;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - iRacing Plugin                  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\SimulatorPlugin.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kIRCApplication := "iRacing"

global kIRCPlugin := "IRC"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class IRCPlugin extends RaceAssistantSimulatorPlugin {
	iCurrentPitstopMFD := false

	iPitstopFuelMFDHotkey := false
	iPitstopTyreMFDHotkey := false

	PitstopFuelMFDHotkey {
		Get {
			return this.iPitstopFuelMFDHotkey
		}
	}

	PitstopTyreMFDHotkey {
		Get {
			return this.iPitstopTyreMFDHotkey
		}
	}

	__New(controller, name, simulator, configuration := false) {
		super.__New(controller, name, simulator, configuration)

		if (this.Active || (isDebug() && isDevelopment())) {
			if !inList(A_Args, "-Replay") {
				this.iPitstopFuelMFDHotkey := this.getArgumentValue("togglePitstopFuelMFD", false)
				this.iPitstopTyreMFDHotkey := this.getArgumentValue("togglePitstopTyreMFD", false)
			}
			else {
				this.iPitstopFuelMFDHotkey := "Off"
				this.iPitstopTyreMFDHotkey := "Off"
			}
		}
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("NoRefuel", "No Refuel", "Refuel", "Refuel"
								   , "TyreChange", "Tyre Change"
								   , "TyreChangeFrontLeft", "Tyre Change Front Left"
								   , "TyreChangeFrontRight", "Tyre Change Front Right"
								   , "TyreChangeRearLeft", "Tyre Change Rear Left"
								   , "TyreChangeRearRight", "Tyre Change Rear Right"
								   , "TyreCompound", "Tyre Compound"
								   , "TyreAllAround", "All Around"
								   , "TyreFrontLeft", "Front Left", "TyreFrontRight", "Front Right", "TyreRearLeft", "Rear Left", "TyreRearRight", "Rear Right"
								   , "RepairRequest", "Repair")

		selectActions := []
	}

	sendPitstopCommand(command, operation, message, arguments*) {
		local exePath := (kBinariesDirectory . "Connectors\" . "IRC SHM Connector.dll")

		try {
			callSimulator(this.Code, command . "=" . operation . "=" . message . ":" . values2String(";", arguments*), "DLL")
		}
		catch Any as exception {
			logError(exception, true)

			logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: this.Code, protocol: "SHM"})
								   . exePath . translate(") - please rebuild the applications in the binaries folder (")
								   . kBinariesDirectory . translate(")"))

			if !kSilentMode
				showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
											  , {exePath: exePath, simulator: this.Code, protocol: "SHM"})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}
	}

	openPitstopMFD(descriptor := false) {
		local key := false

		static reported := false

		if !descriptor
			descriptor := "Fuel"

		if (this.iCurrentPitstopMFD && (this.iCurrentPitstopMFD != descriptor))
			this.closePitstopMFD()

		if !this.iCurrentPitstopMFD {
			if (!descriptor || (descriptor = "Fuel"))
				key := this.PitstopFuelMFDHotkey
			else if (descriptor = "Tyre")
				key := this.PitstopTyreMFDHotkey
			else
				throw "Unsupported Pitstop MFD detected in IRCPlugin.openPitstopMFD..."

			if key {
				if (key != "Off") {
					this.sendCommand(key)

					this.iCurrentPitstopMFD := descriptor

					return true
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
		else
			return true
	}

	closePitstopMFD(descriptor := false) {
		local key := false

		if this.iCurrentPitstopMFD {
			if (this.iCurrentPitstopMFD = "Fuel")
				key := this.PitstopFuelMFDHotkey
			else if (this.iCurrentPitstopMFD = "Tyre")
				key := this.PitstopTyreMFDHotkey
			else {
				this.iCurrentPitstopMFD := false

				throw "Unsupported Pitstop MFD detected in IRCPlugin.closePitstopMFD..."
			}

			if (key != "Off")
				this.sendCommand(key)

			this.iCurrentPitstopMFD := false
		}
	}

	requirePitstopMFD(descriptor := false) {
		return true
	}

	selectPitstopOption(option) {
		local actions := false
		local ignore := false
		local candidate

		if (this.PitstopFuelMFDHotkey && (this.PitstopFuelMFDHotkey != "Off")) {
			this.getPitstopActions(&actions, &ignore)

			for ignore, candidate in actions
				if (candidate = option)
					return true
		}

		return false
	}

	changePitstopOption(option, action, steps := 1) {
		switch option, false {
			case "Refuel":
				if ((steps == 1) && (getUnit("Volume") = "Liter"))
					steps := 4

				if this.requirePitstopMFD("Fuel")
					this.sendPitstopCommand("Pitstop", "Change", "Refuel", (action = kIncrease) ? Round(steps) : Round(steps * -1))
			case "No Refuel":
				if ((steps == 1) && (getUnit("Volume") = "Liter"))
					steps := 4

				if this.requirePitstopMFD("Fuel")
					this.sendPitstopCommand("Pitstop", "Change", "Refuel", -250)
			case "Tyre Change", "Tyre Change Front Left", "Tyre Change Front Right"
							  , "Tyre Change Rear Left", "Tyre Change Rear Right":
				if this.requirePitstopMFD("Tyre")
					this.sendPitstopCommand("Pitstop", "Change", option, (action = kIncrease) ? "true" : "false")
			case "Tyre Compound":
				if this.requirePitstopMFD("Tyre")
					this.sendPitstopCommand("Pitstop", "Change", "Tyre Compound", (action = kIncrease) ? Abs(Round(steps)) : (-1 * Abs(Round(steps))))
			case "All Around", "Front Left", "Front Right", "Rear Left", "Rear Right":
				if this.requirePitstopMFD("Tyre")
					this.sendPitstopCommand("Pitstop", "Change", option, Round(steps * 0.1 * ((action = kIncrease) ? 1 : -1), 1))
			case "Repair":
				if this.requirePitstopMFD("Fuel")
					this.sendPitstopCommand("Pitstop", "Change", "Repair", (action = kIncrease) ? "true" : "false")
		}
	}

	prepareSettings(settings, data) {
		settings := super.prepareSettings(settings, data)

		if (getMultiMapValue(settings, "Simulator.iRacing", "Pitstop.Service.Tyres", kUndefined) == kUndefined)
			setMultiMapValue(settings, "Simulator.iRacing", "Pitstop.Service.Tyres", "Change")

		return settings
	}

	prepareSession(settings, data) {
		SessionDatabase.registerTrack(getMultiMapValue(data, "Session Data", "Simulator", "Unknown")
									, getMultiMapValue(data, "Session Data", "Car", "Unknown")
									, getMultiMapValue(data, "Session Data", "Track", "Unknown")
									, getMultiMapValue(data, "Session Data", "TrackShortName", "Unknown")
									, getMultiMapValue(data, "Session Data", "TrackLongName", "Unknown"))

		super.prepareSession(settings, data)
	}

	getPitstopOptionValues(option) {
		local data, compound, compoundColor

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

				return [getMultiMapValue(data, "Setup Data", "TyreCompound", false)
					  , getMultiMapValue(data, "Setup Data", "TyreCompoundColor", false)]
			case "Tyre Compound Front Left", "TyreCompoundFrontLeft":
				data := this.readSessionData("Setup=true")

				return [getMultiMapValue(data, "Setup Data", "TyreCompoundFrontLeft", false)
					  , getMultiMapValue(data, "Setup Data", "TyreCompoundColorFrontLeft", false)]
			case "Tyre Compound Front Right", "TyreCompoundFrontRight":
				data := this.readSessionData("Setup=true")

				return [getMultiMapValue(data, "Setup Data", "TyreCompoundFrontRight", false)
					  , getMultiMapValue(data, "Setup Data", "TyreCompoundColorFrontRight", false)]
			case "Tyre Compound Rear Left", "TyreCompoundRearLeft":
				data := this.readSessionData("Setup=true")

				return [getMultiMapValue(data, "Setup Data", "TyreCompoundRearLeft", false)
					  , getMultiMapValue(data, "Setup Data", "TyreCompoundColorRearLeft", false)]
			case "Tyre Compound Rear Right", "TyreCompoundRearRight":
				data := this.readSessionData("Setup=true")

				return [getMultiMapValue(data, "Setup Data", "TyreCompoundRearRight", false)
					  , getMultiMapValue(data, "Setup Data", "TyreCompoundColorRearRight", false)]
			default:
				return super.getPitstopOptionValues(option)
		}
	}

	notifyPitstopChanged(option) {
		local newValues

		if this.RaceEngineer
			switch option, false {
				case "Tyre Change", "Tyre Change Front Left", "Tyre Change Front Right"
								  , "Tyre Change Rear Left", "Tyre Change Rear Right":
					newValues := this.getPitstopOptionValues("Tyre Compound")

					if newValues
						this.RaceEngineer.pitstopOptionChanged("Tyre Compound", true, newValues*)
				default:
					super.notifyPitstopChanged((option = "No Refuel") ? "Refuel" : option)
			}
	}

	startPitstopSetup(pitstopNumber) {
		super.startPitstopSetup(pitstopNumber)

		this.requirePitstopMFD()
	}

	finishPitstopSetup(pitstopNumber) {
		super.finishPitstopSetup(pitstopNumber)

		this.closePitstopMFD()
	}

	setPitstopRefuelAmount(pitstopNumber, liters, fillUp) {
		super.setPitstopRefuelAmount(pitstopNumber, liters, fillUp)

		if this.requirePitstopMFD("Fuel")
			this.sendPitstopCommand("Pitstop", "Set", "Refuel", Round(liters))
	}

	setPitstopTyreCompound(pitstopNumber, compound, compoundColor := false, set := false) {
		local targetCompound := false
		local index, tyre, tyreCompound

		super.setPitstopTyreCompound(pitstopNumber, compound, compoundColor, set)

		if this.requirePitstopMFD("Tyre") {
			if InStr(compound, ",") {
				compound := string2Values(",", compound)
				compoundColor := string2Values(",", compoundColor)
			}
			else {
				compound := [compound, compound, compound, compound]
				compoundColor := [compoundColor, compoundColor, compoundColor, compoundColor]
			}

			for index, tyre in ["Front Left", "Front Right", "Rear Left", "Rear Right"] {
				this.sendPitstopCommand("Pitstop", "Set", "Tyre Change " . tyre, compound[index] ? "true" : "false")

				if compound[index] {
					tyreCompound := this.tyreCompoundCode(compound[index], compoundColor[index])

					if tyreCompound {
						if (targetCompound && (targetCompound != tyreCompound))
							throw "Invalid tyre compound detected in IRCPlugin.setPitstopTyreCompound..."

						targetCompound := tyreCompound

						this.sendPitstopCommand("Pitstop", "Set", "Tyre Compound", tyreCompound)
					}
				}
			}
		}
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if this.requirePitstopMFD("Tyre")
			this.sendPitstopCommand("Pitstop", "Set", "Tyre Pressure"
								  , Round(pressureFL, 1), Round(pressureFR, 1), Round(pressureRL, 1), Round(pressureRR, 1))
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		super.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if this.requirePitstopMFD("Fuel")
			this.sendPitstopCommand("Pitstop", "Set", "Repair"
								  , (repairBodywork || repairSuspension || repairEngine) ? "true" : "false")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startIRC() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kIRCPlugin).Simulator
													 , "Simulator Splash Images\IRC Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeIRCPlugin() {
	local controller := SimulatorController.Instance

	IRCPlugin(controller, kIRCPlugin, kIRCApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeIRCPlugin()
