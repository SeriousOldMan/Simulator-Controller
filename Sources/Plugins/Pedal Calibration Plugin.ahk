;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Pedal Calibration Plugin        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kPedalCalibrationPlugin = "Pedal Calibration"
global kPedalCalibrationMode = "Pedal Calibration"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kCurveShapes := ["Linear", "Sense+1", "Sense+2", "Sense-1", "Sense-2", "S-Shape", "S on Side", "Slow Start", "Slow End"]

global kClutchXPosition = 235
global kBrakeXPosition = 555
global kThrottleXPosition = 875

global kShapeYPosition := 315
global kShapeYDelta := 20

global kSaveToPedalX := 940
global kSaveToPedalY := 785


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class PedalCalibrationPlugin extends ControllerPlugin {
	iSmartCtrlApplication := false
	iPedalProfileMode := false
	
	class PedalProfileMode extends ControllerMode {
		Mode[] {
			Get {
				return kPedalCalibrationMode
			}
		}
	}
	
	class CurveShapeAction extends ControllerAction {
		iPedal := false
		iShape := false
		iSelectionIndex := false
		iSelectionXPosition := false
		
		Pedal[] {
			Get {
				return this.iPedal
			}
		}
		
		Shape[] {
			Get {
				return this.iShape
			}
		}
		
		__New(function, label, pedal, shape) {
			this.iPedal := pedal
			this.iShape := shape
			this.iSelectionIndex := inList(kCurveShapes, shape)
			
			if !this.iSelectionIndex
				Throw "Unknown calibration shape """ . shape . """ detected in CurveShapeAction.__New..."
			
			switch pedal {
				case "Clutch":
					this.iSelectionXPosition := kClutchXPosition
				case "Brake":
					this.iSelectionXPosition := kBrakeXPosition
				case "Throttle":
					this.iSelectionXPosition := kThrottleXPosition
				default:
					Throw "Unknown pedal type """ . pedal . """ detected in CurveShapeAction.__New..."
			}
				
			base.__New(function, label)
		}
		
		fireAction(function, trigger) {
			local application := SimulatorController.Instance.findPlugin(kPedalCalibrationPlugin).Application
			windowTitle := application.WindowTitle
			wasRunning := application.isRunning()
			
			if !wasRunning
				application.startup()
			
			try {
				WinWait %windowTitle%, , 5
			
				WinActivate %windowTitle%
				WinWaitActive %windowTitle%, , 2
				
				xPosition := this.iSelectionXPosition
				yPosition := kShapeYPosition
				
				MouseClick Left, %xPosition%, %yPosition%
				Sleep 2000
				
				yPosition += (this.iSelectionIndex * kShapeYDelta)
				
				MouseClick Left, %xPosition%, %yPosition%
				Sleep 2000
				
				Sleep 10000
				MouseClick Left, %kSaveToPedalX%, %kSaveToPedalY%
				
				trayMessage(translate(this.Pedal), translate("Calibration: ") . this.Shape)
			}
			finally {
				if !wasRunning
					application.shutdown()
				else
					WinMinimize %windowTitle%
			}
		}
	}
	
	Application[] {
		Get {
			return this.iSmartCtrlApplication
		}
	}
	
	__New(controller, name, configuration := false) {
		base.__New(controller, name, configuration, false)
		
		this.iSmartCtrlApplication := new Application(this.getArgumentValue("controlApplication", kPedalCalibrationPlugin), configuration)
	
		smartCtrl := this.iSmartCtrlApplication.ExePath
		
		if (!smartCtrl || !FileExist(smartCtrl)) {
			logMessage(kLogCritical, translate("Plugin Pedal Calibration deactivated, because the configured application path (") . smartCtrl . translate(") cannot be found - please check the configuration"))
			
			if !isDebug()
				return
		}
		
		this.iPedalProfileMode := new this.PedalProfileMode(this)
		
		this.registerMode(this.iPedalProfileMode)
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("pedalCalibrations", ""))
			this.createPedalCalibrationAction(controller, string2Values(A_Space, theAction)*)
		
		controller.registerPlugin(this)
	}
	
	createPedalCalibrationAction(controller, pedalAndShape, descriptor) {
		local function := this.Controller.findFunction(descriptor)
		
		pedalAndShape := ConfigurationItem.splitDescriptor(pedalAndShape)
		pedal := pedalAndShape[1]
		shape := StrReplace(pedalAndShape[2], "_", A_Space)
		
		label := translate(pedal) . " " . shape
		
		if (function != false)
			this.iPedalProfileMode.registerAction(new this.CurveShapeAction(function, label, pedal, shape))
		else
			this.logFunctionNotFound(descriptor)
	}
}

													 
;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializePedalCalibrationPlugin() {
	local controller := SimulatorController.Instance
	
	new PedalCalibrationPlugin(controller, kPedalCalibrationPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializePedalCalibrationPlugin()
