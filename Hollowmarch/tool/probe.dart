// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:hollowmarch/pegs/field.dart';
import 'package:hollowmarch/pegs/rule_of_three.dart';
import 'package:hollowmarch/pegs/solve.dart';

/// What the rule of three says about a board, and what the search finds.
void main() {
  final english = Field(const [
    '##...##',
    '##...##',
    '.......',
    '.......',
    '.......',
    '##...##',
    '##...##',
  ]);
  print('English cross: ${english.hollows} hollows, '
      '${english.jumps.length} jumps');

  // The central game: every hollow full but the middle one.
  final middle = english.at(3, 3);
  final start = english.full & ~(1 << middle);
  final rule = RuleOfThree(english);
  final could = rule.couldFinish(start);
  print('rule of three allows ${could.length} finishing hollows: '
      '${could.map((h) => '(${english.rowOf(h)},${english.columnOf(h)})').join(' ')}');

  for (final hollow in could) {
    final began = DateTime.now();
    final route = Solver(english, finishAt: hollow).from(start);
    final took = DateTime.now().difference(began).inMilliseconds;
    print('  finish at (${english.rowOf(hollow)},${english.columnOf(hollow)}): '
        '${route == null ? "no way" : "${route.moves} jumps"}  '
        '${route?.looked ?? 0} positions, ${took}ms');
  }
}
