import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wedgeworth/wedge/levels.dart';
import 'package:wedgeworth/ui/app.dart';
import 'package:wedgeworth/ui/wedge_screen.dart';
import 'package:wedgeworth/ui/wedgeview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the sham when [which] is null.
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
  await tester.pumpWidget(const WedgeworthApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few sets only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

WedgeScreenState state(WidgetTester tester) =>
    tester.state<WedgeScreenState>(find.byType(WedgeScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a dial's number through the painter's metrics: dial 0 the
/// sides, dial 1 the faces.
Future<void> tapDial(WidgetTester tester, int dial, int value) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(dial, value));
  await tester.pumpAndSettle();
}

/// Sets the sides and the faces by two taps.
Future<void> setCorner(WidgetTester tester, int sides, int faces) async {
  await tapDial(tester, 0, sides);
  await tapDial(tester, 1, faces);
}

/// Sets what the pointer says, once.
Future<void> setByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final (dial, value) = state(tester).pointing!;
  await tapDial(tester, dial, value);
}
