// A command line tool whose whole job is to print. It is not part of any game.
// ignore_for_file: avoid_print

import 'package:tallowfield/garden/code.dart';
import 'package:tallowfield/garden/evenings.dart';

/// Walks every shipped evening and prints the ledger the README quotes.
///
/// Run with: dart run tool/check_evenings.dart  (or `make evenings`)
void main() {
  // The code first, everywhere, before the ledger.
  final sound = Code.soundPlantings();
  if (sound.length != 16) throw StateError('not sixteen sound plantings');
  for (final planting in sound) {
    for (var lamp = 1; lamp <= 7; lamp++) {
      final blown = planting ^ (1 << (lamp - 1));
      if (Code.named(blown) != lamp ||
          Code.namedByTrying(blown) != lamp) {
        throw StateError('the tallies misname lamp $lamp of $planting');
      }
    }
  }
  print('the tallies name the changed lantern on all '
      '${sound.length * 7} one-draught evenings there are\n');

  var wrong = 0;
  for (var number = 0; number < Evenings.count; number++) {
    final evening = Evenings.at(number);
    final named = Code.named(evening.seen);
    final truth = evening.snuffed;

    final expectTrue = truth.length <= 1;
    final pointsTrue =
        truth.isEmpty ? named == 0 : truth.length == 1 && named == truth.single;
    final agree = pointsTrue == expectTrue;
    if (!agree) wrong++;

    print('${(number + 1).toString().padLeft(2)} '
        '${evening.name.padRight(18)} '
        'draught at ${truth.isEmpty ? "nothing" : truth.join(" and ")}'
        '  the tallies say ${named == 0 ? "all is well" : "lamp $named"}'
        '${pointsTrue ? "  true" : "  MISTAKEN, as built"}'
        '${agree ? '' : '  WRONG'}');
  }

  if (wrong > 0) {
    print('\n$wrong evening${wrong == 1 ? '' : 's'} wrong');
    throw StateError('the shipped evenings are not what they claim');
  }
}
