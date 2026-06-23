class LevelSystem {
  static const int maxTimeBonusSeconds = 300;
  static const int baseMultiplierNormal = 500;
  static const int baseMultiplierHard = 750;
  static const int timeBonusPerSecond = 2;
  static const int streakBonusMultiplier = 100;

  // Skor hesaplama fonksiyonu
  static Map<String, int> calculateScoreDetails(int attempts, int timeSeconds, int streak, {required bool isHardMode}) {
    int maxAttempts = 6;
    int baseMultiplier = isHardMode ? baseMultiplierHard : baseMultiplierNormal;
    
    // Temel Puan
    int baseScore = (maxAttempts - attempts + 1) * baseMultiplier;
    
    // Zaman Bonusu
    int timeBonus = 0;
    if (timeSeconds < maxTimeBonusSeconds) {
      timeBonus = (maxTimeBonusSeconds - timeSeconds) * timeBonusPerSecond;
    }
    
    // Seri Bonusu
    int streakBonus = streak * streakBonusMultiplier;
    
    int total = baseScore + timeBonus + streakBonus;
    
    return {
      'base': baseScore,
      'time': timeBonus,
      'streak': streakBonus,
      'total': total,
    };
  }

  // Seviye eşikleri
  static final List<int> levelMilestones = [
    0,         // Çaylak
    10000,     // Çırak
    50000,     // Kalfa
    150000,    // Usta
    500000     // Kelime Büyücüsü
  ];

  static final List<String> levelTitles = [
    "Çaylak",
    "Çırak",
    "Kalfa",
    "Usta",
    "Kelime Büyücüsü"
  ];

  // Avatarlar ve kilit açılma puanları (Level Milestones ile eşleşiyor)
  static final Map<int, List<String>> _levelAvatars = {
    0: ["🥚", "🌱", "🐛"], // Çaylak (0+)
    10000: ["🐣", "🌿", "🦋"], // Çırak (10K+)
    50000: ["🐥", "🪴", "🦜"], // Kalfa (50K+)
    150000: ["🦅", "🌳", "🐅"], // Usta (150K+)
    500000: ["🐉", "🪄", "🌟"], // Büyücü (500K+)
  };

  static String getTitleForScore(int score) {
    for (int i = levelMilestones.length - 1; i >= 0; i--) {
      if (score >= levelMilestones[i]) {
        return levelTitles[i];
      }
    }
    return levelTitles[0];
  }

  static int getLevelIndexForScore(int score) {
    for (int i = levelMilestones.length - 1; i >= 0; i--) {
      if (score >= levelMilestones[i]) {
        return i;
      }
    }
    return 0;
  }

  // Geriye açılan yüzdelik durumu veya sonraki seviyeye kalan puanı bulmak için
  static double getProgressToNextLevel(int score) {
    int currentIndex = getLevelIndexForScore(score);
    if (currentIndex == levelMilestones.length - 1) return 1.0; // Maksimum seviye

    int currentThreshold = levelMilestones[currentIndex];
    int nextThreshold = levelMilestones[currentIndex + 1];
    
    return (score - currentThreshold) / (nextThreshold - currentThreshold);
  }

  static int getScoreNeededForNextLevel(int score) {
    int currentIndex = getLevelIndexForScore(score);
    if (currentIndex == levelMilestones.length - 1) return 0; // Zaten sonda
    
    return levelMilestones[currentIndex + 1] - score;
  }

  static List<String> getUnlockedAvatars(int score) {
    List<String> unlocked = [];
    _levelAvatars.forEach((threshold, avatars) {
      if (score >= threshold) {
        unlocked.addAll(avatars);
      }
    });
    return unlocked;
  }

  static List<Map<String, dynamic>> getAllAvatarsWithLockStatus(int score) {
    List<Map<String, dynamic>> result = [];
    _levelAvatars.forEach((threshold, avatars) {
      bool isUnlocked = score >= threshold;
      for (var avatar in avatars) {
        result.add({
          'avatar': avatar,
          'isUnlocked': isUnlocked,
          'requiredScore': threshold
        });
      }
    });
    return result;
  }
}
