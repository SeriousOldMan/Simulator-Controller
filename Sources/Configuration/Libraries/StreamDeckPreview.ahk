;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Stream Deck Preview             ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2023) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Public Constants Section                        ;;;
;;;-------------------------------------------------------------------------;;;

global kIcon := "Icon"
global kLabel := "Label"
global kIconAndLabel := "IconAndLabel"
global kIconOrLabel := "IconOrLabel"


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
	static kPlusWidth := 325
	static kPlusHeight := 205

	static kTopMargin := 50
	static kLeftMargin := CaseInsenseMap("Mini", 38, "Standard", 44, "XL", 44, "Plus", 44)

	static kButtonWidth := 50
	static kButtonHeight := 50

	static kRowMargin := 13
	static kColumnMargin := 13

	iSize := "Standard"

	iButtons := CaseInsenseMap()
	iLabels := CaseInsenseMap()
	iIcons := CaseInsenseMap()

	Type {
		Get {
			return "Stream Deck"
		}
	}

	Size {
		Get {
			return this.iSize
		}
	}

	loadFromConfiguration(configuration) {
		local layout := getMultiMapValue(configuration, "Layouts", this.Name . ".Layout", "Standard")
		local row, columns, column, button, icon, label, mode

		switch layout, false {
			case "Mini":
				layout := [2, 3]
			case "Standard":
				layout := [3, 5]
			case "XL":
				layout := [4, 8]
			case "Plus":
				layout := [2, 4]
			default:
				layout := string2Values("x", layout)
		}

		if ((layout[1] = 2) && (layout[2] = 3)) {
			this.Width := StreamDeckPreview.kMiniWidth
			this.Height := StreamDeckPreview.kMiniHeight

			this.iSize := "Mini"
		}
		else if (layout[1] = 3) {
			this.Width := StreamDeckPreview.kStandardWidth
			this.Height := StreamDeckPreview.kStandardHeight

			this.iSize := "Standard"
		}
		else if (layout[1] = 4) {
			this.Width := StreamDeckPreview.kXLWidth
			this.Height := StreamDeckPreview.kXLHeight

			this.iSize := "XL"
		}
		else {
			this.Width := StreamDeckPreview.kPlusWidth
			this.Height := StreamDeckPreview.kPlusHeight

			this.iSize := "Plus"
		}

		this.Rows := layout[1]
		this.Columns := layout[2]

		loop this.Rows {
			row := A_Index

			this.iButtons[row] := CaseInsenseMap()

			loop this.Columns {
				column := A_Index

				button := string2Values(";", getMultiMapValue(this.Configuration, "Layouts", this.Name . "." . row), false, WeakArray)[column]

				if (button && (button != "")) {
					icon := getMultiMapValue(this.Configuration, "Buttons", this.Name . "." . button . ".Icon", true)
					label := getMultiMapValue(this.Configuration, "Buttons", this.Name . "." . button . ".Label", true)
					mode := getMultiMapValue(this.Configuration, "Buttons", this.Name . "." . button . ".Mode", kIconOrLabel)

					this.iButtons[row][column] := {Button: ConfigurationItem.splitDescriptor(button)[2], Icon: icon, Label: label, Mode: mode}
				}
				else
					this.iButtons[row][column] := false
			}
		}
	}

	createGui(configuration) {
		local row := 0
		local column := 0
		local isEmpty := true
		local y := StreamDeckPreview.kTopMargin
		local x, column, posX, posY, streamDeckGui

		contextMenu(window, control, item, isRightClick, x, y) {
			if (isRightClick && (window = streamDeckGui))
				controlClick(window)
		}

		streamDeckGui := Window()

		this.Window := streamDeckGui

		streamDeckGui.OnEvent("ContextMenu", contextMenu)

		streamDeckGui.Add("Picture", "x0 y0", (kStreamDeckImagesDirectory . "Stream Deck " . this.Size . ".jpg"))

		streamDeckGui.BackColor := "0x000000"
		streamDeckGui.SetFont("s8 Norm", "Arial")

		streamDeckGui.SetFont("cWhite")

		loop this.Rows {
			this.iLabels[A_Index] := CaseInsenseMap()
			this.iIcons[A_Index] := CaseInsenseMap()

			row := A_Index

			x := StreamDeckPreview.kLeftMargin[this.Size]

			loop this.Columns {
				column := A_Index

				posX := (x + 3)
				posY := (y + 3)

				this.iIcons[row][column] := streamDeckGui.Add("Picture", "x" . posX . " y" . posY . " w44 h44 BackgroundTrans")
				this.iLabels[row][column] := streamDeckGui.Add("Text", "x" . posX . " y" . posY . " w44 h44 Center BackgroundTrans")
				this.iLabels[row][column].OnEvent("Click", controlClick.Bind(streamDeckGui))

				x += (StreamDeckPreview.kColumnMargin + StreamDeckPreview.kButtonWidth)
			}

			y += (StreamDeckPreview.kRowMargin + StreamDeckPreview.kButtonHeight)
		}

		this.updateButtons()
	}

	createBackground(configuration) {
		local control := this.Window.Add("Picture", "x0 y0 0x4000000", (kStreamDeckImagesDirectory . "Stream Deck " . this.Size . ".jpg"))
		local previewMover := this.PreviewManager.getPreviewMover()

		if previewMover {
			move(*) {
				previewMover.Call(this.Window)
			}

			control.OnEvent("Click", move)
		}
	}

	getButton(row, column) {
		return this.iButtons[row][column]
	}

	setButton(row, column, descriptor) {
		this.iButtons[row][column] := descriptor
	}

	getLabel(row, column) {
		local button := this.getButton(row, column)

		return (button ? button.Label : true)
	}

	getIcon(row, column) {
		local button := this.getButton(row, column)

		return (button ? button.Icon : true)
	}

	getMode(row, column) {
		local button := this.getButton(row, column)

		return (button ? button.Mode : false)
	}

	updateButtons() {
		local row, column, button, label, icon

		loop this.Rows {
			row := A_Index

			loop this.Columns {
				column := A_Index

				button := this.getButton(row, column)

				if button {
					label := this.getLabel(row, column)

					this.iLabels[row][column].Text := button.Button . ((label && (label != true)) ? ("`n" . label) : "")
				}
				else
					this.iLabels[row][column].Text := ""

				icon := this.getIcon(row, column)

				if !icon
					icon := (kIconsDirectory . "Empty.png")

				try
					this.iIcons[row][column].Value := icon
			}
		}
	}

	getFunction(row, column) {
		local button := this.getButton(row, column)

		return (button ? ("Button." . button.Button) : false)
	}

	setLabel(row, column, text) {
		local handle := this.iLabels[row][column]

		if handle
			handle.Text := text
	}

	getControl(clickX, clickY, &row, &column, &isEmpty) {
		local function
		local descriptor := "Empty.0"
		local name := "Empty"
		local number := 0
		local y := StreamDeckPreview.kTopMargin
		local x, button, name, number, previewMover

		row := 0
		column := 0
		isEmpty := true

		loop this.Rows {
			if ((clickY > y) && (clickY < (y + StreamDeckPreview.kButtonHeight))) {
				row := A_Index

				x := StreamDeckPreview.kLeftMargin[this.Size]

				loop this.Columns {
					if ((clickX > x) && (clickX < (x + StreamDeckPreview.kButtonWidth))) {
						column := A_Index

						button := this.getButton(row, column)

						if button {
							name := "Button"
							number := button.Button

							isEmpty := false
						}

						return ["Control", ConfigurationItem.descriptor(name, number)]
					}

					x += (StreamDeckPreview.kColumnMargin + StreamDeckPreview.kButtonWidth)
				}
			}

			y += (StreamDeckPreview.kRowMargin + StreamDeckPreview.kButtonHeight)
		}

		previewMover := this.PreviewManager.getPreviewMover()

		if previewMover
			previewMover.Call(this.Window)

		return false
	}

	controlClick(element, row, column, isEmpty) {
		return this.iControlClickHandler.Call(this, element, element[2], row, column, isEmpty)
	}

	openControlMenu(preview, element, function, row, column, isEmpty) {
		local count, mainMenu, controlMenu, numberMenu, subMenu, displayMenu, labelMenu, iconMenu, modeMenu, menuItem, window, label, count
		local button, labelMode, iconMode, mode

		changeControl(control, argument := false, *) {
			this.PreviewManager.changeControl(row, column, control, argument)
		}

		changeLabel(label, *) {
			this.PreviewManager.changeLabel(row, column, label)
		}

		if GetKeyState("Ctrl", "P")
			this.PreviewManager.changeControl(row, column, "__Number__", false)
		else {
			menuItem := (translate(element[1]) . translate(": ") . StrReplace(StrReplace(element[2], "`n", A_Space), "`r", "") . " (" . row . " x " . column . ")")

			mainMenu := Menu()
			window := this.Window

			mainMenu.Add(menuItem, (*) => {})
			mainMenu.Disable(menuItem)
			mainMenu.Add()

			controlMenu := Menu()

			controlMenu.Add(translate("Empty"), changeControl.Bind(false))
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

			mainMenu.Add(translate("Button"), controlMenu)

			button := this.getButton(row, column)

			if button {
				displayMenu := Menu()
				labelMenu := Menu()

				labelMode := this.getLabel(row, column)

				label := translate("Empty")
				labelMenu.Add(label, changeControl.Bind("__No_Label__", false))
				if (labelMode == false)
					labelMenu.Check(label)

				label := translate("Action")
				labelMenu.Add(label, changeControl.Bind("__Action_Label__", false))
				if (labelMode == true)
					labelMenu.Check(label)

				label := translate("Text...")
				labelMenu.Add(label, changeControl.Bind("__Text_Label__", false))
				if (labelMode && (labelMode != true))
					labelMenu.Check(label)

				displayMenu.Add(translate("Label"), labelMenu)

				iconMenu := Menu()

				iconMode := this.getIcon(row, column)

				label := translate("Empty")
				iconMenu.Add(label, changeControl.Bind("__No_Icon__", false))
				if (iconMode == false)
					iconMenu.Check(label)

				label := translate("Action")
				iconMenu.Add(label, changeControl.Bind("__Action_Icon__", false))
				if (iconMode == true)
					iconMenu.Check(label)

				label := translate("Image...")
				iconMenu.Add(label, changeControl.Bind("__Image_Icon__", false))
				if (iconMode && (iconMode != true))
					iconMenu.Check(label)

				label := translate("Icon")

				displayMenu.Add(label, iconMenu)

				modeMenu := Menu()

				mode := this.getMode(row, column)

				label := translate("Icon or Label")
				modeMenu.Add(label, changeControl.Bind("__Mode__", kIconOrLabel))
				if (mode == kIconOrLabel)
					modeMenu.Check(label)

				label := translate("Icon and Label")
				modeMenu.Add(label, changeControl.Bind("__Mode__", kIconAndLabel))
				if (mode == kIconAndLabel)
					modeMenu.Check(label)

				label := translate("Only Icon")
				modeMenu.Add(label, changeControl.Bind("__Mode__", kIcon))
				if (mode == kIcon)
					modeMenu.Check(label)

				label := translate("Only Label")
				modeMenu.Add(label, changeControl.Bind("__Mode__", kLabel))
				if (mode == kLabel)
					modeMenu.Check(label)

				displayMenu.Add(translate("Rule"), modeMenu)

				mainMenu.Add(translate("Display"), displayMenu)
			}

			mainMenu.Show()
		}
	}
}