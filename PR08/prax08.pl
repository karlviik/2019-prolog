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

get_to_terminal(Node, _) :- % end condition, if does not have any children.
    not(is_a(_, Node)),
    asserta(node(Node)),
    fail.
get_to_terminal(Node, Terminal) :- % has children (or failed), get a child node and go recursive
    is_a(NonTerminal, Node),
    get_to_terminal(NonTerminal, Terminal).

% count_terminals(Node,Terminals,Count)
count_terminals(Node, _, _) :- % get all terminals of the thing thing, this fails
    get_to_terminal(Node, _).
count_terminals(_, Terminals, Count) :-  % count terminals
    bagof(Terminal, node(Terminal), Terminals),
    length(Terminals, Count),
    retractall(node(_)).

get_to_terminal_with_eats(Node, _) :- % end condition-ish
    not(is_a(_, Node)), % there are no children
    not(visited(Node)), % the node has not already been visited
    asserta(visited(Node)), % it's visited
    asserta(node(Node)), % and save it
    eats(Something, Node), % if something eats this node
    get_to_terminal_with_eats(Something, _), % go through the thing with whatever eats this
    fail.
get_to_terminal_with_eats(Node, Terminal) :-
    not(visited(Node)), % if node hasn't been visited
    asserta(visited(Node)), % visited save
    is_a(NonTerminal, Node), % Nonterminal is child of this node
        (eats(Something, Node),  % if something eats current node
            (get_to_terminal_with_eats(Something, _) ; true), % get to terminal with this something or true as it always fails
        get_to_terminal(NonTerminal, Terminal); % and just get its terminals as its children don't have eats rules
        not(eats(_, Node)), get_to_terminal_with_eats(NonTerminal, Terminal)). % or if nothing eats current node, just go in with this one

% extinction(Who,What_spieces,How_many)
extinction(Who, _, _) :-
    get_to_terminal_with_eats(Who, _). % get terminals with eats
extinction(_, Terminals, Count) :- % and count them
    bagof(Terminal, node(Terminal), Terminals),
    length(Terminals, Count),
    retractall(node(_)),
    retractall(visited(_)).

% find_most_sensitive_species(L, C, T).
find_most_sensitive_species(_, _, _) :-
    retractall(deathOption(_, _, _)), fail.
find_most_sensitive_species(_, _, _) :- % for each node that is subject to eating
    eats(_, Node),
    extinction(Node, Terminals, Count), % get how many will die
        (not(deathOption(_, _, _)), asserta(deathOption(Node, Terminals, Count)) ; % and basically save largest
        deathOption(_, _, CurCount), Count == max(CurCount, Count),
            (Count == CurCount, asserta(deathOption(Node, Terminals, Count)) ;
            Count \= CurCount, retractall(deathOption(_, _, _)), asserta(deathOption(Node, Terminals, Count)))
        ),
    fail.
find_most_sensitive_species(L, C, T) :-
    deathOption(L, T, C). % return that largest
