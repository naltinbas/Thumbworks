import 'rules.dart';

/// One supper on the sham: the guests, who quarrels with whom, and what
/// the sweep found.
class Level {
  const Level({
    required this.name,
    required this.guests,
    required this.quarrels,
    required this.ways,
    required this.seatings,
    this.note,
  });

  final String name;
  final int guests;
  final List<Quarrel> quarrels;

  /// Seatings with no quarrel at a table, by the sweep; nought for the
  /// hopeless.
  final int ways;

  /// Seatings of the guests, two tables apiece.
  final int seatings;

  /// One thing worth knowing about this supper, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => Rules(guests, quarrels);

  static const names = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  static const _words = {4: 'four', 5: 'five', 6: 'six', 8: 'eight'};

  /// The task, told in words for the ledger.
  String get task =>
      'seat the ${_words[guests]} guests at two tables with no quarrel at either, ${quarrels.length} quarrels among them';
}
