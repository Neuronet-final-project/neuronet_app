// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'NEURONET';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get home => 'Inicio';

  @override
  String get settings => 'Ajustes';

  @override
  String get profile => 'Perfil';

  @override
  String get journal => 'Diario';

  @override
  String get chat => 'Chat';

  @override
  String get mood => 'Estado de ánimo';

  @override
  String get alerts => 'Alertas';

  @override
  String get retry => 'Reintentar';

  @override
  String get failedToLoadDashboard => 'Error al cargar el panel';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenos tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get howAreYouFeeling => '¿Cómo te sientes?';

  @override
  String get allMoods => 'Todos los estados →';

  @override
  String get quickActions => 'Acciones rápidas';

  @override
  String get recentJournals => 'Diarios recientes';

  @override
  String get viewAll => 'Ver todo →';

  @override
  String get personalInsight => 'Perspectiva personal';

  @override
  String get weGotYou => 'Estamos contigo 💙';

  @override
  String get tryThisToday => 'Prueba esto hoy';

  @override
  String get more => 'Más →';

  @override
  String get recommendedForYou => 'Recomendado para ti';

  @override
  String get playAndRelax => 'Jugar y relajarse';

  @override
  String get newTag => 'NUEVO';

  @override
  String get myProfile => 'Mi perfil';

  @override
  String get accountInformation => 'Información de la cuenta';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get emailAddress => 'Correo electrónico';

  @override
  String get accountStatus => 'Estado de la cuenta';

  @override
  String get privacyAndPermissions => 'Privacidad y permisos';

  @override
  String get consentStatus => 'Estado de consentimiento';

  @override
  String get viewConsentDescription => 'Ver lo que tu tutor ha aprobado';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get adolescent => 'ADOLESCENTE';

  @override
  String heyUser(String name) {
    return 'Hola $name 👋';
  }

  @override
  String get innerWorldPrompt => '¿Cómo está tu mundo interior hoy?';

  @override
  String get writeJournal => 'Escribir diario';

  @override
  String get expressYourself => 'Exprésate 📝';

  @override
  String get aiCompanion => 'Compañero IA';

  @override
  String get talkItOut => 'Habla con la IA 🤖';

  @override
  String get checkYourMood => 'Ver tu estado de ánimo';

  @override
  String get moodEmojiPrompt => '¿Cómo te sientes? 😊';

  @override
  String get learnAndGrow => 'Aprender y crecer';

  @override
  String get exploreResources => 'Explorar recursos 📚';

  @override
  String get smallCheckIn => 'Un pequeño registro ayuda mucho.';

  @override
  String get today => 'HOY';

  @override
  String get take30Seconds => 'Tómate 30 segundos.';

  @override
  String get namingFeelings =>
      'Nombrar lo que sientes es la mitad del trabajo.\nNosotros te ayudamos con el resto.';

  @override
  String get checkInNow => 'Registrarse ahora';

  @override
  String get journals => 'Diarios';

  @override
  String get moods => 'Estados';

  @override
  String get forYou => 'Para ti';

  @override
  String get journalToday => 'Hoy';

  @override
  String get journalYesterday => 'Ayer';

  @override
  String daysAgo(int count) {
    return 'Hace $count días';
  }

  @override
  String get journalEntryDefault => 'Entrada de diario';

  @override
  String feelingLabel(String mood) {
    return 'Sintiéndose $mood';
  }

  @override
  String minRead(int count) {
    return '$count min de lectura';
  }

  @override
  String get readNow => 'Leer ahora';

  @override
  String get mindfulnessGames => 'Juegos de atención plena';

  @override
  String get boostYourMood =>
      'Mejora tu ánimo con actividades divertidas respaldadas por la ciencia.';

  @override
  String get playNow => 'Jugar ahora';

  @override
  String get ai => 'IA';

  @override
  String get notificationSettings => 'Ajustes de notificaciones';

  @override
  String get alertNotifications => 'Notificaciones de alerta';

  @override
  String get counselorMessages => 'Mensajes del consejero';

  @override
  String get getNotifiedPatterns =>
      'Recibe notificaciones cuando se detecten patrones';

  @override
  String get pushNotificationsNewMessages =>
      'Notificaciones push para mensajes nuevos';

  @override
  String get role => 'Rol';

  @override
  String get guardian => 'Tutor';

  @override
  String get areYouSureSignOut => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get translate => 'Traducir';

  @override
  String get showOriginal => 'Mostrar original';

  @override
  String get translating => 'Traduciendo...';

  @override
  String get translationError => 'Error al traducir';

  @override
  String get failedToLoadJournals => 'Error al cargar los diarios';

  @override
  String get yourJournalAwaits => 'Tu diario te espera';

  @override
  String get captureHowYouFeel =>
      'Captura cómo te sientes en un espacio privado.\nToca redactar cuando estés listo.';

  @override
  String get secureJournalTag => 'TU DIARIO SEGURO';

  @override
  String get refreshingJournal => 'Actualizando diario...';

  @override
  String get stillSyncingEntry =>
      'Aún sincronizando esta entrada con el servidor...';

  @override
  String get thisWeek => 'ESTA SEMANA';

  @override
  String memoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MEMORIAS',
      one: '1 MEMORIA',
    );
    return '$_temp0';
  }

  @override
  String get openingYourEntry => 'Abriendo tu entrada...';

  @override
  String get couldNotOpenShare =>
      'No se pudo abrir el intercambio. El texto se copió al portapapeles.';

  @override
  String get journalNotFound => 'Diario no encontrado';

  @override
  String get journalSubject => 'Mi entrada de diario';

  @override
  String get pleaseWriteSomething => 'Por favor escribe algo primero';

  @override
  String get journalSaved => 'Tu diario fue guardado.';

  @override
  String get newEntryTag => 'NUEVA ENTRADA';

  @override
  String get safeSpaceNote =>
      'Este es tu espacio seguro. Escribe lo que sientes hoy.';

  @override
  String get journalTitleHint => 'Dale un título...';

  @override
  String get journalContentHint =>
      'Empieza a escribir tus pensamientos aquí...';

  @override
  String get sparkSmile => '¿Qué me hizo sonreír hoy?';

  @override
  String get sparkGrateful => 'Una cosa por la que estoy agradecido';

  @override
  String get sparkVictory => 'Una pequeña victoria que tuve';

  @override
  String get sparkChallenge => 'Cómo manejé un desafío';

  @override
  String get discoverHeader => 'DESCUBRIR';

  @override
  String get searchMemoriesHint => 'Buscar memorias...';

  @override
  String get filterWhen => 'CUÁNDO';

  @override
  String get filterMood => 'ESTADO DE ÁNIMO';

  @override
  String filterResults(int count) {
    return 'RESULTADOS ($count)';
  }

  @override
  String get stillLooking => 'Siguiendo buscando...';

  @override
  String get filterAll => 'Todo';

  @override
  String get filterToday => 'Hoy';

  @override
  String get filterThisWeek => 'Esta semana';

  @override
  String get filterSpecific => 'Fecha específica';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get aboutJournalPrivacy => 'Acerca de la privacidad del diario';

  @override
  String get journalPrivacyTitle => 'Privacidad del diario';

  @override
  String get journalPrivacyContent =>
      'Tus entradas de diario se guardan de forma segura para tu cuenta. La aplicación está diseñada para que el texto original de tu diario no se muestre a tutores o consejeros. Si alguna vez usas funciones opcionales que analizan el estado de ánimo de forma agregada, estas se describen en tus ajustes de consentimiento.';

  @override
  String get gotIt => 'Entendido';

  @override
  String get backToJournal => 'Volver al diario';

  @override
  String get entryRemovedNote =>
      'Es posible que se haya eliminado o que este enlace esté desactualizado.';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get moodLabel => 'Estado';

  @override
  String get wordsLabel => 'Palabras';

  @override
  String get readLabel => 'Lectura';

  @override
  String get tipLongPress =>
      'Consejo: mantén presionada tu entrada a continuación para seleccionar texto o copiar una línea favorita.';

  @override
  String get yourPrivateSpace => 'Tu espacio privado';

  @override
  String get privateSpaceNote =>
      'Esta entrada permanece en tu cuenta para ti. Los tutores y consejeros no leen el texto de tu diario.';

  @override
  String get copyEntry => 'Copiar entrada';

  @override
  String get titleAndFullText => 'Título y texto completo';

  @override
  String get writingSparksTag => 'CHISPAS DE ESCRITURA';

  @override
  String get howAreYouFeelingNow => '¿Cómo te sientes ahora mismo?';

  @override
  String get save => 'Guardar';

  @override
  String get syncingTag => 'SINCRONIZANDO';

  @override
  String get shareTooltip => 'Compartir';

  @override
  String get moreTooltip => 'Más';

  @override
  String get moodHappy => 'Feliz';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodAnxious => 'Ansioso';

  @override
  String get moodCalm => 'Tranquilo';

  @override
  String get moodStressed => 'Estresado';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodExcited => 'Emocionado';

  @override
  String get moodTired => 'Cansado';

  @override
  String get moodAngry => 'Enojado';

  @override
  String get moodHopeful => 'Esperanzado';

  @override
  String get dailyCheckInTag => 'TU REGISTRO DIARIO';

  @override
  String get tapEmojiPrompt =>
      'Toca el emoji que mejor capture tu estado de ánimo actual.';

  @override
  String get intensityLabel => 'Intensidad';

  @override
  String get mildLabel => 'Leve';

  @override
  String get strongLabel => 'Fuerte';

  @override
  String get moodReasonPrompt => '¿Qué te hace sentir así?';

  @override
  String get moodNoteHint => 'Añade una nota rápida... (Opcional)';

  @override
  String get logMoodButton => 'Registrar este ánimo';

  @override
  String get moodLoggedSuccess => '¡Ánimo registrado!';

  @override
  String get thanksCheckingIn =>
      'Gracias por registrarte.\nRastrear cómo te sientes te ayuda a entenderte mejor.';

  @override
  String get logAnotherMood => 'Registrar otro ánimo';

  @override
  String get pastCheckInsHeader => 'Registros pasados';

  @override
  String get failedToLoadHistory => 'No se pudo cargar el historial';

  @override
  String get now => 'Ahora';

  @override
  String get minAbbr => 'm';

  @override
  String get hourAbbr => 'h';

  @override
  String get dayAbbr => 'd';

  @override
  String get levelAbbr => 'Nivel';

  @override
  String get aiAssistant => 'Asistente IA';

  @override
  String get typing => 'Escribiendo...';

  @override
  String get online => 'En línea';

  @override
  String get loading => 'Cargando...';

  @override
  String get offline => 'Desconectado';

  @override
  String get aiAssistantInfo => 'Información del asistente IA';

  @override
  String get safetyFirst => 'La seguridad es lo primero';

  @override
  String get safetyFirstDesc =>
      'Esta IA es para apoyo y reflexión, no para diagnóstico médico o intervención en crisis.';

  @override
  String get yourData => 'Tus datos';

  @override
  String get yourDataDesc =>
      'Las conversaciones se analizan para proporcionar apoyo y pueden ser revisadas por tu consejero escolar.';

  @override
  String get howToUse => 'Cómo usar';

  @override
  String get howToUseDesc =>
      'Pregunta sobre el manejo del estrés, consejos de estudio o simplemente charla sobre tu día.';

  @override
  String get aboutAiAssistant => 'Acerca del asistente IA';

  @override
  String get unableConnectAi => 'No se pudo conectar con el asistente IA';

  @override
  String get checkInternetTryAgain =>
      'Comprueba tu conexión a Internet e inténtalo de nuevo.';

  @override
  String get startConversation => 'Iniciar una conversación';

  @override
  String get aiEmptyPrompt =>
      'Pregúntame cualquier cosa sobre tu bienestar.\nEstoy aquí para ayudarte a reflexionar.';

  @override
  String get aiThinking => 'El asistente IA está pensando...';

  @override
  String get aiSafetyDisclaimer =>
      'El asistente IA puede apoyar tu reflexión pero no es un profesional médico. Para ayuda urgente, contacta a tu consejero.';

  @override
  String get aiSenderLabel => 'Asistente NEURO';

  @override
  String get youSenderLabel => 'Tú';

  @override
  String get aiPrompt1 => '¿En qué puedes ayudarme?';

  @override
  String get aiPrompt2 => '¿Cómo añado una entrada de diario?';

  @override
  String get aiPrompt3 => '¿Quién puede ver mis datos?';

  @override
  String get aiPrompt4 => '¿Cómo contacto a mi consejero?';
}
