import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification_navigation_service.dart';
import 'notification_center_service.dart';
import 'notification_center_models.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      // Inicializar timezone
      tz.initializeTimeZones();
      
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_notification');
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      
      // Inicializar plugin con manejo de errores
      bool initialized = await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
          print('📱 Notificación tocada: ${notificationResponse.payload}');
          // 🆕 NUEVA FUNCIONALIDAD: Manejar navegación automática
          NotificationNavigationService.handleNotificationNavigation(notificationResponse.payload);
        },
      ) ?? false;
      
      if (!initialized) {
        print('❌ Error: No se pudo inicializar el servicio de notificaciones');
        return;
      }
      
      print('✅ NotificationService inicializado correctamente');
      
      // Crear canal de notificaciones en Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'event_channel',
        'Eventos',
        description: 'Notificaciones de eventos programados',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(channel);
        print('✅ Canal de notificaciones creado');
        
        // Solicitar permisos
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
        print('✅ Permisos solicitados');
      }
    } catch (e) {
      print('❌ Error inicializando NotificationService: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,  // 🆕 NUEVO: Payload para navegación
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_channel',
      'Eventos',
      channelDescription: 'Notificaciones de eventos programados',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      icon: '@mipmap/ic_notification',                              // Tu logo como icono pequeño
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_notification'), // Tu logo como icono grande
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    // Convertir a TZDateTime usando la zona horaria local
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    print('Programando notificación para: $scheduledTZDate');
    print('Hora actual: ${tz.TZDateTime.now(tz.local)}');
    
    // Verificar si tenemos permiso para alarmas exactas
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    bool? canScheduleExactAlarms = await androidImplementation?.canScheduleExactNotifications();
    print('¿Puede programar alarmas exactas?: $canScheduleExactAlarms');
    
    // Intentar con alarmas exactas primero, si falla usar inexactas
    try {
      if (canScheduleExactAlarms == true) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTZDate,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,  // 🆕 NUEVO: Incluir payload
        );
        print('✅ Notificación programada con alarma exacta');
      } else {
        // Usar modo inexacto si no tenemos permisos
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTZDate,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,  // 🆕 NUEVO: Incluir payload
        );
        print('⚠️ Notificación programada con alarma inexacta (sin permisos exactos)');
      }
    } catch (e) {
      print('❌ Error programando notificación: $e');
      // Como último recurso, intentar con modo inexacto
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTZDate,
          platformChannelSpecifics,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,  // 🆕 NUEVO: Incluir payload
        );
        print('🔄 Notificación reprogramada en modo inexacto');
      } catch (e2) {
        print('💥 Error crítico: $e2');
      }
    }
  }

  // Función para mostrar notificación inmediata (para debug)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,  // 🆕 NUEVO: Payload para navegación
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'event_channel',
        'Eventos',
        channelDescription: 'Notificaciones de eventos programados',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_notification',                              // Tu logo como icono pequeño
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_notification'), // Tu logo como icono grande
      );
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );
      
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,  // 🆕 NUEVO: Incluir payload
      );
      
      // 🆕 REGISTRAR EN CENTRO DE NOTIFICACIONES
      await _registerNotificationInCenter(title, body, payload);
      
      print('✅ Notificación inmediata enviada: $title');
    } catch (e) {
      print('❌ Error enviando notificación inmediata: $e');
    }
  }

  // Función para verificar notificaciones pendientes (debug)
  Future<void> checkPendingNotifications() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('Notificaciones pendientes: ${pendingNotificationRequests.length}');
    for (final request in pendingNotificationRequests) {
      print('ID: ${request.id}, Título: ${request.title}, Cuerpo: ${request.body}');
    }
  }

  // Función para verificar permisos de alarmas exactas
  Future<void> checkExactAlarmPermissions() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final bool? canScheduleExactAlarms = await androidImplementation.canScheduleExactNotifications();
      print('¿Puede programar alarmas exactas?: $canScheduleExactAlarms');
      
      final bool? areNotificationsEnabled = await androidImplementation.areNotificationsEnabled();
      print('¿Notificaciones habilitadas?: $areNotificationsEnabled');
    }
  }

  // Función de prueba avanzada del canal de notificaciones
  Future<void> testNotificationChannel() async {
    await showImmediateNotification(
      id: 9999,
      title: '🧪 PRUEBA AVANZADA',
      body: '¡Si ves esta notificación, el sistema funciona perfectamente!\n\nCanal: event_channel\nImportancia: MAX\nPrioridad: HIGH',
    );
  }

  // Función agresiva para forzar notificaciones
  Future<void> scheduleAggressiveNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,  // 🆕 NUEVO: Payload para navegación
  }) async {
    // Crear notificación con configuración muy agresiva
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'event_channel',
      'Eventos',
      channelDescription: 'Notificaciones de eventos programados',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      enableVibration: true,
      ongoing: true, // Persistente
      autoCancel: false, // No se cancela automáticamente
      showWhen: true,
      when: scheduledDate.millisecondsSinceEpoch,
      fullScreenIntent: true, // Pantalla completa si es posible
      category: AndroidNotificationCategory.alarm, // Categoría de alarma
      icon: '@mipmap/ic_notification',                              // Tu logo como icono pequeño
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_notification'), // Tu logo como icono grande
    );
    
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    
    final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    // Intentar schedule exacto
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,  // 🆕 NUEVO: Incluir payload
    );
    
    print('🚨 Notificación SÚPER AGRESIVA programada para: $scheduledTZDate');
  }

  // Limpiar notificaciones pendientes
  Future<void> cleanOldNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print('🧹 Todas las notificaciones pendientes han sido limpiadas');
  }

  // Workaround: mostrar notificación inmediata como último recurso
  Future<void> forceNotificationWorkaround({
    required String title,
    required String body,
    String? payload,  // 🆕 NUEVO: Payload para navegación
  }) async {
    await showImmediateNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      payload: payload,  // 🆕 NUEVO: Pasar payload
    );
    print('⚡ Notificación inmediata como workaround enviada');
  }

  /// 🆕 MÉTODO PARA REGISTRAR NOTIFICACIONES EN EL CENTRO
  Future<void> _registerNotificationInCenter(String title, String body, String? payload) async {
    try {
      // Determinar el tipo de notificación basado en el título, contenido y payload
      NotificationType type = _determineNotificationType(title, body, payload);
      
      await NotificationCenterService.instance.addNotification(
        title: title,
        body: body,
        type: type,
        payload: payload,
      );
    } catch (e) {
      print('❌ Error registrando notificación en centro: $e');
    }
  }

  /// Determinar el tipo de notificación basado en el contenido
  NotificationType _determineNotificationType(String title, String body, String? payload) {
    final titleLower = title.toLowerCase();
    final bodyLower = body.toLowerCase();
    
    // Análisis del payload si existe (PRIORIDAD MÁXIMA)
    String? payloadAction;
    if (payload != null && payload.isNotEmpty) {
      try {
        final payloadMap = jsonDecode(payload);
        payloadAction = payloadMap['action']?.toString().toLowerCase();
      } catch (e) {
        // Si el payload no es JSON válido, lo ignoramos
      }
    }
    
    // Prioridad 1: Analizar el payload primero
    if (payloadAction != null) {
      if (payloadAction.contains('challenge') || payloadAction.contains('confirm')) {
        return NotificationType.challenge;
      }
      if (payloadAction.contains('event')) {
        return NotificationType.event;
      }
      if (payloadAction.contains('achievement')) {
        return NotificationType.achievement;
      }
      if (payloadAction.contains('reminder')) {
        return NotificationType.reminder;
      }
    }
    
    // Patrones para identificar tipos de notificación
    // ORDEN IMPORTANTE: Los más específicos primero
    
    // 2. RETOS/CHALLENGES (prioridad ALTA - incluye confirmaciones y recordatorios)
    // ⚠️ IMPORTANTE: Evaluar tanto título como cuerpo para detectar notificaciones de retos
    if (titleLower.contains('reto') || titleLower.contains('challenge') ||
        titleLower.contains('racha') || titleLower.contains('streak') ||
        bodyLower.contains('confirmar') || bodyLower.contains('confirm') ||
        bodyLower.contains('reto') || bodyLower.contains('challenge') ||
        titleLower.contains('🔥') || titleLower.contains('💪') ||
        titleLower.contains('🛡️') || titleLower.contains('💔') ||
        // ✨ NUEVO: Detectar notificaciones de ventana de confirmación aunque tengan ⏰
        (bodyLower.contains('confirmar') && (bodyLower.contains('23:59') || bodyLower.contains('minutos'))) ||
        (titleLower.contains('últimos') && bodyLower.contains('confirmar'))) {
      return NotificationType.challenge;
    }
    
    // 3. LOGROS/ACHIEVEMENTS
    if (titleLower.contains('logro') || titleLower.contains('achievement') || 
        titleLower.contains('🎉') || titleLower.contains('🏆')) {
      return NotificationType.achievement;
    }
    
    // 3. EVENTOS (solo para eventos específicos, no para recordatorios de retos)
    if (titleLower.contains('evento') || titleLower.contains('event') ||
        (titleLower.contains('📅') && !bodyLower.contains('reto') && !bodyLower.contains('confirmar'))) {
      return NotificationType.event;
    }
    
    // 4. MOTIVACIÓN
    if (titleLower.contains('motivación') || titleLower.contains('motivation') ||
        bodyLower.contains('sigue') || bodyLower.contains('ánimo') ||
        titleLower.contains('💭') || titleLower.contains('🌟')) {
      return NotificationType.motivation;
    }
    
    // 5. PLANIFICACIÓN/PERSONALIZACIÓN
    if (titleLower.contains('planificación') || titleLower.contains('estilo') ||
        titleLower.contains('personalización') || titleLower.contains('🎨')) {
      return NotificationType.planning;
    }
    
    // 6. SISTEMA
    if (titleLower.contains('sistema') || titleLower.contains('system') ||
        titleLower.contains('configuración') || titleLower.contains('⚙️')) {
      return NotificationType.system;
    }
    
    // 7. RECORDATORIOS GENERALES (solo si NO son de retos - evaluación más estricta)
    if ((titleLower.contains('recordatorio') || titleLower.contains('reminder') ||
         titleLower.contains('⏰') || titleLower.contains('🔔')) &&
        !bodyLower.contains('reto') && !bodyLower.contains('confirmar') && 
        !bodyLower.contains('challenge') && !titleLower.contains('últimos')) {
      return NotificationType.reminder;
    }
    
    return NotificationType.general;
  }
}
