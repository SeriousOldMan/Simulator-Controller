Before we start, an important information for *First Time Users*: If you install Simulator Controller for the first time, you can skip the information below for the moment. This is only important for users, that already configured theier local installation and will want to keep this configuration information, but also want to integrate all the new features as well.

***

Beginning with Version 2.0 an automatic update procedure is available to bring a local configuaration database up to the new specs. After you installed the new realse package, the system will check, whether an update to the configuration database is necessary for this release (and possibly for releases, you left out) and will greet you with the following dialog:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Update%20Alert.JPG)

You have three possibilities here:

  1. If you choose "No", the application will continue and will use the currrent configuration information. Everything should work as expected, but some of the new features introduced by this and previous releases might be passive due to missing configuration information. But: If you start the application next time, the question will reappear to give you a chance to perform the update then.
  2. In the case of "Never", you will skip the automatic update and also all future questions. This can be undone, but requires some low level tweaking. More on that later.
  3. If you choose "Yes", the update procedure tries to incorporate all new configuration elements from the distribution into your local configuration database in the *Simulator Controller\Config* folder in your user *Documents* folder. This process will be described in detail below.
  
## Automated update procedure

Let's start with some low level information, to give you an understanding, what happens in the background, when an automated update is processed. A new file has been created in the *Simulator Controller\Config* folder. It is named *UPDATES* and keeps track of already performed updates. If it is missing or does not contain information for the current release (or releases you missed out), the update procedure will start. After the update finished sucessfully, this will be noted in the *UPDATES* file. And here is the trick, if you have chosen "Never" in the dialog above: Just open this file with a text editor and delete the lines for the releases in question and you will be fine.

When the automated update procedure runs, there are some standard task, that are performed for each release and there are release specific tasks. You will will find the release specific information for each release below. Typical standard tasks might be:

  * Update of all translation files
    
	If the release introduces new translations, the local translation files in the *Simulator Controller\Config* folder will be updated to include the new translatable items. It cannot give you a full tranlation, as long as the corresponding language is not part of the standard distribution, but you will be able to edit these items using the [translation tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#translations-editor).
  * Update of *Controller Plugin Labels.ini*
    
	New labels for the controller hardware, which has been introduced by plugin extension in the current release, will be automatically copied to your local file.
	
  * New configuration items in *Simulator Configuration.ini*
  
    This some sort of corner case. If a new configuration item has been introduced, it can be copied to your local configuration, but if this will make sense in combination with all your own configuration items depends on the functionality behind it. For example, enabling a wind motor fan in the configuration will not be very uselful, if your own rig does not have a wind motor at all. But, since in most cases it is of interest to at least see the new functionality in the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), all new configuration items will be copied to your local configuration file, as long as there is no conflict, for example duplicate controller functions. Please consult the documentation on each release below to get an overview of all the new configuration items.
	
The update procedure itself is handled by the application *Simulator Tools*. It is autmatically started and the other application, which detected the need for the update will wait, until the update finished successfully. You might want to start *Simulator Tools* manually, but in this case, it will also try to perform other maintenance tasks as well, which might result in warning messages, if your distribution is not configured for development. But you can safely ignore those warnings about missing compiler and so on, nothing harmful will happen.
Although the code, that handles all the update tasks, is integrated into *Simulator Tools*, the activation and, much more important, the dependencies are defined in the *Simulator Tools.targets* file. I do not recommend to change the contents of this file, but it might be helpful to take a look into the update rules, to get a better understanding of the things behind the curtain.

Note: Some of you might want to have more control. No problem. All the files in the *Simulator Controller\Config* folder are humand readable and using a text editor and some *Diff* tool, you can do everything the automated procedure does, on your own. But be sure to make a backup copy of all the files, just for peace of mind.

***

## Release 2.0

Release 2.0 introduces, beside the new automated update mechanism, a full rework of the *ACC* plugin for *Assetto Corsa Competizione*. See the *ACC* plugin documentation about the [new features](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) for an in depth introduction of pitstop management. To support this new functionality, there are new plugin arguments for the *ACC* plugin, which will be autmatically added to the plugin configuration item by the automated update procedure. Please use the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) to edit the arguments for the *ACC* plugin according to your needs.

Additionally, a set of new controller actions and controller functions has been introduced by this release to help you to connect an external event source like *VoiceMacro* to the *ACC* plugin to control all the pitstop settings with voice commands. You will find all the new controller actions in the [configuration documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions). After performing the automated update, you will find the new controller functions for those controller actions in the [*Controller* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller) of the configuration tool. Please use the editor to configure the functions *Custom* #13 up to *Custom* #32 according to your needs.

Another tweak will be necessary, if your are using *Assetto Corsa Competizione* with a language setting other than English or a screen resolution other than 5760 x 1080. To *understand* the Pitstop MFD state of *Assetto Corsa Competizione*, Simulator Controller searches for small picture elements in the graphics of the game window. As you can see below, this are language specific texts shown in the Pitstop MFD.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Pit%20Strategy%201.JPG)     ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Compound%201.JPG)     ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Screen%20Images/ACC/Select%20Driver%202.jpg)

All these pictures are located in the *Resources\Screen Images\ACC* folder in the installation folder of Simulator Controller, but you can *overwrite* these pictures by placing your own ones with identical names in the *Simulator Controller\Screen Images\ACC* folder in your user *Documents* folder. Use the Snipping Tool of Windows to create all the necessary pictures, it will only take a few minutes.

Hint: The "<Select Driver>" option might only be available in special multiuser server setups, whereas the "Strategy" option is available in every *Race* situation.

Last but not least, you need to configure *VoiceMacro*, if you want to use voice control to manage the pitstop settings in *Assetto Corsa Competizione*. This little donationware tool is not part of the Simulator Controller distribution, but it is a part of the [third party application](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications), which are tightely integrated into Simulator Controller. Even the first release already had voice control support, for example to start or stop a simulation game or fire up your motion feedback system, if there is one. Now, with the introduction of the pitstop management system, voice control might become an integral part of your ingame experience. You will find a *VoiceMarco* profile to start with in the *Profiles* folder of the Simulator Controller installation folder. Beside loading this profile, it is very important to tweak the voice recognition settings up to perfection to have the best possible experience while hunting for the lap of the gods. This might be easy, if you use a headset, but if you have a setup similar to mine (Open Webcam micro and 5.1 surround system), you will have a hard time to suppress false positives in voice recognition. I finally found a setting, which I can share here:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Voice%20Macro%20Settings.JPG)