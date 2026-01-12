;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Car Information                 ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Private Functions Section                        ;;;
;;;-------------------------------------------------------------------------;;;

getCarInformation(simulator, car, type) {
	local fileName, value

	simulator := SettingsDatabase.getSimulatorName(simulator)
	car := SettingsDatabase.getCarName(simulator, car)

	fileName := getFileName("Garage\Definitions\Cars\" . simulator . "." . car . ".ini", kResourcesDirectory, kUserHomeDirectory)

	if FileExist(fileName) {
		configuration := readMultiMap(fileName)

		value := getMultiMapValue(configuration, "Setup.General", type, kUndefined)

		if (value != kUndefined)
			return value
	}

	return getMultiMapValue(readMultiMap(kUserConfigDirectory . "Issue Collector.ini"), "Settings"
						  , (simulator . "." . car . ".*.") . type, false)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Public Functions Section                        ;;;
;;;-------------------------------------------------------------------------;;;

getCarSteerLock(simulator, car) {
	return getCarInformation(simulator, car, "SteerLock")
}

getCarSteerRatio(simulator, car) {
	return getCarInformation(simulator, car, "SteerRatio")
}

getCarWheelbase(simulator, car) {
	return getCarInformation(simulator, car, "Wheelbase")
}

getCarTrackWidth(simulator, car) {
	return getCarInformation(simulator, car, "TrackWidth")
}