# 🎯 INSTRUCCIONES DE USO - CORRECCIÓN DE EMERGENCIA

## 🚨 **PROBLEMA IDENTIFICADO**
Los retos creados el mismo día aparecen automáticamente con 2-3 días de racha debido a datos corruptos en el sistema de migración.

## 🔧 **SOLUCIONES IMPLEMENTADAS**

### **1. DIAGNÓSTICO (🔍 Seguro)**
- **Qué hace**: Solo muestra el estado actual en la consola
- **Cuándo usar**: Para entender qué retos están afectados
- **Resultado**: No modifica nada, solo reporta

### **2. CORRECCIÓN QUIRÚRGICA (🎯 Recomendado)**
- **Qué hace**: 
  - Identifica retos con `lastConfirmedDate = HOY` y `racha > 0`
  - Los resetea a `racha = 0` y `lastConfirmedDate = null`
  - Preserva `bestStreak` y `totalConfirmations`
- **Cuándo usar**: Cuando el diagnóstico confirma retos problemáticos
- **Resultado**: Solo corrige los retos afectados por el bug

### **3. RESET COMPLETO (🚨 Drástico)**
- **Qué hace**: 
  - Elimina TODOS los datos de rachas individuales
  - Resetea el flag de migración
  - Fuerza nueva migración limpia
- **Cuándo usar**: Si la corrección quirúrgica no funciona
- **Resultado**: Empezar completamente de cero

## 📱 **CÓMO USAR EN LA APP**

1. **Abre la app** (debe estar ejecutándose)
2. **Busca el botón rojo 🩹** en la parte superior derecha
3. **Tócalo** para ver las opciones
4. **Sigue este orden**:
   - Primero: **Diagnóstico**
   - Segundo: **Quirúrgica** (si hay problemas)
   - Último: **RESET** (solo si nada más funciona)

## ✅ **VERIFICACIÓN POST-CORRECCIÓN**

### **Crear Reto de Prueba**
1. **Crea un reto nuevo** con fecha de hoy
2. **Verifica que muestre**: `0 días` de racha
3. **NO debe mostrar**: `1 día`, `2 días`, o `3 días` automáticamente

### **Probar Confirmación**
1. **Espera hasta las 21:00-23:59**
2. **Confirma el reto**
3. **Verifica que cambie a**: `1 día` de racha

## 🚀 **ESTADO ESPERADO DESPUÉS DE LA CORRECCIÓN**

- ✅ Retos nuevos empiezan con `racha = 0`
- ✅ Solo aumenta la racha al confirmar manualmente
- ✅ No hay confirmaciones automáticas falsas
- ✅ Sistema de notificaciones funciona correctamente

---

**💡 TIP**: Si sigues viendo el problema después de la corrección quirúrgica, usa el RESET completo y luego reinicia la app completamente.
