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
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global vTargetLanguageCode := "en"

global vLocalizationCallbacks := []


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

getPressureUnit(translate := false) {
	return (translate ? translate("PSI") : "PSI")
}

getSpeedUnit(translate := false) {
	return (translate ? translate("km/h") : "km/h")
}

getDistanceUnit(translate := false) {
	return (translate ? translate("meter") : "meter")
}

getWeightUnit(translate := false) {
	return (translate ? translate("kg") : "kg")
}

getFloatSeparator() {
	return "."
}

displayPressureValue(value) {
	return value
}

displayDistanceValue(value) {
	return value
}

displaySpeedValue(value) {
	return value
}

displayWeightValue(value) {
	return value
}

displayFloatValue(value) {
	return StrReplace(value, ".", getFloatSeparator())
}

internalPressureValue(value) {
	return value
}

internalDistanceValue(value) {
	return value
}

internalSpeedValue(value) {
	return value
}

internalWeightValue(value) {
	return value
}

internalFloatValue(value) {
	return StrReplace(value, getFloatSeparator(), ".")
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
		case "Distance":
			return getDistanceUnit(translate)
		case "Speed":
			return getSpeedUnit(translate)
		case "Weight":
			return getWeightUnit(translate)
	}
}

displayValue(type, value) {
	switch type {
		case "Pressure":
			return displayPressureValue(value)
		case "Distance":
			return displayDistanceValue(value)
		case "Speed":
			return displaySpeedValue(value)
		case "Weight":
			return displayWeightValue(value)
		case "Float":
			return displayFloatValue(value)
	}
}

internalValue(type, value) {
	switch type {
		case "Pressure":
			return internalPressureValue(value)
		case "Distance":
			return internalDistanceValue(value)
		case "Speed":
			return internalSpeedValue(value)
		case "Weight":
			return internalWeightValue(value)
		case "Float":
			return internalFloatValue(value)
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