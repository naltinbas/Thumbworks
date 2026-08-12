import 'dart:io';

import 'package:quirebeck/quire/quires.dart';
import 'package:quirebeck/quire/rules.dart';

/// Proves the figures against the walk and plays every quire out.
/// Refuses the bake on any disagreement: this is what `make quires`
/// runs, and the README quotes its ledger verbatim.
void main() {
  // The seat words, on eight leaves and sixteen: the shortest
  // weaving to every seat is the seat's figure in binary, held
  // against a walk of every weaving.
  for (final leaves in const [8, 16]) {
    final bound = [for (var at = 0; at < leaves; at++) at];
    for (var seat = 0; seat < leaves; seat++) {
      final word = Rules.seatWord(seat);
      var stack = bound;
      for (final inward in word) {
        stack = Rules.weave(stack, inward);
      }
      if (stack[seat] != 0) {
        stderr.writeln('WORD WRONG: seat $seat of $leaves');
        exit(1);
      }
      final walked =
          Rules.fewest(bound, (stack) => stack[seat] == 0);
      if (walked != word.length) {
        stderr.writeln('WALK DISAGREES: seat $seat of $leaves, '
            'word ${word.length}, walk $walked');
        exit(1);
      }
    }
  }

  // The parity voice: both weaves are even, the turned pair is odd,
  // and the walked world of a quire of eight misses it.
  final bound8 = [for (var at = 0; at < 8; at++) at];
  for (final inward in const [false, true]) {
    if (!Rules.isEven(Rules.weave(bound8, inward))) {
      stderr.writeln('A WEAVE CAME OUT ODD');
      exit(1);
    }
  }
  final turned = Quires.at(5).start;
  if (Rules.isEven(turned)) {
    stderr.writeln('THE TURNED PAIR CAME OUT EVEN');
    exit(1);
  }
  final world = Rules.orbit(bound8);
  if (world.length != 24 ||
      world.containsKey(turned.join(','))) {
    stderr.writeln('THE ORBIT LIES: ${world.length} stacks');
    exit(1);
  }

  // Coming round: the walk against the figures, and the famous pack.
  for (final leaves in const [8, 16, 52]) {
    if (Rules.comeRound(leaves) != Rules.comeRoundByFigures(leaves)) {
      stderr.writeln('COME-ROUND DISAGREES on $leaves');
      exit(1);
    }
  }

  stdout.writeln(
      'the seat words against the walk of every weaving, every seat '
      'of eight leaves and of sixteen: the shortest weaving to a '
      'seat is the seat\'s figure in binary, an in for a one and an '
      'out for a nought');
  stdout.writeln(
      'every weave is an even count of swaps; a quire of eight '
      'reaches ${world.length} stacks of the 40,320 there are, and '
      'a single turned pair is none of them');
  stdout.writeln(
      'out-weaves come round in ${Rules.comeRound(8)} on eight '
      'leaves, ${Rules.comeRound(16)} on sixteen, '
      '${Rules.comeRound(52)} on a full pack of 52');
  stdout.writeln('');

  for (var number = 0; number < Quires.count; number++) {
    final quire = Quires.at(number);
    final walked = Rules.fewest(quire.start, quire.isDone);

    if (quire.winnable != (walked != -1) ||
        (quire.winnable && walked != quire.weaves)) {
      stderr.writeln('${quire.name}: label says ${quire.weaves}, '
          'walk says $walked');
      exit(1);
    }

    final name = quire.name.padRight(16);
    final task = quire.home
        ? 'back to bound order'
        : 'the plate to seat ${quire.seat! + 1}';
    stdout.writeln(quire.winnable
        ? ' ${number + 1} $name ${quire.leaves} leaves  $task in '
            '${quire.weaves} weave${quire.weaves == 1 ? '' : 's'}'
        : ' ${number + 1} $name ${quire.leaves} leaves  $task, and '
            'no weaving ever mends it');
  }
}
