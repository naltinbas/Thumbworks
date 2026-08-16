import 'level.dart';
import 'levels.dart';

/// What the show-me points at.
enum Aim { add, drop }

/// One go at an ask: the parts laid, the taps taken, and the go before,
/// so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.parts,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : parts = const [],
        moves = 0,
        before = null;

  /// A play stood at a partition, for the mark and the tests.
  Play.standing(this.level, List<int> laid)
      : parts = List.unmodifiable(laid),
        moves = 0,
        before = null;

  final Level level;

  /// The parts laid, in the order laid.
  final List<int> parts;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 20;

  int get sum => parts.fold(0, (a, b) => a + b);

  List<int> get sorted => List.of(parts)..sort((a, b) => b - a);

  bool get isFull => sum == level.number;

  /// Adds a part of [size] from the shelf, if it fits.
  Play add(int size) {
    if (isOver || size < 1 || sum + size > level.number) return this;
    return Play._(level: level, parts: [...parts, size], moves: moves + 1, before: this);
  }

  /// Drops the part laid [i]th.
  Play drop(int i) {
    if (isOver || i < 0 || i >= parts.length) return this;
    return Play._(level: level, parts: [for (var k = 0; k < parts.length; k++) if (k != i) parts[k]], moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(parts);

  /// A hopeless ask, admitted: the number is made whole of even parts
  /// all different but one, or of any parts full and even-only failing;
  /// simplest: the sum stands full, or [gaveUpAt] taps.
  bool get gaveUp => !level.winnable && (isFull || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: drop a part not in the aim, else add the
  /// aim's next; null when nothing points anywhere.
  (Aim, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    final bag = List.of(aim);
    for (var i = 0; i < parts.length; i++) {
      if (!bag.remove(parts[i])) return (Aim.drop, i);
    }
    if (bag.isEmpty) return null;
    return (Aim.add, bag.first);
  }

  static String pointed((Aim, int) aim) => aim.$1 == Aim.drop ? 'Drop the ringed part.' : 'Add a part of ${aim.$2}.';
}

/// Why odd and different match: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'Sunder a number into parts, order set aside: 4 is 4, 3 + 1, 2 + 2, 2 + '
      '1 + 1 and 1 + 1 + 1 + 1, five ways. Euler found in 1748 that a number '
      'sunders into all-different parts in exactly as many ways as into '
      'all-odd parts, and Glaisher showed a folding that says why: take an '
      'all-odd partition and merge any two equal parts into one twice the '
      'size, again and again, and the parts end all different, and every '
      'all-different partition comes from exactly one all-odd one, unfolded '
      'the other way. Turn a partition on its side, reading down the columns '
      'of its dots, and its count of parts and its largest part swap.\n\n'
      'The game lays out every partition of every number to thirty, 5,604 of '
      'them for thirty alone, counts the all-different and the all-odd, and '
      'folds every all-odd one, landing on the all-different ones once each; '
      'and it turns every partition and checks the swap.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every partition of the number '
      'asked, laid out in full.';
}
