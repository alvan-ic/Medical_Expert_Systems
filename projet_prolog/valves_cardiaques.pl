% Structure du cœur
cavite(oreillette_droite).
cavite(oreillette_gauche).
cavite(ventricule_droit).
cavite(ventricule_gauche).

valve(tricuspide, droite).
valve(pulmonaire, droite).
valve(mitrale, gauche).
valve(aortique, gauche).

fonction_valve(tricuspide, empecher_reflux(oreillette_droite)).
fonction_valve(pulmonaire, expulsion_sang(artere_pulmonaire)).
fonction_valve(mitrale, empecher_reflux(oreillette_gauche)).
fonction_valve(aortique, expulsion_sang(aorte)).

etat_valve(ouverte, contraction, [aortique, pulmonaire]).
etat_valve(fermee, contraction, [tricuspide, mitrale]).
etat_valve(ouverte, relaxation, [tricuspide, mitrale]).
etat_valve(fermee, relaxation, [aortique, pulmonaire]).

% Valvulopathies
valvulopathie(usure, degenerative).
valvulopathie(dilatation_ventricule, insuffisance_cardiaque).
valvulopathie(anomalie_congenitale, congenitale).
valvulopathie(infection_bacterienne, infectieuse).
valvulopathie(atteinte_rhumatismale, rhumatismale).

cause_valvulopathie(augmentation_age, usure).
cause_valvulopathie(insuffisance_cardiaque, dilatation_ventricule).
cause_valvulopathie(mutation_genetique, anomalie_congenitale).
cause_valvulopathie(bacterie, infection_bacterienne).
cause_valvulopathie(rhumatisme, atteinte_rhumatismale).

consequence_valvulopathie(fermeture_incomplete, reflux_sang).
consequence_valvulopathie(stenose, obstruction_ecoulement).

% Symptômes
symptome(valvulopathie, fatigue).
symptome(valvulopathie, palpitations).
symptome(valvulopathie, diminution_capacite_physique).
symptome(valvulopathie, douleur_thoracique).
symptome(insuffisance_cardiaque, difficulte_respirer).
symptome(insuffisance_cardiaque, oppression_thoracique).

% Examens
examen(echocardiographie_transthoracique).
examen(echocardiographie_transoesophagienne).
examen(irm_cardiaque).
examen(ct_scan).
examen(coronarographie).
examen(catheterisme).
examen(test_effort).
examen(holter).
examen(mapa).

utilise_diagnostic(valvulopathie, [echocardiographie_transthoracique, echocardiographie_transoesophagienne, irm_cardiaque, ct_scan, coronarographie, catheterisme, test_effort, holter, mapa]).
