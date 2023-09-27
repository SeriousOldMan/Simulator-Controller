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

class DrivingCoach extends RaceAssistant {
	iConnector := false

	class ChatGPTConnector {
		iServer := ""
		iToken := ""
		iModel := ""

		iMaxTokens := 1024
		iTemperature := 0.5

		iSystem := ""
		iTranscript := []
		iMaxTranscript := 3

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

		System {
			Get {
				return this.iSystem
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

		Connect(server?, token?, model?) {
			this.iServer := (isSet(server) ? server : this.Server)
			this.iToken := (isSet(token) ? token : this.Token)
			this.iModel := (isSet(model) ? model : this.Model)

			this.Transcript.Length := 0
		}

		Restart := () => this.Connect()

		SetSystem(text) {
			this.iSystem := text
		}

		AddConversation(question, answer) {
			this.Transcript.Push([question, answer])

			while (this.Transcript.Length > this.MaxTranscript)
				this.Transcript.RemoveAt(1)
		}

		Ask(question) {
			local url := "https://api.openai.com/v1/chat/completions"
			local headers := Map("Content-Type", "application/json", "Authorization", "Bearer " . this.Token)
			local body := {model: this.Model[true], max_tokens: this.MaxTokens, temperature: this.Temperature}
			local messages := []
			local ignore, conversation

			if (this.System != "")
				messages.Push({role: "system", content: this.System})

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
		this.iConnector := DrivingCoach.ChatGPTConnector()

		this.Connector.Connect("", "", "GPT 3.5 turbo")

		this.initializeCoach()

		; result := this.Connector.Ask("I have understeering on corner entry in fast corners. What can I do?")

		; result := this.Connector.Ask("I always have neck pain and feel a little bit dizzy after a race. What do you recommend?")

		; result := this.Connector.Ask("The feeling in my brake pedal of my sim racing rig is kind of dumb. What do you recommend?")

		; result := this.Connector.Ask("Wie stelle ich am besten das FOV ein?")
		; result := this.Connector.Ask("Und bei einem Triple Screen?")

		result := this.Connector.Ask("Hast Du ein Kochrezept für Möhrensuppe?")

		MsgBox(result)

		super.__New(configuration, "Driving Coach", remoteHandler, name, language, synthesizer, speaker, vocalics, recognizer, listener, muted, voiceServer)
	}

	initializeCoach() {
		this.Connector.SetSystem("You are a driving coach for circuit racing in simulations but also in real world racing. You are experienced in handling issues generated by driver errors but you also know all about car physics and the relationship between car setup choices and handling issues.`n"
							   . "Instructions:`n"
							   . "- Only answer questions regarding car handling and car physics."
							   . "- If you're unsure of an answer, you can say `"I don't know`" or `"I'm not sure`" and recommend to use the telemetry analyzer of the application `"Setup Workkbench`" to analyze handling problems of the car.")
	}
}