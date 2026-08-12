import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farthingford/best.dart';
import 'package:farthingford/ui/app.dart';
import 'package:farthingford/ui/ford_screen.dart';

/// The bits every test that wades a reach needs.

/// A phone to run the stream across.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// reach's.
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

  // In a boundary, so a screenshot can be taken of whatever a test
  // leaves on it without the test having to pump the app a second way.
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('screen'),
    child: FarthingfordApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

FordScreenState state(WidgetTester tester) =>
    tester.state<FordScreenState>(find.byType(FordScreen));

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Makes the crossing by asking the game which way the walk goes.
Future<void> wadeIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 10) fail('the crossing was never made');
    final way = state(tester).play.next;
    expect(way, isNotNull, reason: 'no way offered');
    await press(tester, switch (way!) {
      'left' => 'Wade left',
      'right' => 'Wade right',
      _ => 'Cross here',
    });
  }
}
