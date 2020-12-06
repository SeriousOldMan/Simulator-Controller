# Simulator Controller


Simulator Controller is a modular and extandable adminstration and controller application for complex Sim Racing Rigs. At the core is a comprehensive plugin capable automation framework, which can use almost any external controller hardware, such as button boxes, to control typical simulator components such as SimHub, SimFeedback and alike. But there are a lot more functionality and features available to make the life of all of us virtual racers even more fun and simple.

### Main features

  - Connect all your external controller, like button boxes, to one single center of control
  - Configurable, visual feedback for your controller actions
    - Define your own button box layout ([Resources/DocumentationImages/Button Box 1.jpg], [Resources/DocumentationImages/Button Box 2.jpg]) and integrate it with the Simulator Controller using the simple plugin support
    - Code your own functions to be called by the controller buttons and switches using the simple, object-oriented scripting language
  - Configure all additional applications to your taste, including the games used for your virtual races
    - Add splash screens and title melodies
    - Start and stop the applications from your controller hardware or automatically upon configurable events
    - Fully support for application automation - for example, start your favorite voice chat software like TeamSpeak and automatically switch to your standard channel 
  - Several plugins supplied out of the box:
    - Support for Assetto Corsa and Assetto Corsa Competizione already builtin
    - Fully customizable plugins supplied for total control of SimHub and SimFeedback - change your settings while racing using the dials and switches on your favorite button box
    - Send your predefined kudos and rants to the ingame chat without touching the keyboard
  - Additional support to trigger every function and action from external sources like a voice or gesture recognition software to always keep your hands on the wheel

Simulator Controller is fully implemented in AutoHotkey, a very sophisticated and object-oriented Windows automation scripting language, which is capable to control keyboard and other input devices with a simple macro language. On the other hand, AutoHotkey also has a lot of robotics capabilities to automate software packages, which do not provide an external APIs by simulating mouse clicks and keyboard input. You can write your own plugins using the AutoHotkey language. Full source code for all prebuilt plugins with different complexity from simple to advanced is provided to help you get started.

### Additional features

  - Automated build tool for developers
  - Sophisticated logging, tracing and debug support to track down any errors, when developing your own plugins
  - Fully graphical setup and configuration utilities ([Resources/DocumentationImages/Setup Tool.jpg], [Resources/DocumentationImages/Configuration Tool.jpg])

### Documentation

Coming soon. In the meantime use all the given goodies, especially the very large sample configuration as a staring point.

### Included Plugins


| Plugin | Description |
| ------ | ------ |
| System | Handles multiple button box pages and starting and stopping of all applications |
| Tactile Feedback | Support for pedal and chassis vibration using SimHub |
| Motion Feedback | Support for rig motion feedback using SimFeedback |
| ACC | Support for staring and stopping Assetto Corsa Competizione |
| AC | Support for staring and stopping Assetto Corsa |
| Button Box | Tools for building your own button box visuals |

### Installation

Download the complete package, the run the setup utility and configure your environment. AutoHotkey is not necessary, if you are not building your own plugins, but you need an understanding of the Hotkey syntax to bind your controller hardware to the plugin functions and actions using the setup tool. 

### Development

Want to contribute? Great!

  - Build your own plugins and  offer them in GitHub. Contact me and I will add a link to your plugin in this documentation.

  - Found a bug, or even built a new feature. Even better. Please contact me, and I will give you access to the code repository.



### Todos

 - Add full documentation Wiki

License
----

(2020) Creative Commons - BY-NC-SA - by Oliver Juwig (TheBigO)


**Free Software, Hell Yeah!**
