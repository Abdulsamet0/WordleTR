import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wordle_provider.dart';

import '../theme/app_theme.dart';

class SettingsDialog extends StatelessWidget {
  final bool isEmbedded;
  const SettingsDialog({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<WordleProvider>(
      builder: (context, provider, child) {
        final theme = provider.currentTheme;
        final isLight = ThemeData.estimateBrightnessForColor(theme.backgroundColor) == Brightness.light;
        
        final content = Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: isEmbedded ? 40.0 : 24.0,
            bottom: isEmbedded ? 100.0 : 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEmbedded)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Ayarlar",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.iconColor),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    "Ayarlar",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: theme.textColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Titreşim",
                    style: TextStyle(color: theme.textColor, fontSize: 18),
                  ),
                  Switch(
                    value: provider.stats.hapticEnabled,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.green.shade600,
                    inactiveThumbColor: isLight ? Colors.grey.shade400 : Colors.grey.shade300,
                    inactiveTrackColor: isLight ? Colors.grey.shade300 : Colors.grey.shade700,
                    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    onChanged: (val) {
                      provider.toggleHaptic();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ses Efektleri",
                    style: TextStyle(color: theme.textColor, fontSize: 18),
                  ),
                  Switch(
                    value: provider.stats.soundEnabled,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.green.shade600,
                    inactiveThumbColor: isLight ? Colors.grey.shade400 : Colors.grey.shade300,
                    inactiveTrackColor: isLight ? Colors.grey.shade300 : Colors.grey.shade700,
                    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    onChanged: (val) {
                      provider.toggleSound();
                    },
                  ),
                ],
              ),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 8),
              Text(
                "Tema",
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) => _buildThemeItem(index, provider, theme)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) => _buildThemeItem(index + 3, provider, theme)),
                  ),
                ],
              ),
            ],
          ),
        );

        if (isEmbedded) {
          return SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: content,
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Material(
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(32)),
            color: theme.dialogBackgroundColor,
            elevation: 8,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: content,
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeItem(int index, WordleProvider provider, ThemePalette theme) {
    final isSelected = provider.currentThemeIndex == index;
    final targetTheme = ThemePalette.getTheme(index);

    return GestureDetector(
      onTap: () => provider.setTheme(index),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: targetTheme.backgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected 
                    ? Colors.green.shade600 
                    : theme.emptyBoxBorderColor,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.green.shade600.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(Icons.check, color: targetTheme.textColor, size: 28)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            ThemePalette.getThemeName(index),
            style: TextStyle(
              color: isSelected
                  ? theme.textColor
                  : theme.textColor.withValues(alpha: 0.6),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
