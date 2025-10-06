;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	static sWheelTypes := CaseInsenseMap("All", "FL", "FL", "FL", "FR", "FR", "RL", "RL", "RR", "RR"
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
			local data, tickCount

			static lmuApplication := Application("Le Mans Ultimate", kSimulatorConfiguration)

			if lmuApplication.isRunning() {
				try {
					tickCount := A_TickCount

					data := WinHttpRequest({Timeouts: [0, 500, 500, 500]}).GET(url, "", false, {Encoding: "UTF-8", Content: "application/json"}).JSON

					if isDebug()
						logMessage(kLogDebug, "LMU REST GET: " . url . " took " . (A_TickCount - tickCount) . " ms...")

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
			local tickCount

			static lmuApplication := Application("Le Mans Ultimate", kSimulatorConfiguration)

			if (data && lmuApplication.isRunning()) {
				data := JSON.print(data)

				try {
					tickCount := A_TickCount

					WinHttpRequest({Timeouts: [0, 500, 500, 500]}).POST(url, data, false, {Object: true, Encoding: "UTF-8"})

					if isDebug()
						logMessage(kLogDebug, "LMU REST POST: " . url . " took " . (A_TickCount - tickCount) . " ms...")
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
			tyre := this.lookup((tyre = "All") ? "TIRES:" : (LMURESTProvider.WheelTypes[tyre] . " TIRE:"))

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
				tyre := this.lookup(LMURESTProvider.WheelTypes[tyre] . " TIRE:")

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

			tyre := this.lookup(all ? "TIRES:" : (LMURESTProvider.WheelTypes[tyre] . " TIRE:"))

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
			local pressure := this.lookup(LMURESTProvider.WheelTypes[tyre] . " PRESS:")

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

			pressure := this.lookup(LMURESTProvider.WheelTypes[tyre] . " PRESS:")

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
			local pressure := this.lookup(LMURESTProvider.WheelTypes[tyre] . " PRESS:")

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

			try {
				return (driver ? driver["settings"][driver["currentSetting"] + 1]["text"]
							   : SessionDatabase.getDriverName(this.Simulator, SessionDatabase.ID))
			}
			catch Any as exception {
				logError(exception)

				return SessionDatabase.getDriverName(this.Simulator, SessionDatabase.ID)
			}
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
														  , this.Track, true)[carSetup["WM_COMPOUND-W_" . LMURESTProvider.WheelTypes[tyre]]["value"] + 1]
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
					pressure := this.Data["carSetup"]["garageValues"]["WM_PRESSURE-W_" . LMURESTProvider.WheelTypes[tyre]]["stringValue"]

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

	class CarData extends LMURESTProvider.RESTData {
		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/getVehicleCondition"
			}
		}

		Fuel {
			Get {
				return this.getFuel()
			}
		}

		FuelAmount {
			Get {
				return this.getFuelAmount()
			}
		}

		BrakePadWear[wheel] {
			Get {
				return this.getBrakeBrakePadWear(wheel)
			}
		}

		TyreWear[wheel] {
			Get {
				return this.getTyreWear(wheel)
			}
		}

		SuspensionDamage[wheel] {
			Get {
				return this.getSuspensionDamage(wheel)
			}
		}

		VehicleDamage {
			Get {
				return this.getVehicleDamage()
			}
		}

		getFuel() {
			return (this.Data ? this.Data["fuel"] : false)
		}

		getFuelAmount() {
			return (this.Data ? this.Data["fuelCapacity"] : false)
		}

		getBrakeBrakePadWear(wheel) {
			try {
				if (wheel = "All")
					return collect(this.Data["brakeCondition"], (bc) => Round(100 * (1 - bc), 2))
				else
					return Round(100 * (1 - this.Data["brakeCondition"][inList(["FL", "FR", "RL", "RR"], LMURESTProvider.WheelTypes[wheel])]), 2)
			}
			catch Any as exception {
				logError(exception)

				return false
			}
		}

		getTyreWear(wheel) {
			try {
				if (wheel = "All")
					return collect(this.Data["tireCondition"], (tc) => Round(100 * (1 - tc), 1))
				else
					return Round(100 * (1 - this.Data["tireCondition"][inList(["FL", "FR", "RL", "RR"], LMURESTProvider.WheelTypes[wheel])]), 1)
			}
			catch Any as exception {
				logError(exception)

				return false
			}
		}

		getSuspensionDamage(wheel) {
			try {
				if (wheel = "All")
					return this.Data["suspensionDamage"]
				else
					return this.Data["suspensionDamage"][inList(["FL", "FR", "RL", "RR"], LMURESTProvider.WheelTypes[wheel])]
			}
			catch Any as exception {
				logError(exception)

				return false
			}
		}

		getVehicleDamage() {
			try {
				return this.Data["vehicleDamage"]
			}
			catch Any as exception {
				logError(exception)

				return false
			}
		}

	}

	class BrakeDiscData extends LMURESTProvider.RESTData {
		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/brakeinfo"
			}
		}

		BrakeDiscThickness[tyre] {
			Get {
				return this.getBrakeDiscThickness(tyre)
			}
		}

		getBrakeDiscThickness(tyre) {
			local thickness

			if this.Data
				try {
					thickness := this.Data[inList(["FL", "FR", "RL", "RR"], LMURESTProvider.WheelTypes[tyre])]

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

		BrakeDiscThickness[tyre] {
			Get {
				return this.getBrakeDiscThickness(tyre)
			}
		}

		getTyreCompound(tyre) {
			if this.Data
				try {
					tyre := this.Data["wheelInfo"]["wheelLocs"][inList(["FL", "FR", "RL", "RR"], LMURESTProvider.WheelTypes[tyre])]["compound"]

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
					return (100 * (1 - this.Data["wearables"]["tires"][inList(["FL", "FR", "RL", "RR"], LMURESTProvider.WheelTypes[tyre])]))
				}
				catch Any as exception {
					logError(exception)

					this.reload()
				}

			return false
		}

		getBrakeDiscThickness(tyre) {
			local thickness

			if this.Data
				try {
					thickness := this.Data["wearables"]["brakes"][inList(["FL", "FR", "RL", "RR"], LMURESTProvider.WheelTypes[tyre])]

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

		State {
			Get {
				return this.getState()
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

		getState() {
			local data := this.read("http://localhost:6397/rest/sessions/GetGameState", false)

			if data {
				if (data.Has("teamVehicleState") && (data["teamVehicleState"] = "OTHER TEAMMATE DRIVING"))
					return "Not Driving"
				else if data.Has("MultiStintState") {
					switch data["MultiStintState"], false {
						case "Disabled":
							return "Disabled"
						case "Driving":
							return "Driving"
						default:
							return "Paused"
					}
				}
				else
					return "Paused"
			}
			else
				return "Disabled"
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
				return "http://localhost:6397/rest/garage/summary"
			}
		}

		Track {
			Get {
				return this.getTrack()
			}
		}

		reload() {
			this.iCachedTrack := false

			super.reload()
		}

		getTrack() {
			local id, data, ignore, entry

			if this.iCachedTrack
				return this.iCachedTrack
			else if (this.Data && this.Data.Has("track")) {
				id := this.Data["track"]["id"]

				data := this.read("http://localhost:6397/rest/sessions/getTracksInSeries", false)

				if data
					for ignore, entry in data
						if (entry["id"] = id) {
							this.iCachedTrack := entry["properTrackName"]

						return this.iCachedTrack
					}
			}
			else
				return false
		}
	}

	class TeamData extends LMURESTProvider.RESTData {
		iTeamData := false

		iCachedCar := false
		iCachedTeam := false

		class TeamData extends LMURESTProvider.RESTData {
			iTeamSession := kUndefined

			GETURL {
				Get {
					return "http://localhost:6397/rest/multiplayer/teams"
				}
			}

			TeamSession {
				Get {
					if (this.iTeamSession = kUndefined)
						this.iTeamSession := this.getTeamSession()

					return this.iTeamSession
				}
			}

			Nr[id] {
				Get {
					return this.getNr(id)
				}
			}

			Team[id] {
				Get {
					return this.getTeam(id)
				}
			}

			Drivers[id] {
				Get {
					return this.getDrivers(id)
				}
			}

			getTeamSession(id) {
				local data := this.Data

				return (data && (date != kNull))
			}

			getNr(id) {
				local data := this.Data

				if (data && (date != kNull))
					return data["utid" . (id - 1)]["carNumber"]
				else
					return false
			}

			getTeam(id) {
				local data := this.Data

				if (data && (date != kNull))
					return data["utid" . (id - 1)]["name"]
				else
					return false
			}

			getDrivers(id) {
				local data := this.Data

				if (data && (date != kNull))
					return getKeys(data["utid" . (id - 1)]["drivers"])
				else
					return []
			}
		}

		GETURL {
			Get {
				return "http://localhost:6397/rest/garage/UIScreen/CarSetupOverview"
			}
		}

		TeamData {
			Get {
				if !this.iTeamData
					this.iTeamData := LMURESTProvider.TeamData.TeamData()

				return this.iTeamData
			}
		}

		TeamSession {
			Get {
				return this.TeamData.TeamSession
			}
		}

		Car {
			Get {
				return this.getCar()
			}
		}

		Nr[id?] {
			Get {
				if (isSet(id) && this.TeamData.TeamSession)
					return this.TeamData.Nr[id]
				else
					return this.getNr()
			}
		}

		Team[id?] {
			Get {
				if (isSet(id) && this.TeamData.TeamSession)
					return this.TeamData.Team[id]
				else
					return this.getTeam()
			}
		}

		Drivers[id?] {
			Get {
				if (isSet(id) && this.TeamData.TeamSession)
					return this.TeamData.Drivers[id]
				else
					return SessionDatabase.getUserName()
			}
		}

		reload() {
			this.iCachedCar := false
			this.iCachedTeam := false

			super.reload()
		}

		getNr() {
			return false
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

	class DriversData extends LMURESTProvider.RESTData {
		static sCachedData := false

		iCachedCars := CaseInsenseMap()

		GETURL {
			Get {
				return "http://localhost:6397/rest/sessions/getAllVehicles"
			}
		}

		Data {
			Get {
				if LMURestProvider.DriversData.sCachedData
					return LMURestProvider.DriversData.sCachedData
				else
					return (LMURestProvider.DriversData.sCachedData := super.Data)
			}
		}

		Drivers[carDesc] {
			Get {
				return this.getDrivers(carDesc)
			}
		}

		reload() {
			LMURestProvider.DriversData.sCachedData := false

			this.iCachedCars := CaseInsenseMap()

			super.reload()
		}

		getCarDescriptor(carDesc, retry := true) {
			local ignore, candidate

			carDesc := Trim(carDesc)

			if this.iCachedCars.Has(carDesc)
				return this.iCachedCars[carDesc]
			else if this.Data
				if (carDesc != "")
					for ignore, candidate in this.Data
						if (InStr(candidate["desc"], carDesc) = 1) {
							this.iCachedCars[carDesc] := candidate

							return candidate
						}

			if retry {
				this.reload()

				return this.getCarDescriptor(carDesc, false)
			}
			else
				return false
		}

		findCarDescriptor(car, retry := true) {
			local ignore, path, candidate

			car := Trim(car)

			if this.iCachedCars.Has(car)
				return this.iCachedCars[car]
			else if this.Data
				if (car != "")
					for ignore, candidate in this.Data {
						path := string2Values(",", candidate["fullPathTree"])

						if (car = "Oreca 07 ELMS") {
							if ((Trim(path[path.Length]) = "Oreca 07") && (Trim(path[path.Length - 1]) = "LMP2_ELMS")) {
								this.iCachedCars[car] := candidate

								return candidate
							}
						}
						else if (Trim(path[path.Length]) = car) {
							this.iCachedCars[car] := candidate

							return candidate
						}
					}

			if retry {
				this.reload()

				return this.findCarDescriptor(car, false)
			}
			else
				return false
		}

		getDrivers(carDesc) {
			local index := InStr(carDesc, "Custom Team")
			local result := []
			local ignore, car, driver

			if index
				car := (this.getCarDescriptor(carDesc, false) || this.findCarDescriptor(SubStr(carDesc, 1, index - 1), false))
			else
				car := this.getCarDescriptor(carDesc)

			if car
				try {
					for ignore, driver in car["drivers"]
						if (Trim(driver["name"]) != "")
							result.Push({Name: driver["name"], Category: driver["skill"]})
				}
				catch Any as exception {
					logError(exception)
				}

			return result
		}
	}

	class GridData extends LMURESTProvider.RESTData {
		static sCarData := false

		iCachedCars := CaseInsenseMap()

		class CarData extends LMURESTProvider.RESTData {
			iCachedCars := CaseInsenseMap()

			GETURL {
				Get {
					return "http://localhost:6397/rest/race/car"
				}
			}

			Car[carID] {
				Get {
					return this.getCar(carID)
				}
			}

			getCar(carId) {
				local ignore, candidate, path, car

				if this.iCachedCars.Has(carId) {
					path := string2Values(",", this.iCachedCars[carId]["fullPathTree"])

					car := Trim(path[path.Length])

					if (car = "Oreca 07")
						if (Trim(path[path.Length - 1]) = "LMP2_ELMS")
							car := "Oreca 07 ELMS"

					return car
				}
				else if this.Data
					for ignore, candidate in this.Data
						if (InStr(candidate["id"], carId) = 1) {
							this.iCachedCars[carId] := candidate

							return this.getCar(carId)
						}

				return false
			}
		}

		GETURL {
			Get {
				return "http://localhost:6397/rest/watch/standings"
			}
		}

		CarData {
			Get {
				if !LMURestProvider.GridData.sCarData
					LMURestProvider.GridData.sCarData := LMURESTProvider.GridData.CarData()

				return LMURestProvider.GridData.sCarData
			}
		}

		Id[carDesc] {
			Get {
				return this.getId(carDesc)
			}
		}

		Nr[carDesc] {
			Get {
				return this.getNr(carDesc)
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

		reload() {
			this.iCachedCars := CaseInsenseMap()

			super.reload()
		}

		getCarDescriptor(carDesc) {
			local ignore, candidate

			carDesc := Trim(carDesc)

			if this.iCachedCars.Has(carDesc)
				return this.iCachedCars[carDesc]
			else if this.Data
				if (carDesc != "")
					for ignore, candidate in this.Data
						if (InStr(candidate["vehicleName"], carDesc) = 1) {
							this.iCachedCars[carDesc] := candidate

							return candidate
						}

			return false
		}

		getId(carDesc) {
			local car := this.getCarDescriptor(carDesc)

			return (car ? car["carId"] : false)
		}

		getNr(carDesc) {
			local car := this.getCarDescriptor(carDesc)

			return (car ? car["carNumber"] : false)
		}

		getCar(carDesc) {
			local car := this.getCarDescriptor(carDesc)

			if car
				try {
					car := this.CarData.Car[car["carId"]]

					if !car {
						LMURestProvider.GridData.sCarData := false

						car := this.CarData.Car[car["carId"]]
					}
				}
				catch Any as exception {
					logError(exception)

					car := false
				}

			return car
		}

		getClass(carDesc) {
			local car := this.getCarDescriptor(carDesc)

			return ((car && car.Has("carClass")) ? Trim(car["carClass"]) : false)
		}

		getTeam(carDesc) {
			local car := this.getCarDescriptor(carDesc)

			return ((car && car.Has("fullTeamName")) ? Trim(car["fullTeamName"]) : false)
		}
	}

	class StandingsData extends LMURESTProvider.RESTData {
		iStandings := false
		iDriver := false

		GETURL {
			Get {
				return "http://localhost:6397/rest/watch/standings"
			}
		}

		Count {
			Get {
				if !this.iStandings
					this.getCarDescriptor(1)

				return (this.iStandings ? this.iStandings.Length : false)
			}
		}

		Driver[carID] {
			Get {
				return this.getDriver(carID)
			}
		}

		Class[carID] {
			Get {
				return this.getClass(carID)
			}
		}

		Laps[carID] {
			Get {
				return this.getLaps(carID)
			}
		}

		Position[carID] {
			Get {
				return this.getPosition(carID)
			}
		}

		getCarDescriptor(id) {
			local ignore, car, candidate, standings

			if (!this.iStandings && this.Data) {
				standings := Map()

				for ignore, car in this.Data
					standings[Integer(car["slotID"] + 1)] := car

				this.iStandings := standings
			}

			id := Integer(id)

			return (this.iStandings.Has(id) ? this.iStandings[id] : false)
		}

		getDriver(id) {
			local car := this.getCarDescriptor(id)

			return ((car && car.Has("driverName")) ? car["driverName"] : false)
		}

		getClass(position) {
			local car := this.getCarDescriptor(id)

			return ((car && car.Has("carClass")) ? car["carClass"] : false)
		}

		getLaps(position) {
			local car := this.getCarDescriptor(id)

			return ((car && car.Has("lapsCompleted")) ? car["lapsCompleted"] : false)
		}

		getPosition(position) {
			local car := this.getCarDescriptor(id)

			return ((car && car.Has("position")) ? car["position"] : false)
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

				if (data && data.Has("closeestWeatherNode")) {
					try {
						return Round(data["closeestWeatherNode"]["Humidity"])
					}
					catch Any as exception {
						logError(exception)

						return false
					}
				}
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

					if data.Has(name) {
						try {
							return data[name]["WNV_HUMIDITY"]["currentValue"]
						}
						catch Any as exception {
							logError(exception)

							return false
						}
					}
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

				if (data && data.Has("closeestWeatherNode")) {
					try {
						return this.getWeather(data["closeestWeatherNode"]["RainChance"])
					}
					catch Any as exception {
						logError(exception)

						return false
					}
				}
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

					if data.Has(name) {
						try {
							return this.getWeather(data[name]["WNV_RAIN_CHANCE"]["currentValue"])
						}
						catch Any as exception {
							logError(exception)

							return false
						}
					}
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

				if (data && data.Has("closeestWeatherNode")) {
					try {
						return this.getWeather(data["closeestWeatherNode"]["Sky"])
					}
					catch Any as exception {
						logError(exception)

						return false
					}
				}
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

					if data.Has(name) {
						try {
							return this.getWeather(data[name]["WNV_SKY"]["currentValue"])
						}
						catch Any as exception {
							logError(exception)

							return false
						}
					}
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

	static WheelTypes {
		Get {
			return LMURestProvider.sWheelTypes
		}
	}

	static BrakeTypes {
		Get {
			return LMURestProvider.sBrakeTypes
		}
	}
}