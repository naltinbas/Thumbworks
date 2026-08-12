import 'package:crookmarsh/marsh/marshes.dart';
import 'package:crookmarsh/ui/app.dart';
import 'package:crookmarsh/ui/marsh_screen.dart';
import 'package:crookmarsh/ui/marshview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a marsh, or on the marshland when [which] is
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
  await tester.pumpWidget(const CrookmarshApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Marshes.at(which).name));
    await tester.pumpAndSettle();
  }
}

MarshScreenState state(WidgetTester tester) =>
    tester.state<MarshScreenState>(find.byType(MarshScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The marsh board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a crossing through the same metrics the painter draws by.
Future<void> tapCross(WidgetTester tester, int x, int y) async {
  final room = board(tester);
  final metrics = Metrics(room.size);
  await tester.tapAt(room.topLeft + metrics.crossAt(x, y));
  await tester.pumpAndSettle();
}

/// Sets every post of a setting.
Future<void> setAll(
    WidgetTester tester, List<(int, int)> posts) async {
  for (final (x, y) in posts) {
    await tapCross(tester, x, y);
  }
}
