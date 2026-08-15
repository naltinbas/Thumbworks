import 'dart:io';

import 'package:patchmere/quilt/levels.dart';
import 'package:patchmere/quilt/play.dart';
import 'package:patchmere/quilt/rules.dart';

/// Sews every quilt out every way against the house, holds the
/// mirror to the tree on every small quilt, and refuses the bake on
/// any disagreement: this is what `make quilts` runs, and the README
/// quotes its ledger verbatim.
/// A count with commas, the way the ledger reads them.
String commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}

void main() {
  // The places for a patch, counted two ways, and the patches that
  // are their own mirror, on every quilt up to five by five.
  for (var rows = 1; rows <= 5; rows++) {
    for (var cols = 1; cols <= 5; cols++) {
      final q = Quilt(rows, cols);
      if (q.patches.length != q.patchesByArithmetic) {
        stderr.writeln('$rows x $cols: ${q.patches.length} places, arithmetic says ${q.patchesByArithmetic}');
        exit(1);
      }
      final own = q.selfMirrored.length;
      final wanted = (rows.isOdd && cols.isEven) || (rows.isEven && cols.isOdd) ? 1 : 0;
      if (own != wanted) {
        stderr.writeln('$rows x $cols: $own patches are their own mirror');
        exit(1);
      }
    }
  }

  // The mirror, played out: on every even-by-even quilt of up to
  // twenty cells, the second sewer answers across the middle through
  // every game the first can sew, the answer always fits, and the
  // second sews last; the tree agrees the first loses.
  var mirrorGames = 0;
  for (final (rows, cols) in [(2, 2), (2, 4), (2, 6), (2, 8), (2, 10), (4, 4)]) {
    final q = Quilt(rows, cols);
    var games = 0;
    void walk(int sewn) {
      final moves = q.moves(sewn);
      if (moves.isEmpty) {
        stderr.writeln('$rows x $cols: THE MIRROR RAN OUT FIRST at ${q.picture(sewn)}');
        exit(1);
      }
      for (final p in moves) {
        final after = q.sew(sewn, p);
        final back = q.mirror(p);
        if (!q.fits(after, back)) {
          stderr.writeln('$rows x $cols: THE MIRROR OF $p DOES NOT FIT at ${q.picture(after)}');
          exit(1);
        }
        final answered = q.sew(after, back);
        if (q.moves(answered).isEmpty) {
          games++;
        } else {
          walk(answered);
        }
      }
    }

    walk(0);
    if (q.moverWins(0)) {
      stderr.writeln('$rows x $cols: THE TREE SAYS THE FIRST SEWER WINS');
      exit(1);
    }
    mirrorGames += games;
  }

  // The middle then the mirror: on every quilt of up to twenty cells
  // with one side odd, the first sewer takes the middle patch and then
  // answers across it, through every game the second can sew, always
  // fitting, always sewing last; the tree agrees the first wins.
  var middleGames = 0;
  for (final (rows, cols) in [(1, 2), (2, 3), (2, 5), (2, 7), (2, 9), (3, 4), (3, 6), (4, 5)]) {
    final q = Quilt(rows, cols);
    final middle = q.middle!;
    var games = 0;
    void walk(int sewn) {
      final moves = q.moves(sewn);
      if (moves.isEmpty) {
        games++;
        return;
      }
      for (final p in moves) {
        final after = q.sew(sewn, p);
        final back = q.mirror(p);
        if (!q.fits(after, back)) {
          stderr.writeln('$rows x $cols: THE MIRROR OF $p DOES NOT FIT at ${q.picture(after)}');
          exit(1);
        }
        walk(q.sew(after, back));
      }
    }

    walk(q.sew(0, middle));
    if (!q.moverWins(0) || q.moverWins(q.sew(0, middle))) {
      stderr.writeln('$rows x $cols: THE TREE DISAGREES ABOUT THE MIDDLE');
      exit(1);
    }
    middleGames += games;
  }

  // Both sides odd: no middle patch, and the tree alone decides.
  if (Quilt(3, 3).moverWins(0) || !Quilt(3, 5).moverWins(0) || Quilt(3, 3).middle != null) {
    stderr.writeln('THE ODD QUILTS MOVED');
    exit(1);
  }
  if (Quilt(3, 5).winningMoves(0).length != 8 || Quilt(3, 4).winningMoves(0).length != 7 ||
      Quilt(4, 5).winningMoves(0).length != 5) {
    stderr.writeln('THE WINNING OPENINGS MOVED');
    exit(1);
  }
  if (!Quilt(3, 4).winningMoves(0).contains(Quilt(3, 4).middle) ||
      !Quilt(4, 5).winningMoves(0).contains(Quilt(4, 5).middle)) {
    stderr.writeln('THE MIDDLE PATCH DOES NOT OPEN A WIN');
    exit(1);
  }

  // Every level: every game against the house, and the house's mirror
  // where it mirrors held to the tree.
  for (final level in Levels.all) {
    var games = 0, won = 0;
    void walk(Play play) {
      if (play.isOver) {
        games++;
        if (play.won) won++;
        return;
      }
      for (final p in play.quilt.moves(play.sewn)) {
        final after = play.sewPatch(p);
        if (after.houseRule == 'mirror' && after.houseLast != play.quilt.mirror(p)) {
          stderr.writeln('${level.name}: THE HOUSE MIRRORED WRONG');
          exit(1);
        }
        walk(after);
      }
    }

    walk(Play.of(level));
    if (games != level.games || won != level.ways) {
      stderr.writeln('${level.name}: walk finds $won of $games, label says ${level.ways} of ${level.games}');
      exit(1);
    }
    final start = Play.of(level);
    if (start.youWin != level.winnable) {
      stderr.writeln('${level.name}: the tree says ${start.youWin}, the label says ${level.winnable}');
      exit(1);
    }
    if (level.name == 'The Four by Four') {
      // Every house answer is the mirror.
      void mirrors(Play play) {
        if (play.isOver) return;
        for (final p in play.quilt.moves(play.sewn)) {
          final after = play.sewPatch(p);
          if (!after.isOver || after.patches.length > play.patches.length + 1) {
            if (after.houseRule != 'mirror') {
              stderr.writeln('THE HOUSE DID NOT MIRROR: ${after.houseRule}');
              exit(1);
            }
          }
          mirrors(after);
        }
      }

      mirrors(start);
    }
  }

  stdout.writeln(
      'every game of Cram against the house sewn out on every quilt, '
      'and the mirror held to the tree on every quilt of up to twenty '
      'cells: on the even-by-even quilts, six of them, the second sewer '
      'answering across the middle always finds the patch free and '
      'always sews last through all ${commas(mirrorGames)} games, and the tree '
      'agrees the first sewer loses; on the eight quilts with one side '
      'odd the first sewer takes the one patch that is its own mirror '
      'and then answers across it, always fitting, always last, through '
      '${commas(middleGames)} games, and the tree agrees the first sewer wins; the '
      'places for a patch counted two ways on every quilt up to five by '
      'five, the three-by-three read as a loss for the first sewer and '
      'the three-by-five a win by the tree alone');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${commas(level.ways)} of the '
            '${commas(level.games)} games against the house are yours'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${commas(level.games)}, and the mirror said so first');
  }
}
