import 'rules.dart';

/// One ask: which trios to pick.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.note,
  });

  final String name;

  /// 'ten': ten trios every two sharing a friend; 'star': ten sharing,
  /// all holding one friend; 'even': ten sharing, every friend in five;
  /// 'fifteen': fifteen trios with five pairs apart and no more;
  /// 'eleven': eleven trios every two sharing a friend.
  final String kind;

  /// How many families land it, from the sweep.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the family [family] lands the ask.
  bool meets(int family) {
    final n = Rules.size(family);
    switch (kind) {
      case 'ten':
        return n == 10 && Rules.sharing(family);
      case 'star':
        return n == 10 && Rules.sharing(family) && Rules.star(family) != null;
      case 'even':
        return n == 10 && Rules.sharing(family) && Rules.hands(family).every((h) => h == 5);
      case 'fifteen':
        return n == 15 && Rules.apart(family).length == 5;
      default:
        return n == 11 && Rules.sharing(family);
    }
  }

  /// The family the pointer works towards, the sweep's first that lands
  /// the ask, or null.
  int? get aim {
    for (var family = 0; family < Rules.families; family++) {
      if (meets(family)) return family;
    }
    return null;
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'ten':
        return 'pick ten trios so that every two share a friend';
      case 'star':
        return 'pick ten trios all holding one friend';
      case 'even':
        return 'pick ten trios so that every two share a friend and every friend is in five';
      case 'fifteen':
        return 'pick fifteen trios with only five pairs apart';
      default:
        return 'pick eleven trios so that every two share a friend';
    }
  }
}
