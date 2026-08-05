// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:quayfleet/berth/most.dart';
import 'package:quayfleet/berth/quay.dart';

/// Makes days up and keeps the ones worth playing.
///
/// A day is worth keeping when both of the obvious ways of working through it
/// come out short: taking whoever comes alongside first, and taking the
/// shortest stay first. Then the day is about the rule the game is actually
/// built on rather than about being tidy.
///
///   dart run tool/find_days.dart [ships] [opens] [shuts] [how many] [most]
void main(List<String> args) {
  final many = args.isNotEmpty ? int.parse(args[0]) : 9;
  final opens = args.length > 1 ? int.parse(args[1]) : 6;
  final shuts = args.length > 2 ? int.parse(args[2]) : 20;
  final wanted = args.length > 3 ? int.parse(args[3]) : 4;
  final most = args.length > 4 ? int.parse(args[4]) : 0;

  final random = Random(20260806);
  var kept = 0;
  var tried = 0;

  while (kept < wanted && tried < 200000) {
    tried++;
    final ships = <Ship>[];
    for (var ship = 0; ship < many; ship++) {
      final from = opens + random.nextInt(shuts - opens - 1);
      final hours = 1 + random.nextInt(min(5, shuts - from));
      ships.add(Ship('S$ship', from, from + hours));
    }
    // Two ships wanting exactly the same stretch is a duller day.
    final stretches = ships.map((ship) => '${ship.from}-${ship.to}').toSet();
    if (stretches.length != many) continue;

    final quay = Quay(name: 'try', ships: ships, opens: opens, shuts: shuts);
    final berthing = Berthings.most(quay);
    if (most > 0 && berthing.most != most) continue;
    if (Berthings.byArriving(quay).length >= berthing.most) continue;
    if (Berthings.byShortest(quay).length >= berthing.most) continue;

    kept++;
    print('');
    print('$kept  $many ships  most ${berthing.most}  '
        'coming alongside first gets ${Berthings.byArriving(quay).length}  '
        'shortest stay first gets ${Berthings.byShortest(quay).length}  '
        'the hours are ${berthing.marks}');
    for (final ship in ships) {
      print('    Ship(NAME, ${ship.from}, ${ship.to}),');
    }
  }

  print('');
  print('$kept kept out of $tried tried');
}
