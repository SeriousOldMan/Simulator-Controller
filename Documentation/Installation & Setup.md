## Installation

Download one the releases, preferably the latest stable build, and unzip at any location you like. Then go to the Binaries folder. There are five applications. I recommend to add a start menu shortcut to *Simulator Startup.exe* and *Simulator Configuration.exe*, since you will need those two applications a lot. After that, you want to visit the Config folder. If you want to start with a clean, empty setup and configuration, you must delete all *.ini files. Maybe it is a good idea to make a backup copy for later reference. As an alternative leave the config files in place and use the given configuration as a starting point to understand how everything works, and create your own setup & configuration later. Also, leave the *Simulator Tools.targets* file in place, since it contains the build rules used when developing plugins.

Whenever you will install a new release in the future, you need to save your own config files in the *Config* folder, before unzipping the new distribution. Depending own your addtional customization, you will also want to save your media files (see the section about [custom media files](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#using-your-own-pictures-videos-and-sounds-for-all-the-splash-screens) below), and all your plugin development results (see the [plugin development guide](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#introduction) for more information about that).

### Installing additional components

As already mentioned in the [README](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/README.md#third-party-applications) of a lot of third party applications, that might be controlled by Simulator Controller or will enhance the user experience. Please take a look at this list and decide, which ones you want to install. If you want to start your own plugin development or even change the code of the Simulator Controller itself, you definitely need to have [AutoHotkey](https://www.autohotkey.com/) installed. Beside that, I recommend at least [VoiceMacro](http://www.voicemacro.net/) for handling voice commands, and depending on your rig setup, [SimHub](https://www.simhubdash.com/) and [SimFeedback](https://www.opensfx.com/). For the later two, very sophisticated support is built into the Simulator Controller already.

### Using your own pictures, videos and sounds for all the splash screens

The startup process of Simulator Controller can entertain you with splash images and even play videos and emotional songs while starting all the components or your favorite simulation game (no worry, this can be completely switched off using the setup tool (*), if you prefer a more reduced kind of life style). The standard distribution comes with some default media from the GT3 world, but, since every racer or even pilot might have a different taste, you can install your own media files. You will find all the media files in the *Resources/Splash Media* folder, you can put any JPG GIF, WAV or MP3 file their, as long as pictures implement a strict 16:9 format. Last but not least, you can use the configuration tool to choose between picture carousel or GIF animation, whether to play on of the sound files during startup, and so on.

## Setup

The different components of Simulator Controller can be customized to a large extent. Part of this customization is handled by the setup process, which typically you need to do only once, or maybe, when the configuration of your simulation rig might change in the future. This overall setup is handled by a specialized graphical tool, which will be described in the following chapter. Other customization, which address special aspects of the operation of the different applications of Simulator Controller, are handled by configuration dialogs, which will be described in the corresponding documentation chapter about these applications.

### Running the setup tool

The setup tool is located in the *Binaries* folder and is named *Simulator Setup.exe*. If you start this little tool, the following window will be opened.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Setup%20Tool.JPG)

Beside starting the setup application as usual, there are two hidden modifiers. First, if hold the control key down, while starting the setup tool, any currently available configuration file in the *Config* folder will be ignored and the setup will start with a fresh, completely empty configuration.