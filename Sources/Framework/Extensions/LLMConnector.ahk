﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LLM Connector                   ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Global Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework.ahk"


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

			Descriptor {
				Get {
					local descriptor := {description: this.Description, type: this.Type}

					if this.Enumeration
						descriptor.Enum := this.Enumeration

					return descriptor
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

				Set {
					return (this.iReader := value)
				}
			}

			__New(name, description, type, enumeration := false, required := true, reader := (v) => v) {
				if (enumeration && (enumeration.Length = 0))
					enumeration := false

				this.iName := name
				this.iDescription := description
				this.iType := StrLower(type)
				this.iEnumeration := enumeration
				this.iRequired := ((required = kTrue) ? kTrue : ((required = kFalse) ? false : required))
				this.iReader := reader
			}
		}

		Descriptor {
			Get {
				local required := []
				local parameters := {}
				local ignore, parameter

				for ignore, parameter in this.Parameters {
					parameters.%parameter.Name% := parameter.Descriptor

					if parameter.Required
						required.Push(parameter.Name)
				}

				return {type: "function"
					  , function: {name: this.Name, description: this.Description
								 , parameters: {type: "object", properties: parameters, required: required}}}
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

			Set {
				return (this.iCallable := false)
			}
		}

		__New(name, description, parameters, callable := false) {
			this.iParameters := parameters
			this.iCallable := callable

			super.__New(name, description)
		}

		static FromDescriptor(descriptor) {
			local parameters := []
			local required := []
			local name, parameter

			if !isObject(descriptor)
				descriptor := JSON.parse(descriptor)

			if descriptor["function"].Has("parameters") {
				if descriptor["function"]["parameters"].Has("required")
					required := descriptor["function"]["parameters"]["required"]

				for name, parameter in descriptor["function"]["parameters"]["properties"]
					parameters.Push(LLMTool.Function.Parameter(name, parameter["description"], parameter["type"],  parameter["enumeration"], inList(required, name)))
			}

			return LLMTool.Function(descriptor["function"]["name"], descriptor["function"]["description"], parameters)
		}
	}

	Descriptor {
		Get {
			throw "Virtual property LLMTool.Descriptor must be implemeneted in a subclass..."
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

	JSON {
		Get {
			return JSON.print(this.Descriptor, "  ")
		}
	}

	__New(name, description) {
		this.iName := name
		this.iDescription := description
	}

	static FromDescriptor(descriptor) {
		if !isObject(descriptor)
			descriptor := JSON.parse(descriptor)

		if isInstance(descriptor, Array)
			return collect(descriptor, ObjBindMethod(this, "FromDescriptor"))
		else if (descriptor["type"] = "function")
			return LLMTool.Function.FromDescriptor(descriptor)
		else
			throw "Unknown tool type detected in LLMTool.FromDescriptor..."
	}
}

class LLMConnector {
	iManager := false
	iModel := false

	iMaxTokens := 1024
	iTemperature := 0.5

	iHistory := []
	iMaxHistory := 3
	iHistoryEnabled := true

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

		Certificate {
			Get {
				return "CURRENT_USER\My\SimulatorController"
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
			if this.History {
				this.History.Push([question, answer])

				while (this.History.Length > this.MaxHistory)
					this.History.RemoveAt(1)
			}
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

		ProcessToolCalls(tools, message, &calls?) {
			return false
		}

		Ask(question, instructions := false, tools := false, &calls?) {
			local headers := this.CreateHeaders(Map("Content-Type", "application/json"))
			local body := {model: this.Model, max_tokens: this.MaxTokens, temperature: this.Temperature}
			local toolCall := false

			if !instructions
				instructions := this.GetInstructions()

			if !tools
				tools := this.GetTools()

			if isDebug()
				body := JSON.print(this.CreatePrompt(body, instructions, tools, question), "  ")
			else
				body := JSON.print(this.CreatePrompt(body, instructions, tools, question))

			if isDebug() {
				deleteFile(kTempDirectory . "LLM.request")

				try
					FileAppend(body, kTempDirectory . "LLM.request")
			}

			try {
				if this.Certificate {
					try {
						answer := WinHttpRequest({Timeouts: [0, 60000, 30000, 60000]
												, Certificate: this.Certificate}).POST(this.CreateServiceURL(this.Server)
																					 , body, headers, {Object: true, Encoding: "UTF-8"})
					}
					catch Any as exception {
						logError(exception, true)

						answer := WinHttpRequest({Timeouts: [0, 60000, 30000, 60000]}).POST(this.CreateServiceURL(this.Server)
																						  , body, headers, {Object: true, Encoding: "UTF-8"})
					}
				}
				else
					answer := WinHttpRequest({Timeouts: [0, 60000, 30000, 60000]}).POST(this.CreateServiceURL(this.Server)
																					  , body, headers, {Object: true, Encoding: "UTF-8"})

				if ((answer.Status >= 200) && (answer.Status < 300)) {
					this.Manager.connectorState("Active")

					answer := answer.JSON

					if isDebug() {
						deleteFile(kTempDirectory . "LLM.response")

						try
							FileAppend(JSON.print(answer, "  "), kTempDirectory . "LLM.response")
					}

					try {
						answer := answer["choices"][1]

						if answer.Has("message") {
							answer := answer["message"]

							if isSet(calls)
								toolCall := this.ProcessToolCalls(tools, answer, &calls)
							else
								toolCall := this.ProcessToolCalls(tools, answer)

							if toolCall {
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
								else
									answer := this.ParseAnswer(answer)
							}
							else
								answer := false
						}
						else if answer.Has("text")
							answer := this.ParseAnswer(answer["text"])
						else
							throw "Unknown answer format detected..."

						if (answer && (answer != true))
							this.AddConversation(question, answer)

						return answer
					}
					catch Any as exception {
						logError(exception, true)

						this.Manager.connectorState("Error", "Answer", answer)

						return false
					}
				}
				else {
					if isDebug()
						logMessage(kLogDebug, "LLM API call returned " . answer.Status . " in HTTPConnector.Ask...")

					this.Manager.connectorState("Error", "Connection", answer.Status)

					return false
				}
			}
			catch Any as exception {
				logError(exception, true)

				this.Manager.connectorState("Error", "Connection", isSet(answer) ? answer.Status : unset)

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

			for ignore, conversation in (this.History ? this.History : []) {
				messages.Push({role: "user", content: conversation[1]})
				messages.Push({role: "assistant", content: conversation[2]})
			}

			messages.Push({role: "user", content: question})

			body.messages := messages

			if (tools.Length > 0)
				body := this.CreateTools(body, tools)

			return body
		}

		CreateTools(body, tools) {
			body.tools := collect(tools, (t) => t.Descriptor)

			return body
		}

		FindTool(tools, name) {
			local ignore, candidate

			for ignore, candidate in tools
				if (candidate.Name = name)
					return candidate

			return false
		}

		CallTool(tools, tool) {
			local name, arguments, argument

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
				arguments := tool["arguments"]

				tool := this.FindTool(tools, tool["name"])

				if tool {
					if isInstance(arguments, String)
						arguments := JSON.parse(arguments)

					arguments := getArguments(tool, toMap(arguments))

					tool.Callable.Call(arguments*)

					return Array(tool, arguments)
				}
				else
					return false
			}
			else
				throw "Unsupported tool type detected in LLMConnector.APIConnector.CallTool..."
		}

		ProcessToolCalls(tools, message, &calls?) {
			if (message.Has("tool_calls") && isInstance(message["tool_calls"], Array)) {
				if isSet(calls)
					calls := choose(collect(message["tool_calls"], ObjBindMethod(this, "CallTool", tools)), (v) => !!v)
				else
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
			try {
				if this.Certificate {
					try {
						answer := WinHttpRequest({Certificate: this.Certificate}).GET(this.CreateModelsURL(this.Server), "", this.CreateHeaders(), {Encoding: "UTF-8"})
					}
					catch Any as exception {
						logError(exception)

						answer := WinHttpRequest().GET(this.CreateModelsURL(this.Server), "", this.CreateHeaders(), {Encoding: "UTF-8"})
					}
				}
				else
					answer := WinHttpRequest().GET(this.CreateModelsURL(this.Server), "", this.CreateHeaders(), {Encoding: "UTF-8"})

				if ((answer.Status >= 200) && (answer.Status < 300))
					return this.ParseModels(answer.JSON)
				else {
					if isDebug()
						logMessage(kLogDebug, "LLM API call returned " . answer.Status . " in APIConnector.LoadModels...")

					return []
				}
			}
			catch Any as exception {
				logError(exception)

				return []
			}
		}
	}

	class GenericConnector extends LLMConnector.APIConnector {
	}

	class OpenAIConnector extends LLMConnector.APIConnector {
		static Models {
			Get {
				return ["GPT 4o mini", "GPT 3.5 turbo", "GPT 4", "GPT 4 32k", "GPT 4 turbo", "GPT 4o"]
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
			model := "GPT 4.1 mini"
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
			model := "GPT 4.1 mini"
		}

		CreateServiceURL(server) {
			return substituteVariables(server, {model: this.iModel})
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

	class GoogleConnector extends LLMConnector.APIConnector {
		static Models {
			Get {
				return ["gemini-2.0-flash", "gemini-2.0-flash-lite", "gemini-1.5-flash", "gemini-1.5-pro"]
			}
		}

		Models {
			Get {
				return choose(super.Models, (m) => (InStr(m, "gemini") = 1))
			}
		}

		static GetDefaults(&serviceURL, &serviceKey, &model) {
			serviceURL := "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
			serviceKey := ""
			model := "gemini-2.0-flash-lite"
		}

		ParseModels(response) {
			local result := []

			for ignore, element in response["data"]
				result.Push(StrReplace(element["id"], "models/", ""))

			return result
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
		iLLMRuntime := false
		iGPULayers := 0

		LLMRuntime {
			Get {
				return this.iLLMRuntime
			}
		}

		GPULayers {
			Get {
				return this.iGPULayers
			}

			Set {
				return (this.iGPULayers := value)
			}
		}

		__New(manager, model, gpuLayers := 0) {
			this.iGPULayers := gpuLayers

			super.__New(manager, model)

			OnExit((*) => this.Disconnect())
		}

		Connect(force := false) {
			local exePath, options, llmRuntime

			if (!force && this.LLMRuntime && !ProcessExist(this.LLMRuntime))
				return false

			if (!this.LLMRuntime || force) {
				this.Disconnect(force)

				llmRuntime := ProcessExist("LLM Runtime.exe")

				if llmRuntime
					this.iLLMRuntime := llmRuntime
				else {
					exePath := (kProgramsDirectory . "LLM Runtime\LLM Runtime.exe")

					if FileExist(exePath) {
						deleteFile(kTempDirectory . "LLMRuntime.cmd")
						deleteFile(kTempDirectory . "LLMRuntime.out")

						options := ("`"" . this.Model . "`" " . this.Temperature . A_Space . this.MaxTokens . A_Space . this.GPULayers)

						Run("`"" . exePath . "`" `"" . kTempDirectory . "LLMRuntime.cmd`" `"" . kTempDirectory . "LLMRuntime.out`" " . options, kBinariesDirectory, "Hide", &llmRuntime)

						if llmRuntime {
							Sleep(1000)

							if ProcessExist(llmRuntime) {
								this.iLLMRuntime := llmRuntime

								return true
							}
						}
					}

					return false
				}
			}

			return true
		}

		Disconnect(force := false) {
			if ((this.LLMRuntime || force) && ProcessExist("LLM Runtime.exe")) {
				loop 5 {
					try {
						deleteFile(kTempDirectory . "LLMRuntime.cmd")

						try
							FileAppend("Exit`n", kTempDirectory . "LLMRuntime.cmd")
					}
					catch Any as exception {
						if (A_Index = 5)
							logError(exception, true)
					}

					Sleep(250)

					if !ProcessExist("LLM Runtime.exe")
						break
				}

				this.iLLMRuntime := false
			}

			return false
		}

		CreatePrompt(instructions, tools, question) {
			local prompt := ""
			local ignore, instruction, conversation

			addInstruction(instruction) {
				if (instruction && (Trim(instruction) != "")) {
					if (prompt = "")
						prompt .= "<|### System ###|>`n"

					prompt .= (instruction . "`n")
				}
			}

			do(instructions, addInstruction)

			for ignore, conversation in (this.History ? this.History : []) {
				prompt .= ("<|### User ###|>`n" . conversation[1] . "`n")
				prompt .= ("<|### Assistant ###|>`n" . conversation[2] . "`n")
			}

			prompt .= ("<|### User ###|>`n" . question)

			return prompt
		}

		ProcessToolCalls(tools, message, &calls?) {
			return false
		}

		ParseAnswer(answer) {
			return Trim(StrReplace(StrReplace(StrReplace(super.ParseAnswer(answer), "System:", ""), "Assistant:", ""), "User:", ""))
		}

		Ask(question, instructions := false, tools := false, &calls?) {
			local prompt := this.CreatePrompt(instructions ? instructions : this.GetInstructions()
											, tools ? tools : this.GetTools()
											, question)
			local toolCall := false
			local command, answer

			if !this.Connect() {
				this.Manager.connectorState("Error", "Connection")

				return false
			}

			if isDebug() {
				deleteFile(kTempDirectory . "LLM.request")

				try
					FileAppend(prompt, kTempDirectory . "LLM.request")
			}

			try {
				; prompt := StrReplace(StrReplace(prompt, "`"", "\`""), "`n", "\n")

				while !deleteFile(kTempDirectory . "LLMRuntime.cmd")
					Sleep(50)

				while !deleteFile(kTempDirectory . "LLMRuntime.out")
					Sleep(50)

				loop 5
					try {
						FileAppend(prompt, kTempDirectory . "LLMRuntime.cmd")

						break
					}
					catch Any as exception {
						if (A_Index = 5)
							logError(exception, true)
						else
							Sleep(10)
					}

				loop (isDebug() ? 240 : 120)
					try
						if FileExist(kTempDirectory . "LLMRuntime.out") {
							Sleep(500)

							break
						}
						else
							Sleep(1000)
			}
			catch Any as exception {
				logError(exception, true)

				this.Manager.connectorState("Error", "Connection")

				return false
			}

			try {
				if !FileExist(kTempDirectory . "LLMRuntime.out") {
					this.Manager.connectorState("Error", "Answer")

					return false
				}

				answer := Trim(FileRead(kTempDirectory . "LLMRuntime.out", "`n"))

				while ((StrLen(answer) > 0) && (SubStr(answer, 1, 1) = "`n"))
					answer := SubStr(answer, 2)

				if (Trim(answer) = "Error")
					answer := false
				else {
					this.Manager.connectorState("Active")

					if isSet(calls)
						toolCall := this.ProcessToolCalls(tools, answer, &calls)
					else
						toolCall := this.ProcessToolCalls(tools, answer)

					deleteFile(kTempDirectory . "LLMRuntime.out")

					if toolCall
						return true
					else {
						answer := this.ParseAnswer(answer)

						if isDebug() {
							deleteFile(kTempDirectory . "LLM.response")

							try
								FileAppend(answer, kTempDirectory . "LLM.response")
						}

						this.AddConversation(question, answer)

						return answer
					}
				}
			}
			catch Any as exception {
				logError(exception, true)

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
			if FileExist(kProgramsDirectory . "LLM Runtime\LLM Runtime.exe")
				return ["Generic", "OpenAI", "Mistral AI", "Azure", "Google", "OpenRouter", "Ollama", "GPT4All", "LLM Runtime"]
			else
				return ["Generic", "OpenAI", "Mistral AI", "Azure", "Google", "OpenRouter", "Ollama", "GPT4All"]
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
			if this.iHistoryEnabled
				return (isSet(key) ? this.iHistory[key] : this.iHistory)
			else
				return false
		}

		Set {
			return (this.iHistoryEnabled := (value != false))
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
		this.History := true

		this.History.Length := 0
	}

	GetInstructions() {
		return this.Manager.getInstructions()
	}

	GetTools() {
		return this.Manager.getTools()
	}

	ParseAnswer(answer) {
		local index := InStr(answer, "</think>")

		if index
			answer := SubStr(answer, index + 8)

		return answer
	}

	AddConversation(question, answer) {
		if this.History {
			this.History.Push([question, answer])

			while (this.History.Length > this.MaxHistory)
				this.History.RemoveAt(1)
		}
	}

	Ask(question, instructions := false) {
		throw "Virtual method LLMConnector.Ask must be implemented in a subclass..."
	}
}