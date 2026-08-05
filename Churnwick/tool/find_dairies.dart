// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:churnwick/churn/dairy.dart';
import 'package:churnwick/churn/fewest.dart';

/// Walks through dairies and prints the ones with a long answer, which are
/// the ones worth playing. A dairy anybody stumbles into in three goes is not
/// a puzzle.
///
///   dart run tool/find_dairies.dart [churns] [biggest] [fewest to be worth it]
void main(List<String> args) {
  final many = args.isNotEmpty ? int.parse(args[0]) : 2;
  final biggest = args.length > 1 ? int.parse(args[1]) : 13;
  final worth = args.length > 2 ? int.parse(args[2]) : 8;

  final sizes = <List<int>>[];
  void grow(List<int> so, int from) {
    if (so.length == many) {
      sizes.add(List.of(so));
      return;
    }
    for (var size = from; size <= biggest; size++) {
      grow([...so, size], size + 1);
    }
  }

  grow(const [], 2);

  for (final churns in sizes) {
    final step = Pouring.stepOf(churns);
    for (final want in Pouring.whatCanStand(
      Dairy(name: 'try', churns: churns, want: 1),
    )) {
      final dairy = Dairy(name: 'try', churns: churns, want: want);
      final measure = Pouring.fewestFor(dairy);
      if (measure == null || measure.pours < worth) continue;
      print('${churns.join(' and ')}  want $want  '
          'fewest ${measure.pours}  '
          'step $step  '
          'can stand ${Pouring.whatCanStand(dairy)}  '
          '${measure.seen} arrangements looked at');
    }
  }
}
