# Configuration Classes

The following classes are defined in the [Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk) script. They define objects, that can be loaded from or can be saved to a configuration file maintained by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Many of these classes will be subclassed and extended with more functionality in other files of the Simulator Controller framework, especially in the script [Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk). These classes are described [further down below](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controller-classes).

## [Abstract] ConfigurationItem ([Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk))

This is the base class for all objects, that can be stored to or retrieved from a configuration file. Generally, configurations are maintaned by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). During runtime, all configuration data is accessible through the global constant *kSimulatorConfiguration*.

### Public Properties

#### *Configuration[]*
The configuration map this item belongs to, or *false*, if the item wasn't created from a configuration.

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
Typically invoked by the configuration tool, this method needs to write the item state to the configuration map. Implementations may generally look like this:

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
This configuration item represents an application in the current Windows installation.

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
Returns the name of a script function to be invoked as a special startup method, or *false*, if no special startup method is applicable. Special startup methods may be defined to perform some additional tasks, after an application has been started, or to provide a custom splash screen, for example. See the [ACC Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/ACC%20Plugin.ahk) for an example of a custom splash screen.
Important: Script functions used as special startup handler must return the rpocess id of the started application.

#### *SpecialShutdown[]*
Returns the name of a script function to be invoked as a special shutdown method, or *false*, if no special shutdown method is applicable. Ses the ACC Plugin mentioned above for an example as well.
	
#### *SpecialIsRunning[]*
Returns the name of the special script function used to test whether the application is running, or *false*, if no special method is applicable.
	
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
This abstract class defines the protocol for all functions available for a given controller hardware. A function, which might be buttons, dials and swwitches, defines actions, which react to triggers. To connect to the underlying hardware, a controller function defines several [hotkeys](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys) per trigger, which is used by AutoHotkey to detect that a button has been pressed, a dial rotated and so on. At this point, the actions that might be triggered will be simple calls to global function in the script language, but more versatile capabilites will be defined by the [plugin framework](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#overview), where actions will be implemented by specialized classes.

### Public Properties

#### [Abstract] *Type[]*
Returns the [type constant](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#controller-function-types-constantsahk) of the given function. This property must be implemented by a concrete subclass.
	
#### *Number[]*
Returns the running number of the controller function. For example Button # **3**...
	
#### *Descriptor[]*
The resource descriptor of the given function. Typically looks like "Button.3" or "Dial.2".
	
#### [Abstract] *Trigger[]*
Returns a list of all triggers available for this controller function. A button class might return ["Push"], beacause only this single functionality is provided, whereas a dial function might return ["Increase", "Decrease"].
	
#### *Hotkeys[trigger :: String := false, asText :: Boolean := false]*
Returns all the hotkeys for the triggers handled by this controller function. Depending on the first argument, this might be a map for all triggers or the result for one specific trigger. The second argument determines, what is returned for a specific trigger, either directly or as part of the map. When *asText* has not been supplied or is *false*, a list of all hotkeys is returned. If supplied and *true*, one single string representation is returned, where all the hotkeys are delimited by " | ", for example "<^<!F1 | Joy2".

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
Concrete implementation for a custom or external function. The triggers returned by *Trigger[]* are ["Call"] for a generic activation of the function. Normally, custom functions are not bound to a hardware controller, but serve as an interface for other event sources, like a voice control software or a keyboard macro tool.

***

## Plugin extends [ConfigurationItem](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk) ([Classes.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Includes/Classes.ahk))
A plugin is used by the Simulator Controller framework to integrate custom code and extensions. Plugins can be configured by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Especially the more complex plugins may define a set of configuration parameters to define the function mapping, initial values for dynamic parameters, and so on. A special subclass named [ControllerPlugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllerplugin-extends-plugin-simulator-controllerahk) exists, which provides additional functionality to interact with the single instance of [SimulatorController](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-simulatorcontroller-extends-configurationitem-simulator-controllerahk), handle plugin modes and connect to controller functions. The base class *Plugin* only provides the functionality necessary for configuration reading and writing.

### Public Properties

#### *Plugin[]*
Returns the name of the plugin.

#### *Active[]*
Returns *true*, if the plugin is to be considered active according to the configuration.
	
#### *Simulators[]*
Returns a list of names of simulation games, this plugin is aware of. In the default implementation, the modes of a given plugin will only be active, if one of these simulators is currently running. If the list is empty, the plugin and its modes are independently active.

#### *Arguments[asText := false]*
Returns a map of all arguments supplied to the plugin, or, if *asText* has been supplied and is *true*, a string representation, which can be stored in the configuration map.

### Public Methods

#### *__New(plugin :: String, configuration :: ConfigurationMap := false, active :: Boolean := false, simulators :: String := "", arguments :: String := "")*
Constructs a new plugin instance. If *configuration* has been supplied, the instance is initialized from the configuration. Otherwise the *simulators* may be a ","-delimited string of simulator names and arguments might supply all the plugin arguments also in their texutal representation, which follows the following format: "parameter1: value11, value12, value13; parameter2: value21, value22; ..."

#### *hasArgument(parameter :: String)*
Returns *true*, if an argument with values has been supplied for the given parameter name.
	
#### *getArgumentValue(argument :: String, default := false)*
Returns the values for the given argument as string, or the supplied *default* value otherwise.
	
***

# Configuration Editor Classes

The two classes *ConfigurationEditor* and *ConfigurationItemList* implement the configuration tool framework. The conifguration tool can be extended by registering so called configurators, which, in the end, will add a tab in the dialog of the configuration tool. Please see the corresponding documentation on [Customizing the Configuration Tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#customizing-the-configuration-tool) for more information.

## [Singleton] ConfigurationEditor extends [ConfigurationItem](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk) ([Simulator Configuration.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Tools/Simulator%20Configuration.ahk))
This is the main class of the configuration tool. It opens the editor window and creates a tabbed view for all the configurator plugins.

### Public Properties

#### [Class] *Instance[]*
This class property returns the single instance of *ConfigurationEditor*.

#### *Configurators[]*
A list of all registered configurators, which tpically have been provided by configuration plugins by calling [registerConfigurator](*).

#### *AutoSave[]*
Returns *true*, if the user wants each change to be updated automatically.
	
#### *Window[]*
This property returns the short string, which is used by all AutoHotKey *Gui* commands to identify the window of the configuration editor.

### Public Methods

#### *__New(development :: Boolean, configuration :: ConfigurationMap)*
Constructs a new *ConfigurationEditor* instance. If *true* is passed for the first parameter, additional configuration options suitable for development tasks will be available in the first tab of the configuration editor. The second parameter is the configuration, which should be modified.

#### *registerConfigurator(label :: String, configurator :: ConfigurationItem)*
Registers the given configurator and creates a tab with the given label for it in the tabbed view of the configuration editor window. The registered *configurator* object will typically be an instance of a subclass of [ConfigurationItem](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk) and must implement a simple additional protocol, as described in the documentation on [Customizing the Configuration Tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#customizing-the-configuration-tool).

	class MyConfigurator extends ConfigurationItem {
		createGui(editor :: ConfigurationEditor, x :: Integer, y :: Integer, width :: Integer, height :: Integer) { ... }

		loadFromConfiguration(configuration) { ... }

		saveToConfiguration(configuration) { ... }
	}
	
The method *createGui* is called by the *editor* to create the controls for the configuration plugin. All controls must be created using the AutoHotkey *Gui* command in the window defined by *editor.Window* in the boundaries *x* <-> (*x* + *width*) and *y* <-> (*y* + *height*).
*loadFromConfiguration* (inherited from [ConfigurationItem][https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk]) is called during the initialization process. It must load the initial state from the configuration. Please note, that the *createGui* method had not been called yet. The third method of the protocol, *saveToConfiguration* (also inherited from *ConfigurationItem*), will be called, whenever the user wants to save the current state of the configuration tool.

#### *unregisterConfigurator(labelOrConfigurator :: TypeUnion(String, Object))
Removes a configurator (either identified directly as argument or identified by the label, which had been supplied, when registering the configurator), from the configuration tool.

#### *show()*
After all configurators have been registered, *show* will open the editor window for interaction.

#### *hide()*
Makes the main editor window invisble, which might be useful, when a specialized or delegated editor will be opened by one of the plugins.

#### *close()*
Called at the end, after all modifications had been saved (by calling the inherited method [saveToConfiguration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#savetoconfigurationconfiguration--configurationmap)), to finally close and destroy the editor window.

#### *toggleKeyDetector(callback :: TypeUnion(String, FuncObj) := false)*
Calling *toggleKeyDetector* enables or disables a special tool to detect buttons and dials on connected hardware controlles. A small tooltip will follow the mouse and display information as long as these controls are activated. If you supply the *callback*, it will be called with the first pressed control in AutoHotkey [hotkey syntax](https://www.autohotkey.com/docs/KeyList.htm) and the key detector tool will be deactivated automatically.

***

## [Abstract] ConfigurationItemList extends [ConfigurationItem](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk) ([Simulator Configuration.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Tools/Simulator%20Configuration.ahk))
This abstract class implements a list of items, which might be edited with an associated editor. Basis control on item selection, openening and closing the editor area, loading and saving items to and from the editor is already builtin. Please see the [implementation for the "Chat Messages Configuration" plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/Chat%20Messages%20Configuration%20Plugin.ahk) for a simple example of a concrete implementation of *ConfigurationItemList*.

#### *iItemsList :: Array := []*
This variable holds all items of the list. This variable is typically initialized in the implementation of *loadFromConfiguration*.

#### *iCurrentItemIndex :: Integer := 0*
The currently selected line in the list.

#### *ListHandle[]*
Returns the AutoHotkey HNDL for the *ListView* or *ListBox* used for this list widget.

### Public Methods

#### *initializeList(listHandle :: AutoHotkey HNDL, listVariable :: String, addButton :: String := false, deleteButton :: String := false, updateButton :: String := false, upButton :: String := false, downButton :: String := false)*
You call this method at the end of the *createGui* implementation to register your active controls of the list widget. The list widget supports optional "Add", "Delete" and "Save" buttons to control the associated editor area and also optional "Up" and "Down" buttons to control the position of an element in the list. The supplied arguments must be the names of the variables associated with the given control. Additionally, these buttons must have defined corrsponding *g-labels* for the AutoHotkey controls, that are named "addItem", "deleteItem", "updateItem", "upItem" and "downItem" correspondingly. See the documentation on the [AutoHotkey Gui coommand](https://www.autohotkey.com/docs/commands/Gui.htm) for more information. 

#### *associateList(variable :: String, itemList :: ConfigurationItemList)*
This method is called by *initializeList* for each of the supplied variables to register the item list with the given control. Later on, the list can be retrieved during a Gui event by calling *getList*.

#### *getList(variable :: String)*
Returns the instance of *ConfigurationItemList*, which had been associated with the given variable. Normally, there is no need to call this method from your code, since this is part of the event management protocol.

#### *clickEvent(line :: Integer, count :: Integer)*
This method is called, when an item is clicked more than once in the list. The default implementation calls method *openEditor*, which finally will call *loadEditor*.

#### *selectEvent(line :: Integer)*
This method is called, when an item is selected  in the list by using the cursor keys of the keyboard. The default implementation calls *openEditor*, which finally will call *loadEditor*.

#### *openEditor(itemNumber :: Integer)*
Opens and initializes the editor area for the selected item number. This method is part of the event protocol and there is no need to call it directly. *openEditor* finally calls *loadEditor*.

#### *selectItem(itemNumber)*
This method is also part of the event protocol and is called to select a new item in the list, for example after a nw item has been saved from the editor to the list and should be the newly selected item now.

#### *addItem()*, *deleteItem()*, *updateItem()*, *upItem()*, *downItem()*
These methods will be called, whenever one of the buttons, that had been initially registered by calling *initializeList*, are clicked by the user. No need to call them directly, as they are also part of the generic event protocol.

#### *updateState()*
This method is automatically called, whenever a state change occured. It must update all controls to reflect the current state. A state change is for example a new selecion in the list, an updated item in the editor, after the user saved the changes, and so on. The default implementation handles all controls, that had been registered by calling *initializeList*.

#### [Abstract] *loadList(items :: Array)*
This method must be implemented by the concrete subclass of *ConfigurationItemList* to load the given configuration items into the list view or list box.

#### [Abstract] *loadEditor(item :: Object)*
Is calle, whenever an item is selected in the list. The selected *item* is passed to this method and the implementation of this abstract method must initialize all controls from the given item object.

#### [Abstract} *clearEditor()*
Must be implemented by the concrete subclass of *ConfigurationItemList*. *clearEditor* will be called whenever there is no currently selected item in the list. All fields and controls in the editor area should be made empty or reset to their initial state.

#### [Abstract] *buildItemFromEditor(isNew :: Boolean := false)*
This method must also be implemented by the concrete subclass of *ConfigurationItemList*. It is called, whenever the current changes of the item in the editor area should be saved. The method must load the values from all controls and must construct an item of the required structure, which can be anything from a simple string up to a complex object, as long as the variable *iItemsList* and the methods *loadList*, *loadEditor* and *buildItemFromEditor* share the same understanding of this structure.

***

# Controller Classes

All the following classes are part of the Simulator Controller core framework defined in the [Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk) script. In many cases they are based on one of the configuration classes above.

## [Singleton] SimulatorController extends [ConfigurationItem](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk) ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
This class implements the core functionality of Simulator Controller. The single instance manages a set of plugins and the connection between hardware functions of a given controller or Button Box and the actions implemented by these plugins.

### Public Properties

#### [Class] *Instance[]*
This class property returns the single instance of *SimulatorController*.

#### *Settings[]*
Returns the controller configuration map, not to be confused with the complete simulator configration map. This small configuration defines settings for controller notifications such as tray tips and buttonbox visuals and is maintained by the [settings editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--settings).
	
#### *ButtonBoxes[]*
Returns a list all [ButtonBox](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-buttonbox-extends-configurationitem-simulator-controllerahk) instances registered for the controller. These must have been created by a specialized plugin and registered in the controller by calling [registerButtonBox](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#registerbuttonboxbuttonbox--buttonbox). See [this simple example](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/ButtonBox%20Plugin.ahk) for reference.
	
#### *Functions[]*
Returns a list of all functions defined in the underlying configuration.
	
#### *Plugins[]*
Returns a list of all registered plugins. Some of these plugins might be inactive according to the configuration.
	
#### *Modes[]*
A list of all modes defined by all plugins. Here also, not all modes might be active in a given situation.
	
#### *ActiveModes[]*
The currently active modes. These modes define the currently active layer of controller functions and actions on your hardware controllers.

#### *ActiveMode[buttonBox :: ButtonBox}*
Returns the mode, which is currently active for the given buttonBox argument. If more than one mode are active on this Button Box, only the first of these modes is returned.
	
#### *ActiveSimulator[]*
If a simulation game is currently running, the name of this application is returned by this property.
	
#### *LastEvent[]*
This property returns an integer representing the time of the last controller hardware event as reported by the special AutoHotkey variable [A_TickCount](https://www.autohotkey.com/docs/Variables.htm#TickCount).

#### [Class Property] *Instance[]*
Returns the single instance of *SimulatorController*.

### Public Methods

#### *__New(simulatorConfiguration :: ConfigurationMap, settings :: ConfigurationMap)*
Constructs a new *SimulatorController* instance. Both configuration parameters are required. The first expects the general simulator configuration map (see [kSimulatorConfiguration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#global-configuration-map-constantsahk) for reference), the second is the small configuration map maintained by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--configuration) and stored in a configuration file referenced by [kSimulatorSettingsFile](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#ksimulatorconfigurationfile-ksimulatorsettingsfile).
Since *SimulatorController* is a singleton class, the single instance might be accessed after construction by referencing *SimulatorController.Instance*.

#### [Factory Method] *createControllerFunction(descriptor :: String, configuration :: ConfigurationMap)*
Returns an instance of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk) according to the givven descriptor.

#### *findButtonBox(function :: ControllerFunction)*
Return the *ButtonBox* instance, that defines the given function, or *false*, if the function is not associated with a hardware controller.

#### *findPlugin(name :: String)*
Searches for a plugin with the given name. Returns *false*, if not found.

#### *findMode(name :: String)*
Searches for a mode with the given name. Returns *false*, if not found.

#### *findFunction(name :: String)*
Searches for a controller function with the given descriptor. Returns *false*, if not found.

#### *getAction(function :: ControllerFunction, trigger :: String)*
Returns the controller action for the given function / trigger combination. Only currently active actions, which are bound to a function by their mode or plugin, are considered. Returns *false*, if there is no action currently connected to the function.

#### *registerButtonBox(buttonBox :: ButtonBox)*
Registers a visual representation for the hardware controller. This method is automatically called by the constructor of [ButtonBox](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-buttonbox-extends-configurationitem-simulator-controllerahk).

#### *unregisterButtonBox(buttonBox :: ButtonBox)*
Removes a visual representation for the hardware controller from this controller. This method might be called from your own Button Box plugin to remove all predefined Button Box representations before registering your own ones.

#### *registerPlugin(plugin :: ControllerPlugin)*
Registers the given plugin for the controller. If the plugin is active, the *activate* method will be invoked, thereby allowing the plugin to register some actions for controller functions.

Note: Normally, this method is called by the constructor of the plugin. Therefore it is in many cases unnecessary to call *registerPlugin* directly. But depending on initialization order, where modes and actions have been defined after the basic instance construction, a second activation of the plugin might be necessary. All side effects of *registerPlugin* are idempotent, so you can call it as many times you like. 

#### *registerMode(plugin :: ControllerPlugin, mode :: ControllerMode)*
Registers the given mode of the given plugin for the controller.

Note: Normally, this method is called by the *registerMode* method of the plugin. Therefore it is almost always unnecessary to call *registerMode* for the controller directly. But, since all side effects of *registerMode* are idempotent, you can call it for your peace of mind as often as you like.

#### *isActive(modeOrPlugin :: TypeUnion(ControllerPlugin, ControllerMode))*
Returns *true*, if the given plugin or mode is active. Plugins may be deactivated according to configuration information, whereas modes may be deactivated based on a dynamic test, for example, whether a simulator is currently running.

#### *runningSimulator()*
Returns the name of the currently running simulation game or *false*, if no simulation is running.

#### *simulatorStartup(simulator :: String)*
This method is called when a simulation is starting up. The info is distributed to all registered plugins.

#### *simulatorShutdown(simulator :: String)*
This method is called when a simulation has terminated. The info is distributed to all registered plugins.

#### *startSimulator(application :: Application, splashImage :: String := false)*
Starts the simulator represented by the given application. The [startup](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#startupspecial--boolean--true-wait--boolean--false-options--string--) method of *Application* will be called with *false* for the *special* parameter, so that *startSimulator* can be used by a special startup handler provided by plugins without creating an infinite recursion. If *splashImage* is supplied, the startup process will run verbose, showing a splash screen and a progress bar, and possibly playing a startup song. *splashImage* must either be a partial path for a JPG or GIF file relative to [kSplashMediaDirectory](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#ksplashmediadirectory-kbuttonboximagesdirectory-kiconsdirectory), for example "Simulator Splash Images\ACC Splash.jpg", or a partial path relative to the *Simulator Controller\Splash Media* folder, which is located in the *Documents* folder of the current user, or an absolute path. *startSimulator* returns the process id of the application process.

#### *connectAction(function :: ControllerFunction, action :: ControllerAction)*
Connects a given action unambiguously to the given function. All future activation of the function by the controller hardware will trigger the given action. Normally, *connectAction* is called during [activation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#activate) of plugins and modes.

#### *disconnectAction(function :: ControllerFunction, action :: ControllerAction)*
Disconnects the given action from the given function. Normally, *disconnectAction* is called during [deactivation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#deactivate) of plugins and modes.

#### *fireAction(function :: ControllerFunction, trigger :: String)*
This is a dispatcher method, since in the end, the [fireAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-fireactionfunction--controllerfunction-trigger--string) method of the corresponding action is called. This action is retrieved using [getAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#getactionfunction--controllerfunction-trigger--string).

#### *setMode(newMode :: ControllerMode)*
Switches the controller to a different mode. The currently active mode will be [deactivated](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#deactivate) and the new mode will be [activated](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#activate), thereby connecting all its actions to the correspondiing controller functions.

***

## [Abstract] ControllerFunction ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
This is the root class of all controller functions used by the Simulator Controller framework. Due to restrictions in the AutoHotkey language (no multiple inheritance or multiple interface implementation capabilities), this class (and all of its subclasses) does not inherit from the configurable [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk) class. But the protocol of *Function* is completely implemented and *ControllerFunction* and all its descendants use some sort of delegation pattern to connect to the configuration information of *Function*.

### Public Properties

#### *Controller[]*
Returns the controller, for which this function has been defined.

#### *Function[]*
Returns the wrapped original class, an instance of [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk).

#### *Type[]*
Returns the [type constant](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference#controller-function-types-constantsahk) of the given function. This property must be implemented by a concrete subclass.
	
#### *Number[]*
Returns the running number of the controller function. For example Button # **3**...
	
#### *Descriptor[]*
The resource descriptor of the given function. Typically looks like "Button.3" or "Dial.2".

#### *Trigger[]*
Returns a list of all triggers available for this controller function. A button class might return ["Push"], beacause only this single functionality is provided, whereas a dial function might return ["Increase", "Decrease"].
	
#### *Hotkeys[trigger :: String := false]*
Returns all the hotkeys for all triggers handled by this controller function. Depending on the argument, this might be a map for all triggers or the result for one specific trigger. See the [original method](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#hotkeystrigger--string--false-astext--boolean--false) in *Function* for more information.

#### *Actions[trigger :: String := false]*
Similar to the *Hotkeys* property, this property returns the defined actions. See the [original method](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#actionstrigger--string--false-astext--boolean--false) in *Function* for more information. The actions returned here will be function objects, that in the end will activate the *fireAction* method of [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk). 

### Public Methods

#### *__New(controller :: SimulatorController, function :: Function)*
Constructs an instance of *ControllerFunction*. The supplied *function* must be an instance of the wrapped class [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk), which provides the configuration information.

#### *enable(trigger :: String := false)*
Enables the given trigger (for example "Push") for this controller function, which means, that the connected action can be triggered by the hardware controller. If *trigger* is not supplied, all triggers will be enabled.

#### *disable(trigger :: String := false)*
Disables the given trigger (for example "Push") for this controller function, which means, that the connected action cannot be triggered anymore by the hardware controller. If *trigger* is not supplied, all triggers will be disabled.

#### *setText(test :: String, color :: String := "Black")*
If the controller has an associated visual representation of the hardware controller, the visual label of the function might be changed with this method. The given color must be a defined HTML color descriptor.

#### *connectAction(action :: ControllerAction)*
Connects or binds the function to the given action. From now on, every trigger of the hardware controller will result in an activation of the [fireAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-fireactionfunction--controllerfunction-trigger--string) method of the action, as long as the function is currently enabled for the trigger in question. Normally, functions will be connected during the activation of plugins or modes.

#### *disconnectAction(action :: ControllerAction)*
Disconnects the function from the given action. Normally, functions will be disconnected during the deactivation of plugins or modes.

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

## ControllerPlugin extends [Plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#plugin-extends-configurationitem-classesahk) ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
This is the central class, that must be implemented to extend the functionality of the Simulator Controller. Tha base class [Plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#plugin-extends-configurationitem-classesahk) provides all the configuration information, wherease *ControllerPlugin* defines the protocol to interact with the simulator controller and, most important, supplies [modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllermode-simulator-controllerahk) and [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk).

### Public Properties

#### *Controller[]* {
Returns the controller, where this plugin has been registered.
	
#### *Modes[]*
A list of all [modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllermode-simulator-controllerahk) defined by this plugin.
	
#### *Actions[]*
A list of all actions defined by this plugin. Only the actions defined directly for the plugin will be returned, not including the actions defined by the modes of the plugin.

### Public Methods

#### *__New(controller :: SimulatorController, name :: String, configuration :: ConfigurationMap, register :: Boolean := true)*
Constructs an instance of *ControllerPlugin*. The first three parameters are required. If the optional parameter *register* is supplied and *false*, the plugin is not registered automatically in the *controller*. This might be necessary in complex initialization scenarios. You can register the plugin anytime later by calling *registerPlugin* manually.

#### *findMode(name :: String)*
Searches for a mode defined by this plugin with the given name. Returns *false*, if not found.

#### *findAction(label :: String)*
Searches for an action with the given name defined by this plugin. Returns *false*, if not found.

#### *registerMode(mode :: ControllerMode)*
Registers the given mode in the plugin.

Note: Normally, this method is called by the constructor method of the mode. Therefore it is almost always unnecessary to call *registerMode* for the plugin directly. But, since all side effects of *registerMode* are idempotent, you can call it for your peace of mind as often as you like.

#### *registerAction(action :: ControllerAction)*
Registers the given action in the plugin. In deviation from all other *register...* methods, *registerAction* is not called automatically by the constructor of [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk), since actions may be defined both for plugins or for modes. Therefore you need to register a new action for the right owner object.

#### *isActive()*
Returns *true*, if the plugin is to be considered active. The default implementation is based on the [Active](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#active) property of the base class and therefore adheres to the configuration.

#### *activate()*
This method is called by the controller, when the plugin needs to be activated. Normally, an active plugin gets activated in the moment, when it is registered in the controller. The default implementation connects all plugin actions to their respective functions.

#### *deactivate()*
This method is called by the controller, when the plugin needs to be deactivated. The default implemention of the controller never deactivates plugins, but a subclass may provide this functionality. The default implementation of *deactivate* disconnects all plugin actions from their respective functions.

#### *runningSimulator()*
Plugins, that have an understanding of simulation games and can detect their running state, may implement this method to return the name of a currently running simulation.

#### *simulatorStartup(simulator :: String)*
This is an event handler method called by the controller to notify the plugin, that a simulation just has been started. A plugin may, for example, switch to a specific mode specialized for the given simulator.

#### *simulatorShutdown(simulator :: String)*
This is an event handler method called by the controller to notify the plugin, that a simulation just has been stopped.

#### *getLabel(descriptor :: String, default :: String := false)*
This method can be used to support localization or using different labels depending on the bound function in the visual representation of the controller hardware. The label texts are defined in a special configuration file named *Controller Plugin Labels.ini* located in the *Simulator Controller\Config* folder in the users *Documents* folder. The content of this file is accessible using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration).

#### *logFunctionNotFound(functionDescriptor :: String)*
Helper method to log the most common configuration error: A function descriptor is referenced for an action, which is unknown, i.e. is not provided by the current hardware controller.
***

## ControllerMode ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
Controller modes represent a layer or group of functionality for the hardware controller. All the actions, that are part of this group, will be defined by the mode. Only one mode may be active for the controller at any given point in time.
	
### Public Properties

#### [Abstract] *Mode[]*
Returns the name of the mode, wich might be displayed in the visual representation of the hardware controller, for example a Button Box. This property must be implemented by all subclasses.
	
#### *Plugin[]*
Returns the plugin, which has defined this mode.
	
#### *Controller[]*
The controller, where the plugin of this mode has been registered.

#### *ButtonBoxes[]*
Returns a list all [ButtonBox](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-buttonbox-extends-configurationitem-simulator-controllerahk) instances, on which this mode has registered actions.

#### *Actions[]*
A list of all actions defined by this mode.

### Public Methods
	
#### *__New(plugin :: ControllerPlugin)*
Constructs a new mode. [registerMode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#registermodemode--controllermode) is called for the given plugin.

#### *registerAction(action :: ControllerAction)*
Registers the given action for this mode. In deviation from some other *register...* methods, *registerAction* is not called automatically by the constructor of [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk), since actions might be defined for plugins or for modes. Therefore you need to register a new action for the right owner object.

#### *registerButtonBox(buttonBox :: ButtonBox)*
Registers a visual representation for the hardware controller, for which this mode has defined one or more actions. This method is called automatically, so nothing to do on your side, but you may want to overwrite the method in situations, where you want to take special actions for one of these Button Boxes.

#### *findAction(label :: String)*
Searches for an action with the given label or name defined by this mode. Returns *false*, if not found.

#### *isActive()*
Return *true*, if this mode is currently active, which means, that it can be activated by the controller. The default implementation will check, whether the mode is dependent on a specific running simulator and will act accordingly.

#### *activate()*
This method is called by the controller, when the mode will be activated. The default implementation connects all mode actions to their respective functions.

#### *deactivate()*
This method is called by the controller, when the mode will be deactivated. The default implementation of *deactivate* disconnects all mode actions from their respective functions.

***

## ControllerAction ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
This little class represents the actions, which can be connected to the hardware controller functions. An action simply consists of a label, which may be displayed on the visual representation of the controller hardware and the *fireAction* method, which implements the triggerable functionality.

### Public Properties

#### *Function[]*
Returns the function, to which this action will be connected, when the correspoding plugin or mode is active.
	
#### *Controller[]*
The controller, where the corresponding function has been registered.
	
#### *Label[]*
Returns the label of this action.
	
### Public Methods

#### *__New(function :: ControllerFunction, label :: String := "")*
Constructs an instance of *ControllerAction*.

#### [Abstract] *fireAction(function :: ControllerFunction, trigger :: String)*
This method must be implemented by every subclass of *ControllerAction* and act according to the supplied trigger argument.

***

## [Abstract] ButtonBox extends [ConfigurationItem](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk) ([Simulator Controller.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Simulator%20Controller.ahk))
Instances of this class will implement a visual representation of your hardware controller. Althoug the Simulator Controller will provide complete functionality even without a visual representation, it is much more fun to see what happens. Subclasses of *ButtonBox* must use the [Gui capabilities](https://www.autohotkey.com/docs/commands/Gui.htm) of the AutoHotkey language to implement the graphical representation. See [this simple example](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/ButtonBox%20Plugin.ahk) for reference.

### Public Properties

#### *Controller[]*
Returns the corresponding controller.

#### *Descriptor[]*
Returns a unique descriptor for this instance of *ButtonBox*. The default implementation returns the name of the class, which will be unique in most cases, unless you have more than one Button Box of the same type.
	
#### *Visible[]*
Returns *true*, if the Button Box window is currently visible.
	
#### *Num1WayToggles[]*
The number of 1-way toggle switches of the Button Box. This is maintained by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration).

#### *Num2WayToggles[]*
The number of 2-way toggle switches of the Button Box. This is maintained by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration).

#### *NumButtons[]*
The number of simple push buttons of the Button Box. This is maintained by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration).

#### *NumDials[]*
The number of rotary dials of the Button Box. This is maintained by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration).

#### *VisibleDuration[]*
The time in milliseconds, the Button Box may be visible after an action has been triggered. You can specify two different durations with the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), depending being in a running simulation or not.

### Public Methods

#### *__New(controller :: SimulatorController, configuration :: ConfigurationMap := false)*
Constructs a Button Box. The single instance will be bound to the *Instance* property of the *ButtonBox* class. The Button Box is automatically registered for the given controller using [registerButtonBox](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#registerbuttonboxbuttonbox--buttonbox).
	
#### [Abstract] *createGui()*
This method must be implemented by a subclass of *ButtonBox*. The window with its Gui controls for the visual representation of the Button Box must be created. The implementation of *createGui* must call *associateGui* (see below) and supply the Gui prefix for this window (see the [AutoHotkey documentation](https://www.autohotkey.com/docs/commands/Gui.htm) for an explanation), and its width and height and other information to the framework. Furthermore, all label fields must be registered using *registerControlHandle*.

#### *associateGui(window :: String, width :: Integer, height :: Integer, num1WayToggles :: Integer, num2WayToggles :: Integer, numButtons :: Integer, numDials :: Integer)*
This method must be called by *createGui* to describe the Button Box to the framework.

#### *findButtonBox(window :: String)*
This class method return the *ButtonBox* instance, that defined the given window, or *false*, if there is no such instance.


#### *registerControlHandle(descriptor :: String, handle :: Control Handle)*
This method must be called by *createGui* as well for each label field of the Button Box. *handle* must be a control handle as defined by the *Hwnd* argument of [AutoHotkey Gui elements](https://www.autohotkey.com/docs/commands/Gui.htm).

#### *getControlHandle(descriptor :: String)*
For each visual representation of a controller function, which will a have an associated label or text field, a [GuiControl handle](https://www.autohotkey.com/docs/commands/GuiControl.htm) will be returned, or *false*, if there is no such text control. The given descriptor will identify the function according to the standard descriptor format, like "Button.3".
	
#### *show()*
Shows the Button Box window according to the visibility rules defined in the configuration. This method is called automatically by the framework after each potential visual change.

#### *hide()*
Hides the Button Box window again. This method is automatically called, after the visible duration defined in the configuration has elapsed with no hardware trigger event in between.

#### *moveByMouse(button :: String := "LButton")*
Call this method from an event handler. It will move the Button Box window following the mouse, while the given button is down. The position will be remembered as the "Last Position" in the *Simulator Controller.ini* configuration file.