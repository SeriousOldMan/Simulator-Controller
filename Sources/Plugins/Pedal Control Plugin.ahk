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
