import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sortlow/mill/loads.dart';
import 'package:sortlow/ui/app.dart';
import 'package:sortlow/ui/mill_screen.dart';
import 'package:sortlow/ui/millview.dart';

/// Opens the app on a load, or on the low when [which] is null.
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
  await tester.pumpWidget(const SortlowApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Loads.at(which).name));
    await tester.pumpAndSettle();
  }
}

MillScreenState state(WidgetTester tester) =>
    tester.state<MillScreenState>(find.byType(MillScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The mill board, as laid out.
Rect board(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byType(GestureDetector),
            matching: find.byType(CustomPaint),
          )
          .first,
    );

/// Taps a dial through the painter's metrics.
Future<void> tapDial(WidgetTester tester, int slot) async {
  final room = board(tester);
  final metrics = Metrics(state(tester).play, room.size);
  await tester.tapAt(room.topLeft + metrics.dialOf(slot).center);
  await tester.pumpAndSettle();
}

/// Taps a dial until it shows [digit].
Future<void> dialTo(WidgetTester tester, int slot, int digit) async {
  var guard = 0;
  while (state(tester).play.digits[slot] != digit && guard++ < 11) {
    await tapDial(tester, slot);
  }
}

/// Dials by the pointer until the load lands.
Future<void> grindByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 40) {
    await press(tester, 'Show me');
    final slot = state(tester).pointing!;
    await tapDial(tester, slot);
  }
}
