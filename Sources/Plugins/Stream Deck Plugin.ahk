;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Stream Deck Plugin              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2022) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\Messages.ahk
#Include ..\Libraries\CLR.ahk
#Include ..\Libraries\GDIP.ahk


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

class StreamDeck extends FunctionController {
	static sModes := false

	iName := false
	iLayout := false

	iRowDefinitions := []
	iRows := false
	iColumns := false

	iFunctions := []
	iLabels := {}
	iIcons := {}
	iModes := {}
	iSpecial := {}

	iConnector := false

	iActions := {}

	iFunctionTitles := {}
	iFunctionImages := {}

	iChangedFunctionTitles := {}
	iChangedFunctionImages := {}

	iRefreshActive := false
	iPendingUpdates := []

	Descriptor[] {
		Get {
			return this.Name
		}
	}

	Type[] {
		Get {
			return "Stream Deck"
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

	RowDefinitions[] {
		Get {
			return this.iRowDefinitions
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

	Functions[] {
		Get {
			return this.iFunctions
		}
	}

	Actions[function := false] {
		Get {
			if function
				return (function ? (this.iActions.HasKey(function) ? this.iActions[function] : []) : [])
			else
				return this.iActions
		}
	}

	Label[function := false] {
		Get {
			if function
				return (this.iLabels.HasKey(function) ? this.iLabels[function] : true)
			else
				return this.iLabels
		}
	}

	Icon[function := false] {
		Get {
			if function
				return (this.iIcons.HasKey(function) ? this.iIcons[function] : true)
			else
				return this.iIcons
		}
	}

	Mode[function := false, icon := false] {
		Get {
			if (function != false) {
				if isInstance(function, ControllerFunction)
					function := function.Descriptor

				if (icon != false) {
					key := (function . "." . icon)

					if this.iModes.HasKey(key)
						return this.iModes[key]

					if this.iModes.HasKey(icon)
						return this.iModes[icon]

					if this.sModes.HasKey(icon)
						return this.sModes[icon]
				}

				return (this.iModes.HasKey(function) ? this.iModes[function] : kIconOrLabel)
			}
			else
				return this.iModes
		}
	}

	RefreshActive[] {
		Get {
			return this.iRefreshActive
		}
	}

	Connector[] {
		Get {
			return this.iConnector
		}
	}

	__New(name, layout, controller, configuration) {
		this.iName := name
		this.iLayout := layout

		dllName := "SimulatorControllerPluginConnector.dll"
		dllFile := kBinariesDirectory . dllName

		this.iConnector := CLR_LoadLibrary(dllFile).CreateInstance("PluginConnector.PluginConnector")

		base.__New(controller, configuration)
	}

	loadFromConfiguration(configuration) {
		local function

		numButtons := 0
		numDials := 0
		num1WayToggles := 0
		num2WayToggles := 0

		base.loadFromConfiguration(configuration)

		if !this.sModes {
			StreamDeck.sModes := {}

			Loop {
				special := mode := getConfigurationValue(configuration, "Icons", "*.Icon.Mode." . A_Index, kUndefined)

				if (special == kUndefined)
					break
				else {
					special := string2values(";", special)

					this.sModes[special[1]] := special[2]
				}
			}
		}

		layout := string2Values("x", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Layout, "Layout"), ""))

		this.iRows := layout[1]
		this.iColumns := layout[2]

		Loop {
			special := mode := getConfigurationValue(configuration, "Icons", this.Layout . ".Icon.Mode." . A_Index, kUndefined)

			if (special == kUndefined)
				break
			else {
				special := string2values(";", special)

				this.iModes[special[1]] := special[2]
			}
		}

		rows := []

		Loop % this.Rows
		{
			row := string2Values(";", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Layout, A_Index), ""))

			for ignore, function in row
				if (function != "") {
					this.Functions.Push(function)

					icon := getConfigurationValue(configuration, "Buttons", this.Layout . "." . function . ".Icon", true)
					label := getConfigurationValue(configuration, "Buttons", this.Layout . "." . function . ".Label", true)
					mode := getConfigurationValue(configuration, "Buttons", this.Layout . "." . function . ".Mode", kIconOrLabel)

					isRunning := this.isRunning()

					if isRunning {
						this.setFunctionTitle(function, "")
						this.setFunctionImage(function, "clear")
					}

					if (mode != kIconOrLabel) {
						this.iModes[function] := mode
					}

					if (icon != true) {
						this.iIcons[function] := icon

						if (icon && (icon != "") && isRunning)
							this.setControlIcon(function, icon)
					}

					if (label != true) {
						this.iLabels[function] := label

						if (label && isRunning)
							this.setControlLabel(function, label)
					}

					Loop {
						special := mode := getConfigurationValue(configuration, "Buttons", this.Layout . "." . function . ".Mode.Icon." . A_Index, kUndefined)

						if (special == kUndefined)
							break
						else {
							special := string2values(";", special)

							this.iModes[function . "." . special[1]] := special[2]
						}
					}

					switch ConfigurationItem.splitDescriptor(function)[1] {
						case k1WayToggleType:
							num1WayToggles += 1
						case k2WayToggleType:
							num2WayToggles += 1
						case kButtonType:
							numButtons += 1
						case kDialType:
							numDials += 1
						default:
							Throw "Unknown controller function type (" . ConfigurationItem.splitDescriptor(function)[1] . ") detected in StreamDeck.loadFromConfiguration..."
					}
				}

			rows.Push(row)
		}

		this.iRowDefinitions := rows

		this.setControls(num1WayToggles, num2WayToggles, numButtons, numDials)
	}

	isRunning() {
		Process Exist, SimulatorControllerPlugin.exe

		return (ErrorLevel != 0)
	}

	hasFunction(function) {
		if IsObject(function)
			function := function.Descriptor

		return (inList(this.Functions, function) != false)
	}

	connectAction(plugin, function, action) {
		actions := this.Actions

		if actions.HasKey(function)
			actions[function].Push(action)
		else
			actions[function] := Array(action)

		this.setControlLabel(function, plugin.actionLabel(action))
		this.setControlIcon(function, plugin.actionIcon(action))
	}

	disconnectAction(plugin, function, action) {
		this.setControlLabel(function, "")
		this.setControlIcon(function, false)

		actions := this.Actions[function]

		index := inList(actions, action)

		if index
			actions.RemoveAt(index)

		if (actions.Length() = 0)
			this.Actions.Delete(function)
	}

	setControlLabel(function, text, color := "Black", overlay := false) {
		if !IsObject(function)
			function := this.Controller.findFunction(function)

		if (this.isRunning() && this.hasFunction(function)) {
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

	setControlIcon(function, icon) {
		controller := this.Controller

		if !IsObject(function)
			function := controller.findFunction(function)

		if (this.isRunning() && this.hasFunction(function)) {
			enabled := false

			for ignore, theAction in this.Actions[function]
				if function.Enabled[theAction] {
					enabled := true

					break
				}

			if (!icon || (icon = ""))
				icon := "clear"

			displayMode := ((icon != "clear") ? this.Mode[function, icon] : this.Mode[function])

			if (displayMode = kLabel)
				this.setFunctionImage(function.Descriptor, "clear")
			else {
				iconMode := this.Icon[function.Descriptor]

				if (iconMode == true)
					this.setFunctionImage(function.Descriptor, icon, enabled)
				else if (iconMode == false)
					this.setFunctionImage(function.Descriptor, "clear")
				else
					this.setFunctionImage(function.Descriptor, iconMode, enabled)
			}
		}
	}

	setFunctionTitle(function, title, refresh := false) {
		if refresh {
			if (title = "")
				title := " "

			this.Connector.SetTitle(function, title)
		}
		else if this.RefreshActive {
			this.iPendingUpdates.Push(ObjBindMethod(this, "setFunctionTitle", function, title))

			return
		}
		else {
			if this.iFunctionTitles.HasKey(function) {
				if (this.iFunctionTitles[function] != title)
					this.iChangedFunctionTitles[function] := true
			}
			else
				this.iChangedFunctionTitles[function] := true

			this.iFunctionTitles[function] := title

			this.Connector.SetTitle(function, title)
		}
	}

	setFunctionImage(function, icon, enabled := false, refresh := false) {
		if refresh
			this.Connector.SetImage(function, ((icon = "clear") || enabled) ? icon : disabledIcon(icon))
		else if this.RefreshActive {
			this.iPendingUpdates.Push(ObjBindMethod(this, "setFunctionImage", function, icon, enabled))

			return
		}
		else {
			if this.iFunctionImages.HasKey(function) {
				if (this.iFunctionImages[function] != icon)
					this.iChangedFunctionImages[function] := true
			}
			else
				this.iChangedFunctionImages[function] := true

			this.iFunctionImages[function] := icon

			this.Connector.SetImage(function, ((icon = "clear") || enabled) ? icon : disabledIcon(icon))
		}
	}

	refresh(full := false) {
		local function

		if this.RefreshActive
			return
		else {
			this.iRefreshActive := true

			try {
				for theFunction, title in this.iFunctionTitles
					if (full || (this.iChangedFunctionTitles.HasKey(theFunction) && this.iChangedFunctionTitles[theFunction]))
						this.setFunctionTitle(theFunction, title, true)

				controller := this.Controller

				for theFunction, image in this.iFunctionImages
					if (full || (this.iChangedFunctionImages.HasKey(theFunction) && this.iChangedFunctionImages[theFunction])) {
						enabled := false

						function := controller.findFunction(theFunction)

						for ignore, theAction in this.Actions[function]
							if function.Enabled[theAction] {
								enabled := true

								break
						}

						this.setFunctionImage(theFunction, image, enabled, true)
					}

				this.iChangedFunctionTitles := {}
				this.iChangedFunctionImages := {}
			}
			finally {
				this.iRefreshActive := false
			}

			for ignore, update in this.iPendingUpdates
				%update%()

			this.iPendingUpdates := []
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

disabledIcon(fileName) {
	SplitPath fileName, , , extension, name

	disabledFileName := (kTempDirectory . "Icons\" . name . "_Dsbld." . extension)

	if !FileExist(disabledFileName) {
		FileCreateDir %kTempDirectory%Icons

		token := Gdip_Startup()

		bitmap := Gdip_CreateBitmapFromFile(fileName)

		graphics := Gdip_GraphicsFromImage(bitmap)

		Loop % Gdip_GetImageHeight(bitmap)
		{
			x := A_Index - 1

			Loop % Gdip_GetImageWidth(bitmap)
			{
				y := A_Index - 1

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

		Gdip_SaveBitmapToFile(bitmap, disabledFileName)

		Gdip_DisposeImage(bitmap)

		Gdip_DeleteGraphics(graphics)

		Gdip_Shutdown(token)
	}

	return disabledFileName
}

refreshStreamDecks() {
	static cycle := 0

	if (++cycle > 1) {
		cycle := 0

		full := true
	}
	else
		full := false


	for ignore, fnController in SimulatorController.Instance.FunctionController
		if isInstance(fnController, StreamDeck)
			fnController.refresh(full)

	SetTimer refreshStreamDecks, -5000
}

handleStreamDeckMessage(category, data) {
	local function

	command := string2Values(A_Space, data)

	function := command[1]

	found := false

	for ignore, fnController in SimulatorController.Instance.FunctionController
		if isInstance(fnController, StreamDeck) && fnController.hasFunction(function)
			found := true

	if !found
		return

	descriptor := ConfigurationItem.splitDescriptor(function)

	switch descriptor[1] {
		case k1WayToggleType, k2WayToggleType:
			switchToggle(descriptor[1], descriptor[2], (command.Length() > 1) ? command[2] : "On")
		case kButtonType:
			pushButton(descriptor[2])
		case kDialType:
			rotateDial(descriptor[2], command[2])
		default:
			Throw "Unknown controller function type (" . descriptor[1] . ") detected in handleStreamDeckMessage..."
	}
}

initializeStreamDeckPlugin() {
	controller := SimulatorController.Instance

	configuration := readConfiguration(getFileName("Stream Deck Configuration.ini", kUserConfigDirectory, kConfigDirectory))

	for ignore, strmDeck in string2Values("|", getConfigurationValue(controller.Configuration, "Controller Layouts", "Stream Decks", "")) {
		strmDeck := string2Values(":", strmDeck)

		new StreamDeck(strmDeck[1], strmDeck[2], controller, configuration)
	}

	registerMessageHandler("Stream Deck", "handleStreamDeckMessage")

	SetTimer refreshStreamDecks, -5000
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeStreamDeckPlugin()