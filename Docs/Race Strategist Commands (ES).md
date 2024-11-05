A continuación encontrará una lista completa de todos los comandos de voz reconocidos por Cato, el estratega de carrera virtual, junto con una breve introducción a la sintaxis de las gramáticas de frases.

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

   Si una determinada lista de opciones se utiliza en varias frases, se puede definir una variable para ella y se puede utilizar una referencia de variable (el nombre de la lista de opciones encerrado entre **(** y **)**) en lugar de explícito sintaxis. Todas las opciones predefinidas se enumeran en la sección "[Choices]" del [archivo de gramática] (https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Race%20Engineer.grammars.es) y se ve así:

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

Announcements=avisos meteorológicos

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

	[(TellMe) las vueltas restantes, Cuántas vueltas quedan, Cuántas vueltas quedan, Cuántas vueltas faltan]
FuturePosition=[Simula la {carrera, la clasificación} en (Number) vueltas, (CanYou) simular la {carrera, clasificación} en (Number) vueltas, ¿Cuál será mi posición en (Number) vueltas, ¿Cuál sera mi posición en (Number) vueltas]

	[Como esta el tiempo, Puede llover, hay cambio de teimpo, (CanYou) comprobar el tiempo]

	[Simula la {carrera, la clasificación} en (Number) vueltas, (CanYou) simular la {carrera, clasificación} en (Number) vueltas, ¿Cuál será mi posición en (Number) vueltas, ¿Cuál sera mi posición en (Number) vueltas]
	
	[(WhatIs) mi posición en {mi carrera, mi carrera actual}, (TellMe)mi posición en {mi carrera, mi carrera actual}]
	
	[(TellMe) la diferencia con el {coche de delante, coche de delante, posición de delante, posición de delante, coche siguiente}, (WhatIs) la diferencia con el {coche de delante, coche de delante, posición de delante, posición de delante, siguiente coche}, Qué diferencia hay con el {coche de delante, coche de delante, posición de delante, posición de delante, siguiente coche}]
	
	[(TellMe) la diferencia con {el coche que viene detrás de mí, la posición detrás de mí, el coche anterior}, (WhatIs) a diferencia con {el coche detrás de mí, la posición detrás de mí, el coche anterior}, Cómo de grande es la diferencia con el {coche detrás de mí, la posición detrás de mí, el coche anterior}]
	
	[(TellMe) la diferencia con el {coche líder, líder}, (WhatIs) la diferencia con el {coche líder, líder}, Qué tan grande es la diferencia con el {coche líder, líder}]
	
	[(TellMe) la diferencia con el {coche, coche número, número} (Number), (WhatIs) la diferencia con el {coche, coche número, número} (Number), Qué tan grande es la diferencia con el {coche, coche número, número} (Number)]
	
	[(TellMe) el {nombre del conductor, conductor del coche} de delante, (WhatIs) el {nombre del conductor, conductor del coche} de delante]
	
	[(TellMe) el {nombre del conductor, conductor del coche} de atrás, (WhatIs) el {nombre del conductor, conductor del coche} de atrás]
	
	[(TellMe) la clase del coche que va delante, (WhatIs) la clase del coche que va delante]
	
	[(TellMe) la clase del coche de atrás, (WhatIs) la clase del coche de atrás]
	
	[(TellMe) la categoría de copa del coche de delante, (WhatIs) la categoría de copa del coche de delante]
	
	[(TellMe) la categoría de copa del coche de atrás, (WhatIs) la categoría de copa del coche de atrás]
	
	[(TellMe) los tiempo de {última vuelta, vuelta} del {coche, coche número, número} (Number), (WhatIs) los tiempo de {última vuelta, vuelta} del {coche, coche número, número} (Number)]
	
	[(TellMe) los tiempo de {última vuelta, vuelta} de la posición (Number), (WhatIs) los tiempo de {última vuelta, vuelta} de la posición (Number)]
	
	[(TellMe) {los, mi} tiempo de {última vuelta, vuelta}, (WhatIs) {los, mi} tiempo de {última vuelta, vuelta}]
	
	[(TellMe) los tiempos de {vuelta actual, vuelta}, (WhatAre) los tiempos {actuales de la vuelta, vuelta}]
	
	[(TellMe) el número de {coches, coches en la pista, coches en la sesión}, (WhatAre) el número de {coches, coches en la pista, coches en la sesión}, Cuantos coches hay en la pista, Cuantos coches siguen activos, Cuántos coches hay en la sesión]
	
	[(TellMe) cuantas veces ha estado en boxes el {coche, coche número, número} (Number), Cuántas paradas en boxes tiene el {coche, coche número, número} (Number), Con qué frecuencia estuvo el {coche, coche número, número} (Number) en boxes]

3. Parada en boxes

	[(WhatIs) la mejor {vuelta, opción} para el próximo pitstop, ¿Cuándo recomienda el próximo pitstop, (CanYou) recomendar la próxima parada en boxes, en qué vuelta debo entrar en boxes]
	
	[(CanYou) simular la {siguiente parada en boxes, pitstop} {alrededor, en} la vuelta (Number), Planificar la {siguiente parada en boxes, pitstop} {alrededor, en} la vuelta (Number), (CanYou) planificar la {siguiente parada en boxes, pitstop} {alrededor, en} la vuelta (Number)]

4. Estrategia

	[Cómo es nuestra estrategia para {hoy, la carrera}, Puedes darme un resumen de {la, nuestra} estrategia, Cómo es nuestra estrategia, Dame {por favor} {la, nuestra} estrategia]

	[(CanYou) {suspender, cancelar} la estrategia, {Suspender, cancelar} la estrategia, La estrategia ya no tiene sentido, La estrategia ya no tiene sentido]

	[Cuándo es la próxima parada en boxes, En qué {vuelta está prevista la parada en boxes, debo entrar en boxes}, Cuándo debo entrar en boxes, (TellMe) {la vuelta para la siguiente parada en boxes, cuando debería entrar en boxes}]

	[(CanYou) desarrollar una nueva estrategia, (CanYou) ajustar la estrategia, (CanYou) planear una nueva estrategia, Necesitamos una nueva estrategia]

	[{Contamos con Curso, Curso} Completo Amarillo. Qué {tengo que, podemos} hacer, {Contamos con Curso, Curso} Completo Amarillo. {Debería ir a boxes ahora, Debería venir a boxes, Debería hacer boxes, Debería ir a boxes ahora}]