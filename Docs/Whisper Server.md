## Introduction

*Whisper Server* is a server-based solution, which allows you to run the famous Whisper voice recognition system (originally developed by OpenAI and available as Open Source) on a remote machine. The voice recognition quality of Whisper is comparable to the services provided by Azure or Google, but it runs fully locally. Performance is also comaparable, as long as the neural network is executed on a capable graphics card.

Whisper can be run on the same PC as Simulator Controller itself and therefore also alongside the running simulator, but this will result in most cases in mediocre performance and may also cause frame rate degredation, unless your machine is really high end. Therefore, you can run Whisper on a second PC, for which a GPU with 8 GB of RAM is sufficient.

## Installation & Configuration

The *Whisper Server* requires you to run a Web API server process, which has been developed using .NET 8.0. Applications developed using this multi-plattform server framework from Micorsoft can be hosted on Windows, Linux and even macOS operating systems. You can find the *Whisper Server* in the *Binaries* folder - please copy this directory to your favorite hosting environment or to a location outside the Windows program folders for a local test environment. If you want to set up your own host or if you want to test the *Whisper Server* on your local PC, you probably will have to install the .NET 8.0 Runtime (Hosting Bundle) - depending on your installed Windows version. All required resources can be found on this [dedicated website](https://dotnet.microsoft.com/en-us/download/dotnet/8.0) from Microsoft.

After you have installed .NET Runtime 8.0 and the Team Server, you have to configure the URL, where the server listens. Default is "https://localhost:7001" or "http://localhost:7000". But, when you want to setup a server which is available on the network, you have to setup a different URL. Information about this can be found in this [short article](https://andrewlock.net/5-ways-to-set-the-urls-for-an-aspnetcore-app/). The easiest way will be to supply the URL using a command line argument, for example:

	"Team Server.exe" --urls "http://yourip:7100;https://yourip:7101"

with *yourip* substituted with the IP, where your server should be available. And you have to make sure that this IP is visible to the public, of course.

Then take a look at the "Settings.json" file, which is located in the same folder.

	{
	  "WhisperPath": ".\\Whisper Runtime"
	}

Here you must define the path to the "Whisper Runtime" directory. The "Whisper Runtime" is a downloadable component of Simulator Controller, which is available as [preset "Local runtime for Whisper speech recognition"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#presets--special-configurations) in "Simulator Setup". Of course, you need to transfer the directory *Whisper Runtime*, which is located in the *Simulator Controller\Programs* folder in your user *Documents* folder, to the machine where you are running the Whisper Server, after you have downloaded and installed the DLC. After you have done that, specify the path to this directory in the above settings file. Please note, that backslashes must be *doubled*, like in "D:\\AI\\Server\\Whisper Runtime".

## Running the Whisper Server

You can start the *Whisper Server* by running "Whisper Server.exe" (with the required options) from the corresponding directory. The server will open a sheel window, where diagnostic information for the server process itself and also for each request is available. If a model is used for the first time, additional information about the download progress will be shown here as well.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Whisper%20Model%20Download.JPG)

## Connecting to the Whisper Server

To use the Whisper Server for voice recognition, you have to configure "Whisper Server" in the [voice control configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#whisper-runtime) as the voice recognition method.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%207%20Whisper%20Server.JPG)

As "Server URL" use one of the URLs to which the server listens.