import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:churnwick/best.dart';
import 'package:churnwick/ui/app.dart';
import 'package:churnwick/ui/churn_screen.dart';
import 'package:churnwick/ui/dairyview.dart';

/// The bits every test that measures a morning out needs.

/// A phone to lay the dairy out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last morning's.
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
    child: ChurnwickApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

ChurnScreenState state(WidgetTester tester) =>
    tester.state<ChurnScreenState>(find.byType(ChurnScreen));

Metrics _metrics(WidgetTester tester) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(ChurnScreenState.dairyKey),
  );
  return Metrics(state(tester).play, box.size);
}

Offset _global(WidgetTester tester, Offset local) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(ChurnScreenState.dairyKey),
  );
  return box.localToGlobal(local);
}

/// Taps a churn, worked out the way the game works it out.
Future<void> tapChurn(WidgetTester tester, int churn) async {
  await tester.tapAt(_global(tester, _metrics(tester).churnAt(churn).center));
  await tester.pump();
}

Future<void> tapVat(WidgetTester tester) async {
  await tester.tapAt(_global(tester, _metrics(tester).vat.center));
  await tester.pump();
}

Future<void> tapDrain(WidgetTester tester) async {
  await tester.tapAt(_global(tester, _metrics(tester).drain.center));
  await tester.pump();
}

/// Fills a churn: pick it up, then the vat.
Future<void> fill(WidgetTester tester, int churn) async {
  await tapChurn(tester, churn);
  await tapVat(tester);
}

/// Empties one: pick it up, then the drain.
Future<void> drain(WidgetTester tester, int churn) async {
  await tapChurn(tester, churn);
  await tapDrain(tester);
}

/// Pours one into another.
Future<void> tip(WidgetTester tester, int from, int into) async {
  await tapChurn(tester, from);
  await tapChurn(tester, into);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Measures the whole morning out by asking the game what to do next.
Future<void> measureItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 40) fail('it never finished');
    await press(tester, 'Show me');
  }
}
