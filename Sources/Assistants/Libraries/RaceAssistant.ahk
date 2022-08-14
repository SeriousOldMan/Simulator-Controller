;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Assistant               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk
#Include ..\Libraries\JSON.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\RuleEngine.ahk
#Include ..\Assistants\Libraries\VoiceManager.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk
#Include ..\Assistants\Libraries\SettingsDatabase.ahk
#Include ..\Assistants\Libraries\TyresDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessionFinished := 0
global kSessionPaused := -1
global kSessionOther := 1
global kSessionPractice := 2
global kSessionQualification := 3
global kSessionRace := 4

global kDebugKnowledgeBase := 1
global kDebugLast := 1

global kAsk := "Ask"
global kAlways := "Always"
global kNever := "Never"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceAssistant extends ConfigurationItem {
	iDebug := kDebugOff
	iOptions := {}

	iAssistantType := ""
	iSettings := false
	iVoiceManager := false

	iMuted := false

	iAnnouncements := false

	iRemoteHandler := false

	iSessionTime := false

	iSimulator := ""
	iSession := kSessionFinished
	iDriverForName := "John"

	iDriverFullName := "John Doe (JD)"

	iLearningLaps := 1

	iKnowledgeBase := false

	iOverallTime := 0
	iBestLapTime := 0

	iLastFuelAmount := 0
	iInitialFuelAmount := 0
	iAvgFuelConsumption := 0

	iEnoughData := false

	iTyresDatabase := false

	iSettingsDatabase := false
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
			sendMessage(kFileMessage, this.Event, function . ":" . values2String(";", arguments*), this.RemotePID)
		}

		saveSessionState(arguments*) {
			this.callRemote("callSaveSessionState", arguments*)
		}
	}

	class RaceVoiceManager extends VoiceManager {
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
			local prefix := this.RaceAssistant.AssistantType . ".grammars."
			local fileName := (prefix . language)
			local grammars, section, values, key, value

			if !FileExist(getFileName(fileName, kUserGrammarsDirectory, kGrammarsDirectory))
				fileName := (prefix . "en")

			grammars := readConfiguration(kGrammarsDirectory . fileName)

			for section, values in readConfiguration(kUserGrammarsDirectory . fileName)
				for key, value in values
					setConfigurationValue(grammars, section, key, value)

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

	VoiceManager[] {
		Get {
			return this.iVoiceManager
		}
	}

	Muted[]  {
		Get {
			return this.VoiceManager.Muted
		}

		Set {
			return (this.VoiceManager.Muted := value)
		}
	}

	Speaker[muted := false] {
		Get {
			return this.VoiceManager.Speaker[muted]
		}
	}

	Listener[] {
		Get {
			return this.VoiceManager.Listener
		}
	}

	Announcements[key := false] {
		Get {
			return (key ? this.iAnnouncements[key] : this.iAnnouncements)
		}

		Set {
			return (key ? (this.iAnnouncements[key] := value) : (this.iAnnouncements := value))
		}
	}

	Continuation[] {
		Get {
			return this.VoiceManager.Continuation
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

	SettingsDatabase[] {
		Get {
			if !this.iSettingsDatabase
				this.iSettingsDatabase := new SettingsDatabase()

			return this.iSettingsDatabase
		}
	}

	TyresDatabase[] {
		Get {
			if !this.iTyresDatabase
				this.iTyresDatabase := new TyresDatabase()

			return this.iTyresDatabase
		}
	}

	__New(configuration, assistantType, remoteHandler, name := false, language := "__Undefined__"
	    , synthesizer := false, speaker := false, vocalics := false, recognizer := false, listener := false, voiceServer := false) {
		local options

		this.iDebug := (isDebug() ? kDebugKnowledgeBase : kDebugOff)
		this.iAssistantType := assistantType
		this.iRemoteHandler := remoteHandler

		base.__New(configuration)

		options := this.iOptions

		if (language != kUndefined) {
			listener := ((speaker != false) ? listener : false)

			options["Language"] := ((language != false) ? language : options["Language"])
			options["Synthesizer"] := ((synthesizer == true) ? options["Synthesizer"] : synthesizer)
			options["Speaker"] := ((speaker == true) ? options["Speaker"] : speaker)
			options["Vocalics"] := (vocalics ? string2Values(",", vocalics) : options["Vocalics"])
			options["Recognizer"] := ((recognizer == true) ? options["Recognizer"] : recognizer)
			options["Listener"] := ((listener == true) ? options["Listener"] : listener)
			options["VoiceServer"] := voiceServer
		}

		this.iVoiceManager := this.createVoiceManager(name, options)
	}

	loadFromConfiguration(configuration) {
		local options

		base.loadFromConfiguration(configuration)

		options := this.iOptions

		options["Language"] := getConfigurationValue(configuration, "Voice Control", "Language", getLanguage())
		options["Synthesizer"] := getConfigurationValue(configuration, "Voice Control", "Synthesizer", getConfigurationValue(configuration, "Voice Control", "Service", "dotNET"))
		options["Speaker"] := getConfigurationValue(configuration, "Voice Control", "Speaker", true)
		options["Vocalics"] := Array(getConfigurationValue(configuration, "Voice Control", "SpeakerVolume", 100)
								   , getConfigurationValue(configuration, "Voice Control", "SpeakerPitch", 0)
								   , getConfigurationValue(configuration, "Voice Control", "SpeakerSpeed", 0))
		options["Recognizer"] := getConfigurationValue(configuration, "Voice Control", "Recognizer", "Desktop")
		options["Listener"] := getConfigurationValue(configuration, "Voice Control", "Listener", false)
		options["PushToTalk"] := getConfigurationValue(configuration, "Voice Control", "PushToTalk", false)
	}

	createVoiceManager(name, options) {
		return new this.RaceVoiceManager(this, name, options)
	}

	updateConfigurationValues(values) {
		if values.HasKey("Settings")
			this.iSettings := values["Settings"]

		if values.HasKey("SaveSettings")
			this.iSaveSettings := values["SaveSettings"]

		if values.HasKey("LearningLaps")
			this.iLearningLaps := values["LearningLaps"]

		if values.HasKey("Announcements")
			this.iAnnouncements := values["Announcements"]
	}

	updateSessionValues(values) {
		if values.HasKey("SessionTime")
			this.iSessionTime := values["SessionTime"]

		if values.HasKey("Simulator")
			this.iSimulator := values["Simulator"]

		if values.HasKey("Driver")
			this.iDriverForName := values["Driver"]

		if values.HasKey("DriverFullName")
			this.iDriverFullName := values["DriverFullName"]

		if values.HasKey("Session") {
			this.iSession := values["Session"]

			if (this.Session == kSessionFinished)
				this.iInitialFuelAmount := 0
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
		local continuation

		switch grammar {
			case "Time":
				this.timeRecognized(words)
			case "Yes":
				continuation := this.Continuation

				this.clearContinuation()

				if isInstance(continuation, VoiceManager.VoiceContinuation)
					continuation.continue()
				else if continuation {
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
			case "Activate":
				this.clearContinuation()

				this.activateRecognized(words)
			case "Deactivate":
				this.clearContinuation()

				this.deactivateRecognized(words)
			case "Joke":
				this.jokeRecognized(words)
			case "AnnouncementsOn":
				this.clearContinuation()

				this.activateAnnouncement(words, true)
			case "AnnouncementsOff":
				this.clearContinuation()

				this.activateAnnouncement(words, false)
			case "?":
				this.getSpeaker().speakPhrase("Repeat")
			default:
				throw "Unknown grammar """ . grammar . """ detected in RaceAssistant.handleVoiceCommand...."
		}
	}

	timeRecognized(words) {
		local time

		FormatTime time, %A_Now%, Time

		this.getSpeaker().speakPhrase("Time", {time: time})
	}

	activateAnnouncement(words, active) {
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local announcements := []
		local key, value, announcement, score, ignore, fragment, fragmentScore

		for key, value in this.Announcements
			announcements.Push(key)

		announcement := false
		score := 0

		for ignore, fragment in announcements
			if fragments.HasKey(fragment) {
				fragmentScore := matchFragment(words, fragments[fragment])

				if (fragmentScore > score) {
					announcement := fragment
					score := fragmentScore
				}
			}

		if (score > 0.5) {
			speaker.speakPhrase(active ? "ConfirmAnnouncementOn" : "ConfirmAnnouncementOff", {announcement: fragments[announcement]}, true)

			this.setContinuation(new VoiceManager.ReplyContinuation(this, ObjBindMethod(this, "updateAnnouncement", announcement, active), "Roger"))
		}
		else
			speaker.speakPhrase("Repeat")
	}

	updateAnnouncement(announcement, value) {
		this.Announcements[announcement] := value
	}

	call() {
		local voiceManager := this.VoiceManager

		if voiceManager
			voiceManager.recognizeActivation("Call", ["Hey", this.VoiceManager.Name])
	}

	accept() {
		if this.Continuation {
			if this.VoiceManager
				this.VoiceManager.phraseRecognized("Yes", ["Yes"])
			else
				this.handleVoiceCommand("Yes", ["Yes"])
		}
		else if this.VoiceManager
			this.VoiceManager.recognizeCommand("Yes", ["Yes"])
	}

	reject() {
		if this.Continuation {
			if this.VoiceManager
				this.VoiceManager.phraseRecognized("No", ["No"])
			else
				this.handleVoiceCommand("No", ["No"])
		}
		else if this.VoiceManager
			this.VoiceManager.recognizeCommand("No", ["No"])
	}

	nameRecognized(words) {
		this.getSpeaker().speakPhrase("IHearYou")
	}

	activateRecognized(words) {
		this.Muted := false

		this.getSpeaker().speakPhrase("Roger")
	}

	deactivateRecognized(words) {
		this.Muted := true

		this.getSpeaker().speakPhrase("Okay")
	}

	jokeRecognized(words) {
		local rnd, joke, speaker, html, index, hasJoke

		Random rnd, 0, 4

		hasJoke := (rnd > 1)

		if hasJoke
			if (this.VoiceManager.Language = "EN")
				try {
					URLDownloadToFile https://api.chucknorris.io/jokes/random, %kTempDirectory%joke.json

					FileRead joke, %kTempDirectory%joke.json

					joke := JSON.parse(joke)

					speaker := this.getSpeaker()

					speaker.startTalk()

					try {
						speaker.speakPhrase("Joke")

						speaker.speak(joke.value)
					}
					finally {
						speaker.finishTalk()
					}
				}
				catch exception {
					hasJoke := false
				}
			else if (this.VoiceManager.Language = "DE")
				try {
					URLDownloadToFile http://www.hahaha.de/witze/zufallswitz.js.php, %kTempDirectory%joke.json

					FileRead joke, %kTempDirectory%joke.json

					html := ComObjCreate("HtmlFile")

					html.write(joke)

					joke := html.documentElement.innerText

					joke := StrReplace(StrReplace(StrReplace(joke, "document.writeln('", ""), "`n", " "), "\", "")

					index := InStr(joke, "</div")

					if index
						joke := SubStr(joke, 1, index - 1)

					speaker := this.getSpeaker()

					speaker.startTalk()

					try {
						speaker.speakPhrase("Joke")

						speaker.speak(joke)
					}
					finally {
						speaker.finishTalk()
					}
				}
				catch exception {
					hasJoke := false
				}
			else
				hasJoke := false

		if !hasJoke
			this.getSpeaker().speakPhrase("NoJoke")
	}

	isNumber(word, ByRef number) {
		local fragments, index, fragment

		static numberFragmentsLookup := false

		if word is Number
		{
			number := word

			return true
		}
		else {
			if !numberFragmentsLookup {
				fragments := this.getSpeaker().Fragments

				numberFragmentsLookup := {}

				for index, fragment in ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"]
					numberFragmentsLookup[fragment] := index - 1
			}

			if numberFragmentsLookup.HasKey(word) {
				number := numberFragmentsLookup[word]

				return true
			}
			else
				return false
		}
	}

	setContinuation(continuation) {
		if isInstance(continuation, VoiceManager.VoiceContinuation)
			this.VoiceManager.setContinuation(continuation)
		else
			this.VoiceManager.setContinuation(new VoiceManager.ReplyContinuation(this, continuation, "Confirm"))
	}

	clearContinuation() {
		this.VoiceManager.clearContinuation()
	}

	createKnowledgeBase(facts) {
		local rules, productions, reductions, engine

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
		return this.VoiceManager.getSpeaker()
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

	prepareSession(ByRef settings, ByRef data) {
		local simulator, simulatorName, session, driverForname, driverSurname, driverNickname

		if (settings && !IsObject(settings))
			settings := readConfiguration(settings)

		if (data && !IsObject(data))
			data := readConfiguration(data)
		else if !data
			data := newConfiguration()

		if settings
			this.updateConfigurationValues({Settings: settings})

		settings := this.Settings

		simulator := getConfigurationValue(data, "Session Data", "Simulator", "Unknown")
		simulatorName := this.SettingsDatabase.getSimulatorName(simulator)

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

		driverForname := getConfigurationValue(data, "Stint Data", "DriverForname", this.DriverForName)
		driverSurname := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
		driverNickname := getConfigurationValue(data, "Stint Data", "DriverNickname", "JDO")

		this.updateSessionValues({Simulator: simulatorName, Session: session, SessionTime: A_Now
								, Driver: driverForname, DriverFullName: computeDriverName(driverForName, driverSurName, driverNickName)})
	}

	createSession(ByRef settings, ByRef data) {
		local configuration, simulator, simulatorName, session, driverForname, driverSurname, driverNickname
		local lapTime, settingsLapTime, sessionForma, sessionTimeRemaining, sessionLapsRemaining
		local dataDuration, duration, laps, settingsDuration, sessionFormat

		if (settings && !IsObject(settings))
			settings := readConfiguration(settings)

		if (data && !IsObject(data))
			data := readConfiguration(data)

		if settings
			this.updateConfigurationValues({Settings: settings})

		configuration := this.Configuration
		settings := this.Settings

		simulator := getConfigurationValue(data, "Session Data", "Simulator", "Unknown")
		simulatorName := this.SettingsDatabase.getSimulatorName(simulator)

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

		driverForname := getConfigurationValue(data, "Stint Data", "DriverForname", this.DriverForName)
		driverSurname := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
		driverNickname := getConfigurationValue(data, "Stint Data", "DriverNickname", "JDO")

		this.updateSessionValues({Simulator: simulatorName, Session: session, SessionTime: A_Now
								, Driver: driverForname, DriverFullName: computeDriverName(driverForName, driverSurName, driverNickName)})

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

		return {"Session.Simulator": simulator
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
	}

	updateSession(settings) {
		local knowledgeBase := this.KnowledgeBase
		local facts, key, value

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
				knowledgeBase.setFact(key, value)

			if this.Debug[kDebugKnowledgeBase]
				this.dumpKnowledge(knowledgeBase)
		}
	}

	startSession(settings, data) {
		throw "Virtual method RaceAssistant.startSession must be implemented in a subclass..."
	}

	finishSession(shutdown := true) {
		throw "Virtual method RaceAssistant.finishSession must be implemented in a subclass..."
	}

	restoreSessionState(settingsFile, stateFile) {
		local sessionState, sessionSettings

		if stateFile {
			sessionState := readConfiguration(stateFile)

			try {
				FileDelete %stateFile%
			}
			catch exception {
				; ignore
			}

			this.KnowledgeBase.Facts.Facts := getConfigurationSectionValues(sessionState, "Session State", Object())

			this.updateDynamicValues({LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false, DriverFullName: "John Doe (JD)"})
		}

		if settingsFile {
			sessionSettings := readConfiguration(settingsFile)

			try {
				FileDelete %settingsFile%
			}
			catch exception {
				; ignore
			}

			this.updateSession(sessionSettings)
		}
	}

	prepareData(lapNumber, data) {
		if !IsObject(data)
			data := readConfiguration(data)

		if !this.KnowledgeBase
			this.startSession(this.Settings, data)

		return data
	}

	addLap(lapNumber, ByRef data) {
		local knowledgeBase := this.KnowledgeBase
		local driverForname, driverSurname, driverNickname, tyreSet, timeRemaining, airTemperature, trackTemperature
		local weatherNow, weather10Min, weather30Min, lapTime, settingsLapTime, overallTime, values, result
		local fuelRemaining, avgFuelConsumption, tyrePressures, tyreTemperatures, tyreWear, brakeTemperatures, brakeWear

		static baseLap := false

		if (knowledgeBase && (knowledgeBase.getValue("Lap", 0) == lapNumber))
			return false

		data := this.prepareData(lapNumber, data)

		knowledgeBase := this.KnowledgeBase

		knowledgeBase.setFact("Lap", lapNumber)

		if !this.InitialFuelAmount
			baseLap := lapNumber

		this.updateDynamicValues({EnoughData: (lapNumber > (baseLap + (this.LearningLaps - 1)))})

		knowledgeBase.setFact("Session.Time.Remaining", getDeprecatedConfigurationValue(data, "Session Data", "Stint Data", "SessionTimeRemaining", 0))
		knowledgeBase.setFact("Session.Lap.Remaining", getDeprecatedConfigurationValue(data, "Session Data", "Stint Data", "SessionLapsRemaining", 0))

		driverForname := getConfigurationValue(data, "Stint Data", "DriverForname", this.DriverForName)
		driverSurname := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
		driverNickname := getConfigurationValue(data, "Stint Data", "DriverNickname", "JDO")

		this.updateSessionValues({Driver: driverForname, DriverFullName: computeDriverName(driverForname, driverSurname, driverNickname)})

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

		tyreSet := getConfigurationValue(data, "Car Data", "TyreSet", kUndefined)

		if (tyreSet != kUndefined)
			knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Set", tyreSet)

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

		tyreWear := getConfigurationValue(data, "Car Data", "TyreWear", "")

		if (tyreWear != "") {
			tyreWear := string2Values(",", tyreWear)

			knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Wear.FL", Round(tyreWear[1]))
			knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Wear.FR", Round(tyreWear[2]))
			knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Wear.RL", Round(tyreWear[3]))
			knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Wear.RR", Round(tyreWear[4]))
		}

		brakeTemperatures := string2Values(",", getConfigurationValue(data, "Car Data", "BrakeTemperature", ""))

		knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Temperature.FL", Round(brakeTemperatures[1] / 10) * 10)
		knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Temperature.FR", Round(brakeTemperatures[2] / 10) * 10)
		knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Temperature.RL", Round(brakeTemperatures[3] / 10) * 10)
		knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Temperature.RR", Round(brakeTemperatures[4] / 10) * 10)

		brakeWear := getConfigurationValue(data, "Car Data", "BrakeWear", "")

		if (brakeWear != "") {
			brakeWear := string2Values(",", brakeWear)

			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Wear.FL", Round(brakeWear[1], 1))
			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Wear.FR", Round(brakeWear[2], 1))
			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Wear.RL", Round(brakeWear[3], 1))
			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Wear.RR", Round(brakeWear[4], 1))
		}

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
		local result

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
		this.updateDynamicValues({LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
	}

	finishPitstop(lapNumber := false) {
		local savedKnowledgeBase, postfix, settingsFile, stateFile

		if this.RemoteHandler {
			savedKnowledgeBase := newConfiguration()

			setConfigurationSectionValues(savedKnowledgeBase, "Session State", this.KnowledgeBase.Facts.Facts)

			Random postfix, 1, 1000000

			settingsFile := (kTempDirectory . "Race Assistant " . postfix . ".settings")
			stateFile := (kTempDirectory . "Race Assistant " . postfix . ".state")

			writeConfiguration(settingsFile, this.Settings)
			writeConfiguration(stateFile, savedKnowledgeBase)

			this.RemoteHandler.saveSessionState(settingsFile, stateFile)
		}
	}

	saveSessionSettings() {
		local knowledgeBase := this.KnowledgeBase
		local compound, settingsDB, simulator, car, track, duration, weather, compound, compoundColor, oldValue
		local loadSettings, lapTime, fileName, settings

		if knowledgeBase {
			settingsDB := this.SettingsDatabase

			simulator := settingsDB.getSimulatorName(knowledgeBase.getValue("Session.Simulator"))
			car := knowledgeBase.getValue("Session.Car")
			track := knowledgeBase.getValue("Session.Track")
			duration := knowledgeBase.getValue("Session.Duration")
			weather := knowledgeBase.getValue("Weather.Weather.Now")
			compound := knowledgeBase.getValue("Tyre.Compound")
			compoundColor := knowledgeBase.getValue("Tyre.Compound.Color")

			oldValue := getConfigurationValue(this.Configuration, "Race Engineer Startup", simulator . ".LoadSettings", "Default")
			loadSettings := getConfigurationValue(this.Configuration, "Race Assistant Startup", simulator . ".LoadSettings", oldValue)

			lapTime := Round(this.BestLapTime / 1000)

			if ((loadSettings = "SettingsDatabase") || (loadSettings = "SetupDatabase")) {
				settingsDB.setSettingValue(simulator, car, track, weather, "Session Settings", "Fuel.AvgConsumption", Round(this.AvgFuelConsumption, 2))

				if (settingsDB.getSettingValue(simulator, car, track, "*", "Session Settings", "Fuel.Amount", kUndefined) == kUndefined)
					settingsDB.setSettingValue(simulator, car, track, "*", "Session Settings", "Fuel.Amount", Round(knowledgeBase.getValue("Session.Settings.Fuel.Max")))

				if (lapTime > 10)
					settingsDB.setSettingValue(simulator, car, track, weather, "Session Settings", "Lap.AvgTime", Round(lapTime, 1))
			}
			else {
				fileName := getFileName("Race.settings", kUserConfigDirectory)

				settings := readConfiguration(fileName)

				setConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption", Round(this.AvgFuelConsumption, 2))

				if (lapTime > 10)
					setConfigurationValue(settings, "Session Settings", "Lap.AvgTime", Round(lapTime, 1))

				writeConfiguration(fileName, settings)
			}
		}
	}

	dumpKnowledge(knowledgeBase) {
		local prefix := this.AssistantType
		local key, value, text

		try {
			FileDelete %kTempDirectory%%prefix%.knowledge
		}
		catch exception {
			; ignore
		}

		for key, value in knowledgeBase.Facts.Facts {
			text := (key . " = " . value . "`n")

			FileAppend %text%, %kTempDirectory%%prefix%.knowledge
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

printNumber(number, precision) {
	local pos

	number := (Format("{:." . precision . "f}", Round(number, precision)) . "")

	pos := InStr(number, ".")

	if pos {
		if (precision > 0)
			return SubStr(number, 1, pos + precision)
		else
			return SubStr(number, 1, pos - 1)
	}
	else
		return number
}

getDeprecatedConfigurationValue(data, newSection, oldSection, key, default := false) {
	local value := getConfigurationValue(data, newSection, key, kUndefined)

	if (value != kUndefined)
		return value
	else
		return getConfigurationValue(data, oldSection, key, default)
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

matchFragment(words, fragment) {
	local score := 0
	local fragmentWords := string2Values(A_Space, fragment)
	local ignore, word, wordScore, candidate

	for ignore, word in fragmentWords {
		wordScore := 0

		for ignore, candidate in words
			wordScore := Max(matchWords(candidate, word), wordScore)

		score += wordScore
	}

	return (score / fragmentWords.Length())
}