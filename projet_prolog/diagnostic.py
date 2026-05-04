from flask import (
    Flask,
    render_template,
    request,
    jsonify,
    Blueprint,
)
import os
from pyswip import Prolog

diagnostic = Blueprint("diagnostic", __name__)

user_state = {
    "stage": "menu",
    "current_question": 1,
    "waiting_for": None,
}

# Initialiser Prolog
prolog = Prolog()
prolog.consult("chatbot_diagnostic.pl")  # Charger le module Prolog corrigé


@diagnostic.route("/chat", methods=["POST"])
def chatt():
    user_message = request.json.get("message", "").strip().lower()

    if user_state["stage"] == "menu":
        return handle_menu(user_message)
    elif user_state["stage"] == "evaluate_risks":
        return handle_evaluate_risks(user_message)
    elif user_state["stage"] == "validate_submission":
        return handle_validation(user_message)
    elif user_state["stage"] == "calculate_probability":
        return calculate_probability()
    elif user_state["stage"] == "explain_factors":
        return handle_explain_factors()
    elif user_state["stage"] == "generate_report":
        return generate_report()
    else:
        user_state["stage"] = "menu"  # Reset to 'menu'
        return jsonify(
            {
                "reply": "An error occurred. Returning to the main menu."
                + generate_main_menu()
            }
        )


def handle_explain_factors():
    """
    Provide an explanation of risk factors, categorized by type, along with their weights.
    """
    try:
        # Fetch risk factors from Prolog
        modifiable = fetch_factors("modifiable_factor")
        non_modifiable = fetch_factors("non_modifiable_factor")
        hormonal = fetch_factors("hormonal_factor")

        # Verify that factors exist
        if not (modifiable or non_modifiable or hormonal):
            return jsonify(
                {"reply": "No factors found. Please check the knowledge base."}
            )

        # Format risk factors with their weights
        modifiable_with_weights = format_factors_with_weights(modifiable)
        non_modifiable_with_weights = format_factors_with_weights(non_modifiable)
        hormonal_with_weights = format_factors_with_weights(hormonal)

        # Construct the response message
        reply = (
            "Here are the risk factors categorized by type:<br><br>"
            "Modifiable factors:<br>"
            + "<br>".join(modifiable_with_weights)
            + "<br><br>Non-modifiable factors:<br>"
            + "<br>".join(non_modifiable_with_weights)
            + "<br><br>Hormonal factors:<br>"
            + "<br>".join(hormonal_with_weights)
        )
    except Exception as e:
        # Handle exceptions and provide feedback
        reply = f"An error occurred while fetching factors: {str(e)}"
    finally:
        # Reset state to 'menu' and include the main menu
        user_state["stage"] = "menu"
        reply += generate_main_menu()
        return jsonify({"reply": reply})


def fetch_factors(factor_type):
    """
    Fetch a list of factors for the given category from the Prolog knowledge base.
    """
    try:
        # Query the Prolog knowledge base for the specified factor type
        return list({f["F"] for f in prolog.query(f"{factor_type}(F)")})
    except Exception as e:
        # Return an empty list in case of errors
        print(f"Error fetching factors for {factor_type}: {str(e)}")
        return []


def format_factors_with_weights(factors):
    """
    Format a list of factors by appending their weights from the knowledge base.
    """
    formatted_factors = []
    for factor_name in factors:
        try:
            # Query the weight for the given factor
            weight_query = list(
                prolog.query(f"diagnostic_factor_weight({factor_name}, W)")
            )
            weight = weight_query[0]["W"] if weight_query else "Not specified"
            formatted_factors.append(
                f"{factor_name.replace('_', ' ').capitalize()} (Weight: {weight})"
            )
        except Exception as e:
            # Handle any errors gracefully
            print(f"Error fetching weight for factor {factor_name}: {str(e)}")
            formatted_factors.append(
                f"{factor_name.replace('_', ' ').capitalize()} (Weight: Error)"
            )
    return formatted_factors


def generate_main_menu():
    """
    Generate the HTML string for the main menu options.
    """
    return (
        "<br><br><p>What would you like to do next?</p>"
        "<p>1. Evaluate your risk factors.</p>"
        "<p>2. Receive explanations about risk factors.</p>"
        "<p>3. Generate a medical report.</p>"
        "<p>4. Quit.</p>"
    )


@diagnostic.route("/generate_report", methods=["GET"])
def generate_report():
    """
    Generate a detailed medical report using Prolog data, including user symptoms, probability, and advice.
    """
    try:
        # Collect user data
        user_data = list(prolog.query("user_data(Factor, Response, Severity)"))
        print(f"Debug: Retrieved user data - {user_data}")

        # Collect probability of heart attack
        probability_result = list(
            prolog.query("diagnostic_risk_evaluation_complete(Probability)")
        )
        probability = (
            probability_result[0]["Probability"] if probability_result else "Unknown"
        )
        print(f"Debug: Retrieved probability - {probability}")

        # Collect advice based on probability
        probability_integer = (
            int(probability) if isinstance(probability, float) else probability
        )
        advice_result = list(prolog.query(f"advise({probability_integer}, Advice)"))
        print(f"Debug: Retrieved advice - {advice_result}")
        advice = (
            advice_result[0]["Advice"]
            if advice_result and "Advice" in advice_result[0]
            else "No advice available."
        )

        # Prepare report lines
        report_lines = ["=== Medical Report ===\n<br>"]
        report_lines.append("User Symptoms and Responses:\n<br>")

        if user_data:
            for entry in user_data:
                # Safely process each entry
                factor = str(entry["Factor"]).replace("_", " ").capitalize()
                response = (
                    str(entry["Response"]).capitalize()
                    if isinstance(entry["Response"], str)
                    else str(entry["Response"])
                )
                severity = entry["Severity"]

                report_lines.append(
                    f"- {factor}: {response} (Severity: {severity})<br>"
                )
        else:
            report_lines.append("No user data found.\n<br>")

        report_lines.append(
            f"\nEstimated Probability of Heart Attack: {probability_integer}%\n<br>"
        )
        report_lines.append("Advice:\n<br>")
        report_lines.append(f"  - {advice}")
        report_lines.append("\n=======================\n<br>")

        reply = "\n".join(report_lines)

    except Exception as e:
        reply = f"An error occurred while generating the report: {str(e)}"
    finally:
        # Reset state to menu and include the main menu
        user_state["stage"] = "menu"
        reply += generate_main_menu()
        return jsonify({"reply": reply})


def handle_menu(user_message):
    """
    Handle navigation based on user input in the main menu.
    """
    if user_message in ["1", "evaluate"]:
        user_state["stage"] = "evaluate_risks"
        user_state["current_question"] = 1
        return start_evaluation()
    elif user_message in ["2", "explain"]:
        user_state["stage"] = "explain_factors"
        return handle_explain_factors()
    elif user_message in ["3", "report"]:
        user_state["stage"] = "generate_report"
        return generate_report()
    elif user_message in ["4", "quit"]:
        return jsonify(
            {
                "reply": "Thank you for using the Diagnostic Risk Assessment chatbot! Goodbye!"
            }
        )
    else:
        return jsonify({"reply": "Invalid option. Please choose 1, 2, 3, or 4."})


def start_evaluation():
    """
    Start the evaluation process by asking the first question.
    """
    return jsonify(
        {
            "reply": "You chose to evaluate risk factors. Let's begin!\n\n"
            + get_next_question()
        }
    )


def add_main_menu(response):
    """Ajoutez le menu principal à la réponse pour guider l'utilisateur."""
    menu = (
        "\n\nWhat would you like to do next?\n<br>"
        "1. Evaluate your risk factors.\n<br>"
        "2. Receive explanations about risk factors.\n<br>"
        "3. Generate a medical report.\n<br>"
        "4. Quit."
    )

    response_json = response.get_json()
    response_json["reply"] += menu

    # Réinitialiser l'état de l'utilisateur
    user_state["stage"] = "menu"
    return jsonify(response_json)


def get_next_question():
    """
    Retrieve the next question based on the current question index.
    """
    question_index = user_state["current_question"]
    result = list(prolog.query(f"diagnostic_question({question_index}, Factor)"))

    if result:
        factor = result[0]["Factor"]
        if factor == "age":
            return "What is your age?"
        else:
            return f"Do you have {factor.replace('_', ' ')}? (yes/no/sometimes)"
    else:
        return "No more questions available. Please proceed to calculation."


def handle_evaluate_risks(user_message):
    """
    Handle responses for risk factor evaluation.
    """
    if user_state.get("waiting_for_severity"):
        if user_message.isdigit():
            severity = int(user_message)
            if 1 <= severity <= 10:
                last_factor = user_state["last_factor"]
                prolog.assertz(
                    f"user_data({repr(last_factor)}, 'sometimes', {severity})"
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

    question_index = user_state["current_question"]
    result = list(prolog.query(f"diagnostic_question({question_index}, Factor)"))

    if not result:
        probability_response = calculate_probability()
        return add_main_menu(probability_response)

    factor = result[0]["Factor"]
    user_state["last_factor"] = factor

    if factor == "age":
        if user_message.isdigit():
            age = int(user_message)
            if age > 0:
                prolog.assertz(f"user_data(age, {age}, 0)")
                user_state["current_question"] += 1
                return jsonify({"reply": get_next_question()})
            else:
                return jsonify({"reply": "Please provide a valid positive age."})
        else:
            return jsonify({"reply": "Please provide a valid numeric age."})

    # Handle responses for symptoms and risk factors
    if user_message in ["yes", "sometimes"]:
        # If the answer is 'sometimes', ask for severity
        if user_message == "sometimes":
            user_state["waiting_for_severity"] = True
            return jsonify(
                {"reply": "On a scale from 1 to 10, how severe is this condition?"}
            )
        else:  # If the answer is 'yes'
            prolog.assertz(f"user_data({repr(factor)}, 'yes', 0)")
            user_state["current_question"] += 1
            return jsonify({"reply": get_next_question()})
    elif user_message == "no":
        prolog.assertz(f"user_data({repr(factor)}, 'no', 0)")
        user_state["current_question"] += 1
        return jsonify({"reply": get_next_question()})
    else:
        return jsonify({"reply": "Please answer with 'yes', 'no', or 'sometimes'."})


def handle_validation(user_message):
    """
    Handle validation of the submission and transition to risk calculation.
    """
    if user_message.lower() == "ok":
        user_state["stage"] = "calculate_probability"
        return calculate_probability()
    else:
        return jsonify(
            {"reply": "Invalid input. Type 'ok' to validate your submission."}
        )


def calculate_probability():
    """
    Calculate the probability of a heart attack and provide advice.
    """
    try:
        # Query Prolog for probability
        probability_result = list(
            prolog.query("diagnostic_risk_evaluation_complete(Probability)")
        )

        if probability_result:
            # Assuming Probability is returned as a float
            probability = float(probability_result[0]["Probability"])
            probability =  probability  # Ensure range is [0, 100]

            # Debugging log for Probability
            print(f"Debug: Calculated Probability = {probability}")

            # Query Prolog for advice based on probability
            advice_result = list(prolog.query(f"advise({probability}, Advice)"))
            advice = (
                advice_result[0]["Advice"]
                if advice_result and "Advice" in advice_result[0]
                else "No advice available."
            )

            # Debugging log for Advice
            print(f"Debug: Advice Retrieved = {advice}")

            return jsonify(
                {
                    "reply": f"Your estimated probability of having a heart attack is: {probability:.2f}%.<br>{advice}"
                }
            )
        else:
            return jsonify(
                {"reply": "Error: Unable to calculate probability. Please try again."}
            )
    except Exception as e:
        return jsonify({"reply": f"Error during calculation: {str(e)}"})


