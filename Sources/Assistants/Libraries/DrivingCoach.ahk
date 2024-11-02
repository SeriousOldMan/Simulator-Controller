;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Driving Coach                ;;;
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

#Include "..\..\Libraries\Task.ahk"
#Include "..\..\Libraries\JSON.ahk"
#Include "..\..\Libraries\HTTP.ahk"
#Include "..\..\Libraries\LLMConnector.ahk"
#Include "RaceAssistant.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "..\..\Database\Libraries\TelemetryCollector.ahk"
#Include "..\..\Database\Libraries\TelemetryAnalyzer.ahk"
#Include "..\..\Garage\Libraries\IssueCollector.ahk"
#Include "..\..\Garage\Libraries\IRCIssueCollector.ahk"
#Include "..\..\Garage\Libraries\R3EIssueCollector.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class DrivingCoach extends GridRaceAssistant {
	iConnector := false
	iConnectionState := "Active"

	iTemplates := false

	iInstructions := CaseInsenseWeakMap()

	iLaps := Map()
	iLapsHistory := 0

	iStandings := []

	iIssueCollector := false

	iTranscript := false

	iMode := "Conversation"

	iCoachingActive := false
	iAvailableTelemetry := CaseInsenseMap()

	iTelemetryAnalyzer := false
	iTelemetryCollector := false
	iCollectorTask := false

	iTrackTriggerPID := false

	class CoachVoiceManager extends RaceAssistant.RaceVoiceManager {
	}

	class DrivingCoachRemoteHandler extends RaceAssistant.RaceAssistantRemoteHandler {
		__New(remotePID) {
			super.__New("Driving Coach", remotePID)
		}

		serviceState(arguments*) {
			this.callRemote("serviceState", arguments*)
		}
	}

	Knowledge {
		Get {
			static knowledge := choose(super.Knowledge, (t) => !inList(["Standings", "Positions"], t))

			return knowledge
		}
	}

	CollectorClass {
		Get {
			switch SessionDatabase.getSimulatorCode(this.Simulator), false {
				case "IRC":
					return "IRCIssueCollector"
				case "R3E":
					return "R3EIssueCollector"
				default:
					return "IssueCollector"
			}
		}
	}

	Providers {
		Get {
			return LLMConnector.Providers
		}
	}

	Templates[language?] {
		Get {
			local templates, fileName, code, ignore

			if !this.iTemplates {
				templates := CaseInsenseMap()

				for code, ignore in availableLanguages() {
					fileName := getFileName("Driving Coach.instructions." . code, kTranslationsDirectory)

					if FileExist(fileName) {
						templates[code] := readMultiMap(fileName)

						fileName := getFileName("Driving Coach.instructions." . code, kUserTranslationsDirectory)

						if FileExist(fileName)
							addMultiMapValues(templates[code], readMultiMap(fileName))
					}
					else {
						fileName := getFileName("Driving Coach.instructions." . code, kUserTranslationsDirectory)

						if FileExist(fileName)
							templates[code] := readMultiMap(fileName)
					}
				}

				this.iTemplates := templates
			}

			return (isSet(language) ? this.iTemplates[language] : this.iTemplates)
		}
	}

	Instructions[type?] {
		Get {
			if isSet(type) {
				if (type == true)
					return ["Character", "Simulation", "Session", "Stint", "Knowledge", "Handling", "Coaching", "Coaching.Lap", "Coaching.Corner", "Coaching.Corner.Short"]
				else
					return (this.iInstructions.Has(type) ? this.iInstructions[type] : false)
			}
			else
				return this.iInstructions
		}

		Set {
			return (isSet(type) ? (this.iInstructions[type] := value) : (this.iInstructions := value))
		}
	}

	Connector {
		Get {
			return this.iConnector
		}
	}

	ConnectionState {
		Get {
			return this.iConnectionState
		}

		Set {
			return (this.iConnectionState := value)
		}
	}

	Transcript {
		Get {
			return this.iTranscript
		}
	}

	Mode {
		Get {
			return this.iMode
		}

		Set {
			if this.Connector
				this.Connector.History := (value = "Conversation")

			return (this.iMode := value)
		}
	}

	Laps[lapNumber?] {
		Get {
			if isSet(lapNumber) {
				lapNumber := (lapNumber + 0)

				return (this.iLaps.Has(lapNumber) ? this.iLaps[lapNumber] : false)
			}
			else
				return this.iLaps
		}

		Set {
			if isSet(lapNumber) {
				lapNumber := (lapNumber + 0)

				return (this.iLaps[lapNumber] := value)
			}
			else
				return this.iLaps := value
		}
	}

	LapsHistory {
		Get {
			return this.iLapsHistory
		}
	}

	Standings[position?] {
		Get {
			return (isSet(position) ? this.iStandings[position] : this.iStandings)
		}

		Set {
			return (isSet(position) ? (this.iStandings[position] := value) : (this.iStandings := value))
		}
	}

	CoachingActive {
		Get {
			return this.iCoachingActive
		}
	}

	AvailableTelemetry {
		Get {
			return this.iAvailableTelemetry
		}
	}

	TelemetryAnalyzer {
		Get {
			return this.iTelemetryAnalyzer
		}
	}

	TelemetryCollector {
		Get {
			return this.iTelemetryCollector
		}
	}

	CollectorTask {
		Get {
			return this.iCollectorTask
		}
	}

	__New(configuration, remoteHandler, name := false, language := kUndefined
		, synthesizer := false, speaker := false, vocalics := false, speakerBooster := false
		, recognizer := false, listener := false, listenerBooster := false, conversationBooster := false, agentBooster := false
		, muted := false, voiceServer := false) {
		super.__New(configuration, "Driving Coach", remoteHandler, name, language, synthesizer, speaker, vocalics, speakerBooster
												  , recognizer, listener, listenerBooster, conversationBooster, agentBooster
												  , muted, voiceServer)

		this.updateConfigurationValues({Announcements: {SessionInformation: true, StintInformation: false, HandlingInformation: false}})

		DirCreate(this.Options["Driving Coach.Archive"])

		OnExit(ObjBindMethod(this, "stopIssueCollector"))
		OnExit((*) {
			if this.TelemetryCollector
				this.TelemetryCollector.shutdown()
		})
		OnExit(ObjBindMethod(this, "shutdownTrackTrigger", true))
	}

	loadFromConfiguration(configuration) {
		local options, laps, ignore, instruction

		super.loadFromConfiguration(configuration)

		options := this.Options

		options["Driving Coach.Archive"] := getMultiMapValue(configuration, "Driving Coach Conversations", "Archive", kTempDirectory . "Conversations")

		if (!options["Driving Coach.Archive"] || (options["Driving Coach.Archive"] = ""))
			options["Driving Coach.Archive"] := (kTempDirectory . "Conversations")

		options["Driving Coach.Service"] := getMultiMapValue(configuration, "Driving Coach Service", "Service", getMultiMapValue(configuration, "Driving Coach", "Service", false))
		options["Driving Coach.Model"] := getMultiMapValue(configuration, "Driving Coach Service", "Model", false)
		options["Driving Coach.MaxTokens"] := getMultiMapValue(configuration, "Driving Coach Service", "MaxTokens", 2048)
		options["Driving Coach.Temperature"] := getMultiMapValue(configuration, "Driving Coach Personality", "Temperature", 0.5)

		if (string2Values("|", options["Driving Coach.Service"])[1] = "LLM Runtime")
			options["Driving Coach.GPULayers"] := getMultiMapValue(configuration, "Driving Coach Service", "GPULayers", 0)

		options["Driving Coach.MaxHistory"] := getMultiMapValue(configuration, "Driving Coach Personality", "MaxHistory", 3)
		options["Driving Coach.Confirmation"] := getMultiMapValue(configuration, "Driving Coach Personality", "Confirmation", true)

		for ignore, instruction in this.Instructions[true]
			if (getMultiMapValue(configuration, "Driving Coach Personality", "Instructions." . instruction, kUndefined) != kUndefined)
				options["Driving Coach.Instructions." . instruction] := getMultiMapValue(configuration, "Driving Coach Personality", "Instructions." . instruction, false)
			else
				options["Driving Coach.Instructions." . instruction] := getMultiMapValue(this.Templates[options["Language"]], "Instructions", instruction)

		laps := InStr(options["Driving Coach.Instructions.Stint"], "%laps:")

		if laps {
			laps := SubStr(options["Driving Coach.Instructions.Stint"], laps + 1, InStr(options["Driving Coach.Instructions.Stint"], "%", false, laps + 1) - laps - 1)

			options["Driving Coach.Instructions.Stint"] := StrReplace(options["Driving Coach.Instructions.Stint"], laps, "laps")

			this.iLapsHistory := string2Values(":", laps)[2]
		}
	}

	createVoiceManager(name, options) {
		return DrivingCoach.CoachVoiceManager(this, name, options)
	}

	updateSessionValues(values) {
		super.updateSessionValues(values)

		if values.HasProp("Laps")
			this.iLaps := values.Laps
		else if values.HasProp("Standings")
			this.iStandings := values.Standings

		if (values.HasProp("Session") && (values.Session == kSessionFinished) && (this.Session != kSessionFinished))
			if this.CoachingActive
				this.shutdownCoaching()
	}

	connectorState(state, reason := false, arguments*) {
		local oldState := this.ConnectionState

		if (state = "Active")
			this.ConnectionState := state
		else if (state = "Error")
			this.ConnectionState := (state . (reason ? (":" . reason) : ""))
		else
			this.ConnectionState := "Unknown"

		if ((oldState != this.ConnectionState) && this.RemoteHandler)
			this.RemoteHandler.serviceState((this.ConnectionState = "Active") ? "Available" : this.ConnectionState)
	}

	getInstruction(category) {
		local knowledgeBase := this.KnowledgeBase
		local settingsDB := this.SettingsDatabase
		local simulator, car, track, position, hasSectorTimes, laps, lapData, ignore, carData, standingsData
		local collector, issues, handling, ignore, type, speed, where, issue, index
		local key, value, text, filter, telemetry

		static sessions := false

		if !sessions {
			sessions := ["Other", "Practice", "Qualifying", "Race"]

			sessions.Default := "Other"
		}

		switch category, false {
			case "Character":
				return substituteVariables(this.Instructions["Character"], {name: this.VoiceManager.Name})
			case "Simulation":
				if knowledgeBase {
					simulator := knowledgeBase.getValue("Session.Simulator")
					car := knowledgeBase.getValue("Session.Car")
					track := knowledgeBase.getValue("Session.Track")

					if (simulator && car && track)
						return substituteVariables(this.Instructions["Simulation"]
												 , {name: this.VoiceManager.Name
												  , driver: this.DriverForName
												  , simulator: settingsDB.getSimulatorName(simulator)
												  , car: settingsDB.getCarName(simulator, car)
												  , track: settingsDB.getTrackName(simulator, track)})
				}
			case "Session":
				if (knowledgeBase && this.Announcements["SessionInformation"] && (this.Mode = "Conversation")) {
					position := this.GridPosition

					if (position != 0)
						return substituteVariables(this.Instructions["Session"]
												 , {session: translate(sessions[this.Session])
												  , carNumber: this.getNr()
												  , classPosition: this.GridPosition["Class"], overallPosition: position})
				}
			case "Stint":
				if (knowledgeBase && this.Announcements["StintInformation"] && (this.Mode = "Conversation")) {
					position := this.getPosition(false, "Class")

					if ((position != 0) && (this.Laps.Count > 0)) {
						lapData := ""

						laps := bubbleSort(&laps := getKeys(this.Laps))

						hasSectorTimes := false

						for ignore, lap in laps
							if this.Laps[lap].SectorTimes {
								hasSectorTimes := true

								break
							}

						if hasSectorTimes
							lapData .= (values2String(";", collect(["Lap", "Position (Overall)", "Position (Class)", "Sector Times", "Lap Time"], translate)*) . "`n")
						else
							lapData .= (values2String(";", collect(["Lap", "Position (Overall)", "Position (Class)", "Lap Time"], translate)*) . "`n")

						for ignore, lap in laps {
							carData := this.Laps[lap]

							if (A_Index > 1)
								lapData .= "`n"

							if hasSectorTimes
								lapData .= values2String(";", lap, carData.OverallPosition, carData.ClassPosition
																 , carData.SectorTimes ? values2String(",", carData.SectorTimes*) : "", carData.LapTime)
							else
								lapData .= values2String(";", lap, carData.OverallPosition, carData.ClassPosition, carData.LapTime)
						}

						standingsData := ""

						hasSectorTimes := false

						for position, carData in this.Standings
							if carData.SectorTimes {
								hasSectorTimes := true

								break
							}

						if hasSectorTimes
							standingsData .= (values2String(";", collect(["Position (Overall)", "Position (Class)", "Race Number", "Class", "Sector Times", "Lap Time"], translate)*) . "`n")
						else
							standingsData .= (values2String(";", collect(["Position (Overall)", "Position (Class)", "Race Number", "Class", "Lap Time"], translate)*) . "`n")

						for ignore, carData in this.Standings {
							if (A_Index > 1)
								standingsData .= "`n"

							if hasSectorTimes
								standingsData .= values2String(";", carData.OverallPosition, carData.ClassPosition, carData.Nr, carData.Class
																  , carData.SectorTimes ? values2String(",", carData.SectorTimes*) : "", carData.LapTime)
							else
								standingsData .= values2String(";", carData.OverallPosition, carData.ClassPosition, carData.Nr, carData.Class, carData.LapTime)
						}

						return substituteVariables(this.Instructions["Stint"], {lap: knowledgeBase.getValue("Lap"), position: position, carNumber: this.getNr()
																			  , laps: lapData, standings: standingsData})
					}
				}
			case "Knowledge":
				if knowledgeBase
					return substituteVariables(this.Instructions["Knowledge"], {knowledge: StrReplace(JSON.print(this.getKnowledge("Conversation")), "%", "\%")})
			case "Handling":
				if (knowledgeBase && this.Announcements["HandlingInformation"]) {
					collector := this.iIssueCollector

					if collector {
						issues := collector.Handling

						handling := ""
						index := 0

						for ignore, type in ["Oversteer", "Understeer"]
							for ignore, speed in ["Slow", "Fast"]
								for ignore, where in ["Entry", "Apex", "Exit"]
									for ignore, issue in issues[type . ".Corner." . where . "." . speed] {
										if (++index > 1)
											handling .= "`n"

										handling .= ("- " . substituteVariables(translate("%severity% %type% at %speed% corner %where%")
																			  , {severity: translate(issue.Severity . A_Space)
																			   , type: translate(type . A_Space), speed: translate(speed . A_Space)
																			   , where: where . A_Space}))
									}

						if index
							return substituteVariables(this.Instructions["Handling"], {handling: handling})
					}
				}
			case "Coaching":
				if ((knowledgeBase || isDebug()) && this.CoachingActive && (this.Mode = "Conversation")) {
					telemetry := this.getTelemetry()

					if (this.TelemetryAnalyzer && (telemetry.Length > 0) && (Trim(this.Instructions["Coaching"]) != ""))
						return substituteVariables(this.Instructions["Coaching"] . "`n`n%telemetry%"
												 , {name: this.VoiceManager.Name
												  , telemetry: values2String("`n`n", collect(telemetry, (t) => t.JSON)*)})
				}
		}

		return false
	}

	getInstructions() {
		return choose(collect(this.Instructions[true], ObjBindMethod(this, "getInstruction"))
					, (instruction) => (instruction && (Trim(instruction) != "")))
	}

	getTools() {
		return []
	}

	startConversation() {
		local service := this.Options["Driving Coach.Service"]
		local ignore, instruction

		this.iTranscript := (normalizeDirectoryPath(this.Options["Driving Coach.Archive"]) . "\" . translate("Conversation ") . A_Now . ".txt")

		if service {
			service := string2Values("|", service)

			if !inList(this.Providers, service[1])
				throw "Unsupported service detected in DrivingCoach.startConversation..."

			if (service[1] = "LLM Runtime")
				this.iConnector := LLMConnector.LLMRuntimeConnector(this, this.Options["Driving Coach.Model"]
																		, this.Options["Driving Coach.GPULayers"])
			else
				try {
					this.iConnector := LLMConnector.%StrReplace(service[1], A_Space, "")%Connector(this, this.Options["Driving Coach.Model"])

					this.Connector.Connect(service[2], service[3])

					this.connectorState("Active")
				}
				catch Any as exception {
					logError(exception)

					this.connectorState("Error", "Configuration")

					throw "Unsupported service detected in DrivingCoach.startConversation..."
				}

			this.Connector.MaxTokens := this.Options["Driving Coach.MaxTokens"]
			this.Connector.Temperature := this.Options["Driving Coach.Temperature"]
			this.Connector.MaxHistory := this.Options["Driving Coach.MaxHistory"]

			for ignore, instruction in this.Instructions[true] {
				this.Instructions[instruction] := this.Options["Driving Coach.Instructions." . instruction]

				if !this.Instructions[instruction]
					this.Instructions[instruction] := ""
			}
		}
		else
			throw "Unsupported service detected in DrivingCoach.startConversation..."
	}

	restartConversation() {
		if this.Connector
			this.Connector.Restart()
	}

	handleVoiceCommand(grammar, words) {
		switch grammar, false {
			case "CoachingStart":
				this.coachingStartRecognized(words)
			case "CoachingFinish":
				this.coachingFinishRecognized(words)
			case "ReviewCorner":
				if this.CoachingActive
					this.reviewCornerRecognized(words)
				else
					this.handleVoiceText("TEXT", values2String(A_Space, words*))
			case "ReviewLap":
				if this.CoachingActive
					this.reviewLapRecognized(words)
				else
					this.handleVoiceText("TEXT", values2String(A_Space, words*))
			case "TrackCoachingStart":
				if this.CoachingActive
					this.trackCoachingStartRecognized(words)
				else
					this.handleVoiceText("TEXT", values2String(A_Space, words*))
			case "TrackCoachingFinish":
				if this.CoachingActive
					this.trackCoachingFinishRecognized(words)
				else
					this.handleVoiceText("TEXT", values2String(A_Space, words*))
			default:
				super.handleVoiceCommand(grammar, words)
		}
	}

	coachingStartRecognized(words) {
		if !this.Connector
			this.startConversation()

		this.getSpeaker().speakPhrase("ConfirmCoaching")

		this.iCoachingActive := true
	}

	coachingFinishRecognized(words) {
		this.getSpeaker().speakPhrase("Roger")

		this.shutdownCoaching()
	}

	reviewCornerRecognized(words) {
		local corner := this.getNumber(words)
		local oldMode := this.Mode
		local telemetry

		this.Mode := "Coaching"

		try {
			if (corner = kUndefined)
				this.getSpeaker().speakPhrase("Repeat")
			else {
				telemetry := this.getTelemetry(corner)

				if (this.TelemetryAnalyzer && (telemetry.Length > 0))
					this.handleVoiceText("TEXT", substituteVariables(this.Instructions["Coaching.Corner"]
																   , {telemetry: values2String("`n`n", collect(telemetry, (t) => t.JSON)*)
																	, corner: corner}))
				else
					this.getSpeaker().speakPhrase("Later")
			}
		}
		finally {
			this.Mode := oldMode
		}
	}

	reviewLapRecognized(words) {
		local telemetry := this.getTelemetry()
		local oldMode := this.Mode

		this.Mode := "Coaching"

		try {
			if (this.TelemetryAnalyzer && (telemetry.Length > 0))
				this.handleVoiceText("TEXT", substituteVariables(this.Instructions["Coaching.Lap"]
															   , {telemetry: values2String("`n`n", collect(telemetry, (t) => t.JSON)*)}))
			else
				this.getSpeaker().speakPhrase("Later")
		}
		finally {
			this.Mode := oldMode
		}
	}

	trackCoachingStartRecognized(words, confirm := true) {
		if this.startupTrackCoaching() {
			if confirm
				this.getSpeaker().speakPhrase("Roger")
		}
		else
			this.getSpeaker().speakPhrase("Later")
	}

	trackCoachingFinishRecognized(words) {
		this.getSpeaker().speakPhrase("Okay")

		this.shutdownTrackCoaching()
	}

	handleVoiceText(grammar, text, reportError := true) {
		local answer := false
		local ignore, part

		static report := true

		try {
			if (this.Speaker && this.Options["Driving Coach.Confirmation"] && (this.ConnectionState = "Active"))
				this.getSpeaker().speakPhrase("Confirm", false, false, false, {Noise: false})

			if !this.Connector
				this.startConversation()

			answer := this.Connector.Ask(text)

			if answer
				report := true
			else if (this.Speaker && report) {
				if reportError
					this.getSpeaker().speakPhrase("Later", false, false, false, {Noise: false})

				report := false
			}
		}
		catch Any as exception {
			if report {
				if (this.Speaker && reportError)
					this.getSpeaker().speakPhrase("Later", false, false, false, {Noise: false})

				report := false

				logError(exception, true)

				logMessage(kLogCritical, substituteVariables(translate("Cannot connect to GPT service (%service%) - please check the configuration")
														   , {service: this.Options["Driving Coach.Service"]}))

				showMessage(substituteVariables(translate("Cannot connect to GPT service (%service%) - please check the configuration...")
											  , {service: this.Options["Driving Coach.Service"]})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}

		if answer {
			answer := StrReplace(answer, "*", "")

			if this.Speaker
				if this.VoiceManager.UseTalking
					this.getSpeaker().speak(answer, false, false, {Noise: false, Rephrase: false})
				else
					for ignore, part in string2Values(". ", answer)
						this.getSpeaker().speak(part . ".", false, false, {Noise: false, Rephrase: false, Click: (A_Index = 1)})

			if (this.Transcript && (this.Mode = "Conversation"))
				FileAppend(translate("-- Driver --------") . "`n`n" . text . "`n`n" . translate("-- Coach ---------") . "`n`n" . answer . "`n`n", this.Transcript, "UTF-16")
		}
	}

	stopIssueCollector(arguments*) {
		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		this.stopIssueAnalyzer()

		if this.iIssueCollector {
			this.iIssueCollector.deleteSamples()

			this.iIssueCollector := false
		}

		return false
	}

	startIssueAnalyzer() {
		local knowledgeBase := this.KnowledgeBase

		this.stopIssueCollector()

		if knowledgeBase {
			this.iIssueCollector := %this.CollectorClass%(this.Simulator, knowledgeBase.getValue("Session.Car"), knowledgeBase.getValue("Session.Track")
															, {Handling: true, Frequency: 5000})

			this.iIssueCollector.loadFromSettings()

			this.iIssueCollector.startIssueCollector()
		}

		return this.iIssueCollector
	}

	stopIssueAnalyzer() {
		if this.iIssueCollector
			this.iIssueCollector.stopIssueCollector()
	}

	startCoaching() {
		this.coachingStartRecognized([])
	}

	finishCoaching() {
		this.coachingFinishRecognized([])
	}

	startTrackCoaching() {
		if !this.CoachingActive {
			this.coachingStartRecognized([])

			this.trackCoachingStartRecognized([], false)
		}
		else
			this.trackCoachingStartRecognized([])
	}

	finishTrackCoaching() {
		this.trackCoachingFinishRecognized([])
	}

	startupCoaching() {
		local state

		if !this.TelemetryCollector {
			this.startupTelemetryCollector()

			state := newMultiMap()

			setMultiMapValue(state, "Coaching", "Active", true)

			writeMultiMap(kTempDirectory . "Driving Coach\Coaching.state", state)
		}
	}

	shutdownCoaching() {
		local state := newMultiMap()

		this.shutdownTrackTrigger()

		if this.TelemetryCollector
			this.shutdownTelemetryCollector()

		this.iCoachingActive := false
		this.iAvailableTelemetry := CaseInsenseMap()

		setMultiMapValue(state, "Coaching", "Active", false)

		writeMultiMap(kTempDirectory . "Driving Coach\Coaching.state", state)
	}

	startupTrackCoaching() {
		local state := readMultiMap(kTempDirectory . "Driving Coach\Coaching.state")
		local started := this.startupTrackTrigger()

		setMultiMapValue(state, "Coaching", "Track", started)

		writeMultiMap(kTempDirectory . "Driving Coach\Coaching.state", state)

		return started
	}

	shutdownTrackCoaching() {
		local state := readMultiMap(kTempDirectory . "Driving Coach\Coaching.state")

		this.shutdownTrackTrigger()

		setMultiMapValue(state, "Coaching", "Track", false)

		writeMultiMap(kTempDirectory . "Driving Coach\Coaching.state", state)
	}

	telemetryAvailable(laps) {
		local bestLap, bestLaptime, bestInfo, telemetries, data
		local ignore, lap, candidate, sessionDB, info, lapTime, size

		if (this.AvailableTelemetry.Count = 0) {
			this.getSpeaker().speakPhrase("CoachingReady", false, true)

			if getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Reference.Database", false) {
				sessionDB := SessionDatabase()
				bestLap := kUndefined

				sessionDB.getTelemetryNames(this.Simulator, this.Car, this.Track, &telemetries := true, &ignore := false)

				for ignore, candidate in telemetries {
					info := sessionDB.readTelemetryInfo(this.Simulator, this.Car, this.Track, candidate)

					lapTime := getMultiMapValue(info, "Lap", "LapTime", false)

					if (lapTime && ((bestLap == kUndefined) || (lapTime < bestLapTime))) {
						bestLap := candidate
						bestLapTime := lapTime
						bestInfo := info
					}
				}

				if (bestLap != kUndefined) {
					data := session.readTelemetry(this.Simulator, this.Car, this.Track, bestLap, &size)

					if data {
						deleteFile(kTempDirectory . "Driving Coach\Telemetry\Reference.telemetry")

						file := FileOpen(kTempDirectory . "Driving Coach\Telemetry\Reference.telemetry", "w", "")

						if file {
							file.RawWrite(data, size)

							file.Close()

							info := newMultiMap()

							setMultiMapValue(info, "Info", "Driver", getMultiMapValue(bestInfo, "Lap", "Driver", SessionDatabase.getUserName()))
							setMultiMapValue(info, "Info", "LapTime", bestLapTime)

							if getMultiMapValue(bestInfo, "Lap", "SectorTimes", false)
								setMultiMapValue(info, "Info", "SectorTimes", getMultiMapValue(bestInfo, "Lap", "SectorTimes"))

							writeMultiMap(kTempDirectory . "Driving Coach\Telemetry\Reference.telemetry.info", info)

							this.AvailableTelemetry[0] := true
						}
					}
				}
			}
		}

		for ignore, lap in laps
			this.AvailableTelemetry[lap] := true
	}

	getTelemetry(corner := false) {
		local result := []
		local mode := getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Reference", "Fastest")
		local laps := getKeys(this.AvailableTelemetry)
		local theLap := false
		local bestLap := false
		local lastLap := false
		local ignore, lap, found, fileName, info, driver, lapTime, sectorTimes, lapNr, telemetry

		for ignore, lap in bubbleSort(&laps, (a, b) => (a < b)) {
			if (theLap && (mode = "None"))
				break
			else if ((mode = "Last") && theLap && lastLap)
				break

			lapNr := lap

			if (this.AvailableTelemetry[lapNr] == true) {
				if (lapNr = 0)
					fileName := (kTempDirectory . "Driving Coach\Telemetry\Reference.telemetry")
				else
					fileName := (kTempDirectory . "Driving Coach\Telemetry\Lap " . lapNr . ".telemetry")

				info := readMultiMap(fileName . ".info")

				driver := getMultiMapValue(info, "Info", "Driver", SessionDatabase.getUserName())
				lapTime := getMultiMapValue(info, "Info", "LapTime", false)
				sectorTimes := getMultiMapValue(info, "Info", "SectorTimes", false)

				this.AvailableTelemetry[lapNr] := [this.TelemetryAnalyzer.createTelemetry(lapNr, fileName)
												 , driver, lapTime, sectorTimes]
			}

			lap := this.AvailableTelemetry[lap]

			if corner {
				telemetry := lap[1].Clone()
				lap := lap.Clone()

				lap[1] := telemetry

				found := false

				telemetry.Sections := choose(telemetry.Sections, (section) {
										  if ((section.Type = "Corner") && (section.Nr = corner)) {
											  found := true

											  return true
										  }
										  else if found {
											  found := false

											  return true
										  }
										  else
											  return false
									  })
			}

			if (!theLap && (lapNr != 0))
				theLap := lap[1]
			else if (theLap && !lastLap && (lapNr != 0))
				lastLap := lap[1]
			else if theLap
				if (!bestLap || (lap[3] < bestLap[3]))
					bestLap := lap
		}

		if theLap {
			if ((mode = "Fastest") && bestLap)
				result.Push(bestLap[1])
			else if ((mode = "Last") && lastLap)
				result.Push(lastLap)

			result.Push(theLap)
		}

		return result
	}

	startupTelemetryCollector() {
		local loadedLaps

		updateTelemetry() {
			local knowledgeBase := this.KnowledgeBase
			local newLaps := []
			local lap, car, driver, lapTime, sectorTimes, info

			if knowledgeBase
				loop Files, kTempDirectory . "Driving Coach\Telemetry\*.telemetry" {
					lap := StrReplace(StrReplace(A_LoopFileName, "Lap ", ""), ".telemetry", "")

					if (!loadedLaps.Has(lap) && knowledgeBase.hasFact("Lap." . lap . ".Driver.ForName")) {
						car := knowledgeBase.getValue("Driver.Car", kUndefined)

						driver := driverName(knowledgeBase.getValue("Lap." . lap . ".Driver.ForName")
										   , knowledgeBase.getValue("Lap." . lap . ".Driver.SurName")
										   , knowledgeBase.getValue("Lap." . lap . ".Driver.NickName"))
						lapTime := (this.getLapTime(car) / 1000)
						sectorTimes := this.getSectorTimes(car)

						info := newMultiMap()

						setMultiMapValue(info, "Info", "Driver", driver)

						if lapTime
							setMultiMapValue(info, "Info", "LapTime", lapTime)

						if (sectorTimes && (sectorTimes.Length > 0))
							setMultiMapValue(info, "Info", "SectorTimes", values2String(",", sectorTimes*))

						writeMultiMap(A_LoopFileFullPath . ".info", info)

						newLaps.Push(lap)

						loadedLaps[lap] := true
					}
				}

			if (newLaps.Length > 0) {
				bubbleSort(&newLaps)

				this.telemetryAvailable(newLaps)
			}
		}

		if (!this.TelemetryCollector && this.Simulator && this.Track && ((this.TrackLength > 0) || isDebug())) {
			DirCreate(kTempDirectory . "Driving Coach")
			DirCreate(kTempDirectory . "Driving Coach\Telemetry")

			if !isDebug()
				deleteDirectory(kTempDirectory . "Driving Coach\Telemetry")

			this.iTelemetryAnalyzer := TelemetryAnalyzer(this.Simulator, this.Track)
			this.iTelemetryCollector := TelemetryCollector(kTempDirectory . "Driving Coach\Telemetry", this.Simulator, this.Track, this.TrackLength)

			this.iTelemetryCollector.startup()

			loadedLaps := CaseInsenseMap()

			this.iCollectorTask := PeriodicTask(updateTelemetry, 10000, kLowPriority)

			this.iCollectorTask.start()
		}
	}

	shutdownTelemetryCollector() {
		if this.TelemetryCollector
			this.TelemetryCollector.shutdown()

		if this.iCollectorTask
			this.iCollectorTask.stop()

		this.iTelemetryAnalyzer := false
		this.iTelemetryCollector := false
		this.iCollectorTask := false
	}

	startupTrackTrigger() {
		local simulator := this.Simulator
		local analyzer := this.TelemetryAnalyzer
		local sections, positions, sessionDB, code, data, exePath, pid
		local ignore, section, x, y

		static distance := false

		if (!this.iTrackTriggerPID && simulator && analyzer) {
			sections := analyzer.TrackSections

			if (sections && (sections.Length > 0)) {
				positions := ""

				if !distance
					distance := - Abs(getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Corner.Distance", 400))

				for ignore, section in sections
					if (section.Type = "Corner") {
						if analyzer.getSectionCoordinateIndex(section, &x, &y, &ignore, distance)
							positions .= (A_Space . x . A_Space . y)
						else
							positions .= (A_Space . -32767 . A_Space . -32767)
					}
					else
						positions .= (A_Space . -32767 . A_Space . -32767)

				sessionDB := SessionDatabase()

				code := sessionDB.getSimulatorCode(simulator)
				data := sessionDB.getTrackData(simulator, this.Track)

				exePath := (kBinariesDirectory . "Providers\" . code . " SHM Spotter.exe")
				pid := false

				try {
					if !FileExist(exePath)
						throw "File not found..."

					if data
						Run("`"" . exePath . "`" -Trigger `"" . data . "`" " . positions, kBinariesDirectory, "Hide", &pid)
					else
						Run("`"" . exePath . "`" -Trigger " . positions, kBinariesDirectory, "Hide", &pid)
				}
				catch Any as exception {
					logError(exception, true)

					logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (")
															   , {simulator: code, protocol: "SHM"})
										   . exePath . translate(") - please rebuild the applications in the binaries folder (")
										   . kBinariesDirectory . translate(")"))

					showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Spotter (%exePath%) - please check the configuration...")
												  , {exePath: exePath, simulator: code, protocol: "SHM"})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}

				if pid
					this.iTrackTriggerPID := pid
			}
		}

		return (this.iTrackTriggerPID != false)
	}

	shutdownTrackTrigger(force := false, arguments*) {
		local pid := this.iTrackTriggerPID
		local tries

		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		if pid {
			ProcessClose(pid)

			if (force && ProcessExist(pid)) {
				Sleep(500)

				tries := 5

				while (tries-- > 0) {
					pid := ProcessExist(pid)

					if pid {
						ProcessClose(pid)

						Sleep(500)
					}
					else
						break
				}
			}

			this.iTrackTriggerPID := false
		}

		return false
	}

	prepareSession(&settings, &data, formationLap := true) {
		local prepared := this.Prepared
		local announcements := false
		local facts

		if !prepared {
			if formationLap {
				this.updateDynamicValues({KnowledgeBase: false
										, OverallTime: 0, BestLapTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0, EnoughData: false})
				this.updateSessionValues({Simulator: "", Car: "", Track: "", Session: kSessionFinished, SessionTime: false, Laps: Map(), Standings: []})
			}

			this.restartConversation()
		}

		facts := super.prepareSession(&settings, &data, formationLap)

		if (!prepared && settings) {
			this.updateConfigurationValues({UseTalking: getMultiMapValue(settings, "Assistant.Coach", "Voice.UseTalking", true)})

			if (this.Session = kSessionPractice)
				announcements := {SessionInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Practice.Session", true)
								, StintInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Practice.Stint", true)
								, HandlingInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Practice.Handling", true)}
			else if (this.Session = kSessionQualification)
				announcements := {SessionInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Qualification.Session", true)
								, StintInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Qualification.Stint", true)
								, HandlingInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Qualification.Handling", false)}
			else if (this.Session = kSessionRace)
				announcements := {SessionInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Race.Session", true)
								, StintInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Race.Stint", true)
								, HandlingInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Race.Handling", false)}

			if announcements
				this.updateConfigurationValues({Announcements: announcements})
		}

		if this.CoachingActive
			this.startupCoaching()

		return facts
	}

	startSession(settings, data) {
		local facts := this.prepareSession(&settings, &data, false)

		this.updateConfigurationValues({LearningLaps: 1, AdjustLapTime: true, SaveSettings: false})

		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts)
								, BestLapTime: 0, OverallTime: 0, LastFuelAmount: 0
								, InitialFuelAmount: 0, EnoughData: false})

		this.updateSessionValues({Standings: [], Laps: Map()})

		; this.initializeGridPosition(data)

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)

		if this.Announcements["HandlingInformation"]
			this.startIssueAnalyzer()
	}

	finishSession(shutdown := true) {
		this.stopIssueAnalyzer()
		this.updateDynamicValues({Prepared: false})
	}

	updateLaps(lapNumber, data) {
		local knowledgeBase := this.KnowledgeBase
		local driver := knowledgeBase.getValue("Driver.Car", false)
		local standingsData := CaseInsenseWeakMap()
		local standings := []
		local keys, ignore, car, carData, sectorTimes

		if driver {
			sectorTimes := this.getSectorTimes(driver)

			if sectorTimes {
				sectorTimes := sectorTimes.Clone()

				loop sectorTimes.Length
					sectorTimes[A_Index] := Round(sectorTimes[A_Index] / 1000, 1)
			}
			else
				sectorTimes := false

			this.Laps[lapNumber] := {Class: this.getClass(driver), OverallPosition: this.getPosition(driver), ClassPosition: this.getPosition(driver, "Class")
								   , SectorTimes: sectorTimes, LapTime: Round(this.getLapTime(driver) / 1000, 1)}

			for ignore, car in this.getCars() {
				sectorTimes := this.getSectorTimes(car)

				if sectorTimes {
					sectorTimes := sectorTimes.Clone()

					loop sectorTimes.Length
						sectorTimes[A_Index] := Round(sectorTimes[A_Index] / 1000, 1)
				}
				else
					sectorTimes := false

				carData := {Nr: this.getNr(car), Class: this.getClass(car)
						  , OverallPosition: this.getPosition(car), ClassPosition: this.getPosition(car, "Class")
						  , SectorTimes: sectorTimes, LapTime: Round(this.getLapTime(car) / 1000, 1)}

				standingsData[carData.OverallPosition] := carData
			}

			loop standingsData.Count
				if standingsData.Has(A_Index)
					standings.Push(standingsData[A_Index])

			this.Standings := standings
		}
	}

	addLap(lapNumber, &data) {
		local result := super.addLap(lapNumber, &data)

		this.updateLaps(lapNumber, data)

		if this.CoachingActive
			this.startupCoaching()

		return result
	}

	updateLap(lapNumber, &data, arguments*) {
		local result := super.updateLap(lapNumber, &data, arguments*)

		if this.CoachingActive
			this.startupCoaching()

		return result
	}

	positionTrigger(sectionNr, positionX, positionY) {
		local cornerNr := this.TelemetryAnalyzer.TrackSections[sectionNr].Nr
		local oldMode := this.Mode
		local telemetry

		static nextRecommendation := false
		static wait := false

		if ((Round(positionX) = -32767) && (Round(positionY) = -32767))
			return

		if !wait
			wait := (getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Corner.Wait", 10) * 1000)

		telemetry := this.getTelemetry(cornerNr)

		if (this.TelemetryAnalyzer && (telemetry.Length > 0)) {
			if (A_TickCount < nextRecommendation)
				return
			else if (Random(1, 10) > 3) {
				nextRecommendation := (A_TickCount + wait)

				this.Mode := "Coaching"

				try {
					this.handleVoiceText("TEXT", substituteVariables(this.Instructions["Coaching.Corner.Short"]
																   , {telemetry: values2String("`n`n", collect(telemetry, (t) => t.JSON)*)
																	, corner: cornerNr})
											   , false)
				}
				finally {
					this.Mode := oldMode
				}
			}
		}
	}
}