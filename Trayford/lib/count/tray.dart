/// One tray on the sham: the row lengths, the leftovers asked, and
/// what the sweep found.
class Tray {
  const Tray({
    required this.name,
    required this.rows,
    required this.asked,
    required this.ways,
    this.note,
  });

  final String name;
  final List<int> rows;
  final List<int> asked;

  /// Counts in the tray that meet the asking, by the sweep; nought
  /// for the hopeless.
  final int ways;

  /// One thing worth knowing about this tray, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  static const _words = {3: 'threes', 4: 'fours', 5: 'fives', 6: 'sixes', 7: 'sevens'};

  /// The task, told in words for the ledger.
  String get task {
    final parts = <String>[];
    for (var i = 0; i < rows.length; i++) {
      parts.add('${asked[i]} over by ${_words[rows[i]]}');
    }
    final told = parts.length == 2
        ? '${parts[0]} and ${parts[1]}'
        : '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
    return 'fill the tray to a count leaving $told';
  }
}
