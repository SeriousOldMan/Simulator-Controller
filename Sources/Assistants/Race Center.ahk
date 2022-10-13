;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Race Center Tool                ;;;
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

#MaxMem 128

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Console.ico
;@Ahk2Exe-ExeName Race Center.exe


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Messages.ahk
#Include ..\Libraries\Math.ahk
#Include ..\Libraries\CLR.ahk
#Include ..\Libraries\GDIP.ahk
#Include Libraries\SessionDatabase.ahk
#Include Libraries\SettingsDatabase.ahk
#Include Libraries\TyresDatabase.ahk
#Include Libraries\TelemetryDatabase.ahk
#Include Libraries\RaceReportViewer.ahk
#Include Libraries\Strategy.ahk
#Include Libraries\StrategyViewer.ahk


;;;-------------------------------------------------------------------------;;;
;;;                   Private Constant Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

global kClose := "Close"
global kConnect := "Connect"
global kEvent := "Event"

global kSessionReports := concatenate(["Track"], kRaceReports, ["Pressures", "Brakes", "Temperatures", "Free"])
global kDetailReports := ["Plan", "Stint", "Lap", "Session", "Drivers", "Strategy"]

global kSessionDataSchemas := {"Stint.Data": ["Nr", "Lap", "Driver.Forname", "Driver.Surname", "Driver.Nickname"
											, "Weather", "Compound", "Lap.Time.Average", "Lap.Time.Best", "Fuel.Consumption", "Accidents"
											, "Position.Start", "Position.End", "Time.Start", "Driver.ID"]
							 , "Driver.Data": ["Forname", "Surname", "Nickname", "Nr", "ID"]
							 , "Lap.Data": ["Stint", "Nr", "Lap", "Lap.Time", "Position", "Grip", "Map", "TC", "ABS"
										  , "Weather", "Temperature.Air", "Temperature.Track"
										  , "Fuel.Remaining", "Fuel.Consumption", "Damage", "Accident"
										  , "Tyre.Laps", "Tyre.Compound", "Tyre.Compound.Color"
										  , "Tyre.Pressure.Cold.Average", "Tyre.Pressure.Cold.Front.Average", "Tyre.Pressure.Cold.Rear.Average"
										  , "Tyre.Pressure.Cold.Front.Left", "Tyre.Pressure.Cold.Front.Right"
										  , "Tyre.Pressure.Cold.Rear.Left", "Tyre.Pressure.Cold.Rear.Right"
										  , "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
										  , "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right"
										  , "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
										  , "Tyre.Temperature.Average", "Tyre.Temperature.Front.Average", "Tyre.Temperature.Rear.Average"
										  , "Tyre.Temperature.Front.Left", "Tyre.Temperature.Front.Right"
										  , "Tyre.Temperature.Rear.Left", "Tyre.Temperature.Rear.Right"
										  , "Tyre.Wear.Average", "Tyre.Wear.Front.Average", "Tyre.Wear.Rear.Average"
										  , "Tyre.Wear.Front.Left", "Tyre.Wear.Front.Right"
										  , "Tyre.Wear.Rear.Left", "Tyre.Wear.Rear.Right"
										  , "Brake.Temperature.Front.Left", "Brake.Temperature.Front.Right"
										  , "Brake.Temperature.Rear.Left", "Brake.Temperature.Rear.Right"
										  , "Brake.Wear.Average", "Brake.Wear.Front.Average", "Brake.Wear.Rear.Average"
										  , "Brake.Wear.Front.Left", "Brake.Wear.Front.Right"
										  , "Brake.Wear.Rear.Left", "Brake.Wear.Rear.Right",
										  , "EngineDamage"
										  , "Brake.Temperature.Average"
										  , "Brake.Temperature.Front.Average", "Brake.Temperature.Rear.Average"]
							 , "Pitstop.Data": ["Lap", "Fuel", "Tyre.Compound", "Tyre.Compound.Color", "Tyre.Set"
											  , "Tyre.Pressure.Cold.Front.Left", "Tyre.Pressure.Cold.Front.Right"
											  , "Tyre.Pressure.Cold.Rear.Left", "Tyre.Pressure.Cold.Rear.Right"
											  , "Repair.Bodywork", "Repair.Suspension", "Repair.Engine", "Driver"]
							 , "Pitstop.Service.Data": ["Pitstop", "Lap", "Time", "Driver.Previous", "Driver.Next", "Fuel"
													  , "Tyre.Compound", "Tyre.Compound.Color", "Tyre.Set", "Tyre.Pressures"
													  , "Bodywork.Repair", "Suspension.Repair", "Engine.Repair"]
							 , "Pitstop.Tyre.Data": ["Pitstop", "Driver", "Laps", "Compound", "Compound.Color", "Set"
												   , "Tyre", "Tread", "Wear", "Grain", "Blister", "FlatSpot"]
							 , "Delta.Data": ["Lap", "Car", "Type", "Delta", "Distance"]
							 , "Standings.Data": ["Lap", "Car", "Driver", "Position", "Time", "Laps", "Delta"]
							 , "Plan.Data": ["Stint", "Driver", "Time.Planned", "Time.Actual", "Lap.Planned", "Lap.Actual"
										   , "Fuel.Amount", "Tyre.Change"]
							 , "Setups.Data": ["Driver", "Weather", "Temperature.Air", "Temperature.Track"
											 , "Tyre.Compound", "Tyre.Compound.Color"
											 , "Tyre.Pressure.Front.Left", "Tyre.Pressure.Front.Right"
											 , "Tyre.Pressure.Rear.Left", "Tyre.Pressure.Rear.Right"]}


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                        RaceCenterTask                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class RaceCenterTask extends Task {
	Window[] {
		Get {
			return RaceCenter.Instance.Window
		}
	}

	run() {
		local rCenter := RaceCenter.Instance

		if rCenter.startWorking() {
			try {
				base.run()

				return false
			}
			finally {
				rCenter.finishWorking()
			}
		}
		else
			return this
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                       SyncSessionTask                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class SyncSessionTask extends RaceCenterTask {
	__New() {
		base.__New(ObjBindMethod(RaceCenter.Instance, "syncSession"), 10000)

		this.Runnable := false
	}

	run() {
		base.run()

		this.NextExecution := (A_TickCount + 10000)

		return this
	}

	resume() {
		base.resume()

		this.NextExecution := A_TickCount
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; Class                          RaceCenter                               ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global messageField

global serverURLEdit
global serverTokenEdit
global teamDropDownMenu
global sessionDropDownMenu

global chartTypeDropDown
global chartViewer

global reportSettingsButton

global detailsViewer

global reportsListView

global driverDropDown
global dataXDropDown
global dataY1DropDown
global dataY2DropDown
global dataY3DropDown
global dataY4DropDown
global dataY5DropDown
global dataY6DropDown

global waitViewer

global sessionMenuDropDown
global strategyMenuDropDown
global planMenuDropDown
global pitstopMenuDropDown

global setupDriverDropDownMenu
global setupWeatherDropDownMenu
global setupAirTemperatureEdit
global setupTrackTemperatureEdit
global setupCompoundDropDownMenu
global setupBasePressureFLEdit
global setupBasePressureFrEdit
global setupBasePressureRLEdit
global setupBasePressureRREdit

global addSetupButton
global copySetupButton
global deleteSetupButton

global sessionDateCal
global sessionTimeEdit
global planDriverDropDownMenu
global planTimeEdit
global actTimeEdit
global planLapEdit
global actLapEdit
global planRefuelEdit
global planTyreCompoundDropDown

global addPlanButton
global deletePlanButton

global numScenariosEdit := 20
global variationWindowEdit := 3
global randomFactorEdit := 5

global useSessionDataDropDown
global useTelemetryDataDropDown
global keepMapDropDown
global considerTrafficDropDown

global lapTimeVariationDropDown
global driverErrorsDropDown
global pitstopsDropDown
global overtakeDeltaEdit := 2
global trafficConsideredEdit := 7

global pitstopLapEdit
global pitstopDriverDropDownMenu
global pitstopRefuelEdit
global pitstopTyreCompoundDropDown
global pitstopTyreSetEdit
global pitstopPressureFLEdit := ""
global pitstopPressureFREdit := ""
global pitstopPressureRLEdit := ""
global pitstopPressureRREdit := ""
global pitstopRepairsDropDown

class RaceCenter extends ConfigurationItem {
	iWorking := 0
	iSyncTask := false

	iClosed := false

	iSessionDirectory := false
	iRaceSettings := false

	iConnector := false
	iConnected := false

	iServerURL := ""
	iServerToken := "__INVALID__"

	iTeams := {}
	iSessions := {}
	iSessionDrivers := {}
	iTeamDrivers := []

	iTeamIdentifier := false
	iTeamName := false

	iSessionIdentifier := false
	iSessionName := false

	iSessionLoaded := false
	iSessionFinished := false

	iSetupsVersion := false
	iTeamDriversVersion := false

	iPlanVersion := false
	iDate := false
	iTime := false

	iSimulator := false
	iCar := false
	iTrack := false
	iWeather := false
	iWeather10Min := false
	iWeather30Min := false
	iAirTemperature := false
	iTrackTemperature := false

	iTyreCompounds := ["Dry"]

	iTyreCompound := false
	iTyreCompoundColor := false

	iStrategy := false

	iUseSessionData := true
	iUseTelemetryDatabase := false
	iUseCurrentMap := true
	iUseTraffic := false

	iDrivers := []
	iStints := {}
	iLaps := {}

	iCurrentStint := false
	iLastLap := false

	iSetupsListView := false
	iPlanListView := false
	iStintsListView := false
	iLapsListView := false
	iPitstopsListView := false

	iSelectedSetup := false
	iSelectedPlanStint := false

	iTyrePressureMode := "Relative"

	iSessionStore := false
	iTelemetryDatabase := false
	iPressuresDatabase := false

	iSimulationTelemetryDatabase := false

	iReportViewer := false
	iSelectedReport := false
	iSelectedChartType := false

	iAvailableDrivers := []
	iSelectedDrivers := false

	iSelectedDetailReport := false

	iStrategyViewer := false

	iTasks := []

	class RaceCenterTelemetryDatabase extends TelemetryDatabase {
		iRaceCenter := false
		iTelemetryDatabase := false

		class SessionTelemetryDatabase extends RaceCenter.RaceCenterTelemetryDatabase {
			Drivers[] {
				Get {
					return this.RaceCenter.SelectedDrivers
				}
			}
		}

		class SimulationTelemetryDatabase extends RaceCenter.RaceCenterTelemetryDatabase {
		}

		RaceCenter[] {
			Get {
				return this.iRaceCenter
			}
		}

		TelemetryDatabase[] {
			Get {
				return this.iTelemetryDatabase
			}
		}

		__New(raceCenter, simulator := false, car := false, track := false) {
			this.iRaceCenter := raceCenter

			base.__New()

			this.setDatabase(new Database(raceCenter.SessionDirectory, kTelemetrySchemas))

			if simulator
				this.iTelemetryDatabase := new TelemetryDatabase(simulator, car, track)
		}

		setDrivers(drivers) {
			base.setDrivers(drivers)

			if this.TelemetryDatabase
				this.TelemetryDatabase.setDrivers(drivers)
		}

		getMapData(weather, compound, compoundColor) {
			local entries := []
			local newEntries, ignore, entry, ignore, entry, found, candidate, lastLap, result

			if this.RaceCenter.UseSessionData
				for ignore, entry in base.getMapData(weather, compound, compoundColor)
					if ((entry["Fuel.Consumption"] > 0) && (entry["Lap.Time"] > 0))
						entries.Push(entry)

			if (this.RaceCenter.UseTelemetryDatabase && this.TelemetryDatabase) {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getMapData(weather, compound, compoundColor) {
					if ((entry["Fuel.Consumption"] > 0) && (entry["Lap.Time"] > 0)) {
						found := false

						for ignore, candidate in entries
							if ((candidate.Map = entry.Map) && (candidate["Lap.Time"] = entry["Lap.Time"])
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

			if this.RaceCenter.UseCurrentMap {
				lastLap := this.iRaceCenter.LastLap

				if lastLap {
					result := []

					for ignore, entry in entries
						if (entry.Map = lastLap.Map)
							result.Push(entry)

					return result
				}
			}

			return entries
		}

		getTyreData(weather, compound, compoundColor) {
			local entries := []
			local newEntries, ignore, entry, found, candidate

			if this.RaceCenter.UseSessionData
				for ignore, entry in base.getTyreData(weather, compound, compoundColor)
					if (entry["Lap.Time"] > 0)
						entries.Push(entry)

			if (this.RaceCenter.UseTelemetryDatabase && this.TelemetryDatabase) {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getTyreData(weather, compound, compoundColor) {
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

		getMapLapTimes(weather, compound, compoundColor) {
			local entries := []
			local newEntries, ignore, entry, found, candidate, lastLap, result

			if this.RaceCenter.UseSessionData
				for ignore, entry in base.getMapLapTimes(weather, compound, compoundColor)
					if (entry["Lap.Time"] > 0)
						entries.Push(entry)

			if (this.RaceCenter.UseTelemetryDatabase && this.TelemetryDatabase) {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getMapLapTimes(weather, compound, compoundColor) {
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

			if this.iRaceCenter.UseCurrentMap {
				lastLap := this.iRaceCenter.LastLap

				if lastLap {
					result := []

					for ignore, entry in entries
						if (entry.Map = lastLap.Map)
							result.Push(entry)

					return result
				}
			}

			return entries
		}

		getTyreLapTimes(weather, compound, compoundColor) {
			local entries := []
			local newEntries, ignore, entry, found, candidate

			if this.RaceCenter.UseSessionData
				for ignore, entry in base.getTyreLapTimes(weather, compound, compoundColor)
					if (entry["Lap.Time"] > 0)
						entries.Push(entry)

			if (this.RaceCenter.UseTelemetryDatabase && this.TelemetryDatabase) {
				newEntries := []

				for ignore, entry in this.TelemetryDatabase.getTyreLapTimes(weather, compound, compoundColor) {
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

		Database[] {
			Get {
				return this.iDatabase
			}
		}

		__New(rCenter) {
			this.iDatabase := new Database(rCenter.SessionDirectory, kTyresSchemas)
		}

		updatePressures(weather, airTemperature, trackTemperature, compound, compoundColor, coldPressures, hotPressures, flush := true) {
			local tyres, types, typeIndex, tPressures, tyreIndex, pressure

			if (!compoundColor || (compoundColor = ""))
				compoundColor := "Black"

			this.Database.add("Tyres.Pressures", {Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
												, Compound: compound, "Compound.Color": compoundColor
												, "Tyre.Pressure.Cold.Front.Left": null(coldPressures[1])
												, "Tyre.Pressure.Cold.Front.Right": null(coldPressures[2])
												, "Tyre.Pressure.Cold.Rear.Left": null(coldPressures[3])
												, "Tyre.Pressure.Cold.Rear.Right": null(coldPressures[4])
												, "Tyre.Pressure.Hot.Front.Left": null(hotPressures[1])
												, "Tyre.Pressure.Hot.Front.Right": null(hotPressures[2])
												, "Tyre.Pressure.Hot.Rear.Left": null(hotPressures[3])
												, "Tyre.Pressure.Hot.Rear.Right": null(hotPressures[4])}
												, flush)

			tyres := ["FL", "FR", "RL", "RR"]
			types := ["Cold", "Hot"]

			for typeIndex, tPressures in [coldPressures, hotPressures]
				for tyreIndex, pressure in tPressures
					this.updatePressure(weather, airTemperature, trackTemperature, compound, compoundColor
									  , types[typeIndex], tyres[tyreIndex], pressure, 1, flush, false)
		}

		updatePressure(weather, airTemperature, trackTemperature, compound, compoundColor
					 , type, tyre, pressure, count := 1, flush := true) {
			local rows

			if (isNull(null(pressure)))
				return

			if (!compoundColor || (compoundColor = ""))
				compoundColor := "Black"

			rows := this.Database.query("Tyres.Pressures.Distribution"
									  , {Where: {Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
											   , Compound: compound, "Compound.Color": compoundColor, Type: type, Tyre: tyre, "Pressure": pressure}})

			if (rows.Length() > 0)
				rows[1].Count := rows[1].Count + count
			else
				this.Database.add("Tyres.Pressures.Distribution"
								, {Weather: weather, "Temperature.Air": airTemperature, "Temperature.Track": trackTemperature
								 , Compound: compound, "Compound.Color": compoundColor, Type: type, Tyre: tyre, "Pressure": pressure, Count: count}, flush)
		}
	}

	class SessionStrategy extends Strategy {
		initializeAvailableTyreSets() {
			base.initializeAvailableTyreSets()

			RaceCenter.Instance.initializeAvailableTyreSets(this)
		}
	}

	class SessionTrafficStrategy extends TrafficStrategy {
		initializeAvailableTyreSets() {
			base.initializeAvailableTyreSets()

			RaceCenter.Instance.initializeAvailableTyreSets(this)
		}
	}

	Window[] {
		Get {
			return "RaceCenter"
		}
	}

	RaceSettings[] {
		Get {
			return this.iRaceSettings
		}
	}

	SessionDirectory[] {
		Get {
			if this.SessionActive
				return (this.iSessionDirectory . this.iSessionName . "\")
			else if this.SessionLoaded
				return this.SessionLoaded
			else
				return this.iSessionDirectory
		}
	}

	Connector[] {
		Get {
			return this.iConnector
		}
	}

	Connected[] {
		Get {
			return this.iConnected
		}
	}

	ServerURL[] {
		Get {
			return this.iServerURL
		}
	}

	ServerToken[] {
		Get {
			return this.iServerToken
		}
	}

	Teams[key := false] {
		Get {
			if key
				return this.iTeams[key]
			else
				return this.iTeams
		}
	}

	Sessions[key := false] {
		Get {
			if key
				return this.iSessions[key]
			else
				return this.iSessions
		}
	}

	SessionDrivers[key := false] {
		Get {
			if key
				return this.iSessionDrivers[key]
			else
				return this.iSessionDrivers
		}
	}

	TeamDrivers[key := false] {
		Get {
			if key
				return this.iTeamDrivers[key]
			else
				return this.iTeamDrivers
		}
	}

	SelectedTeam[asIdentifier := false] {
		Get {
			return (asIdentifier ? this.iTeamIdentifier : this.iTeamName)
		}
	}

	SelectedSession[asIdentifier := false] {
		Get {
			return (asIdentifier ? this.iSessionIdentifier : this.iSessionName)
		}
	}

	SessionActive[] {
		Get {
			return (this.Connected && this.SelectedTeam[true] && this.SelectedSession[true])
		}
	}

	SessionFinished[] {
		Get {
			return this.iSessionFinished
		}
	}

	SessionLoaded[] {
		Get {
			return this.iSessionLoaded
		}
	}

	HasData[] {
		Get {
			return ((this.SessionActive && this.CurrentStint) || this.SessionLoaded)
		}
	}

	SetupsVersion[] {
		Get {
			return this.iSetupsVersion
		}
	}

	TeamDriversVersion[] {
		Get {
			return this.iTeamDriversVersion
		}
	}

	PlanVersion[] {
		Get {
			return this.iPlanVersion
		}
	}

	Date[] {
		Get {
			return this.iDate
		}
	}

	Time[] {
		Get {
			return this.iTime
		}
	}

	Simulator[] {
		Get {
			return this.iSimulator
		}
	}

	Car[] {
		Get {
			return this.iCar
		}
	}

	Track[] {
		Get {
			return this.iTrack
		}
	}

	Weather[] {
		Get {
			return this.iWeather
		}
	}

	Weather10Min[] {
		Get {
			return this.iWeather10Min
		}
	}

	Weather30Min[] {
		Get {
			return this.iWeather30Min
		}
	}

	AirTemperature[] {
		Get {
			return this.iAirTemperature
		}
	}

	TrackTemperature[] {
		Get {
			return this.iTrackTemperature
		}
	}

	TyreCompounds[key := false] {
		Get {
			return (key ? this.iTyreCompounds[key] : this.iTyreCompounds)
		}
	}

	TyreCompound[] {
		Get {
			return this.iTyreCompound
		}
	}

	TyreCompoundColor[] {
		Get {
			return this.iTyreCompoundColor
		}
	}

	Strategy[] {
		Get {
			return this.iStrategy
		}
	}

	StintDriver[] {
		Get {
			return this.iStintDriver
		}
	}

	UseSessionData[] {
		Get {
			return this.iUseSessionData
		}
	}

	UseTelemetryDatabase[] {
		Get {
			return this.iUseTelemetryDatabase
		}
	}

	UseCurrentMap[] {
		Get {
			return this.iUseCurrentMap
		}
	}

	UseTraffic[] {
		Get {
			return this.iUseTraffic
		}
	}

	Drivers[] {
		Get {
			return this.iDrivers
		}

		Set {
			return (key ? (this.iStints[key] := value) : (this.iStints := value))
		}
	}

	Stints[key := false] {
		Get {
			return (key ? this.iStints[key] : this.iStints)
		}

		Set {
			return (key ? (this.iStints[key] := value) : (this.iStints := value))
		}
	}

	CurrentStint[asIdentifier := false] {
		Get {
			if this.iCurrentStint
				return (asIdentifier ? this.iCurrentStint.Identifier : this.iCurrentStint)
			else
				return false
		}
	}

	Laps[key := false] {
		Get {
			return (key ? this.iLaps[key] : this.iLaps)
		}

		Set {
			return (key ? (this.iLaps[key] := value) : (this.iLaps := value))
		}
	}

	LastLap[asIdentifier := false] {
		Get {
			if this.iLastLap
				return (asIdentifier ? this.iLastLap.Identifier : this.iLastLap)
			else
				return false
		}
	}

	SetupsListView[] {
		Get {
			return this.iSetupsListView
		}
	}

	PlanListView[] {
		Get {
			return this.iPlanListView
		}
	}

	StintsListView[] {
		Get {
			return this.iStintsListView
		}
	}

	LapsListView[] {
		Get {
			return this.iLapsListView
		}
	}

	PitstopsListView[] {
		Get {
			return this.iPitstopsListView
		}
	}

	SelectedSetup[] {
		Get {
			return this.iSelectedSetup
		}
	}

	SelectedPlanStint[] {
		Get {
			return this.iSelectedPlanStint
		}
	}

	TyrePressureMode[] {
		Get {
			return this.iTyrePressureMode
		}
	}

	SessionStore[] {
		Get {
			if !this.iSessionStore
				this.iSessionStore := new Database(this.SessionDirectory, kSessionDataSchemas)

			return this.iSessionStore
		}
	}

	TelemetryDatabase[] {
		Get {
			if !this.iTelemetryDatabase
				this.iTelemetryDatabase := new this.RaceCenterTelemetryDatabase.SessionTelemetryDatabase(this)

			return this.iTelemetryDatabase
		}
	}

	SimulationTelemetryDatabase[] {
		Get {
			return (this.iSimulationTelemetryDatabase ? this.iSimulationTelemetryDatabase : this.TelemetryDatabase)
		}
	}

	PressuresDatabase[] {
		Get {
			if !this.iPressuresDatabase
				this.iPressuresDatabase := new this.SessionPressuresDatabase(this)

			return this.iPressuresDatabase
		}
	}

	ReportViewer[] {
		Get {
			return this.iReportViewer
		}
	}

	StrategyViewer[] {
		Get {
			return this.iStrategyViewer
		}
	}

	SelectedReport[] {
		Get {
			return this.iSelectedReport
		}
	}

	SelectedChartType[] {
		Get {
			return this.iSelectedChartType
		}
	}

	AvailableDrivers[index := false] {
		Get {
			return (index ? this.iAvailableDrivers[index] : this.iAvailableDrivers)
		}
	}

	SelectedDrivers[] {
		Get {
			return this.iSelectedDrivers
		}
	}

	SelectedDetailReport[] {
		Get {
			return this.iSelectedDetailReport
		}
	}

	__New(configuration, raceSettings) {
		local dllName, dllFile

		this.iRaceSettings := raceSettings

		dllName := "Team Server Connector.dll"
		dllFile := kBinariesDirectory . dllName

		try {
			if !FileExist(dllFile) {
				logMessage(kLogCritical, translate("Team Server Connector.dll not found in ") . kBinariesDirectory)

				throw "Unable to find Team Server Connector.dll in " . kBinariesDirectory . "..."
			}

			this.iConnector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.TeamServerConnector")
		}
		catch exception {
			logMessage(kLogCritical, translate("Error while initializing Team Server Connector - please rebuild the applications"))

			showMessage(translate("Error while initializing Team Server Connector - please rebuild the applications") . translate("...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}

		base.__New(configuration)

		RaceCenter.Instance := this

		this.iSyncTask := new SyncSessionTask()

		Task.addTask(this.iSyncTask)
	}

	loadFromConfiguration(configuration) {
		local directory, settings

		base.loadFromConfiguration(configuration)

		if FileExist(kUserConfigDirectory . "Team Server.ini")
			configuration := readConfiguration(kUserConfigDirectory . "Team Server.ini")

		directory := getConfigurationValue(configuration, "Team Server", "Session.Folder", kTempDirectory . "Sessions")

		if (!directory || (directory = ""))
			directory := (kTempDirectory . "Sessions")

		this.iSessionDirectory := (directory . "\")

		settings := this.RaceSettings

		this.iServerURL := getConfigurationValue(settings, "Team Settings", "Server.URL"
														 , getConfigurationValue(configuration, "Team Server", "Server.URL", ""))
		this.iServerToken := getConfigurationValue(settings, "Team Settings", "Server.Token"
														   , getConfigurationValue(configuration, "Team Server", "Server.Token", "__INVALID__"))
		this.iTeamName := getConfigurationValue(settings, "Team Settings", "Team.Name", "")
		this.iTeamIdentifier := getConfigurationValue(settings, "Team Settings", "Team.Identifier", false)
		this.iSessionName := getConfigurationValue(settings, "Team Settings", "Session.Name", "")
		this.iSessionIdentifier := getConfigurationValue(settings, "Team Settings", "Session.Identifier", false)
	}

	createGui(configuration) {
		local window := this.Window
		local x, y, width, ignore, report, choices

		Gui %window%:Default

		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Text, w1334 Center gmoveRaceCenter, % translate("Modular Simulator Controller System")

		Gui %window%:Font, s9 Norm, Arial
		Gui %window%:Font, Italic Underline, Arial

		Gui %window%:Add, Text, x608 YP+20 w134 cBlue Center gopenDashboardDocumentation, % translate("Race Center")

		Gui %window%:Add, Text, x8 yp+30 w1350 0x10

		Gui %window%:Font, Norm
		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x16 yp+12 w30 h30 Section, %kIconsDirectory%Report.ico
		Gui %window%:Add, Text, x50 yp+5 w80 h26, % translate("Reports")

		Gui %window%:Font, s8 Norm, Arial

		x := 16
		y := 70
		width := 388

		Gui %window%:Add, Text, x16 yp+30 w90 h23 +0x200, % translate("Server URL")
		Gui %window%:Add, Edit, x141 yp+1 w245 h21 VserverURLEdit, % this.ServerURL

		Gui %window%:Add, Text, x16 yp+24 w90 h23 +0x200, % translate("Access Token")
		Gui %window%:Add, Edit, x141 yp+1 w245 h21 VserverTokenEdit, % this.ServerToken
		Gui %window%:Add, Button, x116 yp-1 w23 h23 Center +0x200 HWNDconnectButton gconnectServer
		setButtonIcon(connectButton, kIconsDirectory . "Authorize.ico", 1, "L4 T4 R4 B4")

		Gui %window%:Add, Text, x16 yp+26 w90 h23 +0x200, % translate("Team / Session")

		if this.SelectedTeam[true]
			Gui %window%:Add, DropDownList, x141 yp w120 AltSubmit Choose1 vteamDropDownMenu gchooseTeam, % this.SelectedTeam
		else
			Gui %window%:Add, DropDownList, x141 yp w120 AltSubmit vteamDropDownMenu gchooseTeam

		if this.SelectedSession[true]
			Gui %window%:Add, DropDownList, x266 yp w120 AltSubmit Choose1 vsessionDropDownMenu gchooseSession, % this.SelectedSession
		else
			Gui %window%:Add, DropDownList, x266 yp w120 AltSubmit Choose0 vsessionDropDownMenu gchooseSession

		Gui %window%:Add, Text, x24 yp+30 w356 0x10

		Gui %window%:Add, ListView, x16 yp+10 w115 h230 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDreportsListView gchooseReport, % translate("Report")

		for ignore, report in kSessionReports
			if (report = "Drivers")
				LV_Add("", translate("Driver (Start)"))
			else
				LV_Add("", translate(report))

		LV_ModifyCol(1, "AutoHdr")

		Gui %window%:Add, Text, x141 yp+2 w70 h23 +0x200, % translate("Driver")
		Gui %window%:Add, DropDownList, x195 yp w191 AltSubmit gchooseDriver vdriverDropDown

		Gui %window%:Add, Text, x141 yp+24 w70 h23 +0x200, % translate("X-Axis")

		Gui %window%:Add, DropDownList, x195 yp w191 AltSubmit vdataXDropDown gchooseAxis

		Gui %window%:Add, Text, x141 yp+24 w70 h23 +0x200, % translate("Series")

		Gui %window%:Add, DropDownList, x195 yp w191 AltSubmit vdataY1DropDown gchooseAxis
		Gui %window%:Add, DropDownList, x195 yp+24 w191 AltSubmit vdataY2DropDown gchooseAxis
		Gui %window%:Add, DropDownList, x195 yp+24 w191 AltSubmit vdataY3DropDown gchooseAxis
		Gui %window%:Add, DropDownList, x195 yp+24 w191 AltSubmit vdataY4DropDown gchooseAxis
		Gui %window%:Add, DropDownList, x195 yp+24 w191 AltSubmit vdataY5DropDown gchooseAxis
		Gui %window%:Add, DropDownList, x195 yp+24 w191 AltSubmit vdataY6DropDown gchooseAxis

		Gui %window%:Add, Text, x400 ys w40 h23 +0x200, % translate("Plot")
		Gui %window%:Add, DropDownList, x444 yp w80 AltSubmit Choose1 vchartTypeDropDown gchooseChartType, % values2String("|", map(["Scatter", "Bar", "Bubble", "Line"], "translate")*)

		Gui %window%:Add, Button, x1327 yp w23 h23 HwndreportSettingsButtonHandle vreportSettingsButton greportSettings
		setButtonIcon(reportSettingsButtonHandle, kIconsDirectory . "General Settings.ico", 1)

		Gui %window%:Add, ActiveX, x400 yp+24 w950 h343 Border vchartViewer, shell.explorer

		chartViewer.Navigate("about:blank")

		Gui %window%:Add, Text, x8 yp+351 w1350 0x10

		Gui %window%:Font, s10 Bold, Arial

		Gui %window%:Add, Picture, x16 yp+10 w30 h30 Section, %kIconsDirectory%Tools BW.ico
		Gui %window%:Add, Text, x50 yp+5 w80 h26, % translate("Session")

		Gui %window%:Add, ActiveX, x1323 yp w30 h30 vwaitViewer, shell.explorer

		waitViewer.Navigate("about:blank")

		this.startWorking(false)

		Gui %window%:Font, s8 Norm cBlack, Arial

		Gui %window%:Add, DropDownList, x195 yp-2 w180 AltSubmit Choose1 +0x200 vsessionMenuDropDown gsessionMenu, % values2String("|", map(["Session", "---------------------------------------------", "Connect", "Clear...", "---------------------------------------------", "Load Session...", "Save Session", "Save a Copy...", "---------------------------------------------", "Update Statistics", "---------------------------------------------", "Race Summary", "Driver Statistics"], "translate")*)

		Gui %window%:Add, DropDownList, x380 yp w180 AltSubmit Choose1 +0x200 vplanMenuDropDown gplanMenu, % values2String("|", map(["Plan", "---------------------------------------------", "Load from Strategy", "Clear Plan...", "---------------------------------------------", "Plan Summary", "---------------------------------------------", "Release Plan"], "translate")*)

		Gui %window%:Add, DropDownList, x565 yp w180 AltSubmit Choose1 +0x200 vstrategyMenuDropDown gstrategyMenu

		Gui %window%:Add, DropDownList, x750 yp w180 AltSubmit Choose1 +0x200 vpitstopMenuDropDown gpitstopMenu

		Gui %window%:Font, s8 Norm, Arial

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x619 ys+39 w732 h9, % translate("Output")

		Gui %window%:Add, ActiveX, x619 yp+21 w732 h293 Border vdetailsViewer, shell.explorer

		detailsViewer.Navigate("about:blank")

		this.iStrategyViewer := new StrategyViewer(window, detailsViewer)

		this.showDetails(false, false)
		this.showChart(false)

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x8 y815 w1350 0x10

		Gui %window%:Add, Text, x16 y827 w554 vmessageField
		Gui %window%:Add, Button, x649 y824 w80 h23 GcloseRaceCenter, % translate("Close")

		Gui %window%:Add, Tab3, x16 ys+39 w593 h316 -Wrap Section, % values2String("|", map(["Plan", "Stints", "Laps", "Strategy", "Setups", "Pitstops"], "translate")*)

		Gui Tab, 1

		Gui %window%:Add, Text, x24 ys+33 w90 h23 +0x200, % translate("Session")
		Gui %window%:Add, DateTime, x106 yp w80 h23 vsessionDateCal gupdateDate
		Gui %window%:Add, DateTime, x190 yp w50 h23  vsessionTimeEdit gupdateTime 1, HH:mm

		Gui %window%:Add, ListView, x24 ys+63 w344 h240 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDlistHandle gchoosePlan, % values2String("|", map(["Stint", "Driver", "Time (est.)", "Time (act.)", "Lap (est.)", "Lap (act.)", "Refuel", "Tyre Change"], "translate")*)

		this.iPlanListView := listHandle

		Gui %window%:Add, Text, x378 ys+68 w90 h23 +0x200, % translate("Driver")
		Gui %window%:Add, DropDownList, x474 yp w126 AltSubmit vplanDriverDropDownMenu gupdatePlan

		Gui %window%:Add, Text, x378 yp+28 w90 h23 +0x200, % translate("Time (est. / act.)")
		Gui %window%:Add, DateTime, x474 yp w50 h23 vplanTimeEdit gupdatePlan 1, HH:mm
		Gui %window%:Add, DateTime, x528 yp w50 h23 vactTimeEdit gupdatePlan 1, HH:mm

		Gui %window%:Add, Text, x378 yp+28 w90 h20, % translate("Lap (est. / act.)")
		Gui %window%:Add, Edit, x474 yp-2 w50 h20 Limit3 Number vplanLapEdit gupdatePlan
		Gui %window%:Add, UpDown, x506 yp w18 h20
		Gui %window%:Add, Edit, x528 yp w50 h20 Limit3 Number vactLapEdit gupdatePlan
		Gui %window%:Add, UpDown, x560 yp w18 h20

		Gui %window%:Add, Text, x378 yp+30 w85 h20, % translate("Refuel")
		Gui %window%:Add, Edit, x474 yp-2 w50 h20 Limit3 Number vplanRefuelEdit gupdatePlan
		Gui %window%:Add, UpDown, x506 yp-2 w18 h20
		Gui %window%:Add, Text, x528 yp+2 w30 h20, % translate("Liter")

		Gui %window%:Add, Text, x378 yp+24 w85 h23 +0x200, % translate("Tyre Change")
		choices := map(["Yes", "No"], "translate")
		Gui %window%:Add, DropDownList, x474 yp w50 AltSubmit Choose1 vplanTyreCompoundDropDown gupdatePlan, % values2String("|", choices*)

		Gui %window%:Add, Button, x550 yp+30 w23 h23 Center +0x200 HWNDplusButton vaddPlanButton gaddPlan
		setButtonIcon(plusButton, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, x575 yp w23 h23 Center +0x200 HWNDminusButton vdeletePlanButton gdeletePlan
		setButtonIcon(minusButton, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		Gui %window%:Add, Button, x408 ys+279 w160 greleasePlan, % translate("Release Plan")

		Gui Tab, 2

		Gui %window%:Add, ListView, x24 ys+33 w577 h270 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDlistHandle gchooseStint, % values2String("|", map(["#", "Driver", "Weather", "Compound", "Laps", "Pos. (Start)", "Pos. (End)", "Avg. Lap Time", "Consumption", "Accidents", "Potential", "Race Craft", "Speed", "Consistency", "Car Control"], "translate")*)

		this.iStintsListView := listHandle

		Gui Tab, 3

		Gui %window%:Add, ListView, x24 ys+33 w577 h270 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDlistHandle gchooseLap, % values2String("|", map(["#", "Stint", "Driver", "Position", "Weather", "Grip", "Lap Time", "Consumption", "Remaining", "Pressures", "Accident"], "translate")*)

		this.iLapsListView := listHandle

		Gui Tab, 4

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x24 ys+33 w260 h124, % translate("Simulation")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x32 yp+24 w85 h23 +0x200, % translate("Random Factor")
		Gui %window%:Add, Edit, x170 yp w50 h20 Limit2 Number VrandomFactorEdit, %randomFactorEdit%
		Gui %window%:Add, UpDown, x202 yp w18 h20, %randomFactorEdit%
		Gui %window%:Add, Text, x228 yp+2 w50 h20, % translate("%")

		Gui %window%:Add, Text, x32 yp+22 w85 h23 +0x200, % translate("# Scenarios")
		Gui %window%:Add, Edit, x170 yp w50 h20 Limit2 Number VnumScenariosEdit, %numScenariosEdit%
		Gui %window%:Add, UpDown, x202 yp w18 h20, %numScenariosEdit%

		Gui %window%:Add, Text, x32 yp+24 w85 h23 +0x200, % translate("Variation")
		Gui %window%:Add, Text, x150 yp w18 h23 +0x200, % translate("+/-")
		Gui %window%:Add, Edit, x170 yp w50 h20 Limit2 Number VvariationWindowEdit, %variationWindowEdit%
		Gui %window%:Add, UpDown, x202 yp w18 h20, %variationWindowEdit%
		Gui %window%:Add, Text, x228 yp+2 w50 h20, % translate("laps")

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x304 ys+33 w296 h124, % translate("Settings")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x312 yp+24 w160 h23, % translate("Use Session Data")
		Gui %window%:Add, DropDownList, x480 yp-3 w50 AltSubmit Choose1 vuseSessionDataDropDown gchooseSimulationSettings, % values2String("|", map(["Yes", "No"], "translate")*)

		Gui %window%:Add, Text, x312 yp+27 w160 h23, % translate("Use Telemetry Database")
		Gui %window%:Add, DropDownList, x480 yp-3 w50 AltSubmit Choose2 vuseTelemetryDataDropDown gchooseSimulationSettings, % values2String("|", map(["Yes", "No"], "translate")*)

		Gui %window%:Add, Text, x312 yp+27 w160 h23, % translate("Keep current Map")
		Gui %window%:Add, DropDownList, x480 yp-3 w50 AltSubmit Choose1 vkeepMapDropDown gchooseSimulationSettings, % values2String("|", map(["Yes", "No"], "translate")*)

		Gui %window%:Add, Text, x312 yp+27 w160 h23, % translate("Analyze Traffic")
		Gui %window%:Add, DropDownList, x480 yp-3 w50 AltSubmit Choose2 vconsiderTrafficDropDown gchooseSimulationSettings, % values2String("|", map(["Yes", "No"], "translate")*)

		Gui %window%:Font, Norm, Arial
		Gui %window%:Font, Italic, Arial

		Gui %window%:Add, GroupBox, -Theme x24 yp+37 w576 h148, % translate("Traffic Analysis (Monte Carlo)")

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x32 yp+24 w85 h23 +0x200, % translate("Laptime Variation")
		Gui %window%:Add, DropDownList, x162 yp w50 AltSubmit Choose1 vlapTimeVariationDropDown, % values2String("|", map(["Yes", "No"], "translate")*)
		Gui %window%:Add, Text, x220 yp+2 w290 h20, % translate("according to driver consistency")

		Gui %window%:Add, Text, x32 yp+22 w85 h23 +0x200, % translate("Driver Errors")
		Gui %window%:Add, DropDownList, x162 yp w50 AltSubmit Choose1 vdriverErrorsDropDown, % values2String("|", map(["Yes", "No"], "translate")*)
		Gui %window%:Add, Text, x220 yp+2 w290 h20, % translate("according to driver car control")

		Gui %window%:Add, Text, x32 yp+22 w85 h23 +0x200, % translate("Pitstops")
		Gui %window%:Add, DropDownList, x162 yp w50 AltSubmit Choose1 vpitstopsDropDown, % values2String("|", map(["Yes", "No"], "translate")*)
		Gui %window%:Add, Text, x220 yp+2 w290 h20, % translate("according to random factor")

		Gui %window%:Add, Text, x32 yp+24 w85 h23 +0x200, % translate("Overtake")
		Gui %window%:Add, Text, x132 yp w28 h23 +0x200, % translate("Abs(")
		Gui %window%:Add, Edit, x162 yp w50 h20 Limit2 Number VovertakeDeltaEdit, %overtakeDeltaEdit%
		Gui %window%:Add, UpDown, x194 yp-2 w18 h20 Range1-99 0x80, %overtakeDeltaEdit%
		Gui %window%:Add, Text, x220 yp+4 w340 h20, % translate("/ laptime difference) = additional seconds for each passed car")

		Gui %window%:Add, Text, x32 yp+20 w85 h23 +0x200, % translate("Traffic")
		Gui %window%:Add, Edit, x162 yp w50 h20 Limit2 Number VtrafficConsideredEdit, %trafficConsideredEdit%
		Gui %window%:Add, UpDown, x194 yp-2 w18 h20 Range1-99 0x80, %trafficConsideredEdit%
		Gui %window%:Add, Text, x220 yp+4 w290 h20, % translate("% track length")

		Gui Tab, 5

		Gui %window%:Add, ListView, x24 ys+33 w344 h270 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDlistHandle gchooseSetup, % values2String("|", map(["Driver", "Conditions", "Compound", "Pressures"], "translate")*)

		this.iSetupsListView := listHandle

		Gui %window%:Add, Text, x378 ys+38 w90 h23 +0x200, % translate("Driver")
		Gui %window%:Add, DropDownList, x474 yp w126 AltSubmit vsetupDriverDropDownMenu gupdateSetup

		Gui %window%:Add, Text, x378 yp+30 w70 h23 +0x200, % translate("Weather")

		choices := map(kWeatherConditions, "translate")

		Gui %window%:Add, DropDownList, x474 yp w126 AltSubmit Choose0 vsetupWeatherDropDownMenu gupdateSetup, % values2String("|", choices*)

		Gui %window%:Add, Text, x378 yp+24 w70 h23 +0x200, % translate("Temperatures")

		Gui %window%:Add, Edit, x474 yp w40 vsetupAirTemperatureEdit gupdateSetup, % ""
		Gui %window%:Add, UpDown, x476 yp w18 h20

		Gui %window%:Add, Edit, x521 yp w40 vsetupTrackTemperatureEdit gupdateSetup, % ""
		Gui %window%:Add, UpDown, x523 yp w18 h20
		Gui %window%:Add, Text, x563 yp w35 h23 +0x200, % translate("A / T")

		choices := map(["Dry"], "translate")

		Gui %window%:Add, Text, x378 yp+24 w70 h23 +0x200, % translate("Compound")
		Gui %window%:Add, DropDownList, x474 yp+1 w126 AltSubmit Choose0 vsetupCompoundDropDownMenu gupdateSetup, % values2String("|", choices*)

		Gui %window%:Add, Text, x378 yp+30 w90 h23 +0x200, % translate("Pressure FL")
		Gui %window%:Add, Edit, x474 yp+1 w50 h23 vsetupBasePressureFLEdit gupdateSetup
		Gui %window%:Add, Text, x527 yp+3 w30 h20, % translate("PSI")

		Gui %window%:Add, Text, x378 yp+20 w90 h23 +0x200, % translate("Pressure FR")
		Gui %window%:Add, Edit, x474 yp+1 w50 h23 vsetupBasePressureFREdit gupdateSetup
		Gui %window%:Add, Text, x527 yp+3 w30 h20, % translate("PSI")

		Gui %window%:Add, Text, x378 yp+20 w90 h23 +0x200, % translate("Pressure RL")
		Gui %window%:Add, Edit, x474 yp+1 w50 h23 vsetupBasePressureRLEdit gupdateSetup
		Gui %window%:Add, Text, x527 yp+3 w30 h20, % translate("PSI")

		Gui %window%:Add, Text, x378 yp+20 w90 h23 +0x200, % translate("Pressure RR")
		Gui %window%:Add, Edit, x474 yp+1 w50 h23 vsetupBasePressureRREdit gupdateSetup
		Gui %window%:Add, Text, x527 yp+3 w30 h20, % translate("PSI")

		Gui %window%:Add, Button, x525 yp+30 w23 h23 Center +0x200 HWNDplusButton vaddSetupButton gaddSetup
		setButtonIcon(plusButton, kIconsDirectory . "Plus.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, x550 yp w23 h23 Center +0x200 HWNDcopyButton vcopySetupButton gcopySetup
		setButtonIcon(copyButton, kIconsDirectory . "Copy.ico", 1, "L4 T4 R4 B4")
		Gui %window%:Add, Button, x575 yp w23 h23 Center +0x200 HWNDminusButton vdeleteSetupButton gdeleteSetup
		setButtonIcon(minusButton, kIconsDirectory . "Minus.ico", 1, "L4 T4 R4 B4")

		Gui %window%:Add, Button, x408 ys+279 w160 greleaseSetups, % translate("Save Setups")

		Gui Tab, 6

		Gui %window%:Add, Text, x24 ys+36 w85 h20, % translate("Lap")
		Gui %window%:Add, Edit, x106 yp-2 w50 h20 Limit3 Number vpitstopLapEdit
		Gui %window%:Add, UpDown, x138 yp-2 w18 h20

		Gui %window%:Add, Text, x24 yp+30 w80 h23 +0x200, % translate("Driver")
		Gui %window%:Add, DropDownList, x106 yp w157 vpitstopDriverDropDownMenu

		Gui %window%:Add, Text, x24 yp+30 w85 h20, % translate("Refuel")
		Gui %window%:Add, Edit, x106 yp-2 w50 h20 Limit3 Number vpitstopRefuelEdit
		Gui %window%:Add, UpDown, x138 yp-2 w18 h20
		Gui %window%:Add, Text, x164 yp+2 w30 h20, % translate("Liter")

		Gui %window%:Add, Text, x24 yp+24 w85 h23 +0x200, % translate("Tyre Change")
		choices := map(["No Tyre Change", "Dry"], "translate")
		Gui %window%:Add, DropDownList, x106 yp w157 AltSubmit Choose1 vpitstopTyreCompoundDropDown gupdateState, % values2String("|", choices*)

		Gui %window%:Add, Text, x24 yp+26 w85 h20, % translate("Tyre Set")
		Gui %window%:Add, Edit, x106 yp-2 w50 h20 Limit2 Number vpitstopTyreSetEdit
		Gui %window%:Add, UpDown, x138 yp w18 h20

		Gui %window%:Add, Text, x24 yp+24 w85 h20, % translate("Pressures")

		Gui %window%:Add, Edit, x106 yp-2 w50 h20 Limit4 vpitstopPressureFLEdit gvalidatePitstopPressureFL
		Gui %window%:Add, Edit, x160 yp w50 h20 Limit4 vpitstopPressureFREdit gvalidatePitstopPressureFR
		Gui %window%:Add, Text, x214 yp+2 w30 h20, % translate("PSI")
		Gui %window%:Add, Edit, x106 yp+20 w50 h20 Limit4 vpitstopPressureRLEdit gvalidatePitstopPressureRL
		Gui %window%:Add, Edit, x160 yp w50 h20 Limit4 vpitstopPressureRREdit gvalidatePitstopPressureRR
		Gui %window%:Add, Text, x214 yp+2 w30 h20, % translate("PSI")

		Gui %window%:Add, Text, x24 yp+24 w85 h23 +0x200, % translate("Repairs")
		choices := map(["No Repairs", "Bodywork & Aerodynamics", "Suspension & Chassis", "Engine", "Everything"], "translate")
		Gui %window%:Add, DropDownList, x106 yp w157 AltSubmit Choose1 vpitstopRepairsDropDown, % values2String("|", choices*)

		Gui %window%:Add, Button, x66 ys+279 w160 gplanPitstop, % translate("Instruct Engineer")

		Gui %window%:Add, ListView, x270 ys+34 w331 h269 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HWNDlistHandle gchoosePitstop, % values2String("|", map(["#", "Lap", "Refuel", "Compound", "Set", "Pressures", "Repairs"], "translate")*)

		this.iPitstopsListView := listHandle

		this.iReportViewer := new RaceReportViewer(window, chartViewer)

		this.initializeSession()

		this.updateState()
	}

	showMessage(message, prefix := false) {
		local window := this.Window

		if !prefix
			prefix := translate("Task: ")

		Gui %window%:Default

		GuiControl Text, messageField, % ((message && (message != "")) ? (translate(prefix) . message) : "")
	}

	connect(silent := false) {
		this.pushTask(ObjBindMethod(this, "connectAsync", silent))
	}

	connectAsync(silent) {
		local window := this.Window
		local token, title

		if (!silent && GetKeyState("Ctrl", "P")) {
			Gui TSL:+Owner%window%
			Gui %window%:+Disabled

			try {
				token := loginDialog(this.Connector, this.ServerURL)

				if token {
					serverTokenEdit := token

					Gui %window%:Default

					this.iServerToken := ((serverTokenEdit = "") ? "__INVALID__" : serverTokenEdit)

					GuiControl Text, serverTokenEdit, %serverTokenEdit%
				}
				else
					return
			}
			finally {
				Gui %window%:-Disabled
			}
		}

		window := this.Window

		Gui %window%:Default

		this.iSyncTask.pause()

		try {
			if (!this.ServerToken || (this.ServerToken = ""))
				throw "Invalid token detected..."

			token := this.Connector.Connect(this.ServerURL, this.ServerToken)

			this.iConnected := true

			showMessage(translate("Successfully connected to the Team Server."))

			this.loadTeams()

			this.iSyncTask.resume()
		}
		catch exception {
			this.iServerToken := "__INVALID__"

			GuiControl, , serverTokenEdit, % ""

			if !silent {
				title := translate("Error")

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				MsgBox 262160, %title%, % (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message)
				OnMessage(0x44, "")
			}

			this.loadTeams()
		}
	}

	loadTeams() {
		local window := this.Window
		local teams := (this.Connected ? loadTeams(this.Connector) : {})
		local names := getKeys(teams)
		local identifiers := getValues(teams)
		local chosen

		this.iTeams := teams

		Gui %window%:Default

		GuiControl, , teamDropDownMenu, % ("|" . values2String("|", names*))

		chosen := inList(identifiers, this.SelectedTeam[true])

		if ((chosen == 0) && (names.Length() > 0))
			chosen := 1

		this.selectTeam((chosen == 0) ? false : identifiers[chosen])
	}

	selectTeam(identifier) {
		local window := this.Window
		local chosen, names

		Gui %window%:Default

		chosen := inList(getValues(this.Teams), identifier)

		GuiControl Choose, teamDropDownMenu, % chosen

		names := getKeys(this.Teams)

		if (chosen > 0) {
			this.iTeamName := names[chosen]
			this.iTeamIdentifier := identifier
		}
		else {
			this.iTeamName := ""
			this.iTeamIdentifier := false
		}

		this.loadSessions()
	}

	loadSessions() {
		local window := this.Window
		local teamIdentifier, sessions, names, identifiers, chosen

		Gui %window%:Default

		teamIdentifier := this.SelectedTeam[true]

		sessions := ((this.Connected && teamIdentifier) ? loadSessions(this.Connector, teamIdentifier) : {})

		this.iSessions := sessions

		names := getKeys(sessions)
		identifiers := getValues(sessions)

		GuiControl, , sessionDropDownMenu, % ("|" . values2String("|", names*))

		chosen := inList(identifiers, this.SelectedSession[true])

		if ((chosen == 0) && (names.Length() > 0))
			chosen := 1

		this.selectSession((chosen == 0) ? false : identifiers[chosen])
	}

	loadSessionDrivers() {
		local window := this.Window
		local teamIdentifier, drivers, session, selectedDrivers, ignore, driver, name, names

		Gui %window%:Default

		if this.SessionActive {
			teamIdentifier := this.SelectedTeam[true]

			drivers := ((this.Connected && teamIdentifier) ? loadDrivers(this.Connector, teamIdentifier) : {})

			session := this.SelectedSession[true]
		}
		else {
			drivers := {}

			for ignore, driver in this.Drivers {
				name := computeDriverName(driver.Forname, driver.Surname, driver.Nickname)

				drivers[name] := false
			}
		}

		this.iSessionDrivers := drivers

		names := getKeys(drivers)

		GuiControl, , setupDriverDropDownMenu, % ("|" . values2String("|", names*))
		GuiControl, , planDriverDropDownMenu, % ("|" . values2String("|", translate("-"), names*))
	}

	selectSession(identifier) {
		local window := this.Window
		local chosen, names

		this.iSyncTask.pause()

		Gui %window%:Default

		chosen := inList(getValues(this.Sessions), identifier)

		GuiControl Choose, sessionDropDownMenu, % chosen

		names := getKeys(this.Sessions)

		if (chosen > 0) {
			this.iSessionName := names[chosen]
			this.iSessionIdentifier := identifier
		}
		else {
			this.iSessionName := ""
			this.iSessionIdentifier := false
		}

		this.initializeSession()
		this.loadSessionDrivers()

		this.iSyncTask.resume()
	}

	selectDriver(driver, force := false) {
		local window

		if (force || (this.SelectedDrivers && !inList(this.SelectedDrivers, driver))
				  || (!this.SelectedDrivers && ((driver != true) && (driver != false)))) {
			window := this.Window

			Gui %window%:Default

			if driver {
				GuiControl Choose, driverDropDown, % (((driver = true) || (driver = false)) ? 1 : (inList(this.AvailableDrivers, driver) + 1))

				this.iSelectedDrivers := ((driver == true) ? false : [driver])
			}
			else {
				GuiControl Choose, driverDropDown, 0

				this.iSelectedDrivers := false
			}

			this.updateReports()
		}
	}

	createDriver(driver) {
		local ignore, candidate, found

		if !driver.HasKey("Identifier")
			driver["Identifier"] := false

		if !driver.HasKey("Nr")
			driver["Nr"] := false

		if !driver.HasKey("ID")
			driver["ID"] := false

		for ignore, candidate in this.Drivers {
			found := false

			if (this.SessionActive && (candidate.Identifier == driver.Identifier))
				found := candidate
			else if ((candidate.Forname = driver.Forname) && (candidate.Surname = driver.Surname))
				found := candidate

			if found {
				if driver.ID {
					found.ID := driver.ID

					if !inList(this.iAvailableDrivers, driver.ID)
						this.iAvailableDrivers.Push(driver.ID)

					if this.Simulator
						new SessionDatabase().registerDriver(this.Simulator, driver.ID, found.FullName)
				}

				return found
			}
		}

		driver.FullName := computeDriverName(driver.Forname, driver.Surname, driver.Nickname)
		driver.Laps := []
		driver.Stints := []
		driver.Accidents := 0

		if driver.ID {
			if !inList(this.iAvailableDrivers, driver.ID)
				this.iAvailableDrivers.Push(driver.ID)

			if this.Simulator
				new SessionDatabase().registerDriver(this.Simulator, driver.ID, driver.FullName)
		}

		this.Drivers.Push(driver)

		return driver
	}

	updateState() {
		local window := this.Window
		local currentListView, selected, stint

		Gui %window%:Default

		GuiControlGet pitstopTyreCompoundDropDown

		if (pitstopTyreCompoundDropDown > 1) {
			GuiControl Enable, pitstopTyreSetEdit
			GuiControl Enable, pitstopPressureFLEdit
			GuiControl Enable, pitstopPressureFREdit
			GuiControl Enable, pitstopPressureRLEdit
			GuiControl Enable, pitstopPressureRREdit
		}
		else {
			GuiControl Disable, pitstopTyreSetEdit
			GuiControl Disable, pitstopPressureFLEdit
			GuiControl Disable, pitstopPressureFREdit
			GuiControl Disable, pitstopPressureRLEdit
			GuiControl Disable, pitstopPressureRREdit
		}

		GuiControl Disable, driverDropDown

		GuiControl Disable, dataXDropDown
		GuiControl Disable, dataY1DropDown
		GuiControl Disable, dataY2DropDown
		GuiControl Disable, dataY3DropDown
		GuiControl Disable, dataY4DropDown
		GuiControl Disable, dataY5DropDown
		GuiControl Disable, dataY6DropDown

		if this.HasData {
			if inList(["Drivers", "Positions", "Lap Times", "Consistency", "Pace", "Pressures", "Brakes", "Temperatures", "Free"], this.SelectedReport)
				GuiControl Enable, reportSettingsButton
			else
				GuiControl Disable, reportSettingsButton

			if inList(["Pressures", "Brakes", "Temperatures", "Free"], this.SelectedReport) {
				GuiControl Enable, chartTypeDropDown

				GuiControl Enable, driverDropDown

				GuiControl Enable, dataXDropDown
				GuiControl Enable, dataY1DropDown
				GuiControl Enable, dataY2DropDown
				GuiControl Enable, dataY3DropDown

				if (this.SelectedChartType != "Bubble") {
					GuiControl Enable, dataY4DropDown
					GuiControl Enable, dataY5DropDown
					GuiControl Enable, dataY6DropDown
				}
			}
			else {
				GuiControl Disable, chartTypeDropDown
				GuiControl Choose, chartTypeDropDown, 0

				this.iSelectedChartType := false

				GuiControl Choose, driverDropDown, 0

				GuiControl Choose, dataXDropDown, 0
				GuiControl Choose, dataY1DropDown, 0
				GuiControl Choose, dataY2DropDown, 0
				GuiControl Choose, dataY3DropDown, 0
				GuiControl Choose, dataY4DropDown, 0
				GuiControl Choose, dataY5DropDown, 0
				GuiControl Choose, dataY6DropDown, 0
			}
		}
		else {
			GuiControl Disable, reportSettingsButton

			GuiControl Choose, driverDropDown, 0

			GuiControl Choose, dataXDropDown, 0
			GuiControl Choose, dataY1DropDown, 0
			GuiControl Choose, dataY2DropDown, 0
			GuiControl Choose, dataY3DropDown, 0
			GuiControl Choose, dataY4DropDown, 0
			GuiControl Choose, dataY5DropDown, 0
			GuiControl Choose, dataY6DropDown, 0

			GuiControl Disable, chartTypeDropDown
			GuiControl Choose, chartTypeDropDown, 0

			this.iSelectedChartType := false
		}

		this.updateStrategyMenu()
		this.updatePitstopMenu()

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.SetupsListView

			selected := LV_GetNext(0)

			if (selected != this.SelectedSetup) {
				this.iSelectedSetup := false

				selected := false

				LV_Modify(selected, "-Select")
			}

			if selected {
				GuiControl Enable, setupDriverDropDownMenu
				GuiControl Enable, setupWeatherDropDownMenu
				GuiControl Enable, setupAirTemperatureEdit
				GuiControl Enable, setupTrackTemperatureEdit
				GuiControl Enable, setupCompoundDropDownMenu
				GuiControl Enable, setupBasePressureFLEdit
				GuiControl Enable, setupBasePressureFREdit
				GuiControl Enable, setupBasePressureRLEdit
				GuiControl Enable, setupBasePressureRREdit

				GuiControl Enable, copySetupButton
				GuiControl Enable, deleteSetupButton

				LV_GetText(stint, selected)
			}
			else {
				GuiControl Disable, setupDriverDropDownMenu
				GuiControl Disable, setupWeatherDropDownMenu
				GuiControl Disable, setupAirTemperatureEdit
				GuiControl Disable, setupTrackTemperatureEdit
				GuiControl Disable, setupCompoundDropDownMenu
				GuiControl Disable, setupBasePressureFLEdit
				GuiControl Disable, setupBasePressureFREdit
				GuiControl Disable, setupBasePressureRLEdit
				GuiControl Disable, setupBasePressureRREdit

				GuiControl Disable, copySetupButton
				GuiControl Disable, deleteSetupButton

				GuiControl Choose, setupDriverDropDownMenu, 0
				GuiControl Choose, setupWeatherDropDownMenu, 0
				GuiControl Choose, setupCompoundDropDownMenu, 0
				GuiControl, , setupAirTemperatureEdit, % ""
				GuiControl, , setupTrackTemperatureEdit, % ""
				GuiControl, , setupBasePressureFLEdit, % ""
				GuiControl, , setupBasePressureFREdit, % ""
				GuiControl, , setupBasePressureRLEdit, % ""
				GuiControl, , setupBasePressureRREdit, % ""
			}

			Gui ListView, % this.PlanListView

			selected := LV_GetNext(0)

			if (selected != this.SelectedPlanStint) {
				this.iSelectedPlanStint := false

				selected := false

				LV_Modify(selected, "-Select")
			}

			if selected {
				GuiControl Enable, planDriverDropDownMenu
				GuiControl Enable, planTimeEdit
				GuiControl Enable, actTimeEdit
				GuiControl Enable, deletePlanButton

				LV_GetText(stint, selected)

				if (stint = 1) {
					GuiControl Disable, planLapEdit
					GuiControl Disable, actLapEdit
					GuiControl Disable, planRefuelEdit
					GuiControl Disable, planTyreCompoundDropDown

					GuiControl, , planLapEdit, % ""
					GuiControl, , actLapEdit, % ""
					GuiControl, , planRefuelEdit, % ""
					GuiControl Choose, planTyreCompoundDropDown, 0
				}
				else {
					GuiControl Enable, planLapEdit
					GuiControl Enable, actLapEdit
					GuiControl Enable, planRefuelEdit
					GuiControl Enable, planTyreCompoundDropDown
				}
			}
			else {
				GuiControl Disable, planDriverDropDownMenu
				GuiControl Disable, planTimeEdit
				GuiControl Disable, actTimeEdit
				GuiControl Disable, planLapEdit
				GuiControl Disable, actLapEdit
				GuiControl Disable, planRefuelEdit
				GuiControl Disable, planTyreCompoundDropDown
				GuiControl Disable, deletePlanButton

				GuiControl Choose, planDriverDropDownMenu, 0
				GuiControl, , planTimeEdit, 20200101000000
				GuiControl, , actTimeEdit, 20200101000000
				GuiControl, , planLapEdit, % ""
				GuiControl, , actLapEdit, % ""
				GuiControl, , planRefuelEdit, % ""
				GuiControl Choose, planTyreCompoundDropDown, 0
			}

			if this.UseTraffic {
				GuiControl Enable, numScenariosEdit
				GuiControl Enable, variationWindowEdit

				GuiControl Enable, lapTimeVariationDropDown
				GuiControl Enable, driverErrorsDropDown
				GuiControl Enable, pitstopsDropDown
				GuiControl Enable, overtakeDeltaEdit
				GuiControl Enable, trafficConsideredEdit
			}
			else {
				GuiControl Disable, numScenariosEdit
				GuiControl Disable, variationWindowEdit

				GuiControl Disable, lapTimeVariationDropDown
				GuiControl Disable, driverErrorsDropDown
				GuiControl Disable, pitstopsDropDown
				GuiControl Disable, overtakeDeltaEdit
				GuiControl Disable, trafficConsideredEdit
			}
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	updateStrategyMenu() {
		local window := this.Window
		local use1, use2, use3, use4

		Gui %window%:Default

		use1 := (this.UseSessionData ? "(x) Use Session Data" : "      Use Session Data")
		use2 := (this.UseTelemetryDatabase ? "(x) Use Telemetry Database" : "      Use Telemetry Database")
		use3 := (this.UseCurrentMap ? "(x) Keep current Map" : "      Keep current Map")
		use4 := (this.UseTraffic ? "(x) Analyze Traffic" : "      Analyze Traffic")

		GuiControl, , strategyMenuDropDown, % "|" . values2String("|", map(["Strategy", "---------------------------------------------", "Load current Race Strategy", "Load Strategy...", "Save Strategy...", "---------------------------------------------", "Strategy Summary", "---------------------------------------------", use1, use2, use3, use4, "---------------------------------------------", "Adjust Strategy (Simulation)", "---------------------------------------------", "Discard Strategy", "---------------------------------------------", "Instruct Strategist"], "translate")*)

		GuiControl Choose, strategyMenuDropDown, 1

		GuiControl Choose, useSessionDataDropDown, % (this.UseSessionData ? 1 : 2)
		GuiControl Choose, useTelemetryDataDropDown, % (this.UseTelemetryDatabase ? 1 : 2)
		GuiControl Choose, keepMapDropDown, % (this.UseCurrentMap ? 1 : 2)
		GuiControl Choose, considerTrafficDropDown, % (this.UseTraffic ? 1 : 2)
	}

	updatePitstopMenu() {
		local window := this.Window
		local correct1, correct2

		Gui %window%:Default

		correct1 := ((this.TyrePressureMode = "Reference") ? "(x) Adjust Pressures (Reference)" : "      Adjust Pressures (Reference)")
		correct2 := ((this.TyrePressureMode = "Relative") ? "(x) Adjust Pressures (Relative)" : "      Adjust Pressures (Relative)")

		GuiControl, , pitstopMenuDropDown, % "|" . values2String("|", map(["Pitstop", "---------------------------------------------", "Select Team...", "---------------------------------------------", "Initialize from Session", "Load from Database...", "Clear Setups...", "---------------------------------------------", "Setups Summary", "Pitstops Summary", "---------------------------------------------", correct1, correct2, "---------------------------------------------", "Instruct Engineer"], "translate")*)

		GuiControl Choose, pitstopMenuDropDown, 1
	}

	addSetup() {
		local window := this.Window
		local currentListView

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.SetupsListView

			if (this.SessionDrivers.Count() > 0) {
				GuiControl Choose, setupDriverDropDownMenu, 1

				setupAirTemperatureEdit := 23
				setupTrackTemperatureEdit := 27

				setupBasePressureFLEdit := 25.5
				setupBasePressureFREdit := 25.5
				setupBasePressureRLEdit := 25.5
				setupBasePressureRREdit := 25.5

				GuiControl Choose, setupWeatherDropDownMenu, % inList(kWeatherConditions, "Dry")
				GuiControl, , setupAirTemperatureEdit, %setupAirTemperatureEdit%
				GuiControl, , setupTrackTemperatureEdit, %setupTrackTemperatureEdit%
				GuiControl Choose, setupCompoundDropDownMenu, 1

				GuiControl, , setupBasePressureFLEdit, %setupBasePressureFLEdit%
				GuiControl, , setupBasePressureFREdit, %setupBasePressureFREdit%
				GuiControl, , setupBasePressureRLEdit, %setupBasePressureRLEdit%
				GuiControl, , setupBasePressureRREdit, %setupBasePressureRREdit%

				LV_Add("Select Vis", getKeys(this.SessionDrivers)[1]
								   , translate("Dry") . A_Space . translate("(") . setupAirTemperatureEdit . ", " . setupTrackTemperatureEdit . translate(")")
								   , translate("Dry")
								   , values2String(", ", setupBasePressureFLEdit, setupBasePressureFREdit, setupBasePressureRLEdit, setupBasePressureRREdit))

				this.iSelectedSetup := LV_GetCount()

				LV_ModifyCol()

				loop % LV_GetCount("Col")
					LV_ModifyCol(A_Index, "AutoHdr")

				if (this.SelectedDetailReport = "Setups")
					this.showSetupsDetails()
			}

			this.updateState()
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	copySetup() {
		local window := this.Window
		local driver, conditions, compound, pressures
		local currentListView, row

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.SetupsListView

			row := LV_GetNext(0)

			if row {
				LV_GetText(driver, row, 1)
				LV_GetText(conditions, row, 2)
				LV_GetText(compound, row, 3)
				LV_GetText(pressures, row, 4)

				LV_Add("Select Vis", driver, conditions, compound, pressures)

				this.iSelectedSetup := LV_GetCount()

				LV_ModifyCol()

				loop % LV_GetCount("Col")
					LV_ModifyCol(A_Index, "AutoHdr")

				if (this.SelectedDetailReport = "Setups")
					this.showSetupsDetails()
			}

			this.updateState()
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	deleteSetup() {
		local window := this.Window
		local currentListView, selected

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.SetupsListView

			selected := LV_GetNext(0)

			if (selected != this.SelectedSetup) {
				loop % LV_GetCount()
					LV_Modify(A_Index, "-Select")

				this.iSelectedSetup := false

				selected := false
			}

			if selected
				LV_Delete(selected)

			if (this.SelectedDetailReport = "Setups")
				this.showSetupsDetails()

			this.updateState()
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	clearSetups(verbose := true) {
		local window := this.Window
		local currentListView, delete, title

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.SetupsListView

			if (LV_GetCount() > 0) {
				delete := false

				if verbose {
					title := translate("Delete")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
					MsgBox 262436, %title%, % translate("Do you really want to delete all driver specific setups?")
					OnMessage(0x44, "")

					IfMsgBox Yes
						delete := true
				}
				else
					delete := true

				if delete {
					this.iSetupsVersion := (A_Now . "")

					LV_Delete()

					this.iSelectedSetup := false

					if (this.SelectedDetailReport = "Setups")
						this.showSetupsDetails()

					this.updateState()
				}
			}
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	releaseSetups(verbose := true) {
		local session, version, info, fileName, setups, title

		if this.SessionActive
			try {
				session := this.SelectedSession[true]

				version := (A_Now . "")

				this.iSetupsVersion := version

				info := newConfiguration()

				setConfigurationValue(info, "Setups", "Version", version)

				this.saveSetups(true)

				fileName := (this.SessionDirectory . "Setups.Data.CSV")

				if FileExist(fileName)
					FileRead setups, %fileName%
				else
					setups := "CLEAR"

				this.Connector.setSessionValue(session, "Setups Info", printConfiguration(info))
				this.Connector.setSessionValue(session, "Setups", setups)
				this.Connector.setSessionValue(session, "Setups Version", version)

				if verbose
					showMessage(translate("Setups has been saved for this Session."))
			}
			catch exception {
				logError(exception)
			}
		else if verbose {
			title := translate("Information")

			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262192, %title%, % translate("You are not connected to an active session.")
			OnMessage(0x44, "")
		}
	}

	getPlanDrivers() {
		local window := this.Window
		local drivers := {}
		local currentListView, stint, driver

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PlanListView

			loop % LV_GetCount()
			{
				LV_GetText(stint, A_Index, 1)
				LV_GetText(driver, A_Index, 2)

				drivers[stint + 0] := driver
			}
		}
		finally {
			Gui ListView, %currentListView%
		}

		return drivers
	}

	loadPlanFromStrategy() {
		local window, currentListView, pitstops, pitstop, numStints, title, time, currentTime, last, lastTime
		local driver, forName, surName, nickName, found, ignore, candidate
		local sForName, sSurName, sNickName

		if this.Strategy {
			window := this.Window

			Gui %window%:Default

			currentListView := A_DefaultListView

			try {
				Gui ListView, % this.PlanListView

				loop % LV_GetCount()
					LV_Modify(A_Index, "-Select")

				this.iSelectedPlanStint := false

				pitstops := this.Strategy.Pitstops

				numStints := (pitstops.Length() + 1)

				if (numStints < LV_GetCount()) {
					title := translate("Plan")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Beginning", "End", "Cancel"]))
					MsgBox 262179, %title%, % translate("The plan has more stints than the strategy. Do you want to remove surplus stints from the beginning or from the end of the plan?")
					OnMessage(0x44, "")

					IfMsgBox Cancel
						return

					IfMsgBox Yes
					{
						while (LV_GetCount() > numStints)
							LV_Delete(1)

						if (LV_GetCount() > 0)
							LV_Modify(1, "Col5", "-", "-", "-", "-")
					}

					IfMsgBox No
						while (LV_GetCount() > numStints)
							LV_Delete(LV_GetCount())
				}

				if (LV_GetCount() < numStints) {
					if (LV_GetCount() > 0) {
						title := translate("Information")

						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						MsgBox 262192, %title%, % translate("The plan has less stints than the strategy. Additional stints will be added at the end of the plan.")
						OnMessage(0x44, "")
					}

					while (LV_GetCount() < numStints) {
						if (LV_GetCount() == 0)
							last := 0
						else
							LV_GetText(last, LV_GetCount())

						time := this.Time

						FormatTime time, %time%, HH:mm

						if (last = 0)
							LV_Add("", 1, "", time, "", "-", "-", "-", "-")
						else
							LV_Add("", last + 1, "", time, "", "", "", "", "")
					}
				}

				if (LV_GetCount() > 0) {
					LV_GetText(time, 1, 3)

					time := string2Values(":", time)

					currentTime := "20200101000000"

					if (time.Length() = 2) {
						EnvAdd currentTime, time[1], Hours
						EnvAdd currentTime, time[2], Minutes
					}
				}

				lastTime := 0

				loop % LV_GetCount()
				{
					driver := ((A_Index = 1) ? this.Strategy.DriverName : pitstops[A_Index -1].DriverName)

					forName := false
					surName := false
					nickName := false

					parseDriverName(driver, forName, surName, nickName)

					found := false

					for ignore, candidate in getKeys(this.SessionDrivers) {
						sForName := false
						sSurName := false
						sNickName := false

						parseDriverName(candidate, sForName, sSurName, sNickName)

						if ((sForName = forName) && (sSurName = surName)) {
							found := true
							driver := candidate

							break
						}
					}

					if !found
						driver := "-"

					LV_Modify(A_Index, "Col2", driver)

					if (A_Index > 1) {
						pitstop := pitstops[A_Index - 1]

						time := pitstop.Time
						time -= lastTime

						lastTime := pitstop.Time

						EnvAdd currentTime, time, Seconds
						FormatTime time, %currentTime%, HH:mm

						LV_Modify(A_Index, "Col3", time)
						LV_Modify(A_Index, "Col5", pitstop.Lap)
						LV_Modify(A_Index, "Col7", (pitstop.RefuelAmount == 0) ? "-" : pitstop.RefuelAmount)
						LV_Modify(A_Index, "Col8", pitstop.TyreChange ? "x" : "")
					}
				}

				LV_ModifyCol()

				loop 8
					LV_ModifyCol(A_Index, "AutoHdr")

				if (this.SelectedDetailReport = "Plan")
					this.showPlanDetails()

				this.updateState()
			}
			finally {
				Gui ListView, %currentListView%
			}
		}
	}

	clearPlan(verbose := true) {
		local window := this.Window
		local currentListView, delete, title

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PlanListView

			if (LV_GetCount() > 0) {
				delete := false

				if verbose {
					title := translate("Delete")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
					MsgBox 262436, %title%, % translate("Do you really want to delete the current plan?")
					OnMessage(0x44, "")

					IfMsgBox Yes
						delete := true
				}
				else
					delete := true

				if delete {
					this.iPlanVersion := (A_Now . "")

					LV_Delete()

					this.iSelectedPlanStint := false

					if (this.SelectedDetailReport = "Plan")
						this.showPlanDetails()

					this.updateState()
				}
			}
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	updatePlan(minutesOrStint) {
		local window := this.Window
		local currentListView, time, stintNr

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PlanListView

			loop % LV_GetCount()
				LV_Modify(A_Index, "-Select")

			this.iSelectedPlanStint := false

			if IsObject(minutesOrStint) {
				if (LV_GetCount() > 0) {
					time := this.computeStartTime(minutesOrStint)

					FormatTime time, %time%, HH:mm

					loop % LV_GetCount()
					{
						LV_GetText(stintNr, A_Index)

						if (stintNr = minutesOrStint.Nr) {
							LV_Modify(A_Index, "Col2", minutesOrStint.Driver.FullName)
							LV_Modify(A_Index, "Col4", time)

							if (stintNr != 1)
								LV_Modify(A_Index, "Col6", minutesOrStint.Lap)
						}
					}
				}
			}
			else
				loop % LV_GetCount()
				{
					LV_GetText(time, A_Index, 3)

					time := string2Values(":", time)
					time := ("20200101" . time[1] . time[2] . "00")

					EnvAdd time, %minutesOrStint%, Minutes
					FormatTime time, %time%, HH:mm

					LV_Modify(A_Index, "Col3", time)
				}

			if (this.SelectedDetailReport = "Plan")
				this.showPlanDetails()

			this.updateState()
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	addPlan(position := "After") {
		local window := this.Window
		local currentListView, selected, stintNr, initial

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PlanListView

			selected := LV_GetNext(0)

			if (selected != this.SelectedPlanStint) {
				loop % LV_GetCount()
					LV_Modify(A_Index, "-Select")

				this.iSelectedPlanStint := false

				selected := false
			}

			if selected {
				position := ((position = "After") ? selected + 1 : selected)

				if (position > LV_GetCount())
					position := false
			}
			else
				position := false

			if position
				LV_GetText(stintNr, position)
			else {
				if (LV_GetCount() > 0) {
					LV_GetText(stintNr, LV_GetCount())

					stintNr += 1
				}
				else
					stintNr := 1
			}

			initial := ((stintNr = 1) ? "-" : "")

			if position {
				LV_Insert(position, "Select Vis", stintNr, "", "", "", initial, initial, initial, initial)

				this.iSelectedPlanStint := position
			}
			else {
				LV_Add("Select Vis", stintNr, "", "", "", initial, initial, initial, initial)

				this.iSelectedPlanStint := LV_GetCount()
			}

			GuiControl Choose, planDriverDropDownMenu, 1
			GuiControl, , planTimeEdit, 20200101000000
			GuiControl, , actTimeEdit, 20200101000000
			GuiControl, , planLapEdit, % ""
			GuiControl, , actLapEdit, % ""
			GuiControl, , planRefuelEdit, 0
			GuiControl Choose, planTyreCompoundDropDown, 2

			LV_GetText(stintNr, 1)

			loop % LV_GetCount()
				LV_Modify(A_Index, "", stintNr++)

			if (this.SelectedDetailReport = "Plan")
				this.showPlanDetails()

			this.updateState()
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	deletePlan() {
		local window := this.Window
		local currentListView, selected, stintNr

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PlanListView

			selected := LV_GetNext(0)

			if (selected != this.SelectedPlanStint) {
				loop % LV_GetCount()
					LV_Modify(A_Index, "-Select")

				this.iSelectedPlanStint := false

				selected := false
			}

			if selected {
				LV_Delete(selected)

				if (selected <= LV_GetCount()) {
					LV_GetText(stintNr, 1)

					loop % LV_GetCount()
						LV_Modify(A_Index, "", stintNr++)
				}
			}

			if (this.SelectedDetailReport = "Plan")
				this.showPlanDetails()

			this.updateState()
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	releasePlan(verbose := true) {
		local session, version, info, fileName, plan, title

		if this.SessionActive
			try {
				session := this.SelectedSession[true]

				version := (A_Now . "")

				this.iPlanVersion := version

				info := newConfiguration()

				setConfigurationValue(info, "Plan", "Version", version)
				setConfigurationValue(info, "Plan", "Date", this.Date)
				setConfigurationValue(info, "Plan", "Time", this.Time)

				this.savePlan(true)

				fileName := (this.SessionDirectory . "Plan.Data.CSV")

				if FileExist(fileName)
					FileRead plan, %fileName%
				else
					plan := "CLEAR"

				this.Connector.setSessionValue(session, "Stint Plan Info", printConfiguration(info))
				this.Connector.setSessionValue(session, "Stint Plan", plan)
				this.Connector.setSessionValue(session, "Stint Plan Version", version)

				if verbose
					showMessage(translate("Plan has been saved for this Session."))
			}
			catch exception {
				logError(exception)
			}
		else if verbose {
			title := translate("Information")

			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262192, %title%, % translate("You are not connected to an active session.")
			OnMessage(0x44, "")
		}
	}

	initializePitstopSettings(ByRef lap, ByRef refuel, ByRef compound, ByRef compoundColor) {
		local window := this.Window
		local currentListView, currentStint, nextStint, plannedLap, lastLap, refuelAmount, tyreChange, index, pitstop
		local stint

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PlanListView

			currentStint := this.CurrentStint

			if currentStint {
				nextStint := (currentStint.Nr + 1)

				loop % LV_GetCount()
				{
					LV_GetText(stint, A_Index)

					if (stint = nextStint) {
						LV_GetText(plannedLap, A_Index, 5)
						LV_GetText(refuelAmount, A_Index, 7)
						LV_GetText(tyreChange, A_Index, 8)

						lap := plannedLap
						refuel := refuelAmount

						if (tyreChange != "x") {
							compound := false
							compoundColor := false
						}

						return
					}
				}

				if this.Strategy
					for index, pitstop in this.Strategy.Pitstops
						if (pitstop.ID = currentStint.Nr) {
							lap := pitstop.Lap
							refuel := pitstop.RefuelAmount

							if !pitstop.TyreChange {
								compound := false
								compoundColor := false
							}

							return
						}

				lastLap := this.LastLap

				if lastLap {
					lap := (lastLap.Nr + 2)
					refuel := Round(this.CurrentStint.FuelConsumption + (lastLap.FuelConsumption * 2))
				}
			}
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	initializePitstopFromSession() {
		local stint := this.CurrentStint
		local window, drivers, index, pressuresDB, pressuresTable, last, pressures
		local lap, refuel, compound, compoundColor

		if stint {
			drivers := this.getPlanDrivers()

			if (drivers.HasKey(stint.Nr + 1)) {
				index := inList(this.TeamDrivers, drivers[stint.Nr + 1])

				if index
					GuiControl Choose, pitstopDriverDropDownMenu, %index%
			}
		}

		pressuresDB := this.PressuresDatabase

		if pressuresDB {
			pressuresTable := pressuresDB.Database.Tables["Tyres.Pressures"]

			last := pressuresTable.Length()

			if (last > 0) {
				pressures := pressuresTable[last]

				lap := 0
				refuel := 0
				compound := pressures["Compound"]
				compoundColor := pressures["Compound.Color"]

				this.initializePitstopSettings(lap, refuel, compound, compoundColor)

				window := this.Window

				Gui %window%:Default

				GuiControl, , pitstopLapEdit, %lap%
				GuiControl, , pitstopRefuelEdit, %refuel%

				this.initializePitstopTyreSetup(compound, compoundColor
											  , displayValue(pressures["Tyre.Pressure.Cold.Front.Left"]), displayValue(pressures["Tyre.Pressure.Cold.Front.Right"])
											  , displayValue(pressures["Tyre.Pressure.Cold.Rear.Left"]), displayValue(pressures["Tyre.Pressure.Cold.Rear.Right"]))
			}
		}
	}

	getDriver(stintNr) {
		local window := this.Window
		local currentListView, stint, driver, ignore, candidate, forName, surName, nickName

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PlanListView

			loop % LV_GetCount()
			{
				LV_GetText(stint, A_Index, 1)

				if (stint = stintNr) {
					LV_GetText(driver, A_Index, 2)

					for ignore, candidate in getKeys(this.SessionDrivers)
						if (driver = candidate) {
							forName := ""
							surName := ""
							nickName := ""

							parseDriverName(candidate, forName, surName, nickName)

							return this.createDriver({Forname: forName, Surname: surName, Nickname: nickName, Identifier: this.SessionDrivers[candidate]})
						}
				}
			}
		}
		finally {
			Gui ListView, %currentListView%
		}

		return false
	}

	driverSetup(driver, weather, airTemperature, trackTemperature, compound, compoundColor) {
		local setup := false
		local weatherIndex := inList(kWeatherConditions, weather)
		local ignore, candidate, sWeatherIndex, cWeatherIndex

		this.saveSetups()

		for ignore, candidate in this.SessionStore.query("Setups.Data", {Where: {Driver: driver.FullName
																			   , "Tyre.Compound": compound
																			   , "Tyre.Compound.Color": compoundColor}})
			if setup {
				sWeatherIndex := inList(kWeatherConditions, setup.Weather)
				cWeatherIndex := inList(kWeatherConditions, candidate.Weather)

				if (Abs(weatherIndex - cWeatherIndex) < Abs(weatherIndex - sWeatherIndex))
					setup := candidate
				else if ((Abs(candidate["Temperature.Air"] - airTemperature) < Abs(setup["Temperature.Air"] - airTemperature))
					  || (Abs(candidate["Temperature.Track"] - trackTemperature) < Abs(setup["Temperature.Track"] - trackTemperature)))
					setup := candidate
			}
			else
				setup := candidate

		return setup
	}

	driverSetups(driver, weather, compound, compoundColor) {
		this.saveSetups()

		return this.SessionStore.query("Setups.Data", {Where: {Driver: driver.FullName, Weather: weather
															 , "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor}})
	}

	driverPressureCurve(driver, setups, tyreType, ByRef a, ByRef b) {
		local xValues := []
		local yValues := []
		local ignore, setup

		for ignore, setup in setups {
			xValues.Push(setup["Temperature.Air"])
			yValues.Push(setup["Tyre.Pressure." . tyreType])
		}

		linRegression(xValues, yValues, a, b)
	}

	driverReferencePressure(driver, weather, airTemperature, trackTemperature, compound, compoundColor
						  , ByRef pressureFL, ByRef pressureFR, ByRef pressureRL, ByRef pressureRR) {
		local setup := this.driverSetup(driver, weather, airTemperature, trackTemperature, compound, compoundColor)
		local variable, setups, index, tyreType, a, b, tempFL, tempFR, tempRL, tempRR
		local settings, correctionAir, correctionTrack, delta

		if setup {
			setups := this.driverSetups(driver, setup.Weather, setup["Tyre.Compound"], setup["Tyre.Compound.Color"])

			if (setups.Length() > 1) {
				for index, tyreType in ["Front.Left", "Front.Right", "Rear.Left", "Rear.Right"] {
					a := false
					b := false

					this.driverPressureCurve(driver, setups, tyreType, a, b)

					variable := ["tempFL", "tempFR", "tempRL", "tempRR"][index]

					%variable% := (a + (b * airTemperature))
				}

				pressureFL := tempFL
				pressureFR := tempFR
				pressureRL := tempRL
				pressureRR := tempRR

				return true
			}
			else {
				settings := new SettingsDatabase().loadSettings(this.Simulator, this.Car, this.Track, weather)

				correctionAir := getConfigurationValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Air", -0.1)
				correctionTrack := getConfigurationValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Track", -0.02)

				delta := (((airTemperature - setup["Temperature.Air"]) * correctionAir) + ((trackTemperature - setup["Temperature.Track"]) * correctionTrack))

				pressureFL := (setup["Tyre.Pressure.Front.Left"] + delta)
				pressureFR := (setup["Tyre.Pressure.Front.Right"] + delta)
				pressureRL := (setup["Tyre.Pressure.Rear.Left"] + delta)
				pressureRR := (setup["Tyre.Pressure.Rear.Right"] + delta)

				return true
			}
		}
		else
			return false
	}

	driverPressureDelta(currentDriver, nextDriver, weather, airTemperature, trackTemperature, compound, compoundColor
					  , ByRef deltaFL, ByRef deltaFR, ByRef deltaRL, ByRef deltaRR) {
		local currentDriverSetup, nextDriverSetup
		local currentBasePressureFL, currentBasePressureFR, currentBasePressureRL, currentBasePressureRR
		local nextBasePressureFL, nextBasePressureFR, nextBasePressureRL, nextBasePressureRR

		if (currentDriver = nextDriver) {
			deltaFL := 0
			deltaFR := 0
			deltaRL := 0
			deltaRR := 0

			return true
		}
		else {
			currentDriverSetup := this.driverSetup(currentDriver, weather, airTemperature, trackTemperature, compound, compoundColor)
			nextDriverSetup := this.driverSetup(nextDriver, weather, airTemperature, trackTemperature, compound, compoundColor)

			if (currentDriverSetup && nextDriverSetup) {
				currentBasePressureFL := false
				currentBasePressureFR := false
				currentBasePressureRL := false
				currentBasePressureRR := false

				nextBasePressureFL := false
				nextBasePressureFR := false
				nextBasePressureRL := false
				nextBasePressureRR := false

				this.driverReferencePressure(currentDriver, weather, airTemperature, trackTemperature, compound, compoundColor
										   , currentBasePressureFL, currentBasePressureFR, currentBasePressureRL, currentBasePressureRR)

				this.driverReferencePressure(nextDriver, weather, airTemperature, trackTemperature, compound, compoundColor
										   , nextBasePressureFL, nextBasePressureFR, nextBasePressureRL, nextBasePressureRR)

				/*
				settings := new SettingsDatabase().loadSettings(this.Simulator, this.Car, this.Track, weather)

				correctionAir := getConfigurationValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Air", -0.1)
				correctionTrack := getConfigurationValue(settings, "Session Settings", "Tyre.Pressure.Correction.Temperature.Track", -0.02)

				currentDelta := (((airTemperature - currentDriverSetup["Temperature.Air"]) * correctionAir)
							   + ((trackTemperature - currentDriverSetup["Temperature.Track"]) * correctionTrack))

				currentBasePressureFL := (currentDriverSetup["Tyre.Pressure.Front.Left"] + currentDelta)
				currentBasePressureFR := (currentDriverSetup["Tyre.Pressure.Front.Right"] + currentDelta)
				currentBasePressureRL := (currentDriverSetup["Tyre.Pressure.Rear.Left"] + currentDelta)
				currentBasePressureRR := (currentDriverSetup["Tyre.Pressure.Rear.Right"] + currentDelta)

				nextDelta := (((airTemperature - nextDriverSetup["Temperature.Air"]) * correctionAir)
							+ ((trackTemperature - nextDriverSetup["Temperature.Track"]) * correctionTrack))

				nextBasePressureFL := (nextDriverSetup["Tyre.Pressure.Front.Left"] + nextDelta)
				nextBasePressureFR := (nextDriverSetup["Tyre.Pressure.Front.Right"] + nextDelta)
				nextBasePressureRL := (nextDriverSetup["Tyre.Pressure.Rear.Left"] + nextDelta)
				nextBasePressureRR := (nextDriverSetup["Tyre.Pressure.Rear.Right"] + nextDelta)
				*/

				deltaFL := (nextBasePressureFL - currentBasePressureFL)
				deltaFR := (nextBasePressureFR - currentBasePressureFR)
				deltaRL := (nextBasePressureRL - currentBasePressureRL)
				deltaRR := (nextBasePressureRR - currentBasePressureRR)

				return true
			}
			else
				return false
		}
	}

	adjustPitstopTyrePressures(tyrePressureMode, weather, airTemperature, trackTemperature, compound, compoundColor
							 , ByRef flPressure, ByRef frPressure, ByRef rlPressure, ByRef rrPressure) {
		local currentDriver := (this.CurrentStint ? this.CurrentStint.Driver : false)
		local nextDriver := (this.CurrentStint ? this.getDriver(this.CurrentStint.Nr + 1) : false)
		local pressureFL, pressureFR, pressureRL, pressureRR, deltaFL, deltaFR, deltaRL, deltaRR

		if (currentDriver && nextDriver) {
			if (tyrePressureMode = "Reference") {
				pressureFL := false
				pressureFR := false
				pressureRL := false
				pressureRR := false

				if this.driverReferencePressure(nextDriver, weather, airTemperature, trackTemperature, compound, compoundColor
											  , pressureFL, pressureFR, pressureRL, pressureRR) {
					flPressure := pressureFL
					frPressure := pressureFR
					rlPressure := pressureRL
					rrPressure := pressureRR
				}
			}
			else if (tyrePressureMode = "Relative") {
				deltaFL := false
				deltaFR := false
				deltaRL := false
				deltaRR := false

				if this.driverPressureDelta(currentDriver, nextDriver, weather, airTemperature, trackTemperature, compound, compoundColor
										  , deltaFL, deltaFR, deltaRL, deltaRR) {
					flPressure += deltaFL
					frPressure += deltaFR
					rlPressure += deltaRL
					rrPressure += deltaRR
				}
			}
			else
				throw "Unknown tyre pressure mode detected in RaceCenter.adjustPitstopTyrePressures..."
		}
	}

	initializePitstopTyreSetup(compound, compoundColor, flPressure, frPressure, rlPressure, rrPressure) {
		local window := this.Window
		local chosen

		Gui %window%:Default

		if compound {
			if (compoundColor != "Black")
				compound := compound(compound, compoundColor)

			if this.TyrePressureMode
				this.adjustPitstopTyrePressures(this.TyrePressureMode, this.Weather, this.AirTemperature, this.TrackTemperature
											  , compound, compoundColor, flPressure, frPressure, rlPressure, rrPressure)

			chosen := inList(concatenate(["No Tyre Change"], this.TyreCompounds), compound)

			GuiControl Choose, pitstopTyreCompoundDropDown, % ((chosen == 0) ? 1 : chosen)

			GuiControl, , pitstopPressureFLEdit, % Round(flPressure, 1)
			GuiControl, , pitstopPressureFREdit, % Round(frPressure, 1)
			GuiControl, , pitstopPressureRLEdit, % Round(rlPressure, 1)
			GuiControl, , pitstopPressureRREdit, % Round(rrPressure, 1)
		}
		else {
			GuiControl Choose, pitstopTyreCompoundDropDown, 1

			GuiControl, , pitstopPressureFLEdit, % ""
			GuiControl, , pitstopPressureFREdit, % ""
			GuiControl, , pitstopPressureRLEdit, % ""
			GuiControl, , pitstopPressureRREdit, % ""
		}

		this.updateState()
	}

	updateStrategy() {
		local strategy, session, lap

		if (this.Strategy && this.SessionActive)
			try {
				this.Strategy.setVersion(A_Now)

				strategy := newConfiguration()

				this.Strategy.saveToConfiguration(strategy)

				strategy := printConfiguration(strategy)

				session := this.SelectedSession[true]

				this.Connector.SetSessionValue(session, "Race Strategy", strategy)
				this.Connector.SetSessionValue(session, "Race Strategy Version", this.Strategy.Version)

				lap := this.Connector.GetSessionLastLap(session)

				this.Connector.SetLapValue(lap, "Race Strategy", strategy)
				this.Connector.SetLapValue(lap, "Strategy Update", strategy)
				this.Connector.SetSessionValue(session, "Strategy Update", lap)

				showMessage(translate("Race Strategist will be instructed as fast as possible."))
			}
			catch exception {
				showMessage(translate("Session has not been started yet."))
			}
	}

	discardStrategy() {
		local session, lap

		this.selectStrategy(false)

		if this.SessionActive
			try {
				session := this.SelectedSession[true]

				this.Connector.SetSessionValue(session, "Race Strategy", "CANCEL")
				this.Connector.SetSessionValue(session, "Race Strategy Version", A_Now . "")

				lap := this.Connector.GetSessionLastLap(session)

				this.Connector.SetLapValue(lap, "Strategy Update", "CANCEL")
				this.Connector.SetSessionValue(session, "Strategy Update", lap)

				showMessage(translate("Race Strategist will be instructed as fast as possible."))
			}
			catch exception {
				showMessage(translate("Session has not been started yet."))
			}
	}

	planPitstop() {
		local window, pitstopPlan, stint, drivers, currentDriver, nextDriver, currentNr, nextNr, session, lap, title
		local compound, compoundColor

		if this.SessionActive {
			window := this.Window

			Gui %window%:Default

			GuiControlGet pitstopLapEdit
			GuiControlGet pitstopDriverDropDownMenu
			GuiControlGet pitstopRefuelEdit
			GuiControlGet pitstopTyreCompoundDropDown
			GuiControlGet pitstopTyreSetEdit
			GuiControlGet pitstopPressureFLEdit
			GuiControlGet pitstopPressureFREdit
			GuiControlGet pitstopPressureRLEdit
			GuiControlGet pitstopPressureRREdit
			GuiControlGet pitstopRepairsDropDown

			pitstopPlan := newConfiguration()

			if ((pitstopPlanEdit = "") || (pitstopPlanEdit = 0))
				pitstopPlanEdit := (this.LastLap ? this.LastLap.Nr : 1)

			if (pitstopRefuelEdit = "")
				pitstopRefuelEdit := 0

			if (pitstopTyreSetEdit = "")
				pitstopTyreSetEdit := 0

			setConfigurationValue(pitstopPlan, "Pitstop", "Lap", pitstopLapEdit)
			setConfigurationValue(pitstopPlan, "Pitstop", "Refuel", pitstopRefuelEdit)

			stint := this.CurrentStint

			if (stint && pitstopDriverDropDownMenu && (pitstopDriverDropDownMenu != "")) {
				drivers := this.getPlanDrivers()

				if (drivers.HasKey(stint.Nr)) {
					currentDriver := drivers[stint.Nr]
					nextDriver := pitstopDriverDropDownMenu

					currentNr := inList(this.TeamDrivers, currentDriver)
					nextNr := inList(this.TeamDrivers, nextDriver)

					if (currentNr && nextNr)
						setConfigurationValue(pitstopPlan, "Pitstop", "Driver", currentDriver . ":" . currentNr . "|" . nextDriver . ":" . nextNr)
				}
			}

			if (pitstopTyreCompoundDropDown > 1) {
				setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Change", true)

				setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Set", pitstopTyreSetEdit)

				splitCompound(this.TyreCompounds[pitstopTyreCompoundDropDown - 1], compound, compoundColor)

				setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Compound", compound)
				setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Compound.Color", compoundColor)

				setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Pressures"
									, values2String(",", pitstopPressureFLEdit, pitstopPressureFREdit
													   , pitstopPressureRLEdit, pitstopPressureRREdit))
			}
			else
				setConfigurationValue(pitstopPlan, "Pitstop", "Tyre.Change", false)

			setConfigurationValue(pitstopPlan, "Pitstop", "Repair.Bodywork"
								, ((pitstopRepairsDropDown = 2) || (pitstopRepairsDropDown = 5)))

			setConfigurationValue(pitstopPlan, "Pitstop", "Repair.Suspension"
								, ((pitstopRepairsDropDown = 3) || (pitstopRepairsDropDown = 5)))

			setConfigurationValue(pitstopPlan, "Pitstop", "Repair.Engine"
								, ((pitstopRepairsDropDown = 4) || (pitstopRepairsDropDown = 5)))

			try {
				session := this.SelectedSession[true]

				lap := this.Connector.GetSessionLastLap(session)

				this.Connector.SetLapValue(lap, "Pitstop Plan", printConfiguration(pitstopPlan))
				this.Connector.SetSessionValue(session, "Pitstop Plan", lap)

				showMessage(translate("Race Engineer will be instructed as fast as possible."))
			}
			catch exception {
				title := translate("Error")

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				MsgBox 262192, %title%, % translate("You must be connected to an active session to plan a pitstop.")
				OnMessage(0x44, "")
			}
		}
		else {
			title := translate("Error")

			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262192, %title%, % translate("You must be connected to an active session to plan a pitstop.")
			OnMessage(0x44, "")
		}
	}

	chooseSessionMenu(line) {
		local window, title

		switch line {
			case 3: ; Connect...
				window := this.Window

				Gui %window%:Default

				GuiControlGet serverURLEdit
				GuiControlGet serverTokenEdit

				this.iServerURL := serverURLEdit
				this.iServerToken := ((serverTokenEdit = "") ? "__INVALID__" : serverTokenEdit)

				this.connect()
			case 4: ; Clear...
				if this.SessionActive {
					title := translate("Delete")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
					MsgBox 262436, %title%, % translate("Do you really want to delete all data from the currently active session? This can take quite a while...")
					OnMessage(0x44, "")

					IfMsgBox Yes
						this.clearSession()
				}
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("You are not connected to an active session.")
					OnMessage(0x44, "")
				}
			case 6: ; Load Session...
				this.loadSession()
			case 7: ; Save Session
				if this.HasData {
					if this.SessionActive
						this.saveSession()
					else {
						title := translate("Information")

						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						MsgBox 262192, %title%, % translate("You are not connected to an active session. Use ""Save a Copy..."" instead.")
						OnMessage(0x44, "")
					}
				}
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("There is no session data to be saved.")
					OnMessage(0x44, "")
				}
			case 8: ; Save Session Copy...
				if this.HasData
					this.saveSession(true)
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("There is no session data to be saved.")
					OnMessage(0x44, "")
				}
			case 10: ; Update Statistics
				this.updateStatistics()
			case 12: ; Race Summary
				this.showRaceSummary()
			case 13: ; Driver Statistics
				this.showDriverStatistics()
		}
	}

	chooseStrategyMenu(line) {
		local strategy, simulator, car, track, simulatorCode, dirName, fileName, configuration, title, file, name
		local sessionDB, directory

		if this.Simulator {
			simulator := this.Simulator
			car := this.Car
			track := this.Track

			if (car && track) {
				sessionDB := new SessionDatabase()

				directory := sessionDB.DatabasePath
				simulatorCode := sessionDB.getSimulatorCode(simulator)

				dirName = %directory%User\%simulatorCode%\%car%\%track%\Race Strategies

				FileCreateDir %dirName%
			}
			else
				dirName := ""
		}
		else
			dirName := ""

		switch line {
			case 3:
				fileName := kUserConfigDirectory . "Race.strategy"

				if FileExist(fileName) {
					configuration := readConfiguration(fileName)

					if (configuration.Count() > 0)
						this.selectStrategy(this.createStrategy(configuration, false, false), true)
				}
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("There is no active Race Strategy.")
					OnMessage(0x44, "")
				}
			case 4:
				title := translate("Load Race Strategy...")

				Gui +OwnDialogs

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
				FileSelectFile file, 1, %dirName%, %title%, Strategy (*.strategy)
				OnMessage(0x44, "")

				if (file != "") {
					configuration := readConfiguration(file)

					if (configuration.Count() > 0)
						this.selectStrategy(this.createStrategy(configuration, false, false), true)
				}
			case 5: ; "Save Strategy..."
				if this.Strategy {
					title := translate("Save Race Strategy...")

					fileName := (dirName . "\" . this.Strategy.Name . ".strategy")

					Gui +OwnDialogs

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Save", "Cancel"]))
					FileSelectFile file, S17, %fileName%, %title%, Strategy (*.strategy)
					OnMessage(0x44, "")

					if (file != "") {
						if !InStr(file, ".")
							file := (file . ".strategy")

						SplitPath file, , , , name

						this.Strategy.setName(name)

						configuration := newConfiguration()

						this.Strategy.saveToConfiguration(configuration)

						writeConfiguration(file, configuration)
					}
				}
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("There is no current Strategy.")
					OnMessage(0x44, "")
				}
			case 7: ; Strategy Summary
				if this.Strategy {
					this.StrategyViewer.showStrategyInfo(this.Strategy)

					this.iSelectedDetailReport := "Strategy"
				}
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("There is no current Strategy.")
					OnMessage(0x44, "")
				}
			case 9: ; Use Session Data
				this.iUseSessionData := !this.UseSessionData

				this.updateState()
			case 10: ; Use Telemetry Database
				this.iUseTelemetryDatabase := !this.UseTelemetryDatabase

				this.updateState()
			case 11: ; Use current Map
				this.iUseCurrentMap := !this.UseCurrentMap

				this.updateState()
			case 12: ; Use Traffic
				this.iUseTraffic := !this.UseTraffic

				this.updateState()
			case 14: ; Run Simulation
				if this.Strategy {
					if (this.UseTraffic && !this.SessionActive) {
						title := translate("Information")

						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						MsgBox 262192, %title%, % translate("A traffic-based strategy simulation is only possible in an active session.")
						OnMessage(0x44, "")

						this.iUseTraffic := false

						this.updateState()
					}

					this.runSimulation(this.Strategy.SessionType)
				}
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("There is no current Strategy.")
					OnMessage(0x44, "")
				}
			case 16: ; Discard Strategy
				if this.Strategy {
					if this.SessionActive {
						title := translate("Strategy")

						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
						MsgBox 262436, %title%, % translate("Do you really want to discard the active strategy? Strategist will be instructed immediately...")
						OnMessage(0x44, "")

						IfMsgBox Yes
						{
							this.discardStrategy()

							if (this.SelectedDetailReport = "Strategy")
								this.showDetails(false, false)
						}
					}
					else {
						title := translate("Information")

						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						MsgBox 262192, %title%, % translate("You are not connected to an active session.")
						OnMessage(0x44, "")
					}
				}
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("There is no current Strategy.")
					OnMessage(0x44, "")
				}
			case 18: ; Instruct Strategist
				if this.Strategy {
					if this.SessionActive
						this.updateStrategy()
					else {
						title := translate("Information")

						OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
						MsgBox 262192, %title%, % translate("You are not connected to an active session.")
						OnMessage(0x44, "")
					}
				}
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("There is no current Strategy.")
					OnMessage(0x44, "")
				}
		}
	}

	choosePlanMenu(line) {
		local title

		switch line {
			case 3:
				this.pushTask(ObjBindMethod(this, "loadPlanFromStrategyAsync"))
			case 4:
				this.pushTask(ObjBindMethod(this, "clearPlanAsync"))
			case 6:
				this.showPlanDetails()

				this.iSelectedDetailReport := "Plan"
			case 8:
				if this.SessionActive
					this.releasePlan()
				else {
					title := translate("Information")

					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					MsgBox 262192, %title%, % translate("You are not connected to an active session.")
					OnMessage(0x44, "")
				}
		}
	}

	choosePitstopMenu(line) {
		local pid, exePath, options, simulator

		switch line {
			case 3: ; Manage Team
				this.manageTeam()
			case 5:
				this.initializePitstopFromSession()
			case 6:
				exePath := kBinariesDirectory . "Session Database.exe"

				try {
					Process Exist

					pid := ErrorLevel

					options := ["-Setup", pid]

					if (this.Simulator && this.Car && this.Track) {
						simulator := new SessionDatabase().getSimulatorName(this.Simulator)

						options := concatenate(options, ["-Simulator", """" . simulator . """", "-Car", """" . this.Car . """", "-Track", """" . this.Track . """"
													   , "-Weather", this.Weather
													   , "-AirTemperature", Round(this.AirTemperature), "-TrackTemperature", Round(this.TrackTemperature)])
					}

					options := values2String(A_Space, options*)

					Run "%exePath%" %options%, %kBinariesDirectory%
				}
				catch exception {
					logMessage(kLogCritical, translate("Cannot start the Session Database tool (") . exePath . translate(") - please rebuild the applications in the binaries folder (") . kBinariesDirectory . translate(")"))

					showMessage(substituteVariables(translate("Cannot start the Session Database tool (%exePath%) - please check the configuration..."), {exePath: exePath})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
				}
			case 7:
				this.pushTask(ObjBindMethod(this, "clearSetupsAsync"))
			case 9:
				this.showSetupsDetails()

				this.iSelectedDetailReport := "Setups"
			case 10:
				this.showPitstopsDetails()

				this.iSelectedDetailReport := "Pitstops"
			case 12:
				this.iTyrePressureMode := ((this.TyrePressureMode = "Reference") ? false : "Reference")

				this.updateState()
			case 13:
				this.iTyrePressureMode := ((this.TyrePressureMode = "Relative") ? false : "Relative")

				this.updateState()
			case 15:
				this.planPitstop()
		}
	}

	loadPlanFromStrategyAsync() {
		this.loadPlanFromStrategy()
	}

	clearPlanAsync() {
		this.clearPlan()
	}

	clearSetupsAsync() {
		this.clearSetups()
	}

	withExceptionHandler(function, arguments*) {
		local title

		try {
			return %function%(arguments*)
		}
		catch exception {
			title := translate("Error")

			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			MsgBox 262160, %title%, % (translate("Error while executing command.") . "`n`n" . translate("Error: ") . exception.Message)
			OnMessage(0x44, "")
		}
	}

	pushTask(theTask) {
		new RaceCenterTask(theTask).start()
	}

	createStrategy(nameOrConfiguration, driver := false, simulation := true) {
		local name := nameOrConfiguration
		local theStrategy

		if !IsObject(nameOrConfiguration)
			nameOrConfiguration := false

		theStrategy := ((simulation && this.UseTraffic) ? new this.SessionTrafficStrategy(this, nameOrConfiguration, driver)
														: new this.SessionStrategy(this, nameOrConfiguration, driver))

		if (name && !IsObject(name))
			theStrategy.setName(name)

		theStrategy.setVersion(A_Now)

		return theStrategy
	}

	selectStrategy(strategy, show := false) {
		if this.Strategy
			this.Strategy.dispose()

		this.iStrategy := strategy

		if strategy
			this.initializeSimulator(strategy.Simulator, strategy.Car, strategy.Track)

		if (show || (this.SelectedDetailReport = "Strategy") || !this.SelectedDetailReport)
			if strategy {
				this.StrategyViewer.showStrategyInfo(this.Strategy)

				this.iSelectedDetailReport := "Strategy"
			}
			else {
				this.showDetails(false, false)

				this.iSelectedDetailReport := false
			}
	}

	getStintDriver(stintNumber, ByRef driverID, ByRef driverName) {
		local driver := this.getDriver(stintNumber)

		if (driver && driver.ID) {
			driverID := driver.ID
			driverName := driver.Fullname
		}
		else {
			driverID := false
			driverName := "John Doe (JD)"
		}

		return true
	}

	runSimulation(sessionType) {
		this.pushTask(ObjBindMethod(this, "runSimulationAsync", sessionType))
	}

	runSimulationAsync(sessionType) {
		local telemetryDB

		this.saveSession()

		telemetryDB := new this.RaceCenterTelemetryDatabase.SimulationTelemetryDatabase(this, this.Simulator, this.Car, this.Track)

		this.iSimulationTelemetryDatabase := telemetryDB

		try {
			if this.UseTraffic
				new TrafficSimulation(this, sessionType, telemetryDB).runSimulation(true)
			else
				new VariationSimulation(this, sessionType, telemetryDB).runSimulation(true)
		}
		finally {
			this.iSimulationTelemetryDatabase := false
		}
	}

	getPreviousLap(lap) {
		local laps := this.Laps

		lap := (lap.Nr - 1)

		while (lap > 0)
			if laps.HasKey(lap)
				return laps[lap]
			else
				lap -= 1

		return false
	}

	getStrategySettings(ByRef simulator, ByRef car, ByRef track, ByRef weather, ByRef airTemperature, ByRef trackTemperature
					  , ByRef sessionType, ByRef sessionLength
					  , ByRef maxTyreLaps, ByRef tyreCompound, ByRef tyreCompoundColor, ByRef tyrePressures) {
		local strategy := this.Strategy
		local telemetryDB, candidate

		if strategy {
			if this.Simulator {
				simulator := new SessionDatabase().getSimulatorName(this.Simulator)
				car := this.Car
				track := this.Track
			}
			else {
				simulator := strategy.Simulator
				car := strategy.Car
				track := strategy.Track
			}

			if this.Weather {
				weather := this.Weather
				airTemperature := this.AirTemperature
				trackTemperature := this.TrackTemperature
			}
			else {
				weather := strategy.Weather
				airTemperature := strategy.AirTemperature
				trackTemperature := strategy.TrackTemperature
			}

			if this.TyreCompound {
				tyreCompound := this.TyreCompound
				tyreCompoundColor := this.TyreCompoundColor
			}
			else {
				tyreCompound := strategy.TyreCompound
				tyreCompoundColor := strategy.TyreCompoundColor
			}

			telemetryDB := this.SimulationTelemetryDatabase

			if !telemetryDB.suitableTyreCompound(simulator, car, track, weather, compound(tyreCompound, tyreCompoundColor)) {
				candidate := telemetryDB.optimalTyreCompound(simulator, car, track, weather, airTemperature, trackTemperature
														   , getKeys(this.computeAvailableTyreSets(strategy.AvailableTyreSets)))

				if candidate
					splitCompound(candidate, tyreCompound, tyreCompoundColor)
			}

			sessionType := strategy.SessionType
			sessionLength := strategy.SessionLength
			maxTyreLaps := strategy.MaxTyreLaps
			tyrePressures := strategy.TyrePressures

			return true
		}
		else
			return false
	}

	getSessionSettings(ByRef stintLength, ByRef formationLap, ByRef postRaceLap, ByRef fuelCapacity, ByRef safetyFuel
					 , ByRef pitstopDelta, ByRef pitstopFuelService, ByRef pitstopTyreService, ByRef pitstopServiceOrder) {
		local strategy := this.Strategy

		if strategy {
			stintLength := strategy.StintLength
			formationLap := strategy.FormationLap
			postRaceLap := strategy.PostRaceLap

			fuelCapacity := strategy.FuelCapacity
			safetyFuel := strategy.SafetyFuel

			pitstopDelta := strategy.PitstopDelta
			pitstopFuelService := strategy.PitstopFuelService
			pitstopTyreService := strategy.PitstopTyreService
			pitstopServiceOrder := strategy.PitstopServiceOrder

			return true
		}
		else
			return false
	}

	getSessionWeather(minute, ByRef weather, ByRef airTemperature, ByRef trackTemperature) {
		local strategy

		if this.Weather {
			if (minute >= 30)
				weather := this.Weather30Min
			else if (minute >= 10)
				weather := this.Weather10Min
			else
				weather := this.Weather

			airTemperature := this.AirTemperature
			trackTemperature := this.TrackTemperature
		}
		else {
			strategy := := this.Strategy

			if strategy
				return strategy.getWeather(minute, weather, airTemperature, trackTemperature)
			else {
				weather := "Dry"
				airTemperature := 23
				trackTemperature := 27
			}
		}

		return false
	}

	getTrafficSettings(ByRef randomFactor, ByRef numScenarios, ByRef variationWindow
					 , ByRef useLapTimeVariation, ByRef useDriverErrors, ByRef usePitstops
					 , ByRef overTakeDelta, ByRef consideredTraffic) {
		local window := this.Window

		Gui %window%:Default

		GuiControlGet numScenariosEdit
		GuiControlGet variationWindowEdit
		GuiControlGet randomFactorEdit

		randomFactor := randomFactorEdit
		numScenarios := numScenariosEdit
		variationWindow := variationWindowEdit

		GuiControlGet lapTimeVariationDropDown
		GuiControlGet driverErrorsDropDown
		GuiControlGet pitstopsDropDown
		GuiControlGet overtakeDeltaEdit
		GuiControlGet trafficConsideredEdit

		useLapTimeVariation := (lapTimeVariationDropDown == 1)
		useDriverErrors := (driverErrorsDropDown == 1)
		usePitstops := (pitstopsDropDown == 1)
		overTakeDelta := overtakeDeltaEdit
		consideredTraffic := trafficConsideredEdit
	}

	getStartConditions(ByRef initialStint, ByRef initialLap, ByRef initialStintTime, ByRef initialSessionTime
					 , ByRef initialTyreLaps, ByRef initialFuelAmount
					 , ByRef initialMap, ByRef initialFuelConsumption, ByRef initialAvgLapTime) {
		local lastLap, tyresTable, lap, ignore, stint, telemetryDB
		local strategy, simulator, car, track, weather, tyreCompound, tyreCompoundColor

		this.syncSessionStore()

		lastLap := this.LastLap

		initialStint := 1
		initialLap := 0
		initialSessionTime := 0
		initialStintTime := 0
		initialTyreLaps := 0
		initialFuelAmount := 0
		initialMap := "n/a"
		initialFuelConsumption := 0
		initialAvgLapTime := 0.0

		if lastLap {
			telemetryDB := this.SimulationTelemetryDatabase

			initialStint := lastLap.Stint.Nr
			initialLap := lastLap.Nr
			initialFuelAmount := lastLap.FuelRemaining
			initialMap := lastLap.Map
			initialFuelConsumption := lastLap.FuelConsumption
			initialAvgLapTime := this.CurrentStint.AvgLapTime

			initialStintTime := this.computeDuration(this.CurrentStint)

			loop % this.CurrentStint.Nr
				if this.Stints.HasKey(A_Index)
					initialSessionTime += this.computeDuration(this.Stints[A_Index])

			strategy := this.Strategy

			if this.Simulator {
				simulator := new SessionDatabase().getSimulatorName(this.Simulator)
				car := this.Car
				track := this.Track
			}
			else {
				simulator := strategy.Simulator
				car := strategy.Car
				track := strategy.Track
			}

			if this.Weather
				weather := this.Weather
			else
				weather := strategy.Weather

			if this.TyreCompound {
				tyreCompound := this.TyreCompound
				tyreCompoundColor := this.TyreCompoundColor
			}
			else {
				tyreCompound := strategy.TyreCompound
				tyreCompoundColor := strategy.TyreCompoundColor
			}

			if !telemetryDB.suitableTyreCompound(simulator, car, track, weather, tyreCompound, tyreCompoundColor)
				initialTyreLaps := 999
			else {
				tyresTable := telemetryDB.Database.Tables["Tyres"]

				if (tyresTable.Length() >= lastLap.Nr)
					initialTyreLaps := tyresTable[lastLap.Nr]["Tyre.Laps"]
				else
					initialTyreLaps := 0
			}
		}
	}

	getSimulationSettings(ByRef useInitialConditions, ByRef useTelemetryData
						, ByRef consumptionVariation, ByRef initialFuelVariation, ByRef tyreUsageVariation, ByRef tyreCompoundVariation) {
		local strategy := this.Strategy
		local window

		useInitialConditions := false
		useTelemetryData := true

		if strategy {
			consumptionVariation := strategy.ConsumptionVariation
			initialFuelVariation := strategy.InitialFuelVariation
			tyreUsageVariation := strategy.TyreUsageVariation
			tyreCompoundVariation := strategy.TyreCompoundVariation
		}
		else {
			consumptionVariation := 0
			initialFuelVariation := 0
			tyreUsageVariation := 0
			tyreCompoundVariation := 0
		}

		if !this.UseTraffic {
			window := this.Window

			Gui %window%:Default

			GuiControlGet randomFactorEdit

			tyreUsageVariation := randomFactorEdit
			tyreCompoundVariation := randomFactorEdit
		}

		return (strategy != false)
	}

	getPitstopRules(ByRef validator, ByRef pitstopRule, ByRef refuelRule, ByRef tyreChangeRule, ByRef tyreSets) {
		local strategy := this.Strategy
		local window, currentListView, pitstops

		if strategy {
			validator := strategy.Validator
			pitstopRule := strategy.PitstopRule
			refuelRule := strategy.RefuelRule
			tyreChangeRule := strategy.TyreChangeRule
			tyreSets := strategy.TyreSets

			if pitstopRule is Integer
				if (pitstopRule > 0) {
					window := this.Window

					Gui %window%:Default

					currentListView := A_DefaultListView

					try {
						Gui ListView, % this.PitstopsListView

						pitstops := LV_GetCount()

						pitstopRule := Max(0, pitstopRule - pitstops)
					}
					finally {
						Gui ListView, %currentListView%
					}
				}

			return true
		}
		else
			return false
	}

	getAvgLapTime(numLaps, map, remainingFuel, fuelConsumption, weather, tyreCompound, tyreCompoundColor, tyreLaps, default := false) {
		local telemetryDB := this.SimulationTelemetryDatabase
		local lapTimes := telemetryDB.getMapLapTimes(weather, tyreCompound, tyreCompoundColor)
		local tyreLapTimes := telemetryDB.getTyreLapTimes(weather, tyreCompound, tyreCompoundColor)
		local a := false
		local b := false
		local xValues, yValues, ignore, entry, baseLapTime, count, avgLapTime, lapTime, candidate

		if (tyreLapTimes.Length() > 1) {
			xValues := []
			yValues := []

			for ignore, entry in tyreLapTimes {
				xValues.Push(entry["Tyre.Laps"])
				yValues.Push(entry["Lap.Time"])
			}

			linRegression(xValues, yValues, a, b)
		}

		baseLapTime := ((a && b) ? (a + (tyreLaps * b)) : false)

		count := 0
		avgLapTime := 0
		lapTime := false

		loop %numLaps% {
			candidate := lookupLapTime(lapTimes, map, remainingFuel - (fuelConsumption * (A_Index - 1)))

			if (!lapTime || !baseLapTime)
				lapTime := candidate
			else if (candidate < lapTime)
				lapTime := candidate

			if lapTime {
				if baseLapTime
					avgLapTime += (lapTime + ((a + (b * (tyreLaps + A_Index))) - baseLapTime))
				else
					avgLapTime += lapTime

				count += 1
			}
		}

		if (avgLapTime > 0)
			avgLapTime := (avgLapTime / count)

		return avgLapTime ? avgLapTime : (default ? default : this.Strategy.AvgLapTime)
	}

	computeAvailableTyreSets(availableTyreSets) {
		local window := this.Window
		local currentListView, compound, translatedCompounds, index, count

		availableTyreSets := availableTyreSets.Clone()

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PitstopsListView

			translatedCompounds := map(this.TyreCompounds, "translate")

			loop % LV_GetCount()
			{
				LV_GetText(compound, A_Index, 4)

				index := inList(translatedCompounds, compound)

				if index {
					compound := this.TyreCompounds[index]

					if availableTyreSets.HasKey(compound) {
						count := (availableTyreSets[compound] - 1)

						if (count > 0)
							availableTyreSets[compound] := count
						else
							availableTyreSets.Delete(compound)
					}
				}
			}
		}
		finally {
			Gui ListView, %currentListView%
		}

		return availableTyreSets
	}

	initializeAvailableTyreSets(strategy) {
		strategy.AvailableTyreSets := this.computeAvailableTyreSets(strategy.AvailableTyreSets)
	}

	chooseScenario(strategy) {
		if strategy {
			if this.Strategy
				strategy.PitstopRule := this.Strategy.PitstopRule

			this.selectStrategy(strategy, true)
		}
	}

	startWorking(state := true) {
		local window := this.Window
		local start := false
		local html

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

		Gui %window%:Default

		if state
			Gui %window%:+Disabled
		else
			Gui %window%:-Disabled

		waitViewer.Document.Open()

		html := (state ? ("<img src='" . (kResourcesDirectory . "Wait.gif") . "' width=28 height=28 border=0 padding=0></body></html>") : "")
		html := ("<html><body style='background-color: #D0D0D0' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>" . html . "</body></html>")

		waitViewer.Document.Write(html)
		waitViewer.Document.Close()

		return (start || (this.iWorking == 0))
	}

	finishWorking() {
		this.startWorking(false)
	}

	isWorking() {
		return (this.iWorking > 0)
	}

	initializeSession() {
		local directory, reportDirectory, currentListView

		this.iSessionFinished := false
		this.iSessionLoaded := false

		if this.SessionActive {
			directory := this.SessionDirectory

			deleteDirectory(directory)

			FileCreateDir %directory%

			reportDirectory := (directory . "Race Report")

			deleteDirectory(reportDirectory)

			FileCreateDir %reportDirectory%

			this.ReportViewer.setReport(reportDirectory)
		}

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.SetupsListView

			LV_Delete()

			this.iSelectedSetup := false

			Gui ListView, % this.PlanListView

			LV_Delete()

			this.iSelectedPlanStint := false

			Gui ListView, % this.StintsListView

			LV_Delete()

			Gui ListView, % this.LapsListView

			LV_Delete()

			Gui ListView, % this.PitstopsListView

			LV_Delete()

			GuiControl, , driverDropDown, |
			GuiControl Choose, driverDropDown, 0

			this.iAvailableDrivers := []
			this.iSelectedDrivers := false

			if this.SessionActive
				this.loadSessionDrivers()
			else {
				GuiControl, , setupDriverDropDownMenu, % "|"
				GuiControl, , planDriverDropDownMenu, % "|"
			}

			GuiControl, , pitstopDriverDropDownMenu, % "|"

			this.iTeamDrivers := []
			this.iTeamDriversVersion := false

			this.iDrivers := []
			this.iStints := {}
			this.iLaps := {}

			this.iLastLap := false
			this.iCurrentStint := false

			this.iTelemetryDatabase := false
			this.iPressuresDatabase := false
			this.iSessionStore := false

			this.iSelectedReport := false
			this.iSelectedChartType := false
			this.iSelectedDetailReport := false

			GuiControlGet sessionDateCal
			GuiControlGet sessionTimeEdit

			this.iSetupsVersion := false
			this.iSelectedSetup := false

			this.iPlanVersion := false
			this.iDate := sessionDateCal
			this.iTime := sessionTimeEdit
			this.iSelectedPlanStint := false

			this.iSimulator := false
			this.iCar := false
			this.iTrack := false

			this.iWeather := false
			this.iWeather10Min := false
			this.iWeather30Min := false
			this.iAirTemperature := false
			this.iTrackTemperature := false

			this.iTyreCompound := false
			this.iTyreCompoundColor := false

			this.iStrategy := false

			this.showChart(false)
			this.showDetails(false, false)
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	initializeSimulator(simulator, car, track, force := false) {
		local window, compounds, currentListView, row, compound

		if (force || !this.Simulator || (this.Simulator != simulator) || (this.Car != car) || (this.Track != track)) {
			this.iSimulator := simulator
			this.iCar := car
			this.iTrack := track

			if (this.Simulator = "") {
				this.iSimulator := false
				this.iCar := false
				this.iTrack := false
			}

			if this.Simulator {
				window := this.Window

				Gui %window%:Default

				compounds := new SessionDatabase().getTyreCompounds(simulator, car, track)

				this.iTyreCompounds := compounds

				GuiControl, , setupCompoundDropDownMenu, % ("|" . values2String("|", map(compounds, "translate")*))

				currentListView := A_DefaultListView

				try {
					Gui ListView, % this.SetupsListView

					row := LV_GetNext(0)

					if row {
						LV_GetText(compound, row, 3)

						GuiControl Choose, setupCompoundDropDownMenu, % inList(map(this.TyreCompounds, "translate"), compound)
					}
					else
						GuiControl Choose, setupCompoundDropDownMenu, % ((compounds.Length() > 0) ? 1 : 0)
				}
				finally {
					Gui ListView, %currentListView%
				}

				GuiControl, , pitstopTyreCompoundDropDown, % ("|" . values2String("|", map(concatenate(["No Tyre Change"], compounds), "translate")*))
				GuiControl Choose, pitstopTyreCompoundDropDown, 1
			}
		}
	}

	initializeReports() {
		local raceData, drivers, positions, times

		if !this.Simulator {
			raceData := true
			drivers := false
			positions := false
			times := false

			this.ReportViewer.loadReportData(false, raceData, drivers, positions, times)

			this.initializeSimulator(getConfigurationValue(raceData, "Session", "Simulator", false)
								   , getConfigurationValue(raceData, "Session", "Car")
								   , getConfigurationValue(raceData, "Session", "Track"))
		}
	}

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

	loadNewStints(currentStint) {
		local session := this.SelectedSession[true]
		local newStints := []
		local ignore, identifier, newStint, time, identifier, driver, message, stint

		if (!this.CurrentStint || (currentStint.Nr > this.CurrentStint.Nr)) {
			for ignore, identifier in string2Values(";", this.Connector.GetSessionStints(session))
				if !this.Stints.HasKey(identifier) {
					newStint := parseObject(this.Connector.GetStint(identifier))
					newStint.Nr := (newStint.Nr + 0)

					try {
						time := this.Connector.GetStintValue(identifier, "Time")
					}
					catch exception {
						time := false
					}

					if (!time || (time == ""))
						newStint.Time := ((newStint.Nr == 1) ? (A_Now . "") : false)
					else
						newStint.Time := time

					try {
						newStint.ID := this.Connector.GetStintValue(identifier, "ID")

						if (newStint.ID = "")
							newStint.ID := false
					}
					catch exception {
						newStint.ID := false
					}

					newStints.Push(newStint)
				}

			loop % newStints.Length()
			{
				stint := newStints[A_Index]
				identifier := stint.Identifier

				driver := parseObject(this.Connector.GetDriver(this.Connector.GetStintDriver(identifier)))
				driver["ID"] := stint.ID

				driver := this.createDriver(driver)

				message := (translate("Load stint (Stint: ") . stint.Nr . translate(", Driver: ") . driver.FullName . translate(")"))

				this.showMessage(message)

				logMessage(kLogInfo, message)

				stint.Driver := driver
				driver.Stints.Push(stint)
				stint.FuelConsumption := 0.0
				stint.Accidents := 0
				stint.Weather := "-"
				stint.Compound := "-"
				stint.StartPosition := "-"
				stint.EndPosition := "-"
				stint.AvgLaptime := "-"
				stint.Potential := "-"
				stint.RaceCraft := "-"
				stint.Speed := "-"
				stint.Consistency := "-"
				stint.CarControl := "-"

				stint.Laps := []

				this.Stints[identifier] := stint
				this.Stints[stint.Nr] := stint
			}
		}

		bubbleSort(newStints, "objectOrder")

		return newStints
	}

	loadNewLaps(stint) {
		local stintLaps := string2Values(";" , this.Connector.GetStintLaps(stint.Identifier))
		local newLaps := []
		local ignore, identifier, newLap, count, lap, tries, rawData, data, damage, ignore, value
		local fuelConsumption, compound, compoundColor, car, pLap

		for ignore, identifier in stintLaps
			if !this.Laps.HasKey(identifier) {
				newLap := parseObject(this.Connector.GetLap(identifier))
				newLap.Nr := (newLap.Nr + 0)

				if !this.Laps.HasKey(newLap.Nr)
					newLaps.Push(newLap)
			}

		bubbleSort(newLaps, "objectOrder")

		count := newLaps.Length()

		loop %count% {
			lap := newLaps[A_Index]
			identifier := lap.Identifier

			lap.Stint := stint

			tries := ((A_Index == count) ? 30 : 1)

			while (tries > 0) {
				rawData := this.Connector.GetLapValue(identifier, "Telemetry Data")

				if (!rawData || (rawData == "")) {
					tries -= 1

					this.showMessage(translate("Waiting for data"))

					if (tries <= 0) {
						this.showMessage(translate("Give up - use default values"))

						newLaps.RemoveAt(A_Index, newLaps.Length() - A_Index + 1)

						return newLaps
					}
					else
						Sleep 400
				}
				else {
					this.showMessage(translate("Load lap data (Lap: ") . lap.Nr . translate(")"))

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, translate("Load lap data (Lap: ") . lap.Nr . translate("), Data: `n`n") . rawData . "`n")

					break
				}
			}

			if (stint.Laps.Length() == 0)
				stint.Lap := lap.Nr

			stint.Laps.Push(lap)
			stint.Driver.Laps.Push(lap)

			data := parseConfiguration(rawData)

			lap.Telemetry := rawData

			damage := 0

			for ignore, value in string2Values(",", getConfigurationValue(data, "Car Data", "BodyworkDamage"))
				damage += value

			for ignore, value in string2Values(",", getConfigurationValue(data, "Car Data", "SuspensionDamage"))
				damage += value

			lap.Damage := damage

			if ((lap.Nr == 1) && (damage > 0))
				lap.Accident := true
			else if ((lap.Nr > 1) && (damage > this.getPreviousLap(lap).Damage))
				lap.Accident := true
			else
				lap.Accident := false

			lap.EngineDamage := getConfigurationValue(data, "Car Data", "EngineDamage", 0)

			lap.FuelRemaining := Round(getConfigurationValue(data, "Car Data", "FuelRemaining"), 1)

			if ((lap.Nr == 1) || (stint.Laps[1] == lap))
				lap.FuelConsumption := "-"
			else {
				fuelConsumption := (this.getPreviousLap(lap).FuelRemaining - lap.FuelRemaining)

				lap.FuelConsumption := ((fuelConsumption > 0) ? Round(fuelConsumption, 1) : "-")
			}

			lap.Laptime := Round(getConfigurationValue(data, "Stint Data", "LapLastTime") / 1000, 1)

			lap.Map := getConfigurationValue(data, "Car Data", "Map")
			lap.TC := getConfigurationValue(data, "Car Data", "TC")
			lap.ABS := getConfigurationValue(data, "Car Data", "ABS")

			lap.Weather := getConfigurationValue(data, "Weather Data", "Weather")
			lap.Weather10Min := getConfigurationValue(data, "Weather Data", "Weather10Min")
			lap.Weather30Min := getConfigurationValue(data, "Weather Data", "Weather30Min")
			lap.AirTemperature := Round(getConfigurationValue(data, "Weather Data", "Temperature"), 1)
			lap.TrackTemperature := Round(getConfigurationValue(data, "Track Data", "Temperature"), 1)
			lap.Grip := getConfigurationValue(data, "Track Data", "Grip")

			compound := getConfigurationValue(data, "Car Data", "TyreCompound")
			compoundColor := getConfigurationValue(data, "Car Data", "TyreCompoundColor")

			lap.Compound := compound(compound, compoundColor)

			try {
				tries := ((A_Index == count) ? 30 : 1)

				while (tries > 0) {
					rawData := this.Connector.GetLapValue(identifier, "Positions Data")

					if (!rawData || (rawData = "")) {
						tries -= 1

						this.showMessage(translate("Waiting for data"))

						if (tries <= 0) {
							this.showMessage(translate("Give up - use default values"))

							throw "No data..."
						}
						else
							Sleep 400
					}
					else
						break
				}

				data := parseConfiguration(rawData)

				lap.Positions := rawData

				car := getConfigurationValue(data, "Position Data", "Driver.Car")

				if car
					lap.Position := getConfigurationValue(data, "Position Data", "Car." . car . ".Position")
				else
					throw "No data..."
			}
			catch exception {
				if (lap.Nr > 1) {
					pLap := this.getPreviousLap(lap)

					lap.Positions := pLap.Positions
					lap.Position := pLap.Position
				}
				else
					lap.Position := "-"
			}

			this.Laps[identifier] := lap
			this.Laps[lap.Nr] := lap
		}

		return newLaps
	}

	updateStint(stint) {
		local window := this.Window
		local laps, numLaps, lapTimes, airTemperatures, trackTemperatures
		local ignore, lap, consumption, weather, currentListView

		Gui %window%:Default

		stint.FuelConsumption := 0.0
		stint.Accidents := 0
		stint.Weather := ""

		laps := stint.Laps
		numLaps := laps.Length()

		lapTimes := []
		airTemperatures := []
		trackTemperatures := []

		for ignore, lap in laps {
			if (lap.Nr > 1) {
				consumption := lap.FuelConsumption

				if consumption is Number
					stint.FuelConsumption += ((this.getPreviousLap(lap).FuelConsumption = "-") ? (consumption * 2) : consumption)
			}

			if lap.Accident
				stint.Accidents += 1

			lapTimes.Push(lap.Laptime)
			airTemperatures.Push(lap.AirTemperature)
			trackTemperatures.Push(lap.TrackTemperature)

			if (A_Index == 1) {
				stint.Compound := lap.Compound
				stint.StartPosition := lap.Position
			}
			else if (A_Index == numLaps)
				stint.EndPosition := lap.Position

			weather := lap.Weather

			if (stint.Weather = "")
				stint.Weather := weather
			else if !inList(string2Values(",", stint.Weather), weather)
				stint.Weather .= (", " . weather)
		}

		stint.AvgLaptime := Round(average(laptimes), 1)
		stint.BestLaptime := Round(minimum(laptimes), 1)
		stint.FuelConsumption := Round(stint.FuelConsumption, 1)
		stint.AirTemperature := Round(average(airTemperatures), 1)
		stint.TrackTemperature := Round(average(trackTemperatures), 1)

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.StintsListView

			LV_Modify(stint.Row, "", stint.Nr, stint.Driver.FullName, values2String(", ", map(string2Values(",", stint.Weather), "translate")*)
								   , translate(stint.Compound), stint.Laps.Length()
								   , stint.StartPosition, stint.EndPosition, lapTimeDisplayValue(stint.AvgLaptime), stint.FuelConsumption, stint.Accidents
								   , stint.Potential, stint.RaceCraft, stint.Speed, stint.Consistency, stint.CarControl)

			this.updatePlan(stint)
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	syncLaps(lastLap) {
		local window := this.Window
		local session := this.SelectedSession[true]
		local message, currentStint, first, newData, newStints, updatedStints, currentListView, ignore, stint, lap

		Gui %window%:Default

		message := (translate("Syncing laps (Lap: ") . lastLap.Nr . translate(")"))

		this.showMessage(message)

		if (getLogLevel() <= kLogInfo)
			logMessage(kLogInfo, message)

		try {
			currentStint := this.Connector.GetSessionCurrentStint(session)

			if currentStint {
				currentStint := parseObject(this.Connector.GetStint(currentStint))
				currentStint.Nr := (currentStint.Nr + 0)
			}
		}
		catch exception {
			currentStint := false
		}

		first := (!this.CurrentStint || !this.LastLap)

		if (!currentStint
		 || (!lastLap && this.CurrentStint && !((currentStint.Nr = (this.CurrentStint.Nr + 1)) && (currentStint.Lap == this.LastLap.Nr)))
		 || (this.CurrentStint && ((currentStint.Nr < this.CurrentStint.Nr)
								|| ((currentStint.Nr = this.CurrentStint.Nr) && (currentStint.Identifier != this.CurrentStint.Identifier))))
		 || (this.LastLap && (lastLap.Nr < this.LastLap.Nr))) {
			this.initializeSession()

			first := true
		}

		newData := first

		if (!this.LastLap || (lastLap.Nr > this.LastLap.Nr)) {
			try {
				newStints := this.loadNewStints(currentStint)

				currentStint := this.Stints[currentStint.Identifier]

				updatedStints := []

				if this.CurrentStint
					updatedStints := [this.CurrentStint]

				currentListView := A_DefaultListView

				try {
					Gui ListView, % this.StintsListView

					for ignore, stint in newStints {
						Gui ListView, % this.StintsListView

						LV_Add("", stint.Nr, stint.Driver.FullName, values2String(", ", map(string2Values(",", stint.Weather), "translate")*)
								 , translate(stint.Compound), stint.Laps.Length()
								 , stint.StartPosition, stint.EndPosition, lapTimeDisplayValue(stint.AvgLaptime), stint.FuelConsumption, stint.Accidents
								 , stint.Potential, stint.RaceCraft, stint.Speed, stint.Consistency, stint.CarControl)

						stint.Row := LV_GetCount()

						updatedStints.Push(stint)
					}

					if first {
						LV_ModifyCol()

						loop % LV_GetCount("Col")
							LV_ModifyCol(A_Index, "AutoHdr")
					}

					Gui ListView, % this.LapsListView

					for ignore, stint in updatedStints {
						for ignore, lap in this.loadNewLaps(stint) {
							Gui ListView, % this.LapsListView

							LV_Add("", lap.Nr, stint.Nr, stint.Driver.FullName, lap.Position, translate(lap.Weather), translate(lap.Grip), lapTimeDisplayValue(lap.Laptime), displayValue(lap.FuelConsumption), lap.FuelRemaining, "", lap.Accident ? translate("x") : "")

							lap.Row := LV_GetCount()
						}
					}

					if first {
						LV_ModifyCol()

						loop % LV_GetCount("Col")
							LV_ModifyCol(A_Index, "AutoHdr")
					}

					for ignore, stint in updatedStints
						this.updateStint(stint)

					newData := true

					this.iLastLap := this.Laps[lastLap.Nr]
					this.iCurrentStint := currentStint

					lastLap := this.LastLap

					if lastLap {
						this.iWeather := lastLap.Weather
						this.iAirTemperature := lastLap.AirTemperature
						this.iTrackTemperature := lastLap.TrackTemperature

						if lastLap.HasKey("Weather10Min") {
							this.iWeather10Min := lastLap.Weather10Min
							this.iWeather30Min := lastLap.Weather30Min
						}
						else {
							this.iWeather10Min := lastLap.Weather
							this.iWeather30Min := lastLap.Weather
						}
					}

					currentStint := this.CurrentStint

					if currentStint {
						this.iTyreCompound := compound(currentStint.Compound)
						this.iTyreCompoundColor := compoundColor(currentStint.Compound)
					}
				}
				finally {
					Gui ListView, %currentListView%
				}
			}
			catch exception {
				return newData
			}
		}

		return newData
	}

	syncRaceReport() {
		local lastLap := this.LastLap
		local directory, data, lap, message, raceInfo, pitstops, newData, missingLaps, lapData, key, value
		local times, positions, laps, drivers
		local mTimes, mPositions, mLaps, mDrivers, newLine, line, fileName

		if lastLap
			lastLap := lastLap.Nr
		else
			return

		directory := this.SessionDirectory . "Race Report"

		FileCreateDir %directory%

		directory .= "\"

		data := readConfiguration(directory . "Race.data")

		if (data.Count() == 0)
			lap := 1
		else
			lap := (getConfigurationValue(data, "Laps", "Count") + 1)

		message := (translate("Syncing race report (Lap: ") . lap . translate(")"))

		this.showMessage(message)

		if (getLogLevel() <= kLogInfo)
			logMessage(kLogInfo, message)

		if (lap == 1) {
			try {
				try {
					if this.Laps.HasKey(lap)
						raceInfo := this.Connector.getLapValue(this.Laps[lap].Identifier, "Race Strategist Race Info")
					else
						raceInfo := false
				}
				catch exception {
					raceInfo := false
				}

				if (!raceInfo || (raceInfo == ""))
					return false

				if !FileExist(directory . "Race.data")
					FileAppend %raceInfo%, %directory%Race.data
			}
			catch exception {
				logError(exception)
			}

			data := readConfiguration(directory . "Race.data")

			if (getConfigurationValue(data, "Cars", "Count") = "__NotInitialized__")
				setConfigurationValue(data, "Cars", "Count", 0)

			if (getConfigurationValue(data, "Cars", "Driver") = "__NotInitialized__")
				setConfigurationValue(data, "Cars", "Driver", 0)
		}

		pitstops := false
		newData := false
		missingLaps := 0

		while (lap <= lastLap) {
			try {
				if this.Laps.HasKey(lap)
					lapData := this.Connector.getLapValue(this.Laps[lap].Identifier, "Race Strategist Race Lap")
				else
					lapData := false

				if (lapData && (lapData != "")) {
					this.showMessage(translate("Updating race report (Lap: ") . lap . translate(")"))

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, translate("Updating race report (Lap: ") . lap . translate("), Data: `n`n") . lapData . "`n")

					lapData := parseConfiguration(lapData)
				}
				else if (lap = lastLap)
					throw "No data..."
				else {
					missingLaps +=1
					lap += 1

					continue
				}
			}
			catch exception {
				if newData
					writeConfiguration(directory . "Race.data", data)

				return newData
			}

			if (lapData.Count() == 0)
				return newData

			for key, value in getConfigurationSectionValues(lapData, "Lap")
				setConfigurationValue(data, "Laps", key, value)

			pitstops := getConfigurationValue(lapData, "Pitstop", "Laps", "")

			setConfigurationValue(data, "Laps", "Pitstops", pitstops)

			times := getConfigurationValue(lapData, "Times", lap)
			positions := getConfigurationValue(lapData, "Positions", lap)
			laps := getConfigurationValue(lapData, "Laps", lap)
			drivers := getConfigurationValue(lapData, "Drivers", lap)

			if (missingLaps > 0) {
				mTimes := times
				mPositions := positions
				mLaps := laps
				mDrivers := drivers

				loop %missingLaps% {
					times .= ("`n" . mTimes)
					positions .= ("`n" . mPositions)
					laps .= ("`n" . mLaps)
					drivers .= ("`n" . mDrivers)
				}
			}

			missingLaps := 0

			newLine := ((lap > 1) ? "`n" : "")

			line := (newLine . times)

			FileAppend %line%, % directory . "Times.CSV"

			line := (newLine . positions)

			FileAppend %line%, % directory . "Positions.CSV"

			line := (newLine . laps)

			FileAppend %line%, % directory . "Laps.CSV"

			line := (newLine . drivers)
			fileName := (directory . "Drivers.CSV")

			FileAppend %line%, %fileName%, UTF-16

			removeConfigurationValue(data, "Laps", "Lap")
			setConfigurationValue(data, "Laps", "Count", lap)

			newData := true
			lap += 1
		}

		if newData
			writeConfiguration(directory . "Race.data", data)

		return newData
	}

	syncTrackMap() {
		local rawData

		if this.LastLap {
			rawData := this.Connector.GetLapValue(this.LastLap.Identifier, "Telemetry Update")

			if (rawData && (rawData != "")) {
				this.LastLap.Telemetry := rawData

				return true
			}
		}

		return false
	}

	syncTelemetry(load := false) {
		local lastLap := this.LastLap
		local newData, message, session, telemetryDB, tyresTable, lap, runningLap, driverID, pitstop, tries
		local telemetryData, state, pressures, temperatures, wear, currentListView, lapPressures

		if lastLap
			lastLap := lastLap.Nr
		else
			return false

		newData := false

		if !load {
			message := (translate("Syncing telemetry data (Lap: ") . lastLap . translate(")"))

			this.showMessage(message)

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, message)

			session := this.SelectedSession[true]
			telemetryDB := this.TelemetryDatabase

			tyresTable := telemetryDB.Database.Tables["Tyres"]

			lap := tyresTable.Length()

			if (lap > 0)
				runningLap := tyresTable[lap]["Tyre.Laps"]
			else
				runningLap := 0

			lap += 1

			while (lap <= lastLap) {
				driverID := this.Laps[lap].Stint.ID

				pitstop := false

				if !this.Laps.HasKey(lap) {
					lap += 1

					continue
				}

				try {
					tries := ((lap == lastLap) ? 10 : 1)

					while (tries > 0) {
						telemetryData := this.Connector.GetSessionLapValue(session, lap, "Race Strategist Telemetry")

						if (!telemetryData || (telemetryData == "")) {
							tries -= 1

							this.showMessage(translate("Waiting for data"))

							if (tries <= 0) {
								this.showMessage(translate("Give up - use default values"))

								throw "No data..."
							}
							else
								Sleep 400
						}
						else {
							this.showMessage(translate("Updating telemetry data (Lap: ") . lap . translate(")"))

							if (getLogLevel() <= kLogInfo)
								logMessage(kLogInfo, translate("Updating telemetry data (Lap: ") . lap . translate("), Data: `n`n") . telemetryData . "`n")

							break
						}
					}
				}
				catch exception {
					try {
						state := this.Connector.GetSessionValue(session, "Race Engineer State")
					}
					catch exception {
						state := false
					}

					try {
						pitstop := this.Connector.GetSessionLapValue(session, lap, "Race Center Pitstop")

						if (pitstop = "")
							pitstop := false
					}
					catch exception {
						pitstop := false
					}

					if (!pitstop && (state && (state != ""))) {
						state := parseConfiguration(state)

						pitstop := getConfigurationValue(state, "Session State", "Pitstop.Last", false)

						if pitstop {
							pitstop := (Abs(lap - (getConfigurationValue(state, "Session State", "Pitstop." . pitstop . ".Lap"))) <= 2)

							if pitstop
								try {
									this.Connector.SetSessionLapValue(session, lap, "Race Center Pitstop", pitstop)
								}
								catch exception {
									logError(exception)
								}
						}
					}

					telemetryData := values2String(";", "-", "-", "-", "-", "-", "-", "-", "-", "-", pitstop, "n/a", "n/a", "n/a", "-", "-", ",,,", ",,,", "null,null,null,null")
				}

				telemetryData := string2Values(";", telemetryData)

				if !pitstop {
					pitstop := telemetryData[10]

					if pitstop
						telemetryData := ["-", "-", "-", "-", "-", "-", "-", "-", "-", pitstop, "n/a", "n/a", "n/a", "-", "-", ",,,", ",,,", "null,null,null,null"]
				}

				if ((runningLap > 2) && pitstop)
					runningLap := 0

				runningLap += 1

				pressures := string2Values(",", telemetryData[16])
				temperatures := string2Values(",", telemetryData[17])

				if (telemetryData.Length() >= 18)
					wear := string2Values(",", telemetryData[18])
				else
					wear := [kNull, kNull, kNull, kNull]

				telemetryDB.addElectronicEntry(telemetryData[4], telemetryData[5], telemetryData[6], telemetryData[14], telemetryData[15]
											 , telemetryData[11], telemetryData[12], telemetryData[13], telemetryData[7], telemetryData[8], telemetryData[9]
											 , driverID)

				telemetryDB.addTyreEntry(telemetryData[4], telemetryData[5], telemetryData[6], telemetryData[14], telemetryData[15], runningLap
									   , pressures[1], pressures[2], pressures[4], pressures[4]
									   , temperatures[1], temperatures[2], temperatures[3], temperatures[4]
									   , wear[1], wear[2], wear[3], wear[4]
									   , telemetryData[7], telemetryData[8], telemetryData[9]
									   , driverID)

				currentListView := A_DefaultListView

				try {
					Gui ListView, % this.LapsListView

					LV_GetText(lapPressures, lap, 10)

					if (lapPressures = "-, -, -, -")
						LV_Modify(this.Laps[lap].Row, "Col10", values2String(", ", map(pressures, "displayValue")*))

					newData := true
					lap += 1
				}
				finally {
					Gui ListView, %currentListView%
				}
			}
		}

		return newData
	}

	syncTyrePressures(load := false) {
		local lastLap, tyresTable, ignore, pressureData, pressureFL, pressureFR, pressureRL, pressureRR, tyres
		local currentListView, row, session, pressuresDB, message, newData, lap, flush, driverID, tries
		local lapPressures, coldPressures, hotPressures, pressuresTable

		if load {
			lastLap := this.LastLap

			if lastLap
				lastLap := (lastLap.Nr + 0)

			tyresTable := this.TelemetryDatabase.Database.Tables["Tyres"]

			for ignore, pressureData in this.PressuresDatabase.Database.Tables["Tyres.Pressures"] {
				if !this.Laps.HasKey(A_Index)
					continue

				pressureFL := pressureData["Tyre.Pressure.Hot.Front.Left"]
				pressureFR := pressureData["Tyre.Pressure.Hot.Front.Right"]
				pressureRL := pressureData["Tyre.Pressure.Hot.Rear.Left"]
				pressureRR := pressureData["Tyre.Pressure.Hot.Rear.Right"]

				if (tyresTable.Length() >= lastLap) {
					tyres := tyresTable[A_Index]

					if (isNull(pressureFL))
						pressureFL := tyres["Tyre.Pressure.Front.Left"]
					if (isNull(pressureFR))
						pressureFR := tyres["Tyre.Pressure.Front.Right"]
					if (isNull(pressureRL))
						pressureRL := tyres["Tyre.Pressure.Rear.Left"]
					if (isNull(pressureRR))
						pressureRR := tyres["Tyre.Pressure.Rear.Right"]
				}

				if this.Laps.HasKey(A_Index) {
					currentListView := A_DefaultListView

					try {
						Gui ListView, % this.LapsListView

						row := this.Laps[A_Index].Row

						LV_Modify(row, "Col10", values2String(", ", displayValue(pressureFL), displayValue(pressureFR)
																  , displayValue(pressureRL), displayValue(pressureRR)))
					}
					finally {
						Gui ListView, %currentListView%
					}
				}
			}

			return false
		}
		else {
			session := this.SelectedSession[true]
			pressuresDB := this.PressuresDatabase
			lastLap := this.LastLap

			if lastLap
				lastLap := lastLap.Nr
			else
				return

			message := (translate("Syncing tyre pressures (Lap: ") . lastLap . translate(")"))

			this.showMessage(message)

			if (getLogLevel() <= kLogInfo)
				logMessage(kLogInfo, message)

			pressuresTable := pressuresDB.Database.Tables["Tyres.Pressures"]
			lap := pressuresTable.Length()

			newData := false
			lap += 1

			flush := (Abs(lastLap - lap) <= 2)

			while (lap <= lastLap) {
				driverID := this.Laps[lap].Stint.ID

				if !this.Laps.HasKey(lap) {
					lap += 1

					continue
				}

				try {
					tries := ((lap == lastLap) ? 10 : 1)

					while (tries > 0) {
						lapPressures := this.Connector.GetSessionLapValue(session, lap, "Race Engineer Pressures")

						if (!lapPressures || (lapPressures == "")) {
							tries -= 1

							this.showMessage(translate("Waiting for data"))

							if (tries <= 0) {
								this.showMessage(translate("Give up - use default values"))

								throw "No data..."
							}
							else
								Sleep 400
						}
						else {
							this.showMessage(translate("Updating tyre pressures (Lap: ") . lap . translate(")"))

							if (getLogLevel() <= kLogInfo)
								logMessage(kLogInfo, translate("Updating tyre pressures (Lap: ") . lap . translate("), Data: `n`n") . lapPressures . "`n")

							break
						}
					}
				}
				catch exception {
					lapPressures := values2String(";", "-", "-", "-", "-", "-", "-", "-", "-", "-,-,-,-", "-,-,-,-")
				}

				lapPressures := string2Values(";", lapPressures)

				if (lapPressures[1] != "-")
					this.initializeSimulator(lapPressures[1], lapPressures[2], lapPressures[3])

				coldPressures := string2Values(",", lapPressures[9])
				hotPressures := string2Values(",", lapPressures[10])

				coldPressures := map(coldPressures, kNull)
				hotPressures := map(hotPressures, kNull)

				pressuresDB.updatePressures(lapPressures[4], lapPressures[5], lapPressures[6]
										  , lapPressures[7], lapPressures[8], coldPressures, hotPressures, flush, driverID)

				currentListView := A_DefaultListView

				try {
					Gui ListView, % this.LapsListView

					LV_Modify(this.Laps[lap].Row, "Col10", values2String(", ", string2Values(",", lapPressures[10])*))

					newData := true
					lap += 1
				}
				finally {
					Gui ListView, %currentListView%
				}
			}

			if (newData && !flush)
				pressuresDB.Database.flush()

			return newData
		}
	}

	syncPitstops(state := false) {
		local sessionStore := this.SessionStore
		local window := this.Window
		local newData := false
		local compound, currentListView, session, nextStop, lap, fuel, compound, compoundColor, tyreSet
		local pressureFL, pressureFR, pressureRL, pressureRR, repairBodywork, repairSuspension, repairEngine
		local pressures

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PitstopsListView

			session := this.SelectedSession[true]

			nextStop := (LV_GetCount() + 1)

			if !state
				try {
					state := this.Connector.GetSessionValue(session, "Race Engineer State")
				}
				catch exception {
					logError(exception)
				}

			if (state && (state != "")) {
				this.showMessage(translate("Updating pitstops"))

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Updating pitstops, State: `n`n") . state . "`n")

				state := parseConfiguration(state)

				loop {
					lap := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Lap", false)

					if lap {
						fuel := Round(getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Fuel", 0))
						compound := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Compound", false)
						compoundColor := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Compound.Color")
						tyreSet := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Set", "-")
						pressureFL := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Pressure.FL", "-")
						pressureFR := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Pressure.FR", "-")
						pressureRL := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Pressure.RL", "-")
						pressureRR := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Tyre.Pressure.RR", "-")
						repairBodywork := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Repair.Bodywork", false)
						repairSuspension := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Repair.Suspension", false)
						repairEngine := getConfigurationValue(state, "Session State", "Pitstop." . nextStop . ".Repair.Engine", false)

						if (compound && (compound != "-"))
							pressures := values2String(", ", Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
						else {
							compound := "-"
							compoundColor := false

							tyreSet := "-"
							pressures := "-, -, -, -"
						}

						Gui ListView, % this.PitstopsListView

						LV_Add("", nextStop, lap + 1, fuel, translate(compound(compound, compoundColor)), tyreSet
								 , pressures, this.computeRepairs(repairBodywork, repairSuspension, repairEngine))

						if (nextStop = 1) {
							LV_ModifyCol()

							loop % LV_GetCount("Col")
								LV_ModifyCol(A_Index, "AutoHdr")
						}

						pressures := string2Values(",", pressures)

						sessionStore.add("Pitstop.Data", {Lap: lap, Fuel: fuel, "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor, "Tyre.Set": tyreSet
														, "Tyre.Pressure.Cold.Front.Left": pressures[1], "Tyre.Pressure.Cold.Front.Right": pressures[2]
														, "Tyre.Pressure.Cold.Rear.Left": pressures[3], "Tyre.Pressure.Cold.Rear.Right": pressures[4]
														, "Repair.Bodywork": repairBodywork, "Repair.Suspension": repairSuspension
														, "Repair.Engine": repairEngine
														, Driver: this.Laps[lap].Stint.Driver.FullName})

						newData := true

						nextStop += 1

						if (this.SelectedDetailReport = "Pitstops")
							this.showPitstopsDetails()
					}
					else
						break
				}
			}
		}
		finally {
			Gui ListView, %currentListView%
		}

		return newData
	}

	syncPitstopsDetails() {
		local sessionStore := this.SessionStore
		local lastPitstop := sessionStore.Tables["Pitstop.Data"].Length()
		local newData := false
		local compound, hasServiceData, hasTyreData, lastLap, startLap, state, pitstop
		local driver, laps, compound, compoundColor, tyreSet, ignore, tyre

		if (lastPitstop != 0) {
			hasServiceData := (sessionStore.query("Pitstop.Service.Data", {Where: {Pitstop: lastPitstop}}).Length() > 0)
			hasTyreData := (sessionStore.query("Pitstop.Tyre.Data", {Where: {Pitstop: lastPitstop}}).Length() > 0)

			if (!hasServiceData || !hasTyreData) {
				lastlap := this.LastLap

				if lastLap
					lastLap := lastLap.Nr

				startLap := Max(1, sessionStore.Tables["Pitstop.Data"][lastPitstop].Lap - 1)

				loop {
					if ((startLap + A_Index) > lastLap)
						break

					if (hasServiceData && hasTyreData)
						break

					state := false

					try {
						state := this.Connector.GetLapValue(this.Laps[startLap + A_Index].Identifier, "Race Engineer Pitstop State")
					}
					catch exception {
						logError(exception)
					}

					if (state && (state != "")) {
						state := parseConfiguration(state)

						pitstop := getConfigurationValue(state, "Pitstop Data", "Pitstop", kUndefined)

						if (pitstop = lastPitstop) {
							if (!hasServiceData && (getConfigurationValue(state, "Pitstop Data", "Service.Lap", kUndefined) != kUndefined)) {
								hasServiceData := true
								newData := true

								sessionStore.add("Pitstop.Service.Data"
											   , {Pitstop: pitstop
												, Lap: getConfigurationValue(state, "Pitstop Data", "Service.Lap", false)
												, Time: getConfigurationValue(state, "Pitstop Data", "Service.Time", false)
												, "Driver.Previous": getConfigurationValue(state, "Pitstop Data", "Service.Driver.Previous", false)
												, "Driver.Next": getConfigurationValue(state, "Pitstop Data", "Service.Driver.Next", false)
												, Fuel: getConfigurationValue(state, "Pitstop Data", "Service.Refuel", 0)
												, "Tyre.Compound": getConfigurationValue(state, "Pitstop Data", "Service.Tyre.Compound", false)
												, "Tyre.Compound.Color": getConfigurationValue(state, "Pitstop Data", "Service.Tyre.Compound.Color", false)
												, "Tyre.Set": getConfigurationValue(state, "Pitstop Data", "Service.Tyre.Set", false)
												, "Tyre.Pressures": getConfigurationValue(state, "Pitstop Data", "Service.Tyre.Pressures", "")
												, "Bodywork.Repair": getConfigurationValue(state, "Pitstop Data", "Service.Bodywork.Repair", false)
												, "Suspension.Repair": getConfigurationValue(state, "Pitstop Data", "Service.Suspension.Repair", false)
												, "Engine.Repair": getConfigurationValue(state, "Pitstop Data", "Service.Engine.Repair", false)})
							}

							if (!hasTyreData && (getConfigurationValue(state, "Pitstop Data", "Tyre.Compound", kUndefined) != kUndefined)) {
								hasTyreData := true
								newData := true

								driver := getConfigurationValue(state, "Pitstop Data", "Tyre.Driver")
								laps := getConfigurationValue(state, "Pitstop Data", "Tyre.Laps", false)
								compound := getConfigurationValue(state, "Pitstop Data", "Tyre.Compound", "Dry")
								compoundColor := getConfigurationValue(state, "Pitstop Data", "Tyre.Compound.Color", "Black")
								tyreSet := getConfigurationValue(state, "Pitstop Data", "Tyre.Set", false)

								for ignore, tyre in ["Front.Left", "Front.Right", "Rear.Left", "Rear.Right"]
									sessionStore.add("Pitstop.Tyre.Data"
												   , {Pitstop: pitstop, Driver: driver, Laps: laps
													, Compound: compound, "Compound.Color": compoundColor
													, Set: tyreSet, Tyre: tyre
													, Tread: getConfigurationValue(state, "Pitstop Data", "Tyre.Tread." . tyre, "-")
													, Wear: getConfigurationValue(state, "Pitstop Data", "Tyre.Wear." . tyre, 0)
													, Grain: getConfigurationValue(state, "Pitstop Data", "Tyre.Grain." . tyre, "-")
													, Blister: getConfigurationValue(state, "Pitstop Data", "Tyre.Blister." . tyre, "-")
													, FlatSpot: getConfigurationValue(state, "Pitstop Data", "Tyre.FlatSpot." . tyre, "-")})
							}
						}
					}
				}

				if (this.SelectedDetailReport = "Pitstops")
					if (hasServiceData && hasTyreData)
						this.showPitstopsDetails()
			}
		}

		return newData
	}

	syncStrategy() {
		local strategy, session, version, fileName, configuration

		try {
			session := this.SelectedSession[true]

			version := this.Connector.GetSessionValue(session, "Race Strategy Version")

			if (version && (version != "")) {
				this.showMessage(translate("Syncing session strategy"))

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Syncing session strategy (Version: ") . version . translate(")"))

				if (!this.Strategy || !this.Strategy.Version || (version > this.Strategy.Version)) {
					strategy := this.Connector.GetSessionValue(session, "Race Strategy")

					this.showMessage(translate("Updating session strategy"))

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, translate("Updating session strategy, Strategy: `n`n") . strategy . "`n")

					this.selectStrategy((strategy = "CANCEL") ? false : this.createStrategy(parseConfiguration(strategy), false, false))
				}
			}
			else if (!this.Strategy && !this.LastLap) {
				fileName := kUserConfigDirectory . "Race.strategy"

				if FileExist(fileName) {
					configuration := readConfiguration(fileName)

					if (configuration.Count() > 0)
						this.selectStrategy(this.createStrategy(configuration, false, false), true)
				}
			}
		}
		catch exception {
			logError(exception)
		}
	}

	syncSetups() {
		local session, version, window, currentListView, info, setups

		try {
			session := this.SelectedSession[true]

			version := this.Connector.GetSessionValue(session, "Setups Version")

			if (version && (version != "")) {
				this.showMessage(translate("Syncing setups"))

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Syncing setups (Version: ") . version . translate(")"))

				window := this.Window

				Gui %window%:Default

				currentListView := A_DefaultListView

				try {
					Gui ListView, % this.SetupsListView

					if (!this.SetupsVersion || (this.SetupsVersion < version)) {
						info := this.Connector.GetSessionValue(session, "Setups Info")
						setups := this.Connector.GetSessionValue(session, "Setups")

						if (setups = "CLEAR") {
							if (this.SetupsVersion && (LV_GetCount() > 0)) {
								this.showMessage(translate("Clearing setups"))

								if (getLogLevel() <= kLogInfo)
									logMessage(kLogInfo, translate("Clearing setups, Info: `n`n") . info . "`n")

								LV_Delete()
							}
						}
						else {
							this.showMessage(translate("Updating setups"))

							if (getLogLevel() <= kLogInfo)
								logMessage(kLogInfo, translate("Updating setups, Info: `n`n") . info . translate(" `nSetups: `n`n") . setups . "`n")

							this.loadSetups(info, setups)
						}

						this.iSelectedSetup := false
					}
				}
				finally {
					Gui ListView, %currentListView%
				}
			}
		}
		catch exception {
			logError(exception)
		}
	}

	syncTeamDrivers() {
		local session, version, teamDrivers

		try {
			session := this.SelectedSession[true]

			version := this.Connector.GetSessionValue(session, "Team Drivers Version")

			if (version && (version != "")) {
				this.showMessage(translate("Syncing team drivers"))

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Syncing team drivers (Version: ") . version . translate(")"))

				if (!this.TeamDriversVersion || (this.TeamDriversVersion < version)) {
					this.iTeamDriversVersion := version

					try {
						teamDrivers := this.Connector.GetSessionValue(session, "Team Drivers")
					}
					catch exception {
						teamDrivers := ""
					}

					if (teamDrivers && (teamDrivers != ""))
						teamDrivers := string2Values("###", teamDrivers)
					else
						teamDrivers := []

					this.iTeamDrivers := teamDrivers

					GuiControl, , pitstopDriverDropDownMenu, % ("|" . values2String("|", teamDrivers*))
					GuiControl Choose, pitstopDriverDropDownMenu, % (teamDrivers.Length() > 0) ? 1 : 0
				}
			}
		}
		catch exception {
			logError(exception)
		}
	}

	syncPlan() {
		local session, version, window, currentListView, info, plan

		try {
			session := this.SelectedSession[true]

			version := this.Connector.GetSessionValue(session, "Stint Plan Version")

			if (version && (version != "")) {
				this.showMessage(translate("Syncing stint plan"))

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Syncing stint plan (Version: ") . version . translate(")"))

				window := this.Window

				Gui %window%:Default

				currentListView := A_DefaultListView

				try {
					Gui ListView, % this.PlanListView

					if (!this.PlanVersion || (this.PlanVersion < version)) {
						info := this.Connector.GetSessionValue(session, "Stint Plan Info")
						plan := this.Connector.GetSessionValue(session, "Stint Plan")

						if (plan = "CLEAR") {
							if (this.PlanVersion && (LV_GetCount() > 0)) {
								this.showMessage(translate("Clearing stint plan"))

								if (getLogLevel() <= kLogInfo)
									logMessage(kLogInfo, translate("Clearing stint plan, Info: `n`n") . info . "`n")

								LV_Delete()
							}
						}
						else {
							this.showMessage(translate("Updating stint plan"))

							if (getLogLevel() <= kLogInfo)
								logMessage(kLogInfo, translate("Updating stint plan, Info: `n`n") . info . translate(" `nPlan: `n`n") . plan . "`n")

							this.loadPlan(info, plan)
						}

						this.iSelectedPlanStint := false
					}
				}
				finally {
					Gui ListView, %currentListView%
				}
			}
		}
		catch exception {
			logError(exception)
		}
	}

	syncSession() {
		local strategy, session, window, lastLap, simulator, car, track, newLaps, newData, finished, message

		static hadLastLap := false

		if this.SessionActive {
			session := this.SelectedSession[true]
			window := this.Window

			Gui %window%:Default

			try {
				this.showMessage(translate("Syncing session"))

				if (getLogLevel() <= kLogInfo)
					logMessage(kLogInfo, translate("Syncing session"))

				try {
					lastLap := this.Connector.GetSessionLastLap(session)

					if lastLap {
						lastLap := parseObject(this.Connector.GetLap(lastLap))
						lastLap.Nr := (lastLap.Nr + 0)
					}
				}
				catch exception {
					lastLap := false
				}

				if (hadLastLap && !lastLap) {
					this.initializeSession()

					hadLastLap := false

					return
				}
				else if lastLap
					hadLastLap := true

				if !this.Simulator {
					simulator := this.Connector.GetSessionValue(session, "Simulator")
					car := this.Connector.GetSessionValue(session, "Car")
					track := this.Connector.GetSessionValue(session, "Track")

					if (simulator && (simulator != ""))
						try {
							this.initializeSimulator(simulator, car, track)
						}
						catch exception {
							logError(exception)
						}
				}

				this.syncSetups()
				this.syncTeamDrivers()
				this.syncPlan()
				this.syncStrategy()

				newLaps := false
				newData := false

				if lastLap
					newLaps := this.syncLaps(lastLap)

				if this.syncRaceReport()
					newData := true

				if this.syncTelemetry()
					newData := true

				if this.syncTyrePressures()
					newData := true

				if (newLaps && this.syncPitstops())
					newData := true

				if this.syncPitstopsDetails()
					newData := true

				if (this.LastLap && (this.SelectedReport == "Track"))
					if this.syncTrackMap()
						newData := true

				if (newData || newLaps)
					this.updateReports()

				if (!newLaps && !this.SessionFinished) {
					finished := parseObject(this.Connector.GetSession(this.SelectedSession[true])).Finished

					if (finished && (finished = "true")) {
						this.saveSession()

						this.iSessionFinished := true
					}
				}
			}
			catch exception {
				message := (IsObject(exception) ? exception.Message : exception)

				this.showMessage(translate("Cannot connect to the Team Server.") . A_Space . translate("Retry in 10 seconds."), translate("Error: ") . message)

				if (getLogLevel() <= kLogWarn)
					logMessage(kLogWarn, message)

				Sleep 2000
			}

			this.showMessage(false)
		}
	}

	updateReports() {
		if !this.SelectedReport
			this.iSelectedReport := "Overview"

		this.showReport(this.SelectedReport, true)

		if (!this.SelectedDetailReport && this.Strategy)
			this.StrategyViewer.showStrategyInfo(this.Strategy)
	}

	getCar(lap, car, ByRef carNumber, ByRef carName, ByRef driverForname, ByRef driverSurname, ByRef driverNickname) {
		this.ReportViewer.getCar(lap.Nr, car, carNumber, carName, driverForname, driverSurname, driverNickname)
	}

	getStandings(lap, ByRef cars, ByRef positions, ByRef carNumbers, ByRef carNames, ByRef driverFornames, ByRef driverSurnames, ByRef driverNicknames) {
		local tCars := true
		local tPositions := true
		local tCarNumbers := carNumbers
		local tCarNames := carNames
		local tDriverFornames := driverFornames
		local tDriverSurnames := driverSurnames
		local tDriverNicknames := driverNicknames
		local index

		this.ReportViewer.getStandings(lap.Nr, tCars, tPositions, tCarNumbers, tCarNames, tDriverFornames, tDriverSurnames, tDriverNicknames)

		if cars
			cars := []

		if positions
			positions := []

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

		if (tCars.Length() > 0)
			loop % tPositions.Length()
			{
				index := inList(tPositions, A_Index)

				if cars
					cars.Push(tCars[index])

				if positions
					positions.Push(tPositions[index])

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
			}
	}

	computeDuration(stint) {
		local duration, duration, ignore, lap

		if stint.Duration
			return stint.Duration
		else {
			duration := 0

			for ignore, lap in stint.Laps
				duration += lap.LapTime

			if (stint != this.CurrentStint)
				stint.Duration := duration

			return duration
		}
	}

	computeStartTime(stint) {
		local time, lastStint, duration, ignore, lap

		if stint.Time
			return stint.Time
		else {
			if (stint.Nr = 1) {
				stint.Time := (A_Now . "")

				time := stint.Time
			}
			else {
				lastStint := this.Stints[stint.Nr - 1]
				duration := 0

				for ignore, lap in lastStint.Laps
					duration += lap.LapTime

				time := this.computeStartTime(lastStint)

				EnvAdd time, %duration%, Seconds
			}

			if (stint != this.CurrentStint)
				stint.Time := time

			return time
		}
	}

	computeLapStatistics(driver, laps, ByRef potential, ByRef raceCraft, ByRef speed, ByRef consistency, ByRef carControl) {
		local raceData := true
		local drivers := false
		local positions := true
		local times := true
		local car, cars, potentials, raceCrafts, speeds, consistencies, carControls, count, oldLapSettings

		this.ReportViewer.loadReportData(laps, raceData, drivers, positions, times)

		car := getConfigurationValue(raceData, "Cars", "Driver", false)

		if car {
			cars := []

			loop % getConfigurationValue(raceData, "Cars", "Count")
				cars.Push(A_Index)

			potentials := false
			raceCrafts := false
			speeds := false
			consistencies := false
			carControls := false

			count := laps.Length()
			laps := []

			loop %count%
				laps.Push(A_Index)

			oldLapSettings := (this.ReportViewer.Settings.HasKey("Laps") ? this.ReportViewer.Settings["Laps"] : false)

			try {
				this.ReportViewer.Settings["Laps"] := laps

				this.ReportViewer.getDriverStatistics(raceData, cars, positions, times, potentials, raceCrafts, speeds, consistencies, carControls)
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

	updateStintStatistics(stint) {
		local laps := []
		local ignore, lap, potential, raceCraft, speed, consistency, carControl

		for ignore, lap in stint.Laps
			laps.Push(lap.Nr)

		potential := false
		raceCraft := false
		speed := false
		consistency := false
		carControl := false

		this.computeLapStatistics(stint.Driver, laps, potential, raceCraft, speed, consistency, carControl)

		stint.Potential := potential
		stint.RaceCraft := raceCraft
		stint.Speed := speed
		stint.Consistency := consistency
		stint.CarControl := carControl
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

		this.computeLapStatistics(driver, laps, potential, raceCraft, speed, consistency, carControl)

		driver.Potential := potential
		driver.RaceCraft := raceCraft
		driver.Speed := speed
		driver.Consistency := consistency
		driver.CarControl := carControl
	}

	manageTeam() {
		this.pushTask(ObjBindMethod(this, "manageTeamAsync"))
	}

	manageTeamAsync() {
		local teamDrivers := manageTeam(this, (this.TeamDrivers.Length() = 0) ? removeDuplicates(getValues(this.getPlanDrivers()))
																			  : this.TeamDrivers)
		local window, session, version, ignore, driver, nr, name

		if teamDrivers {
			if this.SessionActive {
				session := this.SelectedSession[true]

				version := (A_Now . "")

				this.iTeamDriversVersion := version

				this.Connector.setSessionValue(session, "Team Drivers Version", version)
				this.Connector.SetSessionValue(session, "Team Drivers", values2String("###", teamDrivers*))
			}

			this.iTeamDrivers := teamDrivers

			for ignore, driver in this.Drivers
				driver.Nr := false

			for nr, name in teamDrivers
				for ignore, driver in this.Drivers
					if (driver.FullName = name)
						driver.Nr := nr

			window := this.Window

			Gui %window%:Default

			GuiControl, , pitstopDriverDropDownMenu, % ("|" . values2String("|", teamDrivers*))
			GuiControl Choose, pitstopDriverDropDownMenu, % (teamDrivers.Length() > 0) ? 1 : 0
		}
	}

	updateStatistics() {
		this.pushTask(ObjBindMethod(this, "updateStatisticsAsync"))
	}

	updateStatisticsAsync() {
		local x := Round((A_ScreenWidth - 300) / 2)
		local y := A_ScreenHeight - 150
		local progressWindow := showProgress({x: x, y: y, color: "Green", title: translate("Updating Stint Statistics")})
		local currentStint := this.CurrentStint
		local count, stint, window, currentListView, ignore, driver

		if currentStint {
			count := currentStint.Nr

			loop %count% {
				showProgress({progress: Round((A_Index / count) * 50), color: "Green", message: translate("Stint: ") . A_Index})

				if this.Stints.HasKey(A_Index) {
					stint := this.Stints[A_Index]

					this.updateStintStatistics(stint)

					window := this.Window

					Gui %window%:Default

					currentListView := A_DefaultListView

					try {
						Gui ListView, % this.StintsListView

						LV_Modify(stint.Row, "Col11", stint.Potential, stint.RaceCraft, stint.Speed, stint.Consistency, stint.CarControl)
					}
					finally {
						Gui ListView, %currentListView%
					}
				}

				Sleep 200
			}
		}

		showProgress({title: translate("Updating Driver Statistics"), message: translate("...")})

		count := this.Drivers.Length()

		for ignore, driver in this.Drivers {
			showProgress({progress: 50 + Round((A_Index / count) * 50), color: "Green", message: translate("Driver: ") . driver.FullName})

			this.updateDriverStatistics(driver)

			Sleep 200
		}

		hideProgress()
	}

	saveSetups(flush := false) {
		local sessionStore := this.SessionStore
		local compound, window, currentListView, driver, conditions, compound, pressures, temperatures, compoundColor

		sessionStore.clear("Setups.Data")

		window := this.Window

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.SetupsListView

			loop % LV_GetCount()
			{
				LV_GetText(driver, A_Index, 1)
				LV_GetText(conditions, A_Index, 2)
				LV_GetText(compound, A_Index, 3)
				LV_GetText(pressures, A_Index, 4)

				conditions := string2Values(translate("("), conditions)
				temperatures := string2Values(", ", StrReplace(conditions[2], translate(")"), ""))

				compoundColor := false

				splitCompound(this.TyreCompounds[inList(map(this.TyreCompounds, "translate"), compound)]
							, compound, compoundColor)

				pressures := string2Values(",", pressures)

				sessionStore.add("Setups.Data", {Driver: driver
											   , Weather: kWeatherConditions[inList(map(kWeatherConditions, "translate"), conditions[1])]
											   , "Temperature.Air": temperatures[1], "Temperature.Track": temperatures[2]
											   , "Tyre.Compound": compound, "Tyre.Compound.Color": compoundColor
											   , "Tyre.Pressure.Front.Left": pressures[1], "Tyre.Pressure.Front.Right": pressures[2]
											   , "Tyre.Pressure.Rear.Left": pressures[3], "Tyre.Pressure.Rear.Right": pressures[4]})
			}
		}
		finally {
			Gui ListView, %currentListView%
		}

		if flush
			sessionStore.flush("Setups.Data")
	}

	savePlan(flush := false) {
		local sessionStore := this.SessionStore
		local window := this.Window
		local currentListView, stint, driver, timePlanned, timeActual, lapPlanned, lapActual, refuelAmount, tyreChange

		sessionStore.clear("Plan.Data")

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PlanListView

			loop % LV_GetCount()
			{
				LV_GetText(stint, A_Index, 1)
				LV_GetText(driver, A_Index, 2)
				LV_GetText(timePlanned, A_Index, 3)
				LV_GetText(timeActual, A_Index, 4)
				LV_GetText(lapPlanned, A_Index, 5)
				LV_GetText(lapActual, A_Index, 6)
				LV_GetText(refuelAmount, A_Index, 7)
				LV_GetText(tyreChange, A_Index, 8)

				sessionStore.add("Plan.Data", {Stint: stint, Driver: driver
											 , "Time.Planned": timePlanned, "Time.Actual": timeActual
											 , "Lap.Planned": lapPlanned, "Lap.Actual": lapActual
											 , "Fuel.Amount": refuelAmount, "Tyre.Change": tyreChange})
			}
		}
		finally {
			Gui ListView, %currentListView%
		}

		if flush
			sessionStore.flush("Plan.Data")
	}

	saveSession(copy := false) {
		this.pushTask(ObjBindMethod(this, "saveSessionAsync", copy))
	}

	saveSessionAsync(copy := false) {
		local info, directory, title, folder, session

		if this.SessionActive {
			this.syncSessionStore(true)

			info := newConfiguration()

			setConfigurationValue(info, "Session", "Team", this.SelectedTeam)
			setConfigurationValue(info, "Session", "Session", this.SelectedSession)
			setConfigurationValue(info, "Session", "Date", this.Date)
			setConfigurationValue(info, "Session", "Time", this.Time)
			setConfigurationValue(info, "Session", "Simulator", this.Simulator)
			setConfigurationValue(info, "Session", "Car", this.Car)
			setConfigurationValue(info, "Session", "Track", this.Track)

			setConfigurationValue(info, "Weather", "Weather", this.Weather)
			setConfigurationValue(info, "Weather", "Weather10Min", this.Weather10Min)
			setConfigurationValue(info, "Weather", "Weather30Min", this.Weather30Min)
			setConfigurationValue(info, "Weather", "AirTemperature", this.AirTemperature)
			setConfigurationValue(info, "Weather", "TrackTemperature", this.TrackTemperature)

			writeConfiguration(this.SessionDirectory . "Session.info", info)
		}
		else {
			this.saveSetups()
			this.savePlan()

			this.SessionStore.flush()
		}

		if copy {
			directory := (this.SessionLoaded ? this.SessionLoaded : this.SessionDirectory)

			title := translate("Select target folder...")

			Gui +OwnDialogs

			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Select", "Cancel"]))
			FileSelectFolder folder, *%directory%, 0, %title%
			OnMessage(0x44, "")

			if (folder != "") {
				session := this.SelectedSession

				FileCopyDir %directory%, %folder%\%session%, 1
			}
		}
	}

	loadDrivers() {
		local ignore, driver

		this.iDrivers := []

		for ignore, driver in this.SessionStore.Tables["Driver.Data"]
			this.createDriver({Forname: driver.Forname, Surname: driver.Surname, Nickname: driver.Nickname
							 , Fullname: computeDriverName(driver.Forname, driver.Surname, driver.Nickname)
							 , Nr: driver.Nr, ID: driver.ID})
	}

	loadLaps() {
		local ignore, lap, newLap, engineDamage

		this.iLaps := []

		for ignore, lap in this.SessionStore.Tables["Lap.Data"] {
			newLap := {Nr: lap.Nr, Stint: lap.Stint, Laptime: lap["Lap.Time"], Position: lap.Position, Grip: lap.Grip
					 , Map: lap.Map, TC: lap.TC, ABS: lap.ABS
					 , Weather: lap.Weather, AirTemperature: lap["Temperature.Air"], TrackTemperature: lap["Temperature.Track"]
					 , FuelRemaining: lap["Fuel.Remaining"], FuelConsumption: lap["Fuel.Consumption"]
					 , Damage: lap.Damage, EngineDamage: lap.EngineDamage, Accident: lap.Accident
					 , Compound: compound(lap["Tyre.Compound"], lap["Tyre.Compoiund.Color"])}

			if (isNull(newLap.Map))
				newLap.Map := "n/a"

			if (isNull(newLap.TC))
				newLap.TC := "n/a"

			if (isNull(newLap.ABS))
				newLap.ABS := "n/a"

			if (isNull(newLap.EngineDamage))
				newLap.EngineDamage := 0

			if (isNull(newLap.Position))
				newLap.Position := "-"

			if (isNull(newLap.Laptime))
				newLap.Laptime := "-"

			if (isNull(newLap.FuelConsumption))
				newLap.FuelConsumption := "-"

			if (isNull(newLap.FuelRemaining))
				newLap.FuelRemaining := "-"

			if (isNull(newLap.AirTemperature))
				newLap.AirTemperature := "-"

			if (isNull(newLap.TrackTemperature))
				newLap.TrackTemperature := "-"

			this.Laps[newLap.Nr] := newLap
			this.iLastLap := newLap
		}
	}

	loadStints() {
		local ignore, stint, newStint, driver, laps, lap, stintNr, stintLap, airTemperatures, trackTemperatures
		local window, currentListView, currentStint, lastLap

		this.iStints := []

		for ignore, stint in this.SessionStore.Tables["Stint.Data"] {
			driver := this.createDriver({Forname: stint["Driver.Forname"], Surname: stint["Driver.Surname"], Nickname: stint["Driver.Nickname"], ID: stint.ID})

			newStint := {Nr: stint.Nr, Lap: stint.Lap, Driver: driver
					   , Weather: stint.Weather, Compound: stint.Compound, AvgLaptime: stint["Lap.Time.Average"], BestLaptime: stint["Lap.Time.Best"]
					   , FuelConsumption: stint["Fuel.Consumption"], Accidents: stint.Accidents
					   , StartPosition: stint["Position.Start"], EndPosition: stint["Position.End"]
					   , Time: stint["Time.Start"]}

			if (isNull(newStint.Time))
				newStint.Time := false

			driver.Stints.Push(newStint)
			laps := []

			newStint.Laps := laps

			stintNr := newStint.Nr
			stintLap := newStint.Lap

			airTemperatures := []
			trackTemperatures := []

			loop {
				if !this.Laps.HasKey(stintLap)
					break

				lap := this.Laps[stintLap]

				airTemperatures.Push(lap.AirTemperature)
				trackTemperatures.Push(lap.TrackTemperature)

				if IsObject(lap.Stint)
					newStint.Lap := (stintLap + 1)
				else
					if (lap.Stint != stintNr)
						break
					else {
						lap.Stint := newStint
						laps.Push(lap)

						driver.Laps.Push(lap)
					}

				stintLap += 1
			}

			newStint.AirTemperature := Round(average(airTemperatures), 1)
			newStint.TrackTemperature := Round(average(trackTemperatures), 1)

			newStint.Potential := "-"
			newStint.RaceCraft := "-"
			newStint.Speed := "-"
			newStint.Consistency := "-"
			newStint.CarControl := "-"

			if (isNull(newStint.AvgLaptime))
				newStint.AvgLaptime := "-"

			if (isNull(newStint.BestLaptime))
				newStint.BestLaptime := "-"

			if (isNull(newStint.FuelConsumption))
				newStint.FuelConsumption := "-"

			if (isNull(newStint.StartPosition))
				newStint.StartPosition := "-"

			if (isNull(newStint.EndPosition))
				newStint.EndPosition := "-"

			this.Stints[newStint.Nr] := newStint

			this.iCurrentStint := newStint

			this.updatePlan(newStint)
		}

		window := this.Window

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.StintsListView

			currentStint := this.CurrentStint

			if currentStint
				loop % currentStint.Nr
					if this.Stints.HasKey(A_Index) {
						stint := this.Stints[A_Index]
						stint.Row := (LV_GetCount() + 1)

						Gui ListView, % this.StintsListView

						LV_Add("", stint.Nr, stint.Driver.FullName, values2String(", ", map(string2Values(",", stint.Weather), "translate")*)
								 , translate(stint.Compound), stint.Laps.Length()
								 , stint.StartPosition, stint.EndPosition, lapTimeDisplayValue(stint.AvgLaptime), stint.FuelConsumption, stint.Accidents
								 , stint.Potential, stint.RaceCraft, stint.Speed, stint.Consistency, stint.CarControl)
					}

			LV_ModifyCol()

			loop % LV_GetCount("Col")
				LV_ModifyCol(A_Index, "AutoHdr")

			Gui ListView, % this.LapsListView

			lastLap := this.LastLap

			if lastLap
				loop % lastLap.Nr
					if this.Laps.HasKey(A_Index) {
						lap := this.Laps[A_Index]
						lap.Row := (LV_GetCount() + 1)

						Gui ListView, % this.LapsListView

						LV_Add("", lap.Nr, lap.Stint.Nr, lap.Stint.Driver.FullName, lap.Position, translate(lap.Weather), translate(lap.Grip), lapTimeDisplayValue(lap.Laptime), displayValue(lap.FuelConsumption), lap.FuelRemaining, "", lap.Accident ? translate("x") : "")
					}

			LV_ModifyCol()

			loop % LV_GetCount("Col")
				LV_ModifyCol(A_Index, "AutoHdr")
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	loadSetups(info := false, setups := false) {
		local window := this.Window
		local currentListView, fileName, ignore, setup, conditions

		Gui %window%:Default

		if info {
			info := parseConfiguration(info)

			this.iSetupsVersion := getConfigurationValue(info, "Setups", "Version")
		}

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.SetupsListView

			LV_Delete()

			this.iSelectedSetup := false

			if setups {
				fileName := (this.SessionDirectory . "Setups.Data.CSV")

				deleteFile(fileName)

				FileAppend %setups%, %fileName%, UTF-16

				this.SessionStore.reload("Setups.Data", false)
			}

			for ignore, setup in this.SessionStore.Tables["Setups.Data"] {
				Gui ListView, % this.SetupsListView

				conditions := (translate(setup.Weather) . A_Space
							 . translate("(") . translate(setup["Temperature.Air"]) . ", " . translate(setup["Temperature.Track"]) . translate(")"))

				LV_Add("", setup.Driver, conditions
						 , translate(compound(setup["Tyre.Compound"], setup["Tyre.Compound.Color"]))
						 , values2String(", ", setup["Tyre.Pressure.Front.Left"], setup["Tyre.Pressure.Front.Right"]
											 , setup["Tyre.Pressure.Rear.Left"], setup["Tyre.Pressure.Rear.Right"]))
			}

			LV_ModifyCol()

			loop % LV_GetCount("Col")
				LV_ModifyCol(A_Index, "AutoHdr")

			if (this.SelectedDetailReport = "Setups")
				this.showSetupsDetails()
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	loadPlan(info := false, plan := false) {
		local window := this.Window
		local currentListView, fileName, ignore

		Gui %window%:Default

		if info {
			info := parseConfiguration(info)

			this.iPlanVersion := getConfigurationValue(info, "Plan", "Version")
			this.iDate := getConfigurationValue(info, "Plan", "Date")
			this.iTime := getConfigurationValue(info, "Plan", "Time")

			GuiControl, , sessionDateCal, % this.Date
			GuiControl, , sessionTimeEdit, % this.Time
		}

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PlanListView

			LV_Delete()

			this.iSelectedPlanStint := false

			if plan {
				fileName := (this.SessionDirectory . "Plan.Data.CSV")

				deleteFile(fileName)

				FileAppend %plan%, %fileName%, UTF-16

				this.SessionStore.reload("Plan.Data", false)
			}

			for ignore, plan in this.SessionStore.Tables["Plan.Data"] {
				Gui ListView, % this.PlanListView

				LV_Add("", plan.Stint, plan.Driver, plan["Time.Planned"], plan["Time.Actual"]
						 , plan["Lap.Planned"], plan["Lap.Actual"]
						 , plan["Fuel.Amount"], plan["Tyre.Change"])
			}

			LV_ModifyCol()

			loop % LV_GetCount("Col")
				LV_ModifyCol(A_Index, "AutoHdr")

			if (this.SelectedDetailReport = "Plan")
				this.showPlanDetails()
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	loadPitstops() {
		local window := this.Window
		local currentListView, ignore, pitstop, repairBodywork, repairSuspension, repairEngine, pressures

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PitstopsListView

			for ignore, pitstop in this.SessionStore.Tables["Pitstop.Data"] {
				repairBodywork := pitstop["Repair.Bodywork"]
				repairSuspension := pitstop["Repair.Suspension"]
				repairEngine := pitstop["Repair.Engine"]
				pressures := values2String(", ", pitstop["Tyre.Pressure.Cold.Front.Left"], pitstop["Tyre.Pressure.Cold.Front.Right"]
											   , pitstop["Tyre.Pressure.Cold.Rear.Left"], pitstop["Tyre.Pressure.Cold.Rear.Right"])

				Gui ListView, % this.PitstopsListView

				LV_Add("", A_Index, pitstop.Lap + 1, pitstop.Fuel
						 , translate(compound(pitstop["Tyre.Compound"], pitstop["Tyre.Compound.Color"]))
						 , pitstop["Tyre.Set"], pressures
						 , this.computeRepairs(repairBodywork, repairSuspension, repairEngine))
			}

			LV_ModifyCol()

			loop % LV_GetCount("Col")
				LV_ModifyCol(A_Index, "AutoHdr")
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	clearSession() {
		this.pushTask(ObjBindMethod(this, "clearSessionAsync"))
	}

	clearSessionAsync() {
		local session := this.SelectedSession[true]

		if session {
			try {
				this.Connector.ClearSession(session)
			}
			catch exception {
				logError(exception)
			}

			this.initializeSession()
		}
	}

	loadSession() {
		this.pushTask(ObjBindMethod(this, "loadSessionAsync"))
	}

	loadSessionAsync() {
		local title := translate("Select Session folder...")
		local directory := (this.SessionLoaded ? this.SessionLoaded : this.iSessionDirectory)
		local folder, info, window, lastLap, currentStint

		Gui +OwnDialogs

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Select", "Cancel"]))
		FileSelectFolder folder, *%directory%, 0, %title%
		OnMessage(0x44, "")

		if (folder != "") {
			folder := (folder . "\")

			info := readConfiguration(folder . "Session.info")

			if (info.Count() == 0) {
				title := translate("Error")

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				MsgBox 262160, %title%, % translate("This is not a valid folder with a saved session.")
				OnMessage(0x44, "")
			}
			else {
				this.iSyncTask.pause()

				this.iConnected := false

				this.initializeSession()

				this.iSessionLoaded := folder

				this.iTeamName := getConfigurationValue(info, "Session", "Team")
				this.iTeamIdentifier := false

				this.iSessionName := getConfigurationValue(info, "Session", "Session")
				this.iSessionIdentifier := false

				this.iDate := getConfigurationValue(info, "Session", "Date", A_Now)
				this.iTime := getConfigurationValue(info, "Session", "Time", A_Now)

				this.iWeather := getConfigurationValue(info, "Weather", "Weather", false)
				this.iWeather10Min := getConfigurationValue(info, "Weather", "Weather10Min", false)
				this.iWeather30Min := getConfigurationValue(info, "Weather", "Weather30Min", false)
				this.iAirTemperature := getConfigurationValue(info, "Weather", "AirTemperature", false)
				this.iTrackTemperature := getConfigurationValue(info, "Weather", "TrackTemperature", false)

				window := this.Window

				Gui %window%:Default

				GuiControl, , sessionDateCal, % this.Date
				GuiControl, , sessionTimeEdit, % this.Time

				GuiControl, , teamDropDownMenu, % "|" . this.iTeamName
				GuiControl Choose, teamDropDownMenu, 1

				GuiControl, , sessionDropDownMenu, % "|" . this.iSessionName
				GuiControl Choose, sessionDropDownMenu, 1

				this.loadDrivers()
				this.loadSessionDrivers()
				this.loadSetups()
				this.loadPlan()
				this.loadLaps()
				this.loadStints()
				this.loadPitstops()

				this.syncTelemetry(true)
				this.syncTyrePressures(true)

				this.ReportViewer.setReport(folder . "Race Report")

				this.initializeReports()

				if !this.Weather {
					lastLap := this.LastLap

					if lastLap {
						this.iWeather := lastLap.Weather
						this.iAirTemperature := lastLap.AirTemperature
						this.iTrackTemperature := lastLap.TrackTemperature

						if lastLap.HasKey("Weather10Min") {
							this.iWeather10Min := lastLap.Weather10Min
							this.iWeather30Min := lastLap.Weather30Min
						}
						else {
							this.iWeather10Min := lastLap.Weather
							this.iWeather30Min := lastLap.Weather
						}
					}
				}

				if !this.TyreCompound {
					currentStint := this.CurrentStint

					if currentStint {
						this.iTyreCompound := compound(currentStint.Compound)
						this.iTyreCompoundColor := compoundColor(currentStint.Compound)
					}
				}

				this.updateReports()

				this.updateState()
			}
		}
	}

	show() {
		local window := this.Window
		local x, y

		if getWindowPosition("Race Center", x, y)
			Gui %window%:Show, x%x% y%y%
		else
			Gui %window%:Show

		while !this.iClosed
			Sleep 1000

		this.iSyncTask.pause()
	}

	close() {
		this.iClosed := true
	}

	showChart(drawChartFunction) {
		local window := this.Window
		local width, height, before, after, html

		Gui %window%:Default

		chartViewer.Document.Open()

		width := (chartViewer.Width - 5)
		height := (chartViewer.Height - 5)

		if (drawChartFunction && (drawChartFunction != "")) {
			before =
			(
			<html>
			    <meta charset='utf-8'>
				<head>
					<style>
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: 'FFFFFF'; }
						.rowStyle { font-size: 11px; background-color: 'E0E0E0'; }
						.oddRowStyle { font-size: 11px; background-color: 'E8E8E8'; }
					</style>
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawChart);
			)

			after =
			(
					</script>
				</head>
				<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'>
					<div id="chart_id" style="width: %width%px; height: %height%px"></div>
				</body>
			</html>
			)

			html := (before . drawChartFunction . after)

			chartViewer.Document.Write(html)
		}
		else {
			html := "<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>"

			chartViewer.Document.Write(html)
		}

		chartViewer.Document.Close()
	}

	showDataPlot(data, xAxis, yAxises) {
		local double := (yAxises.Length() > 1)
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

		settingsLaps := this.ReportViewer.Settings["Laps"]
		laps := false

		if (settingsLaps && (settingsLaps.Length() > 0)) {
			laps := {}

			for ignore, lap in settingsLaps
				laps[lap] := lap
		}

		drawChartFunction .= "`ndata.addRows(["
		first := true

		for ignore, values in data {
			if (laps && !laps.HasKey(A_Index))
				continue

			if this.SelectedDrivers
				if !inList(this.SelectedDrivers, this.Stints[values.Stint].Driver.ID)
					continue

			if !first
				drawChartFunction .= ",`n"

			first := false
			value := values[xAxis]

			if ((value = "n/a") || (isNull(value)))
				value := kNull

			if (this.SelectedChartType = "Bubble")
				drawChartFunction .= ("['', " . value)
			else
				drawChartFunction .= ("[" . value)

			for ignore, yAxis in yAxises {
				value := values[yAxis]

				if ((value = "n/a") || (isNull(value)))
					value := kNull
				else {
					minValue := ((minValue == kUndefined) ? value : Min(minValue, value))
					maxValue := ((maxValue == kUndefined) ? value : Max(maxValue, value))
				}

				drawChartFunction .= (", " . value)
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
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8', hAxis: { title: '" . translate(xAxis) . "' }, " . series . ", " . vAxis . "};")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.ScatterChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bar") {
			if (minValue == kUndefined)
				minValue := 0
			else
				minValue := Min(0, minValue)

			if (maxValue == kUndefined)
				maxValue := 0

			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8', hAxis: { viewWindow: {min: " . minValue . ", max: " . maxValue . "} }, vAxis: { viewWindowMode: 'pretty' } };")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Bubble") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8', hAxis: { title: '" . translate(xAxis) . "', viewWindowMode: 'pretty' }, vAxis: { title: '" . translate(yAxises[1]) . "', viewWindowMode: 'pretty' }, colorAxis: { legend: {position: 'none'}, colors: ['blue', 'red'] }, sizeAxis: { maxSize: 15 } };")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BubbleChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}
		else if (this.SelectedChartType = "Line") {
			drawChartFunction .= ("`nvar options = { legend: {position: 'bottom'}, chartArea: { left: '10%', right: '10%', top: '10%', bottom: '30%' }, backgroundColor: '#D8D8D8' };")

			drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.LineChart(document.getElementById('chart_id')); chart.draw(data, options); }"
		}

		this.showChart(drawChartFunction)
	}

	showDetails(report, details, charts*) {
		local chartID := 1
		local html := (details ? details : "")
		local tableCSS, script, ignore, chart

		this.iSelectedDetailReport := report

		if details {
			tableCSS := getTableCSS()

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
					<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
					<script type="text/javascript">
						google.charts.load('current', {'packages':['corechart', 'table', 'scatter']}).then(drawCharts);

						function drawCharts() {
			)

			for ignore, chart in charts
				script .= (A_Space . "drawChart" . chart[1] . "();")

			script .= "}`n"

			for ignore, chart in charts {
				if (A_Index > 0)
					script .= . "`n"

				script .= chart[2]
			}

			script .= "</script></head>"
		}
		else
			script := ""

		html := ("<html>" . script . "<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #header { font-size: 12px; } </style><div>" . html . "</div></body></html>")

		detailsViewer.Document.Open()
		detailsViewer.Document.Write(html)
		detailsViewer.Document.Close()
	}

	selectReport(report) {
		local currentListView := A_DefaultListView

		try {
			Gui ListView, % reportsListView

			if report {
				LV_Modify(inList(kSessionReports, report), "+Select")

				this.iSelectedReport := report
			}
			else {
				loop % LV_GetCount()
					LV_Modify(A_Index, "-Select")

				this.iSelectedReport := false
			}
		}
		finally {
			Gui ListView, %currentListView%
		}
	}

	showOverviewReport() {
		this.selectReport("Overview")

		this.ReportViewer.showOverviewReport()

		this.updateState()
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
		return this.ReportViewer.editReportSettings("Laps", "Drivers")
	}

	showPositionsReport() {
		this.selectReport("Positions")

		this.ReportViewer.showPositionsReport()

		this.updateState()
	}

	editPositionsReportSettings() {
		return this.ReportViewer.editReportSettings("Laps")
	}

	showLapTimesReport() {
		this.selectReport("Lap Times")

		this.ReportViewer.showLapTimesReport()

		this.updateState()
	}

	editLapTimesReportSettings() {
		return this.ReportViewer.editReportSettings("Laps", "Cars")
	}

	showConsistencyReport() {
		this.selectReport("Consistency")

		this.ReportViewer.showConsistencyReport()

		this.updateState()
	}

	editConsistencyReportSettings() {
		return this.ReportViewer.editReportSettings("Laps", "Cars")
	}

	showPaceReport() {
		this.selectReport("Pace")

		this.ReportViewer.showPaceReport()

		this.updateState()
	}

	editPaceReportSettings() {
		return this.ReportViewer.editReportSettings("Laps", "Cars")
	}

	showTrackMap() {
		local html := false
		local lastLap := this.LastLap
		local hasLeader := false
		local hasAhead := false
		local hasBehind := false
		local sessionDB, trackMap, fileName, width, height, scale, offsetX, offsetY, marginX, marginY
		local imgWidth, imgHeight, imgScale, telemetry, positions, token, bitmap, graphics, brushCar, brushGray
		local carIndices, driverIndex, driverID, driverPosition, leaderBrush, aheadBrush, behindBrush
		local r, coordinates, carID, carIndex, carPosition, x, y, brush
		local imageAreaWidth, hWidth, tableCSS, script

		this.initializeReport()

		if this.Simulator {
			sessionDB := new SessionDatabase()

			trackMap := sessionDB.getTrackMap(this.Simulator, this.Track)
			fileName := sessionDB.getTrackImage(this.Simulator, this.Track)

			if (trackMap && fileName) {
				width := chartViewer.Width
				height := chartViewer.Height

				scale := getConfigurationValue(trackMap, "Map", "Scale")

				offsetX := getConfigurationValue(trackMap, "Map", "Offset.X")
				offsetY := getConfigurationValue(trackMap, "Map", "Offset.Y")
				marginX := getConfigurationValue(trackMap, "Map", "Margin.X")
				marginY := getConfigurationValue(trackMap, "Map", "Margin.Y")

				imgWidth := ((getConfigurationValue(trackMap, "Map", "Width") + (2 * marginX)) * scale)
				imgHeight := ((getConfigurationValue(trackMap, "Map", "Height") + (2 * marginY)) * scale)

				imgScale := Min(width / imgWidth, height / imgHeight)

				if (this.SessionActive && lastLap) {
					telemetry := lastLap.Telemetry
					positions := lastLap.Positions

					if telemetry {
						telemetry := parseConfiguration(telemetry)

						if positions
							positions := parseConfiguration(positions)

						token := Gdip_Startup()

						bitmap := Gdip_CreateBitmapFromFile(fileName)

						graphics := Gdip_GraphicsFromImage(bitmap)

						Gdip_SetSmoothingMode(graphics, 4)

						brushCar := Gdip_BrushCreateSolid(0xff000000)
						brushGray := Gdip_BrushCreateSolid(0xffBBBBBB)

						carIndices := {}

						if positions {
							loop % getConfigurationValue(positions, "Position Data", "Car.Count")
								carIndices[getConfigurationValue(positions, "Position Data", "Car." . A_Index . ".ID", A_Index)] := A_Index

							driverIndex := getConfigurationValue(positions, "Position Data", "Driver.Car", 0)
							driverID := getConfigurationValue(positions, "Position Data", "Car." . driverIndex . ".ID", driverIndex)
							driverPosition := getConfigurationValue(positions, "Position Data", "Car." . driverIndex . ".Position", 0)

							leaderBrush := Gdip_BrushCreateSolid(0xff0000ff)
							aheadBrush := Gdip_BrushCreateSolid(0xff006400)
							behindBrush := Gdip_BrushCreateSolid(0xffff0000)
						}
						else {
							driverIndex := false
							driverID := false
							driverPosition := false
						}

						r := Round(15 / (imgScale * 3))

						loop {
							coordinates := getConfigurationValue(telemetry, "Track Data", "Car." . A_Index . ".Position", false)

							if coordinates {
								carID := getConfigurationValue(telemetry, "Track Data", "Car." . A_Index . ".ID", A_Index)

								if (carID = driverID)
									continue

								carIndex := (carIndices.HasKey(carID) ? carIndices[carID] : false)

								coordinates := string2Values(",", coordinates)

								x := Round((marginX + offsetX + coordinates[1]) * scale)
								y := Round((marginX + offsetY + coordinates[2]) * scale)

								brush := brushGray

								if (!hasLeader && positions && driverPosition && carIndex) {
									carPosition := getConfigurationValue(positions, "Position Data", "Car." . carIndex . ".Position", 0)

									if ((carPosition == 1) && (driverPosition != 1)) {
										brush := leaderBrush

										hasLeader := true
									}
								}

								if (!hasAhead && positions && driverPosition && carIndex) {
									carPosition := getConfigurationValue(positions, "Position Data", "Car." . carIndex . ".Position", 0)

									if ((carPosition + 1) = driverPosition) {
										brush := aheadBrush

										hasAhead := true
									}
								}

								if (!hasBehind && positions && driverPosition && carIndex) {
									carPosition := getConfigurationValue(positions, "Position Data", "Car." . carIndex . ".Position", 0)

									if ((carPosition - 1) = driverPosition) {
										brush := behindBrush

										hasBehind := true
									}
								}

								Gdip_FillEllipse(graphics, brush, x - r, y - r, r * 2, r * 2)
							}
							else
								break
						}

						loop
							if (driverID = getConfigurationValue(telemetry, "Track Data", "Car." . A_Index . ".ID", A_Index)) {
								coordinates := getConfigurationValue(telemetry, "Track Data", "Car." . A_Index . ".Position", false)

								if coordinates {
									coordinates := string2Values(",", coordinates)

									x := Round((marginX + offsetX + coordinates[1]) * scale)
									y := Round((marginX + offsetY + coordinates[2]) * scale)

									Gdip_FillEllipse(graphics, brushCar, x - r, y - r, r * 2, r * 2)
								}

								break
							}

						Gdip_DeleteBrush(brushGray)
						Gdip_DeleteBrush(brushCar)

						if driverPosition {
							Gdip_DeleteBrush(leaderBrush)
							Gdip_DeleteBrush(aheadBrush)
							Gdip_DeleteBrush(behindBrush)
						}

						fileName := (kTempDirectory . "TrackMap.png")

						Gdip_SaveBitmapToFile(bitmap, fileName)

						Gdip_DisposeImage(bitmap)

						Gdip_DeleteGraphics(graphics)

						Gdip_Shutdown(token)
					}
				}

				imgWidth *= imgScale
				imgHeight *= imgScale

				scale := 0.99

				imgAreaWidth := (width / 2)

				while (imgWidth > imgAreaWidth) {
					imgWidth := Floor(imgWidth * scale)
					imgHeight := Floor(imgHeight * scale)
				}

				html := ("<div class=""lbox""><img width=""" . imgWidth . """ height=""" . imgHeight . """ src=""" . fileName . """></div>")
			}
		}

		chartViewer.Document.Open()

		if html {
			this.selectReport("Track")

			html .= "<div class=""rbox"">"

			html .= ("<br><br><br><br><br><br><div style=""text-align: left;"" id=""header""><i>" . translate("Deltas") . "</i></div>")
			html .= ("<br>" . this.createLapDeltas(lastLap, hasLeader ? "0000ff" : false, hasAhead ? "006400" : false, hasBehind ? "ff0000" : false))

			html .= "</div>"

			tableCSS := getTableCSS()

			hWidth := Round(width / 2.5)

			script =
			(
				<meta charset='utf-8'>
				<head>
					<style>
						.lbox { float: left; text-align: center; width: %hWidth%; }
						.rbox { float: right; }
						.headerStyle { height: 25; font-size: 11px; font-weight: 500; background-color: 'FFFFFF'; }
						.rowStyle { font-size: 11px; background-color: 'E0E0E0'; }
						.oddRowStyle { font-size: 11px; background-color: 'E8E8E8'; }
						%tableCSS%
					</style>
				</head>
			)

			html := ("<html>" . script . "<body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'><style> div, table { font-family: Arial, Helvetica, sans-serif; font-size: 11px }</style><style> #header { font-size: 12px; } </style><div>" . html . "</div></body></html>")

			chartViewer.Document.Write(html)
		}
		else {
			this.selectReport(false)

			chartViewer.Document.Write("<html><body style='background-color: #D8D8D8' style='overflow: auto' leftmargin='0' topmargin='0' rightmargin='0' bottommargin='0'></body></html>")
		}

		chartViewer.Document.Close()

		this.updateState()
	}

	showRaceReport(report) {
		local raceData, drivers

		switch report {
			case "Overview":
				this.showOverviewReport()
			case "Car":
				this.showCarReport()
			case "Drivers":
				if !this.ReportViewer.Settings.HasKey("Drivers") {
					raceData := true

					this.ReportViewer.loadReportData(false, raceData, false, false, false)

					drivers := []

					loop % Min(5, getConfigurationValue(raceData, "Cars", "Count"))
						drivers.Push(A_Index)

					if !this.ReportViewer.Settings.HasKey("Drivers")
						this.ReportViewer.Settings["Drivers"] := drivers
				}

				this.showDriverReport()
			case "Positions":
				this.showPositionsReport()
			case "Lap Times":
				this.showLapTimesReport()
			case "Consistency":
				if !this.ReportViewer.Settings.HasKey("Drivers") {
					raceData := true

					this.ReportViewer.loadReportData(false, raceData, false, false, false)

					drivers := []

					loop % Min(5, getConfigurationValue(raceData, "Cars", "Count"))
						drivers.Push(A_Index)

					if !this.ReportViewer.Settings.HasKey("Drivers")
						this.ReportViewer.Settings["Drivers"] := drivers
				}

				this.showConsistencyReport()
			case "Pace":
				this.showPaceReport()
		}
	}

	showTelemetryReport() {
		local window := this.Window
		local xAxis, yAxises

		Gui %window%:Default

		GuiControlGet dataXDropDown
		GuiControlGet dataY1DropDown
		GuiControlGet dataY2DropDown
		GuiControlGet dataY3DropDown
		GuiControlGet dataY4DropDown
		GuiControlGet dataY5DropDown
		GuiControlGet dataY6DropDown

		xAxis := this.iXColumns[dataXDropDown]
		yAxises := Array(this.iY1Columns[dataY1DropDown])

		if (dataY2DropDown > 1)
			yAxises.Push(this.iY2Columns[dataY2DropDown - 1])

		if (dataY3DropDown > 1)
			yAxises.Push(this.iY3Columns[dataY3DropDown - 1])

		if (dataY4DropDown > 1)
			yAxises.Push(this.iY4Columns[dataY4DropDown - 1])

		if (dataY5DropDown > 1)
			yAxises.Push(this.iY5Columns[dataY5DropDown - 1])

		if (dataY6DropDown > 1)
			yAxises.Push(this.iY6Columns[dataY6DropDown - 1])

		this.showDataPlot(this.SessionStore.Tables["Lap.Data"], xAxis, yAxises)

		this.updateState()
	}

	showPressuresReport() {
		this.selectReport("Pressures")

		this.showTelemetryReport()

		this.updateState()
	}

	editPressuresReportSettings() {
		return this.ReportViewer.editReportSettings("Laps")
	}

	showBrakesReport() {
		this.selectReport("Brakes")

		this.showTelemetryReport()

		this.updateState()
	}

	editBrakesReportSettings() {
		return this.ReportViewer.editReportSettings("Laps")
	}

	showTemperaturesReport() {
		this.selectReport("Temperatures")

		this.showTelemetryReport()

		this.updateState()
	}

	editTemperaturesReportSettings() {
		return this.ReportViewer.editReportSettings("Laps")
	}

	showCustomReport() {
		this.selectReport("Free")

		this.showTelemetryReport()

		this.updateState()
	}

	editCustomReportSettings() {
		return this.ReportViewer.editReportSettings("Laps")
	}

	updateSeriesSelector(report, force := false) {
		local window := this.Window
		local xChoices, y1Choices, y2Choices, y3Choices, y4Choices, y5Choices, y6Choices
		local sessionDB, selected, names, ignore, id, found, index, driver

		Gui %window%:Default

		GuiControlGet dataXDropDown

		if (force || (report != this.SelectedReport) || (dataXDropDown == 0)) {
			xChoices := []
			y1Choices := []
			y2Choices := []
			y3Choices := []
			y4Choices := []
			y5Choices := []
			y6Choices := []

			if (report = "Pressures") {
				xChoices := ["Stint", "Lap", "Lap.Time", "Tyre.Wear.Average"]

				y1Choices := ["Temperature.Air", "Temperature.Track", "Fuel.Remaining", "Tyre.Laps"
							, "Tyre.Pressure.Cold.Average", "Tyre.Pressure.Cold.Front.Average", "Tyre.Pressure.Cold.Rear.Average"
							, "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
							, "Tyre.Pressure.Cold.Front.Left", "Tyre.Pressure.Cold.Front.Right", "Tyre.Pressure.Cold.Rear.Left", "Tyre.Pressure.Cold.Rear.Right"
							, "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right", "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
							, "Tyre.Wear.Average", "Tyre.Wear.Front.Average", "Tyre.Wear.Rear.Average"
							, "Tyre.Wear.Front.Left", "Tyre.Wear.Front.Right", "Tyre.Wear.Rear.Left", "Tyre.Wear.Rear.Right"]

				y2Choices := y1Choices
				y3Choices := y1Choices
				y4Choices := y1Choices
				y5Choices := y1Choices
				y6Choices := y1Choices
			}
			else if (report = "Brakes") {
				xChoices := ["Stint", "Lap", "Lap.Time", "Brake.Wear.Average"]

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
				xChoices := ["Stint", "Lap", "Lap.Time", "Tyre.Wear.Average", "Brake.Wear.Average"]

				y1Choices := ["Temperature.Air", "Temperature.Track", "Fuel.Remaining", "Tyre.Laps"
							, "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
							, "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right", "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
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
				xChoices := ["Stint", "Lap", "Lap.Time", "Tyre.Laps", "Map", "TC", "ABS", "Temperature.Air", "Temperature.Track", "Tyre.Wear.Average", "Brake.Wear.Average"]

				y1Choices := ["Temperature.Air", "Temperature.Track", "Fuel.Remaining", "Fuel.Consumption", "Lap.Time", "Tyre.Laps", "Map", "TC", "ABS"
							, "Tyre.Pressure.Cold.Average", "Tyre.Pressure.Cold.Front.Average", "Tyre.Pressure.Cold.Rear.Average"
							, "Tyre.Pressure.Hot.Average", "Tyre.Pressure.Hot.Front.Average", "Tyre.Pressure.Hot.Rear.Average"
							, "Tyre.Pressure.Hot.Front.Left", "Tyre.Pressure.Hot.Front.Right", "Tyre.Pressure.Hot.Rear.Left", "Tyre.Pressure.Hot.Rear.Right"
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

			GuiControl, , dataXDropDown, % ("|" . values2String("|", xChoices*))
			GuiControl, , dataY1DropDown, % ("|" . values2String("|", y1Choices*))
			GuiControl, , dataY2DropDown, % ("|" . values2String("|", translate("None"), y2Choices*))
			GuiControl, , dataY3DropDown, % ("|" . values2String("|", translate("None"), y3Choices*))
			GuiControl, , dataY4DropDown, % ("|" . values2String("|", translate("None"), y4Choices*))
			GuiControl, , dataY5DropDown, % ("|" . values2String("|", translate("None"), y5Choices*))
			GuiControl, , dataY6DropDown, % ("|" . values2String("|", translate("None"), y6Choices*))

			dataXDropDown := 0
			dataY1DropDown := 0
			dataY2DropDown := 0
			dataY3DropDown := 0
			dataY4DropDown := 0
			dataY5DropDown := 0
			dataY6DropDown := 0

			if (report = "Pressures") {
				GuiControl Choose, chartTypeDropDown, 4

				this.iSelectedChartType := "Line"

				dataXDropDown := inList(xChoices, "Lap")
				dataY1DropDown := inList(y1Choices, "Temperature.Air")
				dataY2DropDown := inList(y2Choices, "Tyre.Pressure.Cold.Average") + 1
				dataY3DropDown := inList(y3Choices, "Tyre.Pressure.Hot.Average") + 1
				dataY4DropDown := 1
				dataY5DropDown := 1
				dataY6DropDown := 1
			}
			else if (report = "Brakes") {
				GuiControl Choose, chartTypeDropDown, 4

				this.iSelectedChartType := "Line"

				dataXDropDown := inList(xChoices, "Lap")
				dataY1DropDown := inList(y1Choices, "Temperature.Air")
				dataY2DropDown := inList(y2Choices, "Brake.Temperature.Front.Average") + 1
				dataY3DropDown := inList(y3Choices, "Brake.Temperature.Rear.Average") + 1
				dataY4DropDown := inList(y4Choices, "Brake.Wear.Front.Average") + 1
				dataY5DropDown := inList(y5Choices, "Brake.Wear.Rear.Average") + 1
				dataY6DropDown := 1
			}
			else if (report = "Temperatures") {
				GuiControl Choose, chartTypeDropDown, 1

				this.iSelectedChartType := "Scatter"

				dataXDropDown := inList(xChoices, "Lap")
				dataY1DropDown := inList(y1Choices, "Temperature.Air")
				dataY2DropDown := inList(y2Choices, "Tyre.Temperature.Front.Average") + 1
				dataY3DropDown := inList(y3Choices, "Tyre.Temperature.Rear.Average") + 1
				dataY4DropDown := 1
				dataY5DropDown := 1
				dataY6DropDown := 1
			}
			else if (report = "Free") {
				GuiControl Choose, chartTypeDropDown, 4

				this.iSelectedChartType := "Line"

				dataXDropDown := inList(xChoices, "Lap")
				dataY1DropDown := inList(y1Choices, "Lap.Time")
				dataY2DropDown := inList(y2Choices, "Tyre.Laps") + 1
				dataY3DropDown := inList(y3Choices, "Temperature.Air") + 1
				dataY4DropDown := inList(y4Choices, "Temperature.Track") + 1
				dataY5DropDown := inList(y5Choices, "Tyre.Pressure.Cold.Average") + 1
				dataY6DropDown := inList(y6Choices, "Tyre.Pressure.Hot.Average") + 1
			}

			sessionDB := new SessionDatabase()
			selected := false
			names := []

			if this.SelectedDrivers
				selected := this.SelectedDrivers[1]

			for index, id in this.AvailableDrivers {
				found := false

				for ignore, driver in this.Drivers
					if (driver.ID = id) {
						names.Push(driver.Fullname)

						found := true

						break
					}

				if !found
					names.Push(values2String(", ", sessionDB.getDriverNames(this.SelectedSimulator, id)*))

				if (id = selected)
					selected := A_Index
			}

			if selected is not Integer
			{
				selected := false

				this.iSelectedDrivers := false
			}

			GuiControl, , driverDropDown, % "|" . values2String("|", translate("All"), names*)
			GuiControl Choose, driverDropDown, % (selected + 1)

			GuiControl Choose, dataXDropDown, %dataXDropDown%
			GuiControl Choose, dataY1DropDown, %dataY1DropDown%
			GuiControl Choose, dataY2DropDown, %dataY2DropDown%
			GuiControl Choose, dataY3DropDown, %dataY3DropDown%
			GuiControl Choose, dataY4DropDown, %dataY4DropDown%
			GuiControl Choose, dataY5DropDown, %dataY5DropDown%
			GuiControl Choose, dataY6DropDown, %dataY6DropDown%
		}
	}

	syncSessionStore(forSave := false) {
		local session := this.SelectedSession[true]
		local sessionStore := this.SessionStore
		local lastLap := this.LastLap
		local pressuresTable, tyresTable, newLap, lap, lapData, pressures, tyres
		local pressureFL, pressureFR, pressureRL, pressureRR
		local temperatureFL, temperatureFR, temperatureRL, temperatureRR
		local wearFL, wearFR, wearRL, wearRR
		local telemetry, brakeTemperatures, ignore, field, brakeWears
		local currentListView, lapPressures, entry, standingsData, prefix, driver
		local currentStint, newStint, stint, stintData, tries

		if lastLap
			lastLap := lastLap.Nr

		if lastLap {
			pressuresTable := this.PressuresDatabase.Database.Tables["Tyres.Pressures"]
			tyresTable := this.TelemetryDatabase.Database.Tables["Tyres"]

			newLap := (sessionStore.Tables["Lap.Data"].Length() + 1)

			while (newLap <= lastLap) {
				if !this.Laps.HasKey(newLap) {
					newLap += 1

					continue
				}

				lap := this.Laps[newLap]

				if ((pressuresTable.Length() < newLap) || (tyresTable.Length() < newLap))
					return

				lapData := {Nr: newLap, Lap: newLap, Stint: lap.Stint.Nr, "Lap.Time": null(lap.Laptime), Position: null(lap.Position)
						  , Damage: lap.Damage, EngineDamage: lap.EngineDamage, Accident: lap.Accident
						  , "Fuel.Consumption": null(lap.FuelConsumption), "Fuel.Remaining": null(lap.FuelRemaining)
						  , Weather: lap.Weather, "Temperature.Air": null(lap.AirTemperature), "Temperature.Track": null(lap.TrackTemperature)
						  , Grip: lap.Grip, Map: null(lap.Map), TC: null(lap.TC), ABS: null(lap.ABS)
						  , "Tyre.Compound": compound(lap.Compound), "Tyre.Compound.Color": compoundColor(lap.Compound)}

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

				if (isNull(pressureFL))
					pressureFL := tyres["Tyre.Pressure.Front.Left"]
				if (isNull(pressureFR))
					pressureFR := tyres["Tyre.Pressure.Front.Right"]
				if (isNull(pressureRL))
					pressureRL := tyres["Tyre.Pressure.Rear.Left"]
				if (isNull(pressureRR))
					pressureRR := tyres["Tyre.Pressure.Rear.Right"]

				lapData["Tyre.Pressure.Hot.Front.Left"] := null(pressureFL)
				lapData["Tyre.Pressure.Hot.Front.Right"] := null(pressureFR)
				lapData["Tyre.Pressure.Hot.Rear.Left"] := null(pressureRL)
				lapData["Tyre.Pressure.Hot.Rear.Right"] := null(pressureRR)
				lapData["Tyre.Pressure.Hot.Average"] := null(average([pressureFL, pressureFR, pressureRL, pressureRR]))
				lapData["Tyre.Pressure.Hot.Front.Average"] := null(average([pressureFL, pressureFR]))
				lapData["Tyre.Pressure.Hot.Rear.Average"] := null(average([pressureRL, pressureRR]))

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

				telemetry := parseConfiguration(lap.Telemetry)

				if (telemetry.Count() > 0) {
					brakeTemperatures := string2Values(",", getConfigurationValue(telemetry, "Car Data", "BrakeTemperature", ""))

					if (brakeTemperatures.Count() = 4) {
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

					brakeWears := string2Values(",", getConfigurationValue(telemetry, "Car Data", "BrakeWear", ""))

					if (brakeWears.Count() = 4) {
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

				sessionStore.add("Lap.Data", lapData)

				currentListView := A_DefaultListView

				try {
					Gui ListView, % this.LapsListView

					LV_GetText(lapPressures, lap.Row, 10)

					if (lapPressures = "-, -, -, -")
						LV_Modify(lap.Row, "Col10", values2String(", ", displayValue(pressureFL), displayValue(pressureFR)
																	  , displayValue(pressureRL), displayValue(pressureRR)))

					newLap += 1
				}
				finally {
					Gui ListView, %currentListView%
				}
			}

			if this.SessionActive {
				lap := 0

				for ignore, entry in sessionStore.Tables["Delta.Data"]
					lap := Max(lap, entry.Lap)

				lap += 1

				while (lap <= lastLap) {
					if !this.Laps.HasKey(lap) {
						lap += 1

						continue
					}

					try {
						tries := ((lap == lastLap) ? 10 : 1)

						while (tries > 0) {
							standingsData := this.Connector.GetSessionLapValue(session, lap, "Race Strategist Race Standings")

							if (!standingsData || (standingsData == "")) {
								tries -= 1

								this.showMessage(translate("Waiting for data"))

								if (tries <= 0) {
									this.showMessage(translate("Give up - use default values"))

									throw "No data..."
								}
								else
									Sleep 400
							}
							else
								break
						}

						standingsData := parseConfiguration(standingsData)
					}
					catch exception {
						standingsData := newConfiguration()
					}

					if (standingsData.Count() > 0) {
						sessionStore.add("Delta.Data", {Lap: lap, Type: "Standings.Behind"
													  , Car: getConfigurationValue(standingsData, "Position", "Position.Standings.Behind.Car")
													  , Delta: Round(getConfigurationValue(standingsData, "Position", "Position.Standings.Behind.Delta") / 1000, 2)
													  , Distance: Round(getConfigurationValue(standingsData, "Position", "Position.Standings.Behind.Distance"), 2)})
						sessionStore.add("Delta.Data", {Lap: lap, Type: "Standings.Ahead"
													  , Car: getConfigurationValue(standingsData, "Position", "Position.Standings.Ahead.Car")
													  , Delta: Round(getConfigurationValue(standingsData, "Position", "Position.Standings.Ahead.Delta") / 1000, 2)
													  , Distance: Round(getConfigurationValue(standingsData, "Position", "Position.Standings.Ahead.Distance"), 2)})
						sessionStore.add("Delta.Data", {Lap: lap, Type: "Standings.Leader"
													  , Car: getConfigurationValue(standingsData, "Position", "Position.Standings.Leader.Car")
													  , Delta: Round(getConfigurationValue(standingsData, "Position", "Position.Standings.Leader.Delta") / 1000, 2)
													  , Distance: Round(getConfigurationValue(standingsData, "Position", "Position.Standings.Leader.Distance"), 2)})
						sessionStore.add("Delta.Data", {Lap: lap, Type: "Track.Behind"
													  , Car: getConfigurationValue(standingsData, "Position", "Position.Track.Behind.Car")
													  , Delta: Round(getConfigurationValue(standingsData, "Position", "Position.Track.Behind.Delta") / 1000, 2)
													  , Distance: Round(getConfigurationValue(standingsData, "Position", "Position.Track.Behind.Distance"), 2)})
						sessionStore.add("Delta.Data", {Lap: lap, Type: "Track.Ahead"
													  , Car: getConfigurationValue(standingsData, "Position", "Position.Track.Ahead.Car")
													  , Delta: Round(getConfigurationValue(standingsData, "Position", "Position.Track.Ahead.Delta") / 1000, 2)
													  , Distance: Round(getConfigurationValue(standingsData, "Position", "Position.Track.Ahead.Distance"), 2)})

						prefix := ("Standings.Lap." . lap . ".Car.")

						loop % getConfigurationValue(standingsData, "Standings", prefix . "Count")
						{
							driver := computeDriverName(getConfigurationValue(standingsData, "Standings", prefix . A_Index . ".Driver.Forname")
													  , getConfigurationValue(standingsData, "Standings", prefix . A_Index . ".Driver.Surname")
													  , getConfigurationValue(standingsData, "Standings", prefix . A_Index . ".Driver.Nickname"))

							sessionStore.add("Standings.Data", {Lap: lap, Car: A_Index, Driver: driver
															  , Position: getConfigurationValue(standingsData, "Standings", prefix . A_Index . ".Position")
															  , Time: Round(getConfigurationValue(standingsData, "Standings", prefix . A_Index . ".Time") / 1000, 1)
															  , Laps: Round(getConfigurationValue(standingsData, "Standings", prefix . A_Index . ".Laps"), 1)
															  , Delta: Round(getConfigurationValue(standingsData, "Standings", prefix . A_Index . ".Delta") / 1000, 2)})
						}
					}

					lap += 1
				}
			}
		}

		if forSave {
			this.saveSetups(this.SessionFinished)
			this.savePlan(this.SessionFinished)

			currentStint := this.CurrentStint

			if currentStint {
				sessionStore.clear("Stint.Data")
				newStint := 1

				while (newStint <= currentStint.Nr) {
					if this.Stints.HasKey(newStint) {
						stint := this.Stints[newStint]

						stintData := {Nr: newStint, Lap: stint.Lap
									, "Driver.Forname": stint.Driver.Forname, "Driver.Surname": stint.Driver.Surname, "Driver.Nickname": stint.Driver.Nickname
									, "Weather": stint.Weather, "Compound": stint.Compound, "Lap.Time.Average": null(stint.AvgLaptime), "Lap.Time.Best": null(stint.BestLapTime)
									, "Fuel.Consumption": null(stint.FuelConsumption), "Accidents": stint.Accidents
									, "Position.Start": null(stint.StartPosition), "Position.End": null(stint.EndPosition)
									, "Time.Start": stint.Time, "Driver.ID": stint.ID}

						sessionStore.add("Stint.Data", stintData)
					}

					newStint += 1
				}
			}

			if (this.Drivers.Length() != sessionStore.Tables["Driver.Data"].Length()) {
				sessionStore.clear("Driver.Data")

				for ignore, driver in this.Drivers
					sessionStore.add("Driver.Data", {Forname: driver.Forname, Surname: driver.Surname, Nickname: driver.Nickname, ID: driver.ID})
			}

			sessionStore.flush()
		}
	}

	reportSettings(report) {
		switch report {
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
		if (force || (report != this.SelectedReport)) {
			this.pushTask(ObjBindMethod(this, "syncSessionStore"))

			this.pushTask(ObjBindMethod(this, "showReportAsync", report))
		}
	}

	showReportAsync(report) {
		this.updateSeriesSelector(report)

		if (report = "Track")
			this.showTrackMap()
		else if inList(kRaceReports, report)
			this.showRaceReport(report)
		else if (report = "Pressures")
			this.showPressuresReport()
		else if (report = "Brakes")
			this.showBrakesReport()
		else if (report = "Temperatures")
			this.showTemperaturesReport()
		else if (report = "Free")
			this.showCustomReport()
	}

	selectChartType(chartType, force := false) {
		if (force || (chartType != this.SelectedChartType)) {
			GuiControl Choose, chartTypeDropDown, % inList(["Scatter", "Bar", "Bubble", "Line"], chartType)

			this.iSelectedChartType := chartType

			this.showTelemetryReport()
		}
	}

	createStintHeader(stint) {
		local duration := 0
		local ignore, lap, html

		for ignore, lap in stint.Laps
			duration += lap.Laptime

		html := "<table>"
		html .= ("<tr><td><b>" . translate("Driver:") . "</b></div></td><td>" . StrReplace(stint.Driver.FullName, "'", "\'") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Duration:") . "</b></div></td><td>" . Round(duration / 60) . A_Space . translate("Minutes") . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Start Position:") . "</b></div></td><td>" . stint.StartPosition . "</td></tr>")
		html .= ("<tr><td><b>" . translate("End Position:") . "</b></div></td><td>" . stint.EndPosition . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Temperatures (A / T):") . "</b></td><td>" . stint.AirTemperature . ", " . stint.TrackTemperature . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Consumption:") . "</b></div></td><td>" . stint.FuelConsumption . A_Space . translate("Liter") . "</td></tr>")
		html .= "</table>"

		return html
	}

	createLapDetailsChart(chartID, width, height, lapSeries, positionSeries, lapTimeSeries, fuelSeries, tempSeries) {
		local drawChartFunction := ("function drawChart" . chartID . "() {`nvar data = new google.visualization.DataTable();")
		local ignore, time

		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Lap") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Position") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Lap Time") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Consumption") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Tyre Temperatures") . "');")

		drawChartFunction .= "`ndata.addRows(["

		for ignore, time in lapSeries {
			if (A_Index > 1)
				drawChartFunction .= ", "

			drawChartFunction .= ("[" . values2String(", ", lapSeries[A_Index]
														  , chartValue(null(positionSeries[A_Index]))
														  , chartValue(null(lapTimeSeries[A_Index]))
														  , chartValue(null(fuelSeries[A_Index]))
														  , chartValue(null(tempSeries[A_Index])))
									  . "]")
		}

		drawChartFunction .= ("]);`nvar options = { legend: { position: 'Right' }, chartArea: { left: '10%', top: '5%', right: '25%', bottom: '20%' }, hAxis: { title: '" . translate("Lap") . "', gridlines: {count: 0} }, vAxis: { viewWindow: { min: 0 }, gridlines: {count: 0} }, backgroundColor: 'D8D8D8' };`n")

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return drawChartFunction
	}

	createStintPerformanceChart(chartID, width, height, stint) {
		local drawChartFunction := ""
		local minValue, maxValue

		this.updateStintStatistics(stint)

		drawChartFunction .= "function drawChart" . chartID . "() {"
		drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["
		drawChartFunction .= "`n['" . values2String("', '", translate("Category"), StrReplace(stint.Driver.FullName, "'", "\'")) . "'],"

		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Potential") . "'", stint.Potential) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Race Craft") . "'", stint.RaceCraft) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Speed") . "'", stint.Speed) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Consistency") . "'", stint.Consistency) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Car Control") . "'", stint.CarControl) . "]"

		drawChartFunction .= ("`n]);")

		minValue := Min(0, stint.Potential, stint.RaceCraft, stint.Speed, stint.Consistency, stint.CarControl)
		maxValue := Max(stint.Potential, stint.RaceCraft, stint.Speed, stint.Consistency, stint.CarControl)

		drawChartFunction := drawChartFunction . "`nvar options = { bars: 'horizontal', legend: 'none', backgroundColor: 'D8D8D8', chartArea: { left: '20%', top: '5%', right: '10%', bottom: '10%' }, hAxis: {viewWindowMode: 'explicit', viewWindow: {min: " . minValue . ", max: " . maxValue . "}, gridlines: {count: 0} }, vAxis: {gridlines: {count: 0}} };"
		drawChartFunction := drawChartFunction . "`nvar chart = new google.visualization.BarChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }"

		return drawChartFunction
	}

	createStintConsistencyChart(chartID, width, height, stint, laps, lapTimes) {
		local drawChartFunction := "function drawChart" . chartID . "() {"
		local validLaps := []
		local validTimes := []
		local ignore, lap, time, min, avg, max, delta, window, consistency, time, title

		for ignore, lap in laps {
			if (A_Index > 1) { ; skip out lap
				time := lapTimes[A_Index]

				if time is Number
				{
					validLaps.Push(lap)
					validTimes.Push(time)
				}
			}
		}

		drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["

		drawChartFunction .= "`n['" . values2String("', '", translate("Lap"), translate("Lap Time")
														  , translate("Max"), translate("Avg"), translate("Min")) . "']"

		min := minimum(validTimes)
		avg := average(validTimes)
		max := maximum(validTimes)

		for ignore, lap in validLaps
			drawChartFunction .= ",`n[" . values2String(", ", lap, validTimes[A_Index], max, avg, min) . "]"

		drawChartFunction .= ("`n]);")

		delta := (max - min)

		min := Max(avg - (3 * delta), 0)
		max := Min(avg + (2 * delta), max)

		window := ("baseline: " . min . ", viewWindow: {min: " . min . ", max: " . max . "}, ")
		consistency := 0

		for ignore, time in validTimes
			consistency += (100 - Abs(avg - time))

		consistency := Round(consistency / validTimes.Length(), 2)

		title := ("title: '" . translate("Consistency: ") . consistency . translate(" %") . "', titleTextStyle: {bold: false}, ")

		drawChartFunction .= ("`nvar options = {" . title . "seriesType: 'bars', series: {1: {type: 'line'}, 2: {type: 'line'}, 3: {type: 'line'}}, backgroundColor: '#D8D8D8', vAxis: {" . window . "title: '" . translate("Lap Time") . "', gridlines: {count: 0}}, hAxis: {title: '" . translate("Laps") . "', gridlines: {count: 0}}, chartArea: { left: '20%', top: '15%', right: '15%', bottom: '15%' } };")

		drawChartFunction .= ("`nvar chart = new google.visualization.ComboChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return drawChartFunction
	}

	createLapDetails(stint) {
		local html := "<table>"
		local lapData := []
		local mapData := []
		local lapTimeData := []
		local fuelConsumptionData := []
		local accidentData := []
		local ignore, lap

		html .= ("<tr><td><b>" . translate("Average:") . "</b></td><td>" . lapTimeDisplayValue(stint.AvgLapTime) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Best:") . "</b></td><td>" . lapTimeDisplayValue(stint.BestLapTime) . "</td></tr>")
		html .= "</table>"

		for ignore, lap in stint.Laps {
			lapData.Push("<th class=""th-std"">" . lap.Nr . "</th>")
			mapData.Push("<td class=""td-std"">" . lap.Map . "</td>")
			lapTimeData.Push("<td class=""td-std"">" . lapTimeDisplayValue(lap.Laptime) . "</td>")
			fuelConsumptionData.Push("<td class=""td-std"">" . lap.FuelConsumption . "</td>")
			accidentData.Push("<td class=""td-std"">" . (lap.Accident ? "x" : "") . "</td>")
		}

		html .= "<br><table class=""table-std"">"

		html .= ("<tr><th class=""th-std"">" . translate("Lap") . "</th>"
			       . "<th class=""th-std"">" . translate("Map") . "</th>"
			       . "<th class=""th-std"">" . translate("Lap Time") . "</th>"
			       . "<th class=""th-std"">" . translate("Consumption") . "</th>"
			       . "<th class=""th-std"">" . translate("Accident") . "</th>"
			   . "</tr>")

		loop % lapData.Length()
			html .= ("<tr>" . lapData[A_Index]
							. mapData[A_Index]
							. lapTimeData[A_Index]
							. fuelConsumptionData[A_Index]
							. accidentData[A_Index]
				   . "</tr>")

		html .= "</table>"

		return html
	}

	showStintDetails(stint) {
		this.pushTask(ObjBindMethod(this, "syncSessionStore"))

		this.pushTask(ObjBindMethod(this, "showStintDetailsAsync", stint))
	}

	showStintDetailsAsync(stint) {
		local html := ("<div id=""header""><b>" . translate("Stint: ") . stint.Nr . "</b></div>")
		local laps := []
		local positions := []
		local lapTimes := []
		local fuelConsumptions := []
		local temperatures := []
		local lapTable := this.SessionStore.Tables["Lap.Data"]
		local ignore, lap, width, chart1, chart2, chart3

		html .= ("<br><br><div id=""header""><i>" . translate("Overview") . "</i></div>")

		html .= ("<br>" . this.createStintHeader(stint))

		html .= ("<br><br><div id=""header""><i>" . translate("Laps") . "</i></div>")

		html .= ("<br>" . this.createLapDetails(stint))

		html .= ("<br><br><div id=""header""><i>" . translate("Telemetry") . "</i></div>")

		for ignore, lap in stint.Laps {
			laps.Push(lap.Nr)
			positions.Push(lap.Position)
			lapTimes.Push(lap.Laptime)
			fuelConsumptions.Push(lap.FuelConsumption)
			temperatures.Push(lapTable[lap.Nr]["Tyre.Temperature.Average"])
		}

		width := (detailsViewer.Width - 20)

		chart1 := this.createLapDetailsChart(1, width, 248, laps, positions, lapTimes, fuelConsumptions, temperatures)

		html .= ("<br><br><div id=""chart_1" . """ style=""width: " . width . "px; height: 248px""></div>")

		html .= ("<br><br><div id=""header""><i>" . translate("Statistics") . "</i></div>")

		chart2 := this.createStintPerformanceChart(2, width, 248, stint)

		html .= ("<br><div id=""chart_2" . """ style=""width: " . width . "px; height: 248px""></div>")

		html .= ("<br><br><div id=""header""><i>" . translate("Consistency") . "</i></div>")

		chart3 := this.createStintConsistencyChart(3, width, 248, stint, laps, lapTimes)

		html .= ("<br><div id=""chart_3" . """ style=""width: " . width . "px; height: 248px""></div>")

		this.showDetails("Stint", html, [1, chart1], [2, chart2], [3, chart3])
	}

	createLapOverview(lap) {
		local html := "<table>"
		local hotPressures := "-, -, -, -"
		local coldPressures := "-, -, -, -"
		local pressuresDB := this.PressuresDatabase
		local pressuresTable, pressures, coldPressures, hotPressures, tyresTable, tyres

		if pressuresDB {
			pressuresTable := pressuresDB.Database.Tables["Tyres.Pressures"]

			if (pressuresTable.Length() >= lap.Nr) {
				pressures := pressuresTable[lap.Nr]

				coldPressures := values2String(", ", displayValue(pressures["Tyre.Pressure.Cold.Front.Left"]), displayValue(pressures["Tyre.Pressure.Cold.Front.Right"])
												   , displayValue(pressures["Tyre.Pressure.Cold.Rear.Left"]), displayValue(pressures["Tyre.Pressure.Cold.Rear.Right"]))

				hotPressures := values2String(", ", displayValue(pressures["Tyre.Pressure.Hot.Front.Left"]), displayValue(pressures["Tyre.Pressure.Hot.Front.Right"])
												  , displayValue(pressures["Tyre.Pressure.Hot.Rear.Left"]), displayValue(pressures["Tyre.Pressure.Hot.Rear.Right"]))

				if (hotPressures = "-, -, -, -") {
					tyresTable := this.TelemetryDatabase.Database.Tables["Tyres"]

					if (tyresTable.Length() >= lap.Nr) {
						tyres := tyresTable[lap.Nr]

						hotPressures := values2String(", ", displayValue(tyres["Tyre.Pressure.Front.Left"])
														  , displayValue(tyres["Tyre.Pressure.Front.Right"])
														  , displayValue(tyres["Tyre.Pressure.Rear.Left"])
														  , displayValue(tyres["Tyre.Pressure.Rear.Right"]))
					}
				}
			}
		}

		html .= ("<tr><td><b>" . translate("Position:") . "</b></td><td>" . lap.Position . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Lap Time:") . "</b></td><td>" . lapTimeDisplayValue(lap.LapTime) . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Consumption:") . "</b></td><td>" . lap.FuelConsumption . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Fuel Level:") . "</b></td><td>" . lap.FuelRemaining . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Temperatures (A / T):") . "</b></td><td>" . lap.AirTemperature . ", " . lap.TrackTemperature . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Pressures (hot):") . "</b></td><td>" . hotPressures . "</td></tr>")
		html .= ("<tr><td><b>" . translate("Pressures (cold):") . "</b></td><td>" . coldPressures . "</td></tr>")
		html .= "</table>"

		return html
	}

	createLapDeltas(lap, leaderColor := false, aheadColor := false, behindColor := false) {
		local sessionStore := this.SessionStore
		local html := "<table class=""table-std"">"
		local labels := [translate("Leader"), translate("Standings (Ahead)"), translate("Standings (Behind)")
					   , translate("Track (Ahead)"), translate("Track (Behind)")]
		local rowIndices := {"Standings.Leader": 1, "Standings.Front": 2, "Standings.Ahead": 2, "Standings.Behind": 3
						   , "Track.Front": 4, "Track.Ahead": 4, "Track.Behind": 5}
		local telemetryDB := this.TelemetryDatabase
		local rows := [1, 2, 3, 4, 5]
		local deltas, ignore, entry, carNumber, carName, driverFullName, delta, row
		local driverForname, driverSurname, driverNickname, entryType, index, label

		html .= ("<tr><th class=""th-std"">" . "" . "</th>"
			   . "<th class=""th-std"">" . translate("Nr.") . "</th>"
			   . "<th class=""th-std"">" . translate("Driver") . "</th>"
			   . "<th class=""th-std"">" . translate("Car") . "</th>"
			   . "<th class=""th-std"">" . translate("Delta") . "</th>"
			   . "</tr>")

		deltas := sessionStore.query("Delta.Data", {Where: {Lap: lap.Nr}})

		if (deltas.Length() > 0) {
			for ignore, entry in deltas {
				carNumber := "-"
				carName := "-"
				driverFullname := "-"
				delta := "-"

				if (entry.Car) {
					driverForname := false
					driverSurname := false
					driverNickname := false

					this.getCar(lap, entry.Car, carNumber, carName, driverForname, driverSurname, driverNickname)

					driverFullname := computeDriverName(driverForname, driverSurname, driverNickname)
					delta := entry.Delta
				}

				entryType := entry.Type

				index := rowIndices[entryType]

				if (leaderColor && (entryType = "Standings.Leader"))
					label := ("<p style=""color:#" . leaderColor . """;>" . labels[index] . "</p>")
				else if (aheadColor && ((entryType = "Standings.Front") || (entryType = "Standings.Ahead")))
					label := ("<p style=""color:#" . aheadColor . """;>" . labels[index] . "</p>")
				else if (behindColor && (entryType = "Standings.Behind"))
					label := ("<p style=""color:#" . behindColor . """;>" . labels[index] . "</p>")
				else
					label := labels[index]

				rows[index] := ("<tr><th class=""th-std th-left"">" . label . "</th>"
							  . "<td class=""td-std"">" . values2String("</td><td class=""td-std"">" , carNumber, driverFullname, telemetryDB.getCarName(this.Simulator, carName), delta)
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
		local html := "<table class=""table-std"">"
		local cars := true
		local positions := true
		local carNumbers := true
		local carNames := true
		local driverFornames := true
		local driverSurnames := true
		local driverNicknames := true
		local index, position, lapTime, laps, delta, result

		html .= ("<tr><th class=""th-std"">" . translate("#") . "</th>"
			   . "<th class=""th-std"">" . translate("Nr.") . "</th>"
			   . "<th class=""th-std"">" . translate("Driver") . "</th>"
			   . "<th class=""th-std"">" . translate("Car") . "</th>"
			   . "<th class=""th-std"">" . translate("Lap Time") . "</th>"
			   . "<th class=""th-std"">" . translate("Laps") . "</th>"
			   . "<th class=""th-std"">" . translate("Delta") . "</th>"
			   . "</tr>")

		this.getStandings(lap, cars, positions, carNumbers, carNames, driverFornames, driverSurnames, driverNicknames)

		for index, position in positions {
			lapTime := "-"
			laps := "-"
			delta := "-"

			result := sessionStore.query("Standings.Data", {Select: ["Time", "Laps", "Delta"], Where: {Lap: lap.Nr, Car: cars[index]}})

			if (result.Length() > 0) {
				lapTime := result[1].Time
				laps := result[1].Laps
				delta := Round(result[1].Delta, 1)
			}

			html .= ("<tr><th class=""th-std"">" . position . "</td>"
				   . "<td class=""td-std"">" . values2String("</td><td class=""td-std"">", carNumbers[index]
																						 , computeDriverName(driverFornames[index]
																										   , driverSurnames[index]
																										   , driverNickNames[index])
																						 ,  telemetryDB.getCarName(this.Simulator, carNames[index])
																						 , lapTimeDisplayValue(lapTime), laps, delta)
				   . "</td></tr>")
		}

		html .= "</table>"

		return html
	}

	showLapDetails(lap) {
		this.pushTask(ObjBindMethod(this, "syncSessionStore"))

		this.pushTask(ObjBindMethod(this, "showLapDetailsAsync", lap))
	}

	showLapDetailsAsync(lap) {
		local html := ("<div id=""header""><b>" . translate("Lap: ") . lap.Nr . "</b></div>")

		this.initializeReports()

		html .= ("<br><br><div id=""header""><i>" . translate("Overview") . "</i></div>")

		html .= ("<br>" . this.createLapOverview(lap))

		html .= ("<br><br><div id=""header""><i>" . translate("Deltas") . "</i></div>")

		html .= ("<br>" . this.createLapDeltas(lap))

		html .= ("<br><br><div id=""header""><i>" . translate("Standings") . "</i></div>")

		html .= ("<br>" . this.createLapStandings(lap))

		this.showDetails("Lap", html)
	}

	createPitstopPlanDetails(pitstopNr) {
		local html := "<table>"
		local pitstopData := this.SessionStore.Tables["Pitstop.Data"][pitstopNr]
		local pressures := values2String(", ", pitstopData["Tyre.Pressure.Cold.Front.Left"], pitstopData["Tyre.Pressure.Cold.Front.Right"]
									   , pitstopData["Tyre.Pressure.Cold.Rear.Left"], pitstopData["Tyre.Pressure.Cold.Rear.Right"])
		local repairBodywork := pitstopData["Repair.Bodywork"]
		local repairSuspension := pitstopData["Repair.Suspension"]
		local repairEngine := pitstopData["Repair.Engine"]
		local repairs := this.computeRepairs(repairBodyWork, repairSuspension, repairEngine)
		local compound, tyreSet

		html .= ("<tr><td><b>" . translate("Lap:") . "</b></div></td><td>" . (pitstopData.Lap + 1) . "</td></tr>")

		if (pitstopData.Fuel > 0)
			html .= ("<tr><td><b>" . translate("Refuel:") . "</b></div></td><td>" . pitstopData.Fuel . "</td></tr>")

		compound := translate(compound(pitstopData["Tyre.Compound"], pitstopData["Tyre.Compound.Color"]))

		if (compound != "-") {
			tyreSet := pitstopData["Tyre.Set"]

			html .= ("<tr><td><b>" . translate("Tyre Compound:") . "</b></div></td><td>" . compound . "</td></tr>")

			if ((tyreSet != false) && (tyreSet != "-"))
				html .= ("<tr><td><b>" . translate("Tyre Set:") . "</b></div></td><td>" . pitstopData["Tyre.Set"] . "</td></tr>")

			html .= ("<tr><td><b>" . translate("Tyre Pressures:") . "</b></div></td><td>" . pressures . "</td></tr>")
		}

		if (repairs != "-")
			html .= ("<tr><td><b>" . translate("Repairs:") . "</b></div></td><td>" . repairs . "</td></tr>")

		html .= "</table>"

		return html
	}

	createPitstopServiceDetails(pitstopNr) {
		local html := "<table>"
		local serviceData := this.SessionStore.query("Pitstop.Service.Data", {Where: {Pitstop: pitstopNr}})
		local pitstopData, compound, tyreSet, repairs, name, key

		if (serviceData.Length() > 0) {
			serviceData := serviceData[1]

			repairs := this.computeRepairs(serviceData["Bodywork.Repair"]
										 , serviceData["Suspension.Repair"]
										 , serviceData["Engine.Repair"])

			if serviceData.Lap
				html .= ("<tr><td><b>" . translate("Lap:") . "</b></div></td><td>" . serviceData.Lap . "</td></tr>")

			if serviceData.Time
				html .= ("<tr><td><b>" . translate("Service Time:") . "</b></div></td><td>" . Round(serviceData.Time, 1) . "</td></tr>")

			if serviceData["Driver.Previous"]
				html .= ("<tr><td><b>" . translate("Last Driver:") . "</b></div></td><td>" . serviceData["Driver.Previous"] . "</td></tr>")

			if serviceData["Driver.Next"]
				html .= ("<tr><td><b>" . translate("Next Driver:") . "</b></div></td><td>" . serviceData["Driver.Next"] . "</td></tr>")

			if serviceData.Fuel
				html .= ("<tr><td><b>" . translate("Refuel:") . "</b></div></td><td>" . serviceData.Fuel . "</td></tr>")
			else {
				pitstopData := this.SessionStore.Tables["Pitstop.Data"][pitstopNr]

				if (pitstopData.Fuel > 0)
					html .= ("<tr><td><b>" . translate("Refuel:") . "</b></div></td><td>" . pitstopData.Fuel . "</td></tr>")
			}

			compound := translate(compound(serviceData["Tyre.Compound"], serviceData["Tyre.Compound.Color"]))

			if (compound != "-") {
				tyreSet := serviceData["Tyre.Set"]

				html .= ("<tr><td><b>" . translate("Tyre Compound:") . "</b></div></td><td>" . compound . "</td></tr>")

				if ((tyreSet != false) && (tyreSet != "-"))
					html .= ("<tr><td><b>" . translate("Tyre Set:") . "</b></div></td><td>" . serviceData["Tyre.Set"] . "</td></tr>")

				html .= ("<tr><td><b>" . translate("Tyre Pressures:") . "</b></div></td><td>" . values2String(", ", string2Values(",", serviceData["Tyre.Pressures"])*) . "</td></tr>")
			}

			if (repairs != "-")
				html .= ("<tr><td><b>" . translate("Repairs:") . "</b></div></td><td>" . repairs . "</td></tr>")

			html .= "</table>"

			return html
		}
		else
			return ""
	}

	computeTyreWearColor(damage) {
		if (damage < 15)
			return "bgcolor=""Green"" style=""color:#FFFFFF"""
		else if (damage < 25)
			return "bgcolor=""Yellow"""
		else if (damage < 50)
			return "bgcolor=""Orange"""
		else if (damage < 70)
			return "bgcolor=""Red"" style=""color:#FFFFFF"""
		else
			return "bgcolor=""DarkRed"" style=""color:#FFFFFF"""
	}

	computeTyreDamageColor(damage) {
		if ((damage = "-") || (damage < 15))
			return "bgcolor=""Green"" style=""color:#FFFFFF"""
		else if (damage < 25)
			return "bgcolor=""Yellow"" style=""color:#FFFFFF"""
		else if (damage < 40)
			return "bgcolor=""Orange"" style=""color:#FFFFFF"""
		else if (damage < 80)
			return "bgcolor=""Red"" style=""color:#FFFFFF"""
		else
			return "bgcolor=""DarkRed"" style=""color:#FFFFFF"""
	}

	createTyreWearDetails(pitstopNr) {
		local html := "<table>"
		local driver := false
		local laps := false
		local compound := false
		local tyreSet := false
		local tyreNames := []
		local treadData := []
		local wearData := []
		local grainData := []
		local blisterData := []
		local flatSpotData := []
		local hasTread := false
		local hasWear := false
		local hasGrain := false
		local hasBlister := false
		local hasFlatSpot := false
		local tyres := {}
		local compound
		local ignore, tyreData, tyre, key, wear, tread, grain, blister, flatSpot

		for ignore, tyreData in this.SessionStore.query("Pitstop.Tyre.Data", {Where: {Pitstop: pitstopNr}})
			tyres[tyreData.Tyre] := tyreData

		for tyre, key in {FL: "Front.Left", FR: "Front.Right", RL: "Rear.Left", RR: "Rear.Right"} {
			if !driver
				driver := tyres[key]["Driver"]

			if !laps
				laps := tyres[key]["Laps"]

			if !compound
				compound := translate(compound(tyres[key]["Compound"], tyres[key]["Compound.Color"]))

			if !tyreSet
				tyreSet := tyres[key]["Set"]

			tyreNames.Push("<th class=""th-std"">" . translate(tyre) . "</th>")

			wear := tyres[key].Wear
			wearData.Push("<td class=""td-std"" " . this.computeTyreWearColor(tyres[key].Wear) . ">" . wear . "</td>")

			if (wear != "-")
				hasWear := true

			tread := tyres[key].Tread
			if hasWear
				treadData.Push("<td class=""td-std"" " . this.computeTyreWearColor(tyres[key].Wear) . ">"
							 . values2String(", ", string2Values(",", tread)*) . "</td>")
			else
				treadData.Push("<td class=""td-std"">" . values2String(", ", string2Values(",", tread)*) . "</td>")

			if (tread != "-")
				hasTread := true

			grain := tyres[key].Grain
			grainData.Push("<td class=""td-std"" " . this.computeTyreDamageColor(grain) . ">" . grain . "</td>")

			if (grain != "-")
				hasGrain := true

			blister := tyres[key].Blister
			blisterData.Push("<td class=""td-std"" " . this.computeTyreDamageColor(blister) . ">" . blister . "</td>")

			if (blister != "-")
				hasBlister := true

			flatSpot := tyres[key].FlatSpot
			flatSpotData.Push("<td class=""td-std"" " . this.computeTyreDamageColor(flatSpot) . ">" . flatSpot . "</td>")

			if (flatSpot != "-")
				hasFlatSpot := true
		}

		if driver
			html .= ("<tr><td><b>" . translate("Driver:") . "</b></div></td><td>" . driver . "</td></tr>")

		if laps
			html .= ("<tr><td><b>" . translate("Laps:") . "</b></div></td><td>" . laps . "</td></tr>")

		if compound
			html .= ("<tr><td><b>" . translate("Tyre Compound:") . "</b></div></td><td>" . compound . "</td></tr>")

		if tyreSet
			html .= ("<tr><td><b>" . translate("Tyre Set:") . "</b></div></td><td>" . tyreSet . "</td></tr>")

		html .= "</table><br><br>"

		html .= "<table class=""table-std"">"
		html .= ("<tr><th class=""th-std th-left"">" . translate("Tyre") . "</th>" . values2String("", tyreNames*) . "</tr>")

		if hasTread
			html .= ("<tr><th class=""th-std th-left"">" . translate("Tread (mm)") . "</th>" . values2String("", treadData*) . "</tr>")
		else if hasWear
			html .= ("<tr><th class=""th-std th-left"">" . translate("Wear (%)") . "</th>" . values2String("", wearData*) . "</tr>")

		if hasGrain
			html .= ("<tr><th class=""th-std th-left"">" . translate("Grain (%)") . "</th>" . values2String("", grainData*) . "</tr>")

		if hasBlister
			html .= ("<tr><th class=""th-std th-left"">" . translate("Blister (%)") . "</th>" . values2String("", blisterData*) . "</tr>")

		if hasFlatSpot
			html .= ("<tr><th class=""th-std th-left"">" . translate("Flat Spot (%)") . "</th>" . values2String("", flatSpotData*) . "</tr>")

		html .= "</table>"

		return html
	}

	showPitstopDetails(pitstopNr) {
		this.pushTask(ObjBindMethod(this, "syncSessionStore"))

		this.pushTask(ObjBindMethod(this, "showPitstopDetailsAsync", pitstopNr))
	}

	showPitstopDetailsAsync(pitstopNr) {
		local html := ("<div id=""header""><b>" . translate("Pitstop: ") . pitstopNr . "</b></div>")

		html .= ("<br><br><div id=""header""><i>" . translate("Service") . "</i></div>")

		if (this.SessionStore.query("Pitstop.Service.Data", {Where: {Pitstop: pitstopNr}}).Length() = 0)
			html .= ("<br>" . this.createPitstopPlanDetails(pitstopNr))
		else
			html .= ("<br>" . this.createPitstopServiceDetails(pitstopNr))

		if (this.SessionStore.query("Pitstop.Tyre.Data", {Where: {Pitstop: pitstopNr}}).Length() > 0) {
			html .= ("<br><br><div id=""header""><i>" . translate("Tyre Wear") . "</i></div>")

			html .= ("<br>" . this.createTyreWearDetails(pitstopNr))
		}

		this.showDetails("Pitstop", html)
	}

	createPitstopsServiceDetails() {
		local html := "<table class=""table-std"">"
		local headers := []
		local pitstopNRs := []
		local lapData := []
		local timeData := []
		local previousDriverData := []
		local nextDriverData := []
		local refuelData := []
		local tyreCompoundData := []
		local tyreSetData := []
		local tyrePressuresData := []
		local repairsData := []
		local compound, tyreSet, ignore, pitstopData, serviceData, pressures, repairBodywork, repairSuspension, repairs
		local name, key, tyrePressures, header, repairEngine

		for ignore, pitstopData in this.SessionStore.Tables["Pitstop.Data"] {
			pitstopNRs.Push("<th class=""th-std"">" . A_Index . "</th>")

			serviceData := this.SessionStore.query("Pitstop.Service.Data", {Where: {Pitstop: A_Index}})

			if (serviceData.Length() = 0) {
				timeData.Push("<td class=""td-std"">" . "-" . "</td>")
				previousDriverData.Push("<td class=""td-std"">" . "-" . "</td>")
				nextDriverData.Push("<td class=""td-std"">" . "-" . "</td>")

				pressures := values2String(", ", pitstopData["Tyre.Pressure.Cold.Front.Left"], pitstopData["Tyre.Pressure.Cold.Front.Right"]
											   , pitstopData["Tyre.Pressure.Cold.Rear.Left"], pitstopData["Tyre.Pressure.Cold.Rear.Right"])

				repairBodywork := pitstopData["Repair.Bodywork"]
				repairSuspension := pitstopData["Repair.Suspension"]
				repairEngine := pitstopData["Repair.Engine"]

				repairs := this.computeRepairs(repairBodywork, repairSuspension, repairEngine)

				repairsData.Push("<td class=""td-std"">" . repairs . "</td>")

				lapData.Push("<td class=""td-std"">" . (pitstopData.Lap + 1) . "</td>")
				refuelData.Push("<td class=""td-std"">" . ((pitstopData.Fuel != 0) ? pitstopData.Fuel : "-") . "</td>")

				compound := translate(compound(pitstopData["Tyre.Compound"], pitstopData["Tyre.Compound.Color"]))

				tyreCompoundData.Push("<td class=""td-std"">" . compound . "</td>")

				tyreSet := pitstopData["Tyre.Set"]

				if (compound = "-") {
					tyreSet := "-"
					pressures := "-, -, -, -"
				}

				tyreSetData.Push("<td class=""td-std"">" . tyreSet . "</td>")
				tyrePressuresData.Push("<td class=""td-std"">" . pressures . "</td>")
			}
			else {
				serviceData := serviceData[1]

				repairs := this.computeRepairs(serviceData["Bodywork.Repair"]
											 , serviceData["Suspension.Repair"]
											 , serviceData["Engine.Repair"])

				repairsData.Push("<td class=""td-std"">" . repairs . "</td>")

				lapData.Push("<td class=""td-std"">" . (serviceData.Lap ? serviceData.Lap : "-") . "</td>")
				timeData.Push("<td class=""td-std"">" . (serviceData.Time ? Round(serviceData.Time, 1) : "-") . "</td>")
				previousDriverData.Push("<td class=""td-std"">" . (serviceData["Driver.Previous"] ? serviceData["Driver.Previous"] : "-") . "</td>")
				nextDriverData.Push("<td class=""td-std"">" . (serviceData["Driver.Next"] ? serviceData["Driver.Next"] : "-") . "</td>")
				refuelData.Push("<td class=""td-std"">" . (serviceData.Fuel ? ((pitstopData.Fuel != 0) ? pitstopData.Fuel : "-") : "-") . "</td>")

				compound := translate(compound(serviceData["Tyre.Compound"], serviceData["Tyre.Compound.Color"]))

				tyreCompoundData.Push("<td class=""td-std"">" . compound . "</td>")

				tyreSet := serviceData["Tyre.Set"]
				tyrePressures := serviceData["Tyre.Pressures"]

				if (compound = "-") {
					tyreSet := "-"
					tyrePressures := "-, -, -, -"
				}
				else
					tyrePressures := values2String(", ", string2Values(",", tyrePressures)*)

				tyreSetData.Push("<td class=""td-std"">" . tyreSet . "</td>")
				tyrePressuresData.Push("<td class=""td-std"">" . tyrePressures . "</td>")
			}
		}

		for ignore, header in ["Pitstop", "Lap", "Service Time", "Last Driver", "Next Driver", "Refuel", "Tyre Compound", "Tyre Set", "Tyre Pressures", "Repairs"]
			headers.Push("<th class=""th-std"">" . translate(header) . "</th>")

		html .= ("<tr>" . values2String("", headers*) . "</tr>")

		loop % pitstopNRs.Length()
			html .= ("<tr>" . pitstopNRs[A_Index] . lapData[A_Index] . timeData[A_Index]
							. previousDriverData[A_Index] . nextDriverData[A_Index] . refuelData[A_Index]
							. tyreCompoundData[A_Index] . tyreSetData[A_Index] . tyrePressuresData[A_Index]
							. repairsData[A_Index]
				   . "</tr>")

		html .= "</table>"

		return html
	}

	showPitstopsDetails() {
		this.pushTask(ObjBindMethod(this, "syncSessionStore"))

		this.pushTask(ObjBindMethod(this, "showPitstopsDetailsAsync"))
	}

	showPitstopsDetailsAsync() {
		local html := ("<div id=""header""><b>" . translate("Pitstops Summary") . "</b></div>")

		html .= ("<br><br><div id=""header""><i>" . translate("Service") . "</i></div>")

		html .= ("<br>" . this.createPitstopsServiceDetails())

		if (this.SessionStore.Tables["Pitstop.Tyre.Data"].Length() > 0)
			loop % this.SessionStore.Tables["Pitstop.Data"].Length()
				if (this.SessionStore.query("Pitstop.Tyre.Data", {Where: {Pitstop: A_Index}}).Length() > 0) {
					html .= ("<br><br><div id=""header""><i>" . translate("Tyre Wear (Pitstop: ") . A_Index . translate(")") . "</i></div>")

					html .= ("<br>" . this.createTyreWearDetails(A_Index))
				}

		this.showDetails("Pitstops", html)
	}

	createDriverDetails(drivers) {
		local driverData := []
		local stintsData := []
		local lapsData := []
		local drivingTimesData := []
		local avgLapTimesData := []
		local avgFuelConsumptionsData := []
		local accidentsData := []
		local ignore, driver, drivingTime, lapAccidents, lapTimes, fuelConsumptions, ignore, lap, html

		for ignore, driver in drivers {
			driverData.Push("<th class=""th-std"">" . StrReplace(driver.FullName, "'", "\'") . "</th>")
			stintsData.Push("<td class=""td-std"">" . driver.Stints.Length() . "</td>")
			lapsData.Push("<td class=""td-std"">" . driver.Laps.Length() . "</td>")

			drivingTime := 0
			lapAccidents := 0
			lapTimes := []
			fuelConsumptions := []

			for ignore, lap in driver.Laps {
				drivingTime += lap.Laptime
				lapTimes.Push(lap.Laptime)
				fuelConsumptions.Push(lap.FuelConsumption)

				if lap.Accident
					lapAccidents += 1
			}

			drivingTimesData.Push("<td class=""td-std"">" . Round(drivingTime / 60) . "</td>")
			avgLapTimesData.Push("<td class=""td-std"">" . lapTimeDisplayValue(Round(average(lapTimes), 1)) . "</td>")
			avgFuelConsumptionsData.Push("<td class=""td-std"">" . Round(average(fuelConsumptions), 2) . "</td>")
			accidentsData.Push("<td class=""td-std"">" . lapAccidents . "</td>")
		}

		html := "<table class=""table-std"">"
		html .= ("<tr><th class=""th-std th-left"">" . translate("Driver") . "</th>" . values2String("", driverData*) . "</tr>")
		html .= ("<tr><th class=""th-std th-left"">" . translate("Stints") . "</th>" . values2String("", stintsData*) . "</tr>")
		html .= ("<tr><th class=""th-std th-left"">" . translate("Laps") . "</th>" . values2String("", lapsData*) . "</tr>")
		html .= ("<tr><th class=""th-std th-left"">" . translate("Driving Time") . "</th>" . values2String("", drivingTimesData*) . "</tr>")
		html .= ("<tr><th class=""th-std th-left"">" . translate("Avg. Lap Time") . "</th>" . values2String("", avgLapTimesData*) . "</tr>")
		html .= ("<tr><th class=""th-std th-left"">" . translate("Avg. Consumption") . "</th>" . values2String("", avgFuelConsumptionsData*) . "</tr>")
		html .= ("<tr><th class=""th-std th-left"">" . translate("Accidents") . "</th>" . values2String("", accidentsData*) . "</tr>")
		html .= "</table>"

		return html
	}

	createDriverPaceChart(chartID, width, height, drivers) {
		local drawChartFunction := "function drawChart" . chartID . "() {`nvar array = [`n"
		local length := 2000000
		local lapTimes := []
		local validDriverTimes := []
		local ignore, driver, lap, value, driverTimes, avg, stdDev, index, time, validTimes, text, seconds

		for ignore, driver in drivers
			length := Min(length, driver.Laps.Length())

		if (length = 2000000)
			return ""

		for ignore, driver in drivers {
			driverTimes := []

			for ignore, lap in driver.Laps {
				if (A_Index > length)
					break

				value := chartValue(null(lap.Laptime))

				if !isNull(value)
					driverTimes.Push(value)
			}

			loop 2 {
				avg := average(driverTimes)
				stdDev := stdDeviation(driverTimes)

				for index, time in driverTimes
					if ((time <= 0) || ((time > avg) && (Abs(time - avg) > (stdDev / 2))))
						driverTimes[index] := false

				validTimes := []

				for ignore, time in driverTimes
					if time
						validTimes.Push(time)

				driverTimes := validTimes
			}

			length := Min(length, driverTimes.Length())

			validDriverTimes.Push(driverTimes)
		}

		for index, driver in drivers {
			validTimes := validDriverTimes[index]
			driverTimes := []

			loop %length%
				driverTimes.Push(validTimes[A_Index])

			driverTimes.InsertAt(1, "'" . driver.FullName . "'")

			lapTimes.Push("[" . values2String(", ", driverTimes*) . "]")
		}

		drawChartFunction .= (values2String("`n, ", lapTimes*) . "];")

		drawChartFunction .= "`nvar data = new google.visualization.DataTable();"
		drawChartFunction .= "`ndata.addColumn('string', '" . translate("Driver") . "');"

		loop %length%
			drawChartFunction .= "`ndata.addColumn('number', '" . translate("Lap") . A_Space . A_Index . "');"

		text =
		(
		data.addColumn({id:'max', type:'number', role:'interval'});
		data.addColumn({id:'min', type:'number', role:'interval'});
		data.addColumn({id:'firstQuartile', type:'number', role:'interval'});
		data.addColumn({id:'median', type:'number', role:'interval'});
		data.addColumn({id:'thirdQuartile', type:'number', role:'interval'});
		)

		drawChartFunction .= ("`n" . text)

		drawChartFunction .= ("`n" . "data.addRows(getBoxPlotValues(array, " . (length + 1) . "));")

		drawChartFunction .= ("`n" . getPaceJSFunctions())

		text =
		(
		var options = {
			backgroundColor: 'D8D8D8', chartArea: { left: '10`%', top: '5`%', right: '5`%', bottom: '20`%' },
			legend: { position: 'none' },
		)

		drawChartFunction .= text

		drivers := translate("Drivers")
		seconds := translate("Seconds")

		text =
		(
			hAxis: { title: '%drivers%', gridlines: {count: 0} },
			vAxis: { title: '%seconds%', gridlines: {count: 0} },
			lineWidth: 0,
			series: [ { 'color': 'D8D8D8' } ],
			intervals: { barWidth: 1, boxWidth: 1, lineWidth: 2, style: 'boxes' },
			interval: { max: { style: 'bars', fillOpacity: 1, color: '#777' },
						min: { style: 'bars', fillOpacity: 1, color: '#777' } }
		};
		)

		drawChartFunction .= ("`n" . text)

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return drawChartFunction
	}

	createDriverPerformanceChart(chartID, width, height, drivers) {
		local drawChartFunction := "function drawChart" . chartID . "() {"
		local driverNames := []
		local potentialsData := []
		local raceCraftsData := []
		local speedsData := []
		local consistenciesData := []
		local carControlsData := []
		local ignore, driver, minValue, maxValue

		for ignore, driver in drivers {
			driverNames.Push(StrReplace(driver.FullName, "'", "\'"))
			potentialsData.Push(driver.Potential)
			raceCraftsData.Push(driver.RaceCraft)
			speedsData.Push(driver.Speed)
			consistenciesData.Push(driver.Consistency)
			carControlsData.Push(driver.CarControl)
		}

		drawChartFunction .= "`nvar data = google.visualization.arrayToDataTable(["
		drawChartFunction .= "`n['" . values2String("', '", translate("Category"), driverNames*) . "'],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Potential") . "'", potentialsData*) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Race Craft") . "'", raceCraftsData*) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Speed") . "'", speedsData*) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Consistency") . "'", consistenciesData*) . "],"
		drawChartFunction .= "`n[" . values2String(", ", "'" . translate("Car Control") . "'", carControlsData*) . "]"

		drawChartFunction .= ("`n]);")

		minValue := Min(0, minimum(potentialsData), minimum(raceCraftsData), minimum(speedsData), minimum(consistenciesData), minimum(carControlsData))
		maxValue := Max(maximum(potentialsData), maximum(raceCraftsData), maximum(speedsData), maximum(consistenciesData), maximum(carControlsData))

		drawChartFunction .= "`nvar options = { bars: 'horizontal', backgroundColor: 'D8D8D8', chartArea: { left: '15%', top: '5%', right: '30%', bottom: '10%' }, hAxis: {viewWindowMode: 'explicit', viewWindow: {min: " . minValue . ", max: " . maxValue . "}, gridlines: {count: 0} }, vAxis: {gridlines: {count: 0}} };"
		drawChartFunction .= ("`nvar chart = new google.visualization.BarChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return drawChartFunction
	}

	showDriverStatistics() {
		local html := ("<div id=""header""><b>" . translate("Driver Statistics") . "</b></div>")
		local ignore, driver, width, chart1, chart2

		for ignore, driver in this.Drivers
			this.updateDriverStatistics(driver)

		html .= ("<br><br><div id=""header""><i>" . translate("Overview") . "</i></div>")

		html .= ("<br>" . this.createDriverDetails(this.Drivers))

		width := (detailsViewer.Width - 20)

		html .= ("<br><br><div id=""header""><i>" . translate("Pace") . "</i></div>")

		chart1 := this.createDriverPaceChart(1, width, 248, this.Drivers)

		html .= ("<br><br><div id=""chart_1" . """ style=""width: " . width . "px; height: 248px""></div>")

		html .= ("<br><br><div id=""header""><i>" . translate("Performance") . "</i></div>")

		chart2 := this.createDriverPerformanceChart(2, width, 248, this.Drivers)

		html .= ("<br><br><div id=""chart_2" . """ style=""width: " . width . "px; height: 248px""></div>")

		this.showDetails("Driver", html, [1, chart1], [2, chart2])
	}

	createRaceSummaryChart(chartID, width, height, lapSeries, positionSeries, fuelSeries, tyreSeries) {
		local drawChartFunction := ("function drawChart" . chartID . "() {")
		local ignore, time

		drawChartFunction .= "`nvar data = new google.visualization.DataTable();"
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Lap") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Position") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Fuel Level") . "');")
		drawChartFunction .= ("`ndata.addColumn('number', '" . translate("Tyre Laps") . "');")
		drawChartFunction .= "`ndata.addRows(["

		for ignore, time in lapSeries {
			if (A_Index > 1)
				drawChartFunction .= ", "

			drawChartFunction .= ("[" . values2String(", ", lapSeries[A_Index]
														  , chartValue(null(positionSeries[A_Index]))
														  , chartValue(null(fuelSeries[A_Index]))
														  , chartValue(null(tyreSeries[A_Index])))
									  . "]")
		}

		drawChartFunction .= ("]);`nvar options = { legend: { position: 'Right' }, chartArea: { left: '10%', top: '5%', right: '25%', bottom: '20%' }, hAxis: { title: '" . translate("Lap") . "', gridlines: {count: 0} }, vAxis: { viewWindow: { min: 0 }, gridlines: {count: 0} }, backgroundColor: 'D8D8D8' };`n")

		drawChartFunction .= ("`nvar chart = new google.visualization.LineChart(document.getElementById('chart_" . chartID . "')); chart.draw(data, options); }")

		return drawChartFunction
	}

	showRaceSummary() {
		local html := ("<div id=""header""><b>" . translate("Race Summary") . "</b></div>")
		local stints := []
		local drivers := []
		local laps := []
		local durations := []
		local numLaps := []
		local positions := []
		local avgLapTimes := []
		local fuelConsumptions := []
		local accidents := []
		local currentStint := this.CurrentStint
		local positions := []
		local remainingFuels := []
		local tyreLaps := []
		local lastLap := this.LastLap
		local lapDataTable := this.SessionStore.Tables["Lap.Data"]
		local stint, duration, ignore, lap, width, chart1

		html .= ("<br><br><div id=""header""><i>" . translate("Stints") . "</i></div>")

		if currentStint
			loop % currentStint.Nr
			{
				stint := this.Stints[A_Index]

				stints.Push("<th class=""th-std"">" . stint.Nr . "</th>")
				drivers.Push("<td class=""td-std"">" . StrReplace(stint.Driver.Fullname, "'", "\'") . "</td>")
				laps.Push("<td class=""td-std"">" . stint.Lap . "</td>")

				duration := 0

				for ignore, lap in stint.Laps
					duration += lap.Laptime

				durations.Push("<td class=""td-std"">" . Round(duration / 60) . "</td>")
				numLaps.Push("<td class=""td-std"">" . stint.Laps.Length() . "</td>")
				positions.Push("<td class=""td-std"">" . stint.StartPosition . translate(" -> ") . stint.EndPosition . "</td>")
				avgLapTimes.Push("<td class=""td-std"">" . lapTimeDisplayValue(stint.AvgLaptime) . "</td>")
				fuelConsumptions.Push("<td class=""td-std"">" . stint.FuelConsumption . "</td>")
				accidents.Push("<td class=""td-std"">" . stint.Accidents . "</td>")
			}

		html .= "<br><table class=""table-std"">"

		html .= ("<tr><th class=""th-std"">" . translate("Stint") . "</th>"
			       . "<th class=""th-std"">" . translate("Driver") . "</th>"
			       . "<th class=""th-std"">" . translate("Lap") . "</th>"
			       . "<th class=""th-std"">" . translate("Duration") . "</th>"
			       . "<th class=""th-std"">" . translate("Laps") . "</th>"
			       . "<th class=""th-std"">" . translate("Position") . "</th>"
			       . "<th class=""th-std"">" . translate("Avg. Lap Time") . "</th>"
			       . "<th class=""th-std"">" . translate("Consumption") . "</th>"
			       . "<th class=""th-std"">" . translate("Accidents") . "</th>"
			   . "</tr>")

		loop % stints.Length()
			html .= ("<tr>" . stints[A_Index]
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

		html .= ("<br><br><div id=""header""><i>" . translate("Race Course") . "</i></div>")

		laps := []
		positions := []

		if lastLap
			loop % lastLap.Nr
			{
				lap := this.Laps[A_Index]

				laps.Push(A_Index)
				positions.Push(lap.Position)
				remainingFuels.Push(lap.FuelRemaining)
				tyreLaps.Push(lapDataTable[A_Index]["Tyre.Laps"])
			}

		width := (detailsViewer.Width - 20)

		chart1 := this.createRaceSummaryChart(1, width, 248, laps, positions, remainingFuels, tyreLaps)

		html .= ("<br><br><div id=""chart_1" . """ style=""width: " . width . "px; height: 248px""></div>")

		this.showDetails("Session", html, [1, chart1])
	}

	showPlanDetails() {
		local html := ("<div id=""header""><b>" . translate("Plan Summary") . "</b></div>")
		local window := this.Window
		local currentListView, stint, driver, timePlanned, timeActual, lapPlanned, lapActual, refuelAmount, tyreChange

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.PlanListView

			html .= "<br><br><table class=""table-std"">"

			html .= ("<tr><th class=""th-std"">" . translate("Stint") . "</th>"
				   . "<th class=""th-std"">" . translate("Driver") . "</th>"
				   . "<th class=""th-std"">" . translate("Time (est.)") . "</th>"
				   . "<th class=""th-std"">" . translate("Time (act.)") . "</th>"
				   . "<th class=""th-std"">" . translate("Lap (est.)") . "</th>"
				   . "<th class=""th-std"">" . translate("Lap (act.)") . "</th>"
				   . "<th class=""th-std"">" . translate("Refuel") . "</th>"
				   . "<th class=""th-std"">" . translate("Tyre Change") . "</th>"
				   . "</tr>")

			loop % LV_GetCount()
			{
				LV_GetText(stint, A_Index, 1)
				LV_GetText(driver, A_Index, 2)
				LV_GetText(timePlanned, A_Index, 3)
				LV_GetText(timeActual, A_Index, 4)
				LV_GetText(lapPlanned, A_Index, 5)
				LV_GetText(lapActual, A_Index, 6)
				LV_GetText(refuelAmount, A_Index, 7)
				LV_GetText(tyreChange, A_Index, 8)

				html .= ("<tr><th class=""th-std"">" . stint . "</th>"
					   . "<td class=""td-std"">" . driver . "</td>"
					   . "<td class=""td-std"">" . timePlanned . "</td>"
					   . "<td class=""td-std"">" . timeActual . "</td>"
					   . "<td class=""td-std"">" . lapPlanned . "</td>"
					   . "<td class=""td-std"">" . lapActual . "</td>"
					   . "<td class=""td-std"">" . refuelAmount . "</td>"
					   . "<td class=""td-std"">" . tyreChange . "</td>"
					   . "</tr>")
			}

			html .= "</table>"
		}
		finally {
			Gui ListView, %currentListView%
		}

		this.showDetails("Plan", html)
	}

	showSetupsDetails() {
		local html := ("<div id=""header""><b>" . translate("Setups Summary") . "</b></div>")
		local window := this.Window
		local currentListView, driver, conditions, compound, pressures

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % this.SetupsListView

			html .= "<br><br><table class=""table-std"">"

			html .= ("<th class=""th-std"">" . translate("Driver") . "</th>"
				   . "<th class=""th-std"">" . translate("Conditions") . "</th>"
				   . "<th class=""th-std"">" . translate("Compound") . "</th>"
				   . "<th class=""th-std"">" . translate("Prs. FL") . "</th>"
				   . "<th class=""th-std"">" . translate("Prs. FR") . "</th>"
				   . "<th class=""th-std"">" . translate("Prs. RL") . "</th>"
				   . "<th class=""th-std"">" . translate("Prs. RR") . "</th>"
				   . "</tr>")

			loop % LV_GetCount()
			{
				LV_GetText(driver, A_Index, 1)
				LV_GetText(conditions, A_Index, 2)
				LV_GetText(compound, A_Index, 3)
				LV_GetText(pressures, A_Index, 4)

				pressures := string2Values(",", pressures)

				html .= ("<td class=""td-std"">" . driver . "</td>"
					   . "<td class=""td-std"">" . conditions . "</td>"
					   . "<td class=""td-std"">" . compound . "</td>"
					   . "<td class=""td-std"">" . pressures[1] . "</td>"
					   . "<td class=""td-std"">" . pressures[2] . "</td>"
					   . "<td class=""td-std"">" . pressures[3] . "</td>"
					   . "<td class=""td-std"">" . pressures[4] . "</td>"
					   . "</tr>")
			}

			html .= "</table>"
		}
		finally {
			Gui ListView, %currentListView%
		}

		this.showDetails("Setups", html)
	}

	computeCarStatistics(car, laps, ByRef lapTime, ByRef potential, ByRef raceCraft, ByRef speed, ByRef consistency, ByRef carControl) {
		local raceData := true
		local drivers := false
		local positions := true
		local times := true
		local cars := []
		local count := 0
		local potentials := false
		local raceCrafts := false
		local speeds := false
		local consistencies := false
		local carControls := false
		local oldLapSettings

		lapTime := 0

		this.ReportViewer.loadReportData(laps, raceData, drivers, positions, times)

		loop % getConfigurationValue(raceData, "Cars", "Count")
			cars.Push(A_Index)

		loop % laps.Length()
			if times[A_Index].HasKey(car) {
				lapTime += times[A_Index][car]
				count += 1
			}

		if (count > 0)
			lapTime := ((lapTime / count) / 1000)

		count := laps.Length()
		laps := []

		loop %count%
			laps.Push(A_Index)

		oldLapSettings := (this.ReportViewer.Settings.HasKey("Laps") ? this.ReportViewer.Settings["Laps"] : false)

		try {
			this.ReportViewer.Settings["Laps"] := laps

			this.ReportViewer.getDriverStatistics(raceData, cars, positions, times, potentials, raceCrafts, speeds, consistencies, carControls)
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

	getTrafficScenario(strategy, targetLap, randomFactor, numScenarios, useLapTimeVariation, useDriverErrors, usePitstops, overTakeDelta) {
		local lastLap := this.LastLap
		local positions, startLap, endLap, avgLapTime, driver, stintLength, formationLap, postRaceLap
		local fuelCapacity, safetyFuel, pitstopDelta, pitstopFuelService, pitstopTyreService, pitstopServiceOrder
		local lastPositions, lastRunnings, count, laps, consideredLaps, curLap, carPositions, nextRunnings
		local lapTime, potential, raceCraft, speed, consistency, carControl
		local rnd, delta, running, nr, position, ignore, nextPositions, runnings, car

		if (this.SessionActive && lastLap) {
			positions := lastLap.Positions

			if positions {
				startLap := lastLap.Nr
				endLap := targetLap
				avgLapTime := Min(lastLap.Laptime, this.CurrentStint.AvgLapTime)

				positions := parseConfiguration(positions)

				driver := getConfigurationValue(positions, "Position Data", "Driver.Car")

				stintLength := false
				formationLap := false
				postRaceLap := false
				fuelCapacity := false
				safetyFuel := false
				pitstopDelta := false
				pitstopFuelService := false
				pitstopTyreService := false
				pitstopServiceOrder := "Simultaneous"

				this.getSessionSettings(stintLength, formationLap, postRaceLap, fuelCapacity, safetyFuel
									  , pitstopDelta, pitstopFuelService, pitstopTyreService, pitstopServiceOrder)

				lastPositions := []
				lastRunnings := []

				count := getConfigurationValue(positions, "Position Data", "Car.Count", 0)

				loop %count% {
					lastPositions.Push(getConfigurationValue(positions, "Position Data", "Car." . A_Index . ".Position", 0))
					lastRunnings.Push(getConfigurationValue(positions, "Position Data", "Car." . A_Index . ".Lap", 0)
									+ getConfigurationValue(positions, "Position Data", "Car." . A_Index . ".Lap.Running", 0))
				}

				laps := {}

				consideredLaps := []

				loop % Min(startLap, 10)
					consideredLaps.Push(startLap - (A_Index - 1))

				loop % endLap - startLap
				{
					curLap := A_Index

					carPositions := []
					nextRunnings := []

					loop %count% {
						lapTime := true
						potential := true
						raceCraft := true
						speed := true
						consistency := true
						carControl := true

						this.computeCarStatistics(A_Index, consideredLaps, lapTime, potential, raceCraft, speed, consistency, carControl)

						if useLapTimeVariation {
							Random rnd, -1.0, 1.0

							lapTime += (rnd * ((5 - consistency) / 5) * (randomFactor / 100))
						}

						if useDriverErrors {
							Random, rnd, 0.0, 1.0

							lapTime += (rnd * ((5 - carControl) / 5) * (randomFactor / 100))
						}

						if (usePitstops && ((startLap + curLap) == targetLap) && (A_Index != driver)) {
							Random rnd, 0.0, 1.0

							if (rnd < (randomFactor / 100))
								lapTime += strategy.calcPitstopDuration(fuelCapacity, true)
						}
						else if ((A_Index == driver) && ((startLap + curLap) == targetLap))
							lapTime += (pitstopDelta + (pitstopFuelService * fuelCapacity) + pitstopTyreService)

						delta := (((avgLapTime + lapTime) / lapTime) - 1)

						running := (lastRunnings[A_Index] + delta)

						nextRunnings.Push(running)
						carPositions.Push(Array(A_Index, lapTime, running))
					}

					bubbleSort(carPositions, "positionsOrder")

					for nr, position in carPositions
						position[3] += ((lastPositions[position[1]] - nr) * (overTakeDelta / position[2]))

					bubbleSort(carPositions, "positionsOrder")

					nextPositions := []

					loop %count%
						nextPositions.Push(false)

					for nr, position in carPositions {
						car := position[1]

						nextPositions[car] := nr
						nextRunnings[car] := position[3]
					}

					runnings := []

					for ignore, running in nextRunnings
						runnings.Push(running - Floor(running))

					laps[startLap + A_Index] := {Positions: nextPositions, Runnings: runnings}

					lastPositions := nextPositions
					lastRunnings := nextRunnings
				}

				return {Driver: driver, Laps: laps}
			}
		}

		return false
	}

	getTrafficPositions(trafficScenario, targetLap, ByRef driver, ByRef positions, ByRef runnings) {
		if (trafficScenario && trafficScenario.Laps.HasKey(targetLap)) {
			if driver
				driver := trafficScenario.Driver

			if positions
				positions := trafficScenario.Laps[targetLap].Positions

			if runnings
				runnings := trafficScenario.Laps[targetLap].Runnings

			return true
		}
		else {
			if driver
				driver := false

			if positions
				positions := []

			if runnings
				runnings := []

			return false
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

manageTeam(raceCenterOrCommand, teamDrivers := false) {
	local x, y, row, driver, owner, ignore, name

	static result := false

	static availableDriversListView
	static selectedDriversListView

	static selectDriverButton
	static deselectDriverButton
	static upDriverButton
	static downDriverButton

	if (raceCenterOrCommand = kCancel)
		result := kCancel
	else if (raceCenterOrCommand = kOk)
		result := kOk
	else if (raceCenterOrCommand = "SelectDriver") {
		Gui ListView, %availableDriversListView%

		row := LV_GetNext(0)

		LV_GetText(driver, row)
		LV_Delete(row)

		Gui ListView, %selectedDriversListView%

		LV_Add("Select Vis", driver)

		updateTeamManager()
	}
	else if (raceCenterOrCommand = "DeselectDriver") {
		Gui ListView, %selectedDriversListView%

		row := LV_GetNext(0)

		LV_GetText(driver, row)
		LV_Delete(row)

		Gui ListView, %availableDriversListView%

		LV_Add("Vis", driver)

		updateTeamManager()
	}
	else if (raceCenterOrCommand = "UpDriver") {
		Gui ListView, %selectedDriversListView%

		row := LV_GetNext(0)

		LV_GetText(driver, row)
		LV_Delete(row)

		LV_Insert(row - 1, "Select Vis", driver)

		updateTeamManager()
	}
	else if (raceCenterOrCommand = "DownDriver") {
		Gui ListView, %selectedDriversListView%

		row := LV_GetNext(0)

		LV_GetText(driver, row)
		LV_Delete(row)

		LV_Insert(row + 1, "Select Vis", driver)

		updateTeamManager()
	}
	else if (raceCenterOrCommand = "UpdateState") {
		Gui TE:Default

		Gui ListView, %availableDriversListView%

		if LV_GetNext(0)
			GuiControl Enable, selectDriverButton
		else
			GuiControl Disable, selectDriverButton

		Gui ListView, %selectedDriversListView%

		row := LV_GetNext(0)

		if row {
			GuiControl Enable, deselectDriverButton

			if (row > 1)
				GuiControl Enable, upDriverButton
			else
				GuiControl Disable, upDriverButton

			if (row < LV_GetCount())
				GuiControl Enable, downDriverButton
			else
				GuiControl Disable, downDriverButton
		}
		else {
			GuiControl Disable, deselectDriverButton
			GuiControl Disable, upDriverButton
			GuiControl Disable, downDriverButton
		}
	}
	else {
		result := false

		owner := raceCenterOrCommand.Window

		Gui TE:Default
		Gui TE:+Owner%owner%

		Gui %owner%:+Disabled

		Gui TE:-Border ; -Caption
		Gui TE:Color, D0D0D0, D8D8D8

		Gui TE:Font, s10 Bold, Arial

		Gui TE:Add, Text, w392 Center gmoveTeamManager, % translate("Modular Simulator Controller System")

		Gui TE:Font, s9 Norm, Arial
		Gui TE:Font, Italic Underline, Arial

		Gui TE:Add, Text, x148 YP+20 w112 cBlue Center gopenTeamManagerDocumentation, % translate("Team Selection")

		Gui TE:Font, s8 Norm, Arial

		Gui TE:Add, ListView, x16 yp+30 w160 h184 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDavailableDriversListView gupdateTeamManager Section, % values2String("|", map(["Available Driver"], "translate")*)

		if !teamDrivers
			teamDrivers := raceCenterOrCommand.TeamDrivers

		for name, ignore in raceCenterOrCommand.SessionDrivers
			if !inList(teamDrivers, name)
				LV_Add("", name)

		Gui TE:Add, ListView, x230 ys w160 h184 AltSubmit -Multi -LV0x10 NoSort NoSortHdr HWNDselectedDriversListView gupdateTeamManager, % values2String("|", map(["Selected Driver"], "translate")*)

		for ignore, name in teamDrivers
			LV_Add("", name)

		Gui TE:Font, s10 Bold, Arial

		Gui TE:Add, Button, x183 ys+75 w40 vselectDriverButton gselectTeamDriver, >
		Gui TE:Add, Button, x183 yp+30 w40 vdeselectDriverButton gdeselectTeamDriver, <

		upDriverButton := false
		downDriverButton := false

		Gui TE:Add, Button, x205 ys+25 w23 h23 HWNDupDriverButton vupDriverButton gupTeamDriver
		Gui TE:Add, Button, x205 ys+161 w23 h23 HWNDdownDriverButton vdownDriverButton gdownTeamDriver

		setButtonIcon(upDriverButton, kIconsDirectory . "Up Arrow.ico", 1, "W12 H12 L6 T6 R6 B6")
		setButtonIcon(downDriverButton, kIconsDirectory . "Down Arrow.ico", 1, "W12 H12 L4 T4 R4 B4")

		Gui TE:Font, s8 Norm, Arial

		Gui TE:Add, Text, x8 ys+194 w392 0x10

		Gui TE:Add, Button, x120 yp+10 w80 h23 Default GacceptTeamManager, % translate("Ok")
		Gui TE:Add, Button, x208 yp w80 h23 GcancelTeamManager, % translate("&Cancel")

		if getWindowPosition("Race Center.Team Manager", x, y)
			Gui TE:Show, x%x% y%y%
		else
			Gui TE:Show

		updateTeamManager()

		loop
			Sleep 100
		until result

		if (result = kOk) {
			Gui TE:Default
			Gui ListView, %selectedDriversListView%

			result := []

			loop % LV_GetCount()
			{
				LV_GetText(driver, A_Index)

				result.Push(driver)
			}
		}
		else
			result := false

		Gui %owner%:-Disabled

		Gui TE:Destroy

		return result
	}
}

acceptTeamManager() {
	manageTeam(kOk)
}

cancelTeamManager() {
	manageTeam(kCancel)
}

updateTeamManager() {
	manageTeam("UpdateState")
}

selectTeamDriver() {
	manageTeam("SelectDriver")
}

deselectTeamDriver() {
	manageTeam("DeselectDriver")
}

upTeamDriver() {
	manageTeam("UpDriver")
}

downTeamDriver() {
	manageTeam("DownDriver")
}

moveTeamManager() {
	moveByMouse("TE", "Race Center.Team Manager")
}

openTeamManagerDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#session--stint-planning
}

loginDialog(connectorOrCommand := false, teamServerURL := false) {
	local title, window

	static result := false

	static nameEdit := ""
	static passwordEdit := ""

	if (connectorOrCommand == kOk)
		result := kOk
	else if (connectorOrCommand == kCancel)
		result := kCancel
	else {
		result := false
		window := "TSL"

		Gui %window%:New

		Gui %window%:Default

		Gui %window%:-Border ; -Caption
		Gui %window%:Color, D0D0D0, D8D8D8

		Gui %window%:Font, Norm, Arial

		Gui %window%:Add, Text, x16 y16 w90 h23 +0x200, % translate("Server URL")
		Gui %window%:Add, Text, x110 yp w160 h23 +0x200, %teamServerURL%

		Gui %window%:Add, Text, x16 yp+30 w90 h23 +0x200, % translate("Name")
		Gui %window%:Add, Edit, x110 yp+1 w160 h21 VnameEdit, %nameEdit%
		Gui %window%:Add, Text, x16 yp+23 w90 h23 +0x200, % translate("Password")
		Gui %window%:Add, Edit, x110 yp+1 w160 h21 Password VpasswordEdit, %passwordEdit%

		Gui %window%:Add, Button, x60 yp+35 w80 h23 Default gacceptLogin, % translate("Ok")
		Gui %window%:Add, Button, x146 yp w80 h23 gcancelLogin, % translate("&Cancel")

		Gui %window%:Show, AutoSize Center

		while !result
			Sleep 100

		Gui %window%:Submit
		Gui %window%:Destroy

		if (result == kCancel)
			return false
		else if (result == kOk) {
			try {
				connectorOrCommand.Connect(teamServerURL)

				return connectorOrCommand.Login(nameEdit, passwordEdit)
			}
			catch exception {
				title := translate("Error")

				OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
				MsgBox 262160, %title%, % (translate("Cannot connect to the Team Server.") . "`n`n" . translate("Error: ") . exception.Message)
				OnMessage(0x44, "")

				return false
			}
		}
	}
}

acceptLogin() {
	loginDialog(kOk)
}

cancelLogin() {
	loginDialog(kCancel)
}

validateNumber(field) {
	local oldValue := %field%

	GuiControlGet %field%

	if %field% is not Number
	{
		%field% := oldValue

		GuiControl, , %field%, %oldValue%
	}
}

validatePitstopPressureFL() {
	validateNumber("pitstopPressureFLEdit")
}

validatePitstopPressureFR() {
	validateNumber("pitstopPressureFREdit")
}

validatePitstopPressureRL() {
	validateNumber("pitstopPressureRLEdit")
}

validatePitstopPressureRR() {
	validateNumber("pitstopPressureRREdit")
}

lapTimeDisplayValue(lapTime) {
	return RaceReportViewer.lapTimeDisplayValue(lapTime)
}

displayValue(value) {
	return (isNull(value) ? "-" : value)
}

chartValue(value) {
	return (isNull(value) ? kNull : value)
}

null(value) {
	return (((value == 0) || (value == "-") || (value = "n/a")) ? kNull : valueOrNull(value))
}

objectOrder(a, b) {
	return (a.Nr > b.Nr)
}

positionsOrder(a, b) {
	return (a[3] < b[3])
}

parseObject(properties) {
	local result := {}
	local property

	properties := StrReplace(properties, "`r", "")

	loop Parse, properties, `n
	{
		property := string2Values("=", A_LoopField)

		result[property[1]] := property[2]
	}

	return result
}

loadTeams(connector) {
	local teams := {}
	local ignore, identifier, team

	try {
		for ignore, identifier in string2Values(";", connector.GetAllTeams()) {
			team := parseObject(connector.GetTeam(identifier))

			teams[team.Name] := team.Identifier
		}
	}
	catch exception {
		logError(exception)
	}

	return teams
}

loadSessions(connector, team) {
	local sessions := {}
	local ignore, identifier, session

	if team
		for ignore, identifier in string2Values(";", connector.GetTeamSessions(team)) {
			try {
				session := parseObject(connector.GetSession(identifier))

				sessions[session.Name] := session.Identifier
			}
			catch exception {
				logError(exception)
			}
		}

	return sessions
}

loadDrivers(connector, team) {
	local drivers := {}
	local ignore, identifier, driver, name

	if team
		for ignore, identifier in string2Values(";", connector.GetTeamDrivers(team)) {
			try {
				driver := parseObject(connector.GetDriver(identifier))

				name := computeDriverName(driver.ForName, driver.SurName, driver.NickName)

				drivers[name] := driver.Identifier
			}
			catch exception {
				logError(exception)
			}
		}

	return drivers
}

moveRaceCenter() {
	moveByMouse(RaceCenter.Instance.Window, "Race Center")
}

closeRaceCenter() {
	RaceCenter.Instance.close()
}

connectServer() {
	local rCenter := RaceCenter.Instance

	GuiControlGet serverURLEdit
	GuiControlGet serverTokenEdit

	rCenter.iServerURL := serverURLEdit
	rCenter.iServerToken := ((serverTokenEdit = "") ? "__INVALID__" : serverTokenEdit)

	rCenter.connect()
}

chooseTeam() {
	local rCenter := RaceCenter.Instance

	GuiControlGet teamDropDownMenu

	rCenter.withExceptionhandler(ObjBindMethod(rCenter, "selectTeam")
							   , getValues(rCenter.Teams)[teamDropDownMenu])
}

chooseSession() {
	local rCenter := RaceCenter.Instance

	GuiControlGet sessionDropDownMenu

	rCenter.withExceptionhandler(ObjBindMethod(rCenter, "selectSession")
							   , getValues(rCenter.Sessions)[sessionDropDownMenu])
}

chooseChartType() {
	local rCenter := RaceCenter.Instance

	GuiControlGet chartTypeDropDown

	rCenter.selectChartType(["Scatter", "Bar", "Bubble", "Line"][chartTypeDropDown])
}

sessionMenu() {
	GuiControlGet sessionMenuDropDown

	GuiControl Choose, sessionMenuDropDown, 1

	RaceCenter.Instance.withExceptionhandler(ObjBindMethod(RaceCenter.Instance, "chooseSessionMenu", sessionMenuDropDown))
}

planMenu() {
	GuiControlGet planMenuDropDown

	GuiControl Choose, planMenuDropDown, 1

	RaceCenter.Instance.withExceptionhandler(ObjBindMethod(RaceCenter.Instance, "choosePlanMenu", planMenuDropDown))
}

strategyMenu() {
	GuiControlGet strategyMenuDropDown

	GuiControl Choose, strategyMenuDropDown, 1

	RaceCenter.Instance.withExceptionhandler(ObjBindMethod(RaceCenter.Instance, "chooseStrategyMenu", strategyMenuDropDown))
}

pitstopMenu() {
	GuiControlGet pitstopMenuDropDown

	GuiControl Choose, pitstopMenuDropDown, 1

	RaceCenter.Instance.withExceptionhandler(ObjBindMethod(RaceCenter.Instance, "choosePitstopMenu", pitstopMenuDropDown))
}

openDashboardDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server#race-center
}

updateDate() {
	local rCenter := RaceCenter.Instance

	GuiControlGet sessionDateCal

	rCenter.iDate := sessionDateCal
}

updateTime() {
	local rCenter := RaceCenter.Instance
	local time := rCenter.Time
	local currentListView := A_DefaultListView

	GuiControlGet sessionTimeEdit

	EnvSub time, %sessionTimeEdit%, Minutes

	rCenter.iTime := sessionTimeEdit

	rCenter.updatePlan(-time)

	try {
		Gui ListView, % rCenter.PlanListView

		loop % LV_GetCount()
			LV_Modify(A_Index, "-Select")

		rCenter.iSelectedPlanStint := false

		rCenter.updateState()
		}
	finally {
		Gui ListView, %currentListView%
	}
}

addSetup() {
	local rCenter := RaceCenter.Instance
	local title

	if (rCenter.SessionDrivers.Count() > 0)
		rCenter.withExceptionhandler(ObjBindMethod(rCenter, "addSetup"))
	else {
		title := translate("Information")

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		MsgBox 262192, %title%, % translate("There are no drivers available. Please select a valid session first.")
		OnMessage(0x44, "")
	}
}

copySetup() {
	local rCenter := RaceCenter.Instance
	local window := rCenter.Window
	local currentListView, row

	Gui %window%:Default

	currentListView := A_DefaultListView

	try {
		Gui ListView, % rCenter.SetupsListView

		row := LV_GetNext(0)

		if (row != rCenter.SelectedSetup) {
			LV_Modify(row, "-Select")

			row := false
			rCenter.iSelectedSetup := false
		}

		if LV_GetNext(0)
			rCenter.withExceptionhandler(ObjBindMethod(rCenter, "copySetup"))
	}
	finally {
		Gui ListView, %currentListView%
	}
}

deleteSetup() {
	local rCenter := RaceCenter.Instance
	local window := rCenter.Window
	local currentListView, row, title

	Gui %window%:Default

	currentListView := A_DefaultListView

	try {
		Gui ListView, % rCenter.SetupsListView

		row := LV_GetNext(0)

		if (row != rCenter.SelectedSetup) {
			LV_Modify(row, "-Select")

			row := false
			rCenter.iSelectedSetup := false
		}

		if LV_GetNext(0) {
			title := translate("Delete")

			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			MsgBox 262436, %title%, % translate("Do you really want to delete the current driver specific setup?")
			OnMessage(0x44, "")

			IfMsgBox Yes
				rCenter.withExceptionhandler(ObjBindMethod(rCenter, "deleteSetup"))
		}
	}
	finally {
		Gui ListView, %currentListView%
	}
}

chooseSetup() {
	local rCenter, window, currentListView
	local driver, conditions, compound, pressures, temperatures

	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0)) {
		rCenter := RaceCenter.Instance

		window := rCenter.Window

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % rCenter.SetupsListView

			rCenter.iSelectedSetup := A_EventInfo

			LV_GetText(driver, A_EventInfo, 1)
			LV_GetText(conditions, A_EventInfo, 2)
			LV_GetText(compound, A_EventInfo, 3)
			LV_GetText(pressures, A_EventInfo, 4)

			conditions := string2Values(translate("("), conditions)
			temperatures := string2Values(", ", StrReplace(conditions[2], translate(")"), ""))

			setupAirTemperatureEdit := temperatures[1]
			setupTrackTemperatureEdit := temperatures[2]

			pressures := string2Values(",", pressures)

			setupBasePressureFLEdit := pressures[1]
			setupBasePressureFREdit := pressures[2]
			setupBasePressureRLEdit := pressures[3]
			setupBasePressureRREdit := pressures[4]

			GuiControl Choose, setupDriverDropDownMenu, % inList(getKeys(rCenter.SessionDrivers), driver)

			GuiControl Choose, setupWeatherDropDownMenu, % inList(map(kWeatherConditions, "translate"), conditions[1])
			GuiControl Choose, setupCompoundDropDownMenu, % inList(map(rCenter.TyreCompounds, "translate"), compound)

			GuiControl, , setupAirTemperatureEdit, %setupAirTemperatureEdit%
			GuiControl, , setupTrackTemperatureEdit, %setupTrackTemperatureEdit%

			GuiControl, , setupBasePressureFLEdit, %setupBasePressureFLEdit%
			GuiControl, , setupBasePressureFREdit, %setupBasePressureFREdit%
			GuiControl, , setupBasePressureRLEdit, %setupBasePressureRLEdit%
			GuiControl, , setupBasePressureRREdit, %setupBasePressureRREdit%

			rCenter.updateState()
		}
		finally {
			Gui ListView, %currentListView%
		}
	}
}

releaseSetups() {
	local rCenter := RaceCenter.Instance
	local title

	if rCenter.SessionActive
		rCenter.withExceptionhandler(ObjBindMethod(rCenter, "releaseSetups"))
	else {
		title := translate("Information")

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
		MsgBox 262192, %title%, % translate("You are not connected to an active session.")
		OnMessage(0x44, "")
	}
}

updateSetup() {
	RaceCenter.Instance.pushTask("updateSetupAsync")
}

updateSetupAsync() {
	local rCenter := RaceCenter.Instance
	local window := rCenter.Window
	local currentListView, row

	Gui %window%:Default

	currentListView := A_DefaultListView

	try {
		Gui ListView, % rCenter.SetupsListView

		row := LV_GetNext(0)

		if (row != rCenter.SelectedSetup) {
			LV_Modify(row, "-Select")

			row := false
			rCenter.iSelectedSetup := false
		}

		if (row > 0) {
			GuiControlGet setupDriverDropDownMenu

			validateNumber("setupBasePressureFLEdit")
			validateNumber("setupBasePressureFREdit")
			validateNumber("setupBasePressureRLEdit")
			validateNumber("setupBasePressureRREdit")

			GuiControlGet setupBasePressureFLEdit
			GuiControlGet setupBasePressureFREdit
			GuiControlGet setupBasePressureRLEdit
			GuiControlGet setupBasePressureRREdit

			GuiControlGet setupWeatherDropDownMenu
			GuiControlGet setupAirTemperatureEdit
			GuiControlGet setupTrackTemperatureEdit
			GuiControlGet setupCompoundDropDownMenu

			LV_Modify(row, "", getKeys(rCenter.SessionDrivers)[setupDriverDropDownMenu]
							 , translate(kWeatherConditions[setupWeatherDropDownMenu]) . A_Space
									   . translate("(") . setupAirTemperatureEdit . ", " . setupTrackTemperatureEdit . translate(")")
							 , translate(rCenter.TyreCompounds[setupCompoundDropDownMenu])
							 , values2String(", ", setupBasePressureFLEdit, setupBasePressureFREdit, setupBasePressureRLEdit, setupBasePressureRREdit))
		}

		if (rCenter.SelectedDetailReport = "Setups")
			rCenter.showSetupsDetails()
	}
	finally {
		Gui ListView, %currentListView%
	}
}

choosePlan() {
	local rCenter, window, currentListView
	local stint, driver, timePlanned, timeActual, lapPlanned, lapActual, refuelAmount, tyreChange, time, currentTime

	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0)) {
		rCenter := RaceCenter.Instance

		window := rCenter.Window

		Gui %window%:Default

		currentListView := A_DefaultListView

		try {
			Gui ListView, % rCenter.PlanListView

			rCenter.iSelectedPlanStint := A_EventInfo

			LV_GetText(stint, A_EventInfo, 1)
			LV_GetText(driver, A_EventInfo, 2)
			LV_GetText(timePlanned, A_EventInfo, 3)
			LV_GetText(timeActual, A_EventInfo, 4)
			LV_GetText(lapPlanned, A_EventInfo, 5)
			LV_GetText(lapActual, A_EventInfo, 6)
			LV_GetText(refuelAmount, A_EventInfo, 7)
			LV_GetText(tyreChange, A_EventInfo, 8)

			time := string2Values(":", timePlanned)

			currentTime := "20200101000000"

			if (time.Length() = 2) {
				EnvAdd currentTime, time[1], Hours
				EnvAdd currentTime, time[2], Minutes
			}

			timePlanned := currentTime

			time := string2Values(":", timeActual)

			currentTime := "20200101000000"

			if (time.Length() = 2) {
				EnvAdd currentTime, time[1], Hours
				EnvAdd currentTime, time[2], Minutes
			}

			timeActual := currentTime

			GuiControl Choose, planDriverDropDownMenu, % (inList(getKeys(rCenter.SessionDrivers), driver) + 1)
			GuiControl, , planTimeEdit, %timePlanned%
			GuiControl, , actTimeEdit, %timeActual%
			GuiControl, , planLapEdit, %lapPlanned%
			GuiControl, , actLapEdit, %lapActual%
			GuiControl, , planRefuelEdit, %refuelAmount%
			GuiControl Choose, planTyreCompoundDropDown, % ((tyreChange = "x") ? 1 : 2)

			rCenter.updateState()
		}
		finally {
			Gui ListView, %currentListView%
		}
	}
}

updatePlan() {
	RaceCenter.Instance.pushTask("updatePlanAsync")
}

updatePlanAsync() {
	local rCenter := RaceCenter.Instance
	local window := rCenter.Window
	local currentListView, row, stint, time

	Gui %window%:Default

	currentListView := A_DefaultListView

	try {
		Gui ListView, % rCenter.PlanListView

		row := LV_GetNext(0)

		if (row != rCenter.SelectedPlanStint) {
			LV_Modify(row, "-Select")

			row := false
			rCenter.iSelectedPlanStint := false
		}

		if (row > 0) {
			GuiControlGet planDriverDropDownMenu
			GuiControlGet planTimeEdit
			GuiControlGet actTimeEdit
			GuiControlGet planLapEdit
			GuiControlGet actLapEdit
			GuiControlGet planRefuelEdit
			GuiControlGet planTyreCompoundDropDown

			if (planDriverDropDownMenu = 1)
				LV_Modify(row, "Col2", "")
			else
				LV_Modify(row, "Col2", getKeys(rCenter.SessionDrivers)[planDriverDropDownMenu - 1])

			FormatTime time, %planTimeEdit%, HH:mm

			LV_Modify(row, "Col3", ((time = "00:00") ? "" : time))

			FormatTime time, %actTimeEdit%, HH:mm

			LV_Modify(row, "Col4", ((time = "00:00") ? "" : time))

			LV_GetText(stint, row)

			if (stint > 1)
				LV_Modify(row, "Col5", planLapEdit, actLapEdit, planRefuelEdit, (planTyreCompoundDropDown = 2) ? "" : "x")

			if (rCenter.SelectedDetailReport = "Plan")
				rCenter.showPlanDetails()
		}
	}
	finally {
		Gui ListView, %currentListView%
	}
}

addPlan() {
	local rCenter := RaceCenter.Instance
	local window := rCenter.Window
	local currentListView, row, title

	Gui %window%:Default

	currentListView := A_DefaultListView

	try {
		Gui ListView, % rCenter.PlanListView

		row := LV_GetNext(0)

		if (row != rCenter.SelectedPlanStint) {
			LV_Modify(row, "-Select")

			row := false
			rCenter.iSelectedPlanStint := false
		}

		if row {
			title := translate("Insert")

			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Before", "After", "Cancel"]))
			MsgBox 262179, %title%, % translate("Do you want to add the new entry before or after the currently selected entry?")
			OnMessage(0x44, "")

			IfMsgBox Cancel
				return

			IfMsgBox Yes
				rCenter.withExceptionhandler(ObjBindMethod(rCenter, "addPlan", "Before"))

			IfMsgBox No
				rCenter.withExceptionhandler(ObjBindMethod(rCenter, "addPlan", "After"))
		}
		else
			rCenter.withExceptionhandler(ObjBindMethod(rCenter, "addPlan"))
	}
	finally {
		Gui ListView, %currentListView%
	}
}

deletePlan() {
	local rCenter := RaceCenter.Instance
	local window := rCenter.Window
	local currentListView, row, title

	Gui %window%:Default

	currentListView := A_DefaultListView

	try {
		Gui ListView, % rCenter.PlanListView

		row := LV_GetNext(0)

		if (row != rCenter.SelectedPlanStint) {
			LV_Modify(row, "-Select")

			row := false
			rCenter.iSelectedPlanStint := false
		}

		if LV_GetNext(0) {
			title := translate("Delete")

			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Yes", "No"]))
			MsgBox 262436, %title%, % translate("Do you really want to delete the selected plan entry?")
			OnMessage(0x44, "")

			IfMsgBox Yes
				rCenter.withExceptionhandler(ObjBindMethod(rCenter, "deletePlan"))
		}
	}
	finally {
		Gui ListView, %currentListView%
	}
}

releasePlan() {
	local rCenter := RaceCenter.Instance

	rCenter.withExceptionhandler(ObjBindMethod(rCenter, "releasePlan"))
}

updateState() {
	local rCenter := RaceCenter.Instance

	rCenter.withExceptionhandler(ObjBindMethod(rCenter, "updateState"))
}

planPitstop() {
	local rCenter := RaceCenter.Instance

	rCenter.withExceptionhandler(ObjBindMethod(rCenter, "planPitstop"))
}

chooseStint() {
	local rCenter := RaceCenter.Instance
	local currentListView, stint

	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0)) {
		currentListView := A_DefaultListView

		try {
			Gui ListView, % rCenter.StintsListView

			LV_GetText(stint, A_EventInfo, 1)

			rCenter.withExceptionhandler(ObjBindMethod(rCenter, "showStintDetails", rCenter.Stints[stint]))
		}
		finally {
			Gui ListView, %currentListView%
		}
	}
}

chooseLap() {
	local rCenter := RaceCenter.Instance
	local currentListView, lap

	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0)) {
		currentListView := A_DefaultListView

		try {
			Gui ListView, % rCenter.LapsListView

			LV_GetText(lap, A_EventInfo, 1)

			rCenter.withExceptionhandler(ObjBindMethod(rCenter, "showLapDetails", rCenter.Laps[lap]))
		}
		finally {
			Gui ListView, %currentListView%
		}
	}
}

choosePitstop() {
	local rCenter := RaceCenter.Instance
	local currentListView, pitstop

	if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0)) {
		currentListView := A_DefaultListView

		try {
			Gui ListView, % rCenter.PitstopsListView

			LV_GetText(pitstop, A_EventInfo, 1)

			rCenter.withExceptionhandler(ObjBindMethod(rCenter, "showPitstopDetails", pitstop))
		}
		finally {
			Gui ListView, %currentListView%
		}
	}
}

chooseReport() {
	local rCenter := RaceCenter.Instance
	local currentListView

	if rCenter.isWorking()
		return

	currentListView := A_DefaultListView

	try {
		Gui ListView, % reportsListView

		if rCenter.HasData {
			if (((A_GuiEvent = "Normal") || (A_GuiEvent = "RightClick")) && (A_EventInfo > 0))
				rCenter.showReport(kSessionReports[A_EventInfo])
		}
		else
			loop % LV_GetCount()
				LV_Modify(A_Index, "-Select")
	}
	finally {
		Gui ListView, %currentListView%
	}
}

chooseDriver() {
	local rCenter := RaceCenter.Instance
	local window := rCenter.Window

	Gui %window%:Default

	GuiControlGet driverDropDown

	rCenter.withExceptionHandler(ObjBindMethod(rCenter, "selectDriver"
							   , (driverDropDown = 1) ? true : rCenter.AvailableDrivers[driverDropDown - 1]))
}

chooseAxis() {
	local rCenter := RaceCenter.Instance

	rCenter.withExceptionhandler(ObjBindMethod(rCenter, "showTelemetryReport"))
}

reportSettings() {
	local rCenter := RaceCenter.Instance

	rCenter.withExceptionhandler(ObjBindMethod(rCenter, "reportSettings", rCenter.SelectedReport))
}


chooseSimulationSettings() {
	local rCenter := RaceCenter.Instance

	GuiControlGet useSessionDataDropDown
	GuiControlGet useTelemetryDataDropDown
	GuiControlGet keepMapDropDown
	GuiControlGet considerTrafficDropDown

	rCenter.iUseSessionData := (useSessionDataDropDown == 1)
	rCenter.iUseTelemetryDatabase := (useTelemetryDataDropDown == 1)
	rCenter.iUseCurrentMap := (keepMapDropDown == 1)
	rCenter.iUseTraffic := (considerTrafficDropDown == 1)

	rCenter.updateState()
}

setTyrePressures(compound, compoundColor, flPressure, frPressure, rlPressure, rrPressure) {
	local rCenter := RaceCenter.Instance

	rCenter.withExceptionhandler(ObjBindMethod(rCenter, "initializePitstopTyreSetup", compound, compoundColor, flPressure, frPressure, rlPressure, rrPressure))

	return false
}

startupRaceCenter() {
	local icon := kIconsDirectory . "Console.ico"
	local rCenter

	Menu Tray, Icon, %icon%, , 1
	Menu Tray, Tip, Race Center

	fixIE(11)

	rCenter := new RaceCenter(kSimulatorConfiguration, readConfiguration(kUserConfigDirectory . "Race.settings"))

	rCenter.createGui(rCenter.Configuration)

	rCenter.connect(true)

	registerMessageHandler("Setup", "functionMessageHandler")

	rCenter.show()

	ExitApp 0
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

startupRaceCenter()