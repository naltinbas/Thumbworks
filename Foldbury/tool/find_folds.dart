// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:foldbury/fold/fewest.dart';
import 'package:foldbury/fold/fold.dart';

/// Scatters gates and keeps the folds worth playing: the matching floor has
/// to be exactly the answer, so the map carries its own proof, and posting
/// greedily at the busiest gate has to cost a shepherd more, so the map is
/// about thinking rather than tidiness.
///
///   dart run tool/find_folds.dart [gates] [lanes] [how many] [seed]
void main(List<String> args) {
  final gates = args.isNotEmpty ? int.parse(args[0]) : 8;
  final laneCount = args.length > 1 ? int.parse(args[1]) : 11;
  final wanted = args.length > 2 ? int.parse(args[2]) : 2;
  final seed = args.length > 3 ? int.parse(args[3]) : 20260811;

  final random = Random(seed);
  var kept = 0;
  var tried = 0;

  while (kept < wanted && tried < 60000) {
    tried++;

    final where = <(double, double)>[];
    var go = 0;
    while (where.length < gates && go++ < 400) {
      final at = (
        0.10 + random.nextDouble() * 0.80,
        0.12 + random.nextDouble() * 0.76,
      );
      final near = where.any((other) =>
          (other.$1 - at.$1).abs() < 0.16 && (other.$2 - at.$2).abs() < 0.11);
      if (!near) where.add(at);
    }
    if (where.length != gates) continue;

    // Lanes between near gates, no lane twice.
    final near = <(int, int, double)>[];
    for (var one = 0; one < gates; one++) {
      for (var other = one + 1; other < gates; other++) {
        final away = sqrt(pow(where[one].$1 - where[other].$1, 2) +
            pow(where[one].$2 - where[other].$2, 2));
        if (away < 0.42) near.add((one, other, away));
      }
    }
    if (near.length < laneCount) continue;
    near.shuffle(random);
    final lanes = [
      for (final (one, other, _) in near.take(laneCount)) Lane(one, other),
    ];

    // Every gate has to matter.
    final touched = <int>{};
    for (final lane in lanes) {
      touched..add(lane.from)..add(lane.to);
    }
    if (touched.length != gates) continue;

    final fold = Fold(
      name: 'try',
      gates: [
        for (var gate = 0; gate < gates; gate++)
          Gate('G$gate', where[gate].$1, where[gate].$2),
      ],
      lanes: lanes,
      fewest: 0,
    );

    final watch = Watches.of(fold);
    if (!watch.matchingIsTight) continue;
    if (Watches.byGreed(fold) <= watch.fewest) continue;

    kept++;
    print('');
    print('$kept  $gates gates  $laneCount lanes  fewest ${watch.fewest}  '
        'matching ${watch.matching.length}  greed ${Watches.byGreed(fold)}');
    for (var gate = 0; gate < gates; gate++) {
      print("    Gate(NAME, ${where[gate].$1.toStringAsFixed(2)}, "
          "${where[gate].$2.toStringAsFixed(2)}),");
    }
    print('    ---');
    for (final lane in lanes) {
      print('    Lane(${lane.from}, ${lane.to}),');
    }
  }

  print('');
  print('$kept kept out of $tried tried');
}
