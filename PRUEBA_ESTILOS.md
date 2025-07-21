# 🧪 **INSTRUCCIONES DE PRUEBA - ESTILOS DE PLANIFICACIÓN**

## 🎯 **CÓMO ACCEDER A LOS ESTILOS:**

### 📱 **PASO 1: Abrir la app**
- Ejecuta la app con `flutter run`
- Espera a que cargue completamente

### ⚙️ **PASO 2: Ir a Configuración**
- En la barra inferior, toca el ícono de **"Ajustes"** (engranaje)
- Deberías ver la pantalla de configuración

### 🎨 **PASO 3: Buscar "Personalización"**
En la pantalla de ajustes deberías ver:

1. **📱 Apariencia** (Modo oscuro)
2. **🎨 Personalización** ← **¡AQUÍ ESTÁ!**
3. **🔔 Notificaciones**
4. **ℹ️ Información**

### 🎯 **PASO 4: Configurar estilo**
- Toca en la sección **"Personalización"**
- Toca **"Estilo de Planificación"**
- Te llevará a la pantalla de selección con 4 opciones:
  - 😌 **Relajado** (0.6x tiempo)
  - ⚖️ **Equilibrado** (1.0x tiempo)
  - 📋 **Metódico** (1.5x tiempo)  
  - 🎯 **Perfeccionista** (2.0x tiempo)

### ✅ **PASO 5: Probar el cambio**
1. Selecciona un estilo (ej: "Metódico")
2. Toca **"✅ Guardar cambios"**
3. Regresa al inicio
4. **Crea un evento nuevo** (ej: cumpleaños)
5. Ve a **"📋 Preparativos"**
6. ¡Los tiempos deberían estar ajustados según tu estilo!

---

## 🔍 **SI NO VES LA SECCIÓN "PERSONALIZACIÓN":**

### 🛠️ **Solución rápida:**
1. Asegúrate de que usas `settings_page_new.dart`
2. Verifica que tengas todas las importaciones
3. Reinicia la app completamente

### 📋 **Verificar código:**
El archivo `settings_page_new.dart` debe tener:
```dart
// Sección de Personalización
Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.psychology, color: Colors.orange),
            SizedBox(width: 8),
            Text('Personalización'),
          ],
        ),
        // ... resto del código
      ],
    ),
  ),
),
```

---

## 🎉 **RESULTADO ESPERADO:**

### 🧪 **Prueba con "Cumpleaños":**
- **Equilibrado:** Invitar 21 días antes
- **Relajado:** Invitar ~13 días antes  
- **Metódico:** Invitar ~32 días antes
- **Perfeccionista:** Invitar ~42 días antes

¡Los preparativos se adaptan automáticamente a tu personalidad! 🎯
