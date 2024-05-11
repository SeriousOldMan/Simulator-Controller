;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Conversation Booster Editor     ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
			return ["OpenAI", "Azure", "GPT4All", "LLM Runtime"]
		}
	}

	Models[provider] {
		Get {
			if (provider = "OpenAI")
				return ["GPT 3.5 turbo", "GPT 4", "GPT 4 32k", "GPT 4 turbo"]
			else if (provider = "Azure")
				return ["GPT 3.5", "GPT 3.5 turbo", "GPT 4", "GPT 4 32k"]
			else
				return []
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

		editorGui := Window({Descriptor: "Booster Editor", Options: "0x400000"}, "")

		this.iWindow := editorGui

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "w468 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Booster Editor"))

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Documentation", "x178 YP+20 w128 H:Center Center", translate("Conversation Booster")
					, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control")

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

		widget6 := editorGui.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200", translate("Service Key"))
		widget7 := editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h23 vviServiceKeyEdit")

		widget8 := editorGui.Add("Text", "x" . x0 . " yp+30 w105 h23 +0x200", translate("Model / # Tokens"))
		widget9 := editorGui.Add("ComboBox", "x" . x1 . " yp w" . (w1 - 64) . " vviModelDropDown")
		widget10 := editorGui.Add("Edit", "x" . (x1 + (w1 - 60)) . " yp-1 w60 h23 Number vviMaxTokensEdit")
		widget10.OnEvent("Change", validateTokens)
		widget11 := editorGui.Add("UpDown", "x" . (x1 + (w1 - 60)) . " yp w60 h23 Range32-2048")

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

		widget36 := editorGui.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200", translate("Creativity"))
		widget37 := editorGui.Add("Edit", "x" . x1 . " yp w60 Number Limit3 vviConversationTemperatureEdit")
		widget37.OnEvent("Change", validatePercentage.Bind("viConversationTemperatureEdit"))
		widget38 := editorGui.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-100")
		widget39 := editorGui.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200", translate("%"))

		editorGui.Add("Text", "x8 yp+35 w468 W:Grow 0x10")

		editorGui.Add("Button", "x160 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", (*) => this.iResult := kOk)
		editorGui.Add("Button", "x246 yp w80 h23", translate("&Cancel")).OnEvent("Click", (*) => this.iResult := kCancel)
	}

	loadModels(provider, model) {
		local index

		this.Control["viModelDropDown"].Delete()

		if provider
			this.Control["viModelDropDown"].Add(this.Models[provider])

		if model {
			index := inList(this.Models[provider], model)

			if !index {
				this.Control["viModelDropDown"].Add([model])
				this.Control["viModelDropDown"].Choose(this.Models[provider].Length + 1)
			}
			else
				this.Control["viModelDropDown"].Choose(index)
		}
		else if provider
			this.Control["viModelDropDown"].Choose(inList(this.Models[provider], "GPT 3.5 turbo"))
	}

	loadFromConfiguration(configuration) {
		local service, ignore, provider, setting, providerConfiguration

		static defaults := CaseInsenseWeakMap("ServiceURL", false, "Model", "", "MaxTokens", 1024
											, "Speaker", true, "SpeakerTemperature", 0.5, "SpeakerProbability", 0.5
											, "Listener", false, "ListenerMode", "Unknown", "ListenerTemperature", 0.5
											, "Conversation", false, "ConversationMaxHistory", 3, "ConversationTemperature", 0.5)

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

				if !providerConfiguration["ServiceURL"]
					switch provider, false {
						case "OpenAI":
							providerConfiguration["ServiceURL"] := "https://api.openai.com/v1/chat/completions"
						case "Azure":
							providerConfiguration["ServiceURL"] := "__YOUR_AZURE_OPENAI_ENDPOINT__/openai/deployments/%model%/chat/completions?api-version=2023-05-15"
						case "GPT4All":
							providerConfiguration["ServiceURL"] := "http://localhost:4891/v1"
							providerConfiguration["ServiceKey"] := "Any text will do the job"
						case "LLM Runtime":
							providerConfiguration["ServiceURL"] := ""
							providerConfiguration["ServiceKey"] := ""
					}

				if ((providerConfiguration["Model"] = "") && inList(this.Models[provider], "GPT 3.5 turbo"))
					providerConfiguration["Model"] := "GPT 3.5 turbo"

				for ignore, setting in ["Speaker", "SpeakerProbability", "SpeakerTemperature"
									  , "Listener", "ListenerMode", "ListenerTemperature"
									  , "Conversation", "ConversationMaxHistory", "ConversationTemperature"]
					providerConfiguration[setting] := getMultiMapValue(configuration, "Conversation Booster", provider . "." . setting, defaults[setting])
			}

			this.iProviderConfigurations[provider] := providerConfiguration
		}
	}

	saveToConfiguration(configuration) {
		local provider, value

		super.saveToConfiguration(configuration)

		this.saveProviderConfiguration()

		for ignore, provider in this.Providers {
			providerConfiguration := this.iProviderConfigurations[provider]

			for ignore, setting in ["ServiceURL", "ServiceKey", "Model", "MaxTokens"]
				setMultiMapValue(configuration, "Conversation Booster", provider . "." . setting, providerConfiguration[setting])

			for ignore, setting in ["Speaker", "SpeakerProbability", "SpeakerTemperature"
								  , "Listener", "ListenerMode", "ListenerTemperature"
								  , "Conversation", "ConversationMaxHistory", "ConversationTemperature"] {
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

			for ignore, setting in ["ServiceURL", "ServiceKey", "MaxTokens", "SpeakerProbability", "SpeakerTemperature", "ListenerTemperature", "ConversationMaxHistory", "ConversationTemperature"]
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

			if ((provider = "GPT4All") && (Trim(this.Control["viServiceKeyEdit"].Text) = "")
									   && (Trim(this.Control["viServiceURLEdit"].Text) = "http://localhost:4891/v1"))
				this.Control["viServiceKeyEdit"].Text := "Any text will do the job"

			for ignore, setting in ["Speaker", "Listener", "Conversation"]
				this.Control["vi" . setting . "Check"].Value := configuration[setting]

			this.Control["viSpeakerProbabilityEdit"].Text := (isNumber(configuration["SpeakerProbability"]) ? Round(configuration["SpeakerProbability"] * 100) : "")
			this.Control["viSpeakerTemperatureEdit"].Text := (isNumber(configuration["SpeakerTemperature"]) ? Round(configuration["SpeakerTemperature"] * 100) : "")

			this.Control["viListenerModeDropDown"].Choose(2 - (configuration["ListenerMode"] = "Always"))
			this.Control["viListenerTemperatureEdit"].Text := (isNumber(configuration["ListenerTemperature"]) ? Round(configuration["ListenerTemperature"] * 100) : "")

			this.Control["viConversationMaxHistoryEdit"].Text := configuration["ConversationMaxHistory"]
			this.Control["viConversationTemperatureEdit"].Text := (isNumber(configuration["ConversationTemperature"]) ? Round(configuration["ConversationTemperature"] * 100) : "")
		}

		this.loadModels(this.iCurrentProvider, (this.iCurrentProvider ? configuration["Model"] : false))
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
			}
			else {
				providerConfiguration["Conversation"] := false
				providerConfiguration["ConversationMaxHistory"] := ""
				providerConfiguration["ConversationTemperature"] := ""
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
			this.Control["viServiceKeyEdit"].Enabled := (this.Control["viProviderDropDown"].Text != "LLM Runtime")

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
		}
		else {
			this.Control["viSpeakerProbabilityEdit"].Enabled := true
			this.Control["viSpeakerTemperatureEdit"].Enabled := true

			if (this.Control["viSpeakerProbabilityEdit"].Text = "")
				this.Control["viSpeakerProbabilityEdit"].Text := 50

			if (this.Control["viSpeakerTemperatureEdit"].Text = "")
				this.Control["viSpeakerTemperatureEdit"].Text := 50
		}

		if (this.Control["viListenerCheck"].Value = 0) {
			this.Control["viListenerModeDropDown"].Enabled := false
			this.Control["viListenerTemperatureEdit"].Enabled := false
			this.Control["viListenerModeDropDown"].Choose(0)
			this.Control["viListenerTemperatureEdit"].Text := ""
		}
		else {
			this.Control["viListenerModeDropDown"].Enabled := true
			this.Control["viListenerTemperatureEdit"].Enabled := true

			if (this.Control["viListenerModeDropDown"].Value = 0)
				this.Control["viListenerModeDropDown"].Choose(2)

			if (this.Control["viListenerTemperatureEdit"].Text = "")
				this.Control["viListenerTemperatureEdit"].Text := 50
		}

		if (this.Control["viConversationCheck"].Value = 0) {
			this.Control["viConversationMaxHistoryEdit"].Enabled := false
			this.Control["viConversationTemperatureEdit"].Enabled := false
			this.Control["viConversationMaxHistoryEdit"].Text := ""
			this.Control["viConversationTemperatureEdit"].Text := ""
		}
		else {
			this.Control["viConversationMaxHistoryEdit"].Enabled := true
			this.Control["viConversationTemperatureEdit"].Enabled := true

			if (this.Control["viConversationMaxHistoryEdit"].Text = "")
				this.Control["viConversationMaxHistoryEdit"].Text := 3

			if (this.Control["viConversationTemperatureEdit"].Text = "")
				this.Control["viConversationTemperatureEdit"].Text := 50
		}
	}
}