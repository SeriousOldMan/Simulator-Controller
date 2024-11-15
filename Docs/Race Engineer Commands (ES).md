A continuación encontrará una lista completa de todos los comandos de voz reconocidos por Jona, el ingeniero de carrera virtual, junto con una breve introducción a la sintaxis de las gramáticas de frases.

## Sintaxis

1. Personajes reservados

   Los caracteres **[** **]** **{** **}** **(** **)** y el propio **,** son todos caracteres especiales y no pueden usarse como parte de las palabras normales.
   
2. Frases

   Una frase es parte de una oración o incluso una oración completa. Puede contener cualquier número de palabras separadas por espacios, pero ninguno de los caracteres reservados. Puede contener partes alternativas (ya sea directas o referenciadas por su nombre) como se define a continuación. Ejemplos:
   
		Maria quiere un helado

		(TellMe) ¿tu nombre?
		
		¿Cuál es la { hora, hora actual }?
		
   El primer ejemplo es una frase sencilla. El segundo permite opciones definidas por la variable *TellMe* (ver más abajo), y el tercer ejemplo utiliza una opción local y significa "¿Cuál es la hora?" y "¿Cuál es la hora actual?".

3. Opciones

   Usando esta sintaxis se pueden definir partes alternativas de una frase. Las (sub)frases alternativas deben ir entre **{** y **}** y deben estar separadas por comas. Cada (sub)frase puede contener sólo palabras simples. Ejemplo:
   
		{ presiones, presiones de neumáticos }

   Si una determinada lista de opciones se utiliza en varias frases, se puede definir una variable para ella y se puede utilizar una referencia de variable (el nombre de la lista de opciones encerrado entre **(** y **)**) en lugar de explícito sintaxis. Todas las opciones predefinidas se enumeran en la sección "[Choices]" del [archivo de gramática](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Race%20Engineer.grammars.es) y se ve así:

		TellMe=Puedes decirme, Por favor dime, Puedes darme, Por favor dame, Dame

   Se puede hacer referencia a esta lista de opciones predefinidas utilizando *(TellMe)* como parte de una frase. Se puede hacer referencia a esta lista de opciones predefinidas utilizando *(TellMe)* como parte de una frase.

4. Comandos

   Un comando completo es una frase como se define anteriormente o una lista de frases separadas por comas y encerradas entre **[** y **]**. Cada una de estas frases puede activar el comando por sí sola. Ejemplos:

		(WhatAre) {las presiones de los neumáticos, las presiones actuales de los neumáticos, las presiones de los neumáticos}
		
		[(TellMe) la hora, qué hora es, cuál es la {hora actual, hora}]

   El primer ejemplo es una frase única, pero con opciones internas (alternativas). El segundo ejemplo define tres frases independientes para el comando, incluso con opciones internas.

## Comandos (válidos para 4.2.2 y posteriores)

#### Opciones predefinidas

TellMe=Puedes decirme, Por favor dime, Puedes darme, Por favor dame, Dame

WhatAre=Dime, dame, Cuales es

WhatIs=Dime, dame, qué es

CanYou=Puedes, por favor

CanWe=Puedes, podemos, por favor

Announcements=advertencias de combustible, advertencias de daños, análisis de daños, advertencias meteorológicas, advertencias de presión

#### Comandos

1.  Conversación

	[{Hola, Hey} %name%, %name% me escuchas, %name% te necesito, Hey %name% donde estas?]
	
	[Si, De acuerdo, Perfecto]
	
	[No, No más tarde]
	
	[(CanYou) contarme un chiste, Te sabes algun chiste]
	
	[Silencio, Calla, para]
	
	[Habla, Te escucho {ahora, otra vez}, ya puedes hablar {ahora, otra vez}]
	
	[Nada de (Announcements)]
	
	[Dame (Announcements)]

2.  Información

	[(TellMe) decirme la hora, Que hora es, Cual es la {hora actual, hora}]
	
	[(WhatAre) {la presión de los neumaticos, la presión frías de los neumaticos, la presión Setup de los neumaticos, la presión actual, la presión frías, la presión Setup}, (TellMe) la presión {actual, frías, Setup}]
	
	[(WhatAre) la temperatura {de los neumaticos, actual de los neumaticos}, (TellMe) darme la temperatura de los neumaticos]
	
	[{Revisa, Comprueba} {el desgaste de los neumáticos, el desgaste de los neumáticos en este momento}, (TellMe) {el desgaste de los neumáticos, el desgaste de los neumáticos en este momento}]
	
	[(WhatAre) {las temperaturas de los frenos, las temperaturas actuales de los frenos, las temperaturas de los frenos en este momento}, (TellMe) {las temperaturas de los frenos, las temperaturas actuales de los frenos, las temperaturas de los frenos en este momento}]
	
	[{Revisa, Comprueba} {el desgaste de los frenos, el desgaste de los frenos en este momento}, (TellMe) {el desgaste de los frenos, el desgaste de los frenos en este momento}]
	
	[(TellMe) las vueltas que faltan, Cuantas vueltas quedan, Cuántas vueltas faltan]
	
	[Cuanto {deposito, gasolina} queda, cuanto {deposito, gasolina} queda en el tanque, (TellMe) {el deposito que, cuanta gasolina} queda,]

3.  Parada en boxes

	(CanWe) {planificar la parada, crear un plan para la parada}
	
	(CanWe) {planificar la cambio de piloto, crear un plan para la cambio de piloto}
	
	(CanWe) {preparar la parada, configurar la parada}
	
	[(CanWe) repostar (Number) {Litros, Galones}, Necesitor repostar (Number) {Litros, Galones}, (CanWe) recargar hasta 10 {Litros, Galones}]
	
	[(CanWe) {usar, cambiar a} neumaticos secos, Podemos {usar, cambiar a} neumaticos de lluvia, Podemos {usar, cambiar a} neumaticos intermedio]
	
	[(CanWe) incrementa {en la rueda delantera izquierda, en la rueda delantera derecha, en la rueda trasera izquierda, en la rueda trasera derecha, en todas las ruedas} con (Digit) {punto, coma} (Digit), (Digit) {punto, coma} (Digit) más de presión {en la rueda delantera izquierda, en la rueda delantera derecha, en la rueda trasera izquierda, en la rueda trasera derecha, en todas las ruedas}]
	
	[(CanWe) disminuye {en la rueda delantera izquierda, en la rueda delantera derecha, en la rueda trasera izquierda, en la rueda trasera derecha, en todas las ruedas} con (Digit) {punto, coma} (Digit), (Digit) {punto, coma} (Digit) menos de presión {en la rueda delantera izquierda, en la rueda delantera derecha, en la rueda trasera izquierda, en la rueda trasera derecha, en todas las ruedas}]
	
	[(CanWe) dejar la {presión de los neumáticos, la presión} sin cambios, (CanWe) dejar la {presión de los neumáticos, presión} como está, (CanWe) dejar las {presiones de los neumáticos, presiones} sin cambios, (CanWe) {dejar, mantener} las {presiones de los neumáticos, presiones} como están]
	
	[(CanWe) {dejar, mantener} los neumáticos en el coche, no cambiar los neumáticos, (CanWe) {dejar, mantener} los neumáticos]
	
	[(CanWe) repare la suspensión, no reparar la suspensión]
	
	[(CanWe) reparar el chasis, no reparar el chasis]
	
	[(CanWe) repare el motor, no reparar el motor]
	
	[(CanWe) compensar la pérdida de {presión, presión de los neumáticos, presión por favor, presión de los neumáticos por favor}, Compense la pérdida de {presión, presión de los neumáticos, presión por favor, presión de los neumáticos por favor}, {Tenga, Tener} en cuenta la pérdida de {presión, presión de los neumáticos}]
	
	[{Por favor no, No} compensar la pérdida de {presión, presión de los neumáticos, presión por favor, presión de los neumáticos por favor}, No más compensación por la pérdida de {presión, presión de los neumáticos, presión por favor, presión de los neumáticos por favor}]
