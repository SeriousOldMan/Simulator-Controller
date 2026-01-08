;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LMU Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Math.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "Libraries\SimulatorPlugin.ahk"
#Include "Libraries\LMURESTProvider.ahk"
#Include "Libraries\LMUProvider.ahk"
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
	iLastFuelAmount := 0
	iRemainingFuelAmount := 0

	iFuelLevels := []
	iVirtualEnergyLevels := []

	iAdjustRefuelAmount := false

	class LMUProvider extends LMUProvider {
		iPlugin := false

		__New(plugin, car, track) {
			this.iPlugin := plugin

			super.__New(car, track)
		}

		getRefuelAmount(setupData) {
			return this.iPlugin.getOptionHandler("Refuel").Call("Get", , setupData)
		}
	}

	createSimulatorProvider() {
		return LMUPlugin.LMUProvider(this, this.Car, this.Track)
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("NoRefuel", "No Refuel", "Refuel", "Refuel"
								   , "TyreCompound", "Tyre Compound"
								   , "TyreCompoundFrontLeft", "Tyre Compound Front Left", "TyreCompoundFrontRight", "Tyre Compound Front Right"
								   , "TyreCompoundRearLeft", "Tyre Compound Rear Left", "TyreCompoundRearRight", "Tyre Compound Rear Right"
								   , "TyreAllAround", "All Around"
								   , "TyreFrontLeft", "Front Left", "TyreFrontRight", "Front Right", "TyreRearLeft", "Rear Left", "TyreRearRight", "Rear Right"
								   , "BodyworkRepair", "Repair Bodywork", "SuspensionRepair", "Repair Suspension"
								   , "BrakeChange", "Change Brakes", "DriverSelect", "Driver", "PitstopRequest", "RequestPitstop")

		selectActions := []
	}

	updateRaceAssistantActions(session) {
		local ignore, theAction

		super.updateRaceAssistantActions(session)

		for ignore, theAction in this.Actions
			if (isInstance(theAction, RaceAssistantPlugin.RaceAssistantAction) && (theAction.Action = "FuelRatioOptimize")) {
			 	theAction.Function.enable(kAllTrigger, theAction)
				theAction.Function.setLabel(this.actionLabel(theAction))
			}
	}

	supportsSetupImport() {
		return true
	}

	getOptionHandler(option) {
		return (operation, value?, pitstop := false, initial := true) {
			local simulator := this.Simulator[true]
			local car := this.Car
			local track := this.Track
			local write := true
			local code, tyre, found, tyreCompound, tyreCompoundColor, cTyreCompound, cTyreCompoundColor

			if !pitstop
				pitstop := LMURESTProvider.PitstopData(simulator, car, track)
			else
				write := false

			switch option, false {
				case "Refuel":
					switch operation, false {
						case "Get":
							return (pitstop.getRefuelLevel() - (this.iRemainingFuelAmount ? this.iRemainingFuelAmount
																						  : this.iLastFuelAmount))
						case "Set":
							if initial
								this.iRemainingFuelAmount := this.iLastFuelAmount

							if isDebug()
								logMessage(kLogDebug, (initial ? "Initial" : "Updated") . " fuel plan - Remaining: " . Round(this.iLastFuelAmount, 1) . "; Refuel: " . Round(value, 1))

							pitstop.setRefuelLevel(value + this.iRemainingFuelAmount)
						case "Change":
							pitstop.changeRefuelLevel(value)
					}
				case "Tyre Compound", "Tyre Compound Front Left", "Tyre Compound Front Right"
									, "Tyre Compound Rear Left", "Tyre Compound Rear Right":
					if (option = "Tyre Compound")
						tyre := "All"
					else
						tyre := StrReplace(option, "Tyre Compound ", "")

					switch operation, false {
						case "Get":
							tyreCompound := pitstop.getTyreCompound(tyre)

							if tyreCompound
								tyreCompound := SessionDatabase.getTyreCompoundName(this.Simulator[true]
																				  , this.Car, this.Track
																				  , tyreCompound, kUndefined)

							return ((tyreCompound = kUndefined) ? normalizeCompound("Dry") : tyreCompound)
						case "Set":
							if value {
								code := SessionDatabase.getTyreCompoundCode(this.Simulator[true]
																		  , this.Car, this.Track, value, kUndefined)
								found := false

								if (code = kUndefined)
									try
										code := SessionDatabase.getTyreCompounds(this.Simulator[true]
																			   , this.Car, this.Track, true)[1]

								if !pitstop.setTyreCompound(tyre, code) {
									splitCompound(value, &tyreCompound, &tyreCompoundColor)

									for ignore, candidate in SessionDatabase.getTyreCompounds(this.Simulator[true]
																							, this.Car, this.Track) {
										splitCompound(candidate, &cTyreCompound, &cTyreCompoundColor)

										if (tyreCompound = cTyreCompound) {
											code := SessionDatabase.getTyreCompoundCode(this.Simulator[true]
																					  , this.Car, this.Track, candidate)

											if pitstop.setTyreCompound(tyre, code) {
												found := true

												break
											}
										}
									}

									if !found {
										try
											code := SessionDatabase.getTyreCompounds(this.Simulator[true]
																				   , this.Car, this.Track, true)[1]

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
				case "Repair Suspension":
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

			if ((operation != "Get") && write)
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
					compoundColor := false

					if compound
						splitCompound(compound, &compound, &compoundColor)

					return [compound, compoundColor]
				case "Tyre Compound Front Left", "TyreCompoundFrontLeft":
					compound := this.getOptionHandler("Tyre Compound Front Left").Call("Get")
					compoundColor := false

					if compound
						splitCompound(compound, &compound, &compoundColor)

					return [compound, compoundColor]
				case "Tyre Compound Front Right", "TyreCompoundFrontRight":
					compound := this.getOptionHandler("Tyre Compound Front Right").Call("Get")
					compoundColor := false

					if compound
						splitCompound(compound, &compound, &compoundColor)

					return [compound, compoundColor]
				case "Tyre Compound Rear Left", "TyreCompoundRearLeft":
					compound := this.getOptionHandler("Tyre Compound Rear Left").Call("Get")
					compoundColor := false

					if compound
						splitCompound(compound, &compound, &compoundColor)

					return [compound, compoundColor]
				case "Tyre Compound Rear Right", "TyreCompoundRearRight":
					compound := this.getOptionHandler("Tyre Compound Rear Right").Call("Get")
					compoundColor := false

					if compound
						splitCompound(compound, &compound, &compoundColor)

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

	notifyPitstopChanged(option) {
		super.notifyPitstopChanged((option = "No Refuel") ? "Refuel" : option)
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

	setPitstopOption(option, value, pitstop := false) {
		if (this.OpenPitstopMFDHotkey != "Off")
			this.getOptionHandler(option).Call("Set", value, pitstop)
	}

	changePitstopOption(option, action := "Increase", steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option, false {
				case "RequestPitstop":
					if (this.RequestPitstopHotKey && (steps > 0)) {
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

	getConsumptions(&virtualEnergy, &fuel) {
		computeConsumption(series) {
			local values := []

			loop series.Length
				if (A_Index > 1)
					values.Push(series[A_Index - 1] - series[A_Index])

			return average(values)
		}

		virtualEnergy := computeConsumption(this.iVirtualEnergyLevels)
		fuel := computeConsumption(this.iFuelLevels)
	}

	addLap(lap, data) {
		super.addLap(lap, data)

		this.iLastFuelAmount := getMultiMapValue(data, "Car Data", "FuelRemaining", 0)

		this.iFuelLevels.Push(this.iLastFuelAmount)
		this.iVirtualEnergyLevels.Push(LMURESTProvider.EnergyData(this.Simulator[true], this.Car, this.Track).RemainingVirtualEnergy)

		while (this.iFuelLevels.Length > 10) {
			this.iFuelLevels.RemoveAt(1)
			this.iVirtualEnergyLevels.RemoveAt(1)
		}

		if (this.iAdjustRefuelAmount && !getMultiMapValue(data, "Stint Data", "InPitLane", false)
									 && !getMultiMapValue(data, "Stint Data", "InPit", false))
			Task.startTask(() {
				local handler := this.getOptionHandler("Refuel")
				local ignore, fuelConsumption

				this.getConsumptions(&ignore, &fuelConsumption)

				handler.Call("Set", handler.Call("Get") - fuelConsumption, false, false)
			}, 1000, kLowPriority)

		if getMultiMapValue(this.Settings, "Simulator.Le Mans Ultimate", "Pitstop.Fuel.Ratio", false)
			Task.startTask(ObjBindMethod(this, "optimizeFuelRatio"), 2000, kLowPriority)
	}

	optimizeFuelRatio(safetyFuel?) {
		local pitstop, energyConsumption, fuelConsumption

		this.getConsumptions(&energyConsumption, &fuelConsumption)

		if !isSet(safetyFuel)
			safetyFuel := getMultiMapValue(this.Settings, "Session Settings", "Fuel.SafetyMargin", 4)

		if (energyConsumption && fuelConsumption) {
			pitstop := LMURESTProvider.PitstopData(this.Simulator[true], this.Car, this.Track)

			pitstop.setFuelRatio(((100 / energyConsumption * fuelConsumption) + safetyFuel) / 100)

			pitstop.write()
		}
	}

	performPitstop(lapNumber, options) {
		super.performPitstop(lapNumber, options)

		this.iRemainingFuelAmount := 0
		this.iLastFuelAmount := 0

		this.iFuelLevels := []
		this.iVirtualEnergyLevels := []

		this.iAdjustRefuelAmount := false
	}

	setPitstopRefuelAmount(pitstopNumber, liters, fillUp) {
		super.setPitstopRefuelAmount(pitstopNumber, liters, fillUp)

		if (this.OpenPitstopMFDHotkey != "Off") {
			if !fillUp
				this.iAdjustRefuelAmount := getMultiMapValue(this.Settings, "Simulator.Le Mans Ultimate", "Pitstop.Energy.Adjust", false)

			this.setPitstopOption("Refuel", liters)
		}
	}

	setPitstopTyreCompound(pitstopNumber, tyreCompound, tyreCompoundColor := false, set := false) {
		local index, tyre, pitstop

		super.setPitstopTyreCompound(pitstopNumber, tyreCompound, tyreCompoundColor, set)

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.setPitstopOption("Tyre Compound", false)

			if InStr(tyreCompound, ",") {
				tyreCompound := string2Values(",", tyreCompound)
				tyreCompoundColor := string2Values(",", tyreCompoundColor)

				combineCompounds(&tyreCompound, &tyreCompoundColor)

				if (tyreCompound.Length = 1)
					this.setPitstopOption("Tyre Compound"
										, tyreCompound[1] ? compound(tyreCompound[1], tyreCompoundColor[1]) : false)
				else {
					this.setPitstopOption("Tyre Compound", false)

					for index, tyre in ["Front Left", "Front Right", "Rear Left", "Rear Right"]
						this.setPitstopOption("Tyre Compound " . tyre
											, tyreCompound[index] ? compound(tyreCompound[index], tyreCompoundColor[index])
																  : false)
				}
			}
			else
				this.setPitstopOption("Tyre Compound", tyreCompound ? compound(tyreCompound, tyreCompoundColor) : false)
		}
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		local pressures, pressureFLIncrement, pressureFRIncrement, pressureRLIncrement, pressureRRIncrement, finished
		local pitstop

		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if (this.OpenPitstopMFDHotkey != "Off") {
			pitstop := LMURESTProvider.PitstopData(this.Simulator[true], this.Car, this.Track)

			this.setPitstopOption("Front Left", pressureFL, pitstop)
			this.setPitstopOption("Front Right", pressureFR, pitstop)
			this.setPitstopOption("Rear Left", pressureRL, pitstop)
			this.setPitstopOption("Rear Right", pressureRR, pitstop)

			pitstop.write()
		}
	}

	setPitstopBrakeChange(pitstopNumber, change, frontBrakePads := false, rearBrakePads := false) {
		super.setPitstopBrakeChange(pitstopNumber, change, frontBrakePads, rearBrakePads)

		if (this.OpenPitstopMFDHotkey != "Off")
			this.setPitstopOption("Change Brakes", change)
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
		local nextDriver, currentDriver, delta

		if (this.OpenPitstopMFDHotkey != "Off")
			this.getOptionHandler("Driver").Call("Set", string2Values(":", string2Values("|", driver)[2])[1])
	}

	finishPitstopSetup(pitstopNumber) {
		super.finishPitstopSetup(pitstopNumber)

		if getMultiMapValue(this.Settings, "Simulator.Le Mans Ultimate", "Pitstop.Request", false)
			this.changePitstopOption("RequestPitstop")
	}

	updateSession(session, force := false) {
		super.updateSession(session, force)

		if (session == kSessionFinished) {
			this.iLastFuelAmount := 0
			this.iRemainingFuelAmount := 0

			this.iFuelLevels := []
			this.iVirtualEnergyLevels := []

			this.iAdjustRefuelAmount := false
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startLMU(executable := false) {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kLMUPlugin).Simulator
													 , "Simulator Splash Images\LMU Splash.jpg"
													 , executable)
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