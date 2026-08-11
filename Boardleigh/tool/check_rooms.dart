import 'dart:io';

import 'package:boardleigh/floor/rooms.dart';
import 'package:boardleigh/floor/rules.dart';

/// Counts every laying of every room, holds the strips to the
/// staircase rule, and refuses the bake on any disagreement.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  // The staircase rule along the two-board strips: each count is the
  // two before it added. The count knows nothing of the rule.
  final strip = <int>[];
  for (var boards = 1; boards <= 8; boards++) {
    final rules =
        Rules(boards, 2, Rules.rectangle(boards, 2));
    strip.add(rules.tilings(rules.cells));
  }
  for (var boards = 3; boards <= 8; boards++) {
    claim(strip[boards - 1] == strip[boards - 2] + strip[boards - 3],
        'the staircase rule breaks at $boards boards');
  }
  stdout.writeln('two-board strips count ${strip.join(', ')}: each '
      'the two before it added, as the staircase rule says');
  stdout.writeln('');

  for (var number = 0; number < Rooms.count; number++) {
    final room = Rooms.at(number);
    final rules = Rules(room.wide, room.high, room.cells);
    final ways = rules.tilings(room.cells);
    claim(ways == room.ways,
        '${room.name}: $ways layings, written ${room.ways}');

    final (dark, light) = rules.colours();
    if (!room.winnable) {
      claim(dark != light,
          '${room.name}: dead but the colours are even');
    }

    final verdict = room.winnable
        ? 'lays ${room.ways} way${room.ways == 1 ? '' : 's'}, '
            'colours $dark and $light'
        : 'never lays: colours $dark and $light';
    stdout.writeln(' ${number + 1} ${room.name.padRight(19)} '
        '${rules.cellCount} cells  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
