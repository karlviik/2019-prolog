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


canReisi(From, Where, _) :-
    (laevaga(From, Where, Time) ; laevaga(Where, From, Time);
    bussiga(From, Where, Time) ; bussiga(Where, From, Time);
    rongiga(From, Where, Time) ; rongiga(Where, From, Time);
    lennukiga(From, Where, Time) ; lennukiga(Where, From, Time)).

getPath(From, To, Path, Visited) :-
    not(member(To, Visited)),
    canReisi(From, To, Visited),
    Path = [To].
getPath(From, To, Path, Visited) :-
    append([Next], Visited, NewVisited),
    append([Next], SmallerPath, Path),
    canReisi(From, Next, _),
    not(member(Next, Visited)),
    getPath(Next, To, SmallerPath, NewVisited).

