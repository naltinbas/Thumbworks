import 'dart:io';

import 'package:studwell/court/courts.dart';
import 'package:studwell/court/rules.dart';

/// Paves every court every way, holds Golomb's quartering to the
/// sweep, counts the studs, and refuses the bake on any
/// disagreement: this is what `make courts` runs, and the README
/// quotes its ledger verbatim.
void main() {
  for (final court in Courts.all) {
    final ways = Rules(court.side, court.well).waysBySweep();
    if (ways != court.ways) {
      stderr.writeln('${court.name}: sweep finds $ways, '
          'label says ${court.ways}');
      exit(1);
    }
  }

  // The four-court: every well paves exactly once, and the
  // quartering builds that one paving, elbow for elbow.
  for (var well = 0; well < 16; well++) {
    final rules = Rules(4, well);
    final ways = rules.waysBySweep();
    if (ways != 1) {
      stderr.writeln('WELL $well OF FOUR PAVES $ways WAYS');
      exit(1);
    }
    final swept = rules.landing()!;
    final built = rules.quartering()!;
    if (built.length != 5 || !rules.lands(built)) {
      stderr.writeln('THE QUARTERING OF WELL $well DID NOT LAND');
      exit(1);
    }
    final a = (swept.map((e) => e.join(',')).toList()..sort()).join(' ');
    final b = (built.map((e) => e.join(',')).toList()..sort()).join(' ');
    if (a != b) {
      stderr.writeln('WELL $well: SWEEP $a, QUARTERING $b');
      exit(1);
    }
  }

  // The five-court: an elbow covers at most one stud, there are
  // nine studs and eight elbows, and the sweep lands exactly on
  // the stud wells, 8 at a corner, 16 on a wall, 32 in the
  // middle. Every landing covers every other stud exactly once.
  final spread = <int, int>{};
  for (var well = 0; well < 25; well++) {
    final rules = Rules(5, well);
    if (rules.studs.length != 9 || rules.elbowsNeeded != 8) {
      stderr.writeln('THE STUD COUNT MOVED');
      exit(1);
    }
    for (final elbow in rules.elbows()) {
      if (rules.studsUnder(elbow) > 1) {
        stderr.writeln('AN ELBOW COVERS TWO STUDS: $elbow');
        exit(1);
      }
    }
    final ways = rules.waysBySweep();
    if ((ways > 0) != rules.isStud(well)) {
      stderr.writeln('WELL $well OF FIVE: $ways WAYS, '
          'STUD ${rules.isStud(well)}');
      exit(1);
    }
    if (ways > 0) {
      spread[well] = ways;
      rules.pavings((laid) {
        for (final elbow in laid) {
          if (rules.studsUnder(elbow) != 1) {
            stderr.writeln('A LANDING ELBOW MISSED ITS STUD AT $well');
            exit(1);
          }
        }
      });
    }
  }
  final corners = [0, 4, 20, 24].map((w) => spread[w]).toSet();
  final walls = [2, 10, 14, 22].map((w) => spread[w]).toSet();
  if ('$corners' != '{8}' || '$walls' != '{16}' || spread[12] != 32) {
    stderr.writeln('THE FIVE-COURT SPREAD MOVED: $spread');
    exit(1);
  }

  // Seven elbows fit round the stray well: this laying is read
  // for overlap and shape, and eight would be a paving, of
  // which there are none.
  final stray = Rules(5, Courts.at(4).well);
  const seven = [
    [0, 5, 6],
    [1, 2, 7],
    [3, 8, 9],
    [10, 15, 16],
    [12, 13, 18],
    [17, 21, 22],
    [19, 23, 24],
  ];
  final covered = <int>{};
  for (final elbow in seven) {
    if (!stray.isElbow(elbow) || elbow.contains(stray.well)) {
      stderr.writeln('THE SEVEN HOLD A BAD ELBOW: $elbow');
      exit(1);
    }
    for (final cell in elbow) {
      if (!covered.add(cell)) {
        stderr.writeln('THE SEVEN OVERLAP AT $cell');
        exit(1);
      }
    }
  }
  if (covered.length != 21 || stray.waysBySweep() != 0) {
    stderr.writeln('THE STRAY WELL PAVED');
    exit(1);
  }

  stdout.writeln(
      'every paving of every court swept: the four-court paves round '
      'each of its sixteen wells exactly once and Golomb\'s quartering '
      'lays the same sixteen pavings elbow for elbow, while on the '
      'five-court an elbow covers at most one of the nine studs, so '
      'the eight elbows land only where the well is a stud, 8 ways at '
      'a corner, 16 on a wall and 32 in the middle, and nought at the '
      'sixteen other wells, seven elbows being the most the stray '
      'well takes');
  stdout.writeln('');

  for (var number = 0; number < Courts.count; number++) {
    final court = Courts.at(number);
    final name = court.name.padRight(16);
    stdout.writeln(court.winnable
        ? ' ${number + 1} $name ${court.task}: ${court.ways} '
            'paving${court.ways == 1 ? '' : 's'} of the sweep '
            'land${court.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${court.task}: none, and the nine '
            'studs said so first');
  }
}
