// Standard
#Include Choices.es
#Include Conversation.es
#Include Fragments.es
[Configuration]
Recognizer=Mixed
[Fragments]
SessionInformation=Información de la sesión.
StintInformation=Información del stint
HandlingInformation=Información del comportamiento de la conducción
Fastest=rápida
Last=última
[Choices]
Announcements=Información de la sesión, Información del stint, Información del comportamiento de la conducción
[Listener Grammars]
// Conversation //
AnnouncementsOff=[{Tenga en cuenta, Aviso} (Announcements) no más, {Por favor ignorar, Ignorar} (Announcements), Ignorar (Announcements) por favor]
AnnouncementsOn=[{Nota, Tome en cuenta, Tome en cuenta, Tome en cuenta} (Announcements) nuevamente, {Otra vez tome en cuenta, Tome en cuenta nuevamente, Tome en cuenta nuevamente, Tome en cuenta nuevamente} (Announcements)]
// Coaching //
CoachingStart=[(CanYou) darme una {entrenamiento, lección de entrenamiento}, (CanWe) realizar una sesión de {entrenamiento, entrenamiento, práctica, practicar}, (CanYou) {ayudarme, ayudarme} con {el, mi} {entrenamiento, práctica, práctica}, (CanYou) {observar, observar} mi {entrenamiento, práctica, practicar, condución}, (CanYou) {revisar, observar} mi conducción {técnica, estilo}, (CanWe) mejorar mis habilidades de conducción, (CanWe) realizar un entrenamiento, (CanYou) darme una lección de entrenamiento, (CanWe) realizar una sesion de {entrenamiento, práctica}]
CoachingFinish=[Gracias {por tu ayuda, aprendí mucho, estuvo genial}, estuvo genial, gracias, está bien, es suficiente por hoy]
ReviewLap=[(CanYou) darme {una descripción general, una descripción general curva por curva, una descripción general de toda la vuelta, una descripción general completa, una descripción general completa curva por curva}, {Por favor echa, Echa} un vistazo a la pista completa, ¿Dónde puedo mejorar en la pista]
ReviewCorner=[(CanWe) {centrarnos, hablar sobre} {número de curva, curva} (Number), {Por favor toma, Toma} {mira más de cerca, mira} a {número de curva, curva} (Number), ¿Dónde puedo mejorar {número de curva, curva} (Number), ¿Qué debo considerar {para, en} {número de curva, curva} (Number), Qué debo tener en cuenta en la curva (Number)]
TrackCoachingStart=[(CanYou) darme {recomendaciones, consejos, una guía, instrucciones} {mientras conduzco, para cada curva}, {Por favor dime, Dime} {antes de, para} cada curva lo que {puedo, debería} cambiar, (CanYou) entrenarme {en la pista, mientras conduzco}]
TrackCoachingFinish=[{Gracias ahora, Ahora} quiero concentrarme, {Está bien déjame, Déjame} {aplicar, probar} {tus recomendaciones, tus instrucciones, eso} ahora, {Por favor deja, Deja} dándome {recomendaciones, consejos, instrucciones, recomendaciones para cada curva, tips para cada curva, instrucciones para cada curva}, {Por favor no, No} más {instrucciones, instrucciones por favor}]
ReferenceLap=[(CanWe) usar la vuelta {más rápida, última} como {referencia, vuelta de referencia}, {Por favor use, Use} la vuelta {más rápida, última} como {referencia, vuelta de referencia}]
NoReferenceLap=[{Por favor haz, Haz} no utilices una referencia {vuelta, vuelta por favor}]
FocusCorner=[(CanWe) centrarnos en la {número de curva, curva} (Number), {Practiquemos, Centrémonos} la {número de curva, curva} (Number), (CanYou) darme {recomendaciones, consejos, una guía, instrucciones} para la {número de curva, curva} (Number)]
NoFocusCorner=[(CanWe) {centrarnos, centrarnos de nuevo} en toda la pista, {Centrémonos nuevamente, Centrémonos} en toda la pista]
[Speaker Phrases]
// Conversation //
Later.1=Lo siento, estoy ocupado ahora mismo. Por favor contáctame más tarde.
Later.2=Actualmente estoy en la otra línea. Dame algo de tiempo.
Later.3=Tengo que evaluar algunos datos. Ponte en contacto nuevamente en 5 minutos.
// Announcement Handling //
ConfirmAnnouncementOff.1=Ya no quieres hablar más sobre %announcement%, ¿verdad?
ConfirmAnnouncementOff.2=Voy a ignorar %announcement% por ahora, ¿verdad?
ConfirmAnnouncementOn.1=Quieres que preste atención a %announcement% nuevamente, ¿verdad?
ConfirmAnnouncementOn.2=Prestaré atención a %announcement% nuevamente, ¿es correcto?
// Coaching //
StartCoaching.1=Aquí está %name%. Da algunas vueltas hasta que haya encendido mi ordenador. Volveré contigo cuando vea los datos de telemetría.
StartCoaching.2=Aquí %name%. Arrancaré mi ordenador y darás algunas vueltas. Me pondré en contacto contigo cuando esté listo.
ConfirmCoaching.1=Por supuesto. Da algunas vueltas hasta que haya encendido mi ordenador. Volveré contigo cuando vea los datos de telemetría.
ConfirmCoaching.2=Sí, claro. Arrancaré mi ordenador y darás algunas vueltas. Me pondré en contacto contigo cuando esté listo.
CoachingReady.1=Aquí está %name%, estoy listo. ¿Dónde necesitas mi ayuda?
CoachingReady.2=Aquí %name%. Están llegando los datos. ¿Qué puedo hacer por tí?
BrakeEarlier.1=Frena un poco antes %conclusion%
BrakeEarlier.2=Freno antes %conclusion%
BrakeEarlier.3=Tienes que frenar antes %conclusion%
BrakeLater.1=Frena un poco más tarde %conclusion%
BrakeLater.2=Freno más tarde %conclusion%
BrakeLater.3=Tienes que frenar más tarde %conclusion%
BrakeHarder.1=%conjunction% Acumula más presión de freno %conclusion%
BrakeHarder.2=%conjunction% Presione el pedal del freno con más fuerza %conclusion%
BrakeHarder.3=%conjunction% Más presión de freno %conclusion%
BrakeSofter.1=%conjunction% Acumula menos presión de freno %conclusion%
BrakeSofter.2=%conjunction% Presione el pedal del freno con menos fuerza %conclusion%
BrakeSofter.3=%conjunction% Menos presión de freno %conclusion%
BrakeFaster.1=%conjunction% Presione el pedal del freno más rápido %conclusion%
BrakeFaster.2=%conjunction% Más rápido en los frenos %conclusion%
BrakeFaster.3=%conjunction% Frena más rápido %conclusion%
BrakeSlower.1=%conjunction% Aumenta la presión del freno lentamente %conclusion%
BrakeSlower.2=%conjunction% Pise el freno un poco más lento %conclusion%
AccelerateEarlier.1=%conjunction% Acelerar antes %conclusion%
AccelerateEarlier.2=%conjunction% Acelerar un poco antes %conclusion%
AccelerateEarlier.3=%conjunction% Acelerar antes %conclusion%
AccelerateEarlier.4=%conjunction% Acelera antes %conclusion%
AccelerateLater.1=%conjunction% Acelerar más tarde %conclusion%
AccelerateLater.2=%conjunction% Acelerar un poco más tarde %conclusion%
AccelerateLater.3=%conjunction% Acelerar más tarde %conclusion%
Acceleratelater.4=%conjunction% Acelera más tarde %conclusion%
AccelerateHarder.1=%conjunction% Abre el gas más rápido %conclusion%
AccelerateHarder.2=%conjunction% Abre el acelerador rápidamente %conclusion%
AccelerateSofter.1=%conjunction% Abre el gas más lentamente %conclusion%
AccelerateSofter.2=%conjunction% Abre el acelerador lentamente %conclusion%
PushLess.1=%conjunction% No tan agresivo %conclusion%
PushLess.2=%conjunction% Conduce más suave %conclusion%
PushLess.3=%conjunction% No atropelles el coche %conclusion%
PushMore.1=%conjunction% Necesitas conducir más agresivamente %conclusion%
PushMore.2=%conjunction% Conduce de forma más agresiva %conclusion%