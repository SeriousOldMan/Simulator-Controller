;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Reports Tool               ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Chart.ico
;@Ahk2Exe-ExeName Race Reports.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\HTMLViewer.ahk"
#Include "..\Libraries\Task.ahk"
#Include "Libraries\RaceReportViewer.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kOk := "Ok"
global kCancel := "Cancel"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class RaceReports extends ConfigurationItem {
	iWindow := false

	iDatabase := false

	iSessionDatabase := SessionDatabase()

	iSelectedSimulator := false
	iSelectedCar := false
	iSelectedTrack := false

	iAvailableRaces := []

	iRacesListView := false
	iSelectedRace := false
	iSelectedReport := false

	iReportViewer := false

	class ReportResizer extends Window.Resizer {
		iRedraw := false

		__New(arguments*) {
			super.__New(arguments*)

			Task.startTask(ObjBindMethod(this, "RedrawHTMLViwer"), 500, kLowPriority)
		}

		Redraw() {
			this.iRedraw := true
		}

		RedrawHTMLViwer() {
			if this.iRedraw {
				local reports := RaceReports.Instance
				local ignore, button

				for ignore, button in ["LButton", "MButton", "RButton"]
					if GetKeyState(button)
						return Task.CurrentTask

				this.iRedraw := false

				reports.ReportViewer.ChartViewer.Resized()
				reports.ReportViewer.InfoViewer.Resized()

				reports.loadReport(RaceReports.Instance.SelectedReport, true)
			}

			return Task.CurrentTask
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	Control[name] {
		Get {
			return this.iWindow[name]
		}
	}

	RacesListView {
		Get {
			return this.iRacesListView
		}
	}

	Database {
		Get {
			return this.iDatabase
		}
	}

	SessionDatabase {
		Get {
			return this.iSessionDatabase
		}
	}

	SelectedSimulator {
		Get {
			return this.iSelectedSimulator
		}
	}

	SelectedCar {
		Get {
			return this.iSelectedCar
		}
	}

	SelectedTrack {
		Get {
			return this.iSelectedTrack
		}
	}

	AvailableRaces[index?] {
		Get {
			return (isSet(index) ? this.iAvailableRaces[index] : this.iAvailableRaces)
		}
	}

	SelectedRace {
		Get {
			return this.iSelectedRace
		}
	}

	SelectedReport {
		Get {
			return this.iSelectedReport
		}
	}

	ReportViewer {
		Get {
			return this.iReportViewer
		}
	}

	Settings[key?] {
		Get {
			return (isSet(key) ? this.ReportViewer.Settings[key] : this.ReportViewer.Settings)
		}

		Set {
			if isSet(key)
				return this.ReportViewer.Settings[key] := value
			else
				return this.ReportViewer.Settings := value
		}
	}

	__New(database, configuration) {
		this.iDatabase := database

		super.__New(configuration)

		RaceReports.Instance := this

		this.createGui(this.Configuration)
	}

	createGui(configuration) {
		local reports := this
		local stepWizard, simulators, simulator

		static raceReportsGui

		chooseSimulator(*) {
			reports.loadSimulator(raceReportsGui["simulatorDropDown"].Text)
		}

		chooseCar(*) {
			local sessionDB := reports.SessionDatabase
			local simulator := reports.SelectedSimulator
			local index, car

			for index, car in reports.getCars(simulator)
				if (sessionDB.getCarName(simulator, car) = raceReportsGui["carDropDown"].Text)
					reports.loadCar(car)
		}

		chooseTrack(*) {
			local simulator := reports.SelectedSimulator
			local tracks := reports.getTracks(simulator, reports.SelectedCar)
			local trackNames := collect(tracks, ObjBindMethod(reports.SessionDatabase, "getTrackName", simulator))

			reports.loadTrack(tracks[inList(trackNames, raceReportsGui["trackDropDown"].Text)])
		}

		selectRace(listView, line, selected) {
			if selected
				chooseRace(listView, line)
		}

		chooseRace(listView, line, *) {
			reports.loadRace(line)
		}

		chooseReport(*) {
			reports.loadReport(kRaceReports[raceReportsGui["reportsDropDown"].Value])
		}

		reportSettings(*) {
			reports.reportSettings(kRaceReports[raceReportsGui["reportsDropDown"].Value])
		}

		reloadRaceReports(*) {
			reports.loadTrack(reports.SelectedTrack, true)
		}

		deleteRaceReport(*) {
			reports.deleteRace()
		}

		closeReports(*) {
			ExitApp(0)
		}

		raceReportsGui := Window({Descriptor: "Race Reports", Resizeable: true, Closeable: true})

		this.iWindow := raceReportsGui

		raceReportsGui.SetFont("s10 Bold", "Arial")

		raceReportsGui.Add("Text", "w1184 Center H:Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(raceReportsGui, "Race Reports"))

		raceReportsGui.SetFont("s9 Norm", "Arial")

		raceReportsGui.Add("Documentation", "x508 YP+20 w184 Center H:Center", translate("Race Reports")
						 , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports")

		raceReportsGui.Add("Text", "x8 yp+30 w1200 0x10 W:Grow")

		raceReportsGui.SetFont("s8 Norm", "Arial")

		raceReportsGui.Add("Text", "x16 yp+10 w70 h23 +0x200 Section", translate("Simulator"))

		simulators := this.getSimulators()

		simulator := ((simulators.Length > 0) ? 1 : 0)

		raceReportsGui.Add("DropDownList", "x90 yp w180 W:Grow(0.25) Choose" . simulator . " vsimulatorDropDown", simulators).OnEvent("Change", chooseSimulator)

		if (simulator > 0)
			simulator := simulators[simulator]
		else
			simulator := false

		raceReportsGui.Add("Text", "x16 yp+24 w70 h23 +0x200", translate("Car"))
		raceReportsGui.Add("DropDownList", "x90 yp w180 W:Grow(0.25) vcarDropDown").OnEvent("Change", chooseCar)

		raceReportsGui.Add("Text", "x16 yp24 w70 h23 +0x200", translate("Track"))
		raceReportsGui.Add("DropDownList", "x90 yp w180 W:Grow(0.25) vtrackDropDown").OnEvent("Change", chooseTrack)

		raceReportsGui.Add("Text", "x16 yp+26 w70 h23 +0x200", translate("Races"))

		this.iRacesListView := raceReportsGui.Add("ListView", "x90 yp-2 w180 h252 W:Grow(0.25) H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Date", "Time", "Duration", "Starting Grid"], translate))
		this.iRacesListView.OnEvent("Click", chooseRace)
		this.iRacesListView.OnEvent("DoubleClick", chooseRace)
		this.iRacesListView.OnEvent("ItemSelect", selectRace)

		raceReportsGui.Add("Button", "x62 yp+205 w23 h23 Y:Move vreloadReportsButton").OnEvent("Click", reloadRaceReports)
		setButtonIcon(raceReportsGui["reloadReportsButton"], kIconsDirectory . "Renew.ico", 1)

		raceReportsGui.Add("Button", "x62 yp+24 w23 h23 Y:Move vdeleteReportButton").OnEvent("Click", deleteRaceReport)
		setButtonIcon(raceReportsGui["deleteReportButton"], kIconsDirectory . "Minus.ico", 1)

		raceReportsGui.Add("Text", "x16 yp+30 w70 h23 Y:Move +0x200", translate("Info"))
		raceReportsGui.Add("HTMLViewer", "x90 yp-2 w180 h170 Y:Move W:Grow(0.25) Border vinfoViewer")

		raceReportsGui.Add("Text", "x290 ys w40 h23 +0x200 X:Move(0.25)", translate("Report"))
		raceReportsGui.Add("DropDownList", "x334 yp w120 X:Move(0.25) Disabled Choose0 vreportsDropDown", collect(kRaceReports, translate)).OnEvent("Change", chooseReport)

		raceReportsGui.Add("Button", "x1177 yp w23 h23 X:Move vreportSettingsButton").OnEvent("Click", reportSettings)
		setButtonIcon(raceReportsGui["reportSettingsButton"], kIconsDirectory . "Report Settings.ico", 1)

		raceReportsGui.Add("HTMLViewer", "x290 yp+24 w910 h475 X:Move(0.25) W:Grow(0.75) H:Grow Border vchartViewer")

		this.iReportViewer := RaceReportViewer(raceReportsGui, raceReportsGui["chartViewer"], raceReportsGui["infoViewer"])

		this.loadSimulator(simulator, true)

		/*
		raceReportsGui.Add("Text", "x8 y574 w1200 0x10 Y:Move W:Grow")

		raceReportsGui.Add("Button", "x574 y580 w80 h23 H:Center Y:Move", translate("Close")).OnEvent("Click", closeReports)
		*/

		raceReportsGui.Add(RaceReports.ReportResizer(raceReportsGui))
	}

	show() {
		local window := this.Window
		local x, y, w, h

		if getWindowPosition("Race Reports", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show()

		if getWindowSize("Race Reports", &w, &h)
			window.Resize("Initialize", w, h)
	}

	showOverviewReport(reportDirectory) {
		if reportDirectory {
			this.Control["reportSettingsButton"].Enabled := true
			this.Control["reportsDropDown"].Choose(inList(kRaceReports, "Overview"))

			this.iSelectedReport := "Overview"
		}
		else {
			this.Control["reportsDropDown"].Choose(0)

			this.iSelectedReport := false
		}

		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showOverviewReport()
	}

	editOverviewReportSettings(reportDirectory) {
		this.ReportViewer.setReport(reportDirectory)

		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showCarReport(reportDirectory) {
		if reportDirectory {
			this.Control["reportsDropDown"].Choose(inList(kRaceReports, "Car"))

			this.iSelectedReport := "Car"
		}
		else {
			this.Control["reportsDropDown"].Choose(0)

			this.iSelectedReport := false
		}

		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showCarReport()
	}

	showDriverReport(reportDirectory) {
		if reportDirectory {
			this.Control["reportSettingsButton"].Enabled := true
			this.Control["reportsDropDown"].Choose(inList(kRaceReports, "Drivers"))

			this.iSelectedReport := "Drivers"
		}
		else {
			this.Control["reportsDropDown"].Choose(0)

			this.iSelectedReport := false
		}

		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showDriverReport()
	}

	editDriverReportSettings(reportDirectory) {
		this.ReportViewer.setReport(reportDirectory)

		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Drivers", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showPositionsReport(reportDirectory) {
		if reportDirectory {
			this.Control["reportSettingsButton"].Enabled := true
			this.Control["reportsDropDown"].Choose(inList(kRaceReports, "Positions"))

			this.iSelectedReport := "Positions"
		}
		else {
			this.Control["reportsDropDown"].Choose(0)

			this.iSelectedReport := false
		}

		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showPositionsReport()
	}

	editPositionsReportSettings(reportDirectory) {
		this.ReportViewer.setReport(reportDirectory)

		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showLapTimesReport(reportDirectory) {
		if reportDirectory {
			this.Control["reportSettingsButton"].Enabled := true
			this.Control["reportsDropDown"].Choose(inList(kRaceReports, "Lap Times"))

			this.iSelectedReport := "Lap Times"
		}
		else {
			this.Control["reportsDropDown"].Choose(0)

			this.iSelectedReport := false
		}

		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showLapTimesReport()
	}

	editLapTimesReportSettings(reportDirectory) {
		this.ReportViewer.setReport(reportDirectory)

		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Cars", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showConsistencyReport(reportDirectory) {
		if reportDirectory {
			this.Control["reportSettingsButton"].Enabled := true
			this.Control["reportsDropDown"].Choose(inList(kRaceReports, "Consistency"))

			this.iSelectedReport := "Consistency"
		}
		else {
			this.Control["reportsDropDown"].Choose(0)

			this.iSelectedReport := false
		}

		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showConsistencyReport()
	}

	editConsistencyReportSettings(reportDirectory) {
		this.ReportViewer.setReport(reportDirectory)

		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Cars", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showPaceReport(reportDirectory) {
		if reportDirectory {
			this.Control["reportSettingsButton"].Enabled := true
			this.Control["reportsDropDown"].Choose(inList(kRaceReports, "Pace"))

			this.iSelectedReport := "Pace"
		}
		else {
			this.Control["reportsDropDown"].Choose(0)

			this.iSelectedReport := false
		}

		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showPaceReport()
	}

	editPaceReportSettings(reportDirectory) {
		this.ReportViewer.setReport(reportDirectory)

		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Cars", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showPerformanceReport(reportDirectory) {
		if reportDirectory {
			this.Control["reportSettingsButton"].Enabled := true
			this.Control["reportsDropDown"].Choose(inList(kRaceReports, "Performance"))

			this.iSelectedReport := "Performance"
		}
		else {
			this.Control["reportsDropDown"].Choose(0)

			this.iSelectedReport := false
		}

		this.ReportViewer.setReport(reportDirectory)
		this.ReportViewer.showPerformanceReport()
	}

	editPerformanceReportSettings(reportDirectory) {
		this.ReportViewer.setReport(reportDirectory)

		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Cars", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	getSimulators() {
		local simulators := []
		local ignore, simulator, hasReports

		for ignore, simulator in this.SessionDatabase.getSimulators() {
			hasReports := false

			loop Files, this.Database . "\" . this.SessionDatabase.getSimulatorCode(simulator) . "\*.*", "D" {
				hasReports := true

				break
			}

			if hasReports
				simulators.Push(simulator)
		}

		return simulators
	}

	getCars(simulator) {
		local database := this.Database
		local result := []

		simulator := this.SessionDatabase.getSimulatorCode(simulator)

		loop Files, database . "\" . simulator . "\*.*", "D"
			result.Push(A_LoopFileName)

		return result
	}

	getTracks(simulator, car) {
		local database := this.Database
		local sessionDB := this.SessionDatabase
		local result := []

		simulator := sessionDB.getSimulatorCode(simulator)
		car := sessionDB.getCarCode(simulator, car)

		loop Files, database . "\" . simulator . "\" . car . "\*.*", "D"
			result.Push(A_LoopFileName)

		return result
	}

	getReports(simulator, car, track) {
		local database := this.Database
		local sessionDB := this.SessionDatabase
		local reports := []

		simulator := sessionDB.getSimulatorCode(simulator)
		car := sessionDB.getCarCode(simulator, car)
		track := sessionDB.getTrackCode(simulator, track)

		loop Files, database . "\" . simulator . "\" . car . "\" . track . "\*.*", "D"
			reports.Push(A_LoopFilePath)

		return reports
	}

	loadSimulator(simulator, force := false) {
		local window, sessionDB, cars, carNames, index, car

		if (force || (simulator != this.SelectedSimulator)) {
			window := this.Window

			this.iSelectedSimulator := simulator

			sessionDB := this.SessionDatabase

			cars := this.getCars(simulator)
			carNames := cars.Clone()

			for index, car in cars
				carNames[index] := sessionDB.getCarName(simulator, car)

			this.Control["simulatorDropDown"].Choose(inList(this.getSimulators(), simulator))

			this.Control["carDropDown"].Delete()
			this.Control["carDropDown"].Add(carNames)

			this.loadCar((cars.Length > 0) ? cars[1] : false, true)
		}
	}

	loadCar(car, force := false) {
		local tracks

		if (force || (car != this.SelectedCar)) {
			this.iSelectedCar := car

			tracks := this.getTracks(this.SelectedSimulator, car)

			this.Control["carDropDown"].Choose(inList(this.getCars(this.SelectedSimulator), car))

			this.Control["trackDropDown"].Delete()
			this.Control["trackDropDown"].Add(collect(tracks, ObjBindMethod(this.SessionDatabase, "getTrackName", this.SelectedSimulator)))

			this.loadTrack((tracks.Length > 0) ? tracks[1] : false, true)
		}
	}

	loadTrack(track, force := false) {
		local simulator, ignore, report, fileName, raceData, date, time, settings

		if (force || (track != this.SelectedTrack)) {
			simulator := this.SelectedSimulator

			this.iSelectedTrack := track
			this.iAvailableRaces := []
			this.iSelectedRace := false
			this.iSelectedReport := false

			this.Control["trackDropDown"].Choose(inList(this.getTracks(simulator, this.SelectedCar), track))
			this.Control["reportsDropDown"].Enabled := false
			this.Control["reportSettingsButton"].Enabled := false
			this.Control["reportsDropDown"].Choose(0)

			this.Control["deleteReportButton"].Enabled := false

			if track
				this.Control["reloadReportsButton"].Enabled := true
			else
				this.Control["reloadReportsButton"].Enabled := false

			this.ReportViewer.showReportChart(false)
			this.ReportViewer.showReportInfo(false)

			this.RacesListView.Delete()

			if track {
				for ignore, report in this.getReports(simulator, this.SelectedCar, track) {
					SplitPath(report, &fileName)

					date := FormatTime(fileName, "ShortDate")
					time := FormatTime(fileName, "HH:mm")

					raceData := readMultiMap(report . "\Race.data")

					if ((getMultiMapValue(raceData, "Session", "Car") = this.SelectedCar) && (getMultiMapValue(raceData, "Session", "Track") = track)) {
						this.AvailableRaces.Push(fileName)

						this.RacesListView.Add("", date, time, Round(getMultiMapValue(raceData, "Session", "Duration") / 60), getMultiMapValue(raceData, "Cars", "Count"))
					}
				}

				this.RacesListView.ModifyCol(1, "AutoHdr")
				this.RacesListView.ModifyCol(2, "AutoHdr")
				this.RacesListView.ModifyCol(3, "AutoHdr")
				this.RacesListView.ModifyCol(4, "AutoHdr")

				settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

				setMultiMapValue(settings, "Race Reports", "Simulator", this.SelectedSimulator)
				setMultiMapValue(settings, "Race Reports", "Car", this.SelectedCar)
				setMultiMapValue(settings, "Race Reports", "Track", this.SelectedTrack)

				writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)
			}
		}
	}

	loadRace(raceNr) {
		if (raceNr != this.SelectedRace) {
			this.Settings := CaseInsenseMap()

			if raceNr {
				this.Control["reportsDropDown"].Enabled := true
				this.Control["reportsDropDown"].Choose(inList(kRaceReports, "Overview"))
				this.Control["deleteReportButton"].Enabled := true

				this.iSelectedRace := raceNr
				this.iSelectedReport := false

				this.loadReport("Overview")
			}
			else {
				this.Control["reportsDropDown"].Enabled := false
				this.Control["reportSettingsButton"].Enabled := false
				this.Control["reportsDropDown"].Choose(0)
				this.Control["deleteReportButton"].Enabled := false

				this.iSelectedRace := false

				this.ReportViewer.showReportChart(false)
				this.ReportViewer.showReportInfo(false)
			}
		}
	}

	deleteRace() {
		local raceDirectory, simulators, window, prefix, simulator, car, track, msgResult

		OnMessage(0x44, translateYesNoButtons)
		msgResult := withBlockedWindows(MsgBox, translate("Do you really want to delete the selected report?"), translate("Delete"), 262436)
		OnMessage(0x44, translateYesNoButtons, 0)

		if (msgResult = "Yes") {
			simulator := this.SessionDatabase.getSimulatorCode(this.SelectedSimulator)
			car := this.SessionDatabase.getCarCode(this.SelectedSimulator, this.SelectedCar)
			track := this.SessionDatabase.getTrackCode(this.SelectedSimulator, this.SelectedTrack)

			prefix := (this.Database . "\" . simulator . "\")

			deleteDirectory(prefix . car . "\" . track . "\" . this.AvailableRaces[this.SelectedRace])
			deleteDirectory(prefix . car . "\" . track, true, false)
			deleteDirectory(prefix . car, true, false)

			if (this.getReports(this.SelectedSimulator, this.SelectedCar, this.SelectedTrack).Length > 0)
				this.loadTrack(this.SelectedTrack, true)
			else {
				if (this.getTracks(this.SelectedSimulator, this.SelectedCar).Length > 0)
					this.loadCar(this.SelectedCar, true)
				else {
					simulators := this.getSimulators()

					if inList(simulators, this.SelectedSimulator)
						this.loadSimulator(this.SelectedSimulator, true)
					else {
						this.Control["simulatorDropDown"].Delete()
						this.Control["simulatorDropDown"].Add(simulators)

						if (simulators.Length > 0)
							this.loadSimulator(simulators[1], true)
						else
							this.Control["simulatorDropDown"].Choose(0)
					}
				}
			}
		}
	}

	loadReport(report, force := false) {
		local reportDirectory, raceData, drivers, simulator, car, track

		if (force || (report != this.SelectedReport)) {
			if report {
				this.iSelectedReport := report

				this.Control["reportsDropDown"].Choose(inList(kRaceReports, report))
				this.Control["reportSettingsButton"].Enabled := false

				simulator := this.SessionDatabase.getSimulatorCode(this.SelectedSimulator)
				car := this.SessionDatabase.getCarCode(this.SelectedSimulator, this.SelectedCar)
				track := this.SessionDatabase.getTrackCode(this.SelectedSimulator, this.SelectedTrack)

				reportDirectory := (this.Database . "\" . simulator . "\" . car . "\" . track . "\" . this.AvailableRaces[this.SelectedRace])

				switch report, false {
					case "Overview":
						this.showOverviewReport(reportDirectory)
					case "Car":
						this.showCarReport(reportDirectory)
					case "Drivers":
						if !this.ReportViewer.Settings.Has("Drivers") {
							raceData := true
							ignore := false

							this.ReportViewer.loadReportData(false, &raceData, &ignore, &ignore, &ignore)

							drivers := []

							loop Min(5, getMultiMapValue(raceData, "Cars", "Count"))
								drivers.Push(A_Index)

							this.ReportViewer.Settings["Drivers"] := drivers
						}

						this.showDriverReport(reportDirectory)
					case "Positions":
						this.showPositionsReport(reportDirectory)
					case "Lap Times":
						this.showLapTimesReport(reportDirectory)
					case "Consistency":
						if !this.ReportViewer.Settings.Has("Drivers") {
							raceData := true
							ignore := false

							this.ReportViewer.loadReportData(false, &raceData, &ignore, &ignore, &ignore)

							drivers := []

							loop Min(5, getMultiMapValue(raceData, "Cars", "Count"))
								drivers.Push(A_Index)

							this.ReportViewer.Settings["Drivers"] := drivers
						}

						this.showConsistencyReport(reportDirectory)
					case "Pace":
						this.showPaceReport(reportDirectory)
					case "Performance":
						this.showPerformanceReport(reportDirectory)
				}
			}
			else {
				this.Control["reportsDropDown"].Choose(0)

				this.iSelectedReport := false

				this.ReportViewer.showReportChart(false)
				this.ReportViewer.showReportInfo(false)
			}
		}
	}

	reportSettings(report) {
		local simulator := this.SessionDatabase.getSimulatorCode(this.SelectedSimulator)
		local car := this.SessionDatabase.getCarCode(this.SelectedSimulator, this.SelectedCar)
		local track := this.SessionDatabase.getTrackCode(this.SelectedSimulator, this.SelectedTrack)
		local reportDirectory := (this.Database . "\" . simulator . "\" . car . "\" . track . "\" . this.AvailableRaces[this.SelectedRace])

		switch report, false {
			case "Overview":
				if this.editOverviewReportSettings(reportDirectory)
					this.showOverviewReport(reportDirectory)
			case "Drivers":
				if this.editDriverReportSettings(reportDirectory)
					this.showDriverReport(reportDirectory)
			case "Positions":
				if this.editPositionsReportSettings(reportDirectory)
					this.showPositionsReport(reportDirectory)
			case "Lap Times":
				if this.editLapTimesReportSettings(reportDirectory)
					this.showLapTimesReport(reportDirectory)
			case "Consistency":
				if this.editConsistencyReportSettings(reportDirectory)
					this.showConsistencyReport(reportDirectory)
			case "Pace":
				if this.editPaceReportSettings(reportDirectory)
					this.showPaceReport(reportDirectory)
			case "Performance":
				if this.editPerformanceReportSettings(reportDirectory)
					this.showPerformanceReport(reportDirectory)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

startupRaceReports() {
	local icon := kIconsDirectory . "Chart.ico"
	local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")
	local simulator := getMultiMapValue(settings, "Race Reports", "Simulator", false)
	local car := getMultiMapValue(settings, "Race Reports", "Car", false)
	local track := getMultiMapValue(settings, "Race Reports", "Track", false)
	local reportsDirectory := getMultiMapValue(kSimulatorConfiguration, "Race Strategist Reports", "Database", false)
	local index := 1
	local reports, simulators, cars, tracks, msgResult

	TraySetIcon(icon, "1")
	A_IconTip := "Race Reports"

	try {
		while (index < A_Args.Length) {
			switch A_Args[index], false {
				case "-Simulator":
					simulator := A_Args[index + 1]
					index += 2
				case "-Car":
					car := A_Args[index + 1]
					index += 2
				case "-Track":
					track := A_Args[index + 1]
					index += 2
				default:
					index += 1
			}
		}

		if !reportsDirectory {
			OnMessage(0x44, translateYesNoButtons)
			msgResult := withBlockedWindows(MsgBox, translate("The Reports folder has not been configured yet. Do you want to start the Configuration tool now?"), translate("Configuration"), 262436)
			OnMessage(0x44, translateYesNoButtons, 0)

			if (msgResult = "Yes")
				Run(kBinariesDirectory . "Simulator Configuration.exe")

			ExitApp(0)
		}

		reports := RaceReports(reportsDirectory, kSimulatorConfiguration)

		reports.show()

		simulators := reports.getSimulators()

		if (simulators.Length > 0) {
			simulator := (inList(simulators, simulator) ? simulator : simulators[1])

			reports.loadSimulator(simulator)

			cars := reports.getCars(simulator)

			if (cars.Length > 0) {
				if car
					car := SessionDatabase.getCarCode(simulator, car)

				car := (inList(cars, car) ? car : cars[1])

				reports.loadCar(car)

				tracks := reports.getTracks(simulator, car)

				if (tracks.Length > 0) {
					if track
						track := SessionDatabase.getTrackCode(simulator, track)

					track := (inList(tracks, track) ? track : tracks[1])

					reports.loadTrack(track)
				}
			}
		}

		startupApplication()
	}
	catch Any as exception {
		logError(exception, true)

		OnMessage(0x44, translateOkButton)
		withBlockedWindows(MsgBox, substituteVariables(translate("Cannot start %application% due to an internal error..."), {application: "Race Reports"}), translate("Error"), 262160)
		OnMessage(0x44, translateOkButton, 0)

		ExitApp(1)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

startupRaceReports()