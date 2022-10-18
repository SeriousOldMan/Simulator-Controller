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

global kStatusIcons := {Disabled: kIconsDirectory . "Black.ico"
					  , Passive: kIconsDirectory . "Gray.ico"
					  , Active: kIconsDirectory . "Green.ico"
					  , Warning: kIconsDirectory . "Yellow.ico"
					  , Critical: kIconsDirectory . "Red.ico"
					  , Unknown: kIconsDirectory . "Empty.png"}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

systemMonitor(command := false, arguments*) {
	local x, y, time, logLevel, defaultGui, defaultListView
	local controllerStatus, ignore, plugin, icons, plugins, key, icon, status

	static statusIconsList := false
	static statusIcons := {}
	static statusPlugins := false

	static result := false
	static first := true

	static statusListView

	static logMessageListView
	static logBufferEdit

	if (command = kClose)
		result := kClose
	else if (command = "UpdateStatus") {
		defaultGui := A_DefaultGui

		Gui SM:Default

		defaultListView := A_DefaultListView

		Gui ListView, % statusListView

		try {
			if !statusIconsList {
				statusIconsList := IL_Create(kStatusIcons.Count())

				for key, icon in kStatusIcons {
					IL_Add(statusIconsList, icon)

					statusIcons[key] := A_Index
				}

				LV_SetImageList(statusIconsList)
			}

			controllerStatus := getControllerStatus()

			icons := []
			plugins := []
			messages := []

			for ignore, plugin in string2Values("|", getConfigurationValue(controllerStatus, "Plugins", "Plugins")) {
				if plugin {
					status := getConfigurationValue(controllerStatus, plugin, "Status")

					if statusIcons.HasKey(status)
						icons.Push(statusIcons[status])
					else
						icons.Push(statusIcons["Unknown"])

					plugins.Push(translate(plugin))

					messages.Push(getConfigurationValue(controllerStatus, plugin, "Information", ""))
				}
			}

			if (!statusPlugins || !listEqual(plugins, statusPlugins)) {
				LV_Delete()

				LV_SetImageList(statusIconsList)

				for ignore, plugin in plugins
					LV_Add("Icon" . icons[A_Index], "    " . plugin, messages[A_Index])

				LV_ModifyCol()
				LV_ModifyCol(1, "AutoHdr")

				statusPlugins := plugins
			}
			else
				for ignore, plugin in plugins {
					LV_Modify(A_Index, "Icon" . icons[A_Index])
					LV_Modify(A_Index, "Col2", messages[A_Index])
				}

			LV_ModifyCol(2, "AutoHdr")
		}
		catch exception {
			logError(exception)
		}
		finally {
			Gui %defaultGui%:Default
			Gui ListView, %defaultListView%
		}
	}
	else if (command = "LogMessage") {
		defaultGui := A_DefaultGui

		Gui SM:Default

		defaultListView := A_DefaultListView

		Gui ListView, % logMessageListView

		GuiControlGet logBufferEdit

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

			if (LV_GetCount() > 0)
				while (LV_GetCount() >= logBufferEdit)
					LV_Delete(1)

			LV_Add("", arguments[1], time, translate(logLevel), arguments[4])
			LV_Modify(LV_GetCount(), "Vis")

			if first {
				first := false

				LV_ModifyCol()

				loop 4
					LV_ModifyCol(A_Index, "AutoHdr")
			}
			else
				LV_ModifyCol(4, "AutoHdr")
		}
		catch exception {
			logError(exception)
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

		Gui SM:Add, Text, w780 Center gmoveSystemMonitor, % translate("Modular Simulator Controller System")

		Gui SM:Font, s9 Norm, Arial
		Gui SM:Font, Italic Underline, Arial

		Gui SM:Add, Text, x333 YP+20 w140 cBlue Center gopenSystemMonitorDocumentation, % translate("Monitor")

		Gui SM:Font, s8 Norm, Arial

		Gui SM:Add, Text, x8 yp+26 w790 0x10

		Gui SM:Add, Tab3, x16 yp+14 w773 h380 -Wrap Section, % values2String("|", map(["Plugins", "Team Server", "Processes", "Logs"], "translate")*)

		Gui Tab, 1

		Gui SM:Add, ListView, x24 ys+28 w756 h312 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDstatusListView, % values2String("|", map(["Plugin", "Information"], "translate")*)

		Gui Tab, 4

		Gui SM:Add, ListView, x24 ys+28 w756 h312 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDlogMessageListView, % values2String("|", map(["Application", "Time", "Category", "Message"], "translate")*)

		Gui SM:Add, Text, x24 yp+320 w95 h20, % translate("Log Buffer")
		Gui SM:Add, Edit, x120 yp-2 w50 h20 Limit3 Number VlogBufferEdit, 999
		Gui SM:Add, UpDown, x158 yp w18 h20 Range100-999, 999

		Gui Tab

		Gui SM:Font, s8 Norm, Arial

		Gui SM:Add, Text, x8 ys+390 w790 0x10

		Gui SM:Add, Button, x367 yp+10 w80 h23 Default GcloseSystemMonitor, % translate("Close")

		x := false
		y := false

		if getWindowPosition("System Monitor", x, y)
			Gui SM:Show, x%x% y%y%
		else
			Gui SM:Show

		new PeriodicTask(Func("systemMonitor").Bind("UpdateStatus"), 5000, kLowPriority).start()

		loop
			Sleep 100
		until result

		Gui SM:Destroy

		return ((result = kClose) ? false : true)
	}
}

closeSystemMonitor() {
	ExitApp 0
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

	deleteFile(kUserConfigDirectory . "Simulator Controller.status")

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