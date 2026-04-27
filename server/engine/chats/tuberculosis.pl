:- module(chatbot_diagnostic_tuberculosis, [
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
% Symptoms of Tuberculosis
% =========================
symptom(chronic_cough).
symptom(weight_loss).
symptom(fever).
symptom(night_sweats).
symptom(chest_pain).
symptom(hemoptysis).
symptom(fatigue).

% =========================
% Risk Factors / Discriminating Features
% =========================
risk_factor(hiv_exposure).
risk_factor(close_tb_contact).
risk_factor(reduced_appetite).
risk_factor(cervical_lymph_node_swelling).
risk_factor(persistent_low_grade_fever).

% =========================
% Weights
% =========================
diagnostic_factor_weight(chronic_cough, 10).
diagnostic_factor_weight(weight_loss, 8).
diagnostic_factor_weight(fever, 7).
diagnostic_factor_weight(night_sweats, 8).
diagnostic_factor_weight(chest_pain, 7).
diagnostic_factor_weight(hemoptysis, 10).
diagnostic_factor_weight(fatigue, 6).

diagnostic_factor_weight(hiv_exposure, 9).
diagnostic_factor_weight(close_tb_contact, 10).
diagnostic_factor_weight(reduced_appetite, 7).
diagnostic_factor_weight(cervical_lymph_node_swelling, 8).
diagnostic_factor_weight(persistent_low_grade_fever, 8).

% =========================
% Questions
% =========================
collect_data :-
    ask_question("Have you had a cough lasting more than 2 weeks? (yes/no/sometimes)", chronic_cough),
    ask_question("Have you experienced unexplained weight loss? (yes/no/sometimes)", weight_loss),
    ask_question("Do you have a fever? (yes/no/sometimes)", fever),
    ask_question("Do you experience night sweats? (yes/no/sometimes)", night_sweats),
    ask_question("Do you have chest pain? (yes/no/sometimes)", chest_pain),
    ask_question("Have you coughed up blood (hemoptysis)? (yes/no/sometimes)", hemoptysis),
    ask_question("Do you feel persistent fatigue? (yes/no/sometimes)", fatigue),

    ask_question("Have you been exposed to someone with HIV? (yes/no)", hiv_exposure),
    ask_question("Have you had close contact with a TB patient? (yes/no)", close_tb_contact),
    ask_question("Do you have reduced appetite? (yes/no/sometimes)", reduced_appetite),
    ask_question("Do you have swollen lymph nodes in the neck? (yes/no/sometimes)", cervical_lymph_node_swelling),
    ask_question("Do you have a persistent low-grade fever? (yes/no/sometimes)", persistent_low_grade_fever).

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
        Advice = "HIGH risk of Tuberculosis. Seek immediate medical testing (e.g., sputum test, chest X-ray).";
     Probability >= 40 ->
        Advice = "MODERATE risk. Visit a healthcare provider for evaluation and possible TB screening.";
     Advice = "LOW risk. Maintain good health practices but monitor symptoms closely.").

% =========================
% Prevention Tips
% =========================
prevention_tip("Ensure good ventilation in living spaces.").
prevention_tip("Avoid close contact with individuals known to have active TB.").
prevention_tip("Cover mouth when coughing or sneezing.").
prevention_tip("Get tested if you are at risk or exposed.").
prevention_tip("Complete full TB treatment if diagnosed.").
prevention_tip("Boost immunity through proper nutrition and healthcare.").

display_prevention_tips :-
    writeln("=== Tuberculosis Prevention Tips ==="),
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
    writeln("=== Tuberculosis Diagnostic Report ==="),
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
    writeln("=== Tuberculosis Symptoms ==="),
    findall(S, symptom(S), Symptoms),
    writeln(Symptoms),
    writeln("\n=== Risk Factors ==="),
    findall(R, risk_factor(R), Risks),
    writeln(Risks).

% =========================
% Main Menu
% =========================
diagnostic_start :-
    writeln("Welcome to the Tuberculosis Diagnostic Chatbot!"),
    writeln("1. Evaluate symptoms"),
    writeln("2. Learn about tuberculosis"),
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