## Preamble

Everything presented in this chapter is fully optional and I even recommend to not use it right from the start, since it requires some effort to configure and maybe several tests to get it right. But, once you have mastered it, it will take the experience with the Assistants to a whole new level. Welcome to the fascinating world of GPT and large language models (aka LLMs).

## Introduction

All AI Assistants like the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer), [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist) and [Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter) have been implemented using a specialized rule engine and *classical* voice recognition and speech generation.

The rule sets for the Race Assistants can be found in the *Resources\Rules* directory in the installation folder of Simulator Controller. But as with most of the configuration files of Simulator Controller, they can be locally customized or extended. Simply make a copy of one of the rule files and place it in the *Simulator Controller\Rules* directory, which can be found in your user *Documents* folder. Modifying or extending the rule sets of a given Assistant require programming skills and good understanding of logical programming languages. A good introduction and reference for the builtin Hybrid Rule Engine can be found [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine).

The [Driving Coach](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach) is already different than the other Assistants, since the purpose of this Assistant is a natural conversation with you as a driver using a lot of real world knowledge about sim racing and motorsports in general. The Driving Coach therefore is based on the famous GPT (aka general pretrained transformer, a kind of neural network) technology using a large language model (also termed LLM).

But is also possible to connect the rule based Assistants to an LLM to improve the cnversational capabilities or to alter or even extend the behavior of them. This all can be achieved by configuring the so called Assistant Boosters. The following documentation will give you all information you need to setup the Assistant Boosters.

Note: Seting up a connection to a GPT service and configuring the Assistant Boosters require some knowledge. Customizing the *Conversation* and the *Reasoning* bosters may require even some development skills. If you feel overwhelmed, no problem. Simply leave it aside and use the Assistants without connecting them to a GPT service. The will do their job. Or you can become a Patreon of the project and I will setup everything for you.

Important: Even if you are not using a local LLM Runtime are the resource requirements significantly higher compared to running an Assistant based on the rule engine alone. Therefore take a look at the Windows Task Manager to check whether your system can handle all that while using your favorite simulator.

## Connecting an Assistant to an LLM

The voice recognition for all Assistants except the Driving Coach is normally pattern-based. [Here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Engineer-Commands-(EN)), for example, you can find a documentation for the definition of the recognized commands of the Race Engineer and similar documentation is available for the other Assistants as well. The speech output of all Assistants is also preprogrammed with several different phrases for each message, to create at least a little variation.

Said this, it is clear, that the interaction with the grammar-based Assistants, although already impressive, will not feel absolutely natural in many cases. But using the latest development in AI with LLMs (aka large language model) it became possible to improve the conversation capabilities of the Assistants even further. Whenever you see a small button with an icon which looks like a launching space rocket, you can configure AI pre- and post-processing for voice recognition, speech output and general conversation.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Speech%20Improvement.JPG)

Please note, that the first three conversation-related boosters all share a GPT service and a single model, whereas you can choose a separate GPT service and model for the *Reasoning* booster, which requires strong reasoning skills, but no conversational skills at all. This might be helpful to select the best possible model for each task.

Please take a look at the documentation for the [Driving Coach](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#installation) for a description of the different providers and LLMs which can be configured here. Please note, that *GPT4All* and also the local *LLM Runtime* do not support the so called function or tool calling of LLMs at the time of this writing. They therefore cannot be used for the *Conversation* booster with activated actions and absolutely not for the *Resoning* booster. This may change in the future.

As said, the Driving Coach is a bit different in the sense, that it allows free conversation with an LLM using a GPT service. But it also uses several pattern-based grammars for pre-defined commands like the other Assistants, therefore the Driving Coach is a kind of a hybrid, when it comes to voice interaction. For the pattern-based voice commands, the Driving Coach also supports the *Rephrasing* booster and the *Understanding* booster described a described below.

IMPORTANT: As said in the beginning, all this is optional. The Race Assistants will do their job really good even without being connected to an LLM. Additionally, using a GPT service like OpenAI may create some costs, and running an LLM locally on your PC will require a very powerful system, especially when doing this while on the track. Therefore I recommend to use this feature not before everything else has been configured and is fully functional.

Disclaimer: Large Language Models, although incredibly impressive, are still under heavy development. Therefore it depends on the quality and capabilities of the model, whether the Assistant will react like expected. And in most cases, the support for non-English languages is quite limited. I recommend to use the Assistant Booster only for English-speaking Assistants for the time being. Beside that, you will get good results for the *Rephrasing* booster with almost any model, whereas for the *Conversation* or *Reasoning* boosters you will need one of the big boys like GPT 4.1 and above for decent results. The requirements in terms of language understanding is somewhat in between for the *Recognition* booster. You will have to invest some time experimenting with different models, but that is part of the the fun.

## Overview of the different Assistant Boosters

Several boosters are available at the moment. The boosters *Rephrasing* and *Understanding* will not introduce additional capabilities or functionality, but will make the conversation more natural. I recommend to start with these boosters.

Good to know: Whenever one or more Assistant Boosters are configured for a Race Assistant, a transcript of every LLM activation is stored in the *Simulator Controller\Logs\Transcripts* folder which is located in your user *Documents* folder.

### Rephrasing Booster

More variations in the speech output of the Assistants will be created, if *Rephrasing* is activated. This is done by using a GPT to rephrase one of the predefined phrases. The *Activation* setting defines the probability, with which the rephrasing happens (and thereby how many calls to the GPT service will be done) and using the *Creativity* setting, you can define, how *strong* the rephrasing will be. According to my tests, a value of 50% will create some intersting variation without altering the original sense of the message. Please note, that there are messages, especially the urgent alerts of the Spotter, which are time-critical. Those messages will never be send to the AI for rephrasing.
  
A model with a very small context window can be used here, since only the phrase which is to be process plus a couple of instructions are send to the LLM.

### Understanding Booster

If *Understanding* is activated, a GPT is used to semantically analyze your voice commands and match them to any of the pattern-bassed commands defined by the Assistants. This allows you to formulate your commands in any way you like, as long as the meaning the same as for the predefined command. Here is an example:
	
  Grammar: [{Check, Please check} {the brake wear, the brake wear at the moment}, Tell me {the brake wear, the brake wear at the moment}]
	  
  A valid command that will be recognized for the pattern, will be: "Check the brake wear". When using the GPT-based semantically mapping, a command like: "We should check the brakes" will also be understood.
	 
There are two *Activation* methods available, both with their pros and cons. "Always" means, that the LLM is always asked to interpret the given command, whereas "Unrecognized" means, that it is only used, when the pattern-based voice recognition cannot identify the command. The later will result in less calls to the LLM and therefore will probably reduce costs and - even more important - will be better in terms of responsiveness, if you are already quite familar with the command patterns.

Note: Using the semantic *Understanding* booster may only be usable in conjunction with voice recognition methods, that are cabable to recognize continuous, unstructured text. This is the case for Google and Azure voice recognition, but not for the builtin voice recognition of Windows, which only work reliable for pattern-based recognition.

### Conversation Booster

Normally an Assistant will tell you that he didn't understand you, when the spoken command has matched none of the predefined commands. Using the *Conversation* booster a special mode can be activated, that will redirect all non-recognized commands to the LLM for interpretation and processing. This LLM will have full access to the knowledebase of the Assistant and will therefore be able to run a knowledgeable conversation with you. The following table lists the type of knowledge, that will be available to a specific Assistant:
     
| Assistant        | Knowledge (1) |
| ---------------- | ------------- |
| Race Engineer    | Telemetry data incl. tyre pressures, tyre temperatures, tyre wear, brake temperatures, brake wear, fuel level, fuel consumption, damage, and so on. All this is available as real time values as well as historic values for the past 5 laps. Full pitstop history is also included and when a pitstop is planned, the plan is available, otherwise a forecast of the next pitstop will be part of the knowledge. |
| Race Strategist  | Basic telemetry data (both real time and historic) but no detailed information about tyres, brakes and car damage. A reduced pitstop history is available and full information about the active strategy is included. Current position incl. detailed standings with gap and lap time information for all opponents is also available. |
| Race Spotter     | Very basic telemetry data (both real time and historic) and no pitstop information. But current position incl. detailed standings with gap and lap time information for all opponents is provided. |
| Driving Coach    | Beside the [instructions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-driving-coach) that can be configured for the Driving Coach in general, the same information available to the Race Strategist is available to the Driving Coach as well. |

(1) Depending on the availabilty of the data by the current simulator.

Since large parts of the knowledge base of the Assistants will be supplied to the LLM for matching, a larger model with a context window of at least 16k tokens is required for this booster. Full standings history isn't possible at the moment, since this will overflow the input context area of the LLM, at least for the *smaller* models like Mistral 7b, and so on. Time will cure this problem, and I will update the capabilities of the integration, when more capable models become available. For the time being, the position data is available for the most recent laps and also the gaps for the most important opponents are passed to the LLM (for Strategist and Spotter).

Here is an example of the knowledge supplied by the Race Engineer to the LLM:

	{
		"Damage": {
			"Bodywork": {
				"Front": "66.4 %",
				"Left": "0.0 %",
				"Rear": "0.0 %",
				"Right": "33.6 %"
			},
			"LapTimeLoss": "3.3 Seconds",
			"RepairTime": "0 Seconds",
			"Suspension": {
				"Suspension": {
					"FrontLeft": "27.3 %",
					"FrontRight": "43.2 %",
					"RearLeft": "15.9 %",
					"RearRight": "13.6 %"
				}
			}
		},
		"Fuel": {
			"Capacity": "125 Liter",
			"Consumption": "2.6 Liter",
			"Remaining": "1.5 Liter"
		},
		"Laps": [
			{
				"BodyworkDamage": 0.0,
				"EngineDamage": 0.0,
				"FuelConsumption": "2 Liters",
				"FuelRemaining": "9 Liters",
				"Nr": 2,
				"SuspensionDamage": 0.0,
				"LapTime": "110.1 Seconds",
				"Track": {
					"Temperature": 32,
					"Grip": "Green"
				},
				"Tyres": {
					"Pressures": {
						"Front.Left": "27.13 PSI",
						"Front.Right": "27.34 PSI",
						"Rear.Left": "27.17 PSI",
						"Rear.Right": "27.50 PSI"
					},
					"Temperatures": {
						"Front.Left": "82.8 Celsius",
						"Front.Right": "71.4 Celsius",
						"Rear.Left": "86.3 Celsius",
						"Rear.Right": "77.3 Celsius"
					}
				},
				"Valid": true,
				"Weather": {
					"Now": "Dry",
					"Forecast": {
						"10 Minutes": "Dry",
						"30 Minutes": "Dry"
					},
					"Temperature": 25
				}
			},
			{
				"BodyworkDamage": 0.0,
				"EngineDamage": 0.0,
				"FuelConsumption": "3 Liters",
				"FuelRemaining": "7 Liters",
				"Nr": 3,
				"SuspensionDamage": 0.0,
				"LapTime": "108.4 Seconds",
				"Track": {
					"Temperature": 32,
					"Grip": "Green"
				},
				"Tyres": {
					"Pressures": {
						"Front.Left": "27.22 PSI",
						"Front.Right": "27.41 PSI",
						"Rear.Left": "27.26 PSI",
						"Rear.Right": "27.58 PSI"
					},
					"Temperatures": {
						"Front.Left": "83.8 Celsius",
						"Front.Right": "72.2 Celsius",
						"Rear.Left": "87.3 Celsius",
						"Rear.Right": "78.1 Celsius"
					}
				},
				"Valid": true,
				"Weather": {
					"Now": "Dry",
					"Forecast": {
						"10 Minutes": "Dry",
						"30 Minutes": "Dry"
					},
					"Temperature": 25
				}
			},
			{
				"BodyworkDamage": 0.0,
				"EngineDamage": 0.0,
				"FuelConsumption": "3 Liters",
				"FuelRemaining": "4 Liters",
				"Nr": 4,
				"SuspensionDamage": 3.099,
				"LapTime": "113.7 Seconds",
				"Track": {
					"Temperature": 32,
					"Grip": "Green"
				}
				"Tyres": {
					"Pressures": {
						"Front.Left": "27.03 PSI",
						"Front.Right": "27.34 PSI",
						"Rear.Left": "27.14 PSI",
						"Rear.Right": "26.57 PSI"
					},
					"Temperatures": {
						"Front.Left": "82.3 Celsius",
						"Front.Right": "71.5 Celsius",
						"Rear.Left": "87.2 Celsius",
						"Rear.Right": "78.0 Celsius"
					}
				},
				"Valid": true,
				"Weather": {
					"Now": "Dry",
					"Forecast": {
						"10 Minutes": "Dry",
						"30 Minutes": "Dry"
					},
					"Temperature": 25
				}
			},
			{
				"AirTemperature": 25,
				"BodyworkDamage": 22.90,
				"EngineDamage": 0.0,
				"FuelConsumption": "3 Liters",
				"FuelRemaining": "2 Liters",
				"Grip": "Green",
				"Nr": 5,
				"SuspensionDamage": 4.399,
				"LapTime": "107.3 Seconds",
				"TrackTemperature": 32,
				"Tyres": {
					"Pressures": {
						"Front.Left": "27.24 PSI",
						"Front.Right": "27.52 PSI",
						"Rear.Left": "27.23 PSI",
						"Rear.Right": "26.62 PSI"
					},
					"Temperatures": {
						"Front.Left": "84.4 Celsius",
						"Front.Right": "73.4 Celsius",
						"Rear.Left": "88.2 Celsius",
						"Rear.Right": "78.6 Celsius"
					}
				},
				"Valid": true,
				"Weather": {
					"Now": "Dry",
					"Forecast": {
						"10 Minutes": "Dry",
						"30 Minutes": "Dry"
					}
				}
			}
		],
		"Pitstop": {
			"Refuel": "60.0 Liters",
			"Repairs": false,
			"Status": "Forecast",
			"TyreChange": true,
			"TyreCompound": "Dry (Black)",
			"TyrePressures": {
				"FrontLeft": "27.1 PSI",
				"FrontRight": "26.7 PSI",
				"RearLeft": "27.1 PSI",
				"RearRight": "27.2 PSI"
			},
			"TyreSet": 9
		},
		"Pitstops": [
			{
				"AirTemperature": "25.0 Celsius",
				"Lap": 4,
				"Nr": 1,
				"Refuel": "56.8 Liters",
				"Repairs": false,
				"TrackTemperature": "32.0 Celsius",
				"TyreChange": true,
				"TyreCompound": "Dry (Black)",
				"TyrePressures": {
					"FrontLeft": "26.6 PSI",
					"FrontRight": "26.4 PSI",
					"RearLeft": "26.6 PSI",
					"RearRight": "26.1 PSI"
				},
				"TyreSet": 8
			}
		],
		"Session": {
			"Car": "mclaren_720s_gt3",
			"Format": "Time",
			"RemainingLaps": 21,
			"RemainingTime": "2140 seconds",
			"Simulator": "Unknown",
			"Track": "Barcelona",
			"TrackLength": "0 Meters",
			"Type": "Practice"
			"AvailableTyres": [
				{
					"Compound": "Dry (Black)",
					"Sets": 99,
					"Weather": [ "Dry", "Drizzle" ]
				},
				{
					"Compound": "Wet (Black)",
					"Sets": 99,
					"Weather": [ "LightRain", "MediumRain", "HeavyRain", "Thunderstorm" ]
				}
			]
		},
		"Stint": {
			"Driver": "Oliver Doe (JD)",
			"Lap": 6,
			"RemainingTime": "2140 Seconds",
			"LastLapTime": "107.3 Seconds",
			"BestLapTime": "105.1 Seconds"
		},
		"Track": {
			"Grip": "Green",
			"Temperature": "32 Celsius"
		},
		"Tyres": {
			"Compound": "Dry (Black)",
			"Pressures": {
				"Current": {
					"FrontLeft": "27.24 PSI",
					"FrontRight": "27.52 PSI",
					"RearLeft": "27.23 PSI",
					"RearRight": "26.62 PSI"
				},
				"Ideal": {
					"FrontLeft": "27.7 PSI",
					"FrontRight": "27.7 PSI",
					"RearLeft": "27.7 PSI",
					"RearRight": "27.7 PSI"
				},
				"Setup": {
					"FrontLeft": "26.6 PSI",
					"FrontRight": "26.4 PSI",
					"RearLeft": "26.6 PSI",
					"RearRight": "26.1 PSI"
				}
			},
			"Temperatures": {
				"Current": {
					"FrontLeft": "84.4 Celsius",
					"FrontRight": "73.4 Celsius",
					"RearLeft": "88.2 Celsius",
					"RearRight": "78.6 Celsius"
				}
			}
		},
		"Weather": {
			"Forecast": {
				"10 Minutes": "Dry",
				"30 Minutes": "Dry"
			},
			"Now": "Dry",
			"Temperature": "25 Celsius"
		}
	}

Notes:

- As said, the available data depeneds on the current simulator. If available, information about tyre wear, brake temperatures and wear and so on are included as well.
- The number of laps in the lap history is limited to the 5 recent laps.
- The number of pitstops in the pitstop history is unlimited.

Additionally, you can allow the LLM to *call* [predefined or custom actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#managing-actions) as a result of your conversation. For example, if you ask the Strategist whether an undercut might be possible in one of the next laps, the LLM may call the Monte Carlo traffic simulation using an internal action. Which actions will be available to the LLM depends on the current Assistant. See corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist#trigger-actions-from-conversation) for the Strategist for an example.

Please be aware that you are talking to an AI based on GPT technology when using the *Conversation* booster. And AIs o n lie or can give wrong answers. More details on that can be found below in the [How it works section](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#how-it-works). A short sound helps you identify that the *Conversation* booster is active and that an LLM is giving you the answer. As with the *Push-to-Talk* sound, you can route this acknowledge sound to a different device in a streaming setup, if required.

IMPORTANT: When action handling is enabled, it might be necessary to disable the *Understanding* booster or at least set the "Creativity" to a very low value. Otherwise the *Understanding* booster might detect a command pattern, which will match to a pre-defined voice command, thereby preventing the LLM from creating a custom action plan.

#### Examples

The following short conversations demonstrate the potential of the *Conversation* booster with both the Engineer and the Strategist.

[Conversation with Engineer](https://www.dropbox.com/scl/fi/bqfs6xxvr9jjca4yr3ajt/Conversation_with_the_Engineer.mp3?rlkey=33t4j70e3fuetosklvo2peoya&st=dolh5gkc&dl=1)

[Conversation with Strategist 1](https://www.dropbox.com/scl/fi/zza32wd7a4dw9r7u6u2q9/Conversation_with_the_Strategist_1.mp3?rlkey=5nbo5q1qz0xdvsdgdibk652dq&st=4vnvfd4x&dl=1)

[Conversation with Strategist 2](https://www.dropbox.com/scl/fi/o3ej147izjzpm0zymyvdi/Conversation_with_the_Strategist_2.mp3?rlkey=qozaqvqjfhy6tiysvhs6ojkn4&st=qkuy6eei&dl=1)

### Reasoning Booster

*Reasoning* is the most complex and most capable booster, since it allows you to alter or extend the behavior of the Assistant. You can use predefined events or even define your own ones in the [Rule Engine](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine) (as shown below), which then result in a request to the LLM (actually you can process events even without using the LLM directly in rule engine, but this is only half of the fun). Similar to the *Conversation* booster above, the LLM then can decide to activate one or more [predefined or custom actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#managing-booster-actions) to fulfill the request or react to the situation. To support its conclusion, the LLM will have full access to the same knowledge as in the *Conversation* booster.

The *Reasoning* booster implements an LLM agent framework architecture also used by famous open-source agent development environments like [LangChain](https://python.langchain.com/). The difference here is the deep integration with the rule engine of the Assistants as the central instance for the LLM activation.

As already mentioned, you can choose a different LLM for this booster, because here strong reasoning skills are way more important than conversational excellence.
	 
Important: This booster directly alters the behavior of the Assistant for the good or for the bad. Even if you don't change or extend the definition of the events and actions, it still depends on the reasoning capabilities of the used large language model, whether the Assistant will behave as expected. Therefore, always test everything before using it in an important race.

As a special case can the *Reasoning* booster also be used to extend the rules of the Assistant as such, without using an LLM. To do this, use the "Rules" provider. In this case, you must write rules for each event to be handled. These rules then can either handle the event directly or you can define actions and trigger them from the event rule by calling the "Assistant.Trigger" function / predicate as described below.

### Using Actions & Events

The *Reasoning* booster as well as to some extent the *Conversation* booster rely on the capability of the configured LLM to *call* external functions as part of their reasoning process. This is achieved by the so-called tool interface of the LLM. Tools are supported at the time of this writing by the following models:

  - GPT 4.1 mini and above from *OpenAI*
  - Mistral Small, Mistral Large and Mixtral 8x22b from *Mistral AI*
  - Gemini 2 Flash and above from *Google*
  - Claude3 and above by *Anthropic* (via *OpenRouter*)
  - Command-R+ by *Cohere* (via *OpenRouter*, but not working properly yet)
  - Some Open Source models, such as Open Hermes, also support tools but with a varying degree of reliability

Please note that calling actions is not available with any provider. It is supported by commercial providers like *OpenAI*, *Mistral AI* or *OpenRouter* and it is also supported by *Ollama* for locally hosted models, but not for all models (check [here](https://ollama.com/search?c=tools) for supported models).

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
|                | Knowledge         | Scope             | This instruction is used to supply the current content of the knowledge base to the LLM. The content of the knowledge base depends on the type of the Assistant. |
|                |                   | %knowledge%       | This variable is substituted with the content of the knowledge base in a self-explaining JSON format. |
| Reasoning      | Character         | Scope             | This instruction is used when an event has been raised by the rule engine. The LLM must decide which of the provided actions shall be used to deal with the situaton. |
|                |                   | %assistant%       | The type or role of the current Assistant, for example "Race Engineer". |
|                | Knowledge         | Scope             | This instruction is used to supply the current content of the knowledge base to the LLM. The content of the knowledge base depends on the type of the Assistant. |
|                |                   | %knowledge%       | This variable is substituted with the content of the knowledge base in a self-explaining JSON format. |
|                | Event             | Scope             | The event represents the main instruction for the LLM, which describes what just happened or how the situation has changed. |
|                |                   | %event%           | This variable is substituted by the phrase which describes the event. Example: "It just started raining.". This phrase is defined by the event code for a predefined event or the event definition for a custom event. |
|                | Goal              | Scope             | The goal supplies additional information to the LLM by some predefined events, which helps the LLM to come up with a good conclusion. |
|                |                   | %goal%            | This variable is substituted by the phrase which instructs the LLM how to handle the given event. Example: "Check how to set up the car for wet onditions.". This phrase is defined by the event code for a predefined event. It cannot be provided for custom event definitions. |

###### Notes

(1) Each phrase is available in different languages, for example "Rephrase (DE)" for the German version.

## How it works

Since the control flow between the rule engine and the LLM especially for the *Reasoning* booster is not exactly easy to understand at the beginning - and since, as we all know, a picture is worth a thousand words - here is a picture.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Agent%20Flow.JPG)

1. It all starts with an event, typically signalled by the rule engine. An event will be in most cases a special condition in the state of the car or the session (fuel is running low, weather is changing, and so on). There are many predefined events available, which you can find below and you can define your own events, of course.
2. The event will generate a command or information phrase for the LLM and this will be passed to the GPT service together with a complete representation of the current knowledge, as show above, and a list of available actions to call.
3. The LLM can decide to *call* one or more of these actions, which then will be executed in parallel.
4. An action can do almost anything. Typically it triggers a special behaviour of the Assistant, for example, create a pitstop plan, but it can also call any of the available [action functions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) in Simulator Controller, or it can generate voice output, and so on. Using *Assistant.Raise* (see below for [more information](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#managing-events)), it can also raise additional events, even for other Assistants. These enables the LLM to create a complex chain of thought or collaborate with other Assistants.

### About hallucinations and other funny stuff

Especially when using the *Conversation* and/or the *Reasoning* booster keep the following things in mind, please:

  1. A large language model simulates intelligence. Although it is doing this really well, the constant feedback loop of self-aware thinking is missing. An LLM does not really understand the topic it is talking about, it just derives the probability of words in the given context. Since there is also random factor in play (the *Creativity*, as defined in the configuration), it can happen, that an LLM creates answers that sound totally plausible, but are utterly wrong. If you encounter this too often, reduce the *Creativity* setting. This will reduce the variation in the answers of the model, but will also reduce hallucinations.
  
  2. LLMs, especially non-premium models, can also have something called attention deficit. They are not good in following multiple, mostly indepedent chain of thoughts at the same time. The LLM used by the boosters is provided with a lot of data, when you interact with them. Standings, handling information, session and car state, telemetry information, just to name a few. It is therefore possible that the LLM is not using an important information, although it is available. Sometimes it helps in this case to clarify that the informtion is available and the LLM will work with it then.
  
  3. What really can be a problem, is, that an LLM can lie to you. For example, if you ask the Strategist with an active *Conversation* booster (and no appropriate action enabled), that he should change the strategy to pit in lap 20, the LLM might answer, that the strategy has been changed, although it is not able to do this. There is no pre-defined voice command for this kind of request and the LLM only wanted you to be happy. You have been warned...
  
In summary work especially with the *Conversation* booster as you would work with ChatGPT. Always use your own brain as well. As LLMs get smarter, especially with the multi-level reasoning models like OpenAIs o1 or the upcoming o3, we will see big improvements here. With its architecture, Simulator Controller is prepared to participate from this development.

## Managing Actions

A special editor is provided to manage the actions for a given Assistant. An action allows the LLM not only to react with a message to your request, but also to trigger some predefined functions. There are several predefined actions available for the different assistants, but you can also define your own ones.

To open this editor, click on the small button with the "Pencil" icon on the right of the "Actions" drop down menu in the *Conversation* booster or by clicking on the "Actions..." button for a *Reasoning* booster.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Speech%20Actions.JPG)

You can enable or disable individual predefined actions using the checkbox on the left of the action name. And you can define your own actions with a click on the "+" button (or you can copy an existing event by clicking on the button with the "Copy" icon). But this requires a very detailed understanding of the architecture and inner workings of Simulator Controller and the Assistants as well as an excellent understanding of LLMs and how they call tools and functions. This is far beyond the scope of this documentation, but I try to give a brief introduction.

Additionally you can export and import actions here to build a library for you and your team mates or you can share them with the community, for example.

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
   
   Additionally to all the information required by the LLM function definition you can specify whether the corresponding action will be available during the learning phase of the Assistant and whether the Assistant will acknowledge your request like it is done with many of the builtin voice commands. As a rule of thumb. this should be enabled for all actions you want to trigger by a corresponding question or command and should be disabled for all functions you expect the LLM to call automatically whenever needed.
   
   Note: The description of a function and each of their parameters is very important, since these are used by the LLM to *understand* when and how to invoke the function. It may require several iterations and different formulations until the LLM reacts as desired. 

2. When the LLM decides to call such a function, it returns a special response which indicates the function(s) to be called together with values for at least all required parameters. You can now decide what to do, when the logical function is called by the LLM. Four different types of actions are available:

   | Action Type | Description |
   |-------------|-------------|
   | Assistant Method | A method of the object which represents the given Race Assistant is called. The *method* can either simply be the name of the method or it can have the format of a function call with a fixed number of predefined arguments (Example: *requestInformation("Position")*, which will let the Strategist give you information about your current position in the race). You can also name several methods to be called located on multiple lines.<br><br>If only the method name is supplied, all arguments as defined by the action will be supplied to the method call. If a function call format is used, you can reference arguments by using the parameter name enclosed in percent signs, like "%refuelAmount%, Example:<br><br>planPitstopAction(null, %refuelAmount%, true, "Dry (S)", true, false)<br><br>Important: The usage of the character "\|" is strictly forbidden in a call definition, since it is used internally as a separator. |
   | Assistant Rule | The supplied rules are loaded into the [Rule Engine](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-engine) of the given Race Assistant. These rules have full access to the knowledge base and all other rules of this Assistant.<br><br>All arguments supplied by the LLM are created as facts in the knowledge base for the time of the execution. Please use enclosing percentage signs to reference the arguments. Example: %location%<br><br>A special fact named %activation% will be set as well, which can be used to trigger rules, when no other fact is suitable. |
   | Assistant Script | Similar to "Assistant Rule", but uses [Lua](https://www.lua.org) as scripting language.<br><br>All arguments supplied by the LLM are created as global variables for the time of execution. Please use enclosing percentage signs to reference those arguments. Example: %location% |
   | Controller Method | A method of the single instance of the *SimulatorController* class is called in the process "Simulator Controller.exe". The *method* can either simply be the name of the method or it can have the format of a function call with a fixed number of predefined arguments (Example: *setMode("Launch")*, which activates the *Launch* mode on one of the connected Button Boxes). Additional arguments may be supplied like described above for *Assistant Method*. You can also name several methods to be called located on multiple lines. |
   | Controller Function | A global function is called in the process "Simulator Controller.exe". The *function* can either simply be the name of the function to be called or it can have the format of a function call with a fixed number of predefined arguments (Example: *trigger("!w")*, which sends the keyboard command "Alt w" to the current simulator). Additional arguments may be supplied like described above for *Assistant Method*. You can also name several functions to be called located on multiple lines.<br><br>Good candidates are the controller action functions, which are provided by the different plugins. See [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for a complete overview. Using the "invoke" controller action function you can even call a method for one of the active plugins installed in Simulator Controller. |

3. The most versatile *Action Type* is obviously the "Assistant Rule", since it allows you to do almost anything, but it requires very good programming skills in the area of logical programming languages like Prolog and forward chaining production rule systems. Simulator Controller comes with a builtin [Hybrid Rule Engine](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-engine), which has been created exclusivly with the requirements of intelligent agents in mind. The Race Assistants have been implemented using this rule engine, but other applications of Simulator Controller are using it as well. You will find an extensive, developer-oriented documentation for the rule engine [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-engine) and you can take a look at the rule sets of the Race Assistants to learn the language. They can be found in the *Resources\Rules* folder in the program folder of Simulator Controller. Start with "Race Engineer.rules".

   When defining the rules for a custom action, you can use the following predicates and functions to connect to the given Assistant or even the "Simulator Controller.exe" process:
   
   - Assistant.Call(method, p1, p2, ...)
   
     Invokes the *method* on the instance of the Race Assistant class with some arguments. A variable number of arguments are supported.
	 
   - Assistant.Speak(phrase [, force])
   
	 Outputs the given phrase using the voice of the given Race Assistant. *phrase* can be the label of a predefined phrase from the grammar definition of the Assistant. If *phrase* is not one of the predefined phrases it will be spoken as is. The *phrase* will not be spoken, if the Assistant is muted, unless you supply *true* for the optional parameter *force*.
	 
   - Assistant.Ask(question)
   
     Asks the given Race Assistant a question or give a command. The result will be the same, as if the question or the command has been given by voice input.
	 
   - Controller.Call(method, p1, p2, ...)
   
     Invokes the *method* on the instance of the *SimulatorController* class in the process "Simulator Controller.exe". with some arguments. A variable number of arguments are supported.
	 
   - Function.Call(function, p1, p2, ...)
   
     Invokes the global *function* in the process "Simulator Controller.exe". with some arguments. A variable number of arguments are supported.

   You can use these predicates in backward chaining rules directly. Example:
   
	   estimateTrackWetness() <= calculateTrackWetness(), Assistant.Speak("It will be too wet. I will come up with a new strategy."), Assistant.Call(planPitstop)

   Up to 6 arguments are supported for predicates with a variable number of arguments. If you need to pass more arguments, use the syntax Call(*Assistant.Call*, function, p1, ..., pn) for backward chaining rules. Same applies to any other of the above *calls*.
	   
   In forward chaining rules, the syntax is a bit different:
   
	   [?Track.Grip = Wet] => (Call: Assistant.Speak("It will be too wet. I will come up with a new strategy.")), (Call: Assistant.Call(planPitstop))

   Here you can use (Call: *Assistant.Call*(function, p1, ..., pn)), if more than 6 arguments should be passed to the function. Same applies to any other of the above *calls*.
   
   Good to know: During the execution of a rule you can use the *execute* action / predicate not only to call batch files and executable, but you can also run any script defined in the *Lua* scripting language. The arguments passed to the script will be available in the global array *Arguments*. Since the script is run in the host process it will have access to the same global functions as defined for "Assistant Script" *Action Type* below.

4. Equally useful as "Assistant Rule" is "Assistant Script" and since *Lua* is a widespread scripting language, it may be more accessible to the typical user. When defining the script for a custom action, you can use the following functions to connect to the given Assistant or even the "Simulator Controller.exe" process:
   
   - Assistant.Call(method :: \<string\>, p1, p2, ...)
   
     Invokes the *method* on the instance of the Race Assistant class with some arguments. A variable number of arguments are supported.
	 
   - Assistant.Speak(phrase :: \<string\> [, force :: \<booelan\>])
   
	 Outputs the given phrase using the voice of the given Race Assistant. *phrase* can be the label of a predefined phrase from the grammar definition of the Assistant. If *phrase* is not one of the predefined phrases it will be spoken as is. The *phrase* will not be spoken, if the Assistant is muted, unless you supply *true* for the optional parameter *force*.
	 
   - Assistant.Ask(question :: \<string\>)
   
     Asks the given Race Assistant a question or give a command. The result will be the same, as if the question or the command has been given by voice input.
	 
   - Controller.Call(method :: \<string\>, p1, p2, ...)
   
     Invokes the *method* on the instance of the *SimulatorController* class in the process "Simulator Controller.exe". with some arguments. A variable number of arguments are supported.
	 
   - Function.Call(function :: \<string\>, p1, p2, ...)
   
     Invokes the global *function* in the process "Simulator Controller.exe". with some arguments. A variable number of arguments are supported.

   - Rules.SetValue(fact :: \<string\>, value :: \<string\>)
   
     Changes the value for the given fact in the knowledgebase of the Assistant.

   - Rules.GetValue(fact :: \<string\> [, default)
   
     Returns the value for the given fact in the knowledgebase of the Assistant. If there is no such value, the default will be returned if supplied, or nil.

   - Rules.Execute()
   
     Runs a full production cycle of the Rule Engine of the Assistant.
	 
   Here is an example that demonstrates several of the above functions:
   
   ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Action%20Definition%202.JPG)
   
   For this example it is assumed, that two keyboard commands are defined in the current simulator: 1. "i" increases the brake balance and "k" decreases the brake balance.
   
   - extern(name :: \<string\>)
   
   During the execution of a script you can use the *extern* function to call any global *AutoHotkey* object in the current process. Example: extern("showMessage")("Hello World!"). Beside calling functions, *extern* can also be used to access any global variable in that process.
   
   Beside the *builtin* functions described above, additional modules are available, which can be loaded on demand. They can be used to interface with the current simulation and session. Please see the [reference cards for these modules](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Script-Modules) and several examples how to use them.
   
As you can see, defining individual actions is really an expert topic and requires some programming skills when using rules and/or scripts. Therefore it may be no option for the casual user, and even for the experienced programmer it will require some knowledge about the inner workings. If you want to use this feature, I can offer a personal introduction and coaching as part of the Patreon membership. However, when using the *Action Type* "Controller Function", even the technically non-experienced users can achieve impressive results. Here is a corresponding example:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Action%20Definition.JPG)

This action calls the [controller aciton](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) "trigger" with "!w" as an argument in the Simulator Cntroller process. This sends the keyboard command Alt-w to the current simulator, thereby starting the windscreen wiper. This action may be activated by a voice command like "Can you start the windscreen wiper?" when using the *Conversation* booster, or it can be automatically triggered by the *Reasoning* booster, when an event is signalled that tells that it just started raining.

## Managing Events

As discussed above, you can use predefined events or define your own events in the rule engine of a given Assistant, when using the *Reasoning* booster.

A special editor is provided to manage the events for a given Assistant. There are several predefined events available for the different assistants, but you can also define your own ones.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Reasoning%20Events.JPG)

As you can see, this editor looks very similar to the actions editor discussed above. But there are many differences in the details. Please follow the instructions below, when defining your own events.

1. You have to supply a "Signal" name which uniquely identifies the event. When an event is raised by code, you have to supply exactly this identifier.

2. You have to supply a phrase which decribes the event to the LLM. Example: "It just started raining." If your event has defined parameters, you can reference the values of the arguments to the event in the phrase by enclosing them in "%". Example: "We started lap %lapNumber%." Since the "%" has therefore a special meaning, you must escape it when it is used alone. Preceed the percentage character with a backquote (`) or a backslash to do that.

   ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Reasoning%20Event%20Arguments.JPG)

3. The following event typs are supported:

   | Event Type  | Description |
   |-------------|-------------|
   | Event Class | The event is handled by an instance of a builtin class. This is mainly used for predefined events provided by the Assistant implementation. Butif you are an experienced developer, you can implement your own event classes, which are based on the "AssistantEvent" class. Notes:<br><br>1. The name of the class must be entered into the "Class" field. It must be in the global name space.<br><br>2. You have to supply the "Signal" identifier, but you don't have to provide an event phrase, since this is derived by the implementation of the event class. |
   | Event Rule | The supplied rules are loaded into the rule engine of the given Race Assistant. These rules have full access to the knowledge base and all other rules of this Assistant.<br><br>The event rules can use the full knowledge to derive whether the event in question should be raised. They then raise the event by *calling* the "Assistant.Raise* predicate, optionally supplying additional arguments to the event, which can be referenced in the event phrase.<br><br>Note: Actually, you don't have to raise an event in the event rules, if you are able to handle the situation directly using the rules. In this case, the LLM is not activated. |
   | Event Disabled | This is a special one, inidcated by a "-" in the "Active" column in the list of events. It declares that the event is consumed, so that the rule engine does not do the default processing for this event. But the event is also processed by the LLM effectively disabling this type of event at all. This makes sense in combination with very smart LLMs, which will trigger actions simply by looking at the data (see the discussion [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#connecting-events--actions). This makes only sense for the builtin events, of course. |

3. When defining the rules for a custom event, you can use all the predicates and functions introduced above for actions. Additionally, you can use:
   
   - Assistant.Raise(signal, p1, p2, ...)
   
     Raises the given *signal*, thereby identifying the event to be processed by the LLM.
	 
   - Assistant.Trigger(action, p1, p2, ...)
   
     Activates a defined action without going through the LLM processing. The action is located by its name and is invoked directly with the supplied arguments.
	 
   *Assistant.Raise* and *Assistant.Trigger* also come in a different flavour. When the first argument is the type of an Assistant (like "Race Engineer", "Race Strategist" and so on), the second argument must be the signal and this signal is raised for the supplied Assistant. This can be used for communication between the different Assistants.
   
   - Assistant.Raise(assistant, signal, p1, p2, ...)
   
     Raises the given *signal* for the given *assistant*, thereby identifying the event to be processed by the LLM.
	 
   - Assistant.Trigger(assistant, action, p1, p2, ...)
   
     Activates a defined *action* for the given *assistant*. The action is located by its name and is invoked directly with the supplied arguments.

Here is an example of a few rules that together detect that it just started raining. Then the event "RainStart" is signalled to the LLM, which then can react and switch on the wiper, for example.

	{None: [?Rain.Last]} => (Prove: Rain.Start.updateRain(Rain.Last))

	{All: [?Lap], {Prove: Rain.Stop.updateRain(Rain.Now)},
		  [?Rain.Now != ?Rain.Last], [?Rain.Now = true]} => (Call: Assistant.Raise(RainStart))

	priority: -5, {All: [?Lap], [?Rain.Now != ?Rain.Last]} => (Prove: Rain.Start.updateRain(Rain.Last))

	Rain.Start.updateRain(?fact) <= !Weather.Weather.Now = Dry, !, Set(?fact, false)
	Rain.Start.updateRain(?fact) <= !Weather.Weather.Now = Drizzle, !, Set(?fact, false)
	Rain.Start.updateRain(?fact) <= Set(?fact, true)

Another example, this time using arguments:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Event%20Definition%201.png)

This event signals a position change. The previous position and the new position are passed to the LLM for further investigation. Please note the subtle usage of the previous value of *Position.Lost* in the rule actions. Although it will be reset in the first action, the old value will be used in the second action. See [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine#referencing-facts-in-production-rules) for more information about this variable behaviour.
 
Please also take a look at the other predefined events of the Race Engineer or the other Assistants to learn more about writing event rules. And I recommend to take a look at the knowledge base of a session to learn more about all the facts you can use in the event rules (and also the action rules). To do this, activate the "Debug Knowledgebase" item in the tray bar menu of a given Assistant applicaton. Then open the corrsponding "*.knowledge" file in the *Simulator Controller\Temp* folder which is located in your user *Documents* folder.

Good to know: When an event handler is located for a given event signal, custom events are checked before all predefined events. This allows for customization of the predefined events.

## Predefined Actions & Events

All Race Assistants come with a set of predefined Actions and Events for you to choose from. Most of the Actions will be available both in the *Conversation* and in the *Reasoning* boosters, but there are exceptions. Below is a complete reference for each Assistant.

Please note, that it depends on the available data in the knowledge base, whether the LLM will decide to trigger an action or not. If the LLM refuses to do so, you still have all the traditional voice commands and the controller actions at your disposal.

Beside the predefined actions for the different Assistant, which come with the standard installation as listed below, you can also define your own actions & events. But this will require a very deep knowledge of the inner workings of Simulator Controller and the Assistants. You have been warned.

### Race Engineer

#### Actions

| Action                      | Parameter(s)      | Conversation | Reasoning | Command(s) / Description |
|-----------------------------|-------------------|--------------|-----------|--------------------------|
| Pitstop Planning            | 1. [Optional] targetLap<br>2. [Optional] refuelAmount<br>3. [Optional] changeTyres<br>4. [Optional] tyreCompound<br>5. [Optional] repairDamage<br>6. [Optional] swapDriver | Yes | Yes | "We must pit for repairs. Can you create a plan without refueling and without tyre change?"<br>*changeTyres*, *repairDamage* and *swapDriver* all indicate using a *Boolean* whether the repsective service will be provided during pitstop. A tyre compound for the new tyres can be supplied with *tyreCompound*, if a tyre change is requested. |
| Pitstop Clearance           | -                 | Yes | Yes | "I have changed my mind, the pitstop is no longer needed." |
| Damage Impact Recalculation | -                 | Yes | No | "Can you recalculate the time loss caused by the damage?" |
| Low Fuel Reporting          | 1. [Required] remainingFuel<br>2. [Required] remainingLaps | No | Yes | This action informs the driver that fuel is getting low and the pitstop will be needed. |
| Low Energy Reporting        | 1. [Required] remainingEnergy<br>2. [Required] remainingLaps | No | Yes | This action informs the driver that virtual energy is getting low and the pitstop will be needed. Only used in *Le Mans Ultimate* at the time of this writing. |
| Tyre Wear Reporting         | 1. [Required] tyre<br>2. [Required] wear | No | Yes | Informs the driver that the tread of at least one of the tyres may be worn out and a tyre change should be planned. *tyre* must be one of "FL", "FR", "RL" and "RR" and *wear* is the current wear in percentage. |
| Brake Wear Reporting        | 1. [Required] wheel<br>2. [Required] wear | No | Yes | Informs the driver that at least one of the brake pads may be worn out and a change of brake pads should be planned. *wheel* must be one of "FL", "FR", "RL" and "RR" and *wear* is the current wear in percentage. |
| Damage Reporting            | 1. [Required] suspensionDamage<br>2. [Required] bodyworkDamage<br>3. [Required] engineDamage | No | Yes | This action informs the driver that some damage has been collected in the last accident. |
| Time Loss Reporting         | 1. [Required] lapsToDrive<br>2. [Required] timeLoss | No | Yes | Typically activated when it has been detected that the time lost per lap is too high for the remaining laps of the current stint. There is an event available, that signals time loss. *lapsToDrive* is the number of remaining laps in the current stint, *timeLoss* the time lost per lap in seconds. |
| No Time Loss Reporting      | 1. [Required] lapsToDrive<br>2. [Required] timeLoss | No | Yes | Typically activated when the driver has recovered its pace after an accident later on and repairs are no longer needed. There is an event available, that signals this fact. *lapsToDrive* is the number of remaining laps in the current stint, *timeLoss* the time lost per lap in seconds. |
| Pressure Loss Warning     | 1. [Required] tyre<br>2. [Required] lostPressure | No | Yes | Typically activated when a pressure loss has been detected in the telemetry data. There is an event available, that signals pressure loss. *tyre* must be one of "FL", "FR", "RL" and "RR" and *lostPressure* must be the amount of lost pressure in PSI. |
| Weather Reporting (1)       | 1. [Required] weather<br>2. [Required] minutes<br>3. [Required] impactsStrategy | No | Yes | Typically activated when an upcoming weather change is detected in the telemetry data. There is an event available, that signals a change in the weather forecast. *weather* must be one of "Dry", "Drizzle", "LightRain", "MediumRain", "HeavyRain" and "Thunderstorm". *minutes* specify the time, when the new weather will arrive and *impactsStrategy* accepts a *Boolean* that indicates, whether a tyre change might be beneficial. |

##### Notes

1. Not available, when the Race Strategist is active.

#### Events

| Event                       | Parameter(s)      | Description |
|-----------------------------|-------------------|-------------|
| Fuel Low                    | 1. [Required] remainingFuel<br>2. [Required] remainingLaps | When the car is running low on fuel, this event is signalled. |
| Energy Low                  | 1. [Required] remainingEnergy<br>2. [Required] remainingLaps | When the car is running low on virtual energy, this event is signalled. Only used in *Le Mans Ultimate* at the time of this writing. |
| Tyre Wear                   | 1. [Required] tyre<br>2. [Required] wear | When a tyre is almost worn out, this event is signalled. *tyre* will be one of "FL", "FR", "RL" and "RR" and *wear* is the current wear of the tread of this tyre in percentage. |
| Brake Wear                   | 1. [Required] wheel<br>2. [Required] wear | When one of the brake pads is almost worn out, this event is signalled. *wheel* will be one of "FL", "FR", "RL" and "RR" and *wear* is the current wear of this brake pad in percentage. |
| Damage Collected            | 1. [Required] suspensionDamage<br>2. [Required] bodyworkDamage<br>3. [Required] engineDamage | This event is signalled, if new damage is detected for a part of the car. The parameters accept *Boolean* values to indicate where the damage occured. |
| Time Loss                   | 1. [Required] lapsToDrive<br>2. [Required] timeLoss | This event is signalled, if an analysis has shown, that the time lost per lap after an incident is too high for the remaining laps of the current stint. *lapsToDrive* is the number of remaining laps in the current stint, *timeLoss* the time lost per lap in seconds. |
| No Time Loss                | 1. [Required] lapsToDrive<br>2. [Required] timeLoss | This event is signalled, if an analysis has shown, that the driver has recovered his pace and an additional pitstop is no longer beneficial. *lapsToDrive* is the number of remaining laps in the current stint, *timeLoss* the time lost per lap in seconds. |
| Pressure Loss               | 1. [Required] tyre<br>2. [Required] lostPressure | This event is signalled, if a loss of ressure has been detected in a tyre. *tyre* will be one of "FL", "FR", "RL" and "RR" and *lostPressure* will be the amount of lost pressure in PSI. |
| Weather Update (1)          | 1. [Required] weather<br>2. [Required] minutes<br>3. [Required] impactsStrategy<br>4. [Optional] tyreCompound | Indicates an upcoming weather change. *weather* must be one of "Dry", "Drizzle", "LightRain", "MediumRain", "HeavyRain" and "Thunderstorm". *minutes* specify the time, when the new weather will arrive and *impactsStrategy* accepts a *Boolean* that indicates, whether a tyre change might be beneficial. If *tyreCompound* has been supplied, this indicates that a pitstop for tyre change should be planned. |
| Rain Started                | - | This event is signalled, if rain just started. |
| Rain Stopped                | - | This event is signalled, if rain just stopped. |

##### Notes

1. Not available, when the Race Strategist is active.

### Race Strategist

#### Actions

| Action                 | Parameter(s)      | Conversation | Reasoning | Command(s) / Description |
|------------------------|-------------------|--------------|-----------|--------------------------|
| Pitstop Simulation     | [Optional] lap    | Yes | No | "What do you think? Can we go for an undercut in lap 7?" or "Can we get some clean air when we pit earlier?" |
| Pitstop Planning       | [Optional] lap    | Yes | Yes | "Can you ask the Engineer to create a pitstop plan for the next lap?" |
| Pitstop Announcement   | [Required] lap    | No  | Yes | Announces an upcoming pitstop according to the currently active strategy. |
| Strategy Update (1)    | -                 | Yes | No | "Can you check whether we can skip the last pitstop, if we use a fuel saving map from now on?" |
| Strategy Update (2)    | [Optional] lap    | No | Yes | Recalculates the current strategy. If the optional lap number for the next pitstop is supplied, the Strategist will check whether a pitstop at a given lap might be beneficial and is also allowed for the currently active strategy. |
| Weather Reporting      | 1. [Required] weather<br>2. [Required] minutes<br>3. [Required] impactsStrategy | No | Yes | Typically activated when an upcoming weather change is detected in the telemetry data. There is an event available, that signals a change in the weather forecast. *weather* must be one of "Dry", "Drizzle", "LightRain", "MediumRain", "HeavyRain" and "Thunderstorm". *minutes* specify the time, when the new weather will arrive and *impactsStrategy* accepts a *Boolean* that indicates, whether a tyre change might be beneficial. |

##### Notes

1. This action is available in the *Conversation* booster. It will recalculate the strategy according to the current race situation and environmental conditions. Will show the same result as the [plugin action "StrategRecommend"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) and the corresponding voice command.
2. This version of "Strategy Update" is available in the *Reasoning* booster. It will check whether a pitstop in the next lap is valid in the context of the current strategy and might create some benefit. Therefore it might be triggered, when the Spotter detected, that a direct opponent has entered the pit.

#### Events

| Event                       | Parameter(s)      | Description |
|-----------------------------|-------------------|-------------|
| Pitstop Upcoming            | [Required] plannedLap | This event is triggered when the next pitstop according to the currently active strategy is upcoming. *plannedLap* accepts an *Integer*. |
| Weather Update              | 1. [Required] weather<br>2. [Required] minutes<br>3. [Required] impactsStrategy<br>4. [Optional] tyreCompound | Indicates an upcoming weather change. *weather* must be one of "Dry", "Drizzle", "LightRain", "MediumRain", "HeavyRain" and "Thunderstorm". *minutes* specify the time, when the new weather will arrive and *impactsStrategy* accepts a *Boolean* that indicates, whether a tyre change might be beneficial. If *tyreCompound* has been supplied, this indicates that a pitstop for tyre change should be planned. |
| Rain Started                | - | This event is signalled, if rain just started. |
| Rain Stopped                | - | This event is signalled, if rain just stopped. |
| Position Lost               | 1. [Required] previousPosition<br>2. [Required] currentPosition | This event is signalled, if one or more positions has just been lost. *previousPosition* and *currentPosition* inidcate the position before and after the overtake. |
| Position Gained             | 1. [Required] previousPosition<br>2. [Required] currentPosition | This event is signalled, if one or more positions has just been gained. *previousPosition* and *currentPosition* inidcate the position before and after the overtake. |

### Race Spotter

#### Actions

| Action                   | Parameter(s) | Conversation | Reasoning | Command(s) / Description |
|--------------------------|--------------|--------------|-----------|--------------------------|
| Reset Deltas             | -            | Yes | No | "Can you reset the delta information for all cars?" |
| Reset Accident Detection | -            | Yes | No | "There are false positives for accidents and slow cars on the track. Please correct that." |
| Start Track Mapping      | -            | Yes | No | "Can you start the track mapping?" |
| Stop Track Mapping       | -            | Yes | No | "Please stop mapping the track." |

#### Events

| Event                       | Parameter(s)      | Description |
|-----------------------------|-------------------|-------------|
| Position Lost               | 1. [Required] previousPosition<br>2. [Required] currentPosition | This event is signalled, if one or more positions has just been lost. *previousPosition* and *currentPosition* inidcate the position before and after the overtake. |
| Position Gained             | 1. [Required] previousPosition<br>2. [Required] currentPosition | This event is signalled, if one or more positions has just been gained. *previousPosition* and *currentPosition* inidcate the position before and after the overtake. |
| Ahead Gap Update            | 1. [Required] carNumber<br>2. [Required] delta<br>3. [Required] closingIn | This event is signalled periodically, when the gap to the opponent ahead has changed for a given amount, which can be configured in the "Session Database". *carNumber* is the car or race number of the car ahead and *delta* is the current gap in seconds. *closingIn* is a boolean, which indicates whether the gap got smaller. |
| Behind Gap Update           | 1. [Required] carNumber<br>2. [Required] delta<br>3. [Required] closingIn | This event is signalled periodically, when the gap to the opponent behind has changed for a given amount, which can be configured in the "Session Database". *carNumber* is the car or race number of the car ahead and *delta* is the current gap in seconds. *closingIn* is a boolean, which indicates whether the gap got smaller. |
| Attack Imminent             | 1. [Required] carNumber<br>2. [Required] delta | This event is signalled, when an opponent has closed in and an attack might happen soon. *carNumber* is the car or race number of the car closing in and *delta* is the current gap in seconds. |
| Blue Flag Alert             | - | Signalled, when a blue flag is being shown, because an opponent is closing in who is at least one lap ahead. |
| Opponent Pitting            | [Optional] opponentPosition | Informs about an opponent going to the pits. If this is a direct opponent, *opponentPosition* can be supplied and must be one of "Ahead" or "Behind". |
| Pitstop Performed           | 1. [Required] pitstopNumber<br>2. [Required] pitstopLap | Signalled when the car just pitted. *pitstopNumber* and *pitstopLap* must be supplied with the number of the pitstop and the current lap. |
| Stint Ending                | [Optional] remainingLaps | Triggered when the current stint is almost over. |
| Last Lap                    | - | This event is signalled for the last lap of the session. |
| Session Over                | - | This event is signalled when the session is over. |

### Connecting Events & Actions

As usual, it depends on the capabilities of the LLM, which actions will be called as a result of a given event. Additionally, because of the inherent non-deterministic nature of LLMs, the behaviour may vary between invocations. You have to decide which events you will send to the LLM (i.e. are activated) and which events should be handled by the rule engine (i.e. are deactivated). Anyway, using the predefined events will not result in a very different behaviour than running an Assistant without the *Reasoning* booster, since in most cases the LLM will decide to connect an event to its natural corresponding action. Example: *Fuel Low* -> *Low Fuel Reporting*

As LLMs become smarter, we will be able to rely more and more on the intelligence and the domain specific knowledge of the LLM. I have run some tests using some of the current high end models (GPT 4o, Claude 3.5 Sonnet, ...) by disabling all events and running only one very simple event:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Event%20Definition%202.png)

The results are very promising, but these models are still very expensive. If you want to use this approach, make sure, that you leave all predefined events "Active" but set their type to "Event Disabled", because otherwise they will be handled by the rule engine and you might end up with duplicate behaviour, for example a pitstop being planned twice.