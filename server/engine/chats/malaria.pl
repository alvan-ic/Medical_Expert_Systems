% malaria_chatbox.pl
% Simple Malaria Diagnostic Chatbot

% Knowledge base of malaria symptoms and risk factors
symptom(fever).
symptom(headache).
symptom(chills).
symptom(sweating).
symptom(nausea).
symptom(vomiting).
symptom(muscle_pain).
symptom(fatigue).

risk_factor(mosquito_exposure).
risk_factor(recent_travel_endemic).
risk_factor(no_mosquito_net).

% Rules for malaria assessment
has_malaria :- 
    has_symptom(fever),
    has_symptom(headache),
    has_symptom(chills),
    has_symptom(sweating),
    has_risk_factor(mosquito_exposure),
    format('~n~nHIGH RISK: Based on your symptoms and risk factors, you may have malaria.~n', []),
    format('Please consult a doctor immediately for a blood test.~n', []).

has_malaria :-
    has_symptom(fever),
    has_symptom(chills),
    has_risk_factor(mosquito_exposure),
    format('~n~nMEDIUM RISK: You show some malaria symptoms.~n', []),
    format('Monitor your symptoms and consider seeing a doctor if they worsen.~n', []).

has_malaria :-
    has_symptom(fever),
    has_symptom(headache),
    format('~n~nLOW RISK: Your symptoms are mild.~n', []),
    format('But if fever persists, please consult a doctor.~n', []).

has_malaria :-
    format('~n~nLOW RISK: You don''t show strong signs of malaria.~n', []),
    format('If symptoms develop later, please consult a healthcare provider.~n', []).

% Dynamic predicates to store user responses
:- dynamic user_symptom/1.
:- dynamic user_risk/1.

% string_lower/2 is not a built-in; define it via downcase_atom
string_lower(S, L) :-
    string_to_atom(S, A),
    downcase_atom(A, LA),
    atom_string(LA, L).

% Clear previous responses
clear_responses :-
    retractall(user_symptom(_)),
    retractall(user_risk(_)).

% Ask a yes/no question
ask_question(Prompt, Response) :-
    format('~w (yes/no): ', [Prompt]),
    read_line_to_string(user, Input),
    string_lower(Input, LowerInput),
    (   (LowerInput = "yes" ; LowerInput = "y") ->
        Response = yes
    ;   (LowerInput = "no" ; LowerInput = "n") ->
        Response = no
    ;   format('Please answer yes or no.~n', []),
        ask_question(Prompt, Response)
    ).

% Collect symptoms
collect_symptoms :-
    format('~n=== MALARIA SYMPTOM CHECKER ===~n', []),
    format('Answer the following questions about your symptoms:~n~n', []),
    
    ask_question('Do you have fever?', Fever),
    (Fever = yes -> assertz(user_symptom(fever)) ; true),
    
    ask_question('Do you have headache?', Headache),
    (Headache = yes -> assertz(user_symptom(headache)) ; true),
    
    ask_question('Do you have chills?', Chills),
    (Chills = yes -> assertz(user_symptom(chills)) ; true),
    
    ask_question('Do you have sweating episodes?', Sweating),
    (Sweating = yes -> assertz(user_symptom(sweating)) ; true),
    
    ask_question('Do you feel nauseous?', Nausea),
    (Nausea = yes -> assertz(user_symptom(nausea)) ; true),
    
    ask_question('Have you been vomiting?', Vomiting),
    (Vomiting = yes -> assertz(user_symptom(vomiting)) ; true),
    
    ask_question('Do you have muscle pain?', MusclePain),
    (MusclePain = yes -> assertz(user_symptom(muscle_pain)) ; true),
    
    ask_question('Do you feel unusually tired or fatigued?', Fatigue),
    (Fatigue = yes -> assertz(user_symptom(fatigue)) ; true).

% Collect risk factors
collect_risk_factors :-
    format('~n=== RISK FACTOR ASSESSMENT ===~n', []),
    format('Answer the following questions about exposure:~n~n', []),
    
    ask_question('Have you been exposed to mosquitoes recently?', Mosquito),
    (Mosquito = yes -> assertz(user_risk(mosquito_exposure)) ; true),
    
    ask_question('Have you traveled to a malaria-endemic area recently?', Travel),
    (Travel = yes -> assertz(user_risk(recent_travel_endemic)) ; true),
    
    ask_question('Do you sleep under a mosquito net?', Net),
    (Net = no -> assertz(user_risk(no_mosquito_net)) ; true).

% Helper predicates to check facts
has_symptom(Symptom) :-
    user_symptom(Symptom).

has_risk_factor(Risk) :-
    user_risk(Risk).

% Show recommendations
show_recommendations :-
    format('~n=== RECOMMENDATIONS ===~n', []),
    (has_symptom(fever) ->
        format('✓ Drink plenty of fluids to stay hydrated~n', []),
        format('✓ Rest and avoid strenuous activities~n', [])
    ; true),
    (has_symptom(chills) ->
        format('✓ Use blankets to keep warm during chills~n', [])
    ; true),
    (has_risk_factor(no_mosquito_net) ->
        format('✓ Use mosquito nets while sleeping~n', []),
        format('✓ Apply mosquito repellent~n', [])
    ; true),
    format('✓ Seek medical attention if symptoms persist for more than 24 hours~n', []),
    format('✓ Complete a blood test for accurate malaria diagnosis~n', []).

% Main chat interface
chat :-
    clear_responses,
    format('~n~n========================================~n', []),
    format('    MALARIA SYMPTOM CHECKER CHATBOT~n', []),
    format('========================================~n', []),
    format('This chatbot helps assess malaria risk based on symptoms.~n', []),
    format('NOTE: This is NOT a medical diagnosis. Always consult a doctor.~n~n', []),
    
    collect_symptoms,
    collect_risk_factors,
    
    format('~n=== ASSESSMENT RESULT ===~n', []),
    has_malaria,
    
    show_recommendations,
    
    format('~n~nWould you like to start over? (yes/no): ', []),
    read_line_to_string(user, Restart),
    string_lower(Restart, LowerRestart),
    (   (LowerRestart = "yes" ; LowerRestart = "y")
    ->  chat
    ;   format('~nThank you for using Malaria Symptom Checker. Stay healthy!~n', []),
        format('For emergencies, please call your local health service.~n', [])
    ).

% Quick assessment without full chat
quick_check :-
    clear_responses,
    format('~nQuick Malaria Check:~n', []),
    ask_question('Do you have fever?', Fever),
    (Fever = yes -> assertz(user_symptom(fever)) ; true),
    ask_question('Do you have chills?', Chills),
    (Chills = yes -> assertz(user_symptom(chills)) ; true),
    ask_question('Have you been exposed to mosquitoes?', Mosquito),
    (Mosquito = yes -> assertz(user_risk(mosquito_exposure)) ; true),
    
    (has_symptom(fever), has_symptom(chills), has_risk_factor(mosquito_exposure) ->
        format('~nALERT: High risk of malaria! Please see a doctor immediately.~n', [])
    ; has_symptom(fever), has_symptom(chills) ->
        format('~nWarning: You have common malaria symptoms. Monitor closely.~n', [])
    ; has_symptom(fever) ->
        format('~nYou have fever, which could be malaria or other illness.~n', [])
    ; format('~nYou show no major symptoms, but remain vigilant.~n', [])
    ).

% To start the chat, simply type: chat.
% For quick check, type: quick_check.