import 'rules.dart';

/// One ask: a triangle with a whole area of a given kind.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.areaAsked,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'right': whole area with a right angle; 'area': the area asked
  /// exactly; 'isosceles': whole area, two sides alike, no right angle;
  /// 'scalene': whole area, no two sides alike, no right angle;
  /// 'allOdd': whole area with three odd sides.
  final String kind;
  final int? areaAsked;

  /// How many of the 372 triangles land it, from the sweep.
  final int ways;

  /// The sides the pointer walks to, or null when none lands it.
  final (int, int, int)? aim;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  /// Whether sides [a], [b], [c], in any order, land the ask.
  bool meets(int a, int b, int c) {
    final area = Rules.wholeArea(a, b, c);
    if (area == null) return false;
    switch (kind) {
      case 'right':
        return Rules.isRight(a, b, c);
      case 'area':
        return area == areaAsked;
      case 'isosceles':
        return Rules.isIsosceles(a, b, c) && !Rules.isRight(a, b, c);
      case 'scalene':
        return !Rules.isIsosceles(a, b, c) && !Rules.isRight(a, b, c);
      default:
        return Rules.allOdd(a, b, c);
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    switch (kind) {
      case 'right':
        return 'set the sides so the area is a whole number and one corner is a right angle';
      case 'area':
        return 'set the sides so the area is exactly $areaAsked';
      case 'isosceles':
        return 'set the sides so the area is a whole number, two sides alike, and no corner a right angle';
      case 'scalene':
        return 'set the sides so the area is a whole number, no two sides alike, and no corner a right angle';
      default:
        return 'set the sides so the area is a whole number and all three sides are odd';
    }
  }
}
