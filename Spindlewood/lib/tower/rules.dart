import 'dart:typed_data';

/// The arithmetic of the spindles.
///
/// A board is where each round sits: round nought the smallest, each on
/// one of the spindles, the stacking order forced by size. A round may
/// move when nothing smaller sits on it, onto a spindle whose top is
/// larger. Home is the whole tower on the last spindle.
///
/// The fewest moves is known three ways that share nothing: the
/// doubling rule for three spindles, the leapfrog reckoning for four,
/// and a walk of every board there is. The walk is the ground truth
/// the other two are held against, and the game plays from the walk.
class Rules {
  Rules(this.spindles, this.rounds) {
    _walk();
  }

  final int spindles;
  final int rounds;

  int get boards {
    var count = 1;
    for (var round = 0; round < rounds; round++) {
      count *= spindles;
    }
    return count;
  }

  /// Every round on the first spindle.
  int get start => 0;

  /// Every round on the last spindle.
  late final int home = () {
    var board = 0;
    for (var round = rounds - 1; round >= 0; round--) {
      board = board * spindles + (spindles - 1);
    }
    return board;
  }();

  /// Which spindle a round sits on.
  int spindleOf(int board, int round) {
    var at = board;
    for (var below = 0; below < round; below++) {
      at ~/= spindles;
    }
    return at % spindles;
  }

  int _placed(int board, int round, int spindle) {
    var scale = 1;
    for (var below = 0; below < round; below++) {
      scale *= spindles;
    }
    return board + (spindle - spindleOf(board, round)) * scale;
  }

  /// The smallest round on a spindle, or null for a bare one.
  int? topOf(int board, int spindle) {
    for (var round = 0; round < rounds; round++) {
      if (spindleOf(board, round) == spindle) return round;
    }
    return null;
  }

  /// Whether a round may move: nothing smaller on it, and the landing
  /// spindle's top larger, if any.
  bool mayMove(int board, int round, int to) {
    if (round < 0 || round >= rounds || to < 0 || to >= spindles) {
      return false;
    }
    final from = spindleOf(board, round);
    if (from == to) return false;
    if (topOf(board, from) != round) return false;
    final landing = topOf(board, to);
    return landing == null || landing > round;
  }

  int moved(int board, int round, int to) =>
      mayMove(board, round, to) ? _placed(board, round, to) : board;

  /// How many moves each board is from home, walked breadth first.
  late final Uint8List distance;

  void _walk() {
    distance = Uint8List(boards)..fillRange(0, boards, 255);
    distance[home] = 0;
    var edge = [home];
    while (edge.isNotEmpty) {
      final next = <int>[];
      for (final board in edge) {
        for (var round = 0; round < rounds; round++) {
          for (var to = 0; to < spindles; to++) {
            if (!mayMove(board, round, to)) continue;
            final there = moved(board, round, to);
            if (distance[there] != 255) continue;
            distance[there] = distance[board] + 1;
            next.add(there);
          }
        }
      }
      edge = next;
    }
  }

  /// The fewest moves home from a board.
  int fewest(int board) => distance[board];

  /// A move that steps one nearer home: the round and its landing.
  (int, int)? next(int board) {
    final here = distance[board];
    if (here == 0) return null;
    for (var round = 0; round < rounds; round++) {
      for (var to = 0; to < spindles; to++) {
        if (!mayMove(board, round, to)) continue;
        if (distance[moved(board, round, to)] == here - 1) {
          return (round, to);
        }
      }
    }
    return null;
  }

  /// The doubling rule for three spindles: two to the rounds, less one.
  static int doubling(int rounds) => (1 << rounds) - 1;

  /// The leapfrog reckoning for four spindles: carry some rounds aside,
  /// move the rest by the doubling rule, carry the aside back on. The
  /// best split, tried over every split.
  static int leapfrog(int rounds) {
    if (rounds <= 1) return rounds;
    var best = 1 << 62;
    for (var aside = 1; aside < rounds; aside++) {
      final cost = 2 * leapfrog(aside) + doubling(rounds - aside);
      if (cost < best) best = cost;
    }
    return best;
  }

  /// The old iteration for three spindles, executed: on odd turns the
  /// smallest round steps round its cycle, on even turns the one move
  /// that is not the smallest's. The moves it makes, from the start.
  List<(int, int)> iterated() {
    assert(spindles == 3);
    // An odd tower's smallest steps first-to-last-to-middle; an even
    // one's the other way.
    final cycle = rounds.isOdd ? const [2, 0, 1] : const [1, 2, 0];
    var board = start;
    final moves = <(int, int)>[];
    var turn = 0;
    while (board != home) {
      if (turn.isEven) {
        final from = spindleOf(board, 0);
        final to = cycle[from];
        moves.add((0, to));
        board = moved(board, 0, to);
      } else {
        // The one legal move not touching the smallest.
        var made = false;
        for (var round = 1; round < rounds && !made; round++) {
          for (var to = 0; to < spindles && !made; to++) {
            if (mayMove(board, round, to)) {
              moves.add((round, to));
              board = moved(board, round, to);
              made = true;
            }
          }
        }
        if (!made) break;
      }
      turn++;
    }
    return moves;
  }
}
