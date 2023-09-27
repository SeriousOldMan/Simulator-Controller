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

#Include "..\..\Libraries\Task.ahk"
#Include "..\..\Libraries\JSON.ahk"
#Include "..\..\Libraries\HTTP.ahk"
#Include "RaceAssistant.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class DrivingCoach extends GridRaceAssistant {
	iConnector := false

	class OpenAIConnector {
		iCoach := false

		iServer := ""
		iToken := ""
		iModel := ""

		iMaxTokens := 1024
		iTemperature := 0.5

		iInstructions := ""
		iTranscript := []
		iMaxTranscript := 3

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
				if internal {
					switch this.iModel, false {
						case "GPT 4":
							return "gpt-4"
						case "GPT 4 32k":
							return "gpt-4-32k"
						case "GPT 3.5 turbo":
							return "gpt-3.5-turbo"
						case "GPT 3.5 turbo 16k":
							return "gpt-3.5-turbo-16k"
						default:
							return this.iModel
					}
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

		Transcript[key?] {
			Get {
				return (isSet(key) ? this.iTranscript[key] : this.iTranscript)
			}
		}

		MaxTranscript {
			Get {
				return this.iMaxTranscript
			}

			Set {
				return (this.iMaxTranscript := value)
			}
		}

		Instructions {
			Get {
				return this.iInstructions
			}

			Set {
				return (this.iInstructions := value)
			}
		}

		__New(coach) {
			this.iCoach := coach
		}

		Connect(server?, token?, model?) {
			this.iServer := (isSet(server) ? server : this.Server)
			this.iToken := (isSet(token) ? token : this.Token)
			this.iModel := (isSet(model) ? model : this.Model)

			this.Transcript.Length := 0
		}

		Restart := () => this.Connect()

		AddConversation(question, answer) {
			this.Transcript.Push([question, answer])

			while (this.Transcript.Length > this.MaxTranscript)
				this.Transcript.RemoveAt(1)
		}

		Ask(question) {
			local coach := this.Coach
			local settingsDB := coach.SettingsDatabase
			local knowledgeBase := coach.KnowledgeBase
			local speaker := coach.getSpeaker()
			local url := "https://api.openai.com/v1/chat/completions"
			local headers := Map("Content-Type", "application/json", "Authorization", "Bearer " . this.Token)
			local body := {model: this.Model[true], max_tokens: this.MaxTokens, temperature: this.Temperature}
			local messages := []
			local ignore, conversation, message, simulator, car, track

			if (this.Instructions != "") {
				messages.Push({role: "system", content: this.Instructions})

				if (knowledgeBase && (this.Coach.Session != kSessionFinished)) {
					simulator := knowledgeBase.getValue("Session.Simulator")
					car := knowledgeBase.getValue("Session.Car")
					track := knowledgeBase.getValue("Session.Track")

					message := substituteVariables(speaker.Phrases["Simulation"]
												 , {name: coach.VoiceManager.Name
												  , driver: coach.DriverForName
												  , simulator: settingsDB.getSimulatorName(simulator)
												  , car: settingsDB.getCarName(simulator, car)
												  , track: settingsDB.getTrackName(simulator, track)})

					messages.Push({role: "system", content: message})

					position := coach.getPosition(false, "Class")

					if (position != 0) {
						message := substituteVariables(speaker.Phrases["Stint"]
													 , {lap: knowledgeBase.getValue("Lap") + 1
													  , position: position})

						messages.Push({role: "system", content: message})
					}
				}
			}

			for ignore, conversation in this.Transcript {
				messages.Push({role: "user", content: conversation[1]})
				messages.Push({role: "assistant", content: conversation[2]})
			}

			messages.Push({role: "user", content: question})

			body.messages := messages

			answer := WinHttpRequest().POST(url, JSON.print(body), headers, {Object: true, Encoding: "UTF-8"}).JSON
			answer := answer["choices"][1]["message"]["content"]

			this.AddConversation(question, answer)

			return answer
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

	__New(configuration, remoteHandler, name := false, language := kUndefined
		, synthesizer := false, speaker := false, vocalics := false, recognizer := false, listener := false, muted := false, voiceServer := false) {
		super.__New(configuration, "Driving Coach", remoteHandler, name, language, synthesizer, speaker, vocalics, recognizer, listener, muted, voiceServer)
	}

	loadFromConfiguration(configuration) {
		local options

		super.loadFromConfiguration(configuration)

		options := this.Options

		options["Driving Coach.Archive"] := getMultiMapValue(configuration, "Driving Coach Conversations", "Archive", kTempDirectory . "Conversations")
		options["Driving Coach.Service"] := getMultiMapValue(configuration, "Driving Coach", "Service", getMultiMapValue(configuration, "Driving Coach", "Service", false))
		options["Driving Coach.Model"] := getMultiMapValue(configuration, "Driving Coach", "Model", false)
		options["Driving Coach.MaxTokens"] := getMultiMapValue(configuration, "Driving Coach", "MaxTokens", 1024)
		options["Driving Coach.Temperature"] := getMultiMapValue(configuration, "Driving Coach", "Temperature", 0.5)
		options["Driving Coach.MaxTranscript"] := getMultiMapValue(configuration, "Driving Coach", "MaxTranscript", 3)
		options["Driving Coach.Instructions"] := getMultiMapValue(configuration, "Driving Coach", "Instructions", "")
	}

	connect() {
		local service := this.Options["Driving Coach.Service"]

		if (InStr(service, "OpenAI") = 1) {
			this.iConnector := DrivingCoach.OpenAIConnector()

			service := string2Values("|", service)

			this.Connector.Connect(service[2], service[3], this.Options["Driving Coach.Model"])

			this.Connector.MaxTokens := this.Options["Driving Coach.MaxTokens"]
			this.Connector.Temperature := this.Options["Driving Coach.Temperature"]
			this.Connector.MaxTranscript := this.Options["Driving Coach.History"]

			this.Connector.Instructions := this.Options["Driving Coach.Instructions"]
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
	}

	finishSession(shutdown := true) {
		this.updateDynamicValues({KnowledgeBase: false, Prepared: false
								, OverallTime: 0, BestLapTime: 0, LastFuelAmount: 0, InitialFuelAmount: 0
								, EnoughData: false})
		this.updateSessionValues({Simulator: "", Session: kSessionFinished, SessionTime: false})
	}
}