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
	
	iRemoteHandler := false
	
	iSessionTime := false
	
	iSimulator := ""
	iSession := kSessionFinished
	iDriverForName := "John"
	
	iiDriverFullName := "John Doe (JD)"
	iDrivers := []
	
	iLearningLaps := 1
	
	iKnowledgeBase := false

	iOverallTime := 0
	iBestLapTime := 0
	
	iLastFuelAmount := 0
	iInitialFuelAmount := 0
	iAvgFuelConsumption := 0
	
	iEnoughData := false
	
	iSetupDatabase := false
	iSaveSettings := kNever
	
	class RaceAssistantRemoteHandler {
		iEvent := false
		iRemotePID := false
		
		Event[] {
			Get {
				return this.iEvent
			}
		}
		
		RemotePID[] {
			Get {
				return this.iRemotePID
			}
		}
		
		__New(event, remotePID) {
			this.iEvent := event
			this.iRemotePID := remotePID
		}
		
		callRemote(function, arguments*) {
			raiseEvent(kFileMessage, this.Event, function . ":" . values2String(";", arguments*), this.RemotePID)
		}
		
		saveSessionState(arguments*) {
			this.callRemote("saveSessionState", arguments*)
		}
	}
	
	class RaceVoiceAssistant extends VoiceAssistant {
		iRaceAssistant := false
		
		RaceAssistant[] {
			Get {
				return this.iRaceAssistant
			}
		}
		
		User[] {
			Get {
				return this.RaceAssistant.DriverForName
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
	
	RemoteHandler[] {
		Get {
			return this.iRemoteHandler
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
	
	DriverForName[] {
		Get {
			return this.iDriverForName
		}
	}
	
	DriverFullName[] {
		Get {
			return this.iDriverFullName
		}
	}
	
	Drivers[] {
		Get {
			return this.iDrivers
		}
	}
	
	SessionTime[] {
		Get {
			return this.iSessionTime
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
			return this.iEnoughData
		}
	}
	
	LearningLaps[] {
		Get {
			return this.iLearningLaps
		}
	}
	
	AdjustLapTime[] {
		Get {
			return true
		}
	}
	
	OverallTime[] {
		Get {
			return this.iOverallTime
		}
	}
	
	BestLapTime[] {
		Get {
			return this.iBestLapTime
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
	
	AvgFuelConsumption[] {
		Get {
			return this.iAvgFuelConsumption
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
	
	__New(configuration, assistantType, remoteHandler, name := false, language := "__Undefined__", service := false, speaker := false, listener := false, voiceServer := false) {
		this.iDebug := (isDebug() ? kDebugKnowledgeBase : kDebugOff)
		this.iAssistantType := assistantType
		this.iRemoteHandler := remoteHandler
		
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
		
		if values.HasKey("SaveSettings")
			this.iSaveSettings := values["SaveSettings"]
		
		if values.HasKey("LearningLaps")
			this.iLearningLaps := values["LearningLaps"]
	}
	
	updateSessionValues(values) {
		if values.HasKey("SessionTime")
			this.iSessionTime := values["SessionTime"]
		
		if values.HasKey("Simulator")
			this.iSimulator := values["Simulator"]
		
		if values.HasKey("Driver")
			this.iDriverForName := values["Driver"]
		
		if values.HasKey("DriverFullName") {
			fullName := values["DriverFullName"]
			
			if !inList(this.Drivers, fullName)
				this.Drivers.Push(fullName)
		
			this.iDriverFullName := fullName
		}
		
		if values.HasKey("Session") {
			this.iSession := values["Session"]
			
			if (this.Session == kSessionFinished)
				this.iDrivers := []
		}
	}
	
	updateDynamicValues(values) {
		if values.HasKey("KnowledgeBase")
			this.iKnowledgeBase := values["KnowledgeBase"]
		
		if values.HasKey("OverallTime")
			this.iOverallTime := values["OverallTime"]
		
		if values.HasKey("BestLapTime")
			this.iBestLapTime := values["BestLapTime"]
		
		if values.HasKey("LastFuelAmount")
			this.iLastFuelAmount := values["LastFuelAmount"]
		
		if values.HasKey("InitialFuelAmount")
			this.iInitialFuelAmount := values["InitialFuelAmount"]
		
		if values.HasKey("AvgFuelConsumption")
			this.iAvgFuelConsumption := values["AvgFuelConsumption"]
		
		if values.HasKey("EnoughData")
			this.iEnoughData := values["EnoughData"]
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
	
	createSession(ByRef settings, ByRef data) {
		local facts
		
		if settings
			this.updateConfigurationValues({Settings: settings})
		
		configuration := this.Configuration
		settings := this.Settings
		
		simulator := getConfigurationValue(data, "Session Data", "Simulator", "Unknown")
		simulatorName := this.SetupDatabase.getSimulatorName(simulator)
		
		switch getConfigurationValue(data, "Session Data", "Session", "Practice") {
			case "Practice":
				session := kSessionPractice
			case "Qualification":
				session := kSessionQualification
			case "Race":
				session := kSessionRace
			default:
				session := kSessionOther
		}
		
		this.updateSessionValues({Simulator: simulatorName, Session: session, SessionTime: A_Now
								, Driver: getConfigurationValue(data, "Stint Data", "DriverForname", this.DriverForName)})
		
		lapTime := getConfigurationValue(data, "Stint Data", "LapLastTime", 0)
		
		if this.AdjustLapTime {
			settingsLapTime := (getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.AvgTime", lapTime / 1000) * 1000)
			
			if ((lapTime / settingsLapTime) > 1.2)
				lapTime := settingsLapTime
		}
		
		sessionFormat := getConfigurationValue(data, "Session Data", "SessionFormat", "Time")
		sessionTimeRemaining := getDeprecatedConfigurationValue(data, "Session Data", "Stint Data", "SessionTimeRemaining", 0)
		sessionLapsRemaining := getDeprecatedConfigurationValue(data, "Session Data", "Stint Data", "SessionLapsRemaining", 0)
		
		dataDuration := Round((sessionTimeRemaining + lapTime) / 1000)
		
		if (sessionFormat = "Time") {
			duration := dataDuration
			
			laps := Round((dataDuration * 1000) / lapTime)
		}
		else {
			laps := (sessionLapsRemaining + 1)
		
			settingsDuration := getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Duration", dataDuration)
			
			if ((Abs(settingsDuration - dataDuration) / dataDuration) >  0.05)
				duration := dataDuration
			else
				duration := settingsDuration
		}
		
		facts := {"Session.Simulator": simulator
				, "Session.Car": getConfigurationValue(data, "Session Data", "Car", "")
				, "Session.Track": getConfigurationValue(data, "Session Data", "Track", "")
				, "Session.Duration": duration
				, "Session.Laps": laps
				, "Session.Type": this.Session
				, "Session.Format": sessionFormat
				, "Session.Time.Remaining": sessionTimeRemaining
				, "Session.Lap.Remaining": sessionLapsRemaining
				, "Session.Settings.Lap.Formation": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.Formation", true)
				, "Session.Settings.Lap.PostRace": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.PostRace", true)
				, "Session.Settings.Lap.AvgTime": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.AvgTime", 0)
				, "Session.Settings.Lap.Time.Adjust": this.AdjustLapTime
				, "Session.Settings.Lap.PitstopWarning": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.PitstopWarning", 5)
				, "Session.Settings.Fuel.Max": getConfigurationValue(data, "Session Data", "FuelAmount", 0)
				, "Session.Settings.Fuel.AvgConsumption": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Fuel.AvgConsumption", 0)
				, "Session.Settings.Fuel.SafetyMargin": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Fuel.SafetyMargin", 5)}
		
		return facts
	}
	
	updateSession(settings) {
		local knowledgeBase := this.KnowledgeBase
		local facts
		
		if knowledgeBase {
			if !IsObject(settings)
				settings := readConfiguration(settings)
			
			this.updateConfigurationValues({Settings: settings})
			
			facts := {"Session.Settings.Lap.Formation": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.Formation", true)
					, "Session.Settings.Lap.PostRace": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.PostRace", true)
					, "Session.Settings.Lap.AvgTime": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.AvgTime", 0)
					, "Session.Settings.Lap.PitstopWarning": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Lap.PitstopWarning", 5)
					, "Session.Settings.Fuel.AvgConsumption": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Fuel.AvgConsumption", 0)
					, "Session.Settings.Fuel.SafetyMargin": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Fuel.SafetyMargin", 5)}
			
			for key, value in facts
				knowledgeBase.setValue(key, value)
			
			if this.Debug[kDebugKnowledgeBase]
				this.dumpKnowledge(knowledgeBase)
		}
	}
	
	startSession(settings, data) {
		Throw "Virtual method RaceAssistant.startSession must be implemented in a subclass..."
	}
	
	finishSession(shutdown := true) {
		Throw "Virtual method RaceAssistant.finishSession must be implemented in a subclass..."
	}
	
	restoreSessionState(settingsFile, stateFile) {
		sessionSettings := readConfiguration(settingsFile)
		sessionState := readConfiguration(stateFile)
		
		try {
			FileDelete %settingsFile%
			FileDelete %stateFile%
		}
		catch exception {
			; ignore
		}
		
		this.KnowledgeBase.Facts.Facts := getConfigurationSectionValues(sessionState, "Session State", Object())
		
		this.updateSession(sessionSettings)
	}
	
	prepareData(lapNumber, data) {
		if !IsObject(data)
			data := readConfiguration(data)
		
		if !this.KnowledgeBase
			this.startSession(this.Settings, data)
		
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
		
		driverForname := getConfigurationValue(data, "Stint Data", "DriverForname", this.DriverForName)
		driverSurname := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
		driverNickname := getConfigurationValue(data, "Stint Data", "DriverNickname", "JD")
		
		this.updateSessionValues({Driver: driverForname, DriverFullname: computeDriverName(driverForName, driverSurName, driverNickName)})
			
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
		
		knowledgeBase.addFact("Lap." . lapNumber . ".Valid", getConfigurationValue(data, "Stint Data", "LapValid", true))
			
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
		local knowledgeBase := this.KnowledgeBase
		
		data := this.prepareData(lapNumber, data)
		
		if knowledgeBase.getFact("Lap." . lapNumber . ".Valid")
			knowledgeBase.setFact("Lap." . lapNumber . ".Valid", getConfigurationValue(data, "Stint Data", "LapValid", true))
			
		result := knowledgeBase.produce()
			
		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledge(knowledgeBase)
		
		return result
	}
	
	startPitstop(lapNumber := false) {
	}
	
	performPitstop(lapNumber := false) {
	}
	
	finishPitstop(lapNumber := false) {
		if this.RemoteHandler {
			savedKnowledgeBase := newConfiguration()
			
			setConfigurationSectionValues(savedKnowledgeBase, "Session State", this.KnowledgeBase.Facts.Facts)
			
			Random postfix, 1, 1000000
				
			settingsFile := (kTempDirectory . "Race Strategist " . postfix . ".settings")
			stateFile := (kTempDirectory . "Race Strategist " . postfix . ".state")
			
			writeConfiguration(settingsFile, this.Settings)
			writeConfiguration(stateFile, savedKnowledgeBase)
		
			this.RemoteHandler.saveSessionState(settingsFile, stateFile)
		}
	}
	
	saveSessionSettings() {
		local knowledgeBase := this.KnowledgeBase
		local compound
		
		if knowledgeBase {
			setupDB := this.SetupDatabase
			
			simulatorName := setupDB.getSimulatorName(knowledgeBase.getValue("Session.Simulator"))
			car := knowledgeBase.getValue("Session.Car")
			track := knowledgeBase.getValue("Session.Track")
			duration := knowledgeBase.getValue("Session.Duration")
			weather := knowledgeBase.getValue("Weather.Now")
			compound := knowledgeBase.getValue("Tyre.Compound")
			compoundColor := knowledgeBase.getValue("Tyre.Compound.Color")
			
			oldValue := getConfigurationValue(this.Configuration, "Race Engineer Startup", simulatorName . ".LoadSettings", "Default")
			loadSettings := getConfigurationValue(this.Configuration, "Race Assistant Startup", simulatorName . ".LoadSettings", oldValue)
		
			duration := (Round((duration / 60) / 5) * 300)
			
			values := {AvgFuelConsumption: this.AvgFuelConsumption, Compound: compound, CompoundColor: compoundColor, Duration: duration}
			
			lapTime := Round(this.BestLapTime / 1000)
			
			if (lapTime > 10)
				values["AvgLapTime"] := lapTime
			
			if (loadSettings = "SetupDatabase")
				setupDB.updateSettings(simulatorName, car, track
									 , {Duration: duration, Weather: weather, Compound: compound, CompoundColor: compoundColor}, values)
			else {
				fileName := getFileName("Race.settings", kUserConfigDirectory)
				
				settings := readConfiguration(fileName)
				
				setupDB.updateSettingsValues(settings, values)
				
				writeConfiguration(fileName, settings)
			}
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


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

computeDriverName(forName, surName, nickName) {
	name := ""
	
	if (forName != "")
		name .= (forName . A_Space)
	
	if (surName != "")
		name .= (surName . A_Space)
	
	if (nickName != "")
		name .= (translate("(") . nickName . translate(")"))
	
	return Trim(name)
}

getDeprecatedConfigurationValue(data, newSection, oldSection, key, default := false) {
	value := getConfigurationValue(data, newSection, key, kUndefined)
	
	if (value != kUndefined)
		return value
	else
		return getConfigurationValue(data, oldSection, key, default)
}