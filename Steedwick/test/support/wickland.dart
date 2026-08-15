import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steedwick/paddock/errands.dart';
import 'package:steedwick/ui/app.dart';
import 'package:steedwick/ui/paddock_screen.dart';
import 'package:steedwick/ui/paddockview.dart';

/// Opens the app on an errand, or on the sham when [which] is null.
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
  await tester.pumpWidget(const SteedwickApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Errands.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

PaddockScreenState state(WidgetTester tester) =>
    tester.state<PaddockScreenState>(find.byType(PaddockScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a stall through the painter's metrics.
Future<void> tapStall(WidgetTester tester, int stall) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(stall));
  await tester.pumpAndSettle();
}

/// Rides a steed: taps its stall, then the stall it goes to.
Future<void> ride(WidgetTester tester, int steed, int to) async {
  await tapStall(tester, state(tester).play.standing[steed]);
  await tapStall(tester, to);
}

/// Rides by the pointer until the errand is done.
Future<void> rideByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    final (steed, to) = state(tester).pointing!;
    await ride(tester, steed, to);
  }
}
