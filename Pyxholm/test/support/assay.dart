import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyxholm/best.dart';
import 'package:pyxholm/ui/app.dart';
import 'package:pyxholm/ui/assay_screen.dart';
import 'package:pyxholm/ui/beamview.dart';

/// The bits every test that settles a box needs.

/// A phone to lay the beam out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last box's.
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
    child: PyxholmApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

AssayScreenState state(WidgetTester tester) =>
    tester.state<AssayScreenState>(find.byType(AssayScreen));

/// Where a coin is on the screen, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int coin) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(AssayScreenState.beamKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.middleOf(coin));
}

/// Moves a coin on: aside, left pan, right pan, aside.
Future<void> move(WidgetTester tester, int coin) async {
  await tester.tapAt(whereIs(tester, coin));
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

/// Puts a weighing on the pans and weighs it.
Future<void> weigh(
  WidgetTester tester,
  List<int> left,
  List<int> right,
) async {
  for (final coin in left) {
    await move(tester, coin);
  }
  for (final coin in right) {
    await move(tester, coin);
    await move(tester, coin);
  }
  await press(tester, 'Weigh');
}

/// Settles the whole box by asking the game what to weigh next.
Future<void> settleItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 8) fail('the box never settled');
    await press(tester, 'Show me');
    await press(tester, 'Weigh');
  }
}
