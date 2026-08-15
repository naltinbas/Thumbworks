import 'rules.dart';

/// One time on the sham: how many fuses, how many quarter-minutes to
/// strike, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.fuses,
    required this.asked,
    required this.ways,
    required this.plans,
    this.note,
  });

  final String name;
  final int fuses;

  /// The time to strike, in quarter-minutes from the start.
  final int asked;

  /// Plans that strike it, by the sweep; nought for the hopeless.
  final int ways;

  /// Plans of lighting, all told.
  final int plans;

  /// One thing worth knowing about this time, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The time asked, in words.
  String get askedWords => minutes(asked);

  static String minutes(int quarters) {
    final whole = quarters ~/ Rules.quarter;
    final rest = quarters % Rules.quarter;
    if (rest == 0) return '$whole minutes';
    if (rest == 2) return '$whole and a half minutes';
    return '$whole and $rest quarter minutes';
  }

  static const _words = {1: 'one', 2: 'two', 3: 'three'};

  /// The task, told in words for the ledger.
  String get task => 'strike $askedWords with ${_words[fuses]} fuse${fuses == 1 ? '' : 's'}';
}
