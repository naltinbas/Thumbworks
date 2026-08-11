import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notchfield/best.dart';
import 'package:notchfield/ui/app.dart';
import 'package:notchfield/ui/ruler_screen.dart';
import 'package:notchfield/ui/rulerview.dart';

/// The bits every test that cuts a ruler needs.

/// A phone to lay the rule on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last ruler's.
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
    child: NotchfieldApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

RulerScreenState state(WidgetTester tester) =>
    tester.state<RulerScreenState>(find.byType(RulerScreen));

/// Taps one mark on the rule.
Future<void> tapMark(WidgetTester tester, int mark) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(RulerScreenState.ruleKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester
      .tapAt(box.localToGlobal(Offset(metrics.markX(mark), metrics.ruleY)));
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

/// Cuts the ruler by asking the game which mend comes next.
Future<void> cutItTrue(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 15) fail('the ruler never came true');
    final mend = state(tester).play.next;
    expect(mend, isNotNull, reason: 'no mend offered');
    await tapMark(tester, mend!);
  }
}
