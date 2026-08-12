import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wickthorn/rope/greens.dart';
import 'package:wickthorn/ui/app.dart';
import 'package:wickthorn/ui/rope_screen.dart';
import 'package:wickthorn/ui/ropeview.dart';

/// Opens the app on a green, or on the village when [which] is null.
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
  await tester.pumpWidget(const WickthornApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Greens.at(which).name));
    await tester.pumpAndSettle();
  }
}

RopeScreenState state(WidgetTester tester) =>
    tester.state<RopeScreenState>(find.byType(RopeScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The green board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a lantern through the same metrics the painter draws by.
Future<void> tapLantern(WidgetTester tester, int lantern) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.lanternAt(lantern));
  await tester.pumpAndSettle();
}

/// Strings a rope through three lanterns.
Future<void> stringRope(
    WidgetTester tester, (int, int, int) rope) async {
  await tapLantern(tester, rope.$1);
  await tapLantern(tester, rope.$2);
  await tapLantern(tester, rope.$3);
}

/// Strings every rope of a closing.
Future<void> stringAll(
    WidgetTester tester, List<(int, int, int)> ropes) async {
  for (final rope in ropes) {
    await stringRope(tester, rope);
  }
}
