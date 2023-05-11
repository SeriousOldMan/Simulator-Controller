;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Settings Database               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Framework.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Database.ahk"
#Include "SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSettingsDataSchemas := CaseInsenseMap("Settings", ["Owner", "Car", "Track", "Weather", "Section", "Key", "Value"])


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SettingsDatabase extends SessionDatabase {
	iLastSimulator := false
	iUserDatabase := false
	iCommunityDatabase := false

	getSettingsDatabase(simulator, type := "User") {
		if (this.iLastSimulator != simulator) {
			this.iLastSimulator := simulator

			this.iUserDatabase := Database(this.DatabasePath . "User\" . this.getSimulatorCode(simulator) . "\", kSettingsDataSchemas)
			this.iCommunityDatabase := Database(this.DatabasePath . "Community\" . this.getSimulatorCode(simulator) . "\", kSettingsDataSchemas)
		}

		return ((type = "User") ? this.iUserDatabase : this.iCommunityDatabase)
	}

	querySettings(simulator, car, track, weather, &userSettings, &communitySettings) {
		local database
		local id := this.ID
		local result, ignore, setting

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		if userSettings {
			result := CaseInsenseMap()

			readSettings(this, simulator, result, id, true, false, "*", "*", "*")
			readSettings(this, simulator, result, id, true, false, car, "*", "*")
			readSettings(this, simulator, result, id, true, false, "*", track, "*")
			readSettings(this, simulator, result, id, true, false, "*", "*", weather)
			readSettings(this, simulator, result, id, true, false, car, track, "*")
			readSettings(this, simulator, result, id, true, false, car, "*", weather)
			readSettings(this, simulator, result, id, true, false, "*", track, weather)
			readSettings(this, simulator, result, id, true, false, car, track, weather)

			userSettings := []

			for ignore, setting in result
				userSettings.Push(setting)
		}

		if communitySettings {
			result := CaseInsenseMap()

			readSettings(this, simulator, result, id, false, true, "*", "*", "*")
			readSettings(this, simulator, result, id, false, true, car, "*", "*")
			readSettings(this, simulator, result, id, false, true, "*", track, "*")
			readSettings(this, simulator, result, id, false, true, "*", "*", weather)
			readSettings(this, simulator, result, id, false, true, car, track, "*")
			readSettings(this, simulator, result, id, false, true, car, "*", weather)
			readSettings(this, simulator, result, id, false, true, "*", track, weather)
			readSettings(this, simulator, result, id, false, true, car, track, weather)

			communitySettings := []

			for ignore, setting in result
				communitySettings.Push(setting)
		}
	}

	doSettings(simulator, car, track, weather, function, userSettings := true, communitySettings := true) {
		local ignore, setting

		this.querySettings(simulator, car, track, weather, &userSettings, &communitySettings)

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		if userSettings
			for ignore, setting in userSettings
				function.Call(simulator, car, track, weather, setting)

		if communitySettings
			for ignore, setting in communitySettings
				function.Call(simulator, car, track, weather, setting)
	}

	loadSettings(simulator, car, track, weather, community := kUndefined) {
		local settings := newMultiMap()
		local id := this.ID
		local dryPressure, wetPressure, ignore, tyre

		if (community = kUndefined)
			community := this.UseCommunity

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		dryPressure := this.optimalTyrePressure(simulator, car, "Dry")
		wetPressure := this.optimalTyrePressure(simulator, car, "Wet")

		if dryPressure
			for ignore, tyre in ["FL", "FR", "RL", "RR"]
				setMultiMapValue(settings, "Session Settings", "Tyre.Dry.Pressure.Target." . tyre, dryPressure)

		if wetPressure
			for ignore, tyre in ["FL", "FR", "RL", "RR"]
				setMultiMapValue(settings, "Session Settings", "Tyre.Wet.Pressure.Target." . tyre, wetPressure)

		loadSettings(this, simulator, settings, id, true, community, "*", "*", "*")
		loadSettings(this, simulator, settings, id, true, community, car, "*", "*")
		loadSettings(this, simulator, settings, id, true, community, "*", track, "*")
		loadSettings(this, simulator, settings, id, true, community, "*", "*", weather)
		loadSettings(this, simulator, settings, id, true, community, car, track, "*")
		loadSettings(this, simulator, settings, id, true, community, car, "*", weather)
		loadSettings(this, simulator, settings, id, true, community, "*", track, weather)
		loadSettings(this, simulator, settings, id, true, community, car, track, weather)

		return settings
	}

	readSettings(simulator, car, track, weather, inherited := true, community := kUndefined) {
		local result := CaseInsenseMap()
		local id := this.ID
		local settings := []
		local ignore, setting

		if (community = kUndefined)
			community := this.UseCommunity

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		if inherited {
			readSettings(this, simulator, result, id, true, community, "*", "*", "*")
			readSettings(this, simulator, result, id, true, community, car, "*", "*")
			readSettings(this, simulator, result, id, true, community, "*", track, "*")
			readSettings(this, simulator, result, id, true, community, "*", "*", weather)
			readSettings(this, simulator, result, id, true, community, car, track, "*")
			readSettings(this, simulator, result, id, true, community, car, "*", weather)
			readSettings(this, simulator, result, id, true, community, "*", track, weather)
		}

		readSettings(this, simulator, result, id, true, community, car, track, weather)

		for ignore, setting in result
			settings.Push(setting)

		return settings
	}

	readSettingValue(simulator, car, track, weather, section, key
				   , default := false, inherited := true, community := kUndefined) {
		local id := this.ID
		local value

		if (community = kUndefined)
			community := this.UseCommunity

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		value := readSetting(this, simulator, id, true, community
						   , car, track, weather, section, key, kUndefined)

		if inherited {
			if (value == kUndefined)
				value := readSetting(this, simulator, id, true, community
								   , "*", track, weather, section, key, kUndefined)

			if (value == kUndefined)
				value := readSetting(this, simulator, id, true, community
								   , car, "*", weather, section, key, kUndefined)

			if (value == kUndefined)
				value := readSetting(this, simulator, id, true, community
								   , car, track, "*", section, key, kUndefined)

			if (value == kUndefined)
				value := readSetting(this, simulator, id, true, community
								   , "*", "*", weather, section, key, kUndefined)

			if (value == kUndefined)
				value := readSetting(this, simulator, id, true, community
								   , "*", track, "*", section, key, kUndefined)

			if (value == kUndefined)
				value := readSetting(this, simulator, id, true, community
								   , car, "*", "*", section, key, kUndefined)

			if (value == kUndefined)
				value := readSetting(this, simulator, id, true, community
								   , "*", "*", "*", section, key, kUndefined)
		}

		return ((value == kUndefined) ? default : value)
	}

	getSettingValue(simulator, car, track, weather, section, key, default := false) {
		local database := this.getSettingsDatabase(simulator, "User")
		local tries := 5
		local rows

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		while (tries-- > 0) {
			if database.lock("Settings", false)
				try {
					rows := database.query("Settings", {Where: {Owner: this.ID
															  , Car: car, Track: track, Weather: weather
															  , Section: section, Key: key}})

					return ((rows.Length > 0) ? rows[1]["Value"] : default)
				}
				catch Any as exception {
					return default
				}
				finally {
					database.unlock("Settings")
				}

			Sleep(200)
		}

		return default
	}

	setSettingValue(simulator, car, track, weather, section, key, value) {
		local database := this.getSettingsDatabase(simulator, "User")
		local tries := 5
		local cValue := value
		local entry

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		while (tries-- > 0) {
			if database.lock("Settings", false)
				try {
					entry := database.query("Settings", {Where: {Owner: this.ID, Car: car, Track: track, Weather: weather, Section: section, Key: key}})

					if (entry.Length > 0) {
						if (entry[1]["Value"] != cValue) {
							entry[1]["Value"] := value

							database.changed("Settings")
						}
					}
					else
						database.add("Settings", {Owner: this.ID, Car: car, Track: track, Weather: weather, Section: section, Key: key, Value: value})

					return
				}
				catch Any as exception {
					return
				}
				finally {
					database.unlock("Settings", true)
				}

			Sleep(200)
		}
	}

	removeSettingValue(simulator, car, track, weather, section, key) {
		local database := this.getSettingsDatabase(simulator, "User")
		local tries := 5

		car := this.getCarCode(simulator, car)
		track := this.getTrackCode(simulator, track)

		while (tries-- > 0) {
			if database.lock("Settings", false)
				try {
					database.remove("Settings", {Owner: this.ID, Car: car, Track: track, Weather: weather, Section: section, Key: key}
											   , always.Bind(true), true)

					return
				}
				catch Any as exception {
					return
				}
				finally {
					database.unlock("Settings", true)
				}

			Sleep(200)
		}
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

constraintSettings(constraints, row) {
	local column, value

	for column, value in constraints
		if (row[column] != value)
			return false

	return true
}

readSetting(database, simulator, owner, user, community, car, track, weather
		  , section, key, default := false) {
	local rows, ignore, row, settingsDB
	local tries := 5

	if user {
		settingsDB := database.getSettingsDatabase(simulator, "User")

		while (tries-- > 0) {
			if settingsDB.lock("Settings", false)
				try {
					rows := settingsDB.query("Settings", {Where: {Car: car, Track: track
																, Weather: weather
																, Section: section, Key: key
																, Owner: owner}})

					if (rows.Length > 0)
						return rows[1]["Value"]
					else
						break
				}
				catch Any {
				}
				finally {
					settingsDB.unlock("Settings")
				}

			Sleep(200)
		}
	}

	if community
		for ignore, row in database.getSettingsDatabase(simulator, "Community").query("Settings"
																					, {Where: {Car: car, Track: track
																							 , Weather: weather
																							 , Section: section, Key: key}})
			if (row["Owner"] != owner)
				return rows[1]["Value"]

	return default
}

readSettings(database, simulator, settings, owner, user, community, car, track, weather) {
	local result := []
	local tries := 5
	local ignore, row, filtered, visited, key
	local settingsDB

	if community
		for ignore, row in database.getSettingsDatabase(simulator, "Community").query("Settings"
																					, {Where: {Car: car, Track: track, Weather: weather}})
			if (row["Owner"] != owner)
				result.Push(row)

	if user {
		settingsDB := database.getSettingsDatabase(simulator, "User")

		while (tries-- > 0) {
			if settingsDB.lock("Settings", false)
				try {
					for ignore, row in settingsDB.query("Settings", {Where: {Car: car, Track: track
																		   , Weather: weather, Owner: owner}})
						result.Push(row)

					break
				}
				catch Any {
				}
				finally {
					settingsDB.unlock("Settings")
				}

			Sleep(200)
		}
	}

	filtered := []

	visited := CaseInsenseMap()

	for ignore, row in reverse(result) {
		key := row["Section"] . "." . row["Key"]

		if !visited.Has(key) {
			visited[key] := true

			filtered.Push(row)
		}
	}

	for ignore, row in reverse(filtered)
		settings[row["Section"] . "." . row["Key"]] := row
}

loadSettings(database, simulator, settings, owner, user, community, car, track, weather) {
	local values := CaseInsenseMap()
	local ignore, setting

	readSettings(database, simulator, values, owner, user, community, car, track, weather)

	for ignore, setting in values
		setMultiMapValue(settings, setting["Section"], setting["Key"], setting["Value"])
}