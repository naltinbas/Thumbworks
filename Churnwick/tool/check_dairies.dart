// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:churnwick/churn/dairies.dart';
import 'package:churnwick/churn/fewest.dart';

/// Walks every shipped morning: the fewest goes found by walking the dairy,
/// the same number worked out without looking at anything, and what can be
/// measured in it at all.
void main() {
  for (var number = 0; number < Mornings.count; number++) {
    final morning = Mornings.at(number);
    final dairy = morning.dairy;
    final measure = Pouring.fewestFor(dairy);
    final tipping = Pouring.byTipping(dairy);
    final step = Pouring.stepOf(dairy.churns);
    final walked = Pouring.reachedByWalking(dairy.churns);
    final said = Pouring.whatCanStand(dairy).toSet();

    print('${(number + 1).toString().padLeft(2)} '
        '${dairy.name.padRight(21)} '
        'churns ${dairy.churns.join(' and ').padRight(12)} '
        'want ${dairy.want.toString().padLeft(2)}  '
        'fewest ${measure!.pours.toString().padLeft(2)}  '
        'written down ${morning.fewest.toString().padLeft(2)}  '
        'by tipping ${(tipping?.toString() ?? 'three churns').padLeft(2)}  '
        'step $step  '
        'can stand ${Pouring.whatCanStand(dairy)}  '
        '${measure.seen} arrangements looked at'
        '${measure.pours == morning.fewest ? '' : '  WRONG NUMBER WRITTEN DOWN'}'
        '${tipping == null || tipping == measure.pours ? '' : '  TIPPING DISAGREES'}'
        '${walked.difference(said).isEmpty && said.difference(walked).isEmpty ? '' : '  WHAT CAN STAND IS WRONG'}');
  }
}
