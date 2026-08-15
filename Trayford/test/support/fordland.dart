import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trayford/count/trays.dart';
import 'package:trayford/ui/app.dart';
import 'package:trayford/ui/tray_screen.dart';
import 'package:trayford/ui/trayview.dart';

/// Opens the app on a tray, or on the sham when [which] is null.
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
  await tester.pumpWidget(const TrayfordApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Trays.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

TrayScreenState state(WidgetTester tester) =>
    tester.state<TrayScreenState>(find.byType(TrayScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a slot through the painter's metrics.
Future<void> tapSlot(WidgetTester tester, int slot) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.slotAt(slot));
  await tester.pumpAndSettle();
}

/// Fills by the pointer until the tray meets the asking.
Future<void> fillByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 6) {
    await press(tester, 'Show me');
    await tapSlot(tester, state(tester).pointing!);
  }
}
