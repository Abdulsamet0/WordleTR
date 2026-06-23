import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/letter_model.dart';
import '../models/word_model.dart';
import '../models/stats_model.dart';
import '../models/level_system.dart';
import '../theme/app_theme.dart';

// Top-level function for background isolate JSON parsing
List<String> _parseWords(String jsonString) {
  final List<dynamic> data = json.decode(jsonString);
  return data.map((e) => e.toString().toUpperCase()).toList();
}

enum GameStatus { playing, won, lost }

class WordleProvider extends ChangeNotifier {
  List<WordModel> board = List.generate(6, (index) => WordModel.empty());
  int currentRow = 0;
  String targetWord = "";
  GameStatus gameStatus = GameStatus.playing;

  List<String> validWords = [];
  List<String> answerWords = [];
  Map<String, LetterState> keyboardLetterStates = {};
  
  bool isInitialized = false;

  String message = "";

  StatsModel stats = StatsModel();

  bool get isHardMode => stats.hardMode;
  bool get isDailyMode => stats.dailyMode;

  Timer? _timer;
  int elapsedSeconds = 0;
  Map<String, int>? lastScoreDetails;
  
  bool isLevelUp = false;
  String newLevelTitle = "";
  String unlockedAvatar = "";

  final AudioPlayer _audioPlayer = AudioPlayer();

  void playSound(String fileName) {
    if (!stats.soundEnabled) return;
    try {
      _audioPlayer.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint("Ses çalınamadı: $e");
    }
  }

  void toggleSound() {
    stats.soundEnabled = !stats.soundEnabled;
    stats.save();
    notifyListeners();
    lightImpact();
  }

  void toggleHaptic() {
    stats.hapticEnabled = !stats.hapticEnabled;
    stats.save();
    notifyListeners();
    lightImpact();
  }

  void toggleHardMode() {
    // Only allow toggling if the game is at the start (currentRow == 0 and board is empty, or just currentRow == 0)
    // Actually we will handle this in UI, but good to have a simple toggle here.
    stats.hardMode = !stats.hardMode;
    stats.save();
    notifyListeners();
  }

  void vibrate() {
    if (stats.hapticEnabled) HapticFeedback.vibrate();
  }

  void lightImpact() {
    if (stats.hapticEnabled) HapticFeedback.lightImpact();
  }

  void mediumImpact() {
    if (stats.hapticEnabled) HapticFeedback.mediumImpact();
  }

  void heavyImpact() {
    if (stats.hapticEnabled) HapticFeedback.heavyImpact();
  }

  int get currentThemeIndex => stats.themeIndex;
  ThemePalette get currentTheme => ThemePalette.getTheme(stats.themeIndex);

  void setTheme(int index) {
    stats.themeIndex = index;
    stats.save();
    notifyListeners();
    lightImpact();
  }

  WordleProvider() {
    initGame();
  }

  Future<void> initGame() async {
    stats = await StatsModel.load();

    try {
      final String response = await rootBundle.loadString('assets/words.json');
      validWords = await compute(_parseWords, response);

      final String answersResponse = await rootBundle.loadString(
        'assets/answers.json',
      );
      answerWords = await compute(_parseWords, answersResponse);

      if (answerWords.isNotEmpty) {
        final random = Random();
        targetWord = answerWords[random.nextInt(answerWords.length)];
      }
    } catch (e) {
      debugPrint("Kelime listesi yüklenemedi: $e");
    }

      resetGame();
      isInitialized = true;
      notifyListeners();
    }

  void resetGame({bool? isDailyMode, bool? isHardMode}) {
    isLevelUp = false;
    newLevelTitle = "";
    unlockedAvatar = "";
    bool shouldSave = false;
    if (isDailyMode != null) {
      stats.dailyMode = isDailyMode;
      shouldSave = true;
    }
    if (isHardMode != null) {
      stats.hardMode = isHardMode;
      shouldSave = true;
    }
    if (shouldSave) stats.save();

    board = List.generate(6, (index) => WordModel.empty());
    currentRow = 0;
    gameStatus = GameStatus.playing;
    keyboardLetterStates.clear();
    message = "";

    if (answerWords.isNotEmpty) {
      if (stats.dailyMode) {
        final now = DateTime.now();
        final seedStr =
            "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
        final seed = int.parse(seedStr);
        targetWord = answerWords[Random(seed).nextInt(answerWords.length)];
      } else {
        targetWord = answerWords[Random().nextInt(answerWords.length)];
      }
    }

    resetTimer();
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    elapsedSeconds = 0;
    resumeTimer();
  }

  void pauseTimer() {
    _timer?.cancel();
  }

  void resumeTimer() {
    if (gameStatus != GameStatus.playing) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String get formattedTime {
    int minutes = elapsedSeconds ~/ 60;
    int seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void onKeyTapped(String key) {
    if (gameStatus != GameStatus.playing) return;

    if (key == "ENTER") {
      mediumImpact();
      submitGuess();
    } else if (key == "BACK") {
      mediumImpact();
      removeLetter();
    } else {
      lightImpact();
      addLetter(key);
    }
  }

  void addLetter(String letter) {
    if (board[currentRow].isFull) {
      playSound('error.mp3');
      vibrate();
      return;
    }

    board[currentRow].addLetter(letter);
    playSound('tap.mp3');
    lightImpact();
    notifyListeners();
  }

  void removeLetter() {
    if (board[currentRow].letters.every((l) => l.letter.isEmpty)) {
      playSound('error.mp3');
      vibrate();
      return;
    }
    board[currentRow].removeLetter();
    playSound('tap.mp3');
    lightImpact();
    notifyListeners();
  }

  void _triggerShake() {
    final rowIndex = currentRow;
    board[rowIndex].isShaking = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 500), () {
      board[rowIndex].isShaking = false;
      notifyListeners();
    });
  }

  void submitGuess() {
    final currentWord = board[currentRow];

    if (!currentWord.isFull) {
      playSound('error.mp3');
      vibrate();
      _triggerShake();
      showMessage("Kelime 5 harfli olmalı!");
      return;
    }

    if (currentRow == 0 && stats.dailyMode) {
      final now = DateTime.now();
      final todayStr =
          "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
      stats.lastDailyPlayedDate = todayStr;
      stats.save();
    }

    final guessString = currentWord.wordString;

    if (!validWords.contains(guessString)) {
      playSound('error.mp3');
      vibrate();
      _triggerShake();
      showMessage("Geçersiz kelime!");
      return;
    }

    if (stats.hardMode && currentRow > 0) {
      // Yeşil ve Sarı harf kurallarını kontrol et
      for (int i = 0; i < currentRow; i++) {
        final prevWord = board[i];
        for (int j = 0; j < 5; j++) {
          final prevLetter = prevWord.letters[j];
          if (prevLetter.state == LetterState.correct) {
            if (currentWord.letters[j].letter != prevLetter.letter) {
              playSound('error.mp3');
              vibrate();
              _triggerShake();
              showMessage("${j + 1}. harf '${prevLetter.letter}' olmalı!");
              return;
            }
          } else if (prevLetter.state == LetterState.present) {
            if (!currentWord.wordString.contains(prevLetter.letter)) {
              playSound('error.mp3');
              vibrate();
              _triggerShake();
              showMessage("Tahmin '${prevLetter.letter}' harfini içermeli!");
              return;
            }
          }
        }
      }
    }

    mediumImpact();

    // Kayıt: En çok tahmin edilen kelimeler
    ModeStats activeModeStats = isDailyMode
        ? stats.dailyStats
        : (isHardMode ? stats.hardStats : stats.classicStats);
    activeModeStats.guessedWords[guessString] =
        (activeModeStats.guessedWords[guessString] ?? 0) + 1;

    evaluateGuess(currentWord, guessString);

    // Animasyon süresi: her harf için 300ms gecikme + 500ms flip = ~1800ms
    const int animationDurationMs = 1800;

    if (guessString == targetWord) {
      _stopTimer();
      int attempts = currentRow + 1;
      
      int previousScore = stats.totalScore;
      int previousLevel = LevelSystem.getLevelIndexForScore(previousScore);
      
      // Skor hesapla
      lastScoreDetails = LevelSystem.calculateScoreDetails(
        attempts, 
        elapsedSeconds, 
        isDailyMode ? stats.dailyStats.currentStreak : (isHardMode ? stats.hardStats.currentStreak : stats.classicStats.currentStreak),
        isHardMode: isHardMode,
      );
      int earnedScore = lastScoreDetails!['total']!;

      if (isDailyMode) {
        stats.dailyStats.updateStats(isWin: true, attempts: attempts);
        stats.dailyStats.updateBestTime(elapsedSeconds);
        stats.dailyStats.score += earnedScore;
      } else if (isHardMode) {
        stats.hardStats.updateStats(isWin: true, attempts: attempts);
        stats.hardStats.updateBestTime(elapsedSeconds);
        stats.hardStats.score += earnedScore;
      } else {
        stats.classicStats.updateStats(isWin: true, attempts: attempts);
        stats.classicStats.updateBestTime(elapsedSeconds);
        stats.classicStats.score += earnedScore;
      }
      
      int newScore = stats.totalScore;
      int newLevel = LevelSystem.getLevelIndexForScore(newScore);
      
      if (newLevel > previousLevel) {
        isLevelUp = true;
        newLevelTitle = LevelSystem.levelTitles[newLevel];
        // Yeni açılan avatarlardan ilkini örnek olarak al (Çaylak -> Çırak vs.)
        List<String> newAvatars = LevelSystem.getUnlockedAvatars(newScore);
        List<String> oldAvatars = LevelSystem.getUnlockedAvatars(previousScore);
        // Yeni eklenenleri bul
        var newlyUnlocked = newAvatars.where((a) => !oldAvatars.contains(a)).toList();
        if (newlyUnlocked.isNotEmpty) {
          unlockedAvatar = newlyUnlocked.first;
        }
      }

      stats.save();
      Future.delayed(const Duration(milliseconds: animationDurationMs), () {
        gameStatus = GameStatus.won;
        heavyImpact();
        playSound('win.mp3');
        showMessage(isLevelUp ? "SEVİYE ATLADIN!" : "Tebrikler! ${currentRow + 1}. denemede buldunuz.");
        notifyListeners();
      });
    } else if (currentRow == 5) {
      _stopTimer();
      lastScoreDetails = null; // Kaybedince skor 0
      
      if (isDailyMode) {
        stats.dailyStats.updateStats(isWin: false);
      } else if (isHardMode) {
        stats.hardStats.updateStats(isWin: false);
      } else {
        stats.classicStats.updateStats(isWin: false);
      }
      stats.save();
      Future.delayed(const Duration(milliseconds: animationDurationMs), () {
        gameStatus = GameStatus.lost;
        vibrate();
        playSound('lose.mp3');
        showMessage("Oyun bitti! Kelime: $targetWord");
        notifyListeners();
      });
    } else {
      currentRow++;
    }

    notifyListeners();
  }

  void evaluateGuess(WordModel currentWord, String guessString) {
    String remainingTarget = targetWord;
    List<LetterState> evaluatedStates = List.filled(5, LetterState.absent);

    // 1. Doğru harfleri bul (Yeşil)
    for (int i = 0; i < 5; i++) {
      String letter = currentWord.letters[i].letter;
      if (letter == targetWord[i]) {
        evaluatedStates[i] = LetterState.correct;
        remainingTarget = remainingTarget.replaceFirst(letter, '_');
      }
    }

    // 2. Yanlış yerdeki harfleri bul (Sarı) ve geriye kalanları gri yap
    for (int i = 0; i < 5; i++) {
      if (evaluatedStates[i] == LetterState.correct) continue;

      String letter = currentWord.letters[i].letter;
      if (remainingTarget.contains(letter)) {
        evaluatedStates[i] = LetterState.present;
        remainingTarget = remainingTarget.replaceFirst(letter, '_');
      } else {
        evaluatedStates[i] = LetterState.absent;
      }
    }

    // 3. Tahtayı anında güncelle (Animasyonu tetiklemek için)
    for (int i = 0; i < 5; i++) {
      currentWord.letters[i] = LetterModel(
        letter: currentWord.letters[i].letter,
        state: evaluatedStates[i],
      );
    }

    // 4. Klavyeyi gecikmeli güncelle (Flip animasyonu ile senkronize - 90 derecede dönerken)
    for (int i = 0; i < 5; i++) {
      String letter = currentWord.letters[i].letter;
      LetterState state = evaluatedStates[i];

      // Index * 300ms + 250ms (flip'in yarısı)
      Future.delayed(Duration(milliseconds: i * 300 + 250), () {
        if (state == LetterState.correct) {
          keyboardLetterStates[letter] = LetterState.correct;
        } else if (state == LetterState.present &&
            keyboardLetterStates[letter] != LetterState.correct) {
          keyboardLetterStates[letter] = LetterState.present;
        } else if (state == LetterState.absent &&
            keyboardLetterStates[letter] != LetterState.correct &&
            keyboardLetterStates[letter] != LetterState.present) {
          keyboardLetterStates[letter] = LetterState.absent;
        }
        notifyListeners();
      });
    }
  }

  void showMessage(String msg) {
    message = msg;
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (message == msg) {
        message = "";
        notifyListeners();
      }
    });
  }

  void markTutorialSeen() {
    stats.hasSeenTutorial = true;
    stats.save();
    notifyListeners();
  }

  String generateShareString() {
    String modeName = isDailyMode
        ? "Günlük Bulmaca"
        : (isHardMode ? "Zor Mod" : "Klasik Mod");
    String result = "Wordle TR - $modeName\n\n";
    if (gameStatus == GameStatus.won) {
      result += "${currentRow + 1}/6\n\n";
    } else {
      result += "X/6\n\n";
    }

    for (int i = 0; i <= currentRow; i++) {
      for (int j = 0; j < 5; j++) {
        final state = board[i].letters[j].state;
        if (state == LetterState.correct) {
          result += "🟩";
        } else if (state == LetterState.present) {
          result += "🟨";
        } else {
          result += "⬛";
        }
      }
      result += "\n";
    }
    return result;
  }

  void updateSelectedAvatar(String avatar) {
    stats.selectedAvatar = avatar;
    stats.save();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
