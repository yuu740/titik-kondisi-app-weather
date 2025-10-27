import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../constants/dummy_data.dart'; // HAPUS IMPORT INI
import '../provider/theme_provider.dart';
import '../provider/weather_provider.dart'; // TAMBAHKAN IMPORT INI

// ... (Class RainParticle, RainPainter, ShootingStar, StarPainter, LightningPainter
// tidak ada perubahan. Salin-tempel saja dari file Anda yang ada) ...
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

class LightningPainter extends CustomPainter {
  final double opacity;
  LightningPainter({required this.opacity});
  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final flashPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
  }

  @override
  bool shouldRepaint(covariant LightningPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

// --- PERUBAHAN DIMULAI DARI SINI ---

class WeatherBackground extends StatefulWidget {
  const WeatherBackground({super.key});

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _rainController;
  late AnimationController _starController;
  late AnimationController _lightningController;
  late Animation<double> _lightningAnimation;
  Timer? _lightningTimer; // Timer untuk memicu kilat secara periodik

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

    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Durasi kilat yang cepat
    );
    _lightningAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.0), weight: 1),
    ]).animate(_lightningController);

    // --- LOGIKA TIMER DIPINDAHKAN KE `build` ---
    // Logika timer di initState tidak akan berfungsi karena
    // bergantung pada DummyData atau data provider yang mungkin belum siap.

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
    _lightningController.dispose();
    _lightningTimer?.cancel(); // Hentikan timer
    super.dispose();
  }

  // Fungsi helper (tidak ada perubahan)
  LinearGradient _getBackgroundGradient(bool isDarkMode, bool isOvercast) {
    if (isDarkMode) {
      return const LinearGradient(
        colors: [Color(0xFF1a237e), Colors.black],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      if (isOvercast) {
        return LinearGradient(
          colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade700],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      } else {
        return LinearGradient(
          colors: [Colors.lightBlue.shade200, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // 1. DENGARKAN WeatherProvider
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // 2. TAMBAHKAN GUARD: Tampilkan latar belakang default jika data belum siap
    if (weatherProvider.weatherData == null) {
      // Tampilkan gradien default (cerah atau gelap, tapi tidak mendung)
      return Container(
        decoration: BoxDecoration(
          gradient: _getBackgroundGradient(isDarkMode, false),
        ),
      );
    }

    // 3. GUNAKAN DATA API: Tentukan kondisi cuaca dari model
    final weatherData = weatherProvider.weatherData!.weather;

    // Tentukan ambang batas (thresholds)
    // Sesuaikan angka ini jika perlu
    final bool isRaining =
        weatherData.precipitation > 0.1; // (lebih dari 0.1mm)
    final bool isHeavyRain =
        weatherData.precipitation > 2.5; // (lebih dari 2.5mm)
    final bool isCloudy = weatherData.cloudCover > 60; // (lebih dari 60% awan)
    final bool isOvercast = isRaining || isCloudy;
    // final bool isClear = !isOvercast; // (jika diperlukan)

    // 4. KELOLA TIMER KILAT DI SINI
    // Ini akan dievaluasi ulang setiap kali data cuaca berubah
    final bool shouldHaveTimer = isDarkMode && isHeavyRain;

    if (shouldHaveTimer && _lightningTimer == null) {
      // Jika seharusnya ada timer tapi belum ada, BUAT TIMER
      _lightningTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted && (Random().nextBool() || Random().nextBool())) {
          _lightningController.forward(from: 0.0);
        }
      });
    } else if (!shouldHaveTimer && _lightningTimer != null) {
      // Jika seharusnya TIDAK ada timer tapi ada, HENTIKAN TIMER
      _lightningTimer?.cancel();
      _lightningTimer = null;
    }

    // 5. STACK BUILDER SEKARANG MENGGUNAKAN LOGIKA BARU
    return Stack(
      children: [
        // Gradien Latar Belakang yang Dinamis
        Container(
          decoration: BoxDecoration(
            gradient: _getBackgroundGradient(isDarkMode, isOvercast),
          ),
        ),
        // Animasi Hujan
        if (isRaining) // <-- Menggunakan logika baru
          CustomPaint(
            painter: RainPainter(
              particles: rainParticles,
              animation: _rainController,
            ),
            child: Container(),
          ),
        // Animasi Bintang Jatuh
        if (isDarkMode && !isRaining) // <-- Menggunakan logika baru
          CustomPaint(
            painter: StarPainter(
              stars: shootingStars,
              animation: _starController,
            ),
            child: Container(),
          ),

        // Animasi Kilat
        if (isDarkMode && isHeavyRain) // <-- Menggunakan logika baru
          AnimatedBuilder(
            animation: _lightningAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: LightningPainter(opacity: _lightningAnimation.value),
                child: Container(),
              );
            },
          ),
      ],
    );
  }
}

