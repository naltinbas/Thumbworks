import 'dart:io';

import 'package:foldwick/plank/crossings.dart';
import 'package:foldwick/plank/rules.dart';

/// Walks every crossing of every plank, holds Lucas's arithmetic
/// to it, and refuses the bake on any disagreement: this is what
/// `make planks` runs, and the README quotes its ledger verbatim.
void main() {
  for (final crossing in Crossings.all) {
    final rules = Rules(crossing.sheep, crossing.goats, jumps: crossing.jumps);
    final shapes = rules.crossingShapes();
    if (shapes.length != crossing.ways) {
      stderr.writeln('${crossing.name}: walk finds ${shapes.length} crossings, label says ${crossing.ways}');
      exit(1);
    }
    for (final (moves, jumps, steps) in shapes) {
      if (moves != crossing.moves || moves != rules.movesByArithmetic ||
          jumps != crossing.sheep * crossing.goats || steps != crossing.sheep + crossing.goats) {
        stderr.writeln('${crossing.name}: a crossing of $moves moves, $jumps jumps, $steps steps');
        exit(1);
      }
    }
    // The walk's fewest to the goal agrees, and the count of fewest
    // ways is the count of crossings, since every crossing is fewest.
    final walk = rules.walk();
    if (crossing.winnable) {
      if (walk.fewest[rules.goal] != crossing.moves || walk.ways[rules.goal] != crossing.ways) {
        stderr.writeln('${crossing.name}: walk fewest ${walk.fewest[rules.goal]}, ways ${walk.ways[rules.goal]}');
        exit(1);
      }
    } else if (walk.fewest.containsKey(rules.goal)) {
      stderr.writeln('${crossing.name}: the goal was reached');
      exit(1);
    }
  }

  // The reachable planks: 6, 23, 40, 72, and 5 for the steps alone.
  const reach = {'1,1': 6, '2,2': 23, '3,2': 40, '3,3': 72};
  for (final entry in reach.entries) {
    final parts = entry.key.split(',');
    final rules = Rules(int.parse(parts[0]), int.parse(parts[1]));
    if (rules.walk().fewest.length != entry.value) {
      stderr.writeln('PLANK ${entry.key} REACHES ${rules.walk().fewest.length}');
      exit(1);
    }
  }
  final stepsOnly = Rules(2, 2, jumps: false);
  final stepWalk = stepsOnly.walk();
  if (stepWalk.fewest.length != 5) {
    stderr.writeln('STEPS ALONE REACH ${stepWalk.fewest.length}');
    exit(1);
  }
  // Steps keep the order along the plank, on every reached plank.
  for (final plank in stepWalk.fewest.keys) {
    if (Rules.order(plank) != 'SSGG') {
      stderr.writeln('STEPS CHANGED THE ORDER: $plank');
      exit(1);
    }
  }
  // And Lucas's arithmetic on bigger flocks: every crossing of four
  // and four takes twenty-four, and of four and three nineteen.
  for (final (m, n) in [(4, 4), (4, 3), (2, 1), (1, 3)]) {
    final rules = Rules(m, n);
    final shapes = rules.crossingShapes();
    if (shapes.isEmpty || shapes.any((s) => s.$1 != m * n + m + n || s.$2 != m * n)) {
      stderr.writeln('FLOCK $m AND $n: $shapes');
      exit(1);
    }
  }

  stdout.writeln(
      'every crossing of every plank walked, no beast ever going back: one '
      'and one cross in 3, two and two in 8, three and two in 11, three '
      'and three in 15, two crossings apiece and never otherwise, every '
      'crossing taking exactly the sheep times the goats jumps and the '
      'sheep plus the goats steps, as Lucas reckoned, and the same on four '
      'and four, four and three, two and one and one and three; with steps '
      'alone the order along the plank never changes, five planks are '
      'reached and the fold is stuck');
  stdout.writeln('');

  for (var number = 0; number < Crossings.count; number++) {
    final crossing = Crossings.at(number);
    final name = crossing.name.padRight(19);
    stdout.writeln(crossing.winnable
        ? ' ${number + 1} $name ${crossing.task}: ${crossing.moves} moves every time, '
            '${crossing.ways} crossings'
        : ' ${number + 1} $name ${crossing.task}: never, and the order said so first');
  }
}
