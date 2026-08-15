import 'dart:io';

import 'package:cutlassby/deck/level.dart';
import 'package:cutlassby/deck/levels.dart';
import 'package:cutlassby/deck/rules.dart';

/// Sweeps every division of the gold for every crew, reckons the votes
/// from the crew one smaller, holds the labels to the sweep, and
/// refuses the bake on any disagreement: this is what `make plans`
/// runs, and the README quotes its ledger verbatim.
void main() {
  const rules = Rules(Level.gold);
  // Every level's label against the sweep, and the best plan's shape.
  for (final level in Levels.all) {
    final (passing, all) = rules.sweep(level.pirates, level.keep);
    if (passing != level.ways || all != level.plans) {
      stderr.writeln('${level.name}: sweep finds $passing of $all, label says ${level.ways} of ${level.plans}');
      exit(1);
    }
    final most = rules.mostKept(level.pirates);
    if ((most >= level.keep) != level.winnable) {
      stderr.writeln('${level.name}: the captain keeps $most at most, asked ${level.keep}, label ${level.winnable ? 'winnable' : 'hopeless'}');
      exit(1);
    }
  }

  // Every crew from one to seven: the best plan is one alone, it passes,
  // nothing keeping more passes, the captain keeps the gold less half
  // the crew rounded down, and every coin he gives buys an aye from a
  // pirate who expects nothing.
  final kept = <int>[];
  var plansSwept = 0;
  for (var n = 1; n <= 7; n++) {
    final best = rules.best(n);
    plansSwept += rules.divisions(n).length;
    if (!rules.passes(best) && n > 1) {
      stderr.writeln('$n PIRATES: THE BEST PLAN $best FAILS');
      exit(1);
    }
    final (better, _) = rules.sweep(n, best[0] + 1);
    if (better != 0) {
      stderr.writeln('$n PIRATES: $better PLANS KEEP MORE THAN THE BEST');
      exit(1);
    }
    if (best[0] != Level.gold - (n - 1) ~/ 2) {
      stderr.writeln('$n PIRATES: THE CAPTAIN KEEPS ${best[0]}, NOT THE GOLD LESS HALF THE CREW');
      exit(1);
    }
    final want = rules.expects(n);
    for (var i = 1; i < n; i++) {
      if (best[i] != 0 && (best[i] != 1 || want[i] != 0)) {
        stderr.writeln('$n PIRATES: PIRATE $i GETS ${best[i]} EXPECTING ${want[i]}');
        exit(1);
      }
    }
    kept.add(best[0]);
  }

  stdout.writeln(
      'every division of the ten coins swept for crews of one to seven, '
      '${_commas(plansSwept)} plans, the votes reckoned from the best plan of the '
      'crew one smaller: the best plan is one alone every time, and the captain '
      'keeps ${kept.join(', ')} for crews of one to seven, the gold less half the '
      'crew rounded down, every coin he gives buying an aye from a pirate who '
      'expects nothing with the captain gone; two pirates keep the captain ten, '
      'three nine, four nine, five eight, and nine among five never passes');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${level.plans} plan${level.plans == 1 ? '' : 's'} keeping so much pass${level.ways == 1 ? 'es' : ''}'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${level.plans}, and the reckoning said so first');
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
