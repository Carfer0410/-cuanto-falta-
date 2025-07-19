import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('es'), // Español
    Locale('en'), // Inglés
    Locale('pt'), // Portugués
    Locale('fr'), // Francés
    Locale('de'), // Alemán
    Locale('it'), // Italiano
    Locale('ja'), // Japonés
    Locale('ko'), // Coreano
    Locale('zh'), // Chino
    Locale('ar'), // Árabe
    Locale('ru'), // Ruso
    Locale('hi'), // Hindi
  ];

  // ========== APP GENERAL ==========
  String get appTitle => _translate('appTitle');
  String get loading => _translate('loading');
  String get error => _translate('error');
  String get save => _translate('save');
  String get cancel => _translate('cancel');
  String get delete => _translate('delete');
  String get edit => _translate('edit');
  String get ok => _translate('ok');
  String get yes => _translate('yes');
  String get no => _translate('no');
  String get confirm => _translate('confirm');

  // ========== NAVEGACIÓN ==========
  String get homeTab => _translate('homeTab');
  String get challengesTab => _translate('challengesTab');
  String get settingsTab => _translate('settingsTab');

  // ========== EVENTOS ==========
  String get events => _translate('events');
  String get addEvent => _translate('addEvent');
  String get eventTitle => _translate('eventTitle');
  String get eventTitleHint => _translate('eventTitleHint');
  String get selectDate => _translate('selectDate');
  String get chooseDate => _translate('chooseDate');
  String get targetDate => _translate('targetDate');
  String get selectCategory => _translate('selectCategory');
  String get saveEvent => _translate('saveEvent');
  String get noEvents => _translate('noEvents');
  String get addOne => _translate('addOne');
  String get deleteEvent => _translate('deleteEvent');
  String get deleteEventConfirm => _translate('deleteEventConfirm');

  // Categorías de eventos
  String get categoryBirthday => _translate('categoryBirthday');
  String get categoryWedding => _translate('categoryWedding');
  String get categoryVacation => _translate('categoryVacation');
  String get categoryExam => _translate('categoryExam');
  String get categoryTrip => _translate('categoryTrip');
  String get categoryGraduation => _translate('categoryGraduation');
  String get categoryConcert => _translate('categoryConcert');
  String get categoryMeeting => _translate('categoryMeeting');
  String get categoryProject => _translate('categoryProject');
  String get categoryMoving => _translate('categoryMoving');
  String get categoryInterview => _translate('categoryInterview');
  String get categoryChristmas => _translate('categoryChristmas');
  String get categoryNewYear => _translate('categoryNewYear');
  String get categoryMothersDay => _translate('categoryMothersDay');
  String get categoryFathersDay => _translate('categoryFathersDay');
  String get categoryValentines => _translate('categoryValentines');
  String get categoryBlackFriday => _translate('categoryBlackFriday');
  String get categoryVaccine => _translate('categoryVaccine');
  String get categoryOther => _translate('categoryOther');

  // Mensajes de categorías
  String get msgBirthday => _translate('msgBirthday');
  String get msgWedding => _translate('msgWedding');
  String get msgVacation => _translate('msgVacation');
  String get msgExam => _translate('msgExam');
  String get msgTrip => _translate('msgTrip');
  String get msgGraduation => _translate('msgGraduation');
  String get msgConcert => _translate('msgConcert');
  String get msgMeeting => _translate('msgMeeting');
  String get msgProject => _translate('msgProject');
  String get msgMoving => _translate('msgMoving');
  String get msgInterview => _translate('msgInterview');
  String get msgChristmas => _translate('msgChristmas');
  String get msgNewYear => _translate('msgNewYear');
  String get msgMothersDay => _translate('msgMothersDay');
  String get msgFathersDay => _translate('msgFathersDay');
  String get msgValentines => _translate('msgValentines');
  String get msgBlackFriday => _translate('msgBlackFriday');
  String get msgVaccine => _translate('msgVaccine');
  String get msgOther => _translate('msgOther');

  // ========== RETOS/CHALLENGES ==========
  String get challenges => _translate('challenges');
  String get addChallenge => _translate('addChallenge');
  String get challengeTitle => _translate('challengeTitle');
  String get challengeTitleHint => _translate('challengeTitleHint');
  String get startDate => _translate('startDate');
  String get isNegativeHabit => _translate('isNegativeHabit');
  String get positiveHabit => _translate('positiveHabit');
  String get negativeHabit => _translate('negativeHabit');
  String get saveChallenge => _translate('saveChallenge');
  String get noChallenges => _translate('noChallenges');
  String get confirmToday => _translate('confirmToday');
  String get confirmed => _translate('confirmed');
  String get deleteChallenge => _translate('deleteChallenge');
  String get deleteChallengeConfirm => _translate('deleteChallengeConfirm');

  // ========== CONFIGURACIÓN ==========
  String get settings => _translate('settings');
  String get appearance => _translate('appearance');
  String get theme => _translate('theme');
  String get lightTheme => _translate('lightTheme');
  String get darkTheme => _translate('darkTheme');
  String get systemTheme => _translate('systemTheme');
  String get notifications => _translate('notifications');
  String get eventNotifications => _translate('eventNotifications');
  String get challengeNotifications => _translate('challengeNotifications');
  String get notificationFrequency => _translate('notificationFrequency');
  String get eventFrequency => _translate('eventFrequency');
  String get challengeFrequency => _translate('challengeFrequency');
  String get sound => _translate('sound');
  String get vibration => _translate('vibration');
  String get advanced => _translate('advanced');
  String get language => _translate('language');
  String get about => _translate('about');
  String get version => _translate('version');

  // ========== TIEMPO ==========
  String get timeLeft => _translate('timeLeft');
  String get days => _translate('days');
  String get hours => _translate('hours');
  String get minutes => _translate('minutes');
  String get seconds => _translate('seconds');
  String get day => _translate('day');
  String get hour => _translate('hour');
  String get minute => _translate('minute');
  String get second => _translate('second');

  // Abreviaciones de tiempo
  String get daysShort => _translate('daysShort');
  String get hoursShort => _translate('hoursShort');
  String get minutesShort => _translate('minutesShort');
  String get secondsShort => _translate('secondsShort');

  // ========== NOTIFICACIONES ==========
  String get notificationInfo => _translate('notificationInfo');
  String get eventReminders => _translate('eventReminders');
  String get motivationalNotifications => _translate('motivationalNotifications');
  String get systemVerification => _translate('systemVerification');
  String get antiSpamSystem => _translate('antiSpamSystem');

  // ========== FORMATO DE FECHA ==========
  String formatDate(DateTime date) {
    return DateFormat.yMd(locale.languageCode).format(date);
  }

  String formatDateLong(DateTime date) {
    return DateFormat.yMMMMEEEEd(locale.languageCode).format(date);
  }

  // ========== TIEMPO RESTANTE ==========
  String timeRemaining(int days, int hours, int minutes, int seconds) {
    return _translate('timeRemaining')
        .replaceAll('{days}', days.toString())
        .replaceAll('{hours}', hours.toString().padLeft(2, '0'))
        .replaceAll('{minutes}', minutes.toString().padLeft(2, '0'))
        .replaceAll('{seconds}', seconds.toString().padLeft(2, '0'));
  }

  // Método principal de traducción
  String _translate(String key) {
    return _localizedStrings[locale.languageCode]?[key] ?? 
           _localizedStrings['en']?[key] ?? 
           '[$key]';
  }

  // Base de datos de traducciones
  static const Map<String, Map<String, String>> _localizedStrings = {
    'es': {
      // APP GENERAL
      'appTitle': '¿Cuánto Falta?',
      'loading': 'Cargando...',
      'error': 'Error',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'edit': 'Editar',
      'ok': 'OK',
      'yes': 'Sí',
      'no': 'No',
      'confirm': 'Confirmar',

      // NAVEGACIÓN
      'homeTab': 'Eventos',
      'challengesTab': 'Retos',
      'settingsTab': 'Configuración',

      // EVENTOS
      'events': 'Eventos',
      'addEvent': 'Agregar Evento',
      'eventTitle': 'Nombre del evento',
      'eventTitleHint': 'Ej: Mi cumpleaños',
      'selectDate': 'Seleccione una fecha',
      'chooseDate': 'Elegir fecha',
      'targetDate': 'Fecha objetivo',
      'selectCategory': 'Seleccione una categoría',
      'saveEvent': 'Guardar evento',
      'noEvents': 'Aún no hay eventos. ¡Agrega uno!',
      'addOne': '¡Agrega uno!',
      'deleteEvent': 'Eliminar evento',
      'deleteEventConfirm': '¿Seguro que deseas eliminar este evento? Esta acción no se puede deshacer.',

      // CATEGORÍAS
      'categoryBirthday': 'Cumpleaños',
      'categoryWedding': 'Boda',
      'categoryVacation': 'Vacaciones',
      'categoryExam': 'Examen',
      'categoryTrip': 'Viaje',
      'categoryGraduation': 'Graduación',
      'categoryConcert': 'Concierto',
      'categoryMeeting': 'Reunión',
      'categoryProject': 'Entrega de proyecto',
      'categoryMoving': 'Mudanza',
      'categoryInterview': 'Entrevista',
      'categoryChristmas': 'Navidad',
      'categoryNewYear': 'Año Nuevo',
      'categoryMothersDay': 'Día de la Madre',
      'categoryFathersDay': 'Día del Padre',
      'categoryValentines': 'San Valentín',
      'categoryBlackFriday': 'Black Friday',
      'categoryVaccine': 'Vacuna',
      'categoryOther': 'Otro',

      // MENSAJES DE CATEGORÍAS
      'msgBirthday': '🎂 ¡No se te olvide el pastel!',
      'msgWedding': '💍 ¡El gran día se acerca, que viva el amor!',
      'msgVacation': '🧳 ¡A empacar maletas desde ya!',
      'msgExam': '📚 ¡Estudia y confía en ti, vas a lograrlo!',
      'msgTrip': '✈️ ¡Prepara tu itinerario y disfruta la aventura!',
      'msgGraduation': '🎓 ¡Un logro más cerca, sigue así!',
      'msgConcert': '🎵 ¡Pronto a cantar y disfrutar tu música favorita!',
      'msgMeeting': '🤝 ¡Ya casi es hora de ver a todos!',
      'msgProject': '📝 ¡Últimos detalles, tú puedes!',
      'msgMoving': '🏡 ¡Un nuevo hogar te espera!',
      'msgInterview': '💼 ¡Confía en ti, el éxito está cerca!',
      'msgChristmas': '🎄 Ve preparando los regalos',
      'msgNewYear': '🎉 ¡El año nuevo se acerca, prepárate!',
      'msgMothersDay': '🌷 ¡Prepara un detalle especial para mamá!',
      'msgFathersDay': '👔 ¡Haz sentir especial a papá!',
      'msgValentines': '💌 ¡El amor está en el aire!',
      'msgBlackFriday': '🛍️ ¡Prepara tu lista de compras!',
      'msgVaccine': '💉 ¡Cuida tu salud, ya casi es el día!',
      'msgOther': '⏳ Cada día estás más cerca de tu meta.',

      // RETOS
      'challenges': 'Retos',
      'addChallenge': 'Agregar Reto',
      'challengeTitle': 'Nombre del reto',
      'challengeTitleHint': 'Ej: dejar de fumar',
      'startDate': 'Fecha de inicio',
      'isNegativeHabit': '¿Es un hábito que quieres dejar?',
      'positiveHabit': 'Hábito positivo (empezar a hacer)',
      'negativeHabit': 'Hábito negativo (dejar de hacer)',
      'saveChallenge': 'Guardar reto',
      'noChallenges': 'Aún no hay retos. ¡Agrega uno!',
      'confirmToday': 'Confirmar hoy',
      'confirmed': 'Confirmado',
      'deleteChallenge': 'Eliminar reto',
      'deleteChallengeConfirm': '¿Seguro que deseas eliminar este reto? Esta acción no se puede deshacer.',

      // CONFIGURACIÓN
      'settings': 'Configuración',
      'appearance': 'Apariencia',
      'theme': 'Tema',
      'lightTheme': 'Claro',
      'darkTheme': 'Oscuro',
      'systemTheme': 'Sistema',
      'notifications': 'Notificaciones',
      'eventNotifications': 'Notificaciones de eventos',
      'challengeNotifications': 'Notificaciones de retos',
      'notificationFrequency': 'Frecuencia de notificaciones',
      'eventFrequency': 'Frecuencia de eventos',
      'challengeFrequency': 'Frecuencia de retos',
      'sound': 'Sonido',
      'vibration': 'Vibración',
      'advanced': 'Avanzado',
      'language': 'Idioma',
      'about': 'Acerca de',
      'version': 'Versión',

      // TIEMPO
      'timeLeft': 'Tiempo restante',
      'days': 'días',
      'hours': 'horas',
      'minutes': 'minutos',
      'seconds': 'segundos',
      'day': 'día',
      'hour': 'hora',
      'minute': 'minuto',
      'second': 'segundo',
      'daysShort': 'd',
      'hoursShort': 'h',
      'minutesShort': 'm',
      'secondsShort': 's',

      // TIEMPO RESTANTE
      'timeRemaining': 'Falta {days}d {hours}h {minutes}m {seconds}s',

      // NOTIFICACIONES
      'notificationInfo': 'Información de Notificaciones',
      'eventReminders': 'Recordatorios de Eventos',
      'motivationalNotifications': 'Notificaciones Motivacionales',
      'systemVerification': 'Verificación del Sistema',
      'antiSpamSystem': 'Sistema Anti-Spam',
    },

    'en': {
      // APP GENERAL
      'appTitle': 'How Much Left?',
      'loading': 'Loading...',
      'error': 'Error',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'edit': 'Edit',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'confirm': 'Confirm',

      // NAVEGACIÓN
      'homeTab': 'Events',
      'challengesTab': 'Challenges',
      'settingsTab': 'Settings',

      // EVENTOS
      'events': 'Events',
      'addEvent': 'Add Event',
      'eventTitle': 'Event name',
      'eventTitleHint': 'Ex: My birthday',
      'selectDate': 'Select a date',
      'chooseDate': 'Choose date',
      'targetDate': 'Target date',
      'selectCategory': 'Select a category',
      'saveEvent': 'Save event',
      'noEvents': 'No events yet. Add one!',
      'addOne': 'Add one!',
      'deleteEvent': 'Delete event',
      'deleteEventConfirm': 'Are you sure you want to delete this event? This action cannot be undone.',

      // CATEGORÍAS
      'categoryBirthday': 'Birthday',
      'categoryWedding': 'Wedding',
      'categoryVacation': 'Vacation',
      'categoryExam': 'Exam',
      'categoryTrip': 'Trip',
      'categoryGraduation': 'Graduation',
      'categoryConcert': 'Concert',
      'categoryMeeting': 'Meeting',
      'categoryProject': 'Project delivery',
      'categoryMoving': 'Moving',
      'categoryInterview': 'Interview',
      'categoryChristmas': 'Christmas',
      'categoryNewYear': 'New Year',
      'categoryMothersDay': 'Mother\'s Day',
      'categoryFathersDay': 'Father\'s Day',
      'categoryValentines': 'Valentine\'s Day',
      'categoryBlackFriday': 'Black Friday',
      'categoryVaccine': 'Vaccine',
      'categoryOther': 'Other',

      // MENSAJES DE CATEGORÍAS
      'msgBirthday': '🎂 Don\'t forget the cake!',
      'msgWedding': '💍 The big day is coming, long live love!',
      'msgVacation': '🧳 Time to pack your bags!',
      'msgExam': '📚 Study and trust yourself, you\'ll make it!',
      'msgTrip': '✈️ Prepare your itinerary and enjoy the adventure!',
      'msgGraduation': '🎓 One achievement closer, keep it up!',
      'msgConcert': '🎵 Soon to sing and enjoy your favorite music!',
      'msgMeeting': '🤝 Almost time to see everyone!',
      'msgProject': '📝 Final details, you can do it!',
      'msgMoving': '🏡 A new home awaits you!',
      'msgInterview': '💼 Trust yourself, success is near!',
      'msgChristmas': '🎄 Get ready to prepare the gifts',
      'msgNewYear': '🎉 The new year is coming, get ready!',
      'msgMothersDay': '🌷 Prepare something special for mom!',
      'msgFathersDay': '👔 Make dad feel special!',
      'msgValentines': '💌 Love is in the air!',
      'msgBlackFriday': '🛍️ Prepare your shopping list!',
      'msgVaccine': '💉 Take care of your health, the day is almost here!',
      'msgOther': '⏳ Every day you\'re closer to your goal.',

      // RETOS
      'challenges': 'Challenges',
      'addChallenge': 'Add Challenge',
      'challengeTitle': 'Challenge name',
      'challengeTitleHint': 'Ex: quit smoking',
      'startDate': 'Start date',
      'isNegativeHabit': 'Is it a habit you want to quit?',
      'positiveHabit': 'Positive habit (start doing)',
      'negativeHabit': 'Negative habit (stop doing)',
      'saveChallenge': 'Save challenge',
      'noChallenges': 'No challenges yet. Add one!',
      'confirmToday': 'Confirm today',
      'confirmed': 'Confirmed',
      'deleteChallenge': 'Delete challenge',
      'deleteChallengeConfirm': 'Are you sure you want to delete this challenge? This action cannot be undone.',

      // CONFIGURACIÓN
      'settings': 'Settings',
      'appearance': 'Appearance',
      'theme': 'Theme',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'systemTheme': 'System',
      'notifications': 'Notifications',
      'eventNotifications': 'Event notifications',
      'challengeNotifications': 'Challenge notifications',
      'notificationFrequency': 'Notification frequency',
      'eventFrequency': 'Event frequency',
      'challengeFrequency': 'Challenge frequency',
      'sound': 'Sound',
      'vibration': 'Vibration',
      'advanced': 'Advanced',
      'language': 'Language',
      'about': 'About',
      'version': 'Version',

      // TIEMPO
      'timeLeft': 'Time left',
      'days': 'days',
      'hours': 'hours',
      'minutes': 'minutes',
      'seconds': 'seconds',
      'day': 'day',
      'hour': 'hour',
      'minute': 'minute',
      'second': 'second',
      'daysShort': 'd',
      'hoursShort': 'h',
      'minutesShort': 'm',
      'secondsShort': 's',

      // TIEMPO RESTANTE
      'timeRemaining': '{days}d {hours}h {minutes}m {seconds}s left',

      // NOTIFICACIONES
      'notificationInfo': 'Notification Information',
      'eventReminders': 'Event Reminders',
      'motivationalNotifications': 'Motivational Notifications',
      'systemVerification': 'System Verification',
      'antiSpamSystem': 'Anti-Spam System',
    },

    // PORTUGUÉS (básico por ahora)
    'pt': {
      'appTitle': 'Quanto Falta?',
      'homeTab': 'Eventos',
      'challengesTab': 'Desafios',
      'settingsTab': 'Configurações',
      'events': 'Eventos',
      'challenges': 'Desafios',
      'settings': 'Configurações',
      'save': 'Salvar',
      'cancel': 'Cancelar',
      'delete': 'Excluir',
      'ok': 'OK',
      'timeRemaining': 'Falta {days}d {hours}h {minutes}m {seconds}s',
    },

    // FRANCÉS (básico por ahora)
    'fr': {
      'appTitle': 'Combien reste-t-il?',
      'homeTab': 'Événements',
      'challengesTab': 'Défis',
      'settingsTab': 'Paramètres',
      'events': 'Événements',
      'challenges': 'Défis',
      'settings': 'Paramètres',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'ok': 'OK',
      'timeRemaining': 'Il reste {days}j {hours}h {minutes}m {seconds}s',
    },

    // Otros idiomas se pueden agregar aquí...
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.contains(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
