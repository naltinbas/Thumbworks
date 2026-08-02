import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:chalkway/sim/levels.dart';
import 'package:chalkway/sim/shapes.dart';
import 'package:chalkway/sim/world.dart';
import 'package:chalkway/ui/app.dart';
import 'package:chalkway/ui/board_screen.dart';
import 'package:chalkway/ui/slate_painter.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in
// test/.
//
// This one does something the others cannot: it draws with a real finger. The
// strokes below are delivered as device pointer events, so they go in through
// the same door a thumb does — down the platform's touch handling, into the
// engine, out of the Listener the board is wrapped in. A widget test drives
// that from the framework side and would not notice if the platform side were
// wired up wrong.
late final IntegrationTestWidgetsFlutterBinding binding;

/// Whether the Flutter surface has already been turned into an image view.
///
/// Android hands back a black rectangle for a screenshot until it has been,
/// and the call asserts if it is made twice — once per run, not once per test.
var _surfaceConverted = false;

Future<void> _asDevice(PointerEvent event) => TestAsyncUtils.guard<void>(
      () async => binding.handlePointerEventForSource(
        event,
        source: TestBindingEventSource.device,
      ),
    );

BoardScreenState _state(WidgetTester tester) =>
    tester.state<BoardScreenState>(find.byType(BoardScreen));

Finder _slate() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is SlatePainter,
    );

Metrics _metrics(WidgetTester tester) =>
    (tester.widget<CustomPaint>(_slate().first).painter! as SlatePainter)
        .metrics;

Offset _onScreen(WidgetTester tester, Spot spot) =>
    tester.getTopLeft(_slate().first) + _metrics(tester).toScreen(spot);

/// Puts a finger down on the board and drags it, without lifting it.
Future<TestGesture> _drawWith(
  WidgetTester tester,
  Spot from,
  Spot to, {
  int steps = 10,
  int of = 10,
}) async {
  final gesture = TestGesture(dispatcher: _asDevice);
  await gesture.down(_onScreen(tester, from));
  await tester.pump();
  for (var i = 1; i <= steps; i++) {
    await gesture.moveTo(_onScreen(tester, from + (to - from) * (i / of)));
    await tester.pump();
  }
  return gesture;
}

Future<void> _open(WidgetTester tester, {int? level}) async {
  await tester.pumpWidget(ChalkwayApp(opensAt: level));
  await tester.pump();

  if (!_surfaceConverted) {
    await binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }
}

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pump();
  await binding.takeScreenshot(name);
}

/// Lets the ball run on for so many seconds of world time, or to the end.
Future<void> _runFor(WidgetTester tester, double seconds) async {
  for (var i = 0; i < 3000; i++) {
    final world = _state(tester).world;
    if (world == null || world.isOver || world.seconds >= seconds) return;
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => binding.shouldPropagateDevicePointerEvents = true);

  testWidgets('opens on the levels', (tester) async {
    await _open(tester);

    expect(find.text('Chalkway'), findsOneWidget);
    for (var i = 0; i < Levels.count; i++) {
      expect(find.text(Levels.at(i).name), findsOneWidget);
    }
    await _shoot(tester, '01-levels');
  });

  testWidgets('draws a line with a real finger', (tester) async {
    await _open(tester, level: 3);
    const answer = [Spot(4.10, 10.20), Spot(7.60, 9.90)];

    // Photographed with the finger still down, which is the only moment the
    // chalk is wet.
    final finger = await _drawWith(tester, answer.first, answer.last, steps: 7);
    await _shoot(tester, '02-drawing');

    await finger.up();
    await tester.pump();
    expect(_state(tester).drawing.strokes, hasLength(1),
        reason: 'the platform never delivered the stroke');
  });

  testWidgets('runs the ball into the ring', (tester) async {
    await _open(tester, level: 5);
    const answer = [Spot(3.93, 9.65), Spot(9.05, 9.20)];

    final finger = await _drawWith(tester, answer.first, answer.last);
    await finger.up();
    await tester.pump();

    await tester.tap(find.text('Let go'));
    await tester.pump();

    await _runFor(tester, 1.2);
    await _shoot(tester, '03-running');

    await _runFor(tester, 60);
    expect(_state(tester).world!.ending, Ending.home,
        reason: 'the line drawn by hand did not solve the level');
    await _shoot(tester, '04-in');
  });
}
