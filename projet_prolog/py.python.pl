from pyswip import Prolog

# Création d'un moteur Prolog
prolog = Prolog()

# Définir des faits et des règles en Prolog
prolog.assertz("blocage_noeud_sinusal(complete)")
prolog.assertz("arret_sinusal(ECG_surface)")
prolog.assertz("rythme_echappement(jonctionnel, 40_60)")
prolog.assertz("rythme_echappement(ventriculaire, bas)")
prolog.assertz("syncope")

# Causes de bradycardie et besoin de pacemaker
prolog.assertz("cause_bradcardie(sinusale, tonicite_vagale)")
prolog.assertz("cause_bradcardie(sinusale, dysfonction_sinusale)")
prolog.assertz("cause_bradcardie(sinusale, medicament)")
prolog.assertz("besoin_pacemaker(symptomatique)")

# Bloc AV
prolog.assertz("bloc_av(degre_1, intervalle_PQ_prolonge(200))")
prolog.assertz("bloc_av(degre_2, mobitz_I)")
prolog.assertz("bloc_av(degre_2, mobitz_II)")
prolog.assertz("bloc_av(degre_3, complet)")
prolog.assertz("bloc_av(degre_2, besoin_pacemaker)")
prolog.assertz("bloc_av(degre_3, besoin_pacemaker)")

# Règles concernant l'indication de pacemaker
prolog.assertz("""
besoin_pacemaker(sinon, bradycardie) :-
    bradycardie(symptomatique),
    frequence(<40),
    pause > 3.
""")

# Requêtes pour tester les faits et règles

# Exemple de requête : savoir si un pacemaker est nécessaire pour un cas de bradycardie
result = list(prolog.query("besoin_pacemaker(sinon, bradycardie)"))
print("Besoin pacemaker pour bradycardie :", result)

# Exemple de requête : savoir si un pacemaker est nécessaire pour un bloc AV
result = list(prolog.query("besoin_pacemaker(av)"))
print("Besoin pacemaker pour bloc AV :", result)

# Exemple de requête pour un bloc trifasciculaire incomplet avec syncopes
result = list(prolog.query("besoin_pacemaker(trifasciculaire)"))
print("Besoin pacemaker pour bloc trifasciculaire incomplet :", result)
