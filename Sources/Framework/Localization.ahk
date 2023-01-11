;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Collection Functions            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
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

getFloatSeparator() {
	return (vNumberFormat == "#.##" ? "." : ",")
}

displayTemperatureValue(celsius) {
	switch vTemperatureUnit {
		case "Celsius":
			return celsius
		case "Fahrenheit":
			return ((celsius * 1.8) + 32)
		default:
			throw "Unknown temperature unit detected in displayTemperatureValue..."
	}
}

displayPressureValue(psi) {
	switch vPressureUnit {
		case "PSI":
			return psi
		case "Bar":
			return psi / 14.503773
		case "KPa":
			return psi * 6.894757
		default:
			throw "Unknown pressure unit detected in displayPressureValue..."
	}
}

displayLengthValue(meter) {
	switch vLengthUnit {
		case "Meter":
			return meter
		case "Foot":
			return meter * 3.280840
		default:
			throw "Unknown length unit detected in displayLengthValue..."
	}
}

displaySpeedValue(kmh) {
	switch vSpeedUnit {
		case "km/h":
			return kmh
		case "mph":
			return kmh / 1.609344
		default:
			throw "Unknown speed unit detected in displaySpeedValue..."
	}
}

displayMassValue(kilogram) {
	switch vMassUnit {
		case "Kilogram":
			return kilogram
		case "Pound":
			return kilogram * 2.204623
		default:
			throw "Unknown mass unit detected in displayMassValue..."
	}
}

displayVolumeValue(liter) {
	switch vVolumeUnit {
		case "Liter":
			return liter
		case "Gallon":
			return liter / 4,546092
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

internalPressureValue(value) {
	switch vPressureUnit {
		case "PSI":
			return value
		case "Bar":
			return value * 14.503773
		case "KPa":
			return value / 6.894757
		default:
			throw "Unknown pressure unit detected in internalPressureValue..."
	}
}

internalTemperatureValue(value) {
	switch vTemperatureUnit {
		case "Celsius":
			return value
		case "Fahrenheit":
			return ((value - 32) / 1.8)
		default:
			throw "Unknown temperature unit detected in internalTemperatureValue..."
	}
}

internalLengthValue(value) {
	switch vLengthUnit {
		case "Meter":
			return value
		case "Foot":
			return value / 3.280840
		default:
			throw "Unknown length unit detected in internalLengthValue..."
	}
}

internalSpeedValue(value) {
	switch vSpeedUnit {
		case "km/h":
			return value
		case "mph":
			return value * 1.609344
		default:
			throw "Unknown speed unit detected in internalSpeedValue..."
	}
}

internalMassValue(value) {
	switch vMassUnit {
		case "Kilogram":
			return value
		case "Pound":
			return value / 2.204623
		default:
			throw "Unknown mass unit detected in internalMassValue..."
	}
}

internalVolumeValue(value) {
	switch vVolumeUnit {
		case "Liter":
			return value
		case "Gallon":
			return value * 4.546092
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

getUnit(unit, translate := false) {
	switch unit {
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

convertUnit(type, value, display := true) {
	if display
		switch type {
			case "Pressure":
				return displayPressureValue(value)
			case "Temperature":
				return displayTemperatureValue(value)
			case "Length":
				return displayLengthValue(value)
			case "Speed":
				return displaySpeedValue(value)
			case "Mass":
				return displayMassValue(value)
			case "Volume":
				return displayVolumeValue(value)
		}
	else
		switch type {
			case "Pressure":
				return internalPressureValue(value)
			case "Temperature":
				return internalTemperatureValue(value)
			case "Length":
				return internalLengthValue(value)
			case "Speed":
				return internalSpeedValue(value)
			case "Mass":
				return internalMassValue(value)
			case "Volume":
				return internalVolumeValue(value)
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