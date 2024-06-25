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


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class LLMAgent extends ConfigurationItem {
	iOptions := CaseInsenseMap()

	iConnector := false

	Options[key?] {
		Get {
			return (isSet(key) ? this.iOptions[key] : this.iOptions)
		}

		Set {
			return (isSet(key) ? (this.iOptions[key] := value) : (this.iOptions := value))
		}
	}

	Providers {
		Get {
			return LLMConnector.Providers
		}
	}

	Descriptor {
		Get {
			throw "Virtual property LLMAgent.Descriptor must be implemented in a subclass..."
		}
	}

	Model {
		Get {
			return this.Options["Model"]
		}
	}

	MaxTokens {
		Get {
			return this.Options["MaxTokens"]
		}
	}

	Connector {
		Get {
			return this.iConnector
		}
	}

	loadFromConfiguration(configuration) {
		local descriptor := this.Descriptor
		local options := this.Options

		super.loadFromConfiguration(configuration)

		options["Service"] := getMultiMapValue(configuration, "Autonomous Agent", descriptor . ".Service", false)
		options["Model"] := getMultiMapValue(configuration, "Autonomous Agent", descriptor . ".Model", false)
		options["MaxTokens"] := getMultiMapValue(configuration, "Autonomous Agent", descriptor . ".MaxTokens", 2048)
	}

	startAgent() {
		local service := this.Options["Service"]
		local ignore, instruction

		if service {
			service := string2Values("|", service)

			if !inList(this.Providers, service[1])
				throw "Unsupported service detected in LLMAgent.startAgent..."

			if (service[1] = "LLM Runtime")
				this.iConnector := LLMConnector.LLMRuntimeConnector(this, this.Options["Model"])
			else
				try {
					this.iConnector := LLMConnector.%StrReplace(service[1], A_Space, "")%Connector(this, this.Options["Model"])

					this.Connector.Connect(service[2], service[3])
				}
				catch Any as exception {
					logError(exception)

					throw "Unsupported service detected in LLMAgent.startAgent..."
				}

			this.Connector.MaxTokens := this.MaxTokens
		}
		else
			throw "Unsupported service detected in LLMAgent.startAgent..."
	}
}

class AutonomousAgent extends LLMAgent {
	iTranscript := false

	iInstructions := false

	Descriptor {
		Get {
			return this.Options["Descriptor"]
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

	Temperature {
		Get {
			return this.Options["Temperature"]
		}
	}

	Instructions[language?] {
		Get {
			local instructions, ignore, instrLanguage, directory, key, value

			if !this.iInstructions {
				instructions := CaseInsenseMap()

				for ignore, directory in [kTranslationsDirectory, kUserTranslationsDirectory]
					loop Files (directory . "Autonomous Agent.instructions.*") {
						SplitPath A_LoopFilePath, , , &instrLanguage

						if !instructions.Has(instrLanguage)
							instructions[instrLanguage] := newMultiMap()

						addMultiMapValues(instructions[instrLanguage], readMultiMap(A_LoopFilePath))
					}

				for key, value in getMultiMapValues(this.Configuration, "Autonomous Agent")
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

	__New(descriptor, configuration, language := false) {
		local transcripts := getMultiMapValue(configuration, "Autonomous Agents", descriptor . ".Transcripts"
														   , kTempDirectory . "Transcripts\")
		local allLanguages, index

		this.Options["Descriptor"] := descriptor

		this.iTranscript := (normalizeDirectoryPath(transcripts) . "\" . descriptor . ".txt")

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
		else
			this.Options["Code"] := false

		DirCreate(kTempDirectory . "Transcripts\")
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		this.Options["Language"] := getMultiMapValue(configuration, "Conversation Booster", this.Descriptor . ".Language", this.Language)
	}

	getInstructions() {
		return []
	}

	getTools() {
		return []
	}

	connectorState(*) {
	}

	startAgent() {
		super.startAgent()

		if this.Connector
			this.Connector.MaxHistory := 0
	}

	normalizeAnswer(answer) {
		return Trim(StrReplace(StrReplace(answer, "*", ""), "|||", ""), " `t`r`n")
	}
}