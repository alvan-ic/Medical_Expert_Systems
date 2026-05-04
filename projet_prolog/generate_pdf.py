from flask import Flask, send_file
from fpdf import FPDF
import os

app = Flask(__name__)

# Dossier où seront stockés les rapports générés
REPORTS_FOLDER = "reports"
os.makedirs(REPORTS_FOLDER, exist_ok=True)  # Crée le dossier s'il n'existe pas



if __name__ == "__main__":
    app.run(debug=True)
