Di seguito troverai l'elenco completo di tutti i comandi vocali riconosciuti da Aiden, coach di guida virtuale insieme ad una breve introduzione alla sintassi delle grammatiche delle frasi.

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

Information=informazioni sulla sessione, informazioni sul turno, informazioni sulla gestione

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

3.  Formazione

	[(CanYou) dammi un {coaching, lezione di coaching}, (CanWe) organizza una sessione di {coaching, formazione, pratica}, (CanYou) {aiutare, aiutami} con {la, mio} {formazione, pratica}, (CanYou) {osservare, guardare} il mio {allenamento, pratica, guida}, (CanYou) {controllare, guardare} la mia {tecnica, stile} di guida, (CanWe) migliorare la mia guida competenze]

	[Grazie {per il tuo aiuto, ho imparato molto, è stato fantastico}, È stato fantastico grazie, Okay per oggi basta]

	[(CanYou) dammi {una panoramica, una panoramica curva per curva, una panoramica per l'intero giro, una panoramica completa, una panoramica completa curva per curva}, {Per favore dai, Dai} un'occhiata al percorso completo, Dove posso migliorare in pista]

	[(CanWe) {concentrarsi, parlare di} {curva, curva numero} (Number), {Per favore dare, Dare} uno {sguardo più attento, guardare} a {curva, curva numero} (Number), Dove posso migliorare {curva, curva numero} (Number), Cosa dovrei considerare per la {curva, curva numero} (Number)]

	[(CanYou) dammi {raccomandazioni, suggerimenti, una guida, istruzioni} {mentre guido, per ogni curva}, {Per favore dimmi, Dimmi} {davanti, per} ogni curva quello che {posso, dovrebbe} cambiare, (CanYou) allenami {in pista, mentre guido}]

	[{Grazie adesso, Adesso} voglio concentrarmi, {Okay lasciami, Lasciami} {applicare, provare} {i tuoi consigli, le tue istruzioni, quello} ora, {Per favore fermati, Fermati} dandomi {raccomandazioni, suggerimenti, istruzioni, consigli per ogni curva, suggerimenti per ogni curva, istruzioni per ogni curva}, {Per favore no, No} altro {istruzioni, istruzioni per favore}]

	[(CanWe) utilizzare il giro {più veloce, ultimo} come {riferimento, giro di riferimento}, {Per favore utilizzare, Utilizzare} il giro {più veloce, ultimo} come {riferimento, giro di riferimento}]

	[{Per favore non, Non} utilizzare un {giro di riferimento, riferimento, giro di riferimento per favore, riferimento per favore}]

#### Conversazione

Per la maggior parte utilizzerai una conversazione gratuita con l'allenatore di guida. Pertanto, ogni comando vocale che non corrisponde a nessuno dei comandi mostrati sopra verrà inoltrato al modello linguistico GPT, che risulterà in una finestra di dialogo simile a quella umana come mostrato nell'[esempio](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#a-typical-dialog).