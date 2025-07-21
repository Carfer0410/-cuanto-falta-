import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event.dart';
import 'preparation_task.dart';
import 'preparation_service.dart';
import 'localization_service.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreparations();
  }

  Future<void> _loadPreparations() async {
    setState(() => _isLoading = true);
    
    final preparations = await PreparationService.instance.getEventPreparations(widget.event.id!);
    final stats = await PreparationService.instance.getEventPreparationStats(widget.event.id!);
    
    setState(() {
      _preparations = preparations;
      _stats = stats;
      _isLoading = false;
    });
  }

  Future<void> _toggleTask(PreparationTask task) async {
    if (task.isCompleted) {
      await PreparationService.instance.uncompleteTask(task.id!);
    } else {
      await PreparationService.instance.completeTask(task.id!);
    }
    _loadPreparations();
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
                        color: widget.event.color.lightColor,
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
                                    color: widget.event.color.color,
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
                              color: Colors.grey[600],
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
                                  backgroundColor: Colors.grey[300],
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
                                  color: widget.event.color.color,
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
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'No hay preparativos aún',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Agrega preparativos personalizados',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
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
                ? Colors.grey[600] 
                : isOverdue 
                    ? Colors.red[700]
                    : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              style: TextStyle(
                color: task.isCompleted ? Colors.grey[500] : Colors.grey[700],
              ),
            ),
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
                      : Colors.grey[500],
                ),
                SizedBox(width: 4),
                Text(
                  _getTaskTimingText(task),
                  style: TextStyle(
                    fontSize: 12,
                    color: shouldShow 
                        ? (isOverdue ? Colors.red : widget.event.color.color)
                        : Colors.grey[500],
                    fontWeight: shouldShow ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                if (task.isCompleted && task.completedAt != null) ...[
                  SizedBox(width: 12),
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
                  }
                },
                itemBuilder: (context) => [
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
            ? (isOverdue ? Colors.red[50] : null)
            : Colors.grey[100],
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
        return '⚠️ Recomendado hace ${task.daysBeforeEvent - daysUntilEvent} días';
      } else {
        return '📍 Recomendado ahora (${task.daysBeforeEvent} días antes)';
      }
    } else {
      return 'En ${daysUntilEvent - task.daysBeforeEvent} días (${task.daysBeforeEvent} días antes)';
    }
  }
}
