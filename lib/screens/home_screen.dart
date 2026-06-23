import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/wordle_provider.dart';
import '../widgets/settings_dialog.dart';
import 'profile_screen.dart';
import '../widgets/bouncing_button.dart';
import '../widgets/animated_logo.dart';
import '../widgets/floating_background.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isHardModeHovered = false;
  Timer? _rumbleTimer;
  Timer? _hoverDelayTimer;
  late final PageController _pageController;
  int _currentPageIndex = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  void _setHardModeHovered(bool isHovered) {
    if (isHovered) {
      _hoverDelayTimer?.cancel();
      _hoverDelayTimer = Timer(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        setState(() => _isHardModeHovered = true);
        
        // Start rumble
        _rumbleTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
          if (context.read<WordleProvider>().stats.hapticEnabled) {
            HapticFeedback.heavyImpact();
          }
        });
      });
    } else {
      _hoverDelayTimer?.cancel();
      if (_isHardModeHovered) {
        setState(() => _isHardModeHovered = false);
        _rumbleTimer?.cancel();
        _rumbleTimer = null;
      }
    }
  }

  @override
  void dispose() {
    _hoverDelayTimer?.cancel();
    _rumbleTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WordleProvider>(
      builder: (context, provider, child) {
        final theme = provider.currentTheme;
        final now = DateTime.now();
        final todayStr = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
        final hasPlayedDaily = provider.stats.lastDailyPlayedDate == todayStr;
        final isLight = ThemeData.estimateBrightnessForColor(theme.backgroundColor) == Brightness.light;

        return Scaffold(
          backgroundColor: theme.backgroundColor,
          body: Stack(
            children: [
              // 1. Dinamik Arka Plan (Shared across pages)
              Positioned.fill(
                child: FloatingBackground(
                  theme: theme,
                  isHardModeHovered: _currentPageIndex == 1 ? _isHardModeHovered : false,
                ),
              ),

              // Vignette (Tehlike Çerçevesi) - Sadece Home sayfasında
              IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _currentPageIndex == 1 && _isHardModeHovered ? 1.0 : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Colors.transparent,
                          Colors.red.shade900.withValues(alpha: 0.8),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
              
              // 2. Sayfalar (iOS Home Screen style swiping transition)
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                physics: const BouncingScrollPhysics(),
                children: [
                  const SettingsDialog(isEmbedded: true),
                  _buildHomeContent(context, provider, theme, hasPlayedDaily),
                  const ProfileScreen(isEmbedded: true),
                ],
              ),

              // 3. Ortak Premium Alt Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildCustomBottomBar(theme, isLight),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    WordleProvider provider,
    ThemePalette theme,
    bool hasPlayedDaily,
  ) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                // ATEŞ SERİSİ (Win Streak) - Sadece Klasik Mod
                if (provider.stats.classicStats.currentStreak > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                        const SizedBox(width: 4),
                        Text(
                          "${provider.stats.classicStats.currentStreak}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const Spacer(),
                
                // Animasyonlu Logo
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedLogo(theme: theme, waitSeconds: 10),
                      const SizedBox(width: 12),
                      Text(
                        "TR",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: theme.textColor,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Kelime Tahmin Oyunu",
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textColor.withAlpha(150),
                    letterSpacing: 1.5,
                  ),
                ),
                
                const Spacer(),

                // Günlük Bulmaca Butonu
                BouncingButton(
                  hasTexture: false,
                  height: 56, // Daha estetik/ince bir yükseklik
                  onPressed: () {
                    provider.lightImpact();
                    if (hasPlayedDaily) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Bugünkü bulmacayı zaten oynadın! (Klasik modda devam edebilirsin)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.orange.shade800,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                      return;
                    }

                    provider.resetGame(isDailyMode: true, isHardMode: false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  },
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        "GÜNLÜK",
                        style: TextStyle(
                          fontSize: 17, // 18'den 17'ye düşürüldü daha dengeli durması için
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                // Klasik Mod Butonu
                BouncingButton(
                  hasTexture: false,
                  height: 56,
                  onPressed: () {
                    provider.lightImpact();
                    provider.resetGame(isDailyMode: false, isHardMode: false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  },
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF90A4AE), Color(0xFF607D8B)], // Soluk/faded mavi-gri
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        "CLASSIC",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),

                // Zor Mod Butonu
                BouncingButton(
                  height: 56,
                  onHoverStateChanged: (isHovered) {
                    _setHardModeHovered(isHovered);
                  },
                  onPressed: () {
                    provider.lightImpact();
                    provider.resetGame(isDailyMode: false, isHardMode: true);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GameScreen()),
                    );
                  },
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade600, Colors.red.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      const Text(
                        "UZMAN",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2), // Extra space at bottom to account for the custom bottom bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomBottomBar(ThemePalette theme, bool isLight) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor.withAlpha(240),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: theme.dividerColor.withAlpha(80),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isLight ? 10 : 30),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / 3;
            return Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: Center(
                        child: _buildBottomBarItem(
                          icon: Icons.settings_outlined,
                          activeIcon: Icons.settings,
                          label: "Ayarlar",
                          isSelected: _currentPageIndex == 0,
                          theme: theme,
                          isLight: isLight,
                          onTap: () {
                            context.read<WordleProvider>().lightImpact();
                            _pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: Center(
                        child: _buildBottomBarItem(
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home,
                          label: "Ana Sayfa",
                          isSelected: _currentPageIndex == 1,
                          theme: theme,
                          isLight: isLight,
                          onTap: () {
                            context.read<WordleProvider>().lightImpact();
                            _pageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: Center(
                        child: _buildBottomBarItem(
                          icon: Icons.insert_chart,
                          activeIcon: Icons.insert_chart,
                          label: "İstatistikler",
                          isSelected: _currentPageIndex == 2,
                          theme: theme,
                          isLight: isLight,
                          onTap: () {
                            context.read<WordleProvider>().lightImpact();
                            _pageController.animateToPage(
                              2,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOutCubic,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required ThemePalette theme,
    required bool isLight,
    required VoidCallback onTap,
  }) {
    final activeColor = theme.textColor;
    final inactiveColor = theme.textColor.withAlpha(120);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withAlpha(isLight ? 15 : 25) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? activeColor : inactiveColor,
                size: isSelected ? 26 : 24,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerLeft,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: activeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

}
