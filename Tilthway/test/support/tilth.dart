import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tilthway/best.dart';
import 'package:tilthway/ui/app.dart';
import 'package:tilthway/ui/tilth_screen.dart';
import 'package:tilthway/ui/tilthview.dart';

/// The bits every test that sows a tilth needs.

/// A phone to lay the strip on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last board's.
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
  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('screen'),
      child: TilthwayApp(
        key: ValueKey(_openings++),
        opensAt: which,
        best: best,
      ),
    ),
  );
  await tester.pump();
}

TilthScreenState state(WidgetTester tester) =>
    tester.state<TilthScreenState>(find.byType(TilthScreen));

/// Taps a furrow's trough once.
Future<void> sow(WidgetTester tester, int furrow) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(TilthScreenState.stripKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.furrowRect(furrow).center));
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

/// Brings every seed home by asking the game which furrow sows.
Future<void> sowItAllHome(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isHome) {
    if (guard++ > 40) fail('the seeds never came home');
    final furrow = state(tester).play.next;
    expect(furrow, isNotNull, reason: 'no sowing offered');
    await sow(tester, furrow!);
  }
}
