import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/dummy_data.dart';
import '../provider/theme_provider.dart';

// Model untuk partikel hujan (Tidak ada perubahan)
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

// Painter untuk Hujan (Tidak ada perubahan)
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

// Model untuk Bintang Jatuh (Tidak ada perubahan)
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

// Painter untuk Bintang Jatuh (Tidak ada perubahan)
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

// --- PERUBAHAN DIMULAI DARI SINI ---

// BARU: Painter untuk efek kilat/petir
class LightningPainter extends CustomPainter {
  final double opacity;

  LightningPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    // Membuat kilatan putih di seluruh layar dengan opacity yang dianimasikan
    final flashPaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
  }

  @override
  bool shouldRepaint(covariant LightningPainter oldDelegate) {
    // Hanya repaint jika opacity berubah
    return oldDelegate.opacity != opacity;
  }
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

  // BARU: Controller dan animasi untuk kilat
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

    // BARU: Inisialisasi controller dan animasi kilat
    _lightningController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Durasi kilat yang cepat
    );
    // Animasikan opacity dari 0 ke 0.6 (agak transparan) lalu kembali ke 0
    _lightningAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.6), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 0.0), weight: 1),
    ]).animate(_lightningController);

    // BARU: Cek jika kondisi hujan deras untuk memulai timer kilat
    final isHeavyRain =
        DummyData.weatherCondition.toLowerCase() == 'heavy rain';
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
        ThemeMode.dark;

    if (isHeavyRain && isDarkMode) {
      // Memicu kilat setiap 5-10 detik secara acak
      _lightningTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted && (Random().nextBool() || Random().nextBool())) {
          _lightningController.forward(from: 0.0);
        }
      });
    }

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
    _lightningController.dispose(); // Hapus controller kilat
    _lightningTimer?.cancel(); // Hentikan timer
    super.dispose();
  }

  // BARU: Fungsi helper untuk memilih gradien latar belakang
  LinearGradient _getBackgroundGradient(bool isDarkMode, bool isOvercast) {
    if (isDarkMode) {
      // Gradien untuk mode malam (tidak berubah)
      return const LinearGradient(
        colors: [Color(0xFF1a237e), Colors.black],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
    } else {
      if (isOvercast) {
        // Gradien BARU untuk kondisi mendung/hujan di siang hari
        return LinearGradient(
          colors: [Colors.blueGrey.shade300, Colors.blueGrey.shade700],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      } else {
        // Gradien cerah untuk siang hari (default)
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
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // Memperbarui logika kondisi cuaca
    final weatherCondition = DummyData.weatherCondition.toLowerCase();
    final isRaining = weatherCondition.contains('rain');
    final isHeavyRain = weatherCondition == 'heavy rain';
    final isCloudy = weatherCondition == 'cloudy';
    final isOvercast =
        isRaining ||
        isCloudy; // Kondisi dianggap mendung jika hujan atau berawan

    return Stack(
      children: [
        // Gradien Latar Belakang yang Dinamis
        Container(
          decoration: BoxDecoration(
            gradient: _getBackgroundGradient(isDarkMode, isOvercast),
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

        // BARU: Animasi Kilat
        if (isDarkMode && isHeavyRain)
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

