;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LMU REST Provider               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"
#Include "..\..\Libraries\HTTP.ahk"
#Include "..\..\Libraries\JSON.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class LMURestProvider {
	static sTyreTypes := CaseInsenseMap("All", "FL", "FL", "FL", "FR", "FR", "RL", "RL", "RR", "RR"
									  , "Front Left", "FL", "Front Right", "FR", "Rear Left", "RL", "Rear Right", "RR")

	class RESTData {
		iSimulator := false
		iCar := false
		iTrack := false

		iData := false

		iCachedObjects := CaseInsenseMap()

		GETURL {
			Get {
				return "Virtual property RESTData.GETURL must be implemented in a subclass..."
			}
		}

		PUTURL {
			Get {
				return "Virtual property RESTData.PUTURL must be implemented in a subclass..."
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

		read() {
			try {
				this.iData := WinHttpRequest().GET(this.GETURL, "", false, {Encoding: "UTF-8"}).JSON

				if !isObject(this.iData)
					this.iData := false
			}
			catch Any as exception {
				logError(exception)

				this.iData := false
			}
		}

		write() {
			local data := JSON.print(this.Data, "  ")

			if this.Data
				try {
					WinHttpRequest().POST(this.PUTURL, data, false, {Object: true, Encoding: "UTF-8"})
				}
				catch Any as exception {
					logError(exception, true)
				}
		}

		lookup(name) {
			local ignore, candidate

			if this.iCachedObjects.Has(name)
				return this.iCachedObjects[name]
			else if this.Data {
				for ignore, candidate in this.Data
					if (candidate.Has("name") && (candidate["name"] = name)) {
						this.iCachedObjects[name] := candidate

						return candidate
					}

				return false
			}
		}
	}

	class PitstopData extends LMURESTProvider.RESTData {
		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/PitMenu/receivePitMenu"
			}
		}

		PUTURL {
			Get {
				return "http://localhost:6397/rest/garage/PitMenu/loadPitMenu"
			}
		}

		RefuelAmount {
			Get {
				return this.getRefuelAmount()
			}

			Set {
				this.setRefuelAmount(value)

				return this.RefuelAmount
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
			return false
		}

		getRefuelAmount() {
			local ratio := this.lookup("FUEL RATIO:")
			local energy := this.lookup("VIRTUAL ENERGY:")

			if (ratio && energy)
				return (ratio["settings"][ratio["currentSetting"] + 1]["text"] * energy["currentSetting"])
			else
				return false
		}

		setRefuelAmount(liters) {
			local ratio := this.lookup("FUEL RATIO:")
			local energy := this.lookup("VIRTUAL ENERGY:")

			if (ratio && energy)
				energy["currentSetting"] := Min(100, Max(0, Round(liters / ratio["settings"][ratio["currentSetting"] + 1]["text"])))
		}

		changeRefuelAmount(steps := 1) {
			local energy := this.lookup("VIRTUAL ENERGY:")

			if energy
				energy["currentSetting"] := Min(100, Max(0, energy["currentSetting"] + Round(steps)))
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

				if (damage["settings"].Length > 3) {
					if (value >= 2)
						suspension := true
				}
				else if (value = 2)
					suspension := true
			}
		}

		setRepairs(bodywork, suspension, engine) {
			local damage := this.lookup("DAMAGE:")

			if (damage && (damage["settings"].Length > 1)) {
				damage["currentSetting"] := 0

				if (damage["settings"].Length > 3) {
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

		setDriver(driver) {
		}

		changeDriver(steps := 1) {
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
					capacity := (StrReplace(capacity, "gal", "") * 4.54609)
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

					return SessionDatabase.getTyreCompounds(this.Simulator, this.Car, this.Track, true)[1]
				}
			}
			else
				return false
		}

		getTyrePressure(tyre) {
			local pressure

			if this.Data {
				try {
					pressure := this.Data["carSetup"]["garageValues"]["WM_PRESSURE-W_" . LMURESTProvider.TyreTypes[tyre]]["stringValue"]

					if InStr(pressure, "kPa")
						return Round(string2Values(A_Space, pressure)[1] / 6.894757, 2)
					else
						return Round(string2Values(A_Space, pressure)[1], 2)
				}
				catch Any as exception {
					logError(exception)
				}
			}

			return false
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

		RemainingFuelAmount {
			Get {
				return this.getRemainingFuelAmount()
			}
		}

		getRemainingVirtualEnergy() {
			return (this.Data.Has("fuelInfo") ? Round(this.Data["fuelInfo"]["currentVirtualEnergy"] / this.Data["fuelInfo"]["maxVirtualEnergy"] * 100, 2) : false)
		}

		getFuelAmount() {
			return (this.Data.Has("fuelInfo") ? Round(this.Data["fuelInfo"]["currentFuel"], 2) : false)
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
			else if this.Data.Has("trackInfo") {
				this.iCachedTrack := this.Data["trackInfo"]["properTrackName"]

				return this.iCachedTrack
			}
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
			else if this.Data.Has("teamInfo") {
				this.iCachedTeam := this.Data["teamInfo"]["vehicleName"]

				return this.iCachedCar
			}
		}

		getTeam() {
			if this.iCachedTeam
				return this.iCachedTeam
			else if this.Data.Has("teamInfo") {
				this.iCachedTeam := this.Data["teamInfo"]["teamName"]

				return this.iCachedTeam
			}
		}
	}

	class GridData extends LMURESTProvider.RESTData {
		iCachedCars := CaseInsenseMap()

		GETURL {
			Get {
				return "http://localhost:6397/rest/sessions/getAllVehicles"
			}
		}

		Car[carID] {
			Get {
				return this.getCar(carID)
			}
		}

		Class[carID] {
			Get {
				return this.getClass(carID)
			}
		}

		Team[carID] {
			Get {
				return this.getTeam(carID)
			}
		}

		Drivers[carID] {
			Get {
				return this.getDrivers(carID)
			}
		}

		getCarDescriptor(carID) {
			local ignore, candidate

			if this.iCachedCars.Has(carID)
				return this.iCachedCars[carID]
			else if this.Data {
				if (Trim(carID) != "")
					for ignore, candidate in this.Data
						if (InStr(candidate["desc"], carID) = 1) {
							this.iCachedCars[carID] := candidate

							return candidate
						}

				return false
			}
			else
				return false
		}

		getCar(carID) {
			local car := this.getCarDescriptor(carID)

			return (car ? string2Values(",", car["fullPathTree"])[3] : false)
		}

		getClass(carID) {
			local car := this.getCarDescriptor(carID)

			return (car ? string2Values(",", car["fullPathTree"])[2] : false)
		}

		getTeam(carID) {
			local car := this.getCarDescriptor(carID)

			return (car ? car["team"] : false)
		}

		getDrivers(carID) {
			local car := this.getCarDescriptor(carID)
			local result := []
			local ignore, driver

			if car
				for ignore, driver in car["drivers"]
					if (Trim(driver["name"]) != "")
						result.Push({Name: driver["name"], Category: driver["skill"]})

			return result
		}
	}

	static TyreTypes {
		Get {
			return LMURestProvider.sTyreTypes
		}
	}
}