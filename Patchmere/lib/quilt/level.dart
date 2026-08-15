/// One quilt on the sham: its size, who sews first, and what the
/// walk against the house found.
class Level {
  const Level({
    required this.name,
    required this.rows,
    required this.cols,
    required this.youFirst,
    required this.ways,
    required this.games,
    this.note,
  });

  final String name;
  final int rows;
  final int cols;

  /// Whether you sew the first patch; otherwise the house does.
  final bool youFirst;

  /// Games against the house you win, by the walk of every one.
  final int ways;

  /// Games against the house from this quilt, every way you can sew.
  final int games;

  /// One thing worth knowing about this quilt, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {2: 'two', 3: 'three', 4: 'four', 5: 'five', 6: 'six'};

  /// The task, told in words for the ledger.
  String get task =>
      'sew last on the ${_words[rows]}-by-${_words[cols]} quilt, '
      '${youFirst ? 'sewing first' : 'sewing second'}';
}
