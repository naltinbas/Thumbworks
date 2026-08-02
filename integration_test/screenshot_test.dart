import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:emberlane/sim/field.dart';
import 'package:emberlane/sim/kinds.dart';
import 'package:emberlane/sim/plan.dart';
import 'package:emberlane/sim/run.dart';
import 'package:emberlane/ui/app.dart';
import 'package:emberlane/ui/field_painter.dart';
import 'package:emberlane/ui/run_screen.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in
// test/.
//
// A defence game photographed between waves is an empty field. So the pictures
// that matter are taken with a wave part way down the lane and towers firing
// at it, which means the run has to be somewhere in the middle before the
// shutter goes.
//
// Run with:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshot_test.dart -d DEVICE
late final IntegrationTestWidgetsFlutterBinding binding;

/// A run in the thick of it, played out here rather than posed: the careful
/// plan, stopped part way through a wave with towers up and things walking.
late final Run _midRun;

Future<void> _asDevice(PointerEvent event) => TestAsyncUtils.guard<void>(
      () async => binding.handlePointerEventForSource(
        event,
        source: TestBindingEventSource.device,
      ),
    );

Future<void> _tapAt(WidgetTester tester, Offset at) async {
  final gesture = TestGesture(dispatcher: _asDevice);
  await gesture.down(at);
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

Offset _cellAt(WidgetTester tester, Cell cell) {
  final field = tester
      .widgetList<CustomPaint>(find.descendant(
        of: find.byType(RunScreen),
        matching: find.byType(CustomPaint),
      ))
      .where((paint) => paint.painter is FieldPainter)
      .first;
  final metrics = (field.painter as FieldPainter).metrics;
  return tester.getTopLeft(find.byWidget(field)) + metrics.rectOf(cell).center;
}

/// Lets the game run, a frame at a time.
Future<void> _letItRun(WidgetTester tester, Duration how) async {
  const frame = Duration(milliseconds: 16);
  for (var gone = Duration.zero; gone < how; gone += frame) {
    await tester.pump(frame);
  }
}

Future<void> _open(WidgetTester tester, {Run? at, bool playing = true}) async {
  await tester.pumpWidget(
    EmberlaneApp(opening: at, opensPlaying: playing),
  );
  await tester.pump();

  // Android hands back a black rectangle for a screenshot until the Flutter
  // surface is an image view. It is a no-op elsewhere and may be done only
  // once in a test.
  await binding.convertFlutterSurfaceToImage();
}

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pump();
  await binding.takeScreenshot(name);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    binding.shouldPropagateDevicePointerEvents = true;
    _midRun = Plan.held.play(
      until: (run) => run.wave >= 8 && !run.waiting && run.walking.length >= 5,
    );
  });

  testWidgets('opens on a title that says what the towers do', (tester) async {
    await _open(tester, playing: false);

    expect(find.text('Emberlane'), findsOneWidget);
    for (final tower in Tower.values) {
      expect(find.textContaining(tower.name), findsWidgets);
    }
    await _shoot(tester, '01-title');
  });

  testWidgets('photographs a wave coming down the lane', (tester) async {
    await _open(tester, at: _midRun);
    expect(find.byType(RunScreen), findsOneWidget);

    // A moment for the towers to fire, so the picture has shots in it.
    await _letItRun(tester, const Duration(milliseconds: 600));
    await _shoot(tester, '02-wave');

    // Placing a tower, with every square it could go on lit. This is the one
    // screen in the game that is doing something a board could not.
    await _tapAt(tester, tester.getCenter(find.text('Spark')));
    await _letItRun(tester, const Duration(milliseconds: 300));
    await _shoot(tester, '03-placing');

    // And built.
    const spot = Cell(5, 8);
    if (_midRun.canBuildOn(spot)) {
      await _tapAt(tester, _cellAt(tester, spot));
      await _letItRun(tester, const Duration(milliseconds: 400));
      await _shoot(tester, '04-built');
    }
  });

  testWidgets('photographs the keep falling', (tester) async {
    // Not posed: the careless plan really does lose, and this waits on the
    // device for it to happen.
    await _open(tester, at: Plan.silly.play(until: (at) => at.keep <= 1));

    for (var i = 0; i < 400; i++) {
      await _letItRun(tester, const Duration(milliseconds: 100));
      if (find.text('The keep falls').evaluate().isNotEmpty) break;
    }

    expect(find.text('The keep falls'), findsOneWidget);
    await _shoot(tester, '05-fallen');
  });
}
