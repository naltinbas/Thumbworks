import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:candleford/party/levels.dart';
import 'package:candleford/ui/app.dart';
import 'package:candleford/ui/party_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the sham when [which] is null.
Future<void> open(
  WidgetTester tester, {
  int? which,
  Size? screen,
}) async {
  SharedPreferences.setMockInitialValues({});
  if (screen != null) {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(const CandlefordApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few sets only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

PartyScreenState state(WidgetTester tester) =>
    tester.state<PartyScreenState>(find.byType(PartyScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Presses one of the four buttons: -10, -1, +1 or +10.
Future<void> turn(WidgetTester tester, int by) async {
  await tester.tap(find.byKey(Key('turn$by')));
  await tester.pumpAndSettle();
}

/// Presses until the party has [guests] guests, by tens then ones.
Future<void> gather(WidgetTester tester, int guests) async {
  var guard = 0;
  while (state(tester).play.guests != guests && guard++ < 60) {
    final gap = guests - state(tester).play.guests;
    await turn(tester, gap >= 10 ? 10 : gap > 0 ? 1 : gap <= -10 ? -10 : -1);
  }
}

/// Presses what the pointer says, once.
Future<void> turnByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final by = state(tester).pointing!;
  await turn(tester, by);
}

/// Follows the pointer until the ask is met, [most] presses at most.
Future<void> gatherByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await turnByPointer(tester);
  }
}
