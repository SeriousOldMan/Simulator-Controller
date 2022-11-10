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

;@SC-IF %configuration% == Development
#Include ..\Includes\Development.ahk
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Includes\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Startup.ico
;@Ahk2Exe-ExeName Simulator Startup.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Libraries\Messages.ahk
#Include ..\Configuration\Libraries\SettingsEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kClose := "Close"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SimulatorStartup extends ConfigurationItem {
	static sStayOpen := false

	iCoreComponents := []
	iFeedbackComponents := []
	iSettings := false
	iSimulators := false
	iSplashTheme := false
	iStartupOption := false

	iFinished := false
	iCanceled := false

	iControllerPID := false

	StayOpen[] {
		Get {
			return SimulatorStartup.sStayOpen
		}

		Set {
			return (SimulatorStartup.sStayOpen := value)
		}
	}

	Settings[] {
		Get {
			return this.iSettings
		}

		Set {
			return (this.iSettings := value)
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

	ControllerPID[] {
		Get {
			return this.iControllerPID
		}
	}

	__New(configuration, settings) {
		this.Settings := settings

		base.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		local descriptor, applicationName

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
		local noConfiguration := (this.Configuration.Count() == 0)
		local editConfig := GetKeyState("Ctrl")
		local settings := this.Settings
		local result, error

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

				this.Settings := settings
			}
		}

		this.loadFromConfiguration(this.Configuration)
	}

	startSimulatorController() {
		local title, exePath, pid

		try {
			logMessage(kLogInfo, translate("Starting ") . translate("Simulator Controller"))

			if getConfigurationValue(this.Settings, "Core", "System Monitor", false) {
				Process Exist, System Monitor.exe

				if !ErrorLevel {
					exePath := kBinariesDirectory . "System Monitor.exe"

					Run %exePath%, %kBinariesDirectory%

					Sleep 1000
				}
			}

			exePath := kBinariesDirectory . "Voice Server.exe"

			Run %exePath%, %kBinariesDirectory%, , pid

			exePath := kBinariesDirectory . "Simulator Controller.exe -Startup -Voice " . pid

			Run %exePath%, %kBinariesDirectory%, , pid

			Sleep 1000

			return pid
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

		sendMessage(kFileMessage, "Startup", "startupComponent:" . component, this.ControllerPID)
	}

	startComponents(section, components, ByRef startSimulator, ByRef runningIndex) {
		local ignore, component

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
			sendMessage(kFileMessage, "Startup", "startupSimulator:" . this.iStartupOption, this.ControllerPID)
	}

	startup() {
		local startSimulator, runningIndex, hidden, hasSplashTheme

		this.prepareConfiguration()

		startSimulator := ((this.iStartupOption != false) || GetKeyState("Ctrl") || GetKeyState("MButton"))

		this.iControllerPID := this.startSimulatorController()

		if (this.ControllerPID == 0)
			exitStartup(true)

		if (!kSilentMode && this.iSplashTheme)
			showSplashTheme(this.iSplashTheme, "playSong")

		if !kSilentMode
			showProgress({color: "Blue"
						, message: translate("Start: Simulator Controller")
						, title: translate("Initialize Core System")})

		loop 50 {
			if !kSilentMode
				showProgress({progress: A_Index * 2})

			Sleep 20
		}

		if !kSilentMode
			showProgress({progress: 0, color: "Green"
					   , message: translate("..."), title: translate("Starting System Components")})

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

closeApplication(application) {
	Process Exist, %application%.exe

	if ErrorLevel
		Process Close, %ErrorLevel%
}

launchPad(command := false, arguments*) {
	local ignore, application, startupConfig, closeOnStartup, x, y

	static result := false

	static toolTips
	static executables
	static icons

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
	static SystemMonitor

	static closeCheckBox

	if (command = kClose) {
		if (arguments.HasKey(1) && arguments[1])
			launchPad("Close All")

		result := kClose
	}
	else if (command = "Close All") {
		broadcastMessage(concatenate(kBackgroundApps, remove(kForegroundApps, "Simulator Startup")), "exitApplication")

		Sleep 2000

		if (arguments.HasKey(1) && arguments[1])
			launchPad(kClose)
	}
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
		startupConfig := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

		GuiControlGet closeCheckBox

		setConfigurationValue(startupConfig, "Simulator Startup", "CloseLaunchPad", closeCheckBox)

		writeConfiguration(kUserConfigDirectory . "Application Settings.ini", startupConfig)
	}
	else if (command = "Launch") {
		application := arguments[1]

		Run %kBinariesDirectory%%application%

		if arguments[2]
		 	ExitApp 0
	}
	else if (command = "Startup") {
		GuiControlGet closeCheckBox

		SimulatorStartup.StayOpen := !closeCheckBox

		startupSimulator()

		if !SimulatorStartup.StayOpen
			launchPad(kClose)
	}
	else {
		result := false
		toolTips := {}
		executables := {}
		icons := {}

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
		toolTips["SystemMonitor"] := "System Monitor: Monitor all system activities on a dashboard and investigate log files of all system components."

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
		executables["SystemMonitor"] := "System Monitor.exe"

		icons["Startup"] := kIconsDirectory . "Startup.ico"
		icons["RaceReports"] := kIconsDirectory . "Chart.ico"
		icons["StrategyWorkbench"] := kIconsDirectory . "Dashboard.ico"
		icons["RaceCenter"] := kIconsDirectory . "Console.ico"
		icons["ServerAdministration"] := kIconsDirectory . "Server Administration.ico"
		icons["SimulatorSetup"] := kIconsDirectory . "Configuration Wand.ico"
		icons["SimulatorConfiguration"] := kIconsDirectory . "Configuration.ico"
		icons["SimulatorDownload"] := kIconsDirectory . "Installer.ico"
		icons["SimulatorSettings"] := kIconsDirectory . "Settings.ico"
		icons["RaceSettings"] := kIconsDirectory . "Race Settings.ico"
		icons["SessionDatabase"] := kIconsDirectory . "Session Database.ico"
		icons["SetupAdvisor"] := kIconsDirectory . "Setup.ico"
		icons["SystemMonitor"] := kIconsDirectory . "Monitoring.ico"

		Gui LP:Default

		Gui LP:-Border ; -Caption
		Gui LP:Color, D0D0D0, D8D8D8

		Gui LP:Font, s10 Bold, Arial

		Gui LP:Add, Text, w580 Center gmoveLaunchPad, % translate("Modular Simulator Controller System")

		Gui LP:Font, s8 Norm, Arial

		Gui LP:Add, Text, x560 YP w30, % string2Values("-", kVersion)[1]

		Gui LP:Font, s9 Norm, Arial
		Gui LP:Font, Italic Underline, Arial

		Gui LP:Add, Text, x233 YP+20 w140 cBlue Center gopenLaunchPadDocumentation, % translate("Applications")

		Gui LP:Font, s8 Norm, Arial

		Gui LP:Add, Button, x573 yp+4 w23 h23 HwndgeneralSettingsButtonHandle gmodifySettings
		setButtonIcon(generalSettingsButtonHandle, kIconsDirectory . "General Settings.ico", 1)

		Gui LP:Add, Text, x8 yp+26 w590 0x10

		Gui LP:Add, Picture, x16 yp+24 w60 h60 Section vStartup glaunchStartup, % kIconsDirectory . "Startup.ico"

		Gui LP:Add, Picture, xp+90 yp w60 h60 vRaceReports glaunchApplication, % kIconsDirectory . "Chart.ico"
		Gui LP:Add, Picture, xp+74 yp w60 h60 vStrategyWorkbench glaunchApplication, % kIconsDirectory . "Dashboard.ico"
		Gui LP:Add, Picture, xp+110 yp w60 h60 vRaceCenter glaunchApplication, % kIconsDirectory . "Console.ico"
		Gui LP:Add, Picture, xp+74 yp w60 h60 vServerAdministration glaunchApplication, % kIconsDirectory . "Server Administration.ico"

		Gui LP:Add, Picture, xp+150 yp w60 h60 vSystemMonitor glaunchApplication, % kIconsDirectory . "Monitoring.ico"

		; Gui LP:Add, Picture, x16 ys+74 w60 h60 vSimulatorSettings glaunchApplication, % kIconsDirectory . "Settings.ico"
		Gui LP:Add, Picture, x16 ys+74 w60 h60 vSetupAdvisor glaunchApplication, % kIconsDirectory . "Setup.ico"
		Gui LP:Add, Picture, xp+90 yp w60 h60 vRaceSettings glaunchApplication, % kIconsDirectory . "Race Settings.ico"
		Gui LP:Add, Picture, xp+74 yp w60 h60 vSessionDatabase glaunchApplication, % kIconsDirectory . "Session Database.ico"
		; Gui LP:Add, Picture, xp+164 yp w60 h60 vSetupAdvisor glaunchApplication, % kIconsDirectory . "Setup.ico"

		Gui LP:Add, Picture, xp+110 yp w60 h60 vSimulatorSetup glaunchApplication, % kIconsDirectory . "Configuration Wand.ico"
		Gui LP:Add, Picture, xp+74 yp w60 h60 vSimulatorConfiguration glaunchApplication, % kIconsDirectory . "Configuration.ico"
		Gui LP:Add, Picture, xp+150 yp w60 h60 vSimulatorDownload glaunchSimulatorDownload, % kIconsDirectory . "Installer.ico"

		Gui LP:Font, s8 Norm, Arial

		Gui LP:Add, Text, x8 yp+80 w590 0x10

		startupConfig := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

		closeOnStartup := getConfigurationValue(startupConfig, "Simulator Startup", "CloseLaunchPad", false)

		Gui LP:Add, CheckBox, x16 yp+10 w250 h23 Checked%closeOnStartup% vcloseCheckBox gcloseOnStartup, % translate("Close on Startup")
		Gui LP:Add, Button, x267 yp w80 h23 Default GcloseLaunchPad, % translate("Close")

		Gui LP:Add, Button, x482 yp w100 h23 GcloseAll, % translate("Close All...")

		OnMessage(0x0200, "WM_MOUSEMOVE")

		x := false
		y := false

		if getWindowPosition("Simulator Startup", x, y)
			Gui LP:Show, x%x% y%y%
		else
			Gui LP:Show

		loop
			Sleep 100
		until result

		Gui LP:Destroy

		return ((result = kClose) ? false : true)
	}
}

closeLaunchPad() {
	launchPad(kClose, GetKeyState("Ctrl", "P"))
}

closeAll() {
	local title := translate("Modular Simulator Controller System")

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
	MsgBox 262436, %title%, % translate("Do you really want to close all currently running applications? Unsaved data might be lost.")
	OnMessage(0x44, "")

	IfMsgBox Yes
		launchPad("Close All", GetKeyState("Ctrl", "P"))
}

moveLaunchPad() {
	moveByMouse("LP", "Simulator Startup")
}

closeOnStartup() {
	launchPad("CloseOnStartup")
}

launchStartup() {
	launchPad("Startup")
}

launchApplication() {
	local executable := launchPad("Executable", A_GuiControl)

	if executable
		launchPad("Launch", executable)
}

modifySettings() {
	local settings := readConfiguration(kSimulatorSettingsFile)

	Gui SE:+OwnerLP
	Gui LP:+Disabled

	try {
		if (editSettings(settings) == kSave)
			writeConfiguration(kSimulatorSettingsFile, settings)
	}
	finally {
		Gui LP:-Disabled
	}
}

launchSimulatorDownload() {
	local title := translate("Update")

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
	MsgBox 262436, %title%, % translate("Do you really want to download and install the latest version? You must close all applications before running the update.")
	OnMessage(0x44, "")

	IfMsgBox Yes
		launchPad("Launch", "Simulator Download.exe", true)
}

openLaunchPadDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller
}

WM_MOUSEMOVE() {
	local text

    static CurrControl
	static PrevControl := false

	CurrControl := A_GuiControl

	if ((CurrControl != PrevControl) && !InStr(CurrControl, " "))
    {
		ToolTip

		SetTimer RemoveToolTip, Off
        SetTimer DisplayToolTip, 1000

        PrevControl := CurrControl
    }

	return

    DisplayToolTip:
		SetTimer DisplayToolTip, Off

		text := launchPad("ToolTip", CurrControl)

		if text {
			ToolTip %text%

			SetTimer RemoveToolTip, 10000
		}

		return

    RemoveToolTip:
		SetTimer RemoveToolTip, Off

		ToolTip

		return
}

watchStartupSemaphore() {
	if !FileExist(kTempDirectory . "Startup.semaphore")
		if !SimulatorStartup.StayOpen
			exitStartup()
		else
			try {
				hideSplashTheme()
			}
			catch exception {
				logError(exception)
			}
}

clearStartupSemaphore() {
	deleteFile(kTempDirectory . "Startup.semaphore")

	return false
}

startupSimulator() {
	local fileName

	Hotkey Escape, On

	SimulatorStartup.Instance := new SimulatorStartup(kSimulatorConfiguration, readConfiguration(kSimulatorSettingsFile))

	SimulatorStartup.Instance.startup()

	; Looks like we have recurring deadlock situations with bidirectional pipes in case of process exit situations...
	;
	; registerMessageHandler("Startup", "functionMessageHandler")
	;
	; Using a sempahore file instead...

	fileName := (kTempDirectory . "Startup.semaphore")

	if !FileExist(fileName)
		FileAppend Startup, %fileName%

	OnExit("clearStartupSemaphore")

	new PeriodicTask("watchStartupSemaphore", 2000, kLowPriority).start()
}

startSimulator() {
	local icon := kIconsDirectory . "Startup.ico"
	local noLaunch

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Simulator Startup

	noLaunch := inList(A_Args, "-NoLaunchPad")

	if ((noLaunch && !GetKeyState("Shift")) || (!noLaunch && GetKeyState("Shift")))
		startupSimulator()
	else
		launchPad()

	if (!SimulatorStartup.Instance || SimulatorStartup.Instance.Finished)
		ExitApp 0

	return
}

playSong(songFile) {
	if (songFile && FileExist(getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)))
		sendMessage(kFileMessage, "Startup", "playStartupSong:" . songFile, SimulatorStartup.Instance.ControllerPID)
}

cancelStartup() {
	local startupManager := SimulatorStartup.Instance
	local title

	protectionOn()

	try {
		if startupManager {
			startupManager.hideSplashTheme()

			if !startupManager.Finished {
				SoundPlay *32
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
				title := translate("Startup")
				MsgBox 262180, %title%, % translate("Cancel Startup?")
				OnMessage(0x44, "")

				IfMsgBox Yes
				{
					if (startupManager.ControllerPID != 0)
						sendMessage(kFileMessage, "Startup", "stopStartupSong", startupManager.ControllerPID)

					startupManager.cancelStartup()
				}
			}
			else {
				if (startupManager.ControllerPID != 0)
					sendMessage(kFileMessage, "Startup", "stopStartupSong", startupManager.ControllerPID)

				startupManager.hideSplashTheme()

				exitStartup(true)
			}
		}
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

exitStartup(sayGoodBye := false) {
	if (sayGoodBye && (SimulatorStartup.Instance.ControllerPID != false)) {
		sendMessage(kFileMessage, "Startup", "startupExited", SimulatorStartup.Instance.ControllerPID)

		Task.startTask("exitStartup", 2000)
	}
	else {
		Hotkey Escape, Off

		if SimulatorStartup.Instance
			SimulatorStartup.Instance.cancelStartup()

		deleteFile(kTempDirectory . "Startup.semaphore")

		if !SimulatorStartup.StayOpen
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
cancelStartup()

return
