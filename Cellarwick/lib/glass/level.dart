import 'rules.dart';

/// One ask: a pouring to set the glasses and the spoon for.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'unit': one unit of water ends in the wine; 'tenth': the wine glass
  /// ends one tenth water; 'whole': the water in the wine is a whole
  /// count of units, one or more; 'half': the water glass ends half
  /// wine; 'unequal': the water in the wine outweighs the wine in the
  /// water.
  final String kind;

  /// How many of the settings land it, from the sweep.
  final int ways;

  /// The setting the pointer walks to, (wine, water, spoon), or null.
  final (int, int, int)? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the setting lands the ask, well stirred.
  bool meets(int wine, int water, int spoon) {
    final p = Rules.stirred(wine, water, spoon);
    if (p == null) return false;
    final (waterInWine, wineInWater) = p;
    switch (kind) {
      case 'unit':
        return waterInWine == Frac.one;
      case 'tenth':
        return waterInWine * Frac.of(10) == Frac.of(wine);
      case 'whole':
        return waterInWine.isWhole && waterInWine != Frac.zero;
      case 'half':
        return wineInWater * Frac.of(2) == Frac.of(water);
      default:
        return waterInWine.compareTo(wineInWater) > 0;
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'unit':
        return 'set the glasses and the spoon so exactly one unit of water ends in the wine glass';
      case 'tenth':
        return 'set the glasses and the spoon so the wine glass ends one tenth water';
      case 'whole':
        return 'set the glasses and the spoon so the water in the wine glass comes to whole units';
      case 'half':
        return 'set the glasses and the spoon so the water glass ends half wine';
      default:
        return 'set the glasses and the spoon so more water ends in the wine glass than wine in the water glass';
    }
  }
}
