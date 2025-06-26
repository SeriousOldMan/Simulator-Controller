The distribution of Simulator Controller includes a set of predefined plugins, which provide functionalities for (advanced) Simulation Rigs. Some of these plugins provide a sophisticated set of initialization parameters, which can be configured in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool. Below you find an overview and introduction to each plugin and in the following chapters an in depth reference including a description for all initialization parameters.

| Plugin | Description |
| ------ | ------ |
| [System](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-system) | Handles multiple layers, the so called Modes on you hardware controllers, and manages all applications configured for your simulation configuration. This plugin defines the "Launch" mode, where applications my be started and stopped from the controller hardware. These applications can be configured using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Beside that, you can define your own custom modes using some scripting magic. |
| [Button Box](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts) | Tools for building your own Button Box / Controller visuals. The default implementation of *ButtonBox* implements grid based Button Box layouts, which can be configured using a [graphical layout editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts). |
| [Stream Deck](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#stream-deck-layouts) | Tools for connecting one or more Stream Decks as external controller to Simulator Controller. A special Stream Deck plugin is provided, which is able to dynamically display information both as text and/or icon on your Stream Deck. |
| [Tactile Feedback](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-tactile-feedback) | Fully configurable support for pedal and chassis vibration using [SimHub](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). Simulator Controller comes with a set of predefined SimHub profiles, which may help you to connect and manage your vibration motors and chassis shakers. The plugin provides many initialization parameters to adopt to these profiles. Two modes, "Pedal Vibration" and "Chassis Vibration", are defined, which let you control the different vibration effects and intensities directly from your controller. |
| [Motion Feedback](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-motion-feedback) | Fully configurable support for rig motion feedback using [SimFeedback](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). The plugin supports two different methods to control SimFeedback. The first uses mouse automation, which is needed, if you don't have the commercial, so called expert license of *SimFeedback*. The second method programmatically connects to SimFeedback with the help of the [SFX-100-Streamdeck](https://github.com/ashupp/SFX-100-Streamdeck) extension. The mode "Motion", which is available for both methods, allows you to enable individal motion effects like "Roll" and "Pitch" and dial in their intensities. |
| [Pedal Calibration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-pedal-calibration) | Allows to choose between the different calibration curves of your high end pedals directly from the hardware controller. The current implementation supports the Heusinkveld *SmartControl* application, but adopting the plugin to a different pedal vendor is quite easy. |
| [Driving Coach](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-driving-coach) | This plugin integrates Aiden, the AI Driving Coach. If this plugin is active and correctly configured, this Assistant will be automatically available, when Simulator Controller is running. |
| [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) | This plugin integrates Jona, the AI Race Engineer, with all other plugins for the simulation games, like the ACC plugin. The plugin handles the data transfer between the simulation game and the AI Race Engineer. |
| [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) | This plugin integrates Cato, the AI Race Strategist, with all other plugins for the simulation games, like the ACC plugin. The plugin handles the data transfer between the simulation game and the AI Race Strategist. |
| [Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-spotter) | This plugin integrates Elisa, the AI Race Spotter, with all other plugins for the simulation games, like the ACC plugin. The plugin handles the data transfer between the simulation game and the AI Race Spotter. |
| [Team Server](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server) | The *Team Server* supports using the AI Race Assistants even in a multiplayer team race. It is based on a serverside solution, which manages the state of the car and Assistants knowledge and passes them between the participating drivers. |
| [ACC](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) | Provides special support for starting and stopping *Assetto Corsa Competizione* from your hardware controller. The mode "Chat", which is available when *Assetto Corsa Competizione* is currently running, handle automated chat messages for the multiplayer ingame chat system, where the chat messages can be configured by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Additionally, beginning with Release 2.0, this plugin provides sophisticated support for the Pitstop MFD of *Assetto Corsa Competizione*. All settings may be tweaked with the controller hardware using the "Pitstop" mode, but it is also possible to control the settings using voice control to keep your hands on the steering wheel. An integration with Jona, the AI Race Engineer, with Cato, the AI Race Strategist and also with Elisa, the AI Race Spotter is available. The Driving Coach Aiden also is integrated with *Assetto Corsa Competizione*. The "Assistant" mode can handle most of the Race Assistant commands from your hardware controller. |
| [AC](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-ac) | Integration for *Assetto Corsa*, which supports  Jona, the AI Race Engineer, Cato, the AI Race Strategist and also Elisa, the AI Race Spotter. The Driving Coach Aiden also is integrated with *Assetto Corsa*. The plugin also supports a "Pitstop" mode for adjusting pitstop settings and a "Assistant" mode to interact with the Race Assistants. |
| ACE | Simple integration for Assetto Corsa EVO. No functionality beside starting and stopping from a hardware controller. |
| [AMS2](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-AMS2) | Integration for *Automobilista 2*, which supports  Jona, the AI Race Engineer, Cato, the AI Race Strategist and also Elisa, the AI Race Spotter. The Driving Coach Aiden also is integrated with *Automobilista 2*. The plugin also supports a "Pitstop" mode for adjusting pitstop settings and a "Assistant" mode to interact with the Race Assistants. |
| [IRC](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-irc) | This plugin integrates the *iRacing* simulation game with Simulator Controller. A "Pitstop" mode is available to control the pitstop settings from your controller hardware and an integration with Jona, the AI Race Engineer, with Cato, the AI Race Strategist and also with Elisa, the AI Race Spotter is available as well. The Driving Coach Aiden also is integrated with *iRacing*. The "Assistant" mode can handle most of the Race Assistant commands from your hardware controller. |
| [RF2](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-rf2) | Similar to the ACC and IRC plugin provides this plugin start and stop support for *rFactor 2*. The mode "Chat", which is available when *rFactor 2* is currently running, handle automated chat messages for the multiplayer ingame chat system, where the chat messages can be configured by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). A "Pitstop" mode is available to control the pitstop settings from your controller hardware and an integration with Jona, the AI Race Engineer, and with Cato, the AI Race Strategist is available as well. The Race Spotter Elisa and the Driving Coach are also integrated with *rFactor 2*. The "Assistant" mode can handle most of the Race Assistant commands from your hardware controller and the "Chat" mode lets you send predefined messages to your opponents using a button press on your controller similar to the functionality in the plugin "ACC". |
| [R3E](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-rre) | Similar to the ACC, IRC and RF2 plugins provides this plugin start and stop support for *RaceRoom Racing Experience*. A "Pitstop" mode is available to control the pitstop settings from your controller hardware and an integration with Jona, the AI Race Engineer, with Cato, the AI Race Strategist and also with Elisa, the AI Race Spotter is available as well. The Driving Coach Aiden also is integrated with *RaceRoom Racing Experience*. The "Assistant" mode can handle most of the Race Assistant commands from your hardware controller. |
| RSP | Simple integration for Rennsport. No functionality beside starting and stopping from a hardware controller. |
| [PCARS2](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-PCARS2) | Integration for *Project CARS 2*, which supports  Jona, the AI Race Engineer, Cato, the AI Race Strategist and also Elisa, the AI Race Spotter. The Driving Coach Aiden also is integrated with *Project CARS 2*. The plugin also supports a "Pitstop" mode for adjusting pitstop settings and a "Assistant" mode to interact with the Race Assistants. |
| [LMU](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-lmu) | Full support for *Le Mans Ultimate* incl. integration of the Race Assistants and the Driving Coach. Functionality is almost identical to that of the plugin for *rFactor 2*, since *Le Mans Ultimate* is based on the same engine. |
| [Integration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-integration) | This plugin implements interoperability with other applications like SimHub. |

All plugins can be configured in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool.

## Plugin *System*

The "System" plugin is a required part of the core Simulator Controller framework and therefore cannot be deactivated or deleted in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). This plugin handles all the applications during the [startup process](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--configuration) and provides a controller action to switch between the different modes using your hardware controller.

### Mode *Launch*

The "System" plugin creates the controller mode "Launch", which serves as a launchpad for all your important applications, and sets this mode as the currently active mode, when the Simulator Controller starts up. All the applications available on this launchpad can be configured in the [Launchpad tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-launchpad) of the configuration tool. If there are less applications configured for the launch pad than buttons are available on your controller hardware, the last button will be bound to a special action, which will let you shutdown your PC. Here is a picture of a Button Box with the "Launch" mode currently active:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%201.JPG)

As an alternative, you can use the *launchApplications* parameter to specify the applications for the "Launch" mode:

	launchApplications: ACC "Assetto Corsa Competizione" Button.1, FanaLab Fanalab Button.2, TS TeamSpeak Button.3

### Configuration

The "System" plugin accepts one configuration argument in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool, which you almost always will provide:

	modeSelector: *modeSelectorFunction1* *modeSelectorFunction2* ...;
	launchApplications: *label* *application* *launchFunction1*, ...;
	shutdown: *shutdownFunction*
	
The *modeSelector* parameter allows you to define controller functions that switch between modes on your Button Boxes. The *modeSelectorFunctionX* must be in the descriptor format, i.e. *"functionType*.*number*". You can use binary functions, such as 2-way toggle switches or dials, to switch forward and backward between modes, but a simple push button can also be used. Example: "modeSelector: 2WayToggle.1". If you have multiple Button Boxes, you may want to create a mode selector for each one, especially, if you have defined modes, whose actions are exclusive for one of those Button Boxes. Doing this, you can have mutiple modes active on the same time on your Button Boxes and you can switch between those modes on each of those Button Boxes separately. An example: You may bind all action for controlling the ["Motion" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-motion) to one Button Box and all actions for the ["Pitstop" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop-1) to a different Button Box. In this configuration, both modes can be active at the same time.

The parameter *launchApplications* allows you to specify a list of applications that you want to start and stop from your Button Box. *label* will be used as the display name and *application* must reference the application as defined in the [applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications). If the application name or the label contain spaces, you must enclose them in double quotes. With the *shutdown* parameter, a unary function can be supplied to shutdown the complete simulator system. This function will be available in the "Launch" mode.

#### Configuration of custom modes

Beside using all the predefined modes of the various plugins, you can define your own modes using custom functions. First you have to define your own functions using the builtin [controller action functions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions). You do this by creating a custom function like this:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%204.JPG)

Please consult the [documentation for controller configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller) for more information. Please note that when using "Simulator Setup", it is also possible to include custom functions and create custom modes using a configuration patch as described [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#patching-the-configuration).

Hint: You can leave the trigger "Hotkey(s)" empty, if you want to use this action function only in a custom mode, since the trigger is defined for this purpose as shown below.

Once you have created all your custom action functions, you can define one or more custom modes using:

	customCommands: [*mode1* -> *label*] *modeFunction1* *customFunction1*, ... | [*mode2* ->] ...;

*mode* is the name or label of the mode. After the "->" you can define a comma-separated list of bindings for your controller. *modeFunction* stands for a control on your hardware, like Button.7, whereas *customFunction* (like Custom.7) is one of the custom functions you defined as described above. This command will be shown using the *label* and will always be activated as long as the given mode is selected. When you omit the *mode* and the "->" as indicated above with the square brackets, the actions will be bound to the plugin itsself, thereby being available all the time. 

##### Example

We want to define a mode where it is possibe to switch between different [track automations](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter#track-automations). First you have to define a couple of custom functions like this:

	Custom.18.Call.Action=selectTrackAutomation(Wet)
	Custom.19.Call.Action=selectTrackAutomation(Dry)

You can do this either in the "Controller" tab of "Simulator Configuration" or, as mentioned,  by using the configuration patch file when using "Simulator Setup". Then add the *customCommands* argument to the parameters of the "System Plugin":

	customCommands: Automation -> Dry Button.1 Custom.19, Wet Button.2 Custom.18

When using "Simulator Setup", add this to the patch file:

	[Add: Plugins]
	System=; customCommands: Automation -> Dry Button.1 Custom.19, Wet Button.2 Custom.18

Voilà...

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2015.JPG)

## Plugin *Tactile Feedback*

This plugin integrates with [SimHub](https://www.simhubdash.com/) to give you excellent control over your vibration effects. It can handle pedal vibration effects as well as chassis vibration separated between the front and the rear part of your simulation rig.

Note: The plugin "Tactile Feedback" will only be installed and activated, if a similar named application has been configured in the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications) of the configuration tool. This application must point to an installation of *SimHub* on your PC. As an alternative, you can provide the name of the application configuration with the *controlApplication* plugin argument.

The "Tactile Feedback" plugin will allow you to enable or disable pedal vibration, front chassis vibration or rear chassis vibration independently from your controller. And two modes, "Pedal Vibration" und "Chassis Vibration", will allow you to control all the underlying separate effects in detail. All these will only be available when *SimHub* is running, but *SimHub* will be started automatically, when one of the effect groups will be enabled from your controller.

To get the most out of this plugin in the sample configuration presented below, you will need three 2-way toggle switches, two rotary dials and eight push buttons on your controller hardware, although the dials and push buttons may be shared with other modes. But, since all this is fully configurable, you can find a compromise, if your controller provides less control elements. To help you with the configuration of *SimHub*, two shaker profiles are provided in the *Profiles* folder in the Simulator Controller distribution. Please load these profiles, named "...CV..." for chassis vibration and "...PV..." for pedal vibration, and adopt them to the specific configuration of your simulation rig. Using the plugin parameters described below, you can then customize the "Tactile Feedback" plugin to support your concrete hardware configuration as best as possible. These profiles already have been preconfigured with external triggers (for example: "togglePedalVibration" or "increaseRPMSVibration", just to name two), which will be used by the "Tactile Feedback" plugin to interact with *SimHub*.

If you want to create your SimHub profiles from scratch, you can create the external trigger in SimHub using the command shell. Start SimHub and open the controls window for the specific element. The following window will appear:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/SimHub%20Control.JPG)

Click the desired input, then open a command shell, go to the SimHub programm directory and execute the following command:

	SimHubWPF.exe -triggerinput [command][CATEGORY][EFFECT]Vibration

[command] must be one of "toggle", "increase" or "decrease", [CATEGORY] must be either "Pedal", "FrontChassis" or "RearChassis" and [EFFECT] the name of the effect you want to control, for example "WheelSlip". You can name the effects as you like, but the names here and in the configuration below must match. You can also leave the [Effect] empty to control the overall category.

### Mode *Pedal Vibration*

This mode, which is only available, when *SimHub* is runnning, will let you control the pedal vibration effects. In the default configuration, engaged traction control will vibrate the accelerator pedal and the brake pedal will vibrate, when ABS kicks in. This configuration may look like this:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%202.JPG)

You can increase or decrease the "TC" and "ABS" intensity using the buttons and control the overall vibration intensity using the dial knob. But it may have been configured completely differently. This concrete configuration is the result of the following plugin arguments, which will be described later:

	pedalVibration: On 2WayToggle.3 Dial.1;
	pedalEffects: TC Button.1 Button.5, ABS Button.2 Button.6
	
Since this is completely controlled by the configuration and the profiles you have set up in *SimHub*, you may use different effects or none at all depending on your needs and your available hardware.
  
### Mode *Chassis Vibration*

The second mode, which is quite similar to the mode "Pedal Vibration" lets you control all the chassis vibration effects. Here are four effects part of the sample configuration, "RPMS", "GearShift", "WheelsLock" and "WheelsSlip". All these effect may be distributed to the front and the rear with different intensities and effect causes (for example "WheelsSlip" can differentiate between over- and understeer slip amount) according to the profile used in *SimHub*.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%203.JPG)

You will achieve this controller configuration with the following plugin arguments:

	frontChassisVibration: On 2WayToggle.4 Dial.1;
	rearChassisVibration: On 2WayToggle.5 Dial.2;
	chassisEffects: RPMS Button.1 Button.5, GearShift Button.2 Button.6, WheelsLock Button.3 Button.7, WheelsSlip Button.4 Button.8
	
### Configuration

As you have seen, "Tactile Feedback" is quite flexible and therefore provides many plugin parameters. All the arguments for these parameters must be supplied in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool.

	controlApplication: *Name of the SimHub application configuration*;
	pedalVibration: *initialState* *onOffFunction* [*intensityFunction*];
	frontChassisVibration: *initialState* *onOffFunction* [*intensityFunction*];
	rearChassisVibration: *initialState* *onOffFunction* [*intensityFunction*]
	
The optional parameter *controlApplication* let you provide the name of the configured application object for *SimHub*, if it is not named "Tactile Feedback".
The other three parameters follow the same format and let you control the respective group of vibration effects.
*initialState* must be either "On" or "Off". Unfortunately, there is no way to query *SimHub* to request the current state of a toggleable effect, so this can get out of sync, if you left it in the other state the last time you used your rig.
*onOffFunction* will define a controller function to switch the respective vibration effect group on or off. Both, unary and binary functions are supported. This function is connected to the plugin itself and is therefore always available. For all this to work as expected, you must define a trigger in *SimHub* at the respective effect group, which must be named "toggle[*Effect*]Vibration", where *Effect* is either "Pedal", "FrontChassis" or "RearChassis".
The optional argument *intensityFunction*, which is part of the respective mode, will let you control the overall intensity of the effect group. You may have to supply a descriptor for a binary function here, unless you only want to increase the intensity all the time. Example: "pedalVibration: On 2WayToggle.3 Dial.1". You can achieve the same result by supplying an effect named "Pedal", "FrontChassis" or "RearChassis" in the respective mode effects parameter below. As a bonus, you are able to specify two unary functions to control the vibration intensity, if you are using this variant.

In the next step, you may describe all the individual effects for your vibration settings:

	pedalEffects: *effect1* *increaseFunction1* [*decreaseFunction1*], *effect2* *increaseFunction2* [*decreaseFunction2*], ...; 
	chassisEffects: *effect1* *increaseFunction1* [*decreaseFunction1*], *effect2* *increaseFunction2* [*decreaseFunction2*], ...
	
With these parameters, you define the effects that are part of the "Pedal Vibration" or "Chassis Vibration" mode. *effectX* is the name of the effect, for example "TC". This name must be identical to that used, when defining the external trigger in *SimHub* according to the pattern "increase[*Effect*]Vibration" or "decrease[*Effect*]Vibration". For the function bindings, you can use one binary functions, i.e. a rotary dial, for a given effect, or two unary functions, for example push buttons. If you only supply one unary function, you may only increase the effect intensity. Example: "chassisEffects: RPMS Dial.2, GearShift Button.2 Button.6"

Note: To supply the labels, that will be displayed for all these effects and triggers on the visual representation of your controller hardware, use the *Labels Editor*, which is available at the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool.

## Plugin *Motion Feedback*

The "Motion Feedback" plugin is as flexible as the "Tactile Feedback" plugin. It uses [SimFeedback](https://www.opensfx.com/) to control the motion actuators of your simulation rig. *SimFeedback* which is the software part of a [community project](https://opensfx.com/) for building motion rigs, comes in two flavours, a free edition and a so called expert edition, that needs some sort of commercial license. Only the expert edition supports extensions, which allow you to connect to *SimFeedback* using APIs and control the state of all motion effects and intensities without interacting with *SimFeedback* as a user. For the free edition, the plugin "Motion Feedback" therefore tries to control *SimFeedback" using mouse automation, a functionality provided by AutoHotkey, but there are limitations. I strongly recommend to invest in an expert license and install the [SFX-100-Streamdeck](https://github.com/ashupp/SFX-100-Streamdeck) extension and the corresponding console application used to connect to this API. It will be much more fun.

Obviously, this plugin needs *SimFeedback* to be installed on your PC and an application named "Motion Feedback", that points to this *SimFeedback* installation must be configured in the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications) of the configuration tool. Otherwise, the "Motion Feedback" plugin won't install and won't be activated. Please define "startSimFeedback" for the *Startup* function hook, which is especially necessray, if your using mouse automation to control *SimFeedback*. If for any reason you prefer a different name for theapplication configuration object, you can provide it with the *controlApplication* plugin argument. 

When using the API connection, you must install and activate the [above extension](https://github.com/ashupp/SFX-100-Streamdeck) in *SimFeedback* and the console application as a connector. The path to the connector must then be supplied using a plugin argument as described below. 

To get the most out of this plugin in the sample configuration presented below, you will need one 2-way toggle switch, two rotary dials and eight push buttons on your controller hardware, although the dials and push buttons may be shared with other modes. But, since all this is fully configurable, you can find a compromise, if your controller provides less control elements. To help you with the configuration of *SimFeedback*, a profile for ACC is provided in the *Profiles* folder in the Simulator Controller distribution. Please load this profile and adopt it to the specific configuration of your simulation rig. Using the plugin parameters described below, you can then customize the "Motion Feedback" plugin to support your concrete hardware configuration as best as possible.

To globally start or stop the motion actuators of your rig, a plugin action must be bound to a controller function. You can do this with a plugin argument:

	motion: Off 2WayToggle.2 Dial.1 30

The details of the parameter "motion" will be described below, but as you can see, the initial state for *Motion* is "Off" and this state is controlled by the 2-way toggle switch # **2**.

### Mode *Motion*

The plugin defines a single mode to control all motion effects of your simulation rig. This mode is only available, when the motion actuators have been activated. You can enable or disable individual effects and control their intensities. Since there might be quite a lot of individual effects, many more than possibly available dial knobs on your controller this mode provides a selector, with which you can choose an effect to be controlled by the one and only dial.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%204.JPG)

Using the buttons, you can enable or disable the individual effects, but if you press the "Effect Selector" button, before pressing one of the effect buttons, you will chose this effect to be controlled by the dial in the lower right corner of the controller. All this will be achieved using the following plugin argument:

	motionEffectIntensity: Button.8 Dial.2;
	motionEffects: Heave On 1.0 Button.1, Surge On 1.0 Button.2, Surge_2 On 1.0 Button.3, Sway On 1.0 Button.4,
				   Pitch On 1.0 Button.5, Roll On 0.5 Button.6, Traction_Loss Off 1.2 Button.7

As you can see, the effect selector is configured as the button # **8** and will use dial # **2** to control the selected effect.

### Configuration

All the arguments for the plugin parameters of the "Motion Feedback" plugin must be supplied in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool. For the plugin itself the following arguments are relvant:

	controlApplication: *Name of the SimFeedback application configuration*;
	connector: *path to sfx-100-console-application*;
	motion: *initialState* *onOffFunction* [*intensityFunction* [*initialIntensity*]]

The optional parameter *controlApplication* let you provide the name of the configured application object for *SimFeedback*, if it is not named "Motion Feedback". The *connector* parameter may be used, when *SimFeedack* is running in expert mode and you have installed the extensions mentioned above. The path must be set to the location of the console executable, as in "D:\Programme\SimFeedback Connector\sfx-100-streamdeck-console.exe". For *motion*, you supply the *initialState* as one of "On" or "Off". 
*onOffFunction* will define a controller function to start or stop the motion actuator motors. Both, unary and binary functions are supported. This function is connected to the plugin itself and is therefore always available. You can supply a function to control the overall motion intensity starting with *initialIntensity* with the optional *intensityFunction* parameter. You must supply a descriptor for a binary function here, unless you only want to increase the intensity all the time. Example: "motion: Off 2WayToggle.2 Dial.1 30". The intensity function will become an element of the "Motion" mode.

Warning: *initialState* and *initialIntensity* will only be used at startup, when using mouse automation to control *SimFeedback*. It is absolutely cruicial, that these settings correspond with the current settings in *SimFeedback*, when it starts. Otherwise, you will get unpredictable results, since the emulated mouse clicks may be going wild. When using the connector, the initial values will be ignored and the current state will be reoquested from *SimFeedback* using the API integration instead. However, if motion is switched off, all effect states and intensities will be reset to their initial states, even when using the connector.

With the following parameters you can configure the available effects for the "Motion" mode:

	motionEffects: *effect1* *initialState1* *intialIntensity1* *effectToggleFunction1*,
				   *effect2* *initialState2* *intialIntensity2* *effectToggleFunction2*, ...

*effectX* is the name of the effect, for example "Heave". With *initialStateX* and *intialIntensityX* you supply "On" or "Off" and a value between 0.0 and 2.0 respectively. These values will only be used, when mouse automation is used to control *SimFeedback*. Last, you need to supply a controller function with *effectToggleFunctionX* to enable or disable the effect or choose it for intensity manipulation after pressing the "Effect Selector" button, which must have been configured by supplying values for the "motionEffectIntensity" parameter. Example: "Heave On 1.0 Button.1".

	motionEffectIntensity: *effectSelectorFunction* *effectIntensityFunction* [*effectIntensityFunction*];

With "motionEffectIntensity", you can configure, how to manipulate the intensity for one of the effects on your hardware controller. You must supply a unary function for *motionEffectIntensity*, which allows you the two select one of the effects using the *effectToggleFunctionX* function supplied above. After you have selected an effect, you can manipulate its intensity using the *effectIntensityFunction*. Please note, that you can supply either a binary *effectIntensityFunction*, for example a dial, or two unary functions, which then are used to decrease and increase the chosen effect accordingly.

Important: Please be aware, that effect names containing spaces must be enclosed in double quotes, since spaces are allowed in *SimFeedback* effect names, but not in plugin arguments.

Note: To change the labels, that are displayed for all these effects and triggers on the visual representation of your controller hardware, use the *Labels Editor*, which is available at the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool.

Last but not least, the connection between the "Motion Feedback" plugin and *SimFeedback* still has some stabilty issues. Looks like the root cause is located in the *SFX-100-Streamdeck* extension. For a workaround click on "Reload Profile..." button in the Extensions tab in SimFeedback, if you see strange numbers in the Button Box "Motion" mode page.

## Plugin *Pedal Calibration*

This plugin allows you to choose between different calibration curves for your high end pedals directly from the Button Box. The current implementation supports the Heusinkveld pedal family, but the vendor specific part of the plugin is quite small. Therefore is an adoption to a different pedal product possible without much effort. The "Pedal Calibration" plugin It uses [SmartControl](https://heusinkveld.com/download-smartcontrol-configuration-tool/?q=%2Fdownload-smartcontrol-configuration-tool%2F&v=3a52f3c22ed6) to control the pedal calibration.

IMPORTANT: Currently, only version 1.0 of *SmartControl* is supported, since version 1.3.3+ has still a lot of bugs right now.

### Mode *Pedal Calibration*

The plugin provides one controller mode, which lets you bind an unlimted set of calibration selectors to the buttons of your Button Box. This mode is always available, and you can change the pedal calibration even while in a race.

Here is an example for a typical layout.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%207.JPG)

To achieve this layout, use the following plugin argument:

	controlApplication: Heusinkveld SmartControl;
	pedalCalibrations: Brake.Linear Button.1, Brake.S-Shape Button.5,
					   Brake.Slow_Start Button.2, Brake.Slow_End Button.6,
					   Throttle.Linear Button.3, Throttle.S-Shape Button.7,
					   Throttle.Slow_Start Button.4, Throttle.Slow_End Button.8

As you can see, it looks like that my rig does not have a clutch pedal.

### Configuration

All the arguments for the plugin parameters of the "Pedal Calibration" plugin must be supplied in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool. For the plugin itself the following arguments are relvant:

	controlApplication: *Name of the SmartControl application configuration*;
	pedalCalibrations: *pedal*.*calibration* *selectorFunction*, ...

The optional parameter *controlApplication* let you provide the name of the configured application object for *SmartControl*, as long as it is not named "Pedal Calibration". With the *pedalCalibrations* parameter, you can provide all calibration selections, you want to have on your Button Box. *pedal* can be either "Clutch", "Brake" or "Trottle" and *calibration* must be one of "Linear", "Sense+1", "Sense+2", "Sense-1", "Sense-2", "S-Shape", "S_on_Side", "Slow_Start", "Slow_End" or "Custom" for the Heusinkveld Pedals. "Example: "pedalCalibrations: Clutch.Linear Button.1, Brake.Linear Button.2, ..."

Important: Please be aware, that curve names  containing spaces must be enclosed in double quotes, since spaces are allowed in *SmartControl* curve names, but not in plugin arguments.

## Plugin *Driving Coach*

The "Driving Coach" plugin handles the interaction with the AI Driving Coach. Aiden, the coach will be automatically started, whenever Simulator Controller is running. Additional information, for example about your performance in the current race, or telemetry data of your car, might be available to the coach, if a simulation is running as well. The following configuration parameters allow you to customize Aiden to your preferences:

	raceAssistant: [*initialState*] [*onOffFunction*]; name: *name*; logo: On | Off; language: DE | EN | ...;
	synthesizer: Windows | dotNET | Azure|tokenIssuerEndpoint|subscriptionKey | Google|apikey;
	speaker: On | Off | *Speech Generation Language*; speakerVocalics: *volume* , *pitch* , *rate*;
	speakerBooster: *speakerBooster*;
	recognizer: Desktop | Azure|tokenIssuerEndpoint|subscriptionKey | Google|apikey;
	listener: On | Off | *Speech Recognition Engine*; listenerBooster: *listenerBooster*;
	agentBooster: *agentBooster*;
	telemetryCoaching: *onOffFunction*; trackCoaching: *onOffFunction*;
	openSetupWorkbench: *workbenchFunction*

For Aiden to be generally available, you must supply an argument for the *name* parameter, for example "Aiden". You can define a function on your hardware controller with the parameter *raceAssistant*, to enable or disable the AI Driving Coach dynamically. The *onOffFunction* may be ommited, if you only want to enable or disable the Assistant generally. The also optional *initialState* must be either "On" or "Off" (default is "On") and for *onOffFunction* unary and binary functions are supported. The function will be bound to a plugin action.
Last, but not least, with *openSetupWorkbench* you can open the ["Setup Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench) tool.

With "On" (or *true*) supplied for *logo*, Aiden will show a nice rotating AI brain in the lower right corner of the screen, while the AI kernel is working, but you will get a short lag in your simulation, when this window pops up.

The paranmeter *synthesizer* allows you to specify the speech synthesis engine, which is used for the Driving Coach. If you supply *Windows* or *dotNET*, you will use the synthesis engine on your local computer. *Windows* specifies the original solution, whereas *dotNET* specifies the enhanced version introduced with the .NET framework. If you supply *Azure|tokenIsszuerEndpoint|subscriptionKey* or *Google|apikey* (with valid values for *tokenIssuerEndpoint* and *subscriptionKey* or *apiKey*), you will use the cloud services of Microsoft or Google to generate voice output and you will have access to more and more natural voices, but this possibly does not come for free. Please see the [Voice Control configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) for more information. Default for the *synthesizer* parameter is the preconfigured engine.

With *recognizer* you specify the engine used for voice recognition. The value *Desktop* activates the recognition engine which is part of the Windows operating system. Very good recognition quality, but it needs high quality audio input, for example from a headset microphone. You can also activate voice recognition on the Azure Cognitive Services cloud using the same syntax as described above for the *synthesizer* parameter. The default value for *recognizer* is also taken from the general voice configuration, when no value is supplied.

Please note, that the voice recognizer *Server* cannot be used for the driving coach, since this recognition engine does not support the conversion of free speech to text.

With *speaker* and *listener* you can customize the natural language interface (or the personality) of Aiden. If you simply supply "On" (or *true*) as arguments, a voice and the corresponding recognition engine will be choosen based on the currently configured language. If you prefer a specific voice and / or a specific language, you can supply the name for this voice and language instead (Example: "Microsoft David Desktop" is a male US-English voice). Using the parameter *speakerVocalics*, you can supply individual values for the voice volume, voice pitch and speech rate. *volume* must be a number between 0 and 100. For *pitch* and *rate*, you can supply values from -10 to 10. Additionally, you can supply a "*" for each of the three values. In this case, the corresponding setting in the voice control configuration is used. If an argument for the paramter *speakerVocalics* is not supplied at all, the values from the general voice control configuration will be taken as default as well. For more information about Aiden, see the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach). The name of a GPT-based post-processor to bring some variation to some predefined spoken messages of Aiden can be supplied using *speakerBooster* and the name of a GPT-based pre-processor for voice recognition can be supplied with *listenerBooster*. *agentBooster* can be used to give the Assistant even more intelligence and autonomous behaviour using a GPT-based extension to the rule engine. With *language* you can overwrite the default language, which has been configured in the [voice tab of the configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control). 

With *telemetryCoaching* you can supply a function to enable or disable active, telemetry-based coaching for your current session. Unary and binary functions are supported for *onOffFunction*. The function will be bound to a plugin action. The coresponding *trackCoaching* parameter allows to bind a function that enables / disables active coaching while driving. See the [documentation about active coaching](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#Active-Coaching) for more information.

Additional commands for Aiden are available using the *assistantCommands* parameter:

	assistantCommands: Interrupt *interruptFunction*, ...

With *Interrupt* you can interrupt the currently running speech of Aiden.

## Plugin *Race Engineer*

The "Race Engineer" plugin handles the interaction of the currently active simulation as represented by the plugins "ACC", "RF2", "R3E", and so on, and Jona, the AI Race Engineer. If one of these simulation is started, the "Race Engineer" plugin will be automatically activated, and will start Jona in the background according to the configuration arguments described below. The following configuration parameters allow you to customize Jona to your preferences:

	raceAssistant: [*initialState*] [*onOffFunction*]; name: *name*; logo: On | Off; language: DE | EN | ...;
	synthesizer: Windows | dotNET | Azure|tokenIssuerEndpoint|subscriptionKey | Google|apikey;
	speaker: On | Off | *Speech Generation Language*; speakerVocalics: *volume* , *pitch* , *rate*;
	speakerBooster: *speakerBooster*;
	recognizer: Server | Desktop | Azure|tokenIssuerEndpoint|subscriptionKey | Google|apikey;
	listener: On | Off | *Speech Recognition Engine*; listenerBooster: *listenerBooster*;
	conversationBooster: *conversationBooster*; agentBooster: *agentBooster*;
	muted: true | false;
	teamServer: [*initialState*] [*onOffFunction*];
	openRaceSettings: *settingsFunction*; importSetup: *importFunction*;
	openSessionDatabase: *setupsFunction*; openSetupWorkbench: *workbenchFunction*;
	openSoloCenter: *soloCenterFunction*; openTeamCenter: *teamCenterFunction*
	
For Jona to be generally available, you must supply an argument for the *name* parameter, for example "Jona". You can define a function on your hardware controller with the parameter *raceAssistant*, to enable or disable the AI Race Engineer dynamically. The *onOffFunction* may be ommited, if you only want to enable or disable the Assistant for all your sessions. The also optional *initialState* must be either "On" or "Off" (default is "On") and for *onOffFunction* unary and binary functions are supported. The function will be bound to a plugin action.
The *teamServer* parameter replicates the configuration option of the ["Team Server" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server) for your convience (and to have it available for configuration in "Simulator Setup"). Additionally, the parameter *openRaceSettings* allows you to bind a plugin action to your hardware controller, which opens the [settings dialog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#race-settings), which you will use before a race to give Jona the necessary information about your car setup and other stuff. As an alternative you can use the plugin action *importSetup* to import the current tyre setup data only, without opening the settings dialog. Nevertheless, you will get a notification, when the setup has been imported successfully.
Last, but not least, with *openSessionDatabase* you can open the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) tool. If a simulation is currently running, most of the query arguments will already be prefilled. Very similar are the parameters *openSetupWorkbench*, *openSoloCenter* and *openTeamCenter*, which let you open the "Setup Workbench", the "Solo Center" and the "Team Center" tool.

Hint: You can bind the activation and deactivation of all the AI Race Assistants to one function, if you want to control them with the same switch on your hardwar controller.

Note: If you disable Jona during an active race, the Race Engineer will stop working immediately. You can also enable Jona at the beginning of a race, but only until you cross the start/finish line for the first time in your first stint. If you enable Jona after the initial lap, Jona will not be available until the next session. 

With "On" (or *true*) supplied for *logo*, Jona will show a nice rotating AI brain in the lower right corner of the screen, while the AI kernel is working, but you will get a short lag in your simulation, when this window pops up.

The parameter *synthesizer* allows you to specify the speech synthesis engine, which is used for this Race Assistant. If you supply *Windows* or *dotNET*, you will use the synthesis engine on your local computer. *Windows* specifies the original solution, whereas *dotNET* specifies the enhanced version introduced with the .NET framework. If you supply *Azure|tokenIsszuerEndpoint|subscriptionKey* or *Google|apikey* (with valid values for *tokenIssuerEndpoint* and *subscriptionKey* or *apiKey*), you will use the cloud services of Microsoft or Google to generate voice output and you will have access to more and more natural voices, but this possibly does not come for free. Please see the [Voice Control configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) for more information. Default for the *synthesizer* parameter is the preconfigured engine.

With *recognizer* you specify the engine used for voice recognition. The value *Server* stands for the older engine provided by Microsoft for server side solutions. It can handle low quality audio, for example from telephone calls, but the recognition quality is not the best. The value *Desktop* activates the recognition engine which is part of the Windows operating system. Very good recognition quality, but it needs high quality audio input, for example from a headset microphone. You can also activate voice recognition on the Azure Cognitive Services cloud using the same syntax as described above for the *synthesizer* parameter. The default value for *recognizer* is also taken from the general voice configuration, when no value is supplied.

With *speaker* and *listener* you can customize the natural language interface (or the personality) of Jona. If you simply supply "On" (or *true*) as arguments, a voice and the corresponding recognition engine will be choosen based on the currently configured language. If you prefer a specific voice and / or a specific language, you can supply the name for this voice and language instead (Example: "Microsoft David Desktop" is a male US-English voice and "Microsoft Server Speech Recognition - TELE (de-DE)" provide german spoken language recognition=. The phrase grammars of Jona can be localized for any language, with English, German and Spanish already supplied by the standard distribution of Simulator Controller, but you will also need the corresponding Windows libraries for TTS (text-to-speech) and STT (speech-to-text). Using the parameter *speakerVocalics*, you can supply individual values for the voice volume, voice pitch and speech rate. *volume* must be a number between 0 and 100. For *pitch* and *rate*, you can supply values from -10 to 10. Additionally, you can supply a "*" for each of the three values. In this case, the corresponding setting in the voice control configuration is used. If an argument for the paramter *speakerVocalics* is not supplied at all, the values from the general voice control configuration will be taken as default as well. The name of a GPT-based post-processor to bring some variation to all the spoken messages of Jona can be supplied using *speakerBooster* and the name of a GPT-based pre-processor for voice recognition can be supplied with *listenerBooster*. *conversationBooster* and *agentBooster* can be used to give the Assistant even more intelligence and autonomous behaviour using a GPT-based extension to the rule engine. With *language* you can overwrite the default language, which has been configured in the [voice tab of the configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control). For more information about Jona, see the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer).

All Race Assistants can be temporarily instructed with a couple of voice commands to be quite. If you want Jona to start muted, you can request that by supplying *true* for the *muted* parameter. If you want Jona to become active again later on, you can request this using the voice command "You can talk again." or the "Unmute" trigger below.

It is possible, although not much fun, to use Jona without its natural language interface. Only the pitstop planning and setup capabilities are available in this configuration, but it is still useful. You can use the following parameters to connect these actions to your controller hardware:

	assistantCommands: PitstopPlan *function*, DriverSwapPlan *function*, PitstopPrepare *function*,
					   FuelRatioOptimize *function*,
					   Call *callFunction*, Accept *acceptFunction*, Reject *rejectFunction*,
					   Interrupt *interruptFunction*, Mute *muteFunction*, Unmute *unmuteFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
	
All these command actions will be bound to the plugin itself, thereby are available all the time, and only unary functions are supported here. By using this actions, you will be able to use Jona with voice output, but no voice control, thereby getting most of the support from Jona, but you have to use an *oldschool* interface to control the engineer actions. To *answer* "Yes" to one of the questions of Jona, you must supply a controller function, for example a push button function, to the *Accept* parameter and for "No", you must use the *Reject* parameter. A little bit different is the *Call* action. This action will activate Jona and will make it the active listening dialog partner for voice control by the push of a button. This is similar to issuing the "Hey Jona" activation command. With *Interrupt* you can interrupt the currently running speech of Jona, and last but not least, you can use *Mute* and *Unmute*, when you temporarely want to deactivate voice ouput for Jona.

Note: The *FuelRatioOptimize* is available only when using *Le Mans Ultimate*.

Furthermore, you can request a lot of information from Jona, mostly about the current state of your car. Thefore, you can supply the *InformationRequest* parameter multiple times.

Example:

	assistantCommands: ...,
					   InformationRequest LapsRemaining Button.1,
					   InformationRequest TyrePressures Button.2,
					   InformationRequest TyreTemperatures Button.3,
					   ...
	
Please see the following table for available information commands.

| Command | Description |
| ------ | ------ |
| Time | You will be told the current time of your local computer. |
| LapsRemaining | Jona will give you the number of laps still to drive. The number of remaining laps is determined by the remaining stint, session or driver time, but of course is also limited by the remaining fuel. |
| FuelRemaining | Jona will give you the amount of remaining fuel in the tank. |
| Weather | You will get information about the current and upcoming weather. |
| TyrePressures | Jona will tell you the current pressures in your tyres. |
| TyrePressuresCold | Jona will tell you the current cold target pressures for the next pitstop of your tyres. |
| TyrePressuresSetup | Jona will tell you the last cold setup pressures of your tyres. |
| TyreTemperatures | This command will give you the current temperatures in the core of your tyres. |
| TyreWear | This command will give you the current tyre wear in percentage of total wear for the inidividual tyres. Not all simulators support this, and to be honest, it also not available for most race cars in real life. |
| BrakeTemperatures | This command will give you the current temperatures for the individual brakes in Degrees Celsius. |
| BrakeWear | This command will give you the current tyre wear in percentage of total wear for the brakes. Not all simulators support this, and to be honest, it also not available for most race cars in real life. |
| EngineTemperatures | This command will give you the current water and oil temperatures, if they are available. |

Note: All these commands are also available in most of the simulation plugins, either in the "Pitstop" mode or in the "Assistant" mode, depending on the configuration parameters.

## Plugin *Race Strategist*

The "Race Strategist" plugin handles the interaction of the currently active simulation as represented by the plugins "ACC", "RF2", "R3E", and so on, and Cato, the AI Race Strategist. If one of these simulation is started, the "Race Strategist" plugin will be automatically activated, and will start Cato in the background according to the configuration arguments described below. The following configuration parameters allow you to customize Cato to your preferences:

	raceAssistant: [*initialState*] *onOffFunction*; name: *name*; logo: On | Off; language: DE | EN | ...;
	synthesizer: Windows | dotNET | Azure|tokenIssuerEndpoint|subscriptionKey | Google|apikey;
	speaker: On | Off | *Speech Generation Language*; speakerVocalics: *volume* , *pitch* , *rate*;
	speakerBooster: *speakerBooster*;
	recognizer: Server | Desktop | Azure|tokenIssuerEndpoint|subscriptionKey | Google|apikey;
	listener: On | Off | *Speech Recognition Engine*; listenerBooster: *listenerBooster*;
	conversationBooster: *conversationBooster*; agentBooster: *agentBooster*;
	muted: true | false;
	teamServer: [*initialState*] [*onOffFunction*];
	openRaceSettings: *settingsFunction*; openRaceReports: *reportsFunction*;
	openSessionDatabase: *setupsFunction*; openStrategyWorkbench: *strategyFunction*;
	openSoloCenter: *soloCenterFunction*, openTeamCenter: *teamCenterFunction*
	
For Cato to be generally available, you must supply an argument for the *name* parameter, for example "Khato". You can define a function on your hardware controller with the parameter *raceAssistant*, to enable or disable the AI Race Strategist dynamically. The *onOffFunction* may be ommited, if you only want to enable or disable the Assistant for all your sessions. The also optional *initialState* must be either "On" or "Off" (default is "On") and for *onOffFunction* unary and binary functions are supported. The function will be bound to a plugin action.
The *teamServer* parameter replicates the configuration option of the ["Team Server" plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-team-server) for your convience (and to have it available for configuration in "Simulator Setup"). Additionally, the parameter *openRaceSettings* allows you to bind a plugin action to your hardware controller, which opens the [settings dialog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist#race-settings), which you will use before a race to give Cato the necessary information about your car setup and strategy options. With *openRaceReports* you can open the ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports) tool with the current simulator, car and track already selected and with *openSessionDatabase* you can open the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) tool. If a simulation is currently running, most of the query arguments will already be prefilled. Very similar are the parameters *openStrategyWorkbench*, *openSoloCenter* and *openTeamCenter*, which let you open the "Strategy Workbench", "Solo Center" and the "Team Center" tool.

Hint: You can bind the activation and deactivation of all the AI Race Assistants to one function, if you want to control them with the same switch on your hardwar controller.

With "On" (or *true*) supplied for *logo*, Cato will show a nice rotating AI brain in the lower left corner of the screen, while the AI kernel is working, but you will get a short lag in your simulation, when this window pops up.

The paranmeter *synthesizer* allows you to specify the speech synthesis engine, which is used for this Race Assistant. If you supply *Windows* or *dotNET*, you will use the synthesis engine on your local computer. *Windows* specifies the original solution, whereas *dotNET* specifies the enhanced version introduced with the .NET framework. If you supply *Azure|tokenIsszuerEndpoint|subscriptionKey* or *Google|apikey* (with valid values for *tokenIssuerEndpoint* and *subscriptionKey* or *apiKey*), you will use the cloud services of Microsoft or Google to generate voice output and you will have access to more and more natural voices, but this possibly does not come for free. Please see the [Voice Control configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) for more information. Default for the *synthesizer* parameter is the preconfigured engine.

With *recognizer* you specify the engine used for voice recognition. The value *Server* stands for the older engine provided by Microsoft for server side solutions. It can handle low quality audio, for example from telephone calls, but the recognition quality is not the best. The value *Desktop* activates the recognition engine which is part of the Windows operating system. Very good recognition quality, but it needs high quality audio input, for example from a headset microphone.
 
With *speaker* and *listener* you can customize the natural language interface (or the personality) of Cato. If you simply supply "On" (or *true*) as arguments, a voice and the corresponding recognition engine will be choosen based on the currently configured language. If you prefer a specific voice and / or a specific language, you can supply the name for this voice and language instead (Example: "Microsoft David Desktop" is a male US-English voice and "Microsoft Server Speech Recognition - TELE (de-DE)" provide german spoken language recognition). The phrase grammars of Cato can be localized for any language, with English, German and Spanish already supplied by the standard distribution of Simulator Controller, but you will also need the corresponding Windows libraries for TTS (text-to-speech) and STT (speech-to-text). Using the parameter *speakerVocalics*, you can supply individual values for the voice volume, voice pitch and speech rate. *volume* must be a number between 0 and 100. For *pitch* and *rate*, you can supply values from -10 to 10. Additionally, you can supply a "*" for each of the three values. In this case, the corresponding setting in the voice control configuration is used. If an argument for the paramter *speakerVocalics* is not supplied at all, the values from the general voice control configuration will be taken as default as well. The name of a GPT-based post-processor to bring some variation to all the spoken messages of Cato can be supplied using *speakerBooster* and the name of a GPT-based pre-processor for voice recognition can be supplied with *listenerBooster*. *conversationBooster* and *agentBooster* can be used to give the Assistant even more intelligence and autonomous behaviour using a GPT-based extension to the rule engine. With *language* you can overwrite the default language, which has been configured in the [voice tab of the configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control). For more information about Cato, see the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist).

All Race Assistants can be temporarily instructed with a couple of voice commands to be quite. If you want Cato to start muted, you can request that by supplying *true* for the *muted* parameter. If you want Cato to become active again later on, you can request this using the voice command "You can talk again." or the "Unmute" trigger below.

Similar as for Jona, you can use the following parameters to trigger some of Catos service without using voice commands:

	assistantCommands: PitstopRecommend *function*, StrategyCancel *function*,
					   Call *callFunction*, Accept *acceptFunction*, Reject *rejectFunction*,
					   Interrupt *interruptFunction*, Mute *muteFunction*, Unmute *unmuteFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
	
All these command actions will be bound to the plugin itself, thereby are available all the time, and only unary functions are supported here. By using these actions, you will be able to use Cato with voice output, but no voice control, thereby getting most of the support from Cato, but you have to use an *oldschool* interface to control the strategist actions. To *answer* "Yes" to one of the questions of Cato, you must supply a controller function, for example a push button function, to the *Accept* parameter and for "No", you must use the *Reject* parameter. A little bit different is the *Call* action. This action will activate Cato and will make it the active listening dialog partner for voice control by the push of a button. This is similar to issuing the "Hey Cato" activation command. With *Interrupt* you can interrupt the currently running speech of Cato, and last but not least, you can use *Mute* and *Unmute*, when you temporarely want to deactivate voice ouput for Cato.

These additional commands are available:

| Command | Description |
| ------ | ------ |
| StrategyCancel | Cancels the current strategy. Cato will not have any strategy information from now on. |
| StrategyRecommend | Cato will try to update the currently active strategy according to the current situation. Very useful after an unplanned pitstop or a sudden weather change. |
| FCYRecommend | This command can be triggered, when the track is under Full Course Yellow with pitstops allowed. Cato will then check whether a pitstop under full course yellow will have a strategical benefit.  |
| PitstopRecommend | Cato will try to determine the best possible lap for the next pitstop. Possible undercuts will be taken into account as well as the traffic situation after the pitstop. |

Furthermore, you can request a lot of information from Cato about the current race situation. Thefore, you can supply the *InformationRequest* parameter multiple times.

Example:

	assistantCommands: ...,
					   InformationRequest Position Button.1,
					   InformationRequest GapToAhead Track Button.2,
					   InformationRequest GapToRear Track Button.3,
					   ...
	
Please see the following table for available information commands.

| Command | Description |
| ------ | ------ |
| Time | You will be told the current time of your local computer. |
| LapsRemaining | Cato will give you the number of laps still to drive. The number of remaining laps is determined by the remaining stint, session or driver time, but of course is also limited by the remaining fuel. |
| Weather | You will get information about the current and upcoming weather. |
| Position | Cato will tell you your current position. |
| LapTime | You will be given information about your last lap time. |
| LapTimes | You will be given information about your last lap time and those of your direct opponents. |
| ActiveCars | Cato will give you information about the number of cars in the session. In a multi-class or multi-category session additional information will be given on the number of cars in your own class as well. |
| GapToAhead [Standings, Track] | Cato will tell you the gap in seconds to the car one position ahead of you or to the car directly in front of you. If you don't supply *Standings* or *Track*, it will default to *Standings*. Please note, that for compatibility reasons, *GapToFront* is supported as well. |
| GapToBehind [Standings, Track] | Cato will tell you the gap in seconds to the car one position behind you or to the car directly behind you. If you don't supply *Standings* or *Track*, it will default to *Standings*. |
| GapToLeader | Cato will tell you the gap in seconds to the leading car. |
| DriverNameAhead | The Strategist will tell you the driver name of the car ahead of you. |
| DriverNameBehind | The Strategist will tell you the driver name of the car behind of you. |
| CarClassAhead | The Strategist will tell you the class of the car ahead of you. |
| CarClassBehind | The Strategist will tell you the class of the car behind of you. |
| CarCupAhead | The Strategist will tell you the cup category of the car ahead of you. |
| CarCupBehind | The Strategist will tell you the cup category of the car behind of you. |
| StrategyOverview | As the name says, you will get a complete overview of the race strategy, as long as one has been defined in the "Strategy Workbench" and has been exported to be used in this session. |
| NextPitstop | Cato tells you the lap, where the next pitstop according to the strategy has been planned. The Strategist will also ask, whether the Engineer should be informed right away, even if the planned pitstop is still far in the future. |

Note: All these commands are also available in most of the simulation plugins, either in the "Pitstop" mode or in the "Assistant" mode, depending on the configuration parameters.

## Plugin *Race Spotter*

The "Race Spotter" plugin handles the interaction of the currently active simulation as represented by the plugins "ACC", "RF2", "R3E", and so on, and Elisa, the AI Race Spotter. If one of these simulation is started, the "Race Spotter" plugin will be automatically activated, and will start Elisa in the background according to the configuration arguments described below. The following configuration parameters allow you to customize Elisa to your preferences:

	raceAssistant: [*initialState*] *onOffFunction*; name: *name*; logo: On | Off; language: DE | EN | ...;
	synthesizer: Windows | dotNET | Azure|tokenIssuerEndpoint|subscriptionKey | Google|apikey;
	speaker: On | Off | *Speech Generation Language*; speakerVocalics: *volume* , *pitch* , *rate*;
	speakerBooster: *speakerBooster*;
	recognizer: Server | Desktop | Azure|tokenIssuerEndpoint|subscriptionKey | Google|apikey;
	listener: On | Off | *Speech Recognition Engine*; listenerBooster: *listenerBooster*;
	conversationBooster: *conversationBooster*; agentBooster: *agentBooster*;
	muted: true | false;
	trackMapping: [*initialState*] *onOffFunction*; trackAutomation: [*initialState*] *onOffFunction*
	
For Elisa to be generally available, you must supply an argument for the *name* parameter, for example "Elias". You can define a function on your hardware controller with the parameter *raceAssistant*, to enable or disable the AI Race Spotter dynamically. The *onOffFunction* may be ommited, if you only want to enable or disable the Assistant for all your sessions. The also optional *initialState* must be either "On" or "Off" (default is "On") and for *onOffFunction* unary and binary functions are supported. The function will be bound to a plugin action.

Hint: You can bind the activation and deactivation of all the AI Race Assistants to one function, if you want to control them with the same switch on your hardwar controller.

With "On" (or *true*) supplied for *logo*, Elisa will show a nice rotating AI brain in the lower left corner of the screen, while the AI kernel is working, but you will get a short lag in your simulation, when this window pops up.

The paranmeter *synthesizer* allows you to specify the speech synthesis engine, which is used for this Race Assistant. If you supply *Windows* or *dotNET*, you will use the synthesis engine on your local computer. *Windows* specifies the original solution, whereas *dotNET* specifies the enhanced version introduced with the .NET framework. If you supply *Azure|tokenIsszuerEndpoint|subscriptionKey* or *Google|apikey* (with valid values for *tokenIssuerEndpoint* and *subscriptionKey* or *apiKey*), you will use the cloud services of Microsoft or Google to generate voice output and you will have access to more and more natural voices, but this possibly does not come for free. Please see the [Voice Control configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) for more information. Default for the *synthesizer* parameter is the preconfigured engine.

With *recognizer* you specify the engine used for voice recognition. The value *Server* stands for the older engine provided by Microsoft for server side solutions. It can handle low quality audio, for example from telephone calls, but the recognition quality is not the best. The value *Desktop* activates the recognition engine which is part of the Windows operating system. Very good recognition quality, but it needs high quality audio input, for example from a headset microphone.
 
With *speaker* and *listener* you can customize the natural language interface (or the personality) of Elisa. If you simply supply "On" (or *true*) as arguments, a voice and the corresponding recognition engine will be choosen based on the currently configured language. If you prefer a specific voice and / or a specific language, you can supply the name for this voice and language instead (Example: "Microsoft David Desktop" is a male US-English voice and "Microsoft Server Speech Recognition - TELE (de-DE)" provide german spoken language recognition). The phrase grammars of Elisa can be localized for any language, with English, German and Spanish already supplied by the standard distribution of Simulator Controller, but you will also need the corresponding Windows libraries for TTS (text-to-speech) and STT (speech-to-text). Using the parameter *speakerVocalics*, you can supply individual values for the voice volume, voice pitch and speech rate. *volume* must be a number between 0 and 100. For *pitch* and *rate*, you can supply values from -10 to 10. Additionally, you can supply a "*" for each of the three values. In this case, the corresponding setting in the voice control configuration is used. If an argument for the paramter *speakerVocalics* is not supplied at all, the values from the general voice control configuration will be taken as default as well. The name of a GPT-based post-processor to bring some variation to all the spoken messages of Elisa can be supplied using *speakerBooster* and the name of a GPT-based pre-processor for voice recognition can be supplied with *listenerBooster*. *conversationBooster* and *agentBooster* can be used to give the Assistant even more intelligence and autonomous behaviour using a GPT-based extension to the rule engine. With *language* you can overwrite the default language, which has been configured in the [voice tab of the configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control). For more information about Elisa, see the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter).

All Race Assistants can be temporarily instructed with a couple of voice commands to be quite. If you want Elisa to start muted, you can request that by supplying *true* for the *muted* parameter. If you want Elisa to become active again later on, you can request this using the voice command "You can talk again." or the "Unmute" trigger below.

With *trackAutomation* you can supply a function to enable or disable [location dependend actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter#track-automations) for your current session. The *onOffFunction* may be ommited, if you only want to enable or disable location dependend actions for all your sessions. The also optional *initialState* must be either "On" or "Off" (default is "Off") and for *onOffFunction* unary and binary functions are supported. The function will be bound to a plugin action. Very similar is the parameter *trackMapping* which lets you enable or disable track mapping. Default is *On* here. Using a controller function to manually handle this might be very useful when mapping non-closed tracks like Rally stages or hill climb tracks.

Similar as for Cato, you can use the following parameters to trigger some of Elisas service without using voice commands:

	assistantCommands: Call *callFunction*, Accept *acceptFunction*, Reject *rejectFunction*,
					   Interrupt *interruptFunction*, Mute *muteFunction*, Unmute *unmuteFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
	
All these command actions will be bound to the plugin itself, thereby are available all the time, and only unary functions are supported here. To *answer* "Yes" to one of the questions of Elisa, you must supply a controller function, for example a push button function, to the *Accept* parameter and for "No", you must use the *Reject* parameter. A little bit different is the *Call* action. This action will activate Elisa and will make it the active listening dialog partner for voice control by the push of a button. This is similar to issuing the "Hey Elisa" activation command. With *Interrupt* you can interrupt the currently running speech of Elisa, and last but not least, you can use *Mute* and *Unmute*, when you temporarely want to deactivate voice ouput for Elisa.

Furthermore, you can request a lot of information from Elisa about the current race situation, similar to the corrsponding requests for Cato. Thefore, you can supply the *InformationRequest* parameter multiple times.

Example:

	assistantCommands: ...,
					   InformationRequest Position Button.1,
					   InformationRequest GapToAhead Track Button.2,
					   InformationRequest GapToRear Track Button.3,
					   ...
	
Please see the following table for available information commands.

| Command | Description |
| ------ | ------ |
| Time | You will be told the current time of your local computer. |
| Position | Elisa will tell you your current position. |
| LapTime | You will be given information about your last lap time. |
| LapTimes | You will be given information about your last lap time and those of your direct opponents. |
| ActiveCars | Elisa will give you information about the number of cars in the session. In a multi-class or multi-category session additional information will be given on the number of cars in your own class as well. |
| GapToAhead [Standings, Track] | Elisa will tell you the gap in seconds to the car one position ahead of you or to the car directly in front of you. If you don't supply *Standings* or *Track*, it will default to *Standings*. |
| GapToBehind [Standings, Track] | Elisa will tell you the gap in seconds to the car one position behind you or to the car directly behind you. If you don't supply *Standings* or *Track*, it will default to *Standings*. |
| GapToLeader | Elisa will tell you the gap in seconds to the leading car. |
| DriverNameAhead | The Spotter will tell you the driver name of the car ahead of you. |
| DriverNameBehind | The Spotter will tell you the driver name of the car behind of you. |
| CarClassAhead | The Spotter will tell you the class of the car ahead of you. |
| CarClassBehind | The Spotter will tell you the class of the car behind of you. |
| CarCupAhead | The Spotter will tell you the cup category of the car ahead of you. |
| CarCupBehind | The Spotter will tell you the cup category of the car behind of you. |

Note: All these commands are also available in most of the simulation plugins, either in the "Pitstop" mode or in the "Assistant" mode, depending on the configuration parameters.

## Plugin *Team Server*

This is a supporting plugin for the AI Race Assistants. It supports the connection to a central server which manages the state and knowledge of the AI Race Assistants during a multiplayer team session, for example a 24 hour endurance race. See the separate [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server) on the *Team Server* for more information. The following configuration parameters are available:

	teamServer: [*initialState*] [*onOffFunction*];
	openRaceSettings: *settingsFunction*; openTeamCenter: *centerFunction*
	
You can define a function on your hardware controller with the parameter *teamServer*, to enable or disable the connection to the *Team Server* dynamically. The *onOffFunction* may be ommited, if you only want to enable or disable the *Team Server* connection for all your sessions. The also optional *initialState* must be either "On" or "Off" (default is "On") and for *onOffFunction* unary and binary functions are supported. The function will be bound to a plugin action. If you don't supply an argument for this parameter, the *Team Server* connection will always be active, but whether you join a session depends on the settings in the "Race Settings" (see the next parameter).

The parameter *openRaceSettings* allows you to bind a plugin action to your hardware controller, which opens the [settings dialog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#race-settings), which you will use before a race to choose your driver and session settings for a team session. Please note, that this parameter is also available in the plugins for the AI Race Assistants. You only have to declare it once, if you want to use it. Last, but not least, you can open the "Team Center" using the function supplied to the *openTeamCenter* parameter. This parameter is available for you convenience in the plugins for the AI Race Assistants as well.

## Plugin *ACC*

This plugin handles the *Assetto Corsa Competizione* simulation game. This plugin needs an application with the name "Assetto Corsa Competizione" to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startACC", "stopACC" and "isACCRunning" as special function hooks in this configuration. An integration with Jona is available through the "Race Engineer" plugin, an integration with Cato through the plugin "Race Strategist", and an integration with Elisa through the plugin "Race Spotter".

### Mode *Chat*

The mode "Chat" binds all the configured chat messages to buttons on your controller hardware. The chat messages can be defined in the [Chat tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-chat). The messages will be only availabe in a multiuser race scenario, since "Assetto Corsa Competizione" activates the chat system only there.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%205.JPG)

### Mode *Pitstop*

Starting with Release 2.0, all pitstop settings of *Assetto Corsa Competizione* can be controlled by this plugin. The simulator dependent mode *Pitstop* may configure all or a subset of the pitstop settings on your hardware controller, which might be more ergonomic than typing on the keyboard during driving. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%206.JPG)

Using the buttons and dials you may change the pitstop settings in the same way as using the keyboard. All this will be achieved using the following plugin arguments:

	openPitstopMFD: p; closePitstopMFD: {Insert};
	pitstopCommands: Strategy Dial.1, Refuel Dial.2 5, TyreSet Button.1 Button.5, TyreCompound Button.2 Button.6,
					 TyreAllAround Button.3 Button.7, SuspensionRepair Button.4, BodyworkRepair Button.8

### Mode *Assistant*

This mode allows you to group all the available actions of the active Race Assistants into one layer of controls on your hardware controller. Although all these actions are also available as plugin actions of the "Race Engineer" and "Race Strategist" plugins, it may be more practicle to use the "Assistant" mode, when your set of available hardware controls is limited, since plugin actions always occupy a given control.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2012.JPG)

The above will be achieved using the following plugin argument:

	assistantCommands: InformationRequest Position Button.1, InformationRequest LapTimes Button.2,
					   InformationRequest LapsRemaining Button.3, InformationRequest Weather Button.4,
					   InformationRequest GapToAhead Standings Button.5, InformationRequest GapToBehind Standings Button.6,
					   Accept Button.7, Reject Button.8

Note: You can use all these commands in the *pitstopCommands* list as well, which will generate one giant controller mode.

### Configuration

First, you need to define, how to open and close the Pitstop MFD in *Assetto Corsa Competizione*. If the standard keyboard mapping is used, this will be the "p" and the "Insert" keys on the keyboard.

	openPitstopMFD: *openHotkey*; closePitstopMFD: *closeHotkey*;
	pitstopMFDMode: Event | Input | Play | Raw | Default

The parameter *pitstopMFDMode* determines, how the communication to the simulator is handled. You can try different values for this parameter, if the Pitstop MFD does not open. Simulator Controller simulates keyboard input for the simulator and there are different ways to do that. These are named "Event", Input", "Play", "Raw" and "Default". For whatever reason, there is not the one method, which works for every Windows installation. For me, "Event" works best and is therefore the standard, if you don't supply the parameter.

As a special case, you can provide "Off" as the argument to *openPitstopMFD*. This will disable the opening and thereby the complete control of the Pitstop MFD. The software, and especially the *Race Assistants* still *think*, that the pitstop settings had been changed, which is helpful, if you only want to get the target settings by voice, but want to dial them into the Pitstop MFD by your own.

*Assetto Corsa Competizione* provides an UDP interface to gather the position information for all the cars in the grid. The default login to this service is 127.0.0.1,9000,asd, (where the last argument, the *commandPassword*, is empty). If you have changed the connection information in the ACC configuration, you have to provide this connection information using the *udpConnection* in the plugin configuration:

	udpConnection: *ip*, *port*, *connectionPassword*, *commandPassword*

With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Strategy | Choose one of the predefined pitstop strategies. |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| NoRefuel | Sets the refuel amount to zero, thereby skipping refueling. |
| TyreChange | Enables or disables the tyre management. |
| TyreCompound | Selects either the Wet or Dry tyre compound. |
| TyreAllAround | Change the pressure for all tyres at once. Supports the additional increments argument. |
| TyreFrontLeft | Change the pressure for the front left tyre. Supports the additional increments argument. |
| TyreFrontRight | Change the pressure for the front right tyre. Supports the additional increments argument. |
| TyreRearLeft | Change the pressure for the rear left tyre. Supports the additional increments argument. |
| TyreRearRight | Change the pressure for the rear right tyre. Supports the additional increments argument. |
| BrakeChange | Enables or disables the brake management. |
| FrontBrake | Selects the compound for the front brake pads. |
| RearBrake | Selects the compound for the rear brake pads. |
| DriverSelect | Selects the driver for the next stint in a multiplayer team race. |
| SuspensionRepair | Toggles the repair of the suspension components. |
| BodyworkRepair | Toggles the repair of all the bodywork. |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

Note: Be careful, when you change pitstop settings while Jona is active, the Race Engineer will at least be very confused. There is one notable exception, if Jona has planned and prepared a pitstop, but this pitstop has not been carried out yet, every change to the pitstop settings using the "Pitstop" mode will be recognized and taken into account by Jona in the *Assetto Corsa Competizione* simulation.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, StrategyCancel *function*,
					   PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported Assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your Race Assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| FCYRecommend | This command can be triggered, when the track is under Full Course Yellow with pitstops allowed. The Race Strategist will then check whether a pitstop under full course yellow will have a strategical benefit.  |
| PitstopRecommend | Asks the AI Race Strategist for a recommendation for the next pitstop. |
| StrategyRecommend | Asks the AI Race Strategist to [recalculate and adjust the strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist#strategy-handling) based on the currently active strategy and the current race situation. Very useful after an unplanned pitstop. |
| StrategyCancel | Asks the AI Race Strategist to drop the currently active strategy. |
| PitstopPlan | Requests a pitstop plan from the AI Race Engineer. |
| DriverSwapPlan | Requests a pitstop plan for the next driver in a team session from the AI Race Engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *DriverSwapPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend* or *StrategyCancel*.

Note: For convenience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

### Important preparation for the Pitstop MFD handling

Simulator Controller must *understand* the current choices and the available settings in the Pitstop MFD, before any changes can be made automatically. There are two different methods available for this task:

  1. The first method does not need any special preparation from your side. It uses a kind of fuzzy option walk, where the cursor in the Pitstop MFD jumps wildly around and it looks like that the settings are changed randomly. But in the end, everything will be dialed as expected. The *learned* structure will be kept in memory for the next 60 seconds, plenty of time for all changes using your Button Box or by the Race Engineer. After this period, the *learning* walk will happen again, since it might be possible that you changed something in between without the *knowledge* of Simulator Controller. This method is used by default from now on and is **strongly** recommended, but you might take a look at the second method below.
  
  It is possible in very rare situations or when you have accidently interfered using the keyboard yourself, while the option walk is running, that the search for the current pitstop settings get stucked in an endless loop. Holding down the Control key will restart the process in this case.
  
  2. [Deprecated] The drawback of the approach using the option walk, is that the jumping cursor might be a little bit irritating. Therefore a second method is available, which has been around for a long time before the option walk. But this method, which uses image recognition to detect the structure and the current choices of the Pitstop MFD, might need a special preparation from your side.

     In order to *understand* the Pitstop MFD state of *Assetto Corsa Competizione*, Simulator Controller searches for small picture elements in the graphics of the game window. 

     ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Pit%20Strategy%201.JPG)     ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Compound%201.JPG)     ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Select%20Driver%202.jpg)

     These pictures are located in the *Resources\Screen Images\ACC folder* in the installation folder of Simulator Controller. They have been taken from a Full HD triple screen setup (5760 * 1080) using the English language setting in *Assetto Corsa Competizione*. If you are running a different resolution or, even more important, are using a different language, the search for these pictures will fail. But there is help, since you can provide your own pictures by placing your own ones with identical names in the *Simulator Controller\Screen Images\ACC* folder in your user *Documents* folder. Use the Snipping Tool of Windows to create all the necessary pictures, it will only take a few minutes. It is important, that you choose identical names as the originals for your versions of the picture files. While testing your images, you will find information about the images found (or not found) in the "Simulator Controller Logs.txt" file located in the *Logs* folder in your user *Documents* folder. If you set the log level to "Information" in the configuration (see [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-general) on how to do this), you will even get more information in the logs.
	 
     Note: You may use the Windows print screen command to generate a full screen picture of the ACC window and then open this screenshot with "Paint" and grab the pictures using the Snipping Tool. But you will introduce the double amount of compression artefacts into the pictures, since JPG does not use a losslesss compression. This may lead to recognition errors. The preferred method is to switch between the Snipping Tool and ACC back and forth using Alt-Tab and take the pictures single by single.

     Hint: The "Select Driver" option might only be available in special multiuser server setups or custom single user races, whereas the "Strategy" option is available in almost every session.

     Note: The picture search will initially take some time, but the algorithm will learn the position of the Pitstop MFD during the initial run. Depending on your screen size and resolution the initial search will consume quite some CPU cycles. Therefore I advice to open the Pitstop MFD using one of the mode actions above once you are driving in a safe situation, to avoid lags later on. Simulator Controller will learn the position and will only search the much reduced screen area from now on and the CPU load will be 10 times less than before.

     If you haven't taken the pictures or the system have trouble identifying the objects on the screen, Simulator Controller will use a fallback mechanism. You will hear the short standard Windows sound for errors three times to inform you that the picture search has failed, the first time Simulator Controller wants to tweak the pitstop settings and you may hear a single error sound now and then in subsequent tries. And you will find corresponding information in the "Simulator Controller Logs.txt" file located in the *Logs* folder in your user *Documents* folder. Since the fallback mechanism has no understanding of the actual structure and current selections of the Pitstop MFD, it will use a reasonable set of available settings and will navigate accordingly. To be precise, it works only for Dry tyres (since only then the Tyre Set option is available), it will assume that refueling is possible, that tyre change is selected, but brake change is deselected. It will also assume, that the "Select Driver" option is available, as this is the typical layout in an endurance race. For a single user race, refueling and tyre pressure selection will still function correctly, but repair options will be off by one in this case. But be aware, if any of the above conditions are not met, the selection of pitstop settings may fail. Therefore I strongly recommend, that you create the search pictures as described above.

     Last note: On our Discord server (https://discord.gg/5N8JrNr48H), there is a small tool in the channel #tools-and-fixes available, with which you can test, whether all your pictures can be be found.

If you have come so far in your reading and still want to use the image recognition method, because the jumping cursor disturbes you to much, you must do the following: Open the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) and insert and check the setting "Pitstop: Image Search" for the *Assetto Corsa Competizione* simulator. And, of course, you have to create all search images.

## Plugin *AC*

This plugin handles starting and stopping of the *Assetto Corsa* simulation game. An application with the name "Assetto Corsa" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startAC" as a special function hook in this configuration, and set the window title to "ahk_exe acs.exe". An integration with Jona is available through the "Race Engineer" plugin.

### Mode *Pitstop*

Similar to the pitstop mode the plugin for *Assetto Corsa Competizione*, you can control most of the pitstop settings of *Assetto Corsa*. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2013.JPG)

All this will be achieved using the following plugin arguments:

	openPitstopMFD: {Down};
	pitstopCommands: Refuel Dial.1 5, TyreAllAround Dial.2, PitstopPlan Button.1, PitstopPrepare Button.5,
					 TyreCompound Button.2 Button.6, BodyworkRepair Button.3, SuspensionRepair Button.4, EngineRepair Button.7

### Mode *Assistant*

This mode allows you to group all the available actions of the active Race Assistants into one layer of controls on your hardware controller. Although all these actions are also available as plugin actions of the "Race Engineer" plugin, it may be more practicle to use the "Assistant" mode, when your set of available hardware controls is limited, since plugin actions always occupy a given control.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2014.JPG)

The above will be achieved using the following plugin argument:

	assistantCommands: InformationRequest TyrePressures Button.1, InformationRequest TyreTemperatures Button.2,
					   InformationRequest LapsRemaining Button.3, InformationRequest Weather Button.4,
					   Accept Button.7, Reject Button.8

Note: You can use all these commands in the *pitstopCommands* list as well, which will generate one giant controller mode.

### Configuration

Use the *...Option* and *...Choice* parameters to specify the keys, that will be send to *Assetto Corsa* to control the Pitstop MFD. These parameters are defaulted to "{Up}", "{Down]", "{Left}", "{Right]" and the default for *openHotkey* is "{Down}". All these are the default bindings of *Assetto Corsa*, so you won't have to supply them normally.

	openPitstopMFD: *openHotkey*;
	previousOption: *previousOptionHotkey*; nextOption: *nextOptionHotkey*;
	previousChoice: *previousChoiceHotkey*; nextChoice: *nextChoiceHotkey*;
	pitstopMFDMode: Event | Input | Play | Raw | Default

The parameter *pitstopMFDMode* determines, how the communication to the simulator is handled. You can try different values for this parameter, if the Pitstop MFD does not open. Simulator Controller simulates keyboard input for the simulator and there are different ways to do that. These are named "Event", Input", "Play", "Raw" and "Default". For whatever reason, there is not the one method, which works for every Windows installation. For me, "Event" works best and is therefore the standard, if you don't supply the parameter.

As a special case, you can provide "Off" as the argument to *openPitstopMFD*. This will disable the opening and thereby the complete control of the Pitstop MFD. The software, and especially the *Race Assistants* still *think*, that the pitstop settings had been changed, which is helpful, if you only want to get the target settings by voice, but want to dial them into the Pitstop MFD by your own.
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Strategy | Choose one of the predefined pitstop strategies. |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| NoRefuel | Sets the refuel amount to zero, thereby skipping refueling. |
| TyreCompound | Cycles through the available tyre compounds. The leftmost position disables tyre change completely. |
| TyreAllAround | Change the pressure for all tyres at once. Supports the additional increments argument. |
| TyreFrontLeft | Change the pressure for the front left tyre. Supports the additional increments argument. |
| TyreFrontRight | Change the pressure for the front right tyre. Supports the additional increments argument. |
| TyreRearLeft | Change the pressure for the rear left tyre. Supports the additional increments argument. |
| TyreRearRight | Change the pressure for the rear right tyre. Supports the additional increments argument. |
| SuspensionRepair | Toggles the repair of the suspension components. |
| BodyworkRepair | Toggles the repair of all the bodywork. |
| EngineRepair | Toggles the repair of the engine. |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

Note: Be careful, when you change pitstop settings while Jona is active, the Race Engineer will at least be very confused. There is one notable exception, if Jona has planned and prepared a pitstop, but this pitstop has not been carried out yet, every change to the pitstop settings using the "Pitstop" mode will be recognized and taken into account by Jona in the *Assetto Corsa* simulation.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, StrategyCancel *function*,
					   PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported Assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your Race Assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| FCYRecommend | This command can be triggered, when the track is under Full Course Yellow with pitstops allowed. The Race Strategist will then check whether a pitstop under full course yellow will have a strategical benefit.  |
| PitstopRecommend | Asks the AI Race Strategist for a recommendation for the next pitstop. |
| StrategyRecommend | Asks the AI Race Strategist to [recalculate and adjust the strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist#strategy-handling) based on the currently active strategy and the current race situation. Very useful after an unplanned pitstop. |
| StrategyCancel | Asks the AI Race Strategist to drop the currently active strategy. |
| PitstopPlan | Requests a pitstop plan from the AI Race Engineer. |
| DriverSwapPlan | Requests a pitstop plan for the next driver in a team session from the AI Race Engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *DriverSwapPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend* or *StrategyCancel*.

Note: For convenience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

### Installation of the *Assetto Corsa* data interface

For *Assetto Corsa*, you need to install a plugin into a special location for everything to work. Take a look [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#installation-of-telemetry-providers) for installation instructions.

### Special requirements when using the Pitstop automation

*Assetto Corsa* does not provide any information about the current available settings in the Pitstop HUD and their corresponding car specific value range. And, since *Assetto Corsa* is open to modding, the list of cars is potentially endless. Therefore, you may have to provide a couple of information for the car in use, so that the pitstop automation will function correctly, when contolled by the AI Race Engineer or using the Pitsop mode on your hardware controller. I will compile a list of meta data for all the standard cars over time, when they are added to "Setup Workbench" (you can check whether the meta data for a specific car is already there in the file *Resources\Simulator Data\AC\Car Data.ini*, which resides in the programm directory. Unless a car is already known there in the "[Pitstop Settings]" section, you will have to enter the values mentioned below into the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) tool, as long as the defaults does not fit. As an alternative, you can create your own "Car Data.ini" file and place it in the *Simulator Controller\Simulator Data\AC* folder which resides in your user *Documents* folder. By the way, the same applies for tyre data as well, using the file ["Tyre Data.ini"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds#tyre-data-files), where the available tyre compounds for a given car are defined.

  1. Minimum cold tyre pressure
  
     The cold tyre pressures vary between the cars. When tyre pressures are set by the Race Engineer, the lowest possible tyre pressure must be known. The default here is **15** PSI for each tyre. The settings in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) tool are named "Pitstop: Minimum Pressure Front Left" and so on. You will have enter the values for each individual car you use in the *Assetto Corsa* simulation.
	 
  2. Additional pitstop settings
  
     Some cars provide additional settings in the Pitstop HUD, for example front wing settings for a F1 car. These are inserted between the tyre pressure section and the repair section, when they are available. It is necessary to know the number of additional settings, that are present, so that the navigation between the settings will function correctly. You will have to provide the number of additional settings (the defaukt here is **0**, obviously) using "Pitstop: # Car Specific Settings" in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) tool.

## Plugin *IRC*

This plugin handles starting and stopping of the *iRacing* simulation game. An application with the name "iRacing" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please locate the "iRacingUI.exe" application (in a subfolder named "ui"), set "ahk_exe iRacingSim64DX11.exe" as the window title and "startIRC" as a special function hook in this configuration. An integration with Jona is available through the "Race Engineer" plugin, an integration with Cato through the plugin "Race Strategist", and an integration with Elisa through the plugin "Race Spotter".

### Mode *Pitstop*

Similar to the pitstop mode the plugin for *Assetto Corsa Competizione*, you can control most of the pitstop settings of *iRacing*. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2010.JPG)

All this will be achieved using the following plugin arguments:

	togglePitstopFuelMFD: {F4}; togglePitstopTyreMFD: {F5};
	pitstopCommands: Refuel Dial.1 5, TyreAllAround Dial.2, PitstopPlan Button.1, PitstopPrepare Button.5,
					 TyreChange Button.2 Button.5, RepairRequest Button.3 Button.7

### Mode *Assistant*

This mode allows you to group all the available actions of the active Race Assistants into one layer of controls on your hardware controller. Although all these actions are also available as plugin actions of the "Race Engineer" and "Race Strategist" plugins, it may be more practicle to use the "Assistant" mode, when your set of available hardware controls is limited, since plugin actions always occupy a given control.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2012.JPG)

The above will be achieved using the following plugin argument:

	assistantCommands: InformationRequest Position Button.1, InformationRequest LapTimes Button.2,
					   InformationRequest LapsRemaining Button.3, InformationRequest Weather Button.4,
					   InformationRequest GapToAhead Standings Button.5, InformationRequest GapToBehind Standings Button.6,
					   Accept Button.7, Reject Button.8

Note: You can use all these commands in the *pitstopCommands* list as well, which will generate one giant controller mode.

### Configuration

First, you can define+ how to open and close the different Pitstop MFDs (aka Black Boxes) in *iRacing*. This is actually optional, since the menu have not to be open for the control of the pitstop settings. Please supply the bindings you have defined in the "Controls" setup in *iRacing*.

	togglePitstopFuelMFD: *toggleHotkey*; togglePitstopTyreMFD: *toggleHotkey*;
	pitstopMFDMode: Event | Input | Play | Raw | Default

If the opening of the Pitstop MFD for *iRacing* is requested without specifying which type of MFD is meant (for example by calling the controller action *openPitstopMFD* without specifying the optional argument for the *descriptor* parameter), the MFD for the fuel settings will be opened.

The parameter *pitstopMFDMode* determines, how the communication to the simulator is handled. You can try different values for this parameter, if the Pitstop MFD does not open. Simulator Controller simulates keyboard input for the simulator and there are different ways to do that. These are named "Event", Input", "Play", "Raw" and "Default". For whatever reason, there is not the one method, which works for every Windows installation. For me, "Event" works best and is therefore the standard, if you don't supply the parameter.

If the opening of the Pitstop MFD for *iRacing* is requested without specifying which type of MFD is meant (for example by calling the controller action *openPitstopMFD* without specifying the optional argument for the *descriptor* parameter), the MFD for the fuel settings will be opened.

As a special case, you can provide "Off" as the argument to *togglePitstopFuelMFD* or *togglePitstopTyreMFD*. This will disable the opening and thereby the complete control of the Pitstop MFD. The software, and especially the *Race Assistants* still *think*, that the pitstop settings had been changed, which is helpful, if you only want to get the target settings by voice, but want to dial them into the Pitstop MFD by your own.
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| NoRefuel | Sets the refuel amount to zero, thereby skipping refueling. |
| TyreChange | Toggles, whether tyres will be changed at the pitstop. |
| TyreChangeFrontLeft | Toggles, whether the front left tyre will be changed at the pitstop. |
| TyreChangeFrontRight | Toggles, whether the front right tyre will be changed at the pitstop. |
| TyreChangeRearLeft | Toggles, whether the rear left tyre will be changed at the pitstop. |
| TyreChangeRearRight | Toggles, whether the rear right tyre will be changed at the pitstop. |
| TyreCompound | Cycles through the available tyre compounds. |
| TyreAllAround | Change the pressure for all tyres at once. Supports the additional increments argument. |
| TyreFrontLeft | Change the pressure for the front left tyre. Supports the additional increments argument. |
| TyreFrontRight | Change the pressure for the front right tyre. Supports the additional increments argument. |
| TyreRearLeft | Change the pressure for the rear left tyre. Supports the additional increments argument. |
| TyreRearRight | Change the pressure for the rear right tyre. Supports the additional increments argument. |
| RepairRequest | Toggles, whether repairs will be carried out during the next pitstop.  |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

Note: Be careful, when you change pitstop settings while Jona is active, the Race Engineer will at least be very confused.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, StrategyCancel *function*,
					   PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported Assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your Race Assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| FCYRecommend | This command can be triggered, when the track is under Full Course Yellow with pitstops allowed. The Race Strategist will then check whether a pitstop under full course yellow will have a strategical benefit.  |
| PitstopRecommend | Asks the AI Race Strategist for a recommendation for the next pitstop. |
| StrategyRecommend | Asks the AI Race Strategist to [recalculate and adjust the strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist#strategy-handling) based on the currently active strategy and the current race situation. Very useful after an unplanned pitstop. |
| StrategyCancel | Asks the AI Race Strategist to drop the currently active strategy. |
| PitstopPlan | Requests a pitstop plan from the AI Race Engineer. |
| DriverSwapPlan | Requests a pitstop plan for the next driver in a team session from the AI Race Engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *DriverSwapPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend* or *StrategyCancel*.

Note: For convenience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

### Special notes for *iRacing*

*iRacing* does not provide tyre pressure data in the API while you are out on the track and any calculation of cold pressures for changing tyres will end up in a desaster. Therefore, the handling of tyres during pitstop is disabled by default for the Race Engineer. You can change that using a setting in the "Session Database", but then be sure to check the pressures.

## Plugin *RF2*

This plugin handles the *rFactor 2* simulation game. An application with the name "rFactor 2" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startRF2" as a special function hook in this configuration. The plugin supports a "Pitstop" mode to control the pitstop settings and an integration with Jona is available through the "Race Engineer" plugin, an integration with Cato through the plugin "Race Strategist", and an integration with Elisa through the plugin "Race Spotter".

Important: You must install a plugin into *rFactor 2* plugins directory ([rF2]\Bin64\Plugins\) for the telemetry interface and the pitstop mode to work. You can find the plugin in the *Utilities\3rd Part\rf2_sm_tools_3.7.14.2.zip*. Take a look [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#installation-of-telemetry-providers) for installation instructions.

### Mode *Chat*

The mode "Chat" binds all the configured chat messages to buttons on your controller hardware. The chat messages can be defined in the [Chat tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-chat). The messages will be only availabe in a multiuser race scenario, since "rFactor 2" activates the chat system only there.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%205.JPG)

### Mode *Pitstop*

Similar to the pitstop mode the plugin for *Assetto Corsa Competizione*, you can control most of the pitstop settings of *rFactor 2*. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%208.JPG)

All this will be achieved using the following plugin arguments:

	openPitstopMFD: p; closePitstopMFD: p;
	pitstopCommands: Refuel Dial.1 5, TyreAllAround Dial.2, PitstopPlan Button.1, PitstopPrepare Button.5,
					 TyreCompound Button.2 Button.6, RepairRequest Button.3 Button.7, DriverSelect Button.4 Button.8

### Mode *Assistant*

This mode allows you to group all the available actions of the active Race Assistants into one layer of controls on your hardware controller. Although all these actions are also available as plugin actions of the "Race Engineer" and "Race Strategist" plugins, it may be more practicle to use the "Assistant" mode, when your set of available hardware controls is limited, since plugin actions always occupy a given control.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2012.JPG)

The above will be achieved using the following plugin argument:

	assistantCommands: InformationRequest Position Button.1, InformationRequest LapTimes Button.2,
					   InformationRequest LapsRemaining Button.3, InformationRequest Weather Button.4,
					   InformationRequest GapToAhead Standings Button.5, InformationRequest GapToBehind Standings Button.6,
					   Accept Button.7, Reject Button.8

Note: You can use all these commands in the *pitstopCommands* list as well, which will generate one giant controller mode.

### Configuration

First, you can define, how to open and close the Pitstop MFD (aka HUD) in *rFactor 2*. This is actually optional, since the menu have not to be open for the control of the pitstop settings. If you want to use the "PitstopRequest" controller action (see below), supply an argument for *requestPitstop*. Please supply the bindings you have defined in the controller setup in *rFactor 2*.

	openPitstopMFD: *openHotkey*; closePitstopMFD: *closeHotkey*; requestPitstop: *requestPitstopHotkey*;
	openChat: *openChatHotkey*;
	pitstopMFDMode: Event | Input | Play | Raw | Default

The parameter *pitstopMFDMode* determines, how the communication to the simulator is handled. You can try different values for this parameter, if the Pitstop MFD does not open. Simulator Controller simulates keyboard input for the simulator and there are different ways to do that. These are named "Event", Input", "Play", "Raw" and "Default". For whatever reason, there is not the one method, which works for every Windows installation. For me, "Event" works best and is therefore the standard, if you don't supply the parameter.

As a special case, you can provide "Off" as the argument to *openPitstopMFD*. This will disable the opening and thereby the complete control of the Pitstop MFD. The software, and especially the *Race Assistants* still *think*, that the pitstop settings had been changed, which is helpful, if you only want to get the target settings by voice, but want to dial them into the Pitstop MFD by your own. In all other cases, it is strongly recommended to supply at least the key code for opening the Pitstop MFD. Although it is technically possible to leave the MFD closed, while changes are applied to the pitstop settings, it has been reported that this can lead to errors.

If you want to use the "Chat" mode, you have to define the key, which activates the chat entry field in *Le Mans Ultimate* using the *openChat* parameter. The key "t" is the typical default in *Le Mans Ultimate* for this command binding by the way.
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| NoRefuel | Sets the refuel amount to zero, thereby skipping refueling. |
| TyreCompound | Cycles through the available tyre compounds. |
| TyreCompoundFront | Cycles through the available tyre compounds for the front axle. |
| TyreCompoundRear | Cycles through the available tyre compounds for the rear axle. |
| TyreAllAround | Change the pressure for all tyres at once. Supports the additional increments argument. |
| TyreFrontLeft | Change the pressure for the front left tyre. Supports the additional increments argument. |
| TyreFrontRight | Change the pressure for the front right tyre. Supports the additional increments argument. |
| TyreRearLeft | Change the pressure for the rear left tyre. Supports the additional increments argument. |
| TyreRearRight | Change the pressure for the rear right tyre. Supports the additional increments argument. |
| DriverSelect | Selects the driver for the next stint in a multiplayer team race. |
| RepairRequest | Cycles through the available repair options. |
| PitstopRequest | Requests or unrequests a pitstop. |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

Note: Be careful, when you change pitstop settings while Jona is active, the Race Engineer will at least be very confused. There is one notable exception, if Jona has planned and prepared a pitstop, but this pitstop has not been carried out yet, every change to the pitstop settings using the "Pitstop" mode will be recognized and taken into account by Jona in the *rFactor 2* simulation.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, StrategyCancel *function*,
					   PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported Assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your Race Assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| FCYRecommend | This command can be triggered, when the track is under Full Course Yellow with pitstops allowed. The Race Strategist will then check whether a pitstop under full course yellow will have a strategical benefit.  |
| PitstopRecommend | Asks the AI Race Strategist for a recommendation for the next pitstop. |
| StrategyRecommend | Asks the AI Race Strategist to [recalculate and adjust the strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist#strategy-handling) based on the currently active strategy and the current race situation. Very useful after an unplanned pitstop. |
| StrategyCancel | Asks the AI Race Strategist to drop the currently active strategy. |
| PitstopPlan | Requests a pitstop plan from the AI Race Engineer. |
| DriverSwapPlan | Requests a pitstop plan for the next driver in a team session from the AI Race Engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *DriverSwapPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend* or *StrategyCancel*.

Note: For convenience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

### Installation of the *rFactor 2* data interface

For *rFactor 2*, you need to install a plugin into a special location for everything to work. Take a look [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#installation-of-telemetry-providers) for installation instructions.

### Special notes for *rFactor 2*

The *rFactor 2* data API does not provide a car model field and also no dedicated race number for each car. There is only one field that provides a combination of car model, team name, race number and other information. Not all components are there all the time and the format of the field content is not consistent. The "RF2" plugin parses this field and extracts as much information as possible. But it can happen, that several cars with the same race number are on the grid. In this case, the plugin generates synthetical race numbers starting from **1** to keep things working. Also it is possible that the car model is more like the team name and so on. Please blame the developers of *rFactor 2* for this mess.

## Plugin *R3E*

This plugin handles the *RaceRoom Racing Experience* simulation game. An application with the name "RaceRoom Racing Experience" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startR3E" as a special function hook in this configuration and define "ahk_exe RRRE64.exe" (yes, three "R"s) as the window title. The plugin supports a "Pitstop" mode to control the pitstop settings and an integration with Jona is available through the "Race Engineer" plugin, an integration with Cato through the plugin "Race Strategist", and an integration with Elisa through the plugin "Race Spotter".

### Mode *Pitstop*

Similar to the pitstop mode the plugin for *Assetto Corsa Competizione*, you can control most of the pitstop settings of *RaceRoom Racing Experience*. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%209.JPG)

All this will be achieved using the following plugin arguments:

	openPitstopMFD: p; closePitstopMFD: p;
	pitstopCommands: Strategy Dial.1, Refuel Dial.2 5, TyreChange Button.1, BodyworkRepair Button.2, SuspensionRepair Button.3,
					 PitstopPlan Button.7, PitstopPrepare Button.8

### Mode *Assistant*

This mode allows you to group all the available actions of the active Race Assistants into one layer of controls on your hardware controller. Although all these actions are also available as plugin actions of the "Race Engineer" and "Race Strategist" plugins, it may be more practicle to use the "Assistant" mode, when your set of available hardware controls is limited, since plugin actions always occupy a given control.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2012.JPG)

The above will be achieved using the following plugin argument:

	assistantCommands: InformationRequest Position Button.1, InformationRequest LapTimes Button.2,
					   InformationRequest LapsRemaining Button.3, InformationRequest Weather Button.4,
					   InformationRequest GapToAhead Standings Button.5, InformationRequest GapToBehind Standings Button.6,
					   Accept Button.7, Reject Button.8

Note: You can use all these commands in the *pitstopCommands* list as well, which will generate one giant controller mode.

### Configuration

First, you need to define, how to open and close the Pitstop MFD (aka Menu) in *RaceRoom Racing Experience*. Please supply the bindings you have defined in the controller setup in *RaceRoom Racing Experience*.

	openPitstopMFD: *openHotkey*; closePitstopMFD: *closeHotkey*;
	pitstopMFDMode: Event | Input | Play | Raw | Default;
	previousOption: *previousOptionHotkey*; nextOption: *nextOptionHotkey*;
	previousChoice: *previousChoiceHotkey*; nextChoice: *nextChoiceHotkey*;
	acceptChoice: *acceptChoiceHotkey*
	
Use the *...Option* and *...Choice* parameters to specify the keys, that will be send to *RaceRoom Racing Experience* to control the Pitstop MFD. These parameters are defaulted to "w", "s", "a", "d" and "{Enter}", which are the default bindings of *RaceRoom Racing Experience*, so you won't have to supply them normally.

The parameter *pitstopMFDMode* determines, how the communication to the simulator is handled. You can try different values for this parameter, if the Pitstop MFD does not open. Simulator Controller simulates keyboard input for the simulator and there are different ways to do that. These are named "Event", Input", "Play", "Raw" and "Default". For whatever reason, there is not the one method, which works for every Windows installation. For me, "Event" works best and is therefore the standard, if you don't supply the parameter.

As a special case, you can provide "Off" as the argument to *openPitstopMFD*. This will disable the opening and thereby the complete control of the Pitstop MFD. The software, and especially the *Race Assistants* still *think*, that the pitstop settings had been changed, which is helpful, if you only want to get the target settings by voice, but want to dial them into the Pitstop MFD by your own.
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Strategy | Choose one of the predefined pitstop strategies. |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| NoRefuel | Sets the refuel amount to zero, thereby skipping refueling. |
| TyreChange | Toggles, whether you want to change the tyres at the next pitstop or not. |
| TyreChangeFront | Toggles, whether you want to change the front tyres at the next pitstop or not. |
| TyreChangeRear | Toggles, whether you want to change the rear tyres at the next pitstop or not. |
| TyreCompound | Cycles through the available tyre compounds. |
| SuspensionRepair | Toggles the repair of the suspension components. |
| BodyworkRepair | Toggles the repair of all the bodywork and aerodynamic elements. |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

Note: Be careful, when you change pitstop settings while Jona is active, the Race Engineer will at least be very confused.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, StrategyCancel *function*,
					   PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported Assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your Race Assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| FCYRecommend | This command can be triggered, when the track is under Full Course Yellow with pitstops allowed. The Race Strategist will then check whether a pitstop under full course yellow will have a strategical benefit.  |
| PitstopRecommend | Asks the AI Race Strategist for a recommendation for the next pitstop. |
| StrategyRecommend | Asks the AI Race Strategist to [recalculate and adjust the strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist#strategy-handling) based on the currently active strategy and the current race situation. Very useful after an unplanned pitstop. |
| StrategyCancel | Asks the AI Race Strategist to drop the currently active strategy. |
| PitstopPlan | Requests a pitstop plan from the AI Race Engineer. |
| DriverSwapPlan | Requests a pitstop plan for the next driver in a team session from the AI Race Engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *DriverSwapPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend* or *StrategyCancel*.

Note: For convenience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

### Important preparation for the Pitstop MFD handling

Nothing comes for free, and *RaceRoom Racing Experience* does not provide a sophisticated API to externally control the pitstop settings, as *rFactor 2* does. So we also use event automation here, very similar to the [Pitstop MFD control in *Assetto Corsa Competizione*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling). Therefore you also have to create those little pictures, Simulator Controller searches for in order to *understand* the Pitstop MFD state of *RaceRoom Racing Experience*.

These pictures are located in the *Resources\Screen Images\R3E folder* in the installation folder of Simulator Controller. They have been taken from a Full HD triple screen setup (5760 * 1080) using the English language setting in *RaceRoom Racing Experience*. If you are running a different resolution or, even more important, are using a different language, the search for these pictures will fail. But there is help, since you can provide your own pictures by placing your own ones with identical names in the *Simulator Controller\Screen Images\R3E* folder in your user *Documents* folder. Use the Snipping Tool of Windows to create all the necessary pictures, it will only take a few minutes. While testing your images, you will find information about the images found (or not found) in the "Simulator Controller Logs.txt" file located in the *Logs* folder in your user *Documents* folder. If you set the log level to "Information" in the configuration (see [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-general) on how to do this), you will even get more information in the logs.

Note: The picture search will initially take some time, but the algorithm will learn the position of the Pitstop MFD during the initial run. Depending on your screen size and resolution the initial search will consume quite some CPU cycles. Therefore I advice to open the Pitstop MFD using one of the mode actions above once you are driving in a safe situation, to avoid lags later on. Simulator Controller will learn the position and will only search the much reduced screen area from now on and the CPU load will be 10 times less than before.

Second note: The image search algorithm used here is as good as it can be. But unfortunately, the Pitstop MFD in *RaceRoom Racing Experience* has very low contrast differences in several places, other than the Pitstop MFD of *Assetto Corsa Competizione*, Therefore, it is possible from time to time, that the search will yield false positives, which in the end will lead to false values and choices entered into fields of the Pitstop MFD. So please always double check, that everything is correct, before entering the pit lane.

Last note: On our [Discord server](https://discord.gg/5N8JrNr48H), there is a small tool in the channel #tools-and-fixes available, with which you can test, whether all your pictures can be be found.

## Plugin *AMS2*

This plugin handles the *Automobilista 2* simulation game. An application with the name "Automobilista 2" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startAMS2" as a special function hook in this configuration and "ahk_exe AMS2AVX.exe" as the window title.

Important: So that the telemetry data can be accessed, the shared memory interface must be activated in the settings of *Automobilista 2* in the "PCars 2" mode.

The plugin supports a "Pitstop" mode to control the pitstop settings and an integration with Jona is available through the "Race Engineer" plugin, and an integration with Cato through the plugin "Race Strategist", and an integration with Elisa through the plugin "Race Spotter".

### Mode *Pitstop*

Similar to the pitstop mode the plugin for *Assetto Corsa Competizione*, you can control most of the pitstop settings of *Automobilista 2*. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2011.JPG)

All this will be achieved using the following plugin arguments:

	openPitstopMFD: i; previousOption: z; nextOption: h; previousChoice: g; nextChoice: j;
	pitstopCommands: Refuel Dial.2 5, TyreCompound Button.1, BodyworkRepair Button.2, SuspensionRepair Button.3

### Mode *Assistant*

This mode allows you to group all the available actions of the active Race Assistants into one layer of controls on your hardware controller. Although all these actions are also available as plugin actions of the "Race Engineer" and "Race Strategist" plugins, it may be more practicle to use the "Assistant" mode, when your set of available hardware controls is limited, since plugin actions always occupy a given control.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2012.JPG)

The above will be achieved using the following plugin argument:

	assistantCommands: InformationRequest Position Button.1, InformationRequest LapTimes Button.2,
					   InformationRequest LapsRemaining Button.3, InformationRequest Weather Button.4,
					   InformationRequest GapToAhead Standings Button.5, InformationRequest GapToBehind Standings Button.6,
					   Accept Button.7, Reject Button.8

Note: You can use all these commands in the *pitstopCommands* list as well, which will generate one giant controller mode.

### Configuration

First, you need to define, how to open the Pitstop MFD (a part of the In Car Menu, aka ICM) in *Automobilista 2*. "i" is the default value for *openPitstopMFD*, which is **not** the standard binding of *Automobilista 2*. You need to change these bindings in *Automobilista 2*, since the standard bindings are controller buttons, for which unfortunately no events can be generated by software.

	openPitstopMFD: *openHotkey*;
	pitstopMFDMode: Event | Input | Play | Raw | Default;
	previousOption: *previousOptionHotkey*; nextOption: *nextOptionHotkey*;
	previousChoice: *previousChoiceHotkey*; nextChoice: *nextChoiceHotkey*
	
Use the *...Option* and *...Choice* parameters to specify the keys, that will be send to *Automobilista 2* to control the Pitstop MFD. These parameters are defaulted to "z", "h", "g" and "j", which are **not** the default bindings of *Automobilista 2* (see above).

The parameter *pitstopMFDMode* determines, how the communication to the simulator is handled. You can try different values for this parameter, if the Pitstop MFD does not open. Simulator Controller simulates keyboard input for the simulator and there are different ways to do that. These are named "Event", Input", "Play", "Raw" and "Default". For whatever reason, there is not the one method, which works for every Windows installation. For me, "Event" works best and is therefore the standard, if you don't supply the parameter.

As a special case, you can provide "Off" as the argument to *openPitstopMFD*. This will disable the opening and thereby the complete control of the Pitstop MFD. The software, and especially the *Race Assistants* still *think*, that the pitstop settings had been changed, which is helpful, if you only want to get the target settings by voice, but want to dial them into the Pitstop MFD by your own.
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Strategy | Choose one of the predefined pitstop strategies. |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| NoRefuel | Sets the refuel amount to zero, thereby skipping refueling. |
| TyreCompound | Cycles through the available tyre compounds. The leftmost position disables tyre change completely. Only the first 3 positions are supported, typically 1. Slicks, 2. Intermediate or Wets and 3. Automatic |
| SuspensionRepair | Toggles the repair of the suspension components. |
| BodyworkRepair | Toggles the repair of all the bodywork and aerodynamic elements. |
| DriverSwap | Enables or disables driver swap for the upcoming pitstop. |
| PitstopRequest | Requests or unrequests a pitstop. |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

Note: Be careful, when you change pitstop settings while Jona is active, the Race Engineer will at least be very confused.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, StrategyCancel *function*,
					   PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported Assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your Race Assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| FCYRecommend | This command can be triggered, when the track is under Full Course Yellow with pitstops allowed. The Race Strategist will then check whether a pitstop under full course yellow will have a strategical benefit.  |
| PitstopRecommend | Asks the AI Race Strategist for a recommendation for the next pitstop. |
| StrategyRecommend | Asks the AI Race Strategist to [recalculate and adjust the strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist#strategy-handling) based on the currently active strategy and the current race situation. Very useful after an unplanned pitstop. |
| StrategyCancel | Asks the AI Race Strategist to drop the currently active strategy. |
| PitstopPlan | Requests a pitstop plan from the AI Race Engineer. |
| DriverSwapPlan | Requests a pitstop plan for the next driver in a team session from the AI Race Engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *DriverSwapPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend* amd *StrategyCancel*.

Note: For convenience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

### Special requirements when using the Pitstop automation

It is very important, that you do not use the *Automobilista 2* ICM on your own, when you want to control the pitstop settings using the "Pitstop" mode, or if you want Jona to control the pitstop settings. Before the first usage the ICM must be set to the Pitstop page of the ICM and the selection must be set to the bottom line. Furthermore, you must leave *all* repairs selected in the default pitstop strategy and select *no tyre change* in the default pitstop strategy as well. You must also choose the following settings in the *Automobilista 2* configuration:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/AMS2%20Settings.png)

Not complying with this requirements will give you funny results at least.

## Plugin *PCARS2*

This plugin handles the *Automobilista 2* simulation game. An application with the name "Project CARS 2" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startPCARS2" as a special function hook in this configuration and "ahk_exe PCARS2AVX.exe" as the window title.

Important: So that the telemetry data can be accessed, the shared memory interface must be activated in the settings of *Project CARS 2* in the "PCars 2" mode.

The plugin supports a "Pitstop" mode to control the pitstop settings and an integration with Jona is available through the "Race Engineer" plugin, and an integration with Cato through the plugin "Race Strategist", and an integration with Elisa through the plugin "Race Spotter".

### Mode *Pitstop*

Similar to the pitstop mode the plugin for *Automobilista 2*, you can control many of the pitstop settings of *Project CARS 2*. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2011.JPG)

All this will be achieved using the following plugin arguments:

	openPitstopMFD: I; previousOption: Z; nextOption: H; previousChoice: G; nextChoice: J;
	pitstopCommands: Refuel Dial.2 5, TyreCompound Button.1, BodyworkRepair Button.2, SuspensionRepair Button.3

### Mode *Assistant*

This mode allows you to group all the available actions of the active race assistants into one layer of controls on your hardware controller. Although all these actions are also available as plugin actions of the "Race Engineer" and "Race Strategist" plugins, it may be more practicle to use the "Assistant" mode, when your set of available hardware controls is limited, since plugin actions always occupy a given control.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2012.JPG)

The above will be achieved using the following plugin argument:

	assistantCommands: InformationRequest Position Button.1, InformationRequest LapTimes Button.2,
					   InformationRequest LapsRemaining Button.3, InformationRequest Weather Button.4,
					   InformationRequest GapToFront Standings Button.5, InformationRequest GapToBehind Standings Button.6,
					   Accept Button.7, Reject Button.8

Note: You can use all these commands in the *pitstopCommands* list as well, which will generate one giant controller mode.

### Configuration

First, you need to define, how to open the Pitstop MFD (a part of the In Car Menu, aka ICM) in *Project CARS 2*. "I" is the default value for *openPitstopMFD*, which is **not** the standard binding of *Project CARS 2*. You need to change these bindings in *Project CARS 2*, since the standard bindings are undefined in the current distribution of *Project CARS 2*.

	openPitstopMFD: *openHotkey*;
	pitstopMFDMode: Event | Input | Play | Raw | Default;
	previousOption: *previousOptionHotkey*; nextOption: *nextOptionHotkey*;
	previousChoice: *previousChoiceHotkey*; nextChoice: *nextChoiceHotkey*
	
Use the *...Option* and *...Choice* parameters to specify the keys, that will be send to *Project CARS 2* to control the Pitstop MFD. These parameters are defaulted to "Z", "H", "G" and "J", which are **not** the default bindings of *Project CARS 2* (see above).

The parameter *pitstopMFDMode* determines, how the communication to the simulator is handled. You can try different values for this parameter, if the Pitstop MFD does not open. Simulator Controller simulates keyboard input for the simulator and there are different ways to do that. These are named "Event", Input", "Play", "Raw" and "Default". For whatever reason, there is not the one method, which works for every Windows installation. For me, "Event" works best and is therefore the standard, if you don't supply the parameter.

As a special case, you can provide "Off" as the argument to *openPitstopMFD*. This will disable the opening and thereby the complete control of the Pitstop MFD. The software, and especially the *Race Assistants* still *think*, that the pitstop settings had been changed, which is helpful, if you only want to get the target settings by voice, but want to dial them into the Pitstop MFD by your own.
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| NoRefuel | Sets the refuel amount to zero, thereby skipping refueling. |
| TyreCompound | Cycles through the available tyre compounds. The leftmost position disables tyre change completely. Only the first 3 positions are supported, typically 1. Slicks, 2. Intermediate or Wets and 3. Automatic |
| SuspensionRepair | Toggles the repair of the suspension components. |
| BodyworkRepair | Toggles the repair of all the bodywork and aerodynamic elements. |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

Note: Be careful, when you change pitstop settings while Jona is active, the Race Engineer will at least be very confused.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, StrategyCancel *function*,
					   PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your race assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| FCYRecommend | This command can be triggered, when the track is under Full Course Yellow with pitstops allowed. The Race Strategist will then check whether a pitstop under full course yellow will have a strategical benefit.  |
| PitstopRecommend | Asks the AI Race strategist for a recommendation for the next pitstop. This commadn is most useful, when no strategy is currently active. |
| StrategyRecommend | Asks the AI Race Strategist to [recalculate and adjust the strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist#strategy-handling) based on the currently active strategy and the current race situation. Very useful after an unplanned pitstop. |
| StrategyCancel | Asks the AI Race strategist to drop the currently active strategy. |
| PitstopPlan | Requests a pitstop plan from the AI Race engineer. |
| DriverSwapPlan | Requests a pitstop plan for the next driver in a team session from the AI Race Engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the AI Race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the AI Race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *DriverSwapPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend* amd *StrategyCancel*.

Note: For convenience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

### Special requirements when using the Pitstop automation

It is very important, that you do not use the *Project CARS 2* ICM on your own, when you want to control the pitstop settings using the "Pitstop" mode, or if you want Jona to control the pitstop settings. Furthermore, you must leave *all* repairs selected in the default pitstop strategy and select *no tyre change* in the default pitstop strategy as well.

## Plugin *LMU*

This plugin handles the *Le Mans Ultimate* simulation game. An application with the name "Le Mans Ultimate" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startLMU" as a special function hook in this configuration. The plugin supports a "Pitstop" mode to control the pitstop settings and an integration with Jona is available through the "Race Engineer" plugin, an integration with Cato through the plugin "Race Strategist", and an integration with Elisa through the plugin "Race Spotter".

Important: You must install a plugin into *Le Mans Ultimate* plugins directory ([LMU]\Plugins\) for the telemetry interface and the pitstop mode to work. You can find the plugin in the *Utilities\3rd Part\rf2_sm_tools_3.7.14.2.zip*. Take a look [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#installation-of-telemetry-providers) for installation instructions.

### Disclaimer

The *Le Mans Ultimate* game is under heavy development by the studio at the time of this writing. It is marketed as early access and many things are still not working. This also affects the data API and the integration with Simulator Controller. For example, pitstop settings handling is not supported yet and there are problems with driver names and car model names. I will continiously improve on that as far as there are improvements on the side of the *Le Mans Ultimate* data API.

### Mode *Chat*

The mode "Chat" binds all the configured chat messages to buttons on your controller hardware. The chat messages can be defined in the [Chat tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-chat). The messages will be only availabe in a multiuser race scenario, since "Le Mans Ultimate" activates the chat system only there.

### Mode *Pitstop*

Similar to the pitstop mode the plugin for *Assetto Corsa Competizione*, you can control most of the pitstop settings of *Le Mans Ultimate*. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%208.JPG)

All this will be achieved using the following plugin arguments:

	openPitstopMFD: p; closePitstopMFD: p; openChat: t;
	pitstopCommands: Refuel Dial.1 5, TyreAllAround Dial.2, PitstopPlan Button.1, PitstopPrepare Button.5,
					 TyreCompound Button.2 Button.6, RepairRequest Button.3 Button.7, DriverSelect Button.4 Button.8

### Mode *Assistant*

This mode allows you to group all the available actions of the active Race Assistants into one layer of controls on your hardware controller. Although all these actions are also available as plugin actions of the "Race Engineer" and "Race Strategist" plugins, it may be more practicle to use the "Assistant" mode, when your set of available hardware controls is limited, since plugin actions always occupy a given control.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2012.JPG)

The above will be achieved using the following plugin argument:

	assistantCommands: InformationRequest Position Button.1, InformationRequest LapTimes Button.2,
					   InformationRequest LapsRemaining Button.3, InformationRequest Weather Button.4,
					   InformationRequest GapToAhead Standings Button.5, InformationRequest GapToBehind Standings Button.6,
					   Accept Button.7, Reject Button.8

Note: You can use all these commands in the *pitstopCommands* list as well, which will generate one giant controller mode.

### Configuration

First, you can define, how to open and close the Pitstop MFD (aka HUD) in *Le Mans Ultimate*. This is actually optional, since the menu have not to be open for the control of the pitstop settings. If you want to use the "PitstopRequest" controller action (see below), supply an argument for *requestPitstop*. Please supply the bindings you have defined in the controller setup in *Le Mans Ultimate*.

	openPitstopMFD: *openHotkey*; closePitstopMFD: *closeHotkey*; requestPitstop: *requestPitstopHotkey*;
	openChat: *openChatHotkey*;
	pitstopMFDMode: Event | Input | Play | Raw | Default

The parameter *pitstopMFDMode* determines, how the communication to the simulator is handled. You can try different values for this parameter, if the Pitstop MFD does not open. Simulator Controller simulates keyboard input for the simulator and there are different ways to do that. These are named "Event", Input", "Play", "Raw" and "Default". For whatever reason, there is not the one method, which works for every Windows installation. For me, "Event" works best and is therefore the standard, if you don't supply the parameter.

As a special case, you can provide "Off" as the argument to *openPitstopMFD*. This will disable the opening and thereby the complete control of the Pitstop MFD. The software, and especially the *Race Assistants* still *think*, that the pitstop settings had been changed, which is helpful, if you only want to get the target settings by voice, but want to dial them into the Pitstop MFD by your own.

If you want to use the "Chat" mode, you have to define the key, which activates the chat entry field in *Le Mans Ultimate* using the *openChat* parameter. The key "t" is the typical default in *Le Mans Ultimate* for this command binding by the way.
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| NoRefuel | Sets the refuel amount to zero, thereby skipping refueling. |
| TyreCompound | Cycles through the available tyre compounds for all tyres. |
| TyreCompoundFrontLeft | Cycles through the available tyre compounds for the front left tyre. |
| TyreCompoundFrontRight | Cycles through the available tyre compounds for the front right tyre. |
| TyreCompoundRearLeft | Cycles through the available tyre compounds for the rear left tyre. |
| TyreCompoundRearRight | Cycles through the available tyre compounds for the rear right tyre. |
| TyreAllAround | Change the pressure for all tyres at once. Supports the additional increments argument. |
| TyreFrontLeft | Change the pressure for the front left tyre. Supports the additional increments argument. |
| TyreFrontRight | Change the pressure for the front right tyre. Supports the additional increments argument. |
| TyreRearLeft | Change the pressure for the rear left tyre. Supports the additional increments argument. |
| TyreRearRight | Change the pressure for the rear right tyre. Supports the additional increments argument. |
| DriverSelect | Selects the driver for the next stint in a multiplayer team race. |
| SuspensionRepair | Toggles the repair of the suspension components. |
| BodyworkRepair | Toggles the repair of all the bodywork. |
| BrakeChange | Toggles the replacement of the brake pads. |
| PitstopRequest | Requests or unrequests a pitstop. |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

Note: Be careful, when you change pitstop settings while Jona is active, the Race Engineer will at least be very confused. There is one notable exception, if Jona has planned and prepared a pitstop, but this pitstop has not been carried out yet, every change to the pitstop settings using the "Pitstop" mode will be recognized and taken into account by Jona in the *Le Mans Ultimate* simulation.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, StrategyCancel *function*,
					   PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported Assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your Race Assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| FCYRecommend | This command can be triggered, when the track is under Full Course Yellow with pitstops allowed. The Race Strategist will then check whether a pitstop under full course yellow will have a strategical benefit.  |
| PitstopRecommend | Asks the AI Race Strategist for a recommendation for the next pitstop. |
| StrategyRecommend | Asks the AI Race Strategist to [recalculate and adjust the strategy](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist#strategy-handling) based on the currently active strategy and the current race situation. Very useful after an unplanned pitstop. |
| StrategyCancel | Asks the AI Race Strategist to drop the currently active strategy. |
| FuelRatioOptimize | Requests a recalcualtion of the fuel ratio by the AI Race Engineer. |
| PitstopPlan | Requests a pitstop plan from the AI Race Engineer. |
| DriverSwapPlan | Requests a pitstop plan for the next driver in a team session from the AI Race Engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the AI Race Assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *DriverSwapPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend* or *StrategyCancel*.

Note: For convenience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

### Installation of the *Le Mans Ultimate* data interface

For *Le Mans Ultimate*, you need to install a plugin into a special location for everything to work. Take a look [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#installation-of-telemetry-providers) for installation instructions.

### Special notes for *Le Mans Ultimate*

1. The *Le Mans Ultimate* shared memory API (inherited from *rFactor 2*) does not provide a car model field and also no dedicated race number for each car. There is only one field that provides a combination of car model, team name, race number and other information. Not all components are there all the time and the format of the field content is not consistent. The "LMU" plugin parses this field and extracts as much information as possible. But it can happen, that several cars with the same race number are on the grid. In this case, the plugin generates synthetical race numbers starting from **1** to keep things working. Please blame the developers of *rFactor 2* and *Le Mans Ultimate* for this mess.

2. *Le Mans Ultimate* currently does not support driver swaps, although it has already been announced for an upcoming release. The "DriverSelect" action therefore does nothing.

3. It sometimes happens that driver names contain corrupt characters. Looks like a different interpretation of character codings inherited by the *rFactor 2* data API.

4. As usual, the Race Engineer calculates the energy fill up of an upcoming pitstop based on the fuel consumption of the recent laps.

   - For Hypercars and LMGT3 cars the following applies:

     When the Engineer announces the amount of fuel to be added for the next pitstop, the fuel amount will be divided by the *fuel ratio* as currently set in the pitstop menu of the HUD, before being used as the value for the virtual energy replenishment. So make sure, that your *fuel ratio* setting is as desired at the time, when the pitstop settings are changed.

     Note: The *fuel ratio* implicitely includes the max fuel the car can carry, since the value can be greater than 1. Confusing, isn't it. This has the following implications at the moment:
   
       - The fuel ratio normally contain a certain amount of safety fuel, that assure that you will not run out of fuel with 100% energy consumption. But make sure you pit before dropping virtual energy to 0%. You can recalibrate the fuel ratio once you have driven a few laps using the "FuelRatioOptimize" action or the corresponding voice command of the Race Engineer. This will use your current fuel consumption for every 1% virtual energy plus the safety fuel specified in the settings to compute an optimal fuel ratio.
	 
	   - When working with the ["Setup Workbench"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench), it is important to set the max fuel the car can carry to fulfill the virtual energy constraints, which will be lower than the fuel capacity of the car on most tracks. Otherwise you will end up with strategies, which might be against the rules of the WEC. You can set the fuel capacity in the "Session Database" for a given car / track combination, once you have dialed your numbers (it may have been set there already for you by the Assistants, but be sure to correct the value, once you have found a perfect fuel ratio). Then use the "Initialize from Database" command in the "Session" menu of "Setup Workbench", before you simulate your strategy.

     Another important aspect of the virtual energy system is that the setting in the pitstop menu of *Le Mans Ultimate* does not define how much energy has to be added at the next pitstop, but instead specifies the energy amount that will be available, when you leave the pit. This will be taken automatically into account when the refuel amount is calculated, but this is only correct at the current lap. So don't wait too long before you go to the pit or let the Engineer create a new pitstop plan, just before coming to the pit.
   
     When running on a pre-defined strategy, refueling calculation works a bit different. The Strategist and the Engineer will tell you the lap you have to come in. The calculation of the virtual energy will be exact for this particular lap. Of course you can come in later, if you have still some virtual energy left, but then you may have to correct the virtual energy level by this number of laps, at least if the next stint will be your last one.
	 
	 Said all that, please take a look at the [setting "Engineer: Adjust refuel amount after prepare"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) of the "Session Database". Using this setting will allow you to auto-correct the refuel amount in those situations, but this might have other drawbacks.

   - LMP2 and GTE cars have a *classical* fuel capacity, so virtual energy and fuel ratio does not apply here. Nevertheless, the way the refueling calculation works, is the same as for Hypercars and LMGT3s. This means, that the calculation made by the Engineer is based on the amount of fuel to be added, whereas the pitstop menu specifies the amount of fuel in the tank, when the car leaves the pit. Conversion between these two models are automatic, but you may also want to take a look at the [setting "Engineer: Adjust refuel amount after prepare"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings) of the "Session Database", as discussed above.

5. Additionally, the Race Engineer can only handle identical tyre compounds for all four tyres and can only change all four tyres together. You may, however adjust this manually once the Engineer has prepared the pitstop. This may change with a future release.

   When the Race Engineer determines the currently mounted tyre compound, he always looks at the front left tyre as a reference.

6. When it comes to tyre compounds, there are also some aspects to consider:
   - Hypercars can use in general four different compounds, Soft, Medium, Hard and Wet, which are mapped to Dry (S), Dry (M), Dry (H) and Wet. But not all compounds may be available in a given season or on a given track. The Engineer on its own, will never change the compound mixture, when changing tyres. If you are using a pre-defined strategy which is handled by the Strategist, be sure to set the tyre set count for those compounds which are not available for the race to zero. This ensures that those tyre compounds will not be used during the race.
   - The available tyre compounds for LMP2, GTE and GT3 are currently restricted to Medium and Wet, whic are mapped to Dry (M) and Wet.

Lastly, the API of *Le Mans Ultimate* is partly based on a shared memory interface as *rFactor 2* and partly on a REST/JSON interface provided by the simulation engine. Especially the later requires a lot of text processing and therefore consumes quite some CPU cycles. Please test in practice sessions, whether your PC can handle all that, before using it in an important race.

## Plugin *Integration*

This plugin, which is normally not automatically included and enabled, can export the internal state of Simulator Controller - especially a lot of the knowledge of all Race Assistants and plenty of information about the currently running simulator session - to other applications using a JSON file.

To activate this plugin, add it to the list of active plugins in "Simulator Configuration", or, of you are using only the "Simulator Setup" wizard for your configuration work, add the following line to the ["Configuration Patch.ini"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#patching-the-configuration) file:

	[Plugins]
	Integration=true||

If you want to use the *stateFile* parameter here (see below), it looks like:

	[Plugins]
	Integration=true||stateFile: D:\SimRacing\Session State.json
	
where *D:\SimRacing\Session State.json* is an example. Substitute your own path here.

### Configuration

Only one plugin argument is provided, with which you can define the output file for the state representation.

	stateFile: *path*

If no argument for *stateFile* is provided, the state info will be put in a file named "Session State.json" in the *Simulator Controller\Temp* folder which resides in your *Documents* folder.

The content of the JSON file looks like this (depending on the current situation, of course):

	{
		"Assistants": {
			"Mode": "Team",
			"Race Engineer": {
				"Muted": false,
				"State": "Active"
			},
			"Race Spotter": {
				"Muted": false,
				"State": "Active"
			},
			"Race Strategist": {
				"Muted": false,
				"State": "Active"
			},
			"Session": "Race"
		},
		"Automation": {
			"Automation": "Dry",
			"Car": "McLaren 720S GT3",
			"Session": "Race",
			"Simulator": "Assetto Corsa Competizione",
			"State": "Active"
		},
		"Brakes": {
			"Temperatures": [
				199.6,
				197.6,
				339.9,
				337.0
			],
			"Wear": [
				2,
				2,
				3,
				3
			]
		},
		"Engine": {
			"WaterTemperature": 92.7,
			"OilTemperature": 85.2
		},
		"Conditions": {
			"AirTemperature": 24.9,
			"Grip": "Optimum",
			"TrackTemperature": 31.4,
			"Weather": "Dry",
			"Weather10Min": "Dry",
			"Weather30Min": "Dry"
		},
		"Damage": {
			"Bodywork": {
				"Front": 0.0,
				"Left": 0.34,
				"Right": 0.0,
				"Rear": 2.72,
				"All": 3.06
			}
			"Suspension": {
				"FrontLeft": 0.0,
				"FrontRight": 0.0,
				"RearLeft": 0.0,
				"RearRight": 0.0
			},
			"Engine": 0.0,
			"LapDelta": 0.3,
			"RepairTime": 2.7
		},
		"Duration": {
			"Format": "Time",
			"SessionLapsLeft": 24,
			"SessionTimeLeft": "54:53,0",
			"StintLapsLeft": 9,
			"StintTimeLeft": "54:53,0"
		},
		"Fuel": {
			"AvgFuelConsumption": 4.1,
			"LastFuelConsumption": 4.1,
			"RemainingFuel": 36.9,
			"RemainingFuelLaps": 9
			"AvgEnergyConsumption": 3.2,
			"LastEnergyConsumption": 3.0,
			"RemainingEnergy": 26.7,
			"RemainingEnergyLaps": 8
		},
		"Pitstop": {
			"State": "Planned",
			"Fuel": 68.0,
			"Lap": null,
			"Driver": "Oliver Juwig",
			"ServiceTime": 30,
			"RepairTime": 7,
			"PitlaneDelta": 23,
			"Number": 1,
			"Prepared": 0,
			"TyreCompound": "Dry (Black)",
			"TyrePressures": [
				25.2,
				25.2,
				24.4,
				24.3
			],
			"TyrePressureIncrements": [0.2, 0.1, -0.3, -0.2],
			"TyreSet": 2,
			"Brakes": false,
			"Repairs": "-"
		},
		"Session": {
			"Car": "McLaren 720S GT3",
			"Session": "Race",
			"Simulator": "Assetto Corsa Competizione",
			"Track": "Circuit de Spa-Franchorchamps",
			"Profile": "Standard"
		},
		"Standings": {
			"Ahead": null,
			"Behind": {
				"Delta": "-0:02,1",
				"InPit": false,
				"LapTime": "2:21,3",
				"Laps": 2,
				"Nr": 109
			},
			"ClassPosition": 1,
			"Focus": {
				"Delta": "-0:15,9",
				"InPit": false,
				"LapTime": "2:24,3",
				"Laps": 2,
				"Nr": 15
			},
			"Leader": null,
			"OverallPosition": 1,
			"Position": 1
		},
		"Stint": {
			"BestTime": null,
			"Driver": "Oliver Juwig (OJU)",
			"Lap": 3,
			"Laps": 2,
			"LastTime": "2:21,3",
			"BestTime": "2:20,7",
			"LastSpeed": 270,8
			"BestSpeed": 272,1
			"Position": 1
		},
		"Strategy": {
			"State": "Active",
			"Fuel": 12.0,
			"Lap": 10,
			"Position": 7,
			"PlannedPitstops": 2,
			"RemainingPitstops": 2,
			"TyreCompound": "Dry (Black)",
			"Pitstops": [
				{
					"Nr": 1,
					"Fuel": 12.0,
					"TyreCompound": "Dry (Black)"
				},
				{
					"Nr": 2,
					"Fuel": 0.0,
					"TyreCompound": null
				}
			]
		},
		"TeamServer": {
			"Driver": "Oliver Juwig",
			"Server": "https:\/\/vgr-teamserver.azurewebsites.net",
			"Session": "24H Spa",
			"Team": "VGR (EOS)",
			"Token": "xxxxxxxx-yyyy-zzzz-aaaa-bbbbbbbbbbbb"
		},
		"Tyres": {
			"HotPressures": [
				26.4,
				26.4,
				26.7,
				26.5
			],
			"ColdPressures": [
				25.3,
				24.9,
				25.1,
				24.5
			],
			"PressureLosses": [
				0.0,
				- 0.1,
				0.0,
				- 0.2
			],
			"Temperatures": [
				80.6,
				80.6,
				91.7,
				91.1
			],
			"Wear": [
				null,
				null,
				null,
				null
			],
			"TyreCompound": "Dry (M)"
			"TyreCompoundFrontLeft": "Dry (M)"
			"TyreCompoundFrontRight": "Dry (S)"
			"TyreCompoundRearLeft": "Dry (M)"
			"TyreCompoundRearRight": "Dry (M)"
			"TyreSet": 3
		},
		"Instructions": {
			"Corner": 3,
			"Hints": [
				{
					"Hint": "BrakeEarlier",
					"Message": "Brake a bit earlier"
				},
				{
					"Hint": "BrakeHarder",
					"Message": "Put more pressure on the brakes"
				},
				{
					"Hint": "AccelerateLater",
					"Message": "Later on the throttle"
				}
			]
		}
	}
	
A special case here is of course the "Instructions" object. This object is present if [corner by corner coaching](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#coaching-on-the-track) by the Driving Coach is currently active. The "Message"* field will have the instruction translated to the language configured for the Driving Coach. If no voice configuration for the Driving Coach is available, "Message" will be *null*.