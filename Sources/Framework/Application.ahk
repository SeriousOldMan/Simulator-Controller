;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Application Library      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Framework.ahk"
#Include "GUI.ahk"
#Include "Message.ahk"
#Include "Progress.ahk"
#Include "Splash.ahk"
#Include "Configuration.ahk"
#Include "Startup.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\Messages.ahk"
#Include "..\Libraries\HTMLViewer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

consentDialog(id, consent := false, *) {
	local consentGui, texts, chosen, x, y, fileName, ignore, section, keyValues, key, value
	
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

	for ignore, fileName in getFileNames("Consent." . getLanguage(), kTranslationsDirectory, kUserTranslationsDirectory)
		if !texts
			texts := readMultiMap(fileName)
		else
			for section, keyValues in readMultiMap(fileName)
				for key, value in keyValues
					setMultiMapValue(texts, section, key, value)

	if !texts
		texts := readMultiMap(kTranslationsDirectory . "Consent.en")

	consentGui := Window({Descriptor: "Consent", Options: "0x400000"}, "")

	consentGui.SetFont("s10 Bold")

	consentGui.Add("Text", "x0 y8 w800 +0x200 +0x1 BackgroundTrans", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(consentGui, "Consent"))

	consentGui.SetFont("Norm", "Arial")

	consentGui.Add("Text", "x0 y32 w800 h23 +0x200 +0x1 BackgroundTrans", translate("Declaration of consent"))

	consentGui.Add("Text", "x8 y70 w784 h180 -VScroll +Wrap ReadOnly", StrReplace(StrReplace(getMultiMapValue(texts, "Consent", "Introduction"), "``n", "`n"), "\<>", "="))

	consentGui.Add("Text", "x8 y260 w450 h23 +0x200", translate("Your database identification key is:"))
	consentGui.Add("Edit", "x460 y260 w332 h23 -VScroll ReadOnly Center", id)

	consentGui.Add("Text", "x8 y300 w450 h23 +0x200", translate("Do you want to share your tyre pressure data?"))

	chosen := inList(["Yes", "No", "Undecided"], getMultiMapValue(consent, "Consent", "Share Tyre Pressures", "Undecided"))
	tyrePressuresConsentDropDown := consentGui.Add("DropDownList", "x460 y300 w332 Choose" . chosen, collect(["Yes", "No", "Ask again later..."], translate))

	consentGui.Add("Text", "x8 y324 w450 h23 +0x200", translate("Do you want to share your car setup data?"))

	chosen := inList(["Yes", "No", "Undecided"], getMultiMapValue(consent, "Consent", "Share Car Setups", "Undecided"))
	carSetupsConsentDropDown := consentGui.Add("DropDownList", "x460 y324 w332 Choose" . chosen, collect(["Yes", "No", "Ask again later..."], translate))

	consentGui.Add("Text", "x8 y348 w450 h23 +0x200", translate("Do you want to share your race strategies?"))

	chosen := inList(["Yes", "No", "Undecided"], getMultiMapValue(consent, "Consent", "Share Race Strategies", "Undecided"))
	raceStrategiesConsentDropDown := consentGui.Add("DropDownList", "x460 y348 w332 Choose" . chosen, collect(["Yes", "No", "Ask again later..."], translate))

	consentGui.Add("Text", "x8 y388 w784 h60 -VScroll +Wrap ReadOnly", StrReplace(StrReplace(getMultiMapValue(texts, "Consent", "Information"), "``n", "`n"), "\<>", "="))

	consentGui.Add("Link", "x8 y458 w784 h60 cRed -VScroll +Wrap ReadOnly", StrReplace(StrReplace(getMultiMapValue(texts, "Consent", "Warning"), "``n", "`n"), "\<>", "="))

	consentGui.Add("Button", "x368 y514 w80 h23 Default", translate("Save")).OnEvent("Click", consentDialog.Bind("Close"))

	consentGui.Opt("+AlwaysOnTop")

	if getWindowPosition("Consent", &x, &y)
		consentGui.Show("x" . x . " y" . y)
	else
		consentGui.Show()

	loop
		Sleep(100)
	until closed

	try {
		return Map("TyrePressures", ["Yes", "No", "Retry"][tyrePressuresConsentDropDown.Value]
				 , "CarSetups", ["Yes", "No", "Retry"][carSetupsConsentDropDown.Value]
				 , "RaceStrategies", ["Yes", "No", "Retry"][raceStrategiesConsentDropDown.Value])
	}
	finally
		consentGui.Destroy()
}

requestShareSessionDatabaseConsent() {
	local idFileName, ID, consent, request, countdown, newConsent, result, type, key

	if !inList(A_Args, "-Install") {
		if inList(["Simulator Startup", "Simulator Configuration", "Simulator Settings", "Session Database", "Simulator Setup"], StrSplit(A_ScriptName, ".")[1]) {
			idFileName := kUserConfigDirectory . "ID"

			ID := StrSplit(FileRead(idFileName), "`n", "`r")[1]

			consent := readMultiMap(kUserConfigDirectory . "CONSENT")

			request := ((consent.Count == 0) || (ID != getMultiMapValue(consent, "General", "ID")) || getMultiMapValue(consent, "General", "ReNew", false))

			if !request {
				countdown := getMultiMapValue(consent, "General", "Countdown", kUndefined)

				if (countdown != kUndefined) {
					if (--countdown <= 0)
						request := true
					else {
						setMultiMapValue(consent, "General", "Countdown", countdown)

						writeMultiMap(kUserConfigDirectory . "CONSENT", consent)
					}
				}
			}

			if request {
				newConsent := newMultiMap()

				setMultiMapValue(newConsent, "General", "ID", id)
				setMultiMapValue(newConsent, "Consent", "Date", A_MM . "/" . A_DD . "/" . A_YYYY)

				if (getFileNames("Consent.*", kTranslationsDirectory).Length > 0)
					result := consentDialog(id, consent)
				else {
					result := CaseInsenseMap()

					result["TyrePressures"] := "Retry"
					result["RaceStrategies"] := "Retry"
					result["CarSetups"] := "Retry"
				}

				for type, key in Map("TyrePressures", "Share Tyre Pressures", "RaceStrategies", "Share Race Strategies", "CarSetups", "Share Car Setups")
					switch result[type], false {
						case "Yes":
							setMultiMapValue(newConsent, "Consent", key, "Yes")
						case "No":
							setMultiMapValue(newConsent, "Consent", key, "No")
						case "Retry":
							setMultiMapValue(newConsent, "Consent", key, "Undecided")
							setMultiMapValue(newConsent, "General", "Countdown", 10)
					}

				writeMultiMap(kUserConfigDirectory . "CONSENT", newConsent)
			}
		}
	}
}

checkForNews() {
	local check, lastModified, news, nr, html

	if inList(kForegroundApps, StrSplit(A_ScriptName, ".")[1]) {
		check := !FileExist(kUserConfigDirectory . "NEWS")

		if !check {
			lastModified := FileGetTime(kUserConfigDirectory "NEWS", "M")

			lastModified := DateAdd(lastModified, 1, "Days")

			check := (lastModified < A_Now)
		}

		if check {
			try {
				Download("https://www.dropbox.com/s/3zfsgiepo85ufw3/NEWS?dl=1", kTempDirectory . "NEWS")
			}
			catch Any as exception {
				check := false
			}
		}

		if check {
			news := readMultiMap(kUserConfigDirectory . "NEWS")

			for nr, html in getMultiMapValues(readMultiMap(kTempDirectory . "NEWS"), "News")
				if !getMultiMapValue(news, "News", nr, false)
					try {
						Download(html, kTempDirectory . "NEWS.htm")

						setMultiMapValue(news, "News", nr, true)

						writeMultiMap(kUserConfigDirectory . "NEWS", news)

						viewHTML(kTempDirectory . "NEWS.htm")
					}
					catch Any as exception {
						logError(exception)
					}
		}
	}
}

startDatabaseSynchronizer() {
	local idFileName, ID, dbIDFileName, dbID, shareTyrePressures, shareCarSetups, shareRaceStrategies, options, consent

	if (isProperInstallation() && (StrSplit(A_ScriptName, ".")[1] = "Simulator Startup") && !ProcessExist("Database Synchronizer.exe")) {
		idFileName := kUserConfigDirectory . "ID"

		ID := StrSplit(FileRead(idFileName), "`n", "`r")[1]

		dbIDFileName := kDatabaseDirectory . "ID"

		try {
			dbID := StrSplit(FileRead(dbIDFileName),"`n","`r")[1]
		}
		catch Any as exception {
			logError(exception, true)

			dbID := false
		}

		if (ID = dbID) {
			consent := readMultiMap(kUserConfigDirectory . "CONSENT")

			shareTyrePressures := (getMultiMapValue(consent, "Consent", "Share Tyre Pressures", "No") = "Yes")
			shareCarSetups := (getMultiMapValue(consent, "Consent", "Share Car Setups", "No") = "Yes")
			shareRaceStrategies := (getMultiMapValue(consent, "Consent", "Share Race Strategies", "No") = "Yes")

			options := ("-ID `"" . ID . "`" -Synchronize " . true)

			if shareTyrePressures
				options .= " -Pressures"

			if shareCarSetups
				options .= " -Setups"

			if shareRaceStrategies
				options .= " -Strategies"

			try {
				Run(kBinariesDirectory . "Database Synchronizer.exe " . options)
			}
			catch Any as exception {
				logMessage(kLogCritical, translate("Cannot start Database Synchronizer - please rebuild the applications..."))

				showMessage(translate("Cannot start Database Synchronizer - please rebuild the applications...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}
}

checkForUpdates() {
	local check, lastModified, release, version, current, releasePostFix, currentPostFix, automaticUpdates
	local toolTargets, userToolTargets, userToolTargetsFile, updates, target, arguments, versionPostfix, msgResult

	if isDetachedInstallation()
		return

	if inList(kForegroundApps, StrSplit(A_ScriptName, ".")[1]) {
		check := !FileExist(kUserConfigDirectory . "VERSION")

		if !check {
			lastModified := FileGetTime(kUserConfigDirectory . "VERSION", "M")

			lastModified := DateAdd(lastModified, 1, "Days")

			check := (lastModified < A_Now)
		}

		if check {
			try {
				Download("https://simulatorcontroller.s3.eu-central-1.amazonaws.com/Releases/VERSION", kUserConfigDirectory . "VERSION")
			}
			catch Any as exception {
				check := false
			}
		}

		if check {
			release := readMultiMap(kUserConfigDirectory . "VERSION")
			version := getMultiMapValue(release, "Release", "Version", getMultiMapValue(release, "Version", "Release", false))

			if version {
				version := StrSplit(version, "-", , 2)
				current := StrSplit(kVersion, "-", , 2)

				versionPostfix := version[2]
				currentPostfix := current[2]

				version := string2Values(".", version[1])
				current := string2Values(".", current[1])

				while (version.Length < current.Length)
					version.Push("0")

				while (current.Length < version.Length)
					current.Push("0")

				version := values2String("", version*)
				current := values2String("", current*)

				if ((version > current) || ((version = current) && (versionPostfix != currentPostfix))) {
					OnMessage(0x44, translateYesNoButtons)
					msgResult := MsgBox(translate("A newer version of Simulator Controller is available. Do you want to download it now?"), translate("Update"), 262436)
					OnMessage(0x44, translateYesNoButtons, 0)

					if (msgResult = "Yes") {
						automaticUpdates := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Simulator Controller.install"), "Updates", "Automatic", true)

						if automaticUpdates
							Run((!A_IsAdmin ? "*RunAs `"" : "`"") . kBinariesDirectory . "Simulator Download.exe`" -NoUpdate -Download -Update -Start `"" . A_ScriptFullPath . "`"")
						else
							Run("https://github.com/SeriousOldMan/Simulator-Controller#latest-release-builds")

						ExitApp(0)
					}
					else if FileExist(kUserConfigDirectory . "VERSION")
						FileSetTime(A_Now, kUserConfigDirectory . "VERSION")
				}
			}
		}
	}

	toolTargets := readMultiMap(getFileName("Simulator Tools.targets", kConfigDirectory))

	userToolTargetsFile := getFileName("Simulator Tools.targets", kUserConfigDirectory)
	userToolTargets := readMultiMap(userToolTargetsFile)

	if (userToolTargets.Count > 0) {
		setMultiMapValues(userToolTargets, "Update", getMultiMapValues(toolTargets, "Update"))

		writeMultiMap(userToolTargetsFile, userToolTargets)
	}

	if (!inList(A_Args, "-NoUpdate") && inList(kForegroundApps, StrSplit(A_ScriptName, ".")[1])) {
		updates := readMultiMap(getFileName("UPDATES", kUserConfigDirectory))

		for target, arguments in getMultiMapValues(toolTargets, "Update")
			if !getMultiMapValue(updates, "Processed", target, false) {
				RunWait(kBinariesDirectory . "Simulator Tools.exe -Update")

				loadSimulatorConfiguration()

				break
			}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

viewHTML(fileName, title := false, x := kUndefined, y := kUndefined, width := 800, height := 400, *) {
	local html, innerWidth, editHeight, buttonX
	local mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom

	static htmlGui
	static htmlViewer

	if !title
		title := translate("News && Updates")

	if !fileName {
		htmlGui.Destroy()

		return
	}

	html := FileRead(fileName)

	innerWidth := width - 16

	htmlGui := Window({Options: "0x400000"}, "")

	htmlGui.SetFont("s10 Bold")

	htmlGui.Add("Text", "x8 y8 W" . innerWidth . " +0x200 +0x1 BackgroundTrans", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(htmlGui, "HTML Viewer"))

	htmlGui.SetFont()

	htmlGui.Add("Text", "x8 yp+26 W" . innerWidth . " +0x200 +0x1 BackgroundTrans", title)

	editHeight := height - 102

	htmlViewer := htmlGui.Add("HTMLViewer", "X8 YP+26 W" . innerWidth . " H" . editHeight)

	htmlViewer.document.open()
	htmlViewer.document.write(html)
	htmlViewer.document.close()

	MonitorGetWorkArea(, &mainScreenLeft, &mainScreenTop, &mainScreenRight, &mainScreenBottom)

	if !getWindowPosition("HTML Viewer", &x, &y) {
		x := kUndefined
		y := kUndefined
	}

	if (x = kUndefined)
		switch x, false {
			case "Left":
				x := 25
			case "Right":
				x := mainScreenRight - width - 25
			default:
				x := "Center"
		}

	if (y = kUndefined)
		switch y, false {
			case "Top":
				y := 25
			case "Bottom":
				y := mainScreenBottom - height - 25
			default:
				y := "Center"
		}

	buttonX := Round(width / 2) - 40

	htmlGui.Add("Button", "Default X" . buttonX . " y+10 w80", translate("Ok")).OnEvent("Click", viewHTML.Bind(false))

	htmlGui.Opt("+AlwaysOnTop")
	htmlGui.Show("X" . x . " Y" . y . " W" . width . " H" . height . " NoActivate")
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

startupApplication() {
	local isCritical := Task.CriticalHandler

	guardExit(*) {
		if (isCritical() && !GetKeyState("Ctrl", "P")) {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("Please wait until all tasks have been finished."), StrSplit(A_ScriptName, ".")[1], 262192)
			OnMessage(0x44, translateOkButton, 0)

			return true
		}
		else
			return false
	}

	Task.CriticalHandler := (*) => guardExit()

	OnExit(guardExit, -1)

	MessageManager.resume()
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

MessageManager.pause()

if (!isDetachedInstallation() && !isDebug() && !inList(kBackgroundApps, StrSplit(A_ScriptName, ".")[1])) {
	checkForUpdates()

	requestShareSessionDatabaseConsent()
	startDatabaseSynchronizer()
	checkForNews()
}