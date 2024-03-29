[Configuration]
Recognizer=Mixed
[Fragments]
SessionInformation=Información de la sesión
StintInformation=Información de la Stint
HandlingInformation=Información de comportamiento de conducción
[Choices]
Announcements=Información de la sesión, Información de la Stint, Información de comportamiento de conducción
[Listener Grammars]
// Conversation //
Call=[{Hola, Hey} %name%, %name% me escuchas, %name% te necesito, Hey %name% donde estas?]
Yes=[Si, De acuerdo, Perfecto]
No=[No, No más tarde]
AnnouncementsOff=[{Tenga en cuenta, Aviso} (Announcements) no más, {Por favor ignorar, Ignorar} (Announcements), Ignorar (Announcements) por favor]
AnnouncementsOn=[{Nota, Tome en cuenta, Tome en cuenta, Tome en cuenta} (Anuncios) nuevamente, {Otra vez tome en cuenta, Tome en cuenta nuevamente, Tome en cuenta nuevamente, Tome en cuenta nuevamente} (Anuncios)]
// Conversation //
IHearYou.1=Estoy aquí. ¿Qué puedo hacer por ti?
IHearYou.2=Si %driver%? ¿Me has llamado?
IHearYou.3=Te escucho. Continúa.
IHearYou.4=Sí, te escucho. ¿Qué necesitas?
Confirm.1=Roger, espera un momento.
Confirm.2=Bien, lo haré ahora mismo.
Comfirm.3=Vale, déjame ver.
Confirm.4=Roger, vuelvo contigo lo antes posible.
Confirm.5=Vale, dame un segundo.
Comfirm.6=Espera un momento.
Roger.1=Está bien, lo tengo.
Roger.2=Está bien.
Roger.3=Está bien, hagámoslo.
Okay.1=Está bien, tal vez más tarde.
Okay.2=Entendido, no hay problema.
Repeat.1=Lo siento %driver%, No lo he entendido. ¿Puede repetirlo?
Repeat.2=Lo siento, no lo he entendido. Repite, por favor.
Repeat.3=¿Puedes repetirlo, por favor?
Later.1=Lo siento, estoy ocupado ahora mismo. Por favor contáctame más tarde.
Later.2=Actualmente estoy en la otra línea. Dame algo de tiempo.
Later.3=Sólo tengo que evaluar algunos datos. Ponte en contacto nuevamente en 5 minutos.
// Announcement Handling //
ConfirmAnnouncementOff.1=Ya no quieres hablar más sobre %announcement%, ¿verdad?
ConfirmAnnouncementOff.2=Voy a ignorar %announcement% por ahora, ¿verdad?
ConfirmAnnouncementOn.1=Quieres que preste atención a %announcement% nuevamente, ¿verdad?
ConfirmAnnouncementOn.2=Prestaré atención a %announcement% nuevamente, ¿es correcto?