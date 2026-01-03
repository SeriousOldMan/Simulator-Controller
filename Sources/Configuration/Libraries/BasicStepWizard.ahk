;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Basic Step Wizard               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\SpeechSynthesizer.ahk"
#Include "AssistantBoosterEditor.ahk"
#Include "TranslatorEditor.ahk"
#Include "SynthesizerEditor.ahk"


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

	iSynthesizerEditor := false

	Pages {
		Get {
			if this.SetupWizard.Initialize
				return (1 + (this.BasicSetup ? 1 : 0))
			else
				return 1
		}
	}

	BasicSetup {
		Get {
			return this.SetupWizard.BasicSetup
		}

		Set {
			local window := this.SetupWizard.Window

			this.SetupWizard.BasicSetup := value

			if this.SetupWizard.BasicSetup {
				this.Control["basicSetupButton"].Value := window.Theme.RecolorizeImage(kResourcesDirectory . "Setup\Images\Quick Setup.ico")
				this.Control["customSetupButton"].Value := window.Theme.RecolorizeImage(kResourcesDirectory . "Setup\Images\Full Setup Gray.ico")
			}
			else {
				this.Control["basicSetupButton"].Value := window.Theme.RecolorizeImage(kResourcesDirectory . "Setup\Images\Quick Setup Gray.ico")
				this.Control["customSetupButton"].Value := window.Theme.RecolorizeImage(kResourcesDirectory . "Setup\Images\Full Setup.ico")
			}

			return value
		}
	}

	Assistants[key?] {
		Get {
			return (isSet(key) ? this.iAssistants[key] : this.iAssistants)
		}

		Set {
			return (isSet(key) ? (this.iAssistants[key] := value) : (this.iAssistants := value))
		}
	}

	Keys[key?] {
		Get {
			return (isSet(key) ? this.iKeys[key] : this.iKeys)
		}

		Set {
			return (isSet(key) ? (this.iKeys[key] := value) : (this.iKeys := value))
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
			fileName := withBlockedWindows(FileSelect, 1, "", substituteVariables(translate("Select %name% executable..."), {name: translate("Simulator")}), "Executable (*.exe)")
			OnMessage(0x44, translateSelectCancelButtons, 0)

			if (fileName != "") {
				if isDebug()
					logMessage(kLogDebug, "Locating " . fileName . "...")

				simulator := standardApplication(this.SetupWizard.Definition, ["Applications.Simulators"], fileName)

				if simulator {
					if isDebug()
						logMessage(kLogDebug, "Found " . simulator)

					this.locateSimulator(simulator, fileName)
				}
			}
		}

		chooseLanguage(assistant, *) {
			local dropDown := window["basic" . this.Keys[assistant] . "LanguageDropDown"]
			local selectedText := dropDown.Text

			if (InStr(selectedText, translate("Translator")) || InStr(selectedText, translate(" (translated)..."))) {
				if this.editTranslator(assistant)
					this.loadVoices(assistant)

				if !this.SetupWizard.getModuleValue(assistant, "Language.Translated", false)
					if dropDown.HasProp("LastValue")
						dropDown.Choose(dropDown.LastValue)
					else
						dropDown.Choose(1)
			}
			else if InStr(selectedText, translate("---------------------------------------------")) {
				if dropDown.HasProp("LastValue")
					dropDown.Choose(dropDown.LastValue)
				else
					dropDown.Choose(1)
			}
			else {
				this.SetupWizard.setModuleValue(assistant, "Language.Translated", false, false)

				this.loadVoices(assistant)
			}

			dropDown.LastValue := dropDown.Value
		}

		chooseMethod(method, *) {
			if (method = "Basic") {
				/*
				if (wizard.isBasicSetupAvailable() || GetKeyState("Ctrl"))
					this.BasicSetup := (GetKeyState("Ctrl") ? "Force" : true)
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
			msgResult := withBlockedWindows(MsgDlg, (translate("Do you want to generate the new configuration?") . "`n`n" . translate("Backup files will be saved for your current configuration in the `"Simulator Controller\Config`" folder in your user `"Documents`" folder.")), translate("Setup "), 262436)
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

		editBooster(assistant, *) {
			this.editBooster(assistant)
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

		html := "<html><body style='background-color: #" . window.Theme.WindowBackColor . "; overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, p, body { color: #" . window.Theme.TextColor . "}</style><br>" . text . "</body></html>"

		widget1.document.write(html)

		y += 150

		widget2 := window.Add("Picture", "x" . button1X . " y" . y . " w64 h64 vbasicSetupButton Hidden X:Move(0.33)", window.Theme.RecolorizeImage(kResourcesDirectory . (this.BasicSetup ? "Setup\Images\Quick Setup.ico" : "Setup\Images\Quick Setup Gray.ico")))
		widget2.OnEvent("Click", chooseMethod.Bind("Basic"))
		widget3 := window.Add("Text", "x" . button1X . " yp+68 w64 Hidden Center X:Move(0.33)", translate("Basic"))

		widget4 := window.Add("Picture", "x" . button2X . " y" . y . " w64 h64 vcustomSetupButton Hidden X:Move(0.66)", window.Theme.RecolorizeImage(kResourcesDirectory . (!this.BasicSetup ? "Setup\Images\Full Setup.ico" : "Setup\Images\Full Setup Gray.ico")))
		widget4.OnEvent("Click", chooseMethod.Bind("Extended"))
		widget5 := window.Add("Text", "x" . button2X . " yp+68 w64 Hidden Center X:Move(0.66)", translate("Extended"))

		y += 100

		widget6 := window.Add("HTMLViewer", "x" . x . " y" . y . " w" . width . " h120 W:Grow Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Basic", "Basic.StartFooter." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.Theme.WindowBackColor . "; overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, p, body { color: #" . window.Theme.TextColor . "}</style><br>" . text . "</body></html>"

		widget6.document.write(html)

		this.registerWidgets(1, widget1, widget2, widget3, widget4, widget5, widget6)

		y -= 250

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Gears.ico")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("Basic Configuration"))

		window.SetFont("s8 Norm", "Arial")

		window.SetFont("Bold", "Arial")

		widget3 := window.Add("Text", "x" . x . " yp+30 w140 h23 +0x200 Hidden Section", translate("General"))
		widget4 := window.Add("Text", "yp+20 x" . x . " w" . col1Width . " 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		choices := []

		for code, language in languages
			choices.Push(language)

		widget5 := window.Add("Text", "x" . x . " yp+10 w100 h23 +0x200 Hidden", translate("Localization"))
		widget5.Info := "Basic.Localization.Info"
		widget6 := window.Add("Button", "xp+106 yp w23 h23 Hidden")
		widget6.Info := "Basic.Localization.Info"
		widget6.OnEvent("Click", openFormatsEditor)
		setButtonIcon(widget6, kIconsDirectory . "Locale.ico", 1, "L4 T4 R4 B4")
		widget7 := window.Add("DropDownList", "xp+24 yp w96 VbasicUILanguageDropDown Hidden", choices)
		widget7.Info := "Basic.Localization.Info"

		widget8 := window.Add("Text", "x" . x . " yp+24 w100 h23 +0x200 Hidden", translate("Push-To-Talk"))
		widget8.Info := "Basic.Push-To-Talk.Info"
		widget9 := window.Add("Button", "xp+106 yp-1 w23 h23 VbasicPushToTalkButton Hidden")
		widget9.Info := "Basic.Push-To-Talk.Info"
		widget9.OnEvent("Click", getPTTHotkey)
		setButtonIcon(widget9, kIconsDirectory . "Key.ico", 1)
		widget10 := window.Add("DropDownList", "xp+24 yp w96 Choose1 VbasicPushToTalkModeDropDown Hidden", collect(["Hold & Talk", "Press & Talk", "Custom"], translate))
		widget10.Info := "Basic.Push-To-Talk.Info"
		widget10.OnEvent("Change", updateP2T)
		widget51 := window.Add("Button", "xp+99 yp w23 h23 Hidden")
		widget51.Info := "Basic.Push-To-Talk.Info"
		widget51.OnEvent("Click", (*) => this.testPushToTalk())
		setButtonIcon(widget51, kIconsDirectory . "Start.ico", 1)
		widget11 := window.Add("Edit", "xp+24 yp w72 h21 VbasicPushToTalkEdit Hidden")
		widget11.Info := "Basic.Push-To-Talk.Info"

		window.SetFont("Bold", "Arial")

		widget32 := window.Add("Text", "x" . col2X . " ys w140 h23 +0x200 Hidden Section", translate("Simulators"))
		widget33 := window.Add("Text", "yp+20 xp w" . col2Width . " W:Grow 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		widget34 := window.Add("ListView", "x" . col2X . " yp+10 w" . col2Width . " h110 W:Grow Section -Multi -LV0x10 Checked NoSort NoSortHdr Hidden", collect(["Simulation", "Path"], translate))
		widget34.Info := "Basic.Simulators.Info"
		widget34.OnEvent("Click", noSelect)
		widget34.OnEvent("DoubleClick", noSelect)
		widget34.OnEvent("ContextMenu", noSelect)

		this.iSimulatorsListView := widget34

		widget35 := window.Add("Button", "x" . (col2X + col2Width - 90) . " yp+117 w90 h23 X:Move Hidden", translate("Locate..."))
		widget35.Info := "Basic.Simulators.Info"
		widget35.OnEvent("Click", locateSimulator)

		window.SetFont("Bold", "Arial")

		widget12 := window.Add("Text", "x" . x . " yp+20 w140 h23 +0x200 Hidden Section", translate("Assistants"))
		widget13 := window.Add("Text", "yp+20 xp w" . width . " W:Grow 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		widget38 := window.Add("Text", "x" . (x + 16 + 114) . " yp+10 w76 h23 +0x200 Hidden", translate("Name"))
		widget39 := window.Add("Text", "xp+78 yp w96 h23 +0x200 Hidden", translate("Language"))
		widget40 := window.Add("Text", "xp+148 yp w96 h23 +0x200 Hidden", translate("Voice"))

		widget41 := window.Add("CheckBox", "x" . x . " yp+24 w16 h21 vbasicDCEnabledCheck Hidden" . (wizard.isModuleSelected("Driving Coach") ? " Checked" : ""))
		widget41.Info := "Basic.Assistants.Info"
		widget41.OnEvent("Click", updateAssistant.Bind("Driving Coach"))
		widget42 := window.Add("Text", "xp+16 yp w110 h23 +0x200 Hidden", translate("Driving Coach"))
		widget42.Info := "Basic.Assistants.Info"
		widget43 := window.Add("Edit", "xp+114 yp w76 VbasicDCNameEdit Hidden", "Aiden")
		widget43.Info := "Basic.Assistants.Info"
		widget44 := window.Add("DropDownList", "xp+78 yp w146 VbasicDCLanguageDropDown Hidden")
		widget44.Info := "Basic.Assistants.Info"
		widget44.OnEvent("Change", chooseLanguage.Bind("Driving Coach"))
		widget45 := window.Add("DropDownList", "xp+148 yp w279 W:Grow VbasicDCVoiceDropDown Hidden")
		widget45.Info := "Basic.Assistants.Info"
		widget46 := window.Add("Button", "xp+281 yp-1 w23 h23 X:Move vbasicDCSettingsButton Hidden")
		widget46.Info := "Basic.Assistants.Voice.Info"
		widget46.OnEvent("Click", editSynthesizer.Bind("Driving Coach"))
		setButtonIcon(widget46, kIconsDirectory . "General Settings.ico", 1)
		widget47 := window.Add("Button", "xp+24 yp w23 h23 X:Move vbasicDCBoosterButton Hidden")
		widget47.Info := "Basic.Assistants.Boosters.Info"
		widget47.OnEvent("Click", editBooster.Bind("Driving Coach"))
		setButtonIcon(widget47, kIconsDirectory . "Booster.ico", 1, "L4 T4 R4 B4")

		widget14 := window.Add("CheckBox", "x" . x . " yp+24 w16 h21 vbasicREEnabledCheck Hidden" . (wizard.isModuleSelected("Race Engineer") ? " Checked" : ""))
		widget14.Info := "Basic.Assistants.Info"
		widget14.OnEvent("Click", updateAssistant.Bind("Race Engineer"))
		widget15 := window.Add("Text", "xp+16 yp w110 h23 +0x200 Hidden", translate("Race Engineer"))
		widget15.Info := "Basic.Assistants.Info"
		widget16 := window.Add("Edit", "xp+114 yp w76 VbasicRENameEdit Hidden", "Jona")
		widget16.Info := "Basic.Assistants.Info"
		widget17 := window.Add("DropDownList", "xp+78 yp w146 VbasicRELanguageDropDown Hidden")
		widget17.Info := "Basic.Assistants.Info"
		widget17.OnEvent("Change", chooseLanguage.Bind("Race Engineer"))
		widget18 := window.Add("DropDownList", "xp+148 yp w279 W:Grow VbasicREVoiceDropDown Hidden")
		widget18.Info := "Basic.Assistants.Info"
		widget19 := window.Add("Button", "xp+281 yp-1 w23 h23 X:Move vbasicRESettingsButton Hidden")
		widget19.Info := "Basic.Assistants.Voice.Info"
		widget19.OnEvent("Click", editSynthesizer.Bind("Race Engineer"))
		setButtonIcon(widget19, kIconsDirectory . "General Settings.ico", 1)
		widget48 := window.Add("Button", "xp+24 yp w23 h23 X:Move vbasicREBoosterButton Hidden")
		widget48.Info := "Basic.Assistants.Boosters.Info"
		widget48.OnEvent("Click", editBooster.Bind("Race Engineer"))
		setButtonIcon(widget48, kIconsDirectory . "Booster.ico", 1, "L4 T4 R4 B4")

		widget20 := window.Add("CheckBox", "x" . x . " yp+24 w16 h21 vbasicRSEnabledCheck Hidden" . (wizard.isModuleSelected("Race Strategist") ? " Checked" : ""))
		widget20.Info := "Basic.Assistants.Info"
		widget20.OnEvent("Click", updateAssistant.Bind("Race Strategist"))
		widget21 := window.Add("Text", "xp+16 yp w110 h23 +0x200 Hidden", translate("Race Strategist"))
		widget21.Info := "Basic.Assistants.Info"
		widget22 := window.Add("Edit", "xp+114 yp w76 VbasicRSNameEdit Hidden", "Khato")
		widget22.Info := "Basic.Assistants.Info"
		widget23 := window.Add("DropDownList", "xp+78 yp w146 VbasicRSLanguageDropDown Hidden")
		widget23.Info := "Basic.Assistants.Info"
		widget23.OnEvent("Change", chooseLanguage.Bind("Race Strategist"))
		widget24 := window.Add("DropDownList", "xp+148 yp w279 W:Grow VbasicRSVoiceDropDown Hidden")
		widget24.Info := "Basic.Assistants.Info"
		widget25 := window.Add("Button", "xp+281 yp-1 w23 h23 X:Move vbasicRSSettingsButton Hidden")
		widget25.Info := "Basic.Assistants.Voice.Info"
		widget25.OnEvent("Click", editSynthesizer.Bind("Race Strategist"))
		setButtonIcon(widget25, kIconsDirectory . "General Settings.ico", 1)
		widget49 := window.Add("Button", "xp+24 yp w23 h23 X:Move vbasicRSBoosterButton Hidden")
		widget49.Info := "Basic.Assistants.Boosters.Info"
		widget49.OnEvent("Click", editBooster.Bind("Race Strategist"))
		setButtonIcon(widget49, kIconsDirectory . "Booster.ico", 1, "L4 T4 R4 B4")

		widget26 := window.Add("CheckBox", "x" . x . " yp+24 w16 h21 vbasicRSPEnabledCheck Hidden" . (wizard.isModuleSelected("Race Spotter") ? " Checked" : ""))
		widget26.Info := "Basic.Assistants.Info"
		widget26.OnEvent("Click", updateAssistant.Bind("Race Spotter"))
		widget27 := window.Add("Text", "xp+16 yp w110 h23 +0x200 Hidden", translate("Race Spotter"))
		widget27.Info := "Basic.Assistants.Info"
		widget28 := window.Add("Edit", "xp+114 yp w76 VbasicRSPNameEdit Hidden", "Elisa")
		widget28.Info := "Basic.Assistants.Info"
		widget29 := window.Add("DropDownList", "xp+78 yp w146 VbasicRSPLanguageDropDown Hidden")
		widget29.Info := "Basic.Assistants.Info"
		widget29.OnEvent("Change", chooseLanguage.Bind("Race Spotter"))
		widget30 := window.Add("DropDownList", "xp+148 yp w279 W:Grow VbasicRSPVoiceDropDown Hidden")
		widget30.Info := "Basic.Assistants.Info"
		widget31 := window.Add("Button", "xp+281 yp-1 w23 h23 X:Move vbasicRSPSettingsButton Hidden")
		widget31.Info := "Basic.Assistants.Voice.Info"
		widget31.OnEvent("Click", editSynthesizer.Bind("Race Spotter"))
		setButtonIcon(widget31, kIconsDirectory . "General Settings.ico", 1)
		widget50 := window.Add("Button", "xp+24 yp w23 h23 X:Move vbasicRSPBoosterButton Hidden")
		widget50.Info := "Basic.Assistants.Boosters.Info"
		widget50.OnEvent("Click", editBooster.Bind("Race Spotter"))
		setButtonIcon(widget50, kIconsDirectory . "Booster.ico", 1, "L4 T4 R4 B4")

		widget36 := window.Add("HTMLViewer", "x" . x . " yp+30 w" . width . " h95 W:Grow H:Grow(0.8) Hidden")

		text := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.Basic", "Basic.FinishFooter." . getLanguage()))

		text := "<div style='text-align: center; font-family: Arial, Helvetica, sans-serif; font-size: 11px; font-weight: 600'>" . text . "</div>"

		html := "<html><body style='background-color: #" . window.Theme.WindowBackColor . "; overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, p, body { color: #" . window.Theme.TextColor . "}</style><br>" . text . "</body></html>"

		widget36.document.write(html)

		widget37 := window.Add("Button", "x" . (x + Round((width / 2) - 45)) . " yp+96 w90 h60 X:Move(0.4) W:Grow(0.2) Y:Move(0.8) H:Grow(0.2) Hidden")
		setButtonIcon(widget37, kResourcesDirectory . "\Setup\Images\Finish Line.png", 1, "w80 h53", false)
		widget37.OnEvent("Click", finishSetup)

		loop 51
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

	findWidget(x, y, test := (*) => true) {
		if WinActive(this.SetupWizard.Window)
			return super.findWidget(x, y, test)
		else if (this.iSynthesizerEditor && this.iSynthesizerEditor.Window
										 && WinActive(this.iSynthesizerEditor.Window))
			return this.iSynthesizerEditor.findWidget(x, y, test)
		else
			return false
	}

	showPage(page) {
		local wizard := this.SetupWizard
		local chosen := 0
		local enIndex := 0
		local enabled := false
		local fullInstall := false
		local code, language, uiLanguage, startWithWindows, silentMode, configuration, pushToTalk

		static installed := false

		; if !this.SetupWizard.Initialize
			page := 2

		if (page = 2) {
			fullInstall := (!installed && (!isDevelopment() || (GetKeyState("Ctrl") && GetKeyState("Shift"))))

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

			pushToTalk := getMultiMapValue(configuration, "Voice Control", "PushToTalk", false)

			if (pushToTalk = false)
				pushToTalk := ""

			this.Control["basicPushToTalkEdit"].Text := pushToTalk
			this.Control["basicPushToTalkModeDropDown"].Choose(inList(["Hold", "Press", "Custom"]
																	, getMultiMapValue(configuration, "Voice Control"
																					 , "PushToTalkMode", "Hold")))

			this.loadSetup(!fullInstall)

			this.BasicSetup := false ; this.SetupWizard.Initialize
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
		if !this.SetupWizard.Initialize
			page := 2

		return super.hidePage(page)
	}

	savePage(page) {
		if super.savePage(page) {
			if (page = 2) {
				this.updateSelectedSimulators()

				this.saveSetup()
			}

			return true
		}
		else
			return false
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
			this.Control["basic" . key . "BoosterButton"].Enabled := enabled
		}
	}

	testPushToTalk() {
		this.updateSelectedSimulators()

		this.saveSetup()

		testAssistants(this.SetupWizard, , !GetKeyState("Ctrl"))
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
			voiceLanguage := this.Control["basic" . this.Keys[assistant] . "LanguageDropDown"].Text

			if (InStr(voiceLanguage, translate("Translator")) || InStr(voiceLanguage, translate(" (translated)...")))
				return this.assistantTranslator(assistant, editor)
			else {
				languages := availableLanguages()

				for code, language in languages
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
		}
		else if this.SetupWizard.getModuleValue(assistant, "Language.Translated", false)
			return this.assistantTranslator(assistant, false)
		else
			return this.SetupWizard.getModuleValue(assistant, "Language", getLanguage())
	}

	assistantTranslator(assistant, editor := true) {
		local service := this.SetupWizard.getModuleValue(assistant, "Translator.Service", false)

		if service
			return {Service: service
				  , Language: this.SetupWizard.getModuleValue(assistant, "Translator.Language")
				  , Code: this.SetupWizard.getModuleValue(assistant, "Translator.Code")
				  , APIKey: this.SetupWizard.getModuleValue(assistant, "Translator.API Key")
				  , Arguments: string2Values(",", this.SetupWizard.getModuleValue(assistant, "Translator.Arguments"))}
		else
			return false
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

	assistantSpeakerBooster(assistant, editor := true) {
		local speakerBooster

		if this.SetupWizard.isModuleSelected("Voice Control") {
			speakerBooster := this.SetupWizard.getModuleValue(assistant, "Speaker Booster", this.SetupWizard.getModuleValue(assistant, "Booster", this.assistantDefaults(assistant).SpeakerBooster))

			if speakerBooster {
				speakerBooster := (isInstance(speakerBooster, Map) ? speakerBooster : string2Map("|||", "--->>>", speakerBooster))

				if !speakerBooster.Has("Speaker")
					speakerBooster["Speaker"] := true

				if !speakerBooster.Has("SpeakerProbability")
					speakerBooster["SpeakerProbability"] := (speakerBooster.Has("Probability") ? speakerBooster["Probability"] : 0.5)

				if !speakerBooster.Has("SpeakerTemperature")
					speakerBooster["SpeakerTemperature"] := (speakerBooster.Has("Temperature") ? speakerBooster["Temperature"] : 0.5)
			}

			return (speakerBooster ? speakerBooster : false)
		}
		else
			return false
	}

	assistantListenerBooster(assistant, editor := true) {
		local listenerBooster

		if this.SetupWizard.isModuleSelected("Voice Control") {
			listenerBooster := this.SetupWizard.getModuleValue(assistant, "Listener Booster", this.assistantDefaults(assistant).ListenerBooster)

			if listenerBooster
				listenerBooster := (isInstance(listenerBooster, Map) ? listenerBooster : string2Map("|||", "--->>>", listenerBooster))

			return (listenerBooster ? listenerBooster : false)
		}
		else
			return false
	}

	assistantConversationBooster(assistant, editor := true) {
		local conversationBooster

		if this.SetupWizard.isModuleSelected("Voice Control") {
			conversationBooster := this.SetupWizard.getModuleValue(assistant, "Conversation Booster", this.assistantDefaults(assistant).ConversationBooster)

			if conversationBooster
				conversationBooster := (isInstance(conversationBooster, Map) ? conversationBooster : string2Map("|||", "--->>>", conversationBooster))

			return (conversationBooster ? conversationBooster : false)
		}
		else
			return false
	}

	assistantAgentBooster(assistant, editor := true) {
		local agentBooster := this.SetupWizard.getModuleValue(assistant, "Agent Booster", this.assistantDefaults(assistant).AgentBooster)

		if agentBooster
			agentBooster := (isInstance(agentBooster, Map) ? agentBooster : string2Map("|||", "--->>>", agentBooster))

		return (agentBooster ? agentBooster : false)
	}

	assistantSetup(assistant, editor := true) {
		return {Enabled: this.assistantEnabled(assistant, editor)
			  , Name: this.assistantName(assistant, editor)
			  , Language: this.assistantLanguage(assistant, editor)
			  , Synthesizer: this.assistantSynthesizer(assistant, editor)
			  , Voice: this.assistantVoice(assistant, editor)
			  , Volume: this.assistantVolume(assistant), Pitch: this.assistantPitch(assistant), Speed: this.assistantSpeed(assistant)
			  , SpeakerBooster: this.assistantSpeakerBooster(assistant)
			  , ListenerBooster: this.assistantListenerBooster(assistant)
			  , ConversationBooster: this.assistantConversationBooster(assistant)
			  , AgentBooster: this.assistantAgentBooster(assistant)}
	}

	assistantDefaults(assistant) {
		local wizard := this.SetupWizard
		local defaults := {}
		local ignore, key

		for ignore, key in ["Name", "Synthesizer", "Voice", "Volume", "Pitch", "Speed"
						  , "SpeakerBooster", "ListenerBooster", "ConversationBooster", "AgentBooster"]
			defaults.%key% := getMultiMapValue(wizard.Definition, "Setup.Basic", "Basic.Defaults." . assistant . "." . key, false)

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
		local wizard := this.SetupWizard
		local wasInstalled := wizard.isApplicationInstalled(name)

		wizard.locateApplication(name, fileName, false)

		if !wasInstalled
			wizard.selectApplication(name, true, false)

		this.loadSimulators()
	}

	loadVoices(assistant := false, editor := true) {
		local assistants := (assistant ? [assistant] : this.Definition)
		local voices, language, ignore, dropDown, index, voice

		for ignore, assistant in assistants {
			language := this.assistantLanguage(assistant, editor)

			if isObject(language)
				language := language.Code

			try {
				voices := SpeechSynthesizer(this.assistantSynthesizer(assistant, editor), true, language).Voices[language]
			}
			catch Any {
				voices := []
			}

			dropDown := this.Control["basic" . this.Keys[assistant] . "VoiceDropDown"]

			dropDown.Delete()
			dropDown.Add((voices.Length > 0) ? concatenate(collect(["Deactivated", "Random"], translate), voices) : [translate("Deactivated")])
			dropDown.Choose((voices.Length > 0) ? 2 : 1)

			voice := this.SetupWizard.getModuleValue(assistant, "Voice", true)

			if ((voices.Length = 0) && voice && (voice != true)) {
				dropDown.Add([voice])
				dropDown.Choose(2)
			}
			else if (!editor && (voices.Length > 1))
				dropDown.Choose(voice ? (inList(voices, voice) + 2) : 1)

			dropDown.LastValue := dropDown.Value
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
		local allLanguages := availableLanguages()
		local assistantLanguage, code, language, ignore, grammarFile, assistantTranslator

		for ignore, assistant in this.Definition
			for ignore, grammarFile in getFileNames(assistant . ".grammars.*", kUserGrammarsDirectory, kGrammarsDirectory) {
				SplitPath(grammarFile, , , &code)

				if !inList(languages, code) {
					if allLanguages.Has(code)
						choices.Push(allLanguages[code])
					else
						choices.Push(code)

					languages.Push(code)
				}
			}

		this.Control["basic" . key . "EnabledCheck"].Value := (this.assistantEnabled(assistant, false) != false)
		this.Control["basic" . key . "NameEdit"].Text := this.assistantName(assistant, false)

		assistantLanguage := inList(languages, this.assistantLanguage(assistant, false))
		assistantTranslator := this.assistantTranslator(assistant, false)

		this.Control["basic" . key . "LanguageDropDown"].Delete()

		if assistantTranslator
			choices := concatenate(choices, [translate("---------------------------------------------")
										   , first(Translator.Languages, (l) => ((l.Identifier = assistantTranslator.Language)
																			  || (l.Code = assistantTranslator.Language))).Name . translate(" (translated)...")])
		else
			choices := concatenate(choices, [translate("---------------------------------------------")
										   , translate("Translator") . translate("...")])

		this.Control["basic" . key . "LanguageDropDown"].Add(choices)

		if (!assistantLanguage && assistantTranslator)
			this.Control["basic" . key . "LanguageDropDown"].Choose(choices.Length)
		else
			this.Control["basic" . key . "LanguageDropDown"].Choose(assistantLanguage ? assistantLanguage : 1)

		this.Control["basic" . key . "LanguageDropDown"].LastValue := this.Control["basic" . key . "LanguageDropDown"].Value

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
			row := listView.GetNext(row, "C")

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
		local uiLanguage, startWithWindows, silentMode

		for key, assistant in this.Assistants
			assistantSetups.%key% := this.assistantSetup(assistant)

		for key, assistant in this.Assistants {
			wizard.selectModule(assistant, assistantSetups.%key%.Enabled, false)

			for ignore, value in ["Name", "Language", "Synthesizer", "Voice", "Volume", "Pitch", "Speed"]
				if (value = "Language") {
					value := assistantSetups.%key%.Language

					if isObject(value) {
						wizard.setModuleValue(assistant, "Language", value.Code, false)
						wizard.setModuleValue(assistant, "Language.Translated", true, false)
					}
					else {
						wizard.setModuleValue(assistant, "Language", value, false)
						wizard.setModuleValue(assistant, "Language.Translated", false, false)
					}
				}
				else
					wizard.setModuleValue(assistant, value, assistantSetups.%key%.%value%, false)

			if assistantSetups.%key%.HasProp("SpeakerBooster")
				wizard.setModuleValue(assistant, "Speaker Booster"
									, assistantSetups.%key%.SpeakerBooster ? map2String("|||", "--->>>", assistantSetups.%key%.SpeakerBooster) : false, false)
			else
				wizard.setModuleValue(assistant, "Speaker Booster", false, false)

			if assistantSetups.%key%.HasProp("ListenerBooster")
				wizard.setModuleValue(assistant, "Listener Booster"
									, assistantSetups.%key%.ListenerBooster ? map2String("|||", "--->>>", assistantSetups.%key%.ListenerBooster) : false, false)
			else
				wizard.setModuleValue(assistant, "Listener Booster", false, false)

			if assistantSetups.%key%.HasProp("ConversationBooster")
				wizard.setModuleValue(assistant, "Conversation Booster"
									, assistantSetups.%key%.ConversationBooster ? map2String("|||", "--->>>", assistantSetups.%key%.ConversationBooster) : false, false)
			else
				wizard.setModuleValue(assistant, "Conversation Booster", false, false)

			if assistantSetups.%key%.HasProp("AgentBooster")
				wizard.setModuleValue(assistant, "Agent Booster"
									, assistantSetups.%key%.AgentBooster ? map2String("|||", "--->>>", assistantSetups.%key%.AgentBooster) : false, false)
			else
				wizard.setModuleValue(assistant, "Agent Booster", false, false)
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

		wizard.getGeneralConfiguration(&uiLanguage, &startWithWindows, &silentMode)

		wizard.setGeneralConfiguration(languageCode, startWithWindows, silentMode)

		wizard.updateState()
	}

	editSynthesizer(assistant) {
		local wizard := this.SetupWizard
		local window := this.Window
		local configuration, setup, language

		window.Block()

		try {
			this.saveSetup()

			configuration := newMultiMap()

			setup := this.assistantSetup(assistant)
			language := setup.Language

			if isObject(language)
				language := language.Code

			setMultiMapValues(configuration, "Voice Control", getMultiMapValues(kSimulatorConfiguration, "Voice Control"), false)

			setMultiMapValue(configuration, "Voice Control", "Language", language)
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", setup.Synthesizer)
			setMultiMapValue(configuration, "Voice Control", "Speaker", setup.Voice)
			setMultiMapValue(configuration, "Voice Control", "SpeakerVolume", (setup.Volume = "*") ? 100 : setup.Volume)
			setMultiMapValue(configuration, "Voice Control", "SpeakerPitch", (setup.Pitch = "*") ? 0 : setup.Pitch)
			setMultiMapValue(configuration, "Voice Control", "SpeakerSpeed", (setup.Speed = "*") ? 0 : setup.Speed)

			if (InStr(setup.Synthesizer, "Azure") = 1) {
				setMultiMapValue(configuration, "Voice Control", "Speaker.Azure", setup.Voice)

				setup := string2Values("|", setup.Synthesizer)

				setMultiMapValue(configuration, "Voice Control", "Azure.SubscriptionKey", setup[3])
				setMultiMapValue(configuration, "Voice Control", "Azure.TokenIssuer", setup[2])
			}
			else if (setup.Synthesizer = "dotNET")
				setMultiMapValue(configuration, "Voice Control", "Speaker.dotNET", setup.Voice)
			else if (setup.Synthesizer = "Windows")
				setMultiMapValue(configuration, "Voice Control", "Speaker.Windows", setup.Voice)
			else if (InStr(setup.Synthesizer, "Google") = 1) {
				setMultiMapValue(configuration, "Voice Control", "Speaker.Google", setup.Voice)

				setup := string2Values("|", setup.Synthesizer)

				setMultiMapValue(configuration, "Voice Control", "Google.APIKeyFile", setup[2])
			}
			else if (InStr(setup.Synthesizer, "OpenAI") = 1) {
				setMultiMapValue(configuration, "Voice Control", "Speaker.OpenAI", setup.Voice)

				setup := string2Values("|", setup.Synthesizer)

				setMultiMapValue(configuration, "Voice Control", "OpenAI.SpeakerInstructions", setup[4])
			}
			else {
				setMultiMapValue(configuration, "Voice Control", "Speaker.ElevenLabs", setup.Voice)

				setup := string2Values("|", setup.Synthesizer)

				setMultiMapValue(configuration, "Voice Control", "ElevenLabs.APIKey", setup[2])
			}

			this.iSynthesizerEditor := SynthesizerEditor(this, assistant, configuration)

			try {
				configuration := this.iSynthesizerEditor.editSynthesizer(window)
			}
			finally {
				this.iSynthesizerEditor := false
			}

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

	editBooster(assistant) {
		local wizard := this.SetupWizard
		local window := this.Window
		local configuration, setup, availableBooster, speakerBooster, listenerBooster, conversationBooster, agentBooster

		window.Block()

		try {
			this.saveSetup()

			configuration := readMultiMap(kUserHomeDirectory . "Setup\Assistant Booster Configuration.ini")

			setMultiMapValues(configuration, "Conversation Booster", getMultiMapValues(kSimulatorConfiguration, "Conversation Booster"), false)

			setup := this.assistantSetup(assistant)

			if (setup.HasProp("SpeakerBooster") && setup.SpeakerBooster) {
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".Service", setup.SpeakerBooster["Service"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".Model", setup.SpeakerBooster["Model"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".Speaker", setup.SpeakerBooster["Speaker"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".SpeakerProbability", setup.SpeakerBooster["SpeakerProbability"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".SpeakerTemperature", setup.SpeakerBooster["SpeakerTemperature"])
			}

			if (setup.HasProp("ListenerBooster") && setup.ListenerBooster) {
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".Service", setup.ListenerBooster["Service"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".Model", setup.ListenerBooster["Model"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".Listener", setup.ListenerBooster["Listener"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".ListenerMode", setup.ListenerBooster["ListenerMode"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".ListenerTemperature", setup.ListenerBooster["ListenerTemperature"])
			}

			if (setup.HasProp("ConversationBooster") && setup.ConversationBooster) {
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".Service", setup.ConversationBooster["Service"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".Model", setup.ConversationBooster["Model"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".Conversation", setup.ConversationBooster["Conversation"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".ConversationMaxHistory", setup.ConversationBooster["ConversationMaxHistory"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".ConversationTemperature", setup.ConversationBooster["ConversationTemperature"])
				setMultiMapValue(configuration, "Conversation Booster", assistant . ".ConversationActions", setup.ConversationBooster["ConversationActions"])
			}

			if (setup.HasProp("AgentBooster") && setup.AgentBooster) {
				setMultiMapValue(configuration, "Agent Booster", assistant . ".Service", setup.AgentBooster["Service"])
				setMultiMapValue(configuration, "Agent Booster", assistant . ".Model", setup.AgentBooster["Model"])
				setMultiMapValue(configuration, "Agent Booster", assistant . ".Agent", setup.AgentBooster["Agent"])
			}

			availableBooster := ((assistant = "Driving Coach") ? ["Speaker", "Listener", "Agent"]
															   : ["Speaker", "Listener", "Conversation", "Agent"])

			configuration := AssistantBoosterEditor(assistant, configuration, availableBooster).editBooster(window)

			if configuration {
				writeMultiMap(kUserHomeDirectory . "Setup\Assistant Booster Configuration.ini", configuration)

				speakerBooster := Map("Service", getMultiMapValue(configuration, "Conversation Booster", assistant . ".Service")
									 , "Model", getMultiMapValue(configuration, "Conversation Booster", assistant . ".Model")
									 , "Speaker", getMultiMapValue(configuration, "Conversation Booster", assistant . ".Speaker")
									 , "SpeakerProbability", getMultiMapValue(configuration, "Conversation Booster", assistant . ".SpeakerProbability"), "SpeakerProbability", getMultiMapValue(configuration, "Conversation Booster", assistant . ".SpeakerProbability")
									 , "SpeakerTemperature", getMultiMapValue(configuration, "Conversation Booster", assistant . ".SpeakerTemperature"))

				wizard.setModuleValue(assistant, "Speaker Booster", map2String("|||", "--->>>", speakerBooster))

				listenerBooster := Map("Service", getMultiMapValue(configuration, "Conversation Booster", assistant . ".Service")
									  , "Model", getMultiMapValue(configuration, "Conversation Booster", assistant . ".Model")
									  , "Listener", getMultiMapValue(configuration, "Conversation Booster", assistant . ".Listener")
									  , "ListenerMode", getMultiMapValue(configuration, "Conversation Booster", assistant . ".ListenerMode")
									  , "ListenerTemperature", getMultiMapValue(configuration, "Conversation Booster", assistant . ".ListenerTemperature"))

				wizard.setModuleValue(assistant, "Listener Booster", map2String("|||", "--->>>", listenerBooster))

				conversationBooster := Map("Service", getMultiMapValue(configuration, "Conversation Booster", assistant . ".Service")
										  , "Model", getMultiMapValue(configuration, "Conversation Booster", assistant . ".Model")
										  , "Conversation", getMultiMapValue(configuration, "Conversation Booster", assistant . ".Conversation")
										  , "ConversationMaxHistory", getMultiMapValue(configuration, "Conversation Booster", assistant . ".ConversationMaxHistory")
										  , "ConversationTemperature", getMultiMapValue(configuration, "Conversation Booster", assistant . ".ConversationTemperature")
										  , "ConversationActions", getMultiMapValue(configuration, "Conversation Booster", assistant . ".ConversationActions"))

				wizard.setModuleValue(assistant, "Conversation Booster", map2String("|||", "--->>>", conversationBooster))

				agentBooster := Map("Service", getMultiMapValue(configuration, "Agent Booster", assistant . ".Service")
								  , "Model", getMultiMapValue(configuration, "Agent Booster", assistant . ".Model")
								  , "Agent", getMultiMapValue(configuration, "Agent Booster", assistant . ".Agent"))

				wizard.setModuleValue(assistant, "Agent Booster", map2String("|||", "--->>>", agentBooster))

				this.loadAssistant(assistant)
			}
		}
		finally {
			window.Unblock()
		}
	}

	editTranslator(assistant) {
		local wizard := this.SetupWizard
		local window := this.Window
		local configuration

		window.Block()

		try {
			this.saveSetup()

			configuration := readMultiMap(kUserHomeDirectory . "Setup\Translator Configuration.ini")

			configuration := TranslatorEditor(assistant, configuration).editTranslator(window)

			if configuration {
				writeMultiMap(kUserHomeDirectory . "Setup\Translator Configuration.ini", configuration)

				if getMultiMapValue(configuration, assistant . ".Translator", "Service", false) {
					wizard.setModuleValue(assistant, "Translator.Service", getMultiMapValue(configuration, assistant . ".Translator", "Service"))
					wizard.setModuleValue(assistant, "Translator.Language", getMultiMapValue(configuration, assistant . ".Translator", "Language"))
					wizard.setModuleValue(assistant, "Translator.Code", getMultiMapValue(configuration, assistant . ".Translator", "Code"))
					wizard.setModuleValue(assistant, "Translator.API Key", getMultiMapValue(configuration, assistant . ".Translator", "API Key"))
					wizard.setModuleValue(assistant, "Translator.Arguments", getMultiMapValue(configuration, assistant . ".Translator", "Arguments", ""))

					wizard.setModuleValue(assistant, "Language.Translated", true)
				}
				else {
					wizard.clearModuleValue(assistant, "Translator.Service", false)
					wizard.clearModuleValue(assistant, "Translator.Language", false)
					wizard.clearModuleValue(assistant, "Translator.Code", false)
					wizard.clearModuleValue(assistant, "Translator.API Key", false)
					wizard.clearModuleValue(assistant, "Translator.Arguments", false)

					wizard.setModuleValue(assistant, "Language.Translated", false)
				}

				this.loadAssistant(assistant)

				return true
			}
			else
				return false
		}
		finally {
			window.Unblock()
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