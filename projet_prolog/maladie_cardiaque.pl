% Faits
bradycardie(symptomatique).
frequence(<40).
pause(plus_de_3s).
bloc_av(degre_2).
bloc_av(degre_3).

% Règles pour déterminer si un pacemaker est nécessaire
besoin_pacemaker(symptomatique, <40, plus_de_3s) :- 
    bradycardie(symptomatique),
    frequence(<40),
    pause(plus_de_3s).

besoin_pacemaker(degre_2, besoin_pacemaker) :- 
    bloc_av(degre_2).

besoin_pacemaker(degre_3, besoin_pacemaker) :- 
    bloc_av(degre_3).
