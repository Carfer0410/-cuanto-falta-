import 'package:flutter/foundation.dart';
import 'challenge_strategy.dart';
import 'database_helper.dart';
import 'planning_style_service.dart';

class ChallengeStrategyService extends ChangeNotifier {
  static final ChallengeStrategyService _instance = ChallengeStrategyService._internal();
  static ChallengeStrategyService get instance => _instance;
  ChallengeStrategyService._internal();

  /// Templates de estrategias por tipo de reto y estilo de personalidad
  static final Map<String, Map<PlanningStyle, List<Map<String, dynamic>>>> _strategyTemplates = {
    
    // 💧 BEBER AGUA
    'water': {
      PlanningStyle.relaxed: [
        {'title': 'Botella siempre visible', 'description': 'Deja una botella de agua donde siempre la veas', 'category': 'preparation', 'priority': 2},
        {'title': 'Aplicación simple', 'description': 'Usa una app básica de recordatorio de agua', 'category': 'tracking', 'priority': 3},
        {'title': 'Sabor natural', 'description': 'Agrega limón o menta para hacer el agua más atractiva', 'category': 'daily', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Horarios estratégicos', 'description': 'Bebe agua al despertar, antes de comidas y al dormir', 'category': 'daily', 'priority': 2},
        {'title': 'Medición diaria', 'description': 'Usa una botella marcada para medir tu consumo', 'category': 'tracking', 'priority': 2},
        {'title': 'Recordatorios cada 2 horas', 'description': 'Programa alarmas suaves cada 2 horas', 'category': 'tracking', 'priority': 3},
        {'title': 'Meta semanal', 'description': 'Apunta a 7 días consecutivos cumpliendo la meta', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Plan hora por hora', 'description': 'Programa exactamente cuándo beber cada vaso de agua', 'category': 'daily', 'priority': 1},
        {'title': 'Registro detallado', 'description': 'Anota cantidad, hora y sensación en un diario', 'category': 'tracking', 'priority': 1},
        {'title': 'Análisis semanal', 'description': 'Revisa patrones y ajusta estrategia cada domingo', 'category': 'weekly', 'priority': 2},
        {'title': 'Preparación nocturna', 'description': 'Llena botellas la noche anterior con medidas exactas', 'category': 'preparation', 'priority': 2},
        {'title': 'Metas incrementales', 'description': 'Aumenta 200ml cada semana hasta llegar al objetivo', 'category': 'milestone', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Sistema de hidratación completo', 'description': 'Calcula necesidades exactas según peso, ejercicio y clima', 'category': 'preparation', 'priority': 1},
        {'title': 'Múltiples recordatorios', 'description': 'App, alarmas, notas pegadas y recordatorios visuales', 'category': 'tracking', 'priority': 1},
        {'title': 'Calidad del agua optimizada', 'description': 'Filtra el agua y agrega electrolitos según necesidad', 'category': 'daily', 'priority': 1},
        {'title': 'Análisis de patrones avanzado', 'description': 'Correlaciona hidratación con energía, sueño y productividad', 'category': 'weekly', 'priority': 1},
        {'title': 'Backup plan completo', 'description': 'Estrategias alternativas para días ocupados o viajes', 'category': 'preparation', 'priority': 2},
        {'title': 'Sistema de recompensas', 'description': 'Prémiate por cada milestone y semana perfecta', 'category': 'reward', 'priority': 3},
      ],
    },

    // 🏃‍♂️ EJERCICIO
    'exercise': {
      PlanningStyle.relaxed: [
        {'title': 'Movimiento diario simple', 'description': 'Camina 10 minutos o haz estiramientos básicos', 'category': 'daily', 'priority': 2},
        {'title': 'Actividades que disfrutes', 'description': 'Elige ejercicios que realmente te gusten hacer', 'category': 'motivation', 'priority': 2},
        {'title': 'Sin presión', 'description': 'Si un día no puedes, simplemente continúa mañana', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Rutina 3 veces por semana', 'description': 'Programa ejercicio lunes, miércoles y viernes', 'category': 'weekly', 'priority': 2},
        {'title': 'Progresión gradual', 'description': 'Aumenta intensidad o duración cada 2 semanas', 'category': 'milestone', 'priority': 2},
        {'title': 'Preparación la noche anterior', 'description': 'Deja ropa deportiva lista y planifica el ejercicio', 'category': 'preparation', 'priority': 3},
        {'title': 'Registro de progreso', 'description': 'Anota tipo de ejercicio, duración y cómo te sentiste', 'category': 'tracking', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Plan de entrenamiento estructurado', 'description': 'Crea rutinas específicas para cada día de ejercicio', 'category': 'preparation', 'priority': 1},
        {'title': 'Horario fijo', 'description': 'Ejercítate siempre a la misma hora para crear hábito', 'category': 'daily', 'priority': 1},
        {'title': 'Seguimiento detallado', 'description': 'Registra repeticiones, peso, tiempo y frecuencia cardíaca', 'category': 'tracking', 'priority': 1},
        {'title': 'Evaluación semanal', 'description': 'Revisa progreso y ajusta plan cada domingo', 'category': 'weekly', 'priority': 2},
        {'title': 'Preparación completa', 'description': 'Ten plan A y B según tiempo disponible y energía', 'category': 'preparation', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Programa periodizado', 'description': 'Plan de 12 semanas con fases de volumen, intensidad y recuperación', 'category': 'preparation', 'priority': 1},
        {'title': 'Métricas avanzadas', 'description': 'Monitorea progreso con apps, pulsómetro y análisis biométrico', 'category': 'tracking', 'priority': 1},
        {'title': 'Optimización nutricional', 'description': 'Sincroniza ejercicio con plan nutricional y suplementación', 'category': 'daily', 'priority': 1},
        {'title': 'Análisis de rendimiento', 'description': 'Evalúa correlaciones entre sueño, nutrición y performance', 'category': 'weekly', 'priority': 1},
        {'title': 'Estrategias de recuperación', 'description': 'Incluye estiramientos, masajes y técnicas de recuperación activa', 'category': 'daily', 'priority': 2},
        {'title': 'Sistema de motivación completo', 'description': 'Metas a corto, medio y largo plazo con recompensas escalonadas', 'category': 'motivation', 'priority': 2},
      ],
    },

    // 📚 LEER
    'reading': {
      PlanningStyle.relaxed: [
        {'title': 'Lectura placentera', 'description': 'Lee solo cuando tengas ganas, sin presión de tiempo', 'category': 'motivation', 'priority': 3},
        {'title': 'Libros que te emocionen', 'description': 'Elige géneros y autores que realmente disfrutes', 'category': 'preparation', 'priority': 2},
        {'title': 'Momentos cómodos', 'description': 'Lee en tu lugar favorito con buena iluminación', 'category': 'daily', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': '20 minutos diarios', 'description': 'Dedica 20 minutos fijos cada día, preferiblemente antes de dormir', 'category': 'daily', 'priority': 2},
        {'title': 'Meta mensual', 'description': 'Proponte terminar 1-2 libros por mes según su extensión', 'category': 'monthly', 'priority': 2},
        {'title': 'Diversidad de géneros', 'description': 'Alterna entre ficción, no ficción y temas de interés personal', 'category': 'preparation', 'priority': 3},
        {'title': 'Seguimiento básico', 'description': 'Anota libros leídos y una breve opinión de cada uno', 'category': 'tracking', 'priority': 4},
      ],
      PlanningStyle.methodical: [
        {'title': 'Plan de lectura anual', 'description': 'Lista específica de 25-50 libros organizados por trimestre', 'category': 'preparation', 'priority': 1},
        {'title': 'Horario estructurado', 'description': 'Dedica bloques específicos: mañana, tarde y noche para diferentes tipos', 'category': 'daily', 'priority': 1},
        {'title': 'Sistema de notas', 'description': 'Toma apuntes, subraya y crea resúmenes de cada capítulo', 'category': 'tracking', 'priority': 1},
        {'title': 'Evaluación semanal', 'description': 'Revisa progreso y ajusta meta de páginas por día', 'category': 'weekly', 'priority': 2},
        {'title': 'Preparación optimizada', 'description': 'Ten varios libros listos y crea ambiente perfecto de lectura', 'category': 'preparation', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Biblioteca curada estratégicamente', 'description': 'Selecciona libros basado en objetivos de crecimiento personal y profesional', 'category': 'preparation', 'priority': 1},
        {'title': 'Sistema de lectura multi-modal', 'description': 'Combina lectura física, digital y audiolibros según contexto', 'category': 'daily', 'priority': 1},
        {'title': 'Análisis profundo', 'description': 'Crea mapas mentales, conecta ideas entre libros y aplica conceptos', 'category': 'tracking', 'priority': 1},
        {'title': 'Red de discusión', 'description': 'Únete a clubs de lectura y discute libros con otros lectores', 'category': 'weekly', 'priority': 2},
        {'title': 'Optimización de comprensión', 'description': 'Usa técnicas de lectura rápida y retención mejorada', 'category': 'daily', 'priority': 2},
        {'title': 'Biblioteca personal digital', 'description': 'Mantén base de datos con citas, lecciones y referencias cruzadas', 'category': 'tracking', 'priority': 2},
      ],
    },

    // 🧘‍♀️ MEDITAR
    'meditation': {
      PlanningStyle.relaxed: [
        {'title': 'Momentos de calma', 'description': 'Respira profundo 5 minutos cuando lo necesites', 'category': 'daily', 'priority': 3},
        {'title': 'Meditación guiada', 'description': 'Usa apps como Calm o Headspace con sesiones cortas', 'category': 'daily', 'priority': 2},
        {'title': 'Sin expectativas', 'description': 'No te presiones, cada momento de quietud cuenta', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': '10 minutos matutinos', 'description': 'Medita 10 minutos cada mañana antes de empezar el día', 'category': 'daily', 'priority': 2},
        {'title': 'Técnicas variadas', 'description': 'Alterna entre respiración, mindfulness y meditación guiada', 'category': 'weekly', 'priority': 3},
        {'title': 'Espacio dedicado', 'description': 'Crea un rincón tranquilo solo para meditar', 'category': 'preparation', 'priority': 3},
        {'title': 'Progreso gradual', 'description': 'Aumenta duración 2 minutos cada 2 semanas', 'category': 'milestone', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Programa de meditación estructurado', 'description': 'Plan de 8 semanas con técnicas específicas por semana', 'category': 'preparation', 'priority': 1},
        {'title': 'Horario fijo e inquebrantable', 'description': 'Misma hora todos los días, sin excepciones', 'category': 'daily', 'priority': 1},
        {'title': 'Registro detallado', 'description': 'Anota duración, técnica, sensaciones y nivel de concentración', 'category': 'tracking', 'priority': 1},
        {'title': 'Evaluación semanal', 'description': 'Analiza progreso y ajusta técnicas según resultados', 'category': 'weekly', 'priority': 2},
        {'title': 'Ambiente optimizado', 'description': 'Controla temperatura, iluminación, sonidos y aromas', 'category': 'preparation', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Currículo de meditación completo', 'description': 'Estudia filosofía, neurociencia y múltiples tradiciones meditativas', 'category': 'preparation', 'priority': 1},
        {'title': 'Múltiples sesiones diarias', 'description': 'Mañana (concentración), tarde (mindfulness), noche (relajación)', 'category': 'daily', 'priority': 1},
        {'title': 'Métricas de progreso avanzadas', 'description': 'Monitorea variabilidad cardíaca, ondas cerebrales y marcadores de estrés', 'category': 'tracking', 'priority': 1},
        {'title': 'Retiros y profundización', 'description': 'Participa en retiros mensuales y estudia con maestros experimentados', 'category': 'monthly', 'priority': 2},
        {'title': 'Integración en vida diaria', 'description': 'Aplica mindfulness en todas las actividades cotidianas', 'category': 'daily', 'priority': 2},
        {'title': 'Comunidad de práctica', 'description': 'Conecta con otros meditadores y mantén accountability mutuo', 'category': 'weekly', 'priority': 3},
      ],
    },

    // 🚭 DEJAR DE FUMAR
    'quit_smoking': {
      PlanningStyle.relaxed: [
        {'title': 'Reducción gradual', 'description': 'Disminuye 1-2 cigarrillos por semana sin prisa', 'category': 'weekly', 'priority': 2},
        {'title': 'Alternativas saludables', 'description': 'Ten chicles, zanahorias o algo para mantener las manos ocupadas', 'category': 'preparation', 'priority': 2},
        {'title': 'Apoyo emocional', 'description': 'Habla con amigos o familia cuando sientas ganas de fumar', 'category': 'motivation', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Plan de 6 semanas', 'description': 'Semanas 1-2: reducir 50%, 3-4: reducir 75%, 5-6: dejar completamente', 'category': 'preparation', 'priority': 1},
        {'title': 'Reemplazos de rutina', 'description': 'Cambia hábitos asociados: café por té, pausas por caminatas', 'category': 'daily', 'priority': 2},
        {'title': 'Sistema de recompensas', 'description': 'Prémiate cada semana que cumplas el objetivo de reducción', 'category': 'weekly', 'priority': 2},
        {'title': 'Red de apoyo', 'description': 'Informa a familiares y amigos sobre tu plan para accountability', 'category': 'motivation', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Análisis de patrones', 'description': 'Registra cuándo, dónde y por qué fumas durante 2 semanas', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan detallado por fases', 'description': 'Estrategia específica para cada trigger y situación identificada', 'category': 'preparation', 'priority': 1},
        {'title': 'Seguimiento diario', 'description': 'Anota cada cigarrillo, situación, estado emocional y alternativa usada', 'category': 'daily', 'priority': 1},
        {'title': 'Evaluación semanal', 'description': 'Analiza progreso, identifica desafíos y ajusta estrategias', 'category': 'weekly', 'priority': 2},
        {'title': 'Kit de emergencia', 'description': 'Ten lista estrategias específicas para momentos de mayor antojo', 'category': 'preparation', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Investigación científica completa', 'description': 'Estudia neurociencia de adicción y métodos más efectivos', 'category': 'preparation', 'priority': 1},
        {'title': 'Plan multidisciplinario', 'description': 'Combina medicina, psicología, nutrición y ejercicio', 'category': 'preparation', 'priority': 1},
        {'title': 'Monitoreo biomédico', 'description': 'Rastrea indicadores de salud: presión, capacidad pulmonar, etc.', 'category': 'tracking', 'priority': 1},
        {'title': 'Optimización del entorno', 'description': 'Elimina todos los triggers y rediseña espacios asociados', 'category': 'preparation', 'priority': 1},
        {'title': 'Sistema de apoyo profesional', 'description': 'Trabaja con neumólogo, psicólogo y grupo de apoyo', 'category': 'weekly', 'priority': 2},
        {'title': 'Plan de prevención de recaídas', 'description': 'Estrategias específicas para mantener abstinencia a largo plazo', 'category': 'monthly', 'priority': 2},
      ],
    },

    // 💰 AHORRAR DINERO
    'save_money': {
      PlanningStyle.relaxed: [
        {'title': 'Ahorro automático', 'description': 'Configura transferencia automática pequeña cada mes', 'category': 'monthly', 'priority': 2},
        {'title': 'Redondeo de compras', 'description': 'Usa apps que redondeen tus compras y ahorren la diferencia', 'category': 'daily', 'priority': 3},
        {'title': 'Gastos conscientes', 'description': 'Pregúntate "¿realmente necesito esto?" antes de comprar', 'category': 'daily', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Meta mensual clara', 'description': 'Define cantidad específica a ahorrar cada mes', 'category': 'monthly', 'priority': 2},
        {'title': 'Presupuesto 50/30/20', 'description': '50% necesidades, 30% gustos, 20% ahorros', 'category': 'preparation', 'priority': 2},
        {'title': 'Revisión semanal', 'description': 'Revisa gastos semanales y ajusta comportamiento', 'category': 'weekly', 'priority': 3},
        {'title': 'Fondo de emergencia', 'description': 'Prioriza crear fondo equivalente a 3 meses de gastos', 'category': 'milestone', 'priority': 1},
      ],
      PlanningStyle.methodical: [
        {'title': 'Análisis financiero completo', 'description': 'Registra todos los ingresos y gastos durante 3 meses', 'category': 'tracking', 'priority': 1},
        {'title': 'Presupuesto detallado por categorías', 'description': 'Asigna cantidades específicas a cada tipo de gasto', 'category': 'preparation', 'priority': 1},
        {'title': 'Seguimiento diario', 'description': 'Anota cada peso gastado con categoría y justificación', 'category': 'daily', 'priority': 1},
        {'title': 'Evaluación mensual', 'description': 'Analiza variaciones, identifica fugas y optimiza presupuesto', 'category': 'monthly', 'priority': 2},
        {'title': 'Múltiples cuentas de ahorro', 'description': 'Separa dinero por objetivos: emergencia, vacaciones, inversión', 'category': 'preparation', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Sistema financiero integral', 'description': 'Combina presupuesto, inversiones, seguros y planificación fiscal', 'category': 'preparation', 'priority': 1},
        {'title': 'Análisis predictivo', 'description': 'Proyecta gastos futuros y optimiza decisiones financieras', 'category': 'monthly', 'priority': 1},
        {'title': 'Diversificación de ingresos', 'description': 'Desarrolla fuentes pasivas y activas adicionales de dinero', 'category': 'monthly', 'priority': 1},
        {'title': 'Optimización fiscal', 'description': 'Maximiza deducciones y minimiza impuestos legalmente', 'category': 'monthly', 'priority': 2},
        {'title': 'Educación financiera continua', 'description': 'Estudia inversiones, economía y estrategias avanzadas', 'category': 'weekly', 'priority': 2},
        {'title': 'Asesoría profesional', 'description': 'Consulta con expertos financieros para optimizar estrategia', 'category': 'monthly', 'priority': 3},
      ],
    },
  };

  /// Crea estrategias automáticas para un reto basado en su tipo y estilo del usuario
  Future<void> createAutomaticStrategies(int challengeId, String challengeType) async {
    try {
      // Obtener el estilo de planificación del usuario
      final planningStyle = PlanningStyleService.instance.currentStyle;
      
      // Obtener template del tipo de reto (o usar estrategias genéricas como fallback)
      final typeTemplates = _strategyTemplates[challengeType.toLowerCase()];
      final template = typeTemplates?[planningStyle] ?? _getGenericStrategies(planningStyle);
      
      final db = await DatabaseHelper.instance.database;
      
      for (final strategyData in template) {
        final strategy = ChallengeStrategy(
          challengeId: challengeId,
          title: strategyData['title'],
          description: strategyData['description'],
          category: strategyData['category'],
          priority: strategyData['priority'],
        );
        
        await db.insert('challenge_strategies', strategy.toMap());
      }
      
      // Log con información del estilo aplicado
      final styleName = PlanningStyleService.instance.getStyleName(planningStyle);
      
      print('✅ Creadas ${template.length} estrategias automáticas para reto $challengeId (tipo: $challengeType)');
      print('🎨 Estilo aplicado: $styleName');
      notifyListeners();
    } catch (e) {
      print('❌ Error creando estrategias automáticas: $e');
    }
  }

  /// Estrategias genéricas para tipos de reto no específicos
  List<Map<String, dynamic>> _getGenericStrategies(PlanningStyle style) {
    switch (style) {
      case PlanningStyle.relaxed:
        return [
          {'title': 'Pasos pequeños', 'description': 'Avanza poco a poco sin presionarte', 'category': 'daily', 'priority': 3},
          {'title': 'Disfruta el proceso', 'description': 'Enfócate en disfrutar el camino, no solo el resultado', 'category': 'motivation', 'priority': 4},
          {'title': 'Flexibilidad', 'description': 'Ajusta el plan según cómo te sientas cada día', 'category': 'motivation', 'priority': 4},
        ];
      case PlanningStyle.balanced:
        return [
          {'title': 'Rutina consistente', 'description': 'Mantén una rutina equilibrada y sostenible', 'category': 'daily', 'priority': 2},
          {'title': 'Metas semanales', 'description': 'Establece objetivos claros para cada semana', 'category': 'weekly', 'priority': 2},
          {'title': 'Seguimiento básico', 'description': 'Lleva un registro simple de tu progreso', 'category': 'tracking', 'priority': 3},
          {'title': 'Celebra logros', 'description': 'Reconoce y celebra cada pequeño avance', 'category': 'reward', 'priority': 3},
        ];
      case PlanningStyle.methodical:
        return [
          {'title': 'Plan detallado', 'description': 'Crea un plan específico con pasos claros', 'category': 'preparation', 'priority': 1},
          {'title': 'Seguimiento diario', 'description': 'Registra progreso y obstáculos cada día', 'category': 'tracking', 'priority': 1},
          {'title': 'Evaluación semanal', 'description': 'Revisa y ajusta estrategia cada semana', 'category': 'weekly', 'priority': 2},
          {'title': 'Metas intermedias', 'description': 'Establece hitos intermedios para mantener motivación', 'category': 'milestone', 'priority': 2},
          {'title': 'Sistema de backup', 'description': 'Ten plan alternativo para días difíciles', 'category': 'preparation', 'priority': 2},
        ];
      case PlanningStyle.perfectionist:
        return [
          {'title': 'Investigación profunda', 'description': 'Estudia las mejores prácticas y métodos científicos', 'category': 'preparation', 'priority': 1},
          {'title': 'Sistema integral', 'description': 'Diseña un enfoque holístico y multifacético', 'category': 'preparation', 'priority': 1},
          {'title': 'Métricas avanzadas', 'description': 'Monitorea múltiples indicadores de progreso', 'category': 'tracking', 'priority': 1},
          {'title': 'Optimización continua', 'description': 'Refina constantemente métodos y estrategias', 'category': 'weekly', 'priority': 1},
          {'title': 'Red de apoyo', 'description': 'Conecta con expertos y comunidades especializadas', 'category': 'monthly', 'priority': 2},
          {'title': 'Análisis predictivo', 'description': 'Anticipa obstáculos y prepara soluciones', 'category': 'preparation', 'priority': 2},
        ];
    }
  }

  /// Obtiene todas las estrategias de un reto
  Future<List<ChallengeStrategy>> getChallengeStrategies(int challengeId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'challenge_strategies',
        where: 'challengeId = ?',
        whereArgs: [challengeId],
        orderBy: 'priority ASC, category ASC',
      );
      
      return List.generate(maps.length, (i) {
        return ChallengeStrategy.fromMap(maps[i]);
      });
    } catch (e) {
      print('❌ Error obteniendo estrategias del reto: $e');
      return [];
    }
  }

  /// Marca una estrategia como completada
  Future<void> completeStrategy(int strategyId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'challenge_strategies',
        {
          'isCompleted': 1,
          'completedAt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [strategyId],
      );
      
      print('✅ Estrategia $strategyId marcada como completada');
      notifyListeners();
    } catch (e) {
      print('❌ Error completando estrategia: $e');
    }
  }

  /// Desmarca una estrategia como no completada
  Future<void> uncompleteStrategy(int strategyId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.update(
        'challenge_strategies',
        {
          'isCompleted': 0,
          'completedAt': null,
        },
        where: 'id = ?',
        whereArgs: [strategyId],
      );
      
      print('🔄 Estrategia $strategyId desmarcada como completada');
      notifyListeners();
    } catch (e) {
      print('❌ Error descompletando estrategia: $e');
    }
  }

  /// Elimina todas las estrategias de un reto
  Future<void> deleteAllStrategiesForChallenge(int challengeId) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.delete(
        'challenge_strategies',
        where: 'challengeId = ?',
        whereArgs: [challengeId],
      );
      
      print('🗑️ Eliminadas todas las estrategias del reto $challengeId');
      notifyListeners();
    } catch (e) {
      print('❌ Error eliminando estrategias del reto: $e');
    }
  }

  /// Obtiene estadísticas de progreso de un reto
  Future<Map<String, dynamic>> getChallengeProgress(int challengeId) async {
    try {
      final strategies = await getChallengeStrategies(challengeId);
      final total = strategies.length;
      final completed = strategies.where((s) => s.isCompleted).length;
      final percentage = total > 0 ? (completed / total * 100).round() : 0;
      
      // Progreso por categoría
      final byCategory = <String, Map<String, int>>{};
      for (final strategy in strategies) {
        byCategory[strategy.category] ??= {'total': 0, 'completed': 0};
        byCategory[strategy.category]!['total'] = byCategory[strategy.category]!['total']! + 1;
        if (strategy.isCompleted) {
          byCategory[strategy.category]!['completed'] = byCategory[strategy.category]!['completed']! + 1;
        }
      }
      
      return {
        'total': total,
        'completed': completed,
        'pending': total - completed,
        'percentage': percentage,
        'byCategory': byCategory,
      };
    } catch (e) {
      print('❌ Error calculando progreso del reto: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'percentage': 0,
        'byCategory': <String, Map<String, int>>{},
      };
    }
  }
}
