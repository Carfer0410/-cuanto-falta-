import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event.dart';
import 'preparation_task.dart';
import 'preparation_service.dart';
import 'localization_service.dart';
import 'theme_service.dart';

class EventPreparationsPage extends StatefulWidget {
  final Event event;

  const EventPreparationsPage({
    Key? key,
    required this.event,
  }) : super(key: key);

  @override
  State<EventPreparationsPage> createState() => _EventPreparationsPageState();
}

class _EventPreparationsPageState extends State<EventPreparationsPage> {
  List<PreparationTask> _preparations = [];
  Map<String, int> _stats = {'total': 0, 'completed': 0, 'pending': 0};
  Map<String, dynamic>? _recalibrationSuggestion; // 🆕 NUEVO
  bool _isLoading = true;
  bool _isRecalibrating = false; // Para evitar múltiples recalibraciones

  @override
  void initState() {
    super.initState();
    _loadPreparations();
  }

  @override
  void dispose() {
    // Limpiar cualquier operación pendiente
    _isRecalibrating = false;
    super.dispose();
  }

  Future<void> _loadPreparations() async {
    setState(() => _isLoading = true);
    
    final preparations = await PreparationService.instance.getEventPreparations(widget.event.id!);
    final stats = await PreparationService.instance.getEventPreparationStats(widget.event.id!);
    final suggestion = await PreparationService.instance.shouldSuggestRecalibration(widget.event.id!); // 🆕 NUEVO
    
    setState(() {
      _preparations = preparations;
      _stats = stats;
      _recalibrationSuggestion = suggestion; // 🆕 NUEVO
      _isLoading = false;
    });
  }

  Future<void> _toggleTask(PreparationTask task) async {
    // Determinar la nueva acción ANTES de cambiar el estado local
    final willBeCompleted = !task.isCompleted;
    
    // 🆕 OPTIMIZACIÓN: Actualizar estado local inmediatamente para evitar parpadeo
    setState(() {
      final index = _preparations.indexWhere((p) => p.id == task.id);
      if (index != -1) {
        _preparations[index].isCompleted = willBeCompleted;
        _preparations[index].completedAt = willBeCompleted 
            ? DateTime.now() 
            : null;
        
        // Actualizar estadísticas localmente
        if (willBeCompleted) {
          _stats['completed'] = (_stats['completed'] ?? 0) + 1;
        } else {
          _stats['completed'] = (_stats['completed'] ?? 1) - 1;
        }
      }
    });
    
    try {
      // Luego actualizar en la base de datos usando la acción determinada anteriormente
      if (willBeCompleted) {
        await PreparationService.instance.completeTask(task.id!, notify: false);
      } else {
        await PreparationService.instance.uncompleteTask(task.id!, notify: false);
      }
    } catch (e) {
      // Si falla la operación de base de datos, revertir el estado local
      print('❌ Error al actualizar preparativo: $e');
      setState(() {
        final index = _preparations.indexWhere((p) => p.id == task.id);
        if (index != -1) {
          _preparations[index].isCompleted = !willBeCompleted;
          _preparations[index].completedAt = !willBeCompleted 
              ? DateTime.now() 
              : null;
          
          // Revertir estadísticas
          if (!willBeCompleted) {
            _stats['completed'] = (_stats['completed'] ?? 0) + 1;
          } else {
            _stats['completed'] = (_stats['completed'] ?? 1) - 1;
          }
        }
      });
      
      // Mostrar mensaje de error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al actualizar preparativo')),
        );
      }
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    int selectedDays = 7;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('➕ Agregar Preparativo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Título',
                hintText: 'Ej: Comprar regalo',
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Detalles del preparativo',
              ),
              maxLines: 2,
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Text('Días antes del evento: '),
                Expanded(
                  child: DropdownButton<int>(
                    value: selectedDays,
                    items: [1, 3, 7, 14, 21, 30].map((days) {
                      return DropdownMenuItem(
                        value: days,
                        child: Text('$days días'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDays = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty) {
                await PreparationService.instance.addCustomTask(
                  widget.event.id!,
                  titleController.text,
                  descriptionController.text,
                  selectedDays,
                );
                Navigator.pop(context);
                _loadPreparations();
              }
            },
            child: Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(PreparationTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🗑️ Eliminar Preparativo'),
        content: Text('¿Estás seguro de que quieres eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await PreparationService.instance.deleteTask(task.id!);
              Navigator.pop(context);
              _loadPreparations();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  /// 📝 NUEVO: Diálogo para agregar/editar nota personal
  void _showNoteDialog(PreparationTask task) {
    final noteController = TextEditingController(text: task.personalNote ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.note_add, color: widget.event.color.color),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                task.hasPersonalNote ? 'Editar nota personal' : 'Agregar nota personal',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📋 ${task.title}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: widget.event.color.color,
                ),
              ),
              SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  color: context.secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Nota personal',
                  hintText: 'Ej: Comprar en el centro comercial, recordar tarjeta...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Agrega detalles específicos o recordatorios para este preparativo',
                style: TextStyle(
                  fontSize: 12,
                  color: context.hintColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (task.hasPersonalNote)
            TextButton(
              onPressed: () async {
                await PreparationService.instance.updatePersonalNote(task.id!, null);
                Navigator.pop(context);
                _loadPreparations();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('📝 Nota eliminada')),
                );
              },
              child: Text('Quitar nota', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final note = noteController.text.trim();
              await PreparationService.instance.updatePersonalNote(
                task.id!, 
                note.isEmpty ? null : note,
              );
              Navigator.pop(context);
              _loadPreparations();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('📝 Nota guardada')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: widget.event.color.color),
            child: Text('Guardar nota', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 🆕 NUEVO: Diálogo para re-calibrar preparativos automáticamente
  void _showRecalibrationDialog() {
    final now = DateTime.now();
    final daysUntilEvent = widget.event.targetDate.difference(now).inDays;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_fix_high, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '🔄 Re-calibrar Preparativos',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu evento está en $daysUntilEvent días.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 12),
              Text(
                '¿Quieres que re-calibre automáticamente los preparativos para adaptarse mejor al tiempo disponible?',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✨ La re-calibración hará:',
                      style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue[700]),
                    ),
                    SizedBox(height: 8),
                    Text('• Eliminar preparativos obsoletos', style: TextStyle(fontSize: 13)),
                    Text('• Crear nuevos preparativos adaptados', style: TextStyle(fontSize: 13)),
                    Text('• Ajustar tiempos al evento próximo', style: TextStyle(fontSize: 13)),
                    Text('• Mantener preparativos ya completados', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Note: Se mantendrán los preparativos que ya completaste.',
                style: TextStyle(fontSize: 12, color: context.secondaryTextColor, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Evitar múltiples ejecuciones
              if (_isRecalibrating) return;
              _isRecalibrating = true;
              
              // Cerrar diálogo
              Navigator.pop(context);
              
              try {
                // Ejecutar re-calibración directamente
                await _performRecalibration();
              } finally {
                // Resetear flag
                if (mounted) {
                  _isRecalibrating = false;
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.orangeVariant),
            child: Text('🔄 Re-calibrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Método separado para realizar la re-calibración de forma segura
  Future<void> _performRecalibration() async {
    // Solo proceder si el widget está montado
    if (!mounted) return;
    
    // Mostrar loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('🔄 Re-calibrando preparativos...')),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
    
    try {
      // Ejecutar re-calibración
      await PreparationService.instance.recalibrateEventPreparations(widget.event.id!);
      
      // Solo continuar si el widget sigue montado
      if (!mounted) return;
      
      // Recargar preparativos
      await _loadPreparations();
      
      // Mostrar éxito solo si el widget sigue montado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Preparativos re-calibrados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Mostrar error solo si el widget sigue montado
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al re-calibrar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('❌ Error en re-calibración: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text('📋 Preparativos'),
            backgroundColor: widget.event.color.color,
            foregroundColor: Colors.white,
            actions: [
              // 🆕 NUEVO: Botón de re-calibración inteligente
              IconButton(
                icon: Icon(Icons.auto_fix_high),
                onPressed: _showRecalibrationDialog,
                tooltip: 'Re-calibrar preparativos',
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: _showAddTaskDialog,
                tooltip: 'Agregar preparativo',
              ),
            ],
          ),
          body: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Header con información del evento
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.isDark 
                            ? widget.event.color.color.withOpacity(0.2)
                            : widget.event.color.lightColor,
                        border: Border(
                          bottom: BorderSide(
                            color: widget.event.color.color.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                widget.event.icon.icon,
                                color: widget.event.color.color,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.event.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: context.isDark 
                                        ? Colors.white
                                        : widget.event.color.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            _getDaysUntilEvent(),
                            style: TextStyle(
                              fontSize: 14,
                              color: context.isDark 
                                  ? Colors.white70
                                  : context.secondaryTextColor,
                            ),
                          ),
                          SizedBox(height: 12),
                          // Progreso de preparativos
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: _stats['total']! > 0 
                                      ? _stats['completed']! / _stats['total']! 
                                      : 0,
                                  backgroundColor: context.borderColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.event.color.color,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                '${_stats['completed']}/${_stats['total']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: context.isDark 
                                      ? Colors.white
                                      : widget.event.color.color,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Sugerencia inteligente de recalibración
                    if (_recalibrationSuggestion != null)
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getSuggestionColor().withOpacity(0.1),
                          border: Border.all(
                            color: _getSuggestionColor().withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: _getSuggestionColor(),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Sugerencia Inteligente',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _getSuggestionColor(),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getSuggestionColor().withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _recalibrationSuggestion!['urgency'].toString().toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _getSuggestionColor(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              _recalibrationSuggestion!['reason'],
                              style: TextStyle(
                                fontSize: 13,
                                color: context.isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _handleRecalibrationSuggestion,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getSuggestionColor(),
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    child: Text(
                                      'Recalibrar Automáticamente',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _recalibrationSuggestion = null;
                                    });
                                  },
                                  child: Text(
                                    'Descartar',
                                    style: TextStyle(
                                      color: _getSuggestionColor(),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    
                    // Lista de preparativos
                    Expanded(
                      child: _preparations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.checklist,
                                    size: 64,
                                    color: context.iconColor,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No hay preparativos aún',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: context.secondaryTextColor,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Agrega preparativos personalizados',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(8),
                              itemCount: _preparations.length,
                              itemBuilder: (context, index) {
                                final preparation = _preparations[index];
                                return _buildPreparationCard(preparation);
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPreparationCard(PreparationTask task) {
    final shouldShow = task.shouldShowTask(widget.event.targetDate);
    final isOverdue = task.isOverdue(widget.event.targetDate);
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      color: context.cardColor,
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: shouldShow ? (_) => _toggleTask(task) : null,
          activeColor: widget.event.color.color,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w500,
            color: task.isCompleted 
                ? context.secondaryTextColor
                : isOverdue 
                    ? Colors.red[700]
                    : context.primaryTextColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              style: TextStyle(
                color: task.isCompleted ? context.hintColor : context.secondaryTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // 📝 Mostrar nota personal si existe
            if (task.hasPersonalNote) ...[
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.event.color.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.event.color.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 14,
                      color: widget.event.color.color,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        task.personalNote!,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.event.color.color,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  shouldShow 
                      ? Icons.schedule 
                      : Icons.schedule_outlined,
                  size: 14,
                  color: shouldShow 
                      ? (isOverdue ? Colors.red : widget.event.color.color)
                      : context.hintColor,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _getTaskTimingText(task),
                    style: TextStyle(
                      fontSize: 12,
                      color: shouldShow 
                          ? (isOverdue ? Colors.red : widget.event.color.color)
                          : context.hintColor,
                      fontWeight: shouldShow ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (task.isCompleted && task.completedAt != null) ...[
                  SizedBox(width: 8),
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    'Completado',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: shouldShow
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmation(task);
                  } else if (value == 'note') {
                    _showNoteDialog(task);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'note',
                    child: Row(
                      children: [
                        Icon(
                          task.hasPersonalNote ? Icons.edit_note : Icons.note_add,
                          color: widget.event.color.color,
                        ),
                        SizedBox(width: 8),
                        Text(task.hasPersonalNote ? 'Editar nota' : 'Agregar nota'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar'),
                      ],
                    ),
                  ),
                ],
              )
            : null,
        enabled: shouldShow,
        tileColor: shouldShow 
            ? (isOverdue ? (context.isDark ? Colors.red[900]?.withOpacity(0.3) : Colors.red[50]) : null)
            : context.surfaceColor,
      ),
    );
  }

  String _getDaysUntilEvent() {
    final now = DateTime.now();
    final difference = widget.event.targetDate.difference(now).inDays;
    
    if (difference > 0) {
      return '🗓️ Faltan $difference días';
    } else if (difference == 0) {
      return '🎯 ¡Hoy es el día!';
    } else {
      return '✅ Evento pasado';
    }
  }

  String _getTaskTimingText(PreparationTask task) {
    final now = DateTime.now();
    final daysUntilEvent = widget.event.targetDate.difference(now).inDays;
    
    if (task.daysBeforeEvent == 0) {
      return 'El día del evento';
    } else if (task.shouldShowTask(widget.event.targetDate)) {
      if (task.isOverdue(widget.event.targetDate)) {
        // 🆕 NUEVO: Lógica inteligente para evitar advertencias innecesarias
        final daysDifference = task.daysBeforeEvent - daysUntilEvent;
        
        // Si la diferencia es pequeña y el evento es próximo, no mostrar como "vencido"
        if (daysUntilEvent <= 7 && daysDifference <= 3) {
          return '📍 Ajustado';
        }
        
        // Si el evento es muy próximo (menos de 5 días), adaptar mensaje
        if (daysUntilEvent <= 5) {
          return '⚡ Urgente';
        }
        
        // Para casos normales de retraso
        return '⚠️ Hace $daysDifference días';
      } else {
        return '📍 Recomendado ahora';
      }
    } else {
      // 🆕 NUEVO: Manejo inteligente de tareas futuras en eventos próximos
      final daysUntilTask = daysUntilEvent - task.daysBeforeEvent;
      
      // Si el evento es muy próximo pero la tarea está en el futuro, ajustar mensaje
      if (daysUntilEvent <= 7 && daysUntilTask > daysUntilEvent) {
        return '⏰ Adaptado';
      }
      
      return 'En $daysUntilTask días';
    }
  }

  // Métodos para el sistema de sugerencias inteligentes
  Color _getSuggestionColor() {
    if (_recalibrationSuggestion == null) return Colors.blue;
    
    switch (_recalibrationSuggestion!['urgency']) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'normal':
      default:
        return Colors.blue;
    }
  }

  void _handleRecalibrationSuggestion() async {
    if (_recalibrationSuggestion == null) return;

    // Mostrar diálogo de confirmación
    bool? shouldProceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recalibración Automática'),
        content: Text(
          '¿Deseas que el sistema recalibre automáticamente los preparativos de este evento según la nueva proximidad detectada?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getSuggestionColor(),
            ),
            child: Text('Recalibrar'),
          ),
        ],
      ),
    );

    if (shouldProceed == true) {
      try {
        // Ejecutar la recalibración automática
        await PreparationService.instance.recalibrateEventPreparations(widget.event.id!);
        
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Recalibración completada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Recargar los datos
        setState(() {
          _recalibrationSuggestion = null;
        });
        await _loadPreparations();

      } catch (e) {
        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error en la recalibración: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
