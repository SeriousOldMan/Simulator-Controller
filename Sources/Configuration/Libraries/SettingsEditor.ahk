;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Settings Editor                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                   Public Constant Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

global kSave := "Save"
global kContinue := "Continue"
global kCancel := "Cancel"
global kUpdate := "Update"
global kEditModes := "Edit"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

editModes(&settingsOrCommand, arguments*) {
	global kSave, kCancel, kUpdate

	local modes, row, thePlugin, pluginConfiguration, ignore, mode, simulator, options
	Local defaultModes, pluginSimulators, x, y
	local index, session

	static newSettings
	static result := false

	static configuration := false
	static simulators := []

	static selectedSimulator := false
	static selectedSession := false
	static simulatorSessions := []

	static modesEditorGui
	static modeSimulatorDropDown
	static modeSessionDropDown
	static modesListView

	getSelectedModes(modesListView) {
		local rowNumber := 0
		local modes := []

		loop {
			rowNumber := modesListView.GetNext(rowNumber, "C")

			if !rowNumber
				break

			modes.Push(ConfigurationItem.descriptor(modesListView.GetText(rowNumber, 1), modesListView.GetText(rowNumber, 2)))
		}

		return modes
	}

	if ((settingsOrCommand = kSave) || (settingsOrCommand = kUpdate)) {
		modes := getSelectedModes(modesListView)

		if !selectedSimulator
			setMultiMapValue(newSettings, "Modes", "Default", values2String(",", modes*))
		else if !selectedSession
			setMultiMapValue(newSettings, "Modes", ConfigurationItem.descriptor(selectedSimulator, "Default"), values2String(",", modes*))
		else
			setMultiMapValue(newSettings, "Modes", ConfigurationItem.descriptor(selectedSimulator, simulatorSessions[selectedSession]), values2String(",", modes*))
	}

	if (settingsOrCommand = kUpdate) {
		modes := []

		if (modeSimulatorDropDown.Value == 1) {
			modes := string2Values(",", getMultiMapValue(newSettings, "Modes", "Default", ""))

			selectedSimulator := false
			selectedSession := false
			simulatorSessions := []

			modeSessionDropDown.Delete()
			modeSessionDropDown.Add([translate("Inactive")])
			modeSessionDropDown.Choose(1)
		}
		else {
			if (selectedSimulator != simulators[modeSimulatorDropDown.Value - 1]) {
				selectedSimulator := simulators[modeSimulatorDropDown.Value - 1]
				modeSessionDropDown.Choose(1)
				selectedSession := false

				simulatorSessions := string2Values(",", string2Values("|", getMultiMapValue(configuration, "Simulators", selectedSimulator, ""))[2])

				for index, session in simulatorSessions
					if (session = "Qualification")
						simulatorSessions[index] := "Qualifying"

				modeSessionDropDown.Delete()
				modeSessionDropDown.Add(concatenate([translate("Inactive")], collect(simulatorSessions, translate)))
				modeSessionDropDown.Choose(1)

				for index, session in simulatorSessions
					if (session = "Qualifying")
						simulatorSessions[index] := "Qualification"

				modes := string2Values(",", getMultiMapValue(newSettings, "Modes", ConfigurationItem.descriptor(selectedSimulator, "Default"), ""))
			}
			else {
				if (selectedSession != (modeSessionDropDown.Value - 1))
					selectedSession := modeSessionDropDown.Value - 1

				modes := string2Values(",", getMultiMapValue(newSettings, "Modes"
														   , ConfigurationItem.descriptor(selectedSimulator, !selectedSession ? "Default" : simulatorSessions[selectedSession]), ""))
			}
		}

		row := 1

		for thePlugin, pluginConfiguration in getMultiMapValues(configuration, "Plugins") {
			pluginConfiguration := string2Values("|", pluginConfiguration)

			for ignore, mode in string2Values(",", pluginConfiguration[3])
				modesListView.Modify(row++, inList(modes, ConfigurationItem.descriptor(thePlugin, mode)) ? "Check" : "-Check")
		}
	}

	if (settingsOrCommand = kSave) {
		modesEditorGui.Destroy()

		result := kSave
	}
	else if (settingsOrCommand = kCancel) {
		modesEditorGui.Destroy()

		result := kCancel
	}
	else if isObject(settingsOrCommand) {
		result := false
		newSettings := newMultiMap()

		setMultiMapValues(newSettings, "Modes", getMultiMapValues(settingsOrCommand, "Modes"))

		modesEditorGui := Window({Descriptor: "Simulator Settings.Automation", Options: "0x400000"})

		modesEditorGui.SetFont("Bold", "Arial")

		modesEditorGui.Add("Text", "w330 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(modesEditorGui, "Simulator Settings.Automation"))

		modesEditorGui.SetFont("Norm", "Arial")

		modesEditorGui.Add("Documentation", "x108 YP+20 w130 Center", translate("Controller Automation")
						 , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--settings")

		modesEditorGui.SetFont("Norm", "Arial")

		modesEditorGui.Add("Button", "x170 y280 w80 h23 Default", translate("Ok")).OnEvent("Click", editModes.Bind(&kSave))
		modesEditorGui.Add("Button", "x260 y280 w80 h23", translate("&Cancel")).OnEvent("Click", editModes.Bind(&kCancel))

		simulators := []

		selectedSimulator := false
		selectedSession := false
		simulatorSessions := []

		configuration := getControllerState()

		for simulator, options in getMultiMapValues(configuration, "Simulators")
			simulators.Push(simulator)

		modesEditorGui.Add("Text", "x8 y60 w86 h23 +0x200", translate("Simulator"))
		modeSimulatorDropDown := modesEditorGui.Add("DropDownList", "x100 y60 w240 Choose1", concatenate([translate("Inactive")], simulators))
		modeSimulatorDropDown.OnEvent("Change", editModes.Bind(&kUpdate))

		modesEditorGui.Add("Text", "x8 y84 w86 h23 +0x200", translate("Session"))
		modeSessionDropDown := modesEditorGui.Add("DropDownList", "x100 y84 w100 Choose1", [translate("Inactive")])
		modeSessionDropDown.OnEvent("Change", editModes.Bind(&kUpdate))

		modesEditorGui.Add("Text", "x8 y108 w80 h23 +0x200", translate("Modes"))
		modesListView := modesEditorGui.Add("ListView", "x100 y108 w240 h162 -Multi -LV0x10 Checked NoSort NoSortHdr", [translate("Plugin"), translate("Mode"), translate("Simulator(s)")])

		defaultModes := string2Values(",", getMultiMapValue(newSettings, "Modes", "Default", ""))

		for thePlugin, pluginConfiguration in getMultiMapValues(configuration, "Plugins") {
			pluginConfiguration := string2Values("|", pluginConfiguration)

			if pluginConfiguration[1] {
				pluginSimulators := values2String(", ", string2Values(",", pluginConfiguration[2])*)

				for ignore, mode in string2Values(",", pluginConfiguration[3])
					modesListView.Add(inList(defaultModes, ConfigurationItem.descriptor(thePlugin, mode)) ? "Check" : "", thePlugin, mode, pluginSimulators)
			}
		}

		modesListView.ModifyCol(1, "AutoHdr")
		modesListView.ModifyCol(2, "AutoHdr")
		modesListView.ModifyCol(3, "AutoHdr")

		modesEditorGui.MarginX := "10", modesEditorGui.MarginY := "10"

		if getWindowPosition("Simulator Settings.Automation", &x, &y)
			modesEditorGui.Show("x" . x . " y" . y)
		else
			modesEditorGui.Show()

		modesEditorGui.Opt("+Owner" . arguments[1].Hwnd)

		arguments[1].Opt("+Disabled")

		loop
			Sleep(200)
		until result

		arguments[1].Opt("-Disabled")
		arguments[1].Show("NoActivate")

		if (result == kSave)
			settingsOrCommand := newSettings

		return result
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Public Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

editSettings(&settingsOrCommand, withContinue := false, fromSetup := false, x := kUndefined, y := kUndefined) {
	global kSave, kCancel, kContinue, kUpdate, kEditModes

	local index, coreDescriptor, coreVariable, feedbackDescriptor, feedbackVariable, positions
	local descriptor, value, simulators, margin, choices, chosen, splashScreens, uiThemes
	local applicationName, enabled, coreHeight, index, coreDescriptor, ignore, theTheme
	local coreOption, coreLabel, checked, feedbackHeight, feedbackDescriptor, feedbackOption, feedbackLabel
	local applicationSettings

	static modeSettings
	static configuration

	static result
	static restart
	static newSettings
	static origSettings

	static settingsEditorGui
	static voiceRecognition
	static faceRecognition
	static viewTracking
	static simulatorController
	static tactileFeedback
	static motionFeedback
	static buttonBoxPosition
	static popupPosition
	static lastPositions

	static trayTipCheck
	static trayTipDurationInput
	static trayTipSimulationCheck
	static trayTipSimulationDurationInput
	static buttonBoxCheck
	static buttonBoxDurationInput
	static buttonBoxSimulationCheck
	static buttonBoxSimulationDurationInput

	static startup
	static startupOption

	static splashScreen
	static uiTheme

	static coreSettings
	static feedbackSettings

	static coreVariable1
	static coreVariable2
	static coreVariable3
	static coreVariable4
	static coreVariable5
	static coreVariable6
	static coreVariable7
	static coreVariable8

	static feedbackVariable1
	static feedbackVariable2
	static feedbackVariable3
	static feedbackVariable4
	static feedbackVariable5
	static feedbackVariable6
	static feedbackVariable7
	static feedbackVariable8

	setInputState(input, enabler) {
		if enabler.Value
			input.Enabled := true
		else {
			input.Enabled := false
			input.Text := 0
		}
	}

	checkTrayTipDuration(*) {
		setInputState(trayTipDurationInput, trayTipCheck)
	}

	checkTrayTipSimulationDuration(*) {
		setInputState(trayTipSimulationDurationInput, trayTipSimulationCheck)
	}

	checkButtonBoxDuration(*) {
		setInputState(buttonBoxDurationInput, buttonBoxCheck)
	}

	checkButtonBoxSimulationDuration(*) {
		setInputState(buttonBoxSimulationDurationInput, buttonBoxSimulationCheck)
	}

	startConfiguration(*) {
		local restart := "Restart"

		try {
			RunWait(kBinariesDirectory . "Simulator Configuration.exe")

			editSettings(&restart)
		}
		catch Any as exception {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("Cannot start the configuration tool - please check the installation..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}
	}

	if (settingsOrCommand == kSave) {
		try {
			newSettings := newMultiMap()

			for index, coreDescriptor in coreSettings {
				if (index > 1) {
					coreVariable := "coreVariable" . index

					setMultiMapValue(newSettings, "Core", coreDescriptor[1], %coreVariable%.Value)
				}
			}

			for index, feedbackDescriptor in feedbackSettings {
				feedbackVariable := "feedbackVariable" . index

				setMultiMapValue(newSettings, "Feedback", feedbackDescriptor[1], %feedbackVariable%.Value)
			}

			setMultiMapValue(newSettings, "Tray Tip", "Tray Tip Duration", (trayTipCheck.Value ? trayTipDurationInput.Value : false))
			setMultiMapValue(newSettings, "Tray Tip", "Tray Tip Simulation Duration", (trayTipSimulationCheck.Value ? trayTipSimulationDurationInput.Value : false))
			setMultiMapValue(newSettings, "Button Box", "Button Box Duration", (buttonBoxCheck.Value ? buttonBoxDurationInput.Value : false))
			setMultiMapValue(newSettings, "Button Box", "Button Box Simulation Duration", (buttonBoxSimulationCheck.Value ? buttonBoxSimulationDurationInput.Value : false))

			positions := ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "2nd Screen", "Last Position"]

			setMultiMapValue(newSettings, "Button Box", "Button Box Position", positions[inList(collect(positions, translate), buttonBoxPosition.Text)])

			positions := ["Top", "Bottom", "2nd Screen Top", "2nd Screen Bottom"]

			applicationSettings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(applicationSettings, "General", "Popup Position", positions[inList(collect(positions, translate), popupPosition.Text)])

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", applicationSettings)

			for descriptor, value in lastPositions
				setMultiMapValue(newSettings, "Button Box", descriptor, value)

			setMultiMapValue(newSettings, "Startup", "Splash Screen", (splashScreen.Text = translate("None")) ? false : splashScreen.Text)

			for ignore, theTheme in getAllUIThemes(configuration)
				if (translate(theTheme.Descriptor) = uiTheme.Text) {
					settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

					setMultiMapValue(settings, "General", "UI Theme", theTheme.Descriptor)

					writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

					Theme.CurrentTheme := theTheme

					break
				}

			setMultiMapValue(newSettings, "Startup", "Simulator", (startup.Value ? startupOption.Text : false))

			settingsEditorGui.Destroy()

			setMultiMapValues(newSettings, "Modes", getMultiMapValues(modeSettings, "Modes"))

			if fromSetup
				return newSettings
			else
				result := settingsOrCommand
		}
		catch Any as exception {
			if fromSetup
				return origSettings
			else
				logError(exception)
		}
	}
	else if (settingsOrCommand == kContinue) {
		settingsEditorGui.Destroy()

		result := settingsOrCommand
	}
	else if (settingsOrCommand == kCancel) {
		settingsEditorGui.Destroy()

		result := settingsOrCommand
	}
	else if (settingsOrCommand == kEditModes) {
		editModes(&modeSettings, settingsEditorGui, configuration)
	}
	else if (settingsOrCommand = "Restart")
		restart := true
	else {
		origSettings := settingsOrCommand
		configuration := (fromSetup ? fromSetup : kSimulatorConfiguration)
		modeSettings := newMultiMap()

		setMultiMapValues(modeSettings, "Modes", getMultiMapValues(settingsOrCommand, "Modes"))

		result := false
		restart := false

		settingsEditorGui := Window({Descriptor: "Simulator Settings", Options: "ToolWindow 0x400000"})

		settingsEditorGui.SetFont("Bold", "Arial")

		settingsEditorGui.Add("Text", "w220 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(settingsEditorGui, "Simulator Settings"))

		settingsEditorGui.SetFont("Norm", "Arial")

		settingsEditorGui.Add("Documentation", "x68 YP+20 w100 Center", translate("Settings")
							, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--settings")

		coreSettings := [["Simulator Controller", true, false], ["System Monitor", getMultiMapValue(settingsOrCommand, "Core", "System Monitor", false), true]]
		feedbackSettings := []

		for descriptor, applicationName in getMultiMapValues(configuration, "Applications") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			enabled := (getMultiMapValue(configuration, applicationName, "Exe Path", "") != "")

			if (descriptor[1] == "Core")
				coreSettings.Push(Array(applicationName, getMultiMapValue(settingsOrCommand, "Core", applicationName, false), enabled))
			else if (descriptor[1] == "Feedback")
				feedbackSettings.Push(Array(applicationName, getMultiMapValue(settingsOrCommand, "Feedback", applicationName, false), enabled))
		}

		if (coreSettings.Length > 8)
			throw "Too many Core Components detected in editSettings..."

		if (feedbackSettings.Length > 8)
			throw "Too many Feedback Components detected in editSettings..."

		coreHeight := 20 + (coreSettings.Length * 20)

		settingsEditorGui.SetFont("Norm", "Arial")
		settingsEditorGui.SetFont("Italic", "Arial")

		settingsEditorGui.Add("GroupBox", "x8 YP+30 w220 h" . coreHeight, translate("Start Core System"))

		settingsEditorGui.SetFont("Norm", "Arial")

		for index, coreDescriptor in coreSettings {
			coreOption := coreDescriptor[3] ? "" : "Disabled"
			coreLabel := coreDescriptor[1]
			checked := coreDescriptor[2]

			if (index == 1)
				coreOption := coreOption . " YP+20 X20"

			%"coreVariable" . index% := settingsEditorGui.Add("CheckBox", coreOption . " Checked" . checked, coreLabel)
		}

		if (feedbackSettings.Length > 0) {
			feedbackHeight := 20 + (feedbackSettings.Length * 20)

			settingsEditorGui.SetFont("Norm", "Arial")
			settingsEditorGui.SetFont("Italic", "Arial")

			settingsEditorGui.Add("GroupBox", "XP-10 YP+30 w220 h" . feedbackHeight, translate("Start Feedback System"))

			settingsEditorGui.SetFont("Norm", "Arial")

			for index, feedbackDescriptor in feedbackSettings {
				feedbackOption := feedbackDescriptor[3] ? "" : "Disabled"
				feedbackLabel := feedbackDescriptor[1]
				checked := feedbackDescriptor[2]

				if (index == 1)
					feedbackOption := feedbackOption . " YP+20 X20"

				%"feedbackVariable" . index% := settingsEditorGui.Add("CheckBox", feedbackOption . " Checked" . checked, feedbackLabel)
			}
		}

		trayTipDurationInput := getMultiMapValue(settingsOrCommand, "Tray Tip", "Tray Tip Duration", 1500)
		trayTipSimulationDurationInput := getMultiMapValue(settingsOrCommand, "Tray Tip", "Tray Tip Simulation Duration", 1500)
		buttonBoxDurationInput := getMultiMapValue(settingsOrCommand, "Button Box", "Button Box Duration", false)
		buttonBoxSimulationDurationInput := getMultiMapValue(settingsOrCommand, "Button Box", "Button Box Simulation Duration", false)
		buttonBoxPosition := getMultiMapValue(settingsOrCommand, "Button Box", "Button Box Position", "Bottom Right")

		popupPosition := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini"), "General", "Popup Position", "Bottom")

		lastPositions := CaseInsenseMap()

		for descriptor, value in getMultiMapValues(settingsOrCommand, "Button Box")
			if InStr(descriptor, ".Position.")
				lastPositions[descriptor] := value

		trayTipCheck := (trayTipDurationInput != 0) ? true : false
		trayTipSimulationCheck := (trayTipSimulationDurationInput != 0) ? true : false
		buttonBoxCheck := (buttonBoxDurationInput != 0) ? true : false
		buttonBoxSimulationCheck := (buttonBoxSimulationDurationInput != 0) ? true : false

		settingsEditorGui.SetFont("Norm", "Arial")
		settingsEditorGui.SetFont("Italic", "Arial")

		settingsEditorGui.Add("GroupBox", "XP-10 YP+30 w220 h160", translate("Controller Notifications"))

		settingsEditorGui.SetFont("Norm", "Arial")

		trayTipCheck := settingsEditorGui.Add("CheckBox", "X20 YP+20 Checked" . trayTipCheck . " Section", translate("Tray Tips"))
		trayTipCheck.OnEvent("Click", checkTrayTipDuration)
		trayTipDurationInput := settingsEditorGui.Add("Edit", "X160 YP-5 w40 h20 Limit5 Number " . (!trayTipCheck.Value ? "Disabled" : ""), trayTipDurationInput)
		settingsEditorGui.Add("Text", "X205 YP+5", translate("ms"))

		trayTipSimulationCheck := settingsEditorGui.Add("CheckBox", "XS YP+20 Checked" . trayTipSimulationCheck, translate("Tray Tips (Simulation)"))
		trayTipSimulationCheck.OnEvent("Click", checkTrayTipSimulationDuration)
		trayTipSimulationDurationInput := settingsEditorGui.Add("Edit", "X160 YP-5 w40 h20 Limit5 Number " . (!trayTipSimulationCheck.Value ? "Disabled" : ""), trayTipSimulationDurationInput)
		settingsEditorGui.Add("Text", "X205 YP+5", translate("ms"))

		buttonBoxCheck := settingsEditorGui.Add("CheckBox", "XS YP+20 Checked" . buttonBoxCheck, translate("Button Box"))
		buttonBoxCheck.OnEvent("Click", checkButtonBoxDuration)
		buttonBoxDurationInput := settingsEditorGui.Add("Edit", "X160 YP-5 w40 h20 Limit5 Number " . (!buttonBoxCheck.Value ? "Disabled" : ""), buttonBoxDurationInput)
		settingsEditorGui.Add("Text", "X205 YP+5", translate("ms"))

		buttonBoxSimulationCheck := settingsEditorGui.Add("CheckBox", "XS YP+20 Checked" . buttonBoxSimulationCheck, translate("Button Box (Simulation)"))
		buttonBoxSimulationCheck.OnEvent("Click", checkButtonBoxSimulationDuration)
		buttonBoxSimulationDurationInput := settingsEditorGui.Add("Edit", "X160 YP-5 w40 h20 Limit5 Number " . (!buttonBoxSimulationCheck.Value ? "Disabled" : ""), buttonBoxSimulationDurationInput)
		settingsEditorGui.Add("Text", "X205 YP+5", translate("ms"))

		settingsEditorGui.Add("Text", "XS YP+30", translate("Button Box Position"))

		if (buttonBoxPosition = "Secondary Screen")
			buttonBoxPosition := "2nd Screen"

		choices := ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "2nd Screen", "Last Position"]
		chosen := inList(choices, buttonBoxPosition)

		if !chosen
			chosen := 4

		buttonBoxPosition := settingsEditorGui.Add("DropDownList", "X120 YP-5 w100 Choose" . chosen, collect(choices, translate))

		settingsEditorGui.Add("Text", "XS YP+30", translate("Overlay Position"))

		choices := ["Top", "Bottom", "2nd Screen Top", "2nd Screen Bottom"]
		chosen := inList(choices, popupPosition)

		if !chosen
			chosen := 1

		popupPosition := settingsEditorGui.Add("DropDownList", "X120 YP-5 w100 Choose" . chosen, collect(choices, translate))

		if fromSetup
			settingsEditorGui.Add("Button", "X10 Y+15 w220 Disabled", translate("Controller Automation..."))
		else
			settingsEditorGui.Add("Button", "X10 Y+15 w220", translate("Controller Automation...")).OnEvent("Click", editSettings.Bind(&kEditModes))

		uiTheme := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini"), "General", "UI Theme", Theme.CurrentTheme.Descriptor)

		splashScreen := getMultiMapValue(settingsOrCommand, "Startup", "Splash Screen", false)
		splashScreens := getAllSplashScreens(configuration)

		uiThemes := []

		for ignore, theTheme in getAllUIThemes(configuration)
			uiThemes.Push(theTheme.Descriptor)

		chosen := inList(uiThemes, uiTheme)

		if (!chosen && (uiThemes.Length > 0))
			chosen := 1

		settingsEditorGui.Add("Text", "X10 Y+20", translate("Color Scheme"))
		uiTheme := settingsEditorGui.Add("DropDownList", "X90 YP-5 w140 Choose" . chosen, collect(uiThemes, translate))

		chosen := (splashScreen ? inList(splashScreens, splashScreen) + 1 : 1)
		splashScreens := concatenate([translate("None")], splashScreens)

		settingsEditorGui.Add("Text", "X10", translate("Splash Screen"))
		splashScreen := settingsEditorGui.Add("DropDownList", "X90 YP-5 w140 Choose" . chosen, splashScreens)

		startupOption := getMultiMapValue(settingsOrCommand, "Startup", "Simulator", false)
		startup := (startupOption != false)

		startup := settingsEditorGui.Add("CheckBox", "X10 Checked" . startup, translate("Start"))

		simulators := string2Values("|", getMultiMapValue(configuration, "Configuration", "Simulators", ""))

		chosen := inList(simulators, startupOption)

		if ((chosen == 0) && (simulators.Length > 0))
			chosen := 1

		startupOption := settingsEditorGui.Add("DropDownList", "X90 YP-5 w140 Choose" . chosen, simulators)

		if !fromSetup {
			settingsEditorGui.Add("Button", "X10 Y+20 w220", translate("Configuration...")).OnEvent("Click", startConfiguration)

			margin := (withContinue ? "Y+20" : "")

			settingsEditorGui.Add("Button", "Default X10 " . margin . " w100", translate("Save")).OnEvent("Click", editSettings.Bind(&kSave))
			settingsEditorGui.Add("Button", "X+20 w100", translate("&Cancel")).OnEvent("Click", editSettings.Bind(&kCancel))

			if withContinue
				settingsEditorGui.Add("Button", "X10 w220", translate("Co&ntinue w/o Save")).OnEvent("Click", editSettings.Bind(&kContinue))
		}

		settingsEditorGui.MarginX := "10", settingsEditorGui.MarginY := "10"

		if ((x = kUndefined) || (y = kUndefined)) {
			if getWindowPosition("Simulator Settings", &x, &y)
				settingsEditorGui.Show("x" . x . " y" . y)
			else
				settingsEditorGui.Show()
		}
		else
			settingsEditorGui.Show("AutoSize x" . x . " y" . y)

		if (!fromSetup && (readMultiMap(kSimulatorConfigurationFile).Count == 0))
			startConfiguration()

		if fromSetup
			return false
		else {
			loop
				Sleep(200)
			until (result || restart)

			if (restart && (result != kCancel)) {
				restart := false

				settingsEditorGui.Destroy()

				loadSimulatorConfiguration()

				result := editSettings(&settingsOrCommand)
			}

			if (result == kSave)
				settingsOrCommand := newSettings

			return result
		}
	}
}