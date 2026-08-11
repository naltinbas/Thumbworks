import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frankmoor/best.dart';
import 'package:frankmoor/ui/app.dart';
import 'package:frankmoor/ui/post_screen.dart';
import 'package:frankmoor/ui/postview.dart';

/// The bits every test that franks a letter needs.

/// A phone to lay the counter on.
const phone = Size(1170, 2532);

/// Bumped for every screen a test opens, so pumping the app twice in one
/// test hands the new widget a new state rather than the last letter's.
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
    child: FrankmoorApp(
      key: ValueKey(_openings++),
      opensAt: which,
      best: best,
    ),
  ));
  await tester.pump();
}

PostScreenState state(WidgetTester tester) =>
    tester.state<PostScreenState>(find.byType(PostScreen));

/// Licks a stamp from a pile: true the cheap one.
Future<void> lick(WidgetTester tester, bool cheap) async {
  final box = tester.renderObject<RenderBox>(
    find.byKey(PostScreenState.counterKey),
  );
  final metrics = Metrics(state(tester).play, box.size);
  final pile = cheap ? metrics.cheapPile() : metrics.dearPile();
  await tester.tapAt(box.localToGlobal(pile.center));
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

/// Pays the whole letter by asking the game which stamp keeps it payable.
Future<void> payItAll(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isPaid) {
    if (guard++ > 12) fail('the letter never paid');
    final next = state(tester).play.next;
    if (next == null) fail('no stamp keeps the letter payable');
    await lick(tester, next);
  }
}
