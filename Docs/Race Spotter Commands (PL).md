Poniżej znajdziesz kompletną listę wszystkich komend głosowych rozpoznawanych przez Elisa, Obserwator wyścigów AI, wraz z krótkim wprowadzeniem do składni gramatyki fraz.

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

Announcements=informacje o różnicach czasu, porady taktyczne, ostrzeżenia boczne, ostrzeżenia z tyłu, ostrzeżenia o niebieskich flagach, ostrzeżenia o żółtych flagach, ostrzeżenia o limitach toru, informacje o karach, ostrzeżenia o wolnych autach, ostrzeżenia o wypadkach przed tobą, informacje o wypadkach za tobą

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

	[(WhatIs) {my, my race, my current race} position, (TellMe) {my, my race, my current race} position]

	[(TellMe) the gap to the {car in front, car ahead, position in front, position ahead, next car}, (WhatIs) the gap to the {car in front, car ahead, position in front, position ahead, next car}, How big is the gap to the {car in front, car ahead, position in front, position ahead, next car}]

	[(TellMe) the gap to {the car behind me, the position behind me, the previous car}, (WhatIs) the gap to {the car behind me, the position behind me, the previous car}, How big is the gap to the {car behind me, position behind me, previous car}]

	[(TellMe) the gap to the {leading car, leader}, (WhatIs) the gap to the {leading car, leader}, How big is the gap to the {leading car, leader}]
	
	[(TellMe) the gap to {car, car number, number} (Number), (WhatIs) the gap to {car, car number, number} (Number), How big is the gap to {car, car number, number} (Number)]
	
	[(TellMe) the {driver name, name of the driver, driver in the car} ahead, (WhatIs) the {driver name, name of the driver, driver in the car} ahead]

	[(TellMe) the {driver name, name of the driver, driver in the car} behind, (WhatIs) the {driver name, name of the driver, driver in the car} behind]
	
	[(TellMe) the {class of the car, car class} ahead, (WhatIs) the {class of the car, car class} ahead]
	
	[(TellMe) the {class of the car, car class} behind, (WhatIs) the {class of the car, car class} behind]
	
	[(TellMe) the {cup category of the car, car cup category} ahead, (WhatIs) the {cup category of the car, car cup category} ahead]
	
	[(TellMe) the {cup category of the car, car cup category} behind, (WhatIs) the {cup category of the car, car cup category} behind]
	
	[(TellMe) the {current lap, last lap, lap} time of {car, car number, number} (Number), (WhatIs) the {current lap, last lap, lap} time of {car, car number, number} (Number)]
	
	[(TellMe) the {current lap, last lap, lap} time of position (Number), (WhatIs) the {current lap, last lap, lap} time of position (Number)]

	[(TellMe) {the, my} {current lap, last lap, lap} time, (WhatIs) {my, the} {current lap, last lap, lap} time]

	[(TellMe) the {current lap, lap} times, (WhatAre) the {current lap, lap} times]
	
	[(TellMe) the number of {cars, cars on the track, cars in the session, active cars, cars still active}, (WhatAre) the number of {cars, cars on the track, cars in the session}, How many cars {are, are still} {active, on the track, in the session}]
	
	[(TellMe) how often {the car, the car number, number} (Number) {was, have been} in the pits, How many pitstops has {car, car number, number} (Number), How often has been {car, car number, number} (Number) in the pits]
	
	[(CanYou) {focus on, observe} {car, car number, number} (Number), (CanYou) give {me, me more} information about {car, car number, number} (Number)]
	
	[Please no more information on {car, car number, number} (Number), Stop reporting on {car, car number, number} (Number) please]
	
	
	
	
	
	
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
	
	[(CanYou) {skupić się na, obserwować} {auto, auto numer, auto o numerze, aucie o numerze, aucie} (Number), (CanYou) podać {mi, mi więcej} informacji o {aucie, aucie numer, numerze} (Number)]

	[Proszę nie podawaj więcej informacji o {aucie, aucie numer, numerze} (Number), Przestań raportować {auto, auto numer} (Number)]