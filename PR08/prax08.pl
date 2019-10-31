:- dynamic node/1, startNode/1.

% is_a(SubClass, Class).
is_a(roovloomad,elusolend).
is_a(mitte-roovloomad,elusolend).
is_a(veeimetajad,roovloomad).
is_a(kalad,roovloomad).
is_a(saarmas,veeimetajad).
is_a(kobras,veeimetajad).
is_a(ahven,kalad).
is_a(haug,kalad).
is_a(zooplankton,mitte-roovloomad).
is_a(veetaimed,mitte-roovloomad).
is_a(vesikatk,veetaimed).
is_a(vetikas,veetaimed).

% eats(Who, Whom).
eats(zooplankton,veetaimed).
eats(kalad,zooplankton).
eats(veeimetajad,kalad).

get_to_terminal(Node, _) :-
    not(is_a(_, Node)),
    asserta(node(Node)),
    fail.
get_to_terminal(Node, Terminal) :-
    is_a(NonTerminal, Node),
    get_to_terminal(NonTerminal, Terminal).

% count_terminals(Node,Terminals,Count)
count_terminals(Node, _, _) :-
    get_to_terminal(Node, _).
count_terminals(_, Terminals, Count) :-
    bagof(Terminal, node(Terminal), Terminals),
    length(Terminals, Count),
    retractall(node(_)).

get_to_terminal_with_eats(Node, _) :-
    not(is_a(_, Node)),
    asserta(node(Node)),
    eats(Something, Node),
    asserta(startNode(Something)),
    fail.
get_to_terminal_with_eats(Node, Terminal) :-
    is_a(NonTerminal, Node),
    (eats(Something, Node), asserta(startNode(Something)), get_to_terminal(NonTerminal, Terminal);
    not(eats(_, Node)), get_to_terminal_with_eats(NonTerminal, Terminal)).

% extinction(Who,What_spieces,How_many)
extinction(Who, _, _) :-
    not(startNode(_)),
    get_to_terminal_with_eats(Who, _).
extinction(_, _, _) :-
    startNode(X),
    write(X), nl,
    retract(startNode(X)),
    get_to_terminal_with_eats(X, _), fail.
extinction(_, _, _) :-
    startNode(X),
    write(X), nl, nl,
    retract(startNode(X)),
    get_to_terminal_with_eats(X, _), fail.
extinction(_, Terminals, Count) :-
    bagof(Terminal, node(Terminal), Terminals),
    length(Terminals, Count),
    retractall(node(_)).


