import 'package:flutter/foundation.dart';
import 'preparation_task.dart';
import 'database_helper.dart';
import 'planning_style_service.dart';

class PreparationService extends ChangeNotifier {
  static final PreparationService _instance = PreparationService._internal();
  static PreparationService get instance => _instance;
  PreparationService._internal();

  /// Templates de preparativos automáticos por categoría
  static final Map<String, List<Map<String, dynamic>>> _preparationTemplates = {
    
    // 🎂 CUMPLEAÑOS
    'birthday': [
      {'title': 'Planear celebración', 'description': 'Decidir dónde y cómo celebrar el cumpleaños', 'days': 30},
      {'title': 'Lista de invitados', 'description': 'Hacer lista de personas a invitar', 'days': 21},
      {'title': 'Enviar invitaciones', 'description': 'Mandar invitaciones a los invitados', 'days': 14},
      {'title': 'Reservar lugar/restaurante', 'description': 'Confirmar ubicación de la celebración', 'days': 10},
      {'title': 'Comprar decoraciones', 'description': 'Conseguir decoraciones temáticas', 'days': 7},
      {'title': 'Encargar pastel', 'description': 'Ordenar pastel personalizado', 'days': 5},
      {'title': 'Comprar regalo', 'description': 'Elegir y comprar el regalo perfecto', 'days': 3},
      {'title': 'Preparar outfit', 'description': 'Decidir qué ponerse para la ocasión', 'days': 1},
    ],

    // 💍 BODA
    'wedding': [
      {'title': 'Confirmar asistencia', 'description': 'Responder RSVP a los novios', 'days': 45},
      {'title': 'Planear alojamiento', 'description': 'Reservar hotel si es fuera de la ciudad', 'days': 30},
      {'title': 'Comprar regalo', 'description': 'Elegir regalo de la lista de bodas', 'days': 21},
      {'title': 'Buscar outfit formal', 'description': 'Comprar ropa apropiada para boda', 'days': 14},
      {'title': 'Confirmar transporte', 'description': 'Organizar cómo llegar al venue', 'days': 7},
      {'title': 'Preparar detalles', 'description': 'Zapatos, accesorios, maquillaje', 'days': 3},
      {'title': 'Revisar protocolo', 'description': 'Confirmar horarios y ceremonias', 'days': 1},
    ],

    // ✈️ VACACIONES  
    'vacation': [
      {'title': 'Investigar destino', 'description': 'Buscar lugares, actividades y clima', 'days': 60},
      {'title': 'Definir presupuesto', 'description': 'Calcular gastos totales del viaje', 'days': 45},
      {'title': 'Reservar vuelos', 'description': 'Comprar boletos de avión', 'days': 30},
      {'title': 'Reservar alojamiento', 'description': 'Confirmar hotel o Airbnb', 'days': 21},
      {'title': 'Documentos de viaje', 'description': 'Verificar pasaporte, visa, seguros', 'days': 14},
      {'title': 'Planear itinerario', 'description': 'Organizar actividades día a día', 'days': 10},
      {'title': 'Comprar esenciales', 'description': 'Protector solar, adaptadores, etc.', 'days': 7},
      {'title': 'Hacer maleta', 'description': 'Empacar ropa según el clima', 'days': 3},
      {'title': 'Check-in y documentos', 'description': 'Imprimir boletos y confirmaciones', 'days': 1},
    ],

    // 📚 EXAMEN
    'exam': [
      {'title': 'Obtener temario completo', 'description': 'Conseguir todo el material de estudio', 'days': 30},
      {'title': 'Crear plan de estudio', 'description': 'Organizar cronograma de repaso', 'days': 21},
      {'title': 'Estudiar teoría', 'description': 'Repasar conceptos fundamentales', 'days': 14},
      {'title': 'Resolver ejercicios', 'description': 'Practicar con problemas tipo', 'days': 10},
      {'title': 'Hacer simulacros', 'description': 'Exámenes de práctica completos', 'days': 7},
      {'title': 'Repaso final intensivo', 'description': 'Revisar puntos clave', 'days': 3},
      {'title': 'Preparar materiales', 'description': 'Lápices, calculadora, identificación', 'days': 1},
      {'title': 'Descansar bien', 'description': 'Dormir temprano la noche anterior', 'days': 0},
    ],

    // 🎒 VIAJE
    'trip': [
      {'title': 'Investigar destino', 'description': 'Conocer lugares de interés', 'days': 45},
      {'title': 'Reservar transporte', 'description': 'Vuelos, trenes, o renta de auto', 'days': 30},
      {'title': 'Reservar alojamiento', 'description': 'Hotel, hostal, o Airbnb', 'days': 21},
      {'title': 'Verificar documentos', 'description': 'Pasaporte, visa, permisos', 'days': 14},
      {'title': 'Seguro de viaje', 'description': 'Contratar cobertura médica', 'days': 10},
      {'title': 'Cambio de moneda', 'description': 'Obtener dinero local', 'days': 7},
      {'title': 'Descargar apps útiles', 'description': 'Mapas, traductor, transporte', 'days': 5},
      {'title': 'Empacar equipaje', 'description': 'Hacer maleta según duración', 'days': 2},
      {'title': 'Confirmaciones finales', 'description': 'Check-in y revisión de reservas', 'days': 1},
    ],

    // 🎓 GRADUACIÓN
    'graduation': [
      {'title': 'Confirmar ceremonia', 'description': 'Verificar fecha, hora y protocolo', 'days': 30},
      {'title': 'Invitar familiares', 'description': 'Avisar a familia y amigos', 'days': 21},
      {'title': 'Conseguir toga y birrete', 'description': 'Recoger o rentar vestimenta', 'days': 14},
      {'title': 'Planear celebración', 'description': 'Organizar fiesta o cena', 'days': 10},
      {'title': 'Comprar outfit elegante', 'description': 'Ropa formal para bajo la toga', 'days': 7},
      {'title': 'Preparar documentos', 'description': 'Identificación y papeles requeridos', 'days': 3},
      {'title': 'Confirmar asistentes', 'description': 'Número final de invitados', 'days': 1},
    ],

    // 🎵 CONCIERTO
    'concert': [
      {'title': 'Verificar boletos', 'description': 'Confirmar que tienes los tickets', 'days': 7},
      {'title': 'Planear outfit', 'description': 'Ropa cómoda y del estilo musical', 'days': 5},
      {'title': 'Revisar ubicación', 'description': 'Cómo llegar al venue', 'days': 3},
      {'title': 'Organizar transporte', 'description': 'Planear ida y regreso', 'days': 2},
      {'title': 'Preparar para el día', 'description': 'Cargar teléfono, llevar agua', 'days': 0},
    ],

    // 🏢 REUNIÓN
    'meeting': [
      {'title': 'Revisar agenda', 'description': 'Confirmar temas a discutir', 'days': 5},
      {'title': 'Preparar presentación', 'description': 'Crear slides o documentos', 'days': 3},
      {'title': 'Imprimir materiales', 'description': 'Documentos físicos necesarios', 'days': 2},
      {'title': 'Confirmar asistencia', 'description': 'Avisar que estarás presente', 'days': 1},
      {'title': 'Verificar ubicación', 'description': 'Lugar exacto y hora', 'days': 0},
    ],

    // 📑 ENTREGA DE PROYECTO
    'projectDelivery': [
      {'title': 'Revisar requerimientos', 'description': 'Verificar todas las especificaciones', 'days': 21},
      {'title': 'Crear cronograma', 'description': 'Dividir proyecto en tareas', 'days': 14},
      {'title': 'Desarrollo principal', 'description': 'Trabajar en el core del proyecto', 'days': 10},
      {'title': 'Primera revisión', 'description': 'Verificar progreso y calidad', 'days': 7},
      {'title': 'Correcciones y ajustes', 'description': 'Pulir detalles y errores', 'days': 3},
      {'title': 'Revisión final', 'description': 'Último check antes de entregar', 'days': 1},
      {'title': 'Preparar entrega', 'description': 'Formato final y presentación', 'days': 0},
    ],

    // 📦 MUDANZA
    'moving': [
      {'title': 'Buscar empresa de mudanza', 'description': 'Cotizar y contratar servicio', 'days': 30},
      {'title': 'Organizar documentos', 'description': 'Cambio de domicilio oficial', 'days': 21},
      {'title': 'Servicios públicos', 'description': 'Transferir luz, agua, internet', 'days': 14},
      {'title': 'Empacar objetos delicados', 'description': 'Proteger artículos frágiles', 'days': 10},
      {'title': 'Depurar pertenencias', 'description': 'Donar o vender lo innecesario', 'days': 7},
      {'title': 'Empacar todo', 'description': 'Cajas etiquetadas por habitación', 'days': 3},
      {'title': 'Limpieza profunda', 'description': 'Preparar lugar anterior', 'days': 1},
    ],

    // 💼 ENTREVISTA
    'interview': [
      {'title': 'Investigar la empresa', 'description': 'Conocer historia, valores, productos', 'days': 7},
      {'title': 'Preparar respuestas', 'description': 'Practicar preguntas típicas', 'days': 5},
      {'title': 'Actualizar CV', 'description': 'Imprimir copias actualizadas', 'days': 3},
      {'title': 'Elegir outfit profesional', 'description': 'Ropa formal apropiada', 'days': 2},
      {'title': 'Preparar preguntas', 'description': 'Qué preguntar al entrevistador', 'days': 1},
      {'title': 'Llegar temprano', 'description': 'Planear ruta y tiempo extra', 'days': 0},
    ],

    // 🎄 NAVIDAD
    'christmas': [
      {'title': 'Lista de regalos', 'description': 'Decidir qué regalar a cada persona', 'days': 45},
      {'title': 'Comprar regalos', 'description': 'Ir de shopping navideño', 'days': 30},
      {'title': 'Planear cena navideña', 'description': 'Menú y lista de compras', 'days': 21},
      {'title': 'Decorar la casa', 'description': 'Árbol, luces, adornos navideños', 'days': 14},
      {'title': 'Envolver regalos', 'description': 'Papel regalo y moños', 'days': 7},
      {'title': 'Comprar ingredientes', 'description': 'Todo para la cena especial', 'days': 3},
      {'title': 'Preparar comida', 'description': 'Cocinar platos navideños', 'days': 1},
    ],

    // 🎊 AÑO NUEVO
    'newYear': [
      {'title': 'Decidir celebración', 'description': 'Casa, fiesta, o evento especial', 'days': 21},
      {'title': 'Conseguir outfit festivo', 'description': 'Ropa especial para la ocasión', 'days': 14},
      {'title': 'Planear menú', 'description': 'Comida y bebidas para la noche', 'days': 10},
      {'title': 'Invitar amigos', 'description': 'Confirmar quién viene', 'days': 7},
      {'title': 'Comprar suministros', 'description': 'Bebidas, snacks, decoración', 'days': 3},
      {'title': 'Preparar resoluciones', 'description': 'Metas para el nuevo año', 'days': 1},
    ],

    // 💐 DÍA DE LA MADRE
    'mothersDay': [
      {'title': 'Elegir regalo especial', 'description': 'Algo significativo para mamá', 'days': 21},
      {'title': 'Planear celebración', 'description': 'Desayuno, almuerzo, o cena', 'days': 14},
      {'title': 'Hacer reservación', 'description': 'Restaurante o lugar especial', 'days': 10},
      {'title': 'Comprar flores', 'description': 'Bouquet de sus flores favoritas', 'days': 3},
      {'title': 'Preparar sorpresas', 'description': 'Detalles especiales del día', 'days': 1},
    ],

    // 👔 DÍA DEL PADRE
    'fathersDay': [
      {'title': 'Buscar regalo único', 'description': 'Algo que realmente le guste a papá', 'days': 21},
      {'title': 'Planear actividad', 'description': 'Deporte, hobby, o comida especial', 'days': 14},
      {'title': 'Organizar reunión familiar', 'description': 'Juntar a hermanos/familia', 'days': 10},
      {'title': 'Preparar mensaje', 'description': 'Carta o palabras especiales', 'days': 3},
      {'title': 'Organizar sorpresa', 'description': 'Detalles finales del día', 'days': 1},
    ],

    // 💕 SAN VALENTÍN
    'valentine': [
      {'title': 'Planear cita romántica', 'description': 'Decidir actividad especial', 'days': 14},
      {'title': 'Hacer reservación', 'description': 'Restaurante o lugar romántico', 'days': 10},
      {'title': 'Comprar regalo', 'description': 'Algo significativo para la pareja', 'days': 7},
      {'title': 'Elegir outfit especial', 'description': 'Ropa bonita para la cita', 'days': 3},
      {'title': 'Preparar sorpresas', 'description': 'Detalles románticos finales', 'days': 1},
    ],

    // 🛍️ BLACK FRIDAY
    'blackFriday': [
      {'title': 'Hacer lista de deseos', 'description': 'Productos que quieres comprar', 'days': 21},
      {'title': 'Investigar precios', 'description': 'Comparar precios normales', 'days': 14},
      {'title': 'Definir presupuesto', 'description': 'Cuánto dinero gastar', 'days': 10},
      {'title': 'Seguir ofertas', 'description': 'Monitorear descuentos tempranos', 'days': 7},
      {'title': 'Preparar estrategia', 'description': 'Plan de compras y horarios', 'days': 3},
      {'title': 'Estar listo para comprar', 'description': 'Tarjetas, apps, y lista final', 'days': 0},
    ],

    // 💉 VACUNA
    'vaccine': [
      {'title': 'Verificar requisitos', 'description': 'Qué vacuna necesitas exactamente', 'days': 14},
      {'title': 'Conseguir cita médica', 'description': 'Agendar con doctor o clínica', 'days': 10},
      {'title': 'Preparar documentos', 'description': 'Identificación y cartilla', 'days': 7},
      {'title': 'Revisar efectos secundarios', 'description': 'Qué esperar después', 'days': 3},
      {'title': 'Planear día de descanso', 'description': 'Tiempo libre post-vacuna', 'days': 1},
    ],

    // 🔧 OTROS (Template genérico)
    'other': [
      {'title': 'Planear preparativos', 'description': 'Decidir qué necesitas hacer', 'days': 21},
      {'title': 'Investigar requerimientos', 'description': 'Qué se necesita específicamente', 'days': 14},
      {'title': 'Obtener recursos', 'description': 'Conseguir lo que necesitas', 'days': 10},
      {'title': 'Preparación intermedia', 'description': 'Avanzar en los preparativos', 'days': 7},
      {'title': 'Revisión de progreso', 'description': 'Verificar que todo va bien', 'days': 3},
      {'title': 'Preparación final', 'description': 'Últimos detalles y confirmaciones', 'days': 1},
    ],
  };

  /// Crea preparativos automáticos para un evento basado en su categoría
  Future<void> createAutomaticPreparations(int eventId, String category) async {
    try {
      // Obtener template de la categoría (o usar 'other' como fallback)
      final template = _preparationTemplates[category] ?? _preparationTemplates['other']!;
      
      // Obtener el estilo de planificación del usuario
      final planningStyle = PlanningStyleService.instance;
      
      // 🆕 NUEVO: Adaptación dinámica por proximidad del evento
      final db = await DatabaseHelper.instance.database;
      
      // Obtener fecha del evento para calcular días disponibles
      final eventResult = await db.query(
        'events',
        columns: ['targetDate'],
        where: 'id = ?',
        whereArgs: [eventId],
      );
      
      if (eventResult.isEmpty) {
        print('❌ No se encontró el evento $eventId');
        return;
      }
      
      final eventDate = DateTime.parse(eventResult.first['targetDate'] as String);
      final now = DateTime.now();
      final totalDaysAvailable = eventDate.difference(now).inDays;
      
      print('📅 Evento en $totalDaysAvailable días - Adaptando preparativos...');
      
      // Filtrar y adaptar preparativos según días disponibles
      final adaptedTasks = _adaptTasksForTimeframe(template, totalDaysAvailable, planningStyle);
      
      for (final taskData in adaptedTasks) {
        final task = PreparationTask(
          eventId: eventId,
          title: taskData['title'],
          description: taskData['description'],
          daysBeforeEvent: taskData['adaptedDays'], // Usar días adaptados
        );
        
        await db.insert('preparation_tasks', task.toMap());
      }
      
      // Log con información del estilo aplicado
      final styleName = planningStyle.getStyleName(planningStyle.currentStyle);
      final multiplier = planningStyle.getMultiplier(planningStyle.currentStyle);
      
      print('✅ Creados ${adaptedTasks.length} preparativos adaptativos para evento $eventId (categoría: $category)');
      print('🎨 Estilo aplicado: $styleName (${multiplier}x)');
      print('⏰ Adaptación temporal: ${totalDaysAvailable} días disponibles');
      notifyListeners();
    } catch (e) {
      print('❌ Error creando preparativos automáticos: $e');
    }
  }

  /// 🆕 NUEVO: Sistema adaptativo inteligente para ajustar preparativos
  List<Map<String, dynamic>> _adaptTasksForTimeframe(
    List<Map<String, dynamic>> originalTasks, 
    int daysAvailable, 
    PlanningStyleService planningStyle
  ) {
    // Si tenemos menos de 3 días, crear preparativos de emergencia
    if (daysAvailable <= 3) {
      return _createEmergencyTasks(originalTasks, daysAvailable);
    }
    
    // Si tenemos menos de 7 días, comprimir preparativos
    if (daysAvailable <= 7) {
      return _createCompressedTasks(originalTasks, daysAvailable);
    }
    
    // Si tenemos menos de 21 días, usar preparativos optimizados
    if (daysAvailable <= 21) {
      return _createOptimizedTasks(originalTasks, daysAvailable, planningStyle);
    }
    
    // Para más de 21 días, usar sistema normal con estilo
    return _createStandardTasks(originalTasks, planningStyle);
  }

  /// Preparativos de emergencia para eventos muy próximos (1-3 días)
  List<Map<String, dynamic>> _createEmergencyTasks(List<Map<String, dynamic>> originalTasks, int daysAvailable) {
    final emergencyTasks = <Map<String, dynamic>>[];
    
    // Seleccionar solo las tareas más críticas y adaptarlas
    final criticalTasks = originalTasks.where((task) => task['days'] <= 7).toList();
    
    for (int i = 0; i < criticalTasks.length && i < daysAvailable + 2; i++) {
      final task = criticalTasks[i];
      final adaptedDay = (daysAvailable - i).clamp(0, daysAvailable);
      
      emergencyTasks.add({
        'title': '🚨 ${task['title']}',
        'description': '${task['description']} (modo urgente)',
        'adaptedDays': adaptedDay,
      });
    }
    
    print('🚨 Modo emergencia: ${emergencyTasks.length} preparativos críticos');
    return emergencyTasks;
  }

  /// Preparativos comprimidos para eventos próximos (4-7 días)
  List<Map<String, dynamic>> _createCompressedTasks(List<Map<String, dynamic>> originalTasks, int daysAvailable) {
    final compressedTasks = <Map<String, dynamic>>[];
    
    // Seleccionar tareas importantes y distribuirlas en los días disponibles
    final importantTasks = originalTasks.where((task) => task['days'] <= 14).toList();
    
    for (int i = 0; i < importantTasks.length && i < daysAvailable + 1; i++) {
      final task = importantTasks[i];
      final adaptedDay = ((daysAvailable - 1) * (i / (importantTasks.length - 1).clamp(1, double.infinity))).round().clamp(0, daysAvailable - 1);
      
      compressedTasks.add({
        'title': '⚡ ${task['title']}',
        'description': '${task['description']} (tiempo limitado)',
        'adaptedDays': adaptedDay,
      });
    }
    
    print('⚡ Modo comprimido: ${compressedTasks.length} preparativos acelerados');
    return compressedTasks;
  }

  /// Preparativos optimizados para eventos medianos (8-21 días)
  List<Map<String, dynamic>> _createOptimizedTasks(List<Map<String, dynamic>> originalTasks, int daysAvailable, PlanningStyleService planningStyle) {
    final optimizedTasks = <Map<String, dynamic>>[];
    final multiplier = planningStyle.getMultiplier(planningStyle.currentStyle);
    
    for (final task in originalTasks) {
      final originalDays = task['days'] as int;
      var adjustedDays = (originalDays * multiplier).round();
      
      // Adaptar dinámicamente al tiempo disponible
      if (adjustedDays >= daysAvailable) {
        adjustedDays = (daysAvailable * 0.8).round().clamp(0, daysAvailable - 1);
      }
      
      // Solo incluir si queda tiempo suficiente
      if (adjustedDays >= 0) {
        optimizedTasks.add({
          'title': task['title'],
          'description': '${task['description']} (optimizado)',
          'adaptedDays': adjustedDays,
        });
      }
    }
    
    print('🎯 Modo optimizado: ${optimizedTasks.length} preparativos ajustados');
    return optimizedTasks;
  }

  /// Preparativos estándar con estilo de planificación normal
  List<Map<String, dynamic>> _createStandardTasks(List<Map<String, dynamic>> originalTasks, PlanningStyleService planningStyle) {
    final standardTasks = <Map<String, dynamic>>[];
    
    for (final task in originalTasks) {
      final originalDays = task['days'] as int;
      final adjustedDays = planningStyle.getAdjustedDays(originalDays);
      
      standardTasks.add({
        'title': task['title'],
        'description': task['description'],
        'adaptedDays': adjustedDays,
      });
    }
    
    print('📋 Modo estándar: ${standardTasks.length} preparativos normales');
    return standardTasks;
  }

  /// 🆕 NUEVO: Re-calibrar preparativos existentes para adaptarse a tiempo limitado
  Future<void> recalibrateEventPreparations(int eventId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      
      // Obtener información del evento
      final eventResult = await db.query(
        'events',
        columns: ['targetDate', 'category'],
        where: 'id = ?',
        whereArgs: [eventId],
      );
      
      if (eventResult.isEmpty) {
        print('❌ No se encontró el evento $eventId para re-calibrar');
        return;
      }
      
      final eventData = eventResult.first;
      final eventDate = DateTime.parse(eventData['targetDate'] as String);
      final category = eventData['category'] as String;
      final now = DateTime.now();
      final daysAvailable = eventDate.difference(now).inDays;
      
      // Obtener preparativos existentes no completados
      final existingTasks = await db.query(
        'preparation_tasks',
        where: 'eventId = ? AND isCompleted = 0',
        whereArgs: [eventId],
      );
      
      if (existingTasks.isEmpty) {
        print('✅ No hay preparativos pendientes para re-calibrar');
        return;
      }
      
      print('🔄 Re-calibrando ${existingTasks.length} preparativos para $daysAvailable días disponibles...');
      
      // Eliminar preparativos existentes no completados
      await db.delete(
        'preparation_tasks',
        where: 'eventId = ? AND isCompleted = 0',
        whereArgs: [eventId],
      );
      
      // Crear nuevos preparativos adaptados
      await createAutomaticPreparations(eventId, category);
      
      print('✅ Preparativos re-calibrados exitosamente para evento $eventId');
      notifyListeners();
    } catch (e) {
      print('❌ Error re-calibrando preparativos: $e');
    }
  }

  /// Obtiene todos los preparativos de un evento
  Future<List<PreparationTask>> getEventPreparations(int eventId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'preparation_tasks',
        where: 'eventId = ?',
        whereArgs: [eventId],
        orderBy: 'daysBeforeEvent DESC, isCompleted ASC',
      );
      
      return List.generate(maps.length, (i) {
        return PreparationTask.fromMap(maps[i]);
      });
    } catch (e) {
      print('❌ Error obteniendo preparativos del evento $eventId: $e');
      return [];
    }
  }

  /// Marca una tarea como completada
  Future<void> completeTask(int taskId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'preparation_tasks',
        {
          'isCompleted': 1,
          'completedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [taskId],
      );
      
      print('✅ Tarea $taskId marcada como completada');
      notifyListeners();
    } catch (e) {
      print('❌ Error completando tarea $taskId: $e');
    }
  }

  /// Desmarca una tarea como no completada
  Future<void> uncompleteTask(int taskId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'preparation_tasks',
        {
          'isCompleted': 0,
          'completedAt': null,
        },
        where: 'id = ?',
        whereArgs: [taskId],
      );
      
      print('↩️ Tarea $taskId desmarcada como no completada');
      notifyListeners();
    } catch (e) {
      print('❌ Error desmarcando tarea $taskId: $e');
    }
  }

  /// Agrega una tarea personalizada a un evento
  Future<void> addCustomTask(int eventId, String title, String description, int daysBeforeEvent) async {
    try {
      final task = PreparationTask(
        eventId: eventId,
        title: title,
        description: description,
        daysBeforeEvent: daysBeforeEvent,
      );
      
      final db = await DatabaseHelper.instance.database;
      await db.insert('preparation_tasks', task.toMap());
      
      print('✅ Tarea personalizada agregada al evento $eventId');
      notifyListeners();
    } catch (e) {
      print('❌ Error agregando tarea personalizada: $e');
    }
  }

  /// Elimina una tarea de preparativo
  Future<void> deleteTask(int taskId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'preparation_tasks',
        where: 'id = ?',
        whereArgs: [taskId],
      );
      
      print('🗑️ Tarea $taskId eliminada');
      notifyListeners();
    } catch (e) {
      print('❌ Error eliminando tarea $taskId: $e');
    }
  }

  /// Elimina todos los preparativos de un evento (cuando se borra el evento)
  Future<void> deleteEventPreparations(int eventId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'preparation_tasks',
        where: 'eventId = ?',
        whereArgs: [eventId],
      );
      
      print('🗑️ Todos los preparativos del evento $eventId eliminados');
      notifyListeners();
    } catch (e) {
      print('❌ Error eliminando preparativos del evento $eventId: $e');
    }
  }

  /// Obtiene estadísticas de preparativos para un evento
  Future<Map<String, int>> getEventPreparationStats(int eventId) async {
    try {
      final preparations = await getEventPreparations(eventId);
      final total = preparations.length;
      final completed = preparations.where((p) => p.isCompleted).length;
      final pending = total - completed;
      
      return {
        'total': total,
        'completed': completed,
        'pending': pending,
      };
    } catch (e) {
      print('❌ Error obteniendo estadísticas de preparativos: $e');
      return {'total': 0, 'completed': 0, 'pending': 0};
    }
  }
}
