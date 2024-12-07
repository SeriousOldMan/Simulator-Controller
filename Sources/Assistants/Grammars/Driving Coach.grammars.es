// Standard
#Include Choices.es
#Include Conversation.es
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
AnnouncementsOn=[{Nota, Tome en cuenta, Tome en cuenta, Tome en cuenta} (Anuncios) nuevamente, {Otra vez tome en cuenta, Tome en cuenta nuevamente, Tome en cuenta nuevamente, Tome en cuenta nuevamente} (Anuncios)]
// Coaching //
CoachingStart=[(CanYou) (1)darme una {entrenamiento, lección de entrenamiento}, (CanWe) realizar una sesión de {entrenamiento, entrenamiento, práctica, practicar}, (CanYou) {ayudarme, ayudarme} con {el, mi} {entrenamiento, práctica, práctica}, (CanYou) {observar, observar} mi {entrenamiento, práctica, practicar, condución}, (CanYou) {revisar, observar} mi conducción {técnica, estilo}, (CanWe) mejorar mis habilidades de conducción, (CanWe) realizar un entrenamiento, (CanYou) darme una lección de entrenamiento, (CanWe) realizar una sesion de {entrenamiento, práctica}]
CoachingFinish=[Gracias {por tu ayuda, aprendí mucho, estuvo genial}, estuvo genial, gracias, está bien, es suficiente por hoy]
ReviewLap=[(CanYou) darme {una descripción general, una descripción general curva por curva, una descripción general de toda la vuelta, una descripción general completa, una descripción general completa curva por curva}, {Por favor echa, Echa} un vistazo a la pista completa, ¿Dónde puedo mejorar en la pista]
ReviewCorner=[(CanWe) {centrarnos, hablar sobre} {número de curva, curva} (Number), {Por favor toma, Toma} {mira más de cerca, mira} a {número de curva, curva} (Number), ¿Dónde puedo mejorar? {número de curva, curva} (Number),  ( 3) ¿Qué debo considerar {para, en} {número de curva, curva} (Number), Qué debo tener en cuenta en la curva (Number)]
TrackCoachingStart=[(CanYou) darme {recomendaciones, consejos, una guía, instrucciones} {mientras conduzco, para cada curva}, {Por favor dime, Dime} {antes de, para} cada curva lo que {puedo, debería} cambiar, (CanYou) entrenarme {en la pista, mientras conduzco}]
TrackCoachingFinish=[{Gracias ahora, Ahora} quiero concentrarme, {Está bien déjame, Déjame} {aplicar, probar} {tus recomendaciones, tus instrucciones, eso} ahora, {Por favor deja, Deja} dándome {recomendaciones, consejos, instrucciones, recomendaciones para cada curva, tips para cada curva, instrucciones para cada curva}, {Por favor no, No} más {instrucciones, instrucciones por favor}]
ReferenceLap=[(CanWe) usar la vuelta {más rápida, última} como {referencia, vuelta de referencia}, {Por favor use, Use} la vuelta {más rápida, última} como {referencia, vuelta de referencia}]
NoReferenceLap=[{Por favor haz, Haz} no utilices una referencia {vuelta, vuelta por favor}]
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
ConfirmCoaching.1=Por supuesto. Da algunas vueltas hasta que haya encendido mi ordenador. Volveré contigo cuando vea los datos de telemetría.
ConfirmCoaching.2=Sí, claro. Arrancaré mi ordenador y darás algunas vueltas. Me pondré en contacto contigo cuando esté listo.
CoachingReady.1=Aquí está %name%, estoy listo. ¿Dónde necesitas mi ayuda?
CoachingReady.2=Aquí %name%. Están llegando los datos. ¿Qué puedo hacer por tí?