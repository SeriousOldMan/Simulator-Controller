;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Assistant               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\JSON.ahk"
#Include "..\..\Libraries\RuleEngine.ahk"
#Include "VoiceManager.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "..\..\Database\Libraries\SettingsDatabase.ahk"
#Include "..\..\Database\Libraries\TyresDatabase.ahk"


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
	iOptions := CaseInsenseMap()

	iAssistantType := ""
	iSettings := false
	iVoiceManager := false

	iAnnouncements := CaseInsenseMap()

	iRemoteHandler := false

	iSessionTime := false

	iSimulator := ""
	iSession := kSessionFinished
	iTeamSession := false

	iDriverForName := "John"
	iDriverFullName := "John Doe (JD)"

	iLearningLaps := 1

	iKnowledgeBase := false

	iSessionDuration := 0
	iOverallTime := 0
	iBestLapTime := 0

	iBaseLap := false
	iLastLap := false
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

		Event {
			Get {
				return this.iEvent
			}
		}

		RemotePID {
			Get {
				return this.iRemotePID
			}
		}

		__New(event, remotePID) {
			this.iEvent := event
			this.iRemotePID := remotePID
		}

		callRemote(function, arguments*) {
			messageSend(kFileMessage, this.Event, function . ":" . values2String(";", arguments*), this.RemotePID)
		}

		saveSessionState(arguments*) {
			this.callRemote("callSaveSessionState", arguments*)
		}

		saveLapState(arguments*) {
			this.callRemote("callSaveLapState", arguments*)
		}
	}

	class RaceVoiceManager extends VoiceManager {
		iRaceAssistant := false

		Routing {
			Get {
				return this.RaceAssistant.AssistantType
			}
		}

		RaceAssistant {
			Get {
				return this.iRaceAssistant
			}
		}

		User {
			Get {
				return this.RaceAssistant.DriverForName
			}
		}

		__New(raceAssistant, name, options) {
			this.iRaceAssistant := raceAssistant

			super.__New(name, options)
		}

		getPhraseVariables(variables := false) {
			variables := super.getPhraseVariables(variables)

			if variables
				if isInstance(variables, Map)
					variables["Driver"] := variables["User"]
				else
					variables.Driver := variables.User

			return variables
		}

		getGrammars(language) {
			local prefix := this.RaceAssistant.AssistantType . ".grammars."
			local fileName := (prefix . language)
			local grammars, section, values, key, value

			if !FileExist(getFileName(fileName, kUserGrammarsDirectory, kGrammarsDirectory))
				fileName := (prefix . "en")

			grammars := readMultiMap(kGrammarsDirectory . fileName)

			for section, values in readMultiMap(kUserGrammarsDirectory . fileName)
				for key, value in values
					setMultiMapValue(grammars, section, key, value)

			return grammars
		}

		handleVoiceCommand(phrase, words) {
			this.RaceAssistant.handleVoiceCommand(phrase, words)
		}
	}

	class RaceKnowledgeBase extends KnowledgeBase {
		iAssistant := false

		RaceAssistant {
			Get {
				return this.iRaceAssistant
			}
		}

		__New(raceAssistant, ruleEngine, facts, rules) {
			this.iRaceAssistant := raceAssistant

			super.__New(ruleEngine, facts, rules)
		}
	}

	Debug[option] {
		Get {
			return (this.iDebug & option)
		}
	}

	AssistantType {
		Get {
			return this.iAssistantType
		}
	}

	Settings {
		Get {
			return this.iSettings
		}
	}

	RemoteHandler {
		Get {
			return this.iRemoteHandler
		}
	}

	VoiceManager {
		Get {
			return this.iVoiceManager
		}
	}

	Muted {
		Get {
			return this.VoiceManager.Muted
		}

		Set {
			local configuration := readMultiMap(kTempDirectory . this.AssistantType . ".state")

			setMultiMapValue(configuration, "Voice", "Muted", value)

			writeMultiMap(kTempDirectory . this.AssistantType . ".state", configuration)

			return (this.VoiceManager.Muted := value)
		}
	}

	Speaker[force := false] {
		Get {
			return this.VoiceManager.Speaker[force]
		}
	}

	Listener {
		Get {
			return this.VoiceManager.Listener
		}
	}

	Announcements[key?] {
		Get {
			return (isSet(key) ? this.iAnnouncements.Get(key, false) : this.iAnnouncements)
		}

		Set {
			return (isSet(key) ? (this.iAnnouncements[key] := value) : (this.iAnnouncements := value))
		}
	}

	Continuation {
		Get {
			return this.VoiceManager.Continuation
		}
	}

	DriverForName {
		Get {
			return this.iDriverForName
		}
	}

	DriverFullName {
		Get {
			return this.iDriverFullName
		}
	}

	SessionTime {
		Get {
			return this.iSessionTime
		}
	}

	Simulator {
		Get {
			return this.iSimulator
		}
	}

	Session {
		Get {
			return this.iSession
		}
	}

	TeamSession {
		Get {
			return this.iTeamSession
		}
	}

	KnowledgeBase {
		Get {
			return this.iKnowledgeBase
		}
	}

	EnoughData {
		Get {
			return this.iEnoughData
		}
	}

	LearningLaps {
		Get {
			return this.iLearningLaps
		}
	}

	AdjustLapTime {
		Get {
			return true
		}
	}

	SessionDuration {
		Get {
			return this.iSessionDuration
		}
	}

	SessionLaps {
		Get {
			return this.iSessionLaps
		}
	}

	OverallTime {
		Get {
			return this.iOverallTime
		}
	}

	BestLapTime {
		Get {
			return this.iBestLapTime
		}
	}

	LastLap {
		Get {
			return this.iLastLap
		}
	}

	BaseLap {
		Get {
			return this.iBaseLap
		}
	}

	InitialFuelAmount {
		Get {
			return this.iInitialFuelAmount
		}
	}

	LastFuelAmount {
		Get {
			return this.iLastFuelAmount
		}
	}

	AvgFuelConsumption {
		Get {
			return this.iAvgFuelConsumption
		}
	}

	SaveSettings {
		Get {
			return this.iSaveSettings
		}
	}

	SettingsDatabase {
		Get {
			if !this.iSettingsDatabase
				this.iSettingsDatabase := SettingsDatabase()

			return this.iSettingsDatabase
		}
	}

	TyresDatabase {
		Get {
			if !this.iTyresDatabase
				this.iTyresDatabase := TyresDatabase()

			return this.iTyresDatabase
		}
	}

	__New(configuration, assistantType, remoteHandler, name := false, language := kUndefined
		, synthesizer := false, speaker := false, vocalics := false, recognizer := false, listener := false, muted := false, voiceServer := false) {
		global kUnknown
		local options

		if !kUnknown
			kUnknown := translate("Unknown")

		this.iAssistantType := assistantType
		this.iRemoteHandler := remoteHandler

		super.__New(configuration)

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

		configuration := newMultiMap()

		setMultiMapValue(configuration, "Voice", "Speaker", this.Speaker[true])
		setMultiMapValue(configuration, "Voice", "Listener", this.Listener)
		setMultiMapValue(configuration, "Voice", "Muted", this.Muted)

		writeMultiMap(kTempDirectory . assistantType . ".state", configuration)

		if muted
			this.Muted := true
	}

	loadFromConfiguration(configuration) {
		local options

		super.loadFromConfiguration(configuration)

		options := this.iOptions

		options["Language"] := getMultiMapValue(configuration, "Voice Control", "Language", getLanguage())
		options["Synthesizer"] := getMultiMapValue(configuration, "Voice Control", "Synthesizer", getMultiMapValue(configuration, "Voice Control", "Service", "dotNET"))
		options["Speaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker", true)
		options["Vocalics"] := Array(getMultiMapValue(configuration, "Voice Control", "SpeakerVolume", 100)
								   , getMultiMapValue(configuration, "Voice Control", "SpeakerPitch", 0)
								   , getMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", 0))
		options["Recognizer"] := getMultiMapValue(configuration, "Voice Control", "Recognizer", "Desktop")
		options["Listener"] := getMultiMapValue(configuration, "Voice Control", "Listener", false)
		options["PushToTalk"] := getMultiMapValue(configuration, "Voice Control", "PushToTalk", false)
	}

	createVoiceManager(name, options) {
		return RaceAssistant.RaceVoiceManager(this, name, options)
	}

	updateConfigurationValues(values) {
		if values.HasProp("Settings")
			this.iSettings := values.Settings

		if values.HasProp("SaveSettings")
			this.iSaveSettings := values.SaveSettings

		if values.HasProp("LearningLaps")
			this.iLearningLaps := values.LearningLaps

		if values.HasProp("Announcements")
			this.iAnnouncements := toMap(values.Announcements, CaseInsenseMap)
	}

	updateSessionValues(values) {
		if values.HasProp("SessionDuration")
			this.iSessionDuration := values.SessionDuration

		if values.HasProp("SessionLaps")
			this.iSessionLaps := values.SessionLaps

		if values.HasProp("SessionTime")
			this.iSessionTime := values.SessionTime

		if values.HasProp("Simulator")
			this.iSimulator := values.Simulator

		if values.HasProp("Driver")
			this.iDriverForName := values.Driver

		if values.HasProp("DriverFullName")
			this.iDriverFullName := values.DriverFullName

		if values.HasProp("Session") {
			this.iSession := values.Session

			if (this.Session == kSessionFinished) {
				this.iTeamSession := false

				this.iSessionDuration := 0
				this.iSessionLaps := 0

				this.iBaseLap := false
				this.iInitialFuelAmount := 0
			}
		}

		if values.HasProp("TeamSession")
			this.iTeamSession := values.TeamSession
	}

	updateDynamicValues(values) {
		if values.HasProp("KnowledgeBase")
			this.iKnowledgeBase := values.KnowledgeBase

		if values.HasProp("OverallTime")
			this.iOverallTime := values.OverallTime

		if values.HasProp("BestLapTime")
			this.iBestLapTime := values.BestLapTime

		if values.HasProp("BaseLap")
			this.iBaseLap := values.BaseLap

		if values.HasProp("LastFuelAmount")
			this.iLastFuelAmount := values.LastFuelAmount

		if values.HasProp("InitialFuelAmount")
			this.iInitialFuelAmount := values.InitialFuelAmount

		if values.HasProp("AvgFuelConsumption")
			this.iAvgFuelConsumption := values.AvgFuelConsumption

		if values.HasProp("EnoughData")
			this.iEnoughData := values.EnoughData
	}

	handleVoiceCommand(grammar, words) {
		local continuation

		switch grammar, false {
			case "Time":
				this.timeRecognized(words)
			case "Yes":
				continuation := this.Continuation

				this.clearContinuation()

				if isInstance(continuation, VoiceManager.VoiceContinuation)
					continuation.next()
				else if continuation {
					this.getSpeaker().speakPhrase("Confirm")

					continuation.Call()
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
				throw "Unknown grammar `"" . grammar . "`" detected in RaceAssistant.handleVoiceCommand...."
		}
	}

	timeRecognized(words) {
		local time

		time := FormatTime(A_Now, "Time")

		this.getSpeaker().speakPhrase("Time", {time: time})
	}

	activateAnnouncement(words, active) {
		local speaker := this.getSpeaker()
		local fragments := speaker.Fragments
		local announcements := []
		local key, value, announcement, score, ignore, fragment, fragmentScore

		if isInstance(this.Announcements, Map) {
			for key, value in this.Announcements
				announcements.Push(key)
		}
		else
			for key, value in this.Announcements.OwnProps()
				announcements.Push(key)

		announcement := false
		score := 0

		for ignore, fragment in announcements
			if fragments.Has(fragment) {
				fragmentScore := matchFragment(words, fragments[fragment])

				if (fragmentScore > score) {
					announcement := fragment
					score := fragmentScore
				}
			}

		if (score > 0.5) {
			speaker.speakPhrase(active ? "ConfirmAnnouncementOn" : "ConfirmAnnouncementOff", {announcement: fragments[announcement]}, true)

			this.setContinuation(VoiceManager.ReplyContinuation(this, ObjBindMethod(this, "updateAnnouncement", announcement, active), "Roger", "Okay"))
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
		/*
		else if this.VoiceManager
			this.VoiceManager.recognizeCommand("Yes", ["Yes"])
		*/
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
		/*
		else if this.VoiceManager
			this.VoiceManager.recognizeCommand("No", ["No"])
		*/
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

		rnd := Random(0, 4)

		hasJoke := (rnd > 1)

		if hasJoke
			if (this.VoiceManager.Language = "EN") {
				try {
					Download("https://api.chucknorris.io/jokes/random", kTempDirectory . "joke.json")

					joke := FileRead(kTempDirectory . "joke.json")

					joke := JSON.parse(joke)

					speaker := this.getSpeaker()

					speaker.beginTalk()

					try {
						speaker.speakPhrase("Joke")

						speaker.speak(joke["value"])
					}
					finally {
						speaker.endTalk()
					}
				}
				catch Any as exception {
					logError(exception, true, true)

					hasJoke := false
				}
			}
			else if (this.VoiceManager.Language = "DE") {
				try {
					Download("http://www.hahaha.de/witze/zufallswitz.js.php", kTempDirectory . "joke.json")

					joke := FileRead(kTempDirectory . "joke.json")

					html := ComObject("HtmlFile")

					html.write(joke)

					joke := html.documentElement.innerText

					joke := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(joke, "document.writeln('", ""), "`n", " "), "\", ""), "`"", ""), "`r", " ")

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
				catch Any as exception {
					logError(exception, true, true)

					hasJoke := false
				}
			}
			else
				hasJoke := false

		if !hasJoke
			this.getSpeaker().speakPhrase("NoJoke")
	}

	isNumber(word, &number) {
		local fragments, index, fragment

		static numberFragmentsLookup := false

		if isNumber(word) {
			number := word

			return true
		}
		else {
			if !numberFragmentsLookup {
				fragments := this.getSpeaker().Fragments

				numberFragmentsLookup := CaseInsenseMap()

				for index, fragment in ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"]
					numberFragmentsLookup[fragment] := index - 1
			}

			if numberFragmentsLookup.Has(word) {
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
			this.VoiceManager.setContinuation(VoiceManager.ReplyContinuation(this, continuation, "Confirm", "Okay"))
	}

	clearContinuation() {
		this.VoiceManager.clearContinuation()
	}

	createKnowledgeBase(facts := false) {
		local compiler := RuleCompiler()
		local rules, productions, reductions, engine, knowledgeBase, ignore, compound, compoundColor

		rules := FileRead(getFileName(this.AssistantType . ".rules", kUserRulesDirectory, kRulesDirectory))

		productions := false
		reductions := false

		compiler.compileRules(rules, &productions, &reductions)

		engine := RuleEngine(productions, reductions, facts)

		knowledgeBase := RaceAssistant.RaceKnowledgeBase(this, engine, engine.createFacts(), engine.createRules())

		for ignore, compound in SessionDatabase.getTyreCompounds(knowledgeBase.getValue("Session.Simulator")
															   , knowledgeBase.getValue("Session.Car")
															   , knowledgeBase.getValue("Session.Track")) {
			compoundColor := false

			splitCompound(compound, &compound, &compoundColor)

			knowledgeBase.addRule(compiler.compileRule("availableTyreCompound(" . compound . "," . compoundColor . ")"))
		}

		if this.Debug[kDebugRules]
			this.dumpRules(knowledgeBase)

		return knowledgeBase
	}

	setDebug(option, enabled, *) {
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
					SupportMenu.Check(label)
				else
					SupportMenu.Uncheck(label)
		}
		catch Any as exception {
			logError(exception, false, false)
		}
	}

	toggleDebug(option, *) {
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

	callPrepareSession(settings, data) {
		if (settings && !isObject(settings))
			settings := readMultiMap(settings)

		if (data && !isObject(data))
			data := readMultiMap(data)
		else if !data
			data := newMultiMap()

		this.prepareSession(&settings, &data)
	}

	prepareSession(&settings, &data) {
		local simulator, simulatorName, session, driverForname, driverSurname, driverNickname

		if settings
			this.updateConfigurationValues({Settings: settings})

		settings := this.Settings

		simulator := getMultiMapValue(data, "Session Data", "Simulator", "Unknown")
		simulatorName := this.SettingsDatabase.getSimulatorName(simulator)

		switch getMultiMapValue(data, "Session Data", "Session", "Practice"), false {
			case "Practice":
				session := kSessionPractice
			case "Qualification":
				session := kSessionQualification
			case "Race":
				session := kSessionRace
			default:
				session := kSessionOther
		}

		driverForname := getMultiMapValue(data, "Stint Data", "DriverForname", this.DriverForName)
		driverSurname := getMultiMapValue(data, "Stint Data", "DriverSurname", "Doe")
		driverNickname := getMultiMapValue(data, "Stint Data", "DriverNickname", "JDO")

		this.updateSessionValues({Simulator: simulatorName, Session: session, TeamSession: (getMultiMapValue(data, "Session Data", "Mode", "Solo") = "Team")
								, SessionTime: A_Now, Driver: driverForname, DriverFullName: computeDriverName(driverForName, driverSurName, driverNickName)})
	}

	initializeSessionFormat(facts, settings, data, lapTime) {
		local sessionFormat := getMultiMapValue(data, "Session Data", "SessionFormat", "Time")
		local sessionTimeRemaining := getDeprecatedValue(data, "Session Data", "Stint Data", "SessionTimeRemaining", 0)
		local sessionLapsRemaining := getDeprecatedValue(data, "Session Data", "Stint Data", "SessionLapsRemaining", 0)
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
		else if (dataDuration > 0)
			duration := dataDuration

		if isInstance(facts, KnowledgeBase) {
			if (facts.getValue("Session.Duration", 0) == 0)
				facts.setValue("Session.Duration", duration)

			if (facts.getValue("Session.Laps", 0) == 0)
				facts.setValue("Session.Laps", laps)

			facts.setValue("Session.Format", sessionFormat)
		}
		else {
			if (!facts.Has("Session.Duration") || (facts["Session.Duration"] == 0))
				facts["Session.Duration"] := duration

			if (!facts.Has("Session.Laps") || (facts["Session.Laps"] == 0))
				facts["Session.Laps"] := laps

			facts["Session.Format"] := sessionFormat
		}

		this.updateSessionValues({SessionDuration: duration * 1000, SessionLaps: laps, TeamSession: (getMultiMapValue(data, "Session Data", "Mode", "Solo") = "Team")})
	}

	readSettings(simulator, car, track, &settings) {
		if !isObject(settings)
			settings := readMultiMap(settings)

		return CaseInsenseMap("Session.Simulator", simulator
							, "Session.Car", car
							, "Session.Track", track
							, "Session.Settings.Lap.Formation", getDeprecatedValue(settings, "Session Settings", "Race Settings", "Lap.Formation", true)
						    , "Session.Settings.Lap.PostRace", getDeprecatedValue(settings, "Session Settings", "Race Settings", "Lap.PostRace", true)
						    , "Session.Settings.Lap.AvgTime", getDeprecatedValue(settings, "Session Settings", "Race Settings", "Lap.AvgTime", 0)
						    , "Session.Settings.Lap.PitstopWarning", getDeprecatedValue(settings, "Session Settings", "Race Settings", "Lap.PitstopWarning", 5)
							, "Session.Settings.Fuel.AvgConsumption", getDeprecatedValue(settings, "Session Settings", "Race Settings", "Fuel.AvgConsumption", 0)
							, "Session.Settings.Fuel.SafetyMargin", getDeprecatedValue(settings, "Session Settings", "Race Settings", "Fuel.SafetyMargin", 5))
	}

	updateSettings(settings) {
		local knowledgeBase := this.KnowledgeBase
		local facts, key, value

		if knowledgeBase
			for key, value in this.readSettings(knowledgeBase.getValue("Session.Simulator"), knowledgeBase.getValue("Session.Car")
											  , knowledgeBase.getValue("Session.Track"), &settings)
				knowledgeBase.setFact(key, value)
	}

	createSession(&settings, &data) {
		local configuration, simulator, simulatorName, session, driverForname, driverSurname, driverNickname
		local lapTime, settingsLapTime, facts

		if (settings && !isObject(settings))
			settings := readMultiMap(settings)

		if (data && !isObject(data))
			data := readMultiMap(data)

		if settings
			this.updateConfigurationValues({Settings: settings})

		configuration := this.Configuration
		settings := this.Settings

		simulator := getMultiMapValue(data, "Session Data", "Simulator", "Unknown")
		simulatorName := this.SettingsDatabase.getSimulatorName(simulator)

		switch getMultiMapValue(data, "Session Data", "Session", "Practice"), false {
			case "Practice":
				session := kSessionPractice
			case "Qualification":
				session := kSessionQualification
			case "Race":
				session := kSessionRace
			default:
				session := kSessionOther
		}

		driverForname := getMultiMapValue(data, "Stint Data", "DriverForname", this.DriverForName)
		driverSurname := getMultiMapValue(data, "Stint Data", "DriverSurname", "Doe")
		driverNickname := getMultiMapValue(data, "Stint Data", "DriverNickname", "JDO")

		this.updateSessionValues({Simulator: simulatorName, Session: session, TeamSession: (getMultiMapValue(data, "Session Data", "Mode", "Solo") = "Team")
								, SessionTime: A_Now, Driver: driverForname, DriverFullName: computeDriverName(driverForName, driverSurName, driverNickName)})

		lapTime := getMultiMapValue(data, "Stint Data", "LapLastTime", 0)

		if this.AdjustLapTime {
			settingsLapTime := (getDeprecatedValue(settings, "Session Settings", "Race Settings", "Lap.AvgTime", lapTime / 1000) * 1000)

			if ((lapTime / settingsLapTime) > 1.2)
				lapTime := settingsLapTime
		}

		facts := combine(this.readSettings(simulator, getMultiMapValue(data, "Session Data", "Car", ""), getMultiMapValue(data, "Session Data", "Track", ""), &settings)
					   , CaseInsenseMap("Session.Type", this.Session
									  , "Session.Time.Remaining", getDeprecatedValue(data, "Session Data", "Stint Data", "SessionTimeRemaining", 0)
									  , "Session.Lap.Remaining", getDeprecatedValue(data, "Session Data", "Stint Data", "SessionLapsRemaining", 0)
									  , "Session.Settings.Lap.Time.Adjust", this.AdjustLapTime
									  , "Session.Settings.Fuel.Max", getMultiMapValue(data, "Session Data", "FuelAmount", 0)))

		this.initializeSessionFormat(facts, settings, data, lapTime)

		return facts
	}

	callStartSession(settings, data) {
		if (settings && !isObject(settings))
			settings := readMultiMap(settings)

		if (data && !isObject(data))
			data := readMultiMap(data)

		this.startSession(settings, data)
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
			sessionState := readMultiMap(stateFile)

			deleteFile(stateFile)

			this.loadSessionState(sessionState)
		}

		if settingsFile {
			sessionSettings := readMultiMap(settingsFile)

			deleteFile(settingsFile)

			this.loadSessionSettings(sessionSettings)
		}
	}

	createSessionState() {
		local savedKnowledgeBase := newMultiMap()

		setMultiMapValues(savedKnowledgeBase, "Session State", this.KnowledgeBase.Facts.Facts)

		return savedKnowledgeBase
	}

	createSessionSettings() {
		return this.Settings
	}

	loadSessionState(state) {
		local knowledgeBase := this.KnowledgeBase

		knowledgeBase.Facts.Facts := getMultiMapValues(state, "Session State")

		this.updateSessionValues({SessionDuration: knowledgeBase.getValue("Session.Duration") * 1000
								, SessionLaps: knowledgeBase.getValue("Session.Laps")})
		this.updateDynamicValues({LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
	}

	loadSessionSettings(settings) {
		this.updateSettings(settings)

		this.updateConfigurationValues({Settings: settings})
	}

	prepareData(lapNumber, data) {
		if !this.KnowledgeBase
			this.startSession(this.Settings, data)

		return data
	}

	callAddLap(lapNumber, data) {
		if this.KnowledgeBase {
			if !isObject(data)
				data := readMultiMap(data)

			this.addLap(lapNumber, &data)
		}
	}

	addLap(lapNumber, &data, dump := true, lapValid := kUndefined, lapPenalty := kUndefined) {
		local knowledgeBase := this.KnowledgeBase
		local adjustedLapTime := false
		local driverForname, driverSurname, driverNickname, tyreSet, timeRemaining, airTemperature, trackTemperature
		local weatherNow, weather10Min, weather30Min, lapTime, settingsLapTime, overallTime, values, result, baseLap, enoughData
		local fuelRemaining, avgFuelConsumption, tyrePressures, tyreTemperatures, tyreWear, brakeTemperatures, brakeWear, key

		if (knowledgeBase && (knowledgeBase.getValue("Lap", 0) == lapNumber))
			return false

		data := this.prepareData(lapNumber, data)

		knowledgeBase := this.KnowledgeBase

		knowledgeBase.setFact("Lap", lapNumber)

		if !this.InitialFuelAmount
			baseLap := lapNumber
		else
			baseLap := this.BaseLap

		if (lapNumber > (this.LastLap + 1))
			enoughData := false
		else
			enoughData := (lapNumber > (baseLap + (this.LearningLaps - 1)))

		this.iLastLap := lapNumber

		this.updateDynamicValues({EnoughData: enoughData})

		knowledgeBase.setFact("Session.Time.Remaining", getDeprecatedValue(data, "Session Data", "Stint Data", "SessionTimeRemaining", 0))
		knowledgeBase.setFact("Session.Lap.Remaining", getDeprecatedValue(data, "Session Data", "Stint Data", "SessionLapsRemaining", 0))

		driverForname := getMultiMapValue(data, "Stint Data", "DriverForname", this.DriverForName)
		driverSurname := getMultiMapValue(data, "Stint Data", "DriverSurname", "Doe")
		driverNickname := getMultiMapValue(data, "Stint Data", "DriverNickname", "JDO")

		this.updateSessionValues({Driver: driverForname, DriverFullName: computeDriverName(driverForname, driverSurname, driverNickname)
								, TeamSession: (getMultiMapValue(data, "Session Data", "Mode", "Solo") = "Team")})

		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Forname", driverForname)
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Surname", driverSurname)
		knowledgeBase.addFact("Lap." . lapNumber . ".Driver.Nickname", driverNickname)

		knowledgeBase.setFact("Driver.Forname", driverForname)
		knowledgeBase.setFact("Driver.Surname", driverSurname)
		knowledgeBase.setFact("Driver.Nickname", driverNickname)

		knowledgeBase.addFact("Lap." . lapNumber . ".Map", getMultiMapValue(data, "Car Data", "Map", "n/a"))
		knowledgeBase.addFact("Lap." . lapNumber . ".TC", getMultiMapValue(data, "Car Data", "TC", "n/a"))
		knowledgeBase.addFact("Lap." . lapNumber . ".ABS", getMultiMapValue(data, "Car Data", "ABS", "n/a"))

		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Compound", getMultiMapValue(data, "Car Data", "TyreCompound", "Dry"))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Compound.Color", getMultiMapValue(data, "Car Data", "TyreCompoundColor", "Black"))

		tyreSet := getMultiMapValue(data, "Car Data", "TyreSet", kUndefined)

		if (tyreSet != kUndefined)
			knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Set", tyreSet)

		timeRemaining := getDeprecatedValue(data, "Session Data", "Stint Data", "SessionTimeRemaining", 0)

		knowledgeBase.setFact("Driver.Time.Remaining", getMultiMapValue(data, "Stint Data", "DriverTimeRemaining", timeRemaining))
		knowledgeBase.setFact("Driver.Time.Stint.Remaining", getMultiMapValue(data, "Stint Data", "StintTimeRemaining", timeRemaining))

		airTemperature := Round(getMultiMapValue(data, "Weather Data", "Temperature", 0))
		trackTemperature := Round(getMultiMapValue(data, "Track Data", "Temperature", 0))

		if (airTemperature = 0)
			airTemperature := Round(getMultiMapValue(data, "Car Data", "AirTemperature", 0))

		if (trackTemperature = 0)
			trackTemperature := Round(getMultiMapValue(data, "Car Data", "RoadTemperature", 0))

		knowledgeBase.setFact("InPitlane", getMultiMapValue(data, "Stint Data", "InPitlane", false))
		knowledgeBase.setFact("InPit", getMultiMapValue(data, "Stint Data", "InPit", false))

		weatherNow := getMultiMapValue(data, "Weather Data", "Weather", "Dry")
		weather10Min := getMultiMapValue(data, "Weather Data", "Weather10Min", "Dry")
		weather30Min := getMultiMapValue(data, "Weather Data", "Weather30Min", "Dry")

		knowledgeBase.setFact("Weather.Temperature.Air", airTemperature)
		knowledgeBase.setFact("Weather.Temperature.Track", trackTemperature)
		knowledgeBase.setFact("Weather.Weather.Now", weatherNow)
		knowledgeBase.setFact("Weather.Weather.10Min", weather10Min)
		knowledgeBase.setFact("Weather.Weather.30Min", weather30Min)

		lapTime := getMultiMapValue(data, "Stint Data", "LapLastTime", 0)

		if (lapNumber <= 2) {
			if this.AdjustLapTime {
				settingsLapTime := (getDeprecatedValue(this.Settings, "Session Settings", "Race Settings", "Lap.AvgTime", lapTime / 1000) * 1000)

				if ((lapTime / settingsLapTime) > 1.2) {
					lapTime := settingsLapTime

					adjustedLapTime := true
				}
			}

			if ((knowledgeBase.getValue("Session.Duration", 0) == 0) || (knowledgeBase.getValue("Session.Laps", 0) == 0))
				this.initializeSessionFormat(knowledgeBase, this.Settings, data, lapTime)
		}

		overallTime := ((lapNumber = 1) ? 0 : knowledgeBase.getValue("Lap." . (lapNumber - 1) . ".Time.End", 0))

		if (lapValid = kUndefined)
			lapValid := getMultiMapValue(data, "Stint Data", "LapValid", true)

		if (lapPenalty = kUndefined)
			lapPenalty := getMultiMapValue(data, "Stint Data", "Penalty", false)

		knowledgeBase.setFact("Lap.Valid", lapValid)
		knowledgeBase.setFact("Lap.Penalty", lapPenalty)
		knowledgeBase.setFact("Lap.Warnings", getMultiMapValue(data, "Stint Data", "Warnings", 0))

		key := ("Lap." . lapNumber . ".Valid")

		if ((knowledgeBase.getValue(key, kUndefined) == kUndefined) || (knowledgeBase.getValue(key, true) && !lapValid))
			knowledgeBase.setFact(key, lapValid)

		key := ("Lap." . lapNumber . ".Penalty")

		if ((knowledgeBase.getValue(key, kUndefined) == kUndefined) || (!knowledgeBase.getValue(key, false) && lapPenalty))
			knowledgeBase.setFact(key, lapPenalty)

		knowledgeBase.addFact("Lap." . lapNumber . ".Warnings", getMultiMapValue(data, "Stint Data", "Warnings", 0))

		knowledgeBase.addFact("Lap." . lapNumber . ".Time", lapTime)
		knowledgeBase.addFact("Lap." . lapNumber . ".Time.Start", overallTime)

		overallTime := (overallTime + lapTime)

		values := {OverallTime: overallTime}

		if (lapTime > 0) {
			if ((lapNumber > this.LearningLaps) && lapValid && !adjustedLapTime)
				values.BestLapTime := (this.BestLapTime = 0) ? lapTime : Min(this.BestLapTime, lapTime)

			this.updateDynamicValues(values)
		}

		knowledgeBase.addFact("Lap." . lapNumber . ".Time.End", overallTime)

		fuelRemaining := getMultiMapValue(data, "Car Data", "FuelRemaining", 0)

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

		tyrePressures := string2Values(",", getMultiMapValue(data, "Car Data", "TyrePressure", ""))

		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.FL", Round(tyrePressures[1], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.FR", Round(tyrePressures[2], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.RL", Round(tyrePressures[3], 2))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Pressure.RR", Round(tyrePressures[4], 2))

		tyreTemperatures := string2Values(",", getMultiMapValue(data, "Car Data", "TyreTemperature", ""))

		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.FL", Round(tyreTemperatures[1], 1))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.FR", Round(tyreTemperatures[2], 1))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.RL", Round(tyreTemperatures[3], 1))
		knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Temperature.RR", Round(tyreTemperatures[4], 1))

		tyreWear := getMultiMapValue(data, "Car Data", "TyreWear", "")

		if (tyreWear != "") {
			tyreWear := string2Values(",", tyreWear)

			knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Wear.FL", Round(tyreWear[1]))
			knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Wear.FR", Round(tyreWear[2]))
			knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Wear.RL", Round(tyreWear[3]))
			knowledgeBase.addFact("Lap." . lapNumber . ".Tyre.Wear.RR", Round(tyreWear[4]))
		}

		brakeTemperatures := string2Values(",", getMultiMapValue(data, "Car Data", "BrakeTemperature", ""))

		if (brakeTemperatures.Length > 0) {
			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Temperature.FL", Round(brakeTemperatures[1] / 10) * 10)
			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Temperature.FR", Round(brakeTemperatures[2] / 10) * 10)
			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Temperature.RL", Round(brakeTemperatures[3] / 10) * 10)
			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Temperature.RR", Round(brakeTemperatures[4] / 10) * 10)
		}

		brakeWear := getMultiMapValue(data, "Car Data", "BrakeWear", "")

		if (brakeWear != "") {
			brakeWear := string2Values(",", brakeWear)

			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Wear.FL", Round(brakeWear[1], 1))
			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Wear.FR", Round(brakeWear[2], 1))
			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Wear.RL", Round(brakeWear[3], 1))
			knowledgeBase.addFact("Lap." . lapNumber . ".Brake.Wear.RR", Round(brakeWear[4], 1))
		}

		knowledgeBase.addFact("Lap." . lapNumber . ".Weather", weatherNow)
		knowledgeBase.addFact("Lap." . lapNumber . ".Grip", getMultiMapValue(data, "Track Data", "Grip", "Green"))
		knowledgeBase.addFact("Lap." . lapNumber . ".Temperature.Air", airTemperature)
		knowledgeBase.addFact("Lap." . lapNumber . ".Temperature.Track", trackTemperature)

		result := knowledgeBase.produce()

		if (dump && this.Debug[kDebugKnowledgeBase])
			this.dumpKnowledgeBase(this.KnowledgeBase)

		return result
	}

	callUpdateLap(lapNumber, data) {
		if this.KnowledgeBase {
			if !isObject(data)
				data := readMultiMap(data)

			this.updateLap(lapNumber, &data)
		}
	}

	updateLap(lapNumber, &data, dump := true, lapValid := kUndefined, lapPenalty := kUndefined) {
		local knowledgeBase := this.KnowledgeBase
		local result

		if (lapNumber > this.LastLap)
			this.updateDynamicValues({EnoughData: false})

		data := this.prepareData(lapNumber, data)

		if (lapValid = kUndefined)
			lapValid := getMultiMapValue(data, "Stint Data", "LapValid", true)

		if (lapPenalty = kUndefined)
			lapPenalty := getMultiMapValue(data, "Stint Data", "Penalty", false)

		knowledgeBase.setFact("Lap.Valid", lapValid)
		knowledgeBase.setFact("Lap.Penalty", lapPenalty)
		knowledgeBase.setFact("Lap.Warnings", getMultiMapValue(data, "Stint Data", "Warnings", 0))

		result := knowledgeBase.produce()

		if (dump && this.Debug[kDebugKnowledgeBase])
			this.dumpKnowledgeBase(knowledgeBase)

		return result
	}

	performPitstop(lapNumber := false, optionsFile := false) {
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

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(knowledgeBase)

		return result
	}

	finishPitstop(lapNumber) {
		local settingsFile, stateFile

		if this.RemoteHandler {
			settingsFile := temporaryFileName(this.AssistantType, "settings")
			stateFile := temporaryFileName(this.AssistantType, "state")

			writeMultiMap(settingsFile, this.createSessionSettings())
			writeMultiMap(stateFile, this.createSessionState())

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

			oldValue := getMultiMapValue(this.Configuration, "Race Engineer Startup", simulator . ".LoadSettings", "Default")
			loadSettings := getMultiMapValue(this.Configuration, "Race Assistant Startup", simulator . ".LoadSettings", oldValue)

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

				settings := readMultiMap(fileName)

				if (this.AvgFuelConsumption > 0)
					setMultiMapValue(settings, "Session Settings", "Fuel.AvgConsumption", Round(this.AvgFuelConsumption, 2))

				if (lapTime > 10)
					setMultiMapValue(settings, "Session Settings", "Lap.AvgTime", Round(lapTime, 1))

				writeMultiMap(fileName, settings)
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

class GridRaceAssistant extends RaceAssistant {
	MultiClass[data := false] {
		Get {
			static knowledgeBase := false
			static multiClass := false

			if (!knowledgeBase || (knowledgeBase != this.KnowledgeBase)) {
				knowledgaBase := this.KnowledgeBase

				multiClass := (this.getClasses(data).Length > 1)
			}

			return multiClass
		}
	}

	getClasses(data := false) {
		local knowledgebase := this.Knowledgebase
		local class

		static classes := false
		static lastKnowledgeBase := false

		if (data || !lastKnowledgeBase || (lastKnowledgebase != knowledgeBase) || !classes) {
			classes := CaseInsenseMap()

			loop (data ? getMultiMapValue(data, "Position Data", "Car.Count") : knowledgeBase.getValue("Car.Count"))
				if (data || knowledgeBase.getValue("Car." . A_Index . ".Car", false)) {
					class := (data ? getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class", kUnknown)
								   : knowledgeBase.getValue("Car." . A_Index . ".Class", kUnknown))

					if !classes.Has(class)
						classes[class] := true
				}

			lastKnowledgeBase := (data ? false : knowledgeBase)

			classes := getKeys(classes)
		}

		return classes
	}

	getClass(car := false, data := false) {
		if !car
			car := (data ? getMultiMapValue(data, "Position Data", "Driver.Car") : this.KnowledgeBase.getValue("Driver.Car", false))

		if data
			return getMultiMapValue(data, "Position Data", "Car." . car . ".Class", kUnknown)
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
					loop getMultiMapValue(data, "Position Data", "Car.Count")
						if (!class || (class = getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class", kUnknown)))
							positions.Push(Array(A_Index, getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Position")))
				}
				else
					loop knowledgeBase.getValue("Car.Count")
						if (!class || (class = knowledgeBase.getValue("Car." . A_Index . ".Class", kUnknown)))
							if knowledgeBase.getValue("Car." . A_Index . ".Car", false)
								positions.Push(Array(A_Index, knowledgeBase.getValue("Car." . A_Index . ".Position")))

				bubbleSort(&positions, compareClassPositions)

				for ignore, position in positions
					classGrid.Push(position[1])
			}
			else {
				if data {
					loop getMultiMapValue(data, "Position Data", "Car.Count")
						if (!class || (class = getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Class", kUnknown)))
							classGrid.Push(A_Index)
				}
				else
					loop knowledgeBase.getValue("Car.Count")
						if (!class || (class = knowledgeBase.getValue("Car." . A_Index . ".Class", kUnknown)))
							if knowledgeBase.getValue("Car." . A_Index . ".Car", false)
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
					return getMultiMapValue(data, "Position Data", "Car." . getMultiMapValue(data, "Position Data", "Driver.Car") . ".Position", false)
				else
					return knowledgeBase.getValue("Position", 0)
			}
			else
				car := (data ? getMultiMapValue(data, "Position Data", "Driver.Car") : knowledgeBase.getValue("Driver.Car", false))
		}

		if ((type != "Overall") && this.MultiClass[data]) {
			for position, candidate in this.getCars(data ? getMultiMapValue(data, "Position Data", "Car." . car . ".Class", kUnknown)
														 : knowledgeBase.getValue("Car." . car . ".Class", kUnknown)
												  , data, true)
				if (candidate = car)
					return position
		}

		if data
			return getMultiMapValue(data, "Position Data", "Car." . car . ".Position", car)
		else
			return knowledgeBase.getValue("Car." . car . ".Position", car)
	}

	prepareData(lapNumber, data) {
		local knowledgeBase, key, value

		data := super.prepareData(lapNumber, data)

		knowledgeBase := this.KnowledgeBase

		for key, value in getMultiMapValues(data, "Position Data")
			knowledgeBase.setFact(key, value)

		return data
	}

	addLap(lapNumber, &data) {
		local driver, lapValid, lapPenalty

		driver := getMultiMapValue(data, "Position Data", "Driver.Car", false)

		lapValid := getMultiMapValue(data, "Stint Data", "LapValid", true)
		lapPenalty := getMultiMapValue(data, "Stint Data", "Penalty", false)

		if (driver && (getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap", false) = lapNumber)) {
			lapValid := getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap.Valid", lapValid)
			lapPenalty := getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap.Penalty", lapPenalty)
		}

		return super.addLap(lapNumber, &data, true, lapValid, lapPenalty)
	}

	updateLap(lapNumber, &data) {
		local knowledgeBase := this.KnowledgeBase
		local driver, lapValid, lapPenalty, result

		driver := getMultiMapValue(data, "Position Data", "Driver.Car", false)
		lapValid := getMultiMapValue(data, "Stint Data", "LapValid", true)
		lapPenalty := getMultiMapValue(data, "Stint Data", "Penalty", false)

		if (driver && (getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap", false) = lapNumber)) {
			lapValid := getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap.Running.Valid", lapValid)
			lapPenalty := getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap.Running.Penalty", lapPenalty)
		}

		if !lapValid
			knowledgeBase.setFact("Lap." . (lapNumber + 1) . ".Valid", false)

		if lapPenalty
			knowledgeBase.setFact("Lap." . (lapNumber + 1) . ".Penalty", lapPenalty)

		result := super.updateLap(lapNumber, &data, false, lapValid, lapPenalty)

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(knowledgeBase)

		return result
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

parseList(list) {
	local compiler := RuleCompiler()
	local nextCharIndex := 1
	local term := compiler.readList(&list, &nextCharIndex)

	return compiler.createTermParser(term).parse(term).toObject()
}

getDeprecatedValue(data, newSection, oldSection, key, default := false) {
	local value := getMultiMapValue(data, newSection, key, kUndefined)

	if (value != kUndefined)
		return value
	else
		return getMultiMapValue(data, oldSection, key, default)
}


;;;-------------------------------------------------------------------------;;;
;;;                  Internal Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

compareClassPositions(c1, c2) {
	local pos1 := c1[2]
	local pos2 := c2[2]

	if !isNumber(pos1)
		pos1 := 999

	if !isNumber(pos2)
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

	return (score / fragmentWords.Length)
}