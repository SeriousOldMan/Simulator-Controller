;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Button Box Plugin               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ButtonBox extends GuiFunctionController {
	Type {
		Get {
			return "Button Box"
		}
	}

	static findButtonBox(window) {
		return GuiFunctionController.findFunctionController(window)
	}
}

class GridButtonBox extends ButtonBox {
	static kHeaderHeight := 70
	static kLabelMargin := 5

	static kRowMargin := 20
	static kColumnMargin := 40

	static kSidesMargin := 20
	static kBottomMargin := 15

	iName := false
	iLayout := false

	iRows := 0
	iColumns := 0
	iRowMargin := GridButtonBox.kRowMargin
	iColumnMargin := GridButtonBox.kColumnMargin
	iSidesMargin := GridButtonBox.kSidesMargin
	iBottomMargin := GridButtonBox.kBottomMargin

	iRowDefinitions := []
	iControls := CaseInsenseMap()

	Descriptor {
		Get {
			return this.Name
		}
	}

	Name {
		Get {
			return this.iName
		}
	}

	Layout {
		Get {
			return this.iLayout
		}
	}

	Rows {
		Get {
			return this.iRows
		}
	}

	Columns {
		Get {
			return this.iColumns
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

	__New(name, layout, controller, configuration) {
		this.iName := name
		this.iLayout := layout

		super.__New(controller, configuration)
	}

	loadFromConfiguration(configuration) {
		local layout, rows

		super.loadFromConfiguration(configuration)

		layout := string2Values(",", getMultiMapValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Layout, "Layout"), ""))

		if (layout.Length > 1)
			this.iRowMargin := layout[2]

		if (layout.Length > 2)
			this.iColumnMargin := layout[3]

		if (layout.Length > 3)
			this.iSidesMargin := layout[4]

		if (layout.Length > 4)
			this.iBottomMargin := layout[5]

		layout := string2Values("x", layout[1])

		this.iRows := layout[1]
		this.iColumns := layout[2]

		rows := []

		loop this.Rows
			rows.Push(string2Values(";", getMultiMapValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Layout, A_Index), ""), false, WeakArray))

		this.iRowDefinitions := rows
	}

	createGui() {
		local buttonBoxGui, control
		local num1WayToggles := 0
		local num2WayToggles := 0
		local numButtons := 0
		local numDials := 0
		local rowHeights := false
		local columnWidths := false
		local function, height, width, vertical, rowHeight, columnWidth, rowDefinition, horizontal, vertical
		local descriptor, label, labelWidth, labelHeight, number, image, imageWidth, imageHeight
		local x, y, variable

		moveButtonBox(buttonBoxGui, *) {
			ButtonBox.findButtonBox(buttonBoxGui).moveByMouse(buttonBoxGui)
		}

		this.computeLayout(&rowHeights, &columnWidths)

		height := 0

		loop rowHeights.Length
			height += rowHeights[A_Index]

		width := 0

		loop columnWidths.Length
			width += columnWidths[A_Index]

		height += ((rowHeights.Length - 1) * this.RowMargin) + GridButtonBox.kHeaderHeight + this.BottomMargin
		width += ((columnWidths.Length - 1) * this.ColumnMargin) + (2 * this.SidesMargin)

		buttonBoxGui := Window({Options: "-0x800000"})

		buttonBoxGui.Add("Picture", "x-10 y-10", kButtonBoxImagesDirectory . "Photorealistic\CF Background.png")

		buttonBoxGui.SetFont("s12 Bold cSilver")

		buttonBoxGui.Add("Text", "x0 y8 w" . width . " h23 +0x200 +0x1 BackgroundTrans", translate("Modular Simulator Controller System")).OnEvent("Click", moveButtonBox.Bind(buttonBoxGui))

		buttonBoxGui.SetFont("s10 cSilver")

		buttonBoxGui.Add("Text", "x0 y28 w" . width . " h23 +0x200 +0x1 BackgroundTrans", translate(this.Name)).OnEvent("Click", moveButtonBox.Bind(buttonBoxGui))

		buttonBoxGui.BackColor := "0x000000"
		buttonBoxGui.SetFont("s8 Norm", "Arial")

		vertical := GridButtonBox.kHeaderHeight

		loop this.Rows {
			rowHeight := rowHeights[A_Index]
			rowDefinition := this.RowDefinitions[A_Index]

			horizontal := this.SidesMargin

			loop this.Columns {
				columnWidth := columnWidths[A_Index]
				descriptor := rowDefinition[A_Index]

				if (StrLen(descriptor) > 0) {
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

					descriptor := ConfigurationItem.splitDescriptor(descriptor[1])
					number := descriptor[2]

					descriptor := string2Values(";", getMultiMapValue(this.Configuration, "Controls", descriptor[1], ""))

					if (descriptor.Length > 0) {
						function := descriptor[1]
						image := substituteVariables(descriptor[2])

						descriptor := string2Values("x", descriptor[3])
						imageWidth := descriptor[1]
						imageHeight := descriptor[2]

						switch function, false {
							case k1WayToggleType:
								num1WayToggles += 1
							case k2WayToggleType:
								num2WayToggles += 1
							case kButtonType:
								numButtons += 1
							case kDialType:
								numDials += 1
							default:
								throw "Unknown function type (" . function . ") detected in GrindButtonBox.createGui..."
						}

						function := ConfigurationItem.descriptor(function, number)

						x := horizontal + Round((columnWidth - imageWidth) / 2)
						y := vertical + Round((rowHeight - (labelHeight + GridButtonBox.kLabelMargin) - imageHeight) / 2)

						control := buttonBoxGui.Add("Picture", "x" . x . " y" . y . " w" . imageWidth . " h" . imageHeight . " BackgroundTrans", image)
						control.OnEvent("Click", controlEvent.Bind(buttonBoxGui, control))

						this.registerControl(control, function, x, y, imageWidth, imageHeight)

						if ((labelWidth > 0) && (labelHeight > 0)) {
							buttonBoxGui.SetFont("s8 Norm")

							x := horizontal + Round((columnWidth - labelWidth) / 2)
							y := vertical + rowHeight - labelHeight

							control := buttonBoxGui.Add("Text", "x" . x . " y" . y . " w" . labelWidth . " h" . labelHeight . " +Border -Background  +0x1000 +0x1")

							this.registerControlLabel(function, control)
						}
					}
				}

				horizontal += (columnWidth + this.ColumnMargin)
			}

			vertical += (rowHeight + this.RowMargin)
		}

		buttonBoxGui.Add("Picture", "x-10 y-10  0x4000000", kButtonBoxImagesDirectory . "Photorealistic\CF Background.png").OnEvent("Click", moveButtonBox.Bind(buttonBoxGui))
		buttonBoxGui.Opt("+AlwaysOnTop")

		this.associateGui(buttonBoxGui, width, height, num1WayToggles, num2WayToggles, numButtons, numDials)
	}

	computeLayout(&rowHeights, &columnWidths) {
		local rowHeight, rowDefinition, descriptor, label, labelWidth, labelHeight, descriptor
		local imageHeight, imageWidth, columnWidth

		columnWidths := []
		rowHeights := []

		loop this.Columns
			columnWidths.Push(0)

		loop this.Rows {
			rowHeight := 0

			rowDefinition := this.RowDefinitions[A_Index]

			loop this.Columns {
				descriptor := rowDefinition[A_Index]

				if (StrLen(descriptor) > 0) {
					descriptor := string2Values(",", descriptor)

					if (descriptor.Length > 1) {
						label := getMultiMapValue(this.Configuration, "Labels", descriptor[2], "")
						label := string2Values("x", label)
						labelWidth := label[1]
						labelHeight := label[2]
					}
					else {
						labelWidth := 0
						labelHeight := 0
					}

					descriptor := string2Values(";", getMultiMapValue(this.Configuration, "Controls", ConfigurationItem.splitDescriptor(descriptor[1])[1], ""))

					if (descriptor.Length > 0) {
						descriptor := string2Values("x", descriptor[3])

						imageWidth := descriptor[1]
						imageHeight := descriptor[2]
					}
					else {
						imageWidth := 0
						imageHeight := 0
					}

					rowHeight := Max(rowHeight, imageHeight + ((labelHeight > 0) ? (GridButtonBox.kLabelMargin + labelHeight) : 0))

					columnWidths[A_Index] := Max(columnWidths[A_Index], Max(imageWidth, labelWidth))
				}
			}

			rowHeights.Push(rowHeight)
		}
	}

	registerControl(control, function, x, y, width, height) {
		this.iControls[control] := Array(function, x, y, width, height)
	}

	findControl(variable) {
		if this.iControls.Has(variable)
			return this.iControls[variable]
		else
			return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

controlEvent(window, control, *) {
	local function, x, y, descriptor

	MouseGetPos(&x, &y)
			
	x := screen2Window(x)
	y := screen2Window(y)

	function := ButtonBox.findButtonBox(window).findControl(control)

	if function {
		MouseGetPos(&x, &y)
			
		x := screen2Window(x)
		y := screen2Window(y)

		descriptor := ConfigurationItem.splitDescriptor(function[1])

		switch descriptor[1], false {
			case kButtonType:
				pushButton(descriptor[2])
			case kDialType:
				rotateDial(descriptor[2], (x > (function[2] + Round(function[4] / 2))) ? "Increase" : "Decrease")
			case k1WayToggleType, k2WayToggleType:
				switchToggle(descriptor[1], descriptor[2], (y > (function[3] + Round(function[5] / 2))) ? "Off" : "On")
			default:
				throw "Unknown function type (" . descriptor[1] . ") detected in controlEvent..."
		}
	}
}

initializeButtonBoxPlugin() {
	local controller := SimulatorController.Instance
	local configuration := readMultiMap(getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory))
	local ignore, btnBox

	for ignore, btnBox in string2Values("|", getMultiMapValue(controller.Configuration, "Controller Layouts", "Button Boxes", "")) {
		btnBox := string2Values(":", btnBox)

		if getMultiMapValue(configuration, "Layouts", btnBox[2] . ".Visible", true)
			GridButtonBox(btnBox[1], btnBox[2], controller, configuration)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeButtonBoxPlugin()