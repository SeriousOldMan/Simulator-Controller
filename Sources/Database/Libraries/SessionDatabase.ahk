﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Session Database                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"
#Include "..\..\Framework\Configuration.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\CLR.ahk"
#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\Database.ahk"
#Include "SettingsDatabase.ahk"
#Include "..\..\Garage\Libraries\CarInformation.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kWeatherConditions := ["Dry", "Drizzle", "LightRain", "MediumRain", "HeavyRain", "Thunderstorm"]

global kTyreCompounds := ["Wet (Black)", "Intermediate (Black)", "Dry (Black)"
						, "Wet (S)", "Wet (M)", "Wet (H)"
						, "Intermediate (S)", "Intermediate (M)", "Intermediate (H)"
						, "Dry (S+)", "Dry (S)", "Dry (M)", "Dry (H)", "Dry (H+)"
						, "Dry (Red)", "Dry (Yellow)", "Dry (White)", "Dry (Green)", "Dry (Blue)"]

global kDryQualificationSetup := "DQ"
global kDryRaceSetup := "DR"
global kWetQualificationSetup := "WQ"
global kWetRaceSetup := "WR"

global kSetupTypes := [kDryQualificationSetup, kDryRaceSetup, kWetQualificationSetup, kWetRaceSetup]

global kSessionSchemas := CaseInsenseMap("Drivers", ["ID", "Forname", "Surname", "Nickname", "Identifier", "Synchronized"])


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSimulatorCodes := Map("Assetto Corsa", "AC", "Assetto Corsa EVO", "ACE", "Assetto Corsa Competizione", "ACC"
							, "Automobilista 2", "AMS2"
							, "iRacing", "IRC", "RaceRoom Racing Experience", "R3E", "rFactor 2", "RF2", "Project CARS 2", "PCARS2"
							, "Rennsport", "RSP", "Le Mans Ultimate", "LMU")


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SessionDatabase extends ConfigurationItem {
	static sConfiguration := false
	static sControllerState := false

	static sCarData := CaseInsenseMap()
	static sTrackData := CaseInsenseMap()
	static sTyreData := CaseInsenseMap()

	static sID := false

	static sConnectors := CaseInsenseMap()
	static sServerURLs := CaseInsenseMap()
	static sServerTokens := CaseInsenseMap()

	static sConnected := CaseInsenseMap()

	static sSynchronizers := []

	iUseCommunity := false

	class TrackScanningImportTask extends ProgressTask {
		iOptionsCallback := false

		__New(title, optionsCallback) {
			this.iOptionsCallback := optionsCallback

			super.__New(title)
		}

		updateProgress() {
			if this.iOptionsCallback
				super.updateProgress(this.iOptionsCallback.Call())
			else
				super.updateProgress()
		}
	}

	static ID {
		Get {
			return SessionDatabase.sID
		}
	}

	ID {
		Get {
			return SessionDatabase.ID
		}
	}

	static DatabaseID {
		Get {
			try {
				return FileRead(kDatabaseDirectory . "ID")
			}
			catch Any as exception {
				return SessionDatabase.ID
			}
		}
	}

	DatabaseID {
		Get {
			return SessionDatabase.DatabaseID
		}
	}

	static DatabasePath {
		Get {
			return kDatabaseDirectory
		}

		Set {
			global kDatabaseDirectory

			local configuration := readMultiMap(kUserConfigDirectory . "Session Database.ini")

			value := (normalizeDirectoryPath(value) . "\")

			setMultiMapValue(configuration, "Database", "Path", value)
			setMultiMapValue(SessionDatabase.sConfiguration, "Database", "Path", value)

			writeMultiMap(kUserConfigDirectory . "Session Database.ini", configuration)

			return (kDatabaseDirectory := (normalizeDirectoryPath(value) . "\"))
		}
	}

	DatabasePath {
		Get {
			return kDatabaseDirectory
		}
	}

	static DatabaseVersion {
		Get {
			return getMultiMapValue(readMultiMap(kUserConfigDirectory . "Session Database.ini")
								  , "Database", "Version", false)
		}

		Set {
			local configuration := readMultiMap(kUserConfigDirectory . "Session Database.ini")

			setMultiMapValue(configuration, "Database", "Version", value)
			setMultiMapValue(SessionDatabase.sConfiguration, "Database", "Version", value)

			writeMultiMap(kUserConfigDirectory . "Session Database.ini", configuration)

			return value
		}
	}

	DatabaseVersion {
		Get {
			return SessionDatabase.DatabaseVersion
		}
	}

	static Connector[identifier] {
		Get {
			local connector := false
			local dllFile, connection

			static retry := 0

			if (SessionDatabase.ServerURL[identifier] && SessionDatabase.sConnectors.Has(identifier)
													  && !SessionDatabase.sConnectors[identifier] && (A_TickCount > retry))
				SessionDatabase.sConnectors.Delete(identifier)

			if (!SessionDatabase.sConnectors.Has(identifier)) {
				if SessionDatabase.ServerURL[identifier] {
					retry := (A_TickCount + 10000)

					dllFile := (kBinariesDirectory . "Connectors\Data Store Connector.dll")

					try {
						if (!FileExist(dllFile)) {
							logMessage(kLogCritical, translate("Data Store Connector.dll not found in ") . kBinariesDirectory)

							throw "Unable to find Data Store Connector.dll in " . kBinariesDirectory . "..."
						}

						connector := CLR_LoadLibrary(dllFile).CreateInstance("TeamServer.DataConnector")
					}
					catch Any as exception {
						logMessage(kLogCritical, translate("Error while initializing Data Store Connector - please rebuild the applications"))

						if !kSilentMode
							showMessage(translate("Error while initializing Data Store Connector - please rebuild the applications") . translate("...")
												, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
					}

					if connector {
						connector.Initialize(SessionDatabase.ServerURL[identifier], SessionDatabase.ServerToken[identifier])

						try {
							connection := connector.Connect(SessionDatabase.ServerToken[identifier], SessionDatabase.ID, SessionDatabase.getUserName())

							if (connection && (connection != "")) {
								try {
									connector.ValidateDataToken()
								}
								catch Any as exception {
									logError(exception)

									connector := false

									throw exception
								}

								if connector
									PeriodicTask(keepAlive.Bind(identifier, connector, connection), 10000, kInterruptPriority).start()
							}
							else
								connector := false
						}
						catch Any as exception {
							logMessage(kLogCritical, translate("Cannot connect to the Team Server (URL: ") . SessionDatabase.ServerURL[identifier]
												   . translate(", Token: ") . SessionDatabase.ServerToken[identifier]
												   . translate("), Exception: ") . (isObject(exception) ? exception.Message : exception))

							connector := false
						}
					}

					SessionDatabase.sConnectors[identifier] := connector
				}
				else
					SessionDatabase.sConnectors[identifier] := false

				SessionDatabase.Connected[identifier] := (SessionDatabase.sConnectors[identifier] != false)
			}

			return SessionDatabase.sConnectors[identifier]
		}
	}

	Connector[identifier] {
		Get {
			return SessionDatabase.Connector[identifier]
		}
	}

	static Connectors {
		Get {
			local result := CaseInsenseMap()
			local connector, identifier, serverURL

			for identifier, serverURL in stringToMap("|", "->", getMultiMapValue(SessionDatabase.sConfiguration, "Team Server", "Server.URL", ""), "Standard") {
				connector := SessionDatabase.Connector[identifier]

				if connector
					result[identifier] := connector
			}

			return result
		}
	}

	Connectors {
		Get {
			return SessionDatabase.Connectors
		}
	}

	static Connected[identifier] {
		Get {
			return (SessionDatabase.sConnected.Has(identifier) ? SessionDatabase.sConnected[identifier] : false)
		}

		Set {
			return (SessionDatabase.sConnected[identifier] := value)
		}
	}

	Connected[identifier] {
		Get {
			return SessionDatabase.Connected[identifier]
		}
	}

	static ServerURLs[identifier?] {
		Get {
			if (SessionDatabase.sServerURLs.Count = 0) ; isSet(identifier) && !SessionDatabase.sServerURLs.Has(identifier))
				SessionDatabase.sServerURLs := stringToMap("|", "->", getMultiMapValue(SessionDatabase.sConfiguration, "Team Server", "Server.URL", ""), "Standard")

			return (isSet(identifier) ? SessionDatabase.sServerURLs[identifier] : SessionDatabase.sServerURLs)
		}
	}

	ServerURLs[identifier?] {
		Get {
			return SessionDatabase.ServerURLs[identifier?]
		}
	}

	static ServerURL[identifier?] {
		Get {
			return SessionDatabase.ServerURLs[identifier?]
		}
	}

	ServerURL[identifier?] {
		Get {
			return SessionDatabase.ServerURL[identifier?]
		}
	}

	static ServerTokens[identifier := false] {
		Get {
			if !SessionDatabase.sServerTokens.Has(identifier)
				SessionDatabase.sServerTokens := stringToMap("|", "->", getMultiMapValue(SessionDatabase.sConfiguration, "Team Server", "Server.Token", ""), "Standard")

			return (identifier ? SessionDatabase.sServerTokens[identifier] : SessionDatabase.sServerTokens)
		}
	}

	ServerTokens[identifier := false] {
		Get {
			return SessionDatabase.ServerTokens[identifier]
		}
	}

	static ServerToken[identifier] {
		Get {
			return SessionDatabase.ServerTokens[identifier]
		}
	}

	ServerToken[identifier] {
		Get {
			return SessionDatabase.ServerTokens[identifier]
		}
	}

	static Synchronizers {
		Get {
			return SessionDatabase.sSynchronizers
		}
	}

	Synchronizers {
		Get {
			return SessionDatabase.sSynchronizers
		}
	}

	static Synchronization[identifier] {
		Get {
			local configuration := readMultiMap(kUserConfigDirectory . "Session Database.ini")
			local synchronization := stringToMap("|", "->", getMultiMapValue(configuration, "Team Server", "Synchronization", ""), "Standard")

			return (synchronization.Has(identifier) ? synchronization[identifier] : 0)
		}

		Set {
			local configuration := readMultiMap(kUserConfigDirectory . "Session Database.ini")
			local synchronization := stringToMap("|", "->", getMultiMapValue(configuration, "Team Server", "Synchronization", ""), "Standard")

			synchronization[identifier] := value

			synchronization := mapToString("|", "->", synchronization)

			setMultiMapValue(configuration, "Team Server", "Synchronization", synchronization)

			writeMultiMap(kUserConfigDirectory . "Session Database.ini", configuration)

			setMultiMapValue(SessionDatabase.sConfiguration, "Team Server", "Synchronization", synchronization)

			return value
		}
	}

	Synchronization[identifier] {
		Get {
			return SessionDatabase.Synchronization[identifier]
		}

		Set {
			return (SessionDatabase.Synchronization[identifier] := value)
		}
	}

	static Groups[identifier] {
		Get {
			local groups := getMultiMapValue(SessionDatabase.sConfiguration, "Team Server", "Groups", "Telemetry, Pressures")

			if InStr(groups, "->") {
				groups := stringToMap("|", "->", groups)

				return (groups.Has(identifier) ? string2Values(",", groups[identifier]) : [])
			}
			else
				return string2Values(",", groups)
		}
	}

	Groups[identifier] {
		Get {
			return SessionDatabase.Groups[identifier]
		}
	}

	static ControllerState {
		Get {
			if !SessionDatabase.sControllerState
				SessionDatabase.sControllerState := getControllerState()

			return SessionDatabase.sControllerState
		}
	}

	ControllerState {
		Get {
			return SessionDatabase.ControllerState
		}
	}

	UseCommunity[persistent := true] {
		Get {
			return this.iUseCommunity
		}

		Set {
			local configuration

			if persistent {
				configuration := readMultiMap(kUserConfigDirectory . "Session Database.ini")

				setMultiMapValue(configuration, "Scope", "Community", value)
				setMultiMapValue(SessionDatabase.sConfiguration, "Scope", "Community", value)

				writeMultiMap(kUserConfigDirectory . "Session Database.ini", configuration)
			}

			return (this.iUseCommunity := value)
		}
	}

	__New() {
		if !SessionDatabase.sConfiguration {
			SessionDatabase.sConfiguration := readMultiMap(kUserConfigDirectory . "Session Database.ini")

			SessionDatabase.sID := FileRead(kUserConfigDirectory . "ID")
		}

		super.__New(SessionDatabase.sConfiguration)
	}

	loadFromConfiguration(configuration) {
		this.iUseCommunity := getMultiMapValue(configuration, "Scope", "Community", false)
	}

	static reloadConfiguration() {
		SessionDatabase.sConnectors := CaseInsenseMap()
		SessionDatabase.sServerURLs := CaseInsenseMap()
		SessionDatabase.sServerTokens := CaseInsenseMap()

		SessionDatabase.sConfiguration := readMultiMap(kUserConfigDirectory . "Session Database.ini")
	}

	reloadConfiguration() {
		SessionDatabase.reloadConfiguration()
	}

	static prepareDatabase(simulator, car, track, data := false) {
		local simulatorCode, prefix, carName

		if (simulator && car && track) {
			simulatorCode := SessionDatabase.getSimulatorCode(simulator)
			car := SessionDatabase.getCarCode(simulator, car)
			track := SessionDatabase.getTrackCode(simulator, track)

			if (simulatorCode && car && track && (car != true) && (track != true)) {
				prefix := (kDatabaseDirectory . "User\" . simulatorCode . "\")

				if (((simulatorCode = "RF2") || (simulatorCode = "LMU")) && data) {
					carName := getMultiMapValue(data, "Session Data", "CarName")

					if (car != carName) {
						if FileExist(prefix . carName . "\" . track) {
							try {
								if FileExist(prefix . car . "\" . track)
									DirMove(prefix . carName, prefix . car, 2)
								else
									DirMove(prefix . carName, prefix . car, "R")
							}
							catch Any as exception {
								logError(exception)
							}

							return
						}

						if (InStr(carName, "#") > 1) {
							carName := string2Values("#", carName)[1]

							if ((car != carName) && FileExist(prefix . carName . "\" . track)) {
								try {
									if FileExist(prefix . car . "\" . track)
										DirMove(prefix . carName, prefix . car, 2)
									else
										DirMove(prefix . carName, prefix . car, "R")
								}
								catch Any as exception {
									logError(exception)
								}

								return
							}
						}
					}
				}

				DirCreate(prefix . car . "\" . track)
			}
		}
	}

	prepareDatabase(simulator, car, track, data := false) {
		SessionDatabase.prepareDatabase(simulator, car, track, data)
	}

	static registerSynchronizer(synchronizer) {
		SessionDatabase.Synchronizers.Push(synchronizer)
	}

	static getAllDrivers(simulator, names := false) {
		local sessionDB, ids, index, row, ignore, id, result, candidate

		if simulator {
			sessionDB := Database(kDatabaseDirectory . "User\" . SessionDatabase.getSimulatorCode(simulator) . "\", kSessionSchemas)

			ids := sessionDB.query("Drivers", {Select: ["ID"], By: "ID"})

			for index, row in ids
				ids[index] := row["ID"]

			if names {
				names := []

				for ignore, id in ids
					names.Push(SessionDatabase.getDriverNames(simulator, id, sessionDB))

				return names
			}
			else
				return ids
		}
		else {
			result := []

			for ignore, simulator in SessionDatabase.getSimulators()
				for ignore, candidate in SessionDatabase.getAllDrivers(simulator, names)
					if !inList(result, candidate)
						result.Push(candidate)

			return result
		}
	}

	getAllDrivers(simulator, names := false) {
		return SessionDatabase.getAllDrivers(simulator, names)
	}

	static registerDriver(simulator, id, name) {
		local sessionDB, forName, surName, nickName, key

		static knownDrivers := CaseInsenseMap()

		if (simulator && id && name && (InStr(name, "John Doe") != 1)) {
			name := StrReplace(StrReplace(StrReplace(name, ";", ","), "`n", A_Space), "|", "-")

			key := (simulator . id . name)

			if !knownDrivers.Has(key) {
				sessionDB := Database(kDatabaseDirectory . "User\" . this.getSimulatorCode(simulator) . "\", kSessionSchemas)

				forName := false
				surName := false
				nickName := false

				parseDriverName(name, &forName, &surName, &nickName)

				try {
					if (sessionDB.query("Drivers", {Where: {ID: id, Forname: forName, Surname: surName}}).Length = 0)
						sessionDB.add("Drivers", Database.Row("ID", id, "Forname", forName, "Surname", surName, "Nickname", nickName), true)

					knownDrivers[key] := true
				}
				catch Any as exception {
					logError(exception, true)
				}
			}
		}
	}

	registerDriver(simulator, id, name) {
		SessionDatabase.registerDriver(simulator, id, name)
	}

	static getUserName() {
		static userName := SessionDatabase.getDriverNames(false, this.ID)[1]

		return userName
	}

	getUserName() {
		return SessionDatabase.getUserName()
	}

	static getDriverIDs(simulator, name, sessionDB := false) {
		local forName, surName, nickName, ids, ignore, entry

		try {
			if (simulator && name) {
				forName := false
				surName := false
				nickName := false

				parseDriverName(name, &forName, &surName, &nickName)

				if !sessionDB
					sessionDB := Database(kDatabaseDirectory . "User\" . this.getSimulatorCode(simulator) . "\", kSessionSchemas)

				ids := []

				for ignore, entry in sessionDB.query("Drivers", {Where: {Forname: forName, Surname: surName}})
					ids.Push(entry["ID"])

				return ids
			}
		}
		catch Any as exception {
			logError(exception, true)
		}

		return false
	}

	getDriverIDs(simulator, name, sessionDB := false) {
		return SessionDatabase.getDriverIDs(simulator, name, sessionDB)
	}

	static getDriverNames(simulator, id, sessionDB := false) {
		local drivers, ignore, driver

		try {
			if (simulator && id) {
				if !sessionDB
					sessionDB := Database(kDatabaseDirectory . "User\" . this.getSimulatorCode(simulator) . "\", kSessionSchemas)

				drivers := []

				for ignore, driver in sessionDB.query("Drivers", {Where: {ID: id}})
					drivers.Push(driverName(driver["Forname"], driver["Surname"], driver["Nickname"]))

				return ((drivers.Length = 0) ? ["John Doe (JD)"] : drivers)
			}
			else if id {
				for ignore, simulator in SessionDatabase.getSimulators() {
					sessionDB := Database(kDatabaseDirectory . "User\" . SessionDatabase.getSimulatorCode(simulator) . "\", kSessionSchemas)

					for ignore, driver in sessionDB.query("Drivers", {Where: {ID: id}})
						return Array(driverName(driver["Forname"], driver["Surname"], driver["Nickname"]))
				}
			}
		}
		catch Any as exception {
			logError(exception, true)
		}

		return ["John Doe (JD)"]
	}

	getDriverNames(simulator, id, sessionDB := false) {
		return SessionDatabase.getDriverNames(simulator, id, sessionDB)
	}

	static getDriverID(simulator, name) {
		local ids := SessionDatabase.getDriverIDs(simulator, name)

		return ((ids.Length > 0) ? ids[1] : false)
	}

	getDriverID(simulator, name) {
		return SessionDatabase.getDriverID(simulator, name)
	}

	static getDriverName(simulator, id) {
		return SessionDatabase.getDriverNames(simulator, id)[1]
	}

	getDriverName(simulator, id) {
		return SessionDatabase.getDriverName(simulator, id)
	}

	static mapTrack(simulator, track, dataFile, callback := false) {
		local pid

		simulator := SessionDatabase.getSimulatorName(simulator)

		finalizeTrackMap() {
			if ProcessExist(pid)
				Task.startTask(Task.CurrentTask, 10000)
			else {
				deleteFile(kTempDirectory . "Track Mapper.state")

				if callback
					callback.Call()
			}
		}

		try {
			if !FileExist(kBinariesDirectory . "Track Mapper.exe")
				throw "File not found..."

			Run(kBinariesDirectory . "Track Mapper.exe -Simulator `"" . simulator . "`" -Track `"" . track . "`" -Data `"" . datafile . "`""
			  , kBinariesDirectory, "Hide", &pid)
		}
		catch Any as exception {
			logError(exception, true)

			logMessage(kLogCritical, translate("Cannot start Track Mapper - please rebuild the applications..."))

			if !kSilentMode
				showMessage(translate("Cannot start Track Mapper - please rebuild the applications...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			deleteFile(kTempDirectory . "Track Mapper.state")

			pid := false
		}

		if pid
			Task.startTask(finalizeTrackMap, 120000, kLowPriority)

		return pid
	}

	mapTrack(simulator, track, dataFile, callback := false) {
		return SessionDatabase.mapTrack(simulator, track, dataFile, callback)
	}

	hasTrackMap(simulator, track) {
		local prefix := (kDatabaseDirectory . "User\Tracks\" . this.getSimulatorCode(simulator) . "\" . this.getTrackCode(simulator, track))

		return (FileExist(prefix . ".map") && this.getTrackImage(simulator, track))
	}

	availableTrackMaps(simulator) {
		local sessionDB := SessionDatabase()
		local code := sessionDB.getSimulatorCode(simulator)
		local tracks := []
		local track

		loop Files, kDatabaseDirectory . "User\Tracks\" . code . "\*.map", "F" {
			SplitPath(A_LoopFileName, , , , &track)

			tracks.Push(track)
		}

		return tracks
	}

	availableTrackImages(simulator) {
		local sessionDB := SessionDatabase()
		local code := sessionDB.getSimulatorCode(simulator)
		local directory := (kDatabaseDirectory . "User\Tracks\" . code . "\")
		local tracks := []
		local track

		loop Files, directory . "*.map", "F" {
			SplitPath(A_LoopFileName, , , , &track)

			if (FileExist(directory . track . ".png") || FileExist(directory . track . ".jpg")
													  || FileExist(directory . track . ".gif"))
				tracks.Push(track)
		}

		return tracks
	}

	updateTrackMap(simulator, track, map, imageFileName := false, dataFileName := false) {
		local prefix := (kDatabaseDirectory . "User\Tracks\" . this.getSimulatorCode(simulator) . "\" . this.getTrackCode(simulator, track))
		local extension

		writeMultiMap(prefix . ".map", map)

		if imageFileName {
			SplitPath(imageFileName, , , &extension)

			FileCopy(imageFileName, prefix . "." . extension, 1)
		}

		if dataFileName
			FileCopy(dataFileName, prefix . ".data", 1)
	}

	getTrackMap(simulator, track) {
		local fileName := (kDatabaseDirectory . "User\Tracks\" . this.getSimulatorCode(simulator) . "\" . this.getTrackCode(simulator, track) . ".map")

		if FileExist(fileName)
			return readMultiMap(fileName)
		else
			return false
	}

	getTrackImage(simulator, track) {
		local prefix := (kDatabaseDirectory . "User\Tracks\" . this.getSimulatorCode(simulator) . "\" . this.getTrackCode(simulator, track))

		if FileExist(prefix . ".map") {
			if FileExist(prefix . ".png")
				return (prefix . ".png")
			else if FileExist(prefix . ".jpg")
				return (prefix . ".jpg")
			else if FileExist(prefix . ".gif")
				return (prefix . ".gif")
			else
				return false
		}
		else
			return false
	}

	getTrackData(simulator, track) {
		local fileName := (kDatabaseDirectory . "User\Tracks\" . this.getSimulatorCode(simulator) . "\" . this.getTrackCode(simulator, track) . ".data")

		if FileExist(fileName)
			return fileName
		else
			return false
	}

	hasTrackAutomation(simulator, car, track, name := false) {
		local ignore, trackAutomation

		if this.hasTrackMap(simulator, track)
			if !name
				return this.hasTrackAutomations(simulator, car, track)
			else
				for ignore, trackAutomation in this.getTrackAutomations(simulator, car, track)
					if (trackAutomation.Name = name)
						return true

		return false
	}

	hasTrackAutomations(simulator, car, track) {
		local code := this.getSimulatorCode(simulator)

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		return (this.hasTrackMap(simulator, track)
			 && FileExist(kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Track.automations"))
	}

	getTrackAutomations(simulator, car, track) {
		local code := this.getSimulatorCode(simulator)

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		if this.hasTrackMap(simulator, track)
			return this.loadTrackAutomations(kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Track.automations")
		else
			return []
	}

	getTrackAutomation(simulator, car, track, name := false) {
		local ignore, trackAutomation

		for ignore, trackAutomation in this.getTrackAutomations(simulator, car, track)
			if ((name && (trackAutomation.Name = name)) || trackAutomation.Active)
				return trackAutomation

		return false
	}

	setTrackAutomations(simulator, car, track, trackAutomations) {
		local code := this.getSimulatorCode(simulator)

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		this.saveTrackAutomations(trackAutomations, kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Track.automations")
	}

	loadTrackAutomations(data) {
		local result := []
		local id, actions

		if !isObject(data)
			data := readMultiMap(data)

		loop getMultiMapValue(data, "Automations", "Count", 0) {
			id := A_Index

			actions := []

			loop getMultiMapValue(data, "Automations", id . ".Actions", 0)
				actions.Push({X: getMultiMapValue(data, "Actions", id . "." . A_Index . ".X", 0)
						    , Y: getMultiMapValue(data, "Actions", id . "." . A_Index . ".Y", 0)
							, Type: getMultiMapValue(data, "Actions", id . "." . A_Index . ".Type", 0)
							, Action: getMultiMapValue(data, "Actions", id . "." . A_Index . ".Action", 0)})

			result.Push({Name: getMultiMapValue(data, "Automations", id . ".Name", "")
					   , Active: getMultiMapValue(data, "Automations", id . ".Active", false)
					   , Actions: actions})
		}

		return result
	}

	saveTrackAutomations(trackAutomations, fileName := false) {
		local data := newMultiMap()
		local id, trackAutomation, ignore, trackAction

		for id, trackAutomation in trackAutomations {
			setMultiMapValue(data, "Automations", id . ".Name", trackAutomation.Name)
			setMultiMapValue(data, "Automations", id . ".Active", trackAutomation.Active)
			setMultiMapValue(data, "Automations", id . ".Actions", trackAutomation.Actions.Length)

			for ignore, trackAction in trackAutomation.Actions {
				setMultiMapValue(data, "Actions", id . "." . A_Index . ".X", trackAction.X)
				setMultiMapValue(data, "Actions", id . "." . A_Index . ".Y", trackAction.Y)
				setMultiMapValue(data, "Actions", id . "." . A_Index . ".Type", trackAction.Type)
				setMultiMapValue(data, "Actions", id . "." . A_Index . ".Action", trackAction.Action)
			}
		}

		setMultiMapValue(data, "Automations", "Count", trackAutomations.Length)

		if fileName
			writeMultiMap(fileName, data)

		return data
	}

	getEntries(filter := "*.*", option := "D") {
		local result := []

		loop Files, kDatabaseDirectory . "User\" . filter, option
			if ((A_LoopFileName != "1") && (InStr(A_LoopFileName, ".") != 1))
				result.Push(A_LoopFileName)

		if this.UseCommunity
			loop Files, kDatabaseDirectory . "Community\" . filter, option
				if ((A_LoopFileName != "1") && (InStr(A_LoopFileName, ".") != 1) && !inList(result, A_LoopFileName))
					result.Push(A_LoopFileName)

		return result
	}

	static getSimulatorName(simulatorCode) {
		local name, description, code

		if (simulatorCode = "Unknown")
			return "Unknown"
		else {
			if (this.ControllerState.Count > 0)
				for name, description in getMultiMapValues(this.ControllerState, "Simulators")
					if ((simulatorCode = name) || (simulatorCode = string2Values("|", description)[1]))
						return name

			for name, code in kSimulatorCodes
				if ((simulatorCode = name) || (simulatorCode = code))
					return name

			return false
		}
	}

	getSimulatorName(simulatorCode) {
		return SessionDatabase.getSimulatorName(simulatorCode)
	}

	static getSimulatorCode(simulatorName) {
		local code, ignore, description, name

		if (simulatorName = "Unknown")
			return "Unknown"
		else {
			for name, code in kSimulatorCodes
				if ((simulatorName = name) || (simulatorName = code))
					return code

			code := getMultiMapValue(this.ControllerState, "Simulators", simulatorName, false)

			if code
				return string2Values("|", code)[1]
			else {
				for ignore, description in getMultiMapValues(this.ControllerState, "Simulators")
					if (simulatorName = string2Values("|", description)[1])
						return simulatorName

				return false
			}
		}
	}

	getSimulatorCode(simulatorName) {
		return SessionDatabase.getSimulatorCode(simulatorName)
	}

	static getSimulators(force := false) {
		local configuredSimulators := string2Values("|", getMultiMapValue(kSimulatorConfiguration, "Configuration", "Simulators", ""))
		local controllerSimulators := getKeys(getMultiMapValues(this.ControllerState, "Simulators"))
		local simulators := []
		local simulator, ignore, name, code

		for ignore, simulator in configuredSimulators
			if inList(controllerSimulators, simulator)
				simulators.Push(simulator)

		for ignore, simulator in controllerSimulators
			if !inList(simulators, simulator)
				simulators.Push(simulator)

		if (force || (simulators.Length = 0))
			for name, code in kSimulatorCodes
				if (force || FileExist(kDatabaseDirectory . "User\" . code))
					simulators.Push(name)

		return simulators
	}

	getSimulators(force := false) {
		return SessionDatabase.getSimulators(force)
	}

	getCars(simulator) {
		local code := this.getSimulatorCode(simulator)

		if code
			return this.getEntries(code . "\*.*")
		else
			return []
	}

	getTracks(simulator, car) {
		local code := this.getSimulatorCode(simulator)
		local tracks

		if code {
			tracks := this.getEntries(code . "\" . car . "\*.*")

			return ((tracks.Length > 0) ? tracks : this.getEntries(code . "\" . this.getCarCode(simulator, car) . "\*.*"))
		}
		else
			return []
	}

	static loadData(cache, simulator, fileName) {
		local name, data, section, values, key, value

		if cache.Has(simulator)
			return cache[simulator]
		else {
			name := (kResourcesDirectory . "Simulator Data\" . simulator . "\" . fileName)

			if FileExist(name)
				data := readMultiMap(name)
			else
				data := newMultiMap()

			name := (kUserHomeDirectory . "Simulator Data\" . simulator . "\" . fileName)

			if FileExist(name)
				for section, values in readMultiMap(name)
					for key, value in values
						setMultiMapValue(data, section, key, value)

			cache[simulator] := data

			return data
		}
	}

	static clearData(cache, simulator) {
		cache.Delete(simulator)
	}

	static registerCar(simulator, car, name) {
		local simulatorCode := SessionDatabase.getSimulatorCode(simulator)
		local carCode := SessionDatabase.getCarCode(simulator, car)
		local carData, fileName

		if (simulator && simulatorCode && car && carCode) {
			DirCreate(kDatabaseDirectory . "User\" . simulatorCode . "\" . carCode)

			carData := SessionDatabase.loadData(SessionDatabase.sCarData, simulatorCode, "Car Data.ini")

			if ((simulatorCode != "ACC") && (getMultiMapValue(carData, "Car Names", car, kUndefined) == kUndefined)) {
				fileName := (kUserHomeDirectory . "Simulator Data\" . simulatorCode . "\" . "Car Data.ini")
				carData := readMultiMap(fileName)

				setMultiMapValue(carData, "Car Names", car, name)
				setMultiMapValue(carData, "Car Codes", name, car)

				writeMultiMap(fileName, carData)

				SessionDatabase.clearData(SessionDatabase.sCarData, SessionDatabase.getSimulatorCode(simulator))
			}
		}
	}

	registerCar(simulator, car, name) {
		SessionDatabase.registerCar(simulator, car, name)
	}

	static getCarName(simulator, car) {
		local name := getMultiMapValue(SessionDatabase.loadData(SessionDatabase.sCarData, this.getSimulatorCode(simulator), "Car Data.ini")
									 , "Car Names", car, kUndefined)

		if (name == kUndefined)
			name := normalizeFileName(car)
		else if (!name || (name = ""))
			name := car

		return name
	}

	getCarName(simulator, car) {
		return SessionDatabase.getCarName(simulator, car)
	}

	static getCarCode(simulator, car) {
		local code := getMultiMapValue(SessionDatabase.loadData(SessionDatabase.sCarData, this.getSimulatorCode(simulator), "Car Data.ini")
									 , "Car Codes", car, kUndefined)

		if (code == kUndefined)
			code := normalizeFileName(car)
		else if (!code || (code = ""))
			code := normalizeFileName(car)

		return code
	}

	getCarCode(simulator, car) {
		return SessionDatabase.getCarCode(simulator, car)
	}

	getCarSteerLock(simulator, car, track) {
		local key := (this.getSimulatorCode(simulator) . "." this.getCarCode(simulator, car))
		local steerLock

		static settingsDB := false
		static steerLocks := CaseInsenseMap()

		if steerLocks.Has(key)
			return steerLocks[key]

		if !settingsDB
			settingsDB := SettingsDatabase()

		steerLock := settingsDB.readSettingValue(simulator, car, track, "*", "Session Settings", "Car.SteerLock", kUndefined)

		if (steerLock == kUndefined)
			steerLock := getCarSteerLock(simulator, car)

		steerLocks[key] := steerLock

		return steerLock
	}

	static registerTrack(simulator, car, track, shortName, longName) {
		local simulatorCode := SessionDatabase.getSimulatorCode(simulator)
		local carCode := SessionDatabase.getCarCode(simulator, car)
		local trackCode := SessionDatabase.getTrackCode(simulator, track)
		local trackData, fileName

		if (simulator && simulatorCode && car && carCode && track && trackCode) {
			DirCreate(kDatabaseDirectory . "User\" . simulatorCode . "\" . carCode . "\" . trackCode)

			trackData := SessionDatabase.loadData(SessionDatabase.sTrackData, simulatorCode, "Track Data.ini")

			if ((simulatorCode != "ACC") && (getMultiMapValue(trackData, "Track Names Long", track, kUndefined) == kUndefined)) {
				fileName := (kUserHomeDirectory . "Simulator Data\" . simulatorCode . "\" . "Track Data.ini")
				trackData := readMultiMap(fileName)

				setMultiMapValue(trackData, "Track Names Long", track, longName)
				setMultiMapValue(trackData, "Track Names Short", track, shortName)
				setMultiMapValue(trackData, "Track Codes", longName, track)
				setMultiMapValue(trackData, "Track Codes", shortName, track)

				writeMultiMap(fileName, trackData)

				SessionDatabase.clearData(SessionDatabase.sTrackData, SessionDatabase.getSimulatorCode(simulator))
			}
		}
	}

	registerTrack(simulator, car, track, shortName, longName) {
		SessionDatabase.registerTrack(simulator, car, track, shortName, longName)
	}

	static getTrackName(simulator, track, long := true) {
		local name := getMultiMapValue(SessionDatabase.loadData(SessionDatabase.sTrackData, this.getSimulatorCode(simulator), "Track Data.ini")
									 , long ? "Track Names Long" : "Track Names Short", track, kUndefined)

		if ((name != kUndefined) && (StrLen(name) < 5))
			name := getMultiMapValue(SessionDatabase.loadData(SessionDatabase.sTrackData, this.getSimulatorCode(simulator), "Track Data.ini")
									 , "Track Names Long", track, name)

		if (name == kUndefined)
			name := normalizeFileName(track)
		else if (!name || (name = ""))
			name := track

		return StrTitle(name)
	}

	getTrackName(simulator, track, long := true) {
		return SessionDatabase.getTrackName(simulator, track, long)
	}

	static getTrackCode(simulator, track) {
		local code := getMultiMapValue(SessionDatabase.loadData(SessionDatabase.sTrackData, this.getSimulatorCode(simulator), "Track Data.ini")
									 , "Track Codes", track, kUndefined)

		if (code == kUndefined)
			code := normalizeFileName(track)
		else if (!code || (code = ""))
			code := normalizeFileName(track)

		return code
	}

	getTrackCode(simulator, track) {
		return SessionDatabase.getTrackCode(simulator, track)
	}

	static getTyreCompounds(simulator, car, track, codes := false) {
		local code, cache, key, compounds, data, cds, nms, ignore, compound, candidate

		static settingsDB := false
		static sNames := CaseInsenseMap()
		static sCodes := CaseInsenseMap()

		car := SessionDatabase.getCarCode(simulator, car)

		code := SessionDatabase.getSimulatorCode(simulator)
		cache := (codes ? sCodes : sNames)
		key := (code . "." . car . "." . track)

		if cache.Has(key)
			return cache[key]
		else {
			if !settingsDB
				settingsDB := SettingsDatabase()

			cds := []
			nms := []

			try {
				compounds := settingsDB.readSettingValue(simulator, car, track, "*"
													   , "Session Settings", "Tyre.Compound.Choices"
													   , kUndefined)
				data := SessionDatabase.loadData(SessionDatabase.sTyreData, code, "Tyre Data.ini")

				if ((compounds == kUndefined) || (compounds = "")) {
					compounds := getMultiMapValue(data, "Cars", car . ";" . track, kUndefined)

					if (compounds == kUndefined)
						compounds := getMultiMapValue(data, "Cars", car . ";*", kUndefined)

					if (compounds == kUndefined)
						compounds := getMultiMapValue(data, "Cars", "*;" . track, kUndefined)

					if (compounds == kUndefined)
						compounds := getMultiMapValue(data, "Cars", "*;*", kUndefined)
				}

				if (compounds == kUndefined) {
					if (code = "ACC")
						compounds := "Dry->Dry;Wet->Wet"
					else
						compounds := "*->Dry"
				}
				else {
					candidate := getMultiMapValue(data, "Compounds", compounds, false)

					if candidate
						compounds := candidate
				}

				if InStr(compounds, ";")
					compounds := string2Values(";", compounds)
				else
					compounds := string2Values(",", compounds)

				for ignore, compound in compounds {
					compound := string2Values("->", compound)

					if (compound.Length = 2) {
						cds.Push(compound[1])
						nms.Push(normalizeCompound(compound[2]))
					}
				}
			}
			catch Any as exception {
				logError(exception, true)
			}

			if (cds.Length = 0) {
				cds.Push((code = "ACC") ? "Dry" : "*")
				nms.Push("Dry (Black)")
			}

			if codes
				compounds := cds
			else
				compounds := nms

			cache[key] := compounds

			return compounds
		}
	}

	getTyreCompounds(simulator, car, track, codes := false) {
		return SessionDatabase.getTyreCompounds(simulator, car, track, codes)
	}

	static getTyreCompoundName(simulator, car, track, compound, default?) {
		local compounds := SessionDatabase.getTyreCompounds(simulator, car, track, true)
		local index, code

		for index, code in compounds
			if (code = compound)
				return SessionDatabase.getTyreCompounds(simulator, car, track)[index]

		if (isInteger(compound) && compounds.Has(compound))
			return SessionDatabase.getTyreCompounds(simulator, car, track)[compound]
		else
			return (isSet(default) ? default : compound)
	}

	getTyreCompoundName(simulator, car, track, compound, default := kUndefined) {
		return SessionDatabase.getTyreCompoundName(simulator, car, track, compound, default)
	}

	static getTyreCompoundCode(simulator, car, track, compound, default := "Dry") {
		local index, name, code

		if compound
			compound := normalizeCompound(compound)

		for index, name in SessionDatabase.getTyreCompounds(simulator, car, track)
			if (name = compound) {
				code := SessionDatabase.getTyreCompounds(simulator, car, track, true)[index]

				return ((code != "*") ? code : false)
			}

		return default
	}

	getTyreCompoundCode(simulator, car, track, compound, default := "Dry") {
		return SessionDatabase.getTyreCompoundCode(simulator, car, track, compound, default)
	}

	suitableTyreCompound(simulator, car, track, weather, tyreCompound) {
		tyreCompound := compound(tyreCompound)

		if (weather = "Dry") {
			if (tyreCompound = "Dry")
				return true
		}
		else if (weather = "Drizzle") {
			if inList(["Dry", "Intermediate"], tyreCompound)
				return true
		}
		else if (weather = "LightRain") {
			if inList(["Intermediate", "Wet"], tyreCompound)
				return true
		}
		else if (tyreCompound = "Wet")
			return true

		return false
	}

	optimalTyreCompound(simulator, car, track, weather, airTemeperature, trackTemperature, availableTyreCompounds := false) {
		local compounds, tyreCompound, index

		if !availableTyreCompounds
			availableTyreCompounds := this.getTyreCompounds(simulator, car, track)

		compounds := collect(collect(availableTyreCompounds, compound), normalizeCompound)

		switch weather, false {
			case "Dry":
				tyreCompound := "Dry"
			case "Drizzle", "LightRain":
				tyreCompound := "Intermediate"
			default:
				tyreCompound := "Wet"
		}

		index := inList(compounds, normalizeCompound(tyreCompound))

		if index
			return availableTyreCompounds[index]
		else if ((tyreCompound = "Intermediate") && (weather = "Drizzle")) {
			index := inList(compounds, normalizeCompound("Dry"))

			if index
				return availableTyreCompounds[index]
		}
		else if ((tyreCompound = "Intermediate") && (weather = "LightRain")) {
			index := inList(compounds, normalizeCompound("Wet"))

			if index
				return availableTyreCompounds[index]
		}
		else {
			index := inList(compounds, normalizeCompound("Dry"))

			if index
				return availableTyreCompounds[index]
		}

		return false
	}

	optimalTyrePressure(simulator, car, tyreCompound, default := false) {
		car := this.getCarCode(simulator, car)
		tyreCompound := compound(tyreCompound)

		return getMultiMapValue(SessionDatabase.loadData(SessionDatabase.sTyreData, this.getSimulatorCode(simulator), "Tyre Data.ini")
							  , "Pressures", car . ";" . tyreCompound, default)
	}

	readNotes(simulator, car, track) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local fileName

		if (car && (car != true))
			car := this.getCarCode(simulator, car)

		if (car && (car != true)) {
			if (track && (track != true))
				fileName := (kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . this.getTrackCode(simulator, track) . "\Notes.txt")
			else
				fileName := (kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\Notes.txt")
		}
		else
			fileName := (kDatabaseDirectory . "User\" . simulatorCode . "\Notes.txt")

		try {
			return FileExist(fileName) ? FileRead(fileName) : ""
		}
		catch Any as exception {
			return ""
		}
	}

	writeNotes(simulator, car, track, notes) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local directory, fileName

		if (car && (car != true))
			car := this.getCarCode(simulator, car)

		if (car && (car != true)) {
			if (track && (track != true))
				directory := kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track
			else
				directory := kDatabaseDirectory . "User\" . simulatorCode . "\" . car
		}
		else
			directory := kDatabaseDirectory . "User\" . simulatorCode

		DirCreate(directory)

		deleteFile(directory . "\Notes.txt")

		FileAppend(notes, directory . "\Notes.txt", "UTF-16")
	}

	getTelemetryDirectory(simulator, car, track, origin) {
		return (kDatabaseDirectory . StrTitle(origin) . "\" . this.getSimulatorCode(simulator) . "\" . this.getCarCode(simulator, car)
								   . "\" . this.getTrackCode(simulator, track) . "\Lap Telemetries\")
	}

	hasTelemetry(simulator, car, track, user, community, name := false) {
		local found := false

		if user
			found := FileExist(this.getTelemetryDirectory(simulator, car, track, "User") . (name ? (name . ".telemetry") : "\*.telemetry"))

		if (!found && community)
			found := FileExist(this.getTelemetryDirectory(simulator, car, track, "Community") . (name ? (name . ".telemetry") : "\*.telemetry"))

		return found
	}

	getTelemetryNames(simulator, car, track, &userTelemetries, &communityTelemetries) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local ignore, name, extension

		if userTelemetries {
			userTelemetries := []

			loop Files, this.getTelemetryDirectory(simulator, car, track, "User") . "*.*", "F" {
				SplitPath(A_LoopFileName, , , &extension, &name)

				if (extension != "info")
					userTelemetries.Push(name)
			}
		}

		if communityTelemetries {
			communityTelemetries := []

			loop Files, this.getTelemetryDirectory(simulator, car, track, "Community") . "*.*", "F" {
				SplitPath(A_LoopFileName, , , &extension, &name)

				if (extension != "info")
					communityTelemetries.Push(name)
			}
		}
	}

	importTelemetry(simulator, car, track, fileName, &info, verbose := true) {
		local running := 0
		local name, infoFileName

		importFromSecondMonitor(&info) {
			local pid, count, importFileName

			try {
				importFileName := temporaryFileName("Import", "telemetry")

				Run("`"" . kBinariesDirectory . "Connectors\Second Monitor Reader\Second Monitor Reader.exe`" `"" . fileName . "`" `"" . importFileName . "`" `"" . (importFileName . ".info") . "`"", , "Hide", &pid)

				Sleep(500)

				count := 0

				while (ProcessExist(pid) && (count++ < 100))
					Sleep(100)

				if FileExist(importFileName) {
					info := (importFileName . ".info")

					return importFileName
				}
			}
			catch Any as exception {
				logError(exception)
			}

			return false
		}

		scanningProgress() {
			return {progress: Round(running * 100), message: translate("Scanning track..."), color: "Green"}
		}

		importFromMoTeC(&info) {
			local steerLock := this.getCarSteerLock(simulator, car, track)
			local channels := false
			local skipNext := false
			local time := 0
			local trackMap := this.getTrackMap(simulator, track)
			local trackLength := 0
			local points := []
			local firstPass := true
			local entry, ignore, channel, importFileName, infoFileName

			static motecChannels := ["Distance", "THROTTLE", "BRAKE"
								   , "STEERANGLE", "GEAR", "RPMS", "SPEED"
								   , "TC", "ABS", "G_LON", "G_LAT", "UNKNOWN (PosX)", "UNKNOWN (PosY)", "TIME"]

			if trackMap {
				loop getMultiMapValue(trackMap, "Map", "Points")
					points.Push([getMultiMapValue(trackMap, "Points", A_Index . ".X"), getMultiMapValue(trackMap, "Points", A_Index . ".Y")])

				try {
					importFileName := temporaryFileName("Import", "telemetry")

					deleteFile(importFileName)

					info := newMultiMap()

					loop 2 {
						if (A_Index = 2) {
							channels := false
							skipNext := false
							time := 0
							running := 0

							firstPass := false
						}

						loop Read, fileName {
							if ((A_Index = 1) && !InStr(A_LoopReadLine, "MoTeC CSV File"))
								return false

							if skipNext {
								skipNext := false

								continue
							}

							if (Trim(A_LoopReadLine) != "") {
								entry := collect(string2Values(",", A_LoopReadLine), (f) => StrReplace(f, "`"", ""))

								if (entry[1] = "Venue")
									setMultiMapValue(info, "Info", "Track", entry[2])
								else if (entry[1] = "Duration")
									setMultiMapValue(info, "Info", "LapTime", entry[2])
								else if ((entry[1] = "Driver") && (Trim(entry[2]) != ""))
									setMultiMapValue(info, "Info", "Driver", Trim(entry[2]))
								else if (entry[1] = "Range")
									setMultiMapValue(info, "Info", "Lap", Trim(StrReplace(entry[2], "Lap", "")))
								else if !channels {
									if inList(motecChannels, entry[1]) {
										channels := []

										for ignore, channel in motecChannels
											channels.Push([channel, inList(entry, channel)])

										skipNext := true
									}
								}
								else {
									line := []

									for ignore, channel in channels {
										if channel[2] {
											value := entry[channel[2]]

											if isNumber(value) {
												switch channel[1], false {
													case "Distance":
														if firstPass {
															running += 0.0001

															if (running > 1)
																running := 0
														}
														else
															running := (value / trackLength)
													case "THROTTLE", "BRAKE":
														value := (value / 100)
													case "STEERANGLE":
														if steerLock
															value := (- value / steerLock)
														else
															value := (- value)
													case "TIME":
														time := Max(time, value)

														value *= 1000
												}

												line.Push(value)
											}
											else
												line.Push(kNull)
										}
										else if !firstPass
											if (channel[1] = "UNKNOWN (PosX)")
												line.Push(points[Max(1, Min(points.Length, (line[1] / trackLength) * points.Length))][1])
											else if (channel[1] = "UNKNOWN (PosY)")
												line.Push(points[Max(1, Min(points.Length, (line[1] / trackLength) * points.Length))][2])
											else
												line.Push("n/a")

										if firstPass
											trackLength := Max(trackLength, line[1])
									}

									if !firstPass
										FileAppend(values2String(";", line*) . "`n", importFileName)
								}
							}
						}

						if !getMultiMapValue(info, "Info", "Driver", false)
							setMultiMapValue(info, "Info", "Driver", SessionDatabase.getUserName())

						setMultiMapValue(info, "Info", "LapTime", Round(time, 2))

						if FileExist(importFileName) {
							infoFileName := temporaryFileName("Import", "info")

							writeMultiMap(infoFileName, info)

							info := infoFileName

							return importFileName
						}
					}
				}
				catch Any as exception {
					logError(exception)
				}
			}

			return false
		}

		importFromIRacing(&info) {
			local trackData := []
			local trackFile := this.getTrackData(simulator, track)
			local directory, name, importFileName, infoFileName

			if trackFile {
				loop Read, trackFile
					trackData.Push(string2Values(A_Space, A_LoopReadLine))

				SplitPath(fileName, , &directory, , &name)

				info := readMultiMap(directory . "\" . name . ".info")

				setMultiMapValue(info, "Info", "Track", track)
				setMultiMapValue(info, "Info", "Driver", SessionDatabase.getUserName())

				try {
					importFileName := temporaryFileName("Import", "telemetry")
					infoFileName := temporaryFileName("Import", "info")

					deleteFile(importFileName)

					loop Read, fileName
						if (Trim(A_LoopReadLine) != "") {
							line := string2Values(";", A_LoopReadLine)

							running := (Max(1, Min(1000, Round(line[12] * 1000))) / 1000)

							line[12] := trackData[running][1]
							line.Push(trackData[running][2])

							FileAppend(values2String(";", line*) . "`n", importFileName)
						}

					writeMultiMap(infoFileName, info)

					info := infoFileName

					return importFileName
				}
				catch Any as exception {
					logError(exception)
				}
			}

			info := false

			return false
		}

		SplitPath(fileName, , , , &name)

		if InStr(fileName, ".json") {
			if verbose
				withTask(ProgressTask(translate("Extracting ") . name), () {
					fileName := importFromSecondMonitor(&info)
				})
			else
				fileName := importFromSecondMonitor(&info)

			return fileName
		}
		else if InStr(fileName, ".CSV") {
			if verbose
				withTask(SessionDatabase.TrackScanningImportTask(translate("Extracting ") . name, scanningProgress), () {
					fileName := importFromMoTec(&info)
				})
			else
				fileName := importFromMoTec(&info)

			return fileName
		}
		else if InStr(fileName, ".irc") {
			if verbose
				withTask(SessionDatabase.TrackScanningImportTask(translate("Extracting ") . name, scanningProgress), () {
					fileName := importFromIRacing(&info)
				})
			else
				fileName := importFromIRacing(&info)

			return fileName
		}
		else if InStr(fileName, ".telemetry") {
			info := false

			if FileExist(fileName . ".info") {
				info := readMultiMap(fileName . ".info")

				if ((getMultiMapValues(info, "Info").Count = 0) && (getMultiMapValues(info, "Lap").Count > 0))
					setMultiMapValues(info, "Info", getMultiMapValues(info, "Lap"))

				if (getMultiMapValues(info, "Info").Count > 0) {
					infoFileName := temporaryFileName("Telemetry", "info")

					writeMultiMap(infoFileName, info)

					info := infoFileName
				}
				else
					info := false
			}
			else
				info := false

			return fileName
		}
		else
			return false
	}

	readTelemetry(simulator, car, track, name, &size) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local data, fileName, file

		if !InStr(name, ".telemetry")
			name .= ".telemetry"

		fileName := (this.getTelemetryDirectory(simulator, car, track, "User") . name)

		if !FileExist(fileName)
			fileName := (this.getTelemetryDirectory(simulator, car, track, "Community") . name)

		if FileExist(fileName) {
			file := FileOpen(fileName, "r-wd")

			if file {
				size := file.Length

				data := Buffer(size)

				file.RawRead(data, size)

				file.Close()

				return data
			}
		}

		size := 0

		return Buffer(0)
	}

	readTelemetryInfo(simulator, car, track, name) {
		local fileName, info

		if !InStr(name, ".telemetry")
			name .= ".telemetry"

		fileName := (this.getTelemetryDirectory(simulator, car, track, "User") . name . ".info")

		if !FileExist(fileName) {
			fileName := (this.getTelemetryDirectory(simulator, car, track, "User") . name)

			if FileExist(fileName) {
				info := newMultiMap()

				setMultiMapValue(info, "Origin", "Simulator", this.getSimulatorName(simulator))
				setMultiMapValue(info, "Origin", "Car", car)
				setMultiMapValue(info, "Origin", "Track", track)
				setMultiMapValue(info, "Origin", "Driver", this.ID)

				setMultiMapValue(info, "Telemetry", "Name", name)
				setMultiMapValue(info, "Telemetry", "Driver", this.ID)
				setMultiMapValue(info, "Telemetry", "Date", FileGetTime(fileName, "C"))
				setMultiMapValue(info, "Telemetry", "Identifier", createGuid())
				setMultiMapValue(info, "Telemetry", "Synchronized", false)

				setMultiMapValue(info, "Access", "Share", false)
				setMultiMapValue(info, "Access", "Synchronize", true)

				writeMultiMap(fileName . ".info", info)

				return info
			}
			else
				return false
		}
		else
			return readMultiMap(fileName)
	}

	writeTelemetry(simulator, car, track, name, telemetry, size, share, synchronize
				 , driver := kUndefined, identifier := kUndefined, synchronized := false) {
		local fileName, file, info

		if !InStr(name, ".telemetry")
			name .= ".telemetry"

		fileName := normalizeDirectoryPath(this.getTelemetryDirectory(simulator, car, track, "User"))

		DirCreate(fileName)

		fileName := (fileName . "\" . name)

		deleteFile(fileName)

		file := FileOpen(fileName, "w")

		if file {
			file.RawWrite(telemetry, size)

			file.Close()

			if !driver
				driver := this.ID

			info := this.readTelemetryInfo(simulator, car, track, name)

			if (driver != kUndefined)
				setMultiMapValue(info, "Origin", "Driver", driver)

			if (identifier != kUndefined)
				setMultiMapValue(info, "Telemetry", "Identifier", identifier)

			setMultiMapValue(info, "Telemetry", "Synchronized", synchronized)

			setMultiMapValue(info, "Telemetry", "Size", size)

			setMultiMapValue(info, "Access", "Share", share)
			setMultiMapValue(info, "Access", "Synchronize", synchronize)

			this.writeTelemetryInfo(simulator, car, track, name, info)
		}
	}

	writeTelemetryInfo(simulator, car, track, name, info) {
		if !InStr(name, ".telemetry")
			name .= ".telemetry"

		writeMultiMap(this.getTelemetryDirectory(simulator, car, track, "User") . name . ".info", info)
	}

	renameTelemetry(simulator, car, track, oldName, newName) {
		local oldFileName, newFileName, info

		if !InStr(oldName, ".telemetry")
			oldName .= ".telemetry"

		if !InStr(newName, ".telemetry")
			newName .= ".telemetry"

		oldFileName := (this.getTelemetryDirectory(simulator, car, track, "User") . oldName)
		newFileName := (this.getTelemetryDirectory(simulator, car, track, "User") . newName)

		try {
			FileMove(oldFileName, newFileName, 1)

			if FileExist(oldFileName . ".info") {
				info := readMultiMap(oldFileName . ".info")

				deleteFile(oldFileName . ".info")

				setMultiMapValue(info, "Telemetry", "Name", newName)
				setMultiMapValue(info, "Telemetry", "Synchronized", false)

				writeMultiMap(newFileName . ".info", info)
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}

	removeTelemetry(simulator, car, track, name) {
		local fileName, info, identifier, ignore, connector

		if !InStr(name, ".telemetry")
			name .= ".telemetry"

		fileName := (this.getTelemetryDirectory(simulator, car, track, "User") . name)

		info := readMultiMap(fileName . ".info")

		deleteFile(fileName)
		deleteFile(fileName . ".info")

		identifier := getMultiMapValue(info, "Telemetry", "Identifier", false)

		if (identifier && (getMultiMapValue(info, "Origin", "Driver", false) = this.ID))
			for ignore, connector in this.Connectors
				try {
					connector.DeleteData("Document", identifier)
				}
				catch Any as exception {
					logError(exception, true)
				}
	}

	getSessionDirectory(simulator, car, track, type) {
		if (type = "Practice")
			type := "Solo"
		else if (type = "Race")
			type := "Team"

		return (kDatabaseDirectory . "User\" . this.getSimulatorCode(simulator) . "\" . this.getCarCode(simulator, car)
								   . "\" . this.getTrackCode(simulator, track) . "\" . type . " Sessions\")
	}

	hasSession(simulator, car, track, type, name := false) {
		if (type = "Practice")
			type := "Solo"
		else if (type = "Race")
			type := "Team"

		if name
			return FileExist(this.getSessionDirectory(simulator, car, track, type) . name . "." . type)
		else
			return FileExist(this.getSessionDirectory(simulator, car, track, type) . "*." . type)
	}

	getSessions(simulator, car, track, type, &names, &infos := false) {
		local name

		if (type = "Practice")
			type := "Solo"
		else if (type = "Race")
			type := "Team"

		names := []

		if infos
			infos := []

		loop Files, this.getSessionDirectory(simulator, car, track, type) . "*." . StrLower(type), "F" {
			SplitPath(A_LoopFileName, , , , &name)

			names.Push(name)

			if infos
				infos.Push(readMultiMap(A_LoopFileFullPath))
		}
	}

	readSession(simulator, car, track, type, name, &meta, &size) {
		local data, fileName, file

		if (type = "Practice")
			type := "Solo"
		else if (type = "Race")
			type := "Team"

		fileName := (this.getSessionDirectory(simulator, car, track, type) . name)

		if FileExist(fileName . "." . type) {
			file := FileOpen(fileName . ".data", "r-wd")

			if file {
				size := file.Length

				data := Buffer(size)

				file.RawRead(data, size)

				file.Close()

				meta := readMultiMap(fileName . "." . type)

				return data
			}
		}

		size := 0
		meta := false

		return Buffer(0)
	}

	readSessionInfo(simulator, car, track, type, name) {
		local fileName, info

		if (type = "Practice")
			type := "Solo"
		else if (type = "Race")
			type := "Team"

		fileName := (this.getSessionDirectory(simulator, car, track, type) . name . ".info")

		if !FileExist(fileName) {
			if FileExist(this.getSessionDirectory(simulator, car, track, type) . name . "." . StrLower(type)) {
				info := newMultiMap()

				setMultiMapValue(info, "Origin", "Simulator", this.getSimulatorName(simulator))
				setMultiMapValue(info, "Origin", "Car", car)
				setMultiMapValue(info, "Origin", "Track", track)
				setMultiMapValue(info, "Origin", "Driver", this.ID)

				setMultiMapValue(info, "Session", "Name", name)
				setMultiMapValue(info, "Session", "Type", type)
				setMultiMapValue(info, "Session", "Identifier", createGuid())
				setMultiMapValue(info, "Session", "Synchronized", false)

				setMultiMapValue(info, "Access", "Share", false)
				setMultiMapValue(info, "Access", "Synchronize", true)

				writeMultiMap(fileName, info)

				return info
			}
			else
				return false
		}
		else
			return readMultiMap(fileName)
	}

	writeSession(simulator, car, track, type, name, meta, session, size, share, synchronize
			   , driver := kUndefined, identifier := kUndefined, synchronized := false) {
		local fileName, file, info

		if (type = "Practice")
			type := "Solo"
		else if (type = "Race")
			type := "Team"

		fileName := this.getSessionDirectory(simulator, car, track, type)

		DirCreate(fileName)

		fileName := (fileName . "\" . name)

		deleteFile(fileName . "." . StrLower(type))
		deleteFile(fileName . ".data")

		file := FileOpen(fileName . ".data", "w")

		if file {
			file.RawWrite(session, size)

			file.Close()

			writeMultiMap(fileName . "." . StrLower(type), meta)

			if !driver
				driver := this.ID

			info := this.readSessionInfo(simulator, car, track, type, name)

			if (driver != kUndefined)
				setMultiMapValue(info, "Origin", "Driver", driver)

			if (identifier != kUndefined)
				setMultiMapValue(info, "Session", "Identifier", identifier)

			setMultiMapValue(info, "Session", "Synchronized", synchronized)

			setMultiMapValue(info, "Session", "Size", size)

			setMultiMapValue(info, "Access", "Share", share)
			setMultiMapValue(info, "Access", "Synchronize", synchronize)

			this.writeSessionInfo(simulator, car, track, type, name, info)
		}
	}

	writeSessionInfo(simulator, car, track, type, name, info) {
		if (type = "Practice")
			type := "Solo"
		else if (type = "Race")
			type := "Team"

		writeMultiMap(this.getSessionDirectory(simulator, car, track, type) . name . ".info", info)
	}

	renameSession(simulator, car, track, type, oldName, newName) {
		local oldFileName, newFileName, info

		if (type = "Practice")
			type := "Solo"
		else if (type = "Race")
			type := "Team"

		oldFileName := (this.getSessionDirectory(simulator, car, track, type) . oldName)
		newFileName := (this.getSessionDirectory(simulator, car, track, type) . newName)

		try {
			FileMove(oldFileName . "." . StrLower(type), newFileName . "." . StrLower(type), 1)
			FileMove(oldFileName . ".data", newFileName . ".data", 1)

			if FileExist(oldFileName . ".info") {
				info := readMultiMap(oldFileName . ".info")

				deleteFile(oldFileName . ".info")

				setMultiMapValue(info, "Session", "Name", newName)
				setMultiMapValue(info, "Session", "Synchronized", false)

				writeMultiMap(newFileName . ".info", info)
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}

	removeSession(simulator, car, track, type, name) {
		local fileName, info, identifier, ignore, connector

		if (type = "Practice")
			type := "Solo"
		else if (type = "Race")
			type := "Team"

		fileName := (this.getSessionDirectory(simulator, car, track, type) . name)

		info := readMultiMap(fileName . ".info")

		deleteFile(fileName . "." . StrLower(type))
		deleteFile(fileName . ".data")
		deleteFile(fileName . ".info")

		identifier := getMultiMapValue(info, "Session", "Identifier", false)

		if (identifier && (getMultiMapValue(info, "Origin", "Driver", false) = this.ID))
			for ignore, connector in this.Connectors
				try {
					connector.DeleteData("Document", identifier)
				}
				catch Any as exception {
					logError(exception, true)
				}
	}

	hasSetup(simulator, car, track, type, user, community, name := false) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local found := false

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		if user
			found := FileExist(kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\"
												  . type . (name ? (name . ".*") : "\*.*"))

		if (!found && community)
			found := FileExist(kDatabaseDirectory . "Community\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\"
												  . type . (name ? (name . ".*") : "\*.*"))

		return found
	}

	getSetupNames(simulator, car, track, &userSetups, &communitySetups) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local ignore, type, setups, name, extension

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		if userSetups {
			userSetups := CaseInsenseMap()

			for ignore, type in kSetupTypes {
				setups := []

				loop Files, kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\" . type . "\*.*", "F" {
					SplitPath(A_LoopFileName, &name, , &extension)

					if (extension != "info")
						setups.Push(name)
				}

				userSetups[type] := setups
			}
		}

		if communitySetups {
			communitySetups := CaseInsenseMap()

			for ignore, type in kSetupTypes {
				setups := []

				loop Files, kDatabaseDirectory . "Community\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\" . type . "\*.*", "F" {
					SplitPath(A_LoopFileName, &name, , &extension)

					if (extension != "info")
						setups.Push(name)
				}

				communitySetups[type] := setups
			}
		}
	}

	readSetup(simulator, car, track, type, name, &size) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local data, fileName, file

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		fileName := kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\" . type . "\" . name

		if !FileExist(fileName)
			fileName := kDatabaseDirectory . "Community\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\" . type . "\" . name

		if FileExist(fileName) {
			file := FileOpen(fileName, "r-wd")

			if file {
				size := file.Length

				data := Buffer(size)

				file.RawRead(data, size)

				file.Close()

				return data
			}
		}

		size := 0

		return Buffer(0)
	}

	readSetupInfo(simulator, car, track, type, name) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local fileName, info

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		fileName := kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\" . type . "\" . name . ".info"

		if !FileExist(fileName) {
			fileName := kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\" . type . "\" . name

			if FileExist(fileName) {
				info := newMultiMap()

				setMultiMapValue(info, "Origin", "Simulator", this.getSimulatorName(simulator))
				setMultiMapValue(info, "Origin", "Car", car)
				setMultiMapValue(info, "Origin", "Track", track)
				setMultiMapValue(info, "Origin", "Driver", this.ID)

				setMultiMapValue(info, "Setup", "Name", name)
				setMultiMapValue(info, "Setup", "Type", type)
				setMultiMapValue(info, "Setup", "Identifier", createGuid())
				setMultiMapValue(info, "Setup", "Synchronized", false)

				setMultiMapValue(info, "Access", "Share", false)
				setMultiMapValue(info, "Access", "Synchronize", true)

				writeMultiMap(fileName . ".info", info)

				return info
			}
			else
				return false
		}
		else
			return readMultiMap(fileName)
	}

	writeSetup(simulator, car, track, type, name, setup, size, share, synchronize
			 , driver := kUndefined, identifier := kUndefined, synchronized := false) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local fileName, file, info

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		fileName := kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\" . type

		DirCreate(fileName)

		fileName := (fileName . "\" . name)

		deleteFile(fileName)

		file := FileOpen(fileName, "w")

		if file {
			file.RawWrite(setup, size)

			file.Close()

			if !driver
				driver := this.ID

			info := this.readSetupInfo(simulator, car, track, type, name)

			if (driver != kUndefined)
				setMultiMapValue(info, "Origin", "Driver", driver)

			if (identifier != kUndefined)
				setMultiMapValue(info, "Setup", "Identifier", identifier)

			setMultiMapValue(info, "Setup", "Synchronized", synchronized)

			setMultiMapValue(info, "Setup", "Size", size)

			setMultiMapValue(info, "Access", "Share", share)
			setMultiMapValue(info, "Access", "Synchronize", synchronize)

			this.writeSetupInfo(simulator, car, track, type, name, info)
		}
	}

	writeSetupInfo(simulator, car, track, type, name, info) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local fileName

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		fileName := kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\" . type . "\" . name . ".info"

		writeMultiMap(fileName, info)
	}

	renameSetup(simulator, car, track, type, oldName, newName) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local oldFileName, newFileName, info

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		oldFileName := kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\" . type . "\" . oldName
		newFileName := kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\" . type . "\" . newName

		try {
			FileMove(oldFileName, newFileName, 1)

			if FileExist(oldFileName . ".info") {
				info := readMultiMap(oldFileName . ".info")

				deleteFile(oldFileName . ".info")

				setMultiMapValue(info, "Setup", "Name", newName)
				setMultiMapValue(info, "Setup", "Synchronized", false)

				writeMultiMap(newFileName . ".info", info)
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}

	removeSetup(simulator, car, track, type, name) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local fileName, info, identifier, ignore, connector

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		fileName := kDatabaseDirectory . "User\" . simulatorCode . "\" . car . "\" . track . "\Car Setups\" . type . "\" . name

		info := readMultiMap(fileName . ".info")

		deleteFile(fileName)
		deleteFile(fileName . ".info")

		identifier := getMultiMapValue(info, "Setup", "Identifier", false)

		if (identifier && (getMultiMapValue(info, "Origin", "Driver", false) = this.ID))
			for ignore, connector in this.Connectors
				try {
					connector.DeleteData("Document", identifier)
				}
				catch Any as exception {
					logError(exception, true)
				}
	}

	getStrategyDirectory(simulator, car, track, origin) {
		return (kDatabaseDirectory . StrTitle(origin) . "\" . this.getSimulatorCode(simulator) . "\" . this.getCarCode(simulator, car)
								   . "\" . this.getTrackCode(simulator, track) . "\Race Strategies\")
	}

	hasStrategy(simulator, car, track, user, community, name := false) {
		local found := false

		if user
			found := FileExist(this.getStrategyDirectory(simulator, car, track, "User") . (name ? (name . ".strategy") : "\*.strategy"))

		if (!found && community)
			found := FileExist(this.getStrategyDirectory(simulator, car, track, "Community") . (name ? (name . ".strategy") : "\*.strategy"))

		return found
	}

	getStrategyNames(simulator, car, track, &userStrategies, &communityStrategies) {
		local ignore, strategies, name, extension

		if userStrategies {
			userStrategies := []

			loop Files, this.getStrategyDirectory(simulator, car, track, "User") . "*.*", "F" {
				SplitPath(A_LoopFileName, , , &extension, &name)

				if (extension != "info")
					userStrategies.Push(name)
			}
		}

		if communityStrategies {
			communityStrategies := []

			loop Files, this.getStrategyDirectory(simulator, car, track, "Community") . "*.*", "F" {
				SplitPath(A_LoopFileName, , , &extension, &name)

				if (extension != "info")
					communityStrategies.Push(name)
			}
		}
	}

	readStrategy(simulator, car, track, name) {
		local data, fileName

		if !InStr(name, ".strategy")
			name .= ".strategy"

		fileName := (this.getStrategyDirectory(simulator, car, track, "User") . name)

		if !FileExist(fileName)
			fileName := (this.getStrategyDirectory(simulator, car, track, "Community") . name)

		return readMultiMap(fileName)
	}

	readStrategyInfo(simulator, car, track, name) {
		local fileName, info

		if !InStr(name, ".strategy")
			name .= ".strategy"

		fileName := (this.getStrategyDirectory(simulator, car, track, "User") . name . ".info")

		if !FileExist(fileName) {
			fileName := (this.getStrategyDirectory(simulator, car, track, "User") . name)

			if FileExist(fileName) {
				info := newMultiMap()

				setMultiMapValue(info, "Origin", "Simulator", this.getSimulatorName(simulator))
				setMultiMapValue(info, "Origin", "Car", car)
				setMultiMapValue(info, "Origin", "Track", track)
				setMultiMapValue(info, "Origin", "Driver", this.ID)

				setMultiMapValue(info, "Strategy", "Name", name)
				setMultiMapValue(info, "Strategy", "Identifier", createGuid())
				setMultiMapValue(info, "Strategy", "Synchronized", false)

				setMultiMapValue(info, "Access", "Share", true)
				setMultiMapValue(info, "Access", "Synchronize", true)

				writeMultiMap(fileName . ".info", info)

				return info
			}
			else
				return false
		}
		else
			return readMultiMap(fileName)
	}

	writeStrategy(simulator, car, track, name, strategy, share, synchronize
				, driver := kUndefined, identifier := kUndefined, synchronized := false) {
		local fileName, file, info

		if !InStr(name, ".strategy")
			name .= ".strategy"

		fileName := normalizeDirectoryPath(this.getStrategyDirectory(simulator, car, track, "User"))

		DirCreate(fileName)

		fileName := (fileName . "\" . name)

		deleteFile(fileName)

		writeMultiMap(fileName, strategy)

		if !driver
			driver := this.ID

		info := this.readStrategyInfo(simulator, car, track, name)

		if (driver != kUndefined)
			setMultiMapValue(info, "Origin", "Driver", driver)

		if (identifier != kUndefined)
			setMultiMapValue(info, "Strategy", "Identifier", identifier)

		setMultiMapValue(info, "Strategy", "Synchronized", synchronized)

		setMultiMapValue(info, "Access", "Share", share)
		setMultiMapValue(info, "Access", "Synchronize", synchronize)

		this.writeStrategyInfo(simulator, car, track, name, info)
	}

	writeStrategyInfo(simulator, car, track, name, info) {
		if !InStr(name, ".strategy")
			name .= ".strategy"

		writeMultiMap(this.getStrategyDirectory(simulator, car, track, "User") . name . ".info", info)
	}

	renameStrategy(simulator, car, track, oldName, newName) {
		local oldFileName, newFileName, info

		if !InStr(oldName, ".strategy")
			oldName .= ".strategy"

		if !InStr(newName, ".strategy")
			newName .= ".strategy"

		oldFileName := (this.getStrategyDirectory(simulator, car, track, "User") . oldName)
		newFileName := (this.getStrategyDirectory(simulator, car, track, "User") . newName)

		try {
			FileMove(oldFileName, newFileName, 1)

			if FileExist(oldFileName . ".info") {
				info := readMultiMap(oldFileName . ".info")

				deleteFile(oldFileName . ".info")

				setMultiMapValue(info, "Strategy", "Name", newName)
				setMultiMapValue(info, "Strategy", "Synchronized", false)

				writeMultiMap(newFileName . ".info", info)
			}
		}
		catch Any as exception {
			logError(exception)
		}
	}

	removeStrategy(simulator, car, track, name) {
		local fileName, info, identifier, ignore, connector

		if !InStr(name, ".strategy")
			name .= ".strategy"

		fileName := (this.getStrategyDirectory(simulator, car, track, "User") . name)

		info := readMultiMap(fileName . ".info")

		deleteFile(fileName)
		deleteFile(fileName . ".info")

		identifier := getMultiMapValue(info, "Setup", "Identifier", false)

		if (identifier && (getMultiMapValue(info, "Origin", "Driver", false) = this.ID))
			for ignore, connector in this.Connectors
				try {
					connector.DeleteData("Document", identifier)
				}
				catch Any as exception {
					logError(exception, true)
				}
	}

	writeDatabaseState(identifier, info, arguments*) {
		local configuration := newMultiMap()
		local exception, rebuild

		if identifier {
			setMultiMapValue(configuration, "Database Synchronizer", "ServerURL", this.ServerURL[identifier])
			setMultiMapValue(configuration, "Database Synchronizer", "ServerToken", this.ServerToken[identifier])

			setMultiMapValue(configuration, "Database Synchronizer", "Connected", this.Connected[identifier])
		}

		setMultiMapValue(configuration, "Database Synchronizer", "UserID", this.ID)
		setMultiMapValue(configuration, "Database Synchronizer", "DatabaseID", this.DatabaseID)

		if ((info = "State") || !identifier) {
			if (identifier && !this.ServerURL[identifier])
				setMultiMapValue(configuration, "Database Synchronizer", "State", "Disabled")
			else if (this.ID != this.DatabaseID) {
				setMultiMapValue(configuration, "Database Synchronizer", "State", "Warning")

				setMultiMapValue(configuration, "Database Synchronizer", "Information"
							   , translate("Message: ") . translate("Cannot synchronize a database from another user..."))
			}
			else if (identifier && !this.Connector[identifier]) {
				setMultiMapValue(configuration, "Database Synchronizer", "State", "Critical")

				setMultiMapValue(configuration, "Database Synchronizer", "Information"
							   , translate("Message: ") . translate("Cannot connect to the Team Server (URL: ") . this.ServerURL[identifier]
							   . translate(", Token: ") . this.ServerToken[identifier] . translate(")"))
			}
			else if (identifier && !this.Connected[identifier]) {
				setMultiMapValue(configuration, "Database Synchronizer", "State", "Critical")

				setMultiMapValue(configuration, "Database Synchronizer", "Information"
							   , translate("Message: ") . translate("Lost connection to the Team Server (URL: ") . this.ServerURL[identifier]
							   . translate(", Token: ") . this.ServerToken[identifier] . translate(")"))
			}
			else if (this.Connectors.Count != this.ServerURLs.Count) {
				for identifier, serverURL in this.ServerURLs
					if !this.Connectors.Has(identifier) {
						setMultiMapValue(configuration, "Database Synchronizer", "State", "Critical")

						setMultiMapValue(configuration, "Database Synchronizer", "ServerURL", serverURL)
						setMultiMapValue(configuration, "Database Synchronizer", "ServerToken", this.ServerToken[identifier])
						setMultiMapValue(configuration, "Database Synchronizer", "Connected", this.Connected[identifier])

						setMultiMapValue(configuration, "Database Synchronizer", "Information"
									   , translate("Message: ") . translate("Lost connection to the Team Server (URL: ") . serverURL
									   . translate(", Token: ") . this.ServerToken[identifier] . translate(")"))

						break
					}
			}
			else {
				setMultiMapValue(configuration, "Database Synchronizer", "State", "Active")

				setMultiMapValue(configuration, "Database Synchronizer", "Information"
							   , translate("Message: ") . translate("Waiting for next synchronization..."))

				setMultiMapValue(configuration, "Database Synchronizer", "Synchronization", "Waiting")
			}
		}
		else if (info = "Synchronize") {
			setMultiMapValue(configuration, "Database Synchronizer", "State", "Active")

			rebuild := arguments[1]

			setMultiMapValue(configuration, "Database Synchronizer", "Information"
						   , translate("Message: ") . (rebuild ? translate("Rebuilding database...")
															   : translate("Synchronizing database...")))

			setMultiMapValue(configuration, "Database Synchronizer", "Identifier", identifier)
			setMultiMapValue(configuration, "Database Synchronizer", "Synchronization", "Running")
			setMultiMapValue(configuration, "Database Synchronizer", "Counter", (arguments.Length > 1) ? arguments[2] : false)
		}
		else if (info = "Success") {
			setMultiMapValue(configuration, "Database Synchronizer", "State", "Active")

			setMultiMapValue(configuration, "Database Synchronizer", "Information"
						   , translate("Message: ") . translate("Synchronization finished..."))

			setMultiMapValue(configuration, "Database Synchronizer", "Synchronization", "Finished")
		}
		else if (info = "Error") {
			setMultiMapValue(configuration, "Database Synchronizer", "State", "Critical")

			exception := arguments[1]

			setMultiMapValue(configuration, "Database Synchronizer", "Information"
						   , translate("Error: ") . translate("Synchronization failed (Exception: ")
						   . (isObject(exception) ? exception.Message : exception) . translate(")"))

			setMultiMapValue(configuration, "Database Synchronizer", "Synchronization", "Failed")
		}

		writeMultiMap(kTempDirectory . "Database Synchronizer.state", configuration)
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                  Internal Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

stringToMap(elementSeparator, valueSeparator, text, default := "Standard") {
	local result := CaseInsenseMap()
	local ignore, keyValue

	for ignore, keyValue in string2Values(elementSeparator, text) {
		keyValue := string2Values(valueSeparator, keyValue)

		if (keyValue.Length = 1)
			result[default] := keyValue[1]
		else
			result[keyValue[1]] := keyValue[2]
	}

	return result
}

mapToString(elementSeparator, valueSeparator, map) {
	local result := []
	local key, value

	for key, value in map
		result.Push(key . valueSeparator . value)

	return values2String(elementSeparator, result*)
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

compound(compound, color := false) {
	return (color ? (compound . " (" . color . ")") : string2Values(A_Space, compound)[1])
}

compoundColor(compound) {
	compound := string2Values(A_Space, compound)

	return ((compound.Length == 1) ? "Black" : SubStr(compound[2], 2, StrLen(compound[2]) - 2))
}

splitCompound(qualifiedCompound, &tyreCompound, &tyreCompoundColor) {
	tyreCompound := compound(qualifiedCompound)
	tyreCompoundColor := compoundColor(qualifiedCompound)
}

normalizeCompound(qualifiedCompound) {
	local tyreCompound, tyreCompoundColor

	splitCompound(qualifiedCompound, &tyreCompound, &tyreCompoundColor)

	return compound(tyreCompound, tyreCompoundColor)
}

equalCompounds(compounds1, compounds2) {
	if (compounds1.Length != compounds2.Length)
		return false
	else
		loop compounds1.Length
			if (compounds1[A_Index] != compounds2[A_Index])
				return false

	return true
}

compounds(tyreCompounds, tyreCompoundColors := false) {
	local compounds := []
	local theCompound

	loop tyreCompounds.Length {
		theCompound := tyreCompounds[A_Index]

		if (theCompound && (theCompound != "-"))
			compounds.Push(compound(theCompound, (tyreCompoundColors ? tyreCompoundColors[A_Index] : false)))
		else
			compounds.Push("-")
	}

	return compounds
}

compoundColors(tyreCompounds) {
	local compounds := []

	loop tyreCompounds.Length {
		theCompound := tyreCompounds[A_Index]

		if (theCompound && (theCompound != "-"))
			compounds.Push(compoundColor(theCompound))
		else
			compounds.Push("-")
	}

	return compounds
}

normalizeCompounds(compounds) {
	if !isObject(compounds)
		compounds := string2Values(",", compounds)

	loop compounds.Length {
		compound := compounds[A_Index]

		if (!compound || (compound = "-"))
			compounds[A_Index] := "-"
		else
			compounds[A_Index] := normalizeCompound(compound)
	}

	return compounds
}

splitCompounds(compounds, &tyreCompounds, &tyreCompoundColors) {
	tyreCompounds := []
	tyreCompoundColors := []

	do(compounds, (compound) {
		local color

		if (compound = "-") {
			tyreCompounds.Push("-")
			tyreCompoundColors.Push("-")
		}
		else {
			splitCompound(compound, &compound, &color)

			tyreCompounds.Push(compound)
			tyreCompoundColors.Push(color)
		}
	})
}

combineCompounds(&compounds, &compoundColors := false) {
	local newCompounds, newCompoundColors

	if (compounds.Length = 1)
		return
	else {
		newCompounds := removeDuplicates(compounds)

		if (newCompounds.Length = 1)
			if !compoundColors
				compounds := newCompounds
			else {
				newCompoundColors := removeDuplicates(compoundColors)

				if (newCompoundColors.Length = 1) {
					compounds := newCompounds
					compoundColors := newCompoundColors
				}
			}
	}
}

parseDriverName(fullName, &forName, &surName, &nickName?) {
	if InStr(fullName, "(") {
		fullname := StrSplit(fullName, "(", " `t", 2)

		nickName := Trim(StrReplace(fullName[2], ")", ""))
		fullName := fullName[1]
	}
	else
		nickName := ""

	fullName := StrSplit(fullName, A_Space, " `t", 2)

	if (fullName.Length > 0) {
		forName := fullName[1]
		surName := ((fullName.Length > 1) ? fullName[2] : "")
	}
	else {
		forName := ""
		surName := ""
	}
}

driverName(forName, surName, nickName := false) {
	local name := ""

	if (forName != "")
		name .= (forName . A_Space)

	if (surName != "")
		name .= (surName . A_Space)

	if !nickName
		nickName := (SubStr(forName, 1, 1) . SubStr(surName, 1, 1))

	if (nickName != "")
		name .= (translate("(") . nickName . translate(")"))

	return Trim(name)
}

updateSynchronizationState(sessionDB, rebuild) {
	sessionDB.writeDatabaseState(synchronizeDatabase("Identifier"), "Synchronize", rebuild, synchronizeDatabase("Counter"))
}

synchronizeDatabase(command := false) {
	local sessionDB := SessionDatabase()
	local rebuild := (command = "Rebuild")
	local timestamp, simulators, ignore, connector, synchronizer, synchronizeTask, id

	static stateTask := false
	static counter := 0
	static identifier := false

	if (command = "Counter")
		return counter
	else if (command = "Identifier")
		return identifier

	if !stateTask {
		stateTask := PeriodicTask(ObjBindMethod(sessionDB, "writeDatabaseState", false, "State"), 10000)

		stateTask.start()
	}

	if (command = "Stop") {
		stateTask.stop()

		return
	}
	else if (command = "Start") {
		stateTask.start()

		return
	}

	sessionDB.UseCommunity := false

	if (sessionDB.ID = sessionDB.DatabaseID) {
		identifier := false

		try {
			stateTask.pause()

			counter := 0

			synchronizeTask := PeriodicTask(updateSynchronizationState.Bind(sessionDB, rebuild), 1000, kInterruptPriority)

			try {
				for id, connector in sessionDB.Connectors {
					identifier := id

					if (A_Index = 1)
						synchronizeTask.start()

					lastSynchronization := (!rebuild ? sessionDB.Synchronization[id] : false)
					simulators := sessionDB.getSimulators(!lastSynchronization)
					timestamp := connector.GetServerTimestamp()

					for ignore, synchronizer in sessionDB.Synchronizers
						synchronizer.Call(sessionDB.Groups[id], sessionDB, connector, simulators, timestamp, lastSynchronization, !lastSynchronization, &counter)

					sessionDB.Synchronization[id] := timestamp
				}

				sessionDB.writeDatabaseState(identifier, "Success")

				Task.startTask(ObjBindMethod(stateTask, "resume"), 10000)
			}
			finally {
				synchronizeTask.stop()
			}
		}
		catch Any as exception {
			logError(exception, true)

			sessionDB.writeDatabaseState(identifier, "Error", exception)

			Task.startTask(ObjBindMethod(stateTask, "resume"), 30000)

			return false
		}

		return true
	}
	else
		return false
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

parseData(properties) {
	local result := CaseInsenseMap()
	local property

	properties := StrReplace(properties, "`r", "")

	loop Parse, properties, "`n" {
		property := string2Values("=", A_LoopField)

		result[property[1]] := property[2]
	}

	return result
}

synchronizeDrivers(groups, sessionDB, connector, simulators, timestamp, lastSynchronization, force, &counter) {
	local ignore, simulator, db, modified, identifier, driver, drivers, wasNull, properties

	for ignore, simulator in simulators {
		simulator := sessionDB.getSimulatorCode(simulator)

		db := Database(kDatabaseDirectory . "User\" . simulator . "\", kSessionSchemas)

		if db.lock("Drivers", false)
			try {
				modified := false

				drivers := connector.QueryData("License", "Simulator = '" . simulator . "' And Modified > " . lastSynchronization)

				for ignore, identifier in string2Values(";", drivers) {
					modified := true

					driver := parseData(connector.GetData("License", identifier))
					driver["ID"] := ((driver["Driver"] = "") ? kNull : driver["Driver"])
					driver["Synchronized"] := timestamp

					drivers := db.query("Drivers", {Where: {ID: driver["ID"], Forname: driver["Forname"], Surname: driver["Surname"], Nickname: driver["Nickname"]}})

					if (drivers.Length = 0) {
						db.add("Drivers", driver)

						counter += 1
					}
					else {
						drivers[1]["Identifier"] := driver["Identifier"]
						drivers[1]["Synchronized"] := timestamp
					}
				}

				for ignore, driver in db.query("Drivers", {Where: force ? {ID: sessionDB.ID} : {Synchronized: kNull, ID: sessionDB.ID} })
					try {
						if (driver["Identifier"] = kNull) {
							wasNull := true

							driver["Identifier"] := createGUID()
						}
						else
							wasNull := false

						properties := substituteVariables("Identifier=%Identifier%`nSimulator=%Simulator%`n"
													    . "Driver=%Driver%`nForname=%Forname%`nSurname=%Surname%`nNickname=%Nickname%"
														, {Identifier: StrLower(driver["Identifier"]), Simulator: simulator
														 , Driver: driver["ID"], Forname: driver["Forname"]
														 , Surname: driver["Surname"], Nickname: driver["Nickname"]})

						if (connector.CountData("License", "Identifier = '" . StrLower(driver["Identifier"]) . "'") = 0)
							connector.CreateData("License", properties)
						else
							connector.UpdateData("License", driver["Identifier"], properties)

						counter += 1

						driver["Synchronized"] := timestamp

						db.changed("Drivers")
						modified := true
					}
					catch Any as exception {
						logError(exception)

						if wasNull
							driver["Identifier"] := kNull
					}
			}
			finally {
				if modified
					db.flush("Drivers")

				db.unlock("Drivers")
			}
	}
}

synchronizeSessions(groups, sessionDB, connector, simulators, timestamp, lastSynchronization, force, &counter) {
	local hasError := false
	local start, lastRun, ignore, identifier, document, name, meta, type, info, simulator, car, track, session, size

	if inList(groups, "Sessions") {
		lastRun := getMultiMapValue(readMultiMap(kDatabaseDirectory . "SYNCHRONIZE"), "Sessions", "Synchronization", 0)
		start := A_Now

		for ignore, identifier in string2Values(";", connector.QueryData("Document", "Type = 'Session' And Modified > " . lastSynchronization)) {
			document := parseData(connector.GetData("Document", identifier))

			simulator := document["Simulator"]

			if inList(simulators, sessionDB.getSimulatorName(simulator)) {
				info := parseMultiMap(connector.GetDataValue("Document", identifier, "Info"))

				car := document["Car"]
				track := document["Track"]

				try {
					if !sessionDB.readSessionInfo(simulator, car, track
												, getMultiMapValue(info, "Session", "Type")
												, getMultiMapValue(info, "Session", "Name")) {
						counter += 1

						sessionDB.writeSession(simulator, car, track
											 , getMultiMapValue(info, "Session", "Type")
											 , getMultiMapValue(info, "Session", "Name")
											 , parseMultiMap(connector.GetDataValue("Document", identifier, "Meta"))
											 , decodeB16(connector.GetDataValue("Document", identifier, "Data"))
											 , getMultiMapValue(info, "Session", "Size")
											 , getMultiMapValue(info, "Access", "Share")
											 , getMultiMapValue(info, "Access", "Synchronize")
											 , getMultiMapValue(info, "Origin", "Driver")
											 , identifier, true)
					}
				}
				catch Any as exception {
					logError(exception)
				}
			}
		}

		for ignore, simulator in simulators {
			simulator := sessionDB.getSimulatorCode(simulator)

			loop Files, kDatabaseDirectory . "User\" . simulator . "\*.*", "D" {
				car := A_LoopFileName

				loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\*.*", "D" {
					track := A_LoopFileName

					for ignore, type in ["Solo Sessions", "Team Sessions"]
						loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\" . type . "\*.info", "F" {
							lastModified := FileGetTime(A_LoopFilePath, "M")

							if (StrCompare(lastModified, lastRun) > 0) {
								info := readMultiMap(A_LoopFilePath)

								if ((getMultiMapValue(info, "Origin", "Driver", false) = sessionDB.ID)
								 && getMultiMapValue(info, "Access", "Synchronize", false)
								 && !getMultiMapValue(info, "Session", "Synchronized", false)) {
									session := sessionDB.readSession(simulator, car, track
																   , getMultiMapValue(info, "Session", "Type")
																   , getMultiMapValue(info, "Session", "Name")
																   , &meta, &size)
									info := sessionDB.readSessionInfo(simulator, car, track
																	, getMultiMapValue(info, "Session", "Type")
																	, getMultiMapValue(info, "Session", "Name"))

									if (session && meta && (size > 0)) {
										identifier := StrLower(getMultiMapValue(info, "Session", "Identifier"))

										try {
											if (connector.CountData("Document", "Identifier = '" . identifier . "'") = 0)
												connector.CreateData("Document"
																   , substituteVariables("Type=Session`n"
																					   . "Identifier=%Identifier%`nDriver=%Driver%`n"
																					   . "Simulator=%Simulator%`nCar=%Car%`nTrack=%Track%"
																					   , {Identifier: identifier
																						, Driver: getMultiMapValue(info, "Origin", "Driver")
																						, Simulator: simulator, Car: car, Track: track}))

											counter += 1

											connector.SetDataValue("Document", identifier, "Meta", printMultiMap(meta))
											connector.SetDataValue("Document", identifier, "Data", encodeB16(session, size))

											setMultiMapValue(info, "Session", "Synchronized", true)

											connector.SetDataValue("Document", identifier, "Info", printMultiMap(info))

											sessionDB.writeSessionInfo(simulator, car, track
																	 , getMultiMapValue(info, "Session", "Type")
																	 , getMultiMapValue(info, "Session", "Name")
																	 , info)
										}
										catch Any as exception {
											logError(exception)

											hasError := true
										}
									}
								}
							}
						}
				}
			}
		}

		if !hasError {
			info := readMultiMap(kDatabaseDirectory . "SYNCHRONIZE")

			setMultiMapValue(info, "Sessions", "Synchronization", start)

			writeMultiMap(kDatabaseDirectory . "SYNCHRONIZE", info)
		}
	}
}

synchronizeSetups(groups, sessionDB, connector, simulators, timestamp, lastSynchronization, force, &counter) {
	local hasError := false
	local start, lastRun, ignore, identifier, document, name, type, info, simulator, car, track, setup, size

	if inList(groups, "Setups") {
		lastRun := getMultiMapValue(readMultiMap(kDatabaseDirectory . "SYNCHRONIZE"), "Setups", "Synchronization", 0)
		start := A_Now

		for ignore, identifier in string2Values(";", connector.QueryData("Document", "Type = 'Setup' And Modified > " . lastSynchronization)) {
			document := parseData(connector.GetData("Document", identifier))

			simulator := document["Simulator"]

			if inList(simulators, sessionDB.getSimulatorName(simulator)) {
				info := parseMultiMap(connector.GetDataValue("Document", identifier, "Info"))

				car := document["Car"]
				track := document["Track"]

				try {
					if !sessionDB.readSetupInfo(simulator, car, track
											  , getMultiMapValue(info, "Setup", "Type")
											  , getMultiMapValue(info, "Setup", "Name")) {
						setup := connector.GetDataValue("Document", identifier, "Setup")

						counter += 1

						sessionDB.writeSetup(simulator, car, track
										   , getMultiMapValue(info, "Setup", "Type")
										   , getMultiMapValue(info, "Setup", "Name")
										   , getMultiMapValue(info, "Setup", "Encoded") ? decodeB16(setup) : setup
										   , getMultiMapValue(info, "Setup", "Size")
										   , getMultiMapValue(info, "Access", "Share")
										   , getMultiMapValue(info, "Access", "Synchronize")
										   , getMultiMapValue(info, "Origin", "Driver")
										   , identifier, true)
					}
				}
				catch Any as exception {
					logError(exception)
				}
			}
		}

		for ignore, simulator in simulators {
			simulator := sessionDB.getSimulatorCode(simulator)

			loop Files, kDatabaseDirectory . "User\" . simulator . "\*.*", "D" {
				car := A_LoopFileName

				loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\*.*", "D" {
					track := A_LoopFileName

					for ignore, type in kSetupTypes
						loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Car Setups\" . type . "\*.info", "F" {
							lastModified := FileGetTime(A_LoopFilePath, "M")

							if (StrCompare(lastModified, lastRun) > 0) {
								info := readMultiMap(A_LoopFilePath)

								if ((getMultiMapValue(info, "Origin", "Driver", false) = sessionDB.ID)
								 && getMultiMapValue(info, "Access", "Synchronize", false)
								 && !getMultiMapValue(info, "Setup", "Synchronized", false)) {
									setup := sessionDB.readSetup(simulator, car, track
															   , getMultiMapValue(info, "Setup", "Type")
															   , getMultiMapValue(info, "Setup", "Name")
															   , &size)
									info := sessionDB.readSetupInfo(simulator, car, track
																  , getMultiMapValue(info, "Setup", "Type")
																  , getMultiMapValue(info, "Setup", "Name"))

									if (setup && (size > 0)) {
										identifier := StrLower(getMultiMapValue(info, "Setup", "Identifier"))

										try {
											if (connector.CountData("Document", "Identifier = '" . identifier . "'") = 0)
												connector.CreateData("Document"
																   , substituteVariables("Type=Setup`n"
																					   . "Identifier=%Identifier%`nDriver=%Driver%`n"
																					   . "Simulator=%Simulator%`nCar=%Car%`nTrack=%Track%"
																					   , {Identifier: identifier
																						, Driver: getMultiMapValue(info, "Origin", "Driver")
																						, Simulator: simulator, Car: car, Track: track}))

											counter += 1

											connector.SetDataValue("Document", identifier, "Setup", encodeB16(setup, size))

											setMultiMapValue(info, "Setup", "Synchronized", true)
											setMultiMapValue(info, "Setup", "Encoded", true)

											connector.SetDataValue("Document", identifier, "Info", printMultiMap(info))

											sessionDB.writeSetupInfo(simulator, car, track
																   , getMultiMapValue(info, "Setup", "Type")
																   , getMultiMapValue(info, "Setup", "Name")
																   , info)
										}
										catch Any as exception {
											logError(exception)

											hasError := true
										}
									}
								}
							}
						}
				}
			}
		}

		if !hasError {
			info := readMultiMap(kDatabaseDirectory . "SYNCHRONIZE")

			setMultiMapValue(info, "Setups", "Synchronization", start)

			writeMultiMap(kDatabaseDirectory . "SYNCHRONIZE", info)
		}
	}
}

synchronizeTelemetries(groups, sessionDB, connector, simulators, timestamp, lastSynchronization, force, &counter) {
	local hasError := false
	local start, lastRun, ignore, identifier, document, name, type, info, simulator, car, track, telemetry
	local directory, extension

	if inList(groups, "Laps") {
		lastRun := getMultiMapValue(readMultiMap(kDatabaseDirectory . "SYNCHRONIZE"), "Laps", "Synchronization", "")
		start := A_Now

		try {
			for ignore, identifier in string2Values(";", connector.QueryData("Document", "Type = 'Telemetry' And Modified > " . lastSynchronization)) {
				document := parseData(connector.GetData("Document", identifier))

				simulator := document["Simulator"]

				if inList(simulators, sessionDB.getSimulatorName(simulator)) {
					info := parseMultiMap(connector.GetDataValue("Document", identifier, "Info"))

					car := document["Car"]
					track := document["Track"]

					if !sessionDB.readTelemetryInfo(simulator, car, track, getMultiMapValue(info, "Telemetry", "Name")) {
						telemetry := connector.GetDataValue("Document", identifier, "Telemetry")

						counter += 1

						sessionDB.writeTelemetry(simulator, car, track
											   , getMultiMapValue(info, "Telemetry", "Name")
											   , getMultiMapValue(info, "Telemetry", "Encoded") ? decodeB16(telemetry) : telemetry
											   , getMultiMapValue(info, "Telemetry", "Size")
											   , getMultiMapValue(info, "Access", "Share")
											   , getMultiMapValue(info, "Access", "Synchronize")
											   , getMultiMapValue(info, "Origin", "Driver")
											   , identifier, true)
					}
				}
			}

			for ignore, simulator in simulators {
				simulator := sessionDB.getSimulatorCode(simulator)

				loop Files, kDatabaseDirectory . "User\" . simulator . "\*.*", "D" {
					car := A_LoopFileName

					loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\*.*", "D" {
						track := A_LoopFileName

						loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Lap Telemetries\*.info", "F" {
							lastModified := FileGetTime(A_LoopFilePath, "M")

							if (StrCompare(lastModified, lastRun) > 0) {
								info := readMultiMap(A_LoopFilePath)

								if ((getMultiMapValue(info, "Origin", "Driver", false) = sessionDB.ID)
								 && getMultiMapValue(info, "Access", "Synchronize", false)
								 && !getMultiMapValue(info, "Telemetry", "Synchronized", false)) {
									telemetry := sessionDB.readTelemetry(simulator, car, track
																	   , getMultiMapValue(info, "Telemetry", "Name")
																	   , &size)
									info := sessionDB.readTelemetryInfo(simulator, car, track
																	  , getMultiMapValue(info, "Telemetry", "Name"))

									if (telemetry && (size > 0)) {
										identifier := StrLower(getMultiMapValue(info, "Telemetry", "Identifier"))

										try {
											if (connector.CountData("Document", "Identifier = '" . identifier . "'") = 0)
												connector.CreateData("Document"
																   , substituteVariables("Type=Telemetry`n"
																					   . "Identifier=%Identifier%`nDriver=%Driver%`n"
																					   . "Simulator=%Simulator%`nCar=%Car%`nTrack=%Track%"
																					   , {Identifier: identifier
																						, Driver: getMultiMapValue(info, "Origin", "Driver")
																						, Simulator: simulator, Car: car, Track: track}))

											counter += 1

											connector.SetDataValue("Document", identifier, "Telemetry", encodeB16(telemetry, size))

											setMultiMapValue(info, "Telemetry", "Synchronized", true)
											setMultiMapValue(info, "Telemetry", "Encoded", true)

											connector.SetDataValue("Document", identifier, "Info", printMultiMap(info))

											sessionDB.writeTelemetryInfo(simulator, car, track, getMultiMapValue(info, "Telemetry", "Name"), info)
										}
										catch Any as exception {
											logError(exception)

											hasError := true
										}
									}
								}
							}
						}
					}
				}
			}
		}

		if !hasError {
			info := readMultiMap(kDatabaseDirectory . "SYNCHRONIZE")

			setMultiMapValue(info, "Laps", "Synchronization", start)

			writeMultiMap(kDatabaseDirectory . "SYNCHRONIZE", info)
		}
	}
}

synchronizeStrategies(groups, sessionDB, connector, simulators, timestamp, lastSynchronization, force, &counter) {
	local hasError := false
	local start, lastRun, ignore, identifier, document, name, type, info, simulator, car, track, strategy
	local directory, extension

	if inList(groups, "Strategies") {
		lastRun := getMultiMapValue(readMultiMap(kDatabaseDirectory . "SYNCHRONIZE"), "Strategies", "Synchronization", "")
		start := A_Now

		try {
			for ignore, identifier in string2Values(";", connector.QueryData("Document", "Type = 'Strategy' And Modified > " . lastSynchronization)) {
				document := parseData(connector.GetData("Document", identifier))

				simulator := document["Simulator"]

				if inList(simulators, sessionDB.getSimulatorName(simulator)) {
					info := parseMultiMap(connector.GetDataValue("Document", identifier, "Info"))

					car := document["Car"]
					track := document["Track"]

					if !sessionDB.readStrategyInfo(simulator, car, track, getMultiMapValue(info, "Strategy", "Name")) {
						counter += 1

						strategy := parseMultiMap(connector.GetDataValue("Document", identifier, "Strategy"))

						directory := kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Race Strategies\"

						DirCreate(directory)

						name := getMultiMapValue(info, "Strategy", "Name")

						if !InStr(name, ".strategy")
							name .= ".strategy"

						writeMultiMap(directory . name, strategy)

						setMultiMapValue(info, "Strategy", "Synchronized", true)

						writeMultiMap(directory . name . ".info", info)
					}
				}
			}

			for ignore, simulator in simulators {
				simulator := sessionDB.getSimulatorCode(simulator)

				loop Files, kDatabaseDirectory . "User\" . simulator . "\*.*", "D" {
					car := A_LoopFileName

					loop Files, kDatabaseDirectory . "User\" . simulator . "\" . car . "\*.*", "D" {
						track := A_LoopFileName

						directory := kDatabaseDirectory . "User\" . simulator . "\" . car . "\" . track . "\Race Strategies\"

						loop Files, directory . "*.strategy", "F"
							if !FileExist(directory . A_LoopFileName . ".info")
								sessionDB.readStrategyInfo(simulator, car, track, A_LoopFileName)

						loop Files, directory . "*.info", "F" {
							lastModified := FileGetTime(A_LoopFilePath, "M")

							if (StrCompare(lastModified, lastRun) > 0) {
								SplitPath(A_LoopFileName, , , , &name)

								info := sessionDB.readStrategyInfo(simulator, car, track, name)

								if ((getMultiMapValue(info, "Origin", "Driver", false) = sessionDB.ID)
								 && getMultiMapValue(info, "Access", "Synchronize", false)
								 && !getMultiMapValue(info, "Strategy", "Synchronized", false)) {
									strategy := readMultiMap(directory . getMultiMapValue(info, "Strategy", "Name"))

									if (strategy.Count > 0) {
										identifier := StrLower(getMultiMapValue(info, "Strategy", "Identifier", false))

										try {
											if (connector.CountData("Document", "Identifier = '" . identifier . "'") = 0)
												connector.CreateData("Document"
																   , substituteVariables("Type=Strategy`n"
																					   . "Identifier=%Identifier%`nDriver=%Driver%`n"
																					   . "Simulator=%Simulator%`nCar=%Car%`nTrack=%Track%"
																					   , {Identifier: identifier
																						, Driver: getMultiMapValue(info, "Access", "Driver")
																						, Simulator: simulator, Car: car, Track: track}))


											counter += 1

											connector.SetDataValue("Document", identifier, "Strategy", printMultiMap(strategy))

											setMultiMapValue(info, "Strategy", "Synchronized", true)

											connector.SetDataValue("Document", identifier, "Info", printMultiMap(info))

											sessionDB.writeStrategyInfo(simulator, car, track, name, info)
										}
										catch Any as exception {
											logError(exception)

											hasError := true
										}
									}
								}
							}
						}
					}
				}
			}
		}

		if !hasError {
			info := readMultiMap(kDatabaseDirectory . "SYNCHRONIZE")

			setMultiMapValue(info, "Strategies", "Synchronization", start)

			writeMultiMap(kDatabaseDirectory . "SYNCHRONIZE", info)
		}
	}
}

keepAlive(identifier, connector, connection) {
	try {
		if !connection {
			connection := connector.Connect(SessionDatabase.ServerToken[identifier], SessionDatabase.ID, SessionDatabase.getUserName())

			if (connection && (connection != "")) {
				Task.CurrentTask.stop()

				PeriodicTask(keepAlive.Bind(identifier, connector, connection), 10000, kInterruptPriority).start()
			}
		}

		SessionDatabase.Connected[identifier] := connector.KeepAlive(connection)
	}
	catch Any as exception {
		SessionDatabase.Connected[identifier] := false

		Task.CurrentTask.stop()

		PeriodicTask(keepAlive.Bind(identifier, connector, false), 10000, kInterruptPriority).start()
	}
}

initializeSessionDatabase() {
	SessionDatabase()

	SessionDatabase.registerSynchronizer(synchronizeDrivers)
	SessionDatabase.registerSynchronizer(synchronizeSessions)
	SessionDatabase.registerSynchronizer(synchronizeTelemetries)
	SessionDatabase.registerSynchronizer(synchronizeSetups)
	SessionDatabase.registerSynchronizer(synchronizeStrategies)
}


;;;-------------------------------------------------------------------------;;;
;;;                           Initialization Section                        ;;;
;;;-------------------------------------------------------------------------;;;

initializeSessionDatabase()