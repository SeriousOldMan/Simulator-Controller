;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LLM Agent                       ;;;
;;;                                                                         ;;;
;;;   Connects and integrates an LLM with a set of rules which create an    ;;;
;;;   autonomous agent, which can follow goals and show situational         ;;;
;;;   awareness.                                                            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Task.ahk"
#Include "LLMConnector.ahk"
#Include "LLMBooster.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class AgentEvent {
	Name {
		Get {
			throw "Virtual property AgentEvent.Name must be implemented in a subclass..."
		}
	}

	Event {
		Get {
			throw "Virtual property AgentEvent.Event must be implemented in a subclass..."
		}
	}
}

class AgentBooster extends LLMBooster {
	iManager := false

	iTranscript := false

	iInstructions := false

	Type {
		Get {
			return "Agent"
		}
	}

	Descriptor {
		Get {
			return this.Options["Descriptor"]
		}
	}

	Manager {
		Get {
			return this.iManager
		}
	}

	Active {
		Get {
			return this.Options["Active"]
		}
	}

	Code {
		Get {
			return this.Options["Code"]
		}
	}

	Language {
		Get {
			return this.Options["Language"]
		}
	}

	Instructions[language?] {
		Get {
			local instructions, ignore, instrLanguage, directory, key, value

			if !this.iInstructions {
				instructions := CaseInsenseMap()

				for ignore, directory in [kTranslationsDirectory, kUserTranslationsDirectory]
					loop Files (directory . "Agent Booster.instructions.*") {
						SplitPath A_LoopFilePath, , , &instrLanguage

						if !instructions.Has(instrLanguage)
							instructions[instrLanguage] := newMultiMap()

						addMultiMapValues(instructions[instrLanguage], readMultiMap(A_LoopFilePath))
					}

				for key, value in getMultiMapValues(this.Configuration, "Agent Booster")
					if (InStr(key, "Instructions.") = 1) {
						key := ConfigurationItem.splitDescriptor(key)

						instrLanguage := key[4]

						if !instructions.Has(instrLanguage)
							instructions[instrLanguage] := newMultiMap()

						setMultiMapValue(instructions[instrLanguage], key[2] . ".Instructions", key[3], value)
					}

				this.iInstructions := instructions
			}

			if isSet(language) {
				if this.iInstructions.Has(language)
					return this.iInstructions[language]
				else
					return newMultiMap()
			}
			else
				return this.iInstructions
		}
	}

	Transcript {
		Get {
			return this.iTranscript
		}
	}

	__New(manager, descriptor, configuration, language := false) {
		local transcripts := getMultiMapValue(configuration, "Agent Booster", descriptor . ".Transcripts"
														   , kLogsDirectory . "Transcripts\")
		local allLanguages, index

		this.iManager := manager

		this.Options["Descriptor"] := descriptor
		this.Options["Language"] := language

		this.iTranscript := (normalizeDirectoryPath(transcripts) . "\" . descriptor . " Transcript.txt")

		super.__New(configuration)

		if this.Language {
			allLanguages := availableLanguages()

			if allLanguages.Has(this.Language) {
				this.Options["Code"] := this.Language
				this.Options["Language"] := allLanguages[this.Language]
			}
			else if inList(getValues(allLanguages), this.Language)
				this.Options["Code"] := getKeys(allLanguages)[inList(getValues(allLanguages), this.Language)]
			else
				this.Options["Code"] := false
		}
		else {
			this.Options["Code"] := "EN"
			this.Options["Language"] := "English"
		}
	}

	loadFromConfiguration(configuration) {
		local descriptor := this.Descriptor
		local options := this.Options

		super.loadFromConfiguration(configuration)

		options["Language"] := getMultiMapValue(configuration, "Agent Booster", descriptor . ".Language", this.Language)
		options["Active"] := getMultiMapValue(configuration, "Agent Booster", descriptor . ".Agent", false)
	}

	getInstructions() {
		return []
	}

	getTools() {
		return this.Manager.getTools("Agent")
	}

	connectorState(*) {
	}
}

class EventBooster extends AgentBooster {
	trigger(event, trigger, goal := false, options := false) {
		local variables := false
		local doTrigger, code, language, instruction, variables, target, answer, calls

		printCall(call) {
			local arguments := call[2].Clone()

			loop arguments.Length
				if !arguments.Has(A_Index)
					arguments[A_Index] := ""

			return ("Call: " . call[1].Name . "(" . values2String(", ", arguments*) . ")")
		}

		if (this.Model && this.Active) {
			code := this.Code
			language := this.Language
			doTrigger := true

			if options {
				if !isInstance(options, Map)
					options := toMap(options)

				doTrigger := (!options.Has("Trigger") || options["Trigger"])

				if options.Has("Variables")
					variables := options["Variables"]

				if options.Has("Language")
					code := options["Language"]
			}

			if doTrigger {
				try {
					if !this.Connector
						this.startBooster()

					this.Connector.Temperature := 0.2

					if variables
						variables.language := (language ? language : "")
					else
						variables := {language: language ? language : ""}

					variables.event := trigger

					instruction := this.Instructions[code]

					target := substituteVariables(getMultiMapValue(instruction, "Agent.Instructions", "Event"), variables)

					if goal {
						variables.goal := goal

						target .= ("`n`n" . substituteVariables(getMultiMapValue(instruction, "Agent.Instructions", "Goal")
															  , variables))
					}

					instruction := this.Instructions[code]

					answer := this.Connector.Ask(target
											   , [substituteVariables(getMultiMapValue(instruction
																					 , "Agent.Instructions", "Character")
																	, variables)
												, substituteVariables(getMultiMapValue(instruction
																					 , "Agent.Instructions", "Knowledge")
																	, variables)]
											   , false, &calls := [])

					if (calls.Length > 0) {
						Task.startTask(() => FileAppend(translate("-- Event --------") . "`n`n" . ((event.Name . ":" . event.Event) . " -> " . trigger) . "`n`n" . translate("-- " . translate("Reasoning") . " ---------") . "`n`n" . values2String("`n", collect(calls, printCall)*) . "`n`n", this.Transcript, "UTF-16"), 0, kLowPriority)

						return true
					}
					else
						return false
				}
				catch Any as exception {
					logError(exception, true)
				}
			}
		}

		return false
	}
}