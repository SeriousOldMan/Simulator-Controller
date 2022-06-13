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
	iUDPClient := false
	iUDPConnection := false

	iCommandMode := "Event"

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

	UDPConnection[] {
		Get {
			return this.iUDPConnection
		}
	}

	UDPClient[] {
		Get {
			return this.iUDPClient
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

	__New(controller, name, simulator, configuration := false) {
		base.__New(controller, name, simulator, configuration)

		this.iCommandMode := this.getArgumentValue("pitstopMFDMode", "Event")

		this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", "{Down}")

		this.iPreviousOptionHotkey := this.getArgumentValue("previousOption", "{Up}")
		this.iNextOptionHotkey := this.getArgumentValue("nextOption", "{Down}")
		this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoice", "{Left}")
		this.iNextChoiceHotkey := this.getArgumentValue("nextChoice", "{Right}")

		this.iUDPConnection := this.getArgumentValue("udpConnection", false)
	}

	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Refuel: "Refuel", TyreCompound: "Tyre Compound", TyreAllAround: "All Around"
					 , TyreFrontLeft: "Front Left", TyreFrontRight: "Front Right", TyreRearLeft: "Rear Left", TyreRearRight: "Rear Right"
					 , BodyworkRepair: "Repair Bodywork", SuspensionRepair: "Repair Suspension", EngineRepair: "Repair Engine"}
		selectActions := []
	}

	startupUDPClient() {
		if false && !this.UDPClient {
			exePath := kBinariesDirectory . "AC UDP Provider.exe"

			try {
				Loop 6 {
					Process Exist, AC UDP Provider.exe

					if ErrorLevel {
						Process Close, %ErrorLevel%

						Sleep 250
					}
					else
						break
				}

				if FileExist(kTempDirectory . "ACUDP.cmd")
					FileDelete %kTempDirectory%ACUDP.cmd

				if FileExist(kTempDirectory . "ACUDP.out")
					FileDelete %kTempDirectory%ACUDP.out

				options := ""

				if this.UDPConnection
					options := ("-Connect " . this.UDPConnection)

				Run %ComSpec% /c ""%exePath%" "%kTempDirectory%ACUDP.cmd" "%kTempDirectory%ACUDP.out" %options%", , Hide

				this.iUDPClient := ObjBindMethod(this, "shutdownUDPClient")

				OnExit(this.iUDPClient)
			}
			catch exception {
				logMessage(kLogCritical, substituteVariables(translate("Cannot start %simulator% %protocol% Provider ("), {simulator: "AC", protocol: "UDP"})
														   . exePath . translate(") - please rebuild the applications in the binaries folder (")
														   . kBinariesDirectory . translate(")"))

				showMessage(substituteVariables(translate("Cannot start %simulator% %protocol% Provider (%exePath%) - please check the configuration...")
											  , {exePath: exePath, simulator: "AC", protocol: "UDP"})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}

	shutdownUDPClient() {
		if this.UDPClient {
			FileAppend Exit, %kTempDirectory%ACUDP.cmd

			OnExit(this.iUDPClient, 0)

			Sleep 250

			Loop 5 {
				Process Exist, AC UDP Provider.exe

				if ErrorLevel {
					Process Close, %ErrorLevel%

					Sleep 250
				}
				else
					break
			}

			this.iUDPClient := false
		}

		return false
	}

	requireUDPClient() {
		Process Exist, AC UDP Provider.exe

		if !ErrorLevel {
			if this.iUDPClient
				OnExit(this.iUDPClient, 0)

			this.iUDPClient := false
		}

		if !this.UDPClient
			this.startupUDPClient()
	}

	supportsPitstop() {
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

		Sleep 20
	}

	supportsRaceAssistant(assistantPlugin) {
		return ((assistantPlugin = kRaceEngineerPlugin) && base.supportsRaceAssistant(assistantPlugin))
	}

	updateSessionState(sessionState) {
		base.updateSessionState(sessionState)

		if (sessionState == kSessionRace)
			this.startupUDPClient()
		else if (sessionState != kSessionPaused)
			this.shutdownUDPClient()

		if (sessionState == kSessionFinished) {
			this.iRepairSuspensionChosen := false
			this.iRepairBodyworkChosen := false
			this.iRepairEngineChosen := false
		}
	}

	updatePositionsData(data) {
		base.updatePositionsData(data)

		static carIDs := false
		static lastDriverCar := false
		static lastRead := false
		static standings := false

		if (this.SessionState == kSessionRace)
			this.requireUDPClient()
		else if !this.UDPClient
			return

		if !carIDs
			carIDs := getConfigurationSectionValues(readConfiguration(kResourcesDirectory . "Simulator Data\AC\Car Data.ini"), "Car IDs", Object())

		if ((A_Now + 5000) > lastRead) {
			lastRead := (A_Now + 0)

			fileName := kTempDirectory . "ACUDP.cmd"

			FileAppend Read, %fileName%

			tries := 10

			while FileExist(fileName) {
				Sleep 200

				if (--tries <= 0)
					break
			}

			if (tries > 0) {
				fileName := kTempDirectory . "ACUDP.out"

				standings := readConfiguration(fileName)

				try {
					FileDelete %fileName%
				}
				catch exception {
					; ignore
				}
			}
			else {
				standings := false

				try {
					FileDelete %fileName%
				}
				catch exception {
					; ignore
				}

				this.iUDPClient := false
			}
		}

		if standings {
			if (getConfigurationValue(data, "Stint Data", "Laps", 0) <= 1)
				lastDriverCar := false

			driverForname := getConfigurationValue(data, "Stint Data", "DriverForname", "John")
			driverSurname := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
			driverNickname := getConfigurationValue(data, "Stint Data", "DriverNickname", "JDO")

			lapTime := getConfigurationValue(data, "Stint Data", "LapLastTime", 0)

			driverCar := false

			Loop {
				carID := getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Car", kUndefined)

				if (carID == kUndefined)
					break
				else {
					car := (carIDs.HasKey(carID) ? carIDs[carID] : "Unknown")

					if ((car = "Unknown") && isDebug())
						showMessage("Unknown car with ID " . carID . " detected...")

					setConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Car", car)

					if !driverCar {
						if ((getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Driver.Forname") = driverForname)
						 && (getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Driver.Surname") = driverSurname)) {
							driverCar := A_Index

							lastDriverCar := driverCar
						}
						else if (getConfigurationValue(standings, "Position Data", "Car." . A_Index . ".Time") = lapTime)
							driverCar := A_index
					}
				}
			}

			if !driverCar
				driverCar := lastDriverCar

			setConfigurationValue(standings, "Position Data", "Driver.Car", driverCar)
			setConfigurationSectionValues(data, "Position Data", getConfigurationSectionValues(standings, "Position Data"))
		}
	}

	updateSessionData(data) {
		base.updateSessionData(data)

		setConfigurationValue(data, "Car Data", "TC", Round((getConfigurationValue(data, "Car Data", "TCRaw", 0) / 0.2) * 10))
		setConfigurationValue(data, "Car Data", "ABS", Round((getConfigurationValue(data, "Car Data", "ABSRaw", 0) / 0.2) * 10))

		grip := getConfigurationValue(data, "Track Data", "GripRaw", 1)
		grip := Round(6 - (((1 - grip) / 0.15) * 6))
		grip := ["Dusty", "Old", "Slow", "Green", "Fast", "Optimum"][Max(1, grip)]

		setConfigurationValue(data, "Track Data", "Grip", grip)

		forName := getConfigurationValue(data, "Stint Data", "DriverForname", "John")
		surName := getConfigurationValue(data, "Stint Data", "DriverSurname", "Doe")
		nickName := getConfigurationValue(data, "Stint Data", "DriverNickname", "JDO")

		if ((forName = surName) && (surName = nickName)) {
			name := string2Values(A_Space, forName, 2)

			setConfigurationValue(data, "Stint Data", "DriverForname", name[1])
			setConfigurationValue(data, "Stint Data", "DriverSurname", (name.Length() > 1) ? name[2] : "")
			setConfigurationValue(data, "Stint Data", "DriverNickname", "")
		}

		compound := getConfigurationValue(data, "Car Data", "TyreCompoundRaw", "Dry")

		if (InStr(compound, "SemiSlick") = 1)
			compoundColor := "Soft"
		else if (InStr(compound, "Street") = 1)
			compoundColor := "Hard"
		else if (InStr(compound, "Slick") = 1) {
			compoundColor := string2Values(A_Space, compound)

			if (compoundColor.Length() > 1) {
				compoundColor := compoundColor[2]

				if !inList(["Hard", "Medium", "Soft"], compoundColor)
					compoundColor := "Black"
			}
			else
				compoundColor := "Black"
		}
		else
			compoundColor := "Black"

		setConfigurationValue(data, "Car Data", "TyreCompound", "Dry")
		setConfigurationValue(data, "Car Data", "TyreCompoundColor", compoundColor)

		if !isDebug() {
			removeConfigurationValue(data, "Car Data", "TCRaw")
			removeConfigurationValue(data, "Car Data", "ABSRaw")
			removeConfigurationValue(data, "Car Data", "TyreCompoundRaw")
			removeConfigurationValue(data, "Track Data", "GripRaw")
		}

		if !getConfigurationValue(data, "Stint Data", "InPit", false)
			if (getConfigurationValue(data, "Car Data", "FuelRemaining", 0) = 0)
				setConfigurationValue(data, "Session Data", "Paused", true)
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
		if (A_Now < this.iPitstopAutoClose) {
			this.iPitstopAutoClose := (A_Now + 4000)

			return true
		}
		else {
			Sleep 1200

			this.iPitstopAutoClose := (A_Now + 4000)

			return this.openPitstopMFD()
		}
	}

	selectPitstopOption(option) {
		car := (this.Car ? this.Car : "*")
		track := (this.Track ? this.Track : "*")

		carSettings := this.SettingsDatabase.getSettingValue(this.Simulator[true], car, track, "*"
														   , "Simulator.Assetto Corsa Settings", "Pitstop.Car.Settings", 0)

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
				Loop % 7 + carSettings
					this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Repair Suspension") {
				Loop % 8 + carSettings
					this.sendPitstopCommand(this.NextOptionHotkey)

				return true
			}
			else if (option = "Repair Engine") {
				Loop % 9 + carSettings
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
					Loop %steps%
						this.sendPitstopCommand(this.NextChoiceHotkey)
				case "Decrease":
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
		if (this.OpenPitstopMFDHotkey != "Off") {
			this.requirePitstopMFD()

			if this.selectPitstopOption("Refuel") {
				this.dialPitstopOption("Refuel", "Decrease", 200)
				this.dialPitstopOption("Refuel", "Increase", Round(litres))
			}
		}
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			simulator := this.Simulator[true]
			car := (this.Car ? this.Car : "*")
			track := (this.Track ? this.Track : "*")

			showMessage(simulator . A_Space . car . A_Space . track)

			frontLeftMin := this.SettingsDatabase.getSettingValue(simulator, car, track, "*", "Simulator.Assetto Corsa Settings", "Pitstop.Pressures.Front.Left.Min", 15)
			frontRightMin := this.SettingsDatabase.getSettingValue(simulator, car, track, "*", "Simulator.Assetto Corsa Settings", "Pitstop.Pressures.Front.Right.Min", 15)
			rearLeftMin := this.SettingsDatabase.getSettingValue(simulator, car, track, "*", "Simulator.Assetto Corsa Settings", "Pitstop.Pressures.Rear.Left.Min", 15)
			rearRightMin := this.SettingsDatabase.getSettingValue(simulator, car, track, "*", "Simulator.Assetto Corsa Settings", "Pitstop.Pressures.Rear.Right.Min", 15)

			this.requirePitstopMFD()

			if this.selectPitstopOption("Front Left") {
				this.dialPitstopOption("Front Left", "Decrease", 30)

				Loop % Round(pressureFL - frontLeftMin)
					this.dialPitstopOption("Front Left", "Increase")
			}

			if this.selectPitstopOption("Front Right") {
				this.dialPitstopOption("Front Right", "Decrease", 30)

				Loop % Round(pressureFR - frontRightMin)
					this.dialPitstopOption("Front Right", "Increase")
			}

			if this.selectPitstopOption("Rear Left") {
				this.dialPitstopOption("Rear Left", "Decrease", 30)

				Loop % Round(pressureRL - rearLeftMin)
					this.dialPitstopOption("Rear Left", "Increase")
			}

			if this.selectPitstopOption("Rear Right") {
				this.dialPitstopOption("Rear Right", "Decrease", 30)

				Loop % Round(pressureRR - rearRightMin)
					this.dialPitstopOption("Rear Right", "Increase")
			}
		}
	}

	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		if (this.OpenPitstopMFDHotkey != "Off") {
			this.requirePitstopMFD()

			if this.selectPitstopOption("Tyre Compound") {
				this.dialPitstopOption("Tyre Compound", "Decrease", 10)

				if (compound = "Dry") {
					if (compoundColor = "Soft")
						steps := 1
					else if (compoundColor = "Medium")
						steps := 2
					else if (compoundColor = "Hard")
						steps := 3
					else
						steps := 2

					this.dialPitstopOption("Tyre Compound", "Increase", steps)
				}
			}
		}
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork, repairEngine := false) {
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
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kACPlugin).Simulator, "Simulator Splash Images\AC Splash.jpg")
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
