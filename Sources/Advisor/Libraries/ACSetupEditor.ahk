;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Editor for AC             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACSetup                                                                 ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACSetup extends FileSetup {
	iOriginalData := false
	iModifiedData := false

	Data[original := false] {
		Get {
			return (original ? this.iOriginalData : this.iModifiedData)
		}
	}

	Setup[original := false] {
		Get {
			return base.Setup[original]
		}

		Set {
			return (base.Setup[original] := StrReplace(StrReplace(value, "=true", "=1"), "=false", "=0"))
		}
	}

	__New(editor, originalFileName := false) {
		iEditor := editor

		base.__New(editor, originalFileName)

		this.iOriginalData := parseConfiguration(this.Setup[true])
		this.iModifiedData := parseConfiguration(this.Setup[false])
	}

	getValue(setting, original := false, default := false) {
		return getConfigurationValue(this.Data[original], getConfigurationValue(this.Editor.Configuration, "Setup.Settings", setting), "VALUE")
	}

	setValue(setting, value) {
		setConfigurationValue(this.Data, getConfigurationValue(this.Editor.Configuration, "Setup.Settings", setting), "VALUE", value)

		this.Setup := printConfiguration(this.Data)

		return value
	}

	reset() {
		base.reset()

		this.iModifiedData := parseConfiguration(this.Setup[false])
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACSetupEditor                                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACSetupEditor extends FileSetupEditor {
	SetupClass[] {
		Get {
			return "ACSetup"
		}
	}

	chooseSetup(load := true) {
		static carNames := false

		if !carNames
			carNames := getConfigurationSectionValues(readConfiguration(kResourcesDirectory . "Simulator Data\AC\Car Data.ini"), "Car Names")

		directory := (A_MyDocuments . "\Assetto Corsa\setups")
		car := this.Advisor.SelectedCar[false]
		track := this.Advisor.SelectedTrack[false]

		if (car && (car != true))
			directory .= ("\" . (carNames.HasKey(car) ? carNames[car] : car))

		if (track && (track != true))
			Loop Files, *.*, D
				if (InStr(track, A_LoopFileName) == 1) {
					directory .= ("\" . track)

					break
				}

		title := translate("Load AC Setup File...")

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
		FileSelectFile fileName, 1, %directory%, %title%, Setup (*.ini)
		OnMessage(0x44, "")

		if fileName {
			theSetup := new ACSetup(this, fileName)

			if load
				this.loadSetup(theSetup)
			else
				return theSetup
		}
		else
			return false
	}

	saveSetup() {
		fileName := this.Setup.FileName

		if fileName = this.Setup.FileName[true]
			SplitPath fileName, , directory
		else
			directory := fileName

		title := translate("Save AC Setup File...")

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Save", "Cancel"]))
		FileSelectFile fileName, S17, %directory%, %title%, Setup (*.ini)
		OnMessage(0x44, "")

		if (fileName != "") {
			if !InStr(fileName, ".ini")
				fileName := (fileName . ".ini")

			try {
				FileDelete %fileName%
			}
			catch exception {
				; ignore
			}

			text := this.Setup.Setup

			FileAppend %text%, %fileName%

			this.Setup.FileName := fileName
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACSetupComparator                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACSetupComparator extends FileSetupComparator {
	chooseSetup(type, load := true) {
		static carNames := false

		if !carNames
			carNames := getConfigurationSectionValues(readConfiguration(kResourcesDirectory . "Simulator Data\AC\Car Data.ini"), "Car Names")

		directory := (A_MyDocuments . "\Assetto Corsa\setups")
		car := this.Editor.Advisor.SelectedCar[false]
		track := this.Editor.Advisor.SelectedTrack[false]

		if (car && (car != true))
			directory .= ("\" . (carNames.HasKey(car) ? carNames[car] : car))

		if (track && (track != true))
			Loop Files, *.*, D
				if (InStr(track, A_LoopFileName) == 1) {
					directory .= ("\" . track)

					break
				}

		title := (translate("Load ") . translate((type = "A") ? "first" : "second") . translate(" AC Setup File..."))

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
		FileSelectFile fileName, 1, %directory%, %title%, Setup (*.ini)
		OnMessage(0x44, "")

		if fileName {
			theSetup := new ACSetup(this, fileName)

			if load {
				if (type = "A")
					this.loadSetups(theSetup)
				else
					this.loadSetups(false, theSetup)
			}
			else
				return theSetup
		}
		else
			return false
	}
}