;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Practice Center Tool            ;;;
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

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Practice.ico
;@Ahk2Exe-ExeName Practice Center.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Libraries\HTMLViewer.ahk"
#Include "..\Libraries\Messages.ahk"
#Include "..\Libraries\Math.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Database\Libraries\SettingsDatabase.ahk"
#Include "..\Database\Libraries\TyresDatabase.ahk"
#Include "..\Database\Libraries\TelemetryDatabase.ahk"
#Include "Libraries\RaceReportViewer.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                   Private Constant Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kClose := "Close"
global kSave := "Save"
global kEvent := "Event"

global kSessionReports := concatenate(kRaceReports, ["Running", "Pressures", "Temperatures", "Brakes", "Free"])
global kDetailReports := ["Run", "Lap", "Session", "Drivers"]

global kSessionDataSchemas := CaseInsenseMap("Run.Data", ["Nr", "Lap", "Driver.Forname", "Driver.Surname", "Driver.Nickname", "Driver.ID"
													    , "Weather", "Tyre.Compound", "Tyre.Compound.Color", "Tyre.Set", "Tyre.Laps"
														, "Lap.Time.Average", "Lap.Time.Best"
														, "Fuel.Initial", "Fuel.Consumption", "Accidents"
														, "Position.Start", "Position.End", "Time.Start", "Time.End"]
										   , "Driver.Data", ["Forname", "Surname", "Nickname", "ID"]
										   , "Lap.Data", ["Run", "Nr", "Lap", "Position", "Lap.Time", "Lap.State", "Lap.Valid", "Grip", "Map", "TC", "ABS"
														, "Weather", "Temperature.Air", "Temperature.Track"
														, "Fuel.Initial", "Fuel.Remaining", "Fuel.Consumption", "Damage", "EngineDamage", "Accident"
														, "Tyre.Laps", "Tyre.Compound", "Tyre.Compound.Color", "Tyre.Set"
														, "Tyre.Pressure.Cold.Average", "Tyre.Pressure.Cold.Front.Average", "Tyre.Pressure.Cold.Rear.Average"
														, "Tyre.Pressure.Cold.Front.Left", "Tyre.Pressure.Cold.Front.Right"
														, "Tyre.Pressure.Cold.Rear.Left", "Tyre.Pressure.Cold.Rear.Right"
														, "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
														, "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right"
														, "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
														, "Tyre.Pressure.Loss.Front.Left", "Tyre.Pressure.Loss.Front.Right"
														, "Tyre.Pressure.Loss.Rear.Left", "Tyre.Pressure.Loss.Rear.Right"
														, "Tyre.Temperature.Average", "Tyre.Temperature.Front.Average", "Tyre.Temperature.Rear.Average"
														, "Tyre.Temperature.Front.Left", "Tyre.Temperature.Front.Right"
														, "Tyre.Temperature.Rear.Left", "Tyre.Temperature.Rear.Right"
														, "Tyre.Wear.Average", "Tyre.Wear.Front.Average", "Tyre.Wear.Rear.Average"
														, "Tyre.Wear.Front.Left", "Tyre.Wear.Front.Right"
														, "Tyre.Wear.Rear.Left", "Tyre.Wear.Rear.Right"
														, "Brake.Temperature.Average", "Brake.Temperature.Front.Average", "Brake.Temperature.Rear.Average"
														, "Brake.Temperature.Front.Left", "Brake.Temperature.Front.Right"
														, "Brake.Temperature.Rear.Left", "Brake.Temperature.Rear.Right"
														, "Brake.Wear.Average", "Brake.Wear.Front.Average", "Brake.Wear.Rear.Average"
														, "Brake.Wear.Front.Left", "Brake.Wear.Front.Right"
														, "Brake.Wear.Rear.Left", "Brake.Wear.Rear.Right"
														, "Data.Telemetry", "Data.Pressures"]
										   , "Delta.Data", ["Lap", "Car", "Type", "Delta", "Distance", "ID"]
										   , "Standings.Data", ["Lap", "Car", "Driver", "Position", "Time", "Laps", "Delta", "ID", "Category"])

global kPCTyresSchemas := kTyresSchemas.Clone()

kPCTyresSchemas["Tyres.Pressures"] := concatenate(kPCTyresSchemas["Tyres.Pressures"].Clone()
												, ["Tyre.Pressure.Loss.Front.Left", "Tyre.Pressure.Loss.Front.Right"
												 , "Tyre.Pressure.Loss.Rear.Left", "Tyre.Pressure.Loss.Rear.Right"])

global kFuelBuckets := [0, 15, 30, 45, 60, 75, 90, 105, 120]
global kFuelBucketSize := 15

global kTyreLapsBuckets := [5, 10, 15, 20, 25, 30, 35, 30, 35, 40, 45, 50, 55, 60]
global kTyreLapsBucketSize := 5


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                        PracticeCenterTask                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PracticeCenterTask extends Task {
	Window {
		Get {
			return PracticeCenter.Instance.Window
		}
	}

	run() {
		local pCenter := PracticeCenter.Instance

		if pCenter.startWorking() {
			try {
				super.run()

				return false
			}
			finally {
				pCenter.finishWorking()
			}
		}
		else
			return this
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                          PracticeCenter                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class PracticeCenter extends ConfigurationItem {
	iWindow := false

	iWorking := 0
	iSyncTask := false

	iSessionDirectory := false

	iSessionMode := false
	iSessionExported := false

	iDate := A_Now

	iSession := "Practice"
	iSimulator := false
	iCar := false
	iTrack := false
	iWeather := "Dry"
	iWeather10Min := "Dry"
	iWeather30Min := "Dry"
	iAirTemperature := 23
	iTrackTemperature := 27

	iRunning := Map()

	iAvailableTyreCompounds := [normalizeCompound("Dry")]
	iTyreCompounds := [normalizeCompound("Dry")]

	iUsedTyreSets := WeakMap()

	iTyreCompound := "Dry"
	iTyreCompoundColor := "Back"

	iDataWeather := "Dry"
	iDataTyreCompound := "Dry"
	iDataTyreCompoundColor := "Back"

	iUseSessionData := true
	iUseTelemetryDatabase := false

	iDrivers := []
	iRuns := CaseInsenseWeakMap()
	iLaps := CaseInsenseWeakMap()

	iPitstops := CaseInsenseMap()
	iLastPitstopUpdate := false

	iCurrentRun := false
	iLastLap := false

	iRunsListView := false
	iLapsListView := false
	iTyreCompoundsListView := false
	iUsedTyreSetsListView := false

	iFuelDataListView := false
	iTyreDataListView := false

	iSessionStore := false
	iTelemetryDatabase := false
	iPressuresDatabase := false

	iReportsListView := false
	iChartViewer := false
	iReportViewer := false
	iDetailsViewer := false
	iSelectedReport := false
	iSelectedChartType := false

	iSelectedRun := false
	iSelectedDrivers := false

	iSelectedDetailReport := false
	iSelectedDetailHTML := false

	iTasks := []

	class PracticeCenterWindow extends Window {
		iPracticeCenter := false

		PracticeCenter {
			Get {
				return this.iPracticeCenter
			}
		}

		__New(center) {
			this.iPracticeCenter := center

			super.__New({Descriptor: "Practice Center", Closeable: true, Resizeable: "Deferred"})
		}

		Close(*) {
			if (this.PracticeCenter.HasData && !this.PracticeCenter.SessionExported) {
				local translator := translateMsgBoxButtons.Bind(["Yes", "No", "Cancel"])

				OnMessage(0x44, translator)
				msgResult := MsgBox(translate("Do you want to transfer your data to the session database before closing?"), translate("Export"), 262179)
				OnMessage(0x44, translator, 0)

				if (msgResult = "Yes")
					this.PracticeCenter.exportSession(true)

				if (msgResult = "Cancel")
					return true
			}

			return super.Close()
		}
	}

	class PracticeCenterResizer extends Window.Resizer {
		iRedraw := false

		__New(arguments*) {
			super.__New(arguments*)

			Task.startTask(ObjBindMethod(this, "RedrawHTMLViwer"), 500, kLowPriority)
		}

		Resize(deltaWidth, deltaHeight) {
			this.iRedraw := true
		}

		RedrawHTMLViwer() {
			if this.iRedraw {
				local center := PracticeCenter.Instance
				local ignore, button

				for ignore, button in ["LButton", "MButton", "RButton"]
					if GetKeyState(button, "P")
						return Task.CurrentTask

				this.iRedraw := false

				center.ChartViewer.Resized()
				center.DetailsViewer.Resized()

				center.pushTask(ObjBindMethod(PracticeCenter.Instance, "updateReports", true))
			}

			return Task.CurrentTask
		}
	}

	class SessionTelemetryDatabase extends TelemetryDatabase {
		iPracticeCenter := false
		iTelemetryDatabase := false

		PracticeCenter {
			Get {
				return this.iPracticeCenter
			}
		}

		TelemetryDatabase {
			Get {
				return this.iTelemetryDatabase
			}
		}

		__New(practiceCenter, simulator := false, car := false, track := false) {
			this.iPracticeCenter := practiceCenter

			super.__New()

			this.Shared := false

			this.setDatabase(Database(practiceCenter.SessionDirectory, kTelemetrySchemas))

			if simulator
				this.iTelemetryDatabase := TelemetryDatabase(simulator, car, track)
		}

		setDrivers(drivers) {
			super.setDrivers(drivers)

			if this.TelemetryDatabase
				this.TelemetryDatabase.setDrivers(drivers)
		}

		getMapData(weather, tyreCompound, tyreCompoundColor) {
			local entries := []
			local newEntries, ignore, entry, ignore, entry, found, candidate, lastLap, result

			if this.PracticeCenter.UseSessionData
				for ignore, entry in super.getMapData(weather, tyreCompound, tyreCompoundColor)
					if ((entry["Fuel.Consumption"] > 0) && (entry["Lap.Time"] > 0))
						entries.Push(entry)

			if (this.PracticeCenter.UseTelemetryDatabase && this.TelemetryDatabase) {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getMapData(weather, tyreCompound, tyreCompoundColor) {
					if ((entry["Fuel.Consumption"] > 0) && (entry["Lap.Time"] > 0)) {
						found := false

						for ignore, candidate in entries
							if ((candidate["Map"] = entry["Map"]) && (candidate["Lap.Time"] = entry["Lap.Time"])
																  && (candidate["Fuel.Consumption"] = entry["Fuel.Consumption"])) {
								found := true

								break
							}

						if !found
							newEntries.Push(entry)
					}
				}

				for ignore, entry in newEntries
					entries.Push(entry)
			}

			return entries
		}

		getTyreData(weather, tyreCompound, tyreCompoundColor) {
			local entries := []
			local newEntries, ignore, entry, found, candidate

			if this.PracticeCenter.UseSessionData
				for ignore, entry in super.getTyreData(weather, tyreCompound, tyreCompoundColor)
					if (entry["Lap.Time"] > 0)
						entries.Push(entry)

			if (this.PracticeCenter.UseTelemetryDatabase && this.TelemetryDatabase) {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getTyreData(weather, tyreCompound, tyreCompoundColor) {
					if (entry["Lap.Time"] > 0) {
						found := false

						for ignore, candidate in entries
							if ((candidate["Tyre.Laps"] = entry["Tyre.Laps"]) && (candidate["Lap.Time"] = entry["Lap.Time"])) {
								found := true

								break
							}

						if !found
							newEntries.Push(entry)
					}
				}

				for ignore, entry in newEntries
					entries.Push(entry)
			}

			return entries
		}

		getMapLapTimes(weather, tyreCompound, tyreCompoundColor) {
			local entries := []
			local newEntries, ignore, entry, found, candidate, lastLap, result

			if this.PracticeCenter.UseSessionData
				for ignore, entry in super.getMapLapTimes(weather, tyreCompound, tyreCompoundColor)
					if (entry["Lap.Time"] > 0)
						entries.Push(entry)

			if (this.PracticeCenter.UseTelemetryDatabase && this.TelemetryDatabase) {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getMapLapTimes(weather, tyreCompound, tyreCompoundColor) {
					if (entry["Lap.Time"] > 0) {
						found := false

						for ignore, candidate in entries
							if ((candidate["Map"] = entry["Map"]) && (candidate["Fuel.Remaining"] = entry["Fuel.Remaining"])
																  && (candidate["Lap.Time"] = entry["Lap.Time"])) {
								found := true

								break
							}

						if !found
							newEntries.Push(entry)
					}
				}

				for ignore, entry in newEntries
					entries.Push(entry)
			}

			return entries
		}

		getTyreLapTimes(weather, tyreCompound, tyreCompoundColor, withFuel := false) {
			local entries := []
			local newEntries, ignore, entry, found, candidate

			if this.PracticeCenter.UseSessionData
				for ignore, entry in super.getTyreLapTimes(weather, tyreCompound, tyreCompoundColor, withFuel)
					if (entry["Lap.Time"] > 0)
						entries.Push(entry)

			if (this.PracticeCenter.UseTelemetryDatabase && this.TelemetryDatabase) {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getTyreLapTimes(weather, tyreCompound, tyreCompoundColor, withFuel) {
					if (entry["Lap.Time"] > 0) {
						found := false

						for ignore, candidate in entries
							if ((candidate["Tyre.Laps"] = entry["Tyre.Laps"]) && (candidate["Lap.Time"] = entry["Lap.Time"])) {
								found := true

								break
							}

						if !found
							newEntries.Push(entry)
					}
				}

				for ignore, entry in newEntries
					entries.Push(entry)
			}

			return entries
		}
	}

	class SessionPressuresDatabase {
		iDatabase := false

		Database {
			Get {
				return this.iDatabase
			}
		}

		__New(pCenter) {
			this.iDatabase := Database(pCenter.SessionDirectory, kPCTyresSchemas)
		}

		updatePressures(weather, airTemperature, trackTemperature, tyreCompound, tyreCompoundColor, coldPressures, hotPressures, pressuresLosses, driver) {
			local tyres, types, typeIndex, tPressures, tyreIndex, pressure

			if (!tyreCompoundColor || (tyreCompoundColor = ""))
				tyreCompoundColor := "Black"

			this.Database.add("Tyres.Pressures",
							  Database.Row("Weather", weather, "Temperature.Air", airTemperature, "Temperature.Track", trackTemperature
										 , "Compound", tyreCompound, "Compound.Color", tyreCompoundColor, "Driver", driver
										 , "Tyre.Pressure.Cold.Front.Left", null(coldPressures[1])
										 , "Tyre.Pressure.Cold.Front.Right", null(coldPressures[2])
										 , "Tyre.Pressure.Cold.Rear.Left", null(coldPressures[3])
										 , "Tyre.Pressure.Cold.Rear.Right", null(coldPressures[4])
										 , "Tyre.Pressure.Hot.Front.Left", null(hotPressures[1])
										 , "Tyre.Pressure.Hot.Front.Right", null(hotPressures[2])
										 , "Tyre.Pressure.Hot.Rear.Left", null(hotPressures[3])
										 , "Tyre.Pressure.Hot.Rear.Right", null(hotPressures[4])
										 , "Tyre.Pressure.Loss.Front.Left", null(pressuresLosses[1])
										 , "Tyre.Pressure.Loss.Front.Right", null(pressuresLosses[2])
										 , "Tyre.Pressure.Loss.Rear.Left", null(pressuresLosses[3])
										 , "Tyre.Pressure.Loss.Rear.Right", null(pressuresLosses[4]))
							, true)

			tyres := ["FL", "FR", "RL", "RR"]
			types := ["Cold", "Hot"]

			for typeIndex, tPressures in [coldPressures, hotPressures]
				for tyreIndex, pressure in tPressures
					this.updatePressure(weather, airTemperature, trackTemperature, tyreCompound, tyreCompoundColor
									  , types[typeIndex], tyres[tyreIndex], pressure, 1, driver, true)
		}

		updatePressure(weather, airTemperature, trackTemperature, tyreCompound, tyreCompoundColor
					 , type, tyre, pressure, count, driver, flush) {
			local rows

			if isNull(null(pressure))
				return

			if (!tyreCompoundColor || (tyreCompoundColor = ""))
				tyreCompoundColor := "Black"

			rows := this.Database.query("Tyres.Pressures.Distribution"
									  , {Where: CaseInsenseMap("Weather", weather, "Temperature.Air", airTemperature, "Temperature.Track", trackTemperature
															 , "Driver", driver, "Compound", tyreCompound, "Compound.Color", tyreCompoundColor
															 , "Type", type, "Tyre", tyre, "Pressure", pressure)})

			if (rows.Length > 0)
				rows[1]["Count"] := rows[1]["Count"] + count
			else
				this.Database.add("Tyres.Pressures.Distribution"
								, Database.Row("Weather", weather, "Temperature.Air", airTemperature, "Temperature.Track", trackTemperature
											 , "Driver", driver, "Compound", tyreCompound, "Compound.Color", tyreCompoundColor
											 , "Type", type, "Tyre", tyre, "Pressure", pressure, "Count", count)
								, flush)
		}
	}

	class Pitstop {
		iID := false

		iTime := false
		iLap := 0
		iDuration := 0

		ID {
			Get {
				return this.iID
			}
		}

		Time {
			Get {
				return this.iTime
			}
		}

		Lap {
			Get {
				return this.iLap
			}
		}

		Duration {
			Get {
				return this.iDuration
			}

			Set {
				return (this.iDuration := value)
			}
		}

		__New(id, time, lap) {
			this.iID := id
			this.iTime := time
			this.iLap := lap
		}
	}

	Window {
		Get {
			return this.iWindow
		}
	}

	Control[name] {
		Get {
			return this.Window[name]
		}
	}

	SessionDirectory {
		Get {
			if this.SessionActive
				return this.iSessionDirectory
			else if (this.SessionMode = "Loaded")
				return this.SessionLoaded
			else
				return this.iSessionDirectory
		}
	}

	SessionMode {
		Get {
			return this.iSessionMode
		}
	}

	SessionActive {
		Get {
			return (this.SessionMode = "Active")
		}
	}

	SessionExported {
		Get {
			return this.iSessionExported
		}
	}

	SessionLoaded {
		Get {
			return ((this.SessionMode = "Loaded") ? this.iSessionLoaded : false)
		}
	}

	HasData {
		Get {
			return (this.SessionMode && this.CurrentRun && this.LastLap)
		}
	}

	Date {
		Get {
			return this.iDate
		}
	}

	Session {
		Get {
			return this.iSession
		}
	}

	Simulator {
		Get {
			return this.iSimulator
		}
	}

	Car {
		Get {
			return this.iCar
		}
	}

	Track {
		Get {
			return this.iTrack
		}
	}

	Weather[type := "Run"] {
		Get {
			return ((type = "Run") ? this.iWeather : this.iDataWeather)
		}
	}

	Weather10Min {
		Get {
			return this.iWeather10Min
		}
	}

	Weather30Min {
		Get {
			return this.iWeather30Min
		}
	}

	AirTemperature {
		Get {
			return this.iAirTemperature
		}
	}

	TrackTemperature {
		Get {
			return this.iTrackTemperature
		}
	}

	AvailableTyreCompounds {
		Get {
			return this.iAvailableTyreCompounds
		}
	}

	TyreCompounds[key?] {
		Get {
			return (isSet(key) ? this.iTyreCompounds[key] : this.iTyreCompounds)
		}
	}

	UsedTyreSets[key?] {
		Get {
			return (isSet(key) ? this.iUsedTyreSets[key] : this.iUsedTyreSets)
		}
	}

	TyreCompound[type := "Run"] {
		Get {
			return ((type = "Run") ? this.iTyreCompound : this.iDataTyreCompound)
		}
	}

	TyreCompoundColor[type := "Run"] {
		Get {
			return ((type = "Run") ? this.iTyreCompoundColor : this.iDataTyreCompoundColor)
		}
	}

	UseSessionData {
		Get {
			return this.iUseSessionData
		}

		Set {
			return (this.iUseSessionData := value)
		}
	}

	UseTelemetryDatabase {
		Get {
			return this.iUseTelemetryDatabase
		}

		Set {
			return (this.iUseTelemetryDatabase := value)
		}
	}

	Drivers {
		Get {
			return this.iDrivers
		}
	}

	Runs[key?] {
		Get {
			return (isSet(key) ? this.iRuns[key] : this.iRuns)
		}

		Set {
			return (isSet(key) ? (this.iRuns[key] := value) : (this.iRuns := value))
		}
	}

	CurrentRun[asNr := false] {
		Get {
			if this.iCurrentRun
				return (asNr ? this.iCurrentRun.Nr : this.iCurrentRun)
			else
				return false
		}
	}

	Laps[key?] {
		Get {
			return (isSet(key) ? this.iLaps[key] : this.iLaps)
		}

		Set {
			return (isSet(key) ? (this.iLaps[key] := value) : (this.iLaps := value))
		}
	}

	LastLap[asNr := false] {
		Get {
			if this.iLastLap
				return (asNr ? this.iLastLap.Nr : this.iLastLap)
			else
				return false
		}
	}

	Pitstops[id?] {
		Get {
			if isSet(id) {
				if !this.iPitstops.Has(id)
					this.iPitstops[id] := []

				return this.iPitstops[id]
			}
			else
				return this.iPitstops
		}
	}

	Running[key?] {
		Get {
			return (isSet(key) ? this.iRunning[key] : this.iRunning)
		}

		Set {
			return (isSet(key) ? (this.iRunning[key] := value) : (this.iRunning := value))
		}
	}

	RunsListView {
		Get {
			return this.iRunsListView
		}
	}

	LapsListView {
		Get {
			return this.iLapsListView
		}
	}

	TyreCompoundsListView {
		Get {
			return this.iTyreCompoundsListView
		}
	}

	UsedTyreSetsListView {
		Get {
			return this.iUsedTyreSetsListView
		}
	}

	FuelDataListView {
		Get {
			return this.iFuelDataListView
		}
	}

	TyreDataListView {
		Get {
			return this.iTyreDataListView
		}
	}

	SessionStore {
		Get {
			if !this.iSessionStore
				this.iSessionStore := Database(this.SessionDirectory, kSessionDataSchemas)

			return this.iSessionStore
		}
	}

	TelemetryDatabase {
		Get {
			if !this.iTelemetryDatabase
				this.iTelemetryDatabase := PracticeCenter.SessionTelemetryDatabase(this, this.Simulator, this.Car, this.Track)

			return this.iTelemetryDatabase
		}
	}

	PressuresDatabase {
		Get {
			if !this.iPressuresDatabase
				this.iPressuresDatabase := PracticeCenter.SessionPressuresDatabase(this)

			return this.iPressuresDatabase
		}
	}

	ReportsListView {
		Get {
			return this.iReportsListView
		}
	}

	ChartViewer {
		Get {
			return this.iChartViewer
		}
	}

	ReportViewer {
		Get {
			return this.iReportViewer
		}
	}

	DetailsViewer {
		Get {
			return this.iDetailsViewer
		}
	}

	SelectedRun {
		Get {
			return this.iSelectedRun
		}
	}

	SelectedDrivers {
		Get {
			return this.iSelectedDrivers
		}
	}

	SelectedReport {
		Get {
			return this.iSelectedReport
		}
	}

	SelectedChartType {
		Get {
			return this.iSelectedChartType
		}
	}

	SelectedDetailReport {
		Get {
			return this.iSelectedDetailReport
		}
	}

	__New(configuration, raceSettings, simulator := false, car := false, track := false) {
		this.iSimulator := simulator
		this.iCar := car
		this.iTrack := track

		this.iSessionDirectory := (kTempDirectory . "Sessions\Practice\")

		super.__New(configuration)

		PracticeCenter.Instance := this
	}

	createGui(configuration) {
		local center := this
		local centerGui, centerTab, x, y, width, ignore, report, choices, serverURLs, settings, button, control
		local simulator, car, track
		local x, x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11, x12, x13, xB
		local w12, w13

		noSelect(listView, *) {
			loop listView.GetCount()
				listView.Modify(A_Index, "-Select")
		}

		validateNumber(field, *) {
			field := centerGui[field]

			if !isNumber(internalValue("Float", field.Text)) {
				field.Text := (field.HasProp("ValidText") ? field.ValidText : "")

				loop 10
					SendInput("{Right}")
			}
			else
				field.ValidText := field.Text
		}

		closePracticeCenter(*) {
			ExitApp(0)
		}

		chooseSimulator(*) {
			center.loadSimulator(centerGui["simulatorDropDown"].Text)

			center.initializeSession()

			center.analyzeTelemetry()

			center.updateState()
		}

		chooseCar(*) {
			center.loadCar(this.getAvailableCars(this.Simulator)[centerGui["carDropDown"].Value])

			center.initializeSession()

			center.analyzeTelemetry()

			center.updateState()
		}

		chooseTrack(*) {
			local simulator := center.Simulator
			local tracks := center.getAvailableTracks(simulator, center.Car)
			local trackNames := collect(tracks, ObjBindMethod(SessionDatabase, "getTrackName", simulator))

			center.loadTrack(tracks[inList(trackNames, centerGui["trackDropDown"].Text)])

			center.initializeSession()

			center.analyzeTelemetry()

			center.updateState()
		}

		chooseReport(listView, line, *) {
			if center.HasData {
				if center.isWorking()
					return

				if line
					center.showReport(kSessionReports[line])
			}
			else
				loop listView.GetCount()
					listView.Modify(A_Index, "-Select")
		}

		reportSettings(*) {
			center.withExceptionhandler(ObjBindMethod(center, "reportSettings", center.SelectedReport))
		}

		chooseRunData(*) {
			center.withExceptionHandler(ObjBindMethod(center, "selectRun"
									  , (centerGui["runDropDown"].Value = 1) ? false : center.Runs[centerGui["runDropDown"].Value - 1]))
		}

		chooseDriverData(*) {
			center.withExceptionHandler(ObjBindMethod(center, "selectDriver"
									  , (centerGui["driverDropDown"].Value = 1) ? false : center.Drivers[centerGui["driverDropDown"].Value - 1]))
		}

		chooseAxis(*) {
			center.withExceptionhandler(ObjBindMethod(center, "showTelemetryReport"))
		}

		chooseChartType(*) {
			center.selectChartType(["Scatter", "Bar", "Bubble", "Line"][centerGui["chartTypeDropDown"].Value])
		}

		sessionMenu(*) {
			center.withExceptionhandler(ObjBindMethod(center, "chooseSessionMenu", centerGui["sessionMenuDropDown"].Value))
		}

		dataMenu(*) {
			center.withExceptionhandler(ObjBindMethod(center, "chooseDataMenu", centerGui["dataMenuDropDown"].Value))
		}

		runMenu(*) {
			center.withExceptionhandler(ObjBindMethod(center, "chooseRunMenu", centerGui["runMenuDropDown"].Value))
		}

		chooseRun(listView, line, *) {
			local run

			if line {
				run := center.Runs[listView.GetText(line, 1)]

				if center.SessionExported
					listView.Modify(line, "-Check")
				else if (listView.GetNext(line - 1, "C") = line) {
					for ignore, lap in run.Laps
						if (lap.State = "Valid")
							center.LapsListView.Modify(lap.Row, "Check")
				}
				else
					for ignore, lap in run.Laps
						center.LapsListView.Modify(lap.Row, "-Check")

				center.withExceptionhandler(ObjBindMethod(center, "showRunDetails", run))
			}
		}

		chooseLap(listView, line, *) {
			if line {
				if center.SessionExported
					listView.Modify(line, "-Check")

				center.withExceptionhandler(ObjBindMethod(center, "showLapDetails", center.Laps[listView.GetText(line, 1)]))
			}
		}

		updateState(*) {
			center.withExceptionhandler(ObjBindMethod(center, "updateState"))
		}

		newRun(*) {
			local lastLap := center.LastLap

			center.withExceptionhandler(ObjBindMethod(center, "newRun", lastLap ? (lastLap.Nr + 1) : 1))
		}

		importPressures(*) {
			if center.Simulator
				center.withExceptionhandler(ObjBindMethod(center, "importFromSimulation", center.Simulator))
			else {
				OnMessage(0x44, translateOkButton)
				MsgBox(translate("You must first select a simulation."), translate("Information"), 262192)
				OnMessage(0x44, translateOkButton, 0)
			}
		}

		chooseTyreCompound(listView, line, *) {
			local compound := listView.GetText(line, 1)
			local count := listView.GetText(line, 2)
			local chosen

			if line {
				if compound
					compound := normalizeCompound(compound)

				chosen := inList(collect(center.AvailableTyreCompounds, translate), compound)

				centerGui["compoundDropDown"].Choose(chosen)
				centerGui["compoundCountEdit"].Text := count
			}

			center.updateState()
		}

		updateTyreCompoundDropDown() {
			local selected := centerGui["tyreCompoundDropDown"].Text
			local compounds := []
			local choosen := 0
			local compound

			loop center.TyreCompoundsListView.GetCount() {
				compound := center.TyreCompoundsListView.GetText(A_Index, 1)
				compounds.Push(compound)

				if (compound = selected)
					choosen := A_Index
			}

			centerGui["tyreCompoundDropDown"].Delete()
			centerGui["tyreCompoundDropDown"].Add(concatenate(collect(["No change", "Auto"], translate), compounds))
			centerGui["tyreCompoundDropDown"].Choose(choosen + 2)

			center.updateState()
		}

		updateTyreCompound(*) {
			local row := center.TyreCompoundsListView.GetNext(0)
			local availableCompounds, compound, usedCompounds, index, candidate

			if (row > 0) {
				availableCompounds := collect(center.AvailableTyreCompounds, translate)
				compound := availableCompounds[centerGui["compoundDropDown"].Value]
				usedCompounds := []

				loop center.TyreCompoundsListView.GetCount()
					if (A_Index != row)
						usedCompounds.Push(center.TyreCompoundsListView.GetText(A_Index, 1))

				if inList(usedCompounds, compound)
					for index, candidate in availableCompounds
						if !inList(usedCompounds, candidate) {
							compound := candidate

							centerGui["compoundDropDown"].Choose(index)

							break
						}

				center.TyreCompoundsListView.Modify(row, "", compound, centerGui["compoundCountEdit"].Text)

				center.TyreCompoundsListView.ModifyCol()

				updateTyreCompoundDropDown()

				center.updateState()
			}
		}

		addTyreCompound(*) {
			local usedCompounds := []
			local index, ignore, candidate

			loop center.TyreCompoundsListView.GetCount()
				usedCompounds.Push(center.TyreCompoundsListView.GetText(A_Index, 1))

			for ignore, candidate in center.AvailableTyreCompounds
				if !inList(usedCompounds, translate(candidate)) {
					index := A_Index

					break
				}

			center.TyreCompoundsListView.Add("", collect(center.TyreCompounds, translate)[index], 99)
			center.TyreCompoundsListView.Modify(center.TyreCompoundsListView.GetCount(), "Select Vis")

			center.TyreCompoundsListView.ModifyCol()

			centerGui["compoundDropDown"].Choose(index)
			centerGui["compoundCountEdit"].Value := 99

			updateTyreCompoundDropDown()

			center.updateState()
		}

		deleteTyreCompound(*) {
			local index := center.TyreCompoundsListView.GetNext(0)

			if (index > 0)
				center.TyreCompoundsListView.Delete(index)

			updateTyreCompoundDropDown()

			center.updateState()
		}

		updateTelemetry(*) {
			centerGui["practiceCenterTabView"].Redraw()

			this.analyzeTelemetry()
		}

		centerGui := PracticeCenter.PracticeCenterWindow(this)

		this.iWindow := centerGui

		centerGui.SetFont("s10 Bold", "Arial")

		centerGui.Add("Text", "w1334 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(centerGui, "Practice Center"))

		centerGui.SetFont("s9 Norm", "Arial")

		centerGui.Add("Documentation", "x608 YP+20 w134 H:Center Center", translate("Practice Center")
					, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#practice-center")

		centerGui.Add("Text", "x8 yp+30 w1350 W:Grow 0x10")

		centerGui.SetFont("Norm")
		centerGui.SetFont("s10 Bold", "Arial")

		centerGui.Add("Picture", "x16 yp+12 w30 h30 Section", kIconsDirectory . "Report.ico")
		centerGui.Add("Text", "x50 yp+5 w80 h26", translate("Reports"))

		centerGui.SetFont("s8 Norm", "Arial")

		x := 16
		y := 70
		width := 388

		centerGui.SetFont("s8 Norm", "Arial")

		centerGui.Add("Text", "x16 yp+32 w70 h23 +0x200", translate("Simulator"))

		simulators := this.getAvailableSimulators()
		simulator := 0

		if (simulators.Length > 0) {
			if this.Simulator
				simulator := inList(simulators, this.Simulator)

			if (simulator == 0)
				simulator := 1
		}

		centerGui.Add("DropDownList", "x90 yp w296 Choose" . simulator . " vsimulatorDropDown", simulators).OnEvent("Change", chooseSimulator)

		if (simulator > 0)
			simulator := simulators[simulator]
		else
			simulator := false

		centerGui.Add("Text", "x16 yp+24 w70 h23 +0x200", translate("Car"))
		centerGui.Add("DropDownList", "x90 yp w296 vcarDropDown").OnEvent("Change", chooseCar)

		centerGui.Add("Text", "x16 yp24 w70 h23 +0x200", translate("Track"))
		centerGui.Add("DropDownList", "x90 yp w296 vtrackDropDown").OnEvent("Change", chooseTrack)

		centerGui.Add("Text", "x24 yp+31 w356 0x10")

		this.iReportsListView := centerGui.Add("ListView", "x16 yp+10 w115 h230 H:Grow(0.2) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", [translate("Report")])
		this.iReportsListView.OnEvent("Click", chooseReport)

		for ignore, report in kSessionReports
			if (report = "Drivers")
				this.iReportsListView.Add("", translate("Driver (Start)"))
			else
				this.iReportsListView.Add("", translate(report))

		this.iReportsListView.ModifyCol(1, "AutoHdr")

		centerGui.Add("Text", "x141 yp+2 w70 h23 +0x200", translate("Stint"))
		centerGui.Add("DropDownList", "x195 yp w191 vrunDropDown").OnEvent("Change", chooseRunData)

		centerGui.Add("Text", "x141 yp+24 w70 h23 +0x200", translate("Driver"))
		centerGui.Add("DropDownList", "x195 yp w191 vdriverDropDown").OnEvent("Change", chooseDriverData)

		centerGui.Add("Text", "x141 yp+24 w70 h23 +0x200", translate("X-Axis"))

		centerGui.Add("DropDownList", "x195 yp w191 vdataXDropDown").OnEvent("Change", chooseAxis)

		centerGui.Add("Text", "x141 yp+24 w70 h23 +0x200", translate("Series"))

		centerGui.Add("DropDownList", "x195 yp w191 vdataY1DropDown").OnEvent("Change", chooseAxis)
		centerGui.Add("DropDownList", "x195 yp+24 w191 vdataY2DropDown").OnEvent("Change", chooseAxis)
		centerGui.Add("DropDownList", "x195 yp+24 w191 vdataY3DropDown").OnEvent("Change", chooseAxis)
		centerGui.Add("DropDownList", "x195 yp+24 w191 vdataY4DropDown").OnEvent("Change", chooseAxis)
		centerGui.Add("DropDownList", "x195 yp+24 w191 vdataY5DropDown").OnEvent("Change", chooseAxis)
		centerGui.Add("DropDownList", "x195 yp+24 w191 vdataY6DropDown").OnEvent("Change", chooseAxis)

		centerGui.Add("Text", "x400 ys w40 h23 +0x200", translate("Plot"))
		centerGui.Add("DropDownList", "x444 yp w80 Choose1 vchartTypeDropDown", collect(["Scatter", "Bar", "Bubble", "Line"], translate)).OnEvent("Change", chooseChartType)

		centerGui.Add("Button", "x1327 yp w23 h23 X:Move vreportSettingsButton").OnEvent("Click", reportSettings)
		setButtonIcon(centerGui["reportSettingsButton"], kIconsDirectory . "General Settings.ico", 1)

		this.iChartViewer := centerGui.Add("HTMLViewer", "x400 yp+24 w950 h343 W:Grow H:Grow(0.2) Border vchartViewer")

		centerGui.Rules := "Y:Move(0.2)"

		centerGui.Add("Text", "x8 yp+351 w1350 W:Grow 0x10")

		centerGui.SetFont("Norm")
		centerGui.SetFont("s10 Bold", "Arial")

		centerGui.Add("Picture", "x16 yp+10 w30 h30 Section", kIconsDirectory . "Watch.ico")
		centerGui.Add("Text", "x50 yp+5 w80 h26", translate("Session"))

		centerGui.SetFont("s8 Norm", "Arial")

		centerGui.Add("DropDownList", "x195 yp-2 w180 Choose1 +0x200 vsessionMenuDropDown").OnEvent("Change", sessionMenu)
		centerGui.Add("DropDownList", "x380 yp w180 Choose1 +0x200 vdataMenuDropDown").OnEvent("Change", dataMenu)
		centerGui.Add("DropDownList", "x565 yp w180 Choose1 +0x200 vrunMenuDropDown").OnEvent("Change", runMenu)

		centerGui.SetFont("s8 Norm", "Arial")

		centerGui.SetFont("Norm", "Arial")
		centerGui.SetFont("Italic", "Arial")

		centerGui.Add("Text", "x619 ys+39 w80 h21", translate("Output"))
		centerGui.Add("Text", "x700 yp+7 w651 0x10 W:Grow")

		this.iDetailsViewer := centerGui.Add("HTMLViewer", "x619 yp+14 w732 h293 W:Grow H:Grow(0.8) Border vdetailsViewer")

		centerGui.SetFont("Norm", "Arial")

		centerTab := centerGui.Add("Tab3", "x16 ys+39 w593 h316 H:Grow(0.8) AltSubmit -Wrap Section vpracticeCenterTabView", collect(["Tyres", "Stints", "Laps", "Data"], translate))
		centerTab.OnEvent("Change", updateTelemetry)

		centerTab.UseTab(1)

		x := 32
		x0 := x - 4
		x1 := x + 84
		x2 := x1 + 32
		x3 := x2 + 26
		x4 := x1 + 16

		xb := x1 + 87

		x5 := 243 + 8
		x6 := x5 - 4
		x7 := x5 + 79
		x8 := x7 + 32
		x9 := x8 + 26
		x10 := x7 + 16

		x11 := x7 + 87
		x12 := x11 + 56

		centerGui.SetFont("Norm", "Arial")
		centerGui.SetFont("Italic", "Arial")

		centerGui.Add("GroupBox", "x24 ys+34 w209 h271", translate("Setup"))

		centerGui.SetFont("Norm", "Arial")

		centerGui.Add("Text", "x" . x . " yp+21 w75 h23 +0x200", translate("Mode"))
		centerGui.Add("DropDownList", "x" . x1 . " yp w110 Choose2 vrunModeDropDown", collect(["Manual", "Auto"], translate)).OnEvent("Change", updateState)

		/*
		centerGui.Add("Text", "x" . (x + 8) . " yp+35 w175 0x10")

		centerGui.SetFont("Norm", "Arial")
		centerGui.SetFont("Italic", "Arial")

		centerGui.Add("Text", "x" . (x + 8) . " yp+10 w175 h23 +0x200 Center", translate("Tyres"))

		centerGui.SetFont("Norm", "Arial")
		*/

		choices := collect(["No change", "Auto", normalizeCompound("Dry")], translate)
		chosen := 2

		centerGui.Add("Text", "x" . x . " yp+24 w75 h23 +0x200", translate("Compound"))
		centerGui.Add("DropDownList", "x" . x1 . " yp w86 Choose" . chosen . " vtyreCompoundDropDown", choices).OnEvent("Change", updateState)

		centerGui.Add("Button", "x" . xb . " yp w23 h23 Center +0x200 vimportPressuresButton").OnEvent("Click", importPressures)
		setButtonIcon(centerGui["importPressuresButton"], kIconsDirectory . "Copy.ico", 1, "")

		centerGui.Add("Text", "x" . x . " yp+28 w75 h20", translate("Set"))
		centerGui.Add("Edit", "x" . x1 . " yp-4 w50 h20 Limit2 Number vtyreSetEdit")
		centerGui.Add("UpDown", "x" . x2 . " yp-2 w18 h20 Range0-99")

		centerGui.Add("Text", "x" . x . " yp+28 w85 h40", translate("Pressures") . translate(" (") . getUnit("Pressure") . translate(")"))

		centerGui.Add("Edit", "x" . x1 . " yp-2 w50 h20 Limit4 vtyrePressureFLEdit").OnEvent("Change", validateNumber.Bind("tyrePressureFLEdit"))
		centerGui.Add("Edit", "x" . (x1 + 58) . " yp w50 h20 Limit4 vtyrePressureFREdit").OnEvent("Change", validateNumber.Bind("tyrePressureFREdit"))
		centerGui.Add("Edit", "x" . x1 . " yp+22 w50 h20 Limit4 vtyrePressureRLEdit").OnEvent("Change", validateNumber.Bind("tyrePressureRLEdit"))
		centerGui.Add("Edit", "x" . (x1 + 58) . " yp w50 h20 Limit4 vtyrePressureRREdit").OnEvent("Change", validateNumber.Bind("tyrePressureRREdit"))

		centerGui.Add("Button", "x" . (x + 28) . " ys+207 w135 h20 vnewRunButton", translate("New Stint")).OnEvent("Click", newRun)

		centerGui.SetFont("Norm", "Arial")
		centerGui.SetFont("Italic", "Arial")

		centerGui.Add("GroupBox", "x243 ys+34 w354 h271", translate("Tyre Sets"))

		centerGui.SetFont("Norm", "Arial")

		centerGui.Add("Text", "x" . x5 . " yp+21 w75 h23 +0x200", translate("Available"))

		w12 := (x11 + 50 - x7)

		this.iTyreCompoundsListView := centerGui.Add("ListView", "x" . x7 . " yp w" . w12 . " h90 -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Compound", "#"], translate))
		this.iTyreCompoundsListView.OnEvent("Click", chooseTyreCompound)
		this.iTyreCompoundsListView.OnEvent("DoubleClick", chooseTyreCompound)

		x13 := (x7 + w12 + 5)

		centerGui.Add("DropDownList", "x" . x13 . " yp w116 Choose0 vcompoundDropDown", [translate(normalizeCompound("Dry"))]).OnEvent("Change", updateTyreCompound)
		centerGui.Add("Edit", "x" . x13 . " yp+24 w40 h20 Limit2 Number vcompoundCountEdit").OnEvent("Change", updateTyreCompound)
		centerGui.Add("UpDown", "x" . x13 . " yp w18 h20 0x80 Range0-99")

		x13 := (x7 + w12 + 5 + 116 - 48)

		centerGui.Add("Button", "x" . x13 . " yp+18 w23 h23 Center +0x200 vcompoundAddButton").OnEvent("Click", addTyreCompound)
		setButtonIcon(centerGui["compoundAddButton"], kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")

		x13 += 25

		centerGui.Add("Button", "x" . x13 . " yp w23 h23 Center +0x200 vcompoundDeleteButton").OnEvent("Click", deleteTyreCompound)
		setButtonIcon(centerGui["compoundDeleteButton"], kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		centerGui.Add("Text", "x" . x5 . " ys+155 w75 h23 +0x200", translate("Used"))

		w13 := (x13 + 23 - x7)

		this.iUsedTyreSetsListView := centerGui.Add("ListView", "x" . x7 . " yp w" . w13 . " h140 -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Compound", "Set", "Laps"], translate))
		this.iUsedTyreSetsListView.OnEvent("Click", noSelect)
		this.iUsedTyreSetsListView.OnEvent("DoubleClick", noSelect)

		centerTab.UseTab(2)

		this.iRunsListView := centerGui.Add("ListView", "x24 ys+33 w577 h270 H:Grow(0.8) Checked -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["#", "Driver", "Weather", "Compound", "Set", "Laps", "Initial Fuel", "Consumed Fuel", "Avg. Lap Time", "Accidents", "Potential", "Race Craft", "Speed", "Consistency", "Car Control"], translate))
		this.iRunsListView.OnEvent("Click", chooseRun)

		centerTab.UseTab(3)

		this.iLapsListView := centerGui.Add("ListView", "x24 ys+33 w577 h270 H:Grow(0.8) Checked -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["#", "Stint", "Weather", "Grip", "Lap Time", "Consumption", "Remaining", "Pressures", "Invalid", "Accident"], translate))
		this.iLapsListView.OnEvent("Click", chooseLap)

		centerTab.UseTab(4)

		centerGui.Add("Text", "x24 ys+40 w80 h21", translate("Fuel Level"))

		columns := collect(kFuelBuckets, convertUnit.Bind("Volume"))

		loop columns.Length
			columns[A_Index] := (columns[A_Index] . A_Space . SubStr(getUnit("Volume"), 1, 1))

		this.iFuelDataListView := centerGui.Add("ListView", "x124 ys+33 w477 h132 H:Grow(0.4) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", concatenate([translate("Map")], columns))
		this.iFuelDataListView.OnEvent("Click", noSelect)
		this.iFuelDataListView.OnEvent("DoubleClick", noSelect)

		centerGui.Add("Text", "x24 ys+178 w80 h21 Y:Move(0.4)", translate("Tyre Usage"))

		this.iTyreDataListView := centerGui.Add("ListView", "x124 ys+171 w477 h132 Y:Move(0.4) -Multi -LV0x10 AltSubmit NoSort NoSortHdr", concatenate([translate("Fuel")], kTyreLapsBuckets))
		this.iTyreDataListView.OnEvent("Click", noSelect)
		this.iTyreDataListView.OnEvent("DoubleClick", noSelect)

		centerGui.Rules := ""

		this.iReportViewer := RaceReportViewer(centerGui, this.ChartViewer)

		centerGui.Add(PracticeCenter.PracticeCenterResizer(centerGui))

		car := this.Car
		track := this.Track

		this.loadSimulator(simulator, true)

		if car
			this.loadCar(car)

		if track
			this.loadTrack(track)
	}

	show() {
		local window := this.Window
		local x, y, w, h

		if getWindowPosition("Practice Center", &x, &y)
			window.Show("AutoSize x" . x . " y" . y)
		else
			window.Show("AutoSize")

		if getWindowSize("Practice Center", &w, &h)
			window.Resize("Initialize", w, h)

		this.startWorking(false)

		this.showDetails(false, false)
		this.showChart(false)

		this.initializeSession()

		this.updateState()
	}

	getAvailableSimulators() {
		return SessionDatabase.getSimulators()
	}

	getAvailableCars(simulator) {
		return SessionDatabase().getCars(simulator)
	}

	getAvailableTracks(simulator, car) {
		return SessionDatabase().getTracks(simulator, car)
	}

	loadSimulator(simulator, force := false) {
		local drivers, ignore, id, index, car, carNames, cars, settings

		if (force || (simulator != this.Simulator)) {
			this.iSimulator := simulator

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Practice Center", "Simulator", simulator)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

			if simulator
				cars := this.getAvailableCars(simulator)
			else
				cars := []

			carNames := cars.Clone()

			for index, car in cars
				carNames[index] := SessionDatabase.getCarName(simulator, car)

			this.Control["simulatorDropDown"].Choose(inList(this.getAvailableSimulators(), simulator))

			this.Control["carDropDown"].Delete()
			this.Control["carDropDown"].Add(carNames)

			this.loadCar((cars.Length > 0) ? cars[1] : false, true)
		}
	}

	loadCar(car, force := false) {
		local tracks, settings

		if (force || (car != this.Car)) {
			this.iCar := car

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Practice Center", "Car", car)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

			tracks := this.getAvailableTracks(this.Simulator, car)

			this.Control["carDropDown"].Choose(inList(this.getAvailableCars(this.Simulator), car))
			this.Control["trackDropDown"].Delete()
			this.Control["trackDropDown"].Add(collect(tracks, ObjBindMethod(SessionDatabase, "getTrackName", this.Simulator)))

			this.loadTrack((tracks.Length > 0) ? tracks[1] : false, true)
		}
	}

	loadTrack(track, force := false) {
		local simulator, car, settings

		if (force || (track != this.Track)) {
			simulator := this.Simulator
			car := this.Car

			this.iTrack := track

			settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")

			setMultiMapValue(settings, "Practice Center", "Track", track)

			writeMultiMap(kUserConfigDirectory . "Application Settings.ini", settings)

			this.Control["trackDropDown"].Choose(inList(this.getAvailableTracks(simulator, car), track))

			if track
				this.loadTyreCompounds(this.Simulator, this.Car, this.Track)
		}
	}

	loadTyreCompounds(simulator, car, track) {
		local compounds := SessionDatabase.getTyreCompounds(simulator, car, track)
		local translatedCompounds, choices, index, ignore, compound

		this.iAvailableTyreCompounds := compounds
		this.iTyreCompounds := compounds

		translatedCompounds := collect(compounds, translate)

		this.Control["tyreCompoundDropDown"].Delete()
		this.Control["tyreCompoundDropDown"].Add(concatenate(collect(["No change", "Auto"], translate), translatedCompounds))
		this.Control["tyreCompoundDropDown"].Choose(2)

		this.Control["compoundDropDown"].Delete()
		this.Control["compoundDropDown"].Add(translatedCompounds)
		this.Control["compoundDropDown"].Choose(0)

		this.TyreCompoundsListView.Delete()

		for ignore, compound in compounds
			this.TyreCompoundsListView.Add("", translate(compound), 99)

		this.TyreCompoundsListView.ModifyCol()

		this.updateState()
	}

	selectRun(run, force := false) {
		if (force || (run != this.SelectedRun)) {
			this.Control["runDropDown"].Choose(run ? (run.Nr + 1) : 1)

			this.iSelectedRun := run

			this.updateReports()
		}
	}

	selectDriver(driver, force := false) {
		if (force || (this.SelectedDrivers && !inList(this.SelectedDrivers, driver))
				  || (!this.SelectedDrivers && ((driver != true) && (driver != false)))) {
			if driver {
				this.Control["driverDropDown"].Choose(((driver = true) || (driver = false)) ? 1 : (inList(this.Drivers, driver) + 1))

				this.iSelectedDrivers := ((driver == true) ? false : [driver])
			}
			else {
				this.Control["driverDropDown"].Choose(0)

				this.iSelectedDrivers := false
			}

			this.updateReports()
		}
	}

	createDriver(driver) {
		local ignore, candidate, found

		if !driver.HasProp("Nr")
			driver.Nr := false

		if !driver.HasProp("ID")
			driver.ID := false

		for ignore, candidate in this.Drivers {
			found := false

			if ((candidate.Forname = driver.Forname) && (candidate.Surname = driver.Surname))
				found := candidate

			if found {
				if (driver.ID && !found.ID) {
					found.ID := driver.ID

					if this.Simulator
						SessionDatabase.registerDriver(this.Simulator, driver.ID, found.FullName)
				}

				return found
			}
		}

		driver.FullName := computeDriverName(driver.Forname, driver.Surname, driver.Nickname)
		driver.Laps := []
		driver.Runs := []
		driver.Accidents := 0

		if driver.ID {
			found := false

			for ignore, candidate in this.Drivers
				if (driver.ID = candidate.ID) {
					found := true

					break
				}

			if !found
				this.Drivers.Push(driver)

			if this.Simulator
				SessionDatabase.registerDriver(this.Simulator, driver.ID, driver.FullName)
		}
		else
			this.Drivers.Push(driver)

		return driver
	}

	importFromSimulation(simulator) {
		local prefix := SessionDatabase.getSimulatorCode(simulator)
		local data, tyreCompound, tyreCompoundColor, tyreSet, tyrePressure, ignore, field

		if !prefix {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("This is not supported for the selected simulator..."), translate("Warning"), 262192)
			OnMessage(0x44, translateOkButton, 0)

			return
		}

		data := readSimulatorData(prefix)

		if ((getMultiMapValue(data, "Session Data", "Car") != this.Car)
		 || (getMultiMapValue(data, "Session Data", "Track") != this.Track))
			return
		else {
			tyreCompound := getMultiMapValue(data, "Car Data", "TyreCompound", kUndefined)
			tyreCompoundColor := getMultiMapValue(data, "Car Data", "TyreCompoundColor", kUndefined)

			if (tyreCompound = kUndefined) {
				tyreCompound := getMultiMapValue(data, "Car Data", "TyreCompoundRaw", kUndefined)

				if (tyreCompound && (tyreCompound != kUndefined)) {
					tyreCompound := SessionDatabase.getTyreCompoundName(simulator, this.Car, this.Track, tyreCompound, false)

					if tyreCompound
						splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)
					else
						tyreCompound := kUndefined
				}
			}

			if ((tyreCompound != kUndefined) && (tyreCompoundColor != kUndefined))
				this.Control["tyreCompoundDropDown"].Choose(inList(this.TyreCompounds, compound(tyreCompound, tyreCompoundColor)) + 2)

			tyreSet := getMultiMapValue(data, "Car Data", "TyreSet", kUndefined)

			if (tyreSet != kUndefined)
				this.Control["tyreSetEdit"].Text := tyreSet

			for ignore, field in ["TyrePressureFL", "TyrePressureFR", "TyrePressureRL", "TyrePressureRR"] {
				tyrePressure := getMultiMapValue(data, "Setup Data", field, kUndefined)

				if (tyrePressure != kUndefined)
					this.Control[field . "Edit"].Text := displayValue("Float", convertUnit("Pressure", tyrePressure))
			}
		}

		this.updateState()
	}

	getClasses(data) {
		local classes := CaseInsenseMap()
		local class

		loop getMultiMapValue(data, "Position Data", "Car.Count") {
			class := this.getClass(data, A_Index)

			if !classes.Has(class)
				classes[class] := true
		}

		return getKeys(classes)
	}

	getClass(data, car := false) {
		local categories := (this.ReportViewer.Settings.Has("CarCategories") ? this.ReportViewer.Settings["CarCategories"] : ["Class"])
		local carClass, carCategory

		if !car
			car := getMultiMapValue(data, "Position Data", "Driver.Car")

		if inList(categories, "Class") {
			carClass := getMultiMapValue(data, "Position Data", "Car." . car . ".Class", kUnknown)

			if inList(categories, "Cup") {
				carCategory := getMultiMapValue(data, "Position Data", "Car." . car . ".Category", kUndefined)

				return ((carCategory != kUndefined) ? (carClass . translate(" (") . carCategory . translate(")")) : carClass)
			}
			else
				return carClass
		}
		else
			return getMultiMapValue(data, "Position Data", "Car." . car . ".Category", kUnknown)
	}

	getCars(data, class := "Overall", sorted := false) {
		local classGrid := []
		local positions, ignore, position

		compareClassPositions(c1, c2) {
			local pos1 := c1[2]
			local pos2 := c2[2]

			if !isNumber(pos1)
				pos1 := 999

			if !isNumber(pos2)
				pos2 := 999

			return (pos1 > pos2)
		}

		if (class = "Class")
			class := this.getClass(data)
		else if (class = "Overall")
			class := false

		if sorted {
			positions := []

			loop getMultiMapValue(data, "Position Data", "Car.Count")
				if (!class || (class = this.getClass(data, A_Index)))
					positions.Push(Array(A_Index, getMultiMapValue(data, "Position Data", "Car." . A_Index . ".Position")))

			bubbleSort(&positions, compareClassPositions)

			for ignore, position in positions
				classGrid.Push(position[1])
		}
		else
			loop getMultiMapValue(data, "Position Data", "Car.Count")
				if (!class || (class = this.getClass(data, A_Index)))
					classGrid.Push(A_Index)

		return classGrid
	}

	getPosition(data, type := "Overall", car := false) {
		local position, candidate

		if !car
			if (type = "Overall")
				return getMultiMapValue(data, "Position Data", "Car." . getMultiMapValue(data, "Position Data", "Driver.Car") . ".Position", false)
			else
				car := getMultiMapValue(data, "Position Data", "Driver.Car")

		if (type != "Overall")
			for position, candidate in this.getCars(data, this.getClass(data, car), true)
				if (candidate = car)
					return position

		return getMultiMapValue(data, "Position Data", "Car." . car . ".Position", false)
	}

	updateState() {
		local window := this.Window
		local ignore, field

		window["runDropDown"].Enabled := false
		window["driverDropDown"].Enabled := false

		window["dataXDropDown"].Enabled := false
		window["dataY1DropDown"].Enabled := false
		window["dataY2DropDown"].Enabled := false
		window["dataY3DropDown"].Enabled := false
		window["dataY4DropDown"].Enabled := false
		window["dataY5DropDown"].Enabled := false
		window["dataY6DropDown"].Enabled := false

		if (!this.Simulator || this.SessionExported) {
			window["runMenuDropDown"].Visible := false

			window["runModeDropDown"].Enabled := false
			window["runModeDropDown"].Choose(0)

			window["newRunButton"].Enabled := false

			window["tyreCompoundDropDown"].Enabled := false
			window["tyreCompoundDropDown"].Choose(0)

			window["importPressuresButton"].Enabled := false
		}
		else if (this.SessionActive || !this.SessionMode) {
			window["runMenuDropDown"].Visible := true

			window["runModeDropDown"].Enabled := true
			if (window["runModeDropDown"].Value = 0)
				window["runModeDropDown"].Choose(2)

			window["newRunButton"].Enabled := true

			window["tyreCompoundDropDown"].Enabled := true
			if (window["tyreCompoundDropDown"].Value = 0)
				window["tyreCompoundDropDown"].Choose(2)

			window["importPressuresButton"].Enabled := true

			if (window["runModeDropDown"].Value = 1)
				window["newRunButton"].Enabled := true
			else {
				window["importPressuresButton"].Enabled := (window["tyreCompoundDropDown"].Value > 1)
				window["newRunButton"].Enabled := false
			}
		}
		else {
			window["runMenuDropDown"].Visible := true

			window["runModeDropDown"].Enabled := false
			window["runModeDropDown"].Choose(0)

			window["newRunButton"].Enabled := false

			window["tyreCompoundDropDown"].Enabled := false
			window["tyreCompoundDropDown"].Choose(0)

			window["importPressuresButton"].Enabled := false
		}

		if (window["tyreCompoundDropDown"].Value <= 2) {
			for ignore, field in ["tyreSetEdit", "tyrePressureFLEdit", "tyrePressureFREdit", "tyrePressureRLEdit", "tyrePressureRREdit"] {
				window[field].Enabled := false
				window[field].Text := ""
			}
		}
		else {
			for ignore, field in ["tyreSetEdit", "tyrePressureFLEdit", "tyrePressureFREdit", "tyrePressureRLEdit", "tyrePressureRREdit"]
				window[field].Enabled := true

			if (window["tyreSetEdit"].Text = "")
				window["tyreSetEdit"].Text := 0
		}

		this.Control["compoundAddButton"].Enabled := (this.AvailableTyreCompounds.Length > this.TyreCompoundsListView.GetCount())

		if ((this.SessionActive || !this.SessionMode) && (this.TyreCompoundsListView.GetNext(0) > 0) && !this.SessionExported) {
			this.Control["compoundDropDown"].Enabled := true
			this.Control["compoundCountEdit"].Enabled := true
			this.Control["compoundDeleteButton"].Enabled := true
		}
		else {
			this.Control["compoundDropDown"].Enabled := false
			this.Control["compoundCountEdit"].Enabled := false
			this.Control["compoundDeleteButton"].Enabled := false

			this.Control["compoundDropDown"].Choose(0)
			this.Control["compoundCountEdit"].Text := ""
		}

		if this.HasData {
			if inList(["Overview", "Drivers", "Positions", "Lap Times", "Performance", "Consistency", "Pace", "Pressures", "Brakes", "Temperatures", "Free"], this.SelectedReport)
				window["reportSettingsButton"].Enabled := true
			else
				window["reportSettingsButton"].Enabled := false

			if inList(["Running", "Pressures", "Brakes", "Temperatures", "Free"], this.SelectedReport) {
				window["chartTypeDropDown"].Enabled := true

				if (this.SelectedReport != "Running") {
					window["runDropDown"].Enabled := true
					window["driverDropDown"].Enabled := true
				}

				window["dataXDropDown"].Enabled := true
				window["dataY1DropDown"].Enabled := true
				window["dataY2DropDown"].Enabled := true
				window["dataY3DropDown"].Enabled := true

				if (this.SelectedChartType != "Bubble") {
					window["dataY4DropDown"].Enabled := true
					window["dataY5DropDown"].Enabled := true
					window["dataY6DropDown"].Enabled := true
				}
			}
			else {
				window["chartTypeDropDown"].Enabled := false
				window["chartTypeDropDown"].Choose(0)

				this.iSelectedChartType := false

				window["runDropDown"].Choose(0)
				window["driverDropDown"].Choose(0)

				window["dataXDropDown"].Choose(0)
				window["dataY1DropDown"].Choose(0)
				window["dataY2DropDown"].Choose(0)
				window["dataY3DropDown"].Choose(0)
				window["dataY4DropDown"].Choose(0)
				window["dataY5DropDown"].Choose(0)
				window["dataY6DropDown"].Choose(0)
			}
		}
		else {
			window["reportSettingsButton"].Enabled := false

			window["runDropDown"].Choose(0)
			window["driverDropDown"].Choose(0)

			window["dataXDropDown"].Choose(0)
			window["dataY1DropDown"].Choose(0)
			window["dataY2DropDown"].Choose(0)
			window["dataY3DropDown"].Choose(0)
			window["dataY4DropDown"].Choose(0)
			window["dataY5DropDown"].Choose(0)
			window["dataY6DropDown"].Choose(0)

			window["chartTypeDropDown"].Enabled := false
			window["chartTypeDropDown"].Choose(0)

			this.iSelectedChartType := false
		}

		this.updateSessionMenu()
		this.updateRunMenu()
		this.updateDataMenu()
	}

	updateSessionMenu() {
		this.Control["sessionMenuDropDown"].Delete()
		this.Control["sessionMenuDropDown"].Add(collect(["Session", "---------------------------------------------", "Clear...", "---------------------------------------------", "Load Session...", "Save Session", "Save a Copy...", "---------------------------------------------", "Update Statistics", "---------------------------------------------", "Session Summary"], translate))

		if !this.SessionExported
			this.Control["sessionMenuDropDown"].Add(collect(["---------------------------------------------", "Export to Database..."], translate))

		this.Control["sessionMenuDropDown"].Choose(1)
	}

	updateRunMenu() {
		this.Control["runMenuDropDown"].Delete()
		this.Control["runMenuDropDown"].Add(collect(["Stints", "---------------------------------------------", "New Stint", "---------------------------------------------", "Stints Summary"], translate))

		this.Control["runMenuDropDown"].Choose(1)
	}

	updateDataMenu() {
		local use1 := (this.UseSessionData ? "(x) Use Session Data" : "      Use Session Data")
		local use2 := (this.UseTelemetryDatabase ? "(x) Use Telemetry Database" : "      Use Telemetry Database")
		local tyreCompounds := collect(this.AvailableTyreCompounds, translate)
		local tyreCompound := translate(compound(this.TyreCompound["Data"], this.TyreCompoundColor["Data"]))
		local weather := translate(this.Weather["Data"])

		static weatherConditions := collect(kWeatherConditions, translate)

		wConditions := weatherConditions.Clone()

		loop wConditions.Length
			wConditions[A_Index] := (((wConditions[A_Index] = weather) ? "(x) " : "      ") . wConditions[A_Index])

		loop tyreCompounds.Length
			tyreCompounds[A_Index] := (((tyreCompounds[A_Index] = tyreCompound) ? "(x) " : "      ") . tyreCompounds[A_Index])

		this.Control["dataMenuDropDown"].Delete()
		this.Control["dataMenuDropDown"].Add(concatenate(collect(["Data", "---------------------------------------------"
																		, use1, use2, "---------------------------------------------"], translate)
													   , wConditions, [translate("---------------------------------------------")]
													   , tyreCompounds, collect(["---------------------------------------------", "Data Summary"], translate)))

		this.Control["dataMenuDropDown"].Choose(1)
	}

	chooseSessionMenu(line) {
		local msgResult

		switch line {
			case 3: ; Clear...
				if this.SessionActive {
					OnMessage(0x44, translateYesNoButtons)
					msgResult := MsgBox(translate("Do you really want to delete all data from the currently active session? This cannot be undone."), translate("Delete"), 262436)
					OnMessage(0x44, translateYesNoButtons, 0)

					if (msgResult = "Yes")
						this.clearSession()
				}
				else
					this.clearSession()
			case 5: ; Load Session...
				this.loadSession()
			case 6: ; Save Session
				if this.HasData {
					if this.SessionActive
						this.saveSession()
					else {
						OnMessage(0x44, translateOkButton)
						MsgBox(translate("You are not connected to an active session. Use `"Save a Copy...`" instead."), translate("Information"), 262192)
						OnMessage(0x44, translateOkButton, 0)
					}
				}
				else {
					OnMessage(0x44, translateOkButton)
					MsgBox(translate("There is no session data to be saved."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
			case 7: ; Save Session Copy...
				if this.HasData
					this.saveSession(true)
				else {
					OnMessage(0x44, translateOkButton)
					MsgBox(translate("There is no session data to be saved."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
			case 9: ; Update Statistics
				this.updateStatistics()
			case 11: ; Session Summary
				this.showSessionSummary()
			case 13: ; Export data
				if (this.HasData && !this.SessionExported) {
					OnMessage(0x44, translateYesNoButtons)
					msgResult := MsgBox(translate("Do you want to transfer the selected data to the session database? This is only possible once."), translate("Delete"), 262436)
					OnMessage(0x44, translateYesNoButtons, 0)

					if (msgResult = "Yes")
						this.exportSession()
				}
				else {
					OnMessage(0x44, translateOkButton)
					MsgBox(translate("There is no session data to be exported or the session already been exported."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
		}

		this.updateSessionMenu()
	}

	chooseDataMenu(line) {
		local tyreCompound, tyreCompoundColor

		switch line {
			case 3:
				this.UseSessionData := !this.UseSessionData

				this.analyzeTelemetry()
			case 4:
				this.UseTelemetryDatabase := !this.UseTelemetryDatabase

				this.analyzeTelemetry()
			default:
				line -= 5

				if ((line > 0) && (line <= kWeatherConditions.Length)) {
					this.iDataWeather := kWeatherConditions[line]

					this.analyzeTelemetry()
				}
				else {
					line -= (kWeatherConditions.Length + 1)

					if ((line > 0) && (line <= this.AvailableTyreCompounds.Length)) {
						splitCompound(this.AvailableTyreCompounds[line], &tyreCompound, &tyreCompoundColor)

						this.iDataTyreCompound := tyreCompound
						this.iDataTyreCompoundColor := tyreCompoundColor

						this.analyzeTelemetry()
					}
					else if ((line - (this.AvailableTyreCompounds.Length + 1)) = 1) ; Data Summary
						this.showDataSummary()
				}
		}

		this.updateDataMenu()
	}

	chooseRunMenu(line) {
		switch line {
			case 3: ; New Stint
				if this.SessionActive {
					if (this.Control["runModeDropDown"].Value = 1) {
						local lastLap := this.LastLap

						this.withExceptionhandler(ObjBindMethod(this, "newRun", lastLap ? (lastLap.Nr + 1) : 1))
					}
					else {
						OnMessage(0x44, translateOkButton)
						MsgBox(translate("You must have manual stint mode enabled to create a new stint manually."), translate("Information"), 262192)
						OnMessage(0x44, translateOkButton, 0)
					}
				}
				else {
					OnMessage(0x44, translateOkButton)
					MsgBox(translate("You are not connected to an active session."), translate("Information"), 262192)
					OnMessage(0x44, translateOkButton, 0)
				}
			case 5:
				OnMessage(0x44, translateOkButton)
				MsgBox(translate("Not yet implemented."), translate("Information"), 262192)
				OnMessage(0x44, translateOkButton, 0)
		}

		this.updateRunMenu()
	}

	withExceptionHandler(function, arguments*) {
		try {
			return function.Call(arguments*)
		}
		catch Any as exception {
			logError(exception, false)

			OnMessage(0x44, translateOkButton)
			MsgBox((translate("Error while executing command.") . "`n`n" . translate("Error: ") . exception.Message), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}
	}

	pushTask(theTask) {
		PracticeCenterTask(theTask).start()
	}

	startWorking(state := true) {
		local start := false

		if state {
			start := (this.iWorking == 0)

			this.iWorking += 1

			if !start
				return false
		}
		else {
			this.iWorking -= 1

			if (this.iWorking > 0)
				return
			else
				this.iWorking := 0
		}

		if state
			this.Window.Block()
		else {
			curAutoActivate := this.Window.AutoActivate

			try {
				this.Window.AutoActivate := false

				this.Window.Unblock()
			}
			finally {
				this.Window.AutoActivate := curAutoActivate
			}
		}

		return (start || (this.iWorking == 0))
	}

	finishWorking() {
		this.startWorking(false)
	}

	isWorking() {
		return (this.iWorking > 0)
	}

	initializeSession(session := "Practice") {
		local directory, reportDirectory

		if (!this.SessionMode || this.SessionActive) {
			directory := this.SessionDirectory

			deleteDirectory(directory)

			DirCreate(directory)

			reportDirectory := (directory . "Race Report")

			deleteDirectory(reportDirectory)

			DirCreate(reportDirectory)

			this.ReportViewer.setReport(reportDirectory)
		}
		else {
			this.iSessionMode := false
			this.iSessionLoaded := false

			this.initializeSession(session)

			return
		}

		this.iAvailableTyreCompounds := [normalizeCompound("Dry")]
		this.iTyreCompounds := [normalizeCompound("Dry")]
		this.iUsedTyreSets := WeakMap()

		this.RunsListView.Delete()
		this.LapsListView.Delete()
		this.TyreCompoundsListView.Delete()
		this.UsedTyreSetsListView.Delete()
		this.FuelDataListView.Delete()
		this.TyreDataListView.Delete()

		this.iSession := session
		this.iSessionMode := false
		this.iSessionLoaded := false
		this.iSessionExported := false

		this.Control["runDropDown"].Delete()
		this.Control["runDropDown"].Add([translate("All")])
		this.Control["runDropDown"].Choose(1)

		this.Control["driverDropDown"].Delete()
		this.Control["driverDropDown"].Add([translate("All")])
		this.Control["driverDropDown"].Choose(1)

		this.iDrivers := []

		this.iRuns := CaseInsenseWeakMap()
		this.iLaps := CaseInsenseWeakMap()

		this.iRunning := Map()

		this.iPitstops := CaseInsenseMap()
		this.iLastPitstopUpdate := false

		this.iLastLap := false
		this.iCurrentRun := false

		this.iTelemetryDatabase := false
		this.iPressuresDatabase := false
		this.iSessionStore := false

		this.iSelectedReport := false
		this.iSelectedChartType := false
		this.iSelectedDetailReport := false

		this.iSelectedRun := false
		this.iSelectedDrivers := false

		this.initializeSimulator(this.Simulator, this.Car, this.Track, true)

		this.iWeather := "Dry"
		this.iWeather10Min := "Dry"
		this.iWeather30Min := "Dry"
		this.iAirTemperature := 23
		this.iTrackTemperature := 27

		this.iTyreCompound := "Dry"
		this.iTyreCompoundColor := "Black"

		this.iDataWeather := "Dry"
		this.iDataTyreCompound := "Dry"
		this.iDataTyreCompoundColor := "Black"

		this.iSelectedRun := false

		this.showChart(false)
		this.showDetails(false, false)
	}

	initializeSimulator(simulator, car, track, force := false) {
		local row, compound

		if simulator
			simulator := SessionDatabase.getSimulatorName(simulator)

		if (force || !this.Simulator || (this.Simulator != simulator) || (this.Car != car) || (this.Track != track)) {
			this.iSimulator := simulator
			this.iCar := car
			this.iTrack := track

			if (this.Simulator = "") {
				this.iSimulator := false
				this.iCar := false
				this.iTrack := false
			}

			car := this.Car
			track := this.Track

			this.loadSimulator(simulator, true)

			if car
				this.loadCar(car)

			if track
				this.loadTrack(track)
		}
	}

	initializeReports() {
		local raceData, drivers, positions, times

		if !this.Simulator {
			raceData := true
			drivers := false
			positions := false
			times := false

			this.ReportViewer.loadReportData(false, &raceData, &drivers, &positions, &times)

			this.initializeSimulator(getMultiMapValue(raceData, "Session", "Simulator", false)
								   , getMultiMapValue(raceData, "Session", "Car")
								   , getMultiMapValue(raceData, "Session", "Track"))
		}
	}

	getPreviousLap(lap) {
		local laps := this.Laps

		lap := (lap.Nr - 1)

		while (lap > 0)
			if laps.Has(lap)
				return laps[lap]
			else
				lap -= 1

		return false
	}

	updateUsedTyreSets(all := false) {
		local tyreSets := WeakMap()
		local currentRun := this.CurrentRun
		local ignore, tyreSet, run

		this.UsedTyreSetsListView.Delete()

		this.iUsedTyreSets := tyreSets

		if currentRun
			loop currentRun.Nr
				if this.Runs.Has(A_Index) {
					run := this.Runs[A_Index]

					tyreSets[run.Compound . "." . run.TyreSet] := {Nr: run.TyreSet, Compound: run.Compound, Laps: (run.TyreLaps + run.Laps.Length)}
				}

		for ignore, tyreSet in tyreSets
			this.UsedTyreSetsListView.Add("", translate(tyreSet.Compound), tyreSet.Nr, tyreSet.Laps)

		this.UsedTyreSetsListView.ModifyCol()

		loop this.UsedTyreSetsListView.GetCount("Col")
			this.UsedTyreSetsListView.ModifyCol(A_Index, "AutoHdr")
	}

	createRun(lapNumber) {
		local newRun := {Nr: (this.CurrentRun ? (this.CurrentRun.Nr + 1) : 1), Lap: lapNumber, StartTime: A_Now, TyreLaps: 0
					   , Driver: "-", FuelInitial: "-", FuelConsumption: 0.0, Accidents: 0, Weather: "-", Compound: "-", TyreSet: "-"
					   , AvgLapTime: "-", Potential: "-", RaceCraft: "-", Speed: "-", Consistency: "-", CarControl: "-"
					   , StartPosition: "-", EndPosition: "-", Laps: []}

		if (newRun.Nr = 1) {
			if (this.Control["tyreCompoundDropDown"].Value > 2)
				newRun.TyreMode := "Manual"
			else
				newRun.TyreMode := "Auto"
		}
		else
			switch this.Control["tyreCompoundDropDown"].Value {
				case 1:
					newRun.TyreMode := false
				case 2:
					newRun.TyreMode := "Auto"
				default:
					newRun.TyreMode := "Manual"
			}

		this.Runs[newRun.Nr] := newRun

		this.RunsListView.Add("Check", newRun.Nr, "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-", "-")

		newRun.Row := this.RunsListView.GetCount()

		this.RunsListView.ModifyCol()

		loop this.RunsListView.GetCount("Col")
			this.RunsListView.ModifyCol(A_Index, "AutoHdr")

		return newRun
	}

	modifyRun(run) {
		local tyreCompound := false
		local tyreSet := false
		local driver := false
		local laps, numLaps, lapTimes, airTemperatures, trackTemperatures
		local ignore, lap, consumption, weather, fuelAmount

		run.FuelConsumption := 0.0
		run.Accidents := 0
		run.Weather := ""

		laps := run.Laps
		numLaps := laps.Length

		lapTimes := []
		airTemperatures := []
		trackTemperatures := []

		for ignore, lap in laps {
			if (lap.Nr > run.Lap) {
				consumption := lap.FuelConsumption

				if isNumber(consumption) {
					run.FuelConsumption += ((this.getPreviousLap(lap).FuelConsumption = "-") ? (consumption * 2) : consumption)

					if (run.FuelInitial = "-")
						run.FuelInitial := (lap.FuelRemaining + run.FuelConsumption)
				}
			}

			if (A_Index == 1)
				run.StartPosition := lap.Position
			else if (A_Index == numLaps)
				run.EndPosition := lap.Position

			if lap.Accident
				run.Accidents += 1

			lapTimes.Push(lap.Laptime)
			airTemperatures.Push(lap.AirTemperature)
			trackTemperatures.Push(lap.TrackTemperature)

			weather := lap.Weather

			if (run.Weather = "")
				run.Weather := weather
			else if !inList(string2Values(",", run.Weather), weather)
				run.Weather .= (", " . weather)

			tyreCompound := lap.Compound
			tyreSet := lap.TyreSet

			if lap.HasProp("Driver")
				driver := lap.Driver
		}

		if (this.SessionActive && (run.TyreMode = "Auto")) {
			if (tyreCompound && (run.Compound != tyreCompound))
				run.Compound := tyreCompound

			if (tyreSet && (run.TyreSet != tyreSet)) {
				run.TyreSet := tyreSet

				if this.UsedTyreSets.Has(tyreCompound . "." . tyreSet)
					run.TyreLaps := this.UsedTyreSets[tyreCompound . "." . tyreSet].Laps
				else
					run.TyreLaps := 0
			}
		}

		if driver
			run.Driver := driver

		run.AvgLaptime := Round(average(laptimes), 1)
		run.BestLaptime := Round(minimum(laptimes), 1)
		run.FuelConsumption := Round(run.FuelConsumption, 2)
		run.AirTemperature := Round(average(airTemperatures), 1)
		run.TrackTemperature := Round(average(trackTemperatures), 1)

		if (run.Compound != "-") {
			this.iTyreCompound := compound(run.Compound)
			this.iTyreCompoundColor := compoundColor(run.Compound)
		}

		fuelAmount := run.FuelInitial

		if isNumber(fuelAmount)
			fuelAmount := displayValue("Float", convertUnit("Volume", fuelAmount))

		this.RunsListView.Modify(run.Row, "", run.Nr, (run.Driver != "-") ? run.Driver.FullName : "-"
											, values2String(", ", collect(string2Values(",", run.Weather), translate)*)
											, translate(run.Compound), run.TyreSet, run.Laps.Length
											, fuelAmount, displayValue("Float", convertUnit("Volume", run.FuelConsumption))
											, lapTimeDisplayValue(run.AvgLaptime)
											, run.Accidents, run.Potential, run.RaceCraft, run.Speed, run.Consistency, run.CarControl)
	}

	requireRun(lapNumber, new := false) {
		if (new || !this.CurrentRun)
			this.iCurrentRun := this.createRun(lapNumber)

		return this.CurrentRun
	}

	newRun(lap, transferLap := false, newTyres?) {
		local currentRun := this.CurrentRun
		local tyreCompound := "-"
		local tyreSet := "-"
		local newRun, engineerPID, tyrePressures, tyre, tyreCompound, tyreCompoundColor

		if !isSet(newTyres)
			newTyres := (this.Control["tyreCompoundDropDown"].Value > 1)

		if (currentRun && (currentRun.Laps.Length = 0)) {
			this.RunsListView.Delete(currentRun.Row)
			this.Runs.Delete(currentRun.Nr)

			if (currentRun.Nr > 1)
				currentRun := this.Runs[currentRun.Nr - 1]
			else
				currentRun := false

			this.iCurrentRun := currentRun
		}

		newRun := this.requireRun(lap, true)

		if (currentRun && transferLap && this.LastLap) {
			currentRun.Laps.RemoveAt(currentRun.Laps.Length)
			newRun.Laps.Push(this.LastLap)

			this.LastLap.Run := newRun

			this.modifyRun(currentRun)
		}

		if (newTyres || !currentRun) {
			tyreCompound := this.Control["tyreCompoundDropDown"].Value

			if (newRun.TyreMode = "Manual") {
				tyreSet := this.Control["tyreSetEdit"].Value

				newRun.Compound := this.TyreCompounds[tyreCompound - 2]

				if (isInteger(tyreSet) && (tyreSet > 0))
					newRun.TyreSet := tyreSet

				if (newRun.Nr > 1) {
					engineerPID := ProcessExist("Race Engineer.exe")

					if engineerPID {
						tyrePressures := []

						for ignore, tyre in ["FL", "FR", "RL", "RR"] {
							tyre := internalValue("Float", this.Control["tyrePressure" . tyre . "Edit"].Text)

							if isNumber(tyre)
								tyrePressures.Push(convertUnit("Pressure", tyre, false))
							else {
								tyrePressures := false

								break
							}
						}

						if tyrePressures {
							splitCompound(newRun.Compound, &tyreCompound, &tyreCompoundColor)

							tyreSet := newRun.TyreSet

							if (tyreSet = "-")
								tyreSet := false
							else if this.UsedTyreSets.Has(newRun.Compound . "." . tyreSet)
								newRun.TyreLaps := this.UsedTyreSets[newRun.Compound . "." . tyreSet].Laps

							messageSend(kFileMessage, "Race Engineer"
									  , "performService:" . values2String(";", lap, 0
																			 , tyreCompound, tyreCompoundColor, tyreSet, tyrePressures*)
									  , engineerPID)
						}
					}
				}
			}
		}
		else if currentRun {
			newRun.TyreMode := false

			newRun.Compound := currentRun.Compound
			newRun.TyreSet := currentRun.TyreSet
			newRun.TyreLaps := (currentRun.TyreLaps + currentRun.Laps.Length)
		}

		return newRun
	}

	createLap(run, lapNumber) {
		local newLap := {Run: run, Nr: lapNumber, Weather: "-", Grip: "-", Laptime: "-", FuelConsumption: "-", FuelRemaining: "-"
					   , Compound: "-", TyreSet: "-", Pressures: "-,-,-,-", Temperatures: "-,-,-,-", State: "Valid", Accident: ""
					   , Electronics: false, Tyres: false
					   , HotPressures: false, ColdPressures: false, PressureLosses: false}

		newLap.Run := run
		run.Laps.Push(newLap)

		this.Laps[newLap.Nr] := newLap

		this.LapsListView.Add("Check", newLap.Nr, run.Nr, "-", "-", "-", "-", "-", "-, -, -, -", "", "")

		newLap.Row := this.LapsListView.GetCount()

		this.LapsListView.ModifyCol()

		loop this.LapsListView.GetCount("Col")
			this.LapsListView.ModifyCol(A_Index, "AutoHdr")

		return newLap
	}

	modifyLap(lap) {
		local sessionStore := this.SessionStore
		local fuelConsumption := lap.FuelConsumption
		local remainingFuel := lap.FuelRemaining
		local pressures := string2Values(",", lap.Pressures)
		local pressure, row

		if isNumber(remainingFuel)
			remainingFuel := displayValue("Float", convertUnit("Volume", remainingFuel))

		if isNumber(fuelConsumption)
			fuelConsumption := displayValue("Float", convertUnit("Volume", fuelConsumption))

		loop 4 {
			pressure := pressures[A_Index]

			if isNumber(pressure)
				pressures[A_Index] := displayValue("Float", convertUnit("Pressure", pressure))
		}

		row := sessionStore.query("Lap.Data", {Where: {Lap: lap.Nr}})

		if (row.Length > 0) {
			row := row[1]

			row["Lap.State"] := lap.State
			row["Lap.Valid"] := (lap.State != "Invalid")

			sessionStore.changed("Lap.Data")
		}

		this.LapsListView.Modify(lap.Row, (lap.State != "Valid") ? "-Check" : ""
										, lap.Nr, lap.Run.Nr, translate(lap.Weather), translate(lap.Grip)
										, lapTimeDisplayValue(lap.Laptime), displayNullValue(fuelConsumption), remainingFuel
										, values2String(", ", pressures*)
										, (lap.State != "Invalid") ? "" : translate("x"), lap.Accident ? translate("x") : "")
	}

	requireLap(lapNumber) {
		if this.Laps.Has(lapNumber)
			return this.Laps[lapNumber]
		else
			return this.createLap((lapNumber = 1) ? this.newRun(lapNumber, false, true) : this.requireRun(lapNumber), lapNumber)
	}

	addLap(lapNumber, data) {
		local lap := this.requireLap(lapNumber)
		local selectedLap := this.LapsListView.GetNext()
		local selectedRun := this.RunsListView.GetNext()
		local damage, pLap, fuelConsumption, car, run

		if selectedLap
			selectedLap := (selectedLap == this.LapsListView.GetCount())

		if selectedRun
			selectedRun := (selectedRun == this.RunsListView.GetCount())

		lap.Data := data

		run := lap.Run

		lap.Driver := this.createDriver({Forname: getMultiMapValue(data, "Stint Data", "DriverForname")
									   , Surname: getMultiMapValue(data, "Stint Data", "DriverSurname")
									   , Nickname: getMultiMapValue(data, "Stint Data", "DriverNickname")
									   , ID: SessionDatabase.ID})

		lap.Compound := compound(getMultiMapValue(data, "Car Data", "TyreCompound")
							   , getMultiMapValue(data, "Car Data", "TyreCompoundColor"))
		lap.TyreSet := getMultiMapValue(data, "Car Data", "TyreSet", "-")

		damage := 0

		for ignore, value in string2Values(",", getMultiMapValue(data, "Car Data", "BodyworkDamage"))
			damage += value

		for ignore, value in string2Values(",", getMultiMapValue(data, "Car Data", "SuspensionDamage"))
			damage += value

		lap.Damage := damage

		if ((lap.Nr == 1) && (damage > 0))
			lap.Accident := true
		else {
			pLap := this.getPreviousLap(lap)

			if ((lap.Nr > 1) && pLap && (damage > pLap.Damage))
				lap.Accident := true
			else
				lap.Accident := false
		}

		lap.EngineDamage := getMultiMapValue(data, "Car Data", "EngineDamage", 0)

		lap.FuelRemaining := Round(getMultiMapValue(data, "Car Data", "FuelRemaining"), 1)

		if ((lap.Nr == 1) || ((lap.Run.Laps.Length > 0) && (lap.Run.Laps[1] == lap)))
			lap.FuelConsumption := "-"
		else {
			pLap := this.getPreviousLap(lap)

			fuelConsumption := (pLap ? (pLap.FuelRemaining - lap.FuelRemaining) : 0)

			lap.FuelConsumption := ((fuelConsumption > 0) ? Round(fuelConsumption, 2) : "-")
		}

		lap.Laptime := Round(getMultiMapValue(data, "Stint Data", "LapLastTime") / 1000, 1)

		lap.RemainingSessionTime := getMultiMapValue(data, "Session Data", "SessionTimeRemaining")
		lap.RemainingDriverTime := getMultiMapValue(data, "Stint Data", "DriverTimeRemaining", "-")

		if (lap.RemainingDriverTime != "-")
			lap.RemainingDriverTime := Round(lap.RemainingDriverTime / 1000)

		lap.RemainingStintTime := getMultiMapValue(data, "Stint Data", "StintTimeRemaining", "-")

		if (lap.RemainingStintTime != "-")
			lap.RemainingStintTime := Round(lap.RemainingStintTime / 1000)

		lap.Map := getMultiMapValue(data, "Car Data", "Map", "n/a")
		lap.TC := getMultiMapValue(data, "Car Data", "TC", "n/a")
		lap.ABS := getMultiMapValue(data, "Car Data", "ABS", "n/a")

		lap.Weather := getMultiMapValue(data, "Weather Data", "Weather")
		lap.Weather10Min := getMultiMapValue(data, "Weather Data", "Weather10Min")
		lap.Weather30Min := getMultiMapValue(data, "Weather Data", "Weather30Min")
		lap.AirTemperature := Round(getMultiMapValue(data, "Weather Data", "Temperature"), 1)
		lap.TrackTemperature := Round(getMultiMapValue(data, "Track Data", "Temperature"), 1)
		lap.Grip := getMultiMapValue(data, "Track Data", "Grip")

		car := getMultiMapValue(data, "Position Data", "Driver.Car")

		lap.Position := (car ? getMultiMapValue(data, "Position Data", "Car." . car . ".Position") : false)

		this.iWeather := lap.Weather
		this.iAirTemperature := lap.AirTemperature
		this.iTrackTemperature := lap.TrackTemperature
		this.iWeather10Min := lap.Weather10Min
		this.iWeather30Min := lap.Weather30Min

		this.iLastLap := lap

		this.modifyLap(lap)
		this.modifyRun(lap.Run)

		this.updateReports()

		this.syncSessionStore()

		if (selectedLap && (this.SelectedDetailReport = "Lap")) {
			this.LapsListView.Modify(this.LapsListView.GetCount(), "Select Vis")

			this.showLapDetails(this.LastLap)
		}

		if (selectedRun && (this.SelectedDetailReport = "Run")) {
			this.RunsListView.Modify(this.RunsListView.GetCount(), "Select Vis")

			this.showRunDetails(this.CurrentRun)
		}

		this.updatePitstops(lap, data)

		this.updateUsedTyreSets()

		this.updateState()
	}

	updatePitstops(lap, data) {
		local carID, delta, pitstops, pitstop

		if !this.iLastPitstopUpdate {
			this.iLastPitstopUpdate := Round(lap.RemainingSessionTime / 1000)

			delta := 0
		}
		else {
			delta := (this.iLastPitstopUpdate - Round(lap.RemainingSessionTime / 1000))

			this.iLastPitstopUpdate -= delta
		}

		loop getMultiMapValue(data, "Position Data", "Car.Count", 0) {
			if (getMultiMapValue(data, "Position Data", "Car." . A_Index . ".InPitlane", false)
			 || getMultiMapValue(data, "Position Data", "Car." . A_Index . ".InPit", false)) {
				carID := getMultiMapValue(data, "Position Data", "Car." . A_Index . ".ID", A_Index)

				pitstops := this.Pitstops[carID]

				if (pitstops.Length = 0)
					pitstops.Push(PracticeCenter.Pitstop(carID, this.iLastPitstopUpdate, lap.Nr))
				else {
					pitstop := pitstops[pitstops.Length]

					if ((pitstop.Time - pitstop.Duration - (delta + 20)) < this.iLastPitstopUpdate)
						pitstop.Duration := (pitstop.Duration + delta)
					else
						pitstops.Push(PracticeCenter.Pitstop(carID, this.iLastPitstopUpdate, lap.Nr))
				}
			}
		}
	}

	updateRunning(lapNumber, data) {
		local runnings := this.Running
		local driverCar := getMultiMapValue(data, "Position Data", "Driver.Car", 0)
		local running := getMultiMapValue(data, "Position Data", "Car." . driverCar . ".Lap.Running", false)
		local trackRange := (getMultiMapValue(data, "Track Data", "Length", 1.0) / 100)
		local pressures, temperatures

		static lastRunning := 0

		this.updatePitstops(this.requireLap(lapNumber), data)

		if running {
			running := Floor(running * 100)

			if (running > lastRunning) {
				loop (running - lastRunning - 1) {
					lastRunning += 1

					if runnings.Has(lastRunning)
						runnings.Delete(lastRunning)
				}
			}
			else
				loop (100 - lastRunning - 1) {
					lastRunning += 1

					if runnings.Has(lastRunning)
						runnings.Delete(lastRunning)
				}

			lastRunning := running

			if !this.Running.Has(running)
				this.Running[running] := Database.Row("Running", running * trackRange)

			running := this.Running[running]

			pressures := string2Values(",", getMultiMapValue(data, "Car Data", "TyrePressure", "-,-,-,-"))

			running["Tyre.Pressure.Hot.Front.Left"] := null(pressures[1])
			running["Tyre.Pressure.Hot.Front.Right"] := null(pressures[2])
			running["Tyre.Pressure.Hot.Rear.Left"] := null(pressures[3])
			running["Tyre.Pressure.Hot.Rear.Right"] := null(pressures[4])
			running["Tyre.Pressure.Hot.Average"] := null(average([pressures[1], pressures[2], pressures[3], pressures[4]]))
			running["Tyre.Pressure.Hot.Front.Average"] := null(average([pressures[1], pressures[2]]))
			running["Tyre.Pressure.Hot.Rear.Average"] := null(average([pressures[3], pressures[4]]))

			temperatures := string2Values(",", getMultiMapValue(data, "Car Data", "TyreTemperature", "-,-,-,-"))

			running["Tyre.Temperature.Core.Front.Left"] := null(temperatures[1])
			running["Tyre.Temperature.Core.Front.Right"] := null(temperatures[2])
			running["Tyre.Temperature.Core.Rear.Left"] := null(temperatures[3])
			running["Tyre.Temperature.Core.Rear.Right"] := null(temperatures[4])
			running["Tyre.Temperature.Core.Average"] := null(average([temperatures[1], temperatures[2], temperatures[3], temperatures[4]]))
			running["Tyre.Temperature.Core.Front.Average"] := null(average([temperatures[1], temperatures[2]]))
			running["Tyre.Temperature.Core.Rear.Average"] := null(average([temperatures[3], temperatures[4]]))

			temperatures := string2Values(",", getMultiMapValue(data, "Car Data", "TyreInnerTemperature", "-,-,-,-"))

			running["Tyre.Temperature.Inner.Front.Left"] := null(temperatures[1])
			running["Tyre.Temperature.Inner.Front.Right"] := null(temperatures[2])
			running["Tyre.Temperature.Inner.Rear.Left"] := null(temperatures[3])
			running["Tyre.Temperature.Inner.Rear.Right"] := null(temperatures[4])
			running["Tyre.Temperature.Inner.Average"] := null(average([temperatures[1], temperatures[2], temperatures[3], temperatures[4]]))
			running["Tyre.Temperature.Inner.Front.Average"] := null(average([temperatures[1], temperatures[2]]))
			running["Tyre.Temperature.Inner.Rear.Average"] := null(average([temperatures[3], temperatures[4]]))

			temperatures := string2Values(",", getMultiMapValue(data, "Car Data", "TyreMiddleTemperature", "-,-,-,-"))

			running["Tyre.Temperature.Middle.Front.Left"] := null(temperatures[1])
			running["Tyre.Temperature.Middle.Front.Right"] := null(temperatures[2])
			running["Tyre.Temperature.Middle.Rear.Left"] := null(temperatures[3])
			running["Tyre.Temperature.Middle.Rear.Right"] := null(temperatures[4])
			running["Tyre.Temperature.Middle.Average"] := null(average([temperatures[1], temperatures[2], temperatures[3], temperatures[4]]))
			running["Tyre.Temperature.Middle.Front.Average"] := null(average([temperatures[1], temperatures[2]]))
			running["Tyre.Temperature.Middle.Rear.Average"] := null(average([temperatures[3], temperatures[4]]))

			temperatures := string2Values(",", getMultiMapValue(data, "Car Data", "TyreOuterTemperature", "-,-,-,-"))

			running["Tyre.Temperature.Outer.Front.Left"] := null(temperatures[1])
			running["Tyre.Temperature.Outer.Front.Right"] := null(temperatures[2])
			running["Tyre.Temperature.Outer.Rear.Left"] := null(temperatures[3])
			running["Tyre.Temperature.Outer.Rear.Right"] := null(temperatures[4])
			running["Tyre.Temperature.Outer.Average"] := null(average([temperatures[1], temperatures[2], temperatures[3], temperatures[4]]))
			running["Tyre.Temperature.Outer.Front.Average"] := null(average([temperatures[1], temperatures[2]]))
			running["Tyre.Temperature.Outer.Rear.Average"] := null(average([temperatures[3], temperatures[4]]))

			temperatures := string2Values(",", getMultiMapValue(data, "Car Data", "BrakeTemperature", "-,-,-,-"))

			running["Brake.Temperature.Front.Left"] := null(temperatures[1])
			running["Brake.Temperature.Front.Right"] := null(temperatures[2])
			running["Brake.Temperature.Rear.Left"] := null(temperatures[3])
			running["Brake.Temperature.Rear.Right"] := null(temperatures[4])
			running["Brake.Temperature.Average"] := null(average([temperatures[1], temperatures[2], temperatures[3], temperatures[4]]))
			running["Brake.Temperature.Front.Average"] := null(average([temperatures[1], temperatures[2]]))
			running["Brake.Temperature.Rear.Average"] := null(average([temperatures[3], temperatures[4]]))

			if (this.SelectedReport = "Running")
				this.showReport("Running", true)
		}
	}

	addStandings(lap, data) {
		local sessionStore := this.SessionStore
		local prefix, driver, category, carIDs

		carIDs := CaseInsenseWeakMap()

		loop getMultiMapValue(lap.Data, "Position Data", "Car.Count")
			carIDs[A_Index] := getMultiMapValue(lap.Data, "Position Data", "Car." . A_Index . ".ID")

		lap := lap.Nr

		prefix := ("Standings.Lap." . lap . ".Car.")

		sessionStore.add("Delta.Data"
					   , Database.Row("Lap", lap, "Type", "Standings.Behind"
									, "Car", getDeprecatedValue(data, "Position"
																	, "Position.Standings.Class.Behind.Car", "Position.Standings.Behind.Car")
									, "ID", carIDs[getDeprecatedValue(data, "Position"
																		  , "Position.Standings.Class.Behind.Car", "Position.Standings.Behind.Car")]
									, "Delta", Round(getDeprecatedValue(data, "Position"
																			, "Position.Standings.Class.Behind.Delta"
																			, "Position.Standings.Behind.Delta") / 1000, 2)
									, "Distance", Round(getDeprecatedValue(data, "Position"
																			   , "Position.Standings.Class.Behind.Distance"
																			   , "Position.Standings.Behind.Distance"), 2)))

		sessionStore.add("Delta.Data"
					   , Database.Row("Lap", lap, "Type", "Standings.Ahead"
									, "Car", getDeprecatedValue(data, "Position"
																	, "Position.Standings.Class.Ahead.Car", "Position.Standings.Ahead.Car")
									, "ID", carIDs[getDeprecatedValue(data, "Position"
																		  , "Position.Standings.Class.Ahead.Car", "Position.Standings.Ahead.Car")]
									, "Delta", Round(getDeprecatedValue(data, "Position"
																			, "Position.Standings.Class.Ahead.Delta"
																			, "Position.Standings.Ahead.Delta") / 1000, 2)
									, "Distance", Round(getDeprecatedValue(data, "Position"
																			   , "Position.Standings.Class.Ahead.Distance"
																			   , "Position.Standings.Ahead.Distance"), 2)))

		sessionStore.add("Delta.Data"
					   , Database.Row("Lap", lap, "Type", "Standings.Leader"
									, "Car", getDeprecatedValue(data, "Position"
																    , "Position.Standings.Class.Leader.Car", "Position.Standings.Leader.Car")
									, "ID", carIDs[getDeprecatedValue(data, "Position"
																		  , "Position.Standings.Class.Leader.Car", "Position.Standings.Leader.Car")]
									, "Delta", Round(getDeprecatedValue(data, "Position"
																			, "Position.Standings.Class.Leader.Delta"
																			, "Position.Standings.Leader.Delta") / 1000, 2)
									, "Distance", Round(getDeprecatedValue(data, "Position"
																			   , "Position.Standings.Class.Leader.Distance"
																			   , "Position.Standings.Leader.Distance"), 2)))

		sessionStore.add("Delta.Data"
					   , Database.Row("Lap", lap, "Type", "Track.Behind"
									, "Car", getMultiMapValue(data, "Position", "Position.Track.Behind.Car")
									, "ID", carIDs[getMultiMapValue(data, "Position", "Position.Track.Behind.Car")]
									, "Delta", Round(getMultiMapValue(data, "Position", "Position.Track.Behind.Delta") / 1000, 2)
									, "Distance", Round(getMultiMapValue(data, "Position", "Position.Track.Behind.Distance"), 2)))

		sessionStore.add("Delta.Data"
					   , Database.Row("Lap", lap, "Type", "Track.Ahead"
									, "Car", getMultiMapValue(data, "Position", "Position.Track.Ahead.Car")
									, "ID", carIDs[getMultiMapValue(data, "Position", "Position.Track.Ahead.Car")]
									, "Delta", Round(getMultiMapValue(data, "Position", "Position.Track.Ahead.Delta") / 1000, 2)
									, "Distance", Round(getMultiMapValue(data, "Position", "Position.Track.Ahead.Distance"), 2)))

		prefix := ("Standings.Lap." . lap . ".Car.")

		loop getMultiMapValue(data, "Standings", prefix . "Count") {
			driver := computeDriverName(getMultiMapValue(data, "Standings", prefix . A_Index . ".Driver.Forname")
									  , getMultiMapValue(data, "Standings", prefix . A_Index . ".Driver.Surname")
									  , getMultiMapValue(data, "Standings", prefix . A_Index . ".Driver.Nickname"))
			category := getMultiMapValue(data, "Standings", prefix . A_Index . ".Driver.Category", "Unknown")

			if (category = "Unknown")
				category := kNull

			sessionStore.add("Standings.Data"
						   , Database.Row("Lap", lap, "Car", A_Index, "ID", carIDs[A_Index], "Driver", driver, "Category", category
										, "Position", getMultiMapValue(data, "Standings", prefix . A_Index . ".Position")
										, "Time", Round(getMultiMapValue(data, "Standings", prefix . A_Index . ".Time") / 1000, 1)
										, "Laps", Round(getMultiMapValue(data, "Standings", prefix . A_Index . ".Laps"), 1)
										, "Delta", Round(getMultiMapValue(data, "Standings", prefix . A_Index . ".Delta") / 1000, 2)))
		}
	}

	addTelemetry(lap, simulator, car, track, weather, airTemperature, trackTemperature
			   , fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
			   , compound, compoundColor, pressures, temperatures, wear, state) {
		local telemetryDB := this.TelemetryDatabase
		local electronicsTable := this.TelemetryDatabase.Database.Tables["Electronics"]
		local tyresTable := this.TelemetryDatabase.Database.Tables["Tyres"]
		local driverID := lap.Run.Driver.ID
		local telemetry, telemetryData, pressuresData, temperaturesData, wearData, recentLap, tyreLaps
		local newRun, oldRun

		this.initializeSimulator(simulator, car, track)

		if (pitstop && (this.Control["runModeDropDown"].Value = 2))
			this.newRun(lap.Nr, true)

		if (this.Control["tyreCompoundDropDown"].Value = 2) {
		}

		if (lap.Pressures = "-,-,-,-")
			lap.Pressures := pressures

		if (lap.Temperatures = "-,-,-,-")
			lap.Temperatures := temperatures

		if ((lap.FuelConsumption = "-") && (isNumber(fuelConsumption) && (fuelConsumption > 0)))
			lap.FuelConsumption := fuelConsumption

		while (tyresTable.Length < (lap.Nr - 1)) {
			recentLap := this.Laps[tyresTable.Length + 1]
			telemetry := recentLap.Data

			tyreLaps := (recentLap.Run.TyreLaps + (recentLap.Nr - recentLap.Run.Lap) + 2)

			telemetryData := [simulator, car, track
							, getMultiMapValue(telemetry, "Weather Data", "Weather", "Dry")
							, getMultiMapValue(telemetry, "Weather Data", "Temperature", 23)
							, getMultiMapValue(telemetry, "Track Data", "Temperature", 27)
							, "-"
							, getMultiMapValue(telemetry, "Car Data", "FuelRemaining", "-")
							, getMultiMapValue(telemetry, "Stint Data", "LapLastTime", "-")
							, "-"
							, getMultiMapValue(telemetry, "Car Data", "Map", "n/a")
							, getMultiMapValue(telemetry, "Car Data", "TC", "n/a")
							, getMultiMapValue(telemetry, "Car Data", "ABS", "n/a")
							, getMultiMapValue(telemetry, "Car Data", "TyreCompound", "Dry")
							, getMultiMapValue(telemetry, "Car Data", "TyreCompoundColor", "Black")
							, tyreLaps
							, getMultiMapValue(telemetry, "Car Data", "TyrePressure", "-,-,-,-")
							, getMultiMapValue(telemetry, "Car Data", "TyreTemperature", "-,-,-,-")
							, getMultiMapValue(telemetry, "Car Data", "TyreWear", "null,null,null,null")
							, "Unknown"]

			recentLap.State := "Unknown"
			recentLap.TelemetryData := values2String("|||", telemetryData*)

			if (electronicsTable.Length < recentLap.Nr)
				telemetryDB.addElectronicEntry(telemetryData[4], telemetryData[5], telemetryData[6]
											 , telemetryData[14], telemetryData[15]
											 , telemetryData[11], telemetryData[12], telemetryData[13]
											 , kNull, telemetryData[8], telemetryData[9], driverID)

			pressuresData := collect(string2Values(",", telemetryData[16]), null)
			temperaturesData := collect(string2Values(",", telemetryData[17]), null)
			wearData := collect(string2Values(",", telemetryData[18]), null)

			if (tyresTable.Length < recentLap.Nr)
				telemetryDB.addTyreEntry(telemetryData[4], telemetryData[5], telemetryData[6]
									   , telemetryData[14], telemetryData[15], tyreLaps
									   , pressuresData[1], pressuresData[2], pressuresData[3], pressuresData[4]
									   , temperaturesData[1], temperaturesData[2], temperaturesData[3], temperaturesData[4]
									   , wearData[1], wearData[2], wearData[3], wearData[4], kNull, telemetryData[8], telemetryData[9]
									   , driverID)

			this.modifyLap(recentLap)
		}

		lap.State := state

		tyreLaps := (lap.Run.TyreLaps + (lap.Nr - lap.Run.Lap) + 1)

		lap.TelemetryData := values2String("|||", simulator, car, track, weather, airTemperature, trackTemperature
												, fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
												, compound, compoundColor, tyreLaps, pressures, temperatures, wear, state)

		if (electronicsTable.Length < lap.Nr)
			telemetryDB.addElectronicEntry(weather, airTemperature, trackTemperature, compound, compoundColor
										 , map, tc, abs, fuelConsumption, fuelRemaining, lapTime
										 , driverID)

		pressures := collect(string2Values(",", pressures), null)
		temperatures := collect(string2Values(",", temperatures), null)
		wear := collect(string2Values(",", wear), null)

		if (tyresTable.Length < lap.Nr)
			telemetryDB.addTyreEntry(weather, airTemperature, trackTemperature, compound, compoundColor, tyreLaps
								   , pressures[1], pressures[2], pressures[3], pressures[4]
								   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
								   , wear[1], wear[2], wear[3], wear[4], fuelConsumption, fuelRemaining, lapTime
								   , driverID)

		this.modifyLap(lap)
		this.modifyRun(lap.Run)

		this.updateState()
	}

	addPressures(lap, simulator, car, track, weather, airTemperature, trackTemperature
			   , compound, compoundColor, coldPressures, hotPressures, pressuresLosses) {
		local pressuresTable := this.PressuresDatabase.Database.Tables["Tyres.Pressures"]
		local driverID := lap.Run.Driver.ID
		local pressures, pressuresData

		while (pressuresTable.Length < (lap.Nr - 1)) {
			pressures := this.Laps[pressuresTable.Length + 1].Data

			pressuresData := [simulator, car, track
							, getMultiMapValue(pressures, "Weather Data", "Weather", "Dry")
							, getMultiMapValue(pressures, "Weather Data", "Temperature", 23)
							, getMultiMapValue(pressures, "Track Data", "Temperature", 27)
							, getMultiMapValue(pressures, "Car Data", "TyreCompound", "Dry")
							, getMultiMapValue(pressures, "Car Data", "TyreCompoundColor", "Black")
							, "-,-,-,-"
							, getMultiMapValue(pressures, "Car Data", "TyrePressure", "-,-,-,-")
							, "null,null,null,null"]

			this.Laps[pressuresTable.Length + 1].PressuresData := values2String("|||", pressuresData*)

			this.PressuresDatabase.updatePressures(pressuresData[4], pressuresData[5], pressuresData[6]
												 , pressuresData[7], pressuresData[8]
												 , collect(string2Values(",",  pressuresData[9]), null)
												 , collect(string2Values(",",  pressuresData[10]), null)
												 , collect(string2Values(",",  pressuresData[11]), null)
												 , driverID)
		}

		lap.PressuresData := values2String("|||", simulator, car, track, weather, airTemperature, trackTemperature
												, compound, compoundColor, coldPressures, hotPressures, pressuresLosses)

		this.PressuresDatabase.updatePressures(weather, airTemperature, trackTemperature, compound, compoundColor
											 , collect(string2Values(",", coldPressures), null)
											 , collect(string2Values(",", hotPressures), null)
											 , collect(string2Values(",", pressuresLosses), null)
											 , driverID)

		if (lap.Pressures = "-,-,-,-") {
			lap.Pressures := hotPressures

			this.modifyLap(lap)
			this.modifyRun(lap.Run)

			this.updateState()
		}
	}

	analyzeData(weather, tyreCompound, tyreCompoundColor, &fuelLaps, &tyreLaps) {
		local telemetryDB := this.TelemetryDatabase
		local simulator := this.Simulator
		local car := this.Car
		local track := this.Track
		local curDrivers := telemetryDB.Drivers
		local hasData := false
		local map, fuel, ignore, entry, index

		fuelLaps := CaseInsenseMap()
		tyreLaps := CaseInsenseMap()

		telemetryDB.setDrivers(this.Drivers ? ((this.Drivers.Length > 0) ? collect(this.Drivers, (d) => d.ID) : false) : false)

		try {
			for ignore, entry in telemetryDB.getMapLapTimes(weather, tyreCompound, tyreCompoundColor) {
				map := entry["Map"]

				if !fuelLaps.Has(map)
					fuelLaps[map] := collect(kFuelBuckets, always.Bind(false))

				index := Min(kFuelBuckets.Length, Floor(entry["Fuel.Remaining"] / kFuelBucketSize) + 1)

				if (fuelLaps[map][index] != false)
					fuelLaps[map][index] := Min(entry["Lap.Time"], fuelLaps[map][index])
				else
					fuelLaps[map][index] := entry["Lap.Time"]

				hasData := true
			}

			for ignore, entry in telemetryDB.getTyreLapTimes(weather, tyreCompound, tyreCompoundColor, true) {
				fuel := (Floor(entry["Fuel.Remaining"] / kFuelBucketSize) * kFuelBucketSize)

				if !tyreLaps.Has(fuel)
					tyreLaps[fuel] := collect(kTyreLapsBuckets, always.Bind(false))

				index := Min(kTyreLapsBuckets.Length, Floor(entry["Tyre.Laps"] / kTyreLapsBucketSize) + 1)

				if (tyreLaps[fuel][index] != false)
					tyreLaps[fuel][index] := Min(entry["Lap.Time"], tyreLaps[fuel][index])
				else
					tyreLaps[fuel][index] := entry["Lap.Time"]

				hasData := true
			}
		}
		finally {
			telemetryDB.setDrivers(curDrivers)
		}

		return hasData
	}

	analyzeTelemetry() {
		local fuelLaps, tyreLaps, map, fuel, data

		if (this.Control["practiceCenterTabView"].Value = 4) {
			this.analyzeData(this.Weather["Data"], this.TyreCompound["Data"], this.TyreCompoundColor["Data"], &fuelLaps, &tyreLaps)

			this.FuelDataListView.Delete()
			this.TyreDataListView.Delete()

			for map, data in fuelLaps {
				loop data.Length
					if !data[A_Index]
						data[A_Index] := ""
					else
						data[A_Index] := displayValue("Time", data[A_Index])

				this.FuelDataListView.Add("", map, data*)
			}

			for fuel, data in tyreLaps {
				loop data.Length
					if !data[A_Index]
						data[A_Index] := ""
					else
						data[A_Index] := displayValue("Time", data[A_Index])

				this.TyreDataListView.Add("", displayValue("Float", convertUnit("Volume", fuel)) . A_Space . SubStr(getUnit("Volume"), 1, 1), data*)
			}

			this.FuelDataListView.ModifyCol()

			loop this.FuelDataListView.GetCount("Col")
				this.FuelDataListView.ModifyCol(A_Index, "AutoHdr")

			this.TyreDataListView.ModifyCol()

			loop this.TyreDataListView.GetCount("Col")
				this.TyreDataListView.ModifyCol(A_Index, "AutoHdr")
		}

		if (this.SelectedDetailReport = "Data")
			this.showDataSummary()
	}

	exportSession(wait := false) {
		exportSessionAsync() {
			local progressWindow := showProgress({color: "Green", title: translate("Export to Database")})
			local telemetryDB := TelemetryDatabase(this.Simulator, this.Car, this.Track)
			local tyresDB := TyresDatabase()
			local row := 0
			local locked := false
			local count := 0
			local lap, driver, telemetryData, pressures, temperatures, wear, pressuresData, info

			while (row := this.LapsListView.GetNext(row, "C"))
				count += 1

			try {
				row := 0

				while (row := this.LapsListView.GetNext(row, "C")) {
					showProgress({progress: Round((A_Index / count) * 100), color: "Green", message: translate("Lap:") . A_Space . A_Index})

					Sleep(50)

					lap := this.LapsListView.GetText(row, 1)
					lap := (this.Laps.Has(lap) ? this.Laps[lap] : false)

					if lap {
						driver := lap.Run.Driver.ID

						telemetryData := string2Values("|||", lap.TelemetryData)

						telemetryDB.addElectronicEntry(telemetryData[4], telemetryData[5], telemetryData[6], telemetryData[14], telemetryData[15]
													 , telemetryData[11], telemetryData[12], telemetryData[13], telemetryData[7], telemetryData[8], telemetryData[9]
													 , driver)

						pressures := string2Values(",", telemetryData[17])
						temperatures := string2Values(",", telemetryData[18])
						wear := string2Values(",", telemetryData[19])

						telemetryDB.addTyreEntry(telemetryData[4], telemetryData[5], telemetryData[6]
											   , telemetryData[14], telemetryData[15], telemetryData[16]
											   , pressures[1], pressures[2], pressures[3], pressures[4]
											   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
											   , wear[1], wear[2], wear[3], wear[4]
											   , telemetryData[7], telemetryData[8], telemetryData[9]
											   , driver)

						pressuresData := string2Values("|||", lap.PressuresData)

						if !locked
							if tyresDB.lock(pressuresData[1], pressuresData[2], pressuresData[3], false)
								locked := true
							else
								Sleep(200)

						if locked {
							coldPressures := string2Values(",", pressuresData[9])
							hotPressures := string2Values(",", pressuresData[10])

							if (isNumber(coldPressures[1]) && isNumber(hotPressures[1]))
								tyresDB.updatePressures(pressuresData[1], pressuresData[2], pressuresData[3]
													  , pressuresData[4], pressuresData[5], pressuresData[6]
													  , pressuresData[7], pressuresData[8]
													  , coldPressures, hotPressures, false, driver)
						}
					}
				}
			}
			finally {
				if locked
					try {
						tyresDB.unlock()
					}
					catch Any as exception {
						logError(exception)
					}
			}

			this.iSessionExported := true

			if (this.SessionMode = "Loaded") {
				info := readMultiMap(this.SessionLoaded . "Practice.info")

				setMultiMapValue(info, "Session", "Exported", true)

				writeMultiMap(this.SessionLoaded . "Practice.info", info)
			}

			loop this.RunsListView.GetCount()
				this.RunsListView.Modify(A_Index, "-Check")

			loop this.LapsListView.GetCount()
				this.LapsListView.Modify(A_Index, "-Check")

			hideProgress()

			this.updateState()
		}

		if wait
			exportSessionAsync()
		else
			this.pushTask(exportSessionAsync)
	}

	updateReports(redraw := false) {
		local selectedLap, selectedRun

		if this.HasData {
			if !this.SelectedReport
				this.selectReport("Running")

			this.showReport(this.SelectedReport, true)
		}
		else if redraw
			this.showChart(false)

		if redraw {
			selectedLap := this.LapsListView.GetNext(0)

			if (selectedLap && (this.SelectedDetailReport = "Lap"))
				this.showLapDetails(this.Laps[selectedLap])
			else {
				selectedRun := this.RunsListView.GetNext(0)

				if (selectedRun && (this.SelectedDetailReport = "Run"))
					this.showRunDetails(this.Runs[selectedRun])
				else if (this.SelectedDetailReport && this.iSelectedDetailHTML) {
					this.DetailsViewer.document.open()
					this.DetailsViewer.document.write(this.iSelectedDetailHTML)
					this.DetailsViewer.document.close()
				}
			}
		}
	}

	getCar(lap, carID, &car, &carNumber, &carName, &driverForname, &driverSurname, &driverNickname) {
		return this.ReportViewer.getCar(lap.Nr, &carID, &car, &carNumber, &carName, &driverForname, &driverSurname, &driverNickname)
	}

	getStandings(lap, &cars, &ids, &overallPositions, &classPositions, &carNumbers, &carNames
					, &driverFornames, &driverSurnames, &driverNicknames, &driverCategories
					, sort := "Position") {
		local tCars := true
		local tIDs := true
		local tOPositions := true
		local tCPositions := true
		local tCarNumbers := carNumbers
		local tCarNames := carNames
		local tDriverFornames := driverFornames
		local tDriverSurnames := driverSurnames
		local tDriverNicknames := driverNicknames
		local tDriverCategories := driverNicknames
		local index, multiClass, raceData, tTimes, carTimes, car, cTimes, ignore, times

		multiClass := this.ReportViewer.getStandings(lap.Nr, &tCars, &tIDs, &tOPositions, &tCPositions, &tCarNumbers, &tCarNames
														   , &tDriverFornames, &tDriverSurnames, &tDriverNicknames, &tDriverCategories)

		if cars
			cars := []

		if ids
			ids := []

		if overallPositions
			overallPositions := []

		if classPositions
			classPositions := []

		if carNumbers
			carNumbers := []

		if carNames
			carNames := []

		if driverFornames
			driverFornames := []

		if driverSurnames
			driverSurnames := []

		if driverNicknames
			driverNicknames := []

		if driverCategories
			driverCategories := []

		if (sort = "Position") {
			if (tCars.Length > 0)
				loop tOPositions.Length {
					index := inList(tOPositions, A_Index)

					if index {
						if cars
							cars.Push(tCars[index])

						if ids
							ids.Push(tIDs[index])

						if overallPositions
							overallPositions.Push(tOPositions[index])

						if classPositions
							classPositions.Push(tCPositions[index])

						if carNumbers
							carNumbers.Push(tCarNumbers[index])

						if carNames
							carNames.Push(tCarNames[index])

						if driverFornames
							driverFornames.Push(tDriverFornames[index])

						if driverSurnames
							driverSurnames.Push(tDriverSurnames[index])

						if driverNicknames
							driverNicknames.Push(tDriverNicknames[index])

						if driverCategories
							driverCategories.Push(tDriverCategories[index])
					}
				}
			}
			else {
				carTimes := []

				this.ReportViewer.loadData(false, &raceData := true, &ignore := false, &ignore := false, &tTimes := true, &ignore := false)

				if (cars && (tTimes.Length > 0)) {
					loop getMultiMapValue(raceData, "Cars", "Count", 0) {
						car := A_Index
						cTimes := []

						for ignore, times in tTimes
							if (times.Has(car) && isNumber(times[car]) && (times[car] > 0))
								cTimes.Push(times[car])

						carTimes.Push(Array(car, minimum(cTimes)))
					}

					bubbleSort(&carTimes, (c1, c2) => (c1[2] > c2[2]))
				}

				loop carTimes.Length {
					index := carTimes[A_Index][1]

					if index {
						if cars
							cars.Push(tCars[index])

						if ids
							ids.Push(tIDs[index])

						if overallPositions
							overallPositions.Push(tOPositions[index])

						if classPositions
							classPositions.Push(tCPositions[index])

						if carNumbers
							carNumbers.Push(tCarNumbers[index])

						if carNames
							carNames.Push(tCarNames[index])

						if driverFornames
							driverFornames.Push(tDriverFornames[index])

						if driverSurnames
							driverSurnames.Push(tDriverSurnames[index])

						if driverNicknames
							driverNicknames.Push(tDriverNicknames[index])

						if driverCategories
							driverCategories.Push(tDriverCategories[index])
					}
				}
			}

		return multiClass
	}

	computeDriverTime(driver) {
		local duration := 0
		local run

		if this.CurrentRun
			loop this.CurrentRun.Nr {
				run := this.Runs[A_Index]

				if (run.Driver == driver)
					duration += this.computeDuration(run)
			}

		return duration
	}

	computeDuration(run) {
		local duration, ignore, lap

		if run.HasProp("Duration")
			return run.Duration
		else {
			duration := 0

			for ignore, lap in run.Laps
				duration += lap.LapTime

			if (run != this.CurrentRun)
				run.Duration := duration

			return duration
		}
	}

	computeEndTime(run, update := false) {
		local time, duration

		if run.HasProp("EndTime")
			return run.EndTime
		else {
			time := this.computeStartTime(run)
			duration := this.computeDuration(run)

			time := DateAdd(time, duration, "Seconds")

			if update
				run.EndTime := time

			return time
		}
	}

	computeStartTime(run) {
		local time

		if run.HasProp("StartTime")
			return run.StartTime
		else {
			if (run.Nr = 1) {
				run.StartTime := (A_Now . "")

				time := run.StartTime
			}
			else
				time := this.computeEndTime(this.Runs[run.Nr - 1], true)

			if (run != this.CurrentRun)
				run.StartTime := time

			return time
		}
	}

	computeLapStatistics(driver, laps, &potential, &raceCraft, &speed, &consistency, &carControl) {
		local raceData := true
		local drivers := false
		local positions := true
		local times := true
		local car, cars, potentials, raceCrafts, speeds, consistencies, carControls, count, oldLapSettings

		this.ReportViewer.loadReportData(laps, &raceData, &drivers, &positions, &times)

		car := getMultiMapValue(raceData, "Cars", "Driver", false)

		if car {
			cars := []

			loop getMultiMapValue(raceData, "Cars", "Count")
				cars.Push(A_Index)

			potentials := false
			raceCrafts := false
			speeds := false
			consistencies := false
			carControls := false

			count := laps.Length
			laps := []

			loop count
				laps.Push(A_Index)

			oldLapSettings := (this.ReportViewer.Settings.Has("Laps") ? this.ReportViewer.Settings["Laps"] : false)

			try {
				this.ReportViewer.Settings["Laps"] := laps

				this.ReportViewer.getDriverStatistics(raceData, cars, positions, times, &potentials, &raceCrafts, &speeds, &consistencies, &carControls)
			}
			finally {
				if oldLapSettings
					this.ReportViewer.Settings["Laps"] := oldLapSettings
				else
					this.ReportViewer.Settings.Delete("Laps")
			}

			potential := Round(potentials[car], 2)
			raceCraft := Round(raceCrafts[car], 2)
			speed := Round(speeds[car], 2)
			consistency := Round(consistencies[car], 2)
			carControl := Round(carControls[car], 2)
		}
		else {
			potential := 0.0
			raceCraft := 0.0
			speed := 0.0
			consistency := 0.0
			carControl := 0.0
		}
	}

	updateRunStatistics(run) {
		local laps := []
		local ignore, lap, potential, raceCraft, speed, consistency, carControl

		for ignore, lap in run.Laps
			laps.Push(lap.Nr)

		potential := false
		raceCraft := false
		speed := false
		consistency := false
		carControl := false

		this.computeLapStatistics(run.Driver, laps, &potential, &raceCraft, &speed, &consistency, &carControl)

		run.Potential := potential
		run.RaceCraft := raceCraft
		run.Speed := speed
		run.Consistency := consistency
		run.CarControl := carControl
	}

	updateDriverStatistics(driver) {
		local laps := []
		local accidents := 0
		local ignore, lap, potential, raceCraft, speed, consistency, carControl

		for ignore, lap in driver.Laps {
			laps.Push(lap.Nr)

			if lap.Accident
				accidents += 1
		}

		potential := false
		raceCraft := false
		speed := false
		consistency := false
		carControl := false

		this.computeLapStatistics(driver, laps, &potential, &raceCraft, &speed, &consistency, &carControl)

		driver.Potential := potential
		driver.RaceCraft := raceCraft
		driver.Speed := speed
		driver.Consistency := consistency
		driver.CarControl := carControl
		driver.Accidents := accidents
	}

	updateStatistics() {
		updateStatisticsAsync() {
			local progressWindow := showProgress({color: "Green", title: translate("Updating Run Statistics")})
			local currentRun := this.CurrentRun
			local count, run, ignore, driver

			if currentRun {
				count := currentRun.Nr

				loop count {
					showProgress({progress: Round((A_Index / count) * 50), color: "Green", message: translate("Stint: ") . A_Index})

					if this.Runs.Has(A_Index) {
						run := this.Runs[A_Index]

						this.updateRunStatistics(run)

						this.RunsListView.Modify(run.Row, "Col11", run.Potential, run.RaceCraft, run.Speed, run.Consistency, run.CarControl)
					}

					Sleep(200)
				}
			}

			showProgress({title: translate("Updating Driver Statistics"), message: translate("...")})

			count := this.Drivers.Length

			for ignore, driver in this.Drivers {
				showProgress({progress: 50 + Round((A_Index / count) * 50), color: "Green", message: translate("Driver: ") . driver.FullName})

				this.updateDriverStatistics(driver)

				Sleep(200)
			}

			hideProgress()
		}

		this.pushTask(updateStatisticsAsync)
	}

	saveSession(copy := false) {
		saveSessionAsync(copy := false) {
			local info, directory, translator, folder, session

			if this.SessionActive {
				this.syncSessionStore(true)

				info := newMultiMap()

				setMultiMapValue(info, "Session", "Session", this.Session)
				setMultiMapValue(info, "Session", "Exported", this.SessionExported)
				setMultiMapValue(info, "Session", "Date", this.Date)
				setMultiMapValue(info, "Session", "Simulator", this.Simulator)
				setMultiMapValue(info, "Session", "Car", this.Car)
				setMultiMapValue(info, "Session", "Track", this.Track)

				setMultiMapValue(info, "Weather", "Weather", this.Weather)
				setMultiMapValue(info, "Weather", "Weather10Min", this.Weather10Min)
				setMultiMapValue(info, "Weather", "Weather30Min", this.Weather30Min)
				setMultiMapValue(info, "Weather", "AirTemperature", this.AirTemperature)
				setMultiMapValue(info, "Weather", "TrackTemperature", this.TrackTemperature)

				writeMultiMap(this.SessionDirectory . "Practice.info", info)
			}
			else
				this.SessionStore.flush()

			if copy {
				directory := ((this.SessionMode = "Loaded") ? this.SessionLoaded : this.SessionDirectory)

				this.Window.Opt("+OwnDialogs")

				translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

				OnMessage(0x44, translator)
				folder := DirSelect("*" directory, 0, translate("Select target folder..."))
				OnMessage(0x44, translator, 0)

				if (folder != "")
					try {
						DirCopy(directory, folder . "\Practice " . FormatTime(this.Date, "yyyy-MMM-dd"), 1)
					}
					catch Any as exception {
						logError(exception)
					}
			}
		}

		this.pushTask(saveSessionAsync.Bind(copy))
	}

	clearSession() {
		clearSessionAsync() {
			this.initializeSession()

			this.analyzeTelemetry()

			this.updateState()
		}

		this.pushTask(clearSessionAsync)
	}

	loadDrivers() {
		local ignore, driver

		this.iDrivers := []

		for ignore, driver in this.SessionStore.Tables["Driver.Data"]
			this.createDriver({Forname: driver["Forname"], Surname: driver["Surname"], Nickname: driver["Nickname"]
							 , Fullname: computeDriverName(driver["Forname"], driver["Surname"], driver["Nickname"])
							 , ID: driver["ID"]})
	}

	loadLaps() {
		local ignore, lap, newLap, engineDamage

		this.iLaps := CaseInsenseWeakMap()

		for ignore, lap in this.SessionStore.Tables["Lap.Data"] {
			newLap := {Nr: lap["Nr"], Run: lap["Run"], Laptime: lap["Lap.Time"], Position: lap["Position"], Grip: lap["Grip"]
					 , Map: lap["Map"], TC: lap["TC"], ABS: lap["ABS"], State: lap["Lap.State"]
					 , Weather: lap["Weather"], AirTemperature: lap["Temperature.Air"], TrackTemperature: lap["Temperature.Track"]
					 , FuelRemaining: lap["Fuel.Remaining"], FuelConsumption: lap["Fuel.Consumption"]
					 , Damage: lap["Damage"], EngineDamage: lap["EngineDamage"]
					 , Accident: lap["Accident"]
					 , Compound: compound(lap["Tyre.Compound"], lap["Tyre.Compound.Color"]), TyreSet: lap["Tyre.Set"]
					 , Pressures: values2String(",", lap["Tyre.Pressure.Hot.Front.Left"], lap["Tyre.Pressure.Hot.Front.Right"]
												   , lap["Tyre.Pressure.Hot.Rear.Left"], lap["Tyre.Pressure.Hot.Rear.Right"])
					 , Temperatures: values2String(",", lap["Tyre.Temperature.Front.Left"], lap["Tyre.Temperature.Front.Right"]
													  , lap["Tyre.Temperature.Rear.Left"], lap["Tyre.Temperature.Rear.Right"])
					 , Data: false, TelemetryData: lap["Data.Telemetry"], PressuresData: lap["Data.Pressures"]}

			if isNull(newLap.Map)
				newLap.Map := "n/a"

			if isNull(newLap.TC)
				newLap.TC := "n/a"

			if isNull(newLap.ABS)
				newLap.ABS := "n/a"

			if isNull(newLap.EngineDamage)
				newLap.EngineDamage := 0

			if isNull(newLap.Position)
				newLap.Position := "-"

			if isNull(newLap.Laptime)
				newLap.Laptime := "-"

			if isNull(newLap.FuelConsumption)
				newLap.FuelConsumption := "-"

			if isNull(newLap.FuelRemaining)
				newLap.FuelRemaining := "-"

			if isNull(newLap.AirTemperature)
				newLap.AirTemperature := "-"

			if isNull(newLap.TrackTemperature)
				newLap.TrackTemperature := "-"

			this.Laps[newLap.Nr] := newLap
			this.iLastLap := newLap
		}
	}

	loadRuns() {
		local ignore, run, newRun, driver, laps, lap, runNr, runLap, airTemperatures, trackTemperatures
		local currentRun, lastLap, remainingFuel, fuelConsumption

		this.iRuns := CaseInsenseWeakMap()

		for ignore, run in this.SessionStore.Tables["Run.Data"] {
			driver := this.createDriver({Forname: run["Driver.Forname"], Surname: run["Driver.Surname"], Nickname: run["Driver.Nickname"], ID: run["Driver.ID"]})

			newRun := {Nr: run["Nr"], Lap: run["Lap"], Driver: driver, Weather: run["Weather"]
					 , FuelInitial: run["Fuel.Initial"], FuelConsumption: run["Fuel.Consumption"]
					 , Compound: compound(run["Tyre.Compound"], run["Tyre.Compound.Color"]), TyreSet: run["Tyre.Set"], TyreLaps: run["Tyre.Laps"]
					 , AvgLaptime: run["Lap.Time.Average"], BestLaptime: run["Lap.Time.Best"]
					 , Accidents: run["Accidents"], StartPosition: run["Position.Start"], EndPosition: run["Position.End"]
					 , StartTime: run["Time.Start"], EndTime: run["Time.End"]}

			if isNull(newRun.StartTime)
				newRun.StartTime := false

			if isNull(newRun.EndTime)
				newRun.EndTime := false

			driver.Runs.Push(newRun)
			laps := []

			newRun.Laps := laps

			runNr := newRun.Nr
			runLap := newRun.Lap

			airTemperatures := []
			trackTemperatures := []

			loop {
				if !this.Laps.Has(runLap)
					break

				lap := this.Laps[runLap]

				airTemperatures.Push(lap.AirTemperature)
				trackTemperatures.Push(lap.TrackTemperature)

				if isObject(lap.Run)
					newRun.Lap := (runLap + 1)
				else
					if (lap.Run != runNr)
						break
					else {
						lap.Run := newRun
						laps.Push(lap)

						driver.Laps.Push(lap)
					}

				runLap += 1
			}

			newRun.AirTemperature := Round(average(airTemperatures), 1)
			newRun.TrackTemperature := Round(average(trackTemperatures), 1)

			newRun.Potential := "-"
			newRun.RaceCraft := "-"
			newRun.Speed := "-"
			newRun.Consistency := "-"
			newRun.CarControl := "-"

			if isNull(newRun.AvgLaptime)
				newRun.AvgLaptime := "-"

			if isNull(newRun.BestLaptime)
				newRun.BestLaptime := "-"

			if isNull(newRun.FuelInitial)
				newRun.FuelInitial := "-"

			if isNull(newRun.FuelConsumption)
				newRun.FuelConsumption := "-"

			if isNull(newRun.StartPosition)
				newRun.StartPosition := "-"

			if isNull(newRun.EndPosition)
				newRun.EndPosition := "-"

			this.Runs[newRun.Nr] := newRun

			this.iCurrentRun := newRun
		}

		currentRun := this.CurrentRun

		if currentRun
			loop currentRun.Nr
				if this.Runs.Has(A_Index) {
					run := this.Runs[A_Index]
					run.Row := (this.RunsListView.GetCount() + 1)

					this.RunsListView.Add(this.SessionExported ? "" : "Check"
										, run.Nr, run.Driver.FullName
										, values2String(", ", collect(string2Values(",", run.Weather), translate)*)
										, translate(run.Compound), run.TyreSet, run.Laps.Length
										, isNumber(run.FuelInitial) ? displayValue("Float", convertUnit("Volume", run.FuelInitial)) : run.FuelInitial
										, isNumber(run.FuelConsumption) ? displayValue("Float", convertUnit("Volume", run.FuelConsumption)) : run.FuelConsumption
										, lapTimeDisplayValue(run.AvgLaptime)
										, run.Accidents, run.Potential, run.RaceCraft, run.Speed, run.Consistency, run.CarControl)
				}

		this.RunsListView.ModifyCol()

		loop this.RunsListView.GetCount("Col")
			this.RunsListView.ModifyCol(A_Index, "AutoHdr")

		lastLap := this.LastLap

		if lastLap
			loop lastLap.Nr
				if this.Laps.Has(A_Index) {
					lap := this.Laps[A_Index]
					lap.Row := (this.LapsListView.GetCount() + 1)

					remainingFuel := lap.FuelRemaining

					if isNumber(remainingFuel)
						remainingFuel := displayValue("Float", convertUnit("Volume", remainingFuel))

					fuelConsumption := lap.FuelConsumption

					if isNumber(fuelConsumption)
						fuelConsumption := displayValue("Float", convertUnit("Volume", fuelConsumption))

					this.LapsListView.Add((this.SessionExported || (lap.State != "Valid")) ? "" : "Check"
										, lap.Nr, lap.Run.Nr, translate(lap.Weather), translate(lap.Grip)
										, lapTimeDisplayValue(lap.Laptime), displayNullValue(fuelConsumption), remainingFuel, "-, -, -, -"
										, (lap.State != "Invalid") ? "" : translate("x"), lap.Accident ? translate("x") : "")
				}

		this.LapsListView.ModifyCol()

		loop this.LapsListView.GetCount("Col")
			this.LapsListView.ModifyCol(A_Index, "AutoHdr")
	}

	loadTelemetry() {
		local lastLap := this.LastLap
		local lap, telemetryData

		if lastLap
			loop lastLap.Nr
				if this.Laps.Has(A_Index) {
					lap := this.Laps[A_Index]

					telemetryData := string2Values("|||", lap.TelemetryData)

					telemetryData.RemoveAt(16)

					this.addTelemetry(lap, telemetryData*)
				}
	}

	loadPressures() {
		local lastLap := this.LastLap
		local lap

		if lastLap
			loop lastLap.Nr
				if this.Laps.Has(A_Index) {
					lap := this.Laps[A_Index]

					this.addPressures(lap, string2Values("|||", lap.PressuresData)*)
				}
	}

	loadSession() {
		loadSessionAsync() {
			local directory := ((this.SessionMode = "Loaded") ? this.SessionLoaded : this.iSessionDirectory)
			local folder, info, lastLap, currentRun, translator

			this.Window.Opt("+OwnDialogs")

			translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

			OnMessage(0x44, translator)
			folder := DirSelect("*" . directory, 0, translate("Select Practice folder..."))
			OnMessage(0x44, translator, 0)

			if (folder != "") {
				folder := (folder . "\")

				info := readMultiMap(folder . "Practice.info")

				if (info.Count == 0) {
					OnMessage(0x44, translateOkButton)
					MsgBox(translate("This is not a valid folder with a saved session."), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)
				}
				else {
					this.initializeSession(getMultiMapValue(info, "Session", "Session", "Practice"))

					this.iSessionMode := "Loaded"
					this.iSessionLoaded := folder

					this.iSessionExported := getMultiMapValue(info, "Session", "Exported", true)
					this.iDate := getMultiMapValue(info, "Session", "Date", A_Now)
					this.iWeather := getMultiMapValue(info, "Weather", "Weather", false)
					this.iWeather10Min := getMultiMapValue(info, "Weather", "Weather10Min", false)
					this.iWeather30Min := getMultiMapValue(info, "Weather", "Weather30Min", false)
					this.iAirTemperature := getMultiMapValue(info, "Weather", "AirTemperature", false)
					this.iTrackTemperature := getMultiMapValue(info, "Weather", "TrackTemperature", false)

					this.loadDrivers()
					this.loadLaps()
					this.loadRuns()
					this.loadTelemetry()
					this.loadPressures()

					this.ReportViewer.setReport(folder . "Race Report")

					this.initializeReports()

					if !this.Weather {
						lastLap := this.LastLap

						if lastLap {
							this.iWeather := lastLap.Weather
							this.iAirTemperature := lastLap.AirTemperature
							this.iTrackTemperature := lastLap.TrackTemperature
							this.iWeather10Min := lastLap.Weather10Min
							this.iWeather30Min := lastLap.Weather30Min
						}
					}

					if !this.TyreCompound {
						currentRun := this.CurrentRun

						if currentRun {
							this.iTyreCompound := compound(currentRun.Compound)
							this.iTyreCompoundColor := compoundColor(currentRun.Compound)
						}
					}

					this.updateReports()

					this.updateUsedTyreSets()

					this.analyzeTelemetry()

					this.updateState()
				}
			}
		}

		this.pushTask(loadSessionAsync)
	}

	showChart(drawChartFunction) {
		local before, after, html

		this.ChartViewer.document.open()

		if (drawChartFunction && (drawChartFunction != "")) {
			before := "
			(
			<html>
			    <meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: #%headerBackColor%; }
						.rowStyle { font-size: 11px; background-color: #%evenRowBackColor%; }
						.oddRowStyle { font-size: 11px; background-color: #%oddRowBackColor%; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart);
			)"

			before := substituteVariables(before, {headerBackColor: this.Window.Theme.ListBackColor["Header"]
												 , evenRowBackColor: this.Window.Theme.ListBackColor["EvenRow"]
												 , oddRowBackColor: this.Window.Theme.ListBackColor["OddRow"]})

			after := "
			(
					</script>
				</head>
				<body style='background-color: #%backColor%' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: #%headerBackColor%; }
						.rowStyle { font-size: 11px; background-color: #%evenRowBackColor%; }
						.oddRowStyle { font-size: 11px; background-color: #%oddRowBackColor%; }
					</style>
					<div id="chart_id" style="width: %width%px; height: %height%px"></div>
				</body>
			</html>
			)"

			html := (before . drawChartFunction . substituteVariables(after, {width: (this.ChartViewer.getWidth() - 5)
																			, height: (this.ChartViewer.getHeight() - 5)
																			, backColor: this.Window.AltBackColor
																			, headerBackColor: this.Window.Theme.ListBackColor["Header"]
																			, evenRowBackColor: this.Window.Theme.ListBackColor["EvenRow"]
																			, oddRowBackColor: this.Window.Theme.ListBackColor["OddRow"]}))

			this.ChartViewer.document.write(html)
		}
		else {
			html := "<html><body style='background-color: #%backColor%' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

			this.ChartViewer.document.write(substituteVariables(html, {backColor: this.Window.AltBackColor}))
		}

		this.ChartViewer.document.close()
	}

	showDataPlot(data, xAxis, yAxises, defaults := false) {
		local double := (yAxises.Length > 1)
		local minValue := kUndefined
		local maxValue := kUndefined
		local drawChartFunction := ""
		local ignore, yAxis, settingsLaps, laps, ignore, lap, first, values, value, minValue, maxValue
		local series, vAxis, index

		drawChartFunction .= "function drawChart() {"
		drawChartFunction .= "`nvar data = new google.visualization.DataTable();"

		if (this.SelectedChartType = "Bubble")
			drawChartFunction .= ("`ndata.addColumn('string', 'ID');")

		drawChartFunction .= ("`ndata.addColumn('number', '" . xAxis . "');")

		for ignore, yAxis in yAxises {
			drawChartFunction .= ("`ndata.addColumn('number', '" . yAxis . "');")
		}

		settingsLaps := (this.ReportViewer.Settings.Has("Laps") ? this.ReportViewer.Settings["Laps"] : false)
		laps := false

		if (settingsLaps && (settingsLaps.Length > 0)) {
			laps := CaseInsenseWeakMap()

			for ignore, lap in settingsLaps
				laps[lap] := lap
		}

		drawChartFunction .= "`ndata.addRows(["
		first := true

		for ignore, values in data {
			if (laps && !laps.Has(A_Index))
				continue

			if !first
				drawChartFunction .= ",`n"

			first := false

			if (this.SelectedRun && (this.SelectedRun != this.Runs[values["Run"]]))
				value := kNull
			else if (this.SelectedDrivers && !inList(this.SelectedDrivers, this.Runs[values["Run"]].Driver))
				value := kNull
			else if values.Has(xAxis)
				value := values[xAxis]
			else if (defaults && defaults.Has(xAxis))
				value := defaults[xAxis]
			else
				value := kNull

			if !isNumber(value)
				value := kNull

			if (this.SelectedChartType = "Bubble")
				drawChartFunction .= ("['', " . convertValue(xAxis, value))
			else
				drawChartFunction .= ("[" . convertValue(xAxis, value))

			for ignore, yAxis in yAxises {
				if values.Has(yAxis)
					value := values[yAxis]
				else if (defaults && defaults.Has(yAxis))
					value := defaults[yAxis]
				else
					value := kNull

				if isNumber(value) {
					minValue := ((minValue == kUndefined) ? value : Min(minValue, value))
					maxValue := ((maxValue == kUndefined) ? value : Max(maxValue, value))
				}
				else
					value := kNull

				drawChartFunction .= (", " . convertValue(yAxis, value))
			}

			drawChartFunction .= "]"
		}

		drawChartFunction .= "`n]);"

		series := "series: {"
		vAxis := "vAxis: { "

		for ignore, yAxis in yAxises {
			if (A_Index > 1) {
				series .= ", "
				vAxis .= ", "
			}

			if (A_Index > 2)
				break

			index := A_Index - 1

			series .= (index . ": {targetAxisIndex: " . index . "}")
			vAxis .= (index . ": {title: '" . translate(yAxis) . "'}")
		}

		series .= "}"
		vAxis .= "}"

		if (this.SelectedChartType = "Scatter") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "', hAxis: { title: '" . translate(xAxis) . "' }, " . series . ", " . vAxis . "};")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.ScatterChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bar") {
			if (minValue == kUndefined)
				minValue := 0
			else
				minValue := Min(0, minValue)

			if (maxValue == kUndefined)
				maxValue := 0

			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "', hAxis: { viewWindow: {min: " . minValue . ", max: " . maxValue . "} }, vAxis: { viewWindowMode: 'pretty' } };")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bubble") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "', hAxis: { title: '" . translate(xAxis) . "', viewWindowMode: 'pretty' }, vAxis: { title: '" . translate(yAxises[1]) . "', viewWindowMode: 'pretty' }, colorAxis: { legend: {position: 'none'}, colors: ['blue', 'red'] }, sizeAxis: { maxSize: 15 } };")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BubbleChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Line") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#" . this.Window.AltBackColor . "' };")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}

		this.showChart(drawChartFunction)
	}

	showDetails(report, details, charts*) {
		local chartID := 1
		local html := (details ? details : "")
		local script, ignore, chart

		getTableCSS() {
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

			return substituteVariables(script, {altBackColor: this.Window.AltBackColor, backColor: this.Window.BackColor
											  , textColor: this.Window.Theme.TextColor
											  , headerBackColor: this.Window.Theme.TableColor["Header"], frameColor: this.Window.Theme.TableColor["Frame"]})
		}

		this.iSelectedDetailReport := report

		if details {
			script := "
			(
				<meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: #%headerBackColor%; }
						.rowStyle { font-size: 11px; background-color: #%evenRowBackColor%; }
						.oddRowStyle { font-size: 11px; background-color: #%oddRowBackColor%; }
						%tableCSS%
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawCharts);

						function drawCharts() {
			)"

			script := substituteVariables(script, {tableCSS: getTableCSS()
												 , headerBackColor: this.Window.Theme.ListBackColor["Header"]
												 , evenRowBackColor: this.Window.Theme.ListBackColor["EvenRow"]
												 , oddRowBackColor: this.Window.Theme.ListBackColor["OddRow"]})

			for ignore, chart in charts
				script .= (A_Space . "drawChart" . chart[1] . "();")

			script .= "}`n"

			for ignore, chart in charts {
				if (A_Index > 0)
					script .= "`n"

				script .= chart[2]
			}

			script .= "</script></head>"
		}
		else
			script := ""

		html := ("<html>" . script . "<body style='background-color: #" . this.Window.AltBackColor . "' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #header { font-size: 12px; }</style><div>" . html . "</div></body></html>")

		this.iSelectedDetailHTML := html

		this.DetailsViewer.document.open()
		this.DetailsViewer.document.write(html)
		this.DetailsViewer.document.close()
	}

	selectReport(report) {
		if report {
			this.ReportsListView.Modify(inList(kSessionReports, report), "+Select")

			this.iSelectedReport := report
		}
		else {
			loop this.ReportsListView.GetCount()
				this.ReportsListView.Modify(A_Index, "-Select")

			this.iSelectedReport := false
		}
	}

	showOverviewReport() {
		this.selectReport("Overview")

		this.ReportViewer.showOverviewReport()

		this.updateState()
	}

	editOverviewReportSettings() {
		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showCarReport() {
		this.selectReport("Car")

		this.ReportViewer.showCarReport()

		this.updateState()
	}

	showDriverReport() {
		this.selectReport("Drivers")

		this.ReportViewer.showDriverReport()

		this.updateState()
	}

	editDriverReportSettings() {
		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Drivers", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showPositionsReport() {
		this.selectReport("Positions")

		this.ReportViewer.showPositionsReport()

		this.updateState()
	}

	editPositionsReportSettings() {
		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showLapTimesReport() {
		this.selectReport("Lap Times")

		this.ReportViewer.showLapTimesReport()

		this.updateState()
	}

	editLapTimesReportSettings() {
		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Cars", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showConsistencyReport() {
		this.selectReport("Consistency")

		this.ReportViewer.showConsistencyReport()

		this.updateState()
	}

	editConsistencyReportSettings() {
		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Cars", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showPaceReport() {
		this.selectReport("Pace")

		this.ReportViewer.showPaceReport()

		this.updateState()
	}

	editPaceReportSettings() {
		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Cars", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showPerformanceReport() {
		this.selectReport("Performance")

		this.ReportViewer.showPerformanceReport()

		this.updateState()
	}

	editPerformanceReportSettings() {
		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps", "Cars", "Classes")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showRaceReport(report) {
		local raceData, drivers, ignore

		switch report, false {
			case "Overview":
				this.showOverviewReport()
			case "Car":
				this.showCarReport()
			case "Drivers":
				if !this.ReportViewer.Settings.Has("Drivers") {
					raceData := true

					this.ReportViewer.loadReportData(false, &raceData, &ignore := false, &ignore := false, &ignore := false)

					drivers := []

					loop Min(5, getMultiMapValue(raceData, "Cars", "Count"))
						drivers.Push(A_Index)

					if !this.ReportViewer.Settings.Has("Drivers")
						this.ReportViewer.Settings["Drivers"] := drivers
				}

				this.showDriverReport()
			case "Positions":
				this.showPositionsReport()
			case "Lap Times":
				this.showLapTimesReport()
			case "Consistency":
				if !this.ReportViewer.Settings.Has("Drivers") {
					raceData := true

					this.ReportViewer.loadReportData(false, &raceData, &ingore := false, &ingore := false, &ingore := false)

					drivers := []

					loop Min(5, getMultiMapValue(raceData, "Cars", "Count"))
						drivers.Push(A_Index)

					if !this.ReportViewer.Settings.Has("Drivers")
						this.ReportViewer.Settings["Drivers"] := drivers
				}

				this.showConsistencyReport()
			case "Pace":
				this.showPaceReport()
			case "Performance":
				this.showPerformanceReport()
		}
	}

	showTelemetryReport() {
		local window := this.Window
		local xAxis, yAxises, data, lapData, defaults

		xAxis := this.iXColumns[window["dataXDropDown"].Value]
		yAxises := Array(this.iY1Columns[window["dataY1DropDown"].Value])

		if (window["dataY2DropDown"].Value > 1)
			yAxises.Push(this.iY2Columns[window["dataY2DropDown"].Value - 1])

		if (window["dataY3DropDown"].Value > 1)
			yAxises.Push(this.iY3Columns[window["dataY3DropDown"].Value - 1])

		if (window["dataY4DropDown"].Value > 1)
			yAxises.Push(this.iY4Columns[window["dataY4DropDown"].Value - 1])

		if (window["dataY5DropDown"].Value > 1)
			yAxises.Push(this.iY5Columns[window["dataY5DropDown"].Value - 1])

		if (window["dataY6DropDown"].Value > 1)
			yAxises.Push(this.iY6Columns[window["dataY6DropDown"].Value - 1])

		lapData := this.SessionStore.Tables["Lap.Data"]

		if (this.SelectedReport = "Running") {
			running := this.Running
			data := []

			loop 100
				if running.Has(A_Index)
					data.Push(running[A_Index])

			if (lapData.Length > 0)
				defaults := lapData[lapData.Length]

			this.showDataPlot(data, xAxis, yAxises, defaults?)
		}
		else
			this.showDataPlot(lapData, xAxis, yAxises)

		this.updateState()
	}

	showRunningReport() {
		this.selectReport("Running")

		this.showTelemetryReport()

		this.updateState()
	}

	showPressuresReport() {
		this.selectReport("Pressures")

		this.showTelemetryReport()

		this.updateState()
	}

	editPressuresReportSettings() {
		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showBrakesReport() {
		this.selectReport("Brakes")

		this.showTelemetryReport()

		this.updateState()
	}

	editBrakesReportSettings() {
		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showTemperaturesReport() {
		this.selectReport("Temperatures")

		this.showTelemetryReport()

		this.updateState()
	}

	editTemperaturesReportSettings() {
		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps")
		}
		finally {
			this.Window.Unblock()
		}
	}

	showCustomReport() {
		this.selectReport("Free")

		this.showTelemetryReport()

		this.updateState()
	}

	editCustomReportSettings() {
		this.Window.Block()

		try {
			return this.ReportViewer.editReportSettings("Laps")
		}
		finally {
			this.Window.Unblock()
		}
	}

	updateSeriesSelector(report, force := false) {
		local window := this.Window
		local xChoices, y1Choices, y2Choices, y3Choices, y4Choices, y5Choices, y6Choices
		local selected, runs, names, ignore, run, driver

		if (force || (report != this.SelectedReport) || (window["dataXDropDown"].Value == 0)) {
			xChoices := []
			y1Choices := []
			y2Choices := []
			y3Choices := []
			y4Choices := []
			y5Choices := []
			y6Choices := []

			if (report = "Running") {
				xChoices := ["Running"]

				y1Choices := ["Temperature.Air", "Temperature.Track", "Fuel.Remaining", "Tyre.Laps"
							, "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
							, "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right", "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
							, "Tyre.Pressure.Loss.Front.Left", "Tyre.Pressure.Loss.Front.Right", "Tyre.Pressure.Loss.Rear.Left", "Tyre.Pressure.Loss.Rear.Right"
							, "Tyre.Temperature.Core.Average", "Tyre.Temperature.Core.Front.Average", "Tyre.Temperature.Core.Rear.Average"
							, "Tyre.Temperature.Core.Front.Left", "Tyre.Temperature.Core.Front.Right", "Tyre.Temperature.Core.Rear.Left", "Tyre.Temperature.Core.Rear.Right"
							, "Tyre.Temperature.Inner.Average", "Tyre.Temperature.Inner.Front.Average", "Tyre.Temperature.Inner.Rear.Average"
							, "Tyre.Temperature.Inner.Front.Left", "Tyre.Temperature.Inner.Front.Right", "Tyre.Temperature.Inner.Rear.Left", "Tyre.Temperature.Inner.Rear.Right"
							, "Tyre.Temperature.Middle.Average", "Tyre.Temperature.Middle.Front.Average", "Tyre.Temperature.Middle.Rear.Average"
							, "Tyre.Temperature.Middle.Front.Left", "Tyre.Temperature.Middle.Front.Right", "Tyre.Temperature.Middle.Rear.Left", "Tyre.Temperature.Middle.Rear.Right"
							, "Tyre.Temperature.Outer.Average", "Tyre.Temperature.Outer.Front.Average", "Tyre.Temperature.Outer.Rear.Average"
							, "Tyre.Temperature.Outer.Front.Left", "Tyre.Temperature.Outer.Front.Right", "Tyre.Temperature.Outer.Rear.Left", "Tyre.Temperature.Outer.Rear.Right"
							, "Tyre.Wear.Average", "Tyre.Wear.Front.Average", "Tyre.Wear.Rear.Average"
							, "Tyre.Wear.Front.Left", "Tyre.Wear.Front.Right", "Tyre.Wear.Rear.Left", "Tyre.Wear.Rear.Right"
							, "Brake.Temperature.Average", "Brake.Temperature.Front.Average", "Brake.Temperature.Rear.Average"
							, "Brake.Temperature.Front.Left", "Brake.Temperature.Front.Right", "Brake.Temperature.Rear.Left", "Brake.Temperature.Rear.Right"
							, "Brake.Wear.Average", "Brake.Wear.Front.Average", "Brake.Wear.Rear.Average"
							, "Brake.Wear.Front.Left", "Brake.Wear.Front.Right", "Brake.Wear.Rear.Left", "Brake.Wear.Rear.Right"]

				y2Choices := y1Choices
				y3Choices := y1Choices
				y4Choices := y1Choices
				y5Choices := y1Choices
				y6Choices := y1Choices
			}
			else if (report = "Pressures") {
				xChoices := ["Run", "Lap", "Lap.Time", "Tyre.Wear.Average"]

				y1Choices := ["Temperature.Air", "Temperature.Track", "Fuel.Remaining", "Tyre.Laps"
							, "Tyre.Pressure.Cold.Average", "Tyre.Pressure.Cold.Front.Average", "Tyre.Pressure.Cold.Rear.Average"
							, "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
							, "Tyre.Pressure.Cold.Front.Left", "Tyre.Pressure.Cold.Front.Right", "Tyre.Pressure.Cold.Rear.Left", "Tyre.Pressure.Cold.Rear.Right"
							, "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right", "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
							, "Tyre.Pressure.Loss.Front.Left", "Tyre.Pressure.Loss.Front.Right", "Tyre.Pressure.Loss.Rear.Left", "Tyre.Pressure.Loss.Rear.Right"
							, "Tyre.Wear.Average", "Tyre.Wear.Front.Average", "Tyre.Wear.Rear.Average"
							, "Tyre.Wear.Front.Left", "Tyre.Wear.Front.Right", "Tyre.Wear.Rear.Left", "Tyre.Wear.Rear.Right"]

				y2Choices := y1Choices
				y3Choices := y1Choices
				y4Choices := y1Choices
				y5Choices := y1Choices
				y6Choices := y1Choices
			}
			else if (report = "Brakes") {
				xChoices := ["Run", "Lap", "Lap.Time", "Brake.Wear.Average"]

				y1Choices := ["Temperature.Air", "Temperature.Track", "Fuel.Remaining"
							, "Brake.Temperature.Average", "Brake.Temperature.Front.Average", "Brake.Temperature.Rear.Average"
							, "Brake.Temperature.Front.Left", "Brake.Temperature.Front.Right", "Brake.Temperature.Rear.Left", "Brake.Temperature.Rear.Right"
							, "Brake.Wear.Average", "Brake.Wear.Front.Average", "Brake.Wear.Rear.Average"
							, "Brake.Wear.Front.Left", "Brake.Wear.Front.Right", "Brake.Wear.Rear.Left", "Brake.Wear.Rear.Right"]

				y2Choices := y1Choices
				y3Choices := y1Choices
				y4Choices := y1Choices
				y5Choices := y1Choices
				y6Choices := y1Choices
			}
			else if (report = "Temperatures") {
				xChoices := ["Run", "Lap", "Lap.Time", "Tyre.Wear.Average", "Brake.Wear.Average"]

				y1Choices := ["Temperature.Air", "Temperature.Track", "Fuel.Remaining", "Tyre.Laps"
							, "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
							, "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right", "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
							, "Tyre.Pressure.Loss.Front.Left", "Tyre.Pressure.Loss.Front.Right", "Tyre.Pressure.Loss.Rear.Left", "Tyre.Pressure.Loss.Rear.Right"
							, "Tyre.Temperature.Average", "Tyre.Temperature.Front.Average", "Tyre.Temperature.Rear.Average"
							, "Tyre.Temperature.Front.Left", "Tyre.Temperature.Front.Right", "Tyre.Temperature.Rear.Left", "Tyre.Temperature.Rear.Right"
							, "Tyre.Wear.Average", "Tyre.Wear.Front.Average", "Tyre.Wear.Rear.Average"
							, "Tyre.Wear.Front.Left", "Tyre.Wear.Front.Right", "Tyre.Wear.Rear.Left", "Tyre.Wear.Rear.Right"
							, "Brake.Temperature.Average", "Brake.Temperature.Front.Average", "Brake.Temperature.Rear.Average"
							, "Brake.Temperature.Front.Left", "Brake.Temperature.Front.Right", "Brake.Temperature.Rear.Left", "Brake.Temperature.Rear.Right"
							, "Brake.Wear.Average", "Brake.Wear.Front.Average", "Brake.Wear.Rear.Average"
							, "Brake.Wear.Front.Left", "Brake.Wear.Front.Right", "Brake.Wear.Rear.Left", "Brake.Wear.Rear.Right"]

				y2Choices := y1Choices
				y3Choices := y1Choices
				y4Choices := y1Choices
				y5Choices := y1Choices
				y6Choices := y1Choices
			}
			else if (report = "Free") {
				xChoices := ["Run", "Lap", "Lap.Time", "Lap.Valid", "Tyre.Laps", "Map", "TC", "ABS", "Temperature.Air", "Temperature.Track", "Tyre.Wear.Average", "Brake.Wear.Average"]

				y1Choices := ["Temperature.Air", "Temperature.Track", "Fuel.Initial", "Fuel.Remaining", "Fuel.Consumption"
							, "Lap.Time", "Lap.Valid", "Tyre.Laps", "Map", "TC", "ABS"
							, "Tyre.Pressure.Cold.Average", "Tyre.Pressure.Cold.Front.Average", "Tyre.Pressure.Cold.Rear.Average"
							, "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
							, "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right", "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
							, "Tyre.Pressure.Loss.Front.Left", "Tyre.Pressure.Loss.Front.Right", "Tyre.Pressure.Loss.Rear.Left", "Tyre.Pressure.Loss.Rear.Right"
							, "Tyre.Temperature.Average", "Tyre.Temperature.Front.Average", "Tyre.Temperature.Rear.Average"
							, "Tyre.Temperature.Front.Left", "Tyre.Temperature.Front.Right", "Tyre.Temperature.Rear.Left", "Tyre.Temperature.Rear.Right"
							, "Tyre.Wear.Average", "Tyre.Wear.Front.Average", "Tyre.Wear.Rear.Average"
							, "Tyre.Wear.Front.Left", "Tyre.Wear.Front.Right", "Tyre.Wear.Rear.Left", "Tyre.Wear.Rear.Right"
							, "Brake.Temperature.Average", "Brake.Temperature.Front.Average", "Brake.Temperature.Rear.Average"
							, "Brake.Temperature.Front.Left", "Brake.Temperature.Front.Right", "Brake.Temperature.Rear.Left", "Brake.Temperature.Rear.Right"
							, "Brake.Wear.Average", "Brake.Wear.Front.Average", "Brake.Wear.Rear.Average"
							, "Brake.Wear.Front.Left", "Brake.Wear.Front.Right", "Brake.Wear.Rear.Left", "Brake.Wear.Rear.Right"]

				y2Choices := y1Choices
				y3Choices := y1Choices
				y4Choices := y1Choices
				y5Choices := y1Choices
				y6Choices := y1Choices
			}

			this.iXColumns := xChoices
			this.iY1Columns := y1Choices
			this.iY2Columns := y2Choices
			this.iY3Columns := y3Choices
			this.iY4Columns := y3Choices
			this.iY5Columns := y3Choices
			this.iY6Columns := y3Choices

			window["dataXDropDown"].Delete()
			window["dataXDropDown"].Add(xChoices)
			window["dataY1DropDown"].Delete()
			window["dataY1DropDown"].Add(y1Choices)
			window["dataY2DropDown"].Delete()
			window["dataY2DropDown"].Add(concatenate([translate("None")], y2Choices))
			window["dataY3DropDown"].Delete()
			window["dataY3DropDown"].Add(concatenate([translate("None")], y3Choices))
			window["dataY4DropDown"].Delete()
			window["dataY4DropDown"].Add(concatenate([translate("None")], y4Choices))
			window["dataY5DropDown"].Delete()
			window["dataY5DropDown"].Add(concatenate([translate("None")], y5Choices))
			window["dataY6DropDown"].Delete()
			window["dataY6DropDown"].Add(concatenate([translate("None")], y6Choices))

			local dataXChoice := 0
			local dataY1Choice := 0
			local dataY2Choice := 0
			local dataY3Choice := 0
			local dataY4Choice := 0
			local dataY5Choice := 0
			local dataY6Choice := 0

			if (report = "Running") {
				window["chartTypeDropDown"].Choose(4)

				this.iSelectedChartType := "Line"

				dataXChoice := inList(xChoices, "Running")
				dataY1Choice := inList(y1Choices, "Tyre.Temperature.Core.Front.Left")
				dataY2Choice := inList(y2Choices, "Tyre.Temperature.Core.Front.Right") + 1
				dataY3Choice := inList(y3Choices, "Tyre.Temperature.Core.Rear.Left") + 1
				dataY4Choice := inList(y4Choices, "Tyre.Temperature.Core.Rear.Right") + 1
				dataY5Choice := inList(y5Choices, "Brake.Temperature.Front.Average") + 1
				dataY6Choice := inList(y6Choices, "Brake.Temperature.Rear.Average") + 1
			}
			else if (report = "Pressures") {
				window["chartTypeDropDown"].Choose(4)

				this.iSelectedChartType := "Line"

				dataXChoice := inList(xChoices, "Lap")
				dataY1Choice := inList(y1Choices, "Temperature.Air")
				dataY2Choice := inList(y2Choices, "Tyre.Pressure.Cold.Average") + 1
				dataY3Choice := inList(y3Choices, "Tyre.Pressure.Hot.Average") + 1
				dataY4Choice := 1
				dataY5Choice := 1
				dataY6Choice := 1
			}
			else if (report = "Brakes") {
				window["chartTypeDropDown"].Choose(4)

				this.iSelectedChartType := "Line"

				dataXChoice := inList(xChoices, "Lap")
				dataY1Choice := inList(y1Choices, "Temperature.Air")
				dataY2Choice := inList(y2Choices, "Brake.Temperature.Front.Average") + 1
				dataY3Choice := inList(y3Choices, "Brake.Temperature.Rear.Average") + 1
				dataY4Choice := inList(y4Choices, "Brake.Wear.Front.Average") + 1
				dataY5Choice := inList(y5Choices, "Brake.Wear.Rear.Average") + 1
				dataY6Choice := 1
			}
			else if (report = "Temperatures") {
				window["chartTypeDropDown"].Choose(1)

				this.iSelectedChartType := "Scatter"

				dataXChoice := inList(xChoices, "Lap")
				dataY1Choice := inList(y1Choices, "Temperature.Air")
				dataY2Choice := inList(y2Choices, "Tyre.Temperature.Front.Average") + 1
				dataY3Choice := inList(y3Choices, "Tyre.Temperature.Rear.Average") + 1
				dataY4Choice := 1
				dataY5Choice := 1
				dataY6Choice := 1
			}
			else if (report = "Free") {
				window["chartTypeDropDown"].Choose(4)

				this.iSelectedChartType := "Line"

				dataXChoice := inList(xChoices, "Lap")
				dataY1Choice := inList(y1Choices, "Lap.Time")
				dataY2Choice := inList(y2Choices, "Tyre.Laps") + 1
				dataY3Choice := inList(y3Choices, "Temperature.Air") + 1
				dataY4Choice := inList(y4Choices, "Temperature.Track") + 1
				dataY5Choice := inList(y5Choices, "Tyre.Pressure.Cold.Average") + 1
				dataY6Choice := inList(y6Choices, "Tyre.Pressure.Hot.Average") + 1
			}

			if (report = "Running") {
				this.iSelectedRun := false
				this.iSelectedDrivers := false
			}
			else {
				runs := []
				selected := false

				if this.CurrentRun
					loop this.CurrentRun.Nr {
						runs.Push(A_Index)

						if (this.SelectedRun && (A_Index = this.SelectedRun.Nr))
							selected := A_Index
					}

				window["runDropDown"].Delete()
				window["runDropDown"].Add(concatenate([translate("All")], runs))
				window["runDropDown"].Choose(selected + 1)

				names := [translate("All")]

				for ignore, driver in this.Drivers
					names.Push(driver.Fullname)

				window["driverDropDown"].Delete()
				window["driverDropDown"].Add(names)
				window["driverDropDown"].Choose(((this.SelectedDrivers && (this.SelectedDrivers.Length > 0)) ? inList(this.Drivers, this.SelectedDrivers[1]) : 0) + 1)
			}

			window["dataXDropDown"].Choose(dataXChoice)
			window["dataY1DropDown"].Choose(dataY1Choice)
			window["dataY2DropDown"].Choose(dataY2Choice)
			window["dataY3DropDown"].Choose(dataY3Choice)
			window["dataY4DropDown"].Choose(dataY4Choice)
			window["dataY5DropDown"].Choose(dataY5Choice)
			window["dataY6DropDown"].Choose(dataY6Choice)
		}
	}

	syncSessionStore(forSave := false) {
		local sessionStore := this.SessionStore
		local lastLap := this.LastLap
		local pressuresTable, tyresTable, newLap, lap, lapData, pressures, tyres
		local pressureFL, pressureFR, pressureRL, pressureRR
		local pressureLossFL, pressureLossFR, pressureLossRL, pressureLossRR
		local temperatureFL, temperatureFR, temperatureRL, temperatureRR
		local wearFL, wearFR, wearRL, wearRR
		local telemetry, brakeTemperatures, ignore, table, field, brakeWears
		local currentListView, lapPressures, entry, standingsData, prefix, driver, category
		local currentRun, newRun, run, runData, tries, carIDs, positions

		if lastLap
			lastLap := lastLap.Nr

		if lastLap {
			pressuresTable := this.PressuresDatabase.Database.Tables["Tyres.Pressures"]
			tyresTable := this.TelemetryDatabase.Database.Tables["Tyres"]

			newLap := (sessionStore.Tables["Lap.Data"].Length + 1)

			while (newLap <= lastLap) {
				if !this.Laps.Has(newLap) {
					newLap += 1

					continue
				}

				lap := this.Laps[newLap]

				if ((pressuresTable.Length >= newLap) && (tyresTable.Length >= newLap) && lap.HasProp("TelemetryData")) {
					lapData := Database.Row("Nr", newLap, "Lap", newLap, "Run", lap.Run.Nr, "Lap.Time", null(lap.Laptime), "Position", null(lap.Position)
									  , "Damage", lap.Damage, "EngineDamage", lap.EngineDamage, "Accident", lap.Accident
									  , "Fuel.Initial", null(lap.Run.FuelInitial), "Fuel.Consumption", null(lap.FuelConsumption)
									  , "Fuel.Remaining", null(lap.FuelRemaining), "Lap.State", lap.State, "Lap.Valid", (lap.State != "Invalid")
									  , "Weather", lap.Weather, "Temperature.Air", null(lap.AirTemperature), "Temperature.Track", null(lap.TrackTemperature)
									  , "Grip", lap.Grip, "Map", null(lap.Map), "TC", null(lap.TC), "ABS", null(lap.ABS)
									  , "Tyre.Compound", compound(lap.Compound), "Tyre.Compound.Color", compoundColor(lap.Compound), "Tyre.Set", lap.TyreSet
									  , "Data.Telemetry", lap.TelemetryData, "Data.Pressures", lap.PressuresData)

					pressures := pressuresTable[newLap]
					tyres := tyresTable[newLap]

					pressureFL := pressures["Tyre.Pressure.Cold.Front.Left"]
					pressureFR := pressures["Tyre.Pressure.Cold.Front.Right"]
					pressureRL := pressures["Tyre.Pressure.Cold.Rear.Left"]
					pressureRR := pressures["Tyre.Pressure.Cold.Rear.Right"]

					lapData["Tyre.Pressure.Cold.Front.Left"] := null(pressureFL)
					lapData["Tyre.Pressure.Cold.Front.Right"] := null(pressureFR)
					lapData["Tyre.Pressure.Cold.Rear.Left"] := null(pressureRL)
					lapData["Tyre.Pressure.Cold.Rear.Right"] := null(pressureRR)
					lapData["Tyre.Pressure.Cold.Average"] := null(average([pressureFL, pressureFR, pressureRL, pressureRR]))
					lapData["Tyre.Pressure.Cold.Front.Average"] := null(average([pressureFL, pressureFR]))
					lapData["Tyre.Pressure.Cold.Rear.Average"] := null(average([pressureRL, pressureRR]))

					pressureFL := pressures["Tyre.Pressure.Hot.Front.Left"]
					pressureFR := pressures["Tyre.Pressure.Hot.Front.Right"]
					pressureRL := pressures["Tyre.Pressure.Hot.Rear.Left"]
					pressureRR := pressures["Tyre.Pressure.Hot.Rear.Right"]

					if isNull(pressureFL)
						pressureFL := tyres["Tyre.Pressure.Front.Left"]
					if isNull(pressureFR)
						pressureFR := tyres["Tyre.Pressure.Front.Right"]
					if isNull(pressureRL)
						pressureRL := tyres["Tyre.Pressure.Rear.Left"]
					if isNull(pressureRR)
						pressureRR := tyres["Tyre.Pressure.Rear.Right"]

					lapData["Tyre.Pressure.Hot.Front.Left"] := null(pressureFL)
					lapData["Tyre.Pressure.Hot.Front.Right"] := null(pressureFR)
					lapData["Tyre.Pressure.Hot.Rear.Left"] := null(pressureRL)
					lapData["Tyre.Pressure.Hot.Rear.Right"] := null(pressureRR)
					lapData["Tyre.Pressure.Hot.Average"] := null(average([pressureFL, pressureFR, pressureRL, pressureRR]))
					lapData["Tyre.Pressure.Hot.Front.Average"] := null(average([pressureFL, pressureFR]))
					lapData["Tyre.Pressure.Hot.Rear.Average"] := null(average([pressureRL, pressureRR]))

					pressureLossFL := pressures["Tyre.Pressure.Loss.Front.Left"]
					pressureLossFR := pressures["Tyre.Pressure.Loss.Front.Right"]
					pressureLossRL := pressures["Tyre.Pressure.Loss.Rear.Left"]
					pressureLossRR := pressures["Tyre.Pressure.Loss.Rear.Right"]

					lapData["Tyre.Pressure.Loss.Front.Left"] := null(pressureLossFL)
					lapData["Tyre.Pressure.Loss.Front.Right"] := null(pressureLossFR)
					lapData["Tyre.Pressure.Loss.Rear.Left"] := null(pressureLossRL)
					lapData["Tyre.Pressure.Loss.Rear.Right"] := null(pressureLossRR)

					tyres := tyresTable[newLap]

					lapData["Tyre.Laps"] := null(tyres["Tyre.Laps"])

					temperatureFL := tyres["Tyre.Temperature.Front.Left"]
					temperatureFR := tyres["Tyre.Temperature.Front.Right"]
					temperatureRL := tyres["Tyre.Temperature.Rear.Left"]
					temperatureRR := tyres["Tyre.Temperature.Rear.Right"]

					lapData["Tyre.Temperature.Front.Left"] := null(temperatureFL)
					lapData["Tyre.Temperature.Front.Right"] := null(temperatureFR)
					lapData["Tyre.Temperature.Rear.Left"] := null(temperatureRL)
					lapData["Tyre.Temperature.Rear.Right"] := null(temperatureRR)
					lapData["Tyre.Temperature.Average"] := null(average([temperatureFL, temperatureFR, temperatureRL, temperatureRR]))
					lapData["Tyre.Temperature.Front.Average"] := null(average([temperatureFL, temperatureFR]))
					lapData["Tyre.Temperature.Rear.Average"] := null(average([temperatureRL, temperatureRR]))

					wearFL := tyres["Tyre.Wear.Front.Left"]
					wearFR := tyres["Tyre.Wear.Front.Right"]
					wearRL := tyres["Tyre.Wear.Rear.Left"]
					wearRR := tyres["Tyre.Wear.Rear.Right"]

					lapData["Tyre.Wear.Front.Left"] := null(wearFL)
					lapData["Tyre.Wear.Front.Right"] := null(wearFR)
					lapData["Tyre.Wear.Rear.Left"] := null(wearRL)
					lapData["Tyre.Wear.Rear.Right"] := null(wearRR)
					lapData["Tyre.Wear.Average"] := ((wearFL = kNull) ? kNull : null(average([wearFL, wearFR, wearRL, wearRR])))
					lapData["Tyre.Wear.Front.Average"] := ((wearFL = kNull) ? kNull : null(average([wearFL, wearFR])))
					lapData["Tyre.Wear.Rear.Average"] := ((wearFL = kNull) ? kNull : null(average([wearRL, wearRR])))

					if lap.HasProp("Data") {
						telemetry := lap.Data

						if (telemetry.Count > 0) {
							brakeTemperatures := string2Values(",", getMultiMapValue(telemetry, "Car Data", "BrakeTemperature", ""))

							if (brakeTemperatures.Length = 4) {
								temperatureFL := brakeTemperatures[1]
								temperatureFR := brakeTemperatures[2]
								temperatureRL := brakeTemperatures[3]
								temperatureRR := brakeTemperatures[4]

								lapData["Brake.Temperature.Front.Left"] := null(temperatureFL)
								lapData["Brake.Temperature.Front.Right"] := null(temperatureFR)
								lapData["Brake.Temperature.Rear.Left"] := null(temperatureRL)
								lapData["Brake.Temperature.Rear.Right"] := null(temperatureRR)
								lapData["Brake.Temperature.Average"] := null(average([temperatureFL, temperatureFR, temperatureRL, temperatureRR]))
								lapData["Brake.Temperature.Front.Average"] := null(average([temperatureFL, temperatureFR]))
								lapData["Brake.Temperature.Rear.Average"] := null(average([temperatureRL, temperatureRR]))
							}
							else
								for ignore, field in ["Brake.Temperature.Front.Left", "Brake.Temperature.Front.Right", "Brake.Temperature.Rear.Left", "Brake.Temperature.Rear.Right"
													, "Brake.Temperature.Average", "Brake.Temperature.Front.Average", "Brake.Temperature.Rear.Average"]
									lapData[field] := kNull

							brakeWears := string2Values(",", getMultiMapValue(telemetry, "Car Data", "BrakeWear", ""))

							if (brakeWears.Length = 4) {
								wearFL := brakeWears[1]
								wearFR := brakeWears[2]
								wearRL := brakeWears[3]
								wearRR := brakeWears[4]

								lapData["Brake.Wear.Front.Left"] := null(wearFL)
								lapData["Brake.Wear.Front.Right"] := null(wearFR)
								lapData["Brake.Wear.Rear.Left"] := null(wearRL)
								lapData["Brake.Wear.Rear.Right"] := null(wearRR)
								lapData["Brake.Wear.Average"] := ((wearFL = kNull) ? kNull : null(average([wearFL, wearFR, wearRL, wearRR])))
								lapData["Brake.Wear.Front.Average"] := ((wearFL = kNull) ? kNull : null(average([wearFL, wearFR])))
								lapData["Brake.Wear.Rear.Average"] := ((wearFL = kNull) ? kNull : null(average([wearRL, wearRR])))
							}
							else
								for ignore, field in ["Brake.Wear.Front.Left", "Brake.Wear.Front.Right", "Brake.Wear.Rear.Left", "Brake.Wear.Rear.Right"
													, "Brake.Wear.Average", "Brake.Wear.Front.Average", "Brake.Wear.Rear.Average"]
									lapData[field] := kNull
						}
					}

					sessionStore.add("Lap.Data", lapData)
				}
				else if !forSave
					return

				newLap += 1
			}
		}

		if forSave {
			currentRun := this.CurrentRun

			if currentRun {
				sessionStore.clear("Run.Data")
				newRun := 1

				while (newRun <= currentRun.Nr) {
					if this.Runs.Has(newRun) {
						run := this.Runs[newRun]

						if (run.Laps.Length > 0) {
							runData := Database.Row("Nr", newRun, "Lap", run.Lap
												  , "Driver.Forname", run.Driver.Forname, "Driver.Surname", run.Driver.Surname
												  , "Driver.Nickname", run.Driver.Nickname, "Driver.ID", run.Driver.ID
												  , "Weather", run.Weather
												  , "Tyre.Compound", compound(run.Compound), "Tyre.Compound.Color", compoundColor(run.Compound)
												  , "Tyre.Set", run.TyreSet, "Tyre.Laps", run.TyreLaps
												  , "Lap.Time.Average", null(run.AvgLaptime), "Lap.Time.Best", null(run.BestLapTime)
												  , "Fuel.Initial", null(run.FuelInitial), "Fuel.Consumption", null(run.FuelConsumption)
												  , "Accidents", run.Accidents, "Position.Start", null(run.StartPosition), "Position.End", null(run.EndPosition)
												  , "Time.Start", this.computeStartTime(run), "Time.End", this.computeEndTime(run))

							sessionStore.add("Run.Data", runData)
						}
					}

					newRun += 1
				}
			}

			for table, ignore in sessionStore.Schemas
				sessionStore.changed(table)

			sessionStore.flush()
		}
	}

	reportSettings(report) {
		switch report, false {
			case "Overview":
				if this.editOverviewReportSettings()
					this.showOverviewReport()
			case "Drivers":
				if this.editDriverReportSettings()
					this.showDriverReport()
			case "Positions":
				if this.editPositionsReportSettings()
					this.showPositionsReport()
			case "Lap Times":
				if this.editLapTimesReportSettings()
					this.showLapTimesReport()
			case "Consistency":
				if this.editConsistencyReportSettings()
					this.showConsistencyReport()
			case "Pace":
				if this.editPaceReportSettings()
					this.showPaceReport()
			case "Performance":
				if this.editPerformanceReportSettings()
					this.showPerformanceReport()
			case "Running":
				this.showRunningReport()
			case "Pressures":
				if this.editPressuresReportSettings()
					this.showPressuresReport()
			case "Brakes":
				if this.editBrakesReportSettings()
					this.showBrakesReport()
			case "Temperatures":
				if this.editTemperaturesReportSettings()
					this.showTemperaturesReport()
			case "Free":
				if this.editCustomReportSettings()
					this.showCustomReport()
		}
	}

	showReport(report, force := false) {
		showReportAsync(report) {
			this.updateSeriesSelector(report)

			if (report = "Track")
				this.showTrackMap()
			else if inList(kRaceReports, report)
				this.showRaceReport(report)
			else if (report = "Running")
				this.showRunningReport()
			else if (report = "Pressures")
				this.showPressuresReport()
			else if (report = "Brakes")
				this.showBrakesReport()
			else if (report = "Temperatures")
				this.showTemperaturesReport()
			else if (report = "Free")
				this.showCustomReport()
		}

		if (force || (report != this.SelectedReport)) {
			this.pushTask(ObjBindMethod(this, "syncSessionStore"))

			this.pushTask(showReportAsync.Bind(report))
		}
	}

	selectChartType(chartType, force := false) {
		if (force || (chartType != this.SelectedChartType)) {
			this.Control["chartTypeDropDown"].Choose(inList(["Scatter", "Bar", "Bubble", "Line"], chartType))

			this.iSelectedChartType := chartType

			this.showTelemetryReport()
		}
	}

	createSessionSummaryChart(chartID, width, height, lapSeries, positionSeries, fuelSeries, tyreSeries) {
		local drawChartFunction := ("function drawChart" . chartID . "() {")
		local ignore, time, fuel

		drawChartFunction .= "`nvar data = new google.visualization.DataTable();"
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Lap") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Position") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Fuel Level") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Tyre Laps") . "');")
		drawChartFunction .= "`ndata.addRows(["

		for ignore, time in lapSeries {
			if (A_Index > 1)
				drawChartFunction .= ", "

			fuel := fuelSeries[A_Index]

			if isNumber(fuel)
				fuel := convertUnit("Volume", fuel)

			drawChartFunction .= ("[" . values2String(", ", lapSeries[A_Index]
														  , chartValue(null(positionSeries[A_Index]))
														  , chartValue(null(fuel))
														  , chartValue(null(tyreSeries[A_Index])))
								. "]")
		}

		drawChartFunction .= ("]);`nvar options = { legend: { position: 'Right' }, chartArea: { left: '10%', top: '5%', right: '25%', bottom: '20%' }, hAxis: { title: '" . translate("Lap") . "', gridlines: {count: 0} }, vAxis: { viewWindow: { min: 0 }, gridlines: {count: 0} }, backgroundColor: '" . this.Window.AltBackColor . "' };`n")

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return drawChartFunction
	}

	showDataSummary() {
		local telemetryDB := this.TelemetryDatabase
		local html := ("<div id=`"header`"><b>" . translate("Data Summary") . "</b></div>")
		local simulator := this.Simulator
		local carName := this.Car
		local trackName := this.Track
		local sessionDate := this.Date
		local sessionTime := this.Date
		local ignore, weather, tyreCompound, tyreCompoundColor, fuelLaps, tyreLaps, dataSource
		local map, tyreLaps, data, rows, row, columns

		carName := (carName ? telemetryDB.getCarName(simulator, carName) : "-")
		trackName := (trackName ? telemetryDB.getTrackName(simulator, trackName) : "-")

		if sessionDate
			sessionDate := FormatTime(sessionDate, "ShortDate")
		else
			sessionDate := "-"

		if sessionTime
			sessionTime := FormatTime(sessionTime, "Time")
		else
			sessionTime := "-"

		if (this.UseSessionData && this.UseTelemetryDatabase)
			dataSource := (translate("Session") . translate(", ") . translate("Database"))
		else if this.UseSessionData
			dataSource := translate("Session")
		else if this.UseTelemetryDatabase
			dataSource := translate("Database")
		else
			dataSource := translate("-")

		html .= "<br><br><table>"
		html .= ("<tr><td><b>" . translate("Simulator:") . "</b></td><td>" . (simulator ? simulator : "-") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Car:") . "</b></td><td>" . carName . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Track:") . "</b></td><td>" . trackName . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Date:") . "</b></td><td>" . sessionDate . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Time:") . "</b></td><td>" . sessionTime . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Origin:") . "</b></td><td>" . dataSource . "</td></tr>")
		html .= "</table>"

		for ignore, weather in kWeatherConditions
			for ignore, tyreCompound in this.AvailableTyreCompounds {
				splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

				if this.analyzeData(weather, tyreCompound, tyreCompoundColor, &fuelLaps, &tyreLaps) {
					html .= ("<br><br><b>" . translate(weather) . translate(" - ") . translate(compound(tyreCompound, tyreCompoundColor)) . "</b>")

					rows := []

					for map, data in fuelLaps {
						loop data.Length
							if !data[A_Index]
								data[A_Index] := "<td class=`"td-std`"></td>"
							else
								data[A_Index] := ("<td class=`"td-std`">" . displayValue("Time", data[A_Index]) . "</td>")

						rows.Push(Array("<td class=`"td-std`">" . map . "</td>", data*))
					}

					if (rows.Length > 0) {
						html .= "<br><br><table class=`"table-std`">"

						html .= ("<tr><th class=`"th-std`">" . translate("Map") . "</th>")

						columns := collect(kFuelBuckets, convertUnit.Bind("Volume"))

						loop columns.Length
							html .= ("<th class=`"th-std`">" . (columns[A_Index] . A_Space . SubStr(getUnit("Volume"), 1, 1)) . "</th>")

						html .= "</tr>"

						for ignore, row in rows
							html .= ("<tr>" . values2String("", row*) . "</tr>")

						html .= "</table>"
					}

					rows := []

					for fuel, data in tyreLaps {
						loop data.Length
							if !data[A_Index]
								data[A_Index] := "<td class=`"td-std`"></td>"
							else
								data[A_Index] := ("<td class=`"td-std`">" . displayValue("Time", data[A_Index]) . "</td>")

						rows.Push(Array("<td class=`"td-std`">" . (displayValue("Float", convertUnit("Volume", fuel)) . A_Space . SubStr(getUnit("Volume"), 1, 1)) . "</td>", data*))
					}

					if (rows.Length > 0) {
						html .= "<br><br><table class=`"table-std`">"

						html .= ("<tr><th class=`"th-std`">" . translate("Fuel") . "</th>")

						loop kTyreLapsBuckets.Length
							html .= ("<th class=`"th-std`">" . kTyreLapsBuckets[A_Index] . "</th>")

						html .= "</tr>"

						for ignore, row in rows
							html .= ("<tr>" . values2String("", row*) . "</tr>")

						html .= "</table>"
					}
				}
			}

		this.showDetails("Data", html)
	}

	showSessionSummary() {
		local telemetryDB := this.TelemetryDatabase
		local html := ("<div id=`"header`"><b>" . translate("Race Summary") . "</b></div>")
		local runs := []
		local drivers := []
		local laps := []
		local durations := []
		local numLaps := []
		local positions := []
		local avgLapTimes := []
		local fuelConsumptions := []
		local accidents := []
		local penalties := []
		local currentRun := this.CurrentRun
		local positions := []
		local remainingFuels := []
		local tyreLaps := []
		local lastLap := this.LastLap
		local lapDataTable := this.SessionStore.Tables["Lap.Data"]
		local simulator := this.Simulator
		local carName := this.Car
		local trackName := this.Track
		local sessionDate := this.Date
		local sessionTime := this.Date
		local run, duration, ignore, lap, width, chart1, fuelConsumption

		carName := (carName ? telemetryDB.getCarName(simulator, carName) : "-")
		trackName := (trackName ? telemetryDB.getTrackName(simulator, trackName) : "-")

		if sessionDate
			sessionDate := FormatTime(sessionDate, "ShortDate")
		else
			sessionDate := "-"

		if sessionTime
			sessionTime := FormatTime(sessionTime, "Time")
		else
			sessionTime := "-"

		html .= "<br><br><table>"
		html .= ("<tr><td><b>" . translate("Simulator:") . "</b></td><td>" . (simulator ? simulator : "-") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Car:") . "</b></td><td>" . carName . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Track:") . "</b></td><td>" . trackName . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Date:") . "</b></td><td>" . sessionDate . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Time:") . "</b></td><td>" . sessionTime . "</td></tr>")
		html .= "</table>"

		html .= ("<br><br><div id=`"header`"><i>" . translate("Stints") . "</i></div>")

		if currentRun
			loop currentRun.Nr {
				run := this.Runs[A_Index]

				runs.Push("<th class=`"th-std`">" . run.Nr . "</th>")
				drivers.Push("<td class=`"td-std`">" . StrReplace(run.Driver.Fullname, "'", "\'") . "</td>")
				laps.Push("<td class=`"td-std`">" . run.Lap . "</td>")

				duration := 0

				for ignore, lap in run.Laps
					duration += lap.Laptime

				durations.Push("<td class=`"td-std`">" . Round(duration / 60) . "</td>")
				numLaps.Push("<td class=`"td-std`">" . run.Laps.Length . "</td>")
				positions.Push("<td class=`"td-std`">" . run.StartPosition . translate(" -> ") . run.EndPosition . "</td>")
				avgLapTimes.Push("<td class=`"td-std`">" . lapTimeDisplayValue(run.AvgLaptime) . "</td>")

				fuelConsumption := run.FuelConsumption

				if isNumber(fuelConsumption)
					fuelConsumption := displayValue("Float", convertUnit("Volume", fuelConsumption))

				fuelConsumptions.Push("<td class=`"td-std`">" . displayNullValue(fuelConsumption) . "</td>")
				accidents.Push("<td class=`"td-std`">" . run.Accidents . "</td>")
			}

		html .= "<br><table class=`"table-std`">"

		html .= ("<tr><th class=`"th-std`">" . translate("Stint") . "</th>"
				   . "<th class=`"th-std`">" . translate("Driver") . "</th>"
				   . "<th class=`"th-std`">" . translate("Lap") . "</th>"
			       . "<th class=`"th-std`">" . translate("Duration") . "</th>"
			       . "<th class=`"th-std`">" . translate("Laps") . "</th>"
			       . "<th class=`"th-std`">" . translate("Position") . "</th>"
			       . "<th class=`"th-std`">" . translate("Avg. Lap Time") . "</th>"
			       . "<th class=`"th-std`">" . translate("Consumption") . "</th>"
			       . "<th class=`"th-std`">" . translate("Accidents") . "</th>"
			   . "</tr>")

		loop runs.Length
			html .= ("<tr>" . runs[A_Index]
							. drivers[A_Index]
							. laps[A_Index]
							. durations[A_Index]
							. numLaps[A_Index]
							. positions[A_Index]
							. avgLapTimes[A_Index]
							. fuelConsumptions[A_Index]
							. accidents[A_Index]
				   . "</tr>")

		html .= "</table>"

		html .= ("<br><br><div id=`"header`"><i>" . translate("Summary") . "</i></div>")

		laps := []
		positions := []

		if lastLap
			loop lastLap.Nr {
				lap := this.Laps[A_Index]

				laps.Push(A_Index)
				positions.Push(lap.Position)
				remainingFuels.Push(lap.FuelRemaining)

				if lapDataTable.Has(A_Index)
					tyreLaps.Push(lapDataTable[A_Index]["Tyre.Laps"])
				else
					tyreLaps.Push(kNull)
			}

		width := (this.DetailsViewer.getWidth() - 20)

		chart1 := this.createSessionSummaryChart(1, width, 248, laps, positions, remainingFuels, tyreLaps)

		html .= ("<br><br><div id=`"chart_1`" style=`"width: " . width . "px; height: 248px`"></div>")

		this.showDetails("Session", html, [1, chart1])
	}

	createRunHeader(run) {
		local startTime := this.computeStartTime(run)
		local endTime := this.computeEndTime(run)
		local duration := 0
		local ignore, lap, html

		for ignore, lap in run.Laps
			duration += lap.Laptime

		if startTime
			startTime := FormatTime(startTime, "Time")
		else
			startTime := "-"

		if endTime
			endTime := FormatTime(endTime, "Time")
		else
			endTime := "-"

		html := "<table>"
		html .= ("<tr><td><b>" . translate("Driver:") . "</b></div></td><td>" . StrReplace(run.Driver.FullName, "'", "\'") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Start:") . "</b></div></td><td>" . startTime . "</td></tr>")
		html .= ("<tr><td><b>" . translate("End:") . "</b></div></td><td>" . endTime . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Duration:") . "</b></div></td><td>" . Round(duration / 60) . A_Space . translate("Minutes") . "</td></tr>")

		if (this.Session = "Race") {
			html .= ("<tr><td><b>" . translate("Start Position:") . "</b></div></td><td>" . run.StartPosition . "</td></tr>")
			html .= ("<tr><td><b>" . translate("End Position:") . "</b></div></td><td>" . run.EndPosition . "</td></tr>")
		}

		html .= ("<tr><td><b>" . translate("Temperatures (A / T):") . "</b></td><td>" . displayValue("Float", convertUnit("Temperature", run.AirTemperature)) . ", " . displayValue("Float", convertUnit("Temperature", run.TrackTemperature)) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Consumption:") . "</b></div></td><td>" . displayValue("Float", convertUnit("Volume", run.FuelConsumption)) . "</td></tr>")
		html .= "</table>"

		return html
	}

	createLapDetailsChart(chartID, width, height, lapSeries, positionSeries, lapTimeSeries, fuelSeries, tempSeries) {
		local drawChartFunction := ("function drawChart" . chartID . "() {`nvar data = new google.visualization.DataTable();")
		local ignore, time, fuel, temperature

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Lap") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Position") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Lap Time") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Consumption") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Tyre Temperatures") . "');")

		drawChartFunction .= "`ndata.addRows(["

		for ignore, time in lapSeries {
			if (A_Index > 1)
				drawChartFunction .= ", "

			fuel := fuelSeries[A_Index]

			if isNumber(fuel)
				fuel := convertUnit("Volume", fuel)

			temperature := tempSeries[A_Index]

			if isNumber(temperature)
				temperature := convertUnit("Temperature", temperature)

			drawChartFunction .= ("[" . values2String(", ", lapSeries[A_Index]
														  , chartValue(null(positionSeries[A_Index]))
														  , chartValue(null(lapTimeSeries[A_Index]))
														  , chartValue(null(fuel))
														  , chartValue(null(temperature)))
								. "]")
		}

		drawChartFunction .= ("]);`nvar options = { legend: { position: 'Right' }, chartArea: { left: '10%', top: '5%', right: '25%', bottom: '20%' }, hAxis: { title: '" . translate("Lap") . "', gridlines: {count: 0} }, vAxis: { viewWindow: { min: 0 }, gridlines: {count: 0} }, backgroundColor: '" . this.Window.AltBackColor . "' };`n")

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return drawChartFunction
	}

	createRunPerformanceChart(chartID, width, height, run) {
		local drawChartFunction := ""
		local minValue, maxValue

		this.updateRunStatistics(run)

		drawChartFunction .= "function drawChart" . chartID . "() {"
		drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["
		drawChartFunction .= "`n['" . values2String("', '", translate("Category"), StrReplace(run.Driver.FullName, "'", "\'")) . "'],"

		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Potential") . "'", run.Potential) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Race Craft") . "'", run.RaceCraft) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Speed") . "'", run.Speed) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Consistency") . "'", run.Consistency) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Car Control") . "'", run.CarControl) . "]"

		drawChartFunction .= ("`n]);")

		minValue := Min(0, run.Potential, run.RaceCraft, run.Speed, run.Consistency, run.CarControl)
		maxValue := Max(run.Potential, run.RaceCraft, run.Speed, run.Consistency, run.CarControl)

		drawChartFunction := drawChartFunction . "`nvar options = { bars: 'horizontal', legend: 'none', backgroundColor: '" . this.Window.AltBackColor . "', chartArea: { left: '20%', top: '5%', right: '10%', bottom: '10%' }, hAxis: {viewWindowMode: 'explicit', viewWindow: {min: " . minValue . ", max: " . maxValue . "}, gridlines: {count: 0} }, vAxis: {gridlines: {count: 0}} };"
		drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }"

		return drawChartFunction
	}

	createRunConsistencyChart(chartID, width, height, run, laps, lapTimes) {
		local drawChartFunction := "function drawChart" . chartID . "() {"
		local validLaps := []
		local validTimes := []
		local ignore, lap, time, theMin, avg, theMax, delta, window, consistency, time, title

		for ignore, lap in laps {
			if ((laps.Length = 1) || (A_Index > 1)) {
				time := lapTimes[A_Index]

				if isNumber(time) {
					validLaps.Push(lap)
					validTimes.Push(time)
				}
			}
		}

		drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["

		drawChartFunction .= "`n['" . values2String("', '", translate("Lap"), translate("Lap Time")
														  , translate("Max"), translate("Avg"), translate("Min"))
						   . "']"

		theMin := minimum(validTimes)
		avg := average(validTimes)
		theMax := maximum(validTimes)

		for ignore, lap in validLaps
			drawChartFunction .= ",`n[" . values2String(", ", lap, validTimes[A_Index], theMax, avg, theMin) . "]"

		drawChartFunction .= ("`n]);")

		delta := (theMax - theMin)

		theMin := Max(avg - (3 * delta), 0)
		theMax := Min(avg + (2 * delta), theMax)

		if (theMin = 0)
			theMin := (avg / 3)

		window := ("baseline: " . theMin . ", viewWindow: {min: " . theMin . ", max: " . theMax . "}, ")
		consistency := 0

		for ignore, time in validTimes
			consistency += (100 - Abs(avg - time))

		consistency := Round(consistency / ((validTimes.Length = 0) ? 0.01 : validTimes.Length), 2)

		title := ("title: '" . translate("Consistency: ") . consistency . translate(" %") . "', titleTextStyle: {bold: false}, ")

		drawChartFunction .= ("`nvar options = {" . title . "seriesType: 'bars', series: {1: {type: 'line'}, 2: {type: 'line'}, 3: {type: 'line'}}, backgroundColor: '#" . this.Window.AltBackColor . "', vAxis: {" . window . "title: '" . translate("Lap Time") . "', gridlines: {count: 0}}, hAxis: {title: '" . translate("Laps") . "', gridlines: {count: 0}}, chartArea: { left: '20%', top: '15%', right: '15%', bottom: '15%' } };")

		drawChartFunction .= ("`nvar chart = new google.visualization.ComboChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return drawChartFunction
	}

	createLapDetails(run) {
		local html := "<table>"
		local lapData := []
		local mapData := []
		local lapTimeData := []
		local fuelConsumptionData := []
		local accidentData := []
		local ignore, lap, fuelConsumption

		html .= ("<tr><td><b>" . translate("Average:") . "</b></td><td>" . lapTimeDisplayValue(run.AvgLapTime) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Best:") . "</b></td><td>" . lapTimeDisplayValue(run.BestLapTime) . "</td></tr>")
		html .= "</table>"

		for ignore, lap in run.Laps {
			lapData.Push("<th class=`"th-std`">" . lap.Nr . "</th>")
			mapData.Push("<td class=`"td-std`">" . lap.Map . "</td>")
			lapTimeData.Push("<td class=`"td-std`">" . lapTimeDisplayValue(lap.Laptime) . "</td>")

			fuelConsumption := lap.FuelConsumption

			if isNumber(fuelConsumption)
				fuelConsumption := displayValue("Float", convertUnit("Volume", fuelConsumption))

			fuelConsumptionData.Push("<td class=`"td-std`">" . displayNullValue(fuelConsumption) . "</td>")
			accidentData.Push("<td class=`"td-std`">" . (lap.Accident ? "x" : "") . "</td>")
		}

		html .= "<br><table class=`"table-std`">"

		html .= ("<tr><th class=`"th-std`">" . translate("Lap") . "</th>"
				   . "<th class=`"th-std`">" . translate("Map") . "</th>"
				   . "<th class=`"th-std`">" . translate("Lap Time") . "</th>"
				   . "<th class=`"th-std`">" . translate("Consumption") . "</th>"
				   . "<th class=`"th-std`">" . translate("Accident") . "</th>"
			   . "</tr>")

		loop lapData.Length
			html .= ("<tr>" . lapData[A_Index]
							. mapData[A_Index]
							. lapTimeData[A_Index]
							. fuelConsumptionData[A_Index]
							. accidentData[A_Index]
				   . "</tr>")

		html .= "</table>"

		return html
	}

	showRunDetails(run) {
		showRunDetailsAsync(run) {
			local html := ("<div id=`"header`"><b>" . translate("Stint: ") . run.Nr . "</b></div>")
			local laps := []
			local positions := []
			local lapTimes := []
			local fuelConsumptions := []
			local temperatures := []
			local lapTable := this.SessionStore.Tables["Lap.Data"]
			local ignore, lap, width, chart1, chart2, chart3

			html .= ("<br><br><div id=`"header`"><i>" . translate("Overview") . "</i></div>")

			html .= ("<br>" . this.createRunHeader(run))

			html .= ("<br><br><div id=`"header`"><i>" . translate("Laps") . "</i></div>")

			html .= ("<br>" . this.createLapDetails(run))

			html .= ("<br><br><div id=`"header`"><i>" . translate("Telemetry") . "</i></div>")

			for ignore, lap in run.Laps
				if lapTable.Has(lap.Nr) {
					laps.Push(lap.Nr)
					positions.Push(lap.Position)
					lapTimes.Push(lap.Laptime)
					fuelConsumptions.Push(lap.FuelConsumption)
					temperatures.Push(lapTable[lap.Nr]["Tyre.Temperature.Average"])
				}

			width := (this.DetailsViewer.getWidth() - 20)

			chart1 := this.createLapDetailsChart(1, width, 248, laps, positions, lapTimes, fuelConsumptions, temperatures)

			html .= ("<br><br><div id=`"chart_1`" style=`"width: " . width . "px; height: 248px`"></div>")

			html .= ("<br><br><div id=`"header`"><i>" . translate("Statistics") . "</i></div>")

			chart2 := this.createRunPerformanceChart(2, width, 248, run)

			html .= ("<br><div id=`"chart_2`" style=`"width: " . width . "px; height: 248px`"></div>")

			html .= ("<br><br><div id=`"header`"><i>" . translate("Consistency") . "</i></div>")

			chart3 := this.createRunConsistencyChart(3, width, 248, run, laps, lapTimes)

			html .= ("<br><div id=`"chart_3`" style=`"width: " . width . "px; height: 248px`"></div>")

			this.showDetails("Run", html, [1, chart1], [2, chart2], [3, chart3])
		}

		this.pushTask(ObjBindMethod(this, "syncSessionStore"))

		this.pushTask(showRunDetailsAsync.Bind(run))
	}

	createLapOverview(lap) {
		local html := "<table>"
		local hotPressures := "-, -, -, -"
		local coldPressures := "-, -, -, -"
		local pressuresLosses := "-, -, -, -"
		local hasColdPressures := false
		local pressuresDB := this.PressuresDatabase
		local pressuresTable, pressures, tyresTable, tyres
		local fuel, tyreCompound, tyreCompoundColor, tyreSet, tyrePressures, pressure
		local fuelConsumption, remainingFuel

		if pressuresDB {
			pressuresTable := pressuresDB.Database.Tables["Tyres.Pressures"]

			if (pressuresTable.Length >= lap.Nr) {
				pressures := pressuresTable[lap.Nr]

				coldPressures := [displayNullValue(pressures["Tyre.Pressure.Cold.Front.Left"]), displayNullValue(pressures["Tyre.Pressure.Cold.Front.Right"])
								, displayNullValue(pressures["Tyre.Pressure.Cold.Rear.Left"]), displayNullValue(pressures["Tyre.Pressure.Cold.Rear.Right"])]

				fuel := lap.Run.FuelInitial

				splitCompound(lap.Run.Compound, &tyreCompound, &tyreCompoundColor)

				tyreSet := lap.Run.TyreSet

				loop 4 {
					pressure := coldPressures[A_Index]

					if isNumber(pressure)
						coldPressures[A_Index] := displayValue("Float", convertUnit("Pressure", pressure))
				}

				coldPressures := values2String(", ", coldPressures*)

				hasColdPressures := (hasColdPressures || (coldPressures != "-, -, -, -"))

				hotPressures := [displayNullValue(pressures["Tyre.Pressure.Hot.Front.Left"]), displayNullValue(pressures["Tyre.Pressure.Hot.Front.Right"])
							   , displayNullValue(pressures["Tyre.Pressure.Hot.Rear.Left"]), displayNullValue(pressures["Tyre.Pressure.Hot.Rear.Right"])]

				loop 4 {
					pressure := hotPressures[A_Index]

					if isNumber(pressure)
						hotPressures[A_Index] := displayValue("Float", convertUnit("Pressure", pressure))
				}

				hotPressures := values2String(", ", hotPressures*)

				pressuresLosses := [displayNullValue(pressures["Tyre.Pressure.Loss.Front.Left"]), displayNullValue(pressures["Tyre.Pressure.Loss.Front.Right"])
								  , displayNullValue(pressures["Tyre.Pressure.Loss.Rear.Left"]), displayNullValue(pressures["Tyre.Pressure.Loss.Rear.Right"])]

				loop 4 {
					pressure := pressuresLosses[A_Index]

					if isNumber(pressure)
						pressuresLosses[A_Index] := displayValue("Float", convertUnit("Pressure", pressure))
				}

				pressuresLosses := values2String(", ", pressuresLosses*)

				if (hotPressures = "-, -, -, -") {
					tyresTable := this.TelemetryDatabase.Database.Tables["Tyres"]

					if (tyresTable.Length >= lap.Nr) {
						tyres := tyresTable[lap.Nr]

						hotPressures := [displayNullValue(tyres["Tyre.Pressure.Front.Left"]), displayNullValue(tyres["Tyre.Pressure.Front.Right"])
									   , displayNullValue(tyres["Tyre.Pressure.Rear.Left"]), displayNullValue(tyres["Tyre.Pressure.Rear.Right"])]

						loop 4 {
							pressure := hotPressures[A_Index]

							if isNumber(pressure)
								hotPressures[A_Index] := displayValue("Float", convertUnit("Pressure", pressure))
						}

						hotPressures := values2String(", ", hotPressures*)
					}
				}
			}
		}

		remainingFuel := lap.FuelRemaining

		if isNumber(remainingFuel)
			remainingFuel := displayValue("Float", convertUnit("Volume", remainingFuel))

		fuelConsumption := lap.FuelConsumption

		if isNumber(fuelConsumption)
			fuelConsumption := displayValue("Float", convertUnit("Volume", fuelConsumption))

		html .= ("<tr><td><b>" . translate("Position:") . "</b></td><td>" . lap.Position . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Lap Time:") . "</b></td><td>" . lapTimeDisplayValue(lap.LapTime) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Consumption:") . "</b></td><td>" . displayNullValue(fuelConsumption) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Fuel Level:") . "</b></td><td>" . remainingFuel . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Temperatures (A / T):") . "</b></td><td>" . displayValue("Float", convertUnit("Temperature", lap.AirTemperature)) . ", " . displayValue("Float", convertUnit("Temperature", lap.TrackTemperature)) . "</td></tr>")

		if (hotPressures != "-, -, -, -")
			html .= ("<tr><td><b>" . translate("Pressures (hot):") . "</b></td><td>" . hotPressures . "</td></tr>")

		if hasColdPressures
			html .= ("<tr><td><b>" . translate("Pressures (cold, recommended):") . "</b></td><td>" . coldPressures . "</td></tr>")

		if (pressuresLosses != "-, -, -, -")
			html .= ("<tr><td><b>" . translate("Pressures (loss):") . "</b></td><td>" . pressuresLosses . "</td></tr>")

		html .= ("<tr><td></td><td></td></tr>")

		html .= "</table>"

		return html
	}

	createLapDeltas(lap) {
		local sessionStore := this.SessionStore
		local html := "<table class=`"table-std`">"
		local labels := [translate("Leader"), translate("Standings (Ahead)"), translate("Standings (Behind)")
					   , translate("Track (Ahead)"), translate("Track (Behind)")]
		local rowIndices := CaseInsenseMap("Standings.Leader", 1, "Standings.Front", 2, "Standings.Ahead", 2, "Standings.Behind", 3
										 , "Track.Front", 4, "Track.Ahead", 4, "Track.Behind", 5)
		local telemetryDB := this.TelemetryDatabase
		local rows := [1, 2, 3, 4, 5]
		local deltas, ignore, entry, carNumber, carName, driverFullName, delta, row
		local driverForname, driverSurname, driverNickname, entryType, index, label
		local car, carID

		html .= ("<tr><th class=`"th-std`">" . "" . "</th>"
				   . "<th class=`"th-std`">" . translate("Nr.") . "</th>"
				   . "<th class=`"th-std`">" . translate("Driver") . "</th>"
				   . "<th class=`"th-std`">" . translate("Car") . "</th>"
				   . "<th class=`"th-std`">" . translate("Delta") . "</th>"
			   . "</tr>")

		deltas := sessionStore.query("Delta.Data", {Where: {Lap: lap.Nr}})

		if (deltas.Length > 0) {
			for ignore, entry in deltas {
				carNumber := "-"
				carName := "-"
				driverFullname := "-"
				delta := "-"

				if ((entry["Car"] && (entry["Car"] != kNull)) || (entry["ID"] && (entry["ID"] != kNull))) {
					driverForname := false
					driverSurname := false
					driverNickname := false

					car := entry["Car"]

					if this.getCar(lap, (entry["ID"] != kNull) ? entry["ID"] : false, &car, &carNumber, &carName, &driverForname, &driverSurname, &driverNickname) {
						driverFullname := computeDriverName(driverForname, driverSurname, driverNickname)

						delta := entry["Delta"]
					}
				}

				entryType := entry["Type"]

				index := rowIndices[entryType]

				label := labels[index]

				rows[index] := ("<tr><th class=`"th-std th-left`">" . label . "</th>"
							  . "<td class=`"td-std`">" . values2String("</td><td class=`"td-std`">" , carNumber, driverFullname, telemetryDB.getCarName(this.Simulator, carName), delta)
							  . "</td></tr>")
			}

			for ignore, row in rows
				html .= row
		}

		html .= "</table>"

		return html
	}

	createLapStandings(lap) {
		local sessionStore := this.SessionStore
		local telemetryDB := this.TelemetryDatabase
		local isRace := (this.Session = "Race")
		local html := "<table class=`"table-std`">"
		local lapNr := lap.Nr
		local cars := true
		local carIDs := true
		local overallPositions := true
		local classPositions := true
		local carNumbers := true
		local carNames := true
		local driverFornames := true
		local driverSurnames := true
		local driverNicknames := true
		local driverCategories := (this.ReportViewer.Settings.Has("DriverCategories") && this.ReportViewer.Settings["DriverCategories"])
		local index, position, lapTime, laps, delta, result, multiClass, numPitstops, ignore, pitstop, pitstops, pitstopLaps

		multiClass := this.getStandings(lap, &cars, &carIDs, &overallPositions, &classPositions, &carNumbers, &carNames
										   , &driverFornames, &driverSurnames, &driverNicknames, &driverCategories, isRace ? "Position" : "Time")

		html .= ("<tr><th class=`"th-std`">" . translate("#") . "</th>"
				   . "<th class=`"th-std`">" . translate("Nr.") . "</th>"
				   . "<th class=`"th-std`">" . translate("Driver") . "</th>"
				   . "<th class=`"th-std`">" . translate("Car") . "</th>")

		if (isRace && multiClass)
			html .= ("<th class=`"th-std`">" . translate("Position") . "</th>")

		html .= ("<th class=`"th-std`">" . translate("Lap Time") . "</th>"
			   . "<th class=`"th-std`">" . translate("Laps") . "</th>"
			   . (isRace ? ("<th class=`"th-std`">" . translate("Delta") . "</th>") : "")
			   . (isRace ? ("<th class=`"th-std`">" . translate("Pitstops") . "</th>") : "")
			   . "</tr>")

		for index, position in overallPositions
			if (position && carIDs.Has(index)) {
				lapTime := "-"
				laps := "-"
				delta := "-"

				if isRace {
					result := sessionStore.query("Standings.Data", {Select: ["Time", "Laps", "Delta"], Where: {Lap: lap.Nr, ID: carIDs[index]}})

					if (result.Length = 0)
						result := sessionStore.query("Standings.Data", {Select: ["Time", "Laps", "Delta"], Where: {Lap: lap.Nr, Car: cars[index]}})
				}
				else {
					result := sessionStore.query("Standings.Data", {Select: ["Time", "Laps"], Where: {Lap: lap.Nr, ID: carIDs[index]}})

					if (result.Length = 0)
						result := sessionStore.query("Standings.Data", {Select: ["Time", "Laps"], Where: {Lap: lap.Nr, Car: cars[index]}})
				}

				if (result.Length > 0) {
					lapTime := result[1]["Time"]
					laps := result[1]["Laps"]

					if isRace
						delta := Round(result[1]["Delta"], 1)
				}

				driver := computeDriverName(driverFornames[index] , driverSurnames[index], driverNickNames[index])

				if (driverCategories && (driverCategories[index] != "Unknown"))
					driver .= (translate(" [") . translate(driverCategories[index]) . translate("]"))

				html .= ("<tr><th class=`"th-std`">" . (isRace ? position : index) . "</th>")
				html .= ("<td class=`"td-std`">" . values2String("</td><td class=`"td-std`">", carNumbers[index], driver
																							 , telemetryDB.getCarName(this.Simulator, carNames[index]))
					   . "</td>")

				if isRace {
					if multiClass
						html .= ("<td class=`"td-std`">" . classPositions[index] . "</td>")

					html .= ("<td class=`"td-std`">" . values2String("</td><td class=`"td-std`">", lapTimeDisplayValue(lapTime), laps, delta) . "</td>")

					pitstops := this.Pitstops[carIDs[index]]
					numPitstops := 0

					if (pitstops.Length > 0) {
						pitstopLaps := []

						for ignore, pitstop in pitstops
							if (pitstop.Lap <= lapNr) {
								numPitstops += 1

								pitstopLaps.Push(pitstop.Lap)

								if (pitstopLaps.Length > 3)
									pitstopLaps.RemoveAt(1)
							}

						if (numPitstops > 0) {
							pitstops := (numPitstops . translate(":   ["))

							if (numPitstops > 3)
								pitstops .= (translate("...") . translate(", "))

							pitstops .= (values2String(", ", pitstopLaps*) . translate("]"))
						}
						else
							pitstops := "-"
					}
					else
						pitstops := "-"

					html .= ("<td class=`"td-std td-left`">" . pitstops . "</td></tr>")
				}
				else
					html .= ("<td class=`"td-std`">" . values2String("</td><td class=`"td-std`">", lapTimeDisplayValue(lapTime), laps) . "</td>")
			}

		html .= "</table>"

		return html
	}

	showLapDetails(lap) {
		showLapDetailsAsync(lap) {
			local html := ("<div id=`"header`"><b>" . translate("Lap: ") . lap.Nr . "</b></div>")

			this.initializeReports()

			html .= ("<br><br><div id=`"header`"><i>" . translate("Overview") . "</i></div>")

			html .= ("<br>" . this.createLapOverview(lap))

			if (this.Session = "Race") {
				html .= ("<br><br><div id=`"header`"><i>" . translate("Deltas") . "</i></div>")

				html .= ("<br>" . this.createLapDeltas(lap))
			}

			html .= ("<br><br><div id=`"header`"><i>" . translate("Standings") . "</i></div>")

			html .= ("<br>" . this.createLapStandings(lap))

			this.showDetails("Lap", html)
		}

		this.pushTask(ObjBindMethod(this, "syncSessionStore"))

		this.pushTask(showLapDetailsAsync.Bind(lap))
	}

	startSession(fileName) {
		startSessionAsync() {
			local data := readMultiMap(fileName)

			try {
				this.initializeSession(getMultiMapValue(data, "Session Data", "Session", "Practice"))

				this.initializeSimulator(SessionDatabase.getSimulatorName(getMultiMapValue(data, "Session Data", "Simulator"))
									   , getMultiMapValue(data, "Session Data", "Car")
									   , getMultiMapValue(data, "Session Data", "Track"))

				this.analyzeTelemetry()
			}
			finally {
				deleteFile(fileName)
			}
		}

		this.pushTask(startSessionAsync)
	}

	updateLap(lapNumber, fileName, update := false) {
		updateLapAsync() {
			local data := readMultiMap(fileName)

			try {
				if update {
					if (this.SessionActive && (this.LastLap.Nr = lapNumber))
						this.updateRunning(lapNumber, data)
				}
				else {
					if (this.SessionMode && this.SessionMode != "Active")
						return

					if ((!this.LastLap && (lapNumber = 1)) || ((this.LastLap.Nr + 1) = lapNumber)) {
						this.iSessionMode := "Active"

						this.addLap(lapNumber, data)
					}
				}
			}
			finally {
				deleteFile(fileName)
			}
		}

		this.pushTask(updateLapAsync)
	}

	updateReportData(lapNumber, fileName) {
		updateReportDataAsync() {
			try {
				if (this.SessionActive && (this.LastLap.Nr = lapNumber)) {
					DirCreate(this.SessionDirectory . "Race Report")

					FileCopy(fileName, this.SessionDirectory . "Race Report\Race.data", 1)

					this.initializeReports()
				}
			}
			finally {
				deleteFile(fileName)
			}
		}

		this.pushTask(updateReportDataAsync)
	}

	updateReportLap(lapNumber, fileName) {
		updateReportLapAsync() {
			local raceData, lapData, directory, key, value, newLine, line
			local pitstops, times, positions, laps, drivers

			if (this.SessionActive && (this.LastLap.Nr = lapNumber)) {
				directory := (this.SessionDirectory . "Race Report\")

				raceData := readMultiMap(directory . "Race.data")
				lapData := readMultiMap(fileName)

				deleteFile(fileName)

				if (getMultiMapValue(raceData, "Cars", "Count") = kNotInitialized)
					setMultiMapValue(raceData, "Cars", "Count", 0)

				if (getMultiMapValue(raceData, "Cars", "Driver") = kNotInitialized)
					setMultiMapValue(raceData, "Cars", "Driver", 0)

				if (lapData.Count == 0)
					return

				for key, value in getMultiMapValues(lapData, "Lap")
					setMultiMapValue(raceData, "Laps", key, value)

				pitstops := getMultiMapValue(lapData, "Pitstop", "Laps", "")

				setMultiMapValue(raceData, "Laps", "Pitstops", pitstops)

				times := getMultiMapValue(lapData, "Times", lapNumber)
				positions := getMultiMapValue(lapData, "Positions", lapNumber)
				laps := getMultiMapValue(lapData, "Laps", lapNumber)
				drivers := getMultiMapValue(lapData, "Drivers", lapNumber)

				newLine := ((lapNumber > 1) ? "`n" : "")

				line := (newLine . times)

				FileAppend(line, directory . "Times.CSV")

				line := (newLine . positions)

				FileAppend(line, directory . "Positions.CSV")

				line := (newLine . laps)

				FileAppend(line, directory . "Laps.CSV")

				line := (newLine . drivers)
				fileName := (directory . "Drivers.CSV")

				FileAppend(line, fileName, "UTF-16")

				removeMultiMapValue(raceData, "Laps", "Lap")
				setMultiMapValue(raceData, "Laps", "Count", lapNumber)

				writeMultiMap(directory . "Race.data", raceData)

				if (this.LapsListView.GetCount() && (this.SelectedDetailReport = "Lap")) {
					this.LapsListView.Modify(this.LapsListView.GetCount(), "Select Vis")

					this.showLapDetails(this.LastLap)
				}

				this.updateReports()
				this.updateState()
			}
		}

		this.pushTask(updateReportLapAsync)
	}

	updateStandings(lapNumber, fileName) {
		updateStandingsAsync() {
			local data := readMultiMap(fileName)

			try {
				if (this.SessionActive && (this.LastLap.Nr = lapNumber))
					this.addStandings(this.LastLap, data)
			}
			finally {
				deleteFile(fileName)
			}
		}

		this.pushTask(updateStandingsAsync)
	}

	updateTelemetry(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
				  , fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
				  , compound, compoundColor, pressures, temperatures, wear, state) {
		udateTelemetryAsync() {
			if (this.SessionActive && (this.LastLap.Nr = lapNumber)) {
				this.addTelemetry(this.LastLap, simulator, car, track, weather, airTemperature, trackTemperature
								, fuelConsumption, fuelRemaining, lapTime, pitstop, map, tc, abs
								, compound, compoundColor, pressures, temperatures, wear, state)

				this.analyzeTelemetry()
			}
		}

		this.pushTask(udateTelemetryAsync)
	}

	updatePressures(lapNumber, simulator, car, track, weather, airTemperature, trackTemperature
				  , compound, compoundColor, coldPressures, hotPressures, pressuresLosses) {
		updatePressuresAsync() {
			if (this.SessionActive && (this.LastLap.Nr = lapNumber))
				this.addPressures(this.LastLap, simulator, car, track, weather, airTemperature, trackTemperature
								, compound, compoundColor, coldPressures, hotPressures, pressuresLosses)
		}

		this.pushTask(updatePressuresAsync)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

readSimulatorData(simulator) {
	local data := callSimulator(simulator)
	local setupData := callSimulator(simulator, "Setup=true")

	setMultiMapValues(data, "Setup Data", getMultiMapValues(setupData, "Setup Data"))

	return data
}

getDeprecatedValue(data, section, newKey, oldKey, default := false) {
	local value := getMultiMapValue(data, section, newKey, kUndefined)

	if (value != kUndefined)
		return value
	else
		return getMultiMapValue(data, section, oldKey, default)
}

convertValue(name, value) {
	if (value = kNull)
		return value
	else if InStr(name, "Temperature")
		return convertUnit("Temperature", value)
	else if InStr(name, "Pressure")
		return convertUnit("Pressure", value)
	else if InStr(name, "Fuel")
		return convertUnit("Volume", value)
	else
		return value
}

lapTimeDisplayValue(lapTime) {
	if (lapTime = "-")
		return "-"
	else
		return RaceReportViewer.lapTimeDisplayValue(lapTime)
}

displayNullValue(value, null := "-") {
	return (isNull(value) ? null : value)
}

chartValue(value) {
	return (isNull(value) ? kNull : value)
}

null(value) {
	return (((value == 0) || (value == "-") || (value = "n/a")) ? kNull : valueOrNull(value))
}

startupPracticeCenter() {
	local icon := kIconsDirectory . "Practice.ico"
	local settings := readMultiMap(kUserConfigDirectory . "Application Settings.ini")
	local simulator := getMultiMapValue(settings, "Practice Center", "Simulator", false)
	local car := getMultiMapValue(settings, "Practice Center", "Car", false)
	local track := getMultiMapValue(settings, "Practice Center", "Track", false)
	local index := 1
	local pCenter

	TraySetIcon(icon, "1")
	A_IconTip := "Practice Center"

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

	pCenter := PracticeCenter(kSimulatorConfiguration, readMultiMap(kUserConfigDirectory . "Race.settings"), simulator, car, track)

	pCenter.createGui(pCenter.Configuration)

	pCenter.show()

	registerMessageHandler("Practice", methodMessageHandler, pCenter)
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startupPracticeCenter()