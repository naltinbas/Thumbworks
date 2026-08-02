import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cinderplot/game/play.dart';
import 'package:cinderplot/game/plots.dart';
import 'package:cinderplot/ui/app.dart';
import 'package:cinderplot/ui/plot_painter.dart';
import 'package:cinderplot/ui/plot_screen.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in
// test/.
//
// This one does something the others cannot: it lays out its boards on the
// phone. The maker runs on the device, at the device's speed, and if a board
// took long enough to lay out to be worth a spinner this is where that would
// show. The taps are device pointer events too, so they arrive the way a
// thumb's do rather than through the framework's side door.
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

Future<void> _tapAt(WidgetTester tester, Offset at) async {
  final gesture = TestGesture(dispatcher: _asDevice);
  await gesture.down(at);
  await tester.pump();
  await gesture.up();
  await tester.pump();
}

PlotScreenState _state(WidgetTester tester) =>
    tester.state<PlotScreenState>(find.byType(PlotScreen));

Finder _plot() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is PlotPainter,
    );

Metrics _metrics(WidgetTester tester) =>
    (tester.widget<CustomPaint>(_plot().first).painter! as PlotPainter).metrics;

Future<void> _open(WidgetTester tester, {int? which}) async {
  await tester.pumpWidget(CinderplotApp(opensAt: which));
  await tester.pump();

  if (!_surfaceConverted) {
    await binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }
}

Future<void> _press(WidgetTester tester, String label) async {
  await _tapAt(tester, tester.getCenter(find.text(label)));
}

/// Plays on by asking why and doing it, which is the only way to open squares
/// without knowing where the mines are.
Future<void> _playOn(WidgetTester tester, int turns) async {
  for (var turn = 0; turn < turns; turn++) {
    if (_state(tester).play.isOver) return;
    await _press(tester, 'Why?');
    if (_state(tester).showing == null) return;
    await _press(tester, 'Do it');
  }
}

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pump();
  await binding.takeScreenshot(name);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => binding.shouldPropagateDevicePointerEvents = true);

  testWidgets('opens on the plots', (tester) async {
    await _open(tester);

    expect(find.text('Cinderplot'), findsOneWidget);
    for (final plot in Plots.all) {
      expect(find.text(plot.name), findsOneWidget);
    }
    await _shoot(tester, '01-plots');
  });

  testWidgets('lays out a board on the phone and opens a square with a finger',
      (tester) async {
    await _open(tester, which: 1);
    expect(_state(tester).play.opened.length, greaterThan(3),
        reason: 'the maker ran on the device and gave back a board');

    await _playOn(tester, 12);

    // A real tap, on a square this test has proved is clear.
    final showing = _state(tester).showing;
    final clear = showing?.safe.firstOrNull ?? _state(tester).play.field.opening;
    await _tapAt(
      tester,
      tester.getTopLeft(_plot().first) +
          _metrics(tester).squareAt(clear).center,
    );
    expect(_state(tester).play.ending, isNot(Ending.blown),
        reason: 'the platform delivered the tap somewhere unexpected');

    await _shoot(tester, '02-digging');
  });

  testWidgets('says why, and then clears the board', (tester) async {
    await _open(tester, which: 0);
    await _playOn(tester, 6);
    await _press(tester, 'Why?');
    expect(_state(tester).showing, isNotNull);
    await _shoot(tester, '03-why');

    await _press(tester, 'Do it');
    await _playOn(tester, 500);
    expect(_state(tester).play.ending, Ending.cleared,
        reason: 'reasoning ran out on a real phone');
    await _shoot(tester, '04-cleared');
  });
}
