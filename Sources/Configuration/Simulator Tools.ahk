;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Build & Maintenance Tool        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include ..\Framework\Development.ahk
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Framework\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Tools.ico
;@Ahk2Exe-ExeName Simulator Tools.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Application.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Database.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk
#Include ..\Assistants\Libraries\TyresDatabase.ahk
#Include ..\Assistants\Libraries\TelemetryDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kToolsConfigurationFile := "Simulator Tools.ini"
global kToolsTargetsFile := "Simulator Tools.targets"

global kUpdateMessages := {updateTranslations: "Updating translations to "
						 , updatePluginLabels: "Updating plugin labels to "
						 , updateActionLabels: "Updating action labels to "
						 , updateActionIcons: "Updating action icons to "
						 , updatePhraseGrammars: "Updating phrase grammars to "}

global kCompiler := kAHKDirectory . "Compiler\ahk2exe.exe"

global kSave := "save"
global kRevert := "revert"

global kOk := "ok"
global kCancel := "cancel"

global kUninstallKey := "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SimulatorController"

global kInstallDirectory := (A_ProgramFiles . "\Simulator Controller\")


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vTargetConfiguration := "Development"
global vTargetConfigurationChanged := false

global vUpdateTargets := []
global vCleanupTargets := []
global vCopyTargets := []
global vBuildTargets := []
global vSpecialTargets := []

global vSplashTheme := false

global vTargetsCount := 0

global vUpdateSettings := Object()
global vCleanupSettings := Object()
global vCopySettings := Object()
global vBuildSettings := Object()

global vProgressCount := 0


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global installLocationPathEdit

installOptions(options) {
	local directory, valid, empty, title, innerWidth, chosen, disabled, checked

	static installationTypeDropDown
	static automaticUpdatesCheck
	static startMenuShortcutsCheck
	static desktopShortcutsCheck
	static startConfigurationCheck

	static result := false

	static update := false

	if (options == kOk) {
		GuiControlGet installLocationPathEdit

		directory := installLocationPathEdit

		valid := true
		empty := true

		if !update
			if !FileExist(directory)
				try {
					FileCreateDir %directory%
				}
				catch exception {
					title := translate("Error")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262160, %title%, % translate("You must enter a valid directory.")
					OnMessage(0x44, "")

					valid := false
				}
			else if (InStr(kHomeDirectory, directory) != 1)
				loop Files, %directory%\*.*, FD
				{
					empty := false

					break
				}

		if (empty && valid)
			result := kOk
		else if !empty {
			title := translate("Error")

			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262160, %title%, % translate("The installation folder must be empty.")
			OnMessage(0x44, "")
		}
	}
	else if (options == kCancel)
		result := kCancel
	else {
		result := false
		update := options["Update"]

		Gui Install:Default

		Gui Install:-Border ; -Caption
		Gui Install:Color, D0D0D0, D8D8D8

		Gui Install:Font, Bold, Arial

		Gui Install:Add, Text, w330 Center gmoveInstallEditor, % translate("Modular Simulator Controller System")

		Gui Install:Font, Norm, Arial
		Gui Install:Font, Italic Underline, Arial

		Gui Install:Add, Text, x108 YP+20 w130 cBlue Center gopenInstallDocumentation, % translate("Install")

		Gui Install:Font, Norm, Arial

		Gui Install:Add, Text, x8 yp+20 w330 0x10

		Gui Install:Add, Picture, yp+10 w50 h50, % kIconsDirectory . "Install.ico"

		innerWidth := 330 - 66

		Gui Install:Add, Text, X74 YP+5 W%innerWidth% H46, % translate("Do you want to install Simulator Controller on your system as a portable or as a fully registered Windows application?")

		chosen := inList(["Registry", "Portable"], options["InstallType"])

		disabled := (options["Update"] ? "Disabled" : "")

		Gui Install:Add, Text, x16 yp+60 w100 h23 +0x200, % translate("Installation Type")
		Gui Install:Add, DropDownList, x116 yp w80 AltSubmit %disabled% Choose%chosen% VinstallationTypeDropDown, % values2String("|", map(["Registry", "Portable"], "translate")*)

		Gui Install:Add, Text, x16 yp+24 w110 h23 +0x200, % translate("Installation Folder")
		Gui Install:Add, Edit, x116 yp w187 h21 %disabled% VinstallLocationPathEdit, % options["InstallLocation"]
		Gui Install:Add, Button, x304 yp-1 w23 h23 %disabled% gchooseInstallLocationPath, % translate("...")

		checked := (options["AutomaticUpdates"] ? "Checked" : "")

		Gui Install:Add, Text, x16 yp+34 w100 h23 +0x200, % translate("Updates")
		Gui Install:Add, CheckBox, x116 yp+3 w180 %checked% VautomaticUpdatesCheck, % translate("  Automatic")

		checked := (options["StartMenuShortcuts"] ? "Checked" : "")

		Gui Install:Add, Text, x16 yp+34 w100 h23 +0x200, % translate("Create")
		Gui Install:Add, CheckBox, x116 yp+3 w180 %checked% VstartMenuShortcutsCheck, % translate("  Start Menu Shortcuts")

		checked := (options["DesktopShortcuts"] ? "Checked" : "")

		Gui Install:Add, Text, x16 yp+21 w100 h23 +0x200, % translate("")
		Gui Install:Add, CheckBox, x116 yp+3 w180 %checked% VdesktopShortcutsCheck, % translate("  Desktop Shortcuts")

		checked := (options["StartSetup"] ? "Checked" : "")

		Gui Install:Add, Text, x16 yp+34 w100 h23 +0x200, % translate("Start")
		Gui Install:Add, CheckBox, x116 yp+3 w210 %disabled% %checked% VstartConfigurationCheck, % translate("  Configuration when finished...")

		Gui Install:Add, Text, x8 yp+34 w330 0x10

		Gui Install:Add, Button, x170 yp+10 w80 h23 Default gacceptInstall, % translate("Ok")
		Gui Install:Add, Button, x260 yp w80 h23 gcancelInstall, % translate("&Cancel")

		Gui Install:Margin, 10, 10
		Gui Install:Show, AutoSize Center

		loop
			Sleep 200
		until result

		if (result == kOk) {
			Gui Install:Submit

			options["InstallType"] := ["Registry", "Portable"][installationTypeDropDown]
			options["InstallLocation"] := installLocationPathEdit
			options["AutomaticUpdates"] := automaticUpdatesCheck
			options["StartMenuShortcuts"] := startMenuShortcutsCheck
			options["DesktopShortcuts"] := desktopShortcutsCheck
			options["StartSetup"] := startConfigurationCheck
		}

		Gui Install:Destroy

		return (result == kOk)
	}
}

uninstallOptions(options) {
	local innerWidth, checked

	static result := false
	static keepUserFilesCheck

	if (options == kOk)
		result := kOk
	else if (options == kCancel)
		result := kCancel
	else {
		result := false

		Gui Uninstall:Default

		Gui Uninstall:-Border ; -Caption
		Gui Uninstall:Color, D0D0D0, D8D8D8

		Gui Uninstall:Font, Bold, Arial

		Gui Uninstall:Add, Text, w330 Center gmoveUninstallEditor, % translate("Modular Simulator Controller System")

		Gui Uninstall:Font, Norm, Arial
		Gui Uninstall:Font, Italic Underline, Arial

		Gui Uninstall:Add, Text, x108 YP+20 w130 cBlue Center gopenInstallDocumentation, % translate("Uninstall")

		Gui Uninstall:Font, Norm, Arial

		Gui Uninstall:Add, Text, x8 yp+20 w330 0x10

		Gui Uninstall:Add, Picture, yp+10 w50 h50, % kIconsDirectory . "Install.ico"

		innerWidth := 330 - 66

		Gui Uninstall:Add, Text, X74 YP+5 W%innerWidth% H46, % translate("Do you really want to remove Simulator Controller from your Computer?")

		checked := (options["DeleteUserFiles"] ? "" : "Checked")

		Gui Uninstall:Add, CheckBox, x74 yp+60 w250 %checked% VkeepUserFilesCheck, % translate("  Keep user data and configuration files?")

		Gui Uninstall:Add, Text, x8 yp+34 w330 0x10

		Gui Uninstall:Add, Button, x170 yp+10 w80 h23 gacceptUninstall, % translate("Ok")
		Gui Uninstall:Add, Button, x260 yp w80 h23 Default gcancelUninstall, % translate("&Cancel")

		Gui Uninstall:Margin, 10, 10
		Gui Uninstall:Show, AutoSize Center

		loop
			Sleep 200
		until result

		if (result == kOk) {
			Gui Uninstall:Submit

			options["DeleteUserFiles"] := !keepUserFilesCheck
		}

		Gui Uninstall:Destroy

		return (result == kOk)
	}
}

acceptInstall() {
	installOptions(kOk)
}

cancelInstall() {
	installOptions(kCancel)
}

acceptUninstall() {
	uninstallOptions(kOk)
}

cancelUninstall() {
	uninstallOptions(kCancel)
}

moveInstallEditor() {
	moveByMouse("Install")
}

moveUninstallEditor() {
	moveByMouse("Uninstall")
}

chooseInstallLocationPath() {
	local valid, empty, title, directory

	GuiControlGet installLocationPathEdit

	Gui +OwnDialogs

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Select", "Cancel"]))
	FileSelectFolder directory, *%installLocationPathEdit%, 0, % translate("Select Installation folder...")
	OnMessage(0x44, "")

	if (directory != "") {
		valid := true
		empty := true

		if !FileExist(directory)
			try {
				FileCreateDir %directory%
			}
			catch exception {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				title := translate("Error")
				MsgBox 262160, %title%, % translate("You must enter a valid directory.")
				OnMessage(0x44, "")

				valid := false
			}
		else if (InStr(kHomeDirectory, directory) != 1)
			loop Files, %directory%\*.*, FD
			{
				empty := false

				break
			}

		if (empty && valid)
			GuiControl Text, installLocationPathEdit, %directory%
		else if !empty {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("The installation folder must be empty.")
			OnMessage(0x44, "")
		}
	}
}

openInstallDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration
}

exitProcesses(silent := false, force := false) {
	local pid, hasFGProcesses, hasBGProcesses, ignore, app, title

	Process Exist

	pid := ErrorLevel

	while true {
		hasFGProcesses := false
		hasBGProcesses := false

		for ignore, app in concatenate(kForegroundApps, ["Race Settings"]) {
			Process Exist, %app%.exe

			if ErrorLevel {
				hasFGProcesses := true

				break
			}
		}

		for ignore, app in kBackgroundApps {
			Process Exist, %app%.exe

			if (ErrorLevel && (ErrorLevel != pid)) {
				hasBGProcesses := true

				break
			}
		}

		if (hasFGProcesses && !silent) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Continue", "Cancel"]))
			title := translate("Installation")
			MsgBox 8500, %title%, % translate("Before you can run the update, you must first close all running Simulator Controller applications (not Simulator Tools).")
			OnMessage(0x44, "")

			IfMsgBox Yes
				continue
			else
				return false
		}

		if hasFGProcesses
			if force
				broadcastMessage(concatenate(kForegroundApps, ["Race Settings"]), "exit")
			else
				return false

		if hasBGProcesses
			broadcastMessage(remove(kBackgroundApps, "Simulator Tools"), "exit")

		return true
	}
}

checkInstallation() {
	local installLocation, installOptions, quiet, options
	local install, title, index, options, isNew, packageLocation, ignore, directory, currentDirectory

	RegRead installLocation, HKLM, %kUninstallKey%, InstallLocation

	installOptions := readConfiguration(kUserConfigDirectory . "Simulator Controller.install")
	installLocation := getConfigurationValue(installOptions, "Install", "Location", installLocation)

	if inList(A_Args, "-Uninstall") {
		quiet := inList(A_Args, "-Quiet")

		if !A_IsAdmin {
			options := ("-Uninstall -NoUpdate" . (quiet ? " -Quiet" : ""))

			try {
				if A_IsCompiled
					Run *RunAs "%A_ScriptFullPath%" /restart %options%
				else
					Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" %options%
			}
			catch exception {
				;ignore
			}

			ExitApp 0
		}

		if !exitProcesses()
			ExitApp 1

		options := {InstallType: getConfigurationValue(installOptions, "Install", "Type", "Registry")
				  , InstallLocation: normalizeDirectoryPath(installLocation)
				  , AutomaticUpdates: getConfigurationValue(installOptions, "Updates", "Automatic", true)
				  , DesktopShortcuts: getConfigurationValue(installOptions, "Shortcuts", "Desktop", false)
				  , StartMenuShortcuts: getConfigurationValue(installOptions, "Shortcuts", "StartMenu", true)
				  , DeleteUserFiles: false}

		if (quiet || uninstallOptions(options)) {
			showSplashTheme("McLaren 720s GT3 Pictures")

			vProgressCount := 0

			showProgress({color: "Blue", title: translate("Uninstalling Simulator Controller"), message: translate("...")})

			deleteFiles(options["InstallLocation"])

			if options["DeleteUserFiles"] {
				showProgress({message: translate("Removing User files...")})

				deleteDirectory(kUserHomeDirectory)
			}
			else
				deleteFile(kUserConfigDirectory . "Simulator Controller.install")

			if options["StartMenuShortcuts"] {
				showProgress({progress: vProgressCount, message: translate("Removing Start menu shortcuts...")})

				deleteShortcuts(A_StartMenu)
			}

			if options["DesktopShortcuts"] {
				showProgress({progress: vProgressCount, message: translate("Removing Desktop shortcuts...")})

				deleteShortcuts(A_Desktop)
			}

			vProgressCount += 5

			if (options["InstallType"] = "Registry") {
				showProgress({progress: vProgressCount, message: translate("Updating Registry...")})

				deleteAppPaths()
				deleteUninstallerInfo()
			}

			if (installLocation != A_ProgramFiles)
				removeDirectory(installLocation)

			showProgress({progress: 100, message: translate("Finished...")})

			Sleep 1000

			hideSplashTheme()
			hideProgress()

			ExitApp 0
		}
	}
	else {
		install := inList(A_Args, "-Install")
		install := (install || (installLocation && (installLocation != "") && (InStr(kHomeDirectory, installLocation) != 1)))
		install := (install || !installLocation || (installLocation = ""))

		if install {
			if !A_Is64bitOS {
				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				title := translate("Error")
				MsgBox 262160, %title%, % translate("Simulator Controller can only be installed on a 64-bit Windows installation. Setup will exit...")
				OnMessage(0x44, "")

				ExitApp 1
			}

			if !A_IsAdmin {
				index := inList(A_Args, "-Start")

				options := (index ? ("-Start " . """" . A_Args[index + 1] . """") : "")

				try {
					if A_IsCompiled
						Run *RunAs "%A_ScriptFullPath%" /restart -NoUpdate %options%
					else
						Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%" -NoUpdate %options%
				}
				catch exception {
					logError(exception)
				}

				ExitApp 0
			}

			if (!installLocation || (installLocation = ""))
				installLocation := normalizeDirectoryPath(kInstallDirectory)

			isNew := !FileExist(installLocation)

			if !isNew
				if !exitProcesses()
					ExitApp 1

			options := {InstallType: getConfigurationValue(installOptions, "Install", "Type", "Registry")
					  , InstallLocation: normalizeDirectoryPath(getConfigurationValue(installOptions, "Install", "Location", installLocation))
					  , AutomaticUpdates: getConfigurationValue(installOptions, "Updates", "Automatic", true)
					  , Verbose: getConfigurationValue(installOptions, "Updates", "Verbose", false)
					  , DesktopShortcuts: getConfigurationValue(installOptions, "Shortcuts", "Desktop", false)
					  , StartMenuShortcuts: getConfigurationValue(installOptions, "Shortcuts", "StartMenu", true)
					  , StartSetup: isNew, Update: !isNew}

			packageLocation := normalizeDirectoryPath(kHomeDirectory)

			if ((!isNew && !options["Verbose"]) || installOptions(options)) {
				installLocation := options["InstallLocation"]

				setConfigurationValue(installOptions, "Install", "Type", options["InstallType"])
				setConfigurationValue(installOptions, "Install", "Location", installLocation)
				setConfigurationValue(installOptions, "Updates", "Automatic", options["AutomaticUpdates"])
				setConfigurationValue(installOptions, "Updates", "Verbose", options["Verbose"])
				setConfigurationValue(installOptions, "Shortcuts", "Desktop", options["DesktopShortcuts"])
				setConfigurationValue(installOptions, "Shortcuts", "StartMenu", options["StartMenuShortcuts"])

				; showSplashTheme("McLaren 720s GT3 Pictures")

				vProgressCount := 0

				showProgress({color: "Blue", title: translate("Installing Simulator Controller"), message: translate("...")})

				for ignore, directory in [kBinariesDirectory, kResourcesDirectory . "Setup\Installer\"] {
					vProgressCount += 1

					showProgress({progress: vProgressCount, message: translate("Unblocking Applications and DLLs...")})

					currentDirectory := A_WorkingDir

					try {
						SetWorkingDir %directory%

						RunWait Powershell -Command Get-ChildItem -Path '.' -Recurse | Unblock-File, , Hide
					}
					finally {
						SetWorkingDir %currentDirectory%
					}
				}

				if (installLocation != packageLocation)
					copyFiles(packageLocation, installLocation, !isNew)
				else {
					vProgressCount := 80

					showProgress({progress: vProgressCount, message: translate("Download and installation folders are identical...")})

					Sleep 1000
				}

				if options["StartMenuShortcuts"] {
					showProgress({progress: vProgressCount, message: translate("Creating Start menu shortcuts...")})

					createShortcuts(A_StartMenu, installLocation)
				}
				else {
					showProgress({progress: vProgressCount, message: translate("Removing Start menu shortcuts...")})

					deleteShortcuts(A_StartMenu)
				}

				if options["DesktopShortcuts"] {
					showProgress({progress: vProgressCount, message: translate("Creating Desktop shortcuts...")})

					createShortcuts(A_Desktop, installLocation)
				}
				else {
					showProgress({progress: vProgressCount, message: translate("Removing Desktop shortcuts...")})

					deleteShortcuts(A_Desktop)
				}

				if (options["InstallType"] = "Registry") {
					showProgress({message: translate("Updating Registry...")})

					writeAppPaths(installLocation)
					writeUninstallerInfo(installLocation)
				}

				fixIE(11, "Setup Advisor.exe")
				fixIE(11, "Race Reports.exe")
				fixIE(11, "Strategy Workbench.exe")
				fixIE(11, "Race Center.exe")
				fixIE(10, "Simulator Setup.exe")

				writeConfiguration(kUserConfigDirectory . "Simulator Controller.install", installOptions)

				; hideSplashTheme()

				if (installLocation != packageLocation) {
					showProgress({message: translate("Removing installation files...")})

					if InStr(packageLocation, A_Temp)
						removeDirectory(packageLocation)
					else {
						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
						title := translate("Installation")
						MsgBox 262436, %title%, % translate("Do you want to remove the folder with the installation files?")
						OnMessage(0x44, "")

						IfMsgBox Yes
							removeDirectory(packageLocation)
					}
				}

				showProgress({progress: 100, message: translate("Finished...")})

				deleteDirectory(kLogsDirectory)
				deleteDirectory(kTempDirectory)

				FileCreateDir %kLogsDirectory%
				FileCreateDir %kTempDirectory%

				Sleep 1000

				hideProgress()

				if isNew {
					if options["StartSetup"]
						Run %installLocation%\Binaries\Simulator Setup.exe
				}
				else {
					Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Notes

					index := inList(A_Args, "-Start")

					if index
						Run % A_Args[index + 1]
				}
			}
			else {
				if (isNew || (options["InstallLocation"] != packageLocation))
					if InStr(packageLocation, A_Temp)
						removeDirectory(packageLocation)
					else {
						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
						title := translate("Installation")
						MsgBox 262436, %title%, % translate("Do you want to remove the folder with the installation files?")
						OnMessage(0x44, "")

						IfMsgBox Yes
							removeDirectory(packageLocation)
					}
			}

			ExitApp 0
		}
	}
}

copyFiles(source, destination, deleteOrphanes) {
	local count := 0
	local progress := 0
	local step, stepCount

	loop Files, %source%\*, DFR
	{
		if (Mod(count, 100) == 0)
			progress += 1

		showProgress({progress: vProgressCount + Min(progress, 10), message: translate("Validating ") . A_LoopFileName . translate("...")})

		Sleep 1

		count += 1
	}

	vProgressCount += 10

	showProgress({color: "Green"})

	step := ((deleteOrphanes ? 70 : 80) / count)
	stepCount := 0

	copyDirectory(source, destination, step, stepCount)

	vProgressCount := (vProgressCount + Round(step * count))

	showProgress({progress: vProgressCount})

	if deleteOrphanes {
		showProgress({message: translate("Searching for orphane files...")})

		stepCount := 0

		cleanupDirectory(source, destination, 10, stepCount)

		vProgressCount := (vProgressCount + 10)

		showProgress({progress: vProgressCount})
	}
}

deleteFiles(installLocation) {
	local count := 0
	local progress := 0
	local step, stepCount

	loop Files, %installLocation%\*, DFR
	{
		if (Mod(count, 100) == 0)
			progress += 1

		showProgress({progress: vProgressCount + Min(progress, 20), message: translate("Preparing ") . A_LoopFileName . translate("...")})

		Sleep 1

		count += 1
	}

	vProgressCount += 20

	showProgress({color: "Green"})

	step := (70 / count)
	stepCount := 0

	clearDirectory(installLocation, step, stepCount)

	vProgressCount := (vProgressCount + Round(step * count))

	showProgress({progress: vProgressCount})
}

copyDirectory(source, destination, progressStep, ByRef count) {
	local files := []
	local ignore, fileName, file, subDirectory

	FileCreateDir %destination%

	loop Files, %source%\*.*, DF
		files.Push(A_LoopFilePath)

	for ignore, fileName in files {
		SplitPath fileName, file

		count += 1

		showProgress({progress: Round(vProgressCount + (count * progressStep)), message: translate("Copying ") . file . translate("...")})

		if InStr(FileExist(fileName), "D") {
			SplitPath fileName, subDirectory

			copyDirectory(fileName, destination . "\" . subDirectory, progressStep, count)
		}
		else
			FileCopy %fileName%, %destination%, 1
	}
}

clearDirectory(directory, progressStep, ByRef count) {
	local files := []
	local ignore, fileName, subDirectory, file

	loop Files, %directory%\*.*, DF
		files.Push(A_LoopFilePath)

	for ignore, fileName in files {
		SplitPath fileName, file

		count += 1

		showProgress({progress: Round(vProgressCount + (count * progressStep)), message: translate("Deleting ") . file . translate("...")})

		if InStr(FileExist(fileName), "D") {
			SplitPath fileName, subDirectory

			clearDirectory(directory . "\" . subDirectory, progressStep, count)
		}
		else
			deleteFile(fileName)

		Sleep 1
	}
}

cleanupDirectory(source, destination, maxStep, ByRef count) {
	local fileName

	loop Files, %destination%\*.*, DF
	{
		SplitPath A_LoopFilePath, fileName

		if InStr(FileExist(A_LoopFilePath), "D") {
			cleanupDirectory(source . "\" . fileName, A_LoopFilePath, maxStep, count)

			try {
				FileRemoveDir %A_LoopFilePath%
			}
			catch exception {
			}
		}
		else if !FileExist(source . "\" . fileName) {
			count := Min(count + 1, maxStep)

			showProgress({progress: vProgressCount + count, message: translate("Deleting ") . fileName . translate("...")})

			deleteFile(A_LoopFilePath)

			Sleep 100
		}
	}
}

removeDirectory(directory) {
	deleteFile(A_Temp . "\Cleanup.bat")

	command =
(
ping 127.0.0.1 -n 15 > nul
cd C:\
rmdir "%directory%" /s /q
)

	FileAppend %command%, %A_Temp%\Cleanup.bat

	Run "%A_Temp%\Cleanup.bat", C:\, Hide
}

createShortcuts(location, installLocation) {
	local ignore, name

	if (location = A_StartMenu) {
		FileCreateDir %location%\Simulator Controller

		location := (location . "\Simulator Controller")

		FileCreateShortcut %installLocation%\Binaries\Simulator Tools.exe, %location%\Uninstall.lnk, %installLocation%\Binaries, -Uninstall

		for ignore, name in ["Simulator Startup", "Simulator Settings", "Simulator Setup", "Simulator Configuration", "Race Settings", "Session Database"
						   , "Race Reports", "Strategy Workbench", "Race Center", "Server Administration", "Setup Advisor"]
			FileCreateShortCut %installLocation%\Binaries\%name%.exe, %location%\%name%.lnk, %installLocation%\Binaries
	}
	else
		for ignore, name in ["Simulator Startup", "Simulator Settings"]
			FileCreateShortCut %installLocation%\Binaries\%name%.exe, %location%\%name%.lnk, %installLocation%\Binaries

	FileCreateShortCut %installLocation%\Documentation.url, %location%\Documentation.lnk, %installLocation%
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
					   , "Race Reports", "Strategy Workbench", "Race Center", "Server Administration", "Setup Advisor"]
		deleteFile(location . "\" . name . ".lnk")

	deleteFile(location . "\Documentation.lnk")

	if deleteFolder
		deleteDirectory(location)
}

writeAppPaths(installLocation) {
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorStartup.exe, , %installLocation%\Binaries\Simulator Startup.exe
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorController.exe, , %installLocation%\Binaries\Simulator Controller.exe
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorSettings.exe, , %installLocation%\Binaries\Simulator Settings.exe
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorSetup.exe, , %installLocation%\Binaries\Simulator Setup.exe
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorConfiguration.exe, , %installLocation%\Binaries\Simulator Configuration.exe
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceSettings.exe, , %installLocation%\Binaries\Race Settings.exe
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SessionDatabase.exe, , %installLocation%\Binaries\Session Database.exe
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceReports.exe, , %installLocation%\Binaries\Race Reports.exe
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\StrategyWorkbench.exe, , %installLocation%\Binaries\Strategy Workbench.exe
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceCenter.exe, , %installLocation%\Binaries\Race Center.exe
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ServerAdministration.exe, , %installLocation%\Binaries\Server Administration.exe
	RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SetupAdvisor.exe, , %installLocation%\Binaries\SetupAdvisor.exe
}

deleteAppPaths() {
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorStartup.exe
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorController.exe
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorSettings.exe
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorSetup.exe
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SimulatorConfiguration.exe
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceSettings.exe
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SessionDatabase.exe
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceReports.exe
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\StrategyWorkbench.exe
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceCenter.exe
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ServerAdministration.exe
	RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SetupAdvisor.exe
}

writeUninstallerInfo(installLocation) {
	local version := StrSplit(kVersion, "-", , 2)[1]

	RegWrite REG_SZ, HKLM, %kUninstallKey%, DisplayName, Simulator Controller
	RegWrite REG_SZ, HKLM, %kUninstallKey%, InstallLocation, % installLocation
	RegWrite REG_SZ, HKLM, %kUninstallKey%, InstallDate, %A_YYYY%%A_MM%%A_DD%
	RegWrite REG_SZ, HKLM, %kUninstallKey%, UninstallString, "%installLocation%\Binaries\Simulator Tools.exe" -Uninstall
	RegWrite REG_SZ, HKLM, %kUninstallKey%, QuietUninstallString, "%installLocation%\Binaries\Simulator Tools.exe" -Uninstall -Quiet
	RegWrite REG_SZ, HKLM, %kUninstallKey%, DisplayIcon, "%installLocation%\Resources\Icons\Artificial Intelligence.ico"
	RegWrite REG_SZ, HKLM, %kUninstallKey%, DisplayVersion, %version%
	RegWrite REG_SZ, HKLM, %kUninstallKey%, URLInfoAbout, https://github.com/SeriousOldMan/Simulator-Controller/wiki
	RegWrite REG_SZ, HKLM, %kUninstallKey%, Publisher, Oliver Juwig (TheBigO)
	RegWrite REG_SZ, HKLM, %kUninstallKey%, NoModify, 1
}

deleteUninstallerInfo() {
	RegDelete HKLM, %kUninstallKey%
}

readToolsConfiguration(ByRef updateSettings, ByRef cleanupSettings, ByRef copySettings, ByRef buildSettings
					 , ByRef splashTheme, ByRef targetConfiguration) {
	local targets := readConfiguration(kToolsTargetsFile)
	local configuration := readConfiguration(kToolsConfigurationFile)
	local updateConfiguration := readConfiguration(getFileName("UPDATES", kUserConfigDirectory))
	local target, rule

	updateSettings := Object()
	cleanupSettings := Object()
	copySettings := Object()
	buildSettings := Object()

	for target, rule in getConfigurationSectionValues(targets, "Update", Object())
		if !getConfigurationValue(updateConfiguration, "Processed", target, false)
			updateSettings[target] := true

	for target, rule in getConfigurationSectionValues(targets, "Cleanup", Object()) {
		if !InStr(target, "*.bak")
			target := ConfigurationItem.splitDescriptor(target)[1]

		cleanupSettings[target] := getConfigurationValue(configuration, "Cleanup", target, InStr(target, "*.ahk") ? true : false)
	}

	for target, rule in getConfigurationSectionValues(targets, "Copy", Object()) {
		target := ConfigurationItem.splitDescriptor(target)[1]

		copySettings[target] := getConfigurationValue(configuration, "Copy", target, true)
	}

	for target, rule in getConfigurationSectionValues(targets, "Build", Object()) {
		target := ConfigurationItem.splitDescriptor(target)[1]

		buildSettings[target] := getConfigurationValue(configuration, "Build", target, true)
	}

	splashTheme := getConfigurationValue(configuration, "General", "Splash Theme", false)
	targetConfiguration := getConfigurationValue(configuration, "Compile", "TargetConfiguration", "Development")

	if A_IsCompiled
		buildSettings["Simulator Tools"] := false
}

writeToolsConfiguration(updateSettings, cleanupSettings, copySettings, buildSettings, splashTheme, targetConfiguration) {
	local configuration := newConfiguration()
	local target, setting

	for target, setting in cleanupSettings
		setConfigurationValue(configuration, "Cleanup", target, setting)

	for target, setting in copySettings
		setConfigurationValue(configuration, "Copy", target, setting)

	for target, setting in buildSettings
		setConfigurationValue(configuration, "Build", target, setting)

	setConfigurationValue(configuration, "General", "Splash Theme", splashTheme)
	setConfigurationValue(configuration, "Compile", "TargetConfiguration", targetConfiguration)

	writeConfiguration(kToolsConfigurationFile, configuration)
}

viewBuildLog(fileName, title := "", x := "Center", y := "Center", width := 800, height := 400) {
	local text, innerWidth, editHeight, buttonX
	local mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom

	static dismissed := false

	dismissed := false

	if !fileName {
		dismissed := true

		return
	}

	FileRead text, %fileName%

	innerWidth := width - 16

	Gui FV:-Border -Caption
	Gui FV:Color, D0D0D0, D8D8D8
	Gui FV:Font, s10 Bold
	Gui FV:Add, Text, x8 y8 W%innerWidth% +0x200 +0x1 BackgroundTrans gmoveBuildLogViewer, % translate("Modular Simulator Controller System - Compiler")
	Gui FV:Font
	Gui FV:Add, Text, x8 yp+26 W%innerWidth% +0x200 +0x1 BackgroundTrans, %title%

	editHeight := height - 102

	Gui FV:Add, Edit, X8 YP+26 W%innerWidth% H%editHeight%, % text

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

	buttonX := Round(width / 2) - 40

	Gui FV:Add, Button, Default X%buttonX% y+10 w80 gdismissBuildLogViewer, % translate("Ok")

	Gui FV:+AlwaysOnTop
	Gui FV:Show, X%x% Y%y% W%width% H%height% NoActivate

	while !dismissed
		Sleep 100

	Gui FV:Destroy
}

moveBuildLogViewer() {
	moveByMouse("FV")
}

dismissBuildLogViewer() {
	viewBuildLog(false)
}

saveTargets() {
	editTargets(kSave)
}

cancelTargets() {
	editTargets(kCancel)
}

moveEditor() {
	moveByMouse("TE", "Simulator Tools")
}

editTargets(command := "") {
	local target, setting, updateVariable, cleanupVariable, copyVariable, buildVariable, updateHeight, cleanupHeight
	local cleanupPosOption, option, copyHeight, buildHeight, themes, chosen, yPos, x, y

	static result

	static updateVariable1
	static updateVariable2
	static updateVariable3
	static updateVariable4
	static updateVariable5
	static updateVariable6
	static updateVariable7
	static updateVariable8
	static updateVariable9
	static updateVariable10
	static updateVariable11
	static updateVariable12
	static updateVariable13
	static updateVariable14
	static updateVariable15
	static updateVariable16

	static cleanupVariable1
	static cleanupVariable2
	static cleanupVariable3
	static cleanupVariable4
	static cleanupVariable5
	static cleanupVariable6
	static cleanupVariable7
	static cleanupVariable8

	static copyVariable1
	static copyVariable2
	static copyVariable3
	static copyVariable4
	static copyVariable5
	static copyVariable6
	static copyVariable7
	static copyVariable8
	static copyVariable9
	static copyVariable10
	static copyVariable11
	static copyVariable12
	static copyVariable13
	static copyVariable14
	static copyVariable15
	static copyVariable16

	static buildVariable1
	static buildVariable2
	static buildVariable3
	static buildVariable4
	static buildVariable5
	static buildVariable6
	static buildVariable7
	static buildVariable8
	static buildVariable9
	static buildVariable10
	static buildVariable11
	static buildVariable12
	static buildVariable13
	static buildVariable14
	static buildVariable15
	static buildVariable16
	static buildVariable17
	static buildVariable18
	static buildVariable19
	static buildVariable20
	static buildVariable21
	static buildVariable22
	static buildVariable23
	static buildVariable24

	static splashTheme
	static targetConfiguration

	if (command == kSave) {
		Gui TE:Submit

		for target, setting in vUpdateSettings {
			updateVariable := "updateVariable" . vUpdateSettings.Count()

			vUpdateSettings[target] := %updateVariable%
		}

		for target, setting in vCleanupSettings {
			cleanupVariable := "cleanupVariable" . A_Index

			vCleanupSettings[target] := %cleanupVariable%
		}

		for target, setting in vCopySettings {
			copyVariable := "copyVariable" . A_Index

			vCopySettings[target] := %copyVariable%
		}

		for target, setting in vBuildSettings {
			buildVariable := "buildVariable" . A_Index

			vBuildSettings[target] := %buildVariable%
		}

		vSplashTheme := (splashTheme == translate("None")) ? false : splashTheme

		targetConfiguration := ["Development", "Production"][targetConfiguration]

		if (vTargetConfiguration != targetConfiguration)
			vTargetConfigurationChanged := true

		vTargetConfiguration := targetConfiguration

		writeToolsConfiguration(vUpdateSettings, vCleanupSettings, vCopySettings, vBuildSettings, vSplashTheme, vTargetConfiguration)

		Gui TE:Destroy

		result := 1
	}
	else if (command == kRevert) {
		Gui TE:Destroy

		result := 2
	}
	else if (command == kCancel) {
		Gui TE:Destroy

		result := 3
	}
	else {
		result := false

		if (vUpdateSettings.Count() > 16)
			throw "Too many update targets detected in editTargets..."

		if (vCleanupSettings.Count() > 8)
			throw "Too many cleanup targets detected in editTargets..."

		if (vCopySettings.Count() > 16)
			throw "Too many copy targets detected in editTargets..."

		if (vBuildSettings.Count() > 24)
			throw "Too many build targets detected in editTargets..."

		Gui TE:-Border ; -Caption
		Gui TE:Color, D0D0D0, D8D8D8

		Gui TE:Font, Bold, Arial

		Gui TE:Add, Text, w410 Center gmoveEditor, % translate("Modular Simulator Controller System")

		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial

		Gui TE:Add, Text, YP+20 w410 Center, % translate("Targets")

		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial

		updateHeight := 0

		if (vUpdateSettings.Count() > 0) {
			updateHeight := (20 + (Min(vUpdateSettings.Count(), 1) * 20))

			if (updateHeight == 20)
				updateHeight := 40

			Gui TE:Add, GroupBox, -Theme YP+30 w200 h%updateHeight%, % translate("Update")

			Gui TE:Font, Norm, Arial

			if (vUpdateSettings.Count() > 0)
				for target, setting in vUpdateSettings {
					if (A_Index == vUpdateSettings.Count())
						Gui TE:Add, CheckBox, YP+20 XP+10 Disabled Checked%setting% vupdateVariable%A_Index%, %target%
				}
			else
				Gui TE:Add, Text, YP+20 XP+10, % translate("No updates required...")

			Gui TE:Font, Norm, Arial
			Gui TE:Font, Italic, Arial

			cleanupPosOption := "XP-10"
		}
		else
			cleanupPosOption := ""

		cleanupHeight := 20 + (vCleanupSettings.Count() * 20)

		if (cleanupHeight == 20)
			cleanupHeight := 40

		Gui TE:Add, GroupBox, -Theme %cleanupPosOption% YP+30 w200 h%cleanupHeight% Section, % translate("Cleanup")

		Gui TE:Font, Norm, Arial

		if (vCleanupSettings.Count() > 0)
			for target, setting in vCleanupSettings {
				option := ""

				if (A_Index == 1)
					option := option . " YP+20 XP+10"

				Gui TE:Add, CheckBox, %option% Checked%setting% vcleanupVariable%A_Index%, %target%
			}
		else
			Gui TE:Add, Text, YP+20 XP+10, % translate("No targets found...")

		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial

		copyHeight := 20 + (vCopySettings.Count() * 20)

		if (copyHeight == 20)
			copyHeight := 40

		Gui TE:Add, GroupBox, -Theme XP-10 YP+30 w200 h%copyHeight%, % translate("Copy")

		Gui TE:Font, Norm, Arial

		if (vCopySettings.Count() > 0)
			for target, setting in vCopySettings {
				option := ""

				if (A_Index == 1)
					option := option . " YP+20 XP+10"

				Gui TE:Add, CheckBox, %option% Checked%setting% vcopyVariable%A_Index%, %target%
			}
		else
			Gui TE:Add, Text, YP+20 XP+10, % translate("No targets found...")

		Gui TE:Font, Norm, Arial
		Gui TE:Font, Italic, Arial

		buildHeight := 20 + (vBuildSettings.Count() * 20)

		if (buildHeight == 20)
			buildHeight := 40

		Gui TE:Add, GroupBox, -Theme X220 YS w200 h%buildHeight%, % translate("Compile")

		Gui TE:Font, Norm, Arial

		if (vBuildSettings.Count() > 0)
			for target, setting in vBuildSettings {
				option := ""

				if (A_Index == 1)
					option := option . " YP+20 XP+10"

				if (target == "Simulator Tools")
					option := option . (A_IsCompiled ? " Disabled" : "")

				Gui TE:Add, CheckBox, %option% Checked%setting% vbuildVariable%A_Index%, %target%
			}
		else
			Gui TE:Add, Text, YP+20 XP+10, % translate("No targets found...")

		yPos := (Max(cleanupHeight + copyHeight + (updateHeight ? updateHeight + 10 : 0), buildHeight) + 86)

		chosen := inList(["Development", "Production"], vTargetConfiguration)

		Gui TE:Add, Text, X10 Y%yPos%, % translate("Target")
		Gui TE:Add, DropDownList, X110 YP-5 w310 AltSubmit Choose%chosen% vtargetConfiguration, % values2String("|", map(["Development", "Production"], "translate")*)

		themes := getAllThemes()
		chosen := (vSplashTheme ? inList(themes, vSplashTheme) + 1 : 1)
		themes := (translate("None") . "|" . values2String("|", themes*))

		Gui TE:Add, Text, X10 YP+30, % translate("Theme")
		Gui TE:Add, DropDownList, X110 YP-5 w310 Choose%chosen% vsplashTheme, %themes%

		Gui TE:Add, Button, Default X110 y+20 w100 gsaveTargets, % translate("Run")
		Gui TE:Add, Button, X+10 w100 gcancelTargets, % translate("&Cancel")

		Gui TE:Margin, 10, 10

		if getWindowPosition("Simulator Tools", x, y)
			Gui TE:Show, x%x% y%y%
		else
			Gui TE:Show

		loop
			Sleep 1000
		until result

		return ((result == 1) || (result == 2))
	}
}

updatePhraseGrammars() {
	/* Obsolete since 4.0.4...
	languages := availableLanguages()

	for ignore, filePrefix in ["Race Engineer.grammars.", "Race Strategist.grammars.", "Race Spotter.grammars."]
		for ignore, grammarFileName in getFileNames(filePrefix . "*", kUserGrammarsDirectory, kUserConfigDirectory) {
			SplitPath grammarFileName, , , languageCode

			userGrammars := readConfiguration(grammarFileName)
			bundledGrammars := readConfiguration(getFileName(filePrefix . languageCode, kGrammarsDirectory, kConfigDirectory))

			for section, keyValues in bundledGrammars
				for key, value in keyValues
					if (getConfigurationValue(userGrammars, section, key, kUndefined) == kUndefined)
						setConfigurationValue(userGrammars, section, key, value)

			writeConfiguration(grammarFileName, userGrammars)
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
			FileMove %fName%, %fName%.bak, 1
		}
		catch exception {
			logError(exception)
		}
}

updateActionDefinitions(fileName := "Controller Plugin Labels", preset := false) {
	local languages, enDefinitions, ignore, userDefinitionsFile, languageCode, bundledDefinitions, changed
	local section, keyValues, key, value, keys, userDefinitions

	if preset {
		languages := availableLanguages()
		enDefinitions := readConfiguration(kResourcesDirectory . "Setup\Presets\" . fileName . ".en")

		for ignore, userDefinitionsFile in getFileNames(fileName . ".*", kUserTranslationsDirectory) {
			SplitPath userDefinitionsFile, , , languageCode

			if (!languages.HasKey(languageCode) || (languageCode = "en"))
				bundledDefinitions := enDefinitions
			else {
				bundledDefinitions := readConfiguration(kResourcesDirectory . "Setup\Presets\" . fileName . "." . languageCode)

				if (bundledDefinitions.Count() == 0)
					bundledDefinitions := enDefinitions
			}

			userDefinitions := readConfiguration(userDefinitionsFile)
			changed := false

			for section, keyValues in bundledDefinitions
				for key, value in keyValues
					if (getConfigurationValue(userDefinitions, section, key, kUndefined) == kUndefined) {
						setConfigurationValue(userDefinitions, section, key, value)

						changed := true
					}

			if changed
				writeConfiguration(userDefinitionsFile, userDefinitions)
		}
	}
	else {
		/* Obsolete since 4.0.4...
		languages := availableLanguages()
		enDefinitions := readConfiguration(kResourcesDirectory . "Templates\" . fileName . ".en")

		for ignore, userDefinitionsFile in getFileNames(fileName . ".*", kUserTranslationsDirectory, kUserConfigDirectory) {
			SplitPath userDefinitionsFile, , , languageCode

			if (!languages.HasKey(languageCode) || (languageCode = "en"))
				bundledDefinitions := enDefinitions
			else {
				bundledDefinitions := readConfiguration(kResourcesDirectory . "Templates\" . fileName . "." . languageCode)

				if (bundledDefinitions.Count() == 0)
					bundledDefinitions := enDefinitions
			}

			userDefinitions := readConfiguration(userDefinitionsFile)
			changed := false

			for section, keyValues in bundledDefinitions
				for key, value in keyValues
					if (getConfigurationValue(userDefinitions, section, key, kUndefined) == kUndefined) {
						setConfigurationValue(userDefinitions, section, key, value)

						changed := true
					}

			for section, keyValues in userDefinitions {
				keys := []

				for key, value in keyValues
					if (getConfigurationValue(bundledDefinitions, section, key, kUndefined) == kUndefined) {
						keys.Push(key)

						changed := true
					}

				for ignore, key in keys
					removeConfigurationValue(userDefinitions, section, key)
			}

			if changed
				writeConfiguration(userDefinitionsFile, userDefinitions)
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
	local userConfiguration := readConfiguration(userConfigurationFile)
	local bundledConfiguration, customCallIndex, key

	if (userConfiguration.Count() > 0) {
		bundledConfiguration := readConfiguration(getFileName(kSimulatorConfigurationFile, kConfigDirectory))

		customCallIndex := startNumber

		loop {
			key := "Custom." . customCallIndex . ".Call"

			if (getConfigurationValue(userConfiguration, "Controller Functions", key, kUndefined) == kUndefined) {
				setConfigurationValue(userConfiguration, "Controller Functions", key, getConfigurationValue(bundledConfiguration, "Controller Functions", key))

				key .= " Action"

				setConfigurationValue(userConfiguration, "Controller Functions", key, getConfigurationValue(bundledConfiguration, "Controller Functions", key))
			}

			customCallIndex += 1
		} until (customCallIndex > endNumber)

		writeConfiguration(userConfigurationFile, userConfiguration)
	}
}

renewConsent() {
	local consent := readConfiguration(kUserConfigDirectory . "CONSENT")

	if (consent.Count() > 0) {
		setConfigurationValue(consent, "General", "ReNew", true)

		writeConfiguration(kUserConfigDirectory . "CONSENT", consent)
	}
}

updateInstallationForV398() {
	local installOptions := readConfiguration(kUserConfigDirectory . "Simulator Controller.install")
	local installLocation

	if (getConfigurationValue(installOptions, "Shortcuts", "StartMenu", false)) {
		installLocation := getConfigurationValue(installOptions, "Install", "Location")

		deleteFile(installLocation . "\Binaries\Setup Database.exe")

		try {
			FileCreateShortCut %installLocation%\Binaries\Session Database.exe, %A_StartMenu%\Simulator Controller\Session Database.lnk, %installLocation%\Binaries
		}
		catch exception {
			logError(exception)
		}
	}

	if (getConfigurationValue(installOptions, "Install", "Type", false) = "Registry") {
		try {
			RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SessionDatabase.exe, , %installLocation%\Binaries\Session Database.exe
			RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\RaceCenter.exe, , %installLocation%\Binaries\Race Center.exe
			RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ServerAdministration.exe, , %installLocation%\Binaries\Server Administration.exe
			RegWrite REG_SZ, HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SetupAdvisor.exe, , %installLocation%\Binaries\Setup Advisor.exe

			RegDelete HKLM, SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\SetupDatabase.exe
		}
		catch exception {
			logError(exception)
		}
	}
}

updateInstallationForV392() {
	local installOptions := readConfiguration(kUserConfigDirectory . "Simulator Controller.install")
	local installLocation

	if (getConfigurationValue(installOptions, "Shortcuts", "StartMenu", false)) {
		installLocation := getConfigurationValue(installOptions, "Install", "Location")

		FileCreateShortCut %installLocation%\Binaries\Setup Advisor.exe, %A_StartMenu%\Simulator Controller\Setup Advisor.lnk, %installLocation%\Binaries
	}
}

updateConfigurationForV452() {
	local tempValues := {}
	local newValues := {}
	local settings, key, value, found

	updateConfigurationForV451()

	settings := readConfiguration(kUserConfigDirectory . "Application Settings.ini")

	for key, value in getConfigurationSectionValues(settings, "Setup Advisor", Object())
		tempValues[StrReplace(key, ".Unknown", ".*")] := value

	for key, value in tempValues {
		found := false

		for ignore, subkey in [".LowspeedThreshold", ".OversteerThresholds", ".UndersteerThresholds"
							 , ".SteerLock", ".SteerRatio", ".Wheelbase", ".TrackWidth"]
			if (InStr(key, subkey) && (string2Values(".", key).Length() < 4)) {
				newValues[StrReplace(key, subkey, ".*" . subkey)] := value

				found := true

				break
			}

		if !found
			newValues[key] := value
	}

	setConfigurationSectionValues(settings, "Setup Advisor", newValues)

	writeConfiguration(kUserConfigDirectory . "Application Settings.ini", settings)
}

updateConfigurationForV451() {
	local directory := getConfigurationValue(kSimulatorConfiguration, "Race Strategist Reports", "Database", false)
	local sessionDB := new SessionDatabase()
	local raceData, simulator, car, track

	if directory
		loop Files, %directory%\*.*, D
		{
			simulator := A_LoopFileName

			loop Files, %directory%\%simulator%\*.*, D
				if FileExist(A_LoopFilePath . "\Race.data") {
					raceData := readConfiguration(A_LoopFilePath . "\Race.data")

					car := sessionDB.getCarCode(simulator, getConfigurationValue(raceData, "Session", "Car"))
					track := sessionDB.getTrackCode(simulator, getConfigurationValue(raceData, "Session", "Track"))

					FileCreateDir %directory%\%simulator%\%car%\%track%

					FileMoveDir %A_LoopFilePath%, %directory%\%simulator%\%car%\%track%\%A_LoopFileName%
				}
		}
}

updateConfigurationForV448() {
	local data, count

	if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
		data := readConfiguration(kUserHomeDirectory . "Setup\Setup.data")
		count := getConfigurationValue(data, "Setup", "Module.Voice Control.Components", 0)

		loop %count%
			if (getConfigurationValue(data, "Setup", "Module.Voice Control.Component." . A_Index, false) = "MSSpeechLibrary_es-ES")
				return

		setConfigurationValue(data, "Setup", "Module.Voice Control.Component." . ++count, "MSSpeechLibrary_es-ES")
		setConfigurationValue(data, "Setup", "Module.Voice Control.Component." . ++count, "NirCmd")
		setConfigurationValue(data, "Setup", "Module.Voice Control.Components", count)
		setConfigurationValue(data, "Setup", "Module.Voice Control.Component.MSSpeechLibrary_es-ES.Optional", true)
		setConfigurationValue(data, "Setup", "Module.Voice Control.Component.MSSpeechLibrary_es-ES.Required", false)
		setConfigurationValue(data, "Setup", "Module.Voice Control.Component.NirCmd.Optional", true)
		setConfigurationValue(data, "Setup", "Module.Voice Control.Component.NirCmd.Required", false)

		writeConfiguration(kUserHomeDirectory . "Setup\Setup.data", data)
	}
}

updateConfigurationForV441() {
	deleteFile(kUserConfigDirectory . "Simulator Controller.config")
	deleteFile(kUserConfigDirectory . "Simulator Controller.status")
}

updateConfigurationForV430() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readConfiguration(userConfigurationFile)
	local changed := false

	if (getConfigurationValue(userConfiguration, "Automobilista 2", "Window Title", false) = "Automobilista 2") {
		setConfigurationValue(userConfiguration, "Automobilista 2", "Window Title", "ahk_exe AMS2AVX.exe")

		changed := true
	}

	if (getConfigurationValue(userConfiguration, "Project CARS 2", "Window Title", false) = "Project CARS 2") {
		setConfigurationValue(userConfiguration, "Project CARS 2", "Window Title", "ahk_exe PCARS2AVX.exe")

		changed := true
	}

	if changed
		writeConfiguration(userConfigurationFile, userConfiguration)

	if FileExist(kUserHomeDirectory . "Setup\Setup.data")
		FileAppend `nModule.Team Server.Selected=true, %kUserHomeDirectory%Setup\Setup.data

	if FileExist(kUserConfigDirectory . "Simulator Startup.ini") {
		userConfigurationFile := getFileName("Application Settings.ini", kUserConfigDirectory)
		userConfiguration := readConfiguration(userConfigurationFile)

		setConfigurationValue(userConfiguration, "Simulator Startup", "CloseLaunchPad"
							, getConfigurationValue(readConfiguration(kUserConfigDirectory . "Simulator Startup.ini")
												  , "Startup", "CloseLaunchPad"))

		writeConfiguration(userConfigurationFile, userConfiguration)

		deleteFile(kUserConfigDirectory . "Simulator Startup.ini")
	}
}

updateConfigurationForV426() {
	local ignore, simulator, car, track, fileName

	for ignore, simulator in ["AC", "AMS2", "PCARS2", "R3E"] {
		deleteDirectory(kDatabaseDirectory . "User\Tracks\" . simulator)

		loop Files, %kDatabaseDirectory%User\%simulator%\*.*, D					; Car
		{
			car := A_LoopFileName

			loop Files, %kDatabaseDirectory%User\%simulator%\%car%\*.*, D		; Track
			{
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

	loop Files, %kDatabaseDirectory%User\*.*, D
		if FileExist(A_LoopFilePath . "\Settings.CSV") {
			FileRead text, %A_LoopFilePath%\Settings.CSV

			changed := false

			if InStr(text, "Pitstop.KeyDelay") {
				text := StrReplace(text, "Pitstop.KeyDelay", "Command.KeyDelay")

				changed := true
			}

			if changed {
				deleteFile(A_LoopFilePath . "\Settings.CSV")

				FileAppend %text%, %A_LoopFilePath%\Settings.CSV
			}
		}

}

updateConfigurationForV424() {
	local tyresDB := new TyresDatabase()
	local simulator := "rFactor 2"
	local car, oldCar, track, sourceDirectory, sourceDB, targetDB, ignore, row, data, field, tyresDB
	local targetDirectory, fileName, targetName, name

	loop Files, %kDatabaseDirectory%User\RF2\*.*, D
		if InStr(A_LoopFileName, "#") {
			car := string2Values("#", A_LoopFileName)[1]

			if !FileExist(kDatabaseDirectory "User\RF2\" . car)
				FileMoveDir %kDatabaseDirectory%User\RF2\%A_LoopFileName%, %kDatabaseDirectory%User\RF2\%car%, R
			else {
				oldCar := A_LoopFileName

				loop Files, %kDatabaseDirectory%User\RF2\%oldCar%\*.*, D
				{
					track := A_LoopFileName

					sourceDirectory := (kDatabaseDirectory . "User\RF2\" . oldCar . "\" . track . "\")

					sourceDB := new Database(sourceDirectory, kTelemetrySchemas)
					targetDB := new TelemetryDatabase(simulator, car, track).Database

					for ignore, row in sourceDB.Tables["Electronics"] {
						data := Object()

						for ignore, field in kTelemetrySchemas["Electronics"]
							data[field] := row[field]

						targetDB.add("Electronics", data, true)
					}

					for ignore, row in sourceDB.Tables["Tyres"] {
						data := Object()

						for ignore, field in kTelemetrySchemas["Tyres"]
							data[field] := row[field]

						targetDB.add("Tyres", data, true)
					}

					tyresDB := new TyresDatabase()
					sourceDB := new Database(sourceDirectory, kTyresSchemas)
					targetDB := tyresDB.getTyresDatabase(simulator, car, track)

					for ignore, row in sourceDB.Tables["Tyres.Pressures"] {
						data := Object()

						for ignore, field in kTyresSchemas["Tyres.Pressures"]
							data[field] := row[field]

						targetDB.add("Tyres.Pressures", data, true)
					}

					for ignore, row in sourceDB.Tables["Tyres.Pressures.Distribution"] {
						tyresDB.updatePressure(simulator, car, track
											 , row.Weather, row["Temperature.Air"], row["Temperature.Track"]
											 , row.Compound, row["Compound.Color"]
											 , row.Type, row.Tyre, row.Pressure, row.Count
											 , false, true, "User", row.Driver)
					}

					tyresDB.flush()

					targetDirectory := (kDatabaseDirectory . "User\RF2\" . car . "\" . track . "\Race Strategies")

					FileCreateDir %targetDirectory%

					loop Files, %sourceDirectory%Race Strategies\*.*, F
					{
						fileName := A_LoopFileName
						targetName := fileName

						while FileExist(targetDirectory . "\" . targetName) {
							SplitPath targetName, , , , name

							targetName := (name . " (" . (A_Index + 1) . ").strategy")
						}

						FileCopy %A_LoopFilePath%, %targetDirectory%\%targetName%
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
		sessionDB := new SessionDatabase()
		sessionDBConfig := readConfiguration(kUserConfigDirectory . "Session Database.ini")

		for key, drivers in getConfigurationSectionValues(sessionDBConfig, "Drivers", Object()) {
			key := StrSplit(key, ".", " `t", 2)
			simulator := key[1]
			id := key[2]

			for ignore, driver in string2Values("###", drivers)
				sessionDB.registerDriver(simulator, id, driver)
		}

		removeConfigurationSection(sessionDBConfig, "Drivers")

		writeConfiguration(kUserConfigDirectory . "Session Database.ini", sessionDBConfig)
	}

	loop Files, %kDatabaseDirectory%User\*.*, D									; Simulator
	{
		simulator := A_LoopFileName

		if (simulator = "ACC")
			loop Files, %kDatabaseDirectory%User\%simulator%\*.*, D					; Car
			{
				car := A_LoopFileName

				loop Files, %kDatabaseDirectory%User\%simulator%\%car%\*.*, D		; Track
				{
					track := A_LoopFileName

					empty := true

					loop Files, %kDatabaseDirectory%User\%simulator%\%car%\%track%\*.*, FD
					{
						empty := false

						break
					}

					if (empty && (InStr(track, A_Space) || inList(["Spa-Franchorchamps", "Nürburgring"], track))) {
						directoryName = %kDatabaseDirectory%User\%simulator%\%car%\%track%

						deleteDirectory(directoryName)
					}
				}
			}
	}
}

addOwnerField(database, table, id) {
	local rows := database.Tables[table]
	local changed, ignore, row

	if (rows.Length() > 0) {
		changed := false

		for ignore, row in rows
			if (!row.HasKey("Owner") || (row.Owner = kNull)) {
				row.Owner := id

				changed := true
			}

		if changed
			database.changed(table)
	}
}

clearWearFields(database, table, id) {
	local rows := database.Tables[table]
	local changed, ignore, row, tyre, field

	if (rows.Length() > 0) {
		changed := false

		for ignore, row in rows
			for ignore, tyre in ["Front.Left", "Front.Right", "Rear.Left", "Rear.Right"] {
				field := ("Tyre.Wear." . tyre)

				if (row.HasKey(field) && (row[field] = id)) {
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
	local userConfiguration := readConfiguration(userConfigurationFile)
	local id, simulator, car, track, db, tyresDB

	if (getConfigurationValue(userConfiguration, "Assetto Corsa", "Window Title", false) = "Assetto Corsa Launcher") {
		setConfigurationValue(userConfiguration, "Assetto Corsa", "Window Title", "ahk_exe acs.exe")

		writeConfiguration(userConfigurationFile, userConfiguration)
	}

	FileRead id, % kUserConfigDirectory . "ID"

	tyresDB := new TyresDatabase()

	loop Files, %kDatabaseDirectory%User\*.*, D									; Simulator
	{
		simulator := A_LoopFileName

		loop Files, %kDatabaseDirectory%User\%simulator%\*.*, D					; Car
		{
			car := A_LoopFileName

			loop Files, %kDatabaseDirectory%User\%simulator%\%car%\*.*, D		; Track
			{
				track := A_LoopFileName

				db := new TelemetryDatabase(simulator, car, track).Database

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

	loop Files, %kDatabaseDirectory%User\*.*, D
		if FileExist(A_LoopFilePath . "\Settings.CSV") {
			FileRead text, %A_LoopFilePath%\Settings.CSV
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

				FileAppend %text%, %A_LoopFilePath%\Settings.CSV
			}
		}
}

updateConfigurationForV402() {
	if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
		FileAppend `nPatch.Configuration.Files=`%kUserHomeDirectory`%Setup\Configuration Patch.ini, %kUserHomeDirectory%Setup\Setup.data
		FileAppend `nPatch.Settings.Files=`%kUserHomeDirectory`%Setup\Settings Patch.ini, %kUserHomeDirectory%Setup\Setup.data
	}
}

updateConfigurationForV400() {
	deleteFile(kDatabaseDirectory . "User\UPLOAD")
}

updateConfigurationForV398() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readConfiguration(userConfigurationFile)
	local simulator, car, track, fileName, text, ignore

	if (userConfiguration.Count() > 0) {
		for ignore, simulator in ["Assetto Corsa Competizione", "rFactor 2", "iRacing", "Automobilista 2", "RaceRoom Racing Experience"] {
			if (getConfigurationValue(userConfiguration, "Race Assistant Startup", simulator . ".LoadSettings", false) = "SetupDatabase")
				setConfigurationValue(userConfiguration, "Race Assistant Startup", simulator . ".LoadSettings", "SettingsDatabase")

			if (getConfigurationValue(userConfiguration, "Race Engineer Startup", simulator . ".LoadTyrePressures", false) = "SetupDatabase")
				setConfigurationValue(userConfiguration, "Race Engineer Startup", simulator . ".LoadTyrePressures", "TyresDatabase")

			setConfigurationValue(userConfiguration, "Race Assistant Shutdown", simulator . ".SaveSettings", "Never")
		}

		writeConfiguration(userConfigurationFile, userConfiguration)
	}

	if FileExist(kDatabaseDirectory . "Local") {
		try {
			FileCopyDir %kDatabaseDirectory%Local, %kDatabaseDirectory%User, 1
		}
		catch exception {
			logError(exception)
		}

		deleteDirectory(kDatabaseDirectory . "Local")
	}

	if FileExist(kDatabaseDirectory . "Global") {
		try {
			FileCopyDir %kDatabaseDirectory%Global, %kDatabaseDirectory%Community, 1
		}
		catch exception {
			; ignore
		}

		deleteDirectory(kDatabaseDirectory . "Global")
	}

	loop Files, %kDatabaseDirectory%User\*.*, D									; Simulator
	{
		simulator := A_LoopFileName

		loop Files, %kDatabaseDirectory%User\%simulator%\*.*, D					; Car
		{
			car := A_LoopFileName

			loop Files, %kDatabaseDirectory%User\%simulator%\%car%\*.*, D		; Track
			{
				track := A_LoopFileName

				fileName = %kDatabaseDirectory%User\%simulator%\%car%\%track%\Setup.Pressures.CSV

				if FileExist(fileName)
					FileMove %fileName%, %kDatabaseDirectory%User\%simulator%\%car%\%track%\Tyres.Pressures.CSV

				fileName = %kDatabaseDirectory%User\%simulator%\%car%\%track%\Setup.Pressures.Distribution.CSV

				if FileExist(fileName)
					FileMove %fileName%, %kDatabaseDirectory%User\%simulator%\%car%\%track%\Tyres.Pressures.Distribution.CSV
			}
		}
	}

	if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
		FileRead text, %kUserHomeDirectory%Setup\Setup.data

		text := StrReplace(text, "SetupDatabase", "SessionDatabase")

		deleteFile(kUserHomeDirectory . "Setup\Setup.data")

		FileAppend %text%, %kUserHomeDirectory%Setup\Setup.data, UTF-16
	}
}

updatePluginsForV426() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readConfiguration(userConfigurationFile)
	local changed, pcars2

	if (userConfiguration.Count() > 0) {
		changed := false

		if getConfigurationValue(userConfiguration, "Plugins", "PCARS2", false) {
			pcars2 := new Plugin("PCARS2", userConfiguration)

			if (pcars2.Simulators.Length() = 0) {
				pcars2.iSimulators := ["Project CARS 2"]

				pcars2.saveToConfiguration(userConfiguration)

				changed := true
			}
		}
		else {
			pcars2 := new Plugin("PCARS2", false, false, "Project CARS 2")

			pcars2.saveToConfiguration(userConfiguration)

			changed := true
		}

		if getConfigurationValue(userConfiguration, "Plugins", "Project CARS 2", false) {
			removeConfigurationValue(userConfiguration, "Plugins", "Project CARS 2")

			changed := true
		}

		if changed
			writeConfiguration(userConfigurationFile, userConfiguration)
	}
}

updatePluginsForV424() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readConfiguration(userConfigurationFile)
	local pcars2

	if (userConfiguration.Count() > 0) {
		if !getConfigurationValue(userConfiguration, "Plugins", "PCARS2", false) {
			pcars2 := new Plugin("Project CARS 2", false, false, "", "")

			pcars2.saveToConfiguration(userConfiguration)

			writeConfiguration(userConfigurationFile, userConfiguration)
		}
	}
}

updateConfigurationForV394() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readConfiguration(userConfigurationFile)
	local subtitle

	if (userConfiguration.Count() > 0) {
		subtitle := getConfigurationValue(userConfiguration, "Splash Window", "Subtitle", "")

		if InStr(subtitle, "2021") {
			setConfigurationValue(userConfiguration, "Splash Window", "Subtitle", StrReplace(subtitle, "2021", "2022"))

			writeConfiguration(userConfigurationFile, userConfiguration)
		}
	}
}

updateConfigurationForV384() {
	local simulator, car, track, directoryName

	loop Files, %kDatabaseDirectory%Local\*.*, D									; Simulator
	{
		simulator := A_LoopFileName

		if (simulator = "0") {
			directoryName = %kDatabaseDirectory%Local\%simulator%

			deleteDirectory(directoryName)
		}
		else
			loop Files, %kDatabaseDirectory%Local\%simulator%\*.*, D				; Car
			{
				car := A_LoopFileName

				if (car = "0") {
					directoryName = %kDatabaseDirectory%Local\%simulator%\%car%

					deleteDirectory(directoryName)
				}
				else
					loop Files, %kDatabaseDirectory%Local\%simulator%\%car%\*.*, D	; Track
					{
						track := A_LoopFileName

						if (track = "0") {
							directoryName = %kDatabaseDirectory%Local\%simulator%\%car%\%track%

							deleteDirectory(directoryName)
						}
					}
			}
	}
}

updatePluginsForV402() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readConfiguration(userConfigurationFile)
	local descriptor

	if (userConfiguration.Count() > 0) {
		descriptor := getConfigurationValue(userConfiguration, "Plugins", "Race Spotter", false)

		if descriptor {
			descriptor := StrReplace(descriptor, "raceAssistantListener: off", "raceAssistantListener: On")

			setConfigurationValue(userConfiguration, "Plugins", "Race Spotter", descriptor)
		}

		writeConfiguration(userConfigurationFile, userConfiguration)
	}
}

updatePluginsForV400() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readConfiguration(userConfigurationFile)
	local ignore, name, descriptor

	if (userConfiguration.Count() > 0) {
		for ignore, name in ["Race Engineer", "Race Strategist", "Race Spotter"] {
			descriptor := getConfigurationValue(userConfiguration, "Plugins", name, false)

			if descriptor {
				descriptor := StrReplace(descriptor, "raceAssistantService", "raceAssistantSynthesizer")

				setConfigurationValue(userConfiguration, "Plugins", name, descriptor)
			}
		}

		descriptor := getConfigurationValue(userConfiguration, "Plugins", "Race Spotter", false)

		if descriptor {
			descriptor := StrReplace(descriptor, "raceAssistantListener: false", "raceAssistantListener: true")

			setConfigurationValue(userConfiguration, "Plugins", "Race Spotter", descriptor)
		}

		writeConfiguration(userConfigurationFile, userConfiguration)
	}
}

updatePluginsForV398() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readConfiguration(userConfigurationFile)
	local engineerDescriptor, strategistDescriptor

	if (userConfiguration.Count() > 0) {
		engineerDescriptor := getConfigurationValue(userConfiguration, "Plugins", "Race Engineer", false)

		if engineerDescriptor {
			engineerDescriptor := StrReplace(engineerDescriptor, "openSetupDatabase", "openSessionDatabase")

			setConfigurationValue(userConfiguration, "Plugins", "Race Engineer", engineerDescriptor)
		}

		strategistDescriptor := getConfigurationValue(userConfiguration, "Plugins", "Race Strategist", false)

		if strategistDescriptor {
			strategistDescriptor := StrReplace(strategistDescriptor, "openSetupDatabase", "openSessionDatabase")

			setConfigurationValue(userConfiguration, "Plugins", "Race Strategist", strategistDescriptor)
		}

		writeConfiguration(userConfigurationFile, userConfiguration)
	}
}

updatePluginsForV386() {
	local userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	local userConfiguration := readConfiguration(userConfigurationFile)
	local raceSpotter

	if (userConfiguration.Count() > 0) {
		if !getConfigurationValue(userConfiguration, "Plugins", "Race Spotter", false) {
			raceSpotter := new Plugin("Race Spotter", false, false, "", "raceAssistant: On; raceAssistantName: Elisa; raceAssistantSpeaker: true; raceAssistantListener: false")

			raceSpotter.saveToConfiguration(userConfiguration)

			writeConfiguration(userConfigurationFile, userConfiguration)
		}
	}
}

updateToV380() {
	local title

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
	title := translate("Error")
	MsgBox 262160, %title%, % translate("Your installed version is to old to be updated automatically. Please remove the ""Simulator Controller"" folder in your user ""Documents"" folder and restart the application. Application will exit...")
	OnMessage(0x44, "")

	ExitApp 0
}

checkFileDependency(file, modification) {
	local lastModified

	logMessage(kLogInfo, translate("Checking file ") . file . translate(" for modification"))

	FileGetTime lastModified, %file%, M

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

	loop Files, % directory . "*.ahk", R
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

runSpecialTargets(ByRef buildProgress) {
	local msBuild := kMSBuildDirectory . "MSBuild.exe"
	local currentDirectory := A_WorkingDir
	local index, directory, file, success, solution, text, ignore

	try {
		for index, directory in getFileNames("*", kSourcesDirectory . "Special\") {
			SetWorkingDir %directory%

			for ignore, file in getFileNames("*.sln", directory . "\") {
				success := true

				SplitPath file, , , , solution

				if !kSilentMode
					showProgress({progress: ++buildProgress, message: translate("Compiling ") . solution . translate("...")})

				try {
					if (InStr(solution, "Speech") || InStr(solution, "AC UDP Provider"))
						RunWait %ComSpec% /c ""%msBuild%" "%file%" /p:BuildMode=Release /p:Configuration=Release /p:Platform="x64" > "%kTempDirectory%Special Build.out"", , Hide
					else
						RunWait %ComSpec% /c ""%msBuild%" "%file%" /p:BuildMode=Release /p:Configuration=Release > "%kTempDirectory%Special Build.out"", , Hide

					if ErrorLevel {
						success := false

						FileRead text, %kTempDirectory%Special Build.out

						if (StrLen(Trim(text)) == 0)
							throw "Error while compiling..."
					}
				}
				catch exception {
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
		SetWorkingDir %currentDirectory%
	}
}

runUpdateTargets(ByRef buildProgress) {
	local ignore, target, targetName, progressStep, ignore, updateFunction, message, updatesFileName, updates

	for ignore, target in vUpdateTargets {
		targetName := target[1]

		if !kSilentMode
			showProgress({progress: buildProgress, message: translate("Updating to ") . targetName . translate("...")})

		logMessage(kLogInfo, translate("Updating to ") . targetName)

		Sleep 50

		progressStep := ((100 / (vTargetsCount + 1)) / target[2].Length())

		for ignore, updateFunction in target[2] {
			if !kSilentMode {
				if kUpdateMessages.HasKey(updateFunction)
					message := translate(kUpdateMessages[updateFunction]) . targetName . translate("...")
				else
					message := translate("Updating configuration to ") . targetName . translate("...")

				showProgress({progress: buildProgress, message: message})
			}

			%updateFunction%()

			Sleep 50

			buildProgress := Round(buildProgress + progressStep)
		}

		buildProgress += (100 / (vTargetsCount + 1))

		if !kSilentMode
			showProgress({progress: buildProgress})
	}

	updatesFileName := getFileName("UPDATES", kUserConfigDirectory)

	updates := readConfiguration(updatesFileName)

	for target, ignore in vUpdateSettings
		setConfigurationValue(updates, "Processed", target, true)

	writeConfiguration(updatesFileName, updates)
}

runCleanTargets(ByRef buildProgress) {
	local ignore, target, targetName, fileOrFolder, currentDirectory, directory, pattern, options

	for ignore, target in vCleanupTargets {
		targetName := target[1]

		if !kSilentMode
			showProgress({progress: buildProgress, message: translate("Cleaning ") . targetName . translate("...")})

		logMessage(kLogInfo, translate("Cleaning ") . targetName)

		if (target.Length() == 2) {
			fileOrFolder := target[2]

			if (InStr(FileExist(fileOrFolder), "D")) {
				currentDirectory := A_WorkingDir

				SetWorkingDir %fileOrFolder%

				try {
					loop Files, *.*, FDR
					{
						try {
							if InStr(FileExist(A_LoopFilePath), "D")
								deleteDirectory(A_LoopFilePath)
							else
								deleteFile(A_LoopFilePath)
						}
						catch exception {
							; ignore
						}

						if !kSilentMode
							showProgress({progress: buildProgress, message: translate("Deleting ") . A_LoopFileName . translate("...")})

						Sleep 50
					}
				}
				finally {
					SetWorkingDir %currentDirectory%
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

			SetWorkingDir %directory%

			try {
				loop Files, %pattern%, %options%
				{
					deleteFile(A_LoopFilePath)

					if !kSilentMode
						showProgress({progress: buildProgress, message: translate("Deleting ") . A_LoopFileName . translate("...")})

					Sleep 50
				}
			}
			finally {
				SetWorkingDir %currentDirectory%
			}
		}

		Sleep 50

		buildProgress += (100 / (vTargetsCount + 1))

		if !kSilentMode
			showProgress({progress: buildProgress})
	}
}

runCopyTargets(ByRef buildProgress) {
	local title, ignore, target, targetSource, targetDestination, targetFile, srcLastModified, dstLastModified, copy
	local targetName, targetDirectory

	if !kSilentMode
		showProgress({progress: buildProgress, message: A_Space})

	for ignore, target in vCopyTargets {
		targetName := ConfigurationItem.splitDescriptor(target[1])[1]

		logMessage(kLogInfo, translate("Check ") . targetName)

		targetSource := target[2]
		targetDestination := target[3]

		if InStr(targetSource, "*") {
			FileCreateDir %targetDestination%

			loop Files, %targetSource%
			{
				targetFile := (targetDestination . A_LoopFileName)

				FileGetTime srcLastModified, %A_LoopFilePath%, M
				FileGetTime dstLastModified, %targetFile%, M

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

					FileCopy %A_LoopFilePath%, %targetFile%, 1

					Sleep 50

					buildProgress += (100 / (vTargetsCount + 1))

					if !kSilentMode
						showProgress({progress: buildProgress})
				}
			}
		}
		else {
			if InStr(FileExist(targetSource), "D")
				copy := true
			else {
				FileGetTime srcLastModified, %targetSource%, M
				FileGetTime dstLastModified, %targetDestination%, M

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

					FileCopyDir %targetSource%, %targetDestination%, 1
				}
				else {
					SplitPath targetDestination, , targetDirectory

					FileCreateDir %targetDirectory%
					FileCopy %targetSource%, %targetDestination%, 1
				}

				Sleep 50

				buildProgress += (100 / (vTargetsCount + 1))

				if !kSilentMode
					showProgress({progress: buildProgress})
			}
		}
	}
}

runBuildTargets(ByRef buildProgress) {
	local title, ignore, target, targetName, build, targetSource, targetBinary, srcLastModified, binLastModified
	local compiledFile, targetDirectory, sourceDirectory, sourceCode

	if !kSilentMode
		showProgress({progress: buildProgress, message: ""})

	for ignore, target in vBuildTargets {
		targetName := target[1]

		logMessage(kLogInfo, translate("Check ") . targetName)

		build := false

		targetSource := target[2]
		targetBinary := target[3]

		FileGetTime srcLastModified, %targetSource%, M
		FileGetTime binLastModified, %targetBinary%, M

		if vTargetConfigurationChanged
			build := true
		else if binLastModified {
			build := (build || (ErrorLevel || (srcLastModified > binLastModified)))
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

				if (vTargetConfiguration = "Production") {
					SplitPath targetSource, , sourceDirectory

					FileRead sourceCode, %targetSource%

					sourceCode := StrReplace(sourceCode, ";@SC-IF %configuration% == Development`r`n#Include ..\Framework\Development.ahk`r`n;@SC-EndIF", "")

					sourceCode := StrReplace(sourceCode, ";@SC #Include ..\Framework\Production.ahk", "#Include ..\Framework\Production.ahk")

					deleteFile(sourceDirectory . "\compile.ahk")

					FileAppend %sourceCode%, % sourceDirectory . "\compile.ahk"

					RunWait % kCompiler . " /in """ . sourceDirectory . "\compile.ahk" . """"

					deleteFile(sourceDirectory . "\compile.ahk")
				}
				else
					RunWait % kCompiler . " /in """ . targetSource . """"
			}
			catch exception {
				logMessage(kLogCritical, translate("Cannot compile ") . targetSource . translate(" - source file or AHK Compiler (") . kCompiler . translate(") not found"))

				showMessage(substituteVariables(translate("Cannot compile %targetSource%: Source file or AHK Compiler (%kCompiler%) not found..."), {targetSource: targetSource, kCompiler: kCompiler})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}

			SplitPath targetBinary, compiledFile, targetDirectory
			SplitPath targetSource, , sourceDirectory

			compiledFile := sourceDirectory . "\" . compiledFile

			FileCreateDir %targetDirectory%
			FileMove %compiledFile%, %targetDirectory%, 1
		}

		buildProgress += (100 / (vTargetsCount + 1))

		if !kSilentMode
			showProgress({progress: buildProgress})
	}
}

compareUpdateTargets(t1, t2) {
	if inList(t2[3], t1[1])
		return false
	else if inList(t1[3], t2[1])
		return true
	else
		return (t1[1] >= t2[1])
}

prepareTargets(ByRef buildProgress, updateOnly) {
	local counter := 0
	local targets := readConfiguration(kToolsTargetsFile)
	local updateTargets := getConfigurationSectionValues(targets, "Update", Object())
	local target, arguments, update, cleanupTargets, targetName, cleanup, copyTargets, copy, buildTargets, build, rule

	for target, arguments in updateTargets {
		buildProgress += (A_Index / updateTargets.Count())

		update := vUpdateSettings[target]

		if !kSilentMode
			showProgress({progress: buildProgress, message: target . ": " . (update ? translate("Yes") : translate("No"))})

		if update {
			arguments := string2Values("->", substituteVariables(arguments))

			if (arguments.Length() == 1)
				vUpdateTargets.Push(Array(target, string2Values(",", arguments[1]), []))
			else
				vUpdateTargets.Push(Array(target, string2Values(",", arguments[2]), string2Values(",", arguments[1])))
		}

		Sleep 50
	}

	bubbleSort(vUpdateTargets, "compareUpdateTargets")

	if !updateOnly {
		cleanupTargets := getConfigurationSectionValues(targets, "Cleanup", Object())

		for target, arguments in cleanupTargets {
			targetName := ConfigurationItem.splitDescriptor(target)[1]
			buildProgress += (A_Index / cleanupTargets.Count())

			cleanup := (InStr(target, "*.bak") ? vCleanupSettings[target] : vCleanupSettings[targetName])

			if !kSilentMode
				showProgress({progress: buildProgress, message: targetName . ": " . (cleanup ? translate("Yes") : translate("No"))})

			if cleanup {
				arguments := substituteVariables(arguments)

				vCleanupTargets.Push(Array(target, string2Values(",", arguments)*))
			}

			Sleep 50
		}

		copyTargets := getConfigurationSectionValues(targets, "Copy", Object())

		for target, arguments in copyTargets {
			targetName := ConfigurationItem.splitDescriptor(target)[1]
			buildProgress += (A_Index / copyTargets.Count())

			copy := vCopySettings[targetName]

			if !kSilentMode
				showProgress({progress: buildProgress, message: targetName . ": " . (copy ? translate("Yes") : translate("No"))})

			if copy {
				rule := string2Values("<-", substituteVariables(arguments))

				vCopyTargets.Push(Array(target, rule[2], rule[1]))
			}

			Sleep 50
		}

		buildTargets := getConfigurationSectionValues(targets, "Build", Object())

		for target, arguments in buildTargets {
			buildProgress += (A_Index / buildTargets.Count())

			build := vBuildSettings[target]

			if !kSilentMode
				showProgress({progress: buildProgress, message: target . ": " . (build ? translate("Yes") : translate("No"))})

			if build {
				if (arguments = "Special")
					vSpecialTargets.Push(target)
				else {
					rule := string2Values("<-", substituteVariables(arguments))

					arguments := string2Values(";", rule[2])

					vBuildTargets.Push(Array(target, arguments[1], rule[1], string2Values(",", arguments[2])))
				}
			}

			Sleep 50
		}
	}
}

startSimulatorTools() {
	local exitProcesses := GetKeyState("Shift")
	local updateOnly := false
	local icon := kIconsDirectory . "Tools.ico"
	local buildProgress

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Simulator Tools

	readToolsConfiguration(vUpdateSettings, vCleanupSettings, vCopySettings, vBuildSettings, vSplashTheme, vTargetConfiguration)

	if (A_Args.Length() > 0)
		if (A_Args[1] = "-Update")
			updateOnly := true

	if updateOnly {
		vCleanupSettings := {}
		vCopySettings := {}
		vBuildSettings := {}
	}
	else {
		if !FileExist(kAHKDirectory)
			vBuildSettings := {}

		if (!FileExist(getFileName(kToolsConfigurationFile, kUserConfigDirectory, kConfigDirectory)) || GetKeyState("Ctrl"))
			if !editTargets()
				ExitApp 0
	}

	if (!kSilentMode && vSplashTheme)
		showSplashTheme(vSplashTheme, false, false)

	Sleep 500

	if !kSilentMode
		showProgress({color: "Blue", message: "", title: translate("Preparing Targets")})

	buildProgress := 0

	prepareTargets(buildProgress, updateOnly)

	vTargetsCount := (vUpdateTargets.Length() + vCleanupTargets.Length() + vCopyTargets.Length() + vBuildTargets.Length()
					+ (((kMSBuildDirectory != "") && (vSpecialTargets.Length() > 0)) ? getFileNames("*", kSourcesDirectory . "Special\").Length() : 0))

	if !kSilentMode
		showProgress({message: "", color: "Green", title: translate("Running Targets")})

	runUpdateTargets(buildProgress)

	if !updateOnly {
		if exitProcesses
			exitProcesses(true, true)

		runCleanTargets(buildProgress)

		if (vSpecialTargets.Length() > 0)
			runSpecialTargets(buildProgress)

		runCopyTargets(buildProgress)
		runBuildTargets(buildProgress)
	}

	if !kSilentMode
		showProgress({progress: 100, message: translate("Done")})

	Sleep 500

	if !kSilentMode {
		hideProgress()

		if vSplashTheme
			hideSplashTheme()
	}

	ExitApp 0
}

cancelBuild() {
	local title

	protectionOn()

	try {
		SoundPlay *32
		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
		title := translate("Modular Simulator Controller System")
		MsgBox 262180, %title%, % translate("Cancel target processing?")
		OnMessage(0x44, "")

		IfMsgBox Yes
			ExitApp 0
	}
	finally {
		protectionOff()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

if !isDebug()
	checkInstallation()

startSimulatorTools()


;;;-------------------------------------------------------------------------;;;
;;;                         Hotkey & Label Section                          ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Escape::                   Cancel Build                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
Escape::
cancelBuild()

return