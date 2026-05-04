from fpdf import FPDF
import segno
from io import BytesIO


class PDF(FPDF):
    def header(self):
        self.image("CMPF.jpg", 10, 8, 33)
        self.ln(20)
        self.set_font("Arial", "B", 12)
        self.cell(0, 10, "Reçu de confirmation de rendez-vous", 0, 1, "C")
        self.ln(10)
        self.image("logo.jpeg", 160, 8, w=50, h=50)

    def footer(self):
        self.set_y(-15)
        self.set_font("Arial", "I", 8)
        self.cell(0, 10, f"Page {self.page_no()}", 0, 0, "C")

    def chapter_title(self, title):
        self.set_font("Arial", "B", 12)
        self.cell(0, 10, title, 0, 1, "C")
        self.ln(4)

    def chapter_body(self, body):
        self.set_font("Arial", "", 12)
        self.multi_cell(0, 10, body, align="C")
        self.ln()


def generate_qr_code(data):
    qr = segno.make(data)
    qr.save("qrcode.png")


def generate_receipt(
    patient_name, email, date_of_birth, mobile_number, gender, address, cin, services
):
    pdf = PDF()
    pdf.add_page()

    pdf.ln(10)

    pdf.set_font("Arial", "B", 12)
    pdf.cell(0, 10, f"Patient: {patient_name}", 1, 1, "C")
    pdf.ln(5)

    pdf.set_font("Arial", "", 12)
    pdf.cell(0, 10, f"Email: {email}", 1, 1, "C")
    pdf.ln(5)

    pdf.cell(0, 10, f"Date de naissance: {date_of_birth}", 1, 1, "C")
    pdf.ln(5)

    pdf.cell(0, 10, f"Numéro de téléphone: {mobile_number}", 1, 1, "C")
    pdf.ln(5)

    pdf.cell(0, 10, f"Genre: {gender}", 1, 1, "C")
    pdf.ln(5)

    pdf.cell(0, 10, f"Adresse: {address}", 1, 1, "C")
    pdf.ln(5)

    pdf.cell(0, 10, f"Adresse: {address}", 1, 1, "C")
    pdf.ln(5)

    if cin:
        pdf.cell(0, 10, f"CIN: {cin}", 1, 1, "C")
        pdf.ln(5)

    pdf.set_font("Arial", "B", 12)
    pdf.cell(0, 10, "Services sélectionnés:", 0, 1, "C")
    pdf.set_font("Arial", "", 12)
    for service in services:
        pdf.cell(0, 10, service, 1, 1, "C")
        pdf.ln(5)

        # Generate QR code for each service with a URL
    qr_data = (
        f"http://example.com/service_details?service={service.replace(' ', '%20')}"
    )
    generate_qr_code(qr_data)
    # Ajout de l'image QR code et du logo à la fin de la page
    pdf.image("qrcode.png", x=150, y=pdf.get_y(), w=50, h=50)
    pdf.ln(5)  # Ensure there is space for the QR code

    pdf.ln(5)
    pdf.image("test.png", x=20, y=pdf.get_y(), w=40, h=40)

    pdf_file = "receipt.pdf"
    pdf.output(pdf_file)
    return pdf_file
