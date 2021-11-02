;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Stream Deck Plugin              ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                         Local Include Section                           ;;;
;;;-------------------------------------------------------------------------;;;

#Include ..\Libraries\CLR.ahk


;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class StreamDeck extends FunctionController {
	iName := false
	iLayout := false
	
	iRowDefinitions := []
	iRows := false
	iColumns := false
	
	iFunctions := []
	iLabels := {}
	iIcons := {}
		
	iConnector := false
	
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
	
	Labels[function := false] {
		Get {
			if function
				return (this.iLabels.HasKey(function) ? this.iLabels[function] : true)
			else
				return this.iLabels
		}
	}
	
	Icons[function := false] {
		Get {
			if function
				return (this.iIcons.HasKey(function) ? this.iIcons[function] : true)
			else
				return this.iIcons
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
		
		layout := string2Values("x", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Layout, "Layout"), ""))
		
		this.iRows := layout[1]
		this.iColumns := layout[2]
		
		rows := []
		
		Loop % this.Rows
		{
			row := string2Values(";", getConfigurationValue(configuration, "Layouts", ConfigurationItem.descriptor(this.Layout, A_Index), ""))
			
			for ignore, function in row
				if (function != "") {
					icon := getConfigurationValue(configuration, "Buttons", this.Layout . "." . function . ".Icon", true)
					label := getConfigurationValue(configuration, "Buttons", this.Layout . "." . function . ".Label", true)
				
					this.Connector.SetTitle(function, "")
					this.Connector.SetImage(function, "")
					
					if (label != true) {
						this.iLabels[function] := label
						
						if label
							this.Connector.SetTitle(function, label)
					}
					
					if (icon != true) {
						this.iIcons[function] := icon
						
						if icon
							this.Connector.SetIcon(function, icon)
					}
					
					this.Functions.Push(function)
					
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
	
	hasFunction(function) {
		if IsObject(function)
			function := function.Descriptor
		
		return (inList(this.Functions, function) != false)
	}
	
	setControlLabel(function, text, color := "Black") {
		if this.hasFunction(function) {
			Process Exist, SimulatorControllerPlugin.exe
		
			if (ErrorLevel && (this.Labels[function.Descriptor] == true))
				this.Connector.SetTitle(function.Descriptor, text)
		}
	}
	
	setControlIcon(function, icon) {
		if !icon
			icon := ""
		
		if this.hasFunction(function) {
			Process Exist, SimulatorControllerPlugin.exe
		
			if (ErrorLevel && (this.Icons[function.Descriptor] == true))
				this.Connector.SetImage(function.Descriptor, icon)
		}
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

streamDeckEventHandler(event, data) {
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
			Throw "Unknown controller function type (" . descriptor[1] . ") detected in streamDeckEventHandler..."
	}
}

initializeStreamDeckPlugin() {
	controller := SimulatorController.Instance
	
	configuration := readConfiguration(getFileName("Stream Deck Configuration.ini", kUserConfigDirectory, kConfigDirectory))
	
	for ignore, strmDeck in string2Values("|", getConfigurationValue(controller.Configuration, "Controller Layouts", "Stream Decks", "")) {
		strmDeck := string2Values(":", strmDeck)
	
		new StreamDeck(strmDeck[1], strmDeck[2], controller, configuration)
	}
	
	registerEventHandler("Stream Deck", "streamDeckEventHandler")
}


;;;-------------------------------------------------------------------------;;;
;;;                         Initialization Section                          ;;;
;;;-------------------------------------------------------------------------;;;

initializeStreamDeckPlugin()