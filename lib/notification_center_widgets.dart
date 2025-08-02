import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_center_service.dart';
import 'notification_center_page.dart';

/// Widget que muestra un ícono de notificaciones con un badge de contador
/// cuando hay notificaciones no leídas
class NotificationCenterButton extends StatelessWidget {
  final Color? iconColor;
  final double? iconSize;
  final String? tooltip;

  const NotificationCenterButton({
    super.key,
    this.iconColor,
    this.iconSize = 24.0,
    this.tooltip = 'Centro de Notificaciones',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationCenterService>(
      builder: (context, service, child) {
        final unreadCount = service.unreadCount;
        
        return IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const NotificationCenterPage(),
              ),
            );
          },
          tooltip: tooltip,
          icon: Stack(
            children: [
              Icon(
                Icons.notifications,
                color: iconColor ?? Theme.of(context).iconTheme.color,
                size: iconSize,
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Widget para mostrar notificaciones recientes como un banner o card pequeño
class NotificationBanner extends StatelessWidget {
  final int maxNotifications;
  final Duration? autoDismissDuration;

  const NotificationBanner({
    super.key,
    this.maxNotifications = 3,
    this.autoDismissDuration,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationCenterService>(
      builder: (context, service, child) {
        final recentNotifications = service.unreadNotifications
            .take(maxNotifications)
            .toList();

        if (recentNotifications.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: recentNotifications.map((notification) {
            return _NotificationCard(
              notification: notification,
              autoDismissDuration: autoDismissDuration,
            );
          }).toList(),
        );
      },
    );
  }
}

class _NotificationCard extends StatefulWidget {
  final notification;
  final Duration? autoDismissDuration;

  const _NotificationCard({
    required this.notification,
    this.autoDismissDuration,
  });

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();

    // Auto dismiss si se especifica duración
    if (widget.autoDismissDuration != null) {
      Future.delayed(widget.autoDismissDuration!, () {
        if (mounted) {
          _dismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    if (mounted) {
      await NotificationCenterService.instance.markAsRead(widget.notification.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_slideAnimation.value * MediaQuery.of(context).size.width, 0),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Card(
                elevation: 4,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotificationCenterPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: widget.notification.type.color.withOpacity(0.2),
                          radius: 20,
                          child: Icon(
                            widget.notification.type.icon,
                            color: widget.notification.type.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.notification.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.notification.body,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: _dismiss,
                            icon: const Icon(Icons.close, size: 18),
                            tooltip: 'Marcar como leída',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget para mostrar un resumen rápido de estadísticas de notificaciones
class NotificationSummary extends StatelessWidget {
  const NotificationSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationCenterService>(
      builder: (context, service, child) {
        final stats = service.statistics;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.notifications, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Resumen de Notificaciones',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Total',
                      value: stats['total'],
                      icon: Icons.all_inclusive,
                    ),
                    _StatItem(
                      label: 'No leídas',
                      value: stats['unread'],
                      icon: Icons.mark_email_unread,
                      color: Colors.red,
                    ),
                    _StatItem(
                      label: 'Hoy',
                      value: stats['today'],
                      icon: Icons.today,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Colors.grey[600],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
