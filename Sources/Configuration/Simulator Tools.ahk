;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Build & Maintenance Tool        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Tools.ico
;@Ahk2Exe-ExeName Simulator Tools.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Database.ahk"
#Include "..\Libraries\HTMLViewer.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Database\Libraries\TyresDatabase.ahk"
#Include "..\Database\Libraries\TelemetryDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kToolsConfigurationFile := "Simulator Tools.ini"
global kToolsTargetsFile := "Simulator Tools.targets"

global kUpdateMessages := CaseInsenseMap("updateTranslations", "Updating translations to "
									   , "updatePluginLabels", "Updating plugin labels to "
									   , "updateActionLabels", "Updating action labels to "
									   , "updateActionIcons", "Updating action icons to "
									   , "updatePhraseGrammars", "Updating phrase grammars to ")

global kCompiler := (kAHKDirectory . "Compiler\ahk2exe.exe")

global kSave := "save"
global kRevert := "revert"

global kOk := "ok"
global kCancel := "cancel"

global kUninstallKey := "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SimulatorController"

global kInstallDirectory := (A_ProgramFiles . "\Simulator Controller\")


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global gTargetConfiguration := "Development"
global gTargetConfigurationChanged := false

global gUpdateTargets := []
global gCleanupTargets := []
global gCopyTargets := []
global gBuildTargets := []
global gSpecialTargets := []

global gSplashScreen := false

global gTargetsCount := 0

global gUpdateSettings := CaseInsenseWeakMap()
global gCleanupSettings := CaseInsenseWeakMap()
global gCopySettings := CaseInsenseWeakMap()
global gBuildSettings := CaseInsenseWeakMap()

global gProgressCount := 0


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

installOptions(options, *) {
	local directory, valid, empty, title, innerWidth, chosen, disabled, checked

	static installGui

	static installationTypeDropDown
	static automaticUpdatesCheck
	static startMenuShortcutsCheck
	static desktopShortcutsCheck
	static startConfigurationCheck

	static result := false

	static update := false

	chooseInstallLocationPath(*) {
		local valid, empty, directory, translator

		installGui.Opt("+OwnDialogs")

		translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

		OnMessage(0x44, translator)
		directory := DirSelect("*" . installGui["installLocationPathEdit"].Text, 0, translate("Select Installation folder..."))
		OnMessage(0x44, translator, 0)

		if (directory != "") {
			valid := true
			empty := true

			if !FileExist(directory) {
				try {
					DirCreate(directory)
				}
				catch Any as exception {
					OnMessage(0x44, translateOkButton)
					MsgBox(translate("You must enter a valid directory."), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)

					valid := false
				}
			}
			else if (InStr(kHomeDirectory, directory) != 1)
				loop Files, directory . "\*.*", "FD" {
					empty := false

					break
				}

			if (empty && valid)
				installGui["installLocationPathEdit"].Text := directory
			else if !empty {
				OnMessage(0x44, translateOkButton)
				MsgBox(translate("The installation folder must be empty."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)
			}
		}
	}

	if (options == kOk) {
		directory := installGui["installLocationPathEdit"].Text

		valid := true
		empty := true

		if !update
			if !FileExist(directory) {
				try {
					DirCreate(directory)
				}
				catch Any as exception {
					OnMessage(0x44, translateOkButton)
					MsgBox(translate("You must enter a valid directory."), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)

					valid := false
				}
			}
			else if (InStr(kHomeDirectory, directory) != 1)
				loop Files, directory . "\*.*", "FD" {
					empty := false

					break
				}

		if (empty && valid)
			result := kOk
		else if !empty {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("The installation folder must be empty."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}
	}
	else if (options == kCancel)
		result := kCancel
	else {
		result := false

		installGui := Window({Options: "0x400000"}, "")

		installGui.SetFont("Bold", "Arial")

		installGui.Add("Text", "w330 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(installGui, "Install"))

		installGui.SetFont("Norm", "Arial")

		installGui.Add("Documentation", "x108 YP+20 w130 Center", translate("Install")
					 , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration")

		installGui.Add("Text", "x8 yp+20 w330 0x10")

		installGui.Add("Picture", "yp+10 w50 h50", kIconsDirectory . "Install.ico")

		innerWidth := 330 - 66

		installGui.Add("Text", "X74 YP+5 W" . innerWidth . " H46", translate("Do you want to install Simulator Controller on your system as a portable or as a fully registered Windows application?"))

		chosen := inList(["Registry", "Portable"], options.InstallType)

		disabled := (options.Update ? "Disabled" : "")

		installGui.Add("Text", "x16 yp+60 w100 h23 +0x200", translate("Installation Type"))
		installGui.Add("DropDownList", "x116 yp w80 " . disabled . " Choose" . chosen . " vinstallationTypeDropDown", collect(["Registry", "Portable"], translate))

		installGui.Add("Text", "x16 yp+24 w110 h23 +0x200", translate("Installation Folder"))
		installGui.Add("Edit", "x116 yp w187 h21 " . disabled . " vinstallLocationPathEdit", options.InstallLocation)
		installGui.Add("Button", "x304 yp-1 w23 h23 " . disabled, translate("...")).OnEvent("Click", chooseInstallLocationPath)

		checked := (options.AutomaticUpdates ? "Checked" : "")

		installGui.Add("Text", "x16 yp+34 w100 h23 +0x200", translate("Updates"))
		installGui.Add("CheckBox", "x116 yp+3 w180 " . checked . " vautomaticUpdatesCheck", translate("  Automatic"))

		checked := (options.StartMenuShortcuts ? "Checked" : "")

		installGui.Add("Text", "x16 yp+34 w100 h23 +0x200", translate("Create"))
		installGui.Add("CheckBox", "x116 yp+3 w180 " . checked . " vstartMenuShortcutsCheck", translate("  Start Menu Shortcuts"))

		checked := (options.DesktopShortcuts ? "Checked" : "")

		installGui.Add("Text", "x16 yp+21 w100 h23 +0x200", translate(""))
		installGui.Add("CheckBox", "x116 yp+3 w180 " . checked . " VdesktopShortcutsCheck", translate("  Desktop Shortcuts"))

		checked := (options.StartSetup ? "Checked" : "")

		installGui.Add("Text", "x16 yp+34 w100 h23 +0x200", translate("Start"))
		installGui.Add("CheckBox", "x116 yp+3 w210 " . disabled . " " . checked . " vstartConfigurationCheck", translate("  Configuration when finished..."))

		installGui.Add("Text", "x8 yp+34 w330 0x10")

		installGui.Add("Button", "x170 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", installOptions.Bind(kOk))
		installGui.Add("Button", "x260 yp w80 h23", translate("&Cancel")).OnEvent("Click", installOptions.Bind(kCancel))

		installGui.MarginX := "10", installGui.MarginY := "10"
		installGui.Show("AutoSize Center")

		loop
			Sleep(200)
		until result

		if (result == kOk) {
			options.InstallType := ["Registry", "Portable"][installGui["installationTypeDropDown"].Value]
			options.InstallLocation := installGui["installLocationPathEdit"].Text
			options.AutomaticUpdates := installGui["automaticUpdatesCheck"].Value
			options.StartMenuShortcuts := installGui["startMenuShortcutsCheck"].Value
			options.DesktopShortcuts := installGui["desktopShortcutsCheck"].Value
			options.StartSetup := installGui["startConfigurationCheck"].Value
		}

		installGui.Destroy()

		return (result == kOk)
	}
}

uninstallOptions(options, *) {
	local innerWidth, checked

	static uninstallGui

	static result := false
	static keepUserFilesCheck

	if (options == kOk)
		result := kOk
	else if (options == kCancel)
		result := kCancel
	else {
		result := false

		uninstallGui := Window({Options: "0x400000"}, "")

		uninstallGui.SetFont("Bold", "Arial")

		uninstallGui.Add("Text", "w330 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(uninstallGui, "Uninstall"))

		uninstallGui.SetFont("Norm", "Arial")

		uninstallGui.Add("Documentation", "x108 YP+20 w130 Center", translate("Uninstall")
					   , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration")

		uninstallGui.Add("Text", "x8 yp+20 w330 0x10")

		uninstallGui.Add("Picture", "yp+10 w50 h50", kIconsDirectory . "Install.ico")

		innerWidth := 330 - 66

		uninstallGui.Add("Text", "X74 YP+5 W" . innerWidth . " H46", translate("Do you really want to remove Simulator Controller from your Computer?"))

		checked := (options.DeleteUserFiles ? "" : "Checked")

		uninstallGui.Add("CheckBox", "x74 yp+60 w250 " . checked . " vkeepUserFilesCheck", translate("  Keep user data and configuration files?"))

		uninstallGui.Add("Text", "x8 yp+34 w330 0x10")

		uninstallGui.Add("Button", "x170 yp+10 w80 h23", translate("Ok")).OnEvent("Click", uninstallOptions.Bind(kOk))
		uninstallGui.Add("Button", "x260 yp w80 h23 Default", translate("&Cancel")).OnEvent("Click", uninstallOptions.Bind(kCancel))

		uninstallGui.MarginX := "10", uninstallGui.MarginY := "10"
		uninstallGui.Show("AutoSize Center")

		loop
			Sleep(200)
		until result

		if (result == kOk)
			options.DeleteUserFiles := !uninstallGui["keepUserFilesCheck"].Value

		uninstallGui.Destroy()

		return (result == kOk)
	}
}

exitProcesses(silent := false, force := false) {
	local pid, hasFGProcesses, hasBGProcesses, ignore, app, title, translator, msgResult

	pid := ProcessExist()

	while true {
		hasFGProcesses := false
		hasBGProcesses := false

		for ignore, app in kForegroundApps
			if ProcessExist(app . ".exe") {
				hasFGProcesses := true

				break
			}

		for ignore, app in kBackgroundApps
			if (ProcessExist(app ".exe") != pid) {
				hasBGProcesses := true

				break
			}

		if (hasFGProcesses && !silent) {
			translator := translateMsgBoxButtons.Bind(["Continue", "Cancel"])

			OnMessage(0x44, translator)
			msgResult := MsgBox(translate("Before you can run the update, you must first close all running Simulator Controller applications (not Simulator Tools)."), translate("Installation"), 8500)
			OnMessage(0x44, translator, 0)

			if (msgResult = "Yes")
				continue
			else
				return false
		}

		if hasFGProcesses
			if force
				broadcastMessage(kForegroundApps, "exitApplication")
			else
				return false

		if hasBGProcesses
			broadcastMessage(remove(kBackgroundApps, "Simulator Tools"), "exitApplication")

		return true
	}
}

checkInstallation() {
	global gProgressCount

	local installLocation := ""
	local installInfo, quiet, options, msgResult, hasSplash
	local install, index, options, isNew, packageLocation, ignore, directory, currentDirectory

	installComponents(packageLocation, installLocation) {
		global gProgressCount

		local packageInfo := readMultiMap(packageLocation . "\VERSION")
		local installInfo := readMultiMap(installLocation . "\VERSION")
		local installedComponents := string2Map(",", "->", getMultiMapValue(installInfo
																		  , getMultiMapValue(installInfo, "Current", "Type", "Release")
																		  , "Components", ""))
		local error := false
		local component, version, type, ignore, part, path

		for component, version in string2Map(",", "->"
										   , getMultiMapValue(packageInfo, getMultiMapValue(packageInfo, "Current", "Type")
																		 , "Components", "")) {
			if ((packageLocation = installLocation) || !installedComponents.Has(component)
													|| (VerCompare(version, installedComponents[component]) > 0)) {
				try {
					showProgress({progress: (gProgressCount += 2)
								, message: translate("Downloading ") . component . translate(" files...")})

					Download(getMultiMapValue(packageInfo, "Components", component . "." . version . ".Download"), A_Temp . "\Temp.zip")

					showProgress({progress: (gProgressCount += 2)
								, message: translate("Extracting ") . component . translate(" files...")})

					path := Trim(getMultiMapValue(packageInfo, "Components", component . "." . version . ".Path", ""))

					if (path && (path != "") && (path != "."))
						path := (packageLocation . "\" . path)
					else
						path := packageLocation

					RunWait("PowerShell.exe -Command Expand-Archive -LiteralPath '" . A_Temp . "\Temp.zip' -DestinationPath '" . path . "' -Force", , "Hide")

					showProgress({progress: (gProgressCount += 5)})
				}
				catch Any as exception {
					logError(exception, true)

					error := true
				}
			}
			else {
				version := installedComponents[component]

				for ignore, part in string2Values(",", getMultiMapValue(installInfo, "Components", component . "." . version . ".Content")) {
					path := Trim(getMultiMapValue(packageInfo, "Components", component . "." . version . ".Path", ""))

					if (path && (path != "") && (path != "."))
						path := ("\" . path . "\" . part)
					else
						path := ("\" . part)

					type := FileExist(installLocation . path)

					showProgress({progress: (gProgressCount += 2)
								, message: translate("Copying ") . component . translate(" files...")})

					if (type && InStr(type, "D"))
						DirCopy(installLocation . path, packageLocation . path, 1)
					else if type
						FileCopy(installLocation . path, packageLocation, 1)
				}
			}
		}

		if error {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("Cannot download additional files, because the version repository is currently unavailable. Please start `"Simulator Download`" again later."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}
	}

	try {
		installLocation := RegRead("HKLM\" . kUninstallKey, "InstallLocation")
	}
	catch Any as exception {
		logError(exception, false, false)
	}

	installInfo := readMultiMap(kUserConfigDirectory . "Simulator Controller.install")
	installLocation := getMultiMapValue(installInfo, "Install", "Location", installLocation)

	if inList(A_Args, "-Repair") {
		showProgress({color: "Blue", title: translate("Installing Simulator Controller"), message: translate("...")})

		installComponents(normalizeDirectoryPath(installLocation), normalizeDirectoryPath(installLocation))

		hideProgress()

		ExitApp(0)
	}
	else if inList(A_Args, "-Uninstall") {
		quiet := inList(A_Args, "-Quiet")

		if !A_IsAdmin {
			options := ("-Uninstall -NoUpdate" . (quiet ? " -Quiet" : ""))

			try {
				if A_IsCompiled
					Run("*RunAs `"" . A_ScriptFullPath . "`" /restart " . options)
				else
					Run("*RunAs `"" . A_AhkPath . "`" /restart `"" . A_ScriptFullPath . "`" " . options)
			}
			catch Any as exception {
				logError(exception, true)
			}

			ExitApp(0)
		}

		if !exitProcesses()
			ExitApp(1)

		options := {InstallType: getMultiMapValue(installInfo, "Install", "Type", "Registry")
				  , InstallLocation: normalizeDirectoryPath(installLocation)
				  , AutomaticUpdates: getMultiMapValue(installInfo, "Updates", "Automatic", true)
				  , DesktopShortcuts: getMultiMapValue(installInfo, "Shortcuts", "Desktop", false)
				  , StartMenuShortcuts: getMultiMapValue(installInfo, "Shortcuts", "StartMenu", true)
				  , DeleteUserFiles: false}

		if (quiet || uninstallOptions(options)) {
			hasSplash := showSplashScreen("McLaren 720s GT3 Pictures")

			gProgressCount := 0

			showProgress({color: "Blue", title: translate("Uninstalling Simulator Controller"), message: translate("...")})

			deleteFiles(options.InstallLocation)

			if options.DeleteUserFiles {
				showProgress({message: translate("Removing User files...")})

				deleteDirectory(kUserHomeDirectory)
			}
			else
				deleteFile(kUserConfigDirectory . "Simulator Controller.install")

			if options.StartMenuShortcuts {
				showProgress({progress: gProgressCount, message: translate("Removing Start menu shortcuts...")})

				deleteShortcuts(A_StartMenu)
			}

			if options.DesktopShortcuts {
				showProgress({progress: gProgressCount, message: translate("Removing Desktop shortcuts...")})

				deleteShortcuts(A_Desktop)
			}

			gProgressCount += 5

			if (options.InstallType = "Registry") {
				showProgress({progress: gProgressCount, message: translate("Updating Registry...")})

				deleteAppPaths()
				deleteUninstallerInfo()
			}

			if (installLocation != A_ProgramFiles)
				removeDirectory(installLocation)

			showProgress({progress: 100, message: translate("Finished...")})

			Sleep(1000)

			if hasSplash
				hideSplashScreen()

			hideProgress()

			ExitApp(0)
		}
	}
	else {
		install := inList(A_Args, "-Install")
		install := (install || (installLocation && (installLocation != "") && (InStr(kHomeDirectory, installLocation) != 1)))
		install := (install || !installLocation || (installLocation = ""))

		if install {
			if !A_Is64bitOS {
				OnMessage(0x44, translateOkButton)
				MsgBox(translate("Simulator Controller can only be installed on a 64-bit Windows installation. Setup will exit..."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				ExitApp(1)
			}

			if !A_IsAdmin {
				index := inList(A_Args, "-Start")

				options := (index ? ("-Start " . "`"" . A_Args[index + 1] . "`"") : "")

				try {
					if A_IsCompiled
						Run("*RunAs `"" . A_ScriptFullPath . "`" /restart -NoUpdate " . options)
					else
						Run("*RunAs `"" . A_AhkPath . "`" /restart `"" . A_ScriptFullPath . "`" -NoUpdate " . options)
				}
				catch Any as exception {
					logError(exception)
				}

				ExitApp(0)
			}

			if (!installLocation || (installLocation = ""))
				installLocation := normalizeDirectoryPath(kInstallDirectory)

			isNew := !FileExist(installLocation)

			if !isNew
				if !exitProcesses()
					ExitApp(1)

			options := {InstallType: getMultiMapValue(installInfo, "Install", "Type", "Registry")
					  , InstallLocation: normalizeDirectoryPath(getMultiMapValue(installInfo, "Install", "Location", installLocation))
					  , AutomaticUpdates: getMultiMapValue(installInfo, "Updates", "Automatic", true)
					  , Verbose: getMultiMapValue(installInfo, "Updates", "Verbose", false)
					  , DesktopShortcuts: getMultiMapValue(installInfo, "Shortcuts", "Desktop", false)
					  , StartMenuShortcuts: getMultiMapValue(installInfo, "Shortcuts", "StartMenu", true)
					  , StartSetup: isNew, Update: !isNew}

			packageLocation := normalizeDirectoryPath(kHomeDirectory)

			if ((!isNew && !options.Verbose) || installOptions(options)) {
				installLocation := options.InstallLocation

				setMultiMapValue(installInfo, "Install", "Type", options.InstallType)
				setMultiMapValue(installInfo, "Install", "Location", installLocation)
				setMultiMapValue(installInfo, "Updates", "Automatic", options.AutomaticUpdates)
				setMultiMapValue(installInfo, "Updates", "Verbose", options.Verbose)
				setMultiMapValue(installInfo, "Shortcuts", "Desktop", options.DesktopShortcuts)
				setMultiMapValue(installInfo, "Shortcuts", "StartMenu", options.StartMenuShortcuts)

				gProgressCount := 0

				showProgress({color: "Blue", title: translate("Installing Simulator Controller"), message: translate("...")})

				try {
					installComponents(packageLocation, installLocation)

					for ignore, directory in [kBinariesDirectory, kResourcesDirectory . "Setup\Installer\"] {
						gProgressCount += 1

						showProgress({progress: gProgressCount, message: translate("Unblocking Applications and DLLs...")})

						currentDirectory := A_WorkingDir

						try {
							SetWorkingDir(directory)

							RunWait("Powershell -Command Get-ChildItem -Path '.' -Recurse | Unblock-File", , "Hide")
						}
						catch Any as exception {
							logError(exception)
						}
						finally {
							SetWorkingDir(currentDirectory)
						}
					}

					if (installLocation != packageLocation)
						copyFiles(packageLocation, installLocation, !isNew)
					else {
						gProgressCount := 80

						showProgress({progress: gProgressCount, message: translate("Download and installation folders are identical...")})

						Sleep(1000)
					}

					if options.StartMenuShortcuts {
						showProgress({progress: gProgressCount++, message: translate("Creating Start menu shortcuts...")})

						createShortcuts(A_StartMenu, installLocation)
					}
					else {
						showProgress({progress: gProgressCount++, message: translate("Removing Start menu shortcuts...")})

						deleteShortcuts(A_StartMenu)
					}

					if options.DesktopShortcuts {
						showProgress({progress: gProgressCount++, message: translate("Creating Desktop shortcuts...")})

						createShortcuts(A_Desktop, installLocation)
					}
					else {
						showProgress({progress: gProgressCount++, message: translate("Removing Desktop shortcuts...")})

						deleteShortcuts(A_Desktop)
					}

					if (options.InstallType = "Registry") {
						showProgress({progress: gProgressCount++, message: translate("Updating Registry...")})

						writeAppPaths(installLocation)
						writeUninstallerInfo(installLocation)
					}

					fixIE(11, "Session Database.exe")
					fixIE(11, "Setup Workbench.exe")
					fixIE(11, "Race Reports.exe")
					fixIE(11, "Strategy Workbench.exe")
					fixIE(11, "Race Center.exe")
					fixIE(10, "Simulator Setup.exe")
					fixIE(11, "System Monitor.exe")

					writeMultiMap(kUserConfigDirectory . "Simulator Controller.install", installInfo)

					if (installLocation != packageLocation) {
						showProgress({progress: gProgressCount++, message: translate("Removing installation files...")})

						if InStr(packageLocation, A_Temp)
							removeDirectory(packageLocation)
						else {
							OnMessage(0x44, translateYesNoButtons)
							msgResult := MsgBox(translate("Do you want to remove the folder with the installation files?"), translate("Installation"), 262436)
							OnMessage(0x44, translateYesNoButtons, 0)

							if (msgResult = "Yes")
								removeDirectory(packageLocation)
						}
					}
				}
				catch Any as exception {
					logError(exception)
				}

				showProgress({progress: 100, message: translate("Finished...")})

				deleteDirectory(kLogsDirectory)
				deleteDirectory(kTempDirectory)

				DirCreate(kLogsDirectory)
				DirCreate(kTempDirectory)

				Sleep(1000)

				hideProgress()

				if isNew {
					if options.StartSetup
						Run(installLocation . "\Binaries\Simulator Setup.exe")
				}
				else {
					Run("https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Notes")

					index := inList(A_Args, "-Start")

					if index
						Run(A_Args[index + 1])
				}
			}
			else {
				if (isNew || (options.InstallLocation != packageLocation))
					if InStr(packageLocation, A_Temp)
						removeDirectory(packageLocation)
					else {
						OnMessage(0x44, translateYesNoButtons)
						msgResult := MsgBox(translate("Do you want to remove the folder with the installation files?"), translate("Installation"), 262436)
						OnMessage(0x44, translateYesNoButtons, 0)

						if (msgResult = "Yes")
							removeDirectory(packageLocation)
					}
			}

			ExitApp(0)
		}
	}
}

copyFiles(source, destination, deleteOrphanes) {
	global gProgressCount

	local count := 0
	local progress := 0
	local step, stepCount

	loop Files, source . "\*", "DFR" {
		if (Mod(count, 100) == 0)
			progress += 1

		showProgress({progress: gProgressCount + Min(progress, 10), message: translate("Validating ") . A_LoopFileName . translate("...")})

		Sleep(1)

		count += 1
	}

	gProgressCount += 10

	showProgress({color: "Green"})

	step := ((deleteOrphanes ? 70 : 80) / count)
	stepCount := 0

	copyDirectory(source, destination, step, &stepCount)

	gProgressCount := (gProgressCount + Round(step * count))

	showProgress({progress: gProgressCount})

	if deleteOrphanes {
		showProgress({message: translate("Searching for orphane files...")})

		stepCount := 0

		cleanupDirectory(source, destination, 10, &stepCount)

		gProgressCount := (gProgressCount + 10)

		showProgress({progress: gProgressCount})
	}
}

deleteFiles(installLocation) {
	global gProgressCount

	local count := 0
	local progress := 0
	local step, stepCount

	loop Files, installLocation . "\*", "DFR" {
		if (Mod(count, 100) == 0)
			progress += 1

		showProgress({progress: gProgressCount + Min(progress, 20), message: translate("Preparing ") . A_LoopFileName . translate("...")})

		Sleep(1)

		count += 1
	}

	gProgressCount += 20

	showProgress({color: "Green"})

	step := (70 / count)
	stepCount := 0

	clearDirectory(installLocation, step, &stepCount)

	gProgressCount := (gProgressCount + Round(step * count))

	showProgress({progress: gProgressCount})
}

copyDirectory(source, destination, progressStep, &count) {
	local files := []
	local ignore, fileName, file, subDirectory

	DirCreate(destination)

	loop Files, source . "\*.*", "DF"
		files.Push(A_LoopFilePath)

	for ignore, fileName in files {
		SplitPath(fileName, &file)

		count += 1

		showProgress({progress: Round(gProgressCount + (count * progressStep)), message: translate("Copying ") . file . translate("...")})

		if InStr(FileExist(fileName), "D") {
			SplitPath(fileName, &subDirectory)

			copyDirectory(fileName, destination . "\" . subDirectory, progressStep, &count)
		}
		else
			FileCopy(fileName, destination, 1)
	}
}

clearDirectory(directory, progressStep, &count) {
	local files := []
	local ignore, fileName, subDirectory, file

	loop Files, directory . "\*.*", "DF"
		files.Push(A_LoopFilePath)

	for ignore, fileName in files {
		SplitPath(fileName, &file)

		count += 1

		showProgress({progress: Round(gProgressCount + (count * progressStep)), message: translate("Deleting ") . file . translate("...")})

		if InStr(FileExist(fileName), "D") {
			SplitPath(fileName, &subDirectory)

			clearDirectory(directory . "\" . subDirectory, progressStep, &count)
		}
		else
			deleteFile(fileName)

		Sleep(1)
	}
}

cleanupDirectory(source, destination, maxStep, &count) {
	local fileName

	loop Files, destination . "\*.*", "DF" {
		SplitPath(A_LoopFilePath, &fileName)

		if InStr(FileExist(A_LoopFilePath), "D") {
			cleanupDirectory(source . "\" . fileName, A_LoopFilePath, maxStep, &count)

			try {
				DirDelete(A_LoopFilePath)
			}
			catch Any as exception {
			}
		}
		else if !FileExist(source . "\" . fileName) {
			count := Min(count + 1, maxStep)

			showProgress({progress: gProgressCount + count, message: translate("Deleting ") . fileName . translate("...")})

			deleteFile(A_LoopFilePath)

			Sleep(100)
		}
	}
}

removeDirectory(directory) {
	local command

	deleteFile(A_Temp . "\Cleanup.bat")

	command := "
(
ping 127.0.0.1 -n 15 > nul
cd C:\
rmdir "%directory%" /s /q
)"

	FileAppend(substituteVariables(command, {directory: directory}), A_Temp . "\Cleanup.bat")

	Run("`"" . A_Temp . "\Cleanup.bat`"", "C:\", "Hide")
}

createShortcuts(location, installLocation) {
	local ignore, name

	if (location = A_StartMenu) {
		DirCreate(location "\Simulator Controller")

		location := (location . "\Simulator Controller")

		FileCreateShortcut(installLocation . "\Binaries\Simulator Tools.exe", location . "\Uninstall.lnk", installLocation . "\Binaries", "-Uninstall")

		for ignore, name in ["Simulator Startup", "Simulator Settings", "Simulator Setup", "Simulator Configuration", "Race Settings", "Session Database"
						   , "Race Reports", "Strategy Workbench", "Race Center", "Server Administration", "Setup Workbench"]
			FileCreateShortcut(installLocation . "\Binaries\" . name . ".exe", location . "\" . name . ".lnk", installLocation . "\Binaries")
	}
	else
		for ignore, name in ["Simulator Startup", "Simulator Settings"]
			FileCreateShortcut(installLocation . "\Binaries\" . name . ".exe", location . "\" . name . ".lnk", installLocation . "\Binaries")

	FileCreateShortcut(installLocation . "\Documentation.url", location . "\Documentation.lnk", installLocation)
}

deleteShortcuts(location) {
	local deleteFolder := false
	local ignore, name

	if (location = A_StartMenu) {
		location := (A_StartMenu . "\Simulator Controller")

		deleteFolder := true

		deleteFile(location . "\Uninstall.lnk")
	}

	for ignore, name in ["Simulator Startup", "Simulator Settings", "Simulator Setup", "Simulator Configuration", "Race Settings", "Session Database"
					   , "Race Reports", "Strategy Workbench", "Race Center", "Server Administration", "Setup Workbench"]
		deleteFile(location . "\" . name . ".lnk")

	deleteFile(location . "\Documentation.lnk")

	if deleteFolder
		deleteDirectory(location)
}

writeAppPaths(installLocation) {
	RegWrite(installLocation . "\Binaries\Simulator Startup.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorStartup.exe")
	RegWrite(installLocation . "\Binaries\Simulator Controller.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorController.exe")
	RegWrite(installLocation . "\Binaries\Simulator Settings.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorSettings.exe")
	RegWrite(installLocation . "\Binaries\Simulator Setup.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorSetup.exe")
	RegWrite(installLocation . "\Binaries\Simulator Configuration.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorConfiguration.exe")
	RegWrite(installLocation . "\Binaries\Race Settings.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceSettings.exe")
	RegWrite(installLocation . "\Binaries\Session Database.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SessionDatabase.exe")
	RegWrite(installLocation . "\Binaries\Race Reports.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceReports.exe")
	RegWrite(installLocation . "\Binaries\Strategy Workbench.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\StrategyWorkbench.exe")
	RegWrite(installLocation . "\Binaries\Practice Center.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\PracticeCenter.exe")
	RegWrite(installLocation . "\Binaries\Race Center.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceCenter.exe")
	RegWrite(installLocation . "\Binaries\Server Administration.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ServerAdministration.exe")
	RegWrite(installLocation . "\Binaries\SetupWorkbench.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SetupWorkbench.exe")
}

deleteAppPaths() {
	deleteRegEntry(path) {
		try {
			RegDelete(path)
		}
		catch Any as exception {
			logError(exception, false, false)
		}
	}

	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorStartup.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorController.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorSettings.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorSetup.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorConfiguration.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceSettings.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SessionDatabase.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceReports.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\StrategyWorkbench.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\PracticeCenter.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceCenter.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ServerAdministration.exe")
	deleteRegEntry("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SetupWorkbench.exe")
}

writeUninstallerInfo(installLocation) {
	local version := StrSplit(kVersion, "-", , 2)[1]

	RegWrite("Simulator Controller", "REG_SZ", "HKLM\" . kUninstallKey, "DisplayName")
	RegWrite(installLocation, "REG_SZ", "HKLM\" . kUninstallKey, "InstallLocation")
	RegWrite(A_YYYY . A_MM . A_DD, "REG_SZ", "HKLM\" . kUninstallKey, "InstallDate")
	RegWrite("`"" . installLocation . "\Binaries\Simulator Tools.exe`" -Uninstall", "REG_SZ", "HKLM\" . kUninstallKey, "UninstallString")
	RegWrite("`"" . installLocation . "\Binaries\Simulator Tools.exe`" -Uninstall -Quiet", "REG_SZ", "HKLM\" . kUninstallKey, "QuietUninstallString")
	RegWrite("`"" . installLocation . "\Resources\Icons\Artificial Intelligence.ico`"", "REG_SZ", "HKLM\" . kUninstallKey, "DisplayIcon")
	RegWrite(version, "REG_SZ", "HKLM\" . kUninstallKey, "DisplayVersion")
	RegWrite("https://github.com/SeriousOldMan/Simulator-Controller/wiki", "REG_SZ", "HKLM\" . kUninstallKey, "URLInfoAbout")
	RegWrite("Oliver Juwig (TheBigO)", "REG_SZ", "HKLM\" . kUninstallKey, "Publisher")
	RegWrite(1, "REG_SZ", "HKLM\" . kUninstallKey, "NoModify")
}

deleteUninstallerInfo() {
	try {
		RegDeleteKey("HKLM\" . kUninstallKey)
	}
	catch Any as exception {
		logError(exception, false, false)
	}
}

readToolsConfiguration(&updateSettings, &cleanupSettings, &copySettings, &buildSettings
					 , &splashScreen, &targetConfiguration) {
	local targets := readMultiMap(kToolsTargetsFile)
	local configuration := readMultiMap(kToolsConfigurationFile)
	local updateConfiguration := readMultiMap(getFileName("UPDATES", kUserConfigDirectory))
	local target, rule

	updateSettings := CaseInsenseWeakMap()
	cleanupSettings := CaseInsenseWeakMap()
	copySettings := CaseInsenseWeakMap()
	buildSettings := CaseInsenseWeakMap()

	for target, rule in getMultiMapValues(targets, "Update")
		if !getMultiMapValue(updateConfiguration, "Processed", target, false)
			updateSettings[target] := true

	for target, rule in getMultiMapValues(targets, "Cleanup") {
		if !InStr(target, "*.bak")
			target := ConfigurationItem.splitDescriptor(target)[1]

		cleanupSettings[target] := getMultiMapValue(configuration, "Cleanup", target, InStr(target, "*.ahk") ? true : false)
	}

	for target, rule in getMultiMapValues(targets, "Copy") {
		target := ConfigurationItem.splitDescriptor(target)[1]

		copySettings[target] := getMultiMapValue(configuration, "Copy", target, true)
	}

	for target, rule in getMultiMapValues(targets, "Build") {
		target := ConfigurationItem.splitDescriptor(target)[1]

		buildSettings[target] := getMultiMapValue(configuration, "Build", target, true)
	}

	splashScreen := getMultiMapValue(configuration, "General", "Splash Screen", false)
	targetConfiguration := getMultiMapValue(configuration, "Compile", "TargetConfiguration", "Development")

	if A_IsCompiled
		buildSettings["Simulator Tools"] := false
}

writeToolsConfiguration(updateSettings, cleanupSettings, copySettings, buildSettings, splashScreen, targetConfiguration) {
	local configuration := newMultiMap()
	local target, setting

	for target, setting in cleanupSettings
		setMultiMapValue(configuration, "Cleanup", target, setting)

	for target, setting in copySettings
		setMultiMapValue(configuration, "Copy", target, setting)

	for target, setting in buildSettings
		setMultiMapValue(configuration, "Build", target, setting)

	setMultiMapValue(configuration, "General", "Splash Screen", splashScreen)
	setMultiMapValue(configuration, "Compile", "TargetConfiguration", targetConfiguration)

	writeMultiMap(kToolsConfigurationFile, configuration)
}

viewBuildLog(fileName, title := "", x := "Center", y := "Center", width := 800, height := 400) {
	local text, innerWidth, editHeight
	local mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom, buildLogGui

	static dismissed := false

	dismissed := false

	if !fileName {
		dismissed := true

		return
	}

	text := FileRead(fileName)

	innerWidth := width - 16

	buildLogGui := Window({Options: "0x400000"}, "")

	buildLogGui.SetFont("s10 Bold", "Arial")

	buildLogGui.Add("Text", "x8 y8 W" . innerWidth . " +0x200 +0x1 BackgroundTrans", translate("Modular Simulator Controller System - Compiler"))

	buildLogGui.SetFont("Norm", "Arial")

	buildLogGui.Add("Text", "x8 yp+26 W" . innerWidth . " +0x200 +0x1 BackgroundTrans", title)

	editHeight := height - 102

	buildLogGui.Add("Edit", "X8 YP+26 W" . innerWidth . " H" . editHeight, text)

	MonitorGetWorkArea(, &mainScreenLeft, &mainScreenTop, &mainScreenRight, &mainScreenBottom)

	if !isInteger(x)
		switch x, false {
			case "Left":
				x := 25
			case "Right":
				x := mainScreenRight - width - 25
			default:
				x := "Center"
		}

	if !isInteger(y)
		switch y, false {
			case "Top":
				y := 25
			case "Bottom":
				y := mainScreenBottom - height - 25
			default:
				y := "Center"
		}

	buildLogGui.Add("Button", "Default X" . (Round(width / 2) - 40) . " y+10 w80", translate("Ok")).OnEvent("Click", viewBuildLog.Bind(false))

	buildLogGui.Opt("+AlwaysOnTop")
	buildLogGui.Show("X" . x . " Y" . y . " W" . width . " H" . height . " NoActivate")

	while !dismissed
		Sleep(100)

	buildLogGui.Destroy()
}

editTargets(command := "", *) {
	global gSplashScreen, gTargetConfiguration, gTargetConfigurationChanged

	local target, setting, updateVariable, cleanupVariable, copyVariable, buildVariable, updateHeight, cleanupHeight
	local cleanupPosOption, option, copyHeight, buildHeight, splashScreens, chosen, yPos, x, y, targetConfiguration

	static targetsGui

	static result

	if (command == kSave) {
		for target, setting in gUpdateSettings
			gUpdateSettings[target] := targetsGui["updateVariable" . gUpdateSettings.Count].Value

		for target, setting in gCleanupSettings
			gCleanupSettings[target] := targetsGui["cleanupVariable" . A_Index].Value

		for target, setting in gCopySettings
			gCopySettings[target] := targetsGui["copyVariable" . A_Index].Value

		for target, setting in gBuildSettings
			gBuildSettings[target] := targetsGui["buildVariable" . A_Index].Value

		gSplashScreen := ((targetsGui["splashScreen"].Text == translate("None")) ? false : targetsGui["splashScreen"].Text)

		targetConfiguration := ["Development", "Production"][targetsGui["targetConfiguration"].Value]

		if (gTargetConfiguration != targetConfiguration)
			gTargetConfigurationChanged := true

		gTargetConfiguration := targetConfiguration

		writeToolsConfiguration(gUpdateSettings, gCleanupSettings, gCopySettings, gBuildSettings, gSplashScreen, gTargetConfiguration)

		result := 1
	}
	else if (command == kRevert) {
		result := 2
	}
	else if (command == kCancel) {
		result := 3
	}
	else {
		result := false

		targetsGui := Window({Descriptor: "Simulator Tools", Closeable: true, Options: "+SysMenu +Caption"})

		targetsGui.SetFont("Bold", "Arial")

		targetsGui.Add("Text", "w410 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(targetsGui, "Simulator Tools"))

		targetsGui.SetFont("Norm", "Arial")
		targetsGui.SetFont("Italic", "Arial")

		targetsGui.Add("Text", "YP+20 w410 Center", translate("Targets"))

		targetsGui.SetFont("Norm", "Arial")
		targetsGui.SetFont("Italic", "Arial")

		updateHeight := 0

		if (gUpdateSettings.Count > 0) {
			updateHeight := (20 + (Min(gUpdateSettings.Count, 1) * 20))

			if (updateHeight == 20)
				updateHeight := 40

			targetsGui.Add("GroupBox", "YP+30 w200 h" . updateHeight, translate("Update"))

			targetsGui.SetFont("Norm", "Arial")

			if (gUpdateSettings.Count > 0) {
				for target, setting in gUpdateSettings {
					if (A_Index == gUpdateSettings.Count)
						targetsGui.Add("CheckBox", "YP+20 XP+10 Disabled Checked" . setting . " vupdateVariable" . A_Index, target)
				}
			}
			else
				targetsGui.Add("Text", "YP+20 XP+10", translate("No updates required..."))

			targetsGui.SetFont("Norm", "Arial")
			targetsGui.SetFont("Italic", "Arial")

			cleanupPosOption := "XP-10"
		}
		else
			cleanupPosOption := ""

		cleanupHeight := 20 + (gCleanupSettings.Count * 20)

		if (cleanupHeight == 20)
			cleanupHeight := 40

		targetsGui.Add("GroupBox", "" . cleanupPosOption . " YP+30 w200 h" . cleanupHeight . " Section", translate("Cleanup"))

		targetsGui.SetFont("Norm", "Arial")

		if (gCleanupSettings.Count > 0) {
			for target, setting in gCleanupSettings {
				option := ""

				if (A_Index == 1)
					option := option . " YP+20 XP+10"

				targetsGui.Add("CheckBox", option . " Checked" . setting . " vcleanupVariable" . A_Index, target)
			}
		}
		else
			targetsGui.Add("Text", "YP+20 XP+10", translate("No targets found..."))

		targetsGui.SetFont("Norm", "Arial")
		targetsGui.SetFont("Italic", "Arial")

		copyHeight := 20 + (gCopySettings.Count * 20)

		if (copyHeight == 20)
			copyHeight := 40

		targetsGui.Add("GroupBox", "XP-10 YP+30 w200 h" . copyHeight, translate("Copy"))

		targetsGui.SetFont("Norm", "Arial")

		if (gCopySettings.Count > 0) {
			for target, setting in gCopySettings {
				option := ""

				if (A_Index == 1)
					option := option . " YP+20 XP+10"

				targetsGui.Add("CheckBox", option . " Checked" . setting . " vcopyVariable" . A_Index, target)
			}
		}
		else
			targetsGui.Add("Text", "YP+20 XP+10", translate("No targets found..."))

		targetsGui.SetFont("Norm", "Arial")
		targetsGui.SetFont("Italic", "Arial")

		buildHeight := 20 + (gBuildSettings.Count * 20)

		if (buildHeight == 20)
			buildHeight := 40

		targetsGui.Add("GroupBox", "X220 YS w200 h" . buildHeight, translate("Compile"))

		targetsGui.SetFont("Norm", "Arial")

		if (gBuildSettings.Count > 0) {
			for target, setting in gBuildSettings {
				option := ""

				if (A_Index == 1)
					option := option . " YP+20 XP+10"

				if (target == "Simulator Tools")
					option := option . (A_IsCompiled ? " Disabled" : "")

				targetsGui.Add("CheckBox", option . " Checked" . setting . " vbuildVariable" . A_Index, target)
			}
		}
		else
			targetsGui.Add("Text", "YP+20 XP+10", translate("No targets found..."))

		yPos := (Max(cleanupHeight + copyHeight + (updateHeight ? updateHeight + 10 : 0), buildHeight) + 86)

		chosen := inList(["Development", "Production"], gTargetConfiguration)

		targetsGui.Add("Text", "X10 Y" . yPos, translate("Target"))
		targetsGui.Add("DropDownList", "X110 YP-5 w310 Choose" . chosen . " vtargetConfiguration", collect(["Development", "Production"], translate))

		splashScreens := getAllSplashScreens()
		chosen := (gSplashScreen ? inList(splashScreens, gSplashScreen) + 1 : 1)

		targetsGui.Add("Text", "X10 YP+30", translate("Splash Screen"))
		targetsGui.Add("DropDownList", "X110 YP-5 w310 Choose" . chosen . " vsplashScreen", concatenate([translate("None")], splashScreens))

		targetsGui.Add("Button", "Default X110 y+20 w100", translate("Run")).OnEvent("Click", editTargets.Bind(kSave))
		targetsGui.Add("Button", "X+10 w100", translate("&Cancel")).OnEvent("Click", editTargets.Bind(kCancel))

		targetsGui.MarginX := "10", targetsGui.MarginY := "10"

		if getWindowPosition("Simulator Tools", &x, &y)
			targetsGui.Show("x" . x . " y" . y)
		else
			targetsGui.Show()

		loop
			Sleep(1000)
		until result

		targetsGui.Destroy()

		return ((result == 1) || (result == 2))
	}
}

updatePhraseGrammars() {
	/* Obsolete since 4.0.4...
	languages := availableLanguages()

	for ignore, filePrefix in ["Race Engineer.grammars.", "Race Strategist.grammars.", "Race Spotter.grammars."]
		for ignore, grammarFileName in getFileNames(filePrefix . "*", kUserGrammarsDirectory, kUserConfigDirectory) {
			SplitPath grammarFileName, , , languageCode

			userGrammars := readMultiMap(grammarFileName)
			bundledGrammars := readMultiMap(getFileName(filePrefix . languageCode, kGrammarsDirectory, kConfigDirectory))

			for section, keyValues in bundledGrammars
				for key, value in keyValues
					if (getMultiMapValue(userGrammars, section, key, kUndefined) == kUndefined)
						setMultiMapValue(userGrammars, section, key, value)

			writeMultiMap(grammarFileName, userGrammars)
		}
	*/
}

updateTranslations() {
	/* Obsolete since 4.0.4...
	languages := availableLanguages()

	for ignore, translationFileName in getFileNames("Translations.*", kUserTranslationsDirectory, kUserConfigDirectory) {
		SplitPath translationFileName, , , languageCode

		translations := readTranslations(languageCode)

		if (FileExist(getFileName(kTranslationsDirectory . "Translations." . languageCode)) || FileExist(getFileName(kConfigDirectory . "Translations." . languageCode)))
			originalLanguageCode := languageCode
		else
			originalLanguageCode := "en"

		for original, translation in readTranslations(originalLanguageCode, false)
			if !translations.HasKey(original)
				translations[original] := translation

		writeTranslations(languageCode, languages[languageCode], translations)
	}
	*/
}

deleteActionLabels() {
	deletePluginLabels("Controller Action Labels")
}

deletePluginLabels(fileName := "Controller Plugin Labels") {
	local ignore, fName

	for ignore, fName in getFileNames(fileName . ".*", kUserTranslationsDirectory)
		try {
			FileMove(fName, fName . ".bak", 1)
		}
		catch Any as exception {
			logError(exception)
		}
}

updateActionDefinitions(fileName := "Controller Plugin Labels", preset := false) {
	local languages, enDefinitions, ignore, userDefinitionsFile, languageCode, bundledDefinitions, changed
	local section, keyValues, key, value, keys, userDefinitions

	if preset {
		languages := availableLanguages()
		enDefinitions := readMultiMap(kResourcesDirectory . "Setup\Presets\" . fileName . ".en")

		for ignore, userDefinitionsFile in getFileNames(fileName . ".*", kUserTranslationsDirectory) {
			SplitPath(userDefinitionsFile, , , &languageCode)

			if (!languages.Has(languageCode) || (languageCode = "en"))
				bundledDefinitions := enDefinitions
			else {
				bundledDefinitions := readMultiMap(kResourcesDirectory . "Setup\Presets\" . fileName . "." . languageCode)

				if (bundledDefinitions.Count == 0)
					bundledDefinitions := enDefinitions
			}

			userDefinitions := readMultiMap(userDefinitionsFile)
			changed := false

			for section, keyValues in bundledDefinitions
				for key, value in keyValues
					if (getMultiMapValue(userDefinitions, section, key, kUndefined) == kUndefined) {
						setMultiMapValue(userDefinitions, section, key, value)

						changed := true
					}

			if changed
				writeMultiMap(userDefinitionsFile, userDefinitions)
		}
	}
	else {
		/* Obsolete since 4.0.4...
		languages := availableLanguages()
		enDefinitions := readMultiMap(kResourcesDirectory . "Templates\" . fileName . ".en")

		for ignore, userDefinitionsFile in getFileNames(fileName . ".*", kUserTranslationsDirectory, kUserConfigDirectory) {
			SplitPath userDefinitionsFile, , , languageCode

			if (!languages.HasKey(languageCode) || (languageCode = "en"))
				bundledDefinitions := enDefinitions
			else {
				bundledDefinitions := readMultiMap(kResourcesDirectory . "Templates\" . fileName . "." . languageCode)

				if (bundledDefinitions.Count == 0)
					bundledDefinitions := enDefinitions
			}

			userDefinitions := readMultiMap(userDefinitionsFile)
			changed := false

			for section, keyValues in bundledDefinitions
				for key, value in keyValues
					if (getMultiMapValue(userDefinitions, section, key, kUndefined) == kUndefined) {
						setMultiMapValue(userDefinitions, section, key, value)

						changed := true
					}

			for section, keyValues in userDefinitions {
				keys := []

				for key, value in keyValues
					if (getMultiMapValue(bundledDefinitions, section, key, kUndefined) == kUndefined) {
						keys.Push(key)

						changed := true
					}

				for ignore, key in keys
					removeMultiMapValue(userDefinitions, section, key)
			}

			if changed
				writeMultiMap(userDefinitionsFile, userDefinitions)
		}
		*/
	}
}

updateActionLabels() {
	updateActionDefinitions("Controller Action Labels")
}

updateActionIcons() {
	updateActionDefinitions("Controller Action Icons")
}

updateStreamDeckIconPreset() {
	updateActionDefinitions("Controller Action Icons", true)
}

updateCustomCalls(startNumber, endNumber) {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readMultiMap(userConfigurationFile)
	local bundledConfiguration, customCallIndex, key

	if (userConfiguration.Count > 0) {
		bundledConfiguration := readMultiMap(getFileName(kSimulatorConfigurationFile, kConfigDirectory))

		customCallIndex := startNumber

		loop {
			key := ("Custom." . customCallIndex)

			if (getMultiMapValue(userConfiguration, "Controller Functions", key, kUndefined) == kUndefined) {
				setMultiMapValue(userConfiguration, "Controller Functions", key, getMultiMapValue(bundledConfiguration, "Controller Functions", key))

				key .= ".Action"

				setMultiMapValue(userConfiguration, "Controller Functions", key, getMultiMapValue(bundledConfiguration, "Controller Functions", key))
			}

			customCallIndex += 1
		}
		until (customCallIndex > endNumber)

		writeMultiMap(userConfigurationFile, userConfiguration)
	}
}

renewConsent() {
	local consent := readMultiMap(kUserConfigDirectory . "CONSENT")

	if (consent.Count > 0) {
		setMultiMapValue(consent, "General", "ReNew", true)

		writeMultiMap(kUserConfigDirectory . "CONSENT", consent)
	}
}

updateInstallationForV500() {
	local installInfo := readMultiMap(kUserConfigDirectory . "Simulator Controller.install")
	local installLocation := getMultiMapValue(installInfo, "Install", "Location")

	if (getMultiMapValue(installInfo, "Shortcuts", "StartMenu", false)) {
		installLocation := getMultiMapValue(installInfo, "Install", "Location")

		deleteFile(installLocation . "\Binaries\Setup Advisor.exe")

		try {
			FileCreateShortcut(installLocation . "\Binaries\Setup Workbench.exe", A_StartMenu . "\Simulator Controller\Setup Workbench.lnk", installLocation . "\Binaries")
		}
		catch Any as exception {
			logError(exception)
		}
	}

	if (getMultiMapValue(installInfo, "Install", "Type", false) = "Registry") {
		try {
			RegWrite(installLocation . "\Binaries\Setup Workbench.exe", "REG_SZ", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SetupWorkbench.exe")

			RegDelete("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SetupAdvisor.exe")
		}
		catch Any as exception {
			logError(exception)
		}
	}
}

updateConfigurationForV532() {
	local settings

	if FileExist(kUserConfigDirectory . "Race.settings") {
		settings := readMultiMap(kUserConfigDirectory . "Race.settings")

		setMultiMapValue(settings, "Session Setup", "Tyre.Set", false)
		setMultiMapValue(settings, "Session Setup", "Tyre.Set.Fresh", false)

		writeMultiMap(kUserConfigDirectory . "Race.settings", settings)
	}
}

updateConfigurationForV530() {
	local configuration

	if FileExist(kUserConfigDirectory . "P2T Configuration.ini") {
		configuration := readMultiMap(kUserConfigDirectory . "Simulator Configuration.ini")

		setMultiMapValue(configuration, "Voice Control", "PushToTalkMode", "Press")

		writeMultiMap(kUserConfigDirectory . "Simulator Configuration.ini", configuration)

		configuration := readMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini")

		setMultiMapValue(configuration, "Voice Control", "PushToTalkMode", "Press")

		writeMultiMap(kUserHomeDirectory . "Setup\Voice Control Configuration.ini", configuration)

		deleteFile(kUserConfigDirectory . "P2T Configuration.ini")
	}

	if FileExist(kUserConfigDirectory . "Core Settings.ini") {
		configuration := readMultiMap(kUserConfigDirectory . "Core Settings.ini")

		removeMultiMapValue(configuration, "Voice", "Push-To-Talk")

		writeMultiMap(kUserConfigDirectory . "Core Settings.ini", configuration)
	}

	if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
		configuration := readMultiMap(kUserHomeDirectory . "Setup\Setup.data")

		setMultiMapValue(configuration, "Setup", "Patch.Configuration.Files", "%kUserHomeDirectory%Setup\\Configuration Patch.ini")
		setMultiMapValue(configuration, "Setup", "Patch.Settings.Files", "%kUserHomeDirectory%Setup\\Settingss Patch.ini")

		writeMultiMap(kUserHomeDirectory . "Setup\Setup.data", configuration)
	}

	deleteFile(kUserHomeDirectory . "Setup\Settings Patch.ini")
	deleteFile(kUserHomeDirectory . "Setup\Simulator Settings.ini")
}

updateConfigurationForV500() {
	local text

	copyDirectory(source, destination) {
		local files := []
		local ignore, fileName, file, subDirectory

		DirCreate(destination)

		loop Files, source . "\*.*", "DF"
			files.Push(A_LoopFilePath)

		for ignore, fileName in files {
			if InStr(FileExist(fileName), "D") {
				SplitPath(fileName, &subDirectory)

				copyDirectory(fileName, destination . "\" . subDirectory)
			}
			else
				FileCopy(fileName, destination, 1)
		}
	}

	if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
		text := FileRead(kUserHomeDirectory . "Setup\Setup.data", "`n")

		text := StrReplace(text, "SetupAdvisor", "SetupWorkbench")

		deleteFile(kUserHomeDirectory . "Setup\Setup.data")

		FileAppend(text, kUserHomeDirectory . "Setup\Setup.data", "UTF-16")
	}

	if FileExist(kUserConfigDirectory . "Simulator Configuration.ini") {
		text := FileRead(kUserConfigDirectory . "Simulator Configuration.ini", "`n")

		text := StrReplace(text, "SetupAdvisor", "SetupWorkbench")

		deleteFile(kUserConfigDirectory . "Simulator Configuration.ini")

		FileAppend(text, kUserConfigDirectory . "Simulator Configuration.ini")
	}

	if FileExist(kUserConfigDirectory . "Application Settings.ini") {
		text := FileRead(kUserConfigDirectory . "Application Settings.ini", "`n")

		text := StrReplace(text, "Setup Advisor", "Setup Workbench")

		deleteFile(kUserConfigDirectory . "Application Settings.ini")

		FileAppend(text, kUserConfigDirectory . "Application Settings.ini")
	}

	copyDirectory(kUserHomeDirectory . "Advisor", kUserHomeDirectory . "Garage")

	deleteDirectory(kUserHomeDirectory . "Advisor")
}

updateConfigurationForV463() {
	local text
	if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
		text := FileRead(kUserHomeDirectory . "Setup\Setup.data", "`n")

		text := StrReplace(text, "Class=MutedAssistant", "Class=SilentAssistant")
		text := StrReplace(text, "Arguments=SilentSpotter###Race Spotter`n", "Arguments=SilentSpotter###Race Spotter###1`n")
		text := StrReplace(text, "Arguments=SilentStrategist###Race Strategist`n", "Arguments=SilentStrategist###Race Strategist###1`n")
		text := StrReplace(text, "Arguments=SilentEngineer###Race Engineer`n", "Arguments=SilentEngineer###Race Engineer###1`n")

		deleteFile(kUserHomeDirectory . "Setup\Setup.data")

		FileAppend(text, kUserHomeDirectory . "Setup\Setup.data", "UTF-16")
	}
}

updateConfigurationForV460() {
	if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
		text := FileRead(kUserHomeDirectory . "Setup\Setup.data")

		text := StrReplace(text, "MutedEngineer", "SilentEngineer")
		text := StrReplace(text, "MutedStrategist", "SilentStrategist")
		text := StrReplace(text, "MutedSpotter", "SilentSpotter")

		deleteFile(kUserHomeDirectory . "Setup\Setup.data")

		FileAppend(text, kUserHomeDirectory . "Setup\Setup.data", "UTF-16")
	}
}

updateConfigurationForV455() {
	local configuration, subtitle

	if FileExist(kUserConfigDirectory . "Simulator Configuration.ini") {
		configuration := readMultiMap(kUserConfigDirectory . "Simulator Configuration.ini")

		subtitle := getMultiMapValue(configuration, "Splash Window", "Subtitle", false)

		if subtitle {
			setMultiMapValue(configuration, "Splash Window", "Subtitle", StrReplace(subtitle, "2022", "2023"))

			writeMultiMap(kUserConfigDirectory . "Simulator Configuration.ini", configuration)
		}
	}
}

updateConfigurationForV452() {
	local tempValues := CaseInsenseMap()
	local newValues := CaseInsenseMap()
	local settings, key, value, found

	updateConfigurationForV451()

	settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

	for key, value in getMultiMapValues(settings, "Setup Advisor")
		tempValues[StrReplace(key, ".Unknown", ".*")] := value

	for key, value in tempValues {
		found := false

		for ignore, subkey in [".LowspeedThreshold", ".OversteerThresholds", ".UndersteerThresholds"
							 , ".SteerLock", ".SteerRatio", ".Wheelbase", ".TrackWidth"]
			if (InStr(key, subkey) && (string2Values(".", key).Length < 4)) {
				newValues[StrReplace(key, subkey, ".*" . subkey)] := value

				found := true

				break
			}

		if !found
			newValues[key] := value
	}

	setMultiMapValues(settings, "Setup Advisor", newValues)

	writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)
}

updateConfigurationForV451() {
	local directory := getMultiMapValue(kSimulatorConfiguration, "Race Strategist Reports", "Database", false)
	local sessionDB := SessionDatabase()
	local raceData, simulator, car, track

	if directory
		loop Files, directory . "\*.*", "D" {
			simulator := A_LoopFileName

			loop Files, directory . "\" . simulator "\*.*", "D"
				if FileExist(A_LoopFilePath . "\Race.data") {
					raceData := readMultiMap(A_LoopFilePath . "\Race.data")

					car := sessionDB.getCarCode(simulator, getMultiMapValue(raceData, "Session", "Car"))
					track := sessionDB.getTrackCode(simulator, getMultiMapValue(raceData, "Session", "Track"))

					DirCreate(directory . "\" . simulator . "\" . car . "\" . track)

					DirMove(A_LoopFilePath, directory . "\" . simulator . "\" . car . "\" . track . "\" . A_LoopFileName)
				}
		}
}

updateConfigurationForV448() {
	local data, count

	if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
		data := readMultiMap(kUserHomeDirectory . "Setup\Setup.data")
		count := getMultiMapValue(data, "Setup", "Module.Voice Control.Components", 0)

		loop count
			if (getMultiMapValue(data, "Setup", "Module.Voice Control.Component." . A_Index, false) = "MSSpeechLibrary_es-ES")
				return

		setMultiMapValue(data, "Setup", "Module.Voice Control.Component." . ++count, "MSSpeechLibrary_es-ES")
		setMultiMapValue(data, "Setup", "Module.Voice Control.Component." . ++count, "NirCmd")
		setMultiMapValue(data, "Setup", "Module.Voice Control.Components", count)
		setMultiMapValue(data, "Setup", "Module.Voice Control.Component.MSSpeechLibrary_es-ES.Optional", true)
		setMultiMapValue(data, "Setup", "Module.Voice Control.Component.MSSpeechLibrary_es-ES.Required", false)
		setMultiMapValue(data, "Setup", "Module.Voice Control.Component.NirCmd.Optional", true)
		setMultiMapValue(data, "Setup", "Module.Voice Control.Component.NirCmd.Required", false)

		writeMultiMap(kUserHomeDirectory . "Setup\Setup.data", data)
	}
}

updateConfigurationForV441() {
	deleteFile(kUserConfigDirectory . "Simulator Controller.config")
	deleteFile(kUserConfigDirectory . "Simulator Controller.status")
}

updateConfigurationForV430() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readMultiMap(userConfigurationFile)
	local changed := false

	if (getMultiMapValue(userConfiguration, "Automobilista 2", "Window Title", false) = "Automobilista 2") {
		setMultiMapValue(userConfiguration, "Automobilista 2", "Window Title", "ahk_exe AMS2AVX.exe")

		changed := true
	}

	if (getMultiMapValue(userConfiguration, "Project CARS 2", "Window Title", false) = "Project CARS 2") {
		setMultiMapValue(userConfiguration, "Project CARS 2", "Window Title", "ahk_exe PCARS2AVX.exe")

		changed := true
	}

	if changed
		writeMultiMap(userConfigurationFile, userConfiguration)

	if FileExist(kUserHomeDirectory . "Setup\Setup.data")
		FileAppend("`nModule.Team Server.Selected=true", kUserHomeDirectory "Setup\Setup.data")

	if FileExist(kUserConfigDirectory . "Simulator Startup.ini") {
		userConfigurationFile := getFileName("Application Settings.ini", kUserConfigDirectory)
		userConfiguration := readMultiMap(userConfigurationFile)

		setMultiMapValue(userConfiguration, "Simulator Startup", "CloseLaunchPad"
					   , getMultiMapValue(readMultiMap(kUserConfigDirectory . "Simulator Startup.ini")
					   , "Startup", "CloseLaunchPad"))

		writeMultiMap(userConfigurationFile, userConfiguration)

		deleteFile(kUserConfigDirectory . "Simulator Startup.ini")
	}
}

updateConfigurationForV426() {
	local ignore, simulator, car, track, fileName

	for ignore, simulator in ["AC", "AMS2", "PCARS2", "R3E"] {
		deleteDirectory(kDatabaseDirectory . "User\Tracks\" . simulator)

		loop Files, kDatabaseDirectory . "User\" . simulator . "\*.*", "D" {
			car := A_LoopFileName

			loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car "\*.*", "D" {
				track := A_LoopFileName

				fileName := (kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Track.automations")

				if FileExist(fileName)
					deleteFile(fileName)
			}
		}
	}
}

updateConfigurationForV425() {
	local text, changed

	deleteDirectory(kDatabaseDirectory . "User\Tracks")

	loop Files, kDatabaseDirectory . "User\*.*", "D"
		if FileExist(A_LoopFilePath . "\Settings.CSV") {
			text := FileRead(A_LoopFilePath . "\Settings.CSV")

			changed := false

			if InStr(text, "Pitstop.KeyDelay") {
				text := StrReplace(text, "Pitstop.KeyDelay", "Command.KeyDelay")

				changed := true
			}

			if changed {
				deleteFile(A_LoopFilePath . "\Settings.CSV")

				FileAppend(text, A_LoopFilePath . "\Settings.CSV")
			}
		}

}

updateConfigurationForV424() {
	local tyresDB := TyresDatabase()
	local simulator := "rFactor 2"
	local car, oldCar, track, sourceDirectory, sourceDB, targetDB, ignore, row, data, field, tyresDB
	local targetDirectory, fileName, targetName, name

	loop Files, kDatabaseDirectory . "User\RF2\*.*", "D"
		if InStr(A_LoopFileName, "#") {
			car := string2Values("#", A_LoopFileName)[1]

			if !FileExist(kDatabaseDirectory "User\RF2\" . car)
				DirMove(kDatabaseDirectory . "User\RF2\" . A_LoopFileName, kDatabaseDirectory . "User\RF2\" car, "R")
			else {
				oldCar := A_LoopFileName

				loop Files, kDatabaseDirectory . "User\RF2\" . oldCar . "\*.*", "D" {
					track := A_LoopFileName

					sourceDirectory := (kDatabaseDirectory . "User\RF2\" . oldCar . "\" . track . "\")

					sourceDB := Database(sourceDirectory, kTelemetrySchemas)
					targetDB := TelemetryDatabase(simulator, car, track).Database

					for ignore, row in sourceDB.Tables["Electronics"] {
						data := Database.Row()

						for ignore, field in kTelemetrySchemas["Electronics"]
							data[field] := row[field]

						targetDB.add("Electronics", data, true)
					}

					for ignore, row in sourceDB.Tables["Tyres"] {
						data := Database.Row()

						for ignore, field in kTelemetrySchemas["Tyres"]
							data[field] := row[field]

						targetDB.add("Tyres", data, true)
					}

					tyresDB := TyresDatabase()
					sourceDB := Database(sourceDirectory, kTyresSchemas)
					targetDB := tyresDB.getTyresDatabase(simulator, car, track)

					for ignore, row in sourceDB.Tables["Tyres.Pressures"] {
						data := Database.Row()

						for ignore, field in kTyresSchemas["Tyres.Pressures"]
							data[field] := row[field]

						targetDB.add("Tyres.Pressures", data, true)
					}

					for ignore, row in sourceDB.Tables["Tyres.Pressures.Distribution"] {
						tyresDB.updatePressure(simulator, car, track
											 , row["Weather"], row["Temperature.Air"], row["Temperature.Track"]
											 , row["Compound"], row["Compound.Color"]
											 , row["Type"], row["Tyre"], row["Pressure"], row["Count"]
											 , false, true, "User", row["Driver"])
					}

					tyresDB.flush()

					targetDirectory := (kDatabaseDirectory . "User\RF2\" . car . "\" . track . "\Race Strategies")

					DirCreate(targetDirectory)

					loop Files, sourceDirectory . "Race Strategies\*.*", "F" {
						fileName := A_LoopFileName
						targetName := fileName

						while FileExist(targetDirectory . "\" . targetName) {
							SplitPath(fileName, , , , &name)

							targetName := (name . " (" . (A_Index + 1) . ").strategy")
						}

						try {
							FileCopy(A_LoopFilePath, targetDirectory . "\" . targetName)
						}
						catch as exception {
						   logError(exception)
						}
					}
				}

				deleteDirectory(kDatabaseDirectory . "User\RF2\" . oldCar)
			}
		}
}

updateConfigurationForV423() {
	local sessionDB, sessionDBConfig, key, drivers, simulator, id, ignore, driver, car, track, empty
	local directoryName

	if FileExist(kUserConfigDirectory . "Session Database.ini") {
		sessionDB := SessionDatabase()
		sessionDBConfig := readMultiMap(kUserConfigDirectory . "Session Database.ini")

		for key, drivers in getMultiMapValues(sessionDBConfig, "Drivers") {
			key := StrSplit(key, ".", " `t", 2)
			simulator := key[1]
			id := key[2]

			for ignore, driver in string2Values("###", drivers)
				sessionDB.registerDriver(simulator, id, driver)
		}

		removeMultiMapValues(sessionDBConfig, "Drivers")

		writeMultiMap(kUserConfigDirectory . "Session Database.ini", sessionDBConfig)
	}

	loop Files, kDatabaseDirectory . "User\*.*", "D" {
		simulator := A_LoopFileName

		if (simulator = "ACC")
			loop Files, kDatabaseDirectory . "User\" . simulator . "\*.*", "D" {
				car := A_LoopFileName

				loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car "\*.*", "D" {
					track := A_LoopFileName

					empty := true

					loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track "\*.*", "FD" {
						empty := false

						break
					}

					if (empty && (InStr(track, A_Space) || inList(["Spa-Franchorchamps", "Nürburgring"], track))) {
						directoryName := kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track

						deleteDirectory(directoryName)
					}
				}
			}
	}
}

addOwnerField(database, table, id) {
	local rows := database.Tables[table]
	local changed, ignore, row

	if (rows.Length > 0) {
		changed := false

		for ignore, row in rows
			if (!row.Has("Owner") || (row["Owner"] = kNull)) {
				row["Owner"] := id

				changed := true
			}

		if changed
			database.changed(table)
	}
}

clearWearFields(database, table, id) {
	local rows := database.Tables[table]
	local changed, ignore, row, tyre, field

	if (rows.Length > 0) {
		changed := false

		for ignore, row in rows
			for ignore, tyre in ["Front.Left", "Front.Right", "Rear.Left", "Rear.Right"] {
				field := ("Tyre.Wear." . tyre)

				if (row.Has(field) && (row[field] = id)) {
					row[field] := kNull

					changed := true
				}
			}

		if changed
			database.changed(table)
	}
}

updateConfigurationForV422() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readMultiMap(userConfigurationFile)
	local id, simulator, car, track, db, tyresDB

	if (getMultiMapValue(userConfiguration, "Assetto Corsa", "Window Title", false) = "Assetto Corsa Launcher") {
		setMultiMapValue(userConfiguration, "Assetto Corsa", "Window Title", "ahk_exe acs.exe")

		writeMultiMap(userConfigurationFile, userConfiguration)
	}

	id := FileRead(kUserConfigDirectory . "ID")

	tyresDB := TyresDatabase()

	loop Files, kDatabaseDirectory . "User\*.*", "D" {
		simulator := A_LoopFileName

		loop Files, kDatabaseDirectory . "User\" . simulator . "\*.*", "D" {
			car := A_LoopFileName

			loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car "\*.*", "D" {
				track := A_LoopFileName

				db := TelemetryDatabase(simulator, car, track).Database

				addOwnerField(db, "Electronics", id)
				clearWearFields(db, "Tyres", id)
				addOwnerField(db, "Tyres", id)

				db.flush()

				db := tyresDB.getTyresDatabase(simulator, car, track)

				addOwnerField(db, "Tyres.Pressures", id)
				addOwnerField(db, "Tyres.Pressures.Distribution", id)

				db.flush()
			}
		}
	}
}

updateConfigurationForV420() {
	local text, changed

	loop Files, kDatabaseDirectory "User\*.*", "D"
		if FileExist(A_LoopFilePath . "\Settings.CSV") {
			text := FileRead(A_LoopFilePath . "\Settings.CSV")
			changed := false

			if (InStr(text, "Spotter Settings") && !InStr(text, "Assistant.Spotter")) {
				text := StrReplace(text, "Spotter Settings", "Assistant.Spotter")

				changed := true
			}

			if InStr(text, "Assistant.Spotter Settings") {
				text := StrReplace(text, "Assistant.Spotter Settings", "Assistant.Spotter")

				changed := true
			}

			if changed {
				deleteFile(A_LoopFilePath . "\Settings.CSV")

				FileAppend(text, A_LoopFilePath "\Settings.CSV")
			}
		}
}

updateConfigurationForV402() {
	if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
		FileAppend("`nPatch.Configuration.Files=%kUserHomeDirectory%Setup\Configuration Patch.ini", kUserHomeDirectory . "Setup\Setup.data")
		FileAppend("`nPatch.Settings.Files=%kUserHomeDirectory%Setup\Settings Patch.ini", kUserHomeDirectory . "Setup\Setup.data")
	}
}

updateConfigurationForV400() {
	deleteFile(kDatabaseDirectory . "User\UPLOAD")
}

updatePluginsForV5091() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readMultiMap(userConfigurationFile)
	local changed, rsp

	if (userConfiguration.Count > 0) {
		changed := false

		if getMultiMapValue(userConfiguration, "Plugins", "RSP", false) {
			rsp := Plugin("RSP", userConfiguration)

			if (rsp.Simulators.Length = 0) {
				rsp.iSimulators := ["Rennsport"]

				rsp.saveToConfiguration(userConfiguration)

				changed := true
			}
		}
		else {
			rsp := Plugin("RSP", false, false, "Rennsport")

			rsp.saveToConfiguration(userConfiguration)

			changed := true
		}

		if changed
			writeMultiMap(userConfigurationFile, userConfiguration)
	}
}

updatePluginsForV426() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readMultiMap(userConfigurationFile)
	local changed, pcars2

	if (userConfiguration.Count > 0) {
		changed := false

		if getMultiMapValue(userConfiguration, "Plugins", "PCARS2", false) {
			pcars2 := Plugin("PCARS2", userConfiguration)

			if (pcars2.Simulators.Length = 0) {
				pcars2.iSimulators := ["Project CARS 2"]

				pcars2.saveToConfiguration(userConfiguration)

				changed := true
			}
		}
		else {
			pcars2 := Plugin("PCARS2", false, false, "Project CARS 2")

			pcars2.saveToConfiguration(userConfiguration)

			changed := true
		}

		if getMultiMapValue(userConfiguration, "Plugins", "Project CARS 2", false) {
			removeMultiMapValue(userConfiguration, "Plugins", "Project CARS 2")

			changed := true
		}

		if changed
			writeMultiMap(userConfigurationFile, userConfiguration)
	}
}

updatePluginsForV424() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readMultiMap(userConfigurationFile)
	local pcars2

	if (userConfiguration.Count > 0) {
		if !getMultiMapValue(userConfiguration, "Plugins", "PCARS2", false) {
			pcars2 := Plugin("Project CARS 2", false, false, "", "")

			pcars2.saveToConfiguration(userConfiguration)

			writeMultiMap(userConfigurationFile, userConfiguration)
		}
	}
}

updatePluginsForV402() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readMultiMap(userConfigurationFile)
	local descriptor

	if (userConfiguration.Count > 0) {
		descriptor := getMultiMapValue(userConfiguration, "Plugins", "Race Spotter", false)

		if descriptor {
			descriptor := StrReplace(descriptor, "raceAssistantListener: off", "raceAssistantListener: On")

			setMultiMapValue(userConfiguration, "Plugins", "Race Spotter", descriptor)
		}

		writeMultiMap(userConfigurationFile, userConfiguration)
	}
}

updateToV400() {
	OnMessage(0x44, translateOkButton)
	MsgBox(translate("Your installed version is to old to be updated automatically. Please remove the `"Simulator Controller`" folder in your user `"Documents`" folder and restart the application. Application will exit..."), translate("Error"), 262160)
	OnMessage(0x44, translateOkButton, 0)

	ExitApp(0)
}

checkFileDependency(file, modification) {
	local lastModified

	logMessage(kLogInfo, translate("Checking file ") . file . translate(" for modification"))

	try {
		lastModified := FileGetTime(file, "M")
	}
	catch Any as exception {
		if FileExist(file)
			logError(exception)

		lastModified := false
	}

	if (lastModified > modification) {
		logMessage(kLogInfo, translate("File ") . file . translate(" found more recent than ") . modification)

		return true
	}
	else
		return false
}

checkDirectoryDependency(directory, modification) {
	local files := []
	local ignore, file

	logMessage(kLogInfo, translate("Checking all files in ") . directory)

	loop Files, directory . "*.ahk", "R"
		files.Push(A_LoopFilePath)

	for ignore, file in files
		if checkFileDependency(file, modification)
			return true

	return false
}

checkDependencies(dependencies, modification) {
	local ignore, fileOrFolder, attributes

	for ignore, fileOrFolder in dependencies {
		attributes := FileExist(fileOrFolder)

		if InStr(attributes, "D") {
			if checkDirectoryDependency(fileOrFolder, modification)
				return true
		}
		else if attributes {
			if checkFileDependency(fileOrFolder, modification)
				return true
		}
	}

	return false
}

runSpecialTargets(&buildProgress) {
	local msBuild := kMSBuildDirectory . "MSBuild.exe"
	local currentDirectory := A_WorkingDir
	local index, directory, file, success, solution, text, ignore, result

	try {
		for index, directory in getFileNames("*", kSourcesDirectory . "Special\") {
			SetWorkingDir(directory)

			for ignore, file in getFileNames("*.sln", directory . "\") {
				success := true

				SplitPath(file, , , , &solution)

				if !kSilentMode
					showProgress({progress: ++buildProgress, message: translate("Compiling ") . solution . translate("...")})

				try {
					if (InStr(solution, "Speech") || InStr(solution, "AC UDP Provider"))
						result := RunWait(A_ComSpec . " /c `"`"" . msBuild . "`" `"" . file . "`" /p:BuildMode=Release /p:Configuration=Release /p:Platform=`"x64`" > `"" . kTempDirectory . "Special Build.out`"`"", , "Hide")
					else
						result := RunWait(A_ComSpec . " /c `"`"" . msBuild .  "`" `"" . file . "`" /p:BuildMode=Release /p:Configuration=Release > `"" . kTempDirectory . "Special Build.out`"`"", , "Hide")

					if result {
						success := false

						text := FileRead(kTempDirectory . "Special Build.out")

						if (StrLen(Trim(text)) == 0)
							throw "Error while compiling..."
					}
				}
				catch Any as exception {
					logMessage(kLogCritical, translate("Cannot compile ") . solution . translate(" - Solution or MSBuild (") . msBuild . translate(") not found"))

					showMessage(substituteVariables(translate("Cannot compile %solution%: Solution or MSBuild (%msBuild%) not found..."), {solution: solution, msBuild: msBuild})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

					success := true
				}

				if !success
					viewBuildLog(kTempDirectory . "Special Build.out", translate("Error while compiling ") . solution, "Left", "Top", 800, 600)

				if FileExist(kTempDirectory . "Special Build.out")
					deleteFile(kTempDirectory . "Special Build.out")
			}
		}
	}
	finally {
		SetWorkingDir(currentDirectory)
	}
}

runUpdateTargets(&buildProgress) {
	local ignore, target, targetName, progressStep, ignore, updateFunction, message, updatesFileName, updates

	for ignore, target in gUpdateTargets {
		targetName := target[1]

		if !kSilentMode
			showProgress({progress: buildProgress, message: translate("Updating to ") . targetName . translate("...")})

		logMessage(kLogInfo, translate("Updating to ") . targetName)

		Sleep(50)

		progressStep := ((100 / (gTargetsCount + 1)) / target[2].Length)

		for ignore, updateFunction in target[2] {
			if !kSilentMode {
				if kUpdateMessages.Has(updateFunction)
					message := translate(kUpdateMessages[updateFunction]) . targetName . translate("...")
				else
					message := translate("Updating configuration to ") . targetName . translate("...")

				showProgress({progress: buildProgress, message: message})
			}

			%updateFunction%()

			Sleep(50)

			buildProgress := Round(buildProgress + progressStep)
		}

		buildProgress += (100 / (gTargetsCount + 1))

		if !kSilentMode
			showProgress({progress: buildProgress})
	}

	updatesFileName := getFileName("UPDATES", kUserConfigDirectory)

	updates := readMultiMap(updatesFileName)

	for target, ignore in gUpdateSettings
		setMultiMapValue(updates, "Processed", target, true)

	writeMultiMap(updatesFileName, updates)
}

runCleanTargets(&buildProgress) {
	local ignore, target, targetName, fileOrFolder, currentDirectory, directory, pattern, options

	for ignore, target in gCleanupTargets {
		targetName := target[1]

		if !kSilentMode
			showProgress({progress: buildProgress, message: translate("Cleaning ") . targetName . translate("...")})

		logMessage(kLogInfo, translate("Cleaning ") . targetName)

		if (target.Length == 2) {
			fileOrFolder := target[2]

			if (InStr(FileExist(fileOrFolder), "D")) {
				currentDirectory := A_WorkingDir

				SetWorkingDir(fileOrFolder)

				try {
					loop Files, "*.*", "FDR" {
						if InStr(FileExist(A_LoopFilePath), "D")
							deleteDirectory(A_LoopFilePath)
						else
							deleteFile(A_LoopFilePath)

						if !kSilentMode
							showProgress({progress: buildProgress, message: translate("Deleting ") . A_LoopFileName . translate("...")})

						Sleep(50)
					}
				}
				finally {
					SetWorkingDir(currentDirectory)
				}
			}
			else if (FileExist(fileOrFolder) != "")
				deleteFile(fileOrFolder)
		}
		else {
			currentDirectory := A_WorkingDir
			directory := target[2]
			pattern := target[3]
			options := ((target[4] && (target[4] != "")) ? target[4] : "")

			SetWorkingDir(directory)

			try {
				loop Files, pattern, options {
					deleteFile(A_LoopFilePath)

					if !kSilentMode
						showProgress({progress: buildProgress, message: translate("Deleting ") . A_LoopFileName . translate("...")})

					Sleep(50)
				}
			}
			finally {
				SetWorkingDir(currentDirectory)
			}
		}

		Sleep(50)

		buildProgress += (100 / (gTargetsCount + 1))

		if !kSilentMode
			showProgress({progress: buildProgress})
	}
}

runCopyTargets(&buildProgress) {
	local title, ignore, target, targetSource, targetDestination, targetFile, srcLastModified, dstLastModified, copy
	local targetName, targetDirectory

	if !kSilentMode
		showProgress({progress: buildProgress, message: A_Space})

	for ignore, target in gCopyTargets {
		targetName := ConfigurationItem.splitDescriptor(target[1])[1]

		logMessage(kLogInfo, translate("Check ") . targetName)

		targetSource := target[2]
		targetDestination := target[3]

		if InStr(targetSource, "*") {
			DirCreate(targetDestination)

			loop Files, targetSource {
				targetFile := (targetDestination . A_LoopFileName)

				try {
					srcLastModified := FileGetTime(A_LoopFilePath, "M")
				}
				catch Any as exception {
					if FileExist(A_LoopFilePath)
						logError(exception)

					srcLastModified := false
				}

				try {
					dstLastModified := FileGetTime(targetFile, "M")
				}
				catch Any as exception {
					if FileExist(targetFile)
						logError(exception)

					dstLastModified := false
				}

				if srcLastModified {
					if dstLastModified
						copy := (srcLastModified > dstLastModified)
					else
						copy := true
				}
				else
					copy := false

				if copy {
					if !kSilentMode
						showProgress({progress: buildProgress, message: translate("Copying ") . targetName . translate("...")})

					logMessage(kLogInfo, targetName . translate(" out of date - update needed"))
					logMessage(kLogInfo, translate("Copying ") . A_LoopFilePath)

					try {
						FileCopy(A_LoopFilePath, targetFile, 1)
					}
					catch Any as exception {
						logError(exception)
					}

					Sleep(50)

					buildProgress += (100 / (gTargetsCount + 1))

					if !kSilentMode
						showProgress({progress: buildProgress})
				}
			}
		}
		else {
			if InStr(FileExist(targetSource), "D")
				copy := true
			else {
				try {
					srcLastModified := FileGetTime(targetSource, "M")
				}
				catch Any as exception {
					if FileExist(targetSource)
						logError(exception)

					srcLastModified := false
				}

				try {
					dstLastModified := FileGetTime(targetDestination, "M")
				}
				catch Any as exception {
					if FileExist(targetDestination)
						logError(exception)

					dstLastModified := false
				}

				if srcLastModified {
					if dstLastModified
						copy := (srcLastModified > dstLastModified)
					else
						copy := true
				}
				else
					copy := false
			}

			if copy {
				if !kSilentMode
					showProgress({progress: buildProgress, message: translate("Copying ") . targetName . translate("...")})

				logMessage(kLogInfo, targetName . translate(" out of date - update needed"))
				logMessage(kLogInfo, translate("Copying ") . targetSource)

				if InStr(FileExist(targetSource), "D") {
					deleteDirectory(targetDestination)

					try {
						DirCopy(targetSource, targetDestination, 1)
					}
					catch Any as exception {
						logError(exception)
					}
				}
				else {
					SplitPath(targetDestination, , &targetDirectory)

					DirCreate(targetDirectory)

					try {
						FileCopy(targetSource, targetDestination, 1)
					}
					catch Any as exception {
						logError(exception)
					}
				}

				Sleep(50)

				buildProgress += (100 / (gTargetsCount + 1))

				if !kSilentMode
					showProgress({progress: buildProgress})
			}
		}
	}
}

runBuildTargets(&buildProgress) {
	local title, ignore, target, targetName, build, targetSource, targetBinary, srcLastModified, binLastModified
	local compiledFile, targetDirectory, sourceDirectory, sourceCode, result, options

	if !kSilentMode
		showProgress({progress: buildProgress, message: ""})

	for ignore, target in gBuildTargets {
		targetName := target[1]

		logMessage(kLogInfo, translate("Check ") . targetName)

		build := false

		targetSource := target[2]
		targetBinary := target[3]

		try {
			srcLastModified := FileGetTime(targetSource, "M")
		}
		catch Any as exception {
			if FileExist(targetSource)
				logError(exception)

			srcLastModified := false
		}

		try {
			binLastModified := FileGetTime(targetBinary, "M")
		}
		catch Any as exception {
			if FileExist(targetBinary)
				logError(exception)

			binLastModified := false
		}

		if gTargetConfigurationChanged
			build := true
		else if binLastModified {
			build := (build || (srcLastModified > binLastModified))
			build := (build || checkDependencies(target[4], binLastModified))
		}
		else
			build := true

		if build {
			if !kSilentMode
				showProgress({progress: buildProgress, message: translate("Compiling ") . targetName . translate("...")})

			logMessage(kLogInfo, targetName . translate(" or dependent files out of date - recompile triggered"))
			logMessage(kLogInfo, translate("Compiling ") . targetSource)

			try {
				if !FileExist(targetSource)
					throw "Source file not found..."

				options := " /base `"" . kAHKDirectory . "v2\AutoHotkey64.exe`""

				if (gTargetConfiguration = "Production") {
					SplitPath(targetSource, , &sourceDirectory)

					sourceCode := FileRead(targetSource)

					sourceCode := StrReplace(sourceCode, ";@SC-IF %configuration% == Development`r`n#Include `"..\Framework\Development.ahk`"`r`n;@SC-EndIF", "")

					sourceCode := StrReplace(sourceCode, ";@SC #Include `"..\Framework\Production.ahk`"", "#Include `"..\Framework\Production.ahk`"")

					deleteFile(sourceDirectory . "\compile.ahk")

					FileAppend(sourceCode, sourceDirectory . "\compile.ahk")

					result := RunWait(kCompiler . options . " /in `"" . sourceDirectory . "\compile.ahk" . "`"")

					deleteFile(sourceDirectory . "\compile.ahk")
				}
				else
					result := RunWait(kCompiler . options . " /in `"" . targetSource . "`"")
			}
			catch Any as exception {
				logMessage(kLogCritical, translate("Cannot compile ") . targetSource . translate(" - source file or AHK Compiler (") . kCompiler . translate(") not found"))

				showMessage(substituteVariables(translate("Cannot compile %targetSource%: Source file or AHK Compiler (%kCompiler%) not found..."), {targetSource: targetSource, kCompiler: kCompiler})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				result := true
			}

			if !result {
				SplitPath(targetBinary, &compiledFile, &targetDirectory)
				SplitPath(targetSource, , &sourceDirectory)

				compiledFile := sourceDirectory . "\" . compiledFile

				DirCreate(targetDirectory)

				try {
					FileMove(compiledFile, targetDirectory, 1)
				}
				catch Any as exception {
					logError(exception)
				}
			}
		}

		buildProgress += (100 / (gTargetsCount + 1))

		if !kSilentMode
			showProgress({progress: buildProgress})
	}
}

prepareTargets(&buildProgress, updateOnly) {
	global gUpdateTargets

	local counter := 0
	local targets := readMultiMap(kToolsTargetsFile)
	local updateTargets := getMultiMapValues(targets, "Update")
	local target, arguments, update, cleanupTargets, targetName, cleanup, copyTargets, copy, buildTargets, build, rule

	compareUpdateTargets(t1, t2) {
		if inList(t2[3], t1[1])
			return false
		else if inList(t1[3], t2[1])
			return true
		else
			return (t1[1] >= t2[1])
	}

	for target, arguments in updateTargets {
		buildProgress += (A_Index / updateTargets.Count)

		update := gUpdateSettings[target]

		if !kSilentMode
			showProgress({progress: buildProgress, message: target . ": " . (update ? translate("Yes") : translate("No"))})

		if update {
			arguments := string2Values("->", substituteVariables(arguments))

			if (arguments.Length == 1)
				gUpdateTargets.Push(Array(target, string2Values(",", arguments[1]), []))
			else
				gUpdateTargets.Push(Array(target, string2Values(",", arguments[2]), string2Values(",", arguments[1])))
		}

		Sleep(50)
	}

	bubbleSort(&gUpdateTargets, compareUpdateTargets)

	if !updateOnly {
		cleanupTargets := getMultiMapValues(targets, "Cleanup")

		for target, arguments in cleanupTargets {
			targetName := ConfigurationItem.splitDescriptor(target)[1]
			buildProgress += (A_Index / cleanupTargets.Count)

			cleanup := (InStr(target, "*.bak") ? gCleanupSettings[target] : gCleanupSettings[targetName])

			if !kSilentMode
				showProgress({progress: buildProgress, message: targetName . ": " . (cleanup ? translate("Yes") : translate("No"))})

			if cleanup {
				arguments := substituteVariables(arguments)

				gCleanupTargets.Push(Array(target, string2Values(",", arguments)*))
			}

			Sleep(50)
		}

		copyTargets := getMultiMapValues(targets, "Copy")

		for target, arguments in copyTargets {
			targetName := ConfigurationItem.splitDescriptor(target)[1]
			buildProgress += (A_Index / copyTargets.Count)

			copy := gCopySettings[targetName]

			if !kSilentMode
				showProgress({progress: buildProgress, message: targetName . ": " . (copy ? translate("Yes") : translate("No"))})

			if copy {
				rule := string2Values("<-", substituteVariables(arguments))

				gCopyTargets.Push(Array(target, rule[2], rule[1]))
			}

			Sleep(50)
		}

		buildTargets := getMultiMapValues(targets, "Build")

		for target, arguments in buildTargets {
			buildProgress += (A_Index / buildTargets.Count)

			build := gBuildSettings[target]

			if !kSilentMode
				showProgress({progress: buildProgress, message: target . ": " . (build ? translate("Yes") : translate("No"))})

			if build {
				if (arguments = "Special")
					gSpecialTargets.Push(target)
				else {
					rule := string2Values("<-", substituteVariables(arguments))

					arguments := string2Values(";", rule[2])

					gBuildTargets.Push(Array(target, arguments[1], rule[1], string2Values(",", arguments[2])))
				}
			}

			Sleep(50)
		}
	}
}

startupSimulatorTools() {
	global gUpdateSettings, gCleanupSettings, gCopySettings, gBuildSettings, gSplashScreen, gTargetConfiguration, gTargetsCount

	local forceExit := GetKeyState("Shift")
	local updateOnly := false
	local icon := kIconsDirectory . "Tools.ico"
	local buildProgress

	TraySetIcon(icon, "1")
	A_IconTip := "Simulator Tools"

	checkInstallation()

	readToolsConfiguration(&gUpdateSettings, &gCleanupSettings, &gCopySettings, &gBuildSettings, &gSplashScreen, &gTargetConfiguration)

	if (A_Args.Length > 0)
		if (A_Args[1] = "-Update")
			updateOnly := true

	if updateOnly {
		gCleanupSettings := CaseInsenseMap()
		gCopySettings := CaseInsenseMap()
		gBuildSettings := CaseInsenseMap()
	}
	else {
		if !FileExist(kAHKDirectory)
			gBuildSettings := CaseInsenseMap()

		if (!FileExist(getFileName(kToolsConfigurationFile, kUserConfigDirectory, kConfigDirectory)) || GetKeyState("Ctrl"))
			if !editTargets()
				ExitApp(0)
	}

	startupApplication()

	if (!kSilentMode && gSplashScreen)
		showSplashScreen(gSplashScreen, false, false)

	Sleep(500)

	if !kSilentMode
		showProgress({color: "Blue", message: "", title: translate("Preparing Targets")})

	buildProgress := 0

	prepareTargets(&buildProgress, updateOnly)

	gTargetsCount := (gUpdateTargets.Length + gCleanupTargets.Length + gCopyTargets.Length + gBuildTargets.Length
					+ (((kMSBuildDirectory != "") && (gSpecialTargets.Length > 0)) ? getFileNames("*", kSourcesDirectory . "Special\").Length : 0))

	if !kSilentMode
		showProgress({message: "", color: "Green", title: translate("Running Targets")})

	runUpdateTargets(&buildProgress)

	if !updateOnly {
		if forceExit
			exitProcesses(true, true)

		runCleanTargets(&buildProgress)

		if (gSpecialTargets.Length > 0)
			runSpecialTargets(&buildProgress)

		runCopyTargets(&buildProgress)
		runBuildTargets(&buildProgress)
	}

	if !kSilentMode
		showProgress({progress: 100, message: translate("Done")})

	Sleep(500)

	if !kSilentMode {
		hideProgress()

		if gSplashScreen
			hideSplashScreen()
	}

	ExitApp(0)
}

cancelBuild() {
	local msgResult

	protectionOn()

	try {
		OnMessage(0x44, translateYesNoButtons)
		msgResult := MsgBox(translate("Cancel target processing?"), translate("Modular Simulator Controller System"), 262180)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes")
			ExitApp(0)
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startupSimulatorTools()


;;;-------------------------------------------------------------------------;;;
;;;                         Hotkey & Label Section                          ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Escape::                   Cancel Build                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

Escape:: {
	cancelBuild()

	return
}