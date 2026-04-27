:- module(chatbot_diagnostic_measles, [
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
% Symptoms of Measles
% =========================
symptom(high_fever).
symptom(cough).
symptom(runny_nose).
symptom(red_watery_eyes).
symptom(koplik_spots).
symptom(spreading_rash).

% =========================
% Risk Factors / Discriminating Features
% =========================
risk_factor(unvaccinated).
risk_factor(rash_face_to_body).
risk_factor(intense_systemic_symptoms).

% =========================
% Weights
% =========================
diagnostic_factor_weight(high_fever, 10).
diagnostic_factor_weight(cough, 7).
diagnostic_factor_weight(runny_nose, 7).
diagnostic_factor_weight(red_watery_eyes, 8).
diagnostic_factor_weight(koplik_spots, 10).
diagnostic_factor_weight(spreading_rash, 10).

diagnostic_factor_weight(unvaccinated, 9).
diagnostic_factor_weight(rash_face_to_body, 10).
diagnostic_factor_weight(intense_systemic_symptoms, 8).

% =========================
% Questions
% =========================
collect_data :-
    ask_question("Do you have a high fever? (yes/no/sometimes)", high_fever),
    ask_question("Do you have a cough? (yes/no/sometimes)", cough),
    ask_question("Do you have a runny nose? (yes/no/sometimes)", runny_nose),
    ask_question("Do you have red or watery eyes? (yes/no/sometimes)", red_watery_eyes),
    ask_question("Do you have small white spots inside the mouth (Koplik spots)? (yes/no/sometimes)", koplik_spots),
    ask_question("Do you have a rash spreading across the body? (yes/no/sometimes)", spreading_rash),

    ask_question("Is the child unvaccinated for measles? (yes/no)", unvaccinated),
    ask_question("Did the rash start on the face and spread downward? (yes/no/sometimes)", rash_face_to_body),
    ask_question("Are the symptoms severe and affecting the whole body? (yes/no/sometimes)", intense_systemic_symptoms).

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
        Advice = "HIGH risk of measles. Seek immediate medical attention and isolate to prevent spread.";
     Probability >= 40 ->
        Advice = "MODERATE risk. Consult a healthcare provider and monitor closely.";
     Advice = "LOW risk. Continue monitoring and ensure vaccination status is up to date.").

% =========================
% Prevention Tips
% =========================
prevention_tip("Ensure children receive measles vaccination (MMR vaccine).").
prevention_tip("Avoid close contact with infected individuals.").
prevention_tip("Maintain good hygiene practices.").
prevention_tip("Isolate infected individuals to prevent spread.").
prevention_tip("Boost immunity through proper nutrition.").
prevention_tip("Seek early medical care if symptoms appear.").

display_prevention_tips :-
    writeln("=== Measles Prevention Tips ==="),
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
    writeln("=== Measles Diagnostic Report ==="),
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
    writeln("=== Measles Symptoms ==="),
    findall(S, symptom(S), Symptoms),
    writeln(Symptoms),
    writeln("\n=== Risk Factors ==="),
    findall(R, risk_factor(R), Risks),
    writeln(Risks).

% =========================
% Main Menu
% =========================
diagnostic_start :-
    writeln("Welcome to the Measles Diagnostic Chatbot!"),
    writeln("1. Evaluate symptoms"),
    writeln("2. Learn about measles"),
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