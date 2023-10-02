## Introduction

Aiden, The Virtual Driving Coach, is a fully AI based chatbot which plays the role of your personal driving coach. Using state of the art AI techniques (GPT = generative pretrained transformers) using an LLM (aka large language models), the Virtual Driving Coach behaves and interacts as natural as possible. It depends heavily on the concrete LLM which is used, what knowledge is available about the race driving topic and how detailed this knowledge is. Modern LLMs, like GPT 3 or GOT 4 are actually very good even in this very special domain.

Simulator Controller does not implement its own GPT engine, of course. And this is even not necessary, since there are a couple of service providers available, first and foremost OpenAI, the company, that created the famous ChatGPT solutions. Rather, Simulator Controller uses API calls to use the services provided by an existing GPT engine to run the LLM used by Aiden. You can choose in the configuration which provider is used and even which LLM you want to use (see below in the chapter about [configuration](*).

Notes: The initial version of Aiden does not know much about your concrete driving situation like the details of the current session, if any, or the telemetry data of your car. Therefore you can expect only quite general information, unless you provide the relevant context information on your own (see below). However, this will change with future versions, so that Aiden will automatically have as much context information as possible. Especially the GPT-4 LLM provide excellent capabilities to work with data and even is able to call functions in the caller environment to get access to extended information. Using this integration, the Virtual Driving Coach will be able to give you very concrete tips to improve your driving skills, your car setup or the strategy of the current race.

But before we proceed to the details of the configruation and the rules how to interact with your personal Driving Coach, let's take a look at a typical interaction with Aiden.
 
### A typical dialog

## Installation

Installation requires you to choose one of the supported large language model providers. The most capable current LLMs (aka large language models) are provided by the company OpenAI, as you probably know. OpenAI provides an HTTP API to connect to these models. This comes with some costs, but these are negligible. I accumulated costs of about 20 Cent at the time of this writing and I have run hours of interactions already. But there is also an open GPT runtime platform, which can host a vast variety of LLMs developed by universities or less knwon companies. This runtime, named GPT4All, is free and the models can be run on your local PC. But be aware that running an LLM locally on your PC is a very demanding taks and will not be possible in parallel to a running simulation, even if your GPU has enough memory.

### OpenAI

When you have chosen OpenAI, which I recommend, you will have to create an account on [OpenAI](https://openai.com). You will have to invest a couple of bucks to charge up your account - $5 will be more than enough. Tnen create an API key, which you can use to establish a connection. Note down this key, since you will have to enter it into the configuration of the Virtual Driving Coach.

### GPT4All

The alternative, GPT4ALL, can be downloaded from the corresponding [website](https://gpt4all.io/index.html). Install it on your PC and enable the API server in the settings. Additionally you will have to download and install one or more models, which can be done from inside the application window. At the time of this writing, the model *Wizard 1.1* ("wizardlm-13b-v1.1-superhot-8k.ggmlv3.q4_0.bin") is a very good allround model.

Important: If you have issues establishing a connection to the local GPT4All HTTP server, take a look at this [article on GitHub](https://github.com/nomic-ai/gpt4all/issues/934).

### Configuration

The next step is to setup everything in the configuration, either in "Simulator Setup" or "Simulator Configuration". Please follow the instructions in the [Installation & Configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-driving-coach) chapter.

![](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Docs/Images/Configuration%20Tab%2012.JPG)

Since the voice recognition quality is so important for a correct dialog with Aiden, I strongly recommend to use the "Azure" voice recognition engine. The "Desktop" engine may be used as well, especially, when you are using a high quality headset. And use the training mode of the Windows speech recognition, which is available in the Windows Settings -> Time & Language -> Speech  page.

## Interacting with Aiden

Since an interaction with Aiden always is kind of a free dialog, the only way to interact with Aiden is through voice. Simply call your coach, for example with "Hey Aiden", and then formulate your first question. And here the fun begins. Interacting with an LLM feels like a natural human-2-human interaction, but you need to follow some rules to get the information you want:

1. Be as specific as possible
   Asking "What can you tell me about trailbraking" will at best give you a long essay about this topic. A better question will be "I have problems with trailbraking. How can I improve it?"

2. Give as much context as you have
   It is important that your coach knows as much about the background of your current situation and the purpose of your question as possible. Give this information as early as possible.
   
   Most of the context information is provided in the initial default instructions (see the [configuration](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Installation-&-Configuration#tab-driving-coach) for more information how to provide these instructions). But you may have individual context information, which you can provide **before** your question. Example: "I am driving a Mercedes AMG GT3, which has a front motor. I have severe problems with understeering. How should I adopt my drving technique? And how can I setup the car to counteract this?"

3. Don't hesitate to ask for more specific information
   LLM based chat bots tend to give more general information in their first answer, but you can always guide them to more specific answers with follow up questions.

4. Give instructions how the answer should look like
   LLMs *understand* instructions like "Keep it short." or "Don't be so formal."

5. Rephrase your questions
   If Aiden still resists to give you the desired answer, you can try to rephrase your question. Sometimes using a different word, a synonym, will do the job.

The above list are only few of the rules to follow, though the most important ones, when working with an LLM based AI. There are many good articles on te web about the so called *prompt engineering*, which can give you further hints.

## Troubleshooting

https://support.microsoft.com/en-us/windows/use-voice-recognition-in-windows-83ff75bd-63eb-0b6c-18d4-6fae94050571