import 'dart:io';

import 'package:evenholme/split/levels.dart';
import 'package:evenholme/split/play.dart';
import 'package:evenholme/split/rules.dart';

/// Sifts the primes two ways, splits every even number to two thousand,
/// and refuses the bake on any disagreement: this is what `make splits`
/// runs, and the README quotes its ledger verbatim.
void main() {
  // The two voices on every number to 2,000: the sieve against trial
  // division.
  var primes = 0;
  for (var n = 0; n <= Rules.top; n++) {
    if (Rules.isPrime(n) != Rules.isPrimeByTrial(n)) {
      stderr.writeln('$n: THE SIEVE SAYS ${Rules.isPrime(n)}, TRIAL DIVISION ${Rules.isPrimeByTrial(n)}');
      exit(1);
    }
    if (Rules.isPrime(n)) primes++;
  }
  if (primes != 303 || Rules.primesTo(100).length != 25) {
    stderr.writeln('$primes PRIMES TO 2000, ${Rules.primesTo(100).length} TO 100');
    exit(1);
  }
  // Every even number from 4 to 2,000 splits; the singles, the fewest
  // above 100 and the most.
  final singles = <int>[];
  var fewestAbove = 1 << 30, fewestAt = 0, most = 0, mostAt = 0;
  for (var n = 4; n <= Rules.top; n += 2) {
    final c = Rules.splits(n).length;
    if (c == 0) {
      stderr.writeln('$n DOES NOT SPLIT');
      exit(1);
    }
    for (final (p, q) in Rules.splits(n)) {
      if (p + q != n || !Rules.isPrimeByTrial(p) || !Rules.isPrimeByTrial(q) || p > q) {
        stderr.writeln('$n: A BAD SPLIT $p + $q');
        exit(1);
      }
    }
    if (c == 1) singles.add(n);
    if (n > 100 && c < fewestAbove) {
      fewestAbove = c;
      fewestAt = n;
    }
    if (c > most) {
      most = c;
      mostAt = n;
    }
  }
  if (singles.toString() != '[4, 6, 8, 12]' || fewestAbove != 3 || fewestAt != 128 || most != 91 || mostAt != 1890) {
    stderr.writeln('SINGLES $singles, FEWEST ABOVE 100 $fewestAbove AT $fewestAt, MOST $most AT $mostAt');
    exit(1);
  }
  // Every level's label against the sweep of its picks, the aim landing
  // it, and no level over at the opening; and no odd number to 2,000
  // splits without a 2.
  for (final level in Levels.all) {
    var met = 0;
    for (var a = 2; a <= level.number ~/ 2; a++) {
      if (level.meets(a)) met++;
    }
    if (met != level.ways) {
      stderr.writeln('${level.name}: sweep finds $met of ${level.picks}, label says ${level.ways}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? level.winnable : !level.meets(aim)) {
      stderr.writeln('${level.name}: the aim $aim does not land it');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }
  for (var n = 3; n <= Rules.top; n += 2) {
    for (final (p, q) in Rules.splits(n)) {
      if (p != 2 || !Rules.isPrime(q)) {
        stderr.writeln('$n SPLITS AS $p + $q');
        exit(1);
      }
    }
  }
  // The named splits.
  if (Rules.splits(20).map(Rules.told).join(', ') != '3 + 17, 7 + 13' ||
      Rules.splits(60).map(Rules.told).join(', ') != '7 + 53, 13 + 47, 17 + 43, 19 + 41, 23 + 37, 29 + 31' ||
      Rules.splits(98).map(Rules.told).join(', ') != '19 + 79, 31 + 67, 37 + 61' ||
      Rules.splits(100).map(Rules.told).join(', ') != '3 + 97, 11 + 89, 17 + 83, 29 + 71, 41 + 59, 47 + 53' ||
      Rules.splits(51).isNotEmpty || 51 - 2 != 49 || 49 != 7 * 7 ||
      Rules.splits(50).map(Rules.told).join(', ') != '3 + 47, 7 + 43, 13 + 37, 19 + 31' ||
      Rules.splits(52).map(Rules.told).join(', ') != '5 + 47, 11 + 41, 23 + 29' ||
      Rules.splits(4).toString() != '[(2, 2)]' || Rules.splits(12).toString() != '[(5, 7)]') {
    stderr.writeln('THE NAMED SPLITS ARE OFF');
    exit(1);
  }

  stdout.writeln(
      'the primes to 2,000 sifted with Eratosthenes\' sieve and again by trial '
      'division, 303 of them and the two agreeing number for number; every even '
      'number from 4 to 2,000 split into two primes every way it can, and every '
      'one splits, 4, 6, 8 and 12 one way alone, no even number above 100 fewer '
      'than three ways, 128 the first with just three, and 1,890 the most with '
      '91; twenty splits as 3 + 17 and 7 + 13, sixty six ways with 29 + 31 the '
      'twins, ninety-eight three ways with 31 + 67 and 37 + 61 both over thirty, '
      'and a hundred six ways from 3 + 97 to 47 + 53; and no odd number to 2,000 '
      'splits without a 2, so 51, being 2 and 49, seven sevens, splits not at '
      'all, though 50 splits four ways and 52 three');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(12);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.picks} picks ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.picks}, and the odd sum said so first');
  }
}
