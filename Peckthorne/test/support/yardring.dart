import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peckthorne/peck/flocks.dart';
import 'package:peckthorne/ui/app.dart';
import 'package:peckthorne/ui/peck_screen.dart';
import 'package:peckthorne/ui/peckview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a flock, or on the yard when [which] is
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
  await tester.pumpWidget(const PeckthorneApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Flocks.at(which).name));
    await tester.pumpAndSettle();
  }
}

PeckScreenState state(WidgetTester tester) =>
    tester.state<PeckScreenState>(find.byType(PeckScreen));

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

/// Taps a pair's arrow through the painter's metrics.
Future<void> tapPair(WidgetTester tester, int pair) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.headOf(pair));
  await tester.pumpAndSettle();
}

/// Flips by the pointer until the flock lands.
Future<void> crownByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 12) {
    await press(tester, 'Show me');
    final pair = state(tester).pointing!;
    await tapPair(tester, pair);
  }
}
