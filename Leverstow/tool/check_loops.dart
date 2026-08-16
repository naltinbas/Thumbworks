import 'dart:io';

import 'package:leverstow/lever/frac.dart';
import 'package:leverstow/lever/level.dart';
import 'package:leverstow/lever/levels.dart';
import 'package:leverstow/lever/play.dart';
import 'package:leverstow/lever/rules.dart';

/// Runs every loop of levers there is, solves each one's climb two
/// ways, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_loops.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  // The levers on their own.
  check(Rules.odds('A', 0) == Frac.of(1, 2) && Rules.odds('A', 1) == Frac.of(1, 2),
      'lever A\'s odds');
  check(Rules.odds('B', 0) == Frac.of(1, 10) && Rules.odds('B', 1) == Frac.of(3, 4),
      'lever B\'s odds');
  final restingB = Rules.resting('B');
  check(
      restingB[0] == Frac.of(5, 13) &&
          restingB[1] == Frac.of(2, 13) &&
          restingB[2] == Frac.of(6, 13),
      'B at rest: $restingB');
  check(Rules.resting('A').every((share) => share == Frac.of(1, 3)),
      'A at rest');
  // The two sides of B's fairness, told the way the tile tells them.
  check(Frac.of(5) * Frac.of(4, 5) == Frac.of(4) &&
      Frac.of(8) * Frac.of(1, 2) == Frac.of(4), 'B\'s two sides');
  check(Rules.climb('A') == Frac.zero && Rules.climb('B') == Frac.zero,
      'a lever on its own is fair');

  // The purse, carried as a spread against every run of wins and
  // losses there is.
  for (final loop in ['A', 'B', 'ABB', 'ABABB']) {
    for (final rounds in [1, 4, 9, 12]) {
      check(Rules.purse(loop, rounds).last == Rules.purseByEveryRun(loop, rounds),
          'the purse of $loop after $rounds rounds');
    }
  }
  check(Rules.purse('ABB', 4).last == Frac.of(7, 20), 'ABB after four rounds');

  // Every loop there is, its climb folded to three remainders, and the
  // long chain of remainder and slot to check the fold.
  final climbs = <String, Frac>{};
  var loops = 0, climbing = 0, flat = 0, sinking = 0;
  final flatOnes = <String>[];
  for (final loop in Rules.loops()) {
    loops++;
    final climb = Rules.climb(loop);
    climbs[loop] = climb;
    if (climb > Frac.zero) {
      climbing++;
    } else if (climb == Frac.zero) {
      flat++;
      flatOnes.add(loop);
    } else {
      sinking++;
    }
    if (loop.length <= 6) {
      check(Rules.climbByChain(loop) == climb,
          '$loop: $climb folded against ${Rules.climbByChain(loop)} on the long chain');
    }
    // A loop and the same loop written out twice climb at the same rate.
    if (loop.length * 2 <= Rules.most) {
      check(climbs[loop + loop] == null || climbs[loop + loop] == climb,
          '$loop against ${loop + loop}');
    }
  }
  check(loops == 8190, 'loops swept: $loops');
  check(sinking == 0, 'loops that sink: $sinking');
  check(climbing == 8154 && flat == 36, 'climbing $climbing, flat $flat');
  // The flat ones are exactly the single levers and the alternations.
  for (final loop in flatOnes) {
    final alternating = [
      for (var i = 0; i < loop.length; i++) i.isEven ? loop[0] : (loop[0] == 'A' ? 'B' : 'A'),
    ].join();
    check(Rules.oneLever(loop) || loop == alternating, 'flat loop $loop');
  }
  check(flatOnes.where(Rules.oneLever).length == 24, 'flat single-lever loops');

  // The named climbs, against the sweep.
  final best = climbs.values.reduce((a, b) => a > b ? a : b);
  check(best == Level.best, 'the best climb: $best');
  check(climbs['ABB'] == Level.famous, 'the famous climb: ${climbs['ABB']}');
  check(climbs['BBA'] == Level.famous && climbs['BAB'] == Level.famous,
      'the famous climb turned about');
  final bestFour = climbs.entries
      .where((e) => e.key.length == 4)
      .map((e) => e.value)
      .reduce((a, b) => a > b ? a : b);
  check(bestFour == Level.bestFour, 'the best four: $bestFour');
  check(bestFour < Level.famous, 'a four against a three');
  final bestByLength = <int, Frac>{};
  for (final e in climbs.entries) {
    final at = bestByLength[e.key.length];
    if (at == null || e.value > at) bestByLength[e.key.length] = e.value;
  }

  // The asks, counted over every loop.
  final ways = <String, int>{};
  for (final level in Levels.all) {
    var n = 0;
    var cheapest = -1;
    final aims = <String>[];
    for (final loop in climbs.keys) {
      if (!level.meets(loop)) continue;
      n++;
      final taps = Rules.cost(Rules.opening, loop);
      if (cheapest < 0 || taps < cheapest) {
        cheapest = taps;
        aims
          ..clear()
          ..add(loop);
      } else if (taps == cheapest) {
        aims.add(loop);
      }
    }
    ways[level.name] = n;
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    if (level.winnable) {
      check(level.meets(level.aim), '${level.name}: the aim misses');
      check(Rules.cost(Rules.opening, level.aim) == cheapest,
          '${level.name}: the aim is ${Rules.cost(Rules.opening, level.aim)} taps, cheapest $cheapest');
      check(level.fewest == cheapest, '${level.name}: fewest');
    } else {
      check(level.aim.isEmpty && n == 0, '${level.name} has an aim');
    }
  }

  // The pointer lands every ask it can, in the fewest taps, and never
  // wanders.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 20) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer at ${play.loop}');
      if (aim == null) break;
      final was = play.away!;
      play = switch (aim.$1) {
        'add' => play.longer,
        'drop' => play.shorter,
        _ => play.flip(aim.$2),
      };
      check(play.away == was - 1, '${level.name} wandered at ${play.loop}');
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  // The hopeless ask, admitted once both levers have been run alone.
  var alone = Play.of(Levels.all.last);
  alone = alone.flip(0);
  check(alone.gaveUp, 'one lever forever, after A and B alone');

  if (failed) {
    stderr.writeln('the machine is not sound; no bake');
    exit(1);
  }

  final famousLoops = climbs.entries
      .where((e) => e.value == Level.famous)
      .map((e) => e.key)
      .toList();
  final bestLoops =
      climbs.entries.where((e) => e.value == best).map((e) => e.key).toList();

  final ledger = StringBuffer()
    ..write('every loop of twelve slots or fewer taken, ${commas(loops)} of '
        'them, and each one\'s climb solved twice, once folded onto the '
        'three remainders three leaves of the purse and once on the long '
        'chain of remainder and slot, the two agreeing on every loop of six '
        'slots or fewer, which is where the long chain is still small '
        'enough to solve: both levers are fair on their own, A because the '
        'coin is and B because it rests on the remainders in the shares '
        '${restingB.join(', ')}, so five times four fifths is four as '
        'eight times a half is')
    ..write('; and yet ${commas(climbing)} of the ${commas(loops)} loops '
        'climb, $flat stand still and none sinks, the still ones being '
        'exactly the ${flatOnes.where(Rules.oneLever).length} loops of a '
        'single lever and the ${flat - flatOnes.where(Rules.oneLever).length} '
        'that alternate')
    ..write('; the loop Parrondo told it with, A once and B twice, climbs '
        '${Level.famous} of a coin a round, ${famousLoops.length} loops '
        'climb at that rate, and the best of all is $best from '
        '${bestLoops.length} loops, the turnings of BBABA and those written '
        'out twice')
    ..write('; the best a loop of four can do is ${Level.bestFour}, slower '
        'than the best three, so the best climb per slot does not grow with '
        'the loop: ')
    ..write([
      for (var length = 1; length <= 6; length++)
        '${bestByLength[length]} at $length'
    ].join(', '))
    ..write('; the purse itself is carried as a spread of purses rather '
        'than an average, and after four rounds of ABB it stands at '
        '${Rules.purse('ABB', 4).last} of a coin, which walking all sixteen '
        'runs of wins and losses gives too');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(loops)} loops land it, the '
            'fewest ${level.fewest} taps from the opening'
        : 'none of the ${commas(loops)}, and the two levers say so on a '
            'finger';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
