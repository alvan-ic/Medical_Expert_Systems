:- module(chatbot_diagnostic_cholera, [
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
% Symptoms of Cholera
% =========================
symptom(watery_diarrhea).
symptom(vomiting).
symptom(severe_dehydration).
symptom(muscle_cramps).
symptom(sunken_eyes).

% =========================
% Risk Factors / Discriminating Features
% =========================
risk_factor(unsafe_water_exposure).
risk_factor(outbreak_exposure).
risk_factor(rice_water_stool).
risk_factor(rapid_dehydration).

% =========================
% Weights
% =========================
diagnostic_factor_weight(watery_diarrhea, 10).
diagnostic_factor_weight(vomiting, 8).
diagnostic_factor_weight(severe_dehydration, 10).
diagnostic_factor_weight(muscle_cramps, 7).
diagnostic_factor_weight(sunken_eyes, 8).

diagnostic_factor_weight(unsafe_water_exposure, 9).
diagnostic_factor_weight(outbreak_exposure, 9).
diagnostic_factor_weight(rice_water_stool, 10).
diagnostic_factor_weight(rapid_dehydration, 10).

% =========================
% Questions
% =========================
collect_data :-
    ask_question("Do you have sudden watery diarrhea? (yes/no/sometimes)", watery_diarrhea),
    ask_question("Are you vomiting? (yes/no/sometimes)", vomiting),
    ask_question("Are you experiencing signs of severe dehydration (e.g., extreme thirst, dry mouth)? (yes/no/sometimes)", severe_dehydration),
    ask_question("Do you have muscle cramps? (yes/no/sometimes)", muscle_cramps),
    ask_question("Do you have sunken eyes? (yes/no/sometimes)", sunken_eyes),

    ask_question("Have you recently consumed unsafe or contaminated water? (yes/no)", unsafe_water_exposure),
    ask_question("Are you in or recently exposed to a cholera outbreak area? (yes/no)", outbreak_exposure),
    ask_question("Is your stool pale and watery like 'rice-water'? (yes/no/sometimes)", rice_water_stool),
    ask_question("Did dehydration occur very rapidly? (yes/no/sometimes)", rapid_dehydration).

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
        Advice = "HIGH risk of cholera. Seek immediate medical attention and start oral rehydration therapy urgently.";
     Probability >= 40 ->
        Advice = "MODERATE risk. Begin rehydration and consult a healthcare provider as soon as possible.";
     Advice = "LOW risk. Maintain hydration and monitor symptoms closely.").

% =========================
% Prevention Tips
% =========================
prevention_tip("Drink only safe and treated water.").
prevention_tip("Wash hands regularly with soap and clean water.").
prevention_tip("Avoid eating raw or undercooked food.").
prevention_tip("Use proper sanitation and toilet facilities.").
prevention_tip("Boil or treat water before drinking.").
prevention_tip("Maintain good food hygiene practices.").

display_prevention_tips :-
    writeln("=== Cholera Prevention Tips ==="),
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
    writeln("=== Cholera Diagnostic Report ==="),
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
    writeln("=== Cholera Symptoms ==="),
    findall(S, symptom(S), Symptoms),
    writeln(Symptoms),
    writeln("\n=== Risk Factors ==="),
    findall(R, risk_factor(R), Risks),
    writeln(Risks).

% =========================
% Main Menu
% =========================
diagnostic_start :-
    writeln("Welcome to the Cholera Diagnostic Chatbot!"),
    writeln("1. Evaluate symptoms"),
    writeln("2. Learn about cholera"),
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