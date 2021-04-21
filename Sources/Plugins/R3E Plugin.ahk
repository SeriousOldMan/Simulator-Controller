;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - R3E Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Plugins\Libraries\Simulator Plugin.ahk
#Include ..\Libraries\JSON.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kR3EApplication = "RaceRoom Racing Experience"

global kR3EPlugin = "R3E"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Constant Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kBinaryOptions = ["Change Front Tyres", "Change Rear Tyres", "Repair Aero Front", "Repair Aero Rear", "Repair Suspension", "Request Pitstop"]


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class R3EPlugin extends RaceEngineerSimulatorPlugin {
	iOpenPitstopMFDHotkey := false
	iClosePitstopMFDHotkey := false
	
	iPreviousOptionHotkey := false
	iNextOptionHotkey := false
	iPreviousChoiceHotkey := false
	iNextChoiceHotkey := false
	iAcceptChoiceHotkey := false
	
	iPSImageSearchArea := false
	iPitstopOptions := []
	iPitstopOptionStates := []
	
	OpenPitstopMFDHotkey[] {
		Get {
			return this.iOpenPitstopMFDHotkey
		}
	}
	
	ClosePitstopMFDHotkey[] {
		Get {
			return this.iClosePitstopMFDHotkey
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
	
	AcceptChoiceHotkey[] {
		Get {
			return this.iAcceptChoiceHotkey
		}
	}
	
	__New(controller, name, simulator, configuration := false) {
		base.__New(controller, name, simulator, configuration)
		
		this.iOpenPitstopMFDHotkey := this.getArgumentValue("openPitstopMFD", false)
		this.iClosePitstopMFDHotkey := this.getArgumentValue("closePitstopMFD", false)
		
		this.iPreviousOptionHotkey := this.getArgumentValue("previousOptionHotkey", "W")
		this.iNextOptionHotkey := this.getArgumentValue("nextOptionHotkey", "S")
		this.iPreviousChoiceHotkey := this.getArgumentValue("previousChoiceHotkey", "A")
		this.iNextChoiceHotkey := this.getArgumentValue("nextChoiceHotkey", "D")
		this.iAcceptChoiceHotkey := this.getArgumentValue("acceptChoiceHotkey", "{Enter}")
		
		SetKeyDelay, 5, 15
	}
	
	getPitstopActions(ByRef allActions, ByRef selectActions) {
		allActions := {Refuel: "Refuel", TyreChange: "Change Tyres", BodyworkRepair: "Repair Bodywork", SuspensionRepair: "Repair Suspension"}
		selectActions := []
	}
	
	activateR3EWindow() {
		window := this.Simulator.WindowTitle
		
		if !WinActive(window)
			WinActivate %window%
	}
	
	pitstopMFDIsOpen() {
		this.activateR3EWindow()
		
		return this.searchMFDImage("PITSTOP 1", "PITSTOP 2")
	}
		
	openPitstopMFD() {
		static first := true
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

		this.activateR3EWindow()

		secondTry := false
		
		if first
			SendEvent % this.OpenPitstopMFDHotkey
			
		if !this.pitstopMFDIsOpen() {
			SendEvent % this.OpenPitstopMFDHotkey
			
			secondTry := true
		}
		
		if (first && secondTry)
			this.pitstopMFDIsOpen()
		
		first := false
		
		return true
	}
	
	closePitstopMFD() {
		static reported := false
		
		this.activateR3EWindow()

		if this.pitstopMFDIsOpen() {
			if this.ClosePitstopMFDHotkey {
				SendEvent % this.ClosePitstopMFDHotkey
				
				Sleep 50
			}
			else if !reported {
				reported := true
			
				logMessage(kLogCritical, translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration"))
			
				showMessage(translate("The hotkeys for opening and closing the Pitstop MFD are undefined - please check the configuration...")
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
			}
		}
	}
	
	requirePitstopMFD() {
		if this.openPitstopMFD() {
			this.analyzePitstopMFD()
		
			return true
		}
		else
			return false
	}
	
	analyzePitstopMFD() {
		this.iPitstopOptions := []
		this.iPitstopOptionStates := []
		
		this.activateR3EWindow()

		Loop 15
			SendEvent % this.NextOptionHotkey
		
		if this.searchMFDImage("Refuel") {
			this.iPitstopOptions.Push("Refuel")
			this.iPitstopOptionStates.Push(true)
		}
		else if (this.searchMFDImage("No Refuel")) {
			this.iPitstopOptions.Push("Refuel")
			this.iPitstopOptionStates.Push(false)
		}
		
		if this.searchMFDImage("Front Tyre Change") {
			this.iPitstopOptions.Push("Change Front Tyres")
			this.iPitstopOptionStates.Push(true)
		}
		else { ; if this.searchMFDImage("No Front Tyre Change") {
			this.iPitstopOptions.Push("Change Front Tyres")
			this.iPitstopOptionStates.Push(false)
		}
		
		if this.searchMFDImage("Rear Tyre Change") {
			this.iPitstopOptions.Push("Change Rear Tyres")
			this.iPitstopOptionStates.Push(true)
		}
		else { ; if this.searchMFDImage("No Rear Tyre Change") {
			this.iPitstopOptions.Push("Change Rear Tyres")
			this.iPitstopOptionStates.Push(false)
		}
		
		if this.searchMFDImage("Front Damage") {
			this.iPitstopOptions.Push("Repair Aero Front")
			this.iPitstopOptionStates.Push(this.searchMFDImage("Front Damage Selected") != false)
		}
		
		/*
		if this.searchMFDImage("Rear Damage") {
			this.iPitstopOptions.Push("Repair Aero Rear")
			this.iPitstopOptionStates.Push(this.searchMFDImage("Rear Damage Selected") != false)
		}
		*/
		
		if this.searchMFDImage("Suspension Damage") {
			this.iPitstopOptions.Push("Repair Suspension")
			this.iPitstopOptionStates.Push(this.searchMFDImage("Suspension Damage Selected") != false)
		}
		
		if this.searchMFDImage("PIT REQUEST") {
			this.iPitstopOptions.Push("Request Pitstop")
			this.iPitstopOptionStates.Push(true)
		}
		else {
			this.iPitstopOptions.Push("Request Pitstop")
			this.iPitstopOptionStates.Push(false)
		}
	}
	
	optionAvailable(option) {
		return (this.optionIndex(option) != 0)
	}
	
	optionChosen(option) {
		index := this.optionIndex(option)
		
		return (index ? this.iPitstopOptionStates[index] : false)
	}
	
	optionIndex(option) {
		return inList(this.iPitstopOptions, option)
	}
	
	dialPitstopOption(option, action, steps := 1) {
		this.activateR3EWindow()

		switch action {
			case "Accept":
				SendEvent % this.AcceptChoiceHotkey
			case "Increase":
				Loop %steps%
					SendEvent % this.NextChoiceHotkey
			case "Decrease":
				Loop %steps%
					SendEvent % this.PreviousChoiceHotkey
			default:
				Throw "Unsupported change operation """ . action . """ detected in R3EPlugin.dialPitstopOption..."
		}
	}
	
	selectPitstopOption(option) {
		if (option = "Repair Bodywork")
			return (this.optionAvailable("Repair Aero Front") || this.optionAvailable("Repair Aero Rear"))
		else if (option = "Change Tyres")
			return (this.optionAvailable("Change Front Tyres") || this.optionAvailable("Change Rear Tyres"))
		else {
			this.activateR3EWindow()
			
			index := this.optionIndex(option)
			
			if index {
				this.activateR3EWindow()

				Loop 10
					SendEvent % this.PreviousOptionHotkey
				
				index -= 1
				
				if index
					Loop %index%
						SendEvent % this.NextOptionHotkey
				
				return true
			}
			else
				return false
		}
	}
	
	changePitstopOption(option, action, steps := 1) {
		if (option = "Refuel")
			this.changeFuelAmount(action, steps, false, false)
		else if (option = "Change Tyres") {
			this.toggleActivity("Change Front Tyres", false, true)
			this.toggleActivity("Change Rear Tyres", false, true)
		}
		else if (option = "Repair Bodywork") {
			this.toggleActivity("Repair Aero Front", false, true)
			this.toggleActivity("Repair Aero Rear", false, true)
		}
		else if (option = "Repair Suspension")
			this.toggleActivity("Repair Suspension", false, false)
		else
			Throw "Unsupported change operation """ . action . """ detected in R3EPlugin.changePitstopOption..."
	}
	
	toggleActivity(activity, require := true, select := true) {
		if inList(kBinaryOptions, activity) {
			if (!require || this.requirePitstopMFD())
				if  (!select || this.selectPitstopOption(activity))
					this.dialPitstopOption(activity, "Accept")
		}
		else
			Throw "Unsupported activity """ . activity . """ detected in R3EPlugin.toggleActivity..."
	}

	changeFuelAmount(direction, litres := 5, require := true, select := true) {
		if (!require || this.requirePitstopMFD())
			if (!select || this.selectPitstopOption("Refuel")) {
				if this.optionChosen("Refuel")
					SendEvent % this.AcceptChoiceHotkey
				
				this.dialPitstopOption("Refuel", direction, litres)

				SendEvent % this.AcceptChoiceHotkey
			}
	}
	
	supportsPitstop() {
		return true
	}
	
	startPitstopSetup(pitstopNumber) {
		this.requirePitstopMFD()
		
		if this.optionChosen("Request Pitstop")
			this.toggleActivity("Request Pitstop", false, true)
	}

	finishPitstopSetup(pitstopNumber) {
		this.activateR3EWindow()

		Loop 10
			SendEvent % this.NextOptionHotkey
		
		SendEvent % this.AcceptChoiceHotkey
	}

	setPitstopRefuelAmount(pitstopNumber, litres) {
		if this.optionAvailable("Refuel") {
			this.changeFuelAmount("Decrease", 120, false, true)
			
			this.changeFuelAmount("Increase", litres + 3, false, false)
		}
	}
	
	setPitstopTyreSet(pitstopNumber, compound, compoundColor := false, set := false) {
		if this.optionAvailable("Change Front Tyres")
			if (compound && !this.chosenOption("Change Front Tyres"))
				this.toggleActivity("Change Front Tyres", false, true)
			else if (!compound && this.chosenOption("Change Front Tyres"))
				this.toggleActivity("Change Front Tyres", false, true)

		if this.optionAvailable("Change Rear Tyres")
			if (compound && !this.chosenOption("Change Rear Tyres"))
				this.toggleActivity("Change Rear Tyres", false, true)
			else if (!compound && this.chosenOption("Change Rear Tyres"))
				this.toggleActivity("Change Rear Tyres", false, true)
	}

	setPitstopTyrePressures(pitstopNumber, pressureFL, pressureFR, pressureRL, pressureRR) {
	}

	requestPitstopRepairs(pitstopNumber, repairSuspension, repairBodywork) {
		if this.optionAvailable("Repair Suspension")
			if (repairSuspension != this.chosenOption("Repair Suspension"))
				this.toggleActivity("Repair Suspension", false, true)
		
		if this.optionAvailable("Repair Aero Front")
			if (repairBodywork != this.chosenOption("Repair Aero Front"))
				this.toggleActivity("Repair Aero Front", false, true)
		
		if this.optionAvailable("Repair Aero Rear")
			if (repairBodywork != this.chosenOption("Repair Aero Rear"))
				this.toggleActivity("Repair Aero Rear", false, true)
	}
	
	updateSimulatorData(data) {
		static carDB := false
		static lastCarID := false
		static lastCarName := false
		
		if !carDB {
			FileRead script, %kResourcesDirectory%Simulator Data\R3E\r3e-data.json
			
			carDB := JSON.parse(script)["cars"]
		}
		
		carID := getConfigurationValue(data, "Session Data", "Car", "")
		
		if (carID = lastCarID)
			setConfigurationValue(data, "Session Data", "Car", lastCarName)
		else {
			lastCarID := carID
			lastCarName := (carDB.HasKey(carID) ? carDB[carID]["Name"] : "Unknown")
			
			setConfigurationValue(data, "Session Data", "Car", lastCarName)
		}
	}
	
	getImageFileNames(imageNames*) {
		fileNames := []
		
		for ignore, imageName in imageNames {
			imageName := ("R3E\" . imageName)
			fileName := getFileName(imageName . ".png", kUserScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
			
			fileName := getFileName(imageName . ".jpg", kUserScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
			
			fileName := getFileName(imageName . ".png", kScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
			
			fileName := getFileName(imageName . ".jpg", kScreenImagesDirectory)
			
			if FileExist(fileName)
				fileNames.Push(fileName)
		}
		
		if (fileNames.Length() == 0)
			Throw "Unknown image '" . imageName . "' detected in R3EPlugin.getLabelFileName..."
		else {
			if isDebug()
				showMessage("Labels: " . values2String(", ", imageNames*) . "; Images: " . values2String(", ", fileNames*), "Pitstop MFD Image Search", "Information.png", 5000)
			
			return fileNames
		}
	}
	
	searchMFDImage(imageNames*) {
		static kSearchAreaLeft := 0
		static kSearchAreaRight := 400
		
		Loop % imageNames.Length()
		{
			imageName := imageNames[A_Index]
			pitstopImages := this.getImageFileNames(imageName)
			
			this.activateR3EWindow()
			
			curTickCount := A_TickCount
			
			imageX := kUndefined
			imageY := kUndefined
			
			Loop % pitstopImages.Length()
			{
				pitstopImage := pitstopImages[A_Index]
				
				if !this.iPSImageSearchArea {
					ImageSearch imageX, imageY, 0, 0, A_ScreenWidth, A_ScreenHeight, %pitstopImage%

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, substituteVariables(translate("Full search for '%image%' took %ticks% ms"), {image: imageName, ticks: A_TickCount - curTickCount}))
					
					if imageX is Integer
						if ((imageName = "PITSTOP 1") || (imageName = "PITSTOP 2"))
							this.iPSImageSearchArea := [Max(0, imageX - kSearchAreaLeft), 0, Min(imageX + kSearchAreaRight, A_ScreenWidth), A_ScreenHeight]
				}
				else {
					ImageSearch imageX, imageY, this.iPSImageSearchArea[1], this.iPSImageSearchArea[2], this.iPSImageSearchArea[3], this.iPSImageSearchArea[4], %pitstopImage%

					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, substituteVariables(translate("Fast search for '%image%' took %ticks% ms"), {image: imageName, ticks: A_TickCount - curTickCount}))
				}
				
				if imageX is Integer
				{
					if (getLogLevel() <= kLogInfo)
						logMessage(kLogInfo, substituteVariables(translate("'%image%' found at %x%, %y%"), {image: imageName, x: imageX, y: imageY}))
					
					return true
				}
			}
		}
		
		if (getLogLevel() <= kLogInfo)
			logMessage(kLogInfo, substituteVariables(translate("'%image%' not found"), {image: imageName}))
		
		return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startR3E() {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kR3EPlugin).Simulator, "Simulator Splash Images\R3E Splash.jpg")
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeR3EPlugin() {
	local controller := SimulatorController.Instance
	
	new R3EPlugin(controller, kR3EPlugin, kR3EApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeR3EPlugin()
