% chatbot.pl
greeting('Bonjour').
greeting('Salut').
response(Input, Output) :-
	greeting(Input),
	Output = 'Comment puis-je vous aider ?'.