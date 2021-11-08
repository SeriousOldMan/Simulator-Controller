;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Button Box Preview              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kEmptySpaceDescriptor = "Button;" . kButtonBoxImagesDirectory . "Empty.png;52 x 52"


;;;-------------------------------------------------------------------------;;;
;;;                         Private Variables Section                       ;;;
;;;-------------------------------------------------------------------------;;;

global vButtonBoxPreviews = {}


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;
;;; ButtonBoxPreview                                                        ;;;
;;;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -;;;

class ButtonBoxPreview extends ControllerPreview {
	static kHeaderHeight := 70
	static kLabelMargin := 5
	
	static kRowMargin := 20
	static kColumnMargin := 40
	
	static kSidesMargin := 20
	static kBottomMargin := 15
	
	iRows := 0
	iColumns := 0
	iRowMargin := this.kRowMargin
	iColumnMargin := this.kColumnMargin
	iSidesMargin := this.kSidesMargin
	iBottomMargin := this.kBottomMargin
	
	iRowDefinitions := []
	
	iFunctions := {}
	iLabels := {}
	
	Type[] {
		Get {
			return "Button Box"
		}
	}
	
	RowMargin[] {
		Get {
			return this.iRowMargin
		}
	}
	
	ColumnMargin[] {
		Get {
			return this.iColumnMargin
		}
	}
	
	SidesMargin[] {
		Get {
			return this.iSidesMargin
		}
	}
	
	BottomMargin[] {
		Get {
			return this.iBottomMargin
		}
	}
	
	RowDefinitions[row := false] {
		Get {
			if row
				return this.iRowDefinitions[row]
			else
				return this.iRowDefinitions
		}
	}
	
	createGui(configuration) {
		local function
		
		rowHeights := false
		columnWidths := false
		
		this.computeLayout(rowHeights, columnWidths)
		
		height := 0
		Loop % rowHeights.Length()
			height += rowHeights[A_Index]
		
		width := 0
		Loop % columnWidths.Length()
			width += columnWidths[A_Index]
		
		height += ((rowHeights.Length() - 1) * this.RowMargin) + this.kHeaderHeight + this.BottomMargin
		width += ((columnWidths.Length() - 1) * this.ColumnMargin) + (2 * this.SidesMargin)
		
		window := this.Window
		
		previewMover := this.PreviewManager.getPreviewMover()
		previewMover := (previewMover ? ("g" . previewMover) : "")
		
		Gui %window%:-Border -Caption
		
		Gui %window%:+LabelbuttonBox
		
		Gui %window%:Add, Picture, x-10 y-10, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"
		
		Gui %window%:Font, s12 Bold cSilver
		Gui %window%:Add, Text, x0 y8 w%width% h23 +0x200 +0x1 BackgroundTrans %previewMover%, % translate("Modular Simulator Controller System")
		Gui %window%:Font, s10 cSilver
		Gui %window%:Add, Text, x0 y28 w%width% h23 +0x200 +0x1 BackgroundTrans %previewMover%, % translate(this.Name)
		Gui %window%:Color, 0x000000
		Gui %window%:Font, s8 Norm, Arial
		
		vertical := this.kHeaderHeight
		
		Loop % this.Rows
		{
			row := A_Index
			
			rowHeight := rowHeights[A_Index]
			rowDefinition := this.RowDefinitions[A_Index]
		
			horizontal := this.SidesMargin
			
			Loop % this.Columns
			{
				column := A_Index
				
				columnWidth := columnWidths[A_Index]
			
				descriptor := rowDefinition[A_Index]
				
				if (StrLen(Trim(descriptor)) = 0)
					descriptor := "Empty.0"
				
				descriptor := string2Values(",", descriptor)
			
				if (descriptor.Length() > 1) {
					label := string2Values("x", getConfigurationValue(this.Configuration, "Labels", descriptor[2], ""))
					labelWidth := label[1]
					labelHeight := label[2]
				}
				else {
					labelWidth := 0
					labelHeight := 0
				}
				
				if (descriptor[1] = "Empty.0") {
					descriptor := kEmptySpaceDescriptor
					number := 0
				}
				else {
					descriptor := ConfigurationItem.splitDescriptor(descriptor[1])
					number := descriptor[2]
					
					descriptor := getConfigurationValue(this.Configuration, "Controls", descriptor[1], "")
				}
				
				descriptor := string2Values(";", descriptor)
				
				if (descriptor.Length() > 0) {
					function := descriptor[1]
					image := substituteVariables(descriptor[2])
					
					descriptor := string2Values("x", descriptor[3])
					imageWidth := descriptor[1]
					imageHeight := descriptor[2]
					
					function := ConfigurationItem.descriptor(function, number)

					if !this.iFunctions.HasKey(row)
						this.iFunctions[row] := {}
					
					this.iFunctions[row][column] := function
					
					x := horizontal + Round((columnWidth - imageWidth) / 2)
					y := vertical + Round((rowHeight - (labelHeight + this.kLabelMargin) - imageHeight) / 2)
					
					Gui %window%:Add, Picture, x%x% y%y% w%imageWidth% h%imageHeight% BackgroundTrans gcontrolClick, %image%
					
					if ((labelWidth > 0) && (labelHeight > 0)) {
						Gui %window%:Font, s8 Norm cBlack
				
						x := horizontal + Round((columnWidth - labelWidth) / 2)
						y := vertical + rowHeight - labelHeight
				
						labelHandle := false
						
						Gui %window%:Add, Text, x%x% y%y% w%labelWidth% h%labelHeight% +Border -Background HWNDlabelHandle +0x1000 +0x1 gcontrolClick, %number%
			
						if !this.iLabels.HasKey(row)
							this.iLabels[row] := {}
						
						this.iLabels[row][column] := labelHandle
					}
				}
				
				horizontal += (columnWidth + this.ColumnMargin)
			}
		
			vertical += (rowHeight + this.RowMargin)
		}

		Gui %window%:Add, Picture, x-10 y-10 %previewMover% 0x4000000, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"
		
		this.Width := width
		this.Height := height
	}
	
	loadFromConfiguration(configuration) {
		layout := string2Values(",", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Name, "Layout"), ""))
		
		if (layout.Length() > 1)
			this.iRowMargin := layout[2]
		
		if (layout.Length() > 2)
			this.iColumnMargin := layout[3]
		
		if (layout.Length() > 3)
			this.iSidesMargin := layout[4]
		
		if (layout.Length() > 4)
			this.iBottomMargin := layout[5]
		
		layout := string2Values("x", layout[1])
		
		this.Rows := layout[1]
		this.Columns := layout[2]
		
		rows := []
		
		Loop % this.Rows
			rows.Push(string2Values(";", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Name, A_Index), "")))
		
		this.iRowDefinitions := rows
	}
	
	computeLayout(ByRef rowHeights, ByRef columnWidths) {
		columnWidths := []
		rowHeights := []
		
		Loop % this.Columns
			columnWidths.Push(0)
		
		Loop % this.Rows
		{
			rowHeight := 0
		
			rowDefinition := this.RowDefinitions[A_Index]
			
			Loop % this.Columns
			{
				descriptor := rowDefinition[A_Index]
				
				if (StrLen(Trim(descriptor)) = 0)
					descriptor := "Empty.0"
				
				descriptor := string2Values(",", descriptor)
				
				if (descriptor.Length() > 1) {
					label := string2Values("x", getConfigurationValue(this.Configuration, "Labels", descriptor[2], ""))
					labelWidth := label[1]
					labelHeight := label[2]
				}
				else {
					labelWidth := 0
					labelHeight := 0
				}

				if (descriptor[1] = "Empty.0")
					descriptor := kEmptySpaceDescriptor
				else
					descriptor := getConfigurationValue(this.Configuration, "Controls"
													  , ConfigurationItem.splitDescriptor(descriptor[1])[1], "")
				
				descriptor := string2Values(";", descriptor)
				
				if (descriptor.Length() > 0) {
					descriptor := string2Values("x", descriptor[3])
					
					imageWidth := descriptor[1]
					imageHeight := descriptor[2]
				}
				else {
					imageWidth := 0
					imageHeight := 0
				}
				
				rowHeight := Max(rowHeight, imageHeight + ((labelHeight > 0) ? (this.kLabelMargin + labelHeight) : 0))
				
				columnWidths[A_Index] := Max(columnWidths[A_Index], Max(imageWidth, labelWidth))
			}
			
			rowHeights.Push(rowHeight)
		}
	}
	
	getControl(clickX, clickY, ByRef row, ByRef column, ByRef isEmpty) {
		local function
		
		rowHeights := false
		columnWidths := false
		
		this.computeLayout(rowHeights, columnWidths)
		
		height := 0
		Loop % rowHeights.Length()
			height += rowHeights[A_Index]
		
		width := 0
		Loop % columnWidths.Length()
			width += columnWidths[A_Index]
		
		height += ((rowHeights.Length() - 1) * this.RowMargin) + this.kHeaderHeight + this.BottomMargin
		width += ((columnWidths.Length() - 1) * this.ColumnMargin) + (2 * this.SidesMargin)
		
		vertical := this.kHeaderHeight
		
		Loop % this.Rows
		{
			row := A_Index
			
			rowHeight := rowHeights[A_Index]
			rowDefinition := this.RowDefinitions[A_Index]
		
			horizontal := this.SidesMargin
			
			Loop % this.Columns
			{
				column := A_Index
				
				columnWidth := columnWidths[A_Index]
			
				descriptor := rowDefinition[A_Index]
				
				if (StrLen(Trim(descriptor)) = 0) {
					descriptor := "Empty.0"
					
					isEmpty := true
				}
				else
					isEmpty := false
				
				descriptor := string2Values(",", descriptor)
				
				if (descriptor.Length() > 1) {
					label := string2Values("x", getConfigurationValue(this.Configuration, "Labels", descriptor[2], ""))
					labelWidth := label[1]
					labelHeight := label[2]
				}
				else {
					labelWidth := 0
					labelHeight := 0
				}
				
				if (descriptor[1] = "Empty.0") {
					descriptor := kEmptySpaceDescriptor
					name := "Empty"
					number := 0
				}
				else {
					descriptor := ConfigurationItem.splitDescriptor(descriptor[1])
					name := descriptor[1]
					number := descriptor[2]
				
					descriptor := getConfigurationValue(this.Configuration, "Controls", descriptor[1], "")
				}
				
				descriptor := string2Values(";", descriptor)
				
				if (descriptor.Length() > 0) {
					function := descriptor[1]
					image := substituteVariables(descriptor[2])
					
					descriptor := string2Values("x", descriptor[3])
					imageWidth := descriptor[1]
					imageHeight := descriptor[2]
					
					x := horizontal + Round((columnWidth - imageWidth) / 2)
					y := vertical + Round((rowHeight - (labelHeight + this.kLabelMargin) - imageHeight) / 2)
					
					if ((clickX >= x) && (clickX <= (x + imageWidth)) && (clickY >= y) && (clickY <= (y + imageHeight)))
						return ["Control", ConfigurationItem.descriptor(name, number)]
					
					if ((labelWidth > 0) && (labelHeight > 0)) {
						Gui %window%:Font, s8 Norm
				
						x := horizontal + Round((columnWidth - labelWidth) / 2)
						y := vertical + rowHeight - labelHeight
						
						if ((clickX >= x) && (clickX <= (x + labelWidth)) && (clickY >= y) && (clickY <= (y + labelHeight)))
							return ["Label", ConfigurationItem.descriptor(name, number)]
					}
				}
				
				horizontal += (columnWidth + this.ColumnMargin)
			}
		
			vertical += (rowHeight + this.RowMargin)
		}

		return false
	}
	
	getFunction(row, column) {
		if this.iFunctions.HasKey(row) {
			rowFunctions := this.iFunctions[row]
			
			if rowFunctions.HasKey(column)
				return rowFunctions[column]
		}
		
		return false
	}
	
	setLabel(row, column, text) {
		if this.iLabels.HasKey(row) {
			rowLabels := this.iLabels[row]
			
			if rowLabels.HasKey(column) {
				label := rowLabels[column]
				
				GuiControl Text, %label%, %text%
			}
		}
	}
	
	resetLabels() {
		local function
		
		Loop % this.Rows
		{
			row := A_Index
			
			Loop % this.Columns
			{
				function := this.getFunction(row, A_Index)
				
				if function
					this.setLabel(row, A_Index, ConfigurationItem.splitDescriptor(function)[2])
			}	
		}
	}
	
	controlClick(element, row, column, isEmpty) {
		local function
		
		handler := this.iControlClickHandler
		
		function := ConfigurationItem.splitDescriptor(element[2])
		
		for control, descriptor in getConfigurationSectionValues(this.Configuration, "Controls")
			if (control = function[1]) {
				function := ConfigurationItem.descriptor(string2Values(";", descriptor)[1], function[2])
				
				break
			}
			
		return %handler%(this, element, function, row, column, isEmpty)
	}
	
	openControlMenu(preview, element, function, row, column, isEmpty) {
		local count
		
		menuItem := (translate(element[1]) . translate(": ") . element[2] . " (" . row . " x " . column . ")")
		
		try {
			Menu GridElement, DeleteAll
		}
		catch exception {
			; ignore
		}
		
		window := this.Window
		
		Gui %window%:Default
		
		Menu GridElement, Add, %menuItem%, controlMenuIgnore
		Menu GridElement, Disable, %menuItem%
		Menu GridElement, Add
		
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
		
		for control, definition in ControlsList.Instance.getControls() {
			handler := ObjBindMethod(LayoutsList.Instance, "changeControl", row, column, control)
		
			Menu ControlMenu, Add, %control%, %handler%
		}
		
		if !isEmpty {
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
					
					count += 1
				}
			
				Menu NumberMenu, Add, %label%, :%menu%
			}
			
			label := translate("Number")
			Menu ControlMenu, Add, %label%, :NumberMenu
		}
		
		label := translate("Control")
		
		Menu GridElement, Add, %label%, :ControlMenu
		
		if !isEmpty {
			try {
				Menu LabelMenu, DeleteAll
			}
			catch exception {
				; ignore
			}
			
			label := translate("Empty")
			handler := ObjBindMethod(LayoutsList.Instance, "changeLabel", row, column, false)
			
			Menu LabelMenu, Add, %label%, %handler%
			Menu LabelMenu, Add
			
			for label, definition in LabelsList.Instance.getLabels() {
				handler := ObjBindMethod(LayoutsList.Instance, "changeLabel", row, column, label)
			
				Menu LabelMenu, Add, %label%, %handler%
			}
			
			label := translate("Label")
			
			Menu GridElement, Add, %label%, :LabelMenu
		}

		Menu GridElement, Show
	}
}

;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

buttonBoxContextMenu(guiHwnd, ctrlHwnd, eventInfo, isRightClick, x, y) {
	if (isRightClick && vControllerPreviews.HasKey(A_Gui))
		controlClick()
}