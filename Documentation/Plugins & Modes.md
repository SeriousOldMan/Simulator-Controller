The distribution of Simulator Controller includes a set of predefined plugins, which provide functionalities for (advanced) Simulation Rigs. Some of these plugins provide a sophisticated set of initialization parameters, which can be configured in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins) of the setup tool. Below you find an overview and introduction to each plugin and in the following chapters an in depth reference including a description for all initialization parameters.

| Plugin | Description |
| ------ | ------ |
| System | Handles multiple button box layers and manages all applications configured for your simulation setup. This plugin defines the "Launch" mode, where applications my be started and stopped from the controller hardware. These applications can be configured using the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). |
| Tactile Feedback | Fully configurable support for pedal and chassis vibration using [SimHub](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). Simulator Controller comes with a set of predefined SimHub profiles, which may help you to connect your vibration motors and chassis shakers. The plugin provides a lot of initialization parameters to adopt to these profiles. Two modes, "Pedal Vibration" and "Chassis Vibration", are defined, which let you control the different vibration effects and intensities directly from your controller. |
| Motion Feedback | Fully configurable support for rig motion feedback using [SimFeedback](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). The plugin supports two different methods to control SimFeedback. The first uses screen automation, which is needed, if you don't have the commercial, so called expert license of *SimFeedback*. The other method programmatically connects to SimFeedback with the help of the [SFX-100-Streamdeck](https://github.com/ashupp/SFX-100-Streamdeck) extension. The mode "Motion", which is available for both methods, allows you to enable individal motion effects like "Roll" and "Pitch" and dial in their intensities. |
| ACC | Provides special support for starting and stopping Assetto Corsa Competizione from your hardware controller. The mode "Drive", which is only available, when "Assetto Corsa Competizione" is currently running, handle automated chat messages for the multiplayer ingame chat system, where the chat messages can be configured by the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). |
| AC | The smallest plugin in this list only supplies a special splash screem, when Assetto Corsa is started. No special controller mode is defined for the moment. |

All plugins can be configured in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins) of the setup tool.

### Plugin *Systen*

### Plugin *Tactile Feedback*

### Plugin *Motion Feedback*