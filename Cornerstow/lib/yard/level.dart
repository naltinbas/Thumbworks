import 'rules.dart';

/// One ask: a square yard to pave with its flags.
class Level {
  const Level({
    required this.name,
    required this.n,
    this.whole = false,
    required this.ways,
    required this.note,
  });

  final String name;

  /// The flags run one of one to n of n.
  final int n;

  /// Whether the even flags come whole, no halves.
  final bool whole;

  /// How many pavings there are, from the search.
  final int ways;

  /// Something worth knowing, computed.
  final String note;

  int get side => Rules.side(n);

  /// The flag kinds: (width, height, size, count).
  List<(int, int, int, int)> get flags => Rules.flags(n, whole: whole);

  int get flagCount => flags.fold(0, (sum, f) => sum + f.$4);

  bool get winnable => ways > 0;

  /// Whether [placements] pave the yard.
  bool meets(List<(int, int, int, int, int)> placements) => placements.length == flagCount && Rules.paves(side, placements);

  /// The task, told in words for the ledger.
  String get task {
    final yard = '${_told(side)}-by-${_told(side)} yard';
    if (whole) return 'pave the $yard with one flag of one and two whole flags of two';
    switch (n) {
      case 2:
        return 'pave the $yard with one flag of one and two of two, the second two cut in halves';
      case 3:
        return 'pave the $yard with one flag of one, two of two and three of three, the second two in halves';
      case 4:
        return 'pave the $yard with the flags of one to four, the second two and the fourth four in halves';
      default:
        return 'pave the $yard with the flags of one to five, the second two and the fourth four in halves';
    }
  }

  static String _told(int n) => switch (n) {
        3 => 'three',
        6 => 'six',
        10 => 'ten',
        15 => 'fifteen',
        _ => '$n',
      };
}
