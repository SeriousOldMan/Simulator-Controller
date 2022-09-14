Using Simulator Controller is quite easy. The most difficult part will be the configuration, but fortunately, this has to be done only once. Please see the extensive [Installation & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) guide for more information about this task.

Once you have configured everything for your simulation rig, there are two applications, which you will use while having fun with your simulations. Both applications are located in the *Binaries* folder. Normally, you will run *Simlator Startup.exe* to set the stage for everything. Depending on your choices during your initial installation, you will find a link to this program on your desktop and/or the Windows Start menu. Using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) you can also decide, whether *Simulator Startup* will be run automatically whenever your PC is started. When you run *Simlator Startup.exe*, you will see the following window:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Launch%20Pad.JPG)

This window will give you access to all applications of Simulator Controller. You will get some information about a given application, when you hover with the mouse above the icon. Beside starting any of the applications and tools of Simulator Controller, you can continue the startup process of all the components you need, when running a simulation, by clicking on the top left icon. Depending on your concrete configuration, *Simulator Startup* will then start all the configured component applications including *Simulator Controller.exe*, which will be responsible for the essential part, the control of all your simulation applications and simulator games using your hardware controller. Put a check mark in the check box in the lower left corner, when you want the launch window to be closed automatically, when you enter your simulation.

If you want to download and install a new version of Simulator Controller, it is important that none of the applications of the suite is running during the update. Please use the button "Close All..." in the lower right corner just before running the update.

Note: If you don't want to use the launch window and want *Simulator Startup* to run through, create a shortcut and add the option "-NoLaunchPad" to the *Target* field. When you use this shortcut file, no launch window will be shown, unless you hold down the Shift key, while running *Simulator Startup*. The other way around can also be used: If you press the Shift key while running *Simulator Startup* normally, no launch window will be shown and the startup process will run directly.

## Startup Process & Settings

Before starting up, *Simulator Startup* checks the configuration information. If there is no valid configuration, a tool to edit the settings and supply a valid configuration will be launched automatically. You can trigger this anytime later by holding down the Control key when clicking on the Startup icon in *Simulator Startup*. The following settings dialog will show up:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Settings%20Editor.JPG)

With this editor, which is also available as a separate application named *Simulator Settings.exe*, you can change the runtime settings for Simulator Controller. In contrast to the general configuration, which configures all required and optional components of your simulation rig, here you decide which of them you want to use for the next run and onward and how they should behave. Please note, that you can click on the blue label of the dialog title, which will open this documentation in your browser.

Beside maintaining this startup configuration, you can jump to the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) by clicking on the button "Configuration...". This might be helpful, if you detect an error in your simulation rig configuration or if you want to add a new simulation game, you just installed on your PC.

### Customizing Startup Configuration

In the first group, you can decide which of the core applications configured in the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications) of the configuration tool should be started during the startup process. Normally you want to start all of them, after all they are core applications, right? But there can be situations, where things might look a little bit different and these application are not needed or even would create problems. For example, you want to deactivate a voice control software, if you're taking part in an 24h race event and will have a voice chat with your team colleagues. It might not be helpful, if your voice control software would kick in and will stop your simulation while you are on your best lap of your life.

The second group lets you decide whether to start the different feedback components of your simulation rig. In the configuration, that is part of the standard distribution of Simulator Controller, feedback is handled by the ["Tactile Feedback"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-tactile-feedback) and ["Motion Feedback"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-motion-feedback) plugins, which on their side will use the [SimHub](https://www.simhubdash.com/) and [SimFeedback](https://www.opensfx.com/) applications to implement their functionalities. These two applications may be started in advance during the startup process, but they also can be started later from your hardware controller. Me, myself and I, for example, almost always start *SimHub* in advance, since I will always use vibration effects to get a better understanding about what my tyres are doing, but I will start motion feedback later depending on the track and the kind of driving, I am in (training, racing, having fun with friends, and so on).

### Customizing Controller Notifications

In the next group, you can decide, how Simulator Controller will notify you about state changes in your simulation rig or in the applications under control of Simulator Controller. Two types of notifications are supported, for Tray Tips (small message windows popping up in lower right corner of your main screen) and for Button Boxes, the visual representation of your controller hardware. Depending on the situation you are in (in simulation game or not), you might want to use different notifications or no notifications at all. You can configure, how long in milliseconds the Tray Tip or the Button Box windows will stay open. For the Button Boxes, a duration of 9999 ms will be interpreted as *forever*, so the window will be kept open all the time. Also, you can decide where the Button Boxes will appear. To do that, choose one of the corners of your main screen in the dropdown list below the notification duration input fields.

### Configuration of the Controller Mode automation

If you click on then button "Controller Automation...", a new dialog will open up, where you can select predefined Modes for your connected hardware controller.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Automation%20Editor.JPG)

You can choose the context with the first two dropdown menus, for example 1. when no simulation is running or 2. when you are in a given simulator and there in a practice session. Then you select the *Modes* (see the documentation for [Plugins & Modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for more information), which will be automatically activated for this context. Please note, that more than one mode will only make sense, if you have more than one hardware controller connected, and when each mode only use one of these hardware controllers exclusively.

### Themes configuration

In the lower part of the configuration dialog, you can choose the type of [splash theme](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor), which will be used for your entertainment during the startup process. Please see the [installation guide](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#using-your-own-pictures-videos-and-sounds-for-all-the-splash-screens) on how to install your own media files in a special location in your *Documents* folder and hot to use the themes editor. If you decide to play a song while starting your Simulator Controller applications and even your favorite simulation game, the song will keep playing until you press the left mouse button or the Escape key, even if *Simulator Startup* has exited already.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Splash%20Screen.JPG)

Last, but not least, you can choose a simulation game from your list of Simulators and start it automatically, after all other startup tasks have finished.

### More Settings & Configurations

Here is an overview for the all settings and configuration options for the various parts of Simulator Controller:

  1. *Simulator Settings*
  
     Maintained by the "Simulator Settings" application and stored in the *Simulator Settings.ini* file in the *Simulator Controller\Config* folder in your user *Documents* folder. As described [above](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--settings), these settings influence the startup process of Simulator Controller and where on your screen the visual representations of your Button Boxes will appear.

  2. *Simulator Configuration*
  
     Maintained by the "Simulator Configuration" and the more simple "Simulator Setup" applications and stored in *Simulator Configuration.ini*, *Button Box Configuration.ini* and *Stream Deck Configuration.ini* files in the *Simulator Controller\Config* folder in your user *Documents* folder. This configuration contains the complete configuration of all your hardware and software with regards to Simulator Controller. Typically this will be very static, once you have found a satisfying configuration, at least, until you add another piece of hardware or new software. See the documentation for the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) for more information.

  3. *Race (Assistant) Settings*
  
     Maintained by the "Race Settings" and "Session Database" applications and stored in the *Race.settings* file in the *Simulator Controller\Config* folder in your user *Documents* folder. Whenever you start a race (or even a training session), the Virtual Race Assistants will use these settings to control various functionality, for example, how to react to damages, when to change tyres after a severe weather change, and so on. You can edit these settings with the "Race Settings" application just before each session, or you can manage a lot of the setting values by using the "Session Database" application and store default values depending on a given car / track / weather combination. See the [corresponding documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings) for more information.

## Using Simulator Controller

After closing the configuration dialog, the actual startup process begins. Normally, you will be greeted by a splash screen and will see a pogress bar which informs you about what the system is currently doing. If you decide to stop the startup process, you can do this by pressing Escape anytime. If you decide that you want to start your favorite simulation (the first one in the Simulators list (see the [General tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-general) in the configuration tool) after the startup process has finished, you can do this by holding down the Control key during the startup process, even if you haven't checked the startup option in the configuration dialog above.

After the startup process has completed, the splash screen of *Simulator Startup* may stay open still playing a video or showing pictures, unless a simulation has been started as well. You can close it anytime by pressing Escape or it will disappear automatically, when a simulator starts up. But the background process *Simulator Controller.exe* including all the configured [plugins](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) will keep running and now is in complete control of your simulation rig. Depending on your configuration, you will see the visual representation of your controller hardware, i.e. a Button Box.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%201.JPG)

Normally, the active mode on your hardware controller will be the "Launch" mode, so that you can launch additional applications by the touch of a button. For a complete documentation on everything available in the "Simulator Controller" application, please consult the documentation about [Plugins & Modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes).

Normally, it is not necessary to close *Simulator Controller.exe*, since it is very efficient and does not use many system resources. But if necessary, you can locate its icon, a small silverish gear, in the System Tray (at the lower right side of the Windows taskbar), right click the icon and choose Exit.

### Enabling and disabling features

Simulataor Controller is a modular software and consists of many functions, which can be enabled or disabled during runtime. Beside using buttons on your hardware controller to enable or disable these functions, for example the connection to the Team Server or whether Track Automations will be active during the current session, you can also control most of them from the tray menu of the "Simulator Controller" application. Please don't touch the options in the "Support" submenu, unless told you so when tracking down problems.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Simulator%20Controller%20Menu.JPG)

### Voice Commands

The Simulator Controller framework supports a sophisticated natural language interface. This capability is used by the Race Assistants Jona and Cato, thereby allowing a fully voice enabled dialog between you and these Assistants, but the voice recognition can also be used to control parts of your controller hardware by voice commands.

With the introduction of a new Race Assistant in Release 3.1 there are now several different *communication partners* and it is very important that the system understands, to whom you are talking. Therefore an activatiom command, very simular to other digital Assistants like Alexa or Cortana, has been introduced. For the Assistants Jona and Cato this is the call phrase "Hey %name%", where %name% is the configured name of the Assistant. For example, if you say "Hi Jona" or "Jona, can you hear me?" for example (as long as you sticked to the preconfigured name "Jona"), the Virtual Race Engineer will start to listen to the following commands. Jona will give you a short answer, so you know that the activation was successful. Beside this activation, the dedicated listen mode will also be activated, when any of the Assistants has asked you a question and is waiting for the answer. The listen mode of the Simulator Controller itself, which allows you to trigger [controller actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller) by voice, must be activated by an activation command as well, if you have more than one dialog partner active. This activation command can be configured in the [voice control tab of the configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control). When this activation command is recognized, you will hear a short chime tone as confirmation and the system is ready to activate controller actions by voice. Please note, that you also hear a different short tone, when you have pressed the [Push To Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) control in order to tell you, that you can issue your voice command.

Important: In order to reduce confusion of an activation command with a normal command given to the currently active *dialog partner*, the [Push To Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) control has two different behaviours. If you simply press the configured control, for example a button on your steering wheel, you will talk to the currently active *dialog partner*. Whenever you press the control twice like double clicking a mouse button, you will activate a special listener, which only accepts the activation phrases. The last button press of the *double press* must be held down as long as you speak.

#### Push-To-Talk behaviour

Beside the behaviour of the Push-To-Talk button described above, where you need to hold down the button as long as your are talking, there is an alternative mode available. This mode allows you to release the button while you are talking. Once, you have finished your voice command, you press the Push-2-Talk button again, to indicate that you have finished and that the command should be executed. This alternative mode can be activated either by chossing the corresponding preset in "Simulator Setup" or by copying the file "P2T Configuration.ini" from the *Resources\Templates* directory from the program folder too the *Simulator Controller\Config* directory which resides in your user *Documents* folder.

#### Testing voice configuration and voice commands

*After* you have finished all the required [installation and configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) steps (especially for the [voice support](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#installation) of the Assistants), you can test the dialog with two different Assistants. To do this, please open a Windows command shell (type Windows-R => cmd => Return), go to the *Binaries* folder of the Simulator Controller distribution and enter the following commands:

	D:\Controller\Binaries>"Voice Server.exe" -Debug true

	D:\Controller\Binaries>"Race Engineer.exe" -Debug true -Speaker true -Listener true -Language DE -Name Jona -Logo true

	D:\Controller\Binaries>"Race Strategist.exe" -Debug true -Speaker true -Listener true -language EN -Name Cato -Logo true
	
Both, the Virtual Race Engineer and the Virtual Race Strategist will start up and will listen to your commands (Jona will be a german personality, while Cato will use English to talk with you). Please note, that if you configured [Push To Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) in the configuration, you need to hold the respective button, while talking. Since no simulation will be running during your test, the functionality of Jona und Cato will be quite restricted, but you may switch between those Assistants using the activation phrase and you may ask some questions like "Is rain ahead?" or "Wird es regnen?". You may also start the Virtual Race Spotter here, but this will be of no big use, since the Spotter does not answer many questions.

Note: If there is only *one* dialog partner configured, this will be activated for listen mode by default. In this situation, no activation command is necesssary.

Beside the *builtin* voice recognition capabilities, you can still use specialized external voice recognition appplications like [VoiceMacro](http://www.voicemacro.net/) as an external event source for controller actions, since these specialized applications might have a better recognition quality in some cases.

#### Jona, the Virtual Race Engineer

Release 2.1 introduced Jona, an artificial Race Engineer as an optional component of the Simulator Controller package. Since Jona is quite a complex piece of software with its natural language interface, it is fully covered in a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer).

#### Cato, the Virtual Race Strategist

Using the technology developed for Jona, Release 3.1 introduced an additional Race Assitant. This Assistant is named Cato and is a kind of Race Strategy Expert. It is also fully covered in a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist).

#### Elisa, the Virtual Race Spotter

The third Assistant, Elisa, is not so much of a dialog partner, but gives you crucial information about the traffic, your opponents and the current race situation. See the separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist) for more information.

### Controller Commands

If you have configured one or more hardware controllers (Button Boxes and/or Stream Decks), you will have the possibility to trigger almost all commands for the Virtual Race Assistants and other functionalities of Simulator Controller with your hardware. Sometimes it will be much more convinient (and faster) to tell Jona to plan the upcoming pitstop with a simple press of a button. You will find a complete overview and instructions on how to configure all those controller actions in the documentation about [Plugins & Modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) or you can use "Simulator Setup", which provides a graphical point and click environment to configure controller actions.

Please note, that you can mix voice commands and commands triggered by the controller hardware freely, so choose your weapon depending on the current situation on the track.

### External Commands

There is also the possibility to trigger actions in Simulator Controller from other applications. There are several ways to do this, but the most easy ones are:

1. Keyboard commands

   As you have seen in the chapter about [Installation & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration), every action or command in Simulator Controller can be activated and controller from hardware controller like Button Boxes or Stream Decks, but you can also define keyboard shortcuts, called Hotkeys, to achieve the same effect. These keyboard shortcuts can be triggered not only from the keyboard, but also from other applications, as long as they are able to send events to other applications.

2. Command scripts

   Not every application can easily send keyboard commands to other applications, for example Windows .BAT or .CMD scripts. A second method exists therefore, that uses a script file as an interface. You can create a file named "Controller.cmd" in the *Simulator Controller\Temp* folder which resides in your user *Documents* folder. This file is checked every 100 ms, and if it is not empty, it will be processed and afterwards deleted. Here is in example for a "Controller.cmd":
   
	2WayToggle.1 On
	Button.1
	Button.2
	Dial.4 Decrease
	
   This will achieve the same effect as pushing or rotating the corresponding controls on your hardware controller. See the [corresponding documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller) to see which controller functions (*1WayToggle*, *2WayToggle*, *Button*, *Dial* and *Custom*) are available and especially how to define *Custom* controller functions (which are typically not assiciated with a Button Box or a Stream Deck) using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration). As you have seen in the above example, you must use *On* and *Off* as a second argument for *2WayToggle*, and *Increase* and *Decrease* for *Dial*, to specify the desired change.

   A last note for experienced users: Together with the [*execute* controller action function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller), you can create powerful macros. Create a *Custom* controller function, which can be triggered by a button, for example on your steering wheel. This *Custom* function *executes* a Windows command script wich the writes a "Controller.cmd" file as described above.

## And now it's time

...to have some fun. If you like Simulator Controller and find it useful, I would be very happy about a small donation, which will help in further development of this software. Please see the [README](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/README.md) for the donation link. Thanks and see you on the track...
