
% 1. Kirjutada rekursiivne reegel viimane_element/2, mis leiab listi viimase elemendi.
viimane_element(_, []) :- fail.
viimane_element(E, [E | []]).
viimane_element(E, [_ | T]).