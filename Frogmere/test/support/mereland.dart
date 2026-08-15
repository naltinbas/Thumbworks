import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frogmere/mere/reaches.dart';
import 'package:frogmere/mere/rules.dart';
import 'package:frogmere/ui/app.dart';
import 'package:frogmere/ui/mere_screen.dart';
import 'package:frogmere/ui/mereview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a reach, or on the sham when [which] is
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
  await tester.pumpWidget(const FrogmereApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Reaches.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

MereScreenState state(WidgetTester tester) =>
    tester.state<MereScreenState>(find.byType(MereScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a pad through the painter's metrics.
Future<void> tapPad(WidgetTester tester, Pad pad) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(pad));
  await tester.pumpAndSettle();
}

/// Leaps a frog: its pad tapped, then the pad it lands in.
Future<void> leap(WidgetTester tester, Pad from, Pad to) async {
  await tapPad(tester, from);
  await tapPad(tester, to);
}

/// Leaps by the pointer until the reach is reached.
Future<void> leapByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 25) {
    await press(tester, 'Show me');
    final aim = state(tester).pointing!;
    await leap(tester, aim.from, aim.to);
  }
}
