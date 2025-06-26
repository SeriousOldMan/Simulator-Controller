Abaixo você encontrará uma lista completa de todos os comandos de voz reconhecidos por Jona, o AI Race Engineer, juntamente com uma breve introdução à sintaxe das gramáticas de frases.

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

Announcements=avisos de combustível, avisos de desgaste dos pneus, avisos de desgaste do freio, avisos de danos, análise de danos, atualizações meteorológicas, avisos de pressão

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

   [(WhatAre) {as temperaturas do motor, as temperaturas atuais do motor}, (TellMe) {as temperaturas do motor, as temperaturas atuais do motor}]

   [(WhatAre) {as, as frias, as de configuração, as atuais} {pressões dos pneus, pressões}, (TellMe) {as, as frias, as de configuração, as atuais} {pressões dos pneus, pressões}]

   [(WhatAre) {as temperaturas dos pneus, as temperaturas atuais dos pneus, as temperaturas no momento}, (TellMe) {as temperaturas dos pneus, as temperaturas atuais dos pneus, as temperaturas no momento}]

   [{Verifique, Por favor verifique} {o desgaste dos pneus, o desgaste dos pneus no momento}, (TellMe) {o desgaste dos pneus, o desgaste dos pneus no momento}]

   [(WhatAre) {as temperaturas dos freios, as temperaturas atuais dos freios, as temperaturas dos freios no momento}, (TellMe) {as temperaturas dos freios, as temperaturas atuais dos freios, as temperaturas dos freios no momento}]

   [{Verifique, Por favor verifique} {o desgaste dos freios, o desgaste dos freios no momento}, (TellMe) {o desgaste dos freios, o desgaste dos freios no momento}]

   [(TellMe) as voltas restantes, Quantas voltas faltam, Quantas voltas restam, Quantas voltas para o fim, Quanto falta para o fim]

   [Quanto {gasolina, combustível} resta, Quanto {gasolina, combustível} ainda tem, (TellMe) o restante {gasolina, combustível}, (WhatIs) o restante {gasolina, combustível}]

   [E o clima, vai chover à frente, a qualquer momento, mudanças climáticas à vista, (CanYou) verifique o {clima, clima por favor}]

3. Pitstop

   [(CanWe) {otimizar, recalcular, calcular} a proporção de combustível, (CanWe) otimizar a quantidade de combustível, (CanWe) otimizar o reabastecimento de energia]

   [(CanWe) {planejar a parada, criar um plano para a parada, criar um plano de parada, elaborar um plano de parada}]

   [(CanWe) {planejar a troca de motorista, criar um plano para a troca de motorista, criar um plano de troca de motorista, elaborar um plano de troca de motorista}]

   [(CanWe) {preparar a parada, deixar a equipe preparar a parada, configurar tudo para a parada}]

   [(CanWe) {reabastecer, reabastecer até} (Number) {litros, galões}, Precisamos de {reabastecer, reabastecer até} (Number) {litros, galões}]

   [(CanWe) {usar, trocar para} pneus molhados, {Can we, Please} {usar, trocar para} pneus secos, {Can we, Please} {usar, trocar para} pneus intermediários]

   [(CanWe) aumentar {frente esquerda, frente direita, traseira esquerda, traseira direita, todos} por (Digit) {ponto, vírgula} (Digit), (Digit) {ponto, vírgula} (Digit) mais pressão para {o pneu dianteiro esquerdo, o pneu dianteiro direito, o pneu traseiro esquerdo, o pneu traseiro direito, todos os pneus}]

   [(CanWe) diminuir {frente esquerda, frente direita, traseira esquerda, traseira direita, todos} por (Digit) {ponto, vírgula} (Digit), (Digit) {ponto, vírgula} (Digit) menos pressão para {o pneu dianteiro esquerdo, o pneu dianteiro direito, o pneu traseiro esquerdo, o pneu traseiro direito, todos os pneus}]

   [(CanWe) deixar a {pressão dos pneus, pressão} inalterada, (CanWe) deixar a {pressão dos pneus, pressão} como está, (CanWe) deixar as {pressões dos pneus, pressões} inalteradas, (CanWe) {deixar, manter} as {pressões dos pneus, pressões} como estão]

   [(CanWe) {deixar, manter} os pneus do carro, {Please} não mudar os pneus, (CanWe) {deixar, manter} os pneus inalterados, Não mudar os pneus, por favor]

   [(CanWe) reparar a suspensão, {Please} não reparar a suspensão]

   [(CanWe) reparar a carroçaria, {Please} não reparar a carroçaria]

   [(CanWe) reparar o motor, {Please} não reparar o motor]

   [(CanWe) compensar a perda de {pressão dos pneus, pressão}, {Favor compensar, Compensar} a perda de {pressão dos pneus, pressão} dos pneus]

   [{Não, Favor não} {compensar} a perda de {pressão dos pneus, pressão} dos pneus, Sem mais compensação para perda de {pressão dos pneus, pressão}]