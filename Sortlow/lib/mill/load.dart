/// One load: the turns asked of it, and the digits it opens on.
class Load {
  const Load({
    required this.name,
    required this.asked,
    required this.opens,
    required this.ways,
    this.note,
  });

  final String name;

  /// Turns to the stone asked, exactly.
  final int asked;

  /// The number the dials open on.
  final int opens;

  /// Loads of the sweep that land; nought on the hopeless
  /// load, and the label says so.
  final int ways;

  /// One thing worth knowing about this load, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => asked == 0
      ? 'dial the one number the mill cannot move'
      : 'dial a number exactly $asked turn${asked == 1 ? '' : 's'} '
          'from the stone';
}
