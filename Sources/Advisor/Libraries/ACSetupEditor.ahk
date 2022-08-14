;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Editor for AC             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                           Local Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Assistants\Libraries\SessionDatabase.ahk


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
			local setup

			setup := parseConfiguration(value)

			setConfigurationValue(setup, "ROD_LENGTH_RF", "VALUE", getConfigurationValue(setup, "ROD_LENGTH_LF", "VALUE"))
			setConfigurationValue(setup, "ROD_LENGTH_RR", "VALUE", getConfigurationValue(setup, "ROD_LENGTH_LR", "VALUE"))

			value := printConfiguration(setup)

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

	setValue(setting, value, display := false) {
		local data := (display ? display : this.Data)

		setConfigurationValue(data, getConfigurationValue(this.Editor.Configuration, "Setup.Settings", setting), "VALUE", value)

		this.Setup := this.printSetup()

		return value
	}

	printSetup() {
		local display := newConfiguration()
		local ignore, setting

		for ignore, setting in this.Editor.Advisor.Settings
			this.setValue(setting, this.getValue(setting, !this.Enabled[setting]), display)

		return printConfiguration(display)
	}

	enable(setting) {
		base.enable(setting)

		this.setValue(setting, this.getValue(setting))
	}

	disable(setting) {
		base.disable(setting)

		this.setValue(setting, this.getValue(setting))
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
		local sessionDB := new SessionDatabase()
		local directory := (A_MyDocuments . "\Assetto Corsa\setups")
		local car := sessionDB.getCarCode(this.Advisor.SelectedSimulator[false], this.Advisor.SelectedCar[false])
		local track := sessionDB.getTrackCode(this.Advisor.SelectedSimulator[false], this.Advisor.SelectedTrack[false])
		local title, fileName, theSetup

		if (car && (car != true))
			directory .= ("\" . car)

		if (track && (track != true))
			loop Files, %directory%\*.*, D
				if (InStr(track, A_LoopFileName) == 1) {
					directory .= ("\" . A_LoopFileName)

					break
				}

		title := translate("Load AC Setup File...")

		Gui +OwnDialogs

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
		local fileName := this.Setup.FileName
		local directory, title, text

		if fileName = this.Setup.FileName[true]
			SplitPath fileName, , directory
		else
			directory := fileName

		title := translate("Save AC Setup File...")

		Gui +OwnDialogs

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
		local sessionDB := new SessionDatabase()
		local directory := (A_MyDocuments . "\Assetto Corsa\setups")
		local car := sessionDB.getCarCode(this.Advisor.SelectedSimulator[false], this.Advisor.SelectedCar[false])
		local track := sessionDB.getTrackCode(this.Advisor.SelectedSimulator[false], this.Advisor.SelectedTrack[false])
		local title, fileName, theSetup

		if (car && (car != true))
			directory .= ("\" . car)

		if (track && (track != true))
			loop Files, %directory%\*.*, D
				if (InStr(track, A_LoopFileName) == 1) {
					directory .= ("\" . A_LoopFileName)

					break
				}

		title := (translate("Load ") . translate((type = "A") ? "first" : "second") . translate(" AC Setup File..."))

		Gui +OwnDialogs

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