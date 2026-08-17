import 'dart:io';

import 'package:truckleford/yard/levels.dart';
import 'package:truckleford/yard/play.dart';
import 'package:truckleford/yard/rules.dart';

/// Runs every order of every train up to eight wagons through the yard,
/// reads each one for the shape as well, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_yards.dart
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

  /// The yard, run for a train of any length: the first voice.
  int? tapsFor(int wagons, List<int> train) {
    final line = [for (var w = 1; w <= wagons; w++) w];
    final siding = <int>[];
    var taps = 0;
    for (final want in train) {
      while (true) {
        if (siding.isNotEmpty && siding.last == want) {
          siding.removeLast();
          taps++;
          break;
        }
        if (line.isNotEmpty && line.first == want) {
          line.removeAt(0);
          taps++;
          break;
        }
        if (line.isEmpty) return null;
        siding.add(line.removeAt(0));
        taps++;
      }
    }
    return taps;
  }

  /// The shape, looked for and never run: the second voice.
  bool holdsPattern(List<int> train) {
    for (var i = 0; i < train.length; i++) {
      for (var j = i + 1; j < train.length; j++) {
        for (var k = j + 1; k < train.length; k++) {
          if (train[j] < train[k] && train[k] < train[i]) return true;
        }
      }
    }
    return false;
  }

  const catalan = [1, 1, 2, 5, 14, 42, 132, 429, 1430];
  var orders = 0;
  final made = <int, int>{};
  for (var wagons = 1; wagons <= 8; wagons++) {
    var here = 0, runnable = 0;
    for (final train in Rules.orders(wagons)) {
      here++;
      final taps = tapsFor(wagons, train);
      check((taps != null) == !holdsPattern(train),
          'the train ${Rules.tellTrain(train)}: run $taps, shape '
          '${holdsPattern(train)}');
      if (taps != null) {
        runnable++;
        check(taps >= wagons && taps <= 2 * wagons - 1,
            'the train ${Rules.tellTrain(train)} takes $taps taps');
      }
    }
    check(here == Rules.howManyOrders(wagons), '$wagons wagons: $here orders');
    check(runnable == catalan[wagons],
        '$wagons wagons: $runnable runnable against ${catalan[wagons]}');
    made[wagons] = runnable;
    orders += here;
  }
  check(orders == 46233, 'orders swept: $orders');

  // The yard the game plays in.
  final trains = Rules.trains().toList();
  check(trains.length == 132, 'trains the siding can make: ${trains.length}');
  final byTaps = <int, int>{};
  for (final train in trains) {
    final taps = Rules.tapsFor(train)!;
    byTaps[taps] = (byTaps[taps] ?? 0) + 1;
    check(taps == tapsFor(Rules.wagons, train), 'the taps of $train');
  }
  check(
      byTaps[6] == 1 &&
          byTaps[7] == 15 &&
          byTaps[8] == 50 &&
          byTaps[9] == 50 &&
          byTaps[10] == 15 &&
          byTaps[11] == 1,
      'the taps spread: $byTaps');

  // The orders that begin the way the hopeless ask asks for.
  var heads = 0;
  for (final train in Rules.orders()) {
    if (train[0] == 3 && train[1] == 1 && train[2] == 2) {
      heads++;
      check(!Rules.canBeRun(train), 'the yard made ${Rules.tellTrain(train)}');
    }
  }
  check(heads == 6, 'orders that begin 3, 1, 2: $heads');

  // The asks.
  final ways = <String, int>{for (final level in Levels.all) level.name: 0};
  final cheapest = <String, int>{};
  for (final train in trains) {
    for (final level in Levels.all) {
      if (!level.meets(train)) continue;
      ways[level.name] = ways[level.name]! + 1;
      final taps = Rules.tapsFor(train)!;
      final held = cheapest[level.name];
      if (held == null || taps < held) cheapest[level.name] = taps;
    }
  }
  for (final level in Levels.all) {
    check(ways[level.name] == level.ways,
        '${level.name}: ${ways[level.name]} against ${level.ways}');
    if (level.winnable) {
      check(level.meets(level.aim!), '${level.name}: the aim misses');
      check(Rules.canBeRun(level.aim!), '${level.name}: the aim cannot be run');
      check(level.fewest == cheapest[level.name],
          '${level.name}: the aim takes ${level.fewest}, cheapest '
          '${cheapest[level.name]}');
    } else {
      check(level.aim == null && ways[level.name] == 0,
          '${level.name} was landed');
    }
  }

  // The pointer lands every ask it can, in the fewest taps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 20) {
      final was = play.least;
      final what = play.next;
      check(what != null, '${level.name} lost its pointer');
      if (what == null) break;
      play = play.tap(what);
      check(play.least == was! - 1, '${level.name} wandered');
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  // The hopeless ask, walked into its wall: shunt 1, shunt 2, shunt 3,
  // send 3, and wagon 2 stands at the points ahead of wagon 1.
  var stuck = Play.of(Levels.all.last);
  for (final what in [Rules.shunt, Rules.shunt, Rules.shunt, Rules.send]) {
    stuck = stuck.tap(what);
  }
  check(stuck.out.join(',') == '3', 'the wall: out is ${stuck.out}');
  check(stuck.siding.join(',') == '1,2', 'the wall: the siding is ${stuck.siding}');
  check(stuck.gaveUp, 'the hopeless ask did not admit it');

  if (failed) {
    stderr.writeln('the yard is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every order of every train from one wagon to eight taken, '
        '${commas(orders)} orders in all, and each one read twice: once by '
        'running it through the yard wagon by wagon, shunting whatever is in '
        'the way onto the siding, and once by looking through the order for a '
        'wagon followed later by a smaller one and later still by one in '
        'between, which never touches a yard: the two agree on every order')
    ..write('; the yard makes ')
    ..write([for (var w = 1; w <= 8; w++) '${commas(made[w]!)} of the ${commas(Rules.howManyOrders(w))} at $w'].join(', '))
    ..write(' wagons, which are the Catalan numbers, and the orders it '
        'cannot make are exactly the ones holding that shape')
    ..write('; on the six wagons the game plays with, ${commas(trains.length)} '
        'out-trains of the ${commas(Rules.howManyOrders())} can be made and '
        'the other ${commas(Rules.howManyOrders() - trains.length)} cannot; '
        'the taps they take run from ${byTaps.keys.reduce((a, b) => a < b ? a : b)} '
        'to ${byTaps.keys.reduce((a, b) => a > b ? a : b)}, ')
    ..write([
      for (final taps in byTaps.keys.toList()..sort())
        '${byTaps[taps]} at $taps'
    ].join(', '))
    ..write(', which are the Narayana numbers, the six-tap train being the '
        'one where every wagon rolls straight past the siding and the '
        'eleven-tap train the one where every wagon but the last is shunted')
    ..write('; and $heads of the ${commas(Rules.howManyOrders())} orders begin '
        '3, 1, 2, the yard making none of them');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${commas(level.ways)} of the ${commas(trains.length)} out-trains '
            '${level.ways == 1 ? 'lands' : 'land'} it, the cheapest in '
            '${level.fewest} taps'
        : 'none of the ${commas(trains.length)}, and the points say why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
