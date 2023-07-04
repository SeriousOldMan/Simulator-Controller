All applications have been implemented on top of a specialized framework especially built for Simulator Controller. This framework itself provide a couple of configuration options, which can be tweaked to adapt the Simulator Controller applications to slower or even to very fast PCs. The standard configuration is good for a typical gaming PC setup from 2021, for example a Ryzen 5 3600 CPU with 32 GB RAM.

To change any of the low level configuration options, create a file named "Core Settings.ini" and place it in the *Simulator Controller\Config* folder which resides in your *Documents* folder. Then insert the options you want to change, but be sure to preceed them with the correct category header. Example:

	[HTML]
	Viewer=WebView2

Please note, that all this confguration options are documented here for the experienced user with technical skills. Do not change any of them, until you are told so by me, or you do know what you are doing.

Let's start with the configuration settings for the task processing engine. Four priority levels are defined and tasks with higher priority will postpone the processing of tasks with lower priority, when scheduled. For systems with a faster CPU you can make the schedule window smaller, whereas slower PCs might need a less demanding schedule plan.

| Category | Setting | Default | Description |
|----------|---------|---------|-------------|
| Task     | Schedule.Interrupt | 50 | The number of milliseconds to wait between each schedule of tasks at interrupt level. Interrupt tasks are very important for the repsonsiveness of the user interface, but if the value is too low on a slower PC, tasks with lower priority might get no time at all. Example: Polling the Push-2-Talk button on the steering wheel is running at interrupt priority. |
|     | Schedule.High | 200 | The number of milliseconds to wait between each schedule of tasks with high priority. These tasks are very important stuff which can not wait until normal operations complete. Example: Detecting that one Assistant wants to issue an urgent notification to the driver thereby interrupting the speech of another Assistant. |
|     | Schedule.Normal | 500 | The number of milliseconds to wait between each schedule of tasks with normal priority. The majority of all internal tasks are running at this priority level. Example: Processing a message received by another proces. |
|     | Schedule.Low | 2000 | The number of milliseconds to wait between each schedule of tasks with low priority. All tasks that can wait until other processing has finihed are running at low priority. Example: The acquisition of telemetry data for the currently running session. |

Built on top of the Task framework, the Message Manager handles the communcation between the different applications. The delivery of messages as well as the internal processing of a received message also have a schedule window.

| Category | Setting | Default | Description |
|----------|---------|---------|-------------|
| Messages     | Schedule | 200 | The number of milliseconds to wait between each run of the message scheduler, which sends messages to and receives messages from other processes of Simulator Controller. |
|      | Dispatch | 100 | All received messages are placed in a queue for processing. This setting defines the number of milliseconds to let other activities run between each message processing. |

And finally a couple of other settings which configure low level components of Simulator Controller:

| Category | Setting | Default | Description |
|----------|---------|---------|-------------|
| Simulator | Data Provider  | DLL    | This defines the integration method used to acquire data from the different simulators. "EXE" is more reliable, but somewhat slower than "DLL", which is the default. If you encounter obviously wrong or missing data in race reports, for example, you can use the other method. |
| HTML     | Viewer  | IE11    | Many application uses and embedded HTML viewer to show graphs or other content. Actually there are two HTML engines available - *IE11*, which is based on the old Internet Explorer, which is out of support by Micorsoft and the new *WebView2* engine, which is based on Chromium engine. Since the later uses quite some resources, *IE11* is the default as long as it is available in Windows. |
| Voice     | ActivationRecognizer  | Server    | Let's you choose the speech recognizer engine for the activation command used by the voice recognition. Allowed values here are: "Server", "Desktop" and "Azure\|tokenIssuerEndpoint\|subscriptionKey" (with *tokenIssuerEndpoint* and *subscriptionKey* substituted by their corresponding values. |

