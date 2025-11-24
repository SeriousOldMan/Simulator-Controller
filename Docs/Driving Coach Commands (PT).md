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

TellMe=Você poderia me contar, Por favor me conte, Conte-me, Você pode me dar, Por favor me dê, Me dê

WhatAre=Conte-me, O que são

WhatIs=Conte-me, O que é, Fale sobre

CanYou=Você pode

CanWe=Podemos

Information=informações da sessão, informações do stint, informações de manuseio

#### Comandos

1. Conversação

   [{Hi, Hey} %name%, %name% Esta me ouvindo?, %name% Eu preciso de você, %name% Estou em casa, %name% Entre, por favor]

   [Sim {por favor, claro}, {perfeito} prossiga, {Vai, Ok vai} {sobre, por favor, à frente}, Concordo, Certo, Correto, Confirmado, Confirmo, Afirmativo]

   [Não {obrigado, não agora, eu vou te ligar mais tarde}, Não no momento, Negativo]

   [(CanYou) contar uma piada, Você tem uma piada para mim]

   [Silêncio por favor, Fique quieto por favor, Preciso me concentrar, Eu {preciso, devo} focar agora]

   [Ok, você pode falar, Posso ouvir {agora, de novo}, Você pode falar {agora, de novo}, Mantenha-me {informado, atualizado, a par}]

   [Por favor, sem mais (Information), Sem mais (Information), Sem mais (Information) por favor]

   [Por favor, me dê (Information), Você pode me dar (Information), Você pode me dar (Information) por favor, Me dê (Information), Me dê (Information) por favor]

2. Informação

   [(TellMe) as horas, Que horas são, Qual é o {horário atual, horário}]
	
3. Treinamento

   [(CanYou) dar-me um {treinamento}, (CanWe) corra uma sessão de {treinamento, treinamento, prática, prática}, (CanYou) {ajudar, me ajudar} com {o, meu} {treinamento, prática}, (CanYou) {observar} meu {treinamento, condução}, (CanYou) {verificar, assistir} minha {técnica} de condução, (CanWe) melhorar minhas capacidades de condução]

   [Obrigado {pela sua ajuda, eu aprendi muito, isso foi ótimo}, Isso foi ótimo, obrigado. Ok, já chega por hoje]

   [(CanYou) me dê {uma visão geral, uma visão geral curva por curva, uma visão geral volta por volta, uma visão geral da volta inteira, uma visão completa, uma visão completa curva por curva}, {Por favor, dê, Dê} uma olhada na pista completa, Onde posso melhorar na pista]
   
   [{Obrigado agora, Agora} quero me concentrar, {Ok, deixe} eu {aplicar, tentar} {suas recomendações, suas instruções, isso} agora, {Por favor, pare} de me dar {recomendações, dicas, instruções, recomendações para cada curva, recomendações para cada volta, dicas para cada curva, dicas para cada volta, instruções para cada curva, instruções para cada volta}, {Por favor, não} de mais {instruções, instruções por favor}]

   [(CanYou) me dê {recomendações, dicas, instruções} {enquanto eu estiver dirigindo, para cada curva, para cada volta}, {Diga por favor} {antes de, para} cada {curva, volta} o que eu {posso, devo} mudar, (CanYou) treinar-me {na pista, enquanto eu estiver dirigindo, enquanto estiver dirigindo}]

   [(CanWe) {focar em, praticar} {curva, curva número} (Número), Vamos {focar em, praticar} {curva, curva número} (Número), (CanYou) me dê {recomendações, dicas, um guia, instruções} para {curva, curva número} (Número)]
   
   [(CanYou) me dizer onde estão os pontos de frenagem, {Por favor, me diga, Diga} onde frear, (CanWe) praticar {frenagem, pontos de frenagem}]

   [(CanWe) {focar na, falar sobre a} {curva número, curva} (Number), {Por favor dê} uma {olhada mais de perto, olhada} na {curva, curva número, volta, volta número} (Number), Onde posso melhorar na {curva, curva número, volta, volta número} (Number), O que devo considerar {na} {curva, curva número, volta, volta número} (Number), O que devo procurar na {curva, curva número, volta, volta número} (Number)]

   [(CanWe) utilizar a {volta mais rápida, última volta} como {referência, volta de referência}, {Please use, Use} a {volta mais rápida, última volta} como {referência, volta de referência}]

   [{Por favor} não utilizar uma referência da {volta}]

   [(CanWe) {focar, focar novamente} em todo o percurso, Vamos {focar, focar novamente} em toda a faixa]

#### Conversa

Além disso, você pode ter uma conversa gratuita com o Driving Coach na maior parte do tempo. Portanto, todo comando de voz que não corresponder a nenhum dos comandos mostrados acima será encaminhado para o modelo de linguagem GPT, o que resultará em um diálogo semelhante ao humano, conforme mostrado no [exemplo](https://github.com/SeriousOldMan/Simulator-Controller/wiki/AI-Driving-Coach#a-typical-dialog).