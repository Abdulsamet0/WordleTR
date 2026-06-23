import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/wordle_provider.dart';
import '../models/stats_model.dart';
import '../widgets/texture_pattern.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_background.dart';
import '../models/level_system.dart';
import 'achievements_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isEmbedded;
  const ProfileScreen({super.key, this.isEmbedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1); // Varsayılan Klasik
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    if (seconds == 0) return "--:--";
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color _getAccentColor(ThemePalette theme) {
    // Her sekme için her temada okunabilir güçlü vurgu renkleri kullanıyoruz.
    switch (_tabController.index) {
      case 0:
        return Colors.green.shade600;
      case 1:
        return const Color(0xFF0088CC); // Her temada net görünen güçlü mavi
      case 2:
        return Colors.red.shade600;
      default:
        return const Color(0xFF0088CC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordleProvider>();
    final theme = provider.currentTheme;
    final stats = provider.stats;

    final isLight = ThemeData.estimateBrightnessForColor(theme.backgroundColor) == Brightness.light;
    final pageBgColor = widget.isEmbedded 
        ? Colors.transparent 
        : theme.backgroundColor; // Ana tema arkaplanı ile eşlendi
    final accentColor = _getAccentColor(theme);

    return Scaffold(
      backgroundColor: pageBgColor,
      body: Stack(
        children: [
          // 1. Dinamik Yüzen Harf Arka Planı (Sade ve sakin modda) - Sadece bağımsız çalışırken göster
          if (!widget.isEmbedded)
            Positioned.fill(
              child: FloatingBackground(
                theme: theme,
                isHardModeHovered: false,
              ),
            ),

          // 2. Ana İçerik Katmanı
          NestedScrollView(
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverSafeArea(
                  bottom: false,
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.topCenter,
                  children: [
                    // Geri butonu (Sol üst)
                    if (!widget.isEmbedded)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, color: theme.textColor),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    
                    // Kupa Butonu (Sağ üst)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            provider.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AchievementsScreen()),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.dialogBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accentColor.withAlpha(isLight ? 30 : 60),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(isLight ? 8 : 25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.emoji_events,
                              color: Colors.amber.shade700,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Seviye ve Puan
                    Column(
                      children: [
                        SizedBox(height: widget.isEmbedded ? 16 : 24),
                        Text(
                          LevelSystem.getTitleForScore(provider.stats.totalScore),
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // XP Bar
                        SizedBox(
                          width: 220,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 10,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: theme.textColor.withAlpha(30),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: LevelSystem.getProgressToNextLevel(provider.stats.totalScore),
                                    child: Container(
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Toplam Puan: ${provider.stats.totalScore}",
                                style: TextStyle(
                                  color: theme.textColor.withAlpha(150),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Sürgülü Yay Efektli Özel Sekme Seçici
                GameTabSelector(
                  tabController: _tabController,
                  theme: theme,
                  activeColor: accentColor,
                ),
                
                const SizedBox(height: 20),
                
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildStatsContent(stats.dailyStats, theme, accentColor, isLight),
                _buildStatsContent(stats.classicStats, theme, accentColor, isLight),
                _buildStatsContent(stats.hardStats, theme, accentColor, isLight),
              ],
            ),
          ),
        ],
      ),
      
      // Premium Havada Asılı Alt Navigasyon Barı
      bottomNavigationBar: widget.isEmbedded ? null : _buildCustomBottomBar(theme, isLight),
    );
  }


  Widget _buildStatsContent(ModeStats modeStats, ThemePalette theme, Color accentColor, bool isLight) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        24.0,
        8.0,
        24.0,
        widget.isEmbedded ? 100.0 : 24.0, // Alt barın altından kayabilmesi için ekstra boşluk
      ),
      children: [
        // 2x2 Kompakt İstatistik Izgarası (GridView)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildCompactStatCard(
              icon: Icons.emoji_events,
              title: "Kazanılan",
              numericValue: modeStats.wins.toDouble(),
              formatter: (val) => val.toInt().toString(),
              theme: theme,
              accentColor: accentColor,
              isLight: isLight,
            ),
            _buildCompactStatCard(
              icon: Icons.local_fire_department,
              title: "En Yüksek Seri",
              numericValue: modeStats.maxStreak.toDouble(),
              formatter: (val) => val.toInt().toString(),
              theme: theme,
              accentColor: accentColor,
              isLight: isLight,
            ),
            _buildCompactStatCard(
              icon: Icons.timer,
              title: "En İyi Süre",
              numericValue: modeStats.bestTimeSeconds.toDouble(),
              formatter: (val) => _formatTime(val.toInt()),
              theme: theme,
              accentColor: accentColor,
              isLight: isLight,
            ),
            _buildCompactStatCard(
              icon: Icons.pie_chart,
              title: "Başarı Oranı",
              numericValue: modeStats.winPercentage.toDouble(),
              formatter: (val) => "%${val.toStringAsFixed(0)}",
              theme: theme,
              accentColor: accentColor,
              isLight: isLight,
            ),
          ],
        ),
        
        // Tahmin Dağılımı
        const SizedBox(height: 32),
        Text(
          "Tahmin Dağılımı",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        _buildGuessDistribution(modeStats.guessDistribution, theme, accentColor),
      ],
    );
  }

  Widget _buildCompactStatCard({
    required IconData icon,
    required String title,
    required double numericValue,
    required String Function(double) formatter,
    required ThemePalette theme,
    required Color accentColor,
    required bool isLight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withAlpha(isLight ? 30 : 60), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isLight ? 5 : 15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accentColor, size: 28),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: numericValue),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return Text(
                formatter(val),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: theme.textColor.withAlpha(150),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }



  Widget _buildGuessDistribution(List<int> distribution, ThemePalette theme, Color accentColor) {
    return DelayedGuessDistributionChart(
      distribution: distribution,
      theme: theme,
      accentColor: accentColor,
    );
  }

  Widget _buildCustomBottomBar(ThemePalette theme, bool isLight) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor.withAlpha(225),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: theme.dividerColor.withAlpha(80),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isLight ? 8 : 25),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomBarItem(
              icon: Icons.home,
              label: "Ana Sayfa",
              isSelected: false,
              theme: theme,
              onTap: () {
                context.read<WordleProvider>().lightImpact();
                Navigator.of(context).pop();
              },
            ),
            _buildBottomBarItem(
              icon: Icons.insert_chart,
              label: "İstatistikler",
              isSelected: true,
              theme: theme,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required ThemePalette theme,
    required VoidCallback onTap,
  }) {
    final isLight = ThemeData.estimateBrightnessForColor(theme.backgroundColor) == Brightness.light;
    final activeColor = _getAccentColor(theme);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? activeColor.withAlpha(isLight ? 25 : 45) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : theme.textColor.withAlpha(120),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 3. Sürgülü Yay Efektli Özel Sekme Seçici Bileşeni
class GameTabSelector extends StatelessWidget {
  final TabController tabController;
  final ThemePalette theme;
  final Color activeColor;

  const GameTabSelector({
    super.key,
    required this.tabController,
    required this.theme,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeData.estimateBrightnessForColor(theme.backgroundColor) == Brightness.light;
    final barBgColor = theme.dialogBackgroundColor.withAlpha(isLight ? 200 : 150);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 48,
      decoration: BoxDecoration(
        color: barBgColor,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: theme.dividerColor.withAlpha(50),
          width: 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 8) / 3;
          final activeIndex = tabController.index;

          return Stack(
            children: [
              // Sürgülü Yaylı Arka Plan Seçim Katmanı
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                left: 4 + (activeIndex * tabWidth),
                top: 4,
                bottom: 4,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isLight ? 10 : 20),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Buton Yazıları
              Row(
                children: [
                  _buildTabButton(context, "Günlük", 0, activeIndex),
                  _buildTabButton(context, "Classic", 1, activeIndex),
                  _buildTabButton(context, "Uzman", 2, activeIndex),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String text, int index, int activeIndex) {
    final isSelected = activeIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          context.read<WordleProvider>().lightImpact();
          tabController.animateTo(index);
        },
        child: Container(
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected 
                  ? activeColor 
                  : theme.textColor.withAlpha(120),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontSize: 14,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}

// 4. Hafifçe Büyüyüp Küçülen Pulsing Rozet Bileşeni
class PulsingBadge extends StatefulWidget {
  final Widget child;
  const PulsingBadge({super.key, required this.child});

  @override
  State<PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<PulsingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.08).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
    ]).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

class DelayedStatTicker extends StatefulWidget {
  final int value;
  final TextStyle style;
  const DelayedStatTicker({super.key, required this.value, required this.style});
  @override
  State<DelayedStatTicker> createState() => _DelayedStatTickerState();
}

class _DelayedStatTickerState extends State<DelayedStatTicker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _animation = IntTween(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _controller.forward();
    });
  }
  @override
  void didUpdateWidget(covariant DelayedStatTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = IntTween(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic)
      );
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
      animation: _animation,
      builder: (context, child) => Text("${_animation.value}", style: widget.style),
    );
  }
}

class DelayedGuessDistributionChart extends StatefulWidget {
  final List<int> distribution;
  final ThemePalette theme;
  final Color accentColor;
  const DelayedGuessDistributionChart({super.key, required this.distribution, required this.theme, required this.accentColor});
  @override
  State<DelayedGuessDistributionChart> createState() => _DelayedGuessDistributionChartState();
}

class _DelayedGuessDistributionChartState extends State<DelayedGuessDistributionChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant DelayedGuessDistributionChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.distribution != widget.distribution) {
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
    int maxVal = 1;
    for (int v in widget.distribution) {
      if (v > maxVal) maxVal = v;
    }
    return Column(
      children: List.generate(widget.distribution.length, (index) {
        final count = widget.distribution[index];
        final fraction = count / maxVal;
        final targetFraction = fraction > 0 ? fraction : 0.05;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: Text(
                  "${index + 1}",
                  style: TextStyle(fontWeight: FontWeight.bold, color: widget.theme.textColor),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: widget.theme.textColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          widthFactor: _animation.value * targetFraction,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: count > 0 ? widget.accentColor : widget.theme.textColor.withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              "$count",
                              style: TextStyle(
                                color: count > 0 ? Colors.white : widget.theme.textColor.withAlpha(200),
                                fontWeight: FontWeight.bold, 
                                fontSize: 12
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class DelayedWinRateGauge extends StatefulWidget {
  final int percentage;
  final ThemePalette theme;
  final Color accentColor;
  const DelayedWinRateGauge({super.key, required this.percentage, required this.theme, required this.accentColor});
  @override
  State<DelayedWinRateGauge> createState() => _DelayedWinRateGaugeState();
}

class _DelayedWinRateGaugeState extends State<DelayedWinRateGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentPercent = (_animation.value * widget.percentage).round();
        return SizedBox(
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: _animation.value * (widget.percentage / 100),
                  strokeWidth: 12,
                  backgroundColor: widget.theme.textColor.withAlpha(20),
                  color: widget.accentColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "%$currentPercent",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.textColor,
                    ),
                  ),
                  Text(
                    "Kazanma",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: widget.theme.textColor.withAlpha(150),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class BreathingStatsCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? value;
  final int? numericValue;
  final ThemePalette theme;
  final Color accentColor;
  final Widget? badge;

  const BreathingStatsCard({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.numericValue,
    required this.theme,
    required this.accentColor,
    this.badge,
  });

  @override
  State<BreathingStatsCard> createState() => _BreathingStatsCardState();
}

class _BreathingStatsCardState extends State<BreathingStatsCard> with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _breathingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeData.estimateBrightnessForColor(widget.theme.backgroundColor) == Brightness.light;
    final cardBgColor = isLight ? Colors.white : widget.theme.dialogBackgroundColor;

    return AnimatedBuilder(
      animation: _breathingController,
      builder: (context, child) {
        // Breathing effect
        final breath = _breathingController.value;
        final dynamicAlpha = isLight ? 20 + (20 * breath).toInt() : 40 + (40 * breath).toInt();
        final borderColor = widget.accentColor.withAlpha(dynamicAlpha);

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: cardBgColor,
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isLight ? 6 : 20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TexturePattern(
              color: widget.theme.textColor,
              opacity: isLight ? 0.03 : 0.02,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.accentColor.withAlpha(isLight ? 20 : 40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.accentColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.textColor,
                    ),
                  ),
                  const Spacer(),
                  if (widget.badge != null) PulsingBadge(child: widget.badge!),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomRight,
                child: widget.numericValue != null
                    ? DelayedStatTicker(
                        value: widget.numericValue!,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.textColor,
                        ),
                      )
                    : Text(
                        widget.value ?? "",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.textColor,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
},
    );
  }
}
