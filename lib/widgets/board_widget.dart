import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wordle_provider.dart';
import 'letter_box.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool isShaking;

  const ShakeWidget({super.key, required this.child, required this.isShaking});

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isShaking && !oldWidget.isShaking) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WordleProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: provider.board
              .map(
                (word) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ShakeWidget(
                    isShaking: word.isShaking,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: word.letters
                          .asMap()
                          .entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: LetterBox(
                                letterModel: entry.value,
                                index: entry.key,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
