/// One errand to run, as it ships.
class Errand {
  const Errand({
    required this.name,
    required this.caps,
    required this.ask,
    required this.fewest,
    this.note,
  });

  final String name;

  /// The pails, by capacity in pints.
  final List<int> caps;

  /// The measure some pail must hold.
  final int ask;

  /// The fewest pours from all-dry, or null for an errand no pouring
  /// runs.
  final int? fewest;

  final String? note;

  bool get winnable => fewest != null;
}
