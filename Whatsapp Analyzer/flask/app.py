from flask import Flask, request, jsonify
import zipfile
import io
import re
from openai import OpenAI
from pydantic import BaseModel
import os
from dotenv import load_dotenv
from flask_cors import CORS

load_dotenv()

app = Flask(__name__)
CORS(app)

client = OpenAI()

client.api_key = os.environ.get('OPENAI_API_KEY')

class Messages(BaseModel):
    message_without_time: str
    sender: str
    time: str


class Chat(BaseModel):
    messages: list[Messages]
    number_of_leads: str


def parse_whatsapp_messages(text_content):
    """
    Parses WhatsApp chat export text content and extracts messages with their timestamps.
    """
    pattern = r'\[(.*?)\] (.*?): (.*)'
    matches = re.findall(pattern, text_content)
    messages = []
    for match in matches:
        datetime = match[0]
        sender = match[1]
        message = match[2]
        messages.append({'time': datetime, 'message': message, 'sender': sender})
    print(f"Parsed {len(messages)} messages from the text content")
    return messages


@app.route('/upload_zip', methods=['POST'])
def upload_zip():
    print("Received a request to /upload_zip")

    if 'file' not in request.files:
        print("No file part in the request")
        return jsonify({'error': 'No file part in the request'}), 400
    file = request.files['file']

    if file.filename == '':
        print("No file selected")
        return jsonify({'error': 'No file selected'}), 400

    try:
        file_bytes = file.read()
        print(f"Read {len(file_bytes)} bytes from the uploaded file")

        with zipfile.ZipFile(io.BytesIO(file_bytes)) as z:
            txt_contents = {}
            for zip_info in z.infolist():
                print(f"Found file in zip: {zip_info.filename}")
                if zip_info.filename.endswith('.txt'):
                    with z.open(zip_info) as txt_file:
                        content = txt_file.read().decode('utf-8')
                        txt_contents[zip_info.filename] = content
                        print(f"Extracted {len(content)} characters from {zip_info.filename}")

            txt_content = '\n'.join(txt_contents.values())
            print(f"Concatenated text content length: {len(txt_content)}")

            messages = parse_whatsapp_messages(txt_content)
            print(f"Total parsed messages: {len(messages)}")

            batch_size = 500
            final_output = {'messages': [], 'number_of_leads': 0}

            for i in range(0, len(messages), batch_size):
                batch_messages = messages[i:i + batch_size]
                print(f"Processing batch {i // batch_size + 1}: {len(batch_messages)} messages")

                whatsappMessages = '\n'.join(
                    f"{msg['time']} - {msg['sender']}: {msg['message']}" for msg in batch_messages)

                try:
                    response = client.beta.chat.completions.parse(
                        model="gpt-4o-2024-08-06",
                        messages=[
                            {
                                "role": "system",
                                "content": (
                                    "You are a text message analyzer. Go through the provided list of messages "
                                    "and identify which are of lead type, i.e., user showing an intent or interest "
                                    "in a product or service."
                                )
                            },
                            {"role": "user", "content": whatsappMessages}
                        ],
                        response_format=Chat,
                    )
                    print(f"OpenAI API response received for batch {i // batch_size + 1}")

                    parsed_response = response.choices[0].message.parsed


                    messages_as_dict = [msg.dict() for msg in parsed_response.messages]
                    final_output['messages'].extend(messages_as_dict)
                    final_output['number_of_leads'] += int(parsed_response.number_of_leads)
                    print(final_output)
                except Exception as e:
                    print(f"Error calling OpenAI API for batch {i // batch_size + 1}: {e}")
                    return jsonify({'error': f'Error processing batch {i // batch_size + 1}: {str(e)}'}), 500

            print("Returning final output")
            return jsonify(final_output), 200

    except zipfile.BadZipFile:
        print("Invalid zip file")
        return jsonify({'error': 'Invalid zip file'}), 400
    except Exception as e:
        print(f"An error occurred: {e}")
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True)
