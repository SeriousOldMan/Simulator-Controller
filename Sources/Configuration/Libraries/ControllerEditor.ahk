;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Editor               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Task.ahk
#Include ..\Configuration\Libraries\ConfigurationItemList.ahk
#Include ..\Configuration\Libraries\ButtonBoxPreview.ahk
#Include ..\Configuration\Libraries\StreamDeckPreview.ahk
#Include ..\Configuration\Libraries\ControllerActionsEditor.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kControlTypes := {}

kControlTypes[k1WayToggleType] := "1-way Toggle"
kControlTypes[k2WayToggleType] := "2-way Toggle"
kControlTypes[kButtonType] := "Button"
kControlTypes[kDialType] := "Rotary"
kControlTypes[kCustomType] := "Custom"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Variables Section                       ;;;
;;;-------------------------------------------------------------------------;;;

global vControllerPreviews := {}


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerEditor                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerEditor extends ConfigurationItem {
	iControlsList := false
	iLabelsList := false
	iLayoutsList := false

	iName := ""
	iClosed := false

	iControllerPreview := false

	iButtonBoxConfiguration := false
	iButtonBoxConfigurationFile := false

	iStreamDeckConfiguration := false
	iStreamDeckConfigurationFile := false

	iPreviewCenterX := 0
	iPreviewCenterY := 0

	ControllerPreview[] {
		Get {
			return this.iControllerPreview
		}
	}

	Name[] {
		Get {
			return this.iName
		}
	}

	ButtonBoxConfiguration[] {
		Get {
			return this.iButtonBoxConfiguration
		}
	}

	ButtonBoxConfigurationFile[] {
		Get {
			return this.iButtonBoxConfigurationFile
		}
	}

	StreamDeckConfiguration[] {
		Get {
			return this.iStreamDeckConfiguration
		}
	}

	StreamDeckConfigurationFile[] {
		Get {
			return this.iStreamDeckConfigurationFile
		}
	}

	AutoSave[] {
		Get {
			try {
				/*
				if (ConfigurationEditor && ConfigurationEditor.Instance)
					return ConfigurationEditor.Instance.AutoSave
				else
					return false
				*/

				return false
			}
			catch exception {
				return false
			}
		}
	}

	__New(name, configuration, buttonBoxConfigurationFile := false, streamDeckConfigurationFile := false, saveAndCancel := true) {
		this.iName := name

		if !buttonBoxConfigurationFile
			buttonBoxConfigurationFile := getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory)

		if !streamDeckConfigurationFile
			streamDeckConfigurationFile := getFileName("Stream Deck Configuration.ini", kUserConfigDirectory, kConfigDirectory)

		this.iButtonBoxConfigurationFile := buttonBoxConfigurationFile
		this.iStreamDeckConfigurationFile := streamDeckConfigurationFile

		this.iButtonBoxConfiguration := readConfiguration(buttonBoxConfigurationFile)
		this.iStreamDeckConfiguration := readConfiguration(streamDeckConfigurationFile)

		this.iControlsList := new ControlsList(this.iButtonBoxConfiguration)
		this.iLabelsList := new LabelsList(this.iButtonBoxConfiguration)
		this.iLayoutsList := new LayoutsList(this.iButtonBoxConfiguration, this.iStreamDeckConfiguration)

		base.__New(configuration)

		ControllerEditor.Instance := this

		this.createGui(this.iButtonBoxConfiguration, this.iStreamDeckConfiguration, saveAndCancel)
	}

	createGui(buttonBoxConfiguration, streamDeckConfiguration, saveAndCancel) {
		Gui CTRLE:Default

		Gui CTRLE:-Border ; -Caption

		Gui CTRLE:Color, D0D0D0, D8D8D8
		Gui CTRLE:Font, Bold, Arial

		Gui CTRLE:Add, Text, x0 w432 Center gmoveControllerEditor, % translate("Modular Simulator Controller System")

		Gui CTRLE:Font, Norm, Arial
		Gui CTRLE:Font, Italic Underline, Arial

		Gui CTRLE:Add, Text, x160 YP+20 w112 cBlue Center gopenControllerDocumentation, % translate("Controller Layouts")

		this.iControlsList.createGui(buttonBoxConfiguration)
		this.iLabelsList.createGui(buttonBoxConfiguration)
		this.iLayoutsList.createGui(buttonBoxConfiguration, streamDeckConfiguration)

		if saveAndCancel {
			Gui CTRLE:Add, Text, x8 y620 w424 0x10

			Gui CTRLE:Add, Button, x8 yp+10 w140 h23 gopenControllerActionsEditor, % translate("Edit Labels && Icons...")

			Gui CTRLE:Add, Button, x260 yp w80 h23 Default GsaveControllerEditor, % translate("Save")
			Gui CTRLE:Add, Button, x352 yp w80 h23 GcancelControllerEditor, % translate("Cancel")
		}
	}

	saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, save := true) {
		if save
			base.saveToConfiguration(buttonBoxConfiguration)

		this.iControlsList.saveToConfiguration(buttonBoxConfiguration, save)
		this.iLabelsList.saveToConfiguration(buttonBoxConfiguration, save)
		this.iLayoutsList.saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, save)
	}

	setPreviewCenter(centerX, centerY) {
		this.iPreviewCenterX := centerX
		this.iPreviewCenterY := centerY
	}

	getPreviewCenter(ByRef centerX, ByRef centerY) {
		centerX := this.iPreviewCenterX
		centerY := this.iPreviewCenterY
	}

	getPreviewMover() {
		return "moveControllerPreview"
	}

	selectLayout(name) {
		Gui CTRLE:Default

		Gui ListView, % this.iLayoutsList.ListHandle

		for index, item in this.iLayoutsList.ItemList
			if (item[1] = name) {
				this.iLayoutsList.openEditor(index)
				this.iLayoutsList.selectItem(index)

				break
			}
	}

	open(x := "__Undefined__", y := "__Undefined__") {
		if ((x = kUndefined) || (y = kUndefined)) {
			if getWindowPosition("Controller Editor", x, y)
				Gui CTRLE:Show, x%x% y%y%
			else
				Gui CTRLE:Show
		}
		else
			Gui CTRLE:Show, AutoSize x%x% y%y%

		name := this.Name
		
		Task.startTask(ObjBindMethod(this, "selectLayout", name), 1000)
	}

	close(save := true) {
		if save {
			buttonBoxConfiguration := newConfiguration()
			streamDeckConfiguration := newConfiguration()

			this.saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration)

			writeConfiguration(this.ButtonBoxConfigurationFile, buttonBoxConfiguration)
			writeConfiguration(this.StreamDeckConfigurationFile, streamDeckConfiguration)
		}

		this.saveController()

		if this.ControllerPreview {
			this.ControllerPreview.close()

			this.iControllerPreview := false
		}

		Gui CTRLE:Destroy

		this.iClosed := true
	}

	editController() {
		this.open()

		loop
			Sleep 200
		until this.iClosed
	}

	configurationChanged(type, name) {
		this.updateControllerPreview(type, name)
	}

	updateControllerPreview(type, name) {
		buttonBoxConfiguration := newConfiguration()
		streamDeckConfiguration := newConfiguration()

		this.saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, false)

		this.iButtonBoxConfiguration := buttonBoxConfiguration
		this.iStreamDeckConfiguration := streamDeckConfiguration

		oldPreview := this.ControllerPreview

		if name {
			if (type = "Button Box")
				this.iControllerPreview := new ButtonBoxPreview(this, name, buttonBoxConfiguration)
			else
				this.iControllerPreview := new StreamDeckPreview(this, name, streamDeckConfiguration)

			this.ControllerPreview.open()
		}
		else
			this.iControllerPreview := false

		if oldPreview
			oldPreview.close()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControlsList                                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global controlsListView := "|"

global controlNameEdit := ""
global controlTypeDropDown := 0
global imageFilePathEdit := ""
global imageWidthEdit := 0
global imageHeightEdit := 0

global controlAddButton
global controlDeleteButton
global controlUpdateButton

class ControlsList extends ConfigurationItemList {
	AutoSave[] {
		Get {
			return ControllerEditor.Instance.AutoSave
		}
	}

	__New(configuration) {
		base.__New(configuration)

		ControlsList.Instance := this
	}

	createGui(configuration) {
		Gui CTRLE:Font, Norm, Arial
		Gui CTRLE:Font, Italic, Arial

		Gui CTRLE:Add, GroupBox, -Theme x8 y60 w424 h138, % translate("Controls")

		Gui CTRLE:Font, Norm, Arial
		Gui CTRLE:Add, ListView, x16 y79 w134 h108 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndcontrolsListViewHandle VcontrolsListView glistEvent
							 , % values2String("|", map(["Name", "Function", "Size"], "translate")*)

		Gui CTRLE:Add, Text, x164 y79 w80 h23 +0x200, % translate("Name")
		Gui CTRLE:Add, Edit, x214 y80 w101 h21 VcontrolNameEdit, %controlNameEdit%
		Gui CTRLE:Add, DropDownList, x321 y79 w105 AltSubmit Choose%controlTypeDropDown% VcontrolTypeDropDown, % values2String("|", map(["1-way Toggle", "2-way Toggle", "Button", "Dial"], "translate")*)
		;426 400
		Gui CTRLE:Add, Text, x164 y103 w80 h23 +0x200, % translate("Image")
		Gui CTRLE:Add, Edit, x214 y103 w186 h21 VimageFilePathEdit, %imageFilePathEdit%
		Gui CTRLE:Add, Button, x403 y103 w23 h23 gchooseImageFilePath, % translate("...")

		Gui CTRLE:Add, Text, x164 y127 w80 h23 +0x200, % translate("Size")
		Gui CTRLE:Add, Edit, x214 y127 w40 h21 Limit3 Number VimageWidthEdit, %imageWidthEdit%
		Gui CTRLE:Add, Text, x254 y127 w21 h23 +0x200 Center, % translate("x")
		Gui CTRLE:Add, Edit, x275 y127 w40 h21 Limit3 Number VimageHeightEdit, %imageHeightEdit%

		Gui CTRLE:Add, Button, x226 y164 w46 h23 VcontrolAddButton gaddItem, % translate("Add")
		Gui CTRLE:Add, Button, x275 y164 w50 h23 Disabled VcontrolDeleteButton gdeleteItem, % translate("Delete")
		Gui CTRLE:Add, Button, x371 y164 w55 h23 Disabled VcontrolUpdateButton gupdateItem, % translate("Save")

		this.initializeList(controlsListViewHandle, "controlsListView", "controlAddButton", "controlDeleteButton", "controlUpdateButton")

		this.clearEditor()
	}

	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)

		controls := []

		for name, definition in getConfigurationSectionValues(configuration, "Controls", Object())
			controls.Push(Array(name, string2Values(";", definition)*))

		this.ItemList := controls
	}

	saveToConfiguration(configuration, save := true) {
		if save
			base.saveToConfiguration(configuration)

		controls := {}

		for ignore, control in this.ItemList
			controls[control[1]] := values2String(";", control[2], control[3], control[4])

		setConfigurationSectionValues(configuration, "Controls", controls)
	}

	loadList(items) {
		static first := true

		Gui ListView, % this.ListHandle

		LV_Delete()

		this.ItemList := items

		for ignore, control in items
			LV_Add("", control[1], translate(kControlTypes[control[2]]), control[4])

		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			LV_ModifyCol(3, "AutoHdr")

			first := false
		}

		ControllerEditor.Instance.configurationChanged(LayoutsList.Instance.CurrentControllerType, LayoutsList.Instance.CurrentController)
	}

	loadEditor(item) {
		controlNameEdit := item[1]
		imageFilePathEdit := item[3]

		size := string2Values("x", item[4])

		imageWidthEdit := size[1]
		imageHeightEdit := size[2]

		controlTypeDropDown := inList([k1WayToggleType, k2WayToggleType, kButtonType, kDialType], item[2])

		GuiControl Text, controlNameEdit, %controlNameEdit%
		GuiControl Choose, controlTypeDropDown, %controlTypeDropDown%
		GuiControl Text, imageFilePathEdit, %imageFilePathEdit%
		GuiControl Text, imageWidthEdit, %imageWidthEdit%
		GuiControl Text, imageHeightEdit, %imageHeightEdit%
	}

	clearEditor() {
		this.loadEditor(Array("", "", "", ""))
	}

	buildItemFromEditor(isNew := false) {
		GuiControlGet controlNameEdit
		GuiControlGet controlTypeDropDown
		GuiControlGet imageFilePathEdit
		GuiControlGet imageWidthEdit
		GuiControlGet imageHeightEdit

		if ((controlNameEdit = "") || !inList([1, 2, 3, 4], controlTypeDropDown) || (imageFilePathEdit = "")  || (imageWidthEdit = 0) || (imageHeightEdit = 0)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")

			return false
		}
		else
			return Array(controlNameEdit, [k1WayToggleType, k2WayToggleType, kButtonType, kDialType][controlTypeDropDown], imageFilePathEdit, imageWidthEdit . " x " . imageHeightEdit)
	}

	getControls() {
		if ControllerEditor.Instance.AutoSave {
			if (this.CurrentItem != 0)
				this.updateItem()
		}

		controls := {}

		for ignore, control in this.ItemList
			controls[control[1]] := values2String(";", control[2], control[3], control[4])

		return controls
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LabelsList                                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global labelsListView := "|"

global labelNameEdit := ""
global labelWidthEdit := 0
global labelHeightEdit := 0

global labelAddButton
global labelDeleteButton
global labelUpdateButton

class LabelsList extends ConfigurationItemList {
	AutoSave[] {
		Get {
			return ControllerEditor.Instance.AutoSave
		}
	}

	__New(configuration) {
		base.__New(configuration)

		LabelsList.Instance := this
	}

	createGui(configuration) {
		Gui CTRLE:Font, Norm, Arial
		Gui CTRLE:Font, Italic, Arial

		Gui CTRLE:Add, GroupBox, -Theme x8 y205 w424 h115, % translate("Labels")

		Gui CTRLE:Font, Norm, Arial
		Gui CTRLE:Add, ListView, x16 y224 w134 h84 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndlabelsListViewHandle VlabelsListView glistEvent
							 , % values2String("|", map(["Name", "Size"], "translate")*)

		Gui CTRLE:Add, Text, x164 y224 w80 h23 +0x200, % translate("Name")
		Gui CTRLE:Add, Edit, x214 y225 w101 h21 VlabelNameEdit, %labelNameEdit%

		Gui CTRLE:Add, Text, x164 y248 w80 h23 +0x200, % translate("Size")
		Gui CTRLE:Add, Edit, x214 y248 w40 h21 Limit3 Number VlabelWidthEdit, %labelWidthEdit%
		Gui CTRLE:Add, Text, x254 y248 w21 h23 +0x200 Center, % translate("x")
		Gui CTRLE:Add, Edit, x275 y248 w40 h21 Limit3 Number VlabelHeightEdit, %labelHeightEdit%

		Gui CTRLE:Add, Button, x226 y285 w46 h23 VlabelAddButton gaddItem, % translate("Add")
		Gui CTRLE:Add, Button, x275 y285 w50 h23 Disabled VlabelDeleteButton gdeleteItem, % translate("Delete")
		Gui CTRLE:Add, Button, x371 y285 w55 h23 Disabled VlabelUpdateButton gupdateItem, % translate("Save")

		this.initializeList(labelsListViewHandle, "labelsListView", "labelAddButton", "labelDeleteButton", "labelUpdateButton")

		this.clearEditor()
	}

	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)

		labels := []

		for name, definition in getConfigurationSectionValues(configuration, "Labels", Object())
			labels.Push(Array(name, definition))

		this.ItemList := labels
	}

	saveToConfiguration(configuration, save := true) {
		if save
			base.saveToConfiguration(configuration)

		labels := {}

		for ignore, label in this.ItemList
			labels[label[1]] := label[2]

		setConfigurationSectionValues(configuration, "Labels", labels)
	}

	loadList(items) {
		static first := true

		Gui ListView, % this.ListHandle

		LV_Delete()

		this.ItemList := items

		for ignore, label in items
			LV_Add("", label[1], label[2])

		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")

			first := false
		}

		ControllerEditor.Instance.configurationChanged(LayoutsList.Instance.CurrentControllerType, LayoutsList.Instance.CurrentController)
	}

	loadEditor(item) {
		labelNameEdit := item[1]

		size := string2Values("x", item[2])

		labelWidthEdit := size[1]
		labelHeightEdit := size[2]

		GuiControl Text, labelNameEdit, %labelNameEdit%
		GuiControl Text, labelWidthEdit, %labelWidthEdit%
		GuiControl Text, labelHeightEdit, %labelHeightEdit%
	}

	clearEditor() {
		this.loadEditor(Array("", ""))
	}

	buildItemFromEditor(isNew := false) {
		GuiControlGet labelNameEdit
		GuiControlGet labelWidthEdit
		GuiControlGet labelHeightEdit

		if ((labelNameEdit = "") || (labelWidthEdit = 0) || (labelHeightEdit = 0)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")

			return false
		}
		else
			return Array(labelNameEdit, labelWidthEdit . " x " . labelHeightEdit)
	}

	getLabels() {
		if ControllerEditor.Instance.AutoSave {
			if (this.CurrentItem != 0)
				this.updateItem()
		}

		labels := {}

		for ignore, label in this.ItemList
			labels[label[1]] := label[2]

		return labels
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LayoutsList                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global layoutsListView := "|"

global layoutNameEdit := ""
global layoutTypeDropDown
global layoutDropDown

global layoutRowsEdit := ""
global layoutColumnsEdit := ""
global layoutRowMarginEdit := ""
global layoutColumnMarginEdit := ""
global layoutSidesMarginEdit := ""
global layoutBottomMarginEdit := ""

global layoutRowDropDown := 0
global layoutRowEdit := ""

global layoutVisibleCheck := true

global layoutAddButton
global layoutDeleteButton
global layoutUpdateButton

class LayoutsList extends ConfigurationItemList {
	iRowDefinitions := []
	iSelectedRow := false

	iStreamDeckConfiguration := false
	iButtonDefinitions := false
	iIconDefinitions := false

	iButtonBoxWidgets := []
	iStreamDeckWidgets := []

	AutoSave[] {
		Get {
			return ControllerEditor.Instance.AutoSave
		}
	}

	ButtonBoxConfiguration[] {
		Get {
			return this.Configuration
		}
	}

	StreamDeckConfiguration[] {
		Get {
			return this.iStreamDeckConfiguration
		}
	}

	CurrentControllerType[] {
		Get {
			return ((this.CurrentItem != 0) ? this.ItemList[this.CurrentItem][2]["Type"] : "Button Box")
		}
	}

	CurrentController[] {
		Get {
			return ((this.CurrentItem != 0) ? this.ItemList[this.CurrentItem][1] : false)
		}
	}

	__New(buttonBoxConfiguration, streamDeckConfiguration) {
		this.iStreamDeckConfiguration := streamDeckConfiguration

		base.__New(buttonBoxConfiguration)

		LayoutsList.Instance := this
	}

	createGui(buttonBoxConfiguration, streamDeckConfiguration) {
		Gui CTRLE:Add, ListView, x8 y330 w424 h105 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndlayoutsListViewHandle VlayoutsListView glistEvent
							 , % values2String("|", map(["Name", "Grid", "Margins", "Definition"], "translate")*)

		Gui CTRLE:Add, Text, x8 y445 w86 h23 +0x200, % translate("Name && Type")
		Gui CTRLE:Add, Edit, x102 y445 w110 h21 VlayoutNameEdit, %layoutNameEdit%
		Gui CTRLE:Add, DropDownList, x215 y445 w117 AltSubmit Choose1 VlayoutTypeDropDown gchooseLayoutType, % values2String("|", map(["Button Box", "Stream Deck"], "translate")*)

		Gui CTRLE:Add, Text, x8 y469 w86 h23 +0x200 Section hwndbbWidget1, % translate("Visible")
		if layoutVisibleCheck
			Gui CTRLE:Add, CheckBox, x102 y469 w110 h21 Checked VlayoutVisibleCheck hwndbbWidget2
		else
			Gui CTRLE:Add, CheckBox, x102 y469 w110 h21 VlayoutVisibleCheck hwndbbWidget2

		Gui CTRLE:Add, Text, x8 y493 w86 h23 +0x200 hwndbbWidget3, % translate("Layout")
		Gui CTRLE:Font, c505050 s7
		Gui CTRLE:Add, Text, x16 y517 w133 h21 hwndbbWidget4, % translate("(R x C, Margins)")
		Gui CTRLE:Font

		Gui CTRLE:Add, Edit, x102 y493 w40 h21 Limit1 Number gupdateLayoutRowEditor VlayoutRowsEdit hwndbbWidget5, %layoutRowsEdit%
		Gui CTRLE:Add, UpDown, x125 y493 w17 h21 hwndbbWidget6, 1
		Gui CTRLE:Add, Text, x147 y493 w20 h23 +0x200 Center hwndbbWidget7, % translate("x")
		Gui CTRLE:Add, Edit, x172 y493 w40 h21 Limit1 Number gupdateLayoutRowEditor VlayoutColumnsEdit hwndbbWidget8, %layoutColumnsEdit%
		Gui CTRLE:Add, UpDown, x195 y493 w17 h21 hwndbbWidget9, 1

		Gui CTRLE:Font, c505050 s7

		Gui CTRLE:Add, Text, x242 y474 w40 h23 +0x200 Center hwndbbWidget10, % translate("Row")
		Gui CTRLE:Add, Text, x292 y474 w40 h23 +0x200 Center hwndbbWidget11, % translate("Column")
		Gui CTRLE:Add, Text, x342 y474 w40 h23 +0x200 Center hwndbbWidget12, % translate("Sides")
		Gui CTRLE:Add, Text, x392 y474 w40 h23 +0x200 Center hwndbbWidget13, % translate("Bottom")

		Gui CTRLE:Font

		Gui CTRLE:Add, Edit, x242 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutRowMarginEdit hwndbbWidget14, %layoutRowMarginEdit%
		Gui CTRLE:Add, Edit, x292 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutColumnMarginEdit hwndbbWidget15, %layoutColumnMarginEdit%
		Gui CTRLE:Add, Edit, x342 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutSidesMarginEdit hwndbbWidget16, %layoutSidesMarginEdit%
		Gui CTRLE:Add, Edit, x392 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutBottomMarginEdit hwndbbWidget17, %layoutBottomMarginEdit%

		Gui CTRLE:Add, DropDownList, x8 y534 w86 AltSubmit Choose0 gupdateLayoutRowEditor VlayoutRowDropDown hwndbbWidget18, |

		Gui CTRLE:Add, Edit, x102 y534 w330 h50 Disabled VlayoutRowEdit hwndbbWidget19, %layoutRowEdit%

		loop 17
			this.iButtonBoxWidgets.Push(bbWidget%A_Index%)

		Gui CTRLE:Add, Text, x8 ys w86 h23 +0x200 hwndsdWidget1, % translate("Layout")
		Gui CTRLE:Add, DropDownList, x102 yp w110 AltSubmit Choose1 VlayoutDropDown gchooseLayout hwndsdWidget2, % values2String("|", map(["Mini", "Standard", "XL"], "translate")*)

		Gui CTRLE:Add, Button, x102 yp+30 w230 h23 Center gopenDisplayRulesEditor hwndsdWidget3, % translate("Edit Display Rules...")

		loop 3
			this.iStreamDeckWidgets.Push(sdWidget%A_Index%)

		Gui CTRLE:Add, Button, x223 y589 w46 h23 VlayoutAddButton gaddItem, % translate("Add")
		Gui CTRLE:Add, Button, x271 y589 w50 h23 Disabled VlayoutDeleteButton gdeleteItem, % translate("Delete")
		Gui CTRLE:Add, Button, x377 y589 w55 h23 Disabled VlayoutUpdateButton gupdateItem, % translate("&Save")

		this.initializeList(layoutsListViewHandle, "layoutsListView", "layoutAddButton", "layoutDeleteButton", "layoutUpdateButton")

		this.clearEditor()
	}

	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)

		layouts := {}

		for descriptor, definition in getConfigurationSectionValues(this.ButtonBoxConfiguration, "Layouts", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			name := descriptor[1]

			if !layouts.HasKey(name)
				layouts[name] := Object()

			layouts[name]["Type"] := "Button Box"
			layouts[name]["Visible"] := true

			if (descriptor[2] = "Layout") {
				definition := string2Values(",", definition)

				rowMargin := ((definition.Length() > 1) ? definition[2] : ButtonBoxPreview.kRowMargin)
				columnMargin := ((definition.Length() > 2) ? definition[3] : ButtonBoxPreview.kColumnMargin)
				sidesMargin := ((definition.Length() > 3) ? definition[4] : ButtonBoxPreview.kSidesMargin)
				bottomMargin := ((definition.Length() > 4) ? definition[5] : ButtonBoxPreview.kBottomMargin)

				layouts[name]["Grid"] := definition[1]
				layouts[name]["Margins"] := Array(rowMargin, columnMargin, sidesMargin, bottomMargin)
			}
			else if (descriptor[2] = "Visible")
				layouts[name]["Visible"] := definition
			else
				layouts[name][descriptor[2]] := definition
		}

		for descriptor, definition in getConfigurationSectionValues(this.StreamDeckConfiguration, "Layouts", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			name := descriptor[1]

			if !layouts.HasKey(name)
				layouts[name] := Object()

			layouts[name]["Type"] := "Stream Deck"
			layouts[name]["Visible"] := false

			if (descriptor[2] = "Layout")
				layouts[name]["Grid"] := definition
			else
				layouts[name][descriptor[2]] := definition
		}

		this.iButtonDefinitions := getConfigurationSectionValues(this.StreamDeckConfiguration, "Buttons", Object())
		this.iIconDefinitions := getConfigurationSectionValues(this.StreamDeckConfiguration, "Icons", Object())

		items := []

		for name, definition in layouts
			items.Push(Array(name, definition))

		this.ItemList := items
	}

	saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, save := true) {
		if save
			base.saveToConfiguration(buttonBoxConfiguration)

		for ignore, layout in this.ItemList {
			if (layout[2]["Type"] = "Button Box") {
				grid := layout[2]["Grid"]

				setConfigurationValue(buttonBoxConfiguration, "Layouts", ConfigurationItem.descriptor(layout[1], "Layout")
									, grid . ", " . values2String(", ", layout[2]["Margins"]*))

				loop % string2Values("x", grid)[1]
					setConfigurationValue(buttonBoxConfiguration, "Layouts"
										, ConfigurationItem.descriptor(layout[1], A_Index), layout[2][A_Index])

				setConfigurationValue(buttonBoxConfiguration, "Layouts"
									, ConfigurationItem.descriptor(layout[1], "Visible"), layout[2]["Visible"])
			}
			else {
				grid := layout[2]["Grid"]

				setConfigurationValue(streamDeckConfiguration, "Layouts", ConfigurationItem.descriptor(layout[1], "Layout"), grid)

				loop % string2Values("x", grid)[1]
					setConfigurationValue(streamDeckConfiguration, "Layouts"
										, ConfigurationItem.descriptor(layout[1], A_Index), layout[2][A_Index])

				setConfigurationSectionValues(streamDeckConfiguration, "Buttons", this.iButtonDefinitions)
				setConfigurationSectionValues(streamDeckConfiguration, "Icons", this.iIconDefinitions)
			}
		}
	}

	loadList(items) {
		static first := true
		static inCall := false

		Gui ListView, % this.ListHandle

		LV_Delete()

		this.ItemList := items

		for ignore, layout in items {
			grid := layout[2]["Grid"]

			definition := ""

			loop % string2Values("x", grid)[1]
			{
				if (A_Index > 1)
					definition .= "; "

				definition .= (A_Index . ": " . layout[2][A_Index])
			}


			LV_Add("", layout[1], grid, (layout[2]["Type"] = "Button Box") ? values2String(", ", layout[2]["Margins"]*) : "", definition)
		}

		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			LV_ModifyCol(3, "AutoHdr")
			LV_ModifyCol(4, "AutoHdr")

			first := false
		}

		ControllerEditor.Instance.configurationChanged(LayoutsList.Instance.CurrentControllerType, LayoutsList.Instance.CurrentController)
	}

	loadEditor(item) {
		if !item
			MsgBox Oops

		layoutNameEdit := item[1]
		layoutTypeDropDown := item[2]["Type"]
		layoutVisibleCheck := item[2]["Visible"]

		size := string2Values("x", item[2]["Grid"])

		layoutRowsEdit := size[1]
		layoutColumnsEdit := size[2]

		if (item[2]["Type"] = "Button Box") {
			for ignore, widget in this.iButtonBoxWidgets
				GuiControl Show, %widget%

			for ignore, widget in this.iStreamDeckWidgets
				GuiControl Hide, %widget%

			margins := item[2]["Margins"]

			layoutRowMarginEdit := margins[1]
			layoutColumnMarginEdit := margins[2]
			layoutSidesMarginEdit := margins[3]
			layoutBottomMarginEdit := margins[4]
		}
		else {
			for ignore, widget in this.iButtonBoxWidgets
				GuiControl Hide, %widget%

			for ignore, widget in this.iStreamDeckWidgets
				GuiControl Show, %widget%

			layoutRowMarginEdit := ""
			layoutColumnMarginEdit := ""
			layoutSidesMarginEdit := ""
			layoutBottomMarginEdit := ""

			if (layoutRowsEdit = 2)
				GuiControl Choose, layoutDropDown, 1
			else if (layoutRowsEdit = 3)
				GuiControl Choose, layoutDropDown, 2
			else
				GuiControl Choose, layoutDropDown, 3
		}

		Gui CTRLE:Default

		GuiControl Text, layoutNameEdit, %layoutNameEdit%
		GuiControl Choose, layoutTypeDropDown, % inList(["Button Box", "Stream Deck"], layoutTypeDropDown)
		GuiControl Text, layoutRowsEdit, %layoutRowsEdit%
		GuiControl Text, layoutColumnsEdit, %layoutColumnsEdit%
		GuiControl Text, layoutRowMarginEdit, %layoutRowMarginEdit%
		GuiControl Text, layoutColumnMarginEdit, %layoutColumnMarginEdit%
		GuiControl Text, layoutSidesMarginEdit, %layoutSidesMarginEdit%
		GuiControl Text, layoutBottomMarginEdit, %layoutBottomMarginEdit%

		GuiControl, , layoutVisibleCheck, %layoutVisibleCheck%

		if (item[2]["Type"] = "Button Box") {
			GuiControl Enable, layoutRowMarginEdit
			GuiControl Enable, layoutColumnMarginEdit
			GuiControl Enable, layoutSidesMarginEdit
			GuiControl Enable, layoutBottomMarginEdit

			GuiControl Enable, layoutVisibleCheck
		}
		else {
			GuiControl Disable, layoutRowMarginEdit
			GuiControl Disable, layoutColumnMarginEdit
			GuiControl Disable, layoutSidesMarginEdit
			GuiControl Disable, layoutBottomMarginEdit

			GuiControl Disable, layoutVisibleCheck
		}

		choices := []
		rowDefinitions := []

		loop %layoutRowsEdit% {
			choices.Push(translate("Row ") . A_Index)

			rowDefinitions.Push(item[2][A_Index])
		}

		this.iRowDefinitions := rowDefinitions

		GuiControl Text, layoutRowDropDown, % "|" . values2String("|", choices*)

		if (choices.Length() > 0) {
			GuiControl Choose, layoutRowDropDown, 1

			layoutRowEdit := (rowDefinitions.HasKey(1) ? rowDefinitions[1] : "")

			this.iSelectedRow := 1
		}
		else {
			GuiControl Choose, layoutRowDropDown, 0

			layoutRowEdit := ""

			this.iSelectedRow := false
		}

		GuiControl Text, layoutRowEdit, %layoutRowEdit%

		preview := ControllerEditor.Instance.ControllerPreview

		if ((this.CurrentController != layoutNameEdit) || (!preview && (layoutNameEdit != "")) || (preview && (preview.Name != layoutNameEdit)))
			ControllerEditor.Instance.configurationChanged(item[2]["Type"], layoutNameEdit)
	}

	addItem() {
		base.addItem()

		if this.CurrentItem {
			type := this.ItemList[this.CurrentItem][2]["Type"]

			GuiControl Text, layoutRowEdit, %layoutRowEdit%

			preview := ControllerEditor.Instance.ControllerPreview

			if ((this.CurrentController != layoutNameEdit) || (!preview && (layoutNameEdit != "")) || (preview && (preview.Name != layoutNameEdit)))
				ControllerEditor.Instance.configurationChanged(type, this.CurrentController)
		}
	}

	clearEditor() {
		margins := [ButtonBoxPreview.kRowMargin, ButtonBoxPreview.kColumnMargin, ButtonBoxPreview.kSidesMargin, ButtonBoxPreview.kBottomMargin]

		this.loadEditor(Array("", {Type: "Button Box", Visible: true, Grid: "0x0", Margins: margins}))
	}

	buildItemFromEditor(isNew := false) {
		GuiControlGet layoutNameEdit
		GuiControlGet layoutTypeDropDown
		GuiControlGet layoutRowsEdit
		GuiControlGet layoutColumnsEdit
		GuiControlGet layoutRowMarginEdit
		GuiControlGet layoutColumnMarginEdit
		GuiControlGet layoutSidesMarginEdit
		GuiControlGet layoutBottomMarginEdit
		GuiControlGet layoutVisibleCheck

		GuiControlGet layoutRowDropDown
		GuiControlGet layoutRowEdit

		if ((layoutNameEdit = "") || (layoutRowsEdit = 0) || (layoutColumnsEdit = 0)) {
			OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Ok"]))
			title := translate("Error")
			MsgBox 262160, %title%, % translate("Invalid values detected - please correct...")
			OnMessage(0x44, "")

			return false
		}
		else {
			if (layoutRowDropDown > 0)
				this.iRowDefinitions[layoutRowDropDown] := layoutRowEdit

			if (["Button Box", "Stream Deck"][layoutTypeDropDown] = "Button Box")
				layout := {Type: "Button Box", Grid: layoutRowsEdit . " x " . layoutColumnsEdit
						 , Visible: layoutVisibleCheck
						 , Margins: Array(layoutRowMarginEdit, layoutColumnMarginEdit, layoutSidesMarginEdit, layoutBottomMarginEdit)}
			else
				layout := {Type: "Stream Deck", Grid: layoutRowsEdit . " x " . layoutColumnsEdit, Visible: false}

			loop % this.iRowDefinitions.Length()
				layout[A_Index] := this.iRowDefinitions[A_Index]

			return Array(layoutNameEdit, layout)
		}
	}

	chooseLayoutType() {
		GuiControlGet layoutNameEdit
		GuiControlGet layoutTypeDropDown

		if (layoutTypeDropDown = 2) {
			grid := "3x5"

			margins := ["", "", "", ""]
		}
		else {
			GuiControlGet layoutRowsEdit
			GuiControlGet layoutColumnsEdit

			grid := (layoutRowsEdit . "x" . layoutColumnsEdit)

			margins := [ButtonBoxPreview.kRowMargin, ButtonBoxPreview.kColumnMargin, ButtonBoxPreview.kSidesMargin, ButtonBoxPreview.kBottomMargin]
		}

		this.loadEditor(Array(layoutNameEdit, {Type: ["Button Box", "Stream Deck"][layoutTypeDropDown], Visible: (layoutTypeDropDown = 1) ? true : false, Grid: grid, Margins: margins}))

		if (this.CurrentItem != 0)
			this.updateItem()
	}

	chooseLayout() {
		GuiControlGet layoutDropDown

		if (layoutDropDown = 1) {
			GuiControl, , layoutRowsEdit, 2
			GuiControl, , layoutColumnsEdit, 3
		}
		else if (layoutDropDown = 2) {
			GuiControl, , layoutRowsEdit, 3
			GuiControl, , layoutColumnsEdit, 5
		}
		else {
			GuiControl, , layoutRowsEdit, 4
			GuiControl, , layoutColumnsEdit, 8
		}

		if (this.CurrentItem != 0)
			this.updateItem()
	}

	openDisplayRulesEditor() {
		name := false

		if this.CurrentItem {
			GuiControlGet layoutNameEdit

			name := layoutNameEdit
		}

		configuration := newConfiguration()

		setConfigurationSectionValues(configuration, "Icons", this.iIconDefinitions)
		setConfigurationSectionValues(configuration, "Buttons", this.iButtonDefinitions)

		Gui IRE:+OwnerCTRLE
		Gui CTRLE:+Disabled

		try {
			result := (new DisplayRulesEditor(name, configuration)).editDisplayRules()
		}
		finally {
			Gui CTRLE:-Disabled
		}

		if result {
			this.iIconDefinitions := getConfigurationSectionValues(configuration, "Icons", Object())
			this.iButtonDefinitions := getConfigurationSectionValues(configuration, "Buttons", Object())
		}
	}

	updateLayoutRowEditor(save := true) {
		Gui CTRLE:Default

		GuiControlGet layoutRowsEdit
		GuiControlGet layoutRowDropDown
		GuiControlGet layoutRowEdit

		if (save && (this.iSelectedRow > 0))
			this.iRowDefinitions[this.iSelectedRow] := layoutRowEdit

		rows := this.iRowDefinitions.Length()
		changed := false

		if (layoutRowsEdit > rows) {
			loop % layoutRowsEdit - rows
				this.iRowDefinitions.Push("")

			changed := true
		}
		else if (layoutRowsEdit < rows) {
			this.iRowDefinitions.RemoveAt(layoutRowsEdit + 1, rows - layoutRowsEdit)

			changed := true
		}

		loop %layoutRowsEdit%
			this.iRowDefinitions[A_Index] := values2String(";", this.getRowDefinition(A_Index)*)

		if (layoutRowDropDown > 0) {
			layoutRowEdit := ((this.iRowDefinitions.Length() >= layoutRowDropDown) ? this.iRowDefinitions[layoutRowDropDown] : "")

			this.iSelectedRow := layoutRowDropDown

			GuiControl Text, layoutRowEdit, %layoutRowEdit%
		}

		if changed {
			choices := []

			loop %layoutRowsEdit%
				choices.Push(translate("Row ") . A_Index)

			GuiControl Text, layoutRowDropDown, % "|" . values2String("|", choices*)

			if (layoutRowsEdit > 0) {
				layoutRowDropDown := 1

				GuiControl Choose, layoutRowDropDown, 1

				layoutRowEdit := this.iRowDefinitions[1]
			}
			else {
				layoutRowDropDown := 0

				GuiControl Choose, layoutRowDropDown, 0

				layoutRowEdit := ""
			}

			this.iSelectedRow := layoutRowDropDown

			GuiControl Text, layoutRowEdit, %layoutRowEdit%
		}

		if (save && ControllerEditor.Instance.AutoSave) {
			if (this.CurrentItem != 0)
				this.updateItem()
		}
	}

	getRowDefinition(row) {
		rowDefinition := string2Values(";", this.iRowDefinitions[row])

		GuiControlGet layoutColumnsEdit

		if (rowDefinition.Length() > layoutColumnsEdit)
			rowDefinition.RemoveAt(layoutColumnsEdit + 1, rowDefinition.Length() - layoutColumnsEdit)
		else
			loop % layoutColumnsEdit - rowDefinition.Length()
				rowDefinition.Push("")

		return rowDefinition
	}

	setRowDefinition(row, rowDefinition) {
		this.iRowDefinitions[row] := values2String(";", rowDefinition*)

		this.updateLayoutRowEditor(false)

		this.updateItem()

		ControllerEditor.Instance.configurationChanged(this.CurrentControllerType, this.CurrentController)
	}

	changeControl(row, column, control, argument := false) {
		number := argument
		oldButton := false

		Gui CTRLE:Default

		GuiControlGet layoutNameEdit

		if (this.CurrentControllerType = "Stream Deck") {
			oldButton := ControllerEditor.Instance.ControllerPreview.getButton(row, column)

			if oldButton {
				oldNumber := oldButton.Button

				this.iButtonDefinitions.Delete(layoutNameEdit . "." . "Button." . oldNumber . ".Icon")
				this.iButtonDefinitions.Delete(layoutNameEdit . "." . "Button." . oldNumber . ".Label")
				this.iButtonDefinitions.Delete(layoutNameEdit . "." . "Button." . oldNumber . ".Mode")
			}
		}

		rowDefinition := this.getRowDefinition(row)

		definition := string2Values(",", rowDefinition[column])

		if (control = "__Mode__") {
			oldButton.Mode := argument
			number := oldButton.Button
			definition := rowDefinition[column]
		}
		else if (control = "__No_Label__") {
			oldButton.Label := false
			number := oldButton.Button
			definition := rowDefinition[column]
		}
		else if (control = "__Action_Label__") {
			oldButton.Label := true
			number := oldButton.Button
			definition := rowDefinition[column]
		}
		else if (control = "__Text_Label__") {
			oldLabel := (oldButton ? oldButton.Label : false)

			title := translate("Button Label")
			prompt := translate("Please enter a button label:")
			locale := ((getLanguage() = "en") ? "" : "Locale")

			InputBox argument, %title%, %prompt%, , 200, 150, , , %locale%, , % ((oldLabel && (oldLabel != true)) ? oldLabel : "")

			if ErrorLevel
				return
			else
				oldButton.Label := argument

			number := oldButton.Button
			definition := rowDefinition[column]
		}
		else if (control = "__No_Icon__") {
			oldButton.Icon := false
			number := oldButton.Button
			definition := rowDefinition[column]
		}
		else if (control = "__Action_Icon__") {
			oldButton.Icon := true
			number := oldButton.Button
			definition := rowDefinition[column]
		}
		else if (control = "__Image_Icon__") {
			oldImage := (oldButton ? oldButton.Icon : false)

			newImage := chooseImageFile((oldImage && (oldImage != true)) ? oldImage : SubStr(kStreamDeckImagesDirectory, 1, StrLen(kStreamDeckImagesDirectory) - 1))

			if newImage
				oldButton.Icon := newImage
			else
				return

			number := oldButton.Button
			definition := rowDefinition[column]
		}
		else if (control = "__Number__") {
			if !number {
				title := translate("Function Number")
				prompt := translate("Please enter a controller function number:")
				number := ConfigurationItem.splitDescriptor(definition[1])[2]
				locale := ((getLanguage() = "en") ? "" : "Locale")

				InputBox number, %title%, %prompt%, , 200, 150, , , %locale%, , %number%

				if ErrorLevel
					return
			}

			if (definition.Length() = 1)
				definition := ConfigurationItem.descriptor(ConfigurationItem.splitDescriptor(definition[1])[1], number)
			else if (this.CurrentControllerType = "Stream Deck")
				definition := ("Button." . number)
			else
				definition := (ConfigurationItem.descriptor(ConfigurationItem.splitDescriptor(definition[1])[1], number) . "," . definition[2])
		}
		else if control {
			if (definition.Length() = 0) {
				definition := ConfigurationItem.descriptor(control, 1)
				number := 1
			}
			else if (definition.Length() = 1) {
				number := ConfigurationItem.splitDescriptor(definition[1])[2]
				definition := ConfigurationItem.descriptor(control, number)
			}
			else {
				number := ConfigurationItem.splitDescriptor(definition[1])[2]
				definition := (ConfigurationItem.descriptor(control, number) . "," . definition[2])
			}
		}
		else {
			definition := ""
			number := false
		}

		if (number && (this.CurrentControllerType = "Stream Deck")) {
			if !oldButton
				oldButton := {Button: number, Icon: true, Label: true, Mode: kIconOrLabel}

			this.iButtonDefinitions[layoutNameEdit . "." . "Button." . number . ".Icon"] := oldButton.Icon
			this.iButtonDefinitions[layoutNameEdit . "." . "Button." . number . ".Label"] := oldButton.Label
			this.iButtonDefinitions[layoutNameEdit . "." . "Button." . number . ".Mode"] := oldButton.Mode
		}

		rowDefinition[column] := definition

		this.setRowDefinition(row, rowDefinition)
	}

	changeLabel(row, column, label) {
		rowDefinition := this.getRowDefinition(row)

		definition := string2Values(",", rowDefinition[column])

		if (definition.Length() = 0)
			definition := (label ? ("," . label) : "")
		else if (definition.Length() >= 1)
			definition := (definition[1] . (label ? ("," . label) : ""))

		rowDefinition[column] := definition

		this.setRowDefinition(row, rowDefinition)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerPreview                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerPreview extends ConfigurationItem {
	static sCurrentWindow := 0

	iPreviewManager := false
	iName := ""

	iRows := false
	iColumns := false

	iWindow := false

	iWidth := 0
	iHeight := 0

	iControlClickHandler := ObjBindMethod(this, "openControlMenu")

	PreviewManager[] {
		Get {
			return this.iPreviewManager
		}
	}

	Name[] {
		Get {
			return this.iName
		}
	}

	Type[] {
		Get {
			throw "Virtual property ControllerPreview.Type must be implemented in a subclass..."
		}
	}

	Rows[] {
		Get {
			return this.iRows
		}

		Set {
			this.iRows := value
		}
	}

	Columns[] {
		Get {
			return this.iColumns
		}

		Set {
			this.iColumns := value
		}
	}

	Width[] {
		Get {
			return this.iWidth
		}

		Set {
			this.iWidth := value
		}
	}

	Height[] {
		Get {
			return this.iHeight
		}

		Set {
			this.iHeight := value
		}
	}

	Window[] {
		Get {
			return this.iWindow
		}
	}

	CurrentWindow[] {
		Get {
			return ("CTRLP" . ControllerPreview.sCurrentWindow)
		}
	}

	__New(previewManager, name, configuration) {
		this.iPreviewManager := previewManager
		this.iName := name

		ControllerPreview.sCurrentWindow += 1

		this.iWindow := this.CurrentWindow

		base.__New(configuration)

		this.createGui(configuration)

		this.createBackground(configuration)
	}

	createGui(configuration) {
		throw "Virtual method ControllerPreview.createGui must be implemented in a subclass..."
	}

	createBackground(configuration) {
	}

	getControl(clickX, clickY, ByRef row, ByRef column, ByRef isEmpty) {
		throw "Virtual method ControllerPreview.getControl must be implemented in a subclass..."
	}

	setControlClickHandler(handler) {
		this.iControlClickHandler := handler
	}

	controlClick(element, row, column, isEmpty) {
		throw "Virtual method ControllerPreview.controlClick must be implemented in a subclass..."
	}

	openControlMenu(preview, element, function, row, column, isEmpty) {
		throw "Virtual method ControllerPreview.openControlMenu must be implemented in a subclass..."
	}

	getFunction(row, column) {
		throw "Virtual method ControllerPreview.getFunction must be implemented in a subclass..."
	}

	findFunction(function, ByRef row, ByRef column) {
		loop % this.Rows
		{
			cRow := A_Index

			loop % this.Columns
			{
				if (this.getFunction(cRow, A_Index) = function) {
					row := cRow
					column := A_Index

					return true
				}
			}
		}

		return false
	}

	resetLabels() {
		local function

		loop % this.Rows
		{
			row := A_Index

			loop % this.Columns
			{
				function := this.getFunction(row, A_Index)

				if function
					this.setLabel(row, A_Index, ConfigurationItem.splitDescriptor(function)[2])
			}
		}
	}

	setLabel(row, column, text) {
		throw "Virtual method ControllerPreview.setLabel must be implemented in a subclass..."
	}

	open() {
		width := this.Width
		height := this.Height

		centerX := 0
		centerY := 0

		this.PreviewManager.getPreviewCenter(centerX, centerY)

		SysGet mainScreen, MonitorWorkArea

		x := mainScreenRight - width
		y := mainScreenBottom - height

		if centerX
			x := centerX - Round(width / 2)

		if centerY
			y := centerY - Round(height / 2)

		window := this.Window

		vControllerPreviews[window] := this

		Gui %window%:Show, x%x% y%y% w%width% h%height% NoActivate
	}

	close() {
		window := this.Window

		vControllerPreviews.Delete(window)

		Gui %window%:Destroy
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; DisplayRulesEditor                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global displayRuleLayoutDropDown
global displayRuleButtonDropDown

class DisplayRulesEditor extends ConfigurationItem {
	iClosed := false
	iSaved := false

	iLayout := false
	iSelectedLayout := false

	iButtons := false
	iSelectedButton := false

	iDisplayRulesList := false

	Layout[] {
		Get {
			return this.iLayout
		}
	}

	SelectedLayout[] {
		Get {
			return this.iSelectedLayout
		}
	}

	Buttons[index := false] {
		Get {
			if index
				return this.iButtons[index]
			else
				return this.iButtons
		}
	}

	SelectedButton[] {
		Get {
			return this.iSelectedButton
		}
	}

	__New(layout, configuration) {
		this.iLayout := layout
		this.iSelectedLayout := layout

		base.__New(configuration)

		DisplayRulesEditor.Instance := this

		this.iDisplayRulesList := new DisplayRulesList(configuration)

		this.createGui(configuration)
	}

	createGui(configuration) {
		Gui IRE:Default

		Gui IRE:-Border ; -Caption

		Gui IRE:Color, D0D0D0, D8D8D8
		Gui IRE:Font, Bold, Arial

		Gui IRE:Add, Text, x0 w332 Center gmoveDisplayRulesEditor, % translate("Modular Simulator Controller System")

		Gui IRE:Font, Norm, Arial
		Gui IRE:Font, Italic Underline, Arial

		Gui IRE:Add, Text, x110 YP+20 w112 cBlue Center gopenDisplayRulesDocumentation, % translate("Display Rules")

		Gui IRE:Font, Norm, Arial

		layouts := [translate("All Layouts")]
		chosen := 1

		if this.Layout {
			layouts.Push(this.Layout)

			chosen := 2
		}

		Gui IRE:Add, Text, x8 yp+30 w80 h23 +0x200, % translate("Layout")
		Gui IRE:Add, DropDownList, x90 yp w150 AltSubmit Choose%chosen% VdisplayRuleLayoutDropDown gchooseDisplayRuleLayout, % values2String("|", layouts*)

		buttons := [translate("All Buttons")]
		disabled := ""

		if !this.Layout {
			disabled := "Disabled"
			chosen := 0
		}
		else
			chosen := 1

		Gui IRE:Add, Text, x8 yp+24 w80 h23 +0x200 hwndwidget1, % translate("Button")
		Gui IRE:Add, DropDownList, x90 yp w150 AltSubmit %disabled% Choose%chosen% vdisplayRuleButtonDropDown gchooseDisplayRuleButton, % values2String("|", buttons*)

		this.iDisplayRulesList.createGui(configuration)

		Gui IRE:Add, Text, x50 yp+30 w232 0x10

		Gui IRE:Add, Button, x80 yp+10 w80 h23 Default GsaveDisplayRulesEditor, % translate("Save")
		Gui IRE:Add, Button, x180 yp w80 h23 GcancelDisplayRulesEditor, % translate("Cancel")

		this.loadLayoutButtons()
}

	saveToConfiguration(configuration) {
		this.iDisplayRulesList.saveToConfiguration(configuration)
	}

	loadLayoutButtons() {
		Gui IRE:Default

		buttons := [translate("All Buttons")]

		if this.SelectedLayout
			for descriptor, definition in getConfigurationSectionValues(LayoutsList.Instance.StreamDeckConfiguration, "Layouts", Object()) {
				descriptor := ConfigurationItem.splitDescriptor(descriptor)

				if ((descriptor[1] = this.Layout) && (descriptor[2] != "Layout"))
					for ignore, button in string2Values(";", definition)
						if (button != "")
							buttons.Push(button)
			}

		GuiControl, , displayRuleButtonDropDown, % ("|" . values2String("|", buttons*))
		GuiControl Choose, displayRuleButtonDropDown, % (this.SelectedLayout ? 1 : 0)

		buttons.RemoveAt(1)

		this.iButtons := buttons

		if this.SelectedLayout
			GuiControl Enable, displayRuleButtonDropDown
		else
			GuiControl Disable, displayRuleButtonDropDown

		this.iSelectedButton := false
	}

	editDisplayRules() {
		this.open()

		loop
			Sleep 200
		until this.iClosed

		return this.iSaved
	}

	open() {
		window := this.Window

		Gui IRE:Show, AutoSize Center
	}

	close(save := true) {
		if save
			this.iDisplayRulesList.saveToConfiguration(this.Configuration)

		this.iSaved := save

		Gui IRE:Destroy

		this.iClosed := true
	}

	chooseDisplayRuleLayout() {
		local displayRulesList := this.iDisplayRulesList

		GuiControlGet displayRuleLayoutDropDown

		displayRulesList.saveToConfiguration(this.Configuration)

		this.iSelectedLayout := ((displayRuleLayoutDropDown = 1) ? false : this.Layout)

		this.loadLayoutButtons()

		displayRulesList.loadFromConfiguration(this.Configuration)

		displayRulesList.loadList(displayRulesList.ItemList)

		displayRulesList.CurrentItem := false
		displayRulesList.clearEditor()
	}

	chooseDisplayRuleButton() {
		local displayRulesList := this.iDisplayRulesList

		GuiControlGet displayRuleButtonDropDown

		displayRulesList.saveToConfiguration(this.Configuration)

		this.iSelectedButton := ((displayRuleButtonDropDown = 1) ? false : this.Buttons[displayRuleButtonDropDown - 1])

		displayRulesList.loadFromConfiguration(this.Configuration)

		displayRulesList.loadList(displayRulesList.ItemList)

		displayRulesList.CurrentItem := false
		displayRulesList.clearEditor()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; DisplayRulesList                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global displayRulesListView := "|"

global iconFilePathEdit := ""
global displayRuleDropDown
global displayRuleAddButton
global displayRuleDeleteButton
global displayRuleUpdateButton

class DisplayRulesList extends ConfigurationItemList {
	AutoSave[] {
		Get {
			return ControllerEditor.Instance.AutoSave
		}
	}

	__New(configuration) {
		base.__New(configuration)

		DisplayRulesList.Instance := this
	}

	createGui(configuration) {
		Gui IRE:Add, ListView, x8 yp+30 w316 h120 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwnddisplayRulesListViewHandle VdisplayRulesListView glistEvent
							 , % values2String("|", map(["Rule", "Icon"], "translate")*)

		Gui IRE:Add, Text, x8 yp+126 w80 h23 +0x200, % translate("Rule")
		Gui IRE:Add, DropDownList, x90 yp w150 AltSubmit Choose1 VdisplayRuleDropDown, % values2String("|", map(["Icon or Label", "Icon and Label", "Only Icon", "Only Label"], "translate")*)

		Gui IRE:Add, Text, x8 yp+24 w80 h23 +0x200, % translate("Icon")
		Gui IRE:Add, Edit, x90 yp w211 h21 ViconFilePathEdit, %iconFilePathEdit%
		Gui IRE:Add, Button, x303 yp-1 w23 h23 gchooseIconFilePath, % translate("...")

		Gui IRE:Add, Button, x126 yp+40 w46 h23 VdisplayRuleAddButton gaddItem, % translate("Add")
		Gui IRE:Add, Button, x175 yp w50 h23 Disabled VdisplayRuleDeleteButton gdeleteItem, % translate("Delete")
		Gui IRE:Add, Button, x271 yp w55 h23 Disabled VdisplayRuleUpdateButton gupdateItem, % translate("Save")

		this.initializeList(displayRulesListViewHandle, "displayRulesListView", "displayRuleAddButton", "displayRuleDeleteButton", "displayRuleUpdateButton")

		this.clearEditor()
	}

	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)

		this.ItemList := this.loadDisplayRules(configuration, DisplayRulesEditor.Instance.SelectedLayout, DisplayRulesEditor.Instance.SelectedButton)
	}

	saveToConfiguration(configuration) {
		fullConfiguration := this.Configuration

		this.saveDisplayRules(fullConfiguration, DisplayRulesEditor.Instance.SelectedLayout, DisplayRulesEditor.Instance.SelectedButton, this.ItemList)

		setConfigurationSectionValues(configuration, "Icons", getConfigurationSectionValues(fullConfiguration, "Icons"))
		setConfigurationSectionValues(configuration, "Buttons", getConfigurationSectionValues(fullConfiguration, "Buttons"))
	}

	loadDisplayRules(configuration, layout, button) {
		icons := []

		if button {
			prefix := (layout . "." . button . ".Mode.Icon.")

			loop {
				icon := getConfigurationValue(configuration, "Buttons", prefix . A_Index, kUndefined)

				if (icon = kUndefined)
					break
				else
					icons.Push(string2Values(";", icon))
			}
		}
		else {
			prefix := ((layout ? layout : "*") . ".Icon.Mode.")

			loop {
				icon := getConfigurationValue(configuration, "Icons", prefix . A_Index, kUndefined)

				if (icon = kUndefined)
					break
				else
					icons.Push(string2Values(";", icon))
			}
		}

		return icons
	}

	saveDisplayRules(configuration, layout, button, displayRules) {
		if button {
			prefix := (layout . "." . button . ".Mode.Icon.")

			loop {
				if (getConfigurationValue(configuration, "Buttons", prefix . A_Index, kUndefined) == kUndefined)
					break
				else
					removeConfigurationValue(configuration, "Buttons", prefix . A_Index)
			}

			for index, displayRule in displayRules
				setConfigurationValue(configuration, "Buttons", prefix . index, values2String(";", displayRule*))
		}
		else {
			prefix := ((layout ? layout : "*") . ".Icon.Mode.")

			loop {
				if (getConfigurationValue(configuration, "Icons", prefix . A_Index, kUndefined) == kUndefined)
					break
				else
					removeConfigurationValue(configuration, "Icons", prefix . A_Index)
			}

			for index, displayRule in displayRules
				setConfigurationValue(configuration, "Icons", prefix . index, values2String(";", displayRule*))
		}
	}

	loadList(items) {
		local rule

		Gui ListView, % this.ListHandle

		LV_Delete()

		this.ItemList := items

		for ignore, displayRule in items {
			rule := ["Icon or Label", "Icon and Label", "Only Icon", "Only Label"][inList([kIconOrLabel, kIconAndLabel, kIcon, kLabel], displayRule[2])]

			LV_Add("", translate(rule), displayRule[1])
		}

		LV_ModifyCol()
		LV_ModifyCol(1, "AutoHdr")
		LV_ModifyCol(2, "AutoHdr")
	}

	loadEditor(item) {
		iconFilePathEdit := item[1]
		displayRuleDropDown := inList([kIconOrLabel, kIconAndLabel, kIcon, kLabel], item[2])

		GuiControl Text, iconFilePathEdit, %iconFilePathEdit%
		GuiControl Choose, displayRuleDropDown, %displayRuleDropDown%
	}

	clearEditor() {
		this.loadEditor(Array("", kIconOrLabel))
	}

	buildItemFromEditor(isNew := false) {
		GuiControlGet iconFilePathEdit
		GuiControlGet displayRuleDropDown

		return Array(iconFilePathEdit, [kIconOrLabel, kIconAndLabel, kIcon, kLabel][displayRuleDropDown])
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

controlClick() {
	curCoordMode := A_CoordModeMouse

	CoordMode Mouse, Window

	try {
		MouseGetPos clickX, clickY

		row := 0
		column := 0
		isEmpty := false

		element := vControllerPreviews[A_Gui].getControl(clickX, clickY, row, column, isEmpty)

		if element
			vControllerPreviews[A_Gui].controlClick(element, row, column, isEmpty)
	}
	finally {
		CoordMode Mouse, curCoordMode
	}
}

controlMenuIgnore() {
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

saveControllerEditor() {
	ControllerEditor.Instance.close(true)
}

cancelControllerEditor() {
	ControllerEditor.Instance.close(false)
}

moveControllerEditor() {
	moveByMouse(A_Gui, "Controller Editor")
}

openControllerDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#controller-layouts
}

chooseLayoutType() {
	LayoutsList.Instance.chooseLayoutType()
}

chooseLayout() {
	LayoutsList.Instance.chooseLayout()
}

chooseImageFile(path) {
	title := translate("Select Image...")

	Gui +OwnDialogs

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Cancel"]))
	FileSelectFile pictureFile, 1, %path%, %title%, Image (*.jpg; *.png; *.gif; *.ico)
	OnMessage(0x44, "")

	return ((pictureFile != "") ? pictureFile : false)
}

chooseImageFilePath() {
	GuiControlGet imageFilePathEdit

	path := imageFilePathEdit

	if (path && (path != ""))
		path := getFileName(path, kButtonBoxImagesDirectory)
	else
		path := SubStr(kButtonBoxImagesDirectory, 1, StrLen(kButtonBoxImagesDirectory) - 1)

	pictureFile := chooseImageFile(path)

	if pictureFile {
		imageFilePathEdit := pictureFile

		GuiControl Text, imageFilePathEdit, %imageFilePathEdit%
	}
}

chooseIconFilePath() {
	GuiControlGet iconFilePathEdit

	path := iconFilePathEdit

	if (path && (path != ""))
		path := getFileName(path, kStreamDeckImagesDirectory)
	else
		path := SubStr(kStreamDeckImagesDirectory, 1, StrLen(kStreamDeckImagesDirectory) - 1)

	pictureFile := chooseImageFile(path)

	if pictureFile {
		iconFilePathEdit := pictureFile

		GuiControl Text, iconFilePathEdit, %iconFilePathEdit%
	}
}

updateLayoutRowEditor() {
	try {
		list := ConfigurationItemList.getList("layoutsListView")

		if list
			list.updateLayoutRowEditor()
	}
	catch exception {
		; ignore
	}
}

openDisplayRulesEditor() {
	LayoutsList.Instance.openDisplayRulesEditor()
}

openControllerActionsEditor() {
	owner := ControllerEditor.Instance.Window
	Gui CTRLE:+Disabled

	Gui PAE:+OwnerCTRLE

	new ControllerActionsEditor(kSimulatorConfiguration).editPluginActions()

	Gui CTRLE:-Disabled
}

moveControllerPreview() {
	window := ControllerPreview.CurrentWindow

	moveByMouse(window)

	WinGetPos x, y, width, height, A

	vControllerPreviews[A_Gui].PreviewManager.setPreviewCenter(x + Round(width / 2), y + Round(height / 2))
}

saveDisplayRulesEditor() {
	DisplayRulesEditor.Instance.close(true)
}

cancelDisplayRulesEditor() {
	DisplayRulesEditor.Instance.close(false)
}

moveDisplayRulesEditor() {
	moveByMouse(A_Gui)
}

openDisplayRulesDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#display-rules
}

chooseDisplayRuleLayout() {
	DisplayRulesEditor.Instance.chooseDisplayRuleLayout()
}

chooseDisplayRuleButton() {
	DisplayRulesEditor.Instance.chooseDisplayRuleButton()
}