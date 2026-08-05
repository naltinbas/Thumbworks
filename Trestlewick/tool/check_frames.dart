// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:trestlewick/raise/fewest.dart';
import 'package:trestlewick/raise/frames.dart';

/// Walks every shipped frame: the fewest days, the two floors under it, and
/// what raising whatever is ready in the order it was written down would cost.
void main() {
  for (var number = 0; number < Frames.count; number++) {
    final frame = Frames.at(number);
    final raising = Raisings.forFrame(frame);
    final byOrder = Raisings.byOrder(frame);

    print('${(number + 1).toString().padLeft(2)} '
        '${frame.name.padRight(16)} '
        '${frame.count.toString().padLeft(2)} timbers  '
        '${frame.crews} crews  '
        'days ${raising.days}  '
        'written down ${frame.days}  '
        'longest run ${raising.chain.length}  '
        'by work ${raising.byWork}  '
        'in order $byOrder  '
        '${raising.chainIsTight ? 'the run' : ''}'
        '${raising.chainIsTight && raising.workIsTight ? ' and ' : ''}'
        '${raising.workIsTight ? 'the work' : ''}'
        '${raising.floorSaysSo ? ' says so' : ''}'
        '${frame.isSound ? '' : '  IT DOES NOT STAND UP'}'
        '${raising.floorSaysSo ? '' : '  NEITHER FLOOR PROVES IT'}'
        '${byOrder > raising.days || number == 0 ? '' : '  IN ORDER IS ENOUGH'}'
        '${raising.days == frame.days ? '' : '  WRONG NUMBER WRITTEN DOWN'}');
  }
}
