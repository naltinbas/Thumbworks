import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riffleford/deck/riffles.dart';
import 'package:riffleford/ui/app.dart';
import 'package:riffleford/ui/deck_screen.dart';
import 'package:riffleford/ui/deckview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a riffle, or on the sham when [which] is null.
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
  await tester.pumpWidget(const RifflefordApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Riffles.at(which).name);
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

/// Taps a pile through the painter's metrics.
Future<void> tapPile(WidgetTester tester, String pile) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  final rect = pile == 'A' ? metrics.pileA : metrics.pileB;
  await tester.tapAt(room.topLeft + rect.center);
  await tester.pumpAndSettle();
}

/// Drops a run of piles.
Future<void> dropAll(WidgetTester tester, String drops) async {
  for (final pile in drops.split('')) {
    await tapPile(tester, pile);
  }
}

/// Riffles by the pointer until the deck lands.
Future<void> riffleByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 14) {
    await press(tester, 'Show me');
    await tapPile(tester, state(tester).pointing!);
  }
}
