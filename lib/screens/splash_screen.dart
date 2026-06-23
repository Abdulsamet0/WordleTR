import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/wordle_provider.dart';
import 'home_screen.dart';

class Particle {
  final double dx;
  final double dy;
  final Color color;
  final double size;
  
  Particle({required this.dx, required this.dy, required this.color, required this.size});
}

class ParticlePainter extends CustomPainter {
  final double progress;
  final List<Particle> particles;

  ParticlePainter(this.progress, this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;
    
    for (var p in particles) {
      // Fade out and shrink towards the end of progress
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withAlpha((opacity * 255).round());
      
      // Expand outwards from center
      final x = (size.width / 2) + (p.dx * progress * 200);
      final y = (size.height / 2) + (p.dy * progress * 200);
      
      canvas.drawCircle(Offset(x, y), p.size * (1 - progress * 0.3), paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _exitController;
  late final AnimationController _shimmerController;
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  late final Animation<Offset> _block1Slide;
  late final Animation<Offset> _block2Slide;
  late final Animation<Offset> _block3Slide;
  
  late final Animation<Color?> _block1Color;
  late final Animation<Color?> _block2Color;
  late final Animation<Color?> _block3Color;

  late final Animation<double> _textFade;
  late final Animation<double> _exitScale;
  late final Animation<double> _particleExplosion;

  bool _isNavigating = false;
  final List<double> _interactiveScales = [1.0, 1.0, 1.0];
  final List<Particle> _particles = [];
  
  // Renk Paleti (Krmz, Sar, YeYil)
  final Color _colorEmpty = const Color(0xFF3A3A3C);
  final Color _colorRed = const Color(0xFFE53935);
  final Color _colorYellow = const Color(0xFFB59F3B);
  final Color _colorGreen = const Color(0xFF538D4E);

  @override
  void initState() {
    super.initState();
    _generateParticles();
    
    // Sesin hzl almas iin n ykleme yapalm
    _audioPlayer.setSource(AssetSource('sounds/tap.mp3'));

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // Ykleme ubuu hissi iin uzatld
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(); // Srekli parla

    // Dme animasyonlar (lk 1.5 saniye iinde srayla decekler)
    _block1Slide = Tween<Offset>(begin: const Offset(0, -10), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.0, 0.2, curve: Curves.bounceOut)),
    );
    _block2Slide = Tween<Offset>(begin: const Offset(0, -10), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.1, 0.3, curve: Curves.bounceOut)),
    );
    _block3Slide = Tween<Offset>(begin: const Offset(0, -10), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.2, 0.4, curve: Curves.bounceOut)),
    );

    // Den bloklar iin ses efektlerini tetikleyelim
    _entranceController.addListener(() {
      _playDropSoundAt(0.15); // Blok 1
      _playDropSoundAt(0.25); // Blok 2
      _playDropSoundAt(0.35); // Blok 3
    });

    // Renk Dolum Animasyonlar (Loading bar gibi, 0.4 ile 0.9 aras dolacak)
    _block1Color = ColorTween(begin: _colorEmpty, end: _colorRed).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.4, 0.5, curve: Curves.easeIn)),
    );
    _block2Color = ColorTween(begin: _colorEmpty, end: _colorYellow).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.6, 0.7, curve: Curves.easeIn)),
    );
    _block3Color = ColorTween(begin: _colorEmpty, end: _colorGreen).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.8, 0.9, curve: Curves.easeIn)),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: const Interval(0.4, 0.6, curve: Curves.easeIn)),
    );

    _exitScale = Tween<double>(begin: 1.0, end: 3.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInBack),
    );
    
    _particleExplosion = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeOut),
    );

    _entranceController.forward();
    _checkInitialization();
  }

  // Animasyon srasnda sesi bir kez almak iin kk bir kontrol
  final Set<double> _playedSounds = {};
  void _playDropSoundAt(double threshold) {
    if (_entranceController.value >= threshold && !_playedSounds.contains(threshold)) {
      _playedSounds.add(threshold);
      _playTapSound();
    }
  }

  void _generateParticles() {
    final random = Random();
    final colors = [_colorRed, _colorYellow, _colorGreen, Colors.white];
    for (int i = 0; i < 40; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 0.5 + random.nextDouble() * 1.5;
      _particles.add(
        Particle(
          dx: cos(angle) * speed,
          dy: sin(angle) * speed,
          color: colors[random.nextInt(colors.length)],
          size: 3.0 + random.nextDouble() * 5.0,
        )
      );
    }
  }

  void _playTapSound() async {
    final provider = context.read<WordleProvider>();
    if (provider.stats.soundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/tap.mp3'), volume: 0.5);
    }
  }

  void _onBlockTap(int index) {
    HapticFeedback.lightImpact();
    _playTapSound();
    setState(() => _interactiveScales[index] = 0.85);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _interactiveScales[index] = 1.0);
    });
  }

  Future<void> _checkInitialization() async {
    // Toplam minimum 3500ms bekle, kullanc bar grsn
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;

    final provider = context.read<WordleProvider>();
    if (provider.isInitialized) {
      _triggerExit();
    } else {
      provider.addListener(_onProviderUpdate);
    }
  }

  void _onProviderUpdate() {
    final provider = context.read<WordleProvider>();
    if (provider.isInitialized && !_isNavigating) {
      provider.removeListener(_onProviderUpdate);
      _triggerExit();
    }
  }

  void _triggerExit() {
    if (_isNavigating) return;
    _isNavigating = true;

    _exitController.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _exitController.dispose();
    _shimmerController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Color _darken(Color color, [double amount = .2]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Widget _buildInteractiveBlock(int index, Animation<Offset> slide, Animation<Color?> colorAnim) {
    return SlideTransition(
      position: slide,
      child: GestureDetector(
        onTapDown: (_) => _onBlockTap(index),
        child: AnimatedScale(
          scale: _interactiveScales[index],
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedBuilder(
            animation: colorAnim,
            builder: (context, child) {
              final currentColor = colorAnim.value ?? _colorEmpty;
              final shadowColor = _darken(currentColor, 0.15);
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: currentColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      offset: const Offset(0, 6),
                    ),
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    // Sadece renk dolduktan sonra parla
                    if (currentColor == _colorEmpty) return const SizedBox();
                    return ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: const Alignment(-2.0, -1.0),
                          end: const Alignment(2.0, 1.0),
                          colors: [
                            Colors.white.withAlpha(0),
                            Colors.white.withAlpha(76),
                            Colors.white.withAlpha(0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                          transform: GradientRotation(_shimmerController.value * 2 * pi),
                        ).createShader(bounds);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<WordleProvider>().currentTheme;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Stack(
        children: [
          Center(
            child: ScaleTransition(
              scale: _exitScale,
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                  CurvedAnimation(parent: _exitController, curve: const Interval(0.0, 0.8))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInteractiveBlock(0, _block1Slide, _block1Color),
                        const SizedBox(width: 16),
                        _buildInteractiveBlock(1, _block2Slide, _block2Color),
                        const SizedBox(width: 16),
                        _buildInteractiveBlock(2, _block3Slide, _block3Color),
                      ],
                    ),
                    const SizedBox(height: 48),
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          Text(
                            "WORDLE",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              color: theme.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "TÜRKÇE",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 6,
                              color: theme.textColor.withAlpha(150),
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
          
          // Parack Patlamas (Sadece k animasyonunda grnr)
          AnimatedBuilder(
            animation: _particleExplosion,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(_particleExplosion.value, _particles),
                size: Size.infinite,
              );
            },
          ),
        ],
      ),
    );
  }
}
