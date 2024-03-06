;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - LMU Plugin                      ;;;
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

global kLMUApplication := "Le Mans Ultimate"

global kLMUPlugin := "LMU"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class LMUPlugin extends RaceAssistantSimulatorPlugin {
	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false

	iSelectedDriver := false

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

	__New(controller, name, simulator, configuration := false) {
		super.__New(controller, name, simulator, configuration)

		if (this.Active || (isDebug() && isDevelopment())) {
			if !inList(A_Args, "-Replay")
				this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
			else
				this.iOpenPitstopMFDHotkey := "Off"

			this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)
		}
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("NoRefuel", "No Refuel", "Refuel", "Refuel", "TyreCompound", "Tyre Compound", "TyreAllAround", "All Around"
								   , "TyreFrontLeft", "Front Left", "TyreFrontRight", "Front Right", "TyreRearLeft", "Rear Left", "TyreRearRight", "Rear Right"
								   , "DriverSelect", "Driver", "RepairRequest", "Repair")

		selectActions := []
	}

	activateWindow() {
		return true
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

			showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
					  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
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

	changePitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			switch option, false {
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
			}
		}
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
				case "Tyre Compound":
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

		if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off"))
			this.sendPitstopCommand("Pitstop", "Set", "Refuel", Round(liters))
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		super.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off"))
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

		if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off"))
			this.sendPitstopCommand("Pitstop", "Set", "Tyre Pressure"
								  , Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		super.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off"))
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

		if (this.OpenPitstopMFDHotkey && (this.OpenPitstopMFDHotkey != "Off"))
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

	parseCarName(carName, &model?, &nr?, &category?, &team?) {
		local index

		parseNr(candidate, &rest) {
			local temp := ""
			local char

			candidate := Trim(candidate)

			if isNumber(candidate) {
				rest := ""

				return candidate
			}
			else {
				loop StrLen(candidate) {
					char := SubStr(candidate, A_Index, 1)

					if isNumber(char)
						temp .= char
					else if (char != A_Space) {
						rest := SubStr(candidate, A_Index)

						return temp
					}
				}
			}

			rest := ""

			return ((temp != "") ? temp : false)
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

		carName := Trim(carName)

		if isSet(model)
			model := false

		if isSet(team)
			team := false

		if isSet(nr)
			nr := false

		if isSet(category)
			category := false

		index := InStr(carName, "#")

		if (index = 1) {
			if isSet(nr)
				nr := parseNr(SubStr(carName, 2), &carName)
			else
				parseNr(SubStr(carName, 2), &carName)

			if (InStr(carName, ":") = 1)
				if isSet(category)
					category := parseCategory(SubStr(carName, 2), &carName)
				else
					parseCategory(SubStr(carName, 2), &carName)

			if isSet(model)
				model := carName
		}
		else if index {
			carName := StrSplit(carName, "#", , 2)

			if isSet(model) {
				model := Trim(carName[1])

				if (model = "")
					model := false
			}

			if isSet(nr)
				nr := parseNr(carName[2], &carName)
			else
				parseNr(carName[2], &carName)

			if (InStr(carName, ":") = 1)
				if isSet(category)
					category := parseCategory(SubStr(carName, 2), &carName)
				else
					parseCategory(SubStr(carName, 2), &carName)
		}
	}

	acquirePositionsData(telemetryData, finished := false) {
		local positionsData := super.acquirePositionsData(telemetryData, finished)
		local numbers := Map()
		local duplicateNrs := false
		local carRaw, carID, model, category, nr

		loop {
			carRaw := getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".CarRaw", kUndefined)

			if (carRaw == kUndefined)
				break
			else {
				this.parseCarName(carRaw, &model, &nr, &category)

				if model
					setMultiMapValue(telemetryData, "Position Data", "Car." . A_Index . ".Car", model)

				nr := Integer(nr ? nr : getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".ID"))

				setMultiMapValue(telemetryData, "Position Data", "Car." . A_Index . ".Nr", nr)

				if category
					setMultiMapValue(telemetryData, "Position Data", "Car." . A_Index . ".Category", category)

				if numbers.Has(nr)
					duplicateNrs := true
				else
					numbers[nr] := true
			}
		}

		if duplicateNrs
			loop {
				carID := getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".CarID", kUndefined)

				if (carID == kUndefined)
					break
				else
					getMultiMapValue(positionsData, "Position Data", "Car." . A_Index . ".Nr", carID)
			}

		return positionsData
	}

	acquireTelemetryData() {
		local telemetryData := super.acquireTelemetryData()
		local model

		static lastSimulator := false
		static lastCar := false
		static lastTrack := false

		static loadSetup := false
		static nextSetupUpdate := false

		if ((this.Simulator[true] != lastSimulator) || (this.Car != lastCar) || (this.Track != lastTrack)) {
			lastSimulator := this.Simulator[true]
			lastCar := this.Car
			lastTrack := this.Track

			loadSetup := SettingsDatabase().readSettingValue(lastSimulator, lastCar, lastTrack, "*", "Simulator.Le Mans Ultimate", "Session.Data.Setup", 60)
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
