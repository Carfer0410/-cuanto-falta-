import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'notification_center_service.dart';
import 'notification_center_models.dart';
import 'package:intl/intl.dart';

class NotificationCenterPage extends StatefulWidget {
  const NotificationCenterPage({super.key});

  @override
  State<NotificationCenterPage> createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  NotificationType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Notificaciones'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todas', icon: Icon(Icons.inbox)),
            Tab(text: 'Hoy', icon: Icon(Icons.today)),
            Tab(text: 'No leídas', icon: Icon(Icons.mark_email_unread)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar por tipo',
            onSelected: (value) {
              setState(() {
                if (value == 'all') {
                  _selectedFilter = null;
                } else {
                  _selectedFilter = NotificationType.values
                      .firstWhere((type) => type.name == value);
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Todas las categorías'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              ...NotificationType.values.map((type) => PopupMenuItem(
                value: type.name,
                child: Row(
                  children: [
                    Icon(type.icon, color: type.color),
                    const SizedBox(width: 8),
                    Text(type.displayName),
                  ],
                ),
              )),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              final service = NotificationCenterService.instance;
              switch (value) {
                case 'mark_all_read':
                  await service.markAllAsRead();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Todas marcadas como leídas')),
                    );
                  }
                  break;
                case 'delete_read':
                  await service.deleteReadNotifications();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notificaciones leídas eliminadas')),
                    );
                  }
                  break;
                case 'delete_all':
                  _showDeleteAllDialog();
                  break;
                case 'add_samples':
                  await service.addSampleNotifications();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notificaciones de ejemplo agregadas')),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Marcar todas como leídas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_read',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep),
                    SizedBox(width: 8),
                    Text('Eliminar leídas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar todas', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'add_samples',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 8),
                    Text('Agregar ejemplos (Debug)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<NotificationCenterService>(
        builder: (context, service, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationList(service.notifications),
              _buildNotificationList(service.todayNotifications),
              _buildNotificationList(service.unreadNotifications),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<NotificationCenterService>(
        builder: (context, service, child) {
          final unreadCount = service.unreadCount;
          if (unreadCount == 0) return const SizedBox.shrink();
          
          return FloatingActionButton.extended(
            onPressed: () async {
              await service.markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todas marcadas como leídas')),
              );
            },
            icon: const Icon(Icons.mark_email_read),
            label: Text('Marcar $unreadCount como leídas'),
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(List<AppNotification> notifications) {
    // Aplicar filtro si está seleccionado
    final filteredNotifications = _selectedFilter == null
        ? notifications
        : notifications.where((n) => n.type == _selectedFilter).toList();

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Simular refresh - en una app real podrías sincronizar con servidor
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: notification.isRead ? 1 : 3,
      child: InkWell(
        onTap: () async {
          if (!notification.isRead) {
            await NotificationCenterService.instance.markAsRead(notification.id);
          }
          _showNotificationDetails(notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: notification.isRead 
                ? null 
                : Border.all(color: notification.type.color.withOpacity(0.3), width: 2),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: notification.type.color.withOpacity(0.2),
              child: Icon(
                notification.type.icon,
                color: notification.type.color,
                size: 20,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                color: notification.isRead ? Colors.grey[600] : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: notification.isRead ? Colors.grey[500] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: notification.type.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        notification.type.displayName,
                        style: TextStyle(
                          fontSize: 10,
                          color: notification.type.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                final service = NotificationCenterService.instance;
                switch (value) {
                  case 'mark_read':
                    await service.markAsRead(notification.id);
                    break;
                  case 'delete':
                    await service.deleteNotification(notification.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notificación eliminada')),
                    );
                    break;
                }
              },
              itemBuilder: (context) => [
                if (!notification.isRead)
                  const PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(Icons.mark_email_read),
                        SizedBox(width: 8),
                        Text('Marcar como leída'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == null 
                ? 'Las notificaciones aparecerán aquí cuando se generen'
                : 'No hay notificaciones de tipo "${_selectedFilter!.displayName}"',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetails(AppNotification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(notification.type.icon, color: notification.type.color),
            const SizedBox(width: 8),
            Expanded(child: Text(notification.title)),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(notification.body),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(notification.timestamp),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  notification.type.displayName,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (notification.payload != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getPayloadFriendlyText(notification.payload),
                      style: TextStyle(color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          if (!notification.isRead)
            TextButton(
              onPressed: () async {
                await NotificationCenterService.instance.markAsRead(notification.id);
                Navigator.of(context).pop();
              },
              child: const Text('Marcar como leída'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar todas las notificaciones'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar todas las notificaciones? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await NotificationCenterService.instance.deleteAllNotifications();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todas las notificaciones eliminadas')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar todas'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays}d';
    } else {
      return DateFormat('dd/MM').format(timestamp);
    }
  }

  /// Convierte el payload JSON en texto amigable para el usuario
  String _getPayloadFriendlyText(String? payload) {
    if (payload == null || payload.isEmpty) {
      return 'Toca para ver detalles';
    }

    try {
      // Intentar parsear como JSON
      final Map<String, dynamic> data = jsonDecode(payload);
      final String action = data['action'] ?? '';
      final Map<String, dynamic>? extra = data['extra'];

      switch (action) {
        case 'open_home':
          return 'Toca para ir a Inicio';
        case 'open_challenges':
          return 'Toca para ver Retos';
        case 'open_settings':
          return 'Toca para ir a Configuración';
        case 'open_planning_style':
          return 'Toca para configurar estilo de planificación';
        case 'challenge_confirmation':
          final challengeName = extra?['challengeName'] ?? 'reto';
          return 'Toca para confirmar "$challengeName"';
        case 'open_notification_center':
          return 'Toca para ver Centro de Notificaciones';
        default:
          return 'Toca para más información';
      }
    } catch (e) {
      // Si no es JSON válido, mostrar mensaje genérico
      return 'Toca para ver detalles';
    }
  }
}
