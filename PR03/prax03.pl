
% 1. Kirjutada rekursiivne reegel viimane_element/2, mis leiab listi viimase elemendi.
viimane_element(_, []) :- fail.
viimane_element(E, [E | []]).
viimane_element(E, [_ | T]) :- viimane_element(E, T).


% 2. Kirjutada reegel suurim/2, mis kontrollib etteantud listist järjest paarikaupa elemente
% ja paneb väljundlisti elemendi, mis on antud paari elementidest suurim.
% Kui võrreldakse elementi ja tühilisti,siis väljundlisti tuleb panna element.
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
paki([E1 | []], [E1 | []]).
paki([E1, E2 | Tail], Answer) :- E1 == E2,
                                paki([E2 | Tail], Answer).
paki([E1, E2 | Tail], Answer) :- E1 \= E2,
                                paki([E2 | Tail], SmallerAnswer),
                                append([E1], SmallerAnswer, Answer).
