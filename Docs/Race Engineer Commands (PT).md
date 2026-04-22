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

## Comandos

#### Predefined Choices

TellMe=Você pode me dizer, Você pode me falar, Por favor me diga, Por favor me fale, Diga-me, Me diga, Me fala, Você pode me dar, Por favor me dê, Me dê

WhatAre=Diga-me, Me diga, Me dê, Quais são, Quais são os

WhatIs=Diga-me, Me diga, Me dê, O que é, Qual é

CanYou=Você pode, Pode, Podemos, Por favor

CanWe=Você pode, Pode, Podemos, Por favor

Announcements=avisos de combustível, avisos de desgaste dos pneus, avisos de desgaste do freio, avisos de danos, análise de danos, atualizações meteorológicas, avisos de pressão

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

   [(WhatAre) {as temperaturas do motor, as temperaturas atuais do motor}, (TellMe) {as temperaturas do motor, as temperaturas atuais do motor}, Quais são as temperaturas do motor]

   [(WhatAre) {as pressões dos pneus, as pressões, as pressões atuais dos pneus, as pressões de acerto, as pressões frias}, (TellMe) {as pressões dos pneus, as pressões, as pressões atuais dos pneus, as pressões de acerto, as pressões frias}]

   [(WhatAre) {as temperaturas dos pneus, as temperaturas atuais dos pneus, as temperaturas no momento}, (TellMe) {as temperaturas dos pneus, as temperaturas atuais dos pneus, as temperaturas no momento}]

   [{Verifique, Por favor verifique, Cheque} {o desgaste dos pneus, o desgaste atual dos pneus}, (TellMe) {o desgaste dos pneus, o desgaste atual dos pneus}]

   [(WhatAre) {as temperaturas dos freios, as temperaturas atuais dos freios, as temperaturas dos freios no momento}, (TellMe) {as temperaturas dos freios, as temperaturas atuais dos freios, as temperaturas dos freios no momento}]

   [{Verifique, Por favor verifique, Cheque} {o desgaste dos freios, o desgaste atual dos freios}, (TellMe) {o desgaste dos freios, o desgaste atual dos freios}]

   [(TellMe) as voltas restantes, Quantas voltas restam, Quantas voltas faltam, Quantas voltas faltam para acabar, Quanto falta]

   [Quanto {combustível, gasolina} resta, Quanto {combustível, gasolina} {tem no tanque, ainda tem}, (TellMe) o {combustível restante, combustível}, (WhatIs) o {combustível restante, combustível}]
   
   [E o tempo, Como está o tempo, Vai chover mais à frente, {Há alguma, Existem} mudanças no tempo à vista, (CanYou) verificar o {tempo, tempo por favor}]

3. Pitstop

   [(CanWe) {otimizar, recalcular, calcular} a quantidade de combustível, (CanWe) otimizar o reabastecimento, (CanWe) otimizar a quantidade para abastecer]

   (CanWe) {planejar a parada, criar um plano para a parada, criar um plano de parada, montar um plano de parada}

   (CanWe) {planejar a troca de piloto, criar um plano para a troca de piloto, criar um plano de troca de piloto, montar um plano de troca de piloto}

   (CanWe) {preparar a parada, deixar a equipe preparar a parada, deixar tudo pronto para a parada}

   [(CanWe) {reabastecer, reabastecer até} (Number) {litros, galões}, Precisamos {reabastecer, reabastecer até} (Number) {litros, galões}]

   [(CanWe) {usar, trocar para} pneus de chuva, (CanWe) {usar, trocar para} pneus secos, (CanWe) {usar, trocar para} pneus intermediários]

   [(CanWe) aumentar {frente esquerda, frente direita, traseira esquerda, traseira direita, todos} por (Digit) {ponto, vírgula} (Digit), (Digit) {ponto, vírgula} (Digit) mais pressão para {o pneu dianteiro esquerdo, o pneu dianteiro direito, o pneu traseiro esquerdo, o pneu traseiro direito, todos os pneus}]

   [(CanWe) diminuir {frente esquerda, frente direita, traseira esquerda, traseira direita, todos} por (Digit) {ponto, vírgula} (Digit), (Digit) {ponto, vírgula} (Digit) menos pressão para {o pneu dianteiro esquerdo, o pneu dianteiro direito, o pneu traseiro esquerdo, o pneu traseiro direito, todos os pneus}]

   [(CanWe) deixar a {pressão dos pneus, pressão} inalterada, (CanWe) deixar a {pressão dos pneus, pressão} como está, (CanWe) deixar as {pressões dos pneus, pressões} inalteradas, (CanWe) {deixar, manter} as {pressões dos pneus, pressões} como estão]

   [(CanWe) {deixar, manter} os pneus no carro, Por favor não trocar os pneus, (CanWe) {deixar, manter} os pneus inalterados, Sem troca de pneus por favor]

   [(CanWe) reparar a suspensão, Por favor não reparar a suspensão]

   [(CanWe) reparar a carroceria, Por favor não reparar a carroceria]

   [(CanWe) reparar o motor, Por favor não reparar o motor]

   [(CanWe) compensar a perda de {pressão dos pneus, pressão}, {Por favor compense, Compense} a perda de {pressão dos pneus, pressão}, {Leve, Por favor leve} a perda de {pressão dos pneus, pressão} em {consideração, conta}]

   [{Não, Por favor não} compensar a perda de {pressão dos pneus, pressão}, Sem mais compensação da perda de {pressão dos pneus, pressão}]