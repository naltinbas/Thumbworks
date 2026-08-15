import 'rules.dart';

/// One yard on the sham: its size, how many watchmen to post, and what
/// the walk found.
class Level {
  const Level({
    required this.name,
    required this.size,
    required this.watchmen,
    required this.ways,
    required this.postings,
    this.note,
  });

  final String name;

  /// Flags along a side.
  final int size;

  /// Watchmen to post.
  final int watchmen;

  /// Postings that watch every flag, by the walk; nought for the
  /// hopeless.
  final int ways;

  /// Postings of that many watchmen on the yard, all of them.
  final int postings;

  /// One thing worth knowing about this yard, said by the why.
  final String? note;

  bool get winnable => ways > 0;

  Rules get rules => Rules(size);

  static const _words = {3: 'three', 4: 'four', 5: 'five', 6: 'six', 9: 'nine'};

  static String word(int n) => _words[n] ?? '$n';

  /// The task, told in words for the ledger.
  String get task =>
      'post ${word(watchmen)} watchmen on the ${word(size)} by ${word(size)} yard so every flag is watched';
}
