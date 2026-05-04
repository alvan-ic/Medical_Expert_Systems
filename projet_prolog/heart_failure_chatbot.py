from flask import Flask, request, jsonify, render_template
from pyswip import Prolog
from flask import Blueprint

heart_failure_chatbot = Blueprint("heart_failure_chatbot", __name__)

# Initialize Prolog instance
prologg = Prolog()
prologg.consult(
    "heart_failure_chatbot.pl"
)  # Ensure the Prolog file is available and correct

# Initialize user interaction state
user_state = {
    "stage": "menu",  # Set the initial stage to 'menu'
    "current_question": 1,
    "waiting_for_severity": False,
    "last_factor": None,
}


@heart_failure_chatbot.route("/f")
def heart_failure_chatbott():
    """Render the homepage."""
    return render_template("heart_failure_chatbot.html")


@heart_failure_chatbot.route("/chattt", methods=["POST"])
def chattt():
    """Main route for handling chat interactions."""
    try:
        # Get user message
        user_message = request.json.get("message", "").strip().lower()
        print(f"Debug: Current state: {user_state['stage']}")

        # Handle different stages
        if user_state["stage"] == "menu":
            reply = handle_menu(user_message)
            return jsonify({"reply": str(reply)})

        elif user_state["stage"] == "evaluate_risks":
            response = handle_evaluate_risks(user_message)
            if user_state["stage"] == "menu":
                # Ensure response and menu are strings
                return jsonify({"reply": str(response) + "\n\n" + str(menu())})
            return jsonify({"reply": str(response)})

        elif user_state["stage"] == "generate_report":
            response = generate_report()
            user_state["stage"] = "menu"
            return jsonify({"reply": str(response)})

        elif user_state["stage"] == "explain_factors":
            response = explain_factors()
            user_state["stage"] = "menu"
            return jsonify({"reply": str(response)})

        elif user_state["stage"] == "prevention_tip_failure":
            response = display_prevention_tips()
            user_state["stage"] = "menu"
            return jsonify({"reply": str(response)})

        # Handle invalid stages or unrecognized state
        user_state["stage"] = "menu"
        return jsonify(
            {
                "reply": "An error occurred. Returning to the main menu.\n\n"
                + str(menu())
            }
        )

    except Exception as e:
        # Log the error for debugging and return a user-friendly message
        print(f"Error in chattt: {e}")
        return jsonify({"reply": f"An error occurred: {str(e)}"})


def generate_report():
    """Generate a detailed medical report."""
    try:
        # Query Prolog for the report
        result = list(prologg.query("diagnostic_generate_report"))
        if not result:
            return (
                "No data available to generate a report. Please evaluate your risk factors first.\n\n"
                + menu()
            )

        # Debug: Log Prolog result
        print(f"Debug: Prolog Result: {result}")

        # Extract Prolog results
        report_data = result[0]
        data = report_data.get("Data", [])
        probability = report_data.get("Probability", 0)
        advice = report_data.get("Advice", "No advice available.")

        # Decode advice if necessary
        if isinstance(advice, bytes):
            advice = advice.decode("utf-8")

        # Format user responses
        if data:
            responses = "\n".join(
                (
                    f"- {entry[0].replace('_', ' ').capitalize()}: {entry[1]} (Severity: {entry[2]})"
                    if len(entry) == 3
                    else f"- Invalid entry: {entry}"
                )
                for entry in data
            )
        else:
            responses = "No responses recorded."

        # Return formatted report
        return (
            f"=== Medical Report ===\n\n"
            f"User Responses:\n{responses}\n\n"
            f"Probability of Heart Failure: {probability}%\n"
            f"Advice: {advice}\n"
            f"=======================\n\n{menu()}"
        )
    except Exception as e:
        return f"An error occurred while generating the report: {str(e)}\n\n{menu()}"


def handle_evaluate_risks(user_message):
    """Process risk evaluation responses."""
    if user_state["waiting_for_severity"]:
        if user_message.isdigit():
            severity = int(user_message)
            if 1 <= severity <= 10:
                prologg.assertz(
                    f"user_data_failure({repr(user_state['last_factor'])}, 'sometimes', {severity})"
                )
                print(
                    f"Debug: Inserted severity for {user_state['last_factor']}, severity: {severity}"
                )
                user_state["waiting_for_severity"] = False
                user_state["current_question"] += 1
                return get_next_risk_question()
            return "Please provide a severity level between 1 and 10."
        return "Please provide a valid severity level."

    # Fetch the current risk factor
    result = list(
        prologg.query(f"failure_question({user_state['current_question']}, Factor)")
    )
    if not result:
        user_state["stage"] = "menu"
        return calculate_probability()

    factor = result[0]["Factor"]
    user_state["last_factor"] = factor

    # Logic specific to "age"
    if factor == "age":
        if user_message.isdigit():
            age = int(user_message)
            if age > 0:
                prologg.assertz(f"user_data_failure(age, {age}, 0)")
                print(f"Debug: Inserted age: {age}")
                user_state["current_question"] += 1
                return get_next_risk_question()
            return "Please provide a valid positive age."
        return "Please provide a numeric response for your age."

    # Standard logic for other factors
    if user_message in ["yes", "sometimes"]:
        if user_message == "sometimes":
            user_state["waiting_for_severity"] = True
            return "On a scale from 1 to 10, how severe is this condition?"
        prologg.assertz(f"user_data_failure({repr(factor)}, 'yes', 0)")
        print(f"Debug: Inserted factor: {factor}, response: yes")
    elif user_message == "no":
        prologg.assertz(f"user_data_failure({repr(factor)}, 'no', 0)")
        print(f"Debug: Inserted factor: {factor}, response: no")
    else:
        return "Please respond with 'yes', 'no', or 'sometimes'."

    user_state["current_question"] += 1
    return get_next_risk_question()


def get_next_risk_question():
    """Fetch the next risk evaluation question."""
    question_index = user_state.get("current_question", 1)
    result = list(prologg.query(f"failure_question({question_index}, Factor)"))
    if result:
        factor = result[0]["Factor"]
        user_state["last_factor"] = factor  # Store the factor for future reference

        # If the factor is "age", ask for a numeric input
        if factor == "age":
            return "What is your age? (Please enter a number)"

        # Otherwise, pose a standard question
        return f"Do you have {factor.replace('_', ' ')}? (yes/no/sometimes)"

    # If all questions have been asked, return to the menu or calculate
    user_state["stage"] = "menu"
    return calculate_probability()


def handle_menu(user_message):
    """Process menu options."""
    if user_message in ["1", "evaluate risks"]:
        user_state["stage"] = "evaluate_risks"
        user_state["current_question"] = 1
        return get_next_risk_question()
    elif user_message in ["2", "prevention tips"]:
        return display_prevention_tips()
    # elif user_message in ["3", "generate report"]:
    #     user_state["stage"] = "generate_report"
    #     return generate_report()
    elif user_message in ["3", "explain factors"]:
        user_state["stage"] = "explain_factors"
        return explain_factors()
    elif user_message in ["4", "quit"]:
        return "Thank you for using the Heart Risk Assessment Chatbot. Goodbye!"
    else:
        return "Invalid option. Please choose between 1, 2, 3, 4, or 5."


def display_prevention_tips():
    """Fetch and display heart failure prevention tips from Prolog."""
    try:
        # Query Prolog for prevention tips
        result = list(prologg.query("prevention_tip_failure(Tip)"))

        if result:
            # Extract tips from the query result
            tips = [entry["Tip"] for entry in result]
            return (
                "=== Heart Failure Prevention Tips ===\n"
                + "\n".join(f"- {tip}" for tip in tips)
                + "\n====================================\n"
                + menu()
            )
        else:
            return "No prevention tips available at the moment.\n\n" + menu()
    except Exception as e:
        return (
            f"An error occurred while fetching prevention tips: {str(e)}\n\n" + menu()
        )


def menu():
    """Provide the main menu options."""
    return (
        "What would you like to do next?\n"
        "1. Evaluate your risk factors.\n"
        "2. Prevention tips.\n"
        # "3. Generate a medical report.\n"
        "3. Explain risk factors.\n"
        "4. Quit."
    )


# def calculate_probability():
#     try:
#         # Exécute la requête Prolog pour obtenir la probabilité
#         result = list(prologg.query("failure_risk_evaluation_complete(Probability)"))

#         # Vérifie si le résultat n'est pas vide
#         if result:
#             # Debug: Affiche le résultat brut de Prolog
#             print(f"Debug: Prolog query result: {result}")

#             # Récupère la probabilité
#             raw_probability = result[0]["Probability"]
#             probability = min(100, max(0, raw_probability))

#             # Debug: Affiche la probabilité brute et la probabilité finale
#             print(f"Debug: Raw Probability: {raw_probability}")
#             print(f"Debug: Final Probability after clamping: {probability}%")

#             # Détermine le niveau de risque basé sur la probabilité
#             if probability >= 70:
#                 advice = "Your risk is HIGH. Consult a cardiologist immediately."
#             elif probability >= 40:
#                 advice = "Your risk is MODERATE. Take proactive steps to manage risk factors."
#             else:
#                 advice = "Your risk is LOW. Maintain a healthy lifestyle."

#             return (
#                 f"Estimated Probability of Heart Failure: {probability}%\n"
#                 f"Advice:\n  - {advice}\n"
#             )
#         else:
#             return "Error: Prolog query returned no result. Please check your inputs and ensure the Prolog database is correctly set up."

#     except KeyError as ke:
#         return f"Error: Missing expected key in the result: {str(ke)}"
#     except Exception as e:
#         return f"An error occurred while calculating the probability: {str(e)}"


def calculate_probability():
    """
    Calculate the probability of heart failure based on user responses.
    The weights for all factors sum to 100.
    """
    try:
        # Query Prolog to collect 'yes' responses and their weights
        yes_weights = list(
            prologg.query(
                "failure_factor_weight(Factor, Weight), user_data_failure(Factor, 'yes', _)"
            )
        )

        # Query Prolog to collect 'sometimes' responses with severity and their weights
        sometimes_weights = list(
            prologg.query(
                "failure_factor_weight(Factor, Weight), user_data_failure(Factor, 'sometimes', Severity)"
            )
        )

        # Calculate total weight for 'yes' responses
        total_yes = sum(float(entry["Weight"]) for entry in yes_weights)

        # Calculate total weight for 'sometimes' responses with severity
        total_sometimes = sum(
            (float(entry["Weight"]) * float(entry["Severity"])) / 10
            for entry in sometimes_weights
        )

        # Final probability is the sum of contributions
        probability = total_yes + total_sometimes

        # Ensure the probability stays in the range [0, 100]
        probability = min(100, max(0, probability))

        # Debugging logs
        print(f"Debug: Total 'Yes' Weight = {total_yes}")
        print(f"Debug: Total 'Sometimes' Weight = {total_sometimes}")
        print(f"Debug: Final Calculated Probability = {probability}%")

        # Generate advice based on probability
        advice_result = list(
            prologg.query(f"advise_failure({int(probability)}, Advice)")
        )
        advice = (
            advice_result[0]["Advice"]
            if advice_result and "Advice" in advice_result[0]
            else "No advice available."
        )

        return (
            f"Your estimated probability of heart failure is: {probability:.2f}%.\n"
            f"Advice: {advice}"
        )

    except Exception as e:
        return f"An error occurred during probability calculation: {str(e)}"


def explain_factors():
    """Explain risk and symptom factors."""
    try:
        modifiable_factors = list(prologg.query("modifiable_factor_failure(F)"))
        non_modifiable_factors = list(prologg.query("non_modifiable_factor_failure(F)"))

        def format_factors(factors, category):
            formatted = []
            for factor in factors:
                factor_name = factor["F"]
                weight_query = list(
                    prologg.query(f"failure_factor_weight({factor_name}, W)")
                )
                weight = weight_query[0]["W"] if weight_query else "Unknown"
                formatted.append(
                    f"- {factor_name.replace('_', ' ').capitalize()} (Weight: {weight})"
                )
            return (
                f"\n{category}:\n" + "\n".join(formatted)
                if formatted
                else f"\n{category}: None available."
            )

        return (
            "=== Explanation of Risk Factors ===\n"
            + format_factors(modifiable_factors, "Modifiable Factors")
            + format_factors(non_modifiable_factors, "Non-Modifiable Factors")
            + "\n===================================\n"
            + menu()
        )
    except Exception as e:
        return f"An error occurred while explaining factors: {str(e)}"
