;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Stream Deck Preview             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kIcon = "Icon"
global kLabel = "Label"
global kIconAndLabel = "IconAndLabel"
global kIconOrLabel = "IconOrLabel"


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; StreamDeckPreview                                                       ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class StreamDeckPreview extends ControllerPreview {
	static kMiniWidth := 254
	static kMiniHeight := 208
	static kStandardWidth := 387
	static kStandardHeight := 267
	static kXLWidth := 572
	static kXLHeight := 330
	
	static kTopMargin := 50
	static kLeftMargin := {Mini: 38, Standard: 44, XL: 44}
	
	static kButtonWidth := 50
	static kButtonHeight := 50
	
	static kRowMargin := 13
	static kColumnMargin := 13
	
	iSize := "Standard"
	
	iButtons := {}
	iLabels := {}
	iIcons := {}
	
	Type[] {
		Get {
			return "Stream Deck"
		}
	}
	
	Size[] {
		Get {
			return this.iSize
		}
	}
	
	loadFromConfiguration(configuration) {
		layout := getConfigurationValue(configuration, "Layouts", this.Name . ".Layout", "Standard")
		
		switch layout {
			case "Mini":
				layout := [2, 3]
			case "Standard":
				layout := [3, 5]
			case "XL":
				layout := [4, 8]
			default:
				layout := string2Values("x", layout)
		}
		
		if (layout[1] = 2) {
			this.Width := this.kMiniWidth
			this.Height := this.kMiniHeight
			
			this.iSize := "Mini"
		}
		else if (layout[1] = 3) {
			this.Width := this.kStandardWidth
			this.Height := this.kStandardHeight
			
			this.iSize := "Standard"
		}
		else if (layout[1] = 4) {
			this.Width := this.kXLWidth
			this.Height := this.kXLHeight
			
			this.iSize := "XL"
		}
		
		this.Rows := layout[1]
		this.Columns := layout[2]
		
		Loop % this.Rows
		{
			row := A_Index
			
			this.iButtons[row] := Object()
			
			Loop % this.Columns
			{
				column := A_Index
			
				button := string2Values(";", getConfigurationValue(this.Configuration, "Layouts", this.Name . "." . row))[column]
				
				if (button && (button != "")) {
					icon := getConfigurationValue(this.Configuration, "Buttons", this.Name . "." . button . ".Icon", true)
					label := getConfigurationValue(this.Configuration, "Buttons", this.Name . "." . button . ".Label", true)
					mode := getConfigurationValue(this.Configuration, "Buttons", this.Name . "." . button . ".Mode", kIconOrLabel)
					
					this.iButtons[row][column] := {Button: ConfigurationItem.splitDescriptor(button)[2], Icon: icon, Label: label, Mode: mode}
				}
				else
					this.iButtons[row][column] := false
			}
		}
	}
	
	createGui(configuration) {
		window := this.Window
		
		Gui %window%:Default
		
		Gui %window%:-Border -Caption
		
		Gui %window%:+LabelstreamDeck
		
		Gui %window%:Add, Picture, x0 y0, % (kStreamDeckImagesDirectory . "Stream Deck " . this.Size . ".jpg")
		
		Gui %window%:Color, 0x000000
		Gui %window%:Font, s8 Norm, Arial
		
		row := 0
		column := 0
		isEmpty := true
		
		y := this.kTopMargin
		
		Gui %window%:Font, cWhite
		
		Loop % this.Rows
		{
			this.iLabels[A_Index] := Object()
			this.iIcons[A_Index] := Object()
			
			row := A_Index
				
			x := this.kLeftMargin[this.Size]
			
			Loop % this.Columns
			{
				column := A_Index
				
				posX := (x + 3)
				posY := (y + 3)
				
				Gui %window%:Add, Picture, x%posX% y%posY% w44 h44 BackgroundTrans hwndiconHandle
				Gui %window%:Add, Text, x%posX% y%posY% w44 h44 Center BackgroundTrans hwndlabelHandle gcontrolClick
				
				this.iLabels[row][column] := labelHandle
				this.iIcons[row][column] := iconHandle
				
				x += (this.kColumnMargin + this.kButtonWidth)
			}
				
			y += (this.kRowMargin + this.kButtonHeight)
		}
		
		this.updateButtons()
	}
	
	createBackground(configuration) {
		window := this.Window
		
		previewMover := this.PreviewManager.getPreviewMover()
		previewMover := (previewMover ? ("g" . previewMover) : "")
		
		Gui %window%:Add, Picture, x0 y0 %previewMover% 0x4000000, % (kStreamDeckImagesDirectory . "Stream Deck " . this.Size . ".jpg")
	}
	
	getButton(row, column) {
		return this.iButtons[row][column]
	}
	
	setButton(row, column, descriptor) {
		this.iButtons[row][column] := descriptor
	}
	
	getLabel(row, column) {
		button := this.getButton(row, column)
		
		return (button ? button.Label : true)
	}
	
	getIcon(row, column) {
		button := this.getButton(row, column)
		
		return (button ? button.Icon : true)
	}
	
	getMode(row, column) {
		button := this.getButton(row, column)
		
		return (button ? button.Mode : false)
	}
	
	updateButtons() {
		Loop % this.Rows
		{
			row := A_Index
				
			Loop % this.Columns
			{
				column := A_Index
			
				handle := this.iLabels[row][column]
				
				button := this.getButton(row, column)
				
				if button {
					label := this.getLabel(row, column)
					
					GuiControl Text, %handle%, % button.Button . ((label && (label != true)) ? ("`n" . label) : "")
				}
				else
					GuiControl Text, %handle%, % ""
			
				handle := this.iIcons[row][column]
				icon := this.getIcon(row, column)
				
				if !icon
					icon := (kIconsDirectory . "Empty.png")
				
				try
					GuiControl, , %handle%, % icon
			}
		}
	}
	
	getFunction(row, column) {
		button := this.getButton(row, column)
		
		return (button ? ("Button." . button.Button) : false)
	}
	
	setLabel(row, column, text) {
		handle := this.iLabels[row][column]
		
		if handle
			GuiControl Text, %handle%, %text%
	}
	
	getControl(clickX, clickY, ByRef row, ByRef column, ByRef isEmpty) {
		local function
		
		descriptor := "Empty.0"
		name := "Empty"
		number := 0
		
		row := 0
		column := 0
		isEmpty := true
		
		y := this.kTopMargin
		
		Loop % this.Rows
		{
			if ((clickY > y) && (clickY < (y + this.kButtonHeight))) {
				row := A_Index
				
				x := this.kLeftMargin[this.Size]
				
				Loop % this.Columns
				{
					if ((clickX > x) && (clickX < (x + this.kButtonWidth))) {
						column := A_Index
						
						button := this.getButton(row, column)
						
						if button {
							name := "Button"
							number := button.Button
							
							isEmpty := false
						}
						
						return ["Control", ConfigurationItem.descriptor(name, number)]
					}
				
					x += (this.kColumnMargin + this.kButtonWidth)
				}
			}
				
			y += (this.kRowMargin + this.kButtonHeight)
		}

		previewMover := this.PreviewManager.getPreviewMover()
		
		if previewMover
			%previewMover%()
		
		return false
	}
	
	controlClick(element, row, column, isEmpty) {
		handler := this.iControlClickHandler
			
		return %handler%(this, element, element[2], row, column, isEmpty)
	}
	
	openControlMenu(preview, element, function, row, column, isEmpty) {
		local count
		
		menuItem := (translate(element[1]) . translate(": ") . element[2] . " (" . row . " x " . column . ")")
		
		try {
			Menu MainMenu, DeleteAll
		}
		catch exception {
			; ignore
		}
		
		window := this.Window
		
		Gui %window%:Default
		
		Menu MainMenu, Add, %menuItem%, controlMenuIgnore
		Menu MainMenu, Disable, %menuItem%
		Menu MainMenu, Add
		
		try {
			Menu ControlMenu, DeleteAll
		}
		catch exception {
			; ignore
		}
		
		label := translate("Empty")
		handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, false)
		
		Menu ControlMenu, Add, %label%, %handler%
		
		Menu ControlMenu, Add
		
		try {
			Menu NumberMenu, DeleteAll
		}
		catch exception {
			; ignore
		}
		
		label := translate("Input...")
		handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Number__", false)
		
		Menu NumberMenu, Add, %label%, %handler%
		Menu NumberMenu, Add
		
		count := 1
		
		Loop 4 {
			label := (count . " - " . (count + 9))
			
			menu := ("NumSubMenu" . A_Index)
		
			try {
				Menu %menu%, DeleteAll
			}
			catch exception {
				; ignore
			}
			
			Loop 10 {
				handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Number__", count)
				Menu %menu%, Add, %count%, %handler%
				
				if (count = ConfigurationItem.splitDescriptor(element[2])[2])
					Menu %menu%, Check, %count%
				
				count += 1
			}
		
			Menu NumberMenu, Add, %label%, :%menu%
		}
		
		label := translate("Number")
		Menu ControlMenu, Add, %label%, :NumberMenu
		
		label := translate("Button")
		
		Menu MainMenu, Add, %label%, :ControlMenu
		
		button := this.getButton(row, column)
		
		if button {
			try {
				Menu DisplayMenu, DeleteAll
			}
			catch exception {
				; ignore
			}
			
			try {
				Menu LabelMenu, DeleteAll
			}
			catch exception {
				; ignore
			}
			
			labelMode := this.getLabel(row, column)
			
			label := translate("Empty")
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__No_Label__", false)
			Menu LabelMenu, Add, %label%, %handler%
			if (labelMode == false)
				Menu LabelMenu, Check, %label%
			
			label := translate("Action")
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Action_Label__", false)
			Menu LabelMenu, Add, %label%, %handler%
			if (labelMode == true)
				Menu LabelMenu, Check, %label%
			
			label := translate("Text...")
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Text_Label__", false)
			Menu LabelMenu, Add, %label%, %handler%
			if (labelMode && (labelMode != true))
				Menu LabelMenu, Check, %label%
			
			label := translate("Label")
			
			Menu DisplayMenu, Add, %label%, :LabelMenu
			
			try {
				Menu IconMenu, DeleteAll
			}
			catch exception {
				; ignore
			}
			
			iconMode := this.getIcon(row, column)
			
			label := translate("Empty")
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__No_Icon__", false)
			Menu IconMenu, Add, %label%, %handler%
			if (iconMode == false)
				Menu IconMenu, Check, %label%
			
			label := translate("Action")
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Action_Icon__", false)
			Menu IconMenu, Add, %label%, %handler%
			if (iconMode == true)
				Menu IconMenu, Check, %label%
			
			label := translate("Image...")
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Image_Icon__", false)
			Menu IconMenu, Add, %label%, %handler%
			if (iconMode && (iconMode != true))
				Menu IconMenu, Check, %label%
			
			label := translate("Icon")
			
			Menu DisplayMenu, Add, %label%, :IconMenu
			
			try {
				Menu ModeMenu, DeleteAll
			}
			catch exception {
				; ignore
			}
			
			mode := this.getMode(row, column)
			
			label := translate("Icon or Label")
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Mode__", kIconOrLabel)
			Menu ModeMenu, Add, %label%, %handler%
			if (mode == kIconOrLabel)
				Menu ModeMenu, Check, %label%
			
			label := translate("Icon and Label")
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Mode__", kIconAndLabel)
			Menu ModeMenu, Add, %label%, %handler%
			if (mode == kIconAndLabel)
				Menu ModeMenu, Check, %label%
			
			label := translate("Only Icon")
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Mode__", kIcon)
			Menu ModeMenu, Add, %label%, %handler%
			if (mode == kIcon)
				Menu ModeMenu, Check, %label%
			
			label := translate("Only Label")
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, "__Mode__", kLabel)
			Menu ModeMenu, Add, %label%, %handler%
			if (mode == kLabel)
				Menu ModeMenu, Check, %label%
			
			label := translate("Rule")
			
			Menu DisplayMenu, Add, %label%, :ModeMenu
			
			label := translate("Display")
			
			Menu MainMenu, Add, %label%, :DisplayMenu
		}

		Menu MainMenu, Show
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

streamDeckContextMenu(guiHwnd, ctrlHwnd, eventInfo, isRightClick, x, y) {
	if (isRightClick && vControllerPreviews.HasKey(A_Gui))
		controlClick()
}