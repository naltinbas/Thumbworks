import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oddrow/row/askings.dart';
import 'package:oddrow/ui/app.dart';
import 'package:oddrow/ui/row_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens the app on an asking, or on the wall when [which] is
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
  await tester.pumpWidget(const OddrowApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Askings.at(which).name));
    await tester.pumpAndSettle();
  }
}

RowScreenState state(WidgetTester tester) =>
    tester.state<RowScreenState>(find.byType(RowScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Winds until the wall stands at [row].
Future<void> windTo(WidgetTester tester, int row) async {
  var guard = 0;
  while (state(tester).play.at != row && guard++ < 20) {
    await press(tester,
        state(tester).play.at < row ? 'wind down' : 'wind up');
  }
}

/// Winds by the pointer until the asking lands.
Future<void> windByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 20) {
    await press(tester, 'Show me');
    final down = state(tester).pointing!;
    await press(tester, down ? 'wind down' : 'wind up');
  }
}
