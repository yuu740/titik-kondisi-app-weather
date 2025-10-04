import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/dummy_data.dart';
import '../provider/theme_provider.dart';

// Model untuk partikel hujan
class RainParticle {
  late Offset position;
  late double speed;
  late double length;
  late double opacity;

  RainParticle(Size area) {
    reset(area);
  }

  void reset(Size area) {
    position = Offset(
      Random().nextDouble() * area.width,
      -Random().nextDouble() * area.height,
    );
    speed = 2 + Random().nextDouble() * 3;
    length = 10 + Random().nextDouble() * 10;
    opacity = 0.1 + Random().nextDouble() * 0.4;
  }
}

// Painter untuk Hujan
class RainPainter extends CustomPainter {
  final List<RainParticle> particles;
  final Animation<double> animation;

  RainPainter({required this.particles, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rainPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (var particle in particles) {
      particle.position = Offset(
        particle.position.dx,
        particle.position.dy + particle.speed,
      );
      if (particle.position.dy > size.height) {
        particle.reset(size);
      }
      rainPaint.color = Colors.white.withOpacity(particle.opacity);
      rainPaint.strokeWidth = 1 + Random().nextDouble();
      canvas.drawLine(
        particle.position,
        Offset(particle.position.dx, particle.position.dy - particle.length),
        rainPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Model untuk Bintang Jatuh
class ShootingStar {
  late Offset position;
  late double speed;
  late double size;
  late double angle;
  late double tailLength;
  double life = 1.0;

  ShootingStar(Size area) {
    reset(area);
  }

  void reset(Size area) {
    position = Offset(
      Random().nextDouble() * area.width,
      Random().nextDouble() * area.height * 0.5,
    );
    speed = 5 + Random().nextDouble() * 10;
    size = 1 + Random().nextDouble() * 2;
    angle = pi / 4 + (Random().nextDouble() - 0.5) * 0.2;
    tailLength = 100 + Random().nextDouble() * 100;
    life = 1.0;
  }
}

// Painter untuk Bintang Jatuh
class StarPainter extends CustomPainter {
  final List<ShootingStar> stars;
  final Animation<double> animation;

  StarPainter({required this.stars, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint();

    for (var star in stars) {
      star.position = Offset(
        star.position.dx + cos(star.angle) * star.speed,
        star.position.dy + sin(star.angle) * star.speed,
      );
      star.life -= 0.01;

      if (star.life <= 0) {
        star.reset(size);
      }

      final tailEnd = Offset(
        star.position.dx - cos(star.angle) * star.tailLength * (1 - star.life),
        star.position.dy - sin(star.angle) * star.tailLength * (1 - star.life),
      );

      final gradient = LinearGradient(
        colors: [
          Colors.white.withOpacity(star.life),
          Colors.white.withOpacity(0),
        ],
      );

      starPaint.shader = gradient.createShader(
        Rect.fromPoints(star.position, tailEnd),
      );
      starPaint.strokeWidth = star.size;
      canvas.drawLine(star.position, tailEnd, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Widget Utama untuk Background
class WeatherBackground extends StatefulWidget {
  const WeatherBackground({super.key});

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _starController;
  List<RainParticle> rainParticles = [];
  List<ShootingStar> shootingStars = [];

  @override
  void initState() {
    super.initState();
    _rainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      rainParticles = List.generate(100, (_) => RainParticle(size));
      shootingStars = List.generate(3, (_) => ShootingStar(size));
      setState(() {});
    });
  }

  @override
  void dispose() {
    _rainController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final isRaining = DummyData.weatherCondition.toLowerCase().contains('rain');

    return Stack(
      children: [
        // Gradien Latar Belakang
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [const Color(0xFF1a237e), Colors.black]
                  : [Colors.lightBlue.shade200, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Animasi Hujan
        if (isRaining)
          CustomPaint(
            painter: RainPainter(
              particles: rainParticles,
              animation: _rainController,
            ),
            child: Container(),
          ),
        // Animasi Bintang Jatuh
        if (isDarkMode && !isRaining)
          CustomPaint(
            painter: StarPainter(
              stars: shootingStars,
              animation: _starController,
            ),
            child: Container(),
          ),
      ],
    );
  }
}
