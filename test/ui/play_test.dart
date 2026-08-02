import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallyloom/game/book.dart';
import 'package:tallyloom/game/grid.dart';
import 'package:tallyloom/game/line.dart';
import 'package:tallyloom/ui/away_cover.dart';
import 'package:tallyloom/ui/board_view.dart';
import 'package:tallyloom/ui/done_card.dart';
import 'package:tallyloom/ui/title_screen.dart';

import '../support/playing.dart';

/// The grid the board is showing.
Grid boardGrid(WidgetTester tester) =>
    tester.widget<BoardView>(find.byType(BoardView)).grid;

void main() {
  group('the way in', () {
    testWidgets('opens on the title and starts at the first puzzle',
        (tester) async {
      await open(tester, await saved());

      expect(find.text('Tallyloom'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('nothing solved yet'), findsOneWidget);
      expect(find.byType(BoardView), findsNothing);

      await tester.tap(find.text('Start'));
      await tester.pump();

      expect(find.text('Puzzle 1'), findsOneWidget);
      expect(find.byType(BoardView), findsOneWidget);
    });

    testWidgets('offers the first puzzle not yet solved', (tester) async {
      await open(tester, await saved({'took.1': 40, 'took.2': 65}));

      expect(find.text('Puzzle 3'), findsOneWidget);
      expect(find.text('2 solved · the small ones'), findsOneWidget);
      expect(find.byType(TitleScreen), findsOneWidget);
    });
  });

  group('marking squares', () {
    testWidgets('a tap fills one square', (tester) async {
      await open(tester, await saved(), at: 1);

      await tapSquare(tester, 2, 3);
      expect(boardGrid(tester).at(2, 3), Square.filled);
      expect(boardGrid(tester).filledCount, 1);
    });

    testWidgets('a stroke fills every square it crosses', (tester) async {
      await open(tester, await saved(), at: 1);

      await stroke(tester, (row: 1, col: 0), (row: 1, col: 4));
      for (var col = 0; col <= 4; col++) {
        expect(boardGrid(tester).at(1, col), Square.filled, reason: 'column $col');
      }
      expect(boardGrid(tester).filledCount, 5);
    });

    testWidgets('a stroke that starts on a filled square rubs out',
        (tester) async {
      await open(tester, await saved(), at: 1);

      await stroke(tester, (row: 0, col: 0), (row: 0, col: 3));
      expect(boardGrid(tester).filledCount, 4);

      await stroke(tester, (row: 0, col: 0), (row: 0, col: 3));
      expect(boardGrid(tester).filledCount, 0,
          reason: 'drawing back over a run takes it away');
    });

    testWidgets('a stroke keeps to the line it started along', (tester) async {
      await open(tester, await saved(), at: 1);

      // A thumb that wanders a square down on its way across the row. The
      // stroke has to stay in the row it set off along, or it leaves a
      // staircase behind it.
      final gesture = await tester.startGesture(centreOf(tester, 2, 0));
      await tester.pump();
      await gesture.moveTo(centreOf(tester, 2, 1));
      await tester.pump();
      await gesture.moveTo(centreOf(tester, 3, 2));
      await tester.pump();
      await gesture.moveTo(centreOf(tester, 3, 3));
      await tester.pump();
      await gesture.up();
      await tester.pump();

      final grid = boardGrid(tester);
      expect(grid.row(2).where((s) => s == Square.filled), hasLength(4));
      expect(grid.row(3).where((s) => s == Square.filled), isEmpty);
    });

    testWidgets('the cross tool marks where the picture is not',
        (tester) async {
      await open(tester, await saved(), at: 1);

      await tester.tap(find.text('Cross'));
      await tester.pump();
      await stroke(tester, (row: 4, col: 0), (row: 4, col: 2));

      final grid = boardGrid(tester);
      expect(grid.at(4, 0), Square.blank);
      expect(grid.at(4, 2), Square.blank);
      expect(grid.filledCount, 0, reason: 'crosses are not part of the answer');
      expect(find.byType(DoneCard), findsNothing);
    });
  });

  group('undo', () {
    testWidgets('takes back a whole stroke, not a square', (tester) async {
      await open(tester, await saved(), at: 1);

      await stroke(tester, (row: 0, col: 0), (row: 0, col: 4));
      expect(boardGrid(tester).filledCount, 5);

      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pump();
      expect(boardGrid(tester).filledCount, 0);
    });

    testWidgets('is dead until there is something to take back', (tester) async {
      await open(tester, await saved(), at: 1);

      // Tapping it with nothing done must not throw and must not change
      // anything.
      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pump();
      expect(boardGrid(tester).filledCount, 0);
    });
  });

  group('finishing', () {
    testWidgets('drawing the picture ends the puzzle and writes the time down',
        (tester) async {
      final progress = await saved();
      await open(tester, progress, at: 1);

      await tester.pump(const Duration(seconds: 12));
      await drawThePicture(tester, Book.at(1));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(DoneCard), findsOneWidget);
      expect(find.text('Solved'), findsOneWidget);
      expect(progress.solved(1), isTrue);
      expect(progress.took(1)!.inSeconds, closeTo(12, 1));
    });

    testWidgets('crosses do not have to be cleared to finish', (tester) async {
      // The answer is the filled squares. A player who marks the empties as
      // they work should not then have to unmark them.
      final puzzle = Book.at(1);
      await open(tester, await saved(), at: 1);

      await tester.tap(find.text('Cross'));
      await tester.pump();
      for (var col = 0; col < puzzle.width; col++) {
        if (!puzzle.picture.at(0, col)) await tapSquare(tester, 0, col);
      }
      await tester.tap(find.text('Fill'));
      await tester.pump();

      await drawThePicture(tester, puzzle);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(DoneCard), findsOneWidget);
    });

    testWidgets('Next opens the puzzle after it', (tester) async {
      await open(tester, await saved(), at: 1);
      await drawThePicture(tester, Book.at(1));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Next puzzle'));
      await tester.pump();

      expect(find.text('Puzzle 2'), findsOneWidget);
      expect(find.byType(DoneCard), findsNothing);
      expect(boardGrid(tester).filledCount, 0, reason: 'a fresh grid');
    });

    testWidgets('a second go says whether it beat the first', (tester) async {
      final progress = await saved({'took.1': 30});
      await open(tester, progress, at: 1);

      await tester.pump(const Duration(seconds: 5));
      await drawThePicture(tester, Book.at(1));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('your best yet'), findsOneWidget);
      expect(progress.took(1)!.inSeconds, closeTo(5, 1));
    });
  });

  group('leaving the puzzle', () {
    testWidgets('stops the clock and covers the board', (tester) async {
      await open(tester, await saved(), at: 1);
      await tester.pump(const Duration(seconds: 20));
      expect(find.text('0:20'), findsOneWidget);

      await goAway(tester);
      await tester.pump(const Duration(minutes: 5));
      await comeBack(tester);
      await tester.pump();

      expect(find.byType(AwayCover), findsOneWidget);
      expect(find.text('0:20'), findsOneWidget,
          reason: 'the five minutes away are not the puzzle\'s to charge');

      await tester.tap(find.byType(AwayCover));
      await tester.pump();
      expect(find.byType(AwayCover), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      expect(find.text('0:23'), findsOneWidget);
    });
  });

  group('fitting a phone', () {
    for (final entry in const {
      'iphone-se': Size(320, 568),
      'iphone-14': Size(390, 844),
      'pixel-7': Size(412, 915),
    }.entries) {
      testWidgets('the biggest grid fits on ${entry.key}', (tester) async {
        // Puzzle 31 is the first ten across, which is as big as the book gets.
        await open(
          tester,
          await saved(),
          at: 31,
          screen: entry.value * 3,
        );

        final metrics = metricsOf(tester);
        final board = tester.getRect(find.byType(BoardView));

        expect(metrics.grid.width, lessThanOrEqualTo(board.width + 0.5));
        expect(metrics.grid.height, lessThanOrEqualTo(board.height + 0.5));
        expect(metrics.square, greaterThan(20),
            reason: 'a square a thumb can hit');

        // And it is playable: a stroke on the smallest phone still lands where
        // it was aimed.
        await stroke(tester, (row: 0, col: 0), (row: 0, col: 9));
        expect(boardGrid(tester).row(0).where((s) => s == Square.filled),
            hasLength(10));
      });
    }
  });
}
