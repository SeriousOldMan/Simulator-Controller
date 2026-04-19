;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - ACE Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Task.ahk"
#Include "Libraries\SimulatorPlugin.ahk"
#Include "Libraries\ACEUDPProvider.ahk"
#Include "Libraries\ACEProvider.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kACEApplication := "Assetto Corsa EVO"

global kACEPlugin := "ACE"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACEPlugin extends RaceAssistantSimulatorPlugin {
	static sCarData := false

	iUDPProvider := false

	iSessionID := 0

	iStandingsDataFuture := false

	class ACEProvider extends ACEProvider {
		iPlugin := false

		__New(plugin, car, track) {
			this.iPlugin := plugin

			super.__New(car, track, plugin.UDPProvider)
		}

		acquireStandingsData(telemetryData, finished := false) {
			return this.iPlugin.acquireStandingsData(telemetryData, finished)
		}

		acquireSessionData(&telemetryData, &standingsData, finished := false) {
			if !this.iPlugin.iStandingsDataFuture
				this.iPlugin.iStandingsDataFuture := this.iPlugin.UDPProvider.getStandingsDataFuture()

			super.acquireSessionData(&telemetryData, &standingsData, finished)
		}
	}

	UDPProvider {
		Get {
			return this.iUDPProvider
		}
	}

	__New(controller, name, simulator, configuration := false) {
		super.__New(controller, name, simulator, configuration, false)

		if (this.Active || (isDebug() && isDevelopment())) {
			this.iUDPProvider := ACEUDPProvider(this.getArgumentValue("udpConnection", false))

			controller.registerPlugin(this)
		}
	}

	createSimulatorProvider() {
		return ACEPlugin.ACEProvider(this, this.Car, this.Track)
	}

	static requireCarDatabase() {
		local data

		if !ACEPlugin.sCarData {
			data := readMultiMap(kResourcesDirectory . "Simulator Data\ACE\Car Data.ini")

			if FileExist(kUserHomeDirectory . "Simulator Data\ACE\Car Data.ini")
				addMultiMapValues(data, readMultiMap(kUserHomeDirectory . "Simulator Data\ACE\Car Data.ini"))

			ACEPlugin.sCarData := data
		}
	}

	simulatorStartup(simulator) {
		if (simulator = kACEApplication)
			Task.startTask(ObjBindMethod(ACEPlugin, "requireCarDatabase"), 1000, kLowPriority)

		super.simulatorStartup(simulator)
	}

	driverActive(data, driverForname, driverSurname) {
		return this.sessionActive(data)
	}

	updateSession(session, force := false) {
		local lastSession := this.Session

		super.updateSession(session, force)

		if (session > kSessionOther)
			this.UDPProvider.startup((lastSession != session) && (lastSession != kSessionPaused))
		else if (session != kSessionPaused)
			if this.UDPProvider
				this.UDPProvider.shutdown(true)
	}

	prepareSession(settings, data) {
		local shortName, longName

		if (getMultiMapValue(data, "Session Data", "Track", "") != "")
			shortName := getMultiMapValue(data, "Session Data", "TrackShortName", "Unknown")
			longName := getMultiMapValue(data, "Session Data", "TrackLongName", "Unknown")

			shortName := StrReplace(shortName, "Circuit of the Americas", "COTA")
			shortName := StrReplace(shortName, "Circuit de Spa Francorchamps", "Spa")
			shortName := StrReplace(shortName, "Sebring International Raceway", "Sebring")
			shortName := StrReplace(shortName, "Watkins Glen International", "Watkins Glen")

			SessionDatabase.registerTrack(getMultiMapValue(data, "Session Data", "Simulator", "Unknown")
										, getMultiMapValue(data, "Session Data", "Car", "Unknown")
										, getMultiMapValue(data, "Session Data", "Track")
										, shortName, longName)

		super.prepareSession(settings, data)
	}

	supportsRaceAssistant(assistantPlugin) {
		return ((FileExist(kBinariesDirectory . "Providers\ACE UDP Provider.exe") != false) && super.supportsRaceAssistant(assistantPlugin))
	}

	acquireStandingsData(telemetryData, finished := false) {
		local standingsData, session
		local lap, restart, fileName, tries
		local driverID, driverForname, driverSurname, driverNickname, lapTime, car, driverCar, driverCarCandidate

		static lastDriverCar := false
		static sessionID := 0
		static lastLap := 0

		ACEPlugin.requireCarDatabase()

		lap := getMultiMapValue(telemetryData, "Stint Data", "Laps", 0)

		if ((lastLap > lap) && (this.iSessionID = sessionID)) {
			sessionID += 1

			restart := true
		}
		else
			restart := false

		this.iSessionID := sessionID

		lastLap := lap

		if (restart || !this.iStandingsDataFuture)
			this.iStandingsDataFuture := this.UDPProvider.getStandingsDataFuture(restart)

		try {
			standingsData := this.iStandingsDataFuture.StandingsData
		}
		finally {
			this.iStandingsDataFuture := false
		}

		if standingsData {
			session := getMultiMapValue(standingsData, "Session Data", "Session", kUndefined)

			if (session != kUndefined) {
				removeMultiMapValues(standingsData, "Session Data")

				setMultiMapValue(telemetryData, "Session Data", "Session", session)
			}

			if ((lap <= 1) || restart)
				lastDriverCar := false

			driverForname := getMultiMapValue(telemetryData, "Stint Data", "DriverForname", "John")
			driverSurname := getMultiMapValue(telemetryData, "Stint Data", "DriverSurname", "Doe")
			driverNickname := getMultiMapValue(telemetryData, "Stint Data", "DriverNickname", "JD")
			driverID := getMultiMapValue(telemetryData, "Session Data", "ID", kUndefined)

			lapTime := getMultiMapValue(telemetryData, "Stint Data", "LapLastTime", 0)

			driverCar := false
			driverCarCandidate := false

			loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0) {
				car := SessionDatabase.getCarCode(this.Simulator
												, getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Car"))

				setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Class"
							   , getMultiMapValue(ACEProvider.sCarData, "Car Classes", car, "Unknown"))

				if (getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID", false) = driverID) {
					driverCar := A_Index

					lastDriverCar := driverCar
				}
				else if !driverCar
					if ((getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Forname") = driverForname)
					 && (getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Surname") = driverSurname)) {
						driverCar := A_Index

						lastDriverCar := driverCar
					}
			}

			if !driverCar
				loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0)
					if (getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Position")
					  = getMultiMapValue(telemetryData, "Stint Data", "Position", kUndefined)) {
						driverCar := A_Index

						lastDriverCar := driverCar

						break
					}
					else if (getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Time") = lapTime)
						driverCarCandidate := A_Index

			if !driverCar
				driverCar := (lastDriverCar ? lastDriverCar : driverCarCandidate)

			setMultiMapValue(standingsData, "Position Data", "Driver.Car", driverCar)

			return (finished ? standingsData : this.correctStandingsData(standingsData))
		}
		else {
			if this.UDPProvider
				this.UDPProvider.shutdown(true)

			return newMultiMap()
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startACE(executable := false) {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kACEPlugin).Simulator
													 , "Simulator Splash Images\ACE Splash.jpg"
													 , executable)
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeACEPlugin() {
	local controller := SimulatorController.Instance

	ACEPlugin(controller, kACEPlugin, kACEApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACEPlugin()