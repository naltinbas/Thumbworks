/// One share on the sham: how many tokens, how many powers, and
/// what the sweep found.
class Share {
  const Share({
    required this.name,
    required this.count,
    required this.degrees,
    required this.ways,
    this.note,
  });

  final String name;
  final int count;
  final int degrees;

  /// Shares that land, by the sweep; nought for the hopeless.
  final int ways;

  /// One thing worth knowing about this share, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  int get half => count ~/ 2;

  static const powerNames = ['sums', 'squares', 'cubes'];

  /// The powers asked, in words: 'sums', 'sums and squares', or
  /// 'sums, squares and cubes'.
  String get powers {
    final names = powerNames.sublist(0, degrees);
    if (names.length == 1) return names.first;
    return '${names.sublist(0, names.length - 1).join(', ')} and '
        '${names.last}';
  }

  static const _words = {
    2: 'two',
    4: 'four',
    6: 'six',
    8: 'eight',
  };

  /// The task, told in words for the ledger.
  String get task => 'share the tokens 1 to $count, '
      '${_words[half]} and ${_words[half]}, so the $powers agree';
}
