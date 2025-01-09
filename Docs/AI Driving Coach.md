## Introduction

Aiden, The AI Driving Coach, is a fully AI based chatbot which plays the role of your personal driving coach. Implemented with state of the art AI technologiy GPT (aka generative pretrained transformer) using an LLM (aka large language model), the AI Driving Coach behaves and interacts as natural as possible. It depends heavily on the concrete LLM which is used, what knowledge is available about the race driving topic and how detailed this knowledge is. Modern LLMs, like GPT 3.5 or GPT 4 are actually very good even in this very special domain.

Simulator Controller does not provide its own LLM, of course. And this is even not necessary, since there are a dozens of very good models available in the Open Source (see the [Hugging Face website](https://huggingface.co/) for a complete overview what's available). And there are commercial models available as well, first and foremost from OpenAI, the company, that created the famous ChatGPT solutions. Simulator Controller uses API calls to use the services provided by an existing GPT engine to run the LLM used by Aiden, or you can use the integrated "LLM Runtime", to run everything on your own PC, as long as your machine is powerful enough. You can choose in the configuration which provider is used and even which LLM you want to use (see below in the chapters about [installation](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#installation) and [configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#configuration).

Before we proceed to the details of the configruation and the rules how to interact with your personal Driving Coach, let's take a look at a typical interaction with Aiden.
 
### A typical dialog

It is very hard to describe, how the interaction with Aiden is like. Therefore, let's take a look together at a short interaction. By the way, the Driving Coach is named "Kim" here.

[![](https://img.youtube.com/vi/LBtLk_md1IE/0.jpg)](https://youtu.be/LBtLk_md1IE)

And here is a transcript of a very similar conversation:

**Driver:** Can you introduce yourself?

**Aiden:** I am Aiden, a driving coach and expert in car handling and car physics. I specialize in circuit racing, both in simulations and real-world racing. I have experience in troubleshooting handling issues and understanding the relationship between car setup choices and handling problems. How can I assist you today?

**Driver:** I am driving a Mercedes AMG GT3, which has a front engine. I have problems with severe understeering, especially in slow tight corners. Must I adopt my driver inputs or are there any options for the car setup?

**Aiden:** Severe understeer, especially in slow tight corners, can be a common issue in front-engine cars like the Mercedes AMG GT3. There are a few things you can try to address this issue:

1. Driver inputs: You can try adjusting your driving technique to help reduce understeer. One technique is to brake earlier and in a straight line before entering the corner, allowing the weight to shift forward and increase front grip. Additionally, you can try releasing the brakes gradually as you turn into the corner, which can help transfer weight to the front tires and improve grip.

2. Car setup: There are several setup adjustments you can make to reduce understeer. Increasing front tire pressures can help improve responsiveness and grip. Softening the front suspension or stiffening the rear suspension can also help transfer weight to the front tires and improve front grip. Additionally, adjusting the front and rear anti-roll bars can help balance the car and reduce understeer.

It's important to note that every car and track combination is unique, so it may take some trial and error to find the right setup adjustments for your specific situation. I recommend using a telemetry analyzer like "Setup Workbench" to analyze the handling of your car and make informed setup changes.

**Driver:** I am quite bad in trail breaking. What can I do?

**Aiden:** If you're struggling with trail braking, there are a few things you can try to improve your technique:

1. Gradual Progression: Start by gradually increasing your braking pressure as you approach the corner. This will help you get a feel for the braking point and the amount of pressure needed to maintain control.

2. Smooth Inputs: Ensure that your braking inputs are smooth and progressive. Abrupt or jerky braking can unsettle the car and make it difficult to maintain control.

3. Trail Braking Technique: Practice the technique of gradually releasing the brake pedal while smoothly transitioning to the throttle as you enter the corner. This helps to transfer weight to the front tires and improve grip for better turn-in.

4. Visual Focus: Look ahead and focus on the desired racing line rather than fixating on the braking point. This will help you anticipate the corner and make smoother inputs.

5. Practice and Feedback: Regular practice and seeking feedback from experienced drivers or coaches can greatly assist in improving your trail braking technique. They can provide guidance specific to your driving style and help identify any errors or areas for improvement.

Remember, trail braking is a skill that takes time and practice to master. Be patient with yourself and keep working on it.

**Driver:** Can we talk about strategy?

**Aiden:** Certainly! I can provide some insights on race strategy. What specific aspects of strategy would you like to discuss?

**Driver:** I have a one hour race coming up. Fuel and tyres are good for the complete race, but there is a mandatory pit stop. The pit stop does not require changing tyres. What is the best strategy for this race?

**Aiden:** Given that you don't need to change tires during the pit stop, the best strategy for your one-hour race would typically involve the following steps:

1. Pit stop timing: Analyze the race length and the fuel consumption rate of your car to determine the ideal pit stop window. You want to time your pit stop to minimize the time spent in the pits while ensuring you have enough fuel to finish the race.

2. Pit stop execution: During the pit stop, the primary focus will be on refueling the car. Make sure to communicate effectively with your team to ensure a quick and efficient pit stop. Practice entering and exiting the pit lane smoothly to avoid any penalties or delays.

3. Strategy adjustments: Depending on the characteristics of the track and the behavior of your competitors, you may need to adjust your strategy during the race. Pay attention to any changes in track conditions, weather, or the performance of your competitors. This will help you make informed decisions about your pit stop timing or any necessary adjustments to your driving style.

Remember, every race is unique, and it's important to adapt your strategy based on the specific circumstances. Analyzing telemetry data, working closely with your team, and staying aware of the race dynamics will help you make the best decisions for a successful race.

**Driver:** Would an early pit stop or late pit stop be better?

**Aiden:** Determining whether an early or late pit stop is better depends on various factors, including track conditions, tire degradation, and the behavior of your competitors. Here are some considerations for both options:

Early Pit Stop:
- Track position advantage: An early pit stop can give you the advantage of running in clean air without traffic. This can allow you to push harder and potentially gain positions before other competitors make their pit stops.
- Tire management: If the track conditions or tire degradation are particularly challenging, an early pit stop can help you switch to fresh tires sooner. This can improve your grip and overall performance, especially if the tires are experiencing significant wear.
- Undercut strategy: An early pit stop can be used as an undercut strategy, where you aim to gain track position by pitting earlier than your competitors and taking advantage of the fresh tires and empty track ahead.

Late Pit Stop:
- Tire management: If tire degradation is not a significant concern, a late pit stop allows you to maximize the stint length on your current set of tires. This can be beneficial if your tires are performing well and you can maintain a competitive pace without losing too much time.
- Overtaking opportunities: A late pit stop can offer opportunities for overtaking as other competitors make their pit stops. By staying out longer, you may benefit from fresher tires and potentially gain positions as others rejoin the track after their stops.
- Track position preservation: If you have a good track position and are confident in your pace, a late pit stop can help you maintain that position without risking losing positions in the pits.

Ultimately, the decision between an early or late pit stop should be based on careful analysis of the specific race circumstances, including tire wear, track conditions, and the behavior of your competitors. It's also essential to consult with your team and analyze telemetry data to make an informed decision that best suits your race strategy.

**Driver:** Can you shorten this answer?

**Aiden**: Certainly! Here's a shorter version:

The decision between an early or late pit stop depends on factors like track conditions, tire degradation, and competitor behavior. 

An early pit stop can give you a track position advantage, help manage tire wear, and potentially allow for an undercut strategy. 

A late pit stop can maximize tire stint length, offer overtaking opportunities as others pit, and preserve track position. 

Ultimately, analyze the specific race circumstances, consult with your team, and consider telemetry data to make an informed decision that suits your race strategy.

## Installation

Installation requires you to choose one of the supported large language model providers. The most capable current LLMs (aka large language models) are provided by the company OpenAI, as you probably know. OpenAI provides an HTTP API to connect to these models. This comes with some costs, but these are negligible. I accumulated costs of about 20 Cent at the time of this writing and I have run hours of interactions already. Most OpenAI LLMs are also available in the Azure cloud, in the end a matter of taste which one to use. Another inetersting provider is Mistral AI, the European alternative to OpenAI. Or you can use OpenRouter, which provides access to many models of different providers, or even from the Open Source. And there is also an open GPT runtime platform, which can host a vast variety of LLMs developed by universities or less knwon companies. This runtime, named GPT4All, is free and the models can be run on your local PC. But be aware that running an LLM locally on your PC is a very demanding taks and will not be possible in parallel to a running simulation, even if your GPU has enough memory.

The performance and - even more important - the knowledge about the motorsport domain varies between different models. I have made good experience with "GPT 3.5 turbo" and "GPT 4 turbo" from OpenAI, as well as with "Open Mixtral 8x22b" from Mistral AI. Models from the Open Source are a bit more restricted, but "Wizard 1.2", for example, makes a decent job. In the end, you may want to experiment by yourself, but I recommend "GPT 3.5 turbo" as a starting point at the time of this writing. Using LLMs for non-English conversation is a different story. In this case, you will notice, that models from the Open Source will not deliver good results in most cases.

### Generic

This one supports any GPT service provider, which implements the JSON-based instruction protocol defined by OpenAI (see next entry).

### OpenAI

When you have chosen OpenAI, which I recommend, you will have to create an account on [OpenAI](https://openai.com). You will have to invest a couple of bucks to charge up your account - $5 will be more than enough. Follow these steps:

1. Create an account on [openai.com](https://openai.com).
2. Goto the [platform page](https://platform.openai.com/) and select the "Manage account" from your account menu. There you can add a payment in the billing section.
3. Select [API keys](https://platform.openai.com/account/api-keys) in the sidebar menu. There you can create your sectret key.
4. Note down this key, since you will have to enter it into the configuration of the AI Driving Coach.

### Azure

Thanks to the intensive collaboration between OpenAI and Microsoft, many OpenAI models are also available on the Azure Cloud. The performance is a little better, the cost is a little higher. In order to gain access to OpenAI models in the Azure Cloud, an entry must be made in the Azure Console, but this is usually approved. After approval you can get an communication endpoint and API key which then must be used in the configuration of the AI Driving Coach. You also must note down your Azure service endpoint, which must be inserted in the "Service URL" field in the configuration.

### Mistral AI

Very similar to OpenAI. Create an account on [Mistral AI](https://console.mistral.ai/). You will have to register your credit card, but you will only be charged for usage, which is very, very cheap for the Open Weight models. Then create an API key and include it in the configuration as described above. I recommend using the Open Mixtral 8x22b model for the start, which has the best price / performance ratio.

### OpenRouter

[OpenRouter](https://openrouter.ai) is a kind of gateway and hosting environment for many models of different providers, even many source LLMs are available here. It has become my favorite provider in the sense of a one-stop-shop for LLM access. You have to buy a few credits (5$ at least) [here](https://openrouter.ai/credits), before you can use the service. Then create an API key in your user account and include it in the configuration as described above. The last step is to choose the model you want to use from the very long list [here](https://openrouter.ai/models). There are even models available, which do not create any costs when called through the API, like the "meta-llama/llama-3-8b-instruct:free". But as mentioned above, the performance and domain knowledge might not meet your expectations.

### Ollama

Ollama is a free GPT server, which can be run anywhere, including your local PC. It can be downloaded from the [Ollama webiste](https://ollama.com/) for different operating systems incl. Windows. The websste also provides downloads for several LLMs, but you can also use models from other sources.

Documentation for installation and setup can be found on the [Github page](https://github.com/ollama/ollama). Although Ollama is a very powerful solution for setting up your own LLM server, it requires a lot of technical skills and is therefore not for everyone. For a more simple and easy-to-use solution see the next section.

### GPT4All

The alternative, GPT4ALL, can be downloaded from the corresponding [website](https://gpt4all.io/index.html). Install it on your PC and enable the API server in the settings. Additionally you will have to download and install one or more models, which can be done from inside the application window. At the time of this writing, the model *Wizard 1.2* is a very good allround model. In fact you can use any model in the GGUF format supported by Llama, not only the models provided on the GPT4All website.

Please be aware, that running a GPT4All locally puts heavy load on your PC and can use quite a lot of memory (even from your GPU). Therefore do not ask any questions while driving, unless you have a really powerful configuration. Even if your PC is idle, the answer will take some time to be generated, so be patient.

IMPORTANT: At the time of this writing, the integrated REST API of the GPT4All chat client is under heavy development and cannot be considered final or even stable. If you have issues establishing a connection to the local GPT4All HTTP server, take a look at this [article on GitHub](https://github.com/nomic-ai/gpt4all/issues/934). As an alternative, you can either setup a dedicated API server for GPT4All, even on a different machine, if you are a seasoned developer, or you check out the next option.

### LLM Runtime

This one implements an embedded runtime engine for large language models. You do not even have to install GPT4All on your PC, for example, everything is already integrated into Simulator Controller. But since this runtime is quite big (several hundered MB), it must be installed as additional DLC (open "Simulator Setup", go to the Presets page and install the "Local Runtime for LLMs" package).

Technical note: This package supports LLM execution on Nvidia GPUs using Cuda 11 or Cuda 12. To use CUDA for execution of the LLM on the GPU, you have to install the [CUDA drivers](https://developer.nvidia.com/cuda-12-1-0-download-archive?target_os=Windows) from the Nvidia homepage. Install only CUDA, all the other stuff should already be there with your standard Nvidia driver. Vulkan support for other GPU brands is included as well. Of course, the different AVX specifications are supported for CPU execution.

IMPORTANT: It can happen, that the Vulkan driver support conflicts with CUDA on Nvidia GPUs. If this is the case, the Driving Coach will give you an error message like "I am on the other line, please come back in a minute." To fix this, remove the *vulkan* folder from the *Simulator Controller\Programs\LLM Runtime\runtimes\win-x64\native* folder in your user *Documents* folder.

You also have to download an LLM. Make sure the model is in GGUF file format. You can find good models on the [GPT4All website](https://gpt4all.io/index.html) or on the [Hugging Face website](https://huggingface.co/), the largest community for AI development world wide. I recommend starting with *Wizard 1.2* (["wizardlm-13b-v1.2.Q4_0.gguf"](https://gpt4all.io/models/gguf/wizardlm-13b-v1.2.Q4_0.gguf)), which is a very good allround model. Another very good model at the time of this writing is *Hermes* (["nous-hermes-llama2-13b.Q4_0.gguf"](https://gpt4all.io/models/gguf/nous-hermes-llama2-13b.Q4_0.gguf)). Both models consume up to 16GB of RAM, so you need to have at least 32 GB RAM in your machine. There are also some smaller models available on the GPT4All website, but their knowledge about our domain is very limited.

Once you have selected and download a model, enter the full path to the model file into the "Model" field and your done. And you can specify, how many layers of the model would be executed on your graphics card, which of course requires that the GPU can provide the amount of memory to the model. This might need some try and errors, until you find a suitable configuration, which also allows you to still tun your favorite simulator.

Please be aware, that running a large language model locally puts heavy load on your PC and can use quite a lot of memory (even from your GPU). Therefore do not ask any questions while driving, unless you have a really powerful configuration. Even if your PC is idle, the answer will take some time to be generated, so be patient.

### Using the Driving Coach without an LLM

It is possible to use the Driving Coach without a large language model. This configuration supplies only a very [restricted version of the on-track coaching functionality](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#restricted-mode-without-an-llm) and only pre-defined voice commands will be supported. Of course, you will miss all the fun of a natural conversation with a very skilled racing expert as demonstrated above, but it is a starting point.

To use this restricted mode, select the *Generic* GPT provider in the configuration, but leave all fields like Service URL and the Model empty. As this is actual the default for a new installation, the restricted mode will be available out of the box.

## Configuration

The next step is to setup everything in the configuration, either in "Simulator Setup" or "Simulator Configuration". Please follow the instructions in the [Installation & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-driving-coach) chapter.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%2012.JPG)

Since the voice recognition quality is so important for a correct dialog with Aiden, I strongly recommend to use one of the "Azure" or "Google" voice recognition engines. The "Desktop" engine may be used as well, especially, when you are using a high quality headset. And use the training mode of the Windows speech recognition, which is available in the Windows Settings -> Time & Language -> Speech  page.

### Instructions

A very important aspect in the configuration of the Driving Coach are the so called instructions. Instructions provide the LLM with important context information and specifies, how it should react to your questions. It also defines the profession and personality of the Driving Coach. Last but not least, instructions are also used to convey data from your current session in a running simulator to the Driving Coach.

Simulator Controller provide default instructions for all supported languages and instruction categories, but you are free to create your own instructions. Please note, that the default instructions are optimized for OpenAI language models. If you are using LLMs provided by GPT4All, you may have to adopt or totally rewrite the default instructions to work with the chosen model.

Instructions support embedded variables. These variables are automatically replaced with information about the currently running simulation, your progress in the current race, or handling issues, and so on. Whether or not the Driving Coach will understand and use this information will heavily depend on the model and the current context of your discussion with the coach. But you may be successful in most cases by explicitly asking the Driving Coach to take a look at the supplied data.

Below you find all instruction categories and the supported variables:

| Instruction | What              | Description |
|-------------|-------------------|-------------|
| Character   | Scope             | This instruction is used always and must define the profession and the personality of the Driving Coach. You can also include general instructions like "Keep your answers short and precise". The default instruction creates a driving coach specialized in car handling and car physics. |
|             | %name%            | %name% will be replaced with the configured name of the Driving Coach.          |
| Simulation  | Scope             | This instruction is supplied, when an active simulation is detected.            |
|             | %simulator%       | The name of the used simulator.                                                 |
|             | %car%             | The name of the used car.                                                       |
|             | %track%           | The name of the used track.                                                     |
| Session     | Scope             | When you have already started a session, information about the session is provided using this instruction. |
|             | %session%         | Either "Practice", "Qualifying", "Race" or "Other".                             |
|             | %carNumber%       | The race number of your car.                                                    |
|             | %overallPosition% | Your starting position in the overall gid.                                      |
|             | %classPosition%   | The starting position in your class.                                            |
| Stint       | Scope             | This instruction is updated with each lap and provides information about your performance as well as the current standings. |
|             | %carNumber%       | The race number of your car.                                                    |
|             | %lap%             | The lap you have just finished.                                                 |
|             | %position%        | Your position in your class at the end of the last lap.                         |
|             | %laps%            | This variable is substituted with a CSV table of your performance during the last laps. This table contains columns for your position (overall and class) as well as the lap time and sector times. You can define the number of laps to be reported by defining the variable as %laps:5%, for example. |
|             | %standings%       | This variable is replaced with a CSV table containing the current standings sorted by overall position. This table contains columns for the race number, class, position (overall and class) as well as the lap time and sector times. |
| Knowledge   | Scope             | This instruction is used to supply the current content of the knowledge base to the LLM. |
|             | %telemetry%       | This variable is substituted with the content of the knowledge base in a self-explaining JSON format. |
| Handling    | Scope             | This instruction is used only when handling problems had been detected in the telemetry. See the chapter below about detecting handling problems and discussin them with Aiden. |
|             | %handling%        | An enumeration of all detected handing problems. See the [dedicated chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#detecting-and-discussing-handling-problems) below for more information. |
| Coaching    | Scope             | This is a very long instruction, which is used when the telemetry-based coaching is active. It describes many areas to check in the telemetry data when looking for potential imrpvements. See the [dedicated chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#coaching-based-on-lap-telemetry-data) below for more information. |
|             | %telemetry%       | This is a special variable, because it is actually not part of the instruction text, but is appended in *normal* conversation when corner by corner coaching is active. This variable will be replaced condensed telemetry data in JSON format for the last lap and possible recent laps. See the [dedicated chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#coaching-based-on-lap-telemetry-data) below for more information. |
| Coaching.Lap | Scope            | This is synthetic question/command, which is sent to the LLM, if the user request a complete telemetry review of the last lap. |
|             | %telemetry%       | This variable will be replaced with a condensed representation of the telemetry data in JSON format for the last lap and possible recent laps. See the [dedicated chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#coaching-based-on-lap-telemetry-data) below for more information. |
| Coaching.Corner | Scope            | This is synthetic question/command, which is sent to the LLM, if the user request a review for a specific corner. |
|             | %telemetry%       | This variable will be replaced with a condensed representation of the telemetry data in JSON format for the last lap. Only the data for the requested corner and the section after it will be included. See the [dedicated chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#coaching-based-on-lap-telemetry-data) below for more information. |
|             | %corner%          | The corner to be reviewed. |
| Coaching.Corner.Approaching | Scope            | Similar to the "Coaching.Corner" instruction. Used for on-track recommendations for an upcoming corner. |
|             | %telemetry%       | This variable will be replaced with a condensed representation of the telemetry data in JSON format for the last lap. Only the data for the requested corner and the section after it will be included. See the [dedicated chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#coaching-based-on-lap-telemetry-data) below for more information. |
|             | %corner%          | The corner to be reviewed. |
| Coaching.Corner.Problems | Scope            | This instruction is used in several situations to give the LLM additional knowledge about the possible problems induced by driver input errors at a given corner. This knowledge is derived by the rule engine based on the telemetry data. Particular useful for smaller LLMs which are not that strong in reasoning. If you are using a premium model, the text of this instruction can be deleted to let the LLM decide on its own. |
|             | %problems%       | Will be replaced with a comma separated list of driver errors like "Too much pushing, Too late braking". See the [dedicated chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#coaching-based-on-lap-telemetry-data) below for more information. |
|             | %corner%          | The corner to be reviewed. |
| Coaching.Reference | Scope            | This is used as an addition for many of the above synthetic questions/commands for telemetry review. It is used, when a reference lap is available, which can be used for comparison against the most recent lap. |
|             | %telemetry%       | This variable will be replaced with a condensed representation of the telemetry data in JSON format for the reference lap. See the [dedicated chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#coaching-based-on-lap-telemetry-data) below for more information. |

As said, all instructions can be modified in the configuration. You can even clear a complete instruction, if you want (and don't want to dicuss the corresponding information with Aiden). I do not recommend to clear the "Character" instruction, though.

IMPORTANT: Depending on the configuration, especially the chosen model and also the "# Tokens", you may encounter problems with very complex input, for example a longer race with many recorded handling issues. In this case, Aiden will refuse to give you answer with a stupic excuse. That means, that the GPT service returned with an error code, typically meaning that the input area of the LLM was too small. Never happened for me with the GPT-4 model with "# Tokens" set to 2048, though, but happened a couple of times using the *smaller* models.

## Interacting with Aiden

Since an interaction with Aiden always is kind of a free dialog, the only way to interact with Aiden is through voice. Simply call your coach, for example with "Hey Aiden", and then formulate your first question. And here the fun begins. Interacting with an LLM feels like a natural human-2-human interaction, but you need to follow some rules to get the information you want:

1. Be as specific as possible
   Asking "What can you tell me about trailbraking" will at best give you a long essay about this topic. A better question will be "I have problems with trailbraking. How can I improve it?"

2. Give as much context as you have
   It is important that your coach knows as much about the background of your current situation and the purpose of your question as possible. Give this information as early as possible.
   
   Most of the context information is provided in the initial default instructions (see the [configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-driving-coach) for more information how to provide these instructions). But you may have individual context information, which you can provide **before** your question. Example: "I am driving a Mercedes AMG GT3, which has a front motor. I have severe problems with understeering. How should I adopt my drving technique? And how can I setup the car to counteract this?"

3. Don't hesitate to ask for more specific information
   LLM based chat bots tend to give more general information in their first answer, but you can always guide them to more specific answers with follow up questions.

4. Also don't hesitate to correct wrong or incomplete answers
   If you think, that an answer is wrong, or that Aiden missed an important aspect or did not take data into account, which had been provided in the instructions (see above), you can mention that fact and ask for extended or corrected information.

5. Give instructions how the answer should look like
   LLMs *understand* instructions like "Keep it short." or "Don't be so formal."

6. Rephrase your questions
   If Aiden still resists to give you the desired answer, you can try to rephrase your question. Sometimes using a different word, a synonym, will do the job.

The above list are only few of the rules to follow, though the most important ones, when working with an LLM based AI. There are many good articles on te web about the so called *prompt engineering*, which can give you further hints.

### Detecting and discussing handling problems

The Driving Coach will try to detect possible handling problems using the same mechanism that is used by the "Setup Workbench". In fact, Aiden uses the same [Issue Analyzer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#real-time-issue-analyzer) as the "Setup Workbench" and will use the same settings and thresholds you have selected for the same car and track last time. Therefore, if you want to discuss your handling issues with Aiden, be sure to have created a valid or even calibrated configuration in the Telemetry Analyzer for the given car and track.

When at least one handling issue had been detected, the "Handling" instruction will be used to describe the handling issues to the Driving Coach. Each issue will be described on a single line in the instructions. Example:
 
	- Heavy Understeer on Slow corner Entry
	
Using this knowledge, Aiden should be able to give you information how to cope with the given handling issues, for example by changing your driver inputs or changes to the car setup.

Information: You can disable this instruction (and every other instruction as well) completely, by clearing it in the configuration, if you don't want Aiden to give you information regarding handling problems. If you want to temporarily enable or disable it during a running session, you can use the voice commands below.

### List of all voice commands

1. [English version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Driving-Coach-Commands-(EN))

2. [German version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Driving-Coach-Commands-(DE))

3. [Spanish version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Driving-Coach-Commands-(ES))

4. [French version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Driving-Coach-Commands-(FR))

5. [Italian version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Driving-Coach-Commands-(IT))

Normal you will use free conversation to interact with Aiden as shown in the example above. But there are also a couple of predefined grammar based commands available, for example to enable or disable the processing of specific information (see below in the next section). You will always find the current version of the grammar files as actually used by the software in the *Resources\Grammars* folder of the Simulator Controller distribution. Or you can take a look at the files in the [Resources\Grammars directory on GitHub](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Resources/Grammars), for example the German version [Driving Coach.grammars.de](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Grammars/Driving%20Coach.grammars.de).

### Enabling and disabling specific instructions and information processing 

As discussed above Aiden can process information about your current session in a simulation. This includes specific data about your own performance and the preformance of your competitors, as well as information about your recent handling issues. The processing of this data may sometimes confuse the AI behind the Driving Coach, especially for some of the lower-grade LLMs. Therefore you may disable specific information processing by using a special voice command:

	[Please] do not pay attention *information* anymore [please]

As you might expect, the word "please" is optional. Available options for *information* are: "session information", "stint information", "handling information". These options resemble, as you already may have recognized, the instructions discussed above. After you have disabled one of the information processings (all are enabled by default), you can reenable it with the following command:

	[Please] pay attention to *information* again [please]

## Coaching based on lap telemetry data

The Driving Coach is integrated with the telemetry data system of Simulator Controller. You can use a voice command or the plugin action "TelemetryCoaching" on your controller to activate telemtery collection for the Driving Coach. Example for a voice command: "Can you help me with my practice?"

Aiden will then start collecting telemetry data and will contact you after a few laps that he is ready to discuss your performance with you. You can ask for a review of a complete lap or a specific corner, if required. You can also ask more specifically, for example, if you have weaknesses in your braking and how you should work on them. Here is an example:

**Driver:** What are my most important weaknesses and how should I work on them?

**Aiden**: You have several areas to focus on for improvement. 

In turn 2, your maximum lateral G-force is lower than in other corners with similar curvature, indicating that you might not be utilizing the car's full potential. Consider adjusting your cornering technique to extract more grip.

In turn 3, the number of ABS activations is quite high at 13. This can degrade your braking performance. Try to implement trail braking to reduce the number of activations and improve your braking efficiency.

In turn 7, you have 5 TC activations, which can hinder your acceleration out of the corner. Work on opening the throttle gradually or consider short-shifting to minimize traction control interventions.

For turn 9, while your steering smoothness is good, the braking phase could be optimized. You might want to explore a later braking point to reduce the length of the braking phase and improve your overall time through the corner and the following section.

Focusing on these areas will help you improve your lap times and overall performance.

Beside discussing the telemetry data for the last lap, you can also ask Aiden to give you corner by corner instructions while you are driving. This is discussed [below](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#coaching-on-the-track).

Here is a recording of a training session, since no words can really adequately describe this feature.

[![](https://img.youtube.com/vi/mgfFkNh2_Lw/0.jpg)](https://youtu.be/mgfFkNh2_Lw)

DISCLAIMER: This functionality requires a very capable LLM for decent results. This LLM must be able to follow multiple, complex chain of thoughts at the same time and must be able to perform reasoning based on supplied facts. At the time of this writing, only high end models like GPT 4o, Claude 3 Opus or Mistral Large are in this group. The upcoming o1 model of OpenAI may be even better in this area, but it will be prohibitevly expensive. According to my testing, GPT 4o mini, the most cost-efficient model of OpenAI and also Mistral Small by Mistral AI show good results as well, but sometimes they mix up things, for example, that applying less brake pressure at the start of the braking phase will make your braking phase shorter. This can also happen with the stronger models sometimes, but not that often. You can experiment with the *Creativity* configuration setting of the Driving Coach to find the best compromise here.

### Track layout

Before you can use the telemetry-based coaching, you must have recorded a [track map](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Spotter#track-mapping) for the given track and you must have defined the different sections (corners and straights) of the track. Detailed instructions can be found [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#track--automation).

![](https://github.com/SeriousOldMan/Simulator-Controller/raw/main/Docs/Images/Session%20Database%2020.jpg)

Please note, that you do not have to set sections for each corner, only for those where you are interested in. You also should not define corners where no braking is necessary, since you will not get any valuable insights for those corners from Aiden.

And be aware, that corners directly followed by another corner (a typical situation in chicanes on many tracks) are very challenging for Aiden. You can use that, but take the recommendations of Aiden with a grain of salt here.

Good to know: If no sections are defined for the current track, the Driving Coach will try to derive sections automatically based on the lap telemetry data. I strongly recommend to define the sections manually, because this will yield the best results, but the automatically generated sections will provide a starting point. 

### Coaching on the track

Aiden can give you instructions and recommendations for the next corner while you are driving. You can enable this by a voice command, for example: "Can you give me instructions while I am driving?", or you can use the plugin action "TrackCoaching" on you your controller.

If activated, Aiden will use the telemetry data of the recent lap to check for any areas for improvement. Additionally, the lap before the last lap, or the fastest lap of the session so far can be used as a reference for braking points, start of the acceleration phase, and so on. It is also possible to load the [fastest lap stored in the "Session Database"](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Session-Database#laps), which will then be used as a reference lap unless you have driven a faster one in the current session. You configure the behaviour that suites you the most, by using the corresponding [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#race-settings) in the "Session Database".

Important: If you want to use a reference lap from the community database, you must identify this lap explicitely by name using the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#race-settings) in the "Session Database".

Please note, that the recommendations of Aiden might not be trustworthy, if no reference lap is available. Therefore, unless you have loaded a reference lap from the session database, take all recomendations for the first lap after Aiden has told you that telemetry data is available with a grain of salt.

If you approach a corner, Aiden will then evaluate possible areas for improvement and will give you the necessary instructions before you enter the corner. This instructions will be very short and focused and not so detailed with explanations as in the example conversation above, of course. You can configure the typical distance to the corner, where these instructions will be given also in the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#race-settings) in the "Session Database". However, sometimes Aiden will be late, espeutcially when the Spotter interrupted with an important message. Therefore, I recommend to do practice sessions with all other Assistants muted, which can be done with a Startup Profile, for example.

When working with the Driving Coach on track, it is quite important that you already have a quite consistent drving style. You must be able to apply recommended changes, for example to brake a bit earlier, but with less brake pressure when requested by Aiden. And you must be able to replicate that lap by lap, so that Aiden can evaluate the difference in corner performance when those changes are applied. If you do not already can drive with that consistency, you can still use the Driving Coach, of course, but you may get changing instructions each lap.

How the Driving Coach interprets the telemetry data and what instructions will be given by him is largely determined by the instructions. Especially the "Coaching.Corner.Approaching" instruction has a big influence. Let's have a look at the default instruction:

	Evaluate the data from the last lap below and take a look at corner %corner%.
	Tell me the twomost important areas for improvement for this particular corner.
	The shorter the time through the corner and the following section, the better.
	Only mention aspects that I can actually influence, such as braking point and
	brake pressure, start of acceleration, pedal and steering smoothness, line choice
	and so on. If the performance of the corner and the following section was already
	better than in the reference lap, mention only that. Keep your answer extremly short
	(around 25 to 35 words) without explanations and use the imperative.
	Think twice, before answering.
	
	%telemetry%

Important is here the restriction to a short message (25 to 35 words) and the focus on driver inputs. However, you can change that, if you want different corner hints from the Coach or longer explanations, for example. But bear in mind, that these instructions will be given while you are driving, so keeping them short might be a good idea. If you experiment with the length of the Coach's corner hints by increasing the number of words, for example, be sure to adjust the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#race-settings) "Coach: Time between Instructions" and "Coach: Distance before Corner" in the "Session Database" as well.

### Automatic activation of coaching mode

Normally you will only use the telemetry-based coaching during practice sessions. And maybe you want to have the coach on your side in each practice session. Always having to ask the coach to come along can become boring with time. But it is easy to automate that using the [*Reasoning* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#reasoning-booster).

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Driving%20Coach%20Startup.JPG)

If you want to use this for your own setup, here is the rule text, so you can copy it:

	{All: [?Session.Type = 2], {None: [?Coaching.Started]}} =>
			(Call: Assistant.Call(startTelemetryCoaching, false)), (Set: Coaching.Started),
			(Call: Assistant.Speak("Kim here. I'll start my computer. Run some warmup laps and then we will have a look at the telemetry."))

	[?Session.Type > 2] => (Call: Assistant.Call(finishTelemetryCoaching, false)), (Clear: Coaching.Started)

Replace "Kim" with the name of your Driving Coach.

Expert Notes: *startTelemetryCoaching* and *finishTelemetryCoaching* are methods of the *DrivingCoach* class, the session type **2** represents *practice*, **3** stands for *qualifying* and **4** for a *race* session, all values below **2** are for internal purposes.

Another and possibly easier way to automatically start telemtry-based coaching is by using the "On-track Coaching" function in a [startup profile](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Using-Simulator-Controller#startup-profiles). This will not only start the collection of telemetry data, but will also start on-track coaching, once telemetry data is available.

### Restricted mode without an LLM

As mentioned [above](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#using-the-driving-coach-without-an-llm), the Driving Coach can also be used without an LLM and will supply a basic and somewhat restricted support for on-track coaching. All the intelligence supplied by the LLM will be missing and the recommendations given by the coach will be very simple and kind of repetitve. Since this functionality uses a rule based approach when judging the performance of a given corner, it will only work when a reference with a better performance at that given point on the track is available.

## How it works

Beside using an LLM to interact with the driver, the Driving Coach uses the same rule-based AI engine as the other Assistants. Therefore, the Driving Coach has the same understanding of the current race situation as the other Assistants. As you already might have guessed, this knowledge is used to supply the data to the LLM using the [Instructions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#instructions) described above.

Unlike the other Assistants, whose knowledge base, i.e. their memory, is deleted at the end of a session, Aidens memory will still be around until the start of the next session. This makes it possible to analyze and discuss various aspects of the session with Aiden after the end of a session. This retained memory covers everything from the performance information like lap and sector times, as well as position information and also includes handling information, if this was enabled during the session.

The active coaching based on lap telemetry data deserves a more detailed explanation. The apporach to enable the Driving Coach to understand the telemetry data is a three step process. In the first step a special algorithm using an ML model identifies the most important driver input related variables that affect the time used through a part of the track based on the sections defined in the track map and extracts important high-level information from the raw telemetry data. This information is converted into a JSON format, which looks like this:

	{
	  "Driver": "Oliver Juwig",
	  "Lap": 3,
	  "MaxGear": 6,
	  "MaxLateralGForce": 2.66,
	  "MaxRPM": 7708,
	  "MaxSpeed": "244 km\/h",
	  "Sections": [
		{
		  "Apex": {
			"Duration": "0.85 Seconds",
			"Gear": 2,
			"LateralGForce": 1.16,
			"Length": "26.9 Meter",
			"Phase": "Rolling",
			"RPM": 4391,
			"Speed": "66 km\/h",
			"Start": "19457.9 Meter"
		  },
		  "Curvature": -2.39,
		  "Direction": "Right",
		  "Entry": {
			"ABSActivations": "Okay",
			"BrakeCorrections": 0,
			"BrakePressureRampUp": "35.2 Meter",
			"BrakeSmoothness": "Okay",
			"Duration": "2.43 Seconds",
			"Length": "207.6 Meter",
			"MaxBrakePressure": "89 Percent",
			"Phase": "Braking",
			"Start": "16557.4 Meter"
		  },
		  "Exit": {
			"Duration": "6.21 Seconds",
			"Gear": 2,
			"Length": "786.9 Meter",
			"Phase": "Accelerating",
			"RPM": 5151,
			"Speed": "161 km\/h",
			"Start": "16557.4 Meter",
			"TCActivations": "24 Percent",
			"ThrottleCorrections": 0,
			"ThrottleSmoothness": "Okay"
		  },
		  "Length": "1021.4 Meter",
		  "Nr": 2,
		  "SteeringCorrections": 7,
		  "SteeringSmoothness": "77 Percent",
		  "Time": "9.49 Seconds",
		  "Type": "Corner"
		},
		{
		  "Apex": {
			"Duration": "0.82 Seconds",
			"Gear": 3,
			"LateralGForce": 0.95,
			"Length": "11.8 Meter",
			"Phase": "Rolling",
			"RPM": 4931,
			"Speed": "99 km\/h",
			"Start": "29169.8 Meter"
		  },
		  "Curvature": -2.68,
		  "Direction": "Left",
		  "Entry": {
			"ABSActivations": "Okay",
			"BrakeCorrections": 1,
			"BrakePressureRampUp": "0.0 Meter",
			"BrakeSmoothness": "Okay",
			"Duration": "1.44 Seconds",
			"Length": "210.4 Meter",
			"MaxBrakePressure": "82 Percent",
			"Phase": "Braking",
			"Start": "26615.9 Meter"
		  },
		  "Exit": {
			"Duration": "2.05 Seconds",
			"Gear": 3,
			"Length": "271.8 Meter",
			"Phase": "Accelerating",
			"RPM": 5270,
			"Speed": "132 km\/h",
			"Start": "26615.9 Meter",
			"TCActivations": "Okay",
			"ThrottleCorrections": 0,
			"ThrottleSmoothness": "Okay"
		  },
		  "Length": "494.1 Meter",
		  "Nr": 2,
		  "SteeringCorrections": 0,
		  "SteeringSmoothness": "Okay",
		  "Time": "4.31 Seconds",
		  "Type": "Corner"
		},
		{
		  "AvgSpeed": "170 km\/h",
		  "Length": "196.0 Meter",
		  "MaxSpeed": "190 km\/h",
		  "MinSpeed": "134 km\/h",
		  "Time": "4.10 Seconds",
		  "Type": "Straight"
		}
	  ]
	}

In the second step a specialized set of rules in the [Rule Engine](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Rule-engine) converts this information into some high-level driver errors "Braking is too hard" (i.e. braking late with too much brake pressure thereby triggering accessive ABS activations). This information together with the above JSON object is then presented to the LLM of Aiden together with very detailed, context specific instructions and explanations. The instructions for the Driving Coach has already been discussed [above](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#instructions). Especially for the telemetry-based coaching they are very important, because they contain a lot of information about driving technique, which may not be available to a pre-trained LLM in this level of detail. The instructions are based on my own experiences for a smooth, natural and fast driving style. They are not suitable to become an alien, since this type of drivers typically are using special driving techniques that won't work in a real car and espcially not for the average driver, for example. However, you can change the instructions for Aiden, so that it steers you in a direction of any driving style, but this can be very time-consuming process. Welcome in the exciting world of [prompt engineering](https://en.wikipedia.org/wiki/Prompt_engineering).

Depending on the [race settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#race-settings) in the "Session Database", the performance of a given corner in the last lap will be compared to the same corner in a reference lap. If the performance in the reference lap was better, the Coach will instruct you to change your driver inputs to match the reference lap. The Coach will also kind of *experiment* with small variations in braking point, trail-braking, start of acceleration and so on to find the sweet spot for a given corner. Following these instruction will require a very consistent and repeatable driving style, of course.

### About attention deficits, hallucinations and other funny stuff

The Driving Coach does not tell you the truth all the time and occasionally even makes things up. Therefore always double check the recommendations and instructions given by the Coach against your own experiences and expectations. However, the deviations from the "truth" are sometimes very subtle and hard to detect. But what is the reason for this:

  1. A large language model simulates intelligence. Although it is doing this really well, the constant feedback loop of self-aware thinking is missing. An LLM does not really understand the topic it is talking about, it just derives the probability of words in the given context. Since there is also random factor in play (the *Creativity*, as defined in the configuration), it can happen, that an LLM creates answers that sound totally plausible, but are utterly wrong. If you encounter this too often, reduce the *Creativity* setting. This will reduce the variation in the answers of the model, but will also reduce hallucinations.
  
  2. LLMs, especially non-premium models, can also have something called attention deficit. They are not good in following multiple, mostly indepedent chain of thoughts at the same time. The Driving Coach is provided with a lot of data, when you interact with him. Standings, handling information, session and car state, telemetry information, just to name a few. It is therefore possible that the Coach is not using an important information, although it is available. Sometimes it helps in this case to tell the Coach that he has this informtion and he will work with it then.
  
  3. Especially in the case of telemetry-based coaching it is very important that the data quality is as good as it can get. The Coach will be provided with a high level condensed summary of the telemetry data (see above) to work with. To create this summary the telemetry data is split along the defined sections of the given track. If this sections are not well set, for example, if the car is already under full braking before the the corner starting point, the Coach will derive funny things from it. You have been warned...
  
In summary work with the Coach as you would work with ChatGPT. Always use your own brain as well. As LLMs get smarter, especially with the multi-level reasoning models like OpenAIs o1 or the upcoming o3, we will see big improvements here. With its architecture, Simulator Controller is prepared to participate from this development.

## Troubleshooting

For some tips n tricks for the best voice recognition experience, see the [corresponding chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Race-Engineer#troubleshooting) in the documentation of Jona.

A typical problem which shows up in conversations with Aiden, is, that the Driving Coach does not wait with its answer until you have finished your question. This happens especially, when you are formulating very long questions. In this case, use the *Push-To-Talk* method "Hold & Talk", which will prevent this.

Another important aspect is the support for different languages, which are in theory supported by Simulator Controller. Although an LLM can support multiple languages at the same time, only premium models and for the most part paid models have been trained with enough international data. Therefore I strongly recommend to use English as your conversation language with Aiden, especially when using a free or even an open souce model.

As said above, using the "Azure" or the "Google" voice recognition engine is strongly recommended, because of its superior quality. When using the "Dektop" service, which is builtin to the Windows operating system, you will encounter wrong recognitions here and there, esppecially when formulating long questions. To get the best recognition quality with the "Desktop" recognition engine, you can train your computer for your pronounciation. Follow the instructions found in the [Microsoft documentation](https://support.microsoft.com/en-us/windows/use-voice-recognition-in-windows-83ff75bd-63eb-0b6c-18d4-6fae94050571).