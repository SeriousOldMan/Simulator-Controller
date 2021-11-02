# Installation

Installation is easy and fully automatic for the current version. Simply download and run the installer from the [GitHub project page](https://github.com/SeriousOldMan/Simulator-Controller#download-and-installation) (or simply click [here](https://cntr.click/Qt9gVs0)) and follow the instructions. You will have the option to install the Simulator Controller package in any location on your hard disks and you can decide to fully register Simulator Controller in Windows or to use a portable installation without updating the Registry. You may also create Start Menu and Desktop shortcuts according to your preferences. I strongly recommend to leave automatic updates ticked, unless you have a very unusual installation location.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Installation.JPG)

It is also recommended to run the configuration process directly after installing the software. But you won't do any harm if you postpone this task and read the rest of the documentation first. Simply start ["Simulator Setup"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-setup-tool) whenever you are ready.

The automatic Installer will always download and install the latest version of Simulator Controller (unless you hold the Shift and Control key down, then the latest development version is used). If you want to use a version other than the latest one, this is still possible, but you will have to download manually. Unzip it at any location you like, then go to the *Binaries* folder, and start the application "Simulator Tools". It will detect that a version of Simulator Controller is alraedy installed on your Computer and will update it accordingly. If you decide to install an earlier version than your current one this way, you might also have to use a backup copy of an earlier version of the *Simulator Controller* folder fron your user *Documents* folder, since there will be incompatibilities in most cases.

Notes: You will find an application "Simulator Download" in the *Binaries* folder. This application is identical to the automated installer mentioned above. Under normal circumstances it is not necessary to run this application on your own, but it might be helpful in situations where automatic updates have been deactivated during the initial installation. The installation options you have chosen during your initial installation will be saved in the file "Simulator Controller.install", which is located in the *Simulator Controller\Config* folder in your user *Documents* folder. This file looks like this:

	[Install]
	Type=Portable
	Location=D:\Controller
	[Updates]
	Automatic=false
	Verbose=false
	[Shortcuts]
	StartMenu=false
	Desktop=false

You are allowed to change the *[Updates]Automatic* option with a text editor, if you change your mind regarding automatic updates. You can also set *[Updates]Verbose* to *true*, if you want the above dialog window appear even during a normal update. Do **not** change any other options, please.

After you have installed Simulator Controller for the first time, the system will automatically detect any available newer versions. You will be asked once a day, whenever a new version is available, whether you want to download and install the new version. If you decide to install the newest version, downlaod and installation will be handled automatically for you. It is alos posssible here to do the downlaod manually. Unzip the download package and start the "Simulator Tools" application. It will update your installation and will delete the installation files afterwards.

After you have succesfully installed Simulator Controller for the first time, you will have to build a configuration for your simulation setup. There are two applications available to do this:

  - The first, ["Simulator Setup"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-setup-tool), which was introduced with Release 3.5, is an intelligent *Setup Wizard*, which guides you through the initial installation & configuration process. Many of the tasks described below will be handled automatically by this tool. After you have successfully completed the process using this tool, you will have a running installation of Simulator Controller completely customized to your environment. Please note, that "Simulator Setup" is automatically started after the initial installation, if you ticked the corresponding check box.
  - After you have finished the initial installation & configuration process and created your first running configuration using *Simulator Setup*, you might decide to use ["Simulator Configuration"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-configuration-tool) for all your further configuration tasks. This tool requires a much deeper knowledge about the inner workings of Simulator Controller, but will give you access to even more functionality compared to the more simple *Simulator Setup* tool. However, as long as you are happy with the options provided by *Simulator Setup*, I recommend to stick to this tool, since it is much easier and more fail-safe.

Before starting the configuration process, I would like to cover a few more details to help you understand the concepts and aspects of configuration. On the other hand, you can skip these for the time being and go straight to the instructions for the [*Setup Wizard*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-setup-tool):

## A Word about Antivirus Warnings

The programming language used for building Simulator Controller uses some really nasty tricks to control Windows applications, tricks also used by malware. Therefore, depending on your concrete Antivirus program, you may get some warnings regarding the Simulator Controller applications. I can assure you, that there's nothing about it. But you can read about these issues in the forums of [AutoHotkey](https://www.autohotkey.com/) itself. If your Antivirus programm allows exception rules, please define rules for the Simulator Controller applications, otherwise you need to have a beer and search for another Simulator Controller tool. Sorry...

## Storage of the configuration files of Simulator Controller

All our (configuration) files will be saved to the *Simulator Controller* folder in your user *Documents* folder. There are also locations in the program folder of Simulator Controller, where similar configuration files might be found. These files will be used, whenever you have not created your own configuration files, for example for translations. But your local folder will always be searched first, whenever a configuration file is looked up.

For your safety and your peace of mind, I recommend that you always make a backup of this folder, when you change your configuration or when you update Simulator Controller to a newer version.

## Unblocking of Applications & DLLs

Depending on your Windows security settings, Windows might not trust the binary files in the *Binaries* folder, because you downloaded them from an untrusted location on the internet. You have to *unblock* these files, in order to use them. Under normal circumstances, this is done automatically by the installer and the update procedure. But if you still face security warnings afterwards, it will be necessary to unblock these files manually. You can do this by checking the checkbox in the standard properties dialog. Do this for all applications and the DLL files in the *Binaries* folder.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Unblock.JPG)

You might still encounter execution errors later on because of Windows security restrictions. This is nothing I can change at the moment, at least not without buying an expensive certificate, that secures the source of the binaries. You will find a little Powershell script in the *Utilities* folder, which you can copy to the *Binaries* folder and execute it there with Administrator privileges. These are the commands, which need be executed:

	takeown.exe /F . /R /D N
	Get-ChildItem -Path '.' -Recurse | Unblock-File

## Installing additional components

As already mentioned in the [README](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/README.md#third-party-applications) file, you might want to install additional third party applications, that will be used and controlled by Simulator Controller or will enhance the overall user experience. "Simulator Setup" will guide you through the installation of all these applications, but you can do it on your own as well. Please take a look at the list of applications and decide, which ones you want to install during the installation & configuration process. If you want to start your own plugin development or even change the code of the Simulator Controller itself, you additionally need to install [AutoHotkey](https://www.autohotkey.com/) installed. Beginning with Release 2.1, an installation of [VisualStudio Community Edition](https://visualstudio.microsoft.com/de/vs/community/) might also be required, if you want do dig into the heavylifting part of telemetry data acquisition or voice recognition. But you can stick with the precompiled binaries from the distribution, if that is not your domain.

## Installation and configuration of the different Race Assistants

Release 2.1 introduced Jona, an artificial Race Engineer as an optional component of the Simulator Controller package. Since Jona is quite a complex piece of software, and also requires additional installation steps, you will find all necessary information about Jona in a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer). The configuration for Cato, a Virtual Race Strategist (introduced with Release 3.1), is very similar, since it is based on the same technology. Please see the [separate documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist) for more information. "Simulator Setup" will guide you through these configuration steps as well, but I strongly recommend reading the documentation chapters on Jona and Cato to better understand the concepts and relationships of these very powerful and at the same time complex components.

## Using your own pictures, videos and sounds for all the splash screens

The startup process of Simulator Controller can entertain you with splash images and even play videos and emotional songs while starting all the components or your favorite simulation game (no worry, this can be completely switched off using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), if you prefer a more reduced kind of life style). The standard distribution comes with some default media from the GT3 world, but, since every racer or even pilot might have a different taste, you can install your own media files. You will find all the standard media files in the *Resources\Splash Media* folder. For your own media, you can use any JPG, GIF, WAV or MP3 files, as long as the pictures and videos adhere to a strict 16:9 format. Last but not least, you can use the settings editor to choose between picture carousel or GIF animation, whether to play one of the sound files during startup, and so on. To keep the standard distribution clean, a *Simulator Controller\Splash Media* folder will be created by the configuration tool in your standard *Documents* folder, where you can store your media files. The "Simulator Configuration" tool allows you to [create a theme](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor) form all these files, which then can be selected for the various applications as default theme.

Note: Choosing media files depending on the currently selected simulation game is on the wish list for a future release :-)

## Special steps for *Assetto Corsa Compeitizione* and *RaceRoom Racinng Experience*

If you want to use the automated handling of the pitstop settings for the *Assetto Corsa Competizione* or *RaceRoom Racinng Experience* simulations, either manually by using your connected controller or controlled by one of the Race Assistants, you need to create small graphical elements, which Simulator Controller uses to detect and *understand* the currently chossen pitstop settings. You will find detailed instructions for this task in the documentation for the [*Assetto Corsa Competizione* plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling) and for the [*RaceRoom Racinng Experience* plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling-1).

# Configuration

The different components of Simulator Controller can be customized to a large extent. Part of this customization is handled by the installation & configuration process, which typically you need to do only once, unless the configuration of your simulation equipment change in the future. As mentioned, there is a special *Setup Wizard* available for the initial installation & configuration, whereas the somewhat more advanced configuration is handled by a specialized tool, which will be described in the following sections. Additional customization, which address the day to day operations and general appearance of  Simulator Controller, is possible by using separate settings dialogs. See the documentation on the [usage](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller) of Simulator Controller for more information.

## Running the Setup tool

The initial configuration after the first installation is handled by the tool *Simulator Setup*.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Setup%201.PNG)

This tool is self-explanatory to a great extent, so you don't have to read the remaining documentation, before you start your initial installation & configuration process. And you can repeat the installation & configuration process with *Simulator Setup* as many times as you want, since the tool will retain your work between sessions. The current state of the installation & configuration process is stored in the folder *Simulator Controller\Setup* in your *Documents* folder, if you want to make a backup of your currently chosen settings and options.

If you ever have the need to start with an empty, fresh configuration, you can do this either by deleting the *Simulator Controller\Setup* folder or you can hold the Shift and Control key down, while starting *Simulator Setup*. You will be asked, if you want to ignore all the saved settings and options.

Additionally, since the configuration files will only be created in the last step the process, you can experiment with the settings & options until you are satisfied with your choices. Doing this, you will learn a lot about the functionalities of Simulator Controller. If you decide to generate a new configuration in the last step of the installation & configuration step, backup files of all changed configurartion files (named *.bak) will be created automatically, so you can always rescue your current configuration, if something goes wrong.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Setup%202.JPG)

Three files will be created by the *Simulator Setup* tool at the end of the installation & configuration process, all of which are stored in the *Simulator Controller\Config* folder in your *Documents* folder:

  - *Simulator Configuration.ini*
    This is the main configuration file of Simulator Controller. You can customize every aspect of this file using the "Simulator Configuration" application after the initial installation & configuration process. See the remaining documentation for more information.
  - *Button Box Configuration.ini*
    This special configuration file describes the [layout and control elements](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts) of your connected hardware controller and Button Boxes.
  - *Simulator Settings.ini*
    This file is also created in the last step of "Simulator Setup" and is maintained in the future by the "Simulator Settings" application. It defines the [runtime and startup settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--settings) of Simulator Controller.

As already said, I recommend to stick to this tool for all your configuration tasks, unless you have a configuration need, which cannot be handled by "Simulator Setup". Please note, that ecach configuration change that you make with the "Simulator Configuration" tool, which is described in the following sections, will be overwritten, if you ever use "Simulator Setup" afterwards.

Here is a tip for very experienced users: It is possible to patch the generated configuration and/or settings files created by "Simulator Setup". To do this, create a *.ini file with those section/key/value information you want to substitute in or add to the final configuration and/or settings information, name them "Conifguration Patch.ini" or "Settings Patch.ini" and drop them into the *Simulator Controller\Setup* folder in your user *Documents* folder. Corresponding sample files can be found in the *Resources\Templates* folder.

## Running the Configuration tool

The more comprehesive configuration tool is located in the *Binaries* folder and is named *Simulator Configuration.exe*. If you start it, the following window will appear:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Editor.JPG)

The tool is divided in tabs for each aspect of the configuration process. You will find an explanation of each tab and its content below. Before you start experimenting with the configuration tool, be sure to make a backup copy of the current configuration file *Simulator Configuration.ini* in the *Config* folder, just to be safe. But you will always find a fresh copy in the *Resources\Templates* folder for your peace of mind. Generally, all your changes to the configuration files will be saved to the *Simulator Controller\Config* *Simulator Controller\Translations* folders in your user *Documents* folder.

Hint: Beside simply running the configuration tool by double clicking it, there are two hidden modifiers. First, if you hold the Control key down, additional options for developers will be available. These will automatically appear, when an active AutoHotkey installation is detected (by checking, if the folder C:\Program Files\AutoHotkey is available). Second, if ou hold the Control key and the Shift key simultneously  while starting the configuration tool, any currently available configuration file in the *Config* folder will be ignored and you will start with a fresh, completely empty configuration.

## Using the Configuration tool

The configuration tool consists of several pages or tabs. Below you will find a description of each tab. Beside the pages, there are the well known buttons "Ok", "Cancel" and "Apply".

Note: You will find field labels that look like well known hyperlinks at several places in the configuration tool. Yes, you can click on them and a context sensitive section of the this documentation will be opened in your browser. With the *Save* mode dropdown menu in the lower left corner of the configuration dialog you can choose between *Manual* and *Automatic* save mode of all your changes to list items in the different editors.

### Tab *General*

As the name of this tab suggests, some very general configuration options are provided. In the *Installation* group you can identify the root folder of the Simulator Controller installation - optional in most cases, but it may provide some performance benefits. The second path identifies the *NirCmd* executable, which is used by the Simulator Controller to control the sound volume of some simulation games. Optional, but helpful. See the [README](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications) for a link to the *NirCmd* download.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%201.JPG)

The second group, *Settings* allows you to choose whether the Simulator Controller will start together with Windows and whether it will run silently, i.e. without any splash animation or sound. With the button "Themes Editor..." you can jump to a special editor to customize the splash dialogs of various applications of Simulator Controller. See the chapter on the [themes editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor) for a complete explanation of themes. Last but not least you may choose a language for all user interface elements. English as the base language and a German translation are part of the Simulator Controller distribution, but you may define your own translations using the [translations editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#translations-editor), wich you can open by clicking on the small button next to the language drop down.

You can add all the simulation games installed on your PC to the list in the third group *Simulators*. For each entry here, you also need to create a similar named application entry in the applications tab. Please note, that the name of all simulation games, where a plugin exists for, may have a predefined name according to the roles of the plugin. The order of the entries in the *Simulators* list is important, at least the first one has a special role. More on that later. You can change the order with the "Up" and "Down" button, if an entry is selected. As with any list in the configuration tool, an entry must be selected with a double click for editing.

The last group, which is only present in developer mode as mentioned above, lets you activate the debug mode, define the log level and enter the path to an AutoHotkey installation on your PC (only necessary, if AutoHotkey has been installed to a location other than C:\Program Files\AutoHotkey). Be careful with the log level *Info*, since the log files found in the *Simulator Controller\Logs* folder found in the users *Documents* folder may grow quite fast. If you want to automatically build all *Visual Studio* applications and DLLs while running *Simulator Tools*, you must enter the path to the *MSBuild Bin* directory here es well. See the [documentation for *Simulator Tools*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#using-the-build-tool) for more information.

### Tab *Voice Control*

On this tab, you can configure the voice control support of Simulator Controller. Voice output is used by Jona, the [Virtual Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer) and Cato, the [Virtual Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist), to give you crucial information during a session. Jona and Ctato also support voice recognition, thereby allowing you a full interactive dialog with your race assistants. And, last but not least, Simulator Controller also supports voice input to give you complete hands free control over all possible commands. These commands can be configured in the [*Controller* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller) tab below. 

Voice output generation is built into the Windows operating system, but you might have to install (additional) voices depending on the Windows isntallation and language packs you have.

#### Installation of additional Voices

Almost every Windows installation already has builtin support for voice generation (called TTS, aka text-to-speech). If you want to install more voices (and Jona and Cato will use all of them according to the configured language), you might want to install some additional packages ("Simulator Setup" will guide you through this steps). Depending on your Windows license you can do this on the Windows Settings dialog as described in the [Microsoft documentation](https://support.microsoft.com/en-us/office/how-to-download-text-to-speech-languages-for-windows-10-d5a6b612-b3ae-423f-afa5-4f6caf1ec5d3) ([German version](https://support.microsoft.com/de-de/office/herunterladen-von-text-zu-sprache-sprachen-f%C3%BCr-windows-10-d5a6b612-b3ae-423f-afa5-4f6caf1ec5d3)). The current language support of zhe Race Assistants comes with translations for English and German, as these are the languages supported by Simulator Controller out of the box. Therefore I recommend to install voices for these languages at least.

#### Installation of Speech Recognition Libraries

The installation of the voice recognition engine sometimes needs a little bit more effort. Simulator Controller relies on the speech recognition runtime from Microsoft, which is not necessarily part of a Windows standard distribution. You can check this in your settings dialog as well. If you do not have any voice recognition capabilities available, you can use the installer provided for your convenience in the *Utilities\3rd party* folder, as long you have a 64-bit Windows installation. Please install the runtime first and the two provided language packs for English and German afterwards. Alternatively you can download the necessary installation files from [this site at Microsoft](https://www.microsoft.com/en-us/download/details.aspx?id=16789). The same applies here as above, "Simulator Setup" will guide you through this steps.

Note: Since the time for offline voice recognition is almost over, a future version of Jona will use Google, Amazon or Azure services for voice recognition. But this might be a pay per use kind of service. Voice generation using Azure services already has been implemented (see below) and comes with 500.000 free characters per month.

After you have sucessfully installaed all the necessary support packages, we can come back to the configuration of the voice capabilities.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207.JPG)

You can define the spoken language you want to use for voice generation with the first dropdown menu. With the next drop down menu, you can choose the speech synthesis engine, which you want to use for voice generation. If you choose "Windows" here, you will use the synthesis engine on your local computer. If you choose "Azure Cognitive Services", two additional fields will appear, where you have to enter your Azure subscription key and the endpoint for your region.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Azure%20Service.JPG)

You must been registered for the Azure Cloud Services (see https://azure.microsoft.com/ for more details), and you must have configured a resource for the "Microsoft Cognitive Services Speech" API. Both is really easy and free of charge. After you have configured the resource, you will get access to the subscription key and the token issuer endpoint information. Depending on your Windows installation, you might have to install the latest .NET Runtime as well (version 4.6.1 is sufficient).

Please note, that although you must supply a credit card when registering, according to Microsoft, you won't be charged a single cent, unless you give explicit consent for a specific resource. Regarding the Speech API resource, up to 500.000 characters of Text-to-Speech conversion are free per month in the regions "US, East", "Asia, South-East" and "Europe, West". I am quite sure, that you will never reach this limit, unless you are doing 24 h races seven times a week for the whole month, so give it a try...

After choosing the speech synthesis method, you can choose the concrete voice to be used for voice synthesis and also the voice recognizer language with the respectivly labeled dropdown menus. Be careful, a mismatch between chosen language and the selected voice generator will give you very funny results. Generally, I recommend to use the "Automatic" setting for both and let Simulator Controller decide which is the best voice and the best recognizer for your current selected language. If more than one voice is available for voice generation, each time one is selected randomly, thereby providing some variety. For voice output you can set the volume, the pitch and the speed (rate) using the three corresponding sliders. Last but not least, if you have installed [SoX](http://sox.sourceforge.net/), it will be used to apply audio post processing to the spoken voice to achieve a sound like a typical team radio. Really immersive stuff, you won't miss that.

Note: Additionally to this default configuration, you can specify the spoken and recognized language and the voice for each race assistant individually using plugin parameters (see the configuration documentation of [Jona](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) and [Cato](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) for more details). Choosing different voices will be helpful to better recognize who is currently talking.

With the last option, you can configure a *Push To Talk* function for voice recognition, which will greatly enhance the voice recognition quality and will avoid almost all false positives, if you are not in a very quite environment. The argument to be entered in the field is a key code as defined in the AutoHotkey [key list](https://www.autohotkey.com/docs/KeyList.htm). For example, "LControl" defines the left control key on the keyboard, whereas "4Joy2" defines the second button on your 4th connected hardware controller.
Using *Activation Command* you can supply a keyword or a complete phrase to focus the voice recognition framework to the commands you defined as voice commands for [controller actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller). The recognition language for this activation command will always be the one chosen by the language dropdown menu above. For more information on how to use multiple voice *communication partners*, see the [corresponding documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands).

Before you can use the voice capabilities of Simulator Controller, you must configure Windows for voice generation and recognition. Voice generation is normally preinstalled and preconfigured, but you can add additional voices using the Windows Settings dialog. The speech recognition runtime from Microsoft is not necessarily part of a Windows standard distribution. You can check this in your Settings dialog as well. If you do not have any voice recognition capabilities available, you can use the installer provided for your convenience in the *Utilities\3rd party* folder, as long you have a 64-bit Windows installation. Please install the runtime first and the two provided language packs for English and German afterwards. Alternatively you can download the necessary installation files from [this site at Microsoft](https://www.microsoft.com/en-us/download/details.aspx?id=16789).

Note: You can use the [Trigger Detector Tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#trigger-detector-tool) to find out, which button codes your connected controller actually use, by clicking the small button on the right side of the *Push To Talk* entry field. If you push a simple button on your external controller, the corresponding hotkey name will be inserted into the *Push To Talk* edit field.

### Tab *Plugins*

In this tab you can configure the plugins currently in use by the Simulator Controller.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%202.JPG)

Beside temporarily deactivating a plugin and all its modes, you can define a comma separated list of simulator names. This will restrict the modes of the plugin to only be available, when these simulators are running. The most important field here is the *Arguments* field. Here you can supply values for all the configuration parameters of the given plugin. The format is like this: "parameter1: value11, value12, value13; parameter2: value21, value22; ...". Please take a look at the [plugin reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for an in depth explanation of all the parameters of the bundled plugins. Last but not least, you will find an "Edit Labels..." button in the lower left corner of this tab. Pressing this button will open a simple text file, where you can edit the labels, some plugins display on the visual hardware controller display. Change them to your liking. Please note, that the content of this file must be localized depending on the currently configured language of Simulator Controller.

Note: You can deactivate or delete all plugins except *System*. The *System* plugin is required and part of the framework. If you delete one or more of the other plugins here, they will still be loaded by the Simulator Controller, but they won't be activated. On the other hand, if you add a plugin here, but haven't added any plugin code, nothting will happen. And, last but not least, the plugin names given here must be identical to those used in the plugin code. Some sort of primary key, hey. If you have some development skills, see the documentation on [plugin development](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts) for further information.

### Tab *Applications*

Simulator Controller can handle as many applications as you want. Beside the simulation games itself, you may want to launch your favorite telemetry or voice chat application with a push of a button. Or you want a voice recognition software to be started together with the Simulator Controller to be able to handle all activaties not only by the Button Box, but by voice commands as well. The possibilities are endless. To be able to do that, Simulator Controller needs knowledge about these applications, where to find them and how to handle them. This is the purpose of the *Applications* tab.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%203.JPG)

There are three diffenrent types of applications, "Core", "Feedback" and "Other". All of these applications are optional, but for the "Core" and "Feedback" category, Simulator Controller is aware of them, either directly or with the help of a plugin, and use them for a better user experience. Since adding "Core" and "Feedback" applications also need some development efforts, the categories cannot be changed by using the configuration tool, which means, that any application added here will be automatically of type "Other". But "Other" applications may be used by the [Launchpad](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-launchpad).

Note: To change the category of an application, you need to directly edit the *Simulator Configuration.ini* file.

An application must a have a unique name, you must supply the path to the executable file and sometimes also to a special working directory, and you may supply a [window title pattern](https://www.autohotkey.com/docs/misc/WinTitle.htm) according to the AutoHotkey specification. This is used to detect, whether the application is running.

Second note: Although you cannot delete any application in the "Core" or "Feedback" category, you still can disable them in the [settings for the startup process](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--settings).

For developers: Sometimes you want magic stuff to happen, when an application is started. For example, you may automatically swith to your favorite team channel when starting your voice chat software. This need some code support, which can be provided in a plugin. You *simply* define a function, which handles this special stuff and reference it here in the application configuration. See the plugins [Core Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/Core%20Plugin.ahk), [RST Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/RST%20Plugin.ahk) and [AC Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/AC%20Plugin.ahk) for some examples.

### Tab *Controller*

This tab represents the most important, the most versatile and also the most difficult to understand part of the configuration process. On this page, you describe your hardware controllers, for example one or more Button Boxes, and all the functionality available on this controller.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%204.JPG)

Note: Beginning with Release 2.4, Simulator Controller supports multiple Button Boxes. The functions defined on the *Controller tab* will span all Button Boxes. So, the first Button Box might define Button #1 to Button #8 and the second Button Box will define Button #9 onwards. A sngle mode can use controls from several Button Boxes, but you can also have multiple modes active at the same time, as long as these modes uses controls from distinct Button Boxes. See the documentation on the "System" plugin for more information on [how to control multiple simultaneous modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-system).

In the first step you have to define the Button Boxes, which will be activated by Simulator Controller, by entering them into the list. Each Button Box must have a name, whihc might be displayed on the visual representation and you must chose a layout definition from the dropdown next to the name entry field. Button Box layouts can be configured using a separate tool, which is described in a [dedicated documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts) below. This tool can be opened by pressing the small little button with the three dots next to the dropdown menu.

Note: The order, in which the Button Boxes are entered in the given list, establish the order they initially appear on screen, but you can move them around using the mouse later on.

After you have created all your Button Boxes, you must configure the controller functions, which will be associated with the controls on your hardware controller or which might be triggered by other software systems using hotkeys. For each function and its corrsponding binding, you have to create an entry in the *Functions* list.
In the *Bindings* group, you define one or two hotkeys and optionally corresponding actions, depending on whether you have defined a unary or binary function type. 2-way toggles and dials need two bindings for the "On" and "Off", respectivly the "Increase" and "Decrease" trigger. The binding of a function happens by defining [hotkeys](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys), which might trigger the given function. You can define more than one hotkey descriptor, delimited by the vertical bar "|", for each trigger in the controller tab. This might be useful, if you have several sources, which can trigger a given function. For example you might have a function, which can be triggered by pushing a button on the controller, but also from the keyboard, which might be emulated by another tool, for example a voice recognition software.

Additionally to definining hotkeys for keyboard or controller triggers, you can now use the voice recognition capabilities of Simulator Controller, which were introduced with Release 2.1 for the Virtual Race Engineer (see [update notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-21) for specific installation information). A voice trigger must be preceeded by "?" and you can use the full [phrase grammar](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#phrase-grammars) capabilities of the voice recognition framework. But in most cases, you will use simple phrases like "?Next Page", which might be used as a voice trigger for the mode switch. Please be aware, that the recognition language uses the language setting, that is chosen in the configuration. As a result, you might have to change your phrases, if you decide to switch to a different language setting in the user interface.

Note: As already documented in the [troubleshooting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#troubleshooting) section of the documentation for the Virtual Race Engineer, you will get the best results with a headset. If you want to stick with a surround loudspeaker setup, consider using [VoiceMacro](http://www.voicemacro.net/) for recognizing voice commands, since this little tool is specialized and much better when it comes to separating unwanted ambient noises from your voice commands than the voice recognition of Simulator Controller - at least for the moment.

Beside the hotkey(s), a function may define an [action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions), which must be a call to a global function in the scripting language. For all functions managed by plugins, you can leave the action field empty, since in the Simulator Controller framework, actions are represented by instances of [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk).

Last, but not least, and only for the experienced user: Functions can be overloaded. If you bind an action to a function, for example with a [plugin argument](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes), you can reference a given function multiple times. All bound and enabled actions will be triggered by the function at the same time. This might be useful, if you want to control several aspects of your simulation equipment with the same hardware control, for example: You define a master toggle switch, to enable or disable rig motion and vibration at the same time.

#### Hotkeys

The central concept to connect to your hardware controller or to other external trigger is a *Hotkey*. A hotkey is a concept of the Windows operating system, whereby a combination of several keys on the keyboard, mouse or other controlling device might trigger a predefined action. The AutoHotkey language defines a special syntax to define hotkeys. You will find a comprehensive guide to this syntax and all available keys in the [documentation](https://www.autohotkey.com/docs/Hotkeys.htm) of AutoHotkey. For example the string <^<!F1 defines a hotkey for function key one (F1), which must be pressed together with the left (<) Control (^) and left (<) Alt (!) key to be triggered. Beside hotkeys for the keyboard or mouse events, AutoHotkey provide a definition for hotkeys for external controllers, called joysticks. For example, 2Joy7 defines the seventh button on the second controller connected to the PC.

Below you will find a brief and incomplete overview over the possible hotkeys, to help you to understand the hotkeys found in the sample configuration file. Please take a look at the complete [documentation](https://www.autohotkey.com/docs/Hotkeys.htm) of AutoHotkey for further information.

| Symbol | Description |
| ------ | ------ |
| ^ | Represents the CTRL key. |
| ! | Represents the ALT key. |
| + | Represents the SHIFT key. |
| < | A modifier for all keys that restrict it to be on the left side of the keyboard. |
| > | A modifier for all keys that restrict it to be on the right side of the keyboard. |
| A - Z | A normal alphabetical key on the keyboard. |
| F1 - Fn | A function key on the keyboard, if avilable. |
| Numpad0 - Numpad9 | A numpad key on the keyboard, if avilable. These will only be send, if NumLock is activated on the keyboard. |
| LMouse, RMouse | The left and the right mouse button. |
| {X}Joy{Y}| The y-th button on the x-th connected joystick or general hardware controller. Example: "2Joy7". You can use the [Trigger Detector Tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#trigger-detector-tool) to find out, which button codes your connected controller actually use. |

#### Actions

An action is simply a textual representation of a call to a function in the scripting language. It simply looks like this: "setMode(Pedal Vibration)", which means, that the "Pedal Vibration" mode should be selected as the active layer for your hardware controller. You can provide zero or more arguments to the function call. All arguments will be passed as strings to the function with the exception of *true* and *false*, which will be passed as literal values (1 and 0).

Although you may call any globally defined function, you should use only the following functions for your actions, since they are specially prepared to be called from an external source:

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| setDebug | debug | Builtin | Enables or disables debugging. *debug* must be either *true* or *false*. |
| setLogLevel | logLevel | Builtin | Sets the log level. *logLevel* must be one of "Info", "Warn", "Critical" or "Off", where "Info" is the most verbose one. |
| increaseLogLevel | - | Builtin | Increases the log level, i.e. makes the log information more verbose. |
| decreaseLogLevel | - | Builtin | Decreases the log level, i.e. makes the log information less verbose. |
| pushButton | number | Builtin | Virtually pushes the button with the given number. |
| rotateDial | number, direction | Builtin | Virtually rotates the rotary dial with the given number. *direction* must be one of "Increase" or "Decrease". |
| switchToggle | type, number, state | Builtin | Virtually switches the toggle switch with the given number. *state* must be one of "On" or "Off" for 2-way toggle switches and "On" for 1-way toggle switches. The type of the toggle switch must be passed as *type*, one of "1WayToggle" and "2WayToggle". |
| setMode | plugin, mode | Builtin | Switches the currently active mode for the hardware controller. See the [plugin reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for an in depth explanation of all available modes. Instead of supplying the name of a plugin and mode, you can omit the second argument and supply "Increase" or "Deacrease" for the first parameter. In this case the controller will activate the next mode like in a carousel. |
| execute | command | System | Execute any command, which can be an executable or a script with an extension accepted by the system. The *command* string can name additional arguments for parameters accepted by the command, and you can use global variables enclosed in percent signs, like %ComSpec%. Example: execute(D:\Programme\Nircmd.exe changeappvolume ACC.exe -0.1) - reduces the sound volume of *Assetto Corsa Compeitizione* by 10 percent.|
| startSimulation | [Optional] simulator | System | Starts a simulation game. If the simulator name is not provided, the first one in the list of configured simulators on the *General* tab is used. |
| stopSimulation | - | System | Stops the currently running simulation game. |
| shutdownSystem | - | System | Displays a dialog and asks, whether the PC should be shutdown. Use with caution. |
| enablePedalVibration | - | Tactile Feedback | Enables the pedal vibration motors, that might be mounted to your pedals. Available depending on the concrete configuration. |
| disablePedalVibration | - | Tactile Feedback | Disables the pedal vibration motors, that might be mounted to your pedals. Available depending on the concrete configuration. |
| enableFrontChassisVibration | - | Tactile Feedback | Enables the chassis vibration bass shakers that might be mounted to the front of your simulation rig. Available depending on the concrete configuration. |
| disableFrontChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the front of your simulation rig. Available depending on the concrete configuration. |
| enableRearChassisVibration | - | Tactile Feedback | Enables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| disableRearChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| disableRearChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| startMotion | - | Motion Feedback | Starts the motion feedback system of your simulation rig. Available depending on the concrete configuration. |
| stopMotion | - | Motion Feedback | Stops the motion feedback system of your simulation rig and brings the rig back to its resting position. Available depending on the concrete configuration. |
| openPitstopMFD | [Optional] descriptor | ACC, RF2, R3E, IRC | Opens the pitstop settings dialog of the simulation that supports this. If the given simulation supports more than one pitstop settings dialog, the optional parameter *decriptor* can be used to denote the specific dialog. For IRC this is either "Fuel" or "Tyres", with "Fuel" as the default. |
| closePitstopMFD | - | ACC, RF2, R3E, IRC | Closes the currently open pitstop settings dialog of the simulation that supports this. |
| changePitstopOption | option, selection, [Optional] increments | ACC, RF2, R3E, IRC | Enables or disables one of activities carried out by your pitstop crew. The supported options depend on the current simlation game. For example, for ACC the available options are "Change Tyres", "Change Brakes", "Repair Bodywork" and "Repair Suspension", for R3E "Change Tyres", "Repair Bodywork" and "Repair Suspension", for RF2 "Repair", and for IRC "Change Tyres" and "Repair". *selection* must be either "Next" / "Increase" or "Previous" / "Decrease". For stepped options, you can supply the number of increment steps by supplying a value for *increments*. For other, more common pitstop activites like refueling, use on of the next actions. |
| changePitstopStrategy | selection | ACC, R3E | Selects one of the pitstop strategies (this means predefined pitstop settings). *selection* must be either "Next" or "Previous". |
| changePitstopFuelAmount | direction, [Optional] litres | ACC, RF2, R3E, IRC | Changes the amount of fuel to add during the next pitstop. *direction* must be either "Increase" or "Decrease" and *liters* may define the amount of fuel to be changed in one step. This parameter has a default of 5. |
| changePitstopTyreSet | selection | ACC | Selects the tyre sez to change to during  the next pitstop. *selection* must be either "Next" or "Previous". |
| changePitstopTyreCompound | selection | ACC, RF2 | Selects the tyre compound to change to during  the next pitstop. *selection* must be either "Increase" or "Decrease" to cycle through the list of available options. |
| changePitstopTyrePressure | tyre, direction, [Optional] increments | ACC, RF2, IRC | Changes the tyre pressure during the next pitstop. *tyre* must be one of "All Around", "Front Left", "Front Right", "Rear Left" and "Rear Right", and *direction* must be either "Increase" or "Decrease". *increments* with a default of 1 define the change in 0.1 psi increments. |
| changePitstopBrakeType | brake, selection | ACC | Selects the brake pad compound to change to during the next pitstop. *brake* must be "Front Brake" or "Rear Brake" and *selection* must be "Next" or "Previous".  |
| changePitstopDriver | selection | ACC, RF2 | Selects the driver to take the car during the next pitstop. *selection* must be either "Next" or "Previous". |
| planPitstop | - | Race Engineer | *planPitstop* triggers Jona, the Virtual Race Engineer, to plan a pitstop. |
| preparePitstop | - | Race Engineer | *preparePitstop* triggers Jona, the Virtual Race Engineer, to prepare a previously planned pitstop. |
| openRaceSettings | import | Race Engineer, Race Strategist | Opens the settings tool, with which you can edit all the race specific settings, Jona needs for a given race. If you supply *true* for the optional *import* parameter, the setup data is imported directly from a running simulation and the dialog is not opened. |
| openSetupDatabase | - | Race Engineer, Race Strategist | Opens the query tool for the setup database, with which you can get the tyre pressures for a given session depending on the current environmental conditions. If a simulation is currently running, most of the query arguments will already be prefilled. |
| openStrategyWorkbench | - | Race Strategist | Opens the "Strategy Workbench" tool, with which you can explore the telemetrie data for past session, as long as they have been saved by the Race Strategist, and with which you can create a strategy for an upcoming race. If a simulation is currently running, several selections (car, track, and so on) will already be prefilled. |

#### Trigger Detector Tool

This little tool will help you identifying the button numbers of your hardware controller. If you push the "Trigger..." button, a flying tool tip will apear next to your mouse cursor, which provide some information about your connected controller devices and the buttons or other triggers, that are currently beeing pushed there. To disable the tool tip, press the "Trigger..." button again or use the "ESC" key.

### Tab *Launchpad*

On the launchpad, you can define a list of type "Other" applications, that can be launched by a push of a button on your controller. The "Launch" mode, which belongs to the "System" plugin, will use this list to occupy as many buttons on your controller, as has been defined on the *Controller* tab.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%205.JPG)

In the first field, you define the push button function for the given application on one of your hardware controllers. You also need to specify a small label text to display on the visual representation of your controller and you need to choose the application, which will be launched, when the corresponding button is pressed.

### Tab *Chat*

Many simulation games provide an ingame multiplayer text based chat system. Since it is very difficult and also dangerous to a certain extent to type while driving or flying, you can configure predefined chat messages on this tab. These may be used by several plugins for specific simulators, to help you to send a kudos to your oppenents or even insult or offend them. Chat messages will typically be used in a mode of a specific plugin for a simulation game. See the [ACC Plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) for an example.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%206.JPG)

In the first field, you define the push button function for the given chat message on one of your hardware controllers. You also need to specify a small label text to display on the visual representation of your controller and you specifiy the long chat message, which will be send to the ingame chat system, when the corresponding button is pressed.

### Tab *Race Engineer*

With the settings on this tab, the dynamic behaviour of the [Virtual Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer) and its integration with the [setup database](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race--setup-database) can be customized. All options can be chosen independently for each configured simulation game.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%208.JPG)

Choose the simulator with the topmost dropdown menu, before you change one of the settings beneath. In the first two groups, you can choose how the [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#race-settings) for a new session and how the cold tyre pressures reference values will be initialized, and wether the settings and the updated cold tyre pressures will be saved by the end of the session. If you choose to save the settings, selected information from your session (for the moment the best lap time, the average fuel consumption, and the tyre compound currently in use, more information will follow in the next releases) will be used to update the session settings maintained by the *Race Settings* tool, either at the default location in the *Simulator Controller\Config* folder in you user *Documents* folder or in the corresponding settings information in the setup database (depending on the origin of the settings as configured in the first group). If the settings had been loaded from the setup database at the start of the session, this settings file wil be updated, otherwise a new settings file named "New - YYYYMMDDHH24MISS" will be created in the setup database. The second part of the name of the new file represents a time stamp consisting of the current year, month, day, hour, minute and seconds.

The third group allows you to customize some parts of the statistical algorithms of Jona, the Virtual Race Engineer. The first field defines the number of laps, Jona uses to populate its data collection. During this period, most of the functions of Jona are not available, but the predictions of dynamic values, like cold tyre pressures, will be much more precise afterwards. The second field, *Statistical Window*, is also quite important. It defines the number of recent laps, which are used for each and every statistical calculation, for example the standard deviation of tyre pressures. The next field, *Damping Factor*, can be used to influence the calculation weight for each of those laps. If you want all laps to be considered with equal weight, set this to *0*, whereas a value o *0.2* will weigh each lap with *20%* less than the lap before. *Adjust Lap Time* will inform Jona to use the lap time from the *Race Settings* for special laps like the first one or the lap after a pitstop and the last field *Damage Analysis* defines the number of laps, Jona oberves your lap times after you collected some damage.

### Tab *Race Strategist*

Similar as with the tab for the *Race Engineer*, the dynamic behaviour of the [Virtual Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist) can be customized here. All options can be chosen independently for each configured simulation game.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%209.JPG)

In the first field, you can select a folder, where the *Race Strategist* will save the race data for after race analysis using the ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports) tool. Whether a report for a specific race will be saved, can be selected with "Save Race Report" setting further down below, which is specific for a given simulator. Choose this simulator with the "Simulator" dropdown menu, before you change one of the settings beneath. Then you can customize some parts of the statistical algorithms of Cato, the Virtual Race Strategist. The first field defines the number of laps, Cato uses to populate its data collection. During this period, most of the functions of Cato are not available, but the predictions of dynamic values will be much more precise afterwards. The second field, *Statistical Window*, is also quite important. It defines the number of recent laps, which are used for each and every statistical calculation, for example the standard deviation of tyre pressures. The next field, *Damping Factor*, can be used to influence the calculation weight for each of those laps.
With the "Save Telemetry" setting you specify, whether the telemetry data of the last session will be saved for further analysis in the "Strategy Workbench" tool. Although possible, I do not recommend to use “Ask” here, since it might interfere with a similar question by the Race Engineer to save your tyre pressures.

Note: The settings for loading and saving the *Race Settings* specified on *Race Engineer* tab apply for the Virtual Race Strategist as well.

## Themes Editor

This special editor, which can be opened from the *General* tab of the configuration tool, allows you to define a combination of pictures or animation files together with a sound file. This combination is called a splash theme and will be used by the startup sequence. You may have a Rallye theme for your favorite Rallye session, or an F1 theme, or even some cinematic impressions from various airplanes in the sky, while waiting for your flight simulator to startup.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Themes%20Editor.JPG)

Currently, two different types of splash themes are supported. The first uses a collection of pictures for a kind of round robin display. The second theme type let you choose a GIF file for a video like animation. Both support the additional selection of a sound file to play along, while the pictures or the animation will be shown. Despite that, you can overwrite the default title and subtitle of the splash screen window.
Some words about using the editor:
  - You can prelisten the currently selected sound file by pressing the start button next to the entry field. It will keep playing until you press this button again, even if another theme had been selected in the meantime.
  - You can add any picture to the pictures list by pressing the "+" button left to it. The new picture will be added at the end of the list. However, if you save your changes, only those pictures will be stored for the theme, that have a checked checkmark in their list entry.
  - Every JPG and GIF file added to a theme must be of a precise 16:9 format, otherwise you will get distortion artefacts.
  - Due to a restriction in AutoHotkey, only the GIF format is currently supported for animations. A future version of Simulator Controller will support YT videos, MP4 files and other as well. For now you can convert your favorite MP4 file to a GIF image by using one of the available online converters, for example [Convertio](https://convertio.co/de/mp4-gif/) .

After definition of a theme, you can choose it for the [startup sequence](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#other-settings) or even while the build tool is currently compiling your favorite plugin, if you are a developer.

## Translations Editor
Another special editor is used for maintaining different language translations. In the translation process, you can provide a language specific translated text for each user interface element or other texts used by the Simulator Controller. English is the original language, on which the translation is based upon. A translation must be identified by its [ISO language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes), for example "EN", and also has a user understandable language identfier, for example "English". The translation information is stored by the *Translations Editor* in the *Simulator Controller\Translations* folder in your user *Documents* folder in a file named "Translations.LC", where LC is the given ISO language code.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Translations%20Editor.JPG)

With the dropdown menu at the top of the window you can choose any of the available languages and edit the defined translations, or you create a new language by pressing the '+' button next to the language drop down. You can delete a given language and all its translations, but be aware, that this cannot be undone. For your convenience, the small down array on the left side of the translation field will select the next text waiting for translation.

Note: The original text sometimes has leading and/or trailing spaces. Be sure to include them in the translated text as well, since they are important for formatting.

Important: The ISO language code and the language name itself cannot be changed, once a new language has been initially saved. So choose them wisely. And last but not least be careful, if you ever want to edit the translation files directly using a text editor. This editor must be able to handle multibyte files, since the tranlation files are stored in an UTF-16 format.

# Button Box Layouts

Beginning with Release 2.5 it is possible to define Button Box layouts using a structured configuration file. Below you find a sample definition for information, but no worries, a graphical editor is available to handle this file.

	[Controls]
	Switch=2WayToggle;%kButtonBoxImagesDirectory%Photorealistic\Toggle Switch.png;54 x 85
	Push=Button;%kButtonBoxImagesDirectory%Photorealistic\Push Button 3.png;40 x 40
	Rotary=Dial;%kButtonBoxImagesDirectory%Photorealistic\Rotary Dial 3.png;42 x 42
	[Labels]
	Label=56 x 30
	[Layouts]
	Controller 1.Layout=3 x 5
	Controller 1.Visible=true
	Controller 1.1=Switch.1,Label;Switch.2,Label;Switch.3,Label;Switch.4,Label;Switch.5,Label
	Controller 1.2=Push.1,Label;Push.2,Label;Push.3,Label;Push.4,Label;Rotary.1,Label
	Controller 1.3=Push.5,Label;Push.6,Label;Push.7,Label;Push.8,Label;Rotary.2,Label
	Controller 2.Layout=3 x 4, 20, 60, 20, 15
	Controller 2.Visible=true
	Controller 2.1=Push.9,Label;Push.10,Label;Push.11,Label;Push.12,Label
	Controller 2.2=Push.13,Label;Push.14,Label;Push.15,Label;Push.16,Label
	Controller 2.3=Push.17,Label;Push.18,Label;Push.19,Label;Push.20,Label

You can define as many Button Box layouts as you want, but only those Boxes will be activated by Simulator Controller, that also have been added to the list of active Button Boxes list at the top of the [*Controller* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller).

In the given configuration file, you first have to define the different *Control* types, you want to use on your Button Box layouts. In the example above, three different *Control* types are defined, each one consisting of the name of the corresponding class, the image for the visual representation and the size information for this image. Supported classes are "1WayToggle", "2WayToggle", "Button" and "Dial", which corresponds with the controller functions used on the [*Controller* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller). The given name of the *Control* type definition will then be used in the configuration of the concrete layouts in the *[Layouts]* section.

You may define different *Label* types, if you are using label fields of different sizes for your controls. The example above only introduces one label with a fixed size for all controls.

In the last section, the layouts of one or more Button Boxes are described using these components. For each Button Box you have to define the layout grid with *.Layout*" descriptor. The grid argument ("R x C", where "R" define the number of rows and "C" the number of columns) is required, the other optional parts as in "Controller 2.Layout=3 x 4, 20, 60, 20, 15" are the *Row Margin*, *Column Margin*, *Sides Margin* and *Bottom Margin* with 20, 40, 20 and 15 as default. After defining the layout, you enumerate the controls of each row seperately. It is possible to leave positions in the grid blank, when not every corresponding position on your Button Box is occupied with a control, and it is also possible to create a control without a label field. The number of each control (as in "Push.17" must correspond with the number of the corresponding controller function defined on the [*Controller* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller). Last, but not least: You can declare a Button Box to be invisible, so that its graphical representation will not be shown on the screen.

After we now have an understanding of the Button Box layout definition format, let's have a look at the graphical editor, which handles this configuration file. As always, the file will be stored in the *Simulator Controller\Config* folder which resides in your user *Documents* folder.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%20Editor%201.JPG)

As you can see, the structure of this editor is very similar to the structure of the configuration file above. You first have to enter your controls and labels in the first two sections of the editor and then you can define the Button Box layouts. If you select an existing layout definition or when you save a newly created definition, a preview window of this Button Box layout will be opened in the lower right corner of your screen.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%20Editor%202.JPG)

This window will visualize the current layout and will change, whenever you change one of the definitions in the layout editor. Please note, that you have to save the definition changes using the *Save* buttons to update the preview window, as long as you do not have chosen the [*Automatic* save mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#using-the-configuration-tool). As you can see in the image above, freshly added rows and columns will show a free "Space", which you can fill up with *Controls*. Please note, that the "Space" marker will only be shown in the preview mode, so intentionally free space will look good on the final Button Box. You con click on each cell of the preview window and change the *Control* and the *Label*, which should occupy this cell, and you can choose the corresponding controller function number for the given control.

# Stream Deck Layouts

Release 3.6.6 introduces support for Stream Deck controller, very similar to the support for Button Boxes. The layout of a given Stream Deck profile is described to Simulator Controller using a structured configuration file. Below you find a sample definition as a guide.

	[Layouts]
	Stream Deck.Layout=3 x 5
	Stream Deck.1=Button.1;Button.2;Button.3;Button.4;Button.5
	Stream Deck.2=Button.6;Button.7;Button.8;Button.9;Button.10
	Stream Deck.3=;;;;
	Stream Deck Mini.Layout=2 x 3
	Stream Deck Mini.1=Button.11;;
	Stream Deck Mini.2=;;
	[Buttons]
	Stream Deck.Button.1.Label=true
	Stream Deck.Button.2.Label=true
	Stream Deck.Button.3.Label=true
	...
	Stream Deck Mini.Button.11.Icon=D:\Controller\Resources\Icons\Gear,ico
	Stream Deck Mini.Button.11.Label=false

To connect your Stream Deck(s) with Simulator Controller, you must install the special Stream Deck plugin, which is supplied in the *Utilities* folder. Copy the comple folder *de.thebigo.simulatorcontroller.sdplugin* to *%appdata%\Elgato\StreamDeck\Plugins*. Then create a profile using the special action *Controller Function* supplied by this Stream Deck plugin. It is important that you leave the title of the action blank and set the *Function* to the desired controller function, for example "Buttton.1".

Then you have to create "Stream Deck Configuration.ini" file similar to the example above and save it to the *Simulator Controller\Config* folder in your user *Documents* folder. For each button in the profile you can define the default icon to be shown on the Stream Deck and whether textual labels should be shown on the Stream Deck buttons as well. The value for the optional *[layout].Button.X.Label* property may be *false* (no label), *true* (default; use the action label from the [labels defined in the general configuration](*)) or you can supply a fixed text here (you can use "\n" to start a new line in the text value). To supply an icon using the optional *[layout].Button.X.Icon*, use a full path to an image file supported by Stream Deck. Here you can also use *false* to specify that you never want to change the icon on the Stream Deck, or *true* (which is the default), if the [icon from general configuration](*) should by used for the associated controller action, if one is available.

Example: In the above example, all "Stream Deck" Actions will use the icons for the currently associated controller action as defined in the "Controller Action Icons.XX" file. Please note, that you can omit the declaration "...Label=true", since this is the default. Only the first two rows of the Stream Deck are used here for controller actions, whereas in the "Stream Deck Mini" only the first button in the top row is configured.

To activate your Stream Deck configuration, you then must open "Simulator Configuration" and create a new entry in the upper list of the "Controller" tab and associate this new controller with one of the Stream Deck layouts. Done...

More to come in the next releases, incl. a graphical editor for all action icons and support in the "Simulator Setup"...