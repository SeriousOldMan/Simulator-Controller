;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - AC Plugin                       ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\SimulatorPlugin.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk
#Include ..\Assistants\Libraries\SettingsDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kACApplication = "Assetto Corsa"

global kACPlugin = "AC"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACPlugin extends RaceAssistantSimulatorPlugin {
	iCommandMode := "Event"

	iOpenPitstopMFDHotkey := false

	iPreviousOptionHotkey := false
	iNextOptionHotkey := false
	iPreviousChoiceHotkey := false
	iNextChoiceHotkey := false

	iKeyDelay := kUndefined

	iRepairSuspensionChosen := false
	iRepairBodyworkChosen := false
	iRepairEngineChosen := false

	iPitstopAutoClose := false

	iSettingsDatabase := false
	iCarMetaData := {}

	Car[] {
		Get {
			return base.Car
		}

		Set {
			this.iKeyDelay := kUndefined

			return (base.Car := value)
		}
	}

	Track[] {
		Get {
			return base.Track
		}

		Set {
			this.iKeyDelay := kUndefined

			return (base.Track := value)
		}
	}

	OpenPitstopMFDHotkey[] {
		Get {
			return this.iOpenPitstopMFDHotkey
		}
	}

	PreviousOptionHotkey[] {
		Get {
			return this.iPreviousOptionHotkey
		}
	}

	NextOptionHotkey[] {
		Get {
			return this.iNextOptionHotkey
		}
	}

	PreviousChoiceHotkey[] {
		Get {
			return this.iPreviousChoiceHotkey
		}
	}

	NextChoiceHotkey[] {
		Get {
			return this.iNextChoiceHotkey
		}
	}

	SettingsDatabase[] {
		Get {
			settingsDB := this.iSettingsDatabase

			if !settingsDB {
				settingsDB := new SettingsDatabase()

				this.iSettingsDatabase := settingsDB
			}

			return settingsDB
		}
	}

	CarMetaData[key := false] {
		Get {
			return (key ? this.iCarMetaData[key] : this.iCarMetaData)
		}
	}

	__New(controller, name, simulator, configuration := false) {
		base.__New(controller, name, simulator, configuration)

		this.iCommandMode := this.getArgumentValue("pitstopMFDMode", "Event")

		this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", "{Down}")

		this.iPreviousOptionHotkey := this.getArgumentValue("previousOption", "{Up}")
		this.iNextOptionHotkey := this.getArgumentValue("nextOption", "{Down}")
		this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoice", "{Left}")
		this.iNextChoiceHotkey := this.getArgumentValue("nextChoice", "{Right}")
	}

	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Strategy: "Strategy", Refuel: "Refuel", TyreCompound: "Tyre Compound", TyreAllAround: "All Around"
					 , TyreFrontLeft: "Front Left", TyreFrontRight: "Front Right", TyreRearLeft: "Rear Left", TyreRearRight: "Rear Right"
					 , BodyworkRepair: "Repair Bodywork", SuspensionRepair: "Repair Suspension", EngineRepair: "Repair Engine"}
		selectActions := []
	}

	supportsPitstop() {
		return true
	}

	supportsTrackMap() {
		return true
	}

	sendPitstopCommand(command) {
		switch this.iCommandMode {
			case "Event":
				SendEvent %command%
			case "Input":
				SendInput %command%
			case "Play":
				SendPlay %command%
			case "Raw":
				SendRaw %command%
			default:
				Send %command%
		}

		if (this.iKeyDelay = kUndefined) {
			car := (this.Car ? this.Car : "*")
			track := (this.Track ? this.Track : "*")

			settings := new SettingsDatabase().loadSettings(this.Simulator[true], car, track, "*")

			this.iKeyDelay := getConfigurationValue(settings, "Simulator.Automobilista 2", "Pitstop.KeyDelay", 20)
		}

		Sleep % this.iKeyDelay
	}

	updateSessionState(sessionState) {
		base.updateSessionState(sessionState)

		if (sessionState == kSessionFinished) {
			this.iRepairSuspensionChosen := false
			this.iRepairBodyworkChosen := false
			this.iRepairEngineChosen := false
		}
	}

	updatePositionsData(data) {
		base.updatePositionsData(data)

		standings := readSimulatorData(this.Code, "-Standings")

		setConfigurationSectionValues(data, "Position Data", getConfigurationSectionValues(standings, "Position Data"))
	}

	updateSessionData(data) {
		base.updateSessionData(data)

		setConfigurationValue(data, "Car Data", "TC", Round((getConfigurationValue(data, "Car Data", "TCRaw", 0) / 0.2) * 10))
		setConfigurationValue(data, "Car Data", "ABS", Round((getConfigurationValue(data, "Car Data", "ABSRaw", 0) / 0.2) * 10))

		forName := getConfigurationValue(data, "Stint Data", "DriverForname", "John")
		surName := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
		nickName := getConfigurationValue(data, "Stint Data", "DriverNickname", "JDO")

		if ((forName = surName) && (surName = nickName)) {
			name := string2Values(A_Space, forName, 2)

			setConfigurationValue(data, "Stint Data", "DriverForname", name[1])
			setConfigurationValue(data, "Stint Data", "DriverSurname", (name.Length() > 1) ? name[2] : "")
			setConfigurationValue(data, "Stint Data", "DriverNickname", "")
		}

		if !isDebug() {
			removeConfigurationValue(data, "Car Data", "TCRaw")
			removeConfigurationValue(data, "Car Data", "ABSRaw")
			removeConfigurationValue(data, "Track Data", "GripRaw")
		}

		if !getConfigurationValue(data, "Stint Data", "InPit", false)
			if (getConfigurationValue(data, "Car Data", "FuelRemaining", 0) = 0)
				setConfigurationValue(data, "Session Data", "Paused", true)
	}

	getCarMetaData(meta, default := 0) {
		car := (this.Car ? this.Car : "*")
		track := (this.Track ? this.Track : "*")
		key := (car . "." . meta)

		if this.CarMetaData.HasKey(key)
			return this.CarMetaData[key]
		else {
			value := getConfigurationValue(readConfiguration(kResourcesDirectory . "Simulator Data\AC\Car Data.ini"), "Pitstop Settings", key, kUndefined)

			if (value == kUndefined) {
				settings := this.SettingsDatabase.loadSettings(this.Simulator[true], car, track, "*")

				value := getConfigurationValue(settings, "Simulator.Assetto Corsa", "Pitstop." . meta, default)
			}

			this.CarMetaData[key] := value

			return value
		}
	}

	activateACWindow() {
		window := this.Simulator.WindowTitle

		if !WinExist(window)
			if isDebug()
				showMessage("AC not found...")

		if !WinActive(window)
			WinActivate %window%
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

		this.activateACWindow()

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.sendPitstopCommand(this.OpenPitstopMFDHotkey)

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

			this.activateACWindow()

			return true
		}
		else {
			Sleep 1200

			this.iPitstopAutoClose := (A_TickCount + 4000)

			return this.openPitstopMFD()
		}
	}

	selectPitstopOption(option) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			Loop 20
				this.sendPitstopCommand(this.PreviousOptionHotkey)

			if ((option = "Strategy") || (option = "All Around"))
				return true
			else if (option = "Refuel") {
				this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Tyre Compound") {
				this.sendPitstopCommand(this.NextOptionHotkey)
				this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Front Left") {
				Loop 3
					this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Front Right") {
				Loop 4
					this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Rear Left") {
				Loop 5
					this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Rear Right") {
				Loop 6
					this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Repair Bodywork") {
				Loop % 7 + this.getCarMetaData("CarSettings")
					this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Repair Suspension") {
				Loop % 8 + this.getCarMetaData("CarSettings")
					this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Repair Engine") {
				Loop % 9 + this.getCarMetaData("CarSettings")
					this.sendPitstopCommand(this.NextOptionHotkey)

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
			switch action {
				case "Increase":
					this.activateACWindow()

					Loop %steps%
						this.sendPitstopCommand(this.NextChoiceHotkey)
				case "Decrease":
					this.activateACWindow()

					Loop %steps%
						this.sendPitstopCommand(this.PreviousChoiceHotkey)
				default:
					Throw "Unsupported change operation """ . action . """ detected in ACPlugin.dialPitstopOption..."
			}
	}

	changePitstopOption(option, action := "Increase", steps := 1) {
		if (this.OpenPitstopMFDHotkey != "Off")
			if (option = "All Around") {
				for ignore, tyre in ["Front Left", "Front Right", "Rear Left", "Rear Right"]
					if this.selectPitstopOption(tyre)
						this.changePitstopOption(tyre, action, steps)
			}
			else if inList(["Strategy", "Refuel", "Tyre Compound", "Front Left", "Front Right", "Rear Left", "Rear Right"], option)
				this.dialPitstopOption(option, action, steps)
			else if (option = "Repair Bodywork") {
				this.dialPitstopOption("Repair Bodywork", action, steps)

				Loop %steps%
					this.iRepairBodyworkChosen := !this.iRepairBodyworkChosen
			}
			else if (option = "Repair Suspension") {
				this.dialPitstopOption("Repair Suspension", action, steps)

				Loop %steps%
					this.iRepairSuspensionChosen := !this.iRepairSuspensionChosen
			}
			else if (option = "Repair Engine") {
				this.dialPitstopOption("Repair Engine", action, steps)

				Loop %steps%
					this.iRepairEngineChosen := !this.iRepairEngineChosen
			}
			else
				Throw "Unsupported change operation """ . action . """ detected in ACPlugin.changePitstopOption..."
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		base.setPitstopRefuelAmount(pitstopNumber, litres)

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.requirePitstopMFD()

			if this.selectPitstopOption("Refuel") {
				this.dialPitstopOption("Refuel", "Decrease", 200)
				this.dialPitstopOption("Refuel", "Increase", Round(litres))
			}
		}
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		base.setPitstopTyreSet(pitstopNumber, compound, compoundColor, set)

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
		base.setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR)

		if (this.OpenPitstopMFDHotkey != "Off") {
			this.requirePitstopMFD()

			if this.selectPitstopOption("Front Left") {
				this.dialPitstopOption("Front Left", "Decrease", 30)

				Loop % Round(pressureFL - this.getCarMetaData("TyrePressureMinFL", 15))
					this.dialPitstopOption("Front Left", "Increase")
			}

			if this.selectPitstopOption("Front Right") {
				this.dialPitstopOption("Front Right", "Decrease", 30)

				Loop % Round(pressureFR - this.getCarMetaData("TyrePressureMinFR", 15))
					this.dialPitstopOption("Front Right", "Increase")
			}

			if this.selectPitstopOption("Rear Left") {
				this.dialPitstopOption("Rear Left", "Decrease", 30)

				Loop % Round(pressureRL - this.getCarMetaData("TyrePressureMinRL", 15))
					this.dialPitstopOption("Rear Left", "Increase")
			}

			if this.selectPitstopOption("Rear Right") {
				this.dialPitstopOption("Rear Right", "Decrease", 30)

				Loop % Round(pressureRR - this.getCarMetaData("TyrePressureMinRR", 15))
					this.dialPitstopOption("Rear Right", "Increase")
			}
		}
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
		base.requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine)

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

	new ACPlugin(controller, kACPlugin, kACApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeACPlugin()
