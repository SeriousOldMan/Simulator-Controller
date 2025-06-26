﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LMU REST Provider               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\Task.ahk"
#Include "..\..\Framework\Extensions\HTTP.ahk"
#Include "..\..\Framework\Extensions\JSON.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class LMURESTProvider {
	static sTyreTypes := CaseInsenseMap("All", "FL", "FL", "FL", "FR", "FR", "RL", "RL", "RR", "RR"
									  , "Front Left", "FL", "Front Right", "FR", "Rear Left", "RL", "Rear Right", "RR")
	static sBrakeTypes := CaseInsenseMap("FL", "frontLeft", "FR", "frontRight", "RL", "rearLeft", "RR", "rearRight"
									   , "Front Left", "frontLeft", "Front Right", "frontRight"
									   , "Rear Left", "rearLeft", "Rear Right", "rearRight")

	class RESTData {
		iSimulator := false
		iCar := false
		iTrack := false

		iData := false

		GETURL {
			Get {
				return "Virtual property RESTData.GETURL must be implemented in a subclass..."
			}
		}

		POSTURL {
			Get {
				return "Virtual property RESTData.POSTURL must be implemented in a subclass..."
			}
		}

		Simulator {
			Get {
				return this.iSimulator
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

		Data {
			Get {
				if (!this.iData || this.iData.Has("error"))
					this.read()

				return ((!this.iData || this.iData.Has("error")) ? false : this.iData)
			}
		}

		__New(simulator := false, car := false, track := false) {
			this.iSimulator := simulator
			this.iCar := car
			this.iTrack := track
		}

		read(url := this.GETURL, update := true) {
			local data

			static lmuApplication := Application("Le Mans Ultimate", kSimulatorConfiguration)

			if lmuApplication.isRunning() {
				try {
					data := WinHttpRequest({Timeouts: [0, 500, 500, 500]}).GET(url, "", false, {Encoding: "UTF-8", Content: "application/json"}).JSON

					if !isObject(data)
						data := false

					if update
						this.iData := data
				}
				catch Any as exception {
					logError(exception)

					if update
						this.iData := false

					data := false
				}
			}
			else
				data := false

			return data
		}

		write(url := this.POSTURL, data := this.Data) {
			static lmuApplication := Application("Le Mans Ultimate", kSimulatorConfiguration)

			if (data && lmuApplication.isRunning()) {
				data := JSON.print(data, "  ")

				try {
					WinHttpRequest({Timeouts: [0, 500, 500, 500]}).POST(url, data, false, {Object: true, Encoding: "UTF-8"})
				}
				catch Any as exception {
					logError(exception, true)
				}
			}
		}

		reload() {
			this.iData := false
		}
	}

	class PitstopData extends LMURESTProvider.RESTData {
		iCachedObjects := CaseInsenseMap()

		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/PitMenu/receivePitMenu"
			}
		}

		POSTURL {
			Get {
				return "http://localhost:6397/rest/garage/PitMenu/loadPitMenu"
			}
		}

		RefuelLevel {
			Get {
				return this.getRefuelLevel()
			}

			Set {
				this.setRefuelLevel(value)

				return this.RefuelLevel
			}
		}

		FuelRatio {
			Get {
				return this.getFuelRatio()
			}

			Set {
				this.setFuelRatio(value)

				return this.FuelRatio
			}
		}

		TyreCompound[tyre := "All"] {
			Get {
				return this.getTyreCompound(tyre)
			}

			Set {
				this.setTyreCompound(tyre, value)

				return this.TyreCompound[tyre]
			}
		}

		TyrePressure[tyre := "All"] {
			Get {
				return this.getTyrePressure(tyre)
			}

			Set {
				this.setTyrePressure(tyre, value)

				return this.TyrePressure[tyre]
			}
		}

		RepairBodywork {
			Get {
				local ignore, bodywork

				this.getRepairs(&bodywork, &ignore, &ignore)

				return bodywork
			}

			Set {
				this.setRepairs(value, this.RepairSuspension, this.RepairEngine)

				return this.RepairBodywork
			}
		}

		RepairSuspension {
			Get {
				local ignore, suspension

				this.getRepairs(&ignore, &suspension, &ignore)

				return suspension
			}

			Set {
				this.setRepairs(this.RepairBodywork, value, this.RepairEngine)

				return this.RepairSuspension
			}
		}

		RepairEngine {
			Get {
				local ignore, engine

				this.getRepairs(&ignore, &ignore, &engine)

				return engine
			}

			Set {
				this.setRepairs(this.RepairBodywork, this.RepairSuspension, value)

				return this.RepairEngine
			}
		}

		BrakeChange {
			Get {
				return this.getBrakeChange()
			}

			Set {
				this.setBrakeChange(value)

				return this.BrakeChange
			}
		}

		Driver {
			Get {
				return this.getDriver()
			}

			Set {
				this.setDriver(value)

				return this.Driver
			}
		}

		supportsEngineRepair() {
			return false
		}

		supportsDriverSwap() {
			return (this.lookup("DRIVER:") != false)
		}

		lookup(name, data := this.Data, cache := true) {
			local ignore, candidate

			if (cache && this.iCachedObjects.Has(name))
				return this.iCachedObjects[name]
			else if data {
				for ignore, candidate in data
					if (candidate.Has("name") && (candidate["name"] = name)) {
						if cache
							this.iCachedObjects[name] := candidate

						return candidate
					}

				return false
			}
			else
				return false
		}

		reload() {
			super.reload()

			this.iCachedObjects := CaseInsenseMap()
		}

		getRefuelLevel() {
			local ratio := this.lookup("FUEL RATIO:")
			local energy := this.lookup("VIRTUAL ENERGY:")
			local fuel

			if (ratio && energy)
				return (ratio["settings"][ratio["currentSetting"] + 1]["text"] * energy["currentSetting"])
			else {
				fuel := this.lookup("FUEL:")

				if fuel {
					fuel := StrLower(fuel["settings"][fuel["currentSetting"] + 1]["text"])

					if InStr(fuel, "gal/")
						fuel := (string2Values("gal/", fuel)[1] * 3.785411)
					else
						fuel := string2Values("l/", fuel)[1]

					return fuel
				}
				else
					return false
			}
		}

		setRefuelLevel(liters) {
			local ratio := this.lookup("FUEL RATIO:")
			local energy := this.lookup("VIRTUAL ENERGY:")
			local fuel, index, value

			if (ratio && energy)
				energy["currentSetting"] := Min(100, Max(0, Round(liters / ratio["settings"][ratio["currentSetting"] + 1]["text"])))
			else {
				fuel := this.lookup("FUEL:")

				if fuel {
					for index, value in fuel["settings"] {
						value := StrLower(value["text"])

						if InStr(value, "gal/")
							value := (string2Values("gal/", value)[1] * 3.785411)
						else
							value := string2Values("l/", value)[1]

						if (value > liters) {
							fuel["currentSetting"] := (index - 1)

							return
						}
					}

					fuel["currentSetting"] := (fuel["settings"].Length - 1)
				}
			}
		}

		changeRefuelLevel(steps := 1) {
			local energy := this.lookup("VIRTUAL ENERGY:")
			local fuel

			if energy
				energy["currentSetting"] := Min(100, Max(0, energy["currentSetting"] + Round(steps)))
			else {
				fuel := this.lookup("FUEL:")

				if fuel
					fuel["currentSetting"] := Min(fuel["settings"].Length - 1, Max(0, fuel["currentSetting"] + Round(steps)))
			}
		}

		getFuelRatio() {
			local ratio := this.lookup("FUEL RATIO:")

			return (ratio ? ratio["settings"][ratio["currentSetting"] + 1]["text"] : false)
		}

		setFuelRatio(value) {
			local ratio := this.lookup("FUEL RATIO:")

			value := Round(value, 2)

			if ratio {
				for index, candidate in ratio["settings"] {
					candidate := candidate["text"]

					if ((index = 1) && (value < candidate)) {
						ratio["currentSetting"] := 0

						return
					}
					else if (value = candidate) {
						ratio["currentSetting"] := (index - 1)

						return
					}
				}

				ratio["currentSetting"] := (ratio["settings"].Length - 1)
			}
		}

		getTyreCompound(tyre) {
			tyre := this.lookup((tyre = "All") ? "TIRES:" : (LMURESTProvider.TyreTypes[tyre] . " TIRE:"))

			if tyre
				return ((tyre["currentSetting"] > 0) ? tyre["settings"][tyre["currentSetting"] + 1]["type"] : false)
			else
				return false
		}

		setTyreCompound(tyre, code) {
			local index, candidate

			if (tyre = "All") {
				if !this.setTyreCompound("FL", code)
					return false

				if !this.setTyreCompound("FR", code)
					return false

				if !this.setTyreCompound("RL", code)
					return false

				if !this.setTyreCompound("RR", code)
					return false

				tyre := this.lookup("TIRES:")
			}
			else
				tyre := this.lookup(LMURESTProvider.TyreTypes[tyre] . " TIRE:")

			if tyre {
				if !isInteger(code) {
					if code {
						for index, candidate in tyre["settings"]
							if ((index > 1) && (candidate["type"] = code)) {
								tyre["currentSetting"] := (index - 1)

								return true
							}

						return false
					}
					else {
						tyre["currentSetting"] := code

						return true
					}
				}
				else {
					tyre["currentSetting"] := code

					return true
				}
			}
			else
				return false
		}

		changeTyreCompound(tyre, steps := 1) {
			local all := (tyre = "All")
			local index, candidate

			tyre := this.lookup(all ? "TIRES:" : (LMURESTProvider.TyreTypes[tyre] . " TIRE:"))

			if tyre {
				tyre["currentSetting"] := Min(tyre["settings"].Length - 1
											, SessionDatabase.getTyreCompounds(this.Simulator, this.Car, this.Track).Length
											, Max(0, tyre["currentSetting"] + Round(steps)))

				if all {
					this.setTyreCompound("FL", tyre["currentSetting"])
					this.setTyreCompound("FR", tyre["currentSetting"])
					this.setTyreCompound("RL", tyre["currentSetting"])
					this.setTyreCompound("RR", tyre["currentSetting"])
				}
			}
		}

		getTyrePressure(tyre) {
			local pressure := this.lookup(LMURESTProvider.TyreTypes[tyre] . " PRESS:")

			if pressure {
				pressure := string2Values(A_Space, pressure["settings"][pressure["currentSetting"] + 1]["text"])[1]

				return ((pressure > 50) ? Round(pressure / 6.894757, 2) : pressure)
			}
			else
				return false
		}

		setTyrePressure(tyre, value) {
			local pressure, index, candidate, cValue

			value := Round((value < 50) ? (value * 6.894757) : value)

			pressure := this.lookup(LMURESTProvider.TyreTypes[tyre] . " PRESS:")

			if pressure {
				for index, candidate in pressure["settings"] {
					cValue := string2Values(A_Space, candidate["text"])[1]
					cValue := Round((cValue < 50) ? (cValue * 6.894757) : cValue)

					if ((index = 1) && (value <= cValue)) {
						pressure["currentSetting"] := 0

						return
					}
					else if (cValue = value) {
						pressure["currentSetting"] := (index - 1)

						return
					}
					else if (cValue > value) {
						pressure["currentSetting"] := Max(0, (index - 2))

						return
					}
				}

				pressure["currentSetting"] := (pressure["settings"].Length - 1)
			}
		}

		changeTyrePressure(tyre, steps := 1) {
			local pressure := this.lookup(LMURESTProvider.TyreTypes[tyre] . " PRESS:")

			pressure["currentSetting"] := Min(pressure["settings"].Length, Max(0, pressure["currentSetting"] + Round(steps)))
		}

		getRepairs(&bodywork, &suspension, &engine) {
			local damage, value

			bodywork := false
			suspension := false
			engine := false

			damage := this.lookup("DAMAGE:")

			if (damage && (damage["settings"].Length > 1)) {
				value := damage["currentSetting"]

				if (value >= 1)
					bodywork := true

				if ((damage["settings"].Length > 2) && (value >= 2))
					suspension := true
			}
		}

		setRepairs(bodywork, suspension, engine) {
			local damage := this.lookup("DAMAGE:")

			if (damage && (damage["settings"].Length > 1)) {
				damage["currentSetting"] := 0

				if (damage["settings"].Length > 2) {
					if (bodywork && suspension)
						damage["currentSetting"] := (damage["settings"].Length - 1)
					else if bodywork
						damage["currentSetting"] := 1
					else if suspension
						damage["currentSetting"] := 2
				}
				else if (bodywork && suspension)
					damage["currentSetting"] := (damage["settings"].Length - 1)
				else if bodywork
					damage["currentSetting"] := 1
			}
		}

		changeRepairs(steps := 1) {
			local index

			static threeStates := [[false, false, false], [true, false, false], [false, true, false], [false, false, true]
								 , [true, true, false], [false, true, true], [true, false, true], [true, true, true]]
			static twoStates := [[false, false], [true, false], [false, true], [true, true]]

			inThreeStates(v1, v2, v3) {
				local index, candidate

				for index, candidate in threeStates
					if ((candidate[1] = v1) && (candidate[2] = v2) && (candidate[3] = v3))
						return index

				return false
			}

			inTwoStates(v1, v2) {
				local index, candidate

				for index, candidate in twoStates
					if ((candidate[1] = v1) && (candidate[2] = v2))
						return index

				return false
			}

			if this.supportsEngineRepair() {
				index := (inThreeStates(this.RepairBodywork, this.RepairSuspension, this.RepairEngine) + Round(steps))

				if index {
					while ((steps > 0) && (index > threeStates.Length))
						index -= threeStates.Length

					while ((steps < 0) && (index < 1))
						index += threeStates.Length

					this.RepairBodywork := threeStates[index][1]
					this.RepairSuspension := threeStates[index][2]
					this.RepairEngine := threeStates[index][3]
				}
			}
			else {
				index := (inTwoStates(this.RepairBodywork, this.RepairSuspension) + Round(steps))

				if index {
					while ((steps > 0) && (index > twoStates.Length))
						index -= twoStates.Length

					while ((steps < 0) && (index < 1))
						index += twoStates.Length

					this.RepairBodywork := twoStates[index][1]
					this.RepairSuspension := twoStates[index][2]
				}
			}
		}

		getBrakeChange() {
			local brakes := this.lookup("REPLACE BRAKES:")

			return (brakes ? (brakes["currentSetting"] != 0) : false)
		}

		setBrakeChange(change) {
			local brakes := this.lookup("REPLACE BRAKES:")

			if brakes
				brakes["currentSetting"] := (change ? 1 : 0)
		}

		changeBrakeChange(steps := 1) {
			local brakes := this.lookup("REPLACE BRAKES:")

			if brakes
				brakes["currentSetting"] := Max(0, Min(1, brakes["currentSetting"] + Round(steps)))
		}

		getDriver() {
			local driver := this.lookup("DRIVER:")

			return (driver ? driver["settings"][driver["currentSetting"] + 1]["text"]
						   : SessionDatabase.getDriverName(this.Simulator, SessionDatabase.ID))
		}

		setDriver(name) {
			local driver := this.lookup("DRIVER:")
			local index, candidate, forName, surName, cForName, cSurName, ignore

			if driver {
				parseDriverName(name, &forName, &surName, &ignore)

				for index, candidate in driver["settings"] {
					parseDriverName(candidate["text"], &cForName, &cSurName, &ignore)

					if ((forName = cForName) && (surName = cSurName)) {
						driver["currentSetting"] := (index - 1)

						break
					}
				}
			}
		}

		changeDriver(steps := 1) {
			local driver := this.lookup("DRIVER:")

			if driver
				driver["currentSetting"] := Max(0, Min(driver["settings"].Length - 1, driver["currentSetting"] + steps))
		}
	}

	class ServiceData extends LMURESTProvider.RESTData {
		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/UIScreen/RepairAndRefuel"
			}
		}

		ServiceTime {
			Get {
				return this.getServiceTime()
			}
		}

		getServiceTime() {
			if (this.Data && this.Data.Has("pitstopLength"))
				return this.Data["pitstopLength"]["timeInSeconds"]
			else
				return false
		}
	}

	class SetupData extends LMURESTProvider.RESTData {
		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/UIScreen/CarSetupOverview"
			}
		}

		FuelAmount {
			Get {
				return this.getFuelAmount()
			}
		}

		TyreCompound[tyre := "All"] {
			Get {
				return this.getTyreCompound(tyre)
			}
		}

		TyrePressure[tyre] {
			Get {
				return this.getTyrePressure(tyre)
			}
		}

		getFuelAmount() {
			local carSetup, capacity

			if this.Data {
				carSetup := this.Data["carSetup"]["garageValues"]
				capacity := string2Values(A_Space, carSetup["VM_FUEL_CAPACITY"]["stringValue"])[1]

				if InStr(capacity, "gal")
					capacity := (StrReplace(capacity, "gal", "") * 3.785411)
				else
					capacity := StrReplace(capacity, "l", "")

				return ((carSetup["VM_VIRTUAL_ENERGY"]["value"] / 100) * capacity * carSetup["VM_FUEL_LEVEL"]["stringValue"])
			}
			else
				return false
		}

		getTyreCompound(tyre) {
			local carSetup

			if this.Data {
				try {
					carSetup := this.Data["carSetup"]["garageValues"]

					return SessionDatabase.getTyreCompounds(this.Simulator
														  , this.Car
														  , this.Track, true)[carSetup["WM_COMPOUND-W_" . LMURESTProvider.TyreTypes[tyre]]["value"] + 1]
				}
				catch Any as exception {
					logError(exception)

					this.reload()

					return SessionDatabase.getTyreCompounds(this.Simulator, this.Car, this.Track, true)[1]
				}
			}
			else
				return false
		}

		getTyrePressure(tyre) {
			local pressure

			if this.Data
				try {
					pressure := this.Data["carSetup"]["garageValues"]["WM_PRESSURE-W_" . LMURESTProvider.TyreTypes[tyre]]["stringValue"]

					if InStr(pressure, "kPa")
						return Round(string2Values(A_Space, pressure)[1] / 6.894757, 2)
					else
						return Round(string2Values(A_Space, pressure)[1], 2)
				}
				catch Any as exception {
					logError(exception)

					this.reload()
				}

			return false
		}
	}

	class BrakeData extends LMURESTProvider.RESTData {
		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/brakeinfo"
			}
		}

		BrakePadThickness[tyre] {
			Get {
				return this.getBrakePadThickness(tyre)
			}
		}

		getBrakepadThickness(tyre) {
			local thickness
			if this.Data
				try {
					thickness := this.Data[inList(["FL", "FR", "RL", "RR"], LMURESTProvider.TyreTypes[tyre])]

					if (thickness > 0)
						return thickness
					else
						this.reload()
				}
				catch Any as exception {
					logError(exception)

					this.reload()
				}

			return 0.032
		}
	}

	class WheelData extends LMURESTProvider.RESTData {
		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/UIScreen/TireManagement"
			}
		}

		TyreCompound[tyre] {
			Get {
				return this.getTyreCompound(tyre)
			}
		}

		TyreWear[tyre] {
			Get {
				return this.getTyreWear(tyre)
			}
		}

		BrakePadThickness[tyre] {
			Get {
				return this.getBrakePadThickness(tyre)
			}
		}

		getTyreCompound(tyre) {
			if this.Data
				try {
					tyre := this.Data["wheelInfo"]["wheelLocs"][inList(["FL", "FR", "RL", "RR"], LMURESTProvider.TyreTypes[tyre])]["compound"]

					return this.Data["optimalCompoundConditions"]["compounds"][tyre + 1]["type"]
				}
				catch Any as exception {
					logError(exception)

					this.reload()
				}

			return false
		}

		getTyreWear(tyre) {
			if this.Data
				try {
					return (100 * (1 - this.Data["wearables"]["tires"][inList(["FL", "FR", "RL", "RR"], LMURESTProvider.TyreTypes[tyre])]))
				}
				catch Any as exception {
					logError(exception)

					this.reload()
				}

			return false
		}

		getBrakepadThickness(tyre) {
			local thickness

			if this.Data
				try {
					thickness := this.Data["wearables"]["brakes"][inList(["FL", "FR", "RL", "RR"], LMURESTProvider.TyreTypes[tyre])]

					if (thickness > 0)
						return thickness
					else
						this.reload()
				}
				catch Any as exception {
					logError(exception)

					this.reload()
				}

			return 0.032
		}
	}

	class EnergyData extends LMURESTProvider.RESTData {
		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/UIScreen/RepairAndRefuel"
			}
		}

		RemainingVirtualEnergy {
			Get {
				return this.getRemainingVirtualEnergy()
			}
		}

		MaxVirtualEnergy {
			Get {
				return 100
			}
		}

		RemainingFuelAmount {
			Get {
				return this.getRemainingFuelAmount()
			}
		}

		MaxFuelAmount {
			Get {
				return this.getMaxFuelAmount()
			}
		}

		getRemainingVirtualEnergy() {
			if (this.Data && this.Data.Has("fuelInfo") && this.Data["fuelInfo"].Has("currentVirtualEnergy"))
				return Round(this.Data["fuelInfo"]["currentVirtualEnergy"] / this.Data["fuelInfo"]["maxVirtualEnergy"] * 100, 2)
			else
				return false
		}

		getRemainingFuelAmount() {
			return ((this.Data && this.Data.Has("fuelInfo")) ? Round(this.Data["fuelInfo"]["currentFuel"], 2) : false)
		}

		getMaxFuelAmount() {
			return ((this.Data && this.Data.Has("fuelInfo")) ? Round(this.Data["fuelInfo"]["maxFuel"], 2) : false)
		}
	}

	class SessionData extends LMURESTProvider.RESTData {
		GETURL {
			Get {
				return "http://localhost:6397/rest/sessions/GetSessionsInfoForEvent"
			}
		}

		Duration[session] {
			Get {
				return this.getDuration(session)
			}
		}

		RainChance[session] {
			Get {
				return this.getRainChance(session)
			}
		}

		getDuration(session) {
			local ignore, candidate

			if InStr(session, "Qualif")
				session := "QUALIFY"
			else
				session := StrUpper(session)

			if (this.Data && this.Data.Has("scheduledSessions"))
				try {
					for ignore, candidate in this.Data["scheduledSessions"]
						if InStr(candidate["name"], session)
							return (candidate["lengthTime"] * 60)
				}
				catch Any as exception {
					logError(exception)

					this.reload()
				}

			return false
		}

		getRainChance(session) {
			local ignore, candidate

			if InStr(session, "Qualif")
				session := "QUALIFY"
			else
				session := StrUpper(session)

			if (this.Data && this.Data.Has("scheduledSessions"))
				try {
					for ignore, candidate in this.Data["scheduledSessions"]
						if InStr(candidate["name"], session)
							return candidate["rainChance"]
				}
				catch Any as exception {
					logError(exception)

					this.reload()
				}

			return false
		}
	}

	class TrackData extends LMURESTProvider.RESTData {
		iCachedTrack := false

		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/UIScreen/RaceHistory"
			}
		}

		Track {
			Get {
				return this.getTrack()
			}
		}

		getTrack() {
			if this.iCachedTrack
				return this.iCachedTrack
			else if (this.Data && this.Data.Has("trackInfo")) {
				this.iCachedTrack := this.Data["trackInfo"]["properTrackName"]

				return this.iCachedTrack
			}
			else
				return false
		}
	}

	class TeamData extends LMURESTProvider.RESTData {
		iCachedCar := false
		iCachedTeam := false

		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/UIScreen/CarSetupOverview"
			}
		}

		Car {
			Get {
				return this.getCar()
			}
		}

		Team {
			Get {
				return this.getTeam()
			}
		}

		getCar() {
			if this.iCachedCar
				return this.iCachedCar
			else if (this.Data && this.Data.Has("teamInfo")) {
				this.iCachedCar := this.Data["teamInfo"]["vehicleName"]

				return this.iCachedCar
			}
			else
				return false
		}

		getTeam() {
			if this.iCachedTeam
				return this.iCachedTeam
			else if (this.Data && this.Data.Has("teamInfo")) {
				this.iCachedTeam := this.Data["teamInfo"]["teamName"]

				return this.iCachedTeam
			}
			else
				return false
		}
	}

	class GridData extends LMURESTProvider.RESTData {
		iCachedCars := CaseInsenseMap()

		GETURL {
			Get {
				return "http://localhost:6397/rest/sessions/getAllVehicles"
			}
		}

		Car[carDesc] {
			Get {
				return this.getCar(carDesc)
			}
		}

		Class[carDesc] {
			Get {
				return this.getClass(carDesc)
			}
		}

		Team[carDesc] {
			Get {
				return this.getTeam(carDesc)
			}
		}

		Drivers[carDesc] {
			Get {
				return this.getDrivers(carDesc)
			}
		}

		getCarDescriptor(carDesc) {
			local ignore, candidate

			if this.iCachedCars.Has(carDesc)
				return this.iCachedCars[carDesc]
			else if this.Data
				if (Trim(carDesc) != "")
					for ignore, candidate in this.Data
						if (InStr(candidate["desc"], carDesc) = 1) {
							this.iCachedCars[carDesc] := candidate

							return candidate
						}

			return false
		}

		getCar(carDesc) {
			local car := this.getCarDescriptor(carDesc)

			return (car ? string2Values(",", car["fullPathTree"])[3] : false)
		}

		getClass(carDesc) {
			local car := this.getCarDescriptor(carDesc)

			return (car ? string2Values(",", car["fullPathTree"])[2] : false)
		}

		getTeam(carDesc) {
			local car := this.getCarDescriptor(carDesc)

			return (car ? car["team"] : false)
		}

		getDrivers(carDesc) {
			local car := this.getCarDescriptor(carDesc)
			local result := []
			local ignore, driver

			if car
				for ignore, driver in car["drivers"]
					if (Trim(driver["name"]) != "")
						result.Push({Name: driver["name"], Category: driver["skill"]})

			return result
		}
	}

	class StandingsData extends LMURESTProvider.RESTData {
		iStandings := false

		GETURL {
			Get {
				return "http://localhost:6397/rest/watch/standings/history"
			}
		}

		Count {
			Get {
				if !this.iStandings
					this.getCarDescriptor(1)

				return (this.iStandings ? this.iStandings.Count : false)
			}
		}

		Driver[position] {
			Get {
				return this.getDriver(position)
			}
		}

		Class[position] {
			Get {
				return this.getClass(position)
			}
		}

		Laps[position] {
			Get {
				return this.getLaps(position)
			}
		}

		getCarDescriptor(position) {
			local ignore, candidates, candidate, standings

			if !this.iStandings && this.Data {
				standings := Map()

				for ignore, candidates in this.Data
					for ignore, candidate in candidates
						standings[Integer(candidate["position"])] := candidate

				this.iStandings := standings
			}

			position := Integer(position)

			return ((this.iStandings && this.iStandings.Has(position)) ? this.iStandings[position] : false)
		}

		getDriver(position) {
			local car := this.getCarDescriptor(position)

			return (car ? car["driverName"] : false)
		}

		getClass(position) {
			local car := this.getCarDescriptor(position)

			return (car ? car["carClass"] : false)
		}

		getLaps(position) {
			local car := this.getCarDescriptor(position)

			return (car ? car["totalLaps"] : false)
		}
	}

	class WeatherData extends LMURESTProvider.RESTData {
		GETURL {
			Get {
				return "http://localhost:6397/rest/sessions/weather"
			}
		}

		Humidity[session := "Now", time := false] {
			Get {
				return this.getHumidity(session, time)
			}
		}

		RainChance[session := "Now", time := false] {
			Get {
				return this.getRainChance(session, time)
			}
		}

		RainLevel[session := "Now", time := false] {
			Get {
				return this.getRainLevel(session, time)
			}
		}

		Weather[session := "Now", time := false] {
			Get {
				return this.getRainLevel(session, time)
			}
		}

		getWeather(index) {
			if (index >= 10)
				return "Thunderstorm"
			else if (index >= 9)
				return "HeavyRain"
			else if (index >= 8)
				return "MediumRain"
			else if (index >= 6)
				return "LightRain"
			else if (index >= 5)
				return "Drizzle"
			else
				return "Dry"
		}

		getHumidity(session, time) {
			local data, name

			if (session = "Now") {
				data := this.read("http://localhost:6397/rest/sessions/GetGameState", false)

				if (data && data.Has("closeestWeatherNode"))
					return Round(data["closeestWeatherNode"]["Humidity"])
				else
					return false
			}
			else if isNumber(time) {
				if InStr(session, "Qualif")
					session := "QUALIFY"
				else
					session := StrUpper(session)

				data := this.Data

				if (data && data.Has(session)) {
					data := data[session]
					time := Max(0, Min(100, (Round(time / 25) * 25)))

					switch time {
						case 0:
							name := "START"
						case 100:
							name := "FINISH"
						default:
							name := ("Node_" . time)
					}

					if data.Has(name)
						return data[name]["WNV_HUMIDITY"]["currentValue"]
					else
						return false
				}
				else
					return false
			}
			else
				throw ("Unsupported time " . time . " detected in WeatherData.getHumidity...")
		}

		getRainChance(session, time) {
			local data, name

			if (session = "Now") {
				data := this.read("http://localhost:6397/rest/sessions/GetGameState", false)

				if (data && data.Has("closeestWeatherNode"))
					return this.getWeather(data["closeestWeatherNode"]["RainChance"])
				else
					return false
			}
			else if isNumber(time) {
				if InStr(session, "Qualif")
					session := "QUALIFY"
				else
					session := StrUpper(session)

				data := this.Data

				if (data && data.Has(session)) {
					data := data[session]
					time := Max(0, Min(100, (Round(time / 25) * 25)))

					switch time {
						case 0:
							name := "START"
						case 100:
							name := "FINISH"
						default:
							name := ("Node_" . time)
					}

					if data.Has(name)
						return this.getWeather(data[name]["WNV_RAIN_CHANCE"]["currentValue"])
					else
						return false
				}
				else
					return false
			}
			else
				throw ("Unsupported time " . time . " detected in WeatherData.getRainLevel...")
		}

		getRainLevel(session, time) {
			local data, name

			if (session = "Now") {
				data := this.read("http://localhost:6397/rest/sessions/GetGameState", false)

				if (data && data.Has("closeestWeatherNode"))
					return this.getWeather(data["closeestWeatherNode"]["Sky"])
				else
					return false
			}
			else if isNumber(time) {
				if InStr(session, "Qualif")
					session := "QUALIFY"
				else
					session := StrUpper(session)

				data := this.Data

				if (data && data.Has(session)) {
					data := data[session]
					time := Max(0, Min(100, (Round(time / 25) * 25)))

					switch time {
						case 0:
							name := "START"
						case 100:
							name := "FINISH"
						default:
							name := ("Node_" . time)
					}

					if data.Has(name)
						return this.getWeather(data[name]["WNV_SKY"]["currentValue"])
					else
						return false
				}
				else
					return false
			}
			else
				throw ("Unsupported time " . time . " detected in WeatherData.getRainChance...")
		}
	}

	class GarageData extends LMURESTProvider.RESTData {
		POSTURL {
			Get {
				return "http://localhost:6397/rest/garage/refreshsetups"
			}
		}

		refreshSetups() {
			try {
				WinHttpRequest({Timeouts: [0, 500, 500, 500]}).POST(this.POSTURL, "", false)
			}
			catch Any as exception {
				logError(exception)
			}
		}
	}

	static TyreTypes {
		Get {
			return LMURestProvider.sTyreTypes
		}
	}

	static BrakeTypes {
		Get {
			return LMURestProvider.sBrakeTypes
		}
	}
}