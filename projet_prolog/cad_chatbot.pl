:- module(chd_risk_assessment, [
    chd_start/0,
    chd_risk_evaluation_complete/1,
    chd_prevention_tip/1,
    chd_explain_factors/0,
    chd_evaluate_risks/0,
    chd_generate_report/0,
    chd_factor_weight/2,
    chd_question/2,
    user_data_cad/3,
    period_data/3
]).

% Declaration of dynamic predicates
:- dynamic calculate_probability/0, user_data_cad/3.
:- dynamic period_data/3.
:- discontiguous weight/2.
:- discontiguous ask_age/2.
:- discontiguous calculate_probability/1.
:- discontiguous ask_period/2.
:- discontiguous display_data/1.
:- discontiguous adjust_for_period/3.
:- discontiguous display_prevention_tips/0.
:- discontiguous display_tips/1.
:- discontiguous chd_explain_factors/0.
:- discontiguous chd_generate_report/3.

% Questions for risk factors
chd_question(1, smoking).
chd_question(2, physical_activity).
chd_question(3, alcohol_excess).
chd_question(4, hypertension).
chd_question(5, high_cholesterol).
chd_question(6, diabetes).
chd_question(7, chronic_conditions).
chd_question(8, healthy_diet).
chd_question(9, stress_or_depression).
chd_question(10, family_history).
chd_question(11, age).

% Categories of risk factors
% Modifiable factors for CHD
modifiable_factor(smoking).
modifiable_factor(physical_activity).
modifiable_factor(alcohol_excess).
modifiable_factor(hypertension).
modifiable_factor(high_cholesterol).
modifiable_factor(diabetes).
modifiable_factor(chronic_conditions).
modifiable_factor(healthy_diet).
modifiable_factor(stress_or_depression).

% Non-modifiable factors for CHD
non_modifiable_factor(family_history).
non_modifiable_factor(age).

% Weights associated with each factor
% Weights associated with each factor (balanced and reduced)
chd_factor_weight(smoking, 10).
chd_factor_weight(physical_activity, 8).
chd_factor_weight(alcohol_excess, 6).
chd_factor_weight(hypertension, 10).
chd_factor_weight(high_cholesterol, 10).
chd_factor_weight(diabetes, 10).
chd_factor_weight(chronic_conditions, 8).
chd_factor_weight(healthy_diet, 8).
chd_factor_weight(stress_or_depression, 8).
chd_factor_weight(family_history, 10).
chd_factor_weight(age, 12).

% Symptom-specific weights
chd_factor_weight(chest_pain, 12).
chd_factor_weight(shortness_of_breath, 10).
chd_factor_weight(fatigue, 8).
chd_factor_weight(rapid_heartbeat, 8).
chd_factor_weight(dizziness, 6).


% Start predicate: entry point for the chatbot
chd_start :-
    writeln("Welcome to the Coronary Heart Disease (CHD) risk assessment chatbot!"),
    writeln("Type the corresponding number:"),
    writeln("1. Evaluate your risk factors."),
    writeln("2. Receive explanations about risk factors."),
    writeln("3. Generate a medical report."),
    writeln("4. Learn about CHD."),
    writeln("5. Quit."),
    read(Choice),
    handle_choice(Choice).

% Handling user choices
handle_choice(1) :-
    writeln("You chose to evaluate risk factors."),
    chd_evaluate_risks.
handle_choice(2) :-
    writeln("You chose to receive explanations."),
    chd_explain_factors.
handle_choice(3) :-
    writeln("You chose to generate a medical report."),
    chd_generate_report.
handle_choice(4) :-
    chd_education.
handle_choice(5) :-
    writeln("Thank you for using the program. Take care!").
handle_choice(_) :-
    writeln("Invalid choice. Please try again."),
    chd_start.

% Predicate to calculate the total probability
% Predicate principal pour évaluer le risque complet de CHD
chd_risk_evaluation_complete(Probability) :-
	% Étape 1 : Récupérer et sommer les poids des réponses 'yes'
findall(WeightedYes,
		(user_data_cad(Factor, Response, _),
			chd_factor_weight(Factor, Weight),
			Response == yes,
			WeightedYes is Weight),
		YesWeights),
	sum_list(YesWeights, TotalYes),
	% Étape 2 : Gestion spécifique de l'âge
	findall(WeightedAge,
		(user_data_cad(age, Age, _),
			chd_factor_weight(age, Weight),
			WeightedAge is (Weight*Age)/100),
		% Normalisation
		AgeWeights),
	sum_list(AgeWeights, TotalAge),
	% Étape 3 : Récupérer et sommer les poids des réponses 'sometimes'
	findall(WeightedSometimes,
		(user_data_cad(Factor, Response, Severity),
			chd_factor_weight(Factor, Weight),
			Response == sometimes,
			WeightedSometimes is (Weight*Severity)/10),
		SometimesWeights),
	sum_list(SometimesWeights, TotalSometimes),
	% Étape 4 : Calcul du score brut total
	RawTotal is TotalYes + TotalAge + TotalSometimes,
	% Étape 5 : Calcul du poids maximal pour normalisation
	findall(Weight,
		chd_factor_weight(_, Weight),
		AllWeights),
	sum_list(AllWeights, MaxWeight),
	% Étape 6 : Normalisation pour obtenir une probabilité entre 0% et 100%
	(MaxWeight > 0 ->
	Probability is min(100,
			(RawTotal/MaxWeight)*100);
	Probability is 0),
	% Debugging : Afficher les résultats intermédiaires
	writeln("Debugging Information:"),
	writeln("TotalYes: "),
	writeln(TotalYes),
	writeln("TotalAge: "),
	writeln(TotalAge),
	writeln("TotalSometimes: "),
	writeln(TotalSometimes),
	writeln("RawTotal: "),
	writeln(RawTotal),
	writeln("MaxWeight: "),
	writeln(MaxWeight),
	writeln("Final Probability: "),
	writeln(Probability).

% Prevention tips
chd_prevention_tip("Avoid smoking and exposure to tobacco.").
chd_prevention_tip("Manage blood pressure with regular check-ups.").
chd_prevention_tip("Control cholesterol levels through diet and medication.").
chd_prevention_tip("Maintain a healthy weight with exercise and balanced meals.").
chd_prevention_tip("Limit alcohol consumption.").
chd_prevention_tip("Reduce stress with mindfulness and relaxation techniques.").
chd_prevention_tip("Engage in regular physical activity like walking or swimming.").
chd_prevention_tip("Monitor and manage diabetes effectively.").
chd_prevention_tip("Eat a heart-healthy diet rich in fruits, vegetables, and whole grains.").
chd_prevention_tip("Improve sleep quality, especially if you have sleep apnea.").
chd_prevention_tip("Address inflammatory conditions to reduce CHD risks.").

% Explain risk factors
explain_modifiable_factors :-
    findall(F,
        modifiable_factor(F),
        RawFactors),
    sort(RawFactors, Factors),
    writeln("Modifiable factors:"),
    display_explanations_with_weights(Factors).
explain_non_modifiable_factors :-
    findall(F,
        non_modifiable_factor(F),
        RawFactors),
    sort(RawFactors, Factors),
    writeln("Non-modifiable factors:"),
    display_explanations_with_weights(Factors).
chd_explain_factors :-
    writeln("=== Explanation of Risk Factors ==="),
    explain_modifiable_factors,
    explain_non_modifiable_factors,
    writeln("===================================").

% Display explanations with weights
display_explanations_with_weights([]).
display_explanations_with_weights([Factor|Rest]) :-
    chd_factor_weight(Factor, Weight),
    format("- ~w : Weight ~w~n", [Factor, Weight]),
    display_explanations_with_weights(Rest).

% Evaluate risk factors
chd_evaluate_risks :-
    writeln("Please answer the following questions to assess your risks."),
    collect_data,
    calculate_probability.

collect_data :-
    ask_question("Do you smoke? (yes/no/sometimes)", smoking),
    ask_question("Do you exercise regularly? (yes/no/sometimes)", physical_activity),
    ask_question("Do you consume alcohol excessively? (yes/no/sometimes)", alcohol_excess),
    ask_question("Do you have high blood pressure? (yes/no/sometimes)", hypertension),
    ask_question("Do you have high cholesterol? (yes/no/sometimes)", high_cholesterol),
    ask_question("Are you diabetic? (yes/no/sometimes)", diabetes),
    ask_question("Do you have other chronic conditions (e.g., arthritis, sleep apnea)? (yes/no/sometimes)", chronic_conditions),
    ask_question("Do you follow a healthy diet? (yes/no/sometimes)", healthy_diet),
    ask_question("Do you experience chronic stress or depression? (yes/no/sometimes)", stress_or_depression),
    ask_age("What is your age?", age),
    ask_question("Do you have a family history of CHD? (yes/no/sometimes)", family_history).

ask_question(Question, Factor) :-
    format("~w~n", [Question]),
    read(Response),
    (Response == yes -> ask_severity(Factor, Response);
     Response == sometimes -> ask_severity(Factor, Response);
     Response == no -> assert(user_data_cad(Factor, no, 0));
     writeln("Invalid response. Please try again."), ask_question(Question, Factor)).

ask_severity(Factor, Response) :-
    writeln("On a scale from 1 to 10, how severe is this condition?"),
    read(Severity),
    (Severity >= 1, Severity =< 10 -> assert(user_data_cad(Factor, Response, Severity));
     writeln("Invalid severity level. Please enter a number between 1 and 10."), ask_severity(Factor, Response)).


ask_age(Question, Factor) :-
	format("~w~n", [Question]),
	read(Age),
	(integer(Age),
		Age > 0 ->
    assert(user_data_cad(Factor, Age, 0));
	writeln("Invalid response. Please enter a valid age."),
		ask_age(Question, Factor)).


% Calculate probability of CHD with normalization




calculate_probability(Probability) :-
	findall(WeightedYes,
		(user_data_cad(Factor, Response, _),
			chd_factor_weight(Factor, Weight),
			Response == yes,
			% Pour tous les facteurs avec 'yes'
			WeightedYes is Weight),
		YesWeights),
	findall(WeightedAge,
		(user_data_cad(age, Age, _),
			% Gestion spécifique de l'âge
			chd_factor_weight(age, Weight),
			WeightedAge is (Weight*Age)/100),
		% Normalisation
		AgeWeights),
	sum_list(YesWeights, TotalYes),
	sum_list(AgeWeights, TotalAge),
	findall(WeightedSometimes,
		(user_data_cad(Factor, Response, Severity),
			chd_factor_weight(Factor, Weight),
			Response == sometimes,
			WeightedSometimes is (Weight*Severity)/10),
		SometimesWeights),
	sum_list(SometimesWeights, TotalSometimes),
	% Calcul total
	RawTotal is TotalYes + TotalSometimes + TotalAge,
	% Normalisation
	findall(Weight,
		chd_factor_weight(_, Weight),
		AllWeights),
	sum_list(AllWeights, MaxWeight),
	(MaxWeight > 0 ->
	Probability is min(100,
			(RawTotal/MaxWeight)*100);
	Probability is 0).




% Advice based on probability
advise(Probability, Advice) :-
    (Probability >= 80 -> Advice = "Your risk is VERY HIGH. Seek immediate medical attention.";
     Probability >= 60 -> Advice = "Your risk is HIGH. Consult a cardiologist as soon as possible.";
     Probability >= 40 -> Advice = "Your risk is MODERATE. Focus on lifestyle changes and regular check-ups.";
     Advice = "Your risk is LOW. Maintain a heart-healthy lifestyle.").

% Generate report
chd_generate_report :-
    writeln("=== CHD Risk Assessment Report ==="),
    findall((Factor, Response, Severity),
        user_data_cad(Factor, Response, Severity),
        Data),
    display_data(Data),
    calculate_probability(Probability),
    advise(Probability, Advice),
    format("\nEstimated Probability of CHD: ~w~n", [Probability]),
    format("Advice : ~w~n", [Advice]).

display_data([]).
display_data([(Factor, Response, Severity)|Rest]) :-
    format("- ~w: ~w (Severity: ~w)~n", [Factor, Response, Severity]),
    display_data(Rest).

% Educational content about CHD
chd_education :-
    writeln("=== Understanding Coronary Heart Disease (CHD) ==="),
    writeln("CHD is caused by plaque buildup in the coronary arteries, reducing blood flow to the heart."),
    writeln("Key risk factors include smoking, high cholesterol, high blood pressure, and sedentary lifestyle."),
    writeln("Symptoms can include chest pain, shortness of breath, and fatigue."),
    writeln("Preventive measures include a healthy diet, regular exercise, and managing chronic conditions."),
    writeln("If you experience symptoms, consult a healthcare provider promptly."),
    writeln("=============================================").
