% Faits décrivant les types de cardiomyopathies
cardiomyopathie(dilatee).
cardiomyopathie(hypertrophique).
cardiomyopathie(obstructive).
cardiomyopathie(stress).

% Symptômes communs
symptome(cardiomyopathie, fatiguabilite).
symptome(cardiomyopathie, essoufflement).
symptome(cardiomyopathie, douleurs).
symptome(hypertrophique_obstructive, syncope).

% Causes
cause(hypertrophique, hypertension_artérielle).
cause(hypertrophique, sport_intense).
cause(hypertrophique, maladie_genetique).
cause(obstructive, anomalie_genetique).
cause(stress, stress_majeur).
cause(dilatee, infarctus_myocarde).
cause(dilatee, maladie_valves).

% Complications
complication(cardiomyopathie, arythmie).
complication(cardiomyopathie, insuffisance_cardiaque).
complication(obstructive, mort_subite).

% Diagnostic
diagnostic(symptome(fatiguabilite), echographie).
diagnostic(symptome(essoufflement), echographie).
diagnostic(symptome(syncope), imagerie_irm).

% Traitements
traitement(dilatee, [diuretiques, betabloquants, inhibiteurs_enzymes_conversion]).
traitement(hypertrophique, [betabloquants, verapamil]).
traitement(stress, [repos, betabloquants]).
traitement(obstructive, [chirurgie, infarctus_induit]).

% Règles
besoin_diagnostic(X) :- symptome(X, _), diagnostic(X, Methode), write('Diagnostic recommandé : '), writeln(Methode).
besoin_traitement(X) :- traitement(X, Traitements), write('Traitements disponibles : '), writeln(Traitements).
