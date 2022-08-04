;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Launchpad Configuration Plugin  ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LaunchpadConfigurator                                                   ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global launchpadListView = false
global launchpadNumberEdit = 1
global launchpadLabelEdit = ""
global launchpadApplicationDropDown = 0
global launchpadAddButton
global launchpadDeleteButton
global launchpadUpdateButton

class LaunchpadConfigurator extends ConfigurationItemList {
	iEditor := false

	Editor[] {
		Get {
			return this.iEditor
		}
	}

	__New(editor, configuration) {
		this.iEditor := editor

		base.__New(configuration, this.createControls(configuration), "launchpadListView"
				 , "launchpadAddButton", "launchpadDeleteButton", "launchpadUpdateButton")

		LaunchpadConfigurator.Instance := this
	}

	createGui(editor, x, y, width, height) {
		local window := editor.Window

		Gui %window%:Add, ListView, x16 y80 w457 h205 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndlaunchpadListViewHandle VlaunchpadListView glistEvent
						, % values2String("|", map(["#", "Label", "Application"], "translate")*)

		Gui %window%:Add, Text, x16 y295 w86 h23 +0x200, % translate("Button")
		Gui %window%:Add, Text, x95 y295 w23 h23 +0x200, % translate("#")
		Gui %window%:Add, Edit, x110 y295 w40 h21 Number VlaunchpadNumberEdit, %launchpadNumberEdit%
		Gui %window%:Add, UpDown, x150 y295 w17 h21, 1

		Gui %window%:Add, Text, x16 y319 w86 h23 +0x200, % translate("Label")
		Gui %window%:Add, Edit, x110 y319 w80 h21 VlaunchpadLabelEdit, %launchpadLabelEdit%

		Gui %window%:Add, Text, x16 y343 w86 h23 +0x200, % translate("Application")
		Gui %window%:Add, DropDownList, x110 y343 w363 h21 R10 Choose%launchpadApplicationDropDown% VlaunchpadApplicationDropDown

		Gui %window%:Add, Button, x264 y490 w46 h23 VlaunchpadAddButton gaddItem, % translate("Add")
		Gui %window%:Add, Button, x312 y490 w50 h23 Disabled VlaunchpadDeleteButton gdeleteItem, % translate("Delete")
		Gui %window%:Add, Button, x418 y490 w55 h23 Disabled VlaunchpadUpdateButton gupdateItem, % translate("&Save")

		this.initializeList(launchpadListViewHandle, "launchpadListView", "launchpadAddButton", "launchpadDeleteButton", "launchpadUpdateButton")

		this.loadApplicationChoices()
	}

	loadFromConfiguration(configuration) {
		local descriptor, launchpad

		base.loadFromConfiguration(configuration)

		for descriptor, launchpad in getConfigurationSectionValues(configuration, "Launchpad", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			launchpad := string2Values("|", launchpad)

			this.ItemList.Push(Array(descriptor[2], launchpad[1], launchpad[2]))
		}
	}

	saveToConfiguration(configuration) {
		local ignore, launchpadApplication

		base.saveToConfiguration(configuration)

		for ignore, launchpadApplication in this.ItemList
			setConfigurationValue(configuration, "Launchpad", ConfigurationItem.descriptor("Button", launchpadApplication[1]), values2String("|", launchpadApplication[2], launchpadApplication[3]))
	}

	loadList(items) {
		local ignore, launchpadApplication

		static first := true

		Gui ListView, % this.ListHandle

		LV_Delete()

		bubbleSort(items, "compareLaunchApplications")

		this.ItemList := items

		for ignore, launchpadApplication in items
			LV_Add("", launchpadApplication[1], launchpadApplication[2], launchpadApplication[3])

		if first {
			LV_ModifyCol()
			LV_ModifyCol(2, "AutoHdr")

			first := false
		}
	}

	loadApplicationChoices(application := false) {
		local launchpadApplicationsList := []
		local currentApplication := (this.CurrentItem ? this.ItemList[this.CurrentItem][3] : false)

		if ApplicationsConfigurator.Instance
			for ignore, launchpadApplication in ApplicationsConfigurator.Instance.Applications[[translate("Other")]]
				launchpadApplicationsList.Push(launchpadApplication.Application)

		launchpadApplicationDropDown := (application ? inList(launchpadApplicationsList, application) : 0)

		GuiControl Text, launchpadApplicationDropDown, % "|" . values2String("|", launchpadApplicationsList*)

		if (application && (application != true))
			GuiControl Choose, launchpadApplicationDropDown, %application%
		else if (currentApplication && (application == true))
			GuiControl Choose, launchpadApplicationDropDown, %currentApplication%
	}

	loadEditor(item) {
		GuiControl Text, launchpadNumberEdit, % item[1]
		GuiControl Text, launchpadLabelEdit, % item[2]

		this.loadApplicationChoices(item[3])
	}

	clearEditor() {
		GuiControl Text, launchpadNumberEdit, % 1
		GuiControl Text, launchpadLabelEdit, % ""

		this.loadApplicationChoices()
	}

	buildItemFromEditor(isNew := false) {
		local title, ignore, item

		GuiControlGet launchpadNumberEdit
		GuiControlGet launchpadLabelEdit
		GuiControlGet launchpadApplicationDropDown

		if ((launchpadLabelEdit = "") || (launchpadApplicationDropDown = "")) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")

			return false
		}
		else if isNew
			for ignore, item in this.ItemList
				if (item[1] = launchpadNumberEdit) {
					OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
					title := translate("Error")
					MsgBox 262160, %title%, % translate("An application launcher for this button already exists - please use different values...")
					OnMessage(0x44, "")

					return false
				}

		return Array(launchpadNumberEdit, launchpadLabelEdit, launchpadApplicationDropDown)
	}

	updateItem() {
		local launchApplication := this.buildItemFromEditor()
		local title

		if (launchApplication && (launchApplication[1] != this.ItemList[this.CurrentItem][1])) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("The button number of an existing application launcher may not be changed...")
			OnMessage(0x44, "")
		}
		else
			base.updateItem()
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

compareLaunchApplications(a1, a2) {
	return (a1[1] >= a2[1])
}

initializeLaunchpadConfigurator() {
	local editor

	if kConfigurationEditor {
		editor := ConfigurationEditor.Instance

		editor.registerConfigurator(translate("Launchpad"), new LaunchpadConfigurator(editor, editor.Configuration))
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeLaunchpadConfigurator()