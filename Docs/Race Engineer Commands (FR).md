Vous trouverez ci-dessous une liste complète de toutes les commandes vocales reconnues par Jona, l'ingénieur de course AI, ainsi qu'une brève introduction à la syntaxe des grammaires de phrases.

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

   Si une liste de choix donnée est utilisée dans plusieurs phrases, une variable peut être définie pour elle et une référence de variable (le nom de la liste de choix entouré de **(** et **)**) peut être utilisée à la place d'une référence explicite. syntaxe. Tous les choix prédéfinis sont répertoriés dans la section "[Choices]" du [fichier de grammaire](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Choices.fr) et ressemble à ceci:

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

Announcements=avertissements de carburant, avertissements d'usure des pneus, avertissements d'usure des freins, avertissements de dommages, analyse des dommages, avertissements météo, avertissements de pression

#### Commandes

1.  Conversation

	[{Salut, Hé} %name%, %name% m'entendez-vous, %name% j'ai besoin de vous, %name% où es-tu, %name% entre s'il te plaît]

	[Oui {s'il vous plaît, bien sûr}, {Oui, parfait} continuez, {Allez, Okay, allez} {continuez, continuez s'il vous plaît, avancez, avancez s'il vous plaît}, Je suis d'accord, C'est vrai, Je corrige, Je confirme, Je confirme, Affirmatif]

	[Non {merci, pas maintenant, je t'appellerai plus tard}, Pas pour le moment, Négatif]

	[(CanYou) me raconter une blague, As-tu une blague pour moi]

	[Tais-toi, Silence s'il te plaît, Tais-toi s'il te plaît, Je dois me concentrer, Je {dois, dois} me concentrer maintenant]

	[D'accord, Vous pouvez parler, Je peux écouter {maintenant, encore}, Vous pouvez parler {maintenant, encore}, Tenez-moi {informé, mis à jour, à jour}]

	[{S'il vous plaît pas plus, Pas plus} (Announcements), Pas plus (Announcements) s'il vous plaît]

	[S'il vous plaît donnez-moi (Announcements), Pouvez-vous me donner (Announcements), Pouvez-vous me donner (Announcements) s'il vous plaît, Donnez-moi (Announcements), Donnez-moi (Announcements) s'il vous plaît]

2.  Information

	[(TellMe) l'heure, Quelle heure est-il, Quelle est {l'heure, l'heure actuelle}]

	[(WhatAre) {le, le froid, la configuration, le courant} {pressions des pneus, pressions}, (TellMe) {le, le froid, la configuration, le courant} {pressions des pneus, pressions}]

	[(WhatAre) {les températures des pneus, les températures actuelles des pneus, les températures du moment}, (TellMe) {les températures des pneus, les températures actuelles des pneus, les températures du moment}]

	[{Vérifiez, Veuillez vérifier} {l'usure des pneus, l'usure des pneus en ce moment}, (TellMe) {l'usure des pneus, l'usure des pneus en ce moment}]

	[(WhatAre) {les températures des freins, les températures actuelles des freins, les températures des freins en ce moment}, (TellMe) {les températures des freins, les températures actuelles des freins, les températures des freins en ce moment}]

	[{Vérifier, Veuillez vérifier} {l'usure des freins, l'usure des freins en ce moment}, (TellMe) {l'usure des freins, l'usure des freins en ce moment}]
	
	[(WhatAre) {les températures du moteur, les températures actuelles du moteur}, (TellMe) {les températures du moteur, les températures actuelles du moteur}]

	[(TellMe) les tours restants, Combien de tours reste-t-il, Combien de tours reste-t-il, Combien de tours restants, Combien de temps reste-t-il]

	[Combien de {gaz, carburant} reste-t-il, Combien de {gaz, carburant} reste-t-il {restant dans le réservoir, toujours là}, (TellMe) le {gaz, carburant} restant, (WhatIs) le {gaz, carburant} restant]

	[Qu'en est-il de la météo, Est-ce qu'il pleut à venir, S'il y a des changements météorologiques en vue, (CanYou) vérifier la {météo, météo s'il vous plaît}]

3.  Arrêt au stand

	(CanWe) {optimiser, recalculer, calculer} [le rapport carburant, la quantité de carburant, la quantité d'essence}
	
	(CanWe) {planifier l'arrêt au stand, créer un plan pour l'arrêt au stand, créer un plan d'arrêt au stand, proposer un plan d'arrêt au stand}

	(CanWe) {planifier l'échange de pilote, créer un plan pour l'échange de pilote, créer un plan d'échange de pilote, proposer un plan d'échange de pilote}

	(CanWe) {préparer l'arrêt au stand, laisser l'équipage préparer l'arrêt au stand, tout configurer pour l'arrêt au stand}

	[(CanWe) {faire le plein, faire le plein jusqu'à} (Number) {litres, gallons}, Nous devons {faire le plein, faire le plein jusqu'à} (Number) {litres, gallons}]

	[(CanWe) {utiliser, passer à} pneus pluie, {Pouvons-nous, s'il vous plaît} {utiliser, passer à} pneus secs, {Pouvons-nous, s'il vous plaît} {utiliser, passer à} pneus intermédiaires]

	[(CanWe) augmenter {avant gauche, avant droit, arrière gauche, arrière droit, tous} de (Digit) {point, virgule} (Digit), (Digit) {point, virgule} (Digit) plus de pression pour { l'avant gauche, l'avant droit, l'arrière gauche, l'arrière droit, tous} {pneu, pneus}]

	[(CanWe) diminuer {avant gauche, avant droit, arrière gauche, arrière droit, tous} de (Digit) {point, virgule} (Digit), (Digit) {point, virgule} (Digit) moins de pression pour { l'avant gauche, l'avant droit, l'arrière gauche, l'arrière droit, tous} {pneu, pneus}]

	[(CanWe) laisser la {pression des pneus, pression} inchangée, (CanWe) laisser la {pression des pneus, pression} telle quelle, (CanWe) laisser les {pressions des pneus, pressions} inchangées, (CanWe) {laisser, garder} les {pressions des pneus, pressions} telles quelles]

	[(CanWe) {laisser, garder} les pneus sur la voiture, {S'il vous plaît} ne pas changer les pneus, (CanWe) {laisser, garder} les pneus inchangés, Pas de changement de pneus s'il vous plaît]

	[(CanWe) réparer la suspension, {Veuillez} ne pas réparer la suspension]

	[(CanWe) répare la carrosserie, {Veuillez} ne pas réparer la carrosserie]

	[(CanWe) réparer le moteur, {S'il vous plaît} ne réparez pas le moteur]

	[(CanWe) compenser la perte de {pression des pneus, pression}, {Veuillez prendre, Prendre} en compte la perte de {pression des pneus, pression}]

	[{Ne compense pas, Veuillez ne pas compenser} la perte de {pression des pneus, pression, pression des pneus s'il vous plaît, pression s'il vous plaît}, Aucune compensation pour la perte de {pression des pneus, pression, pression des pneus s'il vous plaît, pression s'il vous plaît}]
