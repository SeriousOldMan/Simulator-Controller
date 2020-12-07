# Simulator Controller

Simulator Controller is a modular and extandable adminstration and controller application for complex Sim Racing Rigs. At the core is a comprehensive plugin capable automation framework, which can use almost any external controller hardware, such as button boxes, to control typical simulator components such as SimHub, SimFeedback and alike. But there are a lot more functionality and features available to make the life of all of us virtual racers even more fun and simple.

### Donation

If you find this tool useful, please help me with the further development. Any donation contributed will be used only to support the project.

[![](https://www.paypalobjects.com/en_US/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/donate?hosted_button_id=7GV86ZPS95SL6)

### Main features

  - Connect all your external controller, like button boxes, to one single center of control
    - Define an unlimited number of collections of functions and actions, call modes, for your controller. Switch between modes simply by pushing a button or switch a toggle on your controller
	
	![](./Resources/DocumentationImages/Button%20Box%20Layout.png)
	
  - Configurable, visual feedback for your controller actions
    - Define your own button box layout and integrate it with the Simulator Controller using the simple plugin support
    
    ![](./Resources/DocumentationImages/Button%20Box%202.JPG)
    
    - Code your own functions to be called by the controller buttons and switches using the simple, object-oriented scripting language
  - Configure all additional applications to your taste, including the simulation games used for your virtual races
    - Start and stop applications from your controller hardware or automatically upon configurable events
    - Add splash screens and title melodies for a more emotional startup experience
    - Fully support for sophisticated application automation - for example, start your favorite voice chat software like TeamSpeak and automatically switch to your standard channel 
  - Several plugins supplied out of the box:
    - Support for Assetto Corsa and Assetto Corsa Competizione already builtin
    - Fully customizable plugins supplied for total control of SimHub and SimFeedback - change your settings while racing using the dials and switches on your favorite button box
    - Send your predefined kudos and rants to the ingame chat without touching the keyboard
  - Additional support to trigger every function and action from external sources like a voice or gesture recognition software to always keep your hands on the wheel
  - Builtin support for visual head tracking to control ingame viewing angle - see third party applications below

Simulator Controller is fully implemented in AutoHotkey, a very sophisticated and object-oriented Windows automation scripting language, which is capable to control keyboard and other input devices with a simple macro language. On the other hand, AutoHotkey also has a lot of robotics capabilities to automate software packages, which do not provide an external APIs by simulating mouse clicks and keyboard input. You can write your own plugins using the AutoHotkey language. Full source code for all prebuilt plugins with different complexity from simple to advanced is provided to help you get started.

### Additional features

  - Automated build tool for developers
  - Sophisticated logging, tracing and debug support to track down any errors, when developing your own plugins
  - Fully graphical setup and configuration utilities
  
  ![](./Resources/DocumentationImages/Setup%20Tool.JPG) ![](./Resources/DocumentationImages/Configuration%20Tool.JPG)

### Included Plugins

These plugins are part of the Simulator Controller distribution. Beside providing functionality to the core, they can be used as templates for building your own plugins. They range from very simple functional additions with only a small number of lines of code up to very complex, multi-class behemoths controlling external software such as SimHub.

| Plugin | Description |
| ------ | ------ |
| System | Handles multiple button box pages and starting and stopping of all applications |
| Tactile Feedback | Support for pedal and chassis vibration using SimHub |
| Motion Feedback | Support for rig motion feedback using SimFeedback |
| ACC | Support for staring and stopping Assetto Corsa Competizione |
| AC | Support for staring and stopping Assetto Corsa |
| Button Box | Tools for building your own button box visuals |

### Third party applications

The following applications are not part of the distribution and are not strictly necessary to use Simulator Controller. But Simulator Controller is aware of these components and will use them, if available.

| Application | Description |
| ------ | ------ |
| [AutoHotkey](https://www.autohotkey.com/) | [Development Only] Object oriented scripting language. You need it, if you want to develop your own plugins |
| [NirCmd](https://www.nirsoft.net/utils/nircmd.html) | [Optional] Extended Windows command shell. Used by Simulator Controller to control ingame sound volume settings during startup. |
| [VoiceMacro](http://www.voicemacro.net/) | [Optional] Connects to your microphone and translates voice commands to complex keyboard and/or mouse input. These macros can be connected to Simulator Controller as external input to control functions and actions identical to your hardware controller. |
| [AITrack](https://github.com/AIRLegend/aitrack) | [Optional] Neat little tool which uses neural networks to detect your viewing angle on a dashcam video stream. Used in conjunction with opentrack to control your ingame viewing angle. |
| [opentrack](https://sourceforge.net/projects/opentrack.mirror/) | [Optional] Connects to your simulation game and controls the viewing angle using the freetrack protocol. Several input methods are supported, sich as analog joysticks or UDP based sources such as AITrack. |
| [SimHub](https://www.simhubdash.com/) | [Optional] Versatile, multipurpose software collection for simulation games. Generate vibration using bass shakers or vibration motors using a fully integrated Arduino development environment. Additional features support the definition of custom dashboards. |
| [SimFeedback](https://www.opensfx.com/) | [Optional] Not only a software, but a complete DIY project for building motion rigs. SimFeedback controls the motion actuators using visual control curves, which translate the ingame physics data to complex and very fast rig movements. |


### Documentation

Coming soon. In the meantime use all the given goodies, especially the very large sample configuration as a starting point.

### Installation

Download the complete package and unzip anywhere you like. Then run the setup tool available in the Binaries folder and configure your environment. AutoHotkey is not necessary if you are not building your own plugins, but you need an understanding of the Hotkey syntax to bind your controller hardware to the plugin functions and actions using the setup tool. 

### Development

Want to contribute? Great!

  - Build your own plugins and  offer them in GitHub. Contact me and I will add a link to your plugin in this documentation.

  - Found a bug, or even built a new feature. Even better. Please contact me, and I will give you access to the code repository.

### Todos

 - Add full documentation Wiki and a FAQ

### License

This software is provided as is. You are free to use for any purpose and modify it to your needs, but commercial use is strictly prohibited.

(2020) Creative Commons - BY-NC-SA - by Oliver Juwig (TheBigO)
