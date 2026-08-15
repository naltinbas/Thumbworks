import 'rules.dart';

/// One ask: a green of hamlets and lanes to lay out clear.
class Level {
  const Level({
    required this.name,
    required this.kinds,
    required this.lanes,
    required this.size,
    required this.start,
    required this.ways,
    required this.settings,
    required this.note,
  });

  final String name;

  /// Each hamlet's kind, 0 or 1; lanes of a two-kind green run only
  /// between the kinds.
  final List<int> kinds;

  /// The lanes, as pairs of hamlets.
  final List<(int, int)> lanes;

  /// The grid is [size] by [size] points.
  final int size;

  /// Where the hamlets stand when the ask opens.
  final List<(int, int)> start;

  /// How many placings of the hamlets on the grid lay the green clear,
  /// from the sweep, and how many placings there are.
  final int ways;
  final int settings;

  /// Something worth knowing, computed.
  final String note;

  int get hamlets => kinds.length;

  bool get twoKinds => kinds.contains(1);

  bool get winnable => ways > 0;

  /// Euler's ceiling on the lanes for this green's kind.
  int get ceiling => Rules.ceiling(hamlets, twoKinds: twoKinds);

  /// Whether the hamlets at [at] lay the green clear.
  bool meets(List<(int, int)> at) => Rules.clear(lanes, at);

  /// The task, told in words for the ledger.
  String get task {
    switch (name) {
      case 'The Four Hamlets':
        return 'lay the six lanes between four hamlets, each to each, so no two cross';
      case 'The Two and the Three':
        return 'lay the six lanes from each of two hamlets to each of three so no two cross';
      case 'The Five Less One':
        return 'lay nine of the ten lanes between five hamlets, each to each but one pair, so no two cross';
      case 'The Three and the Three Less One':
        return 'lay eight of the nine lanes from each of three hamlets to each of three, one left out, so no two cross';
      default:
        return 'lay the nine lanes from each of three hamlets to each of three so no two cross';
    }
  }
}
