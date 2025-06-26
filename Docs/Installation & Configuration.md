## Quick Start

Before we go into the full details of the complete installation and configuration process, which can be really overwhelming, especially for users new to Simulator Controller, take a short break and follow the instructions in this [quick start video](https://youtu.be/qLMYz1FkEGs). Alternatively, you can read the [quick start guide](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Quick-Start-Guide). Both guides help you to create a simple initial configuration after you have installed the software for the first time. After you have succesfully created and used this initial configuration, you can always come back here and read the remainder of this documentation, which gives you tons of information aboud all the configuration options of Simulator Controller.

## Installation

Installation is easy and fully automatic. Simply download and run the installer from the [GitHub project page](https://github.com/SeriousOldMan/Simulator-Controller#download-and-installation) (or simply click [here](https://simulatorcontroller.s3.eu-central-1.amazonaws.com/Simulator+Controller.exe)) and follow the instructions. You will have the option to install the Simulator Controller package in any location on your hard disks and you can decide to fully register Simulator Controller in Windows or to use a portable installation without updating the Registry. You may also create Start Menu and Desktop shortcuts according to your preferences. I strongly recommend to leave automatic updates ticked, unless you have a very unusual installation location.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Installation.JPG)

It is also recommended to run the configuration process directly after installing the software. But you won't do any harm if you postpone this task and read the rest of the documentation first. Simply start ["Simulator Setup"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-setup-tool) whenever you are ready.

The automatic Installer will always download and install the latest version of Simulator Controller (unless you hold the Control key down, then sometimes a special preview version is available according to seperate announcement). If you want to use a version other than the latest one, this is still possible, but you will have to download it manually. Unzip the package at any location you like, then go to the *Binaries* folder, and start the application "Simulator Tools". It will detect that a version of Simulator Controller is alraedy installed on your Computer and will update it accordingly. If you decide to install an earlier version than your current one this way, you might also have to use a backup copy of an earlier version of the *Simulator Controller* folder fron your user *Documents* folder, since there may be incompatibilities in some cases. Additionally, when running a manual installation, it might be necessary to unblock the applications and DLLs afterwars, since Windows may block them against execution. You can do this on the second page of the "Simulator Setup" application as [described further down below](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#unblocking-of-applications--dlls).

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

You are allowed to change the *[Updates]Automatic* option with a text editor, if you change your mind regarding automatic updates. You can also set *[Updates]Verbose* to *true*, if you want the above dialog window appear even during a normal update. Do **not** change any of the other options, please.

After you have installed Simulator Controller for the first time, the system will automatically detect any available newer versions. You will be asked once a day, whenever a new version is available, whether you want to download and install the new version. If you decide to install the newest version, downlaod and installation will be handled automatically for you. It is also posssible here to do the downlaod manually as described above. Unzip the download package and start the "Simulator Tools" application. It will update your installation and will delete the installation files afterwards.

After you have succesfully installed Simulator Controller for the first time, you will have to build a configuration for your simulation setup. There are two applications available to do this:

  - The first, ["Simulator Setup"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-setup-tool), which was introduced with Release 3.5, is an intelligent *Setup Wizard*, which guides you through the initial installation & configuration process. Many of the tasks described in the remaining chapters of the current document will be handled automatically by this tool. After you have succesfully completed the process using this tool, you will have a running installation of Simulator Controller completely customized to your environment. Please note, that "Simulator Setup" is automatically started after the initial installation, if you ticked the corresponding check box.
  - After you have finished the initial installation & configuration process and created your first running configuration using *Simulator Setup*, you can additionally use ["Simulator Configuration"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-configuration-tool) for further configuration tasks. This tool requires a much deeper knowledge about the inner workings of Simulator Controller, but will give you access to even more functionality compared to the more simple *Simulator Setup* tool. However, as long as you are happy with the options provided by *Simulator Setup*, I recommend to stick to this tool, since it is much easier to use and more fail-safe.

Before starting the configuration process, I would like to cover a few more details to help you understand the concepts and aspects of configuration. On the other hand, you can skip these for the time being and go straight to the instructions for the [*Setup Wizard*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#running-the-setup-tool):

### A Word about Antivirus Warnings

The programming language used for building Simulator Controller uses some really nasty tricks to control Windows applications, tricks also used by malware. Therefore, depending on your concrete Antivirus program, you may get some warnings regarding the Simulator Controller applications. I can assure you, that there's nothing about it. But you can read about these issues in the forums of [AutoHotkey](https://www.autohotkey.com/) itself. If your Antivirus programm allows exception rules, please define rules for the Simulator Controller installation folder and also for the *Simulator Controller* folder which is located in your user *Documents* folder, otherwise you need to have a beer and search for another Simulator Controller tool. Sorry...

### Storage of the configuration files of Simulator Controller

All our (configuration) files will be saved to the *Simulator Controller* folder in your user *Documents* folder. There are also locations in the program folder of Simulator Controller, where similar configuration files can be found. These files will be used, whenever you have not created your own configuration files, for example for [translations](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#localization-and-translation). But your local folder will always be searched first, whenever a configuration file is looked up.

For your safety and your peace of mind, I recommend that you always make a backup of this folder, when you change your configuration or when you update Simulator Controller to a newer version.

### Unblocking of Applications & DLLs

Depending on your Windows security settings, Windows might not trust the binary files in the *Binaries* folder, because you downloaded them from an untrusted location on the internet. You have to *unblock* these files, in order to use them. Under normal circumstances, this is done automatically by the installer and the update procedure. If you have installed Simulator Controller manually, it might be necessary to do this on your own. Start "Simulator Setup", go to the second page and click on "Unblock Applications and DLLs...".

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Unblock%202.JPG)

If you still face security warnings afterwards or if the software is not running properly, it will be necessary to unblock these files manually. You can do this by checking the checkbox in the standard properties dialog. Do this for all applications and the DLL files in the *Binaries* folder.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Unblock.JPG)

You might still encounter execution errors later on because of Windows security restrictions. This is nothing I can change at the moment, at least not without buying an expensive certificate, that secures the source of the binaries. You will find a little Powershell script in the *Utilities* folder, which you can copy to the *Binaries* folder and execute it there with Administrator privileges. These are the commands, which need be executed:

	takeown.exe /F . /R /D N
	Get-ChildItem -Path '.' -Recurse | Unblock-File

### User Account Control settings

Another Windows security function is the so called User Account Control. It jumps in when files, settings or other low level stuff is about to be changed on your computer by an application. I think all of you know the dimmed desktop, when a new software should be installed.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/User%20Account%20Control.jpg)

It has been reported, that the UAC can interfere in rare cases with the operation of Simulator Controller. Especially the C#-based Stream Deck plugin crashes, when the UAC is set at a too high level. If you experience such problems, try to lower the UAC. If this helps, give the respective application or library of Simulator Controller administration rights and bring the UAC level up again. This usually helps.

It also has been reported, that fully disabling UAC, especially in combination with a Windows user, who has Admin priveliges can cause problems as well. In these cases, please contact me and we will find a solution to install Simulator Controller on your system as well.

### Execution restriction of Powershell scripts

*Powershell* is used in many places to handle low level stuff like ZIP file compression or extraction, or to move big chunks of data around. Depending on your security settings, the execution of *Powershell* might be restricted on your local PC. If you encounter hang ups, for example while running the automated update procedure, you can try to give Powershell more execution priveliges using the [policy management](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.security/set-executionpolicy?view=powershell-7.3). Try the *Unrestricted* policy, and if this works, lower the policy to the lowest possible level, that still works.

### Installing Microsoft Language Runtimes

Several components of Simulator Controller are based on low level language runtimes from Microsoft, namely the *.NET Framwork Runtimes* in the version 4.7.2 and 4.8 and the *Visual C++ Redistributable* for Visual Studio 2022. Normally, these runtimes will be installed on your system, but in some rare conditions they might be not of the required version. You can check whether your system has the required versions installed using the Windows settings dialog in the Apps section. If you need to install a specific version, you can find the installer at various Microsoft Websites:

  [Microsoft Visual C++ Redistributable](https://docs.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170)
  
  [.NET Framework 4.7.2](https://dotnet.microsoft.com/en-us/download/dotnet-framework/net472)
  
  [.NET Framework 4.8](https://dotnet.microsoft.com/en-us/download/dotnet-framework/net48)
  
For your convience, you can find these installers also in the *Utilities\3rd Party\Windows Runtimes* folder. These runtimes will be automatically installed in the *Basic* setup page of "Simulator Setup".

### Installing additional components

As already mentioned in the [README](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/README.md#third-party-applications) file, you might want to install additional third party applications, that will be used and controlled by Simulator Controller or will enhance the overall user experience. "Simulator Setup" will guide you through the installation of all these applications, but you can do it on your own as well. Please take a look at the list of applications and decide, which ones you want to install during the installation & configuration process. If you want to start your own plugin development or even change the code of the Simulator Controller itself, you additionally need to install [AutoHotkey](https://www.autohotkey.com/). Beginning with Release 2.1, an installation of [VisualStudio Community Edition](https://visualstudio.microsoft.com/de/vs/community/) might also be required, if you want do dig into the heavylifting part of telemetry data acquisition or voice recognition. But you can stick with the precompiled binaries from the distribution, if that is not your domain.

### Installation and configuration of the different Race Assistants

Release 2.1 introduced Jona, an AI Race Engineer as an optional component of the Simulator Controller package. Since Jona is quite a complex piece of software, and also requires additional installation steps, you will find all necessary information about Jona in a separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer). The configuration for Cato, an AI Race Strategist (introduced with Release 3.1), and also for Elisa, an AI Race Spotter, is very similar since all these Assistants are based on the same technology. Please see the [separate documentation for Cato](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist) and also [for Elisa](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter) for more information. Lastly, [Aiden, the AI Driving Coach](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach) works a bit differently, since this Assistant requires a connection to a GPT service. "Simulator Setup" will guide you through many of these configuration steps as well, but I strongly recommend reading the documentation chapters for the AI Assistants to have a better understanding of the concepts and relationships of these very powerful and at the same time complex components.

#### Installation of Telemetry Providers

The Assistants acquire telemetry data from the different simulation games using so called telemetry providers, which in most cases read the [required data](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#telemetry-integration) from a shared memory interface. In general these are already included in Simulator Controller and there is nothing to do, but for *Assetto Corsa*, *rFactor 2* and *Le Mans Ultimate*, you need to install a plugin into a special location for the telemetry interface to work and for *Automobilista 2* and *Project CARS 2* a change in the settings is necessary.

  1. *Assetto Corsa*
  
     Please copy the complete *SimlatorController* folder, which is located in the *Utilities\Plugins* folder of the Simulator Controller installation, to the Steam installation folder of *Assetto Corsa* and there into the *apps\python* folder. You will have to enable this plugin in the *Asseto Corsa* settings afterwards. This plugin uses code originally developed by *Sparten* which can be found at [GitHub](https://github.com/Sparten/ACInternalMemoryReader).
  
  2. *rFactor 2* and *Le Mans Ultimate*
  
     You can find the plugin *rFactor2SharedMemoryMapPlugin64.dll* in the *Utilities\Plugins* folder of the Simulator Controller installation folder or you can load the [latest version](https://github.com/TheIronWolfModding/rF2SharedMemoryMapPlugin) from GitHub.
	 
	 *rFactor 2*: Copy the DLL file to the *Bin64\Plugins* folder in the Steam installation directory of *rFactor 2*. You will have to enable this plugin in the *rFactor 2* settings afterwards.
	 
	 *Le Mans Ultimate*: Copy the DLL to the *Plugins* folder in the Steam installation directory of *Le Mans Ultimate*. As the time of this writing, there is no way to enable the plugin in the UI of *le Mans Ultimate*. Therefore start the game once, go to the track and drive out the pit. Exit the game and open the file *UserData\player\CustomPluginVariables.JSON* with a text editor and set " Enabled:" to **1**.

  3. *Automobilista 2* and *Project CARS 2*
  
     You have to enable Shared Memory access in the game settings. Please use the PCars 2 mode.

If you have used the quick setup method of "Simulator Setup", the plugins may already have been installed, but activation is a manual step.

### Using your own pictures, videos and sounds for all the splash screens

The startup process of Simulator Controller can entertain you with nice images and even play videos and emotional songs while starting all the components or your favorite simulation game (no worry, this can be completely switched off using the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration), if you prefer a more reduced kind of life style). The standard distribution comes with some default media from the GT3 world, but, since every racer or even pilot might have a different taste, you can install your own media files. You will find all the standard media files in the *Resources\Splash Media* folder. For your own media, you can use any JPG, GIF, WAV or MP3 files, as long as the pictures and videos adhere to a strict 16:9 format. Last but not least, you can use the settings editor to choose between picture carousel or GIF animation, whether to play one of the sound files during startup, and so on. To keep the standard distribution clean, a *Simulator Controller\Splash Media* folder will be created by the configuration tool in your standard *Documents* folder, where you can store your media files. The "Simulator Configuration" tool allows you to [create a splash screen](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#splash-screen-editor) from all these files, which then can be selected for the various applications as default splash screen.

Note: Choosing media files depending on the currently selected simulation game is on the wish list for a future release :-)

### Using your own sounds for confirmation sounds

Many Simulator Controller applications use confirmation sounds to inform you of certain events. For example, if you have pressed the *Push-To-Talk* button, you will hear a silent notification tone, which informs you, that the system is listening now. These sounds are stored in the folder *Resources\Sounds*, which is located in the program folder. If you want to change a given sound, you can place your own sound using the same name in the folder *Simulator Controller\Sounds*, which is located in your user *Documents* folder.

### Additional requirements for the embedded HTML browser

A couple of the applications of Simulator Controller display various charts and graphs using the Google chart library in an embedded web browser. This web browser, which is part of Windows, must be configured for a given application using a setting in the Windows Registry. In most cases, this setting can be configured automatically by the given application, but in rare cases, admin privileges are required to insert the corresponding key in the registry. If you encounter an error that the Google library can not be loaded, you must run the application in question once using administrator privileges. This currently applies to "Race Reports", "Strategy Workbench", "Team Center", "Solo Center", "Session Database" and "Setup Workbench".

### Special steps for *RaceRoom Racing Experience* and (optionally) for *Assetto Corsa Competizione*

If you want to use the automated handling of the pitstop settings for *RaceRoom Racing Experience* simulations, either manually by using your connected controller or controlled by one of the Race Assistants, you need to create small graphical elements, which Simulator Controller uses to detect and *understand* the currently chossen pitstop settings. You will find detailed instructions for this task in the documentation for the [*Assetto Corsa Competizione* plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling) (actually not longer needed, see below, but still supported) and for the [*RaceRoom Racing Experience* plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling-1).

A couple of presets in "Simulator Setup" are available with sets of pictures for a given screen setup and resolution. Give them a try, before you start creating your own ones.

IMPORTANT: Since release 4.2.1, a second method without image recognition exists and the search pictues for ACC are no longer needed, but since it is the optical much more pleasing solution, you may still want to give it a try. Take a look [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling), how to reactivate the image recognition for *Assetto Corsa Competizione*.

### Securing your data

Before we finally start with setup and configuration task for Simulator Controller in the next section, one word of advice. Please take care of your configuration and your data. Simulator Controller collects a lot of valuable data from your sessions and builds a database for you, for strategy development or support during your pitstops, and so on. Please make sure, that you make periodic backup copies of the *Simulator Controller* directory in your user *Documents* folder and all other locations you reference in the configuration at least once a week and especially before updating to a new version. Despite the typical threats for your data from general PC problems, there might also be a bug in my software, that corrupts data. That was not the case so far, but who knows, nobody is perfect (knock on wood).

## Configuration

The different components of Simulator Controller can be customized to a large extent. Part of this customization is handled by the installation & configuration process, which typically you need to do only once, unless the configuration of your simulation equipment change in the future. As mentioned, there is a special *Setup Wizard* available for the initial installation & configuration, whereas the somewhat more advanced configuration is handled by a specialized tool, which will be described in the following sections. Additional customization, which address the day to day operations and general appearance of  Simulator Controller, is possible by using separate settings dialogs. See the documentation on the [usage](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller) of Simulator Controller for more information.

### Running the Setup tool

The initial configuration after the first installation is handled by the tool *Simulator Setup*.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Setup%201.PNG)

This tool is self-explanatory to a great extent, so you don't have to read the remaining documentation, before you start your initial installation & configuration process. And you can repeat the installation & configuration process with *Simulator Setup* as many times as you want, since the tool will retain your work between sessions. The current state of the installation & configuration process is stored in the folder *Simulator Controller\Setup* in your *Documents* folder, if you want to make a backup of your currently chosen settings and options.

When you start "Simulator Setup" for the first time, you may create a so called basic configuration, which gives you the opportunity to create a simple, but working configuration with just a few choices. This configuration will support the installed simulators and will activate at least one Race Assistant together with voice control. No configuration support is given for your Button Boxes and Stream Decks, but you can add them anytime later.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Quick%20Start%204.JPG)
   
The details of this basic configuration are discussed in the [quick start guide](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Quick-Start-Guide). However, you don't need to stop at the basic configuration. You can go on and go through all the remaining pages of "Simulator Setup" to create a full-blown configuration at the first run.

If you ever have the need to start with an empty, fresh configuration, you can do this either by deleting the *Simulator Controller\Setup* folder or you can hold the Shift and Control key down, while starting *Simulator Setup*. You will be asked, if you want to ignore all the saved settings and options.

Additionally, since the configuration files will only be created in the last step the process, you can experiment with the settings & options until you are satisfied with your choices. Doing this, you will learn a lot about the functionalities of Simulator Controller. If you decide to generate a new configuration in the last step of the installation & configuration step, backup files of all changed configurartion files (named *.bak) will be created automatically, so you can always rescue your current configuration, if something goes wrong.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Setup%202.JPG)

Three files will be created by the *Simulator Setup* tool at the end of the installation & configuration process, all of which are stored in the *Simulator Controller\Config* folder in your *Documents* folder:

  - *Simulator Configuration.ini*
    This is the main configuration file of Simulator Controller. You can customize every aspect of this file using the "Simulator Configuration" application after the initial installation & configuration process. See the remaining documentation for more information.
  - *Button Box Configuration.ini*
    This special configuration file describes the [layout and control elements](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts) of your connected USB game controller and Button Boxes.
  - *Stream Deck Configuration.ini*
    This special configuration file describes the [layout and profiles](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#stream-deck-layouts) of your connected Stream Decks, if there are any.
  - *Simulator Settings.ini*
    This file is also created in the last step of "Simulator Setup" and is maintained in the future by the "Simulator Startup" application. It defines the [runtime and startup settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--settings) of Simulator Controller.

As already said, I recommend to stick to this tool for all your configuration tasks, unless you have a configuration need, which cannot be handled by "Simulator Setup". Please note, that some configuration changes that you make with the "Simulator Configuration" tool, which is described in the following sections, will be overwritten, if you use "Simulator Setup" to generate a new configuration afterwards.

Good to know: As said, you can run "Simulator Setup" as often as necessary. During later configuration sessions it might be benefical to skip the initial pages automatically on startup. To do this, you can enter the following two lines into the file "Application Settings.ini" in the *Simulator Controller\Config* folder which resides in the user *Documents* folder:

	[Simulator Setup]
	StartPage=X

Replace *X* with the number of the page you want to jump to on startup. As an alternative, you can also use the internal name of the step here:

| Step | Name              |
|------|-------------------|
| 1    | Start             |
| 2    | Basic             |
| 3    | Modules           |
| 4    | Installation      |
| 5    | Applications      |
| 6    | Controller        |
| 7    | General           |
| 8    | Simulators        |
| 9    | Assistants        |
| 10   | Motion Feedback   |
| 11   | Tactile Feedback  |
| 12   | Pedal Calibration |
| 13   | Finish            |

#### Presets & Special Configurations

"Simulator Setup" provides a selection of presets for otherwise time-consuming configuration steps. These are mostly preconfigured layouts for Button Boxes and Stream Decks. Even if you do not find your particular layout here, it might be even helpful to start with one of these preconfigured layouts instead of starting from scratch. Simply select the one that fits best.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Setup%203.JPG)

You will also find a couple of packages in the list of available presets for the so called search images, which are used by Simulator Controller to *understand* the state and available option in the Pitstop MFD *RaceRoom Racing Experience*. Detailed instructions for these search images can be found in the documentation for the [*RaceRoom Racing Experience* plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#important-preparation-for-the-pitstop-mfd-handling-1). The same applies here: If you don't find your specific language and/or screen resolution here, start with one which fits best and apply your changes afterwards.

Most presets must simply be moved to the right list to become active. But there are also presets, that require you to give additional information. These presets must be double-clicked to open up an additional window, which let you choose more preset specific options, like the preset for downloadable media files for additional splash screens:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Setup%204.JPG)

And last but not least, some very special configuration options are provided that cannot otherwise be created using the Setup Wizard. Although you can use "Simulator Configuration", the low level configuration tool, to achieve the same results, it requires a lot of knowledge about the inner workings of Simulator Controller.

Please note, that you can remove presets later on. But depending on the type of the preset, the side effects will still remain, since you might have changed the underlying configuration in the meantime, for example a specific Button Box configuration.

#### Locating Simulators and Applications

"Simulator Setup" scans various locations to auto detect the installed games and other applications which might be useful. However, sometimes it might be necessary to locate a software manually, especially, if this software has been installed in an uncommon location. You can use the "Locate..." button to manually identify the desired software in this case. For simulation games, this file must be a special one, which identifies the given software. Please consult the following table:

| Simulator                   | File                 | Comments                                        |
|-----------------------------|----------------------|-------------------------------------------------|
| Assetto Corsa               | AssettoCorsa.exe     |                                                 |
| Assetto Corsa EVO           | AssettoCorsaEVO.exe  |                                                 |
| Assetto Corsa  Competizione | acc.exe              |                                                 |
| rFactor 2                   | rFactor2.exe         |                                                 |
| Le Mans Ultimate            | Le Mans Ultimate.exe |                                                 |
| RaceRoom Racing Experience  | RRRE.exe             |                                                 |
| iRacing                     | iRacingUI.exe        | This file is located in a subfolder named "ui". |
| Automobilista 2             | AMS2.exe             |                                                 |
| Project Cars 2              | pcars2avx.exe        |                                                 |
| Rennsport                   | Rennsport.exe        |                                                 |

#### Patching the configuration

Disclaimer: The following mechanism is only for very experienced users, everybody else can skip this section.

It is possible to patch the generated configuration and/or settings files created by "Simulator Setup". To do this, create a *.ini file with those section/key/value information you want to replace in or add to the final configuration and/or settings information, name them "Conifguration Patch.ini" or "Settings Patch.ini" and drop them into the *Simulator Controller\Setup* folder in your user *Documents* folder. Corresponding sample files can be found in the *Resources\Templates* folder or you can add the corrsponding available presets to your configuration using "Simulator Setup".

The following rules apply:

  1. If you name a section, for example "[Plugins]", similar to the section label in the configuration file generated by *Simulator Setup*, the key / value pairs will simply overwrite everything with a similar key in this section. Missing keys in the generated configuration file will be created.
  
  2. If you prefix the section name with "Add: " like in "[Add: Plugins]", every value for a given key will be added to the current value of this key in the configuration file generated by *Simulator Setup*, unless it is already a part of the current value.
  
    Example:
  
    [Add: Plugins]
	Race Spotter=; synthesizer: dotNET
	
  3. If you prefix the section name with "Delete: " like in "[Delete: Plugins]", every value for a given key will be deleted from the current value of this key in the configuration file generated by *Simulator Setup*.
  
  4. Last, but least, you can replace parts of the current value for a given key in the configuration file generated by *Simulator Setup* by declaring a "[Replace: xxx]" section in the patch file with *xxx* as the name of the original section. The value for a key in the patch file must look like this:
  
    *original value 1*->*new value 1* [ | *original value 2*->*new value 2* | ... ]

    Example:
  
    [Replace: Plugins]
	Race Spotter=name: Elisa->name: Tom|listener: On->listener: Microsoft Stefan (de-DE)
	Race Engineer=name: Jona->name: Frank
	Race Strategist=name: Khato->name: Mary

### Running the Configuration tool

The more comprehensive configuration tool is located in the *Binaries* folder and is named *Simulator Configuration.exe*. If you start it, the following window will appear:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Editor.JPG)

The tool is divided in tabs for each aspect of the configuration process. You will find an explanation of each tab and its content below. Before you start experimenting with the configuration tool, be sure to make a backup copy of the current configuration file *Simulator Configuration.ini* in the *Config* folder, just to be safe. Generally, all your changes to the configuration files will be saved to the *Simulator Controller\Config* *Simulator Controller\Translations* folders in your user *Documents* folder.

Important: Once again, when you change your configuration with "Simulator Configuration", these changes will be unknown to "Simulator Setup" and might therefore be overwritten, whenever you run "Simulator Setup" again, especially when "Simulator Setup" is working on the same configuration item. No problem when you have a deeper knowledge of the inner workings of Simulator Controller, since you will use "Simulator Configuration" for all your configuration tasks, because it is much more powerful. But for the beginners, I recommend to stick with "Simulator Setup" as long as possible.

Hint: Beside simply running the configuration tool by double clicking it, there are two hidden modifiers. First, if you hold the Control key down, additional options for developers will be available. These will automatically appear, when an active AutoHotkey installation is detected (by checking, if the folder C:\Program Files\AutoHotkey is available). Second, if you hold the Control key and the Shift key simultaneously  while starting the configuration tool, any currently available configuration file in the *Config* folder will be ignored and you will start with a fresh, completely empty configuration.

### Using the Configuration tool

The configuration tool consists of several pages or tabs. Below you will find a description of each tab. Beside the pages, there are the well known buttons "Ok", "Cancel" and "Apply".

Note: You will find field labels that look like well known hyperlinks at several places in the configuration tool. Yes, you can click on them and a context sensitive section of the this documentation will be opened in your browser. With the *Save* mode dropdown menu in the lower left corner of the configuration dialog you can choose between *Manual* and *Automatic* save mode of all your changes to list items in the different editors.

#### Tab *General*

As the name of this tab suggests, some very general configuration options are provided. In the *Installation* group you can identify the root folder of the Simulator Controller installation - optional in most cases, but it may provide some performance benefits. The second path identifies the *NirCmd* executable, which is used by the Simulator Controller to control the sound volume of some simulation games. Optional, but helpful. See the [README](https://github.com/SeriousOldMan/Simulator-Controller#third-party-applications) for a link to the *NirCmd* download.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%201.JPG)

The second group, *Settings* allows you to choose whether the Simulator Controller will start together with Windows and whether it will run silently, i.e. without any splash animation or sound. With the button "Splash Screens..." you can jump to a special editor to customize the splash screens of various applications of Simulator Controller. See the chapter on the [splash screen editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#splash-screen-editor) for a complete explanation of splash screens. Last but not least you may choose a language for all user interface elements. English as the base language and a German translation are part of the Simulator Controller distribution, but you may define your own translations using the [translations editor](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#translations-editor), wich you can open by clicking on the small button next to the language drop down. For a full introduction to translation, see the separate [documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#localization-and-translation).

IMPORTANT: I recommend to not run Simulator Controller in silent mode, until everything has been setup and configured correctly. There are many message windows, that will inform you about configuration errors, but will be suppressed in silent mode to not interfere with the simulators operation.

Beside chosing the language for the user interface, you can also choose your preferred units and data formats for all displays and entry fields by clicking on the small button to the left of the language drop down menu. Please see the [next section](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#units-and-formats) for a detailed discussion on using customized units and formats.

You can add all the simulation games installed on your PC to the list in the third group *Simulators*. For each entry here, you also need to create a similar named application entry in the applications tab. Please note, that the name of all simulation games, where a plugin exists for, may have a predefined name according to the roles of the plugin. The order of the entries in the *Simulators* list is important, at least the first one has a special role. More on that later. You can change the order with the "Up" and "Down" button, if an entry is selected. As with any list in the configuration tool, an entry must be selected with a double click for editing.

The last group, which is only present in developer mode as mentioned above, lets you activate the debug mode, define the log level and enter the path to an AutoHotkey installation on your PC (only necessary, if AutoHotkey has been installed to a location other than C:\Program Files\AutoHotkey). Be careful with the log level *Info*, since the log files found in the *Simulator Controller\Logs* folder found in the users *Documents* folder may grow quite fast. If you want to automatically build all *Visual Studio* applications and DLLs while running *Simulator Tools*, you must enter the path to the *MSBuild Bin* directory here es well. See the [documentation for *Simulator Tools*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#using-the-build-tool) for more information.

##### Units and Formats

All Simulator Controller applications can handle different units and data formats. You can configure your preferred display and data entry units and field formats by using the below dialog.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Localization.JPG)

Please be aware, that choosing a specifc unit or field format here does only change the handling on the user interface level. The internal data format is not changed, which is to keep in mind, when you are looking at some of the data files of Simulator Controller. The internal units and formats are:

| Setting     | Value      |
| ----------- | ---------- |
| Temperature | Celsius    |
| Pressure    | PSI        |
| Mass        | Kilogram   |
| Volume      | Liter      |
| Length      | Meter      |
| Speed       | km/h       |
|             |            |
| Number      | #.##       |
| Lap Time    | [H:]M:S.## |

This choices are also the default, if you don't change anything here, except lap time, which is stored in milliseconds in the data files.

Please be also aware, that changing any of the units in the user interface of Simulator Controller does not change the corresponding unit in your simulator. If you set the pressure unit to *Bar* here and your simulator is working with *PSI*, the conversion for all entered values in the applications of Simulator Controller will be handled automatically, but if you look at the info in your simulator, you will still see *PSI*, of course.

#### Tab *Voice Control*

On this tab, you can configure the voice control support of Simulator Controller. Voice output is used by Jona, the [AI Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer), Cato, the [AI Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist), Elisa, the [AI Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter) and last but least Aiden, the [AI Driving Coach](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach), to give you crucial information during a session. All Assistants also support voice recognition, thereby allowing you a fully interactive conversation with them. And Simulator Controller itself also supports voice input for all types of commands and actions to give you complete hands free control over everything. These commands can be configured in the [*Controller* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller) as described below. 

To start with, simple speech generation is built into the Windows operating system, but you might have to install (additional) voices depending on the Windows installation and language packs you already have.

##### Installation of additional voices

Almost every Windows installation already has builtin support for voice generation (called TTS, aka text-to-speech). If you want to install more voices (and Jona and Cato will use all of them according to the configured language), you might want to install some additional packages. Depending on your Windows license you can do this on the Windows Settings dialog as described in the [Microsoft documentation](https://support.microsoft.com/en-us/office/how-to-download-text-to-speech-languages-for-windows-10-d5a6b612-b3ae-423f-afa5-4f6caf1ec5d3) ([German version](https://support.microsoft.com/de-de/office/herunterladen-von-text-zu-sprache-sprachen-f%C3%BCr-windows-10-d5a6b612-b3ae-423f-afa5-4f6caf1ec5d3)). The current language support of the Race Assistants comes with translations for English, German and some other languages, as these are the languages supported by Simulator Controller out of the box. I recommend to install additional voices using the Windows Settings for the languages you want to use to have some choices. Additionally, more voices might be available for the *old* Microsoft TTS engine, which is still supported in Windows 10 and Windows 11 [here](https://www.microsoft.com/en-us/download/details.aspx?id=27224). Look for files named "MSSpeech_TTS_de-DE_Hedda.msi" where "de-DE" is the language code and "Hedda" is the name of the voice.

##### Installation of speech recognition libraries

Simulator Controller supports several speech recognition frameworks. Built into Windows is the so called *Desktop* recognition engine. This engine has a very good and almost error free recognition rate, but needs high quality audio input without disturbing sounds. Best used with a headset. The second recognition engine originates from the Windows Server solution and was developed for voice input through telephone lines. It can handle disturbing noises and distortion, and can therefore be used with an external microphone in a noisy environment, but the recognition rate is not so good for longer phrases. This recognition engine, the so called *Server* recognition engine is not bundled with Windows and therefore needs a little bit more effort for installation. You can use the installer provided for your convenience in the *Utilities\3rd party* folder, as long you have a 64-bit Windows installation. Please install the runtime first and the provided language packs for English, German, Spanish and so on afterwards. Alternatively you can download the runtime from [this site at Microsoft](https://www.microsoft.com/en-us/download/details.aspx?id=27225) and the necessary language recognizer files from [this site at Microsoft](https://www.microsoft.com/en-us/download/details.aspx?id=27225). Look for files named "MSSpeech_SR_fr-FR_TELE.msi" where "fr-FR" is the language code. By the way, "Simulator Setup" will do this for you automatically.

After you have sucessfully installed all the necessary support packages, we can come back to the configuration of the voice capabilities.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207.JPG)

You can define the spoken language you want to use for speech generation with the first dropdown menu. With the second drop down menu, you can choose the speech synthesis engine, which you want to use for speech generation. You have the choice between two different synthesizers which execute on your local PC and you can also use the speech services of the Azure Cognitive Services cloud or the Google Cloud. "Windows (Win32)" and "Windows (.NET)" are built into the Windows operating system and provide more or less the same voice quality, but you may have access to dfferent sets of available voices.

###### Azure Cognitive Services

If you choose "Azure Cognitive Services", two additional fields will appear, where you have to enter your Azure subscription key and the endpoint for your region.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Azure%20Service.JPG)

You must been registered for the Azure Cloud Services (see https://azure.microsoft.com/ for more details), and you must have configured a resource for the "Microsoft Cognitive Services Speech" API. Both is really easy and free of charge. After you have configured the resource, you will get access to the subscription key and the token issuer endpoint information. Depending on your Windows installation, you might have to install the latest .NET Runtime as well (version 4.7.2 and 4.8 are used by Simulator Controller).

Important: Sometimes Azure shows only the main URL for the endpoint in the "Keys and Endpoint" area of the Azure Portal. It will then look like this:

	https://westeurope.api.cognitive.microsoft.com/

Using only this URL will not work as an endpoint for the token issuer. Always append the subpart for the token issuer to the URL like this:

	https://westeurope.api.cognitive.microsoft.com/sts/v1.0/issuetoken

Please note, that although you must supply a credit card when registering, according to Microsoft you won't be charged a single cent, unless you give explicit consent for a specific resource. Regarding the Speech API resource, up to 500.000 characters of Text-to-Speech conversion are free per month in the regions "US, East", "Asia, South-East" and "Europe, West". I am quite sure, that you will never reach this limit, unless you are doing 24 h races seven times a week for the whole month, so give it a try...

###### Google Speech Services

If you choose "Google Speech Services", one additional field will appear. Here you have to enter the API key for accessing the Google Text to Speech service.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Google%20Service.JPG)

To use the Google speech service, you must have been registered for the Google cloud (see https://console.cloud.google.com for more details). After you have created your cloud project and registered your credit card for billing services, you have to enable the text to speech in the cloud shell using the following command: "gcloud services enable texttospeech.googleapis.com". Then generate an API key in the "APIs and Services" submenu of the main menu and copy the new key to the above configuration.

Please note, that although you must supply a credit card when registering, you won't be charged a single cent, since according to Google the first million characters are free of charge. I am quite sure, that you will never reach this limit, unless you are doing 24 h races seven times a week for the whole month, so give it a try...

After choosing the speech synthesis method, you can choose the concrete voice to be used for voice synthesis. Be careful, a mismatch between chosen language and the selected voice generator will give you very funny results. And not all voices support the SSML format for supplying speed, tonality and so on. Therefore use the "Play" button to find the voices you can use. According to my own experiments, all *Neural* voices can be used without restrictions. For voice output you can set the volume, the pitch and the speed (rate) using the three corresponding sliders.

Good to know: You can use the *Play* button to the left of the voice drop down menu to prelisten the selected voice incl. the current settings of the vocalics and the SoX-based sound post-processing.

Quite similar, you can define which recognition engine should be used. I recommend to start with the so called *Desktop* engine, which is built into Windows and needs no installation. If you can't provide the required audio quality and have a lot of recognition errors, please use the *Server* recognition engine as described above. Runtime and language libraries will have been installed by "Simulator Setup" automatically, if you have used the *Basic* setup. Or you can install them manually on the pages for additional software.

After selecting the desired recognizer, you can also choose here the language specific recognition engine. I recommend to leave the setting at "Automatic".

You can also use the speech to text capabilities of the Azure Cognitive Services cloud here, very similar to the speech synthetization described above. According to Microsoft, 5 hours of speech to text conversion is free per month. I stronlgy recommend using this service only, when you also have configured *Push-To-Talk* (see below), otherwise, your microphone will always be open and the 5 hours will be depleted quite fast. Please note, that choosing "Automatic" for the specific recognizer engine might not be a great idea here, when several engines with different dialect support are available for a given language. So please choose the engine, which fits your language and culture best.

As an alternative to the Azure cloud services, corresponding Google services are available as well. Similar to the Text to Speech service of Google, this service must be activated before it can be used. However, the free contingent for the Google speech recognition service is only one hour per month, therefore you might prefer the Azure offer.

IMPORTANT: It is necessary to use one of the cloud based speech recognition services or the Whisper Runtime described below, if you want to talk to Aiden, the AI Driving Coach. This is necessary, since the interaction with Aiden does not use pattern based commands, for which the builtin speech recognition engines of Windows are optimized for (the *Desktop* engine can actually handle a bit of free speech, but not very well). The aforementioned speech recognition services of Azure, Google or the free Whisper are way better, when it comes to free speech.

###### Whisper Runtime

Whisper is a very capable neural speech recognition system developed by OpenAI. Whisper is open source and executes locally on your PC. Therefore it requires a powerful machine and a GPU with at least 6GB of free memory beside the requirements of the current simulator, if you want to run the neural network on your graphics card, which I strongly recommend for performance. To make Whisper available, do the following:

1. [Recommended] Install CUDA libraries for your GPU. These can be typically found on on the website of the graphics card manufacturer. Here is the [link](https://developer.nvidia.com/cuda-downloads) for Nvidia GPU support. A solution for AMD GPUs is described [here](https://www.xda-developers.com/nvidia-cuda-amd-zluda/).
2. Install the [preset "Local runtime for Whisper speech recognition"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#presets--special-configurations) using "Simulator Setup". Please note that the Whisper runtime itself is a download package of around 2.5 GB, so be patient. Additionally, the chosen model will be downloaded on first execution, which will consume another 3 - 15 GB of precious space on your drive (depending on the actual model) and will take some time as well to download and install.

After everything is installed, Whisper Runtime will be available as speech recognition engine (a restart of "Simulator Setup" may be necessary, though). When using Whisper Runtime, you can choose between models of different sizes - I recommend to start with the "medium" model, which supports different languages, shows a good recognition quality and consumes *only* around 6 GB of graphics card memory.

|  Size  | Parameters | English-only model | Multilingual model | Required VRAM | Relative speed |
|:------:|:----------:|:------------------:|:------------------:|:-------------:|:--------------:|
|  tiny  |    39 M    |     `tiny.en`      |       `tiny`       |     ~1 GB     |      ~10x      |
|  base  |    74 M    |     `base.en`      |       `base`       |     ~1 GB     |      ~7x       |
| small  |   244 M    |     `small.en`     |      `small`       |     ~2 GB     |      ~4x       |
| medium |   769 M    |    `medium.en`     |      `medium`      |     ~5 GB     |      ~2x       |
| large  |   1550 M   |        N/A         |      `large`       |    ~10 GB     |       1x       |
| turbo  |   809 M    |        N/A         |      `turbo`       |     ~6 GB     |      ~8x       |

If you are using English to interact with all Assistants, you can use one of the models with the ".en" ending. They are much smaller and also a bit faster than their multilingual counterparts.

IMPORTANT: When you are using a given model for the first time, it will be downloaded and installed automatically. Depending on the size of the model, this can take a very long time. A progress bar will be opened while downloading, so be sure to not do this while driving.

###### Notes

1. You will use the same Azure or Google subscription and the same cloud resource for both the speech synthetization and speech recognition. If Azure or Google has been selected for both, only one set of fields for the endpoint and subscription key will appear.
2. Regardles of what you have configured as listener for each Assistant (see below), a separate listener with the chosen language from this configuration will be used for the activation commands, with or without *Push-To-Talk*. Either the Desktop recognition engine will be used here or you can configure the Server recognition engine (when you have installed the required libraries) in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration). This applies always, also when you are not using cloud based recognition services.
3. As mentioned above, using the cloud-based recognition engines or Whisper without *Push-To-Talk* is not a very good idea. It is not only because of the costs but even more, because the recognition will try to react to each and every thing you say. You will get a lot of "Sorry, can you repeat that, please", while you try to talk to your other Assistants while one is listening using the cloud-based recognition engine.

Last, but not least, if you have installed [SoX](http://sox.sourceforge.net/), it will be used to apply audio post processing to the spoken voice to achieve a sound like a typical team radio. Really immersive stuff, you won't miss that. When you have chosen the location of the *SoX* application folder, you can click on the small button with the gear icon. This opens a small dialog, where you can specify the strength of the different sound effects. The default settings will give you the typical car radio sound with some background noises, crackles and a little bit of distortion.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Sound%20Processing.JPG)

Note: Additionally to this default configuration, you can specify the spoken and recognized language and the voice for each Race Assistant individually using plugin parameters (see the configuration documentation of [Jona](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-engineer) or [Cato](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-race-strategist) or [Elisa](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter) for more details). Choosing different voices will be helpful to better recognize who is currently talking.

With the last option, you can configure a *Push-To-Talk* function for voice recognition, which will greatly enhance the voice recognition quality and will avoid almost all false positives, if you are not in a very quite environment. The argument to be entered in the field is a key code as defined in the AutoHotkey [key list](https://www.autohotkey.com/docs/KeyList.htm). For example, "LControl" defines the left control key on the keyboard, whereas "4Joy2" defines the second button on your 4th connected hardware controller.
Using *Activation Command* you can supply a keyword or a complete phrase to focus the voice recognition framework to the commands you defined as voice commands for [controller actions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller). The recognition language for this activation command will always be the one chosen by the language dropdown menu above. For more information on how to use multiple voice *communication partners*, see the [corresponding documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands).

###### Notes

1. You can use the [Trigger Detector Tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#trigger-detector-tool) to find out, which button codes your connected controller actually use, by clicking the small button on the right side of the *Push-To-Talk* entry field. If you push a simple button on your external controller or a single key on your keyboard, the corresponding hotkey name will be inserted into the *Push-To-Talk* edit field.
2. There are different modes available to choose how the *Push-To-Talk* button behaves. For a detailed explanation see the corresponding [documentation for voice commands](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands). The mode "Custom" is very special and need you to script the controller action functions "startActivation", "startListen" and "stopListen", which are described further down below.
3. Once you have configured the *Push-To-Talk* button, you can start a *Test* mode by pressing the small button with the "Play" icon. The Assistants will start up and you can start a conversation with them. Please note, that depending on the chosen recognizer, the activation command mode must be initiated by a double-press. See the [documentation for voice commands](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) for more information.
4. It is possible to configure multiple *Push-To-Talk* buttons, but you must enter the corresponding codes manually. Separate them either by ";" or by "|".

##### Boosting conversation with an LLM

The voice recognition for all Assistants except the Driving Coach is normally pattern-based. [Here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Engineer-Commands-(EN)), for example, you can find a documentation for the definition of the recognized commands of the Race Engineer and similar documentation is available for the other Assistants as well. The speech output of all Assistants is also preprogrammed with several different phrases for each message, to create at least a little variation.

Said this, it is clear, that the interaction with the Assistants, although already impressive, will not feel absolutely natural in many cases. But using the latest development in AI with LLMs (aka large language models) it became possible to improve the conversational capabilities of the Assistants even further. Whenever you see a small button with an icon which looks like a launching space rocket, you can configure AI pre- and post-processing for voice recognition, speech output and general conversation.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Speech%20Improvement.JPG)

Improving and extending the Assistants using an LLM requires quite some dedication and knowledge, therefore I recmmend to start without it. Once everything is running as expected and you think you are ready for this, take a look at the documentation on [Customizing Assistants](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants).

#### Tab *Plugins*

In this tab you can configure the plugins currently in use by the Simulator Controller.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%202.JPG)

Beside temporarily deactivating a plugin and all its modes, you can define a comma separated list of simulator names. This will restrict the modes of the plugin to only be available, when these simulators are running. The most important field here is the *Arguments* field. Here you can supply values for all the configuration parameters of the given plugin. The format is like this: "parameter1: value11, value12, value13; parameter2: value21, value22; ...". Please take a look at the [plugin reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for an in depth explanation of all the parameters of the bundled plugins.

A special editor is available by clicking on the small button with the launching rocket icon, when you have selected a plugin for one of the Race Assistants. This editor allows you to link a GPT service to this Assistant which can dramatically improve the conversation experience with the Assistant. Please see the separate [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants) for more information about the Assistant Booster.

Last but not least, you will find an "Edit Labels & Icons..." button in the lower left corner of this tab. Pressing this button will open a special editor, which allows you to configure the language specific labels and icons for all controller actions. You will find more information on this in the [chapter on controller layout configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons).

Note: You can deactivate or delete all plugins except *System*. The *System* plugin is required and part of the framework. If you delete one or more of the other plugins here, they will still be loaded by the Simulator Controller, but they won't be activated. On the other hand, if you add a plugin here, but haven't added any plugin code, nothting will happen. And, last but not least, the plugin names given here must be identical to those used in the plugin code. Some sort of primary key, hey. If you have some development skills, see the documentation on [plugin development](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts) for further information.

#### Tab *Applications*

Simulator Controller can handle as many applications as you want. Beside the simulation games itself, you may want to launch your favorite telemetry or voice chat application with a push of a button. Or you want an image recognition software to be started together with the Simulator Controller to be able to translate your head movement to the *freetrack* protocol to control your viewing angle. The possibilities are endless. To be able to do that, Simulator Controller needs knowledge about these applications, where to find them and how to handle them. This is the purpose of the *Applications* tab.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%203.JPG)

There are three diffenrent types of applications, "Core", "Feedback" and "Other". All of these applications are optional, but for the "Core" and "Feedback" category, Simulator Controller is aware of them, either directly or with the help of a plugin, and use them for a better user experience. Since adding "Core" and "Feedback" applications also need some development efforts, the categories cannot be changed by using the configuration tool, which means, that any application added here will be automatically of type "Other". But "Other" applications may be used by the [Launchpad](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-launchpad).

Note: To change the category of an application, you need to directly edit the *Simulator Configuration.ini* file.

An application must a have a unique name, you must supply the path to the executable file and sometimes also to a special working directory, and you may supply a [window title pattern](https://www.autohotkey.com/docs/misc/WinTitle.htm) according to the AutoHotkey specification. This is used to detect whether the application is running.

Second note: Although you cannot delete any application in the "Core" or "Feedback" category, you still can disable them in the [settings for the startup process](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--settings).

For developers: Sometimes you want magic stuff to happen, when an application is started. For example, you may automatically switch to your favorite team channel when starting your voice chat software. This need some code support, which can be provided in a plugin. You *simply* define a function, which handles this special stuff and reference it here in the application configuration. See the plugins [Core Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/Core%20Plugin.ahk), [RST Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/RST%20Plugin.ahk) and [AC Plugin](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Plugins/AC%20Plugin.ahk) for some examples.

#### Tab *Controller*

This tab represents the most important, the most versatile and also the most difficult to understand part of the configuration process. On this page, you describe your hardware controllers, for example one or more Button Boxes, and all the functionality available on this controller.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%204.JPG)

Note: Beginning with Release 2.4, Simulator Controller supports multiple connected hardware controller, like Button Boxes. The functions defined on the *Controller tab* will span all connected controller. So, the first controller might define Button #1 to Button #8 and the second controller will define Button #9 onwards. A sngle mode can use controls from several controller, but you can also have multiple modes active at the same time, as long as these modes uses controls from distinct controller. See the documentation on the "System" plugin for more information on [how to control multiple simultaneous modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-system).

In the first step you have to define the controller, Button Boxes, Stream Decks and so on, which will be activated by Simulator Controller, by entering them into the list. Each controller must have a name, which might be displayed on the visual representation and you must chose a layout definition from the dropdown next to the name entry field. Button Box layouts, for example can be configured using a separate tool, which is described in a [dedicated documentation chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#button-box-layouts) below. This tool can be opened by pressing the small little button with the three dots next to the dropdown menu. The same applies for [Stream Deck layouts](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#stream-deck-layouts).

Note: The order, in which the controller are entered into the given list, establish the order they will initially appear on screen, as long as they have a visual representation, which is the case for Button Boxes. You can move this windows around using the mouse later on.

After you have configured all your controller, you must configure the controller functions, which will be associated with the controls on your hardware controller or which might be triggered by other software systems using hotkeys. For each function and its corrsponding binding, you have to create an entry in the *Functions* list.
In the *Bindings* group, you define one or two hotkeys and optionally corresponding actions, depending on whether you have defined a unary or binary function type. 2-way toggles and dials need two bindings for the "On" and "Off", respectivly the "Increase" and "Decrease" trigger. The binding of a function happens by defining [hotkeys](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys), which might trigger the given function. You can define more than one hotkey descriptor, separated by the vertical bar "|", for each trigger in the controller tab. This might be useful, if you have several sources, which can trigger a given function. For example you might have a function, which can be triggered by pushing a button on the controller, but also from the keyboard, which might be emulated by another tool, for example a voice recognition software.

Additionally to definining hotkeys for keyboard or controller triggers, you can now use the voice recognition capabilities of Simulator Controller, which were introduced with Release 2.1 for the AI Race Engineer (see [update notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes#release-21) for specific installation information). A voice trigger must be preceeded by "?" and you can use the full [phrase grammar](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#phrase-grammars) capabilities of the voice recognition framework. But in most cases, you will use simple phrases like "?Next Page", which might be used as a voice trigger for the mode switch. Please be aware, that the recognition language uses the language setting, that is chosen in the configuration. As a result, you might have to change your phrases, if you decide to switch to a different language setting in the user interface. Examples can be found below in the [*Hotkeys*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys) section.

Note: As already documented in the [troubleshooting](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#troubleshooting) section of the documentation for the AI Race Engineer, you will get the best results with a headset.

Beside the hotkey(s), one or more functions may define an [action](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#actions), which must represent calls to global functions in the scripting language. For all functions managed by plugins, you can leave the action field empty, since in the Simulator Controller framework, actions are represented by instances of [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk). If you want to supply multiple functions to be called as actions, they must be separated by the vertical bar "|" as for the hotkey descriptors (";" may be used here as well). 

Last, but not least, and only for the experienced user: Functions can be overloaded. If you bind an action to a function, for example with a [plugin argument](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes), you can reference a given function multiple times. All bound and enabled actions will be triggered by the function at the same time. This might be useful, if you want to control several aspects of your simulation equipment with the same hardware control, for example: You define a master toggle switch, to enable or disable rig motion and vibration at the same time.

##### Hotkeys

The central concept to connect to your hardware controller or to other external trigger is a *Hotkey*. A hotkey is a concept of the Windows operating system, whereby a combination of several keys on the keyboard, mouse or other controlling device might trigger a predefined action. The AutoHotkey language defines a special syntax to define hotkeys. You will find a comprehensive guide to this syntax and all available keys in the [documentation](https://www.autohotkey.com/docs/Hotkeys.htm) of AutoHotkey. For example the string <^<!F1 defines a hotkey for function key one (F1), which must be pressed together with the left (<) Control (^) and left (<) Alt (!) key to be triggered. Beside hotkeys for the keyboard or mouse events, AutoHotkey provide a definition for hotkeys for external controllers, called joysticks. For example, 2Joy7 defines the seventh button on the second controller connected to the PC.

Below you will find a brief and incomplete overview over the possible hotkeys, to help you to understand the hotkeys found in the sample configuration file. Please take a look at the complete [documentation](https://www.autohotkey.com/docs/Hotkeys.htm) of AutoHotkey for further information.

| Symbol | Description |
| ------ | ------ |
| ^ | A modifier that represents the CTRL key. |
| ! | A modifier that represents the ALT key. |
| + | A modifier that represents the SHIFT key. |
| # | A modifier that represents the WIN key. Not a good idea to consume them, but they can still be used in the "trigger" controller action function. |
| < | A modifier for all keys that restrict it to be on the left side of the keyboard. |
| > | A modifier for all keys that restrict it to be on the right side of the keyboard. |
| A - Z | A normal alphabetical key on the keyboard. |
| F1 - Fn | A function key on the keyboard, if avilable. |
| Numpad0 - Numpad9 | A numpad key on the keyboard, if avilable. These will only be send, if NumLock is activated on the keyboard. |
| LMouse, RMouse | The left and the right mouse button. |
| {X}Joy{Y}| The y-th button on the x-th connected joystick or general hardware controller. Example: "2Joy7". You can use the [Trigger Detector Tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#trigger-detector-tool) to find out, which button codes your connected controller actually use. |

Beside using the standard Hotkey syntax of AutoHotkey, you can use a special *Hotkey* syntax supplied by Simulator Controller to configure a voice command as described above, as long as you configured voice control at all. Please see the [tab *Voice Control*](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control) above for more information on voice control. Here are some examples:

| Example | Description |
| ------ | ------ |
| ?Next mode | This voice *hotkey* will most likely be used to switch the mode on the controller. You simply have to say: "Next Mode". |
| ?{Please} activate motion | This voice *hotkey* can be used for a function that activates the rig motion. You can say: "Please activate motion", but the "please" is optional, so "Activate motion" will work as well. |

Note: The handling of voice hotkeys follow the general rules of voice commands. Therefore you might need to use *Push-To-Talk* and also activation commands, if you have more than one voice dialog partner configured, for example the AI Race Assistants. Please see the documentation on [Voice Commands](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) for more information.

##### Actions

An action is simply a textual representation of a call to a function in the scripting language. It simply looks like this: "setMode(Pedal Vibration)", which means, that the "Pedal Vibration" mode should be selected as the active layer for your hardware controller. You can provide zero or more arguments to the function call. All arguments will be passed as strings to the function with the exception of *true* and *false*, which will be passed as literal values (1 and 0).

Although you may call any globally defined function, you should use only the following functions for your actions, since they are specially prepared to be called from an external source. Many of these functions are particular useful in combination with a [*Conversation* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#conversation-booster).

Please note, that action functions must be written as a function call with "()" as in "increaseLogLevel()", even if there are no actual arguments.

| Function | Parameter(s) | Plugin | Description |
| ------ | ------ | ------ | ------ |
| setDebug | debug | Builtin | Enables or disables debugging. *debug* must be either *true* or *false*. |
| setLogLevel | logLevel | Builtin | Sets the log level. *logLevel* must be one of "Info", "Warn", "Critical" or "Off", where "Info" is the most verbose one. |
| increaseLogLevel | - | Builtin | Increases the log level, i.e. makes the log information more verbose. |
| decreaseLogLevel | - | Builtin | Decreases the log level, i.e. makes the log information less verbose. |
| pushButton | number | Builtin | Virtually pushes the button with the given number. |
| rotateDial | number, direction | Builtin | Virtually rotates the rotary dial with the given number. *direction* must be one of "Increase" or "Decrease". |
| switchToggle | type, number, state | Builtin | Virtually switches the toggle switch with the given number. *state* must be one of "On" or "Off" for 2-way toggle switches and "On" for 1-way toggle switches. The type of the toggle switch must be passed as *type*, one of "1WayToggle" and "2WayToggle". |
| callCustom | number | Builtin | Calls the custom controller action with the given number. |
| setMode | plugin, mode | Builtin | Switches the currently active mode for the hardware controller. See the [plugin reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes) for an in depth explanation of all available modes. Instead of supplying the name of a plugin and mode, you can omit the second argument and supply "Increase" or "Deacrease" for the first parameter. In this case the controller will activate the next mode like in a carousel. |
| speak | message | System | Speaks the supplied *message* using the [default voice synthesizer configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-voice-control). |
| play | fileName | System | *fileName* must a supported sound file, which is then played. |
| execute | command | System | Execute any command, which can be an executable or a script with an extension accepted by the system. The *command* string can name additional arguments for parameters accepted by the command, and you can use global variables enclosed in percent signs, like %ComSpec%. Use double or single quotes to handle spaces in a part of the command string.<br><br>Example: execute("D:\Programme\Nircmd.exe" changeappvolume ACC.exe -0.1) - reduces the sound volume of *Assetto Corsa Compeitizione* by 10 percent.<br><br>A special case are *Lua* scripts, as identified by the ".script" or ".lua" extension. In this case the *Lua* script is executed in the "Simulator Controller" process and any arguments that have been passed to the script are available in the global array *Arguments*. The script also has access to the simulator state and API data using the [*Simulator* script module](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Script-Modules). Please note, that other modules are not supported in this context, but you can reference and call any global object or function using the "extern" function. |
| trigger | hotkey(s), [Optional] method | System | Triggers one or more hotkeys. This can be used to send keyboard commands to your simulator, for example. Each keyboard command is a [keyboard command hotkey](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#hotkeys). Use the vertical bar to separate between the individual commands, if there are more than one command. The optional argument for method specifies the communication method to send the keyboard commands. These are named "Event", Input", "Play", "Raw" and "Default". For whatever reason, there is not the one method, which works for every Windows installation. For me, "Event" works best and is therefore the standard, if you don't supply the argument. |
| mouse | button, x, y, [Optional] count, [Optional] window | System | Clicks the specified mouse button (one of "Left", "Right" or "Middle") at the given location. You can supply the number of clicks using *count* and you can supply a target window using the optional parameter *window*. Coordinates are relative to the upper left corner of the *window*, if supplied, otherwise relative to the uper left corner of the screen. |
| invoke | target, method, [Optional] argument, ... | System | Invokes an internal method. *target* may be either "Controller" (or "Simulator Controller") for a method of the single controller instance itself or the name of a registered plugin or a name of a mode in the format *plugin*.*mode* and *method* is the name of the method to invoke for this target. You can supply any number of arguments to the invocation call. |
| startSimulation | [Optional] simulator | System | Starts a simulation game. If the simulator name is not provided, the first one in the list of configured simulators on the *General* tab is used. |
| stopSimulation | - | System | Stops the currently running simulation game. |
| shutdownSystem | - | System | Displays a dialog and asks, whether the PC should be shutdown. Use with caution. |
| targetListener | target | Voice Control | Directs the next voice commands to the supplied *target*, which must eiher be "Controller" or the name of one of the Race Assistants. Simuilar to using the [Push-To-Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) button and then issuing an activation command. Only usable, if you have chosen the custom *Push-To-Talk* mode in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration). |
| startActivation | - | Voice Control | Activates the activation listen mode. Simuilar to using the [Push-To-Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) button to prepare for issuing an activation command. Only usable, if you have chosen the custom *Push-To-Talk* mode in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration). |
| startListen | - | Voice Control | Activates the listen mode of the currently targeted dialog partner. Simuilar to using the [Push-To-Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) button. Only usable, if you have chosen the custom *Push-To-Talk* mode in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration). |
| stopListen | - | Voice Control | Stops the listen mode and tries to understand the spoken command (both activation and normal). Simuilar to using the [Push-To-Talk](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#voice-commands) button. Only usable, if you have chosen the custom *Push-To-Talk* mode in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration). |
| enableListening | - | Voice Control | Fully enables voice recognition again after it has been disabled using *disableListening*. |
| disableListening | - | Voice Control | Fully disables voice recognition for all currently active conversation partners. Listening will also be disabled for all conversation partners, which are started afterwards. No microphone input will be processed until the listening is enabled again using *enableListening*. |
| enablePedalVibration | - | Tactile Feedback | Enables the pedal vibration motors, that might be mounted to your pedals. Available depending on the concrete configuration. |
| disablePedalVibration | - | Tactile Feedback | Disables the pedal vibration motors, that might be mounted to your pedals. Available depending on the concrete configuration. |
| enableFrontChassisVibration | - | Tactile Feedback | Enables the chassis vibration bass shakers that might be mounted to the front of your simulation rig. Available depending on the concrete configuration. |
| disableFrontChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the front of your simulation rig. Available depending on the concrete configuration. |
| enableRearChassisVibration | - | Tactile Feedback | Enables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| disableRearChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| disableRearChassisVibration | - | Tactile Feedback | Disables the chassis vibration bass shakers that might be mounted to the rear of your simulation rig. Available depending on the concrete configuration. |
| startMotion | - | Motion Feedback | Starts the motion feedback system of your simulation rig. Available depending on the concrete configuration. |
| stopMotion | - | Motion Feedback | Stops the motion feedback system of your simulation rig and brings the rig back to its resting position. Available depending on the concrete configuration. |
| openPitstopMFD | [Optional] descriptor | AC, ACC, RF2, R3E, IRC | Opens the pitstop settings dialog of the simulation that supports this. If the given simulation supports more than one pitstop settings dialog, the optional parameter *decriptor* can be used to denote the specific dialog. For IRC this is either "Fuel" or "Tyres", with "Fuel" as the default. This action function also resets the memorized state of the Pitstop MFD in ACC. So you may want to dedicate a button for this, if you quite often change pitstop settings manually. |
| closePitstopMFD | - | ACC, RF2, R3E, IRC | Closes the currently open pitstop settings dialog of the simulation that supports this. |
| changePitstopOption | option, selection, [Optional] increments | AC, ACC, RF2, R3E, IRC | Enables or disables one of activities carried out by your pitstop crew. The supported options depend on the current simlation game. For example, for ACC the available options are "Change Tyres", "Change Brakes", "Repair Bodywork" and "Repair Suspension", for R3E "Change Tyres", "Repair Bodywork" and "Repair Suspension", for RF2 "Repair", and for IRC "Change Tyres" and "Repair". *selection* must be either "Next" / "Increase" or "Previous" / "Decrease". For stepped options, you can supply the number of increment steps by supplying a value for *increments*. For other, more common pitstop activites like refueling, use on of the next actions. |
| changePitstopStrategy | selection | AC, ACC, R3E | Selects one of the pitstop strategies (this means predefined pitstop settings). *selection* must be either "Next" or "Previous". |
| changePitstopFuelAmount | direction, [Optional] liters | AC, ACC, RF2, R3E, IRC | Changes the amount of fuel to add during the next pitstop. *direction* must be either "Increase" or "Decrease" and *liters* may define the amount of fuel to be changed in one step. This parameter has a default of 5. |
| changePitstopTyreSet | selection | ACC | Selects the tyre sez to change to during  the next pitstop. *selection* must be either "Next" or "Previous". |
| changePitstopTyreCompound | selection | AC, ACC, RF2 | Selects the tyre compound to change to during  the next pitstop. *selection* must be either "Increase" or "Decrease" to cycle through the list of available options. |
| changePitstopTyrePressure | tyre, direction, [Optional] increments | AC, ACC, RF2, IRC | Changes the tyre pressure during the next pitstop. *tyre* must be one of "All Around", "Front Left", "Front Right", "Rear Left" and "Rear Right", and *direction* must be either "Increase" or "Decrease". *increments* with a default of 1 define the change in 0.1 psi increments. |
| changePitstopBrakePadType | brake, selection | ACC | Selects the brake pad compound to change to during the next pitstop. *brake* must be "Front Brake" or "Rear Brake" and *selection* must be "Next" or "Previous".  |
| changePitstopDriver | selection | ACC, RF2 | Selects the driver to take the car during the next pitstop. *selection* must be either "Next" or "Previous". |
| startTelemetryCoaching | confirm, auto | Driving Coach | Initiates telemetry data collection by the Driving Coach. After a few laps the Coach will be ready to discuss your performance with you. If *confirm* is supplied and *false*, no confirmation is given by the Driving Coach. If *auto* is supplied and *true*, the Driving Coach will start to give corner by corner instructions, once telemetry is available. |
| finishTelemetryCoaching | confirm | Driving Coach | Stops the telemetry based coaching mode of the Driving Coach. |
| startTrackCoaching | - | Driving Coach | Instructs the Driving Coach to give corner by corner instructions while you are driving. If *confirm* is supplied and *false*, no confirmation is given by the Driving Coach. |
| finishTrackCoaching | - | Driving Coach | Stops the Driving Coach to give corner by corner instructions. |
| planPitstop | - | Race Engineer | *planPitstop* triggers Jona, the AI Race Engineer, to plan a pitstop. |
| planDriverSwap | - | Race Engineer | This is a special form of *planPitstop*, which is only available in team races. Jona is asked to plan the next pitstop for the next driver according to the stint plan of the session. |
| preparePitstop | - | Race Engineer | *preparePitstop* triggers Jona, the AI Race Engineer, to prepare a previously planned pitstop. |
| openRaceSettings | import | Race Engineer, Race Strategist, Team Server | Opens the settings tool, with which you can edit all the race specific settings, Jona needs for a given race. If you supply *true* for the optional *import* parameter, the setup data is imported directly from a running simulation and the dialog is not opened. |
| openSetupWorkbench | - | Race Engineer | Opens a tool, which generates recommendations for changing the setup options of a car based on problem descriptions provided by the driver. |
| openRaceReports | - | Race Strategist | Opens the bowser for the post race reports generated by the AI Race Strategist. If a simulation is currently running, The simulation, car and track will be preselected. |
| openSessionDatabase | - | Race Engineer, Race Strategist | Opens the tool for the session database, with which you can get the tyre pressures for a given session depending on the current environmental conditions. If a simulation is currently running, most of the query arguments will already be prefilled. |
| openStrategyWorkbench | - | Race Strategist | Opens the "Strategy Workbench" tool, with which you can explore the telemetrie data for past session, as long as they have been saved by the Race Strategist, and with which you can create a strategy for an upcoming race. If a simulation is currently running, several selections (car, track, and so on) will already be prefilled. |
| openSoloCenter | - | Race Engineer, Race Strategist | Opens the "Team Center" tool, with which you can optimize your practice sessions and collect the most relevant data. |
| openTeamCenter | - | Race Engineer, Race Strategist, Team Server | Opens the "Team Center" tool, with which you can analyze the telemetry data of a running team session, plan and control pitstops and change race strategy on the fly. |
| enableRaceAssistant | name | Race Engineer, Race Strategist, Race Spotter | Enables the Race Assistant with the given *name*, which must be one of : Race Engineer, Race Strategist or Race Spotter. |
| disableRaceAssistant | name | Race Engineer, Race Strategist, Race Spotter | Disables the Race Assistant with the given *name*, which must be one of : Race Engineer, Race Strategist or Race Spotter. |
| enableDataCollection | type | This enables the transfer of data of the given *type* to the session database again, after it had been disabled previously by calling *disableDataCollection*. *type* must be one of "Pressures" for cold pressures information collected by the Race Engineer or "Laps" for strategy-related data collected by the Race Strategist.<br><br>Good to know: The data is still being collected and used for any purpose during the session, but will not be stored in the database at the end of the session. |
| disableDataCollection | type | This disables the transfer of data of the given *type* to the session database at the end of the session. *type* must be one of "Pressures" for cold pressures information collected by the Race Engineer or "Laps" for strategy-related data collected by the Race Strategist. Use this in sessions, if you don't want the data to be permanently stored, because you are in a race with 2x fuel consumption for example. Please note, that calling *disableDataCollection* only affects the Race Assistants directly. Any data collected in the "Solo Center" for example can still be transfered to the session database manually.<br><br>Good to know: The data is still being collected and used for any purpose during the session, but will not be stored in the database at the end of the session. |
| enableTrackMapping | - | Race Spotter | Enables track mapping. If the track is not a circuit, track mapping will start immediately, otherwise it will start at the beginning of the next lap. |
| disableTrackMapping | - | Race Spotter | Disables track mapping. If the track track scanner has been active, a track map will be created in the next step. |
| enableTrackAutomation | - | Race Spotter | Enables the track automation. Can be called anytime, the automation will be activated at the beginning of the next lap. |
| disableTrackAutomation | - | Race Spotter | Disables the track automation. No further actions will be executed. |
| selectTrackAutomation | [Optional] name | Race Spotter | Selects one of the configured track automations by its *name* and loads it. If *name* is omitted, the automation marked as the active one, will be loaded. If track automation is currently enabled, the execution of actions will start with the next lap. |
| enableTeamServer | - | Team Server | Enables the team mode and opens a connection to the currently configured Team Server. Must be called before session start. |
| disableTeamServer | - | Team Server | Disables the team mode and closes the connection to the Team Server. |

##### Trigger Detector Tool

This little tool will help you identifying the button numbers of your hardware controller. If you push the "Trigger..." button, a flying tool tip will apear next to your mouse cursor, which provide some information about your connected controller devices and the buttons or other triggers, that are currently being pushed there. You can also type a single key on the keyboard to display the correpsonding logical key name. To disable the tool tip, press the "Trigger..." button again or use the "ESC" key.

Once a valid trigger is detected, the corresponding info is show for 2 seconds in the tool tip. And the hotkey string for the trigger is placed in the clipboard for further usage.

#### Tab *Launchpad*

On the launchpad, you can define a list of type "Other" applications, that can be launched by a push of a button on your controller. The "Launch" mode, which belongs to the "System" plugin, will use this list to occupy as many buttons on your controller, as has been defined on the *Controller* tab.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%205.JPG)

In the first field, you define the push button function for the given application on one of your hardware controllers. You also need to specify a small label text to display on the visual representation of your controller and you need to choose the application, which will be launched, when the corresponding button is pressed.

#### Tab *Chat*

Many simulation games provide an ingame multiplayer text based chat system. Since it is very difficult and also dangerous to a certain extent to type while driving or flying, you can configure predefined chat messages on this tab. These may be used by several plugins for specific simulators, to help you to send a kudos to your oppenents or even insult or offend them. Chat messages will typically be used in a mode of a specific plugin for a simulation game. See the [ACC Plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc) for an example.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%206.JPG)

In the first field, you define the push button function for the given chat message on one of your hardware controllers. You also need to specify a small label text to display on the visual representation of your controller and you specifiy the long chat message, which will be send to the ingame chat system, when the corresponding button is pressed.

#### Tab *Driving Coach*

The [AI Driving Coach](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach) can be configured on this tab.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%2012.JPG)

Several providers are supported: For "OpenAI" you have to register an [API account](https://openai.com) at OpenAI (it will need a little payment, but $5 will be enough for months of usage, believe me). "Azure" will provide many models of OpenAI as well, but is normally not available to private persons. Almost similar is the provider for "Mistral AI", which uses the same HTTPS-based API connection. In any case, you **must** supply an API key for the service, otherwise the Coach will tell you all the time, that it is currently busy.

For "GPT4All", no authentification is required, but you must enable the local API server in the settings. Please follow the instructions [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#installation) to register with the different GPT providers and get access to your secret API key.

Last, but not least, you can also use a local "LLM Runtime", which executes the LLM on your local PC. In this case, you have to supply a file path pointing to the model file in *GGUF* format.

Please note, that "Ollama", "GPT4All" and "LLM Runtime" require a very powerful system and will also use a lot of resources on your GPU. So this will be no option in most cases (at least for the time being), especially when running it side by side to a running simulator.

It is very important to choose the right LLM (aka large language model) for your coach. For "OpenAI", I recommend using "GPT 4.1 mini". It is cheap (a typical conversation lasting around 30 minutes will cost not more than 2 cents), and it has very extensive knowledge about racing. Future extensions to the Driving Coach, especially telemetry data integration, might utilize the extended capabilities of "GPT 4", though. "GPT4All" provide a variety of different models from different sources. Therefore you will have to conduct some experiments, which model works best for you.

You **should** supply the different [instructions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#instructions) for the chatbot, so that it knows as much as possible about its duties. Especially the "Character" instructions is important, so that the chatbot *knows* how to behave as a driving coach. Defaults will be provided here for all supported languages. Other instructions like "Simulation" or "Stint" may be used depending on the current context and the situation at the time of your conversation. You can edit the instructions to your preferences - tell the Assistant how it should behave, how the answers should be structured and so on. You can even delete a whole instruction, if you don't want to talk about the corresponding topic, like car handling, for example. This will save some input for the model and in the end a couple of cents.

Creating these instructions is an art by itself and there are vasts amount of information on the web, when you search for "GPT prompt engineering". Please note, that if you ever want to return to the default, or if you have switched the language for the Driving Coach, you can revert to the default instruction by clicking on the small button with "Reload" icon (hold down the Control key, if you want to reload all instruction categories at once).

A very important setting is the Conversation Memory. You can specify, how many recent conversations will be memorized, so that you can refer to topics mentioned in previous conversations. Please not, that a larger memory will make your conversations with Aiden more natural, but it will take a little bit longer to generate an answer and, depending on the provider, it may cost a little bit more.

You can also specify how long the answers of the Driving Coach can get ("# Tokens" - as a rule of thumb divide this number by 4 and you will get the maximum number of words in English), and you can also specify, how *creative* the answers will be.

The "Confirmation" choice allows you to specify, whether the Assistant will give you a short notice, when it has recognized a question or a command before the actual answer is computed. This can be very helpful in cases, where the underlying model or the GPT service provider is very slow, so that you know, that you have been understood.

The Driving Coach will use the language specified general voice control settings. It is very important, that the voice recognition is as perfect as it can be, I recommend using the "Azure" voice recognition service. If you want to use the "Desktop" recognition engine, which is quite good, when used with a headset, use the training methods of Windows, until your speech is recognized correctly. You can also enable the "Debug Recognitions" option for the "Voice Server", so that it gives you visually feedback for each recognition.

The conversations you have with your coach, will be transcribed to text files. You can supply a special folder, where these transcriptions will be saved, in the first field. If you leave this field empty, the transcriptions will be saved temporarily in the *Simulator Controller\Temp\Conversations* folder which is located in the user *Documents* folder.

#### Tab *Race Engineer*

With the settings on this tab, the dynamic behaviour of the [AI Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer) and its integration with the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) can be customized. All options can be chosen independently for each configured simulation game.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%208.JPG)

Choose the simulator with the topmost dropdown menu, before you change one of the settings beneath. In the first two groups, you can choose how the [settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#race-settings) for a new session and how the cold tyre pressures reference values will be initialized, and whether the settings and the updated cold tyre pressures will be saved by the end of the session. If you choose to save the settings, selected information from your session (for example the fuel capacity, the best lap time and the average fuel consumption) will be used to update the session settings maintained by the *Race Settings* tool, either at the default location in the *Simulator Controller\Config* folder in you user *Documents* folder or in the corresponding settings information in the session database (depending on the origin of the settings as configured in the first group). If the settings had been loaded from the session database at the start of the session, these settings will be associated with the current simulator / car / track / weather combination, so that they will only be used in a similar situation.

When initializing the settings for a session, you have two methods. The simple one "Load from previous session" uses all values as entered lately in the ["Race Settings" application](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#tab-session). But since this is a time consuming and partly recurring task, you can store a lot of default values in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database), which are used to initialize the settings when the second method "Load from Database" is selected. All values not found there will be loaded with the "Load from previous session" method as a fallback.

Please see the following table for an explanation of the different methods for initializing tyre pressures:

| Method                 | Description |
| ---------------------- | ----------- |
| Load from Settings     | The initial cold tyre pressures are taken from the value currently entered in "Race Settings" (depending on the mounted tyre compound) |
| Load from Database     | The pressures will be looked up in the tyre pressure database by using the current weather and temeperature conditions. Please note, that this does NOT change anything in the pressures really chosen in the car setup. |
| Import from Simulator  | This method is supported for *Assetto Corsa Competizione*, *rFactor 2*, *Le Mans Ultimate* and *iRacing*. For *Assetto Corsa Competizione* you must have selected "Use current pressures" for the active strategy in the "Fuel & Strategy" tab for this to work correctly. |
| Use initial pressures  | This one takes the initial pressures which the tyres have in the moment, when data is acquired for the first time from the simulator at the start of the session. They can be a little bit off, though, when the car had sit for some time and the tyres lost temperature. |

The third group allows you to customize some parts of the statistical algorithms of Jona, the AI Race Engineer. The first field defines the number of laps, Jona uses to populate its data collection. During this period, most of the functions of Jona are not available, but the predictions of dynamic values, like cold tyre pressures, will be much more precise afterwards. The second field, *Statistical Window*, is also quite important. It defines the number of recent laps, which are used for each and every statistical calculation, for example the standard deviation of tyre pressures. If you set this to **0**, almost all statistical calculations will fail, what e.g. means that tyre pressures will not be adjusted during a pitstop. The next field, *Damping Factor*, can be used to influence the calculation weight for each of those recent laps. If you want all laps to be considered with equal weight, set this to *0*, whereas a value o *0.2* will weigh each lap with *20%* less than the more recent lap before. *Adjust Lap Time* will inform Jona to use the lap time from the *Race Settings* for special laps like the first one or the lap after a pitstop and the last field *Damage Analysis* defines the number of laps, Jona oberves your lap times after you collected some damage.

Good to know: The little button on the right side of the Simulator dropdown menu lets you replicate the current settings for the chosen simulator to all other simulators. But be aware, that not all simulators might supprt all settings combinations, for example, loading of tyre pressures from the simulation is only supported by *Assetto Corsa Competizione*, *rFactor 2* and *Le Mans Ultimate*.

#### Tab *Race Strategist*

Similar as with the tab for the *Race Engineer*, the dynamic behaviour of the [AI Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Strategist) can be customized here. All options can be chosen independently for each configured simulation game.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%209.JPG)

In the first field, you can select a folder, where the *Race Strategist* will save the race data for after race analysis using the ["Race Reports"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Race-Reports) tool. Whether a report for a specific race will be saved, can be selected with "Save Race Report" setting further down below, which is specific for a given simulator. Choose this simulator with the "Simulator" dropdown menu, before you change one of the settings beneath. Then you can customize some parts of the statistical algorithms of Cato, the AI Race Strategist. The first field defines the number of laps, Cato uses to populate its data collection. During this period, most of the functions of Cato are not available, but the predictions of dynamic values will be much more precise afterwards. The second field, *Statistical Window*, is also quite important. It defines the number of recent laps, which are used for each and every statistical calculation, for example the standard deviation of lap times. If you set this to **0**, almost all statistical calculations will fail, what e.g. means that over- or undercut scenarios cannot be evaluated. The next field, *Damping Factor*, can be used to influence the calculation weight for each of those recent laps. If you want all laps to be considered with equal weight, set this to *0*, whereas a value o *0.2* will weigh each lap with *20%* less than the more recent lap before.
With the "Save Telemetry" setting you specify, whether the telemetry data of the last session will be saved for further analysis in the "Strategy Workbench" tool. Although possible, I do not recommend to use “Ask” here, since it might interfere with a similar question by the Race Engineer to save your tyre pressures. Last, but not least, the "Race Review" drop down allows you to enable or disable a spoken review issued by the Race Strategist, when you have finished your race.

Note: The settings for loading and saving the *Race Settings* specified on *Race Engineer* tab apply for the AI Race Strategist as well, as long as no other Assistants are active.

Good to know: The little button on the right side of the Simulator dropdown menu lets you replicate the current settings for the chosen simulator to all other simulators.

#### Tab *Race Spotter*

Similar as with the tab for the *Race Engineer* and for the *Race Strategist*, the dynamic behaviour of the [AI Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter) can be customized here. All options can be chosen independently for each configured simulation game.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%2011.JPG)

You can customize some parts of the statistical algorithms of Elisa, the AI Race Spotter, in the first group of fields. The first field defines the number of laps, Elisa uses to populate its data collection. During this period, most of the higher functions of Elisa are not available (an exception are the proximity alerts for nearby cars in dense traffic, this functionality is available rightaway from the start of the engines), but the predictions of dynamic values will be much more precise afterwards. The second field, *Statistical Window*, is also quite important. It defines the number of recent laps, which are used for each and every statistical calculation, for example the standard deviation of lap times. If you set this to **0**, almost all statistical calculations will fail, what e.g. means that traffic based tactical recommendations will not be available. The next field, *Damping Factor*, can be used to influence the calculation weight for each of those recent laps. If you want all laps to be considered with equal weight, set this to *0*, whereas a value o *0.2* will weigh each lap with *20%* less than the more recent lap before.

Note: The settings for loading and saving the *Race Settings* specified on *Race Engineer* tab apply for the AI Race Spotter as well, as long as no other Assistants are active.

Below you will find the groups *Alerts* and *Information & Advices*. There you can enable or disable the individual warnings, messages and announcements of Elisa for the driver. If you don't like, for example, the alerts of Elisa that another car is directly behind you, you can simply switch it off. Most callouts can only be enabled or disabled, but for the periodic distance information regarding your direct opponents you can set the number of laps between each update as well. You can even choose an update each sector, if you want the Spotter to be really verbose. For more information about the individual announcements and alerts, please see the [Spotter documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter#alerts--information). Beside that, you can set a minimum time, Elisa waits before contacting you again with the next information or advice.

Good to know: The little button on the right side of the Simulator dropdown menu lets you replicate the current settings for the chosen simulator to all other simulators.

#### Going deeper into the rabbit hole

After creating the general configuration using "Simulator Setup" or "Simulator Configuration", Simulator Controller will be already ready to race. But there are many more settings to customize the behaviour of Simulator Controller available in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database). These settings can be created for specific combinations of a simulator and a car and even track, thereby giving you great flexibility for the best possible experience. But there is a downside, you have to learn all these settings. Don't worry, all settings have a reasonable default, so you can start right away. Here is the documentation about all [available settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Settings).

#### Special configuration options for optimizing overall performance

The underlying runtime environment of the Simulator Controller applications provide a couple of configuration settings which can be used to optimize everything for the performance of the used PC. You can find specific documentation for this in this [special overview](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Configuration), but be cautious when changing any of the settings.

### Splash Screen Editor

This special editor, which can be opened from the *General* tab of the configuration tool, allows you to define a combination of pictures or animation files together with a sound file. This can be used to display a splash screen during the startup sequence. You may have a Rallye splash screen for your favorite Rallye session, or an F1 splash screen, or even some cinematic impressions from various airplanes in the sky, while waiting for your flight simulator to startup.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Themes%20Editor.JPG)

Currently, two different types of splash screens are supported. The first uses a collection of pictures for a kind of round robin display. The second type let you choose a GIF file for a video like animation. Both support the additional selection of a sound file to play along, while the pictures or the animation will be shown. Despite that, you can overwrite the default title and subtitle of the splash screen window.

Some words about using the editor:
  - You can prelisten the currently selected sound file by pressing the start button next to the entry field. It will keep playing until you press this button again, even if another splash screen had been selected in the meantime.
  - You can add any picture to the pictures list by pressing the "+" button left to it. The new picture will be added at the end of the list. However, if you save your changes, only those pictures will be stored for the splash screen, that have a checked checkmark in their list entry.
  - Every JPG and GIF file added to a splash screen must be of a precise 16:9 format, otherwise you will get distortion artefacts.
  - Due to a restriction in AutoHotkey, only the GIF format is currently supported for animations. A future version of Simulator Controller will support YT videos, MP4 files and other as well. For now you can convert your favorite MP4 file to a GIF image by using one of the available online converters, for example [Convertio](https://convertio.co/de/mp4-gif/) .

After definition of a splash screen, you can choose it for the [startup sequence](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#other-settings) or even while the build tool is currently compiling your favorite plugin, if you are a developer.

### Translations Editor
Another special editor is used for maintaining different language translations for the user interface. In the translation process, you can provide a language specific translated text for each user interface element or other texts used by the Simulator Controller. English is the original language, on which the translation is based upon. A translation must be identified by its [ISO language code](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes), for example "EN", and also has a user understandable language identfier, for example "English". The translation information is stored by the *Translations Editor* in the *Simulator Controller\Translations* folder in your user *Documents* folder in a file named "Translations.LC", where LC is the given ISO language code.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Translations%20Editor.JPG)

With the dropdown menu at the top of the window you can choose any of the available languages and edit the defined translations, or you create a new language by pressing the '+' button next to the language drop down. You can delete a given language and all its translations, but be aware, that this cannot be undone. For your convenience, the small down array on the left side of the translation field will select the next text waiting for translation.

The translations editor is useful to supplay alternative texts for a given text in an already available translation according to your personal taste. For a full localization and translation guide, see teh separate [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#localization-and-translation).

Note: The original text sometimes has leading and/or trailing spaces. Be sure to include them in the translated text as well, since they are important for formatting.

Important: The ISO language code and the language name itself cannot be changed, once a new language has been initially saved. So choose them wisely. And last but not least be careful, if you ever want to edit the translation files directly using a text editor. This editor must be able to handle multibyte files, since the tranlation files are stored in an UTF-16 format.

## Controller Layouts

Simulator Controller allows you to use any type of USB controller (normally Button Boxes or the controls on your steering wheel) to control the vast functionality of the different plugins. In addition to standard USB controller, Simulator Controller also provides a special plugin for the famous Stream Deck controller. The layout (type and number of controls, arrangement of controls, etc.) for all type of controller are described using special configuration files, which are documented below. But no worry, you will normally use a graphical tool, the Controller Layout Editor, to create and edit those configuration files.

### Button Box Layouts

Below you find a sample definition for the Button Box configuration file: file.

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

You can define as many Button Box layouts as you want, but only those Boxes will be activated by Simulator Controller, that also have been added to the list of configured controller at the top of the [*Controller* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller). This also applys to any other type of controller layouts.

In the given configuration file, you first have to define the different *Control* types, you want to use on your Button Box layouts. In the example above, three different *Control* types are defined, each one consisting of the name of the corresponding class, the image for the visual representation and the size information for this image. Supported classes are "1WayToggle", "2WayToggle", "Button" and "Dial", which corresponds with the controller functions used on the [*Controller* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller). The given name of the *Control* type definition will then be used in the configuration of the concrete layouts in the *[Layouts]* section.

You may define different *Label* types, if you want to use label fields of different sizes for your controls. The example above only introduces one label with a fixed size for all controls.

In the last section, the layouts of one or more Button Boxes are described using these components. For each Button Box you have to define the layout grid with *.Layout*" descriptor. The grid argument ("R x C", where "R" define the number of rows and "C" the number of columns) is required, the other optional parts as in "Controller 2.Layout=3 x 4, 20, 60, 20, 15" are the *Row Margin*, *Column Margin*, *Sides Margin* and *Bottom Margin* with 20, 40, 20 and 15 as default. After defining the layout, you enumerate the controls of each row seperately. It is possible to leave positions in the grid blank, when not every corresponding position on your Button Box is occupied with a control, and it is also possible to create a control without a label field. The number of each control (as in "Push.17" must correspond with the number of the corresponding controller function defined on the [*Controller* tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-controller). Last, but not least, is it possible to declare a Button Box to be invisible, so that its graphical representation will not be shown on the screen.

After we now have an understanding of the Button Box layout definition format, let's have a look at the graphical editor, which handles this configuration file. As always, the file will be stored in the *Simulator Controller\Config* folder which resides in your user *Documents* folder.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%20Editor%201.JPG)

As you can see, the structure of this editor is very similar to the structure of the configuration file above. You first have to enter your controls and labels in the first two sections of the editor and then you can define the Button Box layouts (be sure to select "Button Box" in the layout type drop down menu). If you select an existing layout definition or when you save a newly created definition, a preview window of this Button Box layout will be opened in the lower right corner of your screen.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Button%20Box%20Editor%202.JPG)

This window will visualize the current layout and will change, whenever you change one of the definitions in the layout editor. Please note, that you have to save the definition changes using the *Save* buttons to update the preview window, as long as you do not have chosen the [*Automatic* save mode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#using-the-configuration-tool). As you can see in the image above, freshly added rows and columns will show a free "Space", which you can fill up with *Controls*. Please note, that the "Space" marker will only be shown in the preview mode, so intentionally free space will look good on the final Button Box. You con click on each cell of the preview window and change the *Control* and the *Label*, which should occupy this cell, and you can choose the corresponding controller function number for the given control. If you hold the Control key down when clicking on a control, the input dialog for entering the control number will open directly.

With the button "Edit Labels & Icons..." you can open the special editor which is also available on the ["Plugins" tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) and which allows you to configure the language specific labels and icons for all controller actions. See the chapter ["Action Labels & Icons"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#action-labels--icons) below for more information.

### Stream Deck Layouts

The configuration file for Stream Deck controller is to some extent similar to that for Button Boxes. Below you find a sample definition as a reference:

	[Layouts]
	Stream Deck.Layout=3 x 5
	Stream Deck.1=Button.1;Button.2;Button.3;Button.4;Button.5
	Stream Deck.2=Button.6;Button.7;Button.8;Button.9;Button.10
	Stream Deck.3=;;;;
	Stream Deck Mini.Layout=2 x 3
	Stream Deck Mini.1=Button.11;;
	Stream Deck Mini.2=;;
	[Icons]
	*.Icon.Mode.1=D:\Controller\Resources\Icons\Clutch.ico;IconAndLabel
	Stream Deck.Icon.Mode.1=D:\Controller\Resources\Icons\Throttle.ico;Icon
	Stream Deck.Icon.Mode.2=D:\Controller\Resources\Icons\Brake.ico;Icon
	Stream Deck.Icon.Mode.3=D:\Controller\Resources\Icons\Clutch.ico;Icon
	[Buttons]
	Stream Deck.Button.1.Icon=true
	Stream Deck.Button.1.Label=true
	Stream Deck.Button.1.Mode=IconOrLabel
	Stream Deck.Button.2.Icon=true
	Stream Deck.Button.2.Label=true
	Stream Deck.Button.2.Mode=IconOrLabel
	Stream Deck.Button.3.Icon=true
	Stream Deck.Button.3.Label=true
	Stream Deck.Button.3.Mode=IconOrLabel
	Stream Deck.Button.2.Mode.Icon.1=D:\Controller\Resources\Icons\Gear.ico;IconAndLabel
	Stream Deck.Button.2.Mode.Icon.2=D:\Controller\Resources\Icons\Flash.ico;IconAndLabel
	Stream Deck.Button.3.Mode.Icon.1=D:\Controller\Resources\Icons\Gear.ico;IconAndLabel
	...
	Stream Deck Mini.Button.11.Icon=D:\Controller\Resources\Icons\Gear,ico
	Stream Deck Mini.Button.11.Label=Select\nMode
	Stream Deck Mini.Button.11.Mode=IconAndLabel

To connect your Stream Deck(s) with Simulator Controller, you must install the special Stream Deck plugin, which is supplied in the *Utilities\Plugins* folder, which is located in the installation directory of Simulator Controller. Copy the complete folder *de.thebigo.simulatorcontroller.sdplugin* to *%appdata%\Elgato\StreamDeck\Plugins* and restart the Stream Deck software.

Important: If you have used the quick setup method of "Simulator Setup", the plugin might already have been installed.

After you have installed and activated the plugin, create a profile using the special action *Controller Function* supplied by this Stream Deck plugin. It is important that you leave the title of the action blank and set the *Function* to the desired controller function, for example "Buttton.1".

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Stream%20Deck%20Action.JPG)

Please note, that you don't have to place all controller actions on one page, although the above example looks like this. You can even distribute them over several profiles and you may have more then one instance for "Button.3" as well. Therefore, you have total freedom to organize your layout, at least when you directly edit the configuration file. Creating a configuration using the editor is a little bit more restricted for good reason, as we will see. Please be aware, that the Stream Deck Actions automatically adopts to the currently active controller actions, so conventional switching of profiles on the Stream Deck is not necessary as with usual Stream Deck profiles.

Hint: Do you want to automatically switch to the created profile, when Simulator Controller starts up? Easy to achieve, if you start "Simulator Startup" from the Stream Deck itself. Simply use a multi action and switch to the profile just before start "Simulator Startup".

Good to know: You can find a preconfigured Stream Deck profile with 2 pages in the *Profiles* folder in the installation directory of Simulator Controller.

After you have setup your Stream Deck profile(s) you have to create "Stream Deck Configuration.ini" file similar to the example above and save it to the *Simulator Controller\Config* folder in your user *Documents* folder. In the "Layouts" section you describe the layout for one or more profiles on one or more connected Stream Deck. The *...Grid* property is simply ignored during runtime, but will be used by the editor to select between a graphical Mini, Standard oder XL layout. Please note, that only "Button.X" function descriptors may be used and that you can leave positions blank.

Then you describe each button in the profile in the "Buttons" section. A default icon can be configured to be shown on the Stream Deck and whether textual labels should be shown on the Stream Deck buttons as well. The value for the optional *[layout].Button.X.Label* property may be *false* (no label at all), true (default; use the action label from the [labels defined in the plugin configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins)) or you can supply a fixed text here (you can use "\n" to start a new line in the text value). To supply an icon using the optional *[layout].Button.X.Icon*, use a full path to an image file supported by Stream Deck. Here you can also use *false* to specify that you never want to show an icon on the Stream Deck for this button, or *true* (which is the default), if the [icon from plugin configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) should by used for the associated controller action, if one is available.

With the *...Mode* property you can define for a button, which layers should be displayed on the Stream Deck. *IconOrLabel*, which is the default, means that the icon is displayed without a label, if an icon is available, otherwise the label will be displayed. Other values for this property are *Icon* (only an icon or nothing is displayed), *Label* (only a label or nothing is displayed), or *IconAndLabel*, which means, that both an icon and a label will be displayed. As you can see in the example above, you can declare exceptions from the default *Mode* for specific icons using the *...Mode.Icon.XX* property, if necessary. Using this exception rule, you specify the *Mode* per icon and button seperately, which can get quite excessive, but it will give you very nice results on the Stream Deck. As you can also see in the example, you can also declare a mode for an icon independent of a specific button in the "Icons" section , but a button specific declaration always takes precedence. You can also use a "*" here for the layout name. This defines a rule with the lowest priority, which, however, applies to every layout.

Example: In the above example, all "Stream Deck" Actions will use the icons for the currently associated controller action as defined in the "Controller Action Icons.XX" file. Please note, that you can omit the declaration "...Label=true", since this is the default. If an icon is available, the label will not be shown (except for Button.2, where an exception rule exists for the "Gear" and "Flash" icon). Only the first two rows of the Stream Deck are used here for controller actions, whereas in the "Stream Deck Mini" only the first button in the top row is configured with a fixed icon and label.

To activate your Stream Deck configuration, you then must open "Simulator Configuration" and create a new entry in the upper list of the "Controller" tab and associate this new controller with one of the Stream Deck layouts. Done...

Let's now take a look at the graphical editor. Using the same editor introduced for Button Box Layouts above, you can create a layout entry in the "Layouts" list and select "Stream Deck" in the layout type drop down menu. The layout section of the Controller Layout Editor now should look like this:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Stream%20Deck%20Editor%201.JPG)

As you can see, this is comparable to but more simple than the layout section for Button Boxes, since the layout on a Stream Deck is fixed for obvious reasons. You simply have to select the Stream Deck layout (one of "Mini", "Standard" and "XL" corresponding to a 2 x 3, 3 x 5 or 4 x 8 button grid). After you have saved the layout a graphical representation of this type of Stream Deck appears, where you can configure the buttons.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Stream%20Deck%20Editor%202.JPG)

Using the context menu for each button, you can specify almost any of the options described above, except the button specific icon exception rules.

#### Display Rules

As you have seen before, you can define in the layout editor for every button whether a label and an icon, or only the icon or only the label should be displayed. But these settings might depend on the specific icon, which is currently displayed. One icon might look good together with a label text, the other might not. Especially, when you use controller action specific icons, you might want to have more control here. This is where icon specific exception rules come into the game. The layout or generic icon specific exception rules may be edited using the following window, which opens, when you click on the "Edit Display Rules..." button.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Stream%20Deck%20Editor%203.JPG)

You can select with the drop down menu in the upper area, whether the exceptions apply to the currently edited Stream Deck layout from the "Layouts" list or whether they might apply to all Stream Deck layouts.

Please note, that the order of rules applied goes from the most specific rules for 1. button and layout specific exceptions for a given icon, over 2. layout, but not button specific exceptions for a given icon to 3. layout unspecific exceptions for a given icon. Sorry for that complexity, probably you will never use this stuff, but it's good that it's there, if you may ever need it.

### Action Labels & Icons

As mentioned above, you can associate a label and an image for each and every different controller action to display on your controller (labels for the Button Box visual representations or labels and icons on the Stream Deck), as long as this action is associated with the corresponding controller function. These labels and icons will therefore only be visible during runtime and not during the configuration process, and be also aware that there might be additional, dynamically computed texts by a given plugin, for example the current strength of a vibration effect, which cannot be modified here.

Labels are stored in a language specific configuration file named "Controller Action Labels.XX" and icon references are stored in a file named "Controller Action Icons.XX" (with *XX* replaced by the language code, for example "EN"). This file must be placed in *Simulator Controller\Translations* folder in your user *Documents* folder and has the following formats:

1. Controller Action Labels.XX

	[Tactile Feedback]  
	TC.Dial=TC  
	TC.Increase=Increase\nTC  
	TC.Decrease=Decrease\nTC  
	ABS.Dial=ABS  
	ABS.Increase=Increase\nABS  
	ABS.Decrease=Decrease\nABS  
	...

Please note, that you can start new lines in the label using **\n**.

2. Controller Action Icons.XX

	[Tactile Feedback]  
	TC.Increase=D:\Dateien\Bilder\Simulator Icons\ButtonDeck\TC+.jpg  
	TC.Decrease=D:\Dateien\Bilder\Simulator Icons\ButtonDeck\TC-.jpg  
	ABS.Increase=D:\Dateien\Bilder\Simulator Icons\ButtonDeck\ABS_+.jpg  
	ABS.Decrease=D:\Dateien\Bilder\Simulator Icons\ButtonDeck\ABS_-.jpg  
	...

In this example, four icons will be displayed on the Stream Deck for increasing and decreasing the pedal vibration for traction control and ABS effects. You can to edit the definition file in the ["Plugins" tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the "Simulator Configuration" tool, as mentioned above. You can find a set of icons for many actions of Simulator Controller in the *Resources\Stream Deck Images\Icons* folder in the programm directory, which can also be installed as a preset using "Simulator Setup". If you don't like these icons, there are a lot of other icons available out there for the Stream Deck, for example [this one](https://www.racedepartment.com/downloads/buttondeck-for-stream-deck.24348/) or the icons from the collection of iEnki in the **#share-your-mods** channel on our [Discord](https://discord.gg/5N8JrNr48H).

As you expect, there is a graphical tool to edit this language specific configuration files:

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Action%20Labels%20Icons%20Editor.jpg)

Simulator Controller comes with preconfigured labels for all supported languages, but you may have to create your own icon definitions.

Note: This editor can be opened from the ["Plugins" tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-plugins) of the configuration tool.