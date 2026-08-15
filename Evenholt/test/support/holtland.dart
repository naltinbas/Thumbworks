import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:evenholt/share/shares.dart';
import 'package:evenholt/ui/app.dart';
import 'package:evenholt/ui/share_screen.dart';
import 'package:evenholt/ui/trayview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a share, or on the sham when [which] is
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
  await tester.pumpWidget(const EvenholtApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Shares.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

ShareScreenState state(WidgetTester tester) =>
    tester.state<ShareScreenState>(find.byType(ShareScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a token through the painter's metrics.
Future<void> tapToken(WidgetTester tester, int number) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.tokenAt(number));
  await tester.pumpAndSettle();
}

/// Carries tokens across, one after another.
Future<void> carry(WidgetTester tester, List<int> numbers) async {
  for (final number in numbers) {
    await tapToken(tester, number);
  }
}

/// Deals by the pointer until the share lands.
Future<void> shareByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    await tapToken(tester, state(tester).pointing!);
  }
}
