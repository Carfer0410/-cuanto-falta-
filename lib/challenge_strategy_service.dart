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

    // 🥗 ALIMENTACIÓN SALUDABLE
    'healthy_eating': {
      PlanningStyle.relaxed: [
        {'title': 'Cambios graduales', 'description': 'Reemplaza una comida chatarra por saludable cada semana', 'category': 'weekly', 'priority': 2},
        {'title': 'Snacks saludables listos', 'description': 'Ten frutas y frutos secos siempre disponibles', 'category': 'preparation', 'priority': 2},
        {'title': 'Hidratación antes de comer', 'description': 'Bebe agua antes de cada comida para mejor digestión', 'category': 'daily', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Plan de comidas semanal', 'description': 'Planifica menús saludables los domingos', 'category': 'weekly', 'priority': 2},
        {'title': 'Compras inteligentes', 'description': 'Haz lista de compras basada en alimentos nutritivos', 'category': 'preparation', 'priority': 2},
        {'title': '80/20 rule', 'description': '80% comida saludable, 20% permitido para gustos', 'category': 'motivation', 'priority': 3},
        {'title': 'Preparación de comidas', 'description': 'Dedica 2 horas dominicales a meal prep', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Análisis nutricional completo', 'description': 'Calcula macros y micros necesarios según objetivos', 'category': 'preparation', 'priority': 1},
        {'title': 'Registro diario detallado', 'description': 'Anota todo lo que comes con cantidades y horarios', 'category': 'tracking', 'priority': 1},
        {'title': 'Menús estructurados', 'description': 'Crea 28 días de menús balanceados sin repetir', 'category': 'preparation', 'priority': 1},
        {'title': 'Evaluación semanal', 'description': 'Analiza cumplimiento nutricional y ajusta plan', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Sistema nutricional científico', 'description': 'Optimiza nutrición basada en genética y objetivos específicos', 'category': 'preparation', 'priority': 1},
        {'title': 'Monitoreo biométrico', 'description': 'Rastrea peso, grasa corporal, energía y marcadores sanguíneos', 'category': 'tracking', 'priority': 1},
        {'title': 'Suplementación estratégica', 'description': 'Complementa con vitaminas y minerales según análisis', 'category': 'daily', 'priority': 1},
        {'title': 'Cronobiología alimentaria', 'description': 'Optimiza horarios de comida según ritmos circadianos', 'category': 'daily', 'priority': 2},
      ],
    },

    // 🍟 DEJAR COMIDA CHATARRA
    'quit_junk_food': {
      PlanningStyle.relaxed: [
        {'title': 'Reemplazos gradual', 'description': 'Cambia una comida chatarra por saludable cada semana', 'category': 'weekly', 'priority': 2},
        {'title': 'Alternativas satisfactorias', 'description': 'Ten opciones sabrosas y saludables siempre listas', 'category': 'preparation', 'priority': 2},
        {'title': 'Sin culpa', 'description': 'Si comes algo chatarra, simplemente vuelve al plan mañana', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Eliminación por categorías', 'description': 'Semana 1: dulces, 2: frituras, 3: comida rápida, 4: bebidas azucaradas', 'category': 'preparation', 'priority': 2},
        {'title': 'Día libre semanal', 'description': 'Permite un antojo controlado cada domingo', 'category': 'weekly', 'priority': 3},
        {'title': 'Cocina casera', 'description': 'Prepara versiones saludables de tus comidas favoritas', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Identificación de triggers', 'description': 'Registra cuándo, dónde y por qué comes chatarra', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan de sustituciones específicas', 'description': 'Define reemplazo exacto para cada comida chatarra', 'category': 'preparation', 'priority': 1},
        {'title': 'Limpieza completa de despensa', 'description': 'Elimina toda comida procesada de casa y oficina', 'category': 'preparation', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Estudio de aditivos alimentarios', 'description': 'Aprende sobre conservadores, saborizantes y su impacto', 'category': 'preparation', 'priority': 1},
        {'title': 'Desintoxicación supervisada', 'description': 'Plan médico de 30 días para eliminar dependencia a azúcar/sal', 'category': 'monthly', 'priority': 1},
        {'title': 'Cocina gourmet saludable', 'description': 'Domina técnicas culinarias para hacer comida saludable deliciosa', 'category': 'weekly', 'priority': 2},
      ],
    },

    // 🍺 DEJAR EL ALCOHOL
    'quit_alcohol': {
      PlanningStyle.relaxed: [
        {'title': 'Días sin alcohol', 'description': 'Comienza con 2-3 días por semana sin beber', 'category': 'weekly', 'priority': 2},
        {'title': 'Bebidas alternativas', 'description': 'Ten agua con gas, jugos naturales o té disponibles', 'category': 'preparation', 'priority': 2},
        {'title': 'Actividades sustitutos', 'description': 'Encuentra hobbies relajantes para reemplazar el alcohol', 'category': 'motivation', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Reducción gradual', 'description': 'Disminuye consumo 25% cada semana durante un mes', 'category': 'preparation', 'priority': 2},
        {'title': 'Socializacion sober', 'description': 'Busca actividades sociales que no involucren alcohol', 'category': 'weekly', 'priority': 2},
        {'title': 'Sistema de recompensas', 'description': 'Prémiate por cada semana cumpliendo el objetivo', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Análisis de patrones de consumo', 'description': 'Registra cuándo, cuánto y por qué bebes durante 2 semanas', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan estructurado de reducción', 'description': 'Estrategia específica por situación y trigger identificado', 'category': 'preparation', 'priority': 1},
        {'title': 'Red de apoyo', 'description': 'Informa a familia/amigos y busca accountability partner', 'category': 'motivation', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Evaluación médica completa', 'description': 'Consulta médica para plan seguro según nivel de consumo', 'category': 'preparation', 'priority': 1},
        {'title': 'Programa de recuperación integral', 'description': 'Combina terapia, grupo de apoyo y seguimiento médico', 'category': 'weekly', 'priority': 1},
        {'title': 'Monitoreo de salud', 'description': 'Rastrea mejoras en sueño, energía, peso y función hepática', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan de prevención de recaídas', 'description': 'Estrategias específicas para situaciones de alto riesgo', 'category': 'preparation', 'priority': 2},
      ],
    },

    // 📱 REDUCIR TIEMPO EN PANTALLAS
    'reduce_screen_time': {
      PlanningStyle.relaxed: [
        {'title': 'Momentos sin pantalla', 'description': 'Crea períodos cortos sin dispositivos (comidas, 1 hora antes de dormir)', 'category': 'daily', 'priority': 2},
        {'title': 'Actividades alternativas', 'description': 'Ten libros, música o actividades manuales disponibles', 'category': 'preparation', 'priority': 3},
        {'title': 'Notificaciones reducidas', 'description': 'Desactiva notificaciones no esenciales', 'category': 'preparation', 'priority': 2},
      ],
      PlanningStyle.balanced: [
        {'title': 'Límites de tiempo por app', 'description': 'Configura límites diarios en redes sociales y entretenimiento', 'category': 'daily', 'priority': 2},
        {'title': 'Zona libre de tecnología', 'description': 'Mantén dormitorio sin dispositivos electrónicos', 'category': 'preparation', 'priority': 2},
        {'title': 'Horarios específicos', 'description': 'Revisa redes sociales solo en horarios determinados', 'category': 'daily', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Auditoría de uso actual', 'description': 'Registra tiempo exacto en cada app durante una semana', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan de reducción gradual', 'description': 'Disminuye 30 minutos por semana hasta llegar al objetivo', 'category': 'preparation', 'priority': 1},
        {'title': 'Bloqueadores y restricciones', 'description': 'Usa apps para bloquear acceso en horarios específicos', 'category': 'preparation', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Detox digital completo', 'description': 'Plan de 30 días de uso consciente y minimalista de tecnología', 'category': 'monthly', 'priority': 1},
        {'title': 'Optimización de entorno digital', 'description': 'Reorganiza apps, elimina distracciones y crea workflows eficientes', 'category': 'preparation', 'priority': 1},
        {'title': 'Mindfulness tecnológico', 'description': 'Practica uso intencional y consciente de cada dispositivo', 'category': 'daily', 'priority': 1},
        {'title': 'Análisis de productividad', 'description': 'Correlaciona tiempo de pantalla con energía, creatividad y bienestar', 'category': 'weekly', 'priority': 2},
      ],
    },

    // 😴 MEJOR SUEÑO
    'better_sleep': {
      PlanningStyle.relaxed: [
        {'title': 'Rutina relajante', 'description': 'Crea ritual calmante 30 minutos antes de dormir', 'category': 'daily', 'priority': 2},
        {'title': 'Ambiente cómodo', 'description': 'Mantén habitación fresca, oscura y silenciosa', 'category': 'preparation', 'priority': 2},
        {'title': 'Sin pantallas antes de dormir', 'description': 'Evita dispositivos 1 hora antes de acostarte', 'category': 'daily', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Horario consistente', 'description': 'Acuéstate y levántate a la misma hora todos los días', 'category': 'daily', 'priority': 2},
        {'title': 'Optimización de cafeína', 'description': 'No tomes cafeína después de las 2 PM', 'category': 'daily', 'priority': 2},
        {'title': 'Ejercicio matutino', 'description': 'Haz actividad física temprano para mejor sueño nocturno', 'category': 'daily', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Diario de sueño detallado', 'description': 'Registra hora de acostarse, despertar, calidad y factores influyentes', 'category': 'tracking', 'priority': 1},
        {'title': 'Protocolo de higiene del sueño', 'description': 'Lista específica de 15 hábitos para optimizar descanso', 'category': 'preparation', 'priority': 1},
        {'title': 'Análisis semanal de patrones', 'description': 'Identifica factores que mejoran o empeoran tu sueño', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Optimización circadiana completa', 'description': 'Controla luz, temperatura, comidas según ritmos naturales', 'category': 'daily', 'priority': 1},
        {'title': 'Monitoreo avanzado', 'description': 'Usa wearables para rastrear fases, HRV y calidad objetiva', 'category': 'tracking', 'priority': 1},
        {'title': 'Suplementación estratégica', 'description': 'Magnesio, melatonina, L-teanina según necesidades individuales', 'category': 'daily', 'priority': 2},
        {'title': 'Análisis de correlaciones', 'description': 'Relaciona calidad de sueño con productividad, humor y salud', 'category': 'weekly', 'priority': 2},
      ],
    },

    // 💊 DEJAR DROGAS
    'quit_drugs': {
      PlanningStyle.relaxed: [
        {'title': 'Reducción muy gradual', 'description': 'Disminuye uso lentamente sin presión extrema', 'category': 'weekly', 'priority': 2},
        {'title': 'Apoyo emocional', 'description': 'Habla con personas de confianza sobre tu proceso', 'category': 'motivation', 'priority': 1},
        {'title': 'Actividades de reemplazo', 'description': 'Encuentra actividades que te den placer natural', 'category': 'preparation', 'priority': 2},
      ],
      PlanningStyle.balanced: [
        {'title': 'Plan de reducción estructurado', 'description': 'Disminuye 25% del consumo cada semana', 'category': 'preparation', 'priority': 1},
        {'title': 'Red de apoyo', 'description': 'Únete a grupo de apoyo o busca terapia', 'category': 'weekly', 'priority': 1},
        {'title': 'Rutinas saludables', 'description': 'Implementa ejercicio, meditación y hobbies nuevos', 'category': 'daily', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Evaluación médica', 'description': 'Consulta con profesional para plan seguro de desintoxicación', 'category': 'preparation', 'priority': 1},
        {'title': 'Identificación de triggers', 'description': 'Mapea situaciones, emociones y personas que provocan uso', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan de contingencia', 'description': 'Estrategias específicas para cada situación de riesgo', 'category': 'preparation', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Programa de rehabilitación integral', 'description': 'Combina terapia médica, psicológica y apoyo social', 'category': 'preparation', 'priority': 1},
        {'title': 'Reconstrucción completa de lifestyle', 'description': 'Cambia entorno, relaciones y rutinas completamente', 'category': 'monthly', 'priority': 1},
        {'title': 'Monitoreo de recuperación', 'description': 'Rastrea progreso físico, mental y social continuamente', 'category': 'weekly', 'priority': 1},
        {'title': 'Plan de vida a largo plazo', 'description': 'Desarrolla objetivos y estrategias para mantener sobriedad', 'category': 'monthly', 'priority': 2},
      ],
    },

    // 🎮 REDUCIR TIEMPO DE VIDEOJUEGOS
    'reduce_gaming': {
      PlanningStyle.relaxed: [
        {'title': 'Límites flexibles', 'description': 'Juega máximo 2 horas en días entre semana', 'category': 'daily', 'priority': 2},
        {'title': 'Juegos en momentos específicos', 'description': 'Solo después de completar responsabilidades principales', 'category': 'daily', 'priority': 3},
        {'title': 'Actividades alternativas', 'description': 'Ten otras formas de entretenimiento disponibles', 'category': 'preparation', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Horarios designados', 'description': 'Juega solo viernes noche y sábados', 'category': 'weekly', 'priority': 2},
        {'title': 'Timer automático', 'description': 'Programa alarmas para recordar límites de tiempo', 'category': 'daily', 'priority': 2},
        {'title': 'Juegos productivos', 'description': 'Si juegas, elige juegos educativos o de desarrollo mental', 'category': 'motivation', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Análisis de tiempo actual', 'description': 'Registra exactamente cuánto tiempo juegas durante una semana', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan de reducción gradual', 'description': 'Disminuye 1 hora por semana hasta llegar al objetivo', 'category': 'preparation', 'priority': 1},
        {'title': 'Bloqueo de acceso', 'description': 'Usa software para limitar acceso en horarios específicos', 'category': 'preparation', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Análisis del impacto en vida', 'description': 'Evalúa cómo los juegos afectan trabajo, relaciones y salud', 'category': 'tracking', 'priority': 1},
        {'title': 'Reemplazo sistemático', 'description': 'Sustituye tiempo de juego con actividades de crecimiento personal', 'category': 'preparation', 'priority': 1},
        {'title': 'Gamificación de objetivos reales', 'description': 'Aplica mecánicas de juego a metas de vida real', 'category': 'motivation', 'priority': 2},
      ],
    },

    // 🔞 DEJAR HÁBITOS SEXUALES PROBLEMÁTICOS
    'quit_sexual_habits': {
      PlanningStyle.relaxed: [
        {'title': 'Reducción gradual', 'description': 'Disminuye frecuencia lentamente sin presión excesiva', 'category': 'weekly', 'priority': 2},
        {'title': 'Actividades de distracción', 'description': 'Ten actividades físicas o creativas listas cuando sientas impulsos', 'category': 'preparation', 'priority': 2},
        {'title': 'Autocompasión', 'description': 'Si hay recaídas, trátate con amabilidad y continúa', 'category': 'motivation', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Identificación de triggers', 'description': 'Reconoce situaciones, emociones o momentos que disparan el hábito', 'category': 'tracking', 'priority': 2},
        {'title': 'Rutinas de reemplazo', 'description': 'Desarrolla actividades específicas para momentos de impulso', 'category': 'preparation', 'priority': 2},
        {'title': 'Apoyo discreto', 'description': 'Busca recursos online o profesionales especializados', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Registro de patrones', 'description': 'Anota cuándo, dónde y qué emociones preceden al comportamiento', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan de prevención específico', 'description': 'Estrategias detalladas para cada trigger identificado', 'category': 'preparation', 'priority': 1},
        {'title': 'Cambios ambientales', 'description': 'Modifica entorno para reducir exposición a estímulos', 'category': 'preparation', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Investigación científica', 'description': 'Estudia neurociencia de adicciones y métodos de recuperación', 'category': 'preparation', 'priority': 1},
        {'title': 'Terapia especializada', 'description': 'Trabaja con terapeuta especializado en adicciones sexuales', 'category': 'weekly', 'priority': 1},
        {'title': 'Reconstrucción de identidad', 'description': 'Desarrolla nueva autoimagen y sistema de valores', 'category': 'monthly', 'priority': 1},
        {'title': 'Sistema de accountability', 'description': 'Partner de apoyo o grupo de recuperación para seguimiento', 'category': 'weekly', 'priority': 2},
      ],
    },

    // ⏰ DEJAR LA PROCRASTINACIÓN
    'stop_procrastination': {
      PlanningStyle.relaxed: [
        {'title': 'Técnica de 5 minutos', 'description': 'Comprométete a trabajar solo 5 minutos en tareas difíciles', 'category': 'daily', 'priority': 2},
        {'title': 'Tareas fáciles primero', 'description': 'Comienza con lo más simple para generar momentum', 'category': 'daily', 'priority': 3},
        {'title': 'Perdónate las recaídas', 'description': 'Si procrastinas, simplemente regresa a la tarea sin culpa', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Técnica Pomodoro', 'description': '25 minutos de trabajo + 5 de descanso en ciclos', 'category': 'daily', 'priority': 2},
        {'title': 'Lista de prioridades', 'description': 'Identifica las 3 tareas más importantes cada día', 'category': 'daily', 'priority': 2},
        {'title': 'Recompensas pequeñas', 'description': 'Prémiate después de completar tareas importantes', 'category': 'motivation', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Análisis de causas', 'description': 'Identifica qué tipos de tareas y situaciones disparan procrastinación', 'category': 'tracking', 'priority': 1},
        {'title': 'División de tareas grandes', 'description': 'Fragmenta proyectos en pasos específicos y manejables', 'category': 'preparation', 'priority': 1},
        {'title': 'Horarios bloqueados', 'description': 'Asigna tiempo específico para cada tipo de actividad', 'category': 'daily', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Sistema anti-procrastinación integral', 'description': 'Combina GTD, time-blocking y técnicas de productividad avanzadas', 'category': 'preparation', 'priority': 1},
        {'title': 'Análisis de patrones profundo', 'description': 'Correlaciona procrastinación con energía, estado emocional y ambiente', 'category': 'tracking', 'priority': 1},
        {'title': 'Optimización de entorno', 'description': 'Diseña espacios y workflows que minimicen distracciones', 'category': 'preparation', 'priority': 1},
        {'title': 'Accountability y seguimiento', 'description': 'Sistema de reportes y revisión con mentor o partner', 'category': 'weekly', 'priority': 2},
      ],
    },

    // 😤 MANEJO DE LA IRA
    'anger_management': {
      PlanningStyle.relaxed: [
        {'title': 'Respiración cuando te enojes', 'description': 'Respira profundo 10 veces antes de reaccionar', 'category': 'daily', 'priority': 2},
        {'title': 'Tiempo fuera', 'description': 'Tómate un break de 10 minutos cuando sientas ira', 'category': 'daily', 'priority': 2},
        {'title': 'Actividades calmantes', 'description': 'Ten actividades relajantes listas (música, caminar, etc.)', 'category': 'preparation', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Identificación de triggers', 'description': 'Reconoce qué situaciones específicas te provocan ira', 'category': 'tracking', 'priority': 2},
        {'title': 'Técnicas de relajación', 'description': 'Practica meditación o progressive muscle relaxation', 'category': 'weekly', 'priority': 2},
        {'title': 'Comunicación asertiva', 'description': 'Aprende a expresar molestias sin agresividad', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Diario de ira', 'description': 'Registra situaciones, intensidad, triggers y respuestas', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan de manejo específico', 'description': 'Estrategias específicas para cada tipo de trigger identificado', 'category': 'preparation', 'priority': 1},
        {'title': 'Práctica diaria de control', 'description': 'Ejercicios de respiración y mindfulness rutinarios', 'category': 'daily', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Análisis psicológico profundo', 'description': 'Explora causas subyacentes con terapia especializada', 'category': 'weekly', 'priority': 1},
        {'title': 'Programa de inteligencia emocional', 'description': 'Desarrolla habilidades avanzadas de autorregulación', 'category': 'monthly', 'priority': 1},
        {'title': 'Monitoreo biométrico', 'description': 'Usa dispositivos para detectar escalación temprana', 'category': 'tracking', 'priority': 2},
        {'title': 'Estrategias preventivas', 'description': 'Modifica lifestyle para reducir estrés y frustración general', 'category': 'preparation', 'priority': 2},
      ],
    },

    // 😰 REDUCIR ANSIEDAD
    'reduce_anxiety': {
      PlanningStyle.relaxed: [
        {'title': 'Respiración consciente', 'description': 'Practica respiración profunda cuando te sientas ansioso', 'category': 'daily', 'priority': 2},
        {'title': 'Actividades calmantes', 'description': 'Ten lista de cosas que te tranquilizan (música, té, mascotas)', 'category': 'preparation', 'priority': 2},
        {'title': 'Limite de noticias', 'description': 'Reduce exposición a noticias negativas y redes sociales', 'category': 'daily', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Técnicas de grounding', 'description': 'Practica ejercicios 5-4-3-2-1 para estar presente', 'category': 'daily', 'priority': 2},
        {'title': 'Ejercicio regular', 'description': 'Actividad física diaria para reducir cortisol y tensión', 'category': 'daily', 'priority': 2},
        {'title': 'Rutina de sueño', 'description': 'Mejora calidad de sueño para mejor regulación emocional', 'category': 'daily', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Registro de ansiedad', 'description': 'Anota triggers, intensidad, síntomas y estrategias efectivas', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan de manejo escalonado', 'description': 'Estrategias específicas según nivel de ansiedad (1-10)', 'category': 'preparation', 'priority': 1},
        {'title': 'Terapia cognitivo-conductual', 'description': 'Trabaja pensamientos automáticos y patrones mentales', 'category': 'weekly', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Programa integral anti-ansiedad', 'description': 'Combina terapia, medicación, ejercicio y mindfulness', 'category': 'preparation', 'priority': 1},
        {'title': 'Monitoreo de HRV', 'description': 'Usa wearables para rastrear variabilidad cardíaca y estrés', 'category': 'tracking', 'priority': 1},
        {'title': 'Optimización de neurotransmisores', 'description': 'Nutrición y suplementos para balance de serotonina/GABA', 'category': 'daily', 'priority': 2},
        {'title': 'Red de apoyo profesional', 'description': 'Equipo de psiquiatra, terapeuta y médico general', 'category': 'monthly', 'priority': 2},
      ],
    },

    // 🚗 MEJOR MANEJO
    'better_driving': {
      PlanningStyle.relaxed: [
        {'title': 'Paciencia en el tráfico', 'description': 'Escucha música relajante y mantén calma en embotellamientos', 'category': 'daily', 'priority': 2},
        {'title': 'Respeta límites de velocidad', 'description': 'Maneja sin prisa y con velocidad prudente', 'category': 'daily', 'priority': 2},
        {'title': 'Cortesía básica', 'description': 'Cede el paso cuando sea apropiado y agradece cortesías', 'category': 'daily', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Planificación de rutas', 'description': 'Revisa tráfico y elige mejores rutas antes de salir', 'category': 'preparation', 'priority': 2},
        {'title': 'Mantenimiento programado', 'description': 'Realiza servicios del auto según cronograma', 'category': 'monthly', 'priority': 2},
        {'title': 'Técnicas defensivas', 'description': 'Anticipa movimientos de otros conductores y mantén distancia', 'category': 'daily', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Registro de hábitos de manejo', 'description': 'Anota situaciones difíciles y cómo las manejaste', 'category': 'tracking', 'priority': 1},
        {'title': 'Curso de manejo defensivo', 'description': 'Toma curso formal para mejorar técnicas', 'category': 'preparation', 'priority': 1},
        {'title': 'Checklists pre-viaje', 'description': 'Verifica combustible, rutas, clima y condiciones del auto', 'category': 'preparation', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Análisis avanzado de driving', 'description': 'Usa apps para monitorear aceleración, frenado y eficiencia', 'category': 'tracking', 'priority': 1},
        {'title': 'Optimización de combustible', 'description': 'Técnicas eco-driving y maintenance predictivo', 'category': 'preparation', 'priority': 2},
        {'title': 'Sistema de seguridad total', 'description': 'Dashcam, sensores, y tecnología de asistencia al conductor', 'category': 'preparation', 'priority': 1},
      ],
    },

    // 👥 MEJORES RELACIONES
    'better_relationships': {
      PlanningStyle.relaxed: [
        {'title': 'Escucha activa simple', 'description': 'Cuando alguien hable, enfócate realmente en escuchar', 'category': 'daily', 'priority': 2},
        {'title': 'Agradecimientos ocasionales', 'description': 'Agradece o elogia a personas importantes cuando se te ocurra', 'category': 'weekly', 'priority': 3},
        {'title': 'Tiempo de calidad', 'description': 'Pasa tiempo sin distracciones con gente que quieres', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.balanced: [
        {'title': 'Check-ins regulares', 'description': 'Programa llamadas/mensajes semanales con familia y amigos', 'category': 'weekly', 'priority': 2},
        {'title': 'Comunicación asertiva', 'description': 'Expresa necesidades y límites de manera clara y respetuosa', 'category': 'daily', 'priority': 2},
        {'title': 'Resolución de conflictos', 'description': 'Aborda problemas directamente en vez de evitarlos', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Análisis de relaciones actuales', 'description': 'Evalúa calidad y necesidades de cada relación importante', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan de mejora específico', 'description': 'Objetivos y estrategias particulares para cada relación', 'category': 'preparation', 'priority': 1},
        {'title': 'Seguimiento de interacciones', 'description': 'Registra calidad de conversaciones y avances', 'category': 'tracking', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Curso de inteligencia emocional', 'description': 'Desarrolla habilidades avanzadas de comunicación y empatía', 'category': 'monthly', 'priority': 1},
        {'title': 'Análisis de patrones relacionales', 'description': 'Identifica y cambia dinámicas disfuncionales', 'category': 'weekly', 'priority': 1},
        {'title': 'Red de relaciones estratégica', 'description': 'Cultiva conscientemente diversas relaciones de apoyo mutuo', 'category': 'monthly', 'priority': 2},
      ],
    },

    // 🗣️ HABILIDADES SOCIALES
    'social_skills': {
      PlanningStyle.relaxed: [
        {'title': 'Conversaciones casuales', 'description': 'Practica small talk con cajeros, vecinos o conocidos', 'category': 'daily', 'priority': 2},
        {'title': 'Sonríe más', 'description': 'Sonríe genuinamente cuando interactúes con otros', 'category': 'daily', 'priority': 3},
        {'title': 'Participa en grupos existentes', 'description': 'Únete a actividades donde ya hay estructura social', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Practica introducirse', 'description': 'Preséntate a nuevas personas en eventos sociales', 'category': 'weekly', 'priority': 2},
        {'title': 'Lenguaje corporal consciente', 'description': 'Mantén contacto visual y postura abierta', 'category': 'daily', 'priority': 2},
        {'title': 'Eventos sociales regulares', 'description': 'Asiste a 1-2 eventos sociales por semana', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Análisis de habilidades actuales', 'description': 'Identifica fortalezas y áreas de mejora específicas', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan de desarrollo progresivo', 'description': 'Programa semanal de práctica de habilidades específicas', 'category': 'preparation', 'priority': 1},
        {'title': 'Evaluación de interacciones', 'description': 'Reflexiona sobre conversaciones y aprende de cada experiencia', 'category': 'daily', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Curso avanzado de comunicación', 'description': 'Estudia PNL, persuasión ética y dinámicas grupales', 'category': 'monthly', 'priority': 1},
        {'title': 'Práctica en contextos diversos', 'description': 'Desarrolla habilidades en networking, presentaciones y liderazgo', 'category': 'weekly', 'priority': 1},
        {'title': 'Mentoring y feedback', 'description': 'Busca mentor en habilidades sociales y practica con coach', 'category': 'monthly', 'priority': 2},
      ],
    },

    // 📋 ORGANIZACIÓN
    'organization': {
      PlanningStyle.relaxed: [
        {'title': 'Regla de los 2 minutos', 'description': 'Si algo toma menos de 2 minutos, hazlo inmediatamente', 'category': 'daily', 'priority': 2},
        {'title': 'Un lugar para cada cosa', 'description': 'Asigna lugares específicos para objetos importantes', 'category': 'preparation', 'priority': 2},
        {'title': 'Limpieza de 10 minutos', 'description': 'Dedica 10 minutos diarios a organizar', 'category': 'daily', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Sistema de listas', 'description': 'Usa to-do lists y agenda para tareas y citas', 'category': 'daily', 'priority': 2},
        {'title': 'Organización semanal', 'description': 'Dedica 1 hora dominical a planificar y organizar', 'category': 'weekly', 'priority': 2},
        {'title': 'Decluttering mensual', 'description': 'Elimina cosas innecesarias una vez al mes', 'category': 'monthly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Sistema de organización completo', 'description': 'Implementa método como GTD o PARA para todas las áreas', 'category': 'preparation', 'priority': 1},
        {'title': 'Inventario y categorización', 'description': 'Cataloga y organiza sistemáticamente todas las posesiones', 'category': 'preparation', 'priority': 1},
        {'title': 'Rutinas de mantenimiento', 'description': 'Horarios específicos para revisar y mantener organización', 'category': 'weekly', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Sistema digital-físico integrado', 'description': 'Sincroniza organización digital y espacios físicos optimamente', 'category': 'preparation', 'priority': 1},
        {'title': 'Minimalismo estratégico', 'description': 'Optimiza posesiones basado en utilidad y frecuencia de uso', 'category': 'monthly', 'priority': 1},
        {'title': 'Análisis de flujos de trabajo', 'description': 'Optimiza procesos para máxima eficiencia y mínima fricción', 'category': 'weekly', 'priority': 2},
      ],
    },

    // 💼 DESARROLLO PROFESIONAL
    'career_development': {
      PlanningStyle.relaxed: [
        {'title': 'Aprendizaje casual', 'description': 'Dedica tiempo a aprender cosas relacionadas con tu trabajo', 'category': 'weekly', 'priority': 3},
        {'title': 'Networking natural', 'description': 'Conecta con colegas cuando se presenten oportunidades', 'category': 'weekly', 'priority': 3},
        {'title': 'Pequeñas mejoras', 'description': 'Busca maneras simples de hacer mejor tu trabajo actual', 'category': 'daily', 'priority': 2},
      ],
      PlanningStyle.balanced: [
        {'title': 'Objetivos profesionales claros', 'description': 'Define metas a 1, 3 y 5 años en tu carrera', 'category': 'preparation', 'priority': 2},
        {'title': 'Skill development planificado', 'description': 'Dedica 5 horas semanales a desarrollar habilidades clave', 'category': 'weekly', 'priority': 2},
        {'title': 'Eventos de industria', 'description': 'Asiste a conferencias, meetups o webinars mensualmente', 'category': 'monthly', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Plan de carrera detallado', 'description': 'Roadmap específico con habilidades, experiencias y timeline', 'category': 'preparation', 'priority': 1},
        {'title': 'Portfolio de competencias', 'description': 'Documenta y actualiza sistemáticamente logros y habilidades', 'category': 'monthly', 'priority': 1},
        {'title': 'Análisis de mercado laboral', 'description': 'Investiga tendencias y oportunidades en tu campo', 'category': 'monthly', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Estrategia profesional integral', 'description': 'Plan que incluye marca personal, networking estratégico y desarrollo continuo', 'category': 'preparation', 'priority': 1},
        {'title': 'Múltiples flujos de desarrollo', 'description': 'Combina educación formal, certificaciones, mentoring y proyectos laterales', 'category': 'monthly', 'priority': 1},
        {'title': 'Monitoreo de ROI profesional', 'description': 'Rastrea retorno de inversión en tiempo y dinero en desarrollo', 'category': 'monthly', 'priority': 2},
      ],
    },

    // 🎨 CREATIVIDAD
    'creativity': {
      PlanningStyle.relaxed: [
        {'title': 'Tiempo libre para crear', 'description': 'Dedica tiempo sin agenda específica para explorar creatividad', 'category': 'weekly', 'priority': 2},
        {'title': 'Inspiración cotidiana', 'description': 'Observa arte, naturaleza o cosas que te inspiren regularmente', 'category': 'daily', 'priority': 3},
        {'title': 'Juego creativo', 'description': 'Experimenta sin presión de crear algo "bueno"', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Práctica creativa regular', 'description': 'Dedica 30 minutos diarios a tu actividad creativa preferida', 'category': 'daily', 'priority': 2},
        {'title': 'Proyectos pequeños', 'description': 'Completa mini-proyectos creativos semanalmente', 'category': 'weekly', 'priority': 2},
        {'title': 'Exposición a diversas artes', 'description': 'Explora diferentes medios y estilos creativos mensualmente', 'category': 'monthly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Curriculum creativo estructurado', 'description': 'Plan de desarrollo de habilidades creativas específicas', 'category': 'preparation', 'priority': 1},
        {'title': 'Portfolio de proyectos', 'description': 'Documenta y evoluciona tu trabajo creativo sistemáticamente', 'category': 'weekly', 'priority': 1},
        {'title': 'Análisis de proceso creativo', 'description': 'Estudia qué condiciones optimizan tu creatividad', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Laboratorio creativo personal', 'description': 'Espacio y sistema optimizado para experimentación y creación', 'category': 'preparation', 'priority': 1},
        {'title': 'Estudio interdisciplinario', 'description': 'Combina múltiples formas de arte y creatividad', 'category': 'monthly', 'priority': 1},
        {'title': 'Red creativa profesional', 'description': 'Conecta con otros creadores para colaboración y feedback', 'category': 'weekly', 'priority': 2},
      ],
    },

    // 🌱 CUIDADO DEL MEDIO AMBIENTE
    'environment': {
      PlanningStyle.relaxed: [
        {'title': 'Pequeños cambios fáciles', 'description': 'Usa bolsas reutilizables y reduce plásticos cuando puedas', 'category': 'daily', 'priority': 2},
        {'title': 'Transporte consciente', 'description': 'Camina o usa transporte público cuando sea conveniente', 'category': 'weekly', 'priority': 3},
        {'title': 'Consumo mindful', 'description': 'Piensa antes de comprar si realmente lo necesitas', 'category': 'daily', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Reciclaje sistemático', 'description': 'Implementa sistema de separación de residuos en casa', 'category': 'preparation', 'priority': 2},
        {'title': 'Reducción de consumo energético', 'description': 'Optimiza uso de electricidad y agua semanalmente', 'category': 'weekly', 'priority': 2},
        {'title': 'Compras sustentables', 'description': 'Elige productos locales y eco-friendly cuando sea posible', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Auditoría ambiental personal', 'description': 'Analiza tu huella de carbono y desperdicio', 'category': 'tracking', 'priority': 1},
        {'title': 'Plan de sustentabilidad', 'description': 'Estrategia específica para reducir impacto ambiental', 'category': 'preparation', 'priority': 1},
        {'title': 'Seguimiento de métricas', 'description': 'Monitorea consumo de agua, energía y generación de residuos', 'category': 'monthly', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Lifestyle carbono-neutral', 'description': 'Sistema integral para minimizar huella ambiental', 'category': 'preparation', 'priority': 1},
        {'title': 'Tecnología verde', 'description': 'Implementa soluciones tecnológicas para eficiencia ambiental', 'category': 'monthly', 'priority': 1},
        {'title': 'Activismo y educación', 'description': 'Participa en iniciativas ambientales y educa a otros', 'category': 'weekly', 'priority': 2},
      ],
    },

    // 🎸 APRENDER INSTRUMENTO MUSICAL
    'learn_instrument': {
      PlanningStyle.relaxed: [
        {'title': 'Práctica casual', 'description': 'Toca cuando tengas ganas, sin presión de tiempo', 'category': 'motivation', 'priority': 3},
        {'title': 'Canciones que te gusten', 'description': 'Aprende canciones que realmente disfrutes escuchar', 'category': 'preparation', 'priority': 2},
        {'title': 'Apps divertidas', 'description': 'Usa apps como Simply Piano o Yousician para aprender jugando', 'category': 'daily', 'priority': 2},
      ],
      PlanningStyle.balanced: [
        {'title': '20 minutos diarios', 'description': 'Dedica 20 minutos cada día a practicar', 'category': 'daily', 'priority': 2},
        {'title': 'Progresión gradual', 'description': 'Aprende acordes básicos antes de intentar canciones complejas', 'category': 'weekly', 'priority': 2},
        {'title': 'Mezcla teoría y práctica', 'description': 'Combina ejercicios técnicos con canciones divertidas', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Currículo estructurado', 'description': 'Sigue un método específico con lecciones ordenadas', 'category': 'preparation', 'priority': 1},
        {'title': 'Práctica con metrónomo', 'description': 'Desarrolla timing preciso desde el principio', 'category': 'daily', 'priority': 1},
        {'title': 'Registro de progreso', 'description': 'Anota canciones aprendidas y técnicas dominadas', 'category': 'tracking', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Maestro profesional', 'description': 'Estudia con instructor calificado para técnica correcta', 'category': 'weekly', 'priority': 1},
        {'title': 'Teoría musical completa', 'description': 'Aprende lectura de partituras, escalas y armonía', 'category': 'preparation', 'priority': 1},
        {'title': 'Grabación y análisis', 'description': 'Graba tu práctica para identificar áreas de mejora', 'category': 'weekly', 'priority': 2},
      ],
    },

    // 🌍 APRENDER IDIOMAS
    'learn_language': {
      PlanningStyle.relaxed: [
        {'title': 'Apps divertidas', 'description': 'Usa Duolingo o Babbel durante tiempos libres', 'category': 'daily', 'priority': 2},
        {'title': 'Contenido que disfrutes', 'description': 'Ve series o escucha música en el idioma objetivo', 'category': 'weekly', 'priority': 3},
        {'title': 'Sin presión', 'description': 'Aprende a tu ritmo sin estresarte por errores', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Práctica diaria estructurada', 'description': '30 minutos: 15 app + 15 conversación o lectura', 'category': 'daily', 'priority': 2},
        {'title': 'Intercambio de idiomas', 'description': 'Practica con nativos 2 veces por semana', 'category': 'weekly', 'priority': 2},
        {'title': 'Inmersión cultural', 'description': 'Consume contenido auténtico: noticias, podcasts, libros', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Currículo completo', 'description': 'Sigue programa estructurado desde principiante hasta avanzado', 'category': 'preparation', 'priority': 1},
        {'title': 'Todas las habilidades', 'description': 'Balancea hablar, escuchar, leer y escribir diariamente', 'category': 'daily', 'priority': 1},
        {'title': 'Flashcards sistemáticas', 'description': 'Usa Anki para vocabulario con repetición espaciada', 'category': 'daily', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Inmersión total', 'description': 'Cambia idioma de dispositivos y consume solo contenido target', 'category': 'preparation', 'priority': 1},
        {'title': 'Clases privadas', 'description': 'Sesiones individuales con profesor nativo certificado', 'category': 'weekly', 'priority': 1},
        {'title': 'Certificaciones oficiales', 'description': 'Prepárate para exámenes TOEFL, DELE, DELF, etc.', 'category': 'monthly', 'priority': 1},
      ],
    },

    // 🍳 APRENDER A COCINAR
    'learn_cooking': {
      PlanningStyle.relaxed: [
        {'title': 'Recetas simples', 'description': 'Comienza con platos básicos de 3-5 ingredientes', 'category': 'weekly', 'priority': 2},
        {'title': 'YouTube cooking', 'description': 'Sigue chefs que expliquen de manera fácil y divertida', 'category': 'preparation', 'priority': 3},
        {'title': 'Experimenta sin miedo', 'description': 'Si algo sale mal, aprende del error y sigue intentando', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Cocina 3 veces por semana', 'description': 'Programa días específicos para practicar nuevas recetas', 'category': 'weekly', 'priority': 2},
        {'title': 'Técnicas básicas primero', 'description': 'Domina cortar, freír, hervir antes de platos complejos', 'category': 'preparation', 'priority': 2},
        {'title': 'Libro de recetas personal', 'description': 'Anota las que te salieron bien con modificaciones', 'category': 'tracking', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Currículo gastronómico', 'description': 'Plan progresivo: básico → intermedio → avanzado', 'category': 'preparation', 'priority': 1},
        {'title': 'Técnicas por semana', 'description': 'Dedica cada semana a dominar una técnica específica', 'category': 'weekly', 'priority': 1},
        {'title': 'Mise en place perfecto', 'description': 'Organiza todos ingredientes antes de empezar', 'category': 'daily', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Escuela culinaria', 'description': 'Toma clases formales con chefs profesionales', 'category': 'monthly', 'priority': 1},
        {'title': 'Ciencia de la cocina', 'description': 'Estudia química y física detrás de técnicas culinarias', 'category': 'preparation', 'priority': 1},
        {'title': 'Equipamiento profesional', 'description': 'Invierte en herramientas de calidad para mejores resultados', 'category': 'preparation', 'priority': 2},
      ],
    },

    // 💪 GANAR PESO/MÚSCULO
    'gain_muscle': {
      PlanningStyle.relaxed: [
        {'title': 'Ejercicios básicos', 'description': 'Comienza con flexiones, sentadillas y ejercicios con peso corporal', 'category': 'daily', 'priority': 2},
        {'title': 'Come más sin obsesionarte', 'description': 'Agrega snacks saludables entre comidas', 'category': 'daily', 'priority': 2},
        {'title': 'Progreso visible', 'description': 'Tómate fotos semanales para ver cambios', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Rutina 3 días por semana', 'description': 'Programa entrenamiento de fuerza con días de descanso', 'category': 'weekly', 'priority': 2},
        {'title': 'Surplus calórico controlado', 'description': 'Come 300-500 calorías extra de tu mantenimiento', 'category': 'daily', 'priority': 2},
        {'title': 'Proteína en cada comida', 'description': 'Incluye fuente de proteína en desayuno, almuerzo y cena', 'category': 'daily', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Plan de entrenamiento estructurado', 'description': 'Programa específico con progresión de cargas', 'category': 'preparation', 'priority': 1},
        {'title': 'Tracking detallado', 'description': 'Registra peso corporal, medidas y pesos levantados', 'category': 'tracking', 'priority': 1},
        {'title': 'Macros calculados', 'description': 'Calcula proteínas, carbos y grasas según objetivos', 'category': 'daily', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Programa periodizado', 'description': 'Plan anual con fases de volumen, fuerza y definición', 'category': 'preparation', 'priority': 1},
        {'title': 'Suplementación optimizada', 'description': 'Creatina, proteína, vitaminas según análisis de sangre', 'category': 'daily', 'priority': 1},
        {'title': 'Trainer y nutricionista', 'description': 'Equipo profesional para maximizar resultados', 'category': 'monthly', 'priority': 1},
      ],
    },

    // 🧠 ESTUDIAR/EDUCACIÓN
    'study_education': {
      PlanningStyle.relaxed: [
        {'title': 'Sesiones cortas', 'description': 'Estudia 25 minutos con breaks de 5 minutos', 'category': 'daily', 'priority': 2},
        {'title': 'Temas que te interesen', 'description': 'Comienza por materias que realmente disfrutes', 'category': 'motivation', 'priority': 2},
        {'title': 'Ambiente cómodo', 'description': 'Estudia en tu lugar favorito con buena iluminación', 'category': 'preparation', 'priority': 3},
      ],
      PlanningStyle.balanced: [
        {'title': 'Horario fijo de estudio', 'description': 'Dedica 1-2 horas diarias a la misma hora', 'category': 'daily', 'priority': 2},
        {'title': 'Técnicas variadas', 'description': 'Alterna lectura, resúmenes, mapas mentales y práctica', 'category': 'weekly', 'priority': 2},
        {'title': 'Objetivos semanales', 'description': 'Define qué temas cubrir cada semana', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Plan de estudios detallado', 'description': 'Cronograma específico con todos los temas y fechas', 'category': 'preparation', 'priority': 1},
        {'title': 'Sistema de notas estructurado', 'description': 'Método consistente para tomar y organizar apuntes', 'category': 'daily', 'priority': 1},
        {'title': 'Evaluaciones regulares', 'description': 'Auto-exámenes semanales para medir progreso', 'category': 'weekly', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Optimización del aprendizaje', 'description': 'Usa técnicas como repetición espaciada y elaboración', 'category': 'preparation', 'priority': 1},
        {'title': 'Recursos múltiples', 'description': 'Combina libros, videos, podcasts y cursos online', 'category': 'preparation', 'priority': 1},
        {'title': 'Grupo de estudio', 'description': 'Estudia con otros para intercambio de ideas', 'category': 'weekly', 'priority': 2},
      ],
    },

    // 🤝 VOLUNTARIADO
    'volunteering': {
      PlanningStyle.relaxed: [
        {'title': 'Actividades ocasionales', 'description': 'Participa en eventos de voluntariado cuando puedas', 'category': 'weekly', 'priority': 3},
        {'title': 'Causas que te muevan', 'description': 'Elige organizaciones con misiones que te inspiren', 'category': 'motivation', 'priority': 2},
        {'title': 'Compromiso flexible', 'description': 'Ayuda según tu disponibilidad sin presión', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Compromiso semanal', 'description': 'Dedica 4 horas semanales a actividades de voluntariado', 'category': 'weekly', 'priority': 2},
        {'title': 'Variedad de actividades', 'description': 'Alterna entre diferentes tipos de servicio comunitario', 'category': 'monthly', 'priority': 3},
        {'title': 'Networking social', 'description': 'Conoce otros voluntarios y amplía tu red social', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Organización específica', 'description': 'Comprométete con una ONG específica a largo plazo', 'category': 'preparation', 'priority': 1},
        {'title': 'Roles con responsabilidades', 'description': 'Toma posiciones que requieran compromiso y habilidades', 'category': 'weekly', 'priority': 1},
        {'title': 'Seguimiento de impacto', 'description': 'Mide y documenta el impacto de tu trabajo voluntario', 'category': 'tracking', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Liderazgo en voluntariado', 'description': 'Organiza eventos y coordina equipos de voluntarios', 'category': 'monthly', 'priority': 1},
        {'title': 'Desarrollo de habilidades', 'description': 'Usa voluntariado para desarrollar habilidades profesionales', 'category': 'preparation', 'priority': 1},
        {'title': 'Múltiples organizaciones', 'description': 'Participa en varias causas para maximizar impacto', 'category': 'weekly', 'priority': 2},
      ],
    },

    // 📝 ESCRIBIR/JOURNALING
    'writing': {
      PlanningStyle.relaxed: [
        {'title': 'Escritura libre', 'description': 'Escribe lo que se te ocurra sin estructura ni presión', 'category': 'daily', 'priority': 3},
        {'title': 'Momentos de inspiración', 'description': 'Escribe cuando tengas ganas, lleva siempre libreta', 'category': 'preparation', 'priority': 2},
        {'title': 'Sin autocrítica', 'description': 'Escribe sin juzgar, edita después si quieres', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': '500 palabras diarias', 'description': 'Meta diaria fija de escritura, cualquier tema', 'category': 'daily', 'priority': 2},
        {'title': 'Géneros diversos', 'description': 'Alterna entre diario personal, ficción y no ficción', 'category': 'weekly', 'priority': 3},
        {'title': 'Lectura para inspirar', 'description': 'Lee autores que te inspiren en el género que escribes', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Horario fijo de escritura', 'description': 'Misma hora todos los días, ritual de escritura', 'category': 'daily', 'priority': 1},
        {'title': 'Proyectos estructurados', 'description': 'Planifica capítulos, outline y deadlines', 'category': 'preparation', 'priority': 1},
        {'title': 'Seguimiento de progreso', 'description': 'Registra palabras escritas y avance en proyectos', 'category': 'tracking', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Taller de escritura', 'description': 'Únete a grupos de escritores para feedback', 'category': 'weekly', 'priority': 1},
        {'title': 'Revisión sistemática', 'description': 'Proceso de múltiples borradores y edición profesional', 'category': 'weekly', 'priority': 1},
        {'title': 'Publicación como meta', 'description': 'Trabaja hacia publicar en blogs, revistas o libros', 'category': 'monthly', 'priority': 2},
      ],
    },

    // 🚶‍♂️ CAMINAR DIARIAMENTE
    'daily_walking': {
      PlanningStyle.relaxed: [
        {'title': 'Caminatas placenteras', 'description': 'Camina cuando tengas ganas, disfruta el paisaje', 'category': 'daily', 'priority': 3},
        {'title': 'Rutas que disfrutes', 'description': 'Explora parques, plazas o vecindarios bonitos', 'category': 'preparation', 'priority': 2},
        {'title': 'Sin presión de distancia', 'description': 'Cualquier caminata cuenta, sin importar duración', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': '30 minutos diarios', 'description': 'Camina 30 minutos cada día, preferiblemente mañana', 'category': 'daily', 'priority': 2},
        {'title': 'Meta de pasos', 'description': 'Objetivo de 8,000-10,000 pasos diarios', 'category': 'daily', 'priority': 2},
        {'title': 'Rutas variadas', 'description': 'Cambia rutas para mantener interés', 'category': 'weekly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Horario fijo de caminata', 'description': 'Misma hora todos los días para crear hábito', 'category': 'daily', 'priority': 1},
        {'title': 'Tracking detallado', 'description': 'Registra distancia, tiempo, ruta y sensaciones', 'category': 'tracking', 'priority': 1},
        {'title': 'Progresión gradual', 'description': 'Aumenta distancia/velocidad semanalmente', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Programa de entrenamiento', 'description': 'Plan progresivo hacia maratones o medio maratones', 'category': 'preparation', 'priority': 1},
        {'title': 'Análisis biomecánico', 'description': 'Optimiza técnica de caminata y calzado', 'category': 'preparation', 'priority': 2},
        {'title': 'Integración con otros objetivos', 'description': 'Combina con pérdida de peso, meditación o socialización', 'category': 'weekly', 'priority': 2},
      ],
    },

    // 🧘‍♀️ YOGA/ESTIRAMIENTOS
    'yoga_stretching': {
      PlanningStyle.relaxed: [
        {'title': 'Estiramientos matutinos', 'description': 'Estira suavemente al despertar para activar el cuerpo', 'category': 'daily', 'priority': 2},
        {'title': 'Videos de YouTube', 'description': 'Sigue clases gratuitas de yoga para principiantes', 'category': 'daily', 'priority': 3},
        {'title': 'Escucha tu cuerpo', 'description': 'No fuerces posturas, respeta tus límites', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Rutina de 20 minutos', 'description': 'Practica yoga o estiramientos 20 minutos, 4 veces por semana', 'category': 'weekly', 'priority': 2},
        {'title': 'Variedad de estilos', 'description': 'Alterna entre yoga restaurativo, vinyasa y estiramientos', 'category': 'weekly', 'priority': 3},
        {'title': 'Flexibilidad como objetivo', 'description': 'Mide progreso en flexibilidad semanalmente', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Secuencias estructuradas', 'description': 'Aprende secuencias específicas para diferentes objetivos', 'category': 'preparation', 'priority': 1},
        {'title': 'Progresión de asanas', 'description': 'Plan gradual desde básico hasta posturas avanzadas', 'category': 'weekly', 'priority': 1},
        {'title': 'Registro de práctica', 'description': 'Anota posturas trabajadas y sensaciones', 'category': 'tracking', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Clases con instructor', 'description': 'Estudia con maestro certificado para técnica correcta', 'category': 'weekly', 'priority': 1},
        {'title': 'Filosofía del yoga', 'description': 'Estudia historia, filosofía y aspectos espirituales', 'category': 'preparation', 'priority': 2},
        {'title': 'Certificación como meta', 'description': 'Trabaja hacia convertirte en instructor certificado', 'category': 'monthly', 'priority': 2},
      ],
    },

    // 📸 FOTOGRAFÍA
    'photography': {
      PlanningStyle.relaxed: [
        {'title': 'Fotos cotidianas', 'description': 'Toma fotos de lo que te llame la atención durante el día', 'category': 'daily', 'priority': 3},
        {'title': 'Experimenta sin reglas', 'description': 'Prueba diferentes ángulos y composiciones libremente', 'category': 'motivation', 'priority': 3},
        {'title': 'Comparte ocasionalmente', 'description': 'Sube fotos a redes sociales cuando te sientas orgulloso', 'category': 'weekly', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Proyecto 365', 'description': 'Toma al menos una foto interesante cada día', 'category': 'daily', 'priority': 2},
        {'title': 'Aprende técnicas básicas', 'description': 'Estudia composición, iluminación y regla de tercios', 'category': 'weekly', 'priority': 2},
        {'title': 'Salidas fotográficas', 'description': 'Dedica tiempo específico a buscar fotos interesantes', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Curso de fotografía', 'description': 'Sigue currículo estructurado de técnicas fotográficas', 'category': 'preparation', 'priority': 1},
        {'title': 'Práctica técnica diaria', 'description': 'Enfócate en aspectos específicos: exposición, enfoque, etc.', 'category': 'daily', 'priority': 1},
        {'title': 'Portfolio organizado', 'description': 'Crea colecciones temáticas de tus mejores trabajos', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Equipo profesional', 'description': 'Invierte en cámara, lentes y accesorios de calidad', 'category': 'preparation', 'priority': 1},
        {'title': 'Post-procesamiento avanzado', 'description': 'Domina Lightroom y Photoshop para edición profesional', 'category': 'weekly', 'priority': 1},
        {'title': 'Exhibiciones y concursos', 'description': 'Participa en concursos y busca exhibir tu trabajo', 'category': 'monthly', 'priority': 2},
      ],
    },

    // 🏡 JARDINERÍA
    'gardening': {
      PlanningStyle.relaxed: [
        {'title': 'Plantas fáciles', 'description': 'Comienza con plantas resistentes como pothos o suculentas', 'category': 'preparation', 'priority': 2},
        {'title': 'Cuidado básico', 'description': 'Riega cuando la tierra esté seca, sin horarios estrictos', 'category': 'daily', 'priority': 3},
        {'title': 'Disfruta el proceso', 'description': 'Encuentra paz y relajación en el cuidado de plantas', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Jardín pequeño planificado', 'description': 'Diseña espacio con 5-10 plantas variadas', 'category': 'preparation', 'priority': 2},
        {'title': 'Rutina de cuidado', 'description': 'Programa días específicos para riego, poda y fertilización', 'category': 'weekly', 'priority': 2},
        {'title': 'Expansión gradual', 'description': 'Agrega nuevas plantas cada mes según experiencia', 'category': 'monthly', 'priority': 3},
      ],
      PlanningStyle.methodical: [
        {'title': 'Plan de jardín detallado', 'description': 'Diseña layout considerando luz, agua y espacio', 'category': 'preparation', 'priority': 1},
        {'title': 'Calendario de jardinería', 'description': 'Programa siembra, trasplante y cuidados por temporada', 'category': 'preparation', 'priority': 1},
        {'title': 'Registro de plantas', 'description': 'Anota crecimiento, cuidados y problemas de cada planta', 'category': 'tracking', 'priority': 1},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Jardín temático especializado', 'description': 'Enfócate en tipo específico: hierbas, rosas, vegetales', 'category': 'preparation', 'priority': 1},
        {'title': 'Técnicas avanzadas', 'description': 'Aprende injertos, hidroponia o agricultura orgánica', 'category': 'monthly', 'priority': 1},
        {'title': 'Sistema de compostaje', 'description': 'Crea compost propio para fertilización natural', 'category': 'preparation', 'priority': 2},
      ],
    },

    // 💻 PROGRAMACIÓN
    'programming': {
      PlanningStyle.relaxed: [
        {'title': 'Tutoriales básicos', 'description': 'Sigue tutoriales de YouTube para aprender conceptos básicos', 'category': 'weekly', 'priority': 3},
        {'title': 'Proyectos pequeños', 'description': 'Crea programas simples que resuelvan problemas reales', 'category': 'weekly', 'priority': 2},
        {'title': 'Comunidad online', 'description': 'Únete a foros y Discord de programadores', 'category': 'motivation', 'priority': 4},
      ],
      PlanningStyle.balanced: [
        {'title': 'Código diario', 'description': 'Programa al menos 1 hora todos los días', 'category': 'daily', 'priority': 2},
        {'title': 'Curso estructurado', 'description': 'Sigue bootcamp online o curso universitario', 'category': 'preparation', 'priority': 2},
        {'title': 'Proyectos prácticos', 'description': 'Construye portfolio con 3-5 proyectos diversos', 'category': 'monthly', 'priority': 2},
      ],
      PlanningStyle.methodical: [
        {'title': 'Roadmap de desarrollo', 'description': 'Plan específico: frontend, backend, database, deployment', 'category': 'preparation', 'priority': 1},
        {'title': 'Algoritmos y estructuras', 'description': 'Estudia fundamentos de ciencias de la computación', 'category': 'weekly', 'priority': 1},
        {'title': 'Code review sistemático', 'description': 'Revisa código de otros y busca feedback del tuyo', 'category': 'weekly', 'priority': 2},
      ],
      PlanningStyle.perfectionist: [
        {'title': 'Múltiples lenguajes', 'description': 'Domina stack completo: Python, JavaScript, SQL, etc.', 'category': 'monthly', 'priority': 1},
        {'title': 'Contribución open source', 'description': 'Participa en proyectos de código abierto', 'category': 'weekly', 'priority': 1},
        {'title': 'Certificaciones técnicas', 'description': 'Busca certificaciones AWS, Google Cloud, etc.', 'category': 'monthly', 'priority': 2},
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
