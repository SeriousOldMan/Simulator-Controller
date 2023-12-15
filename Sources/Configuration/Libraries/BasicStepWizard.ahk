;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Basic Step Wizard               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"
#Include "..\..\Libraries\SpeechSynthesizer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; BasicStepWizard                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class BasicStepWizard extends StepWizard {
	iSimulatorsListView := false

	iAssistants := CaseInsenseMap()
	iKeys := CaseInsenseMap()

	Pages {
		Get {
			return (1 + (this.BasicSetup ? 1 : 0))
		}
	}

	BasicSetup {
		Get {
			return this.SetupWizard.BasicSetup
		}

		Set {
			this.SetupWizard.BasicSetup := value

			if this.SetupWizard.BasicSetup {
				this.Control["basicSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Quick Setup.ico")
				this.Control["customSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Full Setup Gray.ico")
			}
			else {
				this.Control["basicSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Quick Setup Gray.ico")
				this.Control["customSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Full Setup.ico")
			}

			return value
		}
	}

	Assistants {
		Get {
			return this.iAssistants
		}
	}

	Keys {
		Get {
			return this.iKeys
		}
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local labelWidth := width - 30
		local labelX := x + 35
		local labelY := y + 8
		local col1Width := (106 + 24 + 98 + 96)
		local col2X := (x + col1Width + 20)
		local col2Width := (width - col1Width - 20)
		local button1X := x + (Round(width / 3) - 32)
		local button2X := x + (Round(width / 3 * 2) - 32)
		local languages := availableLanguages()
		local code, language, w, h, choices

		noSelect(listView, *) {
			loop listView.GetCount()
				listView.Modify(A_Index, "-Select")
		}

		openFormatsEditor(*) {
			wizard.Steps["General"].openFormatsEditor()
		}

		getPTTHotkey(*) {
			setPTTHotkey(hotkey) {
				if !isInteger(hotkey) {
					SoundPlay(getFileName("Activated.wav", kUserHomeDirectory . "Sounds\", kResourcesDirectory . "Sounds\"))

					this.Control["basicPushToTalkEdit"].Text := hotkey

					wizard.toggleTriggerDetector()
				}
			}

			protectionOn()

			try {
				wizard.toggleTriggerDetector(setPTTHotkey)
			}
			finally {
				protectionOff()
			}
		}

		locateSimulator(*) {
			local fileName, simulator

			window.Opt("+OwnDialogs")

			OnMessage(0x44, translateSelectCancelButtons)
			fileName := FileSelect(1, "", substituteVariables(translate("Select %name% executable..."), {name: translate("Simulator")}), "Executable (*.exe)")
			OnMessage(0x44, translateSelectCancelButtons, 0)

			if (fileName != "") {
				simulator := standardApplication(this.SetupWizard.Definition, ["Applications.Simulators"], fileName)

				if simulator
					this.locateSimulator(simulator, fileName)
			}
		}

		loadVoice(assistant, *) {
			this.loadVoices(assistant)
		}

		chooseMethod(method, *) {
			if (method = "Basic") {
				/*
				if (wizard.isBasicSetupAvailable() || GetKeyState("Ctrl", "P"))
					this.BasicSetup := (GetKeyState("Ctrl", "P") ? "Force" : true)
				else
					this.BasicSetup := false
				*/
				
				this.BasicSetup := "Force"
			}
			else
				this.BasicSetup := false

			wizard.updateState()
		}

		finishSetup(*) {
			local msgResult

			wizard.Window.Show()

			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox((translate("Do you want to generate the new configuration?") . "`n`n" . translate("Backup files will be saved for your current configuration in the `"Simulator Controller\Config`" folder in your user `"Documents`" folder.")), translate("Setup "), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "Yes")
				if this.SetupWizard.finishSetup()
					ExitApp(0)
		}

		updateAssistant(assistant, *) {
			local enabled := window["basic" . this.Keys[assistant] . "EnabledCheck"].Value
			local found := false
			local ignore, key

			if !enabled
				for ignore, key in this.Keys
					if window["basic" . key . "EnabledCheck"].Value {
						found := true

						break
					}

			if (found || enabled)
				wizard.selectModule(assistant, enabled)
			else
				window["basic" . this.Keys[assistant] . "EnabledCheck"].Value := true
		}

		editSynthesizer(assistant, *) {
			this.editSynthesizer(assistant)
		}

		updateP2T(*) {
			if (window["basicPushToTalkModeDropDown"].Value = 3) {
				window["basicPushToTalkEdit"].Enabled := false
				window["basicPushToTalkEdit"].Value := ""
				window["basicPushToTalkButton"].Enabled := false
			}
			else {
				window["basicPushToTalkEdit"].Enabled := true
				window["basicPushToTalkButton"].Enabled := true
			}
		}

		widget1 := window.Add("HTMLViewer", "x" . x . " y" . y . " w" . width . " h120 W:Grow Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Basic", "Basic.StartHeader." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.Theme.WindowBackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "</body></html>"

		widget1.document.write(html)

		y += 150

		widget2 := window.Add("Picture", "x" . button1X . " y" . y . " w64 h64 vbasicSetupButton Hidden X:Move(0.33)", kResourcesDirectory . (this.BasicSetup ? "Setup\Images\Quick Setup.ico" : "Setup\Images\Quick Setup Gray.ico"))
		widget2.OnEvent("Click", chooseMethod.Bind("Basic"))
		widget3 := window.Add("Text", "x" . button1X . " yp+68 w64 Hidden Center X:Move(0.33)", translate("Basic"))

		widget4 := window.Add("Picture", "x" . button2X . " y" . y . " w64 h64 vcustomSetupButton Hidden X:Move(0.66)", kResourcesDirectory . (!this.BasicSetup ? "Setup\Images\Full Setup.ico" : "Setup\Images\Full Setup Gray.ico"))
		widget4.OnEvent("Click", chooseMethod.Bind("Extended"))
		widget5 := window.Add("Text", "x" . button2X . " yp+68 w64 Hidden Center X:Move(0.66)", translate("Extended"))

		y += 100

		widget6 := window.Add("HTMLViewer", "x" . x . " y" . y . " w" . width . " h120 W:Grow Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Basic", "Basic.StartFooter." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.Theme.WindowBackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "</body></html>"

		widget6.document.write(html)

		this.registerWidgets(1, widget1, widget2, widget3, widget4, widget5, widget6)

		y -= 250

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Gears.ico")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Basic Configuration"))

		window.SetFont("s8 Norm", "Arial")

		window.SetFont("Bold", "Arial")

		widget3 := window.Add("Text", "x" . x . " yp+30 w110 h23 +0x200 Hidden Section", translate("General"))
		widget4 := window.Add("Text", "yp+20 x" . x . " w" . col1Width . " 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		choices := []

		for code, language in languages
			choices.Push(language)

		widget5 := window.Add("Text", "x" . x . " yp+10 w86 h23 +0x200 Hidden", translate("Localization"))
		widget6 := window.Add("Button", "xp+106 yp w23 h23 Hidden")
		widget6.OnEvent("Click", openFormatsEditor)
		setButtonIcon(widget6, kIconsDirectory . "Locale.ico", 1, "L4 T4 R4 B4")
		widget7 := window.Add("DropDownList", "xp+24 yp w96 VbasicUILanguageDropDown Hidden", choices)

		widget8 := window.Add("Text", "x" . x . " yp+24 w86 h23 +0x200 Hidden", translate("Push-To-Talk"))
		widget9 := window.Add("Button", "xp+106 yp-1 w23 h23 VbasicPushToTalkButton Hidden")
		widget9.OnEvent("Click", getPTTHotkey)
		setButtonIcon(widget9, kIconsDirectory . "Key.ico", 1)
		widget10 := window.Add("DropDownList", "xp+24 yp w96 Choose1 VbasicPushToTalkModeDropDown Hidden", collect(["Hold & Talk", "Press & Talk", "Custom"], translate))
		widget10.OnEvent("Change", updateP2T)
		widget11 := window.Add("Edit", "xp+98 yp w96 h21 VbasicPushToTalkEdit Hidden")

		window.SetFont("Bold", "Arial")

		widget32 := window.Add("Text", "x" . col2X . " ys w110 h23 +0x200 Hidden Section", translate("Simulators"))
		widget33 := window.Add("Text", "yp+20 xp w" . col2Width . " W:Grow 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		widget34 := window.Add("ListView", "x" . col2X . " yp+10 w" . col2Width . " h110 W:Grow Section -Multi -LV0x10 Checked NoSort NoSortHdr Hidden", collect(["Simulation", "Path"], translate))
		widget34.OnEvent("Click", noSelect)
		widget34.OnEvent("DoubleClick", noSelect)
		widget34.OnEvent("ContextMenu", noSelect)

		this.iSimulatorsListView := widget34

		widget35 := window.Add("Button", "x" . (col2X + col2Width - 90) . " yp+117 w90 h23 X:Move Hidden", translate("Locate..."))
		widget35.OnEvent("Click", locateSimulator)

		window.SetFont("Bold", "Arial")

		widget12 := window.Add("Text", "x" . x . " yp+20 w110 h23 +0x200 Hidden Section", translate("Assistants"))
		widget13 := window.Add("Text", "yp+20 xp w" . width . " W:Grow 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		widget38 := window.Add("Text", "x" . (x + 16 + 114) . " yp+10 w96 h23 +0x200 Hidden", translate("Name"))
		widget39 := window.Add("Text", "xp+98 yp w96 h23 +0x200 Hidden", translate("Language"))
		widget40 := window.Add("Text", "xp+98 yp w96 h23 +0x200 Hidden", translate("Voice"))

		widget41 := window.Add("CheckBox", "x" . x . " yp+24 w16 h23 vbasicDCEnabledCheck Hidden" . (wizard.isModuleSelected("Driving Coach") ? " Checked" : ""))
		widget41.OnEvent("Click", updateAssistant.Bind("Driving Coach"))
		widget42 := window.Add("Text", "xp+16 yp w86 h23 +0x200 Hidden", translate("Driving Coach"))
		widget43 := window.Add("Edit", "xp+114 yp w96 VbasicDCNameEdit Hidden", "Aiden")
		widget44 := window.Add("DropDownList", "xp+98 yp w96 VbasicDCLanguageDropDown Hidden")
		widget44.OnEvent("Change", loadVoice.Bind("Driving Coach"))
		widget45 := window.Add("DropDownList", "xp+98 yp w333 W:Grow VbasicDCVoiceDropDown Hidden")
		widget46 := window.Add("Button", "xp+335 yp-1 w23 h23 X:Move vbasicDCSettingsButton Hidden")
		widget46.OnEvent("Click", editSynthesizer.Bind("Driving Coach"))
		setButtonIcon(widget46, kIconsDirectory . "General Settings.ico", 1)

		widget14 := window.Add("CheckBox", "x" . x . " yp+24 w16 h23 vbasicREEnabledCheck Hidden" . (wizard.isModuleSelected("Race Engineer") ? " Checked" : ""))
		widget14.OnEvent("Click", updateAssistant.Bind("Race Engineer"))
		widget15 := window.Add("Text", "xp+16 yp w86 h23 +0x200 Hidden", translate("Race Engineer"))
		widget16 := window.Add("Edit", "xp+114 yp w96 VbasicRENameEdit Hidden", "Jona")
		widget17 := window.Add("DropDownList", "xp+98 yp w96 VbasicRELanguageDropDown Hidden")
		widget17.OnEvent("Change", loadVoice.Bind("Race Engineer"))
		widget18 := window.Add("DropDownList", "xp+98 yp w333 W:Grow VbasicREVoiceDropDown Hidden")
		widget19 := window.Add("Button", "xp+335 yp-1 w23 h23 X:Move vbasicRESettingsButton Hidden")
		widget19.OnEvent("Click", editSynthesizer.Bind("Race Engineer"))
		setButtonIcon(widget19, kIconsDirectory . "General Settings.ico", 1)

		widget20 := window.Add("CheckBox", "x" . x . " yp+24 w16 h23 vbasicRSEnabledCheck Hidden" . (wizard.isModuleSelected("Race Strategist") ? " Checked" : ""))
		widget20.OnEvent("Click", updateAssistant.Bind("Race Strategist"))
		widget21 := window.Add("Text", "xp+16 yp w86 h23 +0x200 Hidden", translate("Race Strategist"))
		widget22 := window.Add("Edit", "xp+114 yp w96 VbasicRSNameEdit Hidden", "Khato")
		widget23 := window.Add("DropDownList", "xp+98 yp w96 VbasicRSLanguageDropDown Hidden")
		widget23.OnEvent("Change", loadVoice.Bind("Race Strategist"))
		widget24 := window.Add("DropDownList", "xp+98 yp w333 W:Grow VbasicRSVoiceDropDown Hidden")
		widget25 := window.Add("Button", "xp+335 yp-1 w23 h23 X:Move vbasicRSSettingsButton Hidden")
		widget25.OnEvent("Click", editSynthesizer.Bind("Race Strategist"))
		setButtonIcon(widget25, kIconsDirectory . "General Settings.ico", 1)

		widget26 := window.Add("CheckBox", "x" . x . " yp+24 w16 h23 vbasicRSPEnabledCheck Hidden" . (wizard.isModuleSelected("Race Spotter") ? " Checked" : ""))
		widget26.OnEvent("Click", updateAssistant.Bind("Race Spotter"))
		widget27 := window.Add("Text", "xp+16 yp w86 h23 +0x200 Hidden", translate("Race Spotter"))
		widget28 := window.Add("Edit", "xp+114 yp w96 VbasicRSPNameEdit Hidden", "Elisa")
		widget29 := window.Add("DropDownList", "xp+98 yp w96 VbasicRSPLanguageDropDown Hidden")
		widget29.OnEvent("Change", loadVoice.Bind("Race Spotter"))
		widget30 := window.Add("DropDownList", "xp+98 yp w333 W:Grow VbasicRSPVoiceDropDown Hidden")
		widget31 := window.Add("Button", "xp+335 yp-1 w23 h23 X:Move vbasicRSPSettingsButton Hidden")
		widget31.OnEvent("Click", editSynthesizer.Bind("Race Spotter"))
		setButtonIcon(widget31, kIconsDirectory . "General Settings.ico", 1)

		widget36 := window.Add("HTMLViewer", "x" . x . " yp+30 w" . width . " h95 W:Grow H:Grow(0.8) Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Basic", "Basic.FinishFooter." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.Theme.WindowBackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "</body></html>"

		widget36.document.write(html)

		widget37 := window.Add("Button", "x" . (x + Round((width / 2) - 45)) . " yp+96 w90 h60 X:Move(0.4) W:Grow(0.2) Y:Move(0.8) H:Grow(0.2) Hidden")
		setButtonIcon(widget37, kResourcesDirectory . "\Setup\Images\Finish Line.png", 1, "w80 h53")
		widget37.OnEvent("Click", finishSetup)

		loop 46
			this.registerWidget(2, widget%A_Index%)
	}

	loadStepDefinition(definition) {
		local wizard := this.SetupWizard
		local ignore, assistant, key

		super.loadStepDefinition(definition)

		for ignore, assistant in this.Definition {
			key := getMultiMapValue(wizard.Definition, "Setup.Basic", "Basic.Keys." . assistant)

			this.Keys[assistant] := key
			this.Assistants[key] := assistant
		}
	}

	showPage(page) {
		local wizard := this.SetupWizard
		local chosen := 0
		local enIndex := 0
		local enabled := false
		local fullInstall := false
		local code, language, uiLanguage, startWithWindows, silentMode, configuration

		static installed := false

		if (page = 2) {
			fullInstall := (!installed && (!isDevelopment() || (GetKeyState("Ctrl", "P") && GetKeyState("Shift", "P"))))

			wizard.selectModule("Voice Control", true, false)

			for ignore, assistant in this.Definition
				enabled := (enabled || wizard.isModuleSelected(assistant))

			if !enabled
				wizard.selectModule(this.Definition[2], true, false)

			wizard.getGeneralConfiguration(&uiLanguage, &startWithWindows, &silentMode)

			for code, language in availableLanguages() {
				if (code = uiLanguage)
					chosen := A_Index
				else if (code = "en")
					enIndex := A_Index
			}

			if (chosen == 0)
				chosen := enIndex

			this.Control["basicUILanguageDropDown"].Choose(chosen)

			configuration := readMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini")

			this.Control["basicPushToTalkEdit"].Text := getMultiMapValue(configuration, "Voice Control", "PushToTalk", "")
			this.Control["basicPushToTalkModeDropDown"].Choose(inList(["Hold", "Press", "Custom"]
																	, getMultiMapValue(configuration, "Voice Control"
																					 , "PushToTalkMode", "Hold")))

			this.loadSetup(!fullInstall)

			this.BasicSetup := false
		}

		super.showPage(page)

		if (page = 2) {
			if (this.Control["basicPushToTalkModeDropDown"].Value = 3) {
				this.Control["basicPushToTalkEdit"].Enabled := false
				this.Control["basicPushToTalkEdit"].Value := ""
				this.Control["basicPushToTalkButton"].Enabled := false
			}
			else {
				this.Control["basicPushToTalkEdit"].Enabled := true
				this.Control["basicPushToTalkButton"].Enabled := true
			}
		}

		if fullInstall {
			wizard.installSoftware()

			this.loadSimulators()

			installed := true
		}
	}

	hidePage(page) {
		if (page = 2) {
			this.updateSelectedSimulators()

			this.saveSetup()
		}

		return super.hidePage(page)
	}

	updateState() {
		local wizard := this.SetupWizard
		local key, assistant, enabled, ignore, assistant, value

		super.updateState()

		if !wizard.isModuleSelected("Voice Control")
			for ignore, assistant in this.Definition
				for ignore, value in ["Synthesizer", "Voice", "Volume", "Pitch", "Speed"]
					wizard.clearModuleValue(assistant, value, false)

		for key, assistant in this.Assistants {
			enabled := wizard.isModuleSelected(assistant)

			this.Control["basic" . key . "EnabledCheck"].Value := (enabled != false)
			this.Control["basic" . key . "LanguageDropDown"].Enabled := enabled
			this.Control["basic" . key . "VoiceDropDown"].Enabled := enabled
			this.Control["basic" . key . "NameEdit"].Enabled := enabled
			this.Control["basic" . key . "SettingsButton"].Enabled := enabled
		}
	}

	assistantEnabled(assistant, editor := true) {
		if editor
			return (this.Control["basic" . this.Keys[assistant] . "EnabledCheck"].Value != 0)
		else
			return this.SetupWizard.isModuleSelected(assistant)
	}

	assistantName(assistant, editor := true) {
		if editor
			return this.Control["basic" . this.Keys[assistant] . "NameEdit"].Text
		else
			return this.SetupWizard.getModuleValue(assistant, "Name", this.assistantDefaults(assistant).Name)
	}

	assistantLanguage(assistant, editor := true) {
		local languages, found, code, language, ignore, grammarFile, grammarLanguageCode, voiceLanguage

		if editor {
			languages := availableLanguages()
			voiceLanguage := this.Control["basic" . this.Keys[assistant] . "LanguageDropDown"].Text

			for code, language in availableLanguages()
				if (language = voiceLanguage)
					return code

			for ignore, assistant in this.Definition
				for ignore, grammarFile in getFileNames("Race Engineer.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory) {
					SplitPath(grammarFile, , , &grammarLanguageCode)

					if languages.Has(grammarLanguageCode)
						language := languages[grammarLanguageCode]
					else
						language := grammarLanguageCode

					if (language = voiceLanguage)
						return grammarLanguageCode
				}
		}
		else
			return this.SetupWizard.getModuleValue(assistant, "Language", getLanguage())
	}

	assistantSynthesizer(assistant, editor := true) {
		if this.SetupWizard.isModuleSelected("Voice Control")
			return this.SetupWizard.getModuleValue(assistant, "Synthesizer", this.assistantDefaults(assistant).Synthesizer)
		else
			return false
	}

	assistantVoice(assistant, editor := true) {
		local infix, voice

		voice := this.Control["basic" . this.Keys[assistant] . "VoiceDropDown"].Text

		if this.SetupWizard.isModuleSelected("Voice Control") {
			if (voice = translate("Deactivated"))
				voice := false
			else if (voice = translate("Random"))
				voice := true
			else if (!voice || (voice = ""))
				voice := true

			if editor
				return voice
			else
				return this.SetupWizard.getModuleValue(assistant, "Voice", this.assistantDefaults(assistant).Voice)
		}
		else
			voice := false
	}

	assistantVolume(assistant, editor := true) {
		if this.SetupWizard.isModuleSelected("Voice Control")
			return this.SetupWizard.getModuleValue(assistant, "Volume", this.assistantDefaults(assistant).Volume)
		else
			return false
	}

	assistantPitch(assistant, editor := true) {
		if this.SetupWizard.isModuleSelected("Voice Control")
			return this.SetupWizard.getModuleValue(assistant, "Pitch", this.assistantDefaults(assistant).Pitch)
		else
			return false
	}

	assistantSpeed(assistant, editor := true) {
		if this.SetupWizard.isModuleSelected("Voice Control")
			return this.SetupWizard.getModuleValue(assistant, "Speed", this.assistantDefaults(assistant).Speed)
		else
			return false
	}

	assistantSetup(assistant, editor := true) {
		return {Enabled: this.assistantEnabled(assistant, editor), Name: this.assistantName(assistant, editor)
			  , Language: this.assistantLanguage(assistant, editor), Synthesizer: this.assistantSynthesizer(assistant, editor)
			  , Voice: this.assistantVoice(assistant, editor)
			  , Volume: this.assistantVolume(assistant), Pitch: this.assistantPitch(assistant), Speed: this.assistantSpeed(assistant)}
	}

	assistantDefaults(assistant) {
		local wizard := this.SetupWizard
		local defaults := {}
		local ignore, key

		for ignore, key in ["Name", "Synthesizer", "Voice", "Volume", "Pitch", "Speed"]
			defaults.%key% := getMultiMapValue(wizard.Definition, "Setup.Basic", "Basic.Defaults." . assistant . "." . key)

		return defaults
	}

	loadSetup(simulators := true) {
		local wizard := this.SetupWizard
		local ignore, module, assistant

		if (wizard.Initialize && !wizard.getModuleValue(this.Step, "Initialized", false)) {
			wizard.setModuleValue(this.Step, "Initialized", true)

			for ignore, module in wizard.Steps["Modules"].Definition
				wizard.selectModule(module, false, false)

			wizard.selectModule("Voice Control", true, false)

			for ignore, assistant in this.Definition
				wizard.selectModule(assistant, true, false)

			wizard.updateState()
		}

		if simulators
			this.loadSimulators()
		else
			this.iSimulatorsListView.Delete()

		this.loadAssistants()
	}

	locateSimulator(name, fileName) {
		local wizard := this.StepWizard
		local wasInstalled := wizard.isApplicationInstalled(name)

		wizard.locateApplication(name, fileName, false)

		if !wasInstalled
			wizard.selectApplication(name, true, false)

		this.loadSimulators()
	}

	loadVoices(assistant := false, editor := true) {
		local assistants := (assistant ? [assistant] : this.Definition)
		local voices, language, ignore, dropDown, index

		for ignore, assistant in assistants {
			language := this.assistantLanguage(assistant, editor)

			voices := SpeechSynthesizer(this.assistantSynthesizer(assistant, editor), true, language).Voices[language]

			dropDown := this.Control["basic" . this.Keys[assistant] . "VoiceDropDown"]

			dropDown.Delete()
			dropDown.Add((voices.Length > 0) ? concatenate(collect(["Deactivated", "Random"], translate), voices) : [translate("Deactivated")])
			dropDown.Choose((voices.Length > 0) ? 2 : 1)

			if (!editor && (voices.Length > 1)) {
				voice := this.SetupWizard.getModuleValue(assistant, "Voice", true)

				dropDown.Choose(voice ? (inList(voices, voice) + 2) : 1)
			}
		}
	}

	loadSimulators() {
		local wizard := this.SetupWizard
		local definition := wizard.Steps["Applications"].Definition
		local icons := []
		local rows := []
		local stdApplications := []
		local simulator, descriptor, executable, iconFile
		local listViewIcons, ignore, icon, row, ignore, descriptor

		static first := true

		this.iSimulatorsListView.Delete()

		for simulator, descriptor in getMultiMapValues(wizard.Definition, definition[1]) {
			if wizard.isApplicationInstalled(simulator) {
				descriptor := string2Values("|", descriptor)

				executable := wizard.applicationPath(simulator)

				iconFile := findInstallProperty(simulator, "DisplayIcon")

				if iconFile
					icons.Push(iconFile)
				else if executable
					icons.Push(executable)
				else
					icons.Push("")

				rows.Push(Array((wizard.isApplicationSelected(simulator) ? "Check Icon" : "Icon") . (rows.Length + 1), simulator, executable ? executable : translate("Not installed")))
			}
		}

		listViewIcons := IL_Create(icons.Length)

		for ignore, icon in icons
			IL_Add(listViewIcons, icon)

		this.iSimulatorsListView.SetImageList(listViewIcons)

		for ignore, row in rows
			this.iSimulatorsListView.Add(row*)

		if first {
			this.iSimulatorsListView.ModifyCol(1, "AutoHdr")
			this.iSimulatorsListView.ModifyCol(2, "AutoHdr")

			first := false
		}
	}

	loadAssistant(assistant) {
		local key := this.Keys[assistant]
		local choices := []
		local languages := []
		local assistantLanguage, code, language, ignore, grammarFile

		for code, language in availableLanguages() {
			choices.Push(language)
			languages.Push(code)
		}

		for ignore, assistant in this.Definition
			for ignore, grammarFile in getFileNames(assistant . ".grammars.*", kUserGrammarsDirectory, kGrammarsDirectory) {
				SplitPath(grammarFile, , , &code)

				if !inList(languages, code) {
					choices.Push(code)
					languages.Push(code)
				}
			}

		this.Control["basic" . key . "EnabledCheck"].Value := (this.assistantEnabled(assistant, false) != false)
		this.Control["basic" . key . "NameEdit"].Text := this.assistantName(assistant, false)

		assistantLanguage := inList(languages, this.assistantLanguage(assistant, false))

		this.Control["basic" . key . "LanguageDropDown"].Delete()
		this.Control["basic" . key . "LanguageDropDown"].Add(choices)
		this.Control["basic" . key . "LanguageDropDown"].Choose(assistantLanguage ? assistantLanguage : 1)

		this.loadVoices(assistant, false)
	}

	loadAssistants() {
		local ignore, assistant

		for ignore, assistant in this.Assistants
			this.loadAssistant(assistant)
	}

	updateSelectedSimulators() {
		local wizard := this.SetupWizard
		local listView := this.iSimulatorsListView
		local checked := CaseInsenseMap()
		local row := 0
		local name

		loop {
			row := listView.GetNext(row,"C")

			if row {
				name := listView.GetText(row, 1)

				checked[name] := true
			}
			else
				break
		}

		loop listView.GetCount() {
			name := listView.GetText(A_Index, 1)

			if wizard.isApplicationOptional(name)
				wizard.selectApplication(name, checked.Has(name) ? checked[name] : false, false)
			else
				listView.Modify(A_Index, "Check")
		}
	}

	saveSetup() {
		local wizard := this.SetupWizard
		local voiceConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini")
		local assistantSetups := {}
		local languageCode := "en"
		local code, language, ignore, key, value, assistant

		for key, assistant in this.Assistants
			assistantSetups.%key% := this.assistantSetup(assistant)

		for key, assistant in this.Assistants {
			wizard.selectModule(assistant, assistantSetups.%key%.Enabled, false)

			for ignore, value in ["Name", "Language", "Synthesizer", "Voice", "Volume", "Pitch", "Speed"]
				wizard.setModuleValue(assistant, value, assistantSetups.%key%.%value%, false)
		}

		setMultiMapValue(voiceConfiguration, "Voice Control", "Language", getLanguage())
		setMultiMapValue(voiceConfiguration, "Voice Control", "PushToTalk", this.Control["basicPushToTalkEdit"].Text)
		setMultiMapValue(voiceConfiguration, "Voice Control", "PushToTalkMode", ["Hold", "Press", "Custom"][this.Control["basicPushToTalkModeDropDown"].Value])

		if (getMultiMapValue(voiceConfiguration, "Voice Control", "Synthesizer", kUndefined) = kUndefined)
			setMultiMapValue(voiceConfiguration, "Voice Control", "Synthesizer", "dotNET")

		if (getMultiMapValue(voiceConfiguration, "Voice Control", "Speaker", kUndefined) = kUndefined)
			setMultiMapValue(voiceConfiguration, "Voice Control", "Speaker", true)

		if (getMultiMapValue(voiceConfiguration, "Voice Control", "Recognizer", kUndefined) = kUndefined)
			setMultiMapValue(voiceConfiguration, "Voice Control", "Recognizer", "Desktop")

		if (getMultiMapValue(voiceConfiguration, "Voice Control", "Listener", kUndefined) = kUndefined)
			setMultiMapValue(voiceConfiguration, "Voice Control", "Listener", true)

		writeMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini", voiceConfiguration)

		for code, language in availableLanguages()
			if (language = this.Control["basicUILanguageDropDown"].Text) {
				languageCode := code

				break
			}

		wizard.setGeneralConfiguration(languageCode, true, false)

		wizard.updateState()
	}

	editSynthesizer(assistant) {
		local wizard := this.SetupWizard
		local window := this.Window
		local configuration, setup

		window.Block()

		try {
			this.saveSetup()

			configuration := newMultiMap()

			setup := this.assistantSetup(assistant)

			setMultiMapValues(configuration, "Voice Control", getMultiMapValues(kSimulatorConfiguration, "Voice Control"), false)

			setMultiMapValue(configuration, "Voice Control", "Language", setup.Language)
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", setup.Synthesizer)
			setMultiMapValue(configuration, "Voice Control", "Speaker", setup.Voice)
			setMultiMapValue(configuration, "Voice Control", "SpeakerVolume", (setup.Volume = "*") ? 100 : setup.Volume)
			setMultiMapValue(configuration, "Voice Control", "SpeakerPitch", (setup.Pitch = "*") ? 0 : setup.Pitch)
			setMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", (setup.Speed = "*") ? 0 : setup.Speed)

			if (InStr(setup.Synthesizer, "Azure") = 1) {
				setMultiMapValue(configuration, "Voice Control", "Speaker.Azure", setup.Voice)

				setup := string2Values("|", setup.Synthesizer)

				setMultiMapValue(configuration, "Voice Control", "SubscriptionKey", setup[3])
				setMultiMapValue(configuration, "Voice Control", "TokenIssuer", setup[2])
			}
			else if (setup.Synthesizer = "dotNET")
				setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", setup.Voice)
			else if (setup.Synthesizer = "Windows")
				setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", setup.Voice)
			else {
				setMultiMapValue(configuration, "Voice Control", "Speaker.Google", setup.Voice)

				setup := string2Values("|", setup.Synthesizer)

				setMultiMapValue(configuration, "Voice Control", "APIKeyFile", setup[2])
			}

			configuration := VoiceSynthesizerEditor(this, configuration).editSynthesizer(window)

			if configuration {
				wizard.setModuleValue(assistant, "Synthesizer", getMultiMapValue(configuration, "Voice Control", "Synthesizer"))
				wizard.setModuleValue(assistant, "Voice", getMultiMapValue(configuration, "Voice Control", "Speaker"))
				wizard.setModuleValue(assistant, "Volume", getMultiMapValue(configuration, "Voice Control", "SpeakerVolume"))
				wizard.setModuleValue(assistant, "Pitch", getMultiMapValue(configuration, "Voice Control", "SpeakerPitch"))
				wizard.setModuleValue(assistant, "Speed", getMultiMapValue(configuration, "Voice Control", "SpeakerSpeed"))

				this.loadAssistant(assistant)
			}
		}
		finally {
			window.Unblock()
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; VoiceSynthesizerEditor                                                  ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class VoiceSynthesizerEditor extends ConfiguratorPanel {
	iResult := false

	iStepWizard := false
	iLanguage := "English"

	iWindow := false

	iLanguages := []

	iSynthesizerMode := false

	iTopWidgets := []
	iBottomWidgets := []
	iWindowsSynthesizerWidgets := []
	iAzureSynthesizerWidgets := []
	iGoogleSynthesizerWidgets := []
	iOtherWidgets := []

	iTopAzureCredentialsVisible := false
	iTopGoogleCredentialsVisible := false

	StepWizard {
		Get {
			return this.iStepWizard
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	__New(stepWizard, configuration := false) {
		this.iStepWizard := stepWizard

		super.__New(configuration)
	}

	createGui(configuration) {
		local choices := []
		local chosen := 0
		local x := 8
		local width := 380
		local editorGui, x0, x1, x2, w1, w2, x3, w3, x4, w4, voices

		updateAzureVoices(*) {
			this.updateAzureVoices()
		}

		updateGoogleVoices(*) {
			this.updateGoogleVoices()
		}

		chooseVoiceSynthesizer(*) {
			local voiceSynthesizerDropDown := this.Control["basicVoiceSynthesizerDropDown"]
			local oldChoice := voiceSynthesizerDropDown.LastValue

			if (oldChoice == 1)
				this.hideWindowsSynthesizerEditor()
			else if (oldChoice == 2)
				this.hideDotNETSynthesizerEditor()
			else if (oldChoice == 3)
				this.hideAzureSynthesizerEditor()
			else
				this.hideGoogleSynthesizerEditor()

			if (voiceSynthesizerDropDown.Value == 1)
				this.showWindowsSynthesizerEditor()
			else if (voiceSynthesizerDropDown.Value == 2)
				this.showDotNETSynthesizerEditor()
			else if (voiceSynthesizerDropDown.Value == 3)
				this.showAzureSynthesizerEditor()
			else
				this.showGoogleSynthesizerEditor()

			if ((voiceSynthesizerDropDown.Value <= 2) || (voiceSynthesizerDropDown.Value == 4))
				this.updateLanguage()

			voiceSynthesizerDropDown.LastValue := voiceSynthesizerDropDown.Value
		}

		chooseAPIKeyFilePath(*) {
			local file, translator

			this.Window.Opt("+OwnDialogs")

			translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

			OnMessage(0x44, translator)
			file := FileSelect(1, this.Control["basicGoogleAPIKeyFileEdit"].Text, translate("Select Google Credentials File..."), "JSON (*.json)")
			OnMessage(0x44, translator, 0)

			if (file != "") {
				this.Control["basicGoogleAPIKeyFileEdit"].Text := file

				this.updateGoogleVoices()
			}
		}

		editorGui := Window({Descriptor: "Synthesizer Editor", Options: "0x400000"}, "")

		this.iWindow := editorGui

		editorGui.SetFont("Bold", "Arial")

		editorGui.Add("Text", "w388 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(editorGui, "Synthesizer Editor"))

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Documentation", "x138 YP+20 w128 H:Center Center", translate("Voice Configuration")
					, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control")

		editorGui.SetFont("Norm", "Arial")

		editorGui.Add("Text", "x8 yp+30 w388 W:Grow 0x10")

		x0 := x + 8
		x1 := x + 118
		x2 := x + 230

		w1 := width - (x1 - x)
		w2 := w1 - 26 - 26

		x3 := x1 + w2 + 2
		x4 := x2 + 24 + 8
		w4 := width - (x4 - x)
		x5 := x3 + 24

		choices := ["Windows (Win32)", "Windows (.NET)", "Azure Cognitive Services", "Google Speech Services"]
		chosen := 0

		widget1 := editorGui.Add("Text", "x" . x0 . " yp+10 w110 h23 +0x200 Section Hidden", translate("Speech Synthesizer"))
		widget2 := editorGui.Add("DropDownList", "x" . x1 . " yp w156 W:Grow(0.3) Choose" . chosen . "  VbasicVoiceSynthesizerDropDown Hidden", choices)
		widget2.LastValue := chosen
		widget2.OnEvent("Change", chooseVoiceSynthesizer)

		editorGui.Add("Button", "xp+157 yp-1 w23 h23 X:Move(0.3) vbasicWindowsSettingsButton Hidden").OnEvent("Click", (*) => Run("explorer.exe ms-settings:speech"))
		setButtonIcon(editorGui["basicWindowsSettingsButton"], kIconsDirectory . "General Settings.ico", 1)

		this.iTopWidgets := [[widget1, widget2, editorGui["basicWindowsSettingsButton"]]]

		voices := [translate("Random"), translate("Deactivated")]

		widget3 := editorGui.Add("Text", "x" . x0 . " ys+24 w110 h23 +0x200 VbasicWindowsSpeakerLabel Hidden", translate("Voice"))
		widget4 := editorGui.Add("DropDownList", "x" . (x1 + 24) . " yp w" . (w1 - 24) . " W:Grow VbasicWindowsSpeakerDropDown Hidden", voices)

		widget17 := editorGui.Add("Button", "x" . x1 . " yp w23 h23 Default")
		widget17.OnEvent("Click", (*) => this.test())
		setButtonIcon(widget17, kIconsDirectory . "Start.ico", 1, "L4 T4 R4 B4")

		widget5 := editorGui.Add("Text", "x" . x0 . " ys+24 w110 h23 +0x200 VbasicWindowsSpeakerVolumeLabel Hidden", translate("Level"))
		widget6 := editorGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w180 W:Grow(0.3) 0x10 Range0-100 ToolTip VbasicSpeakerVolumeSlider Hidden")

		widget7 := editorGui.Add("Text", "x" . x0 . " yp+22 w110 h23 +0x200 VbasicWindowsSpeakerPitchLabel Hidden", translate("Pitch"))
		widget8 := editorGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w180 W:Grow(0.3) 0x10 Range-10-10 ToolTip VbasicSpeakerPitchSlider Hidden")

		widget9 := editorGui.Add("Text", "x" . x0 . " yp+22 w110 h23 +0x200 VbasicWindowsSpeakerSpeedLabel Hidden", translate("Speed"))
		widget10 := editorGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w180 W:Grow(0.3) 0x10 Range-10-10 ToolTip VbasicSpeakerSpeedSlider Hidden")

		this.iWindowsSynthesizerWidgets := [[editorGui["basicWindowsSpeakerLabel"], editorGui["basicWindowsSpeakerDropDown"], widget17]]

		this.iOtherWidgets := [[editorGui["basicWindowsSpeakerVolumeLabel"], editorGui["basicSpeakerVolumeSlider"]]
							 , [editorGui["basicWindowsSpeakerPitchLabel"], editorGui["basicSpeakerPitchSlider"]]
							 , [editorGui["basicWindowsSpeakerSpeedLabel"], editorGui["basicSpeakerSpeedSlider"]]]

		widget11 := editorGui.Add("Text", "x" . x0 . " ys+24 w140 h23 +0x200 VbasicAzureSubscriptionKeyLabel Hidden", translate("Subscription Key"))
		widget12 := editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h21 W:Grow VbasicAzureSubscriptionKeyEdit Hidden")
		widget12.OnEvent("Change", updateAzureVoices)

		widget13 := editorGui.Add("Text", "x" . x0 . " yp+24 w140 h23 +0x200 VbasicAzureTokenIssuerLabel Hidden", translate("Token Issuer Endpoint"))
		widget14 := editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h21 W:Grow VbasicAzureTokenIssuerEdit Hidden")
		widget14.OnEvent("Change", updateAzureVoices)

		voices := [translate("Random"), translate("Deactivated")]

		widget15 := editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200 VbasicAzureSpeakerLabel Hidden", translate("Voice"))
		widget16 := editorGui.Add("DropDownList", "x" . (x1 + 24) . " yp w" . (w1 - 24) . " W:Grow VbasicAzureSpeakerDropDown Hidden", voices)

		widget18 := editorGui.Add("Button", "x" . x1 . " yp w23 h23 Default")
		widget18.OnEvent("Click", (*) => this.test())
		setButtonIcon(widget18, kIconsDirectory . "Start.ico", 1, "L4 T4 R4 B4")

		editorGui.Add("Text", "x8 yp+106 w388 W:Grow 0x10")

		editorGui.Add("Button", "x120 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", (*) => this.iResult := kOk)
		editorGui.Add("Button", "x206 yp w80 h23", translate("&Cancel")).OnEvent("Click", (*) => this.iResult := kCancel)

		this.iAzureSynthesizerWidgets := [[editorGui["basicAzureSubscriptionKeyLabel"], editorGui["basicAzureSubscriptionKeyEdit"]]
										, [editorGui["basicAzureTokenIssuerLabel"], editorGui["basicAzureTokenIssuerEdit"]]
										, [editorGui["basicAzureSpeakerLabel"], editorGui["basicAzureSpeakerDropDown"], widget18]]

		widget19 := editorGui.Add("Text", "x" . x0 . " ys+24 w140 h23 +0x200 VbasicGoogleAPIKeyFileLabel Hidden", translate("API Key"))
		widget20 := editorGui.Add("Edit", "x" . x1 . " yp w" . (w1 - 24) . " h21 W:Grow VbasicGoogleAPIKeyFileEdit Hidden")
		widget20.OnEvent("Change", updateGoogleVoices)

		widget21 := editorGui.Add("Button", "x" . (x1 + w1 - 23) . " yp w23 h23 X:Move Disabled VbasicGoogleAPIKeyFilePathButton Hidden", translate("..."))
		widget21.OnEvent("Click", chooseAPIKeyFilePath)

		voices := [translate("Random"), translate("Deactivated")]

		widget22 := editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200 VbasicGoogleSpeakerLabel Hidden", translate("Voice"))
		widget23 := editorGui.Add("DropDownList", "x" . (x1 + 24) . " yp w" . (w1 - 24) . " W:Grow VbasicGoogleSpeakerDropDown Hidden", voices)

		widget24 := editorGui.Add("Button", "x" . x1 . " yp w23 h23 Default Hidden")
		widget24.OnEvent("Click", (*) => this.test())
		setButtonIcon(widget24, kIconsDirectory . "Start.ico", 1, "L4 T4 R4 B4")

		this.iGoogleSynthesizerWidgets := [[editorGui["basicGoogleAPIKeyFileLabel"], editorGui["basicGoogleAPIKeyFileEdit"], widget21]
										 , [editorGui["basicGoogleSpeakerLabel"], editorGui["basicGoogleSpeakerDropDown"], widget24]]

		this.updateLanguage()

		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iWindowsSynthesizerWidgets)
		this.hideControls(this.iAzureSynthesizerWidgets)
		this.hideControls(this.iGoogleSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		this.iSynthesizerMode := "Init"
	}

	loadFromConfiguration(configuration, load := false) {
		local synthesizer, languageCode, languages, ignore, speaker

		super.loadFromConfiguration(configuration)

		if load {
			languageCode := getMultiMapValue(configuration, "Voice Control", "Language", getLanguage())
			languages := availableLanguages()

			if languages.Has(languageCode)
				this.iLanguage := languages[languageCode]
			else
				this.iLanguage := languageCode

			synthesizer := getMultiMapValue(configuration, "Voice Control", "Synthesizer", "dotNET")

			if (InStr(synthesizer, "Azure") == 1)
				synthesizer := "Azure"

			if (InStr(synthesizer, "Google") == 1)
				synthesizer := "Google"

			this.Value["voiceSynthesizer"] := inList(["Windows", "dotNET", "Azure", "Google"], synthesizer)

			this.Value["azureSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)
			this.Value["windowsSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.Windows", getMultiMapValue(configuration, "Voice Control", "Speaker", true))
			this.Value["dotNETSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.doNET", true)
			this.Value["googleSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)

			this.Value["azureSubscriptionKey"] := getMultiMapValue(configuration, "Voice Control", "SubscriptionKey", "")
			this.Value["azureTokenIssuer"] := getMultiMapValue(configuration, "Voice Control", "TokenIssuer", "")

			this.Value["googleAPIKeyFile"] := getMultiMapValue(configuration, "Voice Control", "APIKeyFile", "")

			this.Value["speakerVolume"] := getMultiMapValue(configuration, "Voice Control", "SpeakerVolume", 100)
			this.Value["speakerPitch"] := getMultiMapValue(configuration, "Voice Control", "SpeakerPitch", 0)
			this.Value["speakerSpeed"] := getMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", 0)

			if this.Configuration
				for ignore, speaker in ["windowsSpeaker", "dotNETSpeaker", "azureSpeaker", "googleSpeaker"]
					if (this.Value[speaker] == true)
						this.Value[speaker] := translate("Random")
					else if (this.Value[speaker] == false)
						this.Value[speaker] := translate("Deactivated")
		}
	}

	saveToConfiguration(configuration) {
		local windowsSpeaker := this.Control["basicWindowsSpeakerDropDown"].Text
		local azureSpeaker := this.Control["basicAzureSpeakerDropDown"].Text
		local googleSpeaker := this.Control["basicGoogleSpeakerDropDown"].Text

		super.saveToConfiguration(configuration)

		setMultiMapValue(configuration, "Voice Control", "Language", this.getCurrentLanguage())

		if (windowsSpeaker = translate("Random"))
			windowsSpeaker := true
		else if ((windowsSpeaker = translate("Deactivated")) || (windowsSpeaker = A_Space))
			windowsSpeaker := false

		if (azureSpeaker = translate("Random"))
			azureSpeaker := true
		else if ((azureSpeaker = translate("Deactivated")) || (azureSpeaker = A_Space))
			azureSpeaker := false

		if (this.Control["basicVoiceSynthesizerDropDown"].Value = 1) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "Windows")
			setMultiMapValue(configuration, "Voice Control", "Speaker", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)
		}
		else if (this.Control["basicVoiceSynthesizerDropDown"].Value = 2) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "dotNET")
			setMultiMapValue(configuration, "Voice Control", "Speaker", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)
		}
		else if (this.Control["basicVoiceSynthesizerDropDown"].Value = 3) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "Azure|" . Trim(this.Control["basicAzureTokenIssuerEdit"].Text) . "|" . Trim(this.Control["basicAzureSubscriptionKeyEdit"].Text))
			setMultiMapValue(configuration, "Voice Control", "Speaker", azureSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)
		}
		else {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "Google|" . Trim(this.Control["basicGoogleAPIKeyFileEdit"].Text))
			setMultiMapValue(configuration, "Voice Control", "Speaker", googleSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Google", googleSpeaker)
		}

		setMultiMapValue(configuration, "Voice Control", "Speaker.Azure", azureSpeaker)
		setMultiMapValue(configuration, "Voice Control", "SubscriptionKey", Trim(this.Control["basicAzureSubscriptionKeyEdit"].Text))
		setMultiMapValue(configuration, "Voice Control", "TokenIssuer", Trim(this.Control["basicAzureTokenIssuerEdit"].Text))

		setMultiMapValue(configuration, "Voice Control", "Speaker.Google", googleSpeaker)
		setMultiMapValue(configuration, "Voice Control", "APIKeyFile", Trim(this.Control["basicGoogleAPIKeyFileEdit"].Text))

		setMultiMapValue(configuration, "Voice Control", "SpeakerVolume", this.Control["basicSpeakerVolumeSlider"].Value)
		setMultiMapValue(configuration, "Voice Control", "SpeakerPitch", this.Control["basicSpeakerPitchSlider"].Value)
		setMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", this.Control["basicSpeakerSpeedSlider"].Value)
	}

	loadConfigurator(configuration) {
		this.loadFromConfiguration(configuration, true)

		this.Control["basicVoiceSynthesizerDropDown"].Choose(this.Value["voiceSynthesizer"])
		this.Control["basicVoiceSynthesizerDropDown"].LastValue := this.Value["voiceSynthesizer"]

		this.Control["basicAzureSubscriptionKeyEdit"].Text := this.Value["azureSubscriptionKey"]
		this.Control["basicAzureTokenIssuerEdit"].Text := this.Value["azureTokenIssuer"]

		this.Control["basicGoogleAPIKeyFileEdit"].Text := this.Value["googleAPIKeyFile"]

		this.Control["basicGoogleAPIKeyFilePathButton"].Enabled := false

		if (this.Value["voiceSynthesizer"] = 1)
			this.updateWindowsVoices(configuration)
		else if (this.Value["voiceSynthesizer"] = 2)
			this.updateDotNETVoices(configuration)

		this.updateAzureVoices(configuration)
		this.updateGoogleVoices(configuration)

		this.Control["basicSpeakerVolumeSlider"].Value := this.Value["speakerVolume"]
		this.Control["basicSpeakerPitchSlider"].Value := this.Value["speakerPitch"]
		this.Control["basicSpeakerSpeedSlider"].Value := this.Value["speakerSpeed"]
	}

	editSynthesizer(owner := false) {
		local window, x, y, w, h, configuration

		this.createGui(this.Configuration)

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		if getWindowPosition("Synthesizer Editor", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		this.loadConfigurator(this.Configuration)

		this.showWidgets()

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

	showWidgets() {
		local voiceSynthesizer := this.Control["basicVoiceSynthesizerDropDown"].Value

		if !voiceSynthesizer
			voiceSynthesizer := 1

		if (voiceSynthesizer == 1)
			this.showWindowsSynthesizerEditor()
		else if (voiceSynthesizer == 2)
			this.showDotNETSynthesizerEditor()
		else if (voiceSynthesizer == 3)
			this.showAzureSynthesizerEditor()
		else
			this.showGoogleSynthesizerEditor()
	}

	showWindowsSynthesizerEditor() {
		this.showControls(this.iTopWidgets)
		this.showControls(this.iWindowsSynthesizerWidgets)

		if ((this.iSynthesizerMode == false) || (this.iSynthesizerMode = "Init"))
			this.transposeControls(this.iOtherWidgets, 24 * this.iWindowsSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else
			throw "Internal error detected in VoiceControlConfigurator.showWindowsSynthesizerEditor..."

		this.showControls(this.iOtherWidgets)

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := "Windows"
	}

	showDotNETSynthesizerEditor() {
		this.showWindowsSynthesizerEditor()

		this.Control["basicWindowsSettingsButton"].Enabled := true

		this.iSynthesizerMode := "dotNET"
	}

	hideWindowsSynthesizerEditor() {
		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iWindowsSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		if ((this.iSynthesizerMode == "Windows") || (this.iSynthesizerMode == "dotNET"))
			this.transposeControls(this.iOtherWidgets, -24 * this.iWindowsSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else if (this.iSynthesizerMode != "Init")
			throw "Internal error detected in VoiceControlConfigurator.hideWindowsSynthesizerEditor..."

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := false
	}

	hideDotNETSynthesizerEditor() {
		this.hideWindowsSynthesizerEditor()

		this.Control["basicWindowsSettingsButton"].Enabled := false
	}

	showAzureSynthesizerEditor() {
		this.showControls(this.iTopWidgets)
		this.showControls(this.iAzureSynthesizerWidgets)

		this.iTopAzureCredentialsVisible := true

		if ((this.iSynthesizerMode == false) || (this.iSynthesizerMode = "Init"))
			this.transposeControls(this.iOtherWidgets, 24 * this.iAzureSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else
			throw "Internal error detected in VoiceControlConfigurator.showAzureSynthesizerEditor..."

		this.showControls(this.iOtherWidgets)

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := "Azure"
	}

	hideAzureSynthesizerEditor() {
		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iAzureSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		this.iTopAzureCredentialsVisible := false

		if (this.iSynthesizerMode == "Azure")
			this.transposeControls(this.iOtherWidgets, -24 * this.iAzureSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else if (this.iSynthesizerMode != "Init")
			throw "Internal error detected in VoiceControlConfigurator.hideAzureSynthesizerEditor..."

		this.Control["basicWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := false
	}

	showGoogleSynthesizerEditor() {
		this.showControls(this.iTopWidgets)
		this.showControls(this.iGoogleSynthesizerWidgets)

		this.iTopGoogleCredentialsVisible := true

		if ((this.iSynthesizerMode == false) || (this.iSynthesizerMode = "Init"))
			this.transposeControls(this.iOtherWidgets, 24 * this.iGoogleSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else
			throw "Internal error detected in VoiceControlConfigurator.showGoogleSynthesizerEditor..."

		this.showControls(this.iOtherWidgets)

		this.iSynthesizerMode := "Google"
	}

	hideGoogleSynthesizerEditor() {
		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iGoogleSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		this.iTopGoogleCredentialsVisible := false

		if (this.iSynthesizerMode == "Google")
			this.transposeControls(this.iOtherWidgets, -24 * this.iGoogleSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else if (this.iSynthesizerMode != "Init")
			throw "Internal error detected in VoiceControlConfigurator.hideWindowsSynthesizerEditor..."

		this.iSynthesizerMode := false
	}

	getCurrentLanguage() {
		local voiceLanguage := this.iLanguage
		local languages := availableLanguages()
		local languageCode, code, language, ignore, assistant, grammarFile, grammarLanguageCode

		for code, language in availableLanguages()
			if (language = voiceLanguage)
				return code

		for ignore, assistant in this.StepWizard.Definition
			for ignore, grammarFile in getFileNames(assistant . ".grammars.*", kUserGrammarsDirectory, kGrammarsDirectory) {
				SplitPath(grammarFile, , , &grammarLanguageCode)

				if languages.Has(grammarLanguageCode)
					language := languages[grammarLanguageCode]
				else
					language := grammarLanguageCode

				if (language = voiceLanguage)
					return grammarLanguageCode
			}

		return "en"
	}

	updateLanguage() {
		if (this.Control["basicVoiceSynthesizerDropDown"].Value = 1)
			this.updateWindowsVoices()
		else if (this.Control["basicVoiceSynthesizerDropDown"].Value = 2)
			this.updateDotNETVoices()

		this.updateAzureVoices()
		this.updateGoogleVoices()
	}

	loadVoices(synthesizer, configuration) {
		local language := this.getCurrentLanguage()
		local voices := SpeechSynthesizer(synthesizer, true, language).Voices[language].Clone()

		voices.InsertAt(1, translate("Deactivated"))
		voices.InsertAt(1, translate("Random"))

		return voices
	}

	loadWindowsVoices(configuration, &windowsSpeaker) {
		if configuration
			windowsSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Windows", getMultiMapValue(this.Configuration, "Voice Control", "Speaker", true))
		else {
			windowsSpeaker := this.Control["basicWindowsSpeakerDropDown"].Text

			configuration := this.Configuration
		}

		return this.loadVoices("Windows", configuration)
	}

	loadDotNETVoices(configuration, &dotNETSpeaker)	{
		if configuration
			dotNETSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
		else {
			dotNETSpeaker := this.Control["basicWindowsSpeakerDropDown"].Text

			configuration := this.Configuration
		}

		return this.loadVoices("dotNET", configuration)
	}

	updateWindowsVoices(configuration := false) {
		local windowsSpeaker, voices, chosen

		voices := this.loadWindowsVoices(configuration, &windowsSpeaker)
		chosen := inList(voices, windowsSpeaker)

		if (chosen == 0)
			chosen := 1

		this.Control["basicWindowsSpeakerDropDown"].Delete()
		this.Control["basicWindowsSpeakerDropDown"].Add(voices)
		this.Control["basicWindowsSpeakerDropDown"].Choose(chosen)
	}

	updateDotNETVoices(configuration := false) {
		local dotNETSpeaker, voices, chosen

		voices := this.loadDotNETVoices(configuration, &dotNETSpeaker)
		chosen := inList(voices, dotNETSpeaker)

		if (chosen == 0)
			chosen := 1

		this.Control["basicWindowsSpeakerDropDown"].Delete()
		this.Control["basicWindowsSpeakerDropDown"].Add(voices)
		this.Control["basicWindowsSpeakerDropDown"].Choose(chosen)
	}

	updateGoogleVoices(configuration := false) {
		local voices := []
		local googleSpeaker, chosen, language

		if configuration
			googleSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)
		else {
			googleSpeaker := this.Control["basicGoogleSpeakerDropDown"].Text

			configuration := this.Configuration
		}

		if (configuration && !googleSpeaker)
			googleSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Google", true)

		if (Trim(this.Control["basicGoogleAPIKeyFileEdit"].Text) != "") {
			language := this.getCurrentLanguage()

			voices := SpeechSynthesizer("Google|" . Trim(this.Control["basicGoogleAPIKeyFileEdit"].Text), true, language).Voices[language].Clone()
		}

		voices.InsertAt(1, translate("Deactivated"))
		voices.InsertAt(1, translate("Random"))

		chosen := inList(voices, googleSpeaker)

		if (chosen == 0)
			chosen := 1

		this.Control["basicGoogleSpeakerDropDown"].Delete()
		this.Control["basicGoogleSpeakerDropDown"].Add(voices)
		this.Control["basicGoogleSpeakerDropDown"].Choose(chosen)
	}

	updateAzureVoices(configuration := false) {
		local voices := []
		local language, chosen, azureSpeaker

		if configuration
			azureSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)
		else {
			configuration := this.Configuration

			azureSpeaker := this.Control["basicAzureSpeakerDropDown"].Text
		}

		if (configuration && !azureSpeaker)
			azureSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)

		if ((Trim(this.Control["basicAzureSubscriptionKeyEdit"].Text) != "") && (Trim(this.Control["basicAzureTokenIssuerEdit"].Text) != "")) {
			language := this.getCurrentLanguage()

			voices := SpeechSynthesizer("Azure|" . Trim(this.Control["basicAzureTokenIssuerEdit"].Text) . "|" . Trim(this.Control["basicAzureSubscriptionKeyEdit"].Text), true, language).Voices[language].Clone()
		}

		voices.InsertAt(1, translate("Deactivated"))
		voices.InsertAt(1, translate("Random"))

		chosen := inList(voices, azureSpeaker)

		if (chosen == 0)
			chosen := 1

		this.Control["basicAzureSpeakerDropDown"].Delete()
		this.Control["basicAzureSpeakerDropDown"].Add(voices)
		this.Control["basicAzureSpeakerDropDown"].Choose(chosen)
	}

	showControls(widgets) {
		local ignore, widget, widgetPart

		for ignore, widget in widgets
			for ignore, widgetPart in widget {
				widgetPart.Enabled := true
				widgetPart.Visible := true
			}
	}

	hideControls(widgets) {
		local ignore, widget, widgetPart

		for ignore, widget in widgets
			for ignore, widgetPart in widget {
				widgetPart.Enabled := false
				widgetPart.Visible := false
			}
	}

	transposeControls(widgets, offset, correction) {
		local ignore, widget, widgetPart
		local posY

		correction := 0

		for ignore, widget in widgets
			for ignore, widgetPart in widget {
				ControlGetPos( , &posY, , , widgetPart)

				posY := (posY + offset - correction)

				ControlMove( , posY, , , widgetPart)

				for ignore, resizer in this.Window.Resizers[widgetPart]
					resizer.OriginalY := posY
			}
	}

	test() {
		global kSimulatorConfiguration

		local configuration := newMultiMap()
		local synthesizer, language, voice, curSimulatorConfiguration

		this.StepWizard.SetupWizard.saveToConfiguration(configuration)
		this.saveToConfiguration(configuration)

		curSimulatorConfiguration := kSimulatorConfiguration

		kSimulatorConfiguration := configuration

		try {
			synthesizer := getMultiMapValue(configuration, "Voice Control", "Synthesizer", "dotNET")
			language := getMultiMapValue(configuration, "Voice Control", "Language", getLanguage())
			voice := getMultiMapValue(configuration, "Voice Control", "Speaker")

			synthesizer := SpeechSynthesizer(synthesizer, voice, language)

			synthesizer.setVolume(getMultiMapValue(configuration, "Voice Control", "SpeakerVolume"))
			synthesizer.setPitch(getMultiMapValue(configuration, "Voice Control", "SpeakerPitch"))
			synthesizer.setRate(getMultiMapValue(configuration, "Voice Control", "SpeakerSpeed"))

			synthesizer.speakTest()
		}
		finally {
			kSimulatorConfiguration := curSimulatorConfiguration
		}
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeBasicStepWizard() {
	SetupWizard.Instance.registerStepWizard(BasicStepWizard(SetupWizard.Instance, "Basic", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeBasicStepWizard()