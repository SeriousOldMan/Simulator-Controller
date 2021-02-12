# Installation

Download one of the releases, preferably the latest stable build, and unzip it at any location you like. Then go to the *Binaries* folder, where you will find several applications. I recommend to add a Start menu shortcut to *Simulator Startup.exe* and *Simulator Configuration.exe*, since you will need those two applications the most. After that, you want to visit the *Config* folder. If you want to start with a clean, empty configuration, you may want to delete all *.ini files, but it will be a good idea to make a backup copies for later reference. As an alternative which I would recommend, leave the configuration files in place and use the given configuration as a starting point to understand how everything fits together. The create your own configuration by changing it. Also, leave the *Simulator Tools.targets* file in place, since it contains the build rules used when developing plugins.

Important: The files in the *Config* folder will never get overwritten, when you save your own configuration. Instead, your configuration files will be saved to the *Simulator Controller\Config* folder in your user *Documents* folder. This folder will be searched first, when a configuration file is looked up. You can always revert to the original configuration by deleting the *.ini files in the *Simulator Controller\Config* folder.

## Installing additional components

As already mentioned in the [README](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/README.md#third-party-applications) file, you might want to install additional third party applications, that can be controlled by Simulator Controller or will enhance the overall user experience. Please take a look at this list and decide, which ones you want to install. If you want to start your own plugin development or even change the code of the Simulator Controller itself, you definitely need to have [AutoHotkey](https://www.autohotkey.com/) installed. Beginning with Release 2.1, an installation of [VisualStudio Community Edition](https://visualstudio.microsoft.com/de/vs/community/) might also be required, if you want do dig into the heavylifting part of telemetry data acquisition or voice recognition. But you can stick with the precompiled binaries from the distribution, if that is not your domain.

Beside that, I recommend at least [VoiceMacro](http://www.voicemacro.net/) for handling voice commands, and depending on your equipment configuration, [SimHub](https://www.simhubdash.com/) and [SimFeedback](https://www.opensfx.com/). For the later two, very sophisticated support is built into the Simulator Controller already.

## Using your own pictures, videos and sounds for all the splash screens

The startup process of Simulator Controller can entertain you with splash images and even play videos and emotional songs while starting all the components or your favorite simulation game (no worry, this can be completely switched off using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), if you prefer a more reduced kind of life style). The standard distribution comes with some default media from the GT3 world, but, since every racer or even pilot might have a different taste, you can install your own media files. You will find all the standard media files in the *Resources\Splash Media* folder. For your own media, you can use any JPG, GIF, WAV or MP3 files, as long as pictures adhere to a strict 16:9 format. Last but not least, you can use the settings editor to choose between picture carousel or GIF animation, whether to play one of the sound files during startup, and so on. To keep the standard distribution clean, a *Simulator Controller\Splash Media* folder will be created by the configuration tool in your standard *Documents* folder, where you can store your media files.

Note: Choosing media files depending on the currently selected simulation game is on the wish list for a future release :-)

## Installation and Configuration of Jona, the Virtual Race Engineer

Release 2.1 introduced Jona, an artificial race engineer as an optional component of the Simulator Controller package. Since Jona is quite a complex piece of software, and also requires additional installation steps, you will find all necessary information about Jona in a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer).

# Configuration

The different components of Simulator Controller can be customized to a large extent. Part of this customization is handled by the configuration process, which typically you need to do only once, or maybe twice, when the configuration of your simulation equipment might change in the future. This overall configuration is handled by a specialized tool, which will be described in the following chapters. Additional customization, which address special aspects of the operation of the different applications of Simulator Controller, is possible by using separate configuration dialogs. See the documentation on [how to use](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller) the Simulator Controller for more information.

## Running the configuration tool

The configuration tool is located in the *Binaries* folder and is named *Simulator Configuration.exe*. If you start it, the following window will appear:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Editor.JPG)

The tool is divided in tabs for each aspect of the configuration process. You will find an explanation of each tab and its content below. Before you start experimenting with the configuration tool, be sure to make a backup copy of the current configuration file *Simulator Configuration.ini* in the *Config* folder, just to be safe. But you will always find a fresh copy in the *Resources\Templates* folder for your peace of mind.

Hint: Beside simply running the configuration tool by double clicking it, there are two hidden modifiers. First, if you hold the Control key down while starting the configuration tool, any currently available configuration file in the *Config* folder will be ignored and you will start with a fresh, completely empty configuration. And if you hold the Shift key down, additional options for developers will be available. These will automatically appear, when an active AutoHotkey installation is detected (by checking, if the folder C:\Program Files\AutoHotkey is available).

## Using the configuration tool

The configuration tool consists of several pages or tabs. Below you will find a description of each tab. Beside the pages, there are the well known buttons "Ok", "Cancel" and "Apply".

### Tab *General*

As the name of this tab suggests, some very general configuration options are provided. In the *Installation* group you can identify the root folder of the Simulator Controller installation - optional in most cases, but it may provide some performance benefits. The second path identifies the *NirCmd* executable, which is used by the Simulator Controller to control the sound volume of some simulation games. Optional, but helpful. See the [README](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications) for a link to the *NirCmd* download.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%201.JPG)

The second group, *Settings* allows you to choose whether the Simulator Controller will start together with Windows and whether it will run silently, i.e. without any splash animation or sound. With the button "Themes Editor..." you can jump to a special editor to customize the splash dialogs of various applications of Simulator Controller. See the chapter on the [themes editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor) for a complete explanation of themes. Last but not least you may choose a language for all user interface elements. English as the base language and a German translation are part of the Simulator Controller distribution, but you may define your own translations using the [translations editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#translations-editor), wich you can open by clicking on the small button next to the language drop down.

You can add all the simulation games installed on your PC to the list in the third group *Simulators*. For each entry here, you also need to create a similar named application entry in the applications tab. The order of the entries in the *Simulators* list is important, at least the first one has a special role. More on that later. You can change the order with the "Up" and "Down" button, if an entry is selected. As with any list in the configuration tool, an entry must be selected with a double click for editing.

The last group, which is only present in developer mode as mentioned above, lets you activate the debug mode, define the log level and enter the path to an AutoHotkey installation on your PC. Be careful with the log level *Info*, since the log files found in the *Simulator Controller\Logs* folder found in the users *Documents* folder may grow quite fast.

### Tab *Plugins*

In this tab you can configure the plugins currently in use by the Simulator Controller.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%202.JPG)

Beside temporarily deactivating a plugin and all its modes, you can define a comma separated list of simulator names. This will restrict the modes of the plugin to only be available, when these simulators are running. The most important field here is the *Arguments* field. Here you can supply values for all the configuration parameters of the given plugin. The format is like this: "parameter1: value11, value12, value13; parameter2: value21, value22; ...". Please take a look at the [plugin reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for an in depth explanation of all the parameters of the builtin plugins. Last but not least, you will find an "Edit Labels" button in the lower left corner of this tab. Pressing this button will open a simple text file, where you can edit the labels, some plugins display on the visual hardware controller display. Change them to your liking.

Note: You can deactivate or delete all plugins except *System*. The *System* plugin is required and part of the framework. If you delete any other plugin here, it will still be loaded by the Simulator Controller, but it won't be activated. On the other side, if you add a plugin here, but haven't added any plugin code, nothting will happen. And, last but not least, the plugin names given here must be identical to those used in the plugin code. Some sort of primary key, hey. If you have some development skills, see the documentation on [plugin development](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts) for further information.

### Tab *Applications*

Simulator Controller can handle as many applications as you want. Beside the simulation games itself, you may want to launch your favorite telemetry or voice chat application with a push of a button. Or you want a voice recognition software to be started together with the Simulator Controller to be able to handle all activaties not only by the Button Box, but by voice commands as well. The possibilities are endless. To be able to do that, Simulator Controller needs needs knowledge about these applications, where to find them and how to handle them. This is the purpose of the *Applications* tab.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%203.JPG)

There are three diffenrent types of applications, "Core", "Feedback" and "Other". All of these applications are optional, but for the "Core" and "Feedback" category, Simulator Controller is aware of them, either directly or with the help of a plugin, and use them for a better user experience. Since adding "Core" and "Feedback" applications also need some development efforts, the categories cannot be changed by using the configuration tool, which means, that any application added here will be automatically of type "Other". But "Other" applications may be used by the [Launchpad](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-launchpad).

Note: To change the category of an application, you need to directly edit the *Simulator Configuration.ini* file.

An application must a have a unique name, you must supply the path to the executable file and sometimes also to a special working directory, and you may supply a [window title pattern](https://www.autohotkey.com/docs/misc/WinTitle.htm) according to the AutoHotkey specification. This is used to detect, whether the application is running.

For developers: Sometimes you want magic stuff to happen, when an application is started. For example, you may automatically swith to your favorite team channel when starting your voice chat software. This need some code support, which can be provided in a plugin. You *simply* define a function, which handles this special stuff and reference it here in the application configuration. See the plugins [Core Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/Core%20Plugin.ahk), [RST Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/RST%20Plugin.ahk) and [AC Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/AC%20Plugin.ahk) for some examples.

### Tab *Controller*

This tab represents the most important, the most versatile and also the most difficult to understand part of the configuration process. On this page, you describe your hardware controller, for example a Button Box, and all the functionality available on this controller.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%204.JPG)

In the top section you define how many functional elements of each type are available on your hardware controller. Simulator Controller can handle as many 1-way and 2-way toggle switches, normal push buttons and 2-way rotary dials as you like. Beside that, a fith function type *Custom* is available to connect special controller elements or other external trigger (for example macro tools for voice recognition) to the Simulator Controller.

In the *Bindings* group, you define one or two hotkeys and corresponding actions, depending on whether you have defined a unary or binary function type. 2-way toggles and dials need two bindings for the "On" and "Off", respectivly the "Increase" and "Decrease" trigger. The binding of a function happens by defining [hotkeys](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys), which might trigger the given function. You can define more than one hotkey descriptor, delimited by the vertical bar "|", for each trigger in the controller tab. This might be useful, if you have several sources, which can trigger a given function. For example you might have a function, which can be triggered by pushing a button on the controller, but also from the keyboard, which might be emulated by another tool, for example a voice recognition software.

Additionally to definining hotkeys for keyboard or controller triggers, you can use the voice recognition capabilities of Simulator Controller, which were introduced with Release 2.1 for the virtual race engineer (see [update notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-21) for specific installation information). A voice trigger must be preceeded by "?" and you can use the full [phrase grammar](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#phrase-grammars) capabilities of the voice recognition framework. Here is a very simple example: "?Next Page", which might be used as a voice trigger for the mode switch.

Note: As already documented in the [troubleshooting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#troubleshooting) section of the documentation for the virtual race engineer, you will get the best results with a headset. If you want to stick with a surround loudspeaker setup, consider using [VoiceMacro](http://www.voicemacro.net/) for recognizing voice commands, since this little tool is specialized and much better when it comes to separating unwanted ambient noises from your voice commands than the voice recognition of Simulator Controller - at least for the moment.

Beside the hotkey(s), a function may define an [action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions), which must be a call to a global function in the scripting language. For all functions managed by plugins, you can leave the action field empty, since in the Simulator Controller framework, actions are represented by instances of [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk).

#### Hotkeys

The central concept to connect to your hardware controller or to other external trigger is a *Hotkey*. A hotkey is a concept of the Windows operating system, whereby a combination of several keys on the keyboard, mouse or other controlling device might trigger a predefined action. The AutoHotkey language defines a special syntax to define hotkeys. You will find a comprehensive guide to this syntax and all available keys in the [documentation](https://www.autohotkey.com/docs/Hotkeys.htm) of AutoHotkey. For example the string <^<!F1 defines a hotkey for function key one (F1), which must be pressed together with the left (<) Control (^) and left (<) Alt (!) key to be triggered. Beside hotkeys for the keyboard or mouse events, AutoHotkey provide a definition for hotkeys for external controllers, called joysticks. For example, 2Joy7 defines the seventh button on the second controller connected to the PC.

Below you will find a brief and incomplete overview over the possible hotkeys, to help you to understand the hotkeys found in the sample configuration file. Please take a look at the complete [documentation](https://www.autohotkey.com/docs/Hotkeys.htm) of AutoHotkey for further information.

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
| {X}Joy{Y}| The y-th button on the x-th connected joystick or general hardware controller. Example: "2Joy7". You can use the [Key Detector Tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#key-detector-tool) to find out, which button codes your connected controller actually use. |

#### Actions

An action is simply a textual representation of a call to a function in the scripting language. It simply looks like this: "setMode(Pedal Vibration)", which means, that the "Pedal Vibration" mode should be selected as the active layer for your hardware controller. You can provide zero or more arguments to the function call. All arguments will be passed as strings to the function with the exception of *true* and *false*, which will be passed as literal values (1 and 0).

Although you may call any globally defined function, you should use only the following functions for your actions, since they are specially prepared to be called from an external source:

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| setDebug | debug | Builtin | Enables or disables debugging. *debug* must be either *true* or *false*. |
| setLogLevel | logLevel | Builtin | Sets the log level. *logLevel* must be one of "Info", "Warn", "Critical" or "Off", where "Info" is the most verbose one. |
| increaseLogLevel | - | Builtin | Increases the log level, i.e. makes the log information more verbose. |
| decreaseLogLevel | - | Builtin | Decreases the log level, i.e. makes the log information less verbose. |
| pushButton | number | Builtin | Virtually pushes the button with the given number. |
| rotateDial | number, direction | Builtin | Virtually rotates the rotary dial with the given number. *direction* must be one of "Increase" or "Decrease". |
| switchToggle | type, number, state | Builtin | Virtually switches the toggle switch with the given number. *state* must be one of "On" or "Off" for 2-way toggle switches and "On" for 1-way toggle switches. The type of the toggle switch must be passed as *type*, one of "1WayToggle" and "2WayToggle". |
| setMode | mode | Builtin | Switches the currently active mode for the hardware controller. See the [plugin reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for an in depth explanation of all available modes. |
| startSimulation | [Optional] simulator | System | Starts a simulation game. If the simulator name is not provided, the first one in the list of configured simulators on the *General* tab is used. |
| stopSimulation | - | System | Stops the currently running simulation game. |
| shutdownSystem | - | System | Displays a dialog and asks, whether the PC should be shutdown. Use with caution. |
| enablePedalVibration | - | Tactile Feedback | Enables the pedal vibration motors, that might be mounted to your pedals. Available depending on the concrete configuration. |
| disablePedalVibration | - | Tactile Feedback | Disables the pedal vibration motors, that might be mounted to your pedals. Available depending on the concrete configuration. |
| enableFrontChassisVibration | - | Tactile Feedback | Enables the chassis vibration bass shakers that might be mounted to the front of your simulation rig. Available depending on the concrete configuration. |
| disableFrontChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the front of your simulation rig. Available depending on the concrete configuration. |
| enableRearChassisVibration | - | Tactile Feedback | Enables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| disableRearChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| disableRearChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| startMotion | - | Motion Feedback | Starts the motion feedback system of your simulation rig. Available depending on the concrete configuration. |
| stopMotion | - | Motion Feedback | Stops the motion feedback system of your simulation rig and brings the rig back to its resting position. Available depending on the concrete configuration. |
| openPitstopMFD | - | ACC | Opens the pitstop settings dialog of *Assetto Corsa Competizione*. |
| closePitstopMFD | - | ACC | Closes the pitstop settings dialog of *Assetto Corsa Competizione*. |
| togglePitstopActivity | activity | ACC | Enables or disables one of the activities performed by your pitstop crew. The supported activities are "Change Tyres", "Change Brakes", "Repair Bodywork" and "Repair Suspension". |
| changePitstopStrategy | selection | ACC | Selects one of the pitstop strategies. *selection* must be either "Next" or "Previous". |
| changePitstopFuelAmount | direction, [Optional] liters | ACC | Changes the amount of fuel to add during the next pitstop. *direction* must be either "Increase" or "Decrease" and *liters* may define the amount of fuel to be changed in one step. This parameter has a default of 5. |
| changePitstopTyreSet | selection | ACC | Selects the tyre sez to change to during  the next pitstop. *selection* must be either "Next" or "Previous". |
| changePitstopTyreCompound | compound | ACC | Selects the tyre compound to change to during  the next pitstop. *compound* must be either "Wet" or "Dry". |
| changePitstopTyrePressure | tyre, direction, [Optional] increments | ACC | Changes the tyre pressure during the next pitstop. *tyre* must be one of "All Around", "Front Left", "Front Right", "Rear Left" and "Rear Right", and *direction* must be either "Increase" or "Decrease". *increments* with a default of 1 define the change in 0.1 psi increments. |
| changePitstopBrakeType | brake, selection | ACC | Selects the brake pad compound to change to during the next pitstop. *brake* must be "Front Brake" or "Rear Brake" and *selection* must be "Next" or "Previous".  |
| changePitstopDriver | selection | ACC | Selects the driver to take the car during the next pitstop. *selection* must be either "Next" or "Previous". |
| planPitstop | - | ACC | *planPitstop* triggers Jona, the virtual race engineer, to plan a pitstop. |
| preparePitstop | - | ACC | *preparePitstop* triggers Jona, the virtual race engineer, to prepare a previously planned pitstop. |
| openRaceEngineerSettings | - | ACC | Opens the settings tool, with which you can edit all the race specific settings, Jona needs for a given race. |
 
#### Key Detector Tool

This little tool will help you identifying the button numbers of your hardware controller. If you push the "Key Detector" button, a flying tool tip will apear next to your mouse cursor, which provide some information about your connected controller devices and the buttons or other triggers, that are currently beeing pushed there. To disable the tool tip, press the "Key Detector" button again.

### Tab *Launchpad*

On the launchpad, you can define a list of type "Other" applications, that can be launched by a push of a button on your controller. The "Launch" mode, which belongs to the "System" plugin, will use this list to occupy as many buttons on your controller, as has been defined on the *Controller* tab.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%205.JPG)

You need to specify a small label text to display on the visual representation of your controller and you need to choose the application, which will be launched, when the corresponding button is pressed. You can use the "Up" and "Down" buttons to specifiy the position of these applications on the launchpad.

### Tab *Chat*

Many simulation games provide an ingame multiplayer text based chat system. Since it is very difficult and also dangerous to a certain extent to type while driving or flying, you can configure predefined chat messages on this tab. These may be used by several plugins for specific simulators, to help you to send a kudos to your oppenents or even insult or offend them. Chat messages will typically be used in a mode of a specific plugin for a simulation game. See the [ACCPlugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) for an example.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%206.JPG)

You need to specify a small label text to display on the visual representation of your controller and you specifiy the long chat message, which will be send to the ingame chat system. You can use the "Up" and "Down" buttons to specifiy the position of these chat messages on the controller hardware.

## Themes Editor

This special editor, which can be opened from the *General* tab of the configuration tool, allows you to define a combination of pictures or animation files together with a sound file. This combination is called a splash theme and will be used by the startup sequence. You may have a Rallye theme for your favorite Rallye session, or an F1 theme, or even some cinematic impressions from various airplanes in the sky, while waiting for your flight simulator to startup.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Themes%20Editor.JPG)

Currently, two different types of splash themes are supported. The first uses a collection of pictures for a kind of round robin display. The second theme type let you choose a GIF file for a video like animation. Both support the additional selection of a sound file to play along, while the pictures or the animation will be shown. Despite that, you can overwrite the default title and subtitle of the splash screen window.
Some words about using the editor:
  - You can prelisten the currently selected sound file by pressing the start button next to the entry field. It will keep playing until you press this button again, even if another theme had been selected in the meantime.
  - You can add any picture to the pictures list by pressing the "+" button left to it. The new picture will be added at the end of the list. However, if you save your changes, only those pictures will be stored for the theme, that have a checked checkmark in their list entry.
  - Everey JPG and GIF file added to a theme must be of a precise 16:9 format, otherwise you will get distortion artefacts.
  - Due to a restriction in AutoHotkey, only the GIF format is currently supported for animations. A future version of Simulator Controller will support YT videos, MP4 files and other as well. For now you can convert your favorite MP4 file to a GIF image by using one of the available online converters, for example [Convertio](https://convertio.co/de/mp4-gif/) .

After definition of a theme, you can choose it for the [startup sequence](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#other-settings) or even while the build tool is currently compiling your favorite plugin, if you are a developer.

## Translations Editor
Another special editor is used for maintaining different language translations. In the translation process, you can provide a language specific translated text for each user interface element or other texts used by the Simulator Controller. English is the original language, on which the translation is based upon. A translation must be identified by its [ISO language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes), for example "EN", and also has a user understandable language identfier, for example "English". The translation information is stored by the *Translations Editor* in the folder identified by *kUserConfigDirectory* in a file named "Translations.LC", where LC is the given ISO language code.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Translations%20Editor.JPG)

With the drop down menu at the top of the window you can choose any of the available languages and edit the defined translations, or you create a new language by pressing the '+' button next to the language drop down. Last but not least, you can delete a given language and all its translations, but be aware, that this cannot be undone.

Note: The original text sometimes has leading and/or trailing spaces. Be sure to include them in the translated text as well, since they are important for formatting.

Important: The ISO language code and the language name itself cannot be changed, once a new language has been initially saved. So choose them wisely. And last but not least be careful, if you ever want to edit the translation files directly using a text editor. This editor must be able to handle multibyte files, since the tranlation files are stored in an UTF-16 format.
