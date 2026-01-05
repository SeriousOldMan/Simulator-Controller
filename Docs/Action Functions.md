All the functions listed below can be used in various parts of Simulator Controller to script actions and trigger custom behavior. All these functions will be executed in the main "Simulator Controller" background process, if called. But depending on the function, they can also trigger custom behavior in the different plugins, thereby causing effects also in the Race Assistants or for a simulator, for example.

A call to an action function looks like this: *setMode("Tactile Feedback", "Pedal Vibration")*, which means, that the "Pedal Vibration" mode of the "Tactile Feedback" plugin should be selected as the active layer for your hardware controller. You can provide zero or more arguments to the function call. All arguments will be passed as strings to the function with the exception of *true* and *false*, which will be passed as literal values (1 and 0).

Although you may call any globally defined function, you should use only the following functions for your actions, since they are specially prepared to be called from an external source. Many of these functions are particular useful in combination with a [*Conversation* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#conversation-booster).

Please note, that action functions must be written as a function call with "()" as in "increaseLogLevel()", even if there are no actual arguments.

As said, you can call these action functions in various parts of Simulator Controller. Just to name a few:

1. You can call them as [action for a pressed button on a Button Box or Stream Deck](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller).
2. They can be also called as action to be executed when reaching a specific position of the track. See [track automations](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter#track-automation) for more information.
3. You can call them in a [script written in Lua](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Script-Modules) in the "Strategy Workbench", "Setup Workbench" or using the [*Conversation* or *Reasoning* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants).
4. You can also trigger them as a resulting action in [rule](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine) used in the "Strategy Workbench" or in a [*Conversation* or *Reasoning* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants).

[Expert] Please note, that all these functions are supplied by one of the installed plugins. So, if you do not have the corresponding plugin enabled, the function may not work properly.

### Trigger actions

These actions are mainly used to trigger an action in a track automation, but they are also very useful for general scripting.

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| speak | message | System | Speaks the supplied *message* using the [default voice synthesizer configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control). |
| play | fileName | System | *fileName* must a supported sound file, which is then played. |
| execute | command | System | Execute any command, which can be an executable or a script with an extension accepted by the system. The *command* string can name additional arguments for parameters accepted by the command, and you can use global variables enclosed in percent signs, like %ComSpec%. Use double or single quotes to handle spaces in a part of the command string.<br><br>Example: execute("D:\Programme\Nircmd.exe" changeappvolume ACC.exe -0.1) - reduces the sound volume of *Assetto Corsa Compeitizione* by 10 percent.<br><br>A special case are *Lua* scripts, as identified by the ".script" or ".lua" extension. In this case the *Lua* script is executed in the "Simulator Controller" process and any arguments that have been passed to the script are available in the global array *Arguments*. The script also has access to the simulator state and API data using the [*Simulator* script module](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Script-Modules). Please note, that other modules are not supported in this context, but you can reference and call any global object or function using the "extern" function. |
| trigger | hotkey(s), [Optional] method | System | Triggers one or more hotkeys. This can be used to send keyboard commands to your simulator, for example. Each keyboard command is a [keyboard command hotkey](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys). Use the vertical bar to separate between the individual commands, if there are more than one command. The optional argument for method specifies the communication method to send the keyboard commands. These are named "Event", Input", "Play", "Raw" and "Default". For whatever reason, there is not the one method, which works for every Windows installation. For me, "Event" works best and is therefore the standard, if you don't supply the argument. |
| mouse | button, x, y, [Optional] count, [Optional] window | System | Clicks the specified mouse button (one of "Left", "Right" or "Middle") at the given location. You can supply the number of clicks using *count* and you can supply a target window using the optional parameter *window*. Coordinates are relative to the upper left corner of the *window*, if supplied, otherwise relative to the uper left corner of the screen. |

### Track automation handling

A couple functions which let you enable or disable track automation and select a specific track automation. You can write a rule, for example, using the *Reasoning* booster, which automatically chooses between different track automations depending on the current track grip or weather conditions.

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| selectTrackAutomation | [Optional] name | Race Spotter | Selects one of the configured track automations by its *name* and loads it. If *name* is omitted, the automation marked as the active one, will be loaded. If track automation is currently enabled, the execution of actions will start with the next lap. |
| enableTrackAutomation | - | Race Spotter | Enables the track automation. Can be called anytime, the automation will be activated at the beginning of the next lap. |
| disableTrackAutomation | - | Race Spotter | Disables the track automation. No further actions will be executed. |

### Assistant interface

Each Race Assistant is running an internal rule engine. These functions can be used to interface with the rules in the rule set of a given Assistant to implement custom behavior or create custom events. 

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| ask    | assistant, question | Driving Coach, Race Engineer, Race Strategist, Race Spotter | This function will send the given *question* to the specified *assistant* as if it has been given by voice. The *question* will be processed by the *Conversation* booster and therefore the answer will be supplied by the attached LLM. |
| command | assistant, grammar, [Optional] command | Driving Coach, Race Engineer, Race Strategist, Race Spotter | This function will trigger the command with the name *grammar* for the specified *assistant* as if it has been given by voice. If the definition for the *grammar* requires variable parts in the command text, for example a number of liters for refueling, a full command text, that matches the defined grammar, must be supplied with *command*. Otherwise, it is optional. Example (for Race Engineer):<br><br>command("PitstopAdjustPressureUp", "Can we increase front left by 0.4?")<br><br>The names of the different command grammars can be found by looking into grammar files of the corresponding Assistant, which can be found in the *Resources\Grammars* folder which is located in the installation folder of Simulator Controller. |
| raiseEvent | assistant, event, [Optional] arguments... | Driving Coach, Race Engineer, Race Strategist, Race Spotter | Raises *event* in the *Reasoning* booster of the given *assistant*. Any number of arguments can be supplied as defined for the given *event*. See the documentation on [Customizing Assistants](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants) for more information. |
| triggerAction | assistant, action, [Optional] arguments... | Driving Coach, Race Engineer, Race Strategist, Race Spotter | Triggers *action* in the *Reasoning* booster of the given *assistant*. Any number of arguments can be supplied as defined for the given *action*. See the documentation on [Customizing Assistants](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants) for more information. |

### Custom *Push-to-Talk* implementation

These functions can be used to implement custom *Push-to-Talk* behavior or work around a problem, when steering wheel buttons are not recognized properly. Use them as functions for controller actions. It is important, that the *Push-to-Talk* method is set to "Custom", otherwise calls to these functions will be ignored.

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| targetListener | target | Voice Control | Directs the next voice commands to the supplied *target*, which must eiher be "Controller" or the name of one of the Race Assistants. Simuilar to using the [Push-To-Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) button and then issuing an activation command. Only usable, if you have chosen the *Push-To-Talk* mode "Custom" in the configuration. |
| startActivation | - | Voice Control | Activates the activation listen mode. Simuilar to using the [Push-To-Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) button to prepare for issuing an activation command. Only usable, if you have chosen the *Push-To-Talk* mode "Custom" in the configuration. |
| startListen | - | Voice Control | Activates the listen mode of the currently targeted dialog partner. Simuilar to using the [Push-To-Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) button. Only usable, if you have chosen the *Push-To-Talk* mode "Custom" in the configuration. |
| stopListen | - | Voice Control | Stops the listen mode and tries to understand the spoken command (both activation and normal). Simuilar to using the [Push-To-Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) button. Only usable, if you have chosen the *Push-To-Talk* mode "Custom" in the configuration. |

### Custom hardware controller actions

Using these functions, it is possible to achieve the same effect, as if a specific control on a Button Box, Stream Deck or steering wheel has been activated.

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| pushButton | number | Builtin | Virtually pushes the button with the given number. |
| rotateDial | number, direction | Builtin | Virtually rotates the rotary dial with the given number. *direction* must be one of "Increase" or "Decrease". |
| switchToggle | type, number, state | Builtin | Virtually switches the toggle switch with the given number. *state* must be one of "On" or "Off" for 2-way toggle switches and "On" for 1-way toggle switches. The type of the toggle switch must be passed as *type*, one of "1WayToggle" and "2WayToggle". |
| callCustom | number | Builtin | Calls the custom controller action with the given number. |
| setMode | plugin, mode | Builtin | Switches the currently active mode for the hardware controller. See the [plugin reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for an in depth explanation of all available modes. Instead of supplying the name of a plugin and mode, you can omit the second argument and supply "Increase" or "Deacrease" for the first parameter. In this case the controller will activate the next mode like in a carousel. |

### Pitstop MFD handling

You can change the settings in the Pitstop MFD of most simulators using these functions. This is an alternative to using the pre-defined actions of the corresponding plugin, which can be used to create a simple speech interface for the most important settings.

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| openPitstopMFD | [Optional] descriptor | AC, ACC, RF2, LMU, R3E, IRC | Opens the pitstop settings dialog of the simulation that supports this. If the given simulation supports more than one pitstop settings dialog, the optional parameter *decriptor* can be used to denote the specific dialog. For IRC this is either "Fuel" or "Tyres", with "Fuel" as the default. This action function also resets the memorized state of the Pitstop MFD in ACC. So you may want to dedicate a button for this, if you quite often change pitstop settings manually. |
| closePitstopMFD | - | ACC, RF2, R3E, IRC | Closes the currently open pitstop settings dialog of the simulation that supports this. |
| changePitstopOption | option, selection, [Optional] increments | AC, ACC, RF2, LMU, R3E, IRC | Enables or disables one of activities carried out by your pitstop crew. The supported options depend on the current simlation game. For example, for ACC the available options are "Change Tyres", "Change Brakes", "Repair Bodywork" and "Repair Suspension", for R3E "Change Tyres", "Repair Bodywork" and "Repair Suspension", for RF2 "Repair", and for IRC "Change Tyres" and "Repair". *selection* must be either "Next" / "Increase" or "Previous" / "Decrease". For stepped options, you can supply the number of increment steps by supplying a value for *increments*. For other, more common pitstop activites like refueling, use on of the next actions. |
| changePitstopStrategy | selection | AC, ACC, R3E | Selects one of the pitstop strategies (this means predefined pitstop settings). *selection* must be either "Next" or "Previous". |
| changePitstopFuelAmount | direction, [Optional] liters | AC, ACC, RF2, LMU, R3E, IRC, AMS2, PCARS2 | Changes the amount of fuel to add during the next pitstop. *direction* must be either "Increase" or "Decrease" and *liters* may define the amount of fuel to be changed in one step. This parameter has a default of 5. |
| changePitstopTyreSet | selection | ACC | Selects the tyre sez to change to during  the next pitstop. *selection* must be either "Next" or "Previous". |
| changePitstopTyreCompound | selection | AC, ACC, RF2, LMU, AMS2, PCARS2 | Selects the tyre compound to change to during  the next pitstop. *selection* must be either "Increase" or "Decrease" to cycle through the list of available options. |
| changePitstopTyrePressure | tyre, direction, [Optional] increments | AC, ACC, RF2, LMU, AMS2, PCARS2, IRC | Changes the tyre pressure during the next pitstop. *tyre* must be one of "All Around", "Front Left", "Front Right", "Rear Left" and "Rear Right", and *direction* must be either "Increase" or "Decrease". *increments* with a default of 1 define the change in 0.1 psi increments. |
| changePitstopBrakePadType | brake, selection | ACC | Selects the brake pad compound to change to during the next pitstop. *brake* must be "Front Brake" or "Rear Brake" and *selection* must be "Next" or "Previous".  |
| changePitstopDriver | selection | ACC, RF2, LMUs | Selects the driver to take the car during the next pitstop. *selection* must be either "Next" or "Previous". |
| planPitstop | - | Race Engineer | *planPitstop* triggers Jona, the AI Race Engineer, to plan a pitstop. |
| planDriverSwap | - | Race Engineer | This is a special form of *planPitstop*, which is only available in team races. Jona is asked to plan the next pitstop for the next driver according to the stint plan of the session. |
| preparePitstop | - | Race Engineer | *preparePitstop* triggers Jona, the AI Race Engineer, to prepare a previously planned pitstop. |

### Controlling coaching by the Driving Coach

These functions let you start and top coaching by the Driving Coach and let you choose between the different coaching modes.

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| startTelemetryCoaching | confirm, auto | Driving Coach | Initiates telemetry data collection by the Driving Coach. After a few laps the Coach will be ready to discuss your performance with you. If *confirm* is supplied and *false*, no confirmation is given by the Driving Coach. If *auto* is supplied and *true* or "Track", the Driving Coach will start to give corner by corner instructions, once telemetry is available. If "Brake" is supplied, the Coach will give braking instructions. |
| finishTelemetryCoaching | confirm | Driving Coach | Stops the telemetry based coaching mode of the Driving Coach. |
| startTrackCoaching | confirm | Driving Coach | Instructs the Driving Coach to give corner by corner instructions while you are driving. If *confirm* is supplied and *false*, no confirmation is given by the Driving Coach. If *confirm* is supplied and *false*, no confirmation is given by the Driving Coach. |
| startBrakeCoaching | confirm | Driving Coach | Instructs the Driving Coach to give hints while you are driving where and how to brake. If *confirm* is supplied and *false*, no confirmation is given by the Driving Coach. If *confirm* is supplied and *false*, no confirmation is given by the Driving Coach. |
| finishCoaching | - | Driving Coach | Stops the Driving Coach to any instructions while you are driving. |

### Feature activation and general control functions

1. Enabling or disabling installed functions and features.

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| enableListening | - | Voice Control | Fully enables voice recognition again after it has been disabled using *disableListening*. |
| disableListening | - | Voice Control | Fully disables voice recognition for all currently active conversation partners. Listening will also be disabled for all conversation partners, which are started afterwards. No microphone input will be processed until the listening is enabled again using *enableListening*. |
| enableDataCollection | type | Race Engineer, Race Strategist | This enables the transfer of data of the given *type* to the session database again, after it had been disabled previously by calling *disableDataCollection*. *type* must be one of "Pressures" for cold pressures information collected by the Race Engineer or "Laps" for strategy-related data collected by the Race Strategist.<br><br>Good to know: The data is still being collected and used for any purpose during the session, but will not be stored in the database at the end of the session. |
| disableDataCollection | type | Race Engineer, Race Strategist | This disables the transfer of data of the given *type* to the session database at the end of the session. *type* must be one of "Pressures" for cold pressures information collected by the Race Engineer or "Laps" for strategy-related data collected by the Race Strategist. Use this in sessions, if you don't want the data to be permanently stored, because you are in a race with 2x fuel consumption for example. Please note, that calling *disableDataCollection* only affects the Race Assistants directly. Any data collected in the "Solo Center" for example can still be transfered to the session database manually.<br><br>Good to know: The data is still being collected and used for any purpose during the session, but will not be stored in the database at the end of the session. |
| enableRaceAssistant | name | Race Engineer, Race Strategist, Race Spotter | Enables the Race Assistant with the given *name*, which must be one of : Race Engineer, Race Strategist or Race Spotter. |
| disableRaceAssistant | name | Race Engineer, Race Strategist, Race Spotter | Disables the Race Assistant with the given *name*, which must be one of : Race Engineer, Race Strategist or Race Spotter. |
| enablePedalVibration | - | Tactile Feedback | Enables the pedal vibration motors, that might be mounted to your pedals. Available depending on the concrete configuration. |
| disablePedalVibration | - | Tactile Feedback | Disables the pedal vibration motors, that might be mounted to your pedals. Available depending on the concrete configuration. |
| enableFrontChassisVibration | - | Tactile Feedback | Enables the chassis vibration bass shakers that might be mounted to the front of your simulation rig. Available depending on the concrete configuration. |
| disableFrontChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the front of your simulation rig. Available depending on the concrete configuration. |
| enableRearChassisVibration | - | Tactile Feedback | Enables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| disableRearChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| disableRearChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| startMotion | - | Motion Feedback | Starts the motion feedback system of your simulation rig. Available depending on the concrete configuration. |
| stopMotion | - | Motion Feedback | Stops the motion feedback system of your simulation rig and brings the rig back to its resting position. Available depending on the concrete configuration. |
| enableTrackMapping | - | Race Spotter | Enables track mapping. If the track is not a circuit, track mapping will start immediately, otherwise it will start at the beginning of the next lap. |
| disableTrackMapping | - | Race Spotter | Disables track mapping. If the track track scanner has been active, a track map will be created in the next step. |
| enableTrackAutomation | - | Race Spotter | Enables the track automation. Can be called anytime, the automation will be activated at the beginning of the next lap. |
| disableTrackAutomation | - | Race Spotter | Disables the track automation. No further actions will be executed. |
| enableTeamServer | - | Team Server | Enables the team mode and opens a connection to the currently configured Team Server. Must be called before session start. |
| disableTeamServer | - | Team Server | Disables the team mode and closes the connection to the Team Server. |

2. Starting and stoping a simulation or one of the tools of Simulator Controller.

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| startSimulation | [Optional] simulator | System | Starts a simulation game. If the simulator name is not provided, the first one in the list of configured simulators on the *General* tab is used. |
| stopSimulation | - | System | Stops the currently running simulation game. |
| openRaceSettings | import | Race Engineer, Race Strategist, Team Server | Opens the settings tool, with which you can edit all the race specific settings, Jona needs for a given race. If you supply *true* for the optional *import* parameter, the setup data is imported directly from a running simulation and the dialog is not opened. |
| openSetupWorkbench | - | Race Engineer | Opens a tool, which generates recommendations for changing the setup options of a car based on problem descriptions provided by the driver. |
| openRaceReports | - | Race Strategist | Opens the bowser for the post race reports generated by the AI Race Strategist. If a simulation is currently running, The simulation, car and track will be preselected. |
| openSessionDatabase | - | Race Engineer, Race Strategist | Opens the tool for the session database, with which you can get the tyre pressures for a given session depending on the current environmental conditions. If a simulation is currently running, most of the query arguments will already be prefilled. |
| openStrategyWorkbench | - | Race Strategist | Opens the "Strategy Workbench" tool, with which you can explore the telemetrie data for past session, as long as they have been saved by the Race Strategist, and with which you can create a strategy for an upcoming race. If a simulation is currently running, several selections (car, track, and so on) will already be prefilled. |
| openSoloCenter | - | Race Engineer, Race Strategist | Opens the "Team Center" tool, with which you can optimize your practice sessions and collect the most relevant data. |
| openTeamCenter | - | Race Engineer, Race Strategist, Team Server | Opens the "Team Center" tool, with which you can analyze the telemetry data of a running team session, plan and control pitstops and change race strategy on the fly. |

### Runtime and host language interface

These functions are not meant to be used by the general user.

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| setDebug | debug | Builtin | Enables or disables debugging. *debug* must be either *true* or *false*. |
| setLogLevel | logLevel | Builtin | Sets the log level. *logLevel* must be one of "Debug", "Info", "Warn", "Critical" or "Off", where "Debug" is the most verbose one. |
| increaseLogLevel | - | Builtin | Increases the log level, i.e. makes the log information more verbose. |
| decreaseLogLevel | - | Builtin | Decreases the log level, i.e. makes the log information less verbose. |
| invoke | target, method, [Optional] argument, ... | System | Invokes an internal method. *target* may be either "Controller" (or "Simulator Controller") for a method of the single controller instance itself or the name of a registered plugin or a name of a mode in the format *plugin*.*mode* and *method* is the name of the method to invoke for this target. You can supply any number of arguments to the invocation call. |
| shutdownSystem | - | System | Displays a dialog and asks, whether the PC should be shutdown. Use with caution. |