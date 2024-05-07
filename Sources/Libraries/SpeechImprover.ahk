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
#Include "SpeechRecognizer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SpeechImprover extends ConfigurationItem {
	iOptions := CaseInsenseMap()

	iConnector := false

	iCompiler := SpeechRecognizer("Compiler")

	iChoices := CaseInsenseMap()
	iGrammars := CaseInsenseMap()

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

	Model {
		Get {
			return this.Options["Model"]
		}
	}

	Probability {
		Get {
			return this.Options["Probability"]
		}
	}

	Temperature {
		Get {
			return this.Options["Temperature"]
		}
	}

	Compiler {
		Get {
			return this.iCompiler
		}
	}

	Choices[name?] {
		Get {
			return (isSet(name) ? this.iChoices[name] : this.iChoices)
		}
	}

	Grammars[name?] {
		Get {
			return (isSet(name) ? this.iGrammars[name] : this.iGrammars)
		}
	}

	Connector {
		Get {
			return this.iConnector
		}
	}

	__New(descriptor, configuration, language := false) {
		local allLanguages, index

		this.Options["Descriptor"] := descriptor
		this.Options["Language"] := language

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
	}

	loadFromConfiguration(configuration) {
		local descriptor := this.Descriptor
		local options := this.Options

		super.loadFromConfiguration(configuration)

		options["Language"] := getMultiMapValue(configuration, "Speech Improver", descriptor . ".Language", this.Language)
		options["Service"] := getMultiMapValue(configuration, "Speech Improver", descriptor . ".Service", false)
		options["Model"] := getMultiMapValue(configuration, "Speech Improver", descriptor . ".Model", false)
		options["Probability"] := getMultiMapValue(configuration, "Speech Improver", descriptor . ".Probability", 0.5)
		options["Temperature"] := getMultiMapValue(configuration, "Speech Improver", descriptor . ".Temperature", 0.5)
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

	setChoices(name, choices) {
		this.iChoices[name] := choices

		this.Compiler.setChoices(name, choices)
	}

	setGrammar(name, grammar) {
		try {
			this.iGrammars[name] := this.createGrammar(this.Compiler.compileGrammar(grammar))
		}
		catch Any as exception {
			logError(exception, true)

			logMessage(kLogCritical, translate("Error while registering voice command `"") . grammar . translate("`" - please check the configuration"))

			showMessage(substituteVariables(translate("Cannot register voice command `"%command%`" - please check the configuration..."), {command: grammar})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}

	createGrammar(grammar) {
		return grammar.Phrases
	}

	speak(text, options := false) {
		local doRephrase, doTranslate, code, language, fileName, languageInstructions, instruction

		static instructions := false

		if !instructions
			for code, language in availableLanguages() {
				languageInstructions := readMultiMap(kTranslationsDirectory . "Speech Improver.instructions." . code)

				addMultiMapValues(languageInstructions, readMultiMap(kUserTranslationsDirectory . "Speech Improver.instructions." . code))

				instructions[code] := languageInstructions
			}

		if this.Model {
			code := this.Code
			language := this.Language
			doRephrase := true
			doTranslate := (language != false)

			if options {
				if !isInstance(options, Map)
					options := toMap(options)

				doRephrase := ((Random(1, 10) <= (10 * this.Probability)) && (!options.Has("Rephrase") || options["Rephrase"]))
				doTranslate := (language && (!options.Has("Translate") || options["Translate"]))
			}

			if (doRephrase || doTranslate) {
				try {
					if !this.Connector
						this.startImprover()

					if options.Has("Language")
						code := options["Language"]

					if (doRephrase && doTranslate)
						instruction := "RephraseTranslate"
					else if doTranslate
						instruction := "Translate"
					else
						instruction := "Rephrase"

					answer := this.Connector.Ask(substituteVariables(getMultiMapValue(instructions[instructions.Has(code) ? code: "EN"]
																					, "Speaker.Instructions", instruction)
																   , {language: language ? language : "", text: text}))

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

	listen(text, &arguments?) {
		return false
	}
}