from flask import Flask, render_template, request

app = Flask(__name__)


# Fonction pour déterminer si un pacemaker est nécessaire
def analyse_reponses(reponses):
    # Extraire les réponses
    bradycardie = reponses.get("bradycardie")
    frequence = reponses.get("frequence")
    pause = reponses.get("pause")
    bloc_av = reponses.get("bloc_av")

    # Règles pour déterminer si un pacemaker est nécessaire
    if bradycardie == "oui" and frequence == "oui" and pause == "oui":
        return "Le patient a besoin d'un pacemaker pour cause de bradycardie symptomatique."
    elif bloc_av in ["degre_2", "degre_3"]:
        return f"Le patient a besoin d'un pacemaker à cause d'un bloc AV de {bloc_av}."
    else:
        return "Le patient ne semble pas avoir besoin d'un pacemaker selon les informations fournies."


@app.route("/", methods=["GET", "POST"])
def home():
    diagnostic = None
    if request.method == "POST":
        # Récupérer les réponses de l'utilisateur
        reponses = {
            "bradycardie": request.form.get("bradycardie"),
            "frequence": request.form.get("frequence"),
            "pause": request.form.get("pause"),
            "bloc_av": request.form.get("bloc_av"),
        }
        # Analyser les réponses
        diagnostic = analyse_reponses(reponses)

    return render_template("index.html", diagnostic=diagnostic)


if __name__ == "__main__":
    app.run(debug=True)
