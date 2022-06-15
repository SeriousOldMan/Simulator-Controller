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
		iEditor := editor

		base.__New(editor, originalFileName)

		this.iOriginalData := JSON.parse(this.Setup[true])
		this.iModifiedData := JSON.parse(this.Setup[false])
	}

	getValue(setting, original := false, default := false) {
		data := this.Data[original]

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

	setValue(setting, value) {
		data := this.Data
		elements := string2Values(".", getConfigurationValue(this.Editor.Configuration, "Setup.Settings", setting))
		length := elements.Length()

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
			this.Setup := JSON.print(this.Data, false, "  ")
		}
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
		static carNames := false

		if !carNames
			carNames := getConfigurationSectionValues(readConfiguration(kResourcesDirectory . "Simulator Data\ACC\Car Data.ini"), "Car Names")

		directory := (A_MyDocuments . "\Assetto Corsa Competizione\Setups")
		car := this.Advisor.SelectedCar[false]
		track := this.Advisor.SelectedTrack[false]

		if (car && (car != true))
			directory .= ("\" . (carNames.HasKey(car) ? carNames[car] : car))

		if (track && (track != true))
			directory .= ("\" . track)

		title := translate("Load ACC Setup File...")

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
		fileName := this.Setup.FileName

		if fileName = this.Setup.FileName[true]
			SplitPath fileName, , directory
		else
			directory := fileName

		title := translate("Save ACC Setup File...")

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
		static carNames := false

		if !carNames
			carNames := getConfigurationSectionValues(readConfiguration(kResourcesDirectory . "Simulator Data\ACC\Car Data.ini"), "Car Names")

		directory := (A_MyDocuments . "\Assetto Corsa Competizione\Setups")
		car := this.Editor.Advisor.SelectedCar[false]
		track := this.Editor.Advisor.SelectedTrack[false]

		if (car && (car != true))
			directory .= ("\" . (carNames.HasKey(car) ? carNames[car] : car))

		if (track && (track != true))
			directory .= ("\" . track)

		title := (translate("Load ") . translate((type = "A") ? "first" : "second") . translate(" ACC Setup File..."))

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