All applications have been implemented on top of a specialized framework especially built for Simulator Controller. This framework itself provide a couple of configuration options, which can be tweaked to adapt the Simulator Controller applications to slower or even to very fast PCs. The standard configuration is good for a typical gaming PC setup from 2021, for example a Ryzen 5 3600 CPU with 32 GB RAM.

To change any of the low level configuration options, create a file named "Core Settings.ini" and place it in the *Simulator Controller\Config* folder which resides in your *Documents* folder. Then insert the options you want to change, but be sure to preceed them with the correct category header. Example:

	[HTML]
	Viewer=WebView2

Please note, that all this confguration options are documented here for the experienced user with technical skills. Do not change any of them, until you are told so by me, or you do know what you are doing.

### System Settings

Let's start with some very low system level settings.

| Category   | Setting  | Default | Description |
|------------|----------|---------|-------------|
| Locations  | Temp     | %homePath%\Documents\Simulator Controller\Temp | The location of all temporary files of Simulator Controller. Set this to a different location, if your Documents folder is under control of *One Drive* or alike. |
|            | Programs | %homePath%\Documents\Simulator Controller\Programs | The location of all additional or optional programs installed or created by Simulator Controller. Especially when using Whisper, this can consume quite a lot of disk space. Set this to a different location, if your Documents folder is on a drive with restricted size, but be sure to choose a fast alternative drive. |
| Process  | Memory.Max | 1024 | The max memory in MB a process may consume, before it get killed automatically. |
|          | Memory.Critical | 80 | The percentage of max memory usage, when memory reporting starts and special debug code is activated. |
| Diagnostics | Critical | *True* | If this is *True* (which is the default), all internal erros and critical log messages get collected and are sent to the development team for further investigation. No private or personal data is transmitted, only the error messages and the stack information. This setting can be changed in the profile dialog of "Simulator Startup". |
|             | Usage    | *True* | If this is *True* (which is the default), several statistical informations are collected about the usage pattern of Simulator Controller - which tools are used how often, what functions are used and so on. This information is sent to the development team to foster further development of Simulator Controller.  No private or personal data is included. This setting can be changed in the profile dialog of "Simulator Startup". |

### Task Settings

Next are the configuration settings for the task processing engine. Four priority levels are defined and tasks with higher priority will postpone the processing of tasks with lower priority, when scheduled. For systems with a faster CPU you can make the schedule window smaller, whereas slower PCs might need a less demanding schedule plan.

| Category | Setting | Default | Description |
|----------|---------|---------|-------------|
| Task     | Schedule.Interrupt | 50 | The number of milliseconds to wait between each schedule of tasks at interrupt level. Interrupt tasks are very important for the repsonsiveness of the user interface, but if the value is too low on a slower PC, tasks with lower priority might get no time at all. Example: Polling the Push-To-Talk button on the steering wheel is running at interrupt priority. |
|          | Schedule.High | 200 | The number of milliseconds to wait between each schedule of tasks with high priority. These tasks are very important stuff which can not wait until normal operations complete. Example: Detecting that one Assistant wants to issue an urgent notification to the driver thereby interrupting the speech of another Assistant. |
|          | Schedule.Normal | 500 | The number of milliseconds to wait between each schedule of tasks with normal priority. The majority of all internal tasks are running at this priority level. Example: Processing a message received by another proces. |
|          | Schedule.Low | 2000 | The number of milliseconds to wait between each schedule of tasks with low priority. All tasks that can wait until other processing has finihed are running at low priority. Example: The acquisition of telemetry data for the currently running session. |

### Message Settings

Built on top of the Task Manager, the Message Manager handles the communcation between the different applications. The delivery of messages as well as the internal processing of a received message also have a schedule window.

| Category | Setting | Default | Description |
|----------|---------|---------|-------------|
| Messages | Schedule | 200 | The number of milliseconds to wait between each run of the message scheduler, which sends messages to and receives messages from other processes of Simulator Controller. |
|          | Dispatch | 100 | All received messages are placed in a queue for processing. This setting defines the number of milliseconds to let other activities run between each message processing. |

### Development Settings

The next group of settings is used mainly for development purposes. It allows to control the level of self-diagnosing of the framework during development and testing, but can also be used to track down really complex bugs in the production code. Please note, that some of these settings can also be toggled using the choices in the respective application menus in the tray of the Windows task bar during runtime.

| Category | Setting | Default | Description |
|----------|---------|---------|-------------|
| Build    | Configuration | Production | Chooses the runtime mode (*Production* or *Development*) of the framework. This normaly determined during compile time, but it is possible to activate parts of the *Development* mode even for production code.  |
| Debug    | Debug | *depending on configuration* | Specifies, whether the framework is running in a special debug mode. Default is *False* for a production (release) configuration and *True* for a development configuration. This option overwrites the choice as set in "Simulator Configuration" and it can be switched using the application menu. |
|      | LogLevel | *depending on configuration* | Defines the level of verbosity of the logging messages. Allowed values are *Debug*, *Info*, *Warn*, *Critical* and *Off*. Defult is *Warn* for production configuration and *Debug* for devlopment configuration. This option overwrites the choice as set in "Simulator Configuration" and it can be switched using the application menu. |
|      | LogStartup | False | If *True*, special logging is enabled which gives you insights into the timing during the startup process of any of the applications of Simulator Controller. Use this, if any of the applications seems to hang during startup. |
|      | Verbose | *depending on configuration* | Enables or disables additional and very verbose diagnostic output. Never use it in a real race, since error dialogs might popup while driving. Default is *True* for non-compiled code, when *Debug* is enabled, *False* otherwise. |
|      | DebugStrategy | False | If *True*, the Strategist protocols the history of strategies and also his communication with the Race Engineer in the directory %homePath%\Documents\Simulator Controller\Temp\Race Strategist\Strategy. |

### Voice Settings

The following group let's you control a couple of aspects of the voice recognition engine.

| Category | Setting | Default | Description |
|----------|---------|---------|-------------|
| Voice     | Activation Recognizer  | Desktop    | Let's you choose the speech recognizer engine for the activation command used by the voice recognition. Allowed values here are: "Server", "Desktop", "Azure\|tokenIssuerEndpoint\|subscriptionKey" (with *tokenIssuerEndpoint* and *subscriptionKey* substituted by their corresponding values), "Google\|apiKey" (with *apiKey* substituted by its corresponding value) and possibly "Whisper" (if installed). "Server" might be useful in noisy environments. |
|      | Activation Speed  | 500 (Windows default)    | The maximum number of milliseconds between a click or press on the Push-To-Talk, so that an activation mode is triggered. Default is the Windows setting for the mouse double click speed (typically 500 ms, if not changed by the user). |
|      | High Rating  | 0.85     | This value represents the Sorenson-Dice rating for a good enough match of a command phrase, when comparing a spoken command against the registered command syntax. The range of the rating is from 0.0 (no match at all) up to 1.0 (perfect word by word match). When a registered phrase is found with a *High Rating* quality index or higher, this command is used, regardless, whether there are remaining phrases to be tested. By tuning this setting, you can specify how precise the spoken commands must follow the registered syntax. |
|      | Low Rating | 0.7     | This value represents the Sorenson-Dice rating a registered command syntax must reach, when compared to a spoken command, so that this command is even considered. The range of the rating is from 0.0 (no match at all) up to 1.0 (perfect word by word match). |
|      | Interruptable | False | If not *False*, the currently active speech will be interrupted, if Push-to-Talk is pressed. If the value is "All", all currently pending speeches will be discarded as well, before the listener is activated. |

### Script Settings

The Script Engine used by the Assistants is based on the well-known *Lua* scripting language. *Lua* can use libraries or modules, which can be loaded on demand using the *require* statement. These libraries will be searched in those directories defined in a correspnding *Path* setting. If you have defined your own libraries, put them in a folder and point the settings below to this folder. However, if you are using the *Lua* package manager *luarocks* and use only libraries from there, this is not necessary, as long as the packages are located in "%appdata%\luarocks\share\lua\5.4" and "%appdata%\luarocks\lib\lua\5.4", which are the defaults for *luarocks*.

| Category      | Setting        | Default | Description |
|---------------|----------------|---------|-------------|
| Script Engine | Modules Path   | %homePath%\Documents\Simulator Controller\Scripts\\?.script;%homePath%\Documents\Simulator Controller\Scripts\\?.lua;%APPDATA%\luarocks\share\lua\5.4\\?.lua | The path to search for *Lua* modules. Please note the "?.lua" at the end which matches *Lua* source files. When placing scripts in the %homePath%\Documents\Simulator Controller\Scripts direectory, they can have also the extension ".script". The default value contains the local script folder and also the default location for *luarocks* modules. |
|               | Libraries Path | %APPDATA%\luarocks\lib\lua\5.4\\?.lua | The path to search for libraries written in other languages which can be used by *Lua*. Please note the "?.dll". The default value points to the default location of *luarocks* libraries. |

### Miscellaneous Settings

And finally a couple of other settings which configure low level components of Simulator Controller:

| Category | Setting | Default | Description |
|----------|---------|---------|-------------|
| Controller  | External Dispatch | 100   | Specifies how long the central event loop waits in milliseconds before it checks again for external controller commands as described [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#external-commands). |
| HTML     | Viewer  | IE11    | Many application uses and embedded HTML viewer to show graphs or other content. Actually there are two HTML engines available - *IE11*, which is based on the old Internet Explorer, which is out of support by Micorsoft and the new *WebView2* engine, which is based on Chromium engine. Since the later uses quite some resources, *IE11* is the default as long as it is available in Windows. |
| Simulator | Data Provider  | DLL    | This defines the integration method used to acquire data from the different simulators. "EXE" is more reliable, but somewhat slower than "DLL", which is the default. If you encounter obviously wrong or missing data in race reports, for example, you can use the other method. |
| Stream Deck     | Protocol  | Message    | Specifies the communication method between Stream Deck and Simulator Controller. "Message", the default uses traditional message-based inter-process communication, whereas "File" writes the messages to a shared file. Use "File" only, if you encounter stability issues with message-based communication. |
| Team Server | Update Frequency  | 10    | Specifies the minimum number of seconds to wait between each update of the data acquired from the currently running simulator, when running a team session. This value (which you should only change by being told so), restricts the value set in the ["Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database) tool for the Data Update Frequency, so that the update frequency cannot get smaller in team sessions to protect the Team Server from update stalling. |
| Window     | ConstrainWindow  | True    | If *True*, windows will be constrained to a minimum size. If *False*, windows can be made smaller, but it may be possible that content may be made invisible in this case. |
|            | ConstrainControls | True    | If *True*, controls will be constrained to a minimum size according to their resize rules. If *False*, no such rules apply, but it may be possible that the controls get to small for normal interaction. |