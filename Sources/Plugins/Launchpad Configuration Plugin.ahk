;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Launchpad Configuration Plugin  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LaunchpadConfigurator                                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class LaunchpadConfigurator extends ConfigurationItemList {
	__New(editor, configuration) {
		this.Editor := editor

		super.__New(configuration)

		LaunchpadConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window
		local control

		control := window.Add("ListView", "x16 y80 w457 h205 W:Grow H:Grow BackgroundD8D8D8 -Multi -LV0x10 AltSubmit NoSort NoSortHdr VlaunchpadListView", collect(["#", "Label", "Application"], translate))
		control.OnEvent("Click", listEvent.Bind("Click"))
		control.OnEvent("DoubleClick", listEvent.Bind("DoubleClick"))

		window.Add("Text", "x16 y295 w86 h23 Y:Move +0x200", translate("Button"))
		window.Add("Text", "x95 y295 w23 h23 Y:Move +0x200", translate("#"))
		window.Add("Edit", "x110 y295 w40 h21 Y:Move Number Limit3 VlaunchpadNumberEdit")
		window.Add("UpDown", "Range1-999 x150 y295 w17 h21 Y:Move")

		window.Add("Text", "x16 y319 w86 h23 Y:Move +0x200", translate("Label"))
		window.Add("Edit", "x110 y319 w80 h21 Y:Move W:Grow(0.2) VlaunchpadLabelEdit")

		window.Add("Text", "x16 y343 w86 h23 Y:Move +0x200", translate("Application"))
		window.Add("DropDownList", "x110 y343 w363 h21 R10 Y:Move W:Grow VlaunchpadApplicationDropDown")

		window.Add("Button", "x264 y490 w46 h23 Y:Move X:Move VlaunchpadAddButton", translate("Add")).OnEvent("Click", addItem)
		window.Add("Button", "x312 y490 w50 h23 Y:Move X:Move Disabled VlaunchpadDeleteButton", translate("Delete")).OnEvent("Click", deleteItem)
		window.Add("Button", "x418 y490 w55 h23 Y:Move X:Move Disabled VlaunchpadUpdateButton", translate("&Save")).OnEvent("Click", updateItem)

		this.initializeList(editor, window["launchpadListView"], window["launchpadAddButton"], window["launchpadDeleteButton"], window["launchpadUpdateButton"])

		this.loadApplicationChoices()
	}

	loadFromConfiguration(configuration) {
		local descriptor, launchpad

		super.loadFromConfiguration(configuration)

		for descriptor, launchpad in getMultiMapValues(configuration, "Launchpad") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			launchpad := string2Values("|", launchpad)

			this.ItemList.Push(Array(descriptor[2], launchpad[1], launchpad[2]))
		}
	}

	saveToConfiguration(configuration) {
		local ignore, launchpadApplication

		super.saveToConfiguration(configuration)

		for ignore, launchpadApplication in this.ItemList
			setMultiMapValue(configuration, "Launchpad", ConfigurationItem.descriptor("Button", launchpadApplication[1]), values2String("|", launchpadApplication[2], launchpadApplication[3]))
	}

	loadList(items) {
		local ignore, launchpadApplication

		static first := true

		this.Control["launchpadListView"].Delete()

		bubbleSort(&items, (a1, a2) => (a1[1] >= a2[1]))

		this.ItemList := items

		for ignore, launchpadApplication in items
			this.Control["launchpadListView"].Add("", launchpadApplication[1], launchpadApplication[2], launchpadApplication[3])

		if first {
			this.Control["launchpadListView"].ModifyCol()
			this.Control["launchpadListView"].ModifyCol(2, "AutoHdr")

			first := false
		}
	}

	loadApplicationChoices(application := false) {
		local launchpadApplicationsList := []
		local currentApplication := (this.CurrentItem ? this.ItemList[this.CurrentItem][3] : false)
		local ignore, launchpadApplication

		if (isSet(ApplicationsConfigurator) && ApplicationsConfigurator.Instance)
			for ignore, launchpadApplication in ApplicationsConfigurator.Instance.Applications[[translate("Other")]]
				launchpadApplicationsList.Push(launchpadApplication.Application)

		this.Control["launchpadApplicationDropDown"].Delete()
		this.Control["launchpadApplicationDropDown"].Add(launchpadApplicationsList)

		if (application && (application != true))
			this.Control["launchpadApplicationDropDown"].Choose(application)
		else if (currentApplication && (application == true))
			this.Control["launchpadApplicationDropDown"].Choose(currentApplication)
	}

	loadEditor(item) {
		this.Control["launchpadNumberEdit"].Text := item[1]
		this.Control["launchpadLabelEdit"].Text := item[2]

		this.loadApplicationChoices(item[3])
	}

	clearEditor() {
		this.Control["launchpadNumberEdit"].Text := 1
		this.Control["launchpadLabelEdit"].Text := ""

		this.loadApplicationChoices()
	}

	buildItemFromEditor(isNew := false) {
		local ignore, item

		if ((Trim(this.Control["launchpadLabelEdit"].Text) = "") || (Trim(this.Control["launchpadApplicationDropDown"].Text) = "")) {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}
		else if isNew
			for ignore, item in this.ItemList
				if (item[1] = this.Control["launchpadNumberEdit"].Text) {
					OnMessage(0x44, translateOkButton)
					MsgBox(translate("An application launcher for this button already exists - please use different values..."), translate("Error"), 262160)
					OnMessage(0x44, translateOkButton, 0)

					return false
				}

		return Array(this.Control["launchpadNumberEdit"].Text, this.Control["launchpadLabelEdit"].Text, this.Control["launchpadApplicationDropDown"].Text)
	}

	updateItem() {
		local launchApplication := this.buildItemFromEditor()

		if (launchApplication && (launchApplication[1] != this.ItemList[this.CurrentItem][1])) {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("The button number of an existing application launcher may not be changed..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)
		}
		else
			super.updateItem()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

initializeLaunchpadConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Launchpad"), LaunchpadConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeLaunchpadConfigurator()