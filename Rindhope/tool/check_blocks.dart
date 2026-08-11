// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:rindhope/cheese/blocks.dart';
import 'package:rindhope/cheese/fewest.dart';

/// Walks every shipped block and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_blocks.dart  (or `make blocks`)
void main() {
  // The theorem first: the first mouse wins every whole block to seven by
  // seven, proved by the search since the proof will not say.
  var proved = 0;
  for (var width = 1; width <= 7; width++) {
    for (var height = 1; height <= 7; height++) {
      if (width == 1 && height == 1) continue;
      final whole = List<int>.filled(width, height);
      if (Bites.isLoss(whole)) {
        throw StateError('the first mouse loses ${width}x$height');
      }
      proved++;
    }
  }
  print('the first mouse wins every whole block to seven by seven: '
      '$proved blocks\n');

  var wrong = 0;
  for (var number = 0; number < Blocks.count; number++) {
    final block = Blocks.at(number);
    final whole = block.whole;
    final int? fewest;
    if (block.mouseFirst) {
      // The grey mouse bites first and best; the player faces its answer.
      final (x, y) = Bites.reply(whole);
      fewest = Bites.isLoss(Bites.bitten(whole, x, y)) ? null : -1;
    } else {
      fewest = Bites.isLoss(whole) ? null : Bites.fewestWin(whole);
    }

    final agree = fewest == block.fewest;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${block.name.padRight(16)} '
        '${block.width}x${block.height}  '
        '${block.mouseFirst ? "the grey mouse first  " : ""}'
        '${fewest == null ? "cannot be won" : "fewest $fewest"}'
        '  written down ${block.fewest ?? "none"}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong block${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped blocks are not what they claim');
  }
}
