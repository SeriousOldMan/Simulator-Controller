Abaixo você encontrará uma lista completa de todos os comandos de voz reconhecidos por Aiden, o AI Driving Coach, juntamente com uma breve introdução à sintaxe das gramáticas de frases.

## Sintaxe

1. Caracteres reservados

   Os caracteres **[** **]** **{** **}** **(** **)** e o próprio **,** são todos caracteres especiais e não podem ser usados ​​como parte de palavras normais.

2. Frases

   Uma frase é parte de uma frase ou mesmo uma frase completa. Pode conter qualquer número de palavras separadas por espaços, mas nenhum dos caracteres reservados. Pode conter partes alternativas (diretas ou referenciadas pelo nome) conforme definido abaixo. Exemplos:

       Mary quer um sorvete

       (TellMe) seu nome?

       Qual é o horário { the, the current }?

   O primeiro exemplo é uma frase simples. O segundo permite escolhas conforme definido pela variável *TellMe* (veja abaixo), e o terceiro exemplo usa uma escolha local e significa "What is the time?" e "Qual é a hora atual?".

3. Escolhas

   Usando esta sintaxe, partes alternativas de uma frase podem ser definidas. (Sub-)frases alternativas devem ser delimitadas por **{** e **}** e devem ser separadas por vírgulas. Cada (sub-)frase pode conter apenas palavras simples. Exemplo:

       { pressões, pressões dos pneus }

   Se uma determinada lista de escolhas for usada em várias frases, uma variável pode ser definida para ela e uma referência de variável (o nome da lista de escolhas delimitada por **(** e **)**) pode ser usada em vez da sintaxe explícita. Todas as escolhas predefinidas são listadas na seção "[Choices]" do [arquivo de gramática](https://github.com/SeriousOldMan/Simulator-Controller/blob/main/Sources/Assistants/Grammars/Choices.pt) e se parecem com isto:

       TellMe=Você poderia me contar, Por favor me conte, Conte-me, Você pode me dar, Por favor me dê, Me dê

   Esta lista de escolhas predefinidas pode ser referenciada usando *(TellMe)* como parte de uma frase.

4. Comandos

   Um comando completo é uma frase conforme definido acima ou uma lista de frases separadas por vírgulas e colocadas entre **[** e **]**. Cada uma dessas frases pode disparar o comando por si só. Exemplos:

       (WhatAre) {as pressões dos pneus, as pressões atuais dos pneus, as pressões nos pneus}

       [(TellMe) a hora, Que horas são, Qual é a {hora atual, hora}]

   O primeiro exemplo é uma única frase, mas com escolhas internas (alternativas). O segundo exemplo define três frases independentes para o comando, mesmo com escolhas internas.

## Comandos

#### Predefined Choices

TellMe=Você pode me dizer, Você pode me falar, Por favor me diga, Por favor me fale, Diga-me, Me diga, Me fala, Você pode me dar, Por favor me dê, Me dê

WhatAre=Diga-me, Me diga, Me dê, Quais são, Quais são os

WhatIs=Diga-me, Me diga, Me dê, O que é, Qual é

CanYou=Você pode, Pode, Podemos, Por favor

CanWe=Você pode, Pode, Podemos, Por favor

Information=informações da sessão, informações do stint, informações de pilotagem

#### Comandos

1. Conversação

   [{Oi, Ei, Olá} %name%, %name% você me ouve, %name% está me ouvindo, %name% preciso de você, %name% onde você está, %name% responde por favor, %name% fala comigo]

   [Sim {por favor, claro}, {Sim, Perfeito} continue, {Pode, Ok} {continuar, continuar por favor, seguir, seguir por favor}, Pode falar, Prossiga, Concordo, Certo, Correto, Confirmado, Eu confirmo, Afirmativo]

   [Não {obrigado, não agora, eu te chamo mais tarde}, Agora não, Não no momento, Negativo]

   [(CanYou) me contar uma piada, Você tem uma piada para mim, (CanYou) me dizer uma piada]

   [Cale-se, Silêncio por favor, Fique quieto por favor, Preciso me concentrar, Preciso focar agora, Eu {preciso, devo} focar agora]

   [Ok, você pode falar, Tudo bem, pode falar, Posso ouvir {agora, de novo}, Você pode falar {agora, de novo}, Mantenha-me {informado, atualizado, a par}, Pode voltar a falar]

   [{Por favor, ignore, Ignore} (Information), {Por favor, não considere, Não considere} mais (Information), Sem mais (Information), Sem mais (Information) por favor]

   [{Por favor, considere, Considere} (Information) novamente, {Por favor, volte a considerar, Volte a considerar} (Information), {Por favor, me dê, Me dê} (Information), Leve (Information) em {consideração, conta}]

2. Informação

   [(TellMe) o horário, (TellMe) as horas, Que horas são, Qual é o {horário atual, horário}]
	
3. Treinamento

   [(CanYou) me dar {treinamento, coaching, uma sessão de coaching}, (CanWe) fazer uma sessão de {coaching, treino, prática}, (CanYou) {me ajudar, ajudar} com {o meu treino, a minha prática, a minha pilotagem}, (CanYou) {observar, acompanhar} {o meu treino, a minha prática, a minha pilotagem}, (CanYou) {avaliar, observar} a minha técnica de pilotagem, (CanWe) melhorar minhas habilidades de pilotagem]

   [Obrigado {pela ajuda, aprendi muito, isso foi ótimo}, Isso foi ótimo, obrigado, Ok, já chega por hoje, Por hoje já está bom]

   [(CanYou) me dar {uma visão geral, uma visão geral curva por curva, uma visão geral da volta inteira, uma visão completa, uma visão completa curva por curva}, {Por favor, dê, Dê} uma olhada na {volta completa, pista toda}, Onde posso melhorar na pista]

   [(CanWe) {focar na, falar sobre a} {curva número, curva} (Number), {Por favor, dê, Dê} uma {olhada mais de perto, olhada} na {curva, curva número} (Number), Onde posso melhorar na {curva, curva número} (Number), O que devo considerar na {curva, curva número} (Number), O que devo observar na {curva, curva número} (Number)]

   [(CanYou) me dar {recomendações, dicas, instruções, orientação} {enquanto eu estiver dirigindo, durante a pilotagem, para cada curva}, {Por favor, me diga, Diga} {antes de, para} cada {curva, trecho} o que eu {posso, devo} mudar, (CanYou) me treinar {na pista, enquanto eu estiver dirigindo, durante a pilotagem}]

   [(CanYou) me dizer onde estão os pontos de frenagem, {Por favor, me diga, Diga} onde frear, (CanWe) praticar {frenagem, pontos de frenagem}]

   [{Obrigado, Agora} quero focar, {Ok, Deixa} eu {aplicar, testar} {suas recomendações, suas instruções, isso} agora, {Por favor, pare, Pare} de me dar {recomendações, dicas, instruções, recomendações para cada curva, dicas para cada curva, instruções para cada curva}, {Por favor, sem, Sem} mais {instruções, instruções por favor}]

   [(CanWe) usar a volta {mais rápida, última} como {referência, volta de referência}, {Por favor, use, Use} a volta {mais rápida, última} como {referência, volta de referência}]

   [{Por favor, não, Não} usar volta de {referência, referência por favor}]

   [(CanWe) {focar na, praticar a} {curva, curva número} (Number), Vamos {focar na, praticar a} {curva, curva número} (Number), (CanYou) me dar {recomendações, dicas, instruções, orientação} para a {curva, curva número} (Number)]

   [(CanWe) {focar, voltar a focar} na pista toda, Vamos {focar, voltar a focar} na pista toda]

#### Conversa

Além disso, você pode ter uma conversa gratuita com o Driving Coach na maior parte do tempo. Portanto, todo comando de voz que não corresponder a nenhum dos comandos mostrados acima será encaminhado para o modelo de linguagem GPT, o que resultará em um diálogo semelhante ao humano, conforme mostrado no [exemplo](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#a-typical-dialog).