import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pegbourne/best.dart';
import 'package:pegbourne/ui/app.dart';
import 'package:pegbourne/ui/code_screen.dart';
import 'package:pegbourne/ui/codeview.dart';

/// The bits every test that answers a riddle needs.

/// A phone to lay the table on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last riddle's.
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
    child: PegbourneApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

CodeScreenState state(WidgetTester tester) =>
    tester.state<CodeScreenState>(find.byType(CodeScreen));

/// Taps one candidate slot.
Future<void> tapSlot(WidgetTester tester, int slot) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(CodeScreenState.tableKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.candidateSlot(slot)));
  await tester.pump();
}

/// Turns a slot until it shows the colour.
Future<void> setSlot(WidgetTester tester, int slot, int colour) async {
  var guard = 0;
  while (state(tester).play.slots[slot] != colour && guard++ < 6) {
    await tapSlot(tester, slot);
  }
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Answers the riddle by following one mend at a time.
Future<void> answerIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 12) fail('the riddle never answered');
    final mend = state(tester).play.next;
    expect(mend, isNotNull, reason: 'no mend offered');
    await setSlot(tester, mend!.$1, mend.$2);
  }
}
