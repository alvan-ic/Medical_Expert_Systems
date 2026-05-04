% chatbot.pl
salutation(bonjour).
salutation(salut).
repondre(X) :-
	salutation(X),
	write('Bonjour! Comment puis-je vous aider?').
repondre(_) :-
	write('Désolé, je ne comprends pas cette question.').