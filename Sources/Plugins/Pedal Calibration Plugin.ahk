;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Pedal Calibration Plugin        ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kPedalCalibrationPlugin = "Pedal Calibration"
global kPedalCalibrationMode = "Pedal Calibration"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kCurveShapes := ["Linear", "Sense+1", "Sense+2", "Sense-1", "Sense-2", "S-Shape", "S on Side", "Slow Start", "Slow End", "Custom"]

/* For SmartControl Version 1.3+ - but not working at the moment, due to an error in SmartControl...
global kClutchXPosition = 235
global kBrakeXPosition = 555
global kThrottleXPosition = 875

global kShapeYPosition := 315
global kShapeYDelta := 20

global kSaveToPedalX := 940
global kSaveToPedalY := 785
*/

global kClutchXPosition = 205
global kBrakeXPosition = 530
global kThrottleXPosition = 845

global kShapeYPosition := 245
global kShapeYDelta := 20

global kSaveToPedalX := 865
global kSaveToPedalY := 710

global kNeedsActivation := true


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

		__New(function, label, icon, pedal, shape) {
			this.iPedal := pedal
			this.iShape := shape
			this.iSelectionIndex := inList(kCurveShapes, shape)

			if !this.iSelectionIndex
				throw "Unknown calibration shape """ . shape . """ detected in CurveShapeAction.__New..."

			switch pedal {
				case "Clutch":
					this.iSelectionXPosition := kClutchXPosition
				case "Brake":
					this.iSelectionXPosition := kBrakeXPosition
				case "Throttle":
					this.iSelectionXPosition := kThrottleXPosition
				default:
					throw "Unknown pedal type """ . pedal . """ detected in CurveShapeAction.__New..."
			}

			base.__New(function, label, icon)
		}

		fireAction(function, trigger) {
			local application := SimulatorController.Instance.findPlugin(kPedalCalibrationPlugin).Application
			local windowTitle := application.WindowTitle
			local wasRunning := application.isRunning()
			local xPosition, yPosition

			if !wasRunning
				application.startup()

			try {
				WinWait %windowTitle%, , 5

				if kNeedsActivation {
					WinMove %windowTitle%, , 50, 50
					WinSet AlwaysOnTop, On, %windowTitle%
					WinSet Top, , %windowTitle%

					WinActivate %windowTitle%

					if (!WinActive(windowTitle) && SimulatorController.Instance.ActiveSimulator) {
						Send !{Tab}

						WinActivate %windowTitle%
					}

					if WinActive(windowTitle) {
						xPosition := this.iSelectionXPosition
						yPosition := kShapeYPosition

						MouseClick Left, %xPosition%, %yPosition%

						Sleep 500

						yPosition += (this.iSelectionIndex * kShapeYDelta)

						MouseClick Left, %xPosition%, %yPosition%

						Sleep 500

						MouseClick Left, %kSaveToPedalX%, %kSaveToPedalY%
					}
				}
				else {
					xPosition := this.iSelectionXPosition
					yPosition := kShapeYPosition

					ControlClick X%xPosition% Y%yPosition%, %windowTitle%, , , , NA

					Sleep 500

					yPosition += (this.iSelectionIndex * kShapeYDelta)

					ControlClick X%xPosition% Y%yPosition%, %windowTitle%, , , , NA

					Sleep 500

					ControlClick X%kSaveToPedalX% Y%yPosition%, %kSaveToPedalY%, , , , NA
				}

				trayMessage(translate(this.Pedal), translate("Calibration: ") . this.Shape)

				Sleep 500
			}
			finally {
				if !wasRunning
					application.shutdown()
				else {
					WinSet AlwaysOnTop, Off, %windowTitle%

					WinMinimize %windowTitle%
				}
			}
		}
	}

	Application[] {
		Get {
			return this.iSmartCtrlApplication
		}
	}

	__New(controller, name, configuration := false, register := true) {
		local smartCtrl, ignore, theAction

		base.__New(controller, name, configuration, false)

		if (this.Active || isDebug()) {
			this.iSmartCtrlApplication := new Application(this.getArgumentValue("controlApplication", kPedalCalibrationPlugin), configuration)

			smartCtrl := this.iSmartCtrlApplication.ExePath

			if (!smartCtrl || !FileExist(smartCtrl)) {
				logMessage(kLogCritical, translate("Plugin Pedal Calibration deactivated, because the configured application path (") . smartCtrl . translate(") cannot be found - please check the configuration"))

				if !isDebug()
					return false
			}

			this.iPedalProfileMode := new this.PedalProfileMode(this)

			this.registerMode(this.iPedalProfileMode)

			for ignore, theAction in string2Values(",", this.getArgumentValue("pedalCalibrations", ""))
				this.createPedalCalibrationAction(controller, this.parseValues(A_Space, theAction)*)

			if register
				controller.registerPlugin(this)
		}
	}

	createPedalCalibrationAction(controller, pedalAndShape, descriptor) {
		local function := this.Controller.findFunction(descriptor)
		local pedal, shape, label, icon

		pedalAndShape := ConfigurationItem.splitDescriptor(pedalAndShape)
		pedal := pedalAndShape[1]
		shape := StrReplace(pedalAndShape[2], "_", A_Space)

		label := translate(pedal) . "`n" . shape

		if (function != false) {
			icon := this.getIcon("CurveShape." . shape . ".Activate", this.getIcon("CurveShape.Activate"))

			this.iPedalProfileMode.registerAction(new this.CurveShapeAction(function, label, icon, pedal, shape))
		}
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
