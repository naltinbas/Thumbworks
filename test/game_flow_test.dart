import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wirewend/game/grid.dart';
import 'package:wirewend/game/progress.dart';
import 'package:wirewend/main.dart';
import 'package:wirewend/ui/board_view.dart';
import 'package:wirewend/ui/game_screen.dart';

Board boardOnScreen(WidgetTester tester) =>
    tester.widget<BoardView>(find.byType(BoardView)).board;

Finder movesShowing(String count) => find.descendant(
      of: find.byType(MoveCounter),
      matching: find.text(count),
    );

/// Starts the app the way main does, from whatever is currently saved.
Future<void> launch(WidgetTester tester) async {
  await tester.pumpWidget(Wirewend(progress: await Progress.open()));
  await tester.pumpAndSettle();
}

Future<void> tapTile(WidgetTester tester, int index) async {
  await tester.tap(find.byKey(ValueKey<int>(index)));
  await tester.pump();
}

/// A cell that can be turned without finishing the level, so a test about
/// counting moves does not accidentally end the level it is counting.
int harmlessTurn(Board board) {
  for (var index = 0; index < board.rows * board.cols; index++) {
    final row = index ~/ board.cols;
    final col = index % board.cols;
    if (board.at(row, col).isEmpty) continue;
    if (!board.turn(row, col).isSolved) return index;
  }
  throw StateError('every turn on this board finishes it');
}

/// A cell that can be turned all four quarters without finishing the level,
/// so a test about turning is not cut short by the board stopping taking taps
/// part way through.
int harmlessAllTheWayRound(Board board) {
  for (var index = 0; index < board.rows * board.cols; index++) {
    final row = index ~/ board.cols;
    final col = index % board.cols;
    if (board.at(row, col).isEmpty) continue;
    var turned = board;
    var harmless = true;
    for (var quarter = 0; quarter < 4; quarter++) {
      turned = turned.turn(row, col);
      if (turned.isSolved) harmless = false;
    }
    if (harmless) return index;
  }
  throw StateError('every cell on this board finishes it inside a full turn');
}

/// Solves whatever level is on screen by turning every cell back to the shape
/// the generator gave it, which is a solution by construction. That is how a
/// widget test can reach the win screen without a solver.
Future<void> solveOnScreen(WidgetTester tester) async {
  final start = boardOnScreen(tester);
  for (var index = 0; index < start.rows * start.cols; index++) {
    final row = index ~/ start.cols;
    final col = index % start.cols;
    final remaining = (4 - start.at(row, col).turns % 4) % 4;
    for (var i = 0; i < remaining; i++) {
      // A partly restored board can already be lit, and once it is, the tiles
      // stop taking taps.
      if (boardOnScreen(tester).isSolved) break;
      await tapTile(tester, index);
    }
  }
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('offers the first level to a player who has played nothing',
      (tester) async {
    await launch(tester);

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Play level 1 again'), findsNothing);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Level 1'), findsOneWidget);
    expect(find.byType(BoardView), findsOneWidget);
    expect(movesShowing('0'), findsOneWidget);
  });

  testWidgets('counts a move for every tile the player turns', (tester) async {
    await launch(tester);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    await tapTile(tester, harmlessTurn(boardOnScreen(tester)));
    await tester.pumpAndSettle();
    expect(movesShowing('1'), findsOneWidget);

    await tapTile(tester, harmlessTurn(boardOnScreen(tester)));
    await tester.pumpAndSettle();
    expect(movesShowing('2'), findsOneWidget);
  });

  testWidgets('celebrates a solved level in the screen rather than a dialog',
      (tester) async {
    await launch(tester);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    await solveOnScreen(tester);

    expect(boardOnScreen(tester).isSolved, isTrue);
    expect(find.text('Level 1 solved'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(BoardView), findsOneWidget,
        reason: 'the lit board is the reward, so it stays in view');
  });

  testWidgets('starts the next level fresh when the player moves on',
      (tester) async {
    await launch(tester);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await solveOnScreen(tester);

    await tester.tap(find.text('Next level'));
    await tester.pumpAndSettle();

    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('Level 1 solved'), findsNothing);
    expect(movesShowing('0'), findsOneWidget);
    expect(boardOnScreen(tester).isSolved, isFalse);
  });

  testWidgets('puts the same board back when the player restarts',
      (tester) async {
    await launch(tester);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    final start = boardOnScreen(tester);

    final index = harmlessTurn(start);
    await tapTile(tester, index);
    await tapTile(tester, index);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restart'));
    await tester.pumpAndSettle();

    // The level number rebuilds its own board, so a restart is the same
    // puzzle rather than a new one: same shapes, and each cell turned as far
    // from its solved shape as it was to begin with.
    final again = boardOnScreen(tester);
    expect(movesShowing('0'), findsOneWidget);
    for (var row = 0; row < start.rows; row++) {
      for (var col = 0; col < start.cols; col++) {
        expect(again.at(row, col).ends, start.at(row, col).ends,
            reason: 'cell $row,$col');
        expect(again.at(row, col).turns, start.at(row, col).turns,
            reason: 'cell $row,$col');
      }
    }
  });

  testWidgets('opens on the level the last session reached', (tester) async {
    await launch(tester);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await solveOnScreen(tester);
    await tester.tap(find.text('Next level'));
    await tester.pumpAndSettle();

    // A relaunch is a new tree. The old one has to go first, or the app put
    // up in its place keeps the navigator it already had and stays on the
    // level instead of showing the menu.
    await tester.pumpWidget(const SizedBox.shrink());
    await launch(tester);

    expect(find.text('Continue level 2'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
    expect(find.text('Play level 1 again'), findsOneWidget);
  });

  testWidgets('says nothing about winning until the last lamp is lit',
      (tester) async {
    await launch(tester);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    final start = boardOnScreen(tester);
    for (var index = 0; index < start.rows * start.cols; index++) {
      final row = index ~/ start.cols;
      final col = index % start.cols;
      for (var left = (4 - start.at(row, col).turns % 4) % 4; left > 0; left--) {
        final board = boardOnScreen(tester);
        if (board.isSolved) break;
        // Checked before every single turn rather than at the end, so a
        // banner that came up one lamp early would be caught on the move it
        // came up rather than after the level was over.
        expect(find.textContaining('solved'), findsNothing,
            reason: 'the win showed with ${board.litLampCount} of '
                '${board.lampCount} lamps lit');
        await tapTile(tester, index);
      }
    }
    await tester.pumpAndSettle();

    final done = boardOnScreen(tester);
    expect(done.litLampCount, done.lampCount);
    expect(find.text('Level 1 solved'), findsOneWidget);
  });

  testWidgets('counts every tap that lands while a turn is still animating',
      (tester) async {
    await launch(tester);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    final start = boardOnScreen(tester);
    final index = harmlessAllTheWayRound(start);
    final row = index ~/ start.cols;
    final col = index % start.cols;

    for (var tap = 0; tap < 4; tap++) {
      await tester.tap(find.byKey(ValueKey<int>(index)));
      // Well short of the 220ms a turn takes, so every tap but the first
      // lands on a tile that is still spinning.
      await tester.pump(const Duration(milliseconds: 40));
    }
    await tester.pumpAndSettle();

    expect(boardOnScreen(tester).at(row, col).turns - start.at(row, col).turns,
        4,
        reason: 'four taps are four quarter turns, not three and not five');
    expect(boardOnScreen(tester).at(row, col).ends, start.at(row, col).ends,
        reason: 'four quarters is all the way round');
    expect(movesShowing('4'), findsOneWidget);
  });

  testWidgets('starts at the first level when the saved level is nonsense',
      (tester) async {
    // Whatever wrote this, it was not this app. Reading it as absent keeps a
    // player out of a crash on launch, which is the only screen they have.
    SharedPreferences.setMockInitialValues({'reached': 'not a level'});
    await launch(tester);

    expect(find.text('Start'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Level 1'), findsOneWidget);
  });

  testWidgets('starts at the first level when the saved level is below one',
      (tester) async {
    SharedPreferences.setMockInitialValues({'reached': 0});
    await launch(tester);

    // Not 'Continue level 0', which names a level that does not exist and
    // then opens level one anyway.
    expect(find.text('Start'), findsOneWidget);
    expect(find.textContaining('level 0'), findsNothing);
  });

  testWidgets('keeps tiles big enough for a thumb on a late level',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'reached': 30});

    await launch(tester);
    await tester.tap(find.text('Continue level 30'));
    await tester.pumpAndSettle();

    final board = boardOnScreen(tester);
    final tile = tester.getSize(find.byKey(const ValueKey<int>(0)));
    expect(tile.width, greaterThanOrEqualTo(44),
        reason: 'a ${board.rows} by ${board.cols} board still has to be '
            'tappable under the header and the footer');
    expect(find.byType(Scrollable), findsNothing);
  });
}
