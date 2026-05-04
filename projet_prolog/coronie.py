from flask import Flask, request, jsonify, render_template
from pyswip import Prolog
from flask import Blueprint

coronie = Blueprint("coronie", __name__)
prolog_cad = Prolog()

# Charger la base de connaissances Prolog
prolog_cad.consult("cad_chatbot.pl")

user_state = {
    "stage": "menu",
    "curreant_question": 1,
    "waiting_for_severity": False,
    "last_factor": None,
}


@coronie.route("/p")
def coroniee():
    return render_template("coronie.html")


@coronie.route("/chat", methods=["POST"])
def chat():
    """Main route for handling user interactions."""
    global user_state

    # Debugging: Print current state
    print("Current user state:", user_state)

    # Get user message
    user_message = request.json.get("message", "").strip().lower()

    # Route based on the current stage
    if user_state["stage"] == "menu":
        return handle_menu(user_message)
    elif user_state["stage"] == "evaluate_risks":
        return handle_evaluate_risks(user_message)
    elif user_state["stage"] == "explain_factors":
        return handle_explain_factors()
    elif user_state["stage"] == "prevention_tips":
        user_state["stage"] = "menu"
        return jsonify({"reply": generate_prevention_tips()})
    else:
        # Reset invalid state to "menu"
        reset_user_state()
        return jsonify({"reply": "Invalid state. Returning to the main menu."})


def handle_menu(user_message):
    """Handle user input from the main menu."""
    if user_message in ["1", "evaluate"]:
        user_state["stage"] = "evaluate_risks"
        user_state["current_question"] = 1
        return start_evaluation()
    elif user_message in ["2", "explain"]:
        user_state["stage"] = "explain_factors"
        return handle_explain_factors()
    elif user_message in ["3", "prevention tips"]:
        user_state["stage"] = "prevention_tips"
        return jsonify({"reply": generate_prevention_tips()})
    elif user_message in ["4", "quit"]:
        # Réinitialiser l'état du chatbot
        reset_user_state()
        return jsonify(
            {"reply": "Thank you for using the CAD Risk Assessment chatbot! Goodbye!"}
        )
    else:
        return jsonify(
            {"reply": append_menu("Invalid option. Please choose 1, 2, 3, or 4.")}
        )


def reset_user_state():
    """Reset the user state to the initial menu state."""
    global user_state
    user_state = {
        "stage": "menu",
        "current_question": 1,
        "waiting_for_severity": False,
        "last_factor": None,
    }
    print("User state has been reset.")


def start_evaluation():
    return jsonify(
        {
            "reply": "You chose to evaluate risk factors. Let's begin!<br><br>"
            + get_next_question()
        }
    )


def get_next_question():
    question_index = user_state["current_question"]
    result = list(prolog_cad.query(f"chd_question({question_index}, Factor)"))

    if result:
        factor = result[0]["Factor"]
        user_state["last_factor"] = factor
        if factor == "age":
            return "What is your age?"
        else:
            return f"Do you have {factor.replace('_', ' ')}? (yes/no/sometimes)"
    else:
        # Plus de questions -> calcul de la probabilité
        return calculate_probability()


def handle_evaluate_risks(user_message):
    global user_state

    # Vérifie si une sévérité est attendue
    if user_state.get("waiting_for_severity"):
        if user_message.isdigit():
            severity = int(user_message)
            if 1 <= severity <= 10:
                last_factor = user_state["last_factor"]
                prolog_cad.assertz(
                    f"user_data_cad({repr(last_factor)}, 'sometimes', {severity})"
                )
                user_state["waiting_for_severity"] = False
                user_state["current_question"] += 1
                return jsonify({"reply": get_next_question()})
            else:
                return jsonify(
                    {"reply": "Please provide a severity level between 1 and 10."}
                )
        else:
            return jsonify({"reply": "Please provide a valid numeric severity level."})

    # Gérer la question de l'âge
    if user_state["last_factor"] == "age":
        if user_message.isdigit():
            age = int(user_message)
            if age > 0:
                prolog_cad.assertz(f"user_data_cad(age, {age}, 0)")
                user_state["current_question"] += 1
                return jsonify({"reply": get_next_question()})
            else:
                return jsonify({"reply": "Please provide a valid positive age."})
        else:
            return jsonify({"reply": "Please provide a valid numeric age."})

    # Gérer les autres facteurs
    if user_message in ["yes", "no", "sometimes"]:
        last_factor = user_state["last_factor"]
        if user_message == "yes":
            prolog_cad.assertz(f"user_data_cad({repr(last_factor)}, 'yes', 0)")
        elif user_message == "no":
            prolog_cad.assertz(f"user_data_cad({repr(last_factor)}, 'no', 0)")
        elif user_message == "sometimes":
            user_state["waiting_for_severity"] = True
            return jsonify(
                {"reply": "On a scale from 1 to 10, how severe is this condition?"}
            )

        user_state["current_question"] += 1
        return jsonify({"reply": get_next_question()})
    else:
        return jsonify({"reply": "Please answer with 'yes', 'no', or 'sometimes'."})


def handle_explain_factors():
    try:
        modifiable = list(prolog_cad.query("modifiable_factor(F)"))
        non_modifiable = list(prolog_cad.query("non_modifiable_factor(F)"))

        if not modifiable and not non_modifiable:
            return jsonify(
                {
                    "reply": "No factors found in the knowledge base. Please check the Prolog file."
                }
            )

        def get_factors_with_weights(factors):
            results = []
            for f in factors:
                factor_name = f["F"]
                weight_result = list(
                    prolog_cad.query(f"chd_factor_weight({factor_name}, W)")
                )
                if weight_result:
                    w = weight_result[0]["W"]
                    results.append(
                        f"{factor_name.replace('_', ' ').capitalize()} (Weight: {w})"
                    )
                else:
                    results.append(
                        f"{factor_name.replace('_', ' ').capitalize()} (Weight: Unknown)"
                    )
            return results

        modifiable_with_weights = get_factors_with_weights(modifiable)
        non_modifiable_with_weights = get_factors_with_weights(non_modifiable)

        reply = (
            "Modifiable factors:<br>"
            + "<br>".join(modifiable_with_weights)
            + "<br><br>Non-modifiable factors:<br>"
            + "<br>".join(non_modifiable_with_weights)
        )

        user_state["stage"] = "menu"  # Retour au menu
        return jsonify({"reply": append_menu(reply)})
    except Exception as e:
        return jsonify({"reply": f"An error occurred: {str(e)}"})


def generate_prevention_tips():
    """Retrieve and display prevention tips from Prolog."""
    try:
        tips = list(prolog_cad.query("chd_prevention_tip(Tip)"))
        if tips:
            formatted_tips = [f"- {t['Tip']}" for t in tips]
            return (
                "=== Prevention Tips ===<br><br>"
                + "<br>".join(formatted_tips)
                + "<br>"
                + append_menu("")
            )
        else:
            return "No prevention tips available at the moment.<br><br>" + append_menu("")
    except Exception as e:
        return (
            f"An error occurred while fetching prevention tips: {str(e)}<br><br>"
            + append_menu("")
        )


def calculate_probability():
    """Calculate risk probability and provide advice."""
    try:
        result = list(prolog_cad.query("chd_risk_evaluation_complete(Probability)"))
        if result:
            probability = result[0]["Probability"]
            advice = (
                "Your risk is VERY HIGH. Seek immediate medical attention."
                if probability >= 80
                else (
                    "Your risk is HIGH. Consult a cardiologist as soon as possible."
                    if probability >= 60
                    else (
                        "Your risk is MODERATE. Focus on lifestyle changes and regular check-ups."
                        if probability >= 40
                        else "Your risk is LOW. Maintain your healthy lifestyle."
                    )
                )
            )
            reply = (
                f"Your estimated probability of CHD is: {probability:.2f}%. {advice}"
            )
        else:
            reply = "Error: Prolog query returned no result. Please check your inputs."
    except Exception as e:
        reply = f"Error during calculation: {str(e)}"

    user_state["stage"] = "menu"  # Reset state
    return append_menu(reply)


def append_menu(response_text):
    menu_text = (
        "<br><br>What would you like to do next?<br>"
        "1. Evaluate your risk factors.<br>"
        "2. Receive explanations about risk factors.<br>"
        "3. Prevention tips.<br>"
        "4. Quit."
    )
    return response_text + menu_text
