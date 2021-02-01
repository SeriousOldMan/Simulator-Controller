;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Pedal Control Plugin            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kPedalControlPlugin = "Pedal Control"
global kPedalProfileMode = "Pedal Profile"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kCurveShapes := ["Linear", "Sense+1", "Sense+2", "Sense-1", "Sense-2", "S-Shape", "S on Side", "Slow Start", "Slow End"]

global kClutchXPosition = 235
global kBrakeXPosition = 555
global kThrottleXPosition = 875
global kAllYPosition := 315

global kOptionYDelta := 20

global kSaveToPedalX := 940
global kSaveToPedalY := 785


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class PedalControlPlugin extends ControllerPlugin {
	iSmartCtrlApplication := false
	iPedalProfileMode := false
	
	class PedalProfileMode extends ControllerMode {
		Mode[] {
			Get {
				return kPedalProfileMode
			}
		}
	}
	
	class CurveShapeAction extends ControllerAction {
		iSelectionIndex := false
		iSelectionXPosition := false
	}
	
	class BrakeCurveShapeAction extends PedalControlPlugin.CurveShapeAction {
		
	
	}
	
	class ThrottleCurveShapeAction extends PedalControlPlugin.CurveShapeAction {
	
	}
	
	__New(controller, name, configuration := false) {
		this.iSmartCtrlApplication := new Application(kPedalControlPlugin, SimulatorController.Instance.Configuration)
		
		this.iPedalProfileMode := new this.PedalProfileMode(this)
		
		base.__New(controller, name, configuration)
		
		this.registerMode(this.iPedalProfileMode)
		
		for ignore, theAction in string2Values(",", this.getArgumentValue("pedalProfiles", ""))
			this.createPedalProfileAction(controller, string2Values(A_Space, theAction)*)
		
		controller.registerPlugin(this)
	}
	
	createPedalProfileAction(controller, label, selectFunction, profilePath) {
		local function := this.Controller.findFunction(selectFunction)
			
		if (function != false)
			this.iDriveMode.registerAction(new this.SelectProfileAction(function, this.getLabel(ConfigurationItem.descriptor(label, "Select"), profilePath)))
		else
			this.logFunctionNotFound(descriptor)
	}
}

													 
;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializePedalControlPlugin() {
	local controller := SimulatorController.Instance
	
	smartCtrl := getConfigurationValue(controller.Configuration, kPedalControlPlugin, "Exe Path", false)
	
	if (!smartCtrl || !FileExist(smartCtrl)) {
		logMessage(kLogCritical, translate("Plugin Pedal Control deactivated, because the configured application path (") . smartCtrl . translate(") cannot be found - please check the configuration"))
		
		if !isDebug()
			return
	}
	
	new PedalControlPlugin(controller, kPedalControlPlugin, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializePedalControlPlugin()
