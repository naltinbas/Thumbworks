import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thrissleton/third/hands.dart';
import 'package:thrissleton/ui/app.dart';
import 'package:thrissleton/ui/third_screen.dart';
import 'package:thrissleton/ui/thirdview.dart';

/// Opens the app on a hand, or on the leton when [which] is
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
  await tester.pumpWidget(const ThrisletonApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Hands.at(which).name));
    await tester.pumpAndSettle();
  }
}

ThirdScreenState state(WidgetTester tester) =>
    tester.state<ThirdScreenState>(find.byType(ThirdScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The leton board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a stone through the painter's metrics.
Future<void> tapStone(WidgetTester tester, int stone) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.stoneAt(stone));
  await tester.pumpAndSettle();
}

/// Dials by the pointer until the hand lands.
Future<void> dialByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 15) {
    await press(tester, 'Show me');
    final stone = state(tester).pointing!;
    await tapStone(tester, stone);
  }
}
