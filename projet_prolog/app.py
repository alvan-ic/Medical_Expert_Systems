from flask import Flask, render_template, request, jsonify, send_file, make_response
import os
from pyswip import Prolog
from reportlab.lib.pagesizes import letter
from fpdf import FPDF
from pdf_utils import generate_receipt
from io import BytesIO
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib.units import inch
from coronie import coronie
from heart_failure_chatbot import heart_failure_chatbot
from mte_chatbot import mte_chatbot
from stroke_chatbot import stroke_chatbot
from Heart_Valve_Disease import Heart_Valve_Disease
from diagnostic import diagnostic

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

app = Flask(__name__)


# Configuration SMTP
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587
EMAIL_ADDRESS = "assialsm0@gmail.com"
EMAIL_PASSWORD = "wksy ndyv unkt jhql"


user_state = {
    "stage": "menu",
    "current_question": 1,
    "waiting_for": None,
}

# Register the blueprint
app.register_blueprint(coronie, url_prefix="/coronie")

app.register_blueprint(heart_failure_chatbot, url_prefix="/heart_failure_chatbot")
app.register_blueprint(mte_chatbot, url_prefix="/mte_chatbot")
app.register_blueprint(stroke_chatbot, url_prefix="/stroke_chatbot")

app.register_blueprint(Heart_Valve_Disease, url_prefix="/Heart_Valve_Disease")


app.register_blueprint(diagnostic, url_prefix="/diagnostic")


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/appointment")
def appointment():
    return render_template("appointment.html")


@app.route("/send_email", methods=["POST"])
def email():
    try:
        # Récupération des données du formulaire
        name = request.form["name"]
        email = request.form["email"]
        mobile = request.form["mobile"]
        doctor = request.form["doctor"]
        date = request.form["date"]
        time = request.form["time"]
        message = request.form["message"]

        # Configuration de l'email
        msg = MIMEMultipart()
        msg["From"] = EMAIL_ADDRESS
        msg["To"] = email
        msg["Subject"] = "Appointment Confirmation"
        body = (
            f"Dear {name},\n\n"
            f"Your appointment has been scheduled successfully.\n"
            f"Doctor: {doctor}\n"
            f"Date: {date}\n"
            f"Time: {time}\n"
            f"Mobile: {mobile}\n\n"
            f"Message:\n{message}\n\n"
            f"Thank you for choosing our service.\n"
        )
        msg.attach(MIMEText(body, "plain"))

        # Envoi de l'email via le serveur SMTP
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()
        server.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
        server.sendmail(EMAIL_ADDRESS, email, msg.as_string())
        server.quit()

        return jsonify({"status": "success", "message": "Email sent successfully!"})

    except Exception as e:
        return jsonify(
            {"status": "error", "message": f"Failed to send email: {str(e)}"}
        )


@app.route("/chatbot", methods=["GET"])
def chat():
    return render_template("chat.html")  # Page d'accueil avec chat


# @app.route("/send_email", methods=["GET"])
# def appointment():
#     return render_template("appointment.html")  # Page d'accueil avec chat


@app.route("/heart_valve")
def heart_valve():
    """Render the homepage."""
    return render_template("heart_valve.html")


@app.route("/mte_chatbot")
def mte_chatbotQ():
    return render_template("mte_chatbot.html")


@app.route("/chat")
def coronie():
    """Render the homepage."""
    return render_template("coronie.html")


@app.route("/contact")
def contact():
    """Render the homepage."""
    return render_template("contact.html")


@app.route("/stroke_chatbot")
def stroke_chatbott():
    """Render the homepage."""
    return render_template("stroke_chatbot.html")


@app.route("/about")
def about():
    return render_template("about.html")


@app.route("/from")
def form():
    return render_template("form.html")


# @app.route("/cardui")
# def cardui():
#     return render_template("cardui.html")


@app.route("/service")
def service():
    return render_template("service.html")


@app.route("/traitement")
def traitement():
    return render_template("traitement.html")


@app.route("/menu")
def menu():
    return render_template("menu.html")


@app.route("/form1")
def form1():
    return render_template("form1.html")


def predict_heart_disease(age, gender, symptoms, risk_factors):
    """
    Predicts the risk of CAD based on symptoms, risk factors, age, and gender using Python logic.
    """

    # Define weights for symptoms and risk factors
    weights = {
        # Symptoms
        "chest_pain": 30,
        "palpitations": 20,
        "cardiac_arrest": 40,
        "blue_tint": 15,
        "cold_extremities": 10,
        "fatigue_activity": 15,
        "nausea_vomiting": 10,
        "unexplained_fatigue": 15,
        # Risk Factors
        "family_history": 20,
        "smoking": 25,
        "hypertension": 20,
        "high_cholesterol": 20,
        "obesity": 15,
        "sedentary_lifestyle": 10,
    }

    # Initialize total risk score
    total_score = 0

    # Add weights for symptoms
    for symptom in symptoms:
        total_score += weights.get(symptom, 0)

    # Add weights for risk factors
    for risk_factor in risk_factors:
        total_score += weights.get(risk_factor, 0)

    # Add age contribution (older age increases risk)
    if age > 45:
        total_score += 15
    if age > 65:
        total_score += 20

    # Add gender contribution (male has slightly higher risk for CAD)
    if gender == "male":
        total_score += 10

    # Cap the score at a maximum of the sum of possible scores
    max_possible_score = (
        sum(weights.values())
        + 45  # Maximum age contributions
        + 10  # Maximum gender contribution
    )

    probability = min((total_score / max_possible_score) * 100, 100)

    # Round the probability to two decimal places
    probability = round(probability, 2)

    # Generate advice based on the probability
    if probability >= 70:
        advice = "Your risk is HIGH. Consult a cardiologist immediately."
    elif probability >= 40:
        advice = (
            "Your risk is MODERATE. Consider lifestyle changes and monitor your health."
        )
    else:
        advice = "Your risk is LOW. Maintain a healthy lifestyle."

    return {
        "probability": probability,
        "advice": advice,
    }


@app.route("/", methods=["GET", "POST"])
def homee():
    if request.method == "POST":
        # Collect user information from the form
        user_info = {
            "first_name": request.form.get("first_name"),
            "last_name": request.form.get("last_name"),
            "email": request.form.get("email"),
            "phone": request.form.get("phone"),
            "age": int(request.form.get("age")),
            "gender": request.form.get("gender").lower(),
        }

        # Collect symptoms from checkboxes
        symptoms = [
            symptom
            for symptom in [
                "chest_pain" if request.form.get("chest_pain") else None,
                "palpitations" if request.form.get("palpitations") else None,
                "cardiac_arrest" if request.form.get("cardiac_arrest") else None,
                "blue_tint" if request.form.get("blue_tint") else None,
                "cold_extremities" if request.form.get("cold_extremities") else None,
                "fatigue_activity" if request.form.get("fatigue_activity") else None,
                "family_history" if request.form.get("family_history") else None,
                "nausea_vomiting" if request.form.get("nausea_vomiting") else None,
                (
                    "unexplained_fatigue"
                    if request.form.get("unexplained_fatigue")
                    else None
                ),
            ]
            if symptom is not None
        ]

        risk_factors = [
            risk_factor
            for risk_factor in [
                (
                    "sedentary_lifestyle"
                    if request.form.get("sedentary_lifestyle")
                    else None
                ),
                "smoking" if request.form.get("smoking") else None,
                "hypertension" if request.form.get("hypertension") else None,
                "high_cholesterol" if request.form.get("high_cholesterol") else None,
            ]
            if risk_factor is not None
        ]

        # Get prediction from Prolog
        prediction = predict_heart_disease(
            user_info["age"],
            user_info["gender"],
            symptoms,
            risk_factors,
        )

        # Render the results template with collected data
        return render_template(
            "cardui.html",
            first_name=user_info["first_name"],
            last_name=user_info["last_name"],
            email=user_info["email"],
            phone=user_info["phone"],
            age=user_info["age"],
            gender=user_info["gender"],
            prediction=prediction,
            symptoms=symptoms,
            risk_factors=risk_factors,
        )

    # Render the form template for GET requests
    return render_template("form.html")


@app.route("/")
def carduit1():
    return render_template("carduit1.html")


@app.route("/pre", methods=["GET", "POST"])
def home():
    if request.method == "POST":
        try:
            # Collect user information from the form
            user_info = {
                "first_name": request.form.get("first_name"),
                "last_name": request.form.get("last_name"),
                "email": request.form.get("email"),
                "phone": request.form.get("phone"),
                "age": int(request.form.get("age")),
                "gender": request.form.get("gender").lower(),
            }

            # Collect symptoms from checkboxes
            symptoms = [
                symptom
                for symptom in [
                    "chest_pain" if request.form.get("chest_pain") == "yes" else None,
                    (
                        "palpitations"
                        if request.form.get("palpitations") == "yes"
                        else None
                    ),
                    (
                        "cardiac_arrest"
                        if request.form.get("cardiac_arrest") == "yes"
                        else None
                    ),
                    "blue_tint" if request.form.get("blue_tint") == "yes" else None,
                    (
                        "cold_extremities"
                        if request.form.get("cold_extremities") == "yes"
                        else None
                    ),
                    (
                        "fatigue_activity"
                        if request.form.get("fatigue_activity") == "yes"
                        else None
                    ),
                    (
                        "nausea_vomiting"
                        if request.form.get("nausea_vomiting") == "yes"
                        else None
                    ),
                    (
                        "unexplained_fatigue"
                        if request.form.get("unexplained_fatigue") == "yes"
                        else None
                    ),
                ]
                if symptom is not None
            ]

            # Collect risk factors from checkboxes
            risk_factors = [
                risk_factor
                for risk_factor in [
                    (
                        "family_history"
                        if request.form.get("family_history") == "yes"
                        else None
                    ),
                    "smoking" if request.form.get("smoking") == "yes" else None,
                    (
                        "hypertension"
                        if request.form.get("hypertension") == "yes"
                        else None
                    ),
                    (
                        "high_cholesterol"
                        if request.form.get("high_cholesterol") == "yes"
                        else None
                    ),
                    "obesity" if request.form.get("obesity") == "yes" else None,
                    (
                        "sedentary_lifestyle"
                        if request.form.get("sedentary_lifestyle") == "yes"
                        else None
                    ),
                ]
                if risk_factor is not None
            ]

            # Get prediction for CAD
            prediction = predict_cad(
                user_info["age"], user_info["gender"], symptoms, risk_factors
            )

            # Render the results template with collected data
            return render_template(
                "carduit1.html",
                first_name=user_info["first_name"],
                last_name=user_info["last_name"],
                email=user_info["email"],
                phone=user_info["phone"],
                age=user_info["age"],
                gender=user_info["gender"],
                prediction=prediction,
                symptoms=symptoms,
                risk_factors=risk_factors,
            )
        except Exception as e:
            return f"An error occurred: {str(e)}"

    # Render the form template for GET requests
    return render_template("form1.html")


def predict_cad(age, gender, symptoms, risk_factors):
    """
    Predicts the risk of CAD based on symptoms, risk factors, age, and gender using Python logic.
    """

    # Define weights for symptoms and risk factors
    weights = {
        # Symptoms
        "chest_pain": 30,
        "palpitations": 20,
        "cardiac_arrest": 40,
        "blue_tint": 15,
        "cold_extremities": 10,
        "fatigue_activity": 15,
        "nausea_vomiting": 10,
        "unexplained_fatigue": 15,
        "shortness_of_breath": 40,  # Added symptom
        "swollen_ankles": 30,  # Added symptom
    }

    # Risk Factors
    risk_weights = {
        "family_history": 20,
        "smoking": 25,
        "hypertension": 25,  # Adjusted weight
        "high_cholesterol": 20,
        "diabetes": 30,  # Added risk factor
        "obesity": 25,
        "sedentary_lifestyle": 15,  # Adjusted weight
        "unhealthy_diet": 15,  # Added risk factor
    }

    # Initialize total risk score
    total_score = 0

    # Add weights for symptoms
    for symptom in symptoms:
        total_score += weights.get(symptom, 0)

    # Add weights for risk factors
    for risk_factor in risk_factors:
        total_score += risk_weights.get(risk_factor, 0)

    # Add age contribution (older age increases risk)
    if age > 45:
        total_score += 15
    if age > 65:
        total_score += 20

    # Add gender contribution (male has slightly higher risk for CAD)
    if gender == "male":
        total_score += 10

    # Cap the score at a maximum of 100%
    probability = (
        min(total_score / (sum(weights.values()) + sum(risk_weights.values()) + 45), 1)
        * 100
    )

    # Round the probability to two decimal places
    probability = round(probability, 2)

    # Generate advice based on the probability
    if probability >= 70:
        advice = "Your risk is HIGH. Consult a cardiologist immediately."
    elif probability >= 40:
        advice = (
            "Your risk is MODERATE. Consider lifestyle changes and monitor your health."
        )
    else:
        advice = "Your risk is LOW. Maintain a healthy lifestyle."

    return {
        "probability": probability,
        "advice": advice,
    }


# ===================================================


@app.route("/download_report", methods=["GET"])
def download_report():
    # Récupération des paramètres de la requête
    first_name = request.args.get("first_name")
    last_name = request.args.get("last_name")
    email = request.args.get("email")
    phone = request.args.get("phone")
    age = request.args.get("age")
    gender = request.args.get("gender")
    prediction = request.args.get("prediction")

    pdf_file = generate_receipt(
        first_name + " " + last_name, email, age, phone, gender, prediction, " "
    )

    return send_file(pdf_file, as_attachment=True)


# Classe PDF pour personnaliser la génération du reçu
class PDF(FPDF):
    def header(self):
        self.image("logo copy.jpeg", 10, 8, 33)
        self.ln(20)
        self.set_font("Arial", "B", 12)
        self.cell(0, 10, "Your consultation details", 0, 1, "C")
        self.ln(10)
        self.image("test.jpg", 160, 8, w=40, h=40)

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


# def generate_qr_code(data):


def generate_receipt(
    patient_name,
    email,
    date_of_birth,
    mobile_number,
    gender,
    prediction,
    services,
):
    pdf = PDF()
    pdf.add_page()

    pdf.ln(10)

    # Informations personnelles
    pdf.set_font("Arial", "B", 12)
    pdf.cell(0, 10, f"Patient: {patient_name}", 1, 1, "C")
    pdf.ln(5)

    pdf.set_font("Arial", "", 12)
    pdf.cell(0, 10, f"Email: {email}", 1, 1, "C")
    pdf.ln(5)

    pdf.cell(0, 10, f"Age :{date_of_birth} years", 1, 1, "C")
    pdf.ln(5)

    pdf.cell(0, 10, f"Phone number: {mobile_number}", 1, 1, "C")
    pdf.ln(5)

    pdf.cell(0, 10, f"Gander: {gender}", 1, 1, "C")
    pdf.ln(5)

    pdf.cell(0, 10, f"Prediction: { prediction }", 1, 1, "C")
    pdf.ln(5)
    pdf.ln(5)
    pdf.image("bb.jpeg", x=20, y=pdf.get_y(), w=40, h=40)

    # Sauvegarder le fichier PDF
    pdf_file = "receipt.pdf"
    pdf.output(pdf_file)
    return pdf_file


if __name__ == "__main__":
    app.run(debug=True)
