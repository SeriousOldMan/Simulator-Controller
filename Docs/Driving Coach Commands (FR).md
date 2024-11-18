Vous trouverez ci-dessous une liste complète de toutes les commandes vocales reconnues par Aiden, le coach de conduite virtuel ainsi qu'une brève introduction à la syntaxe des grammaires de phrases.

## Syntaxe

1. Caractères réservés

   Les caractères **[** **]** **{** **}** **(** **)** et **,** lui-même sont tous des caractères spéciaux et ne peuvent pas être utilisés comme fait partie des mots normaux.
   
2. Phrases

   Une phrase est une partie d’une phrase ou même une phrase complète. Il peut contenir n'importe quel nombre de mots séparés par des espaces, mais aucun des caractères réservés. Il peut contenir des parties alternatives (directes ou référencées par leur nom) telles que définies ci-dessous. Exemples:
   
		Mary veut une glace

		(TellMe) ton nom?
		
		Quelle { heure est-il, est l'heure actuelle }?
		
   Le premier exemple est une phrase simple. Le deuxième permet des choix tels que définis par la variable *TellMe* (voir ci-dessous), et le troisième exemple utilise un choix local et signifie "Quelle heure est-il?" et "Quelle est l'heure actuelle?".


3. Choix

   En utilisant cette syntaxe, des parties alternatives d'une phrase peuvent être définies. Les (sous-)phrases alternatives doivent être entourées de **{** et **}** et doivent être séparées par des virgules. Chaque (sous-)phrase ne peut contenir que des mots simples. Exemple:
   
		{ pressions, pressions des pneus }

   Si une liste de choix donnée est utilisée dans plusieurs phrases, une variable peut être définie pour elle et une référence de variable (le nom de la liste de choix entouré de **(** et **)**) peut être utilisée à la place d'une référence explicite. syntaxe. Tous les choix prédéfinis sont répertoriés dans la section "[Choices]" du [fichier de grammaire](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Race%20Engineer.grammars.fr) et ressemble à ceci:

		TellMe=Pouvez-vous me dire, S'il vous plaît, Dites-moi, Pouvez-vous me donner, S'il vous plaît, Donnez-moi, Donnez-moi

   Cette liste de choix prédéfinis peut être référencée en utilisant *(TellMe)* dans le cadre d'une phrase.

4. Commandes

   Une commande complète est soit une phrase telle que définie ci-dessus, soit une liste de phrases séparées par des virgules et entourées de **[** et **]**. Chacune de ces phrases peut déclencher la commande à elle seule. Exemples:

		(WhatAre) {les pressions des pneus, les pressions actuelles des pneus, les pressions dans les pneus}
		
		[(TellMe) l'heure, Quelle {heure est-il, est l'heure actuelle}]

   Le premier exemple est une seule phrase, mais avec des choix intérieurs (alternatives). Le deuxième exemple définit deux phrases indépendantes pour la commande, même avec des choix internes.

## Commandes (valables pour 4.2.2 et versions ultérieures)

#### Choix prédéfinis

TellMe=Pouvez-vous me dire, S'il vous plaît dites-moi, Pouvez-vous me donner, S'il vous plaît donnez-moi, Donnez-moi

WhatAre=Dis-moi, Donne-moi, Qu'est-ce que

WhatIs=Dis-moi, Donne-moi, Qu'est-ce que c'est

CanYou=Pouvez-vous, S'il vous plaît pouvez-vous

CanWe=Pouvez-vous, Pouvons-nous, S'il vous plaît pouvez-vous, S'il vous plaît pouvons-nous

Information=informations sur la session, informations sur le relais, informations sur la gestion

#### Commandes

1.  Conversation

	[{Salut, Hé} %name%, %name% m'entendez-vous, %name% j'ai besoin de vous, %name% où êtes-vous, %name% entrez s'il vous plaît]

	[Oui {s'il vous plaît, bien sûr}, {Oui, Parfait} continuez, {Allez, Okay allez} {continuez, continuez s'il vous plaît, avancez, avancez s'il vous plaît}, J'accepte, Bien, Correct, Confirmé, Je confirme, Affirmatif]

	[Non {merci, pas maintenant, je vous appellerai plus tard}, Pas pour le moment, Négatif]

	[(CanYou) me raconter une blague, As-tu une blague pour moi]

	[Tais-toi, Silence s'il te plaît, Tais-toi s'il te plaît, Je dois me concentrer, Je {dois, dois} me concentrer maintenant]

	[D'accord, Vous pouvez parler, Je peux écouter {maintenant, encore}, Vous pouvez parler {maintenant, encore}, Tenez-moi {informé, mis à jour, à jour}]

	[{Veuillez le faire, Ne} plus {faire attention, enquêter} (Information), {Veuillez ignorer, Ignorer} (Information), Ignorer (Information) s'il vous plaît]

	[{Veuillez faire attention à, Faites attention à, Veuillez enquêter, Enquêter} (Information) à nouveau, {Veuillez prendre, Prendre} (Information) dans {compte, compte s'il vous plaît}]

2.  Information

	[(TellMe) l'heure, Quelle heure est-il, Quelle est {l'heure, l'heure actuelle}]

3.  Entraînement

	[(CanYou) me donner {un coaching , une leçon de coaching}, (CanWe) organiser une séance {de coaching, de formation, d'entraînement}, (CanYou) m'aider avec ma {formation, pratique}, (CanYou) {observer, regarder} {mon entraînement, ma pratique, ma conduite}, (CanYou) {vérifier, regarder} {ma technique, mon style} de conduite, (CanWe) améliorer mes compétences de conduite]

	[Merci {pour votre aide, j'ai beaucoup appris, c'était super}, C'était super merci, Okay that's enough for today, D'accord, c'est assez pour aujourd'hui]

	[(CanYou) me donner {un aperçu, un aperçu virage par virage, un aperçu de tout le tour, un aperçu complet, un aperçu complet virage par virage}, {Veuillez jeter, Jetez} un oeil à la piste complète, Où peut-on je m'améliore sur la piste]

	[(CanWe) {concentrer sur le, parler de} {coin numéro, coin} (Number), {Veuillez regarder, Regarder} {de plus près le, un oeil au} {coin numéro, coin} (Number), Où puis-je m'améliorer dans {coin numéro, coin} (Number), Que dois-je considérer {pour, dans} le {coin numéro, coin} (Number)]

	[(CanYou) me donner {des recommandations, des conseils, un guide, des instructions} {pendant que je conduis, en conduisant, à chaque virage}, {S'il vous plaît dites-moi, Dites-moi} {avant, pour} chaque coin ce que je {peut, devrais} changer, (CanYou) {m'entraîner sur la piste, me coacher pendant que je conduis, me coacher en conduisant}]
	
	[{Merci maintenant, Maintenant} je veux me concentrer, Ok, laisse-moi {appliquer, essayer} {tes instructions, vos recommandations, ça} maintenant, {S'il vous plaît arrêtez, Arrêtez} de me donner des {instructions, recommandations, instructions pour chaque coin, recommandations pour chaque coin}, {S'il vous plaît plus, Plus} {d'instructions, d'instructions s'il vous plaît}]

	[(CanWe) utiliser le tour le plus rapide comme {référence, tour de référence}, {Veuillez utiliser, Utiliser} le tour le plus rapide comme {référence, tour de référence}]

	[{S'il vous plaît n'utilisez, N'utilisez} pas de référence {tour, tour s'il vous plaît}]

#### Conversation

Vous utiliserez pour la plupart une conversation gratuite avec le Driving Coach. Par conséquent, chaque commande vocale qui ne correspond à aucune des commandes indiquées ci-dessus sera transmise au modèle de langage GPT, ce qui entraînera une boîte de dialogue de type humain, comme indiqué dans l'[exemple](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#a-typical-dialog).