import 'package:ellmarsh/best.dart';
import 'package:ellmarsh/ui/app.dart';
import 'package:ellmarsh/ui/cloth_screen.dart';
import 'package:ellmarsh/ui/clothview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bits every test that cuts a bench needs.

/// A phone to lay the bench on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last bench's.
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
    child: EllmarshApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

ClothScreenState state(WidgetTester tester) =>
    tester.state<ClothScreenState>(find.byType(ClothScreen));

/// Taps the long bolt once: one more length marked.
Future<void> markOne(WidgetTester tester) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(ClothScreenState.benchKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.longRect().center));
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

/// Marks so many lengths and cuts them.
Future<void> cut(WidgetTester tester, int times) async {
  for (var time = 0; time < times; time++) {
    await markOne(tester);
  }
  await press(tester, 'Cut');
}

/// Holds the whole bench by asking the game what to cut.
Future<void> holdItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 30) fail('the bench never settled');
    await press(tester, 'Show me');
    expect(state(tester).pending, greaterThan(0),
        reason: 'no winning cut offered');
    await press(tester, 'Cut');
  }
}
