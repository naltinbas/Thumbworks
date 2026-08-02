import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lockstead/best.dart';
import 'package:lockstead/lock/marks.dart';
import 'package:lockstead/ui/app.dart';
import 'package:lockstead/ui/board_screen.dart';
import 'package:lockstead/ui/peg.dart';

/// The bits every test that picks a lock needs.
///
/// The table of marks is handed in rather than worked out on an isolate: it
/// is the same table either way, and a test that waits a second for one it
/// already has is a test nobody runs.

/// A phone to lay a lock out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last lock's.
var _openings = 0;

Future<void> open(
  WidgetTester tester, {
  int? which,
  Marks? marks,
  int? secret,
  Best? best,
  Size screen = phone,
}) async {
  tester.view
    ..physicalSize = screen
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(LocksteadApp(
    key: ValueKey(_openings++),
    opensAt: which,
    marks: marks,
    secret: secret,
    best: best,
  ));
  await tester.pump();
}

BoardScreenState state(WidgetTester tester) =>
    tester.state<BoardScreenState>(find.byType(BoardScreen));

/// Puts a colour in the next empty peg. The colours along the bottom are the
/// only ones there are, so the nth of them is colour n.
Future<void> putPeg(WidgetTester tester, int colour) async {
  await tester.tap(find.bySemanticsLabel('colour ${colour + 1}'));
  await tester.pump();
}

/// Fills the row with a whole code and tries it.
Future<void> tryCode(WidgetTester tester, List<int> pegs) async {
  for (final colour in pegs) {
    await putPeg(tester, colour);
  }
  await press(tester, 'Try it');
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Picks the whole lock by asking and doing what it says.
///
/// The only way to open a lock in a test without being told the code: press
/// Show me, which fills the row with the guess that leaves the least behind,
/// and try it.
Future<void> pickIt(WidgetTester tester, {int most = 12}) async {
  for (var turn = 0; turn < most; turn++) {
    final play = state(tester).play;
    if (play == null || play.isOver) return;
    await press(tester, 'Show me');
    await press(tester, 'Try it');
  }
}

/// How many pegs are drawn on the screen right now, filled and empty.
int pegsOnScreen(WidgetTester tester) => find.byType(Peg).evaluate().length;
