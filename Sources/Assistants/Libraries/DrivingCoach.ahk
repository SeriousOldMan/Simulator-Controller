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

#Include "..\..\Libraries\JSON.ahk"
#Include "..\..\Libraries\HTTP.ahk"
#Include "..\..\Libraries\LLMConnector.ahk"
#Include "RaceAssistant.ahk"
#Include "..\..\Garage\Libraries\TelemetryCollector.ahk"
#Include "..\..\Garage\Libraries\IRCTelemetryCollector.ahk"
#Include "..\..\Garage\Libraries\R3ETelemetryCollector.ahk"


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

	iTelemetryCollector := false

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

	CollectorClass {
		Get {
			switch SessionDatabase.getSimulatorCode(this.Simulator), false {
				case "IRC":
					return "IRCTelemetryCollector"
				case "R3E":
					return "R3ETelemetryCollector"
				default:
					return "TelemetryCollector"
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
					return ["Character", "Simulation", "Session", "Stint", "Knowledge", "Handling"]
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

	__New(configuration, remoteHandler, name := false, language := kUndefined
		, synthesizer := false, speaker := false, vocalics := false, speakerBooster := false
		, recognizer := false, listener := false, listenerBooster := false, conversationBooster := false, muted := false, voiceServer := false) {
		super.__New(configuration, "Driving Coach", remoteHandler, name, language, synthesizer, speaker, vocalics, speakerBooster
												  , recognizer, listener, listenerBooster, conversationBooster, muted, voiceServer)

		this.updateConfigurationValues({Announcements: {SessionInformation: true, StintInformation: false, HandlingInformation: false}})

		DirCreate(this.Options["Driving Coach.Archive"])

		OnExit(ObjBindMethod(this, "stopTelemetryCollector"))
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

	getKnowledge(options := false) {
		if !options
			options := {exclude: ["Standings", "Positions"]}
		else if !options.Has("exclude")
			options.exclude := ["Standings", "Positions"]
		else
			options.concatenate(options.exclude, ["Standings", "Positions"])

		return super.getKnowledge(options)
	}

	getInstruction(category) {
		local knowledgeBase := this.KnowledgeBase
		local settingsDB := this.SettingsDatabase
		local simulator, car, track, position, hasSectorTimes, laps, lapData, ignore, carData, standingsData
		local collector, issues, handling, ignore, type, speed, where, issue, index
		local key, value, text, filter

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
				if (knowledgeBase && this.Announcements["SessionInformation"]) {
					position := this.GridPosition

					if (position != 0)
						return substituteVariables(this.Instructions["Session"]
												 , {session: translate(sessions[this.Session])
												  , carNumber: this.getNr()
												  , classPosition: this.GridPosition["Class"], overallPosition: position})
				}
			case "Stint":
				if (knowledgeBase && this.Announcements["StintInformation"]) {
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
					return substituteVariables(this.Instructions["Knowledge"], {knowledge: JSON.print(this.getKnowledge(), "  ")})
			case "Handling":
				if (knowledgeBase && this.Announcements["HandlingInformation"]) {
					collector := this.iTelemetryCollector

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
			service := string2Values("|", service)

			if !inList(this.Providers, service[1])
				throw "Unsupported service detected in DrivingCoach.startConversation..."

			if (service[1] = "LLM Runtime")
				this.iConnector := LLMConnector.LLMRuntimeConnector(this, this.Options["Driving Coach.Model"])
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

	handleVoiceText(grammar, text) {
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
				this.getSpeaker().speakPhrase("Later", false, false, false, {Noise: false})

				report := false
			}
		}
		catch Any as exception {
			if report {
				if this.Speaker
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

			if this.Transcript
				FileAppend(translate("-- Driver --------") . "`n`n" . text . "`n`n" . translate("-- Coach ---------") . "`n`n" . answer . "`n`n", this.Transcript, "UTF-16")
		}
	}

	stopTelemetryCollector(arguments*) {
		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		this.stopTelemetryAnalyzer()

		if this.iTelemetryCollector {
			this.iTelemetryCollector.deleteSamples()

			this.iTelemetryCollector := false
		}

		return false
	}

	startTelemetryAnalyzer() {
		local knowledgeBase := this.KnowledgeBase

		this.stopTelemetryCollector()

		if knowledgeBase {
			this.iTelemetryCollector := %this.CollectorClass%(this.Simulator, knowledgeBase.getValue("Session.Car"), knowledgeBase.getValue("Session.Track")
															, {Handling: true, Frequency: 5000})

			this.iTelemetryCollector.loadFromSettings()

			this.iTelemetryCollector.startTelemetryCollector()
		}

		return this.iTelemetryCollector
	}

	stopTelemetryAnalyzer() {
		if this.iTelemetryCollector
			this.iTelemetryCollector.stopTelemetryCollector()
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

		this.startTelemetryAnalyzer()
	}

	finishSession(shutdown := true) {
		this.stopTelemetryAnalyzer()
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

		return result
	}
}