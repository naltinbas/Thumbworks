// ignore_for_file: avoid_print
import 'package:carterfen/round/rounds_list.dart';
import 'package:carterfen/round/shortest.dart';

/// Walks every shipped round: the shortest there is, and what a carter who
/// always drives to the nearest place they have not called at yet manages.
///
/// Run with: dart run tool/check_rounds.dart
///
/// The second number is what makes a round worth setting. Where the two are
/// the same, driving to the nearest place every time is the answer and there
/// is nothing to work out.
void main() {
  for (var i = 0; i < Rounds.count; i++) {
    final one = Rounds.at(i);
    final moor = one.moor;
    final best = Rounder(moor).work();

    // Nearest place next, from the yard.
    final left = [for (var s = 1; s < moor.count; s++) s];
    final greedy = <int>[0];
    while (left.isNotEmpty) {
      var pick = 0;
      for (var j = 1; j < left.length; j++) {
        if (moor.between(greedy.last, left[j]) <
            moor.between(greedy.last, left[pick])) {
          pick = j;
        }
      }
      greedy.add(left.removeAt(pick));
    }

    print('${'${i + 1}'.padLeft(2)} ${one.name.padRight(18)}'
        '${moor.count} places  shortest ${best.length}'
        '${best.length == one.shortest ? '' : ' BUT IT SAYS ${one.shortest}'}  '
        'nearest-first ${moor.lengthOf(greedy)}  '
        '(${(100 * (moor.lengthOf(greedy) - best.length) / best.length).round()}% over)  '
        '${best.looked} part-rounds  ${best.order.join(' ')}');
  }
}
