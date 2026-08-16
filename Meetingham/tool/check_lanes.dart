import 'dart:io';

import 'package:meetingham/lane/levels.dart';
import 'package:meetingham/lane/play.dart';
import 'package:meetingham/lane/rules.dart';

/// Crosses the lanes on every setting of the three gates, holds the
/// crossing to Ceva's product, and refuses the bake on any disagreement:
/// this is what `make lanes` runs, and the README quotes its ledger
/// verbatim.
void main() {
  // The two voices on every setting: the crossing against the product.
  var meetings = 0, withMiddle = 0;
  for (var d = 1; d < Rules.paces; d++) {
    for (var e = 1; e < Rules.paces; e++) {
      for (var f = 1; f < Rules.paces; f++) {
        final byCrossing = Rules.meetByCrossing(d, e, f), byCeva = Rules.meetByCeva(d, e, f);
        if (byCrossing != byCeva) {
          stderr.writeln('$d $e $f: THE CROSSING SAYS $byCrossing, CEVA $byCeva');
          exit(1);
        }
        if (byCrossing) {
          meetings++;
          if ([d, e, f].contains(Rules.paces ~/ 2)) withMiddle++;
        }
      }
    }
  }
  if (Rules.settings != 1331 || meetings != 31 || withMiddle != 31) {
    stderr.writeln('${Rules.settings} SETTINGS, $meetings MEET, $withMiddle WITH A MIDDLE');
    exit(1);
  }
  // Every level's label against the sweep, the aim landing it, and no
  // level over at the opening.
  for (final level in Levels.all) {
    final (met, all, first) = Rules.sweep(level.meets);
    if (met != level.ways || all != 1331) {
      stderr.writeln('${level.name}: sweep finds $met of $all, label says ${level.ways}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? first != null : !level.meets(aim.$1, aim.$2, aim.$3)) {
      stderr.writeln('${level.name}: the aim $aim does not land it, the sweep finds $first');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }
  // The named facts: the medians meet at (4, 4); (4, 8, 6) at (24/5,
  // 12/5); the thirds give 1:8 and 8:1; the quarter's two settings.
  if (Rules.meetingPoint(6, 6, 6) != (4, 4, 1) || Rules.meetingPoint(4, 8, 6) != (24, 12, 5) || Rules.product(4, 4, 4) != (64, 512) || Rules.product(8, 8, 8) != (512, 64) ||
      Rules.meetByCrossing(4, 4, 4) || Rules.meetByCrossing(8, 8, 8) || Rules.ratio(4) != '1:2' || Rules.ratio(3) != '1:3' || Rules.ratio(9) != '3:1' || Rules.ratio(6) != '1:1') {
    stderr.writeln('THE NAMED FACTS ARE OFF');
    exit(1);
  }
  final quarter = <String>[];
  for (var e = 1; e < 12; e++) {
    for (var f = 1; f < 12; f++) {
      if (Rules.meetByCrossing(3, e, f)) quarter.add('$e,$f');
    }
  }
  if (quarter.join(' ') != '6,9 9,6') {
    stderr.writeln('THE QUARTER SETTINGS ARE $quarter');
    exit(1);
  }
  // Two gates at middles force the third: with d and e at 6, only f at 6
  // meets.
  for (var f = 1; f < 12; f++) {
    if (Rules.meetByCrossing(6, 6, f) != (f == 6)) {
      stderr.writeln('TWO MIDDLES AND F AT $f');
      exit(1);
    }
  }

  stdout.writeln(
      'every setting of the three gates at whole paces on the field of twelve, '
      '1,331 settings, the lanes from A and B crossed in whole-number arithmetic '
      'and the lane from C tried on the crossing, and Ceva\'s product of the three '
      'ratios worked beside it: the two say meet or miss alike on all 1,331; 31 '
      'settings meet, the medians at (4, 4) and thirty more, and every one of the '
      '31 has a gate at a middle; two gates at middles force the third to the '
      'middle; the gate on BC a quarter from B meets 2 ways, E middle and F 3:1 or '
      'E 3:1 and F middle; D at 1:2 and E at 2:1 meet only with F at the middle, '
      'at (24/5, 12/5); and every gate a third along, the same way round, gives '
      '1:8 one way and 8:1 the other and never meets');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(14);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the 1,331 settings ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: none of the 1,331, and the product said so first');
  }
}
