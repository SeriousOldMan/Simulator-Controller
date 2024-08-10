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
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
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
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Configuration\Libraries\SettingsEditor.ahk"
#Include "..\Configuration\Libraries\TeamManagementPanel.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kOk := "Ok"
global kCancel := "Cancel"
global kClose := "Close"
global kRestart := "Restart"
global kEvent := "Event"


;;;-------------------------------------------------------------------------;;;
;;;                       Private Variables Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global gStartupProfile := false


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class TeamManagerOwner {
	iWindow := false

	Window {
		Get {
			return this.iWindow
		}
	}

	__New(window) {
		this.iWindow := window
	}

	registerWidget(panel, widget) {
		widget.Visible := true
	}
}

class StartupWindow extends Window {
	__New() {
		super.__New({Descriptor: "Simulator Startup", Options: "+Caption +Border +SysMenu", Closeable: true})
	}

	Close(*) {
		if this.Closeable
			closeLaunchPad()
		else
			return true
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
		local editConfig := GetKeyState("Alt")
		local settings := this.Settings
		local result

		if (settings.Count = 0)
			editConfig := true

		if (editConfig || noConfiguration) {
			result := editSettings(&settings, false, true)

			if (result == kCancel) {
				exitStartup(true)

				return false
			}
			else if (noConfiguration && (readMultiMap(kSimulatorConfigurationFile).Count == 0)) {
				OnMessage(0x44, translateOkButton)
				withBlockedWindows(MsgBox, translate("Cannot initiate startup sequence, please check the configuration..."), translate("Error"), 262160)
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
		local fileName := (kUserConfigDirectory . "Startup.settings")
		local title, exePath, pid, ignore, tool, startup, profiles, profile

		try {
			logMessage(kLogInfo, translate("Starting ") . translate("Simulator Controller"))

			if getMultiMapValue(this.Settings, "Core", "System Monitor", false) {
				if !ProcessExist("System Monitor.exe") {
					exePath := (kBinariesDirectory . "System Monitor.exe")

					Run(exePath, kBinariesDirectory)

					Sleep(1000)
				}
			}

			exePath := (kBinariesDirectory . "Voice Server.exe")

			Run(exePath, kBinariesDirectory, , &pid)

			if FileExist(kUserConfigDirectory . "Startup.settings") {
				if gStartupProfile {
					profiles := loadStartupProfiles(gStartupProfile)
					profile := getMultiMapValue(profiles, "Profiles", "Profile", false)

					if (profile = gStartupProfile) {
						fileName := (kTempDirectory . "Startup.settings")

						writeMultiMap(fileName, profiles)
					}
					else
						profile := false
				}
				else
					profile := getMultiMapValue(readMultiMap(fileName), "Profiles", "Profile", false)

				if profile {
					showProgress({color: "Blue", message: translate("Loading profile ") . profile . translate("..."), title: translate("Preparing startup profile")})

					loop 50 {
						showProgress({progress: A_Index})

						Sleep 50
					}

					showProgress({color: "Green", message: translate("Applying profile ") . profile . translate("...")})

					loop 50 {
						showProgress({progress: A_Index + 50})

						Sleep 50
					}

					startup := (" -Startup `"" . fileName . "`"")

					for ignore, tool in string2Values(",", getMultiMapValue(readMultiMap(fileName), "Session", "Tools", ""))
						try {
							if (tool = "Race Center Lite")
								Run(kBinariesDirectory . "Race Center.exe -Simple" . startup, kBinariesDirectory)
							else
								Run(kBinariesDirectory . tool . ".exe" . startup, kBinariesDirectory)
						}
						catch Any as exception {
							logError(exception)
						}
				}
				else
					startup := ""
			}
			else
				startup := ""

			Sleep(1000)

			exePath := (kBinariesDirectory . "Simulator Controller.exe -Start -Voice " . pid . startup)

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

			startSimulator := (startSimulator || GetKeyState("MButton"))

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
			startSimulator := ((this.iStartupOption != false) || GetKeyState("MButton"))

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

			if (startSimulator || GetKeyState("MButton")) {
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
	global kSimulatorConfiguration

	local ignore, application, startupConfig, x, y, settingsButton, name, options, lastModified, hasTeamServer, restart

	static result := false

	static toolTips
	static executables
	static icons

	static launchPadGui
	static startupButton

	static closeCheckBox

	getStartupProfile() {
		local startupProfile := translate("Standard")

		if FileExist(kUserConfigDirectory . "Startup.settings") {
			if gStartupProfile {
				profiles := loadStartupProfiles(gStartupProfile)
				profile := getMultiMapValue(profiles, "Profiles", "Profile", false)

				if (profile = gStartupProfile)
					startupProfile := profile
			}
			else
				startupProfile := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Startup.settings")
												 , "Profiles", "Profile", startupProfile)
		}

		return startupProfile
	}

	closeAll(*) {
		local msgResult

		OnMessage(0x44, translateYesNoButtons)
		msgResult := withBlockedWindows(MsgBox, translate("Do you really want to close all currently running applications? Unsaved data might be lost."), translate("Modular Simulator Controller System"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes")
			launchPad("Close All", GetKeyState("Ctrl"))
	}

	closeOnStartup(*) {
		launchPad("CloseOnStartup")
	}

	launchStartup(configure, *) {
		local x, y, w, h, mX, mY
		local curCoordMode

		if !configure
			configure := GetKeyState("Ctrl")

		if !configure {
			launchPadGui["launchProfilesButton"].GetPos(&x, &y, &w, &h)

			curCoordMode := A_CoordModeMouse

			CoordMode("Mouse", "Client")

			try {
				MouseGetPos(&mX, &mY)
			}
			finally {
				CoordMode("Mouse", curCoordMode)
			}

			if ((mX >= x) && (mX <= (x + w)) && (mY >= y) && (mY <= (y + h)))
				configure := true
		}

		if configure {
			if (editStartupProfiles(launchPadGui) = "Startup") {
				startupButton.Text := ("Startup`n" . getStartupProfile())

				launchPad("Startup")
			}
			else
				startupButton.Text := ("Startup`n" . getStartupProfile())
		}
		else
			launchPad("Startup")
	}

	teamManager(configure, *) {
		local x, y, w, h, mX, mY
		local curCoordMode

		if !configure
			configure := GetKeyState("Ctrl")

		if !configure {
			launchPadGui["teamManagerButton"].GetPos(&x, &y, &w, &h)

			curCoordMode := A_CoordModeMouse

			CoordMode("Mouse", "Client")

			try {
				MouseGetPos(&mX, &mY)
			}
			finally {
				CoordMode("Mouse", curCoordMode)
			}

			if ((mX >= x) && (mX <= (x + w)) && (mY >= y) && (mY <= (y + h)))
				configure := true
		}

		if configure
			manageTeams(launchPadGui)
		else
			launchApplication("RaceCenter")
	}

	launchApplication(application, *) {
		local executable := launchPad("Executable", application)

		if executable
			launchPad("Launch", executable)
	}

	modifySettings(launchPadGui, *) {
		local settings := readMultiMap(kSimulatorSettingsFile)
		local restart := false

		launchPadGui.Block()

		try {
			if (editSettings(&settings, launchPadGui) == kSave) {
				writeMultiMap(kSimulatorSettingsFile, settings)

				restart := true
			}
		}
		finally {
			launchPadGui.Unblock()
		}

		if restart
			launchPad(kRestart)
	}

	launchSimulatorDownload(*) {
		if exitProcesses("Update", "Do you really want to download and install the latest version? You must close all applications before running the update."
					   , false, false, ["Simulator Startup"])
			launchPad("Launch", "Simulator Download.exe", true)
	}

	showApplicationInfo(wParam, lParam, msg, hwnd) {
		local text

		static prevHwnd := 0

		try {
			if (WinActive(launchPadGui) && (hwnd != prevHwnd)) {
				text := "", ToolTip()

				curControl := GuiCtrlFromHwnd(hwnd)

				if curControl {
					text := launchPad("ToolTip", curControl)

					if !text
						return

					SetTimer () => ToolTip(text), -1000
					SetTimer () => ToolTip(), -8000
				}

				prevHwnd := hwnd
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}

	disabledIcon(fileName) {
		return modifiedIcon(fileName, "Dsbld", (graphics, bitmap) {
			local x, y, value, red, green, blue, gray

			loop Gdip_GetImageHeight(bitmap) {
				y := A_Index - 1

				loop Gdip_GetImageWidth(bitmap) {
					x := A_Index - 1

					value := Gdip_GetPixel(bitmap, x, y)

					red := (0x00FF0000 & value)
					red := (red >> 16)
					blue := (0x0000FF00 & value)
					blue := (blue >> 8)
					green := (0x000000FF & value)

					gray := Round((0.299 * red) + (0.587 * green) + (0.114 * blue))

					Gdip_SetPixel(bitmap, x, y, ((value & 0xFF000000) + (gray << 16) + (gray << 8) + gray))
				}
			}
		})
	}

	if (command = kClose) {
		if ((arguments.Length > 0) && arguments[1])
			launchPad("Close All")

		result := kClose
	}
	else if (command = kRestart)
		result := kRestart
	else if (command = "Close All") {
		broadcastMessage(concatenate(kBackgroundApps, remove(kForegroundApps, "Simulator Startup")), "exitProcess")

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
		else {
			startupConfig := readMultiMap(kUserConfigDirectory . "Application Settings.ini")
			restart := inList(["Simulator Setup.exe", "Simulator Configuration.exe"], application)

			if (getMultiMapValue(startupConfig, "Simulator", "Simulator", kUndefined) != kUndefined)
				application .= (" -Simulator `"" . getMultiMapValue(startupConfig, "Simulator", "Simulator") . "`""
							  . " -Car `"" . getMultiMapValue(startupConfig, "Simulator", "Car") . "`""
							  . " -Track `"" . getMultiMapValue(startupConfig, "Simulator", "Track") . "`"")

			if restart {
				launchPadGui.Block()

				try {
					lastModified := FileGetTime(getFileName(kSimulatorConfigurationFile, kUserConfigDirectory, kConfigDirectory), "M")

					Run(kBinariesDirectory . application)

					while ProcessExist(application)
						Sleep(1000)

					if (lastModified != FileGetTime(getFileName(kSimulatorConfigurationFile, kUserConfigDirectory, kConfigDirectory), "M")) {
						loadSimulatorConfiguration()

						launchPad(kRestart)
					}
				}
				finally {
					launchPadGui.Unblock()
				}
			}
			else
				Run(kBinariesDirectory . application)
		}

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
		availableFunctions(getControllerState(true, true), &hasTeamServer)

		startupConfig := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		removeMultiMapValue(startupConfig, "Simulator", "Simulator")
		removeMultiMapValue(startupConfig, "Simulator", "Car")
		removeMultiMapValue(startupConfig, "Simulator", "Track")

		writeMultiMap(kUserConfigDirectory . "Application Settings.ini", startupConfig)

		result := false
		toolTips := Map()
		executables := Map()
		icons := Map()

		toolTips["Startup"] := "Startup: Launches all components to be ready for the track."

		toolTips["RaceReports"] := "Race Reports: Analyze your recent races."
		toolTips["StrategyWorkbench"] := "Strategy Workbench: Find the best strategy for an upcoming race."
		toolTips["PracticeCenter"] := "Practice Center: Make the most out of your practice sessions."
		toolTips["RaceCenter"] := "Race Center: Manage your team and control the race during an event using the Team Server."

		if hasTeamServer
			toolTips["ServerAdministration"] := "Server Administration: Manage accounts and access rights on your Team Server. Only needed, when you run your own Team Server."

		toolTips["SimulatorSetup"] := "Setup & Configuration: Describe and generate the configuration of Simulator Controller using a simple point and click wizard. Suitable for beginners."
		toolTips["SimulatorConfiguration"] := "Configuration: Directly edit the configuration of Simulator Controller. Requires profund knowledge of the internals of the various plugins."
		toolTips["SimulatorDownload"] := "Update: Downloads and installs the latest version of Simulator Controller. Not needed, unless you disabled automatic updates during the initial installation."
		toolTips["SimulatorSettings"] := "Settings: Change the behaviour of Simulator Controller during startup and in a running simulation."
		toolTips["RaceSettings"] := "Race Settings: Manage the settings for the Virtual Race Assistants and also the connection to the Team Server for team races."
		toolTips["SessionDatabase"] := "Session Database: Manage simulator, car and track specific settings and gives access to various areas of the data collected by Simulator Controller during the sessions."
		toolTips["SetupWorkbench"] := "Setup Workbench: Develop car setups using an interview-based approach, where you describe your handling issues."
		toolTips["SystemMonitor"] := "System Monitor: Monitor all system activities on a dashboard and investigate log files of all system components."

		executables["RaceReports"] := "Race Reports.exe"
		executables["StrategyWorkbench"] := "Strategy Workbench.exe"
		executables["PracticeCenter"] := "Practice Center.exe"
		executables["RaceCenter"] := "Race Center.exe"

		if hasTeamServer
			executables["ServerAdministration"] := "Server Administration.exe"

		executables["SimulatorSetup"] := "Simulator Setup.exe"
		executables["SimulatorConfiguration"] := "Simulator Configuration.exe"
		executables["SimulatorDownload"] := "Simulator Download.exe"
		executables["SimulatorSettings"] := "Simulator Settings.exe"
		executables["RaceSettings"] := "Race Settings.exe"
		executables["SessionDatabase"] := "Session Database.exe"
		executables["SetupWorkbench"] := "Setup Workbench.exe"
		executables["SystemMonitor"] := "System Monitor.exe"

		icons["Startup"] := (kIconsDirectory . "Startup.ico")
		icons["RaceReports"] := (kIconsDirectory . "Chart.ico")
		icons["StrategyWorkbench"] := (kIconsDirectory . "Workbench.ico")
		icons["PracticeCenter"] := (kIconsDirectory . "Practice.ico")
		icons["RaceCenter"] := (kIconsDirectory . "Console.ico")

		if hasTeamServer
			icons["ServerAdministration"] := (kIconsDirectory . "Server Administration.ico")
		else
			icons["ServerAdministration"] := disabledIcon(kIconsDirectory . "Server Administration.ico")

		icons["SimulatorSetup"] := (kIconsDirectory . "Configuration Wand.ico")
		icons["SimulatorConfiguration"] := (kIconsDirectory . "Configuration.ico")
		icons["SimulatorDownload"] := (kIconsDirectory . "Installer.ico")
		icons["SimulatorSettings"] := (kIconsDirectory . "Settings.ico")
		icons["RaceSettings"] := (kIconsDirectory . "Race Settings.ico")
		icons["SessionDatabase"] := (kIconsDirectory . "Session Database.ico")
		icons["SetupWorkbench"] := (kIconsDirectory . "Setup.ico")
		icons["SystemMonitor"] := (kIconsDirectory . "Monitoring.ico")

		launchPadGui := StartupWindow()

		launchPadGui.SetFont("s10 Bold", "Arial")

		launchPadGui.Add("Text", "w580 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(launchPadGui, "Simulator Startup"))

		launchPadGui.SetFont("s8 Norm", "Arial")

		launchPadGui.Add("Text", "x544 YP w30 Section Right", string2Values("-", kVersion)[1])

		launchPadGui.SetFont("s6")

		try {
			if (string2Values("-", kVersion)[2] != "release")
				launchPadGui.Add("Text", "x546 YP+12 w30 BackgroundTrans Right c" . launchPadGui.Theme.TextColor["Disabled"], StrUpper(string2Values("-", kVersion)[2]))
		}

		launchPadGui.SetFont("s9 Norm", "Arial")

		launchPadGui.Add("Documentation", "x213 YS+20 w180 Center", translate("Applications")
					   , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller")

		launchPadGui.SetFont("s8 Norm", "Arial")

		settingsButton := launchPadGui.Add("Button", "x556 yp+4 w23 h23")
		settingsButton.OnEvent("Click", modifySettings.Bind(launchPadGui))
		setButtonIcon(settingsButton, kIconsDirectory . "General Settings.ico", 1)

		launchPadGui.Add("Text", "x8 yp+26 w574 0x10")

		launchPadGui.SetFont("s7 Norm", "Arial")

		launchPadGui.Add("Picture", "x16 yp+24 w60 h60 Section vStartup", icons["Startup"]).OnEvent("Click", launchStartup.Bind(false))
		widget := launchPadGui.Add("Picture", "x59 yp+43 w14 h14 BackgroundTrans vlaunchProfilesButton", kIconsDirectory . "General Settings White.ico")
		widget.OnEvent("Click", launchStartup.Bind(true))

		launchPadGui.Add("Picture", "xp+47 ys w60 h60 vRaceSettings", icons["RaceSettings"]).OnEvent("Click", launchApplication.Bind("RaceSettings"))
		launchPadGui.Add("Picture", "xp+74 yp w60 h60 vSessionDatabase", icons["SessionDatabase"]).OnEvent("Click", launchApplication.Bind("SessionDatabase"))

		launchPadGui.Add("Picture", "xp+90 yp w60 h60 vPracticeCenter", icons["PracticeCenter"]).OnEvent("Click", launchApplication.Bind("PracticeCenter"))
		launchPadGui.Add("Picture", "xp+74 yp w60 h60 vStrategyWorkbench", icons["StrategyWorkbench"]).OnEvent("Click", launchApplication.Bind("StrategyWorkbench"))

		widget := launchPadGui.Add("Picture", "xp+74 yp w60 h60 vRaceCenter", icons["RaceCenter"])

		if hasTeamServer {
			widget.OnEvent("Click", teamManager.Bind(false))

			widget := launchPadGui.Add("Picture", "xp+4 yp+43 w14 h14 BackgroundTrans vteamManagerButton", kIconsDirectory . "General Settings White.ico")
			widget.OnEvent("Click", teamManager.Bind(true))

			launchPadGui.Add("Picture", "xp+86 yp-43 w60 h60 vRaceReports", icons["RaceReports"]).OnEvent("Click", launchApplication.Bind("RaceReports"))
		}
		else {
			widget.OnEvent("Click", launchApplication.Bind("RaceCenter"))

			launchPadGui.Add("Picture", "xp+90 yp w60 h60 vRaceReports", icons["RaceReports"]).OnEvent("Click", launchApplication.Bind("RaceReports"))
		}

		startupButton := launchPadGui.Add("Text", "x16 yp+64 w60 h23 Center", "Startup")

		launchPadGui.Add("Text", "xp+90 yp w60 h40 Center", "Race Settings")
		launchPadGui.Add("Text", "xp+74 yp w60 h40 Center", "Session Database")
		launchPadGui.Add("Text", "xp+90 yp w60 h40 Center", "Practice Center")
		launchPadGui.Add("Text", "xp+74 yp w60 h40 Center", "Strategy Workbench")
		launchPadGui.Add("Text", "xp+74 yp w60 h40 Center", "Race Center")
		launchPadGui.Add("Text", "xp+90 yp w60 h40 Center", "Race Reports")

		launchPadGui.Add("Picture", "x16 ys+104 w60 h60 vSystemMonitor", icons["SystemMonitor"]).OnEvent("Click", launchApplication.Bind("SystemMonitor"))
		launchPadGui.Add("Picture", "xp+126 ys+104 w60 h60 vSetupWorkbench", icons["SetupWorkbench"]).OnEvent("Click", launchApplication.Bind("SetupWorkbench"))

		launchPadGui.Add("Picture", "xp+128 yp w60 h60 vSimulatorSetup", icons["SimulatorSetup"]).OnEvent("Click", launchApplication.Bind("SimulatorSetup"))
		launchPadGui.Add("Picture", "xp+74 yp w60 h60 vSimulatorConfiguration", icons["SimulatorConfiguration"]).OnEvent("Click", launchApplication.Bind("SimulatorConfiguration"))

		if hasTeamServer {
			launchPadGui.Add("Picture", "xp+74 yp w60 h60 vServerAdministration", icons["ServerAdministration"]).OnEvent("Click", launchApplication.Bind("ServerAdministration"))

			launchPadGui.Add("Picture", "xp+90 yp w60 h60 vSimulatorDownload", icons["SimulatorDownload"]).OnEvent("Click", launchSimulatorDownload.Bind("SimulatorDownload"))
		}
		else
			launchPadGui.Add("Picture", "xp+164 yp w60 h60 vSimulatorDownload", icons["SimulatorDownload"]).OnEvent("Click", launchSimulatorDownload.Bind("SimulatorDownload"))

		launchPadGui.Add("Text", "x16 yp+64 w60 h40 Center", "System Monitor")
		launchPadGui.Add("Text", "xp+126 yp w60 h40 Center", "Setup Workbench")
		launchPadGui.Add("Text", "xp+128 yp w60 h40 Center", "Simulator Setup")
		launchPadGui.Add("Text", "xp+74 yp w60 h40 Center", "Simulator Configuration")

		if hasTeamServer {
			launchPadGui.Add("Text", "xp+74 yp w60 h40 Center", "Server Administration")

			launchPadGui.Add("Text", "xp+90 yp w60 h40 Center", "Simulator Download")
		}
		else
			launchPadGui.Add("Text", "xp+164 yp w60 h40 Center", "Simulator Download")

		launchPadGui.SetFont("s8 Norm", "Arial")

		launchPadGui.Add("Text", "x8 yp+40 w574 0x10")

		closeCheckBox := launchPadGui.Add("CheckBox", "x16 yp+10 w150 h21 Checked" . getMultiMapValue(startupConfig, "Simulator Startup", "CloseLaunchPad", false), translate("Close on Startup"))
		closeCheckBox.OnEvent("Click", closeOnStartup)

		launchPadGui.Add("Button", "x259 yp w80 h23 Default", translate("Close")).OnEvent("Click", closeLaunchPad)
		launchPadGui.Add("Button", "x476 yp w100 h23", translate("Close All...")).OnEvent("Click", closeAll)

		startupButton.Text := ("Startup`n" . getStartupProfile())

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

	if GetKeyState("Ctrl") {
		OnMessage(0x44, translateYesNoButtons)
		msgResult := withBlockedWindows(MsgBox, translate("Do you really want to close all currently running applications? Unsaved data might be lost."), translate("Modular Simulator Controller System"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes")
			launchPad(kClose, true)
	}
	else
		launchPad(kClose)
}

availableFunctions(configuration, &hasTeamServer := false
								, &hasDrivingCoach := false,  &hasRaceSpotter := false
								, &hasRaceStrategist := false, &hasRaceEngineer := false
								, &hasMotionFeedback := false, &hasChassisVibration := false, &hasPedalVibration := false) {
	local functions := []

	hasTeamServer := getMultiMapValue(configuration, "Plugins", "Team Server", false)

	if hasTeamServer
		hasTeamServer := string2Values("|", hasTeamServer)[1]

	hasDrivingCoach := getMultiMapValue(configuration, "Plugins", "Driving Coach", false)

	if hasDrivingCoach
		hasDrivingCoach := string2Values("|", hasDrivingCoach)[1]

	hasRaceSpotter := getMultiMapValue(configuration, "Plugins", "Race Spotter", false)

	if hasRaceSpotter
		hasRaceSpotter := string2Values("|", hasRaceSpotter)[1]

	hasRaceStrategist := getMultiMapValue(configuration, "Plugins", "Race Strategist", false)

	if hasRaceStrategist
		hasRaceStrategist := string2Values("|", hasRaceStrategist)[1]

	hasRaceEngineer := getMultiMapValue(configuration, "Plugins", "Race Engineer", false)

	if hasRaceEngineer
		hasRaceEngineer := string2Values("|", hasRaceEngineer)[1]

	hasMotionFeedback := getMultiMapValue(configuration, "Plugins", "Motion Feedback", false)

	if hasMotionFeedback
		hasMotionFeedback := string2Values("|", hasMotionFeedback)[1]

	hasChassisVibration := getMultiMapValue(configuration, "Plugins", "Tactile Feedback", false)

	if (hasChassisVibration && string2Values("|", hasChassisVibration)[1]) {
		hasChassisVibration := string2Values(",", string2Values("|", hasChassisVibration)[3])

		hasPedalVibration := inList(hasChassisVibration, "Pedal Vibration")
		hasChassisVibration := inList(hasChassisVibration, "Chassis Vibration")
	}
	else {
		hasChassisVibration := false
		hasPedalVibration := false
	}

	if hasDrivingCoach {
		functions.Push(Array("Driving Coach", "Performance Analysis"))
		functions.Push(Array("Driving Coach", "Handling Analysis"))
	}

	if hasRaceSpotter
		functions.Push(Array("Race Spotter", "Track Automation"))

	if hasRaceStrategist {
		functions.Push(Array("Race Strategist", "Telemetry Collection"))
		functions.Push(Array("Race Strategist", "Traffic Analysis"))
	}

	if hasRaceEngineer {
		functions.Push(Array("Race Engineer", "Pressure Collection"))
		functions.Push(Array("Race Engineer", "Fuel Warning"))
		functions.Push(Array("Race Engineer", "Damage Warning"))
		functions.Push(Array("Race Engineer", "Pressure Warning"))
		functions.Push(Array("Race Engineer", "Pressure Correction by Temperature"))
		functions.Push(Array("Race Engineer", "Pressure Correction from Database"))
		functions.Push(Array("Race Engineer", "Pressure Correction for Pressure Loss"))
		functions.Push(Array("Race Engineer", "Pitstop Service"))
	}

	if hasMotionFeedback
		functions.Push(Array("Motion Feedback", "Motion"))

	if hasPedalVibration
		functions.Push(Array("Tactile Feedback", "Pedal Vibration"))

	if hasChassisVibration {
		functions.Push(Array("Tactile Feedback", "Front Vibration"))
		functions.Push(Array("Tactile Feedback", "Rear Vibration"))
	}

	return functions
}

loadStartupProfiles(target, fileName := false) {
	local settings := readMultiMap(fileName ? fileName : (kUserConfigDirectory . "Startup.settings"))
	local hasTeamServer := false
	local functions := availableFunctions(getControllerState(true, true), &hasTeamServer)
	local profiles := []
	local selected := false
	local activeProfiles := []
	local ignore, profile, name, assistant, property, function

	for ignore, name in string2Values(";|;", getMultiMapValue(settings, "Profiles", "Profiles", "")) {
		profile := CaseInsenseMap("Name", name
								, "Mode", hasTeamServer ? getMultiMapValue(settings, "Profiles", name . ".Mode", "Solo") : false
								, "Tools", getMultiMapValue(settings, "Profiles", name . ".Tools", ""))

		for ignore, assistant in kRaceAssistants
			profile[assistant] := getMultiMapValue(settings, "Profiles", name . "." . assistant, "Default")

		profile["Assistant.Autonomy"] := getMultiMapValue(settings, "Profiles", name . ".Assistant.Autonomy", "Default")

		if (profile["Assistant.Autonomy"] = "Custom")
			profile["Assistant.Autonomy"] := "Default"

		if (profile["Mode"] = "Team") {
			profile["Team.Mode"] := getMultiMapValue(settings, "Profiles", name . ".Team.Mode", "Settings")

			if (profile["Team.Mode"] = "Profile") {
				for ignore, property in ["Server.URL", "Server.Token", "Team.Name", "Team.Identifier"
									   , "Driver.Name", "Driver.Identifier", "Session.Name", "Session.Identifier"]
					profile[property] := getMultiMapValue(settings, "Profiles", name . "." . property, "")
			}
		}

		for ignore, function in functions
			if (getMultiMapValue(settings, "Profiles", name . ".Function." . function[2], kUndefined) != kUndefined)
				profile["Function." . function[2]] := getMultiMapValue(settings, "Profiles", name . ".Function." . function[2])

		profiles.Push(profile)

		if (name = target)
			selected := profile
	}

	settings := newMultiMap()

	for ignore, profile in profiles {
		name := profile["Name"]

		activeProfiles.Push(name)

		setMultiMapValue(settings, "Profiles", name . ".Mode", profile["Mode"])
		setMultiMapValue(settings, "Profiles", name . ".Tools", profile["Tools"])

		for ignore, assistant in kRaceAssistants
			if (profile[assistant] != "Default")
				setMultiMapValue(settings, "Profiles", name . "." . assistant, profile[assistant])

		if (profile["Assistant.Autonomy"] != "Default")
			setMultiMapValue(settings, "Profiles", name . ".Assistant.Autonomy", profile["Assistant.Autonomy"])

		if (profile["Mode"] = "Team") {
			setMultiMapValue(settings, "Profiles", name . ".Team.Mode", profile["Team.Mode"])

			if (profile["Team.Mode"] = "Profile")
				for ignore, property in ["Server.URL", "Server.Token", "Team.Name", "Team.Identifier"
									   , "Driver.Name", "Driver.Identifier", "Session.Name", "Session.Identifier"]
					setMultiMapValue(settings, "Profiles", name . "." . property, profile[property])
		}

		for ignore, function in functions
			if profile.Has("Function." . function[2])
				setMultiMapValue(settings, "Profiles", name . ".Function." . function[2], profile["Function." . function[2]])
	}

	setMultiMapValue(settings, "Profiles", "Profiles", values2String(";|;", activeProfiles*))

	if selected {
		setMultiMapValue(settings, "Profiles", "Profile", selected["Name"])

		setMultiMapValue(settings, "Session", "Mode", selected["Mode"])
		setMultiMapValue(settings, "Session", "Tools", selected["Tools"])

		for ignore, assistant in kRaceAssistants
			if (selected[assistant] != "Default") {
				setMultiMapValue(settings, assistant, "Enabled", selected[assistant] != "Disabled")
				setMultiMapValue(settings, assistant, "Silent", selected[assistant] = "Silent")
				setMultiMapValue(settings, assistant, "Muted", selected[assistant] = "Muted")
			}

		if (selected["Assistant.Autonomy"] != "Default")
			setMultiMapValue(settings, "Race Assistant", "Autonomy", selected["Assistant.Autonomy"])

		if ((selected["Mode"] = "Team") && (selected["Team.Mode"] = "Profile"))
			for ignore, property in ["Server.URL", "Server.Token", "Team.Name", "Team.Identifier"
								   , "Driver.Name", "Driver.Identifier", "Session.Name", "Session.Identifier"]
				setMultiMapValue(settings, "Team Session", property, selected[property])

		for ignore, function in functions
			if selected.Has("Function." . function[2])
				setMultiMapValue(settings, "Functions", function[2], selected["Function." . function[2]])

	}

	return settings
}

editStartupProfiles(launchPadOrCommand, arguments*) {
	local x, y, w, h, width, x0, x1, w1, w2, x2, w4, x4, w3, x3, x4, x5, w5, x6, x7
	local checkedRows, checked, settingsTab, first
	local profile, plugin, pluginConfiguration, ignore, lastModified, configuration
	local dllFile, connection
	local names, exception, chosen, fileName, selected, translator, msgResult

	static done := false

	static hasTeamServer := false
	static hasDrivingCoach := false
	static hasRaceSpotter := false
	static hasRaceStrategist := false
	static hasRaceEngineer := false
	static hasChassisVibration := false
	static hasPedalVibration := false
	static hasMotionFeedback := false

	static profiles
	static functions
	static activeAssistants

	static profilesEditorGui
	static profilesListView
	static functionsListView

	static selectedProfile := false
	static checkedProfile := false

	static connector := false
	static connected := false
	static keepAliveTask := false
	static serverURLs := []

	static serverURL, serverToken, teamName, theDriverName, sessionName, teamIdentifier, driverIdentifier, sessionIdentifier

	static teams := CaseInsenseMap()
	static drivers := CaseInsenseMap()
	static sessions := CaseInsenseMap()

	parseObject(properties) {
		local result := CaseInsenseMap()
		local property

		properties := StrReplace(properties, "`r", "")

		loop Parse, properties, "`n" {
			property := string2Values("=", A_LoopField)

			result[property[1]] := property[2]
		}

		return result
	}

	loadTeams(connector) {
		local teams := CaseInsenseMap()
		local identifiers, ignore, identifier, team

		try {
			identifiers := string2Values(";", connector.GetAllTeams())
		}
		catch Any as exception {
			identifiers := []
		}

		for ignore, identifier in identifiers {
			team := parseObject(connector.GetTeam(identifier))

			teams[team["Name"]] := team["Identifier"]
		}

		return teams
	}

	loadDrivers(connector, team) {
		local drivers := CaseInsenseMap()
		local identifiers, ignore, identifier, driver

		if team {
			try {
				identifiers := string2Values(";", connector.GetTeamDrivers(team))
			}
			catch Any as exception {
				identifiers := []
			}

			for ignore, identifier in identifiers {
				driver := parseObject(connector.GetDriver(identifier))

				drivers[driverName(driver["ForName"], driver["SurName"], driver["NickName"])] := driver["Identifier"]
			}
		}

		return drivers
	}

	loadSessions(connector, team) {
		local sessions := CaseInsenseMap()
		local identifiers, ignore, identifier, session

		if team {
			try {
				identifiers := string2Values(";", connector.GetTeamSessions(team))
			}
			catch Any as exception {
				identifiers := []
			}

			for ignore, identifier in identifiers {
				try {
					session := parseObject(connector.GetSession(identifier))

					sessions[session["Name"]] := session["Identifier"]
				}
				catch Any as exception {
					logError(exception)
				}
			}
		}

		return sessions
	}

	loadProfiles(fileName := false, delete := true) {
		local settings := readMultiMap(fileName ? fileName : (kUserConfigDirectory . "Startup.settings"))
		local ignore, profile, name, assistant, property, function

		if delete
			profiles := []

		for ignore, name in string2Values(";|;", getMultiMapValue(settings, "Profiles", "Profiles", "")) {
			profile := CaseInsenseMap("Name", name
									, "Mode", hasTeamServer ? getMultiMapValue(settings, "Profiles", name . ".Mode", "Solo") : false
									, "Tools", getMultiMapValue(settings, "Profiles", name . ".Tools", ""))

			for ignore, assistant in kRaceAssistants
				profile[assistant] := getMultiMapValue(settings, "Profiles", name . "." . assistant, "Default")

			profile["Assistant.Autonomy"] := getMultiMapValue(settings, "Profiles", name . ".Assistant.Autonomy", "Default")

			if (profile["Assistant.Autonomy"] = "Custom")
				profile["Assistant.Autonomy"] := "Default"

			if (profile["Mode"] = "Team") {
				profile["Team.Mode"] := getMultiMapValue(settings, "Profiles", name . ".Team.Mode", "Settings")

				if (profile["Team.Mode"] = "Profile") {
					for ignore, property in ["Server.URL", "Server.Token", "Team.Name", "Team.Identifier"
										   , "Driver.Name", "Driver.Identifier", "Session.Name", "Session.Identifier"]
						profile[property] := getMultiMapValue(settings, "Profiles", name . "." . property, "")
				}
			}

			for ignore, function in functions
				if (getMultiMapValue(settings, "Profiles", name . ".Function." . function[2], kUndefined) != kUndefined)
					profile["Function." . function[2]] := getMultiMapValue(settings, "Profiles", name . ".Function." . function[2])

			profiles.Push(profile)
		}

		profilesListView.Delete()

		profilesListView.Add("", translate("Standard"), translate("-"))

		checkedProfile := getMultiMapValue(settings, "Profiles", "Profile", false)

		for ignore, profile in profiles {
			profilesListView.Add("", profile["Name"], translate(profile["Mode"]))

			if (checkedProfile = profile["Name"]) {
				profilesListView.Modify(profilesListView.GetCount(), "Check")

				checkedProfile := (A_Index +  1)
			}
		}

		loop 2
			profilesListView.ModifyCol(A_Index, "AutoHdr")
	}

	saveProfiles(fileName := false, theProfiles?, checked?) {
		local settings := newMultiMap()
		local activeProfiles := []
		local ignore, profile, assistant, property, name, function

		if !isSet(theProfiles)
			theProfiles := profiles

		for ignore, profile in theProfiles {
			name := profile["Name"]

			activeProfiles.Push(name)

			setMultiMapValue(settings, "Profiles", name . ".Mode", profile["Mode"])
			setMultiMapValue(settings, "Profiles", name . ".Tools", profile["Tools"])

			for ignore, assistant in kRaceAssistants
				if (profile[assistant] != "Default")
					setMultiMapValue(settings, "Profiles", name . "." . assistant, profile[assistant])

			if (profile["Assistant.Autonomy"] != "Default")
				setMultiMapValue(settings, "Profiles", name . ".Assistant.Autonomy", profile["Assistant.Autonomy"])

			if (profile["Mode"] = "Team") {
				setMultiMapValue(settings, "Profiles", name . ".Team.Mode", profile["Team.Mode"])

				if (profile["Team.Mode"] = "Profile")
					for ignore, property in ["Server.URL", "Server.Token", "Team.Name", "Team.Identifier"
										   , "Driver.Name", "Driver.Identifier", "Session.Name", "Session.Identifier"]
						setMultiMapValue(settings, "Profiles", name . "." . property, profile[property])
			}

			for ignore, function in functions
				if profile.Has("Function." . function[2])
					setMultiMapValue(settings, "Profiles", name . ".Function." . function[2], profile["Function." . function[2]])
		}

		setMultiMapValue(settings, "Profiles", "Profiles", values2String(";|;", activeProfiles*))

		if ((!isSet(checked) || checked) && checkedProfile) {
			profile := theProfiles[checkedProfile - 1]

			setMultiMapValue(settings, "Profiles", "Profile", profile["Name"])

			setMultiMapValue(settings, "Session", "Mode", profile["Mode"])
			setMultiMapValue(settings, "Session", "Tools", profile["Tools"])

			for ignore, assistant in kRaceAssistants
				if (profile[assistant] != "Default") {
					setMultiMapValue(settings, assistant, "Enabled", profile[assistant] != "Disabled")
					setMultiMapValue(settings, assistant, "Silent", profile[assistant] = "Silent")
					setMultiMapValue(settings, assistant, "Muted", profile[assistant] = "Muted")
				}

			if (profile["Assistant.Autonomy"] != "Default")
				setMultiMapValue(settings, "Race Assistant", "Autonomy", profile["Assistant.Autonomy"])

			if ((profile["Mode"] = "Team") && (profile["Team.Mode"] = "Profile"))
				for ignore, property in ["Server.URL", "Server.Token", "Team.Name", "Team.Identifier"
									   , "Driver.Name", "Driver.Identifier", "Session.Name", "Session.Identifier"]
					setMultiMapValue(settings, "Team Session", property, profile[property])

			for ignore, function in functions
				if profile.Has("Function." . function[2])
					setMultiMapValue(settings, "Functions", function[2], profile["Function." . function[2]])

		}

		writeMultiMap(fileName ? fileName : (kUserConfigDirectory . "Startup.settings"), settings)
	}

	newProfile() {
		local index, function

		profile := CaseInsenseMap("Name", "", "Mode", "Solo", "Tools", "", "Assistant.Autonomy", "Default")

		for ignore, assistant in kRaceAssistants
			profile[assistant] := "Default"

		if keepAliveTask {
			keepAliveTask.stop()

			keepAliveTask := false
		}

		serverURL := ""
		serverToken := ""
		teamName := ""
		teamIdentifier := false
		theDriverName := ""
		driverIdentifier := false
		sessionName := ""
		sessionIdentifier := false

		return profile
	}

	loadProfile(profile) {
		local ignore, plugin

		profilesEditorGui["profileNameEdit"].Text := profile["Name"]
		profilesEditorGui["profileModeDropDown"].Choose(Max(1, inList(hasTeamServer ? ["Solo", "Team"] : ["Solo"], profile["Mode"])))
		profilesEditorGui["profilePitwallDropDown"].Choose((1 + inList(hasTeamServer ? ["Practice Center", "Race Center", "Race Center Lite"] : ["Practice Center"], profile["Tools"])))

		profilesEditorGui["profileAutonomyDropDown"].Choose(inList(["Yes", "No", "Default"], profile["Assistant.Autonomy"]))

		for ignore, plugin in activeAssistants
			if profile.Has(plugin[1])
				plugin[2].Choose(inList(["Default", "Disabled", "Silent", "Muted", "Active"], profile[plugin[1]]))

		if keepAliveTask {
			keepAliveTask.stop()

			keepAliveTask := false
		}

		if (profile["Mode"] = "Team") {
			profilesEditorGui["profileCredentialsDropDown"].Choose(inList(["Profile", "Settings"], profile["Team.Mode"]))

			if (profile["Team.Mode"] = "Profile") {
				profilesEditorGui["profileServerURLEdit"].Text := profile["Server.URL"]
				profilesEditorGui["profileServerTokenEdit"].Text := profile["Server.Token"]

				profilesEditorGui["profileTeamDropDown"].Delete()
				profilesEditorGui["profileTeamDropDown"].Add([profile["Team.Name"]])
				profilesEditorGui["profileTeamDropDown"].Choose(1)
				teamName := profile["Team.Name"]
				teamIdentifier := profile["Team.Identifier"]

				profilesEditorGui["profileDriverDropDown"].Delete()
				profilesEditorGui["profileDriverDropDown"].Add([profile["Driver.Name"]])
				profilesEditorGui["profileDriverDropDown"].Choose(1)
				theDriverName := profile["Driver.Name"]
				driverIdentifier := profile["Driver.Identifier"]

				profilesEditorGui["profileSessionDropDown"].Delete()
				profilesEditorGui["profileSessionDropDown"].Add([profile["Session.Name"]])
				profilesEditorGui["profileSessionDropDown"].Choose(1)
				sessionName := profile["Session.Name"]
				sessionIdentifier := profile["Session.Identifier"]
			}
		}

		loadFunctions(profile)
	}

	saveProfile(profile) {
		local ignore, plugin, function, index

		if (Trim(profilesEditorGui["profileNameEdit"].Text) = "") {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgBox, translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}
		else {
			profile["Name"] := profilesEditorGui["profileNameEdit"].Text
			profile["Mode"] :=  ["Solo", "Team"][profilesEditorGui["profileModeDropDown"].Value]
			profile["Tools"] := ["", "Practice Center", "Race Center", "Race Center Lite"][profilesEditorGui["profilePitwallDropDown"].Value]

			profile["Assistant.Autonomy"] := ["Yes", "No", "Default"][profilesEditorGui["profileAutonomyDropDown"].Value]

			for ignore, plugin in activeAssistants
				if plugin[2].Value
					profile[plugin[1]] := ["Default", "Disabled", "Silent", "Muted", "Active"][plugin[2].Value]

			if (profile["Mode"] = "Team") {
				profile["Team.Mode"] := ["Profile", "Settings"][profilesEditorGui["profileCredentialsDropDown"].Value]

				if (profile["Team.Mode"] = "Profile") {
					profile["Server.URL"] := profilesEditorGui["profileServerURLEdit"].Text
					profile["Server.Token"] := profilesEditorGui["profileServerTokenEdit"].Text

					profile["Team.Name"] := profilesEditorGui["profileTeamDropDown"].Text
					profile["Team.Identifier"] := teamIdentifier
					profile["Driver.Name"] := profilesEditorGui["profileDriverDropDown"].Text
					profile["Driver.Identifier"] := driverIdentifier
					profile["Session.Name"] := profilesEditorGui["profileSessionDropDown"].Text
					profile["Session.Identifier"] := sessionIdentifier
				}
			}

			return true
		}
	}

	loadFunctions(profile) {
		local listViewIcons := IL_Create(functions.Length)
		local picture, ignore, function

		functionsListView.Opt("-Redraw")

		try {
			functionsListView.Delete()

			for index, function in functions {
				if (profile && profile.Has("Function." . function[2]))
					picture := (kIconsDirectory . (profile["Function." . function[2]] ? "Checked.ico" : "Unchecked.ico"))
				else
					picture := (kIconsDirectory . "Indeterminate.ico")

				IL_Add(listViewIcons, picture)
			}

			listViewIcons := functionsListView.SetImageList(listViewIcons)

			if listViewIcons
				IL_Destroy(listViewIcons)

			for ignore, function in functions
				functionsListView.Add("Icon" . A_Index, translate(function[1]), translate(function[2]))

			loop 2
				functionsListView.ModifyCol(A_Index, "AutoHdr")
		}
		finally {
			functionsListView.Opt("+Redraw")
		}
	}

	selectProfile(listView, line, selected) {
		if selected
			chooseProfile(listView, line)
	}

	chooseProfile(listView, line, *) {
		if (line != selectedProfile) {
			if (selectedProfile > 1)
				if !editStartupProfiles(kEvent, "ProfileSave") {
					profilesListView.Modify(selectedProfile, "Vis Select")

					return
				}

			if (line > 1)
				editStartupProfiles(kEvent, "ProfileLoad", line)
			else if (line = 1) {
				profilesListView.Modify(1, "-Select")

				if selectedProfile
					profilesListView.Modify(selectedProfile, "Select")
			}
			else
				selectedProfile := false
		}

		editStartupProfiles("Update State")
	}

	chooseFunction(listView, line, *) {
		local profile, function

		if (selectedProfile && line) {
			profile := profiles[selectedProfile - 1]
			function := functions[line][2]

			if profile.Has("Function." . function) {
				if profile["Function." . function]
					profile.Delete("Function." . function)
				else
					profile["Function." . function] := true
			}
			else
				profile["Function." . function] := false

			loadFunctions(profile)

			functionsListView.Modify(line, "Vis Select")
		}

		noSelect(functionsListView)
	}

	noSelect(listView, *) {
		loop listView.GetCount()
			listView.Modify(A_Index, "-Select")
	}

	if (launchPadOrCommand == kSave) {
		if selectedProfile
			if !editStartupProfiles(kEvent, "ProfileSave")
				return false

		saveProfiles()

		done := (GetKeyState("Ctrl") ? "Startup" : kSave)
	}
	else if (launchPadOrCommand == kCancel)
		done := kCancel
	else if (launchPadOrCommand == kEvent) {
		if (arguments[1] = "ProfilesUpload") {
			if (selectedProfile > 1)
				if !editStartupProfiles(kEvent, "ProfileSave")
					return

			profilesEditorGui.Opt("+OwnDialogs")

			OnMessage(0x44, translateLoadCancelButtons)
			fileName := withBlockedWindows(FileSelect, 1, "", translate("Import Profiles..."), "Profiles (*.profiles)")
			OnMessage(0x44, translateLoadCancelButtons, 0)

			if (fileName != "")
				if (profiles.Length > 0) {
					translator := translateMsgBoxButtons.Bind(["Insert", "Replace", "Cancel"])

					OnMessage(0x44, translator)
					msgResult := withBlockedWindows(MsgBox, translate("Do you want to replace all current entries or do you want to add the imported entries to the list?"), translate("Import"), 262179)
					OnMessage(0x44, translator, 0)

					if (msgResult = "Cancel")
						return

					if (msgResult = "Yes")
						loadProfiles(fileName, false)

					if (msgResult = "No")
						loadProfiles(fileName, true)
				}
				else
					loadProfiles(fileName, false)

			editStartupProfiles("Update State")
		}
		else if (arguments[1] = "ProfilesDownload") {
			if (selectedProfile > 1)
				if !editStartupProfiles(kEvent, "ProfileSave")
					return

			profilesEditorGui.Opt("+OwnDialogs")

			selected := GetKeyState("Ctrl")

			if (selected && !selectedProfile)
				return

			OnMessage(0x44, translateSaveCancelButtons)
			fileName := withBlockedWindows(FileSelect, "S17", "", translate("Export Profiles..."), "Profiles (*.profiles)")
			OnMessage(0x44, translateSaveCancelButtons, 0)

			if (fileName != "") {
				if !InStr(fileName, ".profiles")
					fileName := (fileName . ".profiles")

				saveProfiles(fileName, selected ? [profiles[selectedProfile - 1]] : profiles, false)
			}

			editStartupProfiles("Update State")
		}
		else if (arguments[1] = "ProfileNew") {
			if (selectedProfile > 1)
				if !editStartupProfiles(kEvent, "ProfileSave")
					return

			profile := newProfile()

			profiles.Push(profile)

			profilesListView.Add("", profile["Name"], translate(profile["Mode"]))

			profilesListView.Modify(selectedProfile, "Vis Select")

			editStartupProfiles(kEvent, "ProfileLoad", profiles.Length + 1)
		}
		else if (arguments[1] = "ProfileCopy") {
			if (selectedProfile > 1)
				if !editStartupProfiles(kEvent, "ProfileSave")
					return

			profile := profiles[selectedProfile - 1].Clone()

			profiles.Push(profile)

			profilesListView.Add("", profile["Name"], translate(profile["Mode"]))

			profilesListView.Modify(selectedProfile, "Vis Select")

			editStartupProfiles(kEvent, "ProfileLoad", profiles.Length + 1)
		}
		else if (arguments[1] = "ProfileDelete") {
			if selectedProfile {
				profiles.RemoveAt(selectedProfile - 1)

				profilesListView.Delete(selectedProfile)

				selectedProfile := false
			}

			editStartupProfiles("Update State")
		}
		else if (arguments[1] = "ProfileLoad") {
			if (selectedProfile > 1)
				if !editStartupProfiles(kEvent, "ProfileSave")
					return

			selectedProfile := arguments[2]

			if (selectedProfile > 1) {
				loadProfile(profiles[selectedProfile - 1])

				profilesListView.Modify(selectedProfile, "Vis Select")
			}

			editStartupProfiles("Update State")
		}
		else if (arguments[1] = "ProfileSave") {
			if (selectedProfile > 1) {
				if saveProfile(profiles[selectedProfile - 1]) {
					profilesListView.Modify(selectedProfile, "", profilesEditorGui["profileNameEdit"].Text, profilesEditorGui["profileModeDropDown"].Text)

					return true
				}
				else {
					profilesListView.Modify(selectedProfile, "Select")

					return false
				}
			}
		}
		else if (arguments[1] = "ManageSession") {
			if editStartupProfiles(kEvent, "ProfileSave") {
				profilesEditorGui.Block()

				try {
					if FileExist(kUserConfigDirectory . "Team Server.ini")
						lastModified := FileGetTime(kUserConfigDirectory . "Team Server.ini", "M")
					else
						lastModified := false

					manageTeams(profilesEditorGui)

					if (FileExist(kUserConfigDirectory . "Team Server.ini") && (!lastModified || (lastModified != FileGetTime(kUserConfigDirectory . "Team Server.ini", "M")))) {
						profile := profiles[selectedProfile - 1]

						configuration := readMultiMap(kUserConfigDirectory . "Team Server.ini")

						if (getMultiMapValue(configuration, "Team Server", "Team.Identifier", false)
						 && getMultiMapValue(configuration, "Team Server", "Driver.Identifier", false)
						 && getMultiMapValue(configuration, "Team Server", "Session.Identifier", false)) {
							profile["Team.Mode"] := "Profile"
							profile["Server.URL"] :=  getMultiMapValue(configuration, "Team Server", "Server.URL")
							profile["Server.Token"] :=  getMultiMapValue(configuration, "Team Server", "Session.Token")
							profile["Team.Name"] :=  getMultiMapValue(configuration, "Team Server", "Team.Name")
							profile["Team.Identifier"] :=  getMultiMapValue(configuration, "Team Server", "Team.Identifier")
							profile["Driver.Name"] :=  getMultiMapValue(configuration, "Team Server", "Driver.Name")
							profile["Driver.Identifier"] :=  getMultiMapValue(configuration, "Team Server", "Driver.Identifier")
							profile["Session.Name"] :=  getMultiMapValue(configuration, "Team Server", "Session.Name")
							profile["Session.Identifier"] :=  getMultiMapValue(configuration, "Team Server", "Session.Identifier")

							profile := selectedProfile
							selectedProfile := false

							editStartupProfiles(kEvent, "ProfileLoad", profile)
						}
					}
				}
				catch Any as exception {
					logError(exception, true)

					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, translate("Cannot start the configuration tool - please check the installation..."), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)
				}
				finally {
					profilesEditorGui.Unblock()
				}
			}
		}
		else if (arguments[1] = "ManageDriver") {
			profilesEditorGui.Block()

			try {
				RunWait(kBinariesDirectory . "Race Settings.exe -Team")
			}
			catch Any as exception {
				logError(exception, true)

				OnMessage(0x44, translateOkButton)
				withBlockedWindows(MsgBox, substituteVariables(translate("Cannot start the Race Settings tool (%exePath%) - please check the configuration..."), {exePath: kBinariesDirectory . "Race Settings.exe"}), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)
			}
			finally {
				profilesEditorGui.Unblock()
			}
		}
		else if (arguments[1] = "Update") {
			if connected
				if (arguments[2] == "Team") {
					if ((teams.Count > 0) && (profilesEditorGui["profileTeamDropDown"].Value != 0)) {
						teamName := getKeys(teams)[profilesEditorGui["profileTeamDropDown"].Value]
						teamIdentifier := teams[teamName]

						exception := false

						try {
							drivers := loadDrivers(connector, teamIdentifier)
						}
						catch Any as e {
							drivers := CaseInsenseMap()

							exception := e
						}
					}
					else {
						teamName := ""
						teamIdentifier := false
						drivers := CaseInsenseMap()
					}

					if ((drivers.Count > 0) && (profilesEditorGui["profileDriverDropDown"].Value != 0)
											&& drivers.Has(profilesEditorGui["profileDriverDropDown"].Text))
						driverIdentifier := drivers[profilesEditorGui["profileDriverDropDown"].Text]
					else
						driverIdentifier := false

					names := getKeys(drivers)
					chosen := inList(getValues(drivers), driverIdentifier)

					if ((chosen == 0) && (names.Length > 0))
						chosen := 1

					if (chosen == 0) {
						theDriverName := ""
						driverIdentifier := false
					}
					else {
						theDriverName := names[chosen]
						driverIdentifier := drivers[theDriverName]
					}

					profilesEditorGui["profileDriverDropDown"].Delete()
					profilesEditorGui["profileDriverDropDown"].Add(names)
					profilesEditorGui["profileDriverDropDown"].Choose(chosen)

					try {
						sessions := loadSessions(connector, teamIdentifier)
					}
					catch Any as e {
						sessions := CaseInsenseMap()

						exception := e
					}

					if ((sessions.Count > 0) && (profilesEditorGui["profileSessionDropDown"].Value != 0)
											 && sessions.Has(profilesEditorGui["profileSessionDropDown"].Text))
						sessionIdentifier := sessions[profilesEditorGui["profileSessionDropDown"].Text]
					else
						sessionIdentifier := false

					names := getKeys(sessions)
					chosen := inList(getValues(sessions), sessionIdentifier)

					if ((chosen == 0) && (names.Length > 0))
						chosen := 1

					if (chosen == 0) {
						sessionName := ""
						sessionIdentifier := false
					}
					else {
						sessionName := names[chosen]
						sessionIdentifier := sessions[sessionName]
					}

					profilesEditorGui["profileSessionDropDown"].Delete()
					profilesEditorGui["profileSessionDropDown"].Add(names)
					profilesEditorGui["profileSessionDropDown"].Choose(chosen)

					if exception
						throw exception
				}
				else if (arguments[2] == "Driver") {
					if ((drivers.Count > 0) && (profilesEditorGui["profileDriverDropDown"].Value != 0)) {
						theDriverName := getKeys(drivers)[profilesEditorGui["profileDriverDropDown"].Value]
						driverIdentifier := drivers[theDriverName]
					}
					else {
						theDriverName := ""
						driverIdentifier := false
					}
				}
				else if (arguments[2] == "Session") {
					if ((sessions.Count > 0) && (profilesEditorGui["profileSessionDropDown"].Value != 0)) {
						sessionName := getKeys(sessions)[profilesEditorGui["profileSessionDropDown"].Value]
						sessionIdentifier := sessions[sessionName]
					}
					else {
						sessionName := ""
						sessionIdentifier := false
					}
				}
		}
		else if (arguments[1] = "Connect") {
			serverURL := profilesEditorGui["profileServerURLEdit"].Text
			serverToken := profilesEditorGui["profileServerTokenEdit"].Text

			if connector {
				if GetKeyState("Ctrl") {
					profilesEditorGui.Block()

					try {
						token := loginDialog(connector, serverURL, profilesEditorGui)

						if token {
							serverToken := token

							profilesEditorGui["profileServerTokenEdit"].Text := token
						}
						else
							return
					}
					finally {
						profilesEditorGui.Unblock()
					}
				}

				try {
					connector.Initialize(serverURL, serverToken)

					connection := connector.Connect(serverToken, SessionDatabase.ID, SessionDatabase.getUserName(), "Driver")

					if (connection && (connection != "")) {
						settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

						serverURLs := string2Values(";", getMultiMapValue(settings, "Team Server", "Server URLs", ""))

						if !inList(serverURLs, serverURL) {
							serverURLs.Push(serverURL)

							setMultiMapValue(settings, "Team Server", "Server URLs", values2String(";", serverURLs*))

							writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

							profilesEditorGui["profileServerURLEdit"].Delete()
							profilesEditorGui["profileServerURLEdit"].Add(serverURLs)
							profilesEditorGui["profileServerURLEdit"].Choose(inList(serverURLs, serverURL))
						}

						connector.ValidateSessionToken()

						if keepAliveTask
							keepAliveTask.stop()

						keepAliveTask := PeriodicTask(ObjBindMethod(connector, "KeepAlive", connection), 120000, kLowPriority)

						keepAliveTask.start()

						teams := loadTeams(connector)

						if ((teams.Count > 0) && (profilesEditorGui["profileTeamDropDown"].Value != 0)
											  && teams.Has(profilesEditorGui["profileTeamDropDown"].Text))
							teamIdentifier := teams[profilesEditorGui["profileTeamDropDown"].Text]
						else
							teamIdentifier := false

						names := getKeys(teams)
						chosen := inList(getValues(teams), teamIdentifier)

						if ((chosen == 0) && (names.Length > 0))
							chosen := 1

						if (chosen == 0) {
							teamName := ""
							teamIdentifier := false
						}
						else {
							teamName := names[chosen]
							teamIdentifier := teams[teamName]
						}

						profilesEditorGui["profileTeamDropDown"].Delete()
						profilesEditorGui["profileTeamDropDown"].Add(names)
						profilesEditorGui["profileTeamDropDown"].Choose(chosen)

						connected := true

						editStartupProfiles(kEvent, "Update", "Team")

						showMessage(translate("Successfully connected to the Team Server."))
					}
					else
						throw "Invalid or missing token..."
				}
				catch Any as exception {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)
				}
			}
		}
	}
	else if (launchPadOrCommand == "Update State") {
		if (profilesListView.GetNext() = 1)
			profilesListView.Modify(1, "-Select")

		checkedRows := []
		checked := profilesListView.GetNext(0, "C")

		while checked {
			checkedRows.Push(checked)

			checked := profilesListView.GetNext(checked, "C")
		}

		if (checkedRows.Length = 0) {
			profilesListView.Modify(1, "Check")

			checkedProfile := false
		}
		else if (checkedRows.Length > 1) {
			loop profilesListView.GetCount()
				profilesListView.Modify(A_Index, "-Check")

			if (inList(checkedRows, selectedProfile) &&  (checkedProfile != selectedProfile)) {
				profilesListView.Modify(selectedProfile, "Check")

				checkedProfile := selectedProfile
			}
			else {
				profilesListView.Modify(1, "Check")

				checkedProfile := false
			}
		}

		if profilesListView.GetNext()
			profilesListView.Modify(profilesListView.GetNext(), "", profilesEditorGui["profileNameEdit"].Text, profilesEditorGui["profileModeDropDown"].Text)

		profilesEditorGui["addProfileButton"].Enabled := true
		profilesEditorGui["profilesUploadButton"].Enabled := true
		profilesEditorGui["profilesDownloadButton"].Enabled := (profilesListView.GetCount() > 1)

		if (profilesListView.GetNext() > 1) {
			profilesEditorGui["deleteProfileButton"].Enabled := true
			profilesEditorGui["copyProfileButton"].Enabled := true

			profilesEditorGui["profileNameEdit"].Enabled := true
			profilesEditorGui["profileModeDropDown"].Enabled := true
			profilesEditorGui["profilePitwallDropDown"].Enabled := true

			profilesEditorGui["profileAutonomyDropDown"].Enabled := true

			for ignore, plugin in activeAssistants
				plugin[2].Enabled := true

			if (profilesEditorGui["profileModeDropDown"].Value = 2) {
				profile := profiles[selectedProfile - 1]

				profilesEditorGui["profileCredentialsDropDown"].Enabled := true

				if (profilesEditorGui["profileCredentialsDropDown"].Value = 0)
					profilesEditorGui["profileCredentialsDropDown"].Choose(2)

				profilesEditorGui["profileTeamButton"].Enabled := (profilesEditorGui["profileCredentialsDropDown"].Value = 2)
				profilesEditorGui["profileSessionButton"].Enabled := true

				if (profilesEditorGui["profileCredentialsDropDown"].Value = 1) {
					profilesEditorGui["profileServerURLEdit"].Enabled := true

					if ((profilesEditorGui["profileServerURLEdit"].Text = "") && (serverURLS.Length > 0))
						profilesEditorGui["profileServerURLEdit"].Text := serverURLs[1]

					profilesEditorGui["profileServerTokenEdit"].Enabled := true
					profilesEditorGui["profileConnectButton"].Enabled := true
					profilesEditorGui["profileTeamDropDown"].Enabled := true
					profilesEditorGui["profileDriverDropDown"].Enabled := true
					profilesEditorGui["profileSessionDropDown"].Enabled := true
				}
			}
		}
		else {
			loadFunctions(false)

			profilesEditorGui["deleteProfileButton"].Enabled := false
			profilesEditorGui["copyProfileButton"].Enabled := false

			profilesEditorGui["profileNameEdit"].Enabled := false
			profilesEditorGui["profileNameEdit"].Text := ""
			profilesEditorGui["profileModeDropDown"].Enabled := false
			profilesEditorGui["profileModeDropDown"].Choose(0)
			profilesEditorGui["profilePitwallDropDown"].Enabled := false
			profilesEditorGui["profilePitwallDropDown"].Choose(0)

			profilesEditorGui["profileAutonomyDropDown"].Enabled := false
			profilesEditorGui["profileAutonomyDropDown"].Choose(0)

			for ignore, plugin in activeAssistants {
				plugin[2].Enabled := false
				plugin[2].Choose(0)
			}
		}

		if hasTeamServer {
			if ((profilesListView.GetNext() <= 1) || (profilesEditorGui["profileModeDropDown"].Value != 2)) {
				profilesEditorGui["profileCredentialsDropDown"].Enabled := false
				profilesEditorGui["profileCredentialsDropDown"].Choose(0)
				profilesEditorGui["profileTeamButton"].Enabled := false
				profilesEditorGui["profileSessionButton"].Enabled := false
			}

			if (profilesEditorGui["profileCredentialsDropDown"].Value != 1) {
				profilesEditorGui["profileServerURLEdit"].Enabled := false
				profilesEditorGui["profileServerURLEdit"].Text := ""
				profilesEditorGui["profileServerTokenEdit"].Enabled := false
				profilesEditorGui["profileServerTokenEdit"].Value := ""
				profilesEditorGui["profileConnectButton"].Enabled := false
				profilesEditorGui["profileTeamDropDown"].Enabled := false
				profilesEditorGui["profileTeamDropDown"].Choose(0)
				profilesEditorGui["profileDriverDropDown"].Enabled := false
				profilesEditorGui["profileDriverDropDown"].Choose(0)
				profilesEditorGui["profileSessionDropDown"].Enabled := false
				profilesEditorGui["profileSessionDropDown"].Choose(0)

				if keepAliveTask {
					keepAliveTask.stop()

					keepAliveTask := false
				}
			}
		}
	}
	else {
		done := false
		selectedProfile := false
		checkedProfile := false
		keepAliveTask := false

		functions := []
		activeAssistants := []

		configuration := getControllerState(true, true)

		functions := availableFunctions(configuration, &hasTeamServer, &hasDrivingCoach, &hasRaceSpotter, &hasRaceStrategist, &hasRaceEngineer
													 , &hasMotionFeedback, &hasChassisVibration, &hasPedalVibration)

		if hasTeamServer {
			connector := false
			connected := false

			dllFile := (kBinariesDirectory . "Connectors\Team Server Connector.dll")

			try {
				if (!FileExist(dllFile)) {
					logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)

					throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
				}

				connector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
			}
			catch Any as exception {
				logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))

				showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}

		profilesEditorGui := Window({Descriptor: "Simulator Startup.Profiles", Options: "ToolWindow 0x400000"})

		profilesEditorGui.SetFont("Bold", "Arial")

		profilesEditorGui.Add("Text", "w408 Center H:Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(profilesEditorGui, "Simulator Startup.Profiles"))

		profilesEditorGui.SetFont("Norm", "Arial")

		profilesEditorGui.Add("Documentation", "x128 YP+20 w178 Center H:Center", translate("Startup Profiles")
							, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-profiles")

		profilesEditorGui.Add("Text", "x8 yp+26 w408 0x10")

		profilesEditorGui.SetFont("Norm", "Arial")

		x := 8
		y := 48
		width := 408

		x0 := x + 8
		x1 := x + 132

		w1 := width - (x1 - x + 8)

		w2 := w1 - 70

		x2 := x1 - 25

		w4 := w1 - 25
		x4 := x1 + w4 + 2

		w3 := Round(w4 / 2)
		x3 := x1 + w3 + 6

		x4 := x3 + 64

		x5 := x4 + 6
		x6 := x5 + 24
		x7 := x6 + 24

		profilesListView := profilesEditorGui.Add("ListView", "x" . x0 . " yp+10 w392 h146 Checked -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Name", "Mode"], translate))
		; profilesListView.OnEvent("Click", chooseProfile)
		; profilesListView.OnEvent("DoubleClick", chooseProfile)
		profilesListView.OnEvent("ItemCheck", chooseProfile)
		profilesListView.OnEvent("ItemSelect", selectProfile)

		profilesEditorGui.Add("Button", "x" . (x5 - 52) . " yp+150 w23 h23 Center +0x200 vprofilesUploadButton").OnEvent("Click", editStartupProfiles.Bind(kEvent, "ProfilesUpload"))
		setButtonIcon(profilesEditorGui["profilesUploadButton"], kIconsDirectory . "Upload.ico", 1, "L4 T4 R4 B4")
		profilesEditorGui.Add("Button", "x" . (x5 - 28) . " yp w23 h23 Center +0x200 vprofilesDownloadButton").OnEvent("Click", editStartupProfiles.Bind(kEvent, "ProfilesDownload"))
		setButtonIcon(profilesEditorGui["profilesDownloadButton"], kIconsDirectory . "Download.ico", 1, "L4 T4 R4 B4")

		profilesEditorGui.Add("Button", "x" . x5 . " yp w23 h23 X:Move Y:Move Center +0x200 vaddProfileButton").OnEvent("Click", editStartupProfiles.Bind(kEvent, "ProfileNew"))
		setButtonIcon(profilesEditorGui["addProfileButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		profilesEditorGui.Add("Button", "x" . x6 . " yp w23 h23 X:Move Y:Move Center +0x200 vcopyProfileButton").OnEvent("Click", editStartupProfiles.Bind(kEvent, "ProfileCopy"))
		setButtonIcon(profilesEditorGui["copyProfileButton"], kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")
		profilesEditorGui.Add("Button", "x" . x7 . " yp w23 h23 X:Move Y:Move Center +0x200 vdeleteProfileButton").OnEvent("Click", editStartupProfiles.Bind(kEvent, "ProfileDelete"))
		setButtonIcon(profilesEditorGui["deleteProfileButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		profilesEditorGui.Add("Text", "x" . x0 . " yp+30 w90 h23 +0x200", translate("Name"))
		profilesEditorGui.Add("Edit", "x" . x1 . " yp+1 w" . (392 - (x1 - x0)) . " vprofileNameEdit").OnEvent("Change", editStartupProfiles.Bind("Update State"))

		profilesEditorGui.Add("Text", "x" . x0 . " yp+24 w90 h23 +0x200", translate("Mode"))
		profilesEditorGui.Add("DropDownList", "x" . x1 . " yp+1 w" . w3 . " vprofileModeDropDown", collect(hasTeamServer ? ["Solo", "Team"] : ["Solo"], translate)).OnEvent("Change", editStartupProfiles.Bind("Update State"))

		profilesEditorGui.Add("Text", "x" . x0 . " yp+23 w90 h23 +0x200", translate("Control Center"))
		profilesEditorGui.Add("DropDownList", "x" . x1 . " yp+1 w" . w3 . " vprofilePitwallDropDown", collect(hasTeamServer ? ["None", "Practice Center", "Race Center", "Race Center Lite"] : ["None", "Practice Center"], translate))

		settingsTab := profilesEditorGui.Add("Tab3", "x" . x0 . " yp+30 w392 h180 Section", collect(hasTeamServer ? ["Assistants", "Team", "Functions"] : ["Assistants", "Functions"], translate))

		settingsTab.UseTab(1)

		profilesEditorGui.Add("Text", "x" . (x0 + 8) . " ys+36 w110 h23", translate("Autonomous Mode"))
		profilesEditorGui.Add("DropDownList", "x" . x1 . " yp-3 w" . w3 . " Choose3 vprofileAutonomyDropDown", collect(["Yes", "No", "Default"], translate))

		first := true

		for plugin, pluginConfiguration in getMultiMapValues(configuration, "Plugins")
			if inList(kRaceAssistants, plugin)
				if string2Values("|", pluginConfiguration)[1] {
					profilesEditorGui.Add("Text", "x" . (x0 + 8) . (first ? " yp+32" : " yp+27") . " w110 h23", translate(plugin))

					first := false

					activeAssistants.Push(Array(plugin, profilesEditorGui.Add("DropDownList", "x" . x1 . " yp-3 w" . w3 . " Choose4", collect(["Default", "Disabled", "Silent", "Muted", "Active"], translate))))
				}

		if hasTeamServer {
			settingsTab.UseTab(2)

			profilesEditorGui.Add("Text", "x" . (x0 + 8) . " ys+36 w90 h23 +0x200", translate("Credentials"))
			profilesEditorGui.Add("DropDownList", "x" . x1 . " yp w" . w3 . " vprofileCredentialsDropDown", collect(["Load from Profile", "Load from Settings"], translate)).OnEvent("Change", editStartupProfiles.Bind("Update State"))

			profilesEditorGui.Add("Button", "x" . ((x0 + 8) + 240) . " yp-1 w23 h23 Center +0x200 vprofileTeamButton").OnEvent("Click", editStartupProfiles.Bind(kEvent, "ManageDriver"))
			setButtonIcon(profilesEditorGui["profileTeamButton"], kIconsDirectory . "Pencil.ico", 1, "L4 T4 R4 B4")

			profilesEditorGui.Add("Button", "x" . ((x0 + 8) + 286) . " yp w86 h23 Center +0x200 vprofileSessionButton", translate("Manage...")).OnEvent("Click", editStartupProfiles.Bind(kEvent, "ManageSession"))

			serverURLs := string2Values(";", getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini"), "Team Server", "Server URLs", ""))

			profilesEditorGui.Add("Text", "x" . (x0 + 8) . " yp+30 w90 h23 +0x200", translate("Server URL"))
			profilesEditorGui.Add("ComboBox", "x" . x1 . " yp+1 w256 vprofileServerURLEdit", serverURLs)

			profilesEditorGui.Add("Text", "x" . (x0 + 8) . " yp+23 w90 h23 +0x200", translate("Session Token"))
			profilesEditorGui.Add("Edit", "x" . x1 . " yp w256 h21 vprofileServerTokenEdit")
			profilesEditorGui.Add("Button", "x" . (x1 - 24) . " yp-1 w23 h23 Center +0x200 vprofileConnectButton").OnEvent("Click", editStartupProfiles.Bind(kEvent, "Connect"))
			setButtonIcon(profilesEditorGui["profileConnectButton"], kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")

			profilesEditorGui.Add("Text", "x" . (x0 + 8) . " yp+30 w90 h23 +0x200", translate("Team / Driver"))
			profilesEditorGui.Add("DropDownList", "x" . x1 . " yp w" . w3 . " vprofileTeamDropDown").OnEvent("Change", editStartupProfiles.Bind(kEvent, "Update", "Team"))
			profilesEditorGui.Add("DropDownList", "x" . ((x0 + 8) + 243) . " yp w" . (w3 + 6) . " vprofileDriverDropDown").OnEvent("Change", editStartupProfiles.Bind(kEvent, "Update", "Driver"))

			profilesEditorGui.Add("Text", "x" . (x0 + 8) . " yp+24 w90 h23 +0x200", translate("Session"))
			profilesEditorGui.Add("DropDownList", "x" . x1 . " yp w" . w3 . " vprofileSessionDropDown").OnEvent("Change", editStartupProfiles.Bind(kEvent, "Update", "Session"))
		}

		settingsTab.UseTab(hasTeamServer ? 3 : 2)

		functionsListView := profilesEditorGui.Add("ListView", "x" . (x0 + 8) . " ys+36 w372 h134 -Multi -LV0x10 -LV0x20 AltSubmit NoSort NoSortHdr", collect(["Module", "Function"], translate))
		functionsListView .OnEvent("Click", chooseFunction)
		functionsListView .OnEvent("DoubleClick", chooseFunction)

		settingsTab.UseTab(0)

		profilesEditorGui.Add("Text", "x8 ys+190 w408 0x10")

		profilesEditorGui.Add("Button", "Default X130 YP+10 w80 vsaveButton", translate("Save")).OnEvent("Click", editStartupProfiles.Bind(kSave))
		profilesEditorGui.Add("Button", "X+10 w80", translate("&Cancel")).OnEvent("Click", editStartupProfiles.Bind(kCancel))

		loadProfiles()
		loadFunctions(false)

		editStartupProfiles("Update State")

		profilesEditorGui.Opt("+Owner" . launchPadOrCommand.Hwnd)

		launchPadOrCommand.Block()

		try {
			if getWindowPosition("Simulator Startup.Profiles", &x, &y)
				profilesEditorGui.Show("x" . x . " y" . y)
			else
				profilesEditorGui.Show()

			loop {
				Sleep(200)

				if GetKeyState("Ctrl")
					profilesEditorGui["saveButton"].Text := translate("Startup")
				else
					profilesEditorGui["saveButton"].Text := translate("Save")
			}
			until done

			profilesEditorGui.Destroy()
		}
		finally {
			launchPadOrCommand.Unblock()
		}

		if keepAliveTask
			keepAliveTask.stop()

		return ((done = "Startup") ? done : (done = kSave))
	}
}

manageTeams(ownerOrCommand, arguments*) {
	static done := false
	static teamManagerGui
	static teamManagerPanel

	if (ownerOrCommand == kClose)
		done := kClose
	else if (ownerOrCommand = "Update State") {
	}
	else {
		done := false

		teamManagerGui := Window({Descriptor: "Simulator Startup.Team Management", Options: "ToolWindow 0x400000"})

		teamManagerGui.SetFont("Bold", "Arial")

		teamManagerGui.Add("Text", "w508 Center H:Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(teamManagerGui, "Simulator Startup.Team Management"))

		teamManagerGui.SetFont("Norm", "Arial")

		teamManagerGui.Add("Documentation", "x174 YP+20 w178 Center H:Center", translate("Team Management")
						 , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#team-management")

		teamManagerGui.Add("Text", "x8 yp+26 w508 0x10")

		teamManagerPanel := TeamManagementPanel(TeamManagerOwner(teamManagerGui), kSimulatorConfiguration)

		teamManagerPanel.createGui(teamManagerPanel.Editor, 8, 64, 508, 500)

		Task.startTask(() => teamManagerPanel.connect(true, true), 2000, kLowPriority)

		teamManagerGui.Add("Text", "x8 y545 w508 0x10")

		teamManagerGui.Add("Button", "X220 YP+10 w80", translate("Close")).OnEvent("Click", manageTeams.Bind(kClose))

		manageTeams("Update State")

		teamManagerGui.Opt("+Owner" . ownerOrCommand.Hwnd)

		ownerOrCommand.Block()

		try {
			if getWindowPosition("Simulator Startup.Team Management", &x, &y)
				teamManagerGui.Show("x" . x . " y" . y)
			else
				teamManagerGui.Show()

			loop
				Sleep(200)
			until done

			teamManagerPanel.saveToConfiguration()

			teamManagerGui.Destroy()
		}
		finally {
			ownerOrCommand.Unblock()

			teamManagerPanel.disconnect()
		}
	}
}

loginDialog(connectorOrCommand := false, teamServerURL := false, owner := false, *) {
	local loginGui

	static name := ""
	static password := ""

	static result := false
	static nameEdit
	static passwordEdit

	if (connectorOrCommand == kOk)
		result := kOk
	else if (connectorOrCommand == kCancel)
		result := kCancel
	else {
		result := false

		loginGui := Window({Options: "0x400000"}, translate("Team Server"))

		loginGui.SetFont("Norm", "Arial")

		loginGui.Add("Text", "x16 y16 w90 h23 +0x200", translate("Server URL"))
		loginGui.Add("Text", "x110 yp w160 h23 +0x200", teamServerURL)

		loginGui.Add("Text", "x16 yp+30 w90 h23 +0x200", translate("Name"))
		nameEdit := loginGui.Add("Edit", "x110 yp+1 w160 h21", name)

		loginGui.Add("Text", "x16 yp+23 w90 h23 +0x200", translate("Password"))
		passwordEdit := loginGui.Add("Edit", "x110 yp+1 w160 h21 Password", password)

		loginGui.Add("Button", "x60 yp+35 w80 h23 Default", translate("Ok")).OnEvent("Click", loginDialog.Bind(kOk))
		loginGui.Add("Button", "x146 yp w80 h23", translate("&Cancel")).OnEvent("Click", loginDialog.Bind(kCancel))

		loginGui.Opt("+Owner" . owner.Hwnd)

		loginGui.Show("AutoSize Center")

		while !result
			Sleep(100)

		try {
			if (result == kCancel)
				return false
			else if (result == kOk) {
				name := nameEdit.Text
				password := passwordEdit.Text

				try {
					connectorOrCommand.Initialize(teamServerURL)

					connectorOrCommand.Login(name, password)

					return connectorOrCommand.GetSessionToken()
				}
				catch Any as exception {
					OnMessage(0x44, translateOkButton)
					withBlockedWindows(MsgBox, (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)

					return false
				}
			}
		}
		finally {
			loginGui.Destroy()
		}
	}
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
	global gStartupProfile

	local icon := kIconsDirectory . "Startup.ico"
	local noLaunch, ignore, startup

	unblockExecutables() {
		local progress := 0
		local ignore, directory, currentDirectory, pid

		if !A_IsAdmin {
			if RegExMatch(DllCall("GetCommandLine", "Str"), " /restart(?!\S)") {
				OnMessage(0x44, translateOkButton)
				withBlockedWindows(MsgBox, translate("Simulator Controller cannot request Admin privileges. Please enable User Account Control."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				ExitApp(0)
			}

			if A_IsCompiled
				Run("*RunAs `"" . A_ScriptFullPath . "`" /restart -Unblock")
			else
				Run("*RunAs `"" . A_AhkPath . "`" `"" . A_ScriptFullPath . "`" /restart -Unblock")

			ExitApp(0)
		}

		showProgress({color: "Green", title: translate("Unblocking Applications and DLLs")})

		try {
			for ignore, directory in [kBinariesDirectory, kResourcesDirectory . "Setup\Installer\"
									, kResourcesDirectory . "Setup\Plugins\"] {
				currentDirectory := A_WorkingDir

				try {
					SetWorkingDir(directory)

					Run("Powershell -Command Get-ChildItem -Path '.' -Recurse | Unblock-File", , "Hide", &pid)

					fixIE(11, "Session Database.exe")
					fixIE(11, "Setup Workbench.exe")
					fixIE(11, "Race Reports.exe")
					fixIE(11, "Strategy Workbench.exe")
					fixIE(11, "Practice Center.exe")
					fixIE(11, "Race Center.exe")
					fixIE(10, "Simulator Setup.exe")
					fixIE(11, "System Monitor.exe")

					while ProcessExist(pid) {
						showProgress({progress: Min(100, progress++)})

						Sleep(50)
					}
				}
				catch Any as exception {
					logError(exception)
				}
				finally {
					SetWorkingDir(currentDirectory)
				}
			}

			while (progress++ <= 100) {
				showProgress({progress: progress})

				Sleep(50)
			}
		}
		catch Any as exception {
			logError(exception)
		}
		finally {
			hideProgress()

			if A_IsCompiled
				Run((!A_IsAdmin ? "*RunAs `"" : "`"") . A_ScriptFullPath . "`" /restart")
			else
				Run((!A_IsAdmin ? "*RunAs `"" : "`"") . A_AhkPath . "`" `"" . A_ScriptFullPath . "`" /restart")

			ExitApp(0)
		}
	}

	Hotkey("Escape", cancelStartup, "Off")

	TraySetIcon(icon, "1")
	A_IconTip := "Simulator Startup"

	if (inList(A_Args, "-Unblock") || (GetKeyState("Ctrl") && GetKeyState("Shift")))
		unblockExecutables()

	startup := inList(A_Args, "-Startup")

	if startup
		gStartupProfile := A_Args[startup + 1]

	try {
		startupApplication()

		noLaunch := inList(A_Args, "-NoLaunchPad")

		if ((noLaunch && !GetKeyState("Shift")) || (!noLaunch && GetKeyState("Shift")))
			startupSimulator()
		else {
			showSplashScreen("Logo")

			Task.startTask(hideSplashScreen, 2000)

			while launchPad()
				ignore := 1
		}
	}
	catch Any as exception {
		logError(exception, true)

		OnMessage(0x44, translateOkButton)
		withBlockedWindows(MsgBox, substituteVariables(translate("Cannot start %application% due to an internal error..."), {application: "Simulator Startup"}), translate("Error"), 262160)
		OnMessage(0x44, translateOkButton, 0)

		ExitApp(1)
	}

	if (!SimulatorStartup.Instance || SimulatorStartup.Instance.Finished)
		ExitApp(0)
}

cancelStartup(*) {
	local startupManager := SimulatorStartup.Instance
	local msgResult

	protectionOn()

	try {
		if startupManager {
			startupManager.hideSplashScreen()

			if !startupManager.Finished {
				OnMessage(0x44, translateYesNoButtons)
				msgResult := withBlockedWindows(MsgBox, translate("Cancel Startup?"), translate("Startup"), 262180)
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