import 'package:filberthow/best.dart';
import 'package:filberthow/ui/app.dart';
import 'package:filberthow/ui/hoard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bits every test that empties a hoard needs.

/// A phone to spill the nuts on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last hoard's.
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
    child: FilberthowApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

HoardScreenState state(WidgetTester tester) =>
    tester.state<HoardScreenState>(find.byType(HoardScreen));

/// Taps the pile once: one more nut marked.
Future<void> mark(WidgetTester tester) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(HoardScreenState.pileKey),
  );
  await tester.tapAt(box.localToGlobal(
    Offset(box.size.width / 2, box.size.height * 0.2),
  ));
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

/// Marks so many and takes them.
Future<void> take(WidgetTester tester, int nuts) async {
  for (var nut = 0; nut < nuts; nut++) {
    await mark(tester);
  }
  await press(tester, 'Take');
}

/// Wins the whole hoard by asking the game what to take.
Future<void> winItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver) {
    if (guard++ > 40) fail('the hoard never emptied');
    await press(tester, 'Show me');
    expect(state(tester).pending, greaterThan(0),
        reason: 'no winning take offered');
    await press(tester, 'Take');
  }
}
