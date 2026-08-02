import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tallyloom/game/book.dart';
import 'package:tallyloom/game/grid.dart';
import 'package:tallyloom/game/line.dart';
import 'package:tallyloom/game/maker.dart';
import 'package:tallyloom/game/solver.dart';
import 'package:tallyloom/progress.dart';
import 'package:tallyloom/ui/app.dart';
import 'package:tallyloom/ui/board_painter.dart';
import 'package:tallyloom/ui/board_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in
// test/.
//
// A nonogram photographed at rest is a grid of numbers, which says nothing
// about what playing it is like. So the picture that matters is taken with the
// thumb still down, part way along a run, with the clues it has already
// satisfied gone grey behind it.
//
// Run with:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshot_test.dart -d DEVICE
late final IntegrationTestWidgetsFlutterBinding binding;

/// The puzzle the pictures are taken on.
///
/// A puzzle number is its own seed, so this is the grid every phone deals at
/// number 8 rather than one that only exists in a test. It is five across,
/// which is the size that photographs best: the squares are big enough to see
/// what a thumb is doing to them.
const _number = 8;

/// Times already on the phone, so the title has something to say.
const _saved = <String, Object>{'took.1': 41, 'took.2': 96, 'took.3': 74};

late final Puzzle _puzzle;

/// Everything the first sweep of line logic settles, which is where the
/// pictures are taken from. Every square in them follows from the clues.
late final Grid _firstPass;

/// Sends a pointer event the way the device would rather than the way a test
/// does.
///
/// The two arrive at the game identically. The difference is that the live
/// binding paints a bright crosshair over wherever a test-sourced pointer last
/// was, and here that is the middle of the board in the one picture this file
/// exists to take.
Future<void> _asDevice(PointerEvent event) => TestAsyncUtils.guard<void>(
      () async => binding.handlePointerEventForSource(
        event,
        source: TestBindingEventSource.device,
      ),
    );

Future<TestGesture> _thumbDown(WidgetTester tester, Offset at) async {
  final gesture = TestGesture(dispatcher: _asDevice);
  await gesture.down(at);
  await tester.pump();
  return gesture;
}

Future<void> _tap(WidgetTester tester, Finder target) async {
  expect(target, findsOneWidget);
  final gesture = await _thumbDown(tester, tester.getCenter(target));
  await gesture.up();
  await tester.pump();
}

/// The middle of a square, in the coordinates the screen uses.
Offset _squareAt(WidgetTester tester, int row, int col) {
  final painted = tester
      .widgetList<CustomPaint>(find.descendant(
        of: find.byType(BoardView),
        matching: find.byType(CustomPaint),
      ))
      .map((paint) => paint.painter)
      .whereType<BoardPainter>()
      .first;
  return tester.getTopLeft(find.byType(BoardView)) +
      painted.metrics.squareAt(row, col).center;
}

/// How long the thumb rests on each square on its way along a run.
///
/// A drag with no time in it is still a legal stroke, but the device sampler
/// takes a frame every couple of seconds and would never catch one. This is
/// about the speed a thumb crosses a board at.
const _perSquare = Duration(milliseconds: 90);

/// Opens the game straight onto the puzzle.
///
/// Everything else is the app as it ships; only the puzzle number is chosen,
/// because a picture of a board nobody can name is a picture nobody can check.
Future<void> _open(WidgetTester tester, {int? at}) async {
  SharedPreferences.setMockInitialValues(Map<String, Object>.from(_saved));
  final progress = Progress(await SharedPreferences.getInstance());
  await tester.pumpWidget(TallyloomApp(progress: progress, opensAt: at));
  await tester.pump();

  // Android hands back a black rectangle for a screenshot until the Flutter
  // surface is an image view. It is a no-op elsewhere, it may be done only
  // once in a test, and the binding puts it back afterwards.
  await binding.convertFlutterSurfaceToImage();
}

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pump();
  await binding.takeScreenshot(name);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Device pointers are dropped by a live test unless this is set. It goes
    // here rather than in a test body because the framework compares the flag
    // against what it was before each body and complains if a test moved it.
    binding.shouldPropagateDevicePointerEvents = true;

    _puzzle = Book.at(_number);
    _firstPass = solve(_puzzle.clues, limit: 1).grid;
  });

  testWidgets('opens on a title anyone can read in one look', (tester) async {
    await _open(tester);

    expect(find.text('Tallyloom'), findsOneWidget);
    expect(find.text('3 solved · the small ones'), findsOneWidget);

    await _shoot(tester, '01-title');
  });

  testWidgets('photographs a run being filled, with the thumb still on it',
      (tester) async {
    await _open(tester, at: _number);
    expect(find.byType(BoardView), findsOneWidget);
    expect(find.text('Puzzle $_number'), findsOneWidget);

    // The longest run the first sweep settles, which is the one worth being
    // photographed part way along.
    var best = (row: 0, from: 0, to: 0);
    for (var row = 0; row < _puzzle.height; row++) {
      var from = -1;
      for (var col = 0; col <= _puzzle.width; col++) {
        final on = col < _puzzle.width &&
            _firstPass.at(row, col) == Square.filled;
        if (on && from < 0) from = col;
        if (!on && from >= 0) {
          if (col - from > best.to - best.from + 1) {
            best = (row: row, from: from, to: col - 1);
          }
          from = -1;
        }
      }
    }
    expect(best.to, greaterThan(best.from),
        reason: 'the first sweep should settle a run worth dragging');

    // Down on the first square of the run and along it, stopping one short so
    // the picture has a thumb in the middle of doing something.
    final gesture =
        await _thumbDown(tester, _squareAt(tester, best.row, best.from));
    for (var col = best.from + 1; col < best.to; col++) {
      await gesture.moveTo(_squareAt(tester, best.row, col));
      await tester.pump(_perSquare);
    }
    await _shoot(tester, '02-filling');

    // Then the rest of it.
    await gesture.moveTo(_squareAt(tester, best.row, best.to));
    await tester.pump(_perSquare);
    await gesture.up();
    await tester.pump();

    // The rest of what the first sweep gives, filled and crossed, which is a
    // board that looks like somebody has been working on it.
    for (var row = 0; row < _puzzle.height; row++) {
      for (var col = 0; col < _puzzle.width; col++) {
        if (_firstPass.at(row, col) != Square.filled) continue;
        if (row == best.row && col >= best.from && col <= best.to) continue;
        final square = await _thumbDown(tester, _squareAt(tester, row, col));
        await square.up();
        await tester.pump();
      }
    }
    await _shoot(tester, '03-working');

    // And the picture out. The last squares are put down the same way as the
    // rest, because a screenshot of a finished board is worth having only if
    // the board was finished by playing it.
    for (var row = 0; row < _puzzle.height; row++) {
      for (var col = 0; col < _puzzle.width; col++) {
        if (!_puzzle.picture.at(row, col)) continue;
        if (_firstPass.at(row, col) == Square.filled) continue;
        final square = await _thumbDown(tester, _squareAt(tester, row, col));
        await square.up();
        await tester.pump();
      }
    }
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Solved'), findsOneWidget,
        reason: 'the picture should be out');
    await _shoot(tester, '04-solved');

    // And back out to the book, which is the whole loop closed on a real
    // device: the puzzle it just solved is written down, and the title is
    // offering the next one.
    await _tap(tester, find.text('Back to the book'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('4 solved · the small ones'), findsOneWidget,
        reason: 'the solve should have been written down');
    await _shoot(tester, '05-book');
  });
}
