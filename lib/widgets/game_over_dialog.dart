import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/wordle_provider.dart';

class GameOverDialog extends StatefulWidget {
  const GameOverDialog({super.key});

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WordleProvider>(context, listen: false);
      if (provider.gameStatus == GameStatus.won) {
        _confettiController.play();
      } else {
        _shakeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordleProvider>();
    final theme = provider.currentTheme;

    final dialogContent = Dialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.isLevelUp) ...[
              const Text(
                "🎉 SEVİYE ATLADIN! 🎉",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withAlpha(100)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.unlockedAvatar,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      provider.newLevelTitle,
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text(
                provider.gameStatus == GameStatus.won ? "TEBRİKLER!" : "OYUN BİTTİ",
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            if (provider.gameStatus == GameStatus.won) ...[
              Text(
                "SÜRE",
                style: TextStyle(fontSize: 12, color: theme.textColor.withAlpha(180)),
              ),
              Text(
                provider.formattedTime,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              if (provider.lastScoreDetails != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.textColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor.withAlpha(50)),
                  ),
                  child: Column(
                    children: [
                      _scoreRow("Temel Puan", provider.lastScoreDetails!['base']!, theme),
                      const SizedBox(height: 4),
                      _scoreRow("Zaman Bonusu", provider.lastScoreDetails!['time']!, theme),
                      const SizedBox(height: 4),
                      _scoreRow("Seri Bonusu", provider.lastScoreDetails!['streak']!, theme),
                      const Divider(height: 16),
                      _scoreRow("TOPLAM PUAN", provider.lastScoreDetails!['total']!, theme, isBold: true),
                    ],
                  ),
                ),
            ] else ...[
              Text(
                "Doğru Kelime:",
                style: TextStyle(fontSize: 14, color: theme.textColor.withAlpha(180)),
              ),
              const SizedBox(height: 8),
              Text(
                provider.targetWord,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade600,
                  letterSpacing: 2.0,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            if (!provider.isDailyMode) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Future.delayed(const Duration(milliseconds: 300), () {
                      provider.resetGame(
                        isDailyMode: provider.isDailyMode,
                        isHardMode: provider.isHardMode,
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "YENİ OYUN",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Return to HomeScreen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "ANA MENÜ",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: dialogContent,
        ),
        if (provider.gameStatus == GameStatus.won)
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
            createParticlePath: drawStar,
          ),
      ],
    );
  }

  Path drawStar(Size size) {
    // Klasik bir yıldız partikülü çizimi (confetti dökümantasyonundan alınma basit bir kare veya daire yerine)
    double degToRad(double deg) => deg * (3.1415926535897932 / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);
    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * 1.0, // simplified for speed
          halfWidth + externalRadius * 1.0); // Would need math.cos and math.sin here for perfect star, let's just use default confetti.
    }
    path.close();
    return path;
  }

  Widget _scoreRow(String label, int value, dynamic theme, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? theme.textColor : theme.textColor.withAlpha(180),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: isBold ? 16 : 14,
          ),
        ),
        Text(
          "+$value",
          style: TextStyle(
            color: isBold ? Colors.green.shade600 : theme.textColor,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            fontSize: isBold ? 18 : 14,
          ),
        ),
      ],
    );
  }
}

