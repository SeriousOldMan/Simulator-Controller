Vous trouverez ci-dessous une liste complète de toutes les commandes vocales reconnues par Cato, le stratège de la course virtuelle, ainsi qu'une brève introduction à la syntaxe des grammaires de phrases.

## Syntaxe

1. Caractères réservés

   Les caractères **[** **]** **{** **}** **(** **)** et **,** lui-même sont tous des caractères spéciaux et ne peuvent pas être utilisés comme fait partie des mots normaux.
   
2. Phrases

   Une phrase est une partie d’une phrase ou même une phrase complète. Il peut contenir n'importe quel nombre de mots séparés par des espaces, mais aucun des caractères réservés. Il peut contenir des parties alternatives (directes ou référencées par leur nom) telles que définies ci-dessous. Exemples:
   
		Mary veut une glace

		(TellMe) ton nom ?
		
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

TellMe=Pouvez-vous me dire, S'il vous plaît, Dites-moi, Pouvez-vous me donner, S'il vous plaît, Donnez-moi, Donnez-moi

WhatAre=Dis-moi, Donne-moi, Qu'est-ce que

WhatIs=Dis-moi, Donne-moi, Qu'est-ce que c'est

CanYou=Pouvez-vous, Pouvons-nous, S'il vous plaît

CanWe=Pouvez-vous, Pouvons-nous, S'il vous plaît

Announcements=avertissements météorologiques

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
	
	[Qu'en est-il de la météo, Est-ce qu'il pleut à venir, S'il y a des changements météorologiques en vue, (CanYou) vérifier la {météo, météo s'il vous plaît}]

	[(TellMe) les tours restants, combien de tours reste-t-il, combien de tours reste-t-il, combien de tours il reste, combien de temps il reste] 

	[Simuler la {course, classement}  (Number) tours, (CanYou) simuler la {course, classement} dans (Number) tours, quelle sera ma position dans (Number) tours, quelle est ma position dans (Number) tours ]

	[(WhatIs) {ma, ma course, ma course actuelle} position, (TellMe) {ma, ma course, ma course actuelle} position]

	[(TellMe) l'écart avec la {voiture devant, voiture devant, position devant, position devant, voiture suivante}, (WhatIs) l'écart avec la {voiture devant, voiture devant, position devant, position devant , voiture suivante}, quelle est la taille de l'écart avec la {voiture devant, voiture devant, position devant, position devant, voiture suivante}]

	[(TellMe) l'écart par rapport à {la voiture derrière moi, la position derrière moi, la voiture précédente}, (WhatIs) l'écart par rapport à {la voiture derrière moi, la position derrière moi, la voiture précédente}, Quelle est sa taille l'écart avec la {voiture derrière moi, position derrière moi, voiture précédente}]

	[(TellMe) l'écart avec la {voiture de tête, leader}, (WhatIs) l'écart avec la {voiture de tête, leader}, Quelle est la taille de l'écart avec la {voiture de tête, leader}]

	[(TellMe) l'écart avec {voiture, numéro de voiture, numéro} (Number), (WhatIs) l'écart avec {voiture, numéro de voiture, numéro} (Number), Quelle est la taille de l'écart avec {voiture, numéro de voiture , numéro} (Number)]

	[(TellMe) le {nom du conducteur, nom du conducteur, conducteur dans la voiture} devant, (WhatIs) le {nom du conducteur, nom du conducteur, conducteur dans la voiture} devant]

	[(TellMe) le {nom du conducteur, nom du conducteur, conducteur dans la voiture} derrière, (WhatIs) le {nom du conducteur, nom du conducteur, conducteur dans la voiture} derrière]

	[(TellMe) la {classe de la voiture, classe de voiture} à venir, (WhatIs) la {classe de voiture, classe de voiture} à venir]

	[(TellMe) la {classe de la voiture, classe de la voiture} derrière, (WhatIs) la {classe de la voiture, classe de la voiture} derrière]

	[(TellMe) la {catégorie de coupe de la voiture, catégorie de coupe de voiture} à venir, (WhatIs) la {catégorie de coupe de la voiture, catégorie de coupe de voiture} à venir]

	[(TellMe) la {catégorie de coupe de la voiture, catégorie de coupe de voiture} derrière, (WhatIs) la {catégorie de coupe de la voiture, catégorie de coupe de voiture} derrière]

	[(TellMe) le temps {tour actuel, dernier tour, tour} de {voiture, numéro de voiture, numéro} (Number), (WhatIs) le temps {tour actuel, dernier tour, tour} de {voiture, numéro de voiture , numéro} (Number)]

	[(TellMe) le {tour actuel, dernier tour, tour} temps de position (Number), (WhatIs) le {tour actuel, dernier tour, tour} temps de position (Number)]

	[(TellMe) {le, mon} {tour actuel, dernier tour, tour} temps, (WhatIs) {mon, le} {tour actuel, dernier tour, tour} temps]

	[(TellMe) les temps du {tour actuel, tour}, (WhatAre) les temps du {tour actuel, tour}]

	[(TellMe) le nombre de {voitures, voitures en piste, voitures en séance, voitures actives, voitures encore actives}, (WhatAre) le nombre de {voitures, voitures en piste, voitures en séance}, Combien de voitures {sont, sont encore} {actives, sur la piste, dans la séance}]

	[(TellMe) combien de fois la {voiture, numéro de voiture, numéro} (Number) est allée aux stands, Combien d’arrêts aux stands la {voiture, numéro de voiture, numéro} (Number) a-t-elle, À quelle fréquence la {voiture, numéro de voiture, numéro} (Number) était-elle dans les stands]

3. Pitstop

	[(WhatIs) le meilleur {tour, option} pour le prochain pitstop, Quand recommandez-vous le prochain pitstop, (CanYou) recommander le prochain arrêt au stand, dans quel tour dois-je venir au stand] 

	[(CanYou) simuler le {prochain arrêt au stand, pitstop} {autour, dans, sur} tour (Number), Planifiez le {prochain arrêt au stand , pitstop} {autour, dans, sur} tour (Number), (CanYou) planifier le {prochain arrêt au stand , pitstop} {autour, dans, sur} tour (Number)]

4. Strategy

	[Quelle est notre stratégie pour {aujourd'hui, la course}, Pouvez-vous me donner un résumé de {la, notre} stratégie, Quelle est notre stratégie, {S'il vous plaît donnez-moi, Donnez-moi} {la, notre} stratégie]

	[(CanYou) {suspendre, annuler} la stratégie, {Suspender, Annuler} la stratégie, La stratégie n'a plus de sens, La stratégie n'a plus de sens]

	[Quand est le prochain arrêt au stand, Dans lequel {le tour est l'arrêt au stand prévu, dois-je venir au stand}, Quand dois-je venir au stand, (TellMe) {le tour pour le prochain arrêt au stand, quand dois-je venir au stand}]

	[(CanYou) développer une nouvelle stratégie, (CanYou) ajuster la stratégie, (CanYou) planifier une nouvelle stratégie, nous avons besoin d'une nouvelle stratégie]

	[{Nous avons un cours jaune, Cours jaune} complet. Que {devrait, puis-je} {je, nous} faire, {Nous avons un cours jaune, Cours jaune} complet. {Devrais-je venir à la fosse, nous devrions venir à la fosse, Venir à la fosse, Venir à la fosse maintenant}]