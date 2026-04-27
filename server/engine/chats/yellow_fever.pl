:- module(chatbot_diagnostic_yellow_fever, [
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
% Symptoms of Yellow Fever
% =========================
symptom(sudden_fever).
symptom(headache).
symptom(muscle_back_pain).
symptom(nausea).
symptom(vomiting).
symptom(jaundice).
symptom(bleeding).
symptom(black_vomit).

% =========================
% Risk Factors / Discriminating Features
% =========================
risk_factor(endemic_area_exposure).
risk_factor(returning_fever).
risk_factor(liver_involvement).
risk_factor(hemorrhagic_signs).

% =========================
% Weights
% =========================
diagnostic_factor_weight(sudden_fever, 9).
diagnostic_factor_weight(headache, 7).
diagnostic_factor_weight(muscle_back_pain, 8).
diagnostic_factor_weight(nausea, 7).
diagnostic_factor_weight(vomiting, 7).
diagnostic_factor_weight(jaundice, 10).
diagnostic_factor_weight(bleeding, 10).
diagnostic_factor_weight(black_vomit, 10).

diagnostic_factor_weight(endemic_area_exposure, 10).
diagnostic_factor_weight(returning_fever, 9).
diagnostic_factor_weight(liver_involvement, 9).
diagnostic_factor_weight(hemorrhagic_signs, 10).

% =========================
% Questions
% =========================
collect_data :-
    ask_question("Do you have a sudden onset of fever? (yes/no/sometimes)", sudden_fever),
    ask_question("Do you have headaches? (yes/no/sometimes)", headache),
    ask_question("Do you have muscle or back pain? (yes/no/sometimes)", muscle_back_pain),
    ask_question("Do you feel nausea? (yes/no/sometimes)", nausea),
    ask_question("Are you vomiting? (yes/no/sometimes)", vomiting),
    ask_question("Do you have yellowing of the eyes or skin (jaundice)? (yes/no/sometimes)", jaundice),
    ask_question("Are you experiencing any bleeding (e.g., gums, nose)? (yes/no/sometimes)", bleeding),
    ask_question("Have you vomited dark or black material? (yes/no/sometimes)", black_vomit),

    ask_question("Have you been in or traveled to an endemic area recently? (yes/no)", endemic_area_exposure),
    ask_question("Did your fever return after initially improving? (yes/no/sometimes)", returning_fever),
    ask_question("Have you been told you have liver problems or signs of liver involvement? (yes/no/sometimes)", liver_involvement),
    ask_question("Are there signs of severe bleeding or hemorrhage? (yes/no/sometimes)", hemorrhagic_signs).

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
        Advice = "HIGH risk of yellow fever. Seek immediate medical attention and emergency care.";
     Probability >= 40 ->
        Advice = "MODERATE risk. Urgent medical evaluation is recommended.";
     Advice = "LOW risk. Continue monitoring and ensure preventive measures.").

% =========================
% Prevention Tips
% =========================
prevention_tip("Get vaccinated against yellow fever.").
prevention_tip("Avoid mosquito bites using repellents and nets.").
prevention_tip("Wear protective clothing in endemic areas.").
prevention_tip("Eliminate mosquito breeding sites.").
prevention_tip("Seek medical care early if symptoms develop.").
prevention_tip("Avoid travel to endemic areas without vaccination.").

display_prevention_tips :-
    writeln("=== Yellow Fever Prevention Tips ==="),
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
    writeln("=== Yellow Fever Diagnostic Report ==="),
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
    writeln("=== Yellow Fever Symptoms ==="),
    findall(S, symptom(S), Symptoms),
    writeln(Symptoms),
    writeln("\n=== Risk Factors ==="),
    findall(R, risk_factor(R), Risks),
    writeln(Risks).

% =========================
% Main Menu
% =========================
diagnostic_start :-
    writeln("Welcome to the Yellow Fever Diagnostic Chatbot!"),
    writeln("1. Evaluate symptoms"),
    writeln("2. Learn about yellow fever"),
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