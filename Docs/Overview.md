Welcome to the Simulator Controller documentation. Here you will find everything to understand, install, configure and use your complete solution for getting the best experience from your immersive simulation games. If you are looking for a quick start, you can download and install the software using the instructions found [here](https://github.com/SeriousOldMan/Simulator-Controller#download-and-installation). But because the Simulator Controller suite offers such a huge amount of functions and individual applications, I recommend to take at least a *look* at the different areas of the documenation, so that you have an overview of what to expect.

The documentation is devided into the following sections:

  - [README](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/README.md)
  
    Useful information about the Simulator Controller project and its functions & features. 

  - [Release Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Release-Notes)

    Here you will find information about the current or previous releases. Even infos for the next upcoming stable release are included. 
    Useful information about Simulator Controller project and its functions & features. 

  - [Update Notes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Update-Notes)

    Beginning with Version 2.0, Simulator Controller supports an update mechanism for your local configurations, which is mostly automated. Please read the information on this page carefully, if you update an already configured installation to a newer version, to be sure, that all the new features will be available in your configuration as well. Here you will also find information for additional manual installation or configuration activities, that might be necessary for new features introduced by a given release.
	
  - [Installation & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration)

    Maybe the most important part of the documentation, a complete description on how to install and configure Simulator Controller. The documentation is structured along different topics, which will give you complete control to adapt Simulator Controller to your equipment.
	
  - [Using Simulator Controller](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller)

    General information how to start and use the Simulator Controller and how to use the available runtime options.	You will also find information on how to use voice control and how to interact with the Race Assistants.
	
  - [Plugin & Modes](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Plugins-&-Modes)

    Reference information for all the builtin plugins and modes.
	
  - [Tyre Compounds](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Tyre-Compounds)

    Gives you detailed information, how to configure and manage all available tyre compounds for a specific car in a given simulator.

  - [Session Database](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database)
  
    All applications of Simulator Controller are data-based. If you are on the track, important data is collected and can be stored into the session database for future usage. Using the "Session Database" application, you can browse this data, share data with your team mates or even the community and you can manage car, track and weather-specific settings for the Race Assistants.
	
  - [Setup Workbench](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench)

    This smart tool gives valuable recommendations on how to change a car setup for a given problem. The tool follows an interview-like approach and can even handle contradictory requirements.

  - [Solo Center](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Solo-Center)
  
    This application helps you in organizing and evaluating your practice runs. You have full access to all relvant telemetry and performance data and you can decide which of the collected data will be stored in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) (see above). The "Solo Center" can also be used in a solo race and offer almost the same functionality as the team-oriented ["Team Center"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center) (see below).
	
  - [Strategy Workbench](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Strategy-Workbench)

    This sophisticated application allows you to develop and simulate strategies for any type of race, ranging from a 30 minute, solo sprint race with one required pitstop up to full-weekend endurance races with multiple drivers. The strategy simulation is data-based and can even handle weather forecasts. A developed strategy can be handed over to the [Virtuak Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist), which then will keep track of the strategy during the race.
	
  - [Team Center](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Center)
  
    Using the "Team Center", a complete pitwall application, you can plan the race, prepare a strategy and based on the strategy, the stint plan for the race. All team members or even a dedicated engineer can investigate the telemetry data and gather information about the race development in general. The car can be remotely controlled, for example to prepare an upcoming pitstop without any driver interaction. Last, but not least, if you encounter an unforeseen event during the race, you have various tools at hand to adopt the strategy to the new race situation. The "Team Center" requires all drivers to be connected to the ["Team Server"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server) (see below).
  
  - [Virtual Driving Coach](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach)

    This a very special chatbot, which behaves as your personal driving coach. Based on text-based GPT technology, it uses a publically available large language model which has been trained with vasts amount of information. Ask anything about racing, car handling and driving techniques and you will probably will get an interesting answer.
	
	Additonally, you can activate an active coaching mode based on your cars telemetry data. If this mode is active, the coach can give you corner by corner instructions while you are driving. And you can discuss potential improvements for the whole lap or specific corners after the session. Reference laps from yourself or any other source can be used by the coach to boost your personal driving skills.
	
  - [Virtual Race Engineer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer)

    You don't want to miss out Jona, the world first full voice dialog capable Virtual Race Engineer based on artificial intelligence algorithms. Jona keeps an eye on all the technical stuff regarding your car and will help you to determine the correct amount of fuel and the correct tyre pressures for an upcoming pitstop.
	
  - [Virtual Race Strategist](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist)

    Another Assistant, Cato, takes care of all strategic aspects during races with one or more pit stops, even under changing weather conditions. It will provide you with extensive after race reports for analysis and documentation and will help you with strategy development based on telemetry data of past sessions.
	
  - [Virtual Race Spotter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Spotter)

    The third Race Assistant, Elisa, will watch your race and will warn you about nearby other cars and will give you valuable information about the current race situation.
	
  - [Customizing Assistants](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants)

    This chapter provides a guideline how to extend the Race Assistants by connecting them to a GPT service and how to introduce new events and actions.
	
  - [Team Server](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Team-Server)

    If you are participating in multiplayer team-based endurance races, you use the *Team Server* to share the car state and the knowledge ot the Virtual Race Assistants between all participating drivers. It is also necessary for using the "Team Center" in a team race.
	
  - [Development Guide](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Development-Overview-&-Concepts)

    Complete set of information for developers, who want to create their own plugins or even contribute to the further development of Simulator Controller. Also part of the developer documentation is an introduction and complete reference for the builtin [Hybrid Rule Engine](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-Engine).
	
  - [Development Backlog](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Backlog)

    You may also want to take a look at the backlog of upcoming features.
	
  - [Credits](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Credits)

    Simulator Controller would not have been possible without the support or the contribution of many. Please check out the credits.
  
If you have any questions that have not been answered here, please feel free to contact me, but please be sure to have read anything related in the documentation in advance. If you want to report a bug, please open an issue. And last, but not least, if you want to contribute, feel free to contact me as well.