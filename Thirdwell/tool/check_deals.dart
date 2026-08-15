import 'dart:io';

import 'package:thirdwell/deal/rules.dart';
import 'package:thirdwell/deal/walks.dart';

/// Deals every run of placings for every counter, holds Gergonne's
/// arithmetic to the dealing, and refuses the bake on any
/// disagreement: this is what `make deals` runs, and the README
/// quotes its ledger verbatim.
void main() {
  for (final walk in Walks.all) {
    final ways = Rules(deals: walk.deals).waysBySweep(walk.chosen, walk.place);
    if (ways != walk.ways) {
      stderr.writeln('${walk.name}: sweep finds $ways, label says ${walk.ways}');
      exit(1);
    }
  }

  // Three deals: for every counter and every run of placings, the
  // dealing lands where the arithmetic says, and the 27 runs reach
  // the 27 places once each; the backward arithmetic gives the one
  // run for every place.
  final three = Rules();
  for (var chosen = 0; chosen < Rules.counters; chosen++) {
    final reached = <int>[];
    three.runs((placings) {
      final dealt = Rules.placeBySimulation(chosen, placings);
      if (dealt != Rules.placeByArithmetic(placings)) {
        stderr.writeln('COUNTER $chosen RUN $placings: DEALT $dealt, ARITHMETIC ${Rules.placeByArithmetic(placings)}');
        exit(1);
      }
      reached.add(dealt);
    });
    reached.sort();
    for (var place = 0; place < Rules.counters; place++) {
      if (reached[place] != place) {
        stderr.writeln('COUNTER $chosen DOES NOT REACH EVERY PLACE ONCE: $reached');
        exit(1);
      }
      if (Rules.placeBySimulation(chosen, Rules.placingsFor(place)) != place) {
        stderr.writeln('THE BACKWARD ARITHMETIC MISSES $place FOR $chosen');
        exit(1);
      }
    }
  }
  // The named runs.
  if ('${Rules.placingsFor(0)}' != '[0, 0, 0]' ||
      '${Rules.placingsFor(13)}' != '[1, 1, 1]' ||
      '${Rules.placingsFor(26)}' != '[2, 2, 2]' ||
      '${Rules.placingsFor(19)}' != '[1, 0, 2]') {
    stderr.writeln('THE NAMED RUNS MOVED');
    exit(1);
  }

  // Two deals: from counter 17's start, only the places one more
  // than a multiple of three, nine of them, and never the top; and
  // in general the units after two deals are the start's nines.
  final two = Rules(deals: 2);
  final reach = two.reachable(16);
  if ('$reach' != '[1, 4, 7, 10, 13, 16, 19, 22, 25]') {
    stderr.writeln('TWO DEALS FROM 16 REACH $reach');
    exit(1);
  }
  for (var chosen = 0; chosen < Rules.counters; chosen++) {
    for (final place in two.reachable(chosen)) {
      if (place % 3 != chosen ~/ 9) {
        stderr.writeln('TWO DEALS FROM $chosen REACH $place, UNITS ${place % 3} NOT ${chosen ~/ 9}');
        exit(1);
      }
    }
    if (two.reachable(chosen).length != 9) {
      stderr.writeln('TWO DEALS FROM $chosen REACH ${two.reachable(chosen).length} PLACES');
      exit(1);
    }
  }

  stdout.writeln(
      'every run of three placings dealt out for every one of the 27 '
      'counters, 729 runs, and every one lands where Gergonne\'s '
      'arithmetic says, the placings read as digits in threes with the '
      'first deal the units, so each of the 27 places is reached by '
      'exactly one run from any start; two deals reach nine places only, '
      'those whose units are the start counted in nines, and counter 17 '
      'never reaches the top in two');
  stdout.writeln('');

  for (var number = 0; number < Walks.count; number++) {
    final walk = Walks.at(number);
    final name = walk.name.padRight(15);
    stdout.writeln(walk.winnable
        ? ' ${number + 1} $name ${walk.task}: ${walk.ways} run of the 27 lands it'
        : ' ${number + 1} $name ${walk.task}: none of the 9, and the units said so first');
  }
}
