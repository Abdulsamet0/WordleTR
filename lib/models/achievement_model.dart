import 'package:flutter/material.dart';
import 'stats_model.dart';
import 'dart:math';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool Function(StatsModel stats) condition;
  final double Function(StatsModel stats) progress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.condition,
    required this.progress,
  });
}

class AchievementsList {
  static List<Achievement> get all => [
    // WINS (7)
    Achievement(
      id: 'win_1', title: 'İlk Kan', description: '1 Galibiyet', icon: Icons.sports_martial_arts, color: Colors.brown,
      condition: (s) => (s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) >= 1,
      progress: (s) => ((s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) / 1).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'win_10', title: 'Çaylak', description: '10 Galibiyet', icon: Icons.sentiment_satisfied_alt, color: Colors.green,
      condition: (s) => (s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) >= 10,
      progress: (s) => ((s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) / 10).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'win_50', title: 'Müdavim', description: '50 Galibiyet', icon: Icons.coffee, color: Colors.teal,
      condition: (s) => (s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) >= 50,
      progress: (s) => ((s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) / 50).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'win_100', title: 'Yüzbaşı', description: '100 Galibiyet', icon: Icons.military_tech, color: Colors.blue,
      condition: (s) => (s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) >= 100,
      progress: (s) => ((s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) / 100).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'win_250', title: 'Gladyatör', description: '250 Galibiyet', icon: Icons.sports_kabaddi, color: Colors.indigo,
      condition: (s) => (s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) >= 250,
      progress: (s) => ((s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) / 250).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'win_500', title: 'Efsane', description: '500 Galibiyet', icon: Icons.workspace_premium, color: Colors.orange,
      condition: (s) => (s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) >= 500,
      progress: (s) => ((s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) / 500).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'win_1000', title: 'Ölümsüz', description: '1000 Galibiyet', icon: Icons.diamond, color: Colors.purple,
      condition: (s) => (s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) >= 1000,
      progress: (s) => ((s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins) / 1000).clamp(0.0, 1.0),
    ),

    // GAMES PLAYED
    Achievement(
      id: 'games_10', title: 'Isınma Turu', description: '10 Oyun Oynama', icon: Icons.sports_esports, color: Colors.blueGrey,
      condition: (s) => (s.classicStats.played + s.hardStats.played + s.dailyStats.played) >= 10,
      progress: (s) => ((s.classicStats.played + s.hardStats.played + s.dailyStats.played) / 10).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'games_100', title: 'Tecrübeli', description: '100 Oyun Oynama', icon: Icons.videogame_asset, color: Colors.indigo,
      condition: (s) => (s.classicStats.played + s.hardStats.played + s.dailyStats.played) >= 100,
      progress: (s) => ((s.classicStats.played + s.hardStats.played + s.dailyStats.played) / 100).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'games_500', title: 'Bağımlı', description: '500 Oyun Oynama', icon: Icons.gamepad, color: Colors.deepPurple,
      condition: (s) => (s.classicStats.played + s.hardStats.played + s.dailyStats.played) >= 500,
      progress: (s) => ((s.classicStats.played + s.hardStats.played + s.dailyStats.played) / 500).clamp(0.0, 1.0),
    ),
    
    // WIN RATE
    Achievement(
      id: 'flawless_50', title: 'Kusursuz', description: '50 Oyun & %90 Win', icon: Icons.track_changes, color: Colors.redAccent,
      condition: (s) {
        int played = s.classicStats.played + s.hardStats.played + s.dailyStats.played;
        int wins = s.classicStats.wins + s.hardStats.wins + s.dailyStats.wins;
        return played >= 50 && (wins / played) >= 0.90;
      },
      progress: (s) => ((s.classicStats.played + s.hardStats.played + s.dailyStats.played) / 50).clamp(0.0, 1.0),
    ),

    // STREAKS (6)
    Achievement(
      id: 'streak_3', title: 'Isınma', description: '3 Seri', icon: Icons.local_fire_department, color: Colors.orangeAccent,
      condition: (s) => max(s.classicStats.maxStreak, s.hardStats.maxStreak) >= 3,
      progress: (s) => (max(s.classicStats.maxStreak, s.hardStats.maxStreak) / 3).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'streak_5', title: 'Alev Alev', description: '5 Seri', icon: Icons.whatshot, color: Colors.deepOrange,
      condition: (s) => max(s.classicStats.maxStreak, s.hardStats.maxStreak) >= 5,
      progress: (s) => (max(s.classicStats.maxStreak, s.hardStats.maxStreak) / 5).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'streak_10', title: 'İstikrar', description: '10 Seri', icon: Icons.bolt, color: Colors.amber,
      condition: (s) => max(s.classicStats.maxStreak, s.hardStats.maxStreak) >= 10,
      progress: (s) => (max(s.classicStats.maxStreak, s.hardStats.maxStreak) / 10).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'streak_20', title: 'Durdurulamaz', description: '20 Seri', icon: Icons.rocket_launch, color: Colors.redAccent,
      condition: (s) => max(s.classicStats.maxStreak, s.hardStats.maxStreak) >= 20,
      progress: (s) => (max(s.classicStats.maxStreak, s.hardStats.maxStreak) / 20).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'streak_30', title: 'Makine', description: '30 Seri', icon: Icons.smart_toy, color: Colors.grey,
      condition: (s) => max(s.classicStats.maxStreak, s.hardStats.maxStreak) >= 30,
      progress: (s) => (max(s.classicStats.maxStreak, s.hardStats.maxStreak) / 30).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'streak_50', title: 'Hilekar?!', description: '50 Seri', icon: Icons.bug_report, color: Colors.greenAccent,
      condition: (s) => max(s.classicStats.maxStreak, s.hardStats.maxStreak) >= 50,
      progress: (s) => (max(s.classicStats.maxStreak, s.hardStats.maxStreak) / 50).clamp(0.0, 1.0),
    ),

    // SCORES (7)
    Achievement(
      id: 'score_10k', title: 'Kumbaram', description: '10B Puan', icon: Icons.savings, color: Colors.pink,
      condition: (s) => s.totalScore >= 10000,
      progress: (s) => (s.totalScore / 10000).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'score_50k', title: 'Kalfa', description: '50B Puan', icon: Icons.build, color: Colors.orange,
      condition: (s) => s.totalScore >= 50000,
      progress: (s) => (s.totalScore / 50000).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'score_100k', title: 'Zengin', description: '100B Puan', icon: Icons.monetization_on, color: Colors.green,
      condition: (s) => s.totalScore >= 100000,
      progress: (s) => (s.totalScore / 100000).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'score_250k', title: 'Aristokrat', description: '250B Puan', icon: Icons.account_balance, color: Colors.blueGrey,
      condition: (s) => s.totalScore >= 250000,
      progress: (s) => (s.totalScore / 250000).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'score_500k', title: 'Büyücü', description: '500B Puan', icon: Icons.auto_awesome, color: Colors.deepPurple,
      condition: (s) => s.totalScore >= 500000,
      progress: (s) => (s.totalScore / 500000).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'score_1m', title: 'Milyoner', description: '1M Puan', icon: Icons.diamond_outlined, color: Colors.cyan,
      condition: (s) => s.totalScore >= 1000000,
      progress: (s) => (s.totalScore / 1000000).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'score_5m', title: 'Kelime Tanrısı', description: '5M Puan', icon: Icons.public, color: Colors.blueAccent,
      condition: (s) => s.totalScore >= 5000000,
      progress: (s) => (s.totalScore / 5000000).clamp(0.0, 1.0),
    ),

    // SPEED (5)
    Achievement(
      id: 'speed_120', title: 'Rahat', description: '2 dk altı', icon: Icons.directions_walk, color: Colors.lightGreen,
      condition: (s) => _bestTime(s, 120) == 1.0,
      progress: (s) => _bestTime(s, 120),
    ),
    Achievement(
      id: 'speed_60', title: 'Tempolu', description: '1 dk altı', icon: Icons.directions_run, color: Colors.orange,
      condition: (s) => _bestTime(s, 60) == 1.0,
      progress: (s) => _bestTime(s, 60),
    ),
    Achievement(
      id: 'speed_30', title: 'Hız Tutkunu', description: '30 sn altı', icon: Icons.sports_motorsports, color: Colors.red,
      condition: (s) => _bestTime(s, 30) == 1.0,
      progress: (s) => _bestTime(s, 30),
    ),
    Achievement(
      id: 'speed_15', title: 'Işık Hızı', description: '15 sn altı', icon: Icons.flash_on, color: Colors.yellowAccent.shade700,
      condition: (s) => _bestTime(s, 15) == 1.0,
      progress: (s) => _bestTime(s, 15),
    ),
    Achievement(
      id: 'speed_10', title: 'Teleport', description: '10 sn altı', icon: Icons.electric_bolt, color: Colors.purpleAccent,
      condition: (s) => _bestTime(s, 10) == 1.0,
      progress: (s) => _bestTime(s, 10),
    ),

    // GUESSES
    Achievement(
      id: 'guess_1', title: 'Müneccim', description: '1. tahminde', icon: Icons.visibility, color: Colors.pinkAccent,
      condition: (s) => s.classicStats.guessDistribution[0] > 0 || s.hardStats.guessDistribution[0] > 0 || s.dailyStats.guessDistribution[0] > 0,
      progress: (s) => (s.classicStats.guessDistribution[0] > 0 || s.hardStats.guessDistribution[0] > 0 || s.dailyStats.guessDistribution[0] > 0) ? 1.0 : 0.0,
    ),
    Achievement(
      id: 'guess_2', title: 'Keskin Nişancı', description: '2. tahminde', icon: Icons.my_location, color: Colors.tealAccent.shade700,
      condition: (s) => s.classicStats.guessDistribution[1] > 0 || s.hardStats.guessDistribution[1] > 0 || s.dailyStats.guessDistribution[1] > 0,
      progress: (s) => (s.classicStats.guessDistribution[1] > 0 || s.hardStats.guessDistribution[1] > 0 || s.dailyStats.guessDistribution[1] > 0) ? 1.0 : 0.0,
    ),
    Achievement(
      id: 'guess_3', title: 'Pratik', description: '3. tahminde', icon: Icons.thumb_up, color: Colors.lightBlue,
      condition: (s) => s.classicStats.guessDistribution[2] > 0 || s.hardStats.guessDistribution[2] > 0 || s.dailyStats.guessDistribution[2] > 0,
      progress: (s) => (s.classicStats.guessDistribution[2] > 0 || s.hardStats.guessDistribution[2] > 0 || s.dailyStats.guessDistribution[2] > 0) ? 1.0 : 0.0,
    ),
    Achievement(
      id: 'guess_4', title: 'Standart', description: '4. tahminde', icon: Icons.check_circle_outline, color: Colors.lightGreen,
      condition: (s) => s.classicStats.guessDistribution[3] > 0 || s.hardStats.guessDistribution[3] > 0 || s.dailyStats.guessDistribution[3] > 0,
      progress: (s) => (s.classicStats.guessDistribution[3] > 0 || s.hardStats.guessDistribution[3] > 0 || s.dailyStats.guessDistribution[3] > 0) ? 1.0 : 0.0,
    ),
    Achievement(
      id: 'guess_5', title: 'Şanslı', description: '5. tahminde', icon: Icons.casino, color: Colors.deepOrangeAccent,
      condition: (s) => s.classicStats.guessDistribution[4] > 0 || s.hardStats.guessDistribution[4] > 0 || s.dailyStats.guessDistribution[4] > 0,
      progress: (s) => (s.classicStats.guessDistribution[4] > 0 || s.hardStats.guessDistribution[4] > 0 || s.dailyStats.guessDistribution[4] > 0) ? 1.0 : 0.0,
    ),
    Achievement(
      id: 'guess_6', title: 'Son Nefeste', description: '6. tahminde', icon: Icons.warning, color: Colors.amber,
      condition: (s) => s.classicStats.guessDistribution[5] > 0 || s.hardStats.guessDistribution[5] > 0 || s.dailyStats.guessDistribution[5] > 0,
      progress: (s) => (s.classicStats.guessDistribution[5] > 0 || s.hardStats.guessDistribution[5] > 0 || s.dailyStats.guessDistribution[5] > 0) ? 1.0 : 0.0,
    ),

    // HARD MODE (4)
    Achievement(
      id: 'hard_1', title: 'Cesaret', description: 'Uzman: 1 Galibiyet', icon: Icons.shield, color: Colors.grey,
      condition: (s) => s.hardStats.wins >= 1,
      progress: (s) => (s.hardStats.wins / 1).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'hard_10', title: 'Savaşçı', description: 'Uzman: 10 Galibiyet', icon: Icons.hardware, color: Colors.brown,
      condition: (s) => s.hardStats.wins >= 10,
      progress: (s) => (s.hardStats.wins / 10).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'hard_50', title: 'Usta', description: 'Uzman: 50 Galibiyet', icon: Icons.psychology, color: Colors.indigoAccent,
      condition: (s) => s.hardStats.wins >= 50,
      progress: (s) => (s.hardStats.wins / 50).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'hard_100', title: 'Büyük Usta', description: 'Uzman: 100 Win', icon: Icons.stars, color: Colors.deepPurple,
      condition: (s) => s.hardStats.wins >= 100,
      progress: (s) => (s.hardStats.wins / 100).clamp(0.0, 1.0),
    ),

    // DAILY MODE (3)
    Achievement(
      id: 'daily_1', title: 'Merhaba', description: 'Günlük: 1 Win', icon: Icons.wb_sunny, color: Colors.orangeAccent,
      condition: (s) => s.dailyStats.wins >= 1,
      progress: (s) => (s.dailyStats.wins / 1).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'daily_7', title: 'Haftalık', description: 'Günlük: 7 Win', icon: Icons.date_range, color: Colors.lightGreen,
      condition: (s) => s.dailyStats.wins >= 7,
      progress: (s) => (s.dailyStats.wins / 7).clamp(0.0, 1.0),
    ),
    Achievement(
      id: 'daily_30', title: 'Aylık', description: 'Günlük: 30 Win', icon: Icons.calendar_month, color: Colors.teal,
      condition: (s) => s.dailyStats.wins >= 30,
      progress: (s) => (s.dailyStats.wins / 30).clamp(0.0, 1.0),
    ),
  ];

  static double _bestTime(StatsModel s, int target) {
    final b1 = s.classicStats.bestTimeSeconds;
    final b2 = s.hardStats.bestTimeSeconds;
    final b3 = s.dailyStats.bestTimeSeconds;
    bool check(int t) => t > 0 && t <= target;
    if (check(b1) || check(b2) || check(b3)) return 1.0;
    
    int minTime = 9999;
    if (b1 > 0) minTime = min(minTime, b1);
    if (b2 > 0) minTime = min(minTime, b2);
    if (b3 > 0) minTime = min(minTime, b3);
    
    if (minTime == 9999) return 0.0;
    double p = target / minTime;
    return p.clamp(0.0, 0.99);
  }
}
