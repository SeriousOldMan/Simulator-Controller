;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Functions                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Task.ahk"
#Include "..\Framework\Extensions\Messages.ahk"
#Include "..\Framework\Extensions\FTP.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kGuardExit := true


;;;-------------------------------------------------------------------------;;;
;;;                        Internal Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kUninstallKey := "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SimulatorController"

global kDetachedInstallation := false
global kProperInstallation := true


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

loadSimulatorConfiguration() {
	global kSimulatorConfiguration, kVersion, kDatabaseDirectory, kAHKDirectory, kMSBuildDirectory, kNirCmd, kSox, kSilentMode, kDiagnosticsStartup

	local appName := StrSplit(A_ScriptName, ".")[1]
	local packageInfo, type, pid, path, argIndex, settings, usage, lastModified, ID, fileName

	if kLogStartup
		logMessage(kLogOff, "Loading configuration...")

	checkInstallation(components) {
		local component, version, ignore, part, type, installedVersion

		for component, version in components {
			path := Trim(getMultiMapValue(packageInfo, "Components", component . "." . version . ".Path", ""))

			if (path && (path != "") && (path != "."))
				path := (kHomeDirectory . path . "\")
			else
				path := kHomeDirectory

			if !FileExist(path)
				return false

			for ignore, part in string2Values(",", getMultiMapValue(packageInfo, "Components", component . "." . version . ".Content")) {
				type := FileExist(path . part)

				if !type
					return false
				else if InStr(type, "D") {
					installedVersion := getMultiMapValue(readMultiMap(path . part . "\VERSION"), "Component", "Version", false)

					if (installedVersion != version)
						return false
				}
			}
		}

		return true
	}

	if kLogStartup
		logMessage(kLogOff, "Checking downloadable component versions...")

	argIndex := inList(A_Args, "-Configuration")

	if argIndex {
		kSimulatorConfiguration := readMultiMap(A_Args[argIndex + 1])

		setLanguage(getMultiMapValue(kSimulatorConfiguration, "Configuration", "Language", getSystemLanguage()))
	}
	else {
		kSimulatorConfiguration := readMultiMap(kConfigDirectory . "Simulator Configuration.ini")

		addMultiMapValues(kSimulatorConfiguration, readMultiMap(kSimulatorConfigurationFile))

		if !FileExist(getFileName(kSimulatorConfigurationFile, kUserConfigDirectory))
			setLanguage(getSystemLanguage())
		else
			setLanguage(getMultiMapValue(kSimulatorConfiguration, "Configuration", "Language", getSystemLanguage()))
	}

	packageInfo := readMultiMap(kHomeDirectory . "VERSION")
	type := getMultiMapValue(packageInfo, "Current", "Type", false)

	if type {
		if (inList(kForegroundApps, appName) && !inList(A_Args, "-Repair"))
			if !checkInstallation(string2Map(",", "->", getMultiMapValue(packageInfo, type, "Components", ""))) {
				Run("`"" . kBinariesDirectory . "Simulator Tools.exe`" -Repair -Start `"" . A_ScriptName . "`"")

				ExitApp(0)
			}

		kVersion := getMultiMapValue(packageInfo, type, "Version", false)

		if !kVersion
			kVersion := getMultiMapValue(packageInfo, "Release", "Version", "0.0.0.0-dev")
	}
	else
		kVersion := getMultiMapValue(packageInfo, "Current", "Version", getMultiMapValue(packageInfo, "Version", "Current", "0.0.0.0-dev"))

	if kLogStartup
		logMessage(kLogOff, "Starting common runtime...")

	pid := ProcessExist()

	logMessage(kLogOff, "---------------------------------------------------------------------")
	logMessage(kLogOff, translate("      Running ") . StrSplit(A_ScriptName, ".")[1] . " (" . kVersion . ") [" . pid . "]")
	logMessage(kLogOff, "---------------------------------------------------------------------")

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

	settings := readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))

	if (getMultiMapValue(settings, "Debug", "Debug", kUndefined) = kUndefined)
		if (!A_IsCompiled || getMultiMapValue(kSimulatorConfiguration, "Configuration", "Debug", false))
			setDebug(true)

	if (getMultiMapValue(settings, "Debug", "LogLevel", kUndefined) = kUndefined)
		if !isDevelopment()
			setLogLevel(inList(kLogLevelNames, getMultiMapValue(kSimulatorConfiguration, "Configuration", "Log Level", "Warn")))

	if getMultiMapValue(settings, "Diagnostics", "Usage", true) {
		if FileExist(kUserHomeDirectory . "Diagnostics\Usage.stat")
			usage := readMultiMap(kUserHomeDirectory . "Diagnostics\Usage.stat")
		else {
			usage := newMultiMap()

			setMultiMapValue(usage, "General", "Created", A_Now)
		}

		setMultiMapValue(usage, "Applications", appName, getMultiMapValue(usage, "Applications", appName, 0) + 1)

		writeMultiMap(kUserHomeDirectory . "Diagnostics\Usage.stat", usage)
	}

	if !FileExist(kUserHomeDirectory . "Diagnostics\UPLOAD")
		FileAppend(A_Now, kUserHomeDirectory . "Diagnostics\UPLOAD")

	lastModified := FileGetTime(kUserHomeDirectory . "Diagnostics\UPLOAD", "M")

	lastModified := DateAdd(lastModified, 1, "Days")

	if (lastModified < A_Now) {
		try {
			deleteFile(kUserHomeDirectory . "Diagnostics\UPLOAD")

			FileAppend(A_Now, kUserHomeDirectory . "Diagnostics\UPLOAD")
		}

		Task.startTask(() {
			ID := StrSplit(FileRead(kUserConfigDirectory . "ID"), "`n", "`r")[1]

			fileName := (ID . "." . A_Now . ".log")

			if ftpUpload("87.177.159.148", "SimulatorController", "Sc-1234567890-Sc", kUserHomeDirectory . "Diagnostics\Critical.log", "Diagnostics-Uploads/" . fileName)
				deleteFile(kUserHomeDirectory . "Diagnostics\Critical.log")

			ftpUpload("87.177.159.148", "SimulatorController", "Sc-1234567890-Sc", kUserHomeDirectory . "Diagnostics\Usage.stat", "Diagnostics-Uploads/" . ID . ".Usage.stat")
		}, 10000, kLowPriority)
	}

	if kLogStartup
		logMessage(kLogOff, "Common runtime started...")
}

initializeEnvironment() {
	global kSimulatorConfiguration, kDetachedInstallation, kProperInstallation, kTempDirectory, kProgramsDirectory
	local installOptions, installLocation, install, newID, idFileName, ID, ticks, wait, major, minor, msgResult, path, settings

	if kLogStartup
		logMessage(kLogOff, "Initializing environment...")

	settings := readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))

	path := getMultiMapValue(settings, "Locations", "Temp", false)
	if path
		kTempDirectory := (normalizeDirectoryPath(path) . "\")

	path := getMultiMapValue(settings, "Locations", "Programs", false)
	if path
		kProgramsDirectory := (normalizeDirectoryPath(path) . "\")

	if !isDebug() {
		if FileExist(kConfigDirectory . "Simulator Controller.install") {
			installOptions := readMultiMap(kConfigDirectory . "Simulator Controller.install")
			installLocation := getMultiMapValue(installOptions, "Install", "Location", "..\")

			if ((installLocation = "*") || (installLocation = "..\"))
				kDetachedInstallation := true
		}

		if !isDetachedInstallation() {
			if kLogStartup
				logMessage(kLogOff, "Ensuring correct installation...")

			installLocation := RegRead("HKLM\" . kUninstallKey, "InstallLocation", "")

			installOptions := readMultiMap(kUserConfigDirectory . "Simulator Controller.install")
			installLocation := getMultiMapValue(installOptions, "Install", "Location", installLocation)

			install := (installLocation && (installLocation != "") && (InStr(kHomeDirectory, installLocation) != 1))
			install := (install || !installLocation || (installLocation = ""))

			if (install || inList(A_Args, "-Repair"))
				kProperInstallation := false

			if (!isProperInstallation() && inList(kForegroundApps, StrSplit(A_ScriptName, ".")[1])) {
				kSimulatorConfiguration := readMultiMap(kSimulatorConfigurationFile)

				if !FileExist(getFileName(kSimulatorConfigurationFile, kUserConfigDirectory))
					setLanguage(getSystemLanguage())
				else
					setLanguage(getMultiMapValue(kSimulatorConfiguration, "Configuration", "Language", getSystemLanguage()))

				OnMessage(0x44, translateYesNoButtons)
				msgResult := withBlockedWindows(MsgBox, translate("You have to install Simulator Controller before starting any of the applications. Do you want run the Setup now?"), translate("Installation"), 262436)
				OnMessage(0x44, translateYesNoButtons, 0)

				if (msgResult = "Yes")
					Run((!A_IsAdmin ? "*RunAs `"" : "`"") . kBinariesDirectory . "Simulator Tools.exe`"")

				ExitApp(0)
			}
		}
	}

	if kLogStartup
		logMessage(kLogOff, "Preparing standard folders...")

	DirCreate(A_MyDocuments . "\Simulator Controller")
	DirCreate(kUserHomeDirectory . "Config")
	DirCreate(kUserHomeDirectory . "Actions")
	DirCreate(kUserHomeDirectory . "Rules")
	DirCreate(kUserHomeDirectory . "Scripts")
	DirCreate(kUserHomeDirectory . "Garage")
	DirCreate(kUserHomeDirectory . "Garage\Definitions")
	DirCreate(kUserHomeDirectory . "Garage\Rules")
	DirCreate(kUserHomeDirectory . "Garage\Definitions\Cars")
	DirCreate(kUserHomeDirectory . "Garage\Rules\Cars")
	DirCreate(kUserHomeDirectory . "Validators")
	DirCreate(kUserHomeDirectory . "Logs")
	DirCreate(kUserHomeDirectory . "Diagnostics")
	DirCreate(kUserHomeDirectory . "Sounds")
	DirCreate(kUserHomeDirectory . "Splash Media")
	DirCreate(kUserHomeDirectory . "Screen Images")
	DirCreate(kUserHomeDirectory . "Plugins")
	DirCreate(kUserHomeDirectory . "Translations")
	DirCreate(kUserHomeDirectory . "Grammars")
	DirCreate(kUserHomeDirectory . "Simulator Data")
	DirCreate(kDatabaseDirectory . "Community")
	DirCreate(kDatabaseDirectory . "User")
	DirCreate(kTempDirectory)
	DirCreate(kProgramsDirectory)

	if FileExist(kResourcesDirectory . "Templates") {
		if !FileExist(A_MyDocuments . "\Simulator Controller\Plugins\Controller Plugins.ahk")
			FileCopy(kResourcesDirectory . "Templates\Controller Plugins.ahk", A_MyDocuments . "\Simulator Controller\Plugins")

		if !FileExist(A_MyDocuments . "\Simulator Controller\Plugins\Configuration Plugins.ahk")
			FileCopy(kResourcesDirectory . "Templates\Configuration Plugins.ahk", A_MyDocuments . "\Simulator Controller\Plugins")

		if !FileExist(A_MyDocuments . "\Simulator Controller\Plugins\Simulator Providers.ahk")
			FileCopy(kResourcesDirectory . "Templates\Simulator Providers.ahk", A_MyDocuments . "\Simulator Controller\Plugins")
	}

	newID := !FileExist(kUserConfigDirectory . "ID")

	if !newID {
		idFileName := kUserConfigDirectory . "ID"

		try {
			ID := StrSplit(FileRead(idFileName), "`n", "`r")[1]

			newID := ((ID = false) || (Trim(ID) = ""))
		}
		catch Any {
			newID := true
		}
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

isProperInstallation() {
	return kProperInstallation
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeEnvironment()
loadSimulatorConfiguration()