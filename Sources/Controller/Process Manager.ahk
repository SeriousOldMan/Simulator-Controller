;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Process Manager                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Observer.ico
;@Ahk2Exe-ExeName Process Manager.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Process.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\Messages.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

checkProcessMemory(maxMemory) {
	local ignore, application, applications

	checkMemory(process, pid) {
		local memory := getMemoryUsage(pid)

		if (memory > maxMemory) {
			ProcessClose(pid)

			logMessage(kLogCritical, "Killed " . process . " with memory usage at " . Round((memory / 1024) / 1024, 1) . " MB")
		}
	}

	maxMemory := (maxMemory * 1024 * 1024)

	for ignore, processes in [kForegroundApps, kBackgroundApps]
		for ignore, process in processes {
			pid := ProcessExist(InStr(process, ".exe") ? process : (process . ".exe"))

			if pid
				checkMemory(process, pid)
		}
}

startupProcessManager() {
	local icon := kIconsDirectory . "Observer.ico"

	TraySetIcon(icon, "1")
	A_IconTip := "Process Manager"

	PeriodicTask(checkProcessMemory.Bind(getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
														, "Process", "Memory.Max", 1024)), 500).start()

	startupProcess()
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startupProcessManager()