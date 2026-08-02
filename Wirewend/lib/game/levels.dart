import 'dart:math';

import 'generator.dart';
import 'grid.dart';

/// One numbered level: how big its board is, how much of it is wire, and the
/// board itself.
///
/// A level is nothing but its number. Size, fill and seed all come from that
/// number, so level 7 is the same puzzle on every device and in every run,
/// and nothing has to be stored to hand a player back a board they left.
class Level {
  Level._({
    required this.number,
    required this.rows,
    required this.cols,
    required this.fill,
  });

  /// The level a number names. Numbers below one are treated as the first
  /// level, so a corrupt saved value cannot open a board with no rows.
  factory Level.forNumber(int number) {
    final step = max(1, number) - 1;
    return Level._(
      number: max(1, number),
      // Columns and rows take turns growing, which keeps the board close to
      // the shape of a phone held upright instead of stretching one way.
      cols: min(_maxCols, _smallestSide + step ~/ 2),
      rows: min(_maxRows, _smallestSide + (step + 1) ~/ 2),
      fill: min(_fullestFill, _emptiestFill + _fillStep * step),
    );
  }

  final int number;
  final int rows;
  final int cols;

  /// The share of the grid the generator grows wire into.
  final double fill;

  /// A board small enough to read at a glance but big enough to have a wrong
  /// answer in it.
  static const _smallestSide = 3;

  /// A thumb wants about 48 logical pixels, and the narrow phones are 360
  /// wide, so six columns is where a tile stops being comfortable to hit.
  /// Rows can go further because a phone is much taller than it is wide.
  static const _maxCols = 6;
  static const _maxRows = 9;

  /// The first levels are sparse so the wire reads as a few separate runs.
  /// Filling up is most of what makes later boards harder: more cells to turn
  /// and more ways for a wrong turn to look plausible.
  static const _emptiestFill = 0.55;
  static const _fullestFill = 0.95;
  static const _fillStep = 0.03;

  Level get next => Level.forNumber(number + 1);

  /// The board for this level, built fresh. Two calls give the same puzzle,
  /// which is what makes restarting a level a restart rather than a reroll.
  Board board() => Generator(random: _LevelRandom(number)).generate(
        rows: rows,
        cols: cols,
        fill: fill,
      );
}

/// The random source a level generates from.
///
/// dart:math's Random takes a seed but does not promise which numbers it will
/// give back, so an SDK upgrade could quietly change what level 7 looks like.
/// This is a plain xorshift written out here instead, so the puzzle a number
/// names is pinned by this file and by nothing else.
class _LevelRandom implements Random {
  _LevelRandom(int seed) : _state = _spread(seed);

  int _state;

  /// Consecutive level numbers are close together, and xorshift takes a while
  /// to pull neighbouring states apart, so the seed is multiplied out first.
  /// Zero is the one state xorshift cannot leave, so it never starts there.
  static int _spread(int seed) {
    final mixed = (seed * 2654435761) & 0xFFFFFFFF;
    return mixed == 0 ? 0x9E3779B9 : mixed;
  }

  int _next() {
    var x = _state;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    _state = x;
    return x;
  }

  @override
  int nextInt(int max) {
    assert(max > 0, 'a range needs at least one value in it');
    return _next() % max;
  }

  @override
  double nextDouble() => _next() / 0x100000000;

  @override
  bool nextBool() => _next() & 1 == 1;
}
