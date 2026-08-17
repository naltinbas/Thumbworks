import 'dart:io';

import 'package:pumpwick/lane/levels.dart';
import 'package:pumpwick/lane/play.dart';
import 'package:pumpwick/lane/rules.dart';

/// Walks every row of houses to every spot on the lane, finds the best
/// spot two ways, and refuses the bake on any disagreement.
///
/// Run with: dart run tool/check_walks.dart
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

  var rows = 0, oddRows = 0, evenRows = 0, wideSpans = 0, averageWorse = 0;
  const most = 7;
  for (var count = 1; count <= most; count++) {
    for (final houses in Rules.rows(count)) {
      rows++;
      final best = Rules.bestSpots(houses);
      final middle = Rules.middleSpots(houses);
      check(best.join(',') == middle.join(','),
          'the houses ${Rules.tellHouses(houses)}: best $best against '
          'middle $middle');
      // The best spots run together, with no gaps.
      for (var i = 1; i < best.length; i++) {
        check(best[i] == best[i - 1] + 1,
            'the best spots of ${Rules.tellHouses(houses)} have a gap');
      }
      if (count.isOdd) {
        oddRows++;
        check(best.length == 1,
            'an odd row with ${best.length} best spots');
      } else {
        evenRows++;
        if (best.length > 1) wideSpans++;
      }
      // Stepping along changes the total by the houses behind less the
      // houses ahead.
      for (var spot = 0; spot < Rules.spots - 1; spot++) {
        check(
            Rules.walk(houses, spot + 1) - Rules.walk(houses, spot) ==
                Rules.stepChange(houses, spot),
            'the step from $spot on ${Rules.tellHouses(houses)}');
      }
      // The average is never better than the middle, and often worse.
      final atAverage = Rules.walk(houses, Rules.averageSpot(houses));
      final atMiddle = Rules.walk(houses, best.first);
      check(atAverage >= atMiddle,
          'the average beat the middle on ${Rules.tellHouses(houses)}');
      if (atAverage > atMiddle) averageWorse++;
    }
  }
  check(rows == 77519, 'rows swept: $rows');

  // The asks.
  for (final level in Levels.all) {
    var n = 0;
    for (var spot = 0; spot < Rules.spots; spot++) {
      if (level.meets(spot)) n++;
    }
    check(n == level.ways, '${level.name}: $n against ${level.ways}');
    check(Rules.leastWalk(level.houses) == level.walk,
        '${level.name}: the least is ${Rules.leastWalk(level.houses)}, not '
        '${level.walk}');
    if (level.winnable) {
      check(level.aim != null && level.meets(level.aim!),
          '${level.name}: the aim misses');
      check(level.fewest == (level.aim! - Rules.start).abs(),
          '${level.name}: the fewest');
    } else {
      check(level.aim == null && n == 0, '${level.name} was landed');
    }
  }

  // The pointer lands every ask it can, in the fewest steps.
  for (final level in Levels.all.where((l) => l.winnable)) {
    var play = Play.of(level);
    var steps = 0;
    while (!play.isDone && steps < 30) {
      final way = play.next;
      check(way != null, '${level.name} lost its pointer');
      if (way == null) break;
      play = play.step(way);
      steps++;
    }
    check(play.isDone, '${level.name} never landed');
    check(play.moves == level.fewest,
        '${level.name} in ${play.moves} against ${level.fewest}');
  }

  if (failed) {
    stderr.writeln('the lane is not sound; no bake');
    exit(1);
  }

  final ledger = StringBuffer()
    ..write('every row of houses on the lane taken, from one house to $most '
        'and every arrangement of them over the ${Rules.spots} spots, '
        '${commas(rows)} rows, and the pump stood at every spot of each: the '
        'spots where the walking is least are exactly the middle houses, on '
        'every row, which is the median and not the average')
    ..write('; ${commas(oddRows)} of the rows have an odd count of houses '
        'and each of those has one best spot alone, while '
        '${commas(evenRows)} have an even count and ${commas(wideSpans)} of '
        'those have a run of best spots between the two middle houses, every '
        'spot of the run as good as the rest')
    ..write('; stepping the pump one spot along changes the walking by the '
        'houses at or behind it less the houses ahead, which the sweep '
        'checks at every spot of every row, so the total falls while houses '
        'lie ahead and rises once they lie behind')
    ..write('; standing the pump at the average instead of the middle is '
        'never better and is worse on ${commas(averageWorse)} of the rows');
  stdout.writeln(ledger);
  stdout.writeln();
  final width =
      Levels.all.map((l) => l.name.length).reduce((a, b) => a > b ? a : b);
  for (var i = 0; i < Levels.count; i++) {
    final level = Levels.at(i);
    final tail = level.winnable
        ? '${level.ways} of the ${Rules.spots} spots '
            '${level.ways == 1 ? 'lands' : 'land'} it, the nearest '
            '${level.fewest} steps from where the pump starts'
        : 'none of the ${Rules.spots}, and the counts either side say why';
    stdout.writeln(' ${i + 1} ${level.name.padRight(width)} ${level.task}: $tail');
  }
}
