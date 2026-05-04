% Declaration of dynamic predicates
:- dynamic user_symptom/3.
:- dynamic user_data/3.
:- discontiguous evaluate_symptoms/0.
:- discontiguous advise_action/1.
:- discontiguous symptom_probability/2.

% Base facts and weights for symptoms
symptom(chest_pain, 30).
symptom(shortness_of_breath, 25).
symptom(nausea, 15).
symptom(dizziness, 15).
symptom(fatigue, 10).
symptom(pain_in_arms_neck_or_back, 20).
symptom(cold_sweats, 15).

% Interactive dialogue
start :-
	writeln("Welcome to the Symptoms Evaluation Program."),
	writeln("Please answer the following questions to evaluate your symptoms."),
	evaluate_symptoms,
	calculate_probability,
	writeln("Thank you for using the program. Take care!").

% Evaluate symptoms
evaluate_symptoms :-
	ask_symptom("Are you experiencing chest pain? (yes/no/sometimes)", chest_pain),
	ask_symptom("Are you experiencing shortness of breath? (yes/no/sometimes)", shortness_of_breath),
	ask_symptom("Are you experiencing nausea or vomiting? (yes/no/sometimes)", nausea),
	ask_symptom("Are you experiencing dizziness or lightheadedness? (yes/no/sometimes)", dizziness),
	ask_symptom("Are you experiencing fatigue or weakness? (yes/no/sometimes)", fatigue),
	ask_symptom("Are you experiencing pain in the arms, neck, jaw, or back? (yes/no/sometimes)", pain_in_arms_neck_or_back),
	ask_symptom("Are you experiencing cold sweats? (yes/no/sometimes)", cold_sweats).

% Ask about a specific symptom
ask_symptom(Question, Symptom) :-
	format("~w~n", [Question]),
	read(Response),
	(Response == yes ->
	ask_severity(Symptom, Response);
	Response == sometimes ->
	ask_severity(Symptom, Response);
	Response == no ->
	assert(user_symptom(Symptom, no, 0));
	writeln("Invalid response. Please try again."),
		ask_symptom(Question, Symptom)).
ask_severity(Symptom, Response) :-
	writeln("On a scale from 1 to 10, how severe is this symptom?"),
	read(Severity),
	(Severity >= 1,
		Severity =< 10 ->
	assert(user_symptom(Symptom, Response, Severity));
	writeln("Invalid severity level. Please enter a number between 1 and 10."),
		ask_severity(Symptom, Response)).

% Calculate probability of a heart attack
calculate_probability :-
	findall(Weight,
		(user_symptom(Symptom, Response, _),
			symptom_probability(Symptom, Response, Weight)),
		WeightList),
	sum_list(WeightList, TotalWeight),
	writeln("Probability of heart attack:"),
	writeln(TotalWeight),
	advise_action(TotalWeight).

% Probability calculation for symptoms
symptom_probability(Symptom, yes, Weight) :-
	symptom(Symptom, BaseWeight),
	Weight is BaseWeight.
symptom_probability(Symptom, sometimes, Weight) :-
	symptom(Symptom, BaseWeight),
	Weight is BaseWeight*0.5.
symptom_probability(_, no, 0).

% Advice based on probability
advise_action(Probability) :-
	Probability >= 70,
	!,
	writeln("Your symptoms indicate a HIGH probability of a heart attack. Call emergency services immediately and perform first aid if needed.").
advise_action(Probability) :-
	Probability >= 40,
	!,
	writeln("Your symptoms indicate a MODERATE probability of a heart attack. Consult a doctor as soon as possible.").
advise_action(_) :-
	writeln("Your symptoms indicate a LOW probability of a heart attack. Monitor your symptoms and take preventive measures.").

% Clear all user data
clear_data :-
	retractall(user_symptom(_, _, _)),
	retractall(user_data(_, _, _)).

% Utility to sum list elements
sum_list([], 0).
sum_list([H|T], Sum) :-
	sum_list(T, Rest),
	Sum is H + Rest.
