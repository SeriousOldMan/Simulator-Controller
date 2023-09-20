;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - General Step Wizard             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "ControllerStepWizard.ahk"
#Include "FormatsEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; GeneralStepWizard                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class GeneralStepWizard extends ControllerPreviewStepWizard {
	static sCurrentGeneralStep := false

	iVoiceControlConfigurator := false
	iModeSelectorsListView := false
	iLaunchApplicationsListView := false

	iModeSelectors := []
	iLaunchApplications := CaseInsenseWeakMap()

	iPendingApplicationRegistration := false
	iPendingFunctionRegistration := false

	iControllerWidgets := []
	iVoiceControlWidgets := []

	Pages {
		Get {
			return (this.SetupWizard.BasicSetup ? 0 : 1)
		}
	}

	static CurrentGeneralStep {
		Get {
			return GeneralStepWizard.sCurrentGeneralStep
		}
	}

	saveToConfiguration(configuration) {
		local wizard := this.SetupWizard
		local application, function, path, directory, voiceControlConfiguration, ignore, section, subConfiguration
		local modeSelectors, arguments, launchApplications, descriptor, label, language, startWithWindows, silentMode
		local values, key, value

		super.saveToConfiguration(configuration)

		setMultiMapValues(configuration, "Splash Window", getMultiMapValues(this.SetupWizard.Definition, "Splash Window"))
		setMultiMapValues(configuration, "Splash Screens", getMultiMapValues(this.SetupWizard.Definition, "Splash Screens"))

		wizard.getGeneralConfiguration(&language, &startWithWindows, &silentMode)

		setMultiMapValue(configuration, "Configuration", "Language", language)
		setMultiMapValue(configuration, "Configuration", "Start With Windows", startWithWindows)
		setMultiMapValue(configuration, "Configuration", "Silent Mode", silentMode)

		for section, values in readMultiMap(kUserHomeDirectory . "Setup\Formats Configuration.ini")
			for key, value in values
				setMultiMapValue(configuration, section, key, value)

		if wizard.isSoftwareInstalled("NirCmd") {
			path := wizard.softwarePath("NirCmd")

			SplitPath(path, , &directory)

			setMultiMapValue(configuration, "Configuration", "NirCmd Path", directory)
		}

		if wizard.isModuleSelected("Voice Control") {
			voiceControlConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini")

			for ignore, section in ["Voice Control"] {
				subConfiguration := getMultiMapValues(voiceControlConfiguration, section, false)

				if subConfiguration
					setMultiMapValues(configuration, section, subConfiguration)
			}
		}
		else {
			setMultiMapValue(configuration, "Voice Control", "Synthesizer", "dotNET")
			setMultiMapValue(configuration, "Voice Control", "Speaker", false)
			setMultiMapValue(configuration, "Voice Control", "Listener", false)
		}

		modeSelectors := wizard.getModeSelectors()
		arguments := ""

		if (modeSelectors.Length > 0)
			arguments := ("modeSelector: " . values2String(A_Space, modeSelectors*))

		launchApplications := []

		for ignore, section in string2Values(",", this.Definition[3])
			for application, descriptor in getMultiMapValues(wizard.Definition, section) {
				if wizard.isApplicationSelected(application) {
					function := wizard.getLaunchApplicationFunction(application)

					if (function && (function != "")) {
						label := wizard.getLaunchApplicationLabel(application)

						if (label = "")
							label := application

						launchApplications.Push("`"" . label . "`" `"" . application . "`" " . function)
					}
				}
			}

		if (launchApplications.Length > 0) {
			if (arguments != "")
				arguments .= "; "

			arguments .= ("launchApplications: " . values2String(", ", launchApplications*))
		}

		Plugin("System", false, true, "", arguments).saveToConfiguration(configuration)

		Plugin("Integration", false, false).saveToConfiguration(configuration)
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local labelWidth := width - 30
		local labelX := x + 35
		local labelY := y + 8
		local secondX := x + 106
		local secondWidth := width - 106
		local col1Width := (secondX - x) + 120
		local col2X := secondX + 140
		local col2Width := width - 140 - secondX + x
		local choices, code, language, info, html, configurator

		noSelect(listView, *) {
			loop listView.GetCount()
				listView.Modify(A_Index, "-Select")
		}

		openFormatsEditor(*) {
			this.openFormatsEditor()
		}

		updateApplicationFunction(row) {
			local function, application, curCoordMode, menuItem, contextMenu

			inputLabel(row, *) {
				local function, application, label, function, result

				application := this.iLaunchApplicationsListView.GetText(row, 1)
				label := this.iLaunchApplicationsListView.GetText(row, 2)
				function := this.iLaunchApplicationsListView.GetText(row, 3)

				result := InputBox(translate("Please enter a label:"), translate("Modular Simulator Controller System"), "w200 h150", label)

				if (result.Result != "Ok")
					return
				else {
					label := result.Value

					if this.iLaunchApplications.Has(application)
						this.iLaunchApplications[application][1] := label
					else
						this.iLaunchApplications[application] := Array(label, "")

					SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

					this.loadApplications()
				}
			}

			loop this.iLaunchApplicationsListView.GetCount()
				this.iLaunchApplicationsListView.Modify(A_Index, "-Select")

			if (row > 0) {
				if this.SetupWizard.isModuleSelected("Controller") {
					if this.iPendingApplicationRegistration
						this.setApplicationFunction(row)
					else {
						curCoordMode := A_CoordModeMouse

						application := this.iLaunchApplicationsListView.GetText(row, 1)

						menuItem := application

						contextMenu := Menu()

						contextMenu.Add(menuItem, (*) => {})
						contextMenu.Disable(menuItem)

						contextMenu.Add()

						contextMenu.Add(translate("Set Function"), (*) => this.setApplicationFunction(row))

						menuItem := translate("Clear Function")

						contextMenu.Add(menuItem, (*) => this.clearApplicationFunction(row))

						application := this.iLaunchApplicationsListView.GetText(row, 1)

						function := this.iLaunchApplications[application]

						if (!function || (function = ""))
							contextMenu.Disable(menuItem)

						contextMenu.Add()

						menuItem := translate("Input Label...")

						contextMenu.Add(menuItem, inputLabel.Bind(row))

						if (!function || (function = ""))
							contextMenu.Disable(menuItem)

						contextMenu.Show()
					}
				}
			}

			loop this.iLaunchApplicationsListView.GetCount()
				this.iLaunchApplicationsListView.Modify(A_Index, "-Select")
		}

		applicationFunctionSelect(listView, line, *) {
			if line
				updateApplicationFunction(line)
		}

		applicationFunctionMenu(listView, line, *) {
			if line
				updateApplicationFunction(line)
		}

		window.SetFont("s10 Bold", "Arial")

		widget1 := window.Add("Picture", "x" . x . " y" . y . " w30 h30 Hidden", kResourcesDirectory . "Setup\Images\Gears.ico")
		widget2 := window.Add("Text", "x" . labelX . " y" . labelY . " w" . labelWidth . " h26 Hidden", translate("General Configuration"))

		window.SetFont("s8 Norm", "Arial")

		window.SetFont("Bold", "Arial")

		widget3 := window.Add("Text", "x" . x . " yp+30 w" . col1Width . " h23 +0x200 Hidden Section", translate("General"))
		widget4 := window.Add("Text", "yp+20 x" . x . " w" . col1Width . " 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		choices := []

		for code, language in availableLanguages()
			choices.Push(language)

		widget5 := window.Add("Text", "x" . x . " yp+10 w86 h23 +0x200 Hidden", translate("Localization"))
		widget6 := window.Add("Button", "x" . secondX . " yp w23 h23 Hidden")
		widget6.OnEvent("Click", openFormatsEditor)
		setButtonIcon(widget6, kIconsDirectory . "Locale.ico", 1, "L4 T4 R4 B4")
		widget7 := window.Add("DropDownList", "xp+24 yp w96 VuiLanguageDropDown Hidden", choices)

		widget8 := window.Add("CheckBox", "x" . x . " yp+30 w242 h23 Checked1 VstartWithWindowsCheck Hidden", translate("Start with Windows"))
		widget9 := window.Add("CheckBox", "x" . x . " yp+24 w242 h23 Checked0 VsilentModeCheck Hidden", translate("Silent mode (no splash screen, no sound)"))

		window.SetFont("Bold", "Arial")

		widget10 := window.Add("Text", "x" . x . " yp+30 w" . col1Width . " h23 +0x200 Hidden", translate("Controller"))
		widget11 := window.Add("Text", "yp+20 x" . x . " w" . col1Width . " 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		widget12 := window.Add("Text", "x" . x . " yp+10 w105 h23 +0x200 Hidden", translate("Mode Selector"))
		widget13 := window.Add("ListBox", "x" . secondX . " yp w120 h60 Disabled ReadOnly Hidden")

		widget14 := window.Add("Text", "x" . x . " yp+60 w140 h23 +0x200 Hidden", translate("Launchpad Mode"))
		widget15 := window.Add("ListView", "x" . x . " yp+24 w" . col1Width . " h112 H:Grow(0.5) AltSubmit -Multi -LV0x10 NoSort NoSortHdr Hidden", collect(["Application", "Label", "Function"], translate))
		widget15.OnEvent("Click", applicationFunctionSelect)
		widget15.OnEvent("DoubleClick", applicationFunctionSelect)
		widget15.OnEvent("ContextMenu", applicationFunctionMenu)

		info := substituteVariables(getMultiMapValue(this.SetupWizard.Definition, "Setup.General", "General.Settings.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif; font-size: 11px'><hr style='border-width:1pt;border-color:#AAAAAA;color:#AAAAAA;width: 90%'>" . info . "</div>"

		widget16 := window.Add("HTMLViewer", "x" . x . " yp+118 w" . width . " h94 Y:Move(0.5) H:Grow(0.5) W:Grow Hidden")

		html := "<html><body style='background-color: #" . window.BackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		widget16.document.write(html)

		window.SetFont("Bold", "Arial")

		widget17 := window.Add("Text", "x" . col2X . " ys w" . col2Width . " h23 +0x200 Hidden Section", translate("Voice Control"))
		widget18 := window.Add("Text", "yp+20 x" . col2X . " w" . col2Width . " W:Grow 0x10 Hidden")

		window.SetFont("Norm", "Arial")

		configurator := VoiceControlConfigurator(this)

		this.iVoiceControlConfigurator := configurator

		configurator.createGui(this, col2X, labelY + 30 + 30, col2Width, height)
		configurator.hideWidgets()

		this.iModeSelectorsListView := widget13
		this.iLaunchApplicationsListView := widget15

		this.iControllerWidgets := Array(widget12, widget13, widget14, widget15, widget10, widget11)
		this.iVoiceControlWidgets := Array(widget17, widget18)

		this.registerWidgets(1, widget1, widget2, widget3, widget4, widget5, widget6, widget7, widget8, widget8, widget9, widget10
							  , widget11, widget12, widget13, widget14, widget15, widget16, widget17, widget18)
	}

	registerWidget(page, widget) {
		if (page = this.iVoiceControlConfigurator)
			super.registerWidget(1, widget)
		else
			super.registerWidget(page, widget)
	}

	startSetup(new) {
		local wizard, uiLanguage, startWithWindows, silentMode

		if !new {
			wizard := this.SetupWizard

			wizard.getGeneralConfiguration(&uiLanguage, &startWithWindows, &silentMode)

			wizard.setGeneralConfiguration(getMultiMapValue(kSimulatorConfiguration, "Configuration", "Language", uiLanguage)
										 , getMultiMapValue(kSimulatorConfiguration, "Configuration", "Start With Windows", startWithWindows)
										 , getMultiMapValue(kSimulatorConfiguration, "Configuration", "Silent Mode", silentMode))
		}
	}

	reset() {
		super.reset()

		this.iVoiceControlConfigurator := false
		this.iModeSelectorsListView := false
		this.iLaunchApplicationsListView := false

		this.iControllerWidgets := []
		this.iVoiceControlWidgets := []

		this.iModeSelectors := []
		this.iLaunchApplications := CaseInsenseWeakMap()
	}

	showPage(page) {
		local wizard := this.SetupWizard
		local window := this.Window
		local chosen := 0
		local enIndex := 0
		local code, language, configuration, voiceControlConfiguration, ignore, section, subConfiguration
		local path, directory, widget, listBox, uiLanguage, startWithWindows, silentMode

		static first := true

		GeneralStepWizard.sCurrentGeneralStep := this

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

		this.Control["uiLanguageDropDown"].Choose(chosen)
		this.Control["startWithWindowsCheck"].Value := startWithWindows
		this.Control["silentModeCheck"].Value := silentMode

		this.iModeSelectors := wizard.getModeSelectors()

		this.iVoiceControlConfigurator.hideWidgets()

		if this.SetupWizard.isModuleSelected("Voice Control") {
			configuration := this.SetupWizard.getSimulatorConfiguration()

			if (this.SetupWizard.Initialize || !first) {
				voiceControlConfiguration := readMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini")

				addMultiMapValues(configuration, voiceControlConfiguration)
			}

			first := false

			if (getMultiMapValue(configuration, "Voice Control", "SoX Path", "") = "") {
				path := wizard.softwarePath("SoX")

				if path {
					SplitPath(path, , &directory)

					setMultiMapValue(configuration, "Voice Control", "SoX Path", directory)
				}
			}

			this.iVoiceControlConfigurator.loadConfigurator(configuration)
			this.iVoiceControlConfigurator.showWidgets()
			this.iVoiceControlConfigurator.updateWidgets()
		}
		else
			for ignore, widget in this.iVoiceControlWidgets
				widget.Visible := false

		if this.SetupWizard.isModuleSelected("Controller") {
			this.iModeSelectorsListView.Delete()
			this.iModeSelectorsListView.Add(this.iModeSelectors)

			this.loadApplications(true)
		}
		else
			for ignore, widget in this.iControllerWidgets
				widget.Visible := false
	}

	hidePage(page) {
		local wizard, window, languageCode, code, language, configuration, voiceControlConfiguration
		local ignore, section, subConfiguration

		this.iVoiceControlConfigurator.hideWidgets()

		if super.hidePage(page) {
			GeneralStepWizard.sCurrentGeneralStep := false

			wizard := this.SetupWizard

			languageCode := "en"

			for code, language in availableLanguages()
				if (language = this.Control["uiLanguageDropDown"].Text) {
					languageCode := code

					break
				}

			wizard.setGeneralConfiguration(languageCode, this.Control["startWithWindowsCheck"].Value, this.Control["silentModeCheck"].Value)

			if wizard.isModuleSelected("Controller") {
				wizard.setModeSelectors(this.iModeSelectors)

				this.saveApplications()
			}

			if wizard.isModuleSelected("Voice Control") {
				configuration := newMultiMap()

				this.iVoiceControlConfigurator.saveToConfiguration(configuration)

				voiceControlConfiguration := newMultiMap()

				for ignore, section in ["Voice Control"] {
					subConfiguration := getMultiMapValues(configuration, section, false)

					if subConfiguration
						setMultiMapValues(voiceControlConfiguration, section, subConfiguration)
				}

				writeMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini", voiceControlConfiguration)
			}

			this.iPendingApplicationRegistration := false
			this.iPendingFunctionRegistration := false

			return true
		}
		else {
			this.iVoiceControlConfigurator.showWidgets()

			return false
		}
	}

	loadApplications(load := false) {
		local wizard := this.SetupWizard
		local application, function, row, column, ignore, section, application, descriptor

		if load
			this.iLaunchApplications := CaseInsenseWeakMap()

		this.iLaunchApplicationsListView.Delete()

		row := false
		column := false

		for ignore, section in string2Values(",", this.Definition[3])
			for application, descriptor in getMultiMapValues(wizard.Definition, section) {
				if wizard.isApplicationSelected(application) {
					if load {
						function := wizard.getLaunchApplicationFunction(application)

						if (function && (function != ""))
							this.iLaunchApplications[application] := Array(wizard.getLaunchApplicationLabel(application), function)
					}

					if this.iLaunchApplications.Has(application)
						this.iLaunchApplicationsListView.Add("", application, this.iLaunchApplications[application][1], this.iLaunchApplications[application][2])
					else
						this.iLaunchApplicationsListView.Add("", application, "", "")
				}
			}

		this.loadControllerLabels()

		this.iLaunchApplicationsListView.ModifyCol(1, 120)
		this.iLaunchApplicationsListView.ModifyCol(2, "AutoHdr")
		this.iLaunchApplicationsListView.ModifyCol(3, "AutoHdr")
	}

	saveApplications() {
		this.SetupWizard.setLaunchApplicationLabelsAndFunctions(this.iLaunchApplications)
	}

	loadControllerLabels() {
		local wizard := this.SetupWizard
		local row := false
		local column := false
		local function, action, ignore, preview, section, application, descriptor, label

		super.loadControllerLabels()

		for ignore, preview in this.ControllerPreviews {
			for ignore, section in string2Values(",", this.Definition[3])
				for application, descriptor in getMultiMapValues(wizard.Definition, section)
					if wizard.isApplicationSelected(application) {
						if this.iLaunchApplications.Has(application) {
							function := this.iLaunchApplications[application][2]

							if (function && (function != "")) {
								label := this.iLaunchApplications[application][1]

								for ignore, preview in this.ControllerPreviews
									if preview.findFunction(function, &row, &column) {
										preview.setLabel(row, column, (label != "") ? label : application)

										break
									}
							}
						}
					}
		}
	}

	addModeSelector(preview, function, control, row, column) {
		if !inList(this.iModeSelectors, function) {
			this.iModeSelectors.Push(function)

			SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

			this.iModeSelectorsListView.Delete()
			this.iModeSelectorsListView.Add(this.iModeSelectors)

			this.SetupWizard.addModuleStaticFunction("System", function, translate("Mode Selector"))

			this.loadControllerLabels()
		}
	}

	removeModeSelector(preview, function, control, row, column) {
		local index := inList(this.iModeSelectors, function)

		if index {
			this.iModeSelectors.RemoveAt(index)

			SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

			this.iModeSelectorsListView.Delete()
			this.iModeSelectorsListView.Add(this.iModeSelectors)

			this.SetupWizard.removeModuleStaticFunction("System", function)

			this.loadControllerLabels()
		}
	}

	setLaunchApplication(arguments) {
		this.iPendingApplicationRegistration := arguments

		SetTimer(showLaunchHint, 100)
	}

	clearLaunchApplication(preview, function, control, row, column) {
		local changed := false
		local found := true
		local application, candidate

		while found {
			found := false

			for application, candidate in this.iLaunchApplications
				if (candidate[2] = function) {
					SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

					this.iLaunchApplications.Delete(application)

					changed := true
					found := true
				}
		}

		if changed
			this.loadApplications()
	}

	setApplicationFunction(row) {
		local arguments

		if this.iPendingApplicationRegistration {
			arguments := this.iPendingApplicationRegistration

			this.iPendingApplicationRegistration := false
			this.iPendingFunctionRegistration := row

			this.controlClick(arguments*)
		}
		else {
			this.iPendingFunctionRegistration := row

			SetTimer(showLaunchHint, 100)
		}
	}

	clearApplicationFunction(row) {
		local application, function

		application := this.iLaunchApplicationsListView.GetText(row, 1)

		function := this.iLaunchApplications[application]

		if (function && (function != "")) {
			SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

			this.iLaunchApplications.Delete(application)

			this.loadApplications()
		}
	}

	controlClick(preview, element, function, row, column, isEmpty, applicationRegistration := false) {
		local application, menuItem, count, ignore, candidate, wizard, descriptor, contextMenu

		if ((element[1] = "Control") && !isEmpty) {
			if (!this.iPendingFunctionRegistration && !applicationRegistration) {
				menuItem := (translate(element[1]) . translate(": ") . StrReplace(StrReplace(element[2], "`n", A_Space), "`r", "") . " (" . row . " x " . column . ")")

				contextMenu := Menu()

				contextMenu.Add(menuItem, (*) => {})
				contextMenu.Disable(menuItem)
				contextMenu.Add()

				menuItem := translate("Set Mode Selector")

				contextMenu.Add(menuItem, (*) => this.addModeSelector(preview, function, element[2], row, column))

				if inList(this.iModeSelectors, function)
					contextMenu.Disable(menuItem)

				menuItem := translate("Clear Mode Selector")

				contextMenu.Add(menuItem, (*) => this.removeModeSelector(preview, function, element[2], row, column))

				if !inList(this.iModeSelectors, function)
					contextMenu.Disable(menuItem)

				contextMenu.Add()

				menuItem := translate("Set Application")

				contextMenu.Add(translate("Set Application")
							  , (*) => this.setLaunchApplication(Array(preview, element, function, row, column, false, true)))

				count := 0

				for ignore, candidate in this.iLaunchApplications
					if (candidate[2] == function)
						count += 1

				menuItem := translate((count > 1) ? "Clear Application(s)" : "Clear Application")

				contextMenu.Add(menuItem, (*) => this.clearLaunchApplication(preview, function, element[2], row, column))

				if (count == 0)
					contextMenu.Disable(menuItem)

				contextMenu.Show()
			}
			else {
				SoundPlay(kResourcesDirectory . "Sounds\Activated.wav")

				wizard := this.SetupWizard

				application := this.iLaunchApplicationsListView.GetText(this.iPendingFunctionRegistration, 1)

				if function {
					if this.iLaunchApplications.Has(application)
						this.iLaunchApplications[application][2] := function
					else {
						descriptor := getApplicationDescriptor(application)

						this.iLaunchApplications[application] := Array((descriptor ? descriptor[1] : ""), function)
					}

					this.loadApplications()

					this.iLaunchApplicationsListView.Modify(this.iPendingFunctionRegistration, "Vis")
				}

				SetTimer(showLaunchHint, 0)

				ToolTip( , , 1)

				this.iPendingFunctionRegistration := false
			}
		}
	}

	toggleTriggerDetector(callback := false) {
		this.SetupWizard.toggleTriggerDetector(callback)
	}

	openFormatsEditor() {
		local window := this.Window
		local configuration, editor

		static first := true

		if (this.SetupWizard.Initialize || !first)
			configuration := readMultiMap(kUserHomeDirectory . "Setup\Formats Configuration.ini")
		else
			configuration := kSimulatorConfiguration

		editor := FormatsEditor(configuration)

		window.Block()

		try {
			configuration := editor.editFormats(window)

			if configuration {
				first := false

				writeMultiMap(kUserHomeDirectory . "Setup\Formats Configuration.ini", configuration)
			}
		}
		finally {
			window.Unblock()
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

showLaunchHint() {
	local hint

	if (GetKeyState("Esc", "P") || !GeneralStepWizard.CurrentGeneralStep) {
		SetTimer(showSelectorHint, 0)

		if GeneralStepWizard.CurrentGeneralStep {
			GeneralStepWizard.CurrentGeneralStep.iPendingApplicationRegistration := false
			GeneralStepWizard.CurrentGeneralStep.iPendingFunctionRegistration := false
		}

		ToolTip( , , 1)
	}
	else if GeneralStepWizard.CurrentGeneralStep.iPendingFunctionRegistration {
		hint := translate("Click on a controller function...")

		ToolTip(hint, , , 1)
	}
	else if GeneralStepWizard.CurrentGeneralStep.iPendingApplicationRegistration {
		hint := translate("Click on an application...")

		ToolTip(hint, , , 1)
	}
}

initializeGeneralStepWizard() {
	SetupWizard.Instance.registerStepWizard(GeneralStepWizard(SetupWizard.Instance, "General", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeGeneralStepWizard()