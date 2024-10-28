from flask import Flask, render_template, request, redirect, url_for
import PyPDF2

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return "No file part in the request"
    file = request.files['file']
    if file.filename == '':
        return "No file selected for uploading"

    # Only process PDF files
    if file and file.filename.endswith('.pdf'):
        # Read the PDF file
        pdf_reader = PyPDF2.PdfReader(file)
        pdf_text = ""
        for page in pdf_reader.pages:
            pdf_text += page.extract_text()

        # Parse the PDF text into rows and columns
        table_data = parse_pdf_to_table(pdf_text)

        # Render the table data to the template
        return render_template('index.html', table_data=table_data)
    else:
        return "Please upload a PDF file."

def parse_pdf_to_table(pdf_text):
    # Skipping the document title and column headers
    lines = pdf_text.strip().split('\n')
    data_rows = []

    # Start parsing from the actual data (assuming first 2 lines are title/header)
    for line in lines[2:]:
        # Split each line based on a pattern (for now, whitespace + numbers + whitespace)
        columns = line.split()

        # Since each hospital has 5 attributes, validate for correct length
        if len(columns) >= 6:
            # Assuming columns follow order:
            # Hospital Name, Specialization, Address, City, Phone Number, Contact Email
            name = " ".join(columns[0:2])  # Combine first 2 as Hospital Name
            specialization = columns[2]
            address = columns[3]
            city = columns[4]
            phone_number = columns[5]
            contact_email = columns[6]

            data_rows.append([name, specialization, address, city, phone_number, contact_email])

    return data_rows

if __name__ == "__main__":
    app.run(debug=True)
