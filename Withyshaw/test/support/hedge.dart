import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:withyshaw/best.dart';
import 'package:withyshaw/ui/app.dart';
import 'package:withyshaw/ui/hedge_screen.dart';
import 'package:withyshaw/ui/hedgeview.dart';

/// The bits every test that cuts a hedge needs.

/// A phone to stand the hedge on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last hedge's.
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

  // In a boundary, so a screenshot can be taken of whatever a test leaves
  // on it without the test having to pump the app a second way.
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('screen'),
    child: WithyshawApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

HedgeScreenState state(WidgetTester tester) =>
    tester.state<HedgeScreenState>(find.byType(HedgeScreen));

/// Where a withy stands, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int stalk, int at) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(HedgeScreenState.hedgeKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.withyRect(stalk, at).center);
}

/// Cuts a withy.
Future<void> cut(WidgetTester tester, int stalk, int at) async {
  await tester.tapAt(whereIs(tester, stalk, at));
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

/// Holds the whole hedge by asking the game where to cut.
Future<void> holdItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 20) fail('the hedge never settled');
    final next = state(tester).play.next;
    if (next == null) fail('no winning cut offered');
    await cut(tester, next.$1, next.$2);
  }
}
