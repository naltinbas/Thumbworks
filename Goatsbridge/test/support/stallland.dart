import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goatsbridge/stall/levels.dart';
import 'package:goatsbridge/ui/app.dart';
import 'package:goatsbridge/ui/stall_screen.dart';
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
  await tester.pumpWidget(const GoatsbridgeApp());
  await tester.pumpAndSettle();
  if (which != null) {
    final tile = find.text(Levels.at(which).name);
    if (tile.evaluate().isEmpty) {
      // A small screen lists the first few sets only until it scrolls.
      await tester.scrollUntilVisible(tile, 80, scrollable: find.byType(Scrollable).first);
    }
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }
}

StallScreenState state(WidgetTester tester) =>
    tester.state<StallScreenState>(find.byType(StallScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The board, as laid out.
Rect board(WidgetTester tester) =>
    tester.getRect(find.byKey(const Key('board')));

/// Presses one of the five buttons: doors-, doors+, opened-, opened+
/// or policy.
Future<void> set(WidgetTester tester, String what) async {
  await tester.tap(find.byKey(Key(what)));
  await tester.pumpAndSettle();
}

/// Presses until the stall stands at [doors] doors, [opened] opened,
/// staying or switching.
Future<void> setStall(WidgetTester tester, int doors, int opened, bool switching) async {
  var guard = 0;
  while (state(tester).play.doors != doors && guard++ < 20) {
    await set(tester, state(tester).play.doors < doors ? 'doors+' : 'doors-');
  }
  while (state(tester).play.opened != opened && guard++ < 40) {
    await set(tester, state(tester).play.opened < opened ? 'opened+' : 'opened-');
  }
  if (state(tester).play.switching != switching) {
    await set(tester, 'policy');
  }
}

/// Presses what the pointer says, once.
Future<void> setByPointer(WidgetTester tester) async {
  await press(tester, 'Show me');
  final what = state(tester).pointing!;
  await set(tester, what);
}

/// Follows the pointer until the ask is met, [most] presses at most.
Future<void> settleByPointer(WidgetTester tester, {int most = 40}) async {
  for (var k = 0; k < most && !state(tester).play.isDone; k++) {
    await setByPointer(tester);
  }
}
