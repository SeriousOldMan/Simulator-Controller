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

## Comandos (válido para 4.2.2 e posteriores)

#### Predefined Choices

TellMe=Você poderia me contar, Por favor me conte, Conte-me, Você pode me dar, Por favor me dê, Me dê

WhatAre=Conte-me, O que são

WhatIs=Conte-me, O que é, Fale sobre

CanYou=Você pode

CanWe=Podemos

Announcements=avisos meteorológicos

#### Commands

1. Conversation

   [{Hi, Hey} %name%, %name% Esta me ouvindo?, %name% Eu preciso de você, %name% Estou em casa, %name% Entre, por favor]

   [Sim {por favor, claro}, {perfeito} prossiga, {Vai, Ok vai} {sobre, por favor, à frente}, Concordo, Certo, Correto, Confirmado, Confirmo, Afirmativo]

   [Não {obrigado, não agora, eu vou te ligar mais tarde}, Não no momento, Negativo]

   [(CanYou) contar uma piada, Você tem uma piada para mim]

   [Silêncio por favor, Fique quieto por favor, Preciso me concentrar, Eu {preciso, devo} focar agora]

   [Ok, você pode falar, Posso ouvir {agora, de novo}, Você pode falar {agora, de novo}, Mantenha-me {informado, atualizado, a par}]

   [Por favor, sem mais (Announcements), Sem mais (Announcements), Sem mais (Announcements) por favor]

   [Por favor, me dê (Announcements), Você pode me dar (Announcements), Você pode me dar (Announcements) por favor, Me dê (Announcements), Me dê (Announcements) por favor]

2. Informação

   [(TellMe) as horas, Que horas são, Qual é o {horário atual, horário}]
   
   [(TellMe) as voltas restantes, Quantas voltas restam, Quantas voltas faltam, Quantas voltas para o fim, Quanto falta]

   [E o clima, vai chover à frente, a qualquer momento, mudanças climáticas à vista, (CanYou) verifique o {clima, clima por favor}]

   [Simular o {corrida, classificação} em (Number) voltas, (CanYou) simular o {corrida, classificação} em (Number) voltas, Qual será minha posição em (Number) voltas, Qual é a minha posição em (Number) voltas]

   [(WhatIs) {minha} posição, (TellMe) {minha} minha posição]

   [(TellMe) o gap para o {carro à frente, próximo carro}, (WhatIs) o gap para o {carro à frente, próximo carro}, Qual é diferença para o {carro à frente, próximo carro}]

   [(TellMe) o gap para {o carro atrás de mim, a posição atrás de mim, o carro anterior}, (WhatIs) o gap para {o carro atrás de mim, a posição atrás de mim, o carro anterior}, Qual é diferença para {o carro atrás de mim, a posição atrás de mim, o carro anterior}]

   [(TellMe) o gap para o {carro líder, líder}, (WhatIs) o gap para o the {carro líder, líder}, Qual é diferença para o {carro líder, líder}]

   [(TellMe) o gap para o {carro, carro número, número} (Number), (WhatIs) o gap para o {carro, carro número, número} (Number), Qual a dimensão da diferença para {carro, carro número, número} (Number)]

   [(TellMe) o {nome do piloto, piloto do carro} adiante, (WhatIs) o {nome do piloto, piloto do carro} adiante]

   [(TellMe) o {nome do piloto, piloto do carro} atrás, (WhatIs) o {nome do piloto, piloto do carro} atrás]

   [(TellMe) a {classe do carro} adiante, (WhatIs) a {classe do carro} adiante]

   [(TellMe) a {class of the car} atrás, (WhatIs) a {class of the car} atrás]

   [(TellMe) a {categoria de copa do carro, copa do carro} adiante, (WhatIs) a {categoria de copa do carro, copa do carro} adiante]

   [(TellMe) o {categoria de copa do carro, copa do carro} atrás, (WhatIs) a {categoria de copa do carro, copa do carro} atrás]

   [(TellMe) a {volta atual, última volta, volta} o tempo do {carro, número do carro, número} (Number), (WhatIs) a {volta atual, última volta, volta} tempo da {volta atual, última volta, volta} do carro (Number)]

   [(TellMe) a {volta atual, última volta, volta} o tempo de posição (Number), (WhatIs) a {volta atual, última volta, volta} tempo da posição (Number)]

   [(TellMe) {o, meu} tempo de {volta atual, última volta, volta}, (WhatIs) {o, meu} tempo de {volta}]

   [(TellMe) a {volta atual, volta} os tempos, (WhatAre) a {volta atual, volta} tempos]

   [(TellMe) o número de {carros, carros na pista, carros na sessão, carros ativos, carros ainda ativos}, (WhatAre) o número de {carros, carros na pista, carros na sessão}, Quantos carros {estão, ainda estão} {ativos, na pista, na sessão}]

   [(TellMe) quantas {vezes} {carro, carro número, número} (Number) {entra, foi} nos boxes, Quantas paradas nos boxes tem o {carro, carro número, número} (Number), Com que frequência o {carro, carro número, número} (Number) esteve nos boxes]

3. Parado

   [(WhatIs) o melhor {volta, opção} para o próximo pitstop, Quando você recomenda o próximo pitstop, (CanYou) recomendar o próximo pitstop, Em que volta devo chegar ao pit]

   [(CanYou) simular o {próximo pitstop, pitstop} {por volta de, em, na} volta (Number), Planeje o {próximo pitstop, pitstop} {por volta de, em, na} volta (Number), (CanYou) planeje o {próximo pitstop, pitstop} {por volta de, em, na} volta (Number)]

4. Strategy

   [Como é a nossa estratégia para {hoje, a corrida}, Você pode me dar um resumo da nossa estratégia, Como é a nossa estratégia, {Por favor, me dê} nossa estratégia]

   [(CanYou) {suspender, cancelar} a estratégia, {Suspender, Cancelar} a estratégia, A estratégia não faz mais sentido]

   [Quando é o próximo pit stop, em qual volta {está planejado o pitstop, devo ir ao pit}, Quando devo ir aos boxes, (TellMe) {a volta para o próximo pitstop, quando devo ir ao pit}]

   [(CanYou) desenvolver uma nova estratégia, (CanYou) ajustar a estratégia, (CanYou) planejar uma nova estratégia, precisamos de uma nova estratégia]

   [{Está completo, completo} Curso Amarelo. O que {devo, podemos} fazer, {Temos um completo, completo} curso Amarelo. Deveria {ir ao pit, ir ao pit agora, pit, pit agora}][Speaker Phrases]