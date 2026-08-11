import 'package:boardleigh/best.dart';
import 'package:boardleigh/ui/app.dart';
import 'package:boardleigh/ui/floor_screen.dart';
import 'package:boardleigh/ui/floorview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bits every test that floors a room needs.

/// A phone to lay the room on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last room's.
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
    child: BoardleighApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

FloorScreenState state(WidgetTester tester) =>
    tester.state<FloorScreenState>(find.byType(FloorScreen));

/// Taps one cell.
Future<void> tapCell(WidgetTester tester, int cell) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(FloorScreenState.roomKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.cellRect(cell).center));
  await tester.pump();
}

/// Lays a plank with two taps.
Future<void> layPlank(WidgetTester tester, int one, int other) async {
  await tapCell(tester, one);
  await tapCell(tester, other);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Floors the room by asking the game which plank comes next.
Future<void> floorItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 12) fail('the floor never laid');
    final plank = state(tester).play.next;
    expect(plank, isNotNull, reason: 'no plank offered');
    await layPlank(tester, plank!.$1, plank.$2);
  }
}
