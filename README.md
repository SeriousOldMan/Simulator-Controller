# Simulator Controller

Simulator Controller is a modular and extandable adminstration and controller application for complex Sim Racing Rigs. At the core is a comprehensive plugin capable automation framework, which can use almost any external controller hardware, such as Button Boxes, to control typical simulator components such as SimHub, SimFeedback and alike. Beside that, Simulator Controller also comes with several voice chat capable assistants, which are based on artificial intelligence technologies. The first, a kind of Virtual Race Engineer, will assist you during your races to keep the hands on the wheel. It will handle all the cumbersome stuff, like preparing a pitstop, take an eye on the weather forecast, calculate damagae impact on your lap times, and so on. The second assistant, a Virtual Race Strategist, will keep an eye on the overall race situation and will develop and adapt strategies depending on race position, traffic and weather changes. Last, but not least, a Virtual Race Spotter will watch over your race and will warn you about crtical situations with nearby cars, and so on.

Beside that, Simulator Controller brings even a bunch of other functionality and features to make the life of all of us virtual racers even more fun and simple. You will find a [comprehensive overwiew](https://github.com/SeriousOldMan/Simulator-Controller#main-features) of all features later in this document, but first things first...

### Donation

If you find this tool useful, please help me with the further development. Any donation contributed will be used only to support the project.

[![](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate?hosted_button_id=7GV86ZPS95SL6)

Another possibility is to use [Patreon](https://www.patreon.com/simulatorcontroller) to give me a hug, and as a benefit, you might get access to the public Team Server for your multiplayer endurance races.

Thank you very much for your support!

### Download and Installation

Installation is very easy. For first time users I recommand using the automated installer below. But there are different download and installation options available. Please see the complete documentation about [Installation & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) for more information.

#### Antivirus Warnings

The programming language used for building Simulator Controller uses some really nasty tricks to control Windows applications, tricks also used by malware. Therefore, depending on your concrete Antivirus program, you may get some warnings regarding the Simulator Controller applications. I can assure you, that there's nothing about it. But you can read about these issues in the forums of [AutoHotkey](https://www.autohotkey.com/) itself. If your Antivirus programm allows exception rules, please define rules for the Simulator Controller applications, otherwise you need to have a beer and search for another Simulator Controller tool. Sorry...

If you don't want to use the automated installer (or you can't cause of your Antivirus protection), you can manually install one of the versions below. There are separate download links for the current development build and at least the two latest stable releases. Download one of these builds and unzip it anywhere on your hard disks. Beginnging with Release 3.5.2, you then need to run the "Simulator Tools" application in the *Binaries* folder. This will guide you through the remaining installation process. For release information, even for a preview on upcoming features in the next stable build, don't miss the [Release Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Notes).

#### Automated Installer

Simply download and run [Simulator Controller.exe](https://bit.ly/3vCSIa1) (you may have to deactivate your Antivirus or Browser download protection). This small application will connect to the version repository and will download and install the latest version automatically for you. If you want to install a version other than the current one, no problem. This is possible by downloading and installing one of the versions below manually, but consult the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#installation) beforehand.

#### Latest release build

VERY IMPORTANT (for users with an already configured installation of Simulator Controller):
An automated update mechanism for local configuration databases exists since Release 2.0. Please read the [information about the update process](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes) carefully before starting one of the Simulator Controller applications. It might also be a good idea, to make a backup copy of the *Simulator Controller* folder in your user *Documents* folder, just to be on the safe side. Also, if you have installed and used a prerelease version, it will be necessary to rerun the automatic update. Please consult the documentation mentioned above on how to do this.

[4.0.4-release](https://cntr.click/NbqY9MC) (New features: Fixed pitstop window requirements in "Strategy Workbench", Many more search image presets in "Simulator Setup" thanks to community contributions, Performance optimization in Strategist Rules, Fixed position reporting for R3E, Fixed various bugs in "Race Center", Introduced *Sector* handling in Race Assistants, More frequent position and gap update for Race Strategist and Race Spotter, Fixed Spotter endlessly announcing pit window in ACC, Rework of translation management.)

Please read the [Release Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Notes) and - even more important - the release specific [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-404) of this version and all the versions you might have skipped, before installing and using this version.


##### Earlier release builds

[4.0.2-release](https://cntr.click/vsGR3Xs) (New features: Support for cloud based voice recognition using Azure Cognitive Services, Presets and Special Configurations for "Simulator Setup", Spotter announcements will start with the green flag for all simulators, Extended patch mechanism for generated configuration files.)

[4.0.0-release](https://cntr.click/qZkSR66) (New features: Consolidation and update process for shared database, Many new commands for the race assistants to control the warning verbosity, Support for .NET compatible TTS 5.1 voices for voice output, Renamed assistant plugin parameter "raceAssistantService" to "raceAssistantSynthesizer", New plugin parameter "raceAssistantRecognizer" for all assistant plugins, Updated ACC car model information, Updated R3E car model information.)

#### Latest development build

None for the moment...

### Discord Community

If you want to become a part of the small and very young Community for Simulator Controller on Discord, please use [this invitation](https://discord.gg/5N8JrNr48H)...

### Main features

  - Connect all your external controller, like Button Boxes, Stream Decks, and so on, to one single center of control
    - An unlimited number of layers of functions and actions, called modes, can be defined for your controller. Switch between modes simply by pushing a button or switch a toggle on your controller. Here is an example of several layers of functions and actions combined in five modes:
	
	![](./Docs/Images/Button%20Box%20Layout.jpg)
	
	- Modes are defined and handled by [plugins](https://github.com/SeriousOldMan/Simulator-Controller#included-plugins), which can be implemented using an object oriented scripting language.
  - Configurable, visual feedback for your controller actions
    - Define your own Button Box visual representation and integrate it with the Simulator Controller using the simple plugin support and a graphical layout editor. Depending on configuration, the Button Box window will popup whenever an action is triggered from your controller, even during active simulation, or it might stay open all the time, if you have anough screen space, for example a second monitor.
    
    ![](./Docs/Images/Button%20Box%202.JPG)
    
    - Code your own functions to be called by the controller buttons and switches using the simple, object-oriented scripting language
  - Configure all additional [applications](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications) to your taste, including the simulation games used for your virtual races
    - Start and stop applications from your controller hardware or automatically upon configurable events
    - Add splash screens and title melodies using a themes editor for a more emotional startup experience
    - Full support for sophisticated application automation - for example, start your favorite voice chat software like TeamSpeak and automatically switch to your standard channel 
  - Several plugins are supplied out of the box:
    - Support for *Assetto Corsa*, *Assetto Corsa Competizione*, *rFactor 2*, *iRacing*, *Automobilista 2* and *RaceRoom Racing Experience* is already builtin, other simulation games will follow
    - Fully customizable plugins supplied for total control of SimHub and SimFeedback - change your settings while racing using the dials and switches on your favorite Button Box
	- Control the calibration curves of your high end pedals by a simple button press with the plugin for the Heusinkveld pedal family
    - Send your predefined kudos and rants to the ingame chat without touching the keyboard
  - Additional support to trigger every function and action from external sources like a voice or gesture recognition software to always keep your hands on the wheel
  - Builtin support for visual head tracking to control ingame viewing angle - see [third party applications](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications) below

#### Virtual Race Engineer & Virtual Race Strategist

An AI based Race Engineer with fully dialog capable voice control will guide you through your race, warn you about critical technical issues and will help you with the pitstop, whereas the Race Strategist keeps an eye on the race positions, develops a pitstop strategy, and so on. These smart chat bots are independent applications, but are integreated with the ACC and other simulation game plugins using interprocess communication right now. An integration for a new simulation games requires some effort, especially for the necessary data acquisition from the simulation game, but a knowledged programmer can manage it in about three to four hours.

Based on the data sets, that are acquired during your sessions by the Virtual Race Assistants, a very flexible tool allows you to [analyze your performance](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports) and the performance of your opponents in many different ways.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Reports%202.JPG)

Another capability of the Virtual Race Strategist is to support you during the [development of a strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#strategy-development) for an upcoming race using the telemetry data of past sessions on the same track in similar conditions.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Strategy%20Workbench.JPG)

You can even use all these functionalities during multiplayer team races using the [*Team Server*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server), which handles the state and knowledge of the Race Assistants and share this information between all participating drivers. The Team Server also supports a so called "Race Center", a console, which can be used by any team member (even if not an active driver) to gather all kind of session data and remote control various aspects of the session, for example the settings for an upcoming pitstop.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Race%20Center%201.JPG)

#### Virtual Race Spotter

Simulator Controller also comes with a Virtual Spotter, which will keep an eye on the traffic around you and will warn you about critical situations. You can fully customize the information provided by the Spotter to your specific needs and taste.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%2011.JPG)

#### Setup Advisor

Another very useful tool of the Simulator Controller suite is the Setup Advisor. This tool is based upon the AI technology which is used by the Race Assistants and generates recommendations for changing the setup options of a car based on problem descriptions provided by the driver.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Setup%20Advisor.JPG)

### Additional features

  - Configurable and automated build tool for developers
  - Sophisticated logging, tracing and debug support to track down any errors while developing your own plugins
  - Fully graphical configuration utilities
  
  ![](./Docs/Images/Settings%20Editor.JPG) ![](./Docs/Images/Configuration%20Editor.JPG)

Simulator Controller has been implemented to great extent in AutoHotkey, a very sophisticated and object-oriented Windows automation and scripting language, which is capable to connect keyboard and other input devices to functions in the script with a simple macro language. On the other hand, AutoHotkey also has a lot of robotics capabilities to automate software packages, which do not provide external APIs, by simulating mouse clicks and keyboard input. You can write your own plugins using the AutoHotkey language. To get you started, full source code for all bundled plugins with different complexity from simple to advanced is included.

You will also find a lot of C#, C++ and even C code for the low-level stuff like telemetry data acquisition or connecting to cloud services on the Azure cloud. Here also, all the sources are open and free to use. Last, but not least, and not for the faint-hearted, there is a hybrid, forward and backward chaining rule engine used to implement the Virtual Race Assistants. It uses a modified RETE-algorithm to be as efficient as possible when using large numbers of facts.

### Included plugins

These plugins are part of the Simulator Controller distribution. Beside providing functionality to the core, they may be used as templates for building your own plugins. They range from very simple functional additions with only a small number of lines of code up to very complex, multi-class behemoths controlling external software such as SimHub.

| Plugin | Description |
| ------ | ------ |
| [System](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-system) | Handles multiple Button Box layers and manages all applications configured for your simulation configuration. |
| [Button Box](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts) | Tools for building your own Button Box / Controller visuals. The default implementation of *ButtonBox* implements grid based Button Box layouts, which can be configured using a [graphical layout editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts). |
| [Stream Deck](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#stream-deck-layouts) | Tools for connecting one or more Stream Decks as external controller to Simulator Controller. A special Stream Deck plugin is provided, which is able to dynamically display information both as text and/or icon on your Stream Deck. |
| [Tactile Feedback](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-tactile-feedback) | Fully configurable support for pedal and chassis vibration using [SimHub](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). |
| [Motion Feedback](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-motion-feedback) | Fully configurable support for rig motion feedback using [SimFeedback](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). |
| [Pedal Calibration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-pedal-calibration) | Allows to choose between the different calibration curves of your high end pedals directly from the hardware controller. |
| [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) | This plugin integrates Jona, the Virtual Race Engineer, with all other plugins for the simulation games, like the ACC plugin. The plugin handles the data transfer between the simulation game and the Virtual Race Engineer. |
| [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) | This plugin integrates Cato, the Virtual Race Strategist, with all other plugins for the simulation games, like the ACC plugin. The plugin handles the data transfer between the simulation game and the Virtual Race Strategist. |
| [Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) | This plugin integrates Elisa, the Virtual Race Spotter, with all other plugins for the simulation games, like the ACC plugin. The plugin handles the data transfer between the simulation game and the Virtual Race Spotter. |
| [Team Server](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server) | The *Team Server* supports using the Virtual Race Assistants even in a multiplayer team race. It is based on a serverside solution, which manages the state of the car and assistants knowledge and passes them between the participating drivers. |
| [ACC](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) | Provides special support for starting and stopping *Assetto Corsa Competizione* from your hardware controller. The mode "Chat", which is available when *Assetto Corsa Competizione* is currently running, handle automated chat messages for the multiplayer ingame chat system, where the chat messages can be configured by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Additionally, beginning with Release 2.0, this plugin provides sophisticated support for the Pitstop MFD of *Assetto Corsa Competizione*. All settings may be tweaked with the controller hardware using the "Pitstop" mode, but it is also possible to control the settings using voice control to keep your hands on the steering wheel. An integration with Jona, the Virtual Race Engineer, wtih Cato, the Virtual Race Strategist and also with Elisa, the Virtual Race Spotter is available. The "Assistant" mode can handle most of the race assistant commands from your hardware controller. |
| [AC](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-ac) | One of the smallest plugin in this list only supplies a special splash screem, when *Assetto Corsa* is started. No special controller mode is defined for the moment. |
| [AMS2](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-AMS2) | Also a small plugin in this list only supplies a special splash screem, when *Automobilista 2* is started. An integration with Jona, the Virtual Race Engineer, wtih Cato, the Virtual Race Strategist and also with Elisa, the Virtual Race Spotter is available. The plugin also supports a "Pitstop" mode for adjusting pitstop settings and a "Assistant" mode to interact with the race assistants. |
| [IRC](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-irc) | This plugin integrates the *iRacing* simulation game with Simulator Controller. A "Pitstop" mode is available to control the pitstop settings from your controller hardware and an integration with Jona, the Virtual Race Engineer, wtih Cato, the Virtual Race Strategist and also with Elisa, the Virtual Race Spotter is available as well. The "Assistant" mode can handle most of the race assistant commands from your hardware controller. |
| [RF2](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-rf2) | Similar to the ACC and IRC plugin provides this plugin start and stop support for *rFactor 2*. A "Pitstop" mode is available to control the pitstop settings from your controller hardware and an integration with Jona, the Virtual Race Engineer, and with Cato, the Virtual Race Strategist is available as well. The "Assistant" mode can handle most of the race assistant commands from your hardware controller. |
| [R3E](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-rre) | Similar to the ACC, IRC and RF2 plugins provides this plugin start and stop support for *RaceRoom Racing Experience*. A "Pitstop" mode is available to control the pitstop settings from your controller hardware and an integration with Jona, the Virtual Race Engineer, wtih Cato, the Virtual Race Strategist and also with Elisa, the Virtual Race Spotter is available as well. The "Assistant" mode can handle most of the race assistant commands from your hardware controller. |

### Third party applications

The following applications are not part of the distribution and are not strictly necessary for Simulator Controller. But Simulator Controller is aware of these components and will integrate them for a better overall experience, if available.

| Application | Description |
| ------ | ------ |
| [AutoHotkey](https://www.autohotkey.com/) | [Development Only] Object oriented scripting language. You need it, if you want to develop your own plugins. |
| [Visual Studio](https://visualstudio.microsoft.com/de/vs/) | [Development Only] Development environment for Windows applications. Used for the development of the different telemetry interfaces of the supported simulation games. |
| [NirCmd](https://www.nirsoft.net/utils/nircmd.html) | [Optional] Extended Windows command shell. Used by Simulator Controller to control ingame sound volume settings during startup. |
| [SoX](http://sox.sourceforge.net/) | [Optional] Audio processing utility. Used by the race assistants for audio post processing to achieve a team radio like audio quality. |
| [VoiceMacro](http://www.voicemacro.net/) | [Optional] Connects to your microphone and translates voice commands to complex keyboard and/or mouse input. These macros can be connected to Simulator Controller as external input to control functions and actions identical to your hardware controller. |
| [AITrack](https://github.com/AIRLegend/aitrack) | [Optional] Neat little tool which uses neural networks to detect your viewing angle on a dashcam video stream. Used in conjunction with opentrack to control your ingame viewing angle. |
| [opentrack](https://sourceforge.net/projects/opentrack.mirror/) | [Optional] Connects to your simulation game and controls the viewing angle using the freetrack protocol. Several input methods are supported, for example analog joysticks or UDP based sources such as AITrack. |
| [SimHub](https://www.simhubdash.com/) | [Optional] Versatile, multipurpose software collection for simulation games. Generates vibration using bass shakers or vibration motors and provides a fully integrated Arduino development environment. Additional features support the definition of custom dashboards. A special plugin is part of Simulator Controller to control the tactile feedback options of SimHub, such as vibration strength, with a touch of a button. |
| [SimFeedback](https://www.opensfx.com/) | [Optional] Not only a software, but a complete DIY project for building motion rigs. SimFeedback controls the motion actuators using visual control curves, which translate the ingame physics data to complex and very fast rig movements. Here also, a plugin is integrated in Simulator Controller to use your hardware controller for controlling SimFeedback. |
| [SFX-100-Streamdeck](https://github.com/ashupp/SFX-100-Streamdeck) | [Optional] This extension for SimFeedback is used to connect to SimFeedback in order to control effect states and intensities. If not used, a subset of the SimFeedback settings will be controlled by mouse automation, which on a side effect requires the SimFeedback window to be the topmost. Since this is not really funny, while currently trying to overtake one of your opponents in a difficult chicane, I strongly advice to install the connector extension, but this requires the *commercial* expert license for SimFeedback. You will find a copy of the *SFX-100-Streamdeck* plugin in the *Utilities\3rd Party* folder for your convenience. And don't forget to read the [installation & configuration instructions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-motion-feedback), since there are two steps necessary. |
| [Microsoft Voice Languages](https://support.microsoft.com/en-us/office/how-to-download-text-to-speech-languages-for-windows-10-d5a6b612-b3ae-423f-afa5-4f6caf1ec5d3) | [Optional] Depending on your Windows version and your selected language, you might want to install additional *Text-to-Speech* languages from Microsoft for the speech generation capabilities of Simulator Controller, especially for Jona, the Virtual Race Engineer. |
| [Microsoft Voice Recognition](https://www.microsoft.com/en-us/download/details.aspx?id=16789) | [Optional] Also depending on your Windows version and your selected language, you might want to install additional *Speech-to-Text* or voice recognition languages from Microsoft, especially for Jona, the Virtual Race Engineer. You will find a copy of the language runtime and some selected recognizer in the *Utilities\3rd Party* folder for your convenience. |
| [rFactor 2 Telemetry Provider](https://github.com/TheIronWolfModding/rF2SharedMemoryMapPlugin) | [Optional] If you are running the *rFactor 2* simulation game and want to use Jona, the Virtual Race Engineer during your races, you need to install this data aqcuisition plugin in your *rFactor 2* application directory. You will find a copy of the plugin (named *rf2_sm_tools_3.7.14.2.zip*) including a Readme file in the *Utilities\3rd Party* folder for your convenience. |

### Documentation

A very [extensive documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki) will guide you through the configuration process and will help you to understand the inner concepts and all the functions & features of Simulator Controller. For developers, who want to create their own plugins, a complete [developers guide & reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts) is available as well.

The markdown files, the so to say source code of this documentation Wiki, can be found in the [Docs](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Docs) folder.

### Discord Community

If you want to become a part of the small and very young Community for Simulator Controller on Discord, please use [this invitation](https://discord.gg/5N8JrNr48H)...

### Known issues

1. Connection between the "Motion Feedback" plugin and *SimFeedback* has some stabilty issues. Looks like the root cause is located in the *SFX-100-Streamdeck* extension. For a workaround click on "Reload Profile..." on the Extensions tab in SimFeedback, if you see strange numbers in the Button Box "Motion" mode page.

### Development

For new features coming in the next release, take a look at the [Release Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Notes).

Want to contribute? Great!

  - Build your own plugins and offer them on GitHub or join the [Discord community](https://discord.gg/5N8JrNr48H) and post your plugin in the #share-your-mods channel. Contact me and I will add a link to your plugin in this documentation.
  - Found a bug, or built a new feature? Even better. Please contact me, and I will give you access to the code repository.

Heads Up: I am looking for a co-developer for the some fancy upcoming AI stuff.

### To Do

After firing out one release per week during the last few weeks, the project will slow down a little bit from now on. But the development of Simulator Controller still goes on, and I am sure that we will end up in a two weeks cycle in the long run. My own list of ideas in the [backlog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Backlog) is always long enough for at least three more releases and if you want to propose a feature to be included in the backlog, you can open an enhancement issue on GitHub or join the [Discord community](https://discord.gg/5N8JrNr48H) and post your idea on the #request-a-feature channel...

### License

This software is provided as is. You are free to use it for any purpose and modify it to your needs, as long as you do not use it for any commercial purposes.

(2022) Creative Commons - BY-NC-SA - by Oliver Juwig (TheBigO)
