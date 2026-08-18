import 'rules.dart';

/// One ask: hold the runs on the fence inside given lengths.
class Level {
  const Level({
    required this.name,
    required this.climbCap,
    required this.dropCap,
    this.matched = false,
    required this.aim,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// The longest climb the fence is allowed. Ten is no limit at all.
  final int climbCap;

  /// The longest drop the fence is allowed.
  final int dropCap;

  /// Whether the two longest runs are also wanted at the same length.
  final bool matched;

  /// The fence the pointer walks to. It lands the ask, and no fence that
  /// lands the ask is fewer moves from the opening, so following the
  /// pointer from the start costs [fewest] and nothing costs less.
  final List<int> aim;

  /// How many of the 3,628,800 fences land it. The sweep's number, and the
  /// checker refuses the bake if it drifts.
  final int ways;

  /// The moves from the opening to the nearest fence that lands it; null
  /// when none does.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether this fence lands the ask.
  bool meets(List<int> fence) {
    final climb = Rules.longestClimb(fence);
    if (climb > climbCap) return false;
    final drop = Rules.longestDrop(fence);
    if (drop > dropCap) return false;
    return !matched || climb == drop;
  }

  static const _words = [
    'none', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
    'nine', 'ten', 'eleven',
  ];

  /// The task, told in words.
  String get task {
    final wants = <String>[
      if (climbCap < Rules.palings) 'no climb runs to ${_words[climbCap + 1]}',
      if (dropCap < Rules.palings) 'no drop runs to ${_words[dropCap + 1]}',
      if (matched) 'the longest climb and the longest drop come out the same '
          'length',
    ];
    return 'slide the palings about until ${wants.join(' and ')}';
  }
}
