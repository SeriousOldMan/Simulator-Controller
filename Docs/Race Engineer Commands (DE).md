Nachfolgend ist eine vollständige Liste aller von Jona, dem virtuellen Renningenieur, erkannten Sprachbefehle zusammen mit einer kurzen Einführung in die Syntax der Phrasengrammatiken.

## Syntax

1. Reservierte Zeichen

   Die Zeichen **[**  **]**  **{**  **}**  **(**  **)** und das **,** selbst sind alles Sonderzeichen und dürfen nicht als Teil normaler Wörter verwendet werden.
   
2. Phrasen

   Eine Phrase ist ein Teil eines Satzes oder ein vollständiger Satz. Eine Phrase besteht aus einer durch Leerzeichen getrennten Anzahl von Wörtern, die keines der reservierten Zeichen enthalten dürfen. Es dürfen jedoch alternative Teile (entweder direkt oder namentlich referenziert) verwendet werden, wie unten definiert. Beispiele:
   
		Mary will ein Eis

		(Sag mir deinen Namen?

		Was ist { die, die aktuelle } Uhrzeit?

   Das erste Beispiel ist ein einfacher Satz. Das zweite enthält alternative Teile, wie sie durch die Variable *TellMe* (siehe unten) definiert sind, und das dritte Beispiel verwendet eine lokale Liste von Alternativen und steht für "Wie ist die Uhrzeit?" und "Wie ist die aktuelle Uhrzeit?".


3. Alternativen

   Mit dieser Syntax können alternative Teile einer Phrase definiert werden. Alternative (Sub-)Phrasen müssen von **{** und **}** eingeschlossen und durch Kommas getrennt werden. Jede (Sub-)Phrase darf nur einfache Wörter enthalten. Beispiel:
   
		{ Drücke, Reifendrücke }

   Wenn eine gegebene Liste alternative Teile in mehreren Phrasen verwendet wird, kann eine Variable dafür definiert werden und eine Variablenreferenz (der Name der Liste, eingeschlossen in **(** und **)**) kann anstelle einer expliziten Definition verwendet werden. Alle vordefinierten alternativen Listen sind im Abschnitt "[Choices]" der [Grammatikdatei](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Race%20Engineer.grammars.de) aufgeführt und sehen folgendermaßen aus:

		GibMir=Gib mir, Gib mir bitte, Was sind, Wie sind, Sag mir

   Auf diese vordefinierte Liste von Alternativen kann durch Verwendung von *(GibMir)* als Teil eines Satzes verwiesen werden.

4. Befehle

   Ein vollständiger Befehl ist entweder eine Phrase wie oben definiert oder eine Liste von Phrasen, die durch Kommas getrennt und in **[** und **]** eingeschlossen sind. Jeder dieser Phrasen kann den Befehl einzeln auslösen. Beispiele:

		(GibMir) {die Reifendrücke, die Reifen Drücke, die aktuellen Reifendrücke, die aktuellen Reifen Drücke, die Drücke in den Reifen}
		
		[(KannstDu) (Mir) die Uhrzeit sagen, Wie viel Uhr ist es, Sag {mir bitte, mir} die Uhrzeit]

   Das erste Beispiel ist ein einzelner Satz, aber mit inneren Alternativen. Das zweite Beispiel definiert drei unabhängige Sätze für den Befehl, sogar mit inneren Wahlmöglichkeiten.

## Befehle (gültig ab 4.2.2 und höher)

#### Vordefinierte Auswahlmöglichkeiten

GibMir=Gib mir, Gib mir bitte, Was sind, Wie sind, Sag mir

WasIst=Gib mir, Was ist, Sag mir, Gib mir bitte, Was ist bitte, Sag mir bitte

KannstDu=Kannst Du, Kannst Du bitte

KoennenWir=Kannst Du, Können wir, Kannst Du bitte, Können wir bitte

Mir=mir, mir bitte

Announcements=Benzinmangel Warnungen, Schadenswarnungen, Schadensanalysen, Wetterwarnungen

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

	[(GibMir) {die Reifendrücke, die Reifen Drücke, die aktuellen Reifendrücke, die aktuellen Reifen Drücke, die Drücke in den Reifen}, (KannstDu) (Mir) die {Reifendrücke, Reifen Drücke} {durchgeben, durchgeben bitte, bitte durchgeben}]

	[(GibMir) die {Reifentemperaturen, Reifen Temperaturen, Temperaturen der Reifen im Moment}, (KannstDu) (Mir) die {Reifentemperaturen, Reifen Temperaturen, Temperaturen der Reifen im Moment} {durchgeben, durchgeben bitte, bitte durchgeben}]

	{Sag mir, Überprüfe mal, Überprüfe bitte mal, Bitte überprüfe} {den Reifenverschleiß, den Verschleiß der Reifen, den Reifenverschleiß im Moment, den Verschleiß der Reifen im Moment}

	[{Wie viele, Sag mir wie viele, Sag mir bitte wie viele} Runden {bleiben, gehen} noch, Für wie viele Runden reicht der {Sprit, Sprit noch}, (KannstDu) (Mir) sagen {wie viele Runden noch gehen, wie viele Runden noch bleiben, für wie viele Runden der Sprit noch reicht}]

	[Wie viel {Benzin, Sprit} {ist noch da, haben wir noch, ist noch im Tank, ist noch übrig, bleibt noch}, Sag (Mir) wie viel {Benzin, Sprit} {noch da ist, wir noch haben, noch im Tank ist, noch übrig ist, noch bleibt}]

	[Wie wird das Wetter, Wird es regnen, Kommmt ein Wetterwechsel, Sag (Mir) ob {es regnen wird, ein Wetterwechsel kommt, wie das Wetter wird}]

3.  Boxenstopp

	[(KoennenWir) {den Boxenstopp planen, den Plan für den Boxenstopp erstellen}, (KannstDu) (Mir) den Boxenstopp Plan {durchsagen, durchsagen bitte}]

	(KoennenWir) {den Boxenstopp vorbereiten, die Crew den Boxenstopp vorbereiten lassen, alles für den Boxenstopp vorbereiten}

	[(KoennenWir) (Number) Liter nachtanken, Wir brauchen (Number) Liter]

	[(KoennenWir) Regen Reifen {verwenden, aufziehen}, (KannstDu) Trocken Reifen {verwenden, aufziehen}]

	[(KoennenWir) den Druck {vorne links, vorne rechts, hinten links, hinten rechts} um (Digit) Punkt (Digit) erhöhen, {Vorne links, Vorne rechts, Hinten links, Hinten rechts} (Digit) Punkt (Digit) mehr {Druck, Druck bitte}]

	[(KoennenWir) den Druck {vorne links, vorne rechts, hinten links, hinten rechts} um (Digit) Punkt (Digit) absenken, {Vorne links, Vorne rechts, Hinten links, Hinten rechts} (Digit) Punkt (Digit) weniger {Druck, Druck bitte}]

	[(KoennenWir) den {Luftdruck, Druck} unverändert {lassen, lassen bitte}, (KoennenWir) den {Luftdruck, Druck} so lassen wie er {ist, ist bitte}, (KoennenWir) die {Luftdrücke, Drücke} so lassen wie sie {sind, sind bitte}, (KannstDu) die {Luftdrücke, Drücke} nicht {ändern, ändern bitte}]

	[(KannstDu) die Reifen auf dem Auto {lassen, lassen bitte}, {Bitte die, die} Reifen nicht {wechseln, wechseln bitte}, (KannstDu) die {Reifen, Reifen bitte} drauf {lassen, lassen bitte}]

	[(KannstDu) die Aufhängung {reparieren, reparieren bitte}, (KannstDu) die Aufhängung {bitte nicht, nicht} {reparieren, reparieren bitte}]

	[(KannstDu) die Verkleidung {reparieren, reparieren bitte}, (KannstDu) die Verkleidung {bitte nicht, nicht} {reparieren, reparieren bitte}]