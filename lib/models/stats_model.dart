import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ModeStats {
  int played;
  int wins;
  int currentStreak;
  int maxStreak;
  int bestTimeSeconds;
  int score; // Added score based on new scoring model
  List<int> guessDistribution;
  Map<String, int> guessedWords;

  ModeStats({
    this.played = 0,
    this.wins = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.bestTimeSeconds = 0,
    this.score = 0,
    List<int>? guessDistribution,
    Map<String, int>? guessedWords,
  }) : guessDistribution = guessDistribution ?? List.filled(6, 0),
       guessedWords = guessedWords ?? {};

  int get winPercentage => played == 0 ? 0 : ((wins / played) * 100).round();

  Map<String, dynamic> toJson() {
    return {
      'played': played,
      'wins': wins,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'bestTimeSeconds': bestTimeSeconds,
      'score': score,
      'guessDistribution': guessDistribution,
      'guessedWords': guessedWords,
    };
  }

  factory ModeStats.fromJson(Map<String, dynamic> json) {
    return ModeStats(
      played: json['played'] ?? 0,
      wins: json['wins'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      maxStreak: json['maxStreak'] ?? 0,
      bestTimeSeconds: json['bestTimeSeconds'] ?? 0,
      score: json['score'] ?? 0,
      guessDistribution: List<int>.from(json['guessDistribution'] ?? List.filled(6, 0)),
      guessedWords: Map<String, int>.from(json['guessedWords'] ?? {}),
    );
  }

  void updateStats({required bool isWin, int? attempts}) {
    played++;
    if (isWin) {
      wins++;
      currentStreak++;
      if (currentStreak > maxStreak) {
        maxStreak = currentStreak;
      }
      if (attempts != null && attempts >= 1 && attempts <= 6) {
        guessDistribution[attempts - 1]++;
      }
    } else {
      currentStreak = 0;
    }
  }

  void updateBestTime(int seconds) {
    if (seconds <= 0) return;
    if (bestTimeSeconds == 0 || seconds < bestTimeSeconds) {
      bestTimeSeconds = seconds;
    }
  }
}

class StatsModel {
  ModeStats classicStats;
  ModeStats hardStats;
  ModeStats dailyStats;
  
  bool hasSeenTutorial;
  bool soundEnabled;
  bool hapticEnabled;
  int themeIndex;
  bool hardMode;
  bool dailyMode;
  String lastDailyPlayedDate;
  String selectedAvatar;

  int get totalScore => classicStats.score + hardStats.score + dailyStats.score;

  StatsModel({
    ModeStats? classicStats,
    ModeStats? hardStats,
    ModeStats? dailyStats,
    this.hasSeenTutorial = false,
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.themeIndex = 0,
    this.hardMode = false,
    this.dailyMode = false,
    this.lastDailyPlayedDate = "",
    this.selectedAvatar = "🥚",
  })  : classicStats = classicStats ?? ModeStats(),
        hardStats = hardStats ?? ModeStats(),
        dailyStats = dailyStats ?? ModeStats();

  Map<String, dynamic> toJson() {
    return {
      'classicStats': classicStats.toJson(),
      'hardStats': hardStats.toJson(),
      'dailyStats': dailyStats.toJson(),
      'hasSeenTutorial': hasSeenTutorial,
      'soundEnabled': soundEnabled,
      'hapticEnabled': hapticEnabled,
      'themeIndex': themeIndex,
      'hardMode': hardMode,
      'dailyMode': dailyMode,
      'lastDailyPlayedDate': lastDailyPlayedDate,
      'selectedAvatar': selectedAvatar,
    };
  }

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    // Migration: Eğer eski formatta "played" varsa, onları classicStats'e at.
    ModeStats? legacyClassicStats;
    if (json.containsKey('played') && !json.containsKey('classicStats')) {
      legacyClassicStats = ModeStats(
        played: json['played'] ?? 0,
        wins: json['wins'] ?? 0,
        currentStreak: json['currentStreak'] ?? 0,
        maxStreak: json['maxStreak'] ?? 0,
        guessDistribution: List<int>.from(json['guessDistribution'] ?? List.filled(6, 0)),
        guessedWords: {},
      );
    }

    return StatsModel(
      classicStats: legacyClassicStats ?? (json['classicStats'] != null ? ModeStats.fromJson(json['classicStats']) : null),
      hardStats: json['hardStats'] != null ? ModeStats.fromJson(json['hardStats']) : null,
      dailyStats: json['dailyStats'] != null ? ModeStats.fromJson(json['dailyStats']) : null,
      hasSeenTutorial: json['hasSeenTutorial'] ?? false,
      soundEnabled: json['soundEnabled'] ?? true,
      hapticEnabled: json['hapticEnabled'] ?? true,
      themeIndex: json['themeIndex'] ?? 0,
      hardMode: json['hardMode'] ?? false,
      dailyMode: json['dailyMode'] ?? false,
      lastDailyPlayedDate: json['lastDailyPlayedDate'] ?? "",
      selectedAvatar: json['selectedAvatar'] ?? "🥚",
    );
  }

  static Future<StatsModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? statsStr = prefs.getString('wordle_stats');
    if (statsStr != null) {
      try {
        return StatsModel.fromJson(json.decode(statsStr));
      } catch (e) {
        return StatsModel();
      }
    }
    return StatsModel();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wordle_stats', json.encode(toJson()));
  }
}
