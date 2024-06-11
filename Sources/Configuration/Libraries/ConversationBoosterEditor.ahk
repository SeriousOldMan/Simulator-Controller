;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Conversation Booster Editor     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\LLMConnector.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\SpeechSynthesizer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ConversationBoosterEditor                                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ConversationBoosterEditor extends ConfiguratorPanel {
	iResult := false

	iAssistant := false

	iWindow := false

	iProviderConfigurations := CaseInsenseMap()
	iCurrentProvider := false

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

	__New(assistant, configuration := false) {
		this.iAssistant := assistant

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

		validateTokens(*) {
			local field := this.Control["viMaxTokensEdit"]
			local value := field.Text

			if (!isInteger(value) || (value < 32)) {
				field.Text := (field.HasProp("ValidText") ? field.ValidText : "200")

				loop 10
					SendInput("{Right}")
			}
			else
				field.ValidText := field.Text
		}

		chooseProvider(*) {
			this.saveProviderConfiguration()

			this.loadProviderConfiguration(editorGui["viProviderDropDown"].Text)

			this.updateState()
		}

		editInstructions(type, title, *) {
			this.editInstructions(type, title)
		}

		editActions(*) {
			this.editActions(this.Assistant)
		}

		loadModels(*) {
			local provider := this.iCurrentProvider
			local configuration

			if provider {
				configuration := this.iProviderConfigurations[provider]

				this.loadModels(provider, this.Control["viServiceURLEdit"].Text
										, this.Control["viServiceKeyEdit"].Text
										, this.Control["viModelDropDown"].Text)
			}
			else
				this.loadModels(false)
		}

		editorGui := Window({Descriptor: "Booster Editor", Options: "0x400000"})

		this.iWindow := editorGui

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "w468 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Booster Editor"))

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Documentation", "x178 YP+20 w128 H:Center Center", translate("Conversation Booster")
					, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#boosting-conversation-with-an-llm")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x8 yp+30 w468 W:Grow 0x10")

		x0 := x + 8
		x1 := x + 132
		x2 := x + 172
		x3 := x + 176

		w1 := width - (x1 - x + 8)
		w3 := width - (x3 - x + 16) + 10

		w2 := w1 - 24
		x4 := x1 + w2 + 1

		w4 := w1 - 24
		x6 := x1 + w4 + 1

		editorGui.SetFont("Italic", "Arial")
		widget1 := editorGui.Add("Text", "x" . x0 . " yp+10 w105 h23", translate("Service "))
		widget2 := editorGui.Add("Text", "x100 yp+7 w" . (width + 8 - 100) . " 0x10 W:Grow")
		editorGui.SetFont("Norm", "Arial")

		widget3 := editorGui.Add("Text", "x" . x0 . " yp+20 w105 h23 +0x200", translate("Provider / URL"))

		widget4 := editorGui.Add("DropDownList", "x" . x1 . " yp w100 Choose1 vviProviderDropDown", concatenate([translate("None")], this.Providers))
		widget4.OnEvent("Change", chooseProvider)

		widget5 := editorGui.Add("Edit", "x" . (x1 + 102) . " yp w" . (w1 - 102) . " h23 vviServiceURLEdit")
		widget5.OnEvent("Change", loadModels)

		widget6 := editorGui.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200", translate("Service Key"))
		widget7 := editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h23 Password vviServiceKeyEdit")
		widget7.OnEvent("Change", loadModels)

		widget8 := editorGui.Add("Text", "x" . x0 . " yp+30 w105 h23 +0x200", translate("Model / # Tokens"))
		widget9 := editorGui.Add("ComboBox", "x" . x1 . " yp w" . (w1 - 64) . " vviModelDropDown")
		widget10 := editorGui.Add("Edit", "x" . (x1 + (w1 - 60)) . " yp-1 w60 h23 Number vviMaxTokensEdit")
		widget10.OnEvent("Change", validateTokens)
		widget11 := editorGui.Add("UpDown", "x" . (x1 + (w1 - 60)) . " yp w60 h23 Range32-131072")

		editorGui.SetFont("Italic", "Arial")
		widget12 := editorGui.Add("Checkbox", "x" . x0 . " yp+36 w105 h23 vviSpeakerCheck", translate("Rephrasing"))
		widget12.OnEvent("Click", (*) => this.updateState())
		widget13 := editorGui.Add("Text", "x100 yp+11 w" . (width + 8 - 100) . " 0x10 W:Grow")
		editorGui.SetFont("Norm", "Arial")

		widget14 := editorGui.Add("Text", "x" . x0 . " yp+20 w105 h23 +0x200", translate("Activation"))
		widget15 := editorGui.Add("Edit", "x" . x1 . " yp w60 Number Limit3 vviSpeakerProbabilityEdit")
		widget15.OnEvent("Change", validatePercentage.Bind("viSpeakerProbabilityEdit"))
		widget16 := editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-100")
		widget17 := editorGui.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200", translate("%"))

		widget40 := editorGui.Add("Button", "x" . (width + 8 - 100) . " yp w100 h23 X:Move vviSpeakerInstructionsButton", translate("Instructions..."))
		widget40.OnEvent("Click", editInstructions.Bind("Speaker", translate("Rephrasing")))

		widget18 := editorGui.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200", translate("Creativity"))
		widget19 := editorGui.Add("Edit", "x" . x1 . " yp w60 Number Limit3 vviSpeakerTemperatureEdit")
		widget19.OnEvent("Change", validatePercentage.Bind("viSpeakerTemperatureEdit"))
		widget20 := editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-100")
		widget21 := editorGui.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200", translate("%"))

		editorGui.SetFont("Italic", "Arial")
		widget22 := editorGui.Add("Checkbox", "x" . x0 . " yp+36 w105 h23 vviListenerCheck", translate("Understanding"))
		widget22.OnEvent("Click", (*) => this.updateState())
		widget23 := editorGui.Add("Text", "x100 yp+11 w" . (width + 8 - 100) . " 0x10 W:Grow")
		editorGui.SetFont("Norm", "Arial")

		widget24 := editorGui.Add("Text", "x" . x0 . " yp+20 w105 h23 +0x200", translate("Activation"))
		widget25:= editorGui.Add("DropDownList", "x" . x1 . " yp w100 Choose1 vviListenerModeDropDown", collect(["Always", "Unrecognized"], translate))
		widget25.OnEvent("Change", (*) => this.updateState())

		widget41 := editorGui.Add("Button", "x" . (width + 8 - 100) . " yp w100 h23 X:Move vviListenerInstructionsButton", translate("Instructions..."))
		widget41.OnEvent("Click", editInstructions.Bind("Listener", translate("Understanding")))

		widget26 := editorGui.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200", translate("Creativity"))
		widget27 := editorGui.Add("Edit", "x" . x1 . " yp w60 Number Limit3 vviListenerTemperatureEdit")
		widget27.OnEvent("Change", validatePercentage.Bind("viListenerTemperatureEdit"))
		widget28 := editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-100")
		widget29 := editorGui.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200", translate("%"))

		editorGui.SetFont("Italic", "Arial")
		widget30 := editorGui.Add("Checkbox", "x" . x0 . " yp+36 w105 h23 vviConversationCheck", translate("Conversation"))
		widget30.OnEvent("Click", (*) => this.updateState())
		widget31 := editorGui.Add("Text", "x100 yp+11 w" . (width + 8 - 100) . " 0x10 W:Grow")
		editorGui.SetFont("Norm", "Arial")

		widget32 := editorGui.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200", translate("Memory"))
		widget33 := editorGui.Add("Edit", "x" . x1 . " yp w60 h23 Number Limit2 vviConversationMaxHistoryEdit")
		widget34 := editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range1-10")
		widget35 := editorGui.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200", translate("Conversations"))

		widget42 := editorGui.Add("Button", "x" . (width + 8 - 100) . " yp w100 h23 X:Move vviConversationInstructionsButton", translate("Instructions..."))
		widget42.OnEvent("Click", editInstructions.Bind("Conversation", translate("Conversation")))

		widget36 := editorGui.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200", translate("Creativity"))
		widget37 := editorGui.Add("Edit", "x" . x1 . " yp w60 Number Limit3 vviConversationTemperatureEdit")
		widget37.OnEvent("Change", validatePercentage.Bind("viConversationTemperatureEdit"))
		widget38 := editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-100")
		widget39 := editorGui.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200", translate("%"))

		widget40 := editorGui.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200", translate("Actions"))
		widget41 := editorGui.Add("DropDownList", "x" . x1 . " yp w60 vviConversationActionsDropdown", collect(["No", "Yes"], translate))
		widget41.OnEvent("Change", (*) => this.updateState())
		widget42 := editorGui.Add("Button", "x" . (x1 + 61) . " yp-1 w23 h23 X:Move Center +0x200 vviConversationIEditActionsButton")
		widget42.OnEvent("Click", editActions)
		setButtonIcon(widget42, kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")

		editorGui.Add("Text", "x8 yp+35 w468 W:Grow 0x10")

		editorGui.Add("Button", "x160 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", (*) => this.iResult := kOk)
		editorGui.Add("Button", "x246 yp w80 h23", translate("&Cancel")).OnEvent("Click", (*) => this.iResult := kCancel)
	}

	loadModels(provider, serviceURL := false, serviceKey := false, model := false) {
		local connector, index, models

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

		this.Control["viModelDropDown"].Delete()
		this.Control["viModelDropDown"].Add(models)

		if model
			this.Control["viModelDropDown"].Choose(inList(models, model))
		else
			this.Control["viModelDropDown"].Choose((models.Length > 0) ? 1 : 0)
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

		static defaults := CaseInsenseWeakMap("ServiceURL", false, "Model", "", "MaxTokens", 2048
											, "Speaker", true, "SpeakerTemperature", 0.5, "SpeakerProbability", 0.5
											, "Listener", false, "ListenerMode", "Unknown", "ListenerTemperature", 0.5
											, "Conversation", false, "ConversationMaxHistory", 3, "ConversationTemperature", 0.5
											, "ConversationActions", false)

		super.loadFromConfiguration(configuration)

		service := getMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Service", false)

		this.iCurrentProvider := (service ? string2Values("|", service)[1] : false)

		for ignore, provider in this.Providers {
			providerConfiguration := CaseInsenseMap()

			if (provider = this.iCurrentProvider) {
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
				}
				else {
					providerConfiguration["ServiceURL"] := string2Values("|", service)[2]
					providerConfiguration["ServiceKey"] := string2Values("|", service)[3]
				}
			}
			else {
				for ignore, setting in ["ServiceURL", "ServiceKey", "Model", "MaxTokens"]
					providerConfiguration[setting] := getMultiMapValue(configuration, "Conversation Booster", provider . "." . setting, defaults[setting])

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

			this.iProviderConfigurations[provider] := providerConfiguration
		}
	}

	saveToConfiguration(configuration) {
		local provider, value

		super.saveToConfiguration(configuration)

		this.saveProviderConfiguration()

		addMultiMapValues(configuration, this.iInstructions)

		this.normalizeConfiguration(configuration)

		for ignore, provider in this.Providers {
			providerConfiguration := this.iProviderConfigurations[provider]

			for ignore, setting in ["ServiceURL", "ServiceKey", "Model", "MaxTokens"]
				setMultiMapValue(configuration, "Conversation Booster", provider . "." . setting, providerConfiguration[setting])

			for ignore, setting in ["Speaker", "SpeakerProbability", "SpeakerTemperature"
								  , "Listener", "ListenerMode", "ListenerTemperature"
								  , "Conversation", "ConversationMaxHistory", "ConversationTemperature", "ConversationActions"] {
				setMultiMapValue(configuration, "Conversation Booster", provider . "." . setting, providerConfiguration[setting])

				if (provider = this.iCurrentProvider)
					setMultiMapValue(configuration, "Conversation Booster", this.Assistant . "." . setting, providerConfiguration[setting])
			}
		}

		provider := this.iCurrentProvider

		if provider {
			providerConfiguration := this.iProviderConfigurations[provider]

			for ignore, setting in ["Model", "MaxTokens"]
				setMultiMapValue(configuration, "Conversation Booster", this.Assistant . "." . setting, providerConfiguration[setting])

			if (provider = "LLM Runtime")
				setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Service", provider)
			else
				setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Service"
											  , values2String("|", provider, Trim(providerConfiguration["ServiceURL"])
																		   , Trim(providerConfiguration["ServiceKey"])))
		}
		else {
			setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Model", false)
			setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".Service", false)
			setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".SpeakerProbability", false)
			setMultiMapValue(configuration, "Conversation Booster", this.Assistant . ".SpeakerTemperature", false)
		}
	}

	loadProviderConfiguration(provider) {
		local configuration

		this.Control["viProviderDropDown"].Choose(inList(this.Providers, provider) + 1)

		if (this.Control["viProviderDropDown"].Value = 1) {
			this.iCurrentProvider := false

			for ignore, setting in ["ServiceURL", "ServiceKey", "MaxTokens", "SpeakerProbability", "SpeakerTemperature", "ListenerTemperature", "ConversationMaxHistory", "ConversationTemperature", "ConversationActions"]
				this.Control["vi" . setting . "Edit"].Text := ""

			for ignore, setting in ["Speaker", "Listener", "Conversation"]
				this.Control["vi" . setting . "Check"].Value := 0

			this.Control["viListenerModeDropDown"].Choose(0)
		}
		else {
			this.iCurrentProvider := this.Control["viProviderDropDown"].Text

			if this.iProviderConfigurations.Has(this.iCurrentProvider)
				configuration := this.iProviderConfigurations[this.iCurrentProvider]

			for ignore, setting in ["ServiceURL", "ServiceKey", "MaxTokens"]
				this.Control["vi" . setting . "Edit"].Text := configuration[setting]

			if ((provider = "GPT4All") && (Trim(this.Control["viServiceKeyEdit"].Text) = ""))
				this.Control["viServiceKeyEdit"].Text := "Any text will do the job"

			if ((provider = "Ollama") && (Trim(this.Control["viServiceKeyEdit"].Text) = ""))
				this.Control["viServiceKeyEdit"].Text := "Ollama"

			for ignore, setting in ["Speaker", "Listener", "Conversation"]
				this.Control["vi" . setting . "Check"].Value := configuration[setting]

			this.Control["viSpeakerProbabilityEdit"].Text := (isNumber(configuration["SpeakerProbability"]) ? Round(configuration["SpeakerProbability"] * 100) : "")
			this.Control["viSpeakerTemperatureEdit"].Text := (isNumber(configuration["SpeakerTemperature"]) ? Round(configuration["SpeakerTemperature"] * 100) : "")

			this.Control["viListenerModeDropDown"].Choose(2 - (configuration["ListenerMode"] = "Always"))
			this.Control["viListenerTemperatureEdit"].Text := (isNumber(configuration["ListenerTemperature"]) ? Round(configuration["ListenerTemperature"] * 100) : "")

			this.Control["viConversationMaxHistoryEdit"].Text := configuration["ConversationMaxHistory"]
			this.Control["viConversationTemperatureEdit"].Text := (isNumber(configuration["ConversationTemperature"]) ? Round(configuration["ConversationTemperature"] * 100) : "")
			this.Control["viConversationActionsDropDown"].Choose(1 + (configuration["ConversationActions"] != false))
		}

		if this.iCurrentProvider
			this.loadModels(this.iCurrentProvider, configuration["ServiceURL"]
												 , configuration["ServiceKey"]
												 , configuration["Model"])
		else
			this.loadModels(false)
	}

	saveProviderConfiguration() {
		if this.iCurrentProvider {
			local providerConfiguration := this.iProviderConfigurations[this.iCurrentProvider]
			local value, ignore, setting

			providerConfiguration["ServiceURL"] := Trim(this.Control["viServiceURLEdit"].Text)
			providerConfiguration["ServiceKey"] := Trim(this.Control["viServiceKeyEdit"].Text)

			value := this.Control["viModelDropDown"].Text

			providerConfiguration["Model"] := ((Trim(value) != "") ? Trim(value) : false)
			providerConfiguration["MaxTokens"] := this.Control["viMaxTokensEdit"].Text

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
				providerConfiguration["ConversationActions"] := (this.Control["viConversationActionsDropDown"].Value = 2)
			}
			else {
				providerConfiguration["Conversation"] := false
				providerConfiguration["ConversationMaxHistory"] := ""
				providerConfiguration["ConversationTemperature"] := ""
				providerConfiguration["ConversationActions"] := false
			}
		}
	}

	loadConfigurator(configuration, simulators := false) {
		this.loadFromConfiguration(configuration)

		this.loadProviderConfiguration(this.iCurrentProvider)

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
		local ignore, setting

		if this.iCurrentProvider {
			this.Control["viServiceURLEdit"].Enabled := (this.Control["viProviderDropDown"].Text != "LLM Runtime")
			this.Control["viServiceKeyEdit"].Enabled := !inList(["GPT4All", "Ollama", "LLM Runtime"], this.Control["viProviderDropDown"].Text)

			this.Control["viSpeakerCheck"].Enabled := true
			this.Control["viListenerCheck"].Enabled := true
			this.Control["viConversationCheck"].Enabled := true

			this.Control["viModelDropDown"].Enabled := true
			this.Control["viMaxTokensEdit"].Enabled := true
		}
		else {
			for ignore, setting in ["ServiceURL", "ServiceKey"]
				this.Control["vi" . setting . "Edit"].Enabled := false

			this.Control["viSpeakerCheck"].Enabled := false
			this.Control["viListenerCheck"].Enabled := false
			this.Control["viConversationCheck"].Enabled := false
			this.Control["viSpeakerCheck"].Value := 0
			this.Control["viListenerCheck"].Value := 0
			this.Control["viConversationCheck"].Value := 0

			this.Control["viModelDropDown"].Enabled := false
			this.Control["viMaxTokensEdit"].Enabled := false
		}

		if (this.Control["viSpeakerCheck"].Value = 0) {
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

		if (this.Control["viListenerCheck"].Value = 0) {
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

		if (this.Control["viConversationCheck"].Value = 0) {
			this.Control["viConversationMaxHistoryEdit"].Enabled := false
			this.Control["viConversationTemperatureEdit"].Enabled := false
			this.Control["viConversationActionsDropDown"].Enabled := false
			this.Control["viConversationIEditActionsButton"].Enabled := false
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
				this.Control["viConversationActionsDropDown"].Choose(1)

			this.Control["viConversationInstructionsButton"].Enabled := true
			this.Control["viConversationIEditActionsButton"].Enabled := (this.Control["viConversationActionsDropDown"].Value = 2)
		}
	}

	getOriginalInstruction(language, type, key) {
		return getMultiMapValue(this.getInstructions(type, true), "Conversation Booster", "Instructions." . type . "." . key . "." . language, "")
	}

	getInstructions(type, original := false) {
		local instructions := newMultiMap()
		local key, value, ignore, directory, configuration, language

		for ignore, directory in [kTranslationsDirectory, kUserTranslationsDirectory]
			loop Files (directory . "Conversation Booster.instructions.*") {
				SplitPath A_LoopFilePath, , , &language

				for key, value in getMultiMapValues(readMultiMap(A_LoopFilePath), type . ".Instructions")
					setMultiMapValue(instructions, "Conversation Booster", "Instructions." . type . "." . key . "." . language, value)
			}

		if !original
			for ignore, configuration in [this.Configuration, this.iInstructions]
				for key, value in getMultiMapValues(configuration, "Conversation Booster")
					if (InStr(key, "Instructions." . type) = 1)
						setMultiMapValue(instructions, "Conversation Booster", key, value)

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
			instructions := editInstructions(this, title, this.getInstructions(type), window)

			if instructions
				this.setInstructions(type, instructions)
		}
		finally {
			window.Unblock()
		}
	}

	editActions(assistant) {
		local window := this.Window
		local actions

		window.Block()

		try {
			actions := ActionsEditor(this).editActions(window)
		}
		finally {
			window.Unblock()
		}
	}
}

class ActionsEditor {
	iEditor := false

	iWindow := false
	iResult := false

	iActionsListView := false
	iScriptEditor := false

	iActions := []
	iSelectedAction := false

	Editor {
		Get {
			return this.iEditor
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

	ActionsListView {
		Get {
			return this.iActionsListView
		}
	}

	ScriptEditor {
		Get {
			return this.iScriptEditor
		}
	}

	Actions[key?] {
		Get {
			return (isSet(key) ? this.iActions[key] : this.iActions)
		}

		Set {
			return (isSet(key) ? (this.iActions[key] := value) : (this.iActions := value))
		}
	}

	SelectedAction {
		Get {
			return this.iSelectedAction
		}
	}

	__New(editor) {
		this.iEditor := editor
	}

	createGui() {
		local editorGui

		chooseAction(listView, line, *) {
			this.selectAction(line ? this.Actions[line] : false)
		}

		editorGui := Window({Descriptor: "Actions Editor", Resizeable: true, Options: "0x400000"})

		this.iWindow := editorGui

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "w468 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Actions Editor"))

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Documentation", "x178 YP+20 w128 H:Center Center", translate("Conversation Actions")
					, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#boosting-conversation-with-an-llm")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x8 yp+30 w468 W:Grow 0x10")

		this.iActionsListView := editorGui.Add("ListView", "x16 y+10 w452 h140 W:Grow H:Grow(0.5) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Action", "Description"], translate))
		this.iActionsListView.OnEvent("Click", chooseAction)
		this.iActionsListView.OnEvent("DoubleClick", chooseAction)
		this.iActionsListView.OnEvent("ItemSelect", chooseAction)

		editorGui.SetFont("Norm", "Cascadia Code")

		this.iScriptEditor := editorGui.Add("Edit", "x16 yp+145 w452 h140 T4 W:Grow Y:Move(0.5) H:Grow(0.5)")

		editorGui.Add("Text", "x8 yp+150 w468 Y:Move W:Grow 0x10")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Button", "x160 yp+10 w80 h23 Default X:Move(0.5) Y:Move", translate("Ok")).OnEvent("Click", (*) => this.iResult := kOk)
		editorGui.Add("Button", "x246 yp w80 h23 X:Move(0.5) Y:Move", translate("&Cancel")).OnEvent("Click", (*) => this.iResult := kCancel)

		this.updateState()
	}

	editActions(owner := false) {
		local window, x, y, w, h

		this.createGui()

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		if getWindowPosition("Actions Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Actions Editor", &w, &h)
			window.Resize("Initialize", w, h)

		this.loadActions()

		loop
			Sleep(200)
		until this.iResult

		try {
			if (this.iResult = kOk)
				return this.saveActions()
			else
				return false
		}
		finally {
			window.Destroy()
		}
	}

	updateState() {
		if this.SelectedAction {
			if this.SelectedAction.Builtin
				this.ScriptEditor.Opt("+ReadOnly")
			else
				this.ScriptEditor.Opt("-ReadOnly")
		}
		else {
			this.ScriptEditor.Text := ""
			this.ScriptEditor.Opt("+ReadOnly")
		}

	}

	selectAction(action) {
		if this.SelectedAction
			this.saveAction(this.SelectedAction)

		if action {
			this.iSelectedAction := action

			this.loadAction(action)
		}

		this.updateState()
	}

	loadAction(action) {
		if (action.Type = "Assistant.Rule")
			this.ScriptEditor.Text := FileRead(getFileName(action.Definition, kUserHomeDirectory . "Actions\"
																			, kResourcesDirectory . "Actions\"))
		else
			this.ScriptEditor.Text := ""

		this.updateState()
	}

	saveAction(action) {
	}

	loadActions() {
		local configuration := readMultiMap(kResourcesDirectory . "Actions\" . this.Assistant . ".actions")
		local actions := []
		local active, ignore, type, action, descriptor, parameters

		addMultiMapValues(configuration, readMultiMap(kUserHomeDirectory . "Actions\" . this.Assistant . ".actions"))

		for ignore, type in ["Builtin", "Custom"]
			for action, descriptor in getMultiMapValues(configuration, type) {
				descriptor := string2Values("|", descriptor)

				parameters := []

				loop descriptor[5] {
					parameter := string2Values("|", getMultiMapValue(configuration, "Parameters", ConfigurationItem.descriptor(action, A_Index)))

					parameters.Push({Name: parameter[1], Type: parameter[2], Enumeration: string2Values(",", parameter[3])
								   , Required: parameter[4], Description: parameter[5]})
				}

				this.Actions.Push({Name: action, Type: descriptor[1], Definition: descriptor[2]
								 , Description: descriptor[6], Parameters: parameters, Builtin: (type = "Builtin")
								 , Initialized: descriptor[3], Confirm: descriptor[4]})
			}

		active := string2Values(",", getMultiMapValue(configuration, "Actions", "Active", ""))

		this.ActionsListView.Delete()

		for ignore, action in this.Actions
			this.ActionsListView.Add("", action.Name, action.Description)

		this.ActionsListView.ModifyCol()

		loop this.ActionsListView.GetCount("Col")
			this.ActionsListView.ModifyCol(A_Index, "AutoHdr")
	}

	saveActions() {
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                        Private Functions Section                        ;;;
;;;-------------------------------------------------------------------------;;;

editInstructions(editorOrCommand, title := false, originalInstructions := false, owner := false) {
	local choices, key, value, descriptor, reloadAll

	static editor, instructions, instructionsGui, result, instructionEdit

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

		for key, value in getMultiMapValues(instructions, "Conversation Booster")
			if (reloadAll || (instructionsGui["instructionsDropDown"].Value = A_Index)) {
				descriptor := ConfigurationItem.splitDescriptor(key)

				value := editor.getOriginalInstruction(descriptor[4], descriptor[2], descriptor[3])

				setMultiMapValue(instructions, "Conversation Booster", key, value)

				if (instructionsGui["instructionsDropDown"].Value = A_Index)
					instructionsGui["instructionEdit"].Value := value

				if !reloadAll
					break
			}
	}
	else if (editorOrCommand == "Load") {
		for key, value in getMultiMapValues(instructions, "Conversation Booster")
			if (instructionsGui["instructionsDropDown"].Value = A_Index) {
				instructionsGui["instructionEdit"].Value := value

				break
			}
	}
	else if (editorOrCommand == "Update") {
		for key, value in getMultiMapValues(instructions, "Conversation Booster")
			if (instructionsGui["instructionsDropDown"].Value = A_Index) {
				setMultiMapValue(instructions, "Conversation Booster", key, instructionsGui["instructionEdit"].Value)

				break
			}
	}
	else {
		editor := editorOrCommand
		result := false

		instructions := originalInstructions.Clone()

		instructionsGui := Window({Options: "0x400000"}, title)

		instructionsGui.SetFont("Norm", "Arial")

		choices := []

		for key, value in getMultiMapValues(instructions, "Conversation Booster") {
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