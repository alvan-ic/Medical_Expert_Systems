:- module(chatbot_diagnostic_typhoid, [
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
% Symptoms of Typhoid Fever
% =========================
symptom(prolonged_fever).
symptom(abdominal_pain).
symptom(headache).
symptom(constipation).
symptom(diarrhea).
symptom(weakness).
symptom(reduced_appetite).

% =========================
% Risk Factors / Discriminating Features
% =========================
risk_factor(unsafe_food_water).
risk_factor(relative_bradycardia).
risk_factor(rose_spots).
risk_factor(abdominal_tenderness).
risk_factor(stepwise_fever).

% =========================
% Weights
% =========================
diagnostic_factor_weight(prolonged_fever, 10).
diagnostic_factor_weight(abdominal_pain, 8).
diagnostic_factor_weight(headache, 7).
diagnostic_factor_weight(constipation, 6).
diagnostic_factor_weight(diarrhea, 6).
diagnostic_factor_weight(weakness, 7).
diagnostic_factor_weight(reduced_appetite, 7).

diagnostic_factor_weight(unsafe_food_water, 9).
diagnostic_factor_weight(relative_bradycardia, 9).
diagnostic_factor_weight(rose_spots, 10).
diagnostic_factor_weight(abdominal_tenderness, 8).
diagnostic_factor_weight(stepwise_fever, 9).

% =========================
% Questions
% =========================
collect_data :-
    ask_question("Do you have a prolonged fever lasting several days? (yes/no/sometimes)", prolonged_fever),
    ask_question("Do you have abdominal pain? (yes/no/sometimes)", abdominal_pain),
    ask_question("Do you have headaches? (yes/no/sometimes)", headache),
    ask_question("Are you experiencing constipation? (yes/no/sometimes)", constipation),
    ask_question("Are you experiencing diarrhea? (yes/no/sometimes)", diarrhea),
    ask_question("Do you feel weak or fatigued? (yes/no/sometimes)", weakness),
    ask_question("Have you noticed a reduced appetite? (yes/no/sometimes)", reduced_appetite),

    ask_question("Have you consumed unsafe food or water recently? (yes/no)", unsafe_food_water),
    ask_question("Have you been told your heart rate is unusually slow relative to fever (relative bradycardia)? (yes/no)", relative_bradycardia),
    ask_question("Do you have faint pink spots on your skin (rose spots)? (yes/no/sometimes)", rose_spots),
    ask_question("Do you feel tenderness in your abdomen? (yes/no/sometimes)", abdominal_tenderness),
    ask_question("Does your fever increase gradually in a stepwise pattern? (yes/no/sometimes)", stepwise_fever).

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
        Advice = "HIGH risk of typhoid fever. Seek immediate medical testing and antibiotic treatment.";
     Probability >= 40 ->
        Advice = "MODERATE risk. Visit a healthcare provider for proper evaluation and testing.";
     Advice = "LOW risk. Maintain hygiene and monitor symptoms closely.").

% =========================
% Prevention Tips
% =========================
prevention_tip("Drink clean and treated water.").
prevention_tip("Practice proper hand hygiene.").
prevention_tip("Avoid eating unsafe or street food.").
prevention_tip("Ensure proper sanitation and waste disposal.").
prevention_tip("Get vaccinated against typhoid where available.").
prevention_tip("Cook food thoroughly before consumption.").

display_prevention_tips :-
    writeln("=== Typhoid Fever Prevention Tips ==="),
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
    writeln("=== Typhoid Fever Diagnostic Report ==="),
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
    writeln("=== Typhoid Fever Symptoms ==="),
    findall(S, symptom(S), Symptoms),
    writeln(Symptoms),
    writeln("\n=== Risk Factors ==="),
    findall(R, risk_factor(R), Risks),
    writeln(Risks).

% =========================
% Main Menu
% =========================
diagnostic_start :-
    writeln("Welcome to the Typhoid Fever Diagnostic Chatbot!"),
    writeln("1. Evaluate symptoms"),
    writeln("2. Learn about typhoid fever"),
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