from flask import Flask, request, jsonify
from flask_cors import CORS
from openai import OpenAI

# Initialize Flask app and OpenAI client
app = Flask(__name__)
CORS(app)  # Enable CORS for all routes
client = OpenAI(api_key="YOUR API KEY")  # Replace with your OpenAI API key
@app.route('/summary', methods=['POST'])
def get_summary():
    data = request.json
    prompt = f"Summarize the book '{data['title']}' by {data['author']} in brief. The genre is {data['genre']}."

    try:
        # Use the new OpenAI client structure
        completion = client.chat.completions.create(
            model="gpt-4o",  # Use GPT-4o model
            messages=[
                {"role": "system", "content": "You are a helpful assistant that provides book summaries."},
                {"role": "user", "content": prompt}
            ]
        )
        # Accessing the message content properly
        summary = completion.choices[0].message.content.strip()
        return jsonify({"summary": summary})
    except Exception as e:
        print("Error:", e)  # Debugging: Log the error
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)
