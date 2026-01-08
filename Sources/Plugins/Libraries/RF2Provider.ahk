;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RF2 Provider                    ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class Sector397Provider extends SimulatorProvider {
	static Protocols {
		Get {
			local protocols := super.Protocols

			protocols.Connector := {Type: "CLR", Protocol: "SHM"
								  , File: kBinariesDirectory . "Connectors\%simulator% SHM Connector.dll"
								  , Instance: "SHMConnector.SHMConnector"}

			return protocols
		}
	}

	supportsTrackMap() {
		return true
	}

	supportsSetupImport() {
		return true
	}

	parseNr(candidate, &rest) {
		local temp, char

		candidate := Trim(candidate)

		if isNumber(candidate) {
			rest := ""

			return candidate
		}
		else {
			temp := ""

			loop StrLen(candidate) {
				char := SubStr(candidate, A_Index, 1)

				if isNumber(char)
					temp .= char
				else if (char != A_Space) {
					rest := SubStr(candidate, A_Index)

					return temp
				}
			}

			rest := ""

			return ((temp != "") ? temp : false)
		}
	}

	parseCategory(candidate, &rest) {
		local temp := ""
		local char

		loop StrLen(candidate) {
			char := SubStr(candidate, A_Index, 1)

			if (char != A_Space)
				temp .= char
			else {
				rest := SubStr(candidate, A_Index)

				return temp
			}
		}

		rest := ""

		return ((temp != "") ? temp : false)
	}

	parseCarName(carID, carName, &model?, &nr?, &category?, &team?) {
		local index

		model := false
		team := false
		nr := false
		category := false

		carName := Trim(carName)
		index := InStr(carName, "#")

		if (index = 1) {
			nr := this.parseNr(SubStr(carName, 2), &carName)

			if (InStr(carName, ":") = 1)
				category := this.parseCategory(SubStr(carName, 2), &carName)

			model := carName
		}
		else if index {
			carName := StrSplit(carName, "#", , 2)

			model := Trim(carName[1])

			if (model = "")
				model := false

			nr := this.parseNr(carName[2], &carName)

			if (InStr(carName, ":") = 1) {
				category := this.parseCategory(SubStr(carName, 2), &carName)

				if (category = "")
					category := false
			}
		}
		else if (carName != "")
			model := carName

		if (InStr(model, ":") && !category) {
			carName := StrSplit(model, ":", , 2)

			model := Trim(carName[1])
			category := Trim(carName[2])
		}

		model := normalizeFileName(model)
	}

	parseDriverName(carID, carName, forName, surName, nickName, &category?) {
		category := false

		return driverName(forName, surName, nickName)
	}

	acquireStandingsData(telemetryData, finished := false) {
		local debug := isDebug()
		local simulator := this.Simulator
		local track := this.Track
		local standingsData := super.acquireStandingsData(telemetryData, finished)
		local driver := getMultiMapValue(standingsData, "Position Data", "Driver.Car", 0)
		local numbers := Map()
		local duplicateNrs := false
		local carCategory := false
		local driverCategory := false
		local model := false
		local team := false
		local nr := false
		local carRaw, carID, forName, surName, nickName, car, tyreCompound

		loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0) {
			carRaw := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".CarRaw", kUndefined)

			if (carRaw != kUndefined) {
				this.parseCarName(getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID")
								, carRaw, &model, &nr, &carCategory, &team)

				if model
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Car", model)

				if team
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Team", team)

				if (A_Index != driver) {
					if debug
						setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Name"
									   , driverName(getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Forname", "")
												  , getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Surname", "")
												  , getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Nickname", "")))

					parseDriverName(this.parseDriverName(getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID")
													   , carRaw, getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Forname", "")
															   , getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Surname", "")
															   , getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Nickname", "")
													   , &driverCategory)
								  , &forName, &surName, &nickName)

					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Forname", forName)
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Surname", surName)
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Nickname", nickName)

					if driverCategory
						setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Driver.Category", driverCategory)
				}

				nr := Integer(nr ? nr : getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID"))

				setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Nr", nr)

				if carCategory
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Category", carCategory)

				if numbers.Has(nr)
					duplicateNrs := true
				else
					numbers[nr] := true
			}

			car := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Car", "Unknown")

			tyreCompound := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".TyreCompoundRaw", kUndefined)

			if (tyreCompound != kUndefined) {
				tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

				if tyreCompound
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".TyreCompound", tyreCompound)
			}

			tyreCompound := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".TyreCompoundRawFront", kUndefined)

			if (tyreCompound != kUndefined) {
				tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

				if tyreCompound
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".TyreCompoundFront", tyreCompound)
			}

			tyreCompound := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".TyreCompoundRawRear", kUndefined)

			if (tyreCompound != kUndefined) {
				tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

				if tyreCompound
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".TyreCompoundRear", tyreCompound)
			}
		}

		if duplicateNrs
			loop getMultiMapValue(standingsData, "Position Data", "Car.Count", 0) {
				carID := getMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".ID", kUndefined)

				if (carID != kUndefined)
					setMultiMapValue(standingsData, "Position Data", "Car." . A_Index . ".Nr", carID)
			}

		return standingsData
	}

	acquireTelemetryData() {
		local telemetryData := super.acquireTelemetryData()
		local model, forName, surName, nickName

		static lastSimulator := false
		static lastCar := false
		static lastTrack := false

		static loadSetup := false
		static nextSetupUpdate := false

		if (!getMultiMapValue(telemetryData, "Stint Data", "InPit", false) && (getMultiMapValue(telemetryData, "Car Data", "FuelRemaining", 0) = 0))
			setMultiMapValue(telemetryData, "Session Data", "Paused", true)

		if ((this.Simulator != lastSimulator) || (this.Car != lastCar) || (this.Track != lastTrack)) {
			lastSimulator := this.Simulator
			lastCar := this.Car
			lastTrack := this.Track

			loadSetup := SettingsDatabase().readSettingValue(lastSimulator, lastCar, lastTrack, "*", "*"
														   , "Simulator." . this.Simulator, "Session.Data.Setup"
														   , (lastSimulator = "rFactor 2") ? 60 : 20)
		}

		this.parseCarName(false, getMultiMapValue(telemetryData, "Session Data", "CarRaw"), &model)

		if model
			setMultiMapValue(telemetryData, "Session Data", "Car", model)

		if (loadSetup == true)
			addMultiMapValues(telemetryData, this.readSessionData("Setup=true"))
		else if (loadSetup && (A_TickCount > nextSetupUpdate)) {
			addMultiMapValues(telemetryData, this.readSessionData("Setup=true"))

			nextSetupUpdate := (A_TickCount + (loadSetup * 1000))
		}

		return telemetryData
	}

	readSessionData(options := "", protocol?) {
		local simulator := this.Simulator
		local car := this.Car
		local track := this.Track
		local data := super.readSessionData(options, protocol?)
		local tyreCompound, tyreCompoundColor, ignore, section, postFix

		static tyres := ["Front", "Rear"]

		if !car
			car := getMultiMapValue(data, "Session Data", "Car", false)

		if !track
			track := getMultiMapValue(data, "Session Data", "Track", false)

		for ignore, section in ["Car Data", "Setup Data"]
			for ignore, postfix in tyres {
				tyreCompound := getMultiMapValue(data, section, "TyreCompound" . postFix, kUndefined)

				if (tyreCompound = kUndefined) {
					tyreCompound := getMultiMapValue(data, section, "TyreCompoundRaw" . postFix, kUndefined)

					if (tyreCompound != kUndefined)
						if tyreCompound {
							tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

							if tyreCompound {
								splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

								setMultiMapValue(data, section, "TyreCompound" . postFix, tyreCompound)
								setMultiMapValue(data, section, "TyreCompoundColor" . postFix, tyreCompoundColor)
							}
						}
						else {
							setMultiMapValue(data, section, "TyreCompound" . postFix, false)
							setMultiMapValue(data, section, "TyreCompoundColor" . postFix, false)
						}
				}
			}

		return data
	}
}

class RF2Provider extends Sector397Provider {
	static Simulator {
		Get {
			return "rFactor 2"
		}
	}

	Simulator {
		Get {
			return RF2Provider.Simulator
		}
	}

	static __New(arguments*) {
		SimulatorProvider.registerSimulatorProvider("RF2", RF2Provider)
	}

	supportsPitstop(&refuelService?, &tyreService?, &brakeService?, &repairService?) {
		refuelService := true
		tyreService := "Axle"
		brakeService := false
		repairService := ["Bodywork", "Suspension"]

		return true
	}

	supportsTyreManagement(&mixedCompounds?, &tyreSets?) {
		mixedCompounds := "Axle"
		tyreSets := false

		return true
	}
}