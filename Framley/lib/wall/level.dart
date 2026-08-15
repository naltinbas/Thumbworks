import 'rules.dart';

/// One ask: a wall to fill with square frames, no two alike.
class Level {
  const Level({
    required this.name,
    required this.width,
    required this.height,
    required this.sizes,
    this.fixed = const {},
    this.smallestOnRim = false,
    required this.ways,
    required this.note,
  });

  final String name;
  final int width;
  final int height;

  /// The frames' sizes, no two alike.
  final List<int> sizes;

  /// Frames hung already, by size, that stay where they are.
  final Map<int, (int, int)> fixed;

  /// Whether the ask wants the smallest frame touching the rim.
  final bool smallestOnRim;

  /// How many hangings fill the wall as asked, from the search.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  bool get winnable => ways > 0;

  int get smallest => sizes.reduce((a, b) => a < b ? a : b);

  int get area => width * height;

  /// Whether [hung], every frame at its corner, lands the ask.
  bool meets(Map<int, (int, int)> hung) {
    if (hung.length != sizes.length) return false;
    if (!smallestOnRim) return true;
    final (x, y) = hung[smallest]!;
    return Rules.touchesRim(width, height, smallest, x, y);
  }

  /// The task, told in words for the ledger.
  String get task {
    final wall = '${_told(width)} by ${_told(height)} wall';
    if (fixed.isNotEmpty) {
      return 'hang the last ${_told(sizes.length - fixed.length)} frames on the $wall, the ${_told(fixed.length)} largest hung already';
    }
    final range = '${sizes.reduce((a, b) => a < b ? a : b)} to ${sizes.reduce((a, b) => a > b ? a : b)}';
    if (smallestOnRim) {
      return 'hang the ${_told(sizes.length)} frames, $range, to fill the $wall with the smallest on the rim';
    }
    return 'hang ${_told(sizes.length)} frames, $range, no two alike, to fill the $wall';
  }

  static String _told(int n) => switch (n) {
        4 => 'four',
        5 => 'five',
        9 => 'nine',
        10 => 'ten',
        32 => 'thirty-two',
        33 => 'thirty-three',
        47 => 'forty-seven',
        61 => 'sixty-one',
        65 => 'sixty-five',
        69 => 'sixty-nine',
        _ => '$n',
      };
}
