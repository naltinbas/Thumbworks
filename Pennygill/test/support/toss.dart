import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pennygill/best.dart';
import 'package:pennygill/toss/call.dart';
import 'package:pennygill/ui/app.dart';
import 'package:pennygill/ui/toss_screen.dart';
import 'package:pennygill/ui/tossview.dart';

/// The bits every test that plays a table needs.

/// A phone to lay the table on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last match's.
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
    child: PennygillApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

TossScreenState state(WidgetTester tester) =>
    tester.state<TossScreenState>(find.byType(TossScreen));

/// Where a call's plaque lies while calling.
Offset whereIs(WidgetTester tester, Call call) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(TossScreenState.tableKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.callRect(call.flips).center);
}

/// Makes a call by tapping its plaque.
Future<void> call(WidgetTester tester, Call call) async {
  await tester.tapAt(whereIs(tester, call));
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

/// Tosses until the match settles, however long the coin takes.
Future<void> tossItOut(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 600) fail('the match never settled');
    await press(tester, 'Toss');
  }
}
