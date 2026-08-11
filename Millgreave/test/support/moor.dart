import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:millgreave/best.dart';
import 'package:millgreave/ui/app.dart';
import 'package:millgreave/ui/moor_screen.dart';
import 'package:millgreave/ui/moorview.dart';

/// The bits every test that sets a moor needs.

/// A phone to lay the moor on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last moor's.
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
    child: MillgreaveApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

MoorScreenState state(WidgetTester tester) =>
    tester.state<MoorScreenState>(find.byType(MoorScreen));

/// Where a plot lies, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int file, int row) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(MoorScreenState.moorKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.plotRect(file, row).center);
}

/// Raises a mill at a plot.
Future<void> raise(WidgetTester tester, int file, int row) async {
  await tester.tapAt(whereIs(tester, file, row));
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

/// Sets the whole moor by asking the game where each mill goes.
Future<void> setItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isSet) {
    if (guard++ > 12) fail('the moor never set');
    final next = state(tester).play.next;
    if (next == null) fail('no plot keeps the moor settable');
    await raise(tester, next.$1, next.$2);
  }
}
