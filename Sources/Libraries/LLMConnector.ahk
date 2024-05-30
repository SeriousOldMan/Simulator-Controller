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

		static Models {
			Get {
				return []
			}
		}

		Models {
			Get {
				return LLMConnector.HTTPConnector.Models
			}
		}

		Model[external := false] {
			Get {
				if !external {
					if inList(this.base.Models, super.Model)
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

		CreateHeaders(headers?) {
			if !isSet(headers)
				headers := Map()

			if (Trim(this.Token) != "")
				headers["Authorization"] := ("Bearer " . this.Token)

			return headers
		}

		CreatePrompt(body, instructions, question) {
			throw "Virtual method HTTPConnector.CreatePrompt must be implemented in a subclass..."
		}

		Ask(question, instructions := false) {
			local headers := this.CreateHeaders(Map("Content-Type", "application/json"))
			local body := this.CreatePrompt({model: this.Model, max_tokens: this.MaxTokens, temperature: this.Temperature}, instructions ? instructions : this.GetInstructions(), question)

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
					answer := answer["choices"][1]

					if answer.Has("message")
						answer := answer["message"]["content"]
					else if answer.Has("text")
						answer := answer["text"]
					else
						throw "Unknown answer format detected..."

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

	class APIConnector extends LLMConnector.HTTPConnector {
		Models {
			Get {
				return this.LoadModels()
			}
		}

		CreateModelsURL(server) {
			return StrReplace(this.CreateServiceURL(server), "chat/completions", "models")
		}

		CreatePrompt(body, instructions, question) {
			local messages := []
			local ignore, instruction, conversation

			addInstruction(instruction) {
				if (instruction && (Trim(instruction) != ""))
					messages.Push({role: "system", content: instruction})
			}

			do(instructions, addInstruction)

			for ignore, conversation in this.History {
				messages.Push({role: "user", content: conversation[1]})
				messages.Push({role: "assistant", content: conversation[2]})
			}

			messages.Push({role: "user", content: question})

			body.messages := messages

			return body
		}

		ParseModels(response) {
			local result := []

			for ignore, element in response["data"]
				result.Push(element["id"])

			return result
		}

		LoadModels() {
			local models, ignore, element

			try {
				return this.ParseModels(WinHttpRequest().GET(this.CreateModelsURL(this.Server), "", this.CreateHeaders(), {Encoding: "UTF-8"}).JSON)
			}
			catch Any as exception {
				return []
			}
		}
	}

	class GenericConnector extends LLMConnector.APIConnector {
	}

	class OpenAIConnector extends LLMConnector.APIConnector {
		static Models {
			Get {
				return ["GPT 3.5 turbo", "GPT 4", "GPT 4 32k", "GPT 4 turbo", "GPT 4o"]
			}
		}

		Models {
			Get {
				return choose(super.Models, (m) => (InStr(m, "gpt") = 1))
			}
		}

		static GetDefaults(&serviceURL, &serviceKey, &model) {
			serviceURL := "https://api.openai.com/v1/chat/completions"
			serviceKey := ""
			model := "GPT 3.5 turbo"
		}
	}

	class AzureConnector extends LLMConnector.OpenAIConnector {
		static Models {
			Get {
				return ["GPT 3.5", "GPT 4", "GPT 4 turbo"]
			}
		}

		Models {
			Get {
				return choose(super.Models, (m) => (InStr(m, "gpt") = 1))
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

		static GetDefaults(&serviceURL, &serviceKey, &model) {
			serviceURL := "__YOUR_AZURE_OPENAI_ENDPOINT__/openai/deployments/%model%/chat/completions?api-version=2023-05-15"
			serviceKey := ""
			model := "GPT 3.5 turbo"
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

	class MistralAIConnector extends LLMConnector.APIConnector {
		static Models {
			Get {
				return ["Open Mistral 7b", "Open Mixtral 8x7b", "Open Mixtral 8x22b", "Mistral Small Latest", "Mistral Medium Latest", "Mistral Large Latest"]
			}
		}

		static GetDefaults(&serviceURL, &serviceKey, &model) {
			serviceURL := "https://api.mistral.ai/v1/chat/completions"
			serviceKey := ""
			model := "Open Mixtral 8x22b"
		}
	}

	class OpenRouterConnector extends LLMConnector.APIConnector {
		static GetDefaults(&serviceURL, &serviceKey, &model) {
			serviceURL := "https://openrouter.ai/api/v1/chat/completions"
			serviceKey := ""
			model := ""
		}
	}

	class OllamaConnector extends LLMConnector.APIConnector {
		static GetDefaults(&serviceURL, &serviceKey, &model) {
			serviceURL := "http://localhost:11434/v1/chat/completions"
			serviceKey := "ollama"
			model := ""
		}

		CreateModelsURL(server) {
			return StrReplace(this.CreateServiceURL(server), "v1/chat/completions", "api/tags")
		}

		ParseModels(response) {
			local result := []

			for ignore, element in response["models"]
				result.Push(element["name"])

			return result
		}
	}

	class GPT4AllConnector extends LLMConnector.APIConnector {
		static GetDefaults(&serviceURL, &serviceKey, &model) {
			serviceURL := "http://localhost:4891/v1/chat/completions"
			serviceKey := "Any text will do the job"
			model := ""
		}
	}

	/*
	class GPT4AllConnector extends LLMConnector.HTTPConnector {
		static GetDefaults(&serviceURL, &serviceKey, &model) {
			serviceURL := "http://localhost:4891/v1/chat/completions"
			serviceKey := "Any text will do the job"
			model := ""
		}

		CreatePrompt(body, instructions, question) {
			local prompt := ""
			local ignore, instruction, conversation

			addInstruction(instruction) {
				if (instruction && (Trim(instruction) != "")) {
					if (prompt = "")
						prompt .= "### System:`n"

					prompt .= (instruction . "`n")
				}
			}

			do(instructions, addInstruction)

			for ignore, conversation in this.History {
				prompt .= ("### Human:`n" . conversation[1] . "`n")
				prompt .= ("### Assistant:`n" . conversation[2] . "`n")
			}

			prompt .= ("### Human:`n" . question . "`n### Assistant:")

			body.prompt := prompt

			return body
		}
	}
	*/

	class LLMRuntimeConnector extends LLMConnector {
		CreatePrompt(instructions, question) {
			local prompt := ""
			local ignore, instruction, conversation

			addInstruction(instruction) {
				if (instruction && (Trim(instruction) != "")) {
					if (prompt = "")
						prompt .= "### System:`n"

					prompt .= (instruction . "`n")
				}
			}

			do(instructions, addInstruction)

			for ignore, conversation in this.History {
				prompt .= ("### Human:`n" . conversation[1] . "`n")
				prompt .= ("### Assistant:`n" . conversation[2] . "`n")
			}

			prompt .= ("### Human:`n" . question . "`n### Assistant:")

			return prompt
		}

		Ask(question, instructions := false) {
			local prompt := this.CreatePrompt(instructions ? instructions : this.GetInstructions(), question)
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

	static Providers {
		Get {
			return ["Generic", "OpenAI", "Mistral AI", "Azure", "OpenRouter", "Ollama", "GPT4All", "LLM Runtime"]
		}
	}

	static Models {
		Get {
			return []
		}
	}

	Models {
		Get {
			return LLMConnector.Models
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

	static GetDefaults(&serviceURL, &serviceKey, &model) {
		serviceURL := ""
		serviceKey := ""
		model := ((this.Models.Length > 0) ? this.Models[1] : "")
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

	Ask(question, instructions := false) {
		throw "Virtual method LLMConnector.Ask must be implemented in a subclass..."
	}
}