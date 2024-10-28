import pandas as pd
import random
from fpdf import FPDF

# Define hospital names, specializations, and cities
hospital_names = [
    "Apollo Hospital", "Fortis Hospital", "Medanta Medical Center", "Max Super Specialty Hospital",
    "Narayana Health", "Kokilaben Dhirubhai Ambani Hospital", "Manipal Hospital",
    "Global Hospital", "Artemis Hospital", "BLK Super Specialty Hospital", "Ruby Hall Clinic",
    "Breach Candy Hospital", "Sir Ganga Ram Hospital", "Care Hospital", "Sunshine Hospital",
    "Aster CMI Hospital", "Yashoda Hospital", "Columbia Asia Hospital", "Lotus Hospital",
    "Metro Hospital"
]
specializations = [
    "Cardiology", "Orthopedics", "Neurology", "Oncology", "Pediatrics",
    "Gastroenterology", "Nephrology", "Gynecology", "Urology", "Pulmonology"
]
cities = ["Mumbai", "Delhi", "Bangalore", "Hyderabad", "Chennai", "Kolkata", "Pune", "Ahmedabad", "Jaipur", "Lucknow"]

# Generate data for 100 hospitals
data = []
for i in range(100):
    name = hospital_names[i % len(hospital_names)]
    specialization = random.choice(specializations)
    address = f"{random.randint(1, 200)}, {random.choice(['Main Street', 'Park Avenue', 'MG Road', 'Station Road'])}, {random.choice(cities)}, India"
    phone = f"+91-{random.randint(7000000000, 9999999999)}"
    email = f"{name.lower().replace(' ', '')}{i+1}@example.com"
    data.append({
        "Hospital Name": name,
        "Specialization": specialization,
        "Address": address,
        "Phone Number": phone,
        "Contact Email": email
    })

# Create DataFrame for easy manipulation (optional)
df_full_hospitals = pd.DataFrame(data)

# Create PDF
pdf = FPDF()
pdf.add_page()
pdf.set_auto_page_break(auto=True, margin=15)
pdf.set_font("Arial", "B", 12)
pdf.cell(200, 10, txt="List of 100 Dummy Hospitals in India", ln=True, align='C')

# Define headers and column widths
headers = ["Hospital Name", "Specialization", "Address", "Phone Number", "Contact Email"]
col_widths = [40, 30, 65, 30, 40]

# Add headers
pdf.set_font("Arial", "B", 10)
pdf.ln(10)
for i, header in enumerate(headers):
    pdf.cell(col_widths[i], 10, txt=header, border=1)
pdf.ln(10)

# Populate table with data
pdf.set_font("Arial", "", 8)
for index, row in df_full_hospitals.iterrows():
    pdf.cell(col_widths[0], 8, row["Hospital Name"], border=1)
    pdf.cell(col_widths[1], 8, row["Specialization"], border=1)
    pdf.cell(col_widths[2], 8, row["Address"], border=1)
    pdf.cell(col_widths[3], 8, row["Phone Number"], border=1)
    pdf.cell(col_widths[4], 8, row["Contact Email"], border=1)
    pdf.ln(8)

# Save PDF
pdf.output("full_hospital_list.pdf")
