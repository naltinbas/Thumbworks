import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posygarth/best.dart';
import 'package:posygarth/ui/app.dart';
import 'package:posygarth/ui/garth_screen.dart';
import 'package:posygarth/ui/garthview.dart';

/// The bits every test that plants a garth needs.

/// A phone to lay the garden on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last garth's.
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
    child: PosygarthApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

GarthScreenState state(WidgetTester tester) =>
    tester.state<GarthScreenState>(find.byType(GarthScreen));

Metrics _metrics(WidgetTester tester) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(GarthScreenState.garthKey),
  );
  return Metrics(state(tester).play, box.size);
}

Offset _global(WidgetTester tester, Rect rect) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(GarthScreenState.garthKey),
  );
  return box.localToGlobal(rect.center);
}

/// Arms a flower chip.
Future<void> armFlower(WidgetTester tester, int flower) async {
  await tester.tapAt(_global(tester, _metrics(tester).flowerChip(flower)));
  await tester.pump();
}

/// Arms a colour chip.
Future<void> armColour(WidgetTester tester, int colour) async {
  await tester.tapAt(_global(tester, _metrics(tester).colourChip(colour)));
  await tester.pump();
}

/// Taps a bed.
Future<void> tapBed(WidgetTester tester, int bed) async {
  await tester.tapAt(_global(tester, _metrics(tester).bedRect(bed)));
  await tester.pump();
}

/// Arms and plants a posy.
Future<void> plant(
    WidgetTester tester, int bed, int flower, int colour) async {
  await armFlower(tester, flower);
  await armColour(tester, colour);
  await tapBed(tester, bed);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Blooms the whole garth by asking the game where each posy goes.
Future<void> bloomItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isBloomed) {
    if (guard++ > 30) fail('the garth never bloomed');
    await press(tester, 'Show me');
    final pointed = state(tester).pointing;
    expect(pointed, isNot(-1), reason: 'no posy offered');
    await tapBed(tester, pointed);
  }
}
