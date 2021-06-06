;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Assistant               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\VoiceAssistant.ahk
#Include ..\Assistants\Libraries\SetupDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessionFinished = 0
global kSessionPaused = -1
global kSessionOther = 1
global kSessionPractice = 2
global kSessionQualification = 3
global kSessionRace = 4

global kDebugKnowledgeBase := 1

global kAsk = "Ask"
global kAlways = "Always"
global kNever = "Never"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceAssistant extends ConfigurationItem {
	iDebug := kDebugOff
	iOptions := {}

	iAssistantType := ""
	iSettings := false
	iVoiceAssistant := false
	
	iSimulator := ""
	iSession := kSessionFinished
	iDriverName := "John"
	
	iLearningLaps := 1
	
	iKnowledgeBase := false
	
	iSetupDatabase := false
	iSaveSettings := kNever
	
	class RaceVoiceAssistant extends VoiceAssistant {
		iRaceAssistant := false
		
		RaceAssistant[] {
			Get {
				return this.iRaceAssistant
			}
		}
		
		User[] {
			Get {
				return this.RaceAssistant.DriverName
			}
		}
		
		__New(raceAssistant, name, options) {
			this.iRaceAssistant := raceAssistant
			
			base.__New(name, options)
		}
		
		getPhraseVariables(variables := false) {
			variables := base.getPhraseVariables(variables)
			
			variables["Driver"] := variables["User"]
			
			return variables
		}
	
		getGrammars(language) {
			prefix := this.RaceAssistant.AssistantType . ".grammars."
			
			grammars := readConfiguration(getFileName(prefix . language, kUserGrammarsDirectory, kGrammarsDirectory))
			
			if (grammars.Count() == 0)
				grammars := readConfiguration(getFileName(prefix . "en", kUserGrammarsDirectory, kGrammarsDirectory))
			
			return grammars
		}
		
		handleVoiceCommand(phrase, words) {
			this.RaceAssistant.handleVoiceCommand(phrase, words)
		}
	}
	
	class RaceKnowledgeBase extends KnowledgeBase {
		iAssistant := false
		
		RaceAssistant[] {
			Get {
				return this.iRaceAssistant
			}
		}
		
		__New(raceAssistant, ruleEngine, facts, rules) {
			this.iRaceAssistant := raceAssistant
			
			base.__New(ruleEngine, facts, rules)
		}
	}
	
	Debug[option] {
		Get {
			return (this.iDebug & option)
		}
	}
	
	AssistantType[] {
		Get {
			return this.iAssistantType
		}
	}
	
	Settings[] {
		Get {
			return this.iSettings
		}
	}
	
	VoiceAssistant[] {
		Get {
			return this.iVoiceAssistant
		}
	}
	
	Speaker[] {
		Get {
			return this.VoiceAssistant.Speaker
		}
	}
	
	Listener[] {
		Get {
			return this.VoiceAssistant.Listener
		}
	}
	
	Continuation[] {
		Get {
			return this.VoiceAssistant.Continuation
		}
	}
	
	DriverName[] {
		Get {
			return this.iDriverName
		}
	}
	
	Simulator[] {
		Get {
			return this.iSimulator
		}
	}
	
	Session[] {
		Get {
			return this.iSession
		}
	}
	
	KnowledgeBase[] {
		Get {
			return this.iKnowledgeBase
		}
	}
	
	EnoughData[] {
		Get {
			Throw "Virtual property RaceAssistant.EnoughData must be implemented in a subclass..."
		}
	}
	
	LearningLaps[] {
		Get {
			return this.iLearningLaps
		}
	}
	
	SaveSettings[] {
		Get {
			return this.iSaveSettings
		}
	}
	
	SetupDatabase[] {
		Get {
			if !this.iSetupDatabase
				this.iSetupDatabase := new SetupDatabase()
			
			return this.iSetupDatabase
		}
	}
	
	__New(configuration, assistantType, settings, name := false, language := "__Undefined__", speaker := false, listener := false, voiceServer := false) {
		this.iDebug := (isDebug() ? kDebugKnowledgeBase : kDebugOff)
		this.iAssistantType := assistantType
		this.iSettings := settings
		
		base.__New(configuration)
		
		options := this.iOptions
		
		if (language != kUndefined) {
			listener := ((speaker != false) ? listener : false)
			
			options["Language"] := ((language != false) ? language : options["Language"])
			options["Speaker"] := ((speaker == true) ? options["Speaker"] : speaker)
			options["Listener"] := ((listener == true) ? options["Listener"] : listener)
			options["VoiceServer"] := voiceServer
		}
		
		this.iVoiceAssistant := new this.RaceVoiceAssistant(this, name, options)
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		options := this.iOptions
		
		options["Language"] := getConfigurationValue(configuration, "Voice Control", "Language", getLanguage())
		options["Speaker"] := getConfigurationValue(configuration, "Voice Control", "Speaker", true)
		options["SpeakerVolume"] := getConfigurationValue(configuration, "Voice Control", "SpeakerVolume", 100)
		options["SpeakerPitch"] := getConfigurationValue(configuration, "Voice Control", "SpeakerPitch", 0)
		options["SpeakerSpeed"] := getConfigurationValue(configuration, "Voice Control", "SpeakerSpeed", 0)
		options["Listener"] := getConfigurationValue(configuration, "Voice Control", "Listener", false)
		options["PushToTalk"] := getConfigurationValue(configuration, "Voice Control", "PushToTalk", false)
	}
	
	updateConfigurationValues(values) {
		if values.HasKey("Settings")
			this.iSettings := values["Settings"]
		
		if values.HasKey("LearningLaps")
			this.iLearningLaps := values["LearningLaps"]
	}
	
	updateSessionValues(values) {
		if values.HasKey("Simulator")
			this.iSimulator := values["Simulator"]
		
		if values.HasKey("Session")
			this.iSession := values["Session"]
		
		if values.HasKey("Driver")
			this.iDriverName := values["Driver"]
	}
	
	updateDynamicValues(values) {
		if values.HasKey("KnowledgeBase")
			this.iKnowledgeBase := values["KnowledgeBase"]
	}
	
	handleVoiceCommand(grammar, words) {
		switch grammar {
			case "Yes":
				continuation := this.Continuation
				
				this.clearContinuation()
				
				if continuation {
					this.getSpeaker().speakPhrase("Confirm")

					%continuation%()
				}
			case "No":
				continuation := this.Continuation
				
				this.clearContinuation()
				
				if continuation
					this.getSpeaker().speakPhrase("Okay")
			case "Call", "Harsh":
				this.nameRecognized(words)
			case "Catch":
				this.getSpeaker().speakPhrase("Repeat")
			default:
				Throw "Unknown grammar """ . grammar . """ detected in RaceAssistant.handleVoiceCommand...."
		}
	}
	
	nameRecognized(words) {
		this.getSpeaker().speakPhrase("IHearYou")
	}
	
	createKnowledgeBase(facts) {
		local rules
		
		FileRead rules, % getFileName(this.AssistantType . ".rules", kRulesDirectory, kUserRulesDirectory)
		
		productions := false
		reductions := false

		new RuleCompiler().compileRules(rules, productions, reductions)

		engine := new RuleEngine(productions, reductions, facts)
		
		return new this.RaceKnowledgeBase(this, engine, engine.createFacts(), engine.createRules())
	}
	
	setDebug(option, enabled) {
		if enabled
			this.iDebug := (this.iDebug | option)
		else if (this.Debug[option] == option)
			this.iDebug := (this.iDebug - option)
	}
	
	getSpeaker() {
		return this.VoiceAssistant.getSpeaker()
	}
	
	hasEnoughData(inform := true) {
		if this.EnoughData
			return true
		else {
			if (inform && this.Speaker)
				this.getSpeaker().speakPhrase("Later")
			
			return false
		}
	}
	
	dumpKnowledge(knowledgeBase) {
		prefix := this.AssistantType
		
		try {
			FileDelete %kTempDirectory%%prefix%.knowledge
		}
		catch exception {
			; ignore
		}

		for key, value in knowledgeBase.Facts.Facts {
			text := key . " = " . value . "`n"
		
			FileAppend %text%, %kTempDirectory%%prefix%.knowledge
		}
	}
}