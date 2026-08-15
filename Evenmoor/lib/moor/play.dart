import 'pegging.dart';
import 'rules.dart';

/// A pegging being set. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.pegging, this.rules, this.pegs, this.moves, this.before);

  factory Play.of(Pegging pegging) => Play._(pegging, Rules(), const [], 0, null);

  /// A play stood at a placing, for the mark and the tests.
  factory Play.standing(Pegging pegging, List<Peg> pegs) =>
      Play._(pegging, Rules(), List.of(pegs), pegs.length, null);

  final Pegging pegging;
  final Rules rules;

  /// The pegs set, in order.
  final List<Peg> pegs;

  /// Pegs set and lifted, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless pegging admits it.
  static const gaveUpAt = 13;

  List<(int, int)> get landed => Rules.halfwayPairs(pegs);

  int get kindsUsed => Rules.kindsUsed(pegs);

  bool get full => pegs.length == pegging.pegs;

  bool get isDone => full && landed.length == pegging.asked;

  bool get gaveUp => !pegging.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool touches(Peg peg) =>
      !isOver && peg.$1 >= 0 && peg.$1 < rules.side && peg.$2 >= 0 && peg.$2 < rules.side &&
      (pegs.contains(peg) || !full);

  /// Taps a hole: sets a peg, or lifts the one there.
  Play tap(Peg peg) {
    if (!touches(peg)) return this;
    final held = pegs.contains(peg) ? [for (final p in pegs) if (p != peg) p] : [...pegs, peg];
    return Play._(pegging, rules, held, moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', peg) for a peg off the aim,
  /// or ('set', peg) for the next; null when nothing lands.
  (String, Peg)? get next {
    if (isOver || !pegging.winnable) return null;
    final aim = aimFor(pegging);
    if (aim == null) return null;
    for (final peg in pegs) {
      if (!aim.contains(peg)) return ('lift', peg);
    }
    for (final peg in aim) {
      if (!pegs.contains(peg)) return ('set', peg);
    }
    return null;
  }

  /// The sweep's first landing placing, kept once found.
  static List<Peg>? aimFor(Pegging pegging) {
    final key = '${pegging.pegs}:${pegging.asked}';
    if (!_aims.containsKey(key)) {
      _aims[key] = Rules().landing(pegging.pegs, pegging.asked);
    }
    return _aims[key];
  }

  static final _aims = <String, List<Peg>?>{};
}
