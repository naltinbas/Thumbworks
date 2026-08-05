// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:packwold/fit/cover.dart';
import 'package:packwold/fit/pieces.dart';

/// Looks for boxes with exactly one way of being packed, and prints them.
///
/// Run with: dart run tool/find_boxes.dart [pieces] [wide] [deep] [wanted]
///
/// It works backwards, the way the rest of this collection does. Laying a few
/// pentominoes down at random is easy, and what they cover is a box that can
/// certainly be packed — by them, in at least the way they are lying. What is
/// not known is whether that is the only way, and almost never is: a box of
/// five pieces usually has half a dozen packings, and those go in the bin.
void main(List<String> args) {
  final howMany = args.isEmpty ? 5 : int.parse(args.first);
  final wide = args.length > 1 ? int.parse(args[1]) : 6;
  final deep = args.length > 2 ? int.parse(args[2]) : 6;
  final wanted = args.length > 3 ? int.parse(args[3]) : 4;

  final dice = Random(howMany * 1000 + wide * 100 + deep * 10 + wanted);
  var tried = 0;
  var kept = 0;

  while (kept < wanted && tried < 40000) {
    tried++;
    final laid = _scatter(dice, howMany, wide, deep);
    if (laid == null) continue;

    final box = _boxOf(laid, wide, deep);
    final letters = laid.map((one) => one.$1).toList()..sort();
    final found = Cover(box, letters: letters).solve();
    if (!found.isOnlyOne) continue;
    kept++;

    print('--- one packing, $howMany pieces, ${found.looked} steps ---');
    for (final row in box.rows) {
      print("        '$row',");
    }
    print('        letters: ${letters.map((l) => "'$l'").join(', ')}');
  }

  print('');
  print('kept $kept of $tried');
}

/// Lays pieces down at random, each touching what is there already so that
/// what they cover is one piece of ground rather than two.
List<(String, List<(int, int)>)>? _scatter(
  Random dice,
  int howMany,
  int wide,
  int deep,
) {
  final letters = [for (final piece in Piece.all) piece.letter]..shuffle(dice);
  final wanted = letters.take(howMany).toList();

  final taken = <(int, int)>{};
  final laid = <(String, List<(int, int)>)>[];

  for (final letter in wanted) {
    final could = <List<(int, int)>>[];
    for (final shape in Piece.of(letter).ways) {
      for (var row = 0; row + shape.deep <= deep; row++) {
        for (var column = 0; column + shape.wide <= wide; column++) {
          final where = [
            for (final (r, c) in shape.cells) (row + r, column + c),
          ];
          if (where.any(taken.contains)) continue;
          if (taken.isNotEmpty && !where.any((cell) => _touches(taken, cell))) {
            continue;
          }
          could.add(where);
        }
      }
    }
    if (could.isEmpty) return null;

    final where = could[dice.nextInt(could.length)];
    taken.addAll(where);
    laid.add((letter, where));
  }
  return laid;
}

bool _touches(Set<(int, int)> taken, (int, int) cell) =>
    taken.contains((cell.$1 - 1, cell.$2)) ||
    taken.contains((cell.$1 + 1, cell.$2)) ||
    taken.contains((cell.$1, cell.$2 - 1)) ||
    taken.contains((cell.$1, cell.$2 + 1));

/// The box those pieces cover, cropped to what they actually used.
Box _boxOf(List<(String, List<(int, int)>)> laid, int wide, int deep) {
  final taken = {for (final one in laid) ...one.$2};
  var leastRow = deep;
  var leastColumn = wide;
  var mostRow = 0;
  var mostColumn = 0;
  for (final (row, column) in taken) {
    if (row < leastRow) leastRow = row;
    if (column < leastColumn) leastColumn = column;
    if (row > mostRow) mostRow = row;
    if (column > mostColumn) mostColumn = column;
  }

  return Box([
    for (var row = leastRow; row <= mostRow; row++)
      [
        for (var column = leastColumn; column <= mostColumn; column++)
          taken.contains((row, column)) ? '.' : '#',
      ].join(),
  ]);
}
