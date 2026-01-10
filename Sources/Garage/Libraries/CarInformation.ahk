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

getCarValue(simulator, car, type) {
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
	return getCarValue(simulator, car, "SteerLock")
}

getCarSteerRatio(simulator, car) {
	return getCarValue(simulator, car, "SteerRatio")
}

getCarWheelbase(simulator, car) {
	return getCarValue(simulator, car, "Wheelbase")
}

getCarTrackWidth(simulator, car) {
	return getCarValue(simulator, car, "TrackWidth")
}