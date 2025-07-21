import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'planning_style_service.dart';

class PlanningStyleSelectionPage extends StatefulWidget {
  final bool isFirstTime;
  
  const PlanningStyleSelectionPage({
    super.key,
    this.isFirstTime = false,
  });

  @override
  State<PlanningStyleSelectionPage> createState() => _PlanningStyleSelectionPageState();
}

class _PlanningStyleSelectionPageState extends State<PlanningStyleSelectionPage>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  PlanningStyle? _selectedStyle;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _selectedStyle = context.read<PlanningStyleService>().currentStyle;
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planningService = context.watch<PlanningStyleService>();
    
    return Scaffold(
      appBar: widget.isFirstTime ? null : AppBar(
        title: Text(
          '⚙️ Estilo de Planificación',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: widget.isFirstTime 
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.orange.shade50, Colors.white],
                ),
              )
            : null,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isFirstTime) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.psychology,
                              size: 60,
                              color: Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '🎯 ¡Personaliza tu experiencia!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Elige tu estilo de planificación para que todos tus preparativos se adapten a tu personalidad',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ] else ...[
                    Text(
                      '🎨 Elige tu estilo de planificación',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Todos tus eventos futuros se adaptarán automáticamente a tu estilo preferido',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                  
                  Expanded(
                    child: ListView(
                      children: PlanningStyle.values.map((style) {
                        final info = planningService.styleInfo[style]!;
                        final isSelected = _selectedStyle == style;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                setState(() {
                                  _selectedStyle = style;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: isSelected 
                                      ? Colors.orange 
                                      : Colors.grey.shade300,
                                    width: isSelected ? 3 : 1,
                                  ),
                                  color: isSelected 
                                    ? Colors.orange.shade50 
                                    : Colors.grey.shade50,
                                  boxShadow: isSelected 
                                    ? [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          info['emoji'],
                                          style: const TextStyle(fontSize: 28),
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                info['name'],
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected 
                                                    ? Colors.orange.shade800 
                                                    : Colors.black87,
                                                ),
                                              ),
                                              Text(
                                                'x${info['multiplier']} tiempo',
                                                style: TextStyle(
                                                  color: isSelected 
                                                    ? Colors.orange.shade600 
                                                    : Colors.grey.shade600,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.orange,
                                            size: 28,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      info['description'],
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.lightbulb_outline,
                                            size: 16,
                                            color: Colors.blue.shade600,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            info['example'],
                                            style: TextStyle(
                                              color: Colors.blue.shade800,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Botón de confirmar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedStyle != null ? _confirmSelection : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        widget.isFirstTime 
                          ? '🚀 ¡Comenzar con este estilo!' 
                          : '✅ Guardar cambios',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  if (widget.isFirstTime) ...[
                    const SizedBox(height: 15),
                    Center(
                      child: Text(
                        'Podrás cambiarlo después en Configuración',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmSelection() async {
    if (_selectedStyle == null) return;
    
    final planningService = context.read<PlanningStyleService>();
    
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );
    
    try {
      await planningService.setPlanningStyle(_selectedStyle!);
      
      // Cerrar loading
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.isFirstTime 
                      ? '¡Perfecto! Tus eventos se adaptarán a tu estilo'
                      : 'Estilo de planificación actualizado',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      
      // Cerrar pantalla
      if (mounted) {
        Navigator.of(context).pop();
      }
      
    } catch (e) {
      // Cerrar loading
      if (mounted) Navigator.of(context).pop();
      
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
