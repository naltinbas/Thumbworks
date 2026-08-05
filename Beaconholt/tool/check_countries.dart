// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:beaconholt/watch/countries.dart';
import 'package:beaconholt/watch/fewest.dart';

/// Walks every shipped country: the fewest beacons there are, and what
/// lighting the hill that adds the most gets you.
///
/// Run with: dart run tool/check_countries.dart
void main() {
  for (var i = 0; i < Watchlands.count; i++) {
    final one = Watchlands.at(i);
    final country = one.country;
    final watch = Beacons.fewestFor(country);
    final greedy = Beacons.byGreed(country);

    print('${'${i + 1}'.padLeft(2)} ${one.name.padRight(18)}'
        '${one.count} hills  ${one.sightlines.length} sightlines  '
        'fewest ${watch.fewest}'
        '${watch.fewest == one.fewest ? '' : ' BUT IT SAYS ${one.fewest}'}  '
        'greed gets ${greedy.length}'
        '${greedy.length > watch.fewest ? '' : ' (GREED IS ENOUGH)'}  '
        '${watch.tried} sets tried  at ${watch.where}');
  }
}
