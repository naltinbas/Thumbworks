import 'dart:io';

import 'package:frogmere/mere/gold.dart';
import 'package:frogmere/mere/reaches.dart';
import 'package:frogmere/mere/rules.dart';

/// Counts every road of every reach, weighs every army exactly,
/// weighs the whole pond, and refuses the bake on any
/// disagreement: this is what `make reaches` runs, and the README
/// quotes its ledger verbatim.
void main() {
  // The reckoning itself: a leap toward the aim keeps the weight,
  // exactly, at every distance.
  if (!Rules.leapTowardKeeps(40)) {
    stderr.writeln('A LEAP TOWARD THE AIM CHANGED THE WEIGHT');
    exit(1);
  }
  // And every other leap loses: checked as numbers over every
  // pad within reach, every direction.
  for (final reach in [1, 2, 3, 4, 5]) {
    final rules = Rules(reach, const []);
    for (var y = -12; y <= reach; y++) {
      for (var x = -12; x <= 12; x++) {
        for (final (dx, dy) in [(1, 0), (-1, 0), (0, 1), (0, -1)]) {
          final from = (x, y), over = (x + dx, y + dy), to = (x + 2 * dx, y + 2 * dy);
          if (to.$2 > reach) continue;
          final change =
              rules.weight(to) - rules.weight(from) - rules.weight(over);
          if (change > 1e-12) {
            stderr.writeln('A LEAP GAINED WEIGHT AT $from TOWARD $to');
            exit(1);
          }
        }
      }
    }
  }

  // Every reach's roads and fewest leaps, by the count, and its
  // army's exact weight.
  final touched = <String>{};
  for (final reach in Reaches.all) {
    final rules = Rules(reach.reach, reach.army);
    final roads = rules.roads(reach.army.toSet(), touchedEdge: touched);
    if (roads != reach.roads) {
      stderr.writeln('${reach.name}: count finds $roads roads, '
          'label says ${reach.roads}');
      exit(1);
    }
    final fewest = rules.fewest(reach.army.toSet()) ?? 0;
    if (fewest != reach.leaps) {
      stderr.writeln('${reach.name}: fewest is $fewest, label says '
          '${reach.leaps}');
      exit(1);
    }
    if (reach.winnable && rules.next(reach.army.toSet()) == null) {
      stderr.writeln('${reach.name}: no first leap');
      exit(1);
    }
  }
  if (touched.isNotEmpty) {
    stderr.writeln('THE COUNT WANDERED TO THE EDGE: $touched');
    exit(1);
  }

  // The four winnable armies weigh exactly one; every one of
  // their leaps therefore keeps the weight, and every frog is
  // used: leaps are frogs less one.
  for (var number = 0; number < 4; number++) {
    final reach = Reaches.at(number);
    final rules = Rules(reach.reach, reach.army);
    if (rules.exactWeightOf(reach.army) != Gold.one) {
      stderr.writeln('${reach.name} WEIGHS ${rules.exactWeightOf(reach.army)}');
      exit(1);
    }
    if (reach.leaps != reach.army.length - 1) {
      stderr.writeln('${reach.name} LEAPS ${reach.leaps} FROM ${reach.army.length}');
      exit(1);
    }
  }

  // The heaviest pads: three cannot reach the second, seven the
  // third, and nineteen weigh exactly one against the fourth.
  final second = Rules(2, const []);
  final third = Rules(3, const []);
  final fourth = Rules(4, const []);
  if (second.heaviest(3).toStringAsFixed(3) != '0.854' ||
      third.heaviest(7).toStringAsFixed(3) != '0.944' ||
      fourth.heaviestExact(19) != Gold.one ||
      fourth.heaviestExact(20) == Gold.one) {
    stderr.writeln('THE HEAVIEST PADS MOVED: ${second.heaviest(3)} '
        '${third.heaviest(7)} ${fourth.heaviestExact(19)}');
    exit(1);
  }

  // Nineteen frogs against the fourth reach: the only armies
  // weighing one are the sixteen pads within seven plus three of
  // the nine at eight, and none of the 84 lands.
  final within7 = <Pad>[
    for (var y = -8; y <= 0; y++)
      for (var x = -8; x <= 8; x++)
        if (fourth.distance((x, y)) <= 7) (x, y),
  ];
  final atEight = <Pad>[
    for (var y = -8; y <= 0; y++)
      for (var x = -8; x <= 8; x++)
        if (fourth.distance((x, y)) == 8) (x, y),
  ];
  if (within7.length != 16 || atEight.length != 9) {
    stderr.writeln('THE NEAR PADS MOVED: ${within7.length} ${atEight.length}');
    exit(1);
  }
  var armies = 0;
  for (var a = 0; a < 9; a++) {
    for (var b = a + 1; b < 9; b++) {
      for (var c = b + 1; c < 9; c++) {
        final army = {...within7, atEight[a], atEight[b], atEight[c]};
        armies++;
        if (fourth.exactWeightOf(army) != Gold.one) {
          stderr.writeln('A NINETEEN ARMY DOES NOT WEIGH ONE');
          exit(1);
        }
        if (Rules(4, army.toList()).lands(army)) {
          stderr.writeln('NINETEEN FROGS REACHED THE FOURTH');
          exit(1);
        }
      }
    }
  }
  if (armies != 84) {
    stderr.writeln('$armies ARMIES OF NINETEEN, NOT 84');
    exit(1);
  }

  // The whole pond against the fifth reach weighs exactly one,
  // by the series, and creeps up to it as it is added out.
  if (!Rules.seriesHolds() || Rules.wholePond(5) != Gold.one) {
    stderr.writeln('THE WHOLE POND WEIGHS ${Rules.wholePond(5)}');
    exit(1);
  }
  var last = 0.0;
  for (final span in [5, 10, 20, 40, 60]) {
    final part = Rules.pondOut(5, span);
    if (part <= last || part >= 1) {
      stderr.writeln('THE POND OUT TO $span WEIGHS $part');
      exit(1);
    }
    last = part;
  }
  if (last < 0.999999) {
    stderr.writeln('THE POND OUT TO 60 WEIGHS ONLY $last');
    exit(1);
  }
  final fifth = Reaches.at(4);
  final fifthWeight = Rules(5, fifth.army).weightOf(fifth.army);
  if (fifth.army.length != 27 || fifthWeight.toStringAsFixed(3) != '0.679') {
    stderr.writeln('THE FIFTH ARMY WEIGHS $fifthWeight WITH ${fifth.army.length}');
    exit(1);
  }

  stdout.writeln(
      'every road of every reach counted, 1, 1, 8 and 369,106,018 of them '
      'and none to the fifth: a leap toward the aim keeps the weight '
      'exactly and every other leap loses, the four armies that land '
      'weigh exactly one so every road spends every frog, three frogs '
      'weigh 0.854 at most against the second reach and seven 0.944 '
      'against the third, all 84 nineteen-frog armies weighing one '
      'against the fourth find no road, and the whole pond below the '
      'reeds weighs exactly one against the fifth by the series and '
      '0.679 for the twenty-seven set down');
  stdout.writeln('');

  for (var number = 0; number < Reaches.count; number++) {
    final reach = Reaches.at(number);
    final name = reach.name.padRight(17);
    stdout.writeln(reach.winnable
        ? ' ${number + 1} $name ${reach.task}: ${_commas(reach.roads)} '
            'road${reach.roads == 1 ? '' : 's'} of the count '
            'land${reach.roads == 1 ? 's' : ''} it in ${reach.leaps} '
            'leap${reach.leaps == 1 ? '' : 's'}'
        : ' ${number + 1} $name ${reach.task}: none, and the whole '
            'pond weighs one, so no army ever will');
  }
}

/// 369106018 as 369,106,018.
String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
