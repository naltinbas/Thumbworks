import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brackenside/hill/hills.dart';
import 'package:brackenside/ui/app.dart';
import 'package:brackenside/ui/hill_screen.dart';
import 'package:brackenside/ui/hillview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a hill, or on the hillside when [which] is null.
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
  await tester.pumpWidget(const BrackensideApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Hills.at(which).name));
    await tester.pumpAndSettle();
  }
}

HillScreenState state(WidgetTester tester) =>
    tester.state<HillScreenState>(find.byType(HillScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The hill board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a spot through the same metrics the painter draws by.
Future<void> tapSpot(WidgetTester tester, int row, int place) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.spotAt(row, place));
  await tester.pumpAndSettle();
}

/// Replants a spot until it wears the wanted plant.
Future<void> plantTo(
    WidgetTester tester, (int, int) spot, String plant) async {
  var guard = 0;
  while (state(tester).play.planted[spot] != plant && guard++ < 3) {
    await tapSpot(tester, spot.$1, spot.$2);
  }
}

/// Follows the pointer until the hill lands its asking.
Future<void> plantByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 24) {
    await press(tester, 'Show me');
    final aim = state(tester).pointing!;
    await plantTo(tester, aim.$1, aim.$2);
  }
}
