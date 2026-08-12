import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sashmoor/pane/sashes.dart';
import 'package:sashmoor/ui/app.dart';
import 'package:sashmoor/ui/pane_screen.dart';
import 'package:sashmoor/ui/paneview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a sash, or on the moor when [which] is null.
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
  await tester.pumpWidget(const SashmoorApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Sashes.at(which).name));
    await tester.pumpAndSettle();
  }
}

PaneScreenState state(WidgetTester tester) =>
    tester.state<PaneScreenState>(find.byType(PaneScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The sash board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a light through the same metrics the painter draws by.
Future<void> tapLight(WidgetTester tester, int x, int y) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.lightAt(x, y));
  await tester.pumpAndSettle();
}

/// Sets every pane of a placing.
Future<void> setAll(
    WidgetTester tester, List<(int, int)> panes) async {
  for (final (x, y) in panes) {
    await tapLight(tester, x, y);
  }
}
