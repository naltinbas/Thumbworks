import 'package:dealstone/deal/handfuls.dart';
import 'package:dealstone/ui/app.dart';
import 'package:dealstone/ui/deal_screen.dart';
import 'package:dealstone/ui/dealview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a handful, or on the stone when [which] is
/// null.
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
  await tester.pumpWidget(const DealstoneApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Handfuls.at(which).name));
    await tester.pumpAndSettle();
  }
}

DealScreenState state(WidgetTester tester) =>
    tester.state<DealScreenState>(find.byType(DealScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The stone board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a slot through the painter's metrics.
Future<void> tapSlot(WidgetTester tester, int slot) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.slotAt(slot));
  await tester.pumpAndSettle();
}

/// Piles by the pointer until the handful lands.
Future<void> dealByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 24) {
    await press(tester, 'Show me');
    final slot = state(tester).pointing!;
    await tapSlot(tester, slot);
  }
}
