import 'package:bridgeholm/best.dart';
import 'package:bridgeholm/ui/app.dart';
import 'package:bridgeholm/ui/walk_screen.dart';
import 'package:bridgeholm/ui/walkview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bits every test that walks a town needs.

/// A phone to lay the map on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last town's.
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
    child: BridgeholmApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

WalkScreenState state(WidgetTester tester) =>
    tester.state<WalkScreenState>(find.byType(WalkScreen));

/// Taps a landing.
Future<void> tapGround(WidgetTester tester, int ground) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(WalkScreenState.townKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.groundCenter(ground)));
  await tester.pump();
}

/// Taps a bridge at its middle.
Future<void> tapBridge(WidgetTester tester, int bridge) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(WalkScreenState.townKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.bridgePoint(bridge, 0.5)));
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

/// Walks the whole town by asking the game where to stand and cross.
Future<void> walkItAll(WidgetTester tester) async {
  final start = state(tester).play.nextStart;
  expect(start, isNotNull, reason: 'no start offered');
  await tapGround(tester, start!);
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 12) fail('the walk never finished');
    final bridge = state(tester).play.nextBridge;
    expect(bridge, isNotNull, reason: 'no crossing offered');
    await tapBridge(tester, bridge!);
  }
}
