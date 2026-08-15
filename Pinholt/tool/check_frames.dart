import 'dart:io';

import 'package:pinholt/board/plots.dart';
import 'package:pinholt/board/rules.dart';

/// Sets every placing of four, five and six pins, counts the
/// frames, holds the fence to the census, and refuses the bake on
/// any disagreement: this is what `make frames` runs, and the
/// README quotes its ledger verbatim.
void main() {
  final rules = Rules(5);
  for (final plot in Plots.all) {
    final (ways, all) = rules.waysBySweep(plot.pins, plot.asked);
    if (ways != plot.ways || all != plot.placings) {
      stderr.writeln('${plot.name}: sweep finds $ways of $all, '
          'label says ${plot.ways} of ${plot.placings}');
      exit(1);
    }
  }

  // Four and five pins: the fence alone tells the frame count,
  // over every placing, and five pins hold 1, 3 or 5 and never
  // nought; the lone frame of a fence of three is built, not
  // searched, and is a frame every time.
  final spreadFour = <int, int>{};
  rules.placings(4, (pins) {
    final counted = Rules.frames(pins).length;
    spreadFour[counted] = (spreadFour[counted] ?? 0) + 1;
    if (Rules.framesByFence(pins) != counted) {
      stderr.writeln('THE FENCE OF FOUR PARTED FROM THE CENSUS AT $pins');
      exit(1);
    }
  });
  final spreadFive = <int, int>{};
  final byFence = <int, int>{};
  rules.placings(5, (pins) {
    final counted = Rules.frames(pins).length;
    spreadFive[counted] = (spreadFive[counted] ?? 0) + 1;
    if (Rules.framesByFence(pins) != counted) {
      stderr.writeln('THE FENCE OF FIVE PARTED FROM THE CENSUS AT $pins');
      exit(1);
    }
    final round = Rules.fence(pins).length;
    byFence[round] = (byFence[round] ?? 0) + 1;
    if (round == 3) {
      final lone = Rules.lonelyFrame(pins);
      if (lone == null || !Rules.isFrame(lone)) {
        stderr.writeln('THE LONE FRAME DID NOT BUILD AT $pins');
        exit(1);
      }
    }
  });
  if ('${_sorted(spreadFour)}' != '{0: 2100, 1: 7398}' ||
      '${_sorted(spreadFive)}' != '{1: 624, 3: 12800, 5: 11628}' ||
      '${_sorted(byFence)}' != '{3: 624, 4: 12800, 5: 11628}') {
    stderr.writeln('THE SPREADS MOVED: $spreadFour $spreadFive $byFence');
    exit(1);
  }

  // Six pins: the spread by fence and count, three the fewest.
  final six = <String, int>{};
  var fewest = 99;
  rules.placings(6, (pins) {
    final counted = Rules.frames(pins).length;
    final round = Rules.fence(pins).length;
    six['$round:$counted'] = (six['$round:$counted'] ?? 0) + 1;
    if (counted < fewest) fewest = counted;
  });
  const wantSix = {
    '3:3': 12, '3:5': 16, '3:6': 44,
    '4:7': 656, '4:8': 1912, '4:9': 3614,
    '5:10': 2532, '5:11': 10732, '5:12': 8420,
    '6:15': 8760,
  };
  if (fewest != 3 || six.length != wantSix.length) {
    stderr.writeln('THE SIXES MOVED: $six');
    exit(1);
  }
  for (final entry in wantSix.entries) {
    if (six[entry.key] != entry.value) {
      stderr.writeln('THE SIXES MOVED AT ${entry.key}: ${six[entry.key]}');
      exit(1);
    }
  }

  stdout.writeln(
      'every placing of four, five and six pins set with no three in a '
      'line, 9,498 and 25,052 and 36,698 of them, and every four of every '
      'placing read for a frame: four pins frame 7,398 ways and go '
      'frameless 2,100, five pins hold 1, 3 or 5 frames by their fence '
      'of three, four or five and never nought, the lone frame of a '
      'fence of three built for all 624, and six pins hold three frames '
      'at the fewest, in 12 placings, and fifteen at the most');
  stdout.writeln('');

  for (var number = 0; number < Plots.count; number++) {
    final plot = Plots.at(number);
    final name = plot.name.padRight(19);
    stdout.writeln(plot.winnable
        ? ' ${number + 1} $name ${plot.task}: ${_commas(plot.ways)} '
            'placing${plot.ways == 1 ? '' : 's'} of the '
            '${_commas(plot.placings)} land${plot.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${plot.task}: none of the '
            '${_commas(plot.placings)}, and the fence said so first');
  }
}

Map<int, int> _sorted(Map<int, int> m) =>
    {for (final k in m.keys.toList()..sort()) k: m[k]!};

/// 25052 as 25,052.
String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
