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
	
	__New(configuration, assistantType, settings, name := false, language := "__Undefined__", service := false, speaker := false, listener := false, voiceServer := false) {
		this.iDebug := (isDebug() ? kDebugKnowledgeBase : kDebugOff)
		this.iAssistantType := assistantType
		this.iSettings := settings
		
		base.__New(configuration)
		
		options := this.iOptions
		
		if (language != kUndefined) {
			listener := ((speaker != false) ? listener : false)
			
			options["Language"] := ((language != false) ? language : options["Language"])
			options["Service"] := ((service == true) ? options["Service"] : service)
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
		options["Service"] := getConfigurationValue(configuration, "Voice Control", "Service", "Windows")
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
			case "Call":
				this.nameRecognized(words)
			case "Catch":
				this.getSpeaker().speakPhrase("Repeat")
			default:
				Throw "Unknown grammar """ . grammar . """ detected in RaceAssistant.handleVoiceCommand...."
		}
	}
	
	call() {
		local voiceAssistant := this.VoiceAssistant
		
		if voiceAssistant
			voiceAssistant.recognizeActivation("Call", ["Hey", this.VoiceAssistant.Name])
	}
	
	accept() {
		if this.Continuation {
			if this.VoiceAssistant
				this.VoiceAssistant.phraseRecognized("Yes", ["Yes"])
			else
				this.handleVoiceCommand("Yes", ["Yes"])
		}
		else if this.VoiceAssistant
			this.VoiceAssistant.recognizeCommand("Yes", ["Yes"])
	}
	
	reject() {
		if this.Continuation {
			if this.VoiceAssistant
				this.VoiceAssistant.phraseRecognized("No", ["No"])
			else
				this.handleVoiceCommand("No", ["No"])
		}
		else if this.VoiceAssistant
			this.VoiceAssistant.recognizeCommand("No", ["No"])
	}
	
	nameRecognized(words) {
		this.getSpeaker().speakPhrase("IHearYou")
	}
			
	setContinuation(continuation) {
		this.VoiceAssistant.setContinuation(continuation)
	}
			
	clearContinuation() {
		this.VoiceAssistant.clearContinuation()
	}
	
	createKnowledgeBase(facts) {
		local rules
		
		FileRead rules, % getFileName(this.AssistantType . ".rules", kUserRulesDirectory, kRulesDirectory)
		
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
		if (this.KnowledgeBase && this.EnoughData)
			return true
		else {
			if (inform && this.Speaker)
				this.getSpeaker().speakPhrase("Later")
			
			return false
		}
	}
	
	prepareData(lapNumber, data) {
		if !IsObject(data)
			data := readConfiguration(data)
		
		if !this.KnowledgeBase
			this.startSession(data)
		
		return data
	}
	
	addLap(lapNumber, ByRef data) {
		local knowledgeBase
		static baseLap := false
		
		data := this.prepareData(lapNumber, data)
		
		knowledgeBase := this.KnowledgeBase
		
		if (lapNumber == 1)
			knowledgeBase.addFact("Lap", 1)
		else
			knowledgeBase.setValue("Lap", lapNumber)
			
		if !this.InitialFuelAmount
			baseLap := lapNumber
		
		this.updateDynamicValues({EnoughData: (lapNumber > (baseLap + (this.LearningLaps - 1)))})
		
		knowledgeBase.setFact("Session.Time.Remaining", getDeprecatedConfigurationValue(data, "Session Data", "Stint Data", "SessionTimeRemaining", 0))
		knowledgeBase.setFact("Session.Lap.Remaining", getDeprecatedConfigurationValue(data, "Session Data", "Stint Data", "SessionLapsRemaining", 0))
		
		driverForname := getConfigurationValue(data, "Stint Data", "DriverForname", this.DriverName)
		driverSurname := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
		driverNickname := getConfigurationValue(data, "Stint Data", "DriverNickname", "JD")
		
		this.updateSessionValues({Driver: driverForname})
			
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Forname", driverForname)
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Surname", driverSurname)
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Nickname", driverNickname)
		
		knowledgeBase.setFact("Driver.Forname", driverForname)
		knowledgeBase.setFact("Driver.Surname", driverSurname)
		knowledgeBase.setFact("Driver.Nickname", driverNickname)
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Map", getConfigurationValue(data, "Car Data", "Map", "n/a"))
		knowledgeBase.addFact("Lap." . lapNumber . ".TC", getConfigurationValue(data, "Car Data", "TC", "n/a"))
		knowledgeBase.addFact("Lap." . lapNumber . ".ABS", getConfigurationValue(data, "Car Data", "ABS", "n/a"))
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Compound", getConfigurationValue(data, "Car Data", "TyreCompound", "Dry"))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Compound.Color", getConfigurationValue(data, "Car Data", "TyreCompoundColor", "Black"))
		
		timeRemaining := getDeprecatedConfigurationValue(data, "Session Data", "Stint Data", "SessionTimeRemaining", 0)
		
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
		
		if ((lapNumber <= 2) && knowledgeBase.getValue("Session.Settings.Lap.Time.Adjust", false)) {
			settingsLapTime := (getDeprecatedConfigurationValue(this.Settings, "Session Settings", "Race Settings", "Lap.AvgTime", lapTime / 1000) * 1000)
			
			if ((lapTime / settingsLapTime) > 1.2)
				lapTime := settingsLapTime
		}
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Time", lapTime)
		knowledgeBase.addFact("Lap." . lapNumber . ".Time.Start", this.OverallTime)
		
		overallTime := (this.OverallTime + lapTime)
		
		values := {OverallTime: overallTime}
		
		if (lapNumber > 1)
			values["BestLapTime"] := (this.BestLapTime = 0) ? lapTime : Min(this.BestLapTime, lapTime)
		
		if (lapTime > 0)
			this.updateDynamicValues(values)
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Time.End", overallTime)
		
		fuelRemaining := getConfigurationValue(data, "Car Data", "FuelRemaining", 0)
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Remaining", Round(fuelRemaining, 2))
		
		if (lapNumber == 1) {
			this.updateDynamicValues({LastFuelAmount: fuelRemaining, InitialFuelAmount: fuelRemaining, AvgFuelConsumption: 0})
			
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", 0)
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", 0)
		}
		else if (!this.InitialFuelAmount || (fuelRemaining > this.LastFuelAmount)) {
			; This is the case after a pitstop
			this.updateDynamicValues({LastFuelAmount: fuelRemaining, InitialFuelAmount: fuelRemaining, AvgFuelConsumption: 0})
			
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", knowledgeBase.getValue("Lap." . (lapNumber - 1) . ".Fuel.AvgConsumption", 0))
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", knowledgeBase.getValue("Lap." . (lapNumber - 1) . ".Fuel.Consumption", 0))
		}
		else {
			avgFuelConsumption := Round((this.InitialFuelAmount - fuelRemaining) / (lapNumber - baseLap), 2)
			
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", avgFuelConsumption)
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", Round(this.LastFuelAmount - fuelRemaining, 2))
			
			this.updateDynamicValues({LastFuelAmount: fuelRemaining, AvgFuelConsumption: avgFuelConsumption})
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
		
		result := knowledgeBase.produce()
		
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
		
		return result
	}
	
	updateLap(lapNumber, ByRef data) {
		data := this.prepareData(lapNumber, data)
		
		result := this.KnowledgeBase.produce()
			
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(this.KnowledgeBase)
		
		return result
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


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getDeprecatedConfigurationValue(data, newSection, oldSection, key, default := false) {
	value := getConfigurationValue(data, newSection, key, kUndefined)
	
	if (value != kUndefined)
		return value
	else
		return getConfigurationValue(data, oldSection, key, default)
}