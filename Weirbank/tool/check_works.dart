// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:weirbank/flow/most.dart';
import 'package:weirbank/flow/works_list.dart';

/// Walks every shipped works: the most that gets through, and the cut that
/// says nothing more can.
///
/// Run with: dart run tool/check_works.dart
void main() {
  for (var i = 0; i < Waterworks.count; i++) {
    final one = Waterworks.at(i);
    final works = one.works;
    final most = Flow(works).work();

    print('${'${i + 1}'.padLeft(2)} ${one.name.padRight(16)}'
        '${works.count} ponds  ${works.pipes.length} pipes  '
        'most ${most.amount}  '
        'cut of ${most.cut.length} holding ${most.holdsOfCut(works)}  '
        '${one.target == most.amount ? 'target agrees' : 'TARGET IS WRONG'}');
  }
}
