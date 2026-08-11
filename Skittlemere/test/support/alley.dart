import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skittlemere/best.dart';
import 'package:skittlemere/ui/alley_screen.dart';
import 'package:skittlemere/ui/alleyview.dart';
import 'package:skittlemere/ui/app.dart';

/// The bits every test that bowls an alley needs.

/// A phone to stand the lane on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last alley's.
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
    child: SkittlemereApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

AlleyScreenState state(WidgetTester tester) =>
    tester.state<AlleyScreenState>(find.byType(AlleyScreen));

/// Taps one skittle.
Future<void> tapPin(WidgetTester tester, int row, int pin) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(AlleyScreenState.laneKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.pinCenter(row, pin)));
  await tester.pump();
}

/// Knocks a single with two taps on the same skittle.
Future<void> knockOne(WidgetTester tester, int row, int pin) async {
  await tapPin(tester, row, pin);
  await tapPin(tester, row, pin);
}

/// Knocks a pair with taps on two neighbours.
Future<void> knockTwo(
    WidgetTester tester, int row, int pin, int other) async {
  await tapPin(tester, row, pin);
  await tapPin(tester, row, other);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Wins the alley by asking the game which knock zeroes.
Future<void> bowlItHome(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).won) {
    if (guard++ > 20) fail('the alley never came home');
    final knock = state(tester).play.zeroing;
    expect(knock, isNotNull, reason: 'no zeroing knock offered');
    final (row, pin, other) = knock!;
    if (other < 0) {
      await knockOne(tester, row, pin);
    } else {
      await knockTwo(tester, row, pin, other);
    }
  }
}
