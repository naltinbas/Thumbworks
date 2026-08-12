import 'rules.dart';
import 'shelf.dart';

/// A shelf being ordered. Every state is a fresh value, and the
/// one before hangs on for take-back.
class Play {
  Play._(this.shelf, this.rules, this.order, this.picked, this.moves,
      this.before);

  factory Play.of(Shelf shelf) => Play._(
      shelf,
      Rules(shelf.books),
      List.generate(shelf.books, (at) => at),
      null,
      0,
      null);

  /// A play stood at an ordering, for the mark and the tests.
  factory Play.standing(Shelf shelf, List<int> order) => Play._(
      shelf, Rules(shelf.books), List.of(order), null, 0, null);

  final Shelf shelf;
  final Rules rules;

  /// The books in shelf order, each its height.
  final List<int> order;

  /// The place picked towards a swap, or null.
  final int? picked;

  /// Swaps taken.
  final int moves;

  final Play? before;

  /// The line past which the hopeless shelf admits it.
  static const gaveUpAt = 12;

  List<int> get stepsDown => Rules.stepsDown(order);

  bool get isDone =>
      moves > 0 && stepsDown.length == shelf.asked;

  bool get gaveUp => !shelf.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  /// Picks a place; the second picked place swaps the two books.
  Play tapAt(int place) {
    if (isOver) return this;
    final one = picked;
    if (one == null) {
      return Play._(shelf, rules, order, place, moves, before);
    }
    if (one == place) {
      return Play._(shelf, rules, order, null, moves, before);
    }
    final next = List.of(order);
    final held = next[one];
    next[one] = next[place];
    next[place] = held;
    return Play._(shelf, rules, next, null, moves + 1, this);
  }

  Play get back => before ?? this;

  /// The place and book the sweep would set next towards its
  /// ordering; null when none lands the asking.
  (int, int)? get next {
    final aim = rules.ordering(shelf.asked);
    if (aim == null || isDone) return null;
    for (var place = 0; place < shelf.books; place++) {
      if (order[place] != aim[place]) return (place, aim[place]);
    }
    return null;
  }
}
