import 'cording.dart';
import 'rules.dart';

/// A cording being pegged. Every state is a fresh value, and the one
/// before hangs on for take-back.
class Play {
  Play._(this.cording, this.pegs, this.moves, this.before);

  factory Play.of(Cording cording) => Play._(cording, List.of(cording.given), 0, null);

  /// A play stood at a set of pegs, for the mark and the tests.
  factory Play.standing(Cording cording, List<Peg> pegs) =>
      Play._(cording, List.of(pegs), pegs.length, null);

  final Cording cording;

  /// The pegs corded, in the order tapped.
  final List<Peg> pegs;

  /// Pegs set and lifted, counted together.
  final int moves;

  final Play? before;

  /// The line past which the hopeless cording admits it.
  static const gaveUpAt = 12;

  bool get full => pegs.length == cording.pegs;

  bool get isDone => full && cording.meets(pegs);

  bool get gaveUp => !cording.winnable && moves >= gaveUpAt && !isDone;

  bool get isOver => isDone || gaveUp;

  bool isGiven(Peg peg) => cording.given.contains(peg);

  /// The square corners as they stand, three pegs corded.
  List<int> get squareCorners => pegs.length == 3 ? Rules.squareCorners(pegs) : const [];

  /// Taps a rim peg: cords it, or lifts it when corded and not given.
  Play tap(Peg peg) {
    if (isOver || !Rules.pegs.contains(peg)) return this;
    if (pegs.contains(peg)) {
      if (isGiven(peg)) return this;
      return Play._(cording, [for (final p in pegs) if (p != peg) p], moves + 1, this);
    }
    if (full) return this;
    return Play._(cording, [...pegs, peg], moves + 1, this);
  }

  Play get back => before ?? this;

  /// What the show-me points at: ('lift', peg) for a peg off the aim,
  /// or ('set', peg) for the next; null when nothing lands.
  (String, Peg)? get next {
    if (isOver || !cording.winnable) return null;
    final aim = aimFor(cording);
    if (aim == null) return null;
    for (final peg in pegs) {
      if (!aim.contains(peg)) return ('lift', peg);
    }
    for (final peg in aim) {
      if (!pegs.contains(peg)) return ('set', peg);
    }
    return null;
  }

  /// The sweep's first landing set that honours the given pegs.
  static List<Peg>? aimFor(Cording cording) {
    if (_aims.containsKey(cording.name)) return _aims[cording.name];
    List<Peg>? found;
    void consider(List<Peg> set) {
      if (found != null) return;
      if (!cording.given.every(set.contains)) return;
      if (cording.meets(set)) found = List.of(set);
    }

    if (cording.pegs == 3) {
      Rules.triples(consider);
    } else {
      Rules.quads(consider);
    }
    _aims[cording.name] = found;
    return found;
  }

  static final _aims = <String, List<Peg>?>{};
}
