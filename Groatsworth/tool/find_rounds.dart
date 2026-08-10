// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:groatsworth/till/fewest.dart';
import 'package:groatsworth/till/till.dart';

/// Walks the old till: every amount where taking the biggest coin fails, and
/// among them the ones whose fewest is exactly the plain floor, which are the
/// ones worth shipping.
void main() {
  final fewests = Fewests(Tills.old);

  print('amounts up to 240d where the biggest coin that fits is not the '
      'fewest:');
  for (final amount in fewests.whereBiggestFails(240)) {
    final best = fewests.fewestFor(amount);
    final quick = fewests.byBiggest(amount).fewest;
    final floor = fewests.floorFor(amount);
    print('  ${Tills.old.spoken(amount).padLeft(5)} ($amount d)  '
        'fewest $best  biggest-first $quick  floor $floor'
        '${best == floor ? '  TIGHT' : ''}');
  }

  final decimal = Fewests(Tills.decimal);
  final fails = decimal.whereBiggestFails(500);
  print('');
  print('on the new till, amounts up to 500 where it fails: '
      '${fails.isEmpty ? 'none at all' : fails}');
}
