﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - System Monitor                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

;@SC-IF %configuration% == Development
;@SC-IF %configuration% == Development
#Include "..\Framework\Development.ahk"
;@SC-EndIF

;@SC-If %configuration% == Production
;@SC #Include "..\Framework\Production.ahk"
;@SC-EndIf

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Monitoring.ico
;@Ahk2Exe-ExeName System Monitor.exe
;@Ahk2Exe-SetCompanyName Oliver Juwig (TheBigO)
;@Ahk2Exe-SetCopyright TheBigO - Creative Commons - BY-NC-SA
;@Ahk2Exe-SetProductName Simulator Controller
;@Ahk2Exe-SetVersion 0.0.0.0


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\HTMLViewer.ahk"
#Include "..\Framework\Extensions\Task.ahk"
#Include "..\Framework\Extensions\Messages.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Plugins\Libraries\SimulatorProvider.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kOk := "Ok"
global kCancel := "Cancel"
global kClose := "Close"

global kStateFiles := concatenate(["Simulator Controller", "Database Synchronizer", "Track Mapper"]
								, kRaceAssistants, collect(kRaceAssistants, (a) => (a . " Session")))

global kStateIcons := CaseInsenseMap("Disabled", kIconsDirectory . "Black.ico"
								   , "Passive", kIconsDirectory . "Gray.ico"
								   , "Active", kIconsDirectory . "Green.ico"
								   , "Warning", kIconsDirectory . "Yellow.ico"
								   , "Critical", kIconsDirectory . "Red.ico"
								   , "Unknown", kIconsDirectory . "Black.ico")


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global gStartupFinished := false


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SystemMonitorResizer extends Window.Resizer {
	iViewer := []
	iRedraw := false

	__New(window, viewer*) {
		this.iViewer := viewer

		super.__New(window)

		Task.startTask(ObjBindMethod(this, "RedrawHTMLViewer"), 500, kHighPriority)
	}

	Redraw() {
		this.iRedraw := true
	}

	RedrawHTMLViewer() {
		if this.iRedraw {
			local ignore, button

			for ignore, button in ["LButton", "MButton", "RButton"]
				if GetKeyState(button)
					return Task.CurrentTask

			this.iRedraw := false

			for ignore, viewer in this.iViewer
				viewer.Resized()
		}

		return Task.CurrentTask
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateDashboard(window, viewer, html := "") {
	local script, ignore, chart

	if (html == false)
		html := " "

	html := ("<html><meta charset='utf-8'><body style='background-color: #" . window.BackColor . "; overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> p, div, table { color: #" . window.Theme.TextColor . "; font-family: Arial, Helvetica, sans-serif; font-size: 10px }</style><style> #header { font-size: 12px; } </style><div>" . html . "</div></body></html>")

	viewer.document.open()
	viewer.document.write(html)
	viewer.document.close()

	Sleep(100)
}

getTableCSS(window, textSize) {
	local script

	script := "
	(
		.table-std, .th-std, .td-std {
			border-collapse: collapse;
			padding: .3em .5em;
			font-size: %textSize%px;
			color: #%fontColor%
		}

		.th-std, .td-std {
			text-align: center;
		}

		.th-std, .caption-std {
			background-color: #%headerBackColor%;
			color: #%textColor%;
			border: thin solid #%frameColor%;
		}

		.th-std {
			vertical-align: top;
		}

		.td-std {
			border-left: thin solid #%frameColor%;
			border-right: thin solid #%frameColor%;
			margin-left: 5px;
		}

		.td-wdg {
			border-left: thin solid #%frameColor%;
			border-right: thin solid #%frameColor%;
			padding-left: 5px;
			padding-right: 5px;
		}

		.th-left {
			text-align: left;
		}

		.td-left {
			text-align: left;
		}

		.th-right {
			text-align: right;
		}

		.td-right {
			text-align: right;
		}

		tfoot {
			border-bottom: thin solid #%frameColor%;
		}

		.caption-std {
			border-radius: .5em .5em 0 0;
			padding: .5em 0 0 0
		}

		.table-std tbody tr:nth-child(even) {
			background-color: #%evenRowColor%;
		}

		.table-std tbody tr:nth-child(odd) {
			background-color: #%evenRowColor%;
		}

		#header {
			font-size: %textSize%px;
		}
	)"

	return substituteVariables(script, {fontColor: window.Theme.TextColor
									  , evenRowColor: window.Theme.ListBackColor["EvenRow"]
									  , oddRowColor: window.Theme.ListBackColor["OddRow"]
									  , altBackColor: window.AltBackColor, backColor: window.BackColor
									  , textColor: window.Theme.TextColor, textSize: textSize
									  , headerBackColor: window.Theme.TableColor["Header"], frameColor: window.Theme.TableColor["Frame"]})
}

editSettings(settingsOrCommand, arguments*) {
	local settingsGui, x, y, row, column, value

	static infoWidgets := []
	static result := false
	static settings := false
	static widgets := []
	static cycle := 5
	static size := 11

	getChoice(descriptor) {
		if !descriptor
			return 1
		else if (descriptor = "Cycle")
			return 2
		else {
			index := inList(infoWidgets, descriptor)

			return (index ? (index + 3) : 1)
		}
	}

	updateWidget(dropDown, *) {
		if (dropDown.Value = 3)
			dropDown.Value := 1
	}

	if (settingsOrCommand == kOk)
		result := kOk
	else if (settingsOrCommand == kCancel)
		result := kCancel
	else {
		infoWidgets := getKeys(arguments[1])
		settings := settingsOrCommand
		widgets := string2Values(",", getMultiMapValue(settings, "System Monitor", "Session Widgets", "Session,Stint,Duration,Conditions,Cycle,Cycle"))
		cycle := getMultiMapValue(settings, "System Monitor", "Session Cycle", 30)
		size := getMultiMapValue(settings, "System Monitor", "Session Size", 11)

		while (widgets.Length < 9)
			widgets.Push(false)

		result := false

		settingsGui := Window({Descriptor: "System Monitor.Settings", Options: "0x400000"}, translate("Settings"))

		settingsGui.SetFont("s10 Bold", "Arial")

		settingsGui.Add("Text", "w438 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(settingsGui, "System Monitor.Settings"))

		settingsGui.SetFont("s9 Norm", "Arial")

		settingsGui.Add("Documentation", "x148 YP+20 w164 H:Center Center", translate("Session Information")
					  , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities")

		settingsGui.SetFont("s8 Norm", "Arial")

		settingsGui.Add("Text", "x8 yp+30 w428 W:Grow 0x10")

		settingsGui.Add("Text", "x16 yp+16 w100", translate("Update each"))
		settingsGui.Add("DropDownList", "x120 yp-4 w100 vcycleDropDown Choose" . inList([5, 10, 15, 30], cycle), collect(["5 seconds", "10 seconds", "15 seconds", "30 seconds"], translate))

		settingsGui.Add("Text", "x16 yp+30 w100", translate("Components"))

		settingsGui.Add("DropDownList", "x120 yp-4 w100 vwidget11 Choose" . getChoice(widgets[1]), concatenate([translate("Empty"), translate("Cycle"), translate("------------------------")], collect(infoWidgets, translate))).OnEvent("Change", updateWidget)
		settingsGui.Add("DropDownList", "x224 yp w100 vwidget12 Choose" . getChoice(widgets[2]), concatenate([translate("Empty"), translate("Cycle"), translate("------------------------")], collect(infoWidgets, translate))).OnEvent("Change", updateWidget)
		settingsGui.Add("DropDownList", "x328 yp w100 vwidget13 Choose" . getChoice(widgets[3]), concatenate([translate("Empty"), translate("Cycle"), translate("------------------------")], collect(infoWidgets, translate))).OnEvent("Change", updateWidget)

		settingsGui.Add("DropDownList", "x120 yp+24 w100 vwidget21 Choose" . getChoice(widgets[4]), concatenate([translate("Empty"), translate("Cycle"), translate("------------------------")], collect(infoWidgets, translate))).OnEvent("Change", updateWidget)
		settingsGui.Add("DropDownList", "x224 yp w100 vwidget22 Choose" . getChoice(widgets[5]), concatenate([translate("Empty"), translate("Cycle"), translate("------------------------")], collect(infoWidgets, translate))).OnEvent("Change", updateWidget)
		settingsGui.Add("DropDownList", "x328 yp w100 vwidget23 Choose" . getChoice(widgets[6]), concatenate([translate("Empty"), translate("Cycle"), translate("------------------------")], collect(infoWidgets, translate))).OnEvent("Change", updateWidget)

		settingsGui.Add("DropDownList", "x120 yp+24 w100 vwidget31 Choose" . getChoice(widgets[7]), concatenate([translate("Empty"), translate("Cycle"), translate("------------------------")], collect(infoWidgets, translate))).OnEvent("Change", updateWidget)
		settingsGui.Add("DropDownList", "x224 yp w100 vwidget32 Choose" . getChoice(widgets[8]), concatenate([translate("Empty"), translate("Cycle"), translate("------------------------")], collect(infoWidgets, translate))).OnEvent("Change", updateWidget)
		settingsGui.Add("DropDownList", "x328 yp w100 vwidget33 Choose" . getChoice(widgets[9]), concatenate([translate("Empty"), translate("Cycle"), translate("------------------------")], collect(infoWidgets, translate))).OnEvent("Change", updateWidget)

		settingsGui.Add("Text", "x16 yp+30 w100", translate("Size"))
		settingsGui.Add("DropDownList", "x120 yp-4 w50 vsizeDropDown Choose" . inList([9, 10, 11, 12, 14, 16, 18, 20, 24, 28], size), [9, 10, 11, 12, 14, 16, 18, 20, 24, 28])

		settingsGui.Add("Text", "x8 yp+30 w428 W:Grow 0x10")

		settingsGui.Add("Button", "x142 yp+10 w80 h23 Default", translate("Ok")).OnEvent("Click", editSettings.Bind(kOk))
		settingsGui.Add("Button", "x228 yp w80 h23", translate("&Cancel")).OnEvent("Click", editSettings.Bind(kCancel))

		settingsGui.Opt("+Owner" . arguments[2].Hwnd)

		if getWindowPosition("System Monitor.Settings", &x, &y)
			settingsGui.Show("x" . x . " y" . y)
		else
			settingsGui.Show("AutoSize Center")

		while !result
			Sleep(100)

		try {
			if (result == kCancel)
				return false
			else if (result == kOk) {
				setMultiMapValue(settings, "System Monitor", "Session Cycle", [5, 10, 15, 30][settingsGui["cycleDropDown"].Value])
				setMultiMapValue(settings, "System Monitor", "Session Size", settingsGui["sizeDropDown"].Text)

				loop 3 {
					row := A_Index

					loop 3 {
						column := A_Index

						value := settingsGui["widget" . row . column].Value

						widgets[((row - 1) * 3) + column] := ((value = 1) ? false : ((value = 2) ? "Cycle" : infoWidgets[value - 3]))
					}
				}

				setMultiMapValue(settings, "System Monitor", "Session Widgets", values2String(",", widgets*))

				return true
			}
		}
		finally {
			settingsGui.Destroy()
		}
	}
}

systemMonitor(command := false, arguments*) {
	global gStartupFinished

	local x, y, w, h, time, logLevel
	local controllerState, databaseState, trackMapperState, sessionInfo, ignore, assistant, plugin, icons, modules, key, value
	local icon, state, property, drivers, choices, chosen, settings, plugins, states, maxLap

	local serverURLValue, serverTokenValue, serverDriverValue, serverTeamValue, serverSessionValue
	local stintNrValue, stintLapValue, stintDriverValue

	static systemMonitorGui
	static monitorTabView

	static settingsButton

	static stateIconsList := false
	static stateIcons := false
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

	static simulationDashboard
	static assistantsDashboard
	static sessionDashboard
	static dataDashboard
	static automationDashboard
	static mapperDashboard

	static simulationState
	static assistantsState
	static sessionState
	static dataState
	static automationState
	static mapperState

	static sessionStateViewer

	static logLevelDropDown

	static provider := false

	static infoWidgets := CaseInsenseMap("Session", createSessionWidget,
										 "Duration", createDurationWidget,
										 "Conditions", createConditionsWidget,
										 "Stint", createStintWidget,
										 "Fuel", createFuelWidget,
										 "Tyres", createTyresWidget,
										 "Brakes", createBrakesWidget,
										 "Engine", createEngineWidget,
										 "Damage", createDamageWidget,
										 "Pitstop", createPitstopWidget,
										 "Strategy", createStrategyWidget,
										 "Standings", createStandingsWidget)

	static sessionInfoWidgets := []
	static sessionInfoSleep := 30000
	static sessionInfoSize := 11
	static nextSessionUpdate := A_TickCount

	nonZero(value) {
		return ((value != 0) && (value != "-"))
	}

	modifySettings(systemMonitorGui, *) {
		local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		systemMonitorGui.Block()

		try {
			if editSettings(settings, infoWidgets, systemMonitorGui) {
				sessionInfoWidgets := string2Values(",", getMultiMapValue(settings, "System Monitor", "Session Widgets", "Session,Stint,Duration,Conditions,Cycle,Cycle"))
				sessionInfoSleep := (getMultiMapValue(settings, "System Monitor", "Session Cycle", 30) * 1000)
				sessionInfoSize := getMultiMapValue(settings, "System Monitor", "Session Size", 11)

				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				setMultiMapValue(settings, "System Monitor", "Session Widgets", values2String(",", sessionInfoWidgets*))
				setMultiMapValue(settings, "System Monitor", "Session Cycle", Round(sessionInfoSleep / 1000))
				setMultiMapValue(settings, "System Monitor", "Session Size", sessionInfoSize)

				writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

				nextSessionUpdate := A_TickCount
			}
		}
		finally {
			systemMonitorGui.Unblock()
		}
	}

	createSessionWidget(sessionState) {
		local html := ""

		html .= "<table class=`"table-std`">"
		html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Session") . "</i></div></th></tr>")
		html .= ("<tr><th class=`"th-std th-left`">" . translate("Simulator") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Session", "Simulator") . "</td></tr>")
		html .= ("<tr><th class=`"th-std th-left`">" . translate("Car") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Session", "Car") . "</td></tr>")
		html .= ("<tr><th class=`"th-std th-left`">" . translate("Track") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Session", "Track") . "</td></tr>")
		html .= ("<tr><th class=`"th-std th-left`">" . translate("Session") . "</th><td class=`"td-wdg`">" . translate(getMultiMapValue(sessionState, "Session", "Type")) . "</td></tr>")

		if (getMultiMapValue(sessionState, "Session", "Profile", kUndefined) != kUndefined)
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Profile") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Session", "Profile") . "</td></tr>")
		else
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Profile") . "</th><td class=`"td-wdg`">" . translate("Standard") . "</td></tr>")

		html .= "</table>"

		return html
	}

	createDurationWidget(sessionState) {
		local driveTime := getMultiMapValue(sessionState, "Stint", "DriveTime", false)
		local sessionTime := getMultiMapValue(sessionState, "Session", "Time.Remaining", kUndefined)
		local stintTime := getMultiMapValue(sessionState, "Stint", "Time.Remaining.Stint", kUndefined)
		local driverTime := getMultiMapValue(sessionState, "Stint", "Time.Remaining.Driver", kUndefined)
		local sessionLaps := getMultiMapValue(sessionState, "Session", "Laps.Remaining", 0)
		local stintLaps := getMultiMapValue(sessionState, "Stint", "Laps.Remaining.Stint", 0)
		local lastValid := getMultiMapValue(sessionState, "Stint", "Valid", true)
		local lastTime := getMultiMapValue(sessionState, "Stint", "Lap.Time.Last", kUndefined)
		local html := ""
		local remainingStintTime, remainingSessionTime, remainingDriverTime

		try {
			if isNumber(sessionTime)
				remainingSessionTime := displayValue("Time", sessionTime)
			else
				remainingSessionTime := "-"

			if (isNumber(stintTime) && isNumber(lastTime))
				remainingStintTime := ((((stintTime / lastTime) < 4) ? "<font color=`"red`">" : "") . displayValue("Time", stintTime) . (((stintTime / lastTime) < 4) ? "</font>" : ""))
			else
				remainingStintTime := "-"

			if (isNumber(driverTime) && isNumber(lastTime))
				remainingDriverTime := ((((driverTime / lastTime) < 4) ? "<font color=`"red`">" : "") . displayValue("Time", driverTime) . (((driverTime / lastTime) < 4) ? "</font>" : ""))
			else
				remainingDriverTime := "-"

			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Duration") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Format") . "</th><td class=`"td-wdg`">" . translate(getMultiMapValue(sessionState, "Session", "Format")) . "</td></tr>")

			if (sessionTime != stintTime) {
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Time Left (Session)") . "</th><td class=`"td-wdg`">" . remainingSessionTime . "</td></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Time Left (Stint)") . "</th><td class=`"td-wdg`">" . remainingStintTime . "</td></tr>")
				if (driverTime != stintTime)
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Time Left (Driver)") . "</th><td class=`"td-wdg`">" . remainingDriverTime . "</td></tr>")
			}
			else
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Time Left") . "</th><td class=`"td-wdg`">" . remainingSessionTime . "</td></tr>")

			if driveTime
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Drive Time") . "</th><td class=`"td-wdg`">" . displayValue("Time", driveTime) . "</td></tr>")

			if (sessionLaps != stintLaps) {
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Laps Left (Session)") . "</th><td class=`"td-wdg`">" . sessionLaps . "</td></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Laps Left (Stint)") . "</th><td class=`"td-wdg`">" . ((isNumber(stintLaps) && (stintLaps < 4)) ? "<font color=`"red`">" : "") . stintLaps . ((isNumber(stintLaps) && (stintLaps < 4)) ? "</font>" : "") . "</td></tr>")
			}
			else
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Laps Left") . "</th><td class=`"td-wdg`">" . sessionLaps . "</td></tr>")
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createConditionsWidget(sessionState) {
		local weatherNow := getMultiMapValue(sessionState, "Weather", "Now")
		local weather10Min := getMultiMapValue(sessionState, "Weather", "10Min")
		local weather30Min := getMultiMapValue(sessionState, "Weather", "30Min")
		local html := ""

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Conditions") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Weather") . "</th><td class=`"td-wdg`">" . translate(weatherNow) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Temperature (Air)") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Temperature", getMultiMapValue(sessionState, "Weather", "Temperature"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Temperature (Track)") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Temperature", getMultiMapValue(sessionState, "Track", "Temperature"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Grip") . "</th><td class=`"td-wdg`">" . translate(getMultiMapValue(sessionState, "Track", "Grip")) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Outlook (10 minutes)") . "</th><td class=`"td-wdg`">" . ((weather10Min != weatherNow) ? "<font color=`"red`">" : "") . translate(weather10Min) . ((weather10Min != weatherNow) ? "</font>" : "") . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Outlook (30 minutes)") . "</th><td class=`"td-wdg`">" . ((weather30Min != weatherNow) ? "<font color=`"red`">" : "") . translate(weather30Min) . ((weather30Min != weatherNow) ? "</font>" : "") . "</td></tr>")
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createStintWidget(sessionState) {
		local lastLap := getMultiMapValue(sessionState, "Session", "Laps", 0)
		local lastValid := getMultiMapValue(sessionState, "Stint", "Valid", true)
		local lastTime := getMultiMapValue(sessionState, "Stint", "Lap.Time.Last")
		local bestTime := getMultiMapValue(sessionState, "Stint", "Lap.Time.Best")
		local lastSpeed := getMultiMapValue(sessionState, "Stint", "Speed.Last", false)
		local bestSpeed := getMultiMapValue(sessionState, "Stint", "Speed.Best", false)
		local html := ""

		try {
			lastTime := ((lastTime < 3600) ? displayValue("Time", lastTime) : "-")
			bestTime := ((bestTime < 3600) ? displayValue("Time", bestTime) : "-")

			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Stint") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Driver") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Stint", "Driver") . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Lap") . "</th><td class=`"td-wdg`">" . (lastLap + 1) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Position") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Stint", "Position") . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Lap Time (Last / Best)") . "</th><td class=`"td-wdg`">" . (!lastValid ? "<font color=`"red`">" : "") . lastTime . (!lastValid ? "</font>" : "") . translate(" / ") . bestTime . "</td></tr>")

			if (lastSpeed && bestSpeed)
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Top Speed (Last / Best)") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Speed", lastSpeed)) . translate(" / ") . displayValue("Float", convertUnit("Speed", bestSpeed)) . "</td></tr>")

			if (lastLap != getMultiMapValue(sessionState, "Stint", "Laps"))
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Laps (Stint)") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Stint", "Laps") . "</td></tr>")
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createFuelWidget(sessionState) {
		local fuelLow := (Floor(getMultiMapValue(sessionState, "Stint", "Laps.Remaining.Fuel", 0)) < 4)
		local energyLow := false
		local html := ""
		local lastTime, remainingLaps

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Fuel") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Consumption (Lap)") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Stint", "Fuel.Consumption")), 1) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Consumption (Avg.)") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Stint", "Fuel.AvgConsumption")), 1) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Remaining Fuel") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Stint", "Fuel.Remaining")), 1) . "</td></tr>")



			if (getMultiMapValue(sessionState, "Stint", "Laps.Remaining.Energy", kUndefined) != kUndefined) {
				energyLow := (Floor(getMultiMapValue(sessionState, "Stint", "Laps.Remaining.Energy", 0)) < 4)

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Energy (Lap)") . "</th><td class=`"td-wdg`">" . displayValue("Float", getMultiMapValue(sessionState, "Stint", "Energy.Consumption"), 1) . "</td></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Energy (Avg.)") . "</th><td class=`"td-wdg`">" . displayValue("Float", getMultiMapValue(sessionState, "Stint", "Energy.AvgConsumption"), 1) . "</td></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Remaining Energy") . "</th><td class=`"td-wdg`">" . displayValue("Float", getMultiMapValue(sessionState, "Stint", "Energy.Remaining"), 1) . "</td></tr>")

			}

			remainingLaps := Min(Floor(getMultiMapValue(sessionState, "Stint", "Laps.Remaining.Fuel")), Floor(getMultiMapValue(sessionState, "Stint", "Laps.Remaining.Energy", 99999)))

			html .= ("<tr><th class=`"th-std th-left`">" . translate("Laps Left") . "</th><td class=`"td-wdg`">" . ((fuelLow || energyLow) ? "<font color=`"red`">" : "") . remainingLaps . ((fuelLow || energyLow) ? "</font>" : "") . "</td></tr>")

			lastTime := getMultiMapValue(sessionState, "Stint", "Lap.Time.Last", kUndefined)

			if (lastTime != kUndefined)
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Time Left") . "</th><td class=`"td-wdg`">" . ((fuelLow || energyLow) ? "<font color=`"red`">" : "") . displayValue("Time", Floor(lastTime * remainingLaps)) . ((fuelLow || energyLow) ? "</font>" : "") . "</td></tr>")
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createTyresWidget(sessionState) {
		local html := ""
		local mixedCompounds := false
		local tyreSet := false
		local pressures, temperatures, wear, tyreCompounds

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"3`"><div id=`"header`"><i>" . translate("Tyres") . "</i></div></th></tr>")

			if provider
				provider.supportsTyreManagement(&mixedCompounds, &tyreSet)

			if (mixedCompounds = "Wheel") {
				tyreCompounds := [translate(getMultiMapValue(sessionState, "Tyres", "CompoundFrontLeft"))
								, translate(getMultiMapValue(sessionState, "Tyres", "CompoundFrontRight"))
								, translate(getMultiMapValue(sessionState, "Tyres", "CompoundRearLeft"))
								, translate(getMultiMapValue(sessionState, "Tyres", "CompoundRearRight"))]

				if (removeDuplicates(tyreCompounds).Length > 1) {
					html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Compound") . "</th><td class=`"td-wdg`" style=`"text-align: center`">" . tyreCompounds[1] . "</td><td class=`"td-wdg`" style=`"text-align: center`">" . tyreCompounds[2] . "</td></tr>")
					html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">" . tyreCompounds[3] . "</td><td class=`"td-wdg`" style=`"text-align: center`">" . tyreCompounds[4] . "</td></tr>")
				}
				else
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Compound") . "</th><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . tyreCompounds[1] . "</td></tr>")
			}
			else if (mixedCompounds = "Axle") {
				tyreCompounds := [translate(getMultiMapValue(sessionState, "Tyres", "CompoundFront"))
								, translate(getMultiMapValue(sessionState, "Tyres", "CompoundRear"))]

				if (tyreCompounds[1] != tyreCompounds[2]) {
					html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Compound") . "</th><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . tyreCompounds[1] . "</td></tr>")
					html .= ("<tr><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . tyreCompounds[2] . "</td></tr>")
				}
				else
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Compound") . "</th><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . tyreCompounds[1] . "</td></tr>")
			}
			else
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Compound") . "</th><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . translate(getMultiMapValue(sessionState, "Tyres", "Compound")) . "</td></tr>")

			if tyreSet {
				tyreSet := getMultiMapValue(sessionState, "Tyres", "Set", false)

				if tyreSet
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyre Set") . "</th><td class=`"td-wdg`" style=`"text-align: center`" colspan=`"2`">" . tyreSet . "</td></tr>")
			}

			pressures := string2Values(",", getMultiMapValue(sessionState, "Tyres", "Pressures.Hot", ""))

			if (pressures.Length = 4) {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Pressures (hot)") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[1])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[2])) . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[3])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[4])) . "</td></tr>")
			}
			else {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Pressures (hot)") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td></tr>")
			}

			pressures := string2Values(",", getMultiMapValue(sessionState, "Tyres", "Pressures.Cold", ""))

			if ((pressures.Length = 4) && (pressures[1] != 0)) {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Pressures (cold)") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[1])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[2])) . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[3])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[4])) . "</td></tr>")
			}

			pressures := string2Values(",", getMultiMapValue(sessionState, "Tyres", "Pressures.Loss", ""))

			if ((pressures.Length = 4) && exist(pressures, nonZero)) {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Pressures (loss)") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[1])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[2])) . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[3])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[4])) . "</td></tr>")
			}

			temperatures := string2Values(",", getMultiMapValue(sessionState, "Tyres", "Temperatures", ""))

			if (temperatures.Length = 4) {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Temperatures") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[1])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[2])) . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[3])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[4])) . "</td></tr>")
			}

			wear := string2Values(",", getMultiMapValue(sessionState, "Tyres", "Wear", ""))

			if ((wear.Length = 4) && exist(wear, nonZero)) {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Wear") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", wear[1]) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", wear[2]) . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", wear[3]) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", wear[4]) . "</td></tr>")
			}
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createBrakesWidget(sessionState) {
		local html := ""
		local temperatures, wear

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"3`"><div id=`"header`"><i>" . translate("Brakes") . "</i></div></th></tr>")

			temperatures := string2Values(",", getMultiMapValue(sessionState, "Brakes", "Temperatures", ""))

			if (temperatures.Length = 4) {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Temperatures") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[1])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[2])) . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[3])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[4])) . "</td></tr>")
			}
			else {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Temperatures") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td></tr>")
			}

			wear := string2Values(",", getMultiMapValue(sessionState, "Brakes", "Wear", ""))

			if ((wear.Length = 4) && exist(wear, nonZero)) {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Wear") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", Round(wear[1], 2)) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", Round(wear[2], 2)) . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", Round(wear[3], 2)) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", Round(wear[4], 2)) . "</td></tr>")
			}
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createEngineWidget(sessionState) {
		local html := ""
		local hasTemperatures := false
		local temperature

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Engine") . "</i></div></th></tr>")

			temperature := getMultiMapValue(sessionState, "Engine", "WaterTemperature", kUndefined)

			if (temperature != kUndefined) {
				hasTemperatures := true

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Temperature (Water)") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", temperature)) . "</td></tr>")
			}

			temperature := getMultiMapValue(sessionState, "Engine", "OilTemperature", kUndefined)

			if (temperature != kUndefined) {
				hasTemperatures := true

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Temperature (Oil)") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", temperature)) . "</td></tr>")
			}
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return (hasTemperatures ? html : "")
	}

	createStrategyWidget(sessionState) {
		local pitstopsCount := getMultiMapValue(sessionState, "Strategy", "Pitstops", kUndefined)
		local html := ""
		local remainingPitstops := 0
		local fuelService := false
		local tyreService := false
		local nextPitstop, tyreCompound, position, index, tyre, axle

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"3`"><div id=`"header`"><i>" . translate("Strategy") . "</i></div></th></tr>")

			if provider
				provider.supportsPitstop(&fuelService, &tyreService)

			if (pitstopsCount != kUndefined) {
				nextPitstop := getMultiMapValue(sessionState, "Strategy", "Pitstop.Next", 0)

				if (nextPitstop && pitstopsCount)
					remainingPitstops := (pitstopsCount - nextPitstop + 1)

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Pitstops (Planned)") . "</th><td class=`"td-wdg`" colspan=`"2`">" . pitstopsCount . "</td></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Pitstops (Remaining)") . "</th><td class=`"td-wdg`" colspan=`"2`">" . remainingPitstops . "</td></tr>")

				if nextPitstop {
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Next Pitstop (Lap)") . "</th><td class=`"td-wdg`" colspan=`"2`">" . getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Lap") . "</td></tr>")

					if fuelService
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Fuel") . "</th><td class=`"td-wdg`" colspan=`"2`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Refuel"))) . "</td></tr>")

					if (tyreService = "Wheel") {
						for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
							if ((index = 1) || (index = 3))
								html .= "<tr>"

							if (index = 1)
								html .= "<th class=`"th-std th-left`" rowspan=`"2`">" . translate("Tyres") . "</th>"

							tyreCompound := getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Tyre.Compound." . tyre)

							if (tyreCompound && (tyreCompound != "-"))
								tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Tyre.Compound.Color." . tyre)))
							else
								tyreCompound := translate("No")

							html .= ("<td class=`"td-wdg`" style=`"text-align: center`">" . tyreCompound . "</td>")

							if ((index = 2) || (index = 4))
								html .= "</tr>"
						}
					}
					else if (tyreService = "Axle") {
						for index, axle in ["Front", "Rear"] {
							html .= "<tr>"

							if (index = 1)
								html .= "<th class=`"th-std th-left`" rowspan=`"2`">" . translate("Tyres") . "</th>"

							tyreCompound := getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Tyre.Compound." . axle)

							if (tyreCompound && (tyreCompound != "-"))
								tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Tyre.Compound.Color." . axle)))
							else
								tyreCompound := translate("No")

							html .= ("<td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . tyreCompound . "</td>")

							html .= "</tr>"
						}
					}
					else if tyreService {
						tyreCompound := getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Tyre.Compound")

						if (tyreCompound && (tyreCompound != "-"))
							tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Tyre.Compound.Color")))
						else
							tyreCompound := translate("No")

						html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . tyreCompound . "</td></tr>")
					}

					position := getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Position", false)

					if position
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Position") . "</th><td class=`"td-wdg`" colspan=`"2`">" . position . "</td></tr>")
				}
			}
			else
				html .= ("<tr><td class=`"td-wdg`" colspan=`"3`">" . translate("No active strategy") . "</td></tr>")
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createDamageWidget(sessionState) {
		local html := "<table class=`"table-std`">"
		local bodyworkDamage := []
		local suspensionDamage := []
		local engineDamage := getMultiMapValue(sessionState, "Damage", "Engine", 0)
		local bodyworkDamageAll, bodyWorkDamageSum, suspensionDamageSum, ignore, index, position, header

		static projection := Map("FL", translate("Front Left"), "FR", translate("Front Right"), "RL", translate("Rear Left"), "RR", translate("Rear Right"))

		for ignore, position in ["Front", "Rear", "Left", "Right"]
			bodyworkDamage.Push(getMultiMapValue(sessionState, "Damage", "Bodywork." . position, 0))

		if isDebug()
			while (bodyworkDamage.Length < 5)
				bodyworkDamage.Push(0)

		bodyworkDamageAll := getMultiMapValue(sessionState, "Damage", "Bodywork.All", 0)

		for ignore, position in ["FL", "FR", "RL", "RR"]
			suspensionDamage.Push(getMultiMapValue(sessionState, "Damage", "Suspension." . position, 0))

		if isDebug() {
			while (bodyworkDamage.Length < 5)
				bodyworkDamage.Push(0)

			while (suspensionDamage.Length < 4)
				suspensionDamage.Push(0)
		}

		html .= ("<tr><th class=`"th-std th-left`" colspan=`"3`"><div id=`"header`"><i>" . translate("Damage") . "</i></div></th></tr>")

		bodyworkDamageSum := sum(bodyworkDamage)
		suspensionDamageSum := sum(suspensionDamage)

		if isDebug() {
			if (bodyworkDamageSum = 0)
				bodyworkDamageSum := 0.0000001

			if (suspensionDamageSum = 0)
				suspensionDamageSum := 0.0000001
		}

		if (!isDebug() && ((bodyWorkDamageSum + bodyworkDamageAll + suspensionDamageSum + engineDamage) = 0))
			html .= ("<tr><td class=`"td-wdg`" colspan=`"3`">" . translate("No damage") . "</td></tr>")
		else {
			if ((bodyWorkDamageSum = 0) && bodyworkDamageAll)
				html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`">" . translate("Bodywork") . "</th><td class=`"td-wdg`">" . displayValue("Float", bodyworkDamageAll, 1) . translate("%") . "</td></tr>")
			else if ((bodyWorkDamageSum > 0) || isDebug())
				for index, position in ["Front", "Rear", "Left", "Right"] {
					header := ((index = 1) ? translate("Bodywork (rel.)") : "")

					html .= ("<tr><th class=`"th-std th-left`">" . header . "</th><th class=`"th-std th-left`">" . translate(position) . "</th><td class=`"td-wdg`">" . displayValue("Float", bodyworkDamage[index] / bodyWorkDamageSum * 100, 1) . translate("%") . "</td></tr>")
				}

			if ((suspensionDamageSum > 0) || isDebug())
				for index, position in ["FL", "FR", "RL", "RR"] {
					header := ((index = 1) ? translate("Suspension (rel.)") : "")

					html .= ("<tr><th class=`"th-std th-left`">" . header . "</th><th class=`"th-std th-left`">" . translate(projection[position]) . "</th><td class=`"td-wdg`">" . displayValue("Float", suspensionDamage[index] / suspensionDamageSum * 100, 1) . translate("%") . "</td></tr>")
				}

			if ((engineDamage > 0) || isDebug())
				html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`">" . translate("Engine") . "</th><td class=`"td-wdg`">" . displayValue("Float", engineDamage, 1) . translate("%") . "</td></tr>")

			if ((getMultiMapValue(sessionState, "Damage", "Lap.Delta", kUndefined) != kUndefined) && (getMultiMapValue(sessionState, "Damage", "Lap.Delta") != 0))
				html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`">" . translate("Lap time delta") . "</th><td class=`"td-wdg`">" . displayValue("Float", getMultiMapValue(sessionState, "Damage", "Lap.Delta", 0), 1) . translate(" Seconds") . "</td></tr>")

			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`">" . translate("Repair time") . "</th><td class=`"td-wdg`">" . displayValue("Float", getMultiMapValue(sessionState, "Damage", "Time.Repairs", 0), 1) . translate(" Seconds") . "</td></tr>")
		}

		html .= "</table>"

		return html
	}

	createPitstopWidget(sessionState) {
		local pitstopNr := getMultiMapValue(sessionState, "Pitstop", "Planned.Nr", false)
		local pitstopLap := getMultiMapValue(sessionState, "Pitstop", "Planned.Lap", 0)
		local html := ""
		local fuelService := false
		local tyreService := false
		local brakeService := false
		local repairService := []
		local tyreSet := false
		local tyreCompound, tyreCompounds, tyrePressures, index, tyre, axle, fragment
		local driverRequest, driver

		computePressure(key) {
			local value := getMultiMapValue(sessionState, "Pitstop", key, false)
			local increment, sign

			if (value = "-")
				return "-"
			else if value {
				increment := getMultiMapValue(sessionState, "Pitstop", key . ".Increment", 0)
				sign := ((increment > 0) ? "+ " : ((increment < 0) ? "- " : ""))

				return (displayValue("Float", convertUnit("Pressure", value))
					  . translate(" (") . sign . displayValue("Float", convertUnit("Pressure", Abs(increment))) . translate(")"))
			}
			else
				return "-"
		}

		computeRepairs(bodywork, suspension, engine) {
			local repairs := ""

			if (bodywork && inList(repairService, "Bodywork"))
				repairs := translate("Bodywork")

			if (suspension && inList(repairService, "Suspension")) {
				if (StrLen(repairs) > 0)
					repairs .= ", "

				repairs .= translate("Suspension")
			}

			if (engine && inList(repairService, "Engine")) {
				if (StrLen(repairs) > 0)
					repairs .= ", "

				repairs .= translate("Engine")
			}

			return ((StrLen(repairs) > 0) ? repairs : "-")
		}

		try {
			html .= "<table class=`"table-std`">"

			if provider {
				provider.supportsPitstop(&fuelService, &tyreService, &brakeService, &repairService)
				provider.supportsTyreManagement( , &tyreSet)
			}

			if pitstopNr {
				html .= ("<tr><th class=`"th-std th-left`" colspan=`"3`"><div id=`"header`"><i>" . translate("Pitstop") . "</i></div></th></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Nr.") . "</th><td class=`"td-wdg`" colspan=`"2`">" . pitstopNr . "</td></tr>")

				if pitstopLap
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Lap") . "</th><td class=`"td-wdg`" colspan=`"2`">" . pitstopLap . "</td></tr>")

				driverRequest := getMultiMapValue(sessionState, "Pitstop", "Planned.Driver.Request", false)

				if driverRequest {
					driverRequest := string2Values("|", driverRequest)

					driver := string2Values(":", driverRequest[2])[1]

					if (driver != string2Values(":", driverRequest[1])[1])
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Driver") . "</th><td class=`"td-wdg`" colspan=`"2`">" . driver . "</td></tr>")
				}

				if fuelService
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Fuel") . "</th><td class=`"td-wdg`" colspan=`"2`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Pitstop", "Planned.Refuel"))) . "</td></tr>")

				if (tyreService = "Wheel") {
					tyreCompounds := CaseInsenseMap()
					fragment := ""

					for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
						if ((index = 1) || (index = 3))
							fragment .= "<tr>"

						if (index = 1)
							fragment .= "<th class=`"th-std th-left`" rowspan=`"2`">" . translate("Tyres") . "</th>"

						tyreCompound := getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Compound." . tyre)

						if (tyreCompound && (tyreCompound != "-")) {
							tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Compound.Color." . tyre)))

							tyreCompounds[tyreCompound] := true

							fragment .= ("<td class=`"td-wdg`" style=`"text-align: center`">" . tyreCompound . "</td>")
						}
						else {
							fragment .= ("<td class=`"td-wdg`" style=`"text-align: center`">" . translate("No") . "</td>")

							tyreCompounds[translate("No")] := true
						}

						if ((index = 2) || (index = 4))
							fragment .= "</tr>"
					}

					if (tyreCompounds.Count > 1)
						html .= fragment
					else
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . getKeys(tyreCompounds)[1] . "</td></tr>")

					if tyreSet {
						tyreSet := getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Set")

						if tyreSet
							html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyre Set") . "</th><td class=`"td-wdg`" colspan=`"2`">" . tyreSet . "</td></tr>")
					}
				}
				else if (tyreService = "Axle") {
					tyreCompounds := CaseInsenseMap()
					fragment := ""

					for index, axle in ["Front", "Rear"] {
						fragment .= "<tr>"

						if (index = 1)
							fragment .= "<th class=`"th-std th-left`" rowspan=`"2`">" . translate("Tyres") . "</th>"

						tyreCompound := getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Compound." . axle)

						if (tyreCompound && (tyreCompound != "-")) {
							tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Compound.Color." . axle)))

							tyreCompounds[tyreCompound] := true

							fragment .= ("<td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . tyreCompound . "</td>")
						}
						else {
							fragment .= ("<td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . translate("No") . "</td>")

							tyreCompounds[translate("No")] := true
						}

						fragment .= "</tr>"
					}

					if (tyreCompounds.Count > 1)
						html .= fragment
					else
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . getKeys(tyreCompounds)[1] . "</td></tr>")

					if tyreSet {
						tyreSet := getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Set")

						if tyreSet
							html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyre Set") . "</th><td class=`"td-wdg`" colspan=`"2`">" . tyreSet . "</td></tr>")
					}
				}
				else if tyreService {
					tyreCompound := getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Compound")

					if (tyreCompound && (tyreCompound != "-")) {
						tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Compound.Color")))

						html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . tyreCompound . "</td></tr>")

						if tyreSet {
							tyreSet := getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Set")

							if tyreSet
								html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyre Set") . "</th><td class=`"td-wdg`" colspan=`"2`">" . tyreSet . "</td></tr>")
						}
					}
					else
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`" style=`"text-align: center`">" . translate("No") . "</td></tr>")
				}

				if (tyreService && exist([computePressure("Planned.Tyre.Pressure.FL"), computePressure("Planned.Tyre.Pressure.FR")
										, computePressure("Planned.Tyre.Pressure.RL"), computePressure("Planned.Tyre.Pressure.RR")]
									   , nonZero)) {
					html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Pressures") . "</th><td class=`"td-wdg`" style=`"text-align: right`">"
						   . computePressure("Planned.Tyre.Pressure.FL") . "</td><td class=`"td-wdg`" style=`"text-align: right`">"
						   . computePressure("Planned.Tyre.Pressure.FR") . "</td></tr>")
					html .= ("<tr><td class=`"td-wdg`" style=`"text-align: right`">"
						   . computePressure("Planned.Tyre.Pressure.RL") . "</td><td class=`"td-wdg`" style=`"text-align: right`">"
						   . computePressure("Planned.Tyre.Pressure.RR") . "</td></tr>")
				}

				if (brakeService && getMultiMapValue(sessionState, "Pitstop", "Planned.Brake.Change", false))
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Brakes") . "</th><td class=`"td-wdg`" colspan=`"2`">" . (getMultiMapValue(sessionState, "Pitstop", "Planned.Brake.Change", false) ? translate("Yes") : translate("No")) . "</td></tr>")

				if (repairService.Length > 0)
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Repairs") . "</th><td class=`"td-wdg`" colspan=`"2`">"
																 . computeRepairs(getMultiMapValue(sessionState, "Pitstop", "Planned.Repair.Bodywork")
																				, getMultiMapValue(sessionState, "Pitstop", "Planned.Repair.Suspension")
																				, getMultiMapValue(sessionState, "Pitstop", "Planned.Repair.Engine"))
																 . "</td></tr>")

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Prepared") . "</th><td class=`"td-wdg`" colspan=`"2`">"
															 . (getMultiMapValue(sessionState, "Pitstop", "Prepared") ? translate("Yes") : translate("No"))
															 . "</td></tr>")

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Loss of time") . "</th><td class=`"td-wdg`" colspan=`"2`">" . (getMultiMapValue(sessionState, "Pitstop", "Planned.Time.Box") + getMultiMapValue(sessionState, "Pitstop", "Planned.Time.Pitlane")) . translate(" Seconds") . "</td></tr>")
			}
			else {
				html .= ("<tr><th class=`"th-std th-left`" colspan=`"3`"><div id=`"header`"><i>" . translate("Pitstop") . translate(" (") . translate("Forecast") . translate(")") . "</i></div></th></tr>")

				if fuelService
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Fuel") . "</th><td class=`"td-wdg`" colspan=`"2`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Pitstop", "Target.Fuel.Amount"))) . "</td></tr>")

				if (tyreService = "Wheel") {
					tyreCompounds := CaseInsenseMap()
					fragment := ""

					for index, tyre in ["FrontLeft", "FrontRight", "RearLeft", "RearRight"] {
						if ((index = 1) || (index = 3))
							fragment .= "<tr>"

						if (index = 1)
							fragment .= "<th class=`"th-std th-left`" rowspan=`"2`">" . translate("Tyres") . "</th>"

						tyreCompound := getMultiMapValue(sessionState, "Pitstop", "Target.Tyre.Compound." . tyre)

						if (tyreCompound && (tyreCompound != "-")) {
							tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionState, "Pitstop", "Target.Tyre.Compound.Color." . tyre)))

							tyreCompounds[tyreCompound] := true

							fragment .= ("<td class=`"td-wdg`" style=`"text-align: center`">" . tyreCompound . "</td>")
						}
						else {
							fragment .= ("<td class=`"td-wdg`" style=`"text-align: center`">" . translate("No") . "</td>")

							tyreCompounds[translate("No")] := true
						}

						if ((index = 2) || (index = 4))
							fragment .= "</tr>"
					}

					if (tyreCompounds.Count > 1)
						html .= fragment
					else
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . getKeys(tyreCompounds)[1] . "</td></tr>")

					if tyreSet {
						tyreSet := getMultiMapValue(sessionState, "Pitstop", "Target.Tyre.Set")

						if tyreSet
							html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyre Set") . "</th><td class=`"td-wdg`" colspan=`"2`">" . tyreSet . "</td></tr>")
					}
				}
				else if (tyreService = "Axle") {
					tyreCompounds := CaseInsenseMap()
					fragment := ""

					for index, axle in ["Front", "Rear"] {
						fragment .= "<tr>"

						if (index = 1)
							fragment .= "<th class=`"th-std th-left`" rowspan=`"2`">" . translate("Tyres") . "</th>"

						tyreCompound := getMultiMapValue(sessionState, "Pitstop", "Target.Tyre.Compound." . axle)

						if (tyreCompound && (tyreCompound != "-")) {
							tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionState, "Pitstop", "Target.Tyre.Compound.Color." . axle)))

							tyreCompounds[tyreCompound] := true

							fragment .= ("<td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . tyreCompound . "</td>")
						}
						else {
							fragment .= ("<td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . translate("No") . "</td>")

							tyreCompounds[translate("No")] := true
						}

						fragment .= "</tr>"
					}

					if (tyreCompounds.Count > 1)
						html .= fragment
					else
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . getKeys(tyreCompounds)[1] . "</td></tr>")

					if tyreSet {
						tyreSet := getMultiMapValue(sessionState, "Pitstop", "Target.Tyre.Set")

						if tyreSet
							html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyre Set") . "</th><td class=`"td-wdg`" colspan=`"2`">" . tyreSet . "</td></tr>")
					}
				}
				else if tyreService {
					tyreCompound := getMultiMapValue(sessionState, "Pitstop", "Target.Tyre.Compound")

					if (tyreCompound && (tyreCompound != "-")) {
						tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionState, "Pitstop", "Target.Tyre.Compound.Color")))

						html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`" colspan=`"2`" style=`"text-align: center`">" . tyreCompound . "</td></tr>")

						if tyreSet {
							tyreSet := getMultiMapValue(sessionState, "Pitstop", "Target.Tyre.Set")

							if tyreSet
								html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyre Set") . "</th><td class=`"td-wdg`" colspan=`"2`">" . tyreSet . "</td></tr>")
						}
					}
					else
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`" style=`"text-align: center`">" . translate("No") . "</td></tr>")
				}

				if (tyreService && exist([computePressure("Target.Tyre.Pressure.FL"), computePressure("Target.Tyre.Pressure.FR")
										, computePressure("Target.Tyre.Pressure.RL"), computePressure("Target.Tyre.Pressure.RR")]
									   , nonZero)) {
					html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Pressures") . "</th><td class=`"td-wdg`" style=`"text-align: right`">"
						   . computePressure("Target.Tyre.Pressure.FL") . "</td><td class=`"td-wdg`" style=`"text-align: right`">"
						   . computePressure("Target.Tyre.Pressure.FR") . "</td></tr>")
					html .= ("<tr><td class=`"td-wdg`" style=`"text-align: right`">"
						   . computePressure("Target.Tyre.Pressure.RL") . "</td><td class=`"td-wdg`" style=`"text-align: right`">"
						   . computePressure("Target.Tyre.Pressure.RR") . "</td></tr>")
				}

				if (brakeService && getMultiMapValue(sessionState, "Pitstop", "Target.Brake.Change", false))
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Brakes") . "</th><td class=`"td-wdg`" colspan=`"2`">" . (getMultiMapValue(sessionState, "Pitstop", "Target.Brake.Change", false) ? translate("Yes") : translate("No")) . "</td></tr>")

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Loss of time") . "</th><td class=`"td-wdg`" colspan=`"2`">" . (getMultiMapValue(sessionState, "Pitstop", "Target.Time.Box") + getMultiMapValue(sessionState, "Pitstop", "Target.Time.Pitlane")) . translate(" Seconds") . "</td></tr>")
			}
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createStandingsWidget(sessionState) {
		local positionOverall := getMultiMapValue(sessionState, "Standings", "Position.Overall", false)
		local positionClass := getMultiMapValue(sessionState, "Standings", "Position.Class", false)
		local html := ""
		local leaderNr := false
		local nr, delta, colorOpen, colorClose

		static lastLeaderDelta := false
		static lastAheadDelta := false
		static lastBehindDelta := false
		static lastFocusDelta := false

		computeColorInfo(delta, &lastDelta, upColor, downColor, &colorOpen, &colorClose) {
			if (lastDelta && (lastDelta != delta)) {
				colorOpen := ("<font color=`"" . ((delta > lastDelta) ? upColor : downColor) . "`">")
				colorClose := "</font>"
			}
			else {
				colorOpen := ""
				colorClose := ""
			}

			lastDelta := delta
		}

		if (!positionOverall || !positionClass)
			return ""

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Standings") . "</i></div></th></tr>")

			if (positionOverall != positionClass) {
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Position (Overall)") . "</th><td class=`"td-wdg`">" . positionOverall . "</td></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Position (Class)") . "</th><td class=`"td-wdg`">" . positionClass . "</td></tr>")
			}
			else
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Position") . "</th><td class=`"td-wdg`">" . positionOverall . "</td></tr>")

			if (getMultiMapValue(sessionState, "Standings", "Focus.Lap.Time", kUndefined) != kUndefined) {
				nr := getMultiMapValue(sessionState, "Standings", "Focus.Nr")
				delta := getMultiMapValue(sessionState, "Standings", "Focus.Delta")

				computeColorInfo(Abs(delta), &lastFocusDelta, "green", "red", &colorOpen, &colorClose)

				if (nr != "-")
					if nr {
						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Observed #%nr% (Laps)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Standings", "Focus.Laps") . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Observed #%nr% (Delta)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Observed #%nr% (Lap Time)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionState, "Standings", "Focus.Lap.Time")) . "</td></tr>")
					}
					else {
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Observed (Laps)") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Standings", "Focus.Laps") . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Observed (Delta)") . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Observed (Lap Time)") . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionState, "Standings", "Focus.Lap.Time")) . "</td></tr>")
					}
			}

			if (getMultiMapValue(sessionState, "Standings", "Leader.Lap.Time", kUndefined) != kUndefined) {
				nr := getMultiMapValue(sessionState, "Standings", "Leader.Nr")
				delta := getMultiMapValue(sessionState, "Standings", "Leader.Delta")

				computeColorInfo(Abs(delta), &lastLeaderDelta, "red", "green", &colorOpen, &colorClose)

				if (nr != "-")
					if nr {
						leaderNr := nr

						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Leader #%nr% (Laps)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Standings", "Leader.Laps") . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Leader #%nr% (Delta)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Leader #%nr% (Lap Time)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionState, "Standings", "Leader.Lap.Time")) . "</td></tr>")
					}
					else {
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Leader (Laps)") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Standings", "Leader.Laps") . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Leader (Delta)") . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Leader (Lap Time)") . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionState, "Standings", "Leader.Lap.Time")) . "</td></tr>")
					}
			}

			if (getMultiMapValue(sessionState, "Standings", "Ahead.Lap.Time", kUndefined) != kUndefined) {
				nr := getMultiMapValue(sessionState, "Standings", "Ahead.Nr")
				delta := getMultiMapValue(sessionState, "Standings", "Ahead.Delta")

				computeColorInfo(Abs(delta), &lastAheadDelta, "red", "green", &colorOpen, &colorClose)

				if (nr != "-")
					if nr {
						if (nr != leaderNr) {
							html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Ahead #%nr% (Laps)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Standings", "Ahead.Laps") . "</td></tr>")
							html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Ahead #%nr% (Delta)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
							html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Ahead #%nr% (Lap Time)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionState, "Standings", "Ahead.Lap.Time")) . "</td></tr>")
						}
					}
					else {
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Ahead (Laps)") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Standings", "Ahead.Laps") . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Ahead (Delta)") . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Ahead (Lap Time)") . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionState, "Standings", "Ahead.Lap.Time")) . "</td></tr>")
					}
			}

			if (getMultiMapValue(sessionState, "Standings", "Behind.Lap.Time", kUndefined) != kUndefined) {
				nr := getMultiMapValue(sessionState, "Standings", "Behind.Nr")
				delta := getMultiMapValue(sessionState, "Standings", "Behind.Delta")

				computeColorInfo(Abs(delta), &lastBehindDelta, "green", "red", &colorOpen, &colorClose)

				if (nr != "-")
					if nr {
						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Behind #%nr% (Laps)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Standings", "Behind.Laps") . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Behind #%nr% (Delta)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . substituteVariables(translate("Behind #%nr% (Lap Time)"), {nr: nr}) . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionState, "Standings", "Behind.Lap.Time")) . "</td></tr>")
					}
					else {
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Behind (Laps)") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Standings", "Behind.Laps") . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Behind (Delta)") . "</th><td class=`"td-wdg`">" . colorOpen . displayValue("Time", delta) . colorClose . "</td></tr>")
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Behind (Lap Time)") . "</th><td class=`"td-wdg`">" . displayValue("Time", getMultiMapValue(sessionState, "Standings", "Behind.Lap.Time")) . "</td></tr>")
					}
			}
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	updateSessionInfo(sessionState, sessionInfoWidgets, textSize) {
		local staticWidgets := remove(sessionInfoWidgets, "Cycle")
		local html

		static widgets := []
		static shows := 0

		renderInfoWidgets(widgets) {
			local html := "<table>"
			local row := 1
			local column := 1
			local columns := [[], [], []]
			local ignore, widget

			for ignore, widget in widgets
				if widget {
					if (row <= 3) {
						if (column > 3) {
							row += 1
							column := 1
						}

						columns[column].Push(widget(sessionState))

						column += 1
					}
				}

			loop 3
				columns[A_Index] := values2String("<br>", columns[A_Index]*)

			html .= ("<tr><td style=`"padding-right: 25px; vertical-align: top`">" . values2String("</td><td style=`"padding-right: 25px; vertical-align: top`">", columns*) . "</td></tr>")

			return (html . "</table")
		}

		addInfoWidget(widgets, descriptor, fixedDescriptors := []) {
			static descriptors := getKeys(infoWidgets)
			static index := 0

			if descriptor {
				if (descriptor = "Cycle") {
					loop {
						if (++index > descriptors.Length)
							index := 1

						if !inList(fixedDescriptors, descriptors[index])
							break
					}

					descriptor := descriptors[index]
				}

				widgets.Push(infoWidgets[descriptor])
			}
			else
				widgets.Push(false)
		}

		if (isDevelopment() || (sessionState.Count > 0)) {
			html := "<style>" . getTableCSS(systemMonitorGui, textSize) . " div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #header { text-align: center; background-color: #" . systemMonitorGui.Theme.TableColor["Header"] . "; } </style><table>"

			widgets := []

			for ignore, descriptor in sessionInfoWidgets
				addInfoWidget(widgets, descriptor, staticWidgets)

			html .= renderInfoWidgets(widgets)

			updateDashboard(systemMonitorGui, sessionStateViewer, html)
		}
		else
			updateDashboard(systemMonitorGui, sessionStateViewer, "<div style=`"text-align: center; font-size: 14px`"><br><br><br>" . translate("No data available") . "</div>")
	}

	updateSimulationState(controllerState) {
		local state := getMultiMapValue(controllerState, "Simulation", "State", "Disabled")
		local html, icon, displayState

		if kStateIcons.Has(state)
			icon := kStateIcons[state]
		else
			icon := kStateIcons["Unknown"]

		simulationState.Value := icon

		displayState := getMultiMapValue(controllerState, "Simulation", "Session")

		if (displayState = "Qualification")
			displayState := "Qualifying"

		if ((state = "Active") || (state = "Warning")) {
			html := "<table>"
			html .= ("<tr><td><b>" . translate("Simulator:") . "</b></td><td>" . getMultiMapValue(controllerState, "Simulation", "Simulator") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Car:") . "</b></td><td>" . getMultiMapValue(controllerState, "Simulation", "Car") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Track:") . "</b></td><td>" . getMultiMapValue(controllerState, "Simulation", "Track") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Session:") . "</b></td><td>" . translate(displayState) . "</td></tr>")

			if (getMultiMapValue(controllerState, "Simulation", "Information", kUndefined) != kUndefined)
				html .= ("<tr><td><b>" . translate("State:") . "</b></td><td>" . getMultiMapValue(controllerState, "Simulation", "Information") . "</td></tr>")
			else if (getMultiMapValue(controllerState, "Simulation", "Profile", kUndefined) != kUndefined)
				html .= ("<tr><td><b>" . translate("Profile: ") . "</b></td><td>" . getMultiMapValue(controllerState, "Simulation", "Profile") . "</td></tr>")

			html .= "</table>"
		}
		else if (state = "Passive") {
			html := "<table>"
			html .= ("<tr><td><b>" . translate("State:") . "</b></td><td>" . translate("Waiting for session...") . "</td></tr>")
			html .= "</table>"
		}
		else
			html := ""

		updateDashboard(systemMonitorGui, simulationDashboard, html)
	}

	updateAssistantsState(controllerState) {
		local overallState := "Disabled"
		local html := "<table>"
		local info := ""
		local assistant, state, configuration

		for key, state in getMultiMapValues(controllerState, "Race Assistants") {
			if ((key = "Mode") || (key = "Session")) {
				state := values2String(A_Space, collect(string2Values(";", state), translate)*)

				info .= ("<tr><td><b>" . translate(key . ":") . "</b></td><td>" . state . "</td></tr>")
			}
			else {
				if (state = "Active") {
					overallState := "Active"

					if getMultiMapValue(controllerState, key, "Restricted", false)
						state := translate("Restricted")
					else
						state := translate("Active")

					configuration := readMultiMap(kTempDirectory . key . ".state")

					if getMultiMapValue(controllerState, key, "Silent", false)
						state .= translate(" (Silent)")
					else if !getMultiMapValue(configuration, "Voice", "Speaker", true)
						state .= translate(" (Silent)")
					else if (getMultiMapValue(configuration, "Voice", "Muted", kUndefined) != kUndefined) {
						if getMultiMapValue(configuration, "Voice", "Muted")
							state .= translate(" (Muted)")
					}
					else if getMultiMapValue(controllerState, key, "Muted", false)
						state .= translate(" (Muted)")
				}
				else if (state = "Waiting") {
					if (overallState = "Disabled")
						overallState := "Passive"

					state := translate("Waiting...")
				}
				else if (state = "Shutdown") {
					overallState := "Warning"

					state := translate("Waiting...")
				}
				else
					state := translate("Inactive")

				html .= ("<tr><td><b>" . translate(key) . translate(":") . "</b></td><td>" . state . "</td></tr>")
			}
		}

		html .= info

		assistantsState.Value := kStateIcons[overallState]

		if (overallState = "Disabled")
			html := ""
		else
			html .= "</table>"

		updateDashboard(systemMonitorGui, assistantsDashboard, html)
	}

	updateSessionState(controllerState) {
		local state := getMultiMapValue(controllerState, "Team Server", "State", "Disabled")
		local html, icon, ignore, property, key, value

		if kStateIcons.Has(state)
			icon := kStateIcons[state]
		else
			icon := kStateIcons["Unknown"]

		sessionState.Value := icon

		if ((state != "Unknown") && (state != "Disabled")) {
			state := CaseInsenseMap()

			for ignore, property in string2Values(";", getMultiMapValue(controllerState, "Team Server", "Properties")) {
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

		updateDashboard(systemMonitorGui, sessionDashboard, html)
	}

	updateDataState(databaseState) {
		local state := getMultiMapValue(databaseState, "Database Synchronizer", "State", "Disabled")
		local html, icon, serverURL, serverToken, action, counter, identifier

		if kStateIcons.Has(state)
			icon := kStateIcons[state]
		else
			icon := kStateIcons["Unknown"]

		dataState.Value := icon

		if ((state != "Unknown") && (state != "Disabled")) {
			serverURL := getMultiMapValue(databaseState, "Database Synchronizer", "ServerURL", kUndefined)
			serverToken := getMultiMapValue(databaseState, "Database Synchronizer", "ServerToken", kUndefined)

			if !getMultiMapValue(databaseState, "Database Synchronizer", "Connected", true)
				action := "Disconnected"
			else
				action := getMultiMapValue(databaseState, "Database Synchronizer", "Synchronization", false)

			html := "<table>"

			/*
			identifier := getMultiMapValue(databaseState, "Database Synchronizer", "Identifier", false)

			if identifier
				html .= ("<tr><td><b>" . translate("Name:") . "</b></td><td>" . identifier . "</td></tr>")
			*/

			if (serverURL != kUndefined)
				html .= ("<tr><td><b>" . translate("Server:") . "</b></td><td>" . serverURL . "</td></tr>")

			if (serverToken != kUndefined)
				html .= ("<tr><td><b>" . translate("Token:") . "</b></td><td>" . serverToken . "</td></tr>")

			html .= ("<tr><td><b>" . translate("User:") . "</b></td><td>" . getMultiMapValue(databaseState, "Database Synchronizer", "UserID") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Database:") . "</b></td><td>" . getMultiMapValue(databaseState, "Database Synchronizer", "DatabaseID") . "</td></tr>")

			if action {
				switch action, false {
					case "Running":
						counter := getMultiMapValue(databaseState, "Database Synchronizer", "Counter", false)

						if counter
							action := substituteVariables(translate("Synchronizing (%counter% objects transferred)..."), {counter: counter})
						else
							action := translate("Synchronizing...")
					case "Finished":
						action := translate("Finished synchronization")
					case "Waiting":
						action := translate("Waiting for next synchronization...")
					case "Failed":
						action := translate("Synchronization failed")
					case "Uploading":
						action := translate("Uploading community database...")
					case "Downloading":
						action := translate("Downloading community database...")
					case "Disconnected":
						action := (translate("Lost connection to the Team Server (URL: ") . serverURL . translate(")"))
					default:
						throw "Unknown action detected in updateDataState..."
				}

				html .= ("<tr><td><b>" . translate("Action:") . "</b></td><td>" . action . "</td></tr>")
			}

			html .= "</table>"
		}
		else
			html := ""

		updateDashboard(systemMonitorGui, dataDashboard, html)
	}

	updateAutomationState(controllerState) {
		local state := getMultiMapValue(controllerState, "Track Automation", "State", "Disabled")
		local html, icon, automation

		if kStateIcons.Has(state)
			icon := kStateIcons[state]
		else
			icon := kStateIcons["Unknown"]

		automationState.Value := icon

		if ((state != "Unknown") && (state != "Disabled")) {
			if (state = "Passive") {
				html := "<table>"
				html .= ("<tr><td><b>" . translate("State:") . "</b></td><td>" . translate("Waiting for session...") . "</td></tr>")
				html .= "</table>"
			}
			else {
				automation := getMultiMapValue(controllerState, "Track Automation", "Automation", false)

				if !automation
					automation := translate("Not available")

				html := "<table>"
				html .= ("<tr><td><b>" . translate("Simulator:") . "</b></td><td>" . getMultiMapValue(controllerState, "Track Automation", "Simulator") . "</td></tr>")
				html .= ("<tr><td><b>" . translate("Car:") . "</b></td><td>" . getMultiMapValue(controllerState, "Track Automation", "Car") . "</td></tr>")
				html .= ("<tr><td><b>" . translate("Track:") . "</b></td><td>" . getMultiMapValue(controllerState, "Track Automation", "Track") . "</td></tr>")
				html .= ("<tr><td><b>" . translate("Automation:") . "</b></td><td>" . automation . "</td></tr>")
				html .= "</table>"
			}
		}
		else
			html := ""

		updateDashboard(systemMonitorGui, automationDashboard, html)
	}

	updateMapperState(trackMapperState) {
		local state := getMultiMapValue(trackMapperState, "Track Mapper", "State", "Disabled")
		local html, icon, simulator, track, action, points, size

		if kStateIcons.Has(state)
			icon := kStateIcons[state]
		else
			icon := kStateIcons["Unknown"]

		mapperState.Value := icon

		if ((state != "Unknown") && (state != "Disabled")) {
			action := getMultiMapValue(trackMapperState, "Track Mapper", "Action", "Waiting")

			html := "<table>"
			html .= ("<tr><td><b>" . translate("Simulator:") . "</b></td><td>" . getMultiMapValue(trackMapperState, "Track Mapper", "Simulator") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Track:") . "</b></td><td>" . getMultiMapValue(trackMapperState, "Track Mapper", "Track") . "</td></tr>")

			switch action, false {
				case "Waiting":
					action := translate("Waiting for track scanner...")
				case "Scanning":
					size := getMultiMapValue(trackMapperState, "Track Mapper", "Size", false)

					action := (size ? substituteVariables(translate("Scanning track (%size% bytes)..."), {size: size})
									: translate("Scanning track..."))
				case "Reading":
					action := translate("Reading track coordinates (%points%)...")
				case "Analyzing":
					action := translate("Analyzing track coordinates (%points%)...")
				case "Normalizing":
					action := translate("Normalizing track coordinates (%points%)...")
				case "Transforming":
					action := translate("Transforming track coordinates (%points%)...")
				case "Processing":
					action := translate("Processing track spline (%points%)...")
				case "Image":
					action := translate("Creating track map...")
				case "Metadata":
					action := translate("Creating track meta data...")
				default:
					throw "Unknown action detected in updateMapperState..."
			}

			action := substituteVariables(action, {points: getMultiMapValue(trackMapperState, "Track Mapper", "Points", 0)})

			html .= ("<tr><td><b>" . translate("Action:") . "</b></td><td>" . action . "</td></tr>")
			html .= "</table>"
		}
		else
			html := ""

		updateDashboard(systemMonitorGui, mapperDashboard, html)
	}

	closeSystemMonitor(*) {
		ExitApp(0)
	}

	noSelect(listView, *) {
		loop listView.GetCount()
			listView.Modify(A_Index, "-Select")
	}

	chooseLogLevel(*) {
		broadcastMessage(concatenate(kBackgroundApps, remove(kForegroundApps, "System Monitor")), "setLogLevel", logLevelDropDown.Value)
	}

	if !stateIcons
		stateIcons := CaseInsenseMap()

	if !stateIconsList {
		stateIconsList := IL_Create(kStateIcons.Count)

		for key, icon in kStateIcons {
			IL_Add(stateIconsList, icon)

			stateIcons[key] := A_Index
		}
	}

	if (command = kClose)
		result := kClose
	else if (command = "UpdateDashboard") {
		local ignore, viewer

		try {
			if (monitorTabView.Value = 1) {
				for igore, viewer in [simulationDashboard, assistantsDashboard, sessionDashboard
									, dataDashboard, automationDashboard, mapperDashboard]
					viewer.Show()

				controllerState := getControllerState(false)
				databaseState := readMultiMap(kTempDirectory . "Database Synchronizer.state")
				trackMapperState := readMultiMap(kTempDirectory . "Track Mapper.state")

				updateSimulationState(controllerState)
				updateAssistantsState(controllerState)
				updateSessionState(controllerState)
				updateDataState(databaseState)
				updateAutomationState(controllerState)
				updateMapperState(trackMapperState)
			}
			else
				for igore, viewer in [simulationDashboard, assistantsDashboard, sessionDashboard
									, dataDashboard, automationDashboard, mapperDashboard]
					viewer.Hide()
		}
		catch Any as exception {
			logError(exception)
		}
	}
	else if (command = "UpdateModules") {
		try {
			if (monitorTabView.Value = 4) {
				controllerState := getControllerState(false)
				databaseState := readMultiMap(kTempDirectory . "Database Synchronizer.state")
				trackMapperState := readMultiMap(kTempDirectory . "Track Mapper.state")

				icons := []
				modules := []
				messages := []

				plugins := string2Values("|", getMultiMapValue(controllerState, "Modules", "Plugins"))

				if (controllerState.Count > 0) {
					plugins := concatenate(plugins, ["Voice Recognition"])

					bubbleSort(&plugins)
				}

				for ignore, plugin in plugins {
					if plugin {
						state := getMultiMapValue(controllerState, plugin, "State")

						if stateIcons.Has(state)
							icons.Push(stateIcons[state])
						else
							icons.Push(stateIcons["Unknown"])

						modules.Push(translate(plugin))

						messages.Push(getMultiMapValue(controllerState, plugin, "Information", ""))
					}
				}

				state := getMultiMapValue(databaseState, "Database Synchronizer", "State", "Disabled")

				if stateIcons.Has(state)
					icons.Push(stateIcons[state])
				else
					icons.Push(stateIcons["Unknown"])

				modules.Push(translate("Database Synchronization"))

				messages.Push(getMultiMapValue(databaseState, "Database Synchronizer", "Information", ""))

				if (controllerState.Count > 0) {
					state := getMultiMapValue(trackMapperState, "Track Mapper", "State", "Disabled")

					if stateIcons.Has(state)
						icons.Push(stateIcons[state])
					else
						icons.Push(stateIcons["Unknown"])

					modules.Push(translate("Track Mapping"))

					messages.Push(getMultiMapValue(trackMapperState, "Track Mapper", "Information", ""))

					state := getMultiMapValue(controllerState, "Track Automation", "State", "Disabled")

					if stateIcons.Has(state)
						icons.Push(stateIcons[state])
					else
						icons.Push(stateIcons["Unknown"])

					modules.Push(translate("Track Automation"))

					messages.Push(getMultiMapValue(controllerState, "Track Automation", "Information", ""))
				}

				if (!stateModules || !listEqual(modules, stateModules)) {
					stateListView.Delete()

					stateListView.SetImageList(stateIconsList)

					for ignore, plugin in modules
						stateListView.Add("Icon" . icons[A_Index], "    " . plugin, messages[A_Index])

					stateListView.ModifyCol()
					stateListView.ModifyCol(1, "AutoHdr")

					stateModules := modules
				}
				else
					for ignore, plugin in modules {
						stateListView.Modify(A_Index, "Icon" . icons[A_Index])
						stateListView.Modify(A_Index, "Col2", messages[A_Index])
					}

				stateListView.ModifyCol(2, "AutoHdr")
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}
	else if (command = "UpdateServer") {
		serverURLValue := translate("Not connected")
		serverTokenValue := translate("Not connected")
		serverDriverValue := translate("Not connected")
		serverTeamValue := translate("Not connected")
		serverSessionValue := translate("Not connected")

		stintNrValue := translate("Not started")
		stintLapValue := translate("Not started")
		stintDriverValue := translate("Not started")

		drivers := []

		if (monitorTabView.Value = 3) {
			controllerState := getControllerState(false)

			if (controllerState.Count > 0) {
				state := getMultiMapValue(controllerState, "Team Server", "State", "Unknown")

				if kStateIcons.Has(state)
					icon := kStateIcons[state]
				else
					icon := kStateIcons["Unknown"]

				serverState.Value := icon

				if ((state != "Unknown") && (state != "Disabled")) {
					state := CaseInsenseMap()

					for ignore, property in string2Values(";", getMultiMapValue(controllerState, "Team Server", "Properties")) {
						property := StrSplit(property, ":", " `t", 2)

						state[property[1]] := property[2]
					}

					for key, value in state {
						if (value = "Invalid")
							value := translate("Not valid")
						else if (value = "Mismatch")
							value := translate("No match")

						switch key, false {
							case "ServerURL":
								serverURLValue := value
							case "SessionToken":
								serverTokenValue := value
							case "Driver":
								serverDriverValue := value
							case "Team":
								serverTeamValue := value
							case "Session":
								serverSessionValue := value
							case "Drivers":
								drivers := string2Values("|", value)
							case "StintNr":
								stintNrValue := value
							case "StintLap":
								stintLapValue := value
							case "StintDriver":
								stintDriverValue := value
						}
					}
				}
			}

			serverURL.Value := serverURLValue
			serverToken.Value := serverTokenValue
			serverDriver.Value := serverDriverValue
			serverTeam.Value := serverTeamValue
			serverSession.Value := serverSessionValue
			stintNr.Value := stintNrValue
			stintLap.Value := stintLapValue
			stintDriver.Value := stintDriverValue

			driversListView.Delete()

			for ignore, driver in drivers
				driversListView.Add("", driver, (driver = stintDriver.Text) ? translate("x") : "")

			driversListView.ModifyCol()
			driversListView.ModifyCol(1, "AutoHdr")
			driversListView.ModifyCol(2, "AutoHdr")
		}
	}
	else if (command = "UpdateSession") {
		if (monitorTabView.Value = 2) {
			settingsButton.Enabled := true

			sessionStateViewer.Show()
		}
		else {
			settingsButton.Enabled := false

			sessionStateViewer.Hide()
		}

		if (A_TickCount > nextSessionUpdate) {
			sessionInfo := newMultiMap()
			states := []

			for ignore, assistant in kRaceAssistants
				states.Push(readMultiMap(kTempDirectory . assistant . " Session.state"))

			maxLap := 0

			for ignore, state in states
				maxLap := Max(maxLap, getMultiMapValue(state, "Session", "Laps", 0))

			for ignore, state in states
				if (getMultiMapValue(state, "Session", "Laps", 0) = maxLap)
					addMultiMapValues(sessionInfo, state)

			try {
				provider := SimulatorProvider.createSimulatorProvider(getMultiMapValue(sessionInfo, "Session", "Simulator")
																	, getMultiMapValue(sessionInfo, "Session", "Car")
																	, getMultiMapValue(sessionInfo, "Session", "Track"))
			}
			catch Any {
				provider := false
			}

			updateSessionInfo(sessionInfo, sessionInfoWidgets, sessionInfoSize)

			nextSessionUpdate := (A_TickCount + sessionInfoSleep)
		}
	}
	else if (command = "LogMessage") {
		try {
			logLevel := arguments[3]

			switch logLevel {
				case kLogDebug:
					logLevel := "Debug"
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

			time := FormatTime(time, "dd.MM.yy hh:mm:ss tt")

			if (logMessageListView.GetCount() > 0)
				while (logMessageListView.GetCount() >= logBufferEdit.Value)
					logMessageListView.Delete(1)

			logMessageListView.Add("", arguments[1], time, translate(logLevel), arguments[4])
			logMessageListView.Modify(logMessageListView.GetCount(), "Vis")

			if first {
				first := false

				logMessageListView.ModifyCol()

				loop 4
					logMessageListView.ModifyCol(A_Index, "AutoHdr")
			}
			else
				logMessageListView.ModifyCol(4, "AutoHdr")
		}
		catch Any as exception {
			logError(exception)
		}
	}
	else {
		result := false

		systemMonitorGui := Window({Descriptor: "System Monitor", Resizeable: true, Closeable: true, Options: "+SysMenu +Caption"})

		systemMonitorGui.SetFont("s10 Bold", "Arial")

		systemMonitorGui.Add("Text", "w780 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(systemMonitorGui, "System Monitor"))

		systemMonitorGui.SetFont("s9 Norm", "Arial")

		systemMonitorGui.Add("Documentation", "x313 YP+20 w180 Center", translate("Monitoring")
						   , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities")

		systemMonitorGui.SetFont("s8 Norm", "Arial")

		systemMonitorGui.Add("Text", "x8 yp+26 w790 0x10")

		settingsButton := systemMonitorGui.Add("Button", "x766 yp+10 w23 h23 Disabled")
		settingsButton.OnEvent("Click", modifySettings.Bind(systemMonitorGui))
		setButtonIcon(settingsButton, kIconsDirectory . "General Settings.ico", 1)

		if (command = "Tab")
			monitorTabView := systemMonitorGui.Add("Tab3", "x16 yp+4 w773 h375 H:Grow Choose" . inList(["Dashboard", "Session", "Team", "Modules", "Logs"], arguments[1]) . " AltSubmit -Wrap Section", collect(["Dashboard", "Session", "Team", "Modules", "Logs"], translate))
		else
			monitorTabView := systemMonitorGui.Add("Tab3", "x16 yp+4 w773 h375 H:Grow AltSubmit -Wrap Section", collect(["Dashboard", "Session", "Team", "Modules", "Logs"], translate))

		monitorTabView.UseTab(1)

		systemMonitorGui.SetFont("s8 Norm", "Arial")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x24 ys+28 w375 h9", translate("Simulation"))
		systemMonitorGui.Add("Text", "x160 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		simulationState := systemMonitorGui.Add("Picture", "x34 ys+73 w32 h32", kIconsDirectory . "Black.ico")
		simulationDashboard := systemMonitorGui.Add("HTMLViewer", "x94 ys+46 w300 h95 H:Grow(0.333333333) Hidden")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x405 ys+28 w375 h9", translate("Race Assistants"))
		systemMonitorGui.Add("Text", "x541 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		assistantsState := systemMonitorGui.Add("Picture", "x415 ys+73 w32 h32", kIconsDirectory . "Black.ico")
		assistantsDashboard := systemMonitorGui.Add("HTMLViewer", "x475 ys+46 w300 h95 H:Grow(0.333333333) Hidden")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x24 ys+138 w375 h9 Y:Move(0.333333333)", translate("Team Session"))
		systemMonitorGui.Add("Text", "x160 yp+7 w230 0x10 Y:Move(0.333333333)")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		sessionState := systemMonitorGui.Add("Picture", "x34 ys+183 w32 h32 Y:Move(0.333333333) vsessionState", kIconsDirectory . "Black.ico")
		sessionDashboard := systemMonitorGui.Add("HTMLViewer", "x94 ys+156 w300 h95 Y:Move(0.333333333) H:Grow(0.333333333) Hidden")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x405 ys+138 w375 h9 Y:Move(0.333333333)", translate("Data Synchronization"))
		systemMonitorGui.Add("Text", "x541 yp+7 w230 0x10 Y:Move(0.333333333)")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		dataState := systemMonitorGui.Add("Picture", "x415 ys+183 w32 h32 Y:Move(0.333333333) vdataState", kIconsDirectory . "Black.ico")
		dataDashboard := systemMonitorGui.Add("HTMLViewer", "x475 ys+156 w300 h95 Y:Move(0.333333333) H:Grow(0.333333333) Hidden")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x24 ys+248 w375 h9 Y:Move(0.66)", translate("Track Automation"))
		systemMonitorGui.Add("Text", "x160 yp+7 w230 0x10 Y:Move(0.66)")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		automationState := systemMonitorGui.Add("Picture", "x34 ys+293 w32 h32 Y:Move(0.66) vautomationState", kIconsDirectory . "Black.ico")
		automationDashboard := systemMonitorGui.Add("HTMLViewer", "x94 ys+266 w300 h95 Y:Move(0.66) H:Grow(0.333333333) Hidden")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x405 ys+248 w375 h9 Y:Move(0.66)", translate("Track Mapping"))
		systemMonitorGui.Add("Text", "x541 yp+7 w230 0x10 Y:Move(0.66)")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		mapperState := systemMonitorGui.Add("Picture", "x415 ys+293 w32 h32 Y:Move(0.66) vmapperState", kIconsDirectory . "Black.ico")
		mapperDashboard := systemMonitorGui.Add("HTMLViewer", "x475 ys+266 w300 h95 Y:Move(0.66) H:Grow(0.333333333) Hidden")

		monitorTabView.UseTab(2)

		sessionStateViewer := systemMonitorGui.Add("HTMLViewer", "x24 ys+28 w756 h336 H:Grow Hidden")

		monitorTabView.UseTab(3)

		systemMonitorGui.SetFont("s10 Bold", "Arial")

		systemMonitorGui.Add("Text", "x160 ys+28 w104 h30 Center", translate("State"))
		serverState := systemMonitorGui.Add("Picture", "x180 ys+75 w64 h64", kIconsDirectory . "Black.ico")

		systemMonitorGui.SetFont("s8 Norm", "Arial")

		systemMonitorGui.SetFont("Italic", "Arial")

		systemMonitorGui.Add("GroupBox", "x405 ys+28 w375 h150", translate("Connection"))

		systemMonitorGui.SetFont("Norm", "Arial")

		systemMonitorGui.Add("Text", "x413 yp+21 w112", translate("Server URL"))
		serverURL := systemMonitorGui.Add("Text", "x528 yp w245")

		systemMonitorGui.Add("Text", "x413 yp+24 w112", translate("Session Token"))
		serverToken := systemMonitorGui.Add("Text", "x528 yp w245")

		systemMonitorGui.Add("Text", "x413 yp+28 w112", translate("Team"))
		serverTeam := systemMonitorGui.Add("Text", "x528 yp w245")

		systemMonitorGui.Add("Text", "x413 yp+24 w112", translate("Driver"))
		serverDriver := systemMonitorGui.Add("Text", "x528 yp w245")

		systemMonitorGui.Add("Text", "x413 yp+24 w112", translate("Session"))
		serverSession := systemMonitorGui.Add("Text", "x528 yp w245")

		systemMonitorGui.SetFont("Italic", "Arial")

		systemMonitorGui.Add("GroupBox", "x24 ys+188 w375 h9", translate("Drivers"))

		systemMonitorGui.SetFont("Norm", "Arial")

		driversListView := systemMonitorGui.Add("ListView", "x24 yp+21 w375 h120 -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Driver", "Active"], translate))
		driversListView.OnEvent("Click", noSelect)
		driversListView.OnEvent("DoubleClick", noSelect)

		systemMonitorGui.SetFont("Italic", "Arial")

		systemMonitorGui.Add("GroupBox", "x405 ys+188 w375 h142", translate("Stint"))

		systemMonitorGui.SetFont("Norm", "Arial")

		systemMonitorGui.Add("Text", "x413 yp+28 w112", translate("Stint"))
		stintNr := systemMonitorGui.Add("Text", "x528 yp w245")

		systemMonitorGui.Add("Text", "x413 yp+24 w112", translate("Laps"))
		stintLap := systemMonitorGui.Add("Text", "x528 yp w245")

		systemMonitorGui.Add("Text", "x413 yp+24 w112", translate("Driver"))
		stintDriver := systemMonitorGui.Add("Text", "x528 yp w245")

		monitorTabView.UseTab(4)

		stateListView := systemMonitorGui.Add("ListView", "x24 ys+28 w756 h336 H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Module", "Information"], translate))
		stateListView.OnEvent("Click", noSelect)
		stateListView.OnEvent("DoubleClick", noSelect)

		monitorTabView.UseTab(5)

		systemMonitorGui.SetFont("s8 Norm", "Arial")

		logMessageListView := systemMonitorGui.Add("ListView", "x24 ys+28 w756 h312 H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Application", "Time", "Category", "Message"], translate))
		logMessageListView.OnEvent("Click", noSelect)
		logMessageListView.OnEvent("DoubleClick", noSelect)

		systemMonitorGui.Add("Text", "x24 yp+320 w95 h20 Y:Move", translate("Log Buffer"))
		logBufferEdit := systemMonitorGui.Add("Edit", "x120 yp-2 w50 h20 Y:Move Limit3 Number", "999")
		systemMonitorGui.Add("UpDown", "x158 yp w18 h20 Y:Move Range100-999", "999")

		systemMonitorGui.Add("Text", "x590 yp w95 h23 Y:Move +0x200", translate("Log Level"))

		choices := kLogLevelNames
		chosen := getLogLevel()

		logLevelDropDown := systemMonitorGui.Add("DropDownList", "x689 yp-1 w91 Y:Move Choose" . chosen, collect(choices, translate))
		logLevelDropDown.OnEvent("Change", chooseLogLevel)

		systemMonitorGui.Add(SystemMonitorResizer(systemMonitorGui, simulationDashboard, assistantsDashBoard, sessionDashboard
																  , dataDashboard, automationDashboard, mapperDashboard))

		/*
		monitorTabView.UseTab()

		systemMonitorGui.SetFont("s8 Norm", "Arial")

		systemMonitorGui.Add("Text", "x8 ys+385 w790 0x10")

		systemMonitorGui.Add("Button", "x367 yp+10 w80 h23 Default", translate("Close")).OnEvent("Click", closeSystemMonitor)
		*/
		x := false
		y := false

		if getWindowPosition("System Monitor", &x, &y)
			systemMonitorGui.Show("x" . x . " y" . y)
		else
			systemMonitorGui.Show()

		systemMonitorGui.MaxWidth := systemMonitorGui.MinWidth

		if getWindowSize("System Monitor", &w, &h)
			systemMonitorGui.Resize("Initialize", w, h)

		updateDashboard(systemMonitorGui, simulationDashboard)
		updateDashboard(systemMonitorGui, assistantsDashboard)
		updateDashboard(systemMonitorGui, sessionDashboard)
		updateDashboard(systemMonitorGui, dataDashboard)
		updateDashboard(systemMonitorGui, automationDashboard)
		updateDashboard(systemMonitorGui, mapperDashboard)
		updateDashboard(systemMonitorGui, sessionStateViewer, "<div style=`"text-align: center; font-size: 14px`"><br><br><br>" . translate("No data available") . "</div>")

		settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		sessionInfoWidgets := string2Values(",", getMultiMapValue(settings, "System Monitor", "Session Widgets", "Session,Stint,Duration,Conditions,Cycle,Cycle"))
		sessionInfoSleep := (getMultiMapValue(settings, "System Monitor", "Session Cycle", 30) * 1000)
		sessionInfoSize := getMultiMapValue(settings, "System Monitor", "Session Size", 11)

		PeriodicTask(systemMonitor.Bind("UpdateDashboard"), 2000, kLowPriority).start()
		PeriodicTask(systemMonitor.Bind("UpdateModules"), 2000, kLowPriority).start()
		PeriodicTask(systemMonitor.Bind("UpdateServer"), 5000, kLowPriority).start()
		PeriodicTask(systemMonitor.Bind("UpdateSession"), 1000, kLowPriority).start()

		gStartupFinished := true
	}
}

clearOrphaneStateFiles() {
	local ignore, assistant, fileName, modTime

	static stateFiles := false
	static excludedFiles := []

	if !stateFiles {
		stateFiles := CaseInsenseMap()

		for ignore, assistant in kRaceAssistants
			excludedFiles.Push(kTempDirectory . assistant . ".state")
	}

	for ignore, fileName in getFileNames("*.state", kTempDirectory) {
		SplitPath(fileName, , , , &name)

		if inList(kStateFiles, name) {
			if !inList(excludedFiles, fileName) {
				if !stateFiles.Has(fileName)
					stateFiles[fileName] := 0

				modTime := FileGetTime(fileName, "M")

				if (stateFiles[fileName] != modTime)
					stateFiles[fileName] := modTime
				else
					deleteFile(fileName)
			}
		}
	}
}

startupSystemMonitor() {
	local icon := kIconsDirectory . "Monitoring.ico"
	local noLaunch, ignore, assistant

	TraySetIcon(icon, "1")
	A_IconTip := "System Monitor"

	try {
		registerMessageHandler("Monitoring", monitoringMessageHandler)

		deleteFile(kTempDirectory . "Simulator Controller.state")
		deleteFile(kTempDirectory . "Database Synchronizer.state")
		deleteFile(kTempDirectory . "Track Mapper.state")

		for ignore, assistant in kRaceAssistants {
			deleteFile(kTempDirectory . assistant . ".state")
			deleteFile(kTempDirectory . assistant . " Session.state")
		}

		PeriodicTask(clearOrphaneStateFiles, 120000, kLowPriority).start()

		startupApplication()

		if inList(A_Args, "-Show")
			systemMonitor("Tab", A_Args[inList(A_Args, "-Show") + 1])
		else
			systemMonitor()
	}
	catch Any as exception {
		logError(exception, true)

		OnMessage(0x44, translateOkButton)
		withBlockedWindows(MsgBox, substituteVariables(translate("Cannot start %application% due to an internal error..."), {application: "System Monitor"}), translate("Error"), 262160)
		OnMessage(0x44, translateOkButton, 0)

		ExitApp(1)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                         Message Handler Section                         ;;;
;;;-------------------------------------------------------------------------;;;

monitoringMessageHandler(category, data) {
	global gStartupFinished

	if gStartupFinished
		if (InStr(data, "logMessage") = 1) {
			data := StrSplit(StrSplit(data, ":", , 2)[2], ";", " `t", 5)

			return withProtection(systemMonitor, "LogMessage", data[1], data[2], data[3], data[4])
		}
		else
			return functionMessageHandler(category, data)
}


;;;-------------------------------------------------------------------------;;;
;;;                          Plugin Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

if kLogStartup
	logMessage(kLogOff, "Loading plugins...")

#Include "..\Plugins\Simulator Providers.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startupSystemMonitor()