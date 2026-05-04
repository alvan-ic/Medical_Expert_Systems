:- module(chatbot_failure_heart_failure, [
    modifiable_factor_failure/1,
    non_modifiable_factor_failure/1,
    failure_question/2,
    prevention_tip_failure/1,
    failure_factor_weight/2,
    calculate_probability/1,
    failure_generate_report/3,
    explain_factors/0,
    failure_display_data/1,
    advise_failure/2,
    user_data_failure/3,
    failure_risk_evaluation_complete/1
]).

:- dynamic  user_data_failure/3.

% Modifiable and non-modifiable factors
modifiable_factor_failure(smoking).
modifiable_factor_failure(hypertension).
modifiable_factor_failure(high_cholesterol).
modifiable_factor_failure(diabetes).
modifiable_factor_failure(obesity).
modifiable_factor_failure(sedentary_lifestyle).
modifiable_factor_failure(unhealthy_diet).
modifiable_factor_failure(alcohol).

non_modifiable_factor_failure(age).
non_modifiable_factor_failure(family_history).
non_modifiable_factor_failure(previous_heart_attack).



% Questions for symptoms and risk factors
failure_question(1, shortness_of_breath).
failure_question(2, swollen_ankles).
failure_question(3, fatigue).
failure_question(4, rapid_heartbeat).
failure_question(5, smoking).
failure_question(6, hypertension).
failure_question(7, high_cholesterol).
failure_question(8, diabetes).
failure_question(9, obesity).
failure_question(10, sedentary_lifestyle).
failure_question(11, unhealthy_diet).
failure_question(12, alcohol).
failure_question(13, age).
failure_question(14, family_history).
failure_question(15, previous_heart_attack).

% Risk factor weights
% Exemple de définition des poids des facteurs
failure_factor_weight('shortness_of_breath', 6.9).
failure_factor_weight('swollen_ankles', 5.2).
failure_factor_weight('fatigue', 1.7).
failure_factor_weight('rapid_heartbeat', 3.4).
failure_factor_weight('smoking', 8.6).
failure_factor_weight('hypertension', 6.9).
failure_factor_weight('high_cholesterol', 10.3).
failure_factor_weight('diabetes', 8.6).
failure_factor_weight('obesity', 6.9).
failure_factor_weight('sedentary_lifestyle', 5.2).
failure_factor_weight('unhealthy_diet', 6.9).
failure_factor_weight('alcohol', 3.4).
failure_factor_weight('age', 1.7).
failure_factor_weight('family_history', 6.9).
failure_factor_weight('previous_heart_attack', 10.3).





failure_generate_report(Data, Probability, Advice) :-
	% Collect user data
findall((Factor, Response, Severity),
		user_data_failure(Factor, Response, Severity),
		Data),
	% Calculate probability
	calculate_probability(Probability),
	% Provide advice based on probability
	advise_failure(Probability, Advice).

% Prevention tips
prevention_tip_failure("Engage in regular physical activity, at least 30 minutes per day.").
prevention_tip_failure("Avoid smoking and exposure to secondhand smoke.").
prevention_tip_failure("Monitor and control blood pressure and cholesterol levels.").
prevention_tip_failure("Maintain a healthy weight to reduce strain on your heart.").
prevention_tip_failure("Adopt a heart-healthy diet, rich in fruits, vegetables, and whole grains.").
prevention_tip_failure("Limit alcohol consumption and stay hydrated.").
prevention_tip_failure("Manage stress through relaxation techniques like meditation or yoga.").
prevention_tip_failure("Get regular medical check-ups to monitor heart health.").
% Calculate normalized probability of heart failure




calculate_probability(Probability) :-
	% Somme des poids pour les réponses 'yes'
findall(Weight,
		(user_data_failure(Factor, 'yes', _),
			failure_factor_weight(Factor, Weight)),
		YesWeights),
	sum_list(YesWeights, TotalYes),
	% Somme des poids pour les réponses 'sometimes', ajustés par la sévérité
	findall(AdjustedWeight,
		(user_data_failure(Factor, 'sometimes', Severity),
			failure_factor_weight(Factor, Weight),
			AdjustedWeight is (Weight*Severity)/10),
		SometimesWeights),
	sum_list(SometimesWeights, TotalSometimes),
	% Additionner les deux contributions
	Total is TotalYes + TotalSometimes,
	% S'assurer que la probabilité reste dans la plage [0, 100]
	Probability is min(100, Total).

% Generate a failure report


% Provide advice based on probability
advise_failure(Probability, Advice) :-
    (Probability >= 70 -> Advice = "Your risk of heart failure is HIGH. Consult a cardiologist immediately.";
     Probability >= 40 -> Advice = "Your risk of heart failure is MODERATE. Take proactive steps to reduce risk factors.";
     Advice = "Your risk of heart failure is LOW. Maintain a healthy lifestyle.").

% Explain modifiable and non-modifiable factors
explain_factors :-
    writeln("=== Explanation of Heart Failure Risk Factors ==="),
    writeln("Modifiable Factors:"),
    findall(Factor, modifiable_factor_failure(Factor), ModifiableFactors),
    display_factors(ModifiableFactors),
    writeln("\nNon-Modifiable Factors:"),
    findall(Factor, non_modifiable_factor_failure(Factor), NonModifiableFactors),
    display_factors(NonModifiableFactors),
    writeln("===============================================").

% Display user data
failure_display_data([]) :- writeln("No data available.").
failure_display_data([(Factor, Response, Severity)|Rest]) :-
    format("- ~w: Response: ~w, Severity: ~w~n", [Factor, Response, Severity]),
    failure_display_data(Rest).

% Helper to display factors with weights
display_factors([]).
display_factors([Factor|Rest]) :-
    failure_factor_weight(Factor, Weight),
    format("- ~w: Weight ~w~n", [Factor, Weight]),
    display_factors(Rest).






failure_risk_evaluation_complete(Probability) :-
	% Contributions from "yes" responses
findall(WeightedYes,
		(user_data_failure(Factor, yes, _),
			failure_factor_weight(Factor, Weight),
			WeightedYes is Weight),
		YesWeights),
	sum_list(YesWeights, TotalYes),
	writeln("Yes Weights: "),
	writeln(YesWeights),
	% Contributions from "sometimes" responses
	findall(WeightedSometimes,
		(user_data_failure(Factor, sometimes, Severity),
			failure_factor_weight(Factor, Weight),
			WeightedSometimes is (Weight*Severity)/10),
		SometimesWeights),
	sum_list(SometimesWeights, TotalSometimes),
	writeln("Sometimes Weights: "),
	writeln(SometimesWeights),
	% Contributions from symptoms
	findall(SymptomWeight,
		(user_data_failure(Symptom, yes, _),
			failure_factor_weight(Symptom, Weight),
			SymptomWeight is Weight),
		SymptomWeights),
	sum_list(SymptomWeights, TotalSymptoms),
	writeln("Symptom Weights: "),
	writeln(SymptomWeights),
	% Calculate raw probability
	RawProbability is TotalYes + TotalSometimes + TotalSymptoms,
	writeln("Raw Probability: "),
	writeln(RawProbability),
	% Normalize probability to percentage
	findall(MaxWeight,
		failure_factor_weight(_, MaxWeight),
		AllWeights),
	sum_list(AllWeights, MaxWeight),
	writeln("Max Weight: "),
	writeln(MaxWeight),
	(MaxWeight > 0 ->
	Probability is (RawProbability/MaxWeight)*100;
	Probability is 0),
	writeln("Final Probability: "),
	writeln(Probability).


failure_generate_report :-
	writeln("=== Medical Report ==="),
	% Collect user data
	(findall((Factor, Response, Severity),
			user_data_failure(Factor, Response, Severity),
			Data),
		Data \= [] ->
	writeln("User Data:"),
		failure_display_data(Data),
		failure_risk_evaluation_complete(Probability),
		writeln("Calculated Probability: "),
		writeln(Probability),
		advise_failure(Probability, Advice),
		format("Estimated Probability of Heart Failure: ~d%%~n", [Probability]),
        format("Advice : ~w~n", [Advice])
    ;
        writeln("Nouserdataavailable.Pleasecompletethequestionnaire.")
    ),
    writeln(" ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  ==  = ").
