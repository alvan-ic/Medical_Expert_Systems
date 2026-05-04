% Système Expert sur les Maladies Cardiaques

% Section : Facteurs de risque modifiables
facteur_risque(hypertension).
facteur_risque(tabagisme).
facteur_risque(cholesterol_eleve).
facteur_risque(obesite).
facteur_risque(alimentation_pauvre).
facteur_risque(inactivite_physique).
facteur_risque(pression_arterielle_elevee).
facteur_risque(diabetique).
facteur_risque(consommation_excessive_alcool).

% Section : Maladies cardiovasculaires
maladie(cardiopathie_coronaire).
maladie(avc).
maladie(infarctus).
maladie(insuffisance_cardiaque).
maladie(thrombose_veineuse).
maladie(arteriopathie_peripherique).
maladie(cardiopathie_rhumatismale).
maladie(cardiopathie_congenitale).

% Section : Symptômes associés aux maladies
symptome(infarctus, douleur_chest).
symptome(infarctus, douleur_bras).
symptome(infarctus, essoufflement).
symptome(avc, engourdissement).
symptome(avc, confusion).
symptome(insuffisance_cardiaque, fatigue).
symptome(insuffisance_cardiaque, arythmie).

% Section : Symptômes spécifiques de la cardiopathie coronaire
maladie_coranarienne(maladie_cardiaque).
cause(maladie_coranarienne, atherosclerose).
symptome(maladie_coranarienne, douleur_thoracique).
symptome(maladie_coranarienne, angine_de_poitrine).
symptome(maladie_coranarienne, essoufflement).
symptome(maladie_coranarienne, fatigue).
symptome(maladie_coranarienne, sudation).

% Section : Diagnostic
diagnostic(ecg).
diagnostic(epreuve_tolérance_effort).
diagnostic(angiographie_coronarienne).

% Section : Traitements disponibles
traitement(medicaments_cholesterol).
traitement(medicaments_antiplaquettaires).
traitement(intervention_cornarianne_percutanée).
traitement(pontage_coronarien).

% Section : Prévention des maladies cardiovasculaires
prevention(arret_tabagisme).
prevention(alimentation_saine).
prevention(exercice_regulier).
prevention(gestion_stress).

% Section : Statistiques et données générales
deces_annuels(140000). % Décès annuels dus aux MCV en France
traitement(4100000). % Nombre de personnes traitées pour MCV
risque_femmes_moins_65(25). % Augmentation des MCV chez les femmes de moins de 65 ans depuis 2000
mortalite(2021, 20500000). % Nombre total de décès dus aux MCV
statistique(hommes_plus_susceptibles, deux_fois_plus_que_femmes).

% Règle : Évaluation du risque de maladie cardiovasculaire
risque_maladie(Maladie) :-
    facteur_risque(hypertension),
    maladie(Maladie).

risque_maladie(infarctus) :-
    facteur_risque(tabagisme),
    facteur_risque(cholesterol_eleve).

% Règles : Interface utilisateur
demarrer :-
    write('Avez-vous une hypertension ? (oui/non)'), nl,
    read(ReponseHypertension),
    write('Êtes-vous fumeur ? (oui/non)'), nl,
    read(ReponseTabagisme),
    evaluer(ReponseHypertension, ReponseTabagisme).

evaluer(oui, oui) :-
    write('Risque élevé d\'infarctus ou d\'autres MCV.'), nl.
evaluer(oui, non) :-
    write('Surveillez vos symptômes et consultez un médecin.'), nl.
evaluer(non, oui) :-
    write('Consultez un médecin pour évaluer vos risques.'), nl.
evaluer(non, non) :-
    write('Pas de risques significatifs détectés.'), nl.

% Règles : Recommandations de prévention
regle_prevention :-
    prevention(X),
    write('Il est recommandé de: '), write(X), nl,
    fail.
regle_prevention.

% Faits concernant la maladie coronarienne (répétition supprimée)
maladie_coranarienne(maladie_cardiaque).
cause(maladie_coranarienne, atherosclerose).

% Diagnostic et traitement (répétition supprimée)
diagnostic(ecg).
diagnostic(epreuve_tolérance_effort).
diagnostic(angiographie_coronarienne).

traitement(medicaments_cholesterol).
traitement(medicaments_antiplaquettaires).
traitement(intervention_cornarianne_percutanée).
traitement(pontage_coronarien).

% Prévention (répétition supprimée)
prevention(arret_tabagisme).
prevention(alimentation_saine).
prevention(exercice_regulier).
prevention(gestion_stress).

% Statistiques (répétition supprimée)
statistique(hommes_plus_susceptibles, deux_fois_plus_que_femmes).
