# Configuration Classes

The following classes are defined in the [Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk) script. They define objects, that can be loaded from or can be saved to a configuration file maintained by the setup tool (*). Many of these classes will be subclassed and extended with more functionality in other files of the Simulator Controller framework, especially in the script [Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk). These classes are described further down [below](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controller-classes).


## [Abstract] ConfigurationItem ([Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk))

This is the base class for all objects, that can be stored to or retrieved from a configuration file. Generally, configurations are maintaned by the setup tool (*). During runtime, all configuration items are accessible through the global constant *kSimulatorConfiguration*.

### Public Properties

#### *Configuration[]*
The configuration map, this item belongs to, or *false*, if the item wasn't created from a configuration.

### Public Methods

#### *__New(configuration :: ConfigurationMap := false)*
If the optional configuration map has been supplied, the method loadFromConfiguration will be invoked automatically.

#### *loadFromConfiguration(configuration :: ConfigurationMap)*
May be overriden by a subclass to read and initialize the item instance variables from the given configuration map. Implementations may generally look like this:

	loadFromConfiguration(configuration) {
		base.loadFromConfiguration(configuration)

		for functionDescriptor, descriptorValues in getConfigurationSectionValues(configuration, "Controller Functions", Object()) {
			functionDescriptor := ConfigurationItem.splitDescriptor(functionDescriptor)
			
			if ((functionDescriptor[1] == this.Type) && (functionDescriptor[2] == this.Number))
				this.loadFromDescriptor(functionDescriptor[3], descriptorValues)
		}
	}

#### *saveToConfiguration(configuration :: ConfigurationMap)*
Typically invoked by the setup tool, this method needs to write the item state to the configuration map. Implementations may generally look like this:

	saveToConfiguration(configuration) {
		base.saveToConfiguration(configuration)
		
		descriptor := this.Descriptor
		
		for ignore, trigger in this.Trigger {
			setConfigurationValue(configuration, "Controller Functions", descriptor . "." . trigger, this.Hotkeys[trigger, true])
			setConfigurationValue(configuration, "Controller Functions", descriptor . "." . trigger . " Action", this.Actions[trigger, true])
		}
	}

#### [Class Method] *descriptor(#rest values)*
Returns a descriptor string to identify a configuration item in a configuration map. For example, calling *ConfigurationItem.descriptor("Button", 5)* yields "Button.5" as its result.

#### [Class Method] *splitDescriptor(descriptor :: String)*
Returns an array with all different parts of the supplied descriptor string.

***

## Application extends [ConfigurationItem](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk) ([Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk))
This configuration item represents an application on the current Windows installation.

### Public Properties

#### *Application[]*
Returns the logical name of this application.

#### *ExePath[]*
Returns the name of the executable file in the file system.
	
#### *WorkingDirectory[]*
Returns the directory, where the application will be executed.
	
#### *WindowTitle[]*
Returns the pattern used to identify an active window for the given application. Fully supports the AutoHotkey *winTitle* syntax. See the AutoHotkey [documentation](https://www.autohotkey.com/docs/misc/WinTitle.htm) for reference.
	
#### *SpecialStartup[]*
Returns the name of a script function to be invoked as a special startup method, or false, if no special startup method is applicable. Special startup methods may be defined to perform some additional tasks, after an application has been started, or to provide a custom splash screen, for example. See the [ACC Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Plugins/ACC%20Plugin.ahk) for an example of a custom splash screen.

#### *SpecialShutdown[]*
Returns the name of a script function to be invoked as a special shutdown method, or false, if no special shutdown method is applicable. Ses the ACC Plugin mentioned above for an example as well.
	
#### *SpecialIsRunning[]*
Returns the name of the special script function used to test whether the application is running, or false, if no special method is applicable.
	
#### *CurrentPID[]*
If the application is running and has been started by the *startup* method below, this property returns the Windows process id associated with the running process.

### Public Methods

#### *__New(application :: String, configuration :: ConfigurationMap := false, exePath :: String := "", workingDirectory :: String := "", windowTitle :: String := "", specialStartup :: String := "", specialShutdown :: String := "", specialIsRunning :: String := "")*
Constructs a new configurable application item. If the configuration argument is not supplied or *false*, all properties may be set with corresponding arguments.

#### *startup(special :: Boolean := true, wait :: Boolean := false, options :: String := "")*
Starts the given application and returns the process id. If *special* is supplied and *false*, a potential special startup method will not be used. If *wait* is supplied and *true*, the call to *startup* will wait until the application terminates and the result code will be returned instead of the process id. *options* are passed to the underlying [*Run* or *RunWait*](https://www.autohotkey.com/docs/commands/Run.htm) command of AutoHotkey.

#### *shutdown(special :: Boolean := true)*
Stops the given application, potentially using a special method, if defined and not suppressed by supplying *special* as *false*.

#### *isRunning(special :: Boolean := true)*
Returns *true*, if the application is currently running, potentially using the defined special function.

#### [Class Method] *run(application :: String, exePath :: String, workingDirectory :: String, options :: String := "", wait :: Boolean := false)*
Low level method to start Windows applications. See above functions for an explanation of all the parameters.

***

## [Abstract] Function extends [ConfigurationItem](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk) ([Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk))
This abstract class defines the protocol for all functions available for a given controller hardware. A function, which might be buttons, dials and swwitches, defines actions, which react to triggers. To connect to the underlying hardware, a controller function defines several hotkeys (*) per trigger, which is used by AutoHotkey to detect that a button has been pressed, a dial rotated and so on. At this point, the actions that might be triggered can be simple function calls in the script language, but more versatile capabilites will be defined by the [plugin framework](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#overview), where actions will be implemented by specialized classes.

### Public Properties

#### [Abstract] *Type[]*
Returns the [type constant](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#controller-function-types-constantsahk) of the given function. This property must be implemented by a concrete subclass.
	
#### *Number[]*
Returns the running number of the controller function. For example Button # 3...
	
#### *Descriptor[]*
The resource descriptor of the given function. Typically looks like "Button.3" or "Dial.2".
	
#### [Abstract] *Trigger[]*
Returns a list of all triggers available for this controller function. A button class might return ["Push"], beacause only this single functionality is provided, whereas a dial function might return ["Increase", "Decrease"].
	
#### *Hotkeys[trigger :: String := false, asText :: Boolean := false]*
Returns all the hotkeys for all triggers handled by this controller function. Depending on the first argument, this might be a map for all triggers or the result for one specific trigger. The second argument determines, what is returned for a specific trigger, either directly or as part of the map. When *asText* is not supplied or false, a list of all hotkeys is returned. If supplied and *true*, one single string representation is returned, where all the hotkeys are delimited by " | ", for example "<^<!F1 | Joy2".

#### *Actions[trigger :: String := false, asText :: Boolean := false]*
Similar to the *Hotkeys* property, this property returns the defined actions. The textual representation of an action looks like a script fragment, like "startSimulator(Assetto Corsa Competizione)", whereas the non-text representation is a callable function object.

### Public Methods

#### *__New(functionNumber :: Integer, configuration :: ConfigurationMap := false, #rest hotkeyActions)*
Constructs a new controller function. If *configuration* is not supplied, the hotkeys and actions must be supplied as string arguments for all triggers in the order returned by the *Trigger[]* property. The class factory method *createFunction* may be used to create an instance of a specific subclass.

#### *fireAction(trigger)*
Calls the action function defined for the given trigger, if any.

#### [Class Factory Method] *createFunction(descriptor :: String, configuration :: ConfigurationMap := false, onHotkeys :: String := false, onAction :: String := false, offHotkeys :: String := false, offAction :: String := false)*
Creates an instance of a specific subclass of *Function* according to the given descriptor. If *configuration* is *false*, the additional arguments may be used to initialize hotkeys and triggerable actions in the order of the defined triggers returned by the property *Trigger[]*.

***

## 2WayToggleFunction extends [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk) ([Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk))
Concrete implementation for two state toggle switches, like On/Off switches. The triggers returned by *Trigger[]* are ["On", "Off"].

***

## 1WayToggleFunction extends [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk) ([Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk))
Concrete implementation for single state switches, for example a momentary ignition switch. The triggers returned by *Trigger[]* are ["On"].

***

## ButtonFunction extends [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk) ([Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk))
Concrete implementation for simple push buttons. The triggers returned by *Trigger[]* are ["Push"].

***

## DialFunction extends [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk) ([Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk))
Concrete implementation for rotary dials. The triggers returned by *Trigger[]* are ["Increase", "Decrease"] for the two different rotary directions.

***

## CustomFunction extends [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk) ([Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk))
Concrete implementation for custom or external function. The triggers returned by *Trigger[]* are ["Call"] for a generic activation of the function. Normally, custom functions are not bound to a hardware controller, but serve as an interface for other event sources, like a voice control software or a keyboard macro tool.

***

## Plugin extends [ConfigurationItem](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk) ([Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk))
A plugin is used by the Simulator Controller framework to integrate custome code and extensions. Plugins can be configured by the setup tool (*). Especially the more complex plugins may define a set of configuration parameters to define the function mapping, initial values for dynamic parameters, and so on. A special subclass named ControllerPlugin (*) exists, which provides additional functionality to interact with the single instance of [SimulatorController](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-simulatorcontroller-extends-configurationitem-simulator-controllerahk), handle plugin modes and connect to controller functions. The base class *Plugin* only provides the functionality necessary for configuration handling.

### Public Properties

#### *Plugin[]*
Returns the name of the plugin.

#### *Active[]*
Returns *true*, if the plugin is to be considered active according to the configuration.
	
#### *Simulators[]*
Returns a list of names of simulation games, this plugin is aware of. In the default implementation, the modes of a given plugin will only be active, if one of these simulators are running. If the list is empty, the plugin and its modes are independently active.

#### *Arguments[asText := false]*
Returns a map of all arguments supplied to the plugin, or, if, *asText* has been supplied and is *true*, a string representation, which can be stored in the configuration map.

### Public Methods

#### *__New(plugin :: String, configuration :: ConfigurationMap := false, active :: Boolean := false, simulators :: String := "", arguments :: String := "")*
Constructs a new plugin instance. If *configuration* has been supplied, the instance is initialized from the configuration. Otherwise the *simulators* may be a ","-delimited string of simulator names and arguments might supply all the plugin arguments also in their texutal representation, which follows the following format: "parameter1: value11, value12, value13; parameter2: value21, value22; ..."

#### *hasArgument(parameter)*
Returns *true*, if an argument with values has been supplied for the given parameter name.
	
#### *getArgumentValue(argument, default := false)*
Returns the values for the given argument as string, or the supplied *default* value otherwise.
	
***
***

# Controller Classes

All the following classes are part of the Simulator Controller core framework defined in the [Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk) script. In many cases they are based upon one of the configuration classes above.

## [Singleton] SimulatorController extends [ConfigurationItem](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk) ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
This class implements the core functionality of Simulator Controller. The single instance manages a set of plugins and the connection between hardware functions of a given controller or button box and the actions implemented by these plugins.

### Public Properties

#### *ControllerConfiguration[]*
Returns the controller configuration map, not to be confused with the complete simulator configration map. This small configuration defines settings for controller notifications such as tray tips and buttonbox visuals and is maintained by the configuration tool (*).
	
#### *ButtonBox[]*
Returns an instance of the singleton class ButtonBox (*). This instance must be created by a specialized plugin. See [this simple example](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Plugins/ButtonBox%20Plugin.ahk) for reference.
	
#### *Functions[]*
Returns a list of all functions defined by all registered plugins.
	
#### *Plugins[]*
Returns a list of all registered pluings. Some of these plugins might be inactive according to the configuration.
	
#### *Modes[]*
A list of all modes defined by all plugins. Here also, not all modes might be active in a given situation.
	
#### *ActiveMode[]*
The currently active mode. This mode defines the currently active layer of controller functions and actions on your hardware controller.
	
#### *ActiveSimulator[]*
If a simulation game is currently running, the name of this application is returned by this property.
	
#### *LastEvent[]*
This property returns an integer representing the time of the last hardware event as reported by the special AutoHotkey variable [A_TickCount](https://www.autohotkey.com/docs/Variables.htm#TickCount).

#### [Class Property] *Instance[]*
Returns the single instance of *SimulatorController*.

### Public Methods

#### *__New(simulatorConfiguration :: ConfigurationMap, controllerConfiguration :: ConfigurationMap)*
Constructs a new *SimulatorController* instance. Both configuration parameters are required. The first expects the general simulator contfiguration map (see [kSimulatorConfiguration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#global-configuration-map-constantsahk) for reference), the second is the small configuration map maintained by the configuration tool (*) and stored in a configuration file referenced by [kControllerConfigurationFile](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#ksimulatorconfigurationfile-kcontrollerconfigurationfile).
Since *SimulatorController* is a singleton class, the single instance might be accessed after construction by referencing *SimulatorController.Instance*.

#### [Factory Method] *createControllerFunction(descriptor :: String, configuration :: ConfigurationMap)*
Returns an instance of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk) according to the givven descriptor.

#### *findPlugin(name :: String)*
Searches for a plugin with the given name. Returns *false*, if not found.

#### *findMode(name :: String)*
Searches for a mode with the given name. Returns *false*, if not found.

#### *findFunction(name :: String)*
Searches for a controller function with the given descriptor. Returns *false*, if not found.

#### *findAction(function :: ControllerFunction, trigger :: String)*
Searches for a controller action for the given function / trigger combination. Only currently active actions, which are bound to a function by their mode or plugin, are considered. Returns *false*, if not found.

#### *registerPlugin(plugin :: ControllerPlugin)*
Registers the given plugin for the controller. If the plugin is active, the *activate* method will be invoked, thereby allowing the plugin to register some actions for controller functions.

Note: Normally, this method is called by the constructor of the plugin. Therefore it is in many cases unnecessary to call *registerPlugin* directly. But depending on initialization order, where modes and actions have been defined after the basic instance construction, a second activation of the plugin might be necessary. All side effects of *registerPlugin* are idempotent, so you can call it as many times you like. 

#### *registerMode(plugin :: ControllerPlugin, mode :: ControllerMode)*
Registers the given mode of the given plugin for the controller.

Note: Normally, this method is called by the *registerMode* method of the plugin. Therefore it is almost always unnecessary to call *registerMode* for the controller directly. But, since all side effects of *registerMode* are idempotent, so you can call it for your peace of mind as often as you like.

#### *isActive(modeOrPlugin :: TypeUnion(ControllerPlugin, ControllerMode))*
Returns *true*, if the given plugin or mode is active. Plugins may be deactivated according to configuration information, whereas modes may be deactivated based on a dynamic test. For example, modes might only be active, if a simulator game is running.

#### *runningSimulator()*
Returns the name of the currently running simulation game or *false*, if no simulation is running, *false* is returned.

#### *simulatorStartup(simulator :: String)*
This method is called when a simulation is starting up. The info is distributed to all registered plugins.

#### *simulatorShutdown()*
This method is called when a simulation has terminated. The info is distributed to all registered plugins.

#### *connectAction(function :: ControllerFunction, action :: ControllerAction)*
Connects a given action unambiguously to the given function. All future activation of the function by the controller hardware will trigger the given action. Normally, *connectAction* is called during activation (*) of plugins and modes.

#### *disconnectAction(function :: ControllerFunction, action :: ControllerAction)*
Disconnects the given action from the given function. Normally, *disconnectAction* is called during deactivation (*) of plugins and modes.

#### *fireAction(function :: ControllerFunction, trigger :: String)*
This is some sort of dispatcher method, since in the end, the fireAction (*) method of the corresponding action is called. This action is retrieved using [findAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#findactionfunction--controllerfunction-trigger--string).

#### *setMode(newMode :: ControllerMode)*
Switches the controller to a different mode. The currently active mode will receive a deactivation and the new mode will be activated, thereby connecting all its actions to the correspondiing controller functions.

***

## [Abstract] ControllerFunction ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
This is the root class of all controller functions used by the Simulator Controller framework. Due to restrictions in the AutoHotkey language (no multiple inheritance or multiple interface implementation capabilities) , this class (and all of its subclasses) does not inherit from the configurable [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk) class. But the protocol of *Function* is completely implemented and *ControllerFunction* and its descendants use some sort of delegation pattern to connect to the configuration information.

### Public Properties

#### *Controller[]*
Returns the controller, for which this function has been defined.

#### *Function[]*
Returns the wrapped original class, an instance of [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk).

#### *Type[]*
Returns the [type constant](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#controller-function-types-constantsahk) of the given function. This property must be implemented by a concrete subclass.
	
#### *Number[]*
Returns the running number of the controller function. For example Button # 3...
	
#### *Descriptor[]*
The resource descriptor of the given function. Typically looks like "Button.3" or "Dial.2".
	
#### *Trigger[]*
Returns a list of all triggers available for this controller function. A button class might return ["Push"], beacause only this single functionality is provided, whereas a dial function might return ["Increase", "Decrease"].
	
#### *Hotkeys[trigger :: String := false]*
Returns all the hotkeys for all triggers handled by this controller function. Depending on the argument, this might be a map for all triggers or the result for one specific trigger. See the [original method](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#hotkeystrigger--string--false-astext--boolean--false) in *Function* for more information.

#### *Actions[trigger :: String := false]*
Similar to the *Hotkeys* property, this property returns the defined actions. See the [original method](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#actionstrigger--string--false-astext--boolean--false) in *Function* for more information.

### Public Methods

#### *__New(controller :: SimulatorController, function :: Function)*
Constructs an instance of *ControllerFunction*. The supplied *function* must be an instance of wrapped class [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk), which provides the configuration information.

#### *enable(trigger :: String)*
Enables the given trigger (for example "Push") for this controller function, which means, that the connected action can be triggered by the hardware controller.

#### *disable(trigger :: String)*
Disables the given trigger (for example "Push") for this controller function, which means, that the connected action cannot be triggered anymore by the hardware controller.

#### *setText(test :: String, color :: String := "Black")*
If the controller has an associated visual representation of the hardware controller, label of the function might be changed with this method. The given color must be a defined HTML color descriptor.

#### *connectAction(action :: ControllerAction)*
Connects or binds the function to the given action. From now on, every trigger of the hardware controller will result in an activation of the [fireAction](*) method of the action, as long as the function is currently enabled for the trigger in question. Functions will be connected normally during the activation of plugins or modes.

#### *disconnectAction(action :: ControllerAction)*
Disconnects the function from the given action. Functions will be disconnected normally during the deactivation of plugins or modes.

***

## Controller2WayToggleFunction extends [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk) ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
Concrete implementation for two state toggle switches, like On/Off switches. The triggers returned by *Trigger[]* are ["On", "Off"].

***

## Controller1WayToggleFunction extends [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk) ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
Concrete implementation for single state switches, for example a momentary ignition switch. The triggers returned by *Trigger[]* are ["On"].

***

## ControllerButtonFunction extends [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk) ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
Concrete implementation for simple push buttons. The triggers returned by *Trigger[]* are ["Push"].

***

## ControllerDialFunction extends [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk) ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
Concrete implementation for rotary dials. The triggers returned by *Trigger[]* are ["Increase", "Decrease"] for the two different rotary directions.

***

## ControllerCustomFunction extends [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk) ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
Concrete implementation for custom or external function. The triggers returned by *Trigger[]* are ["Call"] for a generic activation of the function. Normally, custom functions are not bound to a hardware controller, but serve as an interface for other event sources, like a voice control software or a keyboard macro tool.

***
