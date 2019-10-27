:- dynamic hourconstraint/0.
:- dynamic shortest/3.
:- dynamic cheapest/2.
%:- consult("2019-10-28ish").

mineConstructor([E1, E2 | []], Result) :-
    Result = mine(E1, E2, lennukiga).
mineConstructor([E1, E2 | T], Result) :-
    mineConstructor([E2 | T], SmallerResult),
    Result = mine(E1, E2, lennukiga, SmallerResult).

%addTime(X, Y, Z) :-
%    X = time(H1, M1, S1),
%    Y = time(H2, M2, S2),
%    NewTime is S1 + S2 + (M1 + M2) * 60 + (H1 + H2) * 3600,
%    S3 is NewTime mod 60,
%    NewTimeMins is NewTime // 60,
%    M3 is NewTimeMins mod 60,
%    H3 is NewTimeMins // 60,
%    Z = time(H3, M3, S3).
%substractTime(X, Y, Z) :-
%    X = time(H1, M1, S1),
%    Y = time(H2, M2, S2),
%    NewTime is S1 - S2 + (M1 - M2) * 60 + (H1 - H2) * 3600,
%    (NewTime < 0, NewNewTime is NewTime + 86400 ; NewTime >= 0, NewNewTime is NewTime),
%    S3 is NewNewTime mod 60,
%    NewTimeMins is NewNewTime // 60,
%    M3 is NewTimeMins mod 60,
%    H3 is NewTimeMins // 60,
%    Z = time(H3, M3, S3).

addTime(X, Y, Z) :-
    X = time(H1, M1, S1),
    Y = time(H2, M2, S2),
    S3 is S1 + S2,
    M3 is M1 + M2,
    H3 is H1 + H2,
    (S3 >= 60, S4 is S3 - 60, M4 is M3 + 1 ; S3 < 60.0, S4 is S3, M4 is M3),
    (M4 >= 60, M5 is M4 - 60, H4 is H3 + 1 ; M4 < 60, M5 is M4, H4 is H3),
    Z = time(H4, M5, S4).
% substract Y from X, requires X to be the bigger one, otherwise goes negative.
substractTime(X, Y, Z) :-
    X = time(H1, M1, S1),
    Y = time(H2, M2, S2),
    S3 is S1 - S2,
    M3 is M1 - M2,
    H3 is H1 - H2,
    (S3 < 0, S4 is S3 + 60, M4 is M3 - 1 ; S3 >= 0, S4 is S3, M4 is M3),
    (M4 < 0, M5 is M4 + 60, H4 is H3 - 1 ; M4 >= 0, M5 is M4, H4 is H3),
    (H4 < 0, H5 is H4 + 24 ; H4 >= 0, H5 is H4),
    Z = time(H5, M5, S4).

% end condition for getPath. If can travel between the positions and To hasn't been visited,
% unify Path, Pathmethod and Times with corresponding values.
getQuickestPath(From, To, PreviousArrival, Visited, Path, Cost, CurrentTotalTime, ReturnedTotalTime) :-
    lennukiga(From, To, Cost, Departure, Arrival),
    not(member(To, Visited)),
    substractTime(Arrival, Departure, Duration),
    (
        PreviousArrival == false , ReturnedTotalTime = Duration ;
        substractTime(Departure, PreviousArrival, time(Hours, Mins, Secs)),
        (Hours >= 1, ActualWaitHours = Hours ; Hours < 1 , ActualWaitHours is Hours + 24),
        addTime(Duration, time(ActualWaitHours, Mins, Secs), WaitAndFlight),
        addTime(CurrentTotalTime, WaitAndFlight, ReturnedTotalTime)
    ),
    ReturnedTotalTime = time(A, B, C),
    (not(shortest(_, _, _)) ; shortest(Time, _, _), Time = time(X, Y, Z), (X > A; (X == A, (Y > B; (Y == B, Z > C))))),
    Path = [To].
% recursive. Picks Next so that there is a direct connection between them, unifies it to Visited list, Path list,
% method list and time lists from the inner recursion.
getQuickestPath(From, To, PreviousArrival, Visited, Path, BigCost, CurrentTotalTime, ReturnedTotalTime) :-
    lennukiga(From, Next, FlightCost, Departure, Arrival),
    not(member(Next, Visited)),
    append([Next], Visited, NewVisited),
    substractTime(Arrival, Departure, Duration),
    (
        PreviousArrival == false , NewCurrentTotalTime = Duration ;
        substractTime(Departure, PreviousArrival, time(Hours, Mins, Secs)),
        (Hours >= 1, ActualWaitHours = Hours ; Hours < 1, ActualWaitHours is Hours + 24),
        addTime(Duration, time(ActualWaitHours, Mins, Secs), WaitAndFlight),
        addTime(CurrentTotalTime, WaitAndFlight, NewCurrentTotalTime)
    ),
    NewCurrentTotalTime = time(A, B, C),
    (not(shortest(_, _, _)) ; shortest(Time, _, _), Time = time(X, Y, Z), (X > A; (X == A, (Y > B; (Y == B, Z > C))))),
    getQuickestPath(Next, To, Arrival, NewVisited, SmallerPath, SmallerCost, NewCurrentTotalTime, ReturnedTotalTime),
    append([Next], SmallerPath, Path),
    BigCost is SmallerCost + FlightCost.


% end condition for getPath. If can travel between the positions and To hasn't been visited,
% unify Path, Pathmethod and Times with corresponding values.
getCheapestPath(From, To, Visited, Path, TotalCost, ReturnedCosts) :-
    not(member(To, Visited)),
    lennukiga(From, To, Cost, _, _),
    ReturnedCosts is TotalCost + Cost,
    (not(cheapest(_, _)); cheapest(X, _), X > ReturnedCosts),
    Path = [To].
% recursive. Picks Next so that there is a direct connection between them, unifies it to Visited list, Path list,
% method list and time lists from the inner recursion.
getCheapestPath(From, To, Visited, Path, TotalCost, ReturnedCost) :-
    append([Next], Visited, NewVisited),
    append([Next], SmallerPath, Path),
    lennukiga(From, Next, Cost, _, _),
    NewTotalCost is TotalCost + Cost,
    (not(cheapest(_, _)); cheapest(X, _), X > NewTotalCost),
    not(member(Next, Visited)),
    getCheapestPath(Next, To, NewVisited, SmallerPath, NewTotalCost, ReturnedCost).

odavaim_reis(From, To, _, _) :-
    getCheapestPath(From, To, [From], Path, 0, Cost),
    mineConstructor([From | Path], MinePath),
    retractall(cheapest(_, _)),
    asserta(cheapest(Cost, MinePath)),
    fail.
odavaim_reis(_, _, Path, Price) :-
    cheapest(Price, Path),
    retractall(cheapest(_, _)).

lyhim_reis(From, To, _, _) :-
    getQuickestPath(From, To, false, [From], Path, Cost, false, Time),
    mineConstructor([From | Path], MinePath),
    retractall(shortest(_, _, _)),
    asserta(shortest(Time, Cost, MinePath)),
    fail.
lyhim_reis(_, _, Path, Price) :-
    shortest(Time, Price, Path),
    write(Time), nl,
    retractall(shortest(_, _, _)).
