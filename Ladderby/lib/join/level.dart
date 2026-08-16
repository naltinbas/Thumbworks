import 'frac.dart';
import 'rules.dart';

/// One ask: how the three crossings are to stand.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'level': the three crossings at one height; 'middle': at half
  /// height; 'whole': all three on pegs; 'steep': one above another;
  /// 'bent': not in a line.
  final String kind;

  /// How many hexagons land it, from the sweep, each counted once
  /// whichever way its pegs are named.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the hexagon of [bottom] and [top] lands the ask; the six
  /// cross-joins must all cross.
  bool meets(List<int> bottom, List<int> top) {
    final c = Rules.crossings(bottom, top);
    if (c == null) return false;
    final (x, y, z) = c;
    switch (kind) {
      case 'level':
        return x.$2 == y.$2 && y.$2 == z.$2;
      case 'middle':
        return x.$2 == Frac.of(3) && y.$2 == Frac.of(3) && z.$2 == Frac.of(3);
      case 'whole':
        return [x, y, z].every((p) => p.$1.isWhole && p.$2.isWhole);
      case 'steep':
        return x.$1 == y.$1 && y.$1 == z.$1;
      default:
        return !Rules.inLine(x, y, z);
    }
  }

  /// The pegs the pointer works towards, the sweep's first hexagon that
  /// lands the ask, as (bottom, top), or null.
  (List<int>, List<int>)? get aim {
    for (final bottom in Rules.triples) {
      for (final top in Rules.triples) {
        if (meets(bottom, top)) return (bottom, top);
      }
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'level':
        return 'pick the pegs so that the three crossings stand at one height';
      case 'middle':
        return 'pick the pegs so that the three crossings stand halfway between the rails';
      case 'whole':
        return 'pick the pegs so that the three crossings all fall on pegs';
      case 'steep':
        return 'pick the pegs so that the three crossings stand one above another';
      default:
        return 'pick the pegs so that the three crossings do not lie in a line';
    }
  }
}
