;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - PMR Plugin                      ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Libraries\SimulatorPlugin.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kPMRApplication := "Project Motor Racing"

global kPMRPlugin := "PMR"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class PMRPlugin extends RaceAssistantSimulatorPlugin {
	__New(controller, name, simulator, configuration := false) {
		local multiCastGroup := "224.0.0.150"
		local multiCastPort := 7576
		local multiCast := true
		local connection, udpConfiguration

		super.__New(controller, name, simulator, configuration, false)

		if (this.Active || (isDebug() && isDevelopment())) {
			connection := this.getArgumentValue("udpConnection", false)
			udpConfiguration := newMultiMap()

			if connection {
				connection := string2Values(",", connection)

				multiCastGroup := ((connection.Length > 0) ? connection[1] : "224.0.0.150")
				multiCastPort := ((connection.Length > 1) ? connection[2] : 7576)
				multiCast := ((connection.Length > 2) ? (connection[3] = "true") : true)
			}

			setMultiMapValue(udpConfiguration, "UDP", "MultiCastGroup", multiCastGroup)
			setMultiMapValue(udpConfiguration, "UDP", "Port", multiCastPort)
			setMultiMapValue(udpConfiguration, "UDP", "MultiCast", multiCast)

			writeMultiMap(kUserConfigDirectory . "PMR Configuration.ini", udpConfiguration)

			controller.registerPlugin(this)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startPMR(executable := false) {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kPMRPlugin).Simulator
													 , "Simulator Splash Images\PMR Splash.jpg"
													 , executable)
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializePMRPlugin() {
	local controller := SimulatorController.Instance

	PMRPlugin(controller, kPMRPlugin, kPMRApplication, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializePMRPlugin()