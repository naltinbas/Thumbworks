// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:hollowmarch/pegs/boards.dart';
import 'package:hollowmarch/pegs/rule_of_three.dart';
import 'package:hollowmarch/pegs/solve.dart';

/// The old result about the 33 hollow board, both halves of it.
///
/// Run with: dart run tool/prove.dart  (or `make prove`)
///
/// The rule of three says the last peg can only be in one of five hollows.
/// The search says every one of those five can really be reached. Neither
/// half is worth much alone: the rule allows hollows that cannot be reached
/// on other boards, and a search that finds five says nothing about the
/// twenty eight it did not try.
void main() {
  final board = Boards.at(Boards.count - 1);
  final field = board.field;
  print('${board.name}: ${field.hollows} hollows, '
      '${field.jumps.length} jumps, empty at ${board.empty}');

  final allowed = RuleOfThree(field).couldFinish(board.start);
  print('');
  print('the rule of three allows ${allowed.length} of ${field.hollows} '
      'hollows:');
  for (final hollow in allowed) {
    print('  (${field.rowOf(hollow)},${field.columnOf(hollow)})');
  }

  print('');
  print('and the search reaches:');
  for (final hollow in allowed) {
    final began = DateTime.now();
    final route = Solver(field, finishAt: hollow).from(board.start);
    final took = DateTime.now().difference(began).inMilliseconds;
    final where = '(${field.rowOf(hollow)},${field.columnOf(hollow)})';
    print('  $where: '
        '${route == null ? "no way at all" : "${route.jumps.length} jumps"}'
        '  ${route?.looked ?? 0} positions, ${took}ms');
  }
}
