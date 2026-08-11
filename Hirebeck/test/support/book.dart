import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hirebeck/best.dart';
import 'package:hirebeck/ui/app.dart';
import 'package:hirebeck/ui/book_screen.dart';
import 'package:hirebeck/ui/bookview.dart';

/// The bits every test that keeps a book needs.

/// A phone to lay the day on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last day's.
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
    child: HirebeckApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

BookScreenState state(WidgetTester tester) =>
    tester.state<BookScreenState>(find.byType(BookScreen));

/// Taps one hiring's bar.
Future<void> tapHiring(WidgetTester tester, int hiring) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(BookScreenState.dayKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.barRect(hiring).center));
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

/// Fills the book by asking the game which mend comes next.
Future<void> bookItFull(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 20) fail('the book never filled');
    final mend = state(tester).play.next;
    expect(mend, isNotNull, reason: 'no mend offered');
    await tapHiring(tester, mend!);
  }
}
