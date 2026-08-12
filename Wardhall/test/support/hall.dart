import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardhall/best.dart';
import 'package:wardhall/ui/app.dart';
import 'package:wardhall/ui/hall_screen.dart';
import 'package:wardhall/ui/hallview.dart';

/// The bits every test that wards a hall needs.

/// A phone to build the keep on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// hall's.
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
    child: WardhallApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

HallScreenState state(WidgetTester tester) =>
    tester.state<HallScreenState>(find.byType(HallScreen));

/// Taps one corner by its index.
Future<void> tapCorner(WidgetTester tester, int corner) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(HallScreenState.hallKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(
      box.localToGlobal(metrics.at(state(tester).play.hall.corners[corner])));
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

/// Lights the hall by asking the game which corner comes next.
Future<void> lightIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 6) fail('the hall never lit');
    final play = state(tester).play;
    final watch = play.finished;
    expect(watch, isNotNull, reason: 'no watch offered');
    await tapCorner(tester, play.nextOf(watch!)!);
  }
}
