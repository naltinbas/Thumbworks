import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirdwell/deal/walks.dart';
import 'package:thirdwell/ui/app.dart';
import 'package:thirdwell/ui/deal_screen.dart';
import 'package:thirdwell/ui/dealview.dart';

/// Opens the app on a walk, or on the sham when [which] is null.
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
  await tester.pumpWidget(const ThirdwellApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Walks.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

DealScreenState state(WidgetTester tester) =>
    tester.state<DealScreenState>(find.byType(DealScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a placing through the painter's metrics.
Future<void> tapPlacing(WidgetTester tester, int placing) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.placings[placing].center);
  await tester.pumpAndSettle();
}

/// Gathers by a run of placings.
Future<void> gatherAll(WidgetTester tester, List<int> placings) async {
  for (final p in placings) {
    await tapPlacing(tester, p);
  }
}

/// Walks by the pointer until the counter lands.
Future<void> walkByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 5) {
    await press(tester, 'Show me');
    await tapPlacing(tester, state(tester).pointing!);
  }
}
