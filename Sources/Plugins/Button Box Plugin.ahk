;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Button Box Plugin               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                        Private Variable Section                         ;;;
;;;-------------------------------------------------------------------------;;;

global bbControl1
global bbControl2
global bbControl3
global bbControl4
global bbControl5
global bbControl6
global bbControl7
global bbControl8
global bbControl9
global bbControl10
global bbControl11
global bbControl12
global bbControl13
global bbControl14
global bbControl15
global bbControl16
global bbControl17
global bbControl18
global bbControl19
global bbControl20
global bbControl21
global bbControl22
global bbControl23
global bbControl24
global bbControl25
global bbControl26
global bbControl27
global bbControl28
global bbControl29
global bbControl30
global bbControl31
global bbControl32
global bbControl33
global bbControl34
global bbControl35
global bbControl36
global bbControl37
global bbControl38
global bbControl39
global bbControl40
global bbControl41
global bbControl42
global bbControl43
global bbControl44
global bbControl45
global bbControl46
global bbControl47
global bbControl48
global bbControl49
global bbControl50


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class ButtonBox extends GuiFunctionController {
	Type[] {
		Get {
			return "Button Box"
		}
	}

	findButtonBox(window) {
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

	static sWindowCounter := 1
	static sHandleCounter := 1

	iName := false
	iLayout := false

	iRows := 0
	iColumns := 0
	iRowMargin := this.kRowMargin
	iColumnMargin := this.kColumnMargin
	iSidesMargin := this.kSidesMargin
	iBottomMargin := this.kBottomMargin

	iRowDefinitions := []
	iControls := {}

	Descriptor[] {
		Get {
			return this.Name
		}
	}

	Name[] {
		Get {
			return this.iName
		}
	}

	Layout[] {
		Get {
			return this.iLayout
		}
	}

	Rows[] {
		Get {
			return this.iRows
		}
	}

	Columns[] {
		Get {
			return this.iColumns
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

	__New(name, layout, controller, configuration) {
		this.iName := name
		this.iLayout := layout

		base.__New(controller, configuration)
	}

	loadFromConfiguration(configuration) {
		local layout, rows

		base.loadFromConfiguration(configuration)

		layout := string2Values(",", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Layout, "Layout"), ""))

		if (layout.Length() > 1)
			this.iRowMargin := layout[2]

		if (layout.Length() > 2)
			this.iColumnMargin := layout[3]

		if (layout.Length() > 3)
			this.iSidesMargin := layout[4]

		if (layout.Length() > 4)
			this.iBottomMargin := layout[5]

		layout := string2Values("x", layout[1])

		this.iRows := layout[1]
		this.iColumns := layout[2]

		rows := []

		loop % this.Rows
			rows.Push(string2Values(";", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Layout, A_Index), "")))

		this.iRowDefinitions := rows
	}

	createGui() {
		local window := "bbWindow" . GridButtonBox.sWindowCounter++
		local num1WayToggles := 0
		local num2WayToggles := 0
		local numButtons := 0
		local numDials := 0
		local rowHeights := false
		local columnWidths := false
		local function, height, width, vertical, rowHeight, columnWidth, rowDefinition, horizontal, vertical
		local descriptor, label, labelWidth, labelHeight, number, image, imageWidth, imageHeight
		local x, y, variable

		this.computeLayout(rowHeights, columnWidths)

		height := 0

		loop % rowHeights.Length()
			height += rowHeights[A_Index]

		width := 0

		loop % columnWidths.Length()
			width += columnWidths[A_Index]

		height += ((rowHeights.Length() - 1) * this.RowMargin) + this.kHeaderHeight + this.BottomMargin
		width += ((columnWidths.Length() - 1) * this.ColumnMargin) + (2 * this.SidesMargin)

		Gui %window%:-Border -Caption +AlwaysOnTop

		Gui %window%:Add, Picture, x-10 y-10, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"

		Gui %window%:Font, s12 Bold cSilver
		Gui %window%:Add, Text, x0 y8 w%width% h23 +0x200 +0x1 BackgroundTrans gmoveButtonBox, % translate("Modular Simulator Controller System")
		Gui %window%:Font, s10 cSilver
		Gui %window%:Add, Text, x0 y28 w%width% h23 +0x200 +0x1 BackgroundTrans gmoveButtonBox, % translate(this.Name)
		Gui %window%:Color, 0x000000
		Gui %window%:Font, s8 Norm, Arial

		vertical := this.kHeaderHeight

		loop % this.Rows
		{
			rowHeight := rowHeights[A_Index]
			rowDefinition := this.RowDefinitions[A_Index]

			horizontal := this.SidesMargin

			loop % this.Columns
			{
				columnWidth := columnWidths[A_Index]
				descriptor := rowDefinition[A_Index]

				if (StrLen(descriptor) > 0) {
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

					descriptor := ConfigurationItem.splitDescriptor(descriptor[1])
					number := descriptor[2]

					descriptor := string2Values(";", getConfigurationValue(this.Configuration, "Controls", descriptor[1], ""))

					if (descriptor.Length() > 0) {
						function := descriptor[1]
						image := substituteVariables(descriptor[2])

						descriptor := string2Values("x", descriptor[3])
						imageWidth := descriptor[1]
						imageHeight := descriptor[2]

						switch function {
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
						y := vertical + Round((rowHeight - (labelHeight + this.kLabelMargin) - imageHeight) / 2)

						variable := "bbControl" + GridButtonBox.sHandleCounter++

						Gui %window%:Add, Picture, x%x% y%y% w%imageWidth% h%imageHeight% BackgroundTrans v%variable% gcontrolEvent, %image%

						this.registerControl(variable, function, x, y, imageWidth, imageHeight)

						if ((labelWidth > 0) && (labelHeight > 0)) {
							Gui %window%:Font, s8 Norm

							x := horizontal + Round((columnWidth - labelWidth) / 2)
							y := vertical + rowHeight - labelHeight

							Gui %window%:Add, Text, x%x% y%y% w%labelWidth% h%labelHeight% Hwnd%variable% +Border -Background  +0x1000 +0x1

							this.registerControlHandle(function, %variable%)
						}
					}
				}

				horizontal += (columnWidth + this.ColumnMargin)
			}

			vertical += (rowHeight + this.RowMargin)
		}

		Gui %window%:Add, Picture, x-10 y-10 gmoveButtonBox 0x4000000, % kButtonBoxImagesDirectory . "Photorealistic\CF Background.png"
		Gui %window%:+AlwaysOnTop

		this.associateGui(window, width, height, num1WayToggles, num2WayToggles, numButtons, numDials)
	}

	computeLayout(ByRef rowHeights, ByRef columnWidths) {
		local rowHeight, rowDefinition, descriptor, label, labelWidth, labelHeight, descriptor
		local imageHeight, imageWidth, columnWidth

		columnWidths := []
		rowHeights := []

		loop % this.Columns
			columnWidths.Push(0)

		loop % this.Rows
		{
			rowHeight := 0

			rowDefinition := this.RowDefinitions[A_Index]

			loop % this.Columns
			{
				descriptor := rowDefinition[A_Index]

				if (StrLen(descriptor) > 0) {
					descriptor := string2Values(",", descriptor)

					if (descriptor.Length() > 1) {
						label := getConfigurationValue(this.Configuration, "Labels", descriptor[2], "")
						label := string2Values("x", label)
						labelWidth := label[1]
						labelHeight := label[2]
					}
					else {
						labelWidth := 0
						labelHeight := 0
					}

					descriptor := string2Values(";", getConfigurationValue(this.Configuration, "Controls", ConfigurationItem.splitDescriptor(descriptor[1])[1], ""))

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
			}

			rowHeights.Push(rowHeight)
		}
	}

	registerControl(variable, function, x, y, width, height) {
		this.iControls[variable] := Array(function, x, y, width, height)
	}

	findControl(variable) {
		if this.iControls.HasKey(variable)
			return this.iControls[variable]
		else
			return false
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

controlEvent() {
	local function, x, y, descriptor

	MouseGetPos x, y

	function := ButtonBox.findButtonBox(A_Gui).findControl(A_GuiControl)

	if function {
		MouseGetPos x, y

		descriptor := ConfigurationItem.splitDescriptor(function[1])

		switch descriptor[1] {
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

moveButtonBox() {
	ButtonBox.findButtonBox(A_Gui).moveByMouse(A_Gui)
}

initializeButtonBoxPlugin() {
	local controller := SimulatorController.Instance
	local configuration := readConfiguration(getFileName("Button Box Configuration.ini", kUserConfigDirectory, kConfigDirectory))
	local ignore, btnBox

	for ignore, btnBox in string2Values("|", getConfigurationValue(controller.Configuration, "Controller Layouts", "Button Boxes", "")) {
		btnBox := string2Values(":", btnBox)

		if getConfigurationValue(configuration, "Layouts", btnBox[2] . ".Visible", true)
			new GridButtonBox(btnBox[1], btnBox[2], controller, configuration)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeButtonBoxPlugin()