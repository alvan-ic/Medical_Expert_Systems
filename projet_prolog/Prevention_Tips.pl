% Faits : Conseils associés aux facteurs de risque
advice(smoking, "Arrêter de fumer immédiatement pour réduire les risques cardiovasculaires. Consultez un spécialiste pour un programme d'arrêt.").
advice(hypertension, "Réduisez votre consommation de sel et consultez un médecin pour gérer votre pression artérielle.").
advice(high_cholesterol, "Adoptez un régime faible en graisses saturées et en cholestérol. Faites un bilan lipidique régulier.").
advice(diabetes, "Maintenez un contrôle strict de votre glycémie avec une alimentation saine et des médicaments si nécessaire.").
advice(obesity, "Essayez de perdre du poids en combinant une alimentation équilibrée et une activité physique régulière.").
advice(sedentary_lifestyle, "Augmentez votre activité physique. Même 30 minutes de marche par jour peuvent faire une grande différence.").
advice(unhealthy_diet, "Améliorez votre alimentation en consommant plus de fruits, légumes et fibres. Évitez les aliments transformés.").
advice(alcohol, "Réduisez votre consommation d'alcool à des niveaux modérés pour éviter les effets néfastes sur la santé.").
advice(stress, "Gérez votre stress avec des techniques comme la méditation, la respiration profonde ou une thérapie.").
advice(age, "Surveillez régulièrement votre santé, surtout si vous avez plus de 45 ans (hommes) ou 55 ans (femmes).").
advice(family_history, "Si vous avez des antécédents familiaux, consultez régulièrement un cardiologue pour des bilans de prévention.").
advice(menopause, "Après la ménopause, surveillez votre santé cardiovasculaire avec des bilans réguliers.").
advice(birth_control, "Si vous utilisez des contraceptifs hormonaux, consultez votre médecin pour évaluer les risques cardiovasculaires.").
advice(salt_intake, "Réduisez votre consommation de sel pour éviter l'hypertension artérielle.").
advice(sleep_quality, "Assurez-vous de dormir entre 7 et 9 heures par nuit pour maintenir un cœur en bonne santé.").

% Faits : Conseils généraux pour tous les utilisateurs
general_advice("Adoptez une alimentation riche en fruits, légumes, grains entiers et poissons gras.").
general_advice("Pratiquez une activité physique régulière : au moins 150 minutes d'exercice modéré par semaine.").
general_advice("Effectuez des bilans de santé réguliers pour surveiller votre tension artérielle, votre cholestérol et votre glycémie.").

% Règle : Donner des conseils personnalisés en fonction des facteurs de risque
give_personalized_advice :-
	findall(Factor,
		(user_data(Factor, yes, _)),
		RiskFactors),
	write("Voici vos conseils personnalisés pour réduire votre risque :"),
	nl,
	display_advice(RiskFactors),
	write("Conseils généraux pour préserver votre santé cardiovasculaire :"),
	nl,
	display_general_advice.

% Afficher les conseils personnalisés
display_advice([]).
display_advice([Factor|Rest]) :-
	advice(Factor, Advice),
	format("- ~w~n", [Advice]),
	display_advice(Rest).

% Afficher les conseils généraux
display_general_advice :-
	findall(Advice,
		general_advice(Advice),
		GeneralAdvices),
	display_general_list(GeneralAdvices).
display_general_list([]).
display_general_list([Advice|Rest]) :-
	format("- ~w~n", [Advice]),
	display_general_list(Rest).

% Exemple : Base de données utilisateur
% Pour tester, vous pouvez simuler les réponses des utilisateurs avec ces faits :
user_data(smoking, yes, 7).
user_data(high_cholesterol, yes, 5).
user_data(stress, yes, 6).
user_data(sedentary_lifestyle, no, 0).

% Exemple de requête
% ?- give_personalized_advice.
