import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'challenge_strategy.dart';
import 'challenge_strategy_service.dart';

class ChallengeStrategiesPage extends StatefulWidget {
  final int challengeId;
  final String challengeTitle;
  final String challengeType;

  const ChallengeStrategiesPage({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
    required this.challengeType,
  });

  @override
  State<ChallengeStrategiesPage> createState() => _ChallengeStrategiesPageState();
}

class _ChallengeStrategiesPageState extends State<ChallengeStrategiesPage>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  List<ChallengeStrategy> _strategies = [];
  Map<String, dynamic> _progress = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _loadStrategies();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStrategies() async {
    setState(() => _isLoading = true);
    
    final service = ChallengeStrategyService.instance;
    final strategies = await service.getChallengeStrategies(widget.challengeId);
    final progress = await service.getChallengeProgress(widget.challengeId);
    
    // Si no hay estrategias, crear automáticamente
    if (strategies.isEmpty) {
      await service.createAutomaticStrategies(widget.challengeId, widget.challengeType);
      final newStrategies = await service.getChallengeStrategies(widget.challengeId);
      final newProgress = await service.getChallengeProgress(widget.challengeId);
      
      setState(() {
        _strategies = newStrategies;
        _progress = newProgress;
        _isLoading = false;
      });
    } else {
      setState(() {
        _strategies = strategies;
        _progress = progress;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Estrategias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.challengeTitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          )
        : FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Barra de progreso
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progreso General',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          Text(
                            '${_progress['completed'] ?? 0}/${_progress['total'] ?? 0}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: (_progress['total'] ?? 0) > 0 
                            ? (_progress['completed'] ?? 0) / (_progress['total'] ?? 0)
                            : 0.0,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_progress['percentage'] ?? 0}% completado',
                        style: TextStyle(
                          color: Colors.orange.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Lista de estrategias
                Expanded(
                  child: _strategies.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.psychology_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No hay estrategias disponibles',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Las estrategias se generarán automáticamente\nbasadas en tu estilo de planificación',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _strategies.length,
                        itemBuilder: (context, index) {
                          final strategy = _strategies[index];
                          return _buildStrategyCard(strategy);
                        },
                      ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStrategyCard(ChallengeStrategy strategy) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _toggleStrategy(strategy),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: strategy.isCompleted 
                ? Colors.green.shade50 
                : Colors.white,
              border: Border.all(
                color: strategy.isCompleted 
                  ? Colors.green 
                  : Color(strategy.priorityColor).withOpacity(0.3),
                width: strategy.isCompleted ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: strategy.isCompleted
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Emoji de categoría
                    Text(
                      strategy.categoryEmoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 12),
                    
                    // Título y prioridad
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strategy.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: strategy.isCompleted 
                                ? TextDecoration.lineThrough 
                                : null,
                              color: strategy.isCompleted 
                                ? Colors.grey.shade600 
                                : Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(strategy.priorityColor).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  strategy.priorityText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(strategy.priorityColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                strategy.category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: strategy.isCompleted
                        ? Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 28,
                          )
                        : Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.grey.shade400,
                            size: 28,
                          ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Descripción
                Text(
                  strategy.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: strategy.isCompleted 
                      ? Colors.grey.shade600 
                      : Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                
                if (strategy.isCompleted && strategy.completedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '✅ Completado: ${_formatDate(strategy.completedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleStrategy(ChallengeStrategy strategy) async {
    final service = context.read<ChallengeStrategyService>();
    
    if (strategy.isCompleted) {
      await service.uncompleteStrategy(strategy.id);
    } else {
      await service.completeStrategy(strategy.id);
    }
    
    // Recargar datos
    await _loadStrategies();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
