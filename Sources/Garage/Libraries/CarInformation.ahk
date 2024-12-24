;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Car Information                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Functions Section                        ;;;
;;;-------------------------------------------------------------------------;;;

getCarSteerLock(simulator, car) {
	local fileName

	simulator := SettingsDatabase.getSimulatorName(simulator)
	car := SettingsDatabase.getCarName(simulator, car)

	fileName := getFileName("Garage\Definitions\Cars\" . simulator . "." . car . ".ini", kResourcesDirectory, kUserHomeDirectory)

	if FileExist(fileName) {
		configuration := readMultiMap(fileName)

		steerLock := getMultiMapValue(configuration, "Setup.General", "SteerLock", kUndefined)

		if (steerLock != kUndefined)
			return steerLock
	}

	return getMultiMapValue(readMultiMap(kUserConfigDirectory . "Application Settings.ini"), "Telemetry Collector"
						  , (simulator . "." . car . ".*.") . "SteerLock", false)
}