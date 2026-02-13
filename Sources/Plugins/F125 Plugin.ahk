;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - F125 Plugin                     ;;;
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

global kF125Application := "F1 25"

global kF125Plugin := "F125"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class F125Plugin extends RaceAssistantSimulatorPlugin {
	__New(controller, name, simulator, configuration := false) {
		local multiCastGroup := "127.0.0.1"
		local multiCastPort := 20777
		local multiCast := true
		local connection, udpConfiguration

		super.__New(controller, name, simulator, configuration, false)

		if (this.Active || (isDebug() && isDevelopment())) {
			connection := this.getArgumentValue("udpConnection", false)
			udpConfiguration := newMultiMap()

			if connection {
				connection := string2Values(",", connection)

				multiCastGroup := ((connection.Length > 0) ? connection[1] : "127.0.0.1")
				multiCastPort := ((connection.Length > 1) ? connection[2] : 20777)
				multiCast := ((connection.Length > 2) ? (connection[3] = "true") : true)
			}

			setMultiMapValue(udpConfiguration, "UDP", "MultiCastGroup", multiCastGroup)
			setMultiMapValue(udpConfiguration, "UDP", "Port", multiCastPort)
			setMultiMapValue(udpConfiguration, "UDP", "MultiCast", multiCast)

			writeMultiMap(kUserConfigDirectory . "F125 Configuration.ini", udpConfiguration)

			controller.registerPlugin(this)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                     Function Hook Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

startF125(executable := false) {
	return SimulatorController.Instance.startSimulator(SimulatorController.Instance.findPlugin(kF125Plugin).Simulator
													 , "Simulator Splash Images\F125 Splash.jpg"
													 , executable)
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeF125Plugin() {
	local controller := SimulatorController.Instance

	F125Plugin(controller, kF125Plugin, kF125Application, controller.Configuration)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeF125Plugin()