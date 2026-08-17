import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truckleford/ui/app.dart';
import 'package:truckleford/ui/yard_screen.dart';
import 'package:truckleford/yard/levels.dart';

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
  await tester.pumpWidget(const TrucklefordApp());
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

YardScreenState state(WidgetTester tester) =>
    tester.state<YardScreenState>(find.byType(YardScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Works one of the three levers: 'shunt', 'roll' or 'send'.
Future<void> work(WidgetTester tester, String what) async {
  await tester.tap(find.byKey(Key(what)));
  await tester.pumpAndSettle();
}

/// Works the yard through a run of taps.
Future<void> run(WidgetTester tester, List<String> taps) async {
  for (final what in taps) {
    if (state(tester).play.isOver) return;
    await work(tester, what);
  }
}

/// Does what the pointer says, once.
Future<void> doByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  await work(tester, state(tester).pointing!);
}

/// Follows the pointer until the out-train lands, [most] taps at most.
Future<void> runByPointer(WidgetTester tester, {int most = 20}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await doByPointer(tester);
  }
}
