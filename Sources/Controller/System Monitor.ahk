;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - System Monitor                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
#Include ..\Includes\Development.ahk
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include ..\Includes\Production.ahk
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Monitoring.ico
;@Ahk2Exe-ExeName System Monitor.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Libraries\Messages.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kClose := "Close"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

systemMonitor(command := false, arguments*) {
	local x, y, time, logLevel, defaultGui, defaultListView

	static result := false
	static first := true

	static logMessageListView

	if (command = kClose)
		result := kClose
	else if (command = "LogMessage") {
		defaultGui := A_DefaultGui
		defaultListView := A_DefaultListView

		Gui SM:Default
		Gui ListView, % logMessageListView

		try {
			logLevel := arguments[3]

			switch logLevel {
				case kLogInfo:
					logLevel := "Info"
				case kLogWarn:
					logLevel := "Warn"
				case kLogCritical:
					logLevel := "Critical"
				case kLogOff:
					logLevel := "Off"
				default:
					logLevel := "Unknown"
			}

			time := arguments[2]

			FormatTime, time, %time%, dd.MM.yy hh:mm:ss tt

			LV_Add("", arguments[1], time, translate(logLevel), arguments[4])
			LV_Modify(LV_GetCount(), "Vis")

			if first {
				first := false

				LV_ModifyCol()

				loop 4
					LV_ModifyCol(A_Index, "AutoHdr")
			}
			else
				LV_ModifyCol(4)
		}
		finally {
			Gui %defaultGui%:Default
			Gui ListView, %defaultListView%
		}
	}
	else {
		result := false

		Gui SM:Default

		Gui SM:-Border ; -Caption
		Gui SM:Color, D0D0D0, D8D8D8

		Gui SM:Font, s10 Bold, Arial

		Gui SM:Add, Text, w580 Center gmoveSystemMonitor, % translate("Modular Simulator Controller System")

		Gui SM:Font, s9 Norm, Arial
		Gui SM:Font, Italic Underline, Arial

		Gui SM:Add, Text, x233 YP+20 w140 cBlue Center gopenSystemMonitorDocumentation, % translate("Monitor")

		Gui SM:Font, s8 Norm, Arial

		Gui SM:Add, Text, x8 yp+26 w590 0x10

		Gui SM:Add, ListView, x16 yp+14 w572 h280 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDlogMessageListView, % values2String("|", map(["Application", "Time", "Category", "Message"], "translate")*)

		Gui SM:Font, s8 Norm, Arial

		Gui SM:Add, Text, x8 yp+290 w590 0x10

		Gui SM:Add, Button, x267 yp+10 w80 h23 Default GcloseSystemMonitor, % translate("Close")

		x := false
		y := false

		if getWindowPosition("System Monitor", x, y)
			Gui SM:Show, x%x% y%y%
		else
			Gui SM:Show

		loop
			Sleep 100
		until result

		Gui SM:Destroy

		return ((result = kClose) ? false : true)
	}
}

closeSystemMonitor() {
	systemMonitor(kClose)
}

moveSystemMonitor() {
	moveByMouse("SM", "System Monitor")
}

openSystemMonitorDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller
}

startSystemMonitor() {
	local icon := kIconsDirectory . "Monitoring.ico"
	local noLaunch

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, System Monitor

	registerMessageHandler("Monitor", "monitorMessageHandler")

	systemMonitor()

	ExitApp 0
}

;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

monitorMessageHandler(category, data) {
	if (InStr(data, "logMessage") = 1) {
		data := StrSplit(StrSplit(data, ":", , 2)[2], ";", " `t", 5)

		return withProtection("systemMonitor", "LogMessage", data[1], data[2], data[3], data[4])
	}
	else
		return functionMessageHandler(category, data)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startSystemMonitor()