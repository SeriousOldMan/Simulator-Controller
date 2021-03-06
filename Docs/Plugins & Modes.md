The distribution of Simulator Controller includes a set of predefined plugins, which provide functionalities for (advanced) Simulation Rigs. Some of these plugins provide a sophisticated set of initialization parameters, which can be configured in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool. Below you find an overview and introduction to each plugin and in the following chapters an in depth reference including a description for all initialization parameters.

| Plugin | Description |
| ------ | ------ |
| [System](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-system) | Handles multiple Button Box layers and manages all applications configured for your simulation configuration. This plugin defines the "Launch" mode, where applications my be started and stopped from the controller hardware. These applications can be configured using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). |
| [Button Box](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts) | Tools for building your own Button Box / Controller visuals. The default implementation of *ButtonBox* implements grid based Button Box layouts, which can be configured using a [graphical layout editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts). |
| [Tactile Feedback](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-tactile-feedback) | Fully configurable support for pedal and chassis vibration using [SimHub](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). Simulator Controller comes with a set of predefined SimHub profiles, which may help you to connect and manage your vibration motors and chassis shakers. The plugin provides many initialization parameters to adopt to these profiles. Two modes, "Pedal Vibration" and "Chassis Vibration", are defined, which let you control the different vibration effects and intensities directly from your controller. |
| [Motion Feedback](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-motion-feedback) | Fully configurable support for rig motion feedback using [SimFeedback](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications). The plugin supports two different methods to control SimFeedback. The first uses mouse automation, which is needed, if you don't have the commercial, so called expert license of *SimFeedback*. The second method programmatically connects to SimFeedback with the help of the [SFX-100-Streamdeck](https://github.com/ashupp/SFX-100-Streamdeck) extension. The mode "Motion", which is available for both methods, allows you to enable individal motion effects like "Roll" and "Pitch" and dial in their intensities. |
| [Pedal Calibration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-pedal-calibration) | Allows to choose between the different calibration curves of your high end pedals directly from the hardware controller. The current implementation supports the Heusinkveld *SmartControl* application, but adopting the plugin to a different pedal vendor is quite easy. |
| [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) | This plugin integrates Jona, the Virtual Race Engineer, with all other plugins for the simulation games, like the ACC plugin. The plugin handles the data transfer between the simulation game and the Virtual Race Engineer. |
| [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) | This plugin integrates Cato, the Virtual Race Strategist, with all other plugins for the simulation games, like the ACC plugin. The plugin handles the data transfer between the simulation game and the Virtual Race Strategist. |
| [ACC](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) | Provides special support for starting and stopping *Assetto Corsa Competizione* from your hardware controller. The mode "Chat", which is available when *Assetto Corsa Competizione* is currently running, handle automated chat messages for the multiplayer ingame chat system, where the chat messages can be configured by the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Additionally, beginning with Release 2.0, this plugin provides sophisticated support for the Pitstop MFD of *Assetto Corsa Competizione*. All settings may be tweaked with the controller hardware using the "Pitstop" mode, but it is also possible to control the settings using voice control to keep your hands on the steering wheel. Since Release 2.1, Jona, the Virtual Race Engineer, is integrated with the ACC plugin as well and an integration with Cato, the Virtual Race Strategist exists since Release 3.1.6. The "Assistant" mode can handle most of the race assistant commands from your hardware controller. |
| [AC](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-ac) | One of the smallest plugin in this list only supplies a special splash screem, when *Assetto Corsa* is started. No special controller mode is defined for the moment. |
| [AMS2](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-AMS2) | Also a small plugin in this list only supplies a special splash screem, when *Automobilista 2* is started. An integration with Jona, the Virtual Race Engineer, as well as wtih Cato, the Virtual Race Strategist, is available since Release 3.1.8 and the plugin supports a "Pitstop" mode for adjusting pitstop settings and a "Assistant" mode to interact with the race assistants. |
| [IRC](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-irc) | This plugin integrates the *iRacing* simulation game with Simulator Controller. A "Pitstop" mode is available to control the pitstop settings from your controller hardware and an integration with Jona, the Virtual Race Engineer, including full support for automated pitstop handling is also available, as well as wtih Cato, the Virtual Race Strategist. The "Assistant" mode can handle most of the race assistant commands from your hardware controller. |
| [RF2](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-rf2) | Similar to the ACC and IRC plugin provides this plugin start and stop support for *rFactor 2*. A "Pitstop" mode is available to control the pitstop settings from your controller hardware and an integration with Jona, the Virtual Race Engineer, including full support for automated pitstop handling is available as well since Release 2.8. An integration with Cato, the Virtual Race Strategist exists since Release 3.1.6. The "Assistant" mode can handle most of the race assistant commands from your hardware controller. |
| [R3E](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-rre) | Similar to the ACC, IRC and RF2 plugins provides this plugin start and stop support for *RaceRoom Racing Experience*. A "Pitstop" mode is available to control the pitstop settings from your controller hardware and an integration with Jona, the Virtual Race Engineer, including full support for automated pitstop handling is available as well. An integration with Cato, the Virtual Race Strategist exists since Release 3.1.6. The "Assistant" mode can handle most of the race assistant commands from your hardware controller. |

All plugins can be configured in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool.

## Plugin *System*

The "System" plugin is a required part of the core Simulator Controller framework and therefore cannot be deactivated or deleted in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). This plugin handles all the applications during the [startup process](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--configuration) and provides a controller action to switch between the different modes using your hardware controller.

### Mode *Launch*

The "System" plugin creates the controller mode "Launch", which serves as a launchpad for all your important applications, and sets this mode as the currently active mode, when the Simulator Controller starts up. All the applications available on this launchpad can be configured in the [Launchpad tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-launchpad) of the configuration tool. If there are less applications configured for the launch pad than buttons are available on your controller hardware, the last button will be bound to a special action, which will let you shutdown your PC. Here is a picture of a Button Box with the "Launch" mode currently active:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%201.JPG)

### Configuration

The "System" plugin accepts one configuration argument in the [Plugins tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool, which you almost always will provide:

	modeSelector: *modeSelectorFunction1* *modeSelectorFunction2* ...;
	shutdown: *shutdownFunction*
	
The *modeSelector* parameter allows you to define controller functions that switch between modes on your Button Boxes. The *modeSelectorFunctionX* must be in the descriptor format, i.e. *"functionType*.*number*". You can use binary functions, such as 2-way toggle switches or dials, to switch forward and backward between modes, but a simple push button can also be used. Example: "modeSelector: 2WayToggle.1". If you have multiple Button Boxes, you may want to create a mode selector for each one, especially, if you have defined modes, whose actions are exclusive for one of those Button Boxes. Doing this, you can have mutiple modes active on the same time on your Button Boxes and you can switch between those modes on each of those Button Boxes separately. An example: You may bind all action for controlling the ["Motion" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-motion) to one Button Box and all actions for the ["Pitstop" mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pitstop-1) to a different Button Box. In this configuration, both modes can be active at the same time.

With the *shutdown* parameter, a unary function can be supplied to shutdown the complete simulator system. This function will be available in the "Launch" mode.

## Plugin *Tactile Feedback*

This plugin integrates with [SimHub](https://www.simhubdash.com/) to give you excellent control over your vibration effects. It can handle pedal vibration effects as well as chassis vibration separated between the front and the rear part of your simulation rig.

Note: The plugin "Tactile Feedback" will only be installed and activated, if a similar named application has been configured in the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications) of the configuration tool. This application must point to an installation of *SimHub* on your PC. As an alternative, you can provide the name of the application configuration with the *controlApplication* plugin argument.

The "Tactile Feedback" plugin will allow you to enable or disable pedal vibration, front chassis vibration or rear chassis vibration independently from your controller. And two modes, "Pedal Vibration" und "Chassis Vibration", will allow you to control all the underlying separate effects in detail. All these will only be available when *SimHub* is running, but *SimHub* will be started automatically, when one of the effect groups will be enabled from your controller.

To get the most out of this plugin in the sample configuration presented below, you will need three 2-way toggle switches, two rotary dials and eight push buttons on your controller hardware, although the dials and push buttons may be shared with other modes. But, since all this is fully configurable, you can find a compromise, if your controller provides less control elements. To help you with the configuration of *SimHub*, two shaker profiles are provided in the *Profiles* folder in the Simulator Controller distribution. Please load these profiles, named "...CV..." for chassis vibration and "...PV..." for pedal vibration, and adopt them to the specific configuration of your simulation rig. Using the plugin parameters described below, you can then customize the "Tactile Feedback" plugin to support your concrete hardware configuration as best as possible. These profiles already have been preconfigured with external triggers (for example: "togglePedalVibration" or "increaseRPMSVibration", just to name two), which will be used by the "Tactile Feedback" plugin to interact with *SimHub*.

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
	pedalVibration: *initialState* *onOffFunction* *intensityFunction*;
	frontChassisVibration: *initialState* *onOffFunction* *intensityFunction*;
	rearChassisVibration: *initialState* *onOffFunction* *intensityFunction*
	
The optional parameter *controlApplication* let you provide the name of the configured application object for *SimHub*, if it is not named "Tactile Feedback".
The other three parameters follow the same format and let you control the respective group of vibration effects.
*initialState* must be either "On" or "Off". Unfortunately, there is no way to query *SimHub* to request the current state of a toggleable effect, so this can get out of sync, if you left it in the other state the last time you used your rig.
*onOffFunction* will define a controller function to switch the respective vibration effect group on or off. Both, unary and binary functions are supported. This function is connected to the plugin itself and is therefore always available. For all this to work as expected, you must define a trigger in *SimHub* at the respective effect group, which must be named "toggle[*Effect*]Vibration", where *Effect* is either "Pedal", "FrontChassis" or "RearChassis".
Last, *intensityFunction*, which is part of the respective mode, will let you control the overall intensity of the effect group. You may have to supply a descriptor for a binary function here, unless you only want to increase the intensity all the time. Example: "pedalVibration: On 2WayToggle.3 Dial.1"

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
	motion: *initialState* *onOffFunction* *intensityFunction* *initialIntensity*

The optional parameter *controlApplication* let you provide the name of the configured application object for *SimFeedback*, if it is not named "Motion Feedback". The *connector* parameter may be used, when *SimFeedack* is running in expert mode and you have installed the extensions mentioned above. The path must be set to the location of the console executable, as in "D:\Programme\SimFeedback Connector\sfx-100-streamdeck-console.exe". For *motion*, you supply the *initialState* as one of "On" or "Off". 
*onOffFunction* will define a controller function to start or stop the motion actuator motors. Both, unary and binary functions are supported. This function is connected to the plugin itself and is therefore always available. With *intensityFunction*, you supply a function to control the overall motion intensity starting with *initialIntensity*. You may have to supply a descriptor for binary function here, unless you only want to increase the intensity all the time. Example: "motion: Off 2WayToggle.2 Dial.1 30"

Warning: *initialState* and *initialIntensity* will only be used, when using mouse automation to control *SimFeedback*. It is absolutely cruicial, that these settings correspnd with the current settings in *SimFeedback*, when it starts. Otherwise, you will get unpredictable results, since the emulated mouse clicks may be going wild. When using the connector, the initial values will be ignored and the current state will be requested from *SimFeedback* using the API integration instead.

With the following parameters you can configure the available effects for the "Motion" mode:

	motionEffectIntensity: *effectSelectorFunction* *effectIntensityFunction*;
	motionEffects: *effect1* *initialState1* *intialIntensity1* *effectToggleFunction1*,
				   *effect2* *initialState2* *intialIntensity2* *effectToggleFunction2*, ...

*effectX* is the name of the effect, for example "Heave". With *initialStateX* and *intialIntensityX* you supply "On" or "Off" and a value between 0.0 and 2.0 respectively. These values will only be used, when mouse automation is used to control *SimFeedback*. Last, you need to supply a controller function with *effectToggleFunctionX* to enable or disable the effect or choose it for intensity manipulation after pressing the "Effect Selector" button, which must have been configured by supplying values for the "motionEffectIntensity" parameter. Example: "Heave On 1.0 Button.1"

Important: Please be aware, that any spaces in effect names must be substituted with an underscore, since spaces are allowed in *SimFeedback* effect names, but not in plugin arguments. The underscores will be replaced with spaces again, before being transmitted to *SimFeedback*.

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

## Plugin *Race Engineer*

The "Race Engineer" plugin handles the interaction of the currently active simulation as represented by the plugins "ACC", "RF2", "R3E", and so on, and Jona, the Virtual Race Engineer. If one of these simulation is started, the "Race Engineer" plugin will be automatically activated, and will start Jona in the background according to the configuration arguments described below. The following configuration parameters allow you to customize Jona to your preferences:

	raceAssistant: *initialState* *onOffFunction*; raceAssistantName: *name*; raceAssistantLogo: true or false;
	raceAssistantLanguage: DE | EN | ...; raceAssistantService: Windows | Azure|tokenIssuerEndpoint|subscriptionKey;
	raceAssistantSpeaker: false, true or *Microsoft Speech Generation Language*;
	raceAssistantListener: false, true or *Microsoft Speech Recognition Language*;
	openRaceSettings: *settingsFunction*; importSetup: *importFunction*; openSetupDatabase: *setupsFunction*
	
For Jona to be generally available, you must supply an argument for the *raceAssistantName* parameter. You can define a function on your hardware controller with the parameter *raceAssistant*, to enable or disable the Virtual Race Engineer dynamically. *initialState* must be either "On" or "Off" and for *onOffFunction* unary and binary functions are supported. The function will be bound to a plugin action. Additionally, the parameter *openRaceSettings* allows you to bind a plugin action to your hardware controller, which opens the [settings dialog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings), which you will use before a race to give Jona the necessary information about your car setup and other stuff. As an alternative you can use the plugin action *importSetup* to import the current tyre setup data only, without opening the settings dialog. Nevertheless, you will get a notification, when the setup has been imported successfully.
Last, but not least, with *openSetupDatabase* you can open the [setup database query tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-setup-database). If a simulation is currently running, most of the query arguments will already be prefilled. 

Note: If you disable Jona during an active race, the Race Engineer will stop working immediately. You can also enable Jona at the beginning of a race, but only until you cross the start/finish line for the first time. If you enable Jona after the initial lap, Jona will not be available until the next session. 

With *true* supplied for *raceAssistantLogo*, Jona will show a nice rotating AI brain in the lower right corner of the screen, while the AI kernel is working, but you will get a short lag in your simulation, when this window pops up.

The paranmeter *raceAssistantService* allows you to specify the speech synthesis engine, which is used for this race assistant. If you supply *Windows*, you will use the synthesis engine on your local computer. If you supply *Azure|tokenIsszuerEndpoint|subscriptionKey* (with valid values for *tokenIssuerEndpoint* and *subscriptionKey*), you will use the cloud services of Microsoft to generate voice output and you will have access to more and more natural voices, but this possibly does not come for free. Please see the [Voice Control configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) for more information. Default for the *raceAssistantService* parameter is the preconfigured engine.

With *raceAssistantSpeaker* and *raceAssistantListener* you can customize the natural language interface (or the personality) of Jona. If you simply supply *true* as arguments, a voice and the corresponding recognition engine will be choosen based on the currently configured language. If you prefer a specific voice and / or a specific language, you can supply the name for this voice and language instead (Example: "Microsoft David Desktop" is a male US-English voice and "Microsoft Server Speech Recognition - TELE (de-DE)" provide german spoken language recognition. The phrase grammars of Jona can be localized for any language, with English and German already supplied by the standard distribution of Simulator Controller, but you will also need the corresponding Windows libraries for TTS (text-to-speech) and STT (speech-to-text). For more information about Jona, see the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer). With *raceAssistantLanguage* you can overwrite the default language, which has been configured in the [voice tab of the configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control).

It is possible, although not much fun, to use Jona without its natural language interface. Only the pitstop planning and setup capabilities are available in this cconfiguration, but it is still useful. You can use the following parameters to connect these actions to your controller hardware:

	assistantCommands: PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
	
All these command actions will be bound to the plugin itself, thereby are available all the time, and only unary functions are supported here. By using this actions, you will be able to use Jona with voice output, but no voice control, thereby getting most of the support from Jona, but you have to use an *oldschool* interface to control the engineer actions. To *answer* "Yes" to one of the questions of Jona, you must supply a controller function, for example a push button function, to the *Accept* parameter and for "No", you must use the *Reject* parameter.

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
| LapsRemaining | Jona will give you the number of laps still to drive. The number of remaining laps is determined by the remaining stint, session or driver time, but of course is also limited by the remaining fuel. |
| Weather | You will get information about the current and upcoming weather. |
| TyrePressures | Cato will tell you the current pressures in your tyres in PSI. |
| TyreTemperatures | This command will give you the current temperatures in the core of your tyres in Degrees Celsius. |

Note: All these commands are also available in most of the simulation plugins, either in the "Pitstop" mode or in the "Assistant" mode, depending on the configuration parameters.

## Plugin *Race Strategist*

The "Race Strategist" plugin handles the interaction of the currently active simulation as represented by the plugins "ACC", "RF2", "R3E", and so on, and Cato, the Virtual Race Strategist. If one of these simulation is started, the "Race Strategist" plugin will be automatically activated, and will start Cato in the background according to the configuration arguments described below. The following configuration parameters allow you to customize Cato to your preferences:

	raceAssistant: *initialState* *onOffFunction*; raceAssistantName: *name*; raceAssistantLogo: true or false; 
	raceAssistantLanguage: DE | EN | ...; raceAssistantService: Windows | Azure|tokenIssuerEndpoint|subscriptionKey;
	raceAssistantSpeaker: false, true or *Microsoft Speech Generation Language*;
	raceAssistantListener: false, true or *Microsoft Speech Recognition Language*;
	openRaceSettings: *settingsFunction*; openSetupDatabase: *setupsFunction*
	
For Cato to be generally available, you must supply an argument for the *raceAssistantName* parameter.You can define a function on your hardware controller with the parameter *raceAssistant*, to enable or disable the Virtual Race Strategist dynamically. *initialState* must be either "On" or "Off" and for *onOffFunction* unary and binary functions are supported. The function will be bound to a plugin action. Additionally, the parameter *openRaceSettings* allows you to bind a plugin action to your hardware controller, which opens the [settings dialog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-settings), which you will use before a race to give Cato the necessary information about your car setup and strategy options. And with *openSetupDatabase* you can open the [setup database query tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#querying-the-setup-database). If a simulation is currently running, most of the query arguments will already be prefilled. 

Hint: You can bind the activation and deactivation of the Virtual Race Engineer and the Virtual Race Strategist to one function, if you want to control them both with the same switch on your hardwar controller.

With *true* supplied for *raceAssistantLogo*, Cato will show a nice rotating AI brain in the lower left corner of the screen, while the AI kernel is working, but you will get a short lag in your simulation, when this window pops up.

The paranmeter *raceAssistantService* allows you to specify the speech synthesis engine, which is used for this race assistant. If you supply *Windows*, you will use the synthesis engine on your local computer. If you supply *Azure|tokenIsszuerEndpoint|subscriptionKey* (with valid values for *tokenIssuerEndpoint* and *subscriptionKey*), you will use the cloud services of Microsoft to generate voice output and you will have access to more and more natural voices, but this possibly does not come for free. Please see the [Voice Control configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) for more information. Default for the *raceAssistantService* parameter is the preconfigured engine.

With *raceAssistantSpeaker* and *raceAssistantListener* you can customize the natural language interface (or the personality) of Cato. If you simply supply *true* as arguments, a voice and the corresponding recognition engine will be choosen based on the currently configured language. If you prefer a specific voice and / or a specific language, you can supply the name for this voice and language instead (Example: "Microsoft David Desktop" is a male US-English voice and "Microsoft Server Speech Recognition - TELE (de-DE)" provide german spoken language recognition. The phrase grammars of Cato can be localized for any language, with English and German already supplied by the standard distribution of Simulator Controller, but you will also need the corresponding Windows libraries for TTS (text-to-speech) and STT (speech-to-text). For more information about Cato, see the corresponding [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist). With *raceAssistantLanguage* you can overwrite the default language, which has been configured in the [voice tab of the configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control).

Similar as for Jona, you can use the following parameters to trigger some of Catos service without using voice commands:

	assistantCommands: PitstopRecommend *function*, Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
	
All these command actions will be bound to the plugin itself, thereby are available all the time, and only unary functions are supported here. By using these actions, you will be able to use Cato with voice output, but no voice control, thereby getting most of the support from Cato, but you have to use an *oldschool* interface to control the strategist actions. To *answer* "Yes" to one of the questions of Cato, you must supply a controller function, for example a push button function, to the *Accept* parameter and for "No", you must use the *Reject* parameter.

Furthermore, you can request a lot of information from Cato about the current race situation. Thefore, you can supply the *InformationRequest* parameter multiple times.

Example:

	assistantCommands: ...,
					   InformationRequest Position Button.1,
					   InformationRequest GapToFront Track Button.2,
					   InformationRequest GapToRear Track Button.3,
					   ...
	
Please see the following table for available information commands.

| Command | Description |
| ------ | ------ |
| LapsRemaining | Cato will give you the number of laps still to drive. The number of remaining laps is determined by the remaining stint, session or driver time, but of course is also limited by the remaining fuel. |
| Weather | You will get information about the current and upcoming weather. |
| Position | Cato will tell you your current position. |
| LapTimes | You will be given information about your average lap time and those of your direct opponents. |
| GapToFront [Standings, Track] | Cato will tell you the gap in seconds to the car one position ahead of you or to the car directly in front of you. If you you don't supply *Standings* or *Track*, it will default to *Standings*. |
| GapToBehind [Standings, Track] | Cato will tell you the gap in seconds to the car one position behind you or to the car directly behind you. If you you don't supply *Standings* or *Track*, it will default to *Standings*. |
| GapToLeader | Cato will tell you the gap in seconds to the leading car. |

Note: All these commands are also available in most of the simulation plugins, either in the "Pitstop" mode or in the "Assistant" mode, depending on the configuration parameters.

## Plugin *ACC*

This plugin handles the *Assetto Corsa Competizione* simulation game. This plugin needs an application with the name "Assetto Corsa Competizione" to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startACC", "stopACC" and "isACCRunning" as special function hooks in this configuration. An integration with Jona is available through the "Race Engineer" plugin, and an integration with Cato through the plugin "Race Strategist".

### Mode *Chat*

The mode "Chat" binds all the configured chat messages to buttons on your controller hardware. The chat messages can be defined in the [Chat tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-chat). The messages will be only availabe in a multiuser race scenario, since "Assetto Corsa Competizione" activates the chat system only there.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%205.JPG)

In addition to trigger a chat message from your controller hardware, you can trigger them using *VoiceMacro* by voice commands as well. Please see the *VoiceMacro* profile, which is supplied in the *Profiles* folder in the installation folder of Simulator Controller. And also take a look at the [Release 2.0](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-20) update documentation on how to setup *VoiceMacro* to get the best best possible voice recognition results.

### Mode *Pitstop*

Starting with Release 2.0, all pitstop settings of *Assetto Corsa Competizione* can be controlled by this plugin. The simulator dependent mode *Pitstop* may configure all or a subset of the pitstop settings on your hardware controller, which might be more ergonomic than typing on the keyboard during driving. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%206.JPG)

Using the buttons and dials you may change the pitstop settings in the same way as using the keyboard. All this will be achieved using the following plugin arguments:

	openPitstopMFD: P; closePitstopMFD: {Insert};
	pitstopCommands: Strategy Dial.1, Refuel Dial.2 5, TyreSet Button.1 Button.5, TyreCompound Button.2 Button.6,
					 TyreAllAround Button.3 Button.7, SuspensionRepair Button.4, BodyworkRepair Button.8

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

First, you need to define, how to open and close the Pitstop MFD in *Assetto Corsa Competizione*. If the standard keyboard mapping is used, this will be the "P" and the "Insert" keys on the keyboard.

	openPitstopMFD: *openHotkey*; closePitstopMFD: *closeHotkey*
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Strategy | Choose one of the predefined pitstop strategies. |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
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

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your race assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| PitstopRecommend | Asks the virtual race strategist for a recommendation for the next pitstop. |
| PitstopPlan | Requests a pitstop plan from the virtual race engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the virtual race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the virtual race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend*.

Note: For convinience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

### Important preparation for the Pitstop MFD handling

In order to *understand* the Pitstop MFD state of *Assetto Corsa Competizione*, Simulator Controller searches for small picture elements in the graphics of the game window. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Pit%20Strategy%201.JPG)     ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Compound%201.JPG)     ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Select%20Driver%202.jpg)

These pictures are located in the *Resources\Screen Images\ACC folder* in the installation folder of Simulator Controller. They have been taken from a Full HD triple screen setup (5760 * 1080) using the English language setting in *Assetto Corsa Competizione*. If you are running a different resolution or, even more important, are using a different language, the search for these pictures will fail. But there is help, since you can provide your own pictures by placing your own ones with identical names in the *Simulator Controller\Screen Images\ACC* folder in your user *Documents* folder. Use the Snipping Tool of Windows to create all the necessary pictures, it will only take a few minutes.

Hint: The "Select Driver" option might only be available in special multiuser server setups, whereas the "Strategy" option is available in every Race situation.

Note: The picture search will initially take some time, but the algorithm will learn the position of the Pitstop MFD during the initial run. Depending on your screen size and resolution the initial search will consume quite some CPU cycles. Therefore I advice to open the Pitstop MFD using one of the mode actions above once you are driving in a safe situation, to avoid lags later on. Simulator Controller will learn the position and will only search the much reduced screen area from now on and the CPU load will be 10 times less than before

## Plugin *AC*

This plugin handles starting and stopping of the *Assetto Corsa* simulation game. An application with the name "Assetto Corsa" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startAC" as a special function hook in this configuration, and set the window title to "Assetto Corsa Launcher".

## Plugin *IRC*

This plugin handles starting and stopping of the *iRacing* simulation game. An application with the name "iRacing" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please locate the "iRacingUI.exe" application, set "ahk_exe iRacingUI.exe" as the window title and "startIRC" as a special function hook in this configuration. An integration with Jona is available through the "Race Engineer" plugin, and an integration with Cato through the plugin "Race Strategist".

### Mode *Pitstop*

Similar to the pitstop mode the plugin for *Assetto Corsa Competizione*, you can control most of the pitstop settings of *iRacing*. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2010.JPG)

All this will be achieved using the following plugin arguments:

	togglePitstopFuelMFD: {F4}; togglePitstopTyreMFD: {F5};
	pitstopCommands: Refuel Dial.1 5, TyreAllAround Dial.2, PitstopPlan Button.1, PitstopPrepare Button.5,
					 TyreChange Button.2 Button.5, RepairRequest Button.3 Button.7

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

First, you need to define, how to open and close the different Pitstop MFDs (aka Black Boxes) in *iRacing*. Please supply the bindings you have defined in the "Controls" setup in *iRacing*.

	togglePitstopFuelMFD: *toggleHotkey*; togglePitstopTyreMFD: *toggleHotkey*

If the opening of the Pitstop MFD for *iRacing* is requested without specifying which type of MFD is meant (for example by calling the controller action *openPitstopMFD* without specifying the optional argument for the *descriptor* parameter), the MFD for the fuel settings will be opened.
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| TyreChange | Toggles, whether tyres will be changed at the pitstop. |
| TyreAllAround | Change the pressure for all tyres at once. Supports the additional increments argument. |
| TyreFrontLeft | Change the pressure for the front left tyre. Supports the additional increments argument. |
| TyreFrontRight | Change the pressure for the front right tyre. Supports the additional increments argument. |
| TyreRearLeft | Change the pressure for the rear left tyre. Supports the additional increments argument. |
| TyreRearRight | Change the pressure for the rear right tyre. Supports the additional increments argument. |
| RepairRequest | Toggles, whether repairs will be carried out during the next pitstop.  |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your race assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| PitstopRecommend | Asks the virtual race strategist for a recommendation for the next pitstop. |
| PitstopPlan | Requests a pitstop plan from the virtual race engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the virtual race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the virtual race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend*.

Note: For convinience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

## Plugin *RF2*

This plugin handles the *rFactor 2* simulation game. An application with the name "rFactor 2" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startRF2" as a special function hook in this configuration. The plugin supports a "Pitstop" mode to control the pitstop settings and an integration with Jona is available through the "Race Engineer" plugin, and an integration with Cato through the plugin "Race Strategist".

Important: You must install a plugin into *rFactor 2* plugins directory ([rF2]\Bin64\Plugins\) for the telemetry interface and the pitstop mode to work. You can find the plugin in the *Utilities\3rd Part\rf2_sm_tools_3.7.14.2.zip*. A Readme file is included.

### Mode *Pitstop*

Similar to the pitstop mode the plugin for *Assetto Corsa Competizione*, you can control most of the pitstop settings of *rFactor 2*. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%208.JPG)

All this will be achieved using the following plugin arguments:

	openPitstopMFD: P; closePitstopMFD: P;
	pitstopCommands: Refuel Dial.1 5, TyreAllAround Dial.2, PitstopPlan Button.1, PitstopPrepare Button.5,
					 TyreCompound Button.2 Button.5, RepairRequest Button.3 Button.7, DriverSelect Button.4 Button.8

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

First, you need to define, how to open and close the Pitstop MFD (aka HUD) in *rFactor 2*. Please supply the bindings you have defined in the controller setup in *rFactor 2*.

	openPitstopMFD: *openHotkey*; closePitstopMFD: *closeHotkey*
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| TyreCompound | Cycles through the available tyre compounds. |
| TyreAllAround | Change the pressure for all tyres at once. Supports the additional increments argument. |
| TyreFrontLeft | Change the pressure for the front left tyre. Supports the additional increments argument. |
| TyreFrontRight | Change the pressure for the front right tyre. Supports the additional increments argument. |
| TyreRearLeft | Change the pressure for the rear left tyre. Supports the additional increments argument. |
| TyreRearRight | Change the pressure for the rear right tyre. Supports the additional increments argument. |
| DriverSelect | Selects the driver for the next stint in a multiplayer team race. |
| RepairRequest | Cycles through the available repair options. |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your race assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| PitstopRecommend | Asks the virtual race strategist for a recommendation for the next pitstop. |
| PitstopPlan | Requests a pitstop plan from the virtual race engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the virtual race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the virtual race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend*.

Note: For convinience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

## Plugin *R3E*

This plugin handles the *RaceRoom Racing Experience* simulation game. An application with the name "RaceRoom Racing Experience" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startR3E" as a special function hook in this configuration and define "ahk_exe RRRE64.exe" (yes, three "R"s) as the window title. The plugin supports a "Pitstop" mode to control the pitstop settings and an integration with Jona is available through the "Race Engineer" plugin, and an integration with Cato through the plugin "Race Strategist".

### Mode *Pitstop*

Similar to the pitstop mode the plugin for *Assetto Corsa Competizione*, you can control most of the pitstop settings of *RaceRoom Racing Experience*. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%209.JPG)

All this will be achieved using the following plugin arguments:

	openPitstopMFD: P; closePitstopMFD: P;
	pitstopCommands: Strategy Dial.1, Refuel Dial.2 5, TyreChange Button.1, BodyworkRepair Button.2, SuspensionRepair Button.3,
					 PitstopPlan Button.7, PitstopPrepare Button.8

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

First, you need to define, how to open and close the Pitstop MFD (aka Menu) in *RaceRoom Racing Experience*. Please supply the bindings you have defined in the controller setup in *RaceRoom Racing Experience*.

	openPitstopMFD: *openHotkey*; closePitstopMFD: *closeHotkey*;
	previousOption: *previousOptionHotkey*; nextOption: *nextOptionHotkey*;
	previousChoice: *previousChoiceHotkey*; nextChoice: *nextChoiceHotkey*;
	acceptChoice: *acceptChoiceHotkey*
	
Use the *...Option* and *...Choice* parameters to specify the keys, that will be send to *RaceRoom Racing Experience* to control the Pitstop MFD. These parameters are defaulted to "W", "S", "A", "D" and "{Enter}", which are the default bindings of *RaceRoom Racing Experience*, so you won't have to supply them normally.
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Strategy | Choose one of the predefined pitstop strategies. |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| TyreChange | Toggles, whether you want to change the tyres at the next pitstop or not. |
| SuspensionRepair | Toggles the repair of the suspension components. |
| BodyworkRepair | Toggles the repair of all the bodywork and aerodynamic elements. |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your race assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| PitstopRecommend | Asks the virtual race strategist for a recommendation for the next pitstop. |
| PitstopPlan | Requests a pitstop plan from the virtual race engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the virtual race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the virtual race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend*.

Note: For convinience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

### Important preparation for the Pitstop MFD handling

Nothing comes for free, and *RaceRoom Racing Experience* does not provide a sophisticated API to externally control the pitstop settings, as *rFactor 2* does. So we also use event automation here, very similar to the [Pitstop MFD control in *Assetto Corsa Competizione*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling). Therefore you also have to create those little pictures, Simulator Controller searches for in order to *understand* the Pitstop MFD state of *RaceRoom Racing Experience*.

These pictures are located in the *Resources\Screen Images\R3E folder* in the installation folder of Simulator Controller. They have been taken from a Full HD triple screen setup (5760 * 1080) using the English language setting in *RaceRoom Racing Experience*. If you are running a different resolution or, even more important, are using a different language, the search for these pictures will fail. But there is help, since you can provide your own pictures by placing your own ones with identical names in the *Simulator Controller\Screen Images\R3E* folder in your user *Documents* folder. Use the Snipping Tool of Windows to create all the necessary pictures, it will only take a few minutes.

Note: The picture search will initially take some time, but the algorithm will learn the position of the Pitstop MFD during the initial run. Depending on your screen size and resolution the initial search will consume quite some CPU cycles. Therefore I advice to open the Pitstop MFD using one of the mode actions above once you are driving in a safe situation, to avoid lags later on. Simulator Controller will learn the position and will only search the much reduced screen area from now on and the CPU load will be 10 times less than before.

Second note: The image search algorithm used here is as good as it can be. But unfortunately, the Pitstop MFD in *RaceRoom Racing Experience* has very low contrast differences in several places, other than the Pitstop MFD of *Assetto Corsa Competizione*, Therefore, it is possible from time to time, that the search will yield false positives, which in the end will lead to false values and choices entered into fields of the Pitstop MFD. So please always double check, that everything is correct, before entering the pit lane.

## Plugin *AMS2*

This plugin handles the *Automobilista 2* simulation game. An application with the name "Automobilista 2" needs to be configured in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). Please set "startAMS2" as a special function hook in this configuration and "Automobilista 2" as the window title.

Important: So that the telemetry data can be accessed, the shared memory interface must be activated in the settings of *Automobilista 2* in the "PCars 2" mode.

The plugin supports a "Pitstop" mode to control the pitstop settings and an integration with Jona is available through the "Race Engineer" plugin, and an integration with Cato through the plugin "Race Strategist".

### Mode *Pitstop*

Similar to the pitstop mode the plugin for *Assetto Corsa Competizione*, you can control most of the pitstop settings of *Automobilista 2*. 

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%2011.JPG)

All this will be achieved using the following plugin arguments:

	openPitstopMFD: I; previousOption: Z; nextOption: H; previousChoice: G; nextChoice: J;
	pitstopCommands: Refuel Dial.2 5, TyreChange Button.1, BodyworkRepair Button.2, SuspensionRepair Button.3

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

First, you need to define, how to open the Pitstop MFD (a part of the In Car Menu, aka ICM) in *Automobilista 2*. "I" is the default value for *openPitstopMFD*, which is **not** the standard binding of *Automobilista 2*. You need to change these bindings in *Automobilista 2*, since the standard bindings are controller buttons, for which unfortunately no events can be generated by software.

	openPitstopMFD: *openHotkey*;
	previousOption: *previousOptionHotkey*; nextOption: *nextOptionHotkey*;
	previousChoice: *previousChoiceHotkey*; nextChoice: *nextChoiceHotkey*
	
Use the *...Option* and *...Choice* parameters to specify the keys, that will be send to *Automobilista 2* to control the Pitstop MFD. These parameters are defaulted to "Z", "H", "G" and "J", which are **not** the default bindings of *Automobilista 2* (see above).
	
With the plugin parameter *pitstopCommands* you can supply a list of the settings, you want to tweak from your hardware controller, when the "Pitstop" mode is active. For most settings, you can supply either one binary or two unary controller function to control the setting, depending on the available buttons or dials. For *stepped* settings (for example tyre pressure and fuel amount) you can supply an additional argument to define the number of increments you want change in one step.

	pitstopCommands: *setting1* *settingsFunction1* [*settingSteps1*],
					 *setting2* *settingsFunction2* [*settingSteps2*], ...
					 
See the following table for the supported settings:

| Setting | Description |
| ------ | ------ |
| Refuel | Increment or decrement the refuel amount. Supports the additional increments argument. |
| TyreChange | Chooses between "Dry" and "Wet" tyres for the next pitstop or no tyre change at all. Currently, only vehicles with one dry tyre compound and one wet tyre compound are supported. |
| SuspensionRepair | Toggles the repair of the suspension components. |
| BodyworkRepair | Toggles the repair of all the bodywork and aerodynamic elements. |

Beside controlling the pitstop settings from the button box, most of the settings are also available as actions, which can be bound to external event sources. See the list of [actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions) for more information.

With the plugin parameter *assistantCommands* you can supply a list of the commands you want to trigger, when the "Assistant" mode is active. Only unary controller functions are allowed here.

	assistantCommands: PitstopRecommend *function*, PitstopPlan *function*, PitstopPrepare *function*,
					   Accept *acceptFunction*, Reject *rejectFunction*,
					   InformationRequest *requestFunction* *command* [*arguments*], ...
					 
See the following table for the supported assistant commands.

| Command | Description |
| ------ | ------ |
| InformationRequest {command} | With *InformationRequest*, you can request a lot of information from your race assistants without using voice commands. Please see the documentation for the [Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) plugin and for the [Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) plugin, for an overview what information can be requested. |
| PitstopRecommend | Asks the virtual race strategist for a recommendation for the next pitstop. |
| PitstopPlan | Requests a pitstop plan from the virtual race engineer. |
| PitstopPrepare | Requests Jona to transfer the values from the current pitstop plan to the Pitstop MFD. |
| Accept | Accepts the last recommendation by one of the virtual race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |
| Reject | Cancels or rejects the last recommendation by one of the virtual race assistants. Useful, if you don't want to use voice commands to interact with Jona or Cato. |

See the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) for the "Race Engineer" plugin above for more information on *PitstopPlan*, *PitstopPrepare*, *Accept* and *Reject* and the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for the "Race Strategist" plugin above for more information on *PitstopRecommend*.

Note: For convinience, all commands available for the *assistantCommands* parameter, may also be passed to the *pitstopCommands* parameter, thereby including all these commands in the "Pitstop" mode.

### Special requirements when using the Pitstop automation

It is very important, that you do not use the *Automobilista 2* ICM on your own, when you want to control the pitstop settings using the "Pitstop" mode, or if you want Jona to control the pitstop settings. Furthermore, you must leave *all* repairs selected in the default pitstop strategy and select *no tyre change* in the default pitstop strategy as well. Not complying with this requirements will give you funny results at least.