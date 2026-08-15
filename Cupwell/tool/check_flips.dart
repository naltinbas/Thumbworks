import 'dart:io';

import 'package:cupwell/tray/levels.dart';
import 'package:cupwell/tray/rules.dart';

/// Sweeps every sequence of turns for every tray, walks the reach of
/// every tray, holds the parity law to it, and refuses the bake on any
/// disagreement: this is what `make flips` runs, and the README quotes
/// its ledger verbatim.
void main() {
  // Every level's label against the sweep, and its turns against the
  // fewest by search.
  for (final level in Levels.all) {
    final rules = Rules(level.cups, level.each);
    final (righting, all) = rules.sequences(level.down, level.turns);
    if (righting != level.ways || all != level.sequences) {
      stderr.writeln('${level.name}: sweep finds $righting of $all, label says ${level.ways} of ${level.sequences}');
      exit(1);
    }
    final fewest = rules.fewest(level.down);
    if (level.winnable && fewest != level.turns) {
      stderr.writeln('${level.name}: fewest by search $fewest, turns allowed ${level.turns}');
      exit(1);
    }
    if (!level.winnable && fewest != null) {
      stderr.writeln('${level.name}: RIGHTED IN $fewest');
      exit(1);
    }
    if (rules.barredByParity(level.down) == level.winnable) {
      stderr.writeln('${level.name}: PARITY AND THE LABEL DISAGREE');
      exit(1);
    }
  }

  // Every tray of up to six cups, every count turned at a time short of
  // the whole tray, every start: with an even count turned, all up is
  // out of reach exactly when the count down is odd, and the parity of
  // the count down never changes; with an odd count turned, every tray
  // is in reach. Turning the whole tray reaches only the tray and its
  // opposite.
  var trays = 0, barred = 0;
  for (var cups = 2; cups <= 6; cups++) {
    for (var each = 1; each <= cups; each++) {
      final rules = Rules(cups, each);
      for (var from = 0; from < (1 << cups); from++) {
        trays++;
        final f = rules.fewest(from);
        if (each == cups) {
          if (rules.reachable(from).length != 2) {
            stderr.writeln('$cups BY $each FROM $from: REACH ${rules.reachable(from).length}');
            exit(1);
          }
          continue;
        }
        if ((f == null) != rules.barredByParity(from)) {
          stderr.writeln('$cups BY $each FROM $from: fewest $f, parity says ${rules.barredByParity(from)}');
          exit(1);
        }
        if (f == null) barred++;
        if (each.isEven) {
          for (final t in rules.reachable(from)) {
            if (Rules.downCount(t).isOdd != Rules.downCount(from).isOdd) {
              stderr.writeln('$cups BY $each FROM $from: PARITY CHANGED');
              exit(1);
            }
          }
        } else if (rules.reachable(from).length != (1 << cups)) {
          stderr.writeln('$cups BY $each FROM $from: ODD TURNS DO NOT REACH ALL');
          exit(1);
        }
      }
    }
  }
  // The named reaches.
  if (Rules(3, 2).reachable(0x1).length != 4 ||
      Rules(4, 3).reachable(0xF).length != 16 ||
      Rules(5, 3).reachable(0x1F).length != 32 ||
      Rules(6, 4).reachable(0x3F).length != 32) {
    stderr.writeln('THE REACHES MOVED');
    exit(1);
  }

  stdout.writeln(
      'every sequence of turns swept for every tray, and every tray of two '
      'to six cups walked from every start with every count turned at a '
      'time, $trays starts: short of turning the whole tray, an even count '
      'turned never changes whether the count down is odd or even and puts '
      'all up out of reach exactly when the count down is odd, $barred '
      'starts, while an odd count turned reaches every tray, and turning '
      'the whole tray reaches only the tray and its opposite; two of three '
      'right in one turn '
      'of three, four by threes in four turns 24 ways of 256, five by '
      'threes in three turns 60 ways of 1,000, six by fours in three '
      'turns 120 ways of 3,375, and one of three by twos never, four trays '
      'of the eight in reach and all up not among them');
  stdout.writeln('');

  for (var number = 0; number < Levels.count; number++) {
    final level = Levels.at(number);
    final name = level.name.padRight(18);
    stdout.writeln(level.winnable
        ? ' ${number + 1} $name ${level.task}: ${level.ways} of the '
            '${_commas(level.sequences)} sequences land${level.ways == 1 ? 's' : ''} it'
        : ' ${number + 1} $name ${level.task}: none of the '
            '${_commas(level.sequences)}, and odd against even said so first');
  }
}

String _commas(int n) {
  final digits = '$n';
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
    out.write(digits[i]);
  }
  return '$out';
}
