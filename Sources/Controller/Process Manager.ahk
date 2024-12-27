;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Process Manager                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
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

getProcesses() {
	local d := "  |  "  ; string separator
	local s := 4096  ; size of buffers and arrays (4 KB)
	local ScriptPID := ProcessExist()  ; The PID of this running script.
	local ti, r, t, h, n, e, a, c, l

	static hModule := DllCall("LoadLibrary", "Str", "Psapi.dll")  ; Increase performance by preloading the library.

	; Get the handle of this script with PROCESS_QUERY_INFORMATION (0x0400):
	h := DllCall("OpenProcess", "UInt", 0x0400, "Int", false, "UInt", ScriptPID, "Ptr")

	; Open an adjustable access token with this process (TOKEN_ADJUST_PRIVILEGES = 32):
	DllCall("Advapi32.dll\OpenProcessToken", "Ptr", h, "UInt", 32, "PtrP", &t := 0)

	; Retrieve the locally unique identifier of the debug privilege:
	DllCall("Advapi32.dll\LookupPrivilegeValue", "Ptr", 0, "Str", "SeDebugPrivilege", "Int64P", &luid := 0)

	ti := Buffer(16, 0)  ; structure of privileges

	NumPut( "UInt", 1  ; one entry in the privileges array...
		  , "Int64", luid
		  , "UInt", 2  ; Enable this privilege: SE_PRIVILEGE_ENABLED = 2
		  , ti)

	; Update the privileges of this process with the new access token:
	r := DllCall("Advapi32.dll\AdjustTokenPrivileges", "Ptr", t, "Int", false, "Ptr", ti, "UInt", 0, "Ptr", 0, "Ptr", 0)

	DllCall("CloseHandle", "Ptr", t)  ; Close the access token handle to save memory.
	DllCall("CloseHandle", "Ptr", h)  ; Close the process handle to save memory.

	a := Buffer(s)  ; An array that receives the list of process identifiers:
	l := []

	DllCall("Psapi.dll\EnumProcesses", "Ptr", a, "UInt", s, "UIntP", &r)

	loop r // 4 { ; Parse array for identifiers as DWORDs (32 bits):
		id := NumGet(a, A_Index * 4, "UInt")

		; Open process with: PROCESS_VM_READ (0x0010) | PROCESS_QUERY_INFORMATION (0x0400)
		h := DllCall("OpenProcess", "UInt", 0x0010 | 0x0400, "Int", false, "UInt", id, "Ptr")

		if !h
			continue

		n := Buffer(s, 0)  ; A buffer that receives the base name of the module:
		e := DllCall("Psapi.dll\GetModuleBaseName", "Ptr", h, "Ptr", 0, "Ptr", n, "UInt", s // 2)

		if !e    ; Fall-back method for 64-bit processes when in 32-bit mode:
			e := DllCall("Psapi.dll\GetProcessImageFileName", "Ptr", h, "Ptr", n, "UInt", s // 2)

		SplitPath StrGet(n), &n

		DllCall("CloseHandle", "Ptr", h)  ; Close the process handle to save memory.

		if (n && e)  ; If image is not null add to list:
			l.Push([n, id])
	}

	return l
}

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

killZombies() {
	local provider := choose(getProcesses(), (p) => p[1] = "ACC UDP Provider.exe")
	local validPIDs

	static validProvider := []

	if (provider.Length <= 2)
		validProvider := provider
	else {
		validPIDs := collect(validProvider, (vp) => vp[2])

		do(provider, (p) {
			if !inList(validPIDs, p[2]) {
				ProcessClose(p[2])

				logMessage(kLogCritical, "Killed zombie ACC UDP provider process " . p[2])
			}
		})
	}
}

startupProcessManager() {
	local icon := kIconsDirectory . "Observer.ico"

	TraySetIcon(icon, "1")
	A_IconTip := "Process Manager"

	PeriodicTask(checkProcessMemory.Bind(getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory))
														, "Process", "Memory.Max", 1024)), 500).start()
	PeriodicTask(killZombies, 500).start()

	startupProcess()
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startupProcessManager()