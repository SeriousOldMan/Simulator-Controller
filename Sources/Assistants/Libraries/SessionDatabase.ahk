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
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kWeatherOptions = ["Dry", "Drizzle", "LightRain", "MediumRain", "HeavyRain", "Thunderstorm"]

global kTyreCompounds = ["Dry", "Intermediate", "Wet"]
global kTyreCompoundColors = ["Black", "Red", "Yellow", "White", "Green", "Blue", "Soft", "Medium", "Hard"]

global kQualifiedTyreCompounds = ["Wet", "Intermediate", "Dry", "Dry (Red)", "Dry (Yellow)", "Dry (White)", "Dry (Green)", "Dry (Blue)", "Dry (Soft)", "Dry (Medium)", "Dry (Hard)"]
global kQualifiedTyreCompoundColors = ["Black", "Black", "Black", "Red", "Yellow", "White", "Green", "Blue", "Soft", "Medium", "Hard"]

global kDryQualificationSetup = "DQ"
global kDryRaceSetup = "DR"
global kWetQualificationSetup = "WQ"
global kWetRaceSetup = "WR"

global kSetupTypes = [kDryQualificationSetup, kDryRaceSetup, kWetQualificationSetup, kWetRaceSetup]

global kSessionSchemas = {Drivers: ["ID", "Forname", "Surname", "Nickname"]}


;;;-------------------------------------------------------------------------;;;
;;;                         Private Variables Section                       ;;;
;;;-------------------------------------------------------------------------;;;

global vUserID = false


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SessionDatabase extends ConfigurationItem {
	static sDriver := false

	iID := false
	iControllerConfiguration := false

	iUseCommunity := false

	ID[] {
		Get {
			return this.iID
		}
	}

	DBID[] {
		Get {
			try {
				FileRead id, %kDatabaseDirectory%ID

				return id
			}
			catch exception {
				return this.ID
			}
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
			if persistent {
				configuration := readConfiguration(kUserConfigDirectory . "Session Database.ini")

				setConfigurationValue(configuration, "Scope", "Community", value)

				writeConfiguration(kUserConfigDirectory . "Session Database.ini", configuration)
			}

			return (this.iUseCommunity := value)
		}
	}

	__New(controllerConfiguration := false) {
		base.__New(readConfiguration(kUserConfigDirectory . "Session Database.ini"))

		if !vUserID {
			FileRead identifier, % kUserConfigDirectory . "ID"

			vUserID := identifier
		}

		this.iID := vUserID

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

	hasTrackMap(simulator, track) {
		return false
	}

	updateTrackMap(simulator, track, coordinateX, coordinateY) {
		directory := (kDatabaseDirectory . "User\" . this.getSimulatorCode(simulator) . "\Tracks")

		FileCreateDir %directory%

		text := (Round(coordinateX, 3) . "," . Round(coordinateY, 3))

		FileAppend %text%, %directory%\%track%.map
	}

	getAllDrivers(simulator, names := false) {
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
		if (simulator && id && name && (name != "John Doe (JD)")) {
			sessionDB := new Database(kDatabaseDirectory . "User\" . this.getSimulatorCode(simulator) . "\", kSessionSchemas)

			forName := false
			surname := false
			nickName := false

			parseDriverName(name, forName, surName, nickName)

			if (sessionDB.query("Drivers", {Where: {ID: id, Forname: forName, Surname: surName}}).Length() = 0)
				sessionDB.add("Drivers", {ID: id, Forname: forName, Surname: surName, Nickname: nickName}, true)
		}
	}

	getDriverID(simulator, name) {
		ids := this.getDriverIDs(simulator, name)

		return ((ids.Length() > 0) ? ids[1] : false)
	}

	getDriverName(simulator, id) {
		return this.getDriverNames(simulator, id)[1]
	}

	getDriverIDs(simulator, name) {
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

	prepareDatabase(simulator, car, track) {
		if (simulator && car && track) {
			simulatorCode := this.getSimulatorCode(simulator)

			if (simulatorCode && (car != true) && (track != true))
				FileCreateDir %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%
		}
	}

	getEntries(filter := "*.*", option := "D") {
		result := []

		Loop Files, %kDatabaseDirectory%User\%filter%, %option%
			if (A_LoopFileName != "1")
				result.Push(A_LoopFileName)

		if this.UseCommunity
			Loop Files, %kDatabaseDirectory%Community\%filter%, %option%
				if ((A_LoopFileName != "1") && !inList(result, A_LoopFileName))
					result.Push(A_LoopFileName)

		return result
	}

	getSimulatorName(simulatorCode) {
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
							 , "iRacing": "IRC", "RaceRoom Racing Experience": "R3E", "rFactor 2": "RF2", "PCARS2": "Project CARS 2"}
				if ((simulatorCode = name) || (simulatorCode = code))
					return name

			return false
		}
	}

	getSimulatorCode(simulatorName) {
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
								 , "iRacing": "IRC", "RaceRoom Racing Experience": "R3E", "rFactor 2": "RF2", "PCARS2": "Project CARS 2"}
					if ((simulatorName = name) || (simulatorName = code))
						return code

				return false
			}
		}
	}

	getSimulators() {
		simulators := []

		for simulator, ignore in getConfigurationSectionValues(this.ControllerConfiguration, "Simulators", Object())
			simulators.Push(simulator)

		if (simulators.Length() = 0)
			for name, code in {"Assetto Corsa": "AC", "Assetto Corsa Competizione": "ACC", "Automobilista 2": "AMS2"
							 , "iRacing": "IRC", "RaceRoom Racing Experience": "R3E", "rFactor 2": "RF2", "PCARS2": "Project CARS 2"}
				if FileExist(kDatabaseDirectory . "User\" . code)
					simulators.Push(name)

		return simulators
	}

	getCars(simulator) {
		code := this.getSimulatorCode(simulator)

		if code
			return this.getEntries(code . "\*.*")
		else
			return []
	}

	getTracks(simulator, car) {
		code := this.getSimulatorCode(simulator)

		if code {
			tracks := this.getEntries(code . "\" . car . "\*.*")

			return ((tracks.Length() > 0) ? tracks : this.getEntries(code . "\" . this.getCarName(simulator, car) . "\*.*"))
		}
		else
			return []
	}

	getCarName(simulator, car) {
		static accCarNames := false
		static acCarNames := false

		code := this.getSimulatorCode(simulator)

		if (code == "ACC") {
			if !accCarNames
				accCarNames := getConfigurationSectionValues(readConfiguration(kResourcesDirectory . "Simulator Data\ACC\Car Data.ini"), "Car Names")

			carName := (accCarNames.HasKey(car) ? accCarNames[car] : car)
		}
		else if (code == "AC") {
			if !acCarNames
				acCarNames := getConfigurationSectionValues(readConfiguration(kResourcesDirectory . "Simulator Data\AC\Car Data.ini"), "Car Names")

			carName := (acCarNames.HasKey(car) ? acCarNames[car] : car)
		}
		else
			carName := car

		if (carName = "")
			carName := car

		return carName
	}

	getTrackName(simulator, track, long := true) {
		static accTrackNames := false
		static acTrackNames := false

		code := this.getSimulatorCode(simulator)

		if (code == "ACC") {
			if !accTrackNames
				accTrackNames := readConfiguration(kResourcesDirectory . "Simulator Data\ACC\Track Data.ini")

			trackName := getConfigurationValue(accTrackNames, long ? "Track Names Long" : "Track Names Short", track, track)
		}
		else if (code == "AC") {
			if !acTrackNames
				acTrackNames := readConfiguration(kResourcesDirectory . "Simulator Data\AC\Track Data.ini")

			trackName := getConfigurationValue(acTrackNames, long ? "Track Names Long" : "Track Names Short", track, track)
		}
		else
			trackName := track

		if (trackName = "")
			trackName := track

		return trackName
	}

	readNotes(simulator, car, track) {
		simulatorCode := this.getSimulatorCode(simulator)

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
		simulatorCode := this.getSimulatorCode(simulator)

		try {
			if (car && (car != true)) {
				if (track && (track != true))
					FileDelete %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Notes.txt
				else
					FileDelete %kDatabaseDirectory%User\%simulatorCode%\%car%\Notes.txt
			}
			else
				FileDelete %kDatabaseDirectory%User\%simulatorCode%\Notes.txt
		}
		catch exception {
			; ignore
		}

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
		simulatorCode := this.getSimulatorCode(simulator)

		if userSetups {
			userSetups := {}

			for ignore, type in kSetupTypes {
				setups := []

				Loop Files, %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\*.*
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

				Loop Files, %kDatabaseDirectory%Community\%simulatorCode%\%car%\%track%\Car Setups\%type%\*.*
				{
					SplitPath A_LoopFileName, name

					setups.Push(name)
				}

				communitySetups[type] := setups
			}
		}
	}

	readSetup(simulator, car, track, type, name, ByRef size) {
		simulatorCode := this.getSimulatorCode(simulator)

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
		simulatorCode := this.getSimulatorCode(simulator)

		try {
			FileDelete %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\%name%
		}
		catch exception {
			; ignore
		}

		fileName = %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%

		FileCreateDir %fileName%

		fileName := (fileName . "\" . name)

		file := FileOpen(fileName, "w", "")

		file.RawWrite(setup, size)

		file.Close()
	}

	renameSetup(simulator, car, track, type, oldName, newName) {
		simulatorCode := this.getSimulatorCode(simulator)

		try {
			FileMove %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\%oldName%, %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\%newName%, 1
		}
		catch exception {
			; ignore
		}
	}

	removeSetup(simulator, car, track, type, name) {
		simulatorCode := this.getSimulatorCode(simulator)

		try {
			FileDelete %kDatabaseDirectory%User\%simulatorCode%\%car%\%track%\Car Setups\%type%\%name%
		}
		catch exception {
			; ignore
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

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
	surName := fullName[2]
}

computeDriverName(forName, surName, nickName) {
	name := ""

	if (forName != "")
		name .= (forName . A_Space)

	if (surName != "")
		name .= (surName . A_Space)

	if (nickName != "")
		name .= (translate("(") . nickName . translate(")"))

	return Trim(name)
}