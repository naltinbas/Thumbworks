import 'rules.dart';

/// One ask: a party to gather, of the fewest guests that make a shared
/// day likely enough, or certain.
class Level {
  const Level({
    required this.name,
    required this.days,
    required this.num,
    required this.den,
    this.strict = false,
    required this.cap,
    required this.ways,
    required this.note,
  });

  final String name;

  /// The days of the year: 365, or 12 months.
  final int days;

  /// The chance asked for, [num]/[den], reached at least, or passed when
  /// [strict].
  final int num;
  final int den;
  final bool strict;

  /// The most guests the dial allows.
  final int cap;

  /// How many settings of the dial land it, from the sweep: one, the
  /// fewest, or none.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  /// The settings of the dial: one guest to [cap].
  int get settings => cap;

  bool get winnable => ways > 0;

  bool get certain => num == den;

  /// Whether [n] guests reach the chance asked.
  bool reaches(int n) {
    final (p, q) = Rules.shared(days, n);
    final lhs = p * BigInt.from(den), rhs = BigInt.from(num) * q;
    return strict ? lhs > rhs : lhs >= rhs;
  }

  /// Whether [n] guests land the ask: they reach it and one fewer do not.
  bool meets(int n) => n >= 1 && n <= cap && reaches(n) && !(n > 1 && reaches(n - 1));

  /// The task, told in words for the ledger.
  String get task {
    final year = days == 12 ? 'of a twelve-month year' : '';
    final what = days == 12 ? 'a shared birth month' : 'a shared birthday';
    if (certain) {
      return cap < days + 1
          ? 'gather fewer than ${cap + 1} guests so that $what is certain'
          : 'gather the fewest guests $year that make $what certain';
    }
    final chance = strict && num * 2 == den
        ? 'more likely than not'
        : 'at least ${_told(num)} in ${_told(den)}';
    return 'gather the fewest guests${year.isEmpty ? '' : ' $year'} that make $what $chance';
  }

  static String _told(int n) => switch (n) {
        9 => 'nine',
        10 => 'ten',
        99 => 'ninety-nine',
        100 => 'a hundred',
        _ => '$n',
      };
}
