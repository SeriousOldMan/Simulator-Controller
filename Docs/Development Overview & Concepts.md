## Introduction

The architecture of Simulator Controller has been designed with extensibility in mind. Since every racing rig is different and there are so many different applications out there for sim racers, the core of Simulator Controller is build around a very flexible and generic concept. Plugins may be used to provide additional functionality ranging from simple code additions up to very complex, object-oriented extensions of the Simulator Controller itself.

### Plugin Integration

When the Simulator Controller starts up, it includes one single file in *Sources/Controller/Plugins* folder: [Plugins.ahk](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Plugins/Plugins.ahk). This file must be modified to include all the plugins needed for your specific configuration.

A plugin must not follow a specific pattern, it simply loads and executes code in the AutoHotkey language, after the single [SimulatorController](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-simulatorcontroller-extends-configurationitem-simulator-controllerahk) has been created. *Real* plugins will extend the ControllerPlugin (*) class and will provide additional functionality for your controller box.


### General Concepts

The Simulator Controller framework has been build around the similar named Singleton Class [SimulatorController](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-simulatorcontroller-extends-configurationitem-simulator-controllerahk). This class implements the complete control flow between the hardware controller elements like buttons, dials and switches and the functionalities provided by a plugin. Since the number of hardware control elements is limited, functionalities may be grouped in so called modes, which may be activated or deactivated as a group. Each mode belongs to a given plugin and only on mode may be active at a given point in time. From the user point of view a mode defines a set of controls as a switchable layer for the hardware controller. In addition, plugins may bind functionality to controller functions independent of a specific mode. This functionality will be available all the time. An example will make it more clear: A toggle switch to enable or disable rig motion feedback might be always available, but detailed control over specific effect intensities might only be necessary, while finetuning the feedback levels.

A specific hardware control element is represented in code by instances of the class SimulatorControllerFunction (*). For a controller function to be useful, it must be connected to a ControllerAction (*), which implements the functionality, which should triggered by the hardware controller. These connections are of dynamic nature, which means that the function mapping of the hardware controller may be changed anytime. This is, in the end, the capability used when switching between modes.

### Plugins



### Modes


### Controller Functions

Instances of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-extends-configurationitem-classesahk) represent the active elements of a hardware controller - buttons, dials, switches and so on. A function must be mapped to an Action (*) to be useful. This mapping is handled by Plugins (*) and Modes (*), since both can take ownership of a function and define the corresponding Action. Whereas modes may own a function only as long they are the currently active mode of the Controller (*) (i.e. the currently active layer of a button box), plugins can define actions and bind them to functions, so that they are available all the time. Functions might be enabled or disabled according to the current state of their mode or plugin and they can give visual feedback, if a visual button box representation has been defined. For example, if you increase the force feedback of your steering wheel with a dial knob, the current feedback strength might be dislayed below the dial. Normally this is handled by the action, when the fireAction (*) method is called.

Several subclasses of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-extends-configurationitem-classesahk) define specialized behaviour, for example [2WayToggleFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#2waytogglefunction-extends-controllerfunction-classesahk) can trigger to different action methods, since they have an On and an Off state. See the [class reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference) for details on all subclasses of [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-extends-configurationitem-classesahk).

To make things more complicated a seperate controller function inheritance tree exists for all functions handled by SimulatorController (*), since AutoHotkey does not support multiple inheritence. The complete protocol of *ControllerFunction* is implemented by these classes (*) as well and they use the original classes by a delegation pattern. Since AutoHotey is weakly typed prototype-based language, this fact is invisible to the programmer, but in the end good to know and to understand.

### Controller Actions
ControllerAction (*) objects are very simple. They define a label, which might be displayed by the button box visual and the define the method fireAction (*) which will be triggered by the function. Although actions might be created and registered to their mode or plugin anytime, normally they are created by the mode or plugin during initialization, for example based on configuration data.

### Button Box

### Example