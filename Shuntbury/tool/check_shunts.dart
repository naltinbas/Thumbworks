import 'dart:io';

import 'package:shuntbury/yard/levels.dart';
import 'package:shuntbury/yard/play.dart';
import 'package:shuntbury/yard/rules.dart';

/// Walks out from home through every yard the shunts reach, holds the
/// walk against the count of pairs out of order on all 362,880
/// arrangements, and refuses the bake on any disagreement: this is what
/// `make shunts` runs, and the README quotes its ledger verbatim.
void main() {
  // The walk: 181,440 yards, 31 the most, two of them that far.
  final distances = Rules.distances;
  final byDistance = <int, int>{};
  for (final d in distances.values) {
    byDistance[d] = (byDistance[d] ?? 0) + 1;
  }
  final most = byDistance.keys.reduce((a, b) => a > b ? a : b);
  if (distances.length != 181440 || most != 31 || byDistance[31] != 2 || byDistance[2] != 4 || byDistance[7] != 62 || byDistance[12] != 748) {
    stderr.writeln('THE WALK REACHES ${distances.length}, THE MOST $most, ${byDistance[31]} THAT FAR; ${byDistance[2]} AT TWO, ${byDistance[7]} AT SEVEN, ${byDistance[12]} AT TWELVE');
    exit(1);
  }
  // The two voices on every arrangement: reached by the walk exactly
  // when the count of pairs out of order is even.
  var all = 0, even = 0;
  for (final yard in Rules.allYards) {
    all++;
    final e = Rules.evenByCount(yard);
    if (e) even++;
    if (e != Rules.reachable(yard)) {
      stderr.writeln('${Rules.told(yard)}: THE COUNT SAYS ${e ? 'EVEN' : 'ODD'}, THE WALK ${Rules.reachable(yard) ? 'REACHES IT' : 'DOES NOT'}');
      exit(1);
    }
  }
  if (all != 362880 || even != 181440) {
    stderr.writeln('$all ARRANGEMENTS, $even EVEN');
    exit(1);
  }
  // Every shunt from every reachable yard keeps the count's parity, and
  // moves the fewest by exactly one.
  for (final k in distances.keys) {
    final yard = Rules.unkey(k);
    for (final from in Rules.beside(yard.indexOf(0))) {
      final next = Rules.shunt(yard, from)!;
      if (Rules.inversions(next).isEven != Rules.inversions(yard).isEven || (Rules.fewest(next)! - distances[k]!).abs() != 1) {
        stderr.writeln('${Rules.told(yard)} SHUNTING BERTH $from BREAKS THE PARITY OR THE DISTANCE');
        exit(1);
      }
    }
  }
  // Every level's label against the walk, the note's counts, and the
  // pointer walking home in the fewest.
  for (final level in Levels.all) {
    if (Rules.fewest(level.start) != level.fewest) {
      stderr.writeln('${level.name}: THE WALK SAYS ${Rules.fewest(level.start)}, THE LABEL ${level.fewest}');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
    if (level.winnable) {
      var play = Play.of(level);
      while (!play.isDone) {
        play = play.tap(play.next!);
      }
      if (play.moves != level.fewest) {
        stderr.writeln('${level.name}: THE POINTER TOOK ${play.moves}');
        exit(1);
      }
    }
  }
  final counts = [for (final level in Levels.all) Rules.inversions(level.start)];
  if (counts.toString() != '[4, 10, 12, 24, 1]') {
    stderr.writeln('THE COUNTS OUT OF ORDER ARE $counts');
    exit(1);
  }
  final farthest = [for (final e in distances.entries) if (e.value == 31) Rules.told(Rules.unkey(e.key))]..sort();
  if (farthest.toString() != '[6 4 7 / 8 5 _ / 3 2 1, 8 6 7 / 2 5 4 / 3 _ 1]') {
    stderr.writeln('THE FARTHEST ARE $farthest');
    exit(1);
  }

  stdout.writeln(
      'every yard the shunts can reach walked out from home breadth first, '
      '181,440 of the 362,880 arrangements of eight wagons and a gap, with the '
      'fewest shunts to each, 31 the most and two yards that far, 8 6 7 / 2 5 4 / '
      '3 _ 1 and 6 4 7 / 8 5 _ / 3 2 1; the count of pairs out of order is even on exactly those '
      '181,440 and odd on the other 181,440, arrangement by arrangement, and every '
      'shunt from every reachable yard keeps it even and moves the fewest by '
      'exactly one; the two shunts is one of 4 yards at that distance, the seven '
      'one of 62, the twelve one of 748, and the pairs out of order stand at 4, '
      '10, 12 and 24 on the four asks that come home and at 1 on the swapped pair, '
      'which the walk never reaches');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(16);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: the walk from home says ${level.fewest}'
        : ' ${number + 1} $name ${level.task}: never, and the odd count said so first');
  }
}
