import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wickfell/best.dart';
import 'package:wickfell/ui/app.dart';
import 'package:wickfell/ui/board_screen.dart';

/// The bits every test that puts a board out needs.

/// A phone to lay the lamps out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last board's.
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

  await tester.pumpWidget(WickfellApp(
    key: ValueKey(_openings++),
    opensAt: which,
    best: best,
  ));
  await tester.pump();
}

BoardScreenState state(WidgetTester tester) =>
    tester.state<BoardScreenState>(find.byType(BoardScreen));

/// Presses a lamp. Matched on the front of the label, because it carries
/// whether the lamp is lit as well.
Future<void> pressLamp(WidgetTester tester, int at) async {
  await tester.tap(find.bySemanticsLabel(RegExp('^lamp ${at + 1},')));
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

/// Puts the board out by asking for each press and making it.
Future<void> putItOut(WidgetTester tester, {int most = 40}) async {
  for (var turn = 0; turn < most; turn++) {
    if (state(tester).play.isDone) return;
    final next = state(tester).play.nextPress;
    if (next == null) return;
    await pressLamp(tester, next);
  }
}
