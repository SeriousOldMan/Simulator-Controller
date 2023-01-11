;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Application Library      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Framework.ahk
#Include ..\Framework\GUI.ahk
#Include ..\Framework\Message.ahk
#Include ..\Framework\Progress.ahk
#Include ..\Framework\Splash.ahk
#Include ..\Framework\Classes.ahk
#Include ..\Framework\Startup.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Messages.ahk


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

consentDialog(id, consent := false) {
	local language, texts, chosen, x, y, rootDirectory, ignore, section, keyValues, key, value

	static tyrePressuresConsentDropDown
	static carSetupsConsentDropDown
	static raceStrategiesConsentDropDown
	static closed

	if (id = "Close") {
		closed := true

		return
	}
	else
		closed := false

	texts := false

	language := getLanguage()

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

	Gui CNS:Add, Text, x8 y300 w450 h23 +0x200, % translate("Do you want to share your tyre pressure data?")

	chosen := inList(["Yes", "No", "Undecided"], getConfigurationValue(consent, "Consent", "Share Tyre Pressures", "Undecided"))
	Gui CNS:Add, DropDownList, x460 y300 w332 AltSubmit Choose%chosen% VtyrePressuresConsentDropDown, % values2String("|", map(["Yes", "No", "Ask again later..."], "translate")*)

	Gui CNS:Add, Text, x8 y324 w450 h23 +0x200, % translate("Do you want to share your car setup data?")

	chosen := inList(["Yes", "No", "Undecided"], getConfigurationValue(consent, "Consent", "Share Car Setups", "Undecided"))
	Gui CNS:Add, DropDownList, x460 y324 w332 AltSubmit Choose%chosen% VcarSetupsConsentDropDown, % values2String("|", map(["Yes", "No", "Ask again later..."], "translate")*)

	Gui CNS:Add, Text, x8 y348 w450 h23 +0x200, % translate("Do you want to share your race strategies?")

	chosen := inList(["Yes", "No", "Undecided"], getConfigurationValue(consent, "Consent", "Share Race Strategies", "Undecided"))
	Gui CNS:Add, DropDownList, x460 y348 w332 AltSubmit Choose%chosen% VraceStrategiesConsentDropDown, % values2String("|", map(["Yes", "No", "Ask again later..."], "translate")*)

	Gui CNS:Add, Text, x8 y388 w784 h60 -VScroll +Wrap ReadOnly, % StrReplace(StrReplace(getConfigurationValue(texts, "Consent", "Information"), "``n", "`n"), "\<>", "=")

	Gui CNS:Add, Link, x8 y458 w784 h60 cRed -VScroll +Wrap ReadOnly, % StrReplace(StrReplace(getConfigurationValue(texts, "Consent", "Warning"), "``n", "`n"), "\<>", "=")

	Gui CNS:Add, Button, x368 y514 w80 h23 Default gcloseConsentDialog, % translate("Save")

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
	GuiControlGet raceStrategiesConsentDropDown

	Gui CNS:Destroy

	return {TyrePressures: ["Yes", "No", "Retry"][tyrePressuresConsentDropDown], CarSetups: ["Yes", "No", "Retry"][carSetupsConsentDropDown], RaceStrategies: ["Yes", "No", "Retry"][raceStrategiesConsentDropDown]}
}

closeConsentDialog() {
	consentDialog("Close")
}

moveConsentDialog() {
	moveByMouse("CNS", "Consent")
}


moveHTMLViewer() {
	moveByMouse("HV", "HTML Viewer")
}

dismissHTMLViewer() {
	viewHTML(false)
}

requestShareSessionDatabaseConsent() {
	local idFileName, ID, consent, request, countdown, newConsent, result, type, key

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

				if (getFileNames("Consent.*", kTranslationsDirectory).Length() > 0)
					result := consentDialog(id, consent)
				else {
					result := {}

					result["TyrePressures"] := "Retry"
					result["RaceStrategies"] := "Retry"
					result["CarSetups"] := "Retry"
				}

				for type, key in {TyrePressures: "Share Tyre Pressures", RaceStrategies: "Share Race Strategies"
																	   , CarSetups: "Share Car Setups"}
					switch result[type] {
						case "Yes":
							setConfigurationValue(newConsent, "Consent", key, "Yes")
						case "No":
							setConfigurationValue(newConsent, "Consent", key, "No")
						case "Retry":
							setConfigurationValue(newConsent, "Consent", key, "Undecided")
							setConfigurationValue(newConsent, "General", "Countdown", 10)
					}

				writeConfiguration(kUserConfigDirectory . "CONSENT", newConsent)
			}
		}
	}
}

checkForNews() {
	local check, lastModified, news, nr, html

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

startDatabaseSynchronizer() {
	local idFileName, ID, dbIDFileName, dbID, shareTyrePressures, shareCarSetups, shareRaceStrategies, options, consent

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
				shareRaceStrategies := (getConfigurationValue(consent, "Consent", "Share Race Strategies", "No") = "Yes")

				options := ("-ID """ . ID . """ -Synchronize " . true)

				if shareTyrePressures
					options .= " -Pressures"

				if shareCarSetups
					options .= " -Setups"

				if shareRaceStrategies
					options .= " -Strategies"

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
							Run %kBinariesDirectory%Simulator Download.exe -NoUpdate -Download -Update -Start "%A_ScriptFullPath%" ; *RunAs
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


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

broadcastMessage(applications, message, arguments*) {
	if (arguments.Length() > 0)
		doApplications(applications, Func("sendMessage").Bind(kFileMessage, "Core", message . ":" . values2String(";", arguments*)))
	else
		doApplications(applications, Func("sendMessage").Bind(kFileMessage, "Core", message))

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


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

if (!isDetachedInstallation() && !isDebug()) {
	checkForUpdates()

	requestShareSessionDatabaseConsent()
	startDatabaseSynchronizer()
	checkForNews()
}