Poniżej znajdziesz kompletną listę wszystkich komend głosowych rozpoznawanych przez Jona, inżyniera wyścigowego AI, wraz z krótkim wprowadzeniem do składni gramatyki fraz.

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

Announcements=ostrzeżenia o paliwie, ostrzeżenia o zużyciu opon, ostrzeżenia o zużyciu hamulców, ostrzeżenia o uszkodzeniach, analiza uszkodzeń, ostrzeżenia pogodowe, ostrzeżenia o ciśnieniach

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

	[(WhatIs) {temperatura silnika, aktualne temperatura silnika}, (TellMe) {temperaturę silnika, aktualną temperaturę silnika}]

	[(WhatAre) {ciśnienia opon, ciśnienia opon na zimno, ustawione ciśnienia opon, aktualne ciśnienia}, (TellMe) {ciśnienia opon, ciśnienia opon na zimno, ustawione ciśnienia, aktualne ciśnienia}]

	[(WhatAre) {temperatury opon, aktualne temperatury opon, temperatury w tej chwili}, (TellMe) {temperatury opon, aktualne temperatury opon, temperatury teraz}]

	[{Sprawdź, Proszę sprawdź} {zużycie opon, aktualne zużycie opon}, (TellMe) {zużycie opon, aktualne zużycie opon}]

	[(WhatAre) {temperatury hamulców, aktualne temperatury hamulców}, (TellMe) {temperatury hamulców, aktualne temperatury hamulców}]

	[{Sprawdź, Proszę sprawdź} {zużycie hamulców, aktualne zużycie hamulców}, (TellMe) {zużycie hamulców, aktualne zużycie hamulców}]

	[(TellMe) ile okrążeń zostało, Ile zostało okrążeń, Ile jeszcze okrążeń, Ile do końca, Jak długo do końca]

	[Ile mam {paliwa, benzyny}, Ile zostało {paliwa, benzyny}, (TellMe) ile paliwa zostało, (WhatIs) ilość paliwa]
	
	[Co z pogodą, Czy nadchodzi deszcz, {Czy są, Czy będzie} zmiana pogody, (CanYou) sprawdzić {prognozę, pogodę}]

3. Postój w boksach

	[(CanWe) {optymalizować, przeliczyć, obliczyć} strategię paliwową, (CanWe) {przeliczyć, obliczyć} paliwo, (CanWe) zoptymalizować ilość tankowania, (CanWe) zoptymalizować uzupełnianie energii]

	[(CanWe) {zaplanować pitstop, przygotować plan pitstopu, stworzyć plan pitstopu}]

	[(CanWe) zaplanować zmianę kierowcy, (CanWe) przygotować plan zmiany kierowcy]

	[(CanWe) przygotować pitstop, przygotować wszystko do pitstopu]

	[(CanWe) {zatankować, zatankować do} (Number) {litrów, galonów}, Musimy {zatankować, zatankować do} (Number) {litrów, galonów}]
	
	[(CanWe) {założyć, zmienić na} opony deszczowe, {Czy możemy, Proszę} {założyć, zmienić na} opony suche, {Czy możemy, Proszę} {założyć, zmienić na} opony pośrednie]

	[(CanWe) zwiększyć ciśnienie {przód lewy, przód prawy, tył lewy, tył prawy, wszystkie} o (Digit) {przecinek} (Digit), (Digit) {przecinek} (Digit) więcej ciśnienia dla {przodu lewego, przodu prawego, tyłu lewego, tyłu prawego, wszystkich} opon]

	[(CanWe) zmniejszyć ciśnienie {przód lewy, przód prawy, tył lewy, tył prawy, wszystkie} o (Digit) {przecinek} (Digit), (Digit) {przecinek} (Digit) mniej ciśnienia dla {przodu lewego, przodu prawego, tyłu lewego, tyłu prawego, wszystkich} opon]

	[(CanWe) zostawić {ciśnienie, ciśnienia} bez zmian, pozostawić {ciśnienie, ciśnienia} tak jak są]

	[(CanWe) zostawić opony, Proszę nie zmieniać opon, Nie zmieniamy opon, Nie zmieniać opon]

	[(CanWe) naprawić zawieszenie, Proszę nie naprawiać zawieszenia, nie naprawiać zawieszenia]

	[(CanWe) naprawić nadwozie, Proszę nie naprawiać nadwozia]

	[(CanWe) naprawić silnik, Proszę nie naprawiać silnika, nie naprawiać silnika]

	[(CanWe) {skompensować, skorygować} {spadek ciśnienia opon, spadek ciśnienia}, {Proszę skompensuj, Proszę skoryguj, Skompensuj, Skoryguj} {spadek ciśnienia opon, spadek ciśnienia}, {Weź pod uwagę, Proszę weź pod uwagę} {spadek ciśnienia opon, spadek ciśnienia}]

	[{Nie, Proszę nie} {kompensuj, koryguj} {spadku ciśnienia opon, spadku ciśnienia}, Bez dalszej kompensacji {spadku ciśnienia opon, spadku ciśnienia}]