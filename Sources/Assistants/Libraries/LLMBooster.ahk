;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LLM Booster                     ;;;
;;;                                                                         ;;;
;;;   Provides several GPT-based Pre- and Postprocessors for speech output, ;;;
;;;   voice recognition and conversation.                                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\LLMConnector.ahk"
#Include "..\..\Libraries\SpeechRecognizer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class GPTBooster extends ConfigurationItem {
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
			throw "Virtual property GPTBooster.Descriptor must be implemented in a subclass..."
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

		options["Service"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".Service", false)
		options["Model"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".Model", false)
		options["MaxTokens"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".MaxTokens", 2048)
	}

	startBooster() {
		local service := this.Options["Service"]
		local ignore, instruction

		if service {
			service := string2Values("|", service)

			if !inList(this.Providers, service[1])
				throw "Unsupported service detected in GPTBooster.startBooster..."

			if (service[1] = "LLM Runtime")
				this.iConnector := LLMConnector.LLMRuntimeConnector(this, this.Options["Model"])
			else
				try {
					this.iConnector := LLMConnector.%StrReplace(service[1], A_Space, "")%Connector(this, this.Options["Model"])

					this.Connector.Connect(service[2], service[3])
				}
				catch Any as exception {
					logError(exception)

					throw "Unsupported service detected in GPTBooster.startBooster..."
				}

			this.Connector.MaxTokens := this.MaxTokens
		}
		else
			throw "Unsupported service detected in GPTBooster.startBooster..."
	}
}

class ConversationBooster extends GPTBooster {
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

		options["Language"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".Language", this.Language)
	}

	getInstructions() {
		return []
	}

	connectorState(*) {
	}

	startBooster() {
		super.startBooster()

		if this.Connector
			this.Connector.MaxHistory := 0
	}
}

class SpeechBooster extends ConversationBooster {
	Probability {
		Get {
			return this.Options["Probability"]
		}
	}

	loadFromConfiguration(configuration) {
		local descriptor := this.Descriptor
		local options := this.Options

		super.loadFromConfiguration(configuration)

		options["Active"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".Speaker", true)
		options["Probability"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".SpeakerProbability"
																, getMultiMapValue(configuration, "Conversation Booster", descriptor . ".Probability", 0.5))
		options["Temperature"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".SpeakerTemperature"
																, getMultiMapValue(configuration, "Conversation Booster", descriptor . ".Temperature", 0.5))
	}

	speak(text, options := false) {
		local doRephrase, doTranslate, code, language, fileName, languageInstructions, instruction

		static instructions := false

		if !instructions {
			instructions := CaseInsenseMap()

			for code, language in availableLanguages() {
				languageInstructions := readMultiMap(kTranslationsDirectory . "Conversation Booster.instructions." . code)

				addMultiMapValues(languageInstructions, readMultiMap(kUserTranslationsDirectory . "Conversation Booster.instructions." . code))

				instructions[code] := languageInstructions
			}
		}

		if (this.Model && this.Active) {
			code := this.Code
			language := this.Language
			doRephrase := true
			doTranslate := (language != false)

			if options {
				if !isInstance(options, Map)
					options := toMap(options)

				doRephrase := ((Random(1, 10) <= (10 * this.Probability)) && (!options.Has("Rephrase") || options["Rephrase"]))
				doTranslate := (options.Has("Translate") && options["Translate"])
			}

			if (doRephrase || doTranslate) {
				try {
					if !this.Connector
						this.startBooster()

					this.Connector.Temperature := this.Temperature

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
}

class RecognitionBooster extends ConversationBooster {
	iCompiler := SpeechRecognizer("Compiler")

	iChoices := CaseInsenseMap()
	iGrammars := CaseInsenseMap()

	iCommands := false

	Mode {
		Get {
			return this.Options["Mode"]
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

	loadFromConfiguration(configuration) {
		local descriptor := this.Descriptor
		local options := this.Options

		super.loadFromConfiguration(configuration)

		options["Active"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".Listener", false)
		options["Mode"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".ListenerMode", "Unknown")
		options["Temperature"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".Temperature", 0.2)
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

	recognize(text, options := false) {
		local commands := this.Commands
		local doRecognize, code, language, fileName, languageInstructions, instruction
		local phrase, name, grammar, phrases, candidates, numCandidates

		static instructions := false

		if !instructions {
			instructions := CaseInsenseMap()

			for code, language in availableLanguages() {
				languageInstructions := readMultiMap(kTranslationsDirectory . "Conversation Booster.instructions." . code)

				addMultiMapValues(languageInstructions, readMultiMap(kUserTranslationsDirectory . "Conversation Booster.instructions." . code))

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

		if (this.Model && this.Active) {
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
						this.startBooster()

					this.Connector.Temperature := this.Temperature

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

class ChatBooster extends ConversationBooster {
	MaxHistory {
		Get {
			return this.Options["MaxHistory"]
		}
	}

	loadFromConfiguration(configuration) {
		local descriptor := this.Descriptor
		local options := this.Options

		super.loadFromConfiguration(configuration)

		options["Active"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".Conversation", false)
		options["MaxHistory"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".ConversationMaxHistory", 3)
		options["Temperature"] := getMultiMapValue(configuration, "Conversation Booster", descriptor . ".ConversationTemperature", 0.2)
	}

	startBooster() {
		super.startBooster()

		if (this.Connector && this.Active)
			this.Connector.MaxHistory := this.MaxHistory
	}

	ask(question, options := false) {
		local variables := false
		local doTalk, code, language, fileName, languageInstructions, instruction, variables

		static instructions := false

		if !instructions {
			instructions := CaseInsenseMap()

			for code, language in availableLanguages() {
				languageInstructions := readMultiMap(kTranslationsDirectory . "Conversation Booster.instructions." . code)

				addMultiMapValues(languageInstructions, readMultiMap(kUserTranslationsDirectory . "Conversation Booster.instructions." . code))

				instructions[code] := languageInstructions
			}
		}

		if (this.Model && this.Active) {
			code := this.Code
			language := this.Language
			doTalk := true

			if options {
				if !isInstance(options, Map)
					options := toMap(options)

				doTalk := (!options.Has("Talk") || options["Talk"])

				if options.Has("Variables")
					variables := options["Variables"]
			}

			if doTalk {
				try {
					if !this.Connector
						this.startBooster()

					this.Connector.Temperature := this.Temperature

					if options.Has("Language")
						code := options["Language"]

					instruction := "Talk"

					if variables
						variables.language := (language ? language : "")
					else
						variables := {language: language ? language : ""}

					instruction := instructions[instructions.Has(code) ? code : "EN"]

					answer := this.Connector.Ask(question, [substituteVariables(getMultiMapValue(instruction
																							   , "Conversation.Instructions", "Character")
																			  , variables)
														  , substituteVariables(getMultiMapValue(instruction
																							   , "Conversation.Instructions", "Telemetry")
																			  , variables)])

					return (answer ? answer : false)
				}
				catch Any as exception {
					logError(exception)

					return false
				}
			}
			else
				return false
		}
		else
			return false
	}
}