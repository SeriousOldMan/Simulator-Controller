;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Controller Editor               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\..\Libraries\Task.ahk"
#Include "ConfigurationItemList.ahk"
#Include "ButtonBoxPreview.ahk"
#Include "StreamDeckPreview.ahk"
#Include "ControllerActionsEditor.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kControlTypes := CaseInsenseMap(k1WayToggleType, "1-way Toggle", k2WayToggleType, "2-way Toggle", kButtonType, "Button", kDialType, "Rotary", kCustomType, "Custom")


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerEditor                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerEditor extends ConfiguratorPanel {
	static sPreviewCenters := CaseInsenseMap()

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

	class ControllerWindow extends Window {
		iEditor := false

		__New(editor) {
			this.iEditor := editor

			super.__New({Descriptor: "Controller Editor", Closeable: true, Resizeable: true, Options: "-MaximizeBox"})
		}

		Close(*) {
			this.iEditor.close(false)
		}
	}

	ControllerPreview {
		Get {
			return this.iControllerPreview
		}
	}

	Name {
		Get {
			return this.iName
		}
	}

	ButtonBoxConfiguration {
		Get {
			return this.iButtonBoxConfiguration
		}
	}

	ButtonBoxConfigurationFile {
		Get {
			return this.iButtonBoxConfigurationFile
		}
	}

	StreamDeckConfiguration {
		Get {
			return this.iStreamDeckConfiguration
		}
	}

	StreamDeckConfigurationFile {
		Get {
			return this.iStreamDeckConfigurationFile
		}
	}

	ControlsList {
		Get {
			return this.iControlsList
		}
	}

	LabelsList {
		Get {
			return this.iLabelsList
		}
	}

	LayoutsList {
		Get {
			return this.iLayoutsList
		}
	}

	AutoSave {
		Get {
			if (isSet(ConfigurationEditor) && ConfigurationEditor.hasProp("Instance"))
				return ConfigurationEditor.Instance.AutoSave
			else
				return false
		}
	}

	__New(name, configuration, buttonBoxConfigurationFile := false, streamDeckConfigurationFile := false) {
		this.iName := name

		if !buttonBoxConfigurationFile
			buttonBoxConfigurationFile := getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory)

		if !streamDeckConfigurationFile
			streamDeckConfigurationFile := getFileName("Stream Deck Configuration.ini", kUserConfigDirectory, kConfigDirectory)

		this.iButtonBoxConfigurationFile := buttonBoxConfigurationFile
		this.iStreamDeckConfigurationFile := streamDeckConfigurationFile

		this.iButtonBoxConfiguration := readMultiMap(buttonBoxConfigurationFile)
		this.iStreamDeckConfiguration := readMultiMap(streamDeckConfigurationFile)

		this.iControlsList := ControlsList(this, this.iButtonBoxConfiguration)
		this.iLabelsList := LabelsList(this, this.iButtonBoxConfiguration)
		this.iLayoutsList := LayoutsList(this, this.iButtonBoxConfiguration, this.iStreamDeckConfiguration)

		super.__New(configuration)

		ControllerEditor.Instance := this
	}

	createGui(buttonBoxConfiguration, streamDeckConfiguration, saveAndCancel) {
		static controllerGui

		saveControllerEditor(*) {
			this.close(true)
		}

		cancelControllerEditor(*) {
			this.close(false)
		}

		openControllerActionsEditor(*) {
			this.openControllerActionsEditor()
		}

		controllerGui := ControllerEditor.ControllerWindow(this)

		this.Window := controllerGui

		controllerGui.SetFont("Bold", "Arial")

		controllerGui.Add("Text", "x0 w432 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(controllerGui, "Controller Editor"))

		controllerGui.SetFont("Norm", "Arial")

		controllerGui.Add("Documentation", "x160 YP+20 w112 H:Center Center", translate("Controller Layouts")
						, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#controller-layouts")

		this.ControlsList.createGui(this, buttonBoxConfiguration)
		this.LabelsList.createGui(this, buttonBoxConfiguration)
		this.LayoutsList.createGui(this, buttonBoxConfiguration, streamDeckConfiguration)

		if saveAndCancel {
			controllerGui.Add("Text", "x8 y620 w424 0x10 Y:Move W:Grow")

			controllerGui.Add("Button", "x8 yp+10 w140 h23 Y:Move", translate("Edit Labels && Icons...")).OnEvent("Click", openControllerActionsEditor)

			controllerGui.Add("Button", "x260 yp w80 h23 Y:Move X:Move Default", translate("Save")).OnEvent("Click", saveControllerEditor)
			controllerGui.Add("Button", "x352 yp w80 h23 Y:Move X:Move", translate("Cancel")).OnEvent("Click", cancelControllerEditor)
		}
	}

	saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, save := true) {
		if save
			super.saveToConfiguration(buttonBoxConfiguration)

		this.ControlsList.saveToConfiguration(buttonBoxConfiguration, save)
		this.LabelsList.saveToConfiguration(buttonBoxConfiguration, save)
		this.LayoutsList.saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, save)
	}

	setPreviewCenter(window, centerX, centerY) {
		if window
			ControllerEditor.sPreviewCenters[window] := [centerX, centerY]

		this.iPreviewCenterX := centerX
		this.iPreviewCenterY := centerY
	}

	getPreviewCenter(window, &centerX, &centerY) {
		local center

		if (window && ControllerEditor.sPreviewCenters.Has(window)) {
			center := ControllerEditor.sPreviewCenters[window]

			centerX := center[1]
			centerY := center[2]
		}
		else {
			centerX := this.iPreviewCenterX
			centerY := this.iPreviewCenterY
		}
	}

	getPreviewMover() {
		moveControllerPreview(window) {
			local preview, x, y, width, height

			moveByMouse(window)

			WinGetPos(&x, &y, &width, &height, window)

			x := screen2Window(x)
			y := screen2Window(y)

			preview := ControllerPreview.ControllerPreviews[window]

			preview.PreviewManager.setPreviewCenter(window, x + Round(width / 2), y + Round(height / 2))
		}

		return moveControllerPreview
	}

	selectLayout(name) {
		local index, item

		for index, item in this.LayoutsList.ItemList
			if (item[1] = name) {
				this.LayoutsList.openEditor(index)
				this.LayoutsList.selectItem(index)

				break
			}
	}

	show(x := kUndefined, y := kUndefined) {
		local window := this.Window
		local name, w, h

		if ((x = kUndefined) || (y = kUndefined)) {
			if getWindowPosition("Controller Editor", &x, &y)
				window.Show("x" . x . " y" . y)
			else
				window.Show()
		}
		else
			window.Show("AutoSize x" . x . " y" . y)

		window.MaxHeight := window.MinHeight

		if getWindowSize("Controller Editor", &w, &h)
			window.Resize("Initialize", w, h)

		if this.Name
			this.selectLayout(this.Name)
			; Task.startTask(ObjBindMethod(this, "selectLayout", this.Name), 1000)
	}

	close(save := true) {
		local buttonBoxConfiguration, streamDeckConfiguration

		if save {
			buttonBoxConfiguration := newMultiMap()
			streamDeckConfiguration := newMultiMap()

			this.saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration)

			writeMultiMap(this.ButtonBoxConfigurationFile, buttonBoxConfiguration)
			writeMultiMap(this.StreamDeckConfigurationFile, streamDeckConfiguration)
		}

		if this.ControllerPreview {
			this.ControllerPreview.close()

			this.iControllerPreview := false
		}

		this.Window.Hide()

		this.iClosed := true
	}

	editController(saveAndCancel := true, owner := false) {
		local window

		this.createGui(this.iButtonBoxConfiguration, this.iStreamDeckConfiguration, saveAndCancel)

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		try {
			this.show()

			loop
				Sleep(200)
			until this.iClosed
		}
		finally {
			window.Destroy()
		}
	}

	openControllerActionsEditor() {
		local window := this.Window

		window.Block()

		try {
			ControllerActionsEditor(kSimulatorConfiguration).editPluginActions(false, window)
		}
		finally {
			window.Unblock()
		}
	}

	changeControl(row, column, control, argument := false) {
		this.LayoutsList.changeControl(row, column, control, argument)
	}

	changeLabel(row, column, label) {
		this.LayoutsList.changeLabel(row, column, label)
	}

	configurationChanged(type, name) {
		this.updateControllerPreview(type, name)
	}

	updateControllerPreview(type, name) {
		local buttonBoxConfiguration := newMultiMap()
		local streamDeckConfiguration := newMultiMap()
		local oldPreview

		this.saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, false)

		this.iButtonBoxConfiguration := buttonBoxConfiguration
		this.iStreamDeckConfiguration := streamDeckConfiguration

		oldPreview := this.ControllerPreview

		if name {
			if (type = "Button Box")
				this.iControllerPreview := ButtonBoxPreview(this, name, buttonBoxConfiguration)
			else
				this.iControllerPreview := StreamDeckPreview(this, name, streamDeckConfiguration)

			this.ControllerPreview.show()
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

class ControlsList extends ConfigurationItemList {
	AutoSave {
		Get {
			return this.Editor.AutoSave
		}
	}

	__New(editor, configuration) {
		this.Editor := editor

		super.__New(configuration)

		ControlsList.Instance := this
	}

	createGui(editor, configuration) {
		local window := editor.Window

		chooseImageFilePath(*) {
			local path, pictureFile

			path := window["imageFilePathEdit"].Text

			if (path && (path != ""))
				path := getFileName(path, kButtonBoxImagesDirectory)
			else
				path := SubStr(kButtonBoxImagesDirectory, 1, StrLen(kButtonBoxImagesDirectory) - 1)

			pictureFile := chooseImageFile(window, path)

			if pictureFile
				window["imageFilePathEdit"].Text := pictureFile
		}

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		window.Add("GroupBox", "x8 y60 w424 h138 W:Grow", translate("Controls"))

		window.SetFont("Norm", "Arial")

		window.Add("ListView", "x16 y79 w134 h108 W:Grow(0.2) -Multi -LV0x10 AltSubmit NoSort NoSortHdr VcontrolsListView", collect(["Name", "Function", "Size"], translate))

		window.Add("Text", "x164 y79 w80 h23 X:Move(0.2) +0x200", translate("Name"))
		window.Add("Edit", "x214 y80 w101 h21 X:Move(0.2) W:Grow(0.3) VcontrolNameEdit")
		window.Add("DropDownList", "x321 y79 w105 X:Move(0.5) W:Grow(0.5) Choose1 VcontrolTypeDropDown", collect(["1-way Toggle", "2-way Toggle", "Button", "Dial"], translate))

		window.Add("Text", "x164 y103 w80 h23 X:Move(0.2) +0x200", translate("Image"))
		window.Add("Edit", "x214 y103 w186 h21 X:Move(0.2) W:Grow(0.8) VimageFilePathEdit")
		window.Add("Button", "x403 y103 w23 h23 X:Move ", translate("...")).OnEvent("Click", chooseImageFilePath)

		window.Add("Text", "x164 y127 w80 h23 X:Move(0.2) +0x200", translate("Size"))
		window.Add("Edit", "x214 y127 w40 h21 X:Move(0.2) Limit3 Number VimageWidthEdit")
		window.Add("Text", "x255 y127 w23 h23 X:Move(0.2) +0x200 Center", translate("x"))
		window.Add("Edit", "x279 y127 w40 h21 X:Move(0.2) Limit3 Number VimageHeightEdit")

		window.Add("Button", "x226 y164 w46 h23 X:Move VcontrolAddButton", translate("Add"))
		window.Add("Button", "x275 y164 w50 h23 X:Move Disabled VcontrolDeleteButton", translate("Delete"))
		window.Add("Button", "x371 y164 w55 h23 X:Move Disabled VcontrolUpdateButton", translate("Save"))

		this.initializeList(editor, window["controlsListView"], window["controlAddButton"], window["controlDeleteButton"], window["controlUpdateButton"])

		this.clearEditor()
	}

	loadFromConfiguration(configuration) {
		local controls := []
		local name, definition

		super.loadFromConfiguration(configuration)

		for name, definition in getMultiMapValues(configuration, "Controls")
			controls.Push(Array(name, string2Values(";", definition)*))

		this.ItemList := controls
	}

	saveToConfiguration(configuration, save := true) {
		local controls := newSectionMap()
		local ignore, control

		if save
			super.saveToConfiguration(configuration, true)

		for ignore, control in this.ItemList
			controls[control[1]] := values2String(";", control[2], control[3], control[4])

		setMultiMapValues(configuration, "Controls", controls)
	}

	loadList(items) {
		local ignore, control

		static first := true

		this.Control["controlsListView"].Delete()

		this.ItemList := items

		for ignore, control in items
			this.Control["controlsListView"].Add("", control[1], translate(kControlTypes[control[2]]), control[4])

		if first {
			this.Control["controlsListView"].ModifyCol()
			this.Control["controlsListView"].ModifyCol(1, "AutoHdr")
			this.Control["controlsListView"].ModifyCol(2, "AutoHdr")
			this.Control["controlsListView"].ModifyCol(3, "AutoHdr")

			first := false
		}

		this.Editor.configurationChanged(this.Editor.LayoutsList.CurrentControllerType, this.Editor.LayoutsList.CurrentController)
	}

	loadEditor(item) {
		local size := string2Values("x", item[4])

		this.Control["controlNameEdit"].Text := item[1]
		this.Control["imageFilePathEdit"].Text := item[3]

		this.Control["imageWidthEdit"].Text := size[1]
		this.Control["imageHeightEdit"].Text := size[2]

		this.Control["controlTypeDropDown"].Choose(inList([k1WayToggleType, k2WayToggleType, kButtonType, kDialType], item[2]))
	}

	clearEditor() {
		this.loadEditor(Array("", k1WayToggleType, "", "45x45"))
	}

	buildItemFromEditor(isNew := false) {
		if ((Trim(this.Control["controlNameEdit"].Text) = "") || !inList([1, 2, 3, 4], this.Control["controlTypeDropDown"].Value)
		 || (Trim(this.Control["imageFilePathEdit"].Text) = "")  || (this.Control["imageWidthEdit"].Text = 0) || (this.Control["imageHeightEdit"].Text = 0)) {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}
		else
			return Array(this.Control["controlNameEdit"].Text, [k1WayToggleType, k2WayToggleType, kButtonType, kDialType][this.Control["controlTypeDropDown"].Value]
					   , this.Control["imageFilePathEdit"].Text, this.Control["imageWidthEdit"].Text . " x " . this.Control["imageHeightEdit"].Text)
	}

	getControls() {
		local controls := CaseInsenseMap()
		local ignore, control

		if this.AutoSave {
			if (this.CurrentItem != 0)
				this.updateItem()
		}

		for ignore, control in this.ItemList
			controls[control[1]] := values2String(";", control[2], control[3], control[4])

		return controls
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LabelsList                                                              ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class LabelsList extends ConfigurationItemList {
	AutoSave {
		Get {
			return this.Editor.AutoSave
		}
	}

	__New(editor, configuration) {
		this.Editor := editor

		super.__New(configuration)

		LabelsList.Instance := this
	}

	createGui(editor, configuration) {
		local window := editor.Window

		window.SetFont("Norm", "Arial")
		window.SetFont("Italic", "Arial")

		window.Add("GroupBox", "x8 y205 w424 h115 W:Grow", translate("Labels"))

		window.SetFont("Norm", "Arial")

		window.Add("ListView", "x16 y224 w134 h84 W:Grow(0.2) -Multi -LV0x10 AltSubmit NoSort NoSortHdr VlabelsListView", collect(["Name", "Size"], translate))

		window.Add("Text", "x164 y224 w80 h23 X:Move(0.2) +0x200", translate("Name"))
		window.Add("Edit", "x214 y225 w101 h21 X:Move(0.2) W:Grow(0.3) VlabelNameEdit")

		window.Add("Text", "x164 y248 w80 h23 X:Move(0.2) +0x200", translate("Size"))
		window.Add("Edit", "x214 y248 w40 h21 X:Move(0.2) Limit3 Number VlabelWidthEdit")
		window.Add("Text", "x255 y248 w23 h23 X:Move(0.2) +0x200 Center", translate("x"))
		window.Add("Edit", "x279 y248 w40 h21 X:Move(0.2) Limit3 Number VlabelHeightEdit")

		window.Add("Button", "x226 y285 w46 h23 X:Move VlabelAddButton", translate("Add"))
		window.Add("Button", "x275 y285 w50 h23 X:Move Disabled VlabelDeleteButton", translate("Delete"))
		window.Add("Button", "x371 y285 w55 h23 X:Move Disabled VlabelUpdateButton", translate("Save"))

		this.initializeList(editor, window["labelsListView"], window["labelAddButton"], window["labelDeleteButton"], window["labelUpdateButton"])

		this.clearEditor()
	}

	loadFromConfiguration(configuration) {
		local labels := []
		local name, definition

		super.loadFromConfiguration(configuration)

		for name, definition in getMultiMapValues(configuration, "Labels")
			labels.Push(Array(name, definition))

		this.ItemList := labels
	}

	saveToConfiguration(configuration, save := true) {
		local labels := newSectionMap()
		local ignore, label

		if save
			super.saveToConfiguration(configuration)

		for ignore, label in this.ItemList
			labels[label[1]] := label[2]

		setMultiMapValues(configuration, "Labels", labels)
	}

	loadList(items) {
		local ignore, label

		static first := true

		this.Control["labelsListView"].Delete()

		this.ItemList := items

		for ignore, label in items
			this.Control["labelsListView"].Add("", label[1], label[2])

		if first {
			this.Control["labelsListView"].ModifyCol()
			this.Control["labelsListView"].ModifyCol(1, "AutoHdr")
			this.Control["labelsListView"].ModifyCol(2, "AutoHdr")

			first := false
		}

		this.Editor.configurationChanged(this.Editor.LayoutsList.CurrentControllerType, this.Editor.LayoutsList.CurrentController)
	}

	loadEditor(item) {
		local size := string2Values("x", item[2])

		this.Control["labelNameEdit"].Text := item[1]
		this.Control["labelWidthEdit"].Text := size[1]
		this.Control["labelHeightEdit"].Text := size[2]
	}

	clearEditor() {
		this.loadEditor(Array("", "50x30"))
	}

	buildItemFromEditor(isNew := false) {
		if ((Trim(this.Control["labelNameEdit"].Text) = "") || (this.Control["labelWidthEdit"].Text = 0) || (this.Control["labelHeightEdit"].Text = 0)) {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}
		else
			return Array(this.Control["labelNameEdit"].Text, this.Control["labelWidthEdit"].Text . " x " . this.Control["labelHeightEdit"].Text)
	}

	getLabels() {
		local labels := CaseInsenseMap()
		local ignore, label

		if this.AutoSave {
			if (this.CurrentItem != 0)
				this.updateItem()
		}

		for ignore, label in this.ItemList
			labels[label[1]] := label[2]

		return labels
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; LayoutsList                                                             ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class LayoutsList extends ConfigurationItemList {
	iRowDefinitions := WeakArray()
	iSelectedRow := false

	iStreamDeckConfiguration := false
	iButtonDefinitions := false
	iIconDefinitions := false

	iButtonBoxWidgets := []
	iStreamDeckWidgets := []

	AutoSave {
		Get {
			return this.Editor.AutoSave
		}
	}

	ButtonBoxConfiguration {
		Get {
			return this.Configuration
		}
	}

	StreamDeckConfiguration {
		Get {
			return this.iStreamDeckConfiguration
		}
	}

	CurrentControllerType {
		Get {
			return ((this.CurrentItem != 0) ? this.ItemList[this.CurrentItem][2]["Type"] : "Button Box")
		}
	}

	CurrentController {
		Get {
			return ((this.CurrentItem != 0) ? this.ItemList[this.CurrentItem][1] : false)
		}
	}

	__New(editor, buttonBoxConfiguration, streamDeckConfiguration) {
		this.Editor := editor

		this.iStreamDeckConfiguration := streamDeckConfiguration

		super.__New(buttonBoxConfiguration)

		LayoutsList.Instance := this
	}

	createGui(editor, buttonBoxConfiguration, streamDeckConfiguration) {
		local window := editor.Window

		chooseLayoutType(*) {
			this.chooseLayoutType()
		}

		chooseLayout(*) {
			this.chooseLayout()
		}

		updateLayoutRowEditor(*) {
			this.updateLayoutRowEditor()
		}

		openDisplayRulesEditor(*) {
			this.openDisplayRulesEditor()
		}

		window.Add("ListView", "x8 y330 w424 h105 W:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr VlayoutsListView", collect(["Name", "Grid", "Margins", "Definition"], translate))

		window.Add("Text", "x8 y445 w86 h23 +0x200", translate("Name && Type"))
		window.Add("Edit", "x102 y445 w110 h21 W:Grow(0.2) VlayoutNameEdit")
		window.Add("DropDownList", "x215 y445 w117 X:Move(0.2) W:Grow(0.2) Choose1 VlayoutTypeDropDown", collect(["Button Box", "Stream Deck"], translate)).OnEvent("Change", chooseLayoutType)

		bbWidget1 := window.Add("Text", "x8 y469 w86 h23 +0x200 Section", translate("Visible"))
		bbWidget2 := window.Add("CheckBox", "x102 y469 w110 h21 Checked VlayoutVisibleCheck")

		bbWidget3 := window.Add("Text", "x8 y493 w86 h23 +0x200", translate("Layout"))

		bbWidget4 := window.Add("Text", "x16 y516 w133 h20 c" . window.Theme.TextColor["Disabled"], translate("(R x C, Margins)"))

		window.SetFont()

		bbWidget5 := window.Add("Edit", "x102 y493 w40 h21 Limit1 Number Limit2 VlayoutRowsEdit", 0)
		bbWidget5.OnEvent("Change", updateLayoutRowEditor)
		bbWidget6 := window.Add("UpDown", "x125 y493 w17 h21 Range1-99", 0)

		bbWidget7 := window.Add("Text", "x143 y493 w23 h23 +0x200 Center", translate("x"))

		bbWidget8 := window.Add("Edit", "x168 y493 w40 h21 Limit1 Number Limit2  VlayoutColumnsEdit", 0)
		bbWidget8.OnEvent("Change", updateLayoutRowEditor)
		bbWidget9 := window.Add("UpDown", "x195 y493 w17 h21 Range1-99", 0)

		window.SetFont("s7")

		bbWidget10 := window.Add("Text", "x215 y474 w40 h23 X:Move(0.2) +0x200 Center c" . window.Theme.TextColor["Disabled"], translate("Row"))
		bbWidget11 := window.Add("Text", "x265 y474 w40 h23 X:Move(0.2) +0x200 Center c" . window.Theme.TextColor["Disabled"], translate("Column"))
		bbWidget12 := window.Add("Text", "x315 y474 w40 h23 X:Move(0.2) +0x200 Center c" . window.Theme.TextColor["Disabled"], translate("Sides"))
		bbWidget13 := window.Add("Text", "x365 y474 w40 h23 X:Move(0.2) +0x200 Center c" . window.Theme.TextColor["Disabled"], translate("Bottom"))

		window.SetFont()

		bbWidget14 := window.Add("Edit", "x215 y493 w40 h21 X:Move(0.2) Limit2 Number  VlayoutRowMarginEdit")
		bbWidget14.OnEvent("Change", updateLayoutRowEditor)
		bbWidget15 := window.Add("Edit", "x265 y493 w40 h21 X:Move(0.2) Limit2 Number  VlayoutColumnMarginEdit")
		bbWidget15.OnEvent("Change", updateLayoutRowEditor)
		bbWidget16 := window.Add("Edit", "x315 y493 w40 h21 X:Move(0.2) Limit2 Number  VlayoutSidesMarginEdit")
		bbWidget16.OnEvent("Change", updateLayoutRowEditor)
		bbWidget17 := window.Add("Edit", "x365 y493 w40 h21 X:Move(0.2) Limit2 Number  VlayoutBottomMarginEdit")
		bbWidget17.OnEvent("Change", updateLayoutRowEditor)

		window.Add("DropDownList", "x8 y534 w86 Choose0 VlayoutRowDropDown", ["", ""]).OnEvent("Change", updateLayoutRowEditor)

		window.Add("Edit", "x102 y534 w330 h50 W:Grow Disabled VlayoutRowEdit")

		loop 17
			this.iButtonBoxWidgets.Push(bbWidget%A_Index%)

		sdWidget1 := window.Add("Text", "x8 ys w86 h23 +0x200", translate("Layout"))
		sdWidget2 := window.Add("DropDownList", "x102 yp w110 W:Grow(0.2) Choose2 VlayoutDropDown", collect(["Mini", "Standard", "XL", "Plus"], translate))
		sdWidget2.OnEvent("Change", chooseLayout)

		sdWidget3 := window.Add("Button", "x102 yp+30 w230 h23 W:Grow(0.4) Center", translate("Edit Display Rules..."))
		sdWidget3.OnEvent("Click", openDisplayRulesEditor)

		loop 3
			this.iStreamDeckWidgets.Push(sdWidget%A_Index%)

		window.Add("Button", "x223 y589 w46 h23 X:Move VlayoutAddButton", translate("Add"))
		window.Add("Button", "x271 y589 w50 h23 X:Move Disabled VlayoutDeleteButton", translate("Delete"))
		window.Add("Button", "x377 y589 w55 h23 X:Move Disabled VlayoutUpdateButton", translate("&Save"))

		this.initializeList(editor, window["layoutsListView"], window["layoutAddButton"], window["layoutDeleteButton"], window["layoutUpdateButton"])

		this.clearEditor()
	}

	loadFromConfiguration(configuration) {
		local layouts := CaseInsenseMap()
		local descriptor, definition, name, rowMargin, columnMargin, sidesMargin, bottomMargin, items

		super.loadFromConfiguration(configuration)

		for descriptor, definition in getMultiMapValues(this.ButtonBoxConfiguration, "Layouts") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			name := descriptor[1]

			if !layouts.Has(name) {
				layouts[name] := CaseInsenseWeakMap()
				layouts[name].Default := ""
			}

			layouts[name]["Type"] := "Button Box"
			layouts[name]["Visible"] := true

			if (descriptor[2] = "Layout") {
				definition := string2Values(",", definition)

				rowMargin := ((definition.Length > 1) ? definition[2] : ButtonBoxPreview.kRowMargin)
				columnMargin := ((definition.Length > 2) ? definition[3] : ButtonBoxPreview.kColumnMargin)
				sidesMargin := ((definition.Length > 3) ? definition[4] : ButtonBoxPreview.kSidesMargin)
				bottomMargin := ((definition.Length > 4) ? definition[5] : ButtonBoxPreview.kBottomMargin)

				layouts[name]["Grid"] := definition[1]
				layouts[name]["Margins"] := Array(rowMargin, columnMargin, sidesMargin, bottomMargin)
			}
			else if (descriptor[2] = "Visible")
				layouts[name]["Visible"] := definition
			else
				layouts[name][descriptor[2]] := definition
		}

		for descriptor, definition in getMultiMapValues(this.StreamDeckConfiguration, "Layouts") {
			descriptor := ConfigurationItem.splitDescriptor(descriptor)
			name := descriptor[1]

			if !layouts.Has(name) {
				layouts[name] := CaseInsenseWeakMap()
				layouts[name].Default := ""
			}

			layouts[name]["Type"] := "Stream Deck"
			layouts[name]["Visible"] := false

			if (descriptor[2] = "Layout")
				layouts[name]["Grid"] := definition
			else
				layouts[name][descriptor[2]] := definition
		}

		this.iButtonDefinitions := getMultiMapValues(this.StreamDeckConfiguration, "Buttons")
		this.iIconDefinitions := getMultiMapValues(this.StreamDeckConfiguration, "Icons")

		items := []

		for name, definition in layouts
			items.Push(Array(name, definition))

		this.ItemList := items
	}

	saveToConfiguration(buttonBoxConfiguration, streamDeckConfiguration, save := true) {
		local ignore, layout, grid

		if save
			super.saveToConfiguration(buttonBoxConfiguration)

		for ignore, layout in this.ItemList {
			if (layout[2]["Type"] = "Button Box") {
				grid := layout[2]["Grid"]

				setMultiMapValue(buttonBoxConfiguration, "Layouts", ConfigurationItem.descriptor(layout[1], "Layout")
							   , grid . ", " . values2String(", ", layout[2]["Margins"]*))

				loop string2Values("x", grid)[1]
					setMultiMapValue(buttonBoxConfiguration, "Layouts"
								   , ConfigurationItem.descriptor(layout[1], A_Index), layout[2][A_Index])

				setMultiMapValue(buttonBoxConfiguration, "Layouts"
							   , ConfigurationItem.descriptor(layout[1], "Visible"), layout[2]["Visible"])
			}
			else {
				grid := layout[2]["Grid"]

				setMultiMapValue(streamDeckConfiguration, "Layouts", ConfigurationItem.descriptor(layout[1], "Layout"), grid)

				loop string2Values("x", grid)[1]
					setMultiMapValue(streamDeckConfiguration, "Layouts"
								   , ConfigurationItem.descriptor(layout[1], A_Index), layout[2][A_Index])

				setMultiMapValues(streamDeckConfiguration, "Buttons", this.iButtonDefinitions)
				setMultiMapValues(streamDeckConfiguration, "Icons", this.iIconDefinitions)
			}
		}
	}

	loadList(items) {
		local ignore, layout, grid, definition

		static first := true
		static inCall := false

		this.Control["layoutsListView"].Delete()

		this.ItemList := items

		for ignore, layout in items {
			grid := layout[2]["Grid"]

			definition := ""

			loop string2Values("x", grid)[1] {
				if (A_Index > 1)
					definition .= "; "

				definition .= (A_Index . ": " . layout[2][A_Index])
			}


			this.Control["layoutsListView"].Add("", layout[1], grid, (layout[2]["Type"] = "Button Box") ? values2String(", ", layout[2]["Margins"]*) : "", definition)
		}

		if first {
			this.Control["layoutsListView"].ModifyCol()
			this.Control["layoutsListView"].ModifyCol(1, "AutoHdr")
			this.Control["layoutsListView"].ModifyCol(2, "AutoHdr")
			this.Control["layoutsListView"].ModifyCol(3, "AutoHdr")
			this.Control["layoutsListView"].ModifyCol(4, "AutoHdr")

			first := false
		}

		this.Editor.configurationChanged(this.Editor.LayoutsList.CurrentControllerType, this.Editor.LayoutsList.CurrentController)
	}

	loadEditor(item) {
		local size := string2Values("x", item[2]["Grid"])
		local layoutType := item[2]["Type"]
		local object, ignore, widget, margins, choices, rows, preview

		this.Control["layoutNameEdit"].Text := item[1]
		this.Control["layoutVisibleCheck"].Value := item[2]["Visible"]

		this.Control["layoutRowsEdit"].Text := size[1]
		this.Control["layoutColumnsEdit"].Text := size[2]

		if (item[2]["Type"] = "Button Box") {
			for ignore, widget in this.iButtonBoxWidgets
				widget.Visible := true

			for ignore, widget in this.iStreamDeckWidgets
				widget.Visible := false

			margins := item[2]["Margins"]

			this.Control["layoutRowMarginEdit"].Text := margins[1]
			this.Control["layoutColumnMarginEdit"].Text := margins[2]
			this.Control["layoutSidesMarginEdit"].Text := margins[3]
			this.Control["layoutBottomMarginEdit"].Text := margins[4]
		}
		else {
			for ignore, widget in this.iButtonBoxWidgets
				widget.Visible := false

			for ignore, widget in this.iStreamDeckWidgets
				widget.Visible := true

			this.Control["layoutRowMarginEdit"].Text := ""
			this.Control["layoutColumnMarginEdit"].Text := ""
			this.Control["layoutSidesMarginEdit"].Text := ""
			this.Control["layoutBottomMarginEdit"].Text := ""

			if ((size[1] = 2) && (size[1] = 3))
				this.Control["layoutDropDown"].Choose(1)
			else if (size[1] = 3)
				this.Control["layoutDropDown"].Choose(2)
			else if (size[1] = 4)
				this.Control["layoutDropDown"].Choose(3)
			else
				this.Control["layoutDropDown"].Choose(4)
		}

		this.Control["layoutTypeDropDown"].Choose(inList(["Button Box", "Stream Deck"], layoutType))

		if (item[2]["Type"] = "Button Box") {
			this.Control["layoutRowMarginEdit"].Enabled := true
			this.Control["layoutColumnMarginEdit"].Enabled := true
			this.Control["layoutSidesMarginEdit"].Enabled := true
			this.Control["layoutBottomMarginEdit"].Enabled := true

			this.Control["layoutVisibleCheck"].Enabled := true
		}
		else {
			this.Control["layoutRowMarginEdit"].Enabled := false
			this.Control["layoutColumnMarginEdit"].Enabled := false
			this.Control["layoutSidesMarginEdit"].Enabled := false
			this.Control["layoutBottomMarginEdit"].Enabled := false

			this.Control["layoutVisibleCheck"].Enabled := false
		}

		choices := []
		rows := WeakArray()

		loop
			if item[2].Has(A_Index) {
				choices.Push(translate("Row ") . A_Index)

				definition := item[2]

				rows.Push(definition[A_Index])
			}
			else
				break

		this.Control["layoutRowEdit"].Text := ((rows.Length > 0) ? rows[1] : "")

		this.iRowDefinitions := rows

		this.Control["layoutRowDropDown"].Delete()
		this.Control["layoutRowDropDown"].Add(choices)

		if (choices.Length > 0) {
			this.Control["layoutRowDropDown"].Choose(1)

			this.iSelectedRow := 1
		}
		else {
			this.Control["layoutRowDropDown"].Choose(0)

			this.iSelectedRow := false
		}

		this.updateLayoutRowEditor(false)

		preview := this.Editor.ControllerPreview

		if ((this.CurrentController != this.Control["layoutNameEdit"].Text) || (!preview && (Trim(this.Control["layoutNameEdit"].Text) != ""))
																			|| (preview && (preview.Name != this.Control["layoutNameEdit"].Text)))
			if this.CurrentItem
				this.Editor.configurationChanged(item[2]["Type"], this.Control["layoutNameEdit"].Text)
	}

	addItem() {
		local type, preview

		super.addItem()

		if this.CurrentItem {
			type := this.ItemList[this.CurrentItem][2]["Type"]
			preview := this.Editor.ControllerPreview

			if ((this.CurrentController != this.Control["layoutNameEdit"].Text) || (!preview && (Trim(this.Control["layoutNameEdit"].Text) != ""))
																				|| (preview && (preview.Name != this.Control["layoutNameEdit"].Text)))
				this.Editor.configurationChanged(type, this.CurrentController)
		}
	}

	clearEditor() {
		local margins := [ButtonBoxPreview.kRowMargin, ButtonBoxPreview.kColumnMargin, ButtonBoxPreview.kSidesMargin, ButtonBoxPreview.kBottomMargin]

		this.loadEditor(Array("", CaseInsenseMap("Type", "Button Box", "Visible", true, "Grid", "1x1", "Margins", margins)))
	}

	buildItemFromEditor(isNew := false) {
		local name := Trim(this.Control["layoutNameEdit"].Text)
		local ignore, index, layout, duplicate

		if ((name = "") || (this.Control["layoutRowsEdit"].Text = 0) || (this.Control["layoutColumnsEdit"].Text = 0)) {
			OnMessage(0x44, translateOkButton)
			MsgBox(translate("Invalid values detected - please correct..."), translate("Error"), 262160)
			OnMessage(0x44, translateOkButton, 0)

			return false
		}
		else {
			duplicate := false

			if isNew {
				for ignore, layout in this.ItemList
					if (layout[1] = name)
						duplicate := true
			}
			else
				for index, layout in this.ItemList
					if ((layout[1] = name) && (index != this.CurrentItem))
						duplicate := true

			if duplicate {
				OnMessage(0x44, translateOkButton)
				MsgBox(translate("Invalid values detected - please correct..."), translate("Error"), 262160)
				OnMessage(0x44, translateOkButton, 0)

				return false
			}

			if (this.Control["layoutRowDropDown"].Value > 0)
				this.iRowDefinitions[this.Control["layoutRowDropDown"].Value] := this.Control["layoutRowEdit"].Text

			if (["Button Box", "Stream Deck"][this.Control["layoutTypeDropDown"].Value] = "Button Box")
				layout := CaseInsenseWeakMap("Type", "Button Box", "Grid", this.Control["layoutRowsEdit"].Text . " x " . this.Control["layoutColumnsEdit"].Text
										   , "Visible", this.Control["layoutVisibleCheck"].Value
										   , "Margins", Array(this.Control["layoutRowMarginEdit"].Text, this.Control["layoutColumnMarginEdit"].Text
															, this.Control["layoutSidesMarginEdit"].Text, this.Control["layoutBottomMarginEdit"].Text))
			else
				layout := CaseInsenseWeakMap("Type", "Stream Deck", "Grid", this.Control["layoutRowsEdit"].Text . " x " . this.Control["layoutColumnsEdit"].Text, "Visible", false)

			loop this.iRowDefinitions.Length
				layout[A_Index] := this.iRowDefinitions[A_Index]

			return Array(this.Control["layoutNameEdit"].Text, layout)
		}
	}

	chooseLayoutType() {
		local grid, margins

		if (this.Control["layoutTypeDropDown"].Value = 2) {
			this.chooseLayout(false)

			margins := ["", "", "", ""]
		}
		else
			margins := [ButtonBoxPreview.kRowMargin, ButtonBoxPreview.kColumnMargin, ButtonBoxPreview.kSidesMargin, ButtonBoxPreview.kBottomMargin]

		grid := (this.Control["layoutRowsEdit"].Text . "x" . this.Control["layoutColumnsEdit"].Text)

		this.loadEditor(Array(this.Control["layoutNameEdit"].Text
					  , CaseInsenseMap("Type", ["Button Box", "Stream Deck"][this.Control["layoutTypeDropDown"].Value]
									 , "Visible", (this.Control["layoutTypeDropDown"].Value = 1) ? true : false
									 , "Grid", grid, "Margins", margins)))

		if (this.CurrentItem != 0)
			this.updateItem()
	}

	chooseLayout(update := true) {
		Sleep 1000

		local layoutDropDown := this.Control["layoutDropDown"].Value

		sleep 1000

		if (layoutDropDown = 1) {
			this.Control["layoutRowsEdit"].Text := 2
			this.Control["layoutColumnsEdit"].Text := 3
		}
		else if (layoutDropDown = 2) {
			this.Control["layoutRowsEdit"].Text := 3
			this.Control["layoutColumnsEdit"].Text := 5
		}
		else if (layoutDropDown = 3) {
			this.Control["layoutRowsEdit"].Text := 4
			this.Control["layoutColumnsEdit"].Text := 8
		}
		else {
			this.Control["layoutRowsEdit"].Text := 2
			this.Control["layoutColumnsEdit"].Text := 4
		}

		if (update && (this.CurrentItem != 0))
			this.updateItem()
	}

	openDisplayRulesEditor() {
		local window := this.Window
		local name := false
		local result, configuration

		if this.CurrentItem
			name := this.Control["layoutNameEdit"].Text

		configuration := newMultiMap()

		setMultiMapValues(configuration, "Icons", this.iIconDefinitions)
		setMultiMapValues(configuration, "Buttons", this.iButtonDefinitions)

		window.Block()

		try {
			result := (DisplayRulesEditor(name, configuration)).editDisplayRules(window)
		}
		finally {
			window.Unblock()
		}

		if result {
			this.iIconDefinitions := getMultiMapValues(configuration, "Icons")
			this.iButtonDefinitions := getMultiMapValues(configuration, "Buttons")
		}
	}

	updateLayoutRowEditor(save := true) {
		local rows, changed, choices

		if (save && (this.iSelectedRow > 0))
			this.iRowDefinitions[this.iSelectedRow] := this.Control["layoutRowEdit"].Text

		rows := this.iRowDefinitions.Length
		changed := false

		if (this.Control["layoutRowsEdit"].Text > rows) {
			loop this.Control["layoutRowsEdit"].Text - rows
				this.iRowDefinitions.Push("")

			changed := true
		}
		else if (this.Control["layoutRowsEdit"].Text < rows) {
			this.iRowDefinitions.RemoveAt(this.Control["layoutRowsEdit"].Text + 1, rows - this.Control["layoutRowsEdit"].Text)

			changed := true
		}

		loop this.Control["layoutRowsEdit"].Text
			this.iRowDefinitions[A_Index] := values2String(";", this.getRowDefinition(A_Index)*)

		if (this.Control["layoutRowDropDown"].Value > 0) {
			this.iSelectedRow := this.Control["layoutRowDropDown"].Value

			this.Control["layoutRowEdit"].Text := ((this.iRowDefinitions.Length >= this.iSelectedRow) ? this.iRowDefinitions[this.iSelectedRow] : "")
		}

		if changed {
			choices := []

			loop this.Control["layoutRowsEdit"].Text
				choices.Push(translate("Row ") . A_Index)

			this.Control["layoutRowDropDown"].Delete()
			this.Control["layoutRowDropDown"].Add(choices)

			if (this.Control["layoutRowsEdit"].Text > 0) {
				this.Control["layoutRowDropDown"].Choose(1)

				this.Control["layoutRowEdit"].Text := this.iRowDefinitions[1]

				this.iSelectedRow := 1
			}
			else {
				this.Control["layoutRowDropDown"].Choose(0)

				this.Control["layoutRowEdit"].Text := ""

				this.iSelectedRow := 0
			}
		}

		if (save && this.AutoSave) {
			if (this.CurrentItem != 0)
				this.updateItem()
		}
	}

	getRowDefinition(row) {
		local rowDefinition := string2Values(";", this.iRowDefinitions[row])

		if (rowDefinition.Length > this.Control["layoutColumnsEdit"].Text)
			rowDefinition.RemoveAt(this.Control["layoutColumnsEdit"].Text + 1, rowDefinition.Length - this.Control["layoutColumnsEdit"].Text)
		else
			loop this.Control["layoutColumnsEdit"].Text - rowDefinition.Length
				rowDefinition.Push("")

		return rowDefinition
	}

	setRowDefinition(row, rowDefinition) {
		this.iRowDefinitions[row] := values2String(";", rowDefinition*)

		this.updateLayoutRowEditor(false)

		this.updateItem()

		this.Editor.configurationChanged(this.CurrentControllerType, this.CurrentController)
	}

	changeControl(row, column, control, argument := false) {
		local number := argument
		local oldButton := false
		local rowDefinition, definition, oldLabel, oldImage, newImage, oldNumber, result

		if (this.CurrentControllerType = "Stream Deck") {
			oldButton := this.Editor.ControllerPreview.getButton(row, column)

			if oldButton {
				oldNumber := oldButton.Button

				if this.iButtonDefinitions.Has(this.Control["layoutNameEdit"].Text . "." . "Button." . oldNumber . ".Icon")
					this.iButtonDefinitions.Delete(this.Control["layoutNameEdit"].Text . "." . "Button." . oldNumber . ".Icon")

				if this.iButtonDefinitions.Has(this.Control["layoutNameEdit"].Text . "." . "Button." . oldNumber . ".Label")
					this.iButtonDefinitions.Delete(this.Control["layoutNameEdit"].Text . "." . "Button." . oldNumber . ".Label")

				if this.iButtonDefinitions.Has(this.Control["layoutNameEdit"].Text . "." . "Button." . oldNumber . ".Mode")
					this.iButtonDefinitions.Delete(this.Control["layoutNameEdit"].Text . "." . "Button." . oldNumber . ".Mode")
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

			result := InputBox(translate("Please enter a button label:"), translate("Button Label"), "w200 h150", ((oldLabel && (oldLabel != true)) ? oldLabel : ""))

			if (result.Result = "Ok")
				oldButton.Label := result.Value
			else
				return

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

			newImage := chooseImageFile(this.Window, (oldImage && (oldImage != true)) ? oldImage : (kStreamDeckImagesDirectory . "Icons"))

			if newImage
				oldButton.Icon := newImage
			else
				return

			number := oldButton.Button
			definition := rowDefinition[column]
		}
		else if (control = "__Number__") {
			if !number {
				if (definition.Length > 0)
					number := ConfigurationItem.splitDescriptor(definition[1])[2]
				else
					number := ""

				result := InputBox(translate("Please enter a controller function number:")
								 , translate("Function Number"), "w200 h150", number)

				if (result.Result = "Ok")
					number := result.Value
				else
					return
			}

			if (definition.Length = 1)
				definition := ConfigurationItem.descriptor(ConfigurationItem.splitDescriptor(definition[1])[1], number)
			else if (this.CurrentControllerType = "Stream Deck")
				definition := ("Button." . number)
			else
				definition := (ConfigurationItem.descriptor(ConfigurationItem.splitDescriptor(definition[1])[1], number) . "," . definition[2])
		}
		else if control {
			if ((definition.Length = 0) || ((definition.Length = 1) && (definition[1] = ""))) {
				definition := ConfigurationItem.descriptor(control, 1)
				number := 1
			}
			else if (definition.Length = 1) {
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

			this.iButtonDefinitions[this.Control["layoutNameEdit"].Text . "." . "Button." . number . ".Icon"] := oldButton.Icon
			this.iButtonDefinitions[this.Control["layoutNameEdit"].Text . "." . "Button." . number . ".Label"] := oldButton.Label
			this.iButtonDefinitions[this.Control["layoutNameEdit"].Text . "." . "Button." . number . ".Mode"] := oldButton.Mode
		}

		rowDefinition[column] := definition

		this.setRowDefinition(row, rowDefinition)
	}

	changeLabel(row, column, label) {
		local rowDefinition := this.getRowDefinition(row)
		local definition := string2Values(",", rowDefinition[column])

		if (definition.Length = 0)
			definition := (label ? ("," . label) : "")
		else if (definition.Length >= 1)
			definition := (definition[1] . (label ? ("," . label) : ""))

		rowDefinition[column] := definition

		this.setRowDefinition(row, rowDefinition)
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ControllerPreview                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ControllerPreview extends ConfigurationItem {
	static sControllerPreviews := CaseInsenseMap()

	iPreviewManager := false
	iName := ""

	iRows := false
	iColumns := false

	iWindow := false

	iWidth := 0
	iHeight := 0

	iControlClickHandler := ObjBindMethod(this, "openControlMenu")

	PreviewManager {
		Get {
			return this.iPreviewManager
		}
	}

	Name {
		Get {
			return this.iName
		}
	}

	Window {
		Get {
			return this.iWindow
		}

		Set {
			return (this.iWindow := value)
		}
	}

	Control[name] {
		Get {
			return this.Window[name]
		}
	}

	Type {
		Get {
			throw "Virtual property ControllerPreview.Type must be implemented in a subclass..."
		}
	}

	Rows {
		Get {
			return this.iRows
		}

		Set {
			return (this.iRows := value)
		}
	}

	Columns {
		Get {
			return this.iColumns
		}

		Set {
			return (this.iColumns := value)
		}
	}

	Width {
		Get {
			return this.iWidth
		}

		Set {
			return (this.iWidth := value)
		}
	}

	Height {
		Get {
			return this.iHeight
		}

		Set {
			return (this.iHeight := value)
		}
	}

	static ControllerPreviews[key?] {
		Get {
			return (isSet(key) ? ControllerPreview.sControllerPreviews[key] : ControllerPreview.sControllerPreviews)
		}

		Set {
			return (isSet(key) ? (ControllerPreview.sControllerPreviews[key] := value) : (ControllerPreview.sControllerPreviews := value))
		}
	}

	ControllerPreviews[key?] {
		Get {
			return ControllerPreview.ControllerPreviews[key?]
		}

		Set {
			return (ControllerPreview.ControllerPreviews[key?] := value)
		}
	}

	__New(previewManager, name, configuration) {
		this.iPreviewManager := previewManager
		this.iName := name

		super.__New(configuration)

		this.createGui(configuration)

		this.createBackground(configuration)
	}

	createGui(configuration) {
		throw "Virtual method ControllerPreview.createGui must be implemented in a subclass..."
	}

	createBackground(configuration) {
	}

	getControl(clickX, clickY, &row, &column, &isEmpty) {
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

	findFunction(function, &row, &column) {
		local cRow

		loop this.Rows {
			cRow := A_Index

			loop this.Columns {
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
		local function, row

		loop this.Rows {
			row := A_Index

			loop this.Columns {
				function := this.getFunction(row, A_Index)

				if function
					this.setLabel(row, A_Index, ConfigurationItem.splitDescriptor(function)[2])
			}
		}
	}

	setLabel(row, column, text) {
		throw "Virtual method ControllerPreview.setLabel must be implemented in a subclass..."
	}

	show() {
		local width := this.Width
		local height := this.Height
		local centerX := 0
		local centerY := 0
		local window, x, y
		local mainScreen, mainScreenLeft, mainScreenRight, mainScreenTop, mainScreenBottom

		this.PreviewManager.getPreviewCenter(this.Window, &centerX, &centerY)

		MonitorGetWorkArea(, &mainScreenLeft, &mainScreenTop, &mainScreenRight, &mainScreenBottom)

		if centerX
			x := centerX - Round(width / 2)
		else
			x := mainScreenRight - width

		if centerY
			y := centerY - Round(height / 2)
		else
			y := mainScreenBottom - height

		window := this.Window

		this.ControllerPreviews[window] := this

		window.Show("x" . x . " y" . y . " w" . width . " h" . height . " NoActivate")
	}

	hide() {
		this.Window.Hide()
	}

	close() {
		local window := this.Window

		this.ControllerPreviews.Delete(window)

		window.Destroy()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; DisplayRulesEditor                                                      ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class DisplayRulesEditor extends ConfiguratorPanel {
	iClosed := false
	iSaved := false

	iLayout := false
	iSelectedLayout := false

	iButtons := false
	iSelectedButton := false

	iDisplayRulesList := false

	class RulesWindow extends Window {
		iEditor := false

		__New(editor) {
			this.iEditor := editor

			super.__New({Descriptor: "Controller Editor.Display Rules", Closeable: true, Resizeable: true, Options: "-MaximizeBox"})
		}

		Close(*) {
			this.iEditor.close(false)
		}
	}

	Layout {
		Get {
			return this.iLayout
		}
	}

	SelectedLayout {
		Get {
			return this.iSelectedLayout
		}
	}

	Buttons[index?] {
		Get {
			return (isSet(index) ? this.iButtons[index] : this.iButtons)
		}
	}

	SelectedButton {
		Get {
			return this.iSelectedButton
		}
	}

	__New(layout, configuration) {
		this.iLayout := layout
		this.iSelectedLayout := layout

		super.__New(configuration)

		DisplayRulesEditor.Instance := this

		this.iDisplayRulesList := DisplayRulesList(this, configuration)
	}

	createGui(configuration) {
		local layouts, chosen, disabled

		static rulesGui

		saveDisplayRulesEditor(*) {
			this.close(true)
		}

		cancelDisplayRulesEditor(*) {
			this.close(false)
		}

		chooseDisplayRuleLayout(*) {
			this.chooseDisplayRuleLayout()
		}

		chooseDisplayRuleButton(*) {
			this.chooseDisplayRuleButton()
		}

		rulesGui := DisplayRulesEditor.RulesWindow(this)

		this.Window := rulesGui

		rulesGui.SetFont("Bold", "Arial")

		rulesGui.Add("Text", "w316 H:Center Center", translate("Modular Simulator Controller System")).OnEvent("Click", moveByMouse.Bind(rulesGui, "Controller Editor.Display Rules"))

		rulesGui.SetFont("Norm", "Arial")

		rulesGui.Add("Documentation", "x110 YP+20 w112 H:Center Center", translate("Display Rules")
				   , "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#display-rules")

		rulesGui.SetFont("Norm", "Arial")

		layouts := [translate("All Layouts")]
		chosen := 1

		if this.Layout {
			layouts.Push(this.Layout)

			chosen := 2
		}

		rulesGui.Add("Text", "x8 yp+30 w80 h23 +0x200", translate("Layout"))
		rulesGui.Add("DropDownList", "x90 yp w150 W:Grow(0.3) Choose" . chosen . " VdisplayRuleLayoutDropDown", layouts).OnEvent("Change", chooseDisplayRuleLayout)

		disabled := ""

		if !this.Layout {
			disabled := "Disabled"
			chosen := 0
		}
		else
			chosen := 1

		rulesGui.Add("Text", "x8 yp+24 w80 h23 +0x200", translate("Button"))
		rulesGui.Add("DropDownList", "x90 yp w150 W:Grow(0.3) " . disabled . " Choose" . chosen . " vdisplayRuleButtonDropDown", [translate("All Buttons")]).OnEvent("Change", chooseDisplayRuleButton)

		this.iDisplayRulesList.createGui(this, configuration)

		rulesGui.Add("Text", "x50 yp+30 w232 Y:Move W:Grow 0x10")

		rulesGui.Add("Button", "x80 yp+10 w80 h23 Y:Move X:Move(0.5) Default", translate("Save")).OnEvent("Click", saveDisplayRulesEditor)
		rulesGui.Add("Button", "x180 yp w80 h23 Y:Move X:Move(0.5)", translate("Cancel")).OnEvent("Click", cancelDisplayRulesEditor)

		this.loadLayoutButtons()
	}

	saveToConfiguration(configuration) {
		this.iDisplayRulesList.saveToConfiguration(configuration)
	}

	loadLayoutButtons() {
		local buttons := [translate("All Buttons")]
		local descriptor, definition, ignore, button

		if this.SelectedLayout
			for descriptor, definition in getMultiMapValues(LayoutsList.Instance.StreamDeckConfiguration, "Layouts") {
				descriptor := ConfigurationItem.splitDescriptor(descriptor)

				if ((descriptor[1] = this.Layout) && (descriptor[2] != "Layout"))
					for ignore, button in string2Values(";", definition)
						if (button != "")
							buttons.Push(button)
			}

		this.Control["displayRuleButtonDropDown"].Delete()
		this.Control["displayRuleButtonDropDown"].Add(buttons)
		this.Control["displayRuleButtonDropDown"].Choose(1)

		buttons.RemoveAt(1)

		this.iButtons := buttons

		if this.SelectedLayout
			this.Control["displayRuleButtonDropDown"].Enabled := true
		else
			this.Control["displayRuleButtonDropDown"].Enabled := false

		this.iSelectedButton := false
	}

	editDisplayRules(owner := false) {
		local window

		this.createGui(this.Configuration)

		window := this.Window

		if owner
			window.Opt("+Owner" . owner.Hwnd)

		try {
			this.show()

			loop
				Sleep(200)
			until this.iClosed

			return this.iSaved
		}
		finally {
			window.Destroy()
		}
	}

	show() {
		local window := this.Window
		local x, y, w, h

		if getWindowPosition("Controller Editor.Display Rules", &x, &y)
			window.Show("x" . x . " y" . y)
		else
			window.Show("AutoSize Center")

		if getWindowSize("Controller Editor.Display Rules", &w, &h)
			window.Resize("Initialze", w, h)
	}

	hide() {
		this.Window.hide()
	}

	close(save := true) {
		if save
			this.iDisplayRulesList.saveToConfiguration(this.Configuration)

		this.iSaved := save
		this.iClosed := true
	}

	chooseDisplayRuleLayout() {
		local displayRulesList := this.iDisplayRulesList

		displayRulesList.saveToConfiguration(this.Configuration)

		this.iSelectedLayout := ((this.Control["displayRuleLayoutDropDown"].Value = 1) ? false : this.Layout)

		this.loadLayoutButtons()

		displayRulesList.loadFromConfiguration(this.Configuration)

		displayRulesList.loadList(displayRulesList.ItemList)

		displayRulesList.CurrentItem := false
		displayRulesList.clearEditor()
	}

	chooseDisplayRuleButton() {
		local displayRulesList := this.iDisplayRulesList

		displayRulesList.saveToConfiguration(this.Configuration)

		this.iSelectedButton := ((this.Control["displayRuleButtonDropDown"].Value = 1) ? false : this.Buttons[this.Control["displayRuleButtonDropDown"].Value - 1])

		displayRulesList.loadFromConfiguration(this.Configuration)

		displayRulesList.loadList(displayRulesList.ItemList)

		displayRulesList.CurrentItem := false
		displayRulesList.clearEditor()
	}
}

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; DisplayRulesList                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class DisplayRulesList extends ConfigurationItemList {
	AutoSave {
		Get {
			if ControllerEditor.HasProp("Instance")
				return ControllerEditor.Instance.AutoSave
		}
	}

	__New(editor, configuration) {
		this.Editor := editor

		super.__New(configuration)

		DisplayRulesList.Instance := this
	}

	createGui(editor, configuration) {
		local window := editor.Window

		chooseIconFilePath(*) {
			local path, pictureFile

			path := window["iconFilePathEdit"].Text

			if (path && (path != ""))
				path := getFileName(path, kStreamDeckImagesDirectory)
			else
				path := (kStreamDeckImagesDirectory . "Icons")

			pictureFile := chooseImageFile(window, path)

			if pictureFile
				window["iconFilePathEdit"].Text := pictureFile
		}

		window.Add("ListView", "x8 yp+30 w316 h120 W:Grow H:Grow -Multi -LV0x10 AltSubmit NoSort NoSortHdr VdisplayRulesListView", collect(["Rule", "Icon"], translate))

		window.Add("Text", "x8 yp+126 w80 h23 Y:Move +0x200", translate("Rule"))
		window.Add("DropDownList", "x90 yp w150 Y:Move W:Grow(0.3) Choose1 VdisplayRuleDropDown", collect(["Icon or Label", "Icon and Label", "Only Icon", "Only Label"], translate))

		window.Add("Text", "x8 yp+24 w80 h23 Y:Move +0x200", translate("Icon"))
		window.Add("Edit", "x90 yp w211 h21 Y:Move W:Grow ViconFilePathEdit")
		window.Add("Button", "x303 yp-1 w23 h23 Y:Move X:Move", translate("...")).OnEvent("Click", chooseIconFilePath)

		window.Add("Button", "x126 yp+40 w46 h23 Y:Move X:Move VdisplayRuleAddButton", translate("Add"))
		window.Add("Button", "x175 yp w50 h23 Y:Move X:Move Disabled VdisplayRuleDeleteButton", translate("Delete"))
		window.Add("Button", "x271 yp w55 h23 Y:Move X:Move Disabled VdisplayRuleUpdateButton", translate("Save"))

		this.initializeList(editor, window["displayRulesListView"], window["displayRuleAddButton"], window["displayRuleDeleteButton"], window["displayRuleUpdateButton"])

		this.clearEditor()
	}

	loadFromConfiguration(configuration) {
		super.loadFromConfiguration(configuration)

		this.ItemList := this.loadDisplayRules(configuration, this.Editor.SelectedLayout, this.Editor.SelectedButton)
	}

	saveToConfiguration(configuration) {
		local fullConfiguration := this.Configuration

		this.saveDisplayRules(fullConfiguration, this.Editor.SelectedLayout, this.Editor.SelectedButton, this.ItemList)

		setMultiMapValues(configuration, "Icons", getMultiMapValues(fullConfiguration, "Icons"))
		setMultiMapValues(configuration, "Buttons", getMultiMapValues(fullConfiguration, "Buttons"))
	}

	loadDisplayRules(configuration, layout, button) {
		local icons := []
		local prefix, icon

		if button {
			prefix := (layout . "." . button . ".Mode.Icon.")

			loop {
				icon := getMultiMapValue(configuration, "Buttons", prefix . A_Index, kUndefined)

				if (icon = kUndefined)
					break
				else
					icons.Push(string2Values(";", icon))
			}
		}
		else {
			prefix := ((layout ? layout : "*") . ".Icon.Mode.")

			loop {
				icon := getMultiMapValue(configuration, "Icons", prefix . A_Index, kUndefined)

				if (icon = kUndefined)
					break
				else
					icons.Push(string2Values(";", icon))
			}
		}

		return icons
	}

	saveDisplayRules(configuration, layout, button, displayRules) {
		local prefix, index, displayRule

		if button {
			prefix := (layout . "." . button . ".Mode.Icon.")

			loop {
				if (getMultiMapValue(configuration, "Buttons", prefix . A_Index, kUndefined) == kUndefined)
					break
				else
					removeMultiMapValue(configuration, "Buttons", prefix . A_Index)
			}

			for index, displayRule in displayRules
				setMultiMapValue(configuration, "Buttons", prefix . index, values2String(";", displayRule*))
		}
		else {
			prefix := ((layout ? layout : "*") . ".Icon.Mode.")

			loop {
				if (getMultiMapValue(configuration, "Icons", prefix . A_Index, kUndefined) == kUndefined)
					break
				else
					removeMultiMapValue(configuration, "Icons", prefix . A_Index)
			}

			for index, displayRule in displayRules
				setMultiMapValue(configuration, "Icons", prefix . index, values2String(";", displayRule*))
		}
	}

	loadList(items) {
		local ignore, displayRule, rule

		this.Control["displayRulesListView"].Delete()

		this.ItemList := items

		for ignore, displayRule in items {
			rule := ["Icon or Label", "Icon and Label", "Only Icon", "Only Label"][inList([kIconOrLabel, kIconAndLabel, kIcon, kLabel], displayRule[2])]

			this.Control["displayRulesListView"].Add("", translate(rule), displayRule[1])
		}

		this.Control["displayRulesListView"].ModifyCol()
		this.Control["displayRulesListView"].ModifyCol(1, "AutoHdr")
		this.Control["displayRulesListView"].ModifyCol(2, "AutoHdr")
	}

	loadEditor(item) {
		this.Control["iconFilePathEdit"].Text := item[1]
		this.Control["displayRuleDropDown"].Choose(inList([kIconOrLabel, kIconAndLabel, kIcon, kLabel], item[2]))
	}

	clearEditor() {
		this.loadEditor(Array("", kIconOrLabel))
	}

	buildItemFromEditor(isNew := false) {
		return Array(this.Control["iconFilePathEdit"].Text, [kIconOrLabel, kIconAndLabel, kIcon, kLabel][this.Control["displayRuleDropDown"].Value])
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Public Function Declaration Section                   ;;;
;;;-------------------------------------------------------------------------;;;

controlClick(window, *) {
	local curCoordMode := A_CoordModeMouse
	local row, column, isEmpty, element, clickX, clickY

	CoordMode("Mouse", "Window")

	try {
		MouseGetPos(&clickX, &clickY)

		clickX := screen2Window(clickX)
		clickY := screen2Window(clickY)

		row := 0
		column := 0
		isEmpty := false

		element := ControllerPreview.ControllerPreviews[window].getControl(clickX, clickY, &row, &column, &isEmpty)

		if element
			ControllerPreview.ControllerPreviews[window].controlClick(element, row, column, isEmpty)
	}
	finally {
		CoordMode("Mouse", curCoordMode)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

chooseImageFile(window, path) {
	local pictureFile

	window.Opt("+OwnDialogs")

	OnMessage(0x44, translateSelectCancelButtons)
	pictureFile := FileSelect(1, path, translate("Select Image..."), "Image (*.jpg; *.png; *.gif; *.ico)")
	OnMessage(0x44, translateSelectCancelButtons, 0)

	return ((pictureFile != "") ? pictureFile : false)
}