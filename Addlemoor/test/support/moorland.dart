import 'package:addlemoor/sum/moors.dart';
import 'package:addlemoor/ui/app.dart';
import 'package:addlemoor/ui/moor_screen.dart';
import 'package:addlemoor/ui/moorview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a moor, or on the moorland when [which] is
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
  await tester.pumpWidget(const AddlemoorApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Moors.at(which).name));
    await tester.pumpAndSettle();
  }
}

MoorScreenState state(WidgetTester tester) =>
    tester.state<MoorScreenState>(find.byType(MoorScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The moor board, as laid out.
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

/// Repaints a stone until it wears the wanted paint.
Future<void> paintTo(
    WidgetTester tester, int stone, int paint) async {
  var guard = 0;
  while (state(tester).play.painting[stone - 1] != paint &&
      guard++ < 3) {
    await tapStone(tester, stone);
  }
}

/// Paints the whole row to a target.
Future<void> paintAll(WidgetTester tester, List<int> target) async {
  for (var stone = 1; stone <= target.length; stone++) {
    await paintTo(tester, stone, target[stone - 1]);
  }
}
