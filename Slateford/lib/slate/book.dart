import 'rules.dart';

/// The book: the eight rules of Newell and Simon, tried in order,
/// the first that speaks decides. It searches nothing, and the tree
/// is held to it in the checker.
class Book {
  static const rules = [
    'win',
    'block',
    'fork',
    'block the fork',
    'centre',
    'opposite corner',
    'corner',
    'side',
  ];

  /// The book's move on a slate that is not over, with the rule
  /// that spoke.
  static (int, String) advise(Board b) {
    final me = Rules.toMove(b);
    final them = 3 - me;

    final wins = Rules.winningCells(b, me);
    if (wins.isNotEmpty) return (wins.first, 'win');

    final blocks = Rules.winningCells(b, them);
    if (blocks.isNotEmpty) return (blocks.first, 'block');

    final forks = Rules.forkCells(b, me);
    if (forks.isNotEmpty) return (forks.first, 'fork');

    final theirForks = Rules.forkCells(b, them);
    if (theirForks.isNotEmpty) {
      // A threat they must answer, so long as answering it gives them
      // no fork; best of all a threat that sits on their fork itself.
      int? safeThreat;
      for (final c in Rules.empties(b)) {
        final after = Rules.played(b, c, me);
        final threats = Rules.winningCells(after, me);
        if (threats.length != 1) continue;
        final blocked = Rules.played(after, threats.first, them);
        if (Rules.winningCells(blocked, them).length >= 2) continue;
        if (theirForks.contains(c)) return (c, 'block the fork');
        safeThreat ??= c;
      }
      if (safeThreat != null) return (safeThreat, 'block the fork');
      return (theirForks.first, 'block the fork');
    }

    if (b[Rules.centre] == 0) return (Rules.centre, 'centre');

    for (final c in Rules.corners) {
      if (b[c] == them && b[8 - c] == 0) return (8 - c, 'opposite corner');
    }

    for (final c in Rules.corners) {
      if (b[c] == 0) return (c, 'corner');
    }

    for (final c in Rules.sides) {
      if (b[c] == 0) return (c, 'side');
    }
    throw StateError('the slate is full');
  }

  static int move(Board b) => advise(b).$1;
}
