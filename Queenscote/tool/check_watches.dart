import 'dart:io';

import 'package:queenscote/watch/levels.dart';
import 'package:queenscote/watch/play.dart';
import 'package:queenscote/watch/rules.dart';

/// Tries every placing of the queens asked on every board here, holds
/// the sweep against the picking, and refuses the bake on any
/// disagreement: this is what `make watches` runs, and the README
/// quotes its ledger verbatim.
void main() {
  String commas(int n) {
    final s = n.toString();
    final out = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) out.write(',');
      out.write(s[i]);
    }
    return out.toString();
  }

  int choose(int n, int k) {
    var c = 1;
    for (var i = 0; i < k; i++) {
      c = c * (n - i) ~/ (i + 1);
    }
    return c;
  }

  // Every level's label against the sweep and the picking, the aim
  // landing it, and no level over at the opening.
  for (final level in Levels.all) {
    final placings = choose(level.squares, level.queens);
    final int met;
    if (level.unseenAsked == 0) {
      final (watching, _) = Rules.sweep(level.side, level.queens);
      final (picked, first) = Rules.picking(level.side, level.queens);
      if (watching != picked) {
        stderr.writeln('${level.name}: THE SWEEP FINDS $watching, THE PICKING $picked');
        exit(1);
      }
      if ((first == null) != (level.aim == null) || (first != null && first.toString() != level.aim.toString())) {
        stderr.writeln('${level.name}: THE PICKING\'S FIRST IS $first, THE AIM ${level.aim}');
        exit(1);
      }
      met = watching;
    } else {
      met = Rules.sweepUnseen(level.side, level.queens, level.unseenAsked);
    }
    if (met != level.ways || placings != level.placings) {
      stderr.writeln('${level.name}: sweep finds $met of $placings, label says ${level.ways} of ${level.placings}');
      exit(1);
    }
    final aim = level.aim;
    if (aim != null && !level.meets(aim)) {
      stderr.writeln('${level.name}: the aim $aim does not land it');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }

  // The named facts: the fewest queens board by board, the nearest
  // misses, the most one queen sees, and the four sets on the six.
  final fewest = <int, int>{};
  for (var side = 4; side <= 8; side++) {
    for (var q = 1; q <= 5; q++) {
      final (w, _) = Rules.sweep(side, q);
      if (w > 0) {
        fewest[side] = q;
        break;
      }
    }
  }
  if (fewest.toString() != '{4: 2, 5: 3, 6: 3, 7: 4, 8: 5}') {
    stderr.writeln('THE FEWEST ARE $fewest');
    exit(1);
  }
  final misses = <String>[];
  for (final (side, q) in [(4, 1), (5, 2), (6, 2), (7, 3), (8, 4)]) {
    final (w, few) = Rules.sweep(side, q);
    misses.add('$side:$q:$w:$few');
  }
  if (misses.join(' ') != '4:1:0:4 5:2:0:2 6:2:0:6 7:3:0:4 8:4:0:2') {
    stderr.writeln('THE MISSES ARE $misses');
    exit(1);
  }
  if (Rules.mostSeen(4) != (12, 5) || Rules.mostSeen(8) != (28, 27) || Rules.sweepUnseen(4, 1, 4) != 4 || Rules.sweepUnseen(8, 4, 3) != 672) {
    stderr.writeln('THE MOST SEEN OR THE MISSES ARE OFF: ${Rules.mostSeen(4)}, ${Rules.mostSeen(8)}, ${Rules.sweepUnseen(4, 1, 4)}, ${Rules.sweepUnseen(8, 4, 3)}');
    exit(1);
  }
  final six = <String>[];
  for (var a = 0; a < 36; a++) {
    for (var b = a + 1; b < 36; b++) {
      for (var c = b + 1; c < 36; c++) {
        if (Rules.watches(6, [a, b, c])) six.add([a, b, c].map((i) => Rules.told(6, i)).join(' '));
      }
    }
  }
  if (six.join(', ') != 'a6 e4 c2, f6 b4 d2, c5 e3 a1, d5 b3 f1') {
    stderr.writeln('THE SIX BY SIX SETS ARE $six');
    exit(1);
  }
  // The four are one shape turned and mirrored: the images of the first
  // under the board's eight symmetries, kept once, are exactly the four.
  final firstSix = [0, 16, 26];
  final orbit = <String>{};
  for (var sym = 0; sym < 8; sym++) {
    final image = firstSix.map((i) {
      var r = i ~/ 6, c = i % 6;
      if (sym & 1 != 0) c = 5 - c;
      if (sym & 2 != 0) r = 5 - r;
      if (sym & 4 != 0) {
        final t = r;
        r = c;
        c = t;
      }
      return r * 6 + c;
    }).toList()
      ..sort();
    orbit.add(image.map((i) => Rules.told(6, i)).join(' '));
  }
  if (orbit.length != 4 || !orbit.containsAll(six)) {
    stderr.writeln('THE SIX BY SIX SETS ARE NOT ONE SHAPE TURNED: $orbit');
    exit(1);
  }
  final corner = Rules.masks(4)[0];
  var cornerSees = 0;
  for (var s = 0; s < 16; s++) {
    if (corner & (1 << s) != 0) cornerSees++;
  }
  if (cornerSees != 10 || Rules.told(8, 0) != 'a8' || Rules.told(8, 57) != 'b1' || !Rules.watches(8, [0, 1, 13, 32, 44]) || Rules.unseen(8, [0, 12, 39, 57]) != 2) {
    stderr.writeln('THE NAMED SQUARES ARE OFF');
    exit(1);
  }

  stdout.writeln(
      'every placing of the queens asked tried on every board asked, as masks of '
      'the squares seen, and every watching set found again by picking a queen '
      'for the first unseen square in turn, the two counts agreeing on every '
      'board: two queens watch the four by four 12 ways of 120, three watch the '
      'six by six 4 ways of 7,140, one shape turned four ways, and five watch the '
      'chessboard 4,860 ways of 7,624,512; the fewest that watch run 2, 3, 3, 4, 5 '
      'from the four by four to the eight, and one fewer never does, leaving 4, '
      '2, 6, 4 and 2 squares unseen at best; four queens on the chessboard leave '
      'two unseen in 64 placings of 635,376 and three in 672; and one queen on '
      'the four by four sees 12 squares at the most, from the middle four, and 10 '
      'from a corner, so 4 of the 16 squares leave four unseen and none fewer');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(17);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${commas(level.ways)} of the ${commas(level.placings)} placings land it'
        : ' ${number + 1} $name ${level.task}: none of the ${commas(level.placings)}, and the twelve seen said so first');
  }
}
