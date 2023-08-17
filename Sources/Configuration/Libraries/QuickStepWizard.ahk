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

class SilentSetupPatch extends SetupPatch {
	install(wizard) {
		super.install(wizard, false)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; QuickStepWizard                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class QuickStepWizard extends StepWizard {
	iSimulatorsListView := false

	Pages {
		Get {
			if this.SetupWizard.isQuickSetupAvailable()
				return (1 + (this.SetupWizard.QuickSetup ? 1 : 0))
			else
				return 0
		}
	}

	saveToConfiguration(configuration) {

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
		local enIndex := 0
		local code, language, w, h, chosen, choices, ignore, grammarFile

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
			wizard.QuickSetup := (method = "Quick")

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

		widget1 := window.Add("HTMLViewer", "x" . (x - 10) . " y" . y . " w" . (width + 20) . " h140 W:Grow H:Grow Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Quick", "Quick.StartHeader." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.BackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "</body></html>"

		widget1.document.write(html)

		y += 150

		widget2 := window.Add("Picture", "x" . button1X . " y" . y . " w64 h64 vquickSetupButton Hidden X:Move(0.33)", kResourcesDirectory . (wizard.QuickSetup ? "Setup\Images\Quick Setup.ico" : "Setup\Images\Quick Setup Gray.ico"))
		widget2.OnEvent("Click", chooseMethod.Bind("Quick"))
		widget3 := window.Add("Text", "x" . button1X . " yp+68 w64 Hidden Center X:Move(0.33)", translate("Quick"))

		widget4 := window.Add("Picture", "x" . button2X . " y" . y . " w64 h64 vcustomSetupButton Hidden X:Move(0.66)", kResourcesDirectory . (!wizard.QuickSetup ? "Setup\Images\Full Setup.ico" : "Setup\Images\Full Setup Gray.ico"))
		widget4.OnEvent("Click", chooseMethod.Bind("Custom"))
		widget5 := window.Add("Text", "x" . button2X . " yp+68 w64 Hidden Center X:Move(0.66)", translate("Custom"))

		y += 100

		widget6 := window.Add("HTMLViewer", "x" . (x - 10) . " y" . y . " w" . (width + 20) . " h140 W:Grow H:Grow Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Quick", "Quick.StartFooter." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.BackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "</body></html>"

		widget6.document.write(html)

		this.registerWidgets(1, widget1, widget2, widget3, widget4, widget5, widget6)

		y -= 250

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Gears.ico")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Configuration"))

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

		widget8 := window.Add("Text", "x" . x . " yp+24 w86 h23 +0x200 Hidden", translate("Push-2-Talk"))
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

		widget12 := window.Add("Text", "x" . x . " yp+30 w110 h23 +0x200 Hidden Section", translate("Assistants"))
		widget13 := window.Add("Text", "yp+20 xp w" . width . " W:Grow 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		chosen := 0
		choices := []

		for code, language in languages {
			choices.Push(language)

			if (code = "en")
				enIndex := A_Index
		}

		for ignore, grammarFile in concatenate(getFileNames("Race Engineer.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory)
											 , getFileNames("Race Strategist.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory)
											 , getFileNames("Race Spotter.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory)) {
			SplitPath(grammarFile, , , &code)

			if !languages.Has(code) {
				choices.Push(code)

				if (code = "en")
					enIndex := choices.Length
			}
		}

		widget14 := window.Add("CheckBox", "x" . x . " yp+10 w16 h23 vquickREEnabledCheck Hidden" . (wizard.isModuleSelected("Race Engineer") ? " Checked" : ""))
		widget15 := window.Add("Text", "xp+16 yp w86 h23 +0x200 Hidden", translate("Race Engineer"))
		widget16 := window.Add("Edit", "xp+114 yp w96 VquickRENameEdit Hidden", "Jona")
		widget17 := window.Add("DropDownList", "xp+98 yp w96 VquickRELanguageDropDown Hidden Choose" . enIndex, choices)
		widget17.OnEvent("Change", loadVoice.Bind("Race Engineer"))
		widget18 := window.Add("DropDownList", "xp+98 yp w333 W:Grow VquickREVoiceDropDown Hidden")
		widget19 := window.Add("Button", "xp+335 yp-1 w23 h23 X:Move vquickRESettingsButton Hidden")
		widget19.OnEvent("Click", (*) => Run("explorer.exe ms-settings:speech"))
		setButtonIcon(widget19, kIconsDirectory . "General Settings.ico", 1)

		widget20 := window.Add("CheckBox", "x" . x . " yp+24 w16 h23 vquickRSEnabledCheck Hidden" . (wizard.isModuleSelected("Race Strategist") ? " Checked" : ""))
		widget21 := window.Add("Text", "xp+16 yp w86 h23 +0x200 Hidden", translate("Race Strategist"))
		widget22 := window.Add("Edit", "xp+114 yp w96 VquickRSNameEdit Hidden", "Khato")
		widget23 := window.Add("DropDownList", "xp+98 yp w96 VquickRSLanguageDropDown Hidden Choose" . enIndex, choices)
		widget23.OnEvent("Change", loadVoice.Bind("Race Strategist"))
		widget24 := window.Add("DropDownList", "xp+98 yp w333 W:Grow VquickRSVoiceDropDown Hidden")
		widget25 := window.Add("Button", "xp+335 yp-1 w23 h23 X:Move vquickRSSettingsButton Hidden")
		widget25.OnEvent("Click", (*) => Run("explorer.exe ms-settings:speech"))
		setButtonIcon(widget25, kIconsDirectory . "General Settings.ico", 1)

		widget26 := window.Add("CheckBox", "x" . x . " yp+24 w16 h23 vquickRSPEnabledCheck Hidden" . (wizard.isModuleSelected("Race Spotter") ? " Checked" : ""))
		widget27 := window.Add("Text", "xp+16 yp w86 h23 +0x200 Hidden", translate("Race Spotter"))
		widget28 := window.Add("Edit", "xp+114 yp w96 VquickRSPNameEdit Hidden", "Elisa")
		widget29 := window.Add("DropDownList", "xp+98 yp w96 VquickRSPLanguageDropDown Hidden Choose" . enIndex, choices)
		widget29.OnEvent("Change", loadVoice.Bind("Race Spotter"))
		widget30 := window.Add("DropDownList", "xp+98 yp w333 W:Grow VquickRSPVoiceDropDown Hidden")
		widget31 := window.Add("Button", "xp+335 yp-1 w23 h23 X:Move vquickRSPSettingsButton Hidden")
		widget31.OnEvent("Click", (*) => Run("explorer.exe ms-settings:speech"))
		setButtonIcon(widget31, kIconsDirectory . "General Settings.ico", 1)

		widget36 := window.Add("HTMLViewer", "x" . (x - 10) . " yp+30 w" . (width + 20) . " h100 W:Grow Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Quick", "Quick.FinishFooter." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.BackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><br>" . text . "</body></html>"

		widget36.document.write(html)

		widget37 := window.Add("Button", "x" . (x + Round((width / 2) - 45)) . " yp+100 w90 h23 X:Move(0.5) Hidden", translate("Finish"))
		widget37.OnEvent("Click", finishSetup)

		loop 37
			this.registerWidget(2, widget%A_Index%)
	}

	showPage(page) {
		local wizard := this.SetupWizard
		local chosen := 0
		local enIndex := 0
		local code, language, uiLanguage, startWithWindows, silentMode

		super.showPage(page)

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

		if (page = 2) {
			this.startSetup()

			this.loadSimulators()

			this.loadVoices()

			this.SetupWizard.QuickSetup := false
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
		super.updateState()

		if this.SetupWizard.QuickSetup {
			this.Control["quickSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Quick Setup.ico")
			this.Control["customSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Full Setup Gray.ico")
		}
		else {
			this.Control["quickSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Quick Setup Gray.ico")
			this.Control["customSetupButton"].Value := (kResourcesDirectory . "Setup\Images\Full Setup.ico")
		}
	}

	getLanguage(assistant) {
		local languageCode := "en"
		local languages := availableLanguages()
		local found := false
		local code, language, ignore, grammarFile, grammarLanguageCode, infix, voiceLanguage

		if (assistant = "Race Engineer")
			infix := "RE"
		else if (assistant = "Race Strategist")
			infix := "RS"
		else
			infix := "RSP"

		voiceLanguage := this.Control["quick" . infix . "LanguageDropDown"].Text

		for code, language in availableLanguages()
			if (language = voiceLanguage) {
				found := true

				languageCode := code
			}

		if !found
			for ignore, grammarFile in getFileNames("Race Engineer.grammars.*", kUserGrammarsDirectory, kGrammarsDirectory) {
				SplitPath(grammarFile, , , &grammarLanguageCode)

				if languages.Has(grammarLanguageCode)
					language := languages[grammarLanguageCode]
				else
					language := grammarLanguageCode

				if (language = voiceLanguage) {
					languageCode := grammarLanguageCode

					break
				}
			}

		return languageCode
	}

	getSpeed(assistant) {
		if (assistant = "Race Engineer")
			return 1
		else if (assistant = "Race Strategist")
			return 0
		else
			return 1
	}

	locateSimulator(name, fileName) {
		local wizard := this.StepWizard
		local wasInstalled := wizard.isApplicationInstalled(name)

		wizard.locateApplication(name, fileName, false)

		if !wasInstalled
			wizard.selectApplication(name, true, false)

		this.loadSimulators()
	}

	loadVoices(assistant := false) {
		local assistants := (assistant ? [assistant] : ["Race Engineer", "Race Strategist", "Race Spotter"])
		local voices, language, ignore, dropDown

		for ignore, assistant in assistants {
			language := this.getLanguage(assistant)

			voices := SpeechSynthesizer("dotNET", true, language).Voices[language]

			if (assistant = "Race Engineer")
				dropDown := this.Control["quickREVoiceDropDown"]
			else if (assistant = "Race Strategist")
				dropDown := this.Control["quickRSVoiceDropDown"]
			else
				dropDown := this.Control["quickRSPVoiceDropDown"]

			dropDown.Delete()
			dropDown.Add(voices)
			dropDown.Choose((voices.Length > 0) ? 1 : 0)
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

	startSetup() {
		local wizard := this.SetupWizard
		local ignore, module

		for ignore, module in wizard.Steps["Modules"].Definition
			wizard.selectModule(module, false, false)

		wizard.selectModule("Voice Control", true, false)
		wizard.selectModule("Race Engineer", true, false)
		wizard.selectModule("Race Strategist", true, false)
		wizard.selectModule("Race Spotter", true, false)
	}

	assistantSetup(assistant) {
		local infix

		if (assistant = "Race Engineer")
			infix := "RE"
		else if (assistant = "Race Strategist")
			infix := "RS"
		else
			infix := "RSP"

		return {Language: this.getLanguage(assistant), Speed: this.getSpeed(assistant)
			  , Name: this.Control["quick" . infix . "NameEdit"].Text
			  , Voice: this.Control["quick" . infix . "VoiceDropDown"].Text}
	}

	finishSetup() {
		local voiceConfiguration := readMultiMap(kResourcesDirectory . "Setup\Presets\Voice Control Configuration.ini")
		local patch := substituteVariables(FileRead(kResourcesDirectory . "Setup\Presets\Configuration Patch.template")
										 , {engineerLanguage: this.assistantSetup("Race Engineer").Language
										  , engineerSpeed: this.assistantSetup("Race Engineer").Speed
										  , engineerName: this.assistantSetup("Race Engineer").Name
										  , engineerVoice: this.assistantSetup("Race Engineer").Voice
										  , strategistLanguage: this.assistantSetup("Race Strategist").Language
										  , strategistSpeed: this.assistantSetup("Race Strategist").Speed
										  , strategistName: this.assistantSetup("Race Strategist").Name
										  , strategistVoice: this.assistantSetup("Race Strategist").Voice
										  , spotterLanguage: this.assistantSetup("Race Spotter").Language
										  , spotterSpeed: this.assistantSetup("Race Spotter").Speed
										  , spotterName: this.assistantSetup("Race Spotter").Name
										  , spotterVoice: this.assistantSetup("Race Spotter").Voice})
		local voicePreset := SilentSetupPatch("SpecialSpeakerConfiguration", kResourcesDirectory . "Setup\Presets\Configuration Patch.ini")
		local pushToTalkPreset := P2TConfiguration("PushToTalkConfiguration", kResourcesDirectory . "Setup\Presets\P2T Configuration.ini")
		local languageCode := "en"
		local code, language

		this.SetupWizard.uninstallPreset(voicePreset)
		this.SetupWizard.installPreset(voicePreset)

		deleteFile(kUserHomeDirectory . "Setup\Configuration Patch.ini", true)

		FileAppend(patch, kUserHomeDirectory . "Setup\Configuration Patch.ini")

		this.SetupWizard.uninstallPreset(pushToTalkPreset)
		if (this.Control["quickPushToTalkMethodDropDown"].Value = 2)
			this.SetupWizard.installPreset(pushToTalkPreset)

		setMultiMapValue(voiceConfiguration, "Voice Control", "Language", getLanguage())
		setMultiMapValue(voiceConfiguration, "Voice Control", "PushToTalk", this.Control["quickPushToTalkEdit"].Text)
		setMultiMapValue(voiceConfiguration, "Voice Control", "Synthesizer", "dotNet")
		setMultiMapValue(voiceConfiguration, "Voice Control", "Speaker", true)
		setMultiMapValue(voiceConfiguration, "Voice Control", "Recognizer", "Desktop")
		setMultiMapValue(voiceConfiguration, "Voice Control", "Listener", true)

		writeMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini", voiceConfiguration)

		for code, language in availableLanguages()
			if (language = this.Control["quickUILanguageDropDown"].Text) {
				languageCode := code

				break
			}

		this.SetupWizard.setGeneralConfiguration(languageCode, true, false)
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