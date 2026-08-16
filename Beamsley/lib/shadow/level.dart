import 'rules.dart';

/// One ask: where the triangle stands, how far the shadows are cast,
/// and what the axis is to do.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'whole': the three meetings all on peg places; 'level': the axis
  /// level; 'infinity': all three meetings far off, the axis the line at
  /// infinity; 'lantern': the axis through the lantern; 'crooked': the
  /// three meetings not in a line, which they always are.
  final String kind;

  /// How many settings land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the triangle [t] cast by [casts] lands the ask.
  bool meets(List<Peg> t, List<int> casts) {
    if (!Rules.valid(t) || casts.length != 3 || !casts.every(Rules.casts.contains)) return false;
    final m = Rules.meetings(t, casts);
    switch (kind) {
      case 'whole':
        return m.every((h) => h.$3 != 0 && h.$1 % h.$3 == 0 && h.$2 % h.$3 == 0);
      case 'level':
        final axis = Rules.axis(m);
        return axis != null && axis.$1 == 0 && axis.$2 != 0;
      case 'infinity':
        return m.every(Rules.atInfinity);
      case 'lantern':
        final axis = Rules.axis(m);
        return axis != null && axis.$3 == 0 && !(axis.$1 == 0 && axis.$2 == 0);
      default:
        return !Rules.inLine(m);
    }
  }

  /// The setting the pointer works towards, the sweep's first that lands
  /// the ask, or null; found once and kept.
  (List<Peg>, List<int>)? get aim {
    if (!_aims.containsKey(name)) {
      (List<Peg>, List<int>)? found;
      outer:
      for (final a in Rules.pegs) {
        for (final b in Rules.pegs) {
          if (b == a) continue;
          for (final c in Rules.pegs) {
            if (c == a || c == b) continue;
            final t = [a, b, c];
            if (Rules.flat(t)) continue;
            for (final ta in Rules.casts) {
              for (final tb in Rules.casts) {
                for (final tc in Rules.casts) {
                  if (meets(t, [ta, tb, tc])) {
                    found = (t, [ta, tb, tc]);
                    break outer;
                  }
                }
              }
            }
          }
        }
      }
      _aims[name] = found;
    }
    return _aims[name];
  }

  static final _aims = <String, (List<Peg>, List<int>)?>{};

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'whole':
        return 'set the pegs and the casts so that the three meetings all fall on peg places';
      case 'level':
        return 'set the pegs and the casts so that the axis lies level';
      case 'infinity':
        return 'set the pegs and the casts so that all three meetings are far off and the axis is the line at infinity';
      case 'lantern':
        return 'set the pegs and the casts so that the axis runs through the lantern';
      default:
        return 'set the pegs and the casts so that the three meetings do not lie on one line';
    }
  }
}
