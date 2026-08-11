import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shroveham/best.dart';
import 'package:shroveham/ui/app.dart';
import 'package:shroveham/ui/griddle_screen.dart';
import 'package:shroveham/ui/griddleview.dart';

/// The bits every test that flips a batch needs.

/// A phone to stand the stack on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last batch's.
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
    child: ShrovehamApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

GriddleScreenState state(WidgetTester tester) =>
    tester.state<GriddleScreenState>(find.byType(GriddleScreen));

/// Where a cake lies, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int under) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(GriddleScreenState.griddleKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.cakeRect(under).center);
}

/// Slides the slice under a cake and turns everything above it.
Future<void> flip(WidgetTester tester, int under) async {
  await tester.tapAt(whereIs(tester, under));
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

/// Serves the whole batch by asking the game where the slice goes.
Future<void> serveItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isServed) {
    if (guard++ > 12) fail('the batch never served');
    final next = state(tester).play.next;
    if (next == null) fail('no flip brings serving nearer');
    await flip(tester, next);
  }
}
