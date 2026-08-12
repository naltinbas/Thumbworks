import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tussockmere/best.dart';
import 'package:tussockmere/ui/app.dart';
import 'package:tussockmere/ui/mere_screen.dart';
import 'package:tussockmere/ui/mereview.dart';

/// The bits every test that steps a marsh needs.

/// A phone to lay the mere on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// field's.
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

  // In a boundary, so a screenshot can be taken of whatever a test
  // leaves on it without the test having to pump the app a second way.
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('screen'),
    child: TussockmereApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

MereScreenState state(WidgetTester tester) =>
    tester.state<MereScreenState>(find.byType(MereScreen));

/// Taps one tussock.
Future<void> tapTussock(WidgetTester tester, int at) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(MereScreenState.marshKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.middleOf(at)));
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

/// Links the banks by asking the game what the solve does.
Future<void> linkIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 20) fail('the banks were never linked');
    final way = state(tester).play.next;
    expect(way, isNotNull, reason: 'no way offered');
    switch (way!) {
      case 'take':
        await press(tester, 'Take the pie');
      case 'decline':
        await press(tester, 'Wave it by');
      default:
        await tapTussock(tester, int.parse(way));
    }
  }
}
