import 'dart:io';

import 'package:knowsley/pair/levels.dart';
import 'package:knowsley/pair/play.dart';
import 'package:knowsley/pair/rules.dart';

/// Asks the four things of every pair, sieves the whole set again the
/// other way, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_pairs.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  final pairs = Rules.pairs;
  check(pairs.length == 2352 && pairs.first == (2, 3) && pairs.last == (49, 51), 'the pairs: ${pairs.length}');
  for (final (x, y) in pairs) {
    check(Rules.valid(x, y), 'a pair out of bounds: $x, $y');
  }
  check(!Rules.valid(2, 2) && !Rules.valid(1, 5) && !Rules.valid(49, 52) && Rules.valid(49, 51), 'the bounds');

  // The first voice: the four things asked of every pair.
  final one = <(int, int)>{}, two = <(int, int)>{}, three = <(int, int)>{}, four = <(int, int)>{};
  var evenTwo = 0;
  for (final q in pairs) {
    final (a, b, c, d) = Rules.said(q.$1, q.$2);
    if (a) one.add(q);
    if (b) two.add(q);
    if (c) three.add(q);
    if (d) four.add(q);
    if (b && (q.$1 + q.$2).isEven) evenTwo++;
    check(!b || a, 'S knew before P was in the dark: $q');
    check(!c || b, 'P then knew before S spoke: $q');
    check(!d || c, 'S then knew before P did: $q');
  }
  check(one.length == 1747 && two.length == 145 && three.length == 86 && four.length == 1, 'the four things: ${one.length}, ${two.length}, ${three.length}, ${four.length}');
  check(four.single == (4, 13), 'the answer ${four.single}');
  check(evenTwo == 0, 'even sums S spoke for: $evenTwo');

  // The second voice: the whole set narrowed by each thing said in turn.
  final narrowed = Rules.narrowed;
  check(narrowed.length == 4, 'the narrowing has ${narrowed.length} steps');
  final byName = ['P in the dark', 'S knew it', 'P then knew', 'S then knew'];
  for (var i = 0; i < 4; i++) {
    final a = [one, two, three, four][i], b = narrowed[i];
    check(a.length == b.length && a.containsAll(b), '${byName[i]}: ${a.length} pairs one way, ${b.length} the other');
  }

  // The sums, the splits, the primes.
  final sums = Rules.speakingSums;
  check(sums.join(',') == '11,17,23,27,29,35,37,41,47,53', 'the speaking sums $sums');
  for (final s in sums) {
    check(s.isOdd && !Rules.isPrime(s - 2), 'a speaking sum even or two more than a prime: $s');
  }
  var withSpeakingSum = 0;
  for (final s in sums) {
    withSpeakingSum += Rules.splitsOfSum(s).length;
  }
  check(withSpeakingSum == 145, 'pairs with a speaking sum $withSpeakingSum');
  final keeps = {for (final s in sums) s: Rules.splitsOfSum(s).where((q) => Rules.pInDark(q.$1 * q.$2) && Rules.pNowKnows(q.$1 * q.$2)).length};
  check(keeps[17] == 1 && keeps[11] == 3 && keeps[23] == 3 && keeps[27] == 9 && keeps.values.where((k) => k == 1).length == 1, 'the splits kept $keeps');
  for (var s = 8; s <= 100; s += 2) {
    final split = Rules.primeSplit(s);
    check(split != null && Rules.isPrime(split.$1) && Rules.isPrime(split.$2) && split.$1 < split.$2 && split.$1 + split.$2 == s, 'no split of $s into two different primes');
    check(!Rules.pInDark(split!.$1 * split.$2), 'the primes\' product leaves P in the dark: $s');
  }
  check(Rules.primeSplit(6) == null && Rules.splitsOfSum(6).length == 1 && !Rules.pInDark(8) && Rules.splitsOfSum(4).isEmpty, 'the sums 4 and 6');
  check(Rules.splitsOfProduct(52).length == 2 && Rules.splitsOfProduct(6).length == 1 && Rules.splitsOfProduct(18).length == 2, 'the splits of 52, 6 and 18');
  check(Rules.said(2, 9) == (true, true, true, false) && Rules.said(2, 3) == (false, false, false, false), 'the pairs 2, 9 and 2, 3');

  // The asks.
  for (final level in Levels.all) {
    var ways = 0;
    for (final (x, y) in pairs) {
      if (level.meets(x, y)) ways++;
    }
    check(ways == level.ways, '${level.name}: ${level.ways} said, $ways sieved');
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
  check(Levels.at(3).aim == (4, 13) && Levels.at(1).aim == (2, 9) && Levels.at(0).aim == (2, 3), 'the aims');
  final dead = Play.of(Levels.at(4)).step('y', 1).step('y', 1).step('y', 1).step('y', 1).step('y', 1);
  check(dead.seen.length == 3 && dead.gaveUp, 'the even sum does not admit it after three even sums');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every pair of whole numbers from 2 up, the smaller below the larger and the two adding to 100 at most, taken, ${commas(pairs.length)} pairs, and the four things asked of each, P in the dark, S knowing it, P then knowing and S then knowing, then the whole set narrowed by each thing said in turn, the two agreeing at every step: ${commas(one.length)} pairs leave P in the dark and 605 tell him at once, 145 add to a sum S could speak for, ten sums, 11, 17, 23, 27, 29, 35, 37, 41, 47 and 53, every one odd and none two more than a prime, 86 let P then know, and one lets S know too, 4 and 13, sum 17 and product 52; of the ten sums 17 alone keeps one split once P has spoken, 11 and 23 keeping three and 27 nine; and every even sum from 8 to 100 splits into two different primes whose product tells P at once, so no even sum lets S speak, 6 splitting only into 2 and 4 and 4 not at all\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(pairs.length)} pairs land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(pairs.length)}, and the two primes said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
