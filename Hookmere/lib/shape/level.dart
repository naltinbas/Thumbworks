import 'rules.dart';

/// One ask: how many fillings the staircase is to have.
class Level {
  const Level({
    required this.name,
    required this.fillings,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// The number of fillings the ask wants; 0 for the ask that wants a
  /// staircase the hooks get wrong.
  final int fillings;

  /// How many staircases land it, from the sweep.
  final int ways;

  /// The fewest moves it takes from the opening; null when no
  /// staircase lands it.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether the staircase lands the ask.
  bool meets(List<int> rows) {
    if (!Rules.valid(rows)) return false;
    if (!winnable) return Rules.byCounting(rows) != Rules.byHooks(rows);
    return Rules.byHooks(rows) == fillings;
  }

  /// The task, told in words.
  String get task => winnable
      ? 'lay the eight boxes in a staircase with exactly $fillings '
          '${fillings == 1 ? 'filling' : 'fillings'}'
      : 'lay the eight boxes in a staircase the hooks get wrong';
}
