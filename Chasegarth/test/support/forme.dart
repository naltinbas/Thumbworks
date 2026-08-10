import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chasegarth/best.dart';
import 'package:chasegarth/ui/app.dart';
import 'package:chasegarth/ui/forme_screen.dart';
import 'package:chasegarth/ui/formeview.dart';

/// The bits every test that slides a forme needs.

/// A phone to lay the bench out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last forme's.
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
    child: ChasegarthApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

FormeScreenState state(WidgetTester tester) =>
    tester.state<FormeScreenState>(find.byType(FormeScreen));

/// Where a cell of the chase is, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int cell) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(FormeScreenState.formeKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.cellRect(cell).center);
}

/// Slides the letter in a cell into the empty one.
Future<void> slide(WidgetTester tester, int cell) async {
  await tester.tapAt(whereIs(tester, cell));
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

/// Locks the whole forme by asking the game which letter to slide next.
Future<void> lockItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isLocked) {
    if (guard++ > 40) fail('it never locked');
    final next = state(tester).play.next;
    if (next == null) fail('nothing to slide and it does not read right');
    await slide(tester, next);
  }
}
