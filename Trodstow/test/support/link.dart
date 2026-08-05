import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trodstow/best.dart';
import 'package:trodstow/ui/app.dart';
import 'package:trodstow/ui/link_screen.dart';
import 'package:trodstow/ui/mapview.dart';

/// The bits every test that joins a parish up needs.

/// A phone to lay the map out on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one test
/// hands the new widget a new state rather than the last parish's.
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
    child: TrodstowApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

LinkScreenState state(WidgetTester tester) =>
    tester.state<LinkScreenState>(find.byType(LinkScreen));

/// Where the middle of a path is, worked out the way the game works it out.
Offset whereIs(WidgetTester tester, int trod) {
  final box = tester.renderObject<RenderBox>(
    find.byKey(LinkScreenState.mapKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  return box.localToGlobal(metrics.halfWay(trod));
}

/// Cuts a path, or fills it in again.
Future<void> cut(WidgetTester tester, int trod) async {
  await tester.tapAt(whereIs(tester, trod));
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

/// Joins the whole parish up by asking the game what to cut next.
Future<void> joinItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone) {
    if (guard++ > 20) fail('it never joined up');
    final next = state(tester).play.next;
    if (next == null) fail('nothing to cut and it is not joined up');
    await cut(tester, next);
  }
}
