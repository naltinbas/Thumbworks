import 'dart:io';

import 'package:coursewell/course/rules.dart';
import 'package:coursewell/course/yards.dart';

/// Lays every tiling, reads every seam, counts the crossings,
/// and refuses the bake on any disagreement: this is what
/// `make bricks` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final yard in Yards.all) {
    final ways = Rules(yard.width, yard.height).waysTo(yard.asked);
    if (ways != yard.ways) {
      stderr.writeln('${yard.name}: sweep finds $ways, '
          'label says ${yard.ways}');
      exit(1);
    }
  }

  // The counts, recomputed from both sides.
  final six = Rules(6, 6);
  if (six.waysTo(null) != 6728 ||
      six.waysTo(0) != 0 ||
      six.waysTo(7) != 2) {
    stderr.writeln('THE SIX-SQUARE MOVED');
    exit(1);
  }
  final fiveSix = Rules(6, 5);
  if (fiveSix.waysTo(null) != 1183 || fiveSix.waysTo(0) != 6) {
    stderr.writeln('THE SOUND COURSE MOVED');
    exit(1);
  }
  // The four-square never lays sound and never with one seam.
  final four = Rules(4, 4);
  if (four.waysTo(0) != 0 || four.waysTo(1) != 0) {
    stderr.writeln('THE FOUR SQUARE LAID TOO SOUND');
    exit(1);
  }
  // Crossings come in pairs: every inner line of every 6x6
  // laying is crossed by an even count of bricks.
  var evens = true;
  var mostSeams = 0;
  six.layings((laying) {
    final upright = List.filled(6, 0);
    final level = List.filled(6, 0);
    for (final (a, b) in laying) {
      final ax = a % 6, ay = a ~/ 6;
      final bx = b % 6, by = b ~/ 6;
      if (ax != bx) {
        upright[ax > bx ? ax : bx]++;
      } else {
        level[ay > by ? ay : by]++;
      }
    }
    var seams = 0;
    for (var line = 1; line < 6; line++) {
      if (upright[line].isOdd || level[line].isOdd) {
        evens = false;
      }
      if (upright[line] == 0) seams++;
      if (level[line] == 0) seams++;
    }
    if (seams > mostSeams) mostSeams = seams;
  });
  if (!evens) {
    stderr.writeln('A LINE CROSSED ODDLY');
    exit(1);
  }
  // Seven is the most seams any six-square laying carries, so
  // the label may say so.
  if (mostSeams != 7) {
    stderr.writeln('THE MOST SEAMS IS $mostSeams, NOT 7');
    exit(1);
  }

  // The smallest sound yard: every yard smaller than five by
  // six, at least two cells wide both ways with an even count
  // of cells, has seams in every laying it takes.
  for (var w = 2; w * w < 30; w++) {
    for (var h = w; w * h < 30; h++) {
      if ((w * h).isOdd) continue;
      if (Rules(w, h).waysTo(0) != 0) {
        stderr.writeln('A SMALLER YARD LAYS SOUND: $w by $h');
        exit(1);
      }
    }
  }

  stdout.writeln(
      'every laying of every yard swept, 36 and 1,183 and 6,728 '
      'of them: every inner line of the six-square is crossed '
      'by an even count of bricks, so a sound laying would need '
      'twenty crossings from eighteen bricks and gets none, '
      'while five by six lays sound exactly six ways, no '
      'smaller yard two cells wide both ways lays sound at '
      'all, and the two plain stacks alone wear seven seams');
  stdout.writeln('');

  for (var number = 0; number < Yards.count; number++) {
    final yard = Yards.at(number);
    final name = yard.name.padRight(18);
    stdout.writeln(yard.winnable
        ? ' ${number + 1} $name ${yard.task}: ${yard.ways} '
            'laying${yard.ways == 1 ? '' : 's'} of the sweep '
            'land${yard.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${yard.task}: none of the '
            '6,728, and the crossing count said so first');
  }
}
