// This is a command line tool whose whole job is to print a table.
// ignore_for_file: avoid_print

import 'package:tallyloom/game/book.dart';

/// Prints what the book actually deals, which is the only way to see whether
/// the difficulty curve is a curve.
///
/// Run with: dart run tool/book_report.dart [how many]
///
/// The numbers that matter are `passes`, which is how many times the solver
/// had to come back round the lines and so roughly how hard the puzzle is,
/// and `rejected`, which is how many pictures the maker threw away to find
/// one that was solvable and hard enough. A chapter whose rejected count is
/// climbing into the hundreds is a chapter asking for more than its size can
/// comfortably give.
void main(List<String> args) {
  final upTo = args.isEmpty ? 100 : int.parse(args.first);
  final watch = Stopwatch()..start();

  print('  no  size  passes  rejected  filled  chapter');
  var chapter = '';
  for (var number = 1; number <= upTo; number++) {
    final puzzle = Book.at(number);
    final now = Book.chapterOf(number).title;
    final show = now == chapter ? '' : now;
    chapter = now;
    print('${number.toString().padLeft(4)}'
        '${'${puzzle.width}x${puzzle.height}'.padLeft(6)}'
        '${puzzle.passes.toString().padLeft(8)}'
        '${puzzle.tries.toString().padLeft(10)}'
        '${'${puzzle.picture.filledCount}/${puzzle.picture.area}'.padLeft(9)}'
        '  $show');
  }

  watch.stop();
  print('\n$upTo puzzles in ${watch.elapsedMilliseconds}ms');
}
