import 'rules.dart';

/// One ask: how big the estate is, and what is wanted of the division.
class Level {
  const Level({
    required this.name,
    required this.estate,
    required this.ways,
    required this.kind,
    required this.note,
  });

  final String name;

  /// How many coins are in the chest.
  final int estate;

  /// How many divisions land it, from the sweep.
  final int ways;

  /// 'level': every scale level; 'long': every scale level with the
  /// longest bond ahead of the shortest, which never happens.
  final String kind;

  /// Something worth knowing, written out by hand.
  final String note;

  bool get winnable => ways > 0;

  /// Whether [purses] land the ask.
  bool meets(List<int> purses) {
    if (!Rules.valid(purses, estate)) return false;
    if (purses.reduce((a, b) => a + b) != estate) return false;
    if (!Rules.allLevel(purses)) return false;
    return kind == 'long' ? purses[2] > purses[0] : true;
  }

  /// The division the pointer works towards, or null when nothing lands
  /// the ask.
  List<int>? get aim => winnable ? Rules.division(estate) : null;

  /// The fewest taps the ask takes from an empty board.
  int? get fewest {
    final want = aim;
    if (want == null) return null;
    var taps = 0;
    for (final coins in want) {
      taps += Rules.taps(coins);
    }
    return taps;
  }

  /// How many ways the coins can go into the three purses at all.
  int get divisions => Rules.howManyDivisions(estate);

  /// The task, told in words for the ledger.
  String get task => kind == 'long'
      ? 'divide $estate coins with every scale level and the longest bond '
          'ahead of the shortest'
      : 'divide $estate coins so that every scale hangs level';
}
