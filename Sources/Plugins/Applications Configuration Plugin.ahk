;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Applications Configuration      ;;;
;;;                                         Plugin                          ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ApplicationsConfigurator                                                ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ApplicationsConfigurator extends ConfigurationItemList {
	Applications[types := false] {
		Get {
			local result := []
			local index, theApplication

			for index, theApplication in this.ItemList
				if !types
					result.Push(theApplication[2])
				else if inList(types, theApplication[1])
					result.Push(theApplication[2])

			return result
		}
	}

	__New(editor, configuration) {
		this.Editor := editor

		super.__New(configuration)

		ApplicationsConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window

		chooseApplicationExePath(*) {
			local fileName

			protectionOn()

			try {
				window.Opt("+OwnDialogs")

				OnMessage(0x44, translateSelectCancelButtons)
				fileName := FileSelect(1, window["applicationExePathEdit"].Text, translate("Select application executable..."), "Executable (*.exe)")
				OnMessage(0x44, translateSelectCancelButtons, 0)

				if (fileName != "") {
					window["applicationExePathEdit"].Text := fileName
					window["applicationWorkingDirectoryPathEdit"].Text := ""
				}
			}
			finally {
				protectionOff()
			}
		}

		chooseApplicationWorkingDirectoryPath(*) {
			local directory, translator

			protectionOn()

			try {
				window.Opt("+OwnDialogs")

				translator := translateMsgBoxButtons.Bind(["Select", "Select", "Cancel"])

				OnMessage(0x44, translator)
				directory := DirSelect("*" . window["applicationWorkingDirectoryPathEdit"].Text, 0, translate("Select working directory..."))
				OnMessage(0x44, translator, 0)

				if (directory != "")
					window["applicationWorkingDirectoryPathEdit"].Text := directory
			}
			finally {
				protectionOff()
			}
		}

		window.Add("ListView", "x16 y80 w457 h205 W:Grow H:Grow BackgroundD8D8D8 -Multi -LV0x10 AltSubmit NoSort NoSortHdr VapplicationsListView", collect(["Type", "Name", "Executable", "Window Title", "Working Directory"], translate))

		window.Add("Text", "x16 y295 w141 h23 Y:Move +0x200", translate("Name"))
		window.Add("Edit", "x180 y295 w268 h21 Y:Move W:Grow VapplicationNameEdit")

		window.Add("Text", "x16 y319 w138 h23 Y:Move +0x200", translate("Executable"))
		window.Add("Edit", "x180 y319 w268 h21 Y:Move W:Grow VapplicationExePathEdit")
		window.Add("Button", "x451 y318 w23 h23 Y:Move X:Move", translate("...")).OnEvent("Click", chooseApplicationExePath)

		window.Add("Text", "x16 y343 w138 h23 Y:Move +0x200", translate("Working Directory (optional)"))
		window.Add("Edit", "x180 y343 w268 h21 Y:Move W:Grow VapplicationWorkingDirectoryPathEdit")
		window.Add("Button", "x451 y342 w23 h23 X:Move Y:Move", translate("...")).OnEvent("Click", chooseApplicationWorkingDirectoryPath.Bind("Normal"))

		window.Add("Text", "x16 y367 w140 h23 Y:Move +0x200", translate("Window Title (optional)"))

		window.SetFont("c505050 s8")

		window.Add("Text", "x24 y385 w133 h23 Y:Move", translate("(Use AHK WinTitle Syntax)"))

		window.SetFont()

		window.Add("Edit", "x180 y367 w268 h21 Y:Move W:Grow VapplicationWindowTitleEdit")

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		window.Add("GroupBox", "-Theme x16 y411 w458 h71 Y:Move W:Grow", translate("Function Hooks (optional)"))

		window.SetFont("Norm", "Arial")

		window.Add("Text", "x20 y427 w136 h23 +0x200 Y:Move X:Move(0.16) +Center", translate("Startup"))
		window.Add("Edit", "x20 y451 w136 h21 Y:Move W:Grow(0.33) VapplicationStartupEdit")

		window.Add("Text", "x177 y427 w136 h23 Y:Move X:Move(0.5) +0x200 +Center", translate("Shutdown "))
		window.Add("Edit", "x177 y451 w136 h21 Y:Move X:Move(0.33) W:Grow(0.33) VapplicationShutdownEdit")

		window.Add("Text", "x334 y427 w136 h23 Y:Move X:Move(0.84) +0x200 +Center", translate("Running?"))
		window.Add("Edit", "x334 y451 w136 h21 Y:Move X:Move(0.66) W:Grow(0.34) VapplicationIsRunningEdit")

		window.Add("Button", "x264 y490 w46 h23 Y:Move X:Move VapplicationAddButton", translate("Add"))
		window.Add("Button", "x312 y490 w50 h23 Y:Move X:Move Disabled VapplicationDeleteButton", translate("Delete"))
		window.Add("Button", "x418 y490 w55 h23 Y:Move X:Move Disabled VapplicationUpdateButton", translate("&Save"))

		this.initializeList(editor, window["applicationsListView"], window["applicationAddButton"], window["applicationDeleteButton"], window["applicationUpdateButton"])
	}

	loadFromConfiguration(configuration) {
		local descriptor, name

		super.loadFromConfiguration(configuration)

		for descriptor, name in getMultiMapValues(configuration, "Applications")
			this.ItemList.Push(Array(translate(ConfigurationItem.splitDescriptor(descriptor)[1]), Application(name, configuration)))
	}

	saveToConfiguration(configuration) {
		local count := 0
		local lastType, index, theApplication, type, types

		super.saveToConfiguration(configuration)

		lastType := ""

		for index, theApplication in this.ItemList {
			type := theApplication[1]
			theApplication := theApplication[2]

			if (type != lastType) {
				count := 1
				lastType := type
			}
			else
				count += 1

			types := ["Core", "Feedback", "Other"]

			setMultiMapValue(configuration, "Applications"
						   , ConfigurationItem.descriptor(types[inList(collect(types, "translate"), type)], count), theApplication.Application)

			theApplication.saveToConfiguration(configuration)
		}
	}

	updateState() {
		local theApplication, type

		super.updateState()

		if (this.CurrentItem != 0) {
			theApplication := this.ItemList[this.CurrentItem]

			type := theApplication[1]

			if (type != translate("Other")) {
				this.Control["applicationNameEdit"].Enabled := false
				this.Control["applicationDeleteButton"].Enabled := false
			}
			else {
				this.Control["applicationNameEdit"].Enabled := true
				this.Control["applicationDeleteButton"].Enabled := true
			}

			this.Control["applicationUpdateButton"].Enabled := true
		}
		else {
			this.Control["applicationNameEdit"].Enabled := true
			this.Control["applicationDeleteButton"].Enabled := false
			this.Control["applicationUpdateButton"].Enabled := false
		}

		if (isSet(LaunchpadConfigurator) && LaunchpadConfigurator.hasOwnProp("Instance"))
			try
				LaunchpadConfigurator.Instance.loadApplicationChoices(true)
	}

	loadList(items) {
		local index, theApplication, type

		static first := true

		this.Control["applicationsListView"].Delete()

		for index, theApplication in items {
			type := theApplication[1]
			theApplication := theApplication[2]

			this.Control["applicationsListView"].Add("", type, theApplication.Application, theApplication.ExePath, theApplication.WindowTitle, theApplication.WorkingDirectory)
		}

		if first {
			this.Control["applicationsListView"].ModifyCol()
			this.Control["applicationsListView"].ModifyCol(1, "Center AutoHdr")
			this.Control["applicationsListView"].ModifyCol(2, 120)
			this.Control["applicationsListView"].ModifyCol(3, 80)
			this.Control["applicationsListView"].ModifyCol(4, 80)

			first := false
		}
	}

	loadEditor(item) {
		local theApplication := item[2]

		this.Control["applicationNameEdit"].Text := theApplication.Application
		this.Control["applicationExePathEdit"].Text := theApplication.ExePath
		this.Control["applicationWorkingDirectoryPathEdit"].Text := theApplication.WorkingDirectory
		this.Control["applicationWindowTitleEdit"].Text := theApplication.WindowTitle
		this.Control["applicationStartupEdit"].Text := (theApplication.SpecialStartup ? theApplication.SpecialStartup : "")
		this.Control["applicationShutdownEdit"].Text := (theApplication.SpecialShutdown ? theApplication.SpecialShutdown : "")
		this.Control["applicationIsRunningEdit"].Text := (theApplication.SpecialIsRunning ? theApplication.SpecialIsRunning : "")
	}

	clearEditor() {
		this.Control["applicationNameEdit"].Text := ""
		this.Control["applicationExePathEdit"].Text := ""
		this.Control["applicationWorkingDirectoryPathEdit"].Text := ""
		this.Control["applicationWindowTitleEdit"].Text := ""
		this.Control["applicationStartupEdit"].Text := ""
		this.Control["applicationShutdownEdit"].Text := ""
		this.Control["applicationIsRunningEdit"].Text := ""
	}

	buildItemFromEditor(isNew := false) {
		return Array(isNew ? translate("Other") : this.ItemList[this.CurrentItem][1]
				   , Application(this.Control["applicationNameEdit"].Text, false
							   , this.Control["applicationExePathEdit"].Text, this.Control["applicationWorkingDirectoryPathEdit"].Text, this.Control["applicationWindowTitleEdit"].Text
							   , this.Control["applicationStartupEdit"].Text, this.Control["applicationShutdownEdit"].Text, this.Control["applicationIsRunningEdit"].Text))
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeApplicationsConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Applications"), ApplicationsConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeApplicationsConfigurator()