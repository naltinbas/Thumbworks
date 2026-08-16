import 'frac.dart';
import 'rules.dart';

/// One ask: what the four pegs are to make of the squares.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'whole': every centre on a peg place; 'square': the four centres a
  /// square; 'meeting': the two joins crossing on a peg place; 'fives':
  /// the joins five long; 'skew': the joins unequal or off the right
  /// angle, which they never are.
  final String kind;

  /// How many fours land it, from the sweep, no three pegs in a line.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the four pegs [f] land the ask; a four with three pegs in
  /// a line lands nothing.
  bool meets(List<Peg> f) {
    if (f.length != 4 || f.toSet().length != 4 || Rules.threeInLine(f)) return false;
    switch (kind) {
      case 'whole':
        return Rules.centresWhole(f);
      case 'square':
        return Rules.centresMakeSquare(f);
      case 'meeting':
        final x = Rules.crossing(f);
        return x != null && x.$1.isWhole && x.$2.isWhole;
      case 'fives':
        return Rules.lengthsSquared(f).$1 == Frac.of(25);
      default:
        return !Rules.sameLength(f) || !Rules.atRightAngles(f);
    }
  }

  /// The four the pointer works towards, the sweep's first that lands
  /// the ask, or null; found once and kept.
  List<Peg>? get aim {
    if (!_aims.containsKey(name)) {
      List<Peg>? found;
      Rules.fours((f) {
        if (found == null && meets(f)) found = List.of(f);
      });
      _aims[name] = found;
    }
    return _aims[name];
  }

  static final _aims = <String, List<Peg>?>{};

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'whole':
        return 'set four pegs whose four square-centres all fall on peg places';
      case 'square':
        return 'set four pegs whose four square-centres make a square';
      case 'meeting':
        return 'set four pegs whose two joins cross on a peg place';
      case 'fives':
        return 'set four pegs whose two joins are five long';
      default:
        return 'set four pegs whose two joins differ in length, or miss the right angle';
    }
  }
}
