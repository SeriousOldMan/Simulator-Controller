## 1.5.x-release upcoming...

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. The ACC Plugin has been greatly extended to support complete hands-free control over all the pitstop settings. New controller actions can be connected to an external event source like VoiceMarco to control the pitstop settings by voice. What the driving instructor always said - keep your hands on the steering wheel.

## 1.4.4-release, 01/01/21

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Unicode based translation support. German translation will be bundled - other languages can be easily added
     - including a graphical tool for translation editing
  4. Updated photorealistic elements for Button Box
  5. All settings dialogs may be moved around by clicking in the main title
  6. All current effect settings will be displayed alternately with effect name in Button Box visual representation
     - Only available for the Motion Feedback plugin. Unfortunately, this is currently not possible for Tactile Feedback, since SimHub does not provide an interface for querying the current effect settings at this time
  7. A new option is available in the configuration dialog, which allows the Button Box window to be centered on a secondary screen. Helpful, when opening the visual representation on a small display located next to the button box
  8. Several Refactorings and Renames
     - Renamed "Simulator Configuration" => "Simulator Settings"
     - Renamed "Simulator Setup" => "Simulator Configuration"
	 - Several name changes in the source code to adopt to this new name scheme (Configuration => Settings, Setup => Configuration)

## 1.3.3-stable, 12/27/20

  1. Bugfixes, as always
  2. Documentation updates, as always
     - including a new Wiki page with the hottest backlog features
  3. New photorealistic Button Box Visuals - you will love it
  4. You can now interact with the visual representation of the Button Box using the mouse and everything is functional, even if you don't have a hardware controller. So you can put your old button boxes on eBay - not.
  5. Button Box will be moveable by the mouse and the position might be saved according to configuration.
  6. Better window handling of SimFeedback. The main window will stay closed whenever possible.
  7. Introduced *shutdownSystem* controller action.
  8. Debug mode now defaults to *true* in non compiled scripts.

## 1.2.4-stable, 12/23/20

  1. Bugfixes, as always
  2. Documentation updates, as always
  3. Complete rewrite of sound volume handling (should resolve issue #1)
  4. Themes Editor: A collection of media files (pictures, animation, sounds) can be grouped together using the themes editor, a part of the setup tool. In the startup configuration, you can enable this group for splash screen and startup animation as a whole. With this functionality, you can have a GT3 look and feel, a Rallye look and feel, an F1 look and feel, and so on. For an introduction to themes, please take a look at the [documentation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#themes-editor).

     Important: You either need to use the themes editor of the [configuration tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#configuration) to configure your own splash themes or you need to copy the "[Splash Themes]" and "[Splash Window]" sections from 
*Resources\Templates\Simulator Configuration.ini* to your local configuration file found in *Simulator Controller\Config* in your user *Documents* folder. Also, be sure to update the runtime configuration of *Simulator Startup.exe* and *Simulator Tools.exe* by holding the Control key down while starting these applications.
  5. Added a special startup handler for Tactile Feedback (SimHub).
  
     Important: If you already defined your own configuration using the setup tool, please set "startSimHub" as the special startup handler for the "Tactile Feedback" application in the [Applications tab](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-applications) of the setup tool.

## 1.1.0-stable, 12/19/20

  1. Documentation updates
  2. Several bugfixes
  3. Renamed *Documentation* folder to *Docs* folder.
  4. Introduction of the *Simulator Controller* folder located in the *Documents* folder of the current user. This folder might contain local media files und plugin extensions, as well as log files and configuration files. See the [Installation & Setup](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#using-your-own-pictures-videos-and-sounds-for-all-the-splash-screens) guide for more information.
  6. Created a *Templates* folder in the *Resources* folder for all the files, that will populate the *Simulator Controller* folder in the users *Documentation* folder.
  7. Several refactorings to support the new customization features.

## 1.0.8-beta, 12/18/20

  1. Second preview and possibly release candidate for the upcoming feature release 1.1.0...

## 1.0.5-beta, 12/17/20

  1. First preview and test release for the upcoming feature release 1.1.0...

## 1.0.2-fix, 12/17/20

  1. Critical bugfix for Motion Feedback Plugin
  2. Small fixes for performance issues

## 1.0.0-stable, 12/15/20

Initial release
