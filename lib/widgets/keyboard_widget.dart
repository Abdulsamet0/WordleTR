import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/letter_model.dart';
import '../providers/wordle_provider.dart';
import '../theme/app_theme.dart';
import 'bouncing_button.dart';

class KeyboardWidget extends StatelessWidget {
  const KeyboardWidget({super.key});

  final List<List<String>> keys = const [
    ["E", "R", "T", "Y", "U", "I", "O", "P", "Ğ", "Ü"],
    ["A", "S", "D", "F", "G", "H", "J", "K", "L", "Ş", "İ"],
    ["ENTER", "Z", "C", "V", "B", "N", "M", "Ö", "Ç", "BACK"],
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<WordleProvider>(
      builder: (context, provider, child) {
        return FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: Column(
            children: keys.map((row) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((key) {
                    return KeyboardKey(
                      letter: key,
                      state:
                          provider.keyboardLetterStates[key] ??
                          LetterState.initial,
                      theme: provider.currentTheme,
                      onTap: () => provider.onKeyTapped(key),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class KeyboardKey extends StatelessWidget {
  final String letter;
  final LetterState state;
  final VoidCallback onTap;
  final ThemePalette theme;

  const KeyboardKey({
    super.key,
    required this.letter,
    required this.state,
    required this.onTap,
    required this.theme,
  });

  Color _getBackgroundColor() {
    switch (state) {
      case LetterState.initial:
        if (letter == "ENTER" || letter == "BACK") {
          return theme.textColor.withAlpha(20);
        }
        return theme.keyColor;
      case LetterState.absent:
        return theme.absentKeyColor;
      case LetterState.present:
        return Colors.amber.shade600;
      case LetterState.correct:
        return Colors.green.shade600;
    }
  }

  Color _getShadowColor() {
    switch (state) {
      case LetterState.initial:
        return theme.textColor.withValues(alpha: 0.2);
      case LetterState.absent:
        return theme.textColor.withValues(alpha: 0.3);
      case LetterState.present:
        return Colors.amber.shade800;
      case LetterState.correct:
        return Colors.green.shade800;
    }
  }

  Color _getTextColor() {
    if (state == LetterState.initial) {
      return theme.textColor;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    double width;
    final textColor = _getTextColor();

    if (letter == "ENTER") {
      child = Text(
        "GİR",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      );
      width = 50;
    } else if (letter == "BACK") {
      child = Icon(Icons.backspace, size: 20, color: textColor);
      width = 50;
    } else {
      child = Text(
        letter,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      );
      width = 30;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: BouncingButton(
        onPressed: onTap,
        hasTexture: false,
        width: width,
        height: 48,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: _getShadowColor(),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
