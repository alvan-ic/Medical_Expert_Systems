:- module(chatbot_diagnostic_neonatal_sepsis, [
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
% Symptoms of Neonatal Sepsis
% =========================
symptom(poor_feeding).
symptom(lethargy).
symptom(fever).
symptom(hypothermia).
symptom(fast_breathing).
symptom(grunting).
symptom(irritability).
symptom(jaundice).
symptom(seizures).
symptom(poor_cry).

% =========================
% Risk Factors
% =========================
risk_factor(respiratory_distress).
risk_factor(temperature_instability).
risk_factor(abdominal_distension).
risk_factor(apnea).
risk_factor(hypotonia).
risk_factor(maternal_infection_history).

% =========================
% Weights
% =========================
diagnostic_factor_weight(poor_feeding, 8).
diagnostic_factor_weight(lethargy, 9).
diagnostic_factor_weight(fever, 8).
diagnostic_factor_weight(hypothermia, 9).
diagnostic_factor_weight(fast_breathing, 8).
diagnostic_factor_weight(grunting, 7).
diagnostic_factor_weight(irritability, 6).
diagnostic_factor_weight(jaundice, 7).
diagnostic_factor_weight(seizures, 10).
diagnostic_factor_weight(poor_cry, 7).

diagnostic_factor_weight(respiratory_distress, 9).
diagnostic_factor_weight(temperature_instability, 8).
diagnostic_factor_weight(abdominal_distension, 7).
diagnostic_factor_weight(apnea, 10).
diagnostic_factor_weight(hypotonia, 8).
diagnostic_factor_weight(maternal_infection_history, 9).

% =========================
% Questions
% =========================
collect_data :-
    ask_question("Is the baby feeding poorly? (yes/no/sometimes)", poor_feeding),
    ask_question("Is the baby unusually sleepy or lethargic? (yes/no/sometimes)", lethargy),
    ask_question("Does the baby have a fever? (yes/no/sometimes)", fever),
    ask_question("Does the baby feel unusually cold (hypothermia)? (yes/no/sometimes)", hypothermia),
    ask_question("Is the baby breathing rapidly? (yes/no/sometimes)", fast_breathing),
    ask_question("Does the baby make grunting sounds while breathing? (yes/no/sometimes)", grunting),
    ask_question("Is the baby unusually irritable? (yes/no/sometimes)", irritability),
    ask_question("Does the baby have yellowing of the skin or eyes (jaundice)? (yes/no/sometimes)", jaundice),
    ask_question("Has the baby had seizures? (yes/no/sometimes)", seizures),
    ask_question("Is the baby's cry weak or abnormal? (yes/no/sometimes)", poor_cry),

    ask_question("Does the baby show signs of respiratory distress? (yes/no/sometimes)", respiratory_distress),
    ask_question("Does the baby have unstable body temperature? (yes/no/sometimes)", temperature_instability),
    ask_question("Is the baby's abdomen swollen (abdominal distension)? (yes/no/sometimes)", abdominal_distension),
    ask_question("Does the baby stop breathing temporarily (apnea)? (yes/no/sometimes)", apnea),
    ask_question("Does the baby have low muscle tone (hypotonia)? (yes/no/sometimes)", hypotonia),
    ask_question("Was there any maternal infection during pregnancy or delivery? (yes/no)", maternal_infection_history).

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
        Advice = "HIGH risk of neonatal sepsis. Seek immediate medical attention for the baby.";
     Probability >= 40 ->
        Advice = "MODERATE risk. Urgent medical evaluation is recommended.";
     Advice = "LOW risk, but continue close monitoring and consult a healthcare provider if symptoms persist.").

% =========================
% Prevention Tips
% =========================
prevention_tip("Ensure clean delivery practices and sterile environment.").
prevention_tip("Maintain proper hygiene when handling newborns.").
prevention_tip("Breastfeed the baby to boost immunity.").
prevention_tip("Seek prompt treatment for maternal infections during pregnancy.").
prevention_tip("Ensure proper cord care to prevent infection.").
prevention_tip("Avoid exposing newborns to sick individuals.").

display_prevention_tips :-
    writeln("=== Neonatal Sepsis Prevention Tips ==="),
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
    writeln("=== Neonatal Sepsis Diagnostic Report ==="),
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
    writeln("=== Neonatal Sepsis Symptoms ==="),
    findall(S, symptom(S), Symptoms),
    writeln(Symptoms),
    writeln("\n=== Risk Factors ==="),
    findall(R, risk_factor(R), Risks),
    writeln(Risks).

% =========================
% Main Menu
% =========================
diagnostic_start :-
    writeln("Welcome to the Neonatal Sepsis Diagnostic Chatbot!"),
    writeln("1. Evaluate symptoms"),
    writeln("2. Learn about neonatal sepsis"),
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