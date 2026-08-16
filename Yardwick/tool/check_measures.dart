import 'dart:io';

import 'package:yardwick/yard/levels.dart';
import 'package:yardwick/yard/play.dart';
import 'package:yardwick/yard/rules.dart';

/// Measures every pair of hedges two ways, counts what Lucas promised,
/// and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_measures.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  check(Rules.fib(1) == BigInt.one && Rules.fib(2) == BigInt.one && Rules.fib(12) == BigInt.from(144) && Rules.fib(30) == BigInt.from(832040), 'the Fibonacci numbers');
  for (var i = 3; i <= 30; i++) {
    check(Rules.fib(i) == Rules.fib(i - 1) + Rules.fib(i - 2), 'the ${i}th is not the two before it added');
  }
  // The identity behind it: F(m + n) = F(m - 1) F(n) + F(m) F(n + 1).
  for (var m = 2; m <= 15; m++) {
    for (var n = 1; n <= 15; n++) {
      check(Rules.fib(m + n) == Rules.fib(m - 1) * Rules.fib(n) + Rules.fib(m) * Rules.fib(n + 1), 'the addition rule at $m, $n');
    }
  }
  var pairs = 0, coprime = 0, sly = 0, five = 0, eight = 0, fiftyFive = 0, divides = 0, whole = 0, oddShare = 0, long = 0;
  for (var m = 1; m <= Rules.most; m++) {
    for (var n = 1; n <= Rules.most; n++) {
      pairs++;
      final byHedges = Rules.measureByHedges(m, n), byCounts = Rules.measureByCounts(m, n);
      check(byHedges == byCounts, 'the two yardsticks differ at $m, $n: $byHedges and $byCounts');
      check(Rules.divides(m, n) == Rules.dividesByCounts(m, n), 'the measuring differs at $m, $n');
      final g = Rules.gcd(m, n);
      if (byHedges == BigInt.one) coprime++;
      if (byHedges == BigInt.one && g > 1 && m >= 3 && n >= 3) sly++;
      if (byHedges == BigInt.from(5)) five++;
      if (byHedges == BigInt.from(8)) eight++;
      if (byHedges == BigInt.from(55)) fiftyFive++;
      if (byHedges >= BigInt.from(55)) long++;
      if (Rules.divides(m, n)) divides++;
      if (m >= 3 && m < n && Rules.divides(m, n)) whole++;
      if (byHedges > BigInt.one && g == 1) oddShare++;
      check((byHedges == BigInt.one) == (g <= 2), 'coprime hedges and counts at $m, $n');
    }
  }
  check(pairs == 900 && coprime == 698 && sly == 114 && five == 23 && eight == 19 && fiftyFive == 7 && long == 37 && divides == 126 && whole == 38 && oddShare == 0, 'pairs $pairs, coprime $coprime, sly $sly, five $five, eight $eight, fifty-five $fiftyFive, long $long, divides $divides, whole $whole, odd share $oddShare');
  final primeCounts = [for (var i = 1; i <= 30; i++) if (Rules.isPrime(Rules.fib(i))) i];
  check(primeCounts.join(',') == '3,4,5,7,11,13,17,23,29', 'prime hedges at $primeCounts');
  check(Rules.fib(19) == BigInt.from(4181) && BigInt.from(4181) == BigInt.from(37) * BigInt.from(113), 'the nineteenth');
  check(Rules.measureByHedges(30, 12) == BigInt.from(8) && Rules.measureByHedges(30, 15) == BigInt.from(610) && Rules.measureByHedges(4, 6) == BigInt.one && Rules.measureByHedges(30, 30) == BigInt.from(832040), 'the named pairs');
  check(Rules.euclidOnCounts(30, 12).toString() == '[(30, 12), (12, 6), (6, 0)]', 'Euclid on the counts');
  check(Rules.tell(Rules.fib(30)) == '832,040', 'the telling');

  // The asks.
  for (final level in Levels.all) {
    var ways = 0;
    for (var m = 1; m <= Rules.most; m++) {
      for (var n = 1; n <= Rules.most; n++) {
        if (level.meets(m, n)) ways++;
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
      while (!play.isDone && steps < 60) {
        final (which, by) = play.next!;
        play = play.step(which, by);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(0).aim == (5, 5) && Levels.at(1).aim == (4, 6) && Levels.at(2).aim == (3, 6) && Levels.at(3).aim == (10, 10), 'the aims');
  final dead = Play.of(Levels.at(4)).step('m', 1).step('m', 1).step('m', 1).step('n', 1).step('n', 1);
  check(dead.seen.length == 3 && dead.gaveUp, 'the odd share does not admit it after three coprime settings');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every pair of counts from one to thirty taken, $pairs settings, and the yardstick found on each by Euclid on the two hedges themselves and again as the Fibonacci number of the counts\' common measure, the two agreeing on all $pairs, and the addition rule that carries the proof held on every pair of counts to fifteen: the hedges are coprime on $coprime settings, exactly those whose counts measure by one or by two, $sly of them sly with both counts above two; the yardstick is five on $five settings, eight on $eight, fifty-five on $fiftyFive and fifty-five or longer on $long, 832,040 the longest, both counts thirty; the first hedge measures the second exactly on $divides settings, exactly those where the first count divides the second or is one or two, $whole with the first count three or more and below the second; the hedges of prime length stand at counts 3, 4, 5, 7, 11, 13, 17, 23 and 29, the nineteenth being 4,181, 37 times 113; and no setting has the hedges sharing a factor while the counts share none\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(pairs)} settings land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(pairs)}, and Euclid on the counts said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
