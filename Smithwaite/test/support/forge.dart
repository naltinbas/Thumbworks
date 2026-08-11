import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smithwaite/best.dart';
import 'package:smithwaite/ui/app.dart';
import 'package:smithwaite/ui/forge_screen.dart';
import 'package:smithwaite/ui/forgeview.dart';

/// The bits every test that works a puzzle needs.

/// A phone to lay the bench out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last puzzle's.
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
    child: SmithwaiteApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

ForgeScreenState state(WidgetTester tester) =>
    tester.state<ForgeScreenState>(find.byType(ForgeScreen));

/// Where a ring hangs, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int ring) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(ForgeScreenState.forgeKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.ringAt(ring));
}

/// Works a ring on or off the bar.
Future<void> move(WidgetTester tester, int ring) async {
  await tester.tapAt(whereIs(tester, ring));
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

/// Frees the whole bar by asking the game which move goes forward.
Future<void> freeItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isFree) {
    if (guard++ > 90) fail('the bar never came free');
    final next = state(tester).play.next;
    if (next == null) fail('no move goes forward and the bar is not free');
    await move(tester, next);
  }
}
