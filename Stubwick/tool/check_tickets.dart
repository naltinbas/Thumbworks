import 'dart:io';

import 'package:stubwick/ticket/level.dart';
import 'package:stubwick/ticket/levels.dart';
import 'package:stubwick/ticket/play.dart';
import 'package:stubwick/ticket/rules.dart';

/// Sums every ticket two ways, tries every slip, swap and twin turn on
/// every passing ticket, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_tickets.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  // The table and the doubling agree, and the table is every digit once.
  for (var d = 0; d < 10; d++) {
    check(Rules.doubled(d) == Rules.doubles[d], 'the double of $d');
  }
  check(Rules.doubles.toSet().length == 10, 'the doubles are not every digit once');
  check([for (var d = 0; d < 10; d++) Rules.withDouble(d)].join(',') == '0,3,6,9,2,6,9,2,5,8', 'a digit with its double');
  check(Rules.swapUnseen.toString() == '[(0, 9), (9, 0)]', 'the swap the table lets through: ${Rules.swapUnseen}');
  check(Rules.twinsUnseen.toString() == '[(2, 5), (3, 6), (4, 7)]', 'the twins the table lets through: ${Rules.twinsUnseen}');
  check(Rules.isDoubled(3) && Rules.isDoubled(1) && !Rules.isDoubled(4) && !Rules.isDoubled(2) && !Rules.isDoubled(0), 'which places double');

  // The sweep.
  var passing = 0, slips = 0, slipsPass = 0, swaps = 0, swapsPass = 0, swapsPassNot09 = 0, twins = 0, twinsPass = 0, twinsPassOdd = 0;
  var with09 = 0, withTwin = 0, palindromes = 0, alike = 0;
  final twinKinds = <String, int>{};
  var n = 0;
  for (final d in Rules.tickets) {
    check(Rules.numberOf(d) == n, 'ticket $n reads ${Rules.tell(d)}');
    n++;
    // The second voice: the sum by the table.
    var byTable = 0;
    for (var i = 0; i < Rules.places; i++) {
      byTable += Rules.isDoubled(i) ? Rules.doubles[d[i]] : d[i];
    }
    check(byTable == Rules.sum(d), 'the two sums differ on ${Rules.tell(d)}');
    if (!Rules.passes(d)) continue;
    passing++;
    check(Rules.checkFor(d) == d[4], 'the check digit of ${Rules.tell(d)}');
    for (var i = 0; i < Rules.places; i++) {
      for (var x = 0; x < 10; x++) {
        if (x == d[i]) continue;
        slips++;
        if (Rules.passes(List.of(d)..[i] = x)) slipsPass++;
      }
    }
    for (var i = 0; i + 1 < Rules.places; i++) {
      if (d[i] == d[i + 1]) {
        for (var b = 0; b < 10; b++) {
          if (b == d[i]) continue;
          twins++;
          if (Rules.passes(List.of(d)..[i] = b..[i + 1] = b)) {
            twinsPass++;
            final a = d[i];
            final kind = a < b ? '$a$a with $b$b' : '$b$b with $a$a';
            twinKinds[kind] = (twinKinds[kind] ?? 0) + 1;
            if (!Rules.twinsUnseen.any((p) => (p.$1 == a && p.$2 == b) || (p.$1 == b && p.$2 == a))) twinsPassOdd++;
          }
        }
        continue;
      }
      swaps++;
      if (Rules.passes(List.of(d)..[i] = d[i + 1]..[i + 1] = d[i])) {
        swapsPass++;
        if (!{d[i], d[i + 1]}.containsAll({0, 9})) swapsPassNot09++;
      }
    }
    if (Level.swapPlaces(d).isNotEmpty) with09++;
    if (Level.twinPlaces(d).isNotEmpty) withTwin++;
    if (Level.palindrome(d)) palindromes++;
    if (d.every((x) => x == d[0])) alike++;
  }
  check(n == 100000 && passing == 10000, 'tickets $n, passing $passing');
  check(slips == 450000 && slipsPass == 0, 'slips $slips, passing $slipsPass');
  check(swaps == 36000 && swapsPass == 800 && swapsPassNot09 == 0, 'swaps $swaps, passing $swapsPass, not 0 and 9: $swapsPassNot09');
  check(twins == 36000 && twinsPass == 2400 && twinsPassOdd == 0 && twinKinds.length == 3 && twinKinds.values.every((k) => k == 800), 'twins $twins, passing $twinsPass, odd $twinsPassOdd, kinds $twinKinds');
  check(with09 == 732 && withTwin == 2132 && palindromes == 100 && alike == 1, 'with a 0 by a 9: $with09, with a slipping twin: $withTwin, palindromes $palindromes, alike $alike');
  check(Rules.passes([4, 9, 9, 2, 4]) && Rules.adds([4, 9, 9, 2, 4]).join(',') == '4,9,9,4,4' && Rules.sum([4, 9, 9, 2, 4]) == 30, 'the ticket 4 9 9 2 4');
  check(!Rules.passes([0, 0, 0, 0, 1]) && Rules.passes([0, 0, 0, 0, 0]) && Rules.passes([0, 0, 0, 9, 1]) && Rules.passes([0, 0, 1, 3, 3]) && Rules.passes([0, 0, 1, 6, 6]), 'the named tickets');

  // The asks.
  for (final level in Levels.all) {
    var ways = 0;
    for (final d in Rules.tickets) {
      if (level.meets(d)) ways++;
    }
    check(ways == level.ways, '${level.name}: ${level.ways} said, $ways swept');
    final aim = level.aim;
    check((aim == null) == !level.winnable, '${level.name}: aim $aim');
    if (aim != null) check(level.meets(aim), '${level.name}: the aim misses');
    final open = Play.of(level);
    check(!open.isOver, '${level.name}: opens over');
    if (aim != null) {
      var play = open;
      var steps = 0;
      while (!play.isDone && steps < 40) {
        final (place, by) = play.next!;
        play = play.turn(place, by);
        steps++;
      }
      check(play.isDone, '${level.name}: the pointer never lands');
    }
  }
  check(Levels.at(1).aim!.join() == '00091' && Levels.at(2).aim!.join() == '00133' && Levels.at(3).aim!.join() == '00000', 'the aims');
  final dead = Play.of(Levels.at(4)).turn(4, -1).turn(0, 1).turn(0, -1).turn(1, 1).turn(1, -1).turn(2, 1);
  check(dead.slips == 3 && dead.gaveUp, 'the slip unseen does not admit it after three slips');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every ticket of five digits taken, ${commas(n)}, and summed by Luhn\'s doubling from the right and again by the table of doubles, 0, 2, 4, 6, 8, 1, 3, 5, 7 and 9, the two agreeing on all: ${commas(passing)} pass, one check digit for every run of four; every single slip of a digit on every passing ticket tried, ${commas(slips)}, and every one caught, as the table says it must be, no two digits doubling alike; every swap of two unlike neighbours tried, ${commas(swaps)}, and $swapsPass pass, every one a 0 and a 9, the one pair the table lets through; every twin pair turned to another, ${commas(twins)}, and ${commas(twinsPass)} pass, 22 with 55, 33 with 66 and 44 with 77 either way, the three the table names, 800 a kind; $with09 passing tickets hold a 0 by a 9, ${commas(withTwin)} a slipping twin, $palindromes read the same backwards and 0 0 0 0 0 alone is one digit throughout; 4 9 9 2 4 adds 4, 9, 9, 4 and 4, thirty, and passes\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(n)} tickets land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(n)}, and the table of doubles said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
