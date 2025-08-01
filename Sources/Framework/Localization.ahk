﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Collection Functions            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "Constants.ahk"
#Include "Variables.ahk"
#Include "Debug.ahk"
#Include "Files.ahk"
#Include "Collections.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Math.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                        Public Constants Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kMassUnits := ["Kilogram", "Pound"]
global kTemperatureUnits := ["Celsius", "Fahrenheit"]
global kPressureUnits := ["Bar", "PSI", "KPa"]
global kVolumeUnits := ["Liter", "Gallon (US)", "Gallon (GB)"]
global kLengthUnits := ["Meter", "Yard"]
global kSpeedUnits := ["km/h", "mph"]

global kNumberFormats := ["#.##", "#,##"]
global kTimeFormats := ["[H:]M:S.##", "[H:]M:S,##", "S.##", "S,##"]


;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global gTargetLanguageCode := "en"

global gLocalizationCallbacks := []

global gMassUnit := "Kilogram"
global gTemperatureUnit := "Celcius"
global gPressureUnit := "PSI"
global gVolumeUnit := "Liter"
global gLengthUnit := "Meter"
global gSpeedUnit := "km/h"
global gNumberFormat := "#.##"
global gTimeFormat := "[H:]M:S.##"


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

readLanguage(targetLanguageCode) {
	local translations := Map()
	local translation

	loop Read, getFileName("Translations." . targetLanguageCode, kUserTranslationsDirectory, kTranslationsDirectory) {
		translation := StrSplit(A_LoopReadLine, "=>")

		if (translation[1] = targetLanguageCode)
			return translation[2]
	}

	if isDebug()
		throw "Inconsistent translation encountered for `"" . targetLanguageCode . "`" in readLanguage..."
	else
		logError("Inconsistent translation encountered for `"" . targetLanguageCode . "`" in readLanguage...")
}

getTemperatureUnit(trans := false) {
	global gTemperatureUnit

	return (trans ? translate(gTemperatureUnit) : gTemperatureUnit)
}

getPressureUnit(trans := false) {
	global gPressureUnit

	return (trans ? translate(gPressureUnit) : gPressureUnit)
}

getSpeedUnit(trans := false) {
	global gSpeedUnit

	return (trans ? translate(gSpeedUnit) : gSpeedUnit)
}

getLengthUnit(trans := false) {
	global gLengthUnit

	return (trans ? translate(gLengthUnit) : gLengthUnit)
}

getMassUnit(trans := false) {
	global gMassUnit

	return (trans ? translate(gMassUnit) : gMassUnit)
}

getVolumeUnit(trans := false) {
	global gVolumeUnit

	return (trans ? translate(gVolumeUnit) : gVolumeUnit)
}

displayTemperatureValue(celsius, rnd) {
	global gTemperatureUnit

	if isNumber(celsius) {
		switch gTemperatureUnit, false {
			case "Celsius":
				return (rnd ? Round(celsius, 1) : celsius)
			case "Fahrenheit":
				return (rnd ? Round(((celsius * 1.8) + 32), 1) : ((celsius * 1.8) + 32))
			default:
				throw "Unknown temperature unit detected in displayTemperatureValue..."
		}
	}
	else
		return celsius
}

displayPressureValue(psi, rnd) {
	global gPressureUnit

	if isNumber(psi) {
		switch gPressureUnit, false {
			case "PSI":
				return (rnd ? Round(psi, 1) : psi)
			case "Bar":
				return (rnd ? Round(psi / 14.503773, 2) : (psi / 14.503773))
			case "KPa":
				return (rnd ? Round(psi * 6.894757) : (psi * 6.894757))
			default:
				throw "Unknown pressure unit detected in displayPressureValue..."
		}
	}
	else
		return psi
}

displayLengthValue(meter, rnd) {
	global gLengthUnit

	if isNumber(meter) {
		switch gLengthUnit, false {
			case "Meter":
				return (rnd ? Round(meter, 1) : meter)
			case "Yard":
				return (rnd ? Round(meter * 0.9144) : (meter * 0.9144))
			default:
				throw "Unknown length unit detected in displayLengthValue..."
		}
	}
	else
		return meter
}

displaySpeedValue(kmh, rnd) {
	global gSpeedUnit

	if isNumber(kmh) {
		switch gSpeedUnit, false {
			case "km/h":
				return (rnd ? Round(kmh, 1) : kmh)
			case "mph":
				return (rnd ? Round(kmh / 1.609344, 1) : (kmh / 1.609344))
			default:
				throw "Unknown speed unit detected in displaySpeedValue..."
		}
	}
	else
		return kmh
}

displayMassValue(kilogram, rnd) {
	global gMassUnit

	if isNumber(kilogram) {
		switch gMassUnit, false {
			case "Kilogram":
				return (rnd ? Round(kilogram, 1) : kilogram)
			case "Pound":
				return (rnd ? Round(kilogram * 2.204623): (kilogram * 2.204623))
			default:
				throw "Unknown mass unit detected in displayMassValue..."
		}
	}
	else
		return kilogram
}

displayVolumeValue(liter, rnd) {
	global gVolumeUnit

	if isNumber(liter) {
		switch gVolumeUnit, false {
			case "Liter":
				return (rnd ? Round(liter, 1) : liter)
			case "Gallon (US)":
				return (rnd ? Round(liter / 3.785411, 2) : (liter / 3.785411))
			case "Gallon (GB)", "Gallon":
				return (rnd ? Round(liter / 4.546092, 2) : (liter / 4.546092))
			default:
				throw "Unknown volume unit detected in displayVolumeValue..."
		}
	}
	else
		return liter
}

displayFloatValue(float, precision := kUndefined) {
	if isNumber(float) {
		if (precision = kUndefined)
			return StrReplace(float, ".", getFloatSeparator())
		else if (precision = 0)
			return Round(float)
		else
			return StrReplace(Round(float, precision), ".", getFloatSeparator())
	}
	else
		return float
}

displayTimeValue(time, fillHours := false, withSeconds := true, withFractions := true, arguments*) {
	global gTimeFormat

	local sign := (signum(time) < 0)
	local hours, seconds, fraction, minutes

	if isNumber(time) {
		if ((gTimeFormat = "S.##") || (gTimeFormat = "S,##"))
			return StrReplace(time, ".", (gTimeFormat = "S.##") ? "." : ",")
		else {
			time := Abs(time)

			seconds := Floor(time)
			fraction := (time - seconds)
			minutes := Floor(seconds / 60)
			hours := Floor(minutes / 60)

			minutes -= (hours * 60)

			fraction := Round(fraction * 10)

			seconds := ((seconds - (minutes * 60) - (hours * 3600)) . "")

			if (StrLen(seconds) = 1)
				seconds := ("0" . seconds)

			if fillHours {
				hours := (Format("{1:02}", hours) . ":")
				minutes := Format("{1:02}", minutes)
			}
			else if (hours > 0) {
				hours := (hours . ":")
				minutes := Format("{1:02}", minutes)
			}
			else
				hours := ""

			return ((sign ? "-" : "") . (hours . minutes . (withSeconds ? (":" . seconds . (withFractions ? (((gTimeFormat = "[H:]M:S.##") ? "." : ",") . fraction) : "")) : "")))
		}
	}
	else
		return time
}

internalPressureValue(value, rnd, unit := false) {
	global gPressureUnit

	if !unit
		unit := gPressureUnit

	if isNumber(value) {
		switch unit, false {
			case "PSI":
				return (rnd ? Round(value, 1) : value)
			case "Bar":
				return (rnd ? Round(value * 14.503773, 2) : (value * 14.503773))
			case "KPa":
				return (rnd ? Round(value / 6.894757) : (value / 6.894757))
			default:
				throw "Unknown pressure unit detected in internalPressureValue..."
		}
	}
	else
		return value
}

internalTemperatureValue(value, rnd, unit := false) {
	global gTemperatureUnit

	if !unit
		unit := gTemperatureUnit

	if isNumber(value) {
		switch unit, false {
			case "Celsius":
				return (rnd ? Round(value, 1) : value)
			case "Fahrenheit":
				return (rnd ? Round((value - 32) / 1.8, 1) : ((value - 32) / 1.8))
			default:
				throw "Unknown temperature unit detected in internalTemperatureValue..."
		}
	}
	else
		return value
}

internalLengthValue(value, rnd, unit := false) {
	global gLengthUnit

	if !unit
		unit := gLengthUnit

	if isNumber(value) {
		switch unit, false {
			case "Meter":
				return (rnd ? Round(value, 1) : value)
			case "Yard":
				return (rnd ? Round(value / 0.9144) : (value / 0.9144))
			default:
				throw "Unknown length unit detected in internalLengthValue..."
		}
	}
	else
		return value
}

internalSpeedValue(value, rnd, unit := false) {
	global gSpeedUnit

	if !unit
		unit := gSpeedUnit

	if isNumber(value) {
		switch unit, false {
			case "km/h":
				return (rnd ? Round(value, 1) : value)
			case "mph":
				return (rnd ? Round(value * 1.609344, 1) : (value * 1.609344))
			default:
				throw "Unknown speed unit detected in internalSpeedValue..."
		}
	}
	else
		return value
}

internalMassValue(value, rnd, unit := false) {
	global gMassUnit

	if !unit
		unit := gMassUnit

	if isNumber(value) {
		switch unit, false {
			case "Kilogram":
				return (rnd ? Round(value, 1) : value)
			case "Pound":
				return (rnd ? Round(value / 2.204623) : (value / 2.204623))
			default:
				throw "Unknown mass unit detected in internalMassValue..."
		}
	}
	else
		return value
}

internalVolumeValue(value, rnd, unit := false) {
	global gVolumeUnit

	if !unit
		unit := gVolumeUnit

	if isNumber(value) {
		switch unit, false {
			case "Liter":
				return (rnd ? Round(value, 1) : value)
			case "Gallon (US)":
				return (rnd ? Round(value * 3.785411, 2) : (value * 3.785411))
			case "Gallon (GB)", "Gallon":
				return (rnd ? Round(value * 4.546092, 2) : (value * 4.546092))
			default:
				throw "Unknown volume unit detected in internalVolumeValue..."
		}
	}
	else
		return value
}

internalFloatValue(value, precision := kUndefined) {
	if (precision = kUndefined)
		return StrReplace(value, getFloatSeparator(), ".")
	else if isNumber(value)
		return Round(StrReplace(value, getFloatSeparator(), "."), precision)
	else
		return value
}

internalTimeValue(time, arguments*) {
	global gTimeFormat

	local seconds, fraction

	if (gTimeFormat = "S,##")
		return StrReplace(time, ",", ".")
	else if (gTimeFormat = "S.##")
		return time
	else {
		seconds := StrSplit(time, (gTimeFormat = "S,##") ? "," : ".")

		if (seconds.Length = 1) {
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

		switch seconds.Length, false {
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
	global gMassUnit, gTemperatureUnit, gPressureUnit, gVolumeUnit, gLengthUnit, gSpeedUnit, gNumberFormat, gTimeFormat

	local configuration := readMultiMap(kSimulatorConfigurationFile)

	gMassUnit := getMultiMapValue(configuration, "Localization", "MassUnit", "Kilogram")
	gTemperatureUnit := getMultiMapValue(configuration, "Localization", "TemperatureUnit", "Celsius")
	gPressureUnit := getMultiMapValue(configuration, "Localization", "PressureUnit", "PSI")
	gVolumeUnit := getMultiMapValue(configuration, "Localization", "VolumeUnit", "Liter")
	gLengthUnit := getMultiMapValue(configuration, "Localization", "LengthUnit", "Meter")
	gSpeedUnit := getMultiMapValue(configuration, "Localization", "SpeedUnit", "km/h")

	gNumberFormat := getMultiMapValue(configuration, "Localization", "NumberFormat", "#.##")
	gTimeFormat := getMultiMapValue(configuration, "Localization", "TimeFormat", "H:M:S.##")

	if (gVolumeUnit = "Gallon")
		gVolumeUnit := "Gallon (GB)"
}


;;;-------------------------------------------------------------------------;;;
;;;                    Public Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

availableLanguages() {
	local translations := CaseInsenseMap("en", "English")
	local ignore, fileName, languageCode

	for ignore, fileName in getFileNames("Translations.*", kUserTranslationsDirectory, kTranslationsDirectory) {
		SplitPath(fileName, , , &languageCode)

		translations[languageCode] := readLanguage(languageCode)
	}

	return translations
}

readTranslations(targetLanguageCode, withUserTranslations := true, fromEditor := false) {
	local fileNames := []
	local fileName := (kTranslationsDirectory . "Translations." . targetLanguageCode)
	local translations := CaseInsenseMap()
	local section := false
	local translation, ignore, enString, missingTranslations, inconsistentTranslations

	readOriginals() {
		local section := false
		local fileNames := [kTranslationsDirectory . "Translations.EN"]
		local fileName, orginals, translation, ignore

		fileName := (kUserTranslationsDirectory . "Translations.EN")

		if FileExist(fileName)
			fileNames.Push(fileName)

		originals := CaseInsenseMap()

		for ignore, fileName in fileNames
			loop Read, fileName {
				translation := A_LoopReadLine

				if (SubStr(translation, 1, 1) = "[")
					section := SubStr(translation, 2, -1)
				else if (Trim(translation) != "") {
					translation := StrReplace(translation, "\=", "=")
					translation := StrReplace(translation, "\\", "\")
					translation := StrReplace(translation, "\n", "`n")

					if (section != "Locale")
						originals[StrSplit(translation, "=>")[1]] := true
				}
			}

		return originals
	}

	if FileExist(fileName)
		fileNames.Push(fileName)

	if withUserTranslations {
		fileName := (kUserTranslationsDirectory . "Translations." . targetLanguageCode)

		if FileExist(fileName)
			fileNames.Push(fileName)
	}

	if isDebug() {
		inconsistentTranslations := CaseInsenseMap()

		for ignore, fileName in fileNames
			loop Read, fileName {
				translation := A_LoopReadLine

				if (SubStr(translation, 1, 1) = "[")
					section := SubStr(translation, 2, -1)
				else if ((Trim(translation) != "") && (section != "Locale")) {
					translation := StrReplace(translation, "\=", "=")
					translation := StrReplace(translation, "\\", "\")
					translation := StrReplace(translation, "\n", "`n")

					translation := StrSplit(translation, "=>")
					enString := translation[1]

					if ((SubStr(enString, 1, 1) != "[") && (fromEditor || (targetLanguageCode != "en")))
						if (!fromEditor && ((translation.Length < 2) || (translations.Has(enString) && (translations[enString] != translation[2]))))
							inconsistentTranslations[enString] := true
						else
							translations[enString] := ((translation.Length < 2) ? "" : translation[2])
				}
			}

		if (isDebug() && (targetLanguageCode != "en")) {
			missingTranslations := CaseInsenseMap()

			for enString, ignore in readOriginals()
				if !translations.Has(enString)
					missingTranslations[enString] := true

			deleteFile(kTempDirectory . "Translations.report")

			FileAppend("Missing:`n", kTempDirectory . "Translations.report")

			for enString, ignore in missingTranslations
				FileAppend("`n" . enString, kTempDirectory . "Translations.report")

			FileAppend("`n`nInconsistent:`n", kTempDirectory . "Translations.report")

			for enString, ignore in inconsistentTranslations
				FileAppend("`n" . enString, kTempDirectory . "Translations.report")
		}
	}
	else
		for ignore, fileName in fileNames
			loop Read, fileName {
				translation := A_LoopReadLine

				if (Trim(translation) != "") {
					translation := StrReplace(translation, "\=", "=")
					translation := StrReplace(translation, "\\", "\")
					translation := StrReplace(translation, "\n", "`n")

					translation := StrSplit(translation, "=>")
					enString := translation[1]

					if ((SubStr(enString, 1, 1) != "[") && (fromEditor || (targetLanguageCode != "en")))
						translations[enString] := ((translation.Length < 2) ? "" : translation[2])
				}
			}

	return translations
}

writeTranslations(languageCode, languageName, translations) {
	local fileName := kUserTranslationsDirectory . "Translations." . languageCode
	local stdTranslations := readTranslations(languageCode, false, false)
	local hasValues := false
	local ignore, key, value, temp, curEncoding, original, translation

	for ignore, value in stdTranslations {
		hasValues := true

		break
	}

	if hasValues {
		temp := CaseInsenseMap()

		for key, value in translations
			if (!stdTranslations.Has(key) || (stdTranslations[key] != value))
				temp[key] := value

		translations := temp
	}

	deleteFile(fileName)

	curEncoding := A_FileEncoding

	FileEncoding("UTF-16")

	try {
		FileAppend("[Locale]`n", fileName)
		FileAppend(languageCode . "=>" . languageName . "`n", fileName)
		FileAppend("[Translations]", fileName)

		for original, translation in translations {
			original := StrReplace(original, "\", "\\")
			original := StrReplace(original, "=", "\=")
			original := StrReplace(original, "`n", "\n")

			translation := StrReplace(translation, "\", "\\")
			translation := StrReplace(translation, "=", "\=")
			translation := StrReplace(translation, "`n", "\n")

			FileAppend("`n" . original . "=>" . translation, fileName)
		}
	}
	finally {
		FileEncoding(curEncoding)
	}
}

translate(string, targetLanguageCode := false) {
	global gTargetLanguageCode

	local theTranslations, translation

	static currentLanguageCode := "en"
	static translations := false
	static cachedTranslations := CaseInsenseMap()

	if (targetLanguageCode && (targetLanguageCode = "en"))
		return string
	else if (targetLanguageCode && (targetLanguageCode != gTargetLanguageCode)) {
		if (cachedTranslations.Has(targetLanguageCode))
			theTranslations := cachedTranslations[targetLanguageCode]
		else {
			theTranslations := readTranslations(targetLanguageCode)

			cachedTranslations[targetLanguageCode] := theTranslations
		}

		if theTranslations.Has(string) {
			translation := theTranslations[string]

			return ((translation != "") ? translation : string)
		}
		else
			return string
	}
	else if (gTargetLanguageCode != "en") {
		if (gTargetLanguageCode != currentLanguageCode) {
			currentLanguageCode := gTargetLanguageCode

			cachedTranslations := CaseInsenseMap()

			translations := readTranslations(currentLanguageCode)
		}

		if (translations && translations.Has(string)) {
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
	global gLocalizationCallbacks, gTargetLanguageCode

	local igore, callback

	if (gTargetLanguageCode != languageCode) {
		gTargetLanguageCode := languageCode

		for ignore, callback in gLocalizationCallbacks.Clone()
			callback.Call({Language: languageCode})
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
	global gTargetLanguageCode

	return gTargetLanguageCode
}

registerLocalizationCallback(callback) {
	global gLocalizationCallbacks

	gLocalizationCallbacks.Push(callback)
}

getUnit(type, translate := false) {
	switch type, false {
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
		default:
			throw "Unknown unit type detected in getUnit..."
	}
}

getFloatSeparator() {
	global gNumberFormat

	return (gNumberFormat == "#.##" ? "." : ",")
}

convertUnit(type, value, display := true, rnd := true) {
	if (display == true) {
		switch type, false {
			case "Pressure":
				return displayPressureValue(value, rnd)
			case "Temperature":
				return displayTemperatureValue(value, rnd)
			case "Length":
				return displayLengthValue(value, rnd)
			case "Speed":
				return displaySpeedValue(value, rnd)
			case "Mass":
				return displayMassValue(value, rnd)
			case "Volume":
				return displayVolumeValue(value, rnd)
			default:
				throw "Unknown unit type detected in convertUnit..."
		}
	}
	else if display {
		switch type, false {
			case "Pressure":
				return internalPressureValue(value, rnd, display)
			case "Temperature":
				return internalTemperatureValue(value, rnd, display)
			case "Length":
				return internalLengthValue(value, rnd, display)
			case "Speed":
				return internalSpeedValue(value, rnd, display)
			case "Mass":
				return internalMassValue(value, rnd, display)
			case "Volume":
				return internalVolumeValue(value, rnd, display)
			default:
				throw "Unknown unit type detected in convertUnit..."
		}
	}
	else
		switch type, false {
			case "Pressure":
				return internalPressureValue(value, rnd)
			case "Temperature":
				return internalTemperatureValue(value, rnd)
			case "Length":
				return internalLengthValue(value, rnd)
			case "Speed":
				return internalSpeedValue(value, rnd)
			case "Mass":
				return internalMassValue(value, rnd)
			case "Volume":
				return internalVolumeValue(value, rnd)
			default:
				throw "Unknown unit type detected in convertUnit..."
		}
}

displayValue(type, value, arguments*) {
	switch type, false {
		case "Float":
			return displayFloatValue(value, arguments*)
		case "Time":
			return displayTimeValue(value, arguments*)
		default:
			throw "Unknown format type detected in displayValue..."
	}
}

internalValue(type, value, arguments*) {
	switch type, false {
		case "Float":
			return internalFloatValue(value, arguments*)
		case "Time":
			return internalTimeValue(value, arguments*)
		default:
			throw "Unknown format type detected in internalValue..."
	}
}

validNumber(value, display := false) {
	if isInteger(value)
		return true
	else {
		if display
			value := StrReplace(value, getFloatSeparator(), ".")

		if isFloat(value)
			return true
		else
			return false
	}
}

getFormat(type) {
	global gNumberFormat, gTimeFormat

	switch type, false {
		case "Float":
			return gNumberFormat
		case "Time":
			return gTimeFormat
		default:
			throw "Unknown format type detected in getFormat..."
	}
}

setFormat(type, format) {
	global gNumberFormat, gTimeFormat

	local oldFormat

	switch type, false {
		case "Float":
			oldFormat := gNumberFormat

			gNumberFormat := format
		case "Time":
			oldFormat := gTimeFormat

			gTimeFormat := format
		default:
			throw "Unknown format type detected in setFormat..."
	}

	return oldFormat
}

withFormat(type, format, function, arguments*) {
	local oldFormat := setFormat(type, format)

	try {
		function.Call(arguments*)
	}
	finally {
		setFormat(type, oldFormat)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

initializeLocalization()