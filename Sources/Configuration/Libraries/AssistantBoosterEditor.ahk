﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Assistant Booster Editor        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\LLMConnector.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\SpeechSynthesizer.ahk"
#Include "..\..\Framework\Extensions\LLMConnector.ahk"
#Include "..\..\Framework\Extensions\JSON.ahk"
#Include "..\..\Framework\Extensions\CodeEditor.ahk"
#Include "..\..\Framework\Extensions\RuleEngine.ahk"
#Include "..\..\Framework\Extensions\ScriptEngine.ahk"
#Include "ConfigurationEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; AssistantBoosterEditor                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class AssistantBoosterEditor extends ConfiguratorPanel {
	iResult := false

	iAssistant := false

	iWindow := false

	iBoosters := ["Speaker", "Listener", "Conversation", "Agent"]

	iProviderConfigurations := CaseInsenseMap()
	iCurrentConversationProvider := false
	iCurrentAgentProvider := false

	iInstructions := newMultiMap()

	Assistant {
		Get {
			return this.iAssistant
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	Providers {
		Get {
			return LLMConnector.Providers
		}
	}

	Boosters {
		Get {
			return this.iBoosters
		}
	}

	Models[provider] {
		Get {
			try {
				return LLMConnector.%StrReplace(provider, A_Space, "")%Connector.Models
			}
			catch Any {
				return []
			}
		}
	}

	__New(assistant, configuration := false, boosters := false) {
		this.iAssistant := assistant

		if boosters
			this.iBoosters := boosters

		super.__New(configuration)
	}

	createGui(configuration) {
		local choices := []
		local chosen := 0
		local x := 8
		local width := 460
		local editorGui, x0, x1, x2, w1, w2, x3, w3, x4, w4
		local x0, x1, x2, x3, x4, x5, x6, w1, w2, w3, w4, lineX, lineW

		validatePercentage(field, *) {
			local value

			field := this.Control[field]
			value := field.Text

			if (!isInteger(value) || (value < 0) || (value > 100)) {
				field.Text := (field.HasProp("ValidText") ? field.ValidText : "")

				loop 10
					SendInput("{Right}")
			}
			else
				field.ValidText := field.Text

			this.updateState()
		}

		validateTokens(field, *) {
			local value

			field := this.Control[field]
			value := field.Text

			if (!isInteger(value) || (value < 32)) {
				field.Text := (field.HasProp("ValidText") ? field.ValidText : "200")

				loop 10
					SendInput("{Right}")
			}
			else
				field.ValidText := field.Text
		}

		chooseConversationProvider(*) {
			this.saveProviderConfiguration()

			this.loadProviderConfiguration("Conversation", editorGui["viConversationProviderDropDown"].Text)

			this.updateState()
		}

		chooseAgentProvider(*) {
			this.saveProviderConfiguration()

			this.loadProviderConfiguration("Agent", editorGui["viAgentProviderDropDown"].Text)

			this.updateState()
		}

		chooseModelPath(field, *) {
			local fileName, translator

			editorGui.Opt("+OwnDialogs")

			translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

			OnMessage(0x44, translator)
			fileName := withBlockedWindows(FileSelect, 1, "", translate("Select model file..."), "GGUF (*.GGUF)")
			OnMessage(0x44, translator, 0)

			if (fileName != "")
				editorGui[field].Text := fileName
		}

		editInstructions(type, title, *) {
			this.editInstructions(type, title)
		}

		editEvents(*) {
			this.editEvents(this.Assistant)
		}

		editActions(type, *) {
			this.editActions(this.Assistant, type)
		}

		loadModels(type, *) {
			local provider := ((type = "Conversation") ? this.iCurrentConversationProvider : this.iCurrentAgentProvider)
			local configuration

			if provider {
				configuration := this.iProviderConfigurations[type . "." . provider]

				this.loadModels(type, provider, this.Control["vi" . type . "ServiceURLEdit"].Text
											  , this.Control["vi" . type . "ServiceKeyEdit"].Text
											  , this.Control[(provider = "LLM Runtime") ? ("vi" . type . "ModelEdit")
																						: ("vi" . type . "ModelDropDown")].Text)
			}
			else
				this.loadModels(type, false)
		}

		editorGui := Window({Descriptor: "Booster Editor", Options: "0x400000"})

		this.iWindow := editorGui

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "w468 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Booster Editor"))

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Documentation", "x158 YP+20 w168 H:Center Center", translate("Assistant Booster")
					, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#connecting-an-assistant-to-an-llm")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x8 yp+30 w468 W:Grow 0x10")

		x0 := x + 16
		x1 := x + 132
		x2 := x + 172
		x3 := x + 176

		w1 := width - (x1 - x + 8)
		w3 := width - (x3 - x + 16) + 10

		w2 := w1 - 24
		x4 := x1 + w2 + 1

		w4 := w1 - 24
		x6 := x1 + w4 + 1

		editorGui.SetFont("Italic Bold", "Arial")
		editorGui.Add("Text", "x" . (x + 8) . " yp+10 w100 h23", translate("Conversation"))
		editorGui.Add("Text", "x120 yp+7 w" . (width + 8 - 120) . " 0x10 W:Grow")
		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x" . x0 . " yp+20 w110 h23 +0x200 vviConversationProviderLabel", translate("Provider / URL"))

		editorGui.Add("DropDownList", "x" . x1 . " yp w100 Choose1 vviConversationProviderDropDown", concatenate([translate("Disabled")], this.Providers)).OnEvent("Change", chooseConversationProvider)

		editorGui.Add("Edit", "x" . (x1 + 102) . " yp w" . (w1 - 102) . " h23 vviConversationServiceURLEdit").OnEvent("Change", loadModels.Bind("Conversation"))

		editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200 Section vviConversationServiceKeyLabel", translate("Service Key"))
		editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h23 Password vviConversationServiceKeyEdit").OnEvent("Change", loadModels.Bind("Conversation"))

		editorGui.Add("Text", "x" . x0 . " yp+30 w110 h23 +0x200 vviConversationModelLabel", translate("Model / # Tokens"))
		editorGui.Add("ComboBox", "x" . x1 . " yp w" . (w1 - 64) . " vviConversationModelDropDown")
		editorGui.Add("Edit", "x" . (x1 + (w1 - 60)) . " yp-1 w60 h23 Number vviConversationMaxTokensEdit").OnEvent("Change", validateTokens.Bind("viConversationMaxTokensEdit"))
		editorGui.Add("UpDown", "x" . (x1 + (w1 - 60)) . " yp w60 h23 0x80 Range32-131072 vviConversationMaxTokensRange")

		editorGui.Add("Text", "x" . x0 . " ys+6 w110 h23 +0x200 vviConversationLLMRTModelLabel Hidden", translate("Model"))
		editorGui.Add("Edit", "x" . x1 . " yp w" . (w1 - 24) . " vviConversationLLMRTModelEdit Hidden")
		editorGui.Add("Button", "x" . (x1 + (w1 - 23)) . " yp h23 w23 vviConversationLLMRTModelButton Hidden", translate("...")).OnEvent("Click", chooseModelPath.Bind("viConversationLLMRTModelEdit"))

		editorGui.Add("Text", "x" . x0 . " yp+24 w120 h23 +0x200 vviConversationLLMRTTokensLabel Hidden", translate("# Tokens / # GPULayers"))
		editorGui.Add("Edit", "x" . x1 . " yp-1 w60 h23 Number vviConversationLLMRTMaxTokensEdit Hidden").OnEvent("Change", validateTokens.Bind("viConversationLLMRTMaxTokensEdit"))
		editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 0x80 Range32-131072 vviConversationLLMRTMaxTokensRange Hidden")
		editorGui.Add("Edit", "x" . (x1 + 62) . " yp w60 h23 Number Limit2 vviConversationLLMRTGPULayersEdit Hidden")
		editorGui.Add("UpDown", "x" . (x1 + 62) . " yp w60 h23 Range0-99 vviConversationLLMRTGPULayersRange Hidden")

		editorGui.SetFont("Italic", "Arial")
		editorGui.Add("Checkbox", "x" . x0 . " yp+36 w100 h21 vviSpeakerCheck", translate("Rephrasing")).OnEvent("Click", (*) => this.updateState())
		editorGui.Add("Text", "x127 yp+11 w" . (width + 8 - 127) . " 0x10 W:Grow")
		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x" . x0 . " yp+20 w110 h23 +0x200", translate("Activation"))
		editorGui.Add("Edit", "x" . x1 . " yp w60 Number Limit3 vviSpeakerProbabilityEdit").OnEvent("Change", validatePercentage.Bind("viSpeakerProbabilityEdit"))
		editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-100")
		editorGui.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200", translate("%"))

		editorGui.Add("Button", "x" . (width - 100) . " yp w100 h23 X:Move vviSpeakerInstructionsButton", translate("Instructions...")).OnEvent("Click", editInstructions.Bind("Speaker", translate("Rephrasing")))

		editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200", translate("Creativity"))
		editorGui.Add("Edit", "x" . x1 . " yp w60 Number Limit3 vviSpeakerTemperatureEdit").OnEvent("Change", validatePercentage.Bind("viSpeakerTemperatureEdit"))
		editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-100")
		editorGui.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200", translate("%"))

		editorGui.SetFont("Italic", "Arial")
		editorGui.Add("Checkbox", "x" . x0 . " yp+36 w100 h21 vviListenerCheck", translate("Understanding")).OnEvent("Click", (*) => this.updateState())
		editorGui.Add("Text", "x127 yp+11 w" . (width + 8 - 127) . " 0x10 W:Grow")
		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x" . x0 . " yp+20 w110 h23 +0x200", translate("Activation"))
		editorGui.Add("DropDownList", "x" . x1 . " yp w100 Choose1 vviListenerModeDropDown", collect(["Always", "Unrecognized"], translate)).OnEvent("Change", (*) => this.updateState())

		editorGui.Add("Button", "x" . (width - 100) . " yp w100 h23 X:Move vviListenerInstructionsButton", translate("Instructions...")).OnEvent("Click", editInstructions.Bind("Listener", translate("Understanding")))

		editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200", translate("Creativity"))
		editorGui.Add("Edit", "x" . x1 . " yp w60 Number Limit3 vviListenerTemperatureEdit").OnEvent("Change", validatePercentage.Bind("viListenerTemperatureEdit"))
		editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-100")
		editorGui.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200", translate("%"))

		editorGui.SetFont("Italic", "Arial")
		editorGui.Add("Checkbox", "x" . x0 . " yp+36 w100 h21 vviConversationCheck", translate("Conversation")).OnEvent("Click", (*) => this.updateState())
		editorGui.Add("Text", "x127 yp+11 w" . (width + 8 - 127) . " 0x10 W:Grow")
		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200", translate("Memory"))
		editorGui.Add("Edit", "x" . x1 . " yp w60 h23 Number Limit2 vviConversationMaxHistoryEdit")
		editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range1-10")
		editorGui.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200", translate("Conversations"))

		editorGui.Add("Button", "x" . (width - 100) . " yp w100 h23 X:Move vviConversationInstructionsButton", translate("Instructions...")).OnEvent("Click", editInstructions.Bind("Conversation", translate("Conversation")))

		editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200", translate("Creativity"))
		editorGui.Add("Edit", "x" . x1 . " yp w60 Number Limit3 vviConversationTemperatureEdit").OnEvent("Change", validatePercentage.Bind("viConversationTemperatureEdit"))
		editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-100")
		editorGui.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200", translate("%"))

		editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200", translate("Actions"))
		editorGui.Add("DropDownList", "x" . x1 . " yp w60 vviConversationActionsDropdown", collect(["Yes", "No"], translate)).OnEvent("Change", (*) => this.updateState())
		editorGui.Add("Button", "x" . (x1 + 61) . " yp-1 w23 h23 X:Move Center +0x200 vviConversationEditActionsButton").OnEvent("Click", editActions.Bind("Conversation"))
		setButtonIcon(editorGui["viConversationEditActionsButton"], kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")

		editorGui.SetFont("Italic Bold", "Arial")
		editorGui.Add("Text", "x" . (x + 8) . " yp+30 w100 h23", translate("Reasoning"))
		editorGui.Add("Text", "x120 yp+7 w" . (width + 8 - 120) . " 0x10 W:Grow")
		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x" . x0 . " yp+20 w110 h23 +0x200 vviAgentProviderLabel", translate("Provider / URL"))

		editorGui.Add("DropDownList", "x" . x1 . " yp w100 Choose1 vviAgentProviderDropDown", concatenate([translate("Disabled"), translate("Rules")], this.Providers)).OnEvent("Change", chooseAgentProvider)

		editorGui.Add("Edit", "x" . (x1 + 102) . " yp w" . (w1 - 102) . " h23 vviAgentServiceURLEdit").OnEvent("Change", loadModels.Bind("Agent"))

		editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200 Section vviAgentServiceKeyLabel", translate("Service Key"))
		editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h23 Password vviAgentServiceKeyEdit").OnEvent("Change", loadModels.Bind("Agent"))

		editorGui.Add("Text", "x" . x0 . " yp+30 w110 h23 +0x200 vviAgentModelLabel", translate("Model"))
		editorGui.Add("ComboBox", "x" . x1 . " yp w" . w1 . " vviAgentModelDropDown")

		editorGui.Add("Text", "x" . x0 . " ys+5 w110 h23 +0x200 vviAgentLLMRTModelLabel Hidden", translate("Model"))
		editorGui.Add("Edit", "x" . x1 . " yp w" . (w1 - 24) . " vviAgentLLMRTModelEdit Hidden")
		editorGui.Add("Button", "x" . (x1 + (w1 - 23)) . " yp h23 w23 vviAgentLLMRTModelButton Hidden", translate("...")).OnEvent("Click", chooseModelPath.Bind("viAgentLLMRTModelEdit"))

		editorGui.Add("Text", "x" . x0 . " yp+24 w120 h23 +0x200 vviAgentLLMRTGPULayersLabel Hidden", translate("# GPULayers"))
		editorGui.Add("Edit", "x" . x1 . " yp-1 w60 h23 Number Limit2 vviAgentLLMRTGPULayersEdit Hidden")
		editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-99 vviAgentLLMRTGPULayersRange Hidden")

		editorGui.Add("Button", "x" . (x + 8) . " yp+30 w100 h23 vviAgentEventsButton", translate("Events...")).OnEvent("Click", editEvents)

		editorGui.Add("Button", "x" . (x + 8) + Round((width / 2) - 50) . " yp w100 h23 vviAgentActionsButton X:Move(0.5)", translate("Actions...")).OnEvent("Click", editActions.Bind("Agent"))

		editorGui.Add("Button", "x" . (width - 100) . " yp w100 h23 X:Move vviAgentInstructionsButton", translate("Instructions...")).OnEvent("Click", editInstructions.Bind("Agent", translate("Reasoning")))

		editorGui.Add("Text", "x8 yp+35 w468 W:Grow 0x10")

		editorGui.Add("Button", "x160 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", (*) => this.iResult := kOk)
		editorGui.Add("Button", "x246 yp w80 h23", translate("&Cancel")).OnEvent("Click", (*) => this.iResult := kCancel)
	}

	loadModels(type, provider, serviceURL := false, serviceKey := false, model := false) {
		local connector, index, models

		if !model
			model := ""

		if (provider = "LLM Runtime")
			this.Control["vi" . type . "LLMRTModelEdit"].Text := model
		else {
			if provider {
				try {
					connector := LLMConnector.%StrReplace(provider, A_Space, "")%Connector(this, model)

					if isInstance(connector, LLMConnector.APIConnector) {
						connector.Connect(serviceURL, serviceKey)

						models := connector.Models
					}
					else
						models := this.Models[provider]
				}
				catch Any as exception {
					models := this.Models[provider]
				}
			}
			else
				models := []

			if model {
				index := inList(models, model)

				if !index {
					index := inList(models, StrReplace(model, A_Space, "-"))

					if index
						model := models[index]
				}

				if !index
					models := concatenate(models, [model])
			}

			this.Control["vi" . type . "ModelDropDown"].Delete()
			this.Control["vi" . type . "ModelDropDown"].Add(models)

			if model
				this.Control["vi" . type . "ModelDropDown"].Choose(inList(models, model))
			else
				this.Control["vi" . type . "ModelDropDown"].Choose((models.Length > 0) ? 1 : 0)
		}

		this.updateState()
	}

	normalizeConfiguration(configuration) {
		local ignore, type, section, values, key, value

		for ignore, type in ["Speaker", "Listener", "Conversation"]
			for section, values in this.getInstructions(type, true)
				for key, value in values
					if (getMultiMapValue(configuration, section, key) = value)
						removeMultiMapValue(configuration, section, key)
	}

	loadFromConfiguration(configuration) {
		local service, ignore, provider, setting, providerConfiguration
		local serviceURL, serviceKey, model

		static defaults := CaseInsenseWeakMap("ConversationServiceURL", false, "ConversationModel", ""
											, "ConversationMaxTokens", 2048
											, "Speaker", true, "SpeakerTemperature", 0.5, "SpeakerProbability", 0.5
											, "Listener", false, "ListenerMode", "Unknown", "ListenerTemperature", 0.5
											, "Conversation", false, "ConversationMaxHistory", 3
											, "ConversationTemperature", 0.5, "ConversationGPULayers", 0
											, "ConversationActions", false
											, "AgentServiceURL", false, "AgentModel", "", "AgentMaxTokens", 2048
											, "AgentGPULayers", 0)

		super.loadFromConfiguration(configuration)

		service := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Service", false)

		this.iCurrentConversationProvider := (service ? string2Values("|", service)[1] : false)

		for ignore, provider in this.Providers {
			providerConfiguration := CaseInsenseMap()

			if (provider = this.iCurrentConversationProvider) {
				providerConfiguration["Model"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Model", defaults["Model"])
				providerConfiguration["MaxTokens"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".MaxTokens", defaults["MaxTokens"])

				providerConfiguration["Speaker"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Speaker", defaults["Speaker"])
				providerConfiguration["SpeakerProbability"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".SpeakerProbability", defaults["SpeakerProbability"])
				providerConfiguration["SpeakerTemperature"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".SpeakerTemperature", defaults["SpeakerTemperature"])

				providerConfiguration["Listener"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Listener", defaults["Listener"])
				providerConfiguration["ListenerMode"] := ["Always", "Unknown"][2 - (getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".ListenerMode", defaults["ListenerMode"]) = "Always")]
				providerConfiguration["ListenerTemperature"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".ListenerTemperature", defaults["ListenerTemperature"])

				providerConfiguration["Conversation"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Conversation", defaults["Conversation"])
				providerConfiguration["ConversationMaxHistory"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".ConversationMaxHistory", defaults["ConversationMaxHistory"])
				providerConfiguration["ConversationTemperature"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".ConversationTemperature", defaults["ConversationTemperature"])
				providerConfiguration["ConversationActions"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".ConversationActions", defaults["ConversationActions"])

				if (provider = "LLM Runtime") {
					providerConfiguration["ServiceURL"] := ""
					providerConfiguration["ServiceKey"] := ""
					providerConfiguration["GPULayers"] := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".GPULayers", defaults["ConversationGPULayers"])

				}
				else {
					providerConfiguration["ServiceURL"] := string2Values("|", service)[2]
					providerConfiguration["ServiceKey"] := string2Values("|", service)[3]
				}
			}
			else {
				for ignore, setting in ["ServiceURL", "ServiceKey", "Model", "MaxTokens"]
					providerConfiguration[setting] := getMultiMapValue(configuration, "Conversation Booster", provider . "." . setting, defaults[setting])

				if (provider = "LLM Runtime")
					providerConfiguration["GPULayers"] := getMultiMapValue(configuration, "Conversation Booster", provider . ".GPULayers", defaults["ConversationGPULayers"])

				try {
					LLMConnector.%StrReplace(provider, A_Space, "")%Connector.GetDefaults(&serviceURL, &serviceKey, &model)
				}
				catch Any {
					serviceURL := ""
					serviceKey := ""
					model := ""
				}

				if !providerConfiguration["ServiceURL"]
					providerConfiguration["ServiceURL"] := serviceURL

				if !providerConfiguration["ServiceKey"]
					providerConfiguration["ServiceKey"] := serviceKey

				if (providerConfiguration["Model"] = "")
					providerConfiguration["Model"] := model

				for ignore, setting in ["Speaker", "SpeakerProbability", "SpeakerTemperature"
									  , "Listener", "ListenerMode", "ListenerTemperature"
									  , "Conversation", "ConversationMaxHistory", "ConversationTemperature", "ConversationActions"]
					providerConfiguration[setting] := getMultiMapValue(configuration, "Conversation Booster", provider . "." . setting, defaults[setting])
			}

			this.iProviderConfigurations["Conversation." . provider] := providerConfiguration
		}

		service := getMultiMapValue(configuration, "Agent Booster", this.Assistant . ".Service", false)

		this.iCurrentAgentProvider := (service ? string2Values("|", service)[1] : false)

		for ignore, provider in concatenate(["Rules"], this.Providers) {
			providerConfiguration := CaseInsenseMap()

			if (provider = this.iCurrentAgentProvider) {
				providerConfiguration["Model"] := getMultiMapValue(configuration, "Agent Booster", this.Assistant . ".Model", defaults["Model"])

				if (provider = "LLM Runtime") {
					providerConfiguration["ServiceURL"] := ""
					providerConfiguration["ServiceKey"] := ""
					providerConfiguration["GPULayers"] := getMultiMapValue(configuration, "Agent Booster", this.Assistant . ".GPULayers", defaults["AgentGPULayers"])
				}
				else {
					providerConfiguration["ServiceURL"] := string2Values("|", service)[2]
					providerConfiguration["ServiceKey"] := string2Values("|", service)[3]
				}
			}
			else {
				for ignore, setting in ["ServiceURL", "ServiceKey", "Model"]
					providerConfiguration[setting] := getMultiMapValue(configuration, "Agent Booster", provider . "." . setting, getMultiMapValue(configuration, "Conversation Booster", provider . "." . setting, defaults[setting]))

				if (provider = "LLM Runtime")
					providerConfiguration["GPULayers"] := getMultiMapValue(configuration, "Agent Booster", provider . ".GPULayers", defaults["AgentGPULayers"])

				try {
					LLMConnector.%StrReplace(provider, A_Space, "")%Connector.GetDefaults(&serviceURL, &serviceKey, &model)
				}
				catch Any {
					serviceURL := ""
					serviceKey := ""
					model := ""
				}

				if !providerConfiguration["ServiceURL"]
					providerConfiguration["ServiceURL"] := serviceURL

				if !providerConfiguration["ServiceKey"]
					providerConfiguration["ServiceKey"] := serviceKey

				if (providerConfiguration["Model"] = "")
					providerConfiguration["Model"] := model
			}

			this.iProviderConfigurations["Agent." . provider] := providerConfiguration
		}
	}

	saveToConfiguration(configuration) {
		local ignore, provider, reference, setting, value

		super.saveToConfiguration(configuration)

		this.saveProviderConfiguration()

		addMultiMapValues(configuration, this.iInstructions)

		this.normalizeConfiguration(configuration)

		for ignore, provider in this.Providers {
			providerConfiguration := this.iProviderConfigurations["Conversation." . provider]

			for ignore, setting in ["ServiceURL", "ServiceKey", "Model", "MaxTokens"]
				setMultiMapValue(configuration, "Conversation Booster", provider . "." . setting, providerConfiguration[setting])

			if (provider = "LLM Runtime")
				setMultiMapValue(configuration, "Conversation Booster", provider . ".GPULayers", providerConfiguration["GPULayers"])

			for ignore, setting in ["Speaker", "SpeakerProbability", "SpeakerTemperature"
								  , "Listener", "ListenerMode", "ListenerTemperature"
								  , "Conversation", "ConversationMaxHistory", "ConversationTemperature", "ConversationActions"] {
				setMultiMapValue(configuration, "Conversation Booster", provider . "." . setting, providerConfiguration[setting])

				if (provider = this.iCurrentConversationProvider)
					setMultiMapValue(configuration, "Conversation Booster", this.Assistant . "." . setting, providerConfiguration[setting])
			}

			if (provider = this.iCurrentAgentProvider)
				setMultiMapValue(configuration, "Agent Booster", this.Assistant . ".Agent"
											  , this.Control["viAgentProviderDropDown"].Value > 1)

			providerConfiguration := this.iProviderConfigurations["Agent." . provider]

			for ignore, setting in ["ServiceURL", "ServiceKey", "Model"]
				setMultiMapValue(configuration, "Agent Booster", provider . "." . setting, providerConfiguration[setting])
			if (provider = "LLM Runtime")
				setMultiMapValue(configuration, "Agent Booster", provider . ".GPULayers", providerConfiguration["GPULayers"])
		}

		provider := this.iCurrentConversationProvider

		if provider {
			providerConfiguration := this.iProviderConfigurations["Conversation." . provider]

			setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Model", providerConfiguration["Model"])
			setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".MaxTokens", providerConfiguration["MaxTokens"])

			if (provider = "LLM Runtime") {
				setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Service", provider)
				setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".GPULayers", providerConfiguration["GPULayers"])
			}
			else
				setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Service"
											  , values2String("|", provider, Trim(providerConfiguration["ServiceURL"])
																		   , Trim(providerConfiguration["ServiceKey"])))
		}
		else {
			setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Model", false)
			setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Service", false)
		}

		provider := this.iCurrentAgentProvider

		if provider {
			if (provider = "Rules")
				setMultiMapValue(configuration, "Agent Booster", this.Assistant . ".Agent", true)

			providerConfiguration := this.iProviderConfigurations["Agent." . provider]

			setMultiMapValue(configuration, "Agent Booster", this.Assistant . ".Model", providerConfiguration["Model"])

			if (provider = "LLM Runtime") {
				setMultiMapValue(configuration, "Agent Booster", this.Assistant . ".Service", provider)
				setMultiMapValue(configuration, "Agent Booster", this.Assistant . ".GPULayers", providerConfiguration["GPULayers"])
			}
			else
				setMultiMapValue(configuration, "Agent Booster", this.Assistant . ".Service"
											  , values2String("|", provider, Trim(providerConfiguration["ServiceURL"])
																		   , Trim(providerConfiguration["ServiceKey"])))
		}
		else {
			setMultiMapValue(configuration, "Agent Booster", this.Assistant . ".Model", false)
			setMultiMapValue(configuration, "Agent Booster", this.Assistant . ".Service", false)
		}
	}

	loadProviderConfiguration(type, provider) {
		local configuration, index

		if (type = "Conversation") {
			this.Control["viConversationProviderDropDown"].Choose(inList(this.Providers, provider) + 1)

			if (this.Control["viConversationProviderDropDown"].Value = 1) {
				this.iCurrentConversationProvider := false

				for ignore, setting in ["ServiceURL", "ServiceKey", "MaxTokens", "LLMRTMaxTokens", "LLMRTGPULayers"]
					this.Control["viConversation" . setting . "Edit"].Text := ""

				for ignore, setting in ["SpeakerProbability", "SpeakerTemperature", "ListenerTemperature", "ConversationMaxHistory", "ConversationTemperature"]
					this.Control["vi" . setting . "Edit"].Text := ""

				for ignore, setting in ["Speaker", "Listener", "Conversation"]
					this.Control["vi" . setting . "Check"].Value := 0

				this.Control["viConversationActionsDropDown"].Choose(0)
				this.Control["viListenerModeDropDown"].Choose(0)
			}
			else {
				this.iCurrentConversationProvider := this.Control["viConversationProviderDropDown"].Text

				if this.iProviderConfigurations.Has("Conversation." . this.iCurrentConversationProvider)
					configuration := this.iProviderConfigurations["Conversation." . this.iCurrentConversationProvider]

				for ignore, setting in ["ServiceURL", "ServiceKey"]
					this.Control["viConversation" . setting . "Edit"].Text := configuration[setting]

				if (provider = "LLM Runtime") {
					this.Control["viConversationLLMRTMaxTokensEdit"].Text := configuration["MaxTokens"]
					this.Control["viConversationLLMRTGPULayersEdit"].Text := configuration["GPULayers"]
				}
				else
					this.Control["viConversationMaxTokensEdit"].Text := configuration["MaxTokens"]

				if ((provider = "GPT4All") && (Trim(this.Control["viConversationServiceKeyEdit"].Text) = ""))
					this.Control["viConversationServiceKeyEdit"].Text := "Any text will do the job"

				if ((provider = "Ollama") && (Trim(this.Control["viConversationServiceKeyEdit"].Text) = ""))
					this.Control["viConversationServiceKeyEdit"].Text := "Ollama"

				for ignore, setting in ["Speaker", "Listener", "Conversation"]
					this.Control["vi" . setting . "Check"].Value := configuration[setting]

				this.Control["viSpeakerProbabilityEdit"].Text := (isNumber(configuration["SpeakerProbability"]) ? Round(configuration["SpeakerProbability"] * 100) : "")
				this.Control["viSpeakerTemperatureEdit"].Text := (isNumber(configuration["SpeakerTemperature"]) ? Round(configuration["SpeakerTemperature"] * 100) : "")

				this.Control["viListenerModeDropDown"].Choose(2 - (configuration["ListenerMode"] = "Always"))
				this.Control["viListenerTemperatureEdit"].Text := (isNumber(configuration["ListenerTemperature"]) ? Round(configuration["ListenerTemperature"] * 100) : "")

				this.Control["viConversationMaxHistoryEdit"].Text := configuration["ConversationMaxHistory"]
				this.Control["viConversationTemperatureEdit"].Text := (isNumber(configuration["ConversationTemperature"]) ? Round(configuration["ConversationTemperature"] * 100) : "")
				this.Control["viConversationActionsDropDown"].Choose(1 + (configuration["ConversationActions"] = false))
			}

			if this.iCurrentConversationProvider
				this.loadModels("Conversation", this.iCurrentConversationProvider, configuration["ServiceURL"]
																				 , configuration["ServiceKey"]
																				 , configuration["Model"])
			else
				this.loadModels("Conversation", false)
		}
		else {
			if (provider = translate("Rules") || (provider = "Rules"))
				this.Control["viAgentProviderDropDown"].Choose(2)
			else {
				index := inList(this.Providers, provider)

				this.Control["viAgentProviderDropDown"].Choose(index ? (index + 2) : 1)
			}

			if (this.Control["viAgentProviderDropDown"].Value = 1) {
				this.iCurrentAgentProvider := false

				for ignore, setting in ["ServiceURL", "ServiceKey", "LLMRTGPULayers"]
					this.Control["viAgent" . setting . "Edit"].Text := ""
			}
			else if (this.Control["viAgentProviderDropDown"].Value = 2) {
				this.iCurrentAgentProvider := "Rules"

				for ignore, setting in ["ServiceURL", "ServiceKey", "LLMRTGPULayers"]
					this.Control["viAgent" . setting . "Edit"].Text := ""
			}
			else {
				this.iCurrentAgentProvider := this.Control["viAgentProviderDropDown"].Text

				if this.iProviderConfigurations.Has("Agent." . this.iCurrentAgentProvider)
					configuration := this.iProviderConfigurations["Agent." . this.iCurrentAgentProvider]

				for ignore, setting in ["ServiceURL", "ServiceKey"]
					this.Control["viAgent" . setting . "Edit"].Text := configuration[setting]

				if (provider = "LLM Runtime")
					this.Control["viAgentLLMRTGPULayersEdit"].Text := configuration["GPULayers"]

				if ((provider = "GPT4All") && (Trim(this.Control["viAgentServiceKeyEdit"].Text) = ""))
					this.Control["viAgentServiceKeyEdit"].Text := "Any text will do the job"

				if ((provider = "Ollama") && (Trim(this.Control["viAgentServiceKeyEdit"].Text) = ""))
					this.Control["viAgentServiceKeyEdit"].Text := "Ollama"
			}

			if (this.iCurrentAgentProvider && (this.iCurrentAgentProvider != "Rules"))
				this.loadModels("Agent", this.iCurrentAgentProvider, configuration["ServiceURL"]
																   , configuration["ServiceKey"]
																   , configuration["Model"])
			else
				this.loadModels("Agent", false)
		}

		this.updateState()
	}

	saveProviderConfiguration() {
		local providerConfiguration, value, ignore, setting

		if this.iCurrentConversationProvider {
			providerConfiguration := this.iProviderConfigurations["Conversation." . this.iCurrentConversationProvider]

			providerConfiguration["ServiceURL"] := Trim(this.Control["viConversationServiceURLEdit"].Text)
			providerConfiguration["ServiceKey"] := Trim(this.Control["viConversationServiceKeyEdit"].Text)

			if (this.iCurrentConversationProvider = "LLM Runtime")
				value := this.Control["viConversationLLMRTModelEdit"].Text
			else
				value := this.Control["viConversationModelDropDown"].Text

			providerConfiguration["Model"] := ((Trim(value) != "") ? Trim(value) : false)

			if (this.iCurrentConversationProvider = "LLM Runtime")
				providerConfiguration["MaxTokens"] := this.Control["viConversationLLMRTMaxTokensEdit"].Text
			else
				providerConfiguration["MaxTokens"] := this.Control["viConversationMaxTokensEdit"].Text

			if (this.Control["viConversationProviderDropDown"].Text = "LLM Runtime")
				providerConfiguration["GPULayers"] := this.Control["viConversationLLMRTGPULayersEdit"].Text

			if (this.Control["viSpeakerCheck"].Value = 1) {
				providerConfiguration["Speaker"] := true
				providerConfiguration["SpeakerProbability"] := Round(this.Control["viSpeakerProbabilityEdit"].Text / 100, 2)
				providerConfiguration["SpeakerTemperature"] := Round(this.Control["viSpeakerTemperatureEdit"].Text / 100, 2)
			}
			else {
				providerConfiguration["Speaker"] := false
				providerConfiguration["SpeakerProbability"] := ""
				providerConfiguration["SpeakerTemperature"] := ""
			}

			if (this.Control["viListenerCheck"].Value = 1) {
				providerConfiguration["Listener"] := true
				providerConfiguration["ListenerMode"] := ["Always", "Unknown"][this.Control["viListenerModeDropDown"].Value]
				providerConfiguration["ListenerTemperature"] := Round(this.Control["viListenerTemperatureEdit"].Text / 100, 2)
			}
			else {
				providerConfiguration["Listener"] := false
				providerConfiguration["ListenerMode"] := ""
				providerConfiguration["ListenerTemperature"] := ""
			}

			if (this.Control["viConversationCheck"].Value = 1) {
				providerConfiguration["Conversation"] := true
				providerConfiguration["ConversationMaxHistory"] := this.Control["viConversationMaxHistoryEdit"].Text
				providerConfiguration["ConversationTemperature"] := Round(this.Control["viConversationTemperatureEdit"].Text / 100, 2)
				providerConfiguration["ConversationActions"] := (this.Control["viConversationActionsDropDown"].Value = 1)
			}
			else {
				providerConfiguration["Conversation"] := false
				providerConfiguration["ConversationMaxHistory"] := ""
				providerConfiguration["ConversationTemperature"] := ""
				providerConfiguration["ConversationActions"] := false
			}
		}

		if this.iCurrentAgentProvider {
			providerConfiguration := this.iProviderConfigurations["Agent." . this.iCurrentAgentProvider]

			providerConfiguration["ServiceURL"] := Trim(this.Control["viAgentServiceURLEdit"].Text)
			providerConfiguration["ServiceKey"] := Trim(this.Control["viAgentServiceKeyEdit"].Text)

			if (this.iCurrentAgentProvider = "LLM Runtime")
				value := this.Control["viAgentLLMRTModelEdit"].Text
			else
				value := this.Control["viAgentModelDropDown"].Text

			providerConfiguration["Model"] := ((Trim(value) != "") ? Trim(value) : false)

			if (this.iCurrentAgentProvider = "LLM Runtime")
				providerConfiguration["GPULayers"] := this.Control["viAgentLLMRTGPULayersEdit"].Text

			providerConfiguration["Agent"] := true
		}
	}

	loadConfigurator(configuration, simulators := false) {
		this.loadFromConfiguration(configuration)

		this.loadProviderConfiguration("Conversation", this.iCurrentConversationProvider)
		this.loadProviderConfiguration("Agent", this.iCurrentAgentProvider)

		this.updateState()
	}

	editBooster(owner := false) {
		local window, x, y, w, h, configuration

		this.createGui(this.Configuration)

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		if getWindowPosition("Booster Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		this.loadConfigurator(this.Configuration)

		loop
			Sleep(200)
		until this.iResult

		try {
			if (this.iResult = kOk) {
				configuration := newMultiMap()

				this.saveToConfiguration(configuration)

				return configuration
			}
			else
				return false
		}
		finally {
			window.Destroy()
		}
	}

	updateState() {
		local ignore, setting, llmRuntime

		if (this.Control["viAgentProviderDropDown"].Value = 2) {
			this.Control["viAgentEventsButton"].Enabled := true
			this.Control["viAgentActionsButton"].Enabled := true
			this.Control["viAgentInstructionsButton"].Enabled := false

			this.Control["viAgentServiceURLEdit"].Enabled := false
			this.Control["viAgentServiceURLEdit"].Text := ""
			this.Control["viAgentModelDropDown"].Enabled := false
			this.Control["viAgentModelDropDown"].Choose(0)
			this.Control["viAgentServiceKeyEdit"].Enabled := false
			this.Control["viAgentServiceKeyEdit"].Text := ""
		}
		else if ((this.Control["viAgentProviderDropDown"].Value < 2) || !inList(this.iBoosters, "Agent")) {
			this.Control["viAgentEventsButton"].Enabled := false
			this.Control["viAgentActionsButton"].Enabled := false
			this.Control["viAgentInstructionsButton"].Enabled := false
		}
		else {
			this.Control["viAgentEventsButton"].Enabled := true
			this.Control["viAgentActionsButton"].Enabled := true
			this.Control["viAgentInstructionsButton"].Enabled := true
		}

		if inList(this.iBoosters, "Agent")
			this.Control["viAgentProviderDropDown"].Enabled := true
		else {
			this.Control["viAgentProviderDropDown"].Enabled := false
			this.Control["viAgentProviderDropDown"].Value := 0
		}

		if this.iCurrentConversationProvider {
			this.Control["viConversationServiceURLEdit"].Enabled := (this.Control["viConversationProviderDropDown"].Text != "LLM Runtime")
			this.Control["viConversationServiceKeyEdit"].Enabled := !inList(["GPT4All", "Ollama", "LLM Runtime"], this.Control["viConversationProviderDropDown"].Text)

			this.Control["viConversationModelDropDown"].Enabled := true
			this.Control["viConversationMaxTokensEdit"].Enabled := true

			if inList(this.iBoosters, "Speaker")
				this.Control["viSpeakerCheck"].Enabled := true
			else {
				this.Control["viSpeakerCheck"].Enabled := false
				this.Control["viSpeakerCheck"].Value := 0
			}

			if inList(this.iBoosters, "Listener")
				this.Control["viListenerCheck"].Enabled := true
			else {
				this.Control["viListenerCheck"].Enabled := false
				this.Control["viListenerCheck"].Value := 0
			}

			if inList(this.iBoosters, "Conversation")
				this.Control["viConversationCheck"].Enabled := true
			else {
				this.Control["viConversationCheck"].Enabled := false
				this.Control["viConversationCheck"].Value := 0
			}
		}
		else {
			for ignore, setting in ["ServiceURL", "ServiceKey"]
				this.Control["viConversation" . setting . "Edit"].Enabled := false

			this.Control["viSpeakerCheck"].Enabled := false
			this.Control["viListenerCheck"].Enabled := false
			this.Control["viConversationCheck"].Enabled := false
			this.Control["viSpeakerCheck"].Value := 0
			this.Control["viListenerCheck"].Value := 0
			this.Control["viConversationCheck"].Value := 0

			this.Control["viConversationModelDropDown"].Enabled := false
			this.Control["viConversationMaxTokensEdit"].Enabled := false
		}

		if (this.iCurrentAgentProvider && (this.iCurrentAgentProvider != "Rules") && inList(this.iBoosters, "Agent")) {
			this.Control["viAgentServiceURLEdit"].Enabled := (this.Control["viAgentProviderDropDown"].Text != "LLM Runtime")
			this.Control["viAgentServiceKeyEdit"].Enabled := !inList(["GPT4All", "Ollama", "LLM Runtime"], this.Control["viAgentProviderDropDown"].Text)

			this.Control["viAgentModelDropDown"].Enabled := true
		}
		else {
			this.Control["viAgentServiceURLEdit"].Enabled := false
			this.Control["viAgentModelDropDown"].Enabled := false
			this.Control["viAgentServiceKeyEdit"].Enabled := false
		}

		if ((this.Control["viSpeakerCheck"].Value = 0) || !inList(this.iBoosters, "Speaker")) {
			this.Control["viSpeakerProbabilityEdit"].Enabled := false
			this.Control["viSpeakerTemperatureEdit"].Enabled := false
			this.Control["viSpeakerProbabilityEdit"].Text := ""
			this.Control["viSpeakerTemperatureEdit"].Text := ""
			this.Control["viSpeakerInstructionsButton"].Enabled := false
		}
		else {
			this.Control["viSpeakerProbabilityEdit"].Enabled := true
			this.Control["viSpeakerTemperatureEdit"].Enabled := true

			if (this.Control["viSpeakerProbabilityEdit"].Text = "")
				this.Control["viSpeakerProbabilityEdit"].Text := 50

			if (this.Control["viSpeakerTemperatureEdit"].Text = "")
				this.Control["viSpeakerTemperatureEdit"].Text := 50

			this.Control["viSpeakerInstructionsButton"].Enabled := true
		}

		if ((this.Control["viListenerCheck"].Value = 0) || !inList(this.iBoosters, "Listener")) {
			this.Control["viListenerModeDropDown"].Enabled := false
			this.Control["viListenerTemperatureEdit"].Enabled := false
			this.Control["viListenerModeDropDown"].Choose(0)
			this.Control["viListenerTemperatureEdit"].Text := ""
			this.Control["viListenerInstructionsButton"].Enabled := false
		}
		else {
			this.Control["viListenerModeDropDown"].Enabled := true
			this.Control["viListenerTemperatureEdit"].Enabled := true

			if (this.Control["viListenerModeDropDown"].Value = 0)
				this.Control["viListenerModeDropDown"].Choose(2)

			if (this.Control["viListenerTemperatureEdit"].Text = "")
				this.Control["viListenerTemperatureEdit"].Text := 50

			this.Control["viListenerInstructionsButton"].Enabled := true
		}

		if ((this.Control["viConversationCheck"].Value = 0) || !inList(this.iBoosters, "Conversation")) {
			this.Control["viConversationMaxHistoryEdit"].Enabled := false
			this.Control["viConversationTemperatureEdit"].Enabled := false
			this.Control["viConversationActionsDropDown"].Enabled := false
			this.Control["viConversationEditActionsButton"].Enabled := false
			this.Control["viConversationMaxHistoryEdit"].Text := ""
			this.Control["viConversationTemperatureEdit"].Text := ""
			this.Control["viConversationActionsDropDown"].Choose(0)
			this.Control["viConversationInstructionsButton"].Enabled := false
		}
		else {
			this.Control["viConversationMaxHistoryEdit"].Enabled := true
			this.Control["viConversationTemperatureEdit"].Enabled := true
			this.Control["viConversationActionsDropDown"].Enabled := true

			if (this.Control["viConversationMaxHistoryEdit"].Text = "")
				this.Control["viConversationMaxHistoryEdit"].Text := 3

			if (this.Control["viConversationTemperatureEdit"].Text = "")
				this.Control["viConversationTemperatureEdit"].Text := 50

			if (this.Control["viConversationActionsDropDown"].Value = 0)
				this.Control["viConversationActionsDropDown"].Choose(2)

			this.Control["viConversationInstructionsButton"].Enabled := true
			this.Control["viConversationEditActionsButton"].Enabled := (this.Control["viConversationActionsDropDown"].Value = 1)
		}

		llmRuntime := (this.iCurrentConversationProvider = "LLM Runtime")

		for ignore, field in ["viConversationServiceKeyLabel", "viConversationServiceKeyEdit"
							, "viConversationModelLabel", "viConversationModelDropDown"
							, "viConversationServiceURLEdit"
							, "viConversationMaxTokensEdit", "viConversationMaxTokensRange"]
			this.Control[field].Visible := !llmRuntime

		this.Control["viConversationProviderLabel"].Text := (llmRuntime ? translate("Provider") : translate("Provider / URL"))

		for ignore, field in ["viConversationLLMRTModelLabel", "viConversationLLMRTModelEdit"
							, "viConversationLLMRTModelButton"
							, "viConversationLLMRTTokensLabel"
							, "viConversationLLMRTMaxTokensEdit", "viConversationLLMRTMaxTokensRange"
							, "viConversationLLMRTGPULayersEdit", "viConversationLLMRTGPULayersRange"]
			this.Control[field].Visible := llmRuntime

		llmRuntime := (this.iCurrentAgentProvider = "LLM Runtime")

		for ignore, field in ["viAgentServiceKeyLabel", "viAgentServiceKeyEdit"
							, "viAgentModelLabel", "viAgentModelDropDown"
							, "viAgentServiceURLEdit"]
			this.Control[field].Visible := !llmRuntime

		this.Control["viAgentProviderLabel"].Text := (llmRuntime ? translate("Provider") : translate("Provider / URL"))

		for ignore, field in ["viAgentLLMRTModelLabel", "viAgentLLMRTModelEdit", "viAgentLLMRTModelButton"
							, "viAgentLLMRTGPULayersLabel", "viAgentLLMRTGPULayersEdit", "viAgentLLMRTGPULayersRange"]
			this.Control[field].Visible := llmRuntime
	}

	getOriginalInstruction(language, type, key) {
		if (type = "Agent")
			return getMultiMapValue(this.getInstructions(type, true), "Agent Booster", "Instructions." . type . "." . key . "." . language, "")
		else
			return getMultiMapValue(this.getInstructions(type, true), "Conversation Booster", "Instructions." . type . "." . key . "." . language, "")
	}

	getInstructions(type, original := false) {
		local instructions := newMultiMap()
		local reference := ((type = "Agent") ? "Agent Booster" : "Conversation Booster")
		local key, value, ignore, directory, configuration, language

		for ignore, directory in [kTranslationsDirectory, kUserTranslationsDirectory]
			loop Files (directory . reference . ".instructions.*") {
				SplitPath A_LoopFilePath, , , &language

				for key, value in getMultiMapValues(readMultiMap(A_LoopFilePath), type . ".Instructions")
					setMultiMapValue(instructions, reference, "Instructions." . type . "." . key . "." . language, value)
			}

		if !original
			for ignore, configuration in [this.Configuration, this.iInstructions]
				for key, value in getMultiMapValues(configuration, reference)
					if (InStr(key, "Instructions." . type) = 1)
						setMultiMapValue(instructions, reference, key, value)

		return instructions
	}

	setInstructions(type, instructions) {
		addMultiMapValues(this.iInstructions, instructions)
	}

	editInstructions(type, title) {
		local window := this.Window
		local instructions

		window.Block()

		try {
			instructions := editInstructions(this, type, title, this.getInstructions(type), window)

			if instructions
				this.setInstructions(type, instructions)
		}
		finally {
			window.Unblock()
		}
	}

	editEvents(assistant) {
		local window := this.Window

		window.Block()

		try {
			return EventsEditor(this, (this.iCurrentAgentProvider = "Rules") ? "Agent.Rules.Events" : "Agent.LLM.Events"
									, (this.iCurrentAgentProvider != "Rules") ? ["Builtin", "Custom"]
																			  : ["Custom"]).editEvents(window)
		}
		finally {
			window.Unblock()
		}
	}

	editActions(assistant, type) {
		local window := this.Window

		window.Block()

		try {
			if (type = "Agent")
				return ActionsEditor(this, (this.iCurrentAgentProvider = "Rules") ? "Agent.Rules.Actions" : "Agent.LLM.Actions"
										 , (this.iCurrentAgentProvider != "Rules") ? ["Builtin", "Custom"]
																				   : ["Custom"]).editActions(window)
			else
				return ActionsEditor(this, "Conversation.Actions", ["Builtin", "Custom"]).editActions(window)
		}
		finally {
			window.Unblock()
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; CallbacksEditor                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class CallbacksEditor {
	iEditor := false
	iType := false
	iCategories := ["Builtin", "Custom"]

	iWindow := false
	iResult := false

	iCallbacksListView := false
	iParametersListView := false
	iCallableField := false
	iPhraseField := false
	iScriptEditor := false

	iCallbacks := []
	iSelectedCallback := false
	iSelectedParameter := false

	iDeletedCallbacks := CaseInsenseMap()

	class CallbacksEditorWindow extends Window {
		iCallbacksEditor := false

		CallbacksEditor {
			Get {
				return this.iCallbacksEditor
			}
		}

		__New(editor) {
			this.iCallbacksEditor := editor

			super.__New({Descriptor: (editor.Type . " Editor"), Closeable: true, Resizeable: true, Options: "0x400000"})
		}

		Close(*) {
			local translator

			if this.Closeable {
				translator := translateMsgBoxButtons.Bind(["Yes", "No", "Cancel"])

				OnMessage(0x44, translator)
				msgResult := withBlockedWindows(MsgBox, translate("Do you want to save your changes?"), translate("Close"), 262179)
				OnMessage(0x44, translator, 0)

				if (msgResult = "Yes")
					this.CallbacksEditor.iResult := kOk
				else if (msgResult = "No")
					this.CallbacksEditor.iResult := kCancel
				else if (msgResult = "Cancel")
					return true
			}
			else
				return true
		}
	}

	Editor {
		Get {
			return this.iEditor
		}
	}

	Type {
		Get {
			return this.iType
		}
	}

	Categories {
		Get {
			return this.iCategories
		}
	}

	Assistant {
		Get {
			return this.Editor.Assistant
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	Control[name] {
		Get {
			return this.Window[name]
		}
	}

	CallbacksListView {
		Get {
			return this.iCallbacksListView
		}
	}

	ParametersListView {
		Get {
			return this.iParametersListView
		}
	}

	PhraseField {
		Get {
			return this.iPhraseField
		}
	}

	CallableField {
		Get {
			return this.iCallableField
		}
	}

	ScriptEditor {
		Get {
			return this.iScriptEditor
		}
	}

	Callbacks[key?] {
		Get {
			return (isSet(key) ? this.iCallbacks[key] : this.iCallbacks)
		}

		Set {
			return (isSet(key) ? (this.iCallbacks[key] := value) : (this.iCallbacks := value))
		}
	}

	SelectedCallback {
		Get {
			return this.iSelectedCallback
		}
	}

	SelectedParameter {
		Get {
			return this.iSelectedParameter
		}
	}

	__New(editor, type, categories := ["Builtin", "Custom"]) {
		this.iEditor := editor
		this.iType := type
		this.iCategories := categories
	}

	createGui() {
		local editorGui

		chooseCallback(listView, line, *) {
			this.selectCallback(line ? this.Callbacks[line] : false)
		}

		chooseParameter(listView, line, *) {
			this.selectParameter(line ? this.SelectedCallback.Parameters[line] : false)
		}

		updateCallbacksList(*) {
			local name := Trim(this.Control["callbackNameEdit"].Text)
			local active := this.Control["callbackActiveCheck"].Value
			local description := Trim(this.Control["callbackDescriptionEdit"].Text)
			local disabled := (this.Control["callbackTypeDropDown"].Text = translate("Event Disabled"))

			if this.SelectedCallback
				this.CallbacksListView.Modify(inList(this.Callbacks, this.SelectedCallback), ""
											, name, active ? translate(disabled ? "-" : "x") : "", description)

			this.updateState()
		}

		updateCallbackType(arguments*) {
			local newCallbackType := this.Control["callbackTypeDropDown"].Text
			local callbackType

			static labels := collect(["Event Class", "Event Rule", "Event Disabled", "Event Enabled", "Assistant Method", "Assistant Rule", "Assistant Script", "Controller Method", "Controller Function"], translate)
			static types := ["Assistant.Class", "Assistant.Rule", "", "", "Assistant.Method", "Assistant.Rule", "Assistant.Script", "Controller.Method", "Controller.Function"]

			types.Default := ""

			updateCallbacksList(arguments*)

			if (InStr(this.Type, "Actions") && this.SelectedCallback && !this.SelectedCallback.Builtin) {
				callbackType := this.SelectedCallback.SelectedType

				if (((callbackType = "Assistant.Rule") && (newCallbackType != translate("Assistant Rule")))
				 || ((callbackType = "Assistant.Script") && (newCallbackType != translate("Assistant Script")))) {
					this.ScriptEditor.Content[true] := ""

					this.updateState()
				}
			}

			try
				this.SelectedCallback.SelectedType := types[inList(labels, this.Control["callbackTypeDropDown"].Text)]
		}

		updateParametersList(*) {
			local name := Trim(this.Control["parameterNameEdit"].Text)
			local description := Trim(this.Control["parameterDescriptionEdit"].Text)

			if this.SelectedParameter
				this.ParametersListView.Modify(inList(this.SelectedCallback.Parameters, this.SelectedParameter), ""
											, name, description)

			this.updateState()
		}

		editorGui := CallbacksEditor.CallbacksEditorWindow(this)

		this.iWindow := editorGui

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "w848 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Actions Editor"))

		editorGui.SetFont("Norm", "Arial")

		if (this.Type = "Conversation.Actions")
			editorGui.Add("Documentation", "x308 YP+20 w248 H:Center Center", translate("Conversation Actions")
						, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#managing-actions")
		else if (InStr(this.Type, "Agent") && InStr(this.Type, "Actions"))
			editorGui.Add("Documentation", "x308 YP+20 w248 H:Center Center", translate("Reasoning Actions")
						, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#managing-actions")
		else
			editorGui.Add("Documentation", "x308 YP+20 w248 H:Center Center", translate("Reasoning Events")
						, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#managing-events")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x8 yp+30 w848 W:Grow 0x10")

		this.iCallbacksListView := editorGui.Add("ListView", "x16 y+10 w832 h140 W:Grow H:Grow(0.25) -Multi -LV0x10 AltSubmit NoSort NoSortHdr"
											   , collect([InStr(this.Type, "Actions") ? "Action" : "Event", "Active", "Description"], translate))

		this.iCallbacksListView.OnEvent("Click", chooseCallback)
		this.iCallbacksListView.OnEvent("DoubleClick", chooseCallback)

		editorGui.Add("Text", "x16 yp+146 w90 h23 +0x200 Y:Move(0.25) Hidden", translate("Assistant"))
		editorGui.Add("Text", "x113 yp w200 h23 +0x200 Y:Move(0.25) Hidden", translate(this.Editor.Assistant))

		editorGui.Add("Button", "x726 yp-4 w23 h23 Center +0x200 X:Move Y:Move(0.25) vaddCallbackButton").OnEvent("Click", (*) => this.addCallback())
		setButtonIcon(editorGui["addCallbackButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		editorGui.Add("Button", "x750 yp w23 h23 Center +0x200 X:Move Y:Move(0.25) vcopyCallbackButton").OnEvent("Click", (*) => this.copyCallback())
		setButtonIcon(editorGui["copyCallbackButton"], kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")
		editorGui.Add("Button", "x774 yp w23 h23 Center +0x200 X:Move Y:Move(0.25) vdeleteCallbackButton").OnEvent("Click", (*) => this.deleteCallback())
		setButtonIcon(editorGui["deleteCallbackButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		editorGui.Add("Button", "x800 yp w23 h23 Center +0x200 X:Move Y:Move(0.25) vuploadCallbacksButton").OnEvent("Click", (*) => this.importCallbacks())
		setButtonIcon(editorGui["uploadCallbacksButton"], kIconsDirectory . "Upload.ico", 1, "L4 T4 R4 B4")
		editorGui.Add("Button", "x824 yp w23 h23 Center +0x200 X:Move Y:Move(0.25) vdownloadCallbackButton").OnEvent("Click", (*) => this.exportCallback())
		setButtonIcon(editorGui["downloadCallbackButton"], kIconsDirectory . "Download.ico", 1, "L4 T4 R4 B4")

		if InStr(this.Type, "Actions")
			editorGui.Add("Text", "x16 yp+28 w70 h23 +0x200 Section Y:Move(0.25)", translate("Action"))
		else
			editorGui.Add("Text", "x16 yp+28 w70 h23 +0x200 Section Y:Move(0.25)", translate("Event"))

		editorGui.Add("CheckBox", "x87 yp h21 w23 Y:Move(0.25) vcallbackActiveCheck").OnEvent("Click", updateCallbacksList)

		if InStr(this.Type, "Events")
			editorGui.Add("DropDownList", "x110 yp w127 Y:Move(0.25) vcallbackTypeDropDown"
										, collect(InStr(this.Type, "Rules") ? ["Event Rule"]
																			: ["Event Class", "Event Rule", "Event Disabled"], translate)).OnEvent("Change", updateCallbackType)
		else
			editorGui.Add("DropDownList", "x110 yp w127 Y:Move(0.25) vcallbackTypeDropDown", collect(["Assistant Method", "Assistant Rule", "Assistant Script", "Controller Method", "Controller Function"], translate)).OnEvent("Change", updateCallbackType)

		editorGui.Add("Edit", "x241 yp h23 w177 W:Grow(0.34) Y:Move(0.25) vcallbackNameEdit").OnEvent("Change", updateCallbacksList)

		editorGui.Add("Text", "x16 yp+28 w90 h23 +0x200 Y:Move(0.25)", translate("Description"))
		editorGui.Add("Edit", "x110 yp h96 w308 W:Grow(0.34) Y:Move(0.25) vcallbackDescriptionEdit").OnEvent("Change", updateCallbacksList)

		editorGui.Add("Text", "x16 yp+100 w90 h23 +0x200 Y:Move(0.25)", translate("Learning Phase")).Visible := InStr(this.Type, "Actions")
		editorGui.Add("DropDownList", "x110 yp w90 Y:Move(0.25) vcallbackInitializationDropDown", collect(["Yes", "No"], translate)).OnEvent("Change", (*) => this.updateState())
		editorGui["callbackInitializationDropDown"].Visible := InStr(this.Type, "Actions")

		editorGui.Add("Text", "x16 yp w90 h23 +0x200 Y:Move(0.25)", translate("Signal")).Visible := (this.Type = "Agent.LLM.Events")
		editorGui.Add("Edit", "x110 yp w127 Y:Move(0.25) vcallbackEventEdit").Visible := (this.Type = "Agent.LLM.Events")

		editorGui.Add("Text", "x16 yp+24 w90 h23 +0x200 Y:Move(0.25)", translate("Confirmation")).Visible := InStr(this.Type, "Actions")
		editorGui.Add("DropDownList", "x110 yp w90 Y:Move(0.25) vcallbackConfirmationDropDown", collect(["Yes", "No"], translate)).OnEvent("Change", (*) => this.updateState())
		editorGui["callbackConfirmationDropDown"].Visible := InStr(this.Type, "Actions")

		this.iPhraseField := [editorGui.Add("Text", "x16 yp w90 h23 +0x200 Y:Move(0.25)", translate("Phrase"))
							, editorGui.Add("Edit", "x110 yp w308 Y:Move(0.25) vcallbackPhraseEdit")]

		this.iPhraseField[1].Visible := (this.Type = "Agent.LLM.Events")
		this.iPhraseField[2].Visible := (this.Type = "Agent.LLM.Events")

		this.iCallableField := [editorGui.Add("Text", "x16 yp+28 w90 h23 +0x200 Y:Move(0.25)", translate("Call"))
							  , editorGui.Add("Edit", "x110 yp w738 h140 H:Grow(0.75) W:Grow Y:Move(0.25)")]

		editorGui.SetFont("Norm", "Courier New")

		this.iScriptEditor := editorGui.Add("CodeEditor", "x16 yp" . ((this.Type = "Agent.Rules.Events") ? "-40" : "") . " w832 h140 DefaultOpt SystemTheme Border Disabled W:Grow Y:Move(0.25) H:Grow(0.75)")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x8 yp+150 w848 Y:Move W:Grow 0x10")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Button", "x350 yp+10 w80 h23 Default X:Move(0.5) Y:Move", translate("Ok")).OnEvent("Click", (*) => (GetKeyState("Ctrl") && InStr(this.Type, "Actions")) ? this.showCallbacks() : (this.iResult := kOk))
		editorGui.Add("Button", "x436 yp w80 h23 X:Move(0.5) Y:Move", translate("&Cancel")).OnEvent("Click", (*) => this.iResult := kCancel)

		this.iParametersListView := editorGui.Add("ListView", "x430 ys w418 h96 X:Move(0.34) W:Grow(0.66) Y:Move(0.25) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Parameter", "Description"], translate))
		this.iParametersListView.OnEvent("Click", chooseParameter)
		this.iParametersListView.OnEvent("DoubleClick", chooseParameter)

		editorGui.Add("Button", "x800 yp+100 w23 h23 Center +0x200 X:Move Y:Move(0.25) vaddParameterButton").OnEvent("Click", (*) => this.addParameter())
		setButtonIcon(editorGui["addParameterButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		editorGui.Add("Button", "x824 yp w23 h23 Center +0x200 X:Move Y:Move(0.25) vdeleteParameterButton").OnEvent("Click", (*) => this.deleteParameter())
		setButtonIcon(editorGui["deleteParameterButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		editorGui.Add("Text", "x430 yp+28 w100 h23 +0x200 X:Move(0.34) Y:Move(0.25)", translate("Name / Type")).Visible := (this.Type != "Agent.Rules.Events")
		editorGui.Add("Edit", "x536 yp h23 w127 Y:Move(0.25) X:Move(0.34) vparameterNameEdit").OnEvent("Change", updateParametersList)
		editorGui.Add("DropDownList", "x665 yp w90 Y:Move(0.25) X:Move(0.34) vparameterTypeDropDown", collect(["String", "Integer", "Number", "Boolean"], translate)).OnEvent("Change", updateParametersList)
		editorGui.Add("DropDownList", "x758 yp w90 Y:Move(0.25) X:Move(0.34) vparameterOptionalDropDown", collect(["Required", "Optional"], translate)).OnEvent("Change", updateParametersList)

		editorGui.Add("Text", "x430 yp+24 w100 h23 +0x200 Y:Move(0.25) X:Move(0.34)", translate("Description")).Visible := (this.Type != "Agent.Rules.Events")
		editorGui.Add("Edit", "x536 yp h23 w312 Y:Move(0.25) X:Move(0.34) W:Grow(0.66) vparameterDescriptionEdit").OnEvent("Change", updateParametersList)

		if (this.Type = "Agent.Rules.Events") {
			this.iParametersListView.Visible := false
			editorGui["addParameterButton"].Visible := false
			editorGui["deleteParameterButton"].Visible := false
			editorGui["parameterNameEdit"].Visible := false
			editorGui["parameterTypeDropDown"].Visible := false
			editorGui["parameterOptionalDropDown"].Visible := false
			editorGui["parameterDescriptionEdit"].Visible := false
		}

		this.updateState()
	}

	setScript(type, text, readOnly := false) {
		initializeLanguage(type) {
			if (type = "Rules") {
				this.ScriptEditor.CaseSense := false

				this.ScriptEditor.SetKeywords("priority"
											, "Any All None One Predicate"
											, "Call Prove ProveAll Set Get Clear Produce Option Sqrt Unbound Append get"
											, "messageShow messageBox"
											, "? ! fail"
											, ""
											, "true false")

				this.ScriptEditor.Brace.Chars := "()[]{}"
				this.ScriptEditor.SyntaxEscapeChar := "``"
				this.ScriptEditor.SyntaxCommentLine := ";"
			}
			else {
				this.ScriptEditor.CaseSense := true

				this.ScriptEditor.SetKeywords("_VERSION assert collectgarbage dofile error gcinfo loadfile loadstring print rawget rawset require tonumber tostring type unpack"
											, "_ALERT _ERRORMESSAGE _INPUT _PROMPT _OUTPUT _STDERR _STDIN _STDOUT call dostring foreach foreachi getn globals newtype sort tinsert tremove"
											, "and break do else elseif end false for function if in local nil not or repeat return then true until while"
											, "abs acos asin atan atan2 ceil cos deg exp floor format frexp gsub ldexp log log10 max min mod rad random randomseed sin sqrt strbyte strchar strfind strlen strlower strrep strsub strupper tan"
											, "openfile closefile readfrom writeto appendto remove rename flush seek tmpfile tmpname read write clock date difftime execute exit getenv setlocale time"
											, "_G getfenv getmetatable ipairs loadlib next pairs pcall rawequal setfenv setmetatable xpcall string table math coroutine io os debug load module select"
											, "string.byte string.char string.dump string.find string.len string.lower string.rep string.sub string.upper string.format string.gfind string.gsub table.concat table.foreach table.foreachi table.getn table.sort table.insert table.remove table.setn math.abs math.acos math.asin math.atan math.atan2 math.ceil math.cos math.deg math.exp math.floor math.frexp math.ldexp math.log math.log10 math.max math.min math.mod math.pi math.pow math.rad math.random math.randomseed math.sin math.sqrt math.tan string.gmatch string.match string.reverse table.maxn math.cosh math.fmod math.modf math.sinh math.tanh math.huge")

				this.ScriptEditor.Brace.Chars := "()[]{}"
				this.ScriptEditor.SyntaxEscapeChar := ""
				this.ScriptEditor.SyntaxCommentLine := "--"
			}

			this.ScriptEditor.Tab.Width := 4
		}

		this.ScriptEditor.Loading := true

		try {
			initializeLanguage(type)

			this.ScriptEditor.Content[true] := text
			this.ScriptEditor.Editable := !readOnly
			this.ScriptEditor.Enabled := true
		}
		finally {
			this.ScriptEditor.Loading := false
		}
	}

	editCallbacks(owner := false) {
		local window, x, y, w, h

		this.createGui()

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		if getWindowPosition(this.Type . " Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize(this.Type . " Editor", &w, &h)
			window.Resize("Initialize", w, h)

		this.loadCallbacks()

		try {
			loop {
				loop
					Sleep(200)
				until this.iResult

				if (this.iResult = kOk) {
					this.iResult := this.saveCallbacks()

					if this.iResult
						return this.iResult
					else
						this.iResult := false
				}
				else
					return false
			}
		}
		finally {
			this.ScriptEditor.Destroy()

			window.Destroy()
		}
	}

	updateState() {
		local type

		this.Control["addCallbackButton"].Enabled := true
		this.Control["uploadCallbacksButton"].Enabled := true

		if this.SelectedCallback {
			this.Control["copyCallbackButton"].Enabled := true
			this.Control["callbackActiveCheck"].Enabled := true

			if this.SelectedCallback.Builtin {
				this.Control["addParameterButton"].Enabled := false
				this.Control["deleteParameterButton"].Enabled := false

				this.Control["deleteCallbackButton"].Enabled := false
				this.Control["downloadCallbackButton"].Enabled := false

				this.CallableField[2].Opt("+ReadOnly")

				this.Control["callbackNameEdit"].Opt("+ReadOnly")
				this.Control["callbackDescriptionEdit"].Opt("+ReadOnly")

				if (this.Type = "Agent.LLM.Events") {
					this.Control["callbackTypeDropDown"].Enabled := true

					if (this.Control["callbackTypeDropDown"].Text != translate("Event Disabled")) {
						this.Control["callbackTypeDropDown"].Delete()

						this.Control["callbackTypeDropDown"].Add(collect(["Event Class", "Event Rule", "Event Disabled"], translate))

						this.Control["callbackTypeDropDown"].Choose(inList(["Assistant.Class", "Assistant.Rule"], this.SelectedCallback.Type))
					}
					else {
						this.Control["callbackTypeDropDown"].Delete()

						this.Control["callbackTypeDropDown"].Add(collect(["Event Enabled", "Event Disabled"], translate))

						this.Control["callbackTypeDropDown"].Choose(2)
					}
				}
				else
					this.Control["callbackTypeDropDown"].Enabled := false

				this.Control["callbackEventEdit"].Opt("+ReadOnly")
				this.PhraseField[2].Opt("+ReadOnly")
				this.Control["callbackInitializationDropDown"].Enabled := false
				this.Control["callbackConfirmationDropDown"].Enabled := false
			}
			else {
				this.Control["downloadCallbackButton"].Enabled := true
				this.Control["deleteCallbackButton"].Enabled := true
				this.Control["addParameterButton"].Enabled := true
				this.Control["deleteParameterButton"].Enabled := (this.SelectedParameter != false)

				this.CallableField[2].Opt("-ReadOnly")

				this.Control["callbackNameEdit"].Opt("-ReadOnly")
				this.Control["callbackDescriptionEdit"].Opt("-ReadOnly")
				this.Control["callbackTypeDropDown"].Enabled := true
				this.Control["callbackEventEdit"].Opt("-ReadOnly")
				this.PhraseField[2].Opt("-ReadOnly")
				this.Control["callbackInitializationDropDown"].Enabled := true
				this.Control["callbackConfirmationDropDown"].Enabled := true
			}

			if (this.Control["callbackTypeDropDown"].Value != 0) {
				if (this.Type = "Agent.LLM.Events") {
					if ((this.SelectedCallback.Disabled)
					 || (this.Control["callbackTypeDropDown"].Text = translate("Event Disabled")))
						type := ((this.SelectedCallback.Type = "Assistant.Class") ? "Class" : "Rule")
					else
						type := ["Class", "Rule", "Disabled"][this.Control["callbackTypeDropDown"].Value]
				}
				else if (this.Type = "Agent.Rules.Events")
					type := ["Rule"][this.Control["callbackTypeDropDown"].Value]
				else
					type := ["Method", "Rule", "Script", "Method", "Function"][this.Control["callbackTypeDropDown"].Value]
			}
			else
				type := "Rule"

			if (type = "Rule") {
				if (this.ScriptEditor.Content[true] = "")
					this.setScript("Rules", "; Insert your rules here...`n`n", this.SelectedCallback.Builtin)

				this.ScriptEditor.Visible := true
				this.CallableField[1].Visible := false
				this.CallableField[2].Visible := false
				this.PhraseField[1].Visible := (this.Type = "Agent.LLM.Events")
				this.PhraseField[2].Visible := (this.Type = "Agent.LLM.Events")
			}
			else if (type = "Script") {
				if (this.ScriptEditor.Content[true] = "")
					this.setScript("Script", "-- Insert your script here...`n`n", this.SelectedCallback.Builtin)

				this.ScriptEditor.Visible := true
				this.CallableField[1].Visible := false
				this.CallableField[2].Visible := false
				this.PhraseField[1].Visible := (this.Type = "Agent.LLM.Events")
				this.PhraseField[2].Visible := (this.Type = "Agent.LLM.Events")
			}
			else {
				this.ScriptEditor.Visible := false
				this.CallableField[1].Visible := true
				this.CallableField[2].Visible := true
				this.PhraseField[1].Visible := false
				this.PhraseField[2].Visible := false

				this.CallableField[1].Text := translate(type . (InStr(this.Type, "Actions") ? "(s)" : ""))
			}
		}
		else {
			this.Control["copyCallbackButton"].Enabled := false
			this.Control["deleteCallbackButton"].Enabled := false
			this.Control["downloadCallbackButton"].Enabled := false
			this.Control["addParameterButton"].Enabled := false
			this.Control["deleteParameterButton"].Enabled := false

			this.setScript("Rules", "", true)
			this.CallableField[2].Text := ""
			this.Control["callbackNameEdit"].Text := ""
			this.Control["callbackDescriptionEdit"].Text := ""
			this.Control["callbackActiveCheck"].Value := 0
			this.Control["callbackTypeDropDown"].Choose(0)
			this.Control["callbackEventEdit"].Text := ""
			this.PhraseField[2].Text := ""
			this.Control["callbackInitializationDropDown"].Choose(0)
			this.Control["callbackConfirmationDropDown"].Choose(0)

			this.ScriptEditor.Visible := true
			this.CallableField[1].Visible := false
			this.CallableField[2].Visible := false
			this.Control["callbackNameEdit"].Opt("+ReadOnly")
			this.Control["callbackDescriptionEdit"].Opt("+ReadOnly")
			this.Control["callbackActiveCheck"].Enabled := false
			this.Control["callbackTypeDropDown"].Enabled := false
			this.Control["callbackEventEdit"].Opt("+ReadOnly")
			this.PhraseField[2].Opt("+ReadOnly")
			this.Control["callbackInitializationDropDown"].Enabled := false
			this.Control["callbackConfirmationDropDown"].Enabled := false
		}

		if this.SelectedParameter {
			if this.SelectedCallback.Builtin {
				this.Control["parameterNameEdit"].Opt("+ReadOnly")
				this.Control["parameterDescriptionEdit"].Opt("+ReadOnly")
				this.Control["parameterTypeDropDown"].Enabled := false
				this.Control["parameterOptionalDropDown"].Enabled := false
			}
			else {
				this.Control["parameterNameEdit"].Opt("-ReadOnly")
				this.Control["parameterDescriptionEdit"].Opt("-ReadOnly")
				this.Control["parameterTypeDropDown"].Enabled := true
				this.Control["parameterOptionalDropDown"].Enabled := true
			}
		}
		else {
			this.Control["parameterNameEdit"].Text := ""
			this.Control["parameterDescriptionEdit"].Text := ""
			this.Control["parameterTypeDropDown"].Choose(0)
			this.Control["parameterOptionalDropDown"].Choose(0)

			this.Control["parameterNameEdit"].Opt("+ReadOnly")
			this.Control["parameterDescriptionEdit"].Opt("+ReadOnly")
			this.Control["parameterTypeDropDown"].Enabled := false
			this.Control["parameterOptionalDropDown"].Enabled := false
		}
	}

	selectCallback(callback, force := false, save := true) {
		if (force || (this.SelectedCallback != callback)) {
			if (save && this.SelectedCallback)
				if !this.saveCallback(this.SelectedCallback) {
					this.CallbacksListView.Modify(inList(this.Callbacks, this.SelectedCallback), "Select Vis")

					return
				}

			if callback
				this.CallbacksListView.Modify(inList(this.Callbacks, callback), "Select Vis")
			else
				loop this.CallbacksListView.GetCount()
					this.CallbacksListView.Modify(A_Index, "-Select")

			this.iSelectedCallback := callback

			if (callback && (this.Type = "Agent.LLM.Events")) {
				this.Control["callbackTypeDropDown"].Delete()

				if callback.Builtin {
					if callback.Disabled {
						this.Control["callbackTypeDropDown"].Add(collect(["Event Enabled", "Event Disabled"], translate))
						this.Control["callbackTypeDropDown"].Choose(2)
					}
					else
						this.Control["callbackTypeDropDown"].Add(collect(["Event Class", "Event Rule", "Event Disabled"], translate))
				}
				else
					this.Control["callbackTypeDropDown"].Add(collect(["Event Class", "Event Rule"], translate))

			}

			this.loadCallback(callback)

			this.updateState()
		}
	}

	selectParameter(parameter, force := false, save := true) {
		if (force || (this.SelectedParameter != parameter)) {
			if (save && this.SelectedParameter)
				if !this.saveParameter(this.SelectedParameter) {
					this.ParametersListView.Modify(inList(this.SelectedCallback.Parameters, this.SelectedParameter), "Select Vis")

					return
				}

			this.iSelectedParameter := parameter

			if parameter
				this.ParametersListView.Modify(inList(this.SelectedCallback.Parameters, parameter), "Select Vis")

			this.loadParameter(parameter)

			this.updateState()
		}
	}

	addCallback() {
		local callback

		if this.SelectedCallback
			if !this.saveCallback(this.SelectedCallback) {
				this.CallbacksListView.Modify(inList(this.Callbacks, this.SelectedCallback), "Select Vis")

				return
			}

		if InStr(this.Type, "Events")
			callback := {Name: "", Type: "Assistant.Rule", SelectedType: "Assistant.Rule"
					   , Active: true, Disabled: false, Description: "", Parameters: []
					   , Builtin: false, Event: "", Phrase: "", Definition: "", Script: "; Insert your rules here...`n`n"}
		else
			callback := {Name: "", Type: "Controller.Function", SelectedType: "Controller.Function"
					   , Active: true, Disabled: false, Description: "", Parameters: []
					   , Builtin: false, Initialized: true, Confirm: true, Definition: ""}

		this.Callbacks.Push(callback)

		this.CallbacksListView.Add("", "", translate("x"), "")

		this.selectCallback(callback, true, false)
	}

	copyCallback() {
		local callback

		if this.SelectedCallback
			if !this.saveCallback(this.SelectedCallback) {
				this.CallbacksListView.Modify(inList(this.Callbacks, this.SelectedCallback), "Select Vis")

				return
			}

		callback := this.SelectedCallback.Clone()

		callback.Builtin := false
		callback.Disabled := false
		callback.Active := true

		callback.Name .= "_copy"

		this.Callbacks.Push(callback)

		this.CallbacksListView.Add("", callback.Name, translate("x"), callback.Description)

		this.selectCallback(callback, true, false)
	}

	deleteCallback() {
		local index := inList(this.Callbacks, this.SelectedCallback)

		if index {
			this.iDeletedCallbacks[this.SelectedCallback.Name] := true

			this.CallbacksListView.Delete(index)

			this.Callbacks.RemoveAt(index)

			this.selectCallback(false, true, false)
		}
	}

	importCallbacks() {
		local directory := (kTempDirectory . "Callback Import")
		local extension := (InStr(this.Type, "Events") ? ".event" : ".action")
		local type := (InStr(this.Type, "Events") ? "Event" : "Action")
		local fileName, ignore

		importCallback(fileName) {
			local name, newName, generation, duplicate, definition
			local ignore, type, callback, descriptor, parameter, parameters, theCallback

			deleteDirectory(directory)

			DirCreate(directory)

			try {
				SplitPath(fileName, , , , &name)

				FileCopy(fileName, kTempDirectory . name . ".zip", 1)

				RunWait("PowerShell.exe -Command Expand-Archive -LiteralPath '" . kTempDirectory . name . ".zip" . "' -DestinationPath '" . directory . "' -Force", , "Hide")

				loop Files, directory . "\*" . extension {
					SplitPath(A_LoopFileFullPath, , , , &name)

					newName := name

					loop {
						generation := A_Index
						duplicate := false

						for ignore, callback in this.Callbacks
							if (callBack.Name = newName) {
								duplicate := true

								break
							}

						if duplicate
							newName := (name . "_" . generation)
						else
							break
					}

					definition := readMultiMap(A_LoopFileFullPath)

					type := (this.Type . ".Custom")

					for callback, descriptor in getMultiMapValues(definition, type) {
						descriptor := string2Values("|", descriptor)

						parameters := []

						loop descriptor[5] {
							parameter := string2Values("|", getMultiMapValue(definition, this.Type . ".Parameters", ConfigurationItem.descriptor(callback, A_Index)))

							parameters.Push({Name: parameter[1], Type: parameter[2], Enumeration: string2Values(",", parameter[3])
										   , Required: ((parameter[4] = kTrue) ? true : ((parameter[4] = kFalse) ? false : parameter[4]))
										   , Description: parameter[5]})
						}

						if InStr(this.Type, "Events")
							theCallback := {Name: newName, Active: true, Disabled: false
										  , Type: descriptor[1], SelectedType: descriptor[1], Definition: descriptor[2]
										  , Description: descriptor[6], Parameters: parameters, Builtin: false
										  , Event: descriptor[3], Phrase: descriptor[4]}
						else
							theCallback := {Name: newName, Active: true, Disabled: false
										  , Type: descriptor[1], SelectedType: descriptor[1], Definition: descriptor[2]
										  , Description: descriptor[6], Parameters: parameters, Builtin: false
										  , Initialized: ((descriptor[3] = kTrue) ? true : ((descriptor[3] = kFalse) ? false : descriptor[3]))
										  , Confirm: ((descriptor[4] = kTrue) ? true : ((descriptor[4] = kFalse) ? false : descriptor[4]))}

						if (theCallback.Type = "Assistant.Rule") {
							theCallback.Script := FileRead(directory . "\" . descriptor[2])

							theCallback.Definition := ""
						}
						else if (theCallback.Type = "Assistant.Script") {
							theCallback.Script := FileRead(directory . "\" . descriptor[2])

							theCallback.Definition := ""
						}

						this.Callbacks.Push(theCallback)

						this.CallbacksListView.Add("", theCallback.Name, theCallback.Active ? translate(theCallback.Disabled ? "-" : "x") : "", theCallback.Description)
					}

					this.selectCallback(false)

					this.CallbacksListView.ModifyCol()

					loop this.CallbacksListView.GetCount("Col")
						this.CallbacksListView.ModifyCol(A_Index, "AutoHdr")
				}
			}
			catch Any as exception {
				logError(exception, true)
			}
		}

		if this.SelectedCallback
			if !this.saveCallback(this.SelectedCallback)
				return

		this.Window.Opt("+OwnDialogs")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := withBlockedWindows(FileSelect, "M1", , translate("Load ") . translate(type) . translate("..."), type . " (*" . extension . ")")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if ((fileName != "") || (isObject(fileName) && (fileName.Length > 0)))
			for ignore, fileName in isObject(fileName) ? fileName : [fileName]
				importCallback(fileName)
	}

	exportCallback() {
		local directory := (kTempDirectory . "Callback Export")
		local extension := (InStr(this.Type, "Events") ? ".event" : ".action")
		local type := (InStr(this.Type, "Events") ? "Event" : "Action")
		local callback := this.SelectedCallback
		local configuration := newMultiMap()
		local index, parameter, fileName, newFileName, targetDirectory

		if !this.saveCallback(callback)
			return

		this.Window.Opt("+OwnDialogs")

		fileName := callback.Name

		newFileName := (fileName . extension)

		while FileExist(newFileName)
			newFileName := (fileName . " (" . (A_Index + 1) . ")" . extension)

		fileName := newFileName

		OnMessage(0x44, translateSaveCancelButtons)
		fileName := withBlockedWindows(FileSelect, "S17", fileName, translate("Save ") . translate(type) . translate("..."), type . " (*" . extension . ")")
		OnMessage(0x44, translateSaveCancelButtons, 0)

		if (fileName != "") {
			deleteDirectory(directory)

			DirCreate(directory)

			if (callback.Type = "Assistant.Rule") {
				callback.Definition := (this.Assistant . "." . callback.Name . ".rules")

				FileAppend(callback.Script, directory . "\" . callback.Definition)
			}
			else if (callback.Type = "Assistant.Script") {
				callback.Definition := (this.Assistant . "." . callback.Name . ".script")

				FileAppend(callback.Script, directory . "\" . callback.Definition)
			}

			if InStr(this.Type, "Events")
				setMultiMapValue(configuration, this.Type . ".Custom", callback.Name
											  , values2String("|", callback.Type, callback.Definition, callback.Event, callback.Phrase
																 , callback.Parameters.Length, callback.Description))
			else
				setMultiMapValue(configuration, this.Type . ".Custom", callback.Name
											  , values2String("|", callback.Type, callback.Definition, callback.Initialized, callback.Confirm
																 , callback.Parameters.Length, callback.Description))

			loop
				if !getMultiMapValue(configuration, this.Type . ".Parameters", callback.Name . "." . A_Index)
					break
				else
					removeMultiMapValue(configuration, this.Type . ".Parameters", callback.Name . "." . A_Index)

			for index, parameter in callback.Parameters
				setMultiMapValue(configuration, this.Type . ".Parameters", callback.Name . "." . index
											  , values2String("|", parameter.Name, parameter.Type
																 , values2String(",", parameter.Enumeration*)
																 , parameter.Required, parameter.Description))

			writeMultiMap(directory . "\" . callback.Name . extension, configuration)

			SplitPath(fileName, , &targetDirectory, , &name)

			RunWait("PowerShell.exe -Command Compress-Archive -Path '" . directory . "\*.*' -CompressionLevel Optimal -DestinationPath '" . targetDirectory . "\" . name . ".zip'", , "Hide")

			FileMove(targetDirectory . "\" . name . ".zip", fileName, 1)
		}
	}

	loadCallback(callback) {
		local ignore, parameter

		this.ParametersListView.Delete()
		this.selectParameter(false, true, false)

		if callback {
			this.Control["callbackNameEdit"].Text := callback.Name

			if InStr(this.Type, "Events") {
				this.Control["callbackEventEdit"].Text := callback.Event

				if (this.Type = "Agent.LLM.Events") {
					this.PhraseField[2].Text := callback.Phrase

					if callback.Disabled
						this.Control["callbackTypeDropDown"].Choose(2)
					else
						this.Control["callbackTypeDropDown"].Choose(inList(["Assistant.Class", "Assistant.Rule"], callback.Type))
				}
				else
					this.Control["callbackTypeDropDown"].Choose(inList(["Assistant.Rule"], callback.Type))
			}
			else {
				this.Control["callbackInitializationDropDown"].Choose(1 + (!callback.Initialized ? 1 : 0))
				this.Control["callbackConfirmationDropDown"].Choose(1 + (!callback.Confirm ? 1 : 0))
				this.Control["callbackTypeDropDown"].Choose(inList(["Assistant.Method", "Assistant.Rule", "Assistant.Script", "Controller.Method", "Controller.Function"], callback.Type))
			}

			this.Control["callbackActiveCheck"].Value := !!callback.Active
			this.Control["callbackDescriptionEdit"].Text := callback.Description

			if (callback.Type = "Assistant.Rule") {
				this.setScript("Rules", callback.Script, callback.Builtin)

				this.CallableField[2].Text := ""
			}
			else if (callback.Type = "Assistant.Script") {
				this.setScript("Script", callback.Script, callback.Builtin)

				this.CallableField[2].Text := ""
			}
			else {
				this.setScript("Rules", "", true)

				this.CallableField[2].Value := callback.Definition
			}

			for ignore, parameter in callback.Parameters
				this.ParametersListView.Add("", parameter.Name, parameter.Description)

			this.ParametersListView.ModifyCol()

			loop this.ParametersListView.GetCount("Col")
				this.ParametersListView.ModifyCol(A_Index, "AutoHdr")
		}
		else {
			this.Control["callbackNameEdit"].Text := ""
			this.Control["callbackTypeDropDown"].Choose(0)
			this.Control["callbackActiveCheck"].Value := 0
			this.Control["callbackDescriptionEdit"].Text := ""
			this.Control["callbackEventEdit"].Text := ""
			this.PhraseField[2].Text := ""
			this.Control["callbackInitializationDropDown"].Choose(0)
			this.Control["callbackConfirmationDropDown"].Choose(0)

			this.setScript("Rules", "", true)
		}

		this.updateState()
	}

	saveCallback(callback) {
		local valid := true
		local name := this.Control["callbackNameEdit"].Text
		local errorMessage := ""
		local ignore, other, type, fileName, context, message, script

		if this.SelectedParameter
			if !this.saveParameter(this.SelectedParameter)
				return false

		if (Trim(name) = "") {
			errorMessage .= ("`n" . translate("Error: ") . "Name cannot be empty...")

			valid := false
		}

		for ignore, other in this.Callbacks
			if ((other != callback) && (name = other.Name)) {
				errorMessage .= ("`n" . translate("Error: ") . "Name must be unique...")

				valid := false
			}

		if (this.Type = "Agent.LLM.Events") {
			if (this.Control["callbackTypeDropDown"].Text = translate("Event Disabled")) {
				callback.Disabled := true

				type := callback.Type
			}
			else {
				callback.Disabled := false

				type := ["Assistant.Class", "Assistant.Rule"][this.Control["callbackTypeDropDown"].Value]
			}
		}
		else if (this.Type = "Agent.Rules.Events")
			type := ["Assistant.Rule"][this.Control["callbackTypeDropDown"].Value]
		else
			type := ["Assistant.Method", "Assistant.Rule", "Assistant.Script", "Controller.Method", "Controller.Function"][this.Control["callbackTypeDropDown"].Value]

		if (type = "Assistant.Rule") {
			try {
				RuleCompiler().compileRules(this.ScriptEditor.Content[true], &ignore := false, &ignore := false)
			}
			catch Any as exception {
				errorMessage .= ("`n" . translate("Error: ") . (isObject(exception) ? exception.Message : exception))

				valid := false
			}
		}
		else if (type = "Assistant.Script") {
			fileName := temporaryFilename("Script", "script")

			try {
				context := scriptOpenContext()

				script := this.ScriptEditor.Content[true]

				for ignore, parameter in callback.Parameters
					script := StrReplace(script, "%" . parameter.Name . "%", "__" . parameter.Name . "__")

				FileAppend(script, fileName)

				if !scriptLoadScript(context, fileName, &message)
					throw message

				scriptCloseContext(context)
			}
			catch Any as exception {
				errorMessage .= ("`n" . translate("Error: ") . (isObject(exception) ? exception.Message : exception))

				valid := false
			}
			finally {
				deleteFile(fileName)
			}
		}

		if valid {
			callback.Name := name
			callback.Active := Trim(this.Control["callbackActiveCheck"].Value)
			callback.Description := Trim(this.Control["callbackDescriptionEdit"].Text)
			callback.Type := type

			if InStr(this.Type, "Events") {
				callback.Event := Trim(this.Control["callbackEventEdit"].Text)

				if (this.Type = "Agent.LLM.Events")
					callback.Phrase := Trim(this.PhraseField[2].Text)
			}
			else {
				callback.Initialized := (this.Control["callbackInitializationDropDown"].Value = 1)
				callback.Confirm := (this.Control["callbackConfirmationDropDown"].Value = 1)
			}

			if ((callback.Type = "Assistant.Rule") || (callback.Type = "Assistant.Script"))
				callback.Script := this.ScriptEditor.Content[true]
			else
				callback.Definition := this.CallableField[2].Value

			this.CallbacksListView.Modify(inList(this.Callbacks, callback), "", callback.Name, callback.Active ? translate(callback.Disabled ? "-" : "x") : "", callback.Description)
		}
		else {
			if (StrLen(errorMessage) > 0)
				errorMessage := ("`n" . errorMessage)

			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Invalid values detected - please correct...") . errorMessage, translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}

		return valid
	}

	addParameter() {
		local parameter

		if this.SelectedParameter
			if !this.saveParameter(this.SelectedParameter) {
				this.ParametersListView.Modify(inList(this.SelectedCallback.Parameters, this.SelectedParameter), "Select Vis")

				return
			}

		parameter := {Name: "", Type: "String", Enumeration: [], Required: false, Description: ""}

		this.SelectedCallback.Parameters.Push(parameter)

		this.ParametersListView.Add("", "", "")

		this.selectParameter(parameter, true, false)
	}

	deleteParameter() {
		local index := inList(this.SelectedCallback.Parameters, this.SelectedParameter)

		this.ParametersListView.Delete(index)

		this.SelectedCallback.Parameters.RemoveAt(index)

		this.selectParameter(false, true, false)
	}

	loadParameter(parameter) {
		if parameter {
			this.Control["parameterNameEdit"].Text := parameter.Name
			this.Control["parameterTypeDropDown"].Choose(inList(["String", "Integer", "Number", "Boolean"], parameter.Type))
			this.Control["parameterDescriptionEdit"].Text := parameter.Description
			this.Control["parameterOptionalDropDown"].Choose(1 + (!parameter.Required ? 1 : 0))
		}
		else {
			this.Control["parameterNameEdit"].Text := ""
			this.Control["parameterTypeDropDown"].Choose(0)
			this.Control["parameterDescriptionEdit"].Text := ""
			this.Control["parameterOptionalDropDown"].Choose(0)
		}

		this.updateState()
	}

	saveParameter(parameter) {
		local valid := true
		local name := this.Control["parameterNameEdit"].Text
		local errorMessage := ""
		local ignore, other

		if (Trim(name) = "") {
			errorMessage .= ("`n" . translate("Error: ") . "Name cannot be empty...")

			valid := false
		}

		for ignore, other in this.SelectedCallback.Parameters
			if ((other != parameter) && (name = other.Name)) {
				errorMessage .= ("`n" . translate("Error: ") . "Name must be unique...")

				valid := false
			}

		if valid {
			parameter.Name := name
			parameter.Description := Trim(this.Control["parameterDescriptionEdit"].Text)
			parameter.Type := ["String", "Integer", "Number", "Boolean"][this.Control["parameterTypeDropDown"].Value]
			parameter.Required := (this.Control["parameterOptionalDropDown"].Value = 1)

			this.ParametersListView.Modify(inList(this.SelectedCallback.Parameters, parameter), "", parameter.Name, parameter.Description)
		}
		else {
			if (StrLen(errorMessage) > 0)
				errorMessage := ("`n" . errorMessage)

			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Invalid values detected - please correct...") . errorMessage, translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}

		return valid
	}

	showCallbacks() {
		local callbacks := []
		local ignore, callback, index, parameter, parameters

		if this.SelectedCallback
			if !this.saveCallback(this.SelectedCallback) {
				this.CallbacksListView.Modify(inList(this.Callbacks, this.SelectedCallback), "Select Vis")

				return false
			}

		for ignore, callback in this.Callbacks {
			if callback.Active {
				parameters := []

				for ignore, parameter in callback.Parameters
					parameters.Push(LLMTool.Function.Parameter(parameter.Name, parameter.Description
															 , parameter.Type, parameter.Enumeration, parameter.Required))

				callbacks.Push(LLMTool.Function(callback.Name, callback.Description, parameters))
			}
		}

		deleteFile(kTempDirectory . "LLM Callbacks.json")

		FileAppend(JSON.print(collect(callbacks, (callback) => callback.Descriptor), "`t"), kTempDirectory . "LLM Callbacks.json")

		Run("notepad.exe `"" . kTempDirectory . "LLM Callbacks.json`"")
	}

	loadCallbacks() {
		local extension := (InStr(this.Type, "Events") ? ".events" : ".actions")
		local configuration := readMultiMap(kResourcesDirectory . "Actions\" . this.Assistant . extension)
		local callbacks := []
		local active, disabled, ignore, type, callback, descriptor, parameters, theCallback, context, fileName, message, category

		this.iDeletedCallbacks := CaseInsenseMap()

		addMultiMapValues(configuration, readMultiMap(kUserHomeDirectory . "Actions\" . this.Assistant . extension))

		active := string2Values(",", getMultiMapValue(configuration, this.Type, "Active", ""))
		disabled := string2Values(",", getMultiMapValue(configuration, this.Type, "Disabled", ""))

		for ignore, category in this.Categories {
			type := (this.Type . "." . category)

			for callback, descriptor in getMultiMapValues(configuration, type) {
				descriptor := string2Values("|", descriptor)

				parameters := []

				loop descriptor[5] {
					parameter := string2Values("|", getMultiMapValue(configuration, this.Type . ".Parameters", ConfigurationItem.descriptor(callback, A_Index)))

					parameters.Push({Name: parameter[1], Type: parameter[2], Enumeration: string2Values(",", parameter[3])
								   , Required: ((parameter[4] = kTrue) ? true : ((parameter[4] = kFalse) ? false : parameter[4]))
								   , Description: parameter[5]})
				}

				if InStr(this.Type, "Events")
					theCallback := {Name: callback, Active: inList(active, callback), Disabled: inList(disabled, callback)
								  , Type: descriptor[1], SelectedType: descriptor[1], Definition: descriptor[2]
								  , Description: descriptor[6], Parameters: parameters, Builtin: (type = (this.Type . ".Builtin"))
								  , Event: descriptor[3], Phrase: descriptor[4]}
				else
					theCallback := {Name: callback, Active: inList(active, callback), Disabled: inList(disabled, callback)
								  , Type: descriptor[1], SelectedType: descriptor[1], Definition: descriptor[2]
								  , Description: descriptor[6], Parameters: parameters, Builtin: (type = (this.Type . ".Builtin"))
								  , Initialized: ((descriptor[3] = kTrue) ? true : ((descriptor[3] = kFalse) ? false : descriptor[3]))
								  , Confirm: ((descriptor[4] = kTrue) ? true : ((descriptor[4] = kFalse) ? false : descriptor[4]))}

				if (theCallback.Type = "Assistant.Rule") {
					theCallback.Script := FileRead(getFileName(descriptor[2], kResourcesDirectory . "Actions\", kUserHomeDirectory . "Actions\"))

					if (theCallback.Builtin && isDebug())
						try {
							RuleCompiler().compileRules(theCallback.Script, &ignore := false, &ignore := false)
						}
						catch Any as exception {
							OnMessage(0x44, translateOkButton)
							withBlockedWindows(MsgBox, "Error in builtin rule " . theCallback.Name . ":`n`n" . (isObject(exception) ? exception.Message : exception), translate("Error"), 262160)
							OnMessage(0x44, translateOkButton, 0)
						}

					theCallback.Definition := ""
				}
				else if (theCallback.Type = "Assistant.Script") {
					theCallback.Script := FileRead(getFileName(descriptor[2], kResourcesDirectory . "Actions\", kUserHomeDirectory . "Actions\"))

					if (theCallback.Builtin && isDebug())
						try {
							fileName := temporaryFilename("Script", "script")

							try {
								context := scriptOpenContext()

								FileAppend(theCallback.Script, fileName)

								if !scriptLoadScript(context, fileName, &message)
									throw message

								scriptCloseContext(context)
							}
							finally {
								deleteFile(fileName)
							}
						}
						catch Any as exception {
							OnMessage(0x44, translateOkButton)
							withBlockedWindows(MsgBox, "Error in builtin script " . theCallback.Name . ":`n`n" . (isObject(exception) ? exception.Message : exception), translate("Error"), 262160)
							OnMessage(0x44, translateOkButton, 0)
						}

					theCallback.Definition := ""
				}

				this.Callbacks.Push(theCallback)
			}
		}

		this.CallbacksListView.Delete()

		for ignore, callback in this.Callbacks
			this.CallbacksListView.Add("", callback.Name, callback.Active ? translate(callback.Disabled ? "-" : "x") : "", callback.Description)

		this.CallbacksListView.ModifyCol()

		loop this.CallbacksListView.GetCount("Col")
			this.CallbacksListView.ModifyCol(A_Index, "AutoHdr")
	}

	saveCallbacks(save := true) {
		local extension := (InStr(this.Type, "Events") ? ".events" : ".actions")
		local active := []
		local disabled := []
		local configuration, ignore, callback, index, parameter, name

		if this.SelectedCallback
			if !this.saveCallback(this.SelectedCallback) {
				this.CallbacksListView.Modify(inList(this.Callbacks, this.SelectedCallback), "Select Vis")

				return false
			}

		configuration := readMultiMap(kUserHomeDirectory . "Actions\" . this.Assistant . extension)

		for ignore, callback in this.Callbacks {
			if callback.Active
				active.Push(callback.Name)

			if callback.Disabled
				disabled.Push(callback.Name)

			if this.iDeletedCallbacks.Has(callback.Name)
				this.iDeletedCallbacks.Delete(callback.Name)

			if !callback.Builtin {
				if save
					if (callback.Type = "Assistant.Rule") {
						callback.Definition := (this.Assistant . "." . callback.Name . ".rules")

						deleteFile(kUserHomeDirectory . "Actions\" . callback.Definition)

						FileAppend(callback.Script, kUserHomeDirectory . "Actions\" . callback.Definition)
					}
					else if (callback.Type = "Assistant.Script") {
						callback.Definition := (this.Assistant . "." . callback.Name . ".script")

						deleteFile(kUserHomeDirectory . "Actions\" . callback.Definition)

						FileAppend(callback.Script, kUserHomeDirectory . "Actions\" . callback.Definition)
					}

				if InStr(this.Type, "Events")
					setMultiMapValue(configuration, this.Type . ".Custom", callback.Name
												  , values2String("|", callback.Type, callback.Definition, callback.Event, callback.Phrase
																	 , callback.Parameters.Length, callback.Description))
				else
					setMultiMapValue(configuration, this.Type . ".Custom", callback.Name
												  , values2String("|", callback.Type, callback.Definition, callback.Initialized, callback.Confirm
																	 , callback.Parameters.Length, callback.Description))

				loop
					if !getMultiMapValue(configuration, this.Type . ".Parameters", callback.Name . "." . A_Index)
						break
					else
						removeMultiMapValue(configuration, this.Type . ".Parameters", callback.Name . "." . A_Index)

				for index, parameter in callback.Parameters
					setMultiMapValue(configuration, this.Type . ".Parameters", callback.Name . "." . index
												  , values2String("|", parameter.Name, parameter.Type
																	 , values2String(",", parameter.Enumeration*)
																	 , parameter.Required, parameter.Description))
			}
		}

		for name, ignore in this.iDeletedCallbacks {
			loop
				if !getMultiMapValue(configuration, this.Type . ".Parameters", name . "." . A_Index)
					break
				else
					removeMultiMapValue(configuration, this.Type . ".Parameters", name . "." . A_Index)

			removeMultiMapValue(configuration, this.Type . ".Custom", name)
		}

		setMultiMapValue(configuration, this.Type, "Active", values2String(",", active*))
		setMultiMapValue(configuration, this.Type, "Disabled", values2String(",", disabled*))

		if save
			writeMultiMap(kUserHomeDirectory . "Actions\" . this.Assistant . extension, configuration)

		return configuration
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; EventsEditor                                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class EventsEditor extends CallbacksEditor {
	editEvents(owner := false) {
		this.editCallbacks(owner)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ActionsEditor                                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ActionsEditor extends CallbacksEditor {
	editActions(owner := false) {
		this.editCallbacks(owner)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Functions Section                        ;;;
;;;-------------------------------------------------------------------------;;;

editInstructions(editorOrCommand, type := false, title := false, originalInstructions := false, owner := false) {
	local choices, key, value, descriptor, reloadAll

	static reference, editor, instructions, instructionsGui, result, instructionEdit

	rephrase(key) {
		if (key = "RephraseTranslate")
			return "Rephrase & Translate"
		else
			return key
	}

	if (editorOrCommand == kOk)
		result := kOk
	else if (editorOrCommand == kCancel)
		result := kCancel
	else if (editorOrCommand == "Reload") {
		reloadALL := GetKeyState("Ctrl")

		for key, value in getMultiMapValues(instructions, reference)
			if (reloadAll || (instructionsGui["instructionsDropDown"].Value = A_Index)) {
				descriptor := ConfigurationItem.splitDescriptor(key)

				value := editor.getOriginalInstruction(descriptor[4], descriptor[2], descriptor[3])

				setMultiMapValue(instructions, reference, key, value)

				if (instructionsGui["instructionsDropDown"].Value = A_Index)
					instructionsGui["instructionEdit"].Value := value

				if !reloadAll
					break
			}
	}
	else if (editorOrCommand == "Load") {
		for key, value in getMultiMapValues(instructions, reference)
			if (instructionsGui["instructionsDropDown"].Value = A_Index) {
				instructionsGui["instructionEdit"].Value := value

				break
			}
	}
	else if (editorOrCommand == "Update") {
		for key, value in getMultiMapValues(instructions, reference)
			if (instructionsGui["instructionsDropDown"].Value = A_Index) {
				setMultiMapValue(instructions, reference, key, instructionsGui["instructionEdit"].Value)

				break
			}
	}
	else {
		reference := ((type = "Agent") ? "Agent Booster" : "Conversation Booster")

		editor := editorOrCommand
		result := false

		instructions := originalInstructions.Clone()

		instructionsGui := Window({Options: "0x400000"}, title)

		instructionsGui.SetFont("Norm", "Arial")

		choices := []

		for key, value in getMultiMapValues(instructions, reference) {
			key := ConfigurationItem.splitDescriptor(key)

			choices.Push(translate(rephrase(key[3])) . translate(" (") . StrUpper(key[4]) . translate(")"))
		}

		instructionsGui.Add("Text", "x16 y16 w90 h23 +0x200", translate("Instructions"))
		instructionsGui.Add("DropDownList", "x110 yp w180 vinstructionsDropDown", choices).OnEvent("Change", (*) => editInstructions("Load"))

		widget1 := instructionsGui.Add("Button", "x447 yp w23 h23")
		widget1.OnEvent("Click", (*) => editInstructions("Reload"))
		setButtonIcon(widget1, kIconsDirectory . "Renew.ico", 1)

		instructionEdit := instructionsGui.Add("Edit", "x110 yp+24 w360 h200 Multi vinstructionEdit")
		instructionEdit.OnEvent("Change", (*) => editInstructions("Update"))

		instructionsGui.Add("Button", "x160 yp+210 w80 h23 Default", translate("Ok")).OnEvent("Click", editInstructions.Bind(kOk))
		instructionsGui.Add("Button", "x246 yp w80 h23", translate("&Cancel")).OnEvent("Click", editInstructions.Bind(kCancel))

		instructionsGui.Opt("+Owner" . owner.Hwnd)

		instructionsGui.Show("AutoSize Center")

		instructionsGui["instructionsDropDown"].Choose(1)

		editInstructions("Load")

		while !result
			Sleep(100)

		try {
			if (result == kCancel)
				return false
			else if (result == kOk) {
				return instructions
			}
		}
		finally {
			instructionsGui.Destroy()
		}
	}
}