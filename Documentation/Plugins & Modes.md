The distribution of Simulator Controller includes a set of predefined plugins, which provide functionalities for (advanced) Simulation Rigs. Some of these plugins provide a sophisticated set of initialization parameters, which can be configured in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins) of the setup tool. Below you find an overview and introduction to each plugin and in the following chapters an in depth reference including a description for all initialization parameters.

| Plugin | Description |
| ------ | ------ |
| System | Handles multiple button box layers and manages all applications configured for your simulation setup. This plugin defines the "Launch" mode, where applications my be started and stopped from the controller hardware. These applications can be configured using the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). |
| Tactile Feedback | Fully configurable support for pedal and chassis vibration using [SimHub](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). Simulator Controller comes with a set of predefined SimHub profiles, which may help you to connect your vibration motors and chassis shakers. The plugin provides a lot of initialization parameters to adopt to these profiles. Two modes, "Pedal Vibration" and "Chassis Vibration", are defined, which let you control the different vibration effects and intensities directly from your controller. |
| Motion Feedback | Fully configurable support for rig motion feedback using [SimFeedback](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). The plugin supports two different methods to control SimFeedback. The first uses mouse automation, which is needed, if you don't have the commercial, so called expert license of *SimFeedback*. The other method programmatically connects to SimFeedback with the help of the [SFX-100-Streamdeck](https://github.com/ashupp/SFX-100-Streamdeck) extension. The mode "Motion", which is available for both methods, allows you to enable individal motion effects like "Roll" and "Pitch" and dial in their intensities. |
| ACC | Provides special support for starting and stopping *Assetto Corsa Competizione* from your hardware controller. The mode "Drive", which is only available, when "Assetto Corsa Competizione" is currently running, handle automated chat messages for the multiplayer ingame chat system, where the chat messages can be configured by the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). |
| AC | The smallest plugin in this list only supplies a special splash screem, when Assetto Corsa is started. No special controller mode is defined for the moment. |

All plugins can be configured in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins) of the setup tool.

## Plugin *System*

The "System" plugin is a required part of the core Simulator Controller framework and therefore cannot be deactivated or deleted in the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). This plugin handles all the applications during the [startup process](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--configuration) and provides a controller action to switch between the different modes on your hardware controller.

### Mode *Launch*

The "System" plugin creates the controller mode "Launch", which serves as a launchpad for all your important applications, and sets this mode as the currently active mode, when the Simulator Controller starts up. All the applications available on this launchpad can be configured in the [Launchpad tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-launchpad) of the setup tool. If there are less applications configured for the launch pad than buttons are available on your controller hardware, the last button will be bound to a special action, which will let you shutdown your PC. Here is a picture of a button box with the "Launch" mode currently active:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Button%20Box%201.JPG)

### Configuration

The "System" plugin accepts one configuration argument in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins) of the setup tool, which you almost always will provide:

	modeSelector: *functionType*.*number*
	
The *modeSelector* parameter allows you to define a controller function to switch between modes. You can use binary functions, such as 2-way toggle switches or dials, for switching forward and backward, but a simple push button can also be used. Example: "modeSelector: 2WayToggle.1"

## Plugin *Tactile Feedback*

This plugin integrates with [SimHub](https://www.simhubdash.com/) to give you excellent control over your vibration effects. It can handle pedal vibration effects as well as chassis vibration separated between the front and the rear part of your simulation rig.

Note: The plugin "Tactile Feedback" will only install, if a similar named application has been configured in the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-applications) of the setup tool. This application must point to an installation of *SimHub* on your PC.

The "Tactile Feedback" plugin will allow you to enable or disable pedal vibration, front chassis vibration or rear chassis vibration independently from your controller. And two modes, "Pedal Vibration" und "Chassis Vibration", will allow you to control all the effects in detail. All these functions will only be available when *SimHub* is running, but *SimHub* will be started automatically, when one of the effect groups will be enabled from your controller.

To get the most out of this plugin in the sample configuration presented below, you will need three 2-way toggle switches, two rotary dials and eight push buttons on your controller hardware, although the dials and push buttons may be shared with other modes. But, since all this is fully configurable, you can find a compromise, if your controller provides less control elements. To help you with the configuration of *SimHub*, two shaker profiles are provided in the *Profiles* folder in the Simulator Controller distribution. Please load these profiles, named "...CV..." for chassis vibration and "...PV..." for pedal vibration, and adopt them to the specific configuration of your simulation rig. Using the plugin parameters described below, you can then customize the "Tactile Feedback" plugin to support your concrete hardware setup as best as possible.

### Mode *Pedal Vibration*

This mode, which is only available, when *SimHub* is runnning, will let control the pedal vibration effects. In the default configuration, engaged traction control will vibrate the accelerator pedal and the brake pedal will vibrate, when ABS kicks in. But this is completely controlled by the configuration and by the profiles you have set up in *SimHub*. This configuration may look like this:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Button%20Box%203.JPG)

You can increase or decrease the "TC" and "ABS" intensity using the buttons and control the overall vibration intensity using the dial knob. But it may have been configured completely differently. This concrete configuration is the result of the following plugin arguments, which will be described later:

	pedalEffects: TC Button.1 Button.5, ABS Button.2 Button.6; pedalVibration: On 2WayToggle.3 Dial.1;
  
### Mode *Chassis Vibration*

The second mode, which is quite similar to the mode "Pedaö Vibration" lets you control all the chassis vibration effects. Here are four effects part of the sample configuuration, "RPMS", "GearShift", "WheelsLock" and "WheelsSlip". All these effect may be distributed to the front and the rear with different intensities and effect causes (for example "WheelsSlip" can differntiate between over- and understeer slip amount) according to the profile used in *SimHub*.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Button%20Box%204.JPG)

You will achieve this controller setup with the following plugin arguments:

	chassisEffects: RPMS Button.1 Button.5, GearShift Button.2 Button.6, WheelsLock Button.3 Button.7, WheelsSlip Button.4 Button.8;
	frontChassisVibration: On 2WayToggle.4 Dial.1; rearChassisVibration: On 2WayToggle.5 Dial.2

### Configuration

"Tactile Feedback" is quite flexible and therefore provide many plugin parameters. All the arguments for these parameters must be supplied in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins) of the setup tool.

	pedalVibration: *initialState* *onOffFunction* *intensityFunction*;
	frontChassisVibration: *initialState* *onOffFunction* *intensityFunction*;
	rearChassisVibration: *initialState* *onOffFunction* *intensityFunction*;
	
These three parameters follow the same format and let you control the respective group of vibration effects.
*initialState* must be either "On" or "Off". Unfortunately, there is no way to query *SimHub* to request the current state of a toggleable effect, so this can get out of sync, if you left it in the other state the last time you used your rig.
*onOffFunction* will define a controller function to switch the respective vibration effect group on or off. Both, unary and binary functions are supported. This function is connected to the plugin itself and is therefore always available. For all this to function correctly, you must define a trigger in *SimHub* at the respective effect group, which must be named "toggle[*effect*]Vibration", where *effect* is either "Pedal", "FrontChassis" or "RearChassis".
Last, *intensityFunction*, which is part of the respective mode, will let you control the overall intensity of the effect group. You may have to supply a descriptor for binary function here, unless you only want to increase the intensity all the time. Example: "pedalVibration: On 2WayToggle.3 Dial.1"

In the next step, you need to describe all individual effects for your vibration settings:

	pedalEffects: *effect1* *increaseFunction1* [*decreaseFunction1*], *effect2* *increaseFunction2* [*decreaseFunction2*], ...; 
	chassisEffects: *effect1* *increaseFunction1* [*decreaseFunction1*], *effect2* *increaseFunction2* [*decreaseFunction2*], ...;
	
With this parameters, you define the effects that are part of the "Pedal Vibration" or "Chassis Vibration" mode. *effectX* is the name of the effect, for example "TC". This name must be identical to that used, when defining the external trigger in *SimHub* according to the pattern "increase[*effect*]Vibration" or "decrease[*effect*]Vibration". For the function bindings, you can use one binary functions, i.e. a rotary dial, for a given effect, or two unary functions, like a push button. Also here, if you only supply one unary function, you may only increase the effect intensity. Example: "chassisEffects: RPMS Dial.2, GearShift Button.2 Button.6"

Note: To supply the labels, that will be displayed for all these effects and triggers on the visual representation of your controller hardware, use the *Labels Editor*, which is available at the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins) of the setup tool.

## Plugin *Motion Feedback*

The "Motion Feedback" plugin is as flexible as the "Tactile Feedback" plugin. It uses [SimFeedback](https://www.opensfx.com/) to control the motion actuators of your simulation rig. *SimFeedback* which is the software part of a community project for building motion rigs, comes in two flavours, a free edition and a so called expert edition, that needs some sort of commercial license. Only the expert edition supports extensions, which allow you to connect to *SimFeedback* using APIs and control the state of all motion effects and intensities. For the free edition, the plugin "Motion Feedback" tries to control *SimFeedback" using mouse automation, a functionality provvided by AutoHotkey, but there are limitations. Therefore, I strongly recommend to invest in an expert license and install the [SFX-100-Streamdeck](https://github.com/ashupp/SFX-100-Streamdeck) extension and the corresponding console application used to connect to this API.

Obviously, this plugin needs *SimFeedback* to be installed on your PC and an application named "Motion Feedback", that points to this *SimFeedback* installation must be configured in the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-applications) of the setup tool. Otherwise, the "Motion Feedback" plugin won't install. Please define "startSimFeedback" for the *Startup* function hook, which is especially necessray, if your using mouse automation to control *SimFeedback*.
When using the API connection, you must install and activate the above extension in *SimFeedback* and the console application as as a connector. The path to the connector may be supplied using a plugin argument, which is described below. 

To get the most out of this plugin in the sample configuration presented below, you will need one 2-way toggle switches, two rotary dials and eight push buttons on your controller hardware, although the dials and push buttons may be shared with other modes. But, since all this is fully configurable, you can find a compromise, if your controller provides less control elements. To help you with the configuration of *SimFeedback*, a profile for ACC is provided in the *Profiles* folder in the Simulator Controller distribution. Please load this profile and adopt it to the specific configuration of your simulation rig. Using the plugin parameters described below, you can then customize the "Motion Feedback" plugin to support your concrete hardware setup as best as possible.

To globally start or stop the motion actuators of your rig, a plugin action must be bound to a controller function. You can it with a plugin argument:

	motion: Off 2WayToggle.2 Dial.1 30;

The details of this argument will be described below, but as you can see, the initial state for *Motion* is "Off" and this state is controlled by the 2-way toggle switch # 2.

### Mode *Motion*

The plugin defines a single mode to control all motion effects of your simulation rig. This mode is only available, when the motion actuators have been activated. You can enable or disable individual effects and control their intensities. Since there might be quite a lot of individual effects, many more than possibly available dial knobs on your controller this mode provides a selector, with which you can choose an effect to be controlled by the one and only dial.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Documentation/Images/Button%20Box%205.JPG)

Using the buttons, you can enable or disable the individual effects, but if you press the effect selector button, before pressing one of the effect buttons, you will chose this effect to be controlled by the dial in the lower right corner of the controller. All this will be achieved using the following plugin argument:

	motionEffectIntensity: Button.8 Dial.2;
	motionEffects: Heave On 1.0 Button.1, Surge On 1.0 Button.2, Surge_2 On 1.0 Button.3, Sway On 1.0 Button.4,
				   Pitch On 1.0 Button.5, Roll On 0.5 Button.6, Traction_Loss Off 1.2 Button.7

As you can see, the effect selector is configured as they button # 8 and will use dial # 2 to control the selected effect.

### Configuration

All the arguments for the plugin parameters of the "Motion Feedback" plugin must be supplied in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins) of the setup tool. For the plugin itself the following arguments are relvant:

	connector: *path to sfx-100-console-application*;
	motion: *initialState* *onOffFunction* *intensityFunction* *initialIntensity*;

The *connector* parameter may be used, when *SimFeedack* is running in expert mode and you have installed the extensions above. The path must be set to the location of the console executable, as in "D:\Programme\SimFeedback Connector\sfx-100-streamdeck-console.exe". For *motion*, you supply the *initialState* as one of "On" or "Off". 
*onOffFunction* will define a controller function to start or stop the motion actuator motors. Both, unary and binary functions are supported. This function is connected to the plugin itself and is therefore always available. With *intensityFunction*, you supply a function to control the overall motion intensity starting with *initialIntensity*. You may have to supply a descriptor for binary function here, unless you only want to increase the intensity all the time. Example: "motion: Off 2WayToggle.2 Dial.1 30"

Warning: *initialState* and *initialIntensity* will only be used, when using mouse automation to control *SimFeedback*. It is absolutely cruicial, that these settings correspnd with the current settings in *SimFeedback*, when it starts. Otherwise, you will get unpredictable results, since the emulated mouse clicks may be going wild. When using the connector, the initial values will be ignored and the current state will be requested from *SimFeedback* instead.

With the following parameters you can configure the available effects for the "Motion" mode:

	motionEffectIntensity: *effectSelectorFunction* *effectIntensityFunction*;
	motionEffects: *effect1* *initialState1* *intialIntensity1* *effectToggleFunction1*,
				   *effect2* *initialState2* *intialIntensity2* *effectToggleFunction2*, ...;

With this parameters, you define the effects that are part of the "Motion" mode. *effectX* is the name of the effect, for example "Heave". With *initialStateX* and *intialIntensityX* you supply "On" or "Off" and a value between 0.0 and 2.0 respectively. These values will only be used, when mouse automation is used to control *SimFeedback*. Last, you need to supply a controller function with *effectToggleFunctionX* to enable or disable the effect or choose it for intensity manipulation using the effect selector. Example: "Heave On 1.0 Button.1"

Important: Please be aware, that any spaces in effect names must be substituted with an underscore, since spaces are allowed in *SimFeedback* effect names, but not in the plugin arguments. The underscores will be replaced by spaces again, before beeing transmitted to *SimFeedback*.

## Plugin *ACC*

This plugin handles the *Assetto Corsa Competizione* simulation game. It defines the mode "Drive", which binds all the configured chat messages to buttons on your controller hardware. This plugin needs an application with the name "Assetto Corsa Competizione" to be configured in the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). Please set "startACC", "stopACC" and "isACCRunning" as special function hooks in this configuration.

## Plugin *AC*

This plugin handles the *Assetto Corsa* simulation game. An application with the name "Assetto Corsa" needs to be configured in the [setup tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup). Please set "startAC" as a special function hook in this configuration.