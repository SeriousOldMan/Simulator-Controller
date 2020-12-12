## Introduction

The architecture of Simulator Controller has been designed with extensibility in mind. Since every racing rig is different and there are so many different applications out there for sim racers, the core of Simulator Controller is build around a very flexible and generic concept. Plugins may be used to provide additional functionality ranging from simple code additions up to very complex, object-oriented extensions of the Simulator Controller itself.

### Plugin Integration

When the Simulator Controller starts up, a single file in the *Sources/Controller/Plugins* folder will be included using the AutoHotkey #Include directive: [Plugins.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Plugins/Plugins.ahk). This file may be modified to include all the plugin script required for your specific configuration.

Although a plugin script may execute any kind of code written in the AutoHotkey language, *real* plugins must extend the ControllerPlugin (*) class and will provide additional functionality for your controller box. The following sections will introduce all the concepts and classes needed to implement your own plugins step by step.


### Overview

The Simulator Controller framework has been build around the similar named Singleton Class [SimulatorController](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-simulatorcontroller-extends-configurationitem-simulator-controllerahk). This class implements the complete control flow between the hardware controller elements like buttons, dials and switches and the functionalities provided by a plugin. Since the number of hardware control elements is limited, functionalities may be grouped in so called modes, which may be activated or deactivated as a group. Each mode belongs to a given plugin and only on mode may be active at a given point in time. From the user point of view, a mode defines a set of controls as a switchable layer for the hardware controller. In addition, plugins may bind functionality to controller functions independent of a specific mode, and these functions may be available all the time. An example will make it more clear: A toggle switch to enable or disable rig motion feedback might be always available and therefore is provided by the plugin itself, but detailed control over specific effect intensities might only be necessary, while finetuning the feedback levels, which may be grouped by a "Feedback Settings" mode.

A specific hardware control element is represented in code by an instance of the class [SimulatorControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-simulatorcontrollerfunction-simulator-controllerahk), respectivly one of its subclasses. For a controller function to be useful, it must be connected or bound to a ControllerAction (*), which implements the functionality that should be triggered by the hardware controller. These connections are of dynamic nature, which means that the functional mapping for the hardware controller can be changed anytime. This is first and foremost used when switching between modes, but it can also be used to create context sensitive function mappings.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Class%20Diagram%201.JPG)

### Plugins


### Modes


### Controller Functions

Instances of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-extends-configurationitem-classesahk) represent the active elements of a hardware controller - buttons, dials, switches and so on. A function must be mapped to an [action](*) to be useful. This mapping is handled by [plugins](*) and [modes}(*), since both can take ownership of a function and define the corresponding Action. Whereas modes may connect a function to an action only as long they are the currently active mode of the Controller (*) (i.e. the currently active layer of a button box), plugins can define actions and bind them to functions, so that they are available all the time. Functions might be enabled or disabled according to the current state of their mode or plugin and they can give visual feedback, if a visual button box representation has been defined. For example, if you increase the force feedback of your steering wheel with a dial knob, the current feedback strength might be dislayed below the dial. Normally this is handled by the action, when the [fireAction](*) method is called.

Controller functions are identified by their descriptor, which consists of the [type name](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#controller-function-types-constantsahk) followed by a dot and a running number. For example, the third button on a hardware controller might have "Buttton.3" as its descriptor. All available functions must have been defined by the setup tool (*), before they can used. With the setup tool, you also define the Hotkeys (*), that will trigger the function from the hardware.
To retrieve a function object in code, use the [findFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#findfunctionname--string) method of *SimulatorController*. As sais, functions may be [enabled](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#enabletrigger--string) or [disabled](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#disabletrigger--string) according to the current context, and associated label on the visual controller representation may be changed anytime using the [setText](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#settexttest--string-color--string--black) method.

Every function define one or more trigger (for example "On", "Off", "Push", "Increase") depending on the hardware controller element they represent. According to the trigger, the associated action might react differently. For example, for a 2-way toggle switch, "On" and "Off" will activate or deactivate some functionality of your rig or switch the running lights of your car on or off.

Several subclasses of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-extends-configurationitem-classesahk) define specialized behaviour, for example [2WayToggleFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#2waytogglefunction-extends-controllerfunction-classesahk) can trigger to different action methods, since they have an On and an Off state. See the [class reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference) for details on all subclasses of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-extends-configurationitem-classesahk).

Note: To make things more complicated, a seperate controller function inheritance tree exists for all functions handled by [SimulatorController](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-simulatorcontroller-extends-configurationitem-simulator-controllerahk), since AutoHotkey does not support multiple inheritence. The complete protocol of *ControllerFunction* is implemented by these [classes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-simulatorcontrollerfunction-simulator-controllerahk) as well and they use instances of the original classes by a delegation pattern. Since AutoHotey is a weakly typed prototype-based language, this fact is completely invisible to the programmer, but in the end good to know and to understand.

### Controller Actions
Instances of ControllerAction (*) are very simple. They define a label, which might be displayed by the button box visual representation and they implement the fireAction (*) method, which will be triggered by the function. Although actions might be created and registered to their mode or plugin anytime, normally they are created during the initialization process, most of the time based on configuration data.

### Button Box

### Example

The following example shows some of the concepts introduced above. The code shown here is the most part the ACC Plugin, which comes with the Simulator Controller distribution.

Let's start with the plugin class definition:

	class ACCPlugin extends ControllerPlugin {
		iDriveMode := false
		
		Plugin[] {
			Get {
				return kACCPlugin
			}
		}

		class DriveMode extends ControllerMode {
			Mode[] {
				Get {
					return kDriveMode
				}
			}
		}
		
		...
		
The *ACCPlugin* defines one mode class named *DriveMode*. To keep the global namespace as clean as possible, we use an innerclass defintion style. Second the action class, which handles the ingame chat messages, will be defined also as an inner subclass of *ControllerAction*:

		...
		
		class ChatAction extends ControllerAction {
			iMessage := ""
			
			Message[] {
				Get {
					return this.iMessage
				}
			}
			
			__New(function, label, message) {
				this.iMessage := message
				
				base.__New(function, label)
			}
			
			fireAction(function, trigger) {
				message := this.Message
				
				Send {Enter}
				Sleep 100
				Send %message%
				Sleep 100
				Send {Enter}
			}
		}
		
		...

As you can see, the only important part of the *ChatAction* class is the *fireAction* method, which sends the chat message to the chat list by emulating keyboard input. Now we come to the body of the *ACCPlugin* class, where everything is brought together:

		...
		
		__New(controller, name, configuration := false) {
			this.iDriveMode := new this.DriveMode(this)
			
			base.__New(controller, name, configuration)
			
			this.registerMode(this.iDriveMode)
		}
		
		runningSimulator() {
			return isACCRunning() ? "Assetto Corsa Competizione" : false
		}
		
		simulatorStartup(simulator) {
			base.simulatorStartup(simulator)
			
			if (inList(this.Simulators, simulator)) {
				this.Controller.setMode(this.iDriveMode)
			}
		}
		
		loadFromConfiguration(configuration) {
			base.loadFromConfiguration(configuration)
			
			for descriptor, message in getConfigurationSectionValues(configuration, "Chat Messages", Object()) {
				function := this.Controller.findFunction(descriptor)
				
				if (function != false) {
					message := string2Values("|", message)
				
					this.iDriveMode.registerAction(new this.ChatAction(function, message[1], message[2]))
				}
				else
					logMessage(kLogWarn, "Controller function " . descriptor . " not found in plugin " . this.Plugin . " - please check the setup")
			}
		}
	}
	
In the implementation of *loadFromConfiguration* all chat messages are retrieved from the configuration map, the corresponding controller functions are looked up and actions for each chat message are created and associated with these functions. The actions are registered for the "Drive" mode, thereby assuring, that chat messages will only be available when this mode is active.

The *ACCPlugin* is aware of "Assetto Corsa Competizione", as you can see by the implementation of the *runningSimulator* method above. Since "Assetto Corsa Competizione" might also configured in the setup tool (*) as a required simulator for this plugin, the "Drive" mode will only be active, i.e. available, when Assetto Corsa Competizione is running. As a convinience function, the implmentation of the *simulatorStartup* method  will automatically switch to "Drive" mode, when ACC has been started, thereby making the chat messages buttons available on the hardware controller.