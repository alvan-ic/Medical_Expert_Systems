p(X, Y) :- number(X), number(Y).

distance(p(X1, Y1), p(X2, Y2), D) :-
    D is sqrt((X2 - X1) ** 2 + (Y2 - Y1) ** 2).

cout([_], 0).
cout([p(X1, Y1), p(X2, Y2) | Rest], C) :-
    distance(p(X1, Y1), p(X2, Y2), D),
    cout([p(X2, Y2) | Rest], RestC),
    C is D + RestC.

% Définir la distance entre deux points (par exemple, p(X1, Y1) et p(X2, Y2))
distance(p(X1, Y1), p(X2, Y2), D) :-
    D is sqrt((X2 - X1)^2 + (Y2 - Y1)^2).



ppv(_, [], none).  % Aucun point dans la liste.
ppv(P1, [P | Rest], P) :-
    distance(P1, P, D),
    \+ member(P1, [P]),  % Assurez-vous que P1 nest pas dans la liste.
    ppv(P1, Rest, P2),
    (   P2 == none -> true ; 
        distance(P1, P2, D2), D < D2
    ).
ppv(P1, [P | Rest], P2) :-
    ppv(P1, Rest, P2),
    \+ (distance(P1, P, D), distance(P1, P2, D2), D >= D2).



