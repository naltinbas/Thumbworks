import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turnstead/best.dart';
import 'package:turnstead/ui/app.dart';
import 'package:turnstead/ui/green_screen.dart';
import 'package:turnstead/ui/greenview.dart';

/// The bits every test that writes a card needs.

/// A phone to lay the green on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last card's.
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
    child: TurnsteadApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

GreenScreenState state(WidgetTester tester) =>
    tester.state<GreenScreenState>(find.byType(GreenScreen));

/// Where a badge stands, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int side) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(GreenScreenState.greenKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.badgeAt(side));
}

/// Picks a side.
Future<void> pick(WidgetTester tester, int side) async {
  await tester.tapAt(whereIs(tester, side));
  await tester.pump();
}

/// Pairs two sides.
Future<void> pair(WidgetTester tester, int a, int b) async {
  await pick(tester, a);
  await pick(tester, b);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Writes the whole card by asking the game which pairing works.
Future<void> writeItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isWritten) {
    if (guard++ > 50) fail('the card never wrote');
    final next = state(tester).play.next;
    if (next == null) fail('no pairing keeps the card writable');
    await pair(tester, next.$1, next.$2);
  }
}
