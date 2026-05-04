:- module(avc_chatbot, [
    collect_data_avc_chatbot/0,
    avc_question/2,
    avc_factor_weight/2,
    avc_modifiable_factor/1,
    avc_non_modifiable_factor/1,
    avc_risk_evaluation_complete/1,
    avc_generate_report/3,
    avc_explain_factors/0,
    avc_prevention_tip/1,
    avc_user_data/3,
    ask_question/2,
    ask_age/2,
    avc_advise/2  
]).


% Declare dynamic predicates for user data
:- dynamic avc_user_data/3.

% Modifiable factors for avc

% Séparation des symptômes et facteurs
avc_symptom(facial_drooping).
avc_symptom(arm_weakness).
avc_symptom(speech_difficulty).
avc_symptom(sudden_headache).
avc_symptom(vision_problems).
avc_symptom(dizziness).
avc_factor(hypertension).
avc_factor(diabetes).
avc_factor(high_cholesterol).
avc_factor(smoking).
avc_factor(obesity).
avc_factor(sedentary_lifestyle).
avc_factor(unhealthy_diet).
avc_factor(alcohol).
avc_factor(previous_avc_tia).
avc_factor(family_history).
avc_factor(gender).
avc_factor(age).



% Modifiable risk factors
avc_modifiable_factor(hypertension).
avc_modifiable_factor(diabetes).
avc_modifiable_factor(high_cholesterol).
avc_modifiable_factor(smoking).
avc_modifiable_factor(obesity).
avc_modifiable_factor(sedentary_lifestyle).
avc_modifiable_factor(unhealthy_diet).
avc_modifiable_factor(alcohol).

% Non-modifiable risk factors
avc_non_modifiable_factor(previous_avc_tia).
avc_non_modifiable_factor(family_history).
avc_non_modifiable_factor(gender).
avc_non_modifiable_factor(age).

% Facteurs de risque ajustés
avc_factor_weight(hypertension, 8.0).
avc_factor_weight(diabetes, 6.5).
avc_factor_weight(high_cholesterol, 5.5).
avc_factor_weight(smoking, 8.0).
avc_factor_weight(obesity, 6.5).
avc_factor_weight(sedentary_lifestyle, 4.0).
avc_factor_weight(unhealthy_diet, 4.0).
avc_factor_weight(alcohol, 3.5).
avc_factor_weight(age, 5.0).
avc_factor_weight(family_history, 5.5).
avc_factor_weight(previous_avc_tia, 9.5).
avc_factor_weight(gender, 3.5).

% Symptômes ajustés
avc_factor_weight(facial_drooping, 10.0).
avc_factor_weight(arm_weakness, 12.0).
avc_factor_weight(speech_difficulty, 12.0).
avc_factor_weight(sudden_headache, 8.0).
avc_factor_weight(vision_problems, 5.0).
avc_factor_weight(dizziness, 3.0).

% Questions for risk factors and symptoms
avc_question(1, facial_drooping).
avc_question(2, arm_weakness).
avc_question(3, speech_difficulty).
avc_question(4, sudden_headache).
avc_question(5, vision_problems).
avc_question(6, dizziness).
avc_question(7, hypertension).
avc_question(8, diabetes).
avc_question(9, high_cholesterol).
avc_question(10, smoking).
avc_question(11, obesity).
avc_question(12, sedentary_lifestyle).
avc_question(13, unhealthy_diet).
avc_question(14, alcohol).
avc_question(15, previous_avc_tia).
avc_question(16, family_history).
avc_question(17, gender).
avc_question(18, age).


% Prevention tips
avc_prevention_tip("Maintain a healthy blood pressure through diet, exercise, and medications.").
avc_prevention_tip("Quit smoking to significantly reduce stroke risk.").
avc_prevention_tip("Adopt a balanced diet rich in fruits, vegetables, and low in salt.").
avc_prevention_tip("Engage in regular physical activity.").
avc_prevention_tip("Limit alcohol consumption to moderate levels.").
avc_prevention_tip("Monitor and control blood sugar levels if diabetic.").
avc_prevention_tip("Get regular check-ups to assess stroke risk.").
avc_prevention_tip("Be vigilant for signs of stroke such as sudden weakness, speech difficulty, or facial drooping.").

% Display prevention tips
ac_display_prevention_tips :-
	writeln("=== Stroke Prevention Tips ==="),
	findall(Tip,
		avc_prevention_tip(Tip),
		Tips),
	display_tips(Tips),
	writeln("==============================").
display_tips([]).
display_tips([Tip|Rest]) :-
	format("- ~w~n", [Tip]),
	display_tips(Rest).



% Collect user responses for avc-related questions
collect_data_avc_chatbot :-
    writeln("Answer the following questions about your symptoms and risk factors:"),
    ask_question("Do you experience facial drooping?", facial_drooping),
    ask_question("Do you experience arm weakness?", arm_weakness),
    ask_question("Do you have difficulty speaking or understanding speech?", speech_difficulty),
    ask_question("Do you experience sudden, severe headaches?", sudden_headache),
    ask_question("Do you have vision problems (e.g., blurred vision, double vision)?", vision_problems),
    ask_question("Do you experience dizziness or loss of balance?", dizziness),
    ask_question("Do you have high blood pressure (hypertension)?", hypertension),
    ask_question("Do you have diabetes?", diabetes),
    ask_question("Do you have high cholesterol?", high_cholesterol),
    ask_question("Do you smoke?", smoking),
    ask_question("Are you overweight or obese?", obesity),
    ask_question("Are you physically inactive (sedentary lifestyle)?", sedentary_lifestyle),
    ask_question("Do you consume an unhealthy diet (e.g., high in salt or fat)?", unhealthy_diet),
    ask_question("Do you drink alcohol excessively?", alcohol),
    ask_question("Have you had a previous avc or TIA?", previous_avc_tia),
    ask_question("Do you have a family history of avc?", family_history),
    ask_question("Are you male?", gender),
    ask_age("What is your age?", age),
    writeln("Data collection complete.").

% Handle questions and responses
ask_question(Question, Factor) :-
    format("~w (yes/no/sometimes)~n", [Question]),
    read(Response),
    (Response == yes -> assertz(avc_user_data(Factor, yes, 0));
     Response == sometimes -> ask_severity(Factor);
     Response == no -> assertz(avc_user_data(Factor, no, 0));
     writeln("Invalid response. Try again."), ask_question(Question, Factor)).

% Handle severity for "sometimes" responses
ask_severity(Factor) :-
    writeln("On a scale from 1 to 10, how severe is it?"),
    read(Severity),
    (integer(Severity), Severity >= 1, Severity =< 10 ->
        assertz(avc_user_data(Factor, sometimes, Severity));
        writeln("Invalid severity. Try again."), ask_severity(Factor)).

% Handle age input
ask_age(Question, Factor) :-
    format("~w~n", [Question]),
    read(Age),
    (integer(Age), Age > 0 ->
        assertz(avc_user_data(Factor, Age, 0));
        writeln("Invalid age. Please enter a positive number."), ask_age(Question, Factor)).

% Calculate risk probability

% Correction du calcul de la probabilité
avc_risk_evaluation_complete(Probability) :-
	% Récupération des facteurs et symptômes déclarés
findall(Weight,
		(avc_user_data(Factor, yes, _),
			avc_factor_weight(Factor, Weight)),
		YesWeights),
	sum_list(YesWeights, TotalYes),
	findall(WeightedSometimes,
		(avc_user_data(Factor, sometimes, Severity),
			avc_factor_weight(Factor, Weight),
			WeightedSometimes is (Weight*Severity)/10),
		SometimesWeights),
	sum_list(SometimesWeights, TotalSometimes),
	% Pas besoin de compter séparément les symptômes
	RawTotal is TotalYes + TotalSometimes,
	% Calcul du poids maximal
	findall(W,
		avc_factor_weight(_, W),
		AllWeights),
	sum_list(AllWeights, MaxWeight),
	(MaxWeight > 0 ->
	ProbabilityValue is (RawTotal/MaxWeight)*100;
	ProbabilityValue is 0),
	% Assurez-vous que la probabilité ne dépasse pas 100%
	Probability is min(100, ProbabilityValue).% Generate report
avc_generate_report(Data, Probability, Advice) :-
    findall((Factor, Response, Severity),
        avc_user_data(Factor, Response, Severity),
        Data),
    avc_risk_evaluation_complete(Probability),
    avc_advise(Probability, Advice).

% Provide advice based on risk probability
avc_advise(Probability, Advice) :-
    (Probability >= 70 ->
        Advice = "Your risk of avc is HIGH. Seek immediate medical attention.";
     Probability >= 40 ->
        Advice = "Your risk of avc is MODERATE. Consider lifestyle changes and consult a physician.";
        Advice = "Your risk of avc is LOW. Maintain a healthy lifestyle.").

% Explain risk factors
avc_explain_factors :-
    writeln("=== Explanation of Stroke Risk Factors ==="),
    writeln("Modifiable Factors:"),
    findall(F, avc_modifiable_factor(F), ModifiableFactors),
    display_factors(ModifiableFactors),
    writeln("\nNon-Modifiable Factors:"),
    findall(F, avc_non_modifiable_factor(F), NonModifiableFactors),
    display_factors(NonModifiableFactors),
    writeln("===========================================").

% Display factors
display_factors([]).
display_factors([Factor | Rest]) :-
    avc_factor_weight(Factor, Weight),
    format("- ~w: Weight: ~w~n", [Factor, Weight]),
    display_factors(Rest).
