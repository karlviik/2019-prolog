:- dynamic mycolour/1.    % so far unset anywhere
%-------------------- MANIPULATING GAME-------------------------
% X1 Y1 move from, X2 Y2 move to, XT YT take, XT = 0 if no take.
move(X1,Y1,XT,YT,X2,Y2) :-
        (XT == 0, retract(ruut(XT, YT, _)), asserta(ruut(XT, YT, 0))
    ;
        XT =\= 0),
    retract(ruut(X1, Y1, Col)), retract(ruut(X2, Y2, _)), asserta(ruut(X1, Y1, 0)), asserta(ruut(X2, Y2, Col)).
%---------------------------------------------------------------

%--------------------COPY THE BOARD TO square(X, Y, Col)--------
:- dynamic square/3.
:- dynamic mine/1.
:- dynamic their/1.
copy :-
    retractall(square(_, _, _)),
    retractall(mine(_)),
    retractall(their(_)),
    asserta(whites(0)),
    asserta(blacks(0)),
    fail.
copy :-
    ruut(X, Y, Col),
    mycolour(Me),
    (
        Me == 1,
        (
            (Col == 1 ; Col == 10), mine(C), retract(mine(C)), C1 is C + 1, asserta(mine(C1))
        ;
            (Col == 2 ; Col == 20), their(C), retract(their(C)), C1 is C + 1, asserta(their(C1))
        ;
            Col == 0
        )
    ;
        Me == 2,
        (
            (Col == 2 ; Col == 20), mine(C), retract(mine(C)), C1 is C + 1, asserta(mine(C1))
        ;
            (Col == 1 ; Col == 10), their(C), retract(their(C)), C1 is C + 1, asserta(their(C1))
        ;
            Col == 0
        )
    ),
    asserta(square(X, Y, Col)),
    fail.
copy.
%---------------------------------------------------------------
/*
get moves for color, grab together all moves
    if one of those moves is with taking, check if there are any more moves that can be done by those pieces that take after taking
    multiple takins and such should count as just one move or something, they shouldn't be really complex anyways, unless boulder does the moves...
*/


%-----------------MUST TAKE WITH THIS PIECE---------------------
:- dynamic enemycols/1.
move_take(X1, Y1, XT, YT, X2, Y2) :-
    retractall(enemycols(_)),
    square(X1, Y1, Col),
    ((Col == 1 ; Col == 10), asserta(enemycols(2)), asserta(enemycols(20)) ; (Col == 2 ; Col == 20), asserta(enemycols(1)), asserta(enemycols(10))),
    if col is rock, do rock, if boulder, do boulder.

move_take_rock(X1, Y1, XT, YT, X2, Y2) :-
    (XT is X1 + 1, YT is X1 + 1, X2 is X1 + 2, Y2 is Y1 + 2, square(XT, YT, Col), enemycols(Col), square(X2, Y2, 0)) ;
    (XT is X1 + 1, YT is X1 - 1, X2 is X1 + 2, Y2 is Y1 - 2, square(XT, YT, Col), enemycols(Col), square(X2, Y2, 0)) ;
    (XT is X1 - 1, YT is X1 + 1, X2 is X1 - 2, Y2 is Y1 + 2, square(XT, YT, Col), enemycols(Col), square(X2, Y2, 0)) ;
    (XT is X1 - 1, YT is X1 - 1, X2 is X1 - 2, Y2 is Y1 - 2, square(XT, YT, Col), enemycols(Col), square(X2, Y2, 0)).

move_take_boulder(X1, Y1, XT, YT, X2, Y2) :-
    (Xmove is 1, Ymove is 1 ; Xmove is 1, Ymove is -1 ; Xmove is -1, Ymove is 1; Xmove is -1, Ymove is -1),
    Xnext is X1 + Xmove, Ynext is Y1 + Ymove,
    searchForEnemy(Xmove, Ymove, Xnext, Ynext, XT, YT, X2, Y2).

searchForEnemy(Xmove, Ymove, Xnext, Ynext, XT, YT, X2, Y2) :-

/*
ruut(X, Y, Status).
    Status = 1 % valge
    Status = 2 % must
    Status = 10 % valge tamm
    Status = 20 % must tamm
Valged all, ehk valge on ruut(1, 1, 1)



*/
main(MyColor):-
    ruut(X,Y, MyColor),
    nl, write([MyColor, 'Nupp ', ruudul, X,Y]),
    leia_suund(MyColor,Suund),
    kaigu_variandid(X,Y,Suund,X1,Y1),
    !.
main(_).

leia_suund(1,1):- !.
leia_suund(2,-1).

%--------------------------------
kaigu_variandid(X,Y,Suund,X1,Y1):-
    votmine(X,Y,Suund,X1,Y1),!.
kaigu_variandid(X,Y,Suund,X1,Y1):-
    kaimine(X,Y,Suund,X1,Y1),!.
%--------------------------------
votmine(X,Y,Suund,X1,Y1):-
    kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2),
    vota(X,Y,Suund,X1,Y1,X2,Y2),
    fail.

kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2):-  % Votmine edasi paremale
    X1 is X + Suund,
    Y1 is Y + 1,
    ruut(X1,Y1, Color),
    Color =\= MyColor, Color =\= 0,
    X2 is X1 + Suund,
    Y2 is Y1 + 1,
    ruut(X2,Y2, 0).
kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2):-  % Votmine edasi vasakule
    X1 is X + Suund,
    Y1 is Y - 1,
    ruut(X1,Y1, Color),
    Color =\= MyColor, Color =\= 0,
    X2 is X1 + Suund,
    Y2 is Y1 - 1,
    ruut(X2,Y2, 0).
kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2):-  % Votmine tagasi paremale
    X1 is X + Suund * -1,
    Y1 is Y + 1,
    ruut(X1,Y1, Color),
    Color =\= MyColor, Color =\= 0,
    X2 is X1 + Suund * -1,
    Y2 is Y1 + 1,
    ruut(X2,Y2, 0).
kas_saab_votta(X,Y,Suund,X1,Y1,X2,Y2):-  % Votmine tagasi vasakule
    X1 is X + Suund * -1,
    Y1 is Y - 1,
    ruut(X1,Y1, Color),
    Color =\= MyColor, Color =\= 0,
    X2 is X1 + Suund * -1,
    Y2 is Y1 - 1,
    ruut(X2,Y2, 0).

%--------------------------------
kaimine(X,Y,Suund,X1,Y1):-
    kas_naaber_vaba(X,Y,Suund,X1,Y1),
    tee_kaik(X,Y,X1,Y1),
    write([' kaib ', X1,Y1]),
    fail.
kaimine(_,_,_,_,_).

kas_naaber_vaba(X,Y,Suund,X1,Y1):-
    X1 is X +Suund,
    Y1 is Y + 1,
    ruut(X1,Y1, 0).
kas_naaber_vaba(X,Y,Suund,X1,Y1):-
    X1 is X +Suund,
    Y1 is Y -1,
    ruut(X1,Y1, 0), write(' voi ').

kas_naaber_vaba(X,Y,X1,Y1):-
    ruut(X,Y, Status),
    assert(ruut1(X1,Y1, Status)),!.

/*
%---------MÄNGU ALGSEIS-------------
% Valged
%ruut(1,1,1).
%ruut(1,3,1).
%ruut(1,5,1).
%ruut(1,7,1).
%ruut(2,2,1).
%ruut(2,4,1).
%ruut(2,6,1).
%ruut(2,8,1).
%ruut(3,1,1).
%ruut(3,3,1).
%ruut(3,5,1).
%ruut(3,7,1).
%% Tühjad ruudud
%ruut(4,2,0).
%ruut(4,4,0).
%ruut(4,6,0).
%ruut(4,8,0).
%ruut(5,1,0).
%ruut(5,3,0).
%ruut(5,5,0).
%ruut(5,7,0).
%% Mustad
%ruut(6,2,2).
%ruut(6,4,2).
%ruut(6,6,2).
%ruut(6,8,2).
%ruut(7,1,2).
%ruut(7,3,2).
%ruut(7,5,2).
%ruut(7,7,2).
%ruut(8,2,2).
%ruut(8,4,2).
%ruut(8,6,2).
%ruut(8,8,2).
*/

/*
ruut(X,Y, Status).  %   kus X, Y [1,8]
Status = 0      % tühi
Status = 1      % valge
Status = 2      %  must
*/

%=================== Print checkers board - Start ==================
print_board :-
	print_squares(8).
print_squares(Row) :-
	between(1, 8, Row),
	write('|'), print_row_squares(Row, 1), write('|'), nl,
	NewRow is Row - 1,
	print_squares(NewRow), !.
print_squares(_) :- !.
print_row_squares(Row, Col) :-
	between(1, 8, Col),
	ruut(Col, Row, Status), write(' '), write(Status), write(' '),
	NewCol is Col + 1,
	print_row_squares(Row, NewCol), !.
print_row_squares(_, _) :- !.
%=================== Print checkers board - End ====================

%=================== Print checkers board v2 - Start ==================
status_sq(ROW,COL):-
	(	ruut(ROW,COL,COLOR),
		write(COLOR)
	) ; (
		write(' ')
	).
status_row(ROW):-
	write('row # '),write(ROW), write('   '),
	status_sq(ROW,1),
	status_sq(ROW,2),
	status_sq(ROW,3),
	status_sq(ROW,4),
	status_sq(ROW,5),
	status_sq(ROW,6),
	status_sq(ROW,7),
	status_sq(ROW,8),
	nl.
% print the entire checkers board..
status:-
	nl,
	status_row(8),
	status_row(7),
	status_row(6),
	status_row(5),
	status_row(4),
	status_row(3),
	status_row(2),
	status_row(1).
%=================== Print checkers board v2 - End ====================
