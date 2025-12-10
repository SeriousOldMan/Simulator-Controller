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
#Include "..\..\Plugins\Simulator Providers.ahk"


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
	static sSimulatorProviders := Map()

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

	static SimulatorProviders[code?] {
		Get {
			return (isSet(code) ? SimulatorProvider.sSimulatorProviders[code]
								: SimulatorProvider.sSimulatorProviders)
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

	static Protocols {
		Get {
			return {Connector: {Type: "DLL", Protocol: "SHM"
							  , File: kBinariesDirectory . "Connectors\%simulator% SHM Connector.dll"
							  , Library: "%simulator% SHM Connector"}
				  , Provider: {Type: "EXE", Protocol: "SHM"
							 , File: kBinariesDirectory . "Providers\%simulator% SHM Provider.exe"}
				  , Spotter: {Type: "EXE", Protocol: "SHM"
							 , File: kBinariesDirectory . "Providers\%simulator% SHM Spotter.exe"}
				  , Coach: {Type: "EXE", Protocol: "SHM"
						  , File: kBinariesDirectory . "Providers\%simulator% SHM Coach.exe"}}
		}
	}

	__New(car, track) {
		this.iCar := SessionDatabase.getCarCode(this.Simulator, car)
		this.iTrack := SessionDatabase.getTrackCode(this.Simulator, track)
	}

	static getProtocols(simulator) {
		local protocols

		updateSimulator(object) {
			local property, value

			for property, value in object.OwnProps()
				if isObject(value)
					updateSimulator(value)
				else if isInstance(value, String)
					object.%property% := substituteVariables(value, {simulator: simulator})
		}

		simulator := SessionDatabase.getSimulatorCode(simulator)

		try {
			protocols := %simulator . "Provider"%.Protocols

			updateSimulator(protocols)

			return protocols
		}
		catch Any as exception {
			logError(exception, true)

			throw "Unsupported simulator detected in SimulatorProvider.getProtocols..."
		}
	}

	static getProtocol(simulator, protocol) {
		local protocols := this.getProtocols(simulator)

		return (protocols.HasProp(protocol) ? protocols.%protocol% : false)
	}

	static createSimulatorProvider(simulator, car, track) {
		try {
			return %SessionDatabase.getSimulatorCode(simulator)%Provider(car, track)
		}
		catch Any {
			return SimulatorProvider.GenericSimulatorProvider(SessionDatabase.getSimulatorName(simulator), car, track)
		}
	}

	static registerSimulatorProvider(code, class) {
		SimulatorProvider.sSimulatorProviders[code] := class
	}

	supportsPitstop(&refuelService?, &tyreService?, &brakeService?, &repairService?) {
		refuelService := false
		tyreService := false
		brakeService := false
		repairService := []

		return false
	}

	supportsTyreManagement(&mixedCompounds?, &tyreSets?) {
		mixedCompounds := false
		tyreSets := false

		return false
	}

	supportsSetupImport() {
		return false
	}

	supportsTrackMap() {
		return false
	}

	prepareProvider() {
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

		if !car
			car := getMultiMapValue(data, "Session Data", "Car", false)

		if !track
			track := getMultiMapValue(data, "Session Data", "Track", false)

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

	static defaultProtocol := ((getMultiMapValue(readMultiMap(getFileName("Core Settings.ini"
																		, kUserConfigDirectory, kConfigDirectory))
											   , "Simulator", "Data Provider", "DLL") = "DLL") ? "Connector"
																							   : "Provider")
	static protocols := CaseInsenseMap()
	static connectors := CaseInsenseMap()

	simulator := SessionDatabase.getSimulatorCode(simulator)

	if !protocols.Has(simulator)
		try {
			protocols[simulator] := SimulatorProvider.getProtocols(simulator)
		}
		catch Any {
			throw "Unsupported simulator detected in callSimulator..."
		}

	if ((defaultProtocol = "Provider") && protocols[simulator].HasProp("Provider"))
		protocol := protocols[simulator].Provider
	else if isSet(protocol) {
		if protocols[simulator].HasProp(protocol)
			protocol := protocols[simulator].%protocol%
		else
			protocol := kUndefined
	}
	else if protocols[simulator].HasProp("Connector")
		protocol := protocols[simulator].Connector
	else if protocols[simulator].HasProp("Provider")
		protocol := protocols[simulator].Provider
	else
		protocol := kUndefined

	try {
		if (options = "Close") {
			if ((protocol.Type = "DLL") && connectors.Has(simulator . ".DLL")) {
				try {
					DLLCall(protocol.Library . "\close")

					connectors.Delete(simulator . ".DLL")
				}
			}
			else if ((protocol.Type = "CLR") && connectors.Has(simulator . ".CLR")) {
				try {
					connectors[simulator . ".CLR"].Close()

					connectors.Delete(simulator . ".DLL")
				}
			}
		}
		else {
			if (protocol.Type = "DLL") {
				if !connectors.Has(simulator . ".DLL") {
					curWorkingDir := A_WorkingDir

					SetWorkingDir(kBinariesDirectory . "Connectors\")

					try {
						connector := DllCall("LoadLibrary", "Str", protocol.File, "Ptr")

						DLLCall(protocol.Library . "\open")

						connectors[simulator . ".DLL"] := connector

						OnExit((*) {
							callSimulator(simulator, "Close", "Connector")
						})
					}
					finally {
						SetWorkingDir(curWorkingDir)
					}
				}

				buf := Buffer(1024 * 1024)

				DllCall(protocol.Library . "\call", "AStr", options, "Ptr", buf, "Int", buf.Size)

				data := parseMultiMap(StrGet(buf, "UTF-8"))

				if (data.Count = 0)
					throw ("DLL returned empty data for " . simulator . " in callSimulator...")
			}
			else if (protocol.Type = "CLR") {
				if connectors.Has(simulator . ".CLR")
					connector := connectors[simulator . ".CLR"]
				else {
					if !FileExist(protocol.File)
						throw "Unable to find `"" . protocol.File . "`" in callSimulator..."

					connector := CLR_LoadLibrary(protocol.File).CreateInstance(protocol.Instance)

					if (!connector.Open() && !isDebug())
						throw "Cannot startup `"" . protocol.File . "`" in callSimulator..."

					connectors[simulator . ".CLR"] := connector

					OnExit((*) {
						callSimulator(simulator, "Close", "Connector")
					})
				}

				data := parseMultiMap(connector.Call(options))

				if (data.Count = 0)
					throw ("DLL returned empty data for " . simulator . " in callSimulator...")
			}
			else if (protocol.Type = "EXE") {
				if !FileExist(protocol.File)
					throw "File `"" . protocol.File . "`" not found in callSimulator..."

				DirCreate(kTempDirectory . simulator . " Data")

				dataFile := temporaryFileName(simulator . " Data\SHM", "data")

				RunWait(A_ComSpec . " /c `"`"" . protocol.File . "`" `"" . options . "`" > `"" . dataFile . "`"`"", , "Hide")

				data := readMultiMap(dataFile)

				deleteFile(dataFile)
			}

			setMultiMapValue(data, "Session Data", "Simulator", simulator)

			return data
		}
	}
	catch Any as exception {
		if ((protocol = kUndefined) || (protocol.Type = "EXE")) {
			logError(exception, true)

			if (protocol = kUndefined) {
				protocol := "SHM"
				exePath := "..."
			}
			else {
				exePath := protocol.File
				protocol := protocol.Protocol
			}

			logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider (")
													   , {simulator: simulator, protocol: protocol})
								   . exePath . translate(") - please rebuild the applications in the binaries folder (")
								   . kBinariesDirectory . translate(")"))

			if !kSilentMode
				showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
											  , {exePath: exePath, simulator: simulator, protocol: protocol})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			return newMultiMap()
		}
		else {
			logError(exception)

			return callSimulator(simulator, options, "Provider")
		}
	}
}

readSimulator(simulator, car, track, format := "Object") {
	local provider := SimulatorProvider.createSimulatorProvider(simulator, car, track)
	local data := provider.readSessionData("Setup=true")
	local telemetryData, standingsData

	provider.acquireSessionData(&telemetryData, &standingsData)

	if ((car != getMultiMapValue(telemetryData, "Session Data", "Car", car))
	 || (track != getMultiMapValue(telemetryData, "Session Data", "Track", track))) {
		car := getMultiMapValue(telemetryData, "Session Data", "Car")
		track := getMultiMapValue(telemetryData, "Session Data", "Track")

		provider := SimulatorProvider.createSimulatorProvider(simulator, car, track)
		data := provider.readSessionData("Setup=true")

		provider.acquireSessionData(&telemetryData, &standingsData)
	}

	setMultiMapValue(data, "System", "Time", A_TickCount)

	addMultiMapValues(data, telemetryData)
	addMultiMapValues(data, standingsData)

	return ((format = "Text") ? printMultiMap(data) : data)
}