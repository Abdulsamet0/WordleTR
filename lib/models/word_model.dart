import 'letter_model.dart';

class WordModel {
  final List<LetterModel> letters;
  bool isShaking;

  WordModel({required this.letters, this.isShaking = false});

  factory WordModel.empty() {
    return WordModel(
      letters: List.generate(5, (index) => LetterModel(letter: '')),
      isShaking: false,
    );
  }

  factory WordModel.fromString(String word) {
    return WordModel(
      letters: word.split('').map((e) => LetterModel(letter: e)).toList(),
      isShaking: false,
    );
  }

  String get wordString => letters.map((e) => e.letter).join('');
  
  bool get isFull => letters.every((element) => element.letter.isNotEmpty);

  void addLetter(String letter) {
    for (int i = 0; i < letters.length; i++) {
      if (letters[i].letter.isEmpty) {
        letters[i] = LetterModel(letter: letter);
        break;
      }
    }
  }

  void removeLetter() {
    for (int i = letters.length - 1; i >= 0; i--) {
      if (letters[i].letter.isNotEmpty) {
        letters[i] = LetterModel(letter: '');
        break;
      }
    }
  }
}
