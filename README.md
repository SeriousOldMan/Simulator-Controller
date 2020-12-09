# Simulator Controller

Simulator Controller is a modular and extandable adminstration and controller application for complex Sim Racing Rigs. At the core is a comprehensive plugin capable automation framework, which can use almost any external controller hardware, such as button boxes, to control typical simulator components such as SimHub, SimFeedback and alike. But there are a lot more functionality and features available to make the life of all of us virtual racers even more fun and simple. You will find a [comprehensive overwiew](https://github.com/SeriousOldMan/Simulator-Controller#main-features) of all features later in this document, but first things first...

### Donation

If you find this tool useful, please help me with the further development. Any donation contributed will be used only to support the project.

[![](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate?hosted_button_id=7GV86ZPS95SL6)

Thank you very much for your support!

### Download and Installation

Download one of the builds below and unzip anywhere you like. Then run the setup tool available in the Binaries folder and configure your environment (you may want to delete all *.ini files the Config folder to start out with a really fresh setup, but be sure to make a backup copy elsewhere for later reference, especially for the *Simulator Configuration.ini* file. An installation of the underlying programming language [AutoHotkey](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications) is only necessary, if you want to create your own plugins, but you need a good understanding of the Hotkey syntax to bind your controller hardware to the plugin functions and actions using the setup tool.
For further convinience, you can place links to **Simulator Startup** and **Simulator Configuration** in the Windows Start Menu. You can also configure the software to automatically start with Windows by checking the *Start with Windows* in the first tab of the setup tool.

#### Latest development builds

[0.9.1-alpha](https://www.dropbox.com/s/v9m80hkprcegz6v/Simulator%20Controller%200.9.1a.zip?dl=1)

[0.9.5-beta](https://www.dropbox.com/s/sxyg0fvwmdr3xtu/Simulator%20Controller%200.9.5b.zip?dl=0)

#### Latest stable builds

*Will be available soon*

### Main features

  - Connect all your external controller, like button boxes, to one single center of control
    - An unlimited number of layers of functions and actions, called modes, can be defined for your controller. Switch between modes simply by pushing a button or switch a toggle on your controller. Here is an example of several layers of functions and actions combined in five modes:
	
	![](./Resources/Documentation%20Images/Button%20Box%20Layout.png)
	
	- Modes are defined and handled by [plugins](https://github.com/SeriousOldMan/Simulator-Controller#included-plugins), which can be implemented using an objecct oriented scripting language.
  - Configurable, visual feedback for your controller actions
    - Define your own button box visual and integrate it with the Simulator Controller using the simple plugin support. Depending on configuration, this window will popup whenever an action is triggered from your controller, even during active simulation
    
    ![](./Resources/Documentation%20Images/Button%20Box%202.JPG)
    
    - Code your own functions to be called by the controller buttons and switches using the simple, object-oriented scripting language
  - Configure all additional [applications](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications) to your taste, including the simulation games used for your virtual races
    - Start and stop applications from your controller hardware or automatically upon configurable events
    - Add splash screens and title melodies for a more emotional startup experience
    - Fully support for sophisticated application automation - for example, start your favorite voice chat software like TeamSpeak and automatically switch to your standard channel 
  - Several plugins supplied out of the box:
    - Support for Assetto Corsa and Assetto Corsa Competizione already builtin
    - Fully customizable plugins supplied for total control of SimHub and SimFeedback - change your settings while racing using the dials and switches on your favorite button box
    - Send your predefined kudos and rants to the ingame chat without touching the keyboard
  - Additional support to trigger every function and action from external sources like a voice or gesture recognition software to always keep your hands on the wheel
  - Builtin support for visual head tracking to control ingame viewing angle - see [third party applications](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications) below

Simulator Controller is fully implemented in AutoHotkey, a very sophisticated and object-oriented Windows automation scripting language, which is capable to control keyboard and other input devices with a simple macro language. On the other hand, AutoHotkey also has a lot of robotics capabilities to automate software packages, which do not provide an external APIs by simulating mouse clicks and keyboard input. You can write your own plugins using the AutoHotkey language. Full source code for all prebuilt plugins with different complexity from simple to advanced is provided to help you get started.

### Additional features

  - Configurable and automated build tool for developers
  - Sophisticated logging, tracing and debug support to track down any errors while developing your own plugins
  - Fully graphical setup and configuration utilities
  
  ![](./Resources/Documentation%20Images/Configuration%20Tool.JPG) ![](./Resources/Documentation%20Images/Setup%20Tool.JPG)

### Included plugins

These plugins are part of the Simulator Controller distribution. Beside providing functionality to the core, they may be used as templates for building your own plugins. They range from very simple functional additions with only a small number of lines of code up to very complex, multi-class behemoths controlling external software such as SimHub.

| Plugin | Description |
| ------ | ------ |
| System | Handles multiple button box pages and starting and stopping of all applications. |
| Tactile Feedback | Support for pedal and chassis vibration using SimHub. |
| Motion Feedback | Support for rig motion feedback using SimFeedback. |
| ACC | Support for starting and stopping Assetto Corsa Competizione. |
| AC | Support for starting and stopping Assetto Corsa. |
| Button Box | Tools for building your own button box visuals. An easy to understand example will help you building the screen representation of your own button boxes. |

### Third party applications

The following applications are not part of the distribution and are not strictly necessary for Simulator Controller. But Simulator Controller is aware of these components and will integrate them for a better overall experience, if available.

| Application | Description |
| ------ | ------ |
| [AutoHotkey](https://www.autohotkey.com/) | [Development Only] Object oriented scripting language. You need it, if you want to develop your own plugins. |
| [NirCmd](https://www.nirsoft.net/utils/nircmd.html) | [Optional] Extended Windows command shell. Used by Simulator Controller to control ingame sound volume settings during startup. |
| [VoiceMacro](http://www.voicemacro.net/) | [Optional] Connects to your microphone and translates voice commands to complex keyboard and/or mouse input. These macros can be connected to Simulator Controller as external input to control functions and actions identical to your hardware controller. |
| [AITrack](https://github.com/AIRLegend/aitrack) | [Optional] Neat little tool which uses neural networks to detect your viewing angle on a dashcam video stream. Used in conjunction with opentrack to control your ingame viewing angle. |
| [opentrack](https://sourceforge.net/projects/opentrack.mirror/) | [Optional] Connects to your simulation game and controls the viewing angle using the freetrack protocol. Several input methods are supported, for example analog joysticks or UDP based sources such as AITrack. |
| [SimHub](https://www.simhubdash.com/) | [Optional] Versatile, multipurpose software collection for simulation games. Generate vibration using bass shakers or vibration motors using a fully integrated Arduino development environment. Additional features support the definition of custom dashboards. A special plugin is available to control the tactile feedback options of SimHub, such as vibration strength, with a touch of a button. |
| [SimFeedback](https://www.opensfx.com/) | [Optional] Not only a software, but a complete DIY project for building motion rigs. SimFeedback controls the motion actuators using visual control curves, which translate the ingame physics data to complex and very fast rig movements. Here also, a plugin is available to use your controller for controlling SimFeedback. |
| [SFX-100-Streamdeck](https://github.com/ashupp/SFX-100-Streamdeck) | [Optional] This extension for SimFeedback is used to connect to SimFeedback in order to control effect states and intensities. If not used, a subset of the SimFeedback settings will be controlled by mouse automation, which on a side effect requires the SimFeedback window to be the topmost. Since this is not really funny, while currently trying to overtake one of your opponents in a difficult chicane, I strongly advice to install the connector extension, but this requires the *commercial* expert license for SimFeedback. |


### Documentation

Coming soon. In the meantime use all the given goodies, especially the very large sample configuration as a starting point.

### Known issues

1. Sometimes, the ingame sound volume is not correctly resetted after playing the startup melody. In those situations, you can use the mixer utility of Windows to bring the volume back up.

### Development

Want to contribute? Great!

  - Build your own plugins and  offer them on GitHub. Contact me and I will add a link to your plugin in this documentation.

  - Found a bug, or built a new feature? Even better. Please contact me, and I will give you access to the code repository.

### Todos

 - Add full documentation Wiki and a FAQ

### License

This software is provided as is. You are free to use it for any purpose and modify it to your needs, but commercial use is strictly prohibited.

(2020) Creative Commons - BY-NC-SA - by Oliver Juwig (TheBigO)
