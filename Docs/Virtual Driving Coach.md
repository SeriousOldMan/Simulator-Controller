## Introduction

Aiden, The Virtual Driving Coach, is a fully AI based chatbot which plays the role of your personal driving coach. Implemented with state of the art AI technologiy GPT (aka generative pretrained transformer) using an LLM (aka large language model), the Virtual Driving Coach behaves and interacts as natural as possible. It depends heavily on the concrete LLM which is used, what knowledge is available about the race driving topic and how detailed this knowledge is. Modern LLMs, like GPT 3 or GOT 4 are actually very good even in this very special domain.

Simulator Controller does not implement its own GPT engine, of course. And this is even not necessary, since there are a couple of service providers available, first and foremost OpenAI, the company, that created the famous ChatGPT solutions. Rather, Simulator Controller uses API calls to use the services provided by an existing GPT engine to run the LLM used by Aiden. You can choose in the configuration which provider is used and even which LLM you want to use (see below in the chapter about [configuration](*).

Notes: The initial version of Aiden does not know much about your concrete driving situation like the details of the current session, if any, or the telemetry data of your car. Therefore you can expect only quite general information, unless you provide the relevant context information on your own (see below). However, this will change with future versions, so that Aiden will automatically have as much context information as possible. Especially the GPT-4 LLM provide excellent capabilities to work with data and even is able to call functions in the caller environment to get access to extended information. Using this integration, the Virtual Driving Coach will be able to give you very concrete tips to improve your driving skills, your car setup or the strategy of the current race.

But before we proceed to the details of the configruation and the rules how to interact with your personal Driving Coach, let's take a look at a typical interaction with Aiden.
 
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

Installation requires you to choose one of the supported large language model providers. The most capable current LLMs (aka large language models) are provided by the company OpenAI, as you probably know. OpenAI provides an HTTP API to connect to these models. This comes with some costs, but these are negligible. I accumulated costs of about 20 Cent at the time of this writing and I have run hours of interactions already. Most OpenAI LLMs are also available in the Azure cloud, in the end a matter of taste which one to use. And there is also an open GPT runtime platform, which can host a vast variety of LLMs developed by universities or less knwon companies. This runtime, named GPT4All, is free and the models can be run on your local PC. But be aware that running an LLM locally on your PC is a very demanding taks and will not be possible in parallel to a running simulation, even if your GPU has enough memory.

### OpenAI

When you have chosen OpenAI, which I recommend, you will have to create an account on [OpenAI](https://openai.com). You will have to invest a couple of bucks to charge up your account - $5 will be more than enough. Follow these steps:

1. Create an account on [openai.com](https://openai.com).
2. Goto the [platform page](https://platform.openai.com/) and select the "Manage account" from your account menu. There you can add a payment in the billing section.
3. Select [API keys](https://platform.openai.com/account/api-keys) in the sidebar menu. There you can create your sectret key.
4. Note down this key, since you will have to enter it into the configuration of the Virtual Driving Coach.

### Azure

Thanks to the intensive collaboration between OpenAI and Microsoft, many OpenAI models are also available on the Azure Cloud. The performance is a little better, the cost is a little higher. In order to gain access to OpenAI models in the Azure Cloud, an entry must be made in the Azure Console, but this is usually approved. After approval you can get an communication endpoint and API key which then must be used in the configuration of the Virtual Driving Coach. You also must note down your Azure service endpoint, which must be inserted in the "Service URL" field in the configuration.

### GPT4All

The alternative, GPT4ALL, can be downloaded from the corresponding [website](https://gpt4all.io/index.html). Install it on your PC and enable the API server in the settings. Additionally you will have to download and install one or more models, which can be done from inside the application window. At the time of this writing, the model *Wizard 1.2* is a very good allround model. In fact you can use any model in the GGUF format supported by Llama, not only the models provided on the GPT4All website.

Please be aware, that running a GPT4All locally puts heavy load on your PC and can use quite a lot of memory (even from your GPU). Therefore do not ask any questions while driving, unless you have a really powerful configuration. Even if your PC is idle, the answer will take some time to be generated, so be patient.

IMPORTANT: At the time of this writing, the integrated REST API of the GPT4All chat client is under heavy development and cannot be considered final or even stable. If you have issues establishing a connection to the local GPT4All HTTP server, take a look at this [article on GitHub](https://github.com/nomic-ai/gpt4all/issues/934). As an alternative, you can either setup a dedicated API server for GPT4All, even on a different machine, if you are a seasoned developer, or you check out the next option.

### LLM Runtime

This one implements an embedded runtime engine for large language models. You do not even have to install GPT4All on your PC, for example, everything is already integrated into Simulator Controller. You only have to download one of the LLMs from the [GPT4All website](https://gpt4all.io/index.html) or from another source. I recommend here also the model *Wizard 1.2* (["wizardlm-13b-v1.2.Q4_0.gguf"](https://gpt4all.io/models/gguf/wizardlm-13b-v1.2.Q4_0.gguf)), which is a very good allround model. Another very good model at the time of this writing is *Hermes* (["nous-hermes-llama2-13b.Q4_0.gguf"](https://gpt4all.io/models/gguf/nous-hermes-llama2-13b.Q4_0.gguf)). Both models consume up to 16GB of RAM, so you need to have at least 32 GB RAM in your machine. There are also some smaller models available on the GPT4All website, but theier knowledge about our domain is very limited. In fact you can use any model in the GGUF format supported by the Llama runtime, not only the models provided on the GPT4All website, so also take a look what's available at the [Hugging Face website](https://huggingface.co/), the largest community for AI development world wide. Once you have selected and download a model, enter the full path to the model file into the "Model" field and your done.

Please be aware, that running a large language model locally puts heavy load on your PC and can use quite a lot of memory (even from your GPU). Therefore do not ask any questions while driving, unless you have a really powerful configuration. Even if your PC is idle, the answer will take some time to be generated, so be patient.

## Configuration

The next step is to setup everything in the configuration, either in "Simulator Setup" or "Simulator Configuration". Please follow the instructions in the [Installation & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-driving-coach) chapter.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%2012.JPG)

Since the voice recognition quality is so important for a correct dialog with Aiden, I strongly recommend to use the "Azure" voice recognition engine. The "Desktop" engine may be used as well, especially, when you are using a high quality headset. And use the training mode of the Windows speech recognition, which is available in the Windows Settings -> Time & Language -> Speech  page.

### Instructions

A very important aspect in the configuration of the Driving Coach are the so called instructions. Instructions provide the LLM with important context information and specifies, how it should react to your questions. It also defines the profession and personality of the Driving Coach. Last but not least, instructions are also used to convey data from your current session in a running simulator to the Driving Coach.

Simulator Controller provide default instructions for all supported languages and instruction categories, but you are free to create your own instructions. Please note, that the default instructions are optimized for OpenAI language models. If you are using LLMs provided by GPT4All, you may have to adopt or totally rewrite the default instructions to work with the chosen model.

Instructions support embedded variables. These variables are automatically replaced with information about the currently running simulation, your progress in the current race, or handling issues, and so on. Whether or not the Driving Coach will understand and use this information will heavily depend on the model and the current context of your discussion with the coach. But you may be successful in most cases by explicitly asking the Driving Coach to take a look at the supplied data.

Below you find all instruction categories and the supported variables:

| Instruction | What              | Description |
|-------------|-------------------|-------------|
| Character   | Scope             | This instruction is used always and must define the profession and the personality of the Driving Coach. You can also give general instructions like "Keep your answers short and precise". The default instruction creates a driving coach specialized in car handling and car physics. |
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
| Handling    | Scope             | This instruction is used only when handling problems had been detected in the telemetry. See the chapter below about detecting handling problems and discussin them with Aiden. |
|             | %handling%        | An enumeration of all detected handing problems. See the [dedicated chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#detecting-and-discussing-handling-problems) below for more information. |

As said, all instructions can be modified in the configuration. You can even clear a complete instruction, if you want (and don't want to dicuss the corresponding information with Aiden). I do not recommend to clear the "Character" instruction, though.

IMPORTANT: Depending on the configuration, especially the chosen model and also the "# Tokens", you may encounter problems with very complex input, for example a longer race with many recorded handling issues. In this case, Aiden will refuse to give you answer with a stupic excuse. That means, that the GPT service returned with an error code, typically meaning that the input area of the LLM was too small. Never happened for me with the GPT-4 model with "# MaxTokens" set to 2048, though, but happened a couple of times using the *smaller* models.

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

The Driving Coach will try to detect possible handling problems using the same mechanism used by the "Setup Workbench". In fact, Aiden uses the same [Telemetry Analyzer](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Setup-Workbench#real-time-telemetry-analyzer) as the "Setup Workbench" and will use the same settings and thresholds you have selected for the same car and track last time. Therefore, if you want to discuss your handling issues with Aiden, be sure to have created a valid or even calibrated configuration in the Telemetry Analyzer for the given car and track.

When at least one handling issue had been detected, the "Handling" instruction will be used to describe the handling issues to the Driving Coach. Each issue will be described on a single line in the instructions. Example:
 
	- Heavy Understeer on Slow corner Entry
	
Using this knowledge, Aiden should be able to give you information how to cope with the given handling issues, for example by changing your driver inputs or changes to the car setup.

Information: You can disable this instruction (and every other instruction as well) completely, by clearing it in the configuration, if you don't want Aiden to give you information regarding handling problems. If you want to temporarily enable or disable it during a running session, you can use the voice commands below.

### List of all voice commands

1. [English version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Driving-Coach-Commands-(EN))

2. [German version](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Driving-Coach-Commands-(DE))

Normal you will use free conversation to interact with Aiden as shown in the example above. But there are also a couple of predefined grammar based commands available, for example to enable or disable the processing of specific information (see below in the next section). You will always find the current version of the grammar files as actually used by the software in the *Resources\Grammars* folder of the Simulator Controller distribution. Or you can take a look at the files in the [Resources\Grammars directory on GitHub](https://github.com/SeriousOldMan/Simulator-Controller/tree/main/Resources/Grammars), for example the German version [Driving Coach.grammars.de](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Resources/Grammars/Driving%20Coach.grammars.de).

### Enabling and disabling specific instructions and information processing 

As discussed above Aiden can process information about your current session in a simulation. This includes specific data about your own performance and the preformance of your competitors, as well as information about your recent handling issues. Since the processing of this data may sometimes confuse the AI behind the Driving Coach. Therefore you may disable specific information processing by using a special voice command:

	[Please] do not pay attention *information* anymore [please]

As you might expect, the word "please" is optional. Available options for *information* are: "session information", "stint information", "handling information". These options resemble, as you already may have recognized, the instructions discussed above. After you have disabled one of the information processings (all are enabled by default), you can reenable it with the following command:

	[Please] pay attention to *information* again [please]

### How it works

Beside using an LLM to interact with the driver, the Driving Coach uses the same rule-based AI engine as the other Assistants. Therefore, the Driving Coach has the same understanding of the current race situation as the other Assistants. As you already might have guessed, this knowledge is used to supply the data to the LLM using the [Instructions](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Driving-Coach#instructions) described above.

Unlike the other assistants, whose knowledge base, i.e. their memory, is deleted at the end of a session, with Aiden this remains until the start of the next session. This makes it possible to analyze and discuss various aspects of the session with Aiden after the end of a session. This retained memory covers everything from the performance information like lap and sector times, as well as position information and also includes handling information, if this was enabled during the session.
 
## Troubleshooting

For some tips n tricks for the best voice recognition experience, see the [corresponding chapter](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Engineer#troubleshooting) in the documentation of Jona.

A typical problem, which might happen, is that the Driving Coach does not wait with its answer until you have finished your question. This happens especially, when you are formulating very long questions. In this case, use the *Push-To-Talk* method "Hold & Press", which will prevent this.

As said above, using the "Azure" voice recognition engine is strongly recommend, because of its superior quality. When using the "Dektop" service, which is builtin to the Windows operating system, you will encounter wrong recognitions here and there, esppecially when formulating long questions. To get the best recognition quality with the "Desktop" recognition engine, you can train your computer for your pronounciation. Follow the instructions found in the [Microsoft documentation](https://support.microsoft.com/en-us/windows/use-voice-recognition-in-windows-83ff75bd-63eb-0b6c-18d4-6fae94050571).