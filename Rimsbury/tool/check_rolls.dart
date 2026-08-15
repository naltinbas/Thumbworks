import 'dart:io';
import 'dart:math';

import 'package:rimsbury/roll/levels.dart';
import 'package:rimsbury/roll/play.dart';
import 'package:rimsbury/roll/rules.dart';

/// Sweeps every setting of the hoop and the roller, rolls every trip
/// that fits pivot by pivot, holds the turns rolled against the formula,
/// and refuses the bake on any disagreement: this is what `make rolls`
/// runs, and the README quotes its ledger verbatim.
void main() {
  // The sweep: every setting against every level's label, the aim
  // landing it, and no level landed at the opening setting.
  for (final level in Levels.all) {
    var met = 0, all = 0;
    (int, int, bool)? first;
    for (final inside in [false, true]) {
      for (var hoop = 1; hoop <= Rules.most; hoop++) {
        for (var coin = 1; coin <= Rules.most; coin++) {
          all++;
          if (level.meets(hoop, coin, inside)) {
            met++;
            first ??= (hoop, coin, inside);
          }
        }
      }
    }
    if (met != level.ways || all != Rules.settings) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways} of ${Rules.settings}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? first != null : !level.meets(aim.$1, aim.$2, level.inside)) {
      stderr.writeln('${level.name}: the aim $aim does not land it, the sweep finds $first');
      exit(1);
    }
    final opening = Play.of(level);
    if (opening.isDone || opening.gaveUp) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }

  // The two voices: every trip that fits, rolled in pivots about the
  // point of contact, against the formula; and the misfits counted.
  var fitting = 0, misfits = 0, worst = 0.0;
  for (final inside in [false, true]) {
    for (var hoop = 1; hoop <= Rules.most; hoop++) {
      for (var coin = 1; coin <= Rules.most; coin++) {
        final byFormula = Rules.turns(hoop, coin, inside);
        final rolled = Rules.turnsRolled(hoop, coin, inside);
        if (byFormula == null) {
          if (!rolled.isNaN || Rules.fits(hoop, coin, inside)) {
            stderr.writeln('A ROLLER OF $coin ROLLS INSIDE A HOOP OF $hoop');
            exit(1);
          }
          misfits++;
          continue;
        }
        fitting++;
        final signed = inside ? -rolled : rolled;
        final off = (signed - byFormula.$1 / byFormula.$2).abs();
        worst = max(worst, off);
        if (off > 1e-5) {
          stderr.writeln('HOOP $hoop ROLLER $coin ${inside ? 'INSIDE' : 'OUTSIDE'}: ROLLED $rolled, FORMULA ${byFormula.$1}/${byFormula.$2}');
          exit(1);
        }
        if (byFormula.$1.gcd(byFormula.$2) != 1) {
          stderr.writeln('NOT IN LOWEST TERMS: $byFormula');
          exit(1);
        }
      }
    }
  }
  if (fitting != 51 || misfits != 21) {
    stderr.writeln('$fitting FITTING, $misfits MISFITS');
    exit(1);
  }

  // The named facts: equal coins turn twice; a hoop of twice the roller
  // thrice outside and once inside; a hoop of half the roller one and a
  // half; nothing turns exactly once outside, and the nearest is a hoop
  // of one with a roller of six, 7/6.
  var nearest = (Rules.most + 1, 1);
  for (var hoop = 1; hoop <= Rules.most; hoop++) {
    for (var coin = 1; coin <= Rules.most; coin++) {
      final t = Rules.turns(hoop, coin, false)!;
      if (hoop == coin && t != (2, 1)) {
        stderr.writeln('EQUAL COINS TURN ${Rules.fraction(t)}');
        exit(1);
      }
      if (hoop == 2 * coin && (t != (3, 1) || Rules.turns(hoop, coin, true) != (1, 1))) {
        stderr.writeln('A HOOP OF TWICE THE ROLLER TURNS ${Rules.fraction(t)} OUTSIDE');
        exit(1);
      }
      if (2 * hoop == coin && t != (3, 2)) {
        stderr.writeln('A HOOP OF HALF THE ROLLER TURNS ${Rules.fraction(t)}');
        exit(1);
      }
      if (t == (1, 1) || t.$1 <= t.$2) {
        stderr.writeln('HOOP $hoop ROLLER $coin TURNS ONCE OR LESS OUTSIDE');
        exit(1);
      }
      if (t.$1 * nearest.$2 < nearest.$1 * t.$2) nearest = t;
    }
  }
  if (nearest != (7, 6) || Rules.turns(1, 6, false) != (7, 6)) {
    stderr.writeln('THE NEAREST TO ONCE IS ${Rules.fraction(nearest)}');
    exit(1);
  }

  // The straight line: inside a hoop of twice the roller, the mark runs
  // along a diameter, at 3,600 points of the trip.
  var offLine = 0.0;
  for (var coin = 1; 2 * coin <= Rules.most; coin++) {
    final hoop = 2 * coin;
    var least = double.infinity, most = -double.infinity;
    for (var k = 0; k < 3600; k++) {
      final (_, _, mx, my) = Rules.place(hoop, coin, true, 2 * pi * k / 3600);
      offLine = max(offLine, my.abs());
      least = min(least, mx);
      most = max(most, mx);
    }
    if ((least + hoop).abs() > 1e-9 || (most - hoop).abs() > 1e-9) {
      stderr.writeln('THE MARK DOES NOT RUN THE WHOLE DIAMETER: $least TO $most IN A HOOP OF $hoop');
      exit(1);
    }
  }
  if (offLine >= 1e-9) {
    stderr.writeln('THE MARK LEAVES THE LINE BY $offLine');
    exit(1);
  }
  // And the mark of the equal coins comes back to the hoop once a trip,
  // at the start and nowhere else: the heart's one cusp. A hoop of twice
  // the roller is touched twice a trip; a hoop of half the roller only
  // at the start, and then not again until the second trip is done.
  int touches(int hoop, int coin, int trips) {
    var n = 0;
    for (var k = 0; k < 3600 * trips; k++) {
      final (_, _, mx, my) = Rules.place(hoop, coin, false, 2 * pi * k / 3600);
      if ((sqrt(mx * mx + my * my) - hoop).abs() < 1e-9) n++;
    }
    return n;
  }
  if (touches(2, 2, 1) != 1 || touches(2, 1, 1) != 2 || touches(1, 2, 1) != 1 || touches(1, 2, 2) != 1 || touches(1, 2, 3) != 2) {
    stderr.writeln('THE TOUCHES ARE OFF: ${touches(2, 2, 1)}, ${touches(2, 1, 1)}, ${touches(1, 2, 1)}, ${touches(1, 2, 2)}');
    exit(1);
  }

  stdout.writeln(
      'every setting of the hoop and the roller swept, one to six each, round '
      'the outside and round the inside, 72 settings, the roller too big for the '
      'inside in 21 of them; every trip that fits, 51, rolled in 36,000 pivots '
      'about the point of contact, and the turns rolled agree with the formula, '
      'hoop plus roller over roller outside and hoop less roller over roller '
      'inside, to within ${(worst * 1e6).ceil()} millionths of a turn on every one: equal coins turn '
      'twice, 6 settings; a hoop of twice the roller turns it three times '
      'outside and once inside, 3 settings each; a hoop of half the roller '
      'turns it one and a half times, 3 settings; inside a hoop of twice the '
      'roller the mark runs the whole diameter, off the line by less than a '
      'thousand-millionth at 3,600 points, and round an equal hoop it draws a '
      'heart that touches the hoop once a trip; and nothing turns exactly once '
      'round the outside, the trip alone being a turn, the nearest a hoop of one '
      'and a roller of six at 7/6 of a turn');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(15);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the ${Rules.settings} settings land it'
        : ' ${number + 1} $name ${level.task}: none of the ${Rules.settings}, and the trip said so first');
  }
}
