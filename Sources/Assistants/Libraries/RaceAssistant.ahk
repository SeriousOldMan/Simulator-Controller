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
global kDebugRules := 2

global kAsk := "Ask"
global kAlways := "Always"
global kNever := "Never"

global kUnknown := false


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

	iSessionDuration := 0
	iOverallTime := 0
	iBestLapTime := 0

	iBaseLap := false
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
			local configuration := readConfiguration(kTempDirectory . this.AssistantType . ".state")

			setConfigurationValue(configuration, "Voice", "Muted", value)

			writeConfiguration(kTempDirectory . this.AssistantType . ".state", configuration)

			return (this.VoiceManager.Muted := value)
		}
	}

	Speaker[force := false] {
		Get {
			return this.VoiceManager.Speaker[force]
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

	MultiClass[data := false] {
		Get {
			static knowledgeBase := false
			static multiClass := false

			if (!knowledgeBase || (knowledgeBase != this.KnowledgeBase)) {
				knowledgaBase := this.KnowledgeBase

				multiClass := (this.getClasses(data).Length() > 1)
			}

			return multiClass
		}
	}

	SessionDuration[] {
		Get {
			return this.iSessionDuration
		}
	}

	SessionLaps[] {
		Get {
			return this.iSessionLaps
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

	BaseLap[] {
		Get {
			return this.iBaseLap
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

		if !kUnknown
			kUnknown := translate("Unknown")

		this.iDebug := (isDebug() ? (kDebugKnowledgeBase + kDebugRules) : kDebugOff)
		this.iAssistantType := assistantType
		this.iRemoteHandler := remoteHandler

		base.__New(configuration)

		options := this.iOptions

		if (language != kUndefined) {
			listener := ((speaker != false) ? listener : false)

			options["Language"] := ((language != false) ? language : options["Language"])
			options["Synthesizer"] := ((synthesizer == true) ? options["Synthesizer"] : synthesizer)
			options["Speaker"] := ((speaker == true) ? options["Speaker"] : speaker)
			options["Recognizer"] := ((recognizer == true) ? options["Recognizer"] : recognizer)
			options["Listener"] := ((listener == true) ? options["Listener"] : listener)
			options["VoiceServer"] := voiceServer

			if vocalics {
				vocalics := string2Values(",", vocalics)

				loop 3
					if (vocalics[A_Index] = "*")
						vocalics[A_Index] := options["Vocalics"][A_Index]

				options["Vocalics"] := vocalics
			}
		}

		this.iVoiceManager := this.createVoiceManager(name, options)

		configuration := newConfiguration()

		setConfigurationValue(configuration, "Voice", "Speaker", this.Speaker[true])
		setConfigurationValue(configuration, "Voice", "Listener", this.Listener)
		setConfigurationValue(configuration, "Voice", "Muted", this.Muted)

		writeConfiguration(kTempDirectory . assistantType . ".state", configuration)
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
		if values.HasKey("SessionDuration")
			this.iSessionDuration := values["SessionDuration"]

		if values.HasKey("SessionLaps")
			this.iSessionLaps := values["SessionLaps"]

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

			if (this.Session == kSessionFinished) {
				this.iSessionDuration := 0
				this.iSessionLaps := 0

				this.iBaseLap := false
				this.iInitialFuelAmount := 0
			}
		}
	}

	updateDynamicValues(values) {
		if values.HasKey("KnowledgeBase")
			this.iKnowledgeBase := values["KnowledgeBase"]

		if values.HasKey("OverallTime")
			this.iOverallTime := values["OverallTime"]

		if values.HasKey("BestLapTime")
			this.iBestLapTime := values["BestLapTime"]

		if values.HasKey("BaseLap")
			this.iBaseLap := values["BaseLap"]

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

				if isInstance(continuation, VoiceManager.VoiceContinuation)
					continuation.cancel()
				else if continuation
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

			this.setContinuation(new VoiceManager.ReplyContinuation(this, ObjBindMethod(this, "updateAnnouncement", announcement, active), "Roger", "Okay"))
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
		local continuation := this.Continuation

		if continuation {
			if isInstance(continuation, VoiceManager.VoiceContinuation)
				this.handleVoiceCommand("Yes", ["Yes"])
			else if this.VoiceManager
				this.VoiceManager.phraseRecognized("Yes", ["Yes"])
			else
				this.handleVoiceCommand("Yes", ["Yes"])
		}
		else if this.VoiceManager
			this.VoiceManager.recognizeCommand("Yes", ["Yes"])
	}

	reject() {
		local continuation := this.Continuation

		if continuation {
			if isInstance(continuation, VoiceManager.VoiceContinuation)
				this.handleVoiceCommand("No", ["No"])
			else if this.VoiceManager
				this.VoiceManager.phraseRecognized("No", ["No"])
			else
				this.handleVoiceCommand("No", ["No"])
		}
		else if this.VoiceManager
			this.VoiceManager.recognizeCommand("No", ["No"])
	}

	mute() {
		this.deactivateRecognized([])
	}

	unmute() {
		this.activateRecognized([])
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

					speaker.beginTalk()

					try {
						speaker.speakPhrase("Joke")

						speaker.speak(joke.value)
					}
					finally {
						speaker.endTalk()
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

					speaker.beginTalk()

					try {
						speaker.speakPhrase("Joke")

						speaker.speak(joke)
					}
					finally {
						speaker.endTalk()
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
			this.VoiceManager.setContinuation(new VoiceManager.ReplyContinuation(this, continuation, "Confirm", "Okay"))
	}

	clearContinuation() {
		this.VoiceManager.clearContinuation()
	}

	createKnowledgeBase(facts) {
		local compiler := new RuleCompiler()
		local rules, productions, reductions, engine, knowledgeBase, ignore, compound, compoundColor

		FileRead rules, % getFileName(this.AssistantType . ".rules", kUserRulesDirectory, kRulesDirectory)

		productions := false
		reductions := false

		compiler.compileRules(rules, productions, reductions)

		engine := new RuleEngine(productions, reductions, facts)

		knowledgeBase := new this.RaceKnowledgeBase(this, engine, engine.createFacts(), engine.createRules())

		for ignore, compound in new SessionDatabase().getTyreCompounds(knowledgeBase.getValue("Session.Simulator")
																	 , knowledgeBase.getValue("Session.Car")
																	 , knowledgeBase.getValue("Session.Track")) {
			compoundColor := false

			splitCompound(compound, compound, compoundColor)

			knowledgeBase.addRule(compiler.compileRule("availableTyreCompound(" . compound . "," . compoundColor . ")"))
		}

		if this.Debug[kDebugRules]
			this.dumpRules(knowledgeBase)

		return knowledgeBase
	}

	setDebug(option, enabled) {
		local label := false

		if enabled
			this.iDebug := (this.iDebug | option)
		else if (this.Debug[option] == option)
			this.iDebug := (this.iDebug - option)

		switch option {
			case kDebugKnowledgeBase:
				label := translate("Debug Knowledgebase")

				if (enabled && this.KnowledgeBase)
					this.dumpKnowledgeBase(this.KnowledgeBase)
			case kDebugRules:
				label := translate("Debug Rule System")

				if (enabled && this.KnowledgeBase)
					this.dumpRules(this.KnowledgeBase)
		}

		try {
			if label
				if enabled
					Menu SupportMenu, Check, %label%
				else
					Menu SupportMenu, Uncheck, %label%
		}
		catch exception {
			logError(exception)
		}
	}

	toggleDebug(option) {
		this.setDebug(option, !this.Debug[option])
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

	initializeSessionFormat(facts, settings, data, lapTime) {
		local sessionFormat := getConfigurationValue(data, "Session Data", "SessionFormat", "Time")
		local sessionTimeRemaining := getDeprecatedConfigurationValue(data, "Session Data", "Stint Data", "SessionTimeRemaining", 0)
		local sessionLapsRemaining := getDeprecatedConfigurationValue(data, "Session Data", "Stint Data", "SessionLapsRemaining", 0)
		local dataDuration := Round((sessionTimeRemaining + lapTime) / 1000)
		local laps := sessionLapsRemaining
		local duration := dataDuration
		local settingsDuration

		if (sessionFormat = "Time") {
			if (lapTime > 0)
				laps := Round((dataDuration * 1000) / lapTime)
			else
				laps := 0
		}
		else if (dataDuration > 0) {
			settingsDuration := getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings", "Duration", dataDuration)

			if ((Abs(settingsDuration - dataDuration) / dataDuration) >  0.05)
				duration := dataDuration
			else
				duration := settingsDuration
		}

		if isInstance(facts, KnowledgeBase) {
			facts.setValue("Session.Duration", duration)
			facts.setValue("Session.Laps", laps)
			facts.setValue("Session.Format", sessionFormat)
		}
		else {
			facts["Session.Duration"] := duration
			facts["Session.Laps"] := laps
			facts["Session.Format"] := sessionFormat
		}

		this.updateSessionValues({SessionDuration: duration * 1000, SessionLaps: laps})
	}

	readSettings(ByRef settings) {
		if !IsObject(settings)
			settings := readConfiguration(settings)

		return {"Session.Settings.Lap.Formation": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings"
																				, "Lap.Formation", true)
			  , "Session.Settings.Lap.PostRace": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings"
																			   , "Lap.PostRace", true)
			  , "Session.Settings.Lap.AvgTime": getDeprecatedConfigurationValue(settings, "Session Settings", "Race Settings"
																			  , "Lap.AvgTime", 0)
			  , "Session.Settings.Lap.PitstopWarning": getDeprecatedConfigurationValue(settings, "Session Settings"
																				     , "Race Settings", "Lap.PitstopWarning", 5)
			  , "Session.Settings.Fuel.AvgConsumption": getDeprecatedConfigurationValue(settings, "Session Settings"
			 																		  , "Race Settings", "Fuel.AvgConsumption", 0)
			  , "Session.Settings.Fuel.SafetyMargin": getDeprecatedConfigurationValue(settings, "Session Settings"
																					, "Race Settings", "Fuel.SafetyMargin", 5)}
	}

	updateSettings(settings) {
		local knowledgeBase := this.KnowledgeBase
		local facts, key, value

		if knowledgeBase
			for key, value in this.readSettings(settings)
				knowledgeBase.setFact(key, value)
	}

	createSession(ByRef settings, ByRef data) {
		local configuration, simulator, simulatorName, session, driverForname, driverSurname, driverNickname
		local lapTime, settingsLapTime, facts

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

		facts := combine(this.readSettings(settings)
					   , {"Session.Simulator": simulator
						, "Session.Car": getConfigurationValue(data, "Session Data", "Car", "")
						, "Session.Track": getConfigurationValue(data, "Session Data", "Track", "")
						, "Session.Type": this.Session
						, "Session.Time.Remaining": getDeprecatedConfigurationValue(data, "Session Data", "Stint Data", "SessionTimeRemaining", 0)
						, "Session.Lap.Remaining": getDeprecatedConfigurationValue(data, "Session Data", "Stint Data", "SessionLapsRemaining", 0)
						, "Session.Settings.Lap.Time.Adjust": this.AdjustLapTime
						, "Session.Settings.Fuel.Max": getConfigurationValue(data, "Session Data", "FuelAmount", 0)})

		this.initializeSessionFormat(facts, settings, data, lapTime)

		return facts
	}

	startSession(settings, data) {
		throw "Virtual method RaceAssistant.startSession must be implemented in a subclass..."
	}

	finishSession(shutdown := true) {
		throw "Virtual method RaceAssistant.finishSession must be implemented in a subclass..."
	}

	restoreSessionState(settingsFile, stateFile) {
		local knowledgeBase := this.KnowledgeBase
		local sessionState, sessionSettings

		if stateFile {
			sessionState := readConfiguration(stateFile)

			deleteFile(stateFile)

			knowledgeBase.Facts.Facts := getConfigurationSectionValues(sessionState, "Session State", Object())

			this.updateSessionValues({SessionDuration: knowledgeBase.getValue("Session.Duration") * 1000
									, SessionLaps: knowledgeBase.getValue("Session.Laps")})
			this.updateDynamicValues({LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
		}

		if settingsFile {
			sessionSettings := readConfiguration(settingsFile)

			deleteFile(settingsFile)

			this.updateSettings(sessionSettings)
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
		local driver, driverForname, driverSurname, driverNickname, tyreSet, timeRemaining, airTemperature, trackTemperature
		local weatherNow, weather10Min, weather30Min, lapTime, settingsLapTime, overallTime, values, result, baseLap, lapValid
		local fuelRemaining, avgFuelConsumption, tyrePressures, tyreTemperatures, tyreWear, brakeTemperatures, brakeWear

		if (knowledgeBase && (knowledgeBase.getValue("Lap", 0) == lapNumber))
			return false

		data := this.prepareData(lapNumber, data)

		knowledgeBase := this.KnowledgeBase

		knowledgeBase.setFact("Lap", lapNumber)

		if !this.InitialFuelAmount
			baseLap := lapNumber
		else
			baseLap := this.BaseLap

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

		if ((lapNumber <= 2) && this.AdjustLapTime) {
			settingsLapTime := (getDeprecatedConfigurationValue(this.Settings, "Session Settings", "Race Settings", "Lap.AvgTime", lapTime / 1000) * 1000)

			if ((lapTime / settingsLapTime) > 1.2)
				lapTime := settingsLapTime
		}

		if ((knowledgeBase.getValue("Session.Duration", 0) == 0) || (knowledgeBase.getValue("Session.Laps", 0) == 0))
			this.initializeSessionFormat(knowledgeBase, this.Settings, data, lapTime)

		overallTime := ((lapNumber = 1) ? 0 : knowledgeBase.getValue("Lap." . (lapNumber - 1) . ".Time.End"))

		driver := getConfigurationValue(data, "Position Data", "Driver.Car", false)

		lapValid := getConfigurationValue(data, "Stint Data", "LapValid", true)

		if (driver && (getConfigurationValue(data, "Position Data", "Car." . driver . ".Lap", false) = lapNumber))
			lapValid := getConfigurationValue(data, "Position Data", "Car." . driver . ".Lap.Valid", lapValid)

		knowledgeBase.addFact("Lap." . lapNumber . ".Valid", lapValid)

		knowledgeBase.addFact("Lap." . lapNumber . ".Time", lapTime)
		knowledgeBase.addFact("Lap." . lapNumber . ".Time.Start", overallTime)

		overallTime := (this.OverallTime + lapTime)

		values := {OverallTime: overallTime}

		if (lapTime > 0) {
			if ((lapNumber > 1) && lapValid)
				values["BestLapTime"] := (this.BestLapTime = 0) ? lapTime : Min(this.BestLapTime, lapTime)

			this.updateDynamicValues(values)
		}

		knowledgeBase.addFact("Lap." . lapNumber . ".Time.End", overallTime)

		fuelRemaining := getConfigurationValue(data, "Car Data", "FuelRemaining", 0)

		knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Remaining", Round(fuelRemaining, 2))

		if (lapNumber == 1) {
			this.updateDynamicValues({BaseLap: 1
									, LastFuelAmount: fuelRemaining, InitialFuelAmount: fuelRemaining, AvgFuelConsumption: 0})

			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.AvgConsumption", 0)
			knowledgeBase.addFact("Lap." . lapNumber . ".Fuel.Consumption", 0)
		}
		else if (!this.InitialFuelAmount || (fuelRemaining > this.LastFuelAmount)) {
			; This is the case after a pitstop
			this.updateDynamicValues({BaseLap: lapNumber
									, LastFuelAmount: fuelRemaining, InitialFuelAmount: fuelRemaining, AvgFuelConsumption: 0})

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
			this.dumpKnowledgeBase(this.KnowledgeBase)

		return result
	}

	updateLap(lapNumber, ByRef data) {
		local knowledgeBase := this.KnowledgeBase
		local result

		data := this.prepareData(lapNumber, data)

		result := knowledgeBase.produce()

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(knowledgeBase)

		return result
	}

	getClasses(data := false) {
		local knowledgebase := this.Knowledgebase
		local class

		static classes := false
		static lastKnowledgeBase := false

		if (data || !lastKnowledgeBase || (lastKnowledgebase != knowledgeBase) || !classes) {
			classes := {}

			loop % (data ? getConfigurationValue(data, "Position Data", "Car.Count") : knowledgeBase.getValue("Car.Count"))
			{
				class := (data ? getConfigurationValue(data, "Position Data", "Car." . A_Index . ".Class", kUnknown)
							   : knowledgeBase.getValue("Car." . A_Index . ".Class", kUnknown))

				if !classes.HasKey(class)
					classes[class] := true
			}

			lastKnowledgeBase := (data ? false : knowledgeBase)

			classes := getKeys(classes)
		}

		return classes
	}

	getClass(car := false, data := false) {
		if !car
			car := (data ? getConfigurationValue(data, "Position Data", "Driver.Car") : this.KnowledgeBase.getValue("Driver.Car", false))

		if data
			return getConfigurationValue(data, "Position Data", "Car." . car . ".Class", kUnknown)
		else
			return this.KnowledgeBase.getValue("Car." . car . ".Class", kUnknown)
	}

	getCars(class := "Overall", data := false, sorted := false) {
		local knowledgebase := this.Knowledgebase
		local positions, ignore, position

		static classGrid := false
		static lastClass := false
		static lastKnowledgeBase := false

		if (class = "Class")
			class := this.getClass()
		else if (class = "Overall")
			class := false

		if (data || sorted || !lastKnowledgeBase || (lastKnowledgebase != knowledgeBase) || !class || (lastClass != class)) {
			classGrid := []

			if sorted {
				positions := []

				if data {
					loop % getConfigurationValue(data, "Position Data", "Car.Count")
						if (!class || (class = getConfigurationValue(data, "Position Data", "Car." . A_Index . ".Class", kUnknown)))
							positions.Push(Array(A_Index, getConfigurationValue(data, "Position Data", "Car." . A_Index . ".Position")))
				}
				else
					loop % knowledgeBase.getValue("Car.Count")
						if (!class || (class = knowledgeBase.getValue("Car." . A_Index . ".Class", kUnknown)))
							positions.Push(Array(A_Index, knowledgeBase.getValue("Car." . A_Index . ".Position")))

				bubbleSort(positions, "compareClassPositions")

				for ignore, position in positions
					classGrid.Push(position[1])
			}
			else {
				if data {
					loop % getConfigurationValue(data, "Position Data", "Car.Count")
						if (!class || (class = getConfigurationValue(data, "Position Data", "Car." . A_Index . ".Class", kUnknown)))
							classGrid.Push(A_Index)
				}
				else
					loop % knowledgeBase.getValue("Car.Count")
						if (!class || (class = knowledgeBase.getValue("Car." . A_Index . ".Class", kUnknown)))
							classGrid.Push(A_Index)
			}

			if (data || !class) {
				lastKnowledgeBase := false
				lastClass := false
			}
			else {
				lastKnowledgeBase := knowledgeBase
				lastClass := class
			}
		}

		return classGrid
	}

	getPosition(car := false, type := "Overall", data := false) {
		local knowledgebase := this.Knowledgebase
		local position, candidate

		if !car {
			if (type = "Overall") {
				if data
					return getConfigurationValue(data, "Position Data", "Car." . getConfigurationValue(data, "Position Data", "Driver.Car") . ".Position", false)
				else
					return knowledgeBase.getValue("Position")
			}
			else
				car := (data ? getConfigurationValue(data, "Position Data", "Driver.Car") : knowledgeBase.getValue("Driver.Car", false))
		}

		if ((type != "Overall") && this.MultiClass[data]) {
			for position, candidate in this.getCars(data ? getConfigurationValue(data, "Position Data", "Car." . car . ".Class", kUnknown)
														 : knowledgeBase.getValue("Car." . car . ".Class", kUnknown)
												  , data, true)
				if (candidate = car)
					return position
		}

		if data
			return getConfigurationValue(data, "Position Data", "Car." . car . ".Position", car)
		else
			return knowledgeBase.getValue("Car." . car . ".Position", car)
	}

	performPitstop(lapNumber := false) {
		if !lapNumber
			lapNumber := this.KnowledgeBase.getValue("Lap")

		this.startPitstop(lapNumber)

		this.executePitstop(lapNumber)

		this.finishPitstop(lapNumber)

		this.updateDynamicValues({LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
	}

	startPitstop(lapNumber) {
		return true
	}

	executePitstop(lapNumber) {
		local knowledgeBase := this.KnowledgeBase

		knowledgeBase.addFact("Pitstop.Lap", lapNumber)

		result := knowledgeBase.produce()

		if (this.Debug[kDebugKnowledgeBase])
			this.dumpKnowledgeBase(knowledgeBase)

		return result
	}

	finishPitstop(lapNumber) {
		local savedKnowledgeBase, settingsFile, stateFile

		if this.RemoteHandler {
			savedKnowledgeBase := newConfiguration()

			setConfigurationSectionValues(savedKnowledgeBase, "Session State", this.KnowledgeBase.Facts.Facts)

			settingsFile := temporaryFileName(this.AssistantType, "settings")
			stateFile := temporaryFileName(this.AssistantType, "state")

			writeConfiguration(settingsFile, this.Settings)
			writeConfiguration(stateFile, savedKnowledgeBase)

			this.RemoteHandler.saveSessionState(settingsFile, stateFile)
		}

		return true
	}

	saveSessionSettings() {
		local knowledgeBase, compound, settingsDB, simulator, car, track, duration, weather, compound, compoundColor, oldValue
		local loadSettings, lapTime, fileName, settings

		if this.hasEnoughData(false) {
			knowledgeBase := this.KnowledgeBase
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
				if (this.AvgFuelConsumption > 0)
					settingsDB.setSettingValue(simulator, car, track, weather, "Session Settings", "Fuel.AvgConsumption", Round(this.AvgFuelConsumption, 2))

				if (settingsDB.getSettingValue(simulator, car, track, "*", "Session Settings", "Fuel.Amount", kUndefined) == kUndefined)
					settingsDB.setSettingValue(simulator, car, track, "*", "Session Settings", "Fuel.Amount", Round(knowledgeBase.getValue("Session.Settings.Fuel.Max")))

				if (lapTime > 10)
					settingsDB.setSettingValue(simulator, car, track, weather, "Session Settings", "Lap.AvgTime", Round(lapTime, 1))
			}
			else {
				fileName := getFileName("Race.settings", kUserConfigDirectory)

				settings := readConfiguration(fileName)

				if (this.AvgFuelConsumption > 0)
					setConfigurationValue(settings, "Session Settings", "Fuel.AvgConsumption", Round(this.AvgFuelConsumption, 2))

				if (lapTime > 10)
					setConfigurationValue(settings, "Session Settings", "Lap.AvgTime", Round(lapTime, 1))

				writeConfiguration(fileName, settings)
			}
		}
	}

	dumpKnowledgeBase(knowledgeBase) {
		knowledgeBase.dumpFacts()
	}

	dumpRules(knowledgeBase) {
		knowledgeBase.dumpRules()
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
;;;                  Internal Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

compareClassPositions(c1, c2) {
	local pos1 := c1[2]
	local pos2 := c2[2]

	if pos1 is not Number
		pos1 := 999

	if pos2 is not Number
		pos2 := 999

	return (pos1 > pos2)
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