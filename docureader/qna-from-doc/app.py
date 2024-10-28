from flask import Flask, render_template, request, redirect, url_for, flash
import fitz  # PyMuPDF
from openai import OpenAI
import os
from flask_cors import CORS


app = Flask(__name__)
CORS(app)
app.secret_key = "supersecretkey"  # Needed for flashing messages

# Fetch OpenAI API key from environment variable
api_key = os.getenv("OPENAI_KEY")
if not api_key:
    raise ValueError("OpenAI API key not set. Please set the OPENAI_KEY environment variable.")

client = OpenAI(api_key=api_key)

# Global variable to store the extracted PDF content
document_text = ""

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    global document_text
    if 'file' not in request.files:
        flash("No file part in the request.")
        return redirect(url_for('index'))

    file = request.files['file']
    if file.filename == '':
        flash("No file selected for uploading.")
        return redirect(url_for('index'))

    # Check if the file is a PDF
    if file and file.filename.endswith('.pdf'):
        try:
            # Read and extract text from the PDF
            document_text = extract_text_from_pdf(file)
            flash("File uploaded and processed successfully!")
        except Exception as e:
            # Log error and show feedback if extraction fails
            print(f"Error processing PDF: {e}")
            flash("There was an error processing the PDF file. Please try again.")
        return redirect(url_for('index'))
    else:
        flash("Please upload a PDF file.")
        return redirect(url_for('index'))

@app.route('/ask', methods=['POST'])
def ask_question():
    global document_text
    question = request.form.get('question')
    if not question:
        flash("Please enter a question.")
        return redirect(url_for('index'))

    # Call GPT-4 API with document content and question
    answer = get_answer_from_gpt4(document_text, question)
    return render_template('index.html', question=question, answer=answer)

def extract_text_from_pdf(pdf_file):
    """Extracts text from a PDF file."""
    text = ""
    # Load PDF with PyMuPDF (fitz)
    with fitz.open(stream=pdf_file.read(), filetype="pdf") as pdf:
        for page in pdf:
            text += page.get_text()
    return text

def get_answer_from_gpt4(document_text, question):
    """Fetches an answer from GPT-4 based on document content and the question."""
    messages = [
        {"role": "system", "content": "You are a helpful assistant that answers questions based on provided document content."},
        {"role": "user", "content": f"Document content:\n{document_text}\n\nQuestion: {question}"}
    ]

    # Using the new OpenAI client structure for creating a chat completion
    completion = client.chat.completions.create(
        model="gpt-4o",
        messages=messages
    )

    # Extract and return the response content directly from the message
    answer = completion.choices[0].message.content
    return answer

if __name__ == "__main__":
    app.run(debug=True)
