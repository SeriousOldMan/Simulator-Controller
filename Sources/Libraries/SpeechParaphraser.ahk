;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Speech Paraphraser              ;;;
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

	Connector {
		Get {
			return this.iConnector
		}
	}

	__New(language, configuration) {
	}

	loadFromConfiguration(configuration) {
		local options, laps, ignore, instruction

		super.loadFromConfiguration(configuration)

		options := this.Options

		options["Paraphraser.Service"] := getMultiMapValue(configuration, "Voice Control", "Paraphraser.Service", getMultiMapValue(configuration, "Paraphraser", "Service", false))
		options["Paraphraser.Model"] := getMultiMapValue(configuration, "Voice Control", "Paraphraser.Model", false)
		options["Paraphraser.Temperature"] := getMultiMapValue(configuration, "Voice Control", "Paraphraser.Temperature", 0.5)
	}

	startParaphraser() {
		local service := this.Options["Paraphraser.Service"]
		local ignore, instruction

		if service {
			service := string2Values("|", service)

			if !inList(this.Providers, service[1])
				throw "Unsupported service detected in SpeechParaphraser.startParaphraser..."

			if (service[1] = "LLM Runtime")
				this.iConnector := LLMConnector.LLMRuntimeConnector(this, this.Options["Paraphraser.Model"])
			else
				try {
					this.iConnector := LLMConnector.%service[1]%Connector(this, this.Options["Paraphraser.Model"])

					this.Connector.Connect(service[2], service[3])
				}
				catch Any as exception {
					logError(exception)

					throw "Unsupported service detected in SpeechParaphraser.startParaphraser..."
				}

			this.Connector.MaxTokens := this.Options["Paraphraser.MaxTokens"]
			this.Connector.Temperature := this.Options["Paraphraser.Temperature"]
		}
		else
			throw "Unsupported service detected in SpeechParaphraser.startParaphraser..."
	}

	paraphrase(text) {
		try {
			if !this.Connector
				this.startParaphraser()

			return text
		}
		catch Any as exception {
			logError(exception)

			return text
		}
	}
}