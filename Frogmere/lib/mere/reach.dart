import 'rules.dart';

/// One reach on the sham: the row aimed at, the frogs set down,
/// and what the count found.
class Reach {
  const Reach({
    required this.name,
    required this.reach,
    required this.army,
    required this.roads,
    required this.leaps,
    this.note,
  });

  final String name;
  final int reach;
  final List<Pad> army;

  /// Roads to the aim, by the count; nought for the hopeless.
  final int roads;

  /// The fewest leaps that land, or nought when none do.
  final int leaps;

  /// One thing worth knowing about this reach, said by the why.
  final String? note;

  bool get winnable => roads > 0;

  static const _rows = {
    1: 'first',
    2: 'second',
    3: 'third',
    4: 'fourth',
    5: 'fifth',
  };

  /// The task, told in words for the ledger.
  String get task =>
      'leap a frog to the ${_rows[reach]} reach with ${army.length} frogs';
}
