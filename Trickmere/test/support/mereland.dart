import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trickmere/deck/levels.dart';
import 'package:trickmere/deck/rules.dart';
import 'package:trickmere/ui/app.dart';
import 'package:trickmere/ui/deck_screen.dart';
import 'package:trickmere/ui/deckview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a hand, or on the sham when [which] is null.
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
  await tester.pumpWidget(const TrickmereApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

DeckScreenState state(WidgetTester tester) =>
    tester.state<DeckScreenState>(find.byType(DeckScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a card wherever it lies, through the painter's metrics.
Future<void> tapCard(WidgetTester tester, Playcard c) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(c));
  await tester.pumpAndSettle();
}

/// Taps cards one after another.
Future<void> tapAll(WidgetTester tester, List<Playcard> cards) async {
  for (final c in cards) {
    await tapCard(tester, c);
  }
}

/// Lays the hand by the pointer until the partner names it.
Future<void> layByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final (_, c) = state(tester).pointing!;
    await tapCard(tester, c);
  }
}
