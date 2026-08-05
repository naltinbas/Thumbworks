import 'package:flutter_test/flutter_test.dart';
import 'package:rookvale/board/puzzles.dart';
import 'package:rookvale/board/solve.dart';
import 'package:rookvale/ui/board_screen.dart';
import 'package:rookvale/ui/title_screen.dart';

import '../support/board.dart';

void main() {
  group('getting in', () {
    testWidgets('the list shows every puzzle and its size', (tester) async {
      await open(tester);
      expect(find.byType(TitleScreen), findsOne);
      for (final puzzle in Puzzles.all) {
        expect(find.text(puzzle.name), findsOne);
      }
      expect(find.text('${Puzzles.count} puzzles'), findsOne);
    });

    testWidgets('and a puzzle opens when its row is tapped', (tester) async {
      await open(tester);
      await tester.tap(find.text('Two knights'));
      await tester.pump();

      expect(find.byType(BoardScreen), findsOne);
      expect(state(tester).puzzle.name, 'Two knights');
    });

    testWidgets('a puzzle starts on the board it ships with', (tester) async {
      await open(tester, which: 0);
      expect(state(tester).play.board.sameness,
          Puzzles.at(0).board.sameness);
      expect(state(tester).play.taken, 0);
      expect(find.text('0 / ${Puzzles.at(0).takes}'), findsOne);
    });
  });

  group('capturing', () {
    testWidgets('a piece is picked first, and says how it moves',
        (tester) async {
      await open(tester, which: 0);
      final first = Puzzles.at(0).board.moves.first;

      await tapSquare(tester, first.from);
      expect(state(tester).picked, first.from);
      expect(state(tester).targets, contains(first.to));
      expect(state(tester).saying, isNotNull);
    });

    testWidgets('and then it takes', (tester) async {
      await open(tester, which: 0);
      final first = waysThrough(Puzzles.at(0).board).first.first;

      await capture(tester, first.from, first.to);
      expect(state(tester).play.taken, 1);
      expect(state(tester).play.board.at(first.to), isNotNull);
      expect(state(tester).play.board.at(first.from), isNull);
    });

    testWidgets('tapping somewhere it cannot take just lets go',
        (tester) async {
      await open(tester, which: 0);
      final board = Puzzles.at(0).board;
      final from = board.moves.first.from;
      final empty = List.generate(board.squares, (at) => at)
          .firstWhere((at) => !board.holds(at));

      await tapSquare(tester, from);
      await tapSquare(tester, empty);
      expect(state(tester).picked, -1);
      expect(state(tester).play.taken, 0);
    });

    testWidgets('takes a capture back, and starts over', (tester) async {
      await open(tester, which: 0);
      final first = waysThrough(Puzzles.at(0).board).first.first;

      await capture(tester, first.from, first.to);
      await press(tester, 'Take back');
      expect(state(tester).play.taken, 0);
      expect(state(tester).helped, isTrue,
          reason: 'and it remembers that it was taken back');

      await capture(tester, first.from, first.to);
      await press(tester, 'Again');
      expect(state(tester).play.taken, 0);
    });
  });

  group('a wrong capture', () {
    testWidgets('is said at once, because there is only one way through',
        (tester) async {
      await open(tester, which: 0);
      final right = waysThrough(Puzzles.at(0).board).first.first;
      final wrong =
          Puzzles.at(0).board.moves.firstWhere((move) => move != right);

      await capture(tester, wrong.from, wrong.to);
      expect(state(tester).play.canStillBeDone, isFalse);
      expect(state(tester).saying, contains('no way through'));
    });

    testWidgets('and taking it back puts it right', (tester) async {
      await open(tester, which: 0);
      final right = waysThrough(Puzzles.at(0).board).first.first;
      final wrong =
          Puzzles.at(0).board.moves.firstWhere((move) => move != right);

      await capture(tester, wrong.from, wrong.to);
      await press(tester, 'Take back');
      expect(state(tester).play.canStillBeDone, isTrue);
      expect(state(tester).saying, isNull);
    });
  });

  group('being shown', () {
    testWidgets('picks the piece that takes next', (tester) async {
      await open(tester, which: 3);
      await press(tester, 'Show me');

      final next = state(tester).play.nextTake!;
      expect(state(tester).picked, next.from);
      expect(state(tester).saying, contains('takes'));
      expect(state(tester).helped, isTrue);
    });

    testWidgets('and solves every puzzle, one capture at a time',
        (tester) async {
      // The claim the game is sold on, made through the screen: there is a
      // way through every board, and following it leaves one piece standing.
      for (var which = 0; which < Puzzles.count; which++) {
        await open(tester, which: which);
        await solveIt(tester);

        expect(state(tester).play.isDone, isTrue,
            reason: '${Puzzles.at(which).name} was not finished');
        expect(state(tester).play.taken, Puzzles.at(which).takes);
        expect(find.text('One left'), findsOne);
      }
    });
  });

  group('finishing', () {
    testWidgets('the next one opens after it', (tester) async {
      await open(tester, which: 0);
      await solveIt(tester);

      await press(tester, 'The next one');
      expect(state(tester).puzzle.name, Puzzles.at(1).name);
      expect(state(tester).play.taken, 0);
    });

    testWidgets('and the last one leads back to the list', (tester) async {
      await open(tester, which: Puzzles.count - 1);
      await solveIt(tester);

      await press(tester, 'The next one');
      expect(find.byType(TitleScreen), findsOne);
    });
  });
}
