void main() {
  print('=== ANÁLISIS: Reto inicia 19/07, usuario registra 22/07 ===\n');
  
  final inicioReal = DateTime(2025, 7, 19);  // Cuando DEBÍA empezar
  final registroUsuario = DateTime(2025, 7, 22);  // Cuando el usuario lo registró
  final hoy = DateTime(2025, 7, 22);  // Hoy
  
  // ========== OPCIÓN 1: CRONÓMETRO DESDE INICIO REAL ==========
  final diasCronometroReal = hoy.difference(inicioReal).inDays;
  
  print('📊 OPCIÓN 1: Cronómetro cuenta desde inicio REAL del reto');
  print('   Inicio real: 19/07');
  print('   Registro usuario: 22/07'); 
  print('   Hoy: 22/07');
  print('   Cronómetro: $diasCronometroReal días (19→20→21→22)');
  print('   Rachas: 0 días (no ha confirmado ningún día aún)');
  print('   📅 Días perdidos: 19/07, 20/07, 21/07');
  
  // ========== OPCIÓN 2: CRONÓMETRO DESDE REGISTRO ==========
  final diasCronometroRegistro = hoy.difference(registroUsuario).inDays;
  
  print('\n📊 OPCIÓN 2: Cronómetro cuenta desde REGISTRO del usuario');
  print('   Inicio del cronómetro: 22/07 (cuando registró)');
  print('   Hoy: 22/07');
  print('   Cronómetro: $diasCronometroRegistro días');
  print('   Rachas: 0 días (no ha confirmado ningún día aún)');
  
  // ========== OPCIÓN 3: RECUPERACIÓN RETROACTIVA ==========
  print('\n📊 OPCIÓN 3: Recuperación retroactiva (actual en la app)');
  print('   Pregunta: "¿Cumpliste desde el 19/07?"');
  print('   Si dice SÍ:');
  print('     - Cronómetro: $diasCronometroReal días (desde 19/07)');
  print('     - Rachas: 4 días otorgadas (19→20→21→22)');
  print('   Si dice NO:');
  print('     - Cronómetro: $diasCronometroRegistro días (desde 22/07)');
  print('     - Rachas: 0 días (empezar desde hoy)');
  
  print('\n=== ANÁLISIS DETALLADO ===');
  print('🗓️ 19 julio: Día 1 del reto (inicio planificado)');
  print('🗓️ 20 julio: Día 2 del reto');
  print('🗓️ 21 julio: Día 3 del reto');
  print('🗓️ 22 julio: Día 4 del reto (día de registro)');
  
  print('\n=== RECOMENDACIÓN ===');
  print('🎯 La OPCIÓN 3 es la más justa:');
  print('   • Le pregunta al usuario si cumplió retroactivamente');
  print('   • Le da la oportunidad de recuperar días perdidos');
  print('   • O empezar limpio desde el día de registro');
  print('   • El cronómetro refleja la realidad del tiempo transcurrido');
}
