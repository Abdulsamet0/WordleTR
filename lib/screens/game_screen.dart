import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/wordle_provider.dart';
import '../theme/app_theme.dart';
import '../utils/dynamic_island_dialog.dart';
import '../widgets/board_widget.dart';
import '../widgets/keyboard_widget.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/tutorial_dialog.dart';
import '../widgets/animated_logo.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameStatus _lastStatus = GameStatus.playing;
  late WordleProvider _provider;
  final FocusNode _focusNode = FocusNode();
  bool _isThemeSelectorOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider = context.read<WordleProvider>();
      _provider.addListener(_onGameStatusChanged);

      if (!_provider.stats.hasSeenTutorial) {
        _showTutorial();
      }
    });
  }

  void _showTutorial() {
    _provider.pauseTimer();
    showDynamicIslandDialog(context: context, builder: (_) => const TutorialDialog()).then((
      _,
    ) {
      _provider.markTutorialSeen();
      _provider.resumeTimer();
    });
  }

  void _showPauseMenu() {
    if (_provider.gameStatus != GameStatus.playing) return;
    _provider.pauseTimer();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withAlpha(120),
      builder: (context) {
        final theme = _provider.currentTheme;
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: AlertDialog(
            backgroundColor: theme.dialogBackgroundColor.withAlpha(235),
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: theme.dividerColor.withAlpha(100),
                width: 1.5,
              ),
            ),
            title: Text(
              "OYUN DURAKLATILDI",
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _provider.resumeTimer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("OYUNA DEVAM ET", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to Home
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("ANA MENÜYE DÖN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (_provider.stats.dailyMode)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Dikkat: Günlük moddan çıkarsanız\nbu kelimeyi tekrar oynayamazsınız.",
                      style: TextStyle(
                        color: theme.textColor.withAlpha(150),
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onGameStatusChanged() {
    if (_provider.gameStatus != GameStatus.playing &&
        _lastStatus == GameStatus.playing) {
      // Game just finished
      Future.delayed(const Duration(milliseconds: 2800), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => const GameOverDialog(),
          );
        }
      });
    }
    _lastStatus = _provider.gameStatus;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _provider.removeListener(_onGameStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordleProvider>(
      builder: (context, provider, child) {
        final theme = provider.currentTheme;
        final isLight = ThemeData.estimateBrightnessForColor(theme.backgroundColor) == Brightness.light;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (provider.gameStatus == GameStatus.playing) {
              _showPauseMenu();
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Focus(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (FocusNode node, KeyEvent event) {
              if (event is KeyDownEvent) {
                final key = event.logicalKey;
                if (key == LogicalKeyboardKey.enter) {
                  provider.onKeyTapped("ENTER");
                  return KeyEventResult.handled;
                } else if (key == LogicalKeyboardKey.backspace) {
                  provider.onKeyTapped("BACK");
                  return KeyEventResult.handled;
                } else {
                  final char = event.character?.toUpperCase();
                  if (char != null && "ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ".contains(char)) {
                    provider.onKeyTapped(char);
                    return KeyEventResult.handled;
                  }
                }
              }
              return KeyEventResult.ignored;
            },
            child: Scaffold(
              backgroundColor: theme.backgroundColor,
          appBar: AppBar(
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedLogo(theme: theme, size: 24, fontSize: 14),
                  const SizedBox(width: 8),
                  Text(
                    "TR",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: theme.textColor,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      provider.formattedTime,
                      style: TextStyle(
                        color: theme.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      _isThemeSelectorOpen ? Icons.color_lens : Icons.color_lens_outlined,
                      color: theme.iconColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _isThemeSelectorOpen = !_isThemeSelectorOpen;
                      });
                    },
                  ),
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      provider.gameStatus == GameStatus.playing ? Icons.pause : Icons.home,
                      color: theme.iconColor,
                    ),
                    onPressed: () {
                      if (provider.gameStatus == GameStatus.playing) {
                        _showPauseMenu();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ],
          ),
          body: Stack(
            children: [
              // Hard Mode Watermark (Fire)
              if (provider.isHardMode)
                Positioned.fill(
                  child: Center(
                    child: Opacity(
                      opacity: 0.03,
                      child: Icon(
                        Icons.local_fire_department,
                        size: 400,
                        color: theme.textColor,
                      ),
                    ),
                  ),
                ),
              Column(
                children: [
                  Divider(color: theme.dividerColor, thickness: 1),

                  // Message Box
                  Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: provider.message.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.textColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              provider.message,
                              style: TextStyle(
                                color: theme.backgroundColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Game Board
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: const FittedBox(
                          fit: BoxFit.contain,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: BoardWidget(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Keyboard
                  TweenAnimationBuilder<Offset>(
                    tween: Tween<Offset>(begin: const Offset(0, 400), end: Offset.zero),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, offset, child) {
                      return Transform.translate(
                        offset: offset,
                        child: child,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.bottomCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 24.0, left: 8.0, right: 8.0),
                          child: KeyboardWidget(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Dinamik Ada Tema Seçici
              _buildDynamicIslandThemeSelector(provider, theme, isLight),
            ],
          ),
        ),
      ),
    );
  },
);
  }

  Widget _buildDynamicIslandThemeSelector(WordleProvider provider, ThemePalette theme, bool isLight) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      top: _isThemeSelectorOpen ? 8 : -80,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isThemeSelectorOpen ? 1.0 : 0.0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: isLight ? Colors.white.withAlpha(235) : theme.dialogBackgroundColor.withAlpha(235),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.dividerColor.withAlpha(80),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isLight ? 10 : 30),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(6, (index) {
                  final isSelected = provider.currentThemeIndex == index;
                  
                  Color dotColor;
                  Color dotBorderColor;
                  switch (index) {
                    case 0:
                      dotColor = Colors.white;
                      dotBorderColor = Colors.grey.shade400;
                      break;
                    case 1:
                      dotColor = const Color(0xFF121213);
                      dotBorderColor = Colors.grey.shade700;
                      break;
                    case 2:
                      dotColor = const Color(0xFF0F172A);
                      dotBorderColor = const Color(0xFF334155);
                      break;
                    case 3:
                      dotColor = const Color(0xFFFDF6E3);
                      dotBorderColor = const Color(0xFFE6DBC8);
                      break;
                    case 4:
                      dotColor = const Color(0xFFF0FFF4);
                      dotBorderColor = const Color(0xFF9AE6B4);
                      break;
                    case 5:
                      dotColor = const Color(0xFFFFF5F5);
                      dotBorderColor = const Color(0xFFFEB2B2);
                      break;
                    default:
                      dotColor = Colors.white;
                      dotBorderColor = Colors.grey;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: GestureDetector(
                      onTap: () {
                        provider.setTheme(index);
                        if (provider.stats.hapticEnabled) {
                          HapticFeedback.lightImpact();
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected 
                                ? (index == 0 || index == 3 || index == 4 || index == 5 ? Colors.blue.shade600 : Colors.white) 
                                : dotBorderColor,
                            width: isSelected ? 3 : 1.5,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Colors.blue.withAlpha(100),
                              blurRadius: 6,
                              spreadRadius: 2,
                            )
                          ] : null,
                        ),
                        child: isSelected ? Icon(
                          Icons.check,
                          color: index == 0 || index == 3 || index == 4 || index == 5 ? Colors.blue.shade600 : Colors.white,
                          size: 20,
                        ) : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
