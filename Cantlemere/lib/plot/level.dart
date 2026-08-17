import 'rules.dart';

/// One ask: how many plots the field is to be cut into, and whether they
/// all have to be the same size.
class Level {
  const Level({
    required this.name,
    required this.pieces,
    required this.even,
    required this.ways,
    required this.fewest,
    required this.note,
  });

  final String name;

  /// How many plots the cut is to have.
  final int pieces;

  /// Whether every plot has to be the same size.
  final bool even;

  /// How many cuts land it. The sweep's number, and the checker refuses
  /// the bake if it drifts.
  final int ways;

  /// The taps from the empty field to the nearest cut that lands it;
  /// null when none does. Three pegs make a plot, so it is three times
  /// the plots and never a search.
  final int? fewest;

  /// Something worth knowing, written out by hand.
  final String note;

  /// The size every plot would have to be, in half acres, when the ask
  /// wants them equal.
  int get share => Rules.field ~/ pieces;

  /// Whether the field even divides into this many equal plots.
  bool get shares => Rules.field % pieces == 0;

  bool get winnable => ways > 0;

  /// Whether these laid plots land the ask.
  bool meets(List<int> laid) {
    if (laid.length != pieces) return false;
    if (!Rules.cuts([for (final p in laid) Rules.plots[p]])) return false;
    if (!even) return true;
    for (final p in laid) {
      if (Rules.halves(Rules.plots[p]) != share) return false;
    }
    return true;
  }

  /// The task, told in words.
  String get task => even
      ? 'cut the field into $pieces plots of the same size'
      : 'cut the field into $pieces plots';
}
