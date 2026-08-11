import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ringmarsh/best.dart';
import 'package:ringmarsh/ui/app.dart';
import 'package:ringmarsh/ui/ring_screen.dart';
import 'package:ringmarsh/ui/ringview.dart';

/// The bits every test that sets a watch needs.

/// A phone to lay the road on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last ring's.
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
    child: RingmarshApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

RingScreenState state(WidgetTester tester) =>
    tester.state<RingScreenState>(find.byType(RingScreen));

/// Taps one lantern.
Future<void> turn(WidgetTester tester, int place) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(RingScreenState.roadKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.lanternCenter(place)));
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

/// Sets the watch full by asking the game which lantern to turn.
Future<void> setItFull(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isFull) {
    if (guard++ > 20) fail('the watch never came full');
    final place = state(tester).play.next;
    expect(place, isNotNull, reason: 'no turn offered');
    await turn(tester, place!);
  }
}
