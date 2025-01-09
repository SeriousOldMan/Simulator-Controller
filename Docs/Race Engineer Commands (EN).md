Below you will find a complete list of all voice commands recognized by Jona, the AI Race Engineer together with a short introduction into the syntax of the phrase grammars.

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

Announcements=fuel warnings, damage warnings, damage analysis, weather warnings, pressure warnings

#### Commands

1.  Conversation

	[{Hi, Hey} %name%, %name% do you hear me, %name% I need you, %name% where are you, %name% come in please]

	[Yes {please, of course}, {Yes, Perfect} go on, {Go, Okay go} {on, on please, ahead, ahead please}, I agree, Right, Correct, Confirmed, I confirm, Affirmative]

	[No {thank you, not now, I will call you later}, Not at the moment, Negative]

	[(CanYou) tell me a joke, Do you have a joke for me]

	[Shut up, Silence please, Be quiet please, I must concentrate, I {must, need to} focus now, Please be quiet]

	[Okay you can talk, I can listen {now, again}, You can talk {now, again}, Keep me {informed, updated, up to date}]

	[Please no more (Announcements), No more (Announcements), No more (Announcements) please]

	[Please give me (Announcements), Can you give me (Announcements), Can you give me (Announcements) please, Give me (Announcements), Give me (Announcements) please]

2.  Information

	[(TellMe) the time, What time is it, What is the {current time, time}]

	[(WhatAre) {the, the cold, the current, the setup} {tire pressures, pressures}, (TellMe) {the, the cold, the current, the setup} {tire pressures, pressures}]

	[(WhatAre) {the tire temperatures, the current tire temperatures, the temperatures at the moment}, (TellMe) {the tire temperatures, the current tire temperatures, the temperatures at the moment}]

	[{Check, Please check} {the tire wear, the tire wear at the moment}, (TellMe) {the tire wear, the tire wear at the moment}]
	
	[(WhatAre) {the brake temperatures, the current brake temperatures, the brake temperatures at the moment}, (TellMe) {the brake temperatures, the current brake temperatures, the brake temperatures at the moment}]

	[{Check, Please check} {the brake wear, the brake wear at the moment}, (TellMe) {the brake wear, the brake wear at the moment}]

	[(TellMe) the remaining laps, How many laps are remaining, How many laps are left, How many laps to go, How long to go]

	[How much {gas, fuel} is left, How much {gas, fuel} is {left in the tank, still there}, (TellMe) the remaining {gas, fuel}, (WhatIs) the remaining {gas, fuel}]

	[What about the weather, Is rain ahead, {Any, Are} weather changes in sight, (CanYou) check the {weather, weather please}]

3.  Pitstop

	[(CanWe) {optimize, recalculate, calculate} the fuel ratio, (CanWe) optimize the refuel amount, (CanWe) optimize the energy replenishment]
	
	(CanWe) {plan the pitstop, create a plan for the pitstop, create a pitstop plan, come up with a pitstop plan}
	
	(CanWe) {plan the driver swap, create a plan for the driver swap, create a driver swap plan, come up with a driver swap plan}

	(CanWe) {prepare the pitstop, let the crew prepare the pitstop, setup everything for the pitstop}

	[(CanWe) refuel (Number) {liters, gallons}, We need to refuel (Number) {liters, gallons}]

	[(CanWe) {use, switch to} wet tires, {Can we, Please} {use, switch to} dry tires, {Can we, Please} {use, switch to} intermediate tires]

	[(CanWe) increase {front left, front right, rear left, rear right, all} by (Digit) {point, comma} (Digit), (Digit) {point, comma} (Digit) more pressure for {the front left, the front right, the rear left, the rear right, all} {tire, tires}]
	
	[(CanWe) decrease {front left, front right, rear left, rear right, all} by (Digit) {point, comma} (Digit), (Digit) {point, comma} (Digit) less pressure for {the front left, the front right, the rear left, the rear right, all} {tire, tires}]
	
	[(CanWe) leave the {tire pressure, pressure} unchanged, (CanWe) leave the {tire pressure, pressure} as it is, (CanWe) leave the {tire pressures, pressures} unchanged, (CanWe) {leave, keep} the {tire pressures, pressures} as they are]

	[(CanWe) {leave, keep} the tires on the car, {Please} do not change the tires, (CanWe) {leave, keep} the tires unchanged, No tire change please]

	[(CanWe) repair the suspension, {Please} do not repair the suspension]

	[(CanWe) repair the bodywork, {Please} do not repair the bodywork]
	
	[(CanWe) repair the engine, {Please} do not repair the engine]
	
	[(CanWe) {compensate, compensate for} {tyre pressure, pressure} {loss, loss please}, {Please do compensate, Please do compensate for, Compensate, Compensate for} {tyre pressure, pressure} {loss, loss please}, {Take, Please take} the {tyre pressure loss, pressure loss} into {account, account please}]
	
	[{Do not, Please do not} {compensate, compensate for} {tyre pressure, pressure} {loss, loss please}, No more compensation for {tyre pressure, pressure} {loss, loss please}]
