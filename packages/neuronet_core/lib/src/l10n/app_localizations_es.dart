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

  @override
  String get requestApproval => 'Request Approval';

  @override
  String get checkingApprovalStatus => 'Checking approval status...';

  @override
  String get approvalRequest => 'Approval Request';

  @override
  String get approvalPending => 'Approval Pending';

  @override
  String approvalPendingMessage(String counselorName) {
    return 'Your approval request for $counselorName is already pending.';
  }

  @override
  String get guardianReviewingMessage =>
      'Your guardian is reviewing your request. You\'ll be notified once they respond.';

  @override
  String get requestSent => 'Request Sent';

  @override
  String get requestSentSuccess => 'Request Sent!';

  @override
  String get approvalSentMessage =>
      'Your approval request has been sent to your guardian.';

  @override
  String get statusPending => 'Status: Pending';

  @override
  String get backToChat => 'Back to Chat';

  @override
  String get guardianApprovalRequired => 'Guardian Approval Required';

  @override
  String get guardianApprovalExplanation =>
      'To communicate with a counselor, you need approval from your guardian. Please explain why you would like to talk to this counselor.';

  @override
  String get counselorLabel => 'Counselor';

  @override
  String get counselorChat => 'Counselor Chat';

  @override
  String get reasonForRequest => 'Reason for Request';

  @override
  String get reasonHint =>
      'Explain why you would like to talk to this counselor...';

  @override
  String get reasonRequired => 'Please provide a reason for your request';

  @override
  String get reasonMinLength =>
      'Please provide more details (at least 20 characters)';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get unableToGetUserInfo =>
      'Unable to get user information. Please try again.';

  @override
  String get pendingRequestExists =>
      'You already have a pending approval request for this counselor.';

  @override
  String get alreadyPending => 'already pending';

  @override
  String get approvalRequestAlreadyPending =>
      'Approval request already pending';

  @override
  String get profileNotFound => 'User profile not found.';

  @override
  String get adolescentAccount => 'Adolescent Account';

  @override
  String get errorPrefix => 'Error';

  @override
  String get statusActive => 'Activo';

  @override
  String get statusInactive => 'Inactivo';

  @override
  String get statusSuspended => 'Suspendido';

  @override
  String get statusPendingActivation => 'Pendiente de activación';

  @override
  String appVersion(String version) {
    return 'NeuroNet v$version';
  }

  @override
  String guardianAppVersion(String version) {
    return 'NeuroNet Guardian v$version';
  }

  @override
  String get profileNotFoundUser => 'No user profile found.';

  @override
  String get accountActivatedLogin => 'Account activated! Please login.';

  @override
  String get activateAccountTitle => 'Activate Account';

  @override
  String get setUpSecureAccount => 'Set Up Your Secure Account';

  @override
  String get activationCodeHint =>
      'Use the activation code provided by your guardian to begin your journey.';

  @override
  String get registeredEmail => 'Registered Email';

  @override
  String get activationCode => 'Activation Code';

  @override
  String get activationCodeExample => 'e.g. NEURO-2026';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get activateAccountButton => 'Activate Account';

  @override
  String get passwordPrivacyInfo =>
      'Your password ensures your journal remains private and secure.';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterActivationCode => 'Please enter the activation code';

  @override
  String get pleaseEnterPassword => 'Please enter a password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get discoverPages => 'Discover Pages';

  @override
  String get followedPages => 'Followed Pages';

  @override
  String get pickedForYou => 'Picked for You';

  @override
  String get aiPicks => 'AI Picks';

  @override
  String get popular => 'Popular';

  @override
  String get analyzeNow => 'Analyze Now';

  @override
  String get insightDetail => 'Insight Detail';

  @override
  String get channelNotFound => 'Channel not found. Please try again later.';

  @override
  String get yourChannels => 'Your Channels';

  @override
  String get following => 'Following';

  @override
  String get follow => 'Follow';

  @override
  String get requestApprovalAgain => 'Request Approval Again';

  @override
  String get requestAgain => 'Request Again';

  @override
  String get goToYourChannels => 'Go to Your Channels';

  @override
  String get loginTagline1 => 'Tu espacio de apoyo emocional 💜';

  @override
  String get loginTagline2 => 'No estás solo en esto 🌿';

  @override
  String get loginTagline3 => 'Cada sentimiento es válido aquí ✨';

  @override
  String get anErrorOccurred => 'Ocurrió un error';

  @override
  String get welcomeBack => 'Bienvenido de nuevo 👋';

  @override
  String get signInToContinue => 'Inicia sesión para continuar';

  @override
  String get emailHint => 'Correo electrónico';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get newToNeuroNet => '¿Nuevo en NeuroNet?';

  @override
  String get activateMyAccount => 'Activar mi cuenta';

  @override
  String get dataPrivateEncrypted =>
      'Tus datos son privados y están encriptados';

  @override
  String get onboardingTitle1 => 'Tu espacio seguro';

  @override
  String get onboardingDesc1 =>
      'Un lugar privado para tus pensamientos y sentimientos. Tus diarios nunca son vistos por tutores o consejeros.';

  @override
  String get onboardingTitle2 => 'Comprende tus tendencias';

  @override
  String get onboardingDesc2 =>
      'Nuestra IA te ayuda a ver patrones en tu viaje emocional a lo largo del tiempo, ayudándote a crecer con autoconciencia.';

  @override
  String get onboardingTitle3 => 'Apoyo, no diagnóstico';

  @override
  String get onboardingDesc3 =>
      'Estamos aquí para apoyarte. Nuestra IA es un asistente informativo, no un médico o terapeuta.';

  @override
  String get onboardingTitle4 => '¿Listo para empezar?';

  @override
  String get onboardingDesc4 =>
      'Usa el código de activación proporcionado por tu tutor para desbloquear tu viaje emocional personal.';

  @override
  String get noCommentsYet => 'No comments yet.';

  @override
  String get discover => 'Discover';

  @override
  String get myInsights => 'My Insights';

  @override
  String get aiReflectiveQuest => 'AI REFLECTIVE QUEST';

  @override
  String get gameOver => 'Game Over!';

  @override
  String get playAgain => 'Play Again';

  @override
  String get close => 'Close';

  @override
  String get startGame => 'START GAME';

  @override
  String get startExercise => 'Start Exercise';

  @override
  String get noInsightsYet => 'No insights yet!';

  @override
  String get keepJournalingDesc =>
      'Keep journaling and tracking your moods.\nWe\'ll share helpful patterns here.';

  @override
  String insightsHistory(int count) {
    return 'Insights History ($count)';
  }

  @override
  String get recent => 'RECENT';

  @override
  String get newLabel => 'NEW';

  @override
  String get viewDetails => 'View Details';

  @override
  String get yesterday => 'Ayer';

  @override
  String failedToUploadVoice(String error) {
    return 'Failed to upload voice message: $error';
  }

  @override
  String failedToUploadMedia(String type, String error) {
    return 'Failed to upload $type: $error';
  }

  @override
  String get voiceCall => 'Voice call';

  @override
  String get videoCall => 'Video call';

  @override
  String get refreshMessages => 'Refresh messages';

  @override
  String get chatEnabledBanner =>
      'Chat enabled - Your guardian has approved counselor communication';

  @override
  String get chatDisabledBanner =>
      'Chat disabled - Counselor communication consent required';

  @override
  String get loadingConsent => 'Checking permissions...';

  @override
  String get unableToStartChat => 'Unable to start chat.';

  @override
  String get noMessagesYet => 'No messages yet.';

  @override
  String get startConversationWithCounselor =>
      'Start a conversation with your counselor.';

  @override
  String get counselorPrompt1 => 'I\'d like to talk about something';

  @override
  String get counselorPrompt2 => 'Can you help me with some concerns?';

  @override
  String get counselorPrompt3 => 'I need some guidance';

  @override
  String get deepBreathingTitle => 'Deep Breathing';

  @override
  String get deepBreathingDesc =>
      'A simple 4-4-4 rhythm to calm your mind and regulate your system.';

  @override
  String get mindfulFocusTitle => 'Mindful Focus';

  @override
  String get mindfulFocusDesc =>
      'Train your attention by following the rhythmic movement of light.';

  @override
  String get moodMatcherTitle => 'Mood Matcher';

  @override
  String get moodMatcherDesc =>
      'A fun pattern-matching game to sharpen your focus.';

  @override
  String get aiQuestTitle => 'AI Reflective Quest';

  @override
  String get aiQuestDesc =>
      'Embark on a personal journey of self-discovery powered by AI.';

  @override
  String minCount(int count) {
    return '$count min';
  }

  @override
  String get learnersNook => 'Learner\'s Nook';

  @override
  String get browseTopics => 'Browse Topics';

  @override
  String get myFeed => 'My Feed';

  @override
  String unfollowedCategory(String category) {
    return 'Unfollowed $category';
  }

  @override
  String followingCategory(String category) {
    return 'Following $category';
  }

  @override
  String get noTopicsAvailable => 'No topics available';

  @override
  String get checkBackSoonTopics => 'Check back soon for new topics!';

  @override
  String get feedEmpty => 'Your feed is empty';

  @override
  String get followTopicsToSeeArticles =>
      'Follow some topics to see articles here!';

  @override
  String articlesCount(int count) {
    return '$count articles';
  }

  @override
  String followersCount(int count) {
    return '$count followers';
  }

  @override
  String readMoreAbout(String title) {
    return 'Read more about $title';
  }

  @override
  String get searchPagesHint => 'Search pages...';

  @override
  String get all => 'All';

  @override
  String get noPagesFound => 'No pages found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get noPagesInCategory => 'No pages available in this category';

  @override
  String followerCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count followers',
      one: '1 follower',
    );
    return '$_temp0';
  }

  @override
  String get moodCategory => 'Mood';

  @override
  String get sleepCategory => 'Sleep';

  @override
  String get stressCategory => 'Stress';

  @override
  String get relationshipsCategory => 'Relationships';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get counselorDefaultName => 'Counselor';

  @override
  String get counselorCredentialsDefault => 'Licensed Clinical Psychologist';

  @override
  String get tagsLabel => 'Tags';

  @override
  String partOfTopic(String category) {
    return 'Part of $category topic';
  }

  @override
  String get iveReadThis => 'I\'ve read this!';

  @override
  String get noFollowedPages => 'No followed pages yet';

  @override
  String get startFollowingToSee =>
      'Start following pages to see them here. Discover new content to follow!';

  @override
  String get couldNotLoadFollowedPages => 'Could not load followed pages.';

  @override
  String get couldNotLoadPageDetails => 'Could not load page details';

  @override
  String byAuthor(String author) {
    return 'By $author';
  }

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String get analysisComplete =>
      'Analysis complete! Check for new recommendations.';

  @override
  String get noNewRecommendations => 'No new recommendations at this time.';

  @override
  String get analyzingJourney => 'Analyzing your journey...';

  @override
  String get noAiPicks => 'No AI picks yet';

  @override
  String get aiPicksDesc =>
      'Check back later for personalized recommendations.';

  @override
  String get couldNotLoadAiRecs => 'Could not load AI recommendations.';

  @override
  String get noPicksYet => 'No picks yet!';

  @override
  String get picksDesc =>
      'Keep journaling and exploring! Your personalized picks will appear here as we learn more about your journey.';

  @override
  String get couldNotLoadPicks => 'Could not load your picks.';

  @override
  String get aiPickLabel => 'AI PICK';

  @override
  String get smartPickLabel => 'SMART PICK';

  @override
  String get relatedArticle => 'Related Article:';

  @override
  String errorLabel(String message) {
    return 'Error: $message';
  }

  @override
  String get channels => 'Channels';

  @override
  String get hideComments => 'Hide comments';

  @override
  String get viewComments => 'View comments';

  @override
  String get addCommentHint => 'Add a comment...';

  @override
  String get refreshPostsTooltip => 'Refresh posts';

  @override
  String get followingTooltip => 'Following';

  @override
  String get followTooltip => 'Follow';

  @override
  String reactionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reactions',
      one: '1 reaction',
    );
    return '$_temp0';
  }

  @override
  String get privacyHubTitle => 'Privacy Hub';

  @override
  String get coreTransparency => 'Core Transparency';

  @override
  String get sharingVisibility => 'Sharing & Visibility';

  @override
  String get personalGrowthData => 'Personal Growth Data';

  @override
  String get counselorAccess => 'Counselor Access';

  @override
  String get oversightTitle => 'Guardian Oversight';

  @override
  String get oversightDescription =>
      'Your guardian can see your mood trends but not your private journals.';

  @override
  String get dataPrivacyTitle => 'Data Privacy';

  @override
  String get dataPrivacyDescription =>
      'Your personal data is encrypted and stored securely.';

  @override
  String get aiAnalysisTitle => 'AI Analysis';

  @override
  String get aiAnalysisDescription =>
      'AI analyzes your patterns to provide helpful insights.';

  @override
  String get activitySharingTitle => 'Activity Sharing';

  @override
  String get activitySharingDescription =>
      'You can choose which activities to share with others.';

  @override
  String get totalLabel => 'Total';

  @override
  String get followingLabel => 'Following';

  @override
  String get inThisTabLabel => 'In this tab';

  @override
  String get noChannelsYet => 'No channels yet';

  @override
  String get noChannelsToDiscover => 'No channels to discover';

  @override
  String get followFromDiscoverNote =>
      'Follow channels from the Discover tab to see them here.';

  @override
  String get checkBackLaterForChannels => 'Check back later for new channels!';

  @override
  String get browseAllChannels => 'Browse All Channels';

  @override
  String get noPostsYet => 'No posts yet.';

  @override
  String get counselorUpdatesNote => 'Counselors will post updates here.';

  @override
  String commentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
    );
    return '$_temp0';
  }

  @override
  String get interactionControls => 'Interaction Controls';

  @override
  String get generalParticipation => 'General Participation';

  @override
  String get generalParticipationDesc =>
      'This allows Neuronet AI to analyze your journal entries for emotional patterns. If disabled, entries are stored but not analyzed.';

  @override
  String get aiInsightsSummaries => 'AI Insights & Summaries';

  @override
  String get aiInsightsSummariesDesc =>
      'Your guardian and counselor can view summaries of your emotional trends.';

  @override
  String get safetyAlerts => 'Safety Alerts';

  @override
  String get safetyAlertsDesc =>
      'Real-time notifications sent to your guardian when high-risk patterns are identified.';

  @override
  String get counselorConnection => 'Counselor Connection';

  @override
  String get counselorConnectionDesc =>
      'Allows your school counselor to view your profile and participate in your growth journey.';

  @override
  String get directMessaging => 'Direct Messaging';

  @override
  String get directMessagingDesc =>
      'Enable secure messaging between you, your guardian, and your counselor.';

  @override
  String get couldNotLoadPrivacy => 'Could not load privacy settings.';

  @override
  String get participationPausedNote => 'Paused: General Participation is off';

  @override
  String get guardianOversightNote => 'Guardian Oversight';

  @override
  String get guardianOversightNoteDesc =>
      'Your guardian can see your mood trends but not your private journals.';

  @override
  String get understandingPrivacy => 'Understanding Your Privacy';

  @override
  String get privacyEducation1 =>
      'Your guardian manages these settings to ensure you have the right support.';

  @override
  String get privacyEducation2 =>
      'If you have questions about these settings, we encourage you to discuss them with your guardian.';

  @override
  String get privacyEducation3 =>
      'Neuronet uses AI only for emotional insight, never for clinical diagnosis.';

  @override
  String get yourPrivacyMatters => 'Your Privacy Matters';

  @override
  String get transparencyNote =>
      'We value transparency. Below are the oversight settings currently active for your account.';

  @override
  String get granted => 'Granted';

  @override
  String get revoked => 'Revoked';

  @override
  String get paused => 'Paused';

  @override
  String get composeEntry => 'Compose Entry';

  @override
  String intensityLevel(int level) {
    return 'Nivel $level de 5';
  }

  @override
  String get couldNotLoadAlerts => 'Could not load alerts.';

  @override
  String get you => 'You';

  @override
  String get friend => 'friend';

  @override
  String get refreshingDashboard => 'Refreshing dashboard...';

  @override
  String get skip => 'Omitir';

  @override
  String get next => 'Siguiente';

  @override
  String get getStarted => 'Empezar';

  @override
  String get boxBreathingTitle => 'Box Breathing';

  @override
  String get boxBreathingDesc => 'Calm your mind & find your focus.';

  @override
  String get phasePrepare => 'Prepare';

  @override
  String get phaseInhale => 'Inhale';

  @override
  String get phaseHold => 'Hold';

  @override
  String get phaseExhale => 'Exhale';

  @override
  String get phaseReady => 'Ready?';

  @override
  String get focusOnBreath => 'Focus on your breath...';

  @override
  String get tapOrbToStart => 'Tap the orb to start your quest';

  @override
  String get reflectedOnThis => 'I\'ve reflected on this';

  @override
  String get quest1 =>
      'If your current mood was a weather pattern, what would it look like right now?';

  @override
  String get quest2 =>
      'Identify one thing you can control in your life today, and one thing you can let go.';

  @override
  String get quest3 =>
      'Imagine a future version of yourself who is completely at peace. What\'s the one piece of advice they\'d give you?';

  @override
  String get quest4 =>
      'What\'s a small act of kindness you\'ve witnessed or done recently that stayed with you?';

  @override
  String yourMoodMatchScore(int score) {
    return 'Your Mood Match score: $score';
  }

  @override
  String get howToPlay => 'How to Play';

  @override
  String get moodMatcherInstructions =>
      'Tap the mood icon that matches the target as fast as you can!';

  @override
  String get findThisMood => 'FIND THIS MOOD:';

  @override
  String scoreLabel(int score) {
    return 'Score: $score';
  }

  @override
  String timeLabel(int time) {
    return 'Time: $time';
  }

  @override
  String get pageFollowed => 'Page followed!';

  @override
  String get pageUnfollowed => 'Page unfollowed';

  @override
  String get failedToUnfollowPage => 'Failed to unfollow page';

  @override
  String get failedToFollowPage => 'Failed to follow page';

  @override
  String get unfollowTooltip => 'Unfollow';

  @override
  String get approvalRequired => 'Approval Required';

  @override
  String get needGuardianApprovalDesc =>
      'You need guardian approval to communicate with this counselor. Request approval to start chatting.';

  @override
  String get alertTriggeredRequest => 'Alert-triggered request';

  @override
  String get aiAlertDetails => 'AI Alert Details';

  @override
  String get riskLevelLabel => 'Risk Level: ';

  @override
  String riskScoreLabel(double score) {
    return 'Risk Score: $score%';
  }

  @override
  String get approvedByGuardian => 'Approved by guardian';

  @override
  String get approvalRevoked => 'Approval Revoked';

  @override
  String get guardianRevokedApprovalDesc =>
      'Your guardian has revoked approval for this counselor. You can request approval again to continue chatting.';

  @override
  String get requestDenied => 'Request Denied';

  @override
  String get guardianDeniedRequestDesc =>
      'Your guardian has denied this request. You can submit a new request with more details.';

  @override
  String get checking => 'Checking...';

  @override
  String get failedToLoadAlertDetails => 'Failed to load alert details';

  @override
  String patternNoticedOn(String date) {
    return 'Pattern noticed on $date';
  }

  @override
  String get whatWeNoticed => 'What we noticed';

  @override
  String get feelingsPickedUp => 'Feelings we picked up on';

  @override
  String get groupsHelp => 'Groups that might help';

  @override
  String get channelRecSubtitle =>
      'Highly recommended for you based on recent journals.';

  @override
  String get leftGroup => 'Left group';

  @override
  String joinedGroup(String name) {
    return 'Joined $name!';
  }

  @override
  String get joined => 'JOINED';

  @override
  String get join => 'JOIN';

  @override
  String get thinkingAboutThis => 'Thinking about this?';

  @override
  String get keepJournaling => 'Keep Journaling';

  @override
  String get journalingSubtitle =>
      'Sharing your thoughts helps us find more patterns.';

  @override
  String get chatWithCounselor => 'Chat with Counselor';

  @override
  String get chatWithCounselorSubtitle =>
      'It\'s always good to reach out if you feel like it.';

  @override
  String get alertDisclaimer =>
      'These insights are patterns we noticed based on your activity. They aren\'t a diagnosis or medical advice. We\'re just here to help you understand your emotional journey.';

  @override
  String get moodPattern => 'Mood Pattern';

  @override
  String get energyShift => 'Energy Shift';

  @override
  String get activityUpdate => 'Activity Update';

  @override
  String get mindfulnessPrompt => 'Mindfulness Prompt';

  @override
  String get chatInsight => 'Chat Insight';

  @override
  String get notice => 'Notice';

  @override
  String get emotionSadness => '😔 Feeling down';

  @override
  String get emotionLoneliness => '🫂 Feeling alone';

  @override
  String get emotionHopelessness => '💭 Tough thoughts';

  @override
  String get emotionFear => '😨 Feeling scared';

  @override
  String get emotionAnger => '😤 Feeling frustrated';

  @override
  String get emotionNervousness => '😰 Feeling nervous';

  @override
  String get emotionAnxiety => '🌊 Waves of worry';

  @override
  String get emotionDisappointment => '😞 Disappointed';

  @override
  String get emotionGrief => '💔 Heavy heart';

  @override
  String get emotionAnnoyance => '😒 Annoyed';

  @override
  String get emotionConfusion => '🤔 Confused';

  @override
  String get noDescriptionAvailable => 'No description available';

  @override
  String get followChannelTooltip => 'Follow channel';

  @override
  String get channelLabel => 'Channel';

  @override
  String get userLabel => 'User';

  @override
  String get unauthorizedAdolescentAccess =>
      'Unauthorized access: This account does not have Adolescent privileges.';

  @override
  String get unauthorizedRoleMismatch =>
      'Unauthorized access: Account role mismatch.';

  @override
  String get invalidEmailError => 'Please enter a valid email address.';

  @override
  String get callError => 'Call Error';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get unknownCaller => 'Unknown Caller';

  @override
  String get calling => 'Calling...';

  @override
  String get endCall => 'End Call';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get connected => 'Connected';

  @override
  String get connecting => 'Connecting';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get camera => 'Camera';

  @override
  String get camOff => 'Cam Off';

  @override
  String get flip => 'Flip';

  @override
  String get speaker => 'Speaker';

  @override
  String get insufficientData => 'Insufficient data for analysis.';

  @override
  String get micPermissionRequired =>
      'Microphone permission is required to record voice messages.';

  @override
  String failedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String failedToPickVideo(String error) {
    return 'Failed to pick video: $error';
  }

  @override
  String get playVideo => 'Play Video';

  @override
  String get shareMedia => 'Share Media';

  @override
  String get gallery => 'Gallery';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get videoLabel => 'Video';

  @override
  String get preparingMedia => 'Preparing media...';

  @override
  String get tapToDownload => 'Tap to download';

  @override
  String get voiceLabel => 'Voice';

  @override
  String get contactLabel => 'Contact';

  @override
  String get emptyMessage => '(empty message)';

  @override
  String get attachmentLabel => 'Attachment';

  @override
  String get mindfulFocusTip => 'Keep your head still and follow the dot.';

  @override
  String get supportGroup => 'Support Group';

  @override
  String get educationalLabel => 'Educational';

  @override
  String get supportLabel => 'Support';

  @override
  String get discussionLabel => 'Discussion';

  @override
  String get resourcesLabel => 'Resources';

  @override
  String get activeLabel => 'Active';

  @override
  String get postLabel => 'Post';

  @override
  String get safeSpaceCounselor =>
      'Safe space for counselor guidance and updates.';
}
