import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadewell/best.dart';
import 'package:shadewell/ui/app.dart';
import 'package:shadewell/ui/plot_screen.dart';
import 'package:shadewell/ui/plotview.dart';

/// The bits every test that shades a plot needs.

/// A phone to lay the garden on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last plot's.
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
    child: ShadewellApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

PlotScreenState state(WidgetTester tester) =>
    tester.state<PlotScreenState>(find.byType(PlotScreen));

/// Taps one cell once.
Future<void> tapCell(WidgetTester tester, int row, int col) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(PlotScreenState.gardenKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.cellRect(row, col).center));
  await tester.pump();
}

/// Shades a cell (one tap from unknown), or marks it bare (two).
Future<void> mark(WidgetTester tester, int row, int col,
    {required bool shade}) async {
  await tapCell(tester, row, col);
  if (!shade) await tapCell(tester, row, col);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Finishes the plot by following one deduction at a time.
Future<void> shadeItHome(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 60) fail('the plot never came home');
    final offer = state(tester).play.next;
    expect(offer, isNotNull, reason: 'no deduction offered');
    await mark(tester, offer!.$1, offer.$2, shade: offer.$3);
  }
}
