import 'package:daisyholme/daisy/circles.dart';
import 'package:daisyholme/ui/app.dart';
import 'package:daisyholme/ui/daisy_screen.dart';
import 'package:daisyholme/ui/daisyview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a circle, or on the holme when [which] is
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
  await tester.pumpWidget(const DaisyholmeApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Circles.at(which).name));
    await tester.pumpAndSettle();
  }
}

DaisyScreenState state(WidgetTester tester) =>
    tester.state<DaisyScreenState>(find.byType(DaisyScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The holme board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a pair's wire through the painter's metrics.
Future<void> tapWire(WidgetTester tester, int pair) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.midOf(pair));
  await tester.pumpAndSettle();
}

/// Wires by the pointer until the circle settles.
Future<void> settleByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 14) {
    await press(tester, 'Show me');
    final pair = state(tester).pointing!;
    await tapWire(tester, pair);
  }
}
