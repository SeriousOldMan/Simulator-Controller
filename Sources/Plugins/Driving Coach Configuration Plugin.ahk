;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Driving Coach Configuration   ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; DrivingCoachConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class DrivingCoachConfigurator extends ConfiguratorPanel {
	iProviderConfigurations := CaseInsenseMap()
	iCurrentProvider := false

	Providers {
		Get {
			return ["OpenAI", "Azure", "GPT4All", "LLM Runtime"]
		}
	}

	Models[provider] {
		Get {
			if (provider = "OpenAI")
				return ["GPT 3.5 turbo 1106", "GPT 4", "GPT 4 32k", "GPT 4 1106 preview"]
			else if (provider = "Azure")
				return ["GPT 3.5", "GPT 3.5 turbo", "GPT 4", "GPT 4 32k"]
			else
				return []
		}
	}

	Instructions[qualified := true] {
		Get {
			if qualified
				return ["Instructions.Character", "Instructions.Simulation", "Instructions.Session", "Instructions.Stint", "Instructions.Handling"]
			else
				return ["Character", "Simulation", "Session", "Stint", "Handling"]
		}
	}

	__New(editor, configuration := false) {
		this.Editor := editor

		super.__New(configuration)

		DrivingCoachConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local x0, x1, x2, x3, x4, x5, x6, w1, w2, w3, w4, lineX, lineW

		validateTemperature(*) {
			local field := this.Control["dcTemperatureEdit"]
			local value := field.Text

			if (!isInteger(value) || (value < 0) || (value > 100)) {
				field.Text := (field.HasProp("ValidText") ? field.ValidText : "")

				loop 10
					SendInput("{Right}")
			}
			else
				field.ValidText := field.Text
		}

		validateTokens(*) {
			local field := this.Control["dcMaxTokensEdit"]
			local value := field.Text

			if (!isInteger(value) || (value < 32)) {
				field.Text := (field.HasProp("ValidText") ? field.ValidText : "200")

				loop 10
					SendInput("{Right}")
			}
			else
				field.ValidText := field.Text
		}

		chooseConversationsPath(*) {
			local directory, translator

			translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

			OnMessage(0x44, translator)
			directory := withBlockedWindows(DirSelect, "*" . window["dcConversationsPathEdit"].Text, 0, translate("Select Conversations Folder..."))
			OnMessage(0x44, translator, 0)

			if (directory != "")
				window["dcConversationsPathEdit"].Text := directory
		}

		chooseProvider(*) {
			this.saveProviderConfiguration()

			this.loadProviderConfiguration(window["dcProviderDropDown"].Text)

			this.updateState()
		}

		chooseInstructions(*) {
			local value := this.Value[this.Instructions[true][window["dcInstructionsDropDown"].Value]]

			window["dcInstructionsEdit"].Value := ((value != false) ? value : "")

			this.updateState()
		}

		updateInstructions(*) {
			this.Value[this.Instructions[true][window["dcInstructionsDropDown"].Value]] := ((Trim(window["dcInstructionsEdit"].Value) != "") ? window["dcInstructionsEdit"].Value : false)
		}

		reloadInstructions(*) {
			local chosenSetting := this.Instructions[true][window["dcInstructionsDropDown"].Value]
			local setting, oldValue

			for ignore, setting in (GetKeyState("Ctrl", "P") ? this.Instructions[true] : [chosenSetting]) {
				oldValue := this.Value[setting]

				this.Value[setting] := ""

				this.initializeInstructions(this.iCurrentProvider, window["dcModelDropDown"].text, setting, true)

				if (setting = chosenSetting)
					window["dcInstructionsEdit"].Value := ((this.Value[setting] != false) ? this.Value[setting] : "")
				/*
				else
					this.Value[setting] := oldValue
				*/
			}
		}

		window.SetFont("Norm", "Arial")

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

		widget1 := window.Add("Text", "x" . x0 . " y" . y . " w160 h23 +0x200 Hidden", translate("Conversations Folder"))
		widget2 := window.Add("Edit", "x" . x1 . " yp w" . w2 . " h21 W:Grow VdcConversationsPathEdit Hidden")
		widget3 := window.Add("Button", "x" . x4 . " yp-1 w23 h23 X:Move Hidden", translate("..."))
		widget3.OnEvent("Click", chooseConversationsPath)

		window.SetFont("Italic", "Arial")
		widget4 := window.Add("Text", "x" . x0 . " yp+40 w105 h23 Hidden", translate("Service "))
		widget5 := window.Add("Text", "x100 yp+7 w" . (width + 8 - 100) . " 0x10 W:Grow Hidden")
		window.SetFont("Norm", "Arial")

		widget6 := window.Add("Text", "x" . x0 . " yp+20 w105 h23 +0x200 Hidden", translate("Provider / URL"))

		widget7 := window.Add("DropDownList", "x" . x1 . " yp w100 Choose1 vdcProviderDropDown Hidden", this.Providers)
		widget7.OnEvent("Change", chooseProvider)

		widget8 := window.Add("Edit", "x" . (x1 + 102) . " yp w" . (w1 - 102) . " h23 vdcServiceURLEdit Hidden")

		widget9 := window.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200 Hidden", translate("Service Key"))
		widget10 := window.Add("Edit", "x" . x1 . " yp w" . w1 . " h23 vdcServiceKeyEdit Hidden")

		widget11 := window.Add("Text", "x" . x0 . " yp+30 w105 h23 +0x200 Hidden", translate("Model / # Tokens"))
		widget12 := window.Add("ComboBox", "x" . x1 . " yp w" . (w1 - 64) . " vdcModelDropDown Hidden")
		widget13 := window.Add("Edit", "x" . (x1 + (w1 - 60)) . " yp-1 w60 h23 Number vdcMaxTokensEdit Hidden")
		widget13.OnEvent("Change", validateTokens)
		widget14 := window.Add("UpDown", "x" . (x1 + (w1 - 60)) . " yp w60 h23 Range32-2048 Hidden")

		window.SetFont("Italic", "Arial")
		widget15 := window.Add("Text", "x" . x0 . " yp+40 w105 h23 Hidden", translate("Personality"))
		widget16 := window.Add("Text", "x100 yp+7 w" . (width + 8 - 100) . " 0x10 W:Grow Hidden")
		window.SetFont("Norm", "Arial")

		widget17 := window.Add("Text", "x" . x0 . " yp+20 w105 h23 +0x200 Hidden", translate("Creativity"))
		widget18 := window.Add("Edit", "x" . x1 . " yp w60 Number Limit3 vdcTemperatureEdit Hidden")
		widget18.OnEvent("Change", validateTemperature)
		widget19 := window.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-100 Hidden")
		widget20 := window.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200 Hidden", translate("%"))

		widget21 := window.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200 Hidden", translate("Memory"))
		widget22 := window.Add("Edit", "x" . x1 . " yp w60 h23 Number Limit2 vdcMaxHistoryEdit Hidden")
		widget23 := window.Add("UpDown", "x" . x1 . " yp w60 h23 Range1-10 Hidden")
		widget24 := window.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200 Hidden", translate("Conversations"))

		widget25 := window.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200 Hidden", translate("Confirmation"))
		widget26 := window.Add("DropDownList", "x" . x1 . " yp w60 Choose1 vdcConfirmationDropDown Hidden", collect(["Yes", "No"], translate))

		widget27 := window.Add("Text", "x" . x0 . " yp+24 w105 h23 +0x200 Hidden", translate("Instructions"))

		widget28 := window.Add("DropDownList", "x" . x1 . " yp w120 vdcInstructionsDropDown Hidden", collect(this.Instructions[false], translate))
		widget28.OnEvent("Change", chooseInstructions)

		if (StrSplit(A_ScriptName, ".")[1] = "Simulator Configuration")
			height := 140
		else
			height := 65

		widget29 := window.Add("Edit", "x" . x1 . " yp+24 w" . w1 . " h" . height . " Multi H:Grow W:Grow vdcInstructionsEdit Hidden")
		widget29.OnEvent("Change", updateInstructions)

		widget30 := window.Add("Button", "x" . (x1 + w1 - 23) . " yp-25 w23 h23 X:Move Hidden")
		widget30.OnEvent("Click", reloadInstructions)
		setButtonIcon(widget30, kIconsDirectory . "Renew.ico", 1)

		loop 30
			editor.registerWidget(this, widget%A_Index%)
	}

	loadModels(provider, model) {
		local index

		this.Control["dcModelDropDown"].Delete()
		this.Control["dcModelDropDown"].Add(this.Models[provider])

		if model {
			index := inList(this.Models[provider], model)

			if !index {
				this.Control["dcModelDropDown"].Add([model])
				this.Control["dcModelDropDown"].Choose(this.Models[provider].Length + 1)
			}
			else
				this.Control["dcModelDropDown"].Choose(index)
		}
		else
			this.Control["dcModelDropDown"].Choose(inList(this.Models[provider], "GPT 3.5 turbo 1106"))
	}

	initializeInstructions(provider, model, setting, edit := false) {
		local providerConfiguration := this.iProviderConfigurations[provider]
		local language, value, instructions

		static templates := false

		if !templates {
			templates := CaseInsenseMap()

			for code, language in availableLanguages() {
				fileName := getFileName("Driving Coach.instructions." . code, kUserTranslationsDirectory, kTranslationsDirectory)

				if FileExist(fileName)
					templates[code] := readMultiMap(fileName)
			}
		}

		value := (edit ? this.Value[setting] : providerConfiguration[setting])

		if (value = "") {
			if isSet(SetupWizard)
				language := SetupWizard.Instance.getModuleValue("Driving Coach", "Language", getLanguage())
			else if isSet(VoiceControlConfigurator)
				language := VoiceControlConfigurator.Instance.getCurrentLanguage()
			else
				language := getMultiMapValue(kSimulatorConfiguration, "Voice Control", "Language", getLanguage())

			if edit
				this.Value[setting] := getMultiMapValue(templates[templates.Has(language) ? language : "EN"], "Instructions", StrReplace(setting, "Instructions.", ""))
			else
				providerConfiguration[setting] := getMultiMapValue(templates[templates.Has(language) ? language : "EN"], "Instructions", StrReplace(setting, "Instructions.", ""))
		}
	}

	loadFromConfiguration(configuration) {
		local service, ignore, provider, setting, providerConfiguration

		static defaults := CaseInsenseWeakMap("ServiceURL", false, "Model", false, "MaxTokens", 512
											, "MaxHistory", 5, "Temperature", 0.5, "Confirmation", true)

		super.loadFromConfiguration(configuration)

		this.Value["ConversationsPath"] := getMultiMapValue(configuration, "Driving Coach Conversations", "Archive", "")

		service := getMultiMapValue(configuration, "Driving Coach Service", "Service", false)

		if !service
			this.iCurrentProvider := "OpenAI"
		else
			this.iCurrentProvider := string2Values("|", service)[1]

		for ignore, provider in this.Providers {
			providerConfiguration := CaseInsenseMap()

			for ignore, setting in ["ServiceURL", "ServiceKey", "Model", "MaxTokens"]
				providerConfiguration[setting] := getMultiMapValue(configuration, "Driving Coach Service", provider . "." . setting, defaults[setting])

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

			if ((providerConfiguration["Model"] = "") && inList(this.Models[provider], "GPT 3.5 turbo 1106"))
				providerConfiguration["Model"] := "GPT 3.5 turbo 1106"

			for ignore, setting in concatenate(["Temperature", "MaxHistory", "Confirmation"], this.Instructions)
				if getMultiMapValue(configuration, "Driving Coach Personality", provider . "." . setting . ".Active", true)
					providerConfiguration[setting] := getMultiMapValue(configuration, "Driving Coach Personality", provider . "." . setting, defaults[setting])
				else
					providerConfiguration[setting] := false

			this.iProviderConfigurations[provider] := providerConfiguration

			for ignore, setting in this.Instructions
				this.initializeInstructions(provider, providerConfiguration["Model"], setting)
		}
	}

	saveToConfiguration(configuration) {
		local provider, value

		super.saveToConfiguration(configuration)

		value := this.Control["dcConversationsPathEdit"].Text

		setMultiMapValue(configuration, "Driving Coach Conversations", "Archive", (Trim(value) != "") ? Trim(value) : false)

		this.saveProviderConfiguration()

		for ignore, provider in this.Providers {
			providerConfiguration := this.iProviderConfigurations[provider]

			for ignore, setting in ["ServiceURL", "ServiceKey", "Model", "MaxTokens"]
				setMultiMapValue(configuration, "Driving Coach Service", provider . "." . setting, providerConfiguration[setting])

			for ignore, setting in ["Temperature", "MaxHistory", "Confirmation"] {
				setMultiMapValue(configuration, "Driving Coach Personality", provider . "." . setting, providerConfiguration[setting])

				if (provider = this.iCurrentProvider)
					setMultiMapValue(configuration, "Driving Coach Personality", setting, providerConfiguration[setting])
			}

			for ignore, setting in this.Instructions {
				setMultiMapValue(configuration, "Driving Coach Personality", provider . "." . setting, (providerConfiguration[setting] != false) ? providerConfiguration[setting] : "")
				setMultiMapValue(configuration, "Driving Coach Personality", provider . "." . setting . ".Active", (Trim(providerConfiguration[setting]) != false))

				if (provider = this.iCurrentProvider)
					setMultiMapValue(configuration, "Driving Coach Personality", setting, providerConfiguration[setting])
			}
		}

		provider := this.iCurrentProvider
		providerConfiguration := this.iProviderConfigurations[provider]

		for ignore, setting in ["Model", "MaxTokens"]
			setMultiMapValue(configuration, "Driving Coach Service", setting, providerConfiguration[setting])

		if (provider = "LLM Runtime")
			setMultiMapValue(configuration, "Driving Coach Service", "Service", provider)
		else
			setMultiMapValue(configuration, "Driving Coach Service", "Service"
										  , values2String("|", provider, Trim(providerConfiguration["ServiceURL"])
																	   , Trim(providerConfiguration["ServiceKey"])))
	}

	loadProviderConfiguration(provider := false) {
		local configuration

		if provider
			this.Control["dcProviderDropDown"].Choose(inList(this.Providers, provider))

		this.iCurrentProvider := this.Control["dcProviderDropDown"].Text

		if this.iProviderConfigurations.Has(this.iCurrentProvider)
			configuration := this.iProviderConfigurations[this.iCurrentProvider]

		for ignore, setting in ["ServiceURL", "ServiceKey", "MaxTokens", "MaxHistory"]
			this.Control["dc" . setting . "Edit"].Text := configuration[setting]

		if ((provider = "GPT4All") && (Trim(this.Control["dcServiceKeyEdit"].Text) = "")
								   && (Trim(this.Control["dcServiceURLEdit"].Text) = "http://localhost:4891/v1"))
			this.Control["dcServiceKeyEdit"].Text := "Any text will do the job"

		this.Control["dcTemperatureEdit"].Text := Round(configuration["Temperature"] * 100)

		this.Control["dcConfirmationDropDown"].Value := (configuration["Confirmation"] ? 1 : 2)

		this.loadModels(this.iCurrentProvider, configuration["Model"])

		this.Control["dcInstructionsDropDown"].Choose(1)
		this.Control["dcInstructionsEdit"].Value := ((configuration["Instructions.Character"] != false) ? configuration["Instructions.Character"] : "")

		for ignore, setting in this.Instructions
			this.Value[setting] := configuration[setting]
	}

	saveProviderConfiguration() {
		local providerConfiguration := this.iProviderConfigurations[this.iCurrentProvider]
		local value, ignore, setting

		providerConfiguration["ServiceURL"] := Trim(this.Control["dcServiceURLEdit"].Text)
		providerConfiguration["ServiceKey"] := Trim(this.Control["dcServiceKeyEdit"].Text)

		value := this.Control["dcModelDropDown"].Text

		providerConfiguration["Model"] := ((Trim(value) != "") ? Trim(value) : false)
		providerConfiguration["MaxTokens"] := this.Control["dcMaxTokensEdit"].Text

		providerConfiguration["Temperature"] := Round(this.Control["dcTemperatureEdit"].Text / 100, 2)
		providerConfiguration["MaxHistory"] := this.Control["dcMaxHistoryEdit"].Text
		providerConfiguration["Confirmation"] := ((this.Control["dcConfirmationDropDown"].Value = 1) ? true : false)

		for ignore, setting in this.Instructions
			providerConfiguration[Setting] := ((Trim(this.Value[setting]) != "") ? this.Value[setting] : false)
	}

	loadConfigurator(configuration, simulators := false) {
		this.loadFromConfiguration(configuration)

		this.Control["dcConversationsPathEdit"].Text := (this.Value["ConversationsPath"] ? this.Value["ConversationsPath"] : "")

		this.loadProviderConfiguration(this.iCurrentProvider)

		this.updateState()
	}

	show() {
		super.show()

		this.loadConfigurator(this.Configuration)
	}

	updateState() {
		this.Control["dcServiceURLEdit"].Enabled := (this.Control["dcProviderDropDown"].Text != "LLM Runtime")
		this.Control["dcServiceKeyEdit"].Enabled := (this.Control["dcProviderDropDown"].Text != "LLM Runtime")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeDrivingCoachConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Driving Coach"), DrivingCoachConfigurator(editor, editor.Configuration)
								  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-driving-coach")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeDrivingCoachConfigurator()