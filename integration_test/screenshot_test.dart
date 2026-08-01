import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wirewend/game/grid.dart';
import 'package:wirewend/game/progress.dart';
import 'package:wirewend/main.dart';
import 'package:wirewend/ui/board_view.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs on `flutter test`, which only looks in test/.
//
// A screenshot is worth keeping only if it shows the game being played, so
// every shot is reached the way a player reaches it: in through the menu and
// then tile by tile. Levels are built from their number, so the board in a
// picture is the same board on every run, and a picture that changes means
// the game changed.
//
// Run with:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshot_test.dart -d DEVICE
// `flutter test integration_test` runs the same drive but throws the images
// away, because only the driver side of the run has a disk to write to.
late final IntegrationTestWidgetsFlutterBinding binding;

Board boardOnScreen(WidgetTester tester) =>
    tester.widget<BoardView>(find.byType(BoardView)).board;

/// Opens the game at [level] and taps through to the board.
///
/// What was saved is replaced rather than read, so a shot does not depend on
/// what an earlier run left behind on the device.
Future<void> openLevel(WidgetTester tester, int level) async {
  SharedPreferences.setMockInitialValues(<String, Object>{'reached': level});
  await tester.pumpWidget(Wirewend(progress: await Progress.open()));
  await tester.pumpAndSettle();
  // The menu offers exactly one level, so there is only one button to press.
  await tester.tap(find.byType(FilledButton));
  await tester.pumpAndSettle();
}

/// Turns the first [cells] of the board back to the shape the generator gave
/// them, which is an answer by construction: [Cell.turns] counts how far the
/// scramble moved a cell, so turning it the rest of the way round undoes it.
///
/// The turns go through the tiles, so this is a player's route to the answer
/// and not a back door into the model. Restoring every cell finishes a level;
/// restoring some of them leaves a board half lit.
Future<void> turnBack(WidgetTester tester, int cells) async {
  final start = boardOnScreen(tester);
  for (var index = 0; index < cells; index++) {
    final row = index ~/ start.cols;
    final col = index % start.cols;
    for (var left = (4 - start.at(row, col).turns % 4) % 4; left > 0; left--) {
      // A finished board is a picture rather than a puzzle and stops taking
      // taps, so there is nothing further to ask of it.
      if (boardOnScreen(tester).isSolved) return;
      await tester.tap(find.byKey(ValueKey<int>(index)));
      await tester.pump();
    }
  }
}

/// Waits for the screen to stop moving and takes the picture.
///
/// Android hands back an empty image unless the Flutter surface is turned
/// into an image view first. That call is a no-op on iOS, and it undoes
/// itself when the test ends, so it belongs to one shot and cannot be made
/// twice in the same test.
Future<void> shoot(WidgetTester tester, String name) async {
  await binding.convertFlutterSurfaceToImage();
  // Settling here also clears the ring the test binding draws where it
  // tapped, which fades over the next couple of frames.
  await tester.pumpAndSettle();
  await binding.takeScreenshot(name);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opens on a menu that says what the game is', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(Wirewend(progress: await Progress.open()));
    await tester.pumpAndSettle();

    expect(find.text('Wirewend'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    await shoot(tester, '01-menu');
  });

  testWidgets('plays a level far enough to light half of it', (tester) async {
    // Level 8 is seven rows by six, with twelve lamps: big enough to look
    // like a puzzle and small enough that every tile is still a thumb wide.
    await openLevel(tester, 8);
    await turnBack(tester, 26);
    await tester.pumpAndSettle();

    final board = boardOnScreen(tester);
    expect(board.litLampCount, greaterThan(0));
    expect(
      board.litLampCount,
      lessThan(board.lampCount),
      reason: 'a picture of a level being played needs a lamp left to light',
    );

    await shoot(tester, '02-playing');
  });

  testWidgets('lights the last lamp on a level', (tester) async {
    await openLevel(tester, 7);
    await turnBack(tester, 36);
    await tester.pumpAndSettle();

    expect(boardOnScreen(tester).isSolved, isTrue);
    expect(find.text('Level 7 solved'), findsOneWidget);

    await shoot(tester, '03-solved');
  });
}
