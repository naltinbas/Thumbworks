/// One party: how many couples dine, and what is given.
class Party {
  const Party({
    required this.name,
    required this.couples,
    this.given,
    required this.ways,
    this.note,
  });

  final String name;

  final int couples;

  /// A husband given in his gap, as (gap, husband), or null.
  final (int, int)? given;

  /// Seatings of the sweep that land; nought on the hopeless
  /// party, and the label says so.
  final int ways;

  /// One thing worth knowing about this party, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  /// The task, told in words for the ledger.
  String get task {
    final host = given == null ? '' : ', the host already seated';
    return 'seat the $couples husbands so no couple sits '
        'together$host';
  }
}
