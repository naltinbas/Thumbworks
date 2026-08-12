/// One moor, as it ships.
class Moor {
  const Moor({
    required this.name,
    required this.russet,
    required this.olive,
    required this.slate,
    required this.fewest,
    this.note,
  });

  final String name;

  /// The herds at the start.
  final int russet;
  final int olive;
  final int slate;

  /// The fewest meetings to a settled moor, or null where the
  /// differences forbid it.
  final int? fewest;

  final String? note;

  bool get winnable => fewest != null;

  int get total => russet + olive + slate;

  (int, int, int) get herds => (russet, olive, slate);
}
