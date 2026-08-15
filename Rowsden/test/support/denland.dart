import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rowsden/school/levels.dart';
import 'package:rowsden/ui/app.dart';
import 'package:rowsden/ui/school_screen.dart';
import 'package:rowsden/ui/schoolview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a week, or on the sham when [which] is null.
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
  await tester.pumpWidget(const RowsdenApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

SchoolScreenState state(WidgetTester tester) =>
    tester.state<SchoolScreenState>(find.byType(SchoolScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Taps a girl on the bench through the painter's metrics.
Future<void> tapGirl(WidgetTester tester, int girl) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.benchAt(girl));
  await tester.pumpAndSettle();
}

/// Places girls one after another.
Future<void> placeAll(WidgetTester tester, List<int> girls) async {
  for (final g in girls) {
    await tapGirl(tester, g);
  }
}

/// Places by the pointer until the week lands.
Future<void> placeByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 40) {
    await press(tester, 'Show me');
    final (what, g) = state(tester).pointing!;
    if (what == 'out') {
      await press(tester, 'Back');
    } else {
      await tapGirl(tester, g);
    }
  }
}
