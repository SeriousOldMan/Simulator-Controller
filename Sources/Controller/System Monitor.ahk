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

global kStateIcons := {Disabled: kIconsDirectory . "Black.ico"
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
	local controllerState, ignore, plugin, icons, plugins, key, value, icon, state, property

	static stateIconsList := false
	static stateIcons := {}
	static statePlugins := false

	static serverState
	static serverURL := ""
	static serverToken := ""
	static serverDriver := ""
	static serverTeam := ""
	static serverSession := ""

	static result := false
	static first := true

	static stateListView

	static logMessageListView
	static logBufferEdit

	if !stateIconsList {
		stateIconsList := IL_Create(kStateIcons.Count())

		for key, icon in kStateIcons {
			IL_Add(stateIconsList, icon)

			stateIcons[key] := A_Index
		}

		LV_SetImageList(stateIconsList)
	}

	if (command = kClose)
		result := kClose
	else if (command = "UpdateModuleState") {
		defaultGui := A_DefaultGui

		Gui SM:Default

		defaultListView := A_DefaultListView

		Gui ListView, % stateListView

		try {
			controllerState := getControllerState()

			icons := []
			plugins := []
			messages := []

			for ignore, plugin in string2Values("|", getConfigurationValue(controllerState, "Plugins", "Plugins")) {
				if plugin {
					state := getConfigurationValue(controllerState, plugin, "State")

					if stateIcons.HasKey(state)
						icons.Push(stateIcons[state])
					else
						icons.Push(stateIcons["Unknown"])

					plugins.Push(translate(plugin))

					messages.Push(getConfigurationValue(controllerState, plugin, "Information", ""))
				}
			}

			if (!statePlugins || !listEqual(plugins, statePlugins)) {
				LV_Delete()

				LV_SetImageList(stateIconsList)

				for ignore, plugin in plugins
					LV_Add("Icon" . icons[A_Index], "    " . plugin, messages[A_Index])

				LV_ModifyCol()
				LV_ModifyCol(1, "AutoHdr")

				statePlugins := plugins
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
	else if (command = "UpdateServerState") {
		serverURL := ""
		serverToken := ""
		serverDriver := ""
		serverTeam := ""
		serverSession := ""

		defaultGui := A_DefaultGui

		Gui SM:Default

		try {
			controllerState := getControllerState()

			if (controllerState.Count() > 0) {
				state := getConfigurationValue(controllerState, "Team Server", "State", "Unknown")

				if kStateIcons.HasKey(state)
					icon := kStateIcons[state]
				else
					icon := kStateIcons["Unknown"]

				GuiControl, , serverState, %icon%

				if ((state != "Unknown") && (state != "Disabled")) {
					state := {}

					for ignore, property in string2Values(";", getConfigurationValue(controllerState, "Team Server", "Properties")) {
						property := StrSplit(property, ":", " `t", 2)

						state[property[1]] := property[2]
					}

					for key, value in state {
						if (value = "Invalid")
							value := translate("Not valid")
						else if (value = "Mismatch")
							value := translate("No match")

						switch key {
							case "ServerURL":
								serverURL := value
							case "SessionToken":
								serverToken := value
							case "Driver":
								serverDriver := value
							case "Team":
								serverTeam := value
							case "Session":
								serverSession := value
						}
					}
				}
			}

			GuiControl, , serverURL, %serverURL%
			GuiControl, , serverToken, %serverToken%
			GuiControl, , serverDriver, %serverDriver%
			GuiControl, , serverTeam, %serverTeam%
			GuiControl, , serverSession, %serverSession%
		}
		finally {
			Gui %defaultGui%:Default
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

		Gui SM:Add, Tab3, x16 yp+14 w773 h375 -Wrap Section, % values2String("|", map(["State", "Team Server", "Processes", "Logs"], "translate")*)

		Gui Tab, 1

		Gui SM:Add, ListView, x24 ys+28 w756 h336 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDstateListView gnoSelect, % values2String("|", map(["Module", "Information"], "translate")*)

		Gui Tab, 2

		Gui SM:Font, s10 Bold, Arial

		Gui SM:Add, Text, x24 ys+30 w120 h30, % translate("State")
		Gui SM:Add, Picture, x155 yp-2 w24 h24 vServerState

		Gui SM:Font, s8 Norm, Arial

		Gui SM:Font, Norm, Arial
		Gui SM:Font, Italic, Arial

		Gui SM:Add, GroupBox, -Theme x24 ys+60 w360 h150, % translate("Connection")

		Gui SM:Font, Norm, Arial

		Gui SM:Add, Text, x32 yp+21 w120, % translate("Server URL")
		Gui SM:Add, Text, x155 yp w220 vserverURL

		Gui SM:Add, Text, x32 yp+24 w120, % translate("Session Token")
		Gui SM:Add, Text, x155 yp w220 vserverToken

		Gui SM:Add, Text, x32 yp+28 w120, % translate("Team")
		Gui SM:Add, Text, x155 yp w220 vserverTeam

		Gui SM:Add, Text, x32 yp+24 w120, % translate("Driver")
		Gui SM:Add, Text, x155 yp w220 vserverDriver

		Gui SM:Add, Text, x32 yp+24 w120, % translate("Session")
		Gui SM:Add, Text, x155 yp w220 vserverSession

		Gui Tab, 4

		Gui SM:Add, ListView, x24 ys+28 w756 h312 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDlogMessageListView gnoSelect, % values2String("|", map(["Application", "Time", "Category", "Message"], "translate")*)

		Gui SM:Add, Text, x24 yp+320 w95 h20, % translate("Log Buffer")
		Gui SM:Add, Edit, x120 yp-2 w50 h20 Limit3 Number VlogBufferEdit, 999
		Gui SM:Add, UpDown, x158 yp w18 h20 Range100-999, 999

		Gui Tab

		Gui SM:Font, s8 Norm, Arial

		Gui SM:Add, Text, x8 ys+385 w790 0x10

		Gui SM:Add, Button, x367 yp+10 w80 h23 Default GcloseSystemMonitor, % translate("Close")

		x := false
		y := false

		if getWindowPosition("System Monitor", x, y)
			Gui SM:Show, x%x% y%y%
		else
			Gui SM:Show

		new PeriodicTask(Func("systemMonitor").Bind("UpdateModuleState"), 2000, kLowPriority).start()
		new PeriodicTask(Func("systemMonitor").Bind("UpdateServerState"), 5000, kLowPriority).start()

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

noSelect() {
	loop % LV_GetCount()
		LV_Modify(A_Index, "-Select")
}

startSystemMonitor() {
	local icon := kIconsDirectory . "Monitoring.ico"
	local noLaunch

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, System Monitor

	registerMessageHandler("Monitor", "monitorMessageHandler")

	deleteFile(kUserConfigDirectory . "Simulator Controller.state")

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