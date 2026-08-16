import 'frac.dart';
import 'rules.dart';

/// One ask: where the point is to stand, and what the feet are to do.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'quarter': the feet's triangle a quarter of the whole; 'fifth': a
  /// fifth; 'middle': the point on the rim and the feet's line through
  /// the middle; 'level': the feet's line level; 'off': the point off
  /// the rim and the feet in a line, which never happens.
  final String kind;

  /// How many settings land it, from the sweep: a triangle of rim pegs
  /// and a point of the field not a corner.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the triangle [t] with the point [p] lands the ask.
  bool meets(List<Peg> t, Peg p) {
    if (t.length != 3 || t.toSet().length != 3 || !t.every(Rules.onRim) || !Rules.inField(p) || t.contains(p)) return false;
    switch (kind) {
      case 'quarter':
        return Rules.ratioByFeet(t, p) == Frac.of(1, 4);
      case 'fifth':
        return Rules.ratioByFeet(t, p) == Frac.of(1, 5);
      case 'middle':
        final line = Rules.simsonLine(t, p);
        return Rules.onRim(p) && line != null && Rules.through(line, (Frac.zero, Frac.zero));
      case 'level':
        final line = Rules.simsonLine(t, p);
        return Rules.onRim(p) && line != null && Rules.level(line);
      default:
        return !Rules.onRim(p) && Rules.simsonLine(t, p) != null;
    }
  }

  /// The setting the pointer works towards, the sweep's first that lands
  /// the ask, or null; found once and kept.
  (List<Peg>, Peg)? get aim {
    if (!_aims.containsKey(name)) {
      (List<Peg>, Peg)? found;
      outer:
      for (final t in Rules.triangles) {
        for (final p in Rules.field) {
          if (meets(t, p)) {
            found = (t, p);
            break outer;
          }
        }
      }
      _aims[name] = found;
    }
    return _aims[name];
  }

  static final _aims = <String, (List<Peg>, Peg)?>{};

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'quarter':
        return 'set a triangle on the rim and a point whose feet make a quarter of it';
      case 'fifth':
        return 'set a triangle on the rim and a point whose feet make a fifth of it';
      case 'middle':
        return 'set a triangle on the rim and a rim point whose feet lie in a line through the middle';
      case 'level':
        return 'set a triangle on the rim and a rim point whose feet lie in a level line';
      default:
        return 'set a triangle on the rim and a point off the rim whose feet lie in a line';
    }
  }
}
