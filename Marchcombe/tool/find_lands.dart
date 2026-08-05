// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:marchcombe/dye/fewest.dart';
import 'package:marchcombe/dye/land.dart';

/// Scatters fields across a grid and keeps the maps worth playing.
///
/// A map is worth keeping when two things are true of it. The fewest dyes has
/// to be the size of the biggest set of fields that all share a hedge with
/// each other, so the map carries a proof a player can see. And painting the
/// fields in the order they come, each in the first dye that will do, has to
/// need more dyes than the answer, so the obvious way is not the answer.
///
///   dart run tool/find_lands.dart [wide] [tall] [fields] [how many] [dyes]
void main(List<String> args) {
  final wide = args.isNotEmpty ? int.parse(args[0]) : 7;
  final tall = args.length > 1 ? int.parse(args[1]) : 7;
  final many = args.length > 2 ? int.parse(args[2]) : 8;
  final wanted = args.length > 3 ? int.parse(args[3]) : 4;
  final dyes = args.length > 4 ? int.parse(args[4]) : 0;

  final random = Random(20260805);
  var kept = 0;
  var tried = 0;

  while (kept < wanted && tried < 40000) {
    tried++;
    final rows = _scatter(random, wide, tall, many);
    if (rows == null) continue;

    final land = Land(name: 'try $tried', rows: rows);
    if (land.count != many) continue;

    final painting = Dyes.fewestFor(land);
    if (!painting.ringSaysSo) continue;
    if (painting.fewest < 3) continue;
    if (dyes > 0 && painting.fewest != dyes) continue;

    final byOrder = Dyes.byOrder(land).reduce(max) + 1;
    if (byOrder <= painting.fewest) continue;

    kept++;
    print('');
    print('$kept  ${land.count} fields  ${land.hedges.length} hedges  '
        'fewest ${painting.fewest}  the ring says ${painting.ring}  '
        'painting them in order takes $byOrder');
    for (final row in rows) {
      print("  '$row',");
    }
  }

  print('');
  print('$kept kept out of $tried tried');
}

/// A grid split into contiguous fields: seeds scattered about, then grown a
/// square at a time until there is nothing left over.
List<String>? _scatter(Random random, int wide, int tall, int many) {
  final grid = List.generate(tall, (_) => List.filled(wide, -1));
  final frontier = List.generate(many, (_) => <(int, int)>[]);

  final seeds = <(int, int)>{};
  while (seeds.length < many) {
    seeds.add((random.nextInt(wide), random.nextInt(tall)));
  }
  var field = 0;
  for (final (column, row) in seeds) {
    grid[row][column] = field;
    frontier[field].add((column, row));
    field++;
  }

  var left = wide * tall - many;
  while (left > 0) {
    var grew = false;
    for (var one = 0; one < many && left > 0; one++) {
      if (frontier[one].isEmpty) continue;
      final take = random.nextInt(frontier[one].length);
      final (column, row) = frontier[one][take];

      final open = <(int, int)>[];
      for (final (across, down) in const [(1, 0), (-1, 0), (0, 1), (0, -1)]) {
        final there = (column + across, row + down);
        if (there.$1 < 0 || there.$2 < 0) continue;
        if (there.$1 >= wide || there.$2 >= tall) continue;
        if (grid[there.$2][there.$1] < 0) open.add(there);
      }
      if (open.isEmpty) {
        frontier[one].removeAt(take);
        continue;
      }

      final (nextColumn, nextRow) = open[random.nextInt(open.length)];
      grid[nextRow][nextColumn] = one;
      frontier[one].add((nextColumn, nextRow));
      left--;
      grew = true;
    }
    if (!grew) return null;
  }

  const letters = 'ABCDEFGHIJKLMNOP';
  return [
    for (final row in grid) row.map((field) => letters[field]).join(),
  ];
}
