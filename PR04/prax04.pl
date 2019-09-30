:- dynamic labitud/1.

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



reisi(From, Where) :- (laevaga(From, Where, _) ; laevaga(Where, From, _) ;
                        bussiga(From, Where, _) ; bussiga(Where, From, _) ;
                        rongiga(From, Where, _) ; rongiga(Where, From, _) ;
                        lennukiga(From, Where, _) ; lennukiga(Where, From, _)) , asserta(labitud(From)).

reisi(From, Where) :- not(labitud(From)), reisi(From, Somewhere), reisi(Somewhere, Where).