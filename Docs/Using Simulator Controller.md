Using Simulator Controller is quite easy. The most difficult part will be the configuration, but fortunately, this has to be done only once. Please see the extensive [Installation & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) guide for more information about this task.

Once you have configured everything for your simulation rig, there are two applications, which you will use while having fun with your simulations. Both applications are located in the *Binaries* folder. Normally, you will run *Simlator Startup.exe* to set the stage for everything and therefore it might be a good idea to place a link to this application in the Windows Start Menu. Using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) you can also decide, whether this *Simulator Startup* will be run automatically whenever your PC is started. Depending on your concrete configuration, *Simulator Startup* will then start all the configured component applications including *Simulator Controller.exe*, which will be responsible for the essential part, the control of all your simulation applications and simulator games using your hardware controller.

## Startup Process & Settings

Before starting up, *Simulator Startup* checks the configuration information. If there is no valid configuration, a tool to edit the settings and supply a valid configuration will be launched automatically. You can trigger this anytime later by holding down the Control key when running *Simulator Startup*. The following settings dialog will show up:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Settings%20Editor.JPG)

With this editor, which is also available as a separate application named *Simulator Settings.exe*, you can change the runtime settings for Simulator Controller. In contrast to the general configuration, which configures all required and optional components of your simulation rig, here you decide which of them you want to use for the next run and onward and how they should behave. Please note, that you can click on the blue label of the dialog title, which will open this documentation in your browser.

Beside maintaining this startup configuration, you can jump to the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) by clicking on the button "Configuration...". This might be helpful, if you detect an error in your simulation rig configuration or if you want to add a new simulation game, you just installed on your PC.

### Customizing Startup Configuration

In the first group, you can decide which of the core appications configured in the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications) of the configuration tool should be started during the startup process. Normally you want to start all of them, after all they are core applications, right? But there can be situations, where things might look a little bit different and these application are not needed or even would create problems. For example, you want to deactivate a voice control software, if you're taking part in an 24h race event and will have a voice chat with your team colleagues. It might not be helpful, if your voice control software would kick in and will stop your simulation while you are on your best lap of your life.

The second group lets you decide whether to start the different feedback components of your simulation rig. In the configuration, that is part of the standard distribution of Simulator Controller, feedback is handled by the ["Tactile Feedback"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-tactile-feedback) and ["Motion Feedback"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-motion-feedback) plugins, which on their side will use the [SimHub](https://www.simhubdash.com/) and [SimFeedback](https://www.opensfx.com/) applications to implement their functionalities. These two applications may be started in advance during the startup process, but they also can be started later from your hardware controller. Me, myself and I, for example, almost always start *SimHub* in advance, since I will always use vibration effects to get a better understanding about what my tires are doing, but I will start motion feedback later depending on the track and the kind of driving, I am in (training, racing, having fun with friends, and so on).

### Customizing Controller Notifications

In the next group, you can decide, how Simulator Controller will notify you about state changes in your simulation rig or in the applications under control of Simulator Controller. Two types of notifications are supported, Tray Tips (small message windows popping up in lower right corner of your main screen) and the Button Box, the visual representation of your controller hardware. Depending on the situation you are in (in simulation game or not), you might want to use different notifications or no notifications at all. You can configure, how long in milliseconds the Tray Tip or the Button Box window will stay open. For the Button Box, a duration of 9999 ms will be interpreted as *forever*, so the window will be kept  open all the time. Also, you can decide where the Button Box will appear. To do that, choose one of the corners of your main screen in the dropdown list below the notification duration input fields.

### Configuration of the Controller Mode automation

If you click on then button "Controller Automation...", a neeew dialog will open up, where you can select predefined Modes for your connected hardware controller.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Automation%20Editor.JPG)

You can choose the context with the first two dropdown menus, for example 1. when no simulation is running or 2. when you are in a given simulator and there in a practice session. Then you select the *Modes* (see the documentation for [Plugins & Modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for more information), which will be automatically activated for this context. Please note, that more than one mode will only make sense, if you have more than one hardware controller connected, and when each mode only use one of these hardware controllers  exclusively.

### Other Settings

In the lower part of the configuration dialog, you can choose the type of [splash theme](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor), which will be used for your entertainment during the startup process. Please see the [installation guide](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#using-your-own-pictures-videos-and-sounds-for-all-the-splash-screens) on how to install your own media files in a special location in your *Documents* folder and hot to use the themes editor. If you decide to play a song while starting your Simulator Controller applications and even your favorite simulation game, the song will keep playing until you press the left mouse button or the Escape key, even if *Simulator Startup* has exited already.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Splash%20Screen.JPG)

Last, but not least, you can choose a simulation game from your list of Simulators and start it automatically, after all other startup tasks have finished.

## Using Simulator Controller

After closing the configuration dialog, the actual startup process begins. Normally, you will be greeted by a splash screen and will see a pogress bar which informs you about what the system is currently doing. If you decide to stop the startup process, you can do this by pressing Escape anytime. If you decide that you want to start your favorite simulation (the first one in the Simulators list (see the [General tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-general) in the configuration tool) after the startup process has finished, you can do this by holding down the Control key during the startup process, even if you haven't checked the startup option in the configuration dialog above.

After the startup process has completed, the splash screen of *Simulator Startup* may stay open still playing a video or showing pictures. You can close it anytime by pressing Escape or it will disappear automatically, when a simulator starts up. But the background process *Simulator Controller.exe* including all the configured [plugins](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) will keep running and now is in complete control of your simulation rig. Depending on your configuration, you will see the visual representation of your controller hardware, i.e. a Button Box.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%201.JPG)

Normally, the active mode on your hardware controller will be the "Launch" mode, so that you can launch additional applications by the touch of a button. For a complete documentation on everything available in the *Simulator Controller* application, please consult the documentation about [Plugins & Modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes).

Normally, it is not necessary to close *Simulator Controller.exe*, since it is very efficient and does not use many system resources. But if necessary, you can locate its icon, a small silverish gear, in the System Tray (at the lower right side of the Windows taskbar), right click the icon and choose Exit.

### Voice Commands

The Simulator Controller framework supports a sophisticated natural language interface. This capability is used by the race assistants Jona and Cato, thereby allowing a fully voice enabled dialog between you and these assistants, but the voice recognition can also be used to control parts of your controller hardware by voice commands.

With the introduction of a new race assistant in Release 3.1 there are now several different *communication partners* and it is very important that the system understands, to whom you are talking. Therefore an activatiom command, very simular to other digital assistants like Alexa or Cortana, has been introduced. For the assistants Jona and Cato this is the call phrase "Hey %name%", where %name% is the configured name of the assistant. For example, if you say "Hi Jona" or "Jona, can you hear me?" for example (as long as you sticked to the preconfigured name "Jona"), the Virtual Race Engineer will start to listen to the following commands. Jona will give you a short answer, so you know that the activation was successful. Beside this activation, the dedicated listen mode will also be activated, when any of the assistants has asked you a question and is waiting for the answer. The listen mode of the Simulator Controller itself, which allows you to trigger [controller actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller) by voice, must be activated by an activation command as well, if you have more than one dialog partner active. This activation command can be configured in the [voice control tab of the configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control). When this activation command is recognized, you will hear a short chime tone as confirmation and the system is ready to activate controller actions by voice.

Important: In order to reduce confusion of an activation command with a normal command given to the currently active *dialog partner*, the [Push To Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) control has two different behaviours. If you simply press the configured control, for example a button on your steering wheel, you will talk to the currently active *dialog partner*. Whenever you press the control twice like double clicking a mouse button, you will activate a special listener, which only accepts the activation phrases. The last button press of the *double press* must be held down as long as you speak.

*After* you have finished all the required [installation and configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) steps (especially for the [voice support](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#installation) of the assistants), you can test the dialog with two different assistants. To do this, please open a Windows command shell (type Windows-R => cmd => Return), go to the *Binaries* folder of the Simulator Controller distribution and enter the following commands:

	D:\Controller\Binaries>"Voice Server.exe"

	D:\Controller\Binaries>"Race Engineer.exe" -Debug true -Speaker true -Listener true -Language DE -Name Jona -Logo true

	D:\Controller\Binaries>"Race Strategist.exe" -Debug true -Speaker true -Listener true -language EN -Name Cato -Logo true
	
Both, the Virtual Race Engineer and the Virtual Race Strategist will start up and will listen to your commands (Jona will be a german personality, while Cato will use English to talk with you). Please note, that if you configured [Push To Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) in the configuration, you need to hold the respective button, while talking. Since no simulation will be running during your test, the functionality of Jona und Cato will be quite restricted, but you may switch between those assistants using the activation phrase and you may ask some questions like "Is rain ahead?" or "Wird es regnen?"

Note: If there is only *one* dialog partner configured, this will be activated for listen mode by default. In this situation, no activation command is necesssary.

Beside the *builtin* voice recognition capabilities, you can still use a specialized external voice recognition appplications like [VoiceMacro](http://www.voicemacro.net/) as an external event source for controller actions, since this specialized applications have a much better recognition quality in most cases.

#### Jona, the Virtual Race Engineer

Release 2.1 introduced Jona, an artificial Race Engineer as an optional component of the Simulator Controller package. Since Jona is quite a complex piece of software with its natural language interface, it is fully covered in a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer).

#### Cato, the Virtual Race Strategist

Using the technology developed for Jona, Release 3.1 introduced an additional Race Assitant. This Assistant is named Cato and is a kind of Race Strategy Expert. It is also fully covered in a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist).

## And now it's time

...to have some fun. If you like Simulator Controller and find it useful, I would be very happy about a small donation, which will help in further development of this software. Please see the [README](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/README.md) for the donation link. Thanks and see you on the track...
