;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Global Application Framework    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
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

#Include "..\Framework\Extensions\Task.ahk"
#Include "..\Framework\Extensions\Messages.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

consentDialog(id, consent := false, *) {
	local consentGui, texts, chosen, x, y, fileName, ignore, section, keyValues, key, value

	static tyrePressuresConsentDropDown
	static carSetupsConsentDropDown
	static raceStrategiesConsentDropDown
	static lapTelemetriesConsentDropDown
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

	consentGui := Window({Descriptor: "Consent", Options: "0x400000"}, translate("Declaration of consent"))

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

	consentGui.Add("Text", "x8 y372 w450 h23 +0x200", translate("Do you want to share your lap telemetry data?"))

	chosen := inList(["Yes", "No", "Undecided"], getMultiMapValue(consent, "Consent", "Share Lap Telemetries", "Undecided"))
	lapTelemetriesConsentDropDown := consentGui.Add("DropDownList", "x460 y372 w332 Choose" . chosen, collect(["Yes", "No", "Ask again later..."], translate))

	consentGui.Add("Text", "x8 y412 w784 h60 -VScroll +Wrap ReadOnly", StrReplace(StrReplace(getMultiMapValue(texts, "Consent", "Information"), "``n", "`n"), "\<>", "="))

	consentGui.Add("Link", "x8 y482 w784 h60 cRed -VScroll +Wrap ReadOnly", StrReplace(StrReplace(getMultiMapValue(texts, "Consent", "Warning"), "``n", "`n"), "\<>", "="))

	consentGui.Add("Button", "x352 y538 w80 h23 Default", translate("Save")).OnEvent("Click", consentDialog.Bind("Close"))

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
				 , "RaceStrategies", ["Yes", "No", "Retry"][raceStrategiesConsentDropDown.Value]
				 , "LapTelemetries", ["Yes", "No", "Retry"][lapTelemetriesConsentDropDown.Value])
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
					result["LapTelemetries"] := "Retry"
				}

				for type, key in Map("TyrePressures", "Share Tyre Pressures", "RaceStrategies", "Share Race Strategies", "CarSetups", "Share Car Setups", "LapTelemetries", "Share Lap Telemetries")
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

startDatabaseSynchronizer() {
	local idFileName, ID, dbIDFileName, dbID
	local options, consent

	if (!ProcessExist("Database Synchronizer.exe") && inList(kForegroundApps, StrSplit(A_ScriptName, ".")[1]) && isProperInstallation()) {
		idFileName := kUserConfigDirectory . "ID"

		ID := StrSplit(FileRead(idFileName), "`n", "`r")[1]

		dbIDFileName := (kDatabaseDirectory . "ID")

		if FileExist(dbIDFileName) {
			try {
				dbID := StrSplit(FileRead(dbIDFileName), "`n", "`r")[1]
			}
			catch Any as exception {
				logError(exception, true)

				dbID := false
			}

			if (ID = dbID) {
				consent := readMultiMap(kUserConfigDirectory . "CONSENT")

				options := ("-ID `"" . ID . "`" -Synchronize " . true)

				if (getMultiMapValue(consent, "Consent", "Share Tyre Pressures", "No") = "Yes")
					options .= " -Pressures"

				if (getMultiMapValue(consent, "Consent", "Share Car Setups", "No") = "Yes")
					options .= " -Setups"

				if (getMultiMapValue(consent, "Consent", "Share Race Strategies", "No") = "Yes")
					options .= " -Strategies"

				if (getMultiMapValue(consent, "Consent", "Share Lap Telemetries", "No") = "Yes")
					options .= " -Telemetries"

				try {
					Run(kBinariesDirectory . "Database Synchronizer.exe " . options)
				}
				catch Any as exception {
					logMessage(kLogCritical, translate("Cannot start Database Synchronizer - please rebuild the applications..."))

					if !kSilentMode
						showMessage(translate("Cannot start Database Synchronizer - please rebuild the applications...")
								  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			}
		}
	}
}

checkForUpdates() {
	local release := false
	local check, lastModified, version, current, releasePostFix, currentPostFix, automaticUpdates, ignore, url
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
			deleteFile(kUserConfigDirectory . "VERSION")

			for ignore, url in ["https://fileshare.impresion3d.pro/filebrowser/api/public/dl/OH13SGRl"
							  , "https://www.dropbox.com/scl/fi/3m941rw7qz7voftjoqalq/VERSION?rlkey=b1r9ecrztj1t3cr0jmmbor6du&st=zhl9bzbm&dl=1"
							  , "http://" . StrSplit(FileRead(kConfigDirectory . "MASTER"), "`n", "`r")[1] . "/Releases/VERSION"
							  , "https://simulatorcontroller.s3.eu-central-1.amazonaws.com/Releases/VERSION"]
				try {
					Download(url, kUserConfigDirectory . "VERSION")

					release := readMultiMap(kUserConfigDirectory . "VERSION")

					if (release.Count > 0)
						break
					else
						release := false
				}
				catch Any as exception {
					logError(exception)
				}

			if !release
				check := false
		}

		if check {
			if FileExist(kUserConfigDirectory . "VERSION")
				FileSetTime(A_Now, kUserConfigDirectory . "VERSION")

			if !release
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
					msgResult := withBlockedWindows(MsgDlg, translate("A newer version of Simulator Controller is available. Do you want to download it now?"), translate("Update"), 262436)
					OnMessage(0x44, translateYesNoButtons, 0)

					if (msgResult = "Yes") {
						automaticUpdates := getMultiMapValue(readMultiMap(kUserConfigDirectory . "Simulator Controller.install"), "Updates", "Automatic", true)

						if automaticUpdates
							Run((!A_IsAdmin ? "*RunAs `"" : "`"") . kBinariesDirectory . "Simulator Download.exe`" -NoUpdate -Download -Update -Start `"" . A_ScriptFullPath . "`"")
						else
							Run("https://github.com/SeriousOldMan/Simulator-Controller#latest-release-build")

						ExitApp(0)
					}
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

showConsentDialog(consent := false) {
	local result, id, type, key

	if !consent
		consent := readMultiMap(kUserConfigDirectory . "CONSENT")

	result := withBlockedWindows(() => consentDialog(getMultiMapValue(consent, "General", "ID"), consent))

	for type, key in Map("TyrePressures", "Share Tyre Pressures", "RaceStrategies", "Share Race Strategies", "CarSetups", "Share Car Setups", "LapTelemetries", "Share Lap Telemetries")
		switch result[type], false {
			case "Yes":
				setMultiMapValue(consent, "Consent", key, "Yes")
			case "No":
				setMultiMapValue(consent, "Consent", key, "No")
			case "Retry":
				setMultiMapValue(consent, "Consent", key, "Undecided")
				setMultiMapValue(consent, "General", "Countdown", 10)
		}

	setMultiMapValue(consent, "Consent", "Date", A_MM . "/" . A_DD . "/" . A_YYYY)

	writeMultiMap(kUserConfigDirectory . "CONSENT", consent)
}

startupApplication() {
	global kLogStartup

	local isCritical := Task.CriticalHandler

	if kLogStartup
		logMessage(kLogOff, "Starting application...")

	guardExit(arguments*) {
		if ((arguments.Length > 0) && inList(["Logoff", "Shutdown"], arguments[1]))
			return false

		if (isCritical() && kGuardExit && !GetKeyState("Ctrl")) {
			OnMessage(0x44, translateOkButton)
			withBlockedWindows(MsgDlg, translate("Please wait until all tasks have been finished."), StrSplit(A_ScriptName, ".")[1], 262192)
			OnMessage(0x44, translateOkButton, 0)

			return true
		}
		else
			return false
	}

	Task.CriticalHandler := (*) => guardExit()

	OnExit(guardExit, -1)

	if kLogStartup
		logMessage(kLogOff, "Starting message handler...")

	MessageManager.resume()

	kLogStartup := false
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

MessageManager.pause()

if (!isDetachedInstallation() && !isDevelopment() && !inList(kBackgroundApps, StrSplit(A_ScriptName, ".")[1])) {
	if kLogStartup
		logMessage(kLogOff, "Checking for updates...")

	checkForUpdates()

	if kLogStartup
		logMessage(kLogOff, "Ensuring database consent...")

	requestShareSessionDatabaseConsent()

	if kLogStartup
		logMessage(kLogOff, "Starting database synchronizer...")

	Task.startTask(startDatabaseSynchronizer, 30000, kLowPriority)
}