﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Driving Coach Configuration     ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\LLMConnector.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; DrivingCoachConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class DrivingCoachConfigurator extends ConfiguratorPanel {
	iProviderConfigurations := CaseInsenseMap()
	iCurrentProvider := false

	iTemplates := false

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

	Templates[language?] {
		Get {
			local templates, fileName, code, ignore

			if !this.iTemplates {
				templates := CaseInsenseMap()

				for code, ignore in availableLanguages() {
					fileName := getFileName("Driving Coach.instructions." . code, kTranslationsDirectory)

					if FileExist(fileName) {
						templates[code] := readMultiMap(fileName)

						fileName := getFileName("Driving Coach.instructions." . code, kUserTranslationsDirectory)

						if FileExist(fileName)
							addMultiMapValues(templates[code], readMultiMap(fileName))
					}
					else {
						fileName := getFileName("Driving Coach.instructions." . code, kUserTranslationsDirectory)

						if FileExist(fileName)
							templates[code] := readMultiMap(fileName)
					}
				}

				this.iTemplates := templates
			}

			return (isSet(language) ? this.iTemplates[language] : this.iTemplates)
		}
	}

	Instructions[qualified := true] {
		Get {
			if qualified
				return ["Instructions.Character", "Instructions.Simulation", "Instructions.Session", "Instructions.Stint", "Instructions.Knowledge", "Instructions.Handling", "Instructions.Coaching", "Instructions.Coaching.Lap", "Instructions.Coaching.Corner", "Instructions.Coaching.Corner.Approaching", "Instructions.Coaching.Corner.Problems", "Instructions.Coaching.Corner.Review", "Instructions.Coaching.Reference"]
			else
				return ["Character", "Simulation", "Session", "Stint", "Knowledge", "Handling", "Coaching", "Coaching.Lap", "Coaching.Corner", "Coaching.Corner.Approaching", "Coaching.Corner.Problems", "Coaching.Corner.Review", "Coaching.Reference"]
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

		validateTokens(field, *) {
			local value

			field := this.Control[field]
			value := field.Value

			if (!isInteger(value) || (value < 32)) {
				field.Text := (field.HasProp("ValidText") ? field.ValidText : "200")

				loop 10
					SendInput("{Right}")
			}
			else
				field.ValidText := field.Text
		}

		chooseConversationsPath(*) {
			local directory

			window.Opt("+OwnDialogs")

			OnMessage(0x44, translateSelectCancelButtons)
			directory := withBlockedWindows(FileSelect, "D1" . window["dcConversationsPathEdit"].Text, translate("Select Conversations Folder..."))
			OnMessage(0x44, translateSelectCancelButtons, 0)

			if (directory != "")
				window["dcConversationsPathEdit"].Text := directory
		}

		chooseModelPath(*) {
			local fileName, translator

			window.Opt("+OwnDialogs")

			translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

			OnMessage(0x44, translator)
			fileName := withBlockedWindows(FileSelect, 1, "", translate("Select model file..."), "GGUF (*.GGUF)")
			OnMessage(0x44, translator, 0)

			if (fileName != "")
				window["dcLLMRTModelEdit"].Text := fileName
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

			for ignore, setting in (GetKeyState("Ctrl") ? this.Instructions[true] : [chosenSetting]) {
				oldValue := this.Value[setting]

				this.Value[setting] := ""

				if (this.iCurrentProvider = "LLM Runtime")
					this.initializeInstructions(this.iCurrentProvider, window["dcLLMRTModelEdit"].Text, setting, true)
				else
					this.initializeInstructions(this.iCurrentProvider, window["dcModelDropDown"].Text, setting, true)

				if (setting = chosenSetting)
					window["dcInstructionsEdit"].Value := ((this.Value[setting] != false) ? this.Value[setting] : "")
			}
		}

		loadModels(*) {
			local provider := this.iCurrentProvider
			local configuration

			if provider {
				configuration := this.iProviderConfigurations[provider]

				this.loadModels(provider, this.Control["dcServiceURLEdit"].Text
										, this.Control["dcServiceKeyEdit"].Text
										, this.Control[(provider = "LLM Runtime") ? "dcLLMRTModelEdit"
																				  : "dcModelDropDown"].Text)
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

		widget1 := window.Add("Text", "x" . x0 . " y" . y . " w120 h23 +0x200 Hidden", translate("Conversations Folder"))
		widget2 := window.Add("Edit", "x" . x1 . " yp w" . w2 . " h21 W:Grow VdcConversationsPathEdit Hidden")
		widget3 := window.Add("Button", "x" . x4 . " yp-1 w23 h23 X:Move Hidden", translate("..."))
		widget3.OnEvent("Click", chooseConversationsPath)

		window.SetFont("Italic", "Arial")
		widget4 := window.Add("Text", "x" . x0 . " yp+40 w80 h23 Hidden", translate("Service "))
		widget5 := window.Add("Text", "x105 yp+7 w" . (width + 8 - 105) . " 0x10 W:Grow Hidden")
		window.SetFont("Norm", "Arial")

		widget6 := window.Add("Text", "x" . x0 . " yp+20 w120 h23 +0x200 vdcProviderLabel Hidden", translate("Provider / URL"))

		widget7 := window.Add("DropDownList", "x" . x1 . " yp w100 Choose1 vdcProviderDropDown Hidden", this.Providers)
		widget7.OnEvent("Change", chooseProvider)

		widget8 := window.Add("Edit", "x" . (x1 + 102) . " yp w" . (w1 - 102) . " h23 W:Grow(0.3) vdcServiceURLEdit Hidden")
		widget8.OnEvent("Change", loadModels)

		widget9 := window.Add("Text", "x" . x0 . " yp+24 w120 h23 +0x200 Section Hidden vdcServiceKeyLabel", translate("Service Key"))
		widget10 := window.Add("Edit", "x" . x1 . " yp w" . w1 . " h23 W:Grow(0.3) Password vdcServiceKeyEdit Hidden")
		widget10.OnEvent("Change", loadModels)

		widget11 := window.Add("Text", "x" . x0 . " yp+30 w120 h23 +0x200 vdcModelLabel Hidden", translate("Model / # Tokens"))
		widget12 := window.Add("ComboBox", "x" . x1 . " yp w" . (w1 - 64) . " W:Grow(0.3) vdcModelDropDown Hidden")
		widget13 := window.Add("Edit", "x" . (x1 + (w1 - 60)) . " yp-1 w60 h23 X:Move(0.3) Number vdcMaxTokensEdit Hidden")
		widget13.OnEvent("Change", validateTokens.Bind("dcMaxTokensEdit"))
		widget14 := window.Add("UpDown", "x" . (x1 + (w1 - 60)) . " yp w60 h23 0x80 X:Move(0.3) Range32-131072 vdcMaxTokensRange Hidden")

		widget38 := window.Add("Text", "x" . x0 . " ys+5 w120 h23 +0x200 vdcLLMRTModelLabel Hidden", translate("Model"))
		widget31 := window.Add("Edit", "x" . x1 . " yp w" . (w1 - 24) . " W:Grow(0.3) vdcLLMRTModelEdit Hidden")
		widget32 := window.Add("Button", "x" . (x1 + (w1 - 23)) . " yp h23 w23 X:Move(0.3) vdcLLMRTModelButton Hidden", translate("..."))
		widget32.OnEvent("Click", chooseModelPath)

		widget33 := window.Add("Text", "x" . x0 . " yp+24 w120 h23 +0x200 vdcLLMRTTokensLabel Hidden", translate("# Tokens / # GPULayers"))
		widget34 := window.Add("Edit", "x" . x1 . " yp-1 w60 h23 Number vdcLLMRTMaxTokensEdit Hidden")
		widget34.OnEvent("Change", validateTokens.Bind("dcLLMRTMaxTokensEdit"))
		widget35 := window.Add("UpDown", "x" . x1 . " yp w60 h23 0x80 Range32-131072 vdcLLMRTMaxTokensRange Hidden")
		widget36 := window.Add("Edit", "x" . (x1 + 62) . " yp w60 h23 Number Limit2 vdcLLMRTGPULayersEdit Hidden")
		widget37 := window.Add("UpDown", "x" . (x1 + 62) . " yp w60 h23 Range0-99 vdcLLMRTGPULayersRange Hidden")

		window.SetFont("Italic", "Arial")
		widget15 := window.Add("Text", "x" . x0 . " yp+40 w80 h23 Hidden", translate("Personality"))
		widget16 := window.Add("Text", "x105 yp+7 w" . (width + 8 - 105) . " 0x10 W:Grow Hidden")
		window.SetFont("Norm", "Arial")

		widget17 := window.Add("Text", "x" . x0 . " yp+20 w120 h23 +0x200 Hidden", translate("Creativity"))
		widget18 := window.Add("Edit", "x" . x1 . " yp w60 Number Limit3 vdcTemperatureEdit Hidden")
		widget18.OnEvent("Change", validateTemperature)
		widget19 := window.Add("UpDown", "x" . x1 . " yp w60 h23 Range0-100 Hidden")
		widget20 := window.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200 Hidden", translate("%"))

		widget21 := window.Add("Text", "x" . x0 . " yp+24 w120 h23 +0x200 Hidden", translate("Memory"))
		widget22 := window.Add("Edit", "x" . x1 . " yp w60 h23 Number Limit2 vdcMaxHistoryEdit Hidden")
		widget23 := window.Add("UpDown", "x" . x1 . " yp w60 h23 Range1-10 Hidden")
		widget24 := window.Add("Text", "x" . (x1 + 65) . " yp w100 h23 +0x200 Hidden", translate("Conversations"))

		widget25 := window.Add("Text", "x" . x0 . " yp+24 w120 h23 +0x200 Hidden", translate("Confirmation"))
		widget26 := window.Add("DropDownList", "x" . x1 . " yp w60 Choose1 vdcConfirmationDropDown Hidden", collect(["Yes", "No"], translate))

		widget27 := window.Add("Text", "x" . x0 . " yp+24 w120 h23 +0x200 Hidden", translate("Instructions"))

		widget28 := window.Add("DropDownList", "x" . x1 . " yp w180 vdcInstructionsDropDown Hidden", collect(this.Instructions[false], translate))
		widget28.OnEvent("Change", chooseInstructions)

		if (StrSplit(A_ScriptName, ".")[1] = "Simulator Configuration")
			height := 190
		else
			height := 65

		widget29 := window.Add("Edit", "x" . x1 . " yp+24 w" . w1 . " h" . height . " Multi H:Grow W:Grow vdcInstructionsEdit Hidden")
		widget29.OnEvent("Change", updateInstructions)

		widget30 := window.Add("Button", "x" . (x1 + w1 - 23) . " yp-25 w23 h23 X:Move Hidden")
		widget30.OnEvent("Click", reloadInstructions)
		setButtonIcon(widget30, kIconsDirectory . "Renew.ico", 1)

		loop 38
			editor.registerWidget(this, widget%A_Index%)
	}

	loadModels(provider, serviceURL, serviceKey, model) {
		local connector, index, models

		if !model
			model := ""

		if (provider = "LLM Runtime")
			this.Control["dcLLMRTModelEdit"].Text := model
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

			this.Control["dcModelDropDown"].Delete()
			this.Control["dcModelDropDown"].Add(models)

			if model
				this.Control["dcModelDropDown"].Choose(inList(models, model))
			else
				this.Control["dcModelDropDown"].Choose((models.Length > 0) ? 1 : 0)
		}
	}

	initializeInstructions(provider, model, setting, edit := false) {
		local providerConfiguration := this.iProviderConfigurations[provider]
		local language, value, instructions, configuration, thePlugin

		value := (edit ? this.Value[setting] : providerConfiguration[setting])

		if (value = "") {
			try {
				if isSet(SetupWizard)
					language := SetupWizard.Instance.getModuleValue("Driving Coach", "Language", getLanguage())
				else if isSet(PluginsConfigurator) {
					configuration := newMultiMap()

					PluginsConfigurator.Instance.saveToConfiguration(configuration)

					thePlugin := Plugin("Driving Coach", configuration)

					language := thePlugin.getArgumentValue("language", thePlugin.getArgumentValue("raceAssistantLanguage"))
				}
				else if isSet(VoiceControlConfigurator)
					language := VoiceControlConfigurator.Instance.getCurrentLanguage()
				else
					language := getMultiMapValue(kSimulatorConfiguration, "Voice Control", "Language", getLanguage())
			}
			catch Any as exception {
				logError(exception)

				language := getLanguage()
			}

			if edit
				this.Value[setting] := getMultiMapValue(this.Templates[this.Templates.Has(language) ? language : "EN"], "Instructions", StrReplace(setting, "Instructions.", ""))
			else
				providerConfiguration[setting] := getMultiMapValue(this.Templates[this.Templates.Has(language) ? language : "EN"], "Instructions", StrReplace(setting, "Instructions.", ""))
		}
	}

	normalizeConfiguration(configuration) {
		local language, ignore, provider, setting, providerConfiguration, template, instruction

		if isSet(SetupWizard)
			language := SetupWizard.Instance.getModuleValue("Driving Coach", "Language", getLanguage())
		else if isSet(VoiceControlConfigurator)
			language := VoiceControlConfigurator.Instance.getCurrentLanguage()
		else
			language := getMultiMapValue(kSimulatorConfiguration, "Voice Control", "Language", getLanguage())

		for ignore, provider in this.Providers {
			providerConfiguration := this.iProviderConfigurations[provider]

			for ignore, setting in this.Instructions {
				template := this.Templates[this.Templates.Has(language) ? language : "EN"]

				if (getMultiMapValue(configuration, "Driving Coach Personality", provider . "." . setting)
				  = getMultiMapValue(template, "Instructions", StrReplace(setting, "Instructions.", "")))
					removeMultiMapValue(configuration, "Driving Coach Personality", provider . "." . setting)

				if (provider = this.iCurrentProvider)
					if (getMultiMapValue(configuration, "Driving Coach Personality", setting)
					  = getMultiMapValue(template, "Instructions", StrReplace(setting, "Instructions.", "")))
						removeMultiMapValue(configuration, "Driving Coach Personality", setting)
			}
		}
	}

	loadFromConfiguration(configuration) {
		local service, ignore, provider, setting, providerConfiguration
		local serviceURL, serviceKey, model

		static defaults := CaseInsenseWeakMap("ServiceURL", false, "Model", "", "MaxTokens", 2048
											, "MaxHistory", 5, "Temperature", 0.5, "Confirmation", true
											, "GPULayers", 0)

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

			if (provider = "LLM Runtime")
				providerConfiguration["GPULayers"] := getMultiMapValue(configuration, "Driving Coach Service", provider . ".GPULayers", defaults["GPULayers"])

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

			if (provider = "LLM Runtime") {
				setMultiMapValue(configuration, "Driving Coach Service", provider . ".GPULayers", providerConfiguration["GPULayers"])

				if (provider = this.iCurrentProvider)
					setMultiMapValue(configuration, "Driving Coach Service", "GPULayers", providerConfiguration["GPULayers"])
			}

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

		if (provider = "LLM Runtime") {
			setMultiMapValue(configuration, "Driving Coach Service", "Service", provider)
			setMultiMapValue(configuration, "Driving Coach Service", "GPULayers", providerConfiguration["GPULayers"])
		}
		else
			setMultiMapValue(configuration, "Driving Coach Service", "Service"
										  , values2String("|", provider, Trim(providerConfiguration["ServiceURL"])
																	   , Trim(providerConfiguration["ServiceKey"])))

		this.normalizeConfiguration(configuration)
	}

	loadProviderConfiguration(provider := false) {
		local configuration

		if !provider
			provider := this.Control["dcProviderDropDown"].Text

		this.iCurrentProvider := provider

		if !this.iProviderConfigurations.Has(this.iCurrentProvider)
			this.iCurrentProvider := this.Providers[1]

		provider := this.iCurrentProvider

		if provider {
			this.Control["dcProviderDropDown"].Delete()
			this.Control["dcProviderDropDown"].Add(this.Providers)
			this.Control["dcProviderDropDown"].Choose(inList(this.Providers, provider))
		}

		configuration := this.iProviderConfigurations[this.iCurrentProvider]

		for ignore, setting in ["ServiceURL", "ServiceKey", "MaxHistory"]
			this.Control["dc" . setting . "Edit"].Text := configuration[setting]

		if (provider = "LLM Runtime") {
			this.Control["dcLLMRTGPULayersEdit"].Text := configuration["GPULayers"]
			this.Control["dcLLMRTMaxTokensEdit"].Text := configuration["MaxTokens"]
		}
		else
			this.Control["dcMaxTokensEdit"].Text := configuration["MaxTokens"]

		if ((provider = "GPT4All") && (Trim(this.Control["dcServiceKeyEdit"].Text) = ""))
			this.Control["dcServiceKeyEdit"].Text := "Any text will do the job"

		if ((provider = "Ollama") && (Trim(this.Control["dcServiceKeyEdit"].Text) = ""))
			this.Control["dcServiceKeyEdit"].Text := "Ollama"

		this.Control["dcTemperatureEdit"].Text := Round(configuration["Temperature"] * 100)

		this.Control["dcConfirmationDropDown"].Value := (configuration["Confirmation"] ? 1 : 2)

		this.loadModels(this.iCurrentProvider, configuration["ServiceURL"]
											 , configuration["ServiceKey"]
											 , configuration["Model"])

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

		if (this.iCurrentProvider = "LLM Runtime")
			value := this.Control["dcLLMRTModelEdit"].Text
		else
			value := this.Control["dcModelDropDown"].Text

		providerConfiguration["Model"] := ((Trim(value) != "") ? Trim(value) : false)

		if (this.iCurrentProvider = "LLM Runtime")
			providerConfiguration["MaxTokens"] := this.Control["dcLLMRTMaxTokensEdit"].Text
		else
			providerConfiguration["MaxTokens"] := this.Control["dcMaxTokensEdit"].Text

		if (this.iCurrentProvider = "LLM Runtime")
			providerConfiguration["GPULayers"] := this.Control["dcLLMRTGPULayersEdit"].Text

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
		local ignore, field, llmRuntime

		this.Control["dcServiceURLEdit"].Enabled := (this.Control["dcProviderDropDown"].Text != "LLM Runtime")
		this.Control["dcServiceKeyEdit"].Enabled := !inList(["GPT4All", "Ollama", "LLM Runtime"], this.Control["dcProviderDropDown"].Text)

		llmRuntime := (this.iCurrentProvider = "LLM Runtime")

		for ignore, field in ["dcServiceKeyLabel", "dcServiceKeyEdit", "dcModelLabel", "dcModelDropDown"
							, "dcServiceURLEdit", "dcMaxTokensEdit", "dcMaxTokensRange"]
			this.Control[field].Visible := !llmRuntime

		this.Control["dcProviderLabel"].Text := (llmRuntime ? translate("Provider") : translate("Provider / URL"))

		for ignore, field in ["dcLLMRTModelLabel", "dcLLMRTModelEdit", "dcLLMRTModelButton"
							, "dcLLMRTTokensLabel", "dcLLMRTMaxTokensEdit", "dcLLMRTMaxTokensRange"
							, "dcLLMRTGPULayersEdit", "dcLLMRTGPULayersRange"]
			this.Control[field].Visible := llmRuntime
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