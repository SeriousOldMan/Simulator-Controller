;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LLM Connector                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "JSON.ahk"
#Include "HTTP.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class LLMConnector {
	iManager := false
	iModel := false

	iMaxTokens := 1024
	iTemperature := 0.5

	iHistory := []
	iMaxHistory := 3

	class HTTPConnector extends LLMConnector {
		iServer := ""
		iToken := ""

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
					if inList(this.Models, super.Model)
						return StrLower(StrReplace(super.Model, A_Space, "-"))
					else
						return super.Model
				}
				else
					return super.Model
			}
		}

		Connect(server?, token?) {
			this.iServer := (isSet(server) ? server : this.Server)
			this.iToken := (isSet(token) ? token : this.Token)
		}

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
			local headers := this.CreateHeaders(Map("Content-Type", "application/json"))
			local body := this.CreatePrompt({model: this.Model, max_tokens: this.MaxTokens, temperature: this.Temperature}, question)

			body := JSON.print(body)

			if isDebug() {
				deleteFile(kTempDirectory . "LLM.request")

				FileAppend(body, kTempDirectory . "LLM.request")
			}

			answer := WinHttpRequest().POST(this.CreateServiceURL(this.Server), body, headers, {Object: true, Encoding: "UTF-8"})

			if ((answer.Status >= 200) && (answer.Status < 300)) {
				this.Manager.connectorState("Active")

				answer := answer.JSON

				if isDebug() {
					deleteFile(kTempDirectory . "LLM.response")

					FileAppend(JSON.print(answer), kTempDirectory . "LLM.response")
				}

				try {
					answer := answer["choices"][1]["message"]["content"]

					this.AddConversation(question, answer)

					return answer
				}
				catch Any as exception {
					this.Manager.connectorState("Error", "Answer", answer)

					return false
				}
			}
			else {
				this.Manager.connectorState("Error", "Connection", answer.Status)

				return false
			}
		}
	}

	class OpenAIConnector extends LLMConnector.HTTPConnector {
		Models {
			Get {
				return ["GPT 3.5", "GPT 3.5 turbo", "GPT 3.5 turbo 1106", "GPT 4", "GPT 4 32k", "GPT 4 1106 preview"]
			}
		}

		CreatePrompt(body, question) {
			local messages := []
			local ignore, instruction, conversation

			addInstruction(instruction) {
				if (instruction && (Trim(instruction) != ""))
					messages.Push({role: "system", content: instruction})
			}

			do(this.GetInstructions(), addInstruction)

			for ignore, conversation in this.History {
				messages.Push({role: "user", content: conversation[1]})
				messages.Push({role: "assistant", content: conversation[2]})
			}

			messages.Push({role: "user", content: question})

			body.messages := messages

			return body
		}
	}

	class AzureConnector extends LLMConnector.OpenAIConnector {
		Models {
			Get {
				return ["GPT 3.5", "GPT 3.5 turbo", "GPT 4", "GPT 4 32k"]
			}
		}

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

	class GPT4AllConnector extends LLMConnector.HTTPConnector {
		CreatePrompt(body, question) {
			local prompt := ""
			local ignore, instruction, conversation

			addInstruction(instruction) {
				if (instruction && (Trim(instruction) != "")) {
					if (prompt = "")
						prompt .= "### System:`n"

					prompt .= (instruction . "`n")
				}
			}

			do(this.GetInstructions(), addInstruction)

			for ignore, conversation in this.History {
				prompt .= ("### Human:`n" . conversation[1] . "`n")
				prompt .= ("### Assistant:`n" . conversation[2] . "`n")
			}

			prompt .= ("### Human:`n" . question . "`n### Assistant:")

			body.prompt := prompt

			return body
		}
	}

	class LLMRuntimeConnector extends LLMConnector {
		CreatePrompt(question) {
			local prompt := ""
			local ignore, instruction, conversation

			addInstruction(instruction) {
				if (instruction && (Trim(instruction) != "")) {
					if (prompt = "")
						prompt .= "### System:`n"

					prompt .= (instruction . "`n")
				}
			}

			do(this.GetInstructions(), addInstruction)

			for ignore, conversation in this.History {
				prompt .= ("### Human:`n" . conversation[1] . "`n")
				prompt .= ("### Assistant:`n" . conversation[2] . "`n")
			}

			prompt .= ("### Human:`n" . question . "`n### Assistant:")

			return prompt
		}

		Ask(question) {
			local prompt := this.CreatePrompt(question)
			local answerFile := temporaryFileName("LLMRuntime", "answer")
			local command, answer

			if isDebug() {
				deleteFile(kTempDirectory . "LLM.request")

				FileAppend(prompt, kTempDirectory . "LLM.request")
			}

			try {
				prompt := StrReplace(StrReplace(prompt, "`"", "\`""), "`n", "\n")

				command := (A_ComSpec . " /c `"`"" . kBinariesDirectory . "\LLM Runtime\LLM Runtime.exe`" `"" . this.Model . "`" `"" . prompt . "`" " . this.MaxTokens . A_Space . this.Temperature . " > `"" . answerFile . "`"`"")

				RunWait(command, kBinariesDirectory . "\LLM Runtime", "Hide")
			}
			catch Any as exception {
				this.Manager.connectorState("Error", "Connection")

				return false
			}

			try {
				answer := Trim(FileRead(answerFile, "`n"))

				while ((StrLen(answer) > 0) && (SubStr(answer, 1, 1) = "`n"))
					answer := SubStr(answer, 2)

				deleteFile(answerFile)

				if (answer = "")
					throw "Empty answer received..."

				if isDebug() {
					deleteFile(kTempDirectory . "LLM.response")

					FileAppend(answer, kTempDirectory . "LLM.response")
				}

				this.AddConversation(question, answer)

				return answer
			}
			catch Any as exception {
				this.Manager.connectorState("Error", "Answer")

				return false
			}
		}
	}

	Manager {
		Get {
			return this.iManager
		}
	}

	Models {
		Get {
			return []
		}
	}

	Model {
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

	__New(manager, model) {
		this.iManager := manager
		this.iModel := model
	}

	Restart() {
		this.History.Length := 0
	}

	GetInstructions() {
		return this.Manager.getInstructions()
	}

	AddConversation(question, answer) {
		this.History.Push([question, answer])

		while (this.History.Length > this.MaxHistory)
			this.History.RemoveAt(1)
	}

	Ask(question) {
		throw "Virtual method LLMConnector.Ask must be implemented in a subclass..."
	}
}