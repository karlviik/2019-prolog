% ül 2
%lihtlause--> nimisonafraas, tegusonafraas.
%nimisonafraas--> nimisona, omadussonafraas, nimisona.
%nimisonafraas--> nimisona,nimisonafraas ;[].
%nimisona-->[pakapiku];[habe];[tema];[sobimatuse];[jouluvanaks].  % terminalsümbolid esinevad reeglis paremal pool ühiklistidena
%omadussonafraas --> maarsona, omadussona.
%maarsona--> [liiga].
%omadussona --> [lyhike].
%tegusonafraas --> tegusona, nimisonafraas.
%tegusona --> [tingib];[pohjustab].


% ül 3
liitlause --> lihtlause, uhend, lihtlause.
liitlause --> liitlause, uhend, lihtlause.
uhend --> [','].
lihtlause --> nimisonafraas, tegusonafraas.
nimisonafraas --> maarsonafraas, nimisona.
maarsonafraas --> omadussona, maarsona ; [].
maarsona --> [kivile] ; [upakile].
nimisona --> [sammal] ; [uhkus] ; [raha] ; [volad].
omadussona --> [veerevale] ; [].
tegusona --> [kasva] ; [ajab] ; [tuleb] ; [laheb] ; [jaavad].
tegusonafraas --> meetod, tegusona, maarsonafraas.
meetod --> [ei] ; [].
