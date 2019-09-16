% declarations ------------------------------------------------------------

% mother(laps, ema)

mother(vaano, ulvi).
mother(karl, ulvi).
mother(kirke, ulvi).
mother(henri, ulvi).
mother(timo, silja).
mother(laura, silja).
mother(kristel, lea).
mother(merlin, lea).
mother(karol, lea).
mother(ulvi, leida).
mother(silja, leida).
mother(leida, vanem_leida).
mother(lea, leida).
mother(mari2, mari1).
mother(mari3, mari1).
mother(juku1, mari1).
mother(mari1, mari0).

% married(F, M)

married(ulvi, neeme).
married(silja, olev).
married(lea, andrus).
married(mari0, juku0).
married(vanem_leida, male_leida2).

% female(keegi)

female(kirke).
female(laura).
female(kristel).
female(merlin).
female(karol).
female(ulvi).
female(silja).
female(lea).
female(leida).
female(mari0).
female(mari1).
female(mari2).

% male(keegi)

male(karl).
male(male_leida2)
male(timo).
male(henri).
male(vaano).
male(juku1).
male(juku0).
male(andrus).
male(olev).
male(neeme).

% simple rules ---------------------------

% get siblings
mother_children(Me) :-
    mother(Me, Mother),
    mother(Sibling, Mother), Sibling \= Me, write(Sibling), nl,
    fail.
mother_children(_) :-
    write("My mother has no more other children.").

% father(me, father)
father(Me, Father) :-
    mother(Me, Mother),
    married(Mother, Father).

% brother(me, brother)
brother(Me, Sibling) :-
    mother(Me, Mother),
    mother(Sibling, Mother),
    Sibling \= Me,
    male(Sibling).

% sister(me, sister)
sister(Me, Sibling) :-
    mother(Me, Mother),
    mother(Sibling, Mother),
    Sibling \= Me,
    female(Sibling).

% aunt(me, aunt)
aunt(Me, Aunt) :-
    (mother(Me, Parent) ; father(Me, Parent)),
    sister(Parent, Aunt).

% uncle(me, uncle)
uncle(Me, Uncle) :-
    (mother(Me, Parent) ; father(Me, Parent)),
    brother(Parent, Uncle).

% grandfather(me, grandfather)
grandfather(Me, Grandfather) :-
    (mother(Me, Parent) ; father(Me, Parent)),
    father(Parent, Grandfather).

% grandmother(me, grandmother)
grandmother(Me, Grandmother) :-
    (mother(Me, Parent) ; father(Me, Parent)),
    mother(Parent, Grandmother).

% new rules -------------------------

% ancestor(me, ancestor)
ancestor(Me, Ancestor) :- (father(Me, Ancestor); mother(Me, Ancestor)).
ancestor(Me, Ancestor) :- (mother(Me, Parent); father(Me, Parent)),
                            ancestor(Parent, Ancestor).

% male_ancestor(me, ancestor)
male_ancestor(Me, Male_ancestor) :- father(Me, Male_ancestor).
male_ancestor(Me, Ancestor) :- (mother(Me, Parent); father(Me, Parent)),
                               male_ancestor(Parent, Ancestor).

% female_ancestor(me, ancestor)
female_ancestor(Me, Female_ancestor) :- mother(Me, Female_ancestor).
female_ancestor(Me, Ancestor) :- (mother(Me, Parent); father(Me, Parent)),
                               female_ancestor(Parent, Ancestor).

% ancestor1(Child, Parent, N).
ancestor1(Me, Ancestor, N) :- N == 1, (father(Me, Ancestor); mother(Me, Ancestor)).
ancestor1(Me, Ancestor, N) :- (father(Me, Parent); mother(Me, Parent)),
                                ancestor1(Parent, Ancestor, X).