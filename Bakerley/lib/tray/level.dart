import 'rules.dart';

/// One ask: a tray to fill with a bag of fours.
class Level {
  const Level({
    required this.name,
    required this.width,
    required this.height,
    required this.counts,
    required this.ways,
    required this.note,
  });

  final String name;
  final int width;
  final int height;

  /// How many of each kind, bar, square, tee, skew, elbow.
  final List<int> counts;

  /// How many fillings there are, from the search.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  int get pieces => counts.fold(0, (a, b) => a + b);

  bool get winnable => ways > 0;

  /// Whether [laid] fills the tray: every four laid and every cell once,
  /// which with the cells adding up is every four laid inside with no
  /// two on a cell.
  bool meets(List<(int, int, int, int)> laid) {
    if (laid.length != pieces) return false;
    final grid = List.generate(height, (_) => List.filled(width, 0));
    for (final (k, o, x0, y0) in laid) {
      for (final c in Rules.orientations(k)[o]) {
        final x = x0 + c.$1, y = y0 + c.$2;
        if (x < 0 || y < 0 || x >= width || y >= height) return false;
        grid[y][x]++;
      }
    }
    return grid.every((row) => row.every((c) => c == 1));
  }

  /// The bag, told: 'four tees', 'two tees, two skews and an elbow'.
  String get bag {
    final parts = <String>[];
    for (var k = 0; k < Rules.kinds.length; k++) {
      final n = counts[k];
      if (n == 0) continue;
      final name = Rules.kindNames[k];
      parts.add(n == 1 ? (name == 'elbow' ? 'an elbow' : 'a $name') : '${_told(n)} ${name}s');
    }
    if (parts.length == 1) return parts.first;
    return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
  }

  /// The task, told in words for the ledger.
  String get task => 'fill the ${_told(width)}-by-${_told(height)} tray with $bag';

  static String _told(int n) => switch (n) {
        2 => 'two',
        3 => 'three',
        4 => 'four',
        5 => 'five',
        6 => 'six',
        _ => '$n',
      };
}
