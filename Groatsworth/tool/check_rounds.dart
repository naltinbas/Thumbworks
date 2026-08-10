// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:groatsworth/till/fewest.dart';
import 'package:groatsworth/till/rounds.dart';
import 'package:groatsworth/till/till.dart';

/// Walks every shipped round: the fewest by the table, by trying every mix of
/// coins, what taking the biggest coin that fits would use, and the floor.
void main() {
  for (var number = 0; number < Rounds.count; number++) {
    final round = Rounds.at(number);
    final fewests = Fewests(round.till);
    final table = fewests.fewestFor(round.amount);
    final tried = fewests.byTrying(round.amount);
    final biggest = fewests.byBiggest(round.amount).fewest;
    final floor = fewests.floorFor(round.amount);

    print('${(number + 1).toString().padLeft(2)} '
        '${round.name.padRight(14)} '
        '${round.till.name.padRight(13)} '
        '${round.spoken.padLeft(5)} '
        '(${round.amount.toString().padLeft(3)}d)  '
        'fewest $table  '
        'written down ${round.fewest}  '
        'by trying $tried  '
        'biggest-first $biggest  '
        'floor $floor'
        '${table == tried ? '' : '  THE TWO DISAGREE'}'
        '${table == round.fewest ? '' : '  WRONG NUMBER WRITTEN DOWN'}'
        '${round.till == Tills.old && table != floor ? '  FLOOR NOT TIGHT' : ''}');
  }

  final fails = Fewests(Tills.decimal).whereBiggestFails(500);
  print('');
  print('the new till, every amount to 500: biggest-first fails on '
      '${fails.isEmpty ? 'none, which is the point of it' : '$fails'}');
}
