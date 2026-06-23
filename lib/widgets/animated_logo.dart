import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../theme/app_theme.dart';

class AnimatedLogo extends StatefulWidget {
  final ThemePalette theme;
  final double size;
  final double fontSize;
  final int waitSeconds;

  const AnimatedLogo({
    super.key, 
    required this.theme,
    this.size = 45,
    this.fontSize = 26,
    this.waitSeconds = 5,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  final String _word = "WORDLE";
  late List<AnimationController> _controllers;
  late List<AnimationController> _jumpControllers;
  late List<Animation<double>> _animations;
  late List<Animation<double>> _jumpAnimations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      _word.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    _jumpControllers = List.generate(
      _word.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    _jumpAnimations = _jumpControllers.map((controller) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: -widget.size * 0.3)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: -widget.size * 0.3, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ]).animate(controller);
    }).toList();

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      // Forward animation (turn green)
      for (int i = 0; i < _controllers.length; i++) {
        if (!mounted) return;
        _controllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 150));
      }

      await Future.delayed(Duration(seconds: widget.waitSeconds));

      // Jump animation before reversing
      for (int i = 0; i < _jumpControllers.length; i++) {
        if (!mounted) return;
        _jumpControllers[i].forward(from: 0.0);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Wait for the last jump to finish before turning white
      await Future.delayed(const Duration(milliseconds: 250));

      // Reverse animation (turn white)
      for (int i = 0; i < _controllers.length; i++) {
        if (!mounted) return;
        _controllers[i].reverse();
        await Future.delayed(const Duration(milliseconds: 150));
      }

      await Future.delayed(const Duration(milliseconds: 1500));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var controller in _jumpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_word.length, (index) {
        return AnimatedBuilder(
          animation: Listenable.merge([_animations[index], _jumpAnimations[index]]),
          builder: (context, child) {
            final value = _animations[index].value;
            final jumpY = _jumpAnimations[index].value;
            final isFlipped = value >= 0.5;
            final angle = value * math.pi;

            return Transform.translate(
              offset: Offset(0, jumpY),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002)
                  ..rotateX(angle),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  margin: EdgeInsets.symmetric(horizontal: widget.size * 0.06),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isFlipped
                        ? Colors.green.shade600
                        : widget.theme.emptyBoxColor,
                    border: Border.all(
                      color: isFlipped
                          ? Colors.green.shade600
                          : widget.theme.emptyBoxBorderColor,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: isFlipped ? Matrix4.rotationX(math.pi) : Matrix4.identity(),
                    child: Text(
                      _word[index],
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.bold,
                        color: isFlipped
                            ? Colors.white
                            : widget.theme.textColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
