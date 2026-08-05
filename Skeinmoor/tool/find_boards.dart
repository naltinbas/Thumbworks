// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:skeinmoor/thread/field.dart';
import 'package:skeinmoor/thread/solve.dart';

/// Looks for boards with exactly one way of filling them, and prints them.
///
/// Run with: dart run tool/find_boards.dart [side] [threads] [how many]
///
/// It works backwards. Filling a board at random is easy — grow threads from
/// nothing until every cell is taken — and the ends of those threads are a
/// puzzle whose answer is known before it is asked. What is not known is
/// whether it is the only answer, so every board is then handed to the solver
/// and thrown away unless there is exactly one.
void main(List<String> args) {
  final side = args.isEmpty ? 5 : int.parse(args.first);
  final threads = args.length > 1 ? int.parse(args[1]) : 4;
  final wanted = args.length > 2 ? int.parse(args[2]) : 4;

  final dice = Random(side * 1000 + threads * 10 + wanted);
  var tried = 0;
  var found = 0;

  while (found < wanted && tried < 200000) {
    tried++;
    final owner = _grow(dice, side, threads);
    if (owner == null) continue;

    // The ends of each thread are the cells with only one neighbour of their
    // own colour — the two loose ends of a path.
    final ends = <(int, int)>[];
    var ok = true;
    for (var thread = 0; thread < threads; thread++) {
      final loose = <int>[];
      var long = 0;
      for (var at = 0; at < side * side; at++) {
        if (owner[at] != thread) continue;
        long++;
        var same = 0;
        for (final beside in _around(at, side)) {
          if (owner[beside] == thread) same++;
        }
        if (same <= 1) loose.add(at);
      }
      // Two loose ends and nothing shorter than a corner. A thread of three
      // cells joins itself the moment the board opens and is one less thing
      // to think about, which is the opposite of what a board is for.
      if (loose.length != 2 || long < 4) {
        ok = false;
        break;
      }
      ends.add((loose[0], loose[1]));
    }
    if (!ok) continue;

    final field = Field(across: side, down: side, ends: ends);
    final found2 = Threader(field).ways();
    if (!found2.isOnlyOne) continue;
    found++;

    print('--- one way, $threads threads, ${found2.looked} steps ---');
    for (var row = 0; row < side; row++) {
      final line = StringBuffer("        '");
      for (var column = 0; column < side; column++) {
        final at = row * side + column;
        final thread = field.endAt(at);
        line.write(thread < 0 ? '.' : String.fromCharCode(97 + thread));
      }
      print('$line',);
    }
  }

  print('');
  print('kept $found of $tried');
}

/// Grows threads from random starts until the board is full, or gives up.
List<int>? _grow(Random dice, int side, int threads) {
  final owner = List.filled(side * side, -1);
  final heads = <int>[];
  for (var thread = 0; thread < threads; thread++) {
    var at = dice.nextInt(side * side);
    var tries = 0;
    while (owner[at] >= 0 && tries++ < 50) {
      at = dice.nextInt(side * side);
    }
    if (owner[at] >= 0) return null;
    owner[at] = thread;
    heads.add(at);
  }

  var stuck = 0;
  while (owner.contains(-1) && stuck < threads * 4) {
    final thread = dice.nextInt(threads);
    final free = [
      for (final beside in _around(heads[thread], side))
        if (owner[beside] < 0) beside,
    ];
    if (free.isEmpty) {
      stuck++;
      continue;
    }
    stuck = 0;
    final next = free[dice.nextInt(free.length)];
    owner[next] = thread;
    heads[thread] = next;
  }
  return owner.contains(-1) ? null : owner;
}

List<int> _around(int at, int side) {
  final row = at ~/ side;
  final column = at % side;
  return [
    if (row > 0) at - side,
    if (row < side - 1) at + side,
    if (column > 0) at - 1,
    if (column < side - 1) at + 1,
  ];
}
