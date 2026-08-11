import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spanham/best.dart';
import 'package:spanham/ui/app.dart';
import 'package:spanham/ui/row_screen.dart';
import 'package:spanham/ui/rowview.dart';

/// The bits every test that sets a shelf needs.

/// A phone to lay the shelf on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last shelf's.
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
    child: SpanhamApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

RowScreenState state(WidgetTester tester) =>
    tester.state<RowScreenState>(find.byType(RowScreen));

/// Where a seat lies, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int seat) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(RowScreenState.shelfKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.seatRect(seat).center);
}

/// Places the pair in hand with its left block at a seat.
Future<void> place(WidgetTester tester, int seat) async {
  await tester.tapAt(whereIs(tester, seat));
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

/// Sets the whole shelf by asking the game where each pair goes.
Future<void> setItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isSet) {
    if (guard++ > 12) fail('the shelf never set');
    final next = state(tester).play.next;
    if (next == null) fail('no seat keeps the shelf settable');
    await place(tester, next);
  }
}
