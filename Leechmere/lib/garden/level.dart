import 'rules.dart';

/// One ask on the sham: what the year is to show, whether the loads
/// must be equal, and what the sweep found.
class Level {
  const Level({
    required this.name,
    required this.kind,
    this.equalLoads = false,
    required this.ways,
    required this.settings,
    this.note,
  });

  final String name;

  /// What is asked: 'behind' for Ash's year below Birch's, 'level' for
  /// equal, 'far' for Ash a fifth or more below, 'low' for Ash's year
  /// down to two in five.
  final String kind;

  /// Whether both healers must see the same number in each season.
  final bool equalLoads;

  /// Settings meeting the ask, by the sweep; nought for the hopeless.
  final int ways;

  /// Settings of the loads, all of them, or with equal loads only.
  final int settings;

  /// One thing worth knowing about this ask, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => const Rules();

  /// Whether the loads meet the ask.
  bool meets(int a1, int a2, int b1, int b2) {
    if (equalLoads && (a1 != b1 || a2 != b2)) return false;
    final ash = Rules.year(0, a1, a2), birch = Rules.year(1, b1, b2);
    switch (kind) {
      case 'behind':
        return Rules.compare(ash, birch) < 0;
      case 'level':
        return Rules.compare(ash, birch) == 0;
      case 'far':
        // Ash's share plus a fifth is still no more than Birch's.
        return (ash.$1 * 5 + ash.$2) * birch.$2 <= birch.$1 * 5 * ash.$2;
      default:
        return ash.$1 * 5 <= ash.$2 * 2;
    }
  }

  /// The task, told in words for the ledger.
  String get task {
    final what = switch (kind) {
      'behind' => 'Ash cures a smaller share of the year than Birch',
      'level' => 'Ash and Birch cure the same share of the year',
      'far' => 'Ash cures a fifth or more of the year less than Birch',
      _ => 'Ash cures no more than two in five over the year',
    };
    return equalLoads ? 'set the loads, alike for both healers each season, so $what' : 'set the loads so $what';
  }
}
