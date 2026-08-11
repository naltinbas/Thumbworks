import 'package:charmstead/best.dart';
import 'package:charmstead/ui/app.dart';
import 'package:charmstead/ui/charm_screen.dart';
import 'package:charmstead/ui/charmview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bits every test that sets a charm needs.

/// A phone to lay the bed on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last charm's.
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
    child: CharmsteadApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

CharmScreenState state(WidgetTester tester) =>
    tester.state<CharmScreenState>(find.byType(CharmScreen));

/// Taps one bed cell.
Future<void> tapCell(WidgetTester tester, int cell) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(CharmScreenState.bedKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.cellRect(cell).center));
  await tester.pump();
}

/// Taps a tray coin.
Future<void> tapTray(WidgetTester tester, int worth) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(CharmScreenState.bedKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.trayCenter(worth)));
  await tester.pump();
}

/// Lays a coin with two taps.
Future<void> lay(WidgetTester tester, int cell, int worth) async {
  await tapTray(tester, worth);
  await tapCell(tester, cell);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Sets the charm by asking the game which mend comes next.
Future<void> setItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 20) fail('the charm never held');
    final mend = state(tester).play.next;
    expect(mend, isNotNull, reason: 'no mend offered');
    final (cell, coin) = mend!;
    if (coin == null) {
      await tapCell(tester, cell);
    } else {
      await lay(tester, cell, coin);
    }
  }
}
