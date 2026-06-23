import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wordle_provider.dart';
import '../theme/app_theme.dart';
import '../models/letter_model.dart';
import 'letter_box.dart';

class TutorialDialog extends StatefulWidget {
  const TutorialDialog({super.key});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  int _step = 0;
  Timer? _timer;

  final String _word = "KALEM";

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) return;
      setState(() {
        _step++;
        if (_step > 8) {
          _step = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildLegendItem(Color color, String label, ThemePalette theme) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: theme.textColor, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordleProvider>(
      builder: (context, provider, child) {
        final theme = provider.currentTheme;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Material(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(32)),
            color: theme.dialogBackgroundColor,
            elevation: 8,
            child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Nasıl Oynanır",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.textColor),
                ),
                const SizedBox(height: 12),
                Text(
                  "Hedef kelimeyi 6 denemede bul.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.textColor.withAlpha(200), fontSize: 15),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    String letter = "";
                    LetterState state = LetterState.initial;

                    if (_step > index) {
                      letter = _word[index];
                    }
                    if (_step > 5) {
                      if (index == 0) {
                        state = LetterState.correct;
                      } else if (index == 1) {
                        state = LetterState.present;
                      } else {
                        state = LetterState.absent;
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: LetterBox(
                        index: index,
                        letterModel: LetterModel(letter: letter, state: state),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(Colors.green.shade600, "Doğru", theme),
                    _buildLegendItem(Colors.amber.shade600, "Yanlış Konum", theme),
                    _buildLegendItem(theme.emptyBoxBorderColor, "Yok", theme),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    minimumSize: const Size(double.infinity, 44),
                    shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("BAŞLA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }
}
