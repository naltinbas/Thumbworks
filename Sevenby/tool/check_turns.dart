import 'dart:io';

import 'package:sevenby/turn/levels.dart';
import 'package:sevenby/turn/play.dart';
import 'package:sevenby/turn/rules.dart';

/// Divides every fraction on the dial the long way, sets each period
/// against the steps of 10 round the clock, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_turns.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  bool isPrime(int n) {
    if (n < 2) return false;
    for (var d = 2; d * d <= n; d++) {
      if (n % d == 0) return false;
    }
    return true;
  }

  check(Rules.primes.every(isPrime) && !Rules.primes.contains(2) && !Rules.primes.contains(5) && Rules.primes.length == 13, 'the primes');
  check(Rules.primes.join(',') == [for (var p = 3; p <= 47; p++) if (isPrime(p) && p != 5) p].join(','), 'the primes are every odd prime to 47 but 5');
  check(Rules.settings == 308, 'settings ${Rules.settings}');

  // The two voices on every fraction, and the named facts.
  var fullOnDial = 0, evenPeriods = 0;
  final periods = <int, int>{};
  for (final p in Rules.primes) {
    final byClock = Rules.periodByClock(p);
    periods[p] = byClock;
    check((p - 1) % byClock == 0, 'period of $p, $byClock, does not divide ${p - 1}');
    final (ones, remOnes) = Rules.divide(1, p);
    check(Rules.blockValue(ones) * BigInt.from(p) == Rules.nines(ones.length), 'block of 1/$p times $p is not nines');
    var rotations = 0;
    for (var k = 1; k < p; k++) {
      final (digits, remainders) = Rules.divide(k, p);
      check(digits.length == byClock, 'period of $k/$p by division ${digits.length}, by clock $byClock');
      check(remainders.first == k && remainders.toSet().length == remainders.length && !remainders.contains(0), 'remainders of $k/$p: $remainders');
      // The digits are the remainders' tens: each digit is remainder
      // times ten over p, and the next remainder the rest.
      for (var i = 0; i < digits.length; i++) {
        check(digits[i] == remainders[i] * 10 ~/ p && remainders[(i + 1) % remainders.length] == remainders[i] * 10 % p, 'the division of $k/$p at $i');
      }
      check(Rules.blockValue(digits) * BigInt.from(p) == Rules.nines(digits.length) * BigInt.from(k), 'block of $k/$p times $p is not $k nines');
      final rotation = Rules.isRotation(digits, ones);
      if (rotation) rotations++;
      check(rotation == remOnes.contains(k), '$k/$p reads 1/$p round: $rotation, but $k a remainder of 1/$p: ${remOnes.contains(k)}');
      // Midy: an even period's halves add to nines.
      if (digits.length.isEven) {
        final h = digits.length ~/ 2;
        check(Rules.blockValue(digits.sublist(0, h)) + Rules.blockValue(digits.sublist(h)) == Rules.nines(h), 'Midy fails on $k/$p');
      }
    }
    check(rotations == byClock, 'rotations of 1/$p among k/$p: $rotations, period $byClock');
    check(rotations == remOnes.length, 'rotations of 1/$p: $rotations, remainders ${remOnes.length}');
    if (byClock == p - 1) fullOnDial++;
    if (byClock.isEven) evenPeriods++;
  }
  check(periods.entries.map((e) => '${e.key}:${e.value}').join(' ') == '3:1 7:6 11:2 13:6 17:16 19:18 23:22 29:28 31:15 37:3 41:5 43:21 47:46', 'periods $periods');
  check(fullOnDial == 6 && evenPeriods == 8, 'full turns on the dial $fullOnDial, even periods $evenPeriods');
  check(Rules.tellDigits(Rules.divide(1, 7).$1) == '142857' && Rules.divide(1, 7).$2.join(',') == '1,3,2,6,4,5', 'a seventh');
  check(Rules.tellDigits(Rules.divide(1, 13).$1) == '076923' && Rules.divide(1, 13).$2.join(',') == '1,10,9,12,3,4', 'a thirteenth');
  check(Rules.tellDigits(Rules.divide(2, 7).$1) == '285714' && Rules.tellDigits(Rules.divide(6, 7).$1) == '857142' && Rules.tellDigits(Rules.divide(2, 13).$1) == '153846', 'the sevenths and the two thirteenths');
  check(Rules.tellDigits(Rules.divide(1, 37).$1) == '027' && Rules.tellDigits(Rules.divide(1, 11).$1) == '09' && Rules.tellDigits(Rules.divide(1, 3).$1) == '3', 'the short blocks');
  check(Rules.blockValue([1, 4, 2]) + Rules.blockValue([8, 5, 7]) == BigInt.from(999), 'Midy on a seventh');
  final rotOf13 = [for (var k = 1; k < 13; k++) if (Rules.isRotation(Rules.divide(k, 13).$1, Rules.divide(1, 13).$1)) k];
  final rotOf2of13 = [for (var k = 1; k < 13; k++) if (Rules.isRotation(Rules.divide(k, 13).$1, Rules.divide(2, 13).$1)) k];
  check(rotOf13.join(',') == '1,3,4,9,10,12' && rotOf2of13.join(',') == '2,5,6,7,8,11', 'the thirteenth\'s rotations: $rotOf13 and $rotOf2of13');
  check(Rules.powMod(10, 3, 37) == 1 && 1000 - 1 == 27 * 37, 'ten cubed on thirty-seven');
  // Full-turn primes to a hundred.
  final full = <int>[];
  var oddPrimes = 0;
  for (var p = 3; p <= 100; p++) {
    if (!isPrime(p) || p == 5) continue;
    oddPrimes++;
    check((p - 1) % Rules.periodByClock(p) == 0, 'period of $p divides ${p - 1}');
    if (Rules.isFullTurn(p)) full.add(p);
  }
  check(oddPrimes == 23 && full.join(',') == '7,17,19,23,29,47,59,61,97', 'full-turn primes to a hundred: $full of $oddPrimes');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (final p in Rules.primes) {
      for (var k = 1; k < p; k++) {
        if (level.meets(p, k)) n++;
      }
    }
    check(n == level.ways, '${level.name}: ${level.ways} said, $n swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim.$1, aim.$2), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 40) {
        final (which, way) = play.next!;
        play = play.set(which, way);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == (7, 1) && Levels.at(1).aim == (7, 1) && Levels.at(2).aim == (7, 2) && Levels.at(3).aim == (37, 1), 'the aims');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every fraction k over p on the dial divided the long way, the thirteen odd primes from 3 to 47 but 5 and every k under each, ${Rules.settings} fractions, and each period set against the steps 10 takes to come back to 1 on the p-hour clock, the two agreeing on all ${Rules.settings}; every period divides p - 1, every block of digits times p is k rows of nines, every k over p reads the digits of 1 over p from another start exactly when k is a remainder of 1 over p, and Midy holds on every even period, the two halves adding to nines; the periods are 1, 6, 2, 6, 16, 18, 22, 28, 15, 3, 5, 21 and 46 for 3, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43 and 47, six of them the whole turn; and to a hundred the full-turn primes are 7, 17, 19, 23, 29, 47, 59, 61 and 97, nine of the 23 odd primes but five\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${Rules.settings} fractions land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${Rules.settings}, and the p - 1 remainders said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
