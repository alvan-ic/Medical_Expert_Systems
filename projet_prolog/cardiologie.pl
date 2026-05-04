% Define age groups
age_group(young, Age) :-
	Age < 30.
age_group(adult, Age) :-
	Age >= 30,
	Age < 60.
age_group(senior, Age) :-
	Age >= 60.

% Define symptoms
symptom(chest_pain).
symptom(palpitations).
symptom(cardiac_arrest).
symptom(blue_tint).
symptom(cold_extremities).
symptom(fatigue_activity).
symptom(nausea_vomiting).
symptom(unexplained_fatigue).

% Rules for predicting heart disease based on symptoms and age group
heart_disease(patient(Age, Gender, Symptoms, RiskFactors), Risk) :-
	age_group(Group, Age),
	evaluate_symptoms(Symptoms, Severity),
	risk_factor(Group, Gender, Severity, RiskFactors, Risk).

% Evaluate symptoms severity
evaluate_symptoms(Symptoms, high) :-
	member(chest_pain, Symptoms),
	member(palpitations, Symptoms).
evaluate_symptoms(Symptoms, medium) :-
	member(cardiac_arrest, Symptoms);
member(blue_tint, Symptoms);
member(cold_extremities, Symptoms).
evaluate_symptoms(Symptoms, low) :-
	member(fatigue_activity, Symptoms);
member(nausea_vomiting, Symptoms);
member(unexplained_fatigue, Symptoms).

% Define risk factors based on age group, gender, and severity
risk_factor(young, female, high, _, high).
risk_factor(young, male, medium, _, medium).
risk_factor(adult, female, medium, _, medium).
risk_factor(adult, male, high, _, high).
risk_factor(senior, _, high, _, high).
