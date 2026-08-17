import 'rules.dart';

/// One ask: what the rule for walking away is to do over the 32 runs.
class Level {
  const Level({
    required this.name,
    required this.kind,
    required this.ways,
    required this.aim,
    required this.note,
  });

  final String name;

  /// 'half': ahead on more than half the runs; 'onedown': every run
  /// ends one up or one down; 'twointhree': ahead on at least 22 runs;
  /// 'guarded': ahead on at least 20 and never more than two down;
  /// 'sure': never behind and sometimes ahead, which never happens.
  final String kind;

  /// How many rules land it, from the sweep.
  final int ways;

  /// The cheapest rule that lands it, as standings to mark; null when
  /// none does.
  final List<(int, int)>? aim;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  Set<String> get aimMarks =>
      {for (final at in aim ?? const <(int, int)>[]) Rules.mark(at)};

  /// Whether the rule lands the ask.
  bool meets(Set<String> stop) {
    final ends = Rules.ends(stop);
    switch (kind) {
      case 'half':
        return Rules.aheadIn(ends) > Rules.runs ~/ 2;
      case 'onedown':
        return ends.every((end) => end == 1 || end == -1);
      case 'twointhree':
        return Rules.aheadIn(ends) >= 22;
      case 'guarded':
        return Rules.aheadIn(ends) >= 20 && Rules.worstIn(ends) >= -2;
      default:
        return Rules.worstIn(ends) >= 0 && Rules.bestIn(ends) > 0;
    }
  }

  /// The marks the cheapest rule takes.
  int? get fewest => aim?.length;

  /// The task, told in words.
  String get task => switch (kind) {
        'half' => 'mark a rule that walks away ahead on more than half the '
            '32 runs',
        'onedown' => 'mark a rule that walks away one up or one down on '
            'every run, and nothing else',
        'twointhree' => 'mark a rule that walks away ahead on at least 22 of '
            'the 32 runs',
        'guarded' => 'mark a rule that walks away ahead on at least 20 runs '
            'and never more than two down',
        _ => 'mark a rule that never walks away behind and sometimes walks '
            'away ahead',
      };
}
