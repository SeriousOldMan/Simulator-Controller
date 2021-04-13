;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Engineer                ;;;
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
#Include ..\Libraries\SpeechGenerator.ahk
#Include ..\Libraries\SpeechRecognizer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessionFinished = 0
global kSessionPaused = -1
global kSessionOther = 1
global kSessionPractice = 2
global kSessionQualification = 3
global kSessionRace = 4


global kDebugOff := 0
global kDebugGrammars := 1
global kDebugPhrases := 2
global kDebugRecognitions := 4
global kDebugKnowledgeBase := 8
global kDebugAll = (kDebugGrammars + kDebugPhrases + kDebugRecognitions + kDebugKnowledgeBase)


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceEngineer extends ConfigurationItem {
	iDebug := kDebugOff

	iPitstopHandler := false
	iRaceSettings := false
	
	iLanguage := "en"
	
	iName := false	
	iSpeaker := false
	iSpeakerVolume := 100
	iSpeakerPitch := 0
	iSpeakerSpeed := 0
	iListener := false
	
	iVoiceServer := false
	
	iPushTalk := false
	
	iSpeechGenerator := false
	iSpeechRecognizer := false
	iIsSpeaking := false
	iIsListening := false
	
	iContinuation := false
	
	iDriverName := "John"
	
	iSimulator := ""
	iSession := kSessionFinished
	
	iEnoughData := false
	
	iKnowledgeBase := false
	iOverallTime := 0
	iLastLap := 0
	iLastFuelAmount := 0
	iInitialFuelAmount := 0
	
	iSetupData := {}
	iSetupDataActive := false
	
	class RemoteEngineerListener {
		iListener := false
		iLanguage := false
		
		__New(listener, language) {			
			this.iListener := listener
			this.iLanguage := language
		}
	}
	
	class RemoteEngineerSpeaker {
		iEngineer := false
		iFragments := {}
		iPhrases := {}
		
		iSpeaker := false
		iLanguage := false
		
		Engineer[] {
			Get {
				return this.iEngineer
			}
		}
		
		Phrases[] {
			Get {
				return this.iPhrases
			}
		}
		
		Fragments[] {
			Get {
				return this.iFragments
			}
		}
		
		__New(engineer, speaker, language, fragments, phrases) {
			this.iEngineer := engineer
			this.iFragments := fragments
			this.iPhrases := phrases
			
			this.iSpeaker := speaker
			this.iLanguage := language
		}
		
		speak(text) {
			raiseEvent(kFileMessage, "Voice", "speakWith:" . values2String(";", this.iSpeaker, this.iLanguage, text), this.Engineer.VoiceServer)
		}
		
		speakPhrase(phrase, variables := false) {
			phrases := this.Phrases
			
			if phrases.HasKey(phrase) {
				phrases := phrases[phrase]
				
				Random index, 1, % phrases.Length()
				
				phrase := phrases[Round(index)]
				
				if variables {
					variables := variables.Clone()
					
					variables["name"] := this.Engineer.Name
					variables["driver"] := this.Engineer.DriverName
				}
				else
					variables := {name: this.Engineer.Name, driver: this.Engineer.DriverName}
				
				phrase := substituteVariables(phrase, variables)
			}
			
			if phrase
				this.speak(phrase)
		}
	}
	
	class LocalEngineerSpeaker extends SpeechGenerator {
		iEngineer := false
		iFragments := {}
		iPhrases := {}
		
		Engineer[] {
			Get {
				return this.iEngineer
			}
		}
		
		Phrases[] {
			Get {
				return this.iPhrases
			}
		}
		
		Fragments[] {
			Get {
				return this.iFragments
			}
		}
		
		__New(engineer, speaker, language, fragments, phrases) {
			this.iEngineer := engineer
			this.iFragments := fragments
			this.iPhrases := phrases
			
			base.__New(speaker, language)
		}
		
		speak(text) {
			stopped := this.Engineer.stopListening()
			
			try {
				this.iIsSpeaking := true
			
				try {
					base.speak(text, true)
				}
				finally {
					this.iIsSpeaking := false
				}
			}
			finally {
				if (stopped && !this.Engineer.PushTalk)
					this.Engineer.startListening()
			}
		}
		
		speakPhrase(phrase, variables := false) {
			phrases := this.Phrases
			
			if phrases.HasKey(phrase) {
				phrases := phrases[phrase]
				
				Random index, 1, % phrases.Length()
				
				phrase := phrases[Round(index)]
				
				if variables {
					variables := variables.Clone()
					
					variables["name"] := this.Engineer.Name
					variables["driver"] := this.Engineer.DriverName
				}
				else
					variables := {name: this.Engineer.Name, driver: this.Engineer.DriverName}
				
				phrase := substituteVariables(phrase, variables)
			}
			
			if phrase
				this.speak(phrase)
		}
	}
	
	class RaceKnowledgeBase extends KnowledgeBase {
		iEngineer := false
		
		RaceEngineer[] {
			Get {
				return this.iRaceEngineer
			}
		}
		
		__New(raceEngineer, ruleEngine, facts, rules) {
			this.iRaceEngineer := raceEngineer
			
			base.__New(ruleEngine, facts, rules)
		}
	}
	
	Debug[option] {
		Get {
			return (this.iDebug & option)
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
	
	RaceSettings[] {
		Get {
			return this.iRaceSettings
		}
	}
	
	PitstopHandler[] {
		Get {
			return this.iPitstopHandler
		}
	}
	
	VoiceServer[] {
		Get {
			return this.iVoiceServer
		}
	}
	
	Language[] {
		Get {
			return this.iLanguage
		}
	}
	
	Name[] {
		Get {
			return this.iName
		}
	}
	
	Speaker[] {
		Get {
			return this.iSpeaker
		}
	}
	
	Speaking[] {
		Get {
			return this.iIsSpeaking
		}
	}
	
	Listener[] {
		Get {
			return this.iListener
		}
	}
	
	Listening[] {
		Get {
			return this.iIsListening
		}
	}
	
	PushTalk[] {
		Get {
			return this.iPushTalk
		}
	}
	
	DriverName[] {
		Get {
			return this.iDriverName
		}
	}
	
	Continuation[] {
		Get {
			return this.iContinuation
		}
	}
	
	EnoughData[] {
		Get {
			return this.iEnoughData
		}
	}
	
	OverallTime[] {
		Get {
			return this.iOverallTime
		}
	}
	
	LastLap[] {
		Get {
			return this.iLastLap
		}
	}
	
	InitialFuelAmount[] {
		Get {
			return this.iInitialFuelAmount
		}
	}
	
	LastFuelAmount[] {
		Get {
			return this.iLastFuelAmount
		}
	}
	
	SetupData[] {
		Get {
			return this.iSetupData
		}
	}
	
	SetupDataActive[] {
		Get {
			return this.iSetupDataActive
		}
	}
	
	__New(configuration, raceSettings, pitstopHandler := false, name := false, language := "__Undefined__", speaker := false, listener := false, voiceServer := false) {
		this.iDebug := ((true || isDebug()) ? kDebugKnowledgeBase : kDebugOff)
		this.iRaceSettings := raceSettings
		this.iPitstopHandler := pitstopHandler
		this.iName := name
		
		base.__New(configuration)
		
		if (language != kUndefined) {
			listener := ((speaker != false) ? listener : false)
			
			if (language != false)
				this.iLanguage := language
			
			this.iSpeaker := speaker
			this.iListener := listener
			
			if (voiceServer && (this.Language != getConfigurationValue(configuration, "Voice Control", "Language", getLanguage())))
				voiceServer := false
			
			this.iVoiceServer := voiceServer
		}

		registerEventHandler("Voice", ObjBindMethod(this, "handleVoiceCalls"))
		
		if (!this.VoiceServer && this.PushTalk) {
			pushToTalk := ObjBindMethod(this, "pushToTalk")
			
			SetTimer %pushToTalk%, 100
		}
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		this.iLanguage := getConfigurationValue(configuration, "Voice Control", "Language", getLanguage())
		this.iSpeaker := getConfigurationValue(configuration, "Voice Control", "Speaker", true)
		this.iSpeakerVolume := getConfigurationValue(configuration, "Voice Control", "SpeakerVolume", 100)
		this.iSpeakerPitch := getConfigurationValue(configuration, "Voice Control", "SpeakerPitch", 0)
		this.iSpeakerSpeed := getConfigurationValue(configuration, "Voice Control", "SpeakerSpeed", 0)
		this.iListener := getConfigurationValue(configuration, "Voice Control", "Listener", false)
		this.iPushTalk := getConfigurationValue(configuration, "Voice Control", "PushToTalk", false)
	}
	
	pushToTalk() {
		theHotkey := this.PushTalk
		
		if !this.Speaking && GetKeyState(theHotKey, "P")
			this.startListening()
		else if !GetKeyState(theHotKey, "P")
			this.stopListening()
	}
	
	setDebug(option, enabled) {
		if (option == kDebugAll)
			this.iDebug := (enabled ? option : kDebugOff)
		else if enabled
			this.iDebug := (this.iDebug | option)
		else if (this.Debug[option] == option)
			this.iDebug := (this.iDebug - option)
	}
	
	getSpeaker() {
		if (this.Speaker && !this.iSpeechGenerator) {
			if this.VoiceServer
				this.iSpeechGenerator := new this.RemoteEngineerSpeaker(this, this.Speaker, this.Language
																	  , this.buildFragments(this.Language), this.buildPhrases(this.Language))
			else {
				this.iSpeechGenerator := new this.LocalEngineerSpeaker(this, this.Speaker, this.Language
																	 , this.buildFragments(this.Language), this.buildPhrases(this.Language))
			
				this.iSpeechGenerator.setVolume(this.iSpeakerVolume)
				this.iSpeechGenerator.setPitch(this.iSpeakerPitch)
				this.iSpeechGenerator.setRate(this.iSpeakerSpeed)
			}
				
			this.startListener()
		}
		
		return this.iSpeechGenerator
	}
	
	startListener() {
		static initialized := false
		
		if (!initialized && this.Listener && !this.iSpeechRecognizer) {
			initialized := true
			
			if this.VoiceServer
				this.buildGrammars(false, this.Language)
			else {
				recognizer := new SpeechRecognizer(this.Listener, this.Language)
				
				this.buildGrammars(recognizer, this.Language)
				
				if !this.PushTalk
					recognizer.startRecognizer()
				
				this.iSpeechRecognizer := recognizer
			}
		}
	}
	
	startListening(retry := true) {
		local function
		
		if this.iSpeechRecognizer && !this.Listening
			if !this.iSpeechRecognizer.startRecognizer() {
				if retry {
					callback := ObjBindMethod(this, "startListening", true)
					
					SetTimer %callback%, -200
				}
				
				return false
			}
			else {
				this.iIsListening := true
			
				return true
			}
	}
	
	stopListening(retry := false) {
		local function
		
		if this.iSpeechRecognizer && this.Listening
			if !this.iSpeechRecognizer.stopRecognizer() {
				if retry {
					callback := ObjBindMethod(this, "stopListening", true)
					
					SetTimer %callback%, -200
				}
				
				return false
			}
			else {
				this.iIsListening := false
			
				return true
			}
	}
	
	buildFragments(language) {
		fragments := {}
		
		settings := readConfiguration(getFileName("Race Engineer.grammars." . language, kUserConfigDirectory, kConfigDirectory))
		
		if (settings.Count() == 0)
			settings := readConfiguration(getFileName("Race Engineer.grammars.en", kUserConfigDirectory, kConfigDirectory))
		
		for fragment, word in getConfigurationSectionValues(settings, "Fragments", {})
			fragments[fragment] := word
		
		return fragments
	}
	
	buildPhrases(language) {
		phrases := {}
		
		settings := readConfiguration(getFileName("Race Engineer.grammars." . language, kUserConfigDirectory, kConfigDirectory))
		
		if (settings.Count() == 0)
			settings := readConfiguration(getFileName("Race Engineer.grammars.en", kUserConfigDirectory, kConfigDirectory))
		
		for key, value in getConfigurationSectionValues(settings, "Speaker Phrases", {}) {
			key := ConfigurationItem.splitDescriptor(key)[1]
		
			if phrases.HasKey(key)
				phrases[key].Push(value)
			else
				phrases[key] := Array(value)
		}
		
		return phrases
	}
	
	buildGrammars(speechRecognizer, language) {
		settings := readConfiguration(getFileName("Race Engineer.grammars." . language, kUserConfigDirectory, kConfigDirectory))
		
		if (settings.Count() == 0)
			settings := readConfiguration(getFileName("Race Engineer.grammars.en", kUserConfigDirectory, kConfigDirectory))
		
		for name, choices in getConfigurationSectionValues(settings, "Choices", {})
			if speechRecognizer
				speechRecognizer.setChoices(name, choices)
			else
				raiseEvent(kFileMessage, "Voice", "registerChoices:" . values2String(";", name, string2Values(",", choices)*), this.VoiceServer)
		
		Process Exist
		
		processID := ErrorLevel
		
		for grammar, definition in getConfigurationSectionValues(settings, "Listener Grammars", {}) {
			definition := substituteVariables(definition, {name: this.Name})
		
			if this.Debug[kDebugGrammars] {
				nextCharIndex := 1
				
				showMessage("Register phrase grammar: " . new GrammarCompiler(speechRecognizer).readGrammar(definition, nextCharIndex).toString())
			}
			
			if speechRecognizer
				speechRecognizer.loadGrammar(grammar, speechRecognizer.compileGrammar(definition), ObjBindMethod(this, "raisePhraseRecognized"))
			else
				raiseEvent(kFileMessage, "Voice", "registerVoiceCommand:" . values2String(";", grammar, definition, processID, "remotePhraseRecognized"), this.VoiceServer)
		}
	}

	handleVoiceCalls(event, data) {
		if InStr(data, ":") {
			data := StrSplit(data, ":", , 2)

			return withProtection(ObjBindMethod(this, data[1]), string2Values(";", data[2])*)
		}
		else
			return withProtection(ObjBindMethod(this, data))
	}
	
	raisePhraseRecognized(grammar, words) {
		raiseEvent(kLocalMessage, "Voice", "localPhraseRecognized:" . values2String(";", grammar, words*))
	}
	
	localPhraseRecognized(grammar, words*) {
		this.phraseRecognized(grammar, words)
	}
	
	remotePhraseRecognized(grammar, command, words*) {
		this.phraseRecognized(grammar, words)
	}
	
	phraseRecognized(grammar, words) {
		if this.Debug[kDebugRecognitions]
			showMessage("Phrase " . grammar . " recognized: " . values2String(" ", words*))
		
		protectionOn()
		
		try {
			switch grammar {
				case "Yes":
					continuation := this.iContinuation
					
					this.iContinuation := false
					
					if continuation {
						this.getSpeaker().speakPhrase("Confirm")

						%continuation%()
					}
				case "No":
					continuation := this.iContinuation
					
					this.iContinuation := false
					
					if continuation
						this.getSpeaker().speakPhrase("Okay")
				case "Call", "Harsh":
					this.nameRecognized(words)
				case "Catch":
					this.getSpeaker().speakPhrase("Repeat")
				case "LapsRemaining":
					this.lapInfoRecognized(words)
				case "TyreTemperatures":
					this.tyreInfoRecognized(words)
				case "TyrePressures":
					this.tyreInfoRecognized(words)
				case "Weather":
					this.weatherRecognized(words)
				case "PitstopPlan":
					this.iContinuation := false
					
					if !this.supportsPitstop()
						this.getSpeaker().speakPhrase("NoPitstop")
					else {
						this.getSpeaker().speakPhrase("Confirm")
						
						this.planPitstopRecognized(words)
					}
				case "PitstopPrepare":
					this.iContinuation := false
					
					
					if !this.supportsPitstop()
						this.getSpeaker().speakPhrase("NoPitstop")
					else {
						this.getSpeaker().speakPhrase("Confirm")
						
						this.preparePitstopRecognized(words)
					}
				case "PitstopAdjustFuel":
					this.iContinuation := false
					
					if !this.supportsPitstop()
						this.getSpeaker().speakPhrase("NoPitstop")
					else
						this.pitstopAdjustFuelRecognized(words)
				case "PitstopAdjustCompound":
					this.iContinuation := false
					
					if !this.supportsPitstop()
						this.getSpeaker().speakPhrase("NoPitstop")
					else
						this.pitstopAdjustCompoundRecognized(words)
				case "PitstopAdjustPressureUp", "PitstopAdjustPressureDown":
					this.iContinuation := false
					
					if !this.supportsPitstop()
						this.getSpeaker().speakPhrase("NoPitstop")
					else
						this.pitstopAdjustPressureRecognized(words)
				case "PitstopNoPressureChange":
					this.iContinuation := false
					
					this.pitstopAdjustNoPressureRecognized(words)
				case "PitstopAdjustRepairSuspension":
					this.iContinuation := false
					
					if !this.supportsPitstop()
						this.getSpeaker().speakPhrase("NoPitstop")
					else
						this.pitstopAdjustRepairRecognized("Suspension", words)
				case "PitstopAdjustRepairBodywork":
					this.iContinuation := false
					
					if !this.supportsPitstop()
						this.getSpeaker().speakPhrase("NoPitstop")
					else
						this.pitstopAdjustRepairRecognized("Bodywork", words)
				default:
					Throw "Unknown grammar """ . grammar . """ detected in RaceEngineer.phraseRecognized...."
			}
		}
		finally {
			protectionOff()
		}
	}
	
	nameRecognized(words) {
		this.getSpeaker().speakPhrase("IHearYou")
	}
	
	lapInfoRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		if !this.hasEnoughData()
			return
		
		laps := Round(knowledgeBase.getValue("Lap.Remaining"))
		
		if (laps == 0)
			this.getSpeaker().speakPhrase("Later")
		else
			this.getSpeaker().speakPhrase("Laps", {laps: laps})
	}
	
	tyreInfoRecognized(words) {
		local value
		local knowledgeBase := this.KnowledgeBase
		
		if !this.hasEnoughData()
			return
		
		speaker := this.getSpeaker()
		fragments := speaker.Fragments
		
		if inList(words, fragments["temperatures"])
			value := "Temperature"
		else if inList(words, fragments["pressures"])
			value := "Pressure"
		else {
			speaker.speakPhrase("Repeat")
		
			return
		}
		
		lap := knowledgeBase.getValue("Lap")
		
		speaker.speakPhrase((value == "Pressure") ? "Pressures" : "Temperatures")
		
		speaker.speakPhrase("TyreFL", {value: Format("{:.1f}", Round(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".FL"), 1))
									 , unit: (value == "Pressure") ? fragments["PSI"] : fragments["Degrees"]})
		
		speaker.speakPhrase("TyreFR", {value: Format("{:.1f}", Round(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".FR"), 1))
									 , unit: (value == "Pressure") ? fragments["PSI"] : fragments["Degrees"]})
		
		speaker.speakPhrase("TyreRL", {value: Format("{:.1f}", Round(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".RL"), 1))
									 , unit: (value == "Pressure") ? fragments["PSI"] : fragments["Degrees"]})
		
		speaker.speakPhrase("TyreRR", {value: Format("{:.1f}", Round(knowledgeBase.getValue("Lap." . lap . ".Tyre." . value . ".RR"), 1))
									 , unit: (value == "Pressure") ? fragments["PSI"] : fragments["Degrees"]})
	}
	
	weatherRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		
		weather10Min := knowledgeBase.getValue("Weather.Weather.10Min", false)
		
		if !weather10Min
			this.getSpeaker().speakPhrase("Later")
		else if (weather10Min = "Dry")
			this.getSpeaker().speakPhrase("WeatherGood")
		else
			this.getSpeaker().speakPhrase("WeatherRain")
	}
	
	planPitstopRecognized(words) {
		this.planPitstop()
	}
	
	preparePitstopRecognized(words) {
		this.preparePitstop()
	}
	
	pitstopAdjustFuelRecognized(words) {
		local action
		
		speaker := this.getSpeaker()
		fragments := speaker.Fragments
		
		if !this.hasPlannedPitstop() {
			speaker.speakPhrase("NotPossible")
			
			speaker.speakPhrase("ConfirmPlan")
			
			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			litresPosition := inList(words, fragments["Litres"])
				
			if litresPosition {
				litres := words[litresPosition - 1]
				
				if litres is number
				{
					speaker.speakPhrase("ConfirmFuelChange", {litres: litres})
					
					this.setContinuation(ObjBindMethod(this, "updatePitstopFuel", litres))
					
					return
				}
			}
			
			speaker.speakPhrase("Repeat")
		}
	}
	
	pitstopAdjustCompoundRecognized(words) {
		local action
		local compound
		
		speaker := this.getSpeaker()
		fragments := speaker.Fragments
		
		if !this.hasPlannedPitstop() {
			speaker.speakPhrase("NotPossible")
			speaker.speakPhrase("ConfirmPlan")
			
			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			compound := false
		
			if inList(words, fragments["Wet"])
				compound := "Wet"
			else if inList(words, fragments["Dry"])
				compound := "Dry"
			
			if compound {
				speaker.speakPhrase("ConfirmCompoundChange", {compound: fragments[compound]})
					
				this.setContinuation(ObjBindMethod(this, "updatePitstopTyreCompound", compound))
			}
			else
				speaker.speakPhrase("Repeat")
		}
	}
				
	pitstopAdjustPressureRecognized(words) {
		local action
		
		static tyreTypeFragments := false
		static numberFragmentsLookup := false
		
		speaker := this.getSpeaker()
		fragments := speaker.Fragments
		
		if !tyreTypeFragments {
			tyreTypeFragments := {FL: fragments["FrontLeft"], FR: fragments["FrontRight"], RL: fragments["RearLeft"], RR: fragments["RearRight"]}
			numberFragmentsLookup := {}
			
			for index, fragment in ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"]
				numberFragmentsLookup[fragments[fragment]] := index - 1
		}
		
		if !this.hasPlannedPitstop() {
			speaker.speakPhrase("NotPossible")
			speaker.speakPhrase("ConfirmPlan")
			
			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			tyreType := false
			
			if inList(words, fragments["Front"]) {
				if inList(words, fragments["Left"])
					tyreType := "FL"
				else if inList(words, fragments["Right"])
					tyreType := "FR"
			}
			else if inList(words, fragments["Rear"]) {
				if inList(words, fragments["Left"])
					tyreType := "RL"
				else if inList(words, fragments["Right"])
					tyreType := "RR"
			}
			
			if tyreType {
				action := false
				
				if inList(words, fragments["Increase"])
					action := kIncrease
				else if inList(words, fragments["Decrease"])
					action := kDecrease
				
				pointPosition := inList(words, fragments["Point"])
				
				if pointPosition {
					psiValue := words[pointPosition - 1]
					tenthPsiValue := words[pointPosition + 1]
					
					if psiValue is not number
					{
						psiValue := numberFragmentsLookup[psiValue]
						tenthPsiValue := numberFragmentsLookup[tenthPsiValue]
					}
					
					tyre := tyreTypeFragments[tyreType]
					action := fragments[action]
					
					delta := Round(psiValue + (tenthPsiValue / 10), 1)
					
					speaker.speakPhrase("ConfirmPsiChange", {action: action, tyre: tyre, unit: fragments["PSI"], delta: Format("{:.1f}", delta)})
					
					this.setContinuation(ObjBindMethod(this, "updatePitstopTyrePressure", tyreType, (action == kIncrease) ? delta : (delta * -1)))
					
					return
				}
			}
			
			speaker.speakPhrase("Repeat")
		}
	}
	
	pitstopAdjustNoPressureRecognized(words) {
		local action
		
		speaker := this.getSpeaker()
		fragments := speaker.Fragments
		
		if !this.hasPlannedPitstop() {
			speaker.speakPhrase("NotPossible")
			speaker.speakPhrase("ConfirmPlan")
			
			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			speaker.speakPhrase("ConfirmNoPressureChange")
					
			this.setContinuation(ObjBindMethod(this, "updatePitstopPressures"))
		}
	}
	
	pitstopAdjustRepairRecognized(repairType, words) {
		local action
		
		speaker := this.getSpeaker()
		fragments := speaker.Fragments
		
		if !this.hasPlannedPitstop() {
			speaker.speakPhrase("NotPossible")
			speaker.speakPhrase("ConfirmPlan")
			
			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			negation := ""
		
			if inList(words, fragments["Not"])
				negation := fragments["Not"]
			
			speaker.speakPhrase("ConfirmRepairChange", {damage: fragments[repairType], negation: negation})
					
			this.setContinuation(ObjBindMethod(this, "updatePitstopRepair", repairType, negation = ""))
		}
	}
	
	updatePitstopFuel(litres) {
		speaker := this.getSpeaker()
		
		if !this.hasPlannedPitstop() {
			speaker.speakPhrase("NotPossible")
			speaker.speakPhrase("ConfirmPlan")
			
			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			this.KnowledgeBase.setValue("Pitstop.Planned.Fuel", litres)
			
			if this.Debug[kDebugKnowledgeBase]
				dumpKnowledge(this.KnowledgeBase)

			speaker.speakPhrase("ConfirmPlanUpdate")
			speaker.speakPhrase("MoreChanges")
		}
	}
	
	updatePitstopTyreCompound(compound) {
		local knowledgeBase
		
		speaker := this.getSpeaker()
		
		if !this.hasPlannedPitstop() {
			speaker.speakPhrase("NotPossible")
			speaker.speakPhrase("ConfirmPlan")
			
			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			if (this.KnowledgeBase.getValue("Pitstop.Planned.Tyre.Compound") != compound) {
				speaker.speakPhrase("ConfirmPlanUpdate")
		
				knowledgeBase := this.KnowledgeBase
				
				knowledgeBase.setValue("Tyre.Compound.Target", compound)
				knowledgeBase.setValue("Tyre.Compound.Color.Target", "Black")
				
				knowledgeBase.clearFact("Pitstop.Planned.Tyre.Compound")
				knowledgeBase.clearFact("Pitstop.Planned.Tyre.Compound.Color")
				
				for ignore, tyreType in ["FL", "FR", "RL", "RR"] {
					knowledgeBase.clearFact("Pitstop.Planned.Tyre.Pressure." . tyreType)
					knowledgeBase.clearFact("Pitstop.Planned.Tyre.Pressure." . tyreType . ".Increment")
				}
				
				knowledgeBase.clearFact("Pitstop.Planned.Tyre.Pressure.Correction")
				
				this.planPitstop({Update: true, Pressures: true}, false)
				
				speaker.speakPhrase("MoreChanges")
			}
			else {
				speaker.speakPhrase("ConfirmPlanUpdate")
				speaker.speakPhrase("MoreChanges")
			}
		}
	}
	
	updatePitstopTyrePressure(tyreType, delta) {
		local knowledgeBase := this.KnowledgeBase
		
		speaker := this.getSpeaker()
		
		if !this.hasPlannedPitstop() {
			speaker.speakPhrase("NotPossible")
			speaker.speakPhrase("ConfirmPlan")
			
			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			targetValue := knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure." . tyreType)
			targetIncrement := knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure." . tyreType . ".Increment")
			
			knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure." . tyreType, targetValue + delta)
			knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure." . tyreType . ".Increment", targetIncrement + delta)
			
			if this.Debug[kDebugKnowledgeBase]
				dumpKnowledge(this.KnowledgeBase)

			speaker.speakPhrase("ConfirmPlanUpdate")
			speaker.speakPhrase("MoreChanges")
		}
	}
	
	updatePitstopPressures() {
		local knowledgeBase
		
		speaker := this.getSpeaker()
		
		if !this.hasPlannedPitstop() {
			speaker.speakPhrase("NotPossible")
			speaker.speakPhrase("ConfirmPlan")
			
			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			knowledgeBase := this.KnowledgeBase
		
			if (knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound", "Dry") = "Dry") {
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FL", knowledgeBase.getValue("Session.Setup.Tyre.Dry.Pressure.FL", 26.1))
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FR", knowledgeBase.getValue("Session.Setup.Tyre.Dry.Pressure.FR", 26.1))
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RL", knowledgeBase.getValue("Session.Setup.Tyre.Dry.Pressure.RL", 26.1))
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RR", knowledgeBase.getValue("Session.Setup.Tyre.Dry.Pressure.RR", 26.1))
			}
			else {
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FL", knowledgeBase.getValue("Session.Setup.Tyre.Wet.Pressure.FL", 26.1))
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FR", knowledgeBase.getValue("Session.Setup.Tyre.Wet.Pressure.FR", 26.1))
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RL", knowledgeBase.getValue("Session.Setup.Tyre.Wet.Pressure.RL", 26.1))
				knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RR", knowledgeBase.getValue("Session.Setup.Tyre.Wet.Pressure.RR", 26.1))
			}
			
			knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FL.Increment", 0)
			knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.FR.Increment", 0)
			knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RL.Increment", 0)
			knowledgeBase.setValue("Pitstop.Planned.Tyre.Pressure.RR.Increment", 0)
			
			if this.Debug[kDebugKnowledgeBase]
				dumpKnowledge(knowledgeBase)

			speaker.speakPhrase("ConfirmPlanUpdate")
			speaker.speakPhrase("MoreChanges")
		}
	}
	
	updatePitstopRepair(repairType, repair) {
		speaker := this.getSpeaker()
		
		if !this.hasPlannedPitstop() {
			speaker.speakPhrase("NotPossible")
			speaker.speakPhrase("ConfirmPlan")
			
			this.setContinuation(ObjBindMethod(this, "planPitstop"))
		}
		else {
			this.KnowledgeBase.setValue("Pitstop.Planned.Repair." . repairType, repair)
			
			if this.Debug[kDebugKnowledgeBase]
				dumpKnowledge(this.KnowledgeBase)

			speaker.speakPhrase("ConfirmPlanUpdate")
			speaker.speakPhrase("MoreChanges")
		}
	}
			
	setContinuation(continuation) {
		this.iContinuation := continuation
	}
	
	createSession(data) {
		local facts
		
		settings := this.RaceSettings
		
		this.iDriverName := getConfigurationValue(data, "Stint Data", "DriverForname", this.DriverName)
		this.iSimulator := getConfigurationValue(data, "Session Data", "Simulator", "")
		
		switch getConfigurationValue(data, "Stint Data", "Session", "Practice") {
			case "Practice":
				this.iSession := kSessionPractice
			case "Qualification":
				this.iSession := kSessionQualification
			case "Race":
				this.iSession := kSessionRace
			case "Other":
				this.iSession := kSessionOther
		}
		
		dataDuration := Round((getConfigurationValue(data, "Stint Data", "RaceTimeRemaining", 0) + getConfigurationValue(data, "Stint Data", "LapLastTime", 0)) / 1000)
		settingsDuration := getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Duration", dataDuration)
		
		if ((Abs(settingsDuration - dataDuration) / dataDuration) >  0.1)
			settingsDuration := dataDuration
		
		facts := {"Session.Car": getConfigurationValue(data, "Session Data", "Car", "")
				, "Session.Track": getConfigurationValue(data, "Session Data", "Track", "")
				, "Session.Duration": settingsDuration
				, "Session.Settings.Lap.Formation": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.Formation", true)
				, "Session.Settings.Lap.PostRace": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.PostRace", true)
				, "Session.Settings.Fuel.Max": getConfigurationValue(data, "Session Data", "FuelAmount", 0)
				, "Session.Settings.Fuel.AvgConsumption": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Fuel.AvgConsumption", 0)
				, "Session.Settings.Pitstop.Delta": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Pitstop.Delta", 30)
				, "Session.Settings.Fuel.SafetyMargin": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Fuel.SafetyMargin", 5)
				, "Session.Settings.Lap.PitstopWarning": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.PitstopWarning", 5)
				, "Session.Settings.Lap.AvgTime": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.AvgTime", 0)
				, "Session.Settings.Lap.History.Considered": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.History.Considered", 5)
				, "Session.Settings.Lap.History.Damping": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.History.Damping", 0.2)
				, "Session.Settings.Damage.Suspension.Repair": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Damage.Suspension.Repair", "Always")
				, "Session.Settings.Damage.Suspension.Repair.Threshold": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Damage.Suspension.Repair.Threshold", 0)
				, "Session.Settings.Damage.Bodywork.Repair": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Damage.Bodywork.Repair", "Threshold")
				, "Session.Settings.Damage.Bodywork.Repair.Threshold": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Damage.Bodywork.Repair.Threshold", 20)
				, "Session.Settings.Tyre.Compound.Change": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Compound.Change", "Never")
				, "Session.Settings.Tyre.Compound.Change.Threshold": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Compound.Change.Threshold", 0)
				, "Session.Settings.Tyre.Dry.Pressure.Target.FL": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.FL", 27.7)
				, "Session.Settings.Tyre.Dry.Pressure.Target.FR": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.FR", 27.7)
				, "Session.Settings.Tyre.Dry.Pressure.Target.RL": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.RL", 27.7)
				, "Session.Settings.Tyre.Dry.Pressure.Target.RR": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.RR", 27.7)
				, "Session.Settings.Tyre.Wet.Pressure.Target.FL": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.FL", 30.0)
				, "Session.Settings.Tyre.Wet.Pressure.Target.FR": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.FR", 30.0)
				, "Session.Settings.Tyre.Wet.Pressure.Target.RL": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.RL", 30.0)
				, "Session.Settings.Tyre.Wet.Pressure.Target.RR": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.RR", 30.0)
				, "Session.Settings.Tyre.Pressure.Deviation": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Pressure.Deviation", 0.2)
				, "Session.Setup.Tyre.Set.Fresh": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Set.Fresh", 8)
				, "Session.Setup.Tyre.Set": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Set", 7)}
		
		
		facts["Session.Setup.Tyre.Dry.Pressure.FL"] := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.FL", 26.1)
		facts["Session.Setup.Tyre.Dry.Pressure.FR"] := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.FR", 26.1)
		facts["Session.Setup.Tyre.Dry.Pressure.RL"] := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.RL", 26.1)
		facts["Session.Setup.Tyre.Dry.Pressure.RR"] := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.RR", 26.1)
		facts["Session.Setup.Tyre.Wet.Pressure.FL"] := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.FL", 28.2)
		facts["Session.Setup.Tyre.Wet.Pressure.FR"] := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.FR", 28.2)
		facts["Session.Setup.Tyre.Wet.Pressure.RL"] := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.RL", 28.2)
		facts["Session.Setup.Tyre.Wet.Pressure.RR"] := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.RR", 28.2)

		facts["Session.Simulator"] := getConfigurationValue(data, "Session Data", "Simulator", "Unknown")
		facts["Session.Setup.Tyre.Compound"] := getConfigurationValue(data, "Car Data", "TyreCompound", getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound", "Dry"))
		facts["Session.Setup.Tyre.Compound.Color"] := getConfigurationValue(data, "Car Data", "TyreCompoundColor", getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound.Color", "Black"))
				
		return facts
	}
	
	updateSession(settings) {
		local knowledgeBase := this.KnowledgeBase
		local facts
		
		if knowledgeBase {
			if !IsObject(settings)
				settings := readConfiguration(settings)
			
			this.iRaceSettings := settings
			
			facts := {"Session.Settings.Lap.Formation": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.Formation", true)
					, "Session.Settings.Lap.PostRace": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.PostRace", true)
					, "Session.Settings.Fuel.AvgConsumption": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Fuel.AvgConsumption", 0)
					, "Session.Settings.Pitstop.Delta": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Pitstop.Delta", 30)
					, "Session.Settings.Fuel.SafetyMargin": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Fuel.SafetyMargin", 5)
					, "Session.Settings.Lap.PitstopWarning": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.PitstopWarning", 5)
					, "Session.Settings.Lap.AvgTime": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.AvgTime", 0)
					, "Session.Settings.Lap.History.Considered": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.History.Considered", 5)
					, "Session.Settings.Lap.History.Damping": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.History.Damping", 0.2)
					, "Session.Settings.Damage.Suspension.Repair": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Damage.Suspension.Repair", "Always")
					, "Session.Settings.Damage.Suspension.Repair.Threshold": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Damage.Suspension.Repair.Threshold", 0)
					, "Session.Settings.Damage.Bodywork.Repair": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Damage.Bodywork.Repair", "Threshold")
					, "Session.Settings.Damage.Bodywork.Repair.Threshold": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Damage.Bodywork.Repair.Threshold", 20)
					, "Session.Settings.Tyre.Compound.Change": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Compound.Change", "Never")
					, "Session.Settings.Tyre.Compound.Change.Threshold": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Compound.Change.Threshold", 0)
					, "Session.Settings.Tyre.Dry.Pressure.Target.FL": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.FL", 27.7)
					, "Session.Settings.Tyre.Dry.Pressure.Target.FR": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.FR", 27.7)
					, "Session.Settings.Tyre.Dry.Pressure.Target.RL": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.RL", 27.7)
					, "Session.Settings.Tyre.Dry.Pressure.Target.RR": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Dry.Pressure.Target.RR", 27.7)
					, "Session.Settings.Tyre.Wet.Pressure.Target.FL": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.FL", 30.0)
					, "Session.Settings.Tyre.Wet.Pressure.Target.FR": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.FR", 30.0)
					, "Session.Settings.Tyre.Wet.Pressure.Target.RL": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.RL", 30.0)
					, "Session.Settings.Tyre.Wet.Pressure.Target.RR": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Wet.Pressure.Target.RR", 30.0)
					, "Session.Settings.Tyre.Pressure.Deviation": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Tyre.Pressure.Deviation", 0.2)
					, "Session.Setup.Tyre.Set.Fresh": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Set.Fresh", 8)
					, "Session.Setup.Tyre.Set": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Set", 7)
					, "Session.Setup.Tyre.Dry.Pressure.FL": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.FL", 26.1)
					, "Session.Setup.Tyre.Dry.Pressure.FR": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.FR", 26.1)
					, "Session.Setup.Tyre.Dry.Pressure.RL": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.RL", 26.1)
					, "Session.Setup.Tyre.Dry.Pressure.RR": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Dry.Pressure.RR", 26.1)
					, "Session.Setup.Tyre.Wet.Pressure.FL": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.FL", 28.2)
					, "Session.Setup.Tyre.Wet.Pressure.FR": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.FR", 28.2)
					, "Session.Setup.Tyre.Wet.Pressure.RL": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.RL", 28.2)
					, "Session.Setup.Tyre.Wet.Pressure.RR": getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Wet.Pressure.RR", 28.2)}
					
			facts["Session.Setup.Tyre.Compound"] := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound", "Dry")
			facts["Session.Setup.Tyre.Compound.Color"] := getDeprecatedConfigurationValue(settings, "Session Setup", "Race Setup", "Tyre.Compound.Color", "Black")
					
			for key, value in facts
				knowledgeBase.setValue(key, value)
			
			if this.Debug[kDebugKnowledgeBase]
				dumpKnowledge(knowledgeBase)
		}
	}
	
	startSession(data) {
		local facts
		
		if !IsObject(data)
			data := readConfiguration(data)
		
		facts := this.createSession(data)
		
		FileRead engineerRules, % getFileName("Race Engineer.rules", kConfigDirectory, kUserConfigDirectory)
		
		productions := false
		reductions := false

		new RuleCompiler().compileRules(engineerRules, productions, reductions)

		engine := new RuleEngine(productions, reductions, facts)
		
		this.iKnowledgeBase := new this.RaceKnowledgeBase(this, engine, engine.createFacts(), engine.createRules())
		this.iLastLap := 0
		this.iOverallTime := 0
		this.iLastFuelAmount := 0
		this.iInitialFuelAmount := 0
		this.iEnoughData := false
		this.iSetupData := {}
		
		if this.Speaker
			this.getSpeaker().speakPhrase("Greeting")
		
		if this.Debug[kDebugKnowledgeBase]
			dumpKnowledge(this.KnowledgeBase)
	}
	
	finishSession() {
		this.iLastLap := 0
		this.iOverallTime := 0
		this.iLastFuelAmount := 0
		this.iInitialFuelAmount := 0
		this.iEnoughData := false
			
		if this.KnowledgeBase
			if this.Speaker {
				this.getSpeaker().speakPhrase("Bye")
				
				if (this.SetupData.Count() > 0) {
					if (this.Listener && ((this.Session == kSessionPractice) || (this.Session == kSessionRace))) {
						this.getSpeaker().speakPhrase("ConfirmUpdateSetupDatabase")
						
						this.setContinuation(ObjBindMethod(this, "updateSetupDatabase", true))
						
						callback := ObjBindMethod(this, "forceFinishSession")
						
						SetTimer %callback%, -60000
					}
					else {
						if ((this.Session == kSessionPractice) || (this.Session == kSessionRace))
							this.updateSetupDatabase()
					
						this.iKnowledgeBase := false
					}
				}
				else
					this.iKnowledgeBase := false
			}
			else {
				if (((this.Session == kSessionPractice) || (this.Session == kSessionRace)) && (this.SetupData.Count() > 0))
					this.updateSetupDatabase()
			
				this.iKnowledgeBase := false
			}
			
		this.iSimulator := ""
		this.iSession := kSessionFinished
	}
	
	forceFinishSession() {
		if !this.SetupDataActive {
			this.iKnowledgeBase := false
			this.iSetupData := {}
			this.iSimulator := ""
			this.iSession := kSessionFinished
		}	
	}
	
	addLap(lapNumber, data) {
		local knowledgeBase
		
		static baseLap := false
		
		if !IsObject(data)
			data := readConfiguration(data)
		
		if !this.KnowledgeBase
			this.startSession(data)
		
		knowledgeBase := this.KnowledgeBase
		
		if (lapNumber == 1)
			knowledgeBase.addFact("Lap", 1)
		else
			knowledgeBase.setValue("Lap", lapNumber)
			
		if !this.iInitialFuelAmount
			baseLap := lapNumber
		
		if (lapNumber > baseLap)
			this.iEnoughData := true
		
		driverForname := getConfigurationValue(data, "Stint Data", "DriverForname", this.DriverName)
		driverSurname := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
		driverNickname := getConfigurationValue(data, "Stint Data", "DriverNickname", "JD")
		
		this.iDriverName := driverForname
			
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Forname", driverForname)
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Surname", driverSurname)
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Nickname", driverNickname)
		
		knowledgeBase.setFact("Driver.Forname", driverForname)
		knowledgeBase.setFact("Driver.Surname", driverSurname)
		knowledgeBase.setFact("Driver.Nickname", driverNickname)
		
		timeRemaining := getConfigurationValue(data, "Stint Data", "RaceTimeRemaining", 0)
		
		knowledgeBase.setFact("Driver.Time.Remaining", getConfigurationValue(data, "Stint Data", "DriverTimeRemaining", timeRemaining))
		knowledgeBase.setFact("Driver.Time.Stint.Remaining", getConfigurationValue(data, "Stint Data", "StintTimeRemaining", timeRemaining))
		
		airTemperature := Round(getConfigurationValue(data, "Weather Data", "Temperature", 0))
		trackTemperature := Round(getConfigurationValue(data, "Track Data", "Temperature", 0))
		
		if (airTemperature = 0)
			airTemperature := Round(getConfigurationValue(data, "Car Data", "AirTemperature", 0))
		
		if (trackTemperature = 0)
			trackTemperature := Round(getConfigurationValue(data, "Car Data", "RoadTemperature", 0))
		
		weatherNow := getConfigurationValue(data, "Weather Data", "Weather", "Dry")
		weather10Min := getConfigurationValue(data, "Weather Data", "Weather10Min", "Dry")
		weather30Min := getConfigurationValue(data, "Weather Data", "Weather30Min", "Dry")
		
		knowledgeBase.setFact("Weather.Temperature.Air", airTemperature)
		knowledgeBase.setFact("Weather.Temperature.Track", trackTemperature)
		knowledgeBase.setFact("Weather.Weather.Now", weatherNow)
		knowledgeBase.setFact("Weather.Weather.10Min", weather10Min)
		knowledgeBase.setFact("Weather.Weather.30Min", weather30Min)
		
		lapTime := getConfigurationValue(data, "Stint Data", "LapLastTime", 0)
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Time", lapTime)
		knowledgeBase.addFact("Lap." . lapNumber . ".Time.Start", this.OverallTime)
		
		this.iOverallTime := this.OverallTime + lapTime
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Time.End", this.OverallTime)
		
		fuelRemaining := getConfigurationValue(data, "Car Data", "FuelRemaining", 0)
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Remaining", Round(fuelRemaining, 2))
		
		if (lapNumber == 1) {
			this.iInitialFuelAmount := fuelRemaining
			this.iLastFuelAmount := fuelRemaining
			
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", 0)
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", 0)
		}
		else if !this.iInitialFuelAmount {
			; This is the case after a pitstop
			this.iInitialFuelAmount := fuelRemaining
			this.iLastFuelAmount := fuelRemaining
			
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", knowledgeBase.getValue("Lap." . (lapNumber - 1) . ".Fuel.AvgConsumption", 0))
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", knowledgeBase.getValue("Lap." . (lapNumber - 1) . ".Fuel.Consumption", 0))
		}
		else {
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", Round((this.InitialFuelAmount - fuelRemaining) / (lapNumber - baseLap), 2))
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", Round(this.iLastFuelAmount - fuelRemaining, 2))
			
			this.iLastFuelAmount := fuelRemaining
		}
		
		tyrePressures := string2Values(",", getConfigurationValue(data, "Car Data", "TyrePressure", ""))
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.FL", Round(tyrePressures[1], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.FR", Round(tyrePressures[2], 2))		
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.RL", Round(tyrePressures[3], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.RR", Round(tyrePressures[4], 2))
		
		tyreTemperatures := string2Values(",", getConfigurationValue(data, "Car Data", "TyreTemperature", ""))
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.FL", Round(tyreTemperatures[1], 1))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.FR", Round(tyreTemperatures[2], 1))		
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.RL", Round(tyreTemperatures[3], 1))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.RR", Round(tyreTemperatures[4], 1))
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Weather", weatherNow)
		knowledgeBase.addFact("Lap." . lapNumber . ".Grip", getConfigurationValue(data, "Track Data", "Grip", "Green"))
		knowledgeBase.addFact("Lap." . lapNumber . ".Temperature.Air", airTemperature)
		knowledgeBase.addFact("Lap." . lapNumber . ".Temperature.Track", trackTemperature)
		
		bodyworkDamage := string2Values(",", getConfigurationValue(data, "Car Data", "BodyworkDamage", ""))
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Bodywork.Front", Round(bodyworkDamage[1], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Bodywork.Rear", Round(bodyworkDamage[2], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Bodywork.Left", Round(bodyworkDamage[3], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Bodywork.Right", Round(bodyworkDamage[4], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Bodywork.Center", Round(bodyworkDamage[5], 2))
		
		suspensionDamage := string2Values(",", getConfigurationValue(data, "Car Data", "SuspensionDamage", ""))
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Suspension.FL", Round(suspensionDamage[1], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Suspension.FR", Round(suspensionDamage[2], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Suspension.RL", Round(suspensionDamage[3], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Damage.Suspension.RR", Round(suspensionDamage[4], 2))
		
		result := knowledgeBase.produce()
		
		if this.Debug[kDebugKnowledgeBase]
			dumpKnowledge(this.KnowledgeBase)
		
		currentCompound := knowledgeBase.getValue("Tyre.Compound", false)
		currentCompoundColor := knowledgeBase.getValue("Tyre.Compound.Color", false)
		targetCompound := knowledgeBase.getValue("Tyre.Compound.Target", false)
		targetCompoundColor := knowledgeBase.getValue("Tyre.Compound.Color.Target", false)
		
		if (currentCompound && (currentCompound = targetCompound) && (currentCompoundColor = targetCompoundColor))
			this.updateSetupData(knowledgeBase.getValue("Session.Simulator"), knowledgeBase.getValue("Session.Track"), knowledgeBase.getValue("Session.Car")
							   , currentCompound, currentCompoundColor, airTemperature, trackTemperature, weatherNow)
		
		return result
	}
	
	updateLap(lapNumber, data) {
		local knowledgeBase := this.KnowledgeBase
		local fact
		
		if !IsObject(data)
			data := readConfiguration(data)
		
		needProduce := false
		
		tyrePressures := string2Values(",", getConfigurationValue(data, "Car Data", "TyrePressure", ""))
		threshold := knowledgeBase.getValue("Session.Settings.Tyre.Pressure.Deviation")
		changed := false
		
		for index, tyreType in ["FL", "FR", "RL", "RR"] {
			newValue := Round(tyrePressures[index], 2)
			fact := ("Lap." . lapNumber . ".Tyre.Pressure." . tyreType)
		
			if (Abs(knowledgeBase.getValue(fact) - newValue) > threshold) {
				knowledgeBase.setValue(fact, newValue)
				
				changed := true
			}
		}
		
		if changed {
			knowledgeBase.addFact("Tyre.Update.Pressure", true)
		
			needProduce := true
		}
		
		tyreTemperatures := string2Values(",", getConfigurationValue(data, "Car Data", "TyreTemperature", ""))
		
		for index, tyreType in ["FL", "FR", "RL", "RR"]
			knowledgeBase.setValue("Lap." . lapNumber . ".Tyre.Temperature." . tyreType, Round(tyreTemperatures[index], 2))
		
		bodyworkDamage := string2Values(",", getConfigurationValue(data, "Car Data", "BodyworkDamage", ""))
		changed := false
		
		for index, position in ["Front", "Rear", "Left", "Right", "Center"] {
			newValue := Round(bodyworkDamage[index], 2)
			fact := ("Lap." . lapNumber . ".Damage.Bodywork." . position)
			oldValue := knowledgeBase.getValue(fact, 0)
			
			if (oldValue < newValue)
				knowledgeBase.setValue(fact, newValue)
			
			changed := (changed || (Round(oldValue) < Round(newValue)))
		}
		
		if changed {
			knowledgeBase.addFact("Damage.Update.Bodywork", lapNumber)
		
			needProduce := true
		}
		
		suspensionDamage := string2Values(",", getConfigurationValue(data, "Car Data", "SuspensionDamage", ""))
		changed := false
		
		for index, position in ["FL", "FR", "RL", "RR"] {
			newValue := Round(suspensionDamage[index], 2)
			fact := ("Lap." . lapNumber . ".Damage.Suspension." . position)
			oldValue := knowledgeBase.getValue(fact, 0)
			
			if (oldValue < newValue)
				knowledgeBase.setValue(fact, newValue)
		
			changed := (changed || (Round(oldValue) < Round(newValue)))
		}
		
		if changed {
			knowledgeBase.addFact("Damage.Update.Suspension", lapNumber)
		
			needProduce := true
		}
				
		if needProduce {
			result := knowledgeBase.produce()
			
			if this.Debug[kDebugKnowledgeBase]
				dumpKnowledge(this.KnowledgeBase)
			
			return result
		}
		else
			return true
	}
	
	updateSetupData(simulator, track, car, compound, compoundColor, airTemperature, trackTemperature, weather) {
		local knowledgeBase := this.KnowledgeBase
		
		this.iSetupDataActive := true
		
		try {
			targetPressures := Array(Round(knowledgeBase.getValue("Tyre.Pressure.Target.FL"), 1)
								   , Round(knowledgeBase.getValue("Tyre.Pressure.Target.FR"), 1)
								   , Round(knowledgeBase.getValue("Tyre.Pressure.Target.RL"), 1)
								   , Round(knowledgeBase.getValue("Tyre.Pressure.Target.RR"), 1))
			
			if (compoundColor = "Black")
				descriptor := ConfigurationItem.descriptor(simulator, track, car, compound, airTemperature, trackTemperature, weather)
			else
				descriptor := ConfigurationItem.descriptor(simulator, track, car, compound, compoundColor, airTemperature, trackTemperature, weather)
			
			if this.SetupData.HasKey(descriptor)
				setupData := this.SetupData[descriptor]
			else {
				setupData := Object()
			
				this.SetupData[descriptor] := setupData
			}
			
			for ignore, tyre in ["FL", "FR", "RL", "RR"] {
				pressure := (tyre . ":" . targetPressures[A_Index])
				
				setupData[pressure] := (setupData.HasKey(pressure) ? (setupData[pressure] + 1) : 1)
			}
		}
		finally {
			this.iSetupDataActive := false
		}
	}
	
	updateSetupDatabase(confirm := false) {
		local compound
		
		this.iSetupDataActive := true
		
		try {
			if this.KnowledgeBase {
				for descriptor, pressures in this.SetupData {
					descriptor := ConfigurationItem.splitDescriptor(descriptor)
				
					simulator := descriptor[1]
					track := descriptor[2]
					car := descriptor[3]
					compound := descriptor[4]
					
					if (descriptor.Length() = 7) {
						compoundColor := "Black"
						airTemperature := descriptor[5]
						trackTemperature := descriptor[6]
						weather := descriptor[7]
					}
					else {
						compoundColor := descriptor[5]
						airTemperature := descriptor[6]
						trackTemperature := descriptor[7]
						weather := descriptor[8]
					}
					
					this.updateTyrePressures(simulator, track, car, compound, compoundColor, airTemperature, trackTemperature, weather, pressures)
				}
		
				if (confirm && this.Speaker)
					this.getSpeaker().speakPhrase("SetupDatabaseUpdated")
			}
		}
		finally {
			this.iSetupDataActive := false
		}
		
		this.iSetupData := {}
	}		
	
	updateTyrePressures(simulator, track, car, compound, compoundColor, airTemperature, trackTemperature, weather, targetPressures) {
		local knowledgeBase := this.KnowledgeBase
		static lastSimulator := false
		static lastCar := false
		static lastTrack := false
		static lastCompound := false
		static lastCompoundColor := false
		static lastWeather := false
		static database := false
		static databaseName := false
		
		FileCreateDir %kSetupDatabaseDirectory%Local\%simulator%\%car%\%track%
		
		if ((lastSimulator != simulator) || (lastCar != car) || (lastTrack != track) || (lastCompound != compound) || (lastCompoundColor != compoundColor) || (lastWeather != weather)) {
			database := false
		
			lastSimulator := simulator
			lastCar := car
			lastTrack := track
			lastCompound := compound
			lastCompoundColor := compoundColor
			lastWeather := weather
		}
		
		key := ConfigurationItem.descriptor(airTemperature, trackTemperature)
		
		if !database {
			if (compoundColor = "Black")
				databaseName := (kSetupDatabaseDirectory . "Local\" . simulator . "\" . car . "\" . track . "\Tyre Setup " . compound . " " . weather . ".data")
			else
				databaseName := (kSetupDatabaseDirectory . "Local\" . simulator . "\" . car . "\" . track . "\Tyre Setup " . compound . " (" . compoundColor . ") " . weather . ".data")
		
			database := readConfiguration(databaseName)
		}
		
		pressureData := getConfigurationValue(database, "Pressures", key, false)
		pressures := {FL: {}, FR: {}, RL: {}, RR: {}}
		
		if pressureData {
			pressureData := string2Values(";", pressureData)
			
			for index, tyre in ["FL", "FR", "RL", "RR"]
				for index, pressure in string2Values(",", pressureData[index]) {
					pressure := string2Values(":", pressure)
				
					pressures[tyre][pressure[1]] := pressure[2]
				}
		}
		
		for tyrePressure, count in targetPressures {
			tyrePressure := string2Values(":", tyrePressure)
			pressure := tyrePressure[2]
			
			tyrePressures := pressures[tyrePressure[1]]
			
			tyrePressures[pressure] := (tyrePressures.HasKey(pressure) ? (tyrePressures[pressure] + count) : count)
		}
			
		pressureData := []
		
		for ignore, tyrePressures in pressures {
			data := []
		
			for pressure, count in tyrePressures
				data.Push(pressure . ":" . count)
			
			pressureData.Push(values2String(",", data*))
		}
		
		setConfigurationValue(database, "Pressures", key, values2String("; ", pressureData*))
		
		writeConfiguration(databaseName, database)
	}
	
	hasEnoughData() {
		if this.EnoughData
			return true
		else if this.Speaker {
			this.getSpeaker().speakPhrase("Later")
			
			return false
		}
	}
	
	hasPlannedPitstop() {
		return this.KnowledgeBase.getValue("Pitstop.Planned", false)
	}
	
	hasPreparedPitstop() {
		return this.KnowledgeBase.getValue("Pitstop.Prepared", false)
	}
	
	supportsPitstop() {
		return ((this.Session == kSessionRace) && this.PitstopHandler)
	}
	
	planPitstop(options := true, confirm := true) {
		local knowledgeBase := this.KnowledgeBase
		local compound
		
		if !this.hasEnoughData()
			return false
		
		if !this.supportsPitstop() {
			if this.Speaker
				this.getSpeaker().speakPhrase("NoPitstop")
			
			return false
		}
	
		knowledgeBase.addFact("Pitstop.Plan", ((options == true) || !options.HasKey("Update") || !options.Update) ? true : false)
	
		result := knowledgeBase.produce()
		
		if this.Debug[kDebugKnowledgeBase]
			dumpKnowledge(this.KnowledgeBase)
		
		pitstopNumber := knowledgeBase.getValue("Pitstop.Planned.Nr")
		
		if this.Speaker {
			speaker := this.getSpeaker()
			fragments := speaker.Fragments
			
			if ((options == true) || options.Intro)
				speaker.speakPhrase("Pitstop", {number: pitstopNumber})
			
			if ((options == true) || options.Fuel) {
				fuel := Round(knowledgeBase.getValue("Pitstop.Planned.Fuel", 0))
				
				if (fuel == 0)
					speaker.speakPhrase("NoRefuel")
				else
					speaker.speakPhrase("Refuel", {litres: fuel})
			}
			
			if ((options == true) || options.Compound) {
				compound := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound")
				color := knowledgeBase.getValue("Pitstop.Planned.Tyre.Compound.Color")
				
				if (compound = "Dry")
					speaker.speakPhrase("DryTyres", {compound: fragments[compound], color: color, set: knowledgeBase.getValue("Pitstop.Planned.Tyre.Set")})
				else
					speaker.speakPhrase("WetTyres", {compound: fragments[compound], color: color, set: knowledgeBase.getValue("Pitstop.Planned.Tyre.Set")})
			}
			
			if ((options == true) || options.Pressures) {
				incrementFL := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL.Increment", 0), 1)
				incrementFR := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR.Increment", 0), 1)
				incrementRL := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL.Increment", 0), 1)
				incrementRR := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR.Increment", 0), 1)
			
				debug := this.Debug[kDebugPhrases]
			
				if (debug || (incrementFL != 0) || (incrementFR != 0) || (incrementRL != 0) || (incrementRR != 0))
					speaker.speakPhrase("NewPressures")
				
				if (debug || (incrementFL != 0))
					speaker.speakPhrase("TyreFL", {value: Format("{:.1f}", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FL"), 1))
												 , unit: fragments["PSI"]})
				
				if (debug || (incrementFR != 0))
					speaker.speakPhrase("TyreFR", {value: Format("{:.1f}", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.FR"), 1))
												 , unit: fragments["PSI"]})
				
				if (debug || (incrementRL != 0))
					speaker.speakPhrase("TyreRL", {value: Format("{:.1f}", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RL"), 1))
												 , unit: fragments["PSI"]})
				
				if (debug || (incrementRR != 0))
					speaker.speakPhrase("TyreRR", {value: Format("{:.1f}", Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.RR"), 1))
												 , unit: fragments["PSI"]})
		
				pressureCorrection := Round(knowledgeBase.getValue("Pitstop.Planned.Tyre.Pressure.Correction", 0), 1)
				
				if (Abs(pressureCorrection) > 0.05) {
					temperatureDelta := knowledgeBase.getValue("Weather.Temperature.Air.Delta", 0)
					
					if (temperatureDelta = 0)
						temperatureDelta := ((pressureCorrection > 0) ? -1 : 1)
					
					speaker.speakPhrase((pressureCorrection > 0) ? "PressureCorrectionUp" : "PressureCorrectionDown"
									  , {value: Format("{:.1f}", Abs(pressureCorrection)), unit: fragments["PSI"]
									   , pressureDirection: (pressureCorrection > 0) ? fragments["Increase"] : fragments["Decrease"]
									   , temperatureDirection: (temperatureDelta > 0) ? fragments["Rising"] : fragments["Falling"]})
				}
			}

			if ((options == true) || options.Repairs) {
				if knowledgeBase.getValue("Pitstop.Planned.Repair.Suspension", false)
					speaker.speakPhrase("RepairSuspension")
				else if debug
					speaker.speakPhrase("NoRepairSuspension")

				if knowledgeBase.getValue("Pitstop.Planned.Repair.Bodywork", false)
					speaker.speakPhrase("RepairBodywork")
				else if debug
					speaker.speakPhrase("NoRepairBodywork")
			}
			
			if (confirm && this.Listener) {
				speaker.speakPhrase("ConfirmPrepare")
				
				this.setContinuation(ObjBindMethod(this, "preparePitstop"))
			}
		}
		
		if (result && this.PitstopHandler) {
			this.PitstopHandler.pitstopPlanned(pitstopNumber)
		}
		
		return result
	}
	
	preparePitstop(lap := false) {
		if !this.supportsPitstop() {
			if this.Speaker
				this.getSpeaker().speakPhrase("NoPitstop")
			
			return false
		}
		
		if !this.hasPlannedPitstop() {
			if this.Speaker {
				speaker := this.getSpeaker()

				speaker.speakPhrase("MissingPlan")
				
				if (this.Listener && this.supportsPitstop()) {
					speaker.speakPhrase("ConfirmPlan")
				
					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
			}
			
			return false
		}
		else {
			if this.Speaker {
				speaker := this.getSpeaker()

				if lap
					speaker.speakPhrase("PrepareLap", {lap: lap})
				else
					speaker.speakPhrase("PrepareNow")
			}
				
			if !lap
				this.KnowledgeBase.addFact("Pitstop.Prepare", true)
			else
				this.KnowledgeBase.setFact("Pitstop.Planned.Lap", lap - 1)
		
			result := this.KnowledgeBase.produce()
			
			if this.Debug[kDebugKnowledgeBase]
				dumpKnowledge(this.KnowledgeBase)
					
			return result
		}
	}
	
	performPitstop(lapNumber := false) {
		if this.Speaker
			this.getSpeaker().speakPhrase("Perform")
		
		this.KnowledgeBase.addFact("Pitstop.Lap", lapNumber ? lapNumber : this.KnowledgeBase.getValue("Lap"))
		
		result := this.KnowledgeBase.produce()
		
		this.iEnoughData := false
		this.iLastFuelAmount := 0
		this.iInitialFuelAmount := 0
		
		if this.Debug[kDebugKnowledgeBase]
			dumpKnowledge(this.KnowledgeBase)
		
		if (result && this.PitstopHandler)
			this.PitstopHandler.pitstopFinished(this.KnowledgeBase.getValue("Pitstop.Last", 0))
		
		return result
	}
	
	lowFuelWarning(remainingLaps) {
		if this.Speaker {
			speaker := this.getSpeaker()
			
			speaker.speakPhrase((remainingLaps <= 2) ? "VeryLowFuel" : "LowFuel", {laps: remainingLaps})
						
			if (this.Listener && this.supportsPitstop()) {
				if this.hasPreparedPitstop()
					speaker.speakPhrase((remainingLaps <= 2) ? "LowComeIn" : "ComeIn")
				else if !this.hasPlannedPitstop() {
					speaker.speakPhrase("ConfirmPlan")
					
					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
				else {
					speaker.speakPhrase("ConfirmPrepare")
					
					this.setContinuation(ObjBindMethod(this, "preparePitstop"))
				}
			}
		}
	}
	
	damageWarning(newSuspensionDamage, newBodyworkDamage) {
		if this.Speaker {
			speaker := this.getSpeaker()
			phrase := false
			
			if (newSuspensionDamage && newBodyworkDamage)
				phrase := "BothDamage"
			else if newSuspensionDamage
				phrase := "SuspensionDamage"
			else if newBodyworkDamage
				phrase := "BodyworkDamage"
			
			speaker.speakPhrase(phrase)
	
			speaker.speakPhrase("DamageAnalysis")
		}
	}
	
	reportDamageAnalysis(repair, stintLaps, delta) {
		if this.Speaker {
			speaker := this.getSpeaker()
			
			stintLaps := Round(stintLaps)
			delta := Format("{:.2f}", Round(delta, 2))
			
			if repair {
				speaker.speakPhrase("RepairPitstop", {laps: stintLaps, delta: delta})
		
				if (this.Listener && this.supportsPitstop()) {
					speaker.speakPhrase("ConfirmPlan")
				
					this.setContinuation(ObjBindMethod(this, "planPitstop"))
				}
			}
			else if (repair == false)
				speaker.speakPhrase((delta == 0) ? "NoTimeLost" : "NoRepairPitstop", {laps: stintLaps, delta: delta})
		}
	}
	
	weatherChangeNotification(change, minutes) {
		if this.Speaker {
			speaker := this.getSpeaker()
			
			speaker.speakPhrase(change ? "WeatherChange" : "WeatherNoChange", {minutes: minutes})
		}
	}
	
	weatherTyreChangeRecommendation(minutes, recommendedCompound) {
		if this.Speaker {
			speaker := this.getSpeaker()
			fragments := speaker.Fragments
			
			speaker.speakPhrase((recommendedCompound = "Wet") ? "WeatherRainChange" : "WeatherDryChange"
							  , {minutes: minutes, compound: fragments[recommendedCompound]})
			
			if (this.Listener && this.supportsPitstop()) {
				speaker.speakPhrase("ConfirmPlan")
			
				this.setContinuation(ObjBindMethod(this, "planPitstop"))
			}
		}
	}
	
	startPitstopSetup(pitstopNumber) {
		if this.PitstopHandler
			this.PitstopHandler.startPitstopSetup(pitstopNumber)
	}

	finishPitstopSetup(pitstopNumber) {
		if this.PitstopHandler {
			this.PitstopHandler.finishPitstopSetup(pitstopNumber)
			
			this.PitstopHandler.pitstopPrepared(pitstopNumber)
			
			if this.Speaker
				this.getSpeaker().speakPhrase("CallToPit")
		}
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		if this.PitstopHandler
			this.PitstopHandler.setPitstopRefuelAmount(pitstopNumber, litres)
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor, set) {
		if this.PitstopHandler
			this.PitstopHandler.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		local compound
		local knowledgeBase
		
		if this.PitstopHandler
			this.PitstopHandler.setPitstopTyrePressures(pitstopNumber, Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		if this.PitstopHandler
			this.PitstopHandler.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getDeprecatedConfigurationValue(data, newSection, oldSection, key, default := false) {
	value := getConfigurationValue(data, newSection, key, kUndefined)
	
	if (value != kUndefined)
		return value
	else
		return getConfigurationValue(data, oldSection, key, default)
}

lowFuelWarning(context, remainingLaps) {
	context.KnowledgeBase.RaceEngineer.lowFuelWarning(Round(remainingLaps))
	
	return true
}

damageWarning(context, newSuspensionDamage, newBodyworkDamage) {
	context.KnowledgeBase.RaceEngineer.damageWarning(newSuspensionDamage, newBodyworkDamage)
	
	return true
}

reportDamageAnalysis(context, repair, stintLaps, delta) {
	context.KnowledgeBase.RaceEngineer.reportDamageAnalysis(repair, stintLaps, delta)
	
	return true
}

weatherChangeNotification(context, change, minutes) {
	context.KnowledgeBase.RaceEngineer.weatherChangeNotification(change, minutes)
	
	return true
}

weatherTyreChangeRecommendation(context, minutes, recommendedCompound) {
	context.KnowledgeBase.RaceEngineer.weatherTyreChangeRecommendation(minutes, recommendedCompound)
	
	return true
}

startPitstopSetup(context, pitstopNumber) {
	context.KnowledgeBase.RaceEngineer.startPitstopSetup(pitstopNumber)
	
	return true
}

finishPitstopSetup(context, pitstopNumber) {
	context.KnowledgeBase.RaceEngineer.finishPitstopSetup(pitstopNumber)
	
	return true
}

setPitstopRefuelAmount(context, pitstopNumber, litres) {
	context.KnowledgeBase.RaceEngineer.setPitstopRefuelAmount(pitstopNumber, litres)
	
	return true
}

setPitstopTyreSet(context, pitstopNumber, compound, compoundColor, set) {
	context.KnowledgeBase.RaceEngineer.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)
	
	return true
}

setPitstopTyrePressures(context, pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
	context.KnowledgeBase.RaceEngineer.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)
	
	return true
}

requestPitstopRepairs(context, pitstopNumber, repairSuspension, repairBodywork) {
	context.KnowledgeBase.RaceEngineer.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork)
	
	return true
}

dumpKnowledge(knowledgeBase) {
	try {
		FileDelete %kUserHomeDirectory%Temp\Race Engineer.knowledge
	}
	catch exception {
		; ignore
	}

	for key, value in knowledgeBase.Facts.Facts {
		text := key . " = " . value . "`n"
	
		FileAppend %text%, %kUserHomeDirectory%Temp\Race Engineer.knowledge
	}
}