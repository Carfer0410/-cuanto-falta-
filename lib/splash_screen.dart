import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import 'localization_service.dart';

/// 🎨 Splash Screen hermoso y profesional para "¿Cuánto Falta?"
/// 
/// Características:
/// - Logo animado con efectos profesionales
/// - Gradientes dinámicos siguiendo la paleta de la app
/// - Animaciones fluidas y modernas
/// - Texto inspiracional
/// - Transición suave hacia la app principal
class SplashScreen extends StatefulWidget {
  final Widget child;
  
  const SplashScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  
  // 🎭 Controladores de animación
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _gradientController;
  
  // 🎨 Animaciones específicas
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _particleAnimation;
  late Animation<double> _gradientAnimation;
  
  // ⏱️ Timer para controlar la duración del splash
  Timer? _splashTimer;
  
  // 🎯 Estado del splash
  bool _showLogo = false;
  bool _showText = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  /// 🎬 Inicializar todas las animaciones
  void _initializeAnimations() {
    // Logo principal (2.5 segundos)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // Texto (1.5 segundos, empieza después de 1s)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Partículas de fondo (3 segundos, loop)
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Gradiente animado (4 segundos, loop)
    _gradientController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // 🎨 Configurar animaciones del logo
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _logoRotation = Tween<double>(
      begin: 0.0,
      end: math.pi * 2,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));
    
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));

    // 📝 Configurar animaciones del texto
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));
    
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));

    // ✨ Configurar animaciones de efectos
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));
    
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.linear,
    ));
  }

  /// 🎬 Secuencia completa del splash screen
  void _startSplashSequence() async {
    // Esperar un momento antes de empezar
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 1. 🌈 Iniciar gradiente y partículas de fondo
    _gradientController.repeat();
    _particleController.repeat();
    
    // 2. 🎯 Mostrar y animar logo
    setState(() => _showLogo = true);
    _logoController.forward();
    
    // 3. 📝 Después de 1 segundo, mostrar texto
    Timer(const Duration(milliseconds: 1000), () {
      setState(() => _showText = true);
      _textController.forward();
    });
    
    // 4. ⏱️ Después de 3.5 segundos total, completar splash
    _splashTimer = Timer(const Duration(milliseconds: 3500), () {
      _completeSplash();
    });
  }

  /// ✅ Completar el splash y navegar a la app principal
  void _completeSplash() {
    if (_isComplete) return;
    
    setState(() => _isComplete = true);
    
    // Fade out suave antes de cambiar
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => widget.child,
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          return AnimatedBuilder(
            animation: Listenable.merge([
              _gradientController,
              _particleController,
              _logoController,
              _textController,
            ]),
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: _buildAnimatedGradient(isDark),
                ),
                child: Stack(
                  children: [
                    // 🌟 Partículas de fondo animadas
                    ..._buildParticles(),
                    
                    // 🎯 Contenido principal centrado
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 🖼️ Logo principal
                          if (_showLogo) _buildAnimatedLogo(),
                          
                          const SizedBox(height: 40),
                          
                          // 📝 Texto animado
                          if (_showText) _buildAnimatedText(localizationService),
                          
                          const SizedBox(height: 60),
                          
                          // 💫 Indicador de carga elegante
                          if (_showText) _buildLoadingIndicator(),
                        ],
                      ),
                    ),
                    
                    // 🔥 Efectos adicionales en las esquinas
                    ..._buildCornerEffects(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🌈 Gradiente animado de fondo
  Gradient _buildAnimatedGradient(bool isDark) {
    final gradientProgress = _gradientAnimation.value;
    
    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(
            Colors.grey[900]!,
            Colors.orange[900]!.withOpacity(0.3),
            gradientProgress * 0.5,
          )!,
          Color.lerp(
            Colors.black,
            Colors.orange[800]!.withOpacity(0.2),
            gradientProgress * 0.3,
          )!,
          Color.lerp(
            Colors.grey[900]!,
            Colors.orange[700]!.withOpacity(0.1),
            gradientProgress * 0.4,
          )!,
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(
            Colors.orange[50]!,
            Colors.orange[100]!,
            gradientProgress,
          )!,
          Color.lerp(
            Colors.white,
            Colors.orange[50]!,
            gradientProgress * 0.7,
          )!,
          Color.lerp(
            Colors.orange[25] ?? Colors.orange[50]!,
            Colors.orange[75] ?? Colors.orange[100]!,
            gradientProgress * 0.8,
          )!,
        ],
      );
    }
  }

  /// 🎯 Logo principal con animaciones
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Transform.rotate(
            angle: _logoRotation.value,
            child: Opacity(
              opacity: _logoOpacity.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback si no se encuentra el logo
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange[400]!, Colors.orange[600]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: const Icon(
                          Icons.timer,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 📝 Texto animado con el nombre de la app
  Widget _buildAnimatedText(LocalizationService localizationService) {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return SlideTransition(
          position: _textSlide,
          child: Opacity(
            opacity: _textOpacity.value,
            child: Column(
              children: [
                // Título principal
                Text(
                  localizationService.t('appTitle'),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.orange.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Subtítulo inspiracional
                Text(
                  _getInspirationalText(localizationService),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 💫 Indicador de carga elegante
  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textOpacity.value * 0.8,
          child: Container(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.orange.withOpacity(0.8),
              ),
              backgroundColor: Colors.orange.withOpacity(0.2),
            ),
          ),
        );
      },
    );
  }

  /// 🌟 Partículas animadas de fondo
  List<Widget> _buildParticles() {
    final particles = <Widget>[];
    
    for (int i = 0; i < 12; i++) {
      final delay = i * 0.2;
      final animationValue = (_particleAnimation.value + delay) % 1.0;
      
      particles.add(
        Positioned(
          left: (i * 50 + 30) % MediaQuery.of(context).size.width,
          top: MediaQuery.of(context).size.height * animationValue,
          child: Opacity(
            opacity: (1 - animationValue) * 0.3,
            child: Container(
              width: 4 + (i % 3) * 2,
              height: 4 + (i % 3) * 2,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    }
    
    return particles;
  }

  /// 🔥 Efectos en las esquinas
  List<Widget> _buildCornerEffects() {
    return [
      // Efecto superior izquierdo
      Positioned(
        top: -50,
        left: -50,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.orange.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      
      // Efecto inferior derecho
      Positioned(
        bottom: -50,
        right: -50,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.orange.withOpacity(0.15),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ];
  }

  /// 💭 Obtener texto inspiracional según el idioma
  String _getInspirationalText(LocalizationService localizationService) {
    // Usar diferentes mensajes según el idioma actual
    // 🆕 MEJORADO: Mensajes que incluyen AMBAS funcionalidades (eventos + retos)
    switch (localizationService.currentLanguage) {
      case 'en':
        return 'Plan your events,\ntrack your goals';
      case 'pt':
        return 'Planeje seus eventos,\nacompanhe seus objetivos';
      case 'fr':
        return 'Planifiez vos événements,\nsuivez vos objectifs';
      case 'de':
        return 'Plane deine Events,\nverfolge deine Ziele';
      case 'it':
        return 'Pianifica i tuoi eventi,\nsegui i tuoi obiettivi';
      case 'ja':
        return 'イベントを計画し、\n目標を追跡しよう';
      case 'ko':
        return '이벤트를 계획하고,\n목표를 추적하세요';
      case 'zh':
        return '规划活动，\n追踪目标';
      case 'ar':
        return 'خطط لأحداثك،\nتتبع أهدافك';
      case 'ru':
        return 'Планируй события,\nотслеживай цели';
      default: // español
        return 'Planifica tus eventos,\nsigue tus metas';
    }
  }
}
