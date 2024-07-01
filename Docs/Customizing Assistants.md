## Introduction

All Virtual Assistants like the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer), [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist) and [Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter) have been implemented using a rule engine and *classical* voice recognition and speech generation. The [Driving Coach](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach) is already different, since the nature of this Assistant is a natural conversation with you as a driver using a lot of real world knowledge about sim racing and motorsports in general. The Driving Coach therefore is based on the famous GPT (aka general pretrained transformer, a kind of neural network) technology using a large language model (also termed LLM).

But is also possible to connect the rule based Assistants to an LLM to improve the cnversational capabilities or to alter or even extend the behavior of the given Assistant. This all can be achieved by configuring the so called Assistant Boosters. The following documentation will give you all information you need to setup the Assistant Boosters.

Note: Seting up a connection to a GPT service and configuring the Assistant Boosters require some knowledge. Customizing the *Conversation* and the *Reasoning* bosters may require even some development skills. If you feel overwhelmed, no problem. Simply leave it aside and use the Assistants without connecting them to a GPT service. The will do their job. Or you can become a Patreon of the project and I will setup everything for you.

## Connecting an Assistant to an LLM

The voice recognition for all Assistants except the Driving Coach is normally pattern-based. [Here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Engineer-Commands-(EN)), for example, you can find a documentation for the definition of the recognized commands of the Race Engineer and similar documentation is available for the other Assistants as well. The speech output of all Assistants is also preprogrammed with several different phrases for each message, to create at least a little variation.

Said this, it is clear, that the interaction with the Assistants, although already impressive, will not feel absolutely natural in many cases. But using the latest development in AI with LLMs (aka large language model) it became possible to improve the conversation capabilities of the Assistants even further. Whenever you see a small button with an icon which looks like a launching space rocket, you can configure AI pre- and post-processing for voice recognition, speech output and general conversation.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Speech%20Improvement.JPG)

IMPORTANT: All this is optional. The Race Assistants will do their job really good even without being connected to an LLM. Therefore I recommend to use this feature not before everything else has been configured and is fully functional.

Please take a look at the documentation for the [Driving Coach](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#installation) for a description of the different providers and LLMs which can be configured here.

Important: Using a GPT service like OpenAI may create some costs, and running an LLM locally on your PC will require a very powerful system, especially when doing this while on the track. As already said, extending the capabilities of the Assistants with an LLM is fully optional.

Disclaimer: Large Language Models, although incredibly impressive, are still under heavy development. Therefore it depends on the quality and capabilities of the model, whether the Assistant will react like expected. And in most cases, the support for non-English languages is quite limited. I recommend to use the Assistant Booster only for English-speaking Assistants for the time being. Beside that, you will get good results for the *Rephrasing* booster with almost any model, whereas for the *Conversation* or *Reasoning* boosters you will need one of the big boys like GPT 3.5 and above for decent results. The requirements in terms of language understanding is somewhat in between for the *Recognition* booster. You will have to invest some time experimenting with different models, but that is part of the the fun.

## Overview of the different Assistant Boosters

Several boosters are available at the moment. The boosters *Rephrasing* and *Understanding* will not introduce additional capabilities or functionality, but will make the conversation more natural. I recommend to start with these boosters

Good to know: Whenever one or more Assistant Boosters are configured for a Race Assistant, a transcript of every LLM activation is stored in the *Simulator Controller\Logs\Transcripts* folder which is located in your user *Documents* folder.

### Rephrasing Booster

More variations in the speech output of the Assistants will be created, if *Rephrasing* is activated. This is done by using a GPT to rephrase one of the predefined phrases. The *Activation* setting defines the probability, with which the rephrasing happens (and thereby how many calls to the GPT service will be done) and using the *Creativity* setting, you can define, how *strong* the rephrasing will be. According to my tests, a value of 50% will create some intersting variation without altering the original sense of the message. Please note, that there are messages, especially the urgent alerts of the Spotter, which are time-critical. Those messages will never be send to the AI for rephrasing.
  
A very small context window can be used here, since only the phrase which is to be process plus a couple of instructions are send to the LLM.

### Understanding Booster

If *Understanding* is activated, a GPT is used to semantically analyze your voice commands and match them to any of the pattern-bassed commands defined by the Assistants. This allows you to formulate your commands in any way you like, as long as the meaning the same as for the predefined command. Here is an example:
	
  Grammar: [{Check, Please check} {the brake wear, the brake wear at the moment}, Tell me {the brake wear, the brake wear at the moment}]
	  
  A valid command that will be recognized for the pattern, will be: "Check the brake wear". When using the GPT-based semantically mapping, a command like: "We should check the brakes" will also be understood.
	 
There are two *Activation* methods available, both with their pros and cons. "Always" means, that the LLM is always asked to interpret the given command, whereas "Unrecognized" means, that it is only used, when the pattern-based voice recognition cannot identify the command. The later will result in less calls to the LLM and therefore will probably reduce costs and - even more important - will be better in terms of responsiveness, if you are already quite familar with the command patterns.

Note: Using the semantic *Understanding* booster may only be usable in conjunction with voice recognition methods, that are cabable to recognize continuous, unstructured text. This is true for Google and Azure voice recognition, but not for the builtin voice recognition of Windows, which only work reliable for pattern-based recognition.
	 
A context window of at least 2048 tokens is required for this booster, since all predefined command phrases will be supplied to the LLM for matching.

### Conversation Booster

Normally an Assistant will tell you that he didn't understand you, when the spoken command has matched none of the predefined commands. Using the *Conversation* booster a special mode can be activated, that will redirect all non-recognized commands to the LLM for interpretation and processing. This LLM will have full access to the knowledebase of the Assistant and will therefore be able to run a knowledgeable conversation with you. The following table lists the type of knowledge, that will be available to a specific Assistant:
     
| Assistant        | Knowledge (1) |
| ---------------- | ------------- |
| Race Engineer    | Telemetry data incl. tyre pressures, tyre temeperatures, tyre wear, brake temperatures, brake wear, fuel level, fuel consumption, damage, and so on. Full pitstop history is included and when a pitstop is planned, the plan is available otherwise a forecast of the next pitstop will be part of the knowledge. |
| Race Strategist  | Basic telemetry data but no detailed information about tyres, brakes and car damage. A reduced pitstop history is available as well as full information about the active strategy. Current position incl. detailed standings with gap and lap time information for all opponents is also available. |
| Race Spotter     | Basic telemetry data and no pitstop information. But current position incl. detailed standings with gap and lap time information for all opponents is also available. |
| Driving Coach    | Beside the [instructions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-driving-coach) that can be configured for the Driving Coach in general, the full set of telemetry data available to the Race Engineer is available to the Driving Coach as well. |

(1) Depending on the availabilty of the data by the current simulator.

Since large parts of the knowledgebase of the Assistants will be supplied to the LLM for matching, a context window of at least 4k tokens is required for this booster. Full standings history isn't possible at the moment, since this will overflow the input context area of the LLM, at least for the *smaller* models like GPT 3.5, Mistral 7b, and so on. Time will cure this problem, and I will update the capabilities of the integration, when more capable models become available. For the time being, the position data is available for the most recent laps and also the gaps for the most important opponents are passed to the LLM (for Strategist and Spotter).

Additionally, you can allow the LLM to call [predefined or custom actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#managing-actions) as a result of your conversation. For example, if you ask the Strategist whether an undercut might be possible in one of the next laps, the LLM may call the Monte Carlo traffic simulation using an internal action. Which actions will be available to the LLM depends on the current Assistant. See corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#trigger-actions-from-conversation) for the Strategist for an example.
	 
### Reasoning Booster

*Reasoning* is the most complex and most capable booster, since it allows you to alter or extend the behavior of the Assistant. You can use predefined events or even define your own ones in the rule engine (as shown below), which then result in a request to the LLM (actually you can process events even without using the LLM directly in rule engine, but this is only half of the fun). Similar to the *Conversation* bosster above, the LLM then can decide to activate one or more [predefined or custom actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#managing-booster-actions) to fulfill the request or react to the situation. To support its conclusion, the LLM will have full access to the same knowledge as in the *Conversation* booster.
	 
Important: This booster directly alters the behavior of the Assistant for the good or for the bad. Even if you don't change or extend the definition of the events and actions, it still depends on the reasoning capabilities of the used language model, whether the Assistant will behave as expected. Therefore, always test everything before using it in an important race.

### Instructions

For each of the above Assistant Boosters, you can edit the instructions that are send to the LLM by clicking on the button labeled "Instructions...". A new window will open, where you can edit all related instructions for each of the supported languages. Whenever you want to restore the original instruction, you can do this by clicking on the small button with the "Reload" icon.

Below you find all instruction categories and the supported variables:

| Booster        | Instruction (1)   | What              | Description |
|----------------|-------------------|-------------------|-------------|
| Rephrasing     | Rephrase          | Scope             | This instruction is used when a given phrase by an Assistant should be rephrased without changing its language. |
|                |                   | %assistant%       | The type or role of the current Assistant, for example "Race Engineer". |
|                |                   | %text%            | The text or phrase, which should be rephrased. |
|                | RephraseTranslate | Scope             | This instruction is used when a given phrase by an Assistant should be rephrased and then translated to a different language. |
|                |                   | %assistant%       | The type or role of the current Assistant, for example "Race Engineer". |
|                |                   | %language%        | This variable specifies the target language, for example "French", in which the resulting phrase should be formulated. |
|                |                   | %text%            | The text or phrase, which should be rephrased and then translated. |
|                | Translate         | Scope             | This instruction is used when a given phrase by an Assistant should only be translated without changing the wording. |
|                |                   | %assistant%       | The type or role of the current Assistant, for example "Race Engineer". |
|                |                   | %language%        | This variable specifies the target language, for example "French", for the resulting phrase. |
|                |                   | %text%            | The text or phrase, which should be translated. |
| Understanding  | Recognize         | Scope             | This instruction is used when a voice command has been recognized, which cannot be mapped to one of the predefined command patterns. |
|                |                   | %assistant%       | The type or role of the current Assistant, for example "Race Engineer". |
|                |                   | %commands%        | A table of examples for all predefined commands, so that the LLM can match the unrecognized command to one of those examples. Each line consist of a command name followed by an equal sign and a number of examples for the command. Example: "Yes=Yes thank you, Yes of course, Yes please". The LLM should the return the name of the command or "Unknown", if no match was possible. |
|                |                   | %text%            | The text of the command that should be identified. |
| Conversation   | Character         | Scope             | This instruction is used when a voice command has been recognized, which cannot be mapped to one of the predefined command patterns, even after using the LLM to map the command semantically. It is assumed that the user wants a free conversation with the LLM. This instruction then defines the profession and the personality of the Assistant. You can also include general instructions like "Keep your answers short and precise", and so on. |
|                |                   | %assistant%       | The type or role of the current Assistant, for example "Race Engineer". |
|                |                   | %name%            | Specifies the name of the Assistant. |
|                | Knowledge         | Scope             | This instruction is used to supply the current content of the knowledgebase to the LLM. The content of the knowledgebase depends on the type of the Assistant. |
|                |                   | %knowledge%       | This variable is substituted with the content of the knowledgebase in a self-explaining JSON format. |
| Reasoning      | Character         | Scope             | This instruction is used when an event has been raised by the rule engine. The LLM must decide which of the provided actions shall be used to deal with the situaton. |
|                |                   | %assistant%       | The type or role of the current Assistant, for example "Race Engineer". |
|                | Knowledge         | Scope             | This instruction is used to supply the current content of the knowledgebase to the LLM. The content of the knowledgebase depends on the type of the Assistant. |
|                |                   | %knowledge%       | This variable is substituted with the content of the knowledgebase in a self-explaining JSON format. |
|                | Event             | Scope             | The event represents the main instruction for the LLM, which describes what just happened or how the situation has changed. |
|                |                   | %event%           | This variable is substituted by the phrase which describes the event. Example: "It just started raining.". This phrase is defined by the event code for a builtin event or the event definition for a custom event. |
|                | Goal              | Scope             | The goal supplies additional information to the LLM by some builtin events, which helps the LLM to come up with a good conclusion. |
|                |                   | %goal%            | This variable is substituted by the phrase which instructs the LLM how to handle the given event. Example: "Check how to set up the car for wet onditions.". This phrase is defined by the event code for a builtin event. It cannot be provided for custom event definitions. |

###### Notes

(1) Each phrase is available in different languages, for example "Rephrase (DE)" for the German version.

## Managing Actions

A special editor is provided to manage the actions for a given Assistant. An action allows the LLM not only to react with a message to your request, but also to trigger some predefined functions. There are several builtin actions available for the different assistants, but you can also define your own ones.

To open this editor, click on the small button with the "Pencil" icon on the right of the "Actions" drop down menu in the *Conversation* booster or by clicking on the "Actions..." button for a *Reasoning* booster.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Speech%20Actions.JPG)

You can enable or disable individual predefined actions using the checkbox on the left of the action name. And you can define your own actions with a click on the "+" button. But this requires a very detailed understanding of the architecture and inner workings of Simulator Controller and the Assistants as well as an excellent understanding of LLMs and how they call tools and functions. This is far beyond the scope of this documentation, but I try to give a brief introduction.

1. When an LLM is activated, it is possible to provide a list of function descriptions to the LLM. *OpenAI* has defined the quasi-standard for the function description in JSON format as part of their API:

	   {
		   "type": "function",
		   "function": {
			   "name": "get_current_temperature",
			   "description": "Get the current temperature for a specific location",
			   "parameters": {
				   "type": "object",
				   "properties": {
					   "location": {
						   "type": "string",
						   "description": "The city and state, e.g., San Francisco, CA"
					   },
					   "unit": {
						   "type": "string",
						   "enum": ["Celsius", "Fahrenheit"],
						   "description": "The temperature unit to use. Infer this from the user's location."
					   }
				   },
				   "required": ["location", "unit"]
			   }
		   }
	   }

   This format is used by many other GPT service providers as well. Every LLM, that *understands* this type of function description, will be able to trigger actions, when used as a *Conversation* or *Reasoning* booster. The editor for the *Conversation* or *Reasoning* actions shown above is for the most part a graphical user interface for this type of function definitions. But it also let you define how to react to a *function call* by the LLM (see next section).
   
   Additionally to all the information required by the LLM function definition you can specify whether the corresponding action will be available during the learning phase of the Assistant and whether the Assistant will acknowledge your request like it is done with many of the builtin voice commands. This should be enabled for all actions you want to trigger by a corresponding question or command and should be disabled for all functions you expect the LLM to call automatically whenever needed.
   
   Note: The description of a function and each of their parameters is very important, since these are used by the LLM to *understand* when and how to invoke the function. It may require several iterations and different formulations until the LLM reacts as desired. 

2. When the LLM decides to call such a function, it returns a special response which indicates the function(s) to be called together with values for at least all required parameters. You can now decide what to do, when the logical function is called by the LLM. Four different types of actions are available:

   | Action Type | Description |
   |-------------|-------------|
   | Assistant Method | A method of the object which represents the given Race Assistant is called. The *method* can either simply be the name of the method or it can have the format of a function call with a fixed number of predefined arguments (Example: *requestInformation("Position")*, which will let the Strategist give you information bout your current position in the race). Additional arguments will be appended, if defined for the action. You can also name several methods to be called located on multiple lines. |
   | Assistant Rule | The supplied rules are loaded into the rule engine of the given Race Assistant. These rules have full access to the knowledge base and all other rules of this Assistant.<br><br>All arguments supplied by the LLM are created as facts in the knowledge base for the time of the execution. Please use enclosing percentage signs to reference the arguments. Example: %location%<br><br>A special fact named %activation% will be set as well, which can be used to trigger rules, when no other fact is suitable. |
   | Controller Method | A method of the single instance of the *SimulatorController* class is called in the process "Simulator Controller.exe". The *method* can either simply be the name of the method or it can have the format of a function call with a fixed number of predefined arguments (Example: *setMode("Launch")*, which activates the *Launch* mode on one of the connected Button Boxes). Additional arguments will be appended, if defined for the action. You can also name several methods to be called located on multiple lines. |
   | Controller Function | A global function is called in the process "Simulator Controller.exe". The *function* can either simply be the name of the function to be called or it can have the format of a function call with a fixed number of predefined arguments (Example: *trigger("!w")*, which sends the keyboard command "Alt w" to the current simulator). Additional arguments will be appended, if defined for the action. You can also name several functions to be called located on multiple lines.<br><br>Good candidates are the controller action functions, which are provided by the different plugins. See [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for a complete overview. |

3. The most versatile *Action Type* is obviously the "Assistant Rule", since it allows you to do almost anything, but it requires very good programming skills in the area of logical programming languages like Prolog and forward chaining production rule systems. Simulator Controller comes with a builtin hybrid rule engine, which has been created exclusivly with the requirements of intelligent agents in mind. The Race Assistants have been implemented using this rule engine, but other applications of Simulator Controller are using it as well. You may take a look at the rule sets of the Race Assistants to learn the language. They can be found in the *Resources\Rules* folder in the program folder of Simulator Controller. Start with "Race Engineer.rules".

   When defining the rules for a custom action, you can use the following predicates to connect to the given Assistant or even the "Simulator Controller.exe" process:
   
   - Assistant.Call(method, p1, p2, ...)
   
     Invokes the *method* on the instance of the Race Assistant class with some arguments. A variable number of arguments are supported.
	 
   - Assistant.Speak(phrase)
   
	 Outputs the given phrase using the voice of the given Race Assistant. *phrase* can be the label of a predefined phrase from the grammar definition of the Assistant.
	 
   - Assistant.Ask(question)
   
     Asks the given Race Assistant a question or give a command. The result will be the same, as if the question or the command has been given by voice input.
	 
   - Controller.Call(method, p1, p2, ...)
   
     Invokes the *method* on the instance of the *SimulatorController* class in the process "Simulator Controller.exe". with some arguments. A variable number of arguments are supported.
	 
   - Function.Call(function, p1, p2, ...)
   
     Invokes the global *function* in the process "Simulator Controller.exe". with some arguments. A variable number of arguments are supported.

   You can use this predicates in backward chaining rules directly. Example:
   
	   estimateTrackWetness() <= calculateTrackWetness(), Assistant.Speak("It will be too wet. I will come up with a new strategy."), Assistant.Call(planPitstop)

   Predicates with a variable number of arguments, up to 6 arguments are supported. If you need to pass more arguments, use the syntax Call(*Function.Call*, *function*, p1, ..., pn) for backward chaining rules.
	   
   In forward chaining rules, the syntax is a bit different:
   
	   [?Track.Grip = Wet] => (Call: Assistant.Speak("It will be too wet. I will come up with a new strategy.")), (Call: Assistant.Call(planPitstop))

As you can see, defining individual actions is really an expert topic and therefore nothing for the casual user. If you want use this feature, I can offer a personal introduction and coaching as part of the Patreon membership.

## Managing Events

As discussed above, you can use predefined events or define your own events in the rule engine of a given Assistant, when using the *Reasoning* booster.

A special editor is provided to manage the events for a given Assistant. There are several builtin events available for the different assistants, but you can also define your own ones.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Reasoning%20Events.JPG)

As you can see, this editor looks very similar to the actions editor discussed above. But there are many differences in the details. Please follow the instructions below, when defining your own events.

1. You have to supply a "Signal" name which uniquely identifies the event. When an event is raised by code, you have to supply exactly this identifier.

2. You have to supply a phrase which decribes the event to the LLM. Example: "It just started raining." If your event has defined parameters, you can reference the values of the arguments to the event in the phrase by enclosing them in "%". Example: "We started lap %lapNumber%."

3. The following event typs are supported:

   | Event Type  | Description |
   |-------------|-------------|
   | Event Class | The event is handled by an instance of a builtin class. This is mainly used for builtin events provided by the Assistant implementation. Butif you are an experienced developer, you can implement your own event classes, which are based on the "AssistantEvent" class. Notes:<br><br>1. The name of the class must be entered into the "Class" field. It must be in the global name space.<br><br>2. You have to supply the "Signal" identifier, but you don't have to provide an event phrase, since this is derived by the implementation of the event class. |
   | Event Rule | The supplied rules are loaded into the rule engine of the given Race Assistant. These rules have full access to the knowledge base and all other rules of this Assistant.<br><br>The event rules can use the full knowledge to derive whether the event in question should be raised. They then raise the event by *calling* the "Assistant.Raise* predicate, optionally supplying additional arguments to the event, which can be referenced in the event phrase.<br><br>Note: Actually, you don't have to raise an event in the event rules, if you are able to handle the situation directly using the rules. In this case, the LLM is not activated. |

3. When defining the rules for a custom event, you can use all predicates the introduced above for actions. Additionally, you can use:
   
   - Assistant.Raise(signal, p1, p2, ...)
   
     Raises the given *signal*, thereby identifying the event to be processed by the LLM.
	 
Please take a look at the predefined events of the Rae Engineer to learn more about writing event rules. And I recommend to take a look at the knowledgebase of a session to learn more about all the facts you canuse in the event rules (and also the action rules). To do this, activate the "Debug Knowledgebase" item in the tray bar menu of a given Assistant applicaton. Then open the corrsponding "*.knowledge" file in the *Simulator Controller\Temp* folder which is located in your user *Documents* folder.