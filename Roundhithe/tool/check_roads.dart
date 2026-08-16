import 'dart:io';

import 'package:roundhithe/road/levels.dart';
import 'package:roundhithe/road/play.dart';
import 'package:roundhithe/road/rules.dart';

/// Walks every road-plan on the six villages for a round trip two ways,
/// counts what Dirac and Ore promise, and refuses the bake on any
/// disagreement.
///
/// Run with: dart run tool/check_roads.dart
void main() {
  var failed = false;
  void check(bool ok, String what) {
    if (!ok) {
      failed = true;
      stderr.writeln('DISAGREEMENT: $what');
    }
  }

  String commas(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  check(Rules.villages == 6 && Rules.roadsPossible == 15 && Rules.plans == 32768, 'the villages and roads');
  for (var i = 0; i < Rules.pairs.length; i++) {
    final (a, b) = Rules.pairs[i];
    check(Rules.roadOf(a, b) == i && Rules.roadOf(b, a) == i, 'road $i');
  }

  var trips = 0, dirac = 0, diracTrips = 0, ore = 0, oreTrips = 0, oreNotDirac = 0;
  final byRoads = List<int>.filled(16, 0), tripsByRoads = List<int>.filled(16, 0);
  var twoEach = 0, twoEachTrips = 0, threeEach = 0, threeEachTrips = 0, minTwo = 0, minTwoNoTrip = 0;
  final elevenNoTrip = <int>[];
  for (var mask = 0; mask < Rules.plans; mask++) {
    final walk = Rules.tripByWalk(mask);
    final table = Rules.tripByTable(mask);
    check((walk != null) == table, 'the two voices differ on ${Rules.tell(mask)}');
    if (walk != null) {
      // The trip found really is one: six villages once each, every step a road, closing.
      check(walk.length == 6 && walk.toSet().length == 6 && walk.first == 0, 'the walk on ${Rules.tell(mask)} is no trip: $walk');
      for (var i = 0; i < 6; i++) {
        check(Rules.joined(mask, walk[i], walk[(i + 1) % 6]), 'the walk on ${Rules.tell(mask)} leaves the roads');
      }
    }
    final r = Rules.roads(mask);
    byRoads[r]++;
    if (walk != null) {
      trips++;
      tripsByRoads[r]++;
    } else if (r == 11) {
      elevenNoTrip.add(mask);
    }
    if (Rules.dirac(mask)) {
      dirac++;
      if (walk != null) diracTrips++;
    }
    if (Rules.ore(mask)) {
      ore++;
      if (walk != null) oreTrips++;
      if (!Rules.dirac(mask)) oreNotDirac++;
    }
    final d = Rules.degrees(mask);
    if (d.every((x) => x == 2)) {
      twoEach++;
      if (walk != null) twoEachTrips++;
    }
    if (d.every((x) => x == 3)) {
      threeEach++;
      if (walk != null) threeEachTrips++;
    }
    if (Rules.minDegree(mask) == 2) {
      minTwo++;
      if (walk == null) minTwoNoTrip++;
    }
  }
  check(trips == 10078, 'trips $trips');
  check(dirac == 1858 && diracTrips == 1858, 'Dirac $dirac, trips $diracTrips');
  check(ore == 1978 && oreTrips == 1978 && oreNotDirac == 120, 'Ore $ore, trips $oreTrips, not Dirac $oreNotDirac');
  check(twoEach == 70 && twoEachTrips == 60 && threeEach == 70 && threeEachTrips == 70, 'two each $twoEach/$twoEachTrips, three each $threeEach/$threeEachTrips');
  check(minTwo == 10210 && minTwoNoTrip == 1990, 'least two: $minTwo, without a trip $minTwoNoTrip');
  check(byRoads[6] == 5005 && tripsByRoads[6] == 60 && [for (var r = 0; r < 6; r++) tripsByRoads[r]].every((n) => n == 0), 'six roads: ${byRoads[6]} plans, ${tripsByRoads[6]} trips');
  check(byRoads[11] == 1365 && elevenNoTrip.length == 30, 'eleven roads: ${byRoads[11]} plans, ${elevenNoTrip.length} without a trip');
  var twelveUp = 0;
  for (var r = 12; r <= 15; r++) {
    check(tripsByRoads[r] == byRoads[r], '$r roads: ${byRoads[r]} plans, ${tripsByRoads[r]} trips');
    twelveUp += byRoads[r];
  }
  check(twelveUp == 576, 'twelve roads or more: $twelveUp');
  // Every eleven-road plan without a trip is five villages joined every way and a sixth hung on by one road.
  for (final mask in elevenNoTrip) {
    final d = Rules.degrees(mask)..sort();
    check(d.join(',') == '1,4,4,4,4,5', 'eleven without a trip, degrees $d: ${Rules.tell(mask)}');
  }
  check(Rules.tell(Levels.at(3).aim!) == 'AB, AC, AD, AE, AF, BC, BD, BE, CD, CE, DE', 'the eleven\'s aim');
  check(Rules.tripByWalk(Rules.planOf('AB, BC, CD, DE, EF, FA'))!.join('') == '012345', 'the plain ring');
  check(Rules.tripByWalk(Rules.planOf('AB, BC, CA, DE, EF, FD')) == null, 'two trios with a trip');
  check(Rules.tripByWalk(Rules.planOf('AD, AE, AF, BD, BE, BF, CD, CE, CF'))!.join('') == '031425', 'the threes-and-threes plan');

  // The asks.
  for (final level in Levels.all) {
    var ways = 0;
    for (var mask = 0; mask < Rules.plans; mask++) {
      if (level.meets(mask)) ways++;
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
        final (a, b, _) = play.next!;
        play = play.tap(a == b ? a : (play.held == a ? b : a));
        steps++;
      }
      check(play.isDone && play.moves == 2 * Rules.roads(aim), '${level.name}: the pointer never lands, or takes ${play.moves} taps');
    }
  }
  var dead = Play.of(Levels.at(4));
  for (final r in ['AD', 'AE', 'AF', 'BD', 'BE', 'BF', 'CD', 'CE', 'CF', 'AB', 'AC']) {
    dead = dead.tap(Rules.names.indexOf(r[0])).tap(Rules.names.indexOf(r[1]));
  }
  check(dead.seen.length == 3 && dead.gaveUp, 'the three each does not admit it after three plans');

  if (failed) {
    stderr.writeln('The bake is refused.');
    exit(1);
  }

  stdout.writeln('every road-plan on the six villages taken, ${commas(Rules.plans)}, and a round trip looked for on each two ways, by walking every order of the villages from A and by the table of where a walk from A through a set of villages can end, the two agreeing on all ${commas(Rules.plans)} and every trip found checked to run along the roads: ${commas(trips)} plans have a round trip; every one of the ${commas(dirac)} with three roads or more at every village does, as Dirac said, and every one of the ${commas(ore)} meeting Ore\'s rule, $oreNotDirac of them short of Dirac\'s; six roads is the fewest a round trip needs, ${tripsByRoads[6]} rings of the ${commas(byRoads[6])} plans of six, and eleven the most a plan without one can have, ${elevenNoTrip.length} plans of the ${commas(byRoads[11])}, each five villages joined every way and the sixth hung on one of them by a single road, while every plan of twelve roads or more, $twelveUp, has one; $twoEach plans give every village two roads, $twoEachTrips of them rings and ${twoEach - twoEachTrips} two trios, ${commas(minTwo)} have some village at two roads and no fewer and ${commas(minTwoNoTrip)} of those no round trip, and $threeEach give every village three, every one with a round trip\n');
  final width = Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${commas(Rules.plans)} road-plans land${level.ways == 1 ? 's' : ''} it'
        : 'none of the ${commas(Rules.plans)}, and Dirac said so first';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
