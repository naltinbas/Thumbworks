import 'package:bannford/best.dart';
import 'package:bannford/ui/app.dart';
import 'package:bannford/ui/banns_screen.dart';
import 'package:bannford/ui/bannsview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bits every test that weds a party needs.

/// A phone to lay the hall on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last party's.
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
    child: BannfordApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

BannsScreenState state(WidgetTester tester) =>
    tester.state<BannsScreenState>(find.byType(BannsScreen));

/// Taps one person's chip.
Future<void> tapChip(WidgetTester tester, int who) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(BannsScreenState.hallKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.chipCenter(who)));
  await tester.pump();
}

/// Weds two people with two taps.
Future<void> wed(WidgetTester tester, int one, int other) async {
  await tapChip(tester, one);
  await tapChip(tester, other);
}

/// Taps a button by the words on it.
Future<void> press(WidgetTester tester, String label) async {
  final button = find.text(label);
  await tester.ensureVisible(button);
  await tester.pump();
  await tester.tap(button);
  await tester.pump();
}

/// Settles the party by asking the game which couple comes next.
Future<void> settleItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isSettled) {
    if (guard++ > 15) fail('the party never settled');
    await press(tester, 'Show me');
    final couple = state(tester).pointing;
    expect(couple, isNotNull, reason: 'no couple offered');
    await wed(tester, couple!.$1, couple.$2);
  }
}
