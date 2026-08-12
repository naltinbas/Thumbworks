import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:beadlow/best.dart';
import 'package:beadlow/ui/app.dart';
import 'package:beadlow/ui/bead_screen.dart';
import 'package:beadlow/ui/beadview.dart';

/// The bits every test that strings a ring needs.

/// A phone to pitch the stall on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// ring's.
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
    child: BeadlowApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

BeadScreenState state(WidgetTester tester) =>
    tester.state<BeadScreenState>(find.byType(BeadScreen));

/// Taps one bead of the table's ring.
Future<void> tapBead(WidgetTester tester, int at) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(BeadScreenState.stallKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.beadAt(at)));
  await tester.pump();
}

/// Dyes one bead until it holds [shade].
Future<void> dyeTo(WidgetTester tester, int at, int shade) async {
  var guard = 0;
  while (state(tester).play.beads[at] != shade) {
    if (guard++ > 4) fail('the bead never took shade $shade');
    await tapBead(tester, at);
  }
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Fills the shelf by asking the game what is missing.
Future<void> shelveIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 30) fail('the shelf never filled');
    final missing = state(tester).play.missing;
    expect(missing, isNotNull, reason: 'nothing missing offered');
    for (var at = 0; at < missing!.length; at++) {
      await dyeTo(tester, at, missing[at]);
    }
    await press(tester, 'String it');
  }
}
