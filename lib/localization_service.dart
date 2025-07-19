import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();
  
  LocalizationService._();

  String _currentLanguage = 'es'; // Español por defecto
  
  // Idiomas soportados
  static const supportedLanguages = {
    'es': 'Español',
    'en': 'English',
    'pt': 'Português',
    'fr': 'Français',
    'de': 'Deutsch',
    'it': 'Italiano',
    'ja': '日本語',
    'ko': '한국어',
    'zh': '中文',
    'ar': 'العربية',
    'ru': 'Русский',
    'hi': 'हिन्दी',
  };

  String get currentLanguage => _currentLanguage;
  
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'es';
  }
  
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    _currentLanguage = languageCode;
    notifyListeners(); // Notificar a todos los widgets que escuchan
  }

  // Formato de fecha automático según el idioma
  String formatDate(DateTime date) {
    switch (_currentLanguage) {
      case 'en':
        return DateFormat('MM/dd/yyyy').format(date); // Formato US
      case 'de':
      case 'fr':
      case 'it':
        return DateFormat('dd.MM.yyyy').format(date); // Formato europeo con puntos
      case 'ja':
        return DateFormat('yyyy/MM/dd').format(date); // Formato japonés
      case 'zh':
        return DateFormat('yyyy年MM月dd日').format(date); // Formato chino
      case 'ar':
        return DateFormat('dd/MM/yyyy').format(date); // Formato árabe
      default:
        return DateFormat('dd/MM/yyyy').format(date); // Formato español/latino
    }
  }

  String formatDateLong(DateTime date) {
    switch (_currentLanguage) {
      case 'en':
        return DateFormat('EEEE, MMMM d, yyyy', 'en').format(date);
      case 'de':
        return DateFormat('EEEE, d. MMMM yyyy', 'de').format(date);
      case 'fr':
        return DateFormat('EEEE d MMMM yyyy', 'fr').format(date);
      case 'it':
        return DateFormat('EEEE d MMMM yyyy', 'it').format(date);
      case 'pt':
        return DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy', 'pt').format(date);
      default:
        return DateFormat('EEEE, d \'de\' MMMM \'de\' yyyy', 'es').format(date);
    }
  }

  // Método principal de traducción
  String t(String key) {
    return _translations[_currentLanguage]?[key] ?? 
           _translations['en']?[key] ?? 
           key;
  }

  // Traducción con parámetros
  String tr(String key, {Map<String, dynamic>? args}) {
    String translation = t(key);
    if (args != null) {
      args.forEach((key, value) {
        translation = translation.replaceAll('{$key}', value.toString());
      });
    }
    return translation;
  }

  // Tiempo restante formateado
  String timeRemaining(int days, int hours, int minutes, int seconds) {
    return tr('timeRemaining', args: {
      'days': days,
      'hours': hours.toString().padLeft(2, '0'),
      'minutes': minutes.toString().padLeft(2, '0'),
      'seconds': seconds.toString().padLeft(2, '0'),
    });
  }

  // Base de datos de traducciones completa
  static const Map<String, Map<String, String>> _translations = {
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
      'addEvent': 'Nuevo evento',
      'eventTitle': 'Nombre del evento',
      'eventTitleHint': 'Ej: Mi cumpleaños',
      'selectDate': 'Seleccionar fecha',
      'chooseDate': 'Elegir fecha',
      'targetDate': 'Fecha objetivo',
      'selectCategory': 'Seleccionar categoría',
      'saveEvent': 'Guardar evento',
      'noEvents': 'Aún no hay eventos. ¡Agrega uno!',
      'deleteEvent': 'Eliminar evento',
      'deleteEventConfirm': '¿Seguro que deseas eliminar este evento? Esta acción no se puede deshacer.',

      // CATEGORÍAS DE EVENTOS
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
      'darkTheme': 'Modo oscuro',
      'systemTheme': 'Sistema',
      'notifications': 'Notificaciones',
      'eventNotifications': 'Recordatorios de Eventos',
      'challengeNotifications': 'Notificaciones Motivacionales',
      'sound': 'Sonido',
      'vibration': 'Vibración',
      'language': 'Idioma',
      'about': 'Acerca de',
      'version': 'Versión',
      'advancedSettings': 'Configuración Avanzada',
      'eventFrequency': 'Frecuencia de verificación de eventos',
      'challengeFrequency': 'Frecuencia de verificación de retos',
      'systemStatus': 'Estado del sistema',
      'notificationInfo': 'Acerca de las notificaciones',
      'soundEnabled': 'Reproducir sonido con las notificaciones',
      'vibrationEnabled': 'Vibrar el dispositivo con las notificaciones',
      'themeDescription': 'Cambia entre tema claro y oscuro',

      // TIEMPO
      'timeLeft': 'Tiempo restante',
      'timeRemaining': 'Falta {days}d {hours}h {minutes}m {seconds}s',
      'timeElapsed': 'Llevas {days}d {hours}h {minutes}m {seconds}s',
      'days': 'días',
      'hours': 'horas',
      'minutes': 'minutos',
      'seconds': 'segundos',
      'daysShort': 'd',
      'hoursShort': 'h',
      'minutesShort': 'm',
      'secondsShort': 's',
      'remaining': 'Falta',
      'elapsed': 'Llevas',
      'everySecondCounts': 'Cada segundo cuenta.',
      'youHave': '¡Llevas',
      'keepGoing': '¡Sigue así!',

      // NOTIFICACIONES
      'notificationEventTitle': '📅 {eventTitle} - {days} días',
      'notificationEventBody': 'Faltan {days} días para "{eventTitle}".',
      'notificationTodayTitle': '🎯 ¡HOY es "{eventTitle}"!',
      'notificationTodayBody': '🎊 ¡El día que esperabas ha llegado!',
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
      'addEvent': 'New event',
      'eventTitle': 'Event name',
      'eventTitleHint': 'Ex: My birthday',
      'selectDate': 'Select date',
      'chooseDate': 'Choose date',
      'targetDate': 'Target date',
      'selectCategory': 'Select category',
      'saveEvent': 'Save event',
      'noEvents': 'No events yet. Add one!',
      'deleteEvent': 'Delete event',
      'deleteEventConfirm': 'Are you sure you want to delete this event? This action cannot be undone.',

      // CATEGORÍAS DE EVENTOS
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
      'darkTheme': 'Dark mode',
      'systemTheme': 'System',
      'notifications': 'Notifications',
      'eventNotifications': 'Event Reminders',
      'challengeNotifications': 'Motivational Notifications',
      'sound': 'Sound',
      'vibration': 'Vibration',
      'language': 'Language',
      'about': 'About',
      'version': 'Version',
      'advancedSettings': 'Advanced Settings',
      'eventFrequency': 'Event verification frequency',
      'challengeFrequency': 'Challenge verification frequency',
      'systemStatus': 'System status',
      'notificationInfo': 'About notifications',
      'soundEnabled': 'Play sound with notifications',
      'vibrationEnabled': 'Vibrate device with notifications',
      'themeDescription': 'Switch between light and dark theme',

      // TIEMPO
      'timeLeft': 'Time left',
      'timeRemaining': '{days}d {hours}h {minutes}m {seconds}s left',
      'timeElapsed': '{days}d {hours}h {minutes}m {seconds}s elapsed',
      'days': 'days',
      'hours': 'hours',
      'minutes': 'minutes',
      'seconds': 'seconds',
      'daysShort': 'd',
      'hoursShort': 'h',
      'minutesShort': 'm',
      'secondsShort': 's',
      'remaining': 'Left',
      'elapsed': 'Elapsed',
      'everySecondCounts': 'Keep going, every second counts',
      'youHave': 'You have',
      'keepGoing': 'Keep going!',

      // NOTIFICACIONES
      'notificationEventTitle': '📅 {eventTitle} - {days} days',
      'notificationEventBody': '{days} days left for "{eventTitle}".',
      'notificationTodayTitle': '🎯 TODAY is "{eventTitle}"!',
      'notificationTodayBody': '🎊 The day you were waiting for has arrived!',
    },

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
      'remaining': 'Faltam',
      'elapsed': 'Decorrido',
      'everySecondCounts': 'Cada segundo conta.',
      'youHave': 'Você tem',
      'keepGoing': 'Continue assim!',
      'language': 'Idioma',
    },

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
      'remaining': 'Reste',
      'elapsed': 'Écoulé',
      'everySecondCounts': 'Chaque seconde compte.',
      'youHave': 'Vous avez',
      'keepGoing': 'Continuez !',
      'language': 'Langue',
    },

    'de': {
      'appTitle': 'Wie viel ist übrig?',
      'homeTab': 'Ereignisse',
      'challengesTab': 'Herausforderungen',
      'settingsTab': 'Einstellungen',
      'events': 'Ereignisse',
      'challenges': 'Herausforderungen',
      'settings': 'Einstellungen',
      'save': 'Speichern',
      'cancel': 'Abbrechen',
      'delete': 'Löschen',
      'ok': 'OK',
      'timeRemaining': 'Noch {days}T {hours}Std {minutes}Min {seconds}Sek',
      'remaining': 'Verbleibend',
      'elapsed': 'Vergangen',
      'everySecondCounts': 'Jede Sekunde zählt.',
      'youHave': 'Du hast',
      'keepGoing': 'Weiter so!',
      'language': 'Sprache',
    },

    'it': {
      'appTitle': 'Quanto manca?',
      'homeTab': 'Eventi',
      'challengesTab': 'Sfide',
      'settingsTab': 'Impostazioni',
      'events': 'Eventi',
      'challenges': 'Sfide',
      'settings': 'Impostazioni',
      'save': 'Salva',
      'cancel': 'Annulla',
      'delete': 'Elimina',
      'ok': 'OK',
      'timeRemaining': 'Mancano {days}g {hours}h {minutes}m {seconds}s',
      'remaining': 'Mancano',
      'elapsed': 'Trascorso',
      'everySecondCounts': 'Ogni secondo conta.',
      'youHave': 'Hai',
      'keepGoing': 'Continua così!',
      'language': 'Lingua',
    },

    'ja': {
      'appTitle': 'あとどのくらい？',
      'homeTab': 'イベント',
      'challengesTab': 'チャレンジ',
      'settingsTab': '設定',
      'events': 'イベント',
      'challenges': 'チャレンジ',
      'settings': '設定',
      'save': '保存',
      'cancel': 'キャンセル',
      'delete': '削除',
      'ok': 'OK',
      'timeRemaining': 'あと{days}日{hours}時{minutes}分{seconds}秒',
      'language': '言語',
    },

    'ko': {
      'appTitle': '얼마나 남았나요?',
      'homeTab': '이벤트',
      'challengesTab': '도전',
      'settingsTab': '설정',
      'events': '이벤트',
      'challenges': '도전',
      'settings': '설정',
      'save': '저장',
      'cancel': '취소',
      'delete': '삭제',
      'ok': '확인',
      'timeRemaining': '{days}일 {hours}시 {minutes}분 {seconds}초 남음',
      'language': '언어',
    },

    'zh': {
      'appTitle': '还剩多少？',
      'homeTab': '事件',
      'challengesTab': '挑战',
      'settingsTab': '设置',
      'events': '事件',
      'challenges': '挑战',
      'settings': '设置',
      'save': '保存',
      'cancel': '取消',
      'delete': '删除',
      'ok': '确定',
      'timeRemaining': '还剩{days}天{hours}小时{minutes}分{seconds}秒',
      'language': '语言',
    },

    'ar': {
      'appTitle': 'كم تبقى؟',
      'homeTab': 'الأحداث',
      'challengesTab': 'التحديات',
      'settingsTab': 'الإعدادات',
      'events': 'الأحداث',
      'challenges': 'التحديات',
      'settings': 'الإعدادات',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'ok': 'موافق',
      'timeRemaining': 'يتبقى {days} يوم {hours} ساعة {minutes} دقيقة {seconds} ثانية',
      'language': 'اللغة',
    },

    'ru': {
      'appTitle': 'Сколько осталось?',
      'homeTab': 'События',
      'challengesTab': 'Вызовы',
      'settingsTab': 'Настройки',
      'events': 'События',
      'challenges': 'Вызовы',
      'settings': 'Настройки',
      'save': 'Сохранить',
      'cancel': 'Отмена',
      'delete': 'Удалить',
      'ok': 'ОК',
      'timeRemaining': 'Осталось {days}д {hours}ч {minutes}м {seconds}с',
      'language': 'Язык',
    },

    'hi': {
      'appTitle': 'कितना बचा है?',
      'homeTab': 'इवेंट्स',
      'challengesTab': 'चुनौतियां',
      'settingsTab': 'सेटिंग्स',
      'events': 'इवेंट्स',
      'challenges': 'चुनौतियां',
      'settings': 'सेटिंग्स',
      'save': 'सेव करें',
      'cancel': 'रद्द करें',
      'delete': 'डिलीट करें',
      'ok': 'ओके',
      'timeRemaining': '{days} दिन {hours} घंटे {minutes} मिनट {seconds} सेकंड बचे',
      'language': 'भाषा',
    },
  };
}
