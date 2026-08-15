/// One lighting on the sham: how many lights, and what the sweep
/// found.
class Lighting {
  const Lighting({
    required this.name,
    required this.count,
    required this.ways,
    required this.shapes,
    this.note,
  });

  final String name;

  /// Lights asked, exactly.
  final int count;

  /// Lightings on the mere that lie still, by the sweep; nought for
  /// the hopeless.
  final int ways;

  /// The shapes among them, up to sliding.
  final int shapes;

  /// One thing worth knowing about this lighting, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {3: 'three', 4: 'four', 5: 'five', 6: 'six', 7: 'seven'};

  /// The task, told in words for the ledger.
  String get task => 'light exactly ${_words[count]} lanterns so the mere lies still';
}
