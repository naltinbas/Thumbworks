import 'dart:io';

import 'package:feintley/feint/levels.dart';
import 'package:feintley/feint/play.dart';
import 'package:feintley/feint/rules.dart';

/// Runs Fermat's test on every number to 1,200 on every base two ways,
/// counts the liars, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_tests.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => Rules.tell(n);

  final sieve = Rules.sieve;
  var settings = 0, primes = 0, primePasses = 0, primeFails = 0, liars = 0, carmichaels = 0;
  var composites = 0, compositeSettings = 0, compositeFails = 0;
  final liarsByBase = <int, List<int>>{};
  final carmichaelNumbers = <int>[];
  for (var n = Rules.least; n <= Rules.most; n++) {
    check(Rules.isPrime(n) == sieve[n], 'the trial and the sieve differ on $n');
    final composite = !Rules.isPrime(n);
    if (!composite) primes++;
    if (composite) composites++;
    if (composite) {
      final f = Rules.factor(n)!;
      check(n % f == 0 && f > 1 && f * f <= n, 'the factor of $n is $f');
    } else {
      check(Rules.factor(n) == null, 'a prime with a factor: $n');
    }
    for (var a = Rules.leastBase; a <= Rules.mostBase; a++) {
      settings++;
      final bySquaring = Rules.powMod(a, n - 1, n), whole = Rules.powWhole(a, n - 1, n);
      check(bySquaring == whole, 'the two powers differ at $n on base $a: $bySquaring and $whole');
      final passes = Rules.passes(a, n);
      check(passes == (bySquaring == 1), 'the pass and the power differ at $n on base $a');
      if (!composite) {
        if (Rules.gcd(a, n) == 1) {
          check(passes, 'the prime $n fails on base $a');
          primePasses++;
        } else {
          check(!passes, 'the prime $n passes on the base $a it divides');
          primeFails++;
        }
      } else {
        compositeSettings++;
        if (passes) {
          liars++;
          (liarsByBase[a] ??= []).add(n);
        } else {
          compositeFails++;
        }
      }
    }
    if (Rules.carmichael(n)) {
      carmichaels++;
      carmichaelNumbers.add(n);
      for (var a = Rules.leastBase; a <= Rules.mostBase; a++) {
        if (Rules.gcd(a, n) == 1) check(Rules.passes(a, n), 'the Carmichael number $n fails on base $a');
      }
    }
  }
  check(settings == 13189 && primes == 196 && primePasses == 2142 && primeFails == 14, 'settings $settings, primes $primes, passes $primePasses, fails $primeFails');
  check(liars == 116, 'liars $liars');
  check(composites == 1003 && compositeSettings == 11033 && compositeFails == 10917 && compositeFails + liars == compositeSettings, 'composites $composites, their settings $compositeSettings, failing $compositeFails');
  check(liarsByBase[2]!.join(',') == '341,561,645,1105', 'the liars of base two: ${liarsByBase[2]}');
  check(liarsByBase[3]!.join(',') == '91,121,286,671,703,949,1105', 'the liars of base three: ${liarsByBase[3]}');
  check(carmichaels == 2 && carmichaelNumbers.join(',') == '561,1105', 'the Carmichael numbers $carmichaelNumbers');
  check(341 == 11 * 31 && 561 == 3 * 11 * 17 && 1105 == 5 * 13 * 17 && 91 == 7 * 13, 'the named composites');
  check(!Rules.passes(2, 91) && Rules.passes(3, 91) && Rules.passes(2, 341) && !Rules.passes(3, 341), 'the two bases catching each other out');
  final mostLiars = liarsByBase.entries.reduce((a, b) => a.value.length >= b.value.length ? a : b);
  check(mostLiars.key == 8 && mostLiars.value.length == 22 && liarsByBase[2]!.length == 4, 'the base with the most liars: ${mostLiars.key} with ${mostLiars.value.length}');
  final aboveThousand = [for (var n = 1001; n <= Rules.most; n++) if (Rules.isPrime(n)) n];
  check(aboveThousand.length == 28 && aboveThousand.first == 1009, 'primes above a thousand: ${aboveThousand.length}, first ${aboveThousand.first}');
  check(Rules.powMod(2, 340, 341) == 1 && Rules.powMod(3, 340, 341) == 56, 'the powers at 341');

  // The asks.
  for (final level in Levels.all) {
    var ways = 0;
    for (var n = Rules.least; n <= Rules.most; n++) {
      for (var a = Rules.leastBase; a <= Rules.mostBase; a++) {
        if (level.meets(n, a)) ways++;
      }
    }
    check(ways == level.ways, '${level.name}: ${level.ways} said, $ways swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim.$1, aim.$2), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 200) {
        final (which, by) = play.next!;
        play = play.step(which, by);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == (1009, 2) && Levels.at(1).aim == (341, 2) && Levels.at(2).aim == (91, 3) && Levels.at(3).aim == (561, 2), 'the aims');
  final dead = Play.of(Levels.at(4)).step('n', 10).step('n', 1).step('n', 1).step('n', 1).step('n', 1).step('n', 1).step('n', 1);
  check(dead.seen.length == 3 && dead.gaveUp, 'the failing prime does not admit it after three primes: seen ${dead.seen}, at ${dead.number}');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every number from 2 to ${commas(Rules.most)} tried on every base from 2 to 12, ${commas(settings)} settings, and the power worked by squaring modulo the number and again taken whole before being brought down, the two agreeing on all ${commas(settings)}, the primes found by trial division and again by the sieve, agreeing on all ${commas(Rules.most - 1)}: every one of the $primes primes passes on every base it does not divide, ${commas(primePasses)} settings, and fails on the $primeFails settings where the base is a multiple of it; of the ${commas(compositeSettings)} settings with a composite, ${commas(compositeFails)} fail and $liars pass, the liars, four of them on base two, 341, 561, 645 and 1,105, and seven on base three, 91, 121, 286, 671, 703, 949 and 1,105, base two the honestest of the eleven and base eight the loosest with 22; 561, which is 3 times 11 times 17, and 1,105, which is 5 times 13 times 17, pass on every base they share no factor with, the two Carmichael numbers below ${commas(Rules.most)}; and 91 fails on base two while 341 fails on base three, so a second base catches most liars but not all\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(settings)} settings land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(settings)}, and Fermat said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
