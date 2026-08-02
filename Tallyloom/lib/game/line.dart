/// What is known about one square.
enum Square {
  /// Nobody has worked it out yet.
  unknown,

  /// Part of the picture.
  filled,

  /// Known not to be part of the picture. A player marks these, because
  /// knowing where the picture is not is most of how you find where it is.
  blank,
}

/// One line, its clue, and everything that follows from the two together.
///
/// This is the whole of nonogram logic. A clue and a partly known line permit
/// some set of arrangements; any square that is filled in every one of them is
/// filled, any square empty in every one of them is empty, and any square that
/// varies is still unknown. Working that out for a line and then for the line
/// crossing it, over and over, is how a nonogram is solved.
///
/// It is done without ever writing an arrangement out. Enumerating them is
/// simple to describe and hopeless on a wide line: a fifteen-wide line can hold
/// thousands of arrangements, and the maker runs this over both directions of
/// every candidate puzzle it tries. Instead the runs are walked once forwards
/// and once backwards, which asks two questions of each place a run could go —
/// can everything before it fit behind, and can everything after it fit ahead —
/// and takes time proportional to the line length times the number of runs.
class Line {
  Line(this.clue, this.squares)
      : _runs = clue.where((run) => run > 0).toList(growable: false);

  /// The numbers beside the line.
  final List<int> clue;

  /// What is known about it, which this reads and does not write.
  final List<Square> squares;

  /// The clue with the nothing-here zero taken out, because `[0]` and `[]` say
  /// the same thing to the arithmetic below and only one of them is easy to
  /// write loops against.
  final List<int> _runs;

  int get length => squares.length;

  /// What follows from the clue, or null if nothing does because no
  /// arrangement fits.
  ///
  /// The list that comes back is the whole line, with every square this can
  /// settle settled and the rest left [Square.unknown].
  List<Square>? deduce() {
    final canFill = List<bool>.filled(length, false);
    final canLeave = List<bool>.filled(length, false);

    // The states worth being in: run [i] is the next one to place, and every
    // square before [start] has been decided.
    var reachable = <int>{0};
    for (var i = 0; i <= _runs.length; i++) {
      final next = <int>{};
      for (final start in reachable) {
        if (i == _runs.length) {
          // Everything is placed, so the rest of the line is empty.
          if (!_couldBeEmpty(start, length)) continue;
          for (var at = start; at < length; at++) {
            canLeave[at] = true;
          }
          continue;
        }
        final run = _runs[i];
        for (var at = start; at + run <= length; at++) {
          // Empty from where we were up to here, the run itself, then a gap
          // after it unless the line ends.
          if (!_couldBeEmpty(start, at)) break;
          if (!_couldBeFilled(at, at + run)) continue;
          final after = at + run;
          if (after < length && squares[after] == Square.filled) continue;
          if (!_fitsAfter(i + 1, after + 1)) continue;

          for (var gap = start; gap < at; gap++) {
            canLeave[gap] = true;
          }
          for (var on = at; on < after; on++) {
            canFill[on] = true;
          }
          if (after < length) canLeave[after] = true;
          next.add(after + 1);
        }
      }
      reachable = next;
      if (reachable.isEmpty) break;
    }

    final settled = List<Square>.filled(length, Square.unknown);
    for (var at = 0; at < length; at++) {
      if (!canFill[at] && !canLeave[at]) return null;
      if (canFill[at] && !canLeave[at]) settled[at] = Square.filled;
      if (canLeave[at] && !canFill[at]) settled[at] = Square.blank;
    }
    return settled;
  }

  /// Whether the runs from [i] on can be fitted into the line from [from].
  ///
  /// Answered by the same walk as [deduce], backwards and memoised, which is
  /// what keeps the whole thing polynomial: without it every place a run might
  /// go would be explored again for every way of reaching it.
  bool _fitsAfter(int i, int from) {
    if (from > length) return i == _runs.length;
    final memo = _fits ??= List<List<bool?>>.generate(
      _runs.length + 1,
      (_) => List<bool?>.filled(length + 2, null),
    );
    final known = memo[i][from];
    if (known != null) return known;

    bool answer;
    if (i == _runs.length) {
      answer = _couldBeEmpty(from, length);
    } else {
      answer = false;
      final run = _runs[i];
      for (var at = from; at + run <= length; at++) {
        if (!_couldBeEmpty(from, at)) break;
        if (!_couldBeFilled(at, at + run)) continue;
        final after = at + run;
        if (after < length && squares[after] == Square.filled) continue;
        if (_fitsAfter(i + 1, after + 1)) {
          answer = true;
          break;
        }
      }
    }
    memo[i][from] = answer;
    return answer;
  }

  List<List<bool?>>? _fits;

  bool _couldBeEmpty(int from, int to) {
    for (var at = from; at < to; at++) {
      if (squares[at] == Square.filled) return false;
    }
    return true;
  }

  bool _couldBeFilled(int from, int to) {
    for (var at = from; at < to; at++) {
      if (squares[at] == Square.blank) return false;
    }
    return true;
  }
}
