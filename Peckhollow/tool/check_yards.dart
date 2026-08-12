import 'dart:io';

import 'package:peckhollow/yard/rules.dart';
import 'package:peckhollow/yard/yards.dart';

/// Sweeps every yard of every size that ships, proves the king
/// theorems on all of them, and refuses the bake on any
/// disagreement: this is what `make yards` runs, and the README
/// quotes its ledger verbatim.
void main() {
  for (final birds in const [3, 4, 5]) {
    final count = Rules.pairs(birds).length;
    for (var arrows = 0; arrows < (1 << count); arrows++) {
      final kings = Rules.kings(birds, arrows);
      // Every yard has a king, and the biggest winner is one.
      if (kings.isEmpty ||
          !kings.contains(Rules.biggestWinner(birds, arrows))) {
        stderr.writeln('A YARD WITHOUT ITS WINNER-KING: '
            '$birds birds, arrows $arrows');
        exit(1);
      }
      // No yard crowns exactly two.
      if (kings.length == 2) {
        stderr.writeln('TWO KINGS: $birds birds, arrows $arrows');
        exit(1);
      }
      // Any king's peckers hide another king.
      final table = Rules.pecks(birds, arrows);
      for (final king in kings) {
        final peckers = [
          for (var bird = 0; bird < birds; bird++)
            if (table[bird][king]) bird,
        ];
        if (peckers.isEmpty) continue;
        var top = peckers.first;
        var topWon = -1;
        for (final bird in peckers) {
          final won =
              peckers.where((other) => table[bird][other]).length;
          if (won > topWon) {
            topWon = won;
            top = bird;
          }
        }
        if (!kings.contains(top)) {
          stderr.writeln('A KING\'S PECKERS HID NO KING: '
              '$birds birds, arrows $arrows');
          exit(1);
        }
      }
    }
  }

  // The note-claims, each recomputed from the sweeps.
  final threes = Rules.crownings(3);
  final fours = Rules.crownings(4);
  final fives = Rules.crownings(5);
  if (threes[3] != 2 ||
      fours[1] != 32 ||
      fours[3] != 32 ||
      fours.containsKey(2) ||
      fours.containsKey(4) ||
      fives[3] != 520 ||
      fives[5] != 64) {
    stderr.writeln('A CROWNING COUNT BROKE');
    exit(1);
  }
  // The two all-king three-yards are the two rings: every bird
  // pecks exactly one.
  for (var arrows = 0; arrows < 8; arrows++) {
    if (Rules.kings(3, arrows).length != 3) continue;
    final table = Rules.pecks(3, arrows);
    for (var bird = 0; bird < 3; bird++) {
      if (table[bird].where((pecked) => pecked).length != 1) {
        stderr.writeln('AN ALL-KING THREE-YARD IS NO RING');
        exit(1);
      }
    }
  }

  stdout.writeln(
      'every yard has a king, the biggest winner being one: '
      'whatever pecked it was pecked by something it pecked; any '
      'king\'s peckers hide another king; and no yard crowns '
      'exactly two, swept over all 8, 64 and 1,024 yards of '
      'three, four and five birds');
  stdout.writeln('');

  for (var number = 0; number < Yards.count; number++) {
    final yard = Yards.at(number);
    final walked =
        Rules.flipsTo(yard.birds, yard.start, yard.goalMet);

    if (yard.winnable ? walked != yard.par : walked != -1) {
      stderr.writeln('${yard.name}: label says ${yard.par}, '
          'sweep says $walked');
      exit(1);
    }

    final name = yard.name.padRight(16);
    stdout.writeln(yard.winnable
        ? ' ${number + 1} $name ${yard.birds} birds  ${yard.task}: '
            '${yard.par} flip${yard.par == 1 ? '' : 's'} from the '
            'pecking order'
        : ' ${number + 1} $name ${yard.birds} birds  ${yard.task}: '
            'no flipping of any yard does');
  }
}
