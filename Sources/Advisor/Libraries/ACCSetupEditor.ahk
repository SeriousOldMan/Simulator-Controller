;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Editor for ACC            ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                           Local Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\JSON.ahk
#Include ..\Assistants\Libraries\SessionDatabase.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACCSetup                                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACCSetup extends FileSetup {
	iOriginalData := false
	iModifiedData := false

	Data[original := false] {
		Get {
			return (original ? this.iOriginalData : this.iModifiedData)
		}
	}

	__New(editor, originalFileName := false) {
		base.__New(editor, originalFileName)

		this.iOriginalData := JSON.parse(this.Setup[true])
		this.iModifiedData := JSON.parse(this.Setup[false])
	}

	getValue(setting, original := false, default := false) {
		local data := this.Data[original]
		local ignore, path

		for ignore, path in string2Values(".", getConfigurationValue(this.Editor.Configuration, "Setup.Settings", setting)) {
			if InStr(path, "[") {
				path := string2Values("[", SubStr(path, 1, StrLen(path) - 1))

				if data.HasKey(path[1]) {
					data := data[path[1]]

					if data.HasKey(path[2])
						data := data[path[2]]
					else
						return default
				}
				else
					return default
			}
			else if data.HasKey(path)
				data := data[path]
			else
				return default
		}

		return data
	}

	setValue(setting, value, display := false) {
		local data := (display ? display : this.Data)
		local elements := string2Values(".", getConfigurationValue(this.Editor.Configuration, "Setup.Settings", setting))
		local length := elements.Length()
		local index, path, last

		try {
			for index, path in elements {
				last := (index == length)

				if InStr(path, "[") {
					path := string2Values("[", SubStr(path, 1, StrLen(path) - 1))

					if data.HasKey(path[1]) {
						data := data[path[1]]

						if data.HasKey(path[2]) {
							if last
								return (data[path[2]] := value)
							else
								data := data[path[2]]
						}
						else
							return value
					}
					else
						return value
				}
				else if data.HasKey(path) {
					if last
						return (data[path] := value)
					else
						data := data[path]
				}
				else
					return value
			}

			return (this.iModifiedData := value)
		}
		finally {
			if !display
				this.Setup := this.printSetup()
		}
	}

	printSetup() {
		local display := JSON.parse(this.Setup[true])
		local ignore, setting

		for ignore, setting in this.Editor.Advisor.Settings
			this.setValue(setting, this.getValue(setting, !this.Enabled[setting]), display)

		return JSON.print(display, false, "  ")
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

		this.iModifiedData := JSON.parse(this.Setup[false])
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACCSetupEditor                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACCSetupEditor extends FileSetupEditor {
	SetupClass[] {
		Get {
			return "ACCSetup"
		}
	}

	chooseSetup(load := true) {
		local sessionDB := new SessionDatabase()
		local directory := (A_MyDocuments . "\Assetto Corsa Competizione\Setups")
		local car := sessionDB.getCarCode(this.Advisor.SelectedSimulator[false], this.Advisor.SelectedCar[false])
		local track := sessionDB.getTrackCode(this.Advisor.SelectedSimulator[false], this.Advisor.SelectedTrack[false])
		local title, fileName, theSetup

		if (car && (car != true))
			directory .= ("\" . car)

		if (track && (track != true))
			directory .= ("\" . track)

		title := translate("Load ACC Setup File...")

		Gui +OwnDialogs

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
		FileSelectFile fileName, 1, %directory%, %title%, Setup (*.json)
		OnMessage(0x44, "")

		if fileName {
			theSetup := new ACCSetup(this, fileName)

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
		local directory, title, fileName, text

		if fileName = this.Setup.FileName[true]
			SplitPath fileName, , directory
		else
			directory := fileName

		title := translate("Save ACC Setup File...")

		Gui +OwnDialogs

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Save", "Cancel"]))
		FileSelectFile fileName, S17, %directory%, %title%, Setup (*.json)
		OnMessage(0x44, "")

		if (fileName != "") {
			if !InStr(fileName, ".json")
				fileName := (fileName . ".json")

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
;;; ACCSetupComparator                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACCSetupComparator extends FileSetupComparator {
	chooseSetup(type, load := true) {
		local sessionDB := new SessionDatabase()
		local directory := (A_MyDocuments . "\Assetto Corsa Competizione\Setups")
		local car := sessionDB.getCarCode(this.Advisor.SelectedSimulator[false], this.Advisor.SelectedCar[false])
		local track := sessionDB.getTrackCode(this.Advisor.SelectedSimulator[false], this.Advisor.SelectedTrack[false])
		local title, fileName, theSetup

		if (car && (car != true))
			directory .= ("\" . car)

		if (track && (track != true))
			directory .= ("\" . track)

		title := (translate("Load ") . translate((type = "A") ? "first" : "second") . translate(" ACC Setup File..."))

		Gui +OwnDialogs

		OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Load", "Cancel"]))
		FileSelectFile fileName, 1, %directory%, %title%, Setup (*.json)
		OnMessage(0x44, "")

		if fileName {
			theSetup := new ACCSetup(this, fileName)

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