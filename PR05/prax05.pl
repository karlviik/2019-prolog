:- dynamic hourconstraint/0.
laevaga/5-laevaga(Kust, Kuhu, Pileti_hind, Väljumise_aeg, Saabumise_aeg).
bussiga/5-bussiga(Kust, Kuhu, Pileti_hind, Väljumise_aeg, Saabumise_aeg).
rongiga/5-rongiga(Kust, Kuhu, Pileti_hind, Väljumise_aeg, Saabumise_aeg).
lennukiga/5-lennukiga(Kust, Kuhu, Pileti_hind, Väljumise_aeg, Saabmise_aeg).
laevaga(tallinn, helsinki, 120, time(1, 2, 3.0), time(12, 4, 1.0)).
laevaga(tallinn, stockholm, 480, time(1, 2, 3.0), time(12, 4, 1.0)).
laevaga(helsiki, stockholm, 120, time(1, 2, 3.0), time(12, 4, 1.0)).

bussiga(tallinn, riia, 300, time(1, 2, 3.0), time(12, 4, 1.0)).

rongiga(riia, berlin, 680, time(1, 2, 3.0), time(12, 4, 1.0)).

lennukiga(tallinn, helsinki, 30, time(1, 2, 3.0), time(12, 4, 1.0)).
lennukiga(helsinki, paris, 180, time(1, 2, 3.0), time(12, 4, 1.0)).
lennukiga(paris, berlin, 120, time(1, 2, 3.0), time(12, 4, 1.0)).
lennukiga(paris, tallinn, 120, time(1, 2, 3.0), time(12, 4, 1.0)).


addTime(X, Y, Z) :-
    X = time(H1, M1, S1),
    Y = time(H2, M2, S2),
    S3 is S1 + S2,
    M3 is M1 + M2,
    H3 is H1 + H2,
    (S3 >= 60.0, S4 is S3 - 60.0, M4 is M3 + 1 ; S3 < 60.0, S4 is S3, M4 is M3),
    (M4 >= 60, M5 is M4 - 60, H4 is H3 + 1 ; M4 < 60, M5 is M4, H4 is H3),
    Z = time(H4, M5, S4).
% substract Y from X, requires X to be the bigger one.
substractTime(X, Y, Z) :-
    X = time(H1, M1, S1),
    Y = time(H2, M2, S2),
    S3 is S1 - S2,
    M3 is M1 - M2,
    H3 is H1 - H2,
    (S3 < 0.0, S4 is S3 + 60.0, M4 is M3 - 1 ; S3 >= 0.0, S4 is S3, M4 is M3),
    (M4 < 0, M5 is M4 + 60, H4 is H3 - 1 ; M4 > 0, M5 is M4, H4 is H3),
    (H4 < 0, H5 is H4 + 24; H4 > 0, H5 is H4),
    Z = time(H5, M5, S4).
% checks if can travel between From and To
canReisi(From, To, With, Cost, Departure, Arrival) :-
    (laevaga(From, To, Cost, Departure, Arrival) ; laevaga(To, From, Cost, Departure, Arrival)), With = laevaga;
    (bussiga(From, To, Cost, Departure, Arrival) ; bussiga(To, From, Cost, Departure, Arrival)), With = bussiga;
    (rongiga(From, To, Cost, Departure, Arrival) ; rongiga(To, From, Cost, Departure, Arrival)), With = rongiga;
    (lennukiga(From, To, Cost, Departure, Arrival) ; lennukiga(To, From, Cost, Departure, Arrival)), With = lennukiga.

% end condition for getPath. If can travel between the positions and To hasn't been visited,
% unify Path, Pathmethod and Times with corresponding values.
getPath(From, To, PreviousArrival, Visited, Path, PathMethod, Costs, TotalTime) :-
    not(member(To, Visited)),
    canReisi(From, To, With, Cost, Departure, Arrival),
    Path = [To],
    PathMethod = [With],
    Costs = [Cost],
    substractTime(Arrival, Departure, Duration),
    ((not(hourconstraint) ; hourconstraint, PreviousArrival == false) , TotalTime = Duration ;
    hourconstraint, substractTime(Departure, PreviousArrival, time(Hours, Mins, Secs)), Hours >= 1, addTime(Duration, time(Hours, Mins, Secs), DurationWithWaiting), TotalTime = DurationWithWaiting).
% recursive. Picks Next so that there is a direct connection between them, unifies it to Visited list, Path list,
% method list and time lists from the inner recursion.
getPath(From, To, PreviousArrival, Visited, Path, PathMethod, Costs, TotalTime) :-
    append([Next], Visited, NewVisited),
    append([Next], SmallerPath, Path),
    canReisi(From, Next, With, Cost, Departure, Arrival),
    substractTime(Arrival, Departure, Duration),
    ((not(hourconstraint) ; hourconstraint, PreviousArrival == false) , AddDuration = Duration ;
    hourconstraint, substractTime(Departure, PreviousArrival, time(Hours, Mins, Secs)), Hours >= 1, addTime(Duration, time(Hours, Mins, Secs), AddDuration)),

    append([With], SmallerPathMethod, PathMethod),
    append([Cost], SmallerCosts, Costs),
    not(member(Next, Visited)),
    getPath(Next, To, Arrival, NewVisited, SmallerPath, SmallerPathMethod, SmallerCosts, SmallerTotalTime),
    addTime(AddDuration, SmallerTotalTime, TotalTime).

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
    getPath(From, To, false, [From], _, _, _, _),
    !.

reisi(From, To, MinePath) :-
    getPath(From, To, false, [From], Path, _, _, _),
    mineConstructor([From | Path], MinePath).

reisi(From, To, MinePath, Cost) :-
    getPath(From, To, false, [From], Path, PathMethod, Costs, _),
    mineConstructor([From | Path], PathMethod, MinePath),
    sum_list(Costs, Cost).

reisi(From, To, MinePath, Cost, Time) :-
    getPath(From, To, false, [From], Path, PathMethod, Costs, Time),
    mineConstructor([From | Path], PathMethod, MinePath),
    sum_list(Costs, Cost).

reisi_transpordiga(From, To, MineTransportPath) :-
    getPath(From, To, false, [From], Path, PathMethod, _, _),
    mineConstructor([From | Path], PathMethod, MineTransportPath).

:- dynamic cheapest/2.
odavaim_reis(From, To, _, _) :-
    retractall(cheapest(_, _)),
    reisi(From, To, MinePath, Cost),
    (not(cheapest(_, _)) ; cheapest(X, _), X > Cost),
    retractall(cheapest(X, _, _)),
    asserta(cheapest(Cost, MinePath)),
    fail.
odavaim_reis(_, _, Path, Price) :-
    cheapest(Price, Path).

:- dynamic shortest/3.
lyhim_reis(From, To, _, _) :-
    retractall(shortest(_, _)),
    asserta(hourconstraint),
    reisi(From, To, MinePath, Cost, Time),
    (not(shortest(_, _, _)) ; shortest(X, _, _), substractTime(X, Time, time(H, M, S)), H >= 0, M >= 0, S >= 0),
    retractall(shortest(X, _, _)),
    asserta(shortest(Time, Cost, MinePath)),
    fail.
lyhim_reis(_, _, Path, Price) :-
    retractall(hourconstraint),
    shortest(_, Price, Path).
