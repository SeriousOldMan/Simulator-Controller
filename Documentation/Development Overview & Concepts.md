## Introduction

The architecture of Simulator Controller has been designed with extensibility in mind. Since every simulation equipment is unique and there are so many different applications out there for sim racers, the core of Simulator Controller is build around a very flexible and generic concept. Plugins may be used to provide additional functionality ranging from simple code additions up to very complex, object-oriented extensions of the Simulator Controller itself.

### Plugin Integration

When the Simulator Controller starts up, in a first step a single file in the [Sources/Controller/Plugins] (https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Sources/Controller/Plugins) folder will be included using the AutoHotkey #Include directive: [Plugins.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Plugins/Plugins.ahk). This will load all the plugins that are part of the standard distribution of Simulator Controller. To allow you to create and include your own plugins without needing to modify the above file, a second initially empty *Plugins.ahk* will be included from the special location *Simulator Controller\Plugins* folder, which is located in your *Documents* folder. This special location has been created by the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup) and will not be overwritten by future distributions of Simulator Controller. So feel free to include your own plugins from this second *Plugins.ahk* file.

Although a plugin script may execute any kind of code written in the AutoHotkey language, *real* plugins must extend the [ControllerPlugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllerplugin-extends-plugin-simulator-controllerahk) class and will provide additional functionality for your controller box. Furthermore, you will need to register the newly created plugin in the setup tool, so that it will be activated by the Simulator Controller.

The following sections will introduce all the concepts and classes needed to implement your own *real* plugins step by step.

### Overview

The Simulator Controller framework has been build around the similar named Singleton Class [SimulatorController](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-simulatorcontroller-extends-configurationitem-simulator-controllerahk). This class implements the complete control flow between the hardware controller elements like buttons, dials and switches and the functionalities provided by a plugin. Since the number of hardware control elements is limited, functionalities may be grouped in so called modes, which may be activated or deactivated as a group. Each mode belongs to a given plugin and only on mode may be active at a given point in time. From the user point of view, a mode defines a set of controls as a switchable layer for the hardware controller. In addition, plugins may bind functionality to controller functions independent of a specific mode, and these functions may be available all the time. An example will make it more clear: A toggle switch to enable or disable rig motion feedback might be always available and therefore is provided by the plugin itself, but detailed control over specific effect intensities might only be available, while finetuning the feedback levels, which may be grouped by a "Feedback Settings" mode.

A specific hardware control element is represented in code by an instance of the class [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk), respectivly one of its subclasses. For a controller function to be useful, it must be connected or bound to a [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk), which implements the functionality that should be triggered by the hardware controller. These connections are of dynamic nature, which means that the functional mapping for the hardware controller can be changed anytime. This is first and foremost used when switching between modes, but it can also be used to create context sensitive function mappings.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Class%20Diagram%201.JPG)

### Plugins

Plugins group a set of extensions for the Simulator Controller. The main purpose of a plugin is to define some [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk), either directly or with the help of one or more [controller modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllermode-simulator-controllerahk). Modes group a set of actions, which can be activated or deactivated together. Plugins may range from simple extensions like sending predefined messages to an ingame chat system (see the [example](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#example) below), or they may provide complete control over applications like SimHub or SimFeedback.

To be as flexible as possible, plugins may be configured by the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup) and can define a set of [parameters](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#hasargumentparameter), for which values can be supplied in the configuration. See the documentation for the included plugins, to get an understanding about plugin arguments.

Plugins may be activated or deactivated in the configuration as well, which might be helpful in some situations. Beside that, a plugin may be configured only to be active (concrete: the modes of the plugin), when a specific simulation game is currently running.

### Modes

Each plugin may define one or more [modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllermode-simulator-controllerahk), which group a set of actions. Controller modes represent a layer or group of functionality for the hardware controller. All the actions, that are part of this group, will be connected to their corresponding functions, when their mode becomes the active one. Only one mode may be active for the controller in any given point in time.

### Functions

Instances of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk) represent the active elements of a hardware controller - buttons, dials, switches and so on. A function must be connected to an [action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk) to be useful. This mapping is handled by [plugins](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllerplugin-extends-plugin-simulator-controllerahk) and [modes}(https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllermode-simulator-controllerahk), since both can take ownership of a function and provide the corresponding Action. Whereas modes may connect a function to an action only as long they are the currently active mode of the [controller](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-simulatorcontroller-extends-configurationitem-simulator-controllerahk) (i.e. the currently active layer of a Button Box), plugins can define actions and bind them to functions, so that they are available all the time. Functions might be enabled or disabled according to the current state of their mode or plugin and they can give visual feedback, if a visual Button Box representation has been defined. For example, if you increase the force feedback of your steering wheel with a dial knob, the current feedback strength might be dislayed below the dial. Normally this is handled by the action, when the [fireAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-fireactionfunction--controllerfunction-trigger--string) method is called.

Controller functions are identified by their descriptor, which consists of the [type name](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#controller-function-types-constantsahk) followed by a dot and a running number. For example, the third button on a hardware controller might have "Buttton.3" as its descriptor. All functions must have been defined by the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup), before they can used. With the setup tool, you also define the [hotkeys](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#hotkeys), that will trigger the function from the hardware.
To retrieve a function object in code, use the [findFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#findfunctionname--string) method of *SimulatorController*. As said, functions may be [enabled](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#enabletrigger--string) or [disabled](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#disabletrigger--string) according to the current context, and the associated label on the visual controller representation may be changed anytime using the [setText](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#settexttest--string-color--string--black) method.

Every function define one or more trigger (for example "On", "Off", "Push", "Increase") depending on the hardware controller element they represent. According to that trigger, the associated action might react differently. For example, for a 2-way toggle switch, "On" and "Off" will activate or deactivate some functionality of your rig or may switch the running lights of your car on or off.

Several subclasses of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk) define specialized behaviour, for example [Controller2WayToggleFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controller2waytogglefunction-extends-simulatorcontrollerfunction-simulator-controllerahk) can trigger to different action methods, since they have an On and an Off state. See the [class reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference) for details on all subclasses of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk).

### Actions
Instances of [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk) are very simple. They define a label, which might be displayed by the Button Box visual representation and they implement the [fireAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-fireactionfunction--controllerfunction-trigger--string) method, which will be triggered by the function. Although actions might be created and registered to their mode or plugin anytime, normally they are created during the initialization process, most of the time based on configuration data.

### Button Box

The Simulator Controller can give visual feedback for each interaction with the hardware controller. Normally, this feedback will provide some information about the state change, that has been performed by the last triggered action. For example, a text field below a rotary dial in the visual representation of a Button Box may show the current intensity value for a vibration motor.
The visual representation for the controller hardware will usually be build with the [Gui capabilities](https://www.autohotkey.com/docs/commands/Gui.htm) of the AutoHotkey language. The abstract singleton class [ButtonBox](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-singleton-buttonbox-extends-configurationitem-simulator-controllerahk) is used to create this visual representation and to interact with the controller and the provided functions and corresonding actions. Subclasses must implement two methods [createWindow](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-createwindowbyref-window--string-byref-windowwidth--integer-byref-windowheight--integer) and [getControlHandle](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-getcontrolhandledescriptor--string) to implement these capabilities. See [this example](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Plugins/ButtonBox%20Plugin.ahk) for a small and simple implementation of a Button Box with five toggle switches, eight push buttons and two rotary dials. For building your own visual representations, you can use the supplied images for typical Button Box functions provided in the folder [Resources/Button Box Images](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Resources/Button%20Box%20Images).

## Example

The following example shows some of the concepts introduced above. The code shown here represents the major part the ACC Plugin, which comes with the Simulator Controller distribution.

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
		
The class *ACCPlugin* defines one mode class named *DriveMode*. To keep the global namespace as clean as possible, we use an innerclass defintion style. Second the action class, which handles the ingame chat messages, will be defined also as an inner subclass of *ControllerAction*:

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

As you can see, the only important part of the *ChatAction* class is the *fireAction* method, which sends the chat message to the chat list by emulating keyboard input using AutoHotkey commands. Now we come to the body of the *ACCPlugin* class, where everything is brought together:

		...
		
		__New(controller, name, configuration := false) {
			this.iDriveMode := new this.DriveMode(this)
			
			base.__New(controller, name, configuration)
			
			this.registerMode(this.DriveMode)
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

The *ACCPlugin* is aware of "Assetto Corsa Competizione", as you can see by the implementation of the *runningSimulator* method above. Since "Assetto Corsa Competizione" might also be configured in the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup) as a required simulator for this plugin, the "Drive" mode will only be active, i.e. available, when Assetto Corsa Competizione is running. As a convinience function, the implmentation of the *simulatorStartup* method  will automatically switch to "Drive" mode, when ACC has been started, thereby making the chat messages available on the hardware controller buttons.

## Debugging

As capable, as the AutoHotkey language is, as bad is it, when it comes to avoiding code errors. I like dynamically typed languages, as long as they support the developer good enough to understand the errors introduced by mixing types of variables and values. AutoHotkey is different. Since everything is build around key/value structured objects and a reference to an unknown key simply yields an empty value, the following expression will execute without error, even if the *myObject* is not of the right type or even *false* itself.

	myObject.methodCall("foo", "bar")[42]

Therefore it can be very annoying to track down errors in AutoHotkey. But there is help available. First of all, use one of the AutoHotkey aware editors with debugging, inspection and single-stepping support. You will find an overview of the available editors [here](https://www.autohotkey.com/docs/AHKL_DBGPClients.htm). Second, and maybe even more important, the Simulator Controller has extensive logging capabilties integrated. Most of the time you can detect a coding error in your plugin simply by looking at the activity trace in the log file. Log files reside in the *Logs* folder and the log level can be changed using the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). But be careful, since at log level *Info*, the log files can grow quite fast.

## Using the Build Tool

A simple build tool is part of the Simulator Controller distribution. It is rule based like the good old Unix make tool and will compile all the applications, that are part of Simulator Controller and put them in the *Binaries* folder. Additionaly, you can define cleanup tasks, for example to clear the *Logs* folder or removing backup files. You can find the build tool in the *Binaries* folder, it is named *Simulator Tools.exe*. Simply start it with a double click and it will scan all source files and will recreate all outdated executables..

The build rules are defined in the file *Simulator Tools.targets* in the *Config* folder. A typical build rule will look like this:

	Simulator Controller=
		%kBinariesDirectory%Simulator Controller.exe <- %kSourcesDirectory%Controller\Simulator Controller.ahk;
														%kIncludesDirectory%, %kSourcesDirectory%Controller\Plugins\

Note: You cannot normally format the rules like in this example, since due to technical restrictions, the complete rule must be kept on one line without CRs or LFs.

This rule defines the *Simulator Controller.exe* application in the *Binaries* folder as the target. The main source file will be *Sources\Controller\Simulator Controller.ahk* and there are additional files in the *Includes* and in the *Plugins* folder, that will be checked for modification. Variables enclosed in "%" will be replaced with theirs current runtime values.

Normally you will never need to change the build rules when developing your own plugins, as long as they will reside in the standard *Plugins* folders. But, if you decide to put them elsewhere, you might want to add an dependency to this place.

You can decide which targets you want to include in your build run by holding down the Control key when starting the build tool. A small window will open where you can activate or deactivate all the targets. This settings will be saved for all consecutive runs of the build tool.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Build%20Tool.JPG)

Note: You can cancel a build run anytime by pressing the Escape key.