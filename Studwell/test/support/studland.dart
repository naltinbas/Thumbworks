import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studwell/court/courts.dart';
import 'package:studwell/ui/app.dart';
import 'package:studwell/ui/court_screen.dart';
import 'package:studwell/ui/courtview.dart';

/// Opens the app on a court, or on the sham when [which] is
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
  await tester.pumpWidget(const StudwellApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Courts.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

CourtScreenState state(WidgetTester tester) =>
    tester.state<CourtScreenState>(find.byType(CourtScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The court board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a flag through the painter's metrics.
Future<void> tapCell(WidgetTester tester, int cell) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.cellAt(cell));
  await tester.pumpAndSettle();
}

/// Lays an elbow: its three flags tapped in turn.
Future<void> lay(WidgetTester tester, List<int> elbow) async {
  for (final cell in elbow) {
    await tapCell(tester, cell);
  }
}

/// Paves by the pointer until the court lands.
Future<void> paveByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    final (what, elbow) = state(tester).pointing!;
    if (what == 'lift') {
      await tapCell(tester, elbow.first);
    } else {
      await lay(tester, elbow);
    }
  }
}
