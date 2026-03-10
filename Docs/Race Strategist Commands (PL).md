Poniżej znajdziesz kompletną listę wszystkich komend głosowych rozpoznawanych przez Cato, stratega wyścigowego AI, wraz z krótkim wprowadzeniem do składni gramatyki fraz.

## Składnia

1. Znaki zastrzeżone

   Znaki **[** **]** **{** **}** **(** **)** oraz samo **,** są znakami specjalnymi i nie mogą być używane jako część normalnych słów.

2. Frazy

   Fraza to część zdania, a nawet całe zdanie. Może zawierać dowolną liczbę słów oddzielonych spacjami, ale nie może zawierać znaków zarezerwowanych. Może zawierać części alternatywne (bezpośrednie lub przywoływane przez imię), jak zdefiniowano poniżej. Przykłady:

       Mary chce lody

       (TellMe) jak masz na imię?

       Która jest { the, the current } godzina?

   Pierwszy przykład to prosta fraza. Drugi przykład pozwala na wybór opcji zdefiniowanych przez zmienną *TellMe* (patrz poniżej), a trzeci przykład wykorzystuje wybór lokalny i oznacza „Która jest godzina?” i „Która jest aktualna godzina?”.

3. Wybory

   Za pomocą tej składni można zdefiniować alternatywne części frazy. Alternatywne (pod-)frazy muszą być ujęte w **{** i **}** i rozdzielone przecinkami. Każda (pod-)fraza może zawierać tylko proste słowa. Przykład:

       { ciśnienia, ciśnienia w oponach }

   Jeśli dana lista opcji jest używana w kilku frazach, można zdefiniować dla niej zmienną i zamiast jawnej składni użyć odwołania do zmiennej (nazwy listy opcji ujętej w **(** i **)**). Wszystkie predefiniowane opcje są wymienione w sekcji „[Choices]” w [pliku gramatycznym](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Choices.en) i wyglądają następująco:

       TellMe=Can you tell me, Please tell me, Tell me, Can you give me, Please give me, Give me

   Do tej listy predefiniowanych opcji można odwołać się, używając *(TellMe)* jako części frazy.

4. Polecenia

   Pełne polecenie to albo fraza zdefiniowana powyżej, albo lista fraz oddzielonych przecinkami i ujętych w nawiasy **[** i **]**. Każda z tych fraz może samodzielnie wywołać polecenie. Przykłady:

       (WhatAre) {ciśnienie w oponach, aktualne ciśnienie w oponach, ciśnienie w oponach}

       [(TellMe) godzina, Która godzina, Która jest {aktualna godzina, godzina}]

   Pierwszy przykład to pojedyncza fraza, ale z wewnętrznymi wyborami (alternatywami). Drugi przykład definiuje trzy niezależne frazy dla polecenia, nawet z wewnętrznymi wyborami.

## Polecenia

#### Predefiniowane opcje

TellMe=Powiedz mi, Podaj mi, Daj mi znać, Możesz mi powiedzieć, Proszę powiedz mi, Mów

WhatAre=Powiedz mi jakie są, Podaj jakie są, Jakie są

WhatIs=Powiedz mi jaki jest, Podaj jaki jest, Jaki jest, Jaka jest, Podaj mi jaka jest

CanYou=Czy możesz, Możesz, Proszę

CanWe=Czy możemy, Możemy, Może byśmy

Announcements=ostrzeżenia pogodowe

#### Polecenia

1. Rozmowa

	[Cześć %name%, Hej %name%, %name% słyszysz mnie?, %name% potrzebuję cię, %name% odezwij się proszę]

	[Tak {proszę, jasne}, {Tak, perfekcyjnie} jedziemy dalej, {Ok, jedziemy} {dalej, kontynuuj}, Zgadzam się, Dobrze, Dobra, Potwierdzam]

	[Nie {teraz, dziękuję}, Nie w tej chwili, Negatyw]

	[(CanYou) opowiedzieć mi żart, Masz może jakiś żart?, Dawaj żart]

	[Cisza proszę, Wyłącz się na chwilę, Muszę się skupić, Potrzebuję ciszy, Zamknij się]

	[Okej, możesz mówić, Już cię słyszę, Możesz mówić dalej, Informuj mnie ponownie]

	[Proszę bez (Announcements), Nie podawaj więcej (Announcements), Wstrzymaj (Announcements)]

	[Proszę o (Announcements), Podawaj (Announcements), Możesz dawać (Announcements), Chcę (Announcements)]

2. Informacje

	[(TellMe) godzina, godzinę, która jest godzina, Jaka jest teraz godzina]

	[Co z pogodą, Czy nadchodzi deszcz, {Czy są, Czy będzie} zmiana pogody, (CanYou) sprawdzić {prognozę, pogodę}]

	[(TellMe) ile okrążeń zostało, Ile zostało okrążeń, Ile jeszcze okrążeń, Ile do końca, Jak długo do końca]

	[Zasymuluj {wyścig, pozycję} za (Number) okrążeń, (CanYou) zasymulować {wyścig, pozycję} za (Number) okrążeń, Na jakiej pozycji będę za (Number) okrążeń, Jaka będzie moja pozycja za (Number) okrążeń]

	[(WhatIs) {moja, wyścigowa, aktualna} pozycja, (TellMe) {moją, wyścigową, aktualną} pozycję]

	[(TellMe) różnicę do {auta przede mną, auta z przodu, pozycji przed tobą, następnego auta}, (WhatIs) różnica do {auta przede mną, auta z przodu, pozycji przed tobą, następnego auta}, Jaka jest różnica do {auta przede mną, auta z przodu, pozycji przed tobą, następnego auta}]

	[(TellMe) różnicę do {auta za tobą, pozycji za tobą, poprzedniego auta}, (WhatIs) różnica do {auta za tobą, pozycji za tobą, poprzedniego auta}, Jaka jest różnica do {auta za tobą, pozycji za tobą, poprzedniego auta}]

	[(TellMe) różnicę do {lidera, prowadzącego}, (WhatIs) różnica do {lidera, prowadzącego}, Jaka jest różnica do {lidera, prowadzącego}]

	[(TellMe) różnicę do {auta, auta numer, numeru} (Number), (WhatIs) różnica do {auta, auta numer, numeru} (Number), Jaka jest różnica do {auta, auta numer, numeru} (Number)]

	[(TellMe) {nazwisko kierowcy, kto jedzie, kierowca} przed tobą, (WhatIs) {nazwisko kierowcy, kierowca} przed tobą]

	[(TellMe) {nazwisko kierowcy, kto jedzie, kierowca} za tobą, (WhatIs) {nazwisko kierowcy, kierowca} za tobą]

	[(TellMe) {klasa auta, klasa samochodu} przed tobą, (WhatIs) {klasa auta, klasa samochodu} przed tobą]

	[(TellMe) {klasa auta, klasa samochodu} za tobą, (WhatIs) {klasa auta, klasa samochodu} za tobą]

	[(TellMe) {kategoria pucharu auta, kategoria auta} przed tobą, (WhatIs) {kategoria pucharu auta, kategoria auta} przed tobą]

	[(TellMe) {kategoria pucharu auta, kategoria auta} za tobą,(WhatIs) {kategoria pucharu auta, kategoria auta} za tobą]

	[(TellMe) czas {obecnego, ostatniego} okrążenia {auta, auta numer, numeru} (Number), (WhatIs) czas {obecnego, ostatniego} okrążenia {auta, auta numer, numeru} (Number)]

	[(TellMe) czas {obecnego, ostatniego} okrążenia pozycji (Number), (WhatIs) czas {obecnego, ostatniego} okrążenia pozycji (Number)]

	[(TellMe) {mój, aktualny} czas {obecnego, ostatniego} okrążenia, (WhatIs) {mój, aktualny} czas {obecnego, ostatniego} okrążenia]

	[(TellMe) czasy okrążeń, (WhatAre) czasy okrążeń]

	[(TellMe) liczbę {aut, aut na torze, aut w sesji, aktywnych aut}, (WhatAre) liczba {aut, aut na torze, aut w sesji}, Ile aut {jest, pozostało} {na torze, w sesji}]

	[(TellMe) jak {często} {auto, auto numer, numer} (Number) było w boksach, Ile pitstopów ma {auto, auto numer, numer} (Number), Jak często {auto, auto numer, numer} (Number) było w boksach]

3. Postój w boksach

	[(WhatIs) najlepsze {okrążenie, moment} na pitstop, Kiedy rekomendujesz pitstop, (CanYou) polecić pitstop, Na którym okrążeniu powinienem zjechać]

	[(CanYou) zasymulować {kolejny pitstop, pitstop} {około, na, w} okrążeniu (Number), Zaplanuj {kolejny pitstop, pitstop} {około, na, w} okrążeniu (Number)]

4. Strategia

	[Jak wygląda nasza strategia {na dziś, na wyścig}, Podaj mi skrót strategii, Jaka jest nasza strategia, (TellMe) naszą strategię]

	[(CanYou) {wstrzymać, anulować} strategię, Strategia nie ma sensu, Trzeba anulować strategię]

	[Kiedy jest kolejny pitstop, Na którym okrążeniu jest planowany pitstop, Kiedy mam zjechać, (TellMe) kiedy kolejny pitstop]

	[(CanYou) opracować nową strategię, (CanYou) zmienić strategię, Potrzebujemy nowej strategii]

	[{Mamy, Jest} Full Course Yellow. Co powinniśmy zrobić, Czy mamy zjeżdżać do boksu, Czy pitstop się opłaci]