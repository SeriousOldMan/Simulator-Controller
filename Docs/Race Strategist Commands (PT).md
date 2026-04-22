Abaixo você encontrará uma lista completa de todos os comandos de voz reconhecidos por Cato, o AI Race Strategist, juntamente com uma breve introdução à sintaxe das gramáticas de frases.

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

Announcements=avisos meteorológicos

#### Commands

1. Conversation

   [{Oi, Ei, Olá} %name%, %name% você me ouve, %name% está me ouvindo, %name% preciso de você, %name% onde você está, %name% responde por favor, %name% fala comigo]

   [Sim {por favor, claro}, {Sim, Perfeito} continue, {Pode, Ok} {continuar, continuar por favor, seguir, seguir por favor}, Pode falar, Prossiga, Concordo, Certo, Correto, Confirmado, Eu confirmo, Afirmativo]

   [Não {obrigado, não agora, eu te chamo mais tarde}, Agora não, Não no momento, Negativo]

   [(CanYou) me contar uma piada, Você tem uma piada para mim, (CanYou) me dizer uma piada]

   [Cale-se, Silêncio por favor, Fique quieto por favor, Preciso me concentrar, Preciso focar agora, Eu {preciso, devo} focar agora]

   [Ok, você pode falar, Tudo bem, pode falar, Posso ouvir {agora, de novo}, Você pode falar {agora, de novo}, Mantenha-me {informado, atualizado, a par}, Pode voltar a falar]

   [Por favor, sem mais (Announcements), Sem mais (Announcements), Chega de (Announcements), Sem mais (Announcements) por favor]

   [Por favor, me dê (Announcements), Você pode me dar (Announcements), Você pode me dar (Announcements) por favor, Me dê (Announcements), Me dê (Announcements) por favor, Volte a me dar (Announcements)]

2. Informação

   [(TellMe) o horário, (TellMe) as horas, Que horas são, Qual é o {horário atual, horário}]
   
   [E o tempo, Como está o tempo, Vai chover mais à frente, {Há alguma, Existem} mudanças no tempo à vista, (CanYou) verificar o {tempo, tempo por favor}]

   [(TellMe) as voltas restantes, Quantas voltas restam, Quantas voltas faltam, Quantas voltas faltam para o fim, Quanto falta]

   [Simule {a corrida, a classificação} em (Number) voltas, (CanYou) simular {a corrida, a classificação} em (Number) voltas, Qual será minha posição em (Number) voltas, Qual vai ser minha posição em (Number) voltas]

   [(WhatIs) {a minha posição, minha posição, minha posição de corrida, minha posição atual}, (TellMe) {a minha posição, minha posição, minha posição de corrida, minha posição atual}]

   [(TellMe) a diferença para o {carro da frente, carro à frente, carro seguinte, próximo carro, posição à frente}, (WhatIs) a diferença para o {carro da frente, carro à frente, carro seguinte, próximo carro, posição à frente}, Qual é a diferença para o {carro da frente, carro à frente, carro seguinte, próximo carro, posição à frente}]
 
   [(TellMe) a diferença para {o carro atrás, o carro atrás de mim, a posição atrás de mim, o carro de trás}, (WhatIs) a diferença para {o carro atrás, o carro atrás de mim, a posição atrás de mim, o carro de trás}, Qual é a diferença para {o carro atrás, o carro atrás de mim, a posição atrás de mim, o carro de trás}]

   [(TellMe) a diferença para o {carro líder, líder}, (WhatIs) a diferença para o {carro líder, líder}, Qual é a diferença para o {carro líder, líder}]

   [(TellMe) a diferença para o {carro, carro número, número} (Number), (WhatIs) a diferença para o {carro, carro número, número} (Number), Qual é a diferença para o {carro, carro número, número} (Number)]

   [(TellMe) o {nome do piloto, nome do piloto à frente, piloto do carro} à frente, (WhatIs) o {nome do piloto, nome do piloto à frente, piloto do carro} à frente]

   [(TellMe) o {nome do piloto, nome do piloto atrás, piloto do carro} atrás, (WhatIs) o {nome do piloto, nome do piloto atrás, piloto do carro} atrás]

   [(TellMe) a {classe do carro, categoria do carro} à frente, (WhatIs) a {classe do carro, categoria do carro} à frente]

   [(TellMe) a {classe do carro, categoria do carro} atrás, (WhatIs) a {classe do carro, categoria do carro} atrás]

   [(TellMe) a {categoria da copa do carro, categoria de copa do carro, copa do carro} à frente, (WhatIs) a {categoria da copa do carro, categoria de copa do carro, copa do carro} à frente]

   [(TellMe) a {categoria da copa do carro, categoria de copa do carro, copa do carro} atrás, (WhatIs) a {categoria da copa do carro, categoria de copa do carro, copa do carro} atrás]

   [(TellMe) o tempo da {volta atual, última volta, volta} do {carro, carro número, número} (Number), (WhatIs) o tempo da {volta atual, última volta, volta} do {carro, carro número, número} (Number)]

   [(TellMe) o tempo da {volta atual, última volta, volta} da posição (Number), (WhatIs) o tempo da {volta atual, última volta, volta} da posição (Number)]

   [(TellMe) {o meu, meu, o} tempo de {volta atual, última volta, volta}, (WhatIs) {o meu, meu, o} tempo de {volta atual, última volta, volta}]

   [(TellMe) os tempos de {volta atual, volta}, (WhatAre) os tempos de {volta atual, volta}]

   [(TellMe) o número de {carros, carros na pista, carros na sessão, carros ativos, carros ainda ativos}, (WhatAre) o número de {carros, carros na pista, carros na sessão}, Quantos carros {estão, ainda estão} {ativos, na pista, na sessão}]

   [(TellMe) quantas {vezes, paradas} o {carro, carro número, número} (Number) {entrou nos boxes, foi aos boxes}, Quantas paradas nos boxes tem o {carro, carro número, número} (Number), Com que frequência o {carro, carro número, número} (Number) esteve nos boxes]

3. Parado

   [(WhatIs) a melhor {volta, opção} para a próxima parada, Quando você recomenda a próxima parada, (CanYou) recomendar a próxima parada, Em que volta devo vir para os boxes]

   [(CanYou) simular a {próxima parada, parada} {por volta da, na, em} volta (Number), Planeje a {próxima parada, parada} {por volta da, na, em} volta (Number), (CanYou) planejar a {próxima parada, parada} {por volta da, na, em} volta (Number)]

4. Strategy
   
   [Como está nossa estratégia para {hoje, a corrida}, Você pode me dar um resumo da {estratégia, nossa estratégia}, Como está nossa estratégia, {Por favor, me dê, Me dê} {a estratégia, nossa estratégia}]

   [(CanYou) {suspender, cancelar} a estratégia, {Suspenda, Cancele} a estratégia, A estratégia não faz mais sentido, Essa estratégia não faz mais sentido]

   [Quando é a próxima parada, Em que volta {a parada está planejada, devo ir para os boxes}, Quando devo ir para os boxes, (TellMe) {a volta da próxima parada, quando devo ir para os boxes}]

   [(CanYou) desenvolver uma nova estratégia, (CanYou) ajustar a estratégia, (CanYou) planejar uma nova estratégia, Precisamos de uma nova estratégia]

   [{Temos uma Full, Full} Course Yellow. O que {eu, nós} {devemos, podemos} fazer, {Temos uma Full, Full} Course Yellow. {Eu, nós} {devemos ir para os boxes, podemos ir para os boxes, devemos parar agora, podemos parar agora}]
