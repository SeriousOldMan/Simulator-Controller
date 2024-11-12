Below you will find a complete list of all voice commands recognized by Aiden, the Virtual Driving Coach together with a short introduction into the syntax of the phrase grammars.

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

Information=session information, stint information, handling information

#### Commands

1.  Conversation

	[{Hi, Hey} %name%, %name% do you hear me, %name% I need you, %name% where are you, %name% come in please]
	
	[Yes {please, of course}, {Yes, Perfect} go on, {Go, Okay go} {on, on please, ahead, ahead please}, I agree, Right, Correct, Confirmed, I confirm, Affirmative]
	
	[No {thank you, not now, I will call you later}, Not at the moment, Negative]

	[(CanYou) tell me a joke, Do you have a joke for me]

	[Shut up, Silence please, Be quiet please, I must concentrate, I {need to, must} focus now]

	[Okay you can talk, I can listen {now, again}, You can talk {now, again}, Keep me {informed, updated, up to date}]

	[{Please do, Do} not {pay attention, investigate} (Information) anymore, {Please ignore, Ignore} (Information), Ignore (Information) please]

	[{Please pay attention to, Pay attention to, Please investigate, Investigate} (Information) again, {Please take, Take} (Information) into {account, account please}]

2.  Information

	[(TellMe) the time, What time is it, What is the {current time, time}]
	
3.  Coaching

	[(CanYou) give me a {coaching, coaching lesson}, (CanWe) run a {coaching, training, practice, practise} session, (CanYou) {help, help me} with {the, my} {training, practice, practise}, (CanYou) {observe, watch} my {training, practice, practise, driving}, (CanYou) {check, watch} my driving {technique, style}, (CanWe) improve my driving skills]

	[Thank you {for your help, I learned a lot, that was great}, That was great thank you, Okay that's enough for today]

	[(CanYou) give me {an overview, an overview corner by corner, an overview for zhe whole lap, a complete overview, a complete overview corner by corner}, {Please take, Take} a look at the complete track, Where can I improve around the track]

	[(CanWe) {focus on, talk about} {corner number, corner} (Number), {Please take, Take} a {closer look, look} at {corner number, corner} (Number), Where can I improve in {corner number, corner} (Number), What should I consider {for, in} {corner number, corner} (Number)]

	[(CanYou) give me {recommendations, tips, a guide, instructions} {while I am driving, while driving, for each corner}, {Please tell, Tell} me {ahead of, for} each corner what I {can, should} change, (CanYou) coach me {on the track, while I am driving, while driving}]

	[{Thank you now, Now} I want to focus, {Okay let, Let} me {apply, try} {your recommendations, your instructions, that} now, {Please stop, Stop} giving me {recommendations, tips, instructions, recommendations for each corner, tips for each corner, instructions for each corner}, {Please no, No} more {instructions, instructions please}]

	[(CanWe) use the {fastest, last} lap as {reference, reference lap}, {Please use, Use} the {fastest, last} lap as {reference, reference lap}]

	[{Please do, Do} not use a reference {lap, lap please}]

#### Conversation

Additionally, you can have a free conversation with the Driving Coach for the most part. Therefore, every voice command, that does not match any of the commands shown above will be forwarded to the GPT language model, which will result in a human-like dialog as shown in the [example](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#a-typical-dialog).