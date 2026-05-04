from flask import Flask, request, jsonify, render_template, Blueprint
from pyswip import Prolog

Heart_Valve_Disease = Blueprint("Heart_Valve_Disease", __name__)

prolog1 = Prolog()

# Load Prolog knowledge base
try:
    prolog1.consult("hvd_chatbot_Valve.pl")
except Exception as e:
    print(f"Error loading Prolog file: {e}")

# State to track user interaction
user_state = {
    "stage": "menu",
    "current_question": 1,
    "waiting_for": None,
    "last_factor": None,
    "evaluation_started": False,  # Track if evaluation started
}


@Heart_Valve_Disease.route("/heart_valve")
def heart_valve():
    """Render the homepage."""
    return render_template("heart_valve.html")


@Heart_Valve_Disease.route("/chat", methods=["POST"])
def chat():
    """Main route for handling user interactions."""
    user_message = request.json.get("message", "").strip().lower()

    if user_state["stage"] == "menu":
        return jsonify({"reply": handle_menu(user_message)})
    elif user_state["stage"] == "evaluate_risks":
        return jsonify({"reply": handle_evaluate_risks(user_message)})
    elif user_state["stage"] == "explain_factors":
        return jsonify({"reply": handle_explain_factors()})
    elif user_state["stage"] == "prevention_tips":
        return jsonify({"reply": generate_prevention_tips()})
    else:
        user_state["stage"] = "menu"
        return jsonify(
            {"reply": append_menu("An error occurred. Returning to the menu.")}
        )


def handle_menu(user_message):
    """Handle user input from the main menu."""
    if user_message in ["1", "evaluate"]:
        user_state["stage"] = "evaluate_risks"
        user_state["current_question"] = 1
        user_state["evaluation_started"] = True
        return (
            "You chose to evaluate risk factors. Let's begin!\n\n" + get_next_question()
        )
    elif user_message in ["2", "explain"]:
        user_state["stage"] = "explain_factors"
        return append_menu(handle_explain_factors())
    elif user_message in ["3", "prevention"]:
        user_state["stage"] = "prevention_tips"
        return append_menu(generate_prevention_tips())
    elif user_message in ["4", "quit"]:
        user_state["stage"] = "menu"  # Reset the state to "menu" before exiting
        return "Thank you for using the Heart Valve Disease (HVD) Risk Assessment Chatbot! Goodbye!"
    else:
        return append_menu("Invalid option. Please choose 1, 2, 3, or 4.")


def generate_prevention_tips():
    """Fetch and display heart valve disease prevention tips."""
    try:
        # Query Prolog for prevention tips
        result = list(prolog1.query("valve_prevention_tip(Tip)"))

        if result:
            # Extract and decode tips from the query result
            tips = [
                (
                    entry["Tip"].decode("utf-8")
                    if isinstance(entry["Tip"], bytes)
                    else entry["Tip"]
                )
                for entry in result
            ]
            user_state["stage"] = "menu"  # Return to menu after showing tips
            return (
                "=== Heart Valve Disease Prevention Tips ===<br>"
                + "<br>".join(f"- {tip}" for tip in tips)
                + "<br>==========================================="
            )
        else:
            user_state["stage"] = "menu"  # Return to menu if no tips found
            return "No prevention tips available at the moment."
    except Exception as e:
        user_state["stage"] = "menu"  # Ensure state resets even on error
        return f"An error occurred while fetching prevention tips: {str(e)}"


def get_next_question():
    """Retrieve the next question from Prolog."""
    question_index = user_state["current_question"]
    result = list(prolog1.query(f"valve_diagnostic_question({question_index}, Factor)"))

    if result:
        factor = result[0]["Factor"]
        user_state["last_factor"] = factor
        if factor == "age":
            return "What is your age?"
        else:
            return f"Do you have {factor.replace('_', ' ')}? (yes/no/sometimes)"
    else:
        user_state["stage"] = "menu"
        return append_menu(calculate_probability())


def handle_evaluate_risks(user_message):
    """Process user responses for risk evaluation."""
    # Handle severity input if waiting for severity
    if user_state.get("waiting_for_severity"):
        if user_message.isdigit():
            severity = int(user_message)
            if 1 <= severity <= 10:  # Validate severity range
                last_factor = user_state["last_factor"]
                # Assert user data with severity to Prolog
                prolog1.assertz(
                    f"valve_user_data({repr(last_factor)}, 'sometimes', {severity})"
                )
                print(
                    f"Debug: Asserted {last_factor} = 'sometimes' with severity {severity}"
                )
                user_state["waiting_for_severity"] = False
                user_state["current_question"] += 1
                return get_next_question()
            else:
                return "Please provide a severity level between 1 and 10."
        else:
            return "Please provide a valid numeric severity level."

    # Fetch the current question based on the index
    question_index = user_state["current_question"]
    result = list(prolog1.query(f"valve_diagnostic_question({question_index}, Factor)"))

    # If no more questions, transition to menu
    if not result:
        user_state["stage"] = "menu"
        return append_menu(calculate_probability())

    # Extract the factor for the current question
    factor = result[0]["Factor"]
    user_state["last_factor"] = factor

    # Handle age input
    if factor == "age":
        if user_message.isdigit():
            age = int(user_message)
            if age > 0:  # Validate age
                prolog1.assertz(f"valve_user_data(age, {age}, 0)")
                print(f"Debug: Asserted age({age}) to Prolog")  # Debug
                user_state["current_question"] += 1
                return get_next_question()
            else:
                return "Please provide a valid positive age."
        else:
            return "Please provide a valid numeric age."

    # Handle yes/no/sometimes responses
    if user_message in ["yes", "sometimes"]:
        if user_message == "sometimes":
            # Prompt for severity if "sometimes" is selected
            user_state["waiting_for_severity"] = True
            return "On a scale from 1 to 10, how severe is this condition?"
        # Assert 'yes' response to Prolog
        prolog1.assertz(f"valve_user_data({repr(factor)}, 'yes', 0)")
        print(f"Debug: Asserted {factor} = 'yes'")  # Debug
    elif user_message == "no":
        # Assert 'no' response to Prolog
        prolog1.assertz(f"valve_user_data({repr(factor)}, 'no', 0)")
        print(f"Debug: Asserted {factor} = 'no'")  # Debug
    else:
        return "Please answer with 'yes', 'no', or 'sometimes'."

    # Move to the next question
    user_state["current_question"] += 1
    return get_next_question()


def handle_explain_factors():
    """Explain the risk factors and their weights."""
    try:
        modifiable = list(prolog1.query("valve_modifiable_factor(F)"))
        non_modifiable = list(prolog1.query("valve_non_modifiable_factor(F)"))

        if not (modifiable or non_modifiable):
            return "No factors found in the knowledge base. Please ensure the Prolog file is correct."

        def get_factors_with_weights(factors):
            return [
                f"{f['F'].replace('_', ' ').capitalize()} (Weight: {list(prolog1.query(f'valve_diagnostic_factor_weight({repr(f['F'])}, W)'))[0]['W']})"
                for f in factors
            ]

        modifiable_with_weights = get_factors_with_weights(modifiable)
        non_modifiable_with_weights = get_factors_with_weights(non_modifiable)

        reply = (
        "=== Explanation of Risk Factors ===<br>"
        "Modifiable Factors:<br>"
        + "<br>".join(modifiable_with_weights)
        + "<br><br>Non-modifiable Factors:<br>"
        + "<br>".join(non_modifiable_with_weights)
        + "<br>====================================="
    )

        user_state["stage"] = "menu"
        return reply
    except Exception as e:
        return f"An unexpected error occurred: {str(e)}"


def generate_report():
    """Generate a detailed report based on user data."""
    try:
        result = list(
            prolog1.query("valve_diagnostic_generate_report(Data, Probability, Advice)")
        )
        if not result:
            return "No data available to generate the medical report. Please evaluate your risk factors first."

        # Extract data, probability, and advice
        prolog_result = result[0]
        data = prolog_result["Data"]  # This is a list of tuples
        probability = prolog_result["Probability"]
        advice = prolog_result["Advice"]

        # Build report
        report_lines = ["=== Heart Valve Disease Medical Report ==="]
        for entry in data:  # Iterate through the list of tuples
            factor, response, severity = entry  # Unpack each tuple
            report_lines.append(
                f"- {factor.replace('_', ' ').capitalize()}: {response.capitalize()} (Severity: {severity})"
            )
        report_lines.append(f"\nEstimated Probability: {probability}%")
        report_lines.append(f"Advice: {advice}")
        report_lines.append("\n===========================================")

        return "\n".join(report_lines)
    except ValueError as ve:
        return f"Value Error: {str(ve)}"
    except Exception as e:
        return f"An unexpected error occurred: {str(e)}"


def calculate_probability():
    """Calculate the probability of HVD based on user inputs."""
    try:
        # Query Prolog for probability
        result = list(
            prolog1.query("valve_diagnostic_risk_evaluation_complete(Probability)")
        )

        if result:
            # Récupération de la probabilité
            probability = float(result[0]["Probability"])
            probability = min(
                100, max(0, probability)
            )  # Assurez-vous qu'elle reste entre 0 et 100

            # Conseil basé sur la probabilité
            advice = (
                "Your risk is HIGH. Consult a cardiologist immediately."
                if probability >= 70
                else (
                    "Your risk is MODERATE. Take proactive steps to manage risk factors."
                    if probability >= 40
                    else "Your risk is LOW. Maintain your healthy lifestyle."
                )
            )

            # Debugging logs
            print(f"Debug: Calculated Probability = {probability}%")
            print(f"Debug: Advice = {advice}")

            return (
                f"Your estimated probability of HVD is: {probability:.2f}%.<br>{advice}"
            )
        else:
            return "Error: Unable to calculate probability. Please check your inputs."
    except Exception as e:
        print(f"Error during calculation: {str(e)}")
        return f"An error occurred during calculation: {str(e)}"


def append_menu(response_text):
    """Append the main menu to the response."""
    menu = (
        "<br><br>Welcome to the Heart Valves Chatbot!<br>"
        "Type 'start' to begin or choose an option:<br>"
        "1. Evaluate your risk factors.<br>"
        "2. Receive explanations about risk factors.<br>"
        "3. Prevention tips.<br>"
        "4. Quit."
    )
    return response_text + "\n" + menu
