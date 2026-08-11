import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wickfield/best.dart';
import 'package:wickfield/ui/app.dart';
import 'package:wickfield/ui/wick_screen.dart';
import 'package:wickfield/ui/wickview.dart';

/// The bits every test that presses a board needs.

/// A phone to lay the board on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last board's.
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
    child: WickfieldApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

WickScreenState state(WidgetTester tester) =>
    tester.state<WickScreenState>(find.byType(WickScreen));

/// Presses one lamp.
Future<void> lamp(WidgetTester tester, int cell) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(WickScreenState.boardKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.cellRect(cell).center));
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

/// Darkens the whole board by asking the game which lamp to press.
Future<void> pressItDark(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDark) {
    if (guard++ > 20) fail('the board never went dark');
    final cell = state(tester).play.next;
    expect(cell, isNotNull, reason: 'no press offered');
    await lamp(tester, cell!);
  }
}
