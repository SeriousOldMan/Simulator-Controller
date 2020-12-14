# Installation

Download one the releases, preferably the latest stable build, and unzip at any location you like. Then go to the Binaries folder. There are five applications. I recommend to add a start menu shortcut to *Simulator Startup.exe* and *Simulator Configuration.exe*, since you will need those two applications a lot. After that, you want to visit the Config folder. If you want to start with a clean, empty setup and configuration, you must delete all *.ini files. Maybe it is a good idea to make a backup copy for later reference. As an alternative leave the config files in place and use the given configuration as a starting point to understand how everything works, and create your own setup & configuration later. Also, leave the *Simulator Tools.targets* file in place, since it contains the build rules used when developing plugins.

Whenever you will install a new release in the future, you need to save your own config files in the *Config* folder, before unzipping the new distribution. Depending own your addtional customization, you will also want to save your media files (see the section about [custom media files](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#using-your-own-pictures-videos-and-sounds-for-all-the-splash-screens) below), and all your plugin development results (see the [plugin development guide](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#introduction) for more information about that).

## Installing additional components

As already mentioned in the [README](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/README.md#third-party-applications) of a lot of third party applications, that might be controlled by Simulator Controller or will enhance the user experience. Please take a look at this list and decide, which ones you want to install. If you want to start your own plugin development or even change the code of the Simulator Controller itself, you definitely need to have [AutoHotkey](https://www.autohotkey.com/) installed. Beside that, I recommend at least [VoiceMacro](http://www.voicemacro.net/) for handling voice commands, and depending on your rig setup, [SimHub](https://www.simhubdash.com/) and [SimFeedback](https://www.opensfx.com/). For the later two, very sophisticated support is built into the Simulator Controller already.

## Using your own pictures, videos and sounds for all the splash screens

The startup process of Simulator Controller can entertain you with splash images and even play videos and emotional songs while starting all the components or your favorite simulation game (no worry, this can be completely switched off using the setup tool (*), if you prefer a more reduced kind of life style). The standard distribution comes with some default media from the GT3 world, but, since every racer or even pilot might have a different taste, you can install your own media files. You will find all the media files in the *Resources/Splash Media* folder, you can put any JPG GIF, WAV or MP3 file their, as long as pictures implement a strict 16:9 format. Last but not least, you can use the configuration tool to choose between picture carousel or GIF animation, whether to play on of the sound files during startup, and so on.

# Setup

The different components of Simulator Controller can be customized to a large extent. Part of this customization is handled by the setup process, which typically you need to do only once, or maybe, when the configuration of your simulation rig might change in the future. This overall setup is handled by a specialized graphical tool, which will be described in the following chapter. Other customization, which address special aspects of the operation of the different applications of Simulator Controller, are handled by configuration dialogs, which will be described in the corresponding documentation chapter about these applications.

## Running the setup tool

The setup tool is located in the *Binaries* folder and is named *Simulator Setup.exe*. If you start this little tool, the following window will be opened.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Setup%20Tool.JPG)

In the following chapter, you will find an explanation of each tab and its content. Before you start experimenting with the setup tool, be sure to make a backup copy of the current configuration file *Simulator Configuration.ini* in the *Config* folder.

Beside simply running the setup application by double clicking it, there are two hidden modifiers. First, if you hold the control key down while starting the setup tool, any currently available configuration file in the *Config* folder will be ignored and the setup will start with a fresh, completely empty configuration. And if you hold the shift key down, additional options for developer will be available. These will automatically be available, when an active AutoHotkey installation is detected (by checking if the folder C:\Program Files\AutoHotkey is available).

## Using the setup tool

The setup tool consists of several pages or tabs. Below you will find a description of each page. Beside the pages, there are the well known buttons "Ok", "Cancel" and "Apply". A fourth button named "Key Detector" will help you identifiying the key codes of your hardware controller, but this will be described in the chapter about the Controller tab.

### Tab *General*

As the name of this tab suggests, some very general configuration are available. In the *Installation Folders* group you can identify the root folder of the Simulator Controller installation - optional in most cases, but it may provide some performance benefits. The second path identifies the NirCmd executable, which is used by the Simulator Controller to control the sound volume of some simulation games. Optional, but helpful. See the [README](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications) for a link to the NirCmd download.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Setup%20Tab%201.JPG)

The second group, *Startup*, allows you to choose whether the Simulator Controller will startup together with Windows and that it will run silently, i.e. without any splash animation or sound.

You can add all the simulation games installed on your PC to the list in the third group *Simulators*. For each entry here, you also need to enter a similar named application in the applications tab. The order of the entries in the *Simulators* list is important, at least the first entry has a special role. More on that later. You can change the order with the "Up" and "Down" button, if an entry is selected. As with any list in the setup tool, an entry must be selected with a double click for editing.

The last group, which is only present in developer mode, as mentioned above, lets you activate the debug mode, define the log level and enter the path to an AutoHotkey installation on your PC. Be careful with the log level *Info*, since the log files found in the *Logs* folder may grow very fast.

### Tab *Plugins*

In this tab you will configure the plugins currently in use by the Simulator Controller.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Setup%20Tab%202.JPG)

Beside temporarily deactivating a plugin and all its modes, you can define a comma seperated list of simulator names. This will restrict the modes of the plugin to only be available, when these simulators are running. The most important field here is the *Arguments* field. Here you can supply values for all the configuration arguments of the given plugin. The format is like this: "parameter1: value11, value12, value13; parameter2: value21, value22; ...". Please take a look at the [plugin reference](*) for an in depth explanation of all the arguments of the builtin plugins. Last but not least, you will find an "Edit Labels" button on this tab. Pressing this button will open a simple text file, where you can edit the labels, some plugins display on the visual hardware controller display. cHange them to your liking.

Note: You can deactivate or delete all plugins except *System*. The *System* plugin is required and part of the framework. If you delete a plugin here, it will still be loaded by the Simulator Controller, but it won't be activated. If you add a plugin here, but haven't added any plugin code, nothting will happen. And, last but not least, the plugin names given here must be identical to those, used in the plugin code. Some sort of primary key, hey. See the documentation on [plugin development](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts) for further information.

### Tab *Applications*

