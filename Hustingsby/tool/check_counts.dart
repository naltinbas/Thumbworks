import 'dart:io';

import 'package:hustingsby/poll/levels.dart';
import 'package:hustingsby/poll/play.dart';
import 'package:hustingsby/poll/rules.dart';

/// Reads every order of every poll to eight and eight through, holds
/// the sweep against Bertrand and the reflection, and refuses the bake
/// on any disagreement: this is what `make counts` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // Every level's label against its own sweep, the aim landing it, and
  // no level over at the opening.
  for (final level in Levels.all) {
    final met = level.orders.where(level.meets).length;
    if (met != level.ways || level.orders.length != Rules.choose(level.ballots, level.ash)) {
      stderr.writeln('${level.name}: sweep finds $met of ${level.orders.length}, label says ${level.ways}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? level.winnable : !level.meets(aim)) {
      stderr.writeln('${level.name}: the aim does not land it');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
    if (level.winnable) {
      var play = Play.of(level);
      while (!play.isDone) {
        final n = play.next!;
        play = n == 2 ? play.back : play.draw(n == 0);
      }
    }
  }

  // The three voices on every poll to eight and eight: the sweep against
  // Bertrand and the reflection for the orders that keep Ash ahead, and
  // against the formula for the orders that never put him behind.
  var polls = 0, orders = 0;
  for (var a = 0; a <= 8; a++) {
    for (var b = 0; b <= 8; b++) {
      final os = Rules.orders(a, b);
      polls++;
      orders += os.length;
      if (os.length != Rules.choose(a + b, a) || os.map(Rules.told).toSet().length != os.length) {
        stderr.writeln('$a V $b: ${os.length} ORDERS');
        exit(1);
      }
      final ahead = os.where(Rules.aheadThroughout).length, never = os.where(Rules.neverBehind).length;
      final bertrand = a > b ? Rules.aheadByBertrand(a, b) : 0, reflection = a > b ? Rules.aheadByReflection(a, b) : 0;
      if (ahead != bertrand || ahead != reflection) {
        stderr.writeln('$a V $b: $ahead AHEAD THROUGHOUT, BERTRAND $bertrand, REFLECTION $reflection');
        exit(1);
      }
      if (never != (a >= b ? Rules.neverBehindByFormula(a, b) : 0)) {
        stderr.writeln('$a V $b: $never NEVER BEHIND, FORMULA ${Rules.neverBehindByFormula(a, b)}');
        exit(1);
      }
      if (a > 0 && a == b && ahead != 0) {
        stderr.writeln('$a V $b: A LEVEL POLL WITH ASH AHEAD THROUGHOUT');
        exit(1);
      }
    }
  }
  if (polls != 81 || orders != 48619) {
    stderr.writeln('$polls POLLS, $orders ORDERS');
    exit(1);
  }
  // The named facts of the asks.
  final tallies = <String>[];
  for (final (a, b) in [(3, 2), (4, 3), (5, 3), (4, 4)]) {
    final os = Rules.orders(a, b);
    final levelHist = <int, int>{}, changes = <int, int>{};
    for (final o in os) {
      levelHist[Rules.levels(o)] = (levelHist[Rules.levels(o)] ?? 0) + 1;
      changes[Rules.changesOfHands(o)] = (changes[Rules.changesOfHands(o)] ?? 0) + 1;
    }
    tallies.add('$a v $b: ${os.length} orders, ahead ${os.where(Rules.aheadThroughout).length}, never behind ${os.where(Rules.neverBehind).length}, levels ${[for (var k = 0; k <= 4; k++) levelHist[k] ?? 0]}, changes ${[for (var k = 0; k <= 4; k++) changes[k] ?? 0]}');
  }
  if (tallies.join(' | ') !=
      '3 v 2: 10 orders, ahead 2, never behind 5, levels [2, 4, 4, 0, 0], changes [5, 4, 1, 0, 0] | '
          '4 v 3: 35 orders, ahead 5, never behind 14, levels [5, 10, 12, 8, 0], changes [14, 14, 6, 1, 0] | '
          '5 v 3: 56 orders, ahead 14, never behind 28, levels [14, 18, 16, 8, 0], changes [28, 20, 7, 1, 0] | '
          '4 v 4: 70 orders, ahead 0, never behind 14, levels [0, 10, 20, 24, 16], changes [28, 28, 12, 2, 0]') {
    stderr.writeln('THE TALLIES ARE ${tallies.join(' | ')}');
    exit(1);
  }
  final clean = Rules.orders(3, 2).where(Rules.aheadThroughout).map(Rules.told).toList();
  if (clean.toString() != '[A A A B B, A A B A B]') {
    stderr.writeln('THE CLEAN LEADS ARE $clean');
    exit(1);
  }

  stdout.writeln(
      'every order of every poll to eight Ash and eight Birch read through ballot '
      'by ballot, 81 polls and 48,619 orders: the orders that keep Ash ahead '
      'after every ballot are the majority over the poll of them all, Bertrand\'s '
      '(a - b)/(a + b) of C(a+b, a), and the reflection\'s C(a+b-1, a-1) less '
      'C(a+b-1, a), on every poll, and nought on every level poll; the orders '
      'that never put him behind are (a - b + 1)/(a + 1) of the whole, Catalan\'s '
      'numbers when the poll is level; three to two keeps Ash ahead in 2 orders '
      'of 10, A A A B B and A A B A B; four to three stands level twice in 12 of '
      '35; five to three sees the lead change hands exactly twice in 7 of 56; '
      'four to four never puts Ash behind in 14 of 70 and never keeps him ahead '
      'throughout');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(16);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${level.orders.length} orders ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: none of the ${level.orders.length}, and the level end said so first');
  }
}
