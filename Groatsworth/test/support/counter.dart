import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:groatsworth/best.dart';
import 'package:groatsworth/ui/app.dart';
import 'package:groatsworth/ui/counter_screen.dart';
import 'package:groatsworth/ui/counterview.dart';

/// The bits every test that serves a customer needs.

/// A phone to lay the counter out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last round's.
var _openings = 0;

Future<void> open(
  WidgetTester tester, {
  int? which,
  Best? best,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  // In a boundary, so a screenshot can be taken of whatever a test leaves on
  // it without the test having to pump the app a second way.
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('screen'),
    child: GroatsworthApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

CounterScreenState state(WidgetTester tester) =>
    tester.state<CounterScreenState>(find.byType(CounterScreen));

Metrics _metrics(WidgetTester tester) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(CounterScreenState.counterKey),
  );
  return Metrics(state(tester).play, box.size);
}

Offset _global(WidgetTester tester, Offset local) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(CounterScreenState.counterKey),
  );
  return box.localToGlobal(local);
}

/// Puts a coin down, worked out the way the game works it out.
Future<void> put(WidgetTester tester, int kind) async {
  await tester.tapAt(_global(tester, _metrics(tester).tillAt(kind)));
  await tester.pump();
}

/// Takes the coin at a tray place back.
Future<void> take(WidgetTester tester, int place) async {
  await tester.tapAt(_global(tester, _metrics(tester).trayAt(place)));
  await tester.pump();
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Serves the whole customer by asking the game which coin comes next.
Future<void> payItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 20) fail('the customer was never served');
    final next = state(tester).play.next;
    if (next == null) fail('nothing to put down and the amount is not met');
    await put(tester, next);
  }
}
