;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Speech Processor                ;;;
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

class SpeechParaphraser extends ConfigurationItem {
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

	__New(configuration, language := false) {
		this.Options["Language"] := language

		super.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		local options, laps

		super.loadFromConfiguration(configuration)

		options := this.Options

		options["Language"] := getMultiMapValue(configuration, "Voice Processing", "Paraphraser.Language", getMultiMapValue(configuration, "Paraphraser", "Language", this.Language))
		options["Service"] := getMultiMapValue(configuration, "Voice Processing", "Paraphraser.Service", getMultiMapValue(configuration, "Paraphraser", "Service", false))
		options["Model"] := getMultiMapValue(configuration, "Voice Processing", "Paraphraser.Model", getMultiMapValue(configuration, "Paraphraser", "Model", false))
		options["Temperature"] := getMultiMapValue(configuration, "Voice Processing", "Paraphraser.Temperature", getMultiMapValue(configuration, "Paraphraser", "Temperature", 0.5))
	}

	getInstructions() {
		return []
	}

	connectorState(*) {
	}

	startParaphraser() {
		local service := this.Options["Service"]
		local ignore, instruction

		if service {
			service := string2Values("|", service)

			if !inList(this.Providers, service[1])
				throw "Unsupported service detected in SpeechParaphraser.startParaphraser..."

			if (service[1] = "LLM Runtime")
				this.iConnector := LLMConnector.LLMRuntimeConnector(this, this.Options["Model"])
			else
				try {
					this.iConnector := LLMConnector.%service[1]%Connector(this, this.Options["Model"])

					this.Connector.Connect(service[2], service[3])
				}
				catch Any as exception {
					logError(exception)

					throw "Unsupported service detected in SpeechParaphraser.startParaphraser..."
				}

			this.Connector.Temperature := this.Options["Temperature"]
		}
		else
			throw "Unsupported service detected in SpeechParaphraser.startParaphraser..."
	}

	paraphrase(text) {
		if this.Model {
			try {
				if !this.Connector
					this.startParaphraser()

				instruction := "Rephrase the text after the three #"

				if this.Language
					instruction .= (" and translate it to " . this.Language)
				else
					instruction .= " and retain its original language"

				instruction .= ". Do only answer with the new text. `n###`n"

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
}