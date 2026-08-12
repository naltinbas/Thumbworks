import 'ring.dart';
import 'rules.dart';

/// A stall in progress. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.ring, this.beads, this.strung, this.strings, this.before,
      {this.jammed = false});

  factory Play.of(Ring ring) => Play._(
      ring, List<int>.filled(ring.beads, 0), const [], 0, null);

  final Ring ring;

  /// The string on the table, bead by bead.
  final List<int> beads;

  /// The shelf: every necklace strung so far, each by its smallest
  /// turning, in the order they were strung.
  final List<List<int>> strung;

  /// Strings committed, repeats included.
  final int strings;

  final Play? before;

  bool get isDone => strung.length >= ring.asked;

  /// Set when the whole shelf is already full on a hopeless ring
  /// and a string is committed anyway: there is nothing left to
  /// find, and the ring says so.
  final bool jammed;

  bool get gaveUp => jammed;

  bool get isOver => isDone || gaveUp;

  /// Dye one bead a shade onward, wrapping.
  Play dye(int at) {
    if (isOver) return this;
    final next = List.of(beads);
    next[at] = (next[at] + 1) % ring.dyes;
    return Play._(ring, next, strung, strings, this);
  }

  /// The necklace on the table right now.
  List<int> get necklace => Rules.necklaceOf(beads);

  /// Whether the table's necklace is already on the shelf; the
  /// shelf place when it is, or -1.
  int get alreadyAt {
    final now = necklace.join(',');
    for (var at = 0; at < strung.length; at++) {
      if (strung[at].join(',') == now) return at;
    }
    return -1;
  }

  /// String the table's beads onto the shelf.
  Play stringIt() {
    if (isOver) return this;
    if (!ring.winnable && strung.length == ring.holds) {
      return Play._(ring, List.of(beads), strung, strings + 1, this,
          jammed: true);
    }
    final now = necklace;
    final held = alreadyAt;
    return Play._(
      ring,
      List.of(beads),
      held == -1 ? [...strung, now] : strung,
      strings + 1,
      this,
    );
  }

  Play get back => before ?? this;

  /// What each turn fixes, for the why.
  List<int> get fixedByTurn =>
      Rules.fixedByTurn(ring.beads, ring.dyes);

  /// A necklace not yet on the shelf, for the pointer; null when
  /// the shelf holds the whole ring.
  List<int>? get missing {
    final held = {for (final necklace in strung) necklace.join(',')};
    for (final necklace in Rules.shelf(ring.beads, ring.dyes)) {
      if (!held.contains(necklace.join(','))) return necklace;
    }
    return null;
  }
}
