//import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_page.dart'; // Cambiar import

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _backgroundController;

  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _logoOpacityAnimation;
  late final Animation<double> _textOpacityAnimation;
  late final Animation<double> _backgroundScaleAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animación del logo (escala y opacidad)
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Animación del texto
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
      ),
    );

    // Animación del fondo circular
    _backgroundScaleAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    // Pequeña pausa inicial
    await Future.delayed(const Duration(milliseconds: 200));

    // Iniciar animación del logo y texto
    _mainController.forward();

    // Esperar un poco y luego iniciar la animación del fondo
    await Future.delayed(const Duration(milliseconds: 600));
    _backgroundController.forward();

    // Esperar a que termine todo
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    // Navegar al LoginPage en lugar del HomePage
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(), // Cambio aquí
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white, // Fondo inicial blanco
        child: Stack(
          children: [
            // Animación de fondo circular que cambia de color
            AnimatedBuilder(
              animation: _backgroundScaleAnimation,
              builder: (context, child) {
                final screenSize = MediaQuery.of(context).size;
                final maxRadius =
                    (screenSize.width > screenSize.height
                        ? screenSize.width
                        : screenSize.height) *
                    0.8;

                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(
                    painter: CircularBackgroundPainter(
                      progress: _backgroundScaleAnimation.value,
                      maxRadius: maxRadius,
                    ),
                  ),
                );
              },
            ),

            // Logo y texto centrados
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tu logo personalizado - SIN placeholder y fondo transparente
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoScaleAnimation,
                      _logoOpacityAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Opacity(
                          opacity: _logoOpacityAnimation.value,
                          child: Container(
                            width: 320,
                            height: 320,
                            child: SvgPicture.asset(
                              'assets/images/tree.svg', // Tu logo SVG
                              width: 320,
                              height: 320,
                              fit: BoxFit.contain,
                              // Sin placeholderBuilder - no más frasco verde
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Texto BioLab
                  AnimatedBuilder(
                    animation: _textOpacityAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacityAnimation.value,
                        child: const Text(
                          'BioLab',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF306B0A), // Color actualizado
                            letterSpacing: 2,
                            fontFamily: 'Poppins', // Fuente Poppins
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter personalizado para la animación circular del fondo
class CircularBackgroundPainter extends CustomPainter {
  final double progress;
  final double maxRadius;

  CircularBackgroundPainter({required this.progress, required this.maxRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFE6DCD3) // Tu color de fondo #e6dcd3
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = maxRadius * progress;

    if (progress > 0) {
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(CircularBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
