Di seguito troverai l'elenco completo di tutti i comandi vocali riconosciuti da Jona, il l'ingegnere di pista AI insieme ad una breve introduzione alla sintassi delle grammatiche delle frasi.

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

	Se un dato elenco di scelte viene utilizzato in diverse frasi, è possibile definirne una variabile e utilizzare un riferimento alla variabile (il nome dell'elenco di scelte racchiuso tra **(** e **)**) invece di un riferimento esplicito sintassi. Tutte le scelte predefinite sono elencate nella sezione "[Scelte]" del [file grammaticale](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Race%20Engineer.grammars.it) e assomiglia a questo:

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

Information=avvisi carburante, avvisi danni, analisi danni, avvisi meteo, avvisi pressione

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
	
	[(WhatAre) {le, le temperature, le attuali, le} {pressioni delle gomme, pressioni}, (TellMe) {le, le temperature, le attuali, le} {pressioni delle gomme, pressioni}]

	[(WhatAre) {le temperature delle gomme, le attuali temperature delle gomme, le temperature al momento}, (TellMe) {le temperature delle gomme, le attuali temperature delle gomme, le temperature al momento}]
	
	[{Controlla, Per favore controlla} {l'usura delle gomme, l'usura delle gomme al momento}, (TellMe) {l'usura delle gomme, l'usura delle gomme al momento}]

	[(WhatAre) {le temperature dei freni, le attuali temperature dei freni, le temperature dei freni al momento}, (TellMe) {le temperature dei freni, le attuali temperature dei freni, le temperature dei freni al momento}]

	[{Controlla, Per favore controlla} {l'usura dei freni, l'usura dei freni al momento}, (TellMe) {l'usura dei freni, l'usura dei freni al momento}]

	[(TellMe) i giri rimanenti, Quanti giri mancano, Quanti giri restano, Quanti giri alla fine, Quanto tempo manca]

	[Quanto {benzina, carburante} è rimasto, Quanto {benzina, carburante} è {rimasto nel serbatoio, ancora lì}, (TellMe) il {carburante, benzina} rimanente, (WhatIs) il {carburante, benzina} rimanente]

	[Che ne dici del meteo, Pioggia in arrivo, {Qualche cambiamento climatico, Ci sono cambiamenti climatici} in vista, (Puoi) controllare il {meteo, meteo per favore}]

3.  Pitstop

	(CanWe) {ottimizzare, ricalcolare, calcolare} {il rapporto carburante, la quantità di carburante, la quantità di benzina}
	
	(CanWe) {pianificare il pitstop, creare un piano per il pitstop, creare un piano pitstop, elaborare un piano per il pitstop}

	(CanWe) {pianificare il cambio pilota, creare un piano per il cambio pilota, creare un piano di cambio pilota, elaborare un piano per il cambio pilota}

	(CanWe) {preparare il pitstop, far preparare il pitstop alla squadra, preparare tutto per il pitstop}

	[(CanWe) {fare rifornimento, fare rifornimento fino a} (Number) {litri, galloni}, Dobbiamo {fare rifornimento, fare rifornimento fino a} (Number) {litri, galloni}]

	[(CanWe) {usare, passare a} gomme da bagnato, {Possiamo, Per favore} {usare, passare a} gomme da asciutto, {Possiamo, Per favore} {usare, passare a} gomme da intermedio]

	[(CanWe) aumentare {anteriore sinistro, anteriore destro, posteriore sinistro, posteriore destro, tutti} di (Digit) {punto, virgola} (Digit), (Digit) {punto, virgola} (Digit) più pressione per {l'anteriore sinistro, l'anteriore destro, il posteriore sinistro, il posteriore destro, tutti} {pneumatico, pneumatici}]

	[(CanWe) diminuire {anteriore sinistro, anteriore destro, posteriore sinistro, posteriore destro, tutti} di (Digit) {punto, virgola} (Digit), (Digit) {punto, virgola} (Digit) meno pressione per {l'anteriore sinistro, l'anteriore destro, il posteriore sinistro, il posteriore destro, tutti} {pneumatico, pneumatici}]

	[(CanWe) lasciare la {pressione degli pneumatici, pressione} invariata, (CanWe) lasciare la {pressione degli pneumatici, pressione} così com'è, (CanWe) lasciare le {pressioni degli pneumatici, pressioni} invariate, (CanWe) {lasciare, mantenere} le {pressioni degli pneumatici, pressioni} così come sono]

	[(CanWe) {lasciare, mantenere} gli pneumatici sulla macchina, {Per favore} non cambiare gli pneumatici, (CanWe) {lasciare, mantenere} gli pneumatici invariati, Nessun cambio di pneumatici per favore]

	[(CanWe) riparare la sospensione, {Per favore} non riparare la sospensione]

	[(CanWe) riparare la carrozzeria, {Per favore} non riparare la carrozzeria]

	[(CanWe) riparare il motore, {Per favore} non riparare il motore]

	[(CanWe) compensare la perdita di {pressione dei pneumatici, pressione, pressione dei pneumatici per favore, pressione per favore}, {Si prega di compensare, Compensare} la perdita di {pressione dei pneumatici, pressione, pressione dei pneumatici per favore, pressione per favore}]

	[{Per favore non, Non} compensare la perdita di {pressione dei pneumatici, pressione, pressione dei pneumatici per favore, pressione per favore}, {Per favore niente, Niente} più compensazione per la perdita di {pressione dei pneumatici, pressione, pressione dei pneumatici per favore, pressione per favore}]
