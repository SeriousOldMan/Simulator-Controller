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
#Include ..\Assistants\Libraries\SessionDatabase.ahk


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

getTableCSS() {
	local script

	script =
	(
		.table-std, .th-std, .td-std {
			border-collapse: collapse;
			padding: .3em .5em;
		}

		.th-std, .td-std {
			text-align: center;
		}

		.th-std, .caption-std {
			background-color: #BBB;
			color: #000;
			border: thin solid #BBB;
		}

		.td-std {
			border-left: thin solid #BBB;
			border-right: thin solid #BBB;
		}

		.th-left {
			text-align: left;
		}

		tfoot {
			border-bottom: thin solid #BBB;
		}

		.caption-std {
			font-size: 1.5em;
			border-radius: .5em .5em 0 0;
			padding: .5em 0 0 0
		}

		.table-std tbody tr:nth-child(even) {
			background-color: #D8D8D8;
		}

		.table-std tbody tr:nth-child(odd) {
			background-color: #D0D0D0;
		}
	)

	return script
}

updateDashboard(viewer, html := "") {
	local tableCSS := getTableCSS()
	local script, ignore, chart

	if (html == false)
		html := ""

	script =
	(
		<meta charset='utf-8'>
		<head>
			<style>
				.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: 'FFFFFF'; }
				.rowStyle { font-size: 11px; background-color: 'E0E0E0'; }
				.oddRowStyle { font-size: 11px; background-color: 'E8E8E8'; }
				%tableCSS%
			</style>
		</head>
	)

	html := ("<html>" . script . "<body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 10px }</style><style> #header { font-size: 12px; } </style><div>" . html . "</div></body></html>")

	viewer.Document.Open()
	viewer.Document.Write(html)
	viewer.Document.Close()
}

global simulationDashboard
global assistantsDashboard
global sessionDashboard
global dataDashboard
global automationDashboard
global mapperDashboard

global simulationState
global assistantsState
global sessionState
global dataState
global automationState
global mapperState

systemMonitor(command := false, arguments*) {
	local x, y, time, logLevel, defaultGui, defaultListView
	local controllerState, databaseState, ignore, plugin, icons, modules, key, value, icon, state, property
	local drivers

	static monitorTabView

	static stateIconsList := false
	static stateIcons := {}
	static stateModules := false

	static serverState
	static serverURL := ""
	static serverToken := ""
	static serverDriver := ""
	static serverTeam := ""
	static serverSession := ""

	static driversListView

	static stintNr := ""
	static stintLap := ""
	static stintDriver := ""

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
	else if (command = "UpdateDashboard") {
		defaultGui := A_DefaultGui

		Gui SM:Default

		try {
			GuiControlGet monitorTabView

			if (monitorTabView = 1) {
				controllerState := getControllerState(false)
				databaseState := readConfiguration(kTempDirectory . "Database Synchronizer.state")

				updateSimulationState(controllerState)
				updateAssistantsState(controllerState)
				updateSessionState(controllerState)
				updateDataState(databaseState)
				updateAutomationState(controllerState)
				updateMapperState(controllerState)
			}
		}
		catch exception {
			logError(exception)
		}
		finally {
			Gui %defaultGui%:Default
		}

	}
	else if (command = "UpdateModules") {
		defaultGui := A_DefaultGui

		Gui SM:Default

		defaultListView := A_DefaultListView

		Gui ListView, % stateListView

		try {
			GuiControlGet monitorTabView

			if (monitorTabView = 2) {
				controllerState := getControllerState(false)
				databaseState := readConfiguration(kTempDirectory . "Database Synchronizer.state")

				icons := []
				modules := []
				messages := []

				for ignore, plugin in string2Values("|", getConfigurationValue(controllerState, "Modules", "Plugins")) {
					if plugin {
						state := getConfigurationValue(controllerState, plugin, "State")

						if stateIcons.HasKey(state)
							icons.Push(stateIcons[state])
						else
							icons.Push(stateIcons["Unknown"])

						modules.Push(translate(plugin))

						messages.Push(getConfigurationValue(controllerState, plugin, "Information", ""))
					}
				}

				if (databaseState.Count() > 0) {
					state := getConfigurationValue(databaseState, "Database Synchronizer", "State")

					if stateIcons.HasKey(state)
						icons.Push(stateIcons[state])
					else
						icons.Push(stateIcons["Unknown"])

					modules.Push(translate("Database Synchronizer"))

					messages.Push(getConfigurationValue(databaseState, "Database Synchronizer", "Information", ""))
				}

				if (!stateModules || !listEqual(modules, stateModules)) {
					LV_Delete()

					LV_SetImageList(stateIconsList)

					for ignore, plugin in modules
						LV_Add("Icon" . icons[A_Index], "    " . plugin, messages[A_Index])

					LV_ModifyCol()
					LV_ModifyCol(1, "AutoHdr")

					stateModules := modules
				}
				else
					for ignore, plugin in modules {
						LV_Modify(A_Index, "Icon" . icons[A_Index])
						LV_Modify(A_Index, "Col2", messages[A_Index])
					}

				LV_ModifyCol(2, "AutoHdr")
			}
		}
		catch exception {
			logError(exception)
		}
		finally {
			Gui %defaultGui%:Default
			Gui ListView, %defaultListView%
		}
	}
	else if (command = "UpdateServer") {
		serverURL := translate("Not connectced")
		serverToken := translate("Not connectced")
		serverDriver := translate("Not connectced")
		serverTeam := translate("Not connectced")
		serverSession := translate("Not connectced")

		stintNr := translate("Not started")
		stintLap := translate("Not started")
		stintDriver := translate("Not started")

		drivers := []

		defaultGui := A_DefaultGui

		Gui SM:Default

		defaultListView := A_DefaultListView

		Gui ListView, % driversListView

		try {
			GuiControlGet monitorTabView

			if (monitorTabView = 3) {
				controllerState := getControllerState(false)

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
								case "Drivers":
									drivers := string2Values("|", value)
								case "StintNr":
									stintNr := value
								case "StintLap":
									stintLap := value
								case "StintDriver":
									stintDriver := value
							}
						}
					}
				}

				GuiControl, , serverURL, %serverURL%
				GuiControl, , serverToken, %serverToken%
				GuiControl, , serverDriver, %serverDriver%
				GuiControl, , serverTeam, %serverTeam%
				GuiControl, , serverSession, %serverSession%
				GuiControl, , stintNr, %stintNr%
				GuiControl, , stintLap, %stintLap%
				GuiControl, , stintDriver, %stintDriver%

				LV_Delete()

				for ignore, driver in drivers
					LV_Add("", driver, (driver = stintDriver) ? translate("x") : "")

				LV_ModifyCol()
				LV_ModifyCol(1, "AutoHdr")
				LV_ModifyCol(2, "AutoHdr")
			}
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

		Gui SM:Add, Tab3, x16 yp+14 w773 h375 AltSubmit -Wrap Section vmonitorTabView, % values2String("|", map(["Dashboard", "Modules", "Server", "Logs"], "translate")*)

		Gui Tab, 1

		Gui SM:Font, s8 Norm, Arial

		Gui SM:Font, Italic, Arial
		Gui SM:Add, GroupBox, -Theme x24 ys+28 w375 h9, % translate("Simulation")
		Gui SM:Font, s8 Norm, Arial

		Gui SM:Add, Picture, x34 ys+73 w32 h32 vsimulationState, % kIconsDirectory . "Black.ico"
		Gui SM:Add, ActiveX, x134 ys+46 w260 h90 vsimulationDashboard, shell.explorer
		simulationDashboard.Navigate("about:blank")

		Gui SM:Font, Italic, Arial
		Gui SM:Add, GroupBox, -Theme x405 ys+28 w375 h9, % translate("Assistants")
		Gui SM:Font, s8 Norm, Arial

		Gui SM:Add, Picture, x415 ys+73 w32 h32 vassistantsState, % kIconsDirectory . "Black.ico"
		Gui SM:Add, ActiveX, x515 ys+46 w260 h90 vassistantsDashboard, shell.explorer
		assistantsDashboard.Navigate("about:blank")

		Gui SM:Font, Italic, Arial
		Gui SM:Add, GroupBox, -Theme x24 ys+138 w375 h9, % translate("Team")
		Gui SM:Font, s8 Norm, Arial

		Gui SM:Add, Picture, x34 ys+183 w32 h32 vsessionState, % kIconsDirectory . "Black.ico"
		Gui SM:Add, ActiveX, x134 ys+156 w260 h90 vsessionDashboard, shell.explorer
		sessionDashboard.Navigate("about:blank")

		Gui SM:Font, Italic, Arial
		Gui SM:Add, GroupBox, -Theme x405 ys+138 w375 h9, % translate("Data Synchronization")
		Gui SM:Font, s8 Norm, Arial

		Gui SM:Add, Picture, x415 ys+183 w32 h32 vdataState, % kIconsDirectory . "Black.ico"
		Gui SM:Add, ActiveX, x515 ys+156 w260 h90 vdataDashboard, shell.explorer
		dataDashboard.Navigate("about:blank")

		Gui SM:Font, Italic, Arial
		Gui SM:Add, GroupBox, -Theme x24 ys+248 w375 h9, % translate("Track Automation")
		Gui SM:Font, s8 Norm, Arial

		Gui SM:Add, Picture, x34 ys+293 w32 h32 vautomationState, % kIconsDirectory . "Black.ico"
		Gui SM:Add, ActiveX, x134 ys+266 w260 h90 vautomationDashboard, shell.explorer
		automationDashboard.Navigate("about:blank")

		Gui SM:Font, Italic, Arial
		Gui SM:Add, GroupBox, -Theme x405 ys+248 w375 h9, % translate("Track Mapping")
		Gui SM:Font, s8 Norm, Arial

		Gui SM:Add, Picture, x415 ys+293 w32 h32 vmapperState, % kIconsDirectory . "Black.ico"
		Gui SM:Add, ActiveX, x515 ys+266 w260 h90 vmapperDashboard, shell.explorer
		mapperDashboard.Navigate("about:blank")

		Gui Tab, 2

		Gui SM:Add, ListView, x24 ys+28 w756 h336 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDstateListView gnoSelect, % values2String("|", map(["Module", "Information"], "translate")*)

		Gui Tab, 3

		Gui SM:Font, s10 Bold, Arial

		; Gui SM:Add, Text, x24 ys+120 w120 h30, % translate("Connection")
		Gui SM:Add, Picture, x180 ys+95 w64 h64 vServerState, % kIconsDirectory . "Black.ico"

		Gui SM:Font, s8 Norm, Arial

		Gui SM:Font, Italic, Arial

		Gui SM:Add, GroupBox, -Theme x405 ys+60 w375 h150, % translate("Connection")

		Gui SM:Font, Norm, Arial

		Gui SM:Add, Text, x413 yp+21 w120, % translate("Server URL")
		Gui SM:Add, Text, x528 yp w230 vserverURL

		Gui SM:Add, Text, x413 yp+24 w120, % translate("Session Token")
		Gui SM:Add, Text, x528 yp w230 vserverToken

		Gui SM:Add, Text, x413 yp+28 w120, % translate("Team")
		Gui SM:Add, Text, x528 yp w230 vserverTeam

		Gui SM:Add, Text, x413 yp+24 w120, % translate("Driver")
		Gui SM:Add, Text, x528 yp w230 vserverDriver

		Gui SM:Add, Text, x413 yp+24 w120, % translate("Session")
		Gui SM:Add, Text, x528 yp w230 vserverSession

		Gui SM:Font, Italic, Arial

		Gui SM:Add, GroupBox, -Theme x24 ys+220 w375 h9, % translate("Drivers")

		Gui SM:Font, Norm, Arial

		Gui SM:Add, ListView, x24 yp+21 w375 h120 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDdriversListView gnoSelect, % values2String("|", map(["Driver", "Active"], "translate")*)

		Gui SM:Font, Italic, Arial

		Gui SM:Add, GroupBox, -Theme x405 ys+220 w375 h142, % translate("Stint")

		Gui SM:Font, Norm, Arial

		Gui SM:Add, Text, x413 yp+28 w120, % translate("Stint")
		Gui SM:Add, Text, x528 yp w230 vstintNr

		Gui SM:Add, Text, x413 yp+24 w120, % translate("Laps")
		Gui SM:Add, Text, x528 yp w230 vstintLap

		Gui SM:Add, Text, x413 yp+24 w120, % translate("Driver")
		Gui SM:Add, Text, x528 yp w230 vstintDriver

		Gui Tab, 4

		Gui SM:Font, s8 Norm, Arial

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

		updateDashboard(simulationDashboard)
		updateDashboard(assistantsDashboard)
		updateDashboard(sessionDashboard)
		updateDashboard(dataDashboard)
		updateDashboard(automationDashboard)
		updateDashboard(mapperDashboard)

		new PeriodicTask(Func("systemMonitor").Bind("UpdateDashboard"), 2000, kLowPriority).start()
		new PeriodicTask(Func("systemMonitor").Bind("UpdateModules"), 2000, kLowPriority).start()
		new PeriodicTask(Func("systemMonitor").Bind("UpdateServer"), 5000, kLowPriority).start()

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

updateSimulationState(controllerState) {
	local state := getConfigurationValue(controllerState, "Simulation", "State", "Disabled")
	local html, icon

	if kStateIcons.HasKey(state)
		icon := kStateIcons[state]
	else
		icon := kStateIcons["Unknown"]

	GuiControl, , simulationState, %icon%

	if (state = "Active") {
		html := "<table>"
		html .= ("<tr><td><b>" . translate("Simulator:") . "</b></td><td>" . getConfigurationValue(controllerState, "Simulation", "Simulator") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Car:") . "</b></td><td>" . getConfigurationValue(controllerState, "Simulation", "Car") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Track:") . "</b></td><td>" . getConfigurationValue(controllerState, "Simulation", "Track") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Session:") . "</b></td><td>" . translate(getConfigurationValue(controllerState, "Simulation", "Session")) . "</td></tr>")
		html .= "</table>"
	}
	else
		html := ""

	updateDashboard(simulationDashboard, html)
}

updateAssistantsState(controllerState) {
	local overallState := "Disabled"
	local html := "<table>"
	local assistant, state

	for assistant, state in getConfigurationSectionValues(controllerState, "Assistants", {}) {
		if (state = "Active") {
			overallState := "Active"

			state := translate("Active")
		}
		else if (state = "Wait") {
			if (overallState = "Disabled")
				overallState := "Passive"

			state := translate("Waiting...")
		}
		else
			state := translate("Inactive")

		html .= ("<tr><td><b>" . translate(assistant) . translate(": ") . "</b></td><td>" . state . "</td></tr>")
	}

	GuiControl, , assistantsState, % kStateIcons[overallState]

	if (overallState = "Disabled")
		html := ""
	else
		html .= "</table>"

	updateDashboard(assistantsDashboard, html)
}

updateSessionState(controllerState) {
	local state := getConfigurationValue(controllerState, "Team Server", "State", "Disabled")
	local html, icon, ignore, property, key, value

	if kStateIcons.HasKey(state)
		icon := kStateIcons[state]
	else
		icon := kStateIcons["Unknown"]

	GuiControl, , sessionState, %icon%

	if ((state != "Unknown") && (state != "Disabled")) {
		state := {}

		for ignore, property in string2Values(";", getConfigurationValue(controllerState, "Team Server", "Properties")) {
			property := StrSplit(property, ":", " `t", 2)

			state[property[1]] := property[2]
		}

		for key, value in state
			if (value = "Invalid")
				state[key] := translate("Not valid")
			else if (value = "Mismatch")
				state[key] := translate("No match")

		html := "<table>"
		html .= ("<tr><td><b>" . translate("Server:") . "</b></td><td>" . state["ServerURL"] . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Token:") . "</b></td><td>" . state["SessionToken"] . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Team:") . "</b></td><td>" . state["Team"] . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Driver:") . "</b></td><td>" . state["Driver"] . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Session:") . "</b></td><td>" . state["Session"] . "</td></tr>")
		html .= "</table>"
	}
	else
		html := ""

	updateDashboard(sessionDashboard, html)
}

updateDataState(databaseState) {
	local state := getConfigurationValue(databaseState, "Database Synchronizer", "State", "Disabled")
	local html, icon, serverURL, serverToken, action

	if kStateIcons.HasKey(state)
		icon := kStateIcons[state]
	else
		icon := kStateIcons["Unknown"]

	GuiControl, , dataState, %icon%

	if ((state != "Unknown") && (state != "Disabled")) {
		if !getConfigurationValue(databaseState, "Database Synchronizer", "Connected", true) {
			serverURL := translate("Not valid")
			serverToken := translate("Not valid")
		}
		else {
			serverURL := getConfigurationValue(databaseState, "Database Synchronizer", "ServerURL")
			serverToken := getConfigurationValue(databaseState, "Database Synchronizer", "ServerToken")
		}

		action := getConfigurationValue(databaseState, "Database Synchronizer", "Synchronization", false)

		html := "<table>"
		html .= ("<tr><td><b>" . translate("Server:") . "</b></td><td>" . serverURL . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Token:") . "</b></td><td>" . serverToken . "</td></tr>")
		html .= ("<tr><td><b>" . translate("User:") . "</b></td><td>"
							   . getConfigurationValue(databaseState, "Database Synchronizer", "UserID") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Database:") . "</b></td><td>"
							   . getConfigurationValue(databaseState, "Database Synchronizer", "DatabaseID") . "</td></tr>")

		if action {
			switch action {
				case "Running":
					action := "Synchronizing database..."
				case "Finished":
					action := "Finished synchronization..."
				case "Waiting":
					action := "Waiting for next synchronization..."
				case "Failed":
					action := "Synchronization failed..."
				default:
					throw "Unknown action detected in updateDataState..."
			}

			html .= ("<tr><td><b>" . translate("Action:") . "</b></td><td>" . translate(action) . "</td></tr>")
		}

		html .= "</table>"
	}
	else
		html := ""

	updateDashboard(dataDashboard, html)
}

updateAutomationState(controllerState) {
}

updateMapperState(controllerState) {
}

startSystemMonitor() {
	local icon := kIconsDirectory . "Monitoring.ico"
	local noLaunch

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, System Monitor

	fixIE(11)

	registerMessageHandler("Monitor", "monitorMessageHandler")

	new SessionDatabase() ; so that file Simulator Controller.state can be deleted...

	deleteFile(kTempDirectory . "Simulator Controller.state")
	deleteFile(kTempDirectory . "Database Synchronizer.state")

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