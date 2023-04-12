;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Button Box Preview              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Private Constant Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global kEmptySpaceDescriptor := "Button;" . kButtonBoxImagesDirectory . "Empty.png;52 x 52"


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
	iRowMargin := ButtonBoxPreview.kRowMargin
	iColumnMargin := ButtonBoxPreview.kColumnMargin
	iSidesMargin := ButtonBoxPreview.kSidesMargin
	iBottomMargin := ButtonBoxPreview.kBottomMargin

	iRowDefinitions := []

	iFunctions := CaseInsenseMap()
	iLabels := CaseInsenseMap()

	Type {
		Get {
			return "Button Box"
		}
	}

	RowMargin {
		Get {
			return this.iRowMargin
		}
	}

	ColumnMargin {
		Get {
			return this.iColumnMargin
		}
	}

	SidesMargin {
		Get {
			return this.iSidesMargin
		}
	}

	BottomMargin {
		Get {
			return this.iBottomMargin
		}
	}

	RowDefinitions[row?] {
		Get {
			return (isSet(row) ? this.iRowDefinitions[row] : this.iRowDefinitions)
		}
	}

	createGui(configuration) {
		local rowHeights := false
		local columnWidths := false
		local function, height, width, buttonBoxGui, vertical, row, rowHeight, rowDefinition
		local horizontal, column, columnWidth, descriptor, label, labelWidth, labelHeight, descriptor, number
		local image, imageWidth, imageHeight, x, y, labelHandle

		contextMenu(window, control, item, isRightClick, x, y) {
			if (isRightClick && (window = buttonBoxGui))
				controlClick(window)
		}

		this.computeLayout(&rowHeights, &columnWidths)

		height := 0

		loop rowHeights.Length
			height += rowHeights[A_Index]

		width := 0

		loop columnWidths.Length
			width += columnWidths[A_Index]

		height += ((rowHeights.Length - 1) * this.RowMargin) + ButtonBoxPreview.kHeaderHeight + this.BottomMargin
		width += ((columnWidths.Length - 1) * this.ColumnMargin) + (2 * this.SidesMargin)

		buttonBoxGui := Window()

		this.Window := buttonBoxGui

		buttonBoxGui.OnEvent("ContextMenu", contextMenu)

		buttonBoxGui.Add("Picture", "x-10 y-10", kButtonBoxImagesDirectory . "Photorealistic\CF Background.png")

		buttonBoxGui.SetFont("s12 Bold cSilver")
		buttonBoxGui.Add("Text", "x0 y8 w" . width . " h23 +0x200 +0x1 BackgroundTrans", translate("Modular Simulator Controller System"))
		buttonBoxGui.SetFont("s10 cSilver")
		buttonBoxGui.Add("Text", "x0 y28 w" . width . " h23 +0x200 +0x1 BackgroundTrans", this.Name)
		buttonBoxGui.BackColor := "0x000000"
		buttonBoxGui.SetFont("s8 Norm", "Arial")

		vertical := ButtonBoxPreview.kHeaderHeight

		loop this.Rows {
			row := A_Index

			rowHeight := rowHeights[A_Index]
			rowDefinition := this.RowDefinitions[A_Index]

			horizontal := this.SidesMargin

			loop this.Columns {
				column := A_Index

				columnWidth := columnWidths[A_Index]

				descriptor := rowDefinition[A_Index]

				if (StrLen(Trim(descriptor)) = 0)
					descriptor := "Empty.0"

				descriptor := string2Values(",", descriptor)

				if (descriptor.Length > 1) {
					label := string2Values("x", getMultiMapValue(this.Configuration, "Labels", descriptor[2], ""))
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
					descriptor := getMultiMapValue(this.Configuration, "Controls", descriptor[1], "")
				}

				descriptor := string2Values(";", descriptor)

				if (descriptor.Length > 0) {
					function := descriptor[1]
					image := substituteVariables(descriptor[2])

					descriptor := string2Values("x", descriptor[3])
					imageWidth := descriptor[1]
					imageHeight := descriptor[2]

					function := ConfigurationItem.descriptor(function, number)

					if !this.iFunctions.Has(row)
						this.iFunctions[row] := CaseInsenseMap()

					this.iFunctions[row][column] := function

					x := horizontal + Round((columnWidth - imageWidth) / 2)
					y := vertical + Round((rowHeight - (labelHeight + ButtonBoxPreview.kLabelMargin) - imageHeight) / 2)

					buttonBoxGui.Add("Picture", "x" . x . " y" . y . " w" . imageWidth . " h" . imageHeight . " BackgroundTrans", image).OnEvent("Click", controlClick.Bind(buttonBoxGui))

					if ((labelWidth > 0) && (labelHeight > 0)) {
						buttonBoxGui.SetFont("s8 Norm cBlack")

						x := horizontal + Round((columnWidth - labelWidth) / 2)
						y := vertical + rowHeight - labelHeight

						label := buttonBoxGui.Add("Text", "x" . x . " y" . y . " w" . labelWidth . " h" . labelHeight . " +Border -Background +0x1000 +0x1", number)
						label.OnEvent("Click", controlClick.Bind(buttonBoxGui))

						if !this.iLabels.Has(row)
							this.iLabels[row] := CaseInsenseMap()

						this.iLabels[row][column] := label
					}
				}

				horizontal += (columnWidth + this.ColumnMargin)
			}

			vertical += (rowHeight + this.RowMargin)
		}

		this.Width := width
		this.Height := height
	}

	createBackground(configuration) {
		local control := this.Window.Add("Picture", "x-10 y-10 0x4000000", kButtonBoxImagesDirectory . "Photorealistic\CF Background.png")
		local previewMover := this.PreviewManager.getPreviewMover()

		if previewMover {
			move(*) {
				previewMover.Call(this.Window)
			}

			control.OnEvent("Click", move)
		}
	}

	loadFromConfiguration(configuration) {
		local layout := string2Values(",", getMultiMapValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Name, "Layout"), ""))
		local rows := []
		local columns

		if (layout.Length > 1)
			this.iRowMargin := layout[2]

		if (layout.Length > 2)
			this.iColumnMargin := layout[3]

		if (layout.Length > 3)
			this.iSidesMargin := layout[4]

		if (layout.Length > 4)
			this.iBottomMargin := layout[5]

		layout := string2Values("x", layout[1])

		this.Rows := layout[1]
		this.Columns := layout[2]

		loop this.Rows
			rows.Push(string2Values(";", getMultiMapValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Name, A_Index), ""), false, SafeArray))

		this.iRowDefinitions := rows
	}

	computeLayout(&rowHeights, &columnWidths) {
		local rowHeight, rowDefinition, descriptor, label, labelWidth, labelHeight, imageWidth, imageHeight

		rowHeights := []
		columnWidths := []

		loop this.Columns
			columnWidths.Push(0)

		loop this.Rows {
			rowHeight := 0

			rowDefinition := this.RowDefinitions[A_Index]

			loop this.Columns {
				descriptor := rowDefinition[A_Index]

				if (StrLen(Trim(descriptor)) = 0)
					descriptor := "Empty.0"

				descriptor := string2Values(",", descriptor)

				if (descriptor.Length > 1) {
					label := string2Values("x", getMultiMapValue(this.Configuration, "Labels", descriptor[2], ""))
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
					descriptor := getMultiMapValue(this.Configuration, "Controls"
												 , ConfigurationItem.splitDescriptor(descriptor[1])[1], "")

				descriptor := string2Values(";", descriptor)

				if (descriptor.Length > 0) {
					descriptor := string2Values("x", descriptor[3])

					imageWidth := descriptor[1]
					imageHeight := descriptor[2]
				}
				else {
					imageWidth := 0
					imageHeight := 0
				}

				rowHeight := Max(rowHeight, imageHeight + ((labelHeight > 0) ? (ButtonBoxPreview.kLabelMargin + labelHeight) : 0))

				columnWidths[A_Index] := Max(columnWidths[A_Index], Max(imageWidth, labelWidth))
			}

			rowHeights.Push(rowHeight)
		}
	}

	getControl(clickX, clickY, &row, &column, &isEmpty) {
		local rowHeights := false
		local columnWidths := false
		local function, height, width, vertical, horizontal, rowHeight, rowDefinition, columnWidth
		local descriptor, name, number, image, imageWidth, imageHeight, x, y, labelHeight, label, labelWidth

		this.computeLayout(&rowHeights, &columnWidths)

		height := 0

		loop rowHeights.Length
			height += rowHeights[A_Index]

		width := 0

		loop columnWidths.Length
			width += columnWidths[A_Index]

		height += ((rowHeights.Length - 1) * this.RowMargin) + ButtonBoxPreview.kHeaderHeight + this.BottomMargin
		width += ((columnWidths.Length - 1) * this.ColumnMargin) + (2 * this.SidesMargin)

		vertical := ButtonBoxPreview.kHeaderHeight

		loop this.Rows {
			row := A_Index

			rowHeight := rowHeights[A_Index]
			rowDefinition := this.RowDefinitions[A_Index]

			horizontal := this.SidesMargin

			loop this.Columns {
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

				if (descriptor.Length > 1) {
					label := string2Values("x", getMultiMapValue(this.Configuration, "Labels", descriptor[2], ""))
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
					descriptor := getMultiMapValue(this.Configuration, "Controls", descriptor[1], "")
				}

				descriptor := string2Values(";", descriptor)

				if (descriptor.Length > 0) {
					function := descriptor[1]
					image := substituteVariables(descriptor[2])

					descriptor := string2Values("x", descriptor[3])
					imageWidth := descriptor[1]
					imageHeight := descriptor[2]

					x := horizontal + Round((columnWidth - imageWidth) / 2)
					y := vertical + Round((rowHeight - (labelHeight + ButtonBoxPreview.kLabelMargin) - imageHeight) / 2)

					if ((clickX >= x) && (clickX <= (x + imageWidth)) && (clickY >= y) && (clickY <= (y + imageHeight)))
						return ["Control", ConfigurationItem.descriptor(name, number)]

					if ((labelWidth > 0) && (labelHeight > 0)) {
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
		local rowFunctions

		if this.iFunctions.Has(row) {
			rowFunctions := this.iFunctions[row]

			if rowFunctions.Has(column)
				return rowFunctions[column]
		}

		return false
	}

	setLabel(row, column, text) {
		local rowLabels, label

		if this.iLabels.Has(row) {
			rowLabels := this.iLabels[row]

			if rowLabels.Has(column)
				rowLabels[column].Text := text
		}
	}

	controlClick(element, row, column, isEmpty) {
		local function := ConfigurationItem.splitDescriptor(element[2])
		local control, descriptor

		for control, descriptor in getMultiMapValues(this.Configuration, "Controls")
			if (control = function[1]) {
				function := ConfigurationItem.descriptor(string2Values(";", descriptor)[1], function[2])

				break
			}

		return this.iControlClickHandler.Call(this, element, function, row, column, isEmpty)
	}

	openControlMenu(preview, element, function, row, column, isEmpty) {
		local count, mainMenu, controlMenu, numberMenu, subMenu, labelMenu, menuItem, window, label, control, definition

		changeControl(control, argument := false, *) {
			this.PreviewManager.changeControl(row, column, control, argument)
		}

		changeLabel(label, *) {
			this.PreviewManager.changeLabel(row, column, label)
		}

		if (GetKeyState("Ctrl", "P") && !isEmpty)
			this.PreviewManager.changeControl(row, column, "__Number__", false)
		else {
			menuItem := (translate(element[1]) . translate(": ") . StrReplace(element[2], "`n", A_Space) . " (" . row . " x " . column . ")")

			mainMenu := Menu()

			window := this.Window

			mainMenu.Add(menuItem, (*) => {})
			mainMenu.Disable(menuItem)
			mainMenu.Add()

			controlMenu := Menu()

			controlMenu.Add(translate("Empty"), changeControl.Bind(false))
			controlMenu.Add()

			for control, definition in ControlsList.Instance.getControls() {
				controlMenu.Add(control, changeControl.Bind(control))

				if (control = ConfigurationItem.splitDescriptor(element[2])[1])
					controlMenu.Check(control)
			}

			if !isEmpty {
				controlMenu.Add()

				numberMenu := Menu()

				numberMenu.Add(translate("Input..."), changeControl.Bind("__Number__", false))
				numberMenu.Add()

				count := 1

				loop 4 {
					label := (count . " - " . (count + 9))

					subMenu := Menu()

					loop 10 {
						subMenu.Add(count, changeControl.Bind("__Number__", count))

						if (count = ConfigurationItem.splitDescriptor(element[2])[2])
							subMenu.Check(count)

						count += 1
					}

					numberMenu.Add(label, subMenu)
				}

				controlMenu.Add(translate("Number"), numberMenu)
			}

			mainMenu.Add(translate("Control"), controlMenu)

			if !isEmpty {
				labelMenu := Menu()

				labelMenu.Add(translate("Empty"), changeLabel.Bind(false))
				labelMenu.Add()

				for label, definition in LabelsList.Instance.getLabels()
					labelMenu.Add(label, changeLabel.Bind(label))

				mainMenu.Add(translate("Label"), labelMenu)
			}

			mainMenu.Show()
		}
	}
}