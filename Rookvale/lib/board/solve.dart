import 'board.dart';

/// What a search found on a board.
class Ways {
  const Ways({required this.count, required this.first, required this.looked});

  /// How many ways there are to finish it. The number that matters: one is a
  /// puzzle, nought is a mistake, and six is a board with nothing to work
  /// out.
  final int count;

  /// One of them, if there is one — the first the search came to.
  final List<Move> first;

  /// How many positions it looked at. Only for the tools.
  final int looked;

  bool get canBeDone => count > 0;
  bool get isOnlyOne => count == 1;
}

/// Counts the ways a board can be finished.
///
/// Every move takes a piece off, so no line of play can be longer than the
/// number of pieces and no position can come round again. That means there is
/// nothing to guard against and nothing to prune: the whole tree is small
/// enough to walk, and walking all of it is the only way to answer the
/// question the puzzles are built on — not "can this be done" but "is there
/// more than one way".
Ways waysThrough(Board board, {int give = 4000000}) {
  var count = 0;
  var looked = 0;
  List<Move>? first;
  final line = <Move>[];

  void walk(Board here) {
    if (++looked > give) return;
    if (here.isDone) {
      count++;
      first ??= List.of(line);
      return;
    }
    for (final move in here.moves) {
      line.add(move);
      walk(here.after(move));
      line.removeLast();
    }
  }

  walk(board);
  return Ways(count: count, first: first ?? const [], looked: looked);
}
