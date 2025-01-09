Nachfolgend ist eine vollständige Liste aller von Elisa, dem virtennbeobachter, erkannten Sprachbefehle zusammen mit einer kurzen Einführung in die Syntax der Phrasengrammatiken.

## Syntax

1. Reservierte Zeichen

   Die Zeichen **[**  **]**  **{**  **}**  **(**  **)** und das **,** selbst sind alles Sonderzeichen und dürfen nicht als Teil normaler Wörter verwendet werden.
   
2. Phrasen

   Eine Phrase ist ein Teil eines Satzes oder ein vollständiger Satz. Eine Phrase besteht aus einer durch Leerzeichen getrennten Anzahl von Wörtern, die keines der reservierten Zeichen enthalten dürfen. Es dürfen jedoch alternative Teile (entweder direkt oder namentlich referenziert) verwendet werden, wie unten definiert. Beispiele:
   
		Mary will ein Eis

		(SagMir) deinen Namen?

		Was ist { die, die aktuelle } Uhrzeit?

   Das erste Beispiel ist ein einfacher Satz. Das zweite enthält alternative Teile, wie sie durch die Variable *SagMir* (siehe unten) definiert sind, und das dritte Beispiel verwendet eine lokale Liste von Alternativen und steht für "Wie ist die Uhrzeit?" und "Wie ist die aktuelle Uhrzeit?".


3. Alternativen

   Mit dieser Syntax können alternative Teile einer Phrase definiert werden. Alternative (Sub-)Phrasen müssen von **{** und **}** eingeschlossen und durch Kommas getrennt werden. Jede (Sub-)Phrase darf nur einfache Wörter enthalten. Beispiel:
   
		{ Drücke, Reifendrücke }

   Wenn eine gegebene Liste alternative Teile in mehreren Phrasen verwendet wird, kann eine Variable dafür definiert werden und eine Variablenreferenz (der Name der Liste, eingeschlossen in **(** und **)**) kann anstelle einer expliziten Definition verwendet werden. Alle vordefinierten alternativen Listen sind im Abschnitt "[Choices]" der [Grammatikdatei](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Race%20Spotter.grammars.de) aufgeführt und sehen folgendermaßen aus:

		SagMir=Gib mir, Gib mir bitte, Sag mir

   Auf diese vordefinierte Liste von Alternativen kann durch Verwendung von *(SagMir)* als Teil eines Satzes verwiesen werden.

4. Befehle

   Ein vollständiger Befehl ist entweder eine Phrase wie oben definiert oder eine Liste von Phrasen, die durch Kommas getrennt und in **[** und **]** eingeschlossen sind. Jeder dieser Phrasen kann den Befehl einzeln auslösen. Beispiele:

		(SagMir) {die Reifendrücke, die Reifen Drücke, die aktuellen Reifendrücke, die aktuellen Reifen Drücke, die Drücke in den Reifen}
		
		[(KannstDu) (Mir) die Uhrzeit sagen, Wie viel Uhr ist es, Sag {mir bitte, mir} die Uhrzeit]

   Das erste Beispiel ist ein einzelner Satz, aber mit inneren Alternativen. Das zweite Beispiel definiert drei unabhängige Sätze für den Befehl, sogar mit inneren Wahlmöglichkeiten.

## Befehle (gültig ab 4.2.2 und höher)

#### Vordefinierte Auswahlmöglichkeiten

Announcements=Abstandsinformationen, Taktische Hinweise, Seitenwarnungen, Heckwarnungen, Blaue Flagge Warnungen, Gelbe Flagge Warnungen, Abkürzungswarnungen, Strafeninformationen, Langsame Wagen Warnungen, Unfälle voraus Warnungen, Unfälle zurückliegend Informationen

KannstDu=Kannst Du, Kannst Du bitte

KoennenWir=Kannst Du, Können wir, Kannst Du bitte, Können wir bitte

Mir=mir, mir bitte

#### Befehle

1.  Konversation

	[{Hi, Hey} %name%, %name% hörst du mich, %name% ich brauche Dich, Hey %name% wo bist Du]

	[Einverstanden, Ja bitte, Ja mach weiter, Perfekt mach weiter, Mach weiter bitte, Okay weitermachen, Okay machen wir weiter, Richtig]

	[Nein {danke, jetzt nicht, nicht jetzt, ich melde mich später}, Auf keinen Fall]

	[(KannstDu) (Mir) einen Witz erzählen, Bitte erzähl mir einen Witz, Hast du einen Witz für mich]

	[Halt die Klappe, Ruhe bitte, Sei still bitte, Ich muss mich konzentrieren, (KannstDu) {ruhig sein, still sein, die Klappe halten}]

	[Okay Du kannst sprechen, Ich kann {jetzt, wieder} zuhören, Du kannst {jetzt, wieder} sprechen]

	[Bitte {gib mir keine, keine} (Announcements) mehr, {Gib mir keine, Keine} (Announcements) {mehr, mehr bitte}]

	[Bitte gib (Mir) (Announcements), Gib (Mir) (Announcements), Gib (Mir) (Announcements) bitte, (KannstDu) (Mir) (Announcements) {geben, geben bitte}]

2.  Information

	[(KannstDu) (Mir) die Uhrzeit sagen, Wie viel Uhr ist es, Sag {mir bitte, mir} die Uhrzeit]

	[Wie ist {meine, meine aktuelle} Position, Gib (Mir) {meine, meine aktuelle} Position, (KannstDu) (Mir) {meine, meine aktuelle} Position sagen]

	[{Gib mir den, Gib mir bitte den, Sag mir den, Sag mir bitte den, Wie ist der} Abstand zu {dem Wagen, der Position} vor mir, Wie groß ist die Lücke zu {dem Wagen, der Position} vor mir]

	[{Gib mir den, Gib mir bitte den, Sag mir den, Sag mir bitte den, Wie ist der} Abstand zu {dem Wagen, der Position} hinter mir, Wie groß ist die Lücke zu {dem Wagen, der Position} hinter mir]

	[{Gib mir den, Gib mir bitte den, Sag mir den, Sag mir bitte den, Wie ist der} Abstand zum führenden Wagen, Wie groß ist {die Lücke, der Abstand} zum {Führenden, führenden Wagen, ersten Platz}]
	
	[{Gib mir den, Gib mir bitte den, Sag mir den, Sag mir bitte den, Wie ist der} Abstand {zu, zur, zum} {Wagen, Wagen Nummer, Nummer} (Number), Wie groß ist {die Lücke, der Abstand} {zu, zur, zum} {Wagen, Wagen Nummer, Nummer} (Number)]
	
	[(KannstDu) (Mir) den {Fahrernamen, Fahrernamen im Wagen} vor mir {durchgeben, sagen}, Wie heißt der {Fahrer, Fahrer im Wagen} vor mir, Wie ist der Name des {Fahrers, Fahrers im Wagen} vor mir]

	[(KannstDu) (Mir) den {Fahrernamen, Fahrernamen im Wagen} hinter mir {durchgeben, sagen}, Wie heißt der {Fahrer, Fahrer im Wagen} hinter mir, Wie ist der Name des {Fahrers, Fahrers im Wagen} hinter mir]

	[(KannstDu) (Mir) die {Fahrzeugklasse, Klasse des Wagens} vor mir {durchgeben, sagen}, Wie ist {Fahrzeugklasse, Klasse des Wagens} vor mir]

	[(KannstDu) (Mir) die {Fahrzeugklasse, Klasse des Wagens} hinter mir {durchgeben, sagen}, Wie ist {Fahrzeugklasse, Klasse des Wagens} hinter mir]

	[(KannstDu) (Mir) die {Pokalkategorie, Pokalkategorie des Wagens} vor mir {durchgeben, sagen}, Wie ist {Pokalkategorie, Pokalkategorie des Wagens} vor mir]

	[(KannstDu) (Mir) die {Pokalkategorie, Pokalkategorie des Wagens} hinter mir {durchgeben, sagen}, Wie ist {Pokalkategorie, Pokalkategorie des Wagens} hinter mir]

	[(KannstDu) (Mir) die {Rundenzeit, letzte Rundenzeit, Zeit, letzte Zeit} {des, von} {Wagens, Wagens Nummer, Nummer} (Number) {durchgeben, sagen}, {Gib, Sag} (Mir) die die {Rundenzeit, letzte Rundenzeit, Zeit, letzte Zeit} {des, von} {Wagens, Wagens Nummer, Nummer} (Number)]

	[(KannstDu) (Mir) die {Rundenzeit, letzte Rundenzeit, Zeit, letzte Zeit} von Position (Number) {durchgeben, sagen}, {Gib, Sag} (Mir) die die {Rundenzeit, letzte Rundenzeit, Zeit, letzte Zeit} von Position (Number)]

	[(KannstDu) (Mir) {die, meine} {Rundenzeit, letzte Rundenzeit, Zeit, letzte Zeit} {durchgeben, sagen}, {Gib, Sag} (Mir) {die, meine} {Rundenzeit, letzte Rundenzeit, Zeit, letzte Zeit}, Wie ist {die, meine} {Rundenzeit, letzte Rundenzeit, Zeit, letzte Zeit}]

	[(KannstDu) (Mir) die {Rundenzeiten, Zeiten} {durchgeben, sagen}, {Gib, Sag} (Mir) die {Rundenzeiten, Zeiten}, Wie sind die {Rundenzeiten, Zeiten}, Welche {Rundenzeiten, Zeiten} fahren wir]
	
	[(KannstDu) (Mir) die Anzahl der {Wagen, Fahrzeuge} {durchgeben, durchgeben die noch auf der Strecke sind, durchgeben die noch in der Session sind, durchgeben die noch aktiv sind}, Wie viele {Wagen, Fahrzeuge} {sind, sind noch} {aktiv, auf der Strecke, in der Session}]
	
	[(KannstDu) (Mir) sagen wie {oft, oft der} {Wagen, Wagen Nummer, Nummer} (Number) {schon in, in} der Box war, Wie viele Boxenstopps {hat, hat der} {Wagen, Wagen Nummer, Nummer} (Number), Wie oft {war, war der} {Wagen, Wagen Nummer, Nummer} (Number) {schon in, in} der Box]
	
	[(KannstDu) (Mir) mehr Informationen {zu, zur, zum} {Wagen, Wagen Nummer, Nummer} (Number) geben, (KannstDu) {Wagen, Wagen Nummer, Nummer} (Number) beobachten]
	
	[Bitte gib mir keine weiteren Informationen zu {car, car number, number} (Number) mehr, Keine weiteren Informationen zu {car, car number, number} (Number) mehr bitte]