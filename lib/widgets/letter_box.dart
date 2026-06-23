import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/letter_model.dart';
import '../providers/wordle_provider.dart';
import '../theme/app_theme.dart';

class LetterBox extends StatefulWidget {
  final LetterModel letterModel;
  final int index;

  const LetterBox({super.key, required this.letterModel, required this.index});

  @override
  State<LetterBox> createState() => _LetterBoxState();
}

class _LetterBoxState extends State<LetterBox> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  LetterState _previousState = LetterState.initial;
  String _previousLetter = "";

  @override
  void initState() {
    super.initState();

    // Flip Animation (Color reveal)
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    // Bounce Animation (Typing letter)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 1),
    ]).animate(_bounceController);

    // Wave Animation (Winning celebration)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _waveAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -20.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -20.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _waveController, curve: Curves.easeInOut));


    _previousState = widget.letterModel.state;
    _previousLetter = widget.letterModel.letter;
  }

  @override
  void didUpdateWidget(LetterBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reset animations if game is restarted
    if (widget.letterModel.state == LetterState.initial &&
        _previousState != LetterState.initial) {
      _flipController.reset();
      _bounceController.reset();
    }

    // Trigger Bounce if letter was added
    if (widget.letterModel.letter.isNotEmpty && _previousLetter.isEmpty) {
      _bounceController.forward(from: 0);
    }

    // Trigger Flip if state changed to evaluated
    if (widget.letterModel.state != LetterState.initial &&
        _previousState == LetterState.initial) {
      Future.delayed(Duration(milliseconds: widget.index * 300), () {
        if (mounted) {
          _flipController.forward().then((_) {
            final provider = Provider.of<WordleProvider>(context, listen: false);
            if (provider.gameStatus == GameStatus.won && widget.letterModel.state == LetterState.correct) {
              int delay = 1200 - widget.index * 200;
              if (delay < 0) delay = 0;
              Future.delayed(Duration(milliseconds: delay), () {
                if (mounted) _waveController.forward();
              });
            }
          });
        }
      });
    }

    _previousState = widget.letterModel.state;
    _previousLetter = widget.letterModel.letter;
  }

  @override
  void dispose() {
    _flipController.dispose();
    _bounceController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(LetterState state, ThemePalette theme) {
    switch (state) {
      case LetterState.initial:
        return theme.emptyBoxColor;
      case LetterState.absent:
        return theme.dialogBackgroundColor;
      case LetterState.present:
        return Colors.amber.shade600;
      case LetterState.correct:
        return Colors.green.shade600;
    }
  }

  Color _getBorderColor(LetterState state, String letter, ThemePalette theme) {
    if (state == LetterState.initial) {
      return letter.isNotEmpty ? theme.textColor : theme.emptyBoxBorderColor;
    }
    return Colors.transparent;
  }

  Color _getTextColor(LetterState state, ThemePalette theme) {
    if (state == LetterState.initial || state == LetterState.absent) {
      return theme.textColor;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<WordleProvider>().currentTheme;

    return AnimatedBuilder(
      animation: Listenable.merge([_flipController, _bounceController, _waveController]),
      builder: (context, child) {
        // Evaluate the flip progress
        double flipValue = _flipAnimation.value;
        bool isFlippedHalfway = flipValue >= 0.5;

        // Determine which colors to show based on flip halfway point
        LetterState displayState = isFlippedHalfway
            ? widget.letterModel.state
            : LetterState.initial;

        // Transform value for 3D flip effect
        // 0.0 -> 0 degrees
        // 1.0 -> 180 degrees (pi)
        double angle = flipValue * pi;

        // When halfway, flip the content back so it's not mirrored
        if (isFlippedHalfway) {
          angle -= pi; // Flip back to 0 degrees logically for text
        }

        Matrix4 transform = Matrix4.identity()
          ..setEntry(3, 2, 0.002) // Perspective
          ..rotateX(angle); // Rotate around X axis for up-down flip

        return Transform.translate(
          offset: Offset(0, _waveAnimation.value),
          child: Transform.scale(
            scale: _bounceAnimation.value,
            child: Transform(
              alignment: Alignment.center,
            transform: transform,
            child: Container(
              width: 55,
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _getBackgroundColor(displayState, theme),
                border: Border.all(
                  color: _getBorderColor(
                    displayState,
                    widget.letterModel.letter,
                    theme,
                  ),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.letterModel.letter,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(displayState, theme),
                ),
              ),
              ),
            ),
          ),
        );
      },
    );
  }
}
