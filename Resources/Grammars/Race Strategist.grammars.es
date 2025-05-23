// Standard
#Include Fragments.es
#Include Choices.es
#Include Conversation.es
#Include Weather.es
#Include Grid.es
[Configuration]
Recognizer=Grammar
[Fragments]
WeatherUpdate=avisos meteorológicos
[Choices]
Announcements=avisos meteorológicos
[Listener Grammars]
// Information //
LapsRemaining=[(TellMe) las vueltas restantes, Cuántas vueltas quedan, Cuántas vueltas quedan, Cuántas vueltas faltan]
FuturePosition=[Simula la {carrera, la clasificación} en (Number) vueltas, (CanYou) simular la {carrera, clasificación} en (Number) vueltas, ¿Cuál será mi posición en (Number) vueltas, ¿Cuál será mi posición en (Number) vueltas]
// Pitstop Planning //
PitstopRecommend=[(WhatIs) la mejor {vuelta, opción} para el próximo pitstop, ¿Cuándo recomienda el próximo pitstop?, (CanYou) recomendar la próxima parada en boxes, ¿En qué vuelta debo entrar en boxes?]
PitstopSimulate=[(CanYou) simular la {siguiente parada en boxes, pitstop} {alrededor, en} la vuelta (Number), Planificar la {siguiente parada en boxes, pitstop} {alrededor, en} la vuelta (Number), (CanYou) planificar la {siguiente parada en boxes, pitstop} {alrededor, en} la vuelta (Number)]
// Race Strategy Handling //
StrategyOverview=[Cómo es nuestra estrategia para {hoy, la carrera}, Puedes darme un resumen de {la, nuestra} estrategia, Cómo es nuestra estrategia, Dame {por favor} {la, nuestra} estrategia]
CancelStrategy=[(CanYou) {suspender, cancelar} la estrategia, {Suspender, cancelar} la estrategia, La estrategia ya no tiene sentido, La estrategia ya no tiene sentido]
NextPitstop=[Cuándo es la próxima parada en boxes, En qué {vuelta está prevista la parada en boxes, debo entrar en boxes}, Cuándo debo entrar en boxes, (TellMe) {la vuelta para la siguiente parada en boxes, cuando debería entrar en boxes}]
StrategyRecommend=[(CanYou) desarrollar una nueva estrategia, (CanYou) ajustar la estrategia, (CanYou) planear una nueva estrategia, Necesitamos una nueva estrategia]
FCYRecommend=[{Contamos con Curso, Curso} Completo Amarillo. Qué {tengo que, podemos} hacer, {Contamos con Curso, Curso} Completo Amarillo. {Debería ir a boxes ahora, Debería venir a boxes, Debería hacer boxes, Debería ir a boxes ahora}]
[Speaker Phrases]
// Conversation //	
Greeting.1=Hola %driver%, soy %name%. Veré la carrera y encontraré la mejor estrategia para ti.
Greeting.2=Soy %name%, tu estratega. Estaré atento a la estrategia para esta carrera.
Greeting.3=Me llamo %name%. Llámame si necesitas alguna estrategia.
Later.1=Es demasiado pronto para decirlo. Por favor, preguntame en una o dos vueltas.
Later.2=No puedo decírtelo todavía. Por favor, encuentra tu ritmo primero.
Later.3=Tienes que encontrar tu ritmo primero. Por favor, preguntame más tarde.
Explain.1=¿Quieres una explicación detallada?
Explain.2=¿Debería explicarlo?
CollectingData.1=Lo siento %driver%, pero sólo estoy recogiendo datos para nuestra estrategia de carrera. Por el momento estás por tu cuenta.
CollectingData.2=Oye, estoy preparando la estrategia para la próxima carrera. Tienes que prescindir de mí en este momento.
// Information //
Laps.1=Aún tienes %laps% vueltas para finalizar.
Laps.2=Tienes combustible para %laps% vueltas.
LowLaps.1=Te quedarás sin combustible en %laps% vueltas.
LowLaps.2=Te queda combustible para %laps% vueltas. Deberíamos preparar la parada en la siguiente vuelta.
LapsAlready.1=Ya has conducido %laps% vueltas.
LapsAlready.2=Ya has completado %laps% vueltas.
LapsFuel.1=Tienes combustible para otras %laps% vueltas.
LapsFuel.2=El combustible restante es suficiente para %laps% vueltas.
LapsStint.1=Pero tu stint termina en %laps% vueltas.
LapsStint.2=Pero solo te quedan %laps% para terminar tu stint.
LapsSession.1=Pero la sesión terminara en %laps% vueltas.
LapsSession.2=Pero solo quedan %laps% vueltas para el resto de la sesión.
NoFutureLap.1=Esto no tiene sentido. Por favor, elige otra vuelta.
FuturePosition.1=Lo más probable es que estés en P %position% %class%.
FuturePosition.2=La simulación muestra que estaremos en P %position% %class%.
FuturePosition.3=Parece que estarás en P %position% %class%.
NoFuturePosition.1=Todavía no tenemos suficientes datos para una simulación.
// Pitstop Strategy Planning //
PitstopLap.1=Hola %driver%, la mejor vuelta para una parada en boxes será la vuelta %lap%.
PitstopLap.2=Hola %driver% soy %name%, debes venir en la vuelta %lap% a los boxes.
PitstopLap.3=%driver%, una parada en boxes en la vuelta %lap% será la mejor opción.
NoPlannedPitstop.1=No puedo hacer una simulación de pitstop con estos datos. Entra, cuando estés listo.
NoPitstopNeeded.1=Una parada en boxes no es necesaria. Parece que tienes suficiente combustible para terminar tu stint.
NoPitstopNeeded.2=No necesitamos una parada en boxes, te queda suficiente combustible para este stint.
EvaluatedLaps.1=He calculado una parada en boxes para %laps% vueltas diferentes, desde la vuelta %first% hasta la vuelta %last%.
EvaluatedLaps.2=He simulado paradas en boxes desde la vuelta  %first% hasta la vuelta %last%.
EvaluatedLaps.3=He simulado %laps% paradas en boxes.
EvaluatedSimilarPosition.1=La posición después de la parada en boxes será la misma para todas las paradas posibles, siempre en P %position%.
EvaluatedSimilarPosition.2=Terminarás siempre en P %position% después de la parada en boxes.
EvaluatedBestPosition.1=La mejor posición para entrar a boxes será en la vuelta %lap%. Posiblemente saldrás en P %position%.
EvaluatedBestPosition.2=Si entras a boxes en la vuelta %lap%, puedes acabar en P %position%, que sería el mejor resultado simulado.
EvaluatedNoTraffic.1=Podrás no encontrarte tráfico cuando vuelvas a entrar a pista.
EvaluatedNoTraffic.2=Cuando vuelvas a la carrera no tendrás coches delante de ti.
EvaluatedTraffic.1=Tendrás %traffic% coches delante de ti cuando vuelvas a entrar en la pista.
EvaluatedTraffic.2=Vas a encontrarte %traffic% coches cuando regreses a la carrera.
EvaluatedBackmarkers.1=De ellos, %backmarkers% son doblados.
EvaluatedBackmarkers.2=A %backmarkers% coches les sacas al menos una vuelta.
EvaluatedBackmarker.1=Uno de ellos es un doblado, intenta quitártelo de en medio lo antes posible.
ConfirmUpdateStrategy.1=¿Actualizo la estrategia?
ConfirmUpdateStrategy.2=Actualizaré nuestra estrategia, ¿de acuerdo?
ConfirmInformEngineer.1=¿Informo al ingeniero de carrera?
ConfirmInformEngineer.2=Informaré al ingeniero de carrera, ¿de acuerdo?
ConfirmInformEngineerAnyway.1=De acuerdo, no hay problema. ¿Debo informar al ingeniero de carrera?
ConfirmInformEngineerAnyway.2=Bien, podemos hacer esto más tarde. Pero informaré al ingeniero de carrera, ¿de acuerdo?
// Race Strategy //
ConfirmReportStrategy.1=%driver%, soy %name%. ¿Debería darte algunos datos clave sobre nuestra estrategia?
ConfirmReportStrategy.2=%name% en la radio. ¿Quieres un resumen de nuestra estrategia?
ConfirmReportStrategy.3=%driver%, te habla %name%. Puedo resumir brevemente nuestra estrategia para la carrera, ¿de acuerdo?
ReportStrategy.1=%driver%, soy %name%.
ReportStrategy.2=%name% en la readio.
Strategy.1=Hemos desarrollado la siguiente estrategia.
Strategy.2=Tenemos la siguiente estrategia.
Strategy.3=Aquí está el resumen de la estrategia.
FCYStrategy.1=Ok, una parada en boxes ahora es una buena idea.
FCYStrategy.2=Podemos adelantar la parada en boxes.
FCYStrategy.3=Una parada en boxes durante esta bandera amarilla en toda la pista sería beneficiosa.
FCYStrategy.4=Ok, ven a boxes.
NoStrategy.1=%driver%, no hemos desarrollado una estrategia para esta carrera. Eres libre de elegir las paradas en boxes por tu cuenta.
NoStrategy.2=No tenemos ninguna estrategia para esta carrera. Estás por tu cuenta.
NoFCYStrategy.1=Una parada en boxes no nos da ninguna ventaja ahora.
NoFCYStrategy.2=No necesitamos una parada en boxes ahora.
NoFCYStrategy.3=Mantente fuera.
FCYPitstop.1=Pero usar esta bandera amarilla en toda la pista para una parada en boxes podría ser beneficioso.
FCYPitstop.2=Pero puedes venir a boxes si es necesario.
NoStrategyRecommendation.1=Lo siento, necesito el apoyo de nuestro ingeniero para hacer esto.
NoStrategyRecommendation.2=Nuestro ingeniero no está por aquí. No puedo hacer esto solo.
NoStrategyRecommendation.3=No puedo encontrar a nuestro ingeniero. Es imposible para mí hacer esto solo.
Pitstops.1=Hemos planificado %pitstops% paradas.
Pitstops.2=Tendremos %pitstops% pitstops en total.
PitstopsDifference.1=%difference% %direction% de lo previsto actualmente.
PitstopsDifference.2=%difference% %direction%.
PitstopsDifference.3=En lugar de %pitstops% como está previsto actualmente.
NextPitstop.1=La siguiente parada es en la vuelta %pitstopLap%.
NextPitstop.2=La siguiente parada será en la vuelta %pitstopLap%.
NextPitstop.3=Tienes que venir para la siguiente parada en la vuelta %pitstopLap%.
LapsDifference.1=%difference% %label% %direction% de lo previsto actualmente.
LapsDifference.2=%difference% %label% %direction%.
LapsDifference.3=En lugar de la vuelta %lap% como está previsto actualmente.
NoNextPitstop.1=Ya ha completado todas las paradas programadas.
NoNextPitstop.2=No hay más paradas en boxes.
Refuel.1=Vamos a repostar %fuel% %unit%.
Refuel.2=Se repostarán %fuel% %unit%.
RefuelDifference.1=%difference% %unit% %direction% de lo previsto actualmente.
RefuelDifference.2=%difference% %unit% %direction%.
RefuelDifference.3=Son %difference% %unit% %direction%.
RefuelDifference.4=En lugar de los %refuel% %unit% previstos actualmente.
NoRefuel.1=No está previsto el repostaje.
NoRefuel.2=No es necesario repostar.
NoRefuel.3=No necesitamos combustible adicional.
TyreChange.1=Está previsto un cambio de neumáticos.
TyreChange.2=Vamos a cambiar los neumáticos.
NoTyreChange.1=No está previsto cambiar los neumáticos.
NoTyreChange.2=No es necesario cambiar los neumáticos.
NoTyreChange.3=Dejaremos los neumáticos sin cambiar.
TyreChangeDifference.1=No lo habíamos planeado de antemano.
TyreChangeDifference.2=Esto es probablemente necesario ahora.
NoTyreChangeDifference.1=Probablemente ya no necesitemos el cambio de neumáticos planeado.
TyreCompoundDifference.1=Pero probablemente tendremos que usar un compuesto de neumáticos diferente.
TyreCompoundDifference.2=Pero cambiaremos el compuesto de los neumáticos.
StrategyMap.1=Por cierto, a partir de ahora deberías utilizar el Map %map%.
StrategyMap.2=Por cierto, elige el mapa %map% para este stint.
StintMap.1=%driver%, soy %name%. Por favor, utilice el mapa %map% para este stint.
StintMap.2=%name% en la radio. Por favor, utilice el mapa %map% para este stint.
ConfirmCancelStrategy.1=%driver%, quieres que descarte la estrategia, ¿verdad?
ConfirmCancelStrategy.2=¿Debería cancelar la estrategia?
StrategyCanceled.1=Bien, he rechazado la estrategia. Ahora estás por tu cuenta.
StrategyCanceled.2=La estrategia se cancela. Ahora tenemos que planificar las paradas de forma espontánea.
PitstopAhead.1=%driver%, te habla %name%. La próxima parada en boxes está prevista en  %laps% vueltas.
PitstopAhead.2=%name% en la radio. La próxima parada está prevista para la vuelta %lap%.
NoBetterStrategy.1=No puedo encontrar una mejor estrategia en este momento. Nos quedaremos con eso.
NoBetterStrategy.2=Nuestra estrategia actual parece ser la mejor actualmente. Nos quedaremos con eso.
NoBetterStrategy.3=Parece que no puedo encontrar una mejor estrategia actualmente.
NoValidStrategy.1=No puedo crear una estrategia para estas condiciones.
NoValidStrategy.2=%driver%, no puedo pensar en una estrategia válida en este momento.
StrategyUpdate.1=%driver%, este es %name%. Parece que tenemos que cambiar nuestra estrategia.
StrategyUpdate.2=%driver%, se me ocurrió una mejor estrategia.
StrategyUpdate.3=%driver%, podríamos ajustar nuestra estrategia.
// Session Settings Handling //
ConfirmSaveSettings.1=¿Apunto todos los ajustes para la próxima carrera?
ConfirmSaveSettings.2=Una pregunta %driver%, ¿debo anotar todas las configuraciones?
// Race Report Handling //
ConfirmSaveSettingsAndRaceReport.1=¿Apunto todos los ajustes y preparo el informe para el análisis posterior a la carrera?
ConfirmSaveSettingsAndRaceReport.2=Una pregunta %driver%, ¿anoto todos los ajustes y quieres un informe de la carrera?
ConfirmSaveRaceReport.1=Y yo prepararé el informe para el análisis de después de la carrera, ¿de acuerdo?
ConfirmSaveRaceReport.2=%driver%, ¿quieres un informe de la carrera?
RaceReportSaved.1=Bien, el informe está listo.
RaceReportSaved.2=Todo listo.
// Race Review //
GreatRace.1=%name% en la radio. Gran carrera. P %position% %class%. No hay nada más que decir sobre esto. Vamos a celebrarlo.
GreatRace.2=Te habla %name%. Fantástico, hemos terminado en P %position% %class%. Eres el mejor.
GreatRace.3=%name% al aparato. Gran resultado, P %position% %class%. Pondré el champán a enfriar.
MediocreRace.1=%name% soy %name%. P %position% %class%. Resultado sólido, pero se puede hacer más.
MediocreRace.2=%name% soy %name%. P %position% %class%. No está mal, pero la próxima vez hay que quedar mejor.
CatastrophicRace.1=%name%, soy %name%. ¡Qué vergüenza! P %position% %class%.
CatastrophicRace.2=%name% soy %name% P %position% %class%. Mejor haberte quedado en casa.
CatastrophicRace.3=%name% soy %name% P %position% %class%. Realmente no ha sido tu día.
Compare2Leader.1=Fuiste de media %relative% %seconds% segundos más lento que el ganador.
Compare2Leader.2=%relative% %seconds% segundos más lento que el ganador de media.
InvalidCritics.1=%conjunction% Simplemente has cometido demasiados errores.
InvalidCritics.2=%conjunction% Demasiados errores, todavía tienes que trabajar en ti mismo.
InvalidCritics.3=%conjunction% La próxima vez comete menos errores.
PositiveSummary.1=En general es bastante bueno.
PositiveSummary.2=En general, puedes estar satisfecho.
PositiveSummary.3=Sin embargo, en general está muy bien.
GoodPace.1=Eres rápido
GoodPace.2=Tienes un buen ritmo
MediocrePace.1=Necesitas un poco más de velocidad
MediocrePace.2=Puedes ir un poco más rápido
BadPace.1=Aún tienes que trabajar en tu ritmo
BadPace.2=No eres lo suficientemente rápido todavía
GoodConsistency.1=%conjunction% Tienes buena consistencia.
GoodConsistency.2=%conjunction% Conduces de forma muy constante.
MediocreConsistency.1=%conjunction% Se necesita un poco más de consistencia.
MediocreConsistency.2=%conjunction% Podrías conducir un poco más uniformemente.
BadConsistency.1=%conjunction% Necesitas urgentemente trabajar en tu consistencia, la diferencia entre tus tiempos de vuelta es catastrófica.
BadConsistency.2=%conjunction% La diferencia entre tus tiempos de vuelta es muy alta.