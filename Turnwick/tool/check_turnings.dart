import 'dart:io';

import 'package:turnwick/pack/levels.dart';
import 'package:turnwick/pack/rules.dart';

/// Walks every pack of four, six and eight cards from all face down,
/// holds Hummer's count on every pack reached, sweeps every sequence of
/// moves for the sham, and refuses the bake on any disagreement: this
/// is what `make turnings` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // Every level's label against the sweep and the walk.
  for (final level in Levels.all) {
    final rules = level.rules;
    final (landing, all) = rules.sweep(level.pattern, level.moves);
    if (landing != level.ways || all != level.sequences) {
      stderr.writeln('${level.name}: sweep finds $landing of $all, label says ${level.ways} of ${level.sequences}');
      exit(1);
    }
    final fewest = rules.fewest(level.pattern);
    if ((fewest != null) != level.winnable || (fewest != null && fewest != level.moves)) {
      stderr.writeln('${level.name}: the walk\'s fewest is $fewest, label says ${level.winnable ? level.moves : 'never'}');
      exit(1);
    }
    if (Rules.balanced(level.pattern) != level.winnable) {
      stderr.writeln('${level.name}: HUMMER\'S COUNT ${Rules.balanced(level.pattern) ? 'HOLDS' : 'FAILS'}, LABEL ${level.winnable ? 'WINNABLE' : 'HOPELESS'}');
      exit(1);
    }
  }

  // Every pack of four, six and eight: every pack reached keeps
  // Hummer's count, and the patterns of faces reached are exactly the
  // patterns that keep it.
  final told = <String>[];
  for (final n in [4, 6, 8]) {
    final rules = Rules(n);
    final walked = rules.walk();
    for (final k in walked.keys) {
      if (!Rules.balanced(k.split(',').map((c) => c.endsWith('u')).toList())) {
        stderr.writeln('$n CARDS: THE PACK $k IS REACHED AND OFF THE COUNT');
        exit(1);
      }
    }
    final reached = rules.patterns();
    final (balanced, all) = rules.balancedPatterns();
    if (reached.length != balanced) {
      stderr.writeln('$n CARDS: ${reached.length} PATTERNS REACHED, $balanced KEEP THE COUNT');
      exit(1);
    }
    for (var mask = 0; mask < (1 << n); mask++) {
      final faces = [for (var i = 0; i < n; i++) (mask >> i) & 1 == 1];
      if (Rules.balanced(faces) != reached.containsKey(Rules.faceKey(faces))) {
        stderr.writeln('$n CARDS: THE PATTERN ${Rules.faceKey(faces)} ${Rules.balanced(faces) ? 'KEEPS THE COUNT BUT IS NOT REACHED' : 'IS REACHED OFF THE COUNT'}');
        exit(1);
      }
    }
    told.add('$n cards ${_commas(walked.length)} packs and ${reached.length} patterns of $all');
    // The moves and the count: a turn moves both counts together, a cut
    // swaps them.
    for (final k in walked.keys) {
      final pack = [for (final c in k.split(',')) (int.parse(c.substring(0, c.length - 1)), c.endsWith('u'))];
      final f = Rules.faces(pack);
      final ft = Rules.faces(Rules.turn(pack)), fc = Rules.faces(Rules.cut(pack));
      if (Rules.upAtEven(ft) - Rules.upAtEven(f) != Rules.upAtOdd(ft) - Rules.upAtOdd(f)) {
        stderr.writeln('$n CARDS: A TURN OF $k MOVES THE COUNTS APART');
        exit(1);
      }
      if (Rules.upAtEven(fc) != Rules.upAtOdd(f) || Rules.upAtOdd(fc) != Rules.upAtEven(f)) {
        stderr.writeln('$n CARDS: A CUT OF $k DOES NOT SWAP THE COUNTS');
        exit(1);
      }
    }
  }

  stdout.writeln(
      'every pack of four, six and eight cards walked from all face down, by '
      'cuts and turns, ${told.join(', ')}: on every pack reached the cards face '
      'up at even places number the cards face up at odd, a turn of the top two '
      'moving both counts together and a cut swapping them, and the patterns of '
      'faces '
      'reached are exactly the patterns that keep the count; every sequence of '
      'moves swept for the sham, the top two up in one move 1 way of 2, the ends '
      'in two 1 of 4, the middle two in four 1 of 16, all four up in four 1 of 16, '
      'and one card up alone never');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(14);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.moves} move${level.moves == 1 ? '' : 's'} at the fewest, ${level.ways} sequence${level.ways == 1 ? '' : 's'} of the ${level.sequences}'
        : ' ${number + 1} $name ${level.task}: never, and Hummer\'s count said so first');
  }
}

String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
