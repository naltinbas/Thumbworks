import 'dart:io';

import 'package:stickerwick/album/levels.dart';
import 'package:stickerwick/album/play.dart';
import 'package:stickerwick/album/rules.dart';

/// Works every set and every count of packets in exact fractions two
/// ways each, holds the voices together, and refuses the bake on any
/// disagreement: this is what `make albums` runs, and the README quotes
/// its ledger verbatim.
void main() {
  // The averages by the stages and by the tail, sets of one to twelve.
  final averages = <String>[];
  for (var n = 1; n <= Rules.mostStickers; n++) {
    final a = Rules.averageByStages(n), b = Rules.averageByTail(n);
    if (a != b) {
      stderr.writeln('$n STICKERS: THE STAGES SAY $a, THE TAIL $b');
      exit(1);
    }
    averages.add(a.toString());
  }
  if (averages.join(' ') != '1 3 11/2 25/3 137/12 147/10 363/20 761/35 7129/280 7381/252 83711/2520 86021/2310') {
    stderr.writeln('THE AVERAGES ARE $averages');
    exit(1);
  }
  // The chance of a full album by counting and by walking, on every
  // setting; the medians; and never certain past one sticker.
  final medians = <int>[];
  for (var n = 1; n <= Rules.mostStickers; n++) {
    for (var m = 1; m <= Rules.mostPackets; m++) {
      final a = Rules.fullAfter(n, m), b = Rules.fullAfterByWalk(n, m);
      if (a != b) {
        stderr.writeln('$n STICKERS, $m PACKETS: COUNTING SAYS $a, THE WALK $b');
        exit(1);
      }
      if (n >= 2 && a == Frac.one) {
        stderr.writeln('$n STICKERS, $m PACKETS: CERTAIN');
        exit(1);
      }
      if (n == 1 && a != Frac.one) {
        stderr.writeln('ONE STICKER, $m PACKETS: NOT CERTAIN');
        exit(1);
      }
      if (m > 1 && a.compareTo(Rules.fullAfter(n, m - 1)) < 0) {
        stderr.writeln('$n STICKERS: THE CHANCE FALLS AT $m PACKETS');
        exit(1);
      }
    }
    medians.add(Rules.median(n));
  }
  if (medians.toString() != '[1, 2, 5, 7, 10, 13, 17, 20, 23, 27, 31, 35]') {
    stderr.writeln('THE MEDIANS ARE $medians');
    exit(1);
  }
  // Every level's label against the sweep, the aim landing it, and no
  // level over at the opening.
  for (final level in Levels.all) {
    var met = 0;
    (int, int)? first;
    for (var n = 1; n <= Rules.mostStickers; n++) {
      for (var m = 1; m <= Rules.mostPackets; m++) {
        if (level.meets(n, m)) {
          met++;
          first ??= (n, m);
        }
      }
    }
    if (met != level.ways) {
      stderr.writeln('${level.name}: sweep finds $met of ${Rules.settings}, label says ${level.ways}');
      exit(1);
    }
    final aim = level.aim;
    if (aim == null ? first != null : !level.meets(aim.$1, aim.$2)) {
      stderr.writeln('${level.name}: the aim $aim does not land it, the sweep finds $first');
      exit(1);
    }
    if (Play.of(level).isOver) {
      stderr.writeln('${level.name} OPENS OVER');
      exit(1);
    }
  }
  // The named facts.
  if (Rules.decimal(Rules.fullAfter(6, 13)) != '0.51' || Rules.decimal(Rules.fullAfter(6, 12)) != '0.43' || Rules.decimal(Rules.fullAfter(6, 60)) != '0.99' ||
      Rules.decimal(Rules.averageByStages(6)) != '14.70' || Rules.decimal(Rules.averageByStages(10)) != '29.28' || Rules.decimal(Rules.averageByStages(12)) != '37.23' ||
      Rules.averageByStages(3) - Frac.of(3) != Frac.of(5, 2) || Rules.averageByStages(4) - Frac.of(4) != Frac.of(13, 3)) {
    stderr.writeln('THE NAMED FACTS ARE OFF');
    exit(1);
  }
  // A set of six short after sixty packets: one time in ten thousand, as
  // a decimal to four places, cut.
  final short = Frac.one - Rules.fullAfter(6, 60);
  final tenThousandths = short.n * BigInt.from(10000) ~/ short.d;
  if (tenThousandths != BigInt.one) {
    stderr.writeln('SIX SHORT AFTER SIXTY: $tenThousandths IN TEN THOUSAND');
    exit(1);
  }

  stdout.writeln(
      'every set of one to twelve stickers worked in exact fractions, its average '
      'packets by the stages and by the tail summed, and the two agree on all '
      'twelve: 1, 3, 11/2, 25/3, 137/12, 147/10, 363/20, 761/35, 7,129/280, '
      '7,381/252, 83,711/2,520 and 86,021/2,310, whole for one and two alone; the '
      'chance of a full album after every count of packets to sixty worked by '
      'counting the ways and by walking the packets, agreeing on all 720 settings, '
      'never falling as the packets grow, certain for one sticker and never for '
      'two or more, a set of six short after sixty packets one time in ten '
      'thousand; the album turns more likely full than not at 1, 2, 5, 7, 10, 13, '
      '17, 20, 23, 27, 31 and 35 packets for sets of one to twelve, six being 0.51 '
      'at thirteen and 0.43 at twelve; and the last sticker outweighs the rest '
      'for sets of one to three, 3 to 5/2 for three, and not from four, 4 to 13/3');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the 720 settings ${level.ways == 1 ? 'lands' : 'land'} it'
        : ' ${number + 1} $name ${level.task}: none of the 720, and the same sticker again said so first');
  }
}
