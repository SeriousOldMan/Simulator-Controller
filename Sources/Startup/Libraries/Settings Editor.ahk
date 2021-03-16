;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Settings Editor                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                   Public Constant Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

global kSave = "Save"
global kContinue = "Continue"
global kCancel = "Cancel"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Variable Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global vRestart = false

global trayTipEnabled
global trayTipDurationInput
global trayTipSimulationEnabled
global trayTipSimulationDurationInput
global buttonBoxEnabled
global buttonBoxDurationInput
global buttonBoxSimulationEnabled
global buttonBoxSimulationDurationInput


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

saveSettings() {
	editSettings(kSave)
}

continueSettings() {
	editSettings(kContinue)
}

cancelSettings() {
	editSettings(kCancel)
}

setInputState(input, enabled) {
	if enabled
		GuiControl Enable, %input%
	else {
		GuiControl Disable, %input%
		GuiControl Text, %input%, 0
	}
}

startConfiguration() {
	try {
		RunWait % kBinariesDirectory . "Simulator Configuration.exe"
	}
	catch exception {
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		error := translate("Error")
		MsgBox 262160, %error%, % translate("Cannot start the configuration tool - please check the installation...")
		OnMessage(0x44, "")
	}
	
	if ErrorLevel
		vRestart := true
}

checkTrayTipDuration() {
	setInputState(trayTipDurationInput, (trayTipEnabled := !trayTipEnabled))
}

checkTrayTipSimulationDuration() {
	setInputState(trayTipSimulationDurationInput, (trayTipSimulationEnabled := !trayTipSimulationEnabled))
}

checkButtonBoxDuration() {
	setInputState(buttonBoxDurationInput, (buttonBoxEnabled := !buttonBoxEnabled))
}

checkButtonBoxSimulationDuration() {
	setInputState(buttonBoxSimulationDurationInput, (buttonBoxSimulationEnabled := !buttonBoxSimulationEnabled))
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

computeStartupSongs() {
	files := concatenate(getFileNames("*.wav", kUserSplashMediaDirectory, kSplashMediaDirectory), getFileNames("*.mp3", kUserSplashMediaDirectory, kSplashMediaDirectory))
	
	for index, fileName in files {
		SplitPath fileName, soundFile
		
		files[index] := soundFile
	}
	
	return files
}

moveEditor() {
	moveByMouse("CE")
}

editSettings(ByRef settingsOrCommand, withContinue := false) {
	static result
	static newSettings
	
	static voiceRecognition
	static faceRecognition
	static viewTracking
	static simulatorController
	static tactileFeedback
	static motionFeedback
	static trayTip
	static trayTipDuration
	static trayTipSimulation
	static trayTipSimulationDuration
	static buttonBox
	static buttonBoxDuration
	static buttonBoxSimulation
	static buttonBoxSimulationDuration
	static buttonBoxPosition
	static lastPositions
	
	static startup
	static startOption
	
	static splashTheme
	
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

restart:
	if (settingsOrCommand == kSave) {
		Gui CE:Submit
		
		newSettings := newConfiguration()
		
		for index, coreDescriptor in coreSettings {
			if (index > 1) {
				coreVariable := "coreVariable" . index
			
				setConfigurationValue(newSettings, "Core", coreDescriptor[1], %coreVariable%)
			}
		}
		
		for index, feedbackDescriptor in feedbackSettings {
			feedbackVariable := "feedbackVariable" . index
			
			setConfigurationValue(newSettings, "Feedback", feedbackDescriptor[1], %feedbackVariable%)
		}
		
		setConfigurationValue(newSettings, "Tray Tip", "Tray Tip Duration", (trayTip ? trayTipDuration : false))
		setConfigurationValue(newSettings, "Tray Tip", "Tray Tip Simulation Duration", (trayTipSimulation ? trayTipSimulationDuration : false))
		setConfigurationValue(newSettings, "Button Box", "Button Box Duration", (buttonBox ? buttonBoxDuration : false))
		setConfigurationValue(newSettings, "Button Box", "Button Box Simulation Duration", (buttonBoxSimulation ? buttonBoxSimulationDuration : false))
		
		positions := ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Secondary Screen", "Last Position"]
		
		setConfigurationValue(newSettings, "Button Box", "Button Box Position", positions[inList(map(positions, "translate"), buttonBoxPosition)])
		
		for descriptor, value in lastPositions
			setConfigurationValue(newSettings, "Button Box", descriptor, value)
		
		setConfigurationValue(newSettings, "Startup", "Splash Theme", (splashTheme == translate("None")) ? false : splashTheme)
		setConfigurationValue(newSettings, "Startup", "Simulator", (startup ? startOption : false))
		
		Gui CE:Destroy
		
		result := settingsOrCommand
	}
	else if (settingsOrCommand == kContinue) {
		Gui CE:Destroy
		
		result := settingsOrCommand
	}
	else if (settingsOrCommand == kCancel) {
		Gui CE:Destroy
		
		result := settingsOrCommand
	}
	else {
		result := false
		
		Gui CE:-Border ; -Caption
		Gui CE:Color, D0D0D0
	
		Gui CE:Font, Bold, Arial
	
		Gui CE:Add, Text, w220 Center gmoveEditor, % translate("Modular Simulator Controller System") 
		
		Gui CE:Font, Norm, Arial
		Gui CE:Font, Italic, Arial
	
		Gui CE:Add, Text, YP+20 w220 Center, % translate("Startup Settings")
	
		coreSettings := [["Simulator Controller", true, false]]
		feedbackSettings := []		
		
		for descriptor, applicationName in getConfigurationSectionValues(kSimulatorConfiguration, "Applications", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			enabled := (getConfigurationValue(kSimulatorConfiguration, applicationName, "Exe Path", "") != "")
			
			if (descriptor[1] == "Core")
				coreSettings.Push(Array(applicationName, getConfigurationValue(settingsOrCommand, "Core", applicationName, true), enabled))
			else if (descriptor[1] == "Feedback")
				feedbackSettings.Push(Array(applicationName, getConfigurationValue(settingsOrCommand, "Feedback", applicationName, true), enabled))
		}
		
		if (coreSettings.Length() > 8)
			Throw "Too many Core Components detected in editSettings..."
		
		if (feedbackSettings.Length() > 8)
			Throw "Too many Feedback Components detected in editSettings..."
			
		coreHeight := 20 + (coreSettings.Length() * 20)
		
		Gui CE:Font, Norm, Arial
		Gui CE:Font, Italic, Arial
	
		Gui CE:Add, GroupBox, YP+30 w220 h%coreHeight%, % translate("Core System")
	
		Gui CE:Font, Norm, Arial
	
		for index, coreDescriptor in coreSettings {
			coreOption := coreDescriptor[3] ? "" : "Disabled"
			coreLabel := coreDescriptor[1]
			checked := coreDescriptor[2]
			
			if (index == 1)
				coreOption := coreOption . " YP+20 XP+10"
				
			Gui CE:Add, CheckBox, %coreOption% Checked%checked% vcoreVariable%index%, %coreLabel%
		}
	
		if (feedbackSettings.Length() > 0) {
			feedbackHeight := 20 + (feedbackSettings.Length() * 20)
		
			Gui CE:Font, Norm, Arial
			Gui CE:Font, Italic, Arial
	
			Gui CE:Add, GroupBox, XP-10 YP+30 w220 h%feedbackHeight%, % translate("Feedback System")
	
			Gui CE:Font, Norm, Arial
	
			for index, feedbackDescriptor in feedbackSettings {
				feedbackOption := feedbackDescriptor[3] ? "" : "Disabled"
				feedbackLabel := feedbackDescriptor[1]
				checked := feedbackDescriptor[2]
				
				if (index == 1)
					feedbackOption := feedbackOption . " YP+20 XP+10"
					
				Gui CE:Add, CheckBox, %feedbackOption% Checked%checked% vfeedbackVariable%index%, %feedbackLabel%
			}
		}
	
		trayTipDuration := getConfigurationValue(settingsOrCommand, "Tray Tip", "Tray Tip Duration", false)
		trayTipSimulationDuration := getConfigurationValue(settingsOrCommand, "Tray Tip", "Tray Tip Simulation Duration", 1500)
		buttonBoxDuration := getConfigurationValue(settingsOrCommand, "Button Box", "Button Box Duration", 10000)
		buttonBoxSimulationDuration := getConfigurationValue(settingsOrCommand, "Button Box", "Button Box Simulation Duration", false)
		buttonBoxPosition := getConfigurationValue(settingsOrCommand, "Button Box", "Button Box Position", "Bottom Right")
		
		lastPositions := {}
		
		for descriptor, value in getConfigurationSectionValues(settingsOrCommand, "Button Box", Object())
			if InStr(descriptor, ".Position.")
				lastPositions[descriptor] := value
			
		trayTip := (trayTipDuration != 0) ? true : false
		trayTipSimulation := (trayTipSimulationDuration != 0) ? true : false
		buttonBox := (buttonBoxDuration != 0) ? true : false
		buttonBoxSimulation := (buttonBoxSimulationDuration != 0) ? true : false
		
		trayTipEnabled := trayTip
		trayTipSimulationEnabled := trayTipSimulation
		buttonBoxEnabled := buttonBox
		buttonBoxSimulationEnabled := buttonBoxSimulation
		
		Gui CE:Font, Norm, Arial
		Gui CE:Font, Italic, Arial
	
		Gui CE:Add, GroupBox, XP-10 YP+30 w220 h135, % translate("Controller Notifications")
	
		Gui CE:Font, Norm, Arial
	
		Gui CE:Add, CheckBox, YP+20 XP+10 Checked%trayTip% vtrayTip gcheckTrayTipDuration, % translate("Tray Tips")
		disabled := !trayTip ? "Disabled" : ""
		Gui CE:Add, Edit, X160 YP-5 w40 h20 Limit5 Number %disabled% vtrayTipDuration HwndtrayTipDurationInput, %trayTipDuration%
		Gui CE:Add, Text, X205 YP+5, % translate("ms")
		Gui CE:Add, CheckBox, X20 YP+20 Checked%trayTipSimulation% vtrayTipSimulation gcheckTrayTipSimulationDuration, % translate("Tray Tips (Simulation)")
		disabled := !trayTipSimulation ? "Disabled" : ""
		Gui CE:Add, Edit, X160 YP-5 w40 h20 Limit5 Number %disabled% vtrayTipSimulationDuration HwndtrayTipSimulationDurationInput, %trayTipSimulationDuration%
		Gui CE:Add, Text, X205 YP+5, % translate("ms")
		Gui CE:Add, CheckBox, X20 YP+20 Checked%buttonBox% vbuttonBox gcheckButtonBoxDuration, % translate("Button Box")
		disabled := !buttonBox ? "Disabled" : ""
		Gui CE:Add, Edit, X160 YP-5 w40 h20 Limit5 Number %disabled% vbuttonBoxDuration HwndbuttonBoxDurationInput, %buttonBoxDuration%
		Gui CE:Add, Text, X205 YP+5, % translate("ms")
		Gui CE:Add, CheckBox, X20 YP+20 Checked%buttonBoxSimulation% vbuttonBoxSimulation gcheckButtonBoxSimulationDuration, % translate("Button Box (Simulation)")
		disabled := !buttonBoxSimulation ? "Disabled" : ""
		Gui CE:Add, Edit, X160 YP-5 w40 h20 Limit5 Number %disabled% vbuttonBoxSimulationDuration HwndbuttonBoxSimulationDurationInput, %buttonBoxSimulationDuration%
		Gui CE:Add, Text, X205 YP+5, % translate("ms")
		Gui CE:Add, Text, X20 YP+30, % translate("Button Box Position")
		
		choices := ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Secondary Screen", "Last Position"]
		chosen := inList(choices, buttonBoxPosition)
		
		if !chosen
			chosen := 4
		
		Gui CE:Add, DropDownList, X120 YP-5 w100 Choose%chosen% vbuttonBoxPosition, % values2String("|", map(choices, "translate")*)
		
		splashTheme := getConfigurationValue(settingsOrCommand, "Startup", "Splash Theme", false)	
	 
		themes := getAllThemes()
		chosen := (splashTheme ? inList(themes, splashTheme) + 1 : 1)
		themes := translate("None") "|" + values2String("|", themes*)
		
		Gui CE:Add, Text, X10 Y+20, % translate("Theme")
		Gui CE:Add, DropDownList, X90 YP-5 w140 Choose%chosen% vsplashTheme, %themes%
	
		startupOption := getConfigurationValue(settingsOrCommand, "Startup", "Simulator", false)
		startup := (startupOption != false)
		
		Gui CE:Add, CheckBox, X10 Checked%startup% vstartup, % translate("Start")
		
		simulators := string2Values("|", getConfigurationValue(kSimulatorConfiguration, "Configuration", "Simulators", ""))
		
		chosen := inList(simulators, startupOption)
		
		if ((chosen == 0) && (simulators.Length() > 0))
			chosen := 1
		
		Gui CE:Add, DropDownList, X90 YP-5 w140 Choose%chosen% vstartOption, % values2String("|", simulators*)
	 
		Gui CE:Add, Button, X10 Y+20 w220 gstartConfiguration, % translate("Configuration...")
		
		margin := (withContinue ? "Y+20" : "")
		
		Gui CE:Add, Button, Default X10 %margin% w100 gsaveSettings, % translate("Save")
		Gui CE:Add, Button, X+20 w100 gcancelSettings, % translate("&Cancel")
		
		if withContinue
			Gui CE:Add, Button, X10 w220 gcontinueSettings, % translate("Co&ntinue w/o Save")
	
		Gui CE:Margin, 10, 10
		Gui CE:Show, AutoSize Center
		
		if (readConfiguration(kSimulatorConfigurationFile).Count() == 0)
			startConfiguration()
			
		Loop {
			Sleep 1000
		} until (result || vRestart)
		
		if vRestart {
			vRestart := false
			
			Gui CE:Destroy
			
			loadSimulatorConfiguration()
			
			Goto restart
		}
		
		if (result == kSave)
			settingsOrCommand := newSettings
		
		return result
	}
}
