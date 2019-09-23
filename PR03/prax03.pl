
% 1. Kirjutada rekursiivne reegel viimane_element/2, mis leiab listi viimase elemendi.
viimane_element(_, []) :- fail.
viimane_element(E, [E | []]).
viimane_element(E, [_ | T]) :- viimane_element(E, T).


% 2. Kirjutada reegel suurim/2, mis kontrollib etteantud listist järjest paarikaupa elemente
% ja paneb väljundlisti elemendi, mis on antud paari elementidest suurim.
% Kui võrreldakse elementi ja tühilisti,siis väljundlisti tuleb panna element.
suurim([], []).
suurim([X | []], Y) :- append([], [X], Y).
suurim([H1, H2 | []], X) :- Bigger is max(H1, H2),
                            suurim([H2], Xsmaller),
                            append(Bigger, Xsmaller, X).
suurim([H1, H2 | T], X) :- Bigger is max(H1, H2),
                            append([H2], T, Tsmaller),
                            suurim(Tsmaller, Xsmaller),
                            append([Bigger], Xsmaller, X).


% 3. Kirjutada reegel paki/2, mis elimineerib listist üksteisele vahetult
% järgnevad korduvad elemendid
paki([], []).
paki([E1], [E1]).
paki([E1, E2 | Tail], Answer) :- E1 == E2,
                                paki([E2 | Tail], Answer).
paki([E1, E2 | Tail], Answer) :- E1 \= E2,
                                paki([E2 | Tail], SmallerAnswer),
                                append([E1], SmallerAnswer, Answer).


% 4. Kirjutada reegel duplikeeri/2, mis kahekordistab elemendid etteantud listis.
duplikeeri([], []).
duplikeeri([H1 | T], Answer) :- duplikeeri(T, SmallerAnswer),
                                append([H1, H1], SmallerAnswer, Answer).


% 5. Kirjutada reegel kordista/3, mis kordistab listi kõiki elemente etteantud arv korda.
helper(Element, 1, [Element]).
helper(Element, Times, List) :- FewerTimes is Times - 1,
                                helper(Element, FewerTimes, SmallerList),
                                append([Element], SmallerList, List).
kordista([], _, []).
kordista([El | Tail], Times, Answer) :- kordista(Tail, Times, SmallerAnswer),
                                        helper(El, Times, HelperList),
                                        append(HelperList, SmallerAnswer, Answer).


% 6. Kirjutada reegel vordle_predikaadiga/3, mis võrdleb etteantud predikaadiga
% listi kõiki liikmeid ja paneb väljundlisti need elemendid, mis vastavad tingimustele.
% Võrdluspredikaadid on:
%   -paaritu_arv
%   -paaris_arv
%   -suurem_kui(X)
% Võrdluspredikaadid tuleb ise implementeerida.
paaritu_arv(X) :- 1 is X rem 2.
paaris_arv(X) :- 0 is X rem 2.
suurem_kui(X, Num) :- Num > X.

vordle_predikaadiga([], _, []).
vordle_predikaadiga([El | Tail], [Thing], Answer) :- (Term =.. [Thing, El], Term, Addition = [El], write(Addition) ; Addition = [], write(Addition)),
                                            vordle_predikaadiga(Tail, [Thing], Xsmaller),
                                            append(Addition, Xsmaller, Answer).
vordle_predikaadiga([El | Tail], [Thing, X], Answer) :- (Term =.. [Thing, X, El], Term, Addition = [El], write(Addition) ; Addition = [], write(Addition)),
                                            vordle_predikaadiga(Tail, [Thing, X], Xsmaller),
                                            append(Addition, Xsmaller, Answer).