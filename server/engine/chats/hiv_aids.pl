:- module(chatbot_diagnostic_hiv_aids, [
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
% Symptoms of HIV/AIDS
% =========================
symptom(recurrent_fever).
symptom(weight_loss).
symptom(chronic_diarrhea).
symptom(night_sweats).
symptom(persistent_cough).
symptom(oral_thrush).
symptom(swollen_lymph_nodes).
symptom(recurrent_infections).

% =========================
% Risk Factors
% =========================
risk_factor(high_risk_exposure).
risk_factor(opportunistic_infections).
risk_factor(prolonged_illness).
risk_factor(mucocutaneous_candidiasis).

% =========================
% Weights
% =========================
diagnostic_factor_weight(recurrent_fever, 8).
diagnostic_factor_weight(weight_loss, 9).
diagnostic_factor_weight(chronic_diarrhea, 8).
diagnostic_factor_weight(night_sweats, 7).
diagnostic_factor_weight(persistent_cough, 7).
diagnostic_factor_weight(oral_thrush, 9).
diagnostic_factor_weight(swollen_lymph_nodes, 7).
diagnostic_factor_weight(recurrent_infections, 9).

diagnostic_factor_weight(high_risk_exposure, 10).
diagnostic_factor_weight(opportunistic_infections, 10).
diagnostic_factor_weight(prolonged_illness, 8).
diagnostic_factor_weight(mucocutaneous_candidiasis, 9).

% =========================
% Questions
% =========================
collect_data :-
    ask_question("Do you experience recurrent fever? (yes/no/sometimes)", recurrent_fever),
    ask_question("Have you had significant unexplained weight loss? (yes/no/sometimes)", weight_loss),
    ask_question("Do you have chronic diarrhea? (yes/no/sometimes)", chronic_diarrhea),
    ask_question("Do you experience night sweats? (yes/no/sometimes)", night_sweats),
    ask_question("Do you have a persistent cough? (yes/no/sometimes)", persistent_cough),
    ask_question("Do you have oral thrush (white patches in mouth)? (yes/no/sometimes)", oral_thrush),
    ask_question("Do you have swollen lymph nodes? (yes/no/sometimes)", swollen_lymph_nodes),
    ask_question("Do you frequently get infections? (yes/no/sometimes)", recurrent_infections),

    ask_question("Have you had high-risk exposure (e.g., unprotected sex, shared needles)? (yes/no)", high_risk_exposure),
    ask_question("Have you been diagnosed with opportunistic infections? (yes/no/sometimes)", opportunistic_infections),
    ask_question("Have you had prolonged unexplained illness? (yes/no/sometimes)", prolonged_illness),
    ask_question("Do you have persistent fungal infections (mucocutaneous candidiasis)? (yes/no/sometimes)", mucocutaneous_candidiasis).

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
        Advice = "HIGH risk of HIV/AIDS. Seek immediate medical testing and counseling.";
     Probability >= 40 ->
        Advice = "MODERATE risk. It is strongly recommended to get tested for HIV.";
     Advice = "LOW risk. Maintain safe practices and consider routine testing.").

% =========================
% Prevention Tips
% =========================
prevention_tip("Practice safe sex using condoms.").
prevention_tip("Avoid sharing needles or sharp objects.").
prevention_tip("Get regularly tested for HIV.").
prevention_tip("Use pre-exposure prophylaxis (PrEP) if at high risk.").
prevention_tip("Ensure safe blood transfusions.").
prevention_tip("Seek early treatment if diagnosed to prevent progression.").

display_prevention_tips :-
    writeln("=== HIV/AIDS Prevention Tips ==="),
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
    writeln("=== HIV/AIDS Diagnostic Report ==="),
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
    writeln("=== HIV/AIDS Symptoms ==="),
    findall(S, symptom(S), Symptoms),
    writeln(Symptoms),
    writeln("\n=== Risk Factors ==="),
    findall(R, risk_factor(R), Risks),
    writeln(Risks).

% =========================
% Main Menu
% =========================
diagnostic_start :-
    writeln("Welcome to the HIV/AIDS Diagnostic Chatbot!"),
    writeln("1. Evaluate symptoms"),
    writeln("2. Learn about HIV/AIDS"),
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