;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Build & Maintenance Tool        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#SingleInstance Force			; Ony one instance allowed
#NoEnv							; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode Input					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%		; Ensures a consistent starting directory.

SetBatchLines -1				; Maximize CPU utilization
ListLines Off					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Tools.ico
;@Ahk2Exe-ExeName Simulator Tools.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Assistants\Libraries\TyresDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kToolsConfigurationFile = "Simulator Tools.ini"
global kToolsTargetsFile = "Simulator Tools.targets"

global kUpdateMessages = {updateTranslations: "Updating translations to "
						, updatePluginLabels: "Updating plugin labels to "
						, updateActionLabels: "Updating action labels to "
						, updateActionIcons: "Updating action icons to "
						, updatePhraseGrammars: "Updating phrase grammars to "}

global kCompiler = kAHKDirectory . "Compiler\ahk2exe.exe"

global kSave = "save"
global kRevert = "revert"

global kOk = "ok"
global kCancel = "cancel"

global kUninstallKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SimulatorController"

global kInstallDirectory = (A_ProgramFiles . "\Simulator Controller\")


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vUpdateTargets = []
global vCleanupTargets = []
global vCopyTargets = []
global vBuildTargets = []
global vSpecialTargets = []

global vSplashTheme = false

global vTargetsCount = 0

global vUpdateSettings = Object()
global vCleanupSettings = Object()
global vCopySettings = Object()
global vBuildSettings = Object()

global vProgressCount = 0


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;
global installLocationPathEdit

installOptions(options) {
	static installationTypeDropDown
	static automaticUpdatesCheck
	static startMenuShortcutsCheck
	static desktopShortcutsCheck
	static startConfigurationCheck
	
	static result := false
	
	if (options == kOk)
		result := kOk
	else if (options == kCancel)
		result := kCancel
	else {
		result := false
	
		Gui Install:Default
				
		Gui Install:-Border ; -Caption
		Gui Install:Color, D0D0D0, D8D8D8

		Gui Install:Font, Bold, Arial

		Gui Install:Add, Text, w330 Center gmoveInstallEditor, % translate("Modular Simulator Controller System") 

		Gui Install:Font, Norm, Arial

		Gui Install:Add, Text, YP+20 w330 cBlue Center gopenInstallDocumentation, % translate("Install")

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
		
		Loop {
			Sleep 200
		} until result
	
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
	static keepUserFilesCheck
	
	static result := false
	
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

		Gui Uninstall:Add, Text, YP+20 w330 cBlue Center gopenInstallDocumentation, % translate("Uninstall")

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
		
		Loop {
			Sleep 200
		} until result
	
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
	GuiControlGet installLocationPathEdit
		
	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Select", "Cancel"]))
	FileSelectFolder directory, *%installLocationPathEdit%, 0, % translate("Select Installation folder...")
	OnMessage(0x44, "")

	if (directory != "")
		GuiControl Text, installLocationPathEdit, %directory%
}

openInstallDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration
}

checkInstallation() {
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
		
		options := {InstallType: getConfigurationValue(installOptions, "Install", "Type", "Registry")
				  , InstallLocation: normalizePath(installLocation)
				  , AutomaticUpdates: getConfigurationValue(installOptions, "Updates", "Automatic", true)
				  , DesktopShortcuts: getConfigurationValue(installOptions, "Shortcuts", "Desktop", false)
				  , StartMenuShortcuts: getConfigurationValue(installOptions, "Shortcuts", "StartMenu", true)
				  , DeleteUserFiles: false}
		
		if (quiet || uninstallOptions(options)) {
			showSplashTheme("McLaren 720s GT3 Pictures")
				
			x := Round((A_ScreenWidth - 300) / 2)
			y := A_ScreenHeight - 150
			
			vProgressCount := 0

			showProgress({x: x, y: y, color: "Blue", title: translate("Uninstalling Simulator Controller"), message: translate("...")})
			
			deleteFiles(options["InstallLocation"])
		
			if options["DeleteUserFiles"] {
				showProgress({message: translate("Removing User files...")})
			
				FileRemoveDir %kUserHomeDirectory%, true
			}
			else
				try {
					FileDelete %kUserConfigDirectory%Simulator Controller.install
				}
				catch exception {
					; ignore
				}
			
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
					;ignore
				}
				
				ExitApp 0
			}

			if (!installLocation || (installLocation = ""))
				installLocation := normalizePath(kInstallDirectory)
			
			isNew := !FileExist(installLocation)
			
			options := {InstallType: getConfigurationValue(installOptions, "Install", "Type", "Registry")
					  , InstallLocation: normalizePath(getConfigurationValue(installOptions, "Install", "Location", installLocation))
					  , AutomaticUpdates: getConfigurationValue(installOptions, "Updates", "Automatic", true)
					  , Verbose: getConfigurationValue(installOptions, "Updates", "Verbose", false)
					  , DesktopShortcuts: getConfigurationValue(installOptions, "Shortcuts", "Desktop", false)
					  , StartMenuShortcuts: getConfigurationValue(installOptions, "Shortcuts", "StartMenu", true)
					  , StartSetup: isNew, Update: !isNew}
			
			packageLocation := normalizePath(kHomeDirectory)
			
			if ((!isNew && !options["Verbose"]) || installOptions(options)) {
				installLocation := options["InstallLocation"]
				
				setConfigurationValue(installOptions, "Install", "Type", options["InstallType"])
				setConfigurationValue(installOptions, "Install", "Location", installLocation)
				setConfigurationValue(installOptions, "Updates", "Automatic", options["AutomaticUpdates"])
				setConfigurationValue(installOptions, "Updates", "Verbose", options["Verbose"])
				setConfigurationValue(installOptions, "Shortcuts", "Desktop", options["DesktopShortcuts"])
				setConfigurationValue(installOptions, "Shortcuts", "StartMenu", options["StartMenuShortcuts"])

				showSplashTheme("McLaren 720s GT3 Pictures")
				
				x := Round((A_ScreenWidth - 300) / 2)
				y := A_ScreenHeight - 150
				
				vProgressCount := 0

				showProgress({x: x, y: y, color: "Blue", title: translate("Installing Simulator Controller"), message: translate("...")})
				
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
				
				writeConfiguration(kUserConfigDirectory . "Simulator Controller.install", installOptions)
				
				hideSplashTheme()
				
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
				
				Sleep 1000
				
				hideProgress()
			
				if isNew {
					if options["StartSetup"]
						Run %installLocation%\Binaries\Simulator Setup.exe
				}
				else {
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

normalizePath(path) {
	return ((SubStr(path, StrLen(path)) = "\") ? SubStr(path, 1, StrLen(path) - 1) : path)
}
	
copyFiles(source, destination, deleteOrphanes) {
	count := 0
	progress := 0
	
	Loop Files, %source%\*, DFR
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
	count := 0
	progress := 0
	
	Loop Files, %installLocation%\*, DFR
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
	
	deleteDirectory(installLocation, step, stepCount)
	
	vProgressCount := (vProgressCount + Round(step * count))
	
	showProgress({progress: vProgressCount})
}

copyDirectory(source, destination, progressStep, ByRef count) {
	FileCreateDir %destination%
	
	files := []
	
	Loop Files, %source%\*.*, DF
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

deleteDirectory(directory, progressStep, ByRef count) {	
	files := []
	
	Loop Files, %directory%\*.*, DF
		files.Push(A_LoopFilePath)
	
	for ignore, fileName in files {
		SplitPath fileName, file
	
		count += 1
		
		showProgress({progress: Round(vProgressCount + (count * progressStep)), message: translate("Deleting ") . file . translate("...")})
		
		if InStr(FileExist(fileName), "D") {
			SplitPath fileName, subDirectory
			
			deleteDirectory(directory . "\" . subDirectory, progressStep, count)
		}
		else
			try {
				FileDelete %fileName%
			}
			catch exception {
				; ignore
			}
		
		Sleep 1
	}
}

cleanupDirectory(source, destination, maxStep, ByRef count) {
	Loop Files, %destination%\*.*, DF
	{
		SplitPath A_LoopFilePath, fileName
		
		if InStr(FileExist(A_LoopFilePath), "D") {
			cleanupDirectory(source . "\" . fileName, A_LoopFilePath, maxStep, count)
			
			FileRemoveDir %A_LoopFilePath%, false
		}
		else if !FileExist(source . "\" . fileName) {
			count := Min(count + 1, maxStep)
		
			showProgress({progress: vProgressCount + count, message: translate("Deleting ") . fileName . translate("...")})
		
			FileDelete %A_LoopFilePath%
			
			Sleep 100
		}
	}
}

removeDirectory(directory) {
	try {
		FileDelete %A_Temp%\Cleanup.bat
	}
	catch exception {
		; ignore
	}
	
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
	deleteFolder := false
	
	if (location = A_StartMenu) {
		location := (A_StartMenu . "\Simulator Controller")
		
		deleteFolder := true
		
		try {
			FileDelete %location%\Uninstall.lnk
		}
		catch exception {
			; ignore
		}
	}
	
	for ignore, name in ["Simulator Startup", "Simulator Settings", "Simulator Setup", "Simulator Configuration", "Race Settings", "Session Database"
					   , "Race Reports", "Strategy Workbench", "Race Center", "Server Administration", "Setup Advisor"]
		try {
			FileDelete %location%\%name%.lnk
		}
		catch exception {
			; ignore
		}

	try {
		FileDelete %location%\Documentation.lnk
	}
	catch exception {
		; ignore
	}
	
	if deleteFolder
		FileRemoveDir %location%
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
	version := StrSplit(kVersion, "-", , 2)[1]
	
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

readToolsConfiguration(ByRef updateSettings, ByRef cleanupSettings, ByRef copySettings, ByRef buildSettings, ByRef splashTheme) {
	targets := readConfiguration(kToolsTargetsFile)
	configuration := readConfiguration(kToolsConfigurationFile)
	updateConfiguration := readConfiguration(getFileName("UPDATES", kUserConfigDirectory))
	
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
	
	if A_IsCompiled
		buildSettings["Simulator Tools"] := false
}

writeToolsConfiguration(updateSettings, cleanupSettings, copySettings, buildSettings, splashTheme) {
	configuration := newConfiguration()
	
	for target, setting in cleanupSettings
		setConfigurationValue(configuration, "Cleanup", target, setting)
		
	for target, setting in copySettings
		setConfigurationValue(configuration, "Copy", target, setting)
		
	for target, setting in buildSettings
		setConfigurationValue(configuration, "Build", target, setting)
	
	setConfigurationValue(configuration, "General", "Splash Theme", splashTheme)
	
	writeConfiguration(kToolsConfigurationFile, configuration)
}

viewFile(fileName, title := "", x := "Center", y := "Center", width := 800, height := 400) {
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
	Gui FV:Add, Text, x8 y8 W%innerWidth% +0x200 +0x1 BackgroundTrans gmoveFileViewer, % translate("Modular Simulator Controller System - Compiler")
	Gui FV:Font
	Gui FV:Add, Text, x8 yp+26 W%innerWidth% +0x200 +0x1 BackgroundTrans, %title%
	
	editHeight := height - 102
	
	Gui FV:Add, Edit, X8 YP+26 W%innerWidth% H%editHeight%, % text
	
	SysGet mainScreen, MonitorWorkArea

	if x is not integer
		switch x {
			case "Left":
				x := 25
			case "Right":
				x := mainScreenRight - width - 25
			default:
				x := "Center"
		}

	if y is not integer
		switch y {
			case "Top":
				y := 25
			case "Bottom":
				y := mainScreenBottom - height - 25
			default:
				y := "Center"
		}
	
	buttonX := Round(width / 2) - 40
	
	Gui FV:Add, Button, Default X%buttonX% y+10 w80 gdismissFileViewer, % translate("Ok")
	
	Gui FV:+AlwaysOnTop
	Gui FV:Show, X%x% Y%y% W%width% H%height% NoActivate
	
	while !dismissed
		Sleep 100
	
	Gui FV:Destroy
}

moveFileViewer() {
	moveByMouse("FV")
}

dismissFileViewer() {
	viewFile(false)
}

saveTargets() {
	editTargets(kSave)
}

cancelTargets() {
	editTargets(kCancel)
}

moveEditor() {
	moveByMouse("TE")
}

editTargets(command := "") {
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
		
		writeToolsConfiguration(vUpdateSettings, vCleanupSettings, vCopySettings, vBuildSettings, vSplashTheme)
		
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
			Throw "Too many update targets detected in editTargets..."
		
		if (vCleanupSettings.Count() > 8)
			Throw "Too many cleanup targets detected in editTargets..."
		
		if (vCopySettings.Count() > 16)
			Throw "Too many copy targets detected in editTargets..."
		
		if (vBuildSettings.Count() > 24)
			Throw "Too many build targets detected in editTargets..."
		
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
			copydHeight := 40
			
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
	 
		themes := getAllThemes()
		chosen := (vSplashTheme ? inList(themes, vSplashTheme) + 1 : 1)
		themes := (translate("None") . "|" . values2String("|", themes*))
		
		yPos := (Max(cleanupHeight + copyHeight + (updateHeight ? updateHeight + 10 : 0), buildHeight) + 86)
		
		Gui TE:Add, Text, X10 Y%yPos%, % translate("Theme")
		Gui TE:Add, DropDownList, X110 YP-5 w310 Choose%chosen% vsplashTheme, %themes%
		
		Gui TE:Add, Button, Default X110 y+20 w100 gsaveTargets, % translate("Run")
		Gui TE:Add, Button, X+10 w100 gcancelTargets, % translate("&Cancel")
	
		Gui TE:Margin, 10, 10
		Gui TE:Show, AutoSize Center
		
		Loop
			Sleep 1000
		until result
	
		return ((result == 1) || (result == 2))
	}
}

updatePhraseGrammars() {
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
}

updateTranslations() {
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
}

deleteActionLabels() {
	deletePluginLabels("Controller Action Labels")
}

deletePluginLabels(fileName := "Controller Plugin Labels") {
	for ignore, fName in getFileNames(fileName . ".*", kUserTranslationsDirectory)
		try {
			FileMove %fName%, %fName%.bak, 1
		}
		catch exception {
			; ignore
		}
}

updateActionLabels() {
	updateActionDefinitions("Controller Action Labels")
}

updateActionIcons() {
	updateActionDefinitions("Controller Action Icons")
}

updateActionDefinitions(fileName := "Controller Plugin Labels") {
	languages := availableLanguages()
	enDefinitions := readConfiguration(kResourcesDirectory . "Templates\" . fileName . ".en")
	
	for ignore, userDefinitionsFile in getFileNames(fileName . ".*", kUserTranslationsDirectory, kUserConfigDirectory) {
		SplitPath userDefinitionsFile, , , languageCode
	
		if !languages.HasKey(languageCode)
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
}

updateCustomCalls(startNumber, endNumber) {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		bundledConfiguration := readConfiguration(getFileName(kSimulatorConfigurationFile, kConfigDirectory))
	
		customCallIndex := startNumber
		
		Loop {
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
	consent := readConfiguration(kUserConfigDirectory . "CONSENT")
	
	if (consent.Count() > 0) {
		setConfigurationValue(consent, "General", "ReNew", true)
		
		writeConfiguration(kUserConfigDirectory . "CONSENT", consent)
	}
}

updateInstallationForV398() {
	installOptions := readConfiguration(kUserConfigDirectory . "Simulator Controller.install")
	
	if (getConfigurationValue(installOptions, "Shortcuts", "StartMenu", false)) {
		installLocation := getConfigurationValue(installOptions, "Install", "Location")
		
		try {
			FileDelete %installLocation%\Binaries\Setup Database.exe
			
			FileCreateShortCut %installLocation%\Binaries\Session Database.exe, %A_StartMenu%\Simulator Controller\Session Database.lnk, %installLocation%\Binaries
		}
		catch exception {
			; ignore
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
			; ignore
		}
	}
}

updateInstallationForV392() {
	installOptions := readConfiguration(kUserConfigDirectory . "Simulator Controller.install")
	
	if (getConfigurationValue(installOptions, "Shortcuts", "StartMenu", false)) {
		installLocation := getConfigurationValue(installOptions, "Install", "Location")
		
		FileCreateShortCut %installLocation%\Binaries\Setup Advisor.exe, %A_StartMenu%\Simulator Controller\Setup Advisor.lnk, %installLocation%\Binaries
	}
}

updateInstallationForV376() {
	installOptions := readConfiguration(kUserConfigDirectory . "Simulator Controller.install")
	
	if (getConfigurationValue(installOptions, "Shortcuts", "StartMenu", false)) {
		installLocation := getConfigurationValue(installOptions, "Install", "Location")
		
		FileCreateShortCut %installLocation%\Binaries\Race Center.exe, %A_StartMenu%\Simulator Controller\Race Center.lnk, %installLocation%\Binaries
		FileCreateShortCut %installLocation%\Binaries\Server Administration.exe, %A_StartMenu%\Simulator Controller\Server Administration.lnk, %installLocation%\Binaries
	}
}

updateInstallationForV358() {
	installOptions := readConfiguration(kUserConfigDirectory . "Simulator Controller.install")
	
	if (getConfigurationValue(installOptions, "Shortcuts", "StartMenu", false)) {
		installLocation := getConfigurationValue(installOptions, "Install", "Location")
		
		FileCreateShortCut %installLocation%\Binaries\Strategy Workbench.exe, %A_StartMenu%\Simulator Controller\Strategy Workbench.lnk, %installLocation%\Binaries
	}
}

updateInstallationForV354() {
	installOptions := readConfiguration(kUserConfigDirectory . "Simulator Controller.install")
	
	if (getConfigurationValue(installOptions, "Shortcuts", "StartMenu", false)) {
		installLocation := getConfigurationValue(installOptions, "Install", "Location")
		
		FileCreateShortCut %installLocation%\Binaries\Race Reports.exe, %A_StartMenu%\Simulator Controller\Race Reports.lnk, %installLocation%\Binaries
	}
}

updateConfigurationForV398() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
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
	
	if FileExist(kDatabaseDirectory . "Local")
		try {
			FileCopyDir %kDatabaseDirectory%Local, %kDatabaseDirectory%User, 1
		
			FileRemoveDir %kDatabaseDirectory%Local, 1
		}
		catch exception {
			; ignore
		}
	
	if FileExist(kDatabaseDirectory . "Global")
		try {
			FileCopyDir %kDatabaseDirectory%Global, %kDatabaseDirectory%Community, 1
		
			FileRemoveDir %kDatabaseDirectory%Global, 1
		}
		catch exception {
			; ignore
		}
	
	Loop Files, %kDatabaseDirectory%User\*.*, D									; Simulator
	{
		simulator := A_LoopFileName
		
		Loop Files, %kDatabaseDirectory%User\%simulator%\*.*, D					; Car
		{
			car := A_LoopFileName
			
			Loop Files, %kDatabaseDirectory%User\%simulator%\%car%\*.*, D		; Track
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
		
		FileDelete %kUserHomeDirectory%Setup\Setup.data
		FileAppend %text%, %kUserHomeDirectory%Setup\Setup.data, UTF-16
	}
}

updateConfigurationForV394() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		subtitle := getConfigurationValue(userConfiguration, "Splash Window", "Subtitle", "")
		
		if InStr(subtitle, "2021") {
			setConfigurationValue(userConfiguration, "Splash Window", "Subtitle", StrReplace(subtitle, "2021", "2022"))
			
			writeConfiguration(userConfigurationFile, userConfiguration)
		}
	}
}

updateConfigurationForV384() {
	setupDB := new TyresDatabase()
	
	Loop Files, %kDatabaseDirectory%Local\*.*, D									; Simulator
	{
		simulator := A_LoopFileName
		
		if (simulator = "0")
			try {
				FileRemoveDir %kDatabaseDirectory%Local\%simulator%, 1
			}
			catch exception {
				; ignore
			}
		else
			Loop Files, %kDatabaseDirectory%Local\%simulator%\*.*, D				; Car
			{
				car := A_LoopFileName
				
				if (car = "0")
					try {
						FileRemoveDir %kDatabaseDirectory%Local\%simulator%\%car%, 1
					}
					catch exception {
						; ignore
					}
				else
					Loop Files, %kDatabaseDirectory%Local\%simulator%\%car%\*.*, D	; Track
					{
						track := A_LoopFileName
						
						if (track = "0")
							try {
								FileRemoveDir %kDatabaseDirectory%Local\%simulator%\%car%\%track%, 1
							}
							catch exception {
								; ignore
							}
					}
			}
	}
}

updateConfigurationForV378() {
	if FileExist(kDatabaseDirectory . "Local\ACC\iexus_rc_f_gt3")
		FileMoveDir %kDatabaseDirectory%Local\ACC\iexus_rc_f_gt3, %kDatabaseDirectory%Local\ACC\lexus_rc_f_gt3, R
}

updateConfigurationForV372() {
	setupDB := new TyresDatabase()
	
	Loop Files, %kDatabaseDirectory%Local\*.*, D									; Simulator
	{
		simulator := A_LoopFileName
		
		Loop Files, %kDatabaseDirectory%Local\%simulator%\*.*, D					; Car
		{
			car := A_LoopFileName
			
			Loop Files, %kDatabaseDirectory%Local\%simulator%\%car%\*.*, D			; Track
			{
				track := A_LoopFileName
				
				Loop Files, %kDatabaseDirectory%Local\%simulator%\%car%\%track%\Tyre Setup*.*
				{
					condition := string2Values(A_Space, StrReplace(StrReplace(A_LoopFileName, "Tyre Setup ", ""), ".data", ""))
				
					if (condition.Length() == 2) {
						compound := condition[1]
						compoundColor := "Black"
						weather := condition[2]
					}
					else {
						compound := condition[1]
						compoundColor := condition[2]
						weather := condition[3]
					}
					
					setupDB.requireDatabase(simulator, car, track)
					
					pressureData := readConfiguration(A_LoopFilePath)
					
					for temperature, pressures in getConfigurationSectionValues(pressureData, "Pressures", Object()) {
						temperature := ConfigurationItem.splitDescriptor(temperature)
						airTemperature := temperature[1]
						trackTemperature := temperature[2]
						pressures := string2Values(";", pressures)
							
						for index, tyre in ["FL", "FR", "RL", "RR"]
							for ignore, pressure in string2Values(",", pressures[index]) {
								pressure := string2Values(":", pressure)
							
								setupDB.updatePressure(simulator, car, track, weather, airTemperature, trackTemperature, compound, compoundColor
													 , "Cold", tyre, pressure[1], pressure[2], false, false)
							}
					}
					
					setupDB.flush()
					
					try {
						FileDelete %A_LoopFilePath%
					}
					catch exception {
						; ignore
					}
				}
			}
		}
	}
}

updateConfigurationForV368() {
	if FileExist(kUserHomeDirectory . "Setup\Setup.data") {
		setupConfig := readConfiguration(kUserHomeDirectory . "Setup\Setup.data")
		
		if (getConfigurationValue(setupConfig, "Setup", "Module.Controller.Selected", kUndefined) == kUndefined) {
			setConfigurationValue(setupConfig, "Setup", "Module.Controller.Selected", getConfigurationValue(setupConfig, "Setup", "Module.Button Box.Selected", false))
			removeConfigurationValue(setupConfig, "Setup", "Module.Button Box.Selected")
			
			writeConfiguration(kUserHomeDirectory . "Setup\Setup.data", setupConfig)
		}
	}
}

updateConfigurationForV358() {
	sourceDirectory := (kUserHomeDirectory . "Setup Database")
	destinationDirectory := (kUserHomeDirectory . "Database")
	
	if FileExist(sourceDirectory)
		FileMoveDir %sourceDirectory%, %destinationDirectory%, 1
}

updateConfigurationForV314() {
	if FileExist(kUserConfigDirectory . "Race Engineer.settings")
		try {
			FileMove %kUserConfigDirectory%Race Engineer.settings, %kUserConfigDirectory%Race.settings, 1
		}
		catch exception {
			; ignore
		}
	
	Loop Files, %kDatabaseDirectory%Local\*.*, D									; Simulator
	{
		simulator := A_LoopFileName
		
		Loop Files, %kDatabaseDirectory%Local\%simulator%\*.*, D					; Car
		{
			car := A_LoopFileName
			
			Loop Files, %kDatabaseDirectory%Local\%simulator%\%car%\*.*, D			; Track
			{
				track := A_LoopFileName
		
				try {
					FileMoveDir %kDatabaseDirectory%Local\%simulator%\%car%\%track%\Race Engineer Settings, %kDatabaseDirectory%Local\%simulator%\%car%\%track%\Race Settings, R
				}
				catch exception {
					; ignore
				}
			}
		}
	}
}

updateConfigurationForV310() {
	if FileExist(kUserConfigDirectory . "Race Engineer.rules")
		try {
			FileMove %kUserConfigDirectory%Race Engineer.rules, %kUserRulesDirectory%, 1
		}
		catch exception {
			; ignore
		}
	
	for ignore, fileName in getFileNames("Translations.*", kUserConfigDirectory)
		try {
			FileMove %fileName%, %kUserTranslationsDirectory%, 1
		}
		catch exception {
			; ignore
		}
	
	for ignore, fileName in getFileNames("Controller Plugin Labels.*", kUserConfigDirectory)
		try {
			FileMove %fileName%, %kUserTranslationsDirectory%, 1
		}
		catch exception {
			; ignore
		}
	
	for ignore, fileName in getFileNames("Race Engineer.grammars.*", kUserConfigDirectory)
		try {
			FileMove %fileName%, %kUserGrammarsDirectory%, 1
		}
		catch exception {
			; ignore
		}
}

updatePluginsForV398() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
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
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		if !getConfigurationValue(userConfiguration, "Plugins", "Race Spotter", false) {
			raceSpotter := new Plugin("Race Spotter", false, false, "", "raceAssistant: On; raceAssistantName: Elisa; raceAssistantSpeaker: true; raceAssistantListener: false")
			
			raceSpotter.saveToConfiguration(userConfiguration)
			
			writeConfiguration(userConfigurationFile, userConfiguration)
		}
	}
}

updatePluginsForV370() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		if !getConfigurationValue(userConfiguration, "Plugins", "Team Server", false) {
			teamServer := new Plugin("Team Server", false, false, "", "teamServer: Off")
			
			teamServer.saveToConfiguration(userConfiguration)
			
			writeConfiguration(userConfigurationFile, userConfiguration)
		}
	}
}

updatePluginsForV322() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		engineerDescriptor := getConfigurationValue(userConfiguration, "Plugins", "Race Engineer", false)
		
		if engineerDescriptor {
			engineerDescriptor := StrReplace(engineerDescriptor, "raceEngineerCommands", "assistantCommands")
			engineerDescriptor := StrReplace(engineerDescriptor, "raceEngineerOpenSettings", "openRaceSettings")
			engineerDescriptor := StrReplace(engineerDescriptor, "raceEngineerOpenSetups", "openSetupDatabase")
			engineerDescriptor := StrReplace(engineerDescriptor, "raceEngineerImportSettings", "importSetup")
			engineerDescriptor := StrReplace(engineerDescriptor, "raceEngineer", "raceAssistant")
			
			setConfigurationValue(userConfiguration, "Plugins", "Race Engineer", engineerDescriptor)
		}
		
		strategistDescriptor := getConfigurationValue(userConfiguration, "Plugins", "Race Strategist", false)
		
		if strategistDescriptor {
			strategistDescriptor := StrReplace(strategistDescriptor, "Cato", "Khato")
			strategistDescriptor := StrReplace(strategistDescriptor, "raceStrategistCommands", "assistantCommands")
			strategistDescriptor := StrReplace(strategistDescriptor, "raceStrategistOpenSettings", "openRaceSettings")
			strategistDescriptor := StrReplace(strategistDescriptor, "raceStrategistOpenSetups", "openSetupDatabase")
			strategistDescriptor := StrReplace(strategistDescriptor, "raceStrategistImportSettings", "importSetup")
			strategistDescriptor := StrReplace(strategistDescriptor, "raceStrategist", "raceAssistant")
			
			setConfigurationValue(userConfiguration, "Plugins", "Race Strategist", strategistDescriptor)
		}
			
		writeConfiguration(userConfigurationFile, userConfiguration)
	}
}

updatePluginsForV316() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0) {
		if !getConfigurationValue(userConfiguration, "Plugins", "AMS2", false) {
			ams2Plugin := new Plugin("AMS2", readConfiguration(getFileName(kSimulatorConfigurationFile, kConfigDirectory)))
				
			ams2Plugin.iIsActive := false
			
			ams2Plugin.saveToConfiguration(userConfiguration)
			
			writeConfiguration(userConfigurationFile, userConfiguration)
		}
	}
}

updatePluginsForV312() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0)
		if getConfigurationValue(userConfiguration, "Plugins", "Race Strategist", false) {
			raceStrategistPlugin := new Plugin("Race Strategist", userConfiguration)
				
			if (raceStrategistPlugin.getArgumentValue("raceStrategistName", "Toni") = "Toni") {
				raceStrategistPlugin.setArgumentValue("raceStrategistName", "Cato")
				
				raceStrategistPlugin.saveToConfiguration(userConfiguration)
			
				writeConfiguration(userConfigurationFile, userConfiguration)
			}
		}
}

updatePluginsForV310() {
	userConfigurationFile := getFileName(kSimulatorConfigurationFile, kUserConfigDirectory)
	userConfiguration := readConfiguration(userConfigurationFile)
	
	if (userConfiguration.Count() > 0)
		if !getConfigurationValue(userConfiguration, "Plugins", "Race Strategist", false) {
			raceStrategistPlugin := new Plugin("Race Strategist", readConfiguration(getFileName(kSimulatorConfigurationFile, kConfigDirectory)))
				
			raceStrategistPlugin.iIsActive := false
			
			raceStrategistPlugin.saveToConfiguration(userConfiguration)
			
			writeConfiguration(userConfigurationFile, userConfiguration)
		}
}

updateToV30() {
	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
	title := translate("Error")
	MsgBox 262160, %title%, % translate("Your installed version is to old to be updated automatically. Please remove the ""Simulator Controller"" folder in your user ""Documents"" folder and restart the application. Application will exit...")
	OnMessage(0x44, "")
	
	ExitApp 0
}

checkFileDependency(file, modification) {
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
	logMessage(kLogInfo, translate("Checking all files in ") . directory)
	
	files := []
	
	Loop Files, % directory . "*.ahk", R
	{
		files.Push(A_LoopFilePath)
	}
	
	for ignore, file in files
		if checkFileDependency(file, modification)
			return true
	
	return false
}

checkDependencies(dependencies, modification) {
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
	msBuild := kMSBuildDirectory . "MSBuild.exe"
	
	currentDirectory := A_WorkingDir
	
	try {
		for index, directory in getFileNames("*", kSourcesDirectory . "Special\") {
			SetWorkingDir %directory%
			
			for ignore, file in getFileNames("*.sln", directory . "\") {
				success := true
			
				SplitPath file, , , , solution
			
				if !kSilentMode
					showProgress({progress: ++buildProgress, message: translate("Compiling ") . solution . translate("...")})
				
				try {
					if InStr(solution, "Speech")
						RunWait %ComSpec% /c ""%msBuild%" "%file%" /p:BuildMode=Release /p:Configuration=Release /p:Platform="x64" > "%kTempDirectory%build.out"", , Hide
					else
						RunWait %ComSpec% /c ""%msBuild%" "%file%" /p:BuildMode=Release /p:Configuration=Release > "%kTempDirectory%build.out"", , Hide
					
					if ErrorLevel {
						success := false
						
						FileRead text, %kTempDirectory%build.out
						
						if (StrLen(Trim(text)) == 0)
							Throw "Error while compiling..."
					}
				}
				catch exception {
					logMessage(kLogCritical, translate("Cannot compile ") . solution . translate(" - Solution or MSBuild (") . msBuild . translate(") not found"))
			
					showMessage(substituteVariables(translate("Cannot compile %solution%: Solution or MSBuild (%msBuild%) not found..."), {solution: solution, msBuild: msBuild})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
					
					success := true
				}
				
				if !success
					viewFile(kTempDirectory . "build.out", translate("Error while compiling ") . solution, "Left", "Top", 800, 600)
					
				if FileExist(kTempDirectory . "build.out")
					FileDelete %kTempDirectory%build.out
			}
		}
	}
	finally {
		SetWorkingDir %currentDirectory%
	}
}

runUpdateTargets(ByRef buildProgress) {
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
					Loop Files, *.*, FDR
					{
						try {
							if InStr(FileExist(A_LoopFilePath), "D")
								FileRemoveDir %A_LoopFilePath%, 1
							else
								FileDelete %A_LoopFilePath%
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
			else if (FileExist(fileOrFolder) != "") {
				FileDelete %fileOrFolder%
			}
		}
		else {
			currentDirectory := A_WorkingDir
			directory := target[2]
			pattern := target[3]
			options := ((target[4] && (target[4] != "")) ? target[4] : "")
			
			SetWorkingDir %directory%
			
			try {
				Loop Files, %pattern%, %options%
				{
					FileDelete %A_LoopFilePath%
				
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
	local title
	
	if !kSilentMode
		showProgress({progress: buildProgress, message: A_Space})
	
	for ignore, target in vCopyTargets {
		targetName := ConfigurationItem.splitDescriptor(target[1])[1]
			
		logMessage(kLogInfo, translate("Check ") . targetName)

		targetSource := target[2]
		targetDestination := target[3]
		
		if InStr(targetSource, "*") {
			FileCreateDir %targetDestination%
			
			Loop Files, %targetSource%
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
					try {
						FileRemoveDir %targetDestination%, 1
					}
					catch exception {
						; ignore
					}
					
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
	local title
	
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
		
		if binLastModified {
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
					Throw "Source file not found..."
				
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
	counter := 0
	targets := readConfiguration(kToolsTargetsFile)
	
	updateTargets := getConfigurationSectionValues(targets, "Update", Object())
	
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
	updateOnly := false
	
	icon := kIconsDirectory . "Tools.ico"
	
	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Simulator Tools
	
	readToolsConfiguration(vUpdateSettings, vCleanupSettings, vCopySettings, vBuildSettings, vSplashTheme)
	
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
	
	x := Round((A_ScreenWidth - 300) / 2)
	y := A_ScreenHeight - 150
	
	if !kSilentMode
		showProgress({x: x, y: y, color: "Blue", message: "", title: translate("Preparing Targets")})

	buildProgress := 0
	
	prepareTargets(buildProgress, updateOnly)
	
	vTargetsCount := (vUpdateTargets.Length() + vCleanupTargets.Length() + vCopyTargets.Length() + vBuildTargets.Length()
					+ (((kMSBuildDirectory != "") && (vSpecialTargets.Length() > 0)) ? getFileNames("*", kSourcesDirectory . "Special\").Length() : 0))
	
	if !kSilentMode
		showProgress({message: "", color: "Green", title: translate("Running Targets")})
	
	runUpdateTargets(buildProgress)
	
	if !updateOnly {
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

return