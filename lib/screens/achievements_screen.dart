import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/wordle_provider.dart';
import '../models/achievement_model.dart';

import '../widgets/texture_pattern.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WordleProvider>();
    final theme = provider.currentTheme;
    final stats = provider.stats;

    final achievements = AchievementsList.all;
    int unlockedCount = achievements.where((a) => a.condition(stats)).length;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "BAŞARIMLAR",
          style: TextStyle(
            color: theme.textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Kazanılan",
                  style: TextStyle(
                    fontSize: 18,
                    color: theme.textColor.withAlpha(200),
                  ),
                ),
                Text(
                  "$unlockedCount / ${achievements.length}",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textColor,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.70,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final isUnlocked = achievement.condition(stats);

                return Material(
                  color: Colors.transparent,
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(42),
                    side: BorderSide(
                      color: isUnlocked 
                          ? achievement.color.withAlpha(100) 
                          : theme.dividerColor.withAlpha(50),
                      width: isUnlocked ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isUnlocked 
                          ? theme.dialogBackgroundColor 
                          : theme.dialogBackgroundColor.withAlpha(100),
                      boxShadow: isUnlocked ? [
                        BoxShadow(
                          color: achievement.color.withAlpha(20),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ] : [],
                    ),
                    child: TexturePattern(
                      color: theme.textColor,
                      opacity: isUnlocked ? 0.05 : 0.02,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isUnlocked 
                              ? achievement.color.withAlpha(30) 
                              : Colors.grey.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isUnlocked ? achievement.icon : Icons.lock,
                          color: isUnlocked ? achievement.color : Colors.grey,
                          size: 26,
                        ),
                      ),
                      
                      // Title & Description
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              achievement.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isUnlocked ? theme.textColor : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              achievement.description,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isUnlocked ? theme.textColor.withAlpha(180) : Colors.grey.withAlpha(150),
                                fontSize: 10,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Progress Bar
                      if (!isUnlocked)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: achievement.progress(stats),
                              backgroundColor: theme.dividerColor.withAlpha(50),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                achievement.color.withAlpha(150),
                              ),
                              minHeight: 4,
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
            ),
          ),
        ],
      ),
    );
  }
}
