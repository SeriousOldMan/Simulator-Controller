;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - RF2 Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\SimulatorPlugin.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kRF2Application := "rFactor 2"

global kRF2Plugin := "RF2"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class Sector397Plugin extends RaceAssistantSimulatorPlugin {
	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false
	iRequestPitstopHotkey := false

	OpenPitstopMFDHotkey {
		Get {
			return this.iOpenPitstopMFDHotkey
		}
	}

	ClosePitstopMFDHotkey {
		Get {
			return this.iClosePitstopMFDHotkey
		}
	}

	RequestPitstopHotkey {
		Get {
			return this.iRequestPitstopHotkey
		}
	}

	__New(controller, name, simulator, configuration := false) {
		super.__New(controller, name, simulator, configuration)

		if (this.Active || (isDebug() && isDevelopment())) {
			if !inList(A_Args, "-Replay")
				this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
			else
				this.iOpenPitstopMFDHotkey := "Off"

			this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)

			this.iRequestPitstopHotkey := this.getArgumentValue("requestPitstop", false)

			if this.RequestPitstopHotkey {
				this.iRequestPitstopHotkey := Trim(this.RequestPitstopHotkey)

				if (this.RequestPitstopHotkey = "")
					this.iRequestPitstopHotkey := false
			}
		}
	}

	openPitstopMFD(descriptor := false) {
	}

	closePitstopMFD() {
	}

	requirePitstopMFD() {
		return true
	}

	selectPitstopOption(option) {
		local actions := false
		local ignore := false
		local candidate

		this.getPitstopActions(&actions, &ignore)

		for ignore, candidate in actions
			if (candidate = option)
				return true

		return false
	}

	supportsPitstop() {
		return true
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

	parseCarName(carName, &model?, &nr?, &category?, &team?) {
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
	}

	parseDriverName(carName, forName, surName, nickName) {
		return driverName(forName, surName, nickName)
	}

	acquirePositionsData(telemetryData, finished := false) {
		local positionsData := super.acquirePositionsData(telemetryData, finished)
		local driver := getMultiMapValue(positionsData, "Position Data", "Driver.Car", 0)
		local numbers := Map()
		local duplicateNrs := false
		local carRaw, carID, model, category, nr, forName, surName, nickName

		loop getMultiMapValue(positionsData, "Position Data", "Car.Count", 0) {
			carRaw := getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".CarRaw", kUndefined)

			if (carRaw != kUndefined) {
				this.parseCarName(carRaw, &model, &nr, &category)

				if model
					setMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Car", model)

				if (A_Index != driver) {
					parseDriverName(this.parseDriverName(carRaw, getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Driver.Forname", "")
															   , getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Driver.Surname", "")
															   , getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Driver.Nickname", ""))
								  , &forName, &surName, &nickName)

					setMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Driver.Forname", forName)
					setMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Driver.Surname", surName)
					setMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Driver.Nickname", nickName)
				}

				nr := Integer(nr ? nr : getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".ID"))

				setMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Nr", nr)

				if category
					setMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Category", category)

				if numbers.Has(nr)
					duplicateNrs := true
				else
					numbers[nr] := true
			}
		}

		if duplicateNrs
			loop getMultiMapValue(positionsData, "Position Data", "Car.Count", 0) {
				carID := getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".ID", kUndefined)

				if (carID != kUndefined)
					setMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Nr", carID)
			}

		return positionsData
	}

	acquireTelemetryData() {
		local telemetryData := super.acquireTelemetryData()
		local model, forName, surName, nickName

		static lastSimulator := false
		static lastCar := false
		static lastTrack := false

		static loadSetup := false
		static nextSetupUpdate := false

		if ((this.Simulator[true] != lastSimulator) || (this.Car != lastCar) || (this.Track != lastTrack)) {
			lastSimulator := this.Simulator[true]
			lastCar := this.Car
			lastTrack := this.Track

			loadSetup := SettingsDatabase().readSettingValue(lastSimulator, lastCar, lastTrack, "*"
														   , "Simulator." . this.Simulator[true], "Session.Data.Setup"
														   , (lastSimulator = "Le Mans Ultimate") ? 20 : 60)
		}

		this.parseCarName(getMultiMapValue(telemetryData, "Session Data", "CarRaw"), &model)

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

	updateTelemetryData(data) {
		super.updateTelemetryData(data)

		if !getMultiMapValue(data, "Stint Data", "InPit", false)
			if (getMultiMapValue(data, "Car Data", "FuelRemaining", 0) = 0)
				setMultiMapValue(data, "Session Data", "Paused", true)
	}
}

class RF2Plugin extends Sector397Plugin {
	iSelectedDriver := false

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("NoRefuel", "No Refuel", "Refuel", "Refuel", "TyreCompound", "Tyre Compound", "TyreAllAround", "All Around"
								   , "TyreFrontLeft", "Front Left", "TyreFrontRight", "Front Right", "TyreRearLeft", "Rear Left", "TyreRearRight", "Rear Right"
								   , "DriverSelect", "Driver", "RepairRequest", "Repair", "PitstopRequest", "Pitstop")

		selectActions := []
	}

	sendPitstopCommand(command, operation, message, arguments*) {
		local simulator, exePath

		if (this.OpenPitstopMFDHotkey != "Off") {
			simulator := this.Code
			exePath := (kBinariesDirectory . "Connectors\" . simulator . " SHM Connector.dll")

			try {
				callSimulator(simulator, command . "=" . operation . "=" . message . ":" . values2String(";", arguments*), "CLR")
			}
			catch Any as exception {
				logError(exception, true)

				logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: simulator, protocol: "SHM"})
									   . exePath . translate(") - please rebuild the applications in the binaries folder (")
									   . kBinariesDirectory . translate(")"))

				if !kSilentMode
					showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
												  , {exePath: exePath, simulator: simulator, protocol: "SHM"})
							  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}

	openPitstopMFD(descriptor := false) {
		static reported := false

		if this.OpenPitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off") {
				if this.activateWindow() {
					this.sendCommand(this.OpenPitstopMFDHotkey)

					return true
				}
				else
					return false
			}
			else
				return false
		}
		else if !reported {
			reported := true

			logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))

			if !kSilentMode
				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)

			return false
		}
	}

	closePitstopMFD() {
		static reported := false

		if this.ClosePitstopMFDHotkey {
			if (this.OpenPitstopMFDHotkey != "Off")
				if this.activateWindow()
					this.sendCommand(this.ClosePitstopMFDHotkey)
		}
		else if !reported {
			reported := true

			logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))

			if !kSilentMode
				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
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
					this.sendPitstopCommand("Pitstop", action, "Refuel", Round(steps))
				case "No Refuel":
					this.sendPitstopCommand("Pitstop", "Decrease", "Refuel", 250)
				case "Tyre Compound":
					this.sendPitstopCommand("Pitstop", action, "Tyre Compound", Round(steps))
				case "All Around":
					this.sendPitstopCommand("Pitstop", action, "Tyre Pressure", Round(steps * 0.1, 1), Round(steps * 0.1, 1), Round(steps * 0.1, 1), Round(steps * 0.1, 1))
				case "Front Left":
					this.sendPitstopCommand("Pitstop", action, "Tyre Pressure", Round(steps * 0.1, 1), 0.0, 0.0, 0.0)
				case "Front Right":
					this.sendPitstopCommand("Pitstop", action, "Tyre Pressure", 0.0, Round(steps * 0.1, 1), 0.0, 0.0)
				case "Rear Left":
					this.sendPitstopCommand("Pitstop", action, "Tyre Pressure", 0.0, 0.0, Round(steps * 0.1, 1), 0.0)
				case "Rear Right":
					this.sendPitstopCommand("Pitstop", action, "Tyre Pressure", 0.0, 0.0, 0.0, Round(steps * 0.1, 1))
				case "Driver", "Repair":
					this.sendPitstopCommand("Pitstop", action, option, Round(steps))
				default:
					throw "Unsupported change operation `"" . action . "`" detected in RF2Plugin.changePitstopOption..."
			}
		}
	}

	getPitstopOptionValues(option) {
		local data, compound, compoundColor

		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option, false {
				case "Refuel":
					data := this.readSessionData("Setup=true")

					return [getMultiMapValue(data, "Setup Data", "FuelAmount", 0)]
				case "Tyre Pressures":
					data := this.readSessionData("Setup=true")

					return [getMultiMapValue(data, "Setup Data", "TyrePressureFL", 26.1), getMultiMapValue(data, "Setup Data", "TyrePressureFR", 26.1)
						  , getMultiMapValue(data, "Setup Data", "TyrePressureRL", 26.1), getMultiMapValue(data, "Setup Data", "TyrePressureRR", 26.1)]
				case "Tyre Compound", "TyreCompound":
					data := this.readSessionData("Setup=true")

					compound := getMultiMapValue(data, "Setup Data", "TyreCompoundRaw")
					compound := SessionDatabase.getTyreCompoundName(this.Simulator[true], this.Car, this.Track, compound, kUndefined)

					if (compound = kUndefined)
						compound := normalizeCompound("Dry")

					compoundColor := false

					if compound
						splitCompound(compound, &compound, &compoundColor)

					return [compound, compoundColor]
				case "Repair Suspension":
					data := this.readSessionData("Setup=true")

					return [getMultiMapValue(data, "Setup Data", "RepairSuspension", false)]
				case "Repair Bodywork":
					data := this.readSessionData("Setup=true")

					return [getMultiMapValue(data, "Setup Data", "RepairBodywork", false)]
				default:
					return super.getPitstopOptionValues(option)
			}
		}
		else
			return false
	}

	performPitstop(lap, options) {
		super.performPitstop(lap, options)

		this.iSelectedDriver := false
	}

	setPitstopRefuelAmount(pitstopNumber, liters) {
		super.setPitstopRefuelAmount(pitstopNumber, liters)

		if (this.OpenPitstopMFDHotkey != "Off")
			this.sendPitstopCommand("Pitstop", "Set", "Refuel", Round(liters))
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		super.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		if (this.OpenPitstopMFDHotkey != "Off")
			if compound {
				compound := this.tyreCompoundCode(compound, compoundColor)

				if compound {
					this.sendPitstopCommand("Pitstop", "Set", "Tyre Compound", compound)

					if set
						this.sendPitstopCommand("Pitstop", "Set", "Tyre Set", Round(set))
				}
			}
			else
				this.sendPitstopCommand("Pitstop", "Set", "Tyre Compound", "None")
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if (this.OpenPitstopMFDHotkey != "Off")
			this.sendPitstopCommand("Pitstop", "Set", "Tyre Pressure"
								  , Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		super.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if (this.OpenPitstopMFDHotkey != "Off")
			if (repairBodywork && repairSuspension)
				this.sendPitstopCommand("Pitstop", "Set", "Repair", "Both")
			else if repairSuspension
				this.sendPitstopCommand("Pitstop", "Set", "Repair", "Suspension")
			else if repairBodywork
				this.sendPitstopCommand("Pitstop", "Set", "Repair", "Bodywork")
			else
				this.sendPitstopCommand("Pitstop", "Set", "Repair", "Nothing")
	}

	requestPitstopDriver(pitstopNumber, driver) {
		local delta, currentDriver, nextDriver

		super.requestPitstopDriver(pitstopNumber, driver)

		if (this.OpenPitstopMFDHotkey != "Off")
			if driver {
				driver := string2Values("|", driver)

				nextDriver := string2Values(":", driver[2])
				currentDriver := string2Values(":", driver[1])

				if !this.iSelectedDriver
					this.iSelectedDriver := currentDriver[2]

				delta := (nextDriver[2] - this.iSelectedDriver)

				loop Abs(delta)
					this.changePitstopOption("Driver", (delta < 0) ? "Decrease" : "Increase")

				this.iSelectedDriver := nextDriver[2]
			}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startRF2() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kRF2Plugin).Simulator
													 , "Simulator Splash Images\RF2 Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeRF2Plugin() {
	local controller := SimulatorController.Instance

	RF2Plugin(controller, kRF2Plugin, kRF2Application, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeRF2Plugin()
