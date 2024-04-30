;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Speech Improver                 ;;;
;;;                                                                         ;;;
;;;   Provides several GPT-based Pre- and Postprocessors for speech output  ;;;
;;;   and voice recognition.                                                ;;;
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

#Include "LLMConnector.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SpeechImprover extends ConfigurationItem {
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
			return ["OpenAI", "Azure", "GPT4All", "LLM Runtime"]
		}
	}

	Descriptor {
		Get {
			return this.Options["Descriptor"]
		}
	}

	Language {
		Get {
			return this.Options["Language"]
		}
	}

	Model {
		Get {
			return this.Options["Model"]
		}
	}

	Temperature {
		Get {
			return this.Options["Temperature"]
		}
	}

	Connector {
		Get {
			return this.iConnector
		}
	}

	__New(descriptor, configuration, language := false) {
		this.Options["Descriptor"] := descriptor
		this.Options["Language"] := language

		super.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		local descriptor := this.Descriptor
		local options := this.Options

		super.loadFromConfiguration(configuration)

		options["Language"] := getMultiMapValue(configuration, "Voice Improver", descriptor . ".Language", this.Language)
		options["Service"] := getMultiMapValue(configuration, "Voice Improver", descriptor . ".Service", false)
		options["Model"] := getMultiMapValue(configuration, "Voice Improver", descriptor . ".Model", false)
		options["Temperature"] := getMultiMapValue(configuration, "Voice Improver", descriptor . ".Temperature", 0.5)
	}

	getInstructions() {
		return []
	}

	connectorState(*) {
	}

	startImprover() {
		local service := this.Options["Service"]
		local ignore, instruction

		if service {
			service := string2Values("|", service)

			if !inList(this.Providers, service[1])
				throw "Unsupported service detected in SpeechImprover.startImprover..."

			if (service[1] = "LLM Runtime")
				this.iConnector := LLMConnector.LLMRuntimeConnector(this, this.Options["Model"])
			else
				try {
					this.iConnector := LLMConnector.%service[1]%Connector(this, this.Options["Model"])

					this.Connector.Connect(service[2], service[3])
				}
				catch Any as exception {
					logError(exception)

					throw "Unsupported service detected in SpeechImprover.startImprover..."
				}

			this.Connector.MaxHistory := 0
			this.Connector.Temperature := this.Options["Temperature"]
		}
		else
			throw "Unsupported service detected in SpeechImprover.startImprover..."
	}

	improve(text, options := false) {
		local rephrase := true
		local translate := (this.Language != false)

		if this.Model {
			if options {
				rephrase := (!options.Has("Rephrase") || options["Rephrase"])
				translate := (this.Language && !options.Has("Translate") || options["Tranlate"])
			}

			if (rephrase || translate) {
				try {
					if !this.Connector
						this.startImprover()

					if rephrase {
						instruction := "Rephrase the text after the three |"

						if translate
							instruction .= (" and translate it to " . this.Language)
						else
							instruction .= " and retain its original language"
					}
					else
						instruction := ("Translate the text after the three | to " . this.Language)

					instruction .= ". Do only answer with the new text. `n|||`n"

					answer := this.Connector.Ask(instruction . text)

					return (answer ? answer : text)
				}
				catch Any as exception {
					logError(exception)

					return text
				}
			}
			else
				return text
		}
		else
			return text
	}
}