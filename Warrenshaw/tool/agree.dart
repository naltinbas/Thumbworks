// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:warrenshaw/chase/chart.dart';
import 'package:warrenshaw/chase/dismantle.dart';
import 'package:warrenshaw/chase/tablebase.dart';

/// Holds the theorem against the table on maps made up at random.
///
/// Run with: dart run tool/agree.dart [how many] [places]
void main(List<String> args) {
  final many = args.isEmpty ? 400 : int.parse(args.first);
  final places = args.length > 1 ? int.parse(args[1]) : 8;
  final dice = Random(many * 100 + places);

  var checked = 0;
  var seekerWins = 0;
  var disagreed = 0;
  var longest = 0;

  while (checked < many) {
    final chart = _scatter(dice, places);
    if (!chart.isWhole) continue;
    checked++;

    final table = Tablebase(chart);
    final apart = Dismantle.comesApart(chart);
    if (table.isSeekerWin != apart) {
      disagreed++;
      print('DISAGREED on ${chart.paths}');
      print('  table says ${table.isSeekerWin}, taking it apart says $apart');
    }
    if (table.isSeekerWin) {
      seekerWins++;
      if (table.capture > longest) longest = table.capture;
    }
  }

  print('$checked maps of $places places');
  print('  the seeker wins $seekerWins of them');
  print('  the longest chase was $longest moves');
  print('  the theorem and the table disagreed $disagreed times');
}

Chart _scatter(Random dice, int places) {
  final paths = <(int, int)>[];
  for (var one = 0; one < places; one++) {
    for (var other = one + 1; other < places; other++) {
      if (dice.nextInt(100) < 28) paths.add((one, other));
    }
  }
  return Chart(
    places: [
      for (var place = 0; place < places; place++)
        Place('$place', dice.nextDouble(), dice.nextDouble()),
    ],
    paths: paths,
  );
}
