import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setwick/set/dances.dart';
import 'package:setwick/ui/app.dart';
import 'package:setwick/ui/set_screen.dart';
import 'package:setwick/ui/setview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a set, or on the sham when [which] is null.
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
  await tester.pumpWidget(const SetwickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Dances.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

SetScreenState state(WidgetTester tester) =>
    tester.state<SetScreenState>(find.byType(SetScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a dancer through the painter's metrics.
Future<void> tapDancer(WidgetTester tester, int number) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(number));
  await tester.pumpAndSettle();
}

/// Pairs two dancers.
Future<void> pair(WidgetTester tester, int a, int b) async {
  await tapDancer(tester, a);
  await tapDancer(tester, b);
}

/// Pairs by the pointer until the set lands.
Future<void> pairByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    final (what, a, b) = state(tester).pointing!;
    if (what == 'lift') {
      await tapDancer(tester, a);
    } else {
      await pair(tester, a, b);
    }
  }
}
