Below you will find a complete list of all voice commands recognized by Jona, the Virtual Race Engineer together with a short introduction into the syntax of the phrase grammars.

## Syntax

1. Reserved characters

   The characters **[**  **]**  **{**  **}**  **(**  **)** and the  **,**  itself are all special characters and may not be used as part of normal words.
   
2. Phrases

   A phrase is a part of a sentence or even a complete sentence. It may contain any number of words separated by spaces, but none of the reserved characters. It may contain alternative parts (either direct or referenced by name) as defined below. Examples:
   
		Mary wants an icecream

		(TellMe) your name?
		
		What is { the, the current } time?
		
   The first example is a simple phrase. The second one allows for choices as defined by the variable *TellMe* (see below), and the third example uses a local choice and stands for "What is the time?" and "What is the current time?".


3. Choices

   Using this syntax alternative parts of a phrase can be defined. Alternative (sub-)phrases must be enclosed by **{** and **}** and must be seperated by commas. Each (sub-)phrase may contain only simple words. Example:
   
		{ pressures, tyre pressures }

   If a given list of choices is used in several phrases, a variable may be defined for it and a variable reference (the name of the choices list enclosed by **(** and **)**) may be used instead of explicit syntax. All predefined choices are listed in the section "[Choices]" of the [grammar file](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Race%20Engineer.grammars.en) and look like this:

		TellMe=Can you tell me, Please tell me, Tell me, Can you give me, Please give me, Give me

   This predefined choices list can be referenced by using *(TellMe)* as part of a phrase.

4. Commands

   A full command is either a phrase as defined above or a list of phrases separated by commas and enclosed in **[** and **]**. Each of these phrases can trigger the command on its own. Examples:

		(WhatAre) {the tire pressures, the current tire pressures, the pressures in the tires}
		
		[(TellMe) the time, What time is it, What is the {current time, time}]

   The first example is a single phrase, but with inner choices (alternatives). The second example defines three independent phrases for the command, even with inner choices.

## Commands (valid for 4.2.2 and later)

#### Predefined Choices

TellMe=Can you tell me, Please tell me, Tell me, Can you give me, Please give me, Give me

WhatAre=Tell me, Give me, What are

WhatIs=Tell me, Give me, What is

CanYou=Can you, Please

CanWe=Can you, Can we, Please

Announcements=fuel warnings, damage warnings, damage analysis, weather warnings

#### Commands

1.  Conversation

	[{Hi, Hey} %name%, %name% do you hear me, %name% I need you, Hey %name% where are you]

	[Yes please, Yes of course, Yes go on, Perfect go on, Go on please, Head on please, Okay let's go on, I agree, Right]

	[No {thank you, not now, I will call you later}, Not at the moment]

	[(CanYou) tell me a joke, Do you have a joke for me]

	[Shut up, Silence please, Be quiet please, I must concentrate]

	[Okay you can talk, I can listen {now, again}, You can talk {now, again}]

	[Please no more (Announcements), No more (Announcements), No more (Announcements) please]

	[Please give me (Announcements), Can you give me (Announcements), Can you give me (Announcements) please, Give me (Announcements), Give me (Announcements) please]

2.  Information

	[(TellMe) the time, What time is it, What is the {current time, time}]

	[(WhatAre) {the tire pressures, the current tire pressures, the pressures in the tires}, (TellMe) the current pressures]

	[(WhatAre) {the tire temperatures, the current tire temperatures, the temperatures at the moment}, (TellMe) {the tire temperatures, the current tire temperatures, the temperatures at the moment}]

	[{Check, Please check} {the tire wear, the tire wear at the moment}, (TellMe) {the tire wear, the tire wear at the moment}]
	
	[(WhatAre) {the brake temperatures, the current brake temperatures, the brake temperatures at the moment}, (TellMe) {the brake temperatures, the current brake temperatures, the brake temperatures at the moment}]

	[{Check, Please check} {the brake wear, the brake wear at the moment}, (TellMe) {the brake wear, the brake wear at the moment}]

	[(TellMe) the remaining laps, How many laps are remaining, How many laps are left, How many laps to go]

	[How much {gas, fuel} is left, How much {gas, fuel} is {left in the tank, still there}, (TellMe) the remaining {gas, fuel}, (WhatIs) the remaining {gas, fuel}]

	[What about the weather, Is rain ahead, {Any, Are} weather changes in sight, (CanYou) check the {weather, weather please}]

3.  Pitstop

	(CanWe) {plan the pitstop, create a plan for the pitstop, create a pitstop plan, come up with a pitstop plan}

	(CanWe) {prepare the pitstop, let the crew prepare the pitstop, setup everything for the pitstop}

	[(CanWe) refuel (Number) litres, We need to refuel (Number) litres]

	[(CanWe) {use, switch to} wet tires, {Can we, Please} {use, switch to} dry tires, {Can we, Please} {use, switch to} intemediate tires]

	[(CanWe) increase {front left, front right, rear left, rear right} by (Digit) point (Digit), (Digit) point (Digit) more pressure for the {front left, front right, rear left, rear right} tire]

	[(CanWe) decrease {front left, front right, rear left, rear right} by (Digit) point (Digit), (Digit) point (Digit) less pressure for the {front left, front right, rear left, rear right} tire]

	[(CanWe) leave the {tire pressure, pressure} unchanged, (CanWe) leave the {tire pressure, pressure} as it is, (CanWe) leave the {tire pressures, pressures} unchanged, (CanWe) {leave, keep} the {tire pressures, pressures} as they are]

	[(CanWe) {leave, keep} the tires on the car, {Please} do not change the tires, (CanWe) {leave, keep} the tires unchanged]

	[(CanWe) repair the suspension, {Please} do not repair the suspension]

	[(CanWe) repair the bodywork, {Please} do not repair the bodywork]
	
	[(CanWe) repair the engine, {Please} do not repair the engine]