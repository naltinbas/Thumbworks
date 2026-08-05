import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marchcombe/best.dart';
import 'package:marchcombe/ui/app.dart';
import 'package:marchcombe/ui/dye_screen.dart';
import 'package:marchcombe/ui/mapview.dart';
import 'package:marchcombe/ui/palette.dart';

/// The bits every test that paints a map needs.

/// A phone to lay the map out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last map's.
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
    child: MarchcombeApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

DyeScreenState state(WidgetTester tester) =>
    tester.state<DyeScreenState>(find.byType(DyeScreen));

/// Where a field is on the screen, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int field) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(DyeScreenState.mapKey),
  );
  final metrics = Metrics(state(tester).play.land, box.size);
  return box.localToGlobal(metrics.nameSpot(field));
}

/// Picks a dye out of the pots, by the colour it is.
Future<void> pick(WidgetTester tester, int dye) async {
  await tester.tap(find.bySemanticsLabel(Palette.dyeNames[dye]));
  await tester.pump();
}

/// Puts the dye that is picked on a field.
Future<void> put(WidgetTester tester, int field) async {
  await tester.tapAt(whereIs(tester, field));
  await tester.pump();
}

/// Picks a dye and puts it on a field.
Future<void> paint(WidgetTester tester, int field, int dye) async {
  await pick(tester, dye);
  await put(tester, field);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Paints the whole map by asking the game what to do next and doing it.
Future<void> paintItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isFull) {
    if (guard++ > 40) fail('it never finished');
    await press(tester, 'Show me');
    final screen = state(tester);
    await put(tester, screen.pointing);
  }
}
