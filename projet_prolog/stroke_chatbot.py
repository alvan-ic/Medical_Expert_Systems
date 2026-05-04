from flask import Flask, request, jsonify, render_template, Blueprint
from pyswip import Prolog

# Initialize Flask application and Prolog engine

prolog_stroke = Prolog()
prolog_stroke.consult("avc_chatbot.pl")  # Prolog knowledge base file

stroke_chatbot = Blueprint("stroke_chatbot", __name__)
# Initialize user interaction state
user_state = {
    "stage": "menu",
    "current_question": 1,
    "waiting_for_severity": False,
    "last_factor": None,
}


@stroke_chatbot.route("/stroke_chatbot")
def stroke_chatbott():
    """Render the homepage."""
    return render_template("stroke_chatbot.html")


@stroke_chatbot.route("/chat", methods=["POST"])
def chat():
    """Main route for handling chat interactions."""
    user_message = request.json.get("message", "").strip().lower()

    # Route based on the current user stage
    if user_state["stage"] == "menu":
        return jsonify({"reply": handle_menu(user_message)})
    elif user_state["stage"] == "evaluate_risks":
        response = handle_evaluate_risks(user_message)
        if user_state["stage"] == "menu":  # Return to menu if task is complete
            return jsonify({"reply": response + "\n\n" + menu()})
        return jsonify({"reply": response})
    elif user_state["stage"] == "prevention_tips":
        response = prevention_tips()
        user_state["stage"] = "menu"  # Reset state to menu
        return jsonify({"reply": response})
    elif user_state["stage"] == "explain_factors":
        response = explain_factors()
        user_state["stage"] = "menu"  # Reset state to menu
        return jsonify({"reply": response})
    else:
        user_state["stage"] = "menu"  # Fallback to menu
        return jsonify(
            {"reply": "An error occurred. Returning to the main menu.\n\n" + menu()}
        )


def handle_menu(user_message):
    """Process menu options."""
    if user_message in ["1", "evaluate risks"]:
        user_state["stage"] = "evaluate_risks"
        user_state["current_question"] = 1
        return get_next_question()
    elif user_message in ["2", "prevention tips"]:
        user_state["stage"] = "prevention_tips"
        return prevention_tips()
    elif user_message in ["3", "explain factors"]:
        user_state["stage"] = "explain_factors"
        return explain_factors()
    elif user_message in ["4", "quit"]:
        return "Thank you for using the AVC Risk Assessment Chatbot. Goodbye!"
    else:
        return "Invalid option. Please choose between 1, 2, 3, or 4.\n\n" + menu()


def get_next_question():
    """Fetch the next risk evaluation question."""
    question_index = user_state["current_question"]
    result = list(prolog_stroke.query(f"avc_question({question_index}, Factor)"))

    if result:
        factor = result[0]["Factor"]
        user_state["last_factor"] = factor

        # Logique spécifique pour l'âge
        if factor == "age":
            return "What is your age? (Please enter a positive number)"

        # Logique spécifique pour le genre
        elif factor == "gender":
            return "What is your gender? (male/female)"

        # Pour les autres facteurs standard
        return f"Do you have {factor.replace('_', ' ')}? (yes/no/sometimes)"

    # Fin des questions, calcul de la probabilité
    user_state["stage"] = "menu"
    return calculate_probability()


def handle_evaluate_risks(user_message):
    """Process risk evaluation responses."""
    if user_state["waiting_for_severity"]:
        if user_message.isdigit():
            severity = int(user_message)
            if 1 <= severity <= 10:
                prolog_stroke.assertz(
                    f"avc_user_data({repr(user_state['last_factor'])}, 'sometimes', {severity})"
                )
                user_state["waiting_for_severity"] = False
                user_state["current_question"] += 1
                return get_next_question()
            return "Please provide a severity level between 1 and 10."
        return "Please provide a valid severity level."

    factor = user_state["last_factor"]

    # Handle special cases for age and gender
    if factor == "age":
        if user_message.isdigit() and int(user_message) > 0:
            prolog_stroke.assertz(f"avc_user_data(age, {user_message}, 0)")
            user_state["current_question"] += 1
            return get_next_question()
        return "Invalid age. Please enter a positive number."

    if factor == "gender":
        if user_message in ["yes", "no"]:
            prolog_stroke.assertz(
                f"avc_user_data(gender, {'male' if user_message == 'yes' else 'female'}, 0)"
            )
            user_state["current_question"] += 1
            return get_next_question()
        return "Please respond with 'yes' (male) or 'no' (female)."

    # Handle other factors
    if user_message in ["yes", "sometimes"]:
        if user_message == "sometimes":
            user_state["waiting_for_severity"] = True
            return "On a scale from 1 to 10, how severe is this condition?"
        prolog_stroke.assertz(f"avc_user_data({repr(factor)}, 'yes', 0)")
    elif user_message == "no":
        prolog_stroke.assertz(f"avc_user_data({repr(factor)}, 'no', 0)")
    else:
        return "Please respond with 'yes', 'no', or 'sometimes'."

    user_state["current_question"] += 1
    return get_next_question()


def calculate_probability():
    """Calculate risk probability and provide advice for AVC."""
    try:
        # Appel de la requête Prolog pour évaluer la probabilité
        result = list(prolog_stroke.query("avc_risk_evaluation_complete(Probability)"))
        if result:
            # Extraire la probabilité
            probability = result[0]["Probability"]

            # Récupérer le conseil en fonction de la probabilité
            advice_result = list(
                prolog_stroke.query(f"avc_advise({probability}, Advice)")
            )
            advice = (
                advice_result[0]["Advice"] if advice_result else "No advice available."
            )

            # Retourner le résultat formaté SANS le menu
            return (
                f"Estimated Probability of AVC: {probability:.2f}%<br><br>"
                f"Advice:<br>  - {advice}<br>"
            )
        else:
            return "Error: No result from Prolog query. Please try again."
    except Exception as e:
        return f"An error occurred: {str(e)}"


def prevention_tips():
    """Provide prevention tips to reduce AVC risk."""
    try:
        tips = list(prolog_stroke.query("avc_prevention_tip(Tip)"))
        formatted_tips = [f"- {tip['Tip']}" for tip in tips]
        return (
            "=== Prevention Tips ===\n\n<br><br>"
            + "\n<br>".join(formatted_tips)
            + "\n\n<br><br>"
            + menu()
        )
    except Exception as e:
        return f"An error occurred while fetching prevention tips: {str(e)}"


def explain_factors():
    """Explain the risk factors with their respective weights."""
    try:
        # Query Prolog for modifiable and non-modifiable factors
        modifiable = list(prolog_stroke.query("avc_modifiable_factor(F)"))
        non_modifiable = list(prolog_stroke.query("avc_non_modifiable_factor(F)"))

        # Helper function to fetch weights and format factors
        def format_factors_with_weights(factors):
            formatted = []
            for factor_entry in factors:
                factor_name = factor_entry["F"]
                # Query Prolog for the weight of this factor
                weight_result = list(
                    prolog_stroke.query(f"avc_factor_weight({factor_name}, W)")
                )
                if weight_result:
                    weight = weight_result[0]["W"]
                    formatted.append(
                        f"- {factor_name.replace('_', ' ').capitalize()} (Weight: {weight})"
                    )
                else:
                    formatted.append(
                        f"- {factor_name.replace('_', ' ').capitalize()} (Weight: Unknown)"
                    )
            return formatted

        # Format both modifiable and non-modifiable factors
        modifiable_factors = format_factors_with_weights(modifiable)
        non_modifiable_factors = format_factors_with_weights(non_modifiable)

        # Combine and return the explanation
        return (
            "=== Risk Factors ===\n\n<br><br>"
            "Modifiable factors:\n<br>"
            + "\n<br>".join(modifiable_factors)
            + "\n\n<br><br>"
            "Non-modifiable factors:\n<br>"
            + "\n<br>".join(non_modifiable_factors)
            + "\n\n<br><br>"
            + menu()
        )
    except Exception as e:
        return f"An error occurred while explaining factors: {str(e)}\n\n{menu()}"


def menu():
    """Provide the main menu options."""
    return (
        "What would you like to do next?\n<br>"
        "1. Evaluate your risk factors.\n<br>"
        "2. Receive prevention tips.\n<br>"
        "3. Explain risk factors.\n<br>"
        "4. Quit.<br>"
    )
