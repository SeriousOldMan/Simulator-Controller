;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Translation Validator           ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2024) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                       Global Declaration Section                        ;;;
;;;-------------------------------------------------------------------------;;;

#Requires AutoHotkey >=v2.0
#SingleInstance Force			; Ony one instance allowed
#Warn							; Enable warnings to assist with detecting common errors.
#Warn LocalSameAsGlobal, Off

SendMode("Input")					; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir(A_ScriptDir)			; Ensures a consistent starting directory.

ListLines(false)					; Disable execution history

;@Ahk2Exe-SetMainIcon ..\..\Resources\Icons\Tools.ico
;@Ahk2Exe-ExeName Shared Database Creator.exe

global kBuildConfiguration := "Development"


;;;-------------------------------------------------------------------------;;;
;;;                         Global Include Section                          ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Application.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class AbstractTranslations {
	Code := "EN"
	Language := "English"

	Translations := CaseInsenseMap()

	Errors := []

	class Original {
		Original := ""
		LeadingSpaces := 0
		TrailingSpaces := 0

		Translation {
			Get {
				return ""
			}
		}

		__New(original) {
			this.Original := original

			this.LeadingSpaces := (StrLen(original) - StrLen(LTrim(original)))
			this.TrailingSpaces := (StrLen(original) - StrLen(RTrim(original)))
		}

		adjustTranslation(translation, spaces := true) {
			createSpaces(count) {
				local spaces := ""

				loop count
					spaces .= A_Space

				return spaces
			}

			if spaces
				return (createSpaces(this.LeadingSpaces) . Trim(translation) . createSpaces(this.TrailingSpaces))
			else
				return Trim(translation)
		}
	}

	class Translation {
		Original := ""
		Translation := ""

		__New(original, translation) {
			this.Original := original
			this.Translation := translation
		}
	}

	__New(code := "EN", language := "English") {
		this.Code := code
		this.Language := language
	}

	load(fileName := false) {
		local section := false
		local translation, entry
		local text

		if !fileName
			fileName := (kSourcesDirectory . "Configuration\Translations\Translations." . this.Code)

		text := FileRead(fileName)

		loop Parse, text, "`n", "`r" {
			translation := A_LoopField

			if (SubStr(translation, 1, 1) = "[")
				section := SubStr(translation, 2, -1)
			else if (Trim(translation) != "") {
				translation := StrReplace(translation, "\=", "=")
				translation := StrReplace(translation, "\\", "\")
				translation := StrReplace(translation, "\n", "`n")

				if (section != "Locale") {
					entry := StrSplit(translation, "=>")

					if (entry.Length = 2)
						this.put(entry[1], entry[2])
					else
						this.Errors.Push("Invalid entry in Translations." . this.Code . ": " . translation)
				}
			}
		}
	}

	save(fileName) {
		local progress := 0
		local text := ""

		deleteFile(fileName)

		text .= "[Locale]`n"
		text .= (this.Code . "=>" . this.Language . "`n")
		text .= "[Translations]`n"

		showProgress({Progress: progress, title: "Working"})

		for ignore, translations in this.Translations
			for ignore, translation in translations {
				showProgress({Progress: progress++})

				text .= (encode(translation.Original) . "=>" . encode(translation.Translation) . "`n")

				if (progress >= 100)
					progress := 0
			}

		FileAppend(text, fileName, "UTF-16")

		hideProgress()
	}

	put(original, translation) {
		throw "Virtual method called..."
	}

	adjust(translated) {
		local translations, found

		for key, originals in this.Translations {
			translations := []

			if translated.Translations.Has(key) {
				for ignore, candidate in originals {
					found := false

					for ignore, trans in translated.Translations[key]
						if ((trans.Original = candidate.Original) && (Trim(trans.Translation) != "")) {
							translations.Push(AbstractTranslations.Translation(candidate.Original
																			 , candidate.adjustTranslation(trans.Translation
																										 , this.Code != "EN")))

							found := true

							break
						}

					if !found
						translations.Push(candidate)
				}
			}
			else
				for ignore, candidate in originals
					translations.Push(candidate)

			translated.Translations[key] := translations
		}
	}

	reportErrors(&stream) {
		for ignore, error in this.Errors
			stream .= (error . "`n")
	}

	reportMissing(&stream, translated) {
		local found

		for key, originals in this.Translations
			if !translated.Translations.Has(key) {
				for ignore, candidate in originals
					stream .= ("Missing translation for: " . candidate.Original . "`n")
			}
			else
				for ignore, candidate in originals {
					found := false

					for ignore, trans in translated.Translations[key]
						if ((trans.Original = candidate.Original) && (Trim(trans.Translation) != "")) {
							found := true

							break
						}

					if !found
						stream .= "Missing translation for " . candidate.Original . "...`n"
				}
	}
}

class Originals extends AbstractTranslations {
	put(original, translation) {
		local key := Trim(original)

		if !this.Translations.Has(key)
			this.Translations[key] := []

		for ignore, candidate in this.Translations[key]
			if (candidate.Original = original)
				return

		this.Translations[key].Push(AbstractTranslations.Original(original))
	}
}

class Translations extends AbstractTranslations {
	Inconsistencies := []

	put(original, translation) {
		local key := Trim(original)

		if !this.Translations.Has(key)
			this.Translations[key] := []

		for ignore, candidate in this.Translations[key]
			if (candidate.Original = original) {
				if (candidate.Translation != translation)
					this.Inconsistencies.Push(original . "=>" candidate.Translation . " ||| " . translation)

				return
			}

		this.Translations[key].Push(AbstractTranslations.Translation(original, translation))
	}

	reportInconsistencies(&stream) {
		for ignore, error in this.Inconsistencies
			stream .= (error . "`n")
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                    Private Function Declaration Section                 ;;;
;;;-------------------------------------------------------------------------;;;

runValidator(code, language, folder) {
	local orig := Originals()
	local trans := Translations(code, language)
	local report

	folder := (normalizeDirectoryPath(folder) . "\")

	showProgress({title: "Loading"})

	orig.load()
	trans.load(folder . "Translations." . code)

	report := "-- Errors in Originals --`n"
	orig.reportErrors(&report)

	report .= "`n-- Errors in Translations --`n"
	trans.reportErrors(&report)

	report .= "`n-- Missing in Translations --`n"
	orig.reportMissing(&report, trans)

	report .= "`n-- Inconsistent in Translations --`n"
	trans.reportInconsistencies(&report)

	orig.adjust(trans)

	trans.save(folder . "Translations." . code . ".new")

	deleteFile(folder . "Translation Validation.report")
	FileAppend(report, folder . "Translation Validation.report", "UTF-16")

	ExitApp()
}


;;;-------------------------------------------------------------------------;;;
;;;                          Initialization Section                         ;;;
;;;-------------------------------------------------------------------------;;;

runValidator("IT", "Italiano", "C:\Users\olive\Desktop\Translation")