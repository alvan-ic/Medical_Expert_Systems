:- module(chatbot_diagnostic_heart_failure, [
    modifiable_factor/1,
    non_modifiable_factor/1,
    diagnostic_start/0,
    diagnostic_risk_evaluation_complete/1,
    prevention_tip/1,
    diagnostic_explain_factors/0,
    diagnostic_evaluate_risks/0,
    diagnostic_generate_report/0,
    diagnostic_factor_weight/2,
    diagnostic_question/2,
    advise/2,
    display_prevention_tips/0,
    user_data/3,
    display_data/1
]).

:- dynamic user_data/3.
:- dynamic period_data/3.

% Facteurs modifiables
modifiable_factor(smoking).
modifiable_factor(hypertension).
modifiable_factor(high_cholesterol).
modifiable_factor(diabetes).
modifiable_factor(obesity).
modifiable_factor(sedentary_lifestyle).
modifiable_factor(unhealthy_diet).
modifiable_factor(alcohol).

% Facteurs non modifiables
non_modifiable_factor(age).
non_modifiable_factor(family_history).
non_modifiable_factor(previous_heart_attack).

% Poids des facteurs normalisés
diagnostic_factor_weight(smoking, 6).              % Tabagisme
diagnostic_factor_weight(hypertension, 7).         % Hypertension
diagnostic_factor_weight(high_cholesterol, 6).     % Cholestérol élevé
diagnostic_factor_weight(diabetes, 8).             % Diabète
diagnostic_factor_weight(obesity, 7).              % Obésité
diagnostic_factor_weight(sedentary_lifestyle, 4).  % Mode de vie sédentaire
diagnostic_factor_weight(unhealthy_diet, 4).       % Régime alimentaire malsain
diagnostic_factor_weight(alcohol, 3).              % Consommation d'alcool
diagnostic_factor_weight(age, 7).                  % Âge
diagnostic_factor_weight(family_history, 6).       % Antécédents familiaux
diagnostic_factor_weight(previous_heart_attack, 10).% Antécédents de crise cardiaque

% Poids des symptômes d'insuffisance cardiaque normalisés
diagnostic_factor_weight(shortness_of_breath, 11). % Essoufflement
diagnostic_factor_weight(swollen_ankles, 8).       % Chevilles enflées
diagnostic_factor_weight(fatigue, 6).              % Fatigue
diagnostic_factor_weight(rapid_heartbeat, 8).      % Battements rapides

% Questions pour les symptômes et facteurs de risque
diagnostic_question(1, shortness_of_breath).
diagnostic_question(2, swollen_ankles).
diagnostic_question(3, fatigue).
diagnostic_question(4, rapid_heartbeat).
diagnostic_question(5, smoking).
diagnostic_question(6, hypertension).
diagnostic_question(7, high_cholesterol).
diagnostic_question(8, diabetes).
diagnostic_question(9, obesity).
diagnostic_question(10, sedentary_lifestyle).
diagnostic_question(11, unhealthy_diet).
diagnostic_question(12, alcohol).
diagnostic_question(13, age).
diagnostic_question(14, family_history).
diagnostic_question(15, previous_heart_attack).

% Collecte des données utilisateur
collect_data :-
    ask_question("Are you experiencing shortness of breath? (yes/no/sometimes)", shortness_of_breath),
    ask_question("Are your ankles swollen? (yes/no/sometimes)", swollen_ankles),
    ask_question("Do you feel fatigue? (yes/no/sometimes)", fatigue),
    ask_question("Are you experiencing a rapid heartbeat? (yes/no/sometimes)", rapid_heartbeat),
    ask_question("Do you smoke? (yes/no/sometimes)", smoking),
    ask_question("Do you have high blood pressure? (yes/no/sometimes)", hypertension),
    ask_question("Do you have high cholesterol? (yes/no/sometimes)", high_cholesterol),
    ask_question("Are you diabetic? (yes/no/sometimes)", diabetes),
    ask_question("Are you obese? (yes/no/sometimes)", obesity),
    ask_question("Are you physically inactive? (yes/no/sometimes)", sedentary_lifestyle),
    ask_question("Do you have an unhealthy diet? (yes/no/sometimes)", unhealthy_diet),
    ask_question("Do you consume alcohol? (yes/no/sometimes)", alcohol),
    ask_age("What is your age?", age),
    ask_question("Do you have a family history of heart conditions? (yes/no)", family_history),
    ask_question("Have you experienced a previous heart attack? (yes/no)", previous_heart_attack).



ask_age(Question, Factor) :-
	format("~w~n", [Question]),
	read(Age),
	(integer(Age),
		Age > 0 ->
	assert(user_data(Factor, Age, 0));
	writeln("Invalid age. Try again."),
		ask_age(Question, Factor)).

% Pose une question et enregistre la réponse de l'utilisateur
ask_question(Question, Factor) :-
	format("~w~n", [Question]),
	read(Response),
	(Response == yes ->
	assert(user_data(Factor, yes, 0));
	Response == sometimes ->
	ask_severity(Factor, Response);
	Response == no ->
	assert(user_data(Factor, no, 0));
	writeln("Invalid response. Try again."),
		ask_question(Question, Factor)).

% Pose une question sur la gravité si la réponse est "sometimes"
ask_severity(Factor, Response) :-
	writeln("On a scale from 1 to 10, how severe is it?"),
	read(Severity),
	(integer(Severity),
		Severity >= 1,
		Severity =< 10 ->
	assert(user_data(Factor, Response, Severity));
	writeln("Invalid severity. Try again."),
		ask_severity(Factor, Response)).

% Conseils basés sur la probabilité
advise(Probability, Advice) :-
    (Probability >= 70 ->
        Advice = "Your risk of heart failure is HIGH. Consult a cardiologist immediately.";
    Probability >= 40 ->
        Advice = "Your risk of heart failure is MODERATE. Take proactive steps to reduce risk factors.";
        Advice = "Your risk of heart failure is LOW. Maintain your healthy lifestyle."
    ).

% Conseils de prévention
prevention_tip("Engage in regular physical activity, at least 30 minutes per day.").
prevention_tip("Avoid smoking and exposure to secondhand smoke.").
prevention_tip("Monitor and control blood pressure and cholesterol levels.").
prevention_tip("Maintain a healthy weight to reduce strain on your heart.").
prevention_tip("Adopt a heart-healthy diet, rich in fruits, vegetables, and whole grains.").
prevention_tip("Limit alcohol consumption and stay hydrated.").
prevention_tip("Manage stress through relaxation techniques like meditation or yoga.").
prevention_tip("Get regular medical check-ups to monitor heart health.").

% Génère un rapport médical basé sur les réponses de l'utilisateur


diagnostic_risk_evaluation_complete(Probability) :-
	% Contributions des facteurs de risque (Yes)
findall(WeightedYes,
		(user_data(Factor, yes, _),
			diagnostic_factor_weight(Factor, Weight),
			WeightedYes is Weight),
		YesWeights),
	sum_list(YesWeights, TotalYes),
	% Contributions des facteurs de risque (Sometimes, pondéré par la sévérité)
	findall(WeightedSometimes,
		(user_data(Factor, sometimes, Severity),
			diagnostic_factor_weight(Factor, Weight),
			WeightedSometimes is (Weight*Severity)/10),
		SometimesWeights),
	sum_list(SometimesWeights, TotalSometimes),
	% Contributions des symptômes
	findall(SymptomWeight,
		(user_data(Symptom, yes, _),
			diagnostic_factor_weight(Symptom, Weight),
			SymptomWeight is Weight),
		SymptomWeights),
	sum_list(SymptomWeights, TotalSymptoms),
	% Calcul total des contributions
	RawProbability is TotalYes + TotalSometimes + TotalSymptoms,
	% Calcul du poids total maximal ajusté
	findall(Weight,
		diagnostic_factor_weight(_, Weight),
		AllWeights),
	sum_list(AllWeights, MaxWeight),
	% Normaliser la probabilité en pourcentage
	(MaxWeight > 0 ->
	NormalizedProbability is (RawProbability/MaxWeight)*100;
	NormalizedProbability is 0),
	% Imposer une limite logique de 100%
	Probability is min(NormalizedProbability, 100).


diagnostic_evaluate_risks :-
	writeln("Answer the following questions about your symptoms and lifestyle:"),
	collect_data,
	diagnostic_risk_evaluation_complete(Probability),
	advise(Probability, Advice),
	format("Your estimated risk of heart failure is: ~d%%~n", [Probability]),
    format("Advice : ~w~n", [Advice]).

display_prevention_tips :-
	writeln("=== Heart Failure Prevention Tips ==="),
	findall(Tip,
		prevention_tip(Tip),
		Tips),
	display_tips(Tips),
	writeln("====================================").
display_tips([]).
display_tips([Tip|Rest]) :-
	format("- ~w~n", [Tip]),
	display_tips(Rest).




diagnostic_generate_report :-
	writeln("=== Medical Report ==="),
	(findall((Factor, Response, Severity),
			user_data(Factor, Response, Severity),
			Data),
		Data \= [] ->
	display_data(Data),
		diagnostic_risk_evaluation_complete(Probability),
		advise(Probability, Advice),
		format("Estimated Probability of Heart Failure: ~d%%~n", [Probability]),
        format("Advice : ~w~n", [Advice]));
    writeln("Nouserdataavailable.Pleasecompletethequestionnaire.").


diagnostic_explain_factors :-
	writeln("=== Explanation of Heart Failure Risk Factors ==="),
	writeln("Modifiable Factors:"),
	findall(F,
		 modifiable_factor(F),
		ModifiableFactors),
	display_factors(ModifiableFactors),
	writeln("\nNon-Modifiable Factors:"),
	findall(F,
		non_modifiable_factor(F),
		NonModifiableFactors),
	display_factors(NonModifiableFactors),
	writeln("===============================================").


% Explication des facteurs
diagnostic_explain_factors :-
    writeln("=== Explanation of Heart Failure Risk Factors ==="),
    writeln("Modifiable Factors:"),
    findall(F, modifiable_factor(F), ModifiableFactors),
    display_factors(ModifiableFactors),
    writeln("\nNon-Modifiable Factors:"),
    findall(F, non_modifiable_factor(F), NonModifiableFactors),
    display_factors(NonModifiableFactors),
    writeln("===============================================").

% Point d'entrée du chatbot
diagnostic_start :-
    writeln("Welcome to the Heart Failure Risk Assessment Chatbot!"),
    writeln("Please select an option:"),
    writeln("1. Evaluate your symptoms and risk factors."),
    writeln("2. Learn about risk factors."),
    writeln("3. Get prevention tips."),
    writeln("4. Generate a medical report."),
    writeln("5. Quit."),
    read(Choice),
    handle_choice(Choice).


display_data([]) :-
	writeln("No user data available.").
display_data([(Factor, Response, Severity)|Rest]) :-
	format("- ~w: ~w (Severity: ~w)~n", [Factor, Response, Severity]),
	display_data(Rest).

% Affiche les facteurs avec leurs poids
display_factors([]).
display_factors([Factor|Rest]) :-
	diagnostic_factor_weight(Factor, Weight),
	format("- ~w: Weight: ~w~n", [Factor, Weight]),
	display_factors(Rest).

% Gestion des choix utilisateur
handle_choice(1) :- diagnostic_evaluate_risks.
handle_choice(2) :- diagnostic_explain_factors.
handle_choice(3) :- display_prevention_tips.
handle_choice(4) :- diagnostic_generate_report.
handle_choice(5) :- writeln("Thank you for using the chatbot. Goodbye!").
handle_choice(_) :- writeln("Invalid choice. Try again."), diagnostic_start.
