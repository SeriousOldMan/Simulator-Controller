## Introduction

Simulator Controller allows you to use current GPT technologies and the so called large language models (aka LLM) for various purposes. For the full functionality of the [Driving Coach](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach) it is even required to configure and connect a LLM. All other Assistants can optionally be extended with LLMs for a [better conversation experience](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#rephrasing-booster) and you can even use LLMs to extend the reasoning capabilities by adding a LLM, which is decribed [here](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#reasoning-booster). And there are other components and tools of Simulator Controller where you can use a LLM.

All this requires you to choose and connect to a large language model. Simulator Controller does not provide its own LLM, of course. And this is even not necessary, since there are a hundreds of very good models available in the Open Source (see the [Hugging Face website](https://huggingface.co/) for a complete overview what's available). And there are commercial models available as well, first and foremost from OpenAI, the company, that created the famous ChatGPT solutions. Simulator Controller uses API calls to use the services provided by an existing GPT engine to run the LLM, or you can use the integrated "LLM Runtime", to run everything on your own PC, as long as your machine is powerful enough.

As said, the most capable current LLMs (aka large language models) are provided by companies like OpenAI or Anthropic, as you probably know. Most providers implement an HTTP API to connect to these models. This comes with some costs, but these are negligible. I accumulated costs of about 20 Cent at the time of this writing and I have run hours of interactions already. Many OpenAI LLMs are also available in the Azure cloud, in the end a matter of taste which one to use. Another interesting provider is Mistral AI, the European alternative to OpenAI. Not forget to mention Google, which recently made great progress with their Gemini models, of which some are available free of charge. Or you can use OpenRouter, which provides access to many models of different providers, or even from the Open Source. And there is also an open GPT runtime platform, which can host a vast variety of LLMs developed by universities or less knwon companies. This runtime, named Ollama, is free and the models can be run on your local PC. But be aware that running a LLM locally on your PC is a very demanding task and may not be possible in parallel to a running simulation, even if your GPU has enough memory.

The performance and - even more important - the knowledge about the motorsport domain varies between different models. I have made good experience with different models from OpenAI and Anthropic. Models from the Open Source are a bit more restricted. In the end, you may want to experiment by yourself, but I recommend "GPT 5.4 mini" as a starting point at the time of this writing. Using LLMs for non-English conversation is a different story. In this case, you will notice, that models from the Open Source will not deliver good results in most cases.

### Generic

The first one supports any GPT service provider, which implements the JSON-based API specification defined by OpenAI (see next entry). You have to provide the complete chat API endpoint in the "URL", which typically ends to ".../chat/completions". In most cases, you will see no models in the "Model" drop down field, unless the model list endpoint follows the same naming rules as OpenAI itself. If no models are shown in the drop down list, enter the name of the model you want to use into the field manually.

Many GPT service providers implement the OpenAI protocol, which had become the industry standard. A good example here is [DeepSeek](https://deepseek.com/), the leading GPT provider from China, which offers premium quality at a very low price point.

### OpenAI

When you have chosen OpenAI, you will have to create an account on [OpenAI](https://openai.com). You will have to invest a couple of bucks to charge up your account - $5 will be more than enough. Follow these steps:

1. Create an account on [openai.com](https://openai.com).
2. Goto the [platform page](https://platform.openai.com/) and select the "Manage account" from your account menu. There you can add a payment in the billing section.
3. Select [API keys](https://platform.openai.com/account/api-keys) in the sidebar menu. There you can create your sectret key.
4. Note down this key, since you will have to enter it into the configuration, where you want to use the LLM.

### Azure

Because of the intensive collaboration between OpenAI and Microsoft, many OpenAI models are also available on the Azure Cloud. The performance is a little better, the cost is a little higher. In order to gain access to OpenAI models in the Azure Cloud, an entry must be made in the Azure Console, but this is usually approved. After approval you can get an communication endpoint and API key which then must be used in the configuration. You also must note down your Azure service endpoint, which must be inserted in the "Service URL" field in the configuration.

### Anthropic

Very similar to OpenAI. Create an account on [Anthropic](https://platform.claude.com/). Anthropic offers with the *Claude* models exceptional performance for reasoning and agent processing. Therefore, it is a good candidate for the *Reasoning* booster. To get the best out of this, the native API (aka the *Messages* API) of Anthropic is used, when using this GPT provider.

### Mistral AI

Also very similar to OpenAI. Create an account on [Mistral AI](https://console.mistral.ai/). You will have to register your credit card, but you will only be charged for usage, which is very, very cheap for the Open Weight models. Then create an API key and include it in the configuration as described above. I recommend using the Open Mixtral 8x22b model for the start, which has the best price / performance ratio.

### Google

Google has added support for OpenAI-style REST/JSON access to their API. Create an account on [Google AI Studio](https://aistudio.google.com). You may have to register your credit card (depending on usage - see below). Then create an API key and include it in the configuration as described above. I recommend using the "Gemini 2.0 Flash-Lite" model for the start, which has the best price / performance ratio. Google currently offers a free tier which includes a rate limit with 30 requests per minute and a max of 1500 requests per day for the "Gemini 2.0 Flash-Lite" model. You don't even have to register a credit card for the free tier access.

### Yandex

Yandex, a Russian search engine and cloud service provider, also offers several GPT models, which excel especially in the Russian language. An account can be created on the [Yandex AI Studio](https://aistudio.yandex.ru/). You have to register a payment method, then create an API key. It is important to create a so called *service* account, otherwise the API key cannot be used for Simulator Controller. Then choose a model from the this [list](https://aistudio.yandex.ru/docs/en/ai-studio/concepts/generation/models.html) and make sure that it is marked as "OpenAI-compatible".

### OpenRouter

[OpenRouter](https://openrouter.ai) is a kind of gateway and hosting environment for many models of different providers, even many source LLMs are available here. It has become my favorite provider in the sense of a one-stop-shop for LLM access. You have to buy a few credits (5$ at least) [here](https://openrouter.ai/credits), before you can use the service. Then create an API key in your user account and include it in the configuration as described above. The last step is to choose the model you want to use from the very long list [here](https://openrouter.ai/models). There are even models available, which do not create any costs when called through the API, like the "meta-llama/llama-3-8b-instruct:free". But as mentioned above, the performance and domain knowledge might not meet your expectations.

### Ollama

Ollama is a free GPT server, which can be run anywhere, including your local PC. It can be downloaded from the [Ollama webiste](https://ollama.com/) for different operating systems incl. Windows. The websste also provides downloads for several LLMs, but you can also use models from other sources.

Documentation for installation and setup can be found on the [Github page](https://github.com/ollama/ollama). Although Ollama is a very powerful solution for setting up your own LLM server, it requires a lot of technical skills and is therefore not for everyone. For a more simple and easy-to-use solution see the next section.

### GPT4All

The alternative, GPT4ALL, can be downloaded from the corresponding [website](https://gpt4all.io/index.html). Install it on your PC and enable the API server in the settings. Additionally you will have to download and install one or more models, which can be done from inside the application window. At the time of this writing, the model *Wizard 1.2* is a very good allround model. In fact you can use any model in the GGUF format supported by Llama, not only the models provided on the GPT4All website.

Please be aware, that running a GPT4All locally puts heavy load on your PC and can use quite a lot of memory (even from your GPU). Therefore do not ask any questions while driving, unless you have a really powerful configuration. Even if your PC is idle, the answer will take some time to be generated, so be patient.

> ###### Important
>
> At the time of this writing, the integrated REST API of the GPT4All chat client is under heavy development and cannot be considered final or even stable. If you have issues establishing a connection to the local GPT4All HTTP server, take a look at this [article on GitHub](https://github.com/nomic-ai/gpt4all/issues/934). As an alternative, you can either setup a dedicated API server for GPT4All, even on a different machine, if you are a seasoned developer, or you check out the next option.

### LLM Runtime

This one implements an embedded runtime engine for large language models. You do not even have to install GPT4All or Ollama on your PC, for example, everything is already integrated into Simulator Controller. But since this runtime is quite big (several hundered MB), it must be installed as additional DLC (open "Simulator Setup", go to the Presets page and install the "Local Runtime for LLMs" package).

Additional installation reequirements:

- You have to make sure that the Microsoft .NET Runtime version 10.0 or higher is installed on your system. You can download the installer for this runtime from [this Microsoft page](https://dotnet.microsoft.com/en-us/download/dotnet/10.0).
- The local LLM Runtime supports model execution on Nvidia GPUs using Cuda 11 or Cuda 12. To use CUDA for execution of the LLM on the GPU, you have to install the [CUDA drivers](https://developer.nvidia.com/cuda-12-1-0-download-archive?target_os=Windows) from the Nvidia homepage. Install only CUDA, all the other stuff should already be there with your standard Nvidia driver. Vulkan support for other GPU brands is included as well. Of course, the different AVX specifications are supported for CPU execution. For AMD GPUs, Vulkan drivers are supported, but you may also use CUDA as described [here](https://www.xda-developers.com/nvidia-cuda-amd-zluda/).

  > ###### Important
  >
  > It can happen, that the Vulkan driver support conflicts with CUDA on Nvidia GPUs. If this is the case, you will get an error message like "I am on the other line, please come back in a minute." by the Coach, for example. To fix this, remove the *vulkan* folder from the *Simulator Controller\Programs\LLM Runtime\runtimes\win-x64\native* folder in your user *Documents* folder.

You also have to download a LLM. Make sure the model is in GGUF file format. You can find good models on the [GPT4All website](https://gpt4all.io/index.html) or on the [Hugging Face website](https://huggingface.co/), the largest community for AI development world wide. I recommend starting with *Wizard 1.2* (["wizardlm-13b-v1.2.Q4_0.gguf"](https://gpt4all.io/models/gguf/wizardlm-13b-v1.2.Q4_0.gguf)), which is a very good allround model. Another very good model at the time of this writing is *Hermes* (["nous-hermes-llama2-13b.Q4_0.gguf"](https://gpt4all.io/models/gguf/nous-hermes-llama2-13b.Q4_0.gguf)). Both models consume up to 16GB of RAM, so you need to have at least 32 GB RAM in your machine. There are also some smaller models available on the GPT4All website, but their knowledge about our domain is very limited.

Once you have selected and downloaded a model, enter the full path to the model file into the "Model" field and your done. And you can specify, how many layers of the model would be executed on your graphics card, which of course requires that the GPU can provide the amount of memory to the model. This might need some try and errors, until you find a suitable configuration, which also allows you to still run your favorite simulator. Additional settings are available for experts in the [core settings](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Core-Settings#llm-settings). Be sure what you are doing when changing them. Normally, you only want to change the "Threads" setting, when you encounter heavy stutter, when the LLM Runtime is using the CPU. As a general rule of thumb, set the number of threads to (number of cores / 2) for a CPU with more than 8 cores and to (number of cores / 4) for a CPU with less than 8 cores, if you encounter stutter.

> ###### Good to know
>
> The LLM Runtime supports tool/function calling which is required to trigger actions in the [*Conversation* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#conversation-booster) or even use a LLM for the [*Reasoning* booster](https://github.com/SeriousOldMan/Simulator-Controller/wiki/Customizing-Assistants#reasoning-booster). But not every LLM can handle tool calls, therefore check the model card on the the [Hugging Face website](https://huggingface.co/). It is normally mentioned there, whether a given model supports tool calling. In general, you will need models with at least 13B parameters and a decent quantization.

Please be aware, that running a large language model locally puts heavy load on your PC and can use quite a lot of memory (even from your GPU). Therefore do not ask any questions while driving, unless you have a really powerful configuration. Even if your PC is idle, the answer will take some time to be generated, so be patient.