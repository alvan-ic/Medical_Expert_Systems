% Declaration of dynamic predicates
:- dynamic user_data/3.
:- dynamic period_data/3.
:- discontiguous weight/2.
:- discontiguous ask_age/2.
:- discontiguous calculate_probability/0.
:- discontiguous ask_period/2.
:- discontiguous display_data/1.
:- discontiguous adjust_for_period/3.


% Base facts and weights for risk factors
weight(smoking, 20).
weight(hypertension, 15).
weight(high_cholesterol, 15).
weight(diabetes, 15).
weight(obesity, 10).
weight(sedentary_lifestyle, 10).
weight(unhealthy_diet, 10).
weight(alcohol, 10).
weight(stress, 10).
weight(age, 20).
weight(family_history, 20).
weight(sex, 5).
weight(menopause, 10).
weight(birth_control, 5).


% Risk factor weight
risk_factor(Factor, Weight) :-
	weight(Factor, Weight).

% Adjust weight or severity for a factor based on the period and duration
adjust_for_period(Factor, OriginalValue, AdjustedValue) :-
	(period_data(Factor, Period, Duration),
		Period \== none ->
	DurationFactor = (Duration == short - term ->
	0.8;
	Duration == medium - term ->
	1;
	Duration == long - term ->
	1.2),
		AdjustedValue is OriginalValue*DurationFactor;
	AdjustedValue is OriginalValue).

% Prevention tips facts
prevention_tip("Maintain a healthy diet, low in saturated fats, cholesterol, and added sugars.").
prevention_tip("Engage in regular physical activity, at least 30 minutes per day, 5 days a week.").
prevention_tip("Avoid smoking and exposure to secondhand smoke.").
prevention_tip("Maintain a healthy weight to reduce strain on your heart.").
prevention_tip("Manage stress through relaxation techniques like meditation or yoga.").
prevention_tip("Limit alcohol consumption to moderate levels.").
prevention_tip("Monitor and control blood pressure and cholesterol levels.").
prevention_tip("If you have diabetes, keep it under control with proper management.").
prevention_tip("Get regular medical check-ups to monitor heart health.").
prevention_tip("Ensure adequate sleep, aiming for 7–8 hours per night.").
prevention_tip("Stay hydrated and drink plenty of water daily.").
prevention_tip("Educate yourself about the warning signs of a heart attack.").
prevention_tip("Participate in a cardiac rehabilitation program if recommended.").

% Display prevention tips
display_prevention_tips :-
	writeln("=== Heart Attack Prevention Tips ==="),
	findall(Tip,
		prevention_tip(Tip),
		Tips),
	display_tips(Tips),
	writeln("===================================="),
	start.

% Helper to display tips
display_tips([]).
display_tips([Tip|Rest]) :-
	format("- ~w~n", [Tip]),
	display_tips(Rest).


% Interactive dialogue
start :-
	writeln("Welcome to the heart attack risk assessment program."),
	writeln("What would you like to do? Type the corresponding number:"),
	writeln("1. Evaluate your risk factors and calculate the probability."),
	writeln("2. Receive explanations about risk factors."),
	writeln("3. Generate a medical report."),
	writeln("5. FAQs (Frequently Asked Questions)."),
	writeln("6. Prevention Tips."),
	writeln("4. Quit."),
	read(Choice),
	handle_choice(Choice).

% Handling choices
handle_choice(1) :-
	evaluate_risks.
handle_choice(2) :-
	explain_factors.
handle_choice(3) :-
	generate_report.
handle_choice(4) :-
	writeln("Thank you for using the program. Take care!"),
	!.
handle_choice(5) :-
	display_faqs.

% Handling new choice for prevention tips
handle_choice(6) :-
	display_prevention_tips.

handle_choice(_) :-
	writeln("Invalid choice. Please try again."),
	start.

% FAQs Display
display_faqs :-
	
	writeln("=== FAQs: Frequently Asked Questions ==="),
	writeln("1. What causes a heart attack?"),
	writeln("   Heart attacks are caused by blockages in coronary arteries due to cholesterol (atherosclerosis),"),
	writeln("   blood clots, or coronary spasms."),
	writeln("2. Can stress alone cause a heart attack?"),
	writeln("   Yes, extreme stress can lead to a surge of hormones (like adrenaline) that overload the heart."),
	writeln("3. How are heart attacks diagnosed?"),
	writeln("   - ECG (detects electrical abnormalities)."),
	writeln("   - Blood tests (measures cardiac enzymes)."),
	writeln("   - Angiography (visualizes blockages)."),
	writeln("4. Can women have different symptoms than men?"),
	writeln("   Yes, women may experience fatigue, nausea, or jaw pain, in addition to chest pain."),
	writeln("5. What are the warning signs of a heart attack?"),
	writeln("   Chest pain, shortness of breath, sweating, nausea, and radiating pain in the arm or jaw."),
	writeln("6. Can heart attacks be prevented?"),
	writeln("   Yes, adopting a healthy lifestyle reduces the risk."),
	writeln("7. What should I do if I suspect a heart attack?"),
	writeln("   Call emergency services, keep calm, give aspirin (if not allergic), and prepare for CPR."),
	writeln("8. Are there different types of heart attacks?"),
	writeln("   Yes: STEMI, NSTEMI, and coronary artery spasm."),
	writeln("9. Can younger people have heart attacks?"),
	writeln("   Yes, due to genetic factors, drugs, or underlying health conditions."),
	writeln("10. How long does recovery from a heart attack take?"),
	writeln("   Recovery can take weeks to months, often involving lifestyle changes."),
	writeln("11. Is a heart attack the same as cardiac arrest?"),
	writeln("   No, cardiac arrest is when the heart stops beating. Heart attack is due to blocked blood flow."),
	writeln("12. Can heart attacks be silent?"),
	writeln("   Yes, some heart attacks have no noticeable symptoms, especially in diabetics."),
	writeln("13. Is family history a risk factor?"),
	writeln("   Yes, genetics can increase your risk, particularly if close relatives had heart attacks."),
	writeln("14. Does diet impact heart attack risk?"),
	writeln("   Yes, a diet high in saturated fats, salt, and sugar raises the risk."),
	writeln("15. How does smoking increase heart attack risk?"),
	writeln("   Smoking damages blood vessels, increases cholesterol, and raises blood pressure."),
	writeln("16. Can regular exercise prevent heart attacks?"),
	writeln("   Yes, it strengthens the heart and improves circulation."),
	writeln("17. Can a healthy weight reduce risk?"),
	writeln("   Yes, obesity increases strain on the heart and raises cholesterol and blood pressure."),
	writeln("18. What role does cholesterol play in heart attacks?"),
	writeln("   High LDL (bad cholesterol) forms plaques that block arteries."),
	writeln("19. Are heart attacks more common in men or women?"),
	writeln("   Men are at higher risk earlier, but risk equalizes post-menopause."),
	writeln("20. Can medications help prevent heart attacks?"),
	writeln("   Yes, medications like statins, aspirin, and beta-blockers can lower risk."),
	writeln("21. What is cardiac rehabilitation?"),
	writeln("   A program of exercise, education, and support to recover from a heart attack."),
	writeln("22. How does high blood pressure lead to heart attacks?"),
	writeln("   It damages arteries and promotes plaque formation."),
	writeln("23. Can sleep affect heart health?"),
	writeln("   Yes, poor sleep increases stress and inflammation, raising risk."),
	writeln("24. Does diabetes increase heart attack risk?"),
	writeln("   Yes, diabetes accelerates artery damage and plaque buildup."),
	writeln("25. How does alcohol affect the heart?"),
	writeln("   Moderate consumption may be protective, but excess raises blood pressure."),
	writeln("26. Can medications like aspirin prevent a heart attack?"),
	writeln("   Aspirin can prevent clots but should only be used on a doctor’s advice."),
	writeln("27. How important is mental health for the heart?"),
	writeln("   Very important; chronic stress, anxiety, and depression increase risk."),
	writeln("28. What is a stent, and how does it help?"),
	writeln("   A stent is a small mesh tube that keeps arteries open after a blockage."),
	writeln("29. Can dehydration trigger a heart attack?"),
	writeln("   Severe dehydration can affect blood pressure and strain the heart."),
	writeln("30. Are there new technologies for heart attack prevention?"),
	writeln("   Yes, wearable devices, AI-based diagnostics, and genetic screening are emerging."),
	writeln("=========================================="),
	start.


% Evaluate risk factors and calculate probability
evaluate_risks :-
	writeln("Please answer the following questions to assess your risks."),
	collect_data,
	calculate_probability.
collect_data :-
	ask_question("Do you smoke? (yes/no/sometimes)", smoking),
	ask_question("Do you have high blood pressure? (yes/no/sometimes)", hypertension),
	ask_question("Do you have high cholesterol? (yes/no/sometimes)", high_cholesterol),
	ask_question("Are you diabetic? (yes/no/sometimes)", diabetes),
	ask_question("Are you obese or overweight? (yes/no/sometimes)", obesity),
	ask_question("Are you physically inactive? (yes/no/sometimes)", sedentary_lifestyle),
	ask_question("Do you have an unhealthy diet? (yes/no/sometimes)", unhealthy_diet),
	ask_question("Do you consume alcohol in large quantities? (yes/no/sometimes)", alcohol),
	ask_age("What is your age?", age),
	ask_question("Do you have a family history of heart disease? (yes/no/sometimes)", family_history),
	ask_period("Are your symptoms or conditions more prevalent during a specific period? (yes/no)", period).
ask_period(Question, Factor) :-
	format("~w~n", [Question]),
	read(Response),
	(Response == yes ->
	writeln("Which period? (e.g., winter, summer, morning, night)"),
		read(Period),
		writeln("How long have you experienced this condition during the specified period? (short-term, medium-term, long-term)"),
		read(Duration),
		assert(period_data(Factor, Period, Duration));
	Response == no ->
	assert(period_data(Factor, none, none));
	writeln("Invalid response. Please try again."),
		ask_period(Question, Factor)).
ask_question(Question, Factor) :-
	format("~w~n", [Question]),
	read(Response),
	(Response == yes ->
	ask_severity(Factor, Response);
	Response == sometimes ->
	ask_severity(Factor, Response);
	Response == no ->
	assert(user_data(Factor, no, 0));
	writeln("Invalid response. Please try again."),
		ask_question(Question, Factor)).
ask_severity(Factor, Response) :-
	writeln("On a scale from 1 to 10, how severe is this condition?"),
	read(Severity),
	(Severity >= 1,
		Severity =< 10 ->
	assert(user_data(Factor, Response, Severity));
	writeln("Invalid severity level. Please enter a number between 1 and 10."),
		ask_severity(Factor, Response)).

% Normalize user response
normalize_response(Input, Response) :-
	(atom(Input) ->
	string_lower(Input, Lowercase);
	atom_string(InputAtom, Input),
		string_lower(InputAtom, Lowercase)),
	atom_string(Response, Lowercase).

% Ask a question about age
ask_age(Question, Factor) :-
	format("~w~n", [Question]),
	read(Age),
	(integer(Age),
		Age > 0 ->
	assert(user_data(Factor, Age, 0));
	writeln("Invalid response. Please enter a valid age."),
		ask_age(Question, Factor)).
calculate_probability :-
	% Collect weights for "yes" responses, considering period
findall(WeightedYes,
		(user_data(Factor, Response, _),
			risk_factor(Factor, Weight),
			Response == yes,
			adjust_for_period(Factor, Weight, WeightedYes)),
		WeightListYes),
	sum_list(WeightListYes, TotalWeightYes),
	% Collect weighted severity for "sometimes" responses, considering period
	findall(WeightedSeverity,
		(user_data(Factor, Response, Severity),
			risk_factor(Factor, Weight),
			Response == sometimes,
			Severity > 0,
			BaseWeightedSeverity is (Weight*Severity)/10,
			adjust_for_period(Factor, BaseWeightedSeverity, WeightedSeverity)),
		WeightedSeverityList),
	sum_list(WeightedSeverityList, TotalSometimesWeight),
	% Compute the total probability
	TotalProbability is TotalWeightYes + TotalSometimesWeight,
	% Display the result
	display_result(TotalProbability),
	clean_data.

% Adjust weight or severity for a factor based on the period and duration
adjust_for_period(Factor, OriginalValue, AdjustedValue) :-
	(period_data(Factor, Period, Duration),
		Period \== none ->
	DurationFactor = (Duration == short - term ->
	0.8;
	Duration == medium - term ->
	1;
	Duration == long - term ->
	1.2),
		AdjustedValue is OriginalValue*DurationFactor;
	AdjustedValue is OriginalValue).

% Display result based on total weights
display_result(Probability) :-
	format("Your estimated probability of having a heart attack is: ~w.~n", [Probability]),
	advise(Probability).
% Advice based on probability with treatments
% Recommandations médicales basées sur les risques
advise(Probability) :-
	Probability >= 60,
	!,
	writeln("Votre risque est ÉLEVÉ. Consultez un médecin immédiatement."),
	writeln("Traitements d'urgence recommandés selon votre situation :"),
	recommend_emergency_treatments.
advise(Probability) :-
	Probability >= 30,
	!,
	writeln("Votre risque est MODÉRÉ. Prenez des mesures pour améliorer votre mode de vie."),
	writeln("Traitements à considérer :"),
	recommend_long_term_treatments.
advise(_) :-
	writeln("Votre risque est FAIBLE. Continuez à prendre soin de vous."),
	writeln("Recommandations générales : adoptez un mode de vie sain.").

% Recommandations d'urgence selon les symptômes
recommend_emergency_treatments :-
	(user_data(hypertension, yes, _) ->
	writeln("- Médicaments pour l hypertension : nitroglycérine.");
	true),
	(user_data(high_cholesterol, yes, _) ->
	writeln("- Médicaments pour réduire le cholestérol : statines.");
	true),
	(user_data(smoking, yes, _) ->
	writeln("- Arrêt immédiat du tabac et traitement de substitution.");
	true),
	writeln("- Contactez immédiatement les urgences pour un diagnostic précis.").

% Recommandations à long terme
recommend_long_term_treatments :-
	(user_data(hypertension, yes, _) ->
	writeln("- Médicaments pour l hypertension à long terme : bêta-bloquants, inhibiteurs de l ECA.");
	true),
	(user_data(diabetes, yes, _) ->
	writeln("- Gestion du diabète avec insuline ou antidiabétiques oraux.");
	true),
	(user_data(obesity, yes, _) ->
	writeln("- Programme de perte de poids et réadaptation cardiaque.");
	true),
	writeln("- Adoptez une alimentation saine et un exercice régulier.").



% Generate medical report
generate_report :-
	writeln("=== Medical Report ==="),
	findall((Factor, Response, Severity),
		user_data(Factor, Response, Severity),
		Data),
	display_data(Data),
	writeln("======================="),
	start.
display_data([]).
display_data([(Factor, Response, Severity)|Rest]) :-
	(period_data(Factor, Period, Duration),
		Period \== none ->
	format("- ~w : ~w (Severity: ~w, Period: ~w, Duration: ~w)~n", [Factor, Response, Severity, Period, Duration]);
	format("- ~w : ~w (Severity: ~w)~n", [Factor, Response, Severity])),
	display_data(Rest).


% Explain risk factors
explain_factors :-
	writeln("Modifiable risk factors:"),
	explain_modifiable_factors,
	writeln("Non-modifiable risk factors:"),
	explain_non_modifiable_factors,
	writeln("Hormonal factors specific to women:"),
	explain_hormonal_factors,
	start.
explain_modifiable_factors :-
	findall(F,
		(weight(F, _),
			 modifiable_factor(F)),
		Factors),
	display_explanations(Factors).
explain_non_modifiable_factors :-
	findall(F,
		(weight(F, _),
			non_modifiable_factor(F)),
		Factors),
	display_explanations(Factors).
explain_hormonal_factors :-
	findall(F,
		(weight(F, _),
			hormonal_factor(F)),
		Factors),
	display_explanations(Factors).

% Categorization of factors

modifiable_factor(F) :-
	member(F, [smoking, hypertension, high_cholesterol, diabetes, obesity, sedentary_lifestyle, unhealthy_diet, alcohol]).
non_modifiable_factor(F) :-
	member(F, [age, family_history]).
hormonal_factor(F) :-
	member(F, [menopause, birth_control]).

% Display explanations
display_explanations([]).
display_explanations([T|Q]) :-
	weight(T, Weight),
	format("- ~w : Weight ~w~n", [T, Weight]),
	display_explanations(Q).

% Clean up user data
clean_data :-
	retractall(user_data(_, _, _)),
	retractall(period_data(_, _, _)).
