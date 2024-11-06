A continuación encontrará una lista completa de todos los comandos de voz reconocidos por Aiden, el entrenador de conducción virtual, junto con una breve introducción a la sintaxis de las gramáticas de frases.

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

Information=Información de la sesión, Información de la Stint, Información de comportamiento de conducción

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

#### Conversación

Utilizarás una conversación gratuita con el Driving Coach en su mayor parte. Por lo tanto, cada comando de voz que no coincida con ninguno de los comandos mostrados anteriormente se reenviará al modelo de lenguaje GPT, lo que dará como resultado un cuadro de diálogo similar al de un humano como se muestra en el [ejemplo](https://github.com/ SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#a-typical-dialog).