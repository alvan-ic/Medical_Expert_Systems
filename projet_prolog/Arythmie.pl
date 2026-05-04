
% Faits concernant les troubles cardiaques

% Blocage du noeud sinusal
blocage_noeud_sinusal(complete).
arret_sinusal(ECG_surface).
asystolie.
rythme_echappement(jonctionnel, 40_60).
rythme_echappement(ventriculaire, bas).
syncope.

% Causes de bradycardie et de pauses sinusales
cause_bradcardie(sinusale, tonicite_vagale).
cause_bradcardie(sinusale, dysfonction_sinusale).
cause_bradcardie(sinusale, medicament).
besoin_pacemaker(symptomatique).

% Bloc AV
bloc_av(degre_1, intervalle_PQ_prolonge(200)).
bloc_av(degre_2, mobitz_I).
bloc_av(degre_2, mobitz_II).
bloc_av(degre_3, complet).
bloc_av(degre_2, besoin_pacemaker).
bloc_av(degre_3, besoin_pacemaker).

% Bloc trifasciculaire incomplet
bloc_trifasciculaire(incomplet, risque_difficile).

% Tachyarythmies
tachycardie(frequence(100)).
flutter_atrial(frequence(250_300)).
fibrillation_auriculaire.

% Règles concernant lindication de pacemaker

% Bradycardie symptomatique
besoin_pacemaker(sinon, bradycardie) :-
    bradycardie(symptomatique),
    frequence(<40),
    pause > 3. % Pause de plus de 3 secondes

% Bloc AV
besoin_pacemaker(av) :-
    bloc_av(degre_2, symptomatique).
besoin_pacemaker(av) :-
    bloc_av(degre_3, _).

% Bloc trifasciculaire incomplet
besoin_pacemaker(trifasciculaire) :-
    bloc_trifasciculaire(incomplet),
    symptomes(syncopes).

% Flutter auriculaire
besoin_pacemaker(flutter) :-
    flutter_atrial(_),
    anticoagulation(requise).

% Fibrillation auriculaire
besoin_pacemaker(fibrillation) :-
    fibrillation_auriculaire,
    anticoagulation(requise).

% Règle pour classer la fréquence cardiaque
rythme_cardiaque(Frequence) :-
    Frequence < 60, 
    write('Bradyarythmie').


rythme_cardiaque(Frequence) :-
    Frequence >= 100, 
    write('Tachyarythmie').

rythme_cardiaque(Frequence) :-
    Frequence >= 60, 
    Frequence < 100, 
    write('Rythme normal').

% Syndrome de dysfonctionnement sinusal
bradyarythmie(syndrome_dysfonctionnement_sinusal, age(OldAge)) :-
    OldAge >= 65, 
    write('Syndrome de dysfonctionnement sinusal : prévalence estimée à 1:600 chez les patients âgés').

bradyarythmie(syndrome_dysfonctionnement_sinusal, age(YoungAge)) :-
    YoungAge < 65,
    write('Pas de syndrome de dysfonctionnement sinusal probable').

% Bloc AV
bradyarythmie(bloc_AV, age(OldAge)) :-
    OldAge >= 65, 
    write('Bloc AV de degré supérieur peut nécessiter un pacemaker').

% Tachyarythmies ventriculaires
tachyarythmie(ventriculaire, Traitement) :-
    Traitement == 'urgente', 
    write('Les tachyarythmies ventriculaires représentent une menace vitale et nécessitent un traitement rapide').

% Tachyarythmies supraventriculaires paroxystiques
tachyarythmie(supraventriculaire_paroxystique, Traitement) :-
    Traitement == 'ablation_cathéter', 
    write('Ablation par cathéter recommandée pour les tachyarythmies supraventriculaires paroxystiques').

% Flutter atrial
tachyarythmie(flutter_atrial, Traitement) :-
    Traitement == 'ablation_cathéter', 
    write('Ablation par cathéter recommandée pour le flutter atrial').

% Traitement en fonction des symptômes
traitement(symptome(palpitation), 'pacemaker') :-
    write('Pacemaker recommandé en cas de bradyarythmie avec palpitations').

traitement(symptome(dyspnée), 'défibrillateur') :-
    write('Défibrillateur recommandé en cas de tachyarythmie ventriculaire avec dyspnée').

traitement(symptome(syncope), 'défibrillateur') :-
    write('Défibrillateur recommandé en cas de syncope liée à une tachyarythmie ventriculaire').

% Interprétation de lECG : Fréquence cardiaque, Ondes P, Complexe QRS
interpretation_ecg(frequence(Frequence), onde_P(RegP), complexe_QRS(RegQRS)) :-
    (Frequence < 60 -> write('Bradyarythmie détectée'));
    (Frequence > 100 -> write('Tachyarythmie détectée'));
    (RegP == 'normal' -> write('Onde P régulière'));
    (RegQRS == 'normal' -> write('Complexe QRS normal'));
    (RegP == 'anormal' -> write('Onde P anormale'));
    (RegQRS == 'anormal' -> write('Complexe QRS anormal')).
    