;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Functions                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Messages.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kUninstallKey := "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SimulatorController"

global kDetachedInstallation := false


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

loadSimulatorConfiguration() {
	global kVersion, kDatabaseDirectory, kAHKDirectory, kMSBuildDirectory, kNirCmd, kSox, kSilentMode

	local version, section, pid, path

	kSimulatorConfiguration := readConfiguration(kSimulatorConfigurationFile)

	if !FileExist(getFileName(kSimulatorConfigurationFile, kUserConfigDirectory))
		setLanguage(getSystemLanguage())
	else
		setLanguage(getConfigurationValue(kSimulatorConfiguration, "Configuration", "Language", getSystemLanguage()))

	version := readConfiguration(kHomeDirectory . "VERSION")
	section := getConfigurationValue(version, "Current", "Type", false)

	if section {
		kVersion := getConfigurationValue(version, section, "Version", false)

		if !kVersion
			kVersion := getConfigurationValue(version, "Release", "Version", "0.0.0.0-dev")
	}
	else
		kVersion := getConfigurationValue(version, "Current", "Version", getConfigurationValue(version, "Version", "Current", "0.0.0.0-dev"))

	pid := ProcessExist()

	logMessage(kLogOff, "-----------------------------------------------------------------")
	logMessage(kLogOff, translate("      Running ") . StrSplit(A_ScriptName, ".")[1] . " (" . kVersion . ") [" . pid . "]")
	logMessage(kLogOff, "-----------------------------------------------------------------")

	if (kSimulatorConfiguration.Count == 0)
		logMessage(kLogCritical, translate("No configuration found - please run the configuration tool"))

	path := getConfigurationValue(readConfiguration(kUserConfigDirectory . "Session Database.ini"), "Database", "Path")
	if path {
		kDatabaseDirectory := (normalizeDirectoryPath(path) . "\")

		DirCreate(kDatabaseDirectory . "Community")
		DirCreate(kDatabaseDirectory . "User")

		logMessage(kLogInfo, translate("Session database path set to ") . path)
	}

    logMessage(kLogInfo, translate("Installation path set to ") . kHomeDirectory)

	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "AHK Path")
	if path {
		kAHKDirectory := path . "\"

		logMessage(kLogInfo, translate("AutoHotkey path set to ") . path)
	}
	/*
	else
		logMessage(kLogWarn, translate("AutoHotkey path not set"))
	*/

	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "MSBuild Path")
	if path {
		kMSBuildDirectory := path . "\"

		logMessage(kLogInfo, translate("MSBuild path set to ") . path)
	}
	/*
	else
		logMessage(kLogWarn, translate("MSBuild path not set"))
	*/

	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "NirCmd Path")
	if path {
		kNirCmd := path . "\NirCmd.exe"

		logMessage(kLogInfo, translate("NirCmd executable set to ") . kNirCmd)
	}
	else
		logMessage(kLogWarn, translate("NirCmd executable not configured"))

	path := getConfigurationValue(kSimulatorConfiguration, "Voice Control", "SoX Path")
	if path {
		kSoX := path . "\sox.exe"

		logMessage(kLogInfo, translate("SoX executable set to ") . kSox)
	}
	else
		logMessage(kLogWarn, translate("SoX executable not configured"))

	kSilentMode := getConfigurationValue(kSimulatorConfiguration, "Configuration", "Silent Mode", false)

	if (!A_IsCompiled || getConfigurationValue(kSimulatorConfiguration, "Configuration", "Debug", false))
		setDebug(true)

	setLogLevel(inList(kLogLevelNames, getConfigurationValue(kSimulatorConfiguration, "Configuration", "Log Level", "Warn")))
}

initializeEnvironment() {
	global kDetachedInstallation
	local installOptions, installLocation, install, title, newID, idFileName, ID, ticks, wait, major, minor, msgResult

	if A_IsCompiled {
		if FileExist(kConfigDirectory . "Simulator Controller.install") {
			installOptions := readConfiguration(kConfigDirectory . "Simulator Controller.install")
			installLocation := getConfigurationValue(installOptions, "Install", "Location", "..\")

			if ((installLocation = "*") || (installLocation = "..\"))
				kDetachedInstallation := true
		}

		if !isDetachedInstallation() {
			installLocation := RegRead("HKLM\" . kUninstallKey, "InstallLocation")

			installOptions := readConfiguration(kUserConfigDirectory . "Simulator Controller.install")
			installLocation := getConfigurationValue(installOptions, "Install", "Location", installLocation)

			install := (installLocation && (installLocation != "") && (InStr(kHomeDirectory, installLocation) != 1))
			install := (install || !installLocation || (installLocation = ""))

			if (install && !inList(["Simulator Tools", "Simulator Download", "Database Update"], StrSplit(A_ScriptName, ".")[1])) {
				kSimulatorConfiguration := readConfiguration(kSimulatorConfigurationFile)

				if !FileExist(getFileName(kSimulatorConfigurationFile, kUserConfigDirectory))
					setLanguage(getSystemLanguage())
				else
					setLanguage(getConfigurationValue(kSimulatorConfiguration, "Configuration", "Language", getSystemLanguage()))

				OnMessage(0x44, translateMsgBoxButtons.Bind(["Yes", "No"]))
				title := translate("Installation")
				msgResult := MsgBox(translate("You have to install Simulator Controller before starting any of the applications. Do you want run the Setup now?"), title, 262436)
				OnMessage(0x44)

				if (msgResult = "Yes")
					Run("*RunAs " . kBinariesDirectory . "Simulator Tools.exe")

				ExitApp(0)
			}
		}
	}

	DirCreate(A_MyDocuments . "\Simulator Controller")
	DirCreate(kUserHomeDirectory . "Config")
	DirCreate(kUserHomeDirectory . "Rules")
	DirCreate(kUserHomeDirectory . "Advisor")
	DirCreate(kUserHomeDirectory . "Advisor\Definitions")
	DirCreate(kUserHomeDirectory . "Advisor\Rules")
	DirCreate(kUserHomeDirectory . "Advisor\Definitions\Cars")
	DirCreate(kUserHomeDirectory . "Advisor\Rules\Cars")
	DirCreate(kUserHomeDirectory . "Validators")
	DirCreate(kUserHomeDirectory . "Logs")
	DirCreate(kUserHomeDirectory . "Splash Media")
	DirCreate(kUserHomeDirectory . "Screen Images")
	DirCreate(kUserHomeDirectory . "Plugins")
	DirCreate(kUserHomeDirectory . "Translations")
	DirCreate(kUserHomeDirectory . "Grammars")
	DirCreate(kUserHomeDirectory . "Simulator Data")
	DirCreate(kUserHomeDirectory . "Temp")
	DirCreate(kDatabaseDirectory . "Community")
	DirCreate(kDatabaseDirectory . "User")

	if FileExist(kResourcesDirectory . "Templates") {
		if !FileExist(A_MyDocuments . "\Simulator Controller\Plugins\Controller Plugins.ahk")
			FileCopy(kResourcesDirectory . "Templates\Controller Plugins.ahk", A_MyDocuments . "\Simulator Controller\Plugins")

		if !FileExist(A_MyDocuments . "\Simulator Controller\Plugins\Configuration Plugins.ahk")
			FileCopy(kResourcesDirectory . "Templates\Configuration Plugins.ahk", A_MyDocuments . "\Simulator Controller\Plugins")

		if !FileExist(kUserConfigDirectory . "Race.settings")
			FileCopy(kResourcesDirectory . "Templates\Race.settings", kUserConfigDirectory)
	}

	newID := !FileExist(kUserConfigDirectory . "ID")

	if !newID {
		idFileName := kUserConfigDirectory . "ID"

		ID := StrSplit(FileRead(idFileName), "`n", "`r")[1]

		newID := ((ID = false) || (Trim(ID) = ""))
	}

	if newID {
		ID := createGUID()

		deleteFile(kUserConfigDirectory . "ID")

		FileAppend(ID, kUserConfigDirectory . "ID")
	}

	if !FileExist(kDatabaseDirectory . "ID")
		FileCopy(kUserConfigDirectory . "ID", kDatabaseDirectory . "ID")

	if (!FileExist(kUserConfigDirectory . "UPDATES") && FileExist(kResourcesDirectory . "Templates"))
		FileCopy(kResourcesDirectory . "Templates\UPDATES", kUserConfigDirectory)

	registerMessageHandler("Core", functionMessageHandler)
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

isDetachedInstallation() {
	return kDetachedInstallation
}

getControllerState(configuration := "__Undefined__") {
	local load := true
	local pid, tries, options, exePath, fileName

	if (configuration == false)
		load := false
	else if (configuration = kUndefined)
		configuration := false

	pid := ProcessExist("Simulator Controller.exe")

	if (load && !pid && (configuration || !FileExist(kTempDirectory . "Simulator Controller.state")))
		try {
			if configuration {
				fileName := temporaryFileName("Config", "ini")

				writeConfiguration(fileName, configuration)

				options := (" -Configuration """ . fileName . """")
			}
			else
				options := ""

			exePath := ("`"" . kBinariesDirectory . "Simulator Controller.exe`" -NoStartup -NoUpdate" .  options)

			Run(exePath, kBinariesDirectory, , &pid)

			Sleep(1000)

			tries := 30

			while (tries > 0) {
				Sleep(200)

				if !ProcessExist(pid)
					break
			}

			if configuration
				deleteFile(fileName)
		}
		catch exception {
			logMessage(kLogCritical, translate("Cannot start Simulator Controller (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

			return newConfiguration()
		}


	return readConfiguration(kTempDirectory . "Simulator Controller.state")
}

exit() {
	ExitApp(0)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeEnvironment()
loadSimulatorConfiguration()