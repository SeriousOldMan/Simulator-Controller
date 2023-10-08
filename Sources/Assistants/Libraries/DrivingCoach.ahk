;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AI Driving Coach                ;;;
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
#Include "..\..\Libraries\HTTP.ahk"
#Include "RaceAssistant.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class DrivingCoach extends GridRaceAssistant {
	iConnector := false

	iInstructions := CaseInsenseWeakMap()

	iLaps := Map()
	iLapsHistory := 0

	iStandings := []

	class HTTPConnector {
		iCoach := false

		iServer := ""
		iToken := ""
		iModel := ""

		iMaxTokens := 1024
		iTemperature := 0.5

		iHistory := []
		iMaxHistory := 3

		static Models {
			Get {
				return []
			}
		}

		Models {
			Get {
				return DrivingCoach.HTTPConnector.Models
			}
		}

		Coach {
			Get {
				return this.iCoach
			}
		}

		Server {
			Get {
				return this.iServer
			}
		}

		Token {
			Get {
				return this.iToken
			}
		}

		Model[external := false] {
			Get {
				if !external {
					if inList(this.Models, this.iModel)
						return StrLower(StrReplace(this.iModel, A_Space, "-"))
					else
						return this.iModel
				}
				else
					return this.iModel
			}
		}

		Temperature {
			Get {
				return this.iTemperature
			}

			Set {
				return (this.iTemperature := value)
			}
		}

		MaxTokens {
			Get {
				return this.iMaxTokens
			}

			Set {
				return (this.iMaxTokens := value)
			}
		}

		History[key?] {
			Get {
				return (isSet(key) ? this.iHistory[key] : this.iHistory)
			}
		}

		MaxHistory {
			Get {
				return this.iMaxHistory
			}

			Set {
				return (this.iMaxHistory := value)
			}
		}

		__New(coach) {
			this.iCoach := coach
		}

		Connect(server?, token?, model?) {
			this.iServer := (isSet(server) ? server : this.Server)
			this.iToken := (isSet(token) ? token : this.Token)
			this.iModel := (isSet(model) ? model : this.Model)

			this.History.Length := 0
		}

		Restart := (*) => this.Connect()

		AddConversation(question, answer) {
			this.History.Push([question, answer])

			while (this.History.Length > this.MaxHistory)
				this.History.RemoveAt(1)
		}

		CreateServiceURL(server) {
			return server
		}

		CreateHeaders(headers) {
			if (Trim(this.Token) != "")
				headers["Authorization"] := ("Bearer " . this.Token)

			return headers
		}

		CreatePrompt(body) {
			throw "Virtual method HTTPConnector.CreatePrompt must be implemented in a subclass..."
		}

		Ask(question) {
			local coach := this.Coach
			local speaker := coach.getSpeaker()
			local headers := this.CreateHeaders(Map("Content-Type", "application/json"))
			local body := this.CreatePrompt({model: this.Model, max_tokens: this.MaxTokens, temperature: this.Temperature}, question)

			body := JSON.print(body)

			if isDebug() {
				deleteFile(kTempDirectory . "Chat.request")

				FileAppend(body, kTempDirectory . "Chat.request")
			}

			try {
				answer := WinHttpRequest().POST(this.CreateServiceURL(this.Server), body, headers, {Object: true, Encoding: "UTF-8"})

				if ((answer.Status >= 200) && (answer.Status < 300))
					answer := answer.JSON
				else
					throw "Cannot connect to " . this.CreateServiceURL(this.Server) . "..."
			}
			catch Any as exception {
				logError(exception)

				if this.Coach.RemoteHandler
					this.Coach.RemoteHandler.serviceState("Error:Connection")

				return false
			}

			if isDebug() {
				deleteFile(kTempDirectory . "Chat.response")

				FileAppend(JSON.print(answer), kTempDirectory . "Chat.response")
			}

			try {
				answer := answer["choices"][1]["message"]["content"]

				this.AddConversation(question, answer)

				if this.Coach.RemoteHandler
					this.Coach.RemoteHandler.serviceState("Available")

				return answer
			}
			catch Any as exception {
				logError(exception)

				if this.Coach.RemoteHandler
					this.Coach.RemoteHandler.serviceState("Error:Answer")

				return false
			}
		}
	}

	class OpenAIConnector extends DrivingCoach.HTTPConnector {
		static Models {
			Get {
				return ["GPT 3.5 turbo", "GPT 3.5 turbo 16k", "GPT 4", "GPT 4 32k"]
			}
		}

		Models {
			Get {
				return DrivingCoach.OpenAIConnector.Models
			}
		}

		CreatePrompt(body, question) {
			local coach := this.Coach
			local messages := []
			local ignore, instruction, conversation

			addInstruction(instruction) {
				instruction := coach.getInstruction(instruction)

				if (instruction && (Trim(instruction) != ""))
					messages.Push({role: "system", content: instruction})
			}

			for ignore, instruction in coach.Instructions[true]
				addInstruction(instruction)

			for ignore, conversation in this.History {
				messages.Push({role: "user", content: conversation[1]})
				messages.Push({role: "assistant", content: conversation[2]})
			}

			messages.Push({role: "user", content: question})

			body.messages := messages

			return body
		}
	}

	class AzureConnector extends DrivingCoach.OpenAIConnector {
		Model[external := false] {
			Get {
				if !external
					return StrReplace(super.Model[external], ".", "")
				else
					return super.Model[external]
			}
		}

		CreateServiceURL(server) {
			return substituteVariables(server, {model: this.Model})
		}

		CreateHeaders(headers) {
			if (Trim(this.Token) != "")
				headers["api-key"] := this.Token

			return headers
		}
	}

	class GPT4AllConnector extends DrivingCoach.HTTPConnector {
		CreatePrompt(body, question) {
			local coach := this.Coach
			local prompt := ""
			local ignore, instruction, conversation

			addInstruction(instruction) {
				instruction := coach.getInstruction(instruction)

				if (instruction && (Trim(instruction) != "")) {
					if (prompt = "")
						prompt .= "### System:`n"

					prompt .= (instruction . "`n")
				}
			}

			for ignore, conversation in this.History {
				prompt .= ("### Human: " . conversation[1] . "`n")
				prompt .= ("### Assistant: " . conversation[2] . "`n")
			}

			prompt .= ("### Human: " . question . "`n### Assistant:")

			body.prompt := prompt

			return body
		}
	}

	class DrivingCoachRemoteHandler extends RaceAssistant.RaceAssistantRemoteHandler {
		__New(remotePID) {
			super.__New("Driving Coach", remotePID)
		}

		serviceState(arguments*) {
			this.callRemote("serviceState", arguments*)
		}
	}

	Providers {
		Get {
			return ["OpenAI", "Azure", "GPT4All"]
		}
	}

	Instructions[type?] {
		Get {
			if isSet(type) {
				if (type == true)
					return ["Character", "Simulation", "Session", "Stint"]
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
		, synthesizer := false, speaker := false, vocalics := false, recognizer := false, listener := false, muted := false, voiceServer := false) {
		super.__New(configuration, "Driving Coach", remoteHandler, name, language, synthesizer, speaker, vocalics, recognizer, listener, muted, voiceServer)

		DirCreate(this.Options["Driving Coach.Archive"])
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
		options["Driving Coach.MaxTokens"] := getMultiMapValue(configuration, "Driving Coach Service", "MaxTokens", 1024)
		options["Driving Coach.Temperature"] := getMultiMapValue(configuration, "Driving Coach Personality", "Temperature", 0.5)
		options["Driving Coach.MaxHistory"] := getMultiMapValue(configuration, "Driving Coach Personality", "MaxHistory", 3)
		options["Driving Coach.Confirmation"] := getMultiMapValue(configuration, "Driving Coach Personality", "Confirmation", true)

		for ignore, instruction in this.Instructions[true]
			options["Driving Coach.Instructions." . instruction] := getMultiMapValue(configuration, "Driving Coach Personality", "Instructions." . instruction, false)

		laps := InStr(options["Driving Coach.Instructions.Stint"], "%laps:")

		if laps {
			laps := SubStr(options["Driving Coach.Instructions.Stint"], laps, InStr(options["Driving Coach.Instructions.Stint"], "%", false, laps + 1) - laps - 1)

			options["Driving Coach.Instructions.Stint"] := StrReplace(options["Driving Coach.Instructions.Stint"], laps, "laps")

			this.iLapsHistory := string2Values(":", laps)[2]
		}
	}

	updateSessionValues(values) {
		super.updateSessionValues(values)

		if values.HasProp("Laps")
			this.iLaps := values.Laps
		else if values.HasProp("Standings")
			this.iStandings := values.Standings
		else if (values.HasProp("Session") && (values.Session == kSessionFinished)) {
			this.iLaps := Map()
			this.iStandings := []
		}
	}

	getInstruction(category) {
		local knowledgeBase := this.KnowledgeBase
		local settingsDB := this.SettingsDatabase
		local simulator, car, track, position, hasSectorTimes, laps, lapData, ignore, carData, standingsData

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
				if knowledgeBase {
					position := this.GridPosition

					if (position != 0)
						return substituteVariables(this.Instructions["Session"]
												 , {session: translate(sessions[this.Session])
												  , carNumber: this.getNr()
												  , classPosition: this.GridPosition["Class"], overallPosition: position})
				}
			case "Stint":
				if knowledgeBase {
					position := this.getPosition(false, "Class")

					if (position != 0) {
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
								lapData .= "`""

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
								standingsData .= "`""

							if hasSectorTimes
								standingsData .= values2String(";", carData.OverallPosition, carData.ClassPosition, carData.Nr, carData.Class,
																  , carData.SectorTimes ? values2String(",", carData.SectorTimes*) : "", carData.LapTime)
							else
								standingsData .= values2String(";", carData.OverallPosition, carData.ClassPosition, carData.Nr, carData.Class, carData.LapTime)
						}

						return substituteVariables(this.Instructions["Stint"], {lap: knowledgeBase.getValue("Lap"), position: position, carNumber: this.getNr()
																			  , laps: lapData, standings: standingsData})
					}
				}
		}

		return false
	}

	startConversation() {
		local service := this.Options["Driving Coach.Service"]
		local ignore, instruction

		this.iTranscript := (normalizeDirectoryPath(this.Options["Driving Coach.Archive"]) . "\" . translate("Conversation ") . A_Now . ".txt")

		if service {
			service := string2Values("|", service)

			if !inList(this.Providers, service[1])
				throw "Unsupported service detected in DrivingCoach.connect..."

			try {
				this.iConnector := DrivingCoach.%service[1]%Connector(this)

				this.Connector.Connect(service[2], service[3], this.Options["Driving Coach.Model"])

				this.Connector.MaxTokens := this.Options["Driving Coach.MaxTokens"]
				this.Connector.Temperature := this.Options["Driving Coach.Temperature"]
				this.Connector.MaxHistory := this.Options["Driving Coach.MaxHistory"]

				for ignore, instruction in this.Instructions[true] {
					this.Instructions[instruction] := this.Options["Driving Coach.Instructions." . instruction]

					if !this.Instructions[instruction]
						this.Instructions[instruction] := ""
				}
			}
			catch Any as exception {
				logError(exception)

				if this.RemoteHandler
					this.RemoteHandler.serviceState("Error:Configuration")

				throw "Unsupported service detected in DrivingCoach.connect..."
			}
		}
		else
			throw "Unsupported service detected in DrivingCoach.connect..."
	}

	stopConversation() {
		if this.Connector
			this.Connector.Restart()
	}

	handleVoiceText(grammar, text) {
		local answer := false

		try {
			if (this.Speaker && this.Options["Driving Coach.Confirmation"])
				this.getSpeaker().speakPhrase("Confirm", false, false, false, {Noise: false})

			if !this.Connector
				this.startConversation()

			answer := this.Connector.Ask(text)

			if !answer
				throw "Problems while connecting to GPT service..."
		}
		catch Any as exception {
			if this.Speaker
				this.getSpeaker().speakPhrase("Later", false, false, false, {Noise: false})

			logError(exception, true)

			logMessage(kLogCritical, substituteVariables(translate("Cannot connect to GPT service (%service%) - please check the configuration")
													   , {service: this.Options["Driving Coach.Service"]}))

			showMessage(substituteVariables(translate("Cannot connect to GPT service (%service%) - please check the configuration...")
										  , {service: this.Options["Driving Coach.Service"]})
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}

		if answer {
			if this.Speaker
				this.getSpeaker().speak(answer, false, false, {Noise: false})

			if this.Transcript
				FileAppend(translate("-- Driver --------") . "`n`n" . text . "`n`n" . translate("-- Coach ---------") . "`n`n" . answer . "`n`n", this.Transcript)
		}
	}

	startSession(settings, data) {
		local facts := this.prepareSession(&settings, &data, false)

		this.updateConfigurationValues({LearningLaps: 1, AdjustLapTime: true, SaveSettings: false})

		this.updateDynamicValues({KnowledgeBase: this.createKnowledgeBase(facts)
								, BestLapTime: 0, OverallTime: 0, LastFuelAmount: 0
								, InitialFuelAmount: 0, EnoughData: false})

		this.updateSessionValues({Laps: Map()})

		this.initializeGridPosition(data)

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)

		this.stopConversation()
	}

	finishSession(shutdown := true) {
		this.updateDynamicValues({KnowledgeBase: false, Prepared: false
								, OverallTime: 0, BestLapTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0
								, EnoughData: false})
		this.updateSessionValues({Simulator: "", Session: kSessionFinished, SessionTime: false, Laps: Map()})

		this.stopConversation()
	}

	updateLaps(lapNumber, data) {
		local knowledgeBase := this.KnowledgeBase
		local driver := knowledgeBase.getValue("Driver.Car", false)
		local standingsData := CaseInsenseMap()
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


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

getTime(*) {
	return A_Now
}