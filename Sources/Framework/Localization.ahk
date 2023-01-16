;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Collection Functions            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Framework\Constants.ahk
#Include ..\Framework\Variables.ahk
#Include ..\Framework\Debug.ahk
#Include ..\Framework\Files.ahk
#Include ..\Framework\Collections.ahk


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constants Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kMassUnits := ["Kilogram", "Pound"]
global kTemperatureUnits := ["Celsius", "Fahrenheit"]
global kPressureUnits := ["Bar", "PSI", "KPa"]
global kVolumeUnits := ["Liter", "Gallon"]
global kLengthUnits := ["Meter", "Foot"]
global kSpeedUnits := ["km/h", "mph"]

global kNumberFormats := ["#.##", "#,##"]
global kTimeFormats := ["[H:]M:S.##", "[H:]M:S,##", "S.##", "S,##"]


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vTargetLanguageCode := "en"

global vLocalizationCallbacks := []

global vMassUnit := "Kilogram"
global vTemperatureUnit := "Celcius"
global vPressureUnit := "PSI"
global vVolumeUnit := "Liter"
global vLengthUnit := "Meter"
global vSpeedUnit := "km/h"
global vNumberFormat := "#.##"
global vTimeFormat := "[H:]M:S.##"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

readLanguage(targetLanguageCode) {
	local translations := {}
	local translation

	loop Read, % getFileName("Translations." . targetLanguageCode, kUserTranslationsDirectory, kTranslationsDirectory)
	{
		translation := StrSplit(A_LoopReadLine, "=>")

		if (translation[1] = targetLanguageCode)
			return translation[2]
	}

	if isDebug()
		throw "Inconsistent translation encountered for """ . targetLanguageCode . """ in readLanguage..."
	else
		logError("Inconsistent translation encountered for """ . targetLanguageCode . """ in readLanguage...")
}

getTemperatureUnit(translate := false) {
	return (translate ? translate(vTemperatureUnit) : vTemperatureUnit)
}

getPressureUnit(translate := false) {
	return (translate ? translate(vPressureUnit) : vPressureUnit)
}

getSpeedUnit(translate := false) {
	return (translate ? translate(vSpeedUnit) : vSpeedUnit)
}

getLengthUnit(translate := false) {
	return (translate ? translate(vLengthUnit) : vLengthUnit)
}

getMassUnit(translate := false) {
	return (translate ? translate(vMassUnit) : vMassUnit)
}

getVolumeUnit(translate := false) {
	return (translate ? translate(vVolumeUnit) : vMassUnit)
}

displayTemperatureValue(celsius, round) {
	switch vTemperatureUnit {
		case "Celsius":
			return (round ? Round(celsius, 1) : celsius)
		case "Fahrenheit":
			return (round ? Round(((celsius * 1.8) + 32), 1) : ((celsius * 1.8) + 32))
		default:
			throw "Unknown temperature unit detected in displayTemperatureValue..."
	}
}

displayPressureValue(psi, round) {
	switch vPressureUnit {
		case "PSI":
			return (round ? Round(psi, 1) : psi)
		case "Bar":
			return (round ? Round(psi / 14.503773, 2) : (psi / 14.503773))
		case "KPa":
			return (round ? Round(psi * 6.894757) : (psi * 6.894757))
		default:
			throw "Unknown pressure unit detected in displayPressureValue..."
	}
}

displayLengthValue(meter, round) {
	switch vLengthUnit {
		case "Meter":
			return (round ? Round(meter, 1) : meter)
		case "Foot":
			return (round ? Round(meter * 3.280840) : (meter * 3.280840))
		default:
			throw "Unknown length unit detected in displayLengthValue..."
	}
}

displaySpeedValue(kmh, round) {
	switch vSpeedUnit {
		case "km/h":
			return (round ? Round(kmh, 1) : kmh)
		case "mph":
			return (round ? Round(kmh / 1.609344, 1) : (kmh / 1.609344))
		default:
			throw "Unknown speed unit detected in displaySpeedValue..."
	}
}

displayMassValue(kilogram, round) {
	switch vMassUnit {
		case "Kilogram":
			return (round ? Round(kilogram, 1) : kilogram)
		case "Pound":
			return (round ? Round(kilogram * 2.204623): (kilogram * 2.204623))
		default:
			throw "Unknown mass unit detected in displayMassValue..."
	}
}

displayVolumeValue(liter, round) {
	switch vVolumeUnit {
		case "Liter":
			return (round ? Round(liter, 1) : liter)
		case "Gallon":
			return (round ? Round(liter / 4.546092, 2) : (liter / 4.546092))
		default:
			throw "Unknown volume unit detected in displayVolumeValue..."
	}
}

displayFloatValue(float, precision := "__Undefined__") {
	if (precision = kUndefined)
		return StrReplace(float, ".", getFloatSeparator())
	else
		return StrReplace(Round(float, precision), ".", getFloatSeparator())
}

displayTimeValue(time, arguments*) {
	local hours, seconds, fraction, minutes

	if ((vTimeFormat = "S.##") || (vTimeFormat = "S,##"))
		return StrReplace(time, ".", (vTimeFormat = "S.##") ? "." : ",")
	else {
		seconds := Floor(time)
		fraction := (time - seconds)
		minutes := Floor(seconds / 60)
		hours := Floor(seconds / 3600)

		fraction := Round(fraction * 10)

		seconds := ((seconds - (minutes * 60)) . "")

		if (StrLen(seconds) = 1)
			seconds := ("0" . seconds)

		return (((hours > 0) ? (hours . ":") : "") . minutes . ":" . seconds . ((vTimeFormat = "[H:]M:S.##") ? "." : ",") . fraction)
	}
}

internalPressureValue(value, round) {
	switch vPressureUnit {
		case "PSI":
			return (round ? Round(value, 1) : value)
		case "Bar":
			return (round ? Round(value * 14.503773, 2) : value)
		case "KPa":
			return (round ? Round(value / 6.894757) : value)
		default:
			throw "Unknown pressure unit detected in internalPressureValue..."
	}
}

internalTemperatureValue(value, round) {
	switch vTemperatureUnit {
		case "Celsius":
			return (round ? Round(value, 1) : value)
		case "Fahrenheit":
			return (round ? Round(((value - 32) / 1.8), 1) : value)
		default:
			throw "Unknown temperature unit detected in internalTemperatureValue..."
	}
}

internalLengthValue(value, round) {
	switch vLengthUnit {
		case "Meter":
			return (round ? Round(value, 1) : value)
		case "Foot":
			return (round ? Round(value / 3.280840) : value)
		default:
			throw "Unknown length unit detected in internalLengthValue..."
	}
}

internalSpeedValue(value, round) {
	switch vSpeedUnit {
		case "km/h":
			return (round ? Round(value, 1) : value)
		case "mph":
			return (round ? Round(value * 1.609344, 1) : value)
		default:
			throw "Unknown speed unit detected in internalSpeedValue..."
	}
}

internalMassValue(value, round) {
	switch vMassUnit {
		case "Kilogram":
			return (round ? Round(value, 1) : value)
		case "Pound":
			return (round ? Round(value / 2.204623) : value)
		default:
			throw "Unknown mass unit detected in internalMassValue..."
	}
}

internalVolumeValue(value, round) {
	switch vVolumeUnit {
		case "Liter":
			return (round ? Round(value, 1) : value)
		case "Gallon":
			return (round ? Round(value * 4.546092, 2) : value)
		default:
			throw "Unknown volume unit detected in internalVolumeValue..."
	}
}

internalFloatValue(value, precision := "__Undefined__") {
	if (precision = kUndefined)
		return StrReplace(value, getFloatSeparator(), ".")
	else
		return Round(StrReplace(value, getFloatSeparator(), "."), precision)
}

internalTimeValue(time, arguments*) {
	local seconds, fraction

	if (vTimeFormat = "S,##")
		return StrReplace(time, ",", ".")
	else if (vTimeFormat = "S.##")
		return value
	else {
		seconds := StrSplit(time, (vTimeFormat = "S,##") ? "," : ".")

		if (seconds.Length() = 1) {
			seconds := seconds[1]
			fraction := 0
		}
		else {
			fraction := seconds[2]
			seconds := seconds[1]
		}

		if (fraction > 0)
			if (StrLen(fraction) = 1)
				fraction /= 10
			else
				fraction /= 100

		seconds := StrSplit(seconds, ":")

		switch seconds.Length() {
			case 3:
				return ((seconds[1] * 3600) + (seconds[2] * 60) + seconds[3] + fraction)
			case 2:
				return ((seconds[1] * 60) + seconds[2] + fraction)
			case 1:
				return (seconds[1] + fraction)
			default:
				throw "Invalid format detected in internalTimeValue..."
		}
	}
}

initializeLocalization() {
	local configuration := readConfiguration(kSimulatorConfigurationFile)

	vMassUnit := getConfigurationValue(configuration, "Localization", "MassUnit", "Kilogram")
	vTemperatureUnit := getConfigurationValue(configuration, "Localization", "TemperatureUnit", "Celsius")
	vPressureUnit := getConfigurationValue(configuration, "Localization", "PressureUnit", "PSI")
	vVolumeUnit := getConfigurationValue(configuration, "Localization", "VolumeUnit", "Liter")
	vLengthUnit := getConfigurationValue(configuration, "Localization", "LengthUnit", "Meter")
	vSpeedUnit := getConfigurationValue(configuration, "Localization", "SpeedUnit", "km/h")

	vNumberFormat := getConfigurationValue(configuration, "Localization", "NumberFormat", "#.##")
	vTimeFormat := getConfigurationValue(configuration, "Localization", "TimeFormat", "H:M:S.##")
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

availableLanguages() {
	local translations := {en: "English"}
	local ignore, fileName, languageCode

	for ignore, fileName in getFileNames("Translations.*", kUserTranslationsDirectory, kTranslationsDirectory) {
		SplitPath fileName, , , languageCode

		translations[languageCode] := readLanguage(languageCode)
	}

	return translations
}

readTranslations(targetLanguageCode, withUserTranslations := true) {
	local fileNames := []
	local fileName := (kTranslationsDirectory . "Translations." . targetLanguageCode)
	local translations, translation, ignore, enString

	if FileExist(fileName)
		fileNames.Push(fileName)

	if withUserTranslations {
		fileName := (kUserTranslationsDirectory . "Translations." . targetLanguageCode)

		if FileExist(fileName)
			fileNames.Push(fileName)
	}

	translations := {}

	for ignore, fileName in fileNames
		loop Read, %fileName%
		{
			translation := A_LoopReadLine

			translation := StrReplace(translation, "\=", "=")
			translation := StrReplace(translation, "\\", "\")
			translation := StrReplace(translation, "\n", "`n")

			translation := StrSplit(translation, "=>")
			enString := translation[1]

			if ((SubStr(enString, 1, 1) != "[") && (enString != targetLanguageCode))
				if ((A_Index == 1) && (translations.HasKey(enString) && (translations[enString] != translation[2])))
					if isDebug()
						throw "Inconsistent translation encountered for """ . enString . """ in readTranslations..."
					else
						logError("Inconsistent translation encountered for """ . enString . """ in readTranslations...")

				translations[enString] := translation[2]
		}

	return translations
}

writeTranslations(languageCode, languageName, translations) {
	local fileName := kUserTranslationsDirectory . "Translations." . languageCode
	local stdTranslations := readTranslations(languageCode, false)
	local hasValues := false
	local ignore, key, value, temp, curEncoding, original, translation

	for ignore, value in stdTranslations {
		hasValues := true

		break
	}

	if hasValues {
		temp := {}

		for key, value in translations
			if (!stdTranslations.HasKey(key) || (stdTranslations[key] != value))
				temp[key] := value

		translations := temp
	}

	deleteFile(fileName)

	curEncoding := A_FileEncoding

	FileEncoding UTF-16

	try {
		FileAppend [Locale]`n, %fileName%
		FileAppend %languageCode%=>%languageName%`n, %fileName%
		FileAppend [Translations], %fileName%

		for original, translation in translations {
			original := StrReplace(original, "\", "\\")
			original := StrReplace(original, "=", "\=")
			original := StrReplace(original, "`n", "\n")

			translation := StrReplace(translation, "\", "\\")
			translation := StrReplace(translation, "=", "\=")
			translation := StrReplace(translation, "`n", "\n")

			FileAppend `n%original%=>%translation%, %fileName%
		}
	}
	finally {
		FileEncoding %curEncoding%
	}
}

translate(string, targetLanguageCode := false) {
	local theTranslations, translation

	static currentLanguageCode := "en"
	static translations := false

	if (targetLanguageCode && (targetLanguageCode != vTargetLanguageCode)) {
		theTranslations := readTranslations(targetLanguageCode)

		if theTranslations.HasKey(string) {
			translation := theTranslations[string]

			return ((translation != "") ? translation : string)
		}
		else
			return string
	}
	else if (vTargetLanguageCode != "en") {
		if (vTargetLanguageCode != currentLanguageCode) {
			currentLanguageCode := vTargetLanguageCode

			translations := readTranslations(currentLanguageCode)
		}

		if translations.HasKey(string) {
			translation := translations[string]

			return ((translation != "") ? translation : string)
		}
		else
			return string
	}
	else
		return string
}

setLanguage(languageCode) {
	local igore, callback

	if (vTargetLanguageCode != languageCode) {
		vTargetLanguageCode := languageCode

		for ignore, callback in vLocalizationCallbacks.Clone()
			%callback%({Language: languageCode})
	}
}

getLanguageFromLCID(lcid) {
	local code := SubStr(lcid, StrLen(lcid) - 1)

	if (code = "07")
		return "DE"
	else if (code = "0c")
		return "FR"
	else if (code = "0a")
		return "ES"
	else if (code = "10")
		return "IT"
	else
		return "EN"
}

getSystemLanguage() {
	return getLanguageFromLCID(A_Language)
}

getLanguage() {
	return vTargetLanguageCode
}

registerLocalizationCallback(callback) {
	vLocalizationCallbacks.Push(callback)
}

getUnit(type, translate := false) {
	switch type {
		case "Pressure":
			return getPressureUnit(translate)
		case "Temperature":
			return getTemperatureUnit(translate)
		case "Length":
			return getLengthUnit(translate)
		case "Speed":
			return getSpeedUnit(translate)
		case "Mass":
			return getMassUnit(translate)
		case "Volume":
			return getVolumeUnit(translate)
	}
}

getFloatSeparator() {
	return (vNumberFormat == "#.##" ? "." : ",")
}

convertUnit(type, value, display := true, round := true) {
	if display
		switch type {
			case "Pressure":
				return displayPressureValue(value, round)
			case "Temperature":
				return displayTemperatureValue(value, round)
			case "Length":
				return displayLengthValue(value, round)
			case "Speed":
				return displaySpeedValue(value, round)
			case "Mass":
				return displayMassValue(value, round)
			case "Volume":
				return displayVolumeValue(value, round)
		}
	else
		switch type {
			case "Pressure":
				return internalPressureValue(value, round)
			case "Temperature":
				return internalTemperatureValue(value, round)
			case "Length":
				return internalLengthValue(value, round)
			case "Speed":
				return internalSpeedValue(value, round)
			case "Mass":
				return internalMassValue(value, round)
			case "Volume":
				return internalVolumeValue(value, round)
		}
}

displayValue(type, value, arguments*) {
	switch type {
		case "Float":
			return displayFloatValue(value, arguments*)
		case "Time":
			return displayTimeValue(value, arguments*)
	}
}

internalValue(type, value, arguments*) {
	switch type {
		case "Float":
			return internalFloatValue(value, arguments*)
		case "Time":
			return internalTimeValue(value, arguments*)
	}
}

validNumber(value, display := false) {
	if value is Integer
		return true
	else {
		if display
			value := StrReplace(value, getFloatSeparator(), ".")

		if value is Float
			return true
		else
			return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

initializeLocalization()