import 'frac.dart';
import 'rules.dart';

/// One ask: a count of tags to dial, for the chance it makes.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.chance,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'exactly': the chance is [chance]; 'atLeast': the chance is at
  /// least [chance]; 'half': the chance is a half.
  final String kind;

  final (int, int)? chance;

  /// How many tag counts land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  Frac get want => kind == 'half' ? Frac.of(1, 2) : Frac.of(chance!.$1, chance!.$2);

  /// Whether [k] tags land the ask.
  bool meets(int k) {
    if (k < 1 || k > Rules.most) return false;
    final p = Rules.chanceByForm(k);
    switch (kind) {
      case 'exactly':
        return p == want;
      case 'atLeast':
        return p.compareTo(want) >= 0;
      default:
        return p == want;
    }
  }

  /// The tag count the pointer dials towards, the sweep's first, or null.
  int? get aim {
    for (var k = 1; k <= Rules.most; k++) {
      if (meets(k)) return k;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'exactly':
        return 'dial the tags so that the chance of two boys is ${chance!.$1} in ${chance!.$2}';
      case 'atLeast':
        return 'dial the tags so that the chance of two boys is at least ${chance!.$1} in ${chance!.$2}';
      default:
        return 'dial the tags so that the chance of two boys is a half';
    }
  }
}
