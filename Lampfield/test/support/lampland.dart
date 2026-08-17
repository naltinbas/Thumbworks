import 'package:lampfield/lamp/levels.dart';
import 'package:lampfield/ui/lamp_screen.dart';
import 'package:lampfield/ui/app.dart';
import 'package:flutter/material.dart';
import 'package:lampfield/ui/lampview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an ask, or on the sham when [which] is null.
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
  await tester.pumpWidget(const LampfieldApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few asks only until it scrolls.
      await tester.scrollUntilVisible(tile, 80,
          scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

LampScreenState state(WidgetTester tester) =>
    tester.state<LampScreenState>(find.byType(LampScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Where a lamp stands on the screen, which is where a thumb goes.
Offset lampAt(WidgetTester tester, int lamp) {
  final where = board(tester);
  return where.topLeft + Metrics(where.size).lampAt(lamp);
}

/// Taps a lamp, which lights it or puts it out.
Future<void> tapLamp(WidgetTester tester, int lamp) async {
  await tester.tapAt(lampAt(tester, lamp));
  await tester.pumpAndSettle();
}

/// Lights and puts out lamps until the message reads [want].
Future<void> setMessage(WidgetTester tester, List<int> want,
    {int most = 20}) async {
  for (var k = 0; k < most; k++) {
    final was = state(tester).play;
    if (was.isOver) return;
    var lamp = 0;
    for (var i = 1; i <= want.length; i++) {
      if (was.message[i - 1] != want[i - 1]) {
        lamp = i;
        break;
      }
    }
    if (lamp == 0) return;
    await tapLamp(tester, lamp);
    if (identical(state(tester).play, was)) return;
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await tapLamp(tester, state(tester).pointing!);
}

/// Follows the pointer until the message lands, [most] lamps at most.
Future<void> sendByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
