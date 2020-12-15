The distribution of Simulator Controller includes a set of predefined plugins, which provide functionalities for (advanced) Simulation Rigs. Some of these plugins provide a sophisticated set of initialization parameters, which can be configured in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins) of the setup tool. Below you find an overview and introduction to each plugin and in the following chapters an in depth reference including a description for all initialization parameters.

| Plugin | Description |
| ------ | ------ |
| System | Handles multiple button box layers and manages all applications configured for your simulation setup. This plugin defines the "Launch" mode, where applications my be started and stopped from the controller hardware. These applications can be configured using the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). |
| Tactile Feedback | Fully configurable support for pedal and chassis vibration using [SimHub](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). Simulator Controller comes with a set of predefined SimHub profiles, which may help you to connect your vibration motors and chassis shakers. The plugin provides a lot of initialization parameters to adopt to these profiles. Two modes, "Pedal Vibration" and "Chassis Vibration", are defined, which let you control the different vibration effects and intensities directly from your controller. |
| Motion Feedback | Fully configurable support for rig motion feedback using [SimFeedback](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). The plugin supports two different methods to control SimFeedback. The first uses screen automation, which is needed, if you don't have the commercial, so called expert license of *SimFeedback*. The other method programmatically connects to SimFeedback with the help of the [SFX-100-Streamdeck](https://github.com/ashupp/SFX-100-Streamdeck) extension. The mode "Motion", which is available for both methods, allows you to enable individal motion effects like "Roll" and "Pitch" and dial in their intensities. |
| ACC | Provides special support for starting and stopping *Assetto Corsa Competizione* from your hardware controller. The mode "Drive", which is only available, when "Assetto Corsa Competizione" is currently running, handle automated chat messages for the multiplayer ingame chat system, where the chat messages can be configured by the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). |
| AC | The smallest plugin in this list only supplies a special splash screem, when Assetto Corsa is started. No special controller mode is defined for the moment. |

All plugins can be configured in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins) of the setup tool.

### Plugin *System*

The "System" plugin is a required part of the core Simulator Controller framework and therefore cannot be deactivated or deleted in the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). This plugin handles all the applications during the startup process (*) and provides a controller action to switch between the different modes on your hardware controller.

#### Mode *Launch*

The "System" plugin creates the controller mode "Launch", which serves as a launchpad for all your important applications, and sets this mode as the currently active mode, when the Simulator Controller starts up. All the applications available on this launchpad can be configured in the [Launchpad tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-launchpad) of the setup tool. If there are less applications configured for the launch pad than buttons are available on your controller hardware, the last button will be bound to a special action, which will let you shutdown your PC. Here is a picture of a button box with the "Launch" mode currently active:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Button%20Box%201.JPG)

#### Configuration

The "System" plugin accepts one configuration argument in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins) of the setup tool, which you almost always will provide:

	modeSelector: *functionType*.*number*
	
The *modeSelector* parameter allows you to define a controller function to switch between modes. You can use binary functions, such as 2-way toggle switches or dials, for switching forward and backward, but a simple push button can also be used. Example: "modeSelector: 2WayToggle.1"

### Plugin *Tactile Feedback*

This plugin integrates with [SimHub](https://www.simhubdash.com/) to give you excellent control over your vibration effects. It can handle pedal vibration effects as well as chassis vibration separated between the front and the rear part of your simulation rig.

Note: The plugin "Tactile Feedback" will only install, if a similar named application has been configured in the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-applications) of the setup tool. This application must point to an installation of *SimHub* on your PC.

The "Tactile Feedback" plugin will allow you to enable or disable pedal vibration, front chassis vibration or rear chassis vibration independently from your controller. And two modes, "Pedal Vibration" und "Chassis Vibration", will allow you to control all the effects in detail. All these functions will only be available when *SimHub* is running, but *SimHub* will be started automatically, when one of the effect groups will be enabled from your controller.

To get the most out of this plugin, you will need three 2-way toggle switches, two rotary dials and eight push buttons on your controller hardware, although the dials and push buttons may be shared with other modes. But, since all this is fully configurable, you can find a compromise, if your controller provides less control elements. To help you with the configuration of *SimHub*, two shaker profiles are provided in the *Profiles* folder in the Simulator Controller distribution. Please load these profiles, named "...CV..." for chassis vibration and "...PV..." for pedal vibration, and adopt them to your specific configuration of your simulation rig. Using the plugin parameters described below, you can then customize the "Tactile Feedback" plugin to support your concrete hardware setup as best as possible.

#### Mode *Pedal Vibration*

This mode, which is only available, when *SimHub* is runnning, will let control the pedal vibration effects. In the default configuration, engaged traction control will vibrate the accelerator pedal and the brake pedal will vibrate, when ABS kicks in. But this is completely controlled by the configuration and by the profiles you have set up in *SimHub*. This configuration may look like this:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Button%20Box%203.JPG)

You can increase or decrease the "TC" and "ABS" intensity using the buttons and control the overall vibration intensity using the dial knob. But it may have been configured completely differently. This concrete configuration is the result of the following plugin arguments, which will be described later:

  pedalEffects: TC Button.1 Button.5, ABS Button.2 Button.6; pedalVibration: On 2WayToggle.3 Dial.1;
  
#### Mode *Chassis Vibration

The second mode, which is quite similar to the mode "Pedaö Vibration" lets you control all the chassis vibration effects. Here are four effects part of the sample configuuration, "RPMS", "GearShift", "WheelsLock" and "WheelsSlip". All these effect may be distributed to the front and the rear with different intensities and effect causes (for example "WheelsSlip" can differntiate between over- and understeer slip amount) according to the profile used in *SimHub*.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Button%20Box%204.JPG)

  chassisEffects: RPMS Button.1 Button.5, GearShift Button.2 Button.6, WheelsLock Button.3 Button.7, WheelsSlip Button.4 Button.8;
  frontChassisVibration: On 2WayToggle.4 Dial.1; rearChassisVibration: On 2WayToggle.5 Dial.2

### Plugin *Motion Feedback*

### Plugin *ACC*

This plugin handles the *Assetto Corsa Competizione* simulation game. It defines the mode "Drive", which binds all the configured chat messages to buttons on your controller hardware. This plugin needs an application with the name "Assetto Corsa Competizione" to be configured in the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). Please set "startACC", "stopACC" and "isACCRunning" as special function hooks in this configuration.

### Plugin *AC*

This plugin handles the *Assetto Corsa* simulation game. An application with the name "Assetto Corsa" needs to be configured in the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). Please set "startAC" as a special function hook in this configuration.