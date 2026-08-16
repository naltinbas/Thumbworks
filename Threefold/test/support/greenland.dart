import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threefold/green/levels.dart';
import 'package:threefold/ui/app.dart';
import 'package:threefold/ui/green_screen.dart';
import 'package:threefold/ui/greenview.dart';
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
  await tester.pumpWidget(const ThreefoldApp());
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

GreenScreenState state(WidgetTester tester) =>
    tester.state<GreenScreenState>(find.byType(GreenScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps the lattice point [p] through the painter's metrics.
Future<void> tapPoint(WidgetTester tester, (int, int, int) p) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(p));
  await tester.pumpAndSettle();
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await tapPoint(tester, state(tester).pointing!);
}

/// Follows the pointer until the walker stands as asked, [most] steps
/// at most.
Future<void> standByPointer(WidgetTester tester, {int most = 5}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
