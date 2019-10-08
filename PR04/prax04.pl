:- dynamic visited/1.
:- dynamic goal/1.

laevaga(tallinn, helsinki, 120).
laevaga(tallinn, stockholm, 480).
laevaga(helsiki, stockholm, 120).

bussiga(tallinn, riia, 300).

rongiga(riia, berlin, 680).

lennukiga(tallinn, helsinki, 30).
lennukiga(helsinki, paris, 180).
lennukiga(paris, berlin, 120).
lennukiga(paris, tallinn, 120).


canReisi(From, To, With, Time) :-
    (laevaga(From, To, Time) ; laevaga(To, From, Time)), With = laevaga;
    (bussiga(From, To, Time) ; bussiga(To, From, Time)), With = bussiga;
    (rongiga(From, To, Time) ; rongiga(To, From, Time)), With = rongiga;
    (lennukiga(From, To, Time) ; lennukiga(To, From, Time)), With = lennukiga.

getPath(From, To, Visited, Path, PathMethod, Times) :-
    not(member(To, Visited)),
    canReisi(From, To, With, Time),
    Path = [To],
    PathMethod = [With],
    Times = [Time].
getPath(From, To, Visited, Path, PathMethod, Times) :-
    append([Next], Visited, NewVisited),
    append([Next], SmallerPath, Path),
    canReisi(From, Next, With, Time),
    append([With], SmallerPathMethod, PathMethod),
    append([Time], SmallerTimes, Times),
    not(member(Next, Visited)),
    getPath(Next, To, NewVisited, SmallerPath, SmallerPathMethod, SmallerTimes).


mineConstructor([E1, E2 | []], Result) :-
    Result = mine(E1, E2).
mineConstructor([E1, E2 | T], Result) :-
    mineConstructor([E2 | T], TailResult),
    Result = mine(E1, E2, TailResult).

mineConstructor([E1, E2 | []], [M | []], Result) :-
    Result = mine(E1, E2, M).
mineConstructor([E1, E2 | T], [M | MT], Result) :-
    mineConstructor([E2 | T], MT, SmallerResult),
    Result = mine(E1, E2, M, SmallerResult).

reisi(From, To) :-
    getPath(From, To, [From], _, _, _),
    !.

reisi(From, To, MinePath) :-
    getPath(From, To, [From], Path, _, _),
    mineConstructor([From | Path], MinePath).

reisi_transpordiga(From, To, MineTransportPath) :-
    getPath(From, To, [From], Path, PathMethod, _),
    mineConstructor([From | Path], PathMethod, MineTransportPath).

reisi(From, To, MinePath, Cost) :-
    getPath(From, To, [From], Path, PathMethod, Times),
    mineConstructor([From | Path], PathMethod, MinePath),
    sum_list(Times, Cost).

