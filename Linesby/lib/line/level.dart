import 'rules.dart';

/// One ask: where the three centres are to stand.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'right': the orthocentre on a corner; 'level': the three centres
  /// at one height; 'off': the circumcentre off the field; 'whole': all
  /// three centres on pegs; 'one': all three centres one point.
  final String kind;

  /// How many triangles of the field land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the triangle a b c lands the ask; the pegs must not lie
  /// in a line.
  bool meets(Peg a, Peg b, Peg c) {
    if (Rules.inLine(a, b, c)) return false;
    final g = Rules.centroid(a, b, c), o = Rules.circumcentre(a, b, c), h = Rules.orthocentre(a, b, c);
    switch (kind) {
      case 'right':
        return Rules.rightAt(a, b, c) != null;
      case 'level':
        return g.$2 == o.$2 && o.$2 == h.$2;
      case 'off':
        return !Rules.onField(o);
      case 'whole':
        return Rules.isWhole(g) && Rules.isWhole(o) && Rules.isWhole(h);
      default:
        return g == o && o == h;
    }
  }

  /// The triangle the pointer works towards, the sweep's first, or null.
  (Peg, Peg, Peg)? get aim {
    for (final t in Rules.triangles) {
      if (meets(t.$1, t.$2, t.$3)) return t;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'right':
        return 'set the pegs so the orthocentre sits on a corner of the triangle';
      case 'level':
        return 'set the pegs so the three centres stand at one height, the line through them flat';
      case 'off':
        return 'set the pegs so the circumcentre falls off the field altogether';
      case 'whole':
        return 'set the pegs so all three centres fall on pegs of the field';
      default:
        return 'set the pegs so the three centres are one point';
    }
  }
}
