import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stillmere/mere/lightings.dart';
import 'package:stillmere/mere/rules.dart';
import 'package:stillmere/ui/app.dart';
import 'package:stillmere/ui/mere_screen.dart';
import 'package:stillmere/ui/mereview.dart';

/// Opens the app on a lighting, or on the sham when [which] is null.
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
  await tester.pumpWidget(const StillmereApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Lightings.at(which).name);
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

/// Taps a spot through the painter's metrics.
Future<void> tapSpot(WidgetTester tester, Spot spot) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(spot));
  await tester.pumpAndSettle();
}

/// Lights spots one after another.
Future<void> lightAll(WidgetTester tester, List<Spot> spots) async {
  for (final spot in spots) {
    await tapSpot(tester, spot);
  }
}

/// Lights by the pointer until the mere lies still.
Future<void> lightByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 16) {
    await press(tester, 'Show me');
    final (_, spot) = state(tester).pointing!;
    await tapSpot(tester, spot);
  }
}
