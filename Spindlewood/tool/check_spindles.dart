import 'dart:io';

import 'package:spindlewood/tower/rules.dart';
import 'package:spindlewood/tower/spindles.dart';

/// Walks every board of every job and refuses the bake on any
/// disagreement with what is written, or between the three reckonings.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  for (var number = 0; number < Spindles.count; number++) {
    final spindle = Spindles.at(number);
    final rules = Rules(spindle.spindles, spindle.rounds);
    final floor = rules.fewest(rules.start);

    claim(floor == spindle.fewest,
        '${spindle.name}: walk says $floor, written ${spindle.fewest}');
    final told = spindle.spindles == 3
        ? Rules.doubling(spindle.rounds)
        : Rules.leapfrog(spindle.rounds);
    claim(told == floor,
        '${spindle.name}: the reckoning says $told, the walk $floor');
    if (spindle.spindles == 3) {
      final moves = rules.iterated();
      var board = rules.start;
      for (final (round, to) in moves) {
        board = rules.moved(board, round, to);
      }
      claim(board == rules.home && moves.length == floor,
          '${spindle.name}: the iteration made ${moves.length} and '
          '${board == rules.home ? 'landed home' : 'went astray'}');
    }
    final wager = spindle.wager;
    if (wager != null) {
      claim(wager < floor,
          '${spindle.name}: the wager $wager is not under the floor');
    }

    final verdict = wager != null
        ? 'floor $floor, the wager of $wager unmeetable'
        : 'home in $floor, no board knows shorter';
    stdout.writeln(' ${number + 1} ${spindle.name.padRight(18)} '
        '${spindle.rounds} rounds on ${spindle.spindles}  '
        '${rules.boards} boards walked  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
