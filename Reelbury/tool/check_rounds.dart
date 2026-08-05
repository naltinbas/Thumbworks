// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:reelbury/reel/rounds.dart';
import 'package:reelbury/reel/stable.dart';

/// Walks every shipped round: how many pairings hold, which one, and how
/// many people it hands their first choice to.
///
/// Run with: dart run tool/check_rounds.dart
void main() {
  for (var i = 0; i < Rounds.count; i++) {
    final round = Rounds.at(i);
    final hall = round.hall;
    final all = Stable.allThatHold(hall);
    final asked = Stable.byAsking(hall);
    final answered = Stable.byAsking(hall, callersAsk: false);

    var firsts = 0;
    for (var caller = 0; caller < hall.count; caller++) {
      if (hall.callers[caller].first == asked[caller]) firsts++;
    }

    final same = List.generate(hall.count, (i) => asked[i] == answered[i])
        .every((yes) => yes);

    print('${'${i + 1}'.padLeft(2)} ${round.name.padRight(17)}'
        '${hall.count} couples  '
        '${all.length} ${all.length == 1 ? 'pairing holds ' : 'pairings hold'}  '
        '${same ? 'both sides agree ' : 'the sides differ '}'
        '$firsts of ${hall.count} got their first choice  '
        '${asked.join(' ')}');
  }
}
