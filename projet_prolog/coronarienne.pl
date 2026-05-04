% Causes
cause(athérosclérose).
cause(elevated_ldl).
cause(low_hdl).
cause(hypertension).
cause(tabagisme).
cause(diabète).
cause(mauvais_regime_alimentaire).
cause(inactivité_physique).
cause(obésité).
cause(consommation_excessive_alcool).
cause(historique_familial).

% Symptômes
symptome(angine, douleur_thoracique).
symptome(angine, douleur_epaule).
symptome(angine, douleur_machoire).
symptome(angine, fatigue).
symptome(angine, essoufflement).
symptome(crise_cardiaque, douleur_intense_thoracique).
symptome(crise_cardiaque, douleur_bras).
symptome(crise_cardiaque, oppression_thorax).
symptome(crise_cardiaque, transpiration).
symptome(crise_cardiaque, nausée).
symptome(crise_cardiaque, faiblesse).
symptome(crise_cardiaque, anxiété).

% Diagnostic
diagnostic(electrocardiogramme, anomalies_electriques).
diagnostic(angiographie, plaques_arteres).
diagnostic(epreuve_effort, modifications_pendant_activite).
diagnostic(electrocardiographe_24h, angine_silencieuse).

% Traitement
traitement(medicament, reduction_cholesterol).
traitement(medicament, reduction_hypertension).
traitement(medicament, antithrombotiques).
traitement(intervention, angioplastie).
traitement(intervention, pontage).
traitement(prevention, arret_tabac).
traitement(prevention, regime_alimentaire_sain).
traitement(prevention, exercice_physique).

% Une personne a un risque élevé de maladie coronarienne si elle présente plusieurs facteurs de risque.
risque_eleve(X) :- 
    cause(C1), cause(C2), cause(C3),
    X = [C1, C2, C3].

% Une personne peut avoir une angine si elle présente des douleurs thoraciques et de la fatigue.
possible_angine :- 
    symptome(angine, douleur_thoracique),
    symptome(angine, fatigue).

% Une crise cardiaque est probable si des douleurs thoraciques intenses sont accompagnées de transpiration et doppression thoracique.
possible_crise_cardiaque :- 
    symptome(crise_cardiaque, douleur_intense_thoracique),
    symptome(crise_cardiaque, transpiration),
    symptome(crise_cardiaque, oppression_thorax).

% Un diagnostic est recommandé si des symptômes spécifiques sont présents.
recommander_diagnostic(D) :- 
    symptome(crise_cardiaque, douleur_intense_thoracique),
    diagnostic(D, _).

% Définition de la coronaropathie
coronaropathie(retrécissement_artères).
coronaropathie(obstruction_artères).

% Types de coronaropathie
type_coronaropathie(obstructive).
type_coronaropathie(non_obstructive).
type_coronaropathie(dsac).

% Facteurs de risque modifiables
facteur_risque(hypertension).
facteur_risque(cholesterol_eleve).
facteur_risque(triglycerides_elevés).
facteur_risque(diabete).
facteur_risque(poids_malsain).
facteur_risque(alimentation_de_faible_qualite).
facteur_risque(consommation_excessive_alcool).
facteur_risque(sedentarite).
facteur_risque(tabagisme).
facteur_risque(stress).
facteur_risque(depression).

% Facteurs de risque non modifiables
facteur_risque_non_modifiable(age).
facteur_risque_non_modifiable(sexe_masculin).
facteur_risque_non_modifiable(menopause).
facteur_risque_non_modifiable(antecedents_familiaux).
facteur_risque_non_modifiable(pre_eclampsie).
facteur_risque_non_modifiable(origines_ethniques).

% Symptômes
symptome(fatigue).
symptome(douleurs_poitrine).
symptome(etourdissements).
symptome(sensation_ecrasement_poitrine).
symptome(suffocation).
symptome(brulure_poitrine).
symptome(symptomes_atypiques_femmes).

% Conséquences possibles
consequence(crise_cardiaque).
consequence(avc).
consequence(arret_cardiaque).
consequence(deces).

% Traitements
traitement_medical(medicaments).
traitement_medical(chirurgie).
traitement_medical(changement_habitudes_vie).

% Médicaments
medicament(antiplaquettaires).
medicament(inhibiteurs_eca).
medicament(betabloquants).
medicament(inhibiteurs_canaux_calciques).
medicament(nitrates).

% Chirurgies
chirurgie(angioplastie).
chirurgie(pontage).

% Prévention
prevention(maitrise_pression_arterielle).
prevention(maitrise_cholesterol).
prevention(maitrise_diabete).
prevention(mode_vie_sain).
prevention(arret_tabac).
prevention(eviter_tabagisme_passif).
prevention(activite_physique).
prevention(poids_sain).
prevention(alimentation_saine).
prevention(reduction_stress).

% Règles de prévention
prevenir_coronaropathie(X) :- prevention(X).
