;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Button Box Editor               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Configuration\Libraries\ConfigurationItemList.ahk
#Include ..\Configuration\Libraries\ButtonBoxPreview.ahk
#Include ..\Configuration\Libraries\StreamDeckPreview.ahk


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kControlTypes = {}

kControlTypes[k1WayToggleType] := "1-way Toggle"
kControlTypes[k2WayToggleType] := "2-way Toggle"
kControlTypes[kButtonType] := "Button"
kControlTypes[kDialType] := "Rotary"
kControlTypes[kCustomType] := "Custom"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ButtonBoxEditor                                                         ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ButtonBoxEditor extends ConfigurationItem {
	iControlsList := false
	iLabelsList := false
	iLayoutsList := false
	
	iName := ""
	iClosed := false
	
	iButtonBoxPreview := false
	
	iButtonBoxConfiguration := false
	iButtonBoxConfigurationFile := false
	
	iPreviewCenterX := 0
	iPreviewCenterY := 0
	
	ButtonBoxPreview[] {
		Get {
			return this.iButtonBoxPreview
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
	
	AutoSave[] {
		Get {
			try {
				if (ConfigurationEditor && ConfigurationEditor.Instance)
					return ConfigurationEditor.Instance.AutoSave
				else
					return false
			}
			catch exception {
				return false
			}
		}
	}
	
	__New(name, configuration, configurationFile := false, saveAndCancel := true) {
		this.iName := name
		
		if !configurationFile
			configurationFile := getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory)
		
		this.iButtonBoxConfigurationFile := configurationFile
		
		this.iButtonBoxConfiguration := readConfiguration(configurationFile)
		
		this.iControlsList := new ControlsList(this.iButtonBoxConfiguration)
		this.iLabelsList := new LabelsList(this.iButtonBoxConfiguration)
		this.iLayoutsList := new LayoutsList(this.iButtonBoxConfiguration)
		
		base.__New(configuration)
		
		ButtonBoxEditor.Instance := this
		
		this.createGui(this.iButtonBoxConfiguration, saveAndCancel)
	}
	
	createGui(configuration, saveAndCancel) {
		Gui BBE:Default
	
		Gui BBE:-Border ; -Caption
		
		Gui BBE:Color, D0D0D0, D8D8D8
		Gui BBE:Font, Bold, Arial

		Gui BBE:Add, Text, x0 w432 Center gmoveButtonBoxEditor, % translate("Modular Simulator Controller System") 
		
		Gui BBE:Font, Norm, Arial
		Gui BBE:Font, Italic Underline, Arial

		Gui BBE:Add, Text, x0 YP+20 w432 cBlue Center gopenButtonBoxesDocumentation, % translate("Button Box Layouts")
		
		this.iControlsList.createGui(configuration)
		this.iLabelsList.createGui(configuration)
		this.iLayoutsList.createGui(configuration)
		
		if saveAndCancel {
			Gui BBE:Add, Text, x50 y639 w332 0x10
			
			Gui BBE:Add, Button, x130 y654 w80 h23 Default GsaveButtonBoxEditor, % translate("Save")
			Gui BBE:Add, Button, x230 y654 w80 h23 GcancelButtonBoxEditor, % translate("Cancel")
		}
	}
	
	saveToConfiguration(configuration, save := true) {
		if save
			base.saveToConfiguration(configuration)
		
		this.iControlsList.saveToConfiguration(configuration, save)
		this.iLabelsList.saveToConfiguration(configuration, save)
		this.iLayoutsList.saveToConfiguration(configuration, save)
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
		return "moveButtonBoxPreview"
	}
	
	open(x := "Center", y := "Center") {
		Gui BBE:Show, AutoSize x%x% y%y%
		
		name := this.Name
		
		if !this.AutoSave
			for index, item in this.iLayoutsList.ItemList
				if (item[1] = name) {
					this.iLayoutsList.openEditor(index)
					this.iLayoutsList.selectItem(index)
					
					break
				}
	}
	
	close(save := true) {
		if save {
			configuration := newConfiguration()
		
			this.saveToConfiguration(configuration)
			
			writeConfiguration(this.ButtonBoxConfigurationFile, configuration)
		}
			
		this.saveButtonBox()
		
		if this.ButtonBoxPreview {
			this.ButtonBoxPreview.close()
			
			this.iButtonBoxPreview := false
		}
		
		Gui BBE:Destroy
		
		this.iClosed := true
	}
	
	editButtonBox() {
		this.open()
		
		Loop
			Sleep 200
		until this.iClosed
	}
	
	configurationChanged(name) {
		this.updateButtonBoxPreview(name)
	}

	updateButtonBoxPreview(name) {
		configuration := newConfiguration()
		
		this.saveToConfiguration(configuration, false)
		
		this.iButtonBoxConfiguration := configuration
		
		oldPreview := this.ButtonBoxPreview
		
		if name {
			this.iButtonBoxPreview := new ButtonBoxPreview(this, name, configuration)
		
			this.ButtonBoxPreview.open()
		}
		else
			this.iButtonBoxPreview := false
		
		if oldPreview
			oldPreview.close()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControlsList                                                            ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

global controlsListView := "|"

global controlNameEdit = ""
global controlTypeDropDown = 0
global imageFilePathEdit = ""
global imageWidthEdit = 0
global imageHeightEdit = 0

global controlAddButton
global controlDeleteButton
global controlUpdateButton
		
class ControlsList extends ConfigurationItemList {
	__New(configuration) {
		base.__New(configuration)
				 
		ControlsList.Instance := this
	}
					
	createGui(configuration) {
		Gui BBE:Font, Norm, Arial
		Gui BBE:Font, Italic, Arial
		
		Gui BBE:Add, GroupBox, -Theme x8 y60 w424 h138, % translate("Controls")
		
		Gui BBE:Font, Norm, Arial
		Gui BBE:Add, ListView, x16 y79 w134 h108 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndcontrolsListViewHandle VcontrolsListView glistEvent
							 , % values2String("|", map(["Name", "Function", "Size"], "translate")*)
							
		Gui BBE:Add, Text, x164 y79 w80 h23 +0x200, % translate("Name")
		Gui BBE:Add, Edit, x214 y80 w101 h21 VcontrolNameEdit, %controlNameEdit%
		Gui BBE:Add, DropDownList, x321 y79 w105 AltSubmit Choose%controlTypeDropDown% VcontrolTypeDropDown, % values2String("|", map(["1-way Toggle", "2-way Toggle", "Button", "Dial"], "translate")*)
		;426 400 
		Gui BBE:Add, Text, x164 y103 w80 h23 +0x200, % translate("Image")
		Gui BBE:Add, Edit, x214 y103 w186 h21 VimageFilePathEdit, %imageFilePathEdit%
		Gui BBE:Add, Button, x403 y103 w23 h23 gchooseImageFilePath, % translate("...")
		
		Gui BBE:Add, Text, x164 y127 w80 h23 +0x200, % translate("Size")
		Gui BBE:Add, Edit, x214 y127 w40 h21 Limit3 Number VimageWidthEdit, %imageWidthEdit%
		Gui BBE:Add, Text, x254 y127 w21 h23 +0x200 Center, % translate("x")
		Gui BBE:Add, Edit, x275 y127 w40 h21 Limit3 Number VimageHeightEdit, %imageHeightEdit%
		
		Gui BBE:Add, Button, x226 y164 w46 h23 VcontrolAddButton gaddItem, % translate("Add")
		Gui BBE:Add, Button, x275 y164 w50 h23 Disabled VcontrolDeleteButton gdeleteItem, % translate("Delete")
		Gui BBE:Add, Button, x371 y164 w55 h23 Disabled VcontrolUpdateButton gupdateItem, % translate("Save")
		
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
		
		ButtonBoxEditor.Instance.configurationChanged(LayoutsList.Instance.CurrentButtonBox)
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
		if ButtonBoxEditor.Instance.AutoSave {
			if (this.CurrentItem != 0) {
				this.updateItem()
			}
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

global labelNameEdit = ""
global labelWidthEdit = 0
global labelHeightEdit = 0

global labelAddButton
global labelDeleteButton
global labelUpdateButton
		
class LabelsList extends ConfigurationItemList {
	__New(configuration) {
		base.__New(configuration)
				 
		LabelsList.Instance := this
	}
					
	createGui(configuration) {
		Gui BBE:Font, Norm, Arial
		Gui BBE:Font, Italic, Arial
		
		Gui BBE:Add, GroupBox, -Theme x8 y205 w424 h115, % translate("Labels")
		
		Gui BBE:Font, Norm, Arial
		Gui BBE:Add, ListView, x16 y224 w134 h84 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndlabelsListViewHandle VlabelsListView glistEvent
							 , % values2String("|", map(["Name", "Size"], "translate")*)
							
		Gui BBE:Add, Text, x164 y224 w80 h23 +0x200, % translate("Name")
		Gui BBE:Add, Edit, x214 y225 w101 h21 VlabelNameEdit, %labelNameEdit%
		
		Gui BBE:Add, Text, x164 y248 w80 h23 +0x200, % translate("Size")
		Gui BBE:Add, Edit, x214 y248 w40 h21 Limit3 Number VlabelWidthEdit, %labelWidthEdit%
		Gui BBE:Add, Text, x254 y248 w21 h23 +0x200 Center, % translate("x")
		Gui BBE:Add, Edit, x275 y248 w40 h21 Limit3 Number VlabelHeightEdit, %labelHeightEdit%
		
		Gui BBE:Add, Button, x226 y285 w46 h23 VlabelAddButton gaddItem, % translate("Add")
		Gui BBE:Add, Button, x275 y285 w50 h23 Disabled VlabelDeleteButton gdeleteItem, % translate("Delete")
		Gui BBE:Add, Button, x371 y285 w55 h23 Disabled VlabelUpdateButton gupdateItem, % translate("Save")
		
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
		
		ButtonBoxEditor.Instance.configurationChanged(LayoutsList.Instance.CurrentButtonBox)
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
		if this.AutoSave {
			if (this.CurrentItem != 0) {
				this.updateItem()
			}
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

global layoutNameEdit = ""
global layoutTypeDropDown

global layoutRowsEdit = ""
global layoutColumnsEdit = ""
global layoutRowMarginEdit = ""
global layoutColumnMarginEdit = ""
global layoutSidesMarginEdit = ""
global layoutBottomMarginEdit = ""

global layoutRowDropDown = 0
global layoutRowEdit = ""

global layoutVisibleCheck = true

global layoutAddButton
global layoutDeleteButton
global layoutUpdateButton
		
class LayoutsList extends ConfigurationItemList {
	iRowDefinitions := []
	iSelectedRow := false
	
	CurrentButtonBox[] {
		Get {
			return ((this.CurrentItem != 0) ? this.ItemList[this.CurrentItem][1] : false)
		}
	}
	
	__New(configuration) {
		base.__New(configuration)
				 
		LayoutsList.Instance := this
	}

	createGui(configuration) {
		Gui BBE:Add, ListView, x8 y330 w424 h105 -Multi -LV0x10 AltSubmit NoSort NoSortHdr HwndlayoutsListViewHandle VlayoutsListView glistEvent
							 , % values2String("|", map(["Name", "Grid", "Margins", "Definition"], "translate")*)
		
		Gui BBE:Add, Text, x8 y445 w86 h23 +0x200, % translate("Name && Type")
		Gui BBE:Add, Edit, x102 y445 w110 h21 VlayoutNameEdit, %layoutNameEdit%
		Gui BBE:Add, DropDownList, x215 y445 w110 VlayoutTypeDropDown, % values2String("|", map(["ButtonBox", "Stream Deck"], "translate")*)
		
		Gui BBE:Add, Text, x8 y469 w86 h23 +0x200, % translate("Visible")
		if layoutVisibleCheck
			Gui BBE:Add, CheckBox, x102 y469 w110 h21 Checked VlayoutVisibleCheck
		else
			Gui BBE:Add, CheckBox, x102 y469 w110 h21 VlayoutVisibleCheck
		
		Gui BBE:Add, Text, x8 y493 w86 h23 +0x200, % translate("Layout")
		Gui BBE:Font, c505050 s7
		Gui BBE:Add, Text, x16 y517 w133 h21, % translate("(R x C, Margins)")
		Gui BBE:Font
		
		Gui BBE:Add, Edit, x102 y493 w40 h21 Limit1 Number gupdateLayoutRowEditor VlayoutRowsEdit, %layoutRowsEdit%
		Gui BBE:Add, UpDown, x125 y493 w17 h21, 1
		Gui BBE:Add, Text, x147 y493 w20 h23 +0x200 Center, % translate("x")
		Gui BBE:Add, Edit, x172 y493 w40 h21 Limit1 Number gupdateLayoutRowEditor VlayoutColumnsEdit, %layoutColumnsEdit%
		Gui BBE:Add, UpDown, x195 y493 w17 h21, 1
		
		Gui BBE:Font, c505050 s7
		
		Gui BBE:Add, Text, x242 y474 w40 h23 +0x200 Center, % translate("Row")
		Gui BBE:Add, Text, x292 y474 w40 h23 +0x200 Center, % translate("Column")
		Gui BBE:Add, Text, x342 y474 w40 h23 +0x200 Center, % translate("Sides")
		Gui BBE:Add, Text, x392 y474 w40 h23 +0x200 Center, % translate("Bottom")
		
		Gui BBE:Font
		
		Gui BBE:Add, Edit, x242 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutRowMarginEdit, %layoutRowMarginEdit%
		Gui BBE:Add, Edit, x292 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutColumnMarginEdit, %layoutColumnMarginEdit%
		Gui BBE:Add, Edit, x342 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutSidesMarginEdit, %layoutSidesMarginEdit%
		Gui BBE:Add, Edit, x392 y493 w40 h21 Limit2 Number gupdateLayoutRowEditor VlayoutBottomMarginEdit, %layoutBottomMarginEdit%
		
		Gui BBE:Add, DropDownList, x8 y534 w86 AltSubmit Choose0 gupdateLayoutRowEditor VlayoutRowDropDown, |
		
		Gui BBE:Add, Edit, x102 y534 w330 h50 Disabled VlayoutRowEdit, %layoutRowEdit%
		
		Gui BBE:Add, Button, x223 y589 w46 h23 VlayoutAddButton gaddItem, % translate("Add")
		Gui BBE:Add, Button, x271 y589 w50 h23 Disabled VlayoutDeleteButton gdeleteItem, % translate("Delete")
		Gui BBE:Add, Button, x377 y589 w55 h23 Disabled VlayoutUpdateButton gupdateItem, % translate("&Save")
		
		this.initializeList(layoutsListViewHandle, "layoutsListView", "layoutAddButton", "layoutDeleteButton", "layoutUpdateButton")
		
		this.clearEditor()
	}
	
	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)
		
		layouts := {}
		
		for descriptor, definition in getConfigurationSectionValues(configuration, "Layouts", Object()) {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			name := descriptor[1]
			
			checked := true
			
			if !layouts.HasKey(name)
				layouts[name] := Object()
			
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
				checked := definition
			else
				layouts[name][descriptor[2]] := definition
		}
		
		items := []
		
		for name, definition in layouts
			items.Push(Array(name, checked, definition))
		
		this.ItemList := items
	}
		
	saveToConfiguration(configuration, save := true) {
		if save
			base.saveToConfiguration(configuration)
		
		for ignore, layout in this.ItemList {
			grid := layout[3]["Grid"]
			
			setConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(layout[1], "Layout")
								, grid . ", " . values2String(", ", layout[3]["Margins"]*))
								
			Loop % string2Values("x", grid)[1]
				setConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(layout[1], A_Index), layout[3][A_Index])
			
			setConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(layout[1], "Visible"), layout[2])
		}
	}
	
	loadList(items) {
		static first := true
		static inCall := false
		
		Gui ListView, % this.ListHandle
		
		LV_Delete()
		
		this.ItemList := items
		
		for ignore, layout in items {
			grid := layout[3]["Grid"]
		
			definition := ""
			
			Loop % string2Values("x", grid)[1]
			{
				if (A_Index > 1)
					definition .= "; "
				
				definition .= (A_Index . ": " . layout[3][A_Index])
			}
			
			LV_Add("", layout[1], grid, values2String(", ", layout[3]["Margins"]*), definition)
		}
		
		if first {
			LV_ModifyCol()
			LV_ModifyCol(1, "AutoHdr")
			LV_ModifyCol(2, "AutoHdr")
			LV_ModifyCol(3, "AutoHdr")
			LV_ModifyCol(4, "AutoHdr")
			
			first := false
		}
		
		ButtonBoxEditor.Instance.configurationChanged(LayoutsList.Instance.CurrentButtonBox)
	}
	
	loadEditor(item) {
		layoutNameEdit := item[1]
		layoutVisibleCheck := item[2]
		
		size := string2Values("x", item[3]["Grid"])
		
		layoutRowsEdit := size[1]
		layoutColumnsEdit := size[2]
		
		margins := item[3]["Margins"]
		
		layoutRowMarginEdit := margins[1]
		layoutColumnMarginEdit := margins[2]
		layoutSidesMarginEdit := margins[3]
		layoutBottomMarginEdit := margins[4]
		
		GuiControl Text, layoutNameEdit, %layoutNameEdit%
		GuiControl Text, layoutRowsEdit, %layoutRowsEdit%
		GuiControl Text, layoutColumnsEdit, %layoutColumnsEdit%
		GuiControl Text, layoutRowMarginEdit, %layoutRowMarginEdit%
		GuiControl Text, layoutColumnMarginEdit, %layoutColumnMarginEdit%
		GuiControl Text, layoutSidesMarginEdit, %layoutSidesMarginEdit%
		GuiControl Text, layoutBottomMarginEdit, %layoutBottomMarginEdit%
		
		GuiControl, , layoutVisibleCheck, %layoutVisibleCheck%
		
		choices := []
		rowDefinitions := []
		
		Loop %layoutRowsEdit% {
			choices.Push(translate("Row ") . A_Index)
		
			rowDefinitions.Push(item[3][A_Index])
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
		
		preview := ButtonBoxEditor.Instance.ButtonBoxPreview
		
		if ((this.CurrentButtonBox != layoutNameEdit) || (!preview && (layoutNameEdit != "")) || (preview && (preview.Name != layoutNameEdit)))
			ButtonBoxEditor.Instance.configurationChanged(layoutNameEdit)
	}
	
	addItem() {
		base.addItem()
		
		GuiControl Text, layoutRowEdit, %layoutRowEdit%
		
		preview := ButtonBoxEditor.Instance.ButtonBoxPreview
		
		if ((this.CurrentButtonBox != layoutNameEdit) || (!preview && (layoutNameEdit != "")) || (preview && (preview.Name != layoutNameEdit)))
			ButtonBoxEditor.Instance.configurationChanged(this.CurrentButtonBox)
	}
	
	clearEditor() {
		this.loadEditor(Array("", "", {Grid: "0x0", Margins: [0,0,0,0]}))
	}
	
	buildItemFromEditor(isNew := false) {
		GuiControlGet layoutNameEdit
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
			
			layout := {Grid: layoutRowsEdit . " x " . layoutColumnsEdit
					 , Margins: Array(layoutRowMarginEdit, layoutColumnMarginEdit, layoutSidesMarginEdit, layoutBottomMarginEdit)}
			
			Loop % this.iRowDefinitions.Length()
				layout[A_Index] := this.iRowDefinitions[A_Index]
				
			return Array(layoutNameEdit, layoutVisibleCheck, layout)
		}
	}
	
	updateLayoutRowEditor(save := true) {
		Gui BBE:Default
		
		GuiControlGet layoutRowsEdit
		GuiControlGet layoutRowDropDown
		GuiControlGet layoutRowEdit
		
		if (save && (this.iSelectedRow > 0))
			this.iRowDefinitions[this.iSelectedRow] := layoutRowEdit
			
		rows := this.iRowDefinitions.Length()
		changed := false
		
		if (layoutRowsEdit > rows) {
			Loop % layoutRowsEdit - rows
				this.iRowDefinitions.Push("")
			
			changed := true
		}
		else if (layoutRowsEdit < rows) {
			this.iRowDefinitions.RemoveAt(layoutRowsEdit + 1, rows - layoutRowsEdit)
			
			changed := true
		}
		
		Loop %layoutRowsEdit%
			this.iRowDefinitions[A_Index] := values2String(";", this.getRowDefinition(A_Index)*)
		
		if (layoutRowDropDown > 0) {
			layoutRowEdit := ((this.iRowDefinitions.Length() >= layoutRowDropDown) ? this.iRowDefinitions[layoutRowDropDown] : "")
			
			this.iSelectedRow := layoutRowDropDown
			
			GuiControl Text, layoutRowEdit, %layoutRowEdit%
		}

		if changed {
			choices := []
		
			Loop %layoutRowsEdit%
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
		
		if (save && ButtonBoxEditor.Instance.AutoSave) {
			if (this.CurrentItem != 0) {
				this.updateItem()
			}
		}
	}
	
	getRowDefinition(row) {
		rowDefinition := string2Values(";", this.iRowDefinitions[row])
		
		GuiControlGet layoutColumnsEdit
		
		if (rowDefinition.Length() > layoutColumnsEdit)
			rowDefinition.RemoveAt(layoutColumnsEdit + 1, rowDefinition.Length() - layoutColumnsEdit)
		else
			Loop % layoutColumnsEdit - rowDefinition.Length()
				rowDefinition.Push("")
		
		return rowDefinition
	}
	
	setRowDefinition(row, rowDefinition) {
		this.iRowDefinitions[row] := values2String(";", rowDefinition*)
		
		this.updateLayoutRowEditor(false)
		
		this.updateItem()
		
		ButtonBoxEditor.Instance.configurationChanged(this.CurrentButtonBox)
	}
	
	changeControl(row, column, control, number := false) {
		rowDefinition := this.getRowDefinition(row)
		
		definition := string2Values(",", rowDefinition[column])
		
		if (control = "__Number__") {
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
			else
				definition := (ConfigurationItem.descriptor(ConfigurationItem.splitDescriptor(definition[1])[1], number) . "," . definition[2])
		}
		else if control {
			if (definition.Length() = 0)
				definition := ConfigurationItem.descriptor(control, 1)
			else if (definition.Length() = 1)
				definition := ConfigurationItem.descriptor(control, ConfigurationItem.splitDescriptor(definition[1])[2])
			else
				definition := (ConfigurationItem.descriptor(control, ConfigurationItem.splitDescriptor(definition[1])[2]) . "," . definition[2])
		}
		else
			definition := ""
		
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


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

saveButtonBoxEditor() {
	protectionOn()
	
	try {
		ButtonBoxEditor.Instance.close(true)
	}
	finally {
		protectionOff()
	}
}

cancelButtonBoxEditor() {
	protectionOn()
	
	try {
		ButtonBoxEditor.Instance.close(false)
	}
	finally {
		protectionOff()
	}
}

moveButtonBoxEditor() {
	moveByMouse("BBE")
}

openButtonBoxesDocumentation() {
	Run https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts
}

chooseImageFilePath() {
	GuiControlGet imageFilePathEdit
	
	path := imageFilePathEdit

	if (path && (path != ""))
		path := getFileName(path, kButtonBoxImagesDirectory)
	else
		path := SubStr(kButtonBoxImagesDirectory, 1, StrLen(kButtonBoxImagesDirectory) - 1)
	
	title := translate("Select Image...")

	OnMessage(0x44, Func("translateMsgBoxButtons").Bind(["Select", "Cancel"]))
	FileSelectFile pictureFile, 1, , %title%, Image (*.jpg; *.png; *.gif)
	OnMessage(0x44, "")
	
	if (pictureFile != "") {
		imageFilePathEdit := pictureFile
		
		GuiControl Text, imageFilePathEdit, %imageFilePathEdit%
	}
}

updateLayoutRowEditor() {
	protectionOn()
	
	try {
		list := ConfigurationItemList.getList("layoutsListView")
		
		if list
			list.updateLayoutRowEditor()
	}
	catch exception {
		; ignore
	}
	finally {
		protectionOff()
	}
}

moveButtonBoxPreview() {
	window := ButtonBoxPreview.CurrentWindow
	
	moveByMouse(window)
	
	WinGetPos x, y, width, height, A
	
	vButtonBoxPreviews[A_Gui].PreviewManager.setPreviewCenter(x + Round(width / 2), y + Round(height / 2))
}