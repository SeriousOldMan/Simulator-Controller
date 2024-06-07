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

class LLMTool {
	iName := ""
	iDescription := ""

	class Function extends LLMTool {
		iParameters := []

		iCallable := false

		class Parameter {
			iName := ""
			iDescription := ""

			iType := "object"
			iEnumeration := false
			iRequired := true

			iReader := (v) => v

			Name {
				Get {
					return this.iName
				}
			}

			Description {
				Get {
					return this.iDescription
				}
			}

			Type {
				Get {
					return this.iType
				}
			}

			Enumeration {
				Get {
					return this.iEnumeration
				}
			}

			Required {
				Get {
					return this.iRequired
				}
			}

			Reader {
				Get {
					return this.iReader
				}
			}

			__New(name, description, type, enumeration := false, required := true, reader := (v) => v) {
				this.iName := name
				this.iDescription := description
				this.iType := StrLower(type)
				this.iEnumeration := enumeration
				this.iRequired := required
				this.iReader := reader
			}
		}

		Type {
			Get {
				return "function"
			}
		}

		Parameters {
			Get {
				return this.iParameters
			}
		}

		Callable {
			Get {
				return this.iCallable
			}
		}

		__New(name, description, parameters, callable) {
			this.iParameters := parameters
			this.iCallable := callable

			super.__New(name, description)
		}
	}

	Type {
		Get {
			throw "Virtual property LLTool.Type must be implemeneted in a subclass..."
		}
	}

	Name {
		Get {
			return this.iName
		}
	}

	Description {
		Get {
			return this.iDescription
		}
	}

	__New(name, description) {
		this.iName := name
		this.iDescription := description
	}
}

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

		CreatePrompt(body, instructions, tools, question) {
			throw "Virtual method HTTPConnector.CreatePrompt must be implemented in a subclass..."
		}

		CreateTools(body, tools) {
			throw "Virtual method HTTPConnector.CreateTools must be implemented in a subclass..."
		}

		ProcessToolCalls(tools, message) {
			return false
		}

		Ask(question, instructions := false, tools := false) {
			local headers := this.CreateHeaders(Map("Content-Type", "application/json"))
			local body := {model: this.Model, max_tokens: this.MaxTokens, temperature: this.Temperature}

			if !instructions
				instructions := this.GetInstructions()

			if !tools
				tools := this.GetTools()

			/*
			if InStr(this.Model, "Claude")
				if (tools.Length > 0)
					body.tool_choice := {type: "auto"}
			*/

			if isDebug()
				body := JSON.print(this.CreatePrompt(body, instructions, tools, question), "  ")
			else
				body := JSON.print(this.CreatePrompt(body, instructions, tools, question))

			if isDebug() {
				deleteFile(kTempDirectory . "LLM.request")

				FileAppend(body, kTempDirectory . "LLM.request")
			}

			answer := WinHttpRequest({Timeouts: [0, 60000, 30000, 60000]}).POST(this.CreateServiceURL(this.Server), body, headers, {Object: true, Encoding: "UTF-8"})

			if ((answer.Status >= 200) && (answer.Status < 300)) {
				this.Manager.connectorState("Active")

				answer := answer.JSON

				if isDebug() {
					deleteFile(kTempDirectory . "LLM.response")

					FileAppend(JSON.print(answer), kTempDirectory . "LLM.response")
				}

				try {
					answer := answer["choices"][1]

					if answer.Has("message") {
						answer := answer["message"]

						if this.ProcessToolCalls(tools, answer) {
							if answer.Has("content") {
								answer := answer["content"]

								if ((answer = kNull) || (Trim(answer) = ""))
									answer := true
							}
							else
								answer := true
						}
						else if answer.Has("content") {
							answer := answer["content"]

							if ((answer = kNull) || (Trim(answer) = ""))
								answer := false
						}
						else
							answer := false
					}
					else if answer.Has("text")
						answer := answer["text"]
					else
						throw "Unknown answer format detected..."

					if (answer && (answer != true))
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

		CreatePrompt(body, instructions, tools, question) {
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

			if (tools.Length > 0)
				body := this.CreateTools(body, tools)

			return body
		}

		CreateParameter(parameter) {
			Local descriptor := {description: parameter.Description
							   , type: parameter.Type}

			if parameter.Enumeration
				descriptor.Enum := parameter.Enumeration

			/*
			if InStr(this.Model, "Command")
				descriptor.required := (parameter.Required ? kTrue : kFalse)
			*/

			return descriptor
		}

		CreateParameters(function, &required?) {
			local parameters := {}
			local ignore, parameter

			if isSet(required)
				required := []

			for ignore, parameter in function.Parameters {
				parameters.%parameter.Name% := this.CreateParameter(parameter)

				if (parameter.Required && isSet(required))
					required.Push(parameter.Name)
			}

			return parameters
		}

		CreateFunction(function) {
			local required := []
			local parameters := this.CreateParameters(function, &required)

			/*
			if (!isInstance(this, LLMConnector.OpenRouterConnector) && InStr(this.Model, "Command"))
				return {name: function.Name, description: function.Description
					  , parameter_definitions: parameters}
			else if (!isInstance(this, LLMConnector.OpenRouterConnector) && InStr(this.Model, "Claude"))
				return {name: function.Name, description: function.Description
					  , input_schema: {type: "object", properties: parameters, required: required}}
			else
			*/
				return {type: "function"
					  , function: {name: function.Name, description: function.Description
								 , parameters: {type: "object", properties: parameters, required: required}}}
		}

		CreateTool(tool) {
			if (tool.Type = "function")
				return this.CreateFunction(tool)
			else
				throw "Unsupported tool type detected in LLMConnector.APIConnector.CreateTool..."
		}

		CreateTools(body, tools) {
			body.tools := collect(tools, ObjBindMethod(this, "CreateTool"))

			return body
		}

		CallTool(tools, tool) {
			local name, arguments, ignore, candidate, argument

			getArguments(function, arguments) {
				local result := []
				local ignore, paramater, name, argument, value

				for ignore, parameter in function.Parameters {
					value := kUndefined

					for name, argument in arguments
						if (name = parameter.Name) {
							value := parameter.Reader.Call(argument)

							break
						}

					result.Push((value = kUndefined) ? unset : value)
				}

				return result
			}

			if tool.Has("function") {
				tool := tool["function"]
				name := tool["name"]

				for ignore, candidate in tools
					if (candidate.Name = name) {
						arguments := tool["arguments"]

						if isInstance(arguments, String)
							arguments := JSON.parse(arguments)

						arguments := toMap(arguments)

						candidate.Callable.Call(getArguments(candidate, arguments)*)

						break
					}
			}
			else
				throw "Unsupported tool type detected in LLMConnector.APIConnector.CallTool..."
		}

		ProcessToolCalls(tools, message) {
			if (message.Has("tool_calls") && isInstance(message["tool_calls"], Array)) {
				do(message["tool_calls"], ObjBindMethod(this, "CallTool", tools))

				return true
			}
			else
				return false
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
			serviceURL := "http://localhost:11434/v1/chat/completions"
			serviceKey := "ollma"
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

	class LLMRuntimeConnector extends LLMConnector {
		CreatePrompt(instructions, tools, question) {
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

		Ask(question, instructions := false, tools := false) {
			local prompt := this.CreatePrompt(instructions ? instructions : this.GetInstructions()
											, tools ? tools : this.GetTools()
											, question)
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

	GetTools() {
		return this.Manager.getTools()
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