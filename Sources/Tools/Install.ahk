;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Manual Installer                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#Requires AutoHotkey v2.0

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Logo.ico
;@Ahk2Exe-ExeName Install.exe
;@Ahk2Exe-SetCompanyName Oliver Juwig (TheBigO)
;@Ahk2Exe-SetCopyright TheBigO - Creative Commons - BY-NC-SA
;@Ahk2Exe-SetProductName Simulator Controller
;@Ahk2Exe-SetVersion 1.0.0.0

if !A_IsAdmin {
	if RegExMatch(DllCall("GetCommandLine", "str"), " /restart(?!\S)") {
		MsgBox("Installer cannot request Admin privileges. Please enable User Account Control.", "Error", 262160)

		ExitApp(0)
	}

	try {
		if A_IsCompiled
			Run((!A_IsAdmin ? "*RunAs `"" : "`"") . A_ScriptFullPath . "`" /restart")
		else
			Run((!A_IsAdmin ? "*RunAs `"" : "`"") . A_AhkPath . "`" /restart `"" . A_ScriptFullPath . "`"")
	}
	catch Any as exception {
		MsgBox("An error occured while starting the installation due to Windows security restrictions.", "Error", 262160)
	}

	ExitApp(0)
}

SetWorkingDir(".\Binaries")

RunWait("Powershell -Command Get-ChildItem -Path '.' | Unblock-File", , "Hide")

Run(".\Binaries\Simulator Tools.exe", , "Hide")