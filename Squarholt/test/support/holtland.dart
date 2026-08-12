import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:squarholt/hoard/hoards.dart';
import 'package:squarholt/ui/app.dart';
import 'package:squarholt/ui/hoard_screen.dart';

/// Opens the app on a hoard, or on the holt when [which] is
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
  await tester.pumpWidget(const SquarholtApp());
  await tester.pumpAndSettle();
  if (which != null) {
    await tester.tap(find.text(Hoards.at(which).name));
    await tester.pumpAndSettle();
  }
}

HoardScreenState state(WidgetTester tester) =>
    tester.state<HoardScreenState>(find.byType(HoardScreen));

Future<void> press(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// Turns the dials by the pointer until the hoard pays.
Future<void> payByPointer(WidgetTester tester) async {
  var guard = 0;
  while (!state(tester).play.isDone && guard++ < 16) {
    await press(tester, 'Show me');
    final (first, up) = state(tester).pointing!;
    await press(
        tester,
        first
            ? (up ? 'copper +' : 'copper −')
            : (up ? 'slate +' : 'slate −'));
  }
}
