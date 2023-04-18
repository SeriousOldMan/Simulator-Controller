;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Editor for AC             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                           Local Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Database\Libraries\SessionDatabase.ahk"


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
			return super.Setup[original]
		}

		Set {
			local setup

			setup := parseMultiMap(value)

			setMultiMapValue(setup, "ROD_LENGTH_RF", "VALUE", getMultiMapValue(setup, "ROD_LENGTH_LF", "VALUE"))
			setMultiMapValue(setup, "ROD_LENGTH_RR", "VALUE", getMultiMapValue(setup, "ROD_LENGTH_LR", "VALUE"))

			value := printMultiMap(setup)

			return (super.Setup[original?] := StrReplace(StrReplace(value, "=true", "=1"), "=false", "=0"))
		}
	}

	__New(editor, originalFileName := false, modifiedFileName := false) {
		iEditor := editor

		super.__New(editor, originalFileName, modifiedFileName)

		this.iOriginalData := parseMultiMap(this.Setup[true])
		this.iModifiedData := parseMultiMap(this.Setup[false])
	}

	getValue(setting, original := false, default := false) {
		return getMultiMapValue(this.Data[original], getMultiMapValue(this.Editor.Configuration, "Setup.Settings", setting), "VALUE")
	}

	setValue(setting, value, display := false) {
		local data := (display ? display : this.Data)

		setMultiMapValue(data, getMultiMapValue(this.Editor.Configuration, "Setup.Settings", setting), "VALUE", value)

		if !display
			this.Setup := this.printSetup(data)

		return value
	}

	printSetup(setup) {
		local display := newMultiMap()
		local ignore, setting, section, values, key, value

		for section, values in setup
			for key, value in values
				setMultiMapValue(display, section, key, value)

		for ignore, setting in this.Editor.Workbench.Settings
			this.setValue(setting, this.getValue(setting, !this.Enabled[setting]), display)

		return printMultiMap(display)
	}

	enable(setting) {
		super.enable(setting)

		if setting
			this.setValue(setting, this.getValue(setting))
	}

	disable(setting) {
		super.disable(setting)

		if setting
			this.setValue(setting, this.getValue(setting))
	}

	reset() {
		super.reset()

		this.iModifiedData := parseMultiMap(this.Setup[false])
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACSetupEditor                                                           ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACSetupEditor extends FileSetupEditor {
	SetupClass {
		Get {
			return "ACSetup"
		}
	}

	chooseSetup(load := true) {
		local sessionDB := SessionDatabase()
		local directory := (A_MyDocuments . "\Assetto Corsa\setups")
		local car := sessionDB.getCarCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedCar[false])
		local track := sessionDB.getTrackCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedTrack[false])
		local fileName, theSetup

		if (car && (car != true))
			directory .= ("\" . car)

		if (track && (track != true))
			loop Files, directory "\*.*", "D"
				if (InStr(track, A_LoopFileName) == 1) {
					directory .= ("\" . A_LoopFileName)

					break
				}

		if this.Window
			this.Window.Opt("+OwnDialogs")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := FileSelect(1, directory, translate("Load AC Setup File..."), "Setup (*.ini)")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if fileName {
			theSetup := ACSetup(this, fileName)

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
		local directory, text

		if (fileName = "this.Setup.FileName[true]")
			SplitPath(fileName, , &directory)
		else
			directory := fileName

		if this.Window
			this.Window.Opt("+OwnDialogs")

		OnMessage(0x44, translateSaveCancelButtons)
		fileName := FileSelect("S17", directory, translate("Save AC Setup File..."), "Setup (*.ini)")
		OnMessage(0x44, translateSaveCancelButtons, 0)

		if (fileName != "") {
			if !InStr(fileName, ".ini")
				fileName := (fileName . ".ini")

			deleteFile(fileName)

			text := this.Setup.Setup

			FileAppend(text, fileName)

			this.Setup.FileName := fileName
		}
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACSetupComparator                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACSetupComparator extends FileSetupComparator {
	chooseSetup(type, load := true) {
		local sessionDB := SessionDatabase()
		local directory := (A_MyDocuments . "\Assetto Corsa\setups")
		local car := sessionDB.getCarCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedCar[false])
		local track := sessionDB.getTrackCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedTrack[false])
		local fileName, theSetup, ignore

		if (car && (car != true))
			directory .= ("\" . car)

		if (track && (track != true))
			loop Files, directory "\*.*", "D"
				if (InStr(track, A_LoopFileName) == 1) {
					directory .= ("\" . A_LoopFileName)

					break
				}

		if this.Window
			this.Window.Opt("+OwnDialogs")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := FileSelect(1, directory, (translate("Load ") . translate((type = "A") ? "first" : "second") . translate(" AC Setup File...")), "Setup (*.ini)")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if fileName {
			theSetup := ACSetup(this, fileName)

			if load {
				if (type = "A")
					this.loadSetups(&theSetup)
				else
					this.loadSetups(&ignore := false, &theSetup)
			}
			else
				return theSetup
		}
		else
			return false
	}
}