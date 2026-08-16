import 'frac.dart';
import 'rules.dart';

/// One ask: how the line is to cut the triangle.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'two': two sides cut inside; 'middle': AB cut at its middle;
  /// 'whole': all three crossings on pegs; 'twice': BD twice DC;
  /// 'three': all three sides cut inside.
  final String kind;

  /// How many lines land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the line through p and q lands the ask; it must cross all
  /// three side-lines.
  bool meets(Peg p, Peg q) {
    if (!Rules.crossesAll(p, q)) return false;
    final (f, d, e) = Rules.crossings(p, q);
    switch (kind) {
      case 'two':
        return Rules.sidesInside(p, q) == 2;
      case 'middle':
        return f.$1 == Frac.of(6);
      case 'whole':
        return f.$1.isWhole && d.$1.isWhole && e.$2.isWhole;
      case 'twice':
        return Rules.ratiosByCrossings(p, q).$2 == Frac.of(2);
      default:
        return Rules.sidesInside(p, q) == 3;
    }
  }

  /// The pegs the pointer works towards, the sweep's first line that
  /// lands the ask, or null.
  (Peg, Peg)? get aim {
    for (final (p, q) in Rules.lines) {
      if (meets(p, q)) return (p, q);
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'two':
        return 'set a line that cuts two sides of the triangle inside';
      case 'middle':
        return 'set a line that cuts AB at its middle';
      case 'whole':
        return 'set a line whose three crossings all fall on pegs';
      case 'twice':
        return 'set a line that cuts BC twice as far from B as from C';
      default:
        return 'set a line that cuts all three sides inside';
    }
  }
}
