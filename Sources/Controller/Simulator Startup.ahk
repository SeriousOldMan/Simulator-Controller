;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Startup Sequence                ;;;
;;;     1. Voice Recognition 	- Voice Command Recognition (VoiceMacro)    ;;;
;;;     2. Face Recogition      - Headtracking Neural Network (AITrack)     ;;;
;;;     3. View Tracking        - Viewtracking Interface Manager (opentrack);;;
;;;     4. Simulator Controller - Simulator Controller & Automation         ;;;
;;;     5. Tactile Feedback     - Tactile Feedback System (SimHub)          ;;;
;;;     6. Motion Feedback      - Motion Feedback System (SimFeedback)      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Startup.ico
;@Ahk2Exe-ExeName Simulator Startup.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Libraries Include Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Configuration\Libraries\SettingsEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kClose = "Close"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vSimulatorControllerPID := 0

global vStartupStayOpen := false

global vStartupManager := false


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SimulatorStartup extends ConfigurationItem {
	iCoreComponents := []
	iFeedbackComponents := []
	iSettings := false
	iSimulators := false
	iSplashTheme := false
	iStartupOption := false
	iSimulatorControllerPID := 0

	iFinished := false
	iCanceled := false


	Settings[] {
		Get {
			return this.iSettings
		}
	}

	Finished[] {
		Get {
			return this.iFinished
		}
	}

	Canceled[] {
		Get {
			return this.iCanceled
		}
	}

	__New(configuration, settings) {
		this.iSettings := settings

		base.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)

		this.iSimulators := string2Values("|", getConfigurationValue(configuration, "Configuration", "Simulators", ""))
		this.iSplashTheme := getConfigurationValue(this.Settings, "Startup", "Splash Theme", false)
		this.iStartupOption := getConfigurationValue(this.Settings, "Startup", "Simulator", false)

		this.iCoreComponents := []
		this.iFeedbackComponents := []

		for descriptor, applicationName in getConfigurationSectionValues(configuration, "Applications", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)

			if (descriptor[1] == "Core")
				this.iCoreComponents.Push(applicationName)
			else if (descriptor[1] == "Feedback")
				this.iFeedbackComponents.Push(applicationName)
		}
	}

	prepareConfiguration() {
		noConfiguration := (this.Configuration.Count() == 0)
		editConfig := GetKeyState("Ctrl")

		settings := this.Settings

		if (settings.Count() = 0)
			editConfig := true

		if (editConfig || noConfiguration) {
			result := editSettings(settings, true)

			if (result == kCancel)
				exitStartup(true)
			else if (noConfiguration && (readConfiguration(kSimulatorConfigurationFile).Count() == 0)) {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				error := translate("Error")
				MsgBox 262160, %error%, % translate("Cannot initiate startup sequence, please check the configuration...")
				OnMessage(0x44, "")

				exitStartup(true)
			}
			else if (result == kSave) {
				writeConfiguration(kSimulatorSettingsFile, settings)

				this.iSettings := settings
			}
		}

		this.loadFromConfiguration(this.Configuration)
	}

	startSimulatorController() {
		local title

		try {
			logMessage(kLogInfo, translate("Starting ") . translate("Simulator Controller"))

			exePath := kBinariesDirectory . "Voice Server.exe"

			Run %exePath%, %kBinariesDirectory%, , processID

			exePath := kBinariesDirectory . "Simulator Controller.exe -Startup -Voice " . processID

			Run %exePath%, %kBinariesDirectory%, , processID

			Sleep 1000

			return processID
		}
		catch exception {
			logMessage(kLogCritical, translate("Cannot start Simulator Controller (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

			showMessage(substituteVariables(translate("Cannot start Simulator Controller (%kBinariesDirectory%Simulator Controller.exe) - please rebuild the applications..."))
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			return 0
		}
	}

	startComponent(component) {
		logMessage(kLogInfo, translate("Starting component ") . component)

		raiseEvent(kFileMessage, "Startup", "startupComponent:" . component, vSimulatorControllerPID)
	}

	startComponents(section, components, ByRef startSimulator, ByRef runningIndex) {
		for ignore, component in components {
			if this.Canceled
				break

			startSimulator := (startSimulator || (GetKeyState("Ctrl") || GetKeyState("MButton")))

			if getConfigurationValue(this.Settings, section, component, false) {
				if !kSilentMode
					showProgress({message: translate("Start: ") . component . translate("...")})

				logMessage(kLogInfo, translate("Component ") . component . translate(" is activated"))

				this.startComponent(component)

				Sleep 2000
			}
			else
				logMessage(kLogInfo, translate("Component ") . component . translate(" is deactivated"))

			if !kSilentMode
				showProgress({progress: Round((runningIndex++ / (this.iCoreComponents.Length() + this.iFeedbackComponents.Length())) * 90)})
		}
	}

	startSimulator() {
		if this.Canceled
			return

		if (!this.iStartupOption && (this.iSimulators.Length() > 0))
			this.iStartupOption := this.iSimulators[1]

		if this.iStartupOption
			raiseEvent(kFileMessage, "Startup", "startupSimulator:" . this.iStartupOption, vSimulatorControllerPID)
	}

	startup() {
		this.prepareConfiguration()

		startSimulator := ((this.iStartupOption != false) || GetKeyState("Ctrl") || GetKeyState("MButton"))

		this.iSimulatorControllerPID := this.startSimulatorController()
		vSimulatorControllerPID := this.iSimulatorControllerPID

		if (this.iSimulatorControllerPID == 0)
			exitStartup(true)

		if (!kSilentMode && this.iSplashTheme)
			showSplashTheme(this.iSplashTheme, "playSong")

		x := Round((A_ScreenWidth - 300) / 2)
		y := A_ScreenHeight - 150

		if !kSilentMode {
			message := translate("Start: Simulator Controller")

			showProgress({x: x, y: y, color: "Blue", message: message, title: translate("Initialize Core System")})
		}

		Loop 50 {
			if !kSilentMode
				showProgress({progress: A_Index * 2})

			Sleep 20
		}

		if !kSilentMode {
			message := translate("...")

			showProgress({progress: 0, color: "Green", message: message, title: translate("Starting System Components")})
		}

		runningIndex := 1

		this.startComponents("Core", this.iCoreComponents, startSimulator, runningIndex)
		this.startComponents("Feedback", this.iFeedbackComponents, startSimulator, runningIndex)

		if !kSilentMode
			showProgress({progress: 100, message: translate("Done")})

		Sleep 500

		this.iFinished := true
		hidden := false

		hasSplashTheme := this.iSplashTheme

		if (startSimulator || (GetKeyState("Ctrl") || GetKeyState("MButton"))) {
			if (!kSilentMode && hasSplashTheme) {
				this.hideSplashTheme()

				hidden := true
			}

			this.startSimulator()
		}

		if !kSilentMode
			hideProgress()

		if (kSilentMode || this.Canceled) {
			if (!hidden && !kSilentMode && hasSplashTheme)
				this.hideSplashTheme()

			exitStartup(true)
		}
		else {
			if !hasSplashTheme
				exitStartup(true)
		}
	}

	hideSplashTheme() {
		if this.iSplashTheme {
			this.iSplashTheme := false

			hideSplashTheme()
		}
	}

	cancelStartup() {
		this.iCanceled := true

		this.hideSplashTheme()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

setButtonIcon(buttonHandle, file, index := 1, options := "") {
;   Parameters:
;   1) {Handle} 	HWND handle of Gui button
;   2) {File} 		File containing icon image
;   3) {Index} 		Index of icon in file
;						Optional: Default = 1
;   4) {Options}	Single letter flag followed by a number with multiple options delimited by a space
;						W = Width of Icon (default = 16)
;						H = Height of Icon (default = 16)
;						S = Size of Icon, Makes Width and Height both equal to Size
;						L = Left Margin
;						T = Top Margin
;						R = Right Margin
;						B = Botton Margin
;						A = Alignment (0 = left, 1 = right, 2 = top, 3 = bottom, 4 = center; default = 4)

	RegExMatch(options, "i)w\K\d+", W), (W="") ? W := 16 :
	RegExMatch(options, "i)h\K\d+", H), (H="") ? H := 16 :
	RegExMatch(options, "i)s\K\d+", S), S ? W := H := S :
	RegExMatch(options, "i)l\K\d+", L), (L="") ? L := 0 :
	RegExMatch(options, "i)t\K\d+", T), (T="") ? T := 0 :
	RegExMatch(options, "i)r\K\d+", R), (R="") ? R := 0 :
	RegExMatch(options, "i)b\K\d+", B), (B="") ? B := 0 :
	RegExMatch(options, "i)a\K\d+", A), (A="") ? A := 4 :

	ptrSize := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"

	VarSetCapacity(button_il, 20 + ptrSize, 0)

	NumPut(normal_il := DllCall("ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1), button_il, 0, Ptr)	; Width & Height
	NumPut(L, button_il, 0 + ptrSize, DW)		; Left Margin
	NumPut(T, button_il, 4 + ptrSize, DW)		; Top Margin
	NumPut(R, button_il, 8 + ptrSize, DW)		; Right Margin
	NumPut(B, button_il, 12 + ptrSize, DW)		; Bottom Margin
	NumPut(A, button_il, 16 + ptrSize, DW)		; Alignment

	SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %buttonHandle%

	return IL_Add(normal_il, file, index)
}

launchPad(command := false, arguments*) {
	local application

	static result := false

	static toolTips
	static executables

	static Startup
	static RaceReports
	static StrategyWorkbench
	static RaceCenter
	static ServerAdministration
	static SimulatorSetup
	static SimulatorConfiguration
	static SimulatorDownload
	static SimulatorSettings
	static RaceSettings
	static SessionDatabase
	static SetupAdvisor

	static closeCheckBox

	if (command = kClose)
		result := kClose
	else if (command = "ToolTip") {
		if toolTips.HasKey(arguments[1])
			return translate(toolTips[arguments[1]])
		else
			return false
	}
	else if (command = "Executable") {
		if executables.HasKey(arguments[1])
			return executables[arguments[1]]
		else
			return false
	}
	else if (command = "CloseOnStartup") {
		startupConfig := readConfiguration(kUserConfigDirectory . "Simulator Startup.ini")

		GuiControlGet closeCheckBox

		setConfigurationValue(startupConfig, "Startup", "CloseLaunchPad", closeCheckBox)

		writeConfiguration(kUserConfigDirectory . "Simulator Startup.ini", startupConfig)
	}
	else if (command = "Launch") {
		application := arguments[1]

		Run %kBinariesDirectory%%application%

		if arguments[2]
			ExitApp 0
	}
	else if (command = "Startup") {
		GuiControlGet closeCheckBox

		vStartupStayOpen := !closeCheckBox

		startupSimulator()

		if !vStartupStayOpen
			launchPad(kClose)
	}
	else {
		result := false
		toolTips := {}
		executables := {}

		toolTips["Startup"] := "Startup: Launches all components to be ready for the track."

		toolTips["RaceReports"] := "Race Reports: Analyze your recent races."
		toolTips["StrategyWorkbench"] := "Strategy Workbench: Find the best stratetgy for an upcoming race."
		toolTips["RaceCenter"] := "Race Center: Manage your team and control the race during an event using the Team Server."
		toolTips["ServerAdministration"] := "Server Administration: Manage accounts and access rights on your Team Server. Only needed, when you run your own Team Server."

		toolTips["SimulatorSetup"] := "Setup & Configuration: Describe and generate the configuration of Simulator Controller using a simple point and click wizard. Suitable for beginners."
		toolTips["SimulatorConfiguration"] := "Configuration: Directly edit the configuration of Simulator Controller. Requires profund knowledge of the internals of the various plugins."
		toolTips["SimulatorDownload"] := "Update: Downloads and installs the latest version of Simulator Controller. Not needed, unless you disabled automatic updates during the initial installation."
		toolTips["SimulatorSettings"] := "Settings: Change the behaviour of Simulator Controller during startup and in a running simulation."
		toolTips["RaceSettings"] := "Race Settings: Manage the settings for the Virtual Race Assistants and also the connection to the Team Server for team races."
		toolTips["SessionDatabase"] := "Session Database: Manage simulator, car and track specific settings and gives access to various areas of the data collected by Simulator Controller during the sessions."
		toolTips["SetupAdvisor"] := "Setup Advisor: Develop car setups using an interview-based approach, where you describe your handling problems."

		executables["RaceReports"] := "Race Reports.exe"
		executables["StrategyWorkbench"] := "Strategy Workbench.exe"
		executables["RaceCenter"] := "Race Center.exe"
		executables["ServerAdministration"] := "Server Administration.exe"
		executables["SimulatorSetup"] := "Simulator Setup.exe"
		executables["SimulatorConfiguration"] := "Simulator Configuration.exe"
		executables["SimulatorDownload"] := "Simulator Download.exe"
		executables["SimulatorSettings"] := "Simulator Settings.exe"
		executables["RaceSettings"] := "Race Settings.exe"
		executables["SessionDatabase"] := "Session Database.exe"
		executables["SetupAdvisor"] := "Setup Advisor.exe"

		Gui LP:Default

		Gui LP:-Border ; -Caption
		Gui LP:Color, D0D0D0, D8D8D8

		Gui LP:Font, s10 Bold, Arial

		Gui LP:Add, Text, w580 Center gmoveLaunchPad, % translate("Modular Simulator Controller System")

		Gui LP:Font, s9 Norm, Arial
		Gui LP:Font, Italic Underline, Arial

		Gui LP:Add, Text, x258 YP+20 w90 cBlue Center gopenLaunchPadDocumentation, % translate("Applications")

		Gui LP:Font, s8 Norm, Arial

		Gui LP:Add, Text, x8 yp+30 w590 0x10

		Gui LP:Add, Picture, x16 yp+24 w60 h60 Section vStartup glaunchStartup, % kIconsDirectory . "Startup.ico"

		Gui LP:Add, Picture, xp+90 yp w60 h60 vRaceReports glaunchApplication, % kIconsDirectory . "Chart.ico"
		Gui LP:Add, Picture, xp+74 yp w60 h60 vStrategyWorkbench glaunchApplication, % kIconsDirectory . "Dashboard.ico"
		Gui LP:Add, Picture, xp+90 yp w60 h60 vRaceCenter glaunchApplication, % kIconsDirectory . "Console.ico"
		Gui LP:Add, Picture, xp+74 yp w60 h60 vServerAdministration glaunchApplication, % kIconsDirectory . "Server Administration.ico"

		Gui LP:Add, Picture, xp+106 yp w60 h60 vSimulatorSetup glaunchApplication, % kIconsDirectory . "Configuration Wand.ico"
		Gui LP:Add, Picture, xp+74 yp w60 h60 vSimulatorConfiguration glaunchApplication, % kIconsDirectory . "Configuration.ico"
		Gui LP:Add, Picture, xp yp+74 w60 h60 vSimulatorDownload glaunchSimulatorDownload, % kIconsDirectory . "Installer.ico"

		Gui LP:Add, Picture, x16 ys+74 w60 h60 vSimulatorSettings glaunchApplication, % kIconsDirectory . "Settings.ico"
		Gui LP:Add, Picture, xp+90 yp w60 h60 vRaceSettings glaunchApplication, % kIconsDirectory . "Race Settings.ico"
		Gui LP:Add, Picture, xp+74 yp w60 h60 vSessionDatabase glaunchApplication, % kIconsDirectory . "Session Database.ico"
		Gui LP:Add, Picture, xp+164 yp w60 h60 vSetupAdvisor glaunchApplication, % kIconsDirectory . "Setup.ico"

		Gui LP:Font, s8 Norm, Arial

		Gui LP:Add, Text, x8 yp+80 w590 0x10

		startupConfig := readConfiguration(kUserConfigDirectory . "Simulator Startup.ini")

		closeOnStartup := getConfigurationValue(startupConfig, "Startup", "CloseLaunchPad", false)

		Gui LP:Add, CheckBox, x16 yp+10 w250 h23 Checked%closeOnStartup% vcloseCheckBox gcloseOnStartup, % translate("Close on Startup")
		Gui LP:Add, Button, x267 yp w80 h23 Default GcloseLaunchPad, % translate("Close")

		OnMessage(0x0200, "WM_MOUSEMOVE")

		Gui LP:Show

		Loop
			Sleep 100
		Until result

		Gui LP:Destroy

		return ((result = kClose) ? false : true)
	}
}

closeLaunchPad() {
	launchPad(kClose)
}

moveLaunchPad() {
	moveByMouse("LP")
}

closeOnStartup() {
	launchPad("CloseOnStartup")
}

launchStartup() {
	launchPad("Startup")
}

launchApplication() {
	executable := launchPad("Executable", A_GuiControl)

	if executable
		launchPad("Launch", executable)
}

launchSimulatorDownload() {
	title := translate("Update")

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
	MsgBox 262436, %title%, % translate("Do you really want to download and install the latest version? You must close all applications before running the update.")
	OnMessage(0x44, "")

	IfMsgBox Yes
		launchPad("Launch", "Simulator Download.exe", true)
}

openLaunchPadDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller
}

WM_MOUSEMOVE()
{
    static CurrControl
	static PrevControl := false

	CurrControl := A_GuiControl

	if ((CurrControl != PrevControl) && !InStr(CurrControl, " "))
    {
        ToolTip  ; Turn off any previous tooltip.

		SetTimer RemoveToolTip, Off
        SetTimer DisplayToolTip, 1000

        PrevControl := CurrControl
    }

	return

    DisplayToolTip:
		SetTimer DisplayToolTip, Off

		text := launchPad("ToolTip", CurrControl)

		if text {
			ToolTip %text%  ; The leading percent sign tell it to use an expression.

			SetTimer RemoveToolTip, 10000
		}

		return

    RemoveToolTip:
		SetTimer RemoveToolTip, Off

		ToolTip

		return
}


watchStartupSemaphore() {
	if (!vStartupStayOpen && !FileExist(kTempDirectory . "Startup.semaphore"))
		exitStartup()
}

startupSimulator() {
	Hotkey Escape, On

	vStartupManager := new SimulatorStartup(kSimulatorConfiguration, readConfiguration(kSimulatorSettingsFile))

	vStartupManager.startup()

	; Looks like we have recurring deadlock situations with bidirectional pipes in case of process exit situations...
	;
	; registerEventHandler("Startup", "functionEventHandler")
	;
	; Using a sempahore file instead...

	fileName := (kTempDirectory . "Startup.semaphore")

	if !FileExist(fileName)
		FileAppend Startup, %fileName%

	SetTimer watchStartupSemaphore, 2000
}

startSimulator() {
	icon := kIconsDirectory . "Startup.ico"

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Simulator Startup

	Menu Tray, NoStandard
	Menu Tray, Add, Exit, Exit

	noLaunch := inList(A_Args, "-NoLaunchPad")

	if ((noLaunch && !GetKeyState("Shift")) || (!noLaunch && GetKeyState("Shift")))
		startupSimulator()
	else
		launchPad()

	if (!vStartupManager || vStartupManager.Finished)
		ExitApp 0

	return

Exit:
	ExitApp 0
}

playSong(songFile) {
	if (songFile && FileExist(getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)))
		raiseEvent(kFileMessage, "Startup", "playStartupSong:" . songFile, vSimulatorControllerPID)
}


;;;-------------------------------------------------------------------------;;;
;;;                          Event Handler Section                          ;;;
;;;-------------------------------------------------------------------------;;;

exitStartup(sayGoodBye := false) {
	if (sayGoodBye && (vSimulatorControllerPID != false)) {
		raiseEvent(kFileMessage, "Startup", "startupExited", vSimulatorControllerPID)

		SetTimer exitStartup, -2000
	}
	else {
		Hotkey Escape, Off

		if vStartupManager
			vStartupManager.cancelStartup()

		fileName := (kTempDirectory . "Startup.semaphore")

		try {
			FileDelete %fileName%
		}
		catch exception {
			; ignore
		}

		if !vStartupStayOpen
			ExitApp 0
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

Hotkey Escape, Off

startSimulator()


;;;-------------------------------------------------------------------------;;;
;;;                         Hotkey & Label Section                          ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Escape::                   Cancel Startup                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
Escape::
protectionOn()

try {
	if vStartupManager
		if !vStartupManager.Finished {
			SoundPlay *32
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))

			title := translate("Startup")

			MsgBox 262180, %title%, % translate("Cancel Startup?")
			OnMessage(0x44, "")

			IfMsgBox Yes
			{
				if (vSimulatorControllerPID != 0)
					raiseEvent(kFileMessage, "Startup", "stopStartupSong", vSimulatorControllerPID)

				vStartupManager.cancelStartup()
			}
		}
		else {
			if (vSimulatorControllerPID != 0)
				raiseEvent(kFileMessage, "Startup", "stopStartupSong", vSimulatorControllerPID)

			vStartupManager.hideSplashTheme()

			exitStartup(true)
		}
}
finally {
	protectionOff()
}

return
