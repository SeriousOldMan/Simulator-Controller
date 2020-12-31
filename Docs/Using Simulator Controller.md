Using Simulator Controller is quite easy. The most difficult part will be the configuration, but fortunately, this has to be done only once. Please see the extensive [Installation & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) guide on more information about this task.

Once you have configured everything for your simulation rig, there are two applications, which you will use while having fun with your simulations. Both applications are located in the *Binaries* folder. Normally, you will run *Simlator Startup.exe* to set the stage for everything and therefore it might be a good idea to place a link to this application in the Windows Start menu. Using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) you can also decide, whether this *Simulator Startup* will be run automatically whenever your PC is started. Depending on your concrete configuration, *Simulator Startup* will then start all the configured component applications including *Simulator Controller.exe*, which will be responsible for the essential part, the control of all your simulation applications and simulator games using your hardware controller.

## Startup Process & Settings

Before starting up, *Simulator Startup* checks the configuration information. If there is no valid configuration, a tool to edit the settings and supply a valid configuration will be launched automatically. You can trigger this anytime later by holding down the Control key when running *Simulator Startup*. The following settings dialog will show up:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Settings%20Editor.jpg)

With this editor, which is also available as a separate application named *Simulator Settings.exe*, you can change the runtime settings for Simulator Controller. In contrast to the general configuration, which configures all required and optional components of your simulation rig, here you decide which of them you want to use for the next run and onward and how they should behave.

Beside maintaining this startup configuration, you can jump to the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) by clicking on the button "Configuration...". This might be helpful, if you detect an error in your simulation rig configuration or if you want to add a new simulation game, you just installed on your PC.

### Customizing Startup Configuration

In the first group, you can decide which of the core appications configured in the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications) of the configuration tool should be started during the startup process. Normally you want to start all of them, after all they are core applications, right? But there can be situations, where things might look a little bit different and these application are not needed or even would create problems. For example, you want to deactivate a voice control software, if you're taking part in an 24h race event and will have a voice chat with your team colleagues. It might not be helpful, if your voice control software would kick in and will stop your simulation while you are on your best lap of your life.

The second group lets you decide whether to start the different feedback components of your simulation rig. In the configuration, that is part of the standard distribution of Simulator Controller, feedback is handled by the ["Tactile Feedback"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-tactile-feedback) and ["Motion Feedback"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-motion-feedback) plugins, which on their side will use the [SimHub](https://www.simhubdash.com/) and [SimFeedback](https://www.opensfx.com/) applications to implement their functionalities. These two applications may be started in advance during the startup process, but they also can be started later from your hardware controller. Me, myself and I, for example, almost always start *SimHub* in advance, since I will always use vibration effects to get a better understanding about what my tires are doing, but I will start motion feedback later depending on the track and the kind of driving, I am in (training, racing, having fun with friends, and so on).

### Customizing Controller Notifications

In the next group, you can decide, how Simulator Controller will notify you about state changes in your simulation rig or in the applications under control of Simulator Controller. Two types of notifications are supported, Tray Tips (small message windows popping up in lower right corner of your main screen) and the Button Box, the visual representation of your controller hardware. Depending on the situation you are in (in simulation game or not), you might want to use different notifications or no notifications at all. You can configure, how long in milliseconds the Tray Tip or the Button Box window will stay open. For the Button Box, a duration of 9999 ms will be interpreted as *forever*, so the window will be kept  open all the time. Also, you can decide where the Button Box will appear. To do that, choose one of the corners of your main screen in the dropdown list below the notification duration input fields.

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

## And now it's time

...to have some fun. If you like Simulator Controller and find it useful, I would be very happy about a small donation, which will help in further development of this software. Please see the [README](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/README.md) for the donation link. Thanks and see you on the track...
