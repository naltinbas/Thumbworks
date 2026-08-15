import 'rules.dart';

/// One ask on the sham: what the year is to have, and what the sweep
/// found.
class Level {
  const Level({
    required this.name,
    required this.count,
    this.month,
    required this.ways,
    required this.kinds,
    this.startDay = 0,
    this.note,
  });

  final String name;

  /// How many Fridays the thirteenth the year is to have, or -1 when a
  /// month is asked instead.
  final int count;

  /// The month whose thirteenth is to be a Friday, when that is asked.
  final int? month;

  /// Kinds of year meeting the ask, by the sweep; nought for the
  /// hopeless.
  final int ways;

  /// Kinds of year, all of them: fourteen.
  final int kinds;

  /// The day the year begins on when the ask opens, nought for Monday,
  /// chosen so the year does not meet the ask before a tap.
  final int startDay;

  /// One thing worth knowing about this ask, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => const Rules();

  /// Whether a year with these Friday months meets the ask.
  bool meets(List<int> fridays) => month != null ? fridays.contains(month) : fridays.length == count;

  static const _words = {0: 'no', 1: 'exactly one', 2: 'exactly two', 3: 'exactly three'};

  /// The task, told in words for the ledger.
  String get task => month != null
      ? 'set the year so the thirteenth of ${Rules.months[month!]} is a Friday'
      : 'set the year so it has ${_words[count]} Friday${count == 1 || count == 0 ? '' : 's'} the thirteenth';
}
