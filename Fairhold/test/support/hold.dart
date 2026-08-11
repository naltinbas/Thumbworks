import 'package:fairhold/best.dart';
import 'package:fairhold/ui/app.dart';
import 'package:fairhold/ui/hold_screen.dart';
import 'package:fairhold/ui/holdview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The bits every test that stacks a consignment needs.

/// A phone to lay the yard on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last stack's.
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
    child: FairholdApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

HoldScreenState state(WidgetTester tester) =>
    tester.state<HoldScreenState>(find.byType(HoldScreen));

/// Taps a crate's chip once.
Future<void> tapChip(WidgetTester tester, int crate, int pair) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(HoldScreenState.yardKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  await tester.tapAt(box.localToGlobal(metrics.chipRect(crate, pair).center));
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

/// Stacks the whole consignment by asking the game which rope goes where.
Future<void> stackItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isStacked) {
    if (guard++ > 30) fail('the stack never stood');
    await press(tester, 'Show me');
    final hint = state(tester).pointing;
    expect(hint, isNotNull, reason: 'no choice offered');
    await tapChip(tester, hint!.$1, hint.$2);
    // The hint may have wanted east-west; a second tap moves it on.
    final wanted = state(tester).saying?.contains('east-west') ?? false;
    if (wanted &&
        state(tester).play.serves(hint.$1, hint.$2) == 'ns') {
      await tapChip(tester, hint.$1, hint.$2);
    }
  }
}
