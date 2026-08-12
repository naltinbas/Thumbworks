import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mottlemoor/best.dart';
import 'package:mottlemoor/ui/app.dart';
import 'package:mottlemoor/ui/herd_screen.dart';
import 'package:mottlemoor/ui/herdview.dart';

/// The bits every test that herds a moor needs.

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
    child: MottlemoorApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

HerdScreenState state(WidgetTester tester) =>
    tester.state<HerdScreenState>(find.byType(HerdScreen));

/// Taps one patch.
Future<void> tapPatch(WidgetTester tester, int herd) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(HerdScreenState.moorKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.patchCenter(herd)));
  await tester.pump();
}

/// Meets two herds with two taps.
Future<void> meet(WidgetTester tester, int one, int other) async {
  await tapPatch(tester, one);
  await tapPatch(tester, other);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Settles the moor by asking the game which meeting comes next.
Future<void> settleIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isSettled) {
    if (guard++ > 12) fail('the moor never settled');
    final meeting = state(tester).play.next;
    expect(meeting, isNotNull, reason: 'no meeting offered');
    await meet(tester, meeting!.$1, meeting.$2);
  }
}
