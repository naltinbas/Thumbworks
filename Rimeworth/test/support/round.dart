import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rimeworth/best.dart';
import 'package:rimeworth/ui/app.dart';
import 'package:rimeworth/ui/parishview.dart';
import 'package:rimeworth/ui/round_screen.dart';

/// The bits every test that drives a parish needs.

/// A phone to lay the parish out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last parish's.
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

  // In a boundary, so a screenshot can be taken of whatever a test leaves on
  // it without the test having to pump the app a second way.
  await tester.pumpWidget(RepaintBoundary(
    key: const Key('screen'),
    child: RimeworthApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

RoundScreenState state(WidgetTester tester) =>
    tester.state<RoundScreenState>(find.byType(RoundScreen));

/// Where a junction is on the screen, worked out the way the game works it
/// out.
Offset whereIs(WidgetTester tester, int junction) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(RoundScreenState.parishKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.middleOf(junction));
}

/// Sets the lorry down at a junction, or drives it there.
Future<void> drive(WidgetTester tester, int junction) async {
  await tester.tapAt(whereIs(tester, junction));
  await tester.pump();
}

/// Taps the middle of a lane rather than either end of it.
Future<void> driveLane(WidgetTester tester, int lane) async {
  final parish = state(tester).play.parish;
  final one = whereIs(tester, parish.lanes[lane].from);
  final other = whereIs(tester, parish.lanes[lane].to);
  await tester.tapAt(Offset((one.dx + other.dx) / 2, (one.dy + other.dy) / 2));
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

/// Salts the whole parish by asking the game where to go next and tapping
/// there, which is a thing a player could sit and do.
Future<void> saltItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 200) fail('it never finished');
    final next = state(tester).play.next;
    if (next == null) fail('it had nowhere to go and was not finished');
    await drive(tester, next);
  }
}
