;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LMU Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\SimulatorPlugin.ahk"
#Include "Libraries\LMURESTProvider.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "RF2 Plugin.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kLMUApplication := "Le Mans Ultimate"

global kLMUPlugin := "LMU"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class LMUPlugin extends Sector397Plugin {
	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("NoRefuel", "No Refuel", "Refuel", "Refuel"
								   , "TyreCompound", "Tyre Compound"
								   , "TyreCompoundFrontLeft", "Tyre Compound Front Left", "TyreCompoundFrontRight", "Tyre Compound Front Right"
								   , "TyreCompoundRearLeft", "Tyre Compound Rear Left", "TyreCompoundRearRight", "Tyre Compound Rear Right"
								   , "TyreAllAround", "All Around"
								   , "TyreFrontLeft", "Front Left", "TyreFrontRight", "Front Right", "TyreRearLeft", "Rear Left", "TyreRearRight", "Rear Right"
								   , "BodyworkRepair", "Repair Bodywork", "SuspensionRepair", "Repair Suspension"
								   , "BrakeChange", "Change Brakes", "DriverSelect", "Driver", "PitstopRequest", "Pitstop")

		selectActions := []
	}

	supportsSetupImport() {
		return true
	}

	getOptionHandler(option) {
		return (operation, value?) {
			local pitstop := LMURESTProvider.PitstopData(this.Simulator[true], this.Car, this.Track)
			local compound, code, tyre, found, tyreCompound, tyreCompoundColor, cTyreCompound, cTyreCompoundColor

			switch option, false {
				case "Refuel":
					switch operation, false {
						case "Get":
							return pitstop.getRefuelAmount()
						case "Set":
							pitstop.setRefuelAmount(value)
						case "Change":
							pitstop.changeRefuelAmount(value)
					}
				case "Tyre Compound", "Tyre Compound Front Left", "Tyre Compound Front Right"
									, "Tyre Compound Rear Left", "Tyre Compound Rear Right":
					if (option = "Tyre Compound")
						tyre := "All"
					else
						tyre := StrReplace(option, "Tyre Compound ", "")

					switch operation, false {
						case "Get":
							compound := SessionDatabase.getTyreCompoundName(this.Simulator[true], this.Car, this.Track
																		  , pitstop.getTyreCompound(tyre), kUndefined)

							return ((compound = kUndefined) ? normalizeCompound("Dry") : compound)
						case "Set":
							if value {
								code := SessionDatabase.getTyreCompoundCode(this.Simulator[true], this.Car, this.Track, value, kUndefined)
								found := false

								if (code = kUndefined)
									try
										code := SessionDatabase.getTyreCompounds(this.Simulator[true], this.Car, this.Track, true)[1]

								if !pitstop.setTyreCompound(tyre, code) {
									splitCompound(value, &tyreCompound, &tyreCompoundColor)

									for ignore, candidate in SessionDatabase.getTyreCompounds(this.Simulator[true], this.Car, this.Track) {
										splitCompound(candidate, &cTyreCompound, &cTyreCompoundColor)

										if (tyreCompound = cTyreCompound) {
											code := SessionDatabase.getTyreCompoundCode(this.Simulator[true], this.Car, this.Track, candidate)

											if pitstop.setTyreCompound(tyre, code) {
												found := true

												break
											}
										}
									}

									if !found {
										try
											code := SessionDatabase.getTyreCompounds(this.Simulator[true], this.Car, this.Track, true)[1]

										pitstop.setTyreCompound(tyre, code)
									}
								}
							}
							else
								pitstop.setTyreCompound(tyre, false)
						case "Change":
							pitstop.changeTyreCompound(tyre, value)
					}
				case "Front Left", "Front Right", "Rear Left", "Rear Right":
					switch operation, false {
						case "Get":
							return pitstop.getTyrePressure(option)
						case "Set":
							pitstop.setTyrePressure(option, value)
						case "Change":
							pitstop.changeTyrePressure(option, value)
					}
				case "Repair Bodywork":
					switch operation, false {
						case "Get":
							pitstop.getRepairs(&value, &ignore, &ignore)

							return value
						case "Set":
							pitstop.setRepairs(value, pitstop.RepairSuspension, pitstop.RepairEngine)
						case "Change":
							if (value < 0)
								pitstop.setRepairs(false, pitstop.RepairSuspension, pitstop.RepairEngine)
							else if (value < 0)
								pitstop.setRepairs(true, pitstop.RepairSuspension, pitstop.RepairEngine)
					}
				case "Repair Bodywork":
					switch operation, false {
						case "Get":
							pitstop.getRepairs(&ignore, &value, &ignore)

							return value
						case "Set":
							pitstop.setRepairs(pitstop.RepairBodywork, value, pitstop.RepairEngine)
						case "Change":
							if (value < 0)
								pitstop.setRepairs(pitstop.RepairBodywork, false, pitstop.RepairEngine)
							else if (value < 0)
								pitstop.setRepairs(pitstop.RepairBodywork, true, pitstop.RepairEngine)
					}
				case "Repair Engine":
					if pitstop.supportsEngineRepair()
						switch operation, false {
							case "Get":
								pitstop.getRepairs(&ignore, &ignore, &value)

								return value
							case "Set":
								pitstop.setRepairs(pitstop.RepairBodywork, pitstop.RepairSuspension, value)
							case "Change":
								if (value < 0)
									pitstop.setRepairs(pitstop.RepairBodywork, pitstop.RepairSuspension, false)
								else if (value < 0)
									pitstop.setRepairs(pitstop.RepairBodywork, pitstop.RepairSuspension, true)
						}
					else
						return false
				case "Change Brakes":
					switch operation, false {
						case "Get":
							return pitstop.getBrakeChange()
						case "Set":
							pitstop.setBrakeChange(value)
						case "Change":
							if (value < 0)
								pitstop.setBrakeChange(false)
							else if (value > 0)
								pitstop.setBrakeChange(true)
					}
				case "Driver":
					if pitstop.supportsDriverSwap() {
						switch operation, false {
							case "Get":
								return pitstop.getDriver()
							case "Set":
								pitstop.setDriver(value)
							case "Change":
								pitstop.changeDriver(value)
						}
					}
					else
						return SessionDatabase.getDriverName(this.Simulator[true], SessionDatabase.ID)
			}

			pitstop.write()
		}
	}

	getPitstopOptionValues(option) {
		local data, compound, compoundColor

		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option, false {
				case "Refuel":
					return [this.getOptionHandler(option).Call("Get")]
				case "Tyre Pressures":
					return [this.getOptionHandler("Front Left").Call("Get"), this.getOptionHandler("Front Right").Call("Get")
						  , this.getOptionHandler("Rear Left").Call("Get"), this.getOptionHandler("Rear Right").Call("Get")]
				case "Tyre Compound", "TyreCompound":
					compound := this.getOptionHandler("Tyre Compound").Call("Get")

					if compound
						splitCompound(compound, &compound, &compoundColor := false)

					return [compound, compoundColor]
				case "Repair Suspension", "Repair Bodywork", "Repair Engine":
					return [this.getOptionHandler(option).Call("Get")]
				case "Change Brakes":
					return [this.getOptionHandler(option).Call("Get")]
				case "Driver":
					return [this.getOptionHandler(option).Call("Get")]
				default:
					return super.getPitstopOptionValues(option)
			}
		}
		else
			return false
	}

	dialPitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off")
			if (action = "Increase")
				this.getOptionHandler(option).Call("Change", steps)
			else if (action = "Decrease")
				this.getOptionHandler(option).Call("Change", - steps)
			else
				throw "Unsupported change operation `"" . action . "`" detected in LMUPlugin.dialPitstopOption..."
	}

	setPitstopOption(option, value) {
		if (this.OpenPitstopMFDHotkey != "Off")
			this.getOptionHandler(option).Call("Set", value)
	}

	changePitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option, false {
				case "Pitstop":
					if this.RequestPitstopHotKey {
						this.activateWindow()

						this.sendCommand(this.RequestPitstopHotKey)
					}
				case "Refuel":
					this.dialPitstopOption(option, action, steps)
				case "No Refuel":
					this.dialPitstopOption("Refuel", "Decrease", 250)
				case "Tyre Compound", "Tyre Compound Front Left", "Tyre Compound Front Right"
									, "Tyre Compound Rear Left", "Tyre Compound Rear Right":
					this.dialPitstopOption(option, action, steps)
				case "All Around":
					this.dialPitstopOption("Front Left", action, steps)
					this.dialPitstopOption("Front Right", action, steps)
					this.dialPitstopOption("Rear Left", action, steps)
					this.dialPitstopOption("Rear Right", action, steps)
				case "Front Left", "Front Right", "Rear Left", "Rear Right":
					this.dialPitstopOption(option, action, steps)
				case "Repair Bodywork", "Repair Suspension", "Repair Engine":
					this.dialPitstopOption(option, action, steps)
				case "Change Brakes":
					this.dialPitstopOption("Change Brakes", action, steps)
				case "Driver":
					this.dialPitstopOption("Driver", action, steps)
				default:
					throw "Unsupported change operation `"" . action . "`" detected in LMUPlugin.changePitstopOption..."
			}
		}
	}

	setPitstopRefuelAmount(pitstopNumber, liters) {
		super.setPitstopRefuelAmount(pitstopNumber, liters)

		if (this.OpenPitstopMFDHotkey != "Off")
			this.setPitstopOption("Refuel", liters)
	}

	setPitstopTyreSet(pitstopNumber, tyreCompound, tyreCompoundColor := false, set := false) {
		super.setPitstopTyreSet(pitstopNumber, tyreCompound, tyreCompoundColor, set)

		if (this.OpenPitstopMFDHotkey != "Off")
			this.setPitstopOption("Tyre Compound", compound ? compound(tyreCompound, tyreCompoundColor) : false)
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		local pressures, pressureFLIncrement, pressureFRIncrement, pressureRLIncrement, pressureRRIncrement, finished

		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.setPitstopOption("Front Left", pressureFL)
			this.setPitstopOption("Front Right", pressureFR)
			this.setPitstopOption("Rear Left", pressureRL)
			this.setPitstopOption("Rear Right", pressureRR)
		}
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		super.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.setPitstopOption("Repair Suspension", repairSuspension)
			this.setPitstopOption("Repair Bodywork", repairBodywork)
			this.setPitstopOption("Repair Engine", repairEngine)
		}
	}

	requestPitstopDriver(pitstopNumber, driver) {
		if (this.OpenPitstopMFDHotkey != "Off")
			this.setPitstopOption("Driver", driver)
	}

	parseCategory(candidate, &rest) {
		super.parseCategory(candidate, &rest)

		return false
	}

	parseCarName(carName, &model?, &nr?, &category?, &team?) {
		static gridData := LMURESTProvider.GridData(this.Simulator[true], this.Car, this.Track)

		model := gridData.Car[carName]

		if !model {
			gridData := LMURESTProvider.GridData(this.Simulator[true], this.Car, this.Track)

			model := gridData.Car[carName]
		}

		team := gridData.Team[carName]

		if ((carName != "") && isNumber(SubStr(carName, 1, 1)))
			nr := this.parseNr(carName, &carName)
		else
			super.parseCarName(carName, , &nr)

		try {
			category := gridData.Drivers[carName][1].Category
		}
		catch Any {
			category := false
		}
	}

	parseDriverName(carName, forName, surName, nickName) {
		local driver

		static gridData := LMURESTProvider.GridData(this.Simulator[true], this.Car, this.Track)

		try {
			driver := gridData.Drivers[carName][1]
		}
		catch Any {
			driver := false
		}

		return (driver ? driver.Name : super.parseDriverName(carName, forName, surName, nickName))
	}

	readSessionData(options := "", protocol?) {
		local simulator := this.Simulator[true]
		local car := this.Car
		local track := this.Track
		local data, setupData, tyreCompound, tyreCompoundColor, key, postFix

		static keys := Map("All", "", "Front Left", "FrontLeft", "Front Right", "FrontRight"
									, "Rear Left", "RearLeft", "Rear Right", "RearRight")

		if InStr(options, "Setup=true") {
			setupData := LMURESTProvider.PitstopData(simulator, car, track)
			data := newMultiMap()

			setMultiMapValue(data, "Setup Data", "FuelAmount", setupData.RefuelAmount)

			for key, postFix in keys {
				tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, setupData.TyreCompound[key], false)

				if tyreCompound {
					splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

					setMultiMapValue(data, "Setup Data", "TyreCompound" . postFix, tyreCompound)
					setMultiMapValue(data, "Setup Data", "TyreCompoundColor" . postFix, tyreCompoundColor)
				}
			}

			setMultiMapValue(data, "Setup Data", "TyrePressureFL", setupData.TyrePressure["Front Left"])
			setMultiMapValue(data, "Setup Data", "TyrePressureFR", setupData.TyrePressure["Front Right"])
			setMultiMapValue(data, "Setup Data", "TyrePressureRL", setupData.TyrePressure["Rear Left"])
			setMultiMapValue(data, "Setup Data", "TyrePressureRR", setupData.TyrePressure["Rear Right"])

			setupData := LMURESTProvider.PitstopData(simulator, car, track)

			setMultiMapValue(data, "Setup Data", "RepairBodywork", setupData.RepairBodywork)
			setMultiMapValue(data, "Setup Data", "RepairSuspension", setupData.RepairSuspension)
			setMultiMapValue(data, "Setup Data", "RepairEngine", setupData.RepairEngine)
		}
		else {
			data := super.readSessionData(options, protocol?)

			for key, postFix in keys {
				tyreCompound := getMultiMapValue(data, "Car Data", "TyreCompound" . postFix, kUndefined)

				if (tyreCompound = kUndefined) {
					tyreCompound := getMultiMapValue(data, "Car Data", "TyreCompoundRaw" . postFix, kUndefined)

					if ((tyreCompound != kUndefined) && tyreCompound) {
						tyreCompound := SessionDatabase.getTyreCompoundName(simulator, car, track, tyreCompound, false)

						if tyreCompound {
							splitCompound(tyreCompound, &tyreCompound, &tyreCompoundColor)

							setMultiMapValue(data, "Car Data", "TyreCompound" . postFix, tyreCompound)
							setMultiMapValue(data, "Car Data", "TyreCompoundColor" . postFix, tyreCompoundColor)

							if (postfix = "Front") {
								setMultiMapValue(data, "Car Data", "TyreCompoundFrontLeft" . postFix, tyreCompound)
								setMultiMapValue(data, "Car Data", "TyreCompoundColorFrontLeft" . postFix, tyreCompoundColor)
								setMultiMapValue(data, "Car Data", "TyreCompoundFrontRight" . postFix, tyreCompound)
								setMultiMapValue(data, "Car Data", "TyreCompoundColorFrontRight" . postFix, tyreCompoundColor)
							}
							else if (postfix = "Rear") {
								setMultiMapValue(data, "Car Data", "TyreCompoundRearLeft" . postFix, tyreCompound)
								setMultiMapValue(data, "Car Data", "TyreCompoundColorRearLeft" . postFix, tyreCompoundColor)
								setMultiMapValue(data, "Car Data", "TyreCompoundRearRight" . postFix, tyreCompound)
								setMultiMapValue(data, "Car Data", "TyreCompoundColorRearRight" . postFix, tyreCompoundColor)
							}
						}
					}
				}
			}
		}

		return data
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startLMU() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kLMUPlugin).Simulator
													 , "Simulator Splash Images\LMU Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeLMUPlugin() {
	local controller := SimulatorController.Instance

	LMUPlugin(controller, kLMUPlugin, kLMUApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeLMUPlugin()
