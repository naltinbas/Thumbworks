// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:handfast/hire/fairs.dart';
import 'package:handfast/hire/most.dart';

/// Walks every shipped day: the most the walk gives, the most a search over
/// every way of handing the work out gives, and the set of jobs that says why
/// there is no more.
void main() {
  for (var number = 0; number < Days.count; number++) {
    final day = Days.at(number);
    final fair = day.fair;
    final hiring = Hirings.most(fair);
    final trying = Hirings.byTrying(fair);
    final shortByTrying = Hirings.shortfallByTrying(fair);
    final down = Hirings.byWorkingDown(fair).where((hand) => hand >= 0).length;

    print('${(number + 1).toString().padLeft(2)} '
        '${fair.name.padRight(18)} '
        '${fair.jobs} jobs  '
        '${fair.people} hands  '
        '${fair.marks} crosses  '
        'most ${hiring.most}  '
        'written down ${day.most}  '
        'by trying every way $trying  '
        'working down $down  '
        'undone ${hiring.undone}  '
        'shortfall by trying $shortByTrying  '
        '${hiring.short.length} jobs with ${hiring.onlyThese.length} hands'
        '${hiring.most == trying ? '' : '  THE TWO DISAGREE'}'
        '${hiring.undone == shortByTrying ? '' : '  THE SHORTFALL DISAGREES'}'
        '${hiring.shortSaysSo ? '' : '  THE SET DOES NOT PROVE IT'}'
        '${down < hiring.most || number < 1 ? '' : '  WORKING DOWN IS ENOUGH'}'
        '${hiring.most == day.most ? '' : '  WRONG NUMBER WRITTEN DOWN'}');
  }
}
