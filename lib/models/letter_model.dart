enum LetterState { initial, absent, present, correct }

class LetterModel {
  final String letter;
  final LetterState state;

  LetterModel({required this.letter, this.state = LetterState.initial});

  LetterModel copyWith({String? letter, LetterState? state}) {
    return LetterModel(
      letter: letter ?? this.letter,
      state: state ?? this.state,
    );
  }
}
