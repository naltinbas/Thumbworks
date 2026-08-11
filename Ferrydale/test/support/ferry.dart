import 'package:ferrydale/best.dart';
import 'package:ferrydale/ui/app.dart';
import 'package:ferrydale/ui/ferry_screen.dart';
import 'package:ferrydale/ui/ferryview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bits every test that rows a ferry needs.

/// A phone to lay the river on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last river's.
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
    child: FerrydaleApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

FerryScreenState state(WidgetTester tester) =>
    tester.state<FerryScreenState>(find.byType(FerryScreen));

/// Taps one passenger.
Future<void> tapChip(WidgetTester tester, int who) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(FerryScreenState.riverKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.chipCenter(who)));
  await tester.pump();
}

/// Taps the boat to row.
Future<void> rowBoat(WidgetTester tester) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(FerryScreenState.riverKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  // The hull, below the seats: the seats hold tappable passengers.
  final boat = metrics.boatRect();
  await tester.tapAt(
      box.localToGlobal(Offset(boat.center.dx, boat.bottom - 2)));
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

/// Rows everyone across by asking the game which load comes next.
Future<void> rowItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 15) fail('the ferry never landed');
    final load = state(tester).play.nextLoad;
    expect(load, isNotNull, reason: 'no load offered');
    for (final who in load!) {
      await tapChip(tester, who);
    }
    await rowBoat(tester);
  }
}
