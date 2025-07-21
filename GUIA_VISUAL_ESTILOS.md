# 🎨 **GUÍA VISUAL: DÓNDE ENCONTRAR LOS ESTILOS DE PLANIFICACIÓN**

## 📱 **NAVEGACIÓN PASO A PASO:**

### 1️⃣ **PANTALLA PRINCIPAL**
```
🏠 Inicio  📊 Contadores  📈 Dashboard  ⚙️ AJUSTES ← Toca aquí
```

### 2️⃣ **PANTALLA DE AJUSTES** 
Deberías ver estas tarjetas en orden:

```
┌─────────────────────────────────┐
│ 🎨 Apariencia                   │
│ ┌─ Modo oscuro                  │
│                                 │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ 🧠 Personalización              │  ← ¡ESTA ES LA NUEVA!
│ ┌─ 😌 Estilo de Planificación  │  ← Toca aquí
│    Equilibrado - Me gusta...    │
│                            →    │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ 🔔 Notificaciones               │
│ ┌─ Recordatorios de Eventos     │
│ ┌─ Recordatorios de Retos       │
│                                 │
└─────────────────────────────────┘
```

### 3️⃣ **PANTALLA DE SELECCIÓN DE ESTILO**
Al tocar "Estilo de Planificación" verás:

```
🎯 ¡Personaliza tu experiencia!

┌─────────────────────────────────┐
│ 😌 Relajado              x0.6   │
│ Prefiero preparar sin mucha...  │
│ 💡 Cumpleaños: invitar 13 días │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ ⚖️ Equilibrado           x1.0   │  ← Seleccionado por defecto
│ Me gusta un balance entre...    │
│ 💡 Cumpleaños: invitar 21 días │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ 📋 Metódico              x1.5   │
│ Prefiero tener todo planeado... │
│ 💡 Cumpleaños: invitar 32 días │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ 🎯 Perfeccionista        x2.0   │
│ Me gusta planificar todo con... │
│ 💡 Cumpleaños: invitar 42 días │
└─────────────────────────────────┘

[✅ Guardar cambios]
```

## 🧪 **PRUEBA RÁPIDA:**

### ✅ **Para verificar que funciona:**

1. **Cambia** el estilo a "Metódico" 
2. **Crea** un evento nuevo: "Cumpleaños de María - 30 días"
3. **Ve** a preparativos
4. **Verifica** que los tiempos sean más largos:
   - En lugar de "21 días antes" → "32 días antes"
   - En lugar de "14 días antes" → "21 días antes"

### 🎯 **Resultado esperado:**
Los preparativos se ajustan automáticamente según tu estilo de personalidad.

---

## ❓ **SI NO APARECE LA SECCIÓN:**

### 🔍 **Posibles causas:**
1. **Hot reload no actualizó:** Reinicia la app completamente
2. **Archivo incorrecto:** Verificar que `root_page.dart` importe `settings_page_new.dart`
3. **Error de compilación:** Verificar que no haya errores en el código

### 🛠️ **Solución:**
- Para la app (Ctrl+C en terminal)
- Ejecuta `flutter clean` 
- Ejecuta `flutter run` de nuevo

¡La funcionalidad está 100% implementada y debería aparecer! 🚀
