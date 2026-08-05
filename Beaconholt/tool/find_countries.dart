// ignore_for_file: avoid_print
import 'dart:math';
import 'package:beaconholt/watch/fewest.dart';
import 'package:beaconholt/watch/hills.dart';

/// Scatters hills, joins the ones near each other, and keeps the countries
/// where lighting the hill that adds the most is not the answer.
void main(List<String> args) {
  final hills = args.isEmpty ? 10 : int.parse(args.first);
  final wanted = args.length > 1 ? int.parse(args[1]) : 2;
  final dice = Random(hills * 100 + wanted);
  var kept = 0;
  var tried = 0;

  while (kept < wanted && tried < 4000) {
    tried++;
    final places = <(double, double)>[];
    for (var i = 0; i < hills; i++) {
      places.add((0.08 + dice.nextDouble() * 0.84, 0.08 + dice.nextDouble() * 0.84));
    }
    // Nobody too close to anybody, so the map is readable.
    var tooClose = false;
    for (var i = 0; i < hills && !tooClose; i++) {
      for (var j = i + 1; j < hills; j++) {
        final dx = places[i].$1 - places[j].$1;
        final dy = places[i].$2 - places[j].$2;
        if (dx * dx + dy * dy < 0.02) tooClose = true;
      }
    }
    if (tooClose) continue;

    final reach = args.length > 2 ? double.parse(args[2]) : 0.36;
    final lines = <(int, int)>[];
    for (var i = 0; i < hills; i++) {
      for (var j = i + 1; j < hills; j++) {
        final dx = places[i].$1 - places[j].$1;
        final dy = places[i].$2 - places[j].$2;
        if (sqrt(dx * dx + dy * dy) <= reach) lines.add((i, j));
      }
    }
    final country = Country(
      hills: [for (var i = 0; i < hills; i++) Hill('$i', places[i].$1, places[i].$2)],
      sightlines: lines,
    );
    // Every hill has to see somebody, or it is a beacon by itself and dull.
    var lonely = false;
    for (var i = 0; i < hills; i++) {
      if (country.lights(i) == (1 << i)) lonely = true;
    }
    if (lonely) continue;

    final watch = Beacons.fewestFor(country);
    final greedy = Beacons.byGreed(country);
    if (greedy.length <= watch.fewest) continue;
    if (watch.fewest < (args.length > 3 ? int.parse(args[3]) : 3)) continue;
    kept++;

    print('--- $hills hills, ${lines.length} sightlines, fewest '
        '${watch.fewest}, greed gets ${greedy.length} ---');
    for (var i = 0; i < hills; i++) {
      print('        Hill(\'h$i\', ${places[i].$1.toStringAsFixed(2)}, '
          '${places[i].$2.toStringAsFixed(2)}),');
    }
    print('      sightlines: [${lines.map((l) => '(${l.$1}, ${l.$2})').join(', ')}],');
    print('      fewest: ${watch.fewest},');
  }
  print('kept $kept of $tried');
}
