;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Settings Database               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Includes\Includes.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Local Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Database.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kSettingsDataSchemas := {"Settings": ["ID", "Name", "Owner", "Car", "Track", "Weather", "Section", "Key", "Value"]}


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class SettingsDatabase extends SessionDatabase {
	iLastSimulator := false
	iUserDatabase := false
	iCommunityDatabase := false
	
	iID := false
	
	ID[] {
		Get {
			return this.iID
		}
	}
	
	__New(controllerConfiguration := false) {
		base.__New(controllerConfiguration)
		
		FileRead identifier, % kUserConfigDirectory . "ID"
		
		this.iID := identifier
	}
	
	getSettingsDatabase(simulator, type := "User") {
		if (this.iLastSimulator != simulator) {
			this.iLastSimulator := simulator
			
			this.iUserDatabase := new Database(kDatabaseDirectory . "User\" . this.getSimulatorCode(simulator), kSettingsDataSchemas)
			this.iCommunityDatabase := new Database(kDatabaseDirectory . "Community\" . this.getSimulatorCode(simulator), kSettingsDataSchemas)
		}
		
		return ((type = "User") ? this.iUserDatabase : this.iCommunityDatabase)
	}
	
	querySettings(simulator, car, track, weather, ByRef userSettings, ByRef communitySettings) {
		local database
		
		if userSettings {
			database := this.getSettingsDatabase(simulator, "User")
			userSettings := []
			
			if ((car != true) && (track != true) && (weather != true))
				for ignore, row in database.query("Settings", {Select: ["ID", "Owner", "Name", "Weather"]
															 , Where: {Car: car, Track: track, Weather: weather, Owner: this.ID}})
					userSettings.Push(row)
			
			if ((car != true) && (track != true))
				for ignore, row in database.query("Settings", {Select: ["ID", "Owner", "Name", "Weather"]
															 , Where: {Car: car, Track: track, Weather: "*", Owner: this.ID}})
					userSettings.Push(row)
			
			if (car != true)
				for ignore, row in database.query("Settings", {Select: ["ID", "Owner", "Name", "Weather"]
															 , Where: {Car: car, Track: "*", Weather: "*", Owner: this.ID}})
					userSettings.Push(row)
			
			for ignore, row in database.query("Settings", {Select: ["ID", "Owner", "Name", "Weather"]
														 , Where: {Car: "*", Track: "*", Weather: "*", Owner: this.ID}})
				userSettings.Push(row)
		}
		
		if communitySettings {
			database := this.getSettingsDatabase(simulator, "Community")

			communitySettings := []
			
			if ((car != true) && (track != true) && (weather != true))
				for ignore, row in database.query("Settings", {Select: ["ID", "Owner", "Name", "Weather"]
															 , Where: {Car: car, Track: track, Weather: weather}})
					if row.Owner != this.ID
						communitySettings.Push(row)
			
			if ((car != true) && (track != true))
				for ignore, row in database.query("Settings", {Select: ["ID", "Owner", "Name", "Weather"]
															 , Where: {Car: car, Track: track, Weather: "*"}})
					if row.Owner != this.ID
						communitySettings.Push(row)
			
			if (car != true)
				for ignore, row in database.query("Settings", {Select: ["ID", "Owner", "Name", "Weather"]
															 , Where: {Car: car, Track: "*", Weather: "*"}})
					if row.Owner != this.ID
						communitySettings.Push(row)
			
			for ignore, row in database.query("Settings", {Select: ["ID", "Owner", "Name", "Weather"]
														 , Where: {Car: "*", Track: "*", Owner: this.ID}})
				for ignore, row in database.query("Settings", {Select: ["Name", "Weather", "Owner"], By: ["Name", "Owner"]
															 , Where: {Car: "*", Track: "*", Weather: "*"}})
					if row.Owner != this.ID
						communitySettings.Push(row)
		}
	}
	
	doSettings(simulator, car, track, weather, function, userSettings := true, communitySettings := true) {
		this.querySettings(simulator, car, track, weather, userSettings, communitySettings)
		
		if userSettings
			for ignore, setting in userSettings
				%function%(simulator, car, track, weather, setting.ID, setting.Name, setting.Weather, setting.Owner)
		
		if communitySettings
			for ignore, setting in communitySettings
				%function%(simulator, car, track, weather, setting.ID, setting.Name, setting.Weather, setting.Owner)
	}
	
	loadSettings(simulator, car, track, weather, community := "__Undefined__") {
		if (community = kUndefined)
			community := this.UseCommunity
		
		settings := newConfiguration()
		
		id := this.ID
		
		readSettings(this, simulator, settings, id, community, "*", "*", "*")
		readSettings(this, simulator, settings, id, community, car, "*", "*")
		readSettings(this, simulator, settings, id, community, "*", track, "*")
		readSettings(this, simulator, settings, id, community, "*", "*", weather)
		readSettings(this, simulator, settings, id, community, car, track, "*")
		readSettings(this, simulator, settings, id, community, car, "*", weather)
		readSettings(this, simulator, settings, id, community, "*", track, weather)
		readSettings(this, simulator, settings, id, community, car, track, weather)
		
		return settings
	}
	
	readSettings(simulator, id) {
		local database := this.getSettingsDatabase(simulator, "User")
		
		settings := newConfiguration()
		
		for ignore, row in database.query("Settings", {Where: {ID: id}})
			setConfigurationValue(settings, row.Section, row.Key, row.Value)
		
		return settings
	}
	
	writeSettings(simulator, id, settings) {
		local database := this.getSettingsDatabase(simulator, "User")
		
		data := database.query("Settings", {Select: ["Owner", "Name", "Weather"], Where: {ID: id}})
		
		if (data.Length() > 0) {
			data := data[1]
			
			owner := data.Owner
			name := data.Name
			weather := data.Weather
		}
		else
			Throw "Unknown settings ID encountered in SettingsDatabase.saveSettings..."
		
		database.remove("Settings", Func("constraintSettings").Bind({ID: id}))
		
		for section, values in settings
			for key, value in values
				database.add({ID: id, Owner: owner, Name: Name, Weather: weather, Section: section, Key: key, Value: value})
			
		database.flush()
	}
	
	renameSettings(simulator, id, newName) {
		local database := this.getSettingsDatabase(simulator, "User")
		
		rows := database.query("Settings", {Where: {ID: id}})
		
		for ignore, row in rows
			row.Name := newName
		
		database.remove("Settings", Func("constraintSettings").Bind({ID: id}))
		
		for section, values in rows
			for key, value in values
				database.add({ID: id, Owner: owner, Name: Name, Weather: weather, Section: section, Key: key, Value: value})
			
		database.flush()
	}
	
	removeSettings(simulator, id) {
		local database := this.getSettingsDatabase(simulator, "User")
		
		database.remove("Settings", Func("constraintSettings").Bind({ID: id}), false, true)
		
		for section, values in rows
			for key, value in values
				database.add({ID: id, Owner: owner, Name: Name, Weather: weather, Section: section, Key: key, Value: value})
			
		database.flush()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

constraintSettings(constraints, row) {
	for column, value in constraints
		if (row[column] != value)
			return false
		
	return true
}

readSettings(database, simulator, settings, owner, community, car, track, weather) {
	if community
		for ignore, row in database.getSettingsDatabase(simulator, "Community").query("Settings", {Where: {Car: car, Track: track
																										 , Weather: weather, Owner: owner}})
			if (row.Owner != owner)
				setConfigurationValue(settings, row.Section, row.Key, row.Value)
	
	for ignore, row in database.getSettingsDatabase(simulator, "User").query("Settings", {Where: {Car: car, Track: track
																								, Weather: weather, Owner: owner}})
		setConfigurationValue(settings, row.Section, row.Key, row.Value)
}