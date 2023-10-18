;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - System Monitor                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Monitoring.ico
;@Ahk2Exe-ExeName System Monitor.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\HTMLViewer.ahk"
#Include "..\Libraries\Task.ahk"
#Include "..\Libraries\Messages.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kOk := "Ok"
global kCancel := "Cancel"
global kClose := "Close"

global kStateIcons := CaseInsenseMap("Disabled", kIconsDirectory . "Black.ico"
								   , "Passive", kIconsDirectory . "Gray.ico"
								   , "Active", kIconsDirectory . "Green.ico"
								   , "Warning", kIconsDirectory . "Yellow.ico"
								   , "Critical", kIconsDirectory . "Red.ico"
								   , "Unknown", kIconsDirectory . "Empty.png")


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global gStartupFinished := false


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

updateDashboard(window, viewer, html := "") {
	local script, ignore, chart

	if (html == false)
		html := " "

	html := ("<html><meta charset='utf-8'><body style='background-color: #" . window.BackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 10px }</style><style> #header { font-size: 12px; } </style><div>" . html . "</div></body></html>")

	viewer.document.open()
	viewer.document.write(html)
	viewer.document.close()

	Sleep(100)
}

getTableCSS(window) {
	local script

	script := "
	(
		.table-std, .th-std, .td-std {
			border-collapse: collapse;
			padding: .3em .5em;
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
			font-size: 1.5em;
			border-radius: .5em .5em 0 0;
			padding: .5em 0 0 0
		}

		.table-std tbody tr:nth-child(even) {
			background-color: #%altBackColor%;
		}

		.table-std tbody tr:nth-child(odd) {
			background-color: #%backColor%;
		}
	)"

	return substituteVariables(script, {altBackColor: window.AltBackColor, backColor: window.BackColor
									  , textColor: window.Theme.TextColor
									  , headerBackColor: window.Theme.TableColor["Header"], frameColor: window.Theme.TableColor["Frame"]})
}

editSettings(settingsOrCommand, arguments*) {
	local settingsGui, x, y, row, column, value

	static infoWidgets := []
	static result := false
	static settings := false
	static widgets := []
	static cycle := 5

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

		while (widgets.Length < 9)
			widgets.Push(false)

		result := false

		settingsGui := Window({Descriptor: "System Monitor.Settings", Options: "0x400000"}, "")

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
	local icon, state, property, drivers, choices, chosen, settings

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

	static infoWidgets := CaseInsenseMap("Session", createSessionWidget,
										 "Duration", createDurationWidget,
										 "Conditions", createConditionsWidget,
										 "Stint", createStintWidget,
										 "Fuel", createFuelWidget,
										 "Tyres", createTyresWidget,
										 "Brakes", createBrakesWidget,
										 "Pitstop", createPitstopWidget,
										 "Strategy", createStrategyWidget,
										 "Standings", createStandingsWidget)

	static sessionInfoWidgets := []
	static sessionInfoSleep := 30000
	static nextSessionUpdate := A_TickCount

	modifySettings(systemMonitorGui, *) {
		local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

		systemMonitorGui.Block()

		try {
			if editSettings(settings, infoWidgets, systemMonitorGui) {
				sessionInfoWidgets := string2Values(",", getMultiMapValue(settings, "System Monitor", "Session Widgets", "Session,Stint,Duration,Conditions,Cycle,Cycle"))
				sessionInfoSleep := (getMultiMapValue(settings, "System Monitor", "Session Cycle", 30) * 1000)

				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				setMultiMapValue(settings, "System Monitor", "Session Widgets", values2String(",", sessionInfoWidgets*))
				setMultiMapValue(settings, "System Monitor", "Session Cycle", Round(sessionInfoSleep / 1000))

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
		html .= "</table>"

		return html
	}

	createDurationWidget(sessionState) {
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
		local html := ""
		local lastTime

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Fuel") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Consumption (Lap)") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Stint", "Fuel.Consumption"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Consumption (Avg.)") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Stint", "Fuel.AvgConsumption"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Remaining Fuel") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Stint", "Fuel.Remaining"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Laps Left") . "</th><td class=`"td-wdg`">" . (fuelLow ? "<font color=`"red`">" : "") . Floor(getMultiMapValue(sessionState, "Stint", "Laps.Remaining.Fuel")) . (fuelLow ? "</font>" : "") . "</td></tr>")

			lastTime := getMultiMapValue(sessionState, "Stint", "Lap.Time.Last", kUndefined)

			if (lastTime != kUndefined)
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Time Left") . "</th><td class=`"td-wdg`">" . (fuelLow ? "<font color=`"red`">" : "") . displayValue("Time", Floor(lastTime * getMultiMapValue(sessionState, "Stint", "Laps.Remaining.Fuel"))) . (fuelLow ? "</font>" : "") . "</td></tr>")
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
		local pressures, temperatures, wear

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"3`"><div id=`"header`"><i>" . translate("Tyres") . "</i></div></th></tr>")

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
			else {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Pressures (cold)") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td></tr>")
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
			else {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Temperatures") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . "-" . "</td></tr>")
			}

			wear := string2Values(",", getMultiMapValue(sessionState, "Tyres", "Wear", ""))

			if (wear.Length = 4) {
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

			if (wear.Length = 4) {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Wear") . "</th><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", wear[1])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", wear[2])) . "</td></tr>")
				html .= ("<tr><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", wear[3])) . "</td><td class=`"td-wdg`" style=`"text-align: center`">"
					   . displayValue("Float", convertUnit("Temperature", wear[4])) . "</td></tr>")
			}
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createStrategyWidget(sessionState) {
		local pitstopsCount := getMultiMapValue(sessionState, "Strategy", "Pitstops", kUndefined)
		local html := ""
		local remainingPitstops := 0
		local nextPitstop, tyreCompound

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Strategy") . "</i></div></th></tr>")

			if (pitstopsCount != kUndefined) {
				nextPitstop := getMultiMapValue(sessionState, "Strategy", "Pitstop.Next", 0)

				if (nextPitstop && pitstopsCount)
					remainingPitstops := (pitstopsCount - nextPitstop + 1)

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Pitstops (Planned)") . "</th><td class=`"td-wdg`">" . pitstopsCount . "</td></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Pitstops (Remaining)") . "</th><td class=`"td-wdg`">" . remainingPitstops . "</td></tr>")

				if nextPitstop {
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Next Pitstop (Lap)") . "</th><td class=`"td-wdg`">" . getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Lap") . "</td></tr>")
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Fuel") . "</th><td class=`"td-wdg`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Refuel"))) . "</td></tr>")

					tyreCompound := getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Tyre.Compound")

					if tyreCompound
						tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionState, "Strategy", "Pitstop.Next.Tyre.Compound.Color")))
					else
						tyreCompound := translate("No")

					html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`">" . tyreCompound . "</td></tr>")
				}
			}
			else
				html .= ("<tr><td class=`"td-wdg`" colspan=`"2`">" . translate("No active strategy") . "</td></tr>")
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createPitstopWidget(sessionState) {
		local pitstopNr := getMultiMapValue(sessionState, "Pitstop", "Planned.Nr", false)
		local pitstopLap := getMultiMapValue(sessionState, "Pitstop", "Planned.Lap", 0)
		local html := ""
		local tyreCompound, tyreSet, tyrePressures

		computeRepairs(bodywork, suspension, engine) {
			local repairs := ""

			if bodywork
				repairs := translate("Bodywork")

			if suspension {
				if (StrLen(repairs) > 0)
					repairs .= ", "

				repairs .= translate("Suspension")
			}

			if engine {
				if (StrLen(repairs) > 0)
					repairs .= ", "

				repairs .= translate("Engine")
			}

			return ((StrLen(repairs) > 0) ? repairs : "-")
		}

		try {
			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"3`"><div id=`"header`"><i>" . translate("Pitstop") . "</i></div></th></tr>")

			if pitstopNr {
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Nr.") . "</th><td class=`"td-wdg`" colspan=`"2`">" . pitstopNr . "</td></tr>")

				if pitstopLap
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Lap") . "</th><td class=`"td-wdg`" colspan=`"2`">" . pitstopLap . "</td></tr>")

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Fuel") . "</th><td class=`"td-wdg`" colspan=`"2`">" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Pitstop", "Planned.Refuel"))) . "</td></tr>")

				tyreCompound := getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Compound")

				if tyreCompound {
					tyreCompound := translate(compound(tyreCompound, getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Compound.Color")))

					html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`" colspan=`"2`">" . tyreCompound . "</td></tr>")

					tyreSet := getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Set")

					if tyreSet
						html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyre Set") . "</th><td class=`"td-wdg`" colspan=`"2`">" . tyreSet . "</td></tr>")

					html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Pressures") . "</th><td class=`"td-wdg`" style=`"text-align: right`">"
						   . displayValue("Float", convertUnit("Pressure", getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Pressure.FL"))) . "</td><td class=`"td-wdg`" style=`"text-align: right`">"
						   . displayValue("Float", convertUnit("Pressure", getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Pressure.FR"))) . "</td></tr>")
					html .= ("<tr><td class=`"td-wdg`" style=`"text-align: right`">"
						   . displayValue("Float", convertUnit("Pressure", getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Pressure.RL"))) . "</td><td class=`"td-wdg`" style=`"text-align: right`">"
						   . displayValue("Float", convertUnit("Pressure", getMultiMapValue(sessionState, "Pitstop", "Planned.Tyre.Pressure.RR"))) . "</td></tr>")
				}
				else
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Tyres") . "</th><td class=`"td-wdg`">" . translate("No") . "</td></tr>")

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Repairs") . "</th><td class=`"td-wdg`" colspan=`"2`">"
															 . computeRepairs(getMultiMapValue(sessionState, "Pitstop", "Planned.Repair.Bodywork")
																			, getMultiMapValue(sessionState, "Pitstop", "Planned.Repair.Suspension")
																			, getMultiMapValue(sessionState, "Pitstop", "Planned.Repair.Engine"))
															 . "</td></tr>")

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Prepared") . "</th><td class=`"td-wdg`" colspan=`"2`">"
															 . (getMultiMapValue(sessionState, "Pitstop", "Prepared") ? translate("Yes") : translate("No"))
															 . "</td></tr>")

				html .= ("<tr><th class=`"th-std th-left`">" . translate("Duration") . "</th><td class=`"td-wdg`" colspan=`"2`">" . getMultiMapValue(sessionState, "Pitstop", "Planned.Service.Time") + getMultiMapValue(sessionState, "Pitstop", "Planned.Pitlane.Delta") . "</td></tr>")
			}
			else
				html .= ("<tr><td class=`"td-wdg`" colspan=`"3`">" . translate("No planned pitstop") . "</td></tr>")
		}
		catch Any as exception {
			logError(exception)

			html := "<table>"
		}

		html .= "</table>"

		return html
	}

	createStandingsWidget(sessionState) {
		local positionOverall := getMultiMapValue(sessionState, "Standings", "Position.Overall")
		local positionClass := getMultiMapValue(sessionState, "Standings", "Position.Class")
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

	updateSessionInfo(sessionState, sessionInfoWidgets) {
		local staticWidgets := remove(sessionInfoWidgets, "Cycle")
		local html

		static widgets := []
		static shows := 0

		renderInfoWidgets(widgets) {
			local html := "<table>"
			local row := 1
			local column := 1
			local ignore, widget
			local columns := [[], [], []]

			for ignore, widget in widgets
				if (row <= 3) {
					if (column > 3) {
						row += 1
						column := 1
					}

					if widget
						columns[column].Push(widget(sessionState))

					column += 1
				}

			loop 3
				columns[A_Index] := values2String("<br>", columns[A_Index]*)

			html .= ("<tr><td style=`"padding-right: 25px`">" . values2String("</td><td style=`"padding-right: 25px`">", columns*) . "</td></tr>")

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

		if (sessionState.Count > 0) {
			html := "<style>" . getTableCSS(systemMonitorGui) . " div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #header { text-align: center; font-size: 12px; background-color: #" . systemMonitorGui.Theme.TableColor["Header"] . "; } </style><table>"

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

		if (state = "Active") {
			html := "<table>"
			html .= ("<tr><td><b>" . translate("Simulator:") . "</b></td><td>" . getMultiMapValue(controllerState, "Simulation", "Simulator") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Car:") . "</b></td><td>" . getMultiMapValue(controllerState, "Simulation", "Car") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Track:") . "</b></td><td>" . getMultiMapValue(controllerState, "Simulation", "Track") . "</td></tr>")
			html .= ("<tr><td><b>" . translate("Session:") . "</b></td><td>" . translate(displayState) . "</td></tr>")
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

					state := translate("Active")

					if getMultiMapValue(controllerState, key, "Muted", false)
						state .= translate(" (Muted)")
					else {
						configuration := readMultiMap(kTempDirectory . key . ".state")

						if (getMultiMapValue(configuration, "Voice", "Muted", false)
						 || !getMultiMapValue(configuration, "Voice", "Speaker", true))
							state .= translate(" (Muted)")
					}
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

				for ignore, plugin in string2Values("|", getMultiMapValue(controllerState, "Modules", "Plugins")) {
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

			for ignore, assistant in ["Race Engineer", "Race Strategist", "Race Spotter"]
				addMultiMapValues(sessionInfo, readMultiMap(kTempDirectory . assistant . " Session.state"))

			updateSessionInfo(sessionInfo, sessionInfoWidgets)

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

		systemMonitorGui.Add("Documentation", "x333 YP+20 w140 Center", translate("Monitoring")
						   , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities")

		systemMonitorGui.SetFont("s8 Norm", "Arial")

		settingsButton := systemMonitorGui.Add("Button", "x773 yp+4 w23 h23 Disabled")
		settingsButton.OnEvent("Click", modifySettings.Bind(systemMonitorGui))
		setButtonIcon(settingsButton, kIconsDirectory . "General Settings.ico", 1)

		systemMonitorGui.Add("Text", "x8 yp+26 w790 0x10")

		monitorTabView := systemMonitorGui.Add("Tab3", "x16 yp+14 w773 h375 H:Grow AltSubmit -Wrap Section", collect(["Dashboard", "Session", "Team", "Modules", "Logs"], translate))

		monitorTabView.UseTab(1)

		systemMonitorGui.SetFont("s8 Norm", "Arial")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x24 ys+28 w375 h9", translate("Simulation"))
		systemMonitorGui.Add("Text", "x160 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		simulationState := systemMonitorGui.Add("Picture", "x34 ys+73 w32 h32", kIconsDirectory . "Black.ico")
		simulationDashboard := systemMonitorGui.Add("HTMLViewer", "x94 ys+46 w300 h95 Hidden")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x405 ys+28 w375 h9", translate("Race Assistants"))
		systemMonitorGui.Add("Text", "x541 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		assistantsState := systemMonitorGui.Add("Picture", "x415 ys+73 w32 h32", kIconsDirectory . "Black.ico")
		assistantsDashboard := systemMonitorGui.Add("HTMLViewer", "x475 ys+46 w300 h95 Hidden")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x24 ys+138 w375 h9", translate("Team Session"))
		systemMonitorGui.Add("Text", "x160 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		sessionState := systemMonitorGui.Add("Picture", "x34 ys+183 w32 h32 vsessionState", kIconsDirectory . "Black.ico")
		sessionDashboard := systemMonitorGui.Add("HTMLViewer", "x94 ys+156 w300 h95 Hidden")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x405 ys+138 w375 h9", translate("Data Synchronization"))
		systemMonitorGui.Add("Text", "x541 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		dataState := systemMonitorGui.Add("Picture", "x415 ys+183 w32 h32 vdataState", kIconsDirectory . "Black.ico")
		dataDashboard := systemMonitorGui.Add("HTMLViewer", "x475 ys+156 w300 h95 Hidden")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x24 ys+248 w375 h9", translate("Track Automation"))
		systemMonitorGui.Add("Text", "x160 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		automationState := systemMonitorGui.Add("Picture", "x34 ys+293 w32 h32 vautomationState", kIconsDirectory . "Black.ico")
		automationDashboard := systemMonitorGui.Add("HTMLViewer", "x94 ys+266 w300 h95 Hidden")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x405 ys+248 w375 h9", translate("Track Mapping"))
		systemMonitorGui.Add("Text", "x541 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		mapperState := systemMonitorGui.Add("Picture", "x415 ys+293 w32 h32 vmapperState", kIconsDirectory . "Black.ico")
		mapperDashboard := systemMonitorGui.Add("HTMLViewer", "x475 ys+266 w300 h95 Hidden")

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

		systemMonitorGui.Add("Text", "x413 yp+21 w120", translate("Server URL"))
		serverURL := systemMonitorGui.Add("Text", "x528 yp w230")

		systemMonitorGui.Add("Text", "x413 yp+24 w120", translate("Session Token"))
		serverToken := systemMonitorGui.Add("Text", "x528 yp w230")

		systemMonitorGui.Add("Text", "x413 yp+28 w120", translate("Team"))
		serverTeam := systemMonitorGui.Add("Text", "x528 yp w230")

		systemMonitorGui.Add("Text", "x413 yp+24 w120", translate("Driver"))
		serverDriver := systemMonitorGui.Add("Text", "x528 yp w230")

		systemMonitorGui.Add("Text", "x413 yp+24 w120", translate("Session"))
		serverSession := systemMonitorGui.Add("Text", "x528 yp w230")

		systemMonitorGui.SetFont("Italic", "Arial")

		systemMonitorGui.Add("GroupBox", "x24 ys+188 w375 h9", translate("Drivers"))

		systemMonitorGui.SetFont("Norm", "Arial")

		driversListView := systemMonitorGui.Add("ListView", "x24 yp+21 w375 h120 -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Driver", "Active"], translate))
		driversListView.OnEvent("Click", noSelect.Bind(driversListView))
		driversListView.OnEvent("DoubleClick", noSelect.Bind(driversListView))

		systemMonitorGui.SetFont("Italic", "Arial")

		systemMonitorGui.Add("GroupBox", "x405 ys+188 w375 h142", translate("Stint"))

		systemMonitorGui.SetFont("Norm", "Arial")

		systemMonitorGui.Add("Text", "x413 yp+28 w120", translate("Stint"))
		stintNr := systemMonitorGui.Add("Text", "x528 yp w230")

		systemMonitorGui.Add("Text", "x413 yp+24 w120", translate("Laps"))
		stintLap := systemMonitorGui.Add("Text", "x528 yp w230")

		systemMonitorGui.Add("Text", "x413 yp+24 w120", translate("Driver"))
		stintDriver := systemMonitorGui.Add("Text", "x528 yp w230")

		monitorTabView.UseTab(4)

		stateListView := systemMonitorGui.Add("ListView", "x24 ys+28 w756 h336 H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Module", "Information"], translate))
		stateListView.OnEvent("Click", noSelect.Bind(stateListView))
		stateListView.OnEvent("DoubleClick", noSelect.Bind(stateListView))

		monitorTabView.UseTab(5)

		systemMonitorGui.SetFont("s8 Norm", "Arial")

		logMessageListView := systemMonitorGui.Add("ListView", "x24 ys+28 w756 h312 H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Application", "Time", "Category", "Message"], translate))
		logMessageListView.OnEvent("Click", noSelect.Bind(logMessageListView))
		logMessageListView.OnEvent("DoubleClick", noSelect.Bind(logMessageListView))

		systemMonitorGui.Add("Text", "x24 yp+320 w95 h20 Y:Move", translate("Log Buffer"))
		logBufferEdit := systemMonitorGui.Add("Edit", "x120 yp-2 w50 h20 Y:Move Limit3 Number", "999")
		systemMonitorGui.Add("UpDown", "x158 yp w18 h20 Y:Move Range100-999", "999")

		systemMonitorGui.Add("Text", "x590 yp w95 h23 Y:Move +0x200", translate("Log Level"))

		choices := kLogLevelNames
		chosen := getLogLevel()

		logLevelDropDown := systemMonitorGui.Add("DropDownList", "x689 yp-1 w91 Y:Move Choose" . chosen, collect(choices, translate))
		logLevelDropDown.OnEvent("Change", chooseLogLevel)

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

		PeriodicTask(systemMonitor.Bind("UpdateDashboard"), 2000, kLowPriority).start()
		PeriodicTask(systemMonitor.Bind("UpdateModules"), 2000, kLowPriority).start()
		PeriodicTask(systemMonitor.Bind("UpdateServer"), 5000, kLowPriority).start()
		PeriodicTask(systemMonitor.Bind("UpdateSession"), 1000, kLowPriority).start()

		gStartupFinished := true
	}
}

clearOrphaneStateFiles() {
	local ignore, fileName, modTime

	static stateFiles := false

	if !stateFiles
		stateFiles := CaseInsenseMap()

	for ignore, fileName in getFileNames("*.state", kTempDirectory) {
		if !stateFiles.Has(fileName)
			stateFiles[fileName] := 0

		modTime := FileGetTime(fileName, "M")

		if (stateFiles[fileName] != modTime)
			stateFiles[fileName] := modTime
		else
			deleteFile(fileName)
	}
}

startupSystemMonitor() {
	local icon := kIconsDirectory . "Monitoring.ico"
	local noLaunch, ignore, assistant

	TraySetIcon(icon, "1")
	A_IconTip := "System Monitor"

	registerMessageHandler("Monitoring", monitoringMessageHandler)

	deleteFile(kTempDirectory . "Simulator Controller.state")
	deleteFile(kTempDirectory . "Database Synchronizer.state")
	deleteFile(kTempDirectory . "Track Mapper.state")

	for ignore, assistant in ["Race Engineer", "Race Strategist", "Race Spotter"]
		deleteFile(kTempDirectory . assistant . " Session.state")

	PeriodicTask(clearOrphaneStateFiles, 60000, kLowPriority).start()

	startupApplication()

	systemMonitor()
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
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

startupSystemMonitor()