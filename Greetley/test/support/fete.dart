import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greetley/shake/lawns.dart';
import 'package:greetley/ui/app.dart';
import 'package:greetley/ui/lawn_screen.dart';
import 'package:greetley/ui/lawnview.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on a lawn, or on the fete when [which] is null.
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
  await tester.pumpWidget(const GreetleyApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Lawns.at(which).name));
    await tester.pumpAndSettle();
  }
}

LawnScreenState state(WidgetTester tester) =>
    tester.state<LawnScreenState>(find.byType(LawnScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The lawn board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a guest through the painter's metrics.
Future<void> tapGuest(WidgetTester tester, int guest) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.guestAt(guest));
  await tester.pumpAndSettle();
}

/// Shakes two guests together.
Future<void> shake(WidgetTester tester, (int, int) pair) async {
  await tapGuest(tester, pair.$1);
  await tapGuest(tester, pair.$2);
}

/// Shakes a whole lawn's worth.
Future<void> shakeAll(
    WidgetTester tester, List<(int, int)> pairs) async {
  for (final pair in pairs) {
    await shake(tester, pair);
  }
}
