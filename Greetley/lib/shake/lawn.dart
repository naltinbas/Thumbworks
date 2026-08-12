/// One lawn of the fete: its guests and the odd-handed count
/// asked of it.
class Lawn {
  const Lawn({
    required this.name,
    required this.guests,
    required this.asked,
    required this.ways,
    this.note,
  });

  final String name;

  /// Guests standing on the lawn.
  final int guests;

  /// Odd-handed guests asked, exactly.
  final int asked;

  /// Lawns of the sweep that land it; nought on the hopeless
  /// lawn, and the label says so.
  final int ways;

  /// One thing worth knowing about this lawn, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => 'shake hands among $guests guests until '
      'exactly $asked ${asked == 1 ? 'is' : 'are'} odd-handed';
}
