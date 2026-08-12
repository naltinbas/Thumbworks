/// One hall: its corners, and how many wards the watch is asked to
/// stand.
class Hall {
  const Hall({
    required this.name,
    required this.corners,
    required this.asked,
    required this.fewest,
    this.note,
  });

  final String name;

  /// The corners in order, winding counterclockwise.
  final List<(int, int)> corners;

  /// Wards allowed. On the hopeless hall this is under the fewest
  /// any watch needs.
  final int asked;

  /// The fewest wards that light the whole floor, by the sweep.
  final int fewest;

  /// One thing worth knowing about this hall, said by the why.
  final String? note;

  bool get winnable => asked >= fewest;

  /// The task, told in words for the ledger.
  String get task => 'light every flag with $asked '
      'ward${asked == 1 ? '' : 's'}';
}
