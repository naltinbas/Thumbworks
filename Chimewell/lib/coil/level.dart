import 'rules.dart';

/// One ask: a note to sound by fifths and octaves.
class Level {
  const Level({
    required this.name,
    required this.want,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'tone': the note is [Levels]' fraction; 'near': within a twentieth of
  /// the start with a fifth or more in the stack; 'home': the start itself
  /// with a fifth or more in the stack.
  final (String, BigInt, BigInt) want;

  /// How many of the settings land it, from the sweep.
  final int ways;

  /// The setting the pointer walks to, or null when none lands it.
  final (int, int)? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether fifths [f] and octaves [o] land the ask.
  bool meets(int f, int o) {
    final r = Rules.note(f, o);
    switch (want.$1) {
      case 'tone':
        return r.$1 == want.$2 && r.$2 == want.$3;
      case 'near':
        return f != 0 && Rules.within(r, 20);
      default:
        return f != 0 && Rules.home(r);
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (want.$1) {
      case 'tone':
        return 'set the fifths and the octaves so the note sounds ${Rules.fraction((want.$2, want.$3))} of the start';
      case 'near':
        return 'set the fifths and the octaves so the note comes within a twentieth of the start, one fifth or more in the stack';
      default:
        return 'set the fifths and the octaves so the note comes home exactly, one fifth or more in the stack';
    }
  }
}
