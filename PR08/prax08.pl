:- dynamic node/1, visited/1, deathOption/3.

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
    not(visited(Node)),
    asserta(visited(Node)),
    asserta(node(Node)),
    eats(Something, Node),
    get_to_terminal_with_eats(Something, _),
    fail.
get_to_terminal_with_eats(Node, Terminal) :-
    not(visited(Node)),
    asserta(visited(Node)),
    is_a(NonTerminal, Node),
        (eats(Something, Node),
            (get_to_terminal_with_eats(Something, _) ; true),
        get_to_terminal(NonTerminal, Terminal);
        not(eats(_, Node)), get_to_terminal_with_eats(NonTerminal, Terminal)).

% extinction(Who,What_spieces,How_many)
extinction(Who, _, _) :-
    get_to_terminal_with_eats(Who, _).
extinction(_, Terminals, Count) :-
    bagof(Terminal, node(Terminal), Terminals),
    length(Terminals, Count),
    retractall(node(_)),
    retractall(visited(_)).

% find_most_sensitive_species(L, C, T).
find_most_sensitive_species(_, _, _) :-
    retractall(deathOption(_, _, _)), fail.
find_most_sensitive_species(_, _, _) :-
    eats(_, Node),
    extinction(Node, Terminals, Count),
        (not(deathOption(_, _, _)), asserta(deathOption(Node, Terminals, Count)) ;
        deathOption(_, _, CurCount), Count == max(CurCount, Count),
            (Count == CurCount, asserta(deathOption(Node, Terminals, Count)) ;
            Count \= CurCount, retractall(deathOption(_, _, _)), asserta(deathOption(Node, Terminals, Count)))
        ),
    fail.
find_most_sensitive_species(L, C, T) :-
    deathOption(L, T, C).
