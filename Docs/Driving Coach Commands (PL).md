Poniżej znajdziesz pełną listę wszystkich poleceń głosowych rozpoznawanych przez Aiden, trenera jazdy AI, wraz z krótkim wprowadzeniem do składni gramatyki fraz.

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

Information=informacje o sesji, informacje o stincie, informacje o prowadzeniu

#### Polecenia

1. Rozmowa

	[Cześć %name%, Hej %name%, %name% słyszysz mnie?, %name% potrzebuję cię, %name% odezwij się proszę]

	[Tak {proszę, jasne}, {Tak, perfekcyjnie} jedziemy dalej, {Ok, jedziemy} {dalej, kontynuuj}, Zgadzam się, Dobrze, Dobra, Potwierdzam]

	[Nie {teraz, dziękuję}, Nie w tej chwili, Negatyw]

	[(CanYou) opowiedzieć mi żart, Masz może jakiś żart?, Dawaj żart]

	[Cisza proszę, Wyłącz się na chwilę, Muszę się skupić, Potrzebuję ciszy, Zamknij się]

	[Okej, możesz mówić, Już cię słyszę, Możesz mówić dalej, Informuj mnie ponownie]

	[{Proszę, Możesz} nie zwracaj więcej uwagi na (Announcements), {Proszę ignoruj, Ignoruj} (Announcements), Wyłącz (Announcements)]

	[{Proszę, Zwracaj uwagę na, Sprawdzaj} (Announcements) ponownie, {Proszę weź, Weź} (Announcements) {pod uwagę, pod uwagę proszę}]

2. Informacje

	[(TellMe) godzina, godzinę, która jest godzina, Jaka jest teraz godzina]
	
3. Coaching

	[(CanYou) daj mi {coaching, lekcję coachingu}, (CanWe) rozpocząć {coaching, trening}, (CanYou) {pomóż, pomóż mi} z {treningiem, jazdą}, (CanYou) {obserwuj, obserwuj moją} jazdę, (CanYou) sprawdź moją {technikę, styl jazdy}, (CanWe) poprawić moje umiejętności]
	
	[Dziękuję {za pomoc, dużo się nauczyłem, to było dobre}, To było super dzięki, Ok wystarczy na dziś]

	[(CanYou) daj mi {przegląd, analizę} całego okrążenia, {Proszę zerknij, Sprawdź} cały tor, Gdzie mogę poprawić się na torze]

	[(CanWe) skupmy się na {zakręcie, zakręcie numer} (Number), {Proszę spójrz, Zobacz} bliżej {zakręt, zakręt numer} (Number), Gdzie mogę się poprawić w {zakręcie, zakręcie numer} (Number)]

	[(CanYou) dawaj mi {wskazówki, porady} podczas jazdy, {Proszę mów, Mów} mi przed każdym {zakrętem}, (CanYou) coachuj mnie na torze]

	[(CanYou) pokaż punkty hamowania, {Proszę powiedz, Powiedz} gdzie hamować, (CanWe) poćwiczyć hamowanie]

	[Teraz chcę się skupić, {Ok pozwól, Pozwól} mi spróbować, {Proszę przestań, Przestań} dawać wskazówki]

	[(CanWe) użyć {najszybszego, ostatniego} okrążenia jako referencji, {Użyj, Proszę użyj} {najszybszego, ostatniego} okrążenia jako wzorca]

	[{Proszę nie, Nie} używaj okrążenia referencyjnego]

	[(CanWe) skupmy się na {zakręcie, zakręcie numer} (Number), (CanYou) daj wskazówki dla {zakrętu, zakrętu numer} (Number)]

	[Skupmy się na całym torze, Wróćmy do pełnego okrążenia]

#### Rozmowa

Dodatkowo, w większości przypadków możesz swobodnie rozmawiać z Instruktorem Jazdy. W związku z tym, każde polecenie głosowe, które nie pasuje do żadnego z powyższych poleceń, zostanie przekazane do modelu języka GPT, co spowoduje dialog przypominający rozmowę z człowiekiem, jak pokazano w [przykładzie](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#a-typical-dialog).