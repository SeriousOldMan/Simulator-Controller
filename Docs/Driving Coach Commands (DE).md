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

	[{Bitte beachte, Beachte} (Information) nicht mehr, {Bitte ignoriere, Ignoriere} (Information), Ignoriere (Information) bitte]

	[{Beachte, Berücksichtige, Bitte beachte, Bitte berücksichtige} (Information) wieder, {Beachte wieder, Berücksichtige wieder, Bitte beachte wieder, Bitte berücksichtige wieder} (Information)]

#### Gespräch

Du wirst größtenteils einen freien Dialog mit dem Fahrtrainer führen. Daher wird jeder Sprachbefehl, der keinem der oben gezeigten Befehle entspricht, an das GPT-Sprachmodell weitergeleitet. Das Resultat ist ein sehr natürlicher Dialog mit dem virtuellen Fahrtrainer, wie im [Beispiel](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#a-typical-dialog) gezeigt.