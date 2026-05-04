% Informations générales sur linsuffisance cardiaque
insuffisance_cardiaque(canadiens, 500000).
insuffisance_cardiaque_definition("Faiblesse du coeur a pomper le sang adequatement").
symptome(insuffisance_cardiaque, respiration_courte).
symptome(insuffisance_cardiaque, enflure).
symptome(insuffisance_cardiaque, fatigue).
symptome(insuffisance_cardiaque, gain_de_poids).

% Fonctionnement du coeur
coeur(pompe_sang).
composant_coeur(ventricule_droit).
composant_coeur(ventricule_gauche).
composant_coeur(arteres).
composant_coeur(valves).

% Fonctionnement des ventricules
fonction(ventricule_droit, "pompe_sang_vers_poumons").
fonction(ventricule_gauche, "pompe_sang_vers_corps").

% Circulation du sang
circulation(sang, va_vers(ventricule_droit, poumons)).
circulation(sang, va_vers(poumons, ventricule_gauche)).
circulation(sang, va_vers(ventricule_gauche, corps)).

% Informations sur les valves et leur rôle
valve(tricuspidienne).
valve(pulmonaire).
valve(aortique).
valve(mitrale).
fonction_valve(valve, controle_flux_sang).

% Arteres coronaires et leur rôle
fonction_artere(coronaire, "apport_sang_riche_oxygene_vers_coeur").
obstruction_artere(coronaire, accumulation_gras).

% Cellules électriques et battements cardiaques
cellules_electriques(coeur).
fonction(cellules_electriques, coordonner_battements).

% Fraction déjection
fraction_ejection(normale, 50_60).
fraction_ejection(faible, moins_de_40).

% Une personne a de linsuffisance cardiaque si son ventricule gauche est faible et quil y a des symptômes associés.
a_insuffisance_cardiaque(Personne) :-
    fonction(ventricule_gauche, faible),
    symptome(insuffisance_cardiaque, _).

% Le ventricule gauche est considéré comme faible si la fraction déjection est inférieure à 40 %
ventricule_gauche_faible :-
    fraction_ejection(faible, moins_de_40).

% Les symptômes de l insuffisance cardiaque
symptomes_insuffisance_cardiaque :-
    symptome(insuffisance_cardiaque, respiration_courte),
    symptome(insuffisance_cardiaque, enflure),
    symptome(insuffisance_cardiaque, fatigue),
    symptome(insuffisance_cardiaque, gain_de_poids).

% Si les artères coronaires sont obstruées, cela peut causer une insuffisance cardiaque
cause_insuffisance_cardiaque :-
    obstruction_artere(coronaire, accumulation_gras).

% Les valves empêchent le reflux de sang
flux_normal :-
    valve(tricuspidienne),
    valve(pulmonaire),
    valve(aortique),
    valve(mitrale),
    fonction_valve(valve, controle_flux_sang).

% Faits décrivant les symptômes
symptome(gain_de_poids).
symptome(difficulte_a_respirer).
symptome(respiration_nuit).
symptome(enflure_pieds_chevilles).
symptome(manque_d_energie).

% Faits décrivant les causes
cause(arteres_bloquees).
cause(tension_arterielle_elevee).
cause(diabete).
cause(drogues_alcool).
cause(regurgitation_valvulaire).
cause(infection_cardiaque).
cause(antecedents_familiaux).

% Faits décrivant les effets des hormones
effet_hormone(augmentation_rythme_cardiaque).
effet_hormone(retrécissement_arteres).
effet_hormone(retention_sel_eau).
effet_hormone(augmentation_taille_coeur).

% Règles pour déterminer les symptômes de linsuffisance cardiaque
insuffisance_cardiaque(S) :-
    symptome(S),
    member(S, [gain_de_poids, difficulte_a_respirer, respiration_nuit, enflure_pieds_chevilles, manque_d_energie]).

% Règle pour déterminer les causes d’insuffisance cardiaque
cause_insuffisance_cardiaque(C) :-
    cause(C),
    member(C, [arteres_bloquees, tension_arterielle_elevee, diabete, drogues_alcool, regurgitation_valvulaire, infection_cardiaque, antecedents_familiaux]).

% Règles pour prévention des symptômes
prevention(medicaments) :-
    write('Prenez vos médicaments pour le cœur régulièrement').

prevention(pesée_quotidienne) :-
    write('Pesez-vous chaque jour pour détecter tout gain de poids rapide').

% Exemple de requête :
% ?- insuffisance_cardiaque(X).
% Cela retournera les symptômes listés pour l’insuffisance cardiaque.

% ?- cause_insuffisance_cardiaque(Y).
% Cela retournera les causes listées pour l’insuffisance cardiaque.

% ?- prevention(X).
% Affichera les conseils de prévention pour éviter les symptômes.

% Faits décrivant les recommandations de gestion du poids
peser_matinal(conseil).
appeler_infirmiere(prendre_plus_3_livres_3_jours).
noter_poids(journal_quotidien).

% Règle pour savoir quand se peser
moment_optimal_peser(matinal) :-
    write('Le meilleur moment pour vous peser est le matin dès que vous vous levez. Allez d\'abord à la salle de bains et videz votre vessie, puis montez sur la balance sans vêtements si possible.').

alerte_gain_de_poids(X) :- 
    X >= 1, 
    write('Appelez votre infirmière si vous prenez plus de 1 kg en trois jours ou 2 kg en une semaine.').

% Recommandation pour noter le poids chaque jour
notez_poids :-
    write('Notez votre poids chaque jour dans un tableau et apportez-le lors de visites à la clinique.').

% Recommandations pour limiter la consommation de liquides
limiter_liquides(X) :- 
    X =< 1.5, 
    write('Vous ne devriez pas boire plus de 1.5 litres de liquide par jour.').

% Représentation des liquides à limiter
liquide(eau).
liquide(cafe).
liquide(the).
liquide(jus).
liquide(lait).
liquide(boisson_gazeuse).
liquide(soupe).
liquide(creme_glacee).
liquide(jello).
liquide(popsicle).
liquide(sauce).
liquide(boisson_alcoolisee).
liquide(supplement_repas).
liquide(melon_deau).

% Règles pour limiter la consommation de sel
limiter_sel(quantite_maximale) :-
    quantite_maximale =< 2000,
    write('Consommez moins de 2000 mg de sodium par jour, soit environ une demi-cuillère à thé.').

conseil_sel(evitement) :-
    write('Évitez les aliments transformés, en conserve et n\'utilisez pas de sel en cuisinant.').

conseil_lecture_etiquettes :-
    write('Lisez les étiquettes et évitez les produits contenant le mot sodium.').

% Recommandations pour un régime sain
regime_sain :-
    write('Mangez moins de viande rouge, plus de poisson et de volaille, et augmentez les fibres avec des grains entiers, des légumineuses, fruits et légumes.').

% Règles pour arrêter de fumer
arreter_de_fumer :-
    write('Fumer rétrécit les artères et force le cœur. Rejoignez un programme antitabac si besoin.').

% Règles pour limiter la consommation d’alcool
limiter_alcool :-
    write('Réduisez ou arrêtez l\'alcool pour éviter les dommages au cœur et au foie. Rejoignez un programme de soutien si besoin.').

% Règles pour l’exercice
exercice(30_minutes_par_jour) :-
    write('Faites de l\'exercice au moins 30 minutes par jour. Choisissez une activité que vous aimez comme la marche, la natation ou le vélo.').

exercice_arret :-
    write('Arrêtez si vous vous sentez essoufflé, avez des douleurs à la poitrine ou des vertiges.').

% Règles pour les soins dentaires
soins_dentaires :-
    write('Prenez soin de vos dents et informez votre dentiste de votre insuffisance cardiaque pour éviter les infections.').

% Règles pour la vaccination
vaccination(grippe_pneumonie) :-
    write('Faites-vous vacciner contre la grippe chaque année et demandez un vaccin contre la pneumonie si nécessaire.').

% Règles pour l’activité sexuelle
activite_sexuelle :-
    write('Gardez une activité sexuelle épanouie mais modérée. Parlez à votre partenaire, choisissez un moment calme et évitez les relations après un repas.').

% Faits pour le voyage
voyage_possible(Patient) :-
    etat_coeur_stable(Patient),
    assurance_voyage(Patient),
    vaccinations_a_jour(Patient),
    eau_embouteillee(Patient),
    liste_medicaments(Patient),
    copie_carnet_sante(Patient),
    medicaments_suffisants(Patient).

etat_coeur_stable(Patient) :-
    stable_depuis(Patient, Mois),
    Mois >= 6.

assurance_voyage(Patient) :-
    verifie_assurance(Patient).

vaccinations_a_jour(Patient) :-
    contacte_clinique_voyage(Patient).

eau_embouteillee(Patient).

liste_medicaments(Patient).

copie_carnet_sante(Patient).

medicaments_suffisants(Patient).

% Règles pour le voyage
eviter_voyage(Patient) :-
    hospitalise_recemment(Patient);
    changement_medicament(Patient).

verifie_assurance(Patient) :-
    verifie_avec_compagnie_assurance(Patient).

% Faits sur le traitement de linsuffisance cardiaque
traitement_combinaison(Patient, [pilules, appareils_implantables, chirurgie]) :-
    insuffisance_cardiaque(Patient).

traitement_buts(Patient, [reduction_symptomes, eviter_hospitalisation, prolonger_vie]) :-
    insuffisance_cardiaque(Patient).

% Règles de traitement
utiliser_pilules(Patient) :-
    insuffisance_cardiaque(Patient),
    reduire_symptomes(Patient).

utiliser_appareil_implantable(Patient) :-
    coeur_bat_irregulier(Patient).

priviligier_chirurgie(Patient) :-
    arteres_bloquees(Patient);
    valves_defectueuses(Patient).

% Faits sur les medicaments et leurs effets
diuretiques(Patient) :-
    aide_elimination_eau_sel(Patient),
    effets_secondaires(Patient, [affaiblissement_reins]).

beta_bloquants(Patient) :-
    ralentit_coeur(Patient),
    effets_secondaires(Patient, [etourdissements, fatigue]).

inhibiteurs_ECA(Patient) :-
    dilate_vaisseaux(Patient),
    abaisse_tension(Patient),
    effets_secondaires(Patient, [augmentation_potassium]).

antiarythmiques(Patient) :-
    regularise_rythme(Patient),
    effets_secondaires(Patient, [problemes_thyroide, problemes_poumons, vue_embrouillee]).

statines(Patient) :-
    reduit_cholesterol(Patient),
    effets_secondaires(Patient, [douleurs_musculaires, surcharge_foie]).

% Règles pour les medicaments
ajouter_pilules_potassium(Patient) :-
    sous_diuretiques(Patient),
    faible_potassium(Patient).

surveiller_potassium(Patient) :-
    sous_diuretiques(Patient);
    sous_inhibiteurs_ECA(Patient).

consulter_medecin_si_effets_visuels(Patient) :-
    sous_digitaliques(Patient),
    effets_visuels_anormaux(Patient).

eviter_exposition_soleil(Patient) :-
    sous_amiodarone(Patient),
    couleur_bleue_peau(Patient).

    % Conditions pour pouvoir voyager
peut_voyager(EtatCoeur, Hospitalisation, ChangementMedicaments) :-
    EtatCoeur = stable,
    Hospitalisation = non,
    ChangementMedicaments = non.

% Conseils de voyage
conseil_voyage(vaccinations).
conseil_voyage(eau_embouteillee).
conseil_voyage(liste_medicaments).
conseil_voyage(medicaments_suffisants).

% Types de traitements pour insuffisance cardiaque
traitement_insuffisance(pilules).
traitement_insuffisance(appareil_implante).
traitement_insuffisance(chirurgie).

% Objectifs des traitements
objectif_traitement(traiter_cause).
objectif_traitement(reduire_symptomes).
objectif_traitement(ameliorer_qualite_de_vie).
objectif_traitement(prolonger_vie).

% Types de medicaments
medicament(diuretique).
medicament(beta_bloquant).
medicament(iec).
medicament(ara).
medicament(antiarythmique).
medicament(digitalique).
medicament(statine).

% Effets des medicaments sur le cœur
effet_med(diuretique, soulage_symptomes).
effet_med(beta_bloquant, ralenti_rythme_cardiaque).
effet_med(iec, abaisse_tension).
effet_med(ara, effets_iec).
effet_med(antiarythmique, stabilise_rythme).
effet_med(digitalique, renforce_pompage).
effet_med(statine, baisse_cholesterol).

% Effets secondaires principaux des medicaments
effet_secondaire(diuretique, fatigue).
effet_secondaire(beta_bloquant, etourdissement).
effet_secondaire(iec, toux).
effet_secondaire(ara, effets_secondaires_iec).
effet_secondaire(antiarythmique, faiblesse).
effet_secondaire(digitalique, nausée).
effet_secondaire(statine, douleurs_musculaires).

% Appareils implantables et leurs effets
appareil(stimulateur_cardiaque, ralentit_rythme).
appareil(dci, regulateur_rythme).
appareil(resynchronisation_cardiaque, synchronise_rythme).

% Autres traitements
autre_traitement(recherche).
autre_traitement(coeur_mecanique).
autre_traitement(transplantation_cardiaque).

