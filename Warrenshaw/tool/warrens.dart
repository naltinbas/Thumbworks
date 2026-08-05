// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:warrenshaw/chase/dismantle.dart';
import 'package:warrenshaw/chase/maps.dart';
import 'package:warrenshaw/chase/tablebase.dart';

/// Walks every shipped map: whether it can be won, in how few moves from
/// where the two of them start, and what taking it apart says.
///
/// Run with: dart run tool/warrens.dart
void main() {
  for (var i = 0; i < Warrens.count; i++) {
    final warren = Warrens.at(i);
    final chart = warren.chart;
    final table = Tablebase(chart);
    final apart = Dismantle.comesApart(chart);
    final moves = table.movesFrom(
      warren.seeker,
      warren.runner,
      seekersTurn: true,
    );

    print('${'${i + 1}'.padLeft(2)} ${warren.name.padRight(13)}'
        '${chart.count} places  ${chart.paths.length} paths  '
        '${chart.isWhole ? 'whole' : 'IN PIECES'}  '
        '${apart ? 'comes apart' : 'sticks    '}  '
        '${table.isSeekerWin ? 'winnable' : 'hopeless'}  '
        'from the start: ${moves == Tablebase.never ? 'never' : '$moves moves'}'
        '   (best start ${table.bestStart}, '
        'worst case ${table.capture == Tablebase.never ? 'never' : table.capture})'
        '  ${table.rounds} rounds');
  }
}
