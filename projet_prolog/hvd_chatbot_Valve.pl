:- module(chatbot_diagnostic_heart_valves, [
    valve_modifiable_factor/1,
    valve_non_modifiable_factor/1,
    valve_start/0,
    valve_diagnostic_risk_evaluation_complete/1,
    valve_prevention_tip/1,
    valve_explain_factors/0,
    valve_evaluate_risks/0,
    valve_diagnostic_generate_report/3,
    valve_diagnostic_factor_weight/2,
    valve_diagnostic_question/2,
    valve_advise/2,
    valve_user_data/3,
    collect_data/0
]).


:- dynamic valve_user_data/3.

% Modifiable factors specific to heart valve diseases
valve_modifiable_factor(rheumatic_fever_history).
valve_modifiable_factor(endocarditis_history).
valve_modifiable_factor(hypertension).
valve_modifiable_factor(high_cholesterol).
valve_modifiable_factor(obesity).
valve_modifiable_factor(sedentary_lifestyle).
valve_modifiable_factor(unhealthy_diet).
valve_modifiable_factor(smoking).
valve_modifiable_factor(alcohol).

% Non-modifiable factors specific to heart valve diseases
valve_non_modifiable_factor(age).
valve_non_modifiable_factor(family_history).
valve_non_modifiable_factor(congenital_heart_valve_defects).

% Factor weights
% Symptômes spécifiques
% Symptômes spécifiques
valve_diagnostic_factor_weight('shortness_of_breath', 6.9).
valve_diagnostic_factor_weight('chest_pain', 6.0).
valve_diagnostic_factor_weight('fatigue', 3.4).
valve_diagnostic_factor_weight('heart_murmur', 8.6).
valve_diagnostic_factor_weight('swollen_ankles', 5.2).
valve_diagnostic_factor_weight('dizziness', 5.2).

% Facteurs de risque modifiables
valve_diagnostic_factor_weight('rheumatic_fever_history', 6.0).
valve_diagnostic_factor_weight('endocarditis_history', 8.6).
valve_diagnostic_factor_weight('hypertension', 5.2).
valve_diagnostic_factor_weight('high_cholesterol', 6.9).
valve_diagnostic_factor_weight('obesity', 5.2).
valve_diagnostic_factor_weight('sedentary_lifestyle', 5.2).
valve_diagnostic_factor_weight('unhealthy_diet', 5.2).
valve_diagnostic_factor_weight('smoking', 6.9).
valve_diagnostic_factor_weight('alcohol', 3.4).

% Facteurs non modifiables
valve_diagnostic_factor_weight('age', 3.4).
valve_diagnostic_factor_weight('family_history', 5.2).
valve_diagnostic_factor_weight('congenital_heart_valve_defects', 8.6).

% Questions for symptoms and risk factors
% Questions for symptoms and risk factors specific to heart valve disease
valve_diagnostic_question(1, shortness_of_breath).
valve_diagnostic_question(2, chest_pain).
valve_diagnostic_question(3, fatigue).
valve_diagnostic_question(4, heart_murmur).
valve_diagnostic_question(5, swollen_ankles).
valve_diagnostic_question(6, dizziness).
valve_diagnostic_question(7, rheumatic_fever_history).
valve_diagnostic_question(8, endocarditis_history).
valve_diagnostic_question(9, hypertension).
valve_diagnostic_question(10, high_cholesterol).
valve_diagnostic_question(11, obesity).
valve_diagnostic_question(12, sedentary_lifestyle).
valve_diagnostic_question(13, unhealthy_diet).
valve_diagnostic_question(14, smoking).
valve_diagnostic_question(15, alcohol).
valve_diagnostic_question(16, age).
valve_diagnostic_question(17, family_history).
valve_diagnostic_question(18, congenital_heart_valve_defects).


% Display factors
display_factors([]).
display_factors([Factor | Rest]) :-
    valve_diagnostic_factor_weight(Factor, Weight),
    format("- ~w: Weight: ~w~n", [Factor, Weight]),
    display_factors(Rest).

% Prevention tips
valve_prevention_tip("Get vaccinated to prevent infections that could affect the heart valves.").
valve_prevention_tip("Maintain good dental hygiene to reduce the risk of endocarditis.").
valve_prevention_tip("Engage in regular physical activity to support cardiovascular health.").
valve_prevention_tip("Adopt a heart-healthy diet rich in fruits, vegetables, and whole grains.").
valve_prevention_tip("Avoid smoking and limit alcohol consumption.").
valve_prevention_tip("Monitor and control blood pressure and cholesterol levels.").
valve_prevention_tip("Get regular check-ups to assess heart valve health.").
valve_prevention_tip("Be alert to symptoms like shortness of breath, chest pain, or fatigue, and seek medical attention if they occur.").

% Prevention tips display
valve_display_prevention_tips :-
    writeln("=== Heart Valve Disease Prevention Tips ==="),
    findall(Tip, valve_prevention_tip(Tip), Tips),
    display_tips(Tips),
    writeln("===========================================").

display_tips([]).
display_tips([Tip | Rest]) :-
    format("- ~w~n", [Tip]),
    display_tips(Rest).

% Explain risk factors
valve_explain_factors :-
    writeln("=== Explanation of Heart Valve Disease Risk Factors ==="),
    writeln("Modifiable Factors:"),
    findall(F, valve_modifiable_factor(F), ModifiableFactors),
    display_factors(ModifiableFactors),
    writeln("\nNon-Modifiable Factors:"),
    findall(F, valve_non_modifiable_factor(F), NonModifiableFactors),
    display_factors(NonModifiableFactors),
    writeln("===============================================").

% Collect user data
ask_question(Question, Factor) :-
    format("~w~n", [Question]),
    read(Response),
    (Response == yes -> assert(valve_user_data(Factor, yes, 0));
    Response == sometimes -> ask_severity(Factor, Response);
    Response == no -> assert(valve_user_data(Factor, no, 0));
    writeln("Invalid response. Try again."), ask_question(Question, Factor)).

ask_severity(Factor, Response) :-
    writeln("On a scale from 1 to 10, how severe is it?"),
    read(Severity),
    (integer(Severity), Severity >= 1, Severity =< 10 ->
        assert(valve_user_data(Factor, Response, Severity));
    writeln("Invalid severity. Try again."), ask_severity(Factor, Response)).

ask_age(Question, Factor) :-
    format("~w~n", [Question]),
    read(Age),
    (integer(Age), Age > 0 -> assert(valve_user_data(Factor, Age, 0));
    writeln("Invalid age. Try again."), ask_age(Question, Factor)).

% Diagnostic risk evaluation
% Calculer la probabilité totale des maladies des valves cardiaques
valve_diagnostic_risk_evaluation_complete(Probability) :-
	
	% Somme des poids pour les réponses 'yes'
findall(Weight,
		(valve_user_data(Factor, 'yes', _),
			valve_diagnostic_factor_weight(Factor, Weight)),
		YesWeights),
	sum_list(YesWeights, TotalYes),
	% Somme des poids pour les réponses 'sometimes', ajustés par la sévérité
	findall(AdjustedWeight,
		(valve_user_data(Factor, 'sometimes', Severity),
			valve_diagnostic_factor_weight(Factor, Weight),
			AdjustedWeight is (Weight*Severity)/10),
		SometimesWeights),
	sum_list(SometimesWeights, TotalSometimes),
	% Calculer la somme brute des contributions
	RawTotal is TotalYes + TotalSometimes,
	% Appliquer un facteur d'échelle pour ajuster la probabilité
	ScalingFactor is 1.5,
	% Vous pouvez ajuster ce facteur (1.5, 2.0, etc.) selon le comportement souhaité
	AdjustedTotal is RawTotal/ScalingFactor,
	% S'assurer que la probabilité reste dans la plage [0, 100]
	Probability is min(100,
		max(0, AdjustedTotal)),
	% Débogage pour vérifier les valeurs intermédiaires
	writeln("Debug: Total Yes Weights:"),
	writeln(YesWeights),
	writeln("Debug: Total Sometimes Weights:"),
	writeln(SometimesWeights),
	writeln("Debug: Raw Total:"),
	writeln(RawTotal),
	writeln("Debug: Adjusted Total:"),
	writeln(AdjustedTotal),
	writeln("Debug: Final Probability:"),
	writeln(Probability).


valve_advise(Probability, Advice) :-
    (Probability >= 70 ->
        Advice = "Your risk of heart valve disease is HIGH. Consult a cardiologist immediately.";
    Probability >= 40 ->
        Advice = "Your risk of heart valve disease is MODERATE. Consider lifestyle changes and medical advice.";
        Advice = "Your risk of heart valve disease is LOW. Maintain a healthy lifestyle.").

% Generate diagnostic report
% Generate a detailed medical report
% Generate a detailed diagnostic report

valve_diagnostic_generate_report(Data, Probability, Advice) :-
	findall((Factor, Response, Severity),
		valve_user_data(Factor, Response, Severity),
		Data),
	valve_diagnostic_risk_evaluation_complete(Probability),
	valve_advise(Probability, Advice).


valve_display_data([]) :-
    writeln("No user data available.").
valve_display_data([(Factor, Response, Severity) | Rest]) :-
    format("- ~w: ~w (Severity: ~w)~n", [Factor, Response, Severity]),
    valve_display_data(Rest).

% Handle menu choices
% Handle menu choices
% Handle menu choices
handle_choice(1) :-
    valve_evaluate_risks,  % Evaluate risks
    valve_start.  % Return to the main menu after evaluation

handle_choice(2) :-
    valve_explain_factors,  % Explain risk factors
    valve_start.  % Return to the main menu after explanation

handle_choice(3) :-
    valve_display_prevention_tips,  % Display prevention tips
    valve_start.  % Return to the main menu after displaying tips

handle_choice(4) :-
    % Generate and display the diagnostic report
    (valve_diagnostic_generate_report(Data, Probability, Advice) ->
        writeln("=== Heart Valve Disease Diagnostic Report ==="),
        format("User Data: ~w~n", [Data]),
        format("Estimated Probability: ~d%%~n", [Probability]),
        format("Advice: ~w~n", [Advice]),
        writeln("===========================================");
        writeln("No data available to generate a report. Please evaluate your risks first.")
    ),
    valve_start.  % Return to the main menu after report generation

handle_choice(5) :-
    writeln("Thank you for using the Heart Valve Disease Chatbot. Goodbye!").  % Exit

handle_choice(_) :-
    writeln("Invalid choice. Please try again."),
    valve_start.  % Return to the main menu after invalid input



% Define `valve_evaluate_risks/0`
valve_evaluate_risks :-
	writeln("Answer the following questions about your symptoms and lifestyle:"),
	collect_data,
	valve_diagnostic_risk_evaluation_complete(Probability),
	valve_advise(Probability, Advice),
	format("Your estimated risk of heart valve disease is: ~d~n", [Probability]),
    format("Advice : ~w~n", [Advice]).

% Diagnostic start menu
valve_start :-
    writeln("Welcome to the Heart Valve Disease Risk Assessment Chatbot!"),
    writeln("Please select an option:"),
    writeln("1. Evaluate your symptoms and risk factors."),
    writeln("2. Learn about risk factors."),
    writeln("3. Get prevention tips."),
 
    writeln("4. Quit."),
    read(Choice),
    handle_choice(Choice).

% Define `collect_data/0`
% Collect user responses specific to heart valve disease
collect_data :-
	writeln("Answer the following questions about your symptoms and risk factors:"),
	ask_question("Do you experience shortness of breath?", shortness_of_breath),
	ask_question("Do you feel chest pain or discomfort?", chest_pain),
	ask_question("Do you feel fatigue?", fatigue),
	ask_question("Has a doctor diagnosed you with a heart murmur?", heart_murmur),
	ask_question("Do you have swollen ankles or legs?", swollen_ankles),
	ask_question("Do you experience dizziness or lightheadedness?", dizziness),
	ask_question("Do you have a history of rheumatic fever?", rheumatic_fever_history),
	ask_question("Do you have a history of endocarditis?", endocarditis_history),
	ask_question("Do you have high blood pressure (hypertension)?", hypertension),
	ask_question("Do you have high cholesterol?", high_cholesterol),
	ask_question("Are you obese?", obesity),
	ask_question("Are you physically inactive?", sedentary_lifestyle),
	ask_question("Do you have an unhealthy diet?", unhealthy_diet),
	ask_question("Do you smoke?", smoking),
	ask_question("Do you consume alcohol?", alcohol),
	ask_age("What is your age?", age),
	ask_question("Do you have a family history of heart conditions?", family_history),
	ask_question("Were you born with congenital heart valve defects?", congenital_heart_valve_defects),
	writeln("Data collection complete.").

process_response(Question, yes) :-
	assertz(valve_user_data(Question, yes, 0)).
process_response(Question, no) :-
	assertz(valve_user_data(Question, no, 0)).
process_response(Question, sometimes) :-
	writeln("On a scale from 1 to 10, how severe is it?"),
	read(Severity),
	(integer(Severity),
		Severity >= 1,
		Severity =< 10 ->
	assertz(valve_user_data(Question, sometimes, Severity));
	writeln("Invalid severity. Try again."),
		process_response(Question, sometimes)).
process_response(_, _) :-
	writeln("Invalid response. Please answer with 'yes', 'no', or 'sometimes'."),
	fail.
