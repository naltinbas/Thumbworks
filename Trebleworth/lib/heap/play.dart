import 'level.dart';
import 'levels.dart';

/// What the show-me points at.
enum Aim { shelf, slot }

/// One go at an ask: the slots as filled, the taps taken, and the go
/// before, so a tap can be taken back.
class Play {
  const Play._({
    required this.level,
    required this.slots,
    required this.moves,
    required this.before,
  });

  Play.of(this.level)
      : slots = List.unmodifiable(List<int?>.filled(level.slots, null)),
        moves = 0,
        before = null;

  /// A play stood at a filling, for the mark and the tests.
  Play.standing(this.level, List<int?> filled)
      : slots = List.unmodifiable(filled),
        moves = 0,
        before = null;

  final Level level;

  /// The slots, each a triangular number or null.
  final List<int?> slots;

  /// The taps taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless ask admits it.
  static const gaveUpAt = 20;

  int get sum => slots.fold(0, (a, b) => a + (b ?? 0));

  bool get isFull => slots.every((s) => s != null);

  int? get firstEmpty {
    final i = slots.indexOf(null);
    return i < 0 ? null : i;
  }

  /// Taps shelf number [t]: it fills the first empty slot.
  Play take(int t) {
    if (isOver || !level.shelf.contains(t)) return this;
    final i = firstEmpty;
    if (i == null) return this;
    final next = List<int?>.of(slots);
    next[i] = t;
    return Play._(level: level, slots: List.unmodifiable(next), moves: moves + 1, before: this);
  }

  /// Taps slot [i]: it is emptied.
  Play drop(int i) {
    if (isOver || i < 0 || i >= slots.length || slots[i] == null) return this;
    final next = List<int?>.of(slots);
    next[i] = null;
    return Play._(level: level, slots: List.unmodifiable(next), moves: moves + 1, before: this);
  }

  Play get back => before ?? this;

  bool get isDone => level.winnable && level.meets(slots);

  /// A hopeless ask, admitted: two heaps full at four or six, the
  /// nearest to five, or [gaveUpAt] taps.
  bool get gaveUp => !level.winnable && (isFull && (sum == 4 || sum == 6) || moves >= gaveUpAt);

  bool get isOver => isDone || gaveUp;

  /// What the pointer says: drop a slot not in the aim, else take the
  /// aim's next; null when nothing points anywhere.
  (Aim, int)? get next {
    final aim = level.aim;
    if (aim == null || isOver) return null;
    // The aim as a bag; slots holding something not in the bag are
    // dropped first.
    final bag = List.of(aim);
    for (var i = 0; i < slots.length; i++) {
      final s = slots[i];
      if (s == null) continue;
      if (!bag.remove(s)) return (Aim.slot, i);
    }
    if (bag.isEmpty) return null;
    return (Aim.shelf, bag.first);
  }

  static String pointed((Aim, int) aim) => aim.$1 == Aim.slot ? 'Empty the ringed slot.' : 'Take ${aim.$2} from the shelf.';
}

/// Why three heaps: the words behind the Why button.
String whyWords(Play play) {
  final level = play.level;
  final number = Levels.all.indexOf(level) + 1;
  return 'The triangular numbers are the heaps of a triangle of stones, 0, 1, '
      '3, 6, 10, 15, 21 and on, each the last plus one more row. Gauss found in '
      '1796 that every whole number is three of them added, nought allowed, '
      'and wrote it in his diary as Eureka: num = triangle + triangle + '
      'triangle. Two are not enough, 5 the first that needs three. The reason '
      'runs through squares: eight times a triangular number k(k+1)/2 plus one '
      'is (2k+1) squared, so n is three triangular numbers exactly when 8n + 3 '
      'is three odd squares, and it always is.\n\n'
      'The game sweeps every number to 500, three heaps and two, and matches '
      'the three-heap ways of every n with the odd-square ways of 8n + 3, one '
      'for one; every number to 500 has three heaps, and 212 of them have no '
      'two.\n\n'
      'This is ask $number, ${level.name}. ${level.note}\n\n'
      'The tile\'s counts are the sweep\'s: every heap of the count asked from '
      'the shelf, tried in full.';
}
