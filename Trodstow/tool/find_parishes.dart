// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:trodstow/link/cheapest.dart';
import 'package:trodstow/link/parish.dart';

/// Scatters hamlets about and keeps the parishes worth playing.
///
/// A parish is kept when no two paths cost the same, so there is exactly one
/// cheapest network and every reason the game gives is exactly true, and when
/// joining each hamlet to its own nearest neighbour comes out dearer than the
/// answer.
///
///   dart run tool/find_parishes.dart [places] [how many] [reach] [seed]
// How many were thrown away for each reason.
var _placed = 0, _paths = 0, _joined = 0, _nearest = 0;

void main(List<String> args) {
  final places = args.isNotEmpty ? int.parse(args[0]) : 8;
  final wanted = args.length > 1 ? int.parse(args[1]) : 2;
  final reach = args.length > 2 ? double.parse(args[2]) : 0.5;
  final seed = args.length > 3 ? int.parse(args[3]) : 20260808;

  final random = Random(seed);
  var kept = 0;
  var tried = 0;

  while (kept < wanted && tried < 40000) {
    tried++;

    final where = <(double, double)>[];
    for (var place = 0; place < places; place++) {
      var go = 0;
      while (go++ < 200) {
        final at = (
          0.10 + random.nextDouble() * 0.80,
          0.12 + random.nextDouble() * 0.76,
        );
        final near = where.any((other) =>
            (other.$1 - at.$1).abs() < 0.17 && (other.$2 - at.$2).abs() < 0.11);
        if (!near) {
          where.add(at);
          break;
        }
      }
    }
    if (where.length != places) {
      _placed++;
      continue;
    }

    final trods = <Trod>[];
    final costs = <int>{};
    for (var one = 0; one < places; one++) {
      for (var other = one + 1; other < places; other++) {
        final away = sqrt(pow(where[one].$1 - where[other].$1, 2) +
            pow(where[one].$2 - where[other].$2, 2));
        if (away > reach) continue;
        final yards = (away * 900).round() + random.nextInt(60);
        if (!costs.add(yards)) continue;
        trods.add(Trod(one, other, yards));
      }
    }
    if (trods.length < places || trods.length > places * 3) {
      _paths++;
      continue;
    }

    final parish = Parish(
      name: 'try',
      places: [
        for (var place = 0; place < places; place++)
          Place('P$place', where[place].$1, where[place].$2),
      ],
      trods: trods,
    );

    final cheapest = Cheapests.of(parish);
    if (cheapest.cut.length != places - 1) {
      _joined++;
      continue;
    }
    if (Cheapests.byShortestWay(parish).yards <= cheapest.yards) {
      _nearest++;
      continue;
    }

    kept++;
    print('');
    print('$kept  $places hamlets  ${trods.length} paths  '
        'cheapest ${cheapest.yards}  '
        'shortest way to one place ${Cheapests.byShortestWay(parish).yards}');
    for (var place = 0; place < places; place++) {
      print("    Place(NAME, ${where[place].$1.toStringAsFixed(2)}, "
          "${where[place].$2.toStringAsFixed(2)}),");
    }
    print('    ---');
    for (final trod in trods) {
      print('    Trod(${trod.from}, ${trod.to}, ${trod.yards}),');
    }
  }

  print('');
  print('$kept kept out of $tried tried; '
      '$_placed failed to place, $_paths failed on paths, '
      '$_joined were in pieces, $_nearest were solved by the shortest way');
}
