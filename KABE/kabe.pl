:- dynamic mycolour/1.    % so far unset anywhere
%-------------------- MANIPULATING GAME-------------------------
% X1 Y1 move from, X2 Y2 move to, XT YT take, XT = 0 if no take.
do_actual_move(X1, Y1, Col1, XT, YT, X2, Y2, Col2) :-
        (XT =\= 0, retract(ruut(XT, YT, _)), asserta(ruut(XT, YT, 0))
    ;
        XT == 0),
    retract(ruut(X1, Y1, Col1)), retract(ruut(X2, Y2, 0)), asserta(ruut(X1, Y1, 0)), asserta(ruut(X2, Y2, Col2)).
%---------------------------------------------------------------

%--------------------COPY THE BOARD TO square(X, Y, Col)--------
:- dynamic square/3.
:- dynamic whites/1.
:- dynamic blacks/1.
:- dynamic count/2.
copy :-
    retractall(square(_, _, _)),
    retractall(count(_, _)),
    asserta(count(1, 0)),
    asserta(count(2, 0)),
    fail.
copy :-
    ruut(X, Y, Col),
    (
        (Col == 1 ; Col == 10), count(1, C), retract(count(1, C)), C1 is C + 1, asserta(count(1, C1))
      ;
        (Col == 2 ; Col == 20), count(2, C), retract(count(2, C)), C1 is C + 1, asserta(count(2, C1))
      ;
        Col == 0
    ),
    asserta(square(X, Y, Col)),
    fail.
copy.
%---------------------------------------------------------------

%-----------------MUST TAKE WITH THIS PIECE---------------------
:- dynamic enemycols/1.
move_take(X1, Y1, Col1, XT, YT, ColT, X2, Y2, Col2) :-
    (
        (Col1 == 1 ; Col1 == 2), move_take_rock(X1, Y1, Col1, XT, YT, ColT, X2, Y2, Col2)
      ;
        (Col1 == 10 ; Col1 == 20), move_take_boulder(X1, Y1, XT, YT, ColT, X2, Y2), Col2 = Col1
    ).

move_take_rock(X1, Y1, Col1, XT, YT, ColT, X2, Y2, Col2) :-
    (XT is X1 + 1, X2 is X1 + 2 ; XT is X1 - 1, X2 is X1 - 2),
    (YT is Y1 + 1, Y2 is Y1 + 2 ; YT is Y1 - 1, Y2 is Y1 - 2),
    square(XT, YT, ColT), enemycols(ColT), square(X2, Y2, 0),
    (
        Col1 == 1,
        (
            X2 == 8, Col2 is 10
          ;
            X2 \= 8, Col2 is Col1
        )
      ;
        Col1 == 2,
        (
            X2 == 1, Col2 is 20
          ;
            X2 \= 1, Col2 is Col1
        )
    ).

move_take_boulder(X1, Y1, XT, YT, ColT, X2, Y2) :-
    (Xmove is 1 ; Xmove is -1),(Ymove is 1 ; Ymove is -1),
    Xnext is X1 + Xmove, Ynext is Y1 + Ymove,
    searchForEnemy(Xmove, Ymove, Xnext, Ynext, XT, YT, ColT, X2, Y2).

searchForEnemy(Xmove, Ymove, Xcur, Ycur, XT, YT, ColT, X2, Y2) :-
    square(Xcur, Ycur, ColCur),
    XNext is Xcur + Xmove, YNext is Ycur + Ymove,
    (
        enemycols(ColCur), ColT is ColCur, XT is Xcur, YT is Ycur, searchForFreeSpots(Xmove, Ymove, XNext, YNext, X2, Y2)
      ;
        ColCur == 0, searchForEnemy(Xmove, Ymove, XNext, YNext, XT, YT, ColT, X2, Y2)
    ).

searchForFreeSpots(Xmove, Ymove, Xcur, Ycur, X2, Y2) :-
    square(Xcur, Ycur, ColCur), ColCur == 0,
    (X2 is Xcur, Y2 is Ycur ; XNext is Xcur + Xmove, YNext is Ycur + Ymove, searchForFreeSpots(Xmove, Ymove, XNext, YNext, X2, Y2)).
%----------------------------------------------------------------

%----------------------------JUST MOVE---------------------------
just_move(X1, Y1, Col, X2, Y2, Col2) :-
    square(X1, Y1, Col),
    (Col == 1, Way is 1; Col == 2, Way is -1), move_rock(X1, Y1, Col, Way, X2, Y2, Col2) ;
    (Col == 10 ; Col == 20), move_boulder(X1, Y1, X2, Y2), Col2 = Col.

move_rock(X1, Y1, Col1, Way, X2, Y2, Col2) :-
    X2 is X1 + Way, (Y2 is Y1 - 1 ; Y2 is Y1 + 1), square(X2, Y2, 0),
    (
        Col1 == 1,
        (
            X2 == 8, Col2 is 10
          ;
            X2 \= 8, Col2 is Col1
        )
      ;
        Col1 == 2,
        (
            X2 == 1, Col2 is 20
          ;
            X2 \= 1, Col2 is Col1
        )
    ).

move_boulder(X1, Y1, X2, Y2) :-
    (Xmove is 1 ; Xmove is -1),
    (Ymove is 1 ; Ymove is -1),
    XNext is X1 + Xmove,
    YNext is Y1 + Ymove,
    searchForFreeSpots(Xmove, Ymove, XNext, YNext, X2, Y2).           % this is from move with taking
%----------------------------------------------------------------

%-----------------GET ALL POSSIBLE TAKING MOVES WITH COL---------
get_all_take_moves_with_col(Col, ListOfTakes) :-            % takes are in form of move(X1, Y1, Col1, XT, YT, ColT, X2, Y2, Col2)
    retractall(enemycols(_)),
    (Col == 1, asserta(enemycols(2)), asserta(enemycols(20)) ; Col == 2, asserta(enemycols(1)), asserta(enemycols(10))),
    findall(Take, get_all_take_manager(Col, Take), ListOfTakes).

get_all_take_manager(Col, Take) :-
    (
        Col == 1, (square(X1, Y1, 1), Col1 is 1 ; square(X1, Y1, 10), Col1 is 10)
      ;
        Col == 2, (square(X1, Y1, 2), Col1 is 2 ; square(X1, Y1, 20), Col1 is 20)
    ),
    move_take(X1, Y1, Col1, XT, YT, ColT, X2, Y2, Col2),
    Take = move(X1, Y1, Col1, XT, YT, ColT, X2, Y2, Col2).
%----------------------------------------------------------------

%------------GET ALL POSSIBLE TAKE MOVES WITH ONE COORD----------
get_all_take_moves_with_this(X1, Y1, ListOfTakes) :-
    square(X1, Y1, Col1),
    retractall(enemycols(_)),
    ((Col1 == 1 ; Col1 == 10), asserta(enemycols(2)), asserta(enemycols(20)) ; (Col1 == 2 ; Col1 == 20), asserta(enemycols(1)), asserta(enemycols(10))),
    findall(Take, (move_take(X1, Y1, Col1, XT, YT, ColT, X2, Y2, Col2), Take = move(X1, Y1, Col1, XT, YT, ColT, X2, Y2, Col2)), ListOfTakes).
%----------------------------------------------------------------

%-------------GET ALL POSSIBLE JUST MOVES WITH COL---------------
get_all_just_moves_with_col(Col, ListOfMoves) :-            % moves are in form of move(X1, Y1, Col1, 0, 0, 0, X2, Y2, Col2)
    findall(Move, get_all_move_manager(Col, Move), ListOfMoves).

get_all_move_manager(Col, Move) :-
    (
        Col == 1, (square(X1, Y1, 1), Col1 is 1 ; square(X1, Y1, 10), Col1 is 10)
      ;
        Col == 2, (square(X1, Y1, 2), Col1 is 2 ; square(X1, Y1, 20), Col1 is 20)
    ),
    just_move(X1, Y1, Col1, X2, Y2, Col2),
    Move = move(X1, Y1, Col1, 0, 0, 0, X2, Y2, Col2).
%----------------------------------------------------------------

%-------------GET ALL VALID MOVES WITH COL-----------------------
get_all_valid_moves(Col, IsTake, ListOfMoves) :-        % IsTake = 1 if it's taking, 0 if just moving
    get_all_take_moves_with_col(Col, ListOfTakes),
    (
        length(ListOfTakes, 0), get_all_just_moves_with_col(Col, ListOfMoves), IsTake is 0
    ;
        not(length(ListOfTakes, 0)), ListOfMoves = ListOfTakes, IsTake is 1
    ).
%----------------------------------------------------------------

%--------------MOVE SIMULATING AND DE-SIMULATING-----------------
simulate_move(Move) :-
    Move = move(X1, Y1, Col1, XT, YT, ColT, X2, Y2, Col2),
    square(X1, Y1, Col1),
    retract(square(X1, Y1, Col1)), asserta(square(X1, Y1, 0)),
    retract(square(X2, Y2, 0)), asserta(square(X2, Y2, Col2)),
    (
        XT == 0
      ;
        XT \= 0,
        retract(square(XT, YT, ColT)),
        asserta(square(XT, YT, 0)),
        (
            (ColT == 1 ; ColT == 10), count(1, C), retract(count(1, C)), C1 is C - 1, asserta(count(1, C1))
          ;
            (ColT == 2 ; ColT == 20), count(2, C), retract(count(2, C)), C1 is C - 1, asserta(count(2, C1))
        )
    ).

desimulate_move(Move) :-
    Move = move(X1, Y1, Col1, XT, YT, ColT, X2, Y2, Col2),
    square(X2, Y2, Col2),
    retract(square(X2, Y2, Col2)), asserta(square(X2, Y2, 0)),
    retract(square(X1, Y1, 0)), asserta(square(X1, Y1, Col1)),
    (
        XT == 0
      ;
        XT \= 0,
        retract(square(XT, YT, 0)),
        asserta(square(XT, YT, ColT)),
        (
            (ColT == 1 ; ColT == 10), count(1, C), retract(count(1, C)), C1 is C + 1, asserta(count(1, C1))
          ;
            (ColT == 2 ; ColT == 20), count(2, C), retract(count(2, C)), C1 is C + 1, asserta(count(2, C1))
        )
    ).
%----------------------------------------------------------------

%--------------------------MINIMAXER-----------------------------
% need to make rule for 0 depth
sim_manager(0, _, _, _, _, 0, _).
sim_manager(Depth, Col, Multiplier, XMust, YMust, BestValue, BestMove) :-
    Depth > 0,
    (Col == 1, NextCol is 2 ; Col == 2, NextCol is 1),
    NextDepth is Depth - 1,
    NextMultiplier is Multiplier * -1,
    (
        XMust == 0,
        get_all_valid_moves(Col, IsTake, ListOfMoves),
        % If the moves are just moves
        (
            IsTake == 0,
            go_deeper_move(ListOfMoves, NextCol, NextDepth, NextMultiplier, BestValue, BestMove)
          ;
            IsTake == 1,
            go_deeper_take(ListOfMoves, NextCol, NextDepth, NextMultiplier, BestValue, BestMove)
        )
        ;
        XMust \= 0,
        go_deeper_this_coord(XMust, YMust, NextCol, NextDepth, NextMultiplier, BestValue, BestMove)
    ).

go_deeper_move([], _, _, NeMu, BeVa, 0) :-  % if these values are actually returned, then it's game over
    NeMu == 1, BeVa is 999 ; NeMu == -1, BeVa is -999.
go_deeper_move(ListOfMoves, NextCol, NextDepth, NextMultiplier, BestValue, BestMove) :-
    ListOfMoves = [ CurMove | RestOfMoves ],
    simulate_move(CurMove),
    sim_manager(NextDepth, NextCol, NextMultiplier, 0, 0, ThisValue, _),
    desimulate_move(CurMove),
    go_deeper_move(RestOfMoves, NextCol, NextDepth, NextMultiplier, RestValue, RestMove),
    (
        NextMultiplier == 1,        % means this level is opponent level, must get min value
        (
            RestValue < ThisValue, BestValue = RestValue, BestMove = RestMove
          ;
            RestValue >= ThisValue, BestValue = ThisValue, BestMove = CurMove
        )
      ;
        NextMultiplier == -1,       % means this level is my level, must get max value
        (
            RestValue > ThisValue, BestValue = RestValue, BestMove = RestMove
          ;
            RestValue =< ThisValue, BestValue = ThisValue, BestMove = CurMove
        )
    ).

go_deeper_take([], _, _, NeMu, BeVa, 0) :-  % these values should never be returned, in theory
    NeMu == 1, BeVa is 200 ; NeMu == -1, BeVa is -200.
go_deeper_take(ListOfMoves, NextCol, NextDepth, NextMultiplier, BestValue, BestMove) :-
    ListOfMoves = [ ThisMove | RestOfMoves ],
    ThisMove = move(_, _, _, _, _, TakeCol, X2, Y2, _),
    simulate_move(ThisMove),
    (
        count(NextCol, 0), ThisValue is -999 * NextMultiplier         % 999 * NextMultiplier * -1, there are no opponent pieces left
      ;
        not(count(NextCol, 0)), % simulate takes as long as there are takes
        get_all_take_moves_with_this(X2, Y2, ListOfTakes),
        ((TakeCol == 20 ; TakeCol == 10), ValueAdd = 3; (TakeCol == 2 ; TakeCol == 1), ValueAdd = 1), RealValueAdd is ValueAdd * NextMultiplier * -1,        %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! VALUES FOR PIECES
        (
            length(ListOfTakes, 0), sim_manager(NextDepth, NextCol, NextMultiplier, 0, 0, SubValue, _), ThisValue is SubValue + RealValueAdd
          ;
            not(length(ListOfTakes, 0)), go_deeper_take(ListOfTakes, NextCol, NextDepth, NextMultiplier, SubValue, _), ThisValue is SubValue + RealValueAdd
        )

    ),
    desimulate_move(ThisMove),
    go_deeper_take(RestOfMoves, NextCol, NextDepth, NextMultiplier, RestValue, RestMove),
    (
        NextMultiplier == 1,        % means this level is opponent level, must get min value
        (
            RestValue < ThisValue, BestValue = RestValue, BestMove = RestMove
          ;
            RestValue >= ThisValue, BestValue = ThisValue, BestMove = ThisMove
        )
      ;
        NextMultiplier == -1,       % means this level is my level, must get max value
        (
            RestValue > ThisValue, BestValue = RestValue, BestMove = RestMove
          ;
            RestValue =< ThisValue, BestValue = ThisValue, BestMove = ThisMove
        )
    ).

go_deeper_this_coord(X1, Y1, NextCol, NextDepth, NextMultiplier, BestValue, BestMove) :-
    get_all_take_moves_with_this(X1, Y1, ListOfTakes),
    go_deeper_take(ListOfTakes, NextCol, NextDepth, NextMultiplier, BestValue, BestMove).


:- module(iaib185043).

iaib185043(Col, X, Y):-
    copy,
    sim_manager(4, Col, 1, X, Y, Val, BestMove),
    BestMove = move(X1, Y1, Col1, XT, YT, _, X2, Y2, Col2),
    write(BestMove), write(Val),
    do_actual_move(X1, Y1, Col1, XT, YT, X2, Y2, Col2),
    !.
iaib185043(_, _, _).