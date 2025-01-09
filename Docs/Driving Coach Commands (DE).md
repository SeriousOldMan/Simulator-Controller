Nachfolgend ist eine vollständige Liste aller von Aiden, dem virtuellen Fahrtrainer, erkannten Sprachbefehle zusammen mit einer kurzen Einführung in die Syntax der Phrasengrammatiken.

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

   Wenn eine gegebene Liste alternative Teile in mehreren Phrasen verwendet wird, kann eine Variable dafür definiert werden und eine Variablenreferenz (der Name der Liste, eingeschlossen in **(** und **)**) kann anstelle einer expliziten Definition verwendet werden. Alle vordefinierten alternativen Listen sind im Abschnitt "[Choices]" der [Grammatikdatei](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Race%20Engineer.grammars.de) aufgeführt und sehen folgendermaßen aus:

		SagMir=Gib mir, Gib mir bitte, Sag mir

   Auf diese vordefinierte Liste von Alternativen kann durch Verwendung von *(SagMir)* als Teil eines Satzes verwiesen werden.

4. Befehle

   Ein vollständiger Befehl ist entweder eine Phrase wie oben definiert oder eine Liste von Phrasen, die durch Kommas getrennt und in **[** und **]** eingeschlossen sind. Jeder dieser Phrasen kann den Befehl einzeln auslösen. Beispiele:

		(SagMir) {die Reifendrücke, die Reifen Drücke, die aktuellen Reifendrücke, die aktuellen Reifen Drücke, die Drücke in den Reifen}
		
		[(KannstDu) (Mir) die Uhrzeit sagen, Wie viel Uhr ist es, Sag {mir bitte, mir} die Uhrzeit]

   Das erste Beispiel ist ein einzelner Satz, aber mit inneren Alternativen. Das zweite Beispiel definiert drei unabhängige Sätze für den Befehl, sogar mit inneren Wahlmöglichkeiten.

## Befehle (gültig ab 5.4.1 und höher)

#### Vordefinierte Auswahlmöglichkeiten

Information=Session Information, Stint Information, Information zum Fahrverhalten

#### Befehle

1.  Konversation

	[{Hi, Hey} %name%, %name% hörst du mich, %name% ich brauche Dich, Hey %name% wo bist Du]
	
	[Einverstanden, Ja bitte, Ja mach weiter, Perfekt mach weiter, Mach weiter bitte, Okay weitermachen, Okay machen wir weiter, Richtig]
	
	[Nein {danke, jetzt nicht, nicht jetzt, ich melde mich später}, Auf keinen Fall]

	[(KannstDu) (Mir) einen Witz erzählen, Bitte erzähl mir einen Witz, Hast du einen Witz für mich]

	[Halt die Klappe, Ruhe bitte, Sei still bitte, Ich muss mich konzentrieren, (KannstDu) {ruhig sein, still sein, die Klappe halten}]

	[Okay Du kannst sprechen, Ich kann {jetzt, wieder} zuhören, Du kannst {jetzt, wieder} sprechen]

	[{Bitte beachte, Beachte} (Information) nicht mehr, {Bitte ignoriere, Ignoriere} (Information), Ignoriere (Information) bitte]

	[{Beachte, Berücksichtige, Bitte beachte, Bitte berücksichtige} (Information) wieder, {Beachte wieder, Berücksichtige wieder, Bitte beachte wieder, Bitte berücksichtige wieder} (Information)]

2.  Information

	[(KannstDu) (Mir) die Uhrzeit sagen, Wie viel Uhr ist es, Sag {mir bitte, mir} die Uhrzeit]

3.  Training

	[(KannstDu) (Mir) {beim, bei meinem} Training helfen, (KannstDu) {mein Training, meinen Fahrstil} beobachten, (KannstDu) meine Fahrtechnik überprüfen, Ich brauche mal {Deine Hilfe, ein Training, ein Coaching}]

	[{Ich danke Dir, Danke} für Deine {Hilfe, Unterstützung}, {Danke ich, Ich} habe viel {gelernt, gelernt danke}, Das war {großartig, prima, großartig danke, prima danke}, Okay {das, dass} ist genug für heute]

	[(KannstDu) (Mir) {einen Überblick über die, eine Zusammenfassung der} {letzte Runde, letzten Runde, Runde} geben, {Bitte schau, Schau} Dir mal {die ganze, die} {Runde, Strecke} an, Wo kann ich mich verbessern, Worauf soll ich {achten, achten um mich zu verbessern}]

	[(KannstDu) (Mir) eine Einschätzung von Kurve (Number) geben, {Kannst Du Dir mal, Schau Dir mal, Kannst Du Dir bitte mal, Bitte schau Dir mal} Kurve (Number) {anschauen, anschauen bitte}, Wie kann ich mich in Kurve (Number) verbessern, Worauf soll ich in Kurve (Number) achten]

	[(KannstDu) (Mir) {Anweisungen, Anweisungen für jede Kurve} {geben, geben während ich fahre}, (GibMir) {Anweisungen, Anweisungen für jede Kurve}, {Bitte sag, Sag} (Mir) {vor jeder Kurve, für jede Kurve} {wie ich mich verbessern kann, was ich ändern muss}]

	[{Danke jetzt, Jetzt} muss ich mich {konzentrieren, konzentrieren danke}, {Okay jetzt, Jetzt} werde {ich das, ich Deine Anweisungen, ich Deine Hinweise} erst {mal, einmal} anwenden, {Danke jetzt, Jetzt} komme ich erstmal alleine klar, {Bitte keine, Keine} Hinweise mehr]

	[(KoennenWir) die {schnellste, letzte} Runde als {Referenz, Referenzrunde} verwenden, {Bitte verwende, Verwende} die {schnellste, letzte} Runde als {Referenz, Referenzrunde}, {Bitte als, Als} {Referenz, Referenzrunde} die {schnellste, letzte} Runde {verwenden, verwenden bitte}]

	[{Bitte keine, Keine} {Referenzrunde mehr, Referenzrunde} {verwenden, verwenden bitte}]

#### Gespräch

Daneben kannst Du größtenteils einen freien Dialog mit dem Fahrtrainer führen. Daher wird jeder Sprachbefehl, der keinem der oben gezeigten Befehle entspricht, an das GPT-Sprachmodell weitergeleitet. Das Resultat ist ein sehr natürlicher Dialog mit dem virtuellen Fahrtrainer, wie im [Beispiel](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#a-typical-dialog) gezeigt.