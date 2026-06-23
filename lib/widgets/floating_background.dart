import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../theme/app_theme.dart';

class FloatingBackground extends StatefulWidget {
  final ThemePalette theme;
  final bool isHardModeHovered;

  const FloatingBackground({
    super.key, 
    required this.theme,
    this.isHardModeHovered = false,
  });

  @override
  State<FloatingBackground> createState() => _FloatingBackgroundState();
}

class _FloatingLetter {
  String letter;
  double x;
  double y;
  double speed;
  double angle;
  double rotationSpeed;
  final double size;

  _FloatingLetter({
    required this.letter,
    required this.x,
    required this.y,
    required this.speed,
    required this.angle,
    required this.rotationSpeed,
    required this.size,
  });
}

class _FloatingBackgroundState extends State<FloatingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FloatingLetter> _letters = [];
  final math.Random _random = math.Random();
  final String _alphabet = "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ";
  double _currentSpeedMultiplier = 1.0;
  double _colorLerpValue = 0.0;

  @override
  void initState() {
    super.initState();

    // Initialize random letters
    for (int i = 0; i < 15; i++) {
      _letters.add(_createRandomLetter());
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
        setState(() {
          _updateLetters();
        });
      });

    _controller.repeat();
  }

  _FloatingLetter _createRandomLetter() {
    return _FloatingLetter(
      letter: _alphabet[_random.nextInt(_alphabet.length)],
      x: _random.nextDouble(),
      y: _random.nextDouble() * 1.2, // Spread them out vertically
      speed: 0.0005 + _random.nextDouble() * 0.001,
      angle: _random.nextDouble() * math.pi * 2,
      rotationSpeed: (_random.nextDouble() - 0.5) * 0.02,
      size: 30 + _random.nextDouble() * 40,
    );
  }

  void _updateLetters() {
    double targetSpeed = widget.isHardModeHovered ? 8.0 : 1.0;
    _currentSpeedMultiplier += (targetSpeed - _currentSpeedMultiplier) * 0.05;

    double targetColorLerp = widget.isHardModeHovered ? 1.0 : 0.0;
    _colorLerpValue += (targetColorLerp - _colorLerpValue) * 0.1;

    for (int i = 0; i < _letters.length; i++) {
      var letter = _letters[i];
      letter.y -= letter.speed * _currentSpeedMultiplier;
      letter.angle += letter.rotationSpeed * _currentSpeedMultiplier;

      // Reset letter if it floats out of screen at the top
      if (letter.y < -0.2) {
        letter.y = 1.2;
        letter.x = _random.nextDouble();
        letter.letter = _alphabet[_random.nextInt(_alphabet.length)];
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color defaultBorderColor = widget.theme.textColor.withAlpha(15);
    Color hoverBorderColor = Colors.red.shade900.withValues(alpha: 0.5);
    Color currentBorderColor = Color.lerp(defaultBorderColor, hoverBorderColor, _colorLerpValue) ?? defaultBorderColor;

    Color defaultBgColor = Colors.transparent;
    Color hoverBgColor = Colors.red.shade900.withValues(alpha: 0.1);
    Color currentBgColor = Color.lerp(defaultBgColor, hoverBgColor, _colorLerpValue) ?? defaultBgColor;

    Color defaultTextColor = widget.theme.textColor.withAlpha(15);
    Color hoverTextColor = Colors.red.shade900.withValues(alpha: 0.6);
    Color currentTextColor = Color.lerp(defaultTextColor, hoverTextColor, _colorLerpValue) ?? defaultTextColor;

    double currentBorderWidth = 2.0 + (1.0 * _colorLerpValue);

    return Stack(
      children: _letters.map((l) {
        return Positioned(
          left: l.x * MediaQuery.of(context).size.width,
          top: l.y * MediaQuery.of(context).size.height,
          child: Transform.rotate(
            angle: l.angle,
            child: Container(
              width: l.size,
              height: l.size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: currentBorderColor,
                  width: currentBorderWidth,
                ),
                color: currentBgColor,
                borderRadius: BorderRadius.circular(l.size * 0.1),
              ),
              child: Text(
                l.letter,
                style: TextStyle(
                  color: currentTextColor,
                  fontSize: l.size * 0.6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
