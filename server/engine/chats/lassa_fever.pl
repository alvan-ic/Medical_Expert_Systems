:- module(chatbot_diagnostic_lassa_fever, [
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
% Symptoms of Lassa Fever
% =========================
symptom(fever).
symptom(weakness).
symptom(sore_throat).
symptom(chest_pain).
symptom(vomiting).
symptom(facial_swelling).
symptom(mucosal_bleeding).

% =========================
% Risk Factors / Discriminating Features
% =========================
risk_factor(rodent_exposure).
risk_factor(endemic_area_exposure).
risk_factor(bleeding).
risk_factor(edema).
risk_factor(severe_weakness).
risk_factor(poor_treatment_response).

% =========================
% Weights
% =========================
diagnostic_factor_weight(fever, 9).
diagnostic_factor_weight(weakness, 8).
diagnostic_factor_weight(sore_throat, 7).
diagnostic_factor_weight(chest_pain, 7).
diagnostic_factor_weight(vomiting, 7).
diagnostic_factor_weight(facial_swelling, 9).
diagnostic_factor_weight(mucosal_bleeding, 10).

diagnostic_factor_weight(rodent_exposure, 10).
diagnostic_factor_weight(endemic_area_exposure, 9).
diagnostic_factor_weight(bleeding, 10).
diagnostic_factor_weight(edema, 8).
diagnostic_factor_weight(severe_weakness, 9).
diagnostic_factor_weight(poor_treatment_response, 10).

% =========================
% Questions
% =========================
collect_data :-
    ask_question("Do you have a fever? (yes/no/sometimes)", fever),
    ask_question("Do you feel weak or fatigued? (yes/no/sometimes)", weakness),
    ask_question("Do you have a sore throat? (yes/no/sometimes)", sore_throat),
    ask_question("Do you have chest pain? (yes/no/sometimes)", chest_pain),
    ask_question("Are you vomiting? (yes/no/sometimes)", vomiting),
    ask_question("Do you have swelling of the face? (yes/no/sometimes)", facial_swelling),
    ask_question("Are you experiencing bleeding from the mouth, nose, or other areas? (yes/no/sometimes)", mucosal_bleeding),

    ask_question("Have you been exposed to rodents or their droppings? (yes/no)", rodent_exposure),
    ask_question("Do you live in or recently visited an endemic area? (yes/no)", endemic_area_exposure),
    ask_question("Are you experiencing unusual bleeding? (yes/no/sometimes)", bleeding),
    ask_question("Do you have swelling (edema) in parts of your body? (yes/no/sometimes)", edema),
    ask_question("Is your weakness severe? (yes/no/sometimes)", severe_weakness),
    ask_question("Have you not responded to malaria or antibiotic treatment? (yes/no)", poor_treatment_response).

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
        Advice = "HIGH risk of Lassa fever. Seek immediate medical attention and isolation.";
     Probability >= 40 ->
        Advice = "MODERATE risk. Urgent medical evaluation is strongly recommended.";
     Advice = "LOW risk. Continue monitoring and maintain preventive measures.").

% =========================
% Prevention Tips
% =========================
prevention_tip("Avoid contact with rodents and their droppings.").
prevention_tip("Store food in rodent-proof containers.").
prevention_tip("Maintain clean household environments.").
prevention_tip("Avoid bush burning that may drive rodents indoors.").
prevention_tip("Practice proper hygiene and sanitation.").
prevention_tip("Seek early medical care for symptoms.").

display_prevention_tips :-
    writeln("=== Lassa Fever Prevention Tips ==="),
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
    writeln("=== Lassa Fever Diagnostic Report ==="),
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
    writeln("=== Lassa Fever Symptoms ==="),
    findall(S, symptom(S), Symptoms),
    writeln(Symptoms),
    writeln("\n=== Risk Factors ==="),
    findall(R, risk_factor(R), Risks),
    writeln(Risks).

% =========================
% Main Menu
% =========================
diagnostic_start :-
    writeln("Welcome to the Lassa Fever Diagnostic Chatbot!"),
    writeln("1. Evaluate symptoms"),
    writeln("2. Learn about Lassa fever"),
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