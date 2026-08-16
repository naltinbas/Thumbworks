import 'dart:io';

import 'package:onesby/ones/levels.dart';
import 'package:onesby/ones/play.dart';
import 'package:onesby/ones/rules.dart';

/// Tells every row of ones on the dial prime or not twice over, by trial
/// division and by the Lucas-Lehmer chain, checks the perfect numbers
/// and the composite exponents, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_ones.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  // The two voices on every exponent.
  final primeRows = <int>[], compositePrimeExponents = <int>[];
  for (var p = Rules.least; p <= Rules.most; p++) {
    final byDivision = Rules.rowIsPrimeByDivision(p), byChain = Rules.rowIsPrimeByLucasLehmer(p);
    check(byDivision == byChain, 'row of $p: division $byDivision, Lucas-Lehmer $byChain');
    final row = Rules.row(p);
    check(row.toRadixString(2) == '1' * p, 'the row of $p is not $p ones');
    if (byDivision) primeRows.add(p);
    if (byDivision) check(Rules.isPrime(p), 'the row of $p is prime with $p composite');
    if (Rules.isPrime(p) && !byDivision) compositePrimeExponents.add(p);
    if (!Rules.isPrime(p)) {
      final a = Rules.smallestExponentFactor(p);
      check(row % Rules.row(a) == BigInt.zero, 'the row of $a does not divide the row of $p');
      check(Rules.smallestFactor(row) == Rules.row(a), 'smallest factor of the row of $p: ${Rules.smallestFactor(row)}, not the row of $a');
    }
    if (p >= 3) check(Rules.chain(p).length == p - 1, 'chain of $p runs ${Rules.chain(p).length}');
  }
  check(primeRows.join(',') == '2,3,5,7,13,17,19,31', 'prime rows $primeRows');
  check(compositePrimeExponents.join(',') == '11,23,29', 'prime exponents with composite rows: $compositePrimeExponents');
  check(Rules.smallestFactor(Rules.row(11)) == BigInt.from(23) && Rules.row(11) ~/ BigInt.from(23) == BigInt.from(89), '2,047');
  check(Rules.smallestFactor(Rules.row(23)) == BigInt.from(47) && Rules.row(23) ~/ BigInt.from(47) == BigInt.from(178481), '8,388,607');
  check(Rules.smallestFactor(Rules.row(29)) == BigInt.from(233) && Rules.row(29) ~/ BigInt.from(233) == BigInt.from(2304167), '536,870,911');
  check(Rules.row(30) ~/ BigInt.from(3) == BigInt.from(357913941) && Rules.row(30) % BigInt.from(3) == BigInt.zero, 'the row of thirty');
  check(Rules.row(31) == BigInt.from(2147483647) && Rules.smallestFactor(Rules.row(31)) == Rules.row(31), 'the row of thirty-one');
  check(Rules.chain(7).join(',') == '4,14,67,42,111,0' && Rules.chain(5).join(',') == '4,14,8,0' && Rules.chain(11).last != BigInt.zero, 'the named chains');
  check(Rules.chain(31).last == BigInt.zero && Rules.chain(31).length == 30, 'the chain of thirty-one');
  var sqrt = 0;
  while ((sqrt + 1) * (sqrt + 1) <= 2147483647) {
    sqrt++;
  }
  check(sqrt == 46340, 'root of the last row $sqrt');
  check(Rules.row(4) == BigInt.from(15) && Rules.row(9) == BigInt.from(511) && Rules.row(9) ~/ BigInt.from(7) == BigInt.from(73), 'the small composite rows');
  final twentyThree = [for (var p = Rules.least; p <= Rules.most; p++) if (Rules.row(p) % BigInt.from(23) == BigInt.zero) p];
  check(twentyThree.join(',') == '11,22', 'rows 23 divides: $twentyThree');
  check(BigInt.two.modPow(BigInt.from(11), BigInt.from(23)) == BigInt.one, 'two to the eleventh by 23');

  // The perfect numbers.
  final perfects = <BigInt>[];
  for (final p in primeRows) {
    final n = Rules.perfect(p);
    perfects.add(n);
    if (p <= 19) check(Rules.aliquot(n) == n, 'perfect number of $p: ${Rules.commas(n)} does not add back');
    check(n == (BigInt.one << (p - 1)) * Rules.row(p), 'perfect number of $p');
  }
  check(perfects.map(Rules.commas).join(' ') == '6 28 496 8,128 33,550,336 8,589,869,056 137,438,691,328 2,305,843,008,139,952,128', 'perfect numbers ${perfects.map(Rules.commas).join(' ')}');
  check(Rules.perfect(7) == BigInt.from(8128) && Rules.aliquot(BigInt.from(8128)) == BigInt.from(8128), '8,128');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (var p = Rules.least; p <= Rules.most; p++) {
      if (level.meets(p)) n++;
    }
    check(n == level.ways, '${level.name}: ${level.ways} said, $n swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 20) {
        play = play.wind(play.next!);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == 11 && Levels.at(1).aim == 11 && Levels.at(2).aim == 7 && Levels.at(3).aim == 31, 'the aims');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every row of ones from ${Rules.least} to ${Rules.most} long told prime or not by trial division to its square root and again by the Lucas-Lehmer chain, the two agreeing on all ${Rules.settings}: the prime rows are 2, 3, 5, 7, 13, 17, 19 and 31 ones long, the prime lengths 11, 23 and 29 give composite rows, 23 times 89, 47 times 178,481 and 233 times 2,304,167, and every composite length gives a row whose smallest factor is the row of its smallest prime factor; the eight prime rows make the perfect numbers 6, 28, 496, 8,128, 33,550,336, 8,589,869,056, 137,438,691,328 and 2,305,843,008,139,952,128, the first seven checked by adding their divisors; 23 divides the rows of 11 and 22 ones only; and the row of 31 ones, 2,147,483,647, is prime, its chain ending at 0 after 29 steps and no factor found to 46,340\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${Rules.settings} exponents land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${Rules.settings}, and the row of the smaller length said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
