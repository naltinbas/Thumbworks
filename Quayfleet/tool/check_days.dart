// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:quayfleet/berth/most.dart';
import 'package:quayfleet/berth/quays.dart';

/// Walks every shipped day: the most ships the rule gives, the most a search
/// over every set of ships gives, and what the two obvious ways of working
/// through the book would have got.
void main() {
  for (var number = 0; number < Days.count; number++) {
    final day = Days.at(number);
    final quay = day.quay;
    final berthing = Berthings.most(quay);
    final trying = Berthings.byTrying(quay);
    final arriving = Berthings.byArriving(quay).length;
    final shortest = Berthings.byShortest(quay).length;

    // Every ship in the day has to want the berth at one of the hours.
    final missed = [
      for (var ship = 0; ship < quay.count; ship++)
        if (!berthing.marks.any(quay[ship].wantsIt)) quay[ship].name,
    ];

    print('${(number + 1).toString().padLeft(2)} '
        '${quay.name.padRight(18)} '
        '${quay.count} ships  '
        'most ${berthing.most}  '
        'written down ${day.most}  '
        'by trying every set $trying  '
        'alongside first $arriving  '
        'shortest first $shortest  '
        'hours ${berthing.marks}'
        '${berthing.most == trying ? '' : '  THE TWO DISAGREE'}'
        '${missed.isEmpty ? '' : '  THE HOURS MISS $missed'}'
        '${arriving < berthing.most || number < 2 ? '' : '  ALONGSIDE FIRST IS ENOUGH'}'
        '${shortest < berthing.most || number < 2 ? '' : '  SHORTEST FIRST IS ENOUGH'}'
        '${berthing.most == day.most ? '' : '  WRONG NUMBER WRITTEN DOWN'}');
  }
}
