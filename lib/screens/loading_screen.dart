import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _loopController;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _fade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.78, end: 1).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.1,
                colors: [Color(0xFF4A0808), AppColors.f1Black],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _loopController,
            builder: (context, child) {
              return CustomPaint(
                painter: _SpeedLinesPainter(progress: _loopController.value),
              );
            },
          ),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ScaleTransition(
                        scale: _scale,
                        child: AnimatedBuilder(
                          animation: _loopController,
                          builder: (context, child) {
                            final pulse =
                                1 +
                                (0.035 *
                                    (1 -
                                        (2 * _loopController.value - 1).abs()));
                            return Transform.scale(scale: pulse, child: child);
                          },
                          child: Container(
                            width: 106,
                            height: 106,
                            decoration: BoxDecoration(
                              color: AppColors.f1Red,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.f1Red.withAlpha(80),
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.sports_motorsports,
                              color: Colors.white,
                              size: 58,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'F1 2026',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'SEASON HUB',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white54,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 38),
                      SizedBox(
                        width: 150,
                        child: AnimatedBuilder(
                          animation: _loopController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              value: 0.12 + (_loopController.value * 0.76),
                              minHeight: 3,
                              borderRadius: BorderRadius.circular(3),
                              backgroundColor: Colors.white12,
                              color: AppColors.f1Red,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'PREPARING THE GRID',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white38,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeedLinesPainter extends CustomPainter {
  const _SpeedLinesPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(12)
      ..strokeWidth = 1.2;
    const gap = 44.0;
    final offset = progress * gap;

    for (double y = -size.width; y < size.height + size.width; y += gap) {
      canvas.drawLine(
        Offset(0, y + offset),
        Offset(size.width, y - size.width * 0.35 + offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpeedLinesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
