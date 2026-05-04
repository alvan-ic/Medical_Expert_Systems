:- use_module(library(pce)).

demarrer :-
    new(Dialog, dialog('Consultation médicale')),
    new(Label, label(name, 'Avez-vous des symptômes ?')),
    new(ButtonYes, button('Oui', message(@prolog, evaluer, oui))),
    new(ButtonNo, button('Non', message(@prolog, evaluer, non))),
    
    send(Dialog, append, Label),
    send(Dialog, append, ButtonYes),
    send(Dialog, append, ButtonNo),
    
    send(Dialog, open).

evaluer(oui) :-
    new(Dialog2, dialog('Conseil')),
    new(Label2, label(name2, 'Il est recommandé de consulter un médecin.')),
    send(Dialog2, append, Label2),
    send(Dialog2, open).

evaluer(non) :-
    new(Dialog2, dialog('Conseil')),
    new(Label2, label(name2, 'Continuez à surveiller votre santé.')),
    send(Dialog2, append, Label2),
    send(Dialog2, open).