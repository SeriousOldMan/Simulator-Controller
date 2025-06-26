Below you will find a complete list of all voice commands recognized by Elisa, the AI Race Spotter together with a short introduction into the syntax of the phrase grammars.

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

   If a given list of choices is used in several phrases, a variable may be defined for it and a variable reference (the name of the choices list enclosed by **(** and **)**) may be used instead of explicit syntax. All predefined choices are listed in the section "[Choices]" of the [grammar file](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Choices.en) and look like this:

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

Announcements=delta information, tactical advice, side alerts, rear alerts, blue flag warnings, yellow flag warnings, cut warnings, penalty information, slow car warnings, ahead accidents warnings, behind accidents information

#### Commands

1.  Conversation

	[{Hi, Hey} %name%, %name% do you hear me, %name% I need you, %name% where are you]

	[Yes {please, of course}, {Yes, Perfect} go on, {Go, Okay go} {on, on please, ahead, ahead please}, I agree, Right, Correct, Confirmed, I confirm, Affirmative]

	[No {thank you, not now, I will call you later}, Not at the moment, Negative]

	[(CanYou) tell me a joke, Do you have a joke for me]

	[Shut up, Silence please, Be quiet please, I must concentrate, I {need to, must} focus now]

	[Okay you can talk, I can listen {now, again}, You can talk {now, again}, Keep me {informed, updated, up to date}]

	[Please no more (Announcements), No more (Announcements), No more (Announcements) please]

	[Please give me (Announcements), Can you give me (Announcements), Can you give me (Announcements) please, Give me (Announcements), Give me (Announcements) please]

2.  Information

	[(TellMe) the time, What time is it, What is the {current time, time}]

	[(WhatIs) {my, my race, my current race} position, (TellMe) {my, my race, my current race} position]

	[(TellMe) the gap to the {car in front, car ahead, position in front, position ahead, next car}, (WhatIs) the gap to the {car in front, car ahead, position in front, position ahead, next car}, How big is the gap to the {car in front, car ahead, position in front, position ahead, next car}]

	[(TellMe) the gap to {the car behind me, the position behind me, the previous car}, (WhatIs) the gap to {the car behind me, the position behind me, the previous car}, How big is the gap to the {car behind me, position behind me, previous car}]

	[(TellMe) the gap to the {leading car, leader}, (WhatIs) the gap to the {leading car, leader}, How big is the gap to the {leading car, leader}]
	
	[(TellMe) the gap to {car, car number, number} (Number), (WhatIs) the gap to {car, car number, number} (Number), How big is the gap to {car, car number, number} (Number)]
	
	[(TellMe) the {driver name, name of the driver, driver in the car} ahead, (WhatIs) the {driver name, name of the driver, driver in the car} ahead]

	[(TellMe) the {driver name, name of the driver, driver in the car} behind, (WhatIs) the {driver name, name of the driver, driver in the car} behind]
	
	[(TellMe) the {class of the car, car class} ahead, (WhatIs) the {class of the car, car class} ahead]
	
	[(TellMe) the {class of the car, car class} behind, (WhatIs) the {class of the car, car class} behind]
	
	[(TellMe) the {cup category of the car, car cup category} ahead, (WhatIs) the {cup category of the car, car cup category} ahead]
	
	[(TellMe) the {cup category of the car, car cup category} behind, (WhatIs) the {cup category of the car, car cup category} behind]
	
	[(TellMe) the {current lap, last lap, lap} time of {car, car number, number} (Number), (WhatIs) the {current lap, last lap, lap} time of {car, car number, number} (Number)]
	
	[(TellMe) the {current lap, last lap, lap} time of position (Number), (WhatIs) the {current lap, last lap, lap} time of position (Number)]

	[(TellMe) {the, my} {current lap, last lap, lap} time, (WhatIs) {my, the} {current lap, last lap, lap} time]

	[(TellMe) the {current lap, lap} times, (WhatAre) the {current lap, lap} times]
	
	[(TellMe) the number of {cars, cars on the track, cars in the session, active cars, cars still active}, (WhatAre) the number of {cars, cars on the track, cars in the session}, How many cars {are, are still} {active, on the track, in the session}]
	
	[(TellMe) how often {the car, the car number, number} (Number) {was, have been} in the pits, How many pitstops has {car, car number, number} (Number), How often has been {car, car number, number} (Number) in the pits]
	
	[(CanYou) {focus on, observe} {car, car number, number} (Number), (CanYou) give {me, me more} information about {car, car number, number} (Number)]
	
	[Please no more information on {car, car number, number} (Number), Stop reporting on {car, car number, number} (Number) please]