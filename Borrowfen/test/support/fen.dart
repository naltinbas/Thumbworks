import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:borrowfen/debt/villages.dart';
import 'package:borrowfen/ui/app.dart';
import 'package:borrowfen/ui/fen_screen.dart';
import 'package:borrowfen/ui/fenview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a village, or on the fen when [which] is null.
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
  await tester.pumpWidget(const BorrowfenApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Villages.at(which).name));
    await tester.pumpAndSettle();
  }
}

FenScreenState state(WidgetTester tester) =>
    tester.state<FenScreenState>(find.byType(FenScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The village board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a house through the same metrics the painter draws by.
Future<void> tapHouse(WidgetTester tester, int at) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.houseAt(at));
  await tester.pumpAndSettle();
}
