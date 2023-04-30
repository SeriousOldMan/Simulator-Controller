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
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Startup.ico
;@Ahk2Exe-ExeName Simulator Startup.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\Messages.ahk"
#Include "..\Configuration\Libraries\SettingsEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kClose := "Close"
global kRestart := "Restart"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class StartupWindow extends Window {
	__New() {
		super.__New({Descriptor: "Simulator Startup", Options: "+Caption +Border +SysMenu", Closeable: true})
	}

	Close(*) {
		closeLaunchPad()
	}
}

class SimulatorStartup extends ConfigurationItem {
	static Instance := false

	static sStayOpen := false

	iCoreComponents := []
	iFeedbackComponents := []
	iSettings := false
	iSimulators := false
	iSplashScreen := false
	iStartupOption := false

	iFinished := false
	iCanceled := false

	iControllerPID := false

	static StayOpen {
		Get {
			return SimulatorStartup.sStayOpen
		}

		Set {
			return (SimulatorStartup.sStayOpen := value)
		}
	}

	Settings {
		Get {
			return this.iSettings
		}

		Set {
			return (this.iSettings := value)
		}
	}

	Finished {
		Get {
			return this.iFinished
		}
	}

	Canceled {
		Get {
			return this.iCanceled
		}
	}

	ControllerPID {
		Get {
			return this.iControllerPID
		}
	}

	__New(configuration, settings) {
		this.Settings := settings

		super.__New(configuration)
	}

	loadFromConfiguration(configuration) {
		local descriptor, applicationName

		super.loadFromConfiguration(configuration)

		this.iSimulators := string2Values("|", getMultiMapValue(configuration, "Configuration", "Simulators", ""))
		this.iSplashScreen := getMultiMapValue(this.Settings, "Startup", "Splash Screen", false)
		this.iStartupOption := getMultiMapValue(this.Settings, "Startup", "Simulator", false)

		this.iCoreComponents := []
		this.iFeedbackComponents := []

		for descriptor, applicationName in getMultiMapValues(configuration, "Applications") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)

			if (descriptor[1] == "Core")
				this.iCoreComponents.Push(applicationName)
			else if (descriptor[1] == "Feedback")
				this.iFeedbackComponents.Push(applicationName)
		}
	}

	prepareConfiguration() {
		local noConfiguration := (this.Configuration.Count == 0)
		local editConfig := GetKeyState("Ctrl")
		local settings := this.Settings
		local result

		if (settings.Count = 0)
			editConfig := true

		if (editConfig || noConfiguration) {
			result := editSettings(&settings, true)

			if (result == kCancel) {
				exitStartup(true)

				return false
			}
			else if (noConfiguration && (readMultiMap(kSimulatorConfigurationFile).Count == 0)) {
				OnMessage(0x44, translateOkButton)
				MsgBox(translate("Cannot initiate startup sequence, please check the configuration..."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				exitStartup(true)

				return false
			}
			else if (result == kSave) {
				writeMultiMap(kSimulatorSettingsFile, settings)

				this.Settings := settings
			}
		}

		this.loadFromConfiguration(this.Configuration)

		return true
	}

	startSimulatorController() {
		local title, exePath, pid

		try {
			logMessage(kLogInfo, translate("Starting ") . translate("Simulator Controller"))

			if getMultiMapValue(this.Settings, "Core", "System Monitor", false) {
				if !ProcessExist("System Monitor.exe") {
					exePath := kBinariesDirectory . "System Monitor.exe"

					Run(exePath, kBinariesDirectory)

					Sleep(1000)
				}
			}

			exePath := kBinariesDirectory . "Voice Server.exe"

			Run(exePath, kBinariesDirectory, , &pid)

			exePath := kBinariesDirectory . "Simulator Controller.exe -Startup -Voice " . pid

			Run(exePath, kBinariesDirectory, , &pid)

			Sleep(1000)

			return pid
		}
		catch Any as exception {
			logMessage(kLogCritical, translate("Cannot start Simulator Controller (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

			showMessage(substituteVariables(translate("Cannot start Simulator Controller (%kBinariesDirectory%Simulator Controller.exe) - please rebuild the applications..."))
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			return 0
		}
	}

	startComponent(component) {
		logMessage(kLogInfo, translate("Starting component ") . component)

		messageSend(kFileMessage, "Startup", "startupComponent:" . component, this.ControllerPID)
	}

	startComponents(section, components, &startSimulator, &runningIndex) {
		local ignore, component

		for ignore, component in components {
			if this.Canceled
				break

			startSimulator := (startSimulator || (GetKeyState("Ctrl") || GetKeyState("MButton")))

			if getMultiMapValue(this.Settings, section, component, false) {
				if !kSilentMode
					showProgress({message: translate("Start: ") . component . translate("...")})

				logMessage(kLogInfo, translate("Component ") . component . translate(" is activated"))

				this.startComponent(component)

				Sleep(2000)
			}
			else
				logMessage(kLogInfo, translate("Component ") . component . translate(" is deactivated"))

			if !kSilentMode
				showProgress({progress: Round((runningIndex++ / (this.iCoreComponents.Length + this.iFeedbackComponents.Length)) * 90)})
		}
	}

	startSimulator() {
		if this.Canceled
			return

		if (!this.iStartupOption && (this.iSimulators.Length > 0))
			this.iStartupOption := this.iSimulators[1]

		if this.iStartupOption
			messageSend(kFileMessage, "Startup", "startupSimulator:" . this.iStartupOption, this.ControllerPID)
	}

	startup() {
		local startSimulator, runningIndex, hidden, hasSplashScreen

		playSong(songFile) {
			if (songFile && FileExist(getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)))
				messageSend(kFileMessage, "Startup", "playStartupSong:" . songFile, SimulatorStartup.Instance.ControllerPID)
		}

		if this.prepareConfiguration() {
			startSimulator := ((this.iStartupOption != false) || GetKeyState("Ctrl") || GetKeyState("MButton"))

			this.iControllerPID := this.startSimulatorController()

			if (this.ControllerPID == 0)
				exitStartup(true)

			if (!kSilentMode && this.iSplashScreen)
				showSplashScreen(this.iSplashScreen, playSong)

			if !kSilentMode
				showProgress({color: "Blue", message: translate("Start: Simulator Controller"), title: translate("Initialize Core System")})

			loop 50 {
				if !kSilentMode
					showProgress({progress: A_Index * 2})

				Sleep(20)
			}

			if !kSilentMode
				showProgress({progress: 0, color: "Green", message: translate("..."), title: translate("Starting System Components")})

			runningIndex := 1

			this.startComponents("Core", this.iCoreComponents, &startSimulator, &runningIndex)
			this.startComponents("Feedback", this.iFeedbackComponents, &startSimulator, &runningIndex)

			if !kSilentMode
				showProgress({progress: 100, message: translate("Done")})

			Sleep(500)

			this.iFinished := true

			hidden := false
			hasSplashScreen := this.iSplashScreen

			if (startSimulator || (GetKeyState("Ctrl") || GetKeyState("MButton"))) {
				if (!kSilentMode && hasSplashScreen) {
					this.hideSplashScreen()

					hidden := true
				}

				this.startSimulator()
			}

			if !kSilentMode
				hideProgress()

			if (kSilentMode || this.Canceled) {
				if (!hidden && !kSilentMode && hasSplashScreen)
					this.hideSplashScreen()

				exitStartup(true)
			}
			else {
				if !hasSplashScreen
					exitStartup(true)
			}
		}
	}

	hideSplashScreen() {
		if this.iSplashScreen {
			this.iSplashScreen := false

			hideSplashScreen()
		}
	}

	cancelStartup() {
		this.iCanceled := true

		this.hideSplashScreen()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

closeApplication(application) {
	local pid := ProcessExist(application ".exe")

	if pid
		ProcessClose(pid)
}

launchPad(command := false, arguments*) {
	local ignore, application, startupConfig, x, y, settingsButton, name

	static result := false

	static toolTips
	static executables
	static icons

	static launchPadGui

	static closeCheckBox

	closeAll(*) {
		local msgResult

		OnMessage(0x44, translateYesNoButtons)
		msgResult := MsgBox(translate("Do you really want to close all currently running applications? Unsaved data might be lost."), translate("Modular Simulator Controller System"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes")
			launchPad("Close All", GetKeyState("Ctrl", "P"))
	}

	closeOnStartup(*) {
		launchPad("CloseOnStartup")
	}

	launchStartup(*) {
		launchPad("Startup")
	}

	launchApplication(application, *) {
		local executable := launchPad("Executable", application)

		if executable
			launchPad("Launch", executable)
	}

	modifySettings(launchPadGui, *) {
		local settings := readMultiMap(kSimulatorSettingsFile)
		local restart := false

		launchPadGui.Opt("+Disabled")

		try {
			if (editSettings(&settings) == kSave) {
				writeMultiMap(kSimulatorSettingsFile, settings)

				restart := true
			}
		}
		finally {
			launchPadGui.Opt("-Disabled")
		}

		if restart
			launchPad(kRestart)
	}

	launchSimulatorDownload(*) {
		local msgResult

		OnMessage(0x44, translateYesNoButtons)
		msgResult := MsgBox(translate("Do you really want to download and install the latest version? You must close all applications before running the update."), translate("Update"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes")
			launchPad("Launch", "Simulator Download.exe", true)
	}

	showApplicationInfo(wParam, lParam, msg, hwnd) {
		local Text, CurrControl

		static PrevHwnd := 0

		if (Hwnd != PrevHwnd) {
			Text := "", ToolTip()

			CurrControl := GuiCtrlFromHwnd(hwnd)

			if CurrControl {
				Text := launchPad("ToolTip", CurrControl)

				if !text
					return

				SetTimer () => ToolTip(Text), -1000
				SetTimer () => ToolTip(), -4000
			}

			PrevHwnd := hwnd
		}
	}

	if (command = kClose) {
		if ((arguments.Length > 0) && arguments[1])
			launchPad("Close All")

		result := kClose
	}
	else if (command = kRestart)
		result := kRestart
	else if (command = "Close All") {
		broadcastMessage(concatenate(kBackgroundApps, remove(kForegroundApps, "Simulator Startup")), "exitApplication")

		Sleep(2000)

		if ((arguments.Length > 0) && arguments[1])
			launchPad(kClose)
	}
	else if (command = "ToolTip") {
		name := arguments[1].Name

		if toolTips.Has(name)
			return translate(toolTips[name])
		else
			return false
	}
	else if (command = "Executable") {
		if executables.Has(arguments[1])
			return executables[arguments[1]]
		else
			return false
	}
	else if (command = "CloseOnStartup") {
		startupConfig := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		setMultiMapValue(startupConfig, "Simulator Startup", "CloseLaunchPad", closeCheckBox.Value)

		writeMultiMap(kUserConfigDirectory . "Application Settings.ini", startupConfig)
	}
	else if (command = "Launch") {
		application := arguments[1]

		if ProcessExist(application)
			WinActivate("ahk_exe " . application)
		else
			Run(kBinariesDirectory . application)

		if ((arguments.Length > 1) && arguments[2])
			ExitApp(0)
	}
	else if (command = "Startup") {
		SimulatorStartup.StayOpen := !closeCheckBox.Value

		startupSimulator()

		if !SimulatorStartup.StayOpen
			launchPad(kClose)
	}
	else {
		result := false
		toolTips := Map()
		executables := Map()
		icons := Map()

		toolTips["Startup"] := "Startup: Launches all components to be ready for the track."

		toolTips["RaceReports"] := "Race Reports: Analyze your recent races."
		toolTips["StrategyWorkbench"] := "Strategy Workbench: Find the best strategy for an upcoming race."
		toolTips["RaceCenter"] := "Race Center: Manage your team and control the race during an event using the Team Server."
		toolTips["ServerAdministration"] := "Server Administration: Manage accounts and access rights on your Team Server. Only needed, when you run your own Team Server."

		toolTips["SimulatorSetup"] := "Setup & Configuration: Describe and generate the configuration of Simulator Controller using a simple point and click wizard. Suitable for beginners."
		toolTips["SimulatorConfiguration"] := "Configuration: Directly edit the configuration of Simulator Controller. Requires profund knowledge of the internals of the various plugins."
		toolTips["SimulatorDownload"] := "Update: Downloads and installs the latest version of Simulator Controller. Not needed, unless you disabled automatic updates during the initial installation."
		toolTips["SimulatorSettings"] := "Settings: Change the behaviour of Simulator Controller during startup and in a running simulation."
		toolTips["RaceSettings"] := "Race Settings: Manage the settings for the Virtual Race Assistants and also the connection to the Team Server for team races."
		toolTips["SessionDatabase"] := "Session Database: Manage simulator, car and track specific settings and gives access to various areas of the data collected by Simulator Controller during the sessions."
		toolTips["SetupWorkbench"] := "Setup Workbench: Develop car setups using an interview-based approach, where you describe your handling problems."
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
		executables["SetupWorkbench"] := "Setup Workbench.exe"
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
		icons["SetupWorkbench"] := kIconsDirectory . "Setup.ico"
		icons["SystemMonitor"] := kIconsDirectory . "Monitoring.ico"

		launchPadGui := StartupWindow()

		launchPadGui.SetFont("s10 Bold", "Arial")

		launchPadGui.Add("Text", "w580 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(launchPadGui, "Simulator Startup"))

		launchPadGui.SetFont("s8 Norm", "Arial")

		launchPadGui.Add("Text", "x560 YP w30 Section Right", string2Values("-", kVersion)[1])

		launchPadGui.SetFont("s6")

		try {
			if (string2Values("-", kVersion)[2] != "release")
				launchPadGui.Add("Text", "x562 YP+12 w30 BackgroundTrans Right c" . launchPadGui.Theme.TextColor["Disabled"], StrUpper(string2Values("-", kVersion)[2]))
		}

		launchPadGui.SetFont("s9 Norm", "Arial")

		launchPadGui.Add("Documentation", "x233 YS+20 w140 Center", translate("Applications")
					   , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller")

		launchPadGui.SetFont("s8 Norm", "Arial")

		settingsButton := launchPadGui.Add("Button", "x573 yp+4 w23 h23")
		settingsButton.OnEvent("Click", modifySettings.Bind(launchPadGui))
		setButtonIcon(settingsButton, kIconsDirectory . "General Settings.ico", 1)

		launchPadGui.Add("Text", "x8 yp+26 w590 0x10")

		launchPadGui.SetFont("s7 Norm", "Arial")

		launchPadGui.Add("Picture", "x16 yp+24 w60 h60 Section vStartup", kIconsDirectory . "Startup.ico").OnEvent("Click", launchStartup)

		launchPadGui.Add("Picture", "xp+90 yp w60 h60 vRaceReports", kIconsDirectory . "Chart.ico").OnEvent("Click", launchApplication.Bind("RaceReports"))
		launchPadGui.Add("Picture", "xp+74 yp w60 h60 vStrategyWorkbench", kIconsDirectory . "Dashboard.ico").OnEvent("Click", launchApplication.Bind("StrategyWorkbench"))
		launchPadGui.Add("Picture", "xp+110 yp w60 h60 vRaceCenter", kIconsDirectory . "Console.ico").OnEvent("Click", launchApplication.Bind("RaceCenter"))
		launchPadGui.Add("Picture", "xp+74 yp w60 h60 vServerAdministration", kIconsDirectory . "Server Administration.ico").OnEvent("Click", launchApplication.Bind("ServerAdministration"))

		launchPadGui.Add("Picture", "xp+150 yp w60 h60 vSystemMonitor", kIconsDirectory . "Monitoring.ico").OnEvent("Click", launchApplication.Bind("SystemMonitor"))

		launchPadGui.Add("Text", "x16 yp+64 w60 h40 Center", "Startup")
		launchPadGui.Add("Text", "xp+90 yp w60 h40 Center", "Race Reports")
		launchPadGui.Add("Text", "xp+74 yp w60 h40 Center", "Strategy Workbench")
		launchPadGui.Add("Text", "xp+110 yp w60 h40 Center", "Race Center")
		launchPadGui.Add("Text", "xp+74 yp w60 h40 Center", "Server Administration")
		launchPadGui.Add("Text", "xp+150 yp w60 h40 Center", "System Monitor")

		launchPadGui.Add("Picture", "x16 ys+104 w60 h60 vSetupWorkbench", kIconsDirectory . "Setup.ico").OnEvent("Click", launchApplication.Bind("SetupWorkbench"))
		launchPadGui.Add("Picture", "xp+90 yp w60 h60 vRaceSettings", kIconsDirectory . "Race Settings.ico").OnEvent("Click", launchApplication.Bind("RaceSettings"))
		launchPadGui.Add("Picture", "xp+74 yp w60 h60 vSessionDatabase", kIconsDirectory . "Session Database.ico").OnEvent("Click", launchApplication.Bind("SessionDatabase"))

		launchPadGui.Add("Picture", "xp+110 yp w60 h60 vSimulatorStartup", kIconsDirectory . "Configuration Wand.ico").OnEvent("Click", launchApplication.Bind("SimulatorSetup"))
		launchPadGui.Add("Picture", "xp+74 yp w60 h60 vSimulatorConfiguration", kIconsDirectory . "Configuration.ico").OnEvent("Click", launchApplication.Bind("SimulatorConfiguration"))
		launchPadGui.Add("Picture", "xp+150 yp w60 h60 vSimulatorDownload", kIconsDirectory . "Installer.ico").OnEvent("Click", launchSimulatorDownload.Bind("SimulatorDownload"))

		launchPadGui.Add("Text", "x16 yp+64 w60 h40 Center", "Setup Workbench")
		launchPadGui.Add("Text", "xp+90 yp w60 h40 Center", "Race Settings")
		launchPadGui.Add("Text", "xp+74 yp w60 h40 Center", "Session Database")
		launchPadGui.Add("Text", "xp+110 yp w60 h40 Center", "Simulator Setup")
		launchPadGui.Add("Text", "xp+74 yp w60 h40 Center", "Simulator Configuration")
		launchPadGui.Add("Text", "xp+150 yp w60 h40 Center", "Simulator Download")

		launchPadGui.SetFont("s8 Norm", "Arial")

		launchPadGui.Add("Text", "x8 yp+40 w590 0x10")

		startupConfig := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		closeCheckBox := launchPadGui.Add("CheckBox", "x16 yp+10 w120 h23 Checked" . getMultiMapValue(startupConfig, "Simulator Startup", "CloseLaunchPad", false), translate("Close on Startup"))
		closeCheckBox.OnEvent("Click", closeOnStartup)

		launchPadGui.Add("Button", "x267 yp w80 h23 Default", translate("Close")).OnEvent("Click", closeLaunchPad)
		launchPadGui.Add("Button", "x482 yp w100 h23", translate("Close All...")).OnEvent("Click", closeAll)

		OnMessage(0x0200, showApplicationInfo)

		x := false
		y := false

		if getWindowPosition("Simulator Startup", &x, &y)
			launchPadGui.Show("x" . x . " y" . y)
		else
			launchPadGui.Show()

		loop
			Sleep(100)
		until result

		launchPadGui.Destroy()

		return ((result = kClose) ? false : true)
	}
}

closeLaunchPad(*) {
	local msgResult

	if GetKeyState("Ctrl", "P") {
		OnMessage(0x44, translateYesNoButtons)
		msgResult := MsgBox(translate("Do you really want to close all currently running applications? Unsaved data might be lost."), translate("Modular Simulator Controller System"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes")
			launchPad(kClose, true)
	}
	else
		launchPad(kClose)
}

startupSimulator() {
	local fileName

	watchStartupSemaphore() {
		if !FileExist(kTempDirectory . "Startup.semaphore")
			if !SimulatorStartup.StayOpen
				exitStartup()
			else
				try {
					hideSplashScreen()
				}
				catch Any as exception {
					logError(exception)
				}
	}

	clearStartupSemaphore(*) {
		deleteFile(kTempDirectory . "Startup.semaphore")

		return false
	}

	Hotkey("Escape", cancelStartup, "On")

	SimulatorStartup.Instance := SimulatorStartup(kSimulatorConfiguration, readMultiMap(kSimulatorSettingsFile))

	SimulatorStartup.Instance.startup()

	; Looks like we have recurring deadlock situations with bidirectional pipes in case of process exit situations...
	;
	; registerMessageHandler("Startup", functionMessageHandler)
	;
	; Using a sempahore file instead...

	fileName := (kTempDirectory . "Startup.semaphore")

	if !FileExist(fileName)
		FileAppend("Startup", fileName)

	OnExit(clearStartupSemaphore)

	PeriodicTask(watchStartupSemaphore, 2000, kLowPriority).start()
}

startSimulator() {
	local icon := kIconsDirectory . "Startup.ico"
	local noLaunch, ignore

	Hotkey("Escape", cancelStartup, "Off")

	TraySetIcon(icon, "1")
	A_IconTip := "Simulator Startup"

	noLaunch := inList(A_Args, "-NoLaunchPad")

	if ((noLaunch && !GetKeyState("Shift")) || (!noLaunch && GetKeyState("Shift")))
		startupSimulator()
	else
		while launchPad()
			ignore := 1

	if (!SimulatorStartup.Instance || SimulatorStartup.Instance.Finished)
		ExitApp(0)

	return
}

cancelStartup(*) {
	local startupManager := SimulatorStartup.Instance
	local msgResult

	protectionOn()

	try {
		if startupManager {
			startupManager.hideSplashScreen()

			if !startupManager.Finished {
				SoundPlay("*32")
				OnMessage(0x44, translateYesNoButtons)
				msgResult := MsgBox(translate("Cancel Startup?"), translate("Startup"), 262180)
				OnMessage(0x44, translateYesNoButtons, 0)

				if (msgResult = "Yes") {
					if (startupManager.ControllerPID != 0)
						messageSend(kFileMessage, "Startup", "stopStartupSong", startupManager.ControllerPID)

					startupManager.cancelStartup()
				}
			}
			else {
				if (startupManager.ControllerPID != 0)
					messageSend(kFileMessage, "Startup", "stopStartupSong", startupManager.ControllerPID)

				startupManager.hideSplashScreen()

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
		messageSend(kFileMessage, "Startup", "startupExited", SimulatorStartup.Instance.ControllerPID)

		Task.startTask(exitStartup, 2000)
	}
	else {
		Hotkey("Escape", cancelStartup, "Off")

		if SimulatorStartup.Instance
			SimulatorStartup.Instance.cancelStartup()

		deleteFile(kTempDirectory . "Startup.semaphore")

		if !SimulatorStartup.StayOpen
			ExitApp(0)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startSimulator()