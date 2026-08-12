import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:braidfell/best.dart';
import 'package:braidfell/ui/app.dart';
import 'package:braidfell/ui/braid_screen.dart';
import 'package:braidfell/ui/braidview.dart';

/// The bits every test that braids a yard needs.

/// A phone to floor the yard with.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in
/// one test hands the new widget a new state rather than the last
/// yard's.
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
    child: BraidfellApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

BraidScreenState state(WidgetTester tester) =>
    tester.state<BraidScreenState>(find.byType(BraidScreen));

/// Taps one bundle by its place.
Future<void> tapBundle(WidgetTester tester, int at) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(BraidScreenState.yardKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.bundleAt(at).middle));
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

/// Braids the yard out by always taking the two lightest.
Future<void> braidIt(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 8) fail('the skein was never braided');
    final (one, two) = state(tester).play.lightest!;
    await tapBundle(tester, one);
    await tapBundle(tester, two);
  }
}
