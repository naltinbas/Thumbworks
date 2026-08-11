import 'dart:io';

import 'package:skittlemere/alley/frames.dart';
import 'package:skittlemere/alley/rules.dart';

/// Recounts every alley, searches every position, and refuses the
/// bake on any disagreement with what is written.
void main() {
  var bad = 0;

  void claim(bool holds, String what) {
    if (holds) return;
    bad++;
    stdout.writeln('WRONG: $what');
  }

  // The two voices, swept over every alley shape of 14 or fewer.
  var shapes = 0;
  for (final shape in Rules.shapes(14)) {
    shapes++;
    claim(Rules.moverWins(shape) == (Rules.countAlley(shape) != 0),
        'the search and the arithmetic part at $shape');
  }
  stdout.writeln('every alley of 14 or fewer skittles, $shapes shapes: '
      'the search and the skittle arithmetic never part');

  // The famous table, and the limp of twelve across the shipped
  // stretch.
  const table = [0, 1, 2, 3, 1, 4, 3, 2, 1, 4, 2, 6, 4, 1, 2, 7];
  for (var row = 0; row < table.length; row++) {
    claim(Rules.countOf(row) == table[row],
        'count of $row is ${Rules.countOf(row)}, the book says '
        '${table[row]}');
  }
  for (var row = 83; row <= 200; row++) {
    claim(Rules.countOf(row) == Rules.countOf(row - 12),
        'the period of twelve breaks at $row');
  }
  stdout.writeln('the book table holds to fifteen, and the period of '
      'twelve holds along 71 to 200');
  stdout.writeln('');

  for (var number = 0; number < Frames.count; number++) {
    final frame = Frames.at(number);
    claim(Rules.countAlley(frame.rows) == frame.count,
        '${frame.name}: counts ${Rules.countAlley(frame.rows)}, '
        'written ${frame.count}');
    claim(Rules.moverWins(frame.rows) == frame.winnable,
        '${frame.name}: the search disagrees about the mover');

    final verdict = frame.winnable
        ? 'count ${frame.count}: the mover has it'
        : 'count nought: the mover never has it';
    stdout.writeln(' ${number + 1} ${frame.name.padRight(16)} '
        'rows ${frame.rows.join('/')}  $verdict');
  }

  if (bad > 0) {
    stdout.writeln('\n$bad claims failed');
    exit(1);
  }
}
