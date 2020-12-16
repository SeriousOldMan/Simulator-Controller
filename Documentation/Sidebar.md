[Overview](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Overview)
------

[Release Infos](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Infos)
------

[Installation & Setup](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup)
------
  - [Installation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#installation)
  - [Setup](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#setup)
    - [General](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-general)
    - [Plugins](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-plugins)
    - [Applications](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-applications)
    - [Controller](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-controller)
    - [Launchpad](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-launchpad)
    - [Chat](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Setup#tab-chat)

[Using Simulator Controller](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller)
------
  - [Startup Process & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-process--configuration)
  - [Using Simulator Controller](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#using-simulator-controller)

[Plugins & Modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes)
------
  - [System](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-system)
    - [Launch](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-launch)
  - [Tactile Feedback](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-tactile-feedback)
    - [Pedal Vibration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-pedal-vibration)
    - [Chassis Vibration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-chassis-vibration)
  - [Motion Feedback](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-motion-feedback)
    - [Motion](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#mode-motion)
  - [ACC - Assetto Corsa Competizione](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-acc)
    - Drive
  - [AC - Assetto Corsa](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes#plugin-ac)


[Development Guide](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts)
------
  - [Overview & Concepts](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts)
    - [Overview](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#overview)
    - [Code Example](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#example)
    - [Debugging](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#debugging)
    - [Using the Build Tool](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts#using-the-build-tool)
  - [Constants Reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Constants-Reference)
  - [Functions Reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Functions-Reference)
  - [Classes Reference](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference)
    - [Configuration Classes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#configuration-classes)
      - [ConfigurationItem](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-configurationitem-classesahk)
      - [Application](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#application-extends-configurationitem-classesahk)
      - [Function](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-function-extends-configurationitem-classesahk)
      - [2WayToggleFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#2waytogglefunction-extends-controllerfunction-classesahk)
      - [1WayToggleFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#1waytogglefunction-extends-controllerfunction-classesahk)
      - [ButtonFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#buttonfunction-extends-controllerfunction-classesahk)
      - [DialFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#dialfunction-extends-controllerfunction-classesahk)
      - [CustomFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#customfunction-extends-controllerfunction-classesahk)
      - [Plugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#plugin-extends-configurationitem-classesahk)
    - [Controller Classes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controller-classes)
      - [SimulatorController](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#singleton-simulatorcontroller-extends-configurationitem-simulator-controllerahk)
      - [ControllerFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-controllerfunction-simulator-controllerahk)
      - [Controller2WayToggleFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controller2waytogglefunction-extends-controllerfunction-simulator-controllerahk)
      - [Controller1WayToggleFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controller1waytogglefunction-extends-controllerfunction-simulator-controllerahk)
      - [ControllerButtonFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllerbuttonfunction-extends-controllerfunction-simulator-controllerahk)
      - [ControllerDialFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllerdialfunction-extends-controllerfunction-simulator-controllerahk)
      - [ControllerCustomFunction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllercustomfunction-extends-controllerfunction-simulator-controllerahk)
      - [ControllerPlugin](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllerplugin-extends-plugin-simulator-controllerahk)
      - [ControllerMode](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controllermode-simulator-controllerahk)
      - [ControllerAction](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#controlleraction-simulator-controllerahk)
      - [ButtonBox](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Classes-Reference#abstract-singleton-buttonbox-extends-configurationitem-simulator-controllerahk)
