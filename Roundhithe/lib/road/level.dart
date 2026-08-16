import 'rules.dart';

/// One ask: how the roads are to stand.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'ring': six roads and a round trip; 'trios': every village two
  /// roads and no round trip; 'nine': every village three roads;
  /// 'eleven': eleven roads and no round trip; 'dirac': every village
  /// three roads or more and no round trip.
  final String kind;

  /// How many road-plans land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the road-plan [mask] lands the ask.
  bool meets(int mask) {
    switch (kind) {
      case 'ring':
        return Rules.roads(mask) == 6 && Rules.tripByTable(mask);
      case 'trios':
        return Rules.degrees(mask).every((d) => d == 2) && !Rules.tripByTable(mask);
      case 'nine':
        return Rules.degrees(mask).every((d) => d == 3);
      case 'eleven':
        return Rules.roads(mask) == 11 && !Rules.tripByTable(mask);
      default:
        return Rules.dirac(mask) && !Rules.tripByTable(mask);
    }
  }

  /// The road-plan the pointer works towards, the sweep's first that
  /// lands the ask, or null.
  int? get aim {
    for (var mask = 0; mask < Rules.plans; mask++) {
      if (meets(mask)) return mask;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'ring':
        return 'lay six roads with a round trip through all six villages';
      case 'trios':
        return 'give every village two roads and no round trip';
      case 'nine':
        return 'give every village three roads exactly';
      case 'eleven':
        return 'lay eleven roads and no round trip';
      default:
        return 'give every village three roads or more and no round trip';
    }
  }
}
