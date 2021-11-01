;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Modular Simulator Controller System - Stream Deck Plugin               ;;;
;;;                                                                         ;;;
;;;   Author:     Oliver Juwig (TheBigO)                                    ;;;
;;;   License:    (2021) Creative Commons - BY-NC-SA                        ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;-------------------------------------------------------------------------;;;
;;;                          Public Classes Section                         ;;;
;;;-------------------------------------------------------------------------;;;

class StreamDeck extends FunctionController {
	iName := false
	iLayout := false
	
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
	
	Type[] {
		Get {
			return "Stream Deck"
		}
	}
	
	__New(name, layout, controller, configuration) {
		this.iName := name
		this.iLayout := layout
		
		base.__New(controller, configuration)
	}
}


;;;-------------------------------------------------------------------------;;;
;;;                   Private Function Declaration Section                  ;;;
;;;-------------------------------------------------------------------------;;;

streamDeckEventHandler(event, data) {
	local function
	
	command := string2Values(A_Space, data)
		
	descriptor := ConfigurationItem.splitDescriptor(command[1])
	
	switch descriptor[1] {
		case k1WayToggleType, k2WayToggleType:
			switchToggle(descriptor[1], descriptor[2], (command.Length() > 1) ? command[2] : "On")
		case kButtonType:
			pushButton(descriptor[2])
		case kDialType:
			rotateDial(descriptor[2], command[2])
		default:
			Throw "Unknown controller function descriptor (" . function[1] . ") detected in streamDeckEventHandler..."
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