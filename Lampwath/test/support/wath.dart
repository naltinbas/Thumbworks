import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lampwath/best.dart';
import 'package:lampwath/ui/app.dart';
import 'package:lampwath/ui/wath_screen.dart';
import 'package:lampwath/ui/wathview.dart';

/// The bits every test that crosses a bridge needs.

/// A phone to lay the wath out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last night's.
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
    child: LampwathApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

WathScreenState state(WidgetTester tester) =>
    tester.state<WathScreenState>(find.byType(WathScreen));

/// Where a walker stands, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int walker) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(WathScreenState.wathKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.middleOf(walker));
}

/// Picks a walker, or puts them back.
Future<void> pick(WidgetTester tester, int walker) async {
  await tester.tapAt(whereIs(tester, walker));
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

/// Sends the picked party across.
Future<void> crossNow(WidgetTester tester) async {
  final button = find.textContaining('Cross');
  await tester.ensureVisible(button.first);
  await tester.pump();
  await tester.tap(button.first);
  await tester.pump();
}

/// Crosses the whole night by asking the game who goes next.
Future<void> crossItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 16) fail('the night never ended');
    final party = state(tester).play.next;
    if (party == null) fail('nobody to send and the night is not over');
    for (var walker = 0; walker < state(tester).play.bridge.count; walker++) {
      if ((party & (1 << walker)) != 0) await pick(tester, walker);
    }
    await crossNow(tester);
  }
}
