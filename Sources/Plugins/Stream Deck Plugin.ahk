﻿;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Stream Deck Plugin              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2025) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Gui.ahk"


;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include "..\Framework\Extensions\Task.ahk"
#Include "..\Framework\Extensions\Messages.ahk"
#Include "..\Framework\Extensions\CLR.ahk"
#Include "..\Framework\Extensions\GDIP.ahk"


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

class StreamDeck extends FunctionController {
	static sModes := false

	iName := false
	iLayout := false

	iRowDefinitions := []
	iRows := false
	iColumns := false

	iFunctions := []
	iLabels := CaseInsenseMap()
	iIcons := CaseInsenseMap()
	iModes := CaseInsenseMap()

	iConnector := false

	iActions := CaseInsenseMap()

	iFunctionTitles := CaseInsenseMap()
	iFunctionImages := CaseInsenseMap()

	iChangedFunctionTitles := CaseInsenseMap()
	iChangedFunctionImages := CaseInsenseMap()

	iRefreshActive := false
	iPendingUpdates := []

	Descriptor {
		Get {
			return this.Name
		}
	}

	Type {
		Get {
			return "Stream Deck"
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

	RowDefinitions {
		Get {
			return this.iRowDefinitions
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

	Functions {
		Get {
			return this.iFunctions
		}
	}

	Actions[function := false] {
		Get {
			if function
				return (function ? (this.iActions.Has(function) ? this.iActions[function] : []) : [])
			else
				return this.iActions
		}
	}

	Label[function := false] {
		Get {
			if function
				return (this.iLabels.Has(function) ? this.iLabels[function] : true)
			else
				return this.iLabels
		}
	}

	Icon[function := false] {
		Get {
			if function
				return (this.iIcons.Has(function) ? this.iIcons[function] : true)
			else
				return this.iIcons
		}
	}

	Mode[function := false, icon := false] {
		Get {
			local key

			if (function != false) {
				if isInstance(function, ControllerFunction)
					function := function.Descriptor

				if (icon != false) {
					key := (function . "." . icon)

					if this.iModes.Has(key)
						return this.iModes[key]

					if this.iModes.Has(icon)
						return this.iModes[icon]

					if StreamDeck.sModes.Has(icon)
						return StreamDeck.sModes[icon]
				}

				return (this.iModes.Has(function) ? this.iModes[function] : kIconOrLabel)
			}
			else
				return this.iModes
		}
	}

	RefreshActive {
		Get {
			return this.iRefreshActive
		}
	}

	Connector {
		Get {
			return this.iConnector
		}
	}

	__New(name, layout, controller, configuration) {
		local dllFile

		this.iName := name
		this.iLayout := layout

		dllFile := (kBinariesDirectory . "Connectors\SimulatorControllerPluginConnector.dll")

		try {
			if !FileExist(dllFile)
				throw "File not found..."

			this.iConnector := CLR_LoadLibrary(dllFile).CreateInstance("PluginConnector.PluginConnector")

			if (getMultiMapValue(readMultiMap(getFileName("Core Settings.ini", kUserConfigDirectory, kConfigDirectory)), "Stream Deck", "Protocol", "Message") = "File")
				this.iConnector.SetCommandFile(kTempDirectory . "Controller.cmd")
		}
		catch Any as exception {
			logError(exception, true)

			logMessage(kLogCritical, substituteVariables(translate("Cannot start Stream Deck Connector (%dllFile%) - please check the configuration..."), {dllFile: dllFile}))

			if !kSilentMode
				showMessage(substituteVariables(translate("Cannot start Stream Deck Connector (%dllFile%) - please check the configuration..."), {dllFile: dllFile})
						  , translate("Modular Simulator Controller System"), "Alert.png", 5000, "Center", "Bottom", 800)
		}

		super.__New(controller, configuration)
	}

	loadFromConfiguration(configuration) {
		local numButtons := 0
		local numDials := 0
		local num1WayToggles := 0
		local num2WayToggles := 0
		local function, special, rows, row, ignore, label, icon, mode, layout

		super.loadFromConfiguration(configuration)

		if !StreamDeck.sModes {
			StreamDeck.sModes := CaseInsenseMap()

			loop {
				special := getMultiMapValue(configuration, "Icons", "*.Icon.Mode." . A_Index, kUndefined)

				if (special == kUndefined)
					break
				else {
					special := string2values(";", special)

					StreamDeck.sModes[special[1]] := special[2]
				}
			}
		}

		layout := string2Values("x", getMultiMapValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Layout, "Layout"), ""))

		if (layout.Length > 1) {
			this.iRows := layout[1]
			this.iColumns := layout[2]

			loop {
				special := getMultiMapValue(configuration, "Icons", this.Layout . ".Icon.Mode." . A_Index, kUndefined)

				if (special == kUndefined)
					break
				else {
					special := string2values(";", special)

					this.iModes[special[1]] := special[2]
				}
			}

			rows := []

			loop this.Rows {
				row := string2Values(";", getMultiMapValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Layout, A_Index), ""))

				for ignore, function in row
					if (function != "") {
						this.Functions.Push(function)

						icon := getMultiMapValue(configuration, "Buttons", this.Layout . "." . function . ".Icon", true)
						label := getMultiMapValue(configuration, "Buttons", this.Layout . "." . function . ".Label", true)
						mode := getMultiMapValue(configuration, "Buttons", this.Layout . "." . function . ".Mode", kIconOrLabel)

						this.setFunctionTitle(function, "")
						this.setFunctionImage(function, "clear")

						if (mode != kIconOrLabel) {
							this.iModes[function] := mode
						}

						if (icon != true) {
							this.iIcons[function] := icon

							if (icon && (icon != ""))
								this.setControlIcon(function, icon)
						}

						if (label != true) {
							this.iLabels[function] := label

							if label
								this.setControlLabel(function, label)
						}

						loop {
							special := getMultiMapValue(configuration, "Buttons", this.Layout . "." . function . ".Mode.Icon." . A_Index, kUndefined)

							if (special == kUndefined)
								break
							else {
								special := string2values(";", special)

								this.iModes[function . "." . special[1]] := special[2]
							}
						}

						switch ConfigurationItem.splitDescriptor(function)[1], false {
							case k1WayToggleType:
								num1WayToggles += 1
							case k2WayToggleType:
								num2WayToggles += 1
							case kButtonType:
								numButtons += 1
							case kDialType:
								numDials += 1
							default:
								throw "Unknown controller function type (" . ConfigurationItem.splitDescriptor(function)[1] . ") detected in StreamDeck.loadFromConfiguration..."
						}
					}

				rows.Push(row)
			}

			this.iRowDefinitions := rows
		}

		this.setControls(num1WayToggles, num2WayToggles, numButtons, numDials)
	}

	static isRunning() {
		return ((ProcessExist("SimulatorControllerPlugin.exe") != 0) && SimulatorController.Instance.Started)
	}

	isRunning() {
		return StreamDeck.isRunning()
	}

	hasFunction(function) {
		if isObject(function)
			function := function.Descriptor

		return (inList(this.Functions, function) != false)
	}

	connectAction(plugin, function, action) {
		local actions := this.Actions

		if actions.Has(function)
			actions[function].Push(action)
		else
			actions[function] := Array(action)

		this.setControlLabel(function, plugin.actionLabel(action))
		this.setControlIcon(function, plugin.actionIcon(action))
	}

	disconnectAction(plugin, function, action) {
		local actions := this.Actions[function]
		local index := inList(actions, action)

		if index
			actions.RemoveAt(index)

		if (actions.Length = 0)
			this.Actions.Delete(function)

		this.setControlLabel(function, "")
		this.setControlIcon(function, false)
	}

	setControlLabel(function, text, color := "Black", overlay := false) {
		local actions, icon, ignore, theAction, displayMode, labelMode

		if !isObject(function)
			function := this.Controller.findFunction(function)

		if this.hasFunction(function) {
			actions := this.Actions[function]
			icon := false

			for ignore, theAction in this.Actions[function] {
				icon := theAction.Icon

				if (icon && (icon != ""))
					break
				else
					icon := false
			}

			displayMode := (icon ? this.Mode[function, icon] : this.Mode[function])

			if ((icon != false) && !overlay && ((displayMode = kIcon) || (displayMode = kIconOrLabel)))
				this.setFunctionTitle(function.Descriptor, "")
			else {
				labelMode := this.Label[function.Descriptor]

				if (labelMode == true)
					this.setFunctionTitle(function.Descriptor, text)
				else if (labelMode == false)
					this.setFunctionTitle(function.Descriptor, "")
				else
					this.setFunctionTitle(function.Descriptor, labelMode)
			}
		}
	}

	setControlIcon(function, icon, type := "Normal") {
		local controller := this.Controller
		local enabled, displayMode, iconMode, ignore, theAction, actions

		if !isObject(function)
			function := controller.findFunction(function)

		if this.hasFunction(function) {
			enabled := false

			actions := this.Actions[function]

			if (actions.Length > 0) {
				for ignore, theAction in actions
					if function.Enabled[theAction] {
						enabled := true

						break
					}
			}
			else
				enabled := true

			if (!icon || (icon = ""))
				icon := "clear"

			displayMode := ((icon != "clear") ? this.Mode[function, icon] : this.Mode[function])

			if (displayMode = kLabel)
				this.setFunctionImage(function.Descriptor, "clear")
			else {
				iconMode := this.Icon[function.Descriptor]

				if (iconMode == true)
					this.setFunctionImage(function.Descriptor, icon, enabled ? type : "Disabled")
				else if (iconMode == false)
					this.setFunctionImage(function.Descriptor, "clear")
				else
					this.setFunctionImage(function.Descriptor, iconMode, enabled ? type : "Disabled")
			}
		}
	}

	setFunctionTitle(function, title, refresh := false) {
		if refresh {
			if (title = "")
				title := " "

			if this.isRunning()
				this.Connector.SetTitle(function, title)
		}
		else if this.RefreshActive {
			this.iPendingUpdates.Push(ObjBindMethod(this, "setFunctionTitle", function, title))

			return
		}
		else {
			if this.iFunctionTitles.Has(function) {
				if (this.iFunctionTitles[function] != title)
					this.iChangedFunctionTitles[function] := true
			}
			else
				this.iChangedFunctionTitles[function] := true

			this.iFunctionTitles[function] := title

			if this.isRunning()
				this.Connector.SetTitle(function, title)
		}
	}

	setFunctionImage(function, icon, type := "Normal", refresh := false) {
		local displayIcon := icon

		if (type = "Deactivated")
			type := "Normal"

		if (icon && (icon != "clear"))
			if (type = "Disabled")
				displayIcon := disabledIcon(icon)
			else if (type = "Activated")
				displayIcon := activatedIcon(icon)
			else if (type = "Deactivated")
				displayIcon := deactivatedIcon(icon)

		if refresh {
			if this.isRunning()
				this.Connector.SetImage(function, displayIcon)
		}
		else if this.RefreshActive {
			this.iPendingUpdates.Push(ObjBindMethod(this, "setFunctionImage", function, icon, type))

			return
		}
		else {
			if this.iFunctionImages.Has(function) {
				if ((this.iFunctionImages[function][1] != icon) || (this.iFunctionImages[function][2] != type))
					this.iChangedFunctionImages[function] := true
				else
					return
			}
			else
				this.iChangedFunctionImages[function] := true

			this.iFunctionImages[function] := [icon, type]

			if this.isRunning()
				this.Connector.SetImage(function, displayIcon)
		}
	}

	refresh(full := false) {
		local function, theFunction, title, controller, image, enabled, ignore, theAction, update, actions

		if this.RefreshActive
			return
		else {
			this.iRefreshActive := true

			try {
				for theFunction, title in this.iFunctionTitles
					if (full || (this.iChangedFunctionTitles.Has(theFunction) && this.iChangedFunctionTitles[theFunction]))
						this.setFunctionTitle(theFunction, title, true)

				controller := this.Controller

				for theFunction, image in this.iFunctionImages
					if (full || (this.iChangedFunctionImages.Has(theFunction) && this.iChangedFunctionImages[theFunction])) {
						enabled := false

						function := controller.findFunction(theFunction)

						if function {
							actions := this.Actions[function]

							if (actions.Length > 0) {
								for ignore, theAction in actions
									if function.Enabled[theAction] {
										enabled := true

										break
								}
							}
							else
								enabled := true

							this.setFunctionImage(theFunction, image[1], enabled ? image[2] : "Disabled", true)
						}
					}

				this.iChangedFunctionTitles := CaseInsenseMap()
				this.iChangedFunctionImages := CaseInsenseMap()
			}
			finally {
				this.iRefreshActive := false
			}

			for ignore, update in this.iPendingUpdates
				update.Call()

			this.iPendingUpdates := []
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

activatedIcon(fileName) {
	addGreenBar(graphics, bitmap) {
		local height := Gdip_GetImageHeight(bitmap)
		local x, y, value

		loop height {
			y := A_Index - 1

			if (y < (height / 10)) {
				loop Gdip_GetImageWidth(bitmap) {
					x := A_Index - 1

					value := Gdip_GetPixel(bitmap, x, y)

					Gdip_SetPixel(bitmap, x, y, (value & 0xFF000000) + (0x9F << 8))
				}
			}
			else
				break
		}
	}

	return modifiedIcon(fileName, "Actv", addGreenBar)
}

deactivatedIcon(fileName) {
	addGrayBar(graphics, bitmap) {
		local height := Gdip_GetImageHeight(bitmap)
		local x, y, value

		loop height {
			y := A_Index - 1

			if (y < (height / 10)) {
				loop Gdip_GetImageWidth(bitmap) {
					x := A_Index - 1

					value := Gdip_GetPixel(bitmap, x, y)

					Gdip_SetPixel(bitmap, x, y, ((value & 0xFF000000) + (0x9F << 16) + (0x9F << 8) + 0x9F))
				}
			}
			else
				break
		}
	}

	return modifiedIcon(fileName, "Dactv", addGrayBar)
}

disabledIcon(fileName) {
	grayIcon(graphics, bitmap) {
		local x, y, value, red, green, blue, gray

		loop Gdip_GetImageHeight(bitmap) {
			y := A_Index - 1

			loop Gdip_GetImageWidth(bitmap) {
				x := A_Index - 1

				value := Gdip_GetPixel(bitmap, x, y)

				red := (0x00FF0000 & value)
				red := (red >> 16)
				blue := (0x0000FF00 & value)
				blue := (blue >> 8)
				green := (0x000000FF & value)

				gray := Round((0.299 * red) + (0.587 * green) + (0.114 * blue))

				Gdip_SetPixel(bitmap, x, y, ((value & 0xFF000000) + (gray << 16) + (gray << 8) + gray))
			}
		}
	}

	return modifiedIcon(fileName, "Dsbld", grayIcon)
}

handleStreamDeckMessage(category, data) {
	local command := string2Values(A_Space, data)
	local function := command[1]
	local found := false
	local ignore, fnController, descriptor

	for ignore, fnController in SimulatorController.Instance.FunctionController
		if isInstance(fnController, StreamDeck) && fnController.hasFunction(function)
			found := true

	if !found
		return

	descriptor := ConfigurationItem.splitDescriptor(function)

	switch descriptor[1], false {
		case k1WayToggleType, k2WayToggleType:
			switchToggle(descriptor[1], descriptor[2], (command.Length > 1) ? command[2] : "On", false)
		case kButtonType:
			pushButton(descriptor[2], false)
		case kDialType:
			rotateDial(descriptor[2], command[2], false)
		default:
			throw "Unknown controller function type (" . descriptor[1] . ") detected in handleStreamDeckMessage..."
	}
}

initializeStreamDeckPlugin() {
	local controller := SimulatorController.Instance
	local configuration := readMultiMap(getFileName("Stream Deck Configuration.ini", kUserConfigDirectory, kConfigDirectory))
	local ignore, strmDeck

	for ignore, strmDeck in string2Values("|", getMultiMapValue(controller.Configuration, "Controller Layouts", "Stream Decks", "")) {
		strmDeck := string2Values(":", strmDeck)

		try {
			StreamDeck(strmDeck[1], strmDeck[2], controller, configuration)
		}
		catch Any as exception {
			logError(exception, true)
		}
	}

	registerMessageHandler("Stream Deck", handleStreamDeckMessage)

	Task.startTask(() {
		if StreamDeck.isRunning()
			PeriodicTask(() {
				local ignore, fnController

				for ignore, fnController in SimulatorController.Instance.FunctionController
					if isInstance(fnController, StreamDeck)
						fnController.refresh(true)

				Task.CurrentTask.Sleep := 10000
			}, 0, kLowPriority).start()
		else
			return Task.CurrentTask
	}, 1000, kLowPriority)
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeStreamDeckPlugin()