import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beaconholt/best.dart';
import 'package:beaconholt/watch/fewest.dart';
import 'package:beaconholt/ui/app.dart';
import 'package:beaconholt/ui/watchview.dart';
import 'package:beaconholt/ui/watch_screen.dart';

/// The bits every test that lights a country needs.

/// A phone to lay the country out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last round's.
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
    child: BeaconholtApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

WatchScreenState state(WidgetTester tester) =>
    tester.state<WatchScreenState>(find.byType(WatchScreen));

/// Where a hill is on the screen, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int stop) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(WatchScreenState.countryKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.middleOf(stop));
}

/// Lights or puts out a beacon on a hill.
Future<void> light(WidgetTester tester, int stop) async {
  await tester.tapAt(whereIs(tester, stop));
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

/// Lights the fewest beacons there are, one hill at a time.
Future<void> lightItAll(WidgetTester tester) async {
  final land = state(tester).land;
  for (final hill in Beacons.fewestFor(land.country).where) {
    await light(tester, hill);
  }
}
