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
		html := ""

	html := ("<html><meta charset='utf-8'><body style='background-color: #" . window.BackColor . "; overflow: auto; leftmargin=0; topmargin=0; rightmargin=0; bottommargin=0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 10px }</style><style> #header { font-size: 12px; } td {vertical-align: top } </style><div>" . html . "</div></body></html>")

	viewer.document.open()
	viewer.document.write(html)
	viewer.document.close()
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

		.td-std {
			border-left: thin solid #%frameColor%;
			border-right: thin solid #%frameColor%;
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

systemMonitor(command := false, arguments*) {
	global gStartupFinished

	local x, y, time, logLevel
	local controllerState, databaseState, trackMapperState, ignore, plugin, icons, modules, key, value
	local icon, state, property, drivers, choices, chosen

	local serverURLValue, serverTokenValue, serverDriverValue, serverTeamValue, serverSessionValue
	local stintNrValue, stintLapValue, stintDriverValue

	static systemMonitorGui
	static monitorTabView

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

	updateSessionInfo(sessionState) {
		local sessionTime, stintTime, driverTime, sessionLaps, stintLaps, fuelLow, weatherNow, weather10Min, weather30Min
		local lastTime, bestTime, lastLap, lastValid, pressures, temperatures

		if (sessionState.Count > 0) {
			html := "<style>" . getTableCSS(systemMonitorGui) . " div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #header { text-align: center; font-size: 12px; background-color: #" . systemMonitorGui.Theme.TableColor["Header"] . "; } td {vertical-align: top } </style><table>"

			sessionTime := getMultiMapValue(sessionState, "Session", "Time.Remaining")
			stintTime := getMultiMapValue(sessionState, "Stint", "Time.Remaining.Stint")
			driverTime := getMultiMapValue(sessionState, "Stint", "Time.Remaining.Driver")

			sessionLaps := getMultiMapValue(sessionState, "Session", "Laps.Remaining")
			stintLaps := getMultiMapValue(sessionState, "Stint", "Laps.Remaining.Stint")

			lastLap := getMultiMapValue(sessionState, "Stint", "Lap")
			lastValid := getMultiMapValue(sessionState, "Stint", "Valid", true)

			lastTime := getMultiMapValue(sessionState, "Stint", "Lap.Time.Last")
			lastTime := ((lastTime < 3600) ? displayValue("Time", lastTime) : "-")

			bestTime := getMultiMapValue(sessionState, "Stint", "Lap.Time.Best")
			bestTime := ((bestTime < 3600) ? displayValue("Time", bestTime) : "-")

			fuelLow := (Floor(getMultiMapValue(sessionState, "Stint", "Laps.Remaining.Fuel")) < 4)

			weatherNow := getMultiMapValue(sessionState, "Weather", "Now")
			weather10Min := getMultiMapValue(sessionState, "Weather", "10Min")
			weather30Min := getMultiMapValue(sessionState, "Weather", "30Min")

			html .= "<tr><td style=`"padding-right: 25px`">"

			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Session") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Simulator") . "</th><td>" . getMultiMapValue(sessionState, "Session", "Simulator") . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Car") . "</th><td>" . getMultiMapValue(sessionState, "Session", "Car") . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Track") . "</th><td>" . getMultiMapValue(sessionState, "Session", "Track") . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Session") . "</th><td>" . translate(getMultiMapValue(sessionState, "Session", "Type")) . "</td></tr>")
			html .= "</table>"

			html .= "</td><td style=`"padding-right: 25px`">"

			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Duration") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Format") . "</th><td>" . translate(getMultiMapValue(sessionState, "Session", "Format")) . "</td></tr>")
			if (sessionTime != stintTime) {
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Time Left (Session)") . "</th><td>" . displayValue("Time", sessionTime) . "</td></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Time Left (Stint)") . "</th><td>" . (((stintTime / lastTime) < 4) ? "<font color=`"red`">" : "") . displayValue("Time", stintTime) . (((stintTime / lastTime) < 4) ? "</font>" : "") . "</td></tr>")
				if (driverTime != stintTime)
					html .= ("<tr><th class=`"th-std th-left`">" . translate("Time Left (Driver)") . "</th><td>" . (((driverTime / lastTime) < 4) ? "<font color=`"red`">" : "") . displayValue("Time", driverTime) . (((driverTime / lastTime) < 4) ? "</font>" : "") . "</td></tr>")
			}
			else
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Time Left") . "</th><td>" . displayValue("Time", sessionTime) . "</td></tr>")
			if (sessionLaps != stintLaps) {
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Laps Left (Session)") . "</th><td>" . sessionLaps . "</td></tr>")
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Laps Left (Stint)") . "</th><td>" . ((stintLaps < 4) ? "<font color=`"red`">" : "") . stintLaps . ((stintLaps < 4) ? "</font>" : "") . "</td></tr>")
			}
			else
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Laps Left") . "</th><td>" . sessionLaps . "</td></tr>")
			html .= "</table>"

			html .= "</td><td>"

			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Conditions") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Weather") . "</th><td>" . translate(weatherNow) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Temperature (Air)") . "</th><td>" . displayValue("Float", convertUnit("Temperature", getMultiMapValue(sessionState, "Weather", "Temperature"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Temperature (Track)") . "</th><td>" . displayValue("Float", convertUnit("Temperature", getMultiMapValue(sessionState, "Track", "Temperature"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Grip") . "</th><td>" . translate(getMultiMapValue(sessionState, "Track", "Grip")) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Outlook (10 minutes)") . "</th><td>" . ((weather10Min != weatherNow) ? "<font color=`"red`">" : "") . translate(weather10Min) . ((weather10Min != weatherNow) ? "</font>" : "") . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Outlook (30 minutes)") . "</th><td>" . ((weather30Min != weatherNow) ? "<font color=`"red`">" : "") . translate(weather30Min) . ((weather30Min != weatherNow) ? "</font>" : "") . "</td></tr>")
			html .= "</table>"

			html .= "</td></tr>"

			html .= "<tr><td> </td><td> </td><td> </td></tr>"
			html .= "<tr><td> </td><td> </td><td> </td></tr>"

			html .= "<tr><td style=`"padding-right: 25px`">"

			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Stint") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Driver") . "</th><td>" . getMultiMapValue(sessionState, "Stint", "Driver") . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Lap") . "</th><td>" . lastLap . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Position") . "</th><td>" . getMultiMapValue(sessionState, "Stint", "Position") . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Lap Time (Last / Best)") . "</th><td>" . (!lastValid ? "<font color=`"red`">" : "") . lastTime . (!lastValid ? "</font>" : "") . translate(" / ") . bestTime . "</td></tr>")
			if (lastLap != getMultiMapValue(sessionState, "Stint", "Laps"))
				html .= ("<tr><th class=`"th-std th-left`">" . translate("Laps (Stint)") . "</th><td>" . getMultiMapValue(sessionState, "Stint", "Laps") . "</td></tr>")
			html .= "</table>"

			html .= "</td><td style=`"padding-right: 25px`">"

			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"2`"><div id=`"header`"><i>" . translate("Fuel") . "</i></div></th></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Consumption (Lap)") . "</th><td>" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Stint", "Fuel.Consumption"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Consumption (Avg.)") . "</th><td>" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Stint", "Fuel.AvgConsumption"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Remaining Fuel") . "</th><td>" . displayValue("Float", convertUnit("Volume", getMultiMapValue(sessionState, "Stint", "Fuel.Remaining"))) . "</td></tr>")
			html .= ("<tr><th class=`"th-std th-left`">" . translate("Remaining Laps") . "</th><td>" . (fuelLow ? "<font color=`"red`">" : "") . Floor(getMultiMapValue(sessionState, "Stint", "Laps.Remaining.Fuel")) . (fuelLow ? "</font>" : "") . "</td></tr>")
			html .= "</table>"

			html .= "</td><td>"

			html .= "<table class=`"table-std`">"
			html .= ("<tr><th class=`"th-std th-left`" colspan=`"3`"><div id=`"header`"><i>" . translate("Tyres") . "</i></div></th></tr>")
			pressures := string2Values(",", getMultiMapValue(sessionState, "Tyres", "Pressures", ""))
			if (pressures.Length = 4) {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Pressures") . "</th><td style=`"padding-right: 15px; text-align: right`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[1])) . "</td><td style=`"text-align: right`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[2])) . "</td></tr>")
				html .= ("<tr><td style=`"padding-right: 15px; text-align: right`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[3])) . "</td><td style=`"text-align: right`">"
					   . displayValue("Float", convertUnit("Pressure", pressures[4])) . "</td></tr>")
			}
			else {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Pressures") . "</th><td style=`"padding-right: 15px; text-align: right`">"
					   . "-" . "</td><td style=`"text-align: right`">"
					   . "-" . "</td></tr>")
				html .= ("<tr><td style=`"padding-right: 15px; text-align: right`">"
					   . "-" . "</td><td style=`"text-align: right`">"
					   . "-" . "</td></tr>")
			}
			temperatures := string2Values(",", getMultiMapValue(sessionState, "Tyres", "Temperatures", ""))
			if (temperatures.Length = 4) {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Temperatures") . "</th><td style=`"padding-right: 15px; text-align: right`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[1])) . "</td><td style=`"text-align: right`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[2])) . "</td></tr>")
				html .= ("<tr><td style=`"padding-right: 15px; text-align: right`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[3])) . "</td><td style=`"text-align: right`">"
					   . displayValue("Float", convertUnit("Temperature", temperatures[4])) . "</td></tr>")
			}
			else {
				html .= ("<tr><th class=`"th-std th-left`" rowspan=`"2`">" . translate("Temperatures") . "</th><td style=`"padding-right: 15px; text-align: right`">"
					   . "-" . "</td><td style=`"text-align: right`">"
					   . "-" . "</td></tr>")
				html .= ("<tr><td style=`"padding-right: 15px; text-align: right`">"
					   . "-" . "</td><td style=`"text-align: right`">"
					   . "-" . "</td></tr>")
			}
			html .= "</table>"

			html .= "</td>"

			html .= "</tr>"

			html .= "</table>"

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
			if ((key = "Mode") || (key = "Session"))
				info .= ("<tr><td><b>" . translate(key . ":") . "</b></td><td>" . translate(state) . "</td></tr>")
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
		local html, icon, simulator, track, action, points

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
					action := translate("Scanning track...")
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
		try {
			if (monitorTabView.Value = 1) {
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
		if (monitorTabView.Value = 2)
			updateSessionInfo(readMultiMap(kTempDirectory . "Session.state"))
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

		systemMonitorGui := Window({Descriptor: "System Monitor", Closeable: true, Options: "+SysMenu +Caption"})

		systemMonitorGui.SetFont("s10 Bold", "Arial")

		systemMonitorGui.Add("Text", "w780 Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(systemMonitorGui, "System Monitor"))

		systemMonitorGui.SetFont("s9 Norm", "Arial")

		systemMonitorGui.Add("Documentation", "x333 YP+20 w140 Center", translate("Monitoring")
						   , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities")

		systemMonitorGui.SetFont("s8 Norm", "Arial")

		systemMonitorGui.Add("Text", "x8 yp+26 w790 0x10")

		monitorTabView := systemMonitorGui.Add("Tab3", "x16 yp+14 w773 h375 AltSubmit -Wrap Section", collect(["Dashboard", "Session", "Team", "Modules", "Logs"], translate))

		monitorTabView.UseTab(1)

		systemMonitorGui.SetFont("s8 Norm", "Arial")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x24 ys+28 w375 h9", translate("Simulation"))
		systemMonitorGui.Add("Text", "x160 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		simulationState := systemMonitorGui.Add("Picture", "x34 ys+73 w32 h32", kIconsDirectory . "Black.ico")
		simulationDashboard := systemMonitorGui.Add("HTMLViewer", "x94 ys+46 w300 h95")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x405 ys+28 w375 h9", translate("Race Assistants"))
		systemMonitorGui.Add("Text", "x541 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		assistantsState := systemMonitorGui.Add("Picture", "x415 ys+73 w32 h32", kIconsDirectory . "Black.ico")
		assistantsDashboard := systemMonitorGui.Add("HTMLViewer", "x475 ys+46 w300 h95")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x24 ys+138 w375 h9", translate("Team Session"))
		systemMonitorGui.Add("Text", "x160 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		sessionState := systemMonitorGui.Add("Picture", "x34 ys+183 w32 h32 vsessionState", kIconsDirectory . "Black.ico")
		sessionDashboard := systemMonitorGui.Add("HTMLViewer", "x94 ys+156 w300 h95")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x405 ys+138 w375 h9", translate("Data Synchronization"))
		systemMonitorGui.Add("Text", "x541 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		dataState := systemMonitorGui.Add("Picture", "x415 ys+183 w32 h32 vdataState", kIconsDirectory . "Black.ico")
		dataDashboard := systemMonitorGui.Add("HTMLViewer", "x475 ys+156 w300 h95")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x24 ys+248 w375 h9", translate("Track Automation"))
		systemMonitorGui.Add("Text", "x160 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		automationState := systemMonitorGui.Add("Picture", "x34 ys+293 w32 h32 vautomationState", kIconsDirectory . "Black.ico")
		automationDashboard := systemMonitorGui.Add("HTMLViewer", "x94 ys+266 w300 h95")

		systemMonitorGui.SetFont("Italic", "Arial")
		systemMonitorGui.Add("GroupBox", "x405 ys+248 w375 h9", translate("Track Mapping"))
		systemMonitorGui.Add("Text", "x541 yp+7 w230 0x10")
		systemMonitorGui.SetFont("s8 Norm", "Arial")

		mapperState := systemMonitorGui.Add("Picture", "x415 ys+293 w32 h32 vmapperState", kIconsDirectory . "Black.ico")
		mapperDashboard := systemMonitorGui.Add("HTMLViewer", "x475 ys+266 w300 h95")

		monitorTabView.UseTab(4)

		sessionStateViewer := systemMonitorGui.Add("HTMLViewer", "x24 ys+28 w756 h336")

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

		monitorTabView.UseTab(2)

		stateListView := systemMonitorGui.Add("ListView", "x24 ys+28 w756 h336 -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Module", "Information"], translate))
		stateListView.OnEvent("Click", noSelect.Bind(stateListView))
		stateListView.OnEvent("DoubleClick", noSelect.Bind(stateListView))

		monitorTabView.UseTab(5)

		systemMonitorGui.SetFont("s8 Norm", "Arial")

		logMessageListView := systemMonitorGui.Add("ListView", "x24 ys+28 w756 h312 -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Application", "Time", "Category", "Message"], translate))
		logMessageListView.OnEvent("Click", noSelect.Bind(logMessageListView))
		logMessageListView.OnEvent("DoubleClick", noSelect.Bind(logMessageListView))

		systemMonitorGui.Add("Text", "x24 yp+320 w95 h20", translate("Log Buffer"))
		logBufferEdit := systemMonitorGui.Add("Edit", "x120 yp-2 w50 h20 Limit3 Number", "999")
		systemMonitorGui.Add("UpDown", "x158 yp w18 h20 Range100-999", "999")

		systemMonitorGui.Add("Text", "x590 yp w95 h23 +0x200", translate("Log Level"))

		choices := kLogLevelNames
		chosen := getLogLevel()

		logLevelDropDown := systemMonitorGui.Add("DropDownList", "x689 yp-1 w91 Choose" . chosen, collect(choices, translate))
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

		updateDashboard(systemMonitorGui, simulationDashboard)
		updateDashboard(systemMonitorGui, assistantsDashboard)
		updateDashboard(systemMonitorGui, sessionDashboard)
		updateDashboard(systemMonitorGui, dataDashboard)
		updateDashboard(systemMonitorGui, automationDashboard)
		updateDashboard(systemMonitorGui, mapperDashboard)
		updateDashboard(systemMonitorGui, sessionStateViewer, "<div style=`"text-align: center; font-size: 14px`"><br><br><br>" . translate("No data available") . "</div>")

		PeriodicTask(systemMonitor.Bind("UpdateDashboard"), 2000, kLowPriority).start()
		PeriodicTask(systemMonitor.Bind("UpdateModules"), 2000, kLowPriority).start()
		PeriodicTask(systemMonitor.Bind("UpdateServer"), 5000, kLowPriority).start()
		PeriodicTask(systemMonitor.Bind("UpdateSession"), 10000, kLowPriority).start()

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

startSystemMonitor() {
	local icon := kIconsDirectory . "Monitoring.ico"
	local noLaunch

	TraySetIcon(icon, "1")
	A_IconTip := "System Monitor"

	registerMessageHandler("Monitoring", monitoringMessageHandler)

	deleteFile(kTempDirectory . "Simulator Controller.state")
	deleteFile(kTempDirectory . "Session.state")
	deleteFile(kTempDirectory . "Database Synchronizer.state")
	deleteFile(kTempDirectory . "Track Mapper.state")

	PeriodicTask(clearOrphaneStateFiles, 60000, kLowPriority).start()

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

startSystemMonitor()