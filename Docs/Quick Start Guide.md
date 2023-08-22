You probably already have understood, that Simulator Controller is a quite sophisticated software with tons of configuration options. On the other hand, and especially as a new user, you want to get up and running as quickly as possible. This quick start guide will help you to get a fairly simple initial configuration as quickly as possible. This configuration will support the installed simulators and will activate at least one Race Assistant together with voice control. No configuration support is given for your Button Boxes and Stream Decks, but you can add them anytime later. Please follow the steps below, but also read the disclaimer at the end of the list to fully understand, what you *get for your money* and what not.

1. Start "Simulator Setup"

   At the end of the initial installation of Simulator Controller using the automated installer, the configuration wizard "Simmulator Setup" is run automatically, unless you uncheck this option in the installer. This wizard will guide you through the configuration and will offer you configuration options for even the most sophisticated environments. We will disable almost all this stuff for an initial and simple configuration. You can always visit "Simulator Setup" again to enable additional functionality later on.
   
   There are two ways to get to a basic working setup with a few clicks. "Simulator Setup" offers a basic setup page, which does all the work for you, but you do not have any control where all the software components are installed. This is in general no problem, since the software components will be installed in the typical locations used by the Windows operating system.
   
   If you want to use the basic setup select the "Basic" option when asked by "Simulator Setup" and continue. On the next page, you can take all decisions for your initial setup. Then use this configuration for your initial experiences with Simulator Controller. When you feel comfortable, you can come back to "Simulator Setup" and complete your configuration.
   
   ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Quick%20Start%204.JPG)
   
   If you don't want to use the basic configuration page, simply select "Custom" and continue to the next page. Then go through the following steps for a basic configuration.

2. Select modules

   Move forward in "Simulator Setup" a few pages until you come to the selection of modules. Modules are components of Simulator Controller which provide a set of unctionality and we want to start with a very restricted set here. Deselect all modules except "Voice Control" and "Race Spotter" here.
   
   ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Quick%20Start%201.JPG)

3. Install additional software

   After the module selection move foward again (skip the Presets page) up to the pages where additional software can be installed.
   
   ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Quick%20Start%202.JPG)
   
   Here we have to install:
   
   - Runtimes from Microsoft - Most likely already installed on your computer, but it does not harm to run those installer again.
   
   - Plugins - Can be skipped for the moment, unless *Assetto Corsa* and / or *rFactor 2* are your only games. Then you have to install the "SimulatorController" plugin for *Assetto Corsa* and "rFactor2SharedMemoryMapPlugin64.dll" plugin for *rFactor 2*. Instructions can be found [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#installation-of-telemetry-providers).
   
   - SoX - Although optional, I strongly recommend installing SoX for an immersive soud experience.
   
   - NirCmd - Also optional, but strongly recommended as well. It is used to control sound volumes, when more than one assistant try to talk to you at the same time.
   
   - Speech Runtime and libraries - Runtime and at least the English library should be installed.
   
   Everything else can be skipped or postponed until a later configuration run.

4. Configure voice control

   Move forward to the page "General Configuration". On the way there, check that all your simulation games has been sucessfully detected on the page "Simulations". If this is not the case, which sometimes can happen due to a very unusual configuration of Steam library folders, please contact the *support* on our Discord.
   On the page "General Configuration" choose "Windows (.NET)" as a speech synthesizer method and "Windows (Desktop)" as the method for speech recognition. Then press the small button labeled with an "A" next to the "P2T" field (Push-To-Talk). Then press a button on your steering wheel, you want to use for the Push-To-Talk or Radio function. If this doesn't work at the moment or if you do not have a button you can spare, no issue. In the most simple configuration, we are currently creating, you won't talk to the assistants.
   
   ![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Quick%20Start%203.JPG)

5. Generate the configuration

   Now you can move to the final page of the setup wizard. There press the "Finish" button and create a configuration.

Done, you have created a first runnable configuration. Next step is to run "Simulator Startup". There you press the play button (the one with a green triangle). This starts all the background processes of Simulator Controller, which connect to the simulation. After that, you can start your favourite game and head out to the track where you will be greated by the Spotter during the formation lap.

## Disclaimer

This initial configuration covers only a fraction of the functionality of Simulator Controller. Only one of the Assistants, the Spotter will be active and all the other fancy stuff of Simulator Controller like support for Stream Decks and Button Boxes, Motion Rigs, and so on, is disabled as well. But this configuration will assure, that the low level parts of Simulator Controller are correctly configured for your environment and you can come back to "Simulator Setup" anytime to enable more functionality step by step later on. But before you do this, read the remainder of the [Installation & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration) documentation or watch the [video](https://youtu.be/1XFvWhg2cPw), which covers the full configuration process. Special case is the full configuration of voice control, which is also covered in a separate [video](https://youtu.be/u_2cIrZ1zFk) as well as getting the most out of your hardware controllers, for which also an additional [video guide](https://youtu.be/wPUnjViU15U) is available.