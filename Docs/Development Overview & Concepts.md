## Introduction

The architecture of Simulator Controller has been designed with extensibility in mind. Since every simulation equipment is unique and there are so many different applications out there for sim racers, the core of Simulator Controller is build around a very flexible and generic concept. Plugins may be used to provide additional functionality ranging from simple code additions up to very complex, object-oriented extensions of the Simulator Controller itself.

### Plugin Integration

When the Simulator Controller starts up, in a first step a single file in the [Sources/Plugins](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Sources/Plugins) folder will be included using the AutoHotkey #Include directive: [Controller Plugins.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/Controller%20Plugins.ahk). This will load all the plugins that are part of the standard distribution of Simulator Controller. To allow you to create and include your own plugins without needing to modify the above file, a second initially empty *Controller Plugins.ahk* will be included from the special location *Simulator Controller\Plugins* folder, which is located in your *Documents* folder. This special location has been created by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) and will not be overwritten by future distributions of Simulator Controller. So feel free to include your own plugins from this second *Controller Plugins.ahk* file.

Although a plugin script may execute any kind of code written in the AutoHotkey language, *real* plugins must extend the [ControllerPlugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllerplugin-extends-plugin-simulator-controllerahk) class and will provide additional functionality for your controller box. Furthermore, you will need to register the newly created plugin in the configuration tool, so that it will be activated by the Simulator Controller.

The following sections will introduce all the concepts and classes needed to implement your own *real* plugins step by step.

### Overview

The Simulator Controller framework has been build around the similar named Singleton Class [SimulatorController](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-simulatorcontroller-extends-configurationitem-simulator-controllerahk). This class implements the complete control flow between the hardware controller elements like buttons, dials and switches and the functionalities provided by a plugin. Since the number of hardware control elements is limited, functionalities may be grouped in so called modes, which may be activated or deactivated as a group. Each mode belongs to a given plugin and only on mode may be active at a given point in time. From the user point of view, a mode defines a set of controls as a switchable layer for the hardware controller. In addition, plugins may bind functionality to controller functions independent of a specific mode, and these functions may be available all the time. An example will make it more clear: A toggle switch to enable or disable rig motion feedback might be always available and therefore is provided by the plugin itself, but detailed control over specific effect intensities might only be available, while finetuning the feedback levels, which may be grouped by a "Feedback Settings" mode.

A specific hardware control element is represented in code by an instance of the class [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk), respectivly one of its subclasses. For a controller function to be useful, it must be connected or bound to a [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk), which implements the functionality that should be triggered by the hardware controller. These connections are of dynamic nature, which means that the functional mapping for the hardware controller can be changed anytime. This is first and foremost used when switching between modes, but it can also be used to create context sensitive function mappings.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Class%20Diagram%201.JPG)

### Plugins

Plugins group a set of extensions for the Simulator Controller. The main purpose of a plugin is to define some [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk), either directly or with the help of one or more [controller modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllermode-simulator-controllerahk). Modes group a set of actions, which can be activated or deactivated together. Plugins may range from simple extensions like sending predefined messages to an ingame chat system (see the [example](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#example) below), or they may provide complete control over applications like SimHub or SimFeedback.

To be as flexible as possible, plugins may be configured by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) and can define a set of [parameters](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#hasargumentparameter), for which values can be supplied in the configuration. See the documentation for the included plugins, to get an understanding about plugin arguments.

Plugins may be activated or deactivated in the configuration as well, which might be helpful in some situations. Beside that, a plugin may be configured only to be active (concrete: the modes of the plugin), when a specific simulation game is currently running.

### Modes

Each plugin may define one or more [modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllermode-simulator-controllerahk), which group a set of actions. Controller modes represent a layer or group of functionality for the hardware controller. All the actions, that are part of this group, will be connected to their corresponding functions, when their mode becomes the active one. Only one mode may be active for the controller in any given point in time.

### Functions

Instances of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk) represent the active elements of a hardware controller - buttons, dials, switches and so on. A function must be connected to an [action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk) to be useful. This mapping is handled by [plugins](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllerplugin-extends-plugin-simulator-controllerahk) and [modes}(https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllermode-simulator-controllerahk), since both can take ownership of a function and provide the corresponding Action. Whereas modes may connect a function to an action only as long they are the currently active mode of the [controller](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-simulatorcontroller-extends-configurationitem-simulator-controllerahk) (i.e. the currently active layer of a Button Box), plugins can define actions and bind them to functions, so that they are available all the time. Functions might be enabled or disabled according to the current state of their mode or plugin and they can give visual feedback, if a visual Button Box representation has been defined. For example, if you increase the force feedback of your steering wheel with a dial knob, the current feedback strength might be dislayed below the dial. Normally this is handled by the action, when the [fireAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-fireactionfunction--controllerfunction-trigger--string) method is called.

Controller functions are identified by their descriptor, which consists of the [type name](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#controller-function-types-constantsahk) followed by a dot and a running number. For example, the third button on a hardware controller might have "Buttton.3" as its descriptor. All functions must have been defined by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), before they can used. With the configuration tool, you also define the [hotkeys](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys), that will trigger the function from the hardware.
To retrieve a function object in code, use the [findFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#findfunctionname--string) method of *SimulatorController*. As said, functions may be [enabled](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#enabletrigger--string) or [disabled](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#disabletrigger--string) according to the current context, and the associated label on the visual controller representation may be changed anytime using the [setText](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#settexttest--string-color--string--black) method.

Every function define one or more trigger (for example "On", "Off", "Push", "Increase") depending on the hardware controller element they represent. According to that trigger, the associated action might react differently. For example, for a 2-way toggle switch, "On" and "Off" will activate or deactivate some functionality of your rig or may switch the running lights of your car on or off.

Several subclasses of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk) define specialized behaviour, for example [ControllerTwoWayToggleFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllertwowaytogglefunction-extends-simulatorcontrollerfunction-simulator-controllerahk) can trigger to different action methods, since they have an On and an Off state. See the [class reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference) for details on all subclasses of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk).

### Actions
Instances of [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk) are very simple. They define a label, which might be displayed by the Button Box visual representation and they implement the [fireAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-fireactionfunction--controllerfunction-trigger--string) method, which will be triggered by the function. Although actions might be created and registered to their mode or plugin anytime, normally they are created during the initialization process, most of the time based on configuration data.

### Controller and Button Boxes

The Simulator Controller can give visual feedback for each interaction with a hardware controller. Normally, this feedback will provide some information about the state change, that has been carried out by the last triggered action. For example, a text field below a rotary dial in the visual representation of a Button Box may show the current intensity value for a vibration motor.
The visual representation for the controller hardware will usually be build with the [Gui capabilities](https://www.autohotkey.com/docs/commands/Gui.htm) of the AutoHotkey language. The abstract class [FunctionController](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-functioncontroller-extends-configurationitem-simulator-controllerahk) and its subclass [GuiFunctionController](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-guifunctioncontroller-extends-functioncontroller-simulator-controllerahk) is used to create this visual representation and to interact with the controller and the provided functions and corresonding actions. Subclasses must implement the method [createGui](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-creategui) to implement the user interface for the controller. See [this example](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/Button%20Box%20Plugin.ahk) for a grid based implementation of Button Boxes, for which the layout can be configured using a [graphical editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts). But if you want to create your own subclasses of *GuiFunctionController*, since your controller does not follow a grid like layout, you can use the supplied images for typical Button Box functions provided in the folder [Resources/Button Box Images](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Resources/Button%20Box%20Images) to define your visual elements. Another implementation supports the integration of Stream Decks, but since Stream Decks have their own display, no visual representation is need for them.

## Example

The following example shows some of the concepts introduced above. The code shown here represents a stripped down part the *ACC* Plugin, which comes with the Simulator Controller distribution.

Let's start with the plugin class definition:

	class ACCPlugin extends ControllerPlugin {
		iChatMode := false
		
		Plugin[] {
			Get {
				return kACCPlugin
			}
		}

		class ChatMode extends ControllerMode {
			Mode[] {
				Get {
					return kChatMode
				}
			}
		}
		
		...
		
The class *ACCPlugin* defines one mode class named *ChatMode*. To keep the global namespace as clean as possible, we use an innerclass defintion style. Second the action class, which handles the ingame chat messages, will be defined also as an inner subclass of *ControllerAction*:

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
			this.iChatMode := new this.ChatMode(this)
			
			base.__New(controller, name, configuration)
			
			this.registerMode(this.ChatMode)
		}
		
		runningSimulator() {
			return isACCRunning() ? "Assetto Corsa Competizione" : false
		}
		
		simulatorStartup(simulator) {
			base.simulatorStartup(simulator)
			
			if (inList(this.Simulators, simulator)) {
				this.Controller.setMode(this.iChatMode)
			}
		}
		
		loadFromConfiguration(configuration) {
			base.loadFromConfiguration(configuration)
			
			for descriptor, message in getMultiMapValues(configuration, "Chat Messages", Object()) {
				function := this.Controller.findFunction(descriptor)
				
				if (function != false) {
					message := string2Values("|", message)
				
					this.iChatMode.registerAction(new this.ChatAction(function, message[1], message[2]))
				}
				else
					logMessage(kLogWarn, "Controller function " . descriptor . " not found in plugin " . this.Plugin . " - please check the configuration")
			}
		}
	}
	
In the implementation of *loadFromConfiguration* all chat messages are retrieved from the configuration map, the corresponding controller functions are looked up and actions for each chat message are created and associated with these functions. The actions are registered for the "Chat" mode, thereby assuring, that chat messages will only be available when this mode is active.

The *ACCPlugin* is aware of "Assetto Corsa Competizione", as you can see by the implementation of the *runningSimulator* method above. Since "Assetto Corsa Competizione" might also be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) as a required simulator for this plugin, the "Chat" mode will only be active, i.e. available, when "Assetto Corsa Competizione" is running. As a convenience function, the implmentation of the *simulatorStartup* method  will automatically switch to "Chat" mode, when ACC has been started, thereby making the chat messages available on the hardware controller buttons.

Note: With the introduction of Release 2.0, the *ACC* plugin has become much more capable. The above example shows only a fraction of the functionality of this plugin for didactical reasons.

## Rule Engine

A very important part of many applications of Simulator Controller, especially the Virtual Race Assistants, is the builtin Hybrid Rule Engine. This has been created exclusively for Simulator Controller and requires therefore its own documentation. You can find that documentation in a [separate chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine).

## Debugging

As capable, as the AutoHotkey language is, as bad is it, when it comes to avoiding code errors. I like dynamically typed languages, as long as they support the developer good enough to understand the errors introduced by mixing types of variables and values. AutoHotkey is different. Since everything is build around key/value structured objects and a reference to an unknown key simply yields an empty value, the following expression will execute without error, even if the *myObject* is not of the right type or even *false* itself.

	myObject.methodCall("foo", "bar")[42]

Therefore it can be very annoying to track down errors in AutoHotkey. But there is help available. First of all, use one of the AutoHotkey aware editors with debugging, inspection and single-stepping support. You will find an overview of the available editors [here](https://www.autohotkey.com/docs/AHKL_DBGPClients.htm). Second, and maybe even more important, the Simulator Controller has extensive logging capabilties integrated. Most of the time you can detect a coding error in your plugin simply by looking at the activity trace in the log file. Log files reside in the *Simulator Controller\Logs* folder found in your user *Documents* folder and the log level can be changed using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). But be careful, since at log level *Info*, the log files can grow quite fast.

You can also choose the log level and toogle the debugging mode for a currently running application using the tray context menu of the application. And you can run the ["System Monitor"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#monitoring-health-and-activities) to inspect the logging information during runtime.

It can be very difficult to find problems with the system in full fligt, especially for issues that showed during a session while on the track. For these situations, Simulator Controller provides a kind of replay mode. Make a copy of the *Temp\XXX Data* folder, with *XXX* the three-letter code for the given simulator. Then start "Simulator Controller" with the argument "-replay *dataFolder*" (with *dataFolder* pointing to the beforementioned copy of the data folder).

## Using the Build Tool

A simple build tool is part of the Simulator Controller distribution. It is rule based like the good old Unix make tool and will compile all the applications, that are part of Simulator Controller and put them in the *Binaries* folder. Additionaly, you can define cleanup tasks, for example to clear the *Logs* folder or removing backup files and copy tasks to move files around. You can find the build tool in the *Binaries* folder, it is named *Simulator Tools.exe*. Simply start it with a double click and it will scan all source files and will recreate all outdated executables..

The build rules are defined in the file *Simulator Tools.targets* in the *Config* folder. A typical build rule will look like this:

	Simulator Controller=
		%kBinariesDirectory%Simulator Controller.exe <- %kSourcesDirectory%Controller\Simulator Controller.ahk;
														%kFrameworkDirectory%, %kSourcesDirectory%Controller\Plugins\

Note: You cannot normally format the rules like in this example, since due to technical restrictions, the complete rule must be kept on one line without CRs or LFs.

This rule defines the *Simulator Controller.exe* application in the *Binaries* folder as the target. The main source file will be *Sources\Controller\Simulator Controller.ahk* and there are additional files in the *Includes* and in the *Plugins* folders, that will be checked for modification. Variables enclosed in "%" will be replaced with theirs current runtime values.

Beside these customizable rules, a *special* rule exists, which integrates the *Visual Studio MSBuild* process. This rule looks like this:

	dotNET Applications && DLLs=Special

To use this, you must also set the path to the *MSBuild Bin* directory using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). If this path is set, *Simulator Tools* searches the *Sources\Foreign* folder for "*.sln" files and runs *MSBuild* on them.

Normally you will never need to change the build rules when developing your own plugins, as long as they will reside in the standard *Plugins* folders. But, if you decide to put them elsewhere, you might want to add an dependency to this place. To do this, copy *Simulator Tools.targets* to the *Simulator Controller\Config* folder, which is located in the *Documents* folder in your user home folder.

You can decide which targets you want to include in your build run by holding down the Control key when starting the build tool. A small window will open where you can activate or deactivate all the targets. This settings will be saved for all consecutive runs of the build tool.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Build%20Tool.JPG)

You can also choose a [splash screen](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#splash-screen-editor) here for your entertainment, while waiting for the build tool to finish.

Note: You can cancel a build run anytime by pressing the Escape key.

## Customizing the Configuration Tool

Since Release 2.7, the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) has been extended with a plugin mechanism as well, to allow developers to create specialized configuration editors, that are integrated in the configuration tool. Each plugin cam define one or more tabs to be integrated into the configuration tool tabbed editor view.

When the configuration tool starts up, in a first step a single file in the [Sources/Plugins](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Sources/Plugins) folder will be included using the AutoHotkey #Include directive: [Configuration Plugins.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/Configuration%20Plugins.ahk). This will load all the plugins for the configuration tool that are part of the standard distribution of Simulator Controller. To allow you to create and include your own plugins without needing to modify the above file, a second initially empty *Configuration Plugins.ahk* will be included from the special location *Simulator Controller\Plugins* folder, which is located in your *Documents* folder. This special location has been created by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) and will not be overwritten by future distributions of Simulator Controller. So feel free to include your own plugins from this second *Configuration Plugins.ahk* file.

A plugin must create an object that implements the protocol shown below, and must register this object with the configuration tool by calling

	editor := ConfigurationEditor.Instance
	editor.registerConfigurator(translate("Chat"), new ChatMessagesConfigurator(editor.Configuration))
	
The first argument for [registerConfigurator](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#registerconfiguratorlabel--string-configurator--configurationitem) must supply a label for the editor tab used for the configuration plugin and the second argument represents the configurator object mentioned above. Before you register your own configurators, you can remove one or more of the predefined configurators using the method *unregisterConfigurator* of the editor:

	editor := ConfigurationEditor.Instance
	editor.unregisterConfigurator(translate("Chat"))

This will remove the chat messages tab from the configuration tool. Instead of supplying a localized label, you can also supply the configurator object itself to the call. The editor provides a property, *editor.Configurators*, to get your hands on those objects.

The protocol, a configurator object has to implement, is quite simple:

	class MyConfigurator extends ConfigurationItem {
		createGui(editor :: ConfigurationEditor, x :: Integer, y :: Integer, width :: Integer, height :: Integer) { ... }

		loadFromConfiguration(configuration :: ConfigurationMap) { ... }

		saveToConfiguration(configuration :: ConfigurationMap) { ... }
	}
	
The method *createGui* is called by the *editor* to create the controls for the configuration plugin. All controls must be created using the AutoHotkey *Gui* command in the window defined by *editor.Window* in the boundaries *x* <-> (*x* + *width*) and *y* <-> (*y* + *height*).
*loadFromConfiguration* (inherited from [ConfigurationItem][https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-configurationahk]) is called during the initialization process. It must load the initial state from the configuration. Please note, that the *createGui* method had not been called yet. The third method of the protocol, *saveToConfiguration*, will be called, whenever the user wants to save the current state of the configuration tool.

Please take a look at the documentation of [ConfigurationEditor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-configurationeditor-extends-configurationitem-simulator-multimapahk) and [ConfigurationItemList](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitemlist-extends-configurationitem-simulator-multimapahk) in the classes reference on [Configuration Editor Classes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#configuration-editor-classes) for more information. Especially, if your configuration has multiple items or aspects and you want to present them using a list, the abstract class *ConfigurationItemList* will be very helpful as a building block.

## Localization and Translation

Simulator Controller supports multiple cultures and translations. The internal handling of textual data is based on double-byte characters and the user interface uses standard Windows widgets, which can be customized to support any script, even right to left writing. A user of the Simulator Controller applications can choose between different languages for the user interface and he also has the choice between different units for the values of temperature, pressure, and so on, as well as the display format of numbers, time, etc. during the configuration process.

To support translation, all Simulator Controller applications use external, text-based files for the language specific texts of all user interface elements. The Assistants use language specific [grammar files](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Engineer-Commands-(EN)) for all voice command patterns as well as the phrases spoken by them. And there are a couple more language specific definitions, for example, for Button Box action labels, settings in the configuration and so on.

For most files used in the translation process, Simulator Controller provides a kind of inheritance mechanism, which allow you to modify all or only small parts of a given translation, or to create a completely new translation not already supported by the standard distribution. To support this, the applications of Simulator Controller searches different directories and the loads the files found in these directories in specific order, so that user specific definitions can *overwrite* definitions in the standard distribution.

IMPORTANT: If you want to work on translation files, be sure to use a Unicode-capable text editor, like notepad++, and be sure to save all files containing language specific texts in the "UTF-16" format with little endian byte order. You can use *\n* to represent a new line in a given text and you must use *\\* to create a backslash, of course.

All translation files are located somewhere inside the *Resources* directory in the distribution package. The specific locations are mentioned for each of the different files in the sections below. You can make copies of the these files and compare it always to the original file whenever you have installed a new release, so that you will be informed about any additions or changes in the original file. Once you are done with the translation, you can send me the translated files, and I will make a quality check and integrate everything into the standard distribution.

If you are a seasoned developer you can also create a translation branch of the "Development" branch of the [Simulator Controller project on GitHub](https://github.com/SeriousOldMan/Simulator-Controller) and create a Pull reuqest, once you are done with the translations. BUT: In this case, always translate the original files located in the *Sources* folder, because all files in the *Resources* folder of the distribution package are only copies of the original files from the *Sources* folder, which are created during the build process.

### Translation of the user interface

The translation of the user interface elements uses a couple of different files for different purposes. Below you will find an introduction for each type of translation file.

#### Texts used in windows and dialogs

A file used for user interface element translation is named "Translations.LC", where *LC* stands for an ISO language code, for exmple *EN*, *DE*, and so on. The standard location of this file is *Resources\Translations* in the program installation folder. The first two lines of the file must contain the language code and the language label.

	[Locale]
	DE=>Deutsch

After that you can have any number of sections with translations which look like this:

	[General]
	Yes=>Ja
	No=>Nein
	Always=>Immer
	Never=>Niemals
	Done=>Fertig
	Ok=>Ok
	Cancel=>Abbrechen
	Select=>Auswählen

The section "[General]" is only used to structure the content and is ignored while reading the translation file. As you can see, the original text is always in English, since the untranslated base version of Simulator Controller uses the English language.

IMPORTANT: Leading and trainling spaces in the original texts are important and must be included in the translated text accordingly. Examples:

	 at line => in der Zeile 
	": =>": 
	           Running =>           Starte 

When you want substitute your own translations, you don't have to copy the whole original file of a given language translation, you only have to provide those translations, you want to change. Example:

	[Locale]
	DE=>Deutsch
	[General]
	Yes=>Aber natürlich
	No=>Auf keinen Fall

As you can see, you have to provide the "[Locale]" header and the two line for the translations of "Yes" and "No". Store this file as "Translations.de" in the *Simulator Controller\Translations* folder in your user *Documents* folder, where it will be found during loading. You can also use the [translations editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#translations-editor) for small changes to a given language translation, but I do not recommend to use this tool to introduce a full new language. It will be way faster to use a Unicode-capable text editor like notepadd++ for this purpose.

Good to know: You can enable the [*Debug* mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-configuration-tool) in "Simulator Configuration" to create a file "Translations.report" in the *Temp* directory. This file contains information about missing or duplicate translations.

#### Consent dialog

The translation of the texts in the Consent dialog are placed in a separate file named "Consent.LC", with *LC* being the language code. The location of the original file and the user specific translation is the same as for general translation files, but the structure is a little bit different. The file transatlion file introduce three different texts named "Introduction", "Information" and "Warning". If you want to create support for a new language, make a copy of the original "Consent.en" file and replace the texts accordingly.

#### Button Box action labels

The visual representation of a Button Box can display the names (labels) of currently available actions in a special window. The texts for these labels can be translated, of course, and are placed in a file named "Controller Action Labels.LC", where *LC* is the language code. The location of the original file and the user specific translation is the same as for general translation files, but the structure is also a little bit different. Example:

	[Tactile Feedback]
	TC.Dial=TC
	TC.Increase=Mehr\nTC
	TC.Decrease=Weniger\nTC
	ABS.Dial=ABS
	ABS.Increase=Mehr\nABS

The section label "[Tactile Feedback]" here is important and names the plugin (or module), for which the following translations are for. Each line represents the label of a gicen action, where the left side is the unique, symbolic name of the action and the right side the language specific label to be used. Please note, that *\n* stands for a new line. As with all translation files, you only have to provide those lines, you want to translate, incl. section label, or you can create a translation for a complete new language.

#### Handling issues and car settings in "Setup Workbench"

Also a special case and maybe a candidate to keep the original English terms, since English is the language of the Engineers. The file "Setup Workbench.LC", where *LC* stands for the language code, introduces language specific labels for handling issues and car settings. If you want to supply translations or if you want to introduce a whole new language, follow the structure of the original file, similar to *Button Box action labels*.

#### Settings in the "Session Database"

Another special case, the translations for the (race) settings available in the "Session Database". Before you translate this stuff, make yourself familar with the "Race Settings" area in the "Session Database" and read the documentation about the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Settings). The original translation files are named "Settings.LC", where *LC* again is the language code. 

### Translation of Assistant grammars

The voice command patterns and also the phrases spoken by the Assistants can be translated as well. Also you can provide modified elements for an already available language using the same mechanism as described above, or you can introduce a whole new language.

The orignal files can be found in the directory *Resources\Grammars* in the program installation folder. You can place your own tranlation files in the *Simulator Controller\Grammars* directory in your user *Documents* folder. The files follow the following naming pattern:

	ASSISTANT.grammars.LC

where *ASSISTANT* is the type of the Assistant, for example "Race Engineer", and where *LC* stands for the language code. The content of the grammar files introduce a couple of required sections:

#### Grammar type

	[Configuration]
	Recognizer=Grammar
	
The value for *Recognizer* can be either "Grammar" which defines that only pattern based voice commands are used, or "Text", when the Assistant has a full understanding of language like ChatGPT, or "Mixed", when you want to use both types. If you translate a grammar file, don't change this.

#### Text fragments

	[Fragments]
	FrontLeft=vorne links
	FrontRight=vorne rechts
	RearLeft=hinten links
	RearRight=hinten rechts

Introduces kind of building blocks and variables for the rest of the grammar.

#### Choices of alternatives

	[Choices]
	Announcements=Benzinmangel Warnungen, Schadenswarnungen, Schadensanalysen, Wetterwarnungen, Luftdruckwarnungen

Also a kind of variable, but with multiple alternative values.

#### Patterns for voice commands

	[Listener Grammars]
	TyrePressures=[(GibMir) {die, die kalten, die Setup} {Reifendrücke, Reifen Drücke, aktuellen Reifendrücke, aktuellen Reifen Drücke, Drücke in den Reifen, Drücke in den kalten Reifen}, (KannstDu) (Mir) {die, die kalten, die Setup} {Reifendrücke, Reifen Drücke} {durchgeben, durchgeben bitte, bitte durchgeben}]
	TyreTemperatures=[(GibMir) die {Reifentemperaturen, Reifen Temperaturen, Temperaturen der Reifen im Moment}, (KannstDu) (Mir) die {Reifentemperaturen, Reifen Temperaturen, Temperaturen der Reifen im Moment} {durchgeben, durchgeben bitte, bitte durchgeben}]
	TyreWear={Sag mir, Überprüfe mal, Überprüfe bitte mal, Bitte überprüfe} {den Reifenverschleiß, den Verschleiß der Reifen, den Reifenverschleiß im Moment, den Verschleiß der Reifen im Moment}

Voice commands are defined using a kind of rule based grammar. Please read the introduction to this kind of pattern grammars [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Spotter-Commands-(EN)#syntax) before creating a translation.

#### Phrases for texts spoken by the Assistants

	[Speaker Phrases]
	GreetingEngineer.1=Hi %driver%, hier ist %name%. Ich bin heute für Deinen Wagen zuständig.
	GreetingEngineer.2=Hier ist %name%. Ich kümmere mich heute um Deinen Wagen.
	GreetingEngineer.3=Hier ist %name%.

Every phrase spoken by an Assistant has a unique name, "GreetingEngineer" in this example. You can supply alternatives by appending a dot and a number to the speech name. Those numbers must start with *1* and must be consecutive without any gap. You may use variables in the phrase. %driver% and %name% (the name of the Assistant) are always available, other variables are specific for a given phrase. Those variables may not be translated, of course.

#### Modularization of grammar files

You may have noticed, that the grammar files support a kind of include mechanism. This is very helpful, since the Assistants share a set of common commands and domain specific fragments. To include a language specific file use the *#Include* statement:

	#Include Fragments.de

### Instructions for the GPT-based Driving Coach

The instructions are used to provide the LLM of the Driving Coach with information about the personality of the coach or to transfer context specific data to the LLM. All instructions are used as defaults in the configuration for the Driving Coach and can be altered by the user. The language specific default instructions can be found in *Resources\Translations* in the programm installation folder. They are named 

	Driving Coach.instructions.LC

where *LC* stands for the language code.

### Instructions for the GPT-based Assistant Boosters

Very much like the Driving Coach, a GPT service can be used to extend the conversational and behavioral capabilities fo the *normal* Race Assistants. In those cases, instructions are also used to create a setting for the LLM to behave like an Engineer, for example, and also to provide additional data about the current session, the state of the car, and so on, to the LLM. All instructions are used as defaults in the configuration and can be altered by the user here as well. The language specific default instructions can be found in *Resources\Translations* in the programm installation folder. They are named 

	Conversation Booster.instructions.LC
	
	and
	
	Agent Booster.instructions.LC

where *LC* stands for the language code.

### Translation of "Simulator Setup"

The setup and configuration tool "Simulator Setup" contains lots of help texts which are not handled as part of the normal user interface translation. Fruthermore, there exists no inheritance mechanism to introduce user specific translations. And to make things a lttile bit more complicated, these texts use HTML as their representation and contain embedded pictures. Any changes to the translations of the help texts must therefore be done in the normal development process. The translation files can be found in *Resources\Setup\Translations* in the programm installation folder.