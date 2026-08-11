/// The two answers: the unsowing, and the search.
///
/// Furrows run from the barn outward, numbered from one. A furrow may be
/// sown only when it holds exactly its own number of seeds: they are
/// lifted together and dropped one to each furrow on the way in, the
/// last seed falling into the barn. The tilth is won when every seed is
/// home.
///
/// The unsowing grows winning boards from nothing: to unsow, take one
/// seed from the barn's side of history and run a sowing backwards,
/// choosing the nearest furrow that can have been the source. Each step
/// backwards adds one seed to the board, and the board with n seeds
/// grown this way is the only one of its size that wins. The search
/// checks that the hard way, walking every board there is at each small
/// size and seeing which of them can be played home.
class Rules {
  const Rules._();

  /// The winning board of [seeds] seeds, by unsowing: furrow counts
  /// from furrow one outward, trailing noughts trimmed.
  static List<int> unsown(int seeds) {
    final board = <int>[];
    for (var sown = 0; sown < seeds; sown++) {
      // Reverse a sowing: find the nearest furrow that would be legal
      // to have just sown, which is the nearest with no seeds... the
      // classic step: pick the lowest furrow f with board[f-1] == 0,
      // then set furrow f to f by taking one seed from each nearer
      // furrow and the new seed.
      var furrow = 1;
      while (furrow <= board.length && board[furrow - 1] != 0) {
        furrow++;
      }
      if (furrow > board.length) board.add(0);
      for (var nearer = 1; nearer < furrow; nearer++) {
        board[nearer - 1]--;
      }
      board[furrow - 1] = furrow;
    }
    while (board.isNotEmpty && board.last == 0) {
      board.removeLast();
    }
    return board;
  }

  /// The sowable furrows of a board: those holding exactly their number.
  static List<int> sowable(List<int> board) => [
        for (var furrow = 1; furrow <= board.length; furrow++)
          if (board[furrow - 1] == furrow) furrow,
      ];

  /// The board after sowing [furrow], trailing noughts trimmed.
  static List<int> sown(List<int> board, int furrow) {
    final after = [...board];
    after[furrow - 1] = 0;
    for (var nearer = 1; nearer < furrow; nearer++) {
      after[nearer - 1]++;
    }
    while (after.isNotEmpty && after.last == 0) {
      after.removeLast();
    }
    return after;
  }

  /// Whether a board can be played home, by search.
  static final _memo = <String, bool>{};

  static bool canWin(List<int> board) {
    if (board.isEmpty) return true;
    final key = board.join(',');
    final kept = _memo[key];
    if (kept != null) return kept;
    var won = false;
    for (final furrow in sowable(board)) {
      if (canWin(sown(board, furrow))) {
        won = true;
        break;
      }
    }
    return _memo[key] = won;
  }

  /// Every board of [seeds] seeds across at most [furrows] furrows.
  static Iterable<List<int>> allBoards(int seeds, int furrows) sync* {
    final board = List<int>.filled(furrows, 0);
    Iterable<List<int>> place(int furrow, int left) sync* {
      if (furrow == furrows) {
        if (left == 0) {
          final trimmed = [...board];
          while (trimmed.isNotEmpty && trimmed.last == 0) {
            trimmed.removeLast();
          }
          yield trimmed;
        }
        return;
      }
      for (var put = 0; put <= left; put++) {
        board[furrow] = put;
        yield* place(furrow + 1, left - put);
      }
      board[furrow] = 0;
    }

    yield* place(0, seeds);
  }

  /// The furrows holding more than their number: they can never be sown
  /// again, only gain, and their seeds are trapped. Instant death, and
  /// visible on the board.
  static List<int> overfull(List<int> board) => [
        for (var furrow = 1; furrow <= board.length; furrow++)
          if (board[furrow - 1] > furrow) furrow,
      ];
}
