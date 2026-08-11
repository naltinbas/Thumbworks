import 'rules.dart';

/// One board of lamps as it ships.
class Wick {
  const Wick({
    required this.name,
    required this.rows,
    required this.cols,
    required this.lit,
    required this.fewest,
    required this.ways,
    this.note,
  });

  final String name;
  final int rows;
  final int cols;

  /// The lamps lit at the start, as a bitmask.
  final int lit;

  /// The fewest presses that darken it, or null for a board that
  /// cannot go dark at all.
  final int? fewest;

  /// How many press-sets darken it. Nought for the dead one.
  final int ways;

  final String? note;

  bool get winnable => fewest != null;

  int get lamps => Rules.weigh(lit);
}
