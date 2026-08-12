import 'dart:io';

import 'package:watchmere/watch/meres.dart';
import 'package:watchmere/watch/rules.dart';

/// Slides every dialling of every mere, holds Helly on the
/// line, and refuses the bake on any disagreement: this is
/// what `make watches` runs, and the README quotes its ledger
/// verbatim.
void main() {
  for (final mere in Meres.all) {
    final rules = Rules(mere.lengths);
    final ways = rules.waysTo(mere.pairs, common: mere.common);
    if (ways != mere.ways) {
      stderr.writeln('${mere.name}: sweep finds $ways, '
          'label says ${mere.ways}');
      exit(1);
    }
    // No mere opens landed.
    final opensPairs = rules.pairsOverlapping(mere.opens);
    final opensHeld = rules.commonHours(mere.opens);
    final opensWidth =
        opensHeld == null ? 0 : opensHeld.$2 - opensHeld.$1 + 1;
    final opensLands = opensPairs == mere.pairs &&
        (mere.common == null || opensWidth == mere.common);
    if (opensLands) {
      stderr.writeln('${mere.name} OPENS LANDED');
      exit(1);
    }
  }

  // Helly over every dialling of both walls.
  if (!Rules([4, 4, 4]).lawHolds() ||
      !Rules([6, 5, 4, 3]).lawHolds()) {
    stderr.writeln('THE LAW BROKE');
    exit(1);
  }

  // The full-ring counts split by shared width, pinned.
  final three = Rules([4, 4, 4]);
  if (three.waysTo(3) != 249 ||
      three.waysTo(3, common: 1) != 108 ||
      three.waysTo(2, common: 0) != 156 ||
      three.waysTo(3, common: 0) != 0) {
    stderr.writeln('THE THREE-WATCH COUNTS MOVED');
    exit(1);
  }
  if (Rules([6, 5, 4, 3]).waysTo(6) != 1206) {
    stderr.writeln('THE FOUR-WATCH COUNT MOVED');
    exit(1);
  }

  stdout.writeln(
      'every dialling of every mere slid, 729 of the three '
      'watches and 5,040 of the four: whenever every pair '
      'overlaps some hour sits inside them all, on every single '
      'dialling, while two overlaps of three go without a '
      'shared hour 156 ways, and the full ring without one goes '
      'nought ways at all');
  stdout.writeln('');

  for (var number = 0; number < Meres.count; number++) {
    final mere = Meres.at(number);
    final name = mere.name.padRight(18);
    stdout.writeln(mere.winnable
        ? ' ${number + 1} $name ${mere.task}: ${mere.ways} '
            'dialling${mere.ways == 1 ? '' : 's'} of the sweep '
            'land${mere.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${mere.task}: none of the 729, '
            'and the named pair said so first');
  }
}
