import 'package:coursewell/course/yards.dart';
import 'package:coursewell/ui/app.dart';
import 'package:coursewell/ui/course_screen.dart';
import 'package:coursewell/ui/courseview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a yard, or on the yardland when [which] is
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
  await tester.pumpWidget(const CoursewellApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Yards.at(which).name));
    await tester.pumpAndSettle();
  }
}

CourseScreenState state(WidgetTester tester) =>
    tester.state<CourseScreenState>(find.byType(CourseScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The yard board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a cell through the painter's metrics.
Future<void> tapCell(WidgetTester tester, int cell) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.middleOf(cell));
  await tester.pumpAndSettle();
}

/// Lays or lifts one brick, cell then cell.
Future<void> brickOver(WidgetTester tester, (int, int) brick) async {
  await tapCell(tester, brick.$1);
  await tapCell(tester, brick.$2);
}

/// Lays bricks by the pointer until the yard lands.
Future<void> layByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 45) {
    await press(tester, 'Show me');
    final (brick, _) = state(tester).pointing!;
    await brickOver(tester, brick);
  }
}
