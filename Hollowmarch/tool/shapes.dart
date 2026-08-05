// A command line tool whose whole job is to print. It is not part of the game.
// ignore_for_file: avoid_print

import 'package:hollowmarch/pegs/field.dart';
import 'package:hollowmarch/pegs/runs.dart';
import 'package:hollowmarch/pegs/rule_of_three.dart';
import 'package:hollowmarch/pegs/solve.dart';

/// Tries board shapes: what the rule of three allows, whether they can be
/// finished, and in how few moves.
void main() {
  final shapes = <String, List<String>>{
    'stub': ['...', '.#.', '...'],
    'three by three': ['...', '...', '...'],
    'three by four': ['....', '....', '....'],
    'three by five': ['.....', '.....', '.....'],
    'tee': ['.....', '..#..', '..#..'],
    'ell': ['..##', '..##', '....', '....'],
    'steps': ['..##', '...#', '....', '....'],
    'square': ['....', '....', '....', '....'],
    'arrow': ['##.##', '#...#', '.....', '#...#', '#...#'],
    'small cross': ['#...#', '#...#', '.....', '#...#', '#...#'],
    'cross': ['##...##', '##...##', '.......', '##...##', '##...##'],
    'wide cross': ['#.....#', '.......', '.......', '#.....#'],
    'english': [
      '##...##',
      '##...##',
      '.......',
      '.......',
      '.......',
      '##...##',
      '##...##',
    ],
  };

  for (final shape in shapes.entries) {
    final field = Field(shape.value);
    print('--- ${shape.key}: ${field.hollows} hollows, '
        '${field.jumps.length} jumps ---');
    final rule = RuleOfThree(field);

    for (var empty = 0; empty < field.hollows; empty++) {
      final start = field.full & ~(1 << empty);
      final could = rule.couldFinish(start);
      if (could.isEmpty) continue;

      final began = DateTime.now();
      final fewest = field.hollows <= 21
          ? Runs.fewest(field, start, give: 3000000)
          : null;
      final took = DateTime.now().difference(began).inMilliseconds;

      final route = fewest == null ? Solver(field).from(start) : null;
      final where = '(${field.rowOf(empty)},${field.columnOf(empty)})';
      if (fewest != null) {
        print('  empty $where: ${fewest.$1} moves fewest, '
            'ends at ${_at(field, fewest.$2)}, '
            'rule allows ${could.length} hollows, ${took}ms');
      } else if (route != null) {
        print('  empty $where: ${Runs.movesIn(route.jumps)} moves found, '
            'ends at ${_at(field, route.jumps)}, '
            'rule allows ${could.length} hollows, '
            '${route.looked} positions');
      } else {
        print('  empty $where: cannot be finished');
      }
    }
  }
}

String _at(Field field, List<Jump> jumps) {
  final last = jumps.last.to;
  return '(${field.rowOf(last)},${field.columnOf(last)})';
}
