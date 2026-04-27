:- module(chatbot_diagnostic_uti, [
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
% Symptoms of UTI
% =========================
symptom(dysuria).
symptom(urgency).
symptom(frequency).
symptom(suprapubic_pain).
symptom(cloudy_urine).
symptom(foul_smelling_urine).
symptom(flank_pain).

% =========================
% Risk Factors / Discriminating Features
% =========================
risk_factor(fever).
risk_factor(pyelo_flank_pain).
risk_factor(recurrent_uti_history).
risk_factor(prostate_issues).

% =========================
% Weights
% =========================
diagnostic_factor_weight(dysuria, 10).
diagnostic_factor_weight(urgency, 9).
diagnostic_factor_weight(frequency, 9).
diagnostic_factor_weight(suprapubic_pain, 8).
diagnostic_factor_weight(cloudy_urine, 7).
diagnostic_factor_weight(foul_smelling_urine, 7).
diagnostic_factor_weight(flank_pain, 9).

diagnostic_factor_weight(fever, 8).
diagnostic_factor_weight(pyelo_flank_pain, 10).
diagnostic_factor_weight(recurrent_uti_history, 7).
diagnostic_factor_weight(prostate_issues, 7).

% =========================
% Questions
% =========================
collect_data :-
    ask_question("Do you feel pain or burning when urinating (dysuria)? (yes/no/sometimes)", dysuria),
    ask_question("Do you feel a strong urge to urinate frequently? (yes/no/sometimes)", urgency),
    ask_question("Are you urinating more often than usual? (yes/no/sometimes)", frequency),
    ask_question("Do you have pain in the lower abdomen (suprapubic pain)? (yes/no/sometimes)", suprapubic_pain),
    ask_question("Is your urine cloudy? (yes/no/sometimes)", cloudy_urine),
    ask_question("Does your urine have a foul smell? (yes/no/sometimes)", foul_smelling_urine),
    ask_question("Do you have pain in your sides or back (flank pain)? (yes/no/sometimes)", flank_pain),

    ask_question("Do you have a fever? (yes/no/sometimes)", fever),
    ask_question("Is the flank pain severe (possible kidney infection)? (yes/no/sometimes)", pyelo_flank_pain),
    ask_question("Do you have a history of recurrent UTIs? (yes/no)", recurrent_uti_history),
    ask_question("Do you have known prostate issues? (yes/no)", prostate_issues).

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
        Advice = "HIGH risk of UTI. Seek medical attention promptly; antibiotics may be required.";
     Probability >= 40 ->
        Advice = "MODERATE risk. Consult a healthcare provider for evaluation and urine testing.";
     Advice = "LOW risk. Increase fluid intake and monitor symptoms.").

% =========================
% Prevention Tips
% =========================
prevention_tip("Drink plenty of water to flush bacteria.").
prevention_tip("Maintain proper personal hygiene.").
prevention_tip("Urinate after sexual activity.").
prevention_tip("Avoid holding urine for long periods.").
prevention_tip("Wipe front to back to prevent bacterial spread.").
prevention_tip("Seek early treatment if symptoms develop.").

display_prevention_tips :-
    writeln("=== UTI Prevention Tips ==="),
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
    writeln("=== UTI Diagnostic Report ==="),
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
    writeln("=== UTI Symptoms ==="),
    findall(S, symptom(S), Symptoms),
    writeln(Symptoms),
    writeln("\n=== Risk Factors ==="),
    findall(R, risk_factor(R), Risks),
    writeln(Risks).

% =========================
% Main Menu
% =========================
diagnostic_start :-
    writeln("Welcome to the UTI Diagnostic Chatbot!"),
    writeln("1. Evaluate symptoms"),
    writeln("2. Learn about UTI"),
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