Di seguito troverai l'elenco completo di tutti i comandi vocali riconosciuti da Elisa, il spotter di gara AI insieme ad una breve introduzione alla sintassi delle grammatiche delle frasi.

## Sintassi

1. Caratteri riservati

   I caratteri **[** **]** **{** **}** **(** **)** e **,** stessi sono tutti caratteri speciali e non possono essere utilizzati come parte delle parole normali.
   
2. Frasi

   Una frase è una parte di una frase o anche una frase completa. Può contenere un numero qualsiasi di parole separate da spazi, ma nessuno dei caratteri riservati. Può contenere parti alternative (dirette o referenziate per nome) come definito di seguito. Esempi:
   
		Mary vuole un gelato

		(TellMe) il tuo nome?
		
		{ Qual è l'ora attuale?, Che ore sono? }
		
   Il primo esempio è una frase semplice. Il secondo consente le scelte definite dalla variabile *TellMe* (vedi sotto), mentre il terzo esempio utilizza una scelta locale e sta per "Che ore sono?" e "Qual è l'ora attuale?".


3. Scelte

   Utilizzando questa sintassi è possibile definire parti alternative di una frase. Le (sotto)frasi alternative devono essere racchiuse tra **{** e **}** e separate da virgole. Ciascuna (sotto)frase può contenere solo parole semplici. Esempio:
   
		{ pressioni, pressioni dei pneumatici }

	Se un dato elenco di scelte viene utilizzato in diverse frasi, è possibile definirne una variabile e utilizzare un riferimento alla variabile (il nome dell'elenco di scelte racchiuso tra **(** e **)**) invece di un riferimento esplicito sintassi. Tutte le scelte predefinite sono elencate nella sezione "[Scelte]" del [file grammaticale](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Choices.it) e assomiglia a questo:

		TellMe=Puoi dirmi, Per favore dimmi, Dimmi, Puoi darmi, Per favore dammi, Dammi

   È possibile fare riferimento a questo elenco di scelte predefinite utilizzando *(TellMe)* come parte di una frase.

4. Comandi

   Un comando completo è una frase come definita sopra o un elenco di frasi separate da virgole e racchiuse tra **[** e **]**. Ognuna di queste frasi può attivare il comando da sola. Esempi:

		(WhatAre) {la pressione dei pneumatici, la pressione attuale dei pneumatici, la pressione dei pneumatici}
		
		[(TellMe) che ore sono, che ore sono, che ore sono {l'ora corrente, l'ora}]

   Il primo esempio è una frase singola, ma con scelte interiori (alternative). Il secondo esempio definisce tre frasi indipendenti per il comando, anche con scelte interne.

## Comandi (validi per 4.2.2 e versioni successive)

#### Scelte predefinite

TellMe=Puoi dirmi, Per favore dimmi, Dimmi, Puoi darmi, Per favore dammi, Dammi

WhatAre=Dimmi, Dammi, Cosa sono

WhatIs=Dimmi, Dammi, Cosa è

CanYou=Puoi, Possiamo, Per favore

CanWe=Puoi, Possiamo, Per favore

Information=informazioni sul delta, consigli tattici, avvisi laterali, avvisi posteriori, avvisi bandiere blu, avvisi bandiere gialle, avvisi di taglio, informazioni sulle penalità, avvisi auto lente, avvisi incidenti davanti, informazioni incidenti dietro

#### Comandi

1.  Conversazione

	[{Ciao, Ehi} %name%, %name% mi senti, %name% ho bisogno di te, %name% dove sei, %name% rispondi per favore]

	[Sì {per favore, certo}, {Sì, Perfetto} vai avanti, {Vai, Ok vai} {avanti, avanti per favore, procedi}, D'accordo, Giusto, Corretto, Confermato, Confermo, Affermativo]

	[No {grazie, non ora, ti richiamerò più tardi}, Non al momento, Negativo]

	[(CanYou) raccontarmi una barzelletta, Hai una barzelletta per me]

	[Stai zitto, Silenzio per favore, Per favore fai silenzio, Devo concentrarmi, {Devo, devo} concentrarmi ora]
	
	[Ok puoi parlare, Posso ascoltare {ora, di nuovo}, Puoi parlare {ora, di nuovo}, Tienimi {informato, aggiornato, aggiornato}]

	[Per favore niente più (Announcements), Niente più (Announcements), Niente più (Announcements) per favore]

	[Per favore dammi (Announcements), Puoi darmi (Announcements), Puoi darmi (Announcements) per favore, Dammi (Announcements), Dammi (Announcements) per favore]

2.  Information

	[(TellMe) l'ora, Che ore sono, Qual è {l'ora attuale, l'orario}]

	[(WhatIs) la mia posizione, (TellMe) la mia posizione]

	[(TellMe) il divario con {l'auto davanti, l'auto in testa, la posizione davanti, la posizione in testa, l'auto successiva}, (WhatIs) il divario con {l'auto davanti, l'auto in testa, la posizione davanti, la posizione in testa, l'auto successiva}, Quanto è grande il divario con {l'auto davanti, l'auto in testa, la posizione davanti, la posizione in testa, l'auto successiva}]

	[(TellMe) il divario con {l'auto dietro di me, la posizione dietro di me, l'auto precedente}, (WhatIs) il divario con {l'auto dietro di me, la posizione dietro di me, l'auto precedente}, Quanto è grande il divario con {l'auto dietro di me, la posizione dietro di me, l'auto precedente}]

	[(TellMe) il divario con {l'auto leader, il leader}, (WhatIs) il divario con {l'auto leader, il leader}, Quanto è grande il divario con {l'auto leader, il leader}]

	[(TellMe) il divario con {l'auto, l'auto numero, numero} (Number), (WhatIs) il divario con {l'auto, l'auto numero, numero} (Number), Quanto è grande il divario con {l'auto, l'auto numero, numero} (Number)]

	[(TellMe) il {nome del pilota, nome del pilota, pilota nell'auto} davanti, (WhatIs) il {nome del pilota, nome del pilota, pilota nell'auto} davanti]

	[(TellMe) il {nome del pilota, nome del pilota, pilota nell'auto} dietro, (WhatIs) il {nome del pilota, nome del pilota, pilota nell'auto} dietro]
	
	[(TellMe) la {classe dell'auto, classe dell'auto} davanti, (WhatIs) la {classe dell'auto, classe dell'auto} davanti]

	[(TellMe) la {classe dell'auto, classe dell'auto} dietro, (WhatIs) la {classe dell'auto, classe dell'auto} dietro]

	[(TellMe) la {categoria della coppa dell'auto, categoria della coppa dell'auto} davanti, (WhatIs) la {categoria della coppa dell'auto, categoria della coppa dell'auto} davanti]

	[(TellMe) la {categoria della coppa dell'auto, categoria della coppa dell'auto} dietro, (WhatIs) la {categoria della coppa dell'auto, categoria della coppa dell'auto} dietro]

	[(TellMe) il {tempo del giro attuale, tempo dell'ultimo giro, tempo del giro} di {l'auto, auto numero, numero} (Number), (WhatIs) il {tempo del giro attuale, tempo dell'ultimo giro, tempo del giro} di {l'auto, auto numero, numero} (Number)]

	[(TellMe) il {tempo del giro attuale, tempo dell'ultimo giro, tempo del giro} della posizione (Number), (WhatIs) il {tempo del giro attuale, tempo dell'ultimo giro, tempo del giro} della posizione (Number)]

	[(TellMe) {il, il mio} {tempo del giro attuale, tempo dell'ultimo giro, tempo del giro}, (WhatIs) {il mio, il} {tempo del giro attuale, tempo dell'ultimo giro, tempo del giro}]

	[(TellMe) i {tempi del giro attuale, tempi del giro}, (WhatAre) i {tempi del giro attuale, tempi del giro}]

	[(TellMe) il numero di {auto, auto in pista, auto nella sessione, auto attive, auto ancora attive}, (WhatAre) il numero di {auto, auto in pista, auto nella sessione}, Quante auto {sono, sono ancora} {attive, in pista, nella sessione}]

	[(TellMe) quanto {spesso, spesso l'} {auto, auto numero, numero} (Number) {è stata, sono state} ai box, Quante soste ai box ha fatto {auto, auto numero, numero} (Number), Quanto spesso è stata ai box {auto, auto numero, numero} (Number)]
	
	[(CanYou) {focalizzarti su, osservare} {auto, numero auto, numero} (Number), (CanYou) darmi {ulteriori, maggiori} informazioni su {auto, numero auto, numero} (Number)]

	[Per favore, non fornire più informazioni su {auto, numero auto, numero} (Number), Smetti di riportare informazioni su {auto, numero auto, numero} (Number)]
