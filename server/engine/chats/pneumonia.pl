:- module(chatbot_diagnostic_pneumonia, [
    risk_factor/1,
    symptom/1,
    diagnostic_start/0,
    diagnostic_risk_evaluation_complete/1,
    prevention_tip/1,
    diagnostic_explain_factors/0,
    diagnostic_generate_report/0,
    diagnostic_factor_weight/2,
    advise/2,
    display_prevention_tips/0,
    user_data/3,
    display_data/1
]).

:- dynamic user_data/3.

% =========================
% Symptoms of Pneumonia
% =========================
symptom(cough).
symptom(fever).
symptom(breathlessness).
symptom(chest_pain).
symptom(fast_breathing).
symptom(sputum_production).
symptom(reduced_oxygen_saturation).

% =========================
% Risk Factors / Discriminating Features
% =========================
risk_factor(crackles_on_exam).
risk_factor(pleuritic_pain).
risk_factor(tachypnea).
risk_factor(focal_chest_signs).

% =========================
% Weights
% =========================
diagnostic_factor_weight(cough, 8).
diagnostic_factor_weight(fever, 8).
diagnostic_factor_weight(breathlessness, 10).
diagnostic_factor_weight(chest_pain, 7).
diagnostic_factor_weight(fast_breathing, 9).
diagnostic_factor_weight(sputum_production, 7).
diagnostic_factor_weight(reduced_oxygen_saturation, 10).

diagnostic_factor_weight(crackles_on_exam, 9).
diagnostic_factor_weight(pleuritic_pain, 8).
diagnostic_factor_weight(tachypnea, 9).
diagnostic_factor_weight(focal_chest_signs, 9).

% =========================
% Questions
% =========================
collect_data :-
    ask_question("Do you have a cough? (yes/no/sometimes)", cough),
    ask_question("Do you have a fever? (yes/no/sometimes)", fever),
    ask_question("Do you feel shortness of breath (breathlessness)? (yes/no/sometimes)", breathlessness),
    ask_question("Do you have chest pain that worsens when breathing? (yes/no/sometimes)", chest_pain),
    ask_question("Are you breathing faster than normal? (yes/no/sometimes)", fast_breathing),
    ask_question("Are you producing sputum (phlegm)? (yes/no/sometimes)", sputum_production),
    ask_question("Have you been told you have low oxygen levels? (yes/no/sometimes)", reduced_oxygen_saturation),

    ask_question("Have you been told there are crackling sounds in your chest during examination? (yes/no)", crackles_on_exam),
    ask_question("Do you experience sharp chest pain when breathing deeply (pleuritic pain)? (yes/no/sometimes)", pleuritic_pain),
    ask_question("Do you have very rapid breathing (tachypnea)? (yes/no/sometimes)", tachypnea),
    ask_question("Have you been diagnosed with localized chest findings (focal chest signs)? (yes/no)", focal_chest_signs).

% =========================
% Input Handling
% =========================
ask_question(Question, Factor) :-
    format("~w~n", [Question]),
    read(Response),
    (Response == yes ->
        assert(user_data(Factor, yes, 0));
     Response == sometimes ->
        ask_severity(Factor);
     Response == no ->
        assert(user_data(Factor, no, 0));
     writeln("Invalid response. Try again."),
        ask_question(Question, Factor)).

ask_severity(Factor) :-
    writeln("On a scale from 1 to 10, how severe is it?"),
    read(Severity),
    (integer(Severity), Severity >= 1, Severity =< 10 ->
        assert(user_data(Factor, sometimes, Severity));
     writeln("Invalid severity. Try again."),
        ask_severity(Factor)).

% =========================
% Risk Calculation
% =========================
diagnostic_risk_evaluation_complete(Probability) :-
    findall(W,
        (user_data(F, yes, _), diagnostic_factor_weight(F, Weight), W is Weight),
        YesWeights),
    sum_list(YesWeights, TotalYes),

    findall(W,
        (user_data(F, sometimes, S),
         diagnostic_factor_weight(F, Weight),
         W is (Weight*S)/10),
        SometimesWeights),
    sum_list(SometimesWeights, TotalSometimes),

    Raw is TotalYes + TotalSometimes,

    findall(W, diagnostic_factor_weight(_, W), AllWeights),
    sum_list(AllWeights, Max),

    (Max > 0 ->
        Prob is (Raw/Max)*100;
        Prob is 0),

    Probability is min(Prob, 100).

% =========================
% Advice
% =========================
advise(Probability, Advice) :-
    (Probability >= 70 ->
        Advice = "HIGH risk of pneumonia. Seek immediate medical attention, especially for children or elderly individuals.";
     Probability >= 40 ->
        Advice = "MODERATE risk. Consult a healthcare provider for proper evaluation and possible treatment.";
     Advice = "LOW risk. Monitor symptoms and maintain preventive measures.").

% =========================
% Prevention Tips
% =========================
prevention_tip("Get vaccinated against pneumonia and influenza.").
prevention_tip("Maintain good hygiene (handwashing, respiratory etiquette).").
prevention_tip("Avoid exposure to smoke and air pollution.").
prevention_tip("Ensure proper nutrition and hydration.").
prevention_tip("Seek early treatment for respiratory infections.").
prevention_tip("Protect vulnerable groups such as children and the elderly.").

display_prevention_tips :-
    writeln("=== Pneumonia Prevention Tips ==="),
    findall(Tip, prevention_tip(Tip), Tips),
    display_tips(Tips).

display_tips([]).
display_tips([H|T]) :-
    format("- ~w~n", [H]),
    display_tips(T).

% =========================
% Report
% =========================
diagnostic_generate_report :-
    writeln("=== Pneumonia Diagnostic Report ==="),
    findall((F,R,S), user_data(F,R,S), Data),
    display_data(Data),
    diagnostic_risk_evaluation_complete(P),
    advise(P, A),
    format("Estimated Risk: ~2f%%~n", [P]),
    format("Advice: ~w~n", [A]).

display_data([]).
display_data([(F,R,S)|T]) :-
    format("- ~w: ~w (Severity: ~w)~n", [F,R,S]),
    display_data(T).

% =========================
% Explanation
% =========================
diagnostic_explain_factors :-
    writeln("=== Pneumonia Symptoms ==="),
    findall(S, symptom(S), Symptoms),
    writeln(Symptoms),
    writeln("\n=== Risk Factors ==="),
    findall(R, risk_factor(R), Risks),
    writeln(Risks).

% =========================
% Main Menu
% =========================
diagnostic_start :-
    writeln("Welcome to the Pneumonia Diagnostic Chatbot!"),
    writeln("1. Evaluate symptoms"),
    writeln("2. Learn about pneumonia"),
    writeln("3. Prevention tips"),
    writeln("4. Generate report"),
    writeln("5. Quit"),
    read(C),
    handle_choice(C).

handle_choice(1) :- collect_data, diagnostic_generate_report.
handle_choice(2) :- diagnostic_explain_factors.
handle_choice(3) :- display_prevention_tips.
handle_choice(4) :- diagnostic_generate_report.
handle_choice(5) :- writeln("Goodbye!").
handle_choice(_) :- writeln("Invalid choice"), diagnostic_start.