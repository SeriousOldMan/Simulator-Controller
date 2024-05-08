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

	iCommands := false

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

	Speaker {
		Get {
			return this.Options["Speaker"]
		}
	}

	SpeakerProbability {
		Get {
			return this.Options["SpeakerProbability"]
		}
	}

	Listener {
		Get {
			return this.Options["Listener"]
		}
	}

	ListenerMode {
		Get {
			return this.Options["ListenerMode"]
		}
	}

	Temperature[type := "Speaker"] {
		Get {
			return this.Options[(type = "Speaker") ? "SpeakerTemperature" : "ListenerTemperature"]
		}
	}

	Compiler {
		Get {
			return this.iCompiler
		}
	}

	Commands {
		Get {
			return this.iCommands
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

		options["Speaker"] := getMultiMapValue(configuration, "Speech Improver", descriptor . ".Speaker", true)
		options["SpeakerProbability"] := getMultiMapValue(configuration, "Speech Improver", descriptor . ".SpeakerProbability"
														, getMultiMapValue(configuration, "Speech Improver", descriptor . ".Probability", 0.5))
		options["SpeakerTemperature"] := getMultiMapValue(configuration, "Speech Improver", descriptor . ".SpeakerTemperature"
														, getMultiMapValue(configuration, "Speech Improver", descriptor . ".Temperature", 0.5))

		options["Listener"] := getMultiMapValue(configuration, "Speech Improver", descriptor . ".Listener", false)
		options["ListenerMode"] := getMultiMapValue(configuration, "Speech Improver", descriptor . ".ListenerMode", "Unknown")
		options["ListenerTemperature"] := getMultiMapValue(configuration, "Speech Improver", descriptor . ".ListenerTemperature", 0.2)
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
			this.iGrammars[name] := this.Compiler.compileGrammar(grammar)
		}
		catch Any as exception {
			logError(exception, true)

			logMessage(kLogCritical, translate("Error while registering voice command `"") . grammar . translate("`" - please check the configuration"))

			showMessage(substituteVariables(translate("Cannot register voice command `"%command%`" - please check the configuration..."), {command: grammar})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}

	speak(text, options := false) {
		local doRephrase, doTranslate, code, language, fileName, languageInstructions, instruction

		static instructions := false

		if !instructions {
			instructions := CaseInsenseMap()

			for code, language in availableLanguages() {
				languageInstructions := readMultiMap(kTranslationsDirectory . "Speech Improver.instructions." . code)

				addMultiMapValues(languageInstructions, readMultiMap(kUserTranslationsDirectory . "Speech Improver.instructions." . code))

				instructions[code] := languageInstructions
			}
		}

		if (this.Model && this.Speaker) {
			code := this.Code
			language := this.Language
			doRephrase := true
			doTranslate := (language != false)

			if options {
				if !isInstance(options, Map)
					options := toMap(options)

				doRephrase := ((Random(1, 10) <= (10 * this.SpeakerProbability)) && (!options.Has("Rephrase") || options["Rephrase"]))
				doTranslate := (language && (!options.Has("Translate") || options["Translate"]))
			}

			if (doRephrase || doTranslate) {
				try {
					if !this.Connector
						this.startImprover()

					this.Connector.Temperature := this.Temperature["Speaker"]

					if options.Has("Language")
						code := options["Language"]

					if (doRephrase && doTranslate)
						instruction := "RephraseTranslate"
					else if doTranslate
						instruction := "Translate"
					else
						instruction := "Rephrase"

					instruction := substituteVariables(getMultiMapValue(instructions[instructions.Has(code) ? code : "EN"]
																	  , "Speaker.Instructions", instruction)
													 , {language: language ? language : "", text: text})

					answer := this.Connector.Ask(instruction)

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

	listen(text, options := false) {
		local commands := this.Commands
		local doRecognize, code, language, fileName, languageInstructions, instruction
		local phrase, name, grammar, phrases, candidates, numCandidates

		static instructions := false

		if !instructions {
			instructions := CaseInsenseMap()

			for code, language in availableLanguages() {
				languageInstructions := readMultiMap(kTranslationsDirectory . "Speech Improver.instructions." . code)

				addMultiMapValues(languageInstructions, readMultiMap(kUserTranslationsDirectory . "Speech Improver.instructions." . code))

				instructions[code] := languageInstructions
			}
		}

		if !commands {
			commands := []

			for name, grammar in this.Grammars {
				candidates := grammar.Phrases
				numCandidates := candidates.Length

				if (numCandidates > 0) {
					phrases := []

					if (numCandidates > 10) {
						loop {
							phrase := candidates[Max(1, Min(numCandidates, Random(1, numCandidates)))]

							if !inList(phrases, phrase)
								phrases.Push(phrase)
						}
						until ((phrases.Length = numCandidates) || (phrases.Length = 5))
					}
					else
						for ignore, phrase in candidates
							if (A_Index > 5)
								break
							else
								phrases.Push(phrase)

					commands.Push(name . "=" . values2String(", ", phrases*))
				}
			}

			commands := values2String("`n", commands*)

			this.iCommands := commands
		}

		if (this.Model && this.Listener) {
			code := this.Code
			doRecognize := true

			if options {
				if !isInstance(options, Map)
					options := toMap(options)

				doRecognize := (!options.Has("Recognize") || options["Recognize"])
			}

			if doRecognize {
				try {
					if !this.Connector
						this.startImprover()

					this.Connector.Temperature := this.Temperature["Listener"]

					instruction := "Recognize"

					instruction := substituteVariables(getMultiMapValue(instructions[instructions.Has(code) ? code : "EN"]
																	  , "Listener.Instructions", instruction)
													 , {commands: commands, text: text})

					answer := this.Connector.Ask(instruction)

					return ((!answer || (answer = "Unknown")) ? text : answer)
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