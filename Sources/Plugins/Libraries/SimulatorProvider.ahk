;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Simulator Provider              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\CLR.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSessionUnknown := -2
global kSessionFinished := 0
global kSessionPaused := -1
global kSessionOther := 1
global kSessionPractice := 2
global kSessionQualification := 3
global kSessionRace := 4
global kSessionTimeTrial := 5

global kSessions := [kSessionOther, kSessionPractice, kSessionQualification, kSessionRace, kSessionTimeTrial]
global kSessionNames := ["Other", "Practice", "Qualification", "Race", "Time Trial"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SimulatorProvider {
	iCar := false
	iTrack := false

	class GenericSimulatorProvider extends SimulatorProvider {
		iSimulator := false

		Simulator {
			Get {
				return this.iSimulator
			}
		}

		__New(simulator, car, track) {
			this.iSimulator := SessionDatabase.getSimulatorName(simulator)

			super.__New(car, track)
		}
	}

	Simulator {
		Get {
			throw "Virtual property Simulator must be implemented in a subclass..."
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

	Active {
		Get {
			return Application(this.Simulator, kSimulatorConfiguration).isRunning()
		}
	}

	__New(car, track) {
		this.iCar := SessionDatabase.getCarCode(this.Simulator, car)
		this.iTrack := SessionDatabase.getTrackCode(this.Simulator, track)
	}

	static createSimulatorProvider(simulator, car, track) {
		local name := SessionDatabase.getSimulatorName(simulator)
		local code := SessionDatabase.getSimulatorCode(simulator)

		try {
			return %code%Provider(car, track)
		}
		catch Any {
			return SimulatorProvider.GenericSimulatorProvider(name, car, track)
		}
	}

	correctStandingsData(standingsData, needCorrection := false) {
		local positions := Map()
		local cars := []
		local count, position

		count := getMultiMapValue(standingsData, "Position Data", "Car.Count", 0)

		if !needCorrection
			loop count {
				position := (getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Position", 0) + 0)

				if positions.Has(position)
					needCorrection := true
				else
					positions[position] := true
			}

		if needCorrection {
			loop count
				cars.Push(Array(A_Index, getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Laps"
																	   , getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Lap"))
									   + getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Lap.Running")))

			bubbleSort(&cars, (c1, c2) => c1[2] < c2[2])

			if isDebug() {
				loop count {
					if (getMultiMapValue(standingsData, "Position Data", "Car." . cars[A_Index][1] . ".Position") != A_Index)
						logMessage(kLogDebug, "Corrected position for car " . cars[A_Index][1] . ": "
											. getMultiMapValue(standingsData, "Position Data", "Car." . cars[A_Index][1] . ".Position")
											. " -> " . A_Index)

					setMultiMapValue(standingsData, "Position Data", "Car." . cars[A_Index][1] . ".Position", A_Index)
				}
			}
			else
				loop count
					setMultiMapValue(standingsData, "Position Data", "Car." . cars[A_Index][1] . ".Position", A_Index)
		}

		return standingsData
	}

	readTelemetryData() {
		local trackData, data

		static sessionDB := false

		if !sessionDB
			sessionDB := SessionDatabase()

		trackData := sessionDB.getTrackData(this.Simulator, this.Track)

		return this.readSessionData(trackData ? ("Track=" . trackData) : "")
	}

	readStandingsData(telemetryData, correct := false) {
		local standingsData

		if telemetryData.Has("Position Data") {
			standingsData := newMultiMap()

			setMultiMapValues(standingsData, "Position Data", getMultiMapValues(telemetryData, "Position Data"))
		}
		else
			standingsData := this.readSessionData("Standings=true")

		if correct {
			standingsData := this.correctStandingsData(standingsData)

			if telemetryData.Has("Position Data")
				telemetryData["Position Data"] := standingsData["Position Data"]
		}

		return standingsData
	}

	acquireTelemetryData() {
		return this.readTelemetryData()
	}

	acquireStandingsData(telemetryData, finished := false) {
		return this.readStandingsData(telemetryData, !finished)
	}

	acquireSessionData(&telemetryData, &standingsData, finished := false) {
		local count, driver, carNr

		telemetryData := this.acquireTelemetryData()
		standingsData := this.acquireStandingsData(telemetryData, finished)

		count := getMultiMapValue(standingsData, "Position Data", "Car.Count", 0)
		driver := getMultiMapValue(standingsData, "Position Data", "Driver.Car", false)

		loop count {
			carNr := StrReplace(getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Nr", ""), "`"", "")

			if !IsAlnum(carNr)
				carNr := "-"

			setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Nr", carNr)
		}

		if (driver && (count > 0))
			if (getMultiMapValue(standingsData, "Position Data", "Car." . driver . ".InPitLane", false)
			 && !getMultiMapValue(telemetryData, "Stint Data", "InPitLane", false))
				setMultiMapValue(telemetryData, "Stint Data", "InPitLane", true)
	}

	readSessionData(options := "", protocol?) {
		local simulator := this.Simulator
		local car := this.Car
		local track := this.Track
		local data := callSimulator(SessionDatabase.getSimulatorCode(simulator), options, protocol?)
		local tyreCompound, tyreCompoundColor, ignore, section

		for ignore, section in ["Car Data", "Setup Data"] {
			tyreCompound := getMultiMapValue(data, section, "TyreCompound", kUndefined)

			if (tyreCompound = kUndefined) {
				tyreCompound := getMultiMapValue(data, section, "TyreCompoundRaw", kUndefined)

				if ((tyreCompound != kUndefined) && tyreCompound) {
					tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, kUndefined)

					if (tyreCompound = kUndefined)
						tyreCompound := normalizeCompound("Dry")

					if tyreCompound {
						splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor := false)

						setMultiMapValue(data, section, "TyreCompound", tyreCompound)
						setMultiMapValue(data, section, "TyreCompoundColor", tyreCompoundColor)
					}
				}
			}
		}

		return data
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Public Functions Section                        ;;;
;;;-------------------------------------------------------------------------;;;

callSimulator(simulator, options := "", protocol?) {
	local exePath, dataFile, data
	local connector, curWorkingDir, buf
	local dllName, dllFile

	static defaultProtocol := getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "Simulator", "Data Provider", "DLL")
	static protocols := CaseInsenseMap("AC", "CLR", "ACC", "DLL", "R3E", "DLL", "IRC", "DLL"
									 , "AMS2", "DLL", "PCARS2", "DLL", "RF2", "CLR", "LMU", "CLR")
	static connectors := CaseInsenseMap()

	simulator := SessionDatabase.getSimulatorCode(simulator)

	if (defaultProtocol = "EXE")
		protocol := "EXE"
	else if (!isSet(protocol) && protocols.Has(simulator))
		protocol := protocols[simulator]

	if (options = "Close") {
		connector := false

		if ((protocol = "DLL") && connectors.Has(simulator . ".DLL"))
			connector := connectors[simulator . ".DLL"]
		else if ((protocol = "CLR") && connectors.Has(simulator . ".CLR"))
			connector := connectors[simulator . ".CLR"]

		if connector
			if (protocol = "DLL")
				DLLCall(simulator . " SHM Connector\close")
			else
				connector.Close()
	}
	else
		try {
			if (protocol = "DLL") {
				if connectors.Has(simulator . ".DLL")
					connector := connectors[simulator . ".DLL"]
				else {
					curWorkingDir := A_WorkingDir

					SetWorkingDir(kBinariesDirectory . "Connectors\")

					try {
						connector := DllCall("LoadLibrary", "Str", simulator . " SHM Connector.dll", "Ptr")

						DLLCall(simulator . " SHM Connector\open")

						connectors[simulator . ".DLL"] := connector
					}
					finally {
						SetWorkingDir(curWorkingDir)
					}
				}

				buf := Buffer(1024 * 1024)

				DllCall(simulator . " SHM Connector\call", "AStr", options, "Ptr", buf, "Int", buf.Size)

				data := parseMultiMap(StrGet(buf, "UTF-8"))

				if (data.Count = 0)
					throw ("DLL returned empty data in callSimulator for " . simulator . "...")
			}
			else if (protocol = "CLR") {
				if connectors.Has(simulator . ".CLR")
					connector := connectors[simulator . ".CLR"]
				else {
					dllName := (simulator . " SHM Connector.dll")
					dllFile := (kBinariesDirectory . "Connectors\" . dllName)

					if !FileExist(dllFile)
						throw "Unable to find " . dllName . " in " . kBinariesDirectory . "..."

					connector := CLR_LoadLibrary(dllFile).CreateInstance("SHMConnector.SHMConnector")

					if (!connector.Open() && !isDebug())
						throw "Cannot startup " . dllName . " in " . kBinariesDirectory . "..."

					connectors[simulator . ".CLR"] := connector
				}

				data := parseMultiMap(connector.Call(options))

				if (data.Count = 0)
					throw ("DLL returned empty data in callSimulator for " . simulator . "...")
			}
			else if (protocol = "EXE") {
				exePath := (kBinariesDirectory . "Providers\" . simulator . " SHM Provider.exe")

				if !FileExist(exePath)
					throw "File not found..."

				DirCreate(kTempDirectory . simulator . " Data")

				dataFile := temporaryFileName(simulator . " Data\SHM", "data")

				RunWait(A_ComSpec . " /c `"`"" . exePath . "`" `"" . options . "`" > `"" . dataFile . "`"`"", , "Hide")

				data := readMultiMap(dataFile)

				deleteFile(dataFile)
			}

			setMultiMapValue(data, "Session Data", "Simulator", simulator)

			return data
		}
		catch Any as exception {
			if (protocol = "EXE") {
				logError(exception, true)

				logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider (")
														   , {simulator: simulator, protocol: protocol})
									   . exePath . translate(") - please rebuild the applications in the binaries folder (")
									   . kBinariesDirectory . translate(")"))

				if !kSilentMode
					showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
												  , {exePath: exePath, simulator: simulator, protocol: "SHM"})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

				return newMultiMap()
			}
			else {
				logError(exception)

				return callSimulator(simulator, options, "EXE")
			}
		}
}

readSimulator(simulator, car, track, format := "Object", options := "", protocol?) {
	local data := newMultiMap()
	local telemetryData, standingsData

	SimulatorProvider.createSimulatorProvider(simulator, car, track).acquireSessionData(&telemetryData, &standingsData)

	setMultiMapValue(data, "System", "Time", A_TickCount)

	addMultiMapValues(data, telemetryData)
	addMultiMapValues(data, standingsData)

	return ((format = "Text") ? printMultiMap(data) : data)
}