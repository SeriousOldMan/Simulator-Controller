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

	iHistory := false

	class HTTPConnector {
		iCoach := false

		iServer := ""
		iToken := ""
		iModel := ""

		iMaxTokens := 1024
		iTemperature := 0.5

		iInstructions := CaseInsenseMap()
		iHistory := []
		iMaxHistory := 3

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

		Model[internal := false] {
			Get {
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

		Instructions[type?] {
			Get {
				return (isSet(type) ? this.iInstructions[type] : this.iInstructions)
			}

			Set {
				return (isSet(type) ? (this.iInstructions[type] := value) : (this.iInstructions := value))
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

		Restart := () => this.Connect()

		AddConversation(question, answer) {
			this.History.Push([question, answer])

			while (this.History.Length > this.MaxHistory)
				this.History.RemoveAt(1)
		}

		CreatePrompt(body) {
			throw "Virtual method HTTPConnector.CreatePrompt must be implemented in a subclass..."
		}

		Ask(question) {
			local coach := this.Coach
			local speaker := coach.getSpeaker()
			local headers := Map("Content-Type", "application/json")
			local body := {model: this.Model, max_tokens: this.MaxTokens, temperature: this.Temperature}

			if (Trim(this.Token) != "")
				headers["Authorization"] := ("Bearer " . this.Token)

			this.CreatePrompt(body, question)

			body := JSON.print(body)

			if isDebug() {
				deleteFile(kTempDirectory . "Chat.request")

				FileAppend(body, kTempDirectory . "Chat.request")
			}

			answer := WinHttpRequest().POST(this.Server, body, headers, {Object: true, Encoding: "UTF-8"})

			if ((answer.Status >= 200) && (answer.Status < 300))
				answer := answer.JSON
			else
				throw "Cannot connect to " . this.Server . "..."

			if isDebug() {
				deleteFile(kTempDirectory . "Chat.response")

				FileAppend(JSON.print(answer), kTempDirectory . "Chat.response")
			}

			answer := answer["choices"][1]["message"]["content"]

			this.AddConversation(question, answer)

			return answer
		}
	}

	class OpenAIConnector extends DrivingCoach.HTTPConnector {
		Model[external := false] {
			Get {
				if !external {
					if inList(["GPT 3.5 turbo", "GPT 3.5 turbo 16k", "GPT 4", "GPT 4 32k"], this.iModel)
						return StrLower(StrReplace(super.Model, A_Space, "-"))
					else
						return super.Model
				}
				else
					return super.Model
			}
		}

		CreatePrompt(body, question) {
			local coach := this.Coach
			local settingsDB := coach.SettingsDatabase
			local knowledgeBase := coach.KnowledgeBase
			local messages := []
			local simulator, car, track, message, position, ignore, conversation

			if (this.Instructions.Has("Character") && this.Instructions["Character"])
				messages.Push({role: "system", content: substituteVariables(this.Instructions["Character"], {name: coach.VoiceManager.Name})})

			if (this.Instructions.Has("Simulation") && this.Instructions["Simulation"])
				if (knowledgeBase && (this.Coach.Session != kSessionFinished)) {
					simulator := knowledgeBase.getValue("Session.Simulator")
					car := knowledgeBase.getValue("Session.Car")
					track := knowledgeBase.getValue("Session.Track")

					message := substituteVariables(this.Instructions["Simulation"]
												 , {name: coach.VoiceManager.Name
												  , driver: coach.DriverForName
												  , simulator: settingsDB.getSimulatorName(simulator)
												  , car: settingsDB.getCarName(simulator, car)
												  , track: settingsDB.getTrackName(simulator, track)})

					messages.Push({role: "system", content: message})
				}

			if (this.Instructions.Has("Stint") && this.Instructions["Stint"])
				if (knowledgeBase && (this.Coach.Session != kSessionFinished)) {
					position := coach.getPosition(false, "Class")

					if (position != 0) {
						message := substituteVariables(this.Instructions["Stint"]
													 , {lap: knowledgeBase.getValue("Lap") + 1
													  , position: position})

						messages.Push({role: "system", content: message})
					}
				}

			for ignore, conversation in this.History {
				messages.Push({role: "user", content: conversation[1]})
				messages.Push({role: "assistant", content: conversation[2]})
			}

			messages.Push({role: "user", content: question})

			body.messages := messages
		}
	}

	class GPT4AllConnector extends DrivingCoach.HTTPConnector {
		CreatePrompt(body, question) {
			local coach := this.Coach
			local settingsDB := coach.SettingsDatabase
			local knowledgeBase := coach.KnowledgeBase
			local prompt := ""
			local simulator, car, track, message, position, ignore, conversation

			if (this.Instructions.Has("Character") && this.Instructions["Character"])
				prompt .= ("### Instruction:`n" . substituteVariables(this.Instructions["Character"], {name: coach.VoiceManager.Name}))

			if (this.Instructions.Has("Simulation") && this.Instructions["Simulation"])
				if (knowledgeBase && (this.Coach.Session != kSessionFinished)) {
					simulator := knowledgeBase.getValue("Session.Simulator")
					car := knowledgeBase.getValue("Session.Car")
					track := knowledgeBase.getValue("Session.Track")

					message := substituteVariables(this.Instructions["Simulation"]
												 , {name: coach.VoiceManager.Name
												  , driver: coach.DriverForName
												  , simulator: settingsDB.getSimulatorName(simulator)
												  , car: settingsDB.getCarName(simulator, car)
												  , track: settingsDB.getTrackName(simulator, track)})

					prompt .= (message . "`n")
				}

			if (this.Instructions.Has("Stint") && this.Instructions["Stint"])
				if (knowledgeBase && (this.Coach.Session != kSessionFinished)) {
					position := coach.getPosition(false, "Class")

					if (position != 0) {
						message := substituteVariables(this.Instructions["Stint"]
													 , {lap: knowledgeBase.getValue("Lap") + 1
													  , position: position})

						prompt .= (message . "`n")
					}
				}

			for ignore, conversation in this.History {
				prompt .= ("### Human: " . conversation[1] . "`n")
				prompt .= ("### Assistant: " . conversation[2] . "`n")
			}

			prompt .= ("### Human: " . question . "`n### Assistant:")

			body.prompt := prompt
		}
	}

	class DrivingCoachRemoteHandler extends RaceAssistant.RaceAssistantRemoteHandler {
		__New(remotePID) {
			super.__New("Driving Coach", remotePID)
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

	__New(configuration, remoteHandler, name := false, language := kUndefined
		, synthesizer := false, speaker := false, vocalics := false, recognizer := false, listener := false, muted := false, voiceServer := false) {
		super.__New(configuration, "Driving Coach", remoteHandler, name, language, synthesizer, speaker, vocalics, recognizer, listener, muted, voiceServer)

		DirCreate(this.Options["Driving Coach.Archive"])
	}

	loadFromConfiguration(configuration) {
		local options

		super.loadFromConfiguration(configuration)

		options := this.Options

		options["Driving Coach.Archive"] := getMultiMapValue(configuration, "Driving Coach Conversations", "Archive", kTempDirectory . "Conversations")
		options["Driving Coach.Service"] := getMultiMapValue(configuration, "Driving Coach Service", "Service", getMultiMapValue(configuration, "Driving Coach", "Service", false))
		options["Driving Coach.Model"] := getMultiMapValue(configuration, "Driving Coach Service", "Model", false)
		options["Driving Coach.MaxTokens"] := getMultiMapValue(configuration, "Driving Coach Service", "MaxTokens", 1024)
		options["Driving Coach.Temperature"] := getMultiMapValue(configuration, "Driving Coach Personality", "Temperature", 0.5)
		options["Driving Coach.MaxHistory"] := getMultiMapValue(configuration, "Driving Coach Personality", "MaxHistory", 3)
		options["Driving Coach.Instructions.Character"] := getMultiMapValue(configuration, "Driving Coach Personality", "Instructions.Character", false)
		options["Driving Coach.Instructions.Simulation"] := getMultiMapValue(configuration, "Driving Coach Personality", "Instructions.Simulation", false)
		options["Driving Coach.Instructions.Stint"] := getMultiMapValue(configuration, "Driving Coach Personality", "Instructions.Stint", false)
	}

	startConversation() {
		local service := this.Options["Driving Coach.Service"]

		if service {
			if ((InStr(service, "OpenAI") = 1) || (InStr(service, "GPT4All") = 1)) {
				try {
					service := string2Values("|", service)

					this.iConnector := DrivingCoach.%service[1]%Connector(this)

					this.Connector.Connect(service[2], service[3], this.Options["Driving Coach.Model"])

					this.Connector.MaxTokens := this.Options["Driving Coach.MaxTokens"]
					this.Connector.Temperature := this.Options["Driving Coach.Temperature"]
					this.Connector.MaxHistory := this.Options["Driving Coach.MaxHistory"]

					this.Connector.Instructions["Character"] := this.Options["Driving Coach.Instructions.Character"]
					this.Connector.Instructions["Simulation"] := this.Options["Driving Coach.Instructions.Simulation"]
					this.Connector.Instructions["Stint"] := this.Options["Driving Coach.Instructions.Stint"]
				}
				catch Any as exception {
					logError(exception)

					throw "Unsupported service detected in DrivingCoach.connect..."
				}
			}
			else
				throw "Unsupported service detected in DrivingCoach.connect..."

			this.iTranscript := (normalizeDirectoryPath(this.Options["Driving Coach.Archive"]) . "\" . translate("Conversation ") . A_Now . ".txt")
		}
	}

	stopConversation() {
		if this.Connector
			this.Connector.Restart()
	}

	handleVoiceText(grammar, text) {
		local answer := false

		try {
			if this.Speaker
				this.getSpeaker().speakPhrase("Confirm", false, false, false, {Noise: false})

			if !this.Connector
				this.startConversation()

			answer := this.Connector.Ask(text)
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

		if this.Debug[kDebugKnowledgeBase]
			this.dumpKnowledgeBase(this.KnowledgeBase)

		this.stopConversation()
	}

	finishSession(shutdown := true) {
		this.updateDynamicValues({KnowledgeBase: false, Prepared: false
								, OverallTime: 0, BestLapTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0
								, EnoughData: false})
		this.updateSessionValues({Simulator: "", Session: kSessionFinished, SessionTime: false})

		this.stopConversation()
	}
}