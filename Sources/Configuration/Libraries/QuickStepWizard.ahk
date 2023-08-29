;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Quick Step Wizard               ;;;
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
;;; QuickStepWizard                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class QuickStepWizard extends StepWizard {
	iSimulatorsListView := false

	iAssistants := CaseInsenseMap()
	iKeys := CaseInsenseMap()

	Pages {
		Get {
			return (1 + (this.QuickSetup ? 1 : 0))
		}
	}

	QuickSetup {
		Get {
			return this.SetupWizard.QuickSetup
		}

		Set {
			this.SetupWizard.QuickSetup := value

			if this.SetupWizard.QuickSetup {
				this.Control["quickSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Quick Setup.ico")
				this.Control["customSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Full Setup Gray.ico")
			}
			else {
				this.Control["quickSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Quick Setup Gray.ico")
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
					SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

					this.Control["quickPushToTalkEdit"].Text := hotkey

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
			if (method = "Quick") {
				if (wizard.isQuickSetupAvailable() || GetKeyState("Ctrl", "P"))
					this.QuickSetup := (GetKeyState("Ctrl", "P") ? "Force" : true)
				else
					this.QuickSetup := false
			}
			else
				this.QuickSetup := false

			wizard.updateState()
		}

		finishSetup(*) {
			local msgResult

			wizard.Window.Show()

			OnMessage(0x44, translateYesNoButtons)
			msgResult := MsgBox((translate("Do you want to generate the new configuration?") . "`n`n" . translate("Backup files will be saved for your current configuration in the `"Simulator Controller\Config`" folder in your user `"Documents`" folder.")), translate("Setup"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "Yes")
				if this.SetupWizard.finishSetup()
					ExitApp(0)
		}

		updateAssistant(assistant, *) {
			local enabled := window["quick" . this.Keys[assistant] . "EnabledCheck"].Value
			local found := false
			local ignore, key

			if !enabled
				for ignore, key in this.Keys
					if window["quick" . key . "EnabledCheck"].Value {
						found := true

						break
					}

			if (found || enabled)
				wizard.selectModule(assistant, enabled)
			else
				window["quick" . this.Keys[assistant] . "EnabledCheck"].Value := true
		}

		editSynthesizer(assistant, *) {
			this.editSynthesizer(assistant)
		}

		widget1 := window.Add("HTMLViewer", "x" . x . " y" . y . " w" . width . " h120 W:Grow Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Quick", "Quick.StartHeader." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.BackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "</body></html>"

		widget1.document.write(html)

		y += 150

		widget2 := window.Add("Picture", "x" . button1X . " y" . y . " w64 h64 vquickSetupButton Hidden X:Move(0.33)", kResourcesDirectory . (this.QuickSetup ? "Setup\Images\Quick Setup.ico" : "Setup\Images\Quick Setup Gray.ico"))
		widget2.OnEvent("Click", chooseMethod.Bind("Quick"))
		widget3 := window.Add("Text", "x" . button1X . " yp+68 w64 Hidden Center X:Move(0.33)", translate("Basic"))

		widget4 := window.Add("Picture", "x" . button2X . " y" . y . " w64 h64 vcustomSetupButton Hidden X:Move(0.66)", kResourcesDirectory . (!this.QuickSetup ? "Setup\Images\Full Setup.ico" : "Setup\Images\Full Setup Gray.ico"))
		widget4.OnEvent("Click", chooseMethod.Bind("Extended"))
		widget5 := window.Add("Text", "x" . button2X . " yp+68 w64 Hidden Center X:Move(0.66)", translate("Extended"))

		y += 100

		widget6 := window.Add("HTMLViewer", "x" . x . " y" . y . " w" . width . " h120 W:Grow Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Quick", "Quick.StartFooter." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.BackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "</body></html>"

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
		widget7 := window.Add("DropDownList", "xp+24 yp w96 VquickUILanguageDropDown Hidden", choices)

		widget8 := window.Add("Text", "x" . x . " yp+24 w86 h23 +0x200 Hidden", translate("Push-To-Talk"))
		widget9 := window.Add("Button", "xp+106 yp-1 w23 h23 VquickPushToTalkButton Hidden")
		widget9.OnEvent("Click", getPTTHotkey)
		setButtonIcon(widget9, kIconsDirectory . "Key.ico", 1)
		widget10 := window.Add("DropDownList", "xp+24 yp w96 Choose1 VquickPushToTalkMethodDropDown Hidden", collect(["Hold & Talk", "Press & Talk"], translate))
		widget11 := window.Add("Edit", "xp+98 yp w96 h21 VquickPushToTalkEdit Hidden")

		window.SetFont("Bold", "Arial")

		widget32 := window.Add("Text", "x" . col2X . " ys w110 h23 +0x200 Hidden Section", translate("Simulators"))
		widget33 := window.Add("Text", "yp+20 xp w" . col2Width . " W:Grow 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		widget34 := window.Add("ListView", "x" . col2X . " yp+10 w" . col2Width . " h120 W:Grow Section -Multi -LV0x10 Checked NoSort NoSortHdr Hidden", collect(["Simulation", "Path"], translate))
		widget34.OnEvent("Click", noSelect)
		widget34.OnEvent("DoubleClick", noSelect)
		widget34.OnEvent("ContextMenu", noSelect)

		this.iSimulatorsListView := widget34

		widget35 := window.Add("Button", "x" . (col2X + col2Width - 90) . " yp+127 w90 h23 X:Move Hidden", translate("Locate..."))
		widget35.OnEvent("Click", locateSimulator)

		window.SetFont("Bold", "Arial")

		widget12 := window.Add("Text", "x" . x . " yp+20 w110 h23 +0x200 Hidden Section", translate("Assistants"))
		widget13 := window.Add("Text", "yp+20 xp w" . width . " W:Grow 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		widget38 := window.Add("Text", "x" . (x + 16 + 114) . " yp+10 w96 h23 +0x200 Hidden", translate("Name"))
		widget39 := window.Add("Text", "xp+98 yp w96 h23 +0x200 Hidden", translate("Language"))
		widget40 := window.Add("Text", "xp+98 yp w96 h23 +0x200 Hidden", translate("Voice"))

		widget14 := window.Add("CheckBox", "x" . x . " yp+24 w16 h23 vquickREEnabledCheck Hidden" . (wizard.isModuleSelected("Race Engineer") ? " Checked" : ""))
		widget14.OnEvent("Click", updateAssistant.Bind("Race Engineer"))
		widget15 := window.Add("Text", "xp+16 yp w86 h23 +0x200 Hidden", translate("Race Engineer"))
		widget16 := window.Add("Edit", "xp+114 yp w96 VquickRENameEdit Hidden", "Jona")
		widget17 := window.Add("DropDownList", "xp+98 yp w96 VquickRELanguageDropDown Hidden")
		widget17.OnEvent("Change", loadVoice.Bind("Race Engineer"))
		widget18 := window.Add("DropDownList", "xp+98 yp w333 W:Grow VquickREVoiceDropDown Hidden")
		widget19 := window.Add("Button", "xp+335 yp-1 w23 h23 X:Move vquickRESettingsButton Hidden")
		widget19.OnEvent("Click", editSynthesizer.Bind("Race Engineer"))
		setButtonIcon(widget19, kIconsDirectory . "General Settings.ico", 1)

		widget20 := window.Add("CheckBox", "x" . x . " yp+24 w16 h23 vquickRSEnabledCheck Hidden" . (wizard.isModuleSelected("Race Strategist") ? " Checked" : ""))
		widget20.OnEvent("Click", updateAssistant.Bind("Race Strategist"))
		widget21 := window.Add("Text", "xp+16 yp w86 h23 +0x200 Hidden", translate("Race Strategist"))
		widget22 := window.Add("Edit", "xp+114 yp w96 VquickRSNameEdit Hidden", "Khato")
		widget23 := window.Add("DropDownList", "xp+98 yp w96 VquickRSLanguageDropDown Hidden")
		widget23.OnEvent("Change", loadVoice.Bind("Race Strategist"))
		widget24 := window.Add("DropDownList", "xp+98 yp w333 W:Grow VquickRSVoiceDropDown Hidden")
		widget25 := window.Add("Button", "xp+335 yp-1 w23 h23 X:Move vquickRSSettingsButton Hidden")
		widget25.OnEvent("Click", editSynthesizer.Bind("Race Strategist"))
		setButtonIcon(widget25, kIconsDirectory . "General Settings.ico", 1)

		widget26 := window.Add("CheckBox", "x" . x . " yp+24 w16 h23 vquickRSPEnabledCheck Hidden" . (wizard.isModuleSelected("Race Spotter") ? " Checked" : ""))
		widget26.OnEvent("Click", updateAssistant.Bind("Race Spotter"))
		widget27 := window.Add("Text", "xp+16 yp w86 h23 +0x200 Hidden", translate("Race Spotter"))
		widget28 := window.Add("Edit", "xp+114 yp w96 VquickRSPNameEdit Hidden", "Elisa")
		widget29 := window.Add("DropDownList", "xp+98 yp w96 VquickRSPLanguageDropDown Hidden")
		widget29.OnEvent("Change", loadVoice.Bind("Race Spotter"))
		widget30 := window.Add("DropDownList", "xp+98 yp w333 W:Grow VquickRSPVoiceDropDown Hidden")
		widget31 := window.Add("Button", "xp+335 yp-1 w23 h23 X:Move vquickRSPSettingsButton Hidden")
		widget31.OnEvent("Click", editSynthesizer.Bind("Race Spotter"))
		setButtonIcon(widget31, kIconsDirectory . "General Settings.ico", 1)

		widget36 := window.Add("HTMLViewer", "x" . x . " yp+30 w" . width . " h105 W:Grow H:Grow(0.8) Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Quick", "Quick.FinishFooter." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.BackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "</body></html>"

		widget36.document.write(html)

		widget37 := window.Add("Button", "x" . (x + Round((width / 2) - 45)) . " yp+106 w90 h60 X:Move(0.4) W:Grow(0.2) Y:Move(0.8) H:Grow(0.2) Hidden")
		setButtonIcon(widget37, kResourcesDirectory . "\Setup\Images\Finish Line.png", 1, "w80 h53")
		widget37.OnEvent("Click", finishSetup)

		loop 40
			this.registerWidget(2, widget%A_Index%)
	}

	loadStepDefinition(definition) {
		local wizard := this.SetupWizard
		local ignore, assistant, key

		super.loadStepDefinition(definition)

		for ignore, assistant in this.Definition {
			key := getMultiMapValue(wizard.Definition, "Setup.Quick", "Quick.Keys." . assistant)

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
		local code, language, uiLanguage, startWithWindows, silentMode, ignore, preset

		static installed := false

		if (page = 2) {
			fullInstall := (!installed && (!isDevelopment() || (GetKeyState("Ctrl", "P") && GetKeyState("Shift", "P"))))

			wizard.selectModule("Voice Control", true, false)

			for ignore, assistant in this.Definition
				enabled := (enabled || wizard.isModuleSelected(assistant))

			if !enabled
				wizard.selectModule(this.Definition[1], true, false)

			wizard.getGeneralConfiguration(&uiLanguage, &startWithWindows, &silentMode)

			for code, language in availableLanguages() {
				if (code = uiLanguage)
					chosen := A_Index
				else if (code = "en")
					enIndex := A_Index
			}

			if (chosen == 0)
				chosen := enIndex

			this.Control["quickUILanguageDropDown"].Choose(chosen)

			this.Control["quickPushToTalkEdit"].Text := getMultiMapValue(readMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini")
																	   , "Voice Control", "PushToTalk", "")


			this.Control["quickPushToTalkMethodDropDown"].Value := 1

			for ignore, preset in wizard.loadPresets()
				if isInstance(preset, P2TConfiguration) {
					this.Control["quickPushToTalkMethodDropDown"].Value := 2

					break
				}

			this.loadSetup(!fullInstall)

			this.QuickSetup := false
		}

		super.showPage(page)

		if fullInstall {
			wizard.installSoftware()

			this.loadSimulators()

			installed := true
		}
	}

	hidePage(page) {
		if (page = 2) {
			this.updateSelectedSimulators()

			this.finishSetup()
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

			this.Control["quick" . key . "EnabledCheck"].Value := (enabled != false)
			this.Control["quick" . key . "LanguageDropDown"].Enabled := enabled
			this.Control["quick" . key . "VoiceDropDown"].Enabled := enabled
			this.Control["quick" . key . "NameEdit"].Enabled := enabled
			this.Control["quick" . key . "SettingsButton"].Enabled := enabled
		}
	}

	assistantEnabled(assistant, editor := true) {
		if editor
			return (this.Control["quick" . this.Keys[assistant] . "EnabledCheck"].Value != 0)
		else
			return this.SetupWizard.isModuleSelected(assistant)
	}

	assistantName(assistant, editor := true) {
		if editor
			return this.Control["quick" . this.Keys[assistant] . "NameEdit"].Text
		else
			return this.SetupWizard.getModuleValue(assistant, "Name", this.assistantDefaults(assistant).Name)
	}

	assistantLanguage(assistant, editor := true) {
		local languages, found, code, language, ignore, grammarFile, grammarLanguageCode, voiceLanguage

		if editor {
			languages := availableLanguages()
			voiceLanguage := this.Control["quick" . this.Keys[assistant] . "LanguageDropDown"].Text

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

		voice := this.Control["quick" . this.Keys[assistant] . "VoiceDropDown"].Text

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
			defaults.%key% := getMultiMapValue(wizard.Definition, "Setup.Quick", "Quick.Defaults." . assistant . "." . key)

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

			dropDown := this.Control["quick" . this.Keys[assistant] . "VoiceDropDown"]

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

		this.Control["quick" . key . "EnabledCheck"].Value := (this.assistantEnabled(assistant, false) != false)
		this.Control["quick" . key . "NameEdit"].Text := this.assistantName(assistant, false)

		assistantLanguage := inList(languages, this.assistantLanguage(assistant, false))

		this.Control["quick" . key . "LanguageDropDown"].Delete()
		this.Control["quick" . key . "LanguageDropDown"].Add(choices)
		this.Control["quick" . key . "LanguageDropDown"].Choose(assistantLanguage ? assistantLanguage : 1)

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

	finishSetup() {
		local wizard := this.SetupWizard
		local voiceConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini")
		local assistantSetups := {}
		local pushToTalkPreset := P2TConfiguration("PushToTalkConfiguration")
		local languageCode := "en"
		local code, language, ignore, key, value, assistant

		for key, assistant in this.Assistants
			assistantSetups.%key% := this.assistantSetup(assistant)

		wizard.uninstallPreset(pushToTalkPreset)
		if (this.Control["quickPushToTalkMethodDropDown"].Value = 2)
			wizard.installPreset(pushToTalkPreset)

		for key, assistant in this.Assistants {
			wizard.selectModule(assistant, assistantSetups.%key%.Enabled, false)

			for ignore, value in ["Name", "Language", "Synthesizer", "Voice", "Volume", "Pitch", "Speed"]
				wizard.setModuleValue(assistant, value, assistantSetups.%key%.%value%, false)
		}

		setMultiMapValue(voiceConfiguration, "Voice Control", "Language", getLanguage())
		setMultiMapValue(voiceConfiguration, "Voice Control", "PushToTalk", this.Control["quickPushToTalkEdit"].Text)
		setMultiMapValue(voiceConfiguration, "Voice Control", "Synthesizer", "dotNET")
		setMultiMapValue(voiceConfiguration, "Voice Control", "Speaker", true)
		setMultiMapValue(voiceConfiguration, "Voice Control", "Recognizer", "Desktop")
		setMultiMapValue(voiceConfiguration, "Voice Control", "Listener", true)

		writeMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini", voiceConfiguration)

		for code, language in availableLanguages()
			if (language = this.Control["quickUILanguageDropDown"].Text) {
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
			configuration := newMultiMap()

			setup := this.assistantSetup(assistant)

			setMultiMapValue(configuration, "Voice Control", "Language", setup.Language)
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", setup.Synthesizer)
			setMultiMapValue(configuration, "Voice Control", "Speaker", setup.Voice)
			setMultiMapValue(configuration, "Voice Control", "SpeakerVolume", (setup.Volume = "*") ? 100 : setup.Volume)
			setMultiMapValue(configuration, "Voice Control", "SpeakerPitch", (setup.Pitch = "*") ? 0 : setup.Pitch)
			setMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", (setup.Speed = "*") ? 0 : setup.Speed)

			if (InStr(setup.Synthesizer, "Azure") = 1) {
				setMultiMapValue(configuration, "Voice Control", "Speaker.Azure", setup.Voice)

				setup := string2Values("|", setup.Synthesizer)

				setMultiMapValue(configuration, "Voice Control", "SubscriptionKey", setup[2])
				setMultiMapValue(configuration, "Voice Control", "TokenIssuer", setup[3])
			}
			else if (setup.Synthesizer = "dotNET")
				setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", setup.Voice)
			else
				setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", setup.Voice)

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
	iOtherWidgets := []

	iTopAzureCredentialsVisible := false

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

		chooseVoiceSynthesizer(*) {
			local voiceSynthesizerDropDown := this.Control["quickVoiceSynthesizerDropDown"]
			local oldChoice := voiceSynthesizerDropDown.LastValue

			if (oldChoice == 1)
				this.hideWindowsSynthesizerEditor()
			else if (oldChoice == 2)
				this.hideDotNETSynthesizerEditor()
			else
				this.hideAzureSynthesizerEditor()

			if (voiceSynthesizerDropDown.Value == 1)
				this.showWindowsSynthesizerEditor()
			else if (voiceSynthesizerDropDown.Value == 2)
				this.showDotNETSynthesizerEditor()
			else
				this.showAzureSynthesizerEditor()

			if (voiceSynthesizerDropDown.Value <= 2)
				this.updateLanguage()

			voiceSynthesizerDropDown.LastValue := voiceSynthesizerDropDown.Value
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

		choices := ["Windows (Win32)", "Windows (.NET)", "Azure Cognitive Services"]
		chosen := 0

		widget1 := editorGui.Add("Text", "x" . x0 . " yp+10 w110 h23 +0x200 Section Hidden", translate("Speech Synthesizer"))
		widget2 := editorGui.Add("DropDownList", "x" . x1 . " yp w156 W:Grow(0.3) Choose" . chosen . "  VquickVoiceSynthesizerDropDown Hidden", choices)
		widget2.LastValue := chosen
		widget2.OnEvent("Change", chooseVoiceSynthesizer)

		editorGui.Add("Button", "xp+157 yp-1 w23 h23 X:Move(0.3) vquickWindowsSettingsButton Hidden").OnEvent("Click", (*) => Run("explorer.exe ms-settings:speech"))
		setButtonIcon(editorGui["quickWindowsSettingsButton"], kIconsDirectory . "General Settings.ico", 1)

		this.iTopWidgets := [[widget1, widget2, editorGui["quickWindowsSettingsButton"]]]

		voices := [translate("Random"), translate("Deactivated")]

		widget3 := editorGui.Add("Text", "x" . x0 . " ys+24 w110 h23 +0x200 VquickWindowsSpeakerLabel Hidden", translate("Voice"))
		widget4 := editorGui.Add("DropDownList", "x" . (x1 + 24) . " yp w" . (w1 - 24) . " W:Grow VquickWindowsSpeakerDropDown Hidden", voices)

		widget17 := editorGui.Add("Button", "x" . x1 . " yp w23 h23 Default")
		widget17.OnEvent("Click", (*) => this.test())
		setButtonIcon(widget17, kIconsDirectory . "Start.ico", 1, "L4 T4 R4 B4")

		widget5 := editorGui.Add("Text", "x" . x0 . " ys+24 w110 h23 +0x200 VquickWindowsSpeakerVolumeLabel Hidden", translate("Level"))
		widget6 := editorGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w180 W:Grow(0.3) 0x10 Range0-100 ToolTip VquickSpeakerVolumeSlider Hidden")

		widget7 := editorGui.Add("Text", "x" . x0 . " yp+22 w110 h23 +0x200 VquickWindowsSpeakerPitchLabel Hidden", translate("Pitch"))
		widget8 := editorGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w180 W:Grow(0.3) 0x10 Range-10-10 ToolTip VquickSpeakerPitchSlider Hidden")

		widget9 := editorGui.Add("Text", "x" . x0 . " yp+22 w110 h23 +0x200 VquickWindowsSpeakerSpeedLabel Hidden", translate("Speed"))
		widget10 := editorGui.Add("Slider", "Center Thick15 x" . x1 . " yp+2 w180 W:Grow(0.3) 0x10 Range-10-10 ToolTip VquickSpeakerSpeedSlider Hidden")

		this.iWindowsSynthesizerWidgets := [[editorGui["quickWindowsSpeakerLabel"], editorGui["quickWindowsSpeakerDropDown"], widget17]]

		this.iOtherWidgets := [[editorGui["quickWindowsSpeakerVolumeLabel"], editorGui["quickSpeakerVolumeSlider"]]
							 , [editorGui["quickWindowsSpeakerPitchLabel"], editorGui["quickSpeakerPitchSlider"]]
							 , [editorGui["quickWindowsSpeakerSpeedLabel"], editorGui["quickSpeakerSpeedSlider"]]]

		widget11 := editorGui.Add("Text", "x" . x0 . " ys+24 w140 h23 +0x200 VquickAzureSubscriptionKeyLabel Hidden", translate("Subscription Key"))
		widget12 := editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h21 W:Grow VquickAzureSubscriptionKeyEdit Hidden")
		widget12.OnEvent("Change", updateAzureVoices)

		widget13 := editorGui.Add("Text", "x" . x0 . " yp+24 w140 h23 +0x200 VquickAzureTokenIssuerLabel Hidden", translate("Token Issuer Endpoint"))
		widget14 := editorGui.Add("Edit", "x" . x1 . " yp w" . w1 . " h21 W:Grow VquickAzureTokenIssuerEdit Hidden")
		widget14.OnEvent("Change", updateAzureVoices)

		voices := [translate("Random"), translate("Deactivated")]

		widget15 := editorGui.Add("Text", "x" . x0 . " yp+24 w110 h23 +0x200 VquickAzureSpeakerLabel Hidden", translate("Voice"))
		widget16 := editorGui.Add("DropDownList", "x" . (x1 + 24) . " yp w" . (w1 - 24) . " W:Grow VquickAzureSpeakerDropDown Hidden", voices)

		widget18 := editorGui.Add("Button", "x" . x1 . " yp w23 h23 Default")
		widget18.OnEvent("Click", (*) => this.test())
		setButtonIcon(widget18, kIconsDirectory . "Start.ico", 1, "L4 T4 R4 B4")

		editorGui.Add("Text", "x8 yp+106 w388 W:Grow 0x10")

		editorGui.Add("Button", "x120 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", (*) => this.iResult := kOk)
		editorGui.Add("Button", "x206 yp w80 h23", translate("&Cancel")).OnEvent("Click", (*) => this.iResult := kCancel)

		this.iAzureSynthesizerWidgets := [[editorGui["quickAzureSubscriptionKeyLabel"], editorGui["quickAzureSubscriptionKeyEdit"]]
										, [editorGui["quickAzureTokenIssuerLabel"], editorGui["quickAzureTokenIssuerEdit"]]
										, [editorGui["quickAzureSpeakerLabel"], editorGui["quickAzureSpeakerDropDown"], widget18]]

		this.updateLanguage()

		this.hideControls(this.iTopWidgets)
		this.hideControls(this.iWindowsSynthesizerWidgets)
		this.hideControls(this.iAzureSynthesizerWidgets)
		this.hideControls(this.iOtherWidgets)

		this.iSynthesizerMode := "Init"
	}

	loadFromConfiguration(configuration, load := false) {
		local synthesizer, languageCode, languages

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

			this.Value["voiceSynthesizer"] := inList(["Windows", "dotNET", "Azure"], synthesizer)

			this.Value["azureSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)
			this.Value["windowsSpeaker"] := getMultiMapValue(configuration, "Voice Control", "Speaker.Windows",  getMultiMapValue(configuration, "Voice Control", "Speaker", true))

			this.Value["azureSubscriptionKey"] := getMultiMapValue(configuration, "Voice Control", "SubscriptionKey", "")
			this.Value["azureTokenIssuer"] := getMultiMapValue(configuration, "Voice Control", "TokenIssuer", "")

			this.Value["speakerVolume"] := getMultiMapValue(configuration, "Voice Control", "SpeakerVolume", 100)
			this.Value["speakerPitch"] := getMultiMapValue(configuration, "Voice Control", "SpeakerPitch", 0)
			this.Value["speakerSpeed"] := getMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", 0)

			if this.Configuration {
				if (this.Value["windowsSpeaker"] == true)
					this.Value["windowsSpeaker"] := translate("Random")
				else if (this.Value["windowsSpeaker"] == false)
					this.Value["windowsSpeaker"] := translate("Deactivated")

				if (this.Value["azureSpeaker"] == true)
					this.Value["azureSpeaker"] := translate("Random")
				else if (this.Value["azureSpeaker"] == false)
					this.Value["azureSpeaker"] := translate("Deactivated")
			}
		}
	}

	saveToConfiguration(configuration) {
		local windowsSpeaker := this.Control["quickWindowsSpeakerDropDown"].Text
		local azureSpeaker := this.Control["quickAzureSpeakerDropDown"].Text

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

		if (this.Control["quickVoiceSynthesizerDropDown"].Value = 1) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "Windows")
			setMultiMapValue(configuration, "Voice Control", "Speaker", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
		}
		else if (this.Control["quickVoiceSynthesizerDropDown"].Value = 2) {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "dotNET")
			setMultiMapValue(configuration, "Voice Control", "Speaker", windowsSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", windowsSpeaker)
		}
		else {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "Azure|" . this.Control["quickAzureTokenIssuerEdit"].Text . "|" . this.Control["quickAzureSubscriptionKeyEdit"].Text)
			setMultiMapValue(configuration, "Voice Control", "Speaker", azureSpeaker)
			setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", true)
			setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
		}

		setMultiMapValue(configuration, "Voice Control", "Speaker.Azure", azureSpeaker)
		setMultiMapValue(configuration, "Voice Control", "SubscriptionKey", this.Control["quickAzureSubscriptionKeyEdit"].Text)
		setMultiMapValue(configuration, "Voice Control", "TokenIssuer", this.Control["quickAzureTokenIssuerEdit"].Text)

		setMultiMapValue(configuration, "Voice Control", "SpeakerVolume", this.Control["quickSpeakerVolumeSlider"].Value)
		setMultiMapValue(configuration, "Voice Control", "SpeakerPitch", this.Control["quickSpeakerPitchSlider"].Value)
		setMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", this.Control["quickSpeakerSpeedSlider"].Value)
	}

	loadConfigurator(configuration) {
		this.loadFromConfiguration(configuration, true)

		this.Control["quickVoiceSynthesizerDropDown"].Choose(this.Value["voiceSynthesizer"])
		this.Control["quickVoiceSynthesizerDropDown"].LastValue := this.Value["voiceSynthesizer"]

		this.Control["quickAzureSubscriptionKeyEdit"].Text := this.Value["azureSubscriptionKey"]
		this.Control["quickAzureTokenIssuerEdit"].Text := this.Value["azureTokenIssuer"]

		if (this.Value["voiceSynthesizer"] = 1)
			this.updateWindowsVoices(configuration)
		else if (this.Value["voiceSynthesizer"] = 2)
			this.updateDotNETVoices(configuration)

		this.updateAzureVoices(configuration)

		this.Control["quickSpeakerVolumeSlider"].Value := this.Value["speakerVolume"]
		this.Control["quickSpeakerPitchSlider"].Value := this.Value["speakerPitch"]
		this.Control["quickSpeakerSpeedSlider"].Value := this.Value["speakerSpeed"]
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
		local voiceSynthesizer := this.Control["quickVoiceSynthesizerDropDown"].Value

		if !voiceSynthesizer
			voiceSynthesizer := 1

		if (voiceSynthesizer == 1)
			this.showWindowsSynthesizerEditor()
		else if (voiceSynthesizer == 2)
			this.showDotNETSynthesizerEditor()
		else
			this.showAzureSynthesizerEditor()
	}

	showWindowsSynthesizerEditor() {
		this.showControls(this.iTopWidgets)
		this.showControls(this.iWindowsSynthesizerWidgets)

		if ((this.iSynthesizerMode == false) || (this.iSynthesizerMode = "Init"))
			this.transposeControls(this.iOtherWidgets, 24 * this.iWindowsSynthesizerWidgets.Length, this.Window.TitleBarHeight)
		else
			throw "Internal error detected in VoiceControlConfigurator.showWindowsSynthesizerEditor..."

		this.showControls(this.iOtherWidgets)

		this.Control["quickWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := "Windows"
	}

	showDotNETSynthesizerEditor() {
		this.showWindowsSynthesizerEditor()

		this.Control["quickWindowsSettingsButton"].Enabled := true

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

		this.Control["quickWindowsSettingsButton"].Enabled := false

		this.iSynthesizerMode := false
	}

	hideDotNETSynthesizerEditor() {
		this.hideWindowsSynthesizerEditor()

		this.Control["quickWindowsSettingsButton"].Enabled := false
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

		this.Control["quickWindowsSettingsButton"].Enabled := false

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

		this.Control["quickWindowsSettingsButton"].Enabled := false

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
		if (this.Control["quickVoiceSynthesizerDropDown"].Value = 1)
			this.updateWindowsVoices()
		else if (this.Control["quickVoiceSynthesizerDropDown"].Value = 2)
			this.updateDotNETVoices()

		this.updateAzureVoices()
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
			windowsSpeaker := this.Control["quickWindowsSpeakerDropDown"].Text

			configuration := this.Configuration
		}

		return this.loadVoices("Windows", configuration)
	}

	loadDotNETVoices(configuration, &dotNETSpeaker)	{
		if configuration
			dotNETSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", true)
		else {
			dotNETSpeaker := this.Control["quickWindowsSpeakerDropDown"].Text

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

		this.Control["quickWindowsSpeakerDropDown"].Delete()
		this.Control["quickWindowsSpeakerDropDown"].Add(voices)
		this.Control["quickWindowsSpeakerDropDown"].Choose(chosen)
	}

	updateDotNETVoices(configuration := false) {
		local dotNETSpeaker, voices, chosen

		voices := this.loadDotNETVoices(configuration, &dotNETSpeaker)
		chosen := inList(voices, dotNETSpeaker)

		if (chosen == 0)
			chosen := 1

		this.Control["quickWindowsSpeakerDropDown"].Delete()
		this.Control["quickWindowsSpeakerDropDown"].Add(voices)
		this.Control["quickWindowsSpeakerDropDown"].Choose(chosen)
	}

	updateAzureVoices(configuration := false) {
		local voices := []
		local language, chosen, azureSpeaker

		if configuration
			azureSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)
		else {
			configuration := this.Configuration

			azureSpeaker := this.Control["quickAzureSpeakerDropDown"].Text
		}

		if (configuration && !azureSpeaker)
			azureSpeaker := getMultiMapValue(configuration, "Voice Control", "Speaker.Azure", true)

		if ((this.Control["quickAzureSubscriptionKeyEdit"].Text != "") && (this.Control["quickAzureTokenIssuerEdit"].Text != "")) {
			language := this.getCurrentLanguage()

			voices := SpeechSynthesizer("Azure|" . this.Control["quickAzureTokenIssuerEdit"].Text . "|" . this.Control["quickAzureSubscriptionKeyEdit"].Text, true, language).Voices[language].Clone()
		}

		voices.InsertAt(1, translate("Deactivated"))
		voices.InsertAt(1, translate("Random"))

		chosen := inList(voices, azureSpeaker)

		if (chosen == 0)
			chosen := 1

		this.Control["quickAzureSpeakerDropDown"].Delete()
		this.Control["quickAzureSpeakerDropDown"].Add(voices)
		this.Control["quickAzureSpeakerDropDown"].Choose(chosen)
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

initializeQuickStepWizard() {
	SetupWizard.Instance.registerStepWizard(QuickStepWizard(SetupWizard.Instance, "Quick", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeQuickStepWizard()