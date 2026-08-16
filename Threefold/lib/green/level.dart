/// One ask: a point of the green to find by its rungs.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'equal': all three rungs alike; 'oneTwoNine': the rungs 1, 2 and 9
  /// in some order; 'edge': on a side, the other two rungs alike;
  /// 'doubles': one rung twice another and the third their sum; 'longer':
  /// the rungs adding to more than the side.
  final String kind;

  /// How many of the 91 points land it, from the sweep.
  final int ways;

  /// The point the pointer works towards, or null.
  final (int, int, int)? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the point lands the ask.
  bool meets((int, int, int) p) {
    final s = [p.$1, p.$2, p.$3]..sort();
    switch (kind) {
      case 'equal':
        return s[0] == s[2];
      case 'oneTwoNine':
        return s[0] == 1 && s[1] == 2 && s[2] == 9;
      case 'edge':
        return s[0] == 0 && s[1] == s[2] && s[1] > 0;
      case 'doubles':
        return s[0] > 0 && s[1] == 2 * s[0] && s[2] == s[0] + s[1];
      default:
        return p.$1 + p.$2 + p.$3 > 12;
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'equal':
        return 'stand where the three distances to the sides are all alike';
      case 'oneTwoNine':
        return 'stand where the three distances are 1, 2 and 9 rungs, in any order';
      case 'edge':
        return 'stand on a side where the two other distances are alike';
      case 'doubles':
        return 'stand where one distance is twice another and the third is the two added';
      default:
        return 'stand where the three distances add up to more than the height';
    }
  }
}
