% Define the module and exported predicates
:- module(thrombo_chatbot, [
    thrombo_question/2,
    thrombo_modifiable_factor/1,
    thrombo_non_modifiable_factor/1,
    thrombo_start/0,
    thrombo_advise/2,
    thrombo_risk_evaluation_complete/1,
    thrombo_prevention_tip/1,
    thrombo_explain_factors/0,
    thrombo_evaluate_risks/0,
    thrombo_generate_report/3,
    thrombo_factor_weight/2,
    thrombo_user_data/3,
    collect_data_thrombo_chatbot/0
 
]).

% Declare dynamic predicates
:- dynamic thrombo_user_data/3.


:- discontiguous thrombo_chatbot:thrombo_prevention_tip/1.
% Modifiable factors for thrombo
thrombo_modifiable_factor(hypertension).  % High blood pressure
thrombo_modifiable_factor(diabetes).  % Diabetes
thrombo_modifiable_factor(high_cholesterol).  % High cholesterol
thrombo_modifiable_factor(smoking).  % Smoking
thrombo_modifiable_factor(obesity).  % Obesity
thrombo_modifiable_factor(sedentary_lifestyle).  % Lack of physical activity
thrombo_modifiable_factor(unhealthy_diet).  % Diet high in salt or fat
thrombo_modifiable_factor(alcohol).  % Excessive alcohol consumption

% Non-modifiable factors for thrombo
thrombo_non_modifiable_factor(age).  % Advanced age
thrombo_non_modifiable_factor(family_history).  % Family history of thrombo
thrombo_non_modifiable_factor(previous_thrombo_tia).  % History of thrombo or TIA
thrombo_non_modifiable_factor(gender).  % Gender

% Factor weights
% Facteurs de risque
thrombo_factor_weight(hypertension, 8.2).
thrombo_factor_weight(diabetes, 5.9).
thrombo_factor_weight(high_cholesterol, 4.7).
thrombo_factor_weight(smoking, 7.1).
thrombo_factor_weight(obesity, 5.9).
thrombo_factor_weight(sedentary_lifestyle, 3.5).
thrombo_factor_weight(unhealthy_diet, 3.5).
thrombo_factor_weight(alcohol, 2.4).
thrombo_factor_weight(age, 5.9).
thrombo_factor_weight(family_history, 4.7).
thrombo_factor_weight(previous_thrombo_tia, 9.4).
thrombo_factor_weight(gender, 2.4).

% Symptômes spécifiques
thrombo_factor_weight(facial_drooping, 9.4).
thrombo_factor_weight(arm_weakness, 11.8).
thrombo_factor_weight(speech_difficulty, 11.8).
thrombo_factor_weight(sudden_headache, 8.2).
thrombo_factor_weight(vision_problems, 7.1).
thrombo_factor_weight(dizziness, 5.9).


% Questions for symptoms and risk factors
thrombo_question(1, facial_drooping).
thrombo_question(2, arm_weakness).
thrombo_question(3, speech_difficulty).
thrombo_question(4, sudden_headache).
thrombo_question(5, vision_problems).
thrombo_question(6, dizziness).
thrombo_question(7, hypertension).
thrombo_question(8, diabetes).
thrombo_question(9, high_cholesterol).
thrombo_question(10, smoking).
thrombo_question(11, obesity).
thrombo_question(12, sedentary_lifestyle).
thrombo_question(13, unhealthy_diet).
thrombo_question(14, alcohol).
thrombo_question(15, age).
thrombo_question(16, family_history).
thrombo_question(17, previous_thrombo_tia).
thrombo_question(18, gender).

% Prevention tips
thrombo_prevention_tip("Maintain a healthy blood pressure through diet, exercise, and medications.").
thrombo_prevention_tip("Quit smoking to significantly reduce thrombo risk.").
thrombo_prevention_tip("Adopt a balanced diet rich in fruits, vegetables, and low in salt.").
thrombo_prevention_tip("Engage in regular physical activity.").
thrombo_prevention_tip("Limit alcohol consumption to moderate levels.").
thrombo_prevention_tip("Monitor and control blood sugar levels if diabetic.").
thrombo_prevention_tip("Get regular check-ups to assess thrombo risk.").
thrombo_prevention_tip("Be vigilant for signs of thrombo such as sudden weakness, speech difficulty, or facial drooping.").

% Display prevention tips
thrombo_display_prevention_tips :-
    writeln("=== Stroke Prevention Tips ==="),
    findall(Tip, thrombo_prevention_tip(Tip), Tips),
    display_tips(Tips),
    writeln("==============================").

display_tips([]).
display_tips([Tip | Rest]) :-
    format("- ~w~n", [Tip]),
    display_tips(Rest).


% Prevention tips
thrombo_prevention_tip("Maintain a healthy weight and diet.").
thrombo_prevention_tip("Exercise regularly to improve circulation.").
thrombo_prevention_tip("Avoid prolonged periods of immobility.").
thrombo_prevention_tip("Stay hydrated to reduce blood viscosity.").
thrombo_prevention_tip("Avoid smoking, as it increases clot risks.").
thrombo_prevention_tip("Follow prescribed treatments for underlying conditions like hypertension or diabetes.").

% Explain risk factors
thrombo_explain_factors :-
    writeln("=== Explanation of Stroke Risk Factors ==="),
    writeln("Modifiable Factors:"),
    findall(F, thrombo_modifiable_factor(F), ModifiableFactors),
    display_factors(ModifiableFactors),
    writeln("\nNon-Modifiable Factors:"),
    findall(F, thrombo_non_modifiable_factor(F), NonModifiableFactors),
    display_factors(NonModifiableFactors),
    writeln("===========================================").

display_factors([]).
display_factors([Factor | Rest]) :-
    thrombo_factor_weight(Factor, Weight),
    format("- ~w: Weight: ~w~n", [Factor, Weight]),
    display_factors(Rest).

% Collect user data
ask_question(Question, Factor) :-
    format("~w~n", [Question]),
    read(Response),
    (Response == yes -> assert(thrombo_user_data(Factor, yes, 0));
    Response == sometimes -> ask_severity(Factor, Response);
    Response == no -> assert(thrombo_user_data(Factor, no, 0));
    writeln("Invalid response. Try again."), ask_question(Question, Factor)).

ask_severity(Factor, Response) :-
    writeln("On a scale from 1 to 10, how severe is it?"),
    read(Severity),
    (integer(Severity), Severity >= 1, Severity =< 10 ->
        assert(thrombo_user_data(Factor, Response, Severity));
    writeln("Invalid severity. Try again."), ask_severity(Factor, Response)).

% Risk evaluation

thrombo_risk_evaluation_complete(Probability) :-
	% Contributions des réponses 'yes'
findall(Weight,
		(thrombo_user_data(Factor, yes, _),
			thrombo_factor_weight(Factor, Weight)),
		YesWeights),
	sum_list(YesWeights, TotalYes),
	writeln("Debug: Yes Weights"),
	writeln(YesWeights),
	% Contributions des réponses 'sometimes' avec sévérité
	findall(AdjustedWeight,
		(thrombo_user_data(Factor, sometimes, Severity),
			thrombo_factor_weight(Factor, Weight),
			AdjustedWeight is (Weight*Severity)/10),
		SometimesWeights),
	sum_list(SometimesWeights, TotalSometimes),
	writeln("Debug: Sometimes Weights"),
	writeln(SometimesWeights),
	% Calcul brut des contributions
	RawTotal is TotalYes + TotalSometimes,
	writeln("Debug: Raw Total"),
	writeln(RawTotal),
	% Application d'un facteur d'échelle pour ajuster la probabilité
	ScalingFactor is 1.5,
	% Ajustez ce facteur selon les besoins (ex : 1.5, 2.0)
	AdjustedTotal is RawTotal/ScalingFactor,
	% Assurer que la probabilité reste entre 0 et 100
	Probability is min(100,
		max(0, AdjustedTotal)),
	writeln("Debug: Final Probability"),
	writeln(Probability).

% Generate a detailed diagnostic report
thrombo_generate_report(Data, Probability, Advice) :-
    findall((Factor, Response, Severity),
        thrombo_user_data(Factor, Response, Severity),
        Data),
    thrombo_risk_evaluation_complete(Probability),
    thrombo_advise(Probability, Advice).

thrombo_advise(Probability, Advice) :-
    (Probability >= 70 ->
        Advice = "Your risk of thrombo is HIGH. Seek immediate medical attention.";
    Probability >= 40 ->
        Advice = "Your risk of thrombo is MODERATE. Consider lifestyle changes and consult a physician.";
        Advice = "Your risk of thrombo is LOW. Maintain a healthy lifestyle.").

% Start the chatbot
thrombo_start :-
    writeln("Welcome to the Stroke Risk Assessment Chatbot!"),
    writeln("Please select an option:"),
    writeln("1. Evaluate your symptoms and risk factors."),
    writeln("2. Learn about risk factors."),
    writeln("3. Get prevention tips."),
    writeln("4. Quit."),
    read(Choice),
    handle_choice(Choice).

handle_choice(1) :- thrombo_evaluate_risks, thrombo_start.
handle_choice(2) :- thrombo_explain_factors, thrombo_start.
handle_choice(3) :- thrombo_display_prevention_tips, thrombo_start.
handle_choice(4) :- writeln("Thank you for using the Stroke Chatbot. Goodbye!").
handle_choice(_) :- writeln("Invalid choice. Try again."), thrombo_start.

% Evaluate risks
thrombo_evaluate_risks :-
    writeln("Answer the following questions about your symptoms and lifestyle:"),
    collect_data_thrombo_chatbot,
    thrombo_risk_evaluation_complete(Probability),
    thrombo_advise(Probability, Advice),
    format("Your estimated thrombo risk is: ~d%%~n", [Probability]),
    format("Advice: ~w~n", [Advice]).

% Collect user responses for thrombo-related questions
collect_data_thrombo_chatbot :-
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
	ask_question("Have you had a previous thrombo or TIA?", previous_thrombo_tia),
	ask_question("Do you have a family history of thrombo?", family_history),
	ask_question_gender("Are you male?", gender),  % Question spécifique pour gender
	ask_question_age("What is your age?", age),    % Question spécifique pour age
	writeln("Data collection complete.").


% Question spécifique pour le genre
ask_question_gender(Question, Factor) :-
	format("~w (yes/no):~n", [Question]),
	read(Response),
	(Response == yes ->
	assertz(thrombo_user_data(Factor, yes, 0));
	Response == no ->
	assertz(thrombo_user_data(Factor, no, 0));
	writeln("Invalid response. Please answer with 'yes' or 'no'."),
		ask_question_gender(Question, Factor)).

% Question spécifique pour l'âge
ask_question_age(Question, Factor) :-
	format("~w~n", [Question]),
	read(Age),
	(integer(Age),
		Age > 0 ->
	assertz(thrombo_user_data(Factor, Age, 0));
	writeln("Invalid age. Please enter a positive number."),
		ask_question_age(Question, Factor)).