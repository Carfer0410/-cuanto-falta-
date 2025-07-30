# 🧪 Cómo Probar las Notificaciones de Ventana de Confirmación

## ✅ Sistema Ya Implementado

Las notificaciones de las **21:00** y **23:30** ya están completamente implementadas y activas. Se ejecutan automáticamente todos los días.

## 🔔 Horarios de Notificaciones

### **21:00 - Apertura de Ventana**
- **Mensaje**: "🎯 ¡Ventana de confirmación abierta!"
- **Función**: Avisar que ya pueden confirmar sus retos
- **Duración**: Hasta las 23:59

### **23:30 - Recordatorio Final**
- **Mensaje**: "⏰ ¡Últimos 29 minutos!"
- **Función**: Recordar que quedan exactamente 29 minutos antes del cierre (23:59)
- **Urgencia**: Alta prioridad

## 🧪 Métodos de Prueba

### **Opción 1: Esperar al Horario Natural**
- Las notificaciones se envían automáticamente a las 21:00 y 23:30
- Solo necesitas tener la app abierta o minimizada
- Verificar que tengas retos activos sin confirmar

### **Opción 2: Prueba Inmediata (Desarrollo)**
Si necesitas probar ahora mismo, puedes ejecutar:

```dart
// Desde cualquier lugar donde tengas acceso al código
await ChallengeNotificationService.testConfirmationNotifications();
```

Esta función enviará inmediatamente:
1. Notificación simulada de 21:00
2. Notificación simulada de 23:30 (3 segundos después)

### **Opción 3: Forzar Ventana de Confirmación**
```dart
await ChallengeNotificationService.testForceWindowNotification();
```

## 📋 Requisitos para que Funcione

### ✅ **Condiciones Necesarias:**
1. **App abierta o minimizada** (no cerrada completamente)
2. **Tener al menos un reto activo** sin confirmar hoy
3. **Notificaciones habilitadas** en configuración
4. **Horario correcto** (21:00 o 23:30)

### ❌ **Por qué podría no funcionar:**
- App completamente cerrada
- Todos los retos ya confirmados hoy
- Notificaciones deshabilitadas
- No hay retos activos

## 🔍 Verificación de Estado

### **Logs en Consola:**
Cuando funciona correctamente, verás:
```
🔍 Verificando ventana de confirmación: 21:00
📢 Enviando notificación de inicio de ventana (21:00)
🔔 Notificación de ventana de confirmación enviada: start
```

### **En la App:**
Al iniciar verás en los logs:
```
🔔 Notificaciones automáticas de ventana de confirmación:
   📱 21:00 - "¡Ventana de confirmación abierta!"
   📱 23:30 - "¡Últimos 30 minutos!"
```

## 🚀 Confirmación de Funcionamiento

El sistema está **100% funcional** y se ejecuta automáticamente. Las notificaciones aparecerán puntualmente a las 21:00 y 23:30 todos los días, siempre que:

1. Tengas retos pendientes de confirmar
2. La app esté abierta/minimizada
3. Las notificaciones estén habilitadas

**No necesitas hacer nada adicional - el sistema ya está trabajando automáticamente.**
