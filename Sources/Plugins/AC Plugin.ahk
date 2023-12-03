;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AC Plugin                       ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\SimulatorPlugin.ahk"
#Include "..\Database\Libraries\SessionDatabase.ahk"
#Include "..\Database\Libraries\SettingsDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kACApplication := "Assetto Corsa"

global kACPlugin := "AC"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACPlugin extends RaceAssistantSimulatorPlugin {
	iOpenPitstopMFDHotkey := false

	iPreviousOptionHotkey := false
	iNextOptionHotkey := false
	iPreviousChoiceHotkey := false
	iNextChoiceHotkey := false

	iRepairSuspensionChosen := false
	iRepairBodyworkChosen := false
	iRepairEngineChosen := false

	iPitstopAutoClose := false

	iSettingsDatabase := false
	iCarMetaData := CaseInsenseMap()

	static sCarData := false

	OpenPitstopMFDHotkey {
		Get {
			return this.iOpenPitstopMFDHotkey
		}
	}

	PreviousOptionHotkey {
		Get {
			return this.iPreviousOptionHotkey
		}
	}

	NextOptionHotkey {
		Get {
			return this.iNextOptionHotkey
		}
	}

	PreviousChoiceHotkey {
		Get {
			return this.iPreviousChoiceHotkey
		}
	}

	NextChoiceHotkey {
		Get {
			return this.iNextChoiceHotkey
		}
	}

	SettingsDatabase {
		Get {
			local settingsDB := this.iSettingsDatabase

			if !settingsDB {
				settingsDB := SettingsDatabase()

				this.iSettingsDatabase := settingsDB
			}

			return settingsDB
		}
	}

	CarMetaData[key?] {
		Get {
			return (isSet(key) ? this.iCarMetaData[key] : this.iCarMetaData)
		}

		Set {
			return (isSet(key) ? (this.iCarMetaData[key] := value) : (this.iCarMetaData := value))
		}
	}

	__New(controller, name, simulator, configuration := false) {
		super.__New(controller, name, simulator, configuration)

		if (this.Active || (isDebug() && isDevelopment())) {
			if !inList(A_Args, "-Replay")
				this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", "{Down}")
			else
				this.iOpenPitstopMFDHotkey := "Off"

			this.iPreviousOptionHotkey := this.getArgumentValue("previousOption", "{Up}")
			this.iNextOptionHotkey := this.getArgumentValue("nextOption", "{Down}")
			this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoice", "{Left}")
			this.iNextChoiceHotkey := this.getArgumentValue("nextChoice", "{Right}")
		}
	}

	getPitstopActions(&allActions, &selectActions) {
		allActions := CaseInsenseMap("Strategy", "Strategy", "NoRefuel", "No Refuel", "Refuel", "Refuel"
								   , "TyreCompound", "Tyre Compound", "TyreAllAround", "All Around"
								   , "TyreFrontLeft", "Front Left", "TyreFrontRight", "Front Right"
								   , "TyreRearLeft", "Rear Left", "TyreRearRight", "Rear Right"
								   , "BodyworkRepair", "Repair Bodywork", "SuspensionRepair", "Repair Suspension", "EngineRepair", "Repair Engine")
		selectActions := []
	}

	static requireCarDatabase() {
		if !ACPlugin.sCarData {
			data := readMultiMap(kResourcesDirectory . "Simulator Data\AC\Car Data.ini")

			if FileExist(kUserHomeDirectory . "Simulator Data\AC\Car Data.ini")
				addMultiMapValues(data, readMultiMap(kUserHomeDirectory . "Simulator Data\AC\Car Data.ini"))

			ACPlugin.sCarData := data
		}
	}

	simulatorStartup(simulator) {
		if (simulator = kACApplication)
			Task.startTask(ObjBindMethod(ACPlugin, "requireCarDatabase"), 1000, kLowPriority)

		super.simulatorStartup(simulator)
	}

	supportsPitstop() {
		return true
	}

	supportsTrackMap() {
		return true
	}

	updateSession(session, force := false) {
		super.updateSession(session, force)

		if (session == kSessionFinished) {
			this.iRepairSuspensionChosen := false
			this.iRepairBodyworkChosen := false
			this.iRepairEngineChosen := false
		}
	}

	updateTelemetryData(data) {
		local forName, surName, nickName, name

		super.updateTelemetryData(data)

		setMultiMapValue(data, "Car Data", "TC", Round((getMultiMapValue(data, "Car Data", "TCRaw", 0) / 0.2) * 10))
		setMultiMapValue(data, "Car Data", "ABS", Round((getMultiMapValue(data, "Car Data", "ABSRaw", 0) / 0.2) * 10))

		forName := getMultiMapValue(data, "Stint Data", "DriverForname", "John")
		surName := getMultiMapValue(data, "Stint Data", "DriverSurname", "Doe")
		nickName := getMultiMapValue(data, "Stint Data", "DriverNickname", "JD")

		if ((forName = surName) && (surName = nickName)) {
			name := string2Values(A_Space, forName, 2)

			if isObject(name) {
				setMultiMapValue(data, "Stint Data", "DriverForname", name[1])
				setMultiMapValue(data, "Stint Data", "DriverSurname", (name.Length > 1) ? name[2] : "")
			}
			else
				setMultiMapValue(data, "Stint Data", "DriverSurname", "")

			setMultiMapValue(data, "Stint Data", "DriverNickname", "")
		}

		if !isDebug() {
			removeMultiMapValue(data, "Car Data", "TCRaw")
			removeMultiMapValue(data, "Car Data", "ABSRaw")
			removeMultiMapValue(data, "Track Data", "GripRaw")
		}

		if !getMultiMapValue(data, "Stint Data", "InPit", false)
			if (getMultiMapValue(data, "Car Data", "FuelRemaining", 0) = 0)
				setMultiMapValue(data, "Session Data", "Paused", true)
	}

	getCarMetaData(meta, default := 0) {
		local car := (this.Car ? this.Car : "*")
		local track := (this.Track ? this.Track : "*")
		local key := (car . "." . track . "." . meta)
		local value, settings

		if this.CarMetaData.Has(key)
			return this.CarMetaData[key]
		else {
			settings := this.SettingsDatabase.loadSettings(this.Simulator[true], car, track, "*")

			value := getMultiMapValue(settings, "Simulator.Assetto Corsa", "Pitstop." . meta, kUndefined)

			if (value == kUndefined) {
				ACPlugin.requireCarDatabase()

				value := getMultiMapValue(ACPlugin.sCarData, "Pitstop Settings", key, default)
			}

			this.CarMetaData[key] := value

			return value
		}
	}

	openPitstopMFD(descriptor := false) {
		static reported := false

		if !this.OpenPitstopMFDHotkey {
			if !reported {
				reported := true

				logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))

				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
									, translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}

			return false
		}

		this.activateWindow()

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.sendCommand(this.OpenPitstopMFDHotkey)

			return true
		}
		else
			return false
	}

	closePitstopMFD() {
	}

	requirePitstopMFD() {
		if (A_TickCount < this.iPitstopAutoClose) {
			this.iPitstopAutoClose := (A_TickCount + 4000)

			this.activateWindow()

			return true
		}
		else {
			Sleep(1200)

			this.iPitstopAutoClose := (A_TickCount + 4000)

			return this.openPitstopMFD()
		}
	}

	selectPitstopOption(option) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			loop 20
				this.sendCommand(this.PreviousOptionHotkey)

			if ((option = "Strategy") || (option = "All Around"))
				return true
			else if ((option = "Refuel") || (option = "No Refuel")) {
				this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Tyre Compound") {
				this.sendCommand(this.NextOptionHotkey)
				this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Front Left") {
				loop 3
					this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Front Right") {
				loop 4
					this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Rear Left") {
				loop 5
					this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Rear Right") {
				loop 6
					this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Repair Bodywork") {
				loop 7 + this.getCarMetaData("CarSettings")
					this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Repair Suspension") {
				loop 8 + this.getCarMetaData("CarSettings")
					this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Repair Engine") {
				loop 9 + this.getCarMetaData("CarSettings")
					this.sendCommand(this.NextOptionHotkey)

				return true
			}
			else
				return false
		}
		else
			return false
	}

	dialPitstopOption(option, action, steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off")
			switch action, false {
				case "Increase":
					this.activateWindow()

					loop steps
						this.sendCommand(this.NextChoiceHotkey)
				case "Decrease":
					this.activateWindow()

					loop steps
						this.sendCommand(this.PreviousChoiceHotkey)
				default:
					throw "Unsupported change operation `"" . action . "`" detected in ACPlugin.dialPitstopOption..."
			}
	}

	changePitstopOption(option, action := "Increase", steps := 1) {
		local ignore, tyre

		if (this.OpenPitstopMFDHotkey != "Off")
			if (option = "All Around") {
				for ignore, tyre in ["Front Left", "Front Right", "Rear Left", "Rear Right"]
					if this.selectPitstopOption(tyre)
						this.changePitstopOption(tyre, action, steps)
			}
			else if inList(["Strategy", "Refuel", "Tyre Compound", "Front Left", "Front Right", "Rear Left", "Rear Right"], option)
				this.dialPitstopOption(option, action, steps)
			else if (option = "No Refuel")
				this.dialPitstopOption("Refuel", "Decrease", 250)
			else if (option = "Repair Bodywork") {
				this.dialPitstopOption("Repair Bodywork", action, steps)

				loop steps
					this.iRepairBodyworkChosen := !this.iRepairBodyworkChosen
			}
			else if (option = "Repair Suspension") {
				this.dialPitstopOption("Repair Suspension", action, steps)

				loop steps
					this.iRepairSuspensionChosen := !this.iRepairSuspensionChosen
			}
			else if (option = "Repair Engine") {
				this.dialPitstopOption("Repair Engine", action, steps)

				loop steps
					this.iRepairEngineChosen := !this.iRepairEngineChosen
			}
			else
				throw "Unsupported change operation `"" . action . "`" detected in ACPlugin.changePitstopOption..."
	}

	setPitstopRefuelAmount(pitstopNumber, liters) {
		super.setPitstopRefuelAmount(pitstopNumber, liters)

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.requirePitstopMFD()

			if this.selectPitstopOption("Refuel") {
				this.dialPitstopOption("Refuel", "Decrease", 250)
				this.dialPitstopOption("Refuel", "Increase", Round(liters))
			}
		}
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		local delta

		super.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

		if (this.OpenPitstopMFDHotkey != "Off") {
			delta := this.tyreCompoundIndex(compound, compoundColor)

			if (!compound || delta) {
				this.requirePitstopMFD()

				if this.selectPitstopOption("Tyre Compound") {
					this.dialPitstopOption("Tyre Compound", "Decrease", 10)

					this.dialPitstopOption("Tyre Compound", "Increase", delta)
				}
			}
		}
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		local postFix, tyre

		super.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.requirePitstopMFD()

			for postFix, tyre in Map("FL", "Front Left", "FR", "Front Right", "RL", "Rear Left", "RR", "Rear Right")
				if this.selectPitstopOption(tyre) {
					this.dialPitstopOption(tyre, "Decrease", 60)

					this.dialPitstopOption(tyre, "Increase", Round(pressure%postFix% - this.getCarMetaData("TyrePressureMin" . postFix, 15)))
				}

			/*
			if this.selectPitstopOption("Front Left") {
				this.dialPitstopOption("Front Left", "Decrease", 60)

				loop Round(pressureFL - this.getCarMetaData("TyrePressureMinFL", 15))
					this.dialPitstopOption("Front Left", "Increase")
			}

			if this.selectPitstopOption("Front Right") {
				this.dialPitstopOption("Front Right", "Decrease", 60)

				loop Round(pressureFR - this.getCarMetaData("TyrePressureMinFR", 15))
					this.dialPitstopOption("Front Right", "Increase")
			}

			if this.selectPitstopOption("Rear Left") {
				this.dialPitstopOption("Rear Left", "Decrease", 60)

				loop Round(pressureRL - this.getCarMetaData("TyrePressureMinRL", 15))
					this.dialPitstopOption("Rear Left", "Increase")
			}

			if this.selectPitstopOption("Rear Right") {
				this.dialPitstopOption("Rear Right", "Decrease", 60)

				loop Round(pressureRR - this.getCarMetaData("TyrePressureMinRR", 15))
					this.dialPitstopOption("Rear Right", "Increase")
			}
			*/
		}
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		super.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

		if (this.OpenPitstopMFDHotkey != "Off") {
			if (this.iRepairSuspensionChosen != repairSuspension) {
				this.requirePitstopMFD()

				if this.selectPitstopOption("Repair Suspension")
					this.changePitstopOption("Repair Suspension")
			}

			if (this.iRepairBodyworkChosen != repairBodywork) {
				this.requirePitstopMFD()

				if this.selectPitstopOption("Repair Bodywork")
					this.changePitstopOption("Repair Bodywork")
			}

			if (this.iRepairEngineChosen != repairEngine) {
				this.requirePitstopMFD()

				if this.selectPitstopOption("Repair Engine")
					this.changePitstopOption("Repair Engine")
			}
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startAC() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kACPlugin).Simulator
													 , "Simulator Splash Images\AC Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeACPlugin() {
	local controller := SimulatorController.Instance

	ACPlugin(controller, kACPlugin, kACApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACPlugin()
