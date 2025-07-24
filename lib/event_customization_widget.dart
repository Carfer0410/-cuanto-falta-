import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'event.dart';
import 'localization_service.dart';

class EventCustomizationWidget extends StatelessWidget {
  final EventColor selectedColor;
  final EventIcon selectedIcon;
  final Function(EventColor) onColorChanged;
  final Function(EventIcon) onIconChanged;

  const EventCustomizationWidget({
    super.key,
    required this.selectedColor,
    required this.selectedIcon,
    required this.onColorChanged,
    required this.onIconChanged,
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
                localization.t('customize_appearance'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedColor.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Vista previa del evento
          _buildEventPreview(context, localization),
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

  Widget _buildEventPreview(BuildContext context, LocalizationService localization) {
    // Esta función será sobreescrita por la nueva vista previa dinámica
    // El widget padre (AddEventPage) proporcionará la vista previa real
    return Container(
      height: 0, // Ocultar completamente esta vista previa vieja
      width: 0,
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
        itemCount: EventIcon.values.length,
        itemBuilder: (context, index) {
          final icon = EventIcon.values[index];
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

/// Widget compacto para mostrar la personalización en las tarjetas de eventos
class EventStyleIndicator extends StatelessWidget {
  final EventColor color;
  final EventIcon icon;
  final double size;

  const EventStyleIndicator({
    super.key,
    required this.color,
    required this.icon,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: color.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        icon.icon,
        color: color.color,
        size: size * 0.6,
      ),
    );
  }
}
