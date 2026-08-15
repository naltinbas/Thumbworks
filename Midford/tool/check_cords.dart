import 'dart:io';

import 'package:midford/peg/cordings.dart';
import 'package:midford/peg/rules.dart';

/// Sweeps every ordered four on the board, reads every figure two
/// ways, and refuses the bake on any disagreement: this is what
/// `make cords` runs, and the README quotes its ledger verbatim.
void main() {
  final rules = Rules();
  var all = 0, room = 0, rects = 0, rhombs = 0, squares = 0, skew = 0;
  rules.fours((four) {
    all++;
    if (!Rules.parallelogramByMidpoints(four) || !Rules.varignonHolds(four)) {
      stderr.writeln('VARIGNON FAILED AT $four');
      exit(1);
    }
    if (Rules.rectangleByDiagonals(four) != Rules.rectangleByMidpoints(four) ||
        Rules.rhombusByDiagonals(four) != Rules.rhombusByMidpoints(four)) {
      stderr.writeln('THE TWO READINGS PART AT $four');
      exit(1);
    }
    if (Rules.hasRoom(four)) room++;
    if (Rules.rectangleByDiagonals(four)) rects++;
    if (Rules.rhombusByDiagonals(four)) rhombs++;
    if (Rules.squareByDiagonals(four)) squares++;
    if (!Rules.parallelogramByMidpoints(four)) skew++;
  });
  if (all != 303600 || room != 275728 || rects != 27952 || rhombs != 18384 || squares != 11248 || skew != 0) {
    stderr.writeln('THE COUNTS MOVED: $all $room $rects $rhombs $squares $skew');
    exit(1);
  }
  for (final cording in Cordings.all) {
    var ways = 0, fours = 0;
    rules.fours((four) {
      for (var i = 0; i < cording.given.length; i++) {
        if (four[i] != cording.given[i]) return;
      }
      fours++;
      if (cording.meets(four)) ways++;
    });
    if (ways != cording.ways || fours != cording.fours) {
      stderr.writeln('${cording.name}: sweep finds $ways of $fours, label says ${cording.ways} of ${cording.fours}');
      exit(1);
    }
  }
  // The fourth peg: one place, (1, 4).
  final given = Cordings.at(3).given;
  final places = <(int, int)>[];
  for (final peg in rules.pegs) {
    if (given.contains(peg)) continue;
    if (Rules.rectangleByDiagonals([...given, peg])) places.add(peg);
  }
  if ('$places' != '[(1, 4)]') {
    stderr.writeln('THE FOURTH PEG MOVED: $places');
    exit(1);
  }

  stdout.writeln(
      'every ordered four of pegs on the board swept, 303,600 of them, and '
      'the midpoint figure read two ways, off its own corners and off the '
      'diagonals: a parallelogram every time, Varignon\'s halves agreeing '
      'on all 303,600, a rectangle 27,952 times, a rhombus 18,384, a square '
      '11,248, flat 27,872 and skew never; three pegs at the corner of the '
      'board take one fourth of twenty-two for a rectangle');
  stdout.writeln('');

  for (var number = 0; number < Cordings.count; number++) {
    final cording = Cordings.at(number);
    final name = cording.name.padRight(17);
    stdout.writeln(cording.winnable
        ? ' ${number + 1} $name ${cording.task}: ${_commas(cording.ways)} of the '
            '${_commas(cording.fours)} ordered fours land${cording.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${cording.task}: none of the ${_commas(cording.fours)}, '
            'and the halves said so first');
  }
}

/// 303600 as 303,600.
String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
