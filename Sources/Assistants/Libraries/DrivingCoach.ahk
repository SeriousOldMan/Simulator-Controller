﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Driving Coach                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\JSON.ahk"
#Include "..\..\Framework\Extensions\HTTP.ahk"
#Include "..\..\Framework\Extensions\LLMConnector.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"
#Include "..\..\Database\Libraries\TelemetryCollector.ahk"
#Include "..\..\Database\Libraries\TelemetryAnalyzer.ahk"
#Include "..\..\Garage\Libraries\IssueCollector.ahk"
#Include "..\..\Garage\Libraries\IRCIssueCollector.ahk"
#Include "..\..\Garage\Libraries\R3EIssueCollector.ahk"
#Include "RaceAssistant.ahk"


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

	iReferenceMode := "None"
	iReferenceModeAuto := true
	iLoadReference := "None"

	iOnTrackCoaching := false
	iFocusedCorners := []
	iTelemetryFuture := false

	iAvailableTelemetry := CaseInsenseMap()
	iInstructionHints := CaseInsenseMap()

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
					return ["Character", "Simulation", "Session", "Stint", "Knowledge", "Handling", "Coaching", "Coaching.Lap", "Coaching.Corner", "Coaching.Corner.Approaching", "Coaching.Corner.Problems", "Coaching.Corner.Review", "Coaching.Reference"]
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
				this.Connector.History := ((value = "Conversation") || (value = "Review"))

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

	OnTrackCoaching {
		Get {
			return this.iOnTrackCoaching
		}
	}

	FocusedCorners {
		Get {
			return this.iFocusedCorners
		}
	}

	CoachingActive {
		Get {
			return this.iCoachingActive
		}
	}

	ReferenceMode {
		Get {
			return this.iReferenceMode
		}
	}

	LoadReference {
		Get {
			return this.iLoadReference
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

		this.loadInstructions(configuration)

		this.updateConfigurationValues({Announcements: {SessionInformation: true, StintInformation: false, HandlingInformation: false}
									  , OnTrackCoaching: false})

		try {
			DirCreate(this.Options["Driving Coach.Archive"])
		}
		catch Any as exception {
			logError(exception)
		}

		OnExit(ObjBindMethod(this, "stopIssueCollector"))
		OnExit((*) {
			if this.TelemetryCollector
				this.TelemetryCollector.shutdown()
		})
		OnExit(ObjBindMethod(this, "shutdownTrackTrigger", true))
	}

	loadFromConfiguration(configuration) {
		local options

		super.loadFromConfiguration(configuration)

		options := this.Options

		options["Driving Coach.Archive"] := getMultiMapValue(configuration, "Driving Coach Conversations", "Archive", kTempDirectory . "Conversations")

		if (!options["Driving Coach.Archive"] || (Trim(options["Driving Coach.Archive"]) = ""))
			options["Driving Coach.Archive"] := (kTempDirectory . "Conversations")

		options["Driving Coach.Service"] := getMultiMapValue(configuration, "Driving Coach Service", "Service", getMultiMapValue(configuration, "Driving Coach", "Service", false))
		options["Driving Coach.Model"] := getMultiMapValue(configuration, "Driving Coach Service", "Model", false)
		options["Driving Coach.MaxTokens"] := getMultiMapValue(configuration, "Driving Coach Service", "MaxTokens", 2048)
		options["Driving Coach.Temperature"] := getMultiMapValue(configuration, "Driving Coach Personality", "Temperature", 0.5)

		if (string2Values("|", options["Driving Coach.Service"], 2)[1] = "LLM Runtime")
			options["Driving Coach.GPULayers"] := getMultiMapValue(configuration, "Driving Coach Service", "GPULayers", 0)

		options["Driving Coach.MaxHistory"] := getMultiMapValue(configuration, "Driving Coach Personality", "MaxHistory", 3)
		options["Driving Coach.Confirmation"] := getMultiMapValue(configuration, "Driving Coach Personality", "Confirmation", true)
	}

	loadInstructions(configuration) {
		local options, laps, ignore, instruction

		options := this.Options

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

	updateConfigurationValues(values) {
		local lapName

		super.updateConfigurationValues(values)

		if (values.HasProp("Settings") && this.iReferenceModeAuto) {
			this.iReferenceMode := getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Reference", "Fastest")
			this.iLoadReference := getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Reference.Database", "None")

			if !this.LoadReference
				this.iLoadReference := "None"
			else if (this.LoadReference == true)
				this.iLoadReference := "Fastest"

			if (this.LoadReference = "Named") {
				lapName := getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Reference.Database.Name", "")

				if (Trim(lapName) != "")
					this.iLoadReference := lapName
			}

			TelemetryAnalyzer.TCActivationsThreshold
				:= getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Threshold.TCActivations", 20)
			TelemetryAnalyzer.ABSActivationsThreshold
				:= getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Threshold.ABSActivations", 30)
			TelemetryAnalyzer.SteeringSmoothnessThreshold
				:= getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Threshold.SteeringSmoothnessThreshold", 90)
			TelemetryAnalyzer.ThrottleSmoothnessThreshold
				:= getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Threshold.ThrottleSmoothnessThreshold", 90)
			TelemetryAnalyzer.BrakeSmoothnessThreshold
				:= getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Threshold.BrakeSmoothnessThreshold", 90)
		}

		if values.HasProp("OnTrackCoaching")
			this.iOnTrackCoaching := values.OnTrackCoaching
	}

	updateSessionValues(values) {
		super.updateSessionValues(values)

		if values.HasProp("Laps")
			this.iLaps := values.Laps
		else if values.HasProp("Standings")
			this.iStandings := values.Standings

		if (values.HasProp("Session") && (values.Session == kSessionFinished) && (this.Session != kSessionFinished))
			if this.CoachingActive
				this.shutdownTelemetryCoaching(false)
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
		local key, value, text, filter, telemetry, reference, command

		static sessions := false

		if !sessions {
			sessions := ["Other", "Practice", "Qualifying", "Race", "Time Trial"]

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
				if (knowledgeBase && (this.Mode = "Conversation"))
					return substituteVariables(this.Instructions["Knowledge"], {knowledge: StrReplace(JSON.print(this.getKnowledge("Conversation")), "%", "\%")})
			case "Handling":
				if (knowledgeBase && this.Announcements["HandlingInformation"] && (this.Mode = "Conversation")) {
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
																			   , type: translate(type . A_Space)
																			   , speed: translate(speed . A_Space)
																			   , where: translate(where . A_Space)}))
									}

						if index
							return substituteVariables(this.Instructions["Handling"], {handling: handling})
					}
				}
			case "Coaching":
				if ((knowledgeBase || isDebug()) && this.CoachingActive && this.TelemetryAnalyzer && (Trim(this.Instructions["Coaching"]) != ""))
					if (this.Mode = "Conversation") {
						telemetry := this.getTelemetry(&reference := true)

						if telemetry {
							command := substituteVariables(this.Instructions["Coaching"] . "`n`n%telemetry%"
														 , {telemetry: telemetry.JSON})

							if reference
								command .= ("`n`n" . substituteVariables(this.Instructions["Coaching.Reference"]
																	   , {telemetry: reference.JSON}))

							return command
						}
					}
					else
						return this.Instructions["Coaching"]
		}

		return false
	}

	getInstructions() {
		return choose(collect(this.Instructions[true], ObjBindMethod(this, "getInstruction"))
					, (instruction) => (instruction && (Trim(instruction) != "")))
	}

	startConversation() {
		local service := this.Options["Driving Coach.Service"]
		local ignore, instruction

		this.iTranscript := (normalizeDirectoryPath(this.Options["Driving Coach.Archive"]) . "\" . translate("Conversation ") . A_Now . ".txt")

		if service {
			service := string2Values("|", service, 3)

			if !inList(this.Providers, service[1])
				throw "Unsupported service detected in DrivingCoach.startConversation..."

			try {
				if (!this.Options["Driving Coach.Model"] || (Trim(this.Options["Driving Coach.Model"]) = ""))
					throw "Empty model detected in DrivingCoach.startConversation..."
				else if (service[1] = "LLM Runtime")
					this.iConnector := LLMConnector.LLMRuntimeConnector(this, this.Options["Driving Coach.Model"]
																			, this.Options["Driving Coach.GPULayers"])
				else {
					this.iConnector := LLMConnector.%StrReplace(service[1], A_Space, "")%Connector(this, this.Options["Driving Coach.Model"])

					this.Connector.Connect(service[2], service[3])

					this.connectorState("Active")
				}
			}
			catch Any as exception {
				logError(exception)

				this.iConnector := false

				this.connectorState("Error", "Configuration")

				return false
			}

			this.Connector.MaxTokens := this.Options["Driving Coach.MaxTokens"]
			this.Connector.Temperature := this.Options["Driving Coach.Temperature"]
			this.Connector.MaxHistory := this.Options["Driving Coach.MaxHistory"]

			for ignore, instruction in this.Instructions[true] {
				this.Instructions[instruction] := this.Options["Driving Coach.Instructions." . instruction]

				if !this.Instructions[instruction]
					this.Instructions[instruction] := ""
			}

			return true
		}
		else {
			this.connectorState("Error", "Configuration")

			return false
		}
	}

	restartConversation() {
		if this.Connector
			this.Connector.Restart()
	}

	handleVoiceCommand(grammar, words) {
		switch grammar, false {
			case "CoachingStart":
				this.clearContinuation()

				this.telemetryCoachingStartRecognized(words)
			case "CoachingFinish":
				this.clearContinuation()

				this.telemetryCoachingFinishRecognized(words)
			case "ReviewCorner":
				this.clearContinuation()

				if this.CoachingActive
					this.reviewCornerRecognized(words)
				else
					this.handleVoiceText("TEXT", values2String(A_Space, words*))
			case "ReviewLap":
				this.clearContinuation()

				if this.CoachingActive
					this.reviewLapRecognized(words)
				else
					this.handleVoiceText("TEXT", values2String(A_Space, words*))
			case "TrackCoachingStart":
				this.clearContinuation()

				if this.CoachingActive
					this.trackCoachingStartRecognized(words)
				else
					this.handleVoiceText("TEXT", values2String(A_Space, words*))
			case "TrackCoachingFinish":
				this.clearContinuation()

				if this.CoachingActive
					this.trackCoachingFinishRecognized(words)
				else
					this.handleVoiceText("TEXT", values2String(A_Space, words*))
			case "ReferenceLap":
				this.clearContinuation()

				this.referenceLapRecognized(words)
			case "NoReferenceLap":
				this.clearContinuation()

				this.noReferenceLapRecognized(words)
			case "FocusCorner":
				this.clearContinuation()

				this.focusCornerRecognized(words)
			case "NoFocusCorner":
				this.clearContinuation()

				this.noFocusCornerRecognized(words)
			default:
				super.handleVoiceCommand(grammar, words)
		}
	}

	telemetryCoachingStartRecognized(words, confirm := true, auto := false) {
		if !this.Connector
			this.startConversation()

		if (confirm && this.Speaker)
			this.getSpeaker().speakPhrase(auto ? "StartCoaching" : "ConfirmCoaching")

		this.iCoachingActive := true

		this.startupTelemetryCoaching()
	}

	telemetryCoachingFinishRecognized(words, confirm := true) {
		if (confirm && this.Speaker)
			this.getSpeaker().speakPhrase("Roger")

		this.shutdownTelemetryCoaching()
	}

	reviewCornerRecognized(words) {
		local cornerNr := this.getNumber(words)
		local oldMode := this.Mode
		local telemetry, reference, command

		this.Mode := "Review"

		try {
			if (cornerNr = kUndefined) {
				if this.Speaker
					this.getSpeaker().speakPhrase("Repeat")
			}
			else {
				telemetry := this.getTelemetry(&reference := true, cornerNr)

				if (this.TelemetryAnalyzer && telemetry && (telemetry.Sections.Length > 0)) {
					command := substituteVariables(this.Instructions["Coaching.Corner"]
												 , {telemetry: telemetry.JSON, corner: cornerNr})

					if reference
						command .= ("`n`n" . substituteVariables(this.Instructions["Coaching.Reference"]
															   , {telemetry: reference.JSON}))

					this.handleVoiceText("TEXT", command, true, values2String(A_Space, words*))
				}
				else if this.Speaker
					this.getSpeaker().speakPhrase("Later")
			}
		}
		finally {
			this.Mode := oldMode
		}
	}

	reviewLapRecognized(words) {
		local oldMode := this.Mode
		local telemetry, reference, command

		telemetry := this.getTelemetry(&reference := true)

		this.Mode := "Review"

		try {
			if (this.TelemetryAnalyzer && telemetry && (telemetry.Sections.Length > 0)) {
				command := substituteVariables(this.Instructions["Coaching.Lap"], {telemetry: telemetry.JSON})

				if reference
					command .= ("`n`n" . substituteVariables(this.Instructions["Coaching.Reference"]
														   , {telemetry: reference.JSON}))

				this.handleVoiceText("TEXT", command, true, values2String(A_Space, words*))
			}
			else if this.Speaker
				this.getSpeaker().speakPhrase("Later")
		}
		finally {
			this.Mode := oldMode
		}
	}

	trackCoachingStartRecognized(words, confirm := true) {
		if this.startupTrackCoaching() {
			if (confirm && this.Speaker)
				this.getSpeaker().speakPhrase("Roger")
		}
		else if (confirm && this.Speaker)
			this.getSpeaker().speakPhrase("Later")
	}

	trackCoachingFinishRecognized(words, confirm := true) {
		if (confirm && this.Speaker)
			this.getSpeaker().speakPhrase("Okay")

		this.shutdownTrackCoaching()
	}

	referenceLapRecognized(words) {
		local speaker

		if this.Speaker {
			speaker := this.getSpeaker()

			if inList(words, speaker.Fragments["Fastest"])
				this.iReferenceMode := "Fastest"
			else if inList(words, speaker.Fragments["Last"])
				this.iReferenceMode := "Last"
			else {
				speaker.speakPhrase("Repeat")

				return
			}

			this.iReferenceModeAuto := false

			speaker.speakPhrase("Roger")
		}
	}

	noReferenceLapRecognized(words) {
		if this.Speaker
			this.getSpeaker().speakPhrase("Roger")

		this.iReferenceMode := "None"
		this.iReferenceModeAuto := false
	}

	focusCornerRecognized(words, confirm := true) {
		local corner := this.getNumber(words)

		if (corner != kUndefined) {
			if this.startupTrackCoaching() {
				if (confirm && this.Speaker)
					this.getSpeaker().speakPhrase("Roger")

				corner := String(corner)

				if !inList(this.FocusedCorners, corner)
					this.FocusedCorners.Push(corner)
			}
			else if (confirm && this.Speaker)
				this.getSpeaker().speakPhrase("Later")
		}
		else
			this.getSpeaker().speakPhrase("Repeat")
	}

	noFocusCornerRecognized(words, confirm := true) {
		if (confirm && this.Speaker)
			this.getSpeaker().speakPhrase("Roger")

		this.iFocusedCorners := []
		this.iTelemetryFuture := false
	}

	handleVoiceText(grammar, text, reportError := true, originalText := false) {
		local answer := false
		local ignore, part, telemetry, reference, folder

		static report := true
		static conversationNr := 1

		normalizeAnswer(answer) {
			answer := Trim(StrReplace(StrReplace(answer, "*", ""), "|||", ""), " `t`r`n")

			while InStr(answer, "\n", , -2)
				answer := SubStr(answer, 1, StrLen(answer) - 2)

			return answer
		}

		try {
			if (this.Speaker && this.Options["Driving Coach.Confirmation"]
							 && (this.ConnectionState = "Active") && (this.Mode != "Coaching"))
				this.getSpeaker().speakPhrase("Confirm", false, false, false, {Noise: false})

			if (this.Connector || this.startConversation()) {
				answer := this.Connector.Ask(text)

				if answer {
					answer := normalizeAnswer(answer)

					report := true

					if (this.CoachingActive && !InStr(kVersion, "-release")) {
						if !FileExist(kTempDirectory . "Driving Coach\Conversations")
							conversationNr := 1

						DirCreate(kTempDirectory . "Driving Coach\Conversations")

						folder := (kTempDirectory . "Driving Coach\Conversations\" . Format("{:03}", conversationNr) . "\")

						DirCreate(folder)

						telemetry := telemetry := this.getTelemetry(&reference := true)

						if telemetry {
							FileAppend(telemetry.JSON, folder . "Telemetry.JSON")

							if reference
								FileAppend(reference.JSON, folder . "Reference.JSON")
						}

						FileAppend(translate("-- Driver --------") . "`n`n" . text . "`n`n" . translate("-- Coach ---------") . "`n`n" . answer . "`n`n", folder . "Conversation.txt", "UTF-16")

						conversationNr += 1
					}
				}
				else if (this.Speaker && report) {
					if reportError
						this.getSpeaker().speakPhrase("Later", false, false, false, {Noise: false})

					report := false
				}
			}
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

				if !kSilentMode
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

			if (this.Transcript && (this.Mode != "Coaching"))
				try {
					FileAppend(translate("-- Driver --------") . "`n`n" . (originalText ? originalText : text) . "`n`n" . translate("-- Coach ---------") . "`n`n" . answer . "`n`n", this.Transcript, "UTF-16")
				}
				catch Any as exception {
					logError(exception)
				}
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

	startTelemetryCoaching(confirm := true, auto := false) {
		if auto
			this.updateConfigurationValues({OnTrackCoaching: true})

		this.telemetryCoachingStartRecognized([], confirm, auto)
	}

	finishTelemetryCoaching(confirm := true) {
		this.telemetryCoachingFinishRecognized([], confirm)
	}

	startTrackCoaching(confirm := true) {
		if !this.CoachingActive {
			this.telemetryCoachingStartRecognized([], confirm)

			this.trackCoachingStartRecognized([], false)
		}
		else
			this.trackCoachingStartRecognized([], confirm)
	}

	finishTrackCoaching(confirm := true) {
		this.trackCoachingFinishRecognized([], confirm)
	}

	startupTelemetryCoaching() {
		local state

		if (!this.TelemetryCollector && this.startupTelemetryCollector()) {
			state := newMultiMap()

			setMultiMapValue(state, "Coaching", "Active", true)

			writeMultiMap(kTempDirectory . "Driving Coach\Coaching.state", state)
		}
	}

	shutdownTelemetryCoaching(deactivate := true) {
		local state := newMultiMap()

		this.shutdownTrackTrigger()

		if this.TelemetryCollector
			this.shutdownTelemetryCollector()

		this.iAvailableTelemetry := CaseInsenseMap()

		setMultiMapValue(state, "Coaching", "Active", false)

		writeMultiMap(kTempDirectory . "Driving Coach\Coaching.state", state)

		if deactivate {
			this.iCoachingActive := false

			this.iOnTrackCoaching := false
			this.iFocusedCorners := []
			this.iTelemetryFuture := false
		}
	}

	startupTrackCoaching() {
		local state := readMultiMap(kTempDirectory . "Driving Coach\Coaching.state")
		local started := this.startupTrackTrigger()

		setMultiMapValue(state, "Coaching", "Track", started)

		writeMultiMap(kTempDirectory . "Driving Coach\Coaching.state", state)

		this.iTelemetryFuture := false

		return started
	}

	shutdownTrackCoaching() {
		local state := readMultiMap(kTempDirectory . "Driving Coach\Coaching.state")

		this.shutdownTrackTrigger()

		setMultiMapValue(state, "Coaching", "Track", false)

		removeMultiMapValues(state, "Instructions")

		writeMultiMap(kTempDirectory . "Driving Coach\Coaching.state", state)

		this.iOnTrackCoaching := false
		this.iFocusedCorners := []
		this.iTelemetryFuture := false
	}

	telemetryAvailable(laps) {
		local bestLap, bestLaptime, bestInfo, telemetries, data
		local ignore, lap, candidate, sessionDB, info, lapTime, size, telemetry

		if (this.AvailableTelemetry.Count = 0) {
			if (this.Speaker[false] && !this.OnTrackCoaching)
				this.getSpeaker().speakPhrase("CoachingReady", false, true)

			if (this.TelemetryAnalyzer.TrackSections.Length = 0) {
				telemetry := this.TelemetryAnalyzer.createTelemetry(laps[1], kTempDirectory . "Driving Coach\Telemetry\Lap " . laps[1] . ".telemetry")

				this.TelemetryAnalyzer.requireTrackSections(telemetry)
			}

			if (this.LoadReference != "None") {
				sessionDB := SessionDatabase()
				bestLap := kUndefined

				if (this.LoadReference == "Fastest") {
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
				}
				else {
					info := sessionDB.readTelemetryInfo(this.Simulator, this.Car, this.Track, this.LoadReference)

					lapTime := getMultiMapValue(info, "Lap", "LapTime", false)

					if lapTime {
						bestLap := this.LoadReference
						bestLapTime := lapTime
						bestInfo := info
					}
				}

				if (bestLap != kUndefined) {
					data := sessionDB.readTelemetry(this.Simulator, this.Car, this.Track, bestLap, &size)

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

		if this.OnTrackCoaching
			this.startupTrackCoaching()
	}

	reviewCornerPerformance(cornerNr, fileName) {
		local oldMode := this.Mode
		local found := false
		local previousLap, currentLap, command, ignore

		if this.Speaker[false] {
			this.Mode := "Review"

			try {
				previousLap := this.getTelemetry(&ignore := false, cornerNr)
				currentLap := this.TelemetryAnalyzer.createTelemetry("Current", fileName)

				currentLap.Sections := choose(currentLap.Sections, (section) {
										   if found {
											   found := false

											   return true
										   }
										   else if ((section.Type = "Corner") && (section.Nr = cornerNr)) {
											   found := true

											   return true
										   }
										   else
											   return false
									   })

				if (this.TelemetryAnalyzer && previousLap && (previousLap.Sections.Length > 0)
										   && currentLap && (currentLap.Sections.Length > 0)) {
					command := substituteVariables(this.Instructions["Coaching.Corner.Review"]
												 , {previousLap: previousLap.JSON, currentLap: currentLap.JSON
												  , corner: cornerNr})

					this.handleVoiceText("TEXT", command, false)
				}
				else if this.Speaker
					this.getSpeaker().speakPhrase("Later")
			}
			finally {
				this.Mode := oldMode
			}
		}
	}

	getTelemetry(&reference?, corner?) {
		local mode := this.ReferenceMode
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

				if (sectorTimes && (Trim(sectorTimes) != ""))
					sectorTimes := string2Values(",", sectorTimes)
				else
					sectorTimes := false

				this.AvailableTelemetry[lapNr] := this.TelemetryAnalyzer.createTelemetry(lapNr ? lapNr : "Reference"
																					   , fileName, driver, lapTime, sectorTimes)
			}

			lap := this.AvailableTelemetry[lap]

			if (isSet(corner) && corner) {
				lap := lap.Clone()

				found := false

				lap.Sections := choose(lap.Sections, (section) {
									if found {
										found := false

										return true
									}
									else if ((section.Type = "Corner") && (section.Nr = corner)) {
										found := true

										return true
									}
									else
										return false
								})
			}

			if theLap {
				if (!lastLap && (lapNr != 0))
					lastLap := lap

				if (!bestLap || (lap.LapTime < bestLap.LapTime))
					bestLap := lap
			}
			else if (lapNr != 0)
				theLap := lap
		}

		if isSet(reference) {
			reference := false

			if theLap
				if ((mode = "Fastest") && bestLap)
					reference := bestLap
				else if ((mode = "Last") && lastLap)
					reference := lastLap
		}

		return theLap
	}

	getRunningTelemetry(corner?) {
		return this.getTelemetry(&ignore := false, corner?)
	}

	addInstructionHint(instruction) {
		this.iInstructionHints[instruction] := true
	}

	getInstructionHints(cornerNr) {
		local knowledgeBase := this.KnowledgeBase
		local telemetry, reference

		nullZero(value) {
			return (isNull(value) ? 0 : value)
		}

		nullRound(value, precision := 0, default := 0) {
			if isNumber(value)
				return Round(value, precision)
			else
				return default
		}

		writeCorner(type, corner) {
			if (corner.Type != "Corner")
				throw "Inconsistent section type detected in DrivingCoach.getInstructionHints..."

			knowledgeBase.addFact(type . ".Corner.Nr", corner.Nr)
			knowledgeBase.addFact(type . ".Corner.Time", corner.Time)
			knowledgeBase.addFact(type . ".Corner.Length", corner.Length)

			knowledgeBase.addFact(type . ".Corner.Steering.Corrections", corner.SteeringCorrections)
			knowledgeBase.addFact(type . ".Corner.Steering.Smoothness", nullRound(corner.SteeringSmoothness))

			if (corner.Start["Entry"] && (corner.Start["Entry"] != kNull)) {
				knowledgeBase.addFact(type . ".Corner.Entry.Time", nullRound(corner.Time["Entry"], 0, 0))
				knowledgeBase.addFact(type . ".Corner.Entry.Braking.Start", Round(corner.Start["Entry"], 1))
				knowledgeBase.addFact(type . ".Corner.Entry.Braking.Length", nullRound(corner.Length["Entry"], 1, 0))
				knowledgeBase.addFact(type . ".Corner.Entry.Brake.Pressure", Round(corner.MaxBrakePressure))
				knowledgeBase.addFact(type . ".Corner.Entry.Brake.Rampup", Round(corner.BrakePressureRampUp, 1))
				knowledgeBase.addFact(type . ".Corner.Entry.Brake.Corrections", corner.BrakeCorrections)
				knowledgeBase.addFact(type . ".Corner.Entry.Brake.Smoothness", nullRound(corner.BrakeSmoothness, 0, 100))
				knowledgeBase.addFact(type . ".Corner.Entry.ABSActivations", corner.ABSActivations)
			}

			if (corner.Start["Apex"] && (corner.Start["Apex"] != kNull)) {
				knowledgeBase.addFact(type . ".Corner.Apex.Time", nullRound(corner.Time["Apex"], 0, 0))
				knowledgeBase.addFact(type . ".Corner.Apex.Rolling.Start", Round(corner.Start["Apex"], 1))
				knowledgeBase.addFact(type . ".Corner.Apex.Rolling.Length", nullRound(corner.Length["Apex"], 1, 0))
				knowledgeBase.addFact(type . ".Corner.Apex.Acceleration.Lateral", nullRound(corner.AvgLateralGForce, 2))
				knowledgeBase.addFact(type . ".Corner.Apex.Gear", corner.RollingGear)
				knowledgeBase.addFact(type . ".Corner.Apex.RPM", corner.RollingRPM)
				knowledgeBase.addFact(type . ".Corner.Apex.Speed", nullRound(corner.MinSpeed))
			}
			else {
				knowledgeBase.addFact(type . ".Corner.Apex.Acceleration.Lateral", nullRound(corner.AvgLateralGForce, 2))
				knowledgeBase.addFact(type . ".Corner.Apex.Speed", nullRound(corner.MinSpeed))
			}

			if (corner.Start["Exit"] && (corner.Start["Exit"] != kNull)) {
				knowledgeBase.addFact(type . ".Corner.Exit.Time", nullRound(corner.Time["Exit"], 0, 0))
				knowledgeBase.addFact(type . ".Corner.Exit.Accelerating.Start", Round(corner.Start["Exit"], 1))
				knowledgeBase.addFact(type . ".Corner.Exit.Accelerating.Length", nullRound(corner.Length["Exit"], 1, 0))
				knowledgeBase.addFact(type . ".Corner.Exit.Gear", corner.AcceleratingGear)
				knowledgeBase.addFact(type . ".Corner.Exit.RPM", corner.AcceleratingRPM)
				knowledgeBase.addFact(type . ".Corner.Exit.Speed", nullRound(corner.AcceleratingSpeed))
				knowledgeBase.addFact(type . ".Corner.Exit.Throttle.Corrections", corner.ThrottleCorrections)
				knowledgeBase.addFact(type . ".Corner.Exit.Throttle.Smoothness", nullRound(corner.ThrottleSmoothness, 0, 100))
				knowledgeBase.addFact(type . ".Corner.Exit.TCActivations", corner.TCActivations)
			}
		}

		writeFollowUp(type, followUp) {
			knowledgeBase.addFact(type . ".FollowUp.Nr", followUp.Nr)
			knowledgeBase.addFact(type . ".FollowUp.Type", followUp.Type)
			knowledgeBase.addFact(type . ".FollowUp.Time", followUp.Time)
			knowledgeBase.addFact(type . ".FollowUp.Length", followUp.Length)
		}

		telemetry := this.getTelemetry(&reference := true, cornerNr)

		if (knowledgeBase && telemetry && reference) {
			for index, section in telemetry.Sections
				if (index = 1)
					writeCorner("Lap", section)
				else if (index = 2)
					writeFollowUp("Lap", section)

			for index, section in reference.Sections
				if (index = 1)
					writeCorner("Reference", section)
				else if (index = 2)
					writeFollowUp("Reference", section)

			this.iInstructionHints := CaseInsenseMap()

			knowledgeBase.addFact("Performance.Analyze", true)

			knowledgeBase.produce()

			Task.startTask(() {
				knowledgeBase.addFact("Performance.Clear", true)

				knowledgeBase.produce()
			})

			return getKeys(this.iInstructionHints)
		}
		else
			return []
	}

	startupTelemetryCollector() {
		local loadedLaps, provider

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
							setMultiMapValue(info, "Info", "SectorTimes", values2String(",", collect(sectorTimes, (t) => Round(t / 1000, 2))*))

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
			DirCreate(kTempDirectory . "Driving Coach\Conversations")

			deleteDirectory(kTempDirectory . "Driving Coach\Conversations")

			if !isDebug() {
				deleteDirectory(kTempDirectory . "Driving Coach\Telemetry")

				DirCreate(kTempDirectory . "Driving Coach\Telemetry")
			}

			provider := getMultiMapValue(this.Settings, "Assistant.Coach", "Telemetry.Provider", "Internal")

			if (provider != "Internal")
				provider .= ("|" . getMultiMapValue(this.Settings, "Assistant.Coach", "Telemetry.Provider.URL", ""))

			this.iTelemetryAnalyzer := TelemetryAnalyzer(this.Simulator, this.Track)
			this.iTelemetryCollector := TelemetryCollector(provider, kTempDirectory . "Driving Coach\Telemetry", this.Simulator, this.Track, this.TrackLength)

			this.iTelemetryCollector.startup()

			loadedLaps := CaseInsenseMap()

			this.iCollectorTask := PeriodicTask(updateTelemetry, 10000, kLowPriority)

			this.iCollectorTask.start()

			return true
		}
		else
			return false
	}

	shutdownTelemetryCollector() {
		if this.TelemetryCollector {
			this.TelemetryCollector.shutdown()

			this.iTelemetryCollector := false
		}

		if this.iCollectorTask {
			this.iCollectorTask.stop()

			this.iCollectorTask := false
		}

		this.iTelemetryAnalyzer := false
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

				for ignore, section in sections
					if analyzer.getSectionCoordinateIndex(section, &x, &y, &ignore)
						positions .= (A_Space . x . A_Space . y)
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

					if !kSilentMode
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
		local onTrackCoaching := false
		local facts

		if !prepared {
			if formationLap {
				this.updateDynamicValues({KnowledgeBase: false
										, OverallTime: 0, BestLapTime: 0
										, LastFuelAmount: 0, InitialFuelAmount: 0, LastEnergyAmount: 0, InitialEnergyAmount: 0
										, EnoughData: false})
				this.updateSessionValues({Simulator: "", Car: "", Track: "", Session: kSessionFinished, SessionTime: false, Laps: Map(), Standings: []})
			}

			this.restartConversation()
		}

		facts := super.prepareSession(&settings, &data, formationLap)

		if (!prepared && settings) {
			this.updateConfigurationValues({UseTalking: getMultiMapValue(settings, "Assistant.Coach", "Voice.UseTalking", false)})

			if (this.Session = kSessionPractice) {
				announcements := {SessionInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Practice.Session", true)
								, StintInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Practice.Stint", true)
								, HandlingInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Practice.Handling", true)}

				onTrackCoaching := getMultiMapValue(settings, "Assistant.Coach", "Practice.OnTrackCoaching", false)
			}
			else if (this.Session = kSessionQualification) {
				announcements := {SessionInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Qualification.Session", true)
								, StintInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Qualification.Stint", true)
								, HandlingInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Qualification.Handling", false)}

				onTrackCoaching := getMultiMapValue(settings, "Assistant.Coach", "Qualification.OnTrackCoaching", false)
			}
			else if (this.Session = kSessionRace) {
				announcements := {SessionInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Race.Session", true)
								, StintInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Race.Stint", true)
								, HandlingInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Race.Handling", false)}

				onTrackCoaching := getMultiMapValue(settings, "Assistant.Coach", "Race.OnTrackCoaching", false)
			}
			else if (this.Session = kSessionTimeTrial) {
				announcements := {SessionInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Time Trial.Session", true)
								, StintInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Time Trial.Stint", true)
								, HandlingInformation: getMultiMapValue(settings, "Assistant.Coach", "Data.Time Trial.Handling", false)}

				onTrackCoaching := getMultiMapValue(settings, "Assistant.Coach", "Time Trial.OnTrackCoaching", false)
			}

			if announcements
				this.updateConfigurationValues({Announcements: announcements, OnTrackCoaching: onTrackCoaching || this.OnTrackCoaching})
			else
				this.updateConfigurationValues({OnTrackCoaching: onTrackCoaching || this.OnTrackCoaching})
		}

		if this.CoachingActive
			this.startupTelemetryCoaching()
		else if this.OnTrackCoaching
			this.startTelemetryCoaching(true, true)

		return facts
	}

	startSession(settings, data) {
		local facts := this.prepareSession(&settings, &data, false)

		this.updateConfigurationValues({LearningLaps: 1, AdjustLapTime: true, SaveSettings: false})

		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts)
								, BestLapTime: 0, OverallTime: 0
								, LastFuelAmount: 0, InitialFuelAmount: 0, LastEnergyAmount: 0, InitialEnergyAmount: 0
								, EnoughData: false})

		this.updateSessionValues({Standings: [], Laps: Map()})

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)

		if this.Announcements["HandlingInformation"]
			this.startIssueAnalyzer()
	}

	finishSession(shutdown := true) {
		if (this.Session != kSessionFinished)
			this.shutdownTelemetryCoaching(false)

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
			this.startupTelemetryCoaching()

		return result
	}

	updateLap(lapNumber, &data, arguments*) {
		local result := super.updateLap(lapNumber, &data, arguments*)

		if this.CoachingActive
			this.startupTelemetryCoaching()

		return result
	}

	positionTrigger(sectionNr, positionX, positionY) {
		local analyzer := this.TelemetryAnalyzer
		local oldMode := this.Mode
		local cornerNr, instruct, telemetry, reference, command, instructionHints, problemsInstruction
		local speaker, index, hint, lastHint, conjunction, conclusion

		static nextRecommendation := false
		static wait := false
		static hintProblems := false
		static hints := false
		static instructionCount := 0

		filterInstructionHints(instructionHints) {
			local result := []
			local ignore, hint

			for ignore, hint in instructionHints {
				if ((hint = "BrakeEarlier") && inList(result, "BrakeLater"))
					continue
				else if ((hint = "BrakeLater") && inList(result, "BrakeEarlier"))
					continue
				else if ((hint = "BrakeHarder") && inList(result, "BrakeSofter"))
					continue
				else if ((hint = "BrakeSofter") && inList(result, "BrakeHarder"))
					continue
				else if ((hint = "BrakeFaster") && inList(result, "BrakeSlower"))
					continue
				else if ((hint = "BrakeSlower") && inList(result, "BrakeFaster"))
					continue
				else if ((hint = "AccelerateEarlier") && inList(result, "AccelerateLater"))
					continue
				else if ((hint = "AccelerateLater") && inList(result, "AccelerateEarlier"))
					continue
				else if ((hint = "AccelerateHarder") && inList(result, "AccelerateSofter"))
					continue
				else if ((hint = "AccelerateLater") && inList(result, "AccelerateHarder"))
					continue
				else if ((hint = "PushMore") && inList(result, "PushLess"))
					continue
				else if ((hint = "PushLess") && inList(result, "PushMore"))
					continue

				result.Push(hint)
			}

			return result
		}

		instructionConjunction(h1, h2) {
			if ((h1 = "BrakeEarlier") && (h2 = "BrakeSofter"))
				return "And"
			else if ((h1 = "BrakeLater") && (h2 = "BrakeHarder"))
				return "But"
			else if ((h1 = "BrakeEarlier") && (h2 = "BrakeHarder"))
				return "And"
			else if ((h1 = "BrakeLater") && (h2 = "BrakeSofter"))
				return "But"
			else if ((h1 = "BrakeHarder") && (h2 = "BrakeSlower"))
				return "But"
			else if ((h1 = "BrakeSofter") && (h2 = "BrakeFaster"))
				return "But"
			else if ((h1 = "BrakeHarder") && (h2 = "BrakeFaster"))
				return "And"
			else if ((h1 = "BrakeSofter") && (h2 = "BrakeSlower"))
				return "And"
			else if ((h1 = "AccelerateEarlier") && (h2 = "AccelerateHarder"))
				return "And"
			else if ((h1 = "AccelerateLater") && (h2 = "AccelerateSofter"))
				return "And"
			else if ((h1 = "AccelerateEarlier") && (h2 = "AccelerateSofter"))
				return "But"
			else if ((h1 = "AccelerateLater") && (h2 = "AccelerateHarder"))
				return "But"

			return false
		}

		if !analyzer
			return

		instruct := (sectionNr <= analyzer.TrackSections.Length)

		if (this.iTelemetryFuture && !instruct) {
			sectionNr -= analyzer.TrackSections.Length

			if ((sectionNr >= (this.iTelemetryFuture.Section + 2)) || (sectionNr < this.iTelemetryFuture.Section)) {
				if this.iTelemetryFuture.FileName
					try {
						this.reviewCornerPerformance(Integer(analyzer.TrackSections[this.iTelemetryFuture.Section].Nr)
												   , this.iTelemetryFuture.FileName)
					}
					catch Any as exception {
						logError(exception, true)
					}

				this.iTelemetryFuture := false
			}

			return
		}

		if ((Round(positionX) = -32767) && (Round(positionY) = -32767))
			return

		if !wait {
			wait := (getMultiMapValue(this.Settings, "Assistant.Coach", "Coaching.Corner.Wait", 10) * 1000)

			hints := ["BrakeEarlier", "BrakeLater", "BrakeHarder", "BrakeSofter"
					, "BrakeFaster", "BrakeSlower", "AccelerateEarlier", "AccelerateLater"
					, "AccelerateHarder", "AccelerateSofter", "PushLess", "PushMore"]

			hintProblems := Map("BrakeEarlier", "Too late braking"
							  , "BrakeLater", "Too early braking"
							  , "BrakeHarder", "Not enough brake pressure"
							  , "BrakeSofter", "Too much brake pressure"
							  , "BrakeFaster", "Building brake pressure too slow"
							  , "BrakeSlower", "Building brake pressure too fast"
							  , "PushLess", "Too much pushing"
							  , "PushMore", "Not enough pushing"
							  , "AccelerateEarlier", "Accelerating too late"
							  , "AccelerateLater", "Accelerating too early"
							  , "AccelerateHarder", "Not hard enough on the throttle"
							  , "AccelerateSofter", "Too hard on the throttle")
			hintProblems.Default := ""
		}

		if (analyzer && instruct) {
			cornerNr := Integer(analyzer.TrackSections[sectionNr].Nr)

			if ((this.FocusedCorners.Length > 0) && !inList(this.FocusedCorners, String(cornerNr)))
				return

			telemetry := this.getTelemetry(&reference := true, cornerNr)

			if telemetry {
				if (A_TickCount < nextRecommendation)
					return
				else {
					instructionHints := this.getInstructionHints(cornerNr)

					if (instructionHints.Length > 0)
						instructionHints := filterInstructionHints(instructionHints)

					if this.Speaker[false]
						if ((telemetry.Sections.Length > 0) && !this.getSpeaker().Speaking) {
							nextRecommendation := (A_TickCount + wait)

							if (this.ConnectionState = "Active") {
								if inList(this.FocusedCorners, String(cornerNr)) {
									this.iTelemetryFuture := this.TelemetryCollector.collectTelemetry()

									if this.iTelemetryFuture
										this.iTelemetryFuture.Section := sectionNr
								}

								this.Mode := "Coaching"

								telemetry := telemetry.JSON

								problemsInstruction := this.Instructions["Coaching.Corner.Problems"]

								if ((Trim(problemsInstruction) != "") && (instructionHints.Length > 0))
									telemetry := (substituteVariables(problemsInstruction
																	, {problems: values2String(", ", collect(instructionHints, (h) => translate(hintProblems[h]))*)
																	 , corner: cornerNr})
												. "\n\n" . telemetry)

								try {
									command := substituteVariables(this.Instructions["Coaching.Corner.Approaching"]
																 , {telemetry: telemetry, corner: cornerNr})

									if reference
										command .= ("`n`n" . substituteVariables(this.Instructions["Coaching.Reference"]
																			   , {telemetry: reference.JSON}))

									this.handleVoiceText("TEXT", command, false)
								}
								finally {
									this.Mode := oldMode
								}
							}
							else if (instructionHints.Length > 0) {
								speaker := this.getSpeaker()

								speaker.beginTalk({Talking: true})

								try {
									lastHint := false

									for index, hint in bubbleSort(&instructionHints, (h1, h2) => inList(hints, h1) > inList(hints, h2)) {
										conjunction := (lastHint ? instructionConjunction(lastHint, hint) : false)

										if conjunction
											conjunction := speaker.Fragments[conjunction]
										else if !lastHint
											conjunction := ""
										else
											conjunction := ". "

										conclusion := ((index = instructionHints.Length) ? "." : "")

										speaker.speakPhrase(hint, {conjunction: conjunction, conclusion: conclusion})

										lastHint := hint
									}
								}
								finally {
									speaker.endTalk({Rephrase: false})
								}
							}
						}

					instructionCount += 1

					if (instructionHints.Length > 0)
						Task.startTask(() {
							local state := readMultiMap(kTempDirectory . "Driving Coach\Coaching.state")
							local speaker := (this.Speaker[false] && this.getSpeaker())
							local lastInstruction := instructionCount
							local ignore, hint

							setMultiMapValue(state, "Instructions", "Corner", cornerNr)

							setMultiMapValue(state, "Instructions", "Instructions", values2String(", ", instructionHints*))

							if speaker
								for ignore, hint in instructionHints
									setMultiMapValue(state, "Instructions", hint, Trim(speaker.getPhrase(hint, {conjunction: "", conclusion: ""})))

							writeMultiMap(kTempDirectory . "Driving Coach\Coaching.state", state)

							Task.startTask(() {
								if (lastInstruction = instructionCount) {
									local state := readMultiMap(kTempDirectory . "Driving Coach\Coaching.state")

									removeMultiMapValues(state, "Instructions")

									writeMultiMap(kTempDirectory . "Driving Coach\Coaching.state", state)
								}
							}, wait * 2, kLowPriority)
						})
				}
			}
		}
	}
}