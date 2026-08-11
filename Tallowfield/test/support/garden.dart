import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tallowfield/best.dart';
import 'package:tallowfield/ui/app.dart';
import 'package:tallowfield/ui/garden_screen.dart';
import 'package:tallowfield/ui/gardenview.dart';

/// The bits every test that reads an evening needs.

/// A phone to lay the garden out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last evening's.
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
    child: TallowfieldApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

GardenScreenState state(WidgetTester tester) =>
    tester.state<GardenScreenState>(find.byType(GardenScreen));

/// Where a lantern stands, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int lamp) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(GardenScreenState.gardenKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.lampAt(lamp));
}

/// Reads the garden as naming a lantern.
Future<void> name(WidgetTester tester, int lamp) async {
  await tester.tapAt(whereIs(tester, lamp));
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
