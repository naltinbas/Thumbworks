import 'dart:io';

import 'package:hoopwell/hoop/levels.dart';
import 'package:hoopwell/hoop/play.dart';
import 'package:hoopwell/hoop/rules.dart';

/// Lays every board the hoop allows, lights its lamps three ways, and
/// refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_hoops.dart
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

  check(Rules.holes == 7, 'holes on the hoop: ${Rules.holes}');
  for (var d = 2; d < Rules.holes; d++) {
    check(Rules.holes % d != 0, 'seven divides by $d');
  }

  final boards = 1 << (Rules.holes * 2);
  var laid = 0, under = 0, onFloor = 0, piledVersusPoured = 0;
  final spread = <(int, int), Map<int, int>>{};
  var mostWays = 0;

  for (var dark = 0; dark < 1 << Rules.holes; dark++) {
    for (var pale = 0; pale < 1 << Rules.holes; pale++) {
      laid++;
      // The first voice: the pale ring turned and piled.
      final piled = Rules.lamps(dark, pale);
      // The second: the rings multiplied out hole by hole.
      final poured = Rules.lampsByWays(dark, pale);
      if (piled != poured) piledVersusPoured++;
      check(piled == poured,
          'the two voices differ on ${Rules.write(dark)} and '
          '${Rules.write(pale)}');
      final counts = Rules.ways(dark, pale);
      var total = 0;
      for (final n in counts) {
        total += n;
        if (n > mostWays) mostWays = n;
      }
      check(total == Rules.count(dark) * Rules.count(pale),
          'the ways do not add up on ${Rules.write(dark)} and '
          '${Rules.write(pale)}');

      final a = Rules.count(dark), b = Rules.count(pale);
      final lit = Rules.count(piled);
      if (a == 0 || b == 0) {
        check(lit == 0, 'a lamp lit with an empty ring');
        continue;
      }
      final floor = Rules.floor(a, b);
      // The third voice, which lights nothing: the floor read off the
      // divisors. On a prime hoop it comes back to the floor itself.
      check(Rules.floorByDivisors(Rules.holes, a, b) == floor,
          'the divisor reading differs at $a and $b');
      if (lit < floor) under++;
      if (lit == floor) onFloor++;
      final key = (a, b);
      spread[key] = (spread[key] ?? <int, int>{});
      spread[key]![lit] = (spread[key]![lit] ?? 0) + 1;
    }
  }

  check(laid == boards, 'boards laid: $laid');
  check(laid == 16384, 'boards on a hoop of seven: $laid');
  check(piledVersusPoured == 0,
      'the two voices differed $piledVersusPoured times');
  check(under == 0, 'boards under the floor: $under');
  check(mostWays == Rules.holes, 'the most ways one lamp is lit: $mostWays');

  // The spreads the asks are cut from.
  check(spread[(3, 3)]!.length == 3, 'three and three reach '
      '${spread[(3, 3)]!.length} counts');
  check(spread[(3, 3)]![5] == 147, 'three and three at five: '
      '${spread[(3, 3)]![5]}');
  check(spread[(3, 3)]![6] == 686, 'three and three at six');
  check(spread[(3, 3)]![7] == 392, 'three and three at seven');
  check(spread[(2, 4)]![5] == 147, 'two and four at five');
  check(spread[(2, 4)]![6] == 441, 'two and four at six');
  check(spread[(2, 4)]![7] == 147, 'two and four at seven');
  check(spread[(2, 4)]![4] == null, 'two and four reached four lamps');

  // Vosper: every board sitting exactly on the floor is a pair of runs
  // at one shared step, so long as the floor is not the hoop less one.
  var floorBoards = 0, runPairs = 0;
  for (var dark = 0; dark < 1 << Rules.holes; dark++) {
    final a = Rules.count(dark);
    if (a < 2) continue;
    for (var pale = 0; pale < 1 << Rules.holes; pale++) {
      final b = Rules.count(pale);
      if (b < 2) continue;
      final floor = Rules.floor(a, b);
      if (floor > Rules.holes - 2) continue;
      if (Rules.count(Rules.lamps(dark, pale)) != floor) continue;
      floorBoards++;
      var found = false;
      for (var by = 1; by < Rules.holes; by++) {
        if (Rules.isRun(dark, by) && Rules.isRun(pale, by)) found = true;
      }
      if (found) runPairs++;
    }
  }
  check(floorBoards == runPairs,
      'boards on the floor that are not a pair of runs: '
      '${floorBoards - runPairs}');
  check(floorBoards == 882, 'boards sitting on the floor: $floorBoards');

  // The walk the finger proof takes, and the count it turns on.
  var walked = 0, blockRule = 0;
  for (var dark = 0; dark < 1 << Rules.holes; dark++) {
    if (Rules.count(dark) != 2) continue;
    final order = Rules.walk(dark);
    check(order.toSet().length == Rules.holes,
        'the step misses a hole from ${Rules.write(dark)}');
    for (var pale = 1; pale < 1 << Rules.holes; pale++) {
      walked++;
      // Every run of pale stones along the walk costs one lamp beyond
      // the pale stones themselves.
      if (Rules.count(Rules.lamps(dark, pale)) ==
          Rules.count(pale) + Rules.runEnds(dark, pale)) {
        blockRule++;
      }
    }
  }
  check(walked == blockRule,
      'the run rule failed on ${walked - blockRule} of $walked');

  // The asks.
  for (final level in Levels.all) {
    var n = 0, cheapest = 99;
    for (var dark = 0; dark < 1 << Rules.holes; dark++) {
      if (Rules.count(dark) != level.dark) continue;
      for (var pale = 0; pale < 1 << Rules.holes; pale++) {
        if (!level.meets((dark, pale))) continue;
        n++;
        final away = Rules.between(Rules.opening, (dark, pale));
        if (away < cheapest) cheapest = away;
      }
    }
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    check(!level.meets(Rules.opening),
        '${level.name} is landed before it is touched');
    if (level.winnable) {
      check(level.fewest == cheapest,
          '${level.name}: ${level.fewest} against $cheapest');
      check(level.lit >= level.floor,
          '${level.name} asks for less than the floor and is called winnable');
    } else {
      check(level.fewest == null && n == 0, '${level.name} was landed');
      check(level.lit < level.floor,
          '${level.name} is hopeless for some other reason than the floor');
    }
  }

  // The hopeless ask, and the walk that says why. Its shape never gets
  // under five lamps, and the fewest runs any of its boards has is one.
  final dead = Levels.all.last;
  var fewestRuns = Rules.holes;
  for (var dark = 0; dark < 1 << Rules.holes; dark++) {
    if (Rules.count(dark) != dead.dark) continue;
    for (var pale = 0; pale < 1 << Rules.holes; pale++) {
      if (Rules.count(pale) != dead.pale) continue;
      final runs = Rules.runEnds(dark, pale);
      if (runs < fewestRuns) fewestRuns = runs;
      check(Rules.count(Rules.lamps(dark, pale)) >= dead.floor,
          'a board of the dead shape got under the floor');
    }
  }
  check(fewestRuns == 1, 'the fewest runs on the dead shape: $fewestRuns');
  check(dead.boards == 735, 'boards of the dead shape: ${dead.boards}');

  // The same shape on a hoop of six, where the floor gives out.
  var onSix = 0;
  for (var dark = 0; dark < 1 << 6; dark++) {
    if (Rules.count(dark) != 2) continue;
    for (var pale = 0; pale < 1 << 6; pale++) {
      if (Rules.count(pale) != 4) continue;
      var lit = 0;
      for (var x = 0; x < 6; x++) {
        if (dark >> x & 1 == 0) continue;
        for (var y = 0; y < 6; y++) {
          if (pale >> y & 1 == 1) lit |= 1 << ((x + y) % 6);
        }
      }
      if (Rules.count(lit) == 4) onSix++;
    }
  }
  check(onSix == 9, 'the same shape on a hoop of six: $onSix');
  check(Rules.floorByDivisors(6, 2, 4) == 4,
      'the divisor reading on a hoop of six: '
      '${Rules.floorByDivisors(6, 2, 4)}');

  // The pointer lands every ask it can, in the fewest taps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 16) {
      final aim = play.next;
      check(aim != null, '${level.name} lost its pointer');
      if (aim == null) break;
      play = play.tap(aim.$1, aim.$2);
      steps++;
    }
    check(play.isDone, '${level.name} was never landed');
    check(play.taps == level.fewest,
        '${level.name} in ${play.taps} against ${level.fewest}');
  }

  // The hopeless ask, worn down by eight boards.
  var stuck = Play.of(dead);
  for (final tap in [(0, 1), (1, 1), (1, 2), (1, 3), (0, 2), (1, 4), (1, 5),
    (0, 3)]) {
    final was = stuck;
    stuck = stuck.tap(tap.$1, tap.$2);
    check(!identical(stuck, was), 'a tap that did nothing');
  }
  check(stuck.gaveUp, 'the hopeless ask did not admit it');
  check(!Play.of(dead).gaveUp, 'it admitted it at once');

  if (failed) {
    stderr.writeln('the hoop is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every board a hoop of ${Rules.holes} holes allows laid, all '
        '${commas(laid)} of them, a dark stone or none in each hole and a '
        'pale stone or none in each: the lamps were lit twice on every one, '
        'once by turning the pale ring round the hoop by each dark hole in '
        'turn and piling the copies up, and once by multiplying the rings '
        'out hole by hole, and the two agreed ${commas(laid)} times out of '
        '${commas(laid)}')
    ..write('; the multiplying knows more than the piling, since it counts '
        'how many ways each lamp is lit rather than only that it is, and its '
        'counts came to the two stone counts multiplied on every board, at '
        'most $mostWays ways to one lamp')
    ..write('; the lamps never came under the two stone counts added with '
        'one taken off, or the whole hoop when that is fewer, on any of the '
        '${commas(laid)}, and a third voice that lights nothing read the '
        'same floor off the divisors of seven every time')
    ..write('; ${commas(onFloor)} boards sit exactly on that floor, and of '
        'the ${commas(floorBoards)} of them with two or more stones of each '
        'colour and a floor below six, every single one is a run of dark '
        'stones and a run of pale stones at one shared step round the hoop')
    ..write('; on all ${commas(walked)} boards with two dark stones, '
        'stepping round by the gap between them visits every hole, and the '
        'lamps came to the pale stones plus the runs the walk passes, every '
        'time')
    ..write('; two dark stones and four pale leave five lamps at least on '
        'all ${commas(dead.boards)} boards, and never four, though on a hoop '
        'of six holes the same shape leaves four lamps $onSix boards over');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(level.boards)} boards with '
            'those stones do it, the nearest ${level.fewest} taps away'
        : 'none of the ${commas(level.boards)}, and the floor of '
            '${level.floor} said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
