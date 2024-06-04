;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Race Assistant               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\JSON.ahk"
#Include "..\..\Libraries\Task.ahk"
#Include "..\..\Libraries\RuleEngine.ahk"
#Include "VoiceManager.ahk"
#Include "LLMBooster.ahk"
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
	iSettings := newMultiMap()
	iVoiceManager := false

	iBooster := false

	iAnnouncements := CaseInsenseMap()

	iAutonomy := "Custom"

	iRemoteHandler := false

	iSessionTime := false

	iSimulator := ""
	iCar := ""
	iTrack := ""

	iSession := kSessionFinished
	iTeamSession := false

	iDriverForName := "John"
	iDriverFullName := "John Doe (JD)"

	iLearningLaps := 1

	iPrepared := false
	iKnowledgeBase := false

	iTrackLength := 0

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

	class VariablesMap extends CaseInsenseWeakMap {
		has(*) {
			return true
		}
	}

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

		savePitstopState(arguments*) {
			this.callRemote("savePitstopState", arguments*)
		}

		saveSessionState(arguments*) {
			this.callRemote("callSaveSessionState", arguments*)
		}

		saveLapState(arguments*) {
			this.callRemote("callSaveLapState", arguments*)
		}

		saveSessionInfo(arguments*) {
			this.callRemote("saveSessionInfo", arguments*)
		}
	}

	class RaceVoiceManager extends VoiceManager {
		iRaceAssistant := false

		class VoiceGrammars extends MultiMap {
			include(path, directory?) {
				local fileName, include

				if FileExist(path)
					super.include(path, directory?)
				else {
					SplitPath(path, &fileName)

					include := getFileName(fileName, kGrammarsDirectory)

					if (include && FileExist(include))
						super.include(include, directory?)

					include := getFileName(fileName, kUserGrammarsDirectory)

					if (include && FileExist(include))
						super.include(include, directory?)
				}
			}
		}

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

			super.__New(name, raceAssistant.Configuration, options)
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

			grammars := readMultiMap(kGrammarsDirectory . fileName, RaceAssistant.RaceVoiceManager.VoiceGrammars)

			addMultiMapValues(grammars, readMultiMap(kUserGrammarsDirectory . fileName, RaceAssistant.RaceVoiceManager.VoiceGrammars))

			if isDebug()
				writeMultiMap(kTempDirectory . fileName, grammars)

			return grammars
		}

		handleVoiceCommand(phrase, words) {
			this.RaceAssistant.handleVoiceCommand(phrase, words)
		}

		handleVoiceText(phrase, text) {
			this.RaceAssistant.handleVoiceText(phrase, text)
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

	Options[key?] {
		Get {
			return (isSet(key) ? this.iOptions[key] : this.iOptions)
		}

		Set {
			return (isSet(key) ? (this.iOptions[key] := value) : (this.iOptions := value))
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

	Autonomy {
		Get {
			return this.iAutonomy
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

	Booster {
		Get {
			return this.iBooster
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

	Car {
		Get {
			return this.iCar
		}
	}

	Track {
		Get {
			return this.iTrack
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

	Prepared {
		Get {
			return this.iPrepared
		}
	}

	KnowledgeBase {
		Get {
			return this.iKnowledgeBase
		}
	}

	Knowledge {
		Get {
			static knowledge := ["Session", "Stint", "Fuel", "Weather", "Track", "Tyres"]

			return knowledge
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

	TrackLength {
		Get {
			return this.iTrackLength
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
		, synthesizer := false, speaker := false, vocalics := false, speakerBooster := false
		, recognizer := false, listener := false, listenerBooster := false, conversationBooster := false, muted := false, voiceServer := false) {
		global kUnknown

		local userName := SessionDatabase.getUserName()
		local options, forName, ignore, booster, functions

		if !kUnknown
			kUnknown := translate("Unknown")

		parseDriverName(userName, &forName, &ignore := false, &ignore := false)

		this.iDriverForName := forName
		this.iDriverFullName := userName

		this.iAssistantType := assistantType
		this.iRemoteHandler := remoteHandler

		super.__New(configuration)

		options := this.Options

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

			options["SpeakerBooster"] := ((speakerBooster == true) ? options["SpeakerBooster"] : speakerBooster)
			options["ListenerBooster"] := ((listenerBooster == true) ? options["ListenerBooster"] : listenerBooster)
			options["ConversationBooster"] := ((conversationBooster == true) ? options["ConversationBooster"] : conversationBooster)
		}

		this.iVoiceManager := this.createVoiceManager(name, options)

		configuration := newMultiMap()

		setMultiMapValue(configuration, "Voice", "Speaker", this.Speaker[true])
		setMultiMapValue(configuration, "Voice", "Listener", this.Listener)
		setMultiMapValue(configuration, "Voice", "Muted", this.Muted)

		writeMultiMap(kTempDirectory . assistantType . ".state", configuration)

		if (this.Listener && options["ConversationBooster"]) {
			/*
			functions := "
			(
				[{
					"name": "planPitstop",
					"description": "Ask the Engineer to plan and prepare the next pitstop",
					"parameters": {
						"type": "object",
						"properties": {
							"lap": {
								"type": "integer",
								"description": "The lap at which the car has to come to the pit"
							}
						},
						"required": ["lap"]
					}
				}]
			)"

			functions := JSON.parse(functions)
			*/

			functions := []

			booster := ChatBooster(options["ConversationBooster"], this.Configuration, functions, this.VoiceManager.Language)

			if (booster.Model && booster.Active)
				this.iBooster := booster
		}

		if muted
			this.Muted := true
	}

	loadFromConfiguration(configuration) {
		local options

		super.loadFromConfiguration(configuration)

		options := this.Options

		options["Language"] := getMultiMapValue(configuration, "Voice Control", "Language", getLanguage())
		options["Synthesizer"] := getMultiMapValue(configuration, "Voice Control", "Synthesizer", getMultiMapValue(configuration, "Voice Control", "Service", "dotNET"))
		options["Speaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker", true)
		options["Vocalics"] := Array(getMultiMapValue(configuration, "Voice Control", "SpeakerVolume", 100)
								   , getMultiMapValue(configuration, "Voice Control", "SpeakerPitch", 0)
								   , getMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", 0))
		options["Recognizer"] := getMultiMapValue(configuration, "Voice Control", "Recognizer", "Desktop")
		options["Listener"] := getMultiMapValue(configuration, "Voice Control", "Listener", false)
		options["PushToTalk"] := getMultiMapValue(configuration, "Voice Control", "PushToTalk", false)
		options["PushToTalkMode"] := getMultiMapValue(configuration, "Voice Control", "PushToTalkMode", "Hold")

		if getMultiMapValue(configuration, "Conversation Booster", this.AssistantType . ".Speaker", true)
			options["SpeakerBooster"] := ((getMultiMapValue(configuration, "Conversation Booster", this.AssistantType . ".Model", kUndefined) != kUndefined) ? this.AssistantType : false)
		else
			options["SpeakerBooster"] := false

		if getMultiMapValue(configuration, "Conversation Booster", this.AssistantType . ".Listener", true)
			options["ListenerBooster"] := ((getMultiMapValue(configuration, "Conversation Booster", this.AssistantType . ".Model", kUndefined) != kUndefined) ? this.AssistantType : false)
		else
			options["ListenerBooster"] := false

		if getMultiMapValue(configuration, "Conversation Booster", this.AssistantType . ".Conversation", true)
			options["ConversationBooster"] := ((getMultiMapValue(configuration, "Conversation Booster", this.AssistantType . ".Model", kUndefined) != kUndefined) ? this.AssistantType : false)
		else
			options["ConversationBooster"] := false
	}

	createVoiceManager(name, options) {
		return RaceAssistant.RaceVoiceManager(this, name, options)
	}

	updateConfigurationValues(values) {
		if values.HasProp("Settings") {
			this.iSettings := values.Settings

			if !this.Settings
				this.iSettings := newMultiMap()
		}

		if values.HasProp("UseTalking")
			this.VoiceManager.UseTalking := values.UseTalking

		if values.HasProp("SaveSettings")
			this.iSaveSettings := values.SaveSettings

		if values.HasProp("LearningLaps")
			this.iLearningLaps := values.LearningLaps

		if values.HasProp("Announcements")
			this.iAnnouncements := toMap(values.Announcements, CaseInsenseMap)
	}

	updateSessionValues(values) {
		if values.HasProp("TrackLength")
			this.iTrackLength := values.TrackLength

		if values.HasProp("SessionDuration")
			this.iSessionDuration := values.SessionDuration

		if values.HasProp("SessionLaps")
			this.iSessionLaps := values.SessionLaps

		if values.HasProp("SessionTime")
			this.iSessionTime := values.SessionTime

		if values.HasProp("Simulator")
			this.iSimulator := values.Simulator

		if values.HasProp("Car")
			this.iCar := values.Car

		if values.HasProp("Track")
			this.iTrack := values.Track

		if values.HasProp("Driver")
			this.iDriverForName := values.Driver

		if values.HasProp("DriverFullName")
			this.iDriverFullName := values.DriverFullName

		if values.HasProp("Autonomy")
			this.iAutonomy := values.Autonomy

		if values.HasProp("Session") {
			this.iSession := values.Session

			if (this.Session == kSessionFinished) {
				this.iTeamSession := false

				this.iTrackLength := 0
				this.iSessionDuration := 0
				this.iSessionLaps := 0

				this.iBaseLap := false
				this.iInitialFuelAmount := 0

				this.iAutonomy := "Custom"

				this.updateConfigurationValues({Settings: newMultiMap()})
			}
		}

		if values.HasProp("TeamSession")
			this.iTeamSession := values.TeamSession
	}

	updateDynamicValues(values) {
		if values.HasProp("Prepared")
			this.iPrepared := values.Prepared

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

	activeTopic(options, topic) {
		local active

		if options {
			active := true

			if options.Has("include")
				active := inList(options["include"], topic)
			else
				active := inList(this.Knowledge, topic)

			if (active && options.Has("exclude"))
				active := !inList(options["exclude"], topic)

			if (active && options.Has("filter"))
				active := options["filter"].Call(topic)

			return active
		}
		else
			return inList(this.Knowledge, topic)
	}

	getKnowledge(options := false) {
		local knowledgeBase := this.KnowledgeBase
		local knowledge := Map()
		local lapNumber, tyreSet

		static sessionTypes

		if !isSet(sessionTypes) {
			sessionTypes := Map(kSessionPractice, "Practice", kSessionQualification, "Qualification", kSessionRace, "Race", kSessionOther, "Other")

			sessionTypes.Default := "Other"
		}

		if knowledgeBase {
			lapNumber := knowledgeBase.getValue("Lap", 0)

			if this.activeTopic(options, "Session")
				knowledge["Session"] := Map("Simulator", this.SettingsDatabase.getSimulatorName(this.Simulator)
										  , "Car", this.SettingsDatabase.getCarName(this.Simulator, this.Car)
										  , "Track", this.SettingsDatabase.getTrackName(this.Simulator, this.Track)
										  , "TrackLength", (this.TrackLength . " Meters")
										  , "Type", sessionTypes[this.Session]
										  , "Format", knowledgeBase.getValue("Session.Format", "Time")
										  , "RemainingLaps", Ceil(knowledgeBase.getValue("Lap.Remaining.Session", 0))
										  , "RemainingTime", (Round(knowledgeBase.getValue("Session.Time.Remaining") / 1000) . " seconds"))

			if this.activeTopic(options, "Stint")
				knowledge["Stint"] := Map("Driver", this.DriverFullName
										, "Lap", (lapNumber + 1)
										, "RemainingTime", (Round(Min(knowledgeBase.getValue("Driver.Time.Remaining"), knowledgeBase.getValue("Driver.Time.Stint.Remaining")) / 1000) . " Seconds"))

			if this.activeTopic(options, "Fuel")
				knowledge["Fuel"] := Map("Capacity", (knowledgeBase.getValue("Session.Settings.Fuel.Max") . " Liter")
									   , "Remaining", (Round(knowledgeBase.getValue("Lap." . lapNumber . ".Fuel.Remaining", 0), 1) . " Liter")
									   , "Consumption", (Round(knowledgeBase.getValue("Lap." . lapNumber . ".Fuel.AvgConsumption", 0), 1)  . " Liter"))

			if this.activeTopic(options, "Weather")
				knowledge["Weather"] := Map("Now", knowledgeBase.getValue("Weather.Weather.Now")
										  , "10Min", knowledgeBase.getValue("Weather.Weather.10Min")
										  , "30Min", knowledgeBase.getValue("Weather.Weather.30Min")
										  , "Temperature", (knowledgeBase.getValue("Weather.Temperature.Air") . " Celsius"))

			if this.activeTopic(options, "Track")
				knowledge["Track"] := Map("Temperature", (knowledgeBase.getValue("Track.Temperature") . " Celsius")
										, "Grip", knowledgeBase.getValue("Track.Grip"))

			if this.activeTopic(options, "Tyres") {
				knowledge["Tyres"] := Map("Compound", compound(knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Compound")
															 , knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Compound.Color")))

				tyreSet := knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Set", kUndefined)

				if ((tyreSet != kUndefined) && (tyreSet != 0))
					knowledge["Tyres"]["TyreSet"] := knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Set")
			}
		}

		return knowledge
	}

	handleVoiceText(grammar, text) {
		local ignore, part

		if (grammar = "Text") {
			if this.Booster {
				text := this.Booster.ask(text, Map("Variables", {assistant: this.AssistantType, name: this.VoiceManager.Name
															   , knowledge: JSON.print(this.getKnowledge(), "  ")}))

				if text {
					if this.VoiceManager.UseTalking
						this.getSpeaker().speak(text, false, false, {Noise: false, Rephrase: false})
					else
						for ignore, part in string2Values(". ", text)
							this.getSpeaker().speak(part . ".", false, false, {Rephrase: false, Click: (A_Index = 1)})

					return
				}
			}
		}

		if this.VoiceManager.Grammars.Has("?") {
			this.getSpeaker().speakPhrase("Repeat")

			return
		}

		throw "Unknown grammar `"" . grammar . "`" detected in RaceAssistant.handleVoiceText...."
	}

	requestInformation(category, arguments*) {
		switch category, false {
			case "Time":
				this.timeRecognized([])
			default:
				throw "Unknown information category `"" . category . "`" detected in RaceAssistant.requestInformation...."
		}
	}

	timeRecognized(words) {
		local time

		time := FormatTime(A_Now, "Time")

		this.getSpeaker().speakPhrase("Time", {time: time})
	}

	weatherRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local weather10Min := (knowledgeBase ? knowledgeBase.getValue("Weather.Weather.10Min", false) : false)

		if !weather10Min
			this.getSpeaker().speakPhrase("Later")
		else if (weather10Min = "Dry")
			this.getSpeaker().speakPhrase("WeatherGood")
		else
			this.getSpeaker().speakPhrase("WeatherRain")
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
		local joke, speaker, html, index, hasJoke

		hasJoke := (Random(0, 4) > 1)

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

	isInteger(word, &number) {
		if this.isNumber(word, &number)
			return isInteger(number)
		else
			return false
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
		setDebugAsync() {
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

		Task.startTask(setDebugAsync)
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

	prepareSession(&settings, &data, formationLap := true) {
		local simulator, simulatorName, session, driverForname, driverSurname, driverNickname, facts

		if (settings && !isObject(settings))
			settings := readMultiMap(settings)

		if (data && !isObject(data))
			data := readMultiMap(data)

		if (settings && (formationLap || !this.Settings || (this.Settings.Count = 0)))
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
		driverNickname := getMultiMapValue(data, "Stint Data", "DriverNickname", "JD")

		this.updateSessionValues({Simulator: simulatorName, Car: getMultiMapValue(data, "Session Data", "Car", "Unknown")
								, Track: getMultiMapValue(data, "Session Data", "Track", "Unknown")
								, Session: session, TeamSession: (getMultiMapValue(data, "Session Data", "Mode", "Solo") = "Team")
								, SessionTime: A_Now, Driver: driverForname, DriverFullName: driverName(driverForName, driverSurName, driverNickName)})
		this.updateDynamicValues({Prepared: true})

		lapTime := getMultiMapValue(data, "Stint Data", "LapLastTime", 0)

		if this.AdjustLapTime {
			settingsLapTime := (getDeprecatedValue(settings, "Session Settings", "Race Settings", "Lap.AvgTime", lapTime / 1000) * 1000)

			if (settingsLapTime && ((lapTime / settingsLapTime) > 1.2))
				lapTime := settingsLapTime
		}

		facts := this.createFacts(settings, data)

		this.updateSessionValues({Autonomy: getMultiMapValue(settings, "Assistant", "Assistant.Autonomy", "Custom")})

		this.initializeSessionFormat(facts, settings, data, lapTime)

		return facts
	}

	initializeSessionFormat(facts, settings, data, lapTime := 0, update := true) {
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

		if facts
			if isInstance(facts, KnowledgeBase) {
				if (facts.getValue("Session.Duration", 0) == 0)
					facts.setFact("Session.Duration", duration)

				if (facts.getValue("Session.Laps", 0) == 0)
					facts.setFact("Session.Laps", laps)

				facts.setFact("Session.Format", sessionFormat)
			}
			else {
				if (!facts.Has("Session.Duration") || (facts["Session.Duration"] == 0))
					facts["Session.Duration"] := duration

				if (!facts.Has("Session.Laps") || (facts["Session.Laps"] == 0))
					facts["Session.Laps"] := laps

				facts["Session.Format"] := sessionFormat
			}

		if update
			this.updateSessionValues({TrackLength: getMultiMapValue(data, "Track Data", "Length", 0)
									, SessionDuration: duration * 1000, SessionLaps: laps, TeamSession: (getMultiMapValue(data, "Session Data", "Mode", "Solo") = "Team")})
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

	callUpdateSettings(fileName) {
		this.updateSettings(readMultiMap(fileName), true)
	}

	updateSettings(settings, edit := false) {
		local knowledgeBase := this.KnowledgeBase
		local facts, key, value

		if knowledgeBase
			for key, value in this.readSettings(knowledgeBase.getValue("Session.Simulator"), knowledgeBase.getValue("Session.Car")
											  , knowledgeBase.getValue("Session.Track"), &settings)
				knowledgeBase.setFact(key, value)

		if edit
			this.updateSessionValues({Autonomy: getMultiMapValue(settings, "Assistant", "Assistant.Autonomy", "Custom")})

		this.updateSessionValues({Settings: settings})
	}

	confirmAction(action) {
		switch this.Autonomy, false {
			case "Yes", true:
				return false
			case "No", false:
				return true
			default:
				throw "Unhandled autonomy mode detected in RaceAssistant.confirmAction..."
		}
	}

	createFacts(settings, data) {
		local configuration := this.Configuration
		local simulator := getMultiMapValue(data, "Session Data", "Simulator", "Unknown")
		local simulatorName := this.SettingsDatabase.getSimulatorName(simulator)

		return combine(this.readSettings(simulator
									   , getMultiMapValue(data, "Session Data", "Car", "")
									   , getMultiMapValue(data, "Session Data", "Track", ""), &settings)
					 , CaseInsenseMap("Session.Type", this.Session
									, "Session.Track.Length", getMultiMapValue(data, "Track Data", "Length", 0)
									, "Session.Time.Remaining", getDeprecatedValue(data, "Session Data", "Stint Data", "SessionTimeRemaining", 0)
									, "Session.Lap.Remaining", getDeprecatedValue(data, "Session Data", "Stint Data", "SessionLapsRemaining", 0)
									, "Session.Settings.Lap.Time.Adjust", this.AdjustLapTime
									, "Session.Settings.Fuel.Max", getMultiMapValue(data, "Session Data", "FuelAmount", 0)
									, "Session.Settings.Lap.Learning.Laps", getMultiMapValue(configuration, this.AssistantType . " Analysis", simulatorName . ".LearningLaps", 1)
									, "Session.Settings.Lap.History.Considered", getMultiMapValue(configuration, this.AssistantType . " Analysis", simulatorName . ".ConsideredHistoryLaps", 5)
									, "Session.Settings.Lap.History.Damping", getMultiMapValue(configuration, this.AssistantType . " Analysis", simulatorName . ".HistoryLapsDamping", 0.2)))
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

		if isDebug()

		if isDebug() {
			logMessage(kLogCritical, "Restoring session state for " . this.AssistantType . "...")

			if (!settingsFile || (readMultiMap(settingsFile).Count = 0))
				logMessage(kLogCritical, "Session settings are empty for " . this.AssistantType . "...")

			if (!stateFile || (readMultiMap(stateFile).Count = 0))
				logMessage(kLogCritical, "Session state is empty for " . this.AssistantType . "...")
		}

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

		this.updateSessionValues({TrackLength: knowledgeBase.getValue("Session.Track.Length")
								, SessionDuration: knowledgeBase.getValue("Session.Duration") * 1000
								, SessionLaps: knowledgeBase.getValue("Session.Laps")})
		this.updateDynamicValues({LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
	}

	loadSessionSettings(settings) {
		if !settings
			settings := newMultiMap()

		this.updateSettings(settings)
	}

	prepareData(lapNumber, data) {
		if !this.KnowledgeBase
			this.startSession(this.Settings, data)

		return data
	}

	createSessionInfo(lapNumber, valid, data, simulator, car, track) {
		local knowledgeBase := this.KnowledgeBase
		local sessionInfo := newMultiMap()
		local tyreWear, brakeWear, duration, driverTime

		static sessionTypes

		if !isSet(sessionTypes) {
			sessionTypes := Map(kSessionPractice, "Practice", kSessionQualification, "Qualification", kSessionRace, "Race", kSessionOther, "Other")

			sessionTypes.Default := "Other"
		}

		if knowledgebase {
			setMultiMapValue(sessionInfo, "Session", "Simulator", this.SettingsDatabase.getSimulatorName(simulator))
			setMultiMapValue(sessionInfo, "Session", "Car", this.SettingsDatabase.getCarName(simulator, car))
			setMultiMapValue(sessionInfo, "Session", "Track", this.SettingsDatabase.getTrackName(simulator, track))
			setMultiMapValue(sessionInfo, "Session", "Type", sessionTypes[this.Session])
			setMultiMapValue(sessionInfo, "Session", "Format", knowledgeBase.getValue("Session.Format", "Time"))
			setMultiMapValue(sessionInfo, "Session", "Laps", lapNumber)
			setMultiMapValue(sessionInfo, "Session", "Laps.Remaining", Ceil(knowledgeBase.getValue("Lap.Remaining.Session", 0)))
			setMultiMapValue(sessionInfo, "Session", "Time.Remaining", Round(getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0) / 1000))

			duration := getMultiMapValue(data, "Stint Data", "StartTime", false)

			if duration
				setMultiMapValue(sessionInfo, "Stint", "DriveTime", DateDiff(A_Now, duration, "Seconds"))

			setMultiMapValue(sessionInfo, "Stint", "Driver", driverName(getMultiMapValue(data, "Stint Data", "DriverForname", this.DriverForName)
																	  , getMultiMapValue(data, "Stint Data", "DriverSurname", "Doe")
																	  , getMultiMapValue(data, "Stint Data", "DriverNickname", "JD")))
			setMultiMapValue(sessionInfo, "Stint", "Position", knowledgeBase.getValue("Position", 0))
			setMultiMapValue(sessionInfo, "Stint", "Valid", valid)
			setMultiMapValue(sessionInfo, "Stint", "Fuel.AvgConsumption", Round(knowledgeBase.getValue("Lap." . lapNumber . ".Fuel.AvgConsumption", 0), 1))
			setMultiMapValue(sessionInfo, "Stint", "Fuel.Consumption", Round(knowledgeBase.getValue("Lap." . lapNumber . ".Fuel.Consumption", 0), 1))
			setMultiMapValue(sessionInfo, "Stint", "Fuel.Remaining", Round(getMultiMapValue(data, "Car Data", "FuelRemaining", 0), 1))
			setMultiMapValue(sessionInfo, "Stint", "Laps", lapNumber - this.BaseLap + 1)
			setMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Fuel", Floor(knowledgeBase.getValue("Lap.Remaining.Fuel", 0)))
			setMultiMapValue(sessionInfo, "Stint", "Laps.Remaining.Stint", Floor(knowledgeBase.getValue("Lap.Remaining.Stint", 0)))

			driverTime := Round(getMultiMapValue(data, "Stint Data", "DriverTimeRemaining") / 1000)

			setMultiMapValue(sessionInfo, "Stint", "Time.Remaining.Stint", Min(driverTime, Round(getMultiMapValue(data, "Stint Data", "StintTimeRemaining") / 1000)))
			setMultiMapValue(sessionInfo, "Stint", "Time.Remaining.Driver", driverTime)

			setMultiMapValue(sessionInfo, "Stint", "Lap.Time.Last", Round(getMultiMapValue(data, "Stint Data", "LapLastTime", 0) / 1000, 1))
			setMultiMapValue(sessionInfo, "Stint", "Lap.Time.Best", Round(getMultiMapValue(data, "Stint Data", "LapBestTime", 0) / 1000, 1))

			setMultiMapValue(sessionInfo, "Weather", "Now", getMultiMapValue(data, "Weather Data", "Weather", "Dry"))
			setMultiMapValue(sessionInfo, "Weather", "10Min", getMultiMapValue(data, "Weather Data", "Weather10Min", "Dry"))
			setMultiMapValue(sessionInfo, "Weather", "30Min", getMultiMapValue(data, "Weather Data", "Weather30Min", "Dry"))
			setMultiMapValue(sessionInfo, "Weather", "Temperature", Round(getMultiMapValue(data, "Weather Data", "Temperature", 0), 1))

			setMultiMapValue(sessionInfo, "Track", "Temperature", Round(getMultiMapValue(data, "Track Data", "Temperature", 0), 1))
			setMultiMapValue(sessionInfo, "Track", "Grip", getMultiMapValue(data, "Track Data", "Grip", "Optimum"))

			setMultiMapValue(sessionInfo, "Tyres", "Compound"
										, compound(knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Compound")
												 , knowledgeBase.getValue("Lap." . lapNumber . ".Tyre.Compound.Color")))
			setMultiMapValue(sessionInfo, "Tyres", "Set", getMultiMapValue(data, "Car Data", "TyreSet", false))
			setMultiMapValue(sessionInfo, "Tyres", "Pressures", getMultiMapValue(data, "Car Data", "TyrePressure", ""))
			setMultiMapValue(sessionInfo, "Tyres", "Pressures.Hot", getMultiMapValue(data, "Car Data", "TyrePressure", ""))
			setMultiMapValue(sessionInfo, "Tyres", "Temperatures", getMultiMapValue(data, "Car Data", "TyreTemperature", ""))

			tyreWear := getMultiMapValue(data, "Car Data", "TyreWear", "")

			if (tyreWear != "") {
				tyreWear := string2Values(",", tyreWear)

				setMultiMapValue(sessionInfo, "Tyres", "Wear", values2String(",", Round(tyreWear[1]), Round(tyreWear[2]), Round(tyreWear[3]), Round(tyreWear[4])))
			}

			setMultiMapValue(sessionInfo, "Brakes", "Temperatures", getMultiMapValue(data, "Car Data", "BrakeTemperature", ""))

			brakeWear := getMultiMapValue(data, "Car Data", "BrakeWear", "")

			if (brakeWear != "") {
				brakeWear := string2Values(",", brakeWear)

				setMultiMapValue(sessionInfo, "Brakes", "Wear", values2String(",", Round(brakeWear[1]), Round(brakeWear[2]), Round(brakeWear[3]), Round(brakeWear[4])))
			}
		}

		return sessionInfo
	}

	callAddLap(lapNumber, data) {
		local startTime := A_TickCount

		if this.KnowledgeBase {
			if !isObject(data)
				data := readMultiMap(data)

			this.addLap(lapNumber, &data)
		}

		if isDebug()
			logMessage(kLogInfo, "Adding lap for " . this.AssistantType . " took " . (A_TickCount - startTime) . " ms...")
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
		driverNickname := getMultiMapValue(data, "Stint Data", "DriverNickname", "JD")

		this.updateSessionValues({Driver: driverForname, DriverFullName: driverName(driverForname, driverSurname, driverNickname)
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

		knowledgeBase.setFact("Track.Temperature", trackTemperature)
		knowledgeBase.setFact("Track.Grip", getMultiMapValue(data, "Track Data", "Grip", "Green"))

		lapTime := getMultiMapValue(data, "Stint Data", "LapLastTime", 0)

		if ((lapNumber <= 2) && this.AdjustLapTime) {
			settingsLapTime := (getDeprecatedValue(this.Settings, "Session Settings", "Race Settings", "Lap.AvgTime", lapTime / 1000) * 1000)

			if (settingsLapTime && ((lapTime / settingsLapTime) > 1.2)) {
				lapTime := settingsLapTime

				adjustedLapTime := true
			}
		}

		if (lapNumber < 5)
			if ((knowledgeBase.getValue("Session.Duration", 0) == 0) || (knowledgeBase.getValue("Session.Laps", 0) == 0))
				this.initializeSessionFormat(knowledgeBase, this.Settings, data, lapTime)

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

		if ((lapNumber < 5) && !this.BaseLap) {
			this.updateDynamicValues({BaseLap: lapNumber
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
		local startTime := A_TickCount

		if this.KnowledgeBase {
			if !isObject(data)
				data := readMultiMap(data)

			this.updateLap(lapNumber, &data)
		}

		if isDebug()
			logMessage(kLogInfo, "Updating lap for " . this.AssistantType . " took " . (A_TickCount - startTime) . " ms...")
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
			if isDebug()
				logMessage(kLogCritical, "Saving session state for " . this.AssistantType . "...")

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

	savePitstops(lapNumber, pitstopState) {
		local fileName

		if this.RemoteHandler {
			fileName := temporaryFileName("Pitstops." . lapNumber, "state")

			writeMultiMap(fileName, pitstopState)

			this.RemoteHandler.savePitstopState(lapNumber, fileName)
		}
	}

	saveSessionInfo(lapNumber, simulator, car, track, sessionInfo) {
		local fileName

		if this.RemoteHandler {
			fileName := temporaryFileName("Session." . lapNumber, "info")

			writeMultiMap(fileName, sessionInfo)

			this.RemoteHandler.saveSessionInfo(lapNumber, fileName)
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
	iOverallGridPosition := false
	iClassGridPosition := false

	iPitstops := CaseInsenseMap()
	iLastPitstopUpdate := false

	class Pitstop {
		iID := false

		iTime := false
		iLap := 0
		iDuration := 0

		ID {
			Get {
				return this.iID
			}
		}

		Time {
			Get {
				return this.iTime
			}
		}

		Lap {
			Get {
				return this.iLap
			}
		}

		Duration {
			Get {
				return this.iDuration
			}

			Set {
				return (this.iDuration := value)
			}
		}

		__New(id, time, lap, duration := 0) {
			this.iID := id
			this.iTime := time
			this.iLap := lap
			this.iDuration := duration
		}
	}

	Knowledge {
		Get {
			static knowledge := concatenate(super.Knowledge, ["Positions", "Standings"])

			return knowledge
		}
	}

	Pitstops[id?] {
		Get {
			if isSet(id) {
				if !this.iPitstops.Has(id)
					this.iPitstops[id] := []

				return this.iPitstops[id]
			}
			else
				return this.iPitstops
		}
	}

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

	GridPosition[type := "Overall"] {
		Get {
			return ((type = "Overall") ? this.iOverallGridPosition : this.iClassGridPosition)
		}
	}

	updateSessionValues(values) {
		super.updateSessionValues(values)

		if (values.HasProp("Session") && (values.Session == kSessionFinished)) {
			this.iPitstops := CaseInsenseMap()
			this.iLastPitstopUpdate := false
		}
	}

	handleVoiceCommand(grammar, words) {
		switch grammar, false {
			case "Position":
				this.positionRecognized(words)
			case "LapTime":
				this.lapTimeRecognized(words)
			case "LapTimes":
				this.lapTimesRecognized(words)
			case "ActiveCars":
				this.activeCarsRecognized(words)
			case "GapToAhead", "GapToFront":
				this.gapToAheadRecognized(words)
			case "GapToBehind":
				this.gapToBehindRecognized(words)
			case "GapToLeader":
				this.gapToLeaderRecognized(words)
			case "GapToFocus":
				this.gapToFocusRecognized(words)
			case "LapTimeFocus":
				this.lapTimeFocusRecognized(words)
			case "LapTimePosition":
				this.lapTimePositionRecognized(words)
			case "DriverNameAhead":
				this.driverNameAheadRecognized(words)
			case "DriverNameBehind":
				this.driverNameBehindRecognized(words)
			case "CarClassAhead":
				this.carClassAheadRecognized(words)
			case "CarClassBehind":
				this.carClassBehindRecognized(words)
			case "CarCupAhead":
				this.carCupAheadRecognized(words)
			case "CarCupBehind":
				this.carCupBehindRecognized(words)
			default:
				super.handleVoiceCommand(grammar, words)
		}
	}

	getKnowledge(options := false) {
		local knowledgeBase := this.KnowledgeBase
		local knowledge := super.getKnowledge(options)
		local driver := knowledgeBase.getValue("Driver.Car", false)
		local standingsData := CaseInsenseWeakMap()
		local standings := []
		local keys, ignore, car, carData, sectorTimes
		local positions, position, classPosition, car

		getCar(car, type?) {
			local carData := Map("Nr", this.getNr(car)
							   , "Class", this.getClass(car)
							   , "Laps", knowledgeBase.getValue("Car." . car . ".Laps", knowledgeBase.getValue("Car." . car . ".Lap", 0))
							   , "OverallPosition", this.getPosition(car, "Overall")
							   , "ClassPosition", this.getPosition(car, "Class")
							   , "DistanceIntoTrack", (Round(this.getRunning(car) * this.TrackLength) . " Meters")
							   , "LapTime", (Round(knowledgeBase.getValue("Car." . car . ".Time", 0) / 1000, 1) . " Seconds")
							   , "NumPitstops", this.Pitstops[knowledgeBase.getValue("Car." . car . ".ID")].Length
							   , "InPit", (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false)) ? kTrue : kFalse)

			if isSet(type)
				carData["Delta"] := (Round(knowledgeBase.getValue("Position.Standings.Class." . type . ".Delta", 0) / 1000, 1) . " Seconds")
			else
				carData["Delta"] := (Round(this.getDelta(car) / 1000, 1) . " Seconds")

			return carData
		}

		if knowledgeBase {
			position := this.getPosition()
			classPosition := (this.MultiClass ? this.getPosition(false, "Class") : position)

			if this.activeTopic(options, "Stint") {
				knowledge["Stint"]["OverallPosition"] := position
				knowledge["Stint"]["ClassPosition"] := classPosition
			}

			if this.activeTopic(options, "Positions") {
				positions := Map("OverallPosition", position, "ClassPosition", classPosition)

				knowledge["Positions"] := positions

				if (classPosition != 1) {
					car := knowledgeBase.getValue("Position.Standings.Class.Leader.Car", 0)

					if car
						positions["Leader"] := getCar(car, "Leader")

					car := knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", false)

					if car
						positions["Ahead"] := getCar(car, "Ahead")
				}

				if (this.getPosition(false, "Class") != this.getCars("Class").Length) {
					car := knowledgeBase.getValue("Position.Standings.Class.Behind.Car")

					if car
						positions["Behind"] := getCar(car, "Behind")
				}
			}
		}

		if (this.activeTopic(options, "Standings") && driver) {
			for ignore, car in this.getCars() {
				sectorTimes := this.getSectorTimes(car)

				if sectorTimes {
					sectorTimes := sectorTimes.Clone()

					loop sectorTimes.Length
						sectorTimes[A_Index] := Round(sectorTimes[A_Index] / 1000, 1)
				}
				else
					sectorTimes := false

				carData := getCar(car)

				standingsData[carData["OverallPosition"]] := carData
			}

			loop standingsData.Count
				if standingsData.Has(A_Index)
					standings.Push(standingsData[A_Index])

			knowledge["Standings"] := standings
		}

		return knowledge
	}

	requestInformation(category, arguments*) {
		switch category, false {
			case "Position":
				this.positionRecognized([])
			case "LapTime":
				this.lapTimeRecognized([])
			case "LapTimes":
				this.lapTimesRecognized([])
			case "ActiveCars":
				this.activeCarsRecognized([])
			case "GapToAheadStandings", "GapToFrontStandings":
				this.gapToAheadRecognized([])
			case "GapToAheadTrack", "GapToFrontTrack":
				this.gapToAheadRecognized(Array(this.getSpeaker().Fragments["Car"]))
			case "GapToAhead", "GapToAhead":
				this.gapToAheadRecognized(inList(arguments, "Track") ? Array(this.getSpeaker().Fragments["Car"]) : [])
			case "GapToBehindStandings":
				this.gapToBehindRecognized([])
			case "GapToBehindTrack":
				this.gapToBehindRecognized(Array(this.getSpeaker().Fragments["Car"]))
			case "GapToBehind":
				this.gapToBehindRecognized(inList(arguments, "Track") ? Array(this.getSpeaker().Fragments["Car"]) : [])
			case "GapToLeader":
				this.gapToLeaderRecognized([])
			case "DriverNameAhead":
				this.driverNameAheadRecognized([])
			case "DriverNameBehind":
				this.driverNameBehindRecognized([])
			case "CarClassAhead":
				this.carClassAheadRecognized([])
			case "CarClassBehind":
				this.carClassBehindRecognized([])
			case "CarCupAhead":
				this.carCupAheadRecognized([])
			case "CarCupBehind":
				this.carCupBehindRecognized([])
			default:
				super.requestInformation(category, arguments*)
		}
	}

	positionRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker, position, classPosition

		if !this.hasEnoughData()
			return

		speaker := this.getSpeaker()
		position := this.getPosition()

		if (position == 0)
			speaker.speakPhrase("Later")
		else {
			speaker.beginTalk()

			try {
				if this.MultiClass {
					classPosition := this.getPosition(false, "Class")

					if (position != classPosition) {
						speaker.speakPhrase("PositionClass", {positionOverall: position, positionClass: classPosition})

						position := classPosition
					}
					else
						speaker.speakPhrase("Position", {position: position})
				}
				else
					speaker.speakPhrase("Position", {position: position})

				if (position <= 3)
					speaker.speakPhrase("Great")
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	lapTimeRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local car := knowledgeBase.getValue("Driver.Car", kUndefined)
		local lap := knowledgeBase.getValue("Lap", 0)
		local lapTime, minute, seconds

		if !this.hasEnoughData()
			return

		if ((lap == 0) || (car == kUndefined) || (car == 0))
			speaker.speakPhrase("Later")
		else {
			lapTime := (knowledgeBase.getValue("Car." . car . ".Time") / 1000)

			minute := Floor(lapTime / 60)
			seconds := (lapTime - (minute * 60))

			speaker.speakPhrase("LapTime", {time: speaker.number2Speech(lapTime, 1), minute: minute, seconds: speaker.number2Speech(seconds, 1)})
		}
	}

	lapTimesRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local car, lap, position, cars, driverLapTime, speaker, minute, seconds

		reportLapTime(phrase, driverLapTime, car) {
			local lapTime := knowledgeBase.getValue("Car." . car . ".Time", false)
			local fragments, minute, seconds, delta

			if lapTime {
				lapTime /= 1000

				fragments := speaker.Fragments

				minute := Floor(lapTime / 60)
				seconds := (lapTime - (minute * 60))

				speaker.beginTalk()

				try {
					speaker.speakPhrase(phrase, {time: speaker.number2Speech(lapTime, 1), minute: minute, seconds: speaker.number2Speech(seconds, 1)})

					delta := (driverLapTime - lapTime)

					if (Abs(delta) > 0.5)
						speaker.speakPhrase("LapTimeDelta", {delta: speaker.number2Speech(Abs(delta), 1)
														   , difference: (delta > 0) ? fragments["Faster"] : fragments["Slower"]})
				}
				finally {
					speaker.endTalk()
				}
			}
		}

		if !this.hasEnoughData()
			return

		car := knowledgeBase.getValue("Driver.Car", kUndefined)
		lap := knowledgeBase.getValue("Lap", 0)
		position := this.getPosition(false, "Class")
		cars := knowledgeBase.getValue("Car.Count")

		if ((lap == 0) || (car == kUndefined) || (car == 0))
			speaker.speakPhrase("Later")
		else {
			driverLapTime := (knowledgeBase.getValue("Car." . car . ".Time") / 1000)

			speaker.beginTalk()

			try {
				minute := Floor(driverLapTime / 60)
				seconds := (driverLapTime - (minute * 60))

				speaker.speakPhrase("LapTime", {time: speaker.number2Speech(driverLapTime, 1), minute: minute, seconds: speaker.number2Speech(seconds, 1)})
			}
			finally {
				speaker.endTalk()
			}

			if (position > 2)
				reportLapTime("LapTimeFront", driverLapTime, knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", 0))

			if (position < cars)
				reportLapTime("LapTimeBehind", driverLapTime, knowledgeBase.getValue("Position.Standings.Class.Behind.Car", 0))

			if (position > 1)
				reportLapTime("LapTimeLeader", driverLapTime, knowledgeBase.getValue("Position.Standings.Class.Leader.Car", 0))
		}
	}

	activeCarsRecognized(words) {
		local car

		if !this.Knowledgebase
			this.getSpeaker().speakPhrase("Later")
		else {
			car := this.Knowledgebase.getValue("Driver.Car", kUndefined)

			if ((car == kUndefined) || (car == 0))
				this.getSpeaker().speakPhrase("Later")
			else if this.MultiClass
				this.getSpeaker().speakPhrase("ActiveCarsClass", {overallCars: this.getCars().Length, classCars: this.getCars("Class").Length})
			else
				this.getSpeaker().speakPhrase("ActiveCars", {cars: this.getCars().Length})
		}
	}

	gapToAheadRecognized(words) {
		local knowledgeBase := this.KnowledgeBase

		if !this.hasEnoughData()
			return

		if inList(words, this.getSpeaker().Fragments["Car"])
			this.trackGapToAheadRecognized(words)
		else
			this.standingsGapToAheadRecognized(words)
	}

	trackGapToAheadRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local car := knowledgeBase.getValue("Position.Track.Ahead.Car", kUndefined)
		local delta := Abs(knowledgeBase.getValue("Position.Track.Ahead.Delta", 0))
		local lap, driverLap, otherLap

		if (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))
			speaker.speakPhrase("AheadCarInPit")
		else if (delta != 0) {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("TrackGapToAhead", {delta: speaker.number2Speech(delta / 1000, 1)})

				lap := knowledgeBase.getValue("Lap")
				driverLap := Floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Driver.Car") . ".Laps"))
				otherLap := Floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Position.Track.Ahead.Car") . ".Laps"))

				if (driverLap != otherLap)
				  speaker.speakPhrase("NotTheSameLap")
			}
			finally {
				speaker.endTalk()
			}
		}
		else
			speaker.speakPhrase("NoTrackGap")
	}

	standingsGapToAheadRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local car := knowledgebase.getValue("Driver.Car", kUndefined)
		local speaker := this.getSpeaker()
		local delta, lap, inPit, speaker

		if ((car == kUndefined) || (car == 0))
			speaker.speakPhrase("Later")
		else if (this.getPosition(false, "Class") = 1)
			speaker.speakPhrase("NoGapToAhead")
		else {
			speaker.beginTalk()

			try {
				lap := knowledgeBase.getValue("Lap")
				delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Ahead.Delta", 0) / 1000)
				car := knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", kUndefined)
				inPit := (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))

				if ((delta = 0) || (inPit && (Abs(delta) < 30))) {
					speaker.speakPhrase(inPit ? "AheadCarInPit" : "NoTrackGap")

					return
				}
				else if ((knowledgeBase.getValue("Car." . car . ".Laps", knowledgeBase.getValue("Car." . car . ".Lap")) > lap)
					  && (Abs(delta) > (knowledgeBase.getValue("Lap." . lap . ".Time") / 1000)))
					speaker.speakPhrase("StandingsAheadLapped")
				else
					speaker.speakPhrase("StandingsGapToAhead", {delta: speaker.number2Speech(delta, 1)})

				if inPit
					speaker.speakPhrase("GapCarInPit")
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	gapToBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase

		if !this.hasEnoughData()
			return

		if inList(words, this.getSpeaker().Fragments["Car"])
			this.trackGapToBehindRecognized(words)
		else
			this.standingsGapToBehindRecognized(words)
	}

	trackGapToBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local car := knowledgeBase.getValue("Position.Track.Behind.Car", kUndefined)
		local delta := Abs(knowledgeBase.getValue("Position.Track.Behind.Delta", 0))
		local lap, driverLap, otherLap

		if (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))
			speaker.speakPhrase("BehindCarInPit")
		else if (delta != 0) {
			speaker.beginTalk()

			try {
				speaker.speakPhrase("TrackGapToBehind", {delta: speaker.number2Speech(delta / 1000, 1)})

				lap := knowledgeBase.getValue("Lap")
				driverLap := Floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Driver.Car") . ".Laps"))
				otherLap := Floor(knowledgeBase.getValue("Standings.Lap." . lap . ".Car." . knowledgeBase.getValue("Position.Track.Behind.Car") . ".Laps"))

				if (driverLap != otherLap)
				  speaker.speakPhrase("NotTheSameLap")
			}
			finally {
				speaker.endTalk()
			}
		}
		else
			speaker.speakPhrase("NoTrackGap")
	}

	standingsGapToBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local car := knowledgebase.getValue("Driver.Car", kUndefined)
		local delta, speaker, driver, inPit, lap, lapped

		if ((car == kUndefined) || (car == 0))
			speaker.speakPhrase("Later")
		else if (this.getPosition(false, "Class") = this.getCars("Class").Length)
			speaker.speakPhrase("NoGapToBehind")
		else {
			speaker.beginTalk()

			try {
				lap := knowledgeBase.getValue("Lap")
				delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Behind.Delta", 0) / 1000)
				car := knowledgeBase.getValue("Position.Standings.Class.Behind.Car", kUndefined)
				inPit := (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))
				lapped := false

				if ((delta = 0) || (inPit && (Abs(delta) < 30))) {
					speaker.speakPhrase(inPit ? "BehindCarInPit" : "NoTrackGap")

					return
				}
				else if ((knowledgeBase.getValue("Car." . car . ".Laps", knowledgeBase.getValue("Car." . car . ".Lap")) < lap)
					  && (Abs(delta) > (knowledgeBase.getValue("Lap." . lap . ".Time") / 1000))) {
					speaker.speakPhrase("StandingsBehindLapped")

					lapped := true
				}
				else
					speaker.speakPhrase("StandingsGapToBehind", {delta: speaker.number2Speech(delta, 1)})

				if (!lapped && inPit)
					speaker.speakPhrase("GapCarInPit")
			}
			finally {
				speaker.endTalk()
			}
		}
	}

	gapToLeaderRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local car := knowledgebase.getValue("Driver.Car", kUndefined)
		local delta

		if !this.hasEnoughData()
			return

		if ((car == kUndefined) || (car == 0))
			speaker.speakPhrase("Later")
		else if (this.getPosition(false, "Class") = 1)
			speaker.speakPhrase("NoGapToAhead")
		else {
			delta := Abs(knowledgeBase.getValue("Position.Standings.Class.Leader.Delta", 0) / 1000)

			speaker.speakPhrase("GapToLeader", {delta: speaker.number2Speech(delta, 1)})
		}
	}

	getNumber(words) {
		local numbers := []
		local ignore, candidate, fragment, number

		for ignore, candidate in words {
			if (InStr(candidate, "#") == 1)
				candidate := SubStr(candidate, 2)

			if this.isInteger(candidate, &candidate)
				numbers.Push(candidate)
			else if (numbers.Length > 0)
				break
		}

		if (numbers.Length > 0) {
			number := ""

			for ignore, fragment in numbers
				number .= fragment

			return Integer(number)
		}
		else
			return false
	}

	getCarNumber(words, &number) {
		local knowledgeBase := this.KnowledgeBase
		local car := false
		local ignore, candidate

		number := this.getNumber(words)

		if number
			for ignore, candidate in this.getCars()
				if (knowledgeBase.getValue("Car." . candidate . ".Nr", false) = number) {
					car := candidate

					break
				}

		return car
	}

	getCarIndicatorFragment(speaker, number, position) {
		if number
			return substituteVariables(speaker.Fragments["CarNumber"], {number: number})
		else if position
			return substituteVariables(speaker.Fragments["CarPosition"], {position: position})
		else
			return ""
	}

	gapToFocusRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local car := knowledgebase.getValue("Driver.Car", kUndefined)
		local number, delta, inPit, lapped, lap

		if !this.hasEnoughData()
			return

		if ((car == kUndefined) || (car == 0))
			this.getSpeaker().speakPhrase("Later")
		else {
			car := this.getCarNumber(words, &number)

			if car {
				speaker.beginTalk()

				try {
					lap := knowledgeBase.getValue("Lap")
					delta := (this.getDelta(car) / 1000)
					inPit := (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))
					lapped := false

					if ((delta = 0) || (inPit && (Abs(delta) < 30))) {
						speaker.speakPhrase(inPit ? "CarInPit" : "NoTrackGap")

						return
					}
					else if ((knowledgeBase.getValue("Car." . car . ".Laps", knowledgeBase.getValue("Car." . car . ".Lap")) < lap)
						  && (Abs(delta) > (knowledgeBase.getValue("Lap." . lap . ".Time") / 1000))) {
						speaker.speakPhrase((delta < 0) ? "FocusBehindLapped" : "FocusAheadLapped"
										  , {indicator: this.getCarIndicatorFragment(speaker, number, knowledgeBase.getValue("Car." . car . ".Position", false))})

						lapped := true
					}
					else
						speaker.speakPhrase((delta < 0) ? "FocusGapToBehind" : "FocusGapToAhead"
										  , {indicator: this.getCarIndicatorFragment(speaker, number, knowledgeBase.getValue("Car." . car . ".Position", false))
										   , delta: speaker.number2Speech(Abs(delta), 1)})

					if (!lapped && inPit)
						speaker.speakPhrase("GapCarInPit")
				}
				finally {
					speaker.endTalk()
				}
			}
			else if number
				speaker.speakPhrase("NoFocusCar", {number: number})
			else
				speaker.speakPhrase("Repeat")
		}
	}

	lapTimeFocusRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local car := knowledgebase.getValue("Driver.Car", kUndefined)
		local number, lapTime, minute, seconds, inPit

		if !this.hasEnoughData()
			return

		if ((car == kUndefined) || (car == 0))
			this.getSpeaker().speakPhrase("Later")
		else {
			car := this.getCarNumber(words, &number)

			if car {
				lapTime := (this.getLapTime(car) / 1000)
				inPit := (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))

				if (inPit || (lapTime = 0)) {
					speaker.speakPhrase("CarInPit")

					return
				}
				else {
					minute := Floor(lapTime / 60)
					seconds := (lapTime - (minute * 60))

					speaker.speakPhrase("FocusLapTime", {indicator: this.getCarIndicatorFragment(speaker, number, knowledgeBase.getValue("Car." . car . ".Position", false))
													   , time: speaker.number2Speech(lapTime, 1)
													   , minute: minute, seconds: speaker.number2Speech(seconds, 1)})
				}
			}
			else if number
				speaker.speakPhrase("NoFocusCar", {number: number})
			else
				speaker.speakPhrase("Repeat")
		}
	}

	lapTimePositionRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local speaker := this.getSpeaker()
		local position, car, lapTime, minute, seconds, inPit

		getCarPosition(words, &position) {
			local knowledgeBase := this.KnowledgeBase
			local car := false
			local ignore, candidate

			position := this.getNumber(words)

			if position
				for ignore, candidate in this.getCars()
					if (knowledgeBase.getValue("Car." . candidate . ".Position", false) = position) {
						car := candidate

						break
					}

			return car
		}

		if !this.hasEnoughData()
			return

		car := getCarPosition(words, &position)

		if car {
			lapTime := (this.getLapTime(car) / 1000)
			inPit := (knowledgeBase.getValue("Car." . car . ".InPitLane", false) || knowledgeBase.getValue("Car." . car . ".InPit", false))

			if (inPit || (lapTime = 0)) {
				speaker.speakPhrase("CarInPit")

				return
			}
			else {
				minute := Floor(lapTime / 60)
				seconds := (lapTime - (minute * 60))

				speaker.speakPhrase("PositionLapTime", {position: position, time: speaker.number2Speech(lapTime, 1), minute: minute, seconds: speaker.number2Speech(seconds, 1)})
			}
		}
		else if position
			speaker.speakPhrase("NoPositionCar", {position: position})
		else
			speaker.speakPhrase("Repeat")
	}

	driverNameAheadRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local car := knowledgeBase.getValue("Position.Track.Ahead.Car", kUndefined)
		local forName, surName, ignore

		if (car != kUndefined) {
			parseDriverName(this.getDriver(car), &forName, &surName, &ignore := false)

			this.getSpeaker().speakPhrase("DriverNameAhead", {forName: forName, surName: surName})
		}
		else
			this.getSpeaker().speakPhrase("NoTrackGap")
	}

	driverNameBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local car := knowledgeBase.getValue("Position.Track.Behind.Car", kUndefined)
		local forName, surName, ignore

		if (car != kUndefined) {
			parseDriverName(this.getDriver(car), &forName, &surName, &ignore := false)

			this.getSpeaker().speakPhrase("DriverNameBehind", {forName: forName, surName: surName})
		}
		else
			this.getSpeaker().speakPhrase("NoTrackGap")
	}

	carClassAheadRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local car := knowledgeBase.getValue("Position.Track.Ahead.Car", kUndefined)
		local class

		if (car != kUndefined) {
			class := this.getClass(car)

			if (class = kUnknown)
				this.getSpeaker().speakPhrase("NoInformation")
			else
				this.getSpeaker().speakPhrase("CarClassAhead", {class: class})
		}
		else
			this.getSpeaker().speakPhrase("NoTrackGap")
	}

	carClassBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local car := knowledgeBase.getValue("Position.Track.Behind.Car", kUndefined)
		local class

		if (car != kUndefined) {
			class := this.getClass(car)

			if (class = kUnknown)
				this.getSpeaker().speakPhrase("NoInformation")
			else
				this.getSpeaker().speakPhrase("CarClassBehind", {class: class})
		}
		else
			this.getSpeaker().speakPhrase("NoTrackGap")
	}

	carCupAheadRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local car := knowledgeBase.getValue("Position.Track.Ahead.Car", kUndefined)
		local cup

		if (car != kUndefined) {
			cup := this.getClass(car, false, ["Cup"])

			if (cup = kUnknown)
				this.getSpeaker().speakPhrase("NoInformation")
			else
				this.getSpeaker().speakPhrase("CarCupAhead", {cup: cup})
		}
		else
			this.getSpeaker().speakPhrase("NoTrackGap")
	}

	carCupBehindRecognized(words) {
		local knowledgeBase := this.KnowledgeBase
		local car := knowledgeBase.getValue("Position.Track.Behind.Car", kUndefined)
		local cup

		if (car != kUndefined) {
			cup := this.getClass(car, false, [Cup])

			if (cup = kUnknown)
				this.getSpeaker().speakPhrase("NoInformation")
			else
				this.getSpeaker().speakPhrase("CarCupBehind", {cup: cup})
		}
		else
			this.getSpeaker().speakPhrase("NoTrackGap")
	}

	savePitstopState(state := false) {
		if !state
			state := newMultiMap()

		local id, pitstops, index, pitstop

		for id, pitstops in this.Pitstops {
			setMultiMapValue(state, "Pitstop State", "Pitstop." . A_Index . ".ID", id)

			for index, pitstop in pitstops
				setMultiMapValue(state, "Pitstop State", "Pitstop." . id . "." . index
							   , values2String(";", pitstop.Time, pitstop.Lap, pitstop.Duration))

			setMultiMapValue(state, "Pitstop State", "Pitstop." . id . ".Count", pitstops.Length)
		}

		setMultiMapValue(state, "Pitstop State", "Pitstop.Count", this.Pitstops.Count)

		return state
	}

	createSessionState() {
		local state := super.createSessionState()

		this.savePitstopState(state)

		if isDevelopment()
			writeMultiMap(temporaryFileName(this.AssistantType, "pitstops"), state)

		return state
	}

	loadSessionState(state) {
		local carID

		super.loadSessionState(state)

		this.iPitstops := CaseInsenseMap()

		loop getMultiMapValue(state, "Pitstop State", "Pitstop.Count", 0) {
			carID := getMultiMapValue(state, "Pitstop State", "Pitstop." . A_Index . ".ID")
			pitstops := this.Pitstops[carID]

			loop getMultiMapValue(state, "Pitstop State", "Pitstop." . carID . ".Count", 0)
				pitstops.Push(GridRaceAssistant.Pitstop(carID, string2Values(";", getMultiMapValue(state, "Pitstop State", "Pitstop." . carID . "." . A_Index))*))
		}
	}

	getClasses(data := false) {
		local knowledgebase := this.Knowledgebase
		local class

		static classes := false
		static lastKnowledgeBase := false

		if (data || !lastKnowledgeBase || (lastKnowledgebase != knowledgeBase) || !classes) {
			classes := CaseInsenseMap()

			loop (data ? getMultiMapValue(data, "Position Data", "Car.Count", 0) : (knowledgeBase ? knowledgeBase.getValue("Car.Count") : 0))
				if (data || knowledgeBase.getValue("Car." . A_Index . ".Car", false)) {
					class := this.getClass(A_Index, data)

					if !classes.Has(class)
						classes[class] := true
				}

			lastKnowledgeBase := (data ? false : knowledgeBase)

			classes := getKeys(classes)
		}

		return classes
	}

	getNr(car := false, data := false) {
		local knowledgeBase := this.KnowledgeBase
		local carCategory := kUndefined
		local carClass

		if !car
			car := (data ? getMultiMapValue(data, "Position Data", "Driver.Car") : (knowledgeBase ? knowledgeBase.getValue("Driver.Car", false) : false))

		if data
			return getMultiMapValue(data, "Position Data", "Car." . car . ".Nr", false)
		else
			return (knowledgeBase ? knowledgeBase.getValue("Car." . car . ".Nr", false) : false)
	}

	getClass(car := false, data := false, categories := ["Class"]) {
		local knowledgeBase := this.KnowledgeBase
		local carCategory := kUndefined
		local carClass

		if !car
			car := (data ? getMultiMapValue(data, "Position Data", "Driver.Car") : this.KnowledgeBase.getValue("Driver.Car", false))

		if data {
			if inList(categories, "Class") {
				carClass := getMultiMapValue(data, "Position Data", "Car." . car . ".Class", kUnknown)

				if inList(categories, "Cup")
					carCategory := getMultiMapValue(data, "Position Data", "Car." . car . ".Category", kUndefined)
			}
			else
				carClass := getMultiMapValue(data, "Position Data", "Car." . car . ".Category", kUnknown)
		}
		else {
			if inList(categories, "Class") {
				carClass := (knowledgeBase ? knowledgeBase.getValue("Car." . A_Index . ".Class", kUnknown) : kUnknown)

				if inList(categories, "Cup")
					carCategory := (knowledgeBase ? knowledgeBase.getValue("Car." . A_Index . ".Category", kUndefined) : kUndefined)
			}
			else
				carClass := (knowledgeBase ? knowledgeBase.getValue("Car." . A_Index . ".Category", kUnknown) : kUnknown)
		}

		return ((carCategory != kUndefined) ? (carClass . translate(" (") . carCategory . translate(")")) : carClass)
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
					loop getMultiMapValue(data, "Position Data", "Car.Count", 0)
						if (!class || (class = this.getClass(A_Index, data)))
							positions.Push(Array(A_Index, getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Position")))
				}
				else if knowledgeBase
					loop knowledgeBase.getValue("Car.Count")
						if (!class || (class = this.getClass(A_Index)))
							if knowledgeBase.getValue("Car." . A_Index . ".Car", false)
								positions.Push(Array(A_Index, knowledgeBase.getValue("Car." . A_Index . ".Position")))

				bubbleSort(&positions, compareClassPositions)

				for ignore, position in positions
					classGrid.Push(position[1])
			}
			else {
				if data {
					loop getMultiMapValue(data, "Position Data", "Car.Count", 0)
						if (!class || (class = this.getClass(A_Index, data)))
							classGrid.Push(A_Index)
				}
				else if knowledgeBase
					loop knowledgeBase.getValue("Car.Count")
						if (!class || (class = this.getClass(A_Index)))
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
		local knowledgeBase := this.KnowledgeBase
		local position, candidate

		if !car {
			if (type = "Overall") {
				if data
					return getMultiMapValue(data, "Position Data", "Car." . getMultiMapValue(data, "Position Data", "Driver.Car") . ".Position", false)
				else
					return (knowledgeBase ? knowledgeBase.getValue("Position", 0) : 0)
			}
			else
				car := (data ? getMultiMapValue(data, "Position Data", "Driver.Car") : knowledgeBase.getValue("Driver.Car", false))
		}

		if ((type != "Overall") && this.MultiClass[data]) {
			for position, candidate in this.getCars(this.getClass(car, data), data, true)
				if (candidate = car)
					return position
		}

		if data
			return getMultiMapValue(data, "Position Data", "Car." . car . ".Position", car)
		else
			return (knowledgeBase ? knowledgeBase.getValue("Car." . car . ".Position", car) : 0)
	}

	getRunning(car, data := false) {
		if data
			return getMultiMapValue(data, "Position Data", "Car." . car . ".Lap.Running")
		else
			return this.KnowledgeBase.getValue("Car." . car . ".Lap.Running")
	}

	getDelta(car, data := false) {
		local knowledgeBase, driverLap, driverRunning, driverTime, carLap, carRunning, delta

		if data {
			driver := getMultiMapValue(data, "Position Data", "Driver.Car", false)

			if driver {
				driverLap := getMultiMapValue(data, "Position Data", "Car." . driver . ".Laps", getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap"))
				driverRunning := getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap.Running")
				driverTime := getMultiMapValue(data, "Position Data", "Car." . driver . ".Time")
				carLap := getMultiMapValue(data, "Position Data", "Car." . car . ".Laps", getMultiMapValue(data, "Position Data", "Car." . car . ".Lap"))
				carRunning := getMultiMapValue(data, "Position Data", "Car." . car . ".Lap.Running")

				return (((carLap + carRunning) - (driverLap + driverRunning)) * driverTime)
			}
			else
				return false
		}
		else {
			knowledgeBase := this.KnowledgeBase

			driver := (knowledgeBase ? knowledgeBase.getValue("Driver.Car", false) : false)

			if driver {
				driverLap := knowledgeBase.getValue("Car." . driver . ".Laps", knowledgeBase.getValue("Car." . driver . ".Lap"))
				driverRunning := knowledgeBase.getValue("Car." . driver . ".Lap.Running")
				driverTime := knowledgeBase.getValue("Car." . driver . ".Time")
				carLap := knowledgeBase.getValue("Car." . car . ".Laps", knowledgeBase.getValue("Car." . car . ".Lap"))
				carRunning := knowledgeBase.getValue("Car." . car . ".Lap.Running")

				return (((carLap + carRunning) - (driverLap + driverRunning)) * driverTime)
			}
			else
				return false
		}
	}

	getLapTime(car, data := false) {
		if data
			return getMultiMapValue(data, "Position Data", "Car." . car . ".Time", false)
		else
			return (this.KnowledgeBase ? this.KnowledgeBase.getValue("Car." . car . ".Time", false) : false)
	}

	getSectorTimes(car, data := false) {
		local sectorTimes

		if data
			sectorTimes := getMultiMapValue(data, "Position Data", car . ".Time.Sectors", false)
		else
			sectorTimes := (this.KnowledgeBase ? this.KnowledgeBase.getValue("Car." . car . ".Time.Sectors", false) : false)

		if (sectorTimes && (sectorTimes != "")) {
			sectorTimes := string2Values(",", sectorTimes)

			loop sectorTimes.Length
				if !isNumber(sectorTimes[A_Index]) {
					sectorTimes := false

					break
				}
		}
		else
			sectorTimes := false

		return sectorTimes
	}

	getDriver(car, data := false) {
		local forName, surName, nickName, knowledgeBase

		if data {
			forName := getMultiMapValue(data, "Position Data", "Car." . car . ".Driver.ForName", "John")
			surName := getMultiMapValue(data, "Position Data", "Car." . car . ".Driver.SurName", "Doe")
			nickName := getMultiMapValue(data, "Position Data", "Car." . car . ".Driver.NickName", "JD")
		}
		else {
			knowledgeBase := this.KnowledgeBase

			if knowledgeBase {
				forName := knowledgeBase.getValue("Car." . car . ".Driver.ForName", "John")
				surName := knowledgeBase.getValue("Car." . car . ".Driver.SurName", "Doe")
				nickName := knowledgeBase.getValue("Car." . car . ".Driver.NickName", "JD")
			}
			else {
				forName := "John"
				surName := "Doe"
				nickName := "JD"
			}
		}

		return driverName(forName, surName, nickName)
	}

	prepareData(lapNumber, data) {
		local knowledgeBase, key, value

		data := super.prepareData(lapNumber, data)

		knowledgeBase := this.KnowledgeBase

		for key, value in getMultiMapValues(data, "Position Data")
			knowledgeBase.setFact(key, value)

		return data
	}

	updatePitstops(lap, data) {
		local carID, delta, pitstops, pitstop

		if !this.iLastPitstopUpdate {
			this.iLastPitstopUpdate := Round(getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0) / 1000)

			delta := 0
		}
		else {
			delta := (this.iLastPitstopUpdate - Round(getMultiMapValue(data, "Session Data", "SessionTimeRemaining", 0) / 1000))

			this.iLastPitstopUpdate -= delta
		}

		loop getMultiMapValue(data, "Position Data", "Car.Count", 0) {
			if (getMultiMapValue(data, "Position Data", "Car." . A_Index . ".InPitlane", false)
			 || getMultiMapValue(data, "Position Data", "Car." . A_Index . ".InPit", false)) {
				carID := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".ID", A_Index)

				pitstops := this.Pitstops[carID]

				if (pitstops.Length = 0)
					pitstops.Push(GridRaceAssistant.Pitstop(carID, this.iLastPitstopUpdate, lap))
				else {
					pitstop := pitstops[pitstops.Length]

					if ((pitstop.Time - pitstop.Duration - (delta + 20)) < this.iLastPitstopUpdate)
						pitstop.Duration := (pitstop.Duration + delta)
					else
						pitstops.Push(GridRaceAssistant.Pitstop(carID, this.iLastPitstopUpdate, lap))
				}
			}
		}
	}

	createSessionInfo(lapNumber, valid, data, simulator, car, track) {
		local knowledgeBase := this.KnowledgeBase
		local sessionInfo := super.createSessionInfo(lapNumber, valid, data, simulator, car, track)
		local position, classPosition

		if knowledgeBase {
			position := this.getPosition()
			classPosition := (this.MultiClass ? this.getPosition(false, "Class") : position)

			setMultiMapValue(sessionInfo, "Standings", "Position.Overall", position)
			setMultiMapValue(sessionInfo, "Standings", "Position.Class", classPosition)

			if (classPosition != 1) {
				car := knowledgeBase.getValue("Position.Standings.Class.Leader.Car", 0)

				if car {
					setMultiMapValue(sessionInfo, "Standings", "Leader.Nr", knowledgeBase.getValue("Car." . car . ".Nr", false))
					setMultiMapValue(sessionInfo, "Standings", "Leader.Lap.Time", Round(knowledgeBase.getValue("Car." . car . ".Time", 0) / 1000, 1))
					setMultiMapValue(sessionInfo, "Standings", "Leader.Laps", knowledgeBase.getValue("Car." . car . ".Laps", knowledgeBase.getValue("Car." . car . ".Lap", 0)))
					setMultiMapValue(sessionInfo, "Standings", "Leader.Delta", Round(knowledgeBase.getValue("Position.Standings.Class.Leader.Delta", 0) / 1000, 1))
					setMultiMapValue(sessionInfo, "Standings", "Leader.InPit", (knowledgeBase.getValue("Car." . car . ".InPitLane", false)
																			 || knowledgeBase.getValue("Car." . car . ".InPit", false)))
				}

				car := knowledgeBase.getValue("Position.Standings.Class.Ahead.Car", false)

				if car {
					setMultiMapValue(sessionInfo, "Standings", "Ahead.Nr", knowledgeBase.getValue("Car." . car . ".Nr", false))
					setMultiMapValue(sessionInfo, "Standings", "Ahead.Lap.Time", Round(knowledgeBase.getValue("Car." . car . ".Time", 0) / 1000, 1))
					setMultiMapValue(sessionInfo, "Standings", "Ahead.Laps", knowledgeBase.getValue("Car." . car . ".Laps", knowledgeBase.getValue("Car." . car . ".Lap", 0)))
					setMultiMapValue(sessionInfo, "Standings", "Ahead.Delta", Round(knowledgeBase.getValue("Position.Standings.Class.Ahead.Delta", 0) / 1000, 1))
					setMultiMapValue(sessionInfo, "Standings", "Ahead.InPit", (knowledgeBase.getValue("Car." . car . ".InPitLane", false)
																			|| knowledgeBase.getValue("Car." . car . ".InPit", false)))
				}
			}

			if (this.getPosition(false, "Class") != this.getCars("Class").Length) {
				car := knowledgeBase.getValue("Position.Standings.Class.Behind.Car")

				if car {
					setMultiMapValue(sessionInfo, "Standings", "Behind.Nr", knowledgeBase.getValue("Car." . car . ".Nr", false))
					setMultiMapValue(sessionInfo, "Standings", "Behind.Lap.Time", Round(knowledgeBase.getValue("Car." . car . ".Time", 0) / 1000, 1))
					setMultiMapValue(sessionInfo, "Standings", "Behind.Laps", knowledgeBase.getValue("Car." . car . ".Laps", knowledgeBase.getValue("Car." . car . ".Lap", 0)))
					setMultiMapValue(sessionInfo, "Standings", "Behind.Delta", Round(knowledgeBase.getValue("Position.Standings.Class.Behind.Delta", 0) / 1000, 1))
					setMultiMapValue(sessionInfo, "Standings", "Behind.InPit", (knowledgeBase.getValue("Car." . car . ".InPitLane", false)
																			 || knowledgeBase.getValue("Car." . car . ".InPit", false)))
				}
			}
		}

		return sessionInfo
	}

	initializeGridPosition(data, force := false) {
		local count := getMultiMapValue(data, "Position Data", "Car.Count", 0)
		local driver := getMultiMapValue(data, "Position Data", "Driver.Car", false)

		if isDebug()
			logMessage(kLogDebug, "Grid Position: " . this.getPosition(driver, "Overall", data) . ", " . this.getPosition(driver, "Class", data) . "; Force: " . (force ? kTrue : kFalse) . "; Position: " . this.GridPosition)

		if ((force || !this.GridPosition) && count && driver) {
			this.iOverallGridPosition := this.getPosition(driver, "Overall", data)
			this.iClassGridPosition := this.getPosition(driver, "Class", data)
		}
	}

	prepareSession(&settings, &data, formationLap := true) {
		local prepared := this.Prepared
		local facts := super.prepareSession(&settings, &data, formationLap)

		this.initializeGridPosition(data, !prepared && formationLap)

		return facts
	}

	addLap(lapNumber, &data) {
		local driver, lapValid, lapPenalty

		if !isObject(data)
			data := readMultiMap(data)

		driver := getMultiMapValue(data, "Position Data", "Driver.Car", false)

		this.KnowledgeBase.addFact("Lap." . lapNumber . ".Position.Overall", this.getPosition(false, "Overall", data))
		this.KnowledgeBase.addFact("Lap." . lapNumber . ".Position.Class", this.getPosition(false, "Class", data))

		lapValid := getMultiMapValue(data, "Stint Data", "LapValid", true)
		lapPenalty := getMultiMapValue(data, "Stint Data", "Penalty", false)

		if (driver && (getMultiMapValue(data, "Position Data", "Car." . driver . ".Laps", getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap", false)) = lapNumber)) {
			lapValid := getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap.Valid", lapValid)
			lapPenalty := getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap.Penalty", lapPenalty)
		}

		this.updatePitstops(lapNumber, data)

		this.initializeGridPosition(data)

		result := super.addLap(lapNumber, &data, true, lapValid, lapPenalty)

		this.savePitstops(lapNumber, this.savePitstopState())

		return result
	}

	updateLap(lapNumber, &data) {
		local knowledgeBase := this.KnowledgeBase
		local noGrid := !this.GridPosition
		local driver, lapValid, lapPenalty, result

		if !isObject(data)
			data := readMultiMap(data)

		this.initializeGridPosition(data)

		if (noGrid && this.GridPosition)
			knowledgeBase.setFact("Grid", lapNumber)

		driver := getMultiMapValue(data, "Position Data", "Driver.Car", false)
		lapValid := getMultiMapValue(data, "Stint Data", "LapValid", true)
		lapPenalty := getMultiMapValue(data, "Stint Data", "Penalty", false)

		if (driver && (getMultiMapValue(data, "Position Data", "Car." . driver . ".Laps", getMultiMapValue(data, "Position Data", "Car." . driver . ".Lap", false)) = lapNumber)) {
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

		this.updatePitstops(lapNumber, data)

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

getTime(*) {
	return A_Now
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