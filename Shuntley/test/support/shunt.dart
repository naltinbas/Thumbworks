import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shuntley/best.dart';
import 'package:shuntley/ui/app.dart';
import 'package:shuntley/ui/shunt_screen.dart';
import 'package:shuntley/ui/shuntview.dart';

/// The bits every test that slides a tray needs.

/// A phone to lay the tray on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last tray's.
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
    child: ShuntleyApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

ShuntScreenState state(WidgetTester tester) =>
    tester.state<ShuntScreenState>(find.byType(ShuntScreen));

/// Taps the tile at a cell.
Future<void> slide(WidgetTester tester, int cell) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(ShuntScreenState.trayKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.cellRect(cell).center));
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

/// Brings the tray home by asking the game which tile to shunt.
Future<void> shuntItHome(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isHome) {
    if (guard++ > 40) fail('the tray never came home');
    final cell = state(tester).play.next;
    expect(cell, isNotNull, reason: 'no shunt offered');
    await slide(tester, cell!);
  }
}
