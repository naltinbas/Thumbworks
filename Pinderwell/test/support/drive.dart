import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinderwell/best.dart';
import 'package:pinderwell/ui/app.dart';
import 'package:pinderwell/ui/drive_screen.dart';
import 'package:pinderwell/ui/fieldview.dart';

/// The bits every test that drives a ewe needs.

/// A phone to lay the field out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last drive's.
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
    child: PinderwellApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

DriveScreenState state(WidgetTester tester) =>
    tester.state<DriveScreenState>(find.byType(DriveScreen));

/// Where a square stands, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int east, int north) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(DriveScreenState.fieldKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.middleOf(east, north));
}

/// Pushes the ewe to a square, and the pinder answers on its heels.
Future<void> push(WidgetTester tester, int east, int north) async {
  await tester.tapAt(whereIs(tester, east, north));
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

/// Wins the whole drive by asking the game where to push.
Future<void> winItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 20) fail('the drive never ended');
    final next = state(tester).play.next;
    if (next == null) fail('no winning push and the drive is not over');
    await push(tester, next.$1, next.$2);
  }
}
