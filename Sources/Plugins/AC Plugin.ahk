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


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kACApplication = "Assetto Corsa"

global kACPlugin = "AC"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ACPlugin extends RaceAssistantSimulatorPlugin {
	supportsRaceAssistant(assistantPlugin) {
		return ((assistantPlugin = kRaceEngineerPlugin) && base.supportsRaceAssistant(assistantPlugin))
	}

	updateSessionData(data) {
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

		if (InStr(compound, "Slick") = 1) {
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
