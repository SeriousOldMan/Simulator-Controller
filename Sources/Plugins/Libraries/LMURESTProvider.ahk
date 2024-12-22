;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LMU REST Provider               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"
#Include "..\..\Libraries\HTTP.ahk"
#Include "..\..\Libraries\JSON.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class LMURestProvider {
	class RESTData {
		iSimulator := false
		iCar := false
		iTrack = false

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
				if !this.iData
					this.read()

				return this.iData
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
			}
			catch Any as exception {
				logError(exception, true)
			}
		}

		write() {
			if this.Data
				try {
					WinHttpRequest().PUT(this.PUTURL, JSON.print(this.Data), false, {Object: true, Encoding: "UTF-8"})
				}
				catch Any as exception {
					logError(exception, true)
				}
		}

		lookup(data, name) {
			local ignore, candidate

			if this.iCachedObjects.Has(name)
				return this.iCachedObjects[name]
			else if this.Data {
				for ignore, candidate in this.Data
					if (candidate.Has(name) && (candidate[name] = name)) {
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
				return this.setRefuelAmount(value)
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
		}

		setRefuelAmount(liters) {
		}

		changeRefuelAmount(steps := 1) {
		}

		getTyreCompound(tyre) {
		}

		setTyreCompound(tyre, code) {
		}

		changeTyreCompound(tyre, steps := 1) {
		}

		getTyrePressure(tyre) {
		}

		setTyrePressure(tyre, code) {
		}

		changeTyrePressure(tyre, steps := 1) {
		}

		getRepairs(&bodywork, &suspension, &engine) {
		}

		setRepairs(bodywork, suspension, engine) {
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
				index := (inThreeStates(this.RepairBodywork, this.RepairSuspension, this.RepairEngine) + steps)

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
				index := (inTwoStates(this.RepairBodywork, this.RepairSuspension) + steps)

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
		}

		setBrakeChange(change) {
		}

		getDriver() {
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

					return SessionDatabase.getTyreCompounds(this.Simulator, this.Car, this.Track)[carSetup["WM_COMPOUND-W_FL"]["value"] + 1]
				}
				catch Any as exception {
					logError(exception)

					return SessionDatabase.getTyreCompounds(this.Simulator, this.Car, this.Track)[1]
				}
			}
			else
				return false
		}

		getTyrePressure(tyre) {
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

		getCarDescriptor(carID) {
			local ignore, candidate

			if this.iCachedCars.Has(carID)
				return this.iCachedCars[carID]
			else if this.Data {
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

			return (car ? string2Values(",", car["fullTreePath"])[3] : false)
		}

		getClass(carID) {
			local car := this.getCarDescriptor(carID)

			return (car ? string2Values(",", car["fullTreePath"])[2] : false)
		}

		getTeam(carID) {
			local car := this.getCarDescriptor(carID)

			return (car ? car["team"] : false)
		}
	}
}