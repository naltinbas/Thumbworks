/// One flock: its size, and the crowns asked of the pecking.
class Flock {
  const Flock({
    required this.name,
    required this.chickens,
    required this.asked,
    required this.ways,
    this.note,
  });

  final String name;

  final int chickens;

  /// Kings asked, exactly.
  final int asked;

  /// Peckings of the sweep that land it; nought on the
  /// hopeless flock, and the label says so.
  final int ways;

  /// One thing worth knowing about this flock, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task => asked == chickens
      ? 'settle the pecking of $chickens chickens so every one '
          'is crowned'
      : 'settle the pecking of $chickens chickens so exactly '
          '$asked wear crowns';
}
