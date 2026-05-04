from flask import Flask, request, jsonify, render_template, Blueprint
from pyswip import Prolog

# Initialize Flask and Prolog
mte_chatbot = Blueprint("mte_chatbot", __name__)
prolog_mte = Prolog()

# Load the Prolog knowledge base
try:
    prolog_mte.consult("thrombo_embolic_chatbot.pl")
except Exception as e:
    print(f"Error loading Prolog file: {str(e)}")

# State to track user interaction
user_state = {
    "stage": "menu",
    "current_question": 1,
    "waiting_for_severity": False,
    "last_factor": None,
}


def ensure_user_state():
    """Ensure user_state contains all necessary keys."""
    if "stage" not in user_state:
        user_state["stage"] = "menu"
    if "current_question" not in user_state:
        user_state["current_question"] = 1
    if "waiting_for_severity" not in user_state:
        user_state["waiting_for_severity"] = False
    if "last_factor" not in user_state:
        user_state["last_factor"] = None


@mte_chatbot.route("/mte_chatbot")
def chatbot_home():
    return render_template("mte_chatbot.html")


@mte_chatbot.route("/chat", methods=["POST"])
def chat():
    ensure_user_state()
    user_message = request.json.get("message", "").strip().lower()

    try:
        if user_state["stage"] == "menu":
            return jsonify({"reply": handle_menu(user_message)})
        elif user_state["stage"] == "evaluate_risks":
            return jsonify({"reply": handle_evaluate_risks(user_message)})
        elif user_state["stage"] == "prevention_tips":
            return jsonify({"reply": generate_prevention_tips()})
        elif user_state["stage"] == "explain_factors":
            return jsonify({"reply": explain_factors()})
        else:
            user_state["stage"] = "menu"
            return jsonify({"reply": "An error occurred. Returning to the main menu."})
    except Exception as e:
        return jsonify({"reply": f"An error occurred: {str(e)}<br><br>" + menu()})


def handle_menu(user_message):
    """Handle user selection in the main menu."""
    if user_message == "1":
        user_state["stage"] = "evaluate_risks"
        return get_next_question()
    elif user_message == "2":
        user_state["stage"] = "prevention_tips"
        return generate_prevention_tips()
    elif user_message == "3":
        user_state["stage"] = "explain_factors"
        return explain_factors()
    elif user_message == "4":
        # Quit the chatbot
        reset_user_state()  # Reset the user state
        return "Goodbye! Thank you for using the chatbot."
    else:
        return "Invalid option. Please try again.<br><br>" + menu()


def reset_user_state():
    """Reset the user state to its initial values."""
    user_state["stage"] = "menu"
    user_state["current_question"] = 1
    user_state["waiting_for_severity"] = False
    user_state["last_factor"] = None


def generate_prevention_tips():
    """Fetch and display prevention tips from Prolog."""
    try:
        # Query Prolog for prevention tips
        result = list(prolog_mte.query("thrombo_prevention_tip(Tip)"))

        if result:
            # Format the tips for display
            tips = [
                (
                    entry["Tip"].decode("utf-8")
                    if isinstance(entry["Tip"], bytes)
                    else entry["Tip"]
                )
                for entry in result
            ]
            user_state["stage"] = "menu"  # Reset to menu after displaying tips
            return (
                "=== Prevention Tips ===<br>"
                + "<br>".join(f"- {tip}" for tip in tips)
                + "<br>====================<br>"
                + menu()
            )
        else:
            user_state["stage"] = "menu"
            return "No prevention tips available at the moment.<br><br>" + menu()
    except Exception as e:
        user_state["stage"] = "menu"
        return (
            f"An error occurred while fetching prevention tips: {str(e)}<br><br>"
            + menu()
        )


def get_next_question():
    """Fetch the next question for evaluation."""
    question_index = user_state["current_question"]
    result = list(prolog_mte.query(f"thrombo_question({question_index}, Factor)"))

    if result:
        factor = result[0]["Factor"]
        user_state["last_factor"] = factor

        # Logique spécifique pour l'âge
        if factor == "age":
            return "What is your age? Please enter a positive number."

        # Logique spécifique pour le genre
        if factor == "gender":
            return "Are you male? Please answer 'yes' or 'no'."

        # Logique générale pour les autres facteurs
        return f"Do you have {factor.replace('_', ' ')}? (yes/no/sometimes)"

    # Fin des questions : calculer la probabilité
    user_state["stage"] = "menu"
    return calculate_probability()


def handle_evaluate_risks(user_message):
    """Process user input during evaluation."""
    try:
        factor = user_state["last_factor"]

        # Logique spécifique pour l'âge
        if factor == "age":
            try:
                age = int(user_message)
                if age > 0:
                    prolog_mte.assertz(f"thrombo_user_data('age', {age}, 0)")
                    print(f"Asserted: age = {age}")
                    user_state["current_question"] += 1
                    return get_next_question()
                else:
                    return "Invalid age. Please enter a positive number.<br><br>"
            except ValueError:
                return "Invalid input. Please enter a valid positive number.<br><br>"

        # Logique spécifique pour le genre
        if factor == "gender":
            if user_message in ["yes", "no"]:
                prolog_mte.assertz(f"thrombo_user_data('gender', '{user_message}', 0)")
                print(f"Asserted: gender = {user_message}")
                user_state["current_question"] += 1
                return get_next_question()
            else:
                return "Invalid input. Please answer 'yes' or 'no'.<br><br>"

        # Logique générale pour les autres facteurs
        if user_message in ["yes", "sometimes"]:
            if user_message == "sometimes":
                user_state["waiting_for_severity"] = True
                return "On a scale from 1 to 10, how severe is this condition?<br><br>"
            prolog_mte.assertz(f"thrombo_user_data({repr(factor)}, 'yes', 0)")
        elif user_message == "no":
            prolog_mte.assertz(f"thrombo_user_data({repr(factor)}, 'no', 0)")
        else:
            return "Please respond with 'yes', 'no', or 'sometimes'.<br><br>"

        # Passer à la question suivante
        user_state["current_question"] += 1
        return get_next_question()

    except Exception as e:
        print(f"Error during evaluation: {str(e)}")
        return f"An error occurred: {str(e)}<br><br>" + menu()


def calculate_probability():
    """Calculate thromboembolic disease probability."""
    try:
        result = list(prolog_mte.query("thrombo_risk_evaluation_complete(Probability)"))
        if result:
            probability = result[0]["Probability"]
            advice_result = list(
                prolog_mte.query(f"thrombo_advise({probability}, Advice)")
            )
            advice = advice_result[0]["Advice"]
            return (
                f"Estimated Probability of Thrombo-Embolic Disease: {probability}%<br>Advice:<br>  - {advice}<br><br>"
                + menu()
            )
        else:
            return (
                "Error: No result from Prolog query. Please try again.<br><br>" + menu()
            )
    except Exception as e:
        return f"An error occurred: {str(e)}<br><br>" + menu()


def generate_report():
    """Generate a medical report based on user inputs."""
    try:
        data = list(prolog_mte.query("thrombo_user_data(Factor, Response, Severity)"))
        if not data:
            return "No user data available to generate the report. Please complete the evaluation first."

        formatted_data = "<br>".join(
            [
                f"- {d['Factor']}: {d['Response']} (Severity: {d['Severity']})"
                for d in data
            ]
        )

        probability_result = list(
            prolog_mte.query("thrombo_calculate_probability(Probability)")
        )
        if not probability_result:
            return "Error: Unable to calculate probability."

        probability = probability_result[0]["Probability"]

        advice_result = list(prolog_mte.query(f"thrombo_advise({probability}, Advice)"))
        if not advice_result:
            return "Error: Unable to fetch advice."

        advice = advice_result[0]["Advice"]

        return (
            "=== Medical Report ===<br><br>"
            f"User Data:<br>{formatted_data}<br><br>"
            f"Estimated Probability: {probability}%<br>Advice: {advice}<br><br>"
            + menu()
        )
    except Exception as e:
        return f"An error occurred while generating the report: {str(e)}<br><br>"


def explain_factors():
    """Explain modifiable and non-modifiable factors."""
    try:
        modifiable = list(prolog_mte.query("thrombo_modifiable_factor(F)"))
        non_modifiable = list(prolog_mte.query("thrombo_non_modifiable_factor(F)"))

        if not modifiable and not non_modifiable:
            return "No factors found. Please check the knowledge base."

        def format_factors(factors):
            formatted = []
            for f in factors:
                factor_name = f["F"]
                weight_query = list(
                    prolog_mte.query(f"thrombo_factor_weight({factor_name}, W)")
                )
                if weight_query:
                    weight = weight_query[0]["W"]
                    formatted.append(f"{factor_name} (Weight: {weight})")
            return formatted

        modifiable_factors = format_factors(modifiable)
        non_modifiable_factors = format_factors(non_modifiable)

        return (
            "=== Risk Factors ===<br><br>Modifiable Factors:<br>"
            + "<br>".join(modifiable_factors)
            + "<br><br>Non-Modifiable Factors:<br>"
            + "<br>".join(non_modifiable_factors)
            + "<br><br>"
            + menu()
        )
    except Exception as e:
        return f"An error occurred: {str(e)}<br><br>" + menu()


def menu():
    """Display the main menu options."""
    return (
        "<br><br>What would you like to do next?<br>"
        "1. Evaluate your risk factors.<br>"
        "2. Get prevention tips.<br>"
        "3. Explain risk factors.<br>"
        "4. Quit.<br>"
    )
