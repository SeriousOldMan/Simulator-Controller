;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Driving Coach Configuration   ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; DrivingCoachConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class DrivingCoachConfigurator extends ConfiguratorPanel {
	iSimulators := []
	iSimulatorConfigurations := CaseInsenseMap()
	iCurrentSimulator := false

	Simulators {
		Get {
			return this.iSimulators
		}
	}

	__New(editor, configuration := false) {
		this.Editor := editor

		super.__New(configuration)

		DrivingCoachConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local x0, x1, x2, x3, x4, x5, x6, w1, w2, w3, w4, choices, chosen, lineX, lineW

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

			if (!isInteger(value) || (value < 200) || (value > 32000)) {
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
			directory := DirSelect("*" . window["dcConversationsPathEdit"].Text, 0, translate("Select Conversations Folder..."))
			OnMessage(0x44, translator, 0)

			if (directory != "")
				window["dcConversationsPathEdit"].Text := directory
		}

		chooseService(*) {
			window["dcServiceURLEdit"].Text := this.Value[window["dcProviderDropDown"].Text . ".serviceURL"]
			window["dcServiceKeyEdit"].Text := this.Value[window["dcProviderDropDown"].Text . ".serviceKey"]

			this.loadModels(window["dcProviderDropDown"].Text, this.Value[window["dcProviderDropDown"].Text . ".model"])

			chooseInstructions()

			this.updateState()
		}

		chooseInstructions(*) {
			this.loadInstructions(window["dcProviderDropDown"].Text, window["dcModelDropDown"].Text, "instructions." . window["dcInstructionsDropDown"].Text)

			window["dcInstructionsEdit"].Value := this.Value[window["dcProviderDropDown"].Text . ".instructions." . window["dcInstructionsDropDown"].Text]

			this.updateState()
		}

		updateURL(*) {
			this.Value[window["dcProviderDropDown"].Text . ".serviceURL"] := window["dcServiceURLEdit"].Text
		}

		updateKey(*) {
			this.Value[window["dcProviderDropDown"].Text . ".serviceKey"] := window["dcServiceKeyEdit"].Text
		}

		updateModel(*) {
			this.Value[window["dcProviderDropDown"].Text . ".model"] := window["dcModelDropDown"].Text
		}

		updateInstructions(*) {
			this.Value[window["dcProviderDropDown"].Text . ".instructions." . window["dcInstructionsDropDown"].Text] := window["dcInstructionsEdit"].Value
			this.Value["instructions." . window["dcInstructionsDropDown"].Text] := window["dcInstructionsEdit"].Value
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
		widget4 := window.Add("Text", "x" . x0 . " yp+40 w105 h23 Hidden", translate("Service"))
		widget5 := window.Add("Text", "x100 yp+7 w" . (width + 8 - 100) . " 0x10 W:Grow Hidden")
		window.SetFont("Norm", "Arial")

		widget6 := window.Add("Text", "x" . x0 . " yp+20 w105 h23 +0x200 Hidden", translate("Provider"))

 		choices := ["OpenAI", "GPT4ALL"]
		chosen := (choices.Length > 0) ? 1 : 0

		widget7 := window.Add("DropDownList", "x" . x1 . " yp w" . w1 . " Choose" . chosen . " vdcProviderDropDown Hidden", choices)
		widget7.OnEvent("Change", chooseService)

		widget8 := window.Add("Text", "x" . x0 . " yp+24 w80 h23 +0x200 Hidden", translate("Service URL"))
		widget9 := window.Add("Edit", "x" . x1 . " yp w" . w1 . " h23 vdcServiceURLEdit Hidden")
		widget9.OnEvent("Change", updateURL)

		widget10 := window.Add("Text", "x" . x0 . " yp+24 w80 h23 +0x200 Hidden", translate("Service Key"))
		widget11 := window.Add("Edit", "x" . x1 . " yp w" . w1 . " h23 vdcServiceKeyEdit Hidden")
		widget11.OnEvent("Change", updateKey)

		widget12 := window.Add("Text", "x" . x0 . " yp+30 w80 h23 +0x200 Hidden", translate("Model / # Tokens"))
		widget13 := window.Add("ComboBox", "x" . x1 . " yp w" . (w1 - 64) . " vdcModelDropDown Hidden")
		widget13.OnEvent("Change", updateModel)
		widget14 := window.Add("Edit", "x" . (x1 + (w1 - 60)) . " yp-1 w60 h23 Number vdcMaxTokensEdit Hidden")
		widget14.OnEvent("Change", validateTokens)
		widget15 := window.Add("UpDown", "x" . (x1 + (w1 - 60)) . " yp w60 h23 Range200-32000 Hidden")

		window.SetFont("Italic", "Arial")
		widget16 := window.Add("Text", "x" . x0 . " yp+40 w105 h23 Hidden", translate("Personality"))
		widget17 := window.Add("Text", "x100 yp+7 w" . (width + 8 - 100) . " 0x10 W:Grow Hidden")
		window.SetFont("Norm", "Arial")

		widget18 := window.Add("Text", "x" . x0 . " yp+20 w80 h23 +0x200 Hidden", translate("Creativity"))
		widget19 := window.Add("Edit", "x" . x1 . " yp w40 Number Limit3 vdcTemperatureEdit Hidden")
		widget19.OnEvent("Change", validateTemperature)
		widget20 := window.Add("UpDown", "x" . x1 . " yp w40 h23 Range0-100 Hidden")
		widget21 := window.Add("Text", "x" . (x1 + 45) . " yp w100 h23 +0x200 Hidden", translate("%"))

		widget22 := window.Add("Text", "x" . x0 . " yp+24 w80 h23 +0x200 Hidden", translate("Memory"))
		widget23 := window.Add("Edit", "x" . x1 . " yp w40 h23 Number Limit2 vdcMaxHistoryEdit Hidden")
		widget24 := window.Add("UpDown", "x" . x1 . " yp w40 h23 Range1-10 Hidden")
		widget25 := window.Add("Text", "x" . (x1 + 45) . " yp w100 h23 +0x200 Hidden", translate("Conversations"))

		widget26 := window.Add("Text", "x" . x0 . " yp+24 w80 h23 +0x200 Hidden", translate("Instructions"))

		widget27 := window.Add("DropDownList", "x" . x1 . " yp w120 vdcInstructionsDropDown Hidden", collect(["Character", "Simulation", "Stint"], translate))
		widget27.OnEvent("Change", chooseInstructions)

		if (StrSplit(A_ScriptName, ".")[1] = "Simulator Configuration")
			height := 140
		else
			height := 65

		widget28 := window.Add("Edit", "x" . x1 . " yp+24 w" . w1 . " h" . height . " Multi H:Grow W:Grow vdcInstructionsEdit Hidden")
		widget28.OnEvent("Change", updateInstructions)

		loop 28
			editor.registerWidget(this, widget%A_Index%)
	}

	loadModels(provider, model) {
		this.Control["dcModelDropDown"].Delete()

		if (provider = "OpenAI")
			this.Control["dcModelDropDown"].Add(["GPT 3.5 turbo", "GPT 3.5 turbo 16k", "GPT 4", "GPT 4 32k"])

		if model {
			this.Control["dcModelDropDown"].Add([model])
			this.Control["dcModelDropDown"].Choose(((provider = "OpenAI") ? 4 : 0) + 1)
		}
		else
			this.Control["dcModelDropDown"].Choose((provider = "OpenAI") ? 1 : 0)
	}

	loadInstructions(provider, model, descriptor) {
		getInstructionTemplate() {
			local language := (isSet(SetupWizard) ? SetupWizard.Instance.getModuleValue("Driving Coach", "Language", getLanguage())
												  : getMultiMapValue(kSimulatorConfiguration, "Voice Control", "Language", getLanguage()))

			static templates := readMultiMap(kResourcesDirectory . "Templates\Driving Coach.instructions")

			return getMultiMapValue(templates, language, descriptor, "")
		}

		this.Value[descriptor] := this.Value[provider . "." . descriptor]

		if (this.Value[descriptor] = "") {
			this.Value[descriptor] := getInstructionTemplate()
			this.Value[provider . "." . descriptor] := this.Value[descriptor]
		}
	}

	loadFromConfiguration(configuration) {
		local service

		super.loadFromConfiguration(configuration)

		this.Value["conversationsPath"] := getMultiMapValue(configuration, "Driving Coach Conversations", "Archive", "")

		this.Value["OpenAI.serviceURL"] := getMultiMapValue(configuration, "Driving Coach Service", "OpenAI.ServiceURL", "https://api.openai.com/v1/chat/completions")
		this.Value["OpenAI.serviceKey"] := getMultiMapValue(configuration, "Driving Coach Service", "OpenAI.ServiceKey", "")
		this.Value["OpenAI.model"] := getMultiMapValue(configuration, "Driving Coach Service", "OpenAI.Model", "")

		this.Value["OpenAI.instructions.character"] := getMultiMapValue(configuration, "Driving Coach Personality", "OpenAI.Instructions.Character", "")
		this.Value["OpenAI.instructions.simulation"] := getMultiMapValue(configuration, "Driving Coach Personality", "OpenAI.Instructions.Simulation", "")
		this.Value["OpenAI.instructions.stint"] := getMultiMapValue(configuration, "Driving Coach Personality", "OpenAI.Instructions.Stint", "")

		this.Value["GPT4All.serviceURL"] := getMultiMapValue(configuration, "Driving Coach Service", "GPT4All.ServiceURL", "http://localhost:4891/v1")
		this.Value["GPT4All.serviceKey"] := getMultiMapValue(configuration, "Driving Coach Service", "GPT4All.ServiceKey", "")
		this.Value["GPT4All.model"] := getMultiMapValue(configuration, "Driving Coach Service", "GPT4All.Model", "")

		this.Value["GPT4All.instructions.character"] := getMultiMapValue(configuration, "Driving Coach Personality", "GPT4All.Instructions.Character", "")
		this.Value["GPT4All.instructions.simulation"] := getMultiMapValue(configuration, "Driving Coach Personality", "GPT4All.Instructions.Simulation", "")
		this.Value["GPT4All.instructions.stint"] := getMultiMapValue(configuration, "Driving Coach Personality", "GPT4All.Instructions.Stint", "")

		service := getMultiMapValue(configuration, "Driving Coach Service", "Service", false)

		if (InStr(service, "OpenAI") = 1) {
			service := string2Values("|", service)

			this.Value["provider"] := "OpenAI"
			this.Value["serviceURL"] := service[2]
			this.Value["serviceKey"] := service[3]
		}
		else if (InStr(service, "GPT4ALL") = 1) {
			service := string2Values("|", service)

			this.Value["provider"] := "GPT4All"
			this.Value["serviceURL"] := service[2]
			this.Value["serviceKey"] := ""
		}
		else {
			this.Value["provider"] := "OpenAI"
			this.Value["serviceURL"] := "https://api.openai.com/v1/chat/completions"
			this.Value["serviceKey"] := ""
		}

		this.Value["model"] := getMultiMapValue(configuration, "Driving Coach Service", "Model", false)
		this.Value["maxTokens"] := getMultiMapValue(configuration, "Driving Coach Service", "MaxTokens", 512)

		this.Value["temperature"] := getMultiMapValue(configuration, "Driving Coach Personality", "Temperature", 0.5)
		this.Value["maxHistory"] := getMultiMapValue(configuration, "Driving Coach Personality", "MaxHistory", 3)

		this.loadInstructions(this.Value["provider"], this.Value["model"], "instructions.character")
		this.loadInstructions(this.Value["provider"], this.Value["model"], "instructions.simulation")
		this.loadInstructions(this.Value["provider"], this.Value["model"], "instructions.stint")
	}

	saveToConfiguration(configuration) {
		local provider, value

		super.saveToConfiguration(configuration)

		provider := this.Control["dcProviderDropDown"].Text
		value := this.Control["dcConversationsPathEdit"].Text

		setMultiMapValue(configuration, "Driving Coach Conversations", "Archive", (Trim(value) != "") ? Trim(value) : false)

		setMultiMapValue(configuration, "Driving Coach Service", "Service", values2String("|", provider
																							 , Trim(this.Control["dcServiceURLEdit"].Text)
																							 , Trim(this.Control["dcServiceKeyEdit"].Text)))

		value := this.Control["dcModelDropDown"].Text

		setMultiMapValue(configuration, "Driving Coach Service", "Model", (Trim(value) != "") ? Trim(value) : false)

		setMultiMapValue(configuration, "Driving Coach Service", "MaxTokens", this.Control["dcMaxTokensEdit"].Text)

		setMultiMapValue(configuration, "Driving Coach Service", "OpenAI.ServiceURL", this.Value["OpenAI.serviceURL"])
		setMultiMapValue(configuration, "Driving Coach Service", "OpenAI.ServiceKey", this.Value["OpenAI.serviceKey"])
		setMultiMapValue(configuration, "Driving Coach Service", "OpenAI.Model", this.Value["OpenAI.model"])
		setMultiMapValue(configuration, "Driving Coach Personality", "OpenAI.Instructions.Character", this.Value["OpenAI.instructions.character"])
		setMultiMapValue(configuration, "Driving Coach Personality", "OpenAI.Instructions.Simulation", this.Value["OpenAI.instructions.simulation"])
		setMultiMapValue(configuration, "Driving Coach Personality", "OpenAI.Instructions.Stint", this.Value["OpenAI.instructions.stint"])

		setMultiMapValue(configuration, "Driving Coach Service", "GPT4All.ServiceURL", this.Value["GPT4All.serviceURL"])
		setMultiMapValue(configuration, "Driving Coach Service", "GPT4All.ServiceKey", this.Value["GPT4All.serviceKey"])
		setMultiMapValue(configuration, "Driving Coach Service", "GPT4All.Model", this.Value["GPT4All.model"])
		setMultiMapValue(configuration, "Driving Coach Personality", "GPT4All.Instructions.Character", this.Value["GPT4All.instructions.character"])
		setMultiMapValue(configuration, "Driving Coach Personality", "GPT4All.Instructions.Simulation", this.Value["GPT4All.instructions.simulation"])
		setMultiMapValue(configuration, "Driving Coach Personality", "GPT4All.Instructions.Stint", this.Value["GPT4All.instructions.stint"])

		setMultiMapValue(configuration, "Driving Coach Personality", "MaxHistory", this.Control["dcMaxHistoryEdit"].Text)
		setMultiMapValue(configuration, "Driving Coach Personality", "Temperature", this.Control["dcTemperatureEdit"].Text / 100)

		setMultiMapValue(configuration, "Driving Coach Personality", "Instructions.Character", this.Value[provider . ".instructions.character"])
		setMultiMapValue(configuration, "Driving Coach Personality", "Instructions.Simulation", this.Value[provider . ".instructions.simulation"])
		setMultiMapValue(configuration, "Driving Coach Personality", "Instructions.Stint", this.Value[provider . ".instructions.stint"])
	}

	loadConfigurator(configuration, simulators := false) {
		this.loadFromConfiguration(configuration)

		this.Control["dcConversationsPathEdit"].Text := this.Value["conversationsPath"]

		this.Control["dcProviderDropDown"].Choose(inList(["OpenAI", "GPT4All"], this.Value["provider"]))
		this.Control["dcServiceURLEdit"].Text := this.Value["serviceURL"]
		this.Control["dcServiceKeyEdit"].Text := this.Value["serviceKey"]

		model := this.Value["model"]

		this.loadModels(this.Value["provider"], model)

		this.Control["dcMaxTokensEdit"].Text := this.Value["maxTokens"]

		this.Control["dcTemperatureEdit"].Text := Round(this.Value["temperature"] * 100)
		this.Control["dcMaxHistoryEdit"].Text := this.Value["maxHistory"]

		this.Control["dcInstructionsDropDown"].Choose(1)
		this.Control["dcInstructionsEdit"].Value := this.Value["instructions.character"]

		this.updateState()
	}

	show() {
		super.show()

		this.loadConfigurator(this.Configuration)
	}

	updateState() {
		if (this.Control["dcProviderDropDown"].Text = "GPT4ALL") {
			this.Control["dcServiceKeyEdit"].Enabled := false
			this.Control["dcServiceKeyEdit"].Text := ""
		}
		else
			this.Control["dcServiceKeyEdit"].Enabled := true
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeDrivingCoachConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Driving Coach"), DrivingCoachConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeDrivingCoachConfigurator()