import 'frac.dart';
import 'rules.dart';

/// One ask: how two chords are to cross.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.power,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'middle': the crossing at the middle; 'power': the pieces multiply
  /// to [power] each; 'halved': one chord cut in half, away from the
  /// middle; 'differ': the two products differ.
  final String kind;

  final int? power;

  /// How many crossings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether chords ab and cd, crossing at [p], land the ask.
  bool meets(Peg a, Peg b, Peg c, Peg d) {
    final p = Rules.crossing(a, b, c, d);
    if (p == null) return false;
    switch (kind) {
      case 'middle':
        return Rules.isMiddle(p);
      case 'power':
        return Rules.power(p) == Frac.of(power!);
      case 'halved':
        return !Rules.isMiddle(p) && (Rules.halves(p, a, b) || Rules.halves(p, c, d));
      default:
        return Rules.product(p, a, b) != Rules.product(p, c, d);
    }
  }

  /// The pegs the pointer works towards, the sweep's first crossing
  /// that lands the ask, as the four pegs in order, or null.
  List<int>? get aim {
    for (final ((a, b), (c, d)) in Rules.crossings) {
      if (meets(Rules.pegs[a], Rules.pegs[b], Rules.pegs[c], Rules.pegs[d])) return [a, b, c, d];
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'middle':
        return 'set two chords that cross at the middle of the wheel';
      case 'power':
        return 'set two chords whose pieces multiply to $power on each';
      case 'halved':
        return 'set two chords so that one cuts the other in half, away from the middle';
      default:
        return 'set two chords whose products of pieces differ';
    }
  }
}
