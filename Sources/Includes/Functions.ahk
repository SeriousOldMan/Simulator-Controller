;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Functions                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Constants.ahk
#Include ..\Includes\Variables.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Libraries\Messages.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kUninstallKey := "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SimulatorController"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vDetachedInstallation := false

global vDebug := false
global vLogLevel := kLogWarn

global vTargetLanguageCode := "en"

global vSplashCounter := 0
global vLastImage
global vVideoPlayer
global vSongIsPlaying := false

global vProgressIsOpen := false
global vProgressBar
global vProgressTitle
global vProgressMessage

global vTrayMessageDuration := false

global vHasTrayMenu := false


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

doApplications(applications, callback) {
	local ignore, application

	for ignore, application in applications {
		if !InStr(application, ".exe")
			application .= ".exe"

		Process Exist, %application%

		if ErrorLevel
			%callback%(ErrorLevel)
	}
}

broadcastMessage(applications, message, arguments*) {
	if (arguments.Length() > 0)
		doApplications(applications, Func("sendMessage").Bind(kFileMessage, "Core", message . ":" . values2String(";", arguments*)))
	else
		doApplications(applications, Func("sendMessage").Bind(kFileMessage, "Core", message))

}

exitApplication() {
	ExitApp 0
}

moveHTMLViewer() {
	moveByMouse("HV", "HTML Viewer")
}

dismissHTMLViewer() {
	viewHTML(false)
}

consentDialog(id, consent := false) {
	local language, texts, chosen, x, y, rootDirectory, ignore, section, keyValues, key, value

	static tyrePressuresConsentDropDown
	static carSetupsConsentDropDown
	static closed

	if (id = "Close") {
		closed := true

		return
	}
	else
		closed := false

	texts := false

	for language, ignore in availableLanguages()
		for ignore, rootDirectory in [kTranslationsDirectory, kUserTranslationsDirectory]
			if FileExist(rootDirectory . "Consent." . language)
				if !texts
					texts := readConfiguration(rootDirectory . "Consent." . language)
				else
					for section, keyValues in readConfiguration(rootDirectory . "Consent." . language)
						for key, value in keyValues
							setConfigurationValue(texts, section, key, value)

	if !texts
		texts := readConfiguration(kTranslationsDirectory . "Consent.en")

	Gui CNS:-Border ; -Caption
	Gui CNS:Color, D0D0D0, D8D8D8
	Gui CNS:Font, s10 Bold
	Gui CNS:Add, Text, x0 y8 w800 +0x200 +0x1 BackgroundTrans gmoveConsentDialog, % translate("Modular Simulator Controller System")
	Gui CNS:Font, Norm, Arial
	Gui CNS:Add, Text, x0 y32 w800 h23 +0x200 +0x1 BackgroundTrans, % translate("Declaration of consent")

	Gui CNS:Add, Text, x8 y70 w784 h180 -VScroll +Wrap ReadOnly, % StrReplace(StrReplace(getConfigurationValue(texts, "Consent", "Introduction"), "``n", "`n"), "\<>", "=")

	Gui CNS:Add, Text, x8 y260 w450 h23 +0x200, % translate("Your database identification key is:")
	Gui CNS:Add, Edit, x460 y260 w332 h23 -VScroll ReadOnly Center, % id

	Gui CNS:Add, Text, x8 y300 w450 h23 +0x200, % translate("Do you want to share your local tyre pressure data?")

	chosen := inList(["Yes", "No", "Undecided"], getConfigurationValue(consent, "Consent", "Share Tyre Pressures", "Undecided"))
	Gui CNS:Add, DropDownList, x460 y300 w332 AltSubmit Choose%chosen% VtyrePressuresConsentDropDown, % values2String("|", map(["Yes", "No", "Ask again later..."], "translate")*)

	Gui CNS:Add, Text, x8 y324 w450 h23 +0x200, % translate("Do you want to share your local car setup data?")

	chosen := inList(["Yes", "No", "Undecided"], getConfigurationValue(consent, "Consent", "Share Car Setups", "Undecided"))
	Gui CNS:Add, DropDownList, x460 y324 w332 AltSubmit Choose%chosen% VcarSetupsConsentDropDown, % values2String("|", map(["Yes", "No", "Ask again later..."], "translate")*)

	Gui CNS:Add, Text, x8 y364 w784 h60 -VScroll +Wrap ReadOnly, % StrReplace(StrReplace(getConfigurationValue(texts, "Consent", "Information"), "``n", "`n"), "\<>", "=")

	Gui CNS:Add, Link, x8 y434 w784 h60 cRed -VScroll +Wrap ReadOnly, % StrReplace(StrReplace(getConfigurationValue(texts, "Consent", "Warning"), "``n", "`n"), "\<>", "=")

	Gui CNS:Add, Button, x368 y490 w80 h23 Default gcloseConsentDialog, % translate("Save")

	Gui CNS:+AlwaysOnTop

	if getWindowPosition("Consent", x, y)
		Gui CNS:Show, x%x% y%y%
	else
		Gui CNS:Show

	Gui CNS:Default

	loop
		Sleep 100
	until closed

	GuiControlGet tyrePressuresConsentDropDown
	GuiControlGet carSetupsConsentDropDown

	Gui CNS:Destroy

	return {TyrePressures: ["Yes", "No", "Retry"][tyrePressuresConsentDropDown], CarSetups: ["Yes", "No", "Retry"][carSetupsConsentDropDown]}
}

closeConsentDialog() {
	consentDialog("Close")
}

moveConsentDialog() {
	moveByMouse("CNS", "Consent")
}

changeProtection(up, critical := false, block := false) {
	static level := 0

	if (critical || block) {
		level += (up ? 1 : -1)

		if (level > 0) {
			if critical
				Critical 100

			if block
				BlockInput On
		}
		else if (level == 0) {
			if block
				BlockInput Off

			if critical
				Critical Off
		}
		else if (level <= 0)
			throw "Nesting error detected in changeProtection..."
	}
}

playThemeSong(songFile) {
	songFile := getFileName(songFile, kUserSplashMediaDirectory, kSplashMediaDirectory)

	if FileExist(songFile)
		SoundPlay %songFile%
}

readLanguage(targetLanguageCode) {
	local translations := {}
	local translation

	loop Read, % getFileName("Translations." . targetLanguageCode, kUserTranslationsDirectory, kTranslationsDirectory)
	{
		translation := StrSplit(A_LoopReadLine, "=>")

		if (translation[1] = targetLanguageCode)
			return translation[2]
	}

	if isDebug()
		throw "Inconsistent translation encountered for """ . targetLanguageCode . """ in readLanguage..."
	else
		logError("Inconsistent translation encountered for """ . targetLanguageCode . """ in readLanguage...")
}

initializeLoggingSystem() {
	OnError(Func("logError").Bind(true))
}

requestShareSessionDatabaseConsent() {
	local idFileName, ID, consent, request, countdown, newConsent, result

	if !inList(A_Args, "-Install") {
		if inList(["Simulator Startup", "Simulator Configuration", "Simulator Settings", "Session Database", "Simulator Setup"], StrSplit(A_ScriptName, ".")[1]) {
			idFileName := kUserConfigDirectory . "ID"

			FileReadLine ID, %idFileName%, 1

			consent := readConfiguration(kUserConfigDirectory . "CONSENT")

			request := ((consent.Count() == 0) || (ID != getConfigurationValue(consent, "General", "ID")) || getConfigurationValue(consent, "General", "ReNew", false))

			if !request {
				countdown := getConfigurationValue(consent, "General", "Countdown", kUndefined)

				if (countdown != kUndefined) {
					if (--countdown <= 0)
						request := true
					else {
						setConfigurationValue(consent, "General", "Countdown", countdown)

						writeConfiguration(kUserConfigDirectory . "CONSENT", consent)
					}
				}
			}

			if request {
				newConsent := newConfiguration()

				setConfigurationValue(newConsent, "General", "ID", id)
				setConfigurationValue(newConsent, "Consent", "Date", A_MM . "/" . A_DD . "/" . A_YYYY)

				if FileExist(kTranslationsDirectory . "Consent.ini")
					result := consentDialog(id, consent)
				else {
					result := {}

					result["TyrePressures"] := "Retry"
					result["CarSetups"] := "Retry"
				}

				switch result["TyrePressures"] {
					case "Yes":
						setConfigurationValue(newConsent, "Consent", "Share Tyre Pressures", "Yes")
					case "No":
						setConfigurationValue(newConsent, "Consent", "Share Tyre Pressures", "No")
					case "Retry":
						setConfigurationValue(newConsent, "Consent", "Share Tyre Pressures", "Undecided")
						setConfigurationValue(newConsent, "General", "Countdown", 10)
				}

				switch result["CarSetups"] {
					case "Yes":
						setConfigurationValue(newConsent, "Consent", "Share Car Setups", "Yes")
					case "No":
						setConfigurationValue(newConsent, "Consent", "Share Car Setups", "No")
					case "Retry":
						setConfigurationValue(newConsent, "Consent", "Share Car Setups", "Undecided")
						setConfigurationValue(newConsent, "General", "Countdown", 10)
				}

				writeConfiguration(kUserConfigDirectory . "CONSENT", newConsent)
			}
		}
	}
}

startDatabaseSynchronizer() {
	local idFileName, ID, dbIDFileName, dbID, shareTyrePressures, shareCarSetups, options, consent

	if (StrSplit(A_ScriptName, ".")[1] = "Simulator Startup") {
		Process Exist, Database Synchronizer.exe

		if !ErrorLevel {
			idFileName := kUserConfigDirectory . "ID"

			FileReadLine ID, %idFileName%, 1

			dbIDFileName := kDatabaseDirectory . "ID"

			FileReadLine dbID, %dbIDFileName%, 1

			if (ID = dbID) {
				consent := readConfiguration(kUserConfigDirectory . "CONSENT")

				shareTyrePressures := (getConfigurationValue(consent, "Consent", "Share Tyre Pressures", "No") = "Yes")
				shareCarSetups := (getConfigurationValue(consent, "Consent", "Share Car Setups", "No") = "Yes")

				options := ("-ID """ . ID . """ -Synchronize " . true)

				if shareTyrePressures
					options .= " -Pressures"

				if shareCarSetups
					options .= " -Setups"

				try {
					Run %kBinariesDirectory%Database Synchronizer.exe %options%
				}
				catch exception {
					logMessage(kLogCritical, translate("Cannot start Database Synchronizer - please rebuild the applications..."))

					showMessage(translate("Cannot start Database Synchronizer - please rebuild the applications...")
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}
		}
	}
}

checkForNews() {
	local check, lastModified, news, nr, html

	if vDetachedInstallation
		return

	if inList(kForegroundApps, StrSplit(A_ScriptName, ".")[1]) {
		check := !FileExist(kUserConfigDirectory . "NEWS")

		if !check {
			FileGetTime lastModified, %kUserConfigDirectory%NEWS, M

			EnvAdd lastModified, 1, Days

			check := (lastModified < A_Now)
		}

		if check {
			try {
				URLDownloadToFile https://www.dropbox.com/s/3zfsgiepo85ufw3/NEWS?dl=1, %kTempDirectory%NEWS

				if ErrorLevel
					throw "Error while downloading NEWS..."
			}
			catch exception {
				check := false
			}
		}

		if check {
			news := readConfiguration(kUserConfigDirectory . "NEWS")

			for nr, html in getConfigurationSectionValues(readConfiguration(kTempDirectory . "NEWS"), "News")
				if !getConfigurationValue(news, "News", nr, false)
					try {
						URLDownloadToFile %html%, %kTempDirectory%NEWS.htm

						if ErrorLevel
							throw "Error while downloading NEWS..."

						setConfigurationValue(news, "News", nr, true)

						writeConfiguration(kUserConfigDirectory . "NEWS", news)

						viewHTML(kTempDirectory . "NEWS.htm")
					}
					catch exception {
						logError(exception)
					}
		}
	}
}

checkForUpdates() {
	local check, lastModified, release, version, current, releasePostFix, currentPostFix, title, automaticUpdates
	local toolTargets, userToolTargets, userToolTargetsFile, updates, target, arguments, versionPostfix

	if vDetachedInstallation
		return

	if inList(kForegroundApps, StrSplit(A_ScriptName, ".")[1]) {
		check := !FileExist(kUserConfigDirectory . "VERSION")

		if !check {
			FileGetTime lastModified, %kUserConfigDirectory%VERSION, M

			EnvAdd lastModified, 1, Days

			check := (lastModified < A_Now)
		}

		if check {
			try {
				URLDownloadToFile https://www.dropbox.com/s/txa8muw9j3g66tl/VERSION?dl=1, %kUserConfigDirectory%VERSION

				if ErrorLevel
					throw "Error while checking VERSION..."
			}
			catch exception {
				check := false
			}
		}

		if check {
			release := readConfiguration(kUserConfigDirectory . "VERSION")
			version := getConfigurationValue(release, "Release", "Version", getConfigurationValue(release, "Version", "Release", false))

			if version {
				version := StrSplit(version, "-", , 2)
				current := StrSplit(kVersion, "-", , 2)

				versionPostfix := version[2]
				currentPostfix := current[2]

				version := string2Values(".", version[1])
				current := string2Values(".", current[1])

				while (version.Length() < current.Length())
					version.Push("0")

				while (current.Length() < version.Length())
					current.Push("0")

				version := values2String("", version*)
				current := values2String("", current*)

				if ((version > current) || ((version = current) && (versionPostfix != currentPostfix))) {
					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
					title := translate("Update")
					MsgBox 262436, %title%, % translate("A newer version of Simulator Controller is available. Do you want to download it now?")
					OnMessage(0x44, "")

					IfMsgBox Yes
					{
						automaticUpdates := getConfigurationValue(readConfiguration(kUserConfigDirectory . "Simulator Controller.install"), "Updates", "Automatic", true)

						if automaticUpdates
							Run *RunAs %kBinariesDirectory%Simulator Download.exe -NoUpdate -Download -Update -Start "%A_ScriptFullPath%"
						else
							Run https://github.com/SeriousOldMan/Simulator-Controller#latest-release-builds

						ExitApp 0
					}
					else if FileExist(kUserConfigDirectory . "VERSION")
						FileSetTime A_Now, %kUserConfigDirectory%VERSION
				}
			}
		}
	}

	toolTargets := readConfiguration(getFileName("Simulator Tools.targets", kConfigDirectory))

	userToolTargetsFile := getFileName("Simulator Tools.targets", kUserConfigDirectory)
	userToolTargets := readConfiguration(userToolTargetsFile)

	if (userToolTargets.Count() > 0) {
		setConfigurationSectionValues(userToolTargets, "Update", getConfigurationSectionValues(toolTargets, "Update", Object()))

		writeConfiguration(userToolTargetsFile, userToolTargets)
	}

	if (!inList(A_Args, "-NoUpdate") && inList(kForegroundApps, StrSplit(A_ScriptName, ".")[1])) {
		updates := readConfiguration(getFileName("UPDATES", kUserConfigDirectory))
restartUpdate:
		for target, arguments in getConfigurationSectionValues(toolTargets, "Update", Object())
			if !getConfigurationValue(updates, "Processed", target, false) {
				/*
				SoundPlay *32

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No", "Never"]))
				title := translate("Update")
				MsgBox 262179, %title%, % translate("The local configuration database needs an update. Do you want to run the update now?")
				OnMessage(0x44, "")

				IfMsgBox Cancel
				{
					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
					title := translate("Update")
					MsgBox 262436, %title%, % translate("Are you really sure, you want to skip the automated update procedure?")
					OnMessage(0x44, "")

					IfMsgBox Yes
					{
						for target, arguments in getConfigurationSectionValues(toolTargets, "Update", Object())
							setConfigurationValue(updates, "Processed", target, true)

						writeConfiguration(getFileName("UPDATES", kUserConfigDirectory), updates)

						break
					}

					Goto restartUpdate
				}

				IfMsgBox Yes
				{
					RunWait % kBinariesDirectory . "Simulator Tools.exe -Update"

					loadSimulatorConfiguration()

					break
				}

				IfMsgBox No
				{
					break
				}
				*/

				RunWait % kBinariesDirectory . "Simulator Tools.exe -Update"

				loadSimulatorConfiguration()

				break
			}
	}
}

loadSimulatorConfiguration() {
	local version, section, pid, path

	kSimulatorConfiguration := readConfiguration(kSimulatorConfigurationFile)

	if !FileExist(getFileName(kSimulatorConfigurationFile, kUserConfigDirectory))
		setLanguage(getSystemLanguage())
	else
		setLanguage(getConfigurationValue(kSimulatorConfiguration, "Configuration", "Language", getSystemLanguage()))

	version := readConfiguration(kHomeDirectory . "VERSION")
	section := getConfigurationValue(version, "Current", "Type", false)

	if section
		kVersion := getConfigurationValue(version, section, "Version", "0.0.0.0-dev")
	else
		kVersion := getConfigurationValue(version, "Current", "Version", getConfigurationValue(version, "Version", "Current", "0.0.0.0-dev"))

	Process Exist

	pid := ErrorLevel

	logMessage(kLogOff, "---------------------------------------------------------------")
	logMessage(kLogOff, translate("      Running ") . StrSplit(A_ScriptName, ".")[1] . " (" . kVersion . ") [" . pid . "]")
	logMessage(kLogOff, "---------------------------------------------------------------")

	if (kSimulatorConfiguration.Count() == 0)
		logMessage(kLogCritical, translate("No configuration found - please run the configuration tool"))

	path := getConfigurationValue(readConfiguration(kUserConfigDirectory . "Session Database.ini"), "Database", "Path")
	if path {
		kDatabaseDirectory := (normalizeDirectoryPath(path) . "\")

		FileCreateDir %kDatabaseDirectory%Community
		FileCreateDir %kDatabaseDirectory%User

		logMessage(kLogInfo, translate("Session database path set to ") . path)
	}

    /*
	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "Home Path")
	if path {
		kHomeDirectory := path . "\"

		logMessage(kLogInfo, translate("Installation path set to ") . path)
	}
	else
		logMessage(kLogWarn, translate("Installation path not set"))
	*/

	logMessage(kLogInfo, translate("Installation path set to ") . kHomeDirectory)

	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "AHK Path")
	if path {
		kAHKDirectory := path . "\"

		logMessage(kLogInfo, translate("AutoHotkey path set to ") . path)
	}
	else
		logMessage(kLogWarn, translate("AutoHotkey path not set"))

	path := getConfigurationValue(kSimulatorConfiguration, "Configuration", "MSBuild Path")
	if path {
		kMSBuildDirectory := path . "\"

		logMessage(kLogInfo, translate("MSBuild path set to ") . path)
	}
	else
		logMessage(kLogWarn, translate("MSBuild path not set"))

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

	vLogLevel := inList(["Info", "Warn", "Critical", "Off"], getConfigurationValue(kSimulatorConfiguration, "Configuration", "Log Level", "Warn"))
}

initializeEnvironment() {
	local installOptions, installLocation, install, title, newID, idFileName, ID, ticks, wait, major, minor

	"".base.__Get := "".base.__Set := "".base.__Call := Func("reportNonObjectUsage")

	if A_IsCompiled {
		if FileExist(kConfigDirectory . "Simulator Controller.install") {
			installOptions := readConfiguration(kConfigDirectory . "Simulator Controller.install")
			installLocation := getConfigurationValue(installOptions, "Install", "Location", "..\")

			if ((installLocation = "*") || (installLocation = "..\"))
				vDetachedInstallation := true
		}

		if !vDetachedInstallation {
			RegRead installLocation, HKLM, %kUninstallKey%, InstallLocation

			installOptions := readConfiguration(kUserConfigDirectory . "Simulator Controller.install")
			installLocation := getConfigurationValue(installOptions, "Install", "Location", installLocation)

			install := (installLocation && (installLocation != "") && (InStr(kHomeDirectory, installLocation) != 1))
			install := (install || !installLocation || (installLocation = ""))

			if (install && !inList(["Simulator Tools", "Simulator Download", "Database Update"], StrSplit(A_ScriptName, ".")[1])) {
				kSimulatorConfiguration := readConfiguration(kSimulatorConfigurationFile)

				if !FileExist(getFileName(kSimulatorConfigurationFile, kUserConfigDirectory))
					vTargetLanguageCode := getSystemLanguage()
				else
					vTargetLanguageCode := getConfigurationValue(kSimulatorConfiguration, "Configuration", "Language", getSystemLanguage())

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
				title := translate("Installation")
				MsgBox 262436, %title%, % translate("You have to install Simulator Controller before starting any of the applications. Do you want run the Setup now?")
				OnMessage(0x44, "")

				IfMsgBox Yes
					Run *RunAs %kBinariesDirectory%Simulator Tools.exe

				ExitApp 0
			}
		}
	}

	FileCreateDir %A_MyDocuments%\Simulator Controller
	FileCreateDir %kUserHomeDirectory%Config
	FileCreateDir %kUserHomeDirectory%Rules
	FileCreateDir %kUserHomeDirectory%Advisor
	FileCreateDir %kUserHomeDirectory%Advisor\Definitions
	FileCreateDir %kUserHomeDirectory%Advisor\Rules
	FileCreateDir %kUserHomeDirectory%Advisor\Definitions\Cars
	FileCreateDir %kUserHomeDirectory%Advisor\Rules\Cars
	FileCreateDir %kUserHomeDirectory%Validators
	FileCreateDir %kUserHomeDirectory%Logs
	FileCreateDir %kUserHomeDirectory%Splash Media
	FileCreateDir %kUserHomeDirectory%Screen Images
	FileCreateDir %kUserHomeDirectory%Plugins
	FileCreateDir %kUserHomeDirectory%Translations
	FileCreateDir %kUserHomeDirectory%Grammars
	FileCreateDir %kUserHomeDirectory%Simulator Data
	FileCreateDir %kUserHomeDirectory%Temp
	FileCreateDir %kDatabaseDirectory%Community
	FileCreateDir %kDatabaseDirectory%User

	if FileExist(kResourcesDirectory . "Templates") {
		if !FileExist(A_MyDocuments . "\Simulator Controller\Plugins\Controller Plugins.ahk")
			FileCopy %kResourcesDirectory%Templates\Controller Plugins.ahk, %A_MyDocuments%\Simulator Controller\Plugins

		if !FileExist(A_MyDocuments . "\Simulator Controller\Plugins\Configuration Plugins.ahk")
			FileCopy %kResourcesDirectory%Templates\Configuration Plugins.ahk, %A_MyDocuments%\Simulator Controller\Plugins

		if !FileExist(kUserConfigDirectory . "Race.settings")
			FileCopy %kResourcesDirectory%Templates\Race.settings, %kUserConfigDirectory%
	}

	newID := !FileExist(kUserConfigDirectory . "ID")

	if !newID {
		idFileName := kUserConfigDirectory . "ID"

		FileReadLine ID, %idFileName%, 1

		newID := ((ID = false) || (Trim(ID) = ""))
	}

	if newID {
		/*
		ticks := A_TickCount

		Random wait, 0, 100

		Random, , % Min(4294967295, A_TickCount)
		Random major, 0, 10000

		Sleep %wait%

		Random, , % Min(4294967295, A_TickCount)
		Random minor, 0, 10000

		ID := values2String(".", A_TickCount, major, minor)
		*/

		ID := createGUID()

		deleteFile(kUserConfigDirectory . "ID")

		FileAppend %ID%, % kUserConfigDirectory . "ID"
	}

	if !FileExist(kDatabaseDirectory . "ID")
		FileCopy %kUserConfigDirectory%ID, %kDatabaseDirectory%ID

	if (!FileExist(kUserConfigDirectory . "UPDATES") && FileExist(kResourcesDirectory . "Templates"))
		FileCopy %kResourcesDirectory%Templates\UPDATES, %kUserConfigDirectory%

	registerMessageHandler("Core", "functionMessageHandler")
}

getControllerActionDefinitions(type) {
	local fileName := ("Controller Action " . type . "." . getLanguage())
	local definitions, section, values, key, value

	if (!FileExist(kTranslationsDirectory . fileName) && !FileExist(kUserTranslationsDirectory . fileName))
		fileName := ("Controller Action " . type . ".en")

	definitions := readConfiguration(kTranslationsDirectory . fileName)

	for section, values in readConfiguration(kUserTranslationsDirectory . fileName)
		for key, value in values
			setConfigurationValue(definitions, section, key, value)

	return definitions
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

createGUID() {
	local guid, pGuid, sGuid, size

    VarSetCapacity(pGuid, 16, 0)

	if !(DllCall("ole32.dll\CoCreateGuid", "ptr", &pGuid)) {
        size := VarSetCapacity(sguid, (38 << !!A_IsUnicode) + 1, 0)

        if (DllCall("ole32.dll\StringFromGUID2", "ptr", &pGuid, "ptr", &sGuid, "int", size)) {
			guid := StrGet(&sGuid)

            return SubStr(SubStr(guid, 1, StrLen(guid) - 1), 2)
		}
    }

    return ""
}

setButtonIcon(buttonHandle, file, index := 1, options := "") {
	local ptrSize, button_il, normal_il, L, T, R, B, A, W, H, S, DW, PTR
	local BCM_SETIMAGELIST

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

fixIE(version := 0, exeName := "") {
	local previousValue

	static key := "Software\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION"
	static versions := {7: 7000, 8: 8888, 9: 9999, 10: 10001, 11: 11001}

	if versions.HasKey(version)
		version := versions[version]

	if !exeName {
		if A_IsCompiled
			exeName := A_ScriptName
		else
			SplitPath A_AhkPath, exeName
	}

	RegRead previousValue, HKCU, %key%, %exeName%

	if (version = "") {
		RegDelete, HKCU, %key%, %exeName%
		RegDelete, HKLM, %key%, %exeName%
	}
	else {
		RegWrite, REG_DWORD, HKCU, %key%, %exeName%, %version%
		RegWrite, REG_DWORD, HKLM, %key%, %exeName%, %version%
	}

	return previousValue
}

installTrayMenu(update := false) {
	local icon := kIconsDirectory . "Pause.ico"
	local label := translate("Exit")
	local levels, level, ignore, oldLabel, label, handler

	Menu Tray, Icon, %icon%, , 1

	Sleep 50

	if (update && vHasTrayMenu) {
		oldLabel := translate("Exit", vHasTrayMenu)

		Menu Tray, Rename, %oldLabel%, %label%
	}
	else {
		Menu Tray, NoStandard
		Menu Tray, Add, %label%, exitApplication
	}

	try {
		Menu LogMenu, DeleteAll
	}
	catch exception {
		logError(exception)
	}

	try {
		Menu SupportMenu, DeleteAll
	}
	catch exception {
		logError(exception)
	}

	levels := {Off: kLogOff, Info: kLogInfo, Warn: kLogWarn, Critical: kLogCritical}

	for ignore, label in ["Off", "Info", "Warn", "Critical"] {
		level := levels[label]

		label := translate(label)
		handler := Func("setLogLevel").Bind(level)

		Menu LogMenu, Add, %label%, %handler%

		if (level == getLogLevel())
			Menu LogMenu, Check, %label%
	}

	label := translate("Debug")
	handler := Func("toggleDebug")

	Menu SupportMenu, Add, %label%, %handler%

	if isDebug()
		Menu SupportMenu, Check, %label%

	label := translate("Logging")

	Menu SupportMenu, Add, %label%, :LogMenu

	Menu SupportMenu, Add

	label := translate("Clear log files")
	handler := Func("deleteDirectory").Bind(kLogsDirectory, false)

	Menu SupportMenu, Add, %label%, %handler%

	label := translate("Clear temporary files")
	handler := Func("deleteDirectory").Bind(kTempDirectory, false)

	Menu SupportMenu, Add, %label%, %handler%

	label := translate("Support")

	if (update && vHasTrayMenu) {
		oldLabel := translate("Support", vHasTrayMenu)

		Menu Tray, Delete, %oldLabel%
		Menu Tray, Insert, 1&, %label%, :SupportMenu
	}
	else {
		Menu Tray, Insert, 1&
		Menu Tray, Insert, 1&, %label%, :SupportMenu
	}

	vHasTrayMenu := getLanguage()
}

viewHTML(fileName, title := false, x := "__Undefined__", y := "__Undefined__", width := 800, height := 400) {
	local html, innerWidth, editHeight, buttonX
	local mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom

	static htmlViewer
	static dismissed := false

	if !title
		title := translate("News && Updates")

	dismissed := false

	if !fileName {
		dismissed := true

		return
	}

	FileRead html, %fileName%

	innerWidth := width - 16

	Gui HV:-Border -Caption
	Gui HV:Color, D0D0D0, D8D8D8
	Gui HV:Font, s10 Bold
	Gui HV:Add, Text, x8 y8 W%innerWidth% +0x200 +0x1 BackgroundTrans gmoveHTMLViewer, % translate("Modular Simulator Controller System")
	Gui HV:Font
	Gui HV:Add, Text, x8 yp+26 W%innerWidth% +0x200 +0x1 BackgroundTrans, %title%

	editHeight := height - 102

	Gui HV:Add, ActiveX, X8 YP+26 W%innerWidth% H%editHeight% vhtmlViewer, shell.explorer

	htmlViewer.Navigate("about:blank")

	htmlViewer.Document.open()
	htmlViewer.Document.write(html)
	htmlViewer.Document.close()

	SysGet mainScreen, MonitorWorkArea

	if !getWindowPosition("HTML Viewer", x, y) {
		x := kUndefined
		y := kUndefined
	}

	if (x = kUndefined)
		switch x {
			case "Left":
				x := 25
			case "Right":
				x := mainScreenRight - width - 25
			default:
				x := "Center"
		}

	if (y = kUndefined)
		switch y {
			case "Top":
				y := 25
			case "Bottom":
				y := mainScreenBottom - height - 25
			default:
				y := "Center"
		}

	buttonX := Round(width / 2) - 40

	Gui HV:Add, Button, Default X%buttonX% y+10 w80 gdismissHTMLViewer, % translate("Ok")

	Gui HV:+AlwaysOnTop
	Gui HV:Show, X%x% Y%y% W%width% H%height% NoActivate

	while !dismissed
		Sleep 100

	Gui HV:Destroy
}

showSplash(image, alwaysOnTop := true, video := false) {
	local lastSplash := vSplashCounter
	local title, subTitle, extension, html, options

	image := getFileName(image, kUserSplashMediaDirectory, kSplashMediaDirectory)

	vSplashCounter += 1
	vLastImage := image

	if (vSplashCounter > 10)
		vSplashCounter := 1

	title := substituteVariables(translate(getConfigurationValue(kSimulatorConfiguration, "Splash Window", "Title", "")))
	subTitle := substituteVariables(translate(getConfigurationValue(kSimulatorConfiguration, "Splash Window", "Subtitle", "")))

	SplitPath image, , , extension

	Gui %vSplashCounter%:-Border -Caption
	Gui %vSplashCounter%:Color, D0D0D0, D8D8D8

	Gui %vSplashCounter%:Font, s10 Bold, Arial
	Gui %vSplashCounter%:Add, Text, x10 w780 Center, %title%

	if (extension = "GIF") {
		Gui %vSplashCounter%:Add, ActiveX, x10 y30 w780 h439 vvVideoPlayer, shell explorer

		vVideoPlayer.Navigate("about:blank")

		html := "<html><body style='background-color: #000000' style='overflow:hidden' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><img src='" . image . "' width=780 height=438 border=0 padding=0></body></html>"

		vVideoPlayer.document.write(html)
	}
	else
		Gui %vSplashCounter%:Add, Picture, x10 y30 w780 h439, %image%

	Gui %vSplashCounter%:Font, s8 Norm, Arial
	Gui %vSplashCounter%:Add, Text, x10 y474 w780 Center, %subTitle%

	options := "x" . Round((A_ScreenWidth - 800) / 2) . " y" . Round(A_ScreenHeight / 4)

	if alwaysOnTop
		Gui %vSplashCounter%:+AlwaysOnTop

	Gui %vSplashCounter%:Show, %options% AutoSize NoActivate

	if (lastSplash > 0)
		hideSplash(lastSplash)
}

hideSplash(splashCounter := false) {
	if !splashCounter
		splashCounter := vSplashCounter

	Gui %splashCounter%:Destroy
}

rotateSplash(alwaysOnTop := true) {
	static number := 1
	static images := false
	static numImages := 0

	if !images {
		images := getFileNames("*.jpg", kUserSplashMediaDirectory, kSplashMediaDirectory)

		numImages := images.Length()
	}

	if (number > numImages)
		number := 1

	if (number <= numImages)
		showSplash(images[number++], alwaysOnTop)
}

showSplashTheme(theme := "__Undefined__", songHandler := false, alwaysOnTop := true) {
	local song, video, duration, type

	static images := false
	static number := 1
	static numImages := 0
	static onTop := false

	vSongIsPlaying := false

	if !songHandler
		songHandler := "playThemeSong"

	if (theme == kUndefined) {
		if (number > numImages)
			number := 1

		if (number <= numImages)
			showSplash(images[number++], onTop)

		return
	}

	song := false
	duration := 3000
	type := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Type", false)

	if (type == "Video") {
		song := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Song", false)
		video := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Video")

		showSplash(video, true)

		if song {
			vSongIsPlaying := true

			%songHandler%(song)
		}

		return
	}
	else if (type == "Picture Carousel") {
		duration := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Duration", 5000)
		song := getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Song", false)
		images := string2Values(",", getConfigurationValue(kSimulatorConfiguration, "Splash Themes", theme . ".Images", false))
	}
	else {
		logMessage(kLogCritical, translate("Theme """) . theme . translate(""" not found - please check the configuration"))

		images := getFileNames("*.jpg", kUserSplashMediaDirectory, kSplashMediaDirectory)
	}

	numImages := images.Length()
	onTop := alwaysOnTop

	showSplashTheme()

	SetTimer showSplashTheme, %duration%

	if song {
		vSongIsPlaying := true

		%songHandler%(song)
	}
}

hideSplashTheme() {
	SetTimer showSplashTheme, Off

	if vSongIsPlaying
		try {
			SoundPlay NonExistent.avi
		}
		catch exception {
			logError(exception)
		}

	hideSplash()
}

showProgress(options) {
	local x, y, w, h, color

	static popupPosition := false

	if !vProgressIsOpen {
		if !popupPosition
			popupPosition := getConfigurationValue(readConfiguration(kUserConfigDirectory . "Application Settings.ini")
												 , "General", "Popup Position", "Bottom")
		if options.HasKey("X")
			x := options.X
		else
			x := Round((A_ScreenWidth - 300) / 2)

		if options.HasKey("Y")
			y := options.Y
		else
			y := ((popupPosition = "Bottom") ? A_ScreenHeight - 150 : 150)

		if options.HasKey("Width")
			w := (options.Width - 20)
		else
			w := 280

		color := options.HasKey("color") ? options.color : "Green"

		Gui Progress:Default
		Gui Progress:-Border ; -Caption
		Gui Progress:Color, D0D0D0, D8D8D8

		Gui Progress:Font, s10 Bold, Arial
		Gui Progress:Add, Text, x10 w%w% Center vvProgressTitle

		Gui Progress:Add, Progress, x10 y30 w%w% h20 c%color% BackgroundGray vvProgressBar, 0

		Gui Progress:Font, s8 Norm, Arial
		Gui Progress:Add, Text, x10 y55 w%w% Center vvProgressMessage

		Gui Progress:+AlwaysOnTop
		Gui Progress:Show, x%x% y%y% AutoSize NoActivate

		vProgressIsOpen := true
	}

	Gui Progress:Default

	if options.HasKey("title")
		GuiControl, , vProgressTitle, % options.title

	if options.HasKey("message")
		GuiControl, , vProgressMessage, % options.message

	if options.HasKey("progress")
		GuiControl, , vProgressBar, % Round(options.progress)

	if options.HasKey("color") {
		color := options.color

		GuiControl +c%color%, vProgressBar
	}

	return "Progress"
}

hideProgress() {
	if vProgressIsOpen {
		Gui Progress:Destroy

		vProgressIsOpen := false
	}
}

getAllThemes(configuration := false) {
	local descriptor, value, theme
	local result := []

	if !configuration
		configuration := kSimulatorConfiguration

	for descriptor, value in getConfigurationSectionValues(configuration, "Splash Themes", Object()) {
		theme := StrSplit(descriptor, ".")[1]

		if !inList(result, theme)
			result.Push(theme)
	}

	return result
}

showMessage(message, title := false, icon := "__Undefined__", duration := 1000
		  , x := "Center", y := "__Undefined__", width := 400, height := 100) {
	local mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom
	local innerWidth := width - 16

	static popupPosition := false

	if (y = kUndefined) {
		if !popupPosition
			popupPosition := getConfigurationValue(readConfiguration(kUserConfigDirectory . "Application Settings.ini")
																   , "General", "Popup Position", "Bottom")

		y := popupPosition
	}

	if (icon = kUndefined)
		icon := "Information.png"

	if (!title || (title = ""))
		title := translate("Modular Simulator Controller System")

	Gui MSGW:-Border -Caption
	Gui MSGW:Color, D0D0D0, D8D8D8
	Gui MSGW:Font, s10 Bold
	Gui MSGW:Add, Text, x8 y8 W%innerWidth% +0x200 +0x1 BackgroundTrans, %title%
	Gui MSGW:Font

	if icon {
		Gui MSGW:Add, Picture, w50 h50, % kIconsDirectory . Icon

		innerWidth -= 66

		Gui MSGW:Add, Text, X74 YP+5 W%innerWidth% H%height%, % message
	}
	else
		Gui MSGW:Add, Text, X8 YP+30 W%innerWidth% H%height%, % message

	SysGet mainScreen, MonitorWorkArea

	if x is not Integer
		switch x {
			case "Left":
				x := 25
			case "Right":
				x := mainScreenRight - width - 25
			default:
				x := "Center"
		}

	if y is not Integer
		switch y {
			case "Top":
				y := 25
			case "Bottom":
				y := mainScreenBottom - height - 25
			default:
				y := "Center"
		}

	Gui MSGW:+AlwaysOnTop
	Gui MSGW:Show, X%x% Y%y% W%width% H%height% NoActivate

	Sleep %duration%

	Gui MSGW:Destroy
}

moveByMouse(window, descriptor := false) {
	local curCoordMode := A_CoordModeMouse
	local anchorX, anchorY, winX, winY, newX, newY, x, y, w, h

	local curCoordMode, anchorX, anchorY, winX, winY, x, y, w, h, newX, newY, settings

	if window is not Alpha
		window := A_Gui

	CoordMode Mouse, Screen

	try {
		MouseGetPos anchorX, anchorY
		WinGetPos winX, winY, w, h, A

		newX := winX
		newY := winY

		while GetKeyState("LButton", "P") {
			MouseGetPos x, y

			newX := winX + (x - anchorX)
			newY := winY + (y - anchorY)

			Gui %window%:Show, X%newX% Y%newY%
		}

		if descriptor {
			settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

			setConfigurationValue(settings, "Window Positions", descriptor . ".X", newX)
			setConfigurationValue(settings, "Window Positions", descriptor . ".Y", newY)

			writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)
		}
	}
	finally {
		CoordMode Mouse, curCoordMode
	}
}

getWindowPosition(descriptor, ByRef x, ByRef y) {
	local settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")
	local posX := getConfigurationValue(settings, "Window Positions", descriptor . ".X", kUndefined)
	local posY := getConfigurationValue(settings, "Window Positions", descriptor . ".Y", kUndefined)

	if ((posX == kUndefined) || (posY == kUndefined))
		return false
	else {
		x := posX
		y := posY

		return true
	}
}

isNull(value) {
	return ((value == "__Null__") || (value = "null"))
}

reportNonObjectUsage(reference, p1 = "", p2 = "", p3 = "", p4 = "") {
	if isDebug()
		showMessage(StrSplit(A_ScriptName, ".")[1] . ": The literal value " . reference . " was used as an object: " . p1 . "; " . p2 . "; " . p3 . "; " . p4
				  , false, kUndefined, 5000)

	return false
}

isDebug() {
	return vDebug
}

getLogLevel() {
	return vLogLevel
}

logMessage(logLevel, message) {
	local script := StrSplit(A_ScriptName, ".")[1]
	local time := A_Now
	local level, fileName, directory, tries, logTime, logLine

	static sending := false

	if (logLevel >= vLogLevel) {
		level := ""

		switch logLevel {
			case kLogInfo:
				level := "Info    "
			case kLogWarn:
				level := "Warn    "
			case kLogCritical:
				level := "Critical"
			case kLogOff:
				level := "Off     "
			default:
				throw "Unknown log level (" . logLevel . ") encountered in logMessage..."
		}

		FormatTime, logTime, %time%, dd.MM.yy hh:mm:ss tt

		fileName := kLogsDirectory . script . " Logs.txt"
		logLine := "[" level . " - " . logTime . "]: " . message . "`n"

		SplitPath fileName, , directory
		FileCreateDir %directory%

		tries := 5

		while (tries > 0)
			try {
				FileAppend %logLine%, %fileName%, UTF-16

				break
			}
			catch exception {
				Sleep 1

				tries -= 1
			}

		if (!sending && (script != "System Monitor")) {
			Process Exist, System Monitor.exe

			if ErrorLevel {
				sending := true

				try {
					sendMessage(kFileMessage, "Monitor", "logMessage:" . values2String(";", script, time, logLevel, message), ErrorLevel)
				}
				finally {
					sending := false
				}
			}
		}
	}
}

logError(exception, unhandled := false) {
	local message

	if IsObject(exception) {
		message := exception.Message

		if message is not Number
			logMessage(unhandled ? kLogCritical : kLogInfo
					 , translate(unhandled ? "Unhandled exception encountered in " : "Handled exception encountered in ")
					 . exception.File . translate(" at line ") . exception.Line . translate(": ") . message)
	}
	else if exception is not Number
		logMessage(unhandled ? kLogCritical : kLogInfo
				 , translate(unhandled ? "Unhandled exception encountered: " : "Handled exception encountered: ") . exception)

	return (isDebug() ? false : true)
}

availableLanguages() {
	local translations := {en: "English"}
	local ignore, fileName, languageCode

	for ignore, fileName in getFileNames("Translations.*", kUserTranslationsDirectory, kTranslationsDirectory) {
		SplitPath fileName, , , languageCode

		translations[languageCode] := readLanguage(languageCode)
	}

	return translations
}

readTranslations(targetLanguageCode, withUserTranslations := true) {
	local fileNames := []
	local fileName := (kTranslationsDirectory . "Translations." . targetLanguageCode)
	local translations, translation, ignore, enString

	if FileExist(fileName)
		fileNames.Push(fileName)

	if withUserTranslations {
		fileName := (kUserTranslationsDirectory . "Translations." . targetLanguageCode)

		if FileExist(fileName)
			fileNames.Push(fileName)
	}

	translations := {}

	for ignore, fileName in fileNames
		loop Read, %fileName%
		{
			translation := A_LoopReadLine

			translation := StrReplace(translation, "\=", "=")
			translation := StrReplace(translation, "\\", "\")
			translation := StrReplace(translation, "\n", "`n")

			translation := StrSplit(translation, "=>")
			enString := translation[1]

			if ((SubStr(enString, 1, 1) != "[") && (enString != targetLanguageCode))
				if ((A_Index == 1) && (translations.HasKey(enString) && (translations[enString] != translation[2])))
					if isDebug()
						throw "Inconsistent translation encountered for """ . enString . """ in readTranslations..."
					else
						logError("Inconsistent translation encountered for """ . enString . """ in readTranslations...")

				translations[enString] := translation[2]
		}

	return translations
}

writeTranslations(languageCode, languageName, translations) {
	local fileName := kUserTranslationsDirectory . "Translations." . languageCode
	local stdTranslations := readTranslations(languageCode, false)
	local hasValues := false
	local ignore, key, value, temp, curEncoding, original, translation

	for ignore, value in stdTranslations {
		hasValues := true

		break
	}

	if hasValues {
		temp := {}

		for key, value in translations
			if (!stdTranslations.HasKey(key) || (stdTranslations[key] != value))
				temp[key] := value

		translations := temp
	}

	deleteFile(fileName)

	curEncoding := A_FileEncoding

	FileEncoding UTF-16

	try {
		FileAppend [Locale]`n, %fileName%
		FileAppend %languageCode%=>%languageName%`n, %fileName%
		FileAppend [Translations], %fileName%

		for original, translation in translations {
			original := StrReplace(original, "\", "\\")
			original := StrReplace(original, "=", "\=")
			original := StrReplace(original, "`n", "\n")

			translation := StrReplace(translation, "\", "\\")
			translation := StrReplace(translation, "=", "\=")
			translation := StrReplace(translation, "`n", "\n")

			FileAppend `n%original%=>%translation%, %fileName%
		}
	}
	finally {
		FileEncoding %curEncoding%
	}
}

translate(string, targetLanguageCode := false) {
	local theTranslations, translation

	static currentLanguageCode := "en"
	static translations := false

	if (targetLanguageCode && (targetLanguageCode != vTargetLanguageCode)) {
		theTranslations := readTranslations(targetLanguageCode)

		if theTranslations.HasKey(string) {
			translation := theTranslations[string]

			return ((translation != "") ? translation : string)
		}
		else
			return string
	}
	else if (vTargetLanguageCode != "en") {
		if (vTargetLanguageCode != currentLanguageCode) {
			currentLanguageCode := vTargetLanguageCode

			translations := readTranslations(currentLanguageCode)
		}

		if translations.HasKey(string) {
			translation := translations[string]

			return ((translation != "") ? translation : string)
		}
		else
			return string
	}
	else
		return string
}

setLanguage(languageCode) {
	vTargetLanguageCode := languageCode

	if vHasTrayMenu
		installTrayMenu(true)
}

getLanguageFromLCID(lcid) {
	local code := SubStr(lcid, StrLen(lcid) - 1)

	if (code = "07")
		return "DE"
	else if (code = "0c")
		return "FR"
	else if (code = "0a")
		return "ES"
	else if (code = "10")
		return "IT"
	else
		return "EN"
}

getSystemLanguage() {
	return getLanguageFromLCID(A_Language)
}

getLanguage() {
	return vTargetLanguageCode
}

protectionOn(critical := false, block := false) {
	changeProtection(true, critical, block)
}

protectionOff(critical := false, block := false) {
	changeProtection(false, critical, block)
}

withProtection(function, params*) {
	protectionOn()

	try {
		return %function%(params*)
	}
	finally {
		protectionOff()
	}
}

isInstance(object, root) {
	local candidate, classVar, outerClassVar

	if IsObject(object) {
		candidate := object.base

		while IsObject(candidate)
			if (candidate == root)
				return true
			else {
				classVar := (candidate.base ? candidate.base.__Class : false)

				if (classVar && (classVar != "")) {
					if InStr(classVar, ".") {
						classVar := StrSplit(classVar, ".")
						outerClassVar := classVar[1]

						candidate := %outerClassVar%[classVar[2]]
					}
					else
						candidate := %classVar%
				}
				else
					return false
			}
	}

	return false
}

getFileName(fileName, directories*) {
	local driveName, ignore, directory

	fileName := substituteVariables(fileName)

	SplitPath fileName, , , , , driveName

	if (driveName && (driveName != ""))
		return fileName
	else {
		for ignore, directory in directories
			if FileExist(directory . fileName)
				return (directory . fileName)

		if (directories.Length() > 0)
			return (directories[1] . fileName)
		else
			return fileName
	}
}

getFileNames(filePattern, directories*) {
	local result := []
	local ignore, directory, pattern

	for ignore, directory in directories {
		pattern := directory . filePattern

		loop Files, %pattern%, FD
			result.Push(A_LoopFileLongPath)
	}

	return result
}

normalizeFilePath(filePath) {
	local position, index

	loop {
		position := InStr(filePath, "\..")

		if position {
			index := position - 1

			loop {
				if (index == 0)
					return filePath
				else if (SubStr(filePath, index, 1) == "\") {
					filePath := StrReplace(filePath, SubStr(filePath, index, position + 3 - index), "")

					break
				}

				index -= 1
			}
		}
		else
			return filePath
	}
}

normalizeDirectoryPath(path) {
	return ((SubStr(path, StrLen(path)) = "\") ? SubStr(path, 1, StrLen(path) - 1) : path)
}

temporaryFileName(name, extension) {
	local rnd

	Random rnd, 1, 100000

	return (kTempDirectory . name . "_" . Round(rnd) . "." . extension)
}

deleteFile(fileName) {
	try {
		FileDelete %fileName%

		return !ErrorLevel
	}
	catch exception {
		logError(exception)

		return false
	}
}

deleteDirectory(directoryName, includeDirectory := true) {
	local files, ignore, fileName, result

	if includeDirectory {
		try {
			FileRemoveDir %directoryName%, 1

			return !ErrorLevel
		}
		catch exception {
			logError(exception)

			return false
		}
	}
	else {
		files := []
		result := true

		loop Files, %directoryName%\*.*, DF
			files.Push(A_LoopFilePath)

		for ignore, fileName in files {
			if InStr(FileExist(fileName), "D") {
				if !deleteDirectory(fileName)
					result := false
			}
			else if !deleteFile(fileName)
				result := false
		}

		return result
	}
}

substituteVariables(string, values := false) {
	local result := string
	local variable, startPos, endPos, value

	loop {
		startPos := InStr(result, "%")

		if startPos {
			startPos += 1
			endPos := InStr(result, "%", false, startPos)

			if endPos {
				variable := Trim(SubStr(result, startPos, endPos - startPos))

				value := (values && values.HasKey(variable)) ? values[variable] : %variable%

				result := StrReplace(result, "%" . variable . "%", value)
			}
			else
				throw "Second % not found while scanning (" . string . ") for variables in substituteVariables..."
		}
		else
			break
	}

	return result
}

string2Values(delimiter, string, count := false) {
	return (count ? StrSplit(Trim(string), delimiter, " `t", count) : StrSplit(Trim(string), delimiter, " `t"))
}

values2String(delimiter, values*) {
	local result := ""
	local index, value

	for index, value in values {
		if (index > 1)
			result .= delimiter

		result .= value
	}

	return result
}

inList(list, value) {
	local index, candidate

	for index, candidate in list
		if (candidate = value)
			return index

	return false
}

listEqual(list1, list2) {
	local index, value

	if (list1.Length() != list2.Length())
		return false
	else
		for index, value in list1
			if (list2[index] != value)
				return false

	return true
}

concatenate(lists*) {
	local result := []
	local ignore, list, value

	for ignore, list in lists
		for ignore, value in list
			result.Push(value)

	return result
}

reverse(list) {
	local result := []
	local length := list.Length()

	loop %length%
		result.Push(list[length - (A_Index - 1)])

	return result
}

map(list, function) {
	local result := []
	local ignore, value

	for ignore, value in list
		result.Push(%function%(value))

	return result
}

remove(list, object) {
	local result := []
	local ignore, value

	for ignore, value in list
		if (value != object)
			result.Push(value)

	return result
}

removeDuplicates(list) {
	local result := []
	local ignore, value

	for ignore, value in list
		if !inList(result, value)
			result.Push(value)

	return result
}

do(list, function) {
	local ignore, value

	for ignore, value in list
		%function%(value)
}

combine(maps*) {
	local result := {}
	local ignore, map, key, value

	for ignore, map in maps
		for key, value in map
			result[key] := value

	return result
}

getKeys(map) {
	local result := []
	local ignore, key

	for key, ignore in map
		result.Push(key)

	return result
}

getValues(map) {
	local result := []
	local ignore, value

	for ignore, value in map
		result.Push(value)

	return result
}

greaterComparator(a, b) {
	return (a > b)
}

bubbleSort(ByRef array, comparator := "greaterComparator") {
	local n := array.Length()
	local newN, i, j, lineI, lineJ

	while (n > 1) {
		newN := 1
		i := 0

		while (++i < n) {
			j := i + 1

			if %comparator%(lineI := array[i], lineJ := array[j]) {
				array[i] := lineJ
				array[j] := lineI

				newN := j
			}
		}

		n := newN
	}
}

trayMessage(title, message, duration := false, async := true) {
	if (async && (duration || vTrayMessageDuration))
		Task.startTask(Func("trayMessage").Bind(title, message, duration, false), 0, kLowPriority)
	else {
		title := StrReplace(title, "`n", A_Space)
		message := StrReplace(message, "`n", A_Space)

		if !duration
			duration := vTrayMessageDuration

		if duration {
			protectionOn()

			try {
				TrayTip %title%, %message%

				Sleep %duration%

				TrayTip

				if SubStr(A_OSVersion,1,3) = "10." {
					Menu Tray, NoIcon
					Sleep 200  ; It may be necessary to adjust this sleep...
					Menu Tray, Icon
				}
			}
			finally {
				protectionOff()
			}
		}
	}
}

disableTrayMessages() {
	vTrayMessageDuration := false
}

enableTrayMessages(duration := 1500) {
	vTrayMessageDuration := duration
}

translateMsgBoxButtons(buttonLabels) {
	local curDetectHiddenWindows := A_DetectHiddenWindows
	local index, label

    DetectHiddenWindows, On

	try {
		Process, Exist

		If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
			for index, label in buttonLabels
				try {
					ControlSetText Button%index%, % translate(label)
				}
				catch exception {
					logError(exception)
				}
		}
	}
	finally {
		DetectHiddenWindows %curDetectHiddenWindows%
	}
}

newConfiguration() {
	return {}
}

readConfiguration(configFile) {
	local configuration := {}
	local section := false
	local file := false
	local currentLine, firstChar, keyValue, key, value

	configFile := getFileName(configFile, kUserConfigDirectory, kConfigDirectory)

	loop
		try {
			file := FileOpen(configFile, "r")

			break
		}
		catch exception {
			if !FileExist(configFile)
				return configuration
		}

	if file {
		loop Read, %configFile%
		{
			currentLine := LTrim(A_LoopReadLine)

			if (StrLen(currentLine) == 0)
				continue

			firstChar := SubStr(currentLine, 1, 1)

			if (firstChar = ";")
				continue
			else if (firstChar = "[") {
				section := StrReplace(StrReplace(RTrim(currentLine), "[", ""), "]", "")

				configuration[section] := {}
			}
			else if section {
				keyValue := LTrim(A_LoopReadLine)

				if ((SubStr(keyValue, 1, 2) != "//") && (SubStr(keyValue, 1, 1) != ";")) {
					keyValue := StrSplit(StrReplace(StrReplace(StrReplace(keyValue, "\=", "_#_EQ-#_"), "\\", "_#_AC-#_"), "\n", "_#_CR-#_")
									   , "=", "", 2)

					key := StrReplace(StrReplace(StrReplace(keyValue[1], "_#_EQ-#_", "="), "_#_AC-#_", "\\"), "_#_CR-#_", "`n")
					value := StrReplace(StrReplace(StrReplace(keyValue[2], "_#_EQ-#_", "="), "_#_AC-#_", "\"), "_#_CR-#_", "`n")

					configuration[section][keyValue[1]] := ((value = kTrue) ? true : ((value = kFalse) ? false : value))
				}
			}
		}

		file.Close()
	}

	return configuration
}

parseConfiguration(text) {
	local fileName := temporaryFileName("Config", "ini")
	local configuration

	FileAppend %text%, %fileName%, UTF-16

	configuration := readConfiguration(fileName)

	deleteFile(fileName)

	return configuration
}

writeConfiguration(configFile, configuration) {
	local tempFile := temporaryFileName("Config", "ini")
	local directory, section, keyValues, key, value, pairs

	deleteFile(tempFile)

	SplitPath tempFile, , directory
	FileCreateDir %directory%

	for section, keyValues in configuration {
		pairs := ""

		for key, value in keyValues {
			value := StrReplace(value, "\", "\\")
			value := StrReplace(value, "=", "\=")
			value := StrReplace(value, "`n", "\n")

			pairs := (pairs . "`n" . key . "=" . ((value == true) ? kTrue : ((value == false) ? kFalse : value)))
		}

		section := "[" . section . "]" . pairs . "`n"

		FileAppend %section%, %tempFile%, UTF-16
	}

	configFile := getFileName(configFile, kUserConfigDirectory)

	loop
		try {
			FileMove %tempFile%, %configFile%, 1

			break
		}
		catch exception {
			logError(exception)
		}
}

printConfiguration(configuration) {
	local fileName := temporaryFileName("Config", "ini")
	local text

	writeConfiguration(fileName, configuration)

	try {
		FileRead text, %fileName%
	}
	catch exception {
		text := ""
	}

	deleteFile(fileName)

	return text
}

getConfigurationValue(configuration, section, key, default := false) {
	local value

	if configuration.HasKey(section) {
		value := configuration[section]

		if value.HasKey(key)
			return value[key]
	}

	return default
}

getConfigurationSectionValues(configuration, section, default := false) {
	return configuration.HasKey(section) ? configuration[section].Clone() : default
}

setConfigurationValue(configuration, section, key, value) {
	configuration[section, key] := value
}

setConfigurationSectionValues(configuration, section, values) {
	local key, value

	for key, value in values
		setConfigurationValue(configuration, section, key, value)
}

setConfigurationValues(configuration, otherConfiguration) {
	local section, values

	for section, values in otherConfiguration
		setConfigurationSectionValues(configuration, section, values)
}

removeConfigurationValue(configuration, section, key) {
	if configuration.HasKey(section)
		configuration[section].Delete(key)
}

removeConfigurationSection(configuration, section) {
	if configuration.HasKey(section)
		configuration.Delete(section)
}

getControllerState(configuration := "__Undefined__") {
	local load := true
	local pid, tries, options, exePath, fileName

	if (configuration == false)
		load := false
	else if (configuration = kUndefined)
		configuration := false

	Process Exist, Simulator Controller.exe

	pid := ErrorLevel

	if (!pid && (configuration || !FileExist(kTempDirectory . "Simulator Controller.state")))
		try {
			if configuration {
				fileName := temporaryFileName("Config", "ini")

				writeConfiguration(fileName, configuration)

				options := (" -Configuration """ . fileName . """")
			}
			else
				options := ""

			exePath := ("""" . kBinariesDirectory . "Simulator Controller.exe"" -NoStartup -NoUpdate" .  options)

			Run %exePath%, %kBinariesDirectory%, , pid

			Sleep 1000

			tries := 30

			while (tries > 0) {
				Sleep 200

				Process Exist, %pid%

				if !ErrorLevel
					break
			}

			if configuration
				deleteFile(fileName)
		}
		catch exception {
			logMessage(kLogCritical, translate("Cannot start Simulator Controller (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

			showMessage(substituteVariables(translate("Cannot start Simulator Controller (%kBinariesDirectory%Simulator Controller.exe) - please rebuild the applications..."))
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}


	return readConfiguration(kTempDirectory . "Simulator Controller.state")
}

getControllerActionLabels() {
	return getControllerActionDefinitions("Labels")
}

getControllerActionIcons() {
	local icons := getControllerActionDefinitions("Icons")
	local section, values, key, value

	for section, values in icons
		for key, value in values
			values[key] := substituteVariables(value)

	return icons
}


;;;-------------------------------------------------------------------------;;;
;;;                        Controller Action Section                        ;;;
;;;-------------------------------------------------------------------------;;;

toggleDebug() {
	setDebug(!isDebug())
}

setDebug(debug) {
	local label := translate("Debug")
	local title, state

	if vHasTrayMenu
		if debug
			Menu SupportMenu, Check, %label%
		else
			Menu SupportMenu, Uncheck, %label%

	vDebug := debug

	title := translate("Modular Simulator Controller System")
	state := (debug ? translate("Enabled") : translate("Disabled"))

	TrayTip %title%, Debug: %state%
}

setLogLevel(level) {
	local ignore, label, title, state

	if vHasTrayMenu
		for ignore, label in ["Off", "Info", "Warn", "Critical"] {
			label := translate(label)

			Menu LogMenu, Uncheck, %label%
		}

	switch level {
		case "Info":
			level := kLogInfo
		case "Warn":
			level := kLogWarn
		case "Critical":
			level := kLogCritical
		case "Off":
			level := kLogOff
	}

	vLogLevel := Min(kLogOff, Max(level, kLogInfo))

	state := translate("Unknown")

	switch vLogLevel {
		case kLogInfo:
			state := translate("Info")
		case kLogWarn:
			state := translate("Warn")
		case kLogCritical:
			state := translate("Critical")
		case kLogOff:
			state := translate("Off")
	}

	if vHasTrayMenu
		Menu LogMenu, Check, %state%

	title := translate("Modular Simulator Controller System")

	TrayTip %title%, % translate("Log Level: ") . state
}

increaseLogLevel() {
	setLogLevel(getLogLevel() - 1)
}

decreaseLogLevel() {
	setLogLevel(getLogLevel() + 1)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeEnvironment()
loadSimulatorConfiguration()

if !vDetachedInstallation {
	checkForUpdates()

	if true || !isDebug() {
		requestShareSessionDatabaseConsent()
		startDatabaseSynchronizer()
		checkForNews()
	}
}

initializeLoggingSystem()
installTrayMenu()