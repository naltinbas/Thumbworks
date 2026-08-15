import 'dart:io';

import 'package:milesworth/lane/levels.dart';
import 'package:milesworth/lane/rules.dart';

/// Sweeps every run of every lane, holds the odd divisors to the
/// sweep, and refuses the bake on any disagreement: this is what
/// `make runs` runs, and the README quotes its ledger verbatim.
void main() {
  // Every level's label against the sweep, and the odd divisors'
  // runs against the sweep's runs.
  for (final level in Levels.all) {
    final rules = Rules(level.count);
    final (ways, all) = rules.sweep();
    if (ways != level.ways || all != level.runs || all != rules.runCount) {
      stderr.writeln('${level.name}: sweep finds $ways of $all, label says ${level.ways} of ${level.runs}');
      exit(1);
    }
    final swept = rules.landings();
    final built = Rules.byOddDivisors(level.count);
    if ('$swept' != '$built') {
      stderr.writeln('${level.name}: sweep $swept, odd divisors $built');
      exit(1);
    }
  }

  // Every count to two hundred: the runs the sweep finds are exactly
  // the runs the odd divisors build, one to a divisor, and the count
  // has none exactly when it is a power of two.
  var counts = 0, runsSwept = 0, powersOfTwo = 0;
  for (var n = 1; n <= 200; n++) {
    final rules = Rules(n);
    final swept = rules.landings();
    final built = Rules.byOddDivisors(n);
    if ('$swept' != '$built') {
      stderr.writeln('$n: sweep $swept, odd divisors $built');
      exit(1);
    }
    for (final run in swept) {
      if (Rules.sum(run) != n || Rules.length(run) < 2) {
        stderr.writeln('$n: RUN $run DOES NOT ADD UP');
        exit(1);
      }
    }
    if (swept.isEmpty != Rules.isPowerOfTwo(n)) {
      stderr.writeln('$n: ${swept.length} RUNS BUT POWER OF TWO IS ${Rules.isPowerOfTwo(n)}');
      exit(1);
    }
    counts++;
    runsSwept += rules.runCount;
    if (swept.isEmpty) powersOfTwo++;
  }
  if (powersOfTwo != 8) {
    stderr.writeln('$powersOfTwo POWERS OF TWO TO TWO HUNDRED');
    exit(1);
  }
  // The named runs.
  if ('${Rules(15).landings()}' != '[(1, 5), (4, 6), (7, 8)]' ||
      '${Rules(13).landings()}' != '[(6, 7)]' ||
      '${Rules(45).landings()}' != '[(1, 9), (5, 10), (7, 11), (14, 16), (22, 23)]' ||
      Rules.runFor(15, 15) != (7, 8) ||
      Rules.runFor(21, 7) != (1, 6)) {
    stderr.writeln('THE NAMED RUNS MOVED');
    exit(1);
  }
  // Every odd number past one is a run of two.
  for (var n = 3; n <= 199; n += 2) {
    if (!Rules(n).lands((n ~/ 2, n ~/ 2 + 1))) {
      stderr.writeln('$n IS NOT A RUN OF TWO');
      exit(1);
    }
  }

  stdout.writeln(
      'every run of two or more milestones swept on every lane to two '
      'hundred, ${_commas(runsSwept)} runs on $counts lanes, and the '
      'runs that add to the count are exactly the runs the odd divisors '
      'build, one run to each odd divisor past one, so a count has none '
      'exactly when it is a power of two, eight lanes of the two hundred; '
      'fifteen runs three ways, 1 to 5, 4 to 6 and 7, 8, thirteen once as '
      '6, 7, forty-five five ways, and every odd count is the run of two '
      'either side of its half');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(14);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.runs} runs land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.runs}, and the odd divisors said so first');
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
