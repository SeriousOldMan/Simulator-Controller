;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - General Step Wizard             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include Libraries\ControllerStepWizard.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; GeneralStepWizard                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global uiLanguageDropDown := ""
global startWithWindowsCheck := 1
global silentModeCheck := 1

class GeneralStepWizard extends ControllerPreviewStepWizard {
	static sCurrentGeneralStep := false

	iVoiceControlConfigurator := false
	iModeSelectorsListHandle := false
	iLaunchApplicationsListHandle := false

	iModeSelectors := []
	iLaunchApplications := {}

	iPendingApplicationRegistration := false
	iPendingFunctionRegistration := false

	iControllerWidgets := []
	iVoiceControlWidgets := []

	Pages[] {
		Get {
			return 1
		}
	}

	CurrentGeneralStep[] {
		Get {
			return GeneralStepWizard.sCurrentGeneralStep
		}
	}

	saveToConfiguration(configuration) {
		local wizard := this.SetupWizard
		local application, function, path, directory, voiceControlConfiguration, ignore, section, subConfiguration
		local modeSelectors, arguments, launchApplications, descriptor, label

		base.saveToConfiguration(configuration)

		setConfigurationSectionValues(configuration, "Splash Window", getConfigurationSectionValues(this.SetupWizard.Definition, "Splash Window"))
		setConfigurationSectionValues(configuration, "Splash Themes", getConfigurationSectionValues(this.SetupWizard.Definition, "Splash Themes"))

		wizard.getGeneralConfiguration(language, startWithWindows, silentMode)

		setConfigurationValue(configuration, "Configuration", "Language", language)
		setConfigurationValue(configuration, "Configuration", "Start With Windows", startWithWindows)
		setConfigurationValue(configuration, "Configuration", "Silent Mode", silentMode)

		setConfigurationValue(configuration, "Configuration", "Log Level", "Warn")
		setConfigurationValue(configuration, "Configuration", "Debug", false)

		if wizard.isSoftwareInstalled("NirCmd") {
			path := wizard.softwarePath("NirCmd")

			SplitPath path, , directory

			setConfigurationValue(configuration, "Configuration", "NirCmd Path", directory)
		}

		if wizard.isModuleSelected("Voice Control") {
			voiceControlConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Voice Control Configuration.ini")

			for ignore, section in ["Voice Control"] {
				subConfiguration := getConfigurationSectionValues(voiceControlConfiguration, section, false)

				if subConfiguration
					setConfigurationSectionValues(configuration, section, subConfiguration)
			}
		}
		else {
			setConfigurationValue(configuration, "Voice Control", "Synthesizer", "dotNET")
			setConfigurationValue(configuration, "Voice Control", "Speaker", false)
			setConfigurationValue(configuration, "Voice Control", "Listener", false)
		}

		modeSelectors := wizard.getModeSelectors()
		arguments := ""

		if (modeSelectors.Length() > 0)
			arguments := ("modeSelector: " . values2String(A_Space, modeSelectors*))

		launchApplications := []

		for ignore, section in string2Values(",", this.Definition[3])
			for application, descriptor in getConfigurationSectionValues(wizard.Definition, section) {
				if wizard.isApplicationSelected(application) {
					function := wizard.getLaunchApplicationFunction(application)

					if (function && (function != "")) {
						label := wizard.getLaunchApplicationLabel(application)

						if (label = "")
							label := application

						launchApplications.Push("""" . label . """ """ . application . """ " . function)
					}
				}
			}

		if (launchApplications.Length() > 0) {
			if (arguments != "")
				arguments .= "; "

			arguments .= ("launchApplications: " . values2String(", ", launchApplications*))
		}

		new Plugin("System", false, true, "", arguments).saveToConfiguration(configuration)
	}

	createGui(wizard, x, y, width, height) {
		local window := this.Window
		local generalIconHandle := false
		local generalLabelHandle := false
		local generalInfoTextHandle := false
		local languageLabelHandle := false
		local languageDropDownHandle := false
		local startWithWindowsHandle := false
		local silentModeHandle := false
		local labelWidth := width - 30
		local labelX := x + 35
		local labelY := y + 8
		local colummLabel1Handle := false
		local colummLine1Handle := false
		local colummLabel2Handle := false
		local colummLine2Handle := false
		local colummLabel3Handle := false
		local colummLine3Handle := false
		local modeSelectorsLabelHandle := false
		local modeSelectorsListHandle := false
		local launchApplicationsLabelHandle := false
		local launchApplicationsListHandle := false
		local secondX := x + 105
		local secondWidth := width - 105
		local col1Width := (secondX - x) + 120
		local col2X := secondX + 140
		local col2Width := width - 140 - secondX + x
		local choices, code, language, info, html, configurator

		static generalInfoText

		Gui %window%:Default

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x%x% y%y% w30 h30 HWNDgeneralIconHandle Hidden, %kResourcesDirectory%Setup\Images\Gears.ico
		Gui %window%:Add, Text, x%labelX% y%labelY% w%labelWidth% h26 HWNDgeneralLabelHandle Hidden, % translate("General Configuration")

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Font, Bold, Arial

		Gui %window%:Add, Text, x%x% yp+30 w%col1Width% h23 +0x200 HWNDcolumnLabel1Handle Hidden Section, % translate("General")
		Gui %window%:Add, Text, yp+20 x%x% w%col1Width% 0x10 HWNDcolumnLine1Handle Hidden

		Gui %window%:Font, Norm, Arial

		choices := []

		for code, language in availableLanguages()
			choices.Push(language)

		Gui %window%:Add, Text, x%x% yp+10 w86 h23 +0x200 HWNDlanguageLabelHandle Hidden, % translate("Language")
		Gui %window%:Add, DropDownList, x%secondX% yp w120 HWNDlanguageDropDownHandle VuiLanguageDropDown Hidden, % values2String("|", choices*)

		Gui %window%:Add, CheckBox, x%x% yp+30 w242 h23 Checked%startWithWindowsCheck% HWNDstartWithWindowsHandle VstartWithWindowsCheck Hidden, % translate("Start with Windows")
		Gui %window%:Add, CheckBox, x%x% yp+24 w242 h23 Checked%silentModeCheck% HWNDsilentModeHandle VsilentModeCheck Hidden, % translate("Silent mode (no splash screen, no sound)")

		Gui %window%:Font, Bold, Arial

		Gui %window%:Add, Text, x%x% yp+30 w%col1Width% h23 +0x200 HWNDcolumnLabel3Handle Hidden, % translate("Controller")
		Gui %window%:Add, Text, yp+20 x%x% w%col1Width% 0x10 HWNDcolumnLine3Handle Hidden

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x%x% yp+10 w105 h23 +0x200 HWNDmodeSelectorsLabelHandle Hidden, % translate("Mode Selector")
		Gui %window%:Add, ListBox, x%secondX% yp w120 h60 Disabled ReadOnly HWNDmodeSelectorsListHandle Hidden

		Gui %window%:Add, Text, x%x% yp+60 w140 h23 +0x200 HWNDlaunchApplicationsLabelHandle Hidden, % translate("Launchpad Mode")
		Gui %window%:Add, ListView, x%x% yp+24 w%col1Width% h112 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDlaunchApplicationsListHandle gupdateApplicationFunction Hidden, % values2String("|", map(["Application", "Label", "Function"], "translate")*)

		info := substituteVariables(getConfigurationValue(this.SetupWizard.Definition, "Setup.General", "General.Settings.Info." . getLanguage()))
		info := "<div style='font-family: Arial, Helvetica, sans-serif' style='font-size: 11px'><hr style='width: 90%'>" . info . "</div>"

		Sleep 200

		Gui %window%:Add, ActiveX, x%x% yp+118 w%width% h94 HWNDgeneralInfoTextHandle VgeneralInfoText Hidden, shell.explorer

		html := "<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . info . "</body></html>"

		generalInfoText.Navigate("about:blank")
		generalInfoText.Document.Write(html)

		Gui %window%:Font, Bold, Arial

		Gui %window%:Add, Text, x%col2X% ys w%col2Width% h23 +0x200 HWNDcolumnLabel2Handle Hidden Section, % translate("Voice Control")
		Gui %window%:Add, Text, yp+20 x%col2X% w%col2Width% 0x10 HWNDcolumnLine2Handle Hidden

		Gui %window%:Font, Norm, Arial

		configurator := new VoiceControlConfigurator(this)

		this.iVoiceControlConfigurator := configurator

		configurator.createGui(this, col2X, labelY + 30 + 30, col2Width, height, 0)
		configurator.hideWidgets()

		this.iModeSelectorsListHandle := modeSelectorsListHandle
		this.iLaunchApplicationsListHandle := launchApplicationsListHandle

		this.iControllerWidgets := Array(modeSelectorsLabelHandle, modeSelectorsListHandle, launchApplicationsLabelHandle, launchApplicationsListHandle, columnLabel3Handle, columnLine3Handle)
		this.iVoiceControlWidgets := Array(columnLabel2Handle, columnLine2Handle)

		this.registerWidgets(1, generalIconHandle, generalLabelHandle, modeSelectorsLabelHandle, modeSelectorsListHandle, launchApplicationsLabelHandle, launchApplicationsListHandle, generalInfoTextHandle, columnLabel1Handle, columnLine1Handle, columnLabel2Handle, columnLine2Handle, columnLabel3Handle, columnLine3Handle, languageLabelHandle, languageDropDownHandle, startWithWindowsHandle, silentModeHandle)
	}

	registerWidget(page, widget) {
		if (page = this.iVoiceControlConfigurator)
			base.registerWidget(1, widget)
		else
			base.registerWidget(page, widget)
	}

	reset() {
		base.reset()

		this.iVoiceControlConfigurator := false
		this.iModeSelectorsListHandle := false
		this.iLaunchApplicationsListHandle := false

		this.iControllerWidgets := []
		this.iVoiceControlWidgets := []

		this.iModeSelectors := []
		this.iLaunchApplications := {}
	}

	showPage(page) {
		local wizard := this.SetupWizard
		local window := this.Window
		local chosen := 0
		local enIndex := 0
		local code, language, configuration, voiceControlConfiguration, ignore, section, subConfiguration
		local path, directory, widget, listBox

		GeneralStepWizard.sCurrentGeneralStep := this

		base.showPage(page)

		Gui %window%:Default

		wizard.getGeneralConfiguration(uiLanguage, startWithWindows, silentMode)

		for code, language in availableLanguages() {
			if (code = uiLanguage)
				chosen := A_Index
			else if (code = "en")
				enIndex := A_Index
		}

		if (chosen == 0)
			chosen := enIndex

		GuiControl Choose, uiLanguageDropDown, %chosen%
		GuiControl, , startWithWindowsCheck, % startWithWindows
		GuiControl, , silentModeCheck, % silentMode

		this.iModeSelectors := wizard.getModeSelectors()

		this.iVoiceControlConfigurator.hideWidgets()

		if this.SetupWizard.isModuleSelected("Voice Control") {
			configuration := this.SetupWizard.getSimulatorConfiguration()
			voiceControlConfiguration := readConfiguration(kUserHomeDirectory . "Setup\Voice Control Configuration.ini")

			for ignore, section in ["Voice Control"] {
				subConfiguration := getConfigurationSectionValues(voiceControlConfiguration, section, false)

				if subConfiguration
					setConfigurationSectionValues(configuration, section, subConfiguration)
			}

			if (getConfigurationValue(configuration, "Voice Control", "SoX Path", "") = "") {
				path := wizard.softwarePath("SoX")

				if path {
					SplitPath path, , directory

					setConfigurationValue(configuration, "Voice Control", "SoX Path", directory)
				}
			}

			this.iVoiceControlConfigurator.loadConfigurator(configuration)
			this.iVoiceControlConfigurator.showWidgets()
		}
		else
			for ignore, widget in this.iVoiceControlWidgets
				GuiControl Hide, %widget%

		if this.SetupWizard.isModuleSelected("Controller") {
			listBox := this.iModeSelectorsListHandle

			GuiControl, , %listBox%, % "|" . values2String("|", this.iModeSelectors*)

			this.loadApplications(true)
		}
		else
			for ignore, widget in this.iControllerWidgets
				GuiControl Hide, %widget%
	}

	hidePage(page) {
		local wizard, window, languageCode, code, language, configuration, voiceControlConfiguration
		local ignore, section, subConfiguration

		this.iVoiceControlConfigurator.hideWidgets()

		if base.hidePage(page) {
			GeneralStepWizard.sCurrentGeneralStep := false

			wizard := this.SetupWizard
			window := this.Window

			Gui %window%:Default

			GuiControlGet uiLanguageDropDown
			GuiControlGet startWithWindowsCheck
			GuiControlGet silentModeCheck

			languageCode := "en"

			for code, language in availableLanguages()
				if (language = uiLanguageDropDown) {
					languageCode := code

					break
				}

			wizard.setGeneralConfiguration(languageCode, startWithWindowsCheck, silentModeCheck)

			if wizard.isModuleSelected("Controller") {
				wizard.setModeSelectors(this.iModeSelectors)

				this.saveApplications()
			}

			if wizard.isModuleSelected("Voice Control") {
				configuration := newConfiguration()

				this.iVoiceControlConfigurator.saveToConfiguration(configuration)

				voiceControlConfiguration := newConfiguration()

				for ignore, section in ["Voice Control"] {
					subConfiguration := getConfigurationSectionValues(configuration, section, false)

					if subConfiguration
						setConfigurationSectionValues(voiceControlConfiguration, section, subConfiguration)
				}

				writeConfiguration(kUserHomeDirectory . "Setup\Voice Control Configuration.ini", voiceControlConfiguration)
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
		local window := this.Window
		local wizard := this.SetupWizard
		local application, function, row, column, ignore, section, application, descriptor

		if load
			this.iLaunchApplications := {}

		Gui %window%:Default

		Gui ListView, % this.iLaunchApplicationsListHandle

		LV_Delete()

		row := false
		column := false

		for ignore, section in string2Values(",", this.Definition[3])
			for application, descriptor in getConfigurationSectionValues(wizard.Definition, section) {
				if wizard.isApplicationSelected(application) {
					if load {
						function := wizard.getLaunchApplicationFunction(application)

						if (function != "")
							this.iLaunchApplications[application] := Array(wizard.getLaunchApplicationLabel(application), function)
					}

					if this.iLaunchApplications.HasKey(application)
						LV_Add("", application, this.iLaunchApplications[application][1], this.iLaunchApplications[application][2])
					else
						LV_Add("", application, "", "")
				}
			}

		this.loadControllerLabels()

		LV_ModifyCol(1, 120)
		LV_ModifyCol(2, "AutoHdr")
		LV_ModifyCol(3, "AutoHdr")
	}

	saveApplications() {
		this.SetupWizard.setLaunchApplicationLabelsAndFunctions(this.iLaunchApplications)
	}

	loadControllerLabels() {
		local wizard := this.SetupWizard
		local row := false
		local column := false
		local application, function, action, ignore, preview, section, application, descriptor, label

		base.loadControllerLabels()

		for ignore, preview in this.ControllerPreviews {
			for ignore, section in string2Values(",", this.Definition[3])
				for application, descriptor in getConfigurationSectionValues(wizard.Definition, section)
					if wizard.isApplicationSelected(application) {
						if this.iLaunchApplications.HasKey(application) {
							function := this.iLaunchApplications[application][2]

							if (function != "") {
								label := this.iLaunchApplications[application][1]

								for ignore, preview in this.ControllerPreviews
									if preview.findFunction(function, row, column) {
										preview.setLabel(row, column, (label != "") ? label : application)

										break
									}
							}
						}
					}
		}
	}

	addModeSelector(preview, function, control, row, column) {
		local listBox

		if !inList(this.iModeSelectors, function) {
			this.iModeSelectors.Push(function)

			SoundPlay %kResourcesDirectory%Sounds\Activated.wav

			listBox := this.iModeSelectorsListHandle

			GuiControl, , %listBox%, % "|" . values2String("|", this.iModeSelectors*)

			this.SetupWizard.addModuleStaticFunction("System", function, translate("Mode Selector"))

			this.loadControllerLabels()
		}
	}

	removeModeSelector(preview, function, control, row, column) {
		local index := inList(this.iModeSelectors, function)
		local listBox

		if index {
			this.iModeSelectors.RemoveAt(index)

			SoundPlay %kResourcesDirectory%Sounds\Activated.wav

			listBox := this.iModeSelectorsListHandle

			GuiControl, , %listBox%, % "|" . values2String("|", this.iModeSelectors*)

			this.SetupWizard.removeModuleStaticFunction("System", function)

			this.loadControllerLabels()
		}
	}

	setLaunchApplication(arguments) {
		this.iPendingApplicationRegistration := arguments

		SetTimer showLaunchHint, 100
	}

	clearLaunchApplication(preview, function, control, row, column) {
		local changed := false
		local found := true
		local application, candidate

		while found {
			found := false

			for application, candidate in this.iLaunchApplications
				if (candidate[2] = function) {
					SoundPlay %kResourcesDirectory%Sounds\Activated.wav

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

			SetTimer showLaunchHint, 100
		}
	}

	clearApplicationFunction(row) {
		local window := this.Window
		local application, function

		Gui %window%:Default
		Gui ListView, % this.iLaunchApplicationsListHandle

		LV_GetText(application, row, 1)

		function := this.iLaunchApplications[application]

		if (function && (function != "")) {
			SoundPlay %kResourcesDirectory%Sounds\Activated.wav

			this.iLaunchApplications.Delete(application)

			this.loadApplications()
		}
	}

	controlClick(preview, element, function, row, column, isEmpty, applicationRegistration := false) {
		local application, menuItem, window, handler, count, ignore, candidate, wizard, descriptor

		if (element[1] = "Control") {
			if (!this.iPendingFunctionRegistration && !applicationRegistration) {
				menuItem := (translate(element[1]) . translate(": ") . element[2] . " (" . row . " x " . column . ")")

				try {
					Menu ContextMenu, DeleteAll
				}
				catch exception {
					; ignore
				}

				window := SetupWizard.Instance.WizardWindow

				Gui %window%:Default

				Menu ContextMenu, Add, %menuItem%, controlMenuIgnore
				Menu ContextMenu, Disable, %menuItem%
				Menu ContextMenu, Add

				menuItem := translate("Set Mode Selector")
				handler := ObjBindMethod(this, "addModeSelector", preview, function, element[2], row, column)

				Menu ContextMenu, Add, %menuItem%, %handler%

				if inList(this.iModeSelectors, function)
					Menu ContextMenu, Disable, %menuItem%

				menuItem := translate("Clear Mode Selector")
				handler := ObjBindMethod(this, "removeModeSelector", preview, function, element[2], row, column)

				Menu ContextMenu, Add, %menuItem%, %handler%

				if !inList(this.iModeSelectors, function)
					Menu ContextMenu, Disable, %menuItem%

				Menu ContextMenu, Add

				menuItem := translate("Set Application")
				handler := ObjBindMethod(this, "setLaunchApplication", Array(preview, element, function, row, column, false, true))

				Menu ContextMenu, Add, %menuItem%, %handler%

				count := 0

				for ignore, candidate in this.iLaunchApplications
					if (candidate[2] == function)
						count += 1

				menuItem := translate((count > 1) ? "Clear Application(s)" : "Clear Application")
				handler := ObjBindMethod(this, "clearLaunchApplication", preview, function, element[2], row, column)

				Menu ContextMenu, Add, %menuItem%, %handler%

				if (count == 0)
					Menu ContextMenu, Disable, %menuItem%

				Menu ContextMenu, Show
			}
			else {
				SoundPlay %kResourcesDirectory%Sounds\Activated.wav

				wizard := this.SetupWizard
				window := this.Window

				Gui %window%:Default
				Gui ListView, % this.iLaunchApplicationsListHandle

				LV_GetText(application, this.iPendingFunctionRegistration, 1)

				if function {
					if this.iLaunchApplications.HasKey(application)
						this.iLaunchApplications[application][2] := function
					else {
						descriptor := getApplicationDescriptor(application)

						this.iLaunchApplications[application] := Array((descriptor ? descriptor[1] : ""), function)
					}

					this.loadApplications()

					window := this.Window

					Gui %window%:Default
					Gui ListView, % this.iLaunchApplicationsListHandle

					LV_Modify(this.iPendingFunctionRegistration, "Vis")
				}

				SetTimer showLaunchHint, Off

				ToolTip, , , 1

				this.iPendingFunctionRegistration := false
			}
		}
	}

	toggleTriggerDetector(callback := false) {
		this.SetupWizard.toggleTriggerDetector(callback)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateApplicationFunction() {
	local function, wizard, row, curCoordMode, menuItem, window, handler

	loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")

	wizard := SetupWizard.Instance.StepWizards["General"]

	if ((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) {
		if (A_EventInfo > 0) {
			if wizard.SetupWizard.isModuleSelected("Controller") {
				row := A_EventInfo

				if wizard.iPendingApplicationRegistration
					wizard.setApplicationFunction(row)
				else {
					curCoordMode := A_CoordModeMouse

					LV_GetText(application, row, 1)

					menuItem := application

					try {
						Menu ContextMenu, DeleteAll
					}
					catch exception {
						; ignore
					}

					window := wizard.Window

					Gui %window%:Default

					Menu ContextMenu, Add, %menuItem%, controlMenuIgnore
					Menu ContextMenu, Disable, %menuItem%

					Menu ContextMenu, Add

					menuItem := translate("Set Function")
					handler := ObjBindMethod(wizard, "setApplicationFunction", row)

					Menu ContextMenu, Add, %menuItem%, %handler%

					menuItem := translate("Clear Function")
					handler := ObjBindMethod(wizard, "clearApplicationFunction", row)

					Menu ContextMenu, Add, %menuItem%, %handler%

					Gui ListView, % wizard.iLaunchApplicationsListHandle

					LV_GetText(application, row, 1)

					function := wizard.iLaunchApplications[application]

					if (!function || (function = ""))
						Menu ContextMenu, Disable, %menuItem%

					Menu ContextMenu, Add

					menuItem := translate("Input Label...")
					handler := Func("inputLabel").Bind(wizard, row)

					Menu ContextMenu, Add, %menuItem%, %handler%

					Menu ContextMenu, Show
				}
			}
		}

		loop % LV_GetCount()
			LV_Modify(A_Index, "-Select")
	}
}

inputLabel(wizard, row) {
	local window := wizard.Window
	local title := translate("Modular Simulator Controller System")
	local prompt := translate("Please enter a label:")
	local function, locale, application, label, function

	Gui %window%:Default
	Gui ListView, % wizard.iLaunchApplicationsListHandle

	LV_GetText(application, row, 1)
	LV_GetText(label, row, 2)
	LV_GetText(function, row, 3)

	locale := ((getLanguage() = "en") ? "" : "Locale")

	InputBox label, %title%, %prompt%, , 200, 150, , , %locale%, , %label%

	if ErrorLevel
		return
	else {
		if wizard.iLaunchApplications.HasKey(application)
			wizard.iLaunchApplications[application][1] := label
		else
			wizard.iLaunchApplications[application] := Array(label, "")

		SoundPlay %kResourcesDirectory%Sounds\Activated.wav

		wizard.loadApplications()
	}
}

showLaunchHint() {
	local hint

	if (GetKeyState("Esc", "P") || !GeneralStepWizard.CurrentGeneralStep) {
		SetTimer showSelectorHint, Off

		GeneralStepWizard.CurrentGeneralStep.iPendingApplicationRegistration := false
		GeneralStepWizard.CurrentGeneralStep.iPendingFunctionRegistration := false

		ToolTip, , , 1
	}
	else if GeneralStepWizard.CurrentGeneralStep.iPendingFunctionRegistration {
		hint := translate("Click on a controller function...")

		ToolTip %hint%, , , 1
	}
	else if GeneralStepWizard.CurrentGeneralStep.iPendingApplicationRegistration {
		hint := translate("Click on an application...")

		ToolTip %hint%, , , 1
	}
}

initializeGeneralStepWizard() {
	SetupWizard.Instance.registerStepWizard(new GeneralStepWizard(SetupWizard.Instance, "General", kSimulatorConfiguration))
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeGeneralStepWizard()