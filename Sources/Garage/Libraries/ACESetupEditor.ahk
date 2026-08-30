;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Setup Editor for AC EVO         ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2026) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                           Local Include Section                         ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Framework\Extensions\JSON.ahk"
#Include "..\..\Database\Libraries\SessionDatabase.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACESetup                                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACESetup extends FileSetup {
	iOriginalJSONFileName := false
	iModifiedJSONFileName := false

	iOriginalData := false
	iModifiedData := false

	Data[original := false] {
		Get {
			return (original ? this.iOriginalData : this.iModifiedData)
		}
	}

	FileName[original := false] {
		Set {
			local jsonFile

			if value {
				jsonFile := temporaryFileName("Setup", "json")

				ACESetup.convert2JSON(jsonFile, value)
			}
			else
				jsonFile := false

			this.JSONFileName[original] := jsonFile

			return (super.FileName[original] := value)
		}
	}

	JSONFileName[original := false] {
		Get {
			return (original ? this.iOriginalJSONFileName
							 : (this.iModifiedJSONFileName ? this.iModifiedJSONFileName : this.iOriginalJSONFileName))
		}

		Set {
			return (original ? (this.iOriginalJSONFileName := value) : (this.iModifiedJSONFileName := value))
		}
	}

	__New(editor, originalFileName := false, modifiedFileName := false) {
		super.__New(editor, originalFileName, modifiedFileName, false)

		this.FileName[true] := originalFileName
		this.FileName[false] := modifiedFileName

		if (this.JSONFileName[true] && FileExist(this.JSONFileName[true]))
			this.Setup[true] := FileRead(this.JSONFileName[true])

		if (this.JSONFileName[false] && FileExist(this.JSONFileName[false]))
			this.Setup[false] := FileRead(this.JSONFileName[false])

		this.iOriginalData := JSON.parse(this.Setup[true])
		this.iModifiedData := JSON.parse(this.Setup[false])
	}

	static convert2JSON(jsonFile, protoFile) {
		local setup

		try {
			RunWait("`"" . kBinariesDirectory . "ProtoBuf\buf.exe`" convert CarSetup.proto --type=CarSetupData --from=`"" . protoFile . "`" --to=`"" . jsonFile . "`"", kResourcesDirectory . "Simulator Data\ACE\Proto", "Hide")

			setup := JSON.parse(FileRead(jsonFile))

			deleteFile(jsonFile)

			FileAppend(JSON.print(setup, "  "), jsonFile)
		}
		catch Any as exception {
			logError(exception, true)
		}
	}

	static convert2ProtoBuf(protoFile, jsonFile) {
		try {
			RunWait("`"" . kBinariesDirectory . "ProtoBuf\buf.exe`" convert CarSetup.proto --type=CarSetupData --from=`"" . jsonFile . "`" --to=`"" . protoFile . "`"", kResourcesDirectory . "Simulator Data\ACE\Proto", "Hide")

		}
		catch Any as exception {
			logError(exception, true)
		}
	}

	getValue(setting, original := false, default := false) {
		local data := this.Data[original]
		local ignore, path

		for ignore, path in string2Values(".", getMultiMapValue(this.Editor.Configuration, "Setup.Settings", setting)) {
			if InStr(path, "[") {
				path := string2Values("[", SubStr(path, 1, StrLen(path) - 1))

				if data.Has(path[1]) {
					data := data[path[1]]

					if data.Has(path[2])
						data := data[path[2]]
					else
						return default
				}
				else
					return default
			}
			else if data.Has(path)
				data := data[path]
			else
				return default
		}

		return data
	}

	setValue(setting, value, display := false) {
		local data := (display ? display : this.Data)
		local elements := string2Values(".", getMultiMapValue(this.Editor.Configuration, "Setup.Settings", setting))
		local length := elements.Length
		local index, path, last

		try {
			for index, path in elements {
				last := (index == length)

				if InStr(path, "[") {
					path := string2Values("[", SubStr(path, 1, StrLen(path) - 1))

					if data.Has(path[1]) {
						data := data[path[1]]

						if data.Has(path[2]) {
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
				else if data.Has(path) {
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

		for ignore, setting in this.Editor.Workbench.Settings
			this.setValue(setting, this.getValue(setting, !this.Enabled[setting]), display)

		return JSON.print(display, "  ")
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

		this.iModifiedData := JSON.parse(this.Setup[false])
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACESetupEditor                                                          ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACESetupEditor extends FileSetupEditor {
	SetupClass {
		Get {
			return "ACESetup"
		}
	}

	editableSetup(car) {
		return (super.editableSetup(car) || isDebug())
	}

	chooseSetup(load := true) {
		local directory := (EnvGet("USERPROFILE") . "\Saved Games\ACE\Car Setups")
		local car := SessionDatabase.getCarCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedCar[false])
		local track := SessionDatabase.getTrackCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedTrack[false])
		local fileName, theSetup

		if (car && (car != true))
			directory .= ("\" . car)

		if (track && (track != true))
			directory .= ("\" . track)

		if this.Window {
			this.Workbench.Window.Opt("-OwnDialogs")

			this.Window.Opt("+OwnDialogs")
		}
		else
			this.Workbench.Window.Opt("+OwnDialogs")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := withBlockedWindows(FileSelect, 1, directory
									 , substituteVariables(translate("Load %simulator% Setup File...")
														 , {simulator: SessionDatabase.getSimulatorCode(this.Workbench.SelectedSimulator[false])})
									 , "Setup (*.carSetup)")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if fileName {
			theSetup := ACESetup(this, fileName)

			if load
				return this.loadSetup(&theSetup)

			return theSetup
		}
		else
			return false
	}

	saveSetup() {
		local fileName := this.Setup.FileName
		local directory, title, fileName, text, jsonFile, name

		if (fileName = this.Setup.FileName[true])
			SplitPath(fileName, , &directory)
		else
			directory := fileName

		if this.Window
			this.Window.Opt("+OwnDialogs")

		OnMessage(0x44, translateSaveCancelButtons)
		fileName := withBlockedWindows(FileSelect, "S17", directory
									 , substituteVariables(translate("Save %simulator% Setup File...")
														 , {simulator: SessionDatabase.getSimulatorCode(this.Workbench.SelectedSimulator[false])})
									 , "Setup (*.carSetup)")
		OnMessage(0x44, translateSaveCancelButtons, 0)

		if (fileName != "") {
			if !InStr(fileName, ".carSetup")
				fileName := (fileName . ".carSetup")

			deleteFile(fileName)

			SplitPath(fileName, , , , &name)

			jsonFile := temporaryFileName("Setup", "json")

			try {
				deleteFile(jsonFile)

				text := this.Setup.Setup

				FileAppend(text, jsonFile)

				ACESetup.convert2ProtoBuf(fileName, jsonFile)
			}
			finally {
				if !isDebug()
					deleteFile(jsonFile)
			}

			this.Setup.FileName := fileName

			return true
		}
		else
			return false
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ACESetupComparator                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ACESetupComparator extends FileSetupComparator {
	chooseSetup(type, load := true) {
		local directory := (EnvGet("USERPROFILE") . "\Saved Games\ACE\Car Setups")
		local car := SessionDatabase.getCarCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedCar[false])
		local track := SessionDatabase.getTrackCode(this.Workbench.SelectedSimulator[false], this.Workbench.SelectedTrack[false])
		local fileName, theSetup, ignore

		if (car && (car != true))
			directory .= ("\" . car)

		if (track && (track != true))
			directory .= ("\" . track)

		if this.Window {
			this.Editor.Window.Opt("-OwnDialogs")

			this.Window.Opt("+OwnDialogs")
		}
		else
			this.Editor.Window.Opt("+OwnDialogs")

		OnMessage(0x44, translateLoadCancelButtons)
		fileName := withBlockedWindows(FileSelect, 1, directory
									 , (translate("Load ") . translate((type = "A") ? "first" : "second")
									  . substituteVariables(translate(" %simulator% Setup File...")
														  , {simulator: SessionDatabase.getSimulatorCode(this.Workbench.SelectedSimulator[false])}))
									 , "Setup (*.carSetup)")
		OnMessage(0x44, translateLoadCancelButtons, 0)

		if fileName {
			theSetup := ACESetup(this, fileName)

			if load {
				if (type = "A")
					this.loadSetups(&theSetup)
				else
					this.loadSetups(&ignore := false, &theSetup)
			}

			return theSetup
		}
		else
			return false
	}
}