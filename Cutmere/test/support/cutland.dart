import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cutmere/cellar/levels.dart';
import 'package:cutmere/ui/app.dart';
import 'package:cutmere/ui/cellar_screen.dart';
import 'package:cutmere/ui/cellarview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a cellar, or on the sham when [which] is null.
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
  await tester.pumpWidget(const CutmereApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few cellars only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

CellarScreenState state(WidgetTester tester) =>
    tester.state<CellarScreenState>(find.byType(CellarScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a cask through the painter's metrics.
Future<void> tapCask(WidgetTester tester, int i) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.at(i));
  await tester.pumpAndSettle();
}

/// Taps casks one after another.
Future<void> tapAll(WidgetTester tester, List<int> casks) async {
  for (final i in casks) {
    await tapCask(tester, i);
  }
}

/// Searches the cellar as the pointer says.
Future<void> searchByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isOver && guard++ < 12) {
    await press(tester, 'Show me');
    final cask = state(tester).pointing!;
    await tapCask(tester, cask);
  }
}
