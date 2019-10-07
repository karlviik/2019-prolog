:- dynamic labitud/1.
:- dynamic goal/1.

laevaga(tallinn, helsinki, 120).
laevaga(tallinn, stockholm, 480).
laevaga(helsiki, stockholm, 120).
%laevaga(From, Where, Time) :- laevaga(From, Where, Time) ; laevaga(Where, From, Time).

bussiga(tallinn, riia, 300).
%bussiga(From, Where, Time) :- bussiga(From, Where, Time) ; bussiga(Where, From, Time).

rongiga(riia, berlin, 680).
%rongiga(From, Where, Time) :- rongiga(From, Where, Time) ; rongiga(Where, From, Time).

lennukiga(tallinn, helsinki, 30).
lennukiga(helsinki, paris, 180).
lennukiga(paris, berlin, 120).
lennukiga(paris, tallinn, 120).
%lennukiga(From, Where, Time) :- lennukiga(From, Where, Time) ; lennukiga(Where, From, Time).


mine(From, Where) :- (laevaga(From, Where, _) ; laevaga(Where, From, _) ;
                    bussiga(From, Where, _) ; bussiga(Where, From, _) ;
                    rongiga(From, Where, _) ; rongiga(Where, From, _) ;
                    lennukiga(From, Where, _) ; lennukiga(Where, From, _)), goal(Where).

mine(From, Next, Path) :- not(mine(From, Next)), labitud(Nextynext), retractall(labitud(Nextynext)), (goal(Nextynext), Path = mine(Next, Nextynext) ; Path = mine(Next, Nextynext, Sub)).

reisi_a(From, Where) :- (laevaga(From, Where, _) ; laevaga(Where, From, _) ;
                        bussiga(From, Where, _) ; bussiga(Where, From, _) ;
                        rongiga(From, Where, _) ; rongiga(Where, From, _) ;
                        lennukiga(From, Where, _) ; lennukiga(Where, From, _)) , asserta(labitud(From)).

reisi_a(From, Where) :- not(labitud(From)), reisi_a(From, Somewhere), write(Somewhere), reisi_a(Somewhere, Where).


reisi_a(From, Where, Path) :- retractall(labitud(_)), reisi_a(From, Where), asserta(goal(Where)),
                            (Path = mine(From, Where) ; labitud(Next), Path = mine(From, Next, Sub)).

reisi(From, Where) :- retractall(labitud(_)), reisi_a(From, Where), retractall(labitud(_)) .

%reisi_a(From, Where, mine(From, Where)) :- (laevaga(From, Where, _) ; laevaga(Where, From, _) ;
%                                           bussiga(From, Where, _) ; bussiga(Where, From, _) ;
%                                           rongiga(From, Where, _) ; rongiga(Where, From, _) ;
%                                           lennukiga(From, Where, _) ; lennukiga(Where, From, _)), asserta(labitud(From)).

%reisi_a(From, Where, mine(From, Next, Path)) :- reisi(From, Where), asserta(labitud(From)).




