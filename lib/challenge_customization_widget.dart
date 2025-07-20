import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event.dart';
import 'localization_service.dart';

class ChallengeCustomizationWidget extends StatelessWidget {
  final EventColor selectedColor;
  final EventIcon selectedIcon;
  final Function(EventColor) onColorChanged;
  final Function(EventIcon) onIconChanged;
  final bool isNegativeHabit;

  const ChallengeCustomizationWidget({
    super.key,
    required this.selectedColor,
    required this.selectedIcon,
    required this.onColorChanged,
    required this.onIconChanged,
    this.isNegativeHabit = false,
  });

  @override
  Widget build(BuildContext context) {
    final localization = Provider.of<LocalizationService>(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: selectedColor.lightColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedColor.color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Row(
            children: [
              Icon(
                Icons.palette,
                color: selectedColor.color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                localization.t('customize_challenge'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedColor.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Vista previa del reto
          _buildChallengePreview(context, localization),
          const SizedBox(height: 24),
          
          // Selector de color
          Text(
            localization.t('choose_color'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          _buildColorSelector(),
          const SizedBox(height: 24),
          
          // Selector de icono
          Text(
            localization.t('choose_icon'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          _buildIconSelector(),
        ],
      ),
    );
  }

  Widget _buildChallengePreview(BuildContext context, LocalizationService localization) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: selectedColor.color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icono del reto
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: selectedColor.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  selectedIcon.icon,
                  color: selectedColor.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Información del reto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.t('preview_challenge_title'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isNegativeHabit 
                        ? localization.t('preview_stop_habit') 
                        : localization.t('preview_start_habit'),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Estado del reto
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selectedColor.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '7 días',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Timer de progreso
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: selectedColor.lightColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selectedColor.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '7d 12h 35m 42s',
                style: TextStyle(
                  fontSize: 18,
                  color: selectedColor.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: EventColor.values.length,
        itemBuilder: (context, index) {
          final color = EventColor.values[index];
          final isSelected = color == selectedColor;
          
          return GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    color.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected ? Colors.black : Colors.grey.shade600,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconSelector() {
    // Iconos más relevantes para retos/hábitos
    final challengeIcons = [
      EventIcon.star,
      EventIcon.fitness,
      EventIcon.favorite,
      EventIcon.local_hospital,
      EventIcon.sports,
      EventIcon.emoji_events,
      EventIcon.music,
      EventIcon.restaurant,
      EventIcon.work,
      EventIcon.school,
      EventIcon.home,
      EventIcon.nature,
      EventIcon.beach,
      EventIcon.pets,
      EventIcon.movie,
      EventIcon.camera,
      EventIcon.shopping,
      EventIcon.celebration,
      EventIcon.cake,
      EventIcon.flight,
    ];
    
    return SizedBox(
      height: 80,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: challengeIcons.length,
        itemBuilder: (context, index) {
          final icon = challengeIcons[index];
          final isSelected = icon == selectedIcon;
          
          return GestureDetector(
            onTap: () => onIconChanged(icon),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? selectedColor.color.withOpacity(0.2) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? selectedColor.color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(
                icon.icon,
                color: isSelected ? selectedColor.color : Colors.grey.shade600,
                size: 24,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget compacto para mostrar la personalización en las tarjetas de retos
class ChallengeStyleIndicator extends StatelessWidget {
  final EventColor color;
  final EventIcon icon;
  final double size;
  final bool isActive;

  const ChallengeStyleIndicator({
    super.key,
    required this.color,
    required this.icon,
    this.size = 40,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isActive 
          ? color.color.withOpacity(0.1) 
          : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: isActive 
            ? color.color.withOpacity(0.3) 
            : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Icon(
        icon.icon,
        color: isActive ? color.color : Colors.grey.shade500,
        size: size * 0.6,
      ),
    );
  }
}
