import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:haulyard/ui/app.dart';
import 'package:haulyard/ui/yard_painter.dart';
import 'package:haulyard/ui/yard_screen.dart';
import 'package:haulyard/yard/levels.dart';

// Pictures of the game running on a phone, taken by CI and handed back as
// artifacts. Nothing here runs under `flutter test`, which only looks in
// test/.
//
// This one does something the others cannot: it runs the search on the phone.
// Being shown what to do means searching the whole yard from where it stands,
// and how long that takes on a real device is a thing only a real device can
// say. The taps are device pointer events too, so they arrive the way a
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

YardScreenState _state(WidgetTester tester) =>
    tester.state<YardScreenState>(find.byType(YardScreen));

Finder _plot() => find.byWidgetPredicate(
      (widget) => widget is CustomPaint && widget.painter is YardPainter,
    );

YardPainter _painter(WidgetTester tester) =>
    tester.widget<CustomPaint>(_plot().first).painter! as YardPainter;

Future<void> _tapSquare(WidgetTester tester, int at) => _tapAt(
      tester,
      tester.getTopLeft(_plot().first) +
          _painter(tester).metrics.squareAt(at).center,
    );

Future<void> _press(WidgetTester tester, String label) =>
    _tapAt(tester, tester.getCenter(find.text(label)));

var _opened = 0;

Future<void> _open(WidgetTester tester, {int? which}) async {
  await tester.pumpWidget(
    HaulyardApp(key: ValueKey(_opened++), opensAt: which),
  );
  await tester.pump();

  if (!_surfaceConverted) {
    await binding.convertFlutterSurfaceToImage();
    _surfaceConverted = true;
  }
}

/// Follows what the game says, for so many shoves.
Future<void> _workOn(WidgetTester tester, int shoves) async {
  for (var turn = 0; turn < shoves; turn++) {
    if (_state(tester).yard.isDone) return;
    await _press(tester, 'Show me');
    final crate = _painter(tester).pointAt;
    final way = _painter(tester).pointWay;
    if (crate == null || way == null) return;
    await _tapSquare(tester, _state(tester).yard.ground.beyond(crate, way.back));
    await _tapSquare(tester, crate);
  }
}

Future<void> _shoot(WidgetTester tester, String name) async {
  await tester.pump();
  await binding.takeScreenshot(name);
}

void main() {
  binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => binding.shouldPropagateDevicePointerEvents = true);

  testWidgets('opens on the yards', (tester) async {
    await _open(tester);

    expect(find.text('Haulyard'), findsOneWidget);
    expect(find.text(Levels.at(0).name), findsOneWidget);
    await _shoot(tester, '01-yards');
  });

  testWidgets('shoves a crate with a real finger', (tester) async {
    await _open(tester, which: 4);
    final was = _state(tester).yard.crates.toList();

    await _press(tester, 'Show me');
    final crate = _painter(tester).pointAt!;
    final way = _painter(tester).pointWay!;
    await _tapSquare(tester, _state(tester).yard.ground.beyond(crate, way.back));
    await _tapSquare(tester, crate);

    expect(_state(tester).yard.crates, isNot(was),
        reason: 'the platform never delivered the taps');
    expect(_state(tester).yard.pushes, 1);
    await _shoot(tester, '02-working');
  });

  testWidgets('searches on the phone, and finishes the yard in par',
      (tester) async {
    // The heaviest yard there is, searched from a real device rather than
    // from a laptop.
    await _open(tester, which: Levels.count - 1);
    await _press(tester, 'Show me');
    expect(_painter(tester).pointAt, isNotNull);
    await _shoot(tester, '03-shown');

    await _workOn(tester, 200);
    expect(_state(tester).yard.isDone, isTrue);
    expect(_state(tester).yard.pushes, Levels.at(Levels.count - 1).par,
        reason: 'the way through it was not the shortest one');
    await _shoot(tester, '04-done');
  });
}
