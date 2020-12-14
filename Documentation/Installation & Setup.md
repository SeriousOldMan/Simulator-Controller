# Installation

Download one the releases, preferably the latest stable build, and unzip at any location you like. Then go to the Binaries folder. There are five applications. I recommend to add a start menu shortcut to *Simulator Startup.exe* and *Simulator Configuration.exe*, since you will need those two applications a lot. After that, you want to visit the Config folder. If you want to start with a clean, empty setup and configuration, you must delete all *.ini files. Maybe it is a good idea to make a backup copy for later reference. As an alternative leave the config files in place and use the given configuration as a starting point to understand how everything works, and create your own setup & configuration later. Also, leave the *Simulator Tools.targets* file in place, since it contains the build rules used when developing plugins.

Whenever you will install a new release in the future, you need to save your own config files in the *Config* folder, before unzipping the new distribution. Depending own your addtional customization, you will also want to save your media files (see the section about [custom media files](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#using-your-own-pictures-videos-and-sounds-for-all-the-splash-screens) below), and all your plugin development results (see the [plugin development guide](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#introduction) for more information about that).

## Installing additional components

As already mentioned in the [README](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/README.md#third-party-applications) of a lot of third party applications, that might be controlled by Simulator Controller or will enhance the user experience. Please take a look at this list and decide, which ones you want to install. If you want to start your own plugin development or even change the code of the Simulator Controller itself, you definitely need to have [AutoHotkey](https://www.autohotkey.com/) installed. Beside that, I recommend at least [VoiceMacro](http://www.voicemacro.net/) for handling voice commands, and depending on your equipment setup, [SimHub](https://www.simhubdash.com/) and [SimFeedback](https://www.opensfx.com/). For the later two, very sophisticated support is built into the Simulator Controller already.

## Using your own pictures, videos and sounds for all the splash screens

The startup process of Simulator Controller can entertain you with splash images and even play videos and emotional songs while starting all the components or your favorite simulation game (no worry, this can be completely switched off using the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup), if you prefer a more reduced kind of life style). The standard distribution comes with some default media from the GT3 world, but, since every racer or even pilot might have a different taste, you can install your own media files. You will find all the media files in the *Resources\Splash Media* folder, you can put any JPG GIF, WAV or MP3 file their, as long as pictures implement a strict 16:9 format. Last but not least, you can use the configuration tool to choose between picture carousel or GIF animation, whether to play on of the sound files during startup, and so on.

# Setup

The different components of Simulator Controller can be customized to a large extent. Part of this customization is handled by the setup process, which typically you need to do only once, or maybe, when the configuration of your simulation equipment might change in the future. This overall setup is handled by a specialized graphical tool, which will be described in the following chapters. Additional customization, which address special aspects of the operation of the different applications of Simulator Controller, is possible by using seperate configuration dialogs. See the documentation on [how to use](*) the Simulator Controller for more information.

## Running the setup tool

The setup tool is located in the *Binaries* folder and is named *Simulator Setup.exe*. If you start this little tool, the following window will be opened.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Setup%20Tool.JPG)

The tool is divided in tabs for each aspect of the setup process. You will find an explanation of each tab and its content below. Before you start experimenting with the setup tool, be sure to make a backup copy of the current configuration file *Simulator Configuration.ini* in the *Config* folder, just to be safe. But you will always find a fresh copy in the *Sources\Tools\Config Templates* folder for your peace of mind.

Hint: Beside simply running the setup tool by double clicking it, there are two hidden modifiers. First, if you hold the Control key down while starting the setup tool, any currently available configuration file in the *Config* folder will be ignored and the setup will start with a fresh, completely empty configuration. And if you hold the Shift key down, additional options for developer will be available. These will automatically be available, when an active AutoHotkey installation is detected (by checking if the folder C:\Program Files\AutoHotkey is available).

## Using the setup tool

The setup tool consists of several pages or tabs. Below you will find a description of each page. Beside the pages, there are the well known buttons "Ok", "Cancel" and "Apply". A fourth button named "Key Detector" will help you identifiying the key codes of your hardware controller, but this will be described in the chapter about the *Controller* tab.

### Tab *General*

As the name of this tab suggests, some very general configuration are available. In the *Installation Folders* group you can identify the root folder of the Simulator Controller installation - optional in most cases, but it may provide some performance benefits. The second path identifies the NirCmd executable, which is used by the Simulator Controller to control the sound volume of some simulation games. Optional, but helpful. See the [README](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications) for a link to the NirCmd download.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Setup%20Tab%201.JPG)

The second group, *Startup*, allows you to choose whether the Simulator Controller will startup together with Windows and that it will run silently, i.e. without any splash animation or sound.

You can add all the simulation games installed on your PC to the list in the third group *Simulators*. For each entry here, you also need to enter a similar named application in the applications tab. The order of the entries in the *Simulators* list is important, at least the first entry has a special role. More on that later. You can change the order with the "Up" and "Down" button, if an entry is selected. As with any list in the setup tool, an entry must be selected with a double click for editing.

The last group, which is only present in developer mode, as mentioned above, lets you activate the debug mode, define the log level and enter the path to an AutoHotkey installation on your PC. Be careful with the log level *Info*, since the log files found in the *Logs* folder may grow very fast.

### Tab *Plugins*

In this tab you will configure the plugins currently in use by the Simulator Controller.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Setup%20Tab%202.JPG)

Beside temporarily deactivating a plugin and all its modes, you can define a comma seperated list of simulator names. This will restrict the modes of the plugin to only be available, when these simulators are running. The most important field here is the *Arguments* field. Here you can supply values for all the configuration arguments of the given plugin. The format is like this: "parameter1: value11, value12, value13; parameter2: value21, value22; ...". Please take a look at the [plugin reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for an in depth explanation of all the arguments of the builtin plugins. Last but not least, you will find an "Edit Labels" button on this tab. Pressing this button will open a simple text file, where you can edit the labels, some plugins display on the visual hardware controller display. cHange them to your liking.

Note: You can deactivate or delete all plugins except *System*. The *System* plugin is required and part of the framework. If you delete any other plugin here, it will still be loaded by the Simulator Controller, but it won't be activated. On the other side, if you add a plugin here, but haven't added any plugin code, nothting will happen. And, last but not least, the plugin names given here must be identical to those, used in the plugin code. Some sort of primary key, hey. If you have some development skills, see the documentation on [plugin development](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts) for further information.

### Tab *Applications*

A lot of applications can be handled by the Simulator Controller. Beside the simulation games itself, you may want to launch your favorite telemetry or voice chat application with a push of a button. Or you want a voice recognition software to be started together with the Simulator Controller to be able to handle all activaties not only by the button box, but by voice commands as well. The possibilities are endless. To be able to do that, Simulator Controller needs to know this applications, where to find them and how to handle them. This is the purpose of the *Applications* tab.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Setup%20Tab%203.JPG)

There are three diffenrent types of applications, "Core", "Feedback" and "Other". All of these applications are optional, but for the "Core" and "Feedback" category, Simulator Controller is aware of them, either directly or with the help of a plugin, and use them for a better user experience. Since adding "Core" and "Feedback" applications also need some development efforts, the categories cannot be changed by using the setup tool, which means, that any application added here will be automatically of type "Other".

Note: To change the category of an application, you need to edit the *Simulator Configuration.ini* file directly.

An application must a have a unique name, you must supply the path to the executable file and sometimes also to a special working directory and you may supply a [window title pattern](https://www.autohotkey.com/docs/misc/WinTitle.htm) according to the AutoHotkey specification. This is used to detect, whether the application is running.

For developers: Sometimes you want magic stuff to happen, when an application is started. For example, you may automatically swith to your favorite team channel when starting your voice chat software. This need some code support, which can be provided in a plugin. You *simply* define a function, which handles this special stuff and reference it here in the application configuration. See the plugins [Core Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Plugins/Core%20Plugin.ahk), [RST Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Plugins/RST%20Plugin.ahk) and [AC Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Controller/Plugins/AC%20Plugin.ahk) for some examples.

### Tab *Controller*

This tab represents the most important, the most versatile and also the most difficult to understand part of the setup process. On this page, you describe your hardware controller, for example a button box, and all the functionality available of this controller.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Setup%20Tab%204.JPG)

In the top section you define how many functional elements of each type are available on your hardware controller. Simulator Controller can handle as many 1-way and 2-way toggle switches, normal push buttons and 2-way rotary dials as you like. Beside that, a fith function type *Custom* is available to connect external trigger (for example macro tools for voice recognition) to the Simulator Controller.

In the *Bindings* group, you define one or two hotkeys and corresponding actions, depending on whether you have defined a unary or binary function type. 2-way toggles and dials need two bindings for the "On" and "Off", respectivly the "Increase" and "Decrease" trigger, The binding of a function happens by defining [hotkeys](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#hotkeys), which might trigger the given function. You can define more than one hotkey descriptor, delimited by the vertical bar "|", for each trigger in the controller tab. This might be useful, if you have several sources, which can trigger a given function. For example you might have a function, which can be triggered by pushing a button on the controller, but also from the keyboard, which might be emulated by another tool, for example voice recognition.

Beside the hotkey(s), a function may define an [action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#actions), which must be a function call in the scripting language. For all functions managed by plugins, you can leave the action field empty, since in the Simulator Controller framework, actions are represented by instances of [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk).

#### Hotkeys

The central concept to connect to your hardware controller or to other external trigger is a *Hotkey*. A hotkey is a concept of the Windows operating system, whereby a combination of several keys on the keyboard, mouse or other controlling device might trigger a predefined action. The AutoHotkey language defines a special syntax to define hotkeys. You will find a comprehensive guide to this syntax and all available keys in the [documentation](https://www.autohotkey.com/docs/Hotkeys.htm) of AutoHotkey. For example the string <^<!F1 defines a hotkey for function key one (F1), which must be pressed together with the left (<) Control (^) and left (<) Alt (!) key to be triggered. Beside hotkeys for the keyboard or mouse events, AutoHotkey provide a definition for hotkeys for external controllers, called joysticks. For example, 2Joy7 defines the seventh button on the second controller connected to the PC.

Below you will find only a brief and incomplete overview over the possible hotkeys, to help you to understand the hotkeys found in sample configuration file. Please take a look of the complete [documentation](https://www.autohotkey.com/docs/Hotkeys.htm) of AutoHotkey for further information.

| Symbol | Description |
| ------ | ------ |
| ^ | Represents the CTRL key. |
| ! | Represents the ALT key. |
| + | Represents the SHIFT key. |
| < | A modifier for all keys that restrict it to be on the left side of the keyboard. |
| > | A modifier for all keys that restrict it to be on the right side of the keyboard. |
| A - Z | A normal alphabetical key on the keyboard. |
| F1 - Fn | A function key on the keyboard, if avilable. |
| Numpad0 - Numpad9 | A numpad key on the keyboard, if avilable. These will only be send, if NumLock is activated on the keyboard. |
| LMouse, RMouse | The left and the right mouse button. |
| {X}Joy{Y}| The y-th button on the x-th connected joystick or general hardware controller. Example: "2Joy7". You can use the [Key Detector Tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#key-detector-tool) to find out, which button codes your connected controller send. |

#### Actions

An action is simply a textual representation of a function call in the scripting language. It simply looks like this: "setMode(Pedal Vibration)", which means, that the "Pedal Vibration" mode should be selected as the active layer for your hardware controller. You can provide zero or more arguments to the function call. All arguments will be passed as strings to the function with the exception of *true* and *false*, which will be passed as literal values (1 and 0).

Although you may call any globally defined function, you should use the following functions for your actions, since they are specially prepared to be called from an external source:

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| setDebug | debug | Builtin | Enables or disables debugging. *debug* must be either *true* or *false*. |
| setLogLevel | logLevel | Builtin | Set the log level. *logLevel* must be one of "Info", "Warn", "Critical", "Off", where "Info" is the most verbose one. |
| increaseLogLevel | - | Builtin | Increases the log level, i.e. makes the log information more verbose. |
| decreaseLogLevel | - | Builtin | Decreases the log level, i.e. makes the log information less verbose. |
| pushButton | number | Builtin | Virtually pushes the button with the given number. |
| rotateDial | number, direction | Builtin | Virtually rotates the rotary dial with the given number. *direction* must be one of "Increase" or "Decrease". |
| switchToggle | type, number, state | Builtin | Virtually switches the toggle switch with the given number. *state* must be one of "On" or "Off" for 2-way toggle switches and "On" for 1-way toggle switches. The type of the toggle switch must be passed as *type*, one of "1WayToggle" and "2WayToggle". |
| setMode | mode | Builtin | Switches the currently active mode for the hardware controller. See the [plugin reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for an in depth explanation of all available modes. |
| startSimulation | [Optional] simulator | System Plugin | Starts a simulation game. If the simulator name is not provieded, the first one in the list of configured simulators on the *General* tab is used. |
| stopSimulation | - | System Plugin | Stops the currently running simulation game. |
| enablePedalVibration | - | Tactile Feedback | Enables the pedal vibration motors, that might be mounted to your pedals. Available depending on the concrete configuration. |
| disablePedalVibration | - | Tactile Feedback | Disables the pedal vibration motors, that might be mounted to your pedals. Available depending on the concrete configuration. |
| enableFrontChassisVibration | - | Tactile Feedback | Enables the chassis vibration bass shakers that might be mounted to the front of your Simulation Rig. Available depending on the concrete configuration. |
| disableFrontChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the front of your Simulation Rig. Available depending on the concrete configuration. |
| enableRearChassisVibration | - | Tactile Feedback | Enables the chassis vibration bass shakers that might be mounted to the rear of your Simulation Rig. Available depending on the concrete configuration. |
| disableRearChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the rear of your Simulation Rig. Available depending on the concrete configuration. |
| disableRearChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the rear of your Simulation Rig. Available depending on the concrete configuration. |
| startMotion | - | Motion Feedback | Starts the motion feedback system of your simulation rig. Available depending on the concrete configuration. |
| stopMotion | - | Motion Feedback | Stops the motion feedback system of your simulation rig and brings the rig back to its resting position. Available depending on the concrete configuration. |

#### Key Detector Tool

This little tool will help you identifying the button numbers of your hardware controller. If you push the "Key Detector" button, a flying tool tip will apear next to your mouse cursor, which provide some information about your connected controller devices and the buttons or other triggers, that are currently beeing pushed there. To disable the tool tip, press the "Key Detector" button for a second time.

### Tab *Launchpad*

On the launchpad, you can define a list of applications, that can be launched by a push of a button on your controller. The "Launch" mode, which belongs to the "System" plugin, will use this list to occupy as many buttons on your controller, as has been defined on the *Controller* tab.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Setup%20Tab%205.JPG)

You need to specify a small label text to display on the visual representation of your controller and you need to choose the application, which will be launched, when the corresponding button is pressed. You can use the "Up" and "Down" buttons to specifiy the position of these applications on the launchpad.

### Tab *Chat*

Many simulation games provide an ingame multiplayer text based chat system. Since it is very difficult and also dangerous to a certain extent to type while driving or flying, you can configure predefined chat messages on this tab. These may be used by several plugins for specific simulators, to help you to send a kudos to your oppenents or even insult or offend them. Chat messages will typically used in a mode of a specific plugin for a simulation game. See the [ACCPlugin](*) for an example.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Setup%20Tab%206.JPG)

You need to specify a small label text to display on the visual representation of your controller and you specifiy the long chat message, which will be send to the ingame chat system. You can use the "Up" and "Down" buttons to specifiy the position of these chat messages on the controller hardware.
