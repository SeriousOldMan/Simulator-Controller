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
#Include "RF2 Plugin.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kLMUApplication := "Le Mans Ultimate"

global kLMUPlugin := "LMU"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class LMUPlugin extends RF2Plugin {
	parseCarName(carName, &model?, &nr?, &category?, &team?) {
		if ((carName != "") && isNumber(SubStr(carName, 1, 1))) {
			nr := this.parseNr(carName, &carName)

			super.parseCarName(carName, &model, , &category, &team)
		}
		else
			super.parseCarName(carName, &model, &nr, &category, &team)
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
