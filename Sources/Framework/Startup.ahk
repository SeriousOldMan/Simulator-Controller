;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Functions                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Framework.ahk"


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
	global kSimulatorConfiguration, kVersion, kDatabaseDirectory, kAHKDirectory, kMSBuildDirectory, kNirCmd, kSox, kSilentMode

	local version, section, pid, path

	kSimulatorConfiguration := readMultiMap(kSimulatorConfigurationFile)

	if !FileExist(getFileName(kSimulatorConfigurationFile, kUserConfigDirectory))
		setLanguage(getSystemLanguage())
	else
		setLanguage(getMultiMapValue(kSimulatorConfiguration, "Configuration", "Language", getSystemLanguage()))

	version := readMultiMap(kHomeDirectory . "VERSION")
	section := getMultiMapValue(version, "Current", "Type", false)

	if section {
		kVersion := getMultiMapValue(version, section, "Version", false)

		if !kVersion
			kVersion := getMultiMapValue(version, "Release", "Version", "0.0.0.0-dev")
	}
	else
		kVersion := getMultiMapValue(version, "Current", "Version", getMultiMapValue(version, "Version", "Current", "0.0.0.0-dev"))

	pid := ProcessExist()

	logMessage(kLogOff, "-----------------------------------------------------------------")
	logMessage(kLogOff, translate("      Running ") . StrSplit(A_ScriptName, ".")[1] . " (" . kVersion . ") [" . pid . "]")
	logMessage(kLogOff, "-----------------------------------------------------------------")

	if (kSimulatorConfiguration.Count == 0)
		logMessage(kLogCritical, translate("No configuration found - please run the configuration tool"))

	path := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Session Database.ini"), "Database", "Path")
	if path {
		kDatabaseDirectory := (normalizeDirectoryPath(path) . "\")

		DirCreate(kDatabaseDirectory . "Community")
		DirCreate(kDatabaseDirectory . "User")

		logMessage(kLogInfo, translate("Session database path set to ") . path)
	}

    logMessage(kLogInfo, translate("Installation path set to ") . kHomeDirectory)

	path := getMultiMapValue(kSimulatorConfiguration, "Configuration", "AHK Path")
	if path {
		kAHKDirectory := path . "\"

		logMessage(kLogInfo, translate("AutoHotkey path set to ") . path)
	}

	path := getMultiMapValue(kSimulatorConfiguration, "Configuration", "MSBuild Path")
	if path {
		kMSBuildDirectory := path . "\"

		logMessage(kLogInfo, translate("MSBuild path set to ") . path)
	}

	path := getMultiMapValue(kSimulatorConfiguration, "Configuration", "NirCmd Path")
	if path {
		kNirCmd := path . "\NirCmd.exe"

		logMessage(kLogInfo, translate("NirCmd executable set to ") . kNirCmd)
	}
	else
		logMessage(kLogWarn, translate("NirCmd executable not configured"))

	path := getMultiMapValue(kSimulatorConfiguration, "Voice Control", "SoX Path")
	if path {
		kSoX := path . "\sox.exe"

		logMessage(kLogInfo, translate("SoX executable set to ") . kSox)
	}
	else
		logMessage(kLogWarn, translate("SoX executable not configured"))

	kSilentMode := getMultiMapValue(kSimulatorConfiguration, "Configuration", "Silent Mode", false)

	if (!A_IsCompiled || getMultiMapValue(kSimulatorConfiguration, "Configuration", "Debug", false))
		setDebug(true)

	if !isDevelopment()
		setLogLevel(inList(kLogLevelNames, getMultiMapValue(kSimulatorConfiguration, "Configuration", "Log Level", "Warn")))
}

initializeEnvironment() {
	global kSimulatorConfiguration, kDetachedInstallation
	local installOptions, installLocation, install, newID, idFileName, ID, ticks, wait, major, minor, msgResult

	if !isDebug() {
		if FileExist(kConfigDirectory . "Simulator Controller.install") {
			installOptions := readMultiMap(kConfigDirectory . "Simulator Controller.install")
			installLocation := getMultiMapValue(installOptions, "Install", "Location", "..\")

			if ((installLocation = "*") || (installLocation = "..\"))
				kDetachedInstallation := true
		}

		if !isDetachedInstallation() {
			installLocation := RegRead("HKLM\" . kUninstallKey, "InstallLocation", "")

			installOptions := readMultiMap(kUserConfigDirectory . "Simulator Controller.install")
			installLocation := getMultiMapValue(installOptions, "Install", "Location", installLocation)

			install := (installLocation && (installLocation != "") && (InStr(kHomeDirectory, installLocation) != 1))
			install := (install || !installLocation || (installLocation = ""))

			if (install && !inList(["Simulator Tools", "Simulator Download", "Database Update"], StrSplit(A_ScriptName, ".")[1])) {
				kSimulatorConfiguration := readMultiMap(kSimulatorConfigurationFile)

				if !FileExist(getFileName(kSimulatorConfigurationFile, kUserConfigDirectory))
					setLanguage(getSystemLanguage())
				else
					setLanguage(getMultiMapValue(kSimulatorConfiguration, "Configuration", "Language", getSystemLanguage()))

				OnMessage(0x44, translateYesNoButtons)
				msgResult := MsgBox(translate("You have to install Simulator Controller before starting any of the applications. Do you want run the Setup now?"), translate("Installation"), 262436)
				OnMessage(0x44, translateYesNoButtons, 0)

				if (msgResult = "Yes")
					Run("*RunAs " . kBinariesDirectory . "Simulator Tools.exe")

				ExitApp(0)
			}
		}
	}

	DirCreate(A_MyDocuments . "\Simulator Controller")
	DirCreate(kUserHomeDirectory . "Config")
	DirCreate(kUserHomeDirectory . "Rules")
	DirCreate(kUserHomeDirectory . "Garage")
	DirCreate(kUserHomeDirectory . "Garage\Definitions")
	DirCreate(kUserHomeDirectory . "Garage\Rules")
	DirCreate(kUserHomeDirectory . "Garage\Definitions\Cars")
	DirCreate(kUserHomeDirectory . "Garage\Rules\Cars")
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


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeEnvironment()
loadSimulatorConfiguration()