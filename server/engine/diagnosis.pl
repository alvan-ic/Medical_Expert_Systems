%%----------------Malaria---------------
disease([fever, chills, headache, body_pain, nausea, weakness], malaria).
disease([fever, sweats, headache, body_pain, vomiting, weakness], malaria).
disease([fever, chills, headache, sweating], malaria).

%----------------Neonatal Sepsis-------------
disease([poor_feeding, lethargy, fever, fast_breathing, grunting, irritability, jaundice, seizures,poor_cry], neonatal_sepsis).
disease([poor_feeding, lethargy, hypothermia, fast_breathing, grunting, irritability, jaundice, seizures,poor_cry], neonatal_sepsis).

%-------------------------HIV/AIDS-----------
disease([recurrent_fever, weight_loss, chronic_diarrhea, night_sweats, persistent_cough, oral_thrush, swollen_lymph_nodes, recurrent_infections, high_risk_exposure], hiv_aids).
disease([fever, weight_loss, chronic_diarrhea, night_sweats, persistent_cough, oral_thrush, swollen_lymph_nodes, recurrent_infections, high_risk_exposure], hiv_aids).
disease([recurrent_fever, weight_loss, chronic_diarrhea, night_sweats, persistent_cough, oral_thrush, swollen_lymph_nodes, recurrent_infections, young_adult], hiv_aids).

% ---------------------------------------TB-----------------
disease([cough_two_plus_weeks, weight_loss, fever, night_sweats, chest_pain, hemoptysis, fatigue, hiv_exposure], 'Tuberculosis').
disease([cough_two_plus_weeks, weight_loss, fever, night_sweats, chest_pain, hemoptysis, fatigue, close_tb_contact], 'Tuberculosis').
disease([cough_two_plus_weeks, weight_loss, fever, night_sweats, chest_pain, hemoptysis, fatigue, hiv_exposure, close_tb_contact], 'Tuberculosis').

%---------------------------Pneumonia-------------------

disease([cough, fever, breathlessness, chest_pain_worse_with_breathing, fast_breathing, sputum_production, reduced_oxygen_saturation], 'Pneumonia').
disease([cough, fever, fast_breathing, breathlessness], 'Pneumonia').
disease([cough, fever, breathlessness, chest_pain, fast_breathing, sputum_production, reduced_oxygen_saturation], 'Pneumonia').
disease([cough, fever, fast_breathing, breathlessness, reduced_oxygen_saturation], 'Pneumonia').
disease([cough, fever, confusion, fast_breathing, reduced_oxygen_saturation], 'Pneumonia').

% ------------------------Cholera------------------------
disease([sudden_watery_diarrhea, vomiting, severe_dehydration, muscle_cramps, sunken_eyes, unsafe_water_exposure], 'Cholera').
disease([sudden_watery_diarrhea, vomiting, severe_dehydration, muscle_cramps, sunken_eyes, outbreak_exposure], 'Cholera').
disease([sudden_watery_diarrhea, vomiting, severe_dehydration, muscle_cramps, sunken_eyes, unsafe_water_exposure, outbreak_exposure], 'Cholera').
disease([sudden_watery_diarrhea, vomiting, severe_dehydration], 'Cholera').
disease([sudden_watery_diarrhea, severe_dehydration, muscle_cramps, sunken_eyes, unsafe_water_exposure], 'Cholera').


% -------------------------Chronic Kidney Disease-----------
disease([edema, foamy_urine, fatigue, nocturia, reduced_appetite, hypertension, itching, metallic_taste, known_diabetes], 'Chronic Kidney Disease').
disease([edema, foamy_urine, fatigue, nocturia, reduced_appetite, hypertension, itching, metallic_taste, known_hypertension], 'Chronic Kidney Disease').
disease([edema, foamy_urine, fatigue, nocturia, reduced_appetite, hypertension, itching, metallic_taste, known_diabetes, known_hypertension], 'Chronic Kidney Disease').
disease([edema, hypertension, fatigue, foamy_urine], 'Chronic Kidney Disease').
disease([edema, foamy_urine, fatigue, nocturia, reduced_appetite, hypertension, itching, metallic_taste, nausea, vomiting, muscle_cramps], 'Chronic Kidney Disease').


% -------------------------Typhoid Fever-----------
disease([prolonged_fever, abdominal_pain, headache, constipation, weakness, reduced_appetite, unsafe_food_water], 'Typhoid Fever').
disease([prolonged_fever, abdominal_pain, headache, diarrhea, weakness, reduced_appetite, unsafe_food_water], 'Typhoid Fever').
disease([prolonged_fever, abdominal_pain, headache, constipation, diarrhea, weakness, reduced_appetite, unsafe_food_water], 'Typhoid Fever').
disease([prolonged_fever, abdominal_pain, weakness, headache], 'Typhoid Fever').
disease([prolonged_fever, abdominal_pain, headache, constipation, weakness, reduced_appetite, unsafe_food_water, rose_spots], 'Typhoid Fever').
disease([prolonged_fever, abdominal_pain, headache, constipation, weakness, reduced_appetite, unsafe_food_water, intestinal_perforation, gastrointestinal_bleeding], 'Typhoid Fever').



% -------------------------Lassa Fever-----------
disease([fever, weakness, sore_throat, cough, nausea, vomiting, diarrhea, muscle_pain, chest_pain, abdominal_pain], 'Lassa Fever').
disease([fever, weakness, sore_throat, cough, nausea, vomiting, diarrhea, muscle_pain, chest_pain, abdominal_pain, dry_season], 'Lassa Fever').
disease([fever, weakness, sore_throat, cough, nausea, vomiting, diarrhea, muscle_pain, chest_pain, abdominal_pain, hemorrhage, bleeding_gums, facial_swelling], 'Lassa Fever').
disease([fever, weakness, sore_throat, dry_season], 'Lassa Fever').
disease([fever, weakness, sore_throat, cough, nausea, vomiting, diarrhea, muscle_pain, rodent_exposure, dry_season], 'Lassa Fever').
disease([fever, weakness, sore_throat, muscle_pain, nausea], 'Lassa Fever').
disease([fever, weakness, sore_throat, vomiting, diarrhea, abdominal_pain, hemorrhage, respiratory_distress, pericarditis, hearing_loss], 'Lassa Fever').


% -------------------------Sickle Cell Disease-----------
disease([recurrent_painful_crises, anemia, jaundice, delayed_growth, hand_foot_swelling, recurrent_infections, family_history], 'Sickle Cell Disease').
disease([recurrent_painful_crises, anemia, jaundice, dactylitis, recurrent_infections, family_history], 'Sickle Cell Disease').
disease([recurrent_painful_crises, anemia, jaundice, delayed_growth, hand_foot_swelling, recurrent_infections], 'Sickle Cell Disease').
disease([recurrent_painful_crises, anemia, dactylitis, family_history], 'Sickle Cell Disease').


% -------------------------Hypertension-----------
disease([throbbing_morning_headache, nosebleeds, irregular_heart_rhythms, vision_changes], 'Hypertension').
disease([headache, nosebleeds, blurred_vision, palpitations], 'Hypertension').
disease([asymptomatic, high_blood_pressure_reading], 'Hypertension').

% -------------------------Diabetes Mellitus Type 2-----------
disease([excessive_thirst, frequent_urination, excessive_hunger, blurred_vision, slow_healing_wounds, tingling_hands_feet], 'Diabetes Mellitus Type 2').
disease([polydipsia, polyuria, polyphagia, blurred_vision, slow_healing_wounds, neuropathy], 'Diabetes Mellitus Type 2').
disease([excessive_thirst, frequent_urination, excessive_hunger, fatigue, weight_loss], 'Diabetes Mellitus Type 2').

% -------------------------Hepatitis B-----------
disease([fatigue, jaundice, dark_urine, pale_stool, right_upper_abdominal_pain, nausea, loss_of_appetite], 'Hepatitis B').
disease([fatigue, jaundice, dark_urine, pale_stool, right_upper_abdominal_pain, nausea], 'Hepatitis B').
disease([fatigue, jaundice, loss_of_appetite, right_upper_abdominal_pain, body_fluids_exposure], 'Hepatitis B').


% -------------------------Bacterial Meningitis-----------
disease([sudden_high_fever, severe_headache, neck_stiffness, photophobia, vomiting, altered_consciousness, seizures, rash], 'Bacterial Meningitis').
disease([sudden_high_fever, severe_headache, neck_stiffness, photophobia, vomiting, altered_consciousness], 'Bacterial Meningitis').
disease([fever, headache, neck_stiffness, photophobia, meningitis_belt_exposure], 'Bacterial Meningitis').
disease([sudden_high_fever, severe_headache, neck_stiffness, rash, seizures], 'Bacterial Meningitis').


% -------------------------Peptic Ulcer Disease-----------
disease([burning_epigastric_pain, bloating, nausea, reflux, nighttime_pain, nsaid_use], 'Peptic Ulcer Disease').
disease([burning_epigastric_pain_meal_related, bloating, nausea, reflux, nighttime_pain], 'Peptic Ulcer Disease').
disease([epigastric_pain, bloating, nausea, nsaid_use, stress_history], 'Peptic Ulcer Disease').
disease([burning_epigastric_pain, nighttime_pain, relief_with_food], 'Peptic Ulcer Disease').


% -------------------------Asthma-----------
disease([intermittent_wheeze, night_cough, early_morning_cough, chest_tightness, shortness_of_breath, dust_trigger, cold_air_trigger, exercise_trigger], 'Asthma').
disease([intermittent_wheeze, night_cough, chest_tightness, shortness_of_breath], 'Asthma').
disease([wheezing, coughing, chest_tightness, dyspnea, exercise_induced], 'Asthma').
disease([intermittent_wheeze, night_cough, shortness_of_breath, cold_air_trigger], 'Asthma').


% -------------------------Measles-----------
disease([high_fever, cough, runny_nose, red_watery_eyes, koplik_spots, spreading_rash], 'Measles').
disease([high_fever, cough, coryza, conjunctivitis, koplik_spots, maculopapular_rash], 'Measles').
disease([fever, cough, runny_nose, red_eyes, rash, unvaccinated_child], 'Measles').
disease([high_fever, koplik_spots, spreading_rash, unvaccinated], 'Measles').


% -------------------------Urinary Tract Infection / Pyelonephritis-----------
disease([dysuria, urgency, frequency, suprapubic_pain, cloudy_urine, foul_urine], 'Urinary Tract Infection').
disease([dysuria, urgency, frequency, suprapubic_pain, flank_pain, fever], 'Pyelonephritis').
disease([dysuria, urgency, frequency, cloudy_urine, female], 'Urinary Tract Infection').
disease([dysuria, frequency, suprapubic_pain, foul_urine], 'Urinary Tract Infection').


% -------------------------Yellow Fever-----------
disease([sudden_fever, headache, muscle_pain, back_pain, nausea, vomiting], 'Yellow Fever').
disease([sudden_fever, headache, muscle_pain, nausea, jaundice, bleeding, black_vomit], 'Yellow Fever Toxic Phase').
disease([fever, headache, myalgia, jaundice, hemorrhage, unvaccinated], 'Yellow Fever').
disease([sudden_fever, headache, back_pain, vomiting, jaundice, black_vomit], 'Yellow Fever').


% -------------------------Glaucoma-----------
disease([peripheral_vision_loss, tunnel_vision, gradual_vision_loss], 'Glaucoma').
disease([severe_eye_pain, red_eyes, halos_around_lights, blurred_vision, nausea, vomiting], 'Acute Angle Closure Glaucoma').
disease([eye_pain, headache, blurred_vision, halos, nausea], 'Acute Glaucoma').
disease([asymptomatic, increased_intraocular_pressure, optic_nerve_damage], 'Glaucoma').


% -------------------------Lymphatic Filariasis-----------
disease([chronic_limb_swelling, scrotal_swelling, recurrent_skin_infections, heaviness_of_legs, elephantiasis], 'Lymphatic Filariasis').
disease([chronic_limb_swelling, elephantiasis, endemic_area_exposure], 'Lymphatic Filariasis').
disease([lymphedema, scrotal_swelling, recurrent_infections, heaviness_of_legs], 'Lymphatic Filariasis').


% -------------------------Onchocerciasis (River Blindness)-----------
disease([severe_itching, skin_rash, subcutaneous_nodules, eye_irritation, visual_problems], 'Onchocerciasis').
disease([severe_pruritus, skin_rash, nodules, visual_impairment, river_side_exposure], 'Onchocerciasis').
disease([itching, skin_changes, subcutaneous_nodules, eye_disease], 'River Blindness').


% -------------------------Acute Otitis Media-----------
disease([ear_pain, fever, irritability, reduced_hearing, ear_tugging], 'Acute Otitis Media').
disease([ear_pain, fever, ear_discharge, irritability, reduced_hearing], 'Acute Otitis Media').
disease([ear_pain, fever, irritability, ear_tugging, child], 'Acute Otitis Media').
disease([otalgia, fever, irritability, hearing_loss, otorrhea], 'Otitis Media').


% -------------------------Meningococcal Disease-----------
disease([fever, headache, neck_stiffness, vomiting, confusion, petechial_rash, purpuric_rash], 'Meningococcal Disease').
disease([sudden_fever, severe_headache, neck_stiffness, petechial_rash, dry_season, crowded_setting], 'Meningococcal Disease').
disease([fever, headache, neck_stiffness, confusion, rash, meningitis_belt], 'Meningococcal Meningitis').
disease([fever, neck_stiffness, petechial_rash, vomiting, altered_mental_status], 'Meningococcal Disease').


% -------------------------Gastroenteritis-----------
disease([diarrhea, vomiting, abdominal_cramps, fever, contaminated_food_water_exposure], 'Gastroenteritis').
disease([diarrhea, vomiting, abdominal_cramps, fever, dehydration], 'Gastroenteritis').
disease([watery_diarrhea, vomiting, abdominal_pain, contaminated_food_exposure], 'Gastroenteritis').
disease([diarrhea, vomiting, abdominal_cramps, fever], 'Gastroenteritis').

% -------------------------Hepatitis C-----------
disease([fatigue, jaundice, abnormal_liver_enzymes, transfusion_history], 'Hepatitis C').
disease([fatigue, abnormal_liver_enzymes, unsafe_injection_history], 'Hepatitis C').
disease([asymptomatic, abnormal_liver_enzymes, transfusion_history], 'Hepatitis C').
disease([fatigue, jaundice, dark_urine, transfusion_history], 'Hepatitis C').


match(Disease, UserSymptoms):-
    disease(DiseaseSymptoms, Disease),
    subset(UserSymptoms, DiseaseSymptoms).  % ← Changed order!

subset([], _).
subset([H|T], List) :-
    member(H, List),
    subset(T,List).


%%-----------------------Diagnosis
diagnose(UserSymptoms) :-
    findall(Disease, match(Disease, UserSymptoms), AllDiseases),
    sort(AllDiseases, Diseases),   % deduplicate; fixes exponential backtracking
    (
        Diseases \= [] ->
        write('Based on your symptoms: '), write(UserSymptoms), nl,
        write('You may have the following condition(s): '), nl, nl,
        list_with_details(UserSymptoms, Diseases)
        ;
        write('No matching disease found in the knowledge base'), nl,
        write('Try consulting a doctor for accurate diagnosis'), nl
    ), !.                          % cut: diagnose has exactly one solution

list_with_details(_, []).
list_with_details(UserSymptoms, [D|Rest]) :-
    once(disease(SymList, D)),     % commit to first fact; prevents choice-point explosion
    length(SymList, RequiredCount),
    match_percentage(SymList, UserSymptoms, Percentage),
    write(D), write(': requires '),
    write(RequiredCount),
    write(' symptoms, '),
    write(Percentage),
    write('% match'),
    nl,
    list_with_details(UserSymptoms, Rest).

match_percentage(Required, User, Percentage):-
    intersection(Required, User, Common),
    length(Common, CommonCount),
    length(Required, RequiredCount),
    Percentage is (CommonCount * 100 ) // RequiredCount.

intersection([],_,[]).
intersection([H|T], List, [H|Rest]):-
    member(H,List),
    intersection(T, List, Rest).
intersection([H|T], List, Rest):-
    \+ member(H, List),
    intersection(T, List, Rest).

%% API-facing predicate: returns one result per matching disease via backtracking.
%% Variables: Disease (atom), Percentage (int), Common (list), Missing (list)
diagnose_result(UserSymptoms, Disease, Percentage, Common, Missing) :-
    findall(D, match(D, UserSymptoms), AllDiseases),
    sort(AllDiseases, Diseases),
    member(Disease, Diseases),
    once(disease(SymList, Disease)),
    intersection(SymList, UserSymptoms, Common),
    findall(S, (member(S, SymList), \+ member(S, UserSymptoms)), Missing),
    match_percentage(SymList, UserSymptoms, Percentage).

%%----------------Interactive version-------------
