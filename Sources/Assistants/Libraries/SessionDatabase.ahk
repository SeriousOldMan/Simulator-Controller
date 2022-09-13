;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Session Database                ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Assistants\Libraries\SettingsDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kWeatherConditions := ["Dry", "Drizzle", "LightRain", "MediumRain", "HeavyRain", "Thunderstorm"]

global kTyreCompounds := ["Wet", "Intermediate", "Dry"
					   , "Wet (S)", "Wet (M)", "Wet (H)"
					   , "Intermediate (S)", "Intermediate (M)", "Intermediate (H)"
					   , "Dry (S+)", "Dry (S)", "Dry (M)", "Dry (H)", "Dry (H+)"
					   , "Dry (Red)", "Dry (Yellow)", "Dry (White)", "Dry (Green)", "Dry (Blue)"]

global kDryQualificationSetup := "DQ"
global kDryRaceSetup := "DR"
global kWetQualificationSetup := "WQ"
global kWetRaceSetup := "WR"

global kSetupTypes := [kDryQualificationSetup, kDryRaceSetup, kWetQualificationSetup, kWetRaceSetup]

global kSessionSchemas := {Drivers: ["ID", "Forname", "Surname", "Nickname"]}


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SessionDatabase extends ConfigurationItem {
	static sCarData := {}
	static sTrackData := {}
	static sTyreData := {}

	static sID := false

	iControllerConfiguration := false

	iUseCommunity := false

	ID[] {
		Get {
			return this.sID
		}
	}

	DatabaseID[] {
		Get {
			local id

			try {
				FileRead id, %kDatabaseDirectory%ID

				return id
			}
			catch exception {
				return this.ID
			}
		}
	}

	DatabasePath[] {
		Get {
			return kDatabaseDirectory
		}

		Set {
			local configuration := readConfiguration(kUserConfigDirectory . "Session Database.ini")

			setConfigurationValue(configuration, "Database", "Path", value)
			setConfigurationValue(this.Configuration, "Database", "Path", value)

			writeConfiguration(kUserConfigDirectory . "Session Database.ini", configuration)

			return (kDatabaseDirectory := value)
		}
	}

	DatabaseVersion[] {
		Get {
			return getConfigurationValue(readConfiguration(kUserConfigDirectory . "Session Database.ini")
									   , "Database", "Version", false)
		}

		Set {
			local configuration := readConfiguration(kUserConfigDirectory . "Session Database.ini")

			setConfigurationValue(configuration, "Database", "Version", value)

			writeConfiguration(kUserConfigDirectory . "Session Database.ini", configuration)

			return value
		}
	}

	ControllerConfiguration[] {
		Get {
			return this.iControllerConfiguration
		}
	}

	UseCommunity[persistent := true] {
		Get {
			return this.iUseCommunity
		}

		Set {
			local configuration

			if persistent {
				configuration := readConfiguration(kUserConfigDirectory . "Session Database.ini")

				setConfigurationValue(configuration, "Scope", "Community", value)

				writeConfiguration(kUserConfigDirectory . "Session Database.ini", configuration)
			}

			return (this.iUseCommunity := value)
		}
	}

	__New(controllerConfiguration := false) {
		local identifier

		base.__New(readConfiguration(kUserConfigDirectory . "Session Database.ini"))

		if !this.ID {
			FileRead identifier, % kUserConfigDirectory . "ID"

			SessionDatabase.sID := identifier
		}

		if !controllerConfiguration {
			controllerConfiguration := getControllerConfiguration()

			if !controllerConfiguration
				controllerConfiguration := {}
		}

		this.iControllerConfiguration := controllerConfiguration
	}

	loadFromConfiguration(configuration) {
		this.iUseCommunity := getConfigurationValue(configuration, "Scope", "Community", false)
	}

	prepareDatabase(simulator, car, track, data := false) {
		local simulatorCode, prefix, carName

		if (simulator && car && track) {
			simulatorCode := this.getSimulatorCode(simulator)
			car := this.getCarCode(simulator, car)

			if (simulatorCode && (car != true) && (track != true)) {
				prefix := (kDatabaseDirectory . "User\" . simulatorCode . "\")

				if ((simulatorCode = "RF2") && data) {
					carName := getConfigurationValue(data, "Session Data", "CarName")

					if (car != carName) {
						if FileExist(prefix . carName . "\" . track) {
							try {
								if FileExist(prefix . car . "\" . track)
									FileMoveDir %prefix%%carName%, %prefix%%car%, 2
								else
									FileMoveDir %prefix%%carName%, %prefix%%car%, R
							}
							catch exception {
								logError(exception)
							}

							return
						}

						if (InStr(carName, "#") > 1) {
							carName := string2Values("#", carName)[1]

							if ((car != carName) && FileExist(prefix . carName . "\" . track)) {
								try {
									if FileExist(prefix . car . "\" . track)
										FileMoveDir %prefix%%carName%, %prefix%%car%, 2
									else
										FileMoveDir %prefix%%carName%, %prefix%%car%, R
								}
								catch exception {
									logError(exception)
								}

								return
							}
						}
					}
				}

				FileCreateDir %prefix%%car%\%track%
			}
		}
	}

	getAllDrivers(simulator, names := false) {
		local sessionDB, ids, index, row, ignore, id

		if simulator {
			sessionDB := new Database(kDatabaseDirectory . "User\" . this.getSimulatorCode(simulator) . "\", kSessionSchemas)

			ids := sessionDB.query("Drivers", {Select: ["ID"], By: "ID"})

			for index, row in ids
				ids[index] := row.ID

			if names {
				names := []

				for ignore, id in ids
					names.Push(this.getDriverNames(simulator, id))

				return names
			}
			else
				return ids
		}
		else
			return []
	}

	registerDriver(simulator, id, name) {
		local sessionDB, forName, surName, nickName

		if (simulator && id && name && (name != "John Doe (JD)")) {
			sessionDB := new Database(kDatabaseDirectory . "User\" . this.getSimulatorCode(simulator) . "\", kSessionSchemas)

			forName := false
			surName := false
			nickName := false

			parseDriverName(name, forName, surName, nickName)

			if (sessionDB.query("Drivers", {Where: {ID: id, Forname: forName, Surname: surName}}).Length() = 0)
				sessionDB.add("Drivers", {ID: id, Forname: forName, Surname: surName, Nickname: nickName}, true)
		}
	}

	getDriverID(simulator, name) {
		local ids := this.getDriverIDs(simulator, name)

		return ((ids.Length() > 0) ? ids[1] : false)
	}

	getDriverName(simulator, id) {
		return this.getDriverNames(simulator, id)[1]
	}

	getDriverIDs(simulator, name) {
		local sessionDB, forName, surName, nickName, ids, ignore, entry

		if (simulator && name) {
			forName := false
			surName := false
			nickName := false

			parseDriverName(name, forName, surName, nickName)

			sessionDB := new Database(kDatabaseDirectory . "User\" . this.getSimulatorCode(simulator) . "\", kSessionSchemas)

			ids := []

			for ignore, entry in sessionDB.query("Drivers", {Where: {Forname: forName, Surname: surName}})
				ids.Push(entry.ID)

			return ids
		}
		else
			return false
	}

	getDriverNames(simulator, id) {
		local sessionDB, drivers, ignore, driver

		if (simulator && id) {
			sessionDB := new Database(kDatabaseDirectory . "User\" . this.getSimulatorCode(simulator) . "\", kSessionSchemas)

			drivers := []

			for ignore, driver in sessionDB.query("Drivers", {Where: {ID: id}})
				drivers.Push(computeDriverName(driver.Forname, driver.Surname, driver.Nickname))

			return ((drivers.Length() = 0) ? ["John Doe (JD)"] : drivers)
		}
		else
			return ["John Doe (JD)"]
	}

	hasTrackMap(simulator, track) {
		local prefix := (kDatabaseDirectory . "User\Tracks\" . this.getSimulatorCode(simulator) . "\" . this.getTrackCode(simulator, track))

		return (FileExist(prefix . ".map") && this.getTrackImage(simulator, track))
	}

	availableTrackMaps(simulator) {
		local sessionDB := new SessionDatabase()
		local code := sessionDB.getSimulatorCode(simulator)
		local tracks := []
		local track

		loop Files, %kDatabaseDirectory%User\Tracks\%code%\*.map, F		; Track
		{
			SplitPath A_LoopFileName, , , , track

			tracks.Push(track)
		}

		return tracks
	}

	availableTrackImages(simulator) {
		local sessionDB := new SessionDatabase()
		local code := sessionDB.getSimulatorCode(simulator)
		local directory := (kDatabaseDirectory . "User\Tracks\" . code . "\")
		local tracks := []
		local track

		loop Files, %directory%*.map, F		; Track
		{
			SplitPath A_LoopFileName, , , , track

			if (FileExist(directory . track . ".png") || FileExist(directory . track . ".jpg")
													  || FileExist(directory . track . ".gif"))
				tracks.Push(track)
		}

		return tracks
	}

	updateTrackMap(simulator, track, map, imageFileName, dataFileName := false) {
		local prefix := (kDatabaseDirectory . "User\Tracks\" . this.getSimulatorCode(simulator) . "\" . this.getTrackCode(simulator, track))
		local extension

		writeConfiguration(prefix . ".map", map)

		SplitPath imageFileName, , , extension

		FileCopy %imageFileName%, %prefix%.%extension%, 1

		if dataFileName
			FileCopy %dataFileName%, %prefix%.data, 1
	}

	getTrackMap(simulator, track) {
		local fileName := (kDatabaseDirectory . "User\Tracks\" . this.getSimulatorCode(simulator) . "\" . this.getTrackCode(simulator, track) . ".map")

		if FileExist(fileName)
			return readConfiguration(fileName)
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
			return (fileName)
		else
			return false
	}

	hasTrackAutomations(simulator, car, track) {
		local code := this.getSimulatorCode(simulator)

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		return FileExist(kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Track.automations")
	}

	getTrackAutomations(simulator, car, track) {
		local code := this.getSimulatorCode(simulator)

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		return this.loadTrackAutomations(kDatabaseDirectory . "User\" . code . "\" . car . "\" . track . "\Track.automations")
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

		if !IsObject(data)
			data := readConfiguration(data)

		loop % getConfigurationValue(data, "Automations", "Count", 0)
		{
			id := A_Index

			actions := []

			loop % getConfigurationValue(data, "Automations", id . ".Actions", 0)
				actions.Push({X: getConfigurationValue(data, "Actions", id . "." . A_Index . ".X", 0)
							, Y: getConfigurationValue(data, "Actions", id . "." . A_Index . ".Y", 0)
							, Type: getConfigurationValue(data, "Actions", id . "." . A_Index . ".Type", 0)
							, Action: getConfigurationValue(data, "Actions", id . "." . A_Index . ".Action", 0)})

			result.Push({Name: getConfigurationValue(data, "Automations", id . ".Name", "")
					   , Active: getConfigurationValue(data, "Automations", id . ".Active", false)
					   , Actions: actions})
		}

		return result
	}

	saveTrackAutomations(trackAutomations, fileName := false) {
		local data := newConfiguration()
		local id, trackAutomation, ignore, trackAction

		for id, trackAutomation in trackAutomations {
			setConfigurationValue(data, "Automations", id . ".Name", trackAutomation.Name)
			setConfigurationValue(data, "Automations", id . ".Active", trackAutomation.Active)
			setConfigurationValue(data, "Automations", id . ".Actions", trackAutomation.Actions.Length())

			for ignore, trackAction in trackAutomation.Actions {
				setConfigurationValue(data, "Actions", id . "." . A_Index . ".X", trackAction.X)
				setConfigurationValue(data, "Actions", id . "." . A_Index . ".Y", trackAction.Y)
				setConfigurationValue(data, "Actions", id . "." . A_Index . ".Type", trackAction.Type)
				setConfigurationValue(data, "Actions", id . "." . A_Index . ".Action", trackAction.Action)
			}
		}

		setConfigurationValue(data, "Automations", "Count", trackAutomations.Length())

		if fileName
			writeConfiguration(fileName, data)

		return data
	}

	getEntries(filter := "*.*", option := "D") {
		local result := []

		loop Files, %kDatabaseDirectory%User\%filter%, %option%
			if ((A_LoopFileName != "1") && (InStr(A_LoopFileName, ".") != 1))
				result.Push(A_LoopFileName)

		if this.UseCommunity
			loop Files, %kDatabaseDirectory%Community\%filter%, %option%
				if ((A_LoopFileName != "1") && (InStr(A_LoopFileName, ".") != 1) && !inList(result, A_LoopFileName))
					result.Push(A_LoopFileName)

		return result
	}

	getSimulatorName(simulatorCode) {
		local name, description, code

		if (simulatorCode = "Unknown")
			return "Unknown"
		else if (this.ControllerConfiguration.Count() > 0) {
			for name, description in getConfigurationSectionValues(this.ControllerConfiguration, "Simulators", Object())
				if ((simulatorCode = name) || (simulatorCode = string2Values("|", description)[1]))
					return name

			return false
		}
		else {
			for name, code in {"Assetto Corsa": "AC", "Assetto Corsa Competizione": "ACC", "Automobilista 2": "AMS2"
							 , "iRacing": "IRC", "RaceRoom Racing Experience": "R3E", "rFactor 2": "RF2", "Project CARS 2": "PCARS2"}
				if ((simulatorCode = name) || (simulatorCode = code))
					return name

			return false
		}
	}

	getSimulatorCode(simulatorName) {
		local code, ignore, description, name

		if (simulatorName = "Unknown")
			return "Unknown"
		else {
			code := getConfigurationValue(this.ControllerConfiguration, "Simulators", simulatorName, false)

			if code
				return string2Values("|", code)[1]
			else {
				for ignore, description in getConfigurationSectionValues(this.ControllerConfiguration, "Simulators", Object())
					if (simulatorName = string2Values("|", description)[1])
						return simulatorName

				for name, code in {"Assetto Corsa": "AC", "Assetto Corsa Competizione": "ACC", "Automobilista 2": "AMS2"
								 , "iRacing": "IRC", "RaceRoom Racing Experience": "R3E", "rFactor 2": "RF2", "Project CARS 2": "PCARS2"}
					if ((simulatorName = name) || (simulatorName = code))
						return code

				return false
			}
		}
	}

	getSimulators() {
		local configuredSimulators := string2Values("|", getConfigurationValue(kSimulatorConfiguration, "Configuration"
																									  , "Simulators", ""))
		local controllerSimulators := getKeys(getConfigurationSectionValues(this.ControllerConfiguration, "Simulators", Object()))
		local simulators := []
		local simulator, ignore, name, code

		for ignore, simulator in configuredSimulators
			if inList(controllerSimulators, simulator)
				simulators.Push(simulator)

		for ignore, simulator in controllerSimulators
			if !inList(simulators, simulator)
				simulators.Push(simulator)

		if (simulators.Length() = 0)
			for name, code in {"Assetto Corsa": "AC", "Assetto Corsa Competizione": "ACC", "Automobilista 2": "AMS2"
							 , "iRacing": "IRC", "RaceRoom Racing Experience": "R3E", "rFactor 2": "RF2", "Project CARS 2": "PCARS2"}
				if FileExist(kDatabaseDirectory . "User\" . code)
					simulators.Push(name)

		return simulators
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

			return ((tracks.Length() > 0) ? tracks : this.getEntries(code . "\" . this.getCarCode(simulator, car) . "\*.*"))
		}
		else
			return []
	}

	loadData(cache, simulator, fileName) {
		local name, data, section, values, key, value

		if cache.HasKey(simulator)
			return cache[simulator]
		else {
			name := (kResourcesDirectory . "Simulator Data\" . simulator . "\" . fileName)

			if FileExist(name)
				data := readConfiguration(name)
			else
				data := newConfiguration()

			name := (kUserHomeDirectory . "Simulator Data\" . simulator . "\" . fileName)

			if FileExist(name)
				for section, values in readConfiguration(name)
					for key, value in values
						setConfigurationValue(data, section, key, value)

			cache[simulator] := data

			return data
		}
	}

	clearData(cache, simulator) {
		cache.Delete(simulator)
	}

	registerCar(simulator, car, name) {
		local fileName := (kUserHomeDirectory . "Simulator Data\" . this.getSimulatorCode(simulator) . "\" . "Car Data.ini")
		local carData := readConfiguration(fileName)

		if (getConfigurationValue(carData, "Car Names", car, kUndefined) == kUndefined) {
			setConfigurationValue(carData, "Car Names", car, name)
			setConfigurationValue(carData, "Car Codes", name, car)

			writeConfiguration(fileName, carData)

			this.clearCache(this.sCarData, this.getSimulatorCode(simulator))
		}
	}

	getCarName(simulator, car) {
		local name := getConfigurationValue(this.loadData(this.sCarData, this.getSimulatorCode(simulator), "Car Data.ini")
									, "Car Names", car, car)

		if (!name || (name = ""))
			name := car

		return name
	}

	getCarCode(simulator, car) {
		local code := getConfigurationValue(this.loadData(this.sCarData, this.getSimulatorCode(simulator), "Car Data.ini")
										  , "Car Codes", car, car)

		if (!code || (code = ""))
			code := car

		return code
	}

	registerTrack(simulator, track, shortName, longName) {
		local fileName := (kUserHomeDirectory . "Simulator Data\" . this.getSimulatorCode(simulator) . "\" . "Track Data.ini")
		local trackData := readConfiguration(fileName)

		if (getConfigurationValue(trackData, "Track Names Long", track, kUndefined) == kUndefined) {
			setConfigurationValue(trackData, "Track Names Long", track, longName)
			setConfigurationValue(trackData, "Track Names Short", track, shortName)
			setConfigurationValue(trackData, "Track Codes", longName, track)
			setConfigurationValue(trackData, "Track Codes", shortName, track)

			writeConfiguration(fileName, trackData)

			this.clearCache(this.sTrackData, this.getSimulatorCode(simulator))
		}
	}

	getTrackName(simulator, track, long := true) {
		local name := getConfigurationValue(this.loadData(this.sTrackData, this.getSimulatorCode(simulator), "Track Data.ini")
										  , long ? "Track Names Long" : "Track Names Short", track, track)

		if (!name || (name = ""))
			name := track

		return name
	}

	getTrackCode(simulator, track) {
		local code := getConfigurationValue(this.loadData(this.sTrackData, this.getSimulatorCode(simulator), "Track Data.ini")
										  , "Track Codes", track, track)

		if (!code || (code = ""))
			code := track

		return code
	}

	getTyreCompounds(simulator, car, track, codes := false) {
		local code, cache, key, compounds, data, cds, nms, ignore, compound, candidate

		static settingsDB := false
		static sNames := {}
		static sCodes := {}

		car := this.getCarCode(simulator, car)

		code := this.getSimulatorCode(simulator)
		cache := (codes ? sCodes : sNames)
		key := (code . "." . car . "." . track)

		if cache.HasKey(key)
			return cache[key]
		else {
			if !settingsDB
				settingsDB := new SettingsDatabase()

			compounds := settingsDB.readSettingValue(simulator, car, track, "*"
												   , "Session Settings", "Tyre.Compound.Choices"
												   , kUndefined)
			data := this.loadData(this.sTyreData, code, "Tyre Data.ini")

			if (compounds == kUndefined) {
				compounds := getConfigurationValue(data, "Cars", car . ";" . track, kUndefined)

				if (compounds == kUndefined)
					compounds := getConfigurationValue(data, "Cars", car . ";*", kUndefined)

				if (compounds == kUndefined)
					compounds := getConfigurationValue(data, "Cars", "*;" . track, kUndefined)

				if (compounds == kUndefined)
					compounds := getConfigurationValue(data, "Cars", "*;*", kUndefined)
			}

			if (compounds == kUndefined) {
				if (code = "ACC")
					compounds := "Dry->Dry;Wet->Wet"
				else
					compounds := "*->Dry"
			}
			else {
				candidate := getConfigurationValue(data, "Compounds", compounds, false)

				if candidate
					compounds := candidate
			}

			cds := []
			nms := []

			for ignore, compound in string2Values(";", compounds) {
				compound := string2Values("->", compound)

				cds.Push(compound[1])
				nms.Push(compound[2])
			}

			if codes
				compounds := cds
			else
				compounds := nms

			cache[key] := compounds

			return compounds
		}
	}

	getTyreCompoundName(simulator, car, track, compound, default := "__Undefined__") {
		local index, code

		for index, code in this.getTyreCompounds(simulator, car, track, true)
			if (code = compound)
				return this.getTyreCompounds(simulator, car, track)[index]

		return ((default = kUndefined) ? compound : default)
	}

	getTyreCompoundCode(simulator, car, track, compound, default := "Dry") {
		local index, name, code

		for index, name in this.getTyreCompounds(simulator, car, track)
			if (name = compound) {
				code := this.getTyreCompounds(simulator, car, track, true)[index]

				return ((code != "*") ? code : false)
			}

		return default
	}

	suitableTyreCompound(simulator, car, track, weather, compound) {
		local compoundColor := compoundColor(compound)

		compound := compound(compound)

		if (weather = "Dry") {
			if (compound = "Dry")
				return true
		}
		else if (weather = "Drizzle") {
			if inList(["Dry", "Intermediate"], compound)
				return true
		}
		else if (weather = "LightRain") {
			if inList(["Intermediate", "Wet"], compound)
				return true
		}
		else if (compound = "Wet")
			return true

		return false
	}

	optimalTyreCompound(simulator, car, track, weather, airTemeperature, trackTemperature, availableTyreCompounds := false) {
		local compounds, compound, index

		if !availableTyreCompounds
			availableTyreCompounds := this.getTyreCompounds(simulator, car, track)

		compounds := map(availableTyreCompounds, "compound")

		switch weather {
			case "Dry":
				compound := "Dry"
			case "Drizzle", "LightRain":
				compound := "Intermediate"
			default:
				compound := "Wet"
		}

		index := inList(compounds, compound)

		if index
			return availableTyreCompounds[index]
		else if ((compound = "Intermediate") && (weather = "Drizzle")) {
			index := inList(compounds, "Dry")

			if index
				return availableTyreCompounds[index]
		}
		else if ((compound = "Intermediate") && (weather = "LightRain")) {
			index := inList(compounds, "Wet")

			if index
				return availableTyreCompounds[index]
		}
		else {
			index := inList(compounds, "Dry")

			if index
				return availableTyreCompounds[index]
		}

		return false
	}

	readNotes(simulator, car, track) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local notes

		car := this.getCarCode(simulator, car)

		try {
			if (track && (track != true))
				FileRead notes, %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Notes.txt
			else if (car && (car != true))
				FileRead notes, %kDatabaseDirectory%User\%simulatorCode%\%car%\Notes.txt
			else
				FileRead notes, %kDatabaseDirectory%User\%simulatorCode%\Notes.txt

			return notes
		}
		catch exception {
			return ""
		}
	}

	writeNotes(simulator, car, track, notes) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local fileName

		car := this.getCarCode(simulator, car)

		if (car && (car != true)) {
			if (track && (track != true))
				fileName = %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Notes.txt)
			else
				fileName = %kDatabaseDirectory%User\%simulatorCode%\%car%\Notes.txt
		}
		else
			fileName = %kDatabaseDirectory%User\%simulatorCode%\Notes.txt

		deleteFile(fileName)

		if (car && (car != true)) {
			if (track && (track != true)) {
				FileCreateDir %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%

				FileAppend %notes%, %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Notes.txt, UTF-16
			}
			else {
				FileCreateDir %kDatabaseDirectory%User\%simulatorCode%\%car%

				FileAppend %notes%, %kDatabaseDirectory%User\%simulatorCode%\%car%\Notes.txt, UTF-16
			}
		}
		else {
			FileCreateDir %kDatabaseDirectory%User\%simulatorCode%

			FileAppend %notes%, %kDatabaseDirectory%User\%simulatorCode%\Notes.txt, UTF-16
		}
	}

	getSetupNames(simulator, car, track, ByRef userSetups, ByRef communitySetups) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local ignore, type, setups, name

		car := this.getCarCode(simulator, car)

		if userSetups {
			userSetups := {}

			for ignore, type in kSetupTypes {
				setups := []

				loop Files, %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\*.*
				{
					SplitPath A_LoopFileName, name

					setups.Push(name)
				}

				userSetups[type] := setups
			}
		}

		if communitySetups {
			communitySetups := {}

			for ignore, type in kSetupTypes {
				setups := []

				loop Files, %kDatabaseDirectory%Community\%simulatorCode%\%car%\%track%\Car Setups\%type%\*.*
				{
					SplitPath A_LoopFileName, name

					setups.Push(name)
				}

				communitySetups[type] := setups
			}
		}
	}

	readSetup(simulator, car, track, type, name, ByRef size) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local data, fileName, file

		car := this.getCarCode(simulator, car)

		data := false
		fileName = %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\%name%

		if !FileExist(fileName)
			fileName = %kDatabaseDirectory%Community\%simulatorCode%\%car%\%track%\Car Setups\%type%\%name%

		if FileExist(fileName) {
			file := FileOpen(fileName, "r")
			size := file.Length

			file.RawRead(data, size)

			file.Close()

			return data
		}
		else {
			size := 0

			return ""
		}
	}

	writeSetup(simulator, car, track, type, name, setup, size) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local fileName, file

		car := this.getCarCode(simulator, car)

		fileName = %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%

		FileCreateDir %fileName%

		fileName := (fileName . "\" . name)

		deleteFile(fileName)

		file := FileOpen(fileName, "w", "")

		file.RawWrite(setup, size)

		file.Close()
	}

	renameSetup(simulator, car, track, type, oldName, newName) {
		local simulatorCode := this.getSimulatorCode(simulator)

		car := this.getCarCode(simulator, car)

		try {
			FileMove %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\%oldName%, %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\%newName%, 1
		}
		catch exception {
			logError(exception)
		}
	}

	removeSetup(simulator, car, track, type, name) {
		local simulatorCode := this.getSimulatorCode(simulator)
		local fileName

		car := this.getCarCode(simulator, car)

		fileName = %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\%name%

		deleteFile(fileName)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

compound(compound, color := false) {
	if color {
		if (color = "Black")
			return compound
		else
			return (compound . " (" . color . ")")
	}
	else
		return string2Values(A_Space, compound)[1]
}

compoundColor(compound) {
	compound := string2Values(A_Space, compound)

	if (compound.Length() == 1)
		return "Black"
	else
		return SubStr(compound[2], 2, StrLen(compound[2]) - 2)
}

splitCompound(qualifiedCompound, ByRef compound, ByRef compoundColor) {
	compound := compound(qualifiedCompound)
	compoundColor := compoundColor(qualifiedCompound)
}

parseDriverName(fullName, ByRef forName, ByRef surName, ByRef nickName) {
	if InStr(fullName, "(") {
		fullname := StrSplit(fullName, "(", " `t", 2)

		nickName := Trim(StrReplace(fullName[2], ")", ""))
		fullName := fullName[1]
	}
	else
		nickName := ""

	fullName := StrSplit(fullName, A_Space, " `t", 2)

	forName := fullName[1]
	surName := ((fullName.Length() > 1) ? fullName[2] : "")
}

computeDriverName(forName, surName, nickName) {
	local name := ""

	if (forName != "")
		name .= (forName . A_Space)

	if (surName != "")
		name .= (surName . A_Space)

	if (nickName != "")
		name .= (translate("(") . nickName . translate(")"))

	return Trim(name)
}